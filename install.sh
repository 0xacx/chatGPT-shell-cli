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

if [ -f chatgpt.sh ]
then
	mv chatgpt.sh /usr/local/bin/chatgpt
else
	curl -sS https://raw.githubusercontent.com/0xacx/chatgptcli/main/chatgpt.sh -o /usr/local/bin/chatgpt
fi

chmod +x /usr/local/bin/chatgpt

read -p "Please enter your OpenAi API key: " token

# Adding OpenAI token to shell profile
if [ -f ~/.zprofile ]; then
  echo "export OPENAI_TOKEN=$token" >> ~/.zprofile
  echo 'export PATH=$PATH:/usr/local/bin' >> ~/.zprofile
else
  if [ -f ~/.bash_profile ]; then
    echo "export OPENAI_TOKEN=$token" >> ~/.bash_profile
    echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bash_profile
  else
    export OPENAI_TOKEN=$token
    echo "You need to add this to your shell profile: export OPENAI_TOKEN=$token"
  fi
fi
echo "Installation complete."
chatgpt