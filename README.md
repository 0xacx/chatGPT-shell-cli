![shell](https://user-images.githubusercontent.com/99351112/207697723-a3fabc0b-f067-4f83-96fd-1f7225a0bb38.svg)

# Chatgptcli

A simple shell script to use OpenAI's chatgpt from the terminal without installing python or node.
The script uses the `completion` endpoint and the `text-davinci-003` model.

![Screenshot](https://user-images.githubusercontent.com/99351112/207676114-3d2c934f-68a7-40cc-b113-df9c4e8f25c7.png)

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
* Create an account and get a free API Key at [OpenAI](https://beta.openai.com/account/api-keys)

### Installation

   To install, run this in your terminal and provide your OpenAI API key when asked.
   
   ```sh
   curl -sS https://raw.githubusercontent.com/0xacx/chatgptcli/main/install.sh | sudo -E bash
   ```
   
<!-- USAGE EXAMPLES -->
## Usage

  Run the script by using the command chatgpt `command` anywhere.
    ```
    chatgpt
    ```
