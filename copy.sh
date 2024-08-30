#!/bin/bash

cp -r ~/.config/nvim/* ./nvim
cp ~/.zshrc ./.zshrc
cp ~/.oh-my-zsh/* ./.oh-my-zsh


git add .
git commit -m "update"
git push
