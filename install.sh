#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi
# Check dependencies
if ! type curl &>/dev/null; then
  echo "You need to install 'curl' to use the chatgpt script."
  exit 0
fi
if ! type jq &>/dev/null; then
  echo "You need to install 'jq' to use the chatgpt script."
  exit 0
fi

# Installing imgcat if using iTerm
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
  if [[ ! $(which imgcat) ]]; then
    curl -sS https://iterm2.com/utilities/imgcat -o /usr/local/bin/imgcat
    chmod +x /usr/local/bin/imgcat
    echo "Installed imgcat"
  fi
fi

# Installing magick if using kitty
if [[ "$TERM" == "xterm-kitty" ]]; then
  if [[ ! $(which magick) ]]; then
    curl -sS https://imagemagick.org/archive/binaries/magick -o /usr/local/bin/magick
    chmod +x /usr/local/bin/magick
    echo "Installed magick"
  fi
fi

# Installing chatgpt script
curl -sS https://raw.githubusercontent.com/0xacx/chatGPT-shell-cli/main/chatgpt.sh -o /usr/local/bin/chatgpt

# Replace open image command with xdg-open for linux systems
if [[ "$OSTYPE" == "linux"* ]] || [[ "$OSTYPE" == "freebsd"* ]]; then
  sed -i 's/open "\${image_url}"/xdg-open "\${image_url}"/g' '/usr/local/bin/chatgpt'
fi
chmod +x /usr/local/bin/chatgpt
echo "Installed chatgpt script to /usr/local/bin/chatgpt"

echo "The script will add the OPENAI_KEY environment variable"
echo "to your shell profile and /usr/local/bin to your PATH"
read -ep "Would you like to continue? (Yes/No) " yn
yn=${yn/Y/y}
yn=${yn/ok/y}
if ! test "${yn:0:1}" == "y"; then
  echo
  echo "Please take a look at the instructions to install manually:"
  echo "https://github.com/0xacx/chatGPT-shell-cli/tree/main#manual-installation"
  echo
  exit 0
fi

read -p "Please enter your OpenAI API key: " key

# Adding OpenAI key to shell profile
# RAF: .bashrc was missing, added + using a for loop
envset=0
for u in '' $SUDO_USER; do
  for i in .zprofile .zshrc .bash_profile .bashrc .profile; do
    pf=$(eval readlink -e ~$u/$i)
    if [ -f "$pf" ]; then
      echo "export OPENAI_KEY=$key" >> $pf
      if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
        echo 'export PATH=$PATH:/usr/local/bin' >> $pf
      fi
      echo "OpenAI key and chatgpt path added to ~$u/$i"
  # RAF: sourcing an enviroment within a sub-shell does not affect
  #      the parent shell enviroment unless using source install.sh
  #   source ~/$i
      envset=1
    fi
  done
done

if [ $envset -eq 0 ]; then
  export OPENAI_KEY=$key
  echo "You need to add this to your shell profile: export OPENAI_KEY=$key"
fi
echo "Installation complete"
