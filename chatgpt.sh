#!/bin/bash

#CHAT_INIT_PROMPT="You are ChatGPT, a Large Language Model trained by OpenAI. You will be answering questions from users. You answer as concisely as possible for each response (e.g. don’t be verbose). If you are generating a list, do not have too many items. Keep the number of items short. Before each user prompt you will be given the chat history in Q&A form. Output your answer directly, with no labels in front. Do not start your answers with A or Anwser. You were trained on data up until 2021. Today's date is $(date +%d/%m/%Y)"
CHAT_INIT_PROMPT="Du bist ChatGPT und bekommst Benutzeranfragen direkt aus eine Linux Shell heraus. Beschränke dich auf das wesentliche und gib nützliche Tipps. Setze deine vorgeschlagenen Scripte, Kommandos und Befehle nicht in Anführungszeichen. Füge Kommentaren an den entscheidenden Stellen ein. Der Anfrage wird der Chatverlauf im Q&A Format voran gestellt."
CHATGPT_PROMPT="\n\033[36mchatgpt \033[0m"

# Error handling function
# $1 should be the response body
handle_error() {
	if echo "$1" | jq -e '.error' >/dev/null; then
		echo -e "Your request to Open AI API failed: \033[0;31m$(echo $1 | jq -r '.error.type')\033[0m"
		echo $1 | jq -r '.error.message'
		exit 1
	fi
}

# request to OpenAI API completetions endpoint function
# $1 should be the request prompt
request_to_completions() {
	request_prompt=$1

	response=$(curl https://api.openai.com/v1/completions \
		-sS \
		-H 'Content-Type: application/json' \
		-H "Authorization: Bearer $OPENAI_KEY" \
		-d '{
  			"model": "'"$MODEL"'",
  			"prompt": "'"${request_prompt}"'",
  			"max_tokens": '$MAX_TOKENS',
  			"temperature": '$TEMPERATURE'
			}')
}

# request to OpenAI API image generations endpoint function
# $1 should be the prompt
request_to_image() {
	prompt=$1
	image_response=$(curl https://api.openai.com/v1/images/generations \
		-sS \
		-H 'Content-Type: application/json' \
		-H "Authorization: Bearer $OPENAI_KEY" \
		-d '{
    		"prompt": "'"${prompt#*image:}"'",
    		"n": 1,
    		"size": "'"$SIZE"'"
			}')
}

# build chat context before each request
# $1 should be the chat context
# $2 should be the escaped prompt
build_chat_context() {
	chat_context=$1
	escaped_prompt=$2
	if [ -z "$chat_context" ]; then
		chat_context="$CHAT_INIT_PROMPT\nQ: $escaped_prompt"
	else
		chat_context="$chat_context\nQ: $escaped_prompt"
	fi
	request_prompt="${chat_context//$'\n'/\\n}"
}

# maintain chat context function, builds cc from response,
# keeps chat context length under max token limit
# $1 should be the chat context
# $2 should be the response data (only the text)
maintain_chat_context() {
	chat_context=$1
	response_data=$2
	# add response to chat context as answer
	chat_context="$chat_context${chat_context:+\n}\nA: ${response_data//$'\n'/\\n}"
	# check prompt length, 1 word =~ 1.3 tokens
	# reserving 100 tokens for next user prompt
	while (($(echo "$chat_context" | wc -c) * 1, 3 > (MAX_TOKENS - 100))); do
		# remove first/oldest QnA from prompt
		chat_context=$(echo "$chat_context" | sed -n '/Q:/,$p' | tail -n +2)
		# add init prompt so it is always on top
		chat_context="$CHAT_INIT_PROMPT $chat_context"
	done
}
# parse command line arguments
while [[ "$#" -gt 0 ]]; do
	case $1 in
	-i | --init-prompt-from-file)
		CHAT_INIT_PROMPT=$(cat "$2")
		shift
		shift
		;;
	--init-prompt)
		CHAT_INIT_PROMPT="$2"
		shift
		shift
		;;
	-p | --prompt-from-file)
		prompt=$(cat "$2")
		shift
		shift
		;;
	--prompt)
		prompt="$2"
		shift
		shift
		;;
	-t | --temperature)
		TEMPERATURE="$2"
		shift
		shift
		;;
	--max-tokens)
		MAX_TOKENS="$2"
		shift
		shift
		;;
	-m | --model)
		MODEL="$2"
		shift
		shift
		;;
	-s | --size)
		SIZE="$2"
		shift
		shift
		;;
	-c | --chat-context)
		CONTEXT=true
		shift
		;;
	--test)
		test=true
		shift
		;;
	-h|--help)
	echo 'chatgpt [parameter]

CLI is running if prompt not insert from file, string or stdin.

Usage Parameter:
 -c, --chat-context	i.e. chatgpt --chat-context and start to chat normally. 
 -i, --init-prompt-from-file
 --init-prompt		Overwrite Initial prompt
 -p, --prompt-from-file
 --prompt
 --test		Only prompt parameters
 
Request Parameters:
 -t, --temperature
 -m, --model
 --max-tokens
 -s, --size		256x256, 512x512, 1024x1024

CLI Commands:

image: To generate images, start a prompt with image: If you are using iTerm, you can view the image directly in the terminal. Otherwise the script will ask to open the image in your browser.
 
history To view your chat history, type history
 
models To get a list of the models available at OpenAI API, type models
 
model: To view all the information on a specific model, start a prompt with model: and the model id as it appears in the list of models. For example: model:text-babbage:001 will get you all the fields for text-babbage:001 model
 
exit
'
		exit 0
		;;
	*)
		echo "Unknown parameter: $1"
		exit 1
		;;
	esac
done


# Prüfen, ob die Eingabe über eine Pipe oder eine Datei empfangen wird
if [ -p /dev/stdin ]; then
 # Eingabe über eine Pipe empfangen
 prompt+=$(cat -)
fi


# set defaults
TEMPERATURE=${TEMPERATURE:-0.7}
MAX_TOKENS=${MAX_TOKENS:-1024}
MODEL=${MODEL:-text-davinci-003}
SIZE=${SIZE:-512x512}
CONTEXT=${CONTEXT:-false}
USER=${USER:-Human}

[ -z "$prompt" ] && echo -e "Welcome to chatgpt. You can quit with '\033[36mexit\033[0m'."
running=true

# create history file
if [ ! -f ~/.chatgpt_history ]; then
	touch ~/.chatgpt_history
	chmod a+rw ~/.chatgpt_history
fi

while $running; do
	if [ -z "$prompt" ]; then
		if type -P rlwrap &> /dev/null; then
				prompt=$(rlwrap -pYellow -S "[${USER}] " -H past_orders -o cat)
		else
			echo -e "\nEnter a prompt:"
			read prompt
		fi	
	else
		running=false
	fi

	if [ $test ]; then
		echo "Parameter Test"
		echo '	"model": "'"$MODEL"'"
	"init_prompt": '$CHAT_INIT_PROMPT'
	"prompt": '$prompt'
	"max_tokens": '$MAX_TOKENS'
	"temperature": '$TEMPERATURE'
	"size": '$SIZE'
	"context": '$CONTEXT'
	'
		running=false
	elif [ "$prompt" == "exit" ]; then
		running=false
	elif [[ "$prompt" =~ ^image: ]]; then
		request_to_image "$prompt"
		handle_error "$image_response"
		image_url=$(echo $image_response | jq -r '.data[0].url')
		echo -e "${CHATGPT_PROMPT} Your image was created. \n\nLink: ${image_url}\n"

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
		handle_error "$models_response"
		models_data=$(echo $models_response | jq -r -C '.data[] | {id, owned_by, created}')
		echo -e "${CHATGPT_PROMPT} This is a list of models currently available at OpenAI API:\n ${models_data}"
	elif [[ "$prompt" =~ ^model: ]]; then
		models_response=$(curl https://api.openai.com/v1/models \
			-sS \
			-H "Authorization: Bearer $OPENAI_KEY")
		handle_error "$models_response"
		model_data=$(echo $models_response | jq -r -C '.data[] | select(.id=="'"${prompt#*model:}"'")')
		echo -e "${CHATGPT_PROMPT} Complete details for model: ${prompt#*model:}\n ${model_data}"
	else
		# escape quotation marks
		escaped_prompt=$(echo "$prompt" | sed 's/"/\\"/g')
		# escape new lines
		request_prompt=${escaped_prompt//$'\n'/' '}

		if [ "$CONTEXT" = true ]; then
			build_chat_context "$chat_context" "$escaped_prompt"
		fi

		request_to_completions "$request_prompt"
		handle_error "$response"
		response_data=$(echo $response | jq -r '.choices[].text' | sed '1,2d; s/^A://g')
		echo -e "${CHATGPT_PROMPT} ${response_data}"

		if [ "$CONTEXT" = true ]; then
			maintain_chat_context "$chat_context" "$response_data"
		fi

		timestamp=$(date +"%d/%m/%Y %H:%M")
		echo -e "$timestamp $prompt \n$response_data \n" >>~/.chatgpt_history
	fi
	prompt=""
done
