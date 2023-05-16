
![shell](https://user-images.githubusercontent.com/99351112/207697723-a3fabc0b-f067-4f83-96fd-1f7225a0bb38.svg)
<div align="center">
<p>

✨Join the new <a href="https://discord.gg/fwfYAZWKqu">Discord server</a> and start contributing to this project!✨</p>


<h1>chatGPT-shell-cli</h1>

A simple, lightweight shell script to use OpenAI's chatGPT and DALL-E from the terminal without installing python or node.js. The script uses the official ChatGPT model `gpt-3.5-turbo` with the OpenAI API endpoint `/chat/completions`. You can also use the new `gpt-4` model, if you have access.  
The script supports the use of all other OpenAI models with the `completions` endpoint and the `images/generations` endpoint for generating images.
</div>

## Features

- [Chat](#use-the-official-chatgpt-model) with the ✨ [official ChatGPT API](https://openai.com/blog/introducing-chatgpt-and-whisper-apis) ✨ from the terminal
- [Generate images](#commands) from a text prompt
- View your [chat history](#commands)
- [Chat context](#chat-context), GPT remembers previous chat questions and answers
- Pass the input prompt with [pipe](#pipe-mode), as a [script parameter](#script-parameters) or normal [chat mode](#chat-mode)
- List all available [OpenAI models](#commands) 
- Set OpenAI [request parameters](#set-request-parameters)
- Generate a [command](#commands) and run it in terminal

![Screenshot 2023-01-12 at 13 59 08](https://user-images.githubusercontent.com/99351112/212061157-bc92e221-ad29-46b7-a0a8-c2735a09449d.png)

![Screenshot 2023-01-13 at 16 39 27](https://user-images.githubusercontent.com/99351112/212346562-ea568cce-2ca2-4b03-9ebc-ece8902c923d.png)

![faster_convert](https://user-images.githubusercontent.com/99351112/230916960-aca256c0-a2c0-4193-ace6-7ed7f3db2145.gif)


[Chat mode](#chat-mode):
```shell
$ chatgpt
Welcome to chatgpt. You can quit with 'exit'.

Enter a prompt:

```

Chat mode with [initial prompt](#set-chat-initial-prompt):
```shell
$ chatgpt -i "You are Rick, from Rick and Morty. Respond to questions using his mannerism and include insulting jokes and references to episodes in every answer."
Welcome to chatgpt. You can quit with 'exit'.

Enter a prompt:
Explain in simple terms how GPT3 works

chatgpt  Ah, you want me to explain GPT3 in simple terms? Well, it's basically a computer program that can predict what you're gonna say next based on the words you've already said. Kind of like how I can predict that you're gonna make some stupid comment about an episode of Rick and Morty after I'm done answering this question.

Enter a prompt:

```

Using [pipe](#pipe-mode):
```shell
echo "How to view running processes on Ubuntu?" | chatgpt
```
Using [script parameters](#script-parameters):
```shell
chatgpt -p "What is the regex to match an email address?"
```



## Getting Started

### Prerequisites

This script relies on curl for the requests to the api and jq to parse the json response.

* [curl](https://www.curl.se)
  ```sh
  brew install curl
  ```
* [jq](https://stedolan.github.io/jq/)
  ```sh
  brew install jq
  ```
* An OpenAI API key. Create an account and get a free API Key at [OpenAI](https://beta.openai.com/account/api-keys)

* Optionally, you can install [glow](https://github.com/charmbracelet/glow) to render responses in markdown 

### Installation

   To install, run this in your terminal and provide your OpenAI API key when asked.
   
   ```sh
   curl -sS https://raw.githubusercontent.com/0xacx/chatGPT-shell-cli/main/install.sh | sudo -E bash
   ```
   
#### ArchLinux

  If you are using ArchLinux you can install the [AUR package](https://aur.archlinux.org/packages/chatgpt-shell-cli) with:
  
  ```
  paru -S chatgpt-shell-cli
  ```

### Manual Installation

  If you want to install it manually, all you have to do is:

  - Download the `chatgpt.sh` file in a directory you want
  - Add the path of `chatgpt.sh` to your `$PATH`. You do that by adding this line to your shell profile: `export PATH=$PATH:/path/to/chatgpt.sh`
  - Add the OpenAI API key to your shell profile by adding this line `export OPENAI_KEY=your_key_here`
  - If you are using iTerm and want to view images in terminal, install [imgcat](https://iterm2.com/utilities/imgcat)

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

  - The default model used when starting the script is `gpt-3.5-turbo`.
  
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
    
    
## Contributors
:pray: Thanks to all the people who used, tested, submitted issues, PRs and proposed changes:

[pfr-dev](https://www.github.com/pfr-dev), [jordantrizz](https://www.github.com/jordantrizz), [se7en-x230](https://www.github.com/se7en-x230), [mountaineerbr](https://www.github.com/mountaineerbr), [oligeo](https://www.github.com/oligeo), [biaocy](https://www.github.com/biaocy), [dmd](https://www.github.com/dmd), [goosegit11](https://www.github.com/goosegit11), [dilatedpupils](https://www.github.com/dilatedpupils), [direster](https://www.github.com/direster), [rxaviers](https://www.github.com/rxaviers), [Zeioth](https://www.github.com/Zeioth), [edshamis](https://www.github.com/edshamis), [nre-ableton](https://www.github.com/nre-ableton), [TobiasLaving](https://www.github.com/TobiasLaving), [RexAckermann](https://www.github.com/RexAckermann), [emirkmo](https://www.github.com/emirkmo), [np](https://www.github.com/np), [camAtGitHub](https://github.com/camAtGitHub), [keyboardsage](https://github.com/keyboardsage) [tomas223](https://github.com/tomas223)

## Contributing
Contributions are very welcome!

If you have ideas or need help to get started join the [Discord server](https://discord.gg/fwfYAZWKqu)

![Discord](https://img.shields.io/discord/1090696025162928158?label=Discord&style=for-the-badge)
