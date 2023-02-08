![shell](https://user-images.githubusercontent.com/99351112/207697723-a3fabc0b-f067-4f83-96fd-1f7225a0bb38.svg)

# chatGPT-shell-cli 

A simple, lightweight shell script to use OpenAI's chatGPT and DALL-E from the terminal without installing python or node.js. 
The script uses the `completions` endpoint and the `text-davinci-003` model for chatGPT and the `images/generations` endpoint for generating images.

## Features

- Chat with GPT from the terminal
- Generate images from a text prompt
- View your chat history

![Screenshot 2023-01-12 at 13 59 08](https://user-images.githubusercontent.com/99351112/212061157-bc92e221-ad29-46b7-a0a8-c2735a09449d.png)

![Screenshot 2023-01-13 at 16 39 27](https://user-images.githubusercontent.com/99351112/212346562-ea568cce-2ca2-4b03-9ebc-ece8902c923d.png)

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

  - Run the script by using the `chatgpt` command anywhere
  - To generate images, start a prompt with `image:`
    If you are using iTerm, you can view the image directly in the terminal. Otherwise the script will ask to open the image in your browser.
  - To view your chat history, type `history`
  - To get a list of the models available at OpenAI API, type `models`
  - To view all the information on a specific model, use `model:` and the model `id` as it appears in the list of models. For example: `model:text-babbage:001` will get you all the fields for `text-babbage:001` model

