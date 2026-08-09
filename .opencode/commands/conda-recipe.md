---
description: Create, build, and validate a local Conda overlay recipe
agent: build
---

Create and validate a new `linux-64` Conda overlay recipe.

Arguments:

- Package name: `$1`
- Optional source URL: `$2`

Perform the work, do not only propose a plan. Follow this workflow exactly.

1. Read `AGENTS.md`, `README.md`, `conda_build_config.yaml`, and related recipes before editing. Require a package name, normalize it to the Conda package-name convention, and reject an existing `recipes/<package>/` directory rather than overwriting it.

2. Search conda-forge exactly before creating files:

   ```bash
   conda search --override-channels -c conda-forge --skip-flexible-search --json <package>
   ```

   Treat only `PackagesNotFoundInChannelsError` as an absent package. If the package exists in `linux-64` or `noarch`, show the available result and ask the user to confirm that they intentionally want a local overlay. Do not create a recipe unless they confirm. Stop on any other query failure.

3. If a source URL was supplied, inspect that source. Otherwise, search for an official upstream release source, prefer a versioned source archive, and present the project, version, and archive URL to the user for confirmation. Do not create files until they confirm the discovered source. Stop when a trustworthy source, version, license, or build layout cannot be determined.

4. Download the approved source to a temporary location, calculate its SHA-256, inspect its build files, and select the smallest matching source-build approach:

   - Cargo: use `{{ stdlib('c') }}`, `{{ compiler('c') }}`, and `{{ compiler('rust') }}`. Respect `CARGO_BUILD_TARGET` when installing artifacts.
   - Go: prefer a static `CGO_ENABLED=0` build when the project supports it.
   - Autotools: use the C stdlib and compiler, `make`, `./configure --prefix="${PREFIX}"`, `make`, and `make install`.
   - Make: use the C stdlib and compiler plus `make`; only use its install target when the source provides one.

   For another layout, stop and explain what is missing instead of guessing dependencies, executable names, or install behavior.

5. Create only `recipes/<package>/meta.yaml` and `recipes/<package>/build.sh`. Follow nearby recipe style: source URL and checksum, `build.number: 0` for a new upstream version, concise `about` metadata, and non-interactive `test.commands` that verify the installed runtime. Prefer source builds; use binary repackaging only when rebuilding is disproportionate and record the inspected runtime requirements.

6. Preserve the repository's GLIBC policy. Dynamically linked native builds must use `{{ stdlib('c') }}` so the shared GLIBC 2.17 sysroot produces the correct `__glibc` metadata. Inspect packaged ELF GLIBC symbols after a build. Prebuilt binaries require an explicit inspected `__glibc` `run_constrained` entry. Do not use `CONDA_OVERRIDE_GLIBC` or attempt to install a replacement GLIBC runtime.

7. Build through the existing isolated workflow:

   ```bash
   ./utils/build-recipe.sh <package>
   ```

   Resolve ordinary source-build issues pragmatically, but keep the recipe minimal. The helper's recipe tests are required. When the package has runtime wiring, install the built artifact from the local `conda-bld` channel into a clean test environment and run an appropriate manual smoke test. Do not install the artifact directly by file path.

8. Finish with the selected source, recipe files created, build and test outcome, artifact location, detected GLIBC requirement when applicable, and any remaining manual limitation. If a build fails, retain the generated recipe and builder environment for diagnosis and report the blocker clearly.
