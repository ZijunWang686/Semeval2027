#!/usr/bin/env bash
set -euo pipefail

max_file_size=$((50 * 1024 * 1024))
commit_message="${1:-Update code}"

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    printf 'Error: this directory is not inside a Git repository.\n' >&2
    printf 'Initialize Git and configure a GitHub remote first; see README.md.\n' >&2
    exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
    printf 'Error: no "origin" remote is configured.\n' >&2
    printf 'Add your GitHub repository with: git remote add origin <GitHub URL>\n' >&2
    exit 1
fi

is_excluded_path() {
    local path="${1,,}"
    local component
    local extension="${path##*.}"

    IFS='/' read -r -a components <<< "$path"
    for component in "${components[@]}"; do
        case "$component" in
            model|models|checkpoint|checkpoints|weights)
                return 0
                ;;
        esac
    done

    case "$extension" in
        safetensors|gguf|ggml|bin|pt|pth|ckpt|onnx|engine|tflite|h5|hdf5)
            return 0
            ;;
    esac
    return 1
}

skipped=0
while IFS= read -r -d '' path; do
    if is_excluded_path "$path"; then
        printf 'Skipping model artifact: %s\n' "$path"
        ((skipped += 1))
        continue
    fi

    if [[ -f "$path" ]]; then
        size=$(stat -c '%s' -- "$path")
        if (( size > max_file_size )); then
            printf 'Skipping file over 50 MiB: %s\n' "$path"
            ((skipped += 1))
            continue
        fi
    fi

    git add -A -- "$path"
done < <(git ls-files --cached --others --exclude-standard -z)

# Do not commit model files or oversized files that were staged before this script ran.
while IFS= read -r -d '' path; do
    if is_excluded_path "$path"; then
        printf 'Error: an excluded model artifact is already staged: %s\n' "$path" >&2
        printf 'Unstage it before uploading; no commit was created.\n' >&2
        exit 1
    fi

    index_entry=$(git ls-files -s -- "$path")
    object_id=$(awk 'NR == 1 { print $2 }' <<< "$index_entry")
    if [[ -n "$object_id" ]]; then
        size=$(git cat-file -s "$object_id")
        if (( size > max_file_size )); then
            printf 'Error: an oversized file is already staged: %s\n' "$path" >&2
            printf 'Unstage it before uploading; no commit was created.\n' >&2
            exit 1
        fi
    fi
done < <(git diff --cached --name-only -z --diff-filter=ACMRT)

if git diff --cached --quiet; then
    printf 'No code changes to upload.\n'
    exit 0
fi

git diff --cached --check
git commit -m "$commit_message"
git push -u origin HEAD

if (( skipped > 0 )); then
    printf 'Upload complete. Skipped %d model or oversized file(s).\n' "$skipped"
else
    printf 'Upload complete.\n'
fi
