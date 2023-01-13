![shell](https://user-images.githubusercontent.com/99351112/207697723-a3fabc0b-f067-4f83-96fd-1f7225a0bb38.svg)

# chatGPT-shell-cli 

A simple, lightweight shell script to use OpenAI's chatGPT and DALL-E from the terminal without installing python or node.js. 
The script uses the `completions` endpoint and the `text-davinci-003` model for chatGPT and the `images/generations` endpoint for generating images.

![Screenshot 2023-01-12 at 13 59 08](https://user-images.githubusercontent.com/99351112/212061157-bc92e221-ad29-46b7-a0a8-c2735a09449d.png)

You can generate images by starting your prompt with `image:`. If you are using iTerm, you can view the image directly in the terminal. Otherwise the script will ask to open the image in your browser.

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
   
<!-- USAGE EXAMPLES -->
## Usage

  Run the script by using the `chatgpt` command anywhere.

