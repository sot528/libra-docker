#!/bin/bash
# This script sets up the environment for the Libra build by installing necessary dependencies.
#
# Usage ./dev_setup.sh <options>
#   v - verbose, print all statements

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$SCRIPT_PATH/.."

set -e
OPTIONS="$1"

if [[ $OPTIONS == *"v"* ]]; then
	set -x
fi

if [ ! -f Cargo.toml ]; then
	echo "Unknown location. Please run this from the libra repository. Abort."
	exit 1
fi

PACKAGE_MANAGER=
if [[ "$OSTYPE" == "linux-gnu" ]]; then
	if which yum &>/dev/null; then
		PACKAGE_MANAGER="yum"
	elif which apt-get &>/dev/null; then
		PACKAGE_MANAGER="apt-get"
	else
		echo "Unable to find supported package manager (yum or apt-get). Abort"
		exit 1
	fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
	if which brew &>/dev/null; then
		PACKAGE_MANAGER="brew"
	else
		echo "Missing package manager Homebrew (https://brew.sh/). Abort"
		exit 1
	fi
else
	echo "Unknown OS. Abort."
	exit 1
fi

cat <<EOF
Welcome to Libra!

This script will download and install the necessary dependencies needed to
build Libra Core. This includes:
	* Rust (and the necessary components, e.g. rust-fmt, clippy)
	* CMake, protobuf, go (for building protobuf)

If you'd prefer to install these dependencies yourself, please exit this script
now with Ctrl-C.

EOF

printf "Proceed with installing necessary dependencies? (y) > "
#read -e input
input=y
if [[ "$input" != "y"* ]]; then
	echo "Exiting..."
	exit 0
fi

# Install Rust
echo "Installing Rust......"
if rustup --version &>/dev/null; then
	echo "Rust is already installed"
else
	curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain stable
	CARGO_ENV="$HOME/.cargo/env"
	source "$CARGO_ENV"
fi

# Run update in order to download and install the checked in toolchain
rustup update

# Add all the components that we need
rustup component add rustfmt
rustup component add clippy

echo "Installing CMake......"
if which cmake &>/dev/null; then
  echo "CMake is already installed"
else
	if [[ "$PACKAGE_MANAGER" == "yum" ]]; then
		sudo yum install cmake
	elif [[ "$PACKAGE_MANAGER" == "apt-get" ]]; then
		sudo apt-get install cmake
	elif [[ "$PACKAGE_MANAGER" == "brew" ]]; then
		brew install cmake
	fi
fi

echo "Installing Go......"
if which go &>/dev/null; then
  echo "Go is already installed"
else
	if [[ "$PACKAGE_MANAGER" == "yum" ]]; then
		sudo yum install golang
	elif [[ "$PACKAGE_MANAGER" == "apt-get" ]]; then
		sudo apt-get install golang
	elif [[ "$PACKAGE_MANAGER" == "brew" ]]; then
		brew install go
	fi
fi

echo "Installing Protobuf......"
if which protoc &>/dev/null; then
  echo "Protobuf is already installed"
else
	if [[ "$PACKAGE_MANAGER" == "yum" ]]; then
		sudo yum install protobuf
	elif [[ "$PACKAGE_MANAGER" == "apt-get" ]]; then
		sudo apt-get install protobuf-compiler
	elif [[ "$PACKAGE_MANAGER" == "brew" ]]; then
		brew install protobuf
	fi
fi


