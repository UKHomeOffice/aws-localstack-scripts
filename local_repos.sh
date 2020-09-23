#!/bin/bash

Cloud9=$CLOUD9

PROJECT='<project_name>'
GITLAB_DOMAIN='e.g. github.com'
PRIVATE_DEP_NAME='e.g. lib-middleware'
PRIVATE_DEP_VERSION='eg. 1.4.3'
# repos for local setup
REPOS=(
  'example repo 1'
  'example repo 2'
  'example repo 3'
)

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm use 8.10

cd ..

if [ "$1" == 'setup' ]
  then
    for repo in "${REPOS[@]}"
    do
      git clone https://$GITLAB_DOMAIN/$PROJECT/$repo
      cd $repo
      if [ "${Cloud9}" ]
        then
          # IF USING PRIVATE DEPENDENCIES
          # sed -i '' -e "s|${PRIVATE_DEP_NAME}.*\"|${PRIVATE_DEP_NAME}\": \"${PRIVATE_DEP_VERSION}\"|g" package.json
          mkdir node_modules
          rm package-lock.json
          cp -r ../localstack/artifactory_dependencies/* node_modules/
      fi
      npm i
      cd ..
    done
elif [ "$1" == 'update' ]
  then
    if [ -z "$2" ]
      then
        for repo in "${REPOS[@]}"
        do
          cd $repo
          git pull --rebase origin master:master
          npm i
          cd ..
        done
    else
      cd $2
      git pull --rebase origin master:master
      npm i
      cd ..
    fi
elif [ "$1" == 'add' ]
  then
    git clone https://$GITLAB_DOMAIN/$PROJECT/$2
    cd $repo
    if [ "${Cloud9}" ]
      then
        # IF USING PRIVATE DEPENDENCIES
        # sed -i '' -e "s|${PRIVATE_DEP_NAME}.*\"|${PRIVATE_DEP_NAME}\": \"${PRIVATE_DEP_VERSION}\"|g" package.json
        mkdir node_modules
        rm package-lock.json
        cp -r ../localstack/artifactory_dependencies/* node_modules/
    fi
    npm i
    cd ..
fi
