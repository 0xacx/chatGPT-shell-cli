#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi
# Check dependencies
if type curl &>/dev/null
then
	echo "" &>/dev/null
else
	echo "You need to install 'curl' to use the chatgpt script."
	exit
fi
if type jq &>/dev/null
then
	echo "" &>/dev/null
else
	echo "You need to install 'jq' to use the chatgpt script."
	exit
fi

# Installing imgcat if using iTerm
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
  if [[ ! $(which imgcat) ]]; then
    curl -sS https://iterm2.com/utilities/imgcat -o /usr/local/bin/imgcat
    chmod +x /usr/local/bin/imgcat
  fi
fi

# Installing chatgpt script
curl -sS https://raw.githubusercontent.com/0xacx/chatGPT-shell-cli/main/chatgpt.sh -o /usr/local/bin/chatgpt
chmod +x /usr/local/bin/chatgpt

read -p "Please enter your OpenAI API key: " key

# Adding OpenAI key to shell profile
# zsh profile
if [ -f ~/.zprofile ]; then
  echo "export OPENAI_KEY=$key" >> ~/.zprofile
  echo 'export PATH=$PATH:/usr/local/bin' >> ~/.zprofile
  echo "OpenAI key and chatgpt path added to ~/.zprofile"
# bash profile mac
elif [ -f ~/.bash_profile ]; then
  echo "export OPENAI_KEY=$key" >> ~/.bash_profile
  echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bash_profile
  echo "OpenAI key and chatgpt path added to ~/.bash_profile"
# profile ubuntu
elif [ -f ~/.profile ]; then
  echo "export OPENAI_KEY=$key" >> ~/.profile
  echo 'export PATH=$PATH:/usr/local/bin' >> ~/.profile
  echo "OpenAI key and chatgpt path added to ~/.profile"
else
  export OPENAI_KEY=$key
  echo "You need to add this to your shell profile: export OPENAI_KEY=$key"
fi
echo "Installation complete."
chatgpt