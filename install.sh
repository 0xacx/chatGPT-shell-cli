#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Running as normal user, will install only for current user"
  BINPATH="$HOME/.local/bin"
else
  echo "Running as root, will install system-wide"
  BINPATH="/usr/local/bin"
fi
# Check dependencies
if type curl &>/dev/null; then
  echo "" &>/dev/null
else
  echo "You need to install 'curl' to use the chatgpt script."
  exit
fi
if type jq &>/dev/null; then
  echo "" &>/dev/null
else
  echo "You need to install 'jq' to use the chatgpt script."
  exit
fi

# Installing imgcat if using iTerm
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
  if type imgcat &>/dev/null; then
    curl -sS https://iterm2.com/utilities/imgcat -o "$BINPATH/imgcat"
    chmod +x "$BINPATH/imgcat"
    echo "Installed imgcat"
  fi
fi

# Installing magick if using kitty
if [[ "$TERM" == "xterm-kitty" ]]; then
  if type magick &>/dev/null; then
    curl -sS https://imagemagick.org/archive/binaries/magick -o "$BINPATH/magick"
    chmod +x "$BINPATH/magick"
    echo "Installed magick"
  fi
fi

# Installing chatgpt script
curl -sS https://raw.githubusercontent.com/0xacx/chatGPT-shell-cli/main/chatgpt.sh -o "$BINPATH/chatgpt"

# Replace open image command with xdg-open for linux systems
if [[ "$OSTYPE" == "linux"* ]] || [[ "$OSTYPE" == "freebsd"* ]]; then
  sed -i 's/open "\${image_url}"/xdg-open "\${image_url}"/g' "$BINPATH/chatgpt"
fi
chmod +x "$BINPATH/chatgpt"
echo "Installed chatgpt script to $BINPATH/chatgpt"

echo "The script will add the OPENAI_KEY environment variable to your shell profile and add $BINPATH to your PATH"
echo "Would you like to continue? (Yes/No)"
read -e answer
if [ "$answer" == "Yes" ] || [ "$answer" == "yes" ] || [ "$answer" == "y" ] || [ "$answer" == "Y" ] || [ "$answer" == "ok" ]; then

  read -p "Please enter your OpenAI API key: " key

  # Adding OpenAI key to shell profile
  # zsh profile
  if [ -f ~/.zprofile ]; then
    echo "export OPENAI_KEY=$key" >>~/.zprofile
    if [[ ":$PATH:" != *":$BINPATH:"* ]]; then
      echo "export PATH=\$PATH:$BINPATH" >>~/.zprofile
    fi
    echo "OpenAI key and chatgpt path added to ~/.zprofile"
    source ~/.zprofile
  # zshrc profile for debian
  elif [ -f ~/.zshrc ]; then
    echo "export OPENAI_KEY=$key" >>~/.zshrc
    if [[ ":$PATH:" == *":$BINPATH:"* ]]; then
      echo "export PATH=\$PATH:$BINPATH" >>~/.zshrc
    fi
    echo "OpenAI key and chatgpt path added to ~/.zshrc"
    source ~/.zshrc
  # bash profile mac
  elif [ -f ~/.bash_profile ]; then
    echo "export OPENAI_KEY=$key" >>~/.bash_profile
    if [[ ":$PATH:" != *":$BINPATH:"* ]]; then
      echo "export PATH=\$PATH:$BINPATH" >>~/.bash_profile
    fi
    echo "OpenAI key and chatgpt path added to ~/.bash_profile"
    source ~/.bash_profile
  # profile ubuntu
  elif [ -f ~/.profile ]; then
    echo "export OPENAI_KEY=$key" >>~/.profile
    if [[ ":$PATH:" != *":$BINPATH:"* ]]; then
      echo "export PATH=\$PATH:$BINPATH" >>~/.profile
    fi
    echo "OpenAI key and chatgpt path added to ~/.profile"
    source ~/.profile
  else
    export OPENAI_KEY=$key
    echo "You need to add this to your shell profile: export OPENAI_KEY=$key"
  fi
  echo "Installation complete"

else
  echo "Please take a look at the instructions to install manually: https://github.com/0xacx/chatGPT-shell-cli/tree/main#manual-installation "
  exit
fi
