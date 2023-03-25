---
layout: page
title: "ChatGPT Shell CLI - Install"
permalink: /install
---

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