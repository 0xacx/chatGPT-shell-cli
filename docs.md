---
layout: page
title: "ChatGPT Shell CLI - Docs"
permalink: /docs
---

## Usage

### Start

#### Chat Mode
  - Run the script by using the `chatgpt` command anywhere. By default the script uses the `gpt-3.5-turbo` model.
#### Pipe Mode
  - You can also use it in pipe mode `echo "What is the command to get all pdf files created yesterday?" | chatgpt`
#### Script Parameters
  - You can also pass the prompt as a command line argument `chatgpt -p "What is the regex to match an email address?"`

### Commands

  - `image:` To generate images, start a prompt with `image:`
    If you are using iTerm, you can view the image directly in the terminal. Otherwise the script will ask to open the image in your browser.
  - `history` To view your chat history, type `history`
  - `models` To get a list of the models available at OpenAI API, type `models`
  - `model:` To view all the information on a specific model, start a prompt with `model:` and the model `id` as it appears in the list of models. For example: `model:text-babbage:001` will get you all the fields for `text-babbage:001` model
  - `command:` To get a command with the specified functionality and run it, just type `command:` and explain what you want to achieve. The script will always ask you if you want to execute the command. i.e. `command: show me all files in this directory that have more than 150 lines of code` 
  *If a command modifies your file system or dowloads external files the script will show a warning before executing.*

### Chat context

  - For models other than `gpt-3.5-turbo` and `gpt-4` where the chat context is not supported by the OpenAI api, you can use the chat context build in this script. You can enable chat context mode for the model to remember your previous chat questions and answers. This way you can ask follow-up questions. In chat context the model gets a prompt to act as ChatGPT and is aware of today's date and that it's trained with data up until 2021. To enable this mode start the script with `-c` or `--chat-context`. i.e. `chatgpt --chat-context` and start to chat. 

#### Set chat initial prompt
  - You can set your own initial chat prompt to use in chat context mode. The initial prompt will be sent on every request along with your regular prompt so that the OpenAI model will "stay in character". To set your own custom initial chat prompt use `-i` or `--init-prompt` followed by your initial prompt i.e. `chatgpt -i "You are Rick from Rick and Morty, reply with references to episodes."` 
  - You can also set an initial chat prompt from a file with `--init-prompt-from-file` i.e. `chatgpt --init-prompt-from-file myprompt.txt`
  
  *When you set an initial prompt you don't need to enable the chat context. 

### Use the official ChatGPT model

  - ✨ The model that ChatGPT web uses is `gpt-3.5-turbo` which is the model that is set by default when starting the script.
  
### Use GPT4
  - If you have access to the GPT4 model you can use it by setting the model to `gpt-4`, i.e. `chatgpt --model gpt-4`

### Set request parameters

  - To set request parameters you can start the script like this: `chatgpt --temperature 0.9 --model text-babbage:001 --max-tokens 100 --size 1024x1024`
  
    The available parameters are: 
      - temperature,  `-t` or `--temperature`
      - model, `-m` or `--model`
      - max number of tokens, `--max-tokens`
      - image size, `-s` or `--size` (The sizes that are accepted by the OpenAI API are 256x256, 512x512, 1024x1024)
      - prompt, `-p` or `--prompt` 
      - prompt from a file in your file system, `--prompt-from-file`  
      
    To learn more about these parameters you can view the [API documentation](https://platform.openai.com/docs/api-reference/completions/create)