# SatelliteSpots.jl

[![PkgEval](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/S/SatelliteSpots.svg)](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/report.html)
[![Build Status](https://github.com/JuliaHCI/SatelliteSpots.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaHCI/SatelliteSpots.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/JuliaHCI/SatelliteSpots.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaHCI/SatelliteSpots.jl)
[![License](https://img.shields.io/github/license/JuliaHCI/SatelliteSpots.jl?color=yellow)](LICENSE)

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaHCI.github.io/SatelliteSpots.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaHCI.github.io/SatelliteSpots.jl/dev)

A package for fitting calibration speckles in high-contrast imaging data.

## Installation

To install this package, using [Pkg.jl](https://docs.julialang.org/en/v1/stdlib/Pkg/)

```julia
julia> ] add SatelliteSpots
```

## Usage

To load the package and its exported functions

```julia
julia> using SatelliteSpots
```

The common interface for fitting spots relies heavily on [PSFModels.jl](https://github.com/JuliaAstro/PSFModels.jl), so you'll want to install and load it as well.

```julia
julia> using PSFModels
```

from here, to fit spots in a frame and calculate useful statistics

```julia
result = SatelliteSpots.fit(image, gaussian; n=4, r=30, fwhm=3)
```

For more in-depth documentation and API reference, see the [documentation](https://JuliaHCI.github.io/SatelliteSpots.jl/dev)

## Contributing and Support

If you would like to contribute, feel free to open a [pull request](https://github.com/JuliaHCI/SatelliteSpots.jl/pulls). If you want to discuss something before contributing, head over to [discussions](https://github.com/JuliaHCI/SatelliteSpots.jl/discussions) and join or open a new topic. If you're having problems with something, please open an [issue](https://github.com/JuliaHCI/SatelliteSpots.jl/issues).
