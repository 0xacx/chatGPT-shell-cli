#!/bin/env bash
###############################################################################
# Purpose: The purpose of this script is to simply generate a .deb file.
# Once the .deb file is generated a copy is moved to /tmp.
#
# It can be installed and uninstalled like so:
# $ sudo apt -y install ./chatgpt-shell-cli_0.0.1_all.deb
# $ sudo apt -y remove chatgpt-shell-cli
###############################################################################

# Functions
make_directory() {
    local filepath="$1"
    local shouldRemake=$2

    if [ $shouldRemake -ne 0 ]; then # delete old directory first if desired
        rm -rf "$filepath"
    fi

    mkdir -p "$filepath"
}

add_installation_files() {
    local ABSOLUTE_INSTALL_DIRECTORY="$1"
    local PROGRAM_NAME="$2"
    local ARCHITECTURE="$3"
    local PROGRAM_FILEPATH="${ABSOLUTE_INSTALL_DIRECTORY}/${PROGRAM_NAME,,}"

    # Place the files in the directory based on the architecture
    #curl -sS https://raw.githubusercontent.com/0xacx/chatGPT-shell-cli/main/chatgpt.sh -o "$PROGRAM_FILEPATH"
    cp ../chatgpt.sh "$PROGRAM_FILEPATH"

    # Configure open image command with xdg-open for Linux systems (copied from install.sh)
    if [[ "$OSTYPE" == "linux"* ]] || [[ "$OSTYPE" == "freebsd"* ]]; then
        sed -i 's/open "${image_url}"/xdg-open "${image_url}"/g' "$PROGRAM_FILEPATH"
    fi
}

set_attributes() {
    local STARTING_DIRECTORY="$1"
    local IN_DEB_PROGRAM_NAME="$2"

    find "${STARTING_DIRECTORY}" -type d -exec chmod 0755 {} \; # set all dirs
    find "${STARTING_DIRECTORY}" -type f -exec chmod 0644 {} \; # set all files
    find "${STARTING_DIRECTORY}" -name "${IN_DEB_PROGRAM_NAME}" -type f -exec chmod 0755 {} \; # set executable
    find "${STARTING_DIRECTORY}" -name "postinst" -type f -exec chmod 0755 {} \; # set postinst
}

add_control_file () {
    local CONTROL_FILE="$1"

SECTION="utils"
DEPENDS="curl (>= 7.68), jq (>= 1.6)" # HELPFUL: Use `$ dpkg-query -W -f='${VERSION}\n' depNameHere` to find version info
MAINTAINER="Alwyn \"KeyboardSage\" Berkeley <sagedev@leaflesstree.com>"
HOMEPAGE="https://gptshell.cc"
DESCRIPTION="A simple, lightweight shell script to use OpenAI's chatGPT and
 DALL-E from the terminal without installing python or node.js."
cat << EOF > "$CONTROL_FILE"
Package: $PACKAGE_NAME
Version: $PROGRAM_VERSION
Architecture: $ARCHITECTURES
Section: $SECTION
Essential: no
Priority: optional
Depends: $DEPENDS
Maintainer: $MAINTAINER
Homepage: $HOMEPAGE
Description: $DESCRIPTION
EOF
}

add_postinst_file () {
    local POSTINST="$1"
    ALIAS_NAME="chatgpt.sh"

cat << EOF > "$POSTINST"
#!/bin/env bash

# only continue if the file exists
if [ -f "/usr/bin/${PACKAGE_NAME}" ]; then

echo "File /usr/bin/${PACKAGE_NAME} exists."

    # Make Alias (no sudo, already running as root)
    ln -s /usr/bin/${PACKAGE_NAME} /usr/bin/${ALIAS_NAME}

    # Show user message
    echo "Installed $PACKAGE_NAME script to /usr/bin/${PACKAGE_NAME}"
    echo "The OPENAI_KEY environment variable containing your key is necessary for the script to function."
    echo -e "Add the line below to your shell profile with a valid key:\n"
    echo "export OPENAI_KEY=\"your_key_here\""
    echo -e "\nIf needed, detailed instructions are available:\nhttps://github.com/0xacx/chatGPT-shell-cli/tree/main#manual-installation"

fi

exit 0
EOF
}

# Main
cd `dirname $0` # Run from the directory that stores the script

# Remove the old .debs if there are any
PROGRAM_NAME="chatGPT-shell-cli"
PACKAGE_NAME="${PROGRAM_NAME,,}"
rm -f "${PACKAGE_NAME}*.deb" >/dev/null
sudo rm -f "/tmp/${PACKAGE_NAME}.deb" >/dev/null

# Stage directory
RELATIVE_STAGING_DIR="./debpkgs"
ABSOLUTE_STAGING_DIR=$(readlink --canonicalize "${RELATIVE_STAGING_DIR}")
make_directory "$ABSOLUTE_STAGING_DIR" 1 # remake staging directory

# Architectures
ABSOLUTE_ARCH_DIRECTORIES=()

PROGRAM_VERSION="0.0.1" # No versioning at the moment, 0.0.1 is a placeholder
ARCHITECTURES="all"
for arch in `echo $ARCHITECTURES`; do
    architectureDirectory="${ABSOLUTE_STAGING_DIR}/${PACKAGE_NAME}_${PROGRAM_VERSION}_${arch}"
    make_directory "$architectureDirectory" 0
    ABSOLUTE_ARCH_DIRECTORIES+=("$architectureDirectory")
done

# Installation Directories and Installation Files
INSTALL_DIRECTORIES=("/usr/bin")
for (( i=0; i<${#ABSOLUTE_ARCH_DIRECTORIES[@]}; i++ )); do # For each arch directory...
    for dir in "${INSTALL_DIRECTORIES[@]}"; do
        # Create the install directories needed...
        installDirectory="${ABSOLUTE_ARCH_DIRECTORIES[i]}${dir}"
        make_directory "$installDirectory" 0
        # DEBUG: echo "Architecture directory $((i+1)): ${ABSOLUTE_ARCH_DIRECTORIES[i]} processed and now has $installDirectory"

        # Create the installation file(s) needed based on the install directory
        add_installation_files "$installDirectory" "$PROGRAM_NAME" "${ABSOLUTE_ARCH_DIRECTORIES[i]##*_}"
    done
done

# For each architecture directory make the...
for (( i=0; i<${#ABSOLUTE_ARCH_DIRECTORIES[@]}; i++ )); do
    # ...DEBIAN directory
    ABSOLUTE_DEBIAN_DIR="${ABSOLUTE_ARCH_DIRECTORIES[i]}/DEBIAN"
    make_directory "${ABSOLUTE_DEBIAN_DIR}" 0

    # ...Post installation file
    add_postinst_file "${ABSOLUTE_DEBIAN_DIR}/postinst"

    # ...Control file
    add_control_file "${ABSOLUTE_DEBIAN_DIR}/control"

    # ...then measure the staged size of the package and add that to the control file
    STAGING_SIZE_IN_KB="$(du -s ${ABSOLUTE_ARCH_DIRECTORIES[i]} | awk '{print $1;}')"
    echo "Installed-Size: ${STAGING_SIZE_IN_KB}" >> "${ABSOLUTE_DEBIAN_DIR}/control"
done

# Ensure proper file attributes on all files for all architectures
set_attributes "${ABSOLUTE_STAGING_DIR}" "${PROGRAM_NAME,,}"

# Build
for (( i=0; i<${#ABSOLUTE_ARCH_DIRECTORIES[@]}; i++ )); do
    PROGRAM_ARCH="${ABSOLUTE_ARCH_DIRECTORIES[i]##*_}"
    DEB_FILENAME="${PACKAGE_NAME}_${PROGRAM_VERSION}_${PROGRAM_ARCH}.deb"
    dpkg-deb --root-owner-group --build "${ABSOLUTE_ARCH_DIRECTORIES[i]}" "$DEB_FILENAME"
    chmod 644 "$DEB_FILENAME"
    sudo cp "$DEB_FILENAME" /tmp # Copied to /tmp for testing since apt is not allowed to access /home/*
done