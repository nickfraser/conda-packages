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

Typical files:

- `meta.yaml`: package metadata, source, dependencies, tests
- `build.sh`: Linux build/install script

## Local Build Workflow

Build a recipe with `conda-build` from the repository root:

```bash
conda-build recipes/ctop
conda-build recipes/git-credential-gopass
```

Built packages are written to your local conda build cache, typically under a path like:

```text
$CONDA_PREFIX/envs/<build-env>/conda-bld/linux-64/
```

or, for a Miniforge-style install:

```text
~/miniforge3/envs/<build-env>/conda-bld/linux-64/
```

## Current Packages

- `ctop`: Top-like interface for container metrics
- `git-credential-gopass`: Git credential helper backed by `gopass`

## Notes

- `conda-forge` should remain the primary dependency source.
- These recipes are intended to be small and pragmatic.
- Runtime integration for some packages may still depend on tools outside conda. For example, `git-credential-gopass` still requires a working `gopass` setup.

## Future Work

- add `linux-aarch64` builds
- publish packages to a private/self-hosted channel
- upstream suitable recipes to `conda-forge`
