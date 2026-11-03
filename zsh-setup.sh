#!/bin/sh
# This script installs several zsh plugins, and adjusts a few zsh settings.
# Run it as root with git and git-http installed.

set -eu
PLUGIN_DIR=/usr/share/zsh/plugins
CONFIG_DIR=/etc/zsh

install_plugin() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: install_plugin <repository-url> <plugin-name>" >&2
    exit 1
  fi

  url=$1
  name=$2
  dest="$PLUGIN_DIR/$name"

  if [ -d "$dest/.git" ]; then
    git -C "$dest" pull --ff-only
  elif [ -e "$dest" ]; then
    echo "Error: $dest exists but is not a Git repository." >&2
    exit 1
  else
    git clone --depth 1 "$url" "$dest"
  fi
}

mkdir -p "$PLUGIN_DIR"
install_plugin https://github.com/zsh-users/zsh-completions zsh-completions
install_plugin https://github.com/marlonrichert/zsh-autocomplete zsh-autocomplete
install_plugin https://github.com/zsh-users/zsh-autosuggestions zsh-autosuggestions
install_plugin https://github.com/zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting

mkdir -p "$CONFIG_DIR"
cat > "$CONFIG_DIR/zshrc" <<EOF
if [[ -o interactive ]]; then
  PROMPT='%n@%m:%~%# '
  fpath=("$PLUGIN_DIR/zsh-completions/src" \$fpath)

  [[ -r "$PLUGIN_DIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]] &&
    source "$PLUGIN_DIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

  [[ -r "$PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] &&
    source "$PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"

  [[ -r "$PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] &&
    source "$PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
EOF

echo "zsh plugins installed into $PLUGIN_DIR; shared config written to $CONFIG_DIR/zshrc."
