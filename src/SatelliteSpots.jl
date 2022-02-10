module SatelliteSpots

using ConcreteStructs
using Photometry
using Printf
using PSFModels
using Statistics

center(axes) = map(ax -> (last(ax) - first(ax)) / 2 + first(ax), axes)
center(arr::AbstractArray) = center(axes(arr))

function get_cutout_inds(axes, r, angle; width=20, center=center(axes), kwargs...)
    # find index of new center
    sint, cost = sincosd(angle)
    delta = r * cost, r * sint # CCW
    point = delta .+ center
    half_width = width / 2
    return map(p -> floor(Int, p - half_width):floor(Int, p + half_width), point)
end

function center_of_mass(image::AbstractMatrix{T}, inds=CartesianIndices(image); min_value=zero(T)) where T
    x = y = zero(typeof(one(T) / one(T)))
    norm = zero(T)
    @inbounds for idx in inds
        w = image[idx]
        w < min_value && continue
        norm += w
        x += idx.I[1] * w
        y += idx.I[2] * w
    end
    return x / norm, y / norm
end

function fit(psfmodel, initial, image::AbstractMatrix; n, r, angle=0, width=20, center=center(image), kwargs...)
    # determine azimuthal angle of each spot
    angles = ntuple(i -> mod(angle + (i - 1) * 360 / n, 360), n)
    # get cutout indices
    inds = map(ang -> get_cutout_inds(axes(image), r, ang; width, center), angles)
    return fit(psfmodel, initial, image, inds; kwargs...)
end

function fit(psfmodel, initial, image::AbstractMatrix, inds; kwargs...)
    nspots = length(inds)

    results = map(inds) do _inds
        cartinds = CartesianIndices(_inds)
        com = center_of_mass(image, cartinds)
        cominds = round.(Int, com)
        amp = image[cominds...]
        params = (;x=com[1], y=com[2], amp, initial...)
        PSFModels.fit(psfmodel, params, image, _inds; kwargs...)
    end
    params = map(first, results)
    models = map(last, results)
    return SpotResults(params, models, inds, axes(image))
end

@concrete struct SpotResults
    params
    models
    inds
    full_inds
end

Base.iterate(res::SpotResults) = iterate(res.params)
Base.iterate(res::SpotResults, i) = iterate(res.params, i)
Base.size(res::SpotResults) = size(res.params)
Base.length(res::SpotResults) = length(res.params)

function cross_center(result::SpotResults)
    x = y = 0
    for params in result.params
        x += params.x
        y += params.y
    end
    norm = length(result)
    return x / norm, y / norm
end

function radii(result::SpotResults, center=cross_center(result))
    map(params -> sqrt((params.x - center[1])^2 + (params.y - center[2])^2), result.params)
end

function angles(result::SpotResults, center=cross_center(result))
    map(params -> atand(params.y - center[2], params.x - center[1]), result.params)
end

function centers(result::SpotResults)
    map(params -> (params.x, params.y), result.params)
end

function models(result::SpotResults, inds=result.inds)
    map(result.models, inds) do model, _inds
        cartinds = CartesianIndices(_inds)
        model.(cartinds)
    end
end

function full_model!(out, result::SpotResults, inds=result.full_inds)
    cartinds = CartesianIndices(inds)
    for model in result.models
        @views @. out += model(cartinds)
    end
    return out
end

full_model(result::SpotResults, inds=result.full_inds) = full_model!(zeros(inds), result, inds)

function photometry(result::SpotResults; factor=0.5)
    image = full_model(result)
    map(result.params) do params
        ap = _aperture(params.x, params.y, params.fwhm, factor; params...)
        Photometry.photometry(ap, image).aperture_sum
    end
end

function photometry(result::SpotResults, fwhm; factor=0.5)
    image = full_model(result)
    map(result.params) do params
        ap = _aperture(params.x, params.y, fwhm, factor; params...)
        Photometry.photometry(ap, image).aperture_sum
    end
end

_aperture(x, y, fwhm, factor=0.5; kwargs...) = CircularAperture(x, y, factor * fwhm)
function _aperture(x, y, fwhm::Union{<:AbstractVector,Tuple}, factor=0.5; theta=0, kwargs...)
    EllipticalAperture(x, y, factor * fwhm[1], factor * fwhm[2], theta)
end

function Base.show(io::IO, result::SpotResults)
    n = length(result)
    ctr = cross_center(result)
    
    dists = radii(result, ctr)
    mean_dist = mean(dists)
    std_dist = std(dists; corrected=false, mean=mean_dist)

    angs = angles(result, ctr)
    offsets = ntuple(i -> mod(angs[i], 360) - (i - 1) * 360 / n, n)
    mean_ang = mean(offsets)
    std_ang = std(offsets; corrected=false, mean=mean_ang)

    phots = photometry(result)
    mean_phot = mean(phots)
    std_phot = std(phots; corrected=false, mean=mean_phot)
    
    @printf io "Satellite Spots (# spots: %d)\n" n
    @printf io "----------------------------\n"
    # @printf io "\n" n
    @printf io "center     [x,y] : (%.2f, %.2f)\n" ctr...
    @printf io "distance    [px] : %.2f ± %.4f\n" mean_dist std_dist
    @printf io "angle offset [°] : %.2f ± %.4f\n" mean_ang std_ang
    @printf io "photometry       : %.2f ± %.2f" mean_phot std_phot
end

end # module
