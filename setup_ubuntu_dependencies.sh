#!/bin/bash

# add $AWS_SECRET_KEY, $AWS_ACCESS_KEY, $AWS_REGION, $NPM_AUTH_USERNAME, $NPM_AUTH_TOKEN to ~/.bashrc
git config --global credential.helper store

sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo systemctl enable redis-server.service
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.1/install.sh | bash
pip install awscli-local

sudo apt-get install redis-server
sudo apt-get install jq
sudo apt-get install docker
sudo apt install imagemagick
sudo apt install ffmpeg

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 8.10
nvm use 8.10
nvm uninstall 10.17.0
nvm alias default 8.10
