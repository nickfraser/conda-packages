# AGENTS

## Scope

- This repo is a small conda overlay for packages that are missing from `conda-forge` or intentionally maintained locally.
- Current target is `linux-64` only. Publishing/uploading is out of scope here; local build and validation come first.

## Repo Shape

- Each package recipe lives in `recipes/<package>/`.
- The normal recipe shape is just `meta.yaml` plus `build.sh`; there is no repo-wide task runner, CI workflow, or extra automation to rely on.

## Build Workflow

- Use a dedicated conda build env with `conda-build` installed. The README uses `cb` as the example env name.
- Build from the repo root with `conda-build recipes/<package>`.
- Primary verification is the recipe's `test.commands` plus a manual smoke test after install when the package has runtime wiring.

## Install And Test Built Packages

- Install built artifacts from the local `conda-bld` directory as a channel, not by pointing `conda install` directly at a `.tar.bz2` file. This repo already hit dependency-resolution problems with direct archive installs.
- Preferred pattern:

```bash
conda create -n test-env \
  -c "file:///path/to/miniforge/envs/cb/conda-bld" \
  -c conda-forge \
  --override-channels \
  <package>
```

## Editing Conventions

- Keep recipes small and pragmatic. Prefer the minimal `meta.yaml`/`build.sh` needed to build and test correctly.
- `conda-forge` remains the primary dependency source; local recipes are overlays, not a replacement channel.
- If a requested package already exists on `conda-forge` and the user has not given a reason to package it locally anyway, stop and ask for confirmation before adding a local recipe.
- If packaging changes without an upstream version change, bump the recipe `build.number`.

## Package-Specific Gotchas

- `recipes/chawan/`: the package is intentionally runtime-focused. Keep `cha` plus the required `libexec/chawan` helper tree; omit `mancha` and man pages unless requirements change. Tests should cover runtime files, not just the binary.
- `recipes/git-credential-gopass/`: avoid tests that execute the helper's normal runtime flow; upstream behavior depends on a configured `gopass` setup. Use install/executable checks instead.
- `recipes/screen/`: the package intentionally skips upstream doc installation and does not ship `man` or `info` docs. It also avoids packaging setuid install bits; keep validation focused on non-setuid runtime behavior.
