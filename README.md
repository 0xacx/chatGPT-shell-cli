![shell](https://user-images.githubusercontent.com/99351112/207697723-a3fabc0b-f067-4f83-96fd-1f7225a0bb38.svg)

# ChatGPT_Shell_CLI

A simple shell script to use OpenAI's chatgpt from the terminal without installing python or node.
The script uses the `completion` endpoint and the `text-davinci-003` model.

![Screenshot 2022-12-15 at 17 20 15](https://user-images.githubusercontent.com/99351112/207898587-1fb405c9-02c6-47c0-b433-7110634810f7.png)

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
   curl -sS https://raw.githubusercontent.com/0xacx/chatgptcli/main/install.sh | sudo -E bash
   ```
   
<!-- USAGE EXAMPLES -->
## Usage

  Run the script by using the `chatgpt` command anywhere.

