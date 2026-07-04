using Test
using FytcUtilities
using FytcPlotRegistries

# FytcUtilities permanently re-exports the FytcPlotRegistries API.
# These tests only verify that the re-export is complete and correct;
# the functionality itself is tested in FytcPlotRegistries.jl.

@testset "re-export of FytcPlotRegistries" begin
    # The submodule alias points at the upstream package.
    @test FytcUtilities.PlotRegistries === FytcPlotRegistries

    # Every public name is exported from FytcUtilities and refers to the
    # exact same object as in FytcPlotRegistries.
    for name ∈ (:PlotRegistry,
                :plot_register!, :plot_unregister!,
                :lookup_plot, :list_plots, :prune_plots!,
                Symbol("@plot_register"), Symbol("@plot_unregister"))
        @test name ∈ names(FytcUtilities)
        @test getproperty(FytcUtilities, name) === getproperty(FytcPlotRegistries, name)
    end
end
