# This script installs several zsh plugins, and adjusts a few zsh settings.
# It must be run as root and requires git and git-http to be installed.
#!/bin/sh
set -eu
PLUGIN_DIR=/usr/share/zsh/plugins
CONFIG_DIR=/etc/zsh

install_plugin() {
	if [ "$#" -ne 1 ]; then
    echo "Usage: install_plugin <repository-url>" >&2
    exit 1
  fi

  url=$1
  name=${url##*/}
  dest="$PLUGIN_DIR/${name%.git}"

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
install_plugin https://github.com/zsh-users/zsh-completions
install_plugin https://github.com/marlonrichert/zsh-autocomplete
install_plugin https://github.com/zsh-users/zsh-autosuggestions
install_plugin https://github.com/zsh-users/zsh-syntax-highlighting


mkdir -p "$CONFIG_DIR"
cat > /etc/zsh/zshrc <<'EOF'
if [[ -o interactive ]]; then
  PROMPT='%n@%m:%~%# '
  fpath=(/usr/share/zsh/plugins/zsh-completions/src $fpath)

  [[ -r /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]] &&
    source /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

  [[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

  [[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
EOF

echo "Zsh and plugins installed; shared config written to /etc/zsh/zshrc."
