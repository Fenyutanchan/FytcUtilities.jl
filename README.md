# FytcUtilities

[![CI](https://github.com/Fenyutanchan/FytcUtilities.jl/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Fenyutanchan/FytcUtilities.jl/actions/workflows/ci.yml)
[![doc:latest](https://img.shields.io/badge/doc-latest-blue)](https://fytc.ac/FytcUtilities.jl/)

Julia utilities for numerical workflows.

> **Note**: The former `PlotRegistries` module lives in the standalone package
> [FytcPlotRegistries.jl](https://github.com/Fenyutanchan/FytcPlotRegistries.jl).
> `FytcUtilities` depends on it and permanently re-exports its API, so
> `using FytcUtilities` keeps providing `PlotRegistry`, `plot_register!`, etc.

## Install

This package is registered in the personal registry
[FytcJuliaRegistries](https://github.com/Fenyutanchan/FytcJuliaRegistries),
which is also required to resolve the `FytcPlotRegistries` dependency:

```julia
pkg> registry add https://github.com/Fenyutanchan/FytcJuliaRegistries
pkg> add FytcUtilities
```

## Features

`FytcUtilities` is a growing collection of small, general-purpose utilities:

- `geomspace` — geometrically (log-)spaced sequences.
- Plot registries — re-exported from
  [FytcPlotRegistries.jl](https://github.com/Fenyutanchan/FytcPlotRegistries.jl)
  (`PlotRegistry`, `plot_register!`, `lookup_plot`, …).

See the [documentation](https://fytc.ac/FytcUtilities.jl/) for the full API.

## Development

Run the test suite:

```julia
julia --project=. -e 'using Pkg; Pkg.test()'
```

Build the documentation locally:

```julia
julia --project=docs docs/make.jl
```

## License

[MIT License](LICENSE) © 2026 Quan-feng WU <wuquanfeng@ihep.ac.cn>
