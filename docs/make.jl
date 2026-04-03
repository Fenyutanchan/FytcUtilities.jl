using Documenter
using FytcUtilities

const DOCS_ROOT = normpath(joinpath(@__DIR__, ".."))
const ON_CI = get(ENV, "CI", "false") == "true"

makedocs(
    sitename = "FytcUtilities.jl",
    modules = [FytcUtilities, FytcUtilities.PlotRegistries],
    root = DOCS_ROOT,
    source = "docs/src",
    build = "docs/build",
    format = Documenter.HTML(
        prettyurls = ON_CI,
    ),
)

if ON_CI
    deploydocs(
        repo = "github.com/Fenyutanchan/FytcUtilities.jl.git",
    )
end
