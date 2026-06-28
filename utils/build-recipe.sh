#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./utils/build-recipe.sh <recipe> [--use-local] [--delete-env]

Build a recipe in a dedicated per-recipe conda build environment.

Examples:
  ./utils/build-recipe.sh herdr
  ./utils/build-recipe.sh recipes/herdr --use-local
  ./utils/build-recipe.sh herdr --delete-env

Options:
  --use-local    Pass --use-local to conda-build
  --delete-env   Remove the per-recipe build env after a successful build
  -h, --help     Show this help text
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${REPO_ROOT}/build"

recipe_arg=""
use_local=0
delete_env=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --use-local)
      use_local=1
      ;;
    --delete-env)
      delete_env=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      printf 'error: unknown option: %s\n\n' "$1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [[ -n "${recipe_arg}" ]]; then
        printf 'error: only one recipe may be specified\n\n' >&2
        usage >&2
        exit 1
      fi
      recipe_arg="$1"
      ;;
  esac
  shift
done

if [[ -z "${recipe_arg}" ]]; then
  printf 'error: recipe is required\n\n' >&2
  usage >&2
  exit 1
fi

recipe_name="${recipe_arg##*/}"
recipe_name="${recipe_name%/}"
recipe_dir="${REPO_ROOT}/recipes/${recipe_name}"

if [[ ! -d "${recipe_dir}" ]]; then
  printf 'error: recipe directory not found: %s\n' "${recipe_dir}" >&2
  exit 1
fi

env_name="cb-${recipe_name}"
mkdir -p "${OUTPUT_DIR}"

if ! conda run -n "${env_name}" python --version >/dev/null 2>&1; then
  printf 'Creating builder environment: %s\n' "${env_name}"
  conda create -y -n "${env_name}" -c conda-forge \
    python \
    conda \
    conda-build \
    conda-libmamba-solver
fi

build_cmd=(
  conda-build
  --override-channels
  -c conda-forge
  --output-folder "${OUTPUT_DIR}"
)

if (( use_local )); then
  build_cmd+=(--use-local)
fi

build_cmd+=("${recipe_dir}")

printf 'Using builder environment: %s\n' "${env_name}"
printf 'Building recipe: %s\n' "${recipe_dir}"

if conda run -n "${env_name}" "${build_cmd[@]}"; then
  printf 'Build artifacts written under: %s\n' "${OUTPUT_DIR}"
  if (( delete_env )); then
    printf 'Removing builder environment: %s\n' "${env_name}"
    conda env remove -y -n "${env_name}"
  fi
else
  printf 'Build failed; keeping builder environment: %s\n' "${env_name}" >&2
  exit 1
fi
