#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install zsh on debian-based systems and Fedora-based systems
if command_exists apt; then
    echo "Installing zsh using apt..."
    sudo apt update && sudo apt install -y zsh
elif command_exists dnf; then
    echo "Installing zsh using dnf..."
    sudo dnf install -y zsh
else
    echo "Package manager not found. Please install zsh manually."
    exit 1
fi

# Install oh-my-zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "oh-my-zsh is already installed."
fi

# Move oh-my-zsh files if they are found in the current directory
if [ -f "$HOME/zshrc" ]; then
    echo "Moving zshrc configuration..."
    mv -n zshrc ~/.zshrc
else
    echo "zshrc configuration not found."
fi

if [ -d "$HOME/oh-my-zsh" ]; then
    echo "Moving oh-my-zsh directory..."
    mv -n oh-my-zsh ~/.oh-my-zsh
else
    echo "oh-my-zsh directory not found."
fi

# Install neovim on debian-based systems and Fedora-based systems
if command_exists apt; then
    echo "Installing neovim using apt..."
    sudo apt update && sudo apt install -y neovim
elif command_exists dnf; then
    echo "Installing neovim using dnf..."
    sudo dnf install -y neovim
else
    echo "Package manager not found. Please install neovim manually."
    exit 1
fi

# Check if git and curl are installed
if ! command_exists git; then
    echo "Git is required to install packer. Installing git..."
    if command_exists apt; then
        sudo apt install -y git
    elif command_exists dnf; then
        sudo dnf install -y git
    else
        echo "Package manager not found. Please install git manually."
        exit 1
    fi
fi

if ! command_exists curl; then
    echo "Curl is required to download resources. Installing curl..."
    if command_exists apt; then
        sudo apt install -y curl
    elif command_exists dnf; then
        sudo dnf install -y curl
    else
        echo "Package manager not found. Please install curl manually."
        exit 1
    fi
fi

# Install Packer for Neovim
if [ ! -d "$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim" ]; then
    echo "Cloning packer.nvim..."
    git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
else
    echo "packer.nvim is already installed."
fi

# Move the init.vim file to the correct location
if [ -f "$HOME/nvim" ]; then
    echo "Moving nvim configuration..."
    mv -n nvim ~/.config/
else
    echo "nvim configuration not found."
fi

echo "Installation completed successfully!"

