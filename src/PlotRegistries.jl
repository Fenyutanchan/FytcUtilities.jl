# Copyright (c) 2026 Quan-feng WU <wuquanfeng@ihep.ac.cn>
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

"""
    PlotRegistries

A lightweight plot registry backed by a TOML file.

Each entry records:
- `file`        — output filename (relative to the registry directory)
- `script`      — source script that generates the plot
- `description` — (optional) short description

## Usage

```julia
using FytcUtilities.PlotRegistries

# Create a registry in the plots/ directory
reg = PlotRegistries.PlotRegistry("plots/plot_registry.toml")

# Register a plot (call this right after `save(...)`)
PlotRegistries.plot_register!(reg, "fig1.pdf", @__FILE__; description="c_α and d_α vs T")

# Or use the convenience macro (auto-captures source file)
PlotRegistries.@plot_register reg "fig1.pdf" "c_α and d_α vs T"

# Query
PlotRegistries.lookup_plot(reg, "fig1.pdf")             # returns (file, script, description), or ("", "", "") if not found
PlotRegistries.list_plots(reg)                          # returns all entries
PlotRegistries.list_plots(reg; script="notebook.jl")    # filter by script

# Remove stale entries whose source scripts no longer exist on disk
PlotRegistries.prune_plots!(reg)
```
"""
module PlotRegistries

using TOML

export PlotRegistry,
       plot_register!, plot_unregister!,
       lookup_plot, list_plots, prune_plots!,
       @plot_register, @plot_unregister

"""
    PlotRegistry(path::AbstractString)

A handle to a `plot_registry.toml` file at `path`.
The file is created on first `plot_register!` if it does not exist.
"""
struct PlotRegistry
    path::String
    function PlotRegistry(path::AbstractString)
        if isfile(path)
            return new(realpath(path))
        elseif isdir(path)
            # If a directory is given, use "plot_registry.toml" inside it
            @warn "Given path is a directory; using `plot_registry.toml` inside it: $path"
            return new(joinpath(realpath(path), "plot_registry.toml"))
        elseif ispath(path)
            ArgumentError("Path exists but is not a file or directory: $path") |> throw
        else
            @warn "Registry file does not exist!"
            if endswith(path, ".toml")
                @warn "Will create new registry file at: $path"
                path_directory = dirname(path)
                isdir(path_directory) || mkpath(path_directory; mode=0o755) # Ensure parent directory exists
                write(path, "") # Create an empty file
                return PlotRegistry(path)
            else
                @warn "Given path does not end with .toml; treating it as a directory."
                mkpath(path; mode=0o755) # Create the directory
                return PlotRegistry(path)
            end
        end
    end
end

# ─── Internal helpers ───

function _normalize_registry(data::AbstractDict)::Dict{String, Dict{String, String}}
    normalized = Dict{String, Dict{String, String}}()

    for (key, entry) ∈ data
        key isa AbstractString || continue
        entry isa AbstractDict || continue
        haskey(entry, "file") && haskey(entry, "script") || continue

        file = entry["file"]
        script = entry["script"]
        file isa AbstractString || continue
        script isa AbstractString || continue

        normalized_entry = Dict{String, String}(
            "file" => String(file),
            "script" => String(script),
        )

        if haskey(entry, "description") && entry["description"] isa AbstractString
            description = String(entry["description"])
            isempty(description) || (normalized_entry["description"] = description)
        end

        normalized[String(key)] = normalized_entry
    end

    return normalized
end

function _read(reg::PlotRegistry)::Dict{String, Dict{String, String}}
    isfile(reg.path) || return Dict{String, Dict{String, String}}()

    parsed_raw = TOML.parsefile(reg.path)
    parsed = try
        convert(Dict{String, Dict{String, String}}, parsed_raw)
    catch
        parsed_raw
    end
    normalized = _normalize_registry(parsed)

    if parsed != normalized
        raw_keys = Set(String(k) for k in keys(parsed) if k isa AbstractString)
        normalized_keys = Set(keys(normalized))
        dropped_keys = collect(setdiff(raw_keys, normalized_keys))
        @warn "Registry file contained non-conformant entries and was normalized." path=reg.path dropped_keys=dropped_keys
        # Keep the registry TOML canonical and schema-conformant once loaded.
        open(reg.path, "w") do io
            TOML.print(io, normalized; sorted=true)
        end
    end

    return normalized
end

function _write(reg::PlotRegistry, data::Dict{String, Dict{String, String}})
    normalized = _normalize_registry(data)
    open(reg.path, "w") do io
        TOML.print(io, normalized; sorted=true)
    end
end

# ─── Public API ───

"""
    plot_register!(reg, file, script; description="")::Nothing

Register (or update) a plot entry. `file` is the output filename (basename only),
`script` is the source file path.
"""
function plot_register!(reg::PlotRegistry, file::AbstractString, script::AbstractString;
                   description::AbstractString="")
    data = _read(reg)
    file_path = relpath(realpath(file), dirname(reg.path))
    script_path = relpath(realpath(script), dirname(reg.path))
    entry = Dict{String, String}("file" => file_path, "script" => script_path)
    isempty(description) || (entry["description"] = description)

    data[basename(file)] = entry
    _write(reg, data)

    return nothing
end

"""
    plot_unregister!(reg, file)::Nothing

Unregister a plot entry by filename. Does nothing if the entry does not exist.
"""
function plot_unregister!(reg::PlotRegistry, file::AbstractString)
    data = _read(reg)
    key = basename(file)
    if haskey(data, key)
        delete!(data, key)
        _write(reg, data)
    end
    return nothing
end

"""
    @plot_register reg filename description=""

Convenience macro that auto-captures the source file via `@__FILE__`.
"""
macro plot_register(reg, file, desc="")
    quote
        plot_register!($(esc(reg)), $(esc(file)), @__FILE__; description=$(esc(desc)))
    end
end

"""
    @plot_unregister reg filename

Convenience macro that auto-captures the source file via `@__FILE__`.
"""
macro plot_unregister(reg, file)
    quote
        plot_unregister!($(esc(reg)), $(esc(file)))
    end
end

"""
    lookup_plot(reg, file)::@NamedTuple{:file, :script, :description}

Look up an entry by filename.
Returns `(file=..., script=..., description=...)` when found.
If the entry does not exist, returns `(file="", script="", description="")`.
"""
function lookup_plot(reg::PlotRegistry, file::AbstractString)::@NamedTuple{file::String, script::String, description::String}
    data = _read(reg)
    key = basename(file)
    haskey(data, key) || return (file="", script="", description="")

    e = data[key]
    return (file=e["file"], script=e["script"], description=get(e, "description", ""))
end

"""
    list_plots(reg; script=nothing)::Vector{NamedTuple}

List all entries, optionally filtered by source script (substring match).
"""
function list_plots(reg::PlotRegistry; script::Union{AbstractString, Nothing}=nothing)
    data = _read(reg)
    entries = [
        (file=e["file"], script=e["script"], description=get(e, "description", ""))
        for e ∈ values(data)
    ]
    isnothing(script) || filter!(e -> occursin(script, e.script), entries)
    sort!(entries; by=e->e.file)
    return entries
end

"""
    prune_plots!(reg)::Vector{String}

Remove entries whose source scripts no longer exist on disk.
When pruning happens, the updated registry is written back to disk.
Returns suggested plot file paths (absolute paths)
that can be manually removed.
"""
function prune_plots!(reg::PlotRegistry)
    data = _read(reg)
    dir = dirname(reg.path)
    suggested_files_to_delete = String[]
    changed = false

    for (key, entry) ∈ collect(data)
        scriptpath = joinpath(dir, entry["script"])
        if !isfile(scriptpath)
            delete!(data, key)
            file_to_delete = joinpath(dir, entry["file"]) |> normpath
            isfile(file_to_delete) && push!(suggested_files_to_delete, file_to_delete)
            changed = true
        end
    end

    changed && _write(reg, data)

    isempty(suggested_files_to_delete) ||
        @info "Pruned registry entries whose scripts are missing. Consider deleting these orphaned plot files:" suggested_files_to_delete

    return suggested_files_to_delete
end

end # module

using .PlotRegistries

export PlotRegistry,
       plot_register!, plot_unregister!,
       lookup_plot, list_plots, prune_plots!,
       @plot_register, @plot_unregister
