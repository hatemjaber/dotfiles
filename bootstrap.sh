#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${HOME}/dotfiles"
LOCAL_BIN_DIR="${HOME}/.local/bin"

DRY_RUN=false
FORCE=false
CHECK_DEPS=true

SYMLINK_ITEMS=(
  ".aliases"
  ".bash_prompt"
  ".bashrc"
  ".curlrc"
  ".exports"
  ".fonts"
  ".functions"
  ".wgetrc"
)

COPY_ITEMS=(
  ".extra"
  ".path"
  ".gitconfig"
)

COMMON_COMMANDS=(
  "bash|run these dotfiles"
  "git|git aliases, prompt status, and diff helper"
  "python3|python HTTP server and python alias target"
  "gzip|gz and targz helpers"
  "bc|gz compression ratio math"
  "file|dataurl MIME detection"
  "openssl|dataurl and certificate helpers"
  "tar|targz helper"
  "stat|targz archive size reporting"
  "du|fs size helper"
  "curl|isup and install scripts"
  "docker|docker aliases and helpers"
  "vim|v helper and editor workflows"
  "tree|tre helper"
  "less|tre pager"
  "dig|digga helper"
  "convert|ImageMagick convert_image_format helper"
  "pigz|optional faster targz compression"
  "zopfli|optional smaller targz compression"
)

LINUX_COMMANDS=(
  "xclip|clipx clipboard helper"
  "notify-send|alert and isup desktop notifications"
  "xdg-open|server and o open helpers"
  "feh|openimage helper"
  "pcregrep|ifactive alias"
  "lwp-request|GET/HEAD/POST/etc aliases"
  "dircolors|GNU ls colors"
  "dconf|GNOME settings dump/restore script"
  "systemctl|battery threshold service setup"
  "apt|Docker install/remove scripts"
)

MACOS_COMMANDS=(
  "brew|Homebrew package management and shell setup"
  "pbcopy|c clipboard alias"
  "defaults|Finder/Desktop defaults aliases"
  "killall|restart Finder/SystemUIServer after defaults changes"
  "gs|mergepdf alias"
  "mdutil|Spotlight aliases"
  "sqlite3|emptytrash quarantine cleanup"
  "osascript|cdf Finder-directory helper"
  "ipconfig|phpserver IP lookup"
  "php|phpserver helper"
  "rbenv|macOS Ruby path setup"
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
  --no-deps   Skip dependency inventory checks
  -h, --help  Show this help
EOF
}

parse_args() {
  while (($#)); do
    case "$1" in
      --dry-run) DRY_RUN=true ;;
      --force)   FORCE=true ;;
      --no-deps) CHECK_DEPS=false ;;
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

platform_name() {
  case "$(uname -s)" in
    Darwin) printf 'macos' ;;
    Linux)  printf 'linux' ;;
    *)      printf 'unknown' ;;
  esac
}

copy_source_for() {
  local name="$1"
  local platform="$2"
  local platform_source="${DOTFILES_DIR}/${platform}/${name}"
  local default_source="${DOTFILES_DIR}/${name}"
  local sample_source="${DOTFILES_DIR}/${name}_sample"

  if [[ -n "$platform" && -e "$platform_source" ]]; then
    printf '%s' "$platform_source"
  elif [[ -e "$default_source" ]]; then
    printf '%s' "$default_source"
  elif [[ -e "$sample_source" ]]; then
    printf '%s' "$sample_source"
  else
    printf '%s' "$default_source"
  fi
}

check_command_group() {
  local label="$1"
  shift

  local missing=()
  local entry cmd reason
  for entry in "$@"; do
    cmd="${entry%%|*}"
    reason="${entry#*|}"
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing+=("${cmd}: ${reason}")
    fi
  done

  if ((${#missing[@]} == 0)); then
    log "Dependency check (${label}): all commands found"
    return 0
  fi

  warn "Dependency check (${label}): missing ${#missing[@]} command(s)"
  for entry in "${missing[@]}"; do
    warn "  ${entry}"
  done
}

check_dependencies() {
  local platform="$1"

  check_command_group "common" "${COMMON_COMMANDS[@]}"
  case "$platform" in
    macos) check_command_group "macOS" "${MACOS_COMMANDS[@]}" ;;
    linux) check_command_group "Linux" "${LINUX_COMMANDS[@]}" ;;
    *) warn "Dependency check: unknown platform $(uname -s); only common commands checked" ;;
  esac
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
  local platform="$2"
  local source
  source="$(copy_source_for "$name" "$platform")"
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
  local platform
  platform="$(platform_name)"

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
    copy_item "$item" "$platform"
  done

  if $CHECK_DEPS; then
    check_dependencies "$platform"
  fi

  log "Done."
}

main "$@"
