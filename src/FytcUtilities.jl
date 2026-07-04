# Copyright (c) 2026 Quan-feng WU <wuquanfeng@ihep.ac.cn>
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

module FytcUtilities

using FytcPlotRegistries

include("geomspace.jl")

# ─── Re-export of FytcPlotRegistries ───
# The former `PlotRegistries` submodule lives in the standalone package
# FytcPlotRegistries.jl. FytcUtilities permanently re-exports its API, and
# the alias below keeps `FytcUtilities.PlotRegistries.*` usages working.
const PlotRegistries = FytcPlotRegistries

export PlotRegistry,
       plot_register!, plot_unregister!,
       lookup_plot, list_plots, prune_plots!,
       @plot_register, @plot_unregister

end # module FytcUtilities
