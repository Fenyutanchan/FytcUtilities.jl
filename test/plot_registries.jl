using Test
using FytcUtilities
using Logging
using TOML

@testset "PlotRegistry creation and initialization" begin
    mktempdir() do tmpdir
        # Test creating registry with non-existent .toml path
        registry_path = joinpath(tmpdir, "plots", "plot_registry.toml")
        @test_logs (:warn, "Registry file does not exist!") (:warn, "Will create new registry file at: $registry_path") begin
            reg = FytcUtilities.PlotRegistry(registry_path)
            @test isfile(registry_path)
            @test reg.path == realpath(registry_path)
        end

        # Test creating registry with directory path (file not created until plot_register!)
        dir_path = joinpath(tmpdir, "plots2")
        mkpath(dir_path)
        @test_logs (:warn, "Given path is a directory; using `plot_registry.toml` inside it: $dir_path") begin
            reg = FytcUtilities.PlotRegistry(dir_path)
            expected_path = joinpath(realpath(dir_path), "plot_registry.toml")
            @test reg.path == expected_path
            # File is NOT created yet, it will be created on first plot_register!
            @test !isfile(expected_path)
        end
    end
end

@testset "plot_register! and plot_unregister!" begin
    mktempdir() do tmpdir
        registry_path = joinpath(tmpdir, "plot_registry.toml")
        reg = FytcUtilities.PlotRegistry(registry_path)
        
        # Create dummy files
        script_file = joinpath(tmpdir, "make_plot.jl")
        plot_file = joinpath(tmpdir, "fig1.pdf")
        write(script_file, "# dummy script")
        write(plot_file, "dummy plot")
        
        # Test registration (file must exist for realpath to work)
        FytcUtilities.plot_register!(reg, plot_file, script_file; description="Test plot")
        entries = FytcUtilities.list_plots(reg)
        @test length(entries) == 1
        @test entries[1].file == "fig1.pdf"
        @test entries[1].script == "make_plot.jl"
        @test entries[1].description == "Test plot"
        
        # Test update existing entry
        FytcUtilities.plot_register!(reg, plot_file, script_file; description="Updated plot")
        entries = FytcUtilities.list_plots(reg)
        @test length(entries) == 1
        @test entries[1].description == "Updated plot"
        
        # Test unregistration
        FytcUtilities.plot_unregister!(reg, "fig1.pdf")
        entries = FytcUtilities.list_plots(reg)
        @test length(entries) == 0
        
        # Test unregistering non-existent entry (should not error)
        FytcUtilities.plot_unregister!(reg, "nonexistent.pdf")
    end
end

@testset "lookup_plot" begin
    mktempdir() do tmpdir
        registry_path = joinpath(tmpdir, "plot_registry.toml")
        reg = FytcUtilities.PlotRegistry(registry_path)
        
        script_file = joinpath(tmpdir, "make_plot.jl")
        plot_file = joinpath(tmpdir, "fig1.pdf")
        write(script_file, "# dummy script")
        write(plot_file, "dummy plot")
        
        FytcUtilities.plot_register!(reg, plot_file, script_file; description="Test plot")
        
        # Test lookup existing
        result = FytcUtilities.lookup_plot(reg, "fig1.pdf")
        @test result.file == "fig1.pdf"
        @test result.script == "make_plot.jl"
        @test result.description == "Test plot"
        
        # Test lookup non-existent
        result = FytcUtilities.lookup_plot(reg, "nonexistent.pdf")
        @test result.file == ""
        @test result.script == ""
        @test result.description == ""
    end
end

@testset "list_plots with filtering" begin
    mktempdir() do tmpdir
        registry_path = joinpath(tmpdir, "plot_registry.toml")
        reg = FytcUtilities.PlotRegistry(registry_path)
        
        script1 = joinpath(tmpdir, "script1.jl")
        script2 = joinpath(tmpdir, "script2.jl")
        plot1 = joinpath(tmpdir, "fig1.pdf")
        plot2 = joinpath(tmpdir, "fig2.pdf")
        plot3 = joinpath(tmpdir, "fig3.pdf")
        write(script1, "# script 1")
        write(script2, "# script 2")
        write(plot1, "plot 1")
        write(plot2, "plot 2")
        write(plot3, "plot 3")
        
        FytcUtilities.plot_register!(reg, plot1, script1)
        FytcUtilities.plot_register!(reg, plot2, script2)
        FytcUtilities.plot_register!(reg, plot3, script1)
        
        # Test list all
        entries = FytcUtilities.list_plots(reg)
        @test length(entries) == 3
        
        # Test filter by script
        entries = FytcUtilities.list_plots(reg; script="script1.jl")
        @test length(entries) == 2
        @test all(e -> occursin("script1.jl", e.script), entries)
        
        # Test filter with no matches
        entries = FytcUtilities.list_plots(reg; script="nonexistent.jl")
        @test length(entries) == 0
    end
end

@testset "prune_plots!" begin
    mktempdir() do tmpdir
        registry_path = joinpath(tmpdir, "plot_registry.toml")
        reg = FytcUtilities.PlotRegistry(registry_path)
        
        script1 = joinpath(tmpdir, "script1.jl")
        script2 = joinpath(tmpdir, "script2.jl")
        plot1 = joinpath(tmpdir, "fig1.pdf")
        plot2 = joinpath(tmpdir, "fig2.pdf")
        
        write(script1, "# script 1")
        write(script2, "# script 2")
        write(plot1, "plot 1")
        write(plot2, "plot 2")
        
        FytcUtilities.plot_register!(reg, plot1, script1)
        FytcUtilities.plot_register!(reg, plot2, script2)
        
        # Remove script2 to simulate stale entry
        rm(script2)
        
        # Prune should remove fig2 entry
        suggested_files = FytcUtilities.prune_plots!(reg)
        
        entries = FytcUtilities.list_plots(reg)
        @test length(entries) == 1
        @test entries[1].file == "fig1.pdf"
        
        @test length(suggested_files) == 1
        @test suggested_files[1] == realpath(plot2)
        
        # Test prune when both script AND plot file are already deleted
        plot3 = joinpath(tmpdir, "fig3.pdf")
        script3 = joinpath(tmpdir, "script3.jl")
        write(script3, "# script 3")
        write(plot3, "plot 3")
        FytcUtilities.plot_register!(reg, plot3, script3)
        
        # Remove both script and plot file
        rm(script3)
        rm(plot3)
        
        suggested_files = FytcUtilities.prune_plots!(reg)
        entries = FytcUtilities.list_plots(reg)
        @test length(entries) == 1
        @test length(suggested_files) == 0  # No suggestion since plot file is already gone
    end
end

@testset "plot_register! with relative paths" begin
    mktempdir() do tmpdir
        registry_path = joinpath(tmpdir, "registry", "plot_registry.toml")
        reg = FytcUtilities.PlotRegistry(registry_path)
        
        # Create files relative to registry
        script_file = joinpath(tmpdir, "scripts", "make_plot.jl")
        plot_file = joinpath(tmpdir, "plots", "fig1.pdf")
        mkpath(dirname(script_file))
        mkpath(dirname(plot_file))
        write(script_file, "# script")
        write(plot_file, "plot")
        
        FytcUtilities.plot_register!(reg, plot_file, script_file)
        
        entries = FytcUtilities.list_plots(reg)
        @test length(entries) == 1
        # Paths should be relative to registry directory
        @test !isabspath(entries[1].file)
        @test !isabspath(entries[1].script)
    end
end

@testset "plot registry normalization keeps conformant data" begin
    mktempdir() do tmpdir
        registry_path = joinpath(tmpdir, "plot_registry.toml")
        write(registry_path, """
[\"keep.pdf\"]
file = \"keep.pdf\"
script = \"make_plot.jl\"
""")

        reg = FytcUtilities.PlotRegistry(registry_path)
        entries = @test_logs min_level=Logging.Warn FytcUtilities.list_plots(reg)

        @test length(entries) == 1
        @test entries[1].file == "keep.pdf"
        @test entries[1].script == "make_plot.jl"
        @test entries[1].description == ""

        reparsed = TOML.parsefile(registry_path)
        @test sort!(collect(keys(reparsed))) == ["keep.pdf"]
        @test reparsed["keep.pdf"]["file"] == "keep.pdf"
        @test reparsed["keep.pdf"]["script"] == "make_plot.jl"
    end
end

@testset "plot registry normalization drops non-conformant entries" begin
    mktempdir() do tmpdir
        registry_path = joinpath(tmpdir, "plot_registry.toml")
        write(registry_path, """
[\"keep.pdf\"]
file = \"keep.pdf\"
script = \"make_plot.jl\"

[\"drop_missing_script\"]
file = \"missing_script.pdf\"

[\"drop_wrong_type\"]
file = 42
script = \"bad.jl\"
""")

        reg = FytcUtilities.PlotRegistry(registry_path)
    logger = Test.TestLogger(min_level=Logging.Warn)
    entries = with_logger(logger) do
        FytcUtilities.list_plots(reg)
    end

    @test length(logger.logs) == 1
    warn_record = logger.logs[1]
    @test warn_record.level == Logging.Warn
    @test occursin("non-conformant entries", string(warn_record.message))
    warn_kwargs = Dict(warn_record.kwargs)
    @test haskey(warn_kwargs, :dropped_keys)
    @test sort!(warn_kwargs[:dropped_keys]) == ["drop_missing_script", "drop_wrong_type"]

        @test length(entries) == 1
        @test entries[1].file == "keep.pdf"
        @test entries[1].script == "make_plot.jl"

        reparsed = TOML.parsefile(registry_path)
        @test sort!(collect(keys(reparsed))) == ["keep.pdf"]
    end
end

@testset "@plot_register macro captures caller file" begin
    mktempdir() do tmpdir
        registry_path = joinpath(tmpdir, "plot_registry.toml")
        reg = FytcUtilities.PlotRegistry(registry_path)

        plot_file = joinpath(tmpdir, "fig_macro.pdf")
        write(plot_file, "dummy plot")

        # Call the macro directly here; __source__.file should resolve to this test file
        FytcUtilities.@plot_register reg plot_file "from macro"

        entries = FytcUtilities.list_plots(reg)
        @test length(entries) == 1
        @test entries[1].file == "fig_macro.pdf"
        @test entries[1].description == "from macro"
        # The script field must reference this test file, NOT PlotRegistries.jl
        @test occursin("plot_registries.jl", entries[1].script)
        @test !occursin("PlotRegistries.jl", entries[1].script)
    end
end
