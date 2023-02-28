![shell](https://user-images.githubusercontent.com/99351112/207697723-a3fabc0b-f067-4f83-96fd-1f7225a0bb38.svg)

# chatGPT-shell-cli 

A simple, lightweight shell script to use OpenAI's chatGPT and DALL-E from the terminal without installing python or node.js. 
The script uses the `completions` endpoint and the `text-davinci-003` model for chatGPT and the `images/generations` endpoint for generating images.

## Features

- Chat with GPT from the terminal
- Generate images from a text prompt
- View your chat history
- Chat context, GPT remembers previous chat questions and answers
- Pass the input prompt with pipe, as a script parameter or normal chat mode
- List all available OpenAI models 
- Set OpenAI request parameters

![Screenshot 2023-01-12 at 13 59 08](https://user-images.githubusercontent.com/99351112/212061157-bc92e221-ad29-46b7-a0a8-c2735a09449d.png)

![Screenshot 2023-01-13 at 16 39 27](https://user-images.githubusercontent.com/99351112/212346562-ea568cce-2ca2-4b03-9ebc-ece8902c923d.png)

Chat mode:
```shell
$ chatgpt
Welcome to chatgpt. You can quit with 'exit'.

Enter a prompt:

```

Using pipe:
```shell
echo "How to view running processes on Ubuntu?" | chatgpt
```
Using script arguments
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

### Installation

   To install, run this in your terminal and provide your OpenAI API key when asked.
   
   ```sh
   curl -sS https://raw.githubusercontent.com/0xacx/chatGPT-shell-cli/main/install.sh | sudo -E bash
   ```
  
### Manual Installation

  If you want to install it manually, all you have to do is:

  - Download the `chatgpt.sh` file in a directory you want
  - Add the path of `chatgpt.sh` to your `$PATH`. You do that by adding this line to your shell profile: `export PATH=$PATH:/path/to/chatgpt.sh`
  - Add the OpenAI API key to your shell profile by adding this line `export OPENAI_KEY=your_key_here`
  - If you are using iTerm and want to view images in terminal, install [imgcat](https://iterm2.com/utilities/imgcat)

## Usage

### Start

  - Run the script by using the `chatgpt` command anywhere
  - You can also use it in pipe mode `echo "What is the command to get all pdf files created yesterday?" | chatgpt`
  - You can also pass the prompt as an argument `chatgpt -p "What is the regex to match an email address?"`

### Commands

  - `image:` To generate images, start a prompt with `image:`
    If you are using iTerm, you can view the image directly in the terminal. Otherwise the script will ask to open the image in your browser.
  - `history` To view your chat history, type `history`
  - `models` To get a list of the models available at OpenAI API, type `models`
  - `model:` To view all the information on a specific model, start a prompt with `model:` and the model `id` as it appears in the list of models. For example: `model:text-babbage:001` will get you all the fields for `text-babbage:001` model

### Chat context

  - You can enable chat context mode for the model to remember your previous chat questions and answers. This way you can ask follow-up questions. To enable this mode start the script with `-c` or `--chat-context`. i.e. `chatgpt --chat-context` and start to chat. 

#### Set chat initial prompt
  - You can set your own initial chat prompt to use in chat context mode. The initial prompt will be sent on every request along with your regular prompt so that the OpenAI model will "stay in character". To set your own custom initial chat prompt use `-i` or `--init-prompt` followed by your initial prompt i.e. `chatgpt -i "You are Rick from Rick and Morty, reply with references to episodes."` 
  - You can also set an initial chat prompt from a file with `--init-prompt-from-file` i.e. `chatgpt --init-prompt-from-file myprompt.txt`
  
  *When you set an initial prompt you don't need to enable the chat context. 

### Set request parameters

  - To set request parameters you can start the script like this: `chatgpt --temperature 0.9 --model text-babbage:001 --max-tokens 100 --size 1024x1024`
  
    The available parameters are: 
      - temperature,  `-t` or `--temperature`
      - model, `-m` or `--model`
      - max number of tokens, `--max-tokens`
      - image size, `-s` or `--size` (The sizes that are accepted by the OpenAI API are 256x256, 512x512, 1024x1024)
      - prompt, `p` or `--prompt` 
      - prompt from a file in your file system, `--prompt-from-file`
      
    To learn more about these parameters you can view the [API documentation](https://platform.openai.com/docs/api-reference/completions/create)
    
    
## Contributors
Thanks to all the people who used, tested, submitted issues, PRs and proposed changes:

[pfr-dev](https://www.github.com/pfr-dev), [jordantrizz](https://www.github.com/jordantrizz), [se7en-x230](https://www.github.com/se7en-x230), [mountaineerbr](https://www.github.com/mountaineerbr), [oligeo](https://www.github.com/oligeo)

