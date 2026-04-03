using Logging
using TOML

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
