#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${HOME}/dotfiles"
LOCAL_BIN_DIR="${HOME}/.local/bin"

DRY_RUN=false
FORCE=false

SYMLINK_ITEMS=(
  ".aliases"
  ".bash_prompt"
  ".bashrc"
  ".curlrc"
  ".fonts"
  ".functions"
  ".wgetrc"
)

COPY_ITEMS=(
  ".exports"
  ".extra"
  ".path"
  ".gitconfig"
)

log() {
  printf '[bootstrap] %s\n' "$1"
}

warn() {
  printf '[bootstrap][warn] %s\n' "$1" >&2
}

run() {
  if $DRY_RUN; then
    printf '[dry-run] '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [--dry-run] [--force]

Options:
  --dry-run   Show what would happen without making changes
  --force     Replace existing files/symlinks/directories (backing them up first)
  -h, --help  Show this help
EOF
}

parse_args() {
  while (($#)); do
    case "$1" in
      --dry-run) DRY_RUN=true ;;
      --force)   FORCE=true ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        warn "Unknown argument: $1"
        usage
        exit 1
        ;;
    esac
    shift
  done
}

ensure_exists() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    warn "Source does not exist: $path"
    return 1
  fi
  return 0
}

target_exists() {
  local target="$1"
  [[ -e "$target" || -L "$target" ]]
}

backup_target() {
  local target="$1"
  local backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
  log "Backing up existing target: $target -> $backup"
  run mv "$target" "$backup"
}

create_symlink() {
  local name="$1"
  local source="${DOTFILES_DIR}/${name}"
  local target="${HOME}/${name}"

  ensure_exists "$source" || return 0

  if [[ -L "$target" ]]; then
    local current_target
    current_target="$(readlink "$target" || true)"
    if [[ "$current_target" == "$source" ]]; then
      log "Symlink already correct: $target -> $source"
      return 0
    fi
  fi

  if target_exists "$target"; then
    if ! $FORCE; then
      log "Exists, skipping: $target"
      return 0
    fi
    backup_target "$target"
  fi

  log "Symlinking: $target -> $source"
  run ln -s "$source" "$target"
}

copy_item() {
  local name="$1"
  local source="${DOTFILES_DIR}/${name}"
  local target="${HOME}/${name}"

  ensure_exists "$source" || return 0

  if target_exists "$target"; then
    if ! $FORCE; then
      log "Exists, skipping: $target"
      return 0
    fi
    backup_target "$target"
  fi

  log "Copying: $source -> $target"
  run cp -a "$source" "$target"
}

main() {
  parse_args "$@"

  if [[ ! -d "$DOTFILES_DIR" ]]; then
    printf 'Error: dotfiles directory not found: %s\n' "$DOTFILES_DIR" >&2
    exit 1
  fi

  if [[ ! -d "$LOCAL_BIN_DIR" ]]; then
    log "Creating directory: $LOCAL_BIN_DIR"
    run mkdir -p "$LOCAL_BIN_DIR"
  else
    log "Directory already exists: $LOCAL_BIN_DIR"
  fi

  for item in "${SYMLINK_ITEMS[@]}"; do
    create_symlink "$item"
  done

  for item in "${COPY_ITEMS[@]}"; do
    copy_item "$item"
  done

  log "Done."
}

main "$@"
