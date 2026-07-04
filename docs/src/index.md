# FytcUtilities

`FytcUtilities` provides utilities for numerical workflows.

## Exported APIs

### `geomspace`

```@docs
FytcUtilities.geomspace
```

## Plot registries

The former `PlotRegistries` submodule lives in the standalone package
[FytcPlotRegistries.jl](https://github.com/Fenyutanchan/FytcPlotRegistries.jl).

`FytcUtilities` depends on `FytcPlotRegistries` and permanently re-exports its
API (`PlotRegistry`, `plot_register!`, `plot_unregister!`, `lookup_plot`,
`list_plots`, `prune_plots!`, `@plot_register`, `@plot_unregister`); the alias
`FytcUtilities.PlotRegistries` also works. See the FytcPlotRegistries.jl
documentation for the full API reference.
