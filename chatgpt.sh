#!/bin/bash

# Error handling function
# $1 should be the response body
handleError() {
	if echo "$1" | jq -e '.error' >/dev/null; then
		echo -e "Your request to Open AI API failed: \033[0;31m$(echo $1 | jq -r '.error.type')\033[0m"
		echo $1 | jq -r '.error.message'
		exit 1
	fi
}

echo -e "Welcome to chatgpt. You can quit with '\033[36mexit\033[0m'."
running=true

# create history file
if [ ! -f ~/.chatgpt_history ]; then
	touch ~/.chatgpt_history
	chmod a+rw ~/.chatgpt_history
fi

while $running; do
	echo -e "\nEnter a prompt:"
	read prompt

	if [ "$prompt" == "exit" ]; then
		running=false
	elif [[ "$prompt" =~ ^image: ]]; then
		image_response=$(curl https://api.openai.com/v1/images/generations \
			-sS \
			-H 'Content-Type: application/json' \
			-H "Authorization: Bearer $OPENAI_KEY" \
			-d '{
    		"prompt": "'"${prompt#*image:}"'",
    		"n": 1,
    		"size": "512x512"
			}')
		handleError "$image_response"
		image_url=$(echo $image_response | jq -r '.data[0].url')
		echo -e "\n\033[36mchatgpt \033[0mYour image was created. \n\nLink: ${image_url}\n"

		if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
			curl -sS $image_url -o temp_image.png
			imgcat temp_image.png
			rm temp_image.png
		else
			echo "Would you like to open it? (Yes/No)"
			read answer
			if [ "$answer" == "Yes" ] || [ "$answer" == "yes" ] || [ "$answer" == "y" ] || [ "$answer" == "Y" ] || [ "$answer" == "ok" ]; then
				open "${image_url}"
			fi
		fi
	elif [[ "$prompt" == "history" ]]; then
		echo -e "\n$(cat ~/.chatgpt_history)"
	elif [[ "$prompt" == "models" ]]; then
		models_response=$(curl https://api.openai.com/v1/models \
			-sS \
			-H "Authorization: Bearer $OPENAI_KEY")
		handleError "$models_response"
		models_data=$(echo $models_response | jq -r '.data[] | {id, owned_by, created}')
		echo -e "\n\033[36mchatgpt \033[0m This is a list of models currently available at OpenAI API:\n ${models_data}"
	elif [[ "$prompt" =~ ^model: ]]; then
		models_response=$(curl https://api.openai.com/v1/models \
			-sS \
			-H "Authorization: Bearer $OPENAI_KEY")
		handleError "$models_response"
		model_data=$(echo $models_response | jq -r '.data[] | select(.id=="'"${prompt#*model:}"'")')
		echo -e "\n\033[36mchatgpt \033[0m Complete data for model: ${prompt#*model:}\n ${model_data}"
	else
		# escape quotation marks
		escaped_prompt=$(echo "$prompt" | sed 's/"/\\"/g')
		# request to OpenAI API
		response=$(curl https://api.openai.com/v1/completions \
			-sS \
			-H 'Content-Type: application/json' \
			-H "Authorization: Bearer $OPENAI_KEY" \
			-d '{
  			"model": "text-davinci-003",
  			"prompt": "'"${escaped_prompt}"'",
  			"max_tokens": 1000,
  			"temperature": 0.7
			}')

		handleError "$response"
		response_data=$(echo $response | jq -r '.choices[].text' | sed '1,2d')
		echo -e "\n\033[36mchatgpt \033[0m${response_data}"

		timestamp=$(date +"%d/%m/%Y %H:%M")
		echo -e "$timestamp $prompt \n$response_data \n" >>~/.chatgpt_history
	fi
done
