# Conda Overlay Recipes

This repository contains custom conda recipes that augment `conda-forge` with packages that are missing there or that we want to maintain ourselves.

Current scope:

- target platform: `linux-64`
- focus: building and validating packages locally first
- publishing/indexing/uploading: handled separately later

## Layout

Each recipe lives under `recipes/<package>/`.

Examples:

- `recipes/ctop/`
- `recipes/git-credential-gopass/`
- `recipes/opencode/`
- `recipes/screen/`
- `recipes/tuxedo/`

Typical files:

- `meta.yaml`: package metadata, source, dependencies, tests
- `build.sh`: Linux build/install script

## Build Environment Setup

Install Miniforge first if you do not already have a conda distribution available:

- Miniforge releases and install instructions: <https://github.com/conda-forge/miniforge>

After Miniforge is installed, create a dedicated build environment and install `conda-build` there:

```bash
conda create -n cb -c conda-forge conda-build
conda activate cb
```

All build and installation commands below assume this build environment is active.

## Local Build Workflow

Build a recipe from the repository root with:

```bash
conda-build -c conda-forge recipes/<package>
```

Pass `-c conda-forge` explicitly when building. Some recipes need build dependencies such as `go`, and `conda-build` does not always inherit the channel configuration you used when creating the `cb` environment.

Examples:

```bash
conda-build -c conda-forge recipes/ctop
conda-build -c conda-forge recipes/git-credential-gopass
conda-build -c conda-forge recipes/opencode
conda-build -c conda-forge recipes/screen
conda-build -c conda-forge recipes/tuxedo
```

If a recipe ever needs to consume another package you already built locally, add `--use-local`:

```bash
conda-build --use-local -c conda-forge recipes/<package>
```

`conda-build` writes the resulting package to your local build cache, typically under a path like:

```text
$CONDA_PREFIX/envs/<build-env>/conda-bld/linux-64/
```

or, for a Miniforge-style install:

```text
~/miniforge3/envs/<build-env>/conda-bld/linux-64/
```

In this repository's current setup, built packages have been written under paths like:

```text
~/.local/miniforge3/envs/cb/conda-bld/linux-64/
```

## Installing Built Packages

Install built packages from the local `conda-bld` directory as a channel so that conda can resolve runtime dependencies correctly:

```bash
conda create -n test-env \
  -c "file://$CONDA_PREFIX/conda-bld" \
  -c conda-forge \
  --override-channels \
  screen
```

You can also install into an existing environment:

```bash
conda install -n my-env \
  -c "file://$CONDA_PREFIX/conda-bld" \
  -c conda-forge \
  --override-channels \
  screen
```

These examples assume the `cb` build environment is active, so `CONDA_PREFIX` points at that environment. If your build environment or Miniforge installation lives somewhere else, replace the channel path with the actual location of its `conda-bld` directory.

Avoid installing a built package by pointing `conda install` directly at the `.tar.bz2` artifact. Installing from the local channel is more reliable because it allows conda to solve and install the package's dependencies.

After installation, run a quick smoke test for the package you built when appropriate.

## Current Packages

- `ctop`: Top-like interface for container metrics
- `git-credential-gopass`: Git credential helper backed by `gopass`
- `opencode`: Open source AI coding agent; current package repackages the upstream `linux-x64-baseline` CLI binary for broader CPU compatibility on `linux-64`
- `chawan`: Text-mode web browser; current package includes `cha` and the required runtime helper tree, but omits `mancha` and man pages for now
- `screen`: GNU Screen terminal multiplexer; current package installs the runtime binary and encoding data, but omits man and info docs
- `tuxedo`: Fast, keyboard-driven terminal UI for `todo.txt`

## Notes

- `conda-forge` should remain the primary dependency source.
- These recipes are intended to be small and pragmatic.
- `opencode` is a deliberate exception to the usual source-build preference here: the current recipe repackages the upstream CLI binary, with conda binary relocation disabled to preserve the original ELF behavior.
- Runtime integration for some packages may still depend on tools outside conda. For example, `git-credential-gopass` still requires a working `gopass` setup.
- `screen` currently builds and passes detached-session smoke tests without packaging setuid installation bits.
- `screen` intentionally skips upstream doc installation, so `man screen` and `info screen` are not provided by this package.

## Future Work

- add `linux-aarch64` builds
- publish packages to a private/self-hosted channel
- upstream suitable recipes to `conda-forge`
