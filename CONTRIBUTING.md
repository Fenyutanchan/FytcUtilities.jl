# Contributing to FytcUtilities

Thanks for your interest in improving `FytcUtilities`! This document
describes the local development workflow and the commit message
convention used in this repository.

`FytcUtilities` is a small grab-bag of general-purpose Julia utilities.
It also depends on
[FytcPlotRegistries.jl](https://github.com/Fenyutanchan/FytcPlotRegistries)
and permanently re-exports its API, so some contributions are as simple
as keeping that re-export in sync. The contribution process is
intentionally lightweight.

## Development Setup

1. Install a recent Julia release (CI tracks the latest stable `1.x`).
2. Add the personal registry that hosts the `FytcPlotRegistries`
   dependency (needed once per Julia depot):

   ```julia
   pkg> registry add https://github.com/Fenyutanchan/FytcJuliaRegistries
   ```

3. Clone the repository and instantiate the project environment:

   ```julia
   pkg> activate .
   pkg> instantiate
   ```

   Equivalently, from the shell:

   ```bash
   julia --project=. -e 'using Pkg; Pkg.instantiate()'
   ```

## Running Tests

Run the full test suite before opening a pull request:

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

Tests live under `test/`, with `test/runtests.jl` including the individual
test files. CI runs the same suite on Ubuntu and macOS against the latest
stable Julia release.

## Building Documentation

Documentation is generated with `Documenter.jl`. Build it locally with:

```bash
julia --project=docs -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'
julia --project=docs docs/make.jl
```

The rendered site is written to `docs/build/`. Docstrings are the source
of truth for the API reference, so update them alongside code changes.

## Code Style

- Follow standard Julia conventions: modules and types in `PascalCase`,
  functions and variables in `snake_case`, and mutating functions end
  with `!`.
- Keep the exported API and the docstrings in `src/` in sync.
- Prefer small, focused functions, and keep dependencies minimal. The
  main intentional dependency is `FytcPlotRegistries`, whose API is
  re-exported from `src/FytcUtilities.jl`; when its exported names
  change, update that re-export list to match.
- Add or update tests under `test/` for every behavioural change.

## Release Process

`FytcUtilities` is published through the personal registry
[FytcJuliaRegistries](https://github.com/Fenyutanchan/FytcJuliaRegistries).
To cut a release:

1. Bump `version` in `Project.toml` following semantic versioning.
2. Update `[compat]` bounds whenever dependencies change.
3. Make sure the test suite and the documentation build pass on `main`.
4. Register the new version with `LocalRegistry.jl`, following the
   FytcJuliaRegistries contribution guidelines.

## Commit Message Convention

### Format

```
<scope>(<target>): <subject>

<body>

<footer>
```

- All lines must not exceed 72 characters.
- All commit messages are written in English.

### Subject

- Must not exceed 50 characters.
- Use imperative mood (e.g., `add`, not `added` / `adding`).
- Do not end with a period.
- Start with a lowercase letter unless the first word is a proper noun.

### Scope and Target

The scope identifies the dimension of the repository affected by the change.

| Scope | Meaning | Target example |
|-------|---------|----------------|
| `src` | Core library code | `geomspace`, `plot-registry` |
| `test` | Test suite | `runtests`, `geomspace` |
| `docs` | Documentation and docstrings | `index`, `make`, `api` |
| `ci` | GitHub Actions workflows | `ci`, `docs`, `setup` |
| `deps` | Dependencies and `[compat]` bounds | `FytcPlotRegistries`, `compat` |
| `release` | Version bump and registry publication | `v0.2.0` |
| `repo` | Repository housekeeping | `readme`, `gitignore`, `license`, `contributing` |

- `target` is the affected module, function, file, or component, without
  path prefix or file extension.
- When a commit affects multiple scopes equally, join them with `&` and
  use a single `target` that identifies the primary component: e.g.,
  `src&test(geomspace)` indicates a code change (`src`) that also
  directly updates its tests (`test`). Use this form only when both
  scopes are genuinely primary — do not use `&` for incidental side
  effects (e.g., a `src` change that happens to touch a docstring is
  `src(...)`, not `src&docs(...)`).
- For the `release` scope, `target` is the new version tag rather than a
  component name.

### Body

- Separate from subject with one blank line.
- Use imperative mood.
- Explain **why** the change was made, not **what** was changed (the subject already covers what).
- Each line must not exceed 72 characters.
- Use unordered lists (`-`) to enumerate specific changes.

### Footer

- AI-assisted commits **must** include an `Assisted-by` trailer (see AI Attribution section).
- Purely human commits require no footer trailer.
- The `Co-authored-by` trailer is **prohibited** for AI attribution; use `Assisted-by` exclusively.

### Subject Verbs

| Scenario | Recommended verbs | Example |
|----------|-------------------|---------|
| New feature | `add`, `implement`, `introduce` | `src(geomspace): add geometric-spacing generator` |
| Remove code or file | `remove`, `delete` | `src(plot-registry): remove bundled submodule` |
| Bug fix | `fix`, `correct` | `src(geomspace): fix zero-endpoint handling` |
| Update behaviour | `update`, `revise`, `refine` | `src(geomspace): refine per-point ratio` |
| Tests | `add`, `cover`, `extend` | `test(geomspace): cover non-finite inputs` |
| Documentation | `document`, `clarify` | `docs(index): clarify re-export note` |
| Refactor or rename | `refactor`, `rename`, `reorganize` | `src(plot-registry): re-export FytcPlotRegistries` |
| Release | `bump`, `release` | `release(v0.2.0): bump minor for package split` |
| CI or tooling | `add`, `update`, `harden` | `ci(setup): reuse composite action` |

### AI Attribution

Based on the [Linux Kernel AI Coding Assistants](https://docs.kernel.org/process/coding-assistants.html) guidelines.

#### Format

```
Assisted-by: AGENT_NAME:MODEL_NAME
```

#### Rules

- AI tools **must not** add `Signed-off-by` tags; only humans can legally certify the Developer Certificate of Origin.
- The human committer is responsible for reviewing all AI-generated content and taking full responsibility for the contribution.
- When multiple AI tools assisted, use one `Assisted-by` line per tool.
- The `Co-authored-by` trailer is **prohibited** for AI attribution.

#### Canonical Agent Names

`AGENT_NAME` must exactly match one of the following entries:

| AGENT_NAME | Description |
|------------|-------------|
| `ClaudeCode` | Anthropic Claude |
| `QwenCode` | Alibaba Qwen Code |
| `GitHub-Copilot` | GitHub Copilot |
| `OpenCode` | OpenCode CLI |
| `Codex` | OpenAI Codex |

To add a new agent, append a row to this table in `CONTRIBUTING.md`.

#### Canonical Model Names

`MODEL_NAME` should be lowercase and may include version numbers or descriptors to specify the exact model used, e.g., `gemini-3.1-pro-preview`, `glm-5.1`, `claude-opus-4.6`.

#### Examples

```
src(geomspace): validate inputs with ArgumentError

- @assert is meant for internal invariants and may be disabled
  under optimization, so it must not guard user-facing input
- Zero and non-finite endpoints previously slipped through and
  produced NaNs instead of a clear error

Assisted-by: ClaudeCode:claude-opus-4.6
```

```
docs(index): document the FytcPlotRegistries re-export

- Readers did not know the plot-registry API is provided via a
  permanent re-export rather than a bundled submodule
- The reference must point at the upstream package so the split
  is discoverable

Assisted-by: GitHub-Copilot:claude-opus-4.8
```

```
src&test(geomspace): reject zero and non-finite endpoints

- These degenerate inputs silently produced NaNs, so they must
  raise a clear ArgumentError at the boundary instead
- The validation needs regression coverage so future changes
  keep rejecting the same cases

Assisted-by: Codex:gpt-5.5
```
