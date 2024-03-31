[ -n "$PS1" ] && source ~/.bash_profile;

# pnpm
export PNPM_HOME="/Users/hatem/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
