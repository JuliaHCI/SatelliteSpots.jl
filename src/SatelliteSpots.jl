module SatelliteSpots

using PSFModels
using Photometry
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

function center_of_mass(image::AbstractMatrix{T}; min_value=zero(T)) where T
    x = y = zero(typeof(one(T) / one(T)))
    norm = zero(T)
    @inbounds for idx in CartesianIndices(image)
        w = image[idx]
        w < min_value && continue
        norm += w
        x += idx.I[1] * w
        y += idx.I[2] * w
    end
    return x / norm, y / norm
end

function fit(image::AbstractMatrix, args...; n, r, angle=0, width=20, center=center(image), kwargs...)
    # determine azimuthal angle of each spot
    angles = ntuple(i -> mod(angle + (i - 1) * 360 / n, 360), n)
    # get cutout indices
    inds = map(ang -> get_cutout_inds(axes(image), r, ang; width, center), angles)
    return fit(image, args..., inds; kwargs...)
end

function fit(image::AbstractMatrix, psfmodel, initial, inds; kwargs...)
    nspots = length(inds)

    results = map(inds) do _inds
        stamp = @view image[_inds...]
        com = center_of_mass(stamp)
        amp = maximum(stamp)
        params = (;x=com[1], y=com[2], amp, initial...)
        PSFModels.fit(psfmodel, params, image, _inds; kwargs...)
    end

    return results
end

end