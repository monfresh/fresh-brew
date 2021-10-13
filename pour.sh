#!/usr/bin/env bash

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\\n$fmt\\n" "$@"
}

append_to_file() {
  local file="$1"
  local text="$2"

  if ! grep -qs "^$text$" "$file"; then
    printf "\\n%s\\n" "$text" >> "$file"
  fi
}

append_to_beginning_of_file() {
  local file="$1"
  local text="$2"

  if ! grep -qs "^$text$" "$file"; then
    echo "$text" | cat - "$file" > temp && mv temp "$file"
  fi
}

create_zshrc_and_set_it_as_shell_file() {
  if [ ! -f "$HOME/.zshrc" ]; then
    touch "$HOME/.zshrc"
  fi

  shell_file="$HOME/.zshrc"
}

create_bash_profile_and_set_it_as_shell_file() {
  if [ ! -f "$HOME/.bash_profile" ]; then
    touch "$HOME/.bash_profile"
  fi

  shell_file="$HOME/.bash_profile"
}

create_fish_config_and_set_it_as_shell_file() {
  if [ ! -d "$HOME/.config/fish" ]; then
     mkdir "$HOME/.config/fish"
  fi

  if [ ! -f "$HOME/.config/fish/config.fish" ]; then
    touch "$HOME/.config/fish/config.fish"
  fi

  shell_file="$HOME/.config/fish/config.fish"
}

apple_m1() {
  sysctl -n machdep.cpu.brand_string | grep "Apple M1"
}

rosetta() {
  uname -m | grep "x86_64"
}

homebrew_installed_on_m1() {
  apple_m1 && ! rosetta && [ -d "/opt/homebrew" ]
}

homebrew_installed_on_intel() {
  ! apple_m1 && command -v brew >/dev/null
}

install_or_update_homebrew() {
  if homebrew_installed_on_m1 || homebrew_installed_on_intel; then
    update_homebrew
  else
    install_homebrew
  fi
}

install_homebrew() {
  fancy_echo "Installing Homebrew ..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  configure_shell_file_for_homebrew
}

update_homebrew() {
  fancy_echo "Homebrew already installed. Updating Homebrew ..."
  configure_shell_file_for_homebrew
  brew update
}

configure_shell_file_for_homebrew() {
  if apple_m1 && ! rosetta; then
    configure_shell_file_for_homebrew_on_m1
  else
    # shellcheck disable=SC2016
    append_to_file "$shell_file" 'export PATH="/usr/local/bin:$PATH"'
  fi
}

configure_shell_file_for_homebrew_on_m1() {
  if [[ $SHELL == *fish ]]; then
    # shellcheck disable=SC2016
    append_to_beginning_of_file "$shell_file" 'status --is-interactive; and eval (/opt/homebrew/bin/brew shellenv)'
  else
    # shellcheck disable=SC2016
    append_to_file "$HOME/.zprofile" 'eval $(/opt/homebrew/bin/brew shellenv)'
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

# shellcheck disable=SC2154
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

case "$SHELL" in
  */zsh) :
    create_zshrc_and_set_it_as_shell_file
    ;;
  */bash)
    create_bash_profile_and_set_it_as_shell_file
    ;;
  */fish)
    create_fish_config_and_set_it_as_shell_file
    ;;
esac

fancy_echo 'Welcome to the fresh-brew script!'
fancy_echo 'You should be up and running with a working dev environment in a few minutes.'
fancy_echo 'The following lines are to help debug any issues:'
fancy_echo "====Start of debugging===="
fancy_echo "Current shell: $SHELL"
fancy_echo "Current PATH: $PATH"
fancy_echo "macOS version:"
sw_vers

fancy_echo "Mac model:"
sysctl hw.model

fancy_echo "Mac CPU:"
sysctl -n machdep.cpu.brand_string

fancy_echo "CPU architecture:"
uname -m

fancy_echo "====End of debugging===="

fancy_echo "====Getting ready to install or update Homebrew===="
install_or_update_homebrew
fancy_echo "====Done installing or updating Homebrew===="

fancy_echo "Verifying the Homebrew installation..."
if brew doctor; then
  fancy_echo "Your Homebrew installation is good to go."
else
  fancy_echo "Your Homebrew installation reported some errors or warnings."
  echo "Review the Homebrew messages to see if any action is needed."
fi

fancy_echo "Installing formulas and casks from the Brewfile..."
if brew bundle --file="Brewfile"; then
  fancy_echo "All formulas were installed successfully."
else
  fancy_echo "Some formulas failed to install."
fi

if [ -f "fresh-brew.local" ] && ! [[ $SKIP_LOCAL == true ]]; then
  # shellcheck source=/dev/null
  . "fresh-brew.local"
fi

fancy_echo 'All done!'
fancy_echo 'Now make sure to quit and restart your terminal!'
