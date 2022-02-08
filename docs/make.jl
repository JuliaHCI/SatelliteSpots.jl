using SatelliteSpots
using Documenter

DocMeta.setdocmeta!(SatelliteSpots, :DocTestSetup, :(using SatelliteSpots); recursive=true)

makedocs(;
    modules=[SatelliteSpots],
    authors="mileslucas <mdlucas@hawaii.edu> and contributors",
    repo="https://github.com/JuliaHCI/SatelliteSpots.jl/blob/{commit}{path}#{line}",
    sitename="SatelliteSpots.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaHCI.github.io/SatelliteSpots.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaHCI/SatelliteSpots.jl",
    devbranch="main",
)
