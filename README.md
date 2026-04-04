# FytcUtilities

[![CI](https://github.com/Fenyutanchan/FytcUtilities.jl/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Fenyutanchan/FytcUtilities.jl/actions/workflows/ci.yml)
[![doc:latest](https://img.shields.io/badge/doc-latest-blue)](https://fytc.ac/FytcUtilities.jl/)

Julia utilities for numerical workflows and plot artifact tracking.

## Install

This package is **not registered** in the Julia General Registry. Install it directly from GitHub:

```julia
pkg> add https://github.com/Fenyutanchan/FytcUtilities.jl
```

## Quick Start

```julia
using FytcUtilities

xs = geomspace(1.0, 1000.0, 4)

reg = PlotRegistries.PlotRegistry("plots/plot_registry.toml")
PlotRegistries.plot_register!(reg, "fig1.pdf", @__FILE__; description="example")
```

## Documentation

Build locally:

```julia
julia --project=docs docs/make.jl
```

CI workflow: `.github/workflows/docs.yml`

## Test

```julia
julia --project=. -e 'using Pkg; Pkg.test()'
```

## License

MIT
