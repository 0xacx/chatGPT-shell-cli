#!/bin/bash
GLOBIGNORE="*"

CHAT_INIT_PROMPT="You are ChatGPT, a Large Language Model trained by OpenAI. You will be answering questions from users. You answer as concisely as possible for each response (e.g. don’t be verbose). If you are generating a list, do not have too many items. Keep the number of items short. Before each user prompt you will be given the chat history in Q&A form. Output your answer directly, with no labels in front. Do not start your answers with A or Anwser. You were trained on data up until 2021. Today's date is $(date +%d/%m/%Y)"

SYSTEM_PROMPT="You are ChatGPT, a large language model trained by OpenAI. Answer as concisely as possible. Current date: $(date +%d/%m/%Y). Knowledge cutoff: 9/1/2021."

CHATGPT_CYAN_LABEL="\n\033[36mchatgpt \033[0m"

# error handling function
# $1 should be the response body
handle_error() {
	if echo "$1" | jq -e '.error' >/dev/null; then
		echo -e "Your request to Open AI API failed: \033[0;31m$(echo $1 | jq -r '.error.type')\033[0m"
		echo $1 | jq -r '.error.message'
		exit 1
	fi
}

# request to OpenAI API completions endpoint function
# $1 should be the request prompt
request_to_completions() {
	request_prompt="$1"

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
	prompt="$1"
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

# request to OpenAPI API chat completion endpoint function
# $1 should be the message(s) formatted with role and content
request_to_chat() {
	message="$1"
	response=$(curl https://api.openai.com/v1/chat/completions \
		-sS \
		-H 'Content-Type: application/json' \
		-H "Authorization: Bearer $OPENAI_KEY" \
		-d '{
            "model": "'"$MODEL"'",
            "messages": [
                {"role": "system", "content": "'"$SYSTEM_PROMPT"'"},
                '"$message"'
                ],
            "max_tokens": '$MAX_TOKENS',
            "temperature": '$TEMPERATURE'
            }')
}

# build chat context before each request for /completions (all models except
# gpt turbo)
# $1 should be the chat context
# $2 should be the escaped prompt
build_chat_context() {
	chat_context="$1"
	escaped_prompt="$2"
	if [ -z "$chat_context" ]; then
		chat_context="$CHAT_INIT_PROMPT\nQ: $escaped_prompt"
	else
		chat_context="$chat_context\nQ: $escaped_prompt"
	fi
	request_prompt="${chat_context//$'\n'/\\n}"
}

# maintain chat context function for /completions (all models except gpt turbo)
# builds chat context from response,
# keeps chat context length under max token limit
# $1 should be the chat context
# $2 should be the response data (only the text)
maintain_chat_context() {
	chat_context="$1"
	response_data="$2"
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

# build user chat message function for /chat/completions (gpt turbo model)
# builds chat message before request,
# $1 should be the chat message
# $2 should be the escaped prompt
build_user_chat_message() {
	chat_message="$1"
	escaped_prompt="$2"
	if [ -z "$chat_message" ]; then
		chat_message="{\"role\": \"user\", \"content\": \"$escaped_prompt\"}"
	else
		chat_message="$chat_message, {\"role\": \"user\", \"content\": \"$escaped_prompt\"}"
	fi

	request_prompt=$chat_message
}

# adds the assistant response to the message in (chatml) format
# for /chat/completions (gpt turbo model)
# keeps messages length under max token limit
# $1 should be the chat message
# $2 should be the response data (only the text)
add_assistant_response_to_chat_message() {
	chat_message="$1"
	response_data="$2"

	# replace new line characters from response with space
	response_data=$(echo "$response_data" | tr '\n' ' ')
	# add response to chat context as answer
	chat_message="$chat_message, {\"role\": \"assistant\", \"content\": \"$response_data\"}"

	# transform to json array to parse with jq
	chat_message_json="[ $chat_message ]"
	# check prompt length, 1 word =~ 1.3 tokens
	# reserving 100 tokens for next user prompt
	while (($(echo "$chat_message" | wc -c) * 1, 3 > (MAX_TOKENS - 100))); do
		# remove first/oldest QnA from prompt
		chat_message=$(echo "$chat_message_json" | jq -c '.[2:] | .[] | {role, content}')
	done
}

# parse command line arguments
while [[ "$#" -gt 0 ]]; do
	case $1 in
	-i | --init-prompt)
		CHAT_INIT_PROMPT="$2"
		SYSTEM_PROMPT="$2"
		CONTEXT=true
		shift
		shift
		;;
	--init-prompt-from-file)
		CHAT_INIT_PROMPT=$(cat "$2")
		SYSTEM_PROMPT=$(cat "$2")
		CONTEXT=true
		shift
		shift
		;;
	-p | --prompt)
		prompt="$2"
		shift
		shift
		;;
	--prompt-from-file)
		prompt=$(cat "$2")
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
	-cc | --chat-completion)
		MODEL="gpt-3.5-turbo"
		CHAT_COMPLETION=true
		shift
		;;
	*)
		echo "Unknown parameter: $1"
		exit 1
		;;
	esac
done

# set defaults
TEMPERATURE=${TEMPERATURE:-0.7}
MAX_TOKENS=${MAX_TOKENS:-1024}
MODEL=${MODEL:-text-davinci-003}
SIZE=${SIZE:-512x512}
CONTEXT=${CONTEXT:-false}
CHAT_COMPLETION=${CHAT_COMPLETION:-false}

# create history file
if [ ! -f ~/.chatgpt_history ]; then
	touch ~/.chatgpt_history
	chmod a+rw ~/.chatgpt_history
fi

running=true
# check input source
# if prompt already entered, run on pipe mode (run once, no chat)
# prompt from pipe
if [ -p /dev/stdin ]; then
	pipe_mode_prompt+=$(cat -)
# prompt from argument
elif [ -n "$prompt" ]; then
	pipe_mode_prompt=${prompt}
else
	echo -e "Welcome to chatgpt. You can quit with '\033[36mexit\033[0m'."
fi

while $running; do

	if [ -z "$pipe_mode_prompt" ]; then
		echo -e "\nEnter a prompt:"
		read -e prompt
	else
		# set vars for pipe mode
		prompt=${pipe_mode_prompt}
		running=false
		CHATGPT_CYAN_LABEL=""
	fi

	if [ "$prompt" == "exit" ]; then
		running=false
	elif [[ "$prompt" =~ ^image: ]]; then
		request_to_image "$prompt"
		handle_error "$image_response"
		image_url=$(echo $image_response | jq -r '.data[0].url')
		echo -e "${CHATGPT_CYAN_LABEL}Your image was created. \n\nLink: ${image_url}\n"

		if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
			curl -sS $image_url -o temp_image.png
			imgcat temp_image.png
			rm temp_image.png
		else
			echo "Would you like to open it? (Yes/No)"
			read -e answer
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
		echo -e "${CHATGPT_CYAN_LABEL}This is a list of models currently available at OpenAI API:\n ${models_data}"
	elif [[ "$prompt" =~ ^model: ]]; then
		models_response=$(curl https://api.openai.com/v1/models \
			-sS \
			-H "Authorization: Bearer $OPENAI_KEY")
		handle_error "$models_response"
		model_data=$(echo $models_response | jq -r -C '.data[] | select(.id=="'"${prompt#*model:}"'")')
		echo -e "${CHATGPT_CYAN_LABEL}Complete details for model: ${prompt#*model:}\n ${model_data}"
	elif [[ "$CHAT_COMPLETION" = true ]]; then
		# escape quotation marks
		escaped_prompt=$(echo "$prompt" | sed 's/"/\\"/g')
		# escape new lines
		request_prompt=${escaped_prompt//$'\n'/' '}

		build_user_chat_message "$chat_message" "$request_prompt"
		request_to_chat "$request_prompt"
		handle_error "$response"
		response_data=$(echo "$response" | jq -r '.choices[].message.content')

		echo -e "${CHATGPT_CYAN_LABEL}${response_data}"

		response_data=$(echo "$response_data" | sed 's/"/\\"/g')
		add_assistant_response_to_chat_message "$chat_message" "$response_data"

		timestamp=$(date +"%d/%m/%Y %H:%M")
		echo -e "$timestamp $prompt \n$response_data \n" >>~/.chatgpt_history
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
		response_data=$(echo "$response" | jq -r '.choices[].text' | sed '1,2d; s/^A://g')
		echo -e "${CHATGPT_CYAN_LABEL}${response_data}"

		if [ "$CONTEXT" = true ]; then
			escaped_response_data=$(echo "$response_data" | sed 's/"/\\"/g')
			maintain_chat_context "$chat_context" "$escaped_response_data"
		fi

		timestamp=$(date +"%d/%m/%Y %H:%M")
		echo -e "$timestamp $prompt \n$escaped_response_data \n" >>~/.chatgpt_history
	fi
done
