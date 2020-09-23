# THINGS YOU NEED TO HAVE INSTALLED LOCALLY:
  1. jq - this is a json parser. Can be installed on Mac using 'brew install jq'
  2. ffmpeg
  3. docker

# THINGS TO EXPORT LOCALLY TO ENSURE STABLE LOCALSTACK CREATION:
  1. $HOME_DIR_LAMBDAS - root directory for all lambda code you have locally]
  2. $DEV_API_ID - ID for API Gateway stage you want to mimic. This is the serial which is part of the url.
  3. $AWS_ACCESS_KEY
  4. $AWS_SECRET_KEY
  5. $AWS_REGION

# For watching logs coming out of localstack:
docker logs -f localstack

# SETUP LocalStack
./localstack.sh setup

# RUN LocalStack
./localstack.sh

# RESTART LocalStack
./localstack.sh restart

# STOP/DELETE LocalStack
./localstack.sh stop

# Cloud9/EC2 Ubuntu installation requirements
./setup_ubuntu_dependencies.sh

# Update running lambda code
./update_lambda.sh <lambda_name>

# To ensure all relevant lambda repos are cloned and up-to-date on master
./setup_repos.sh

___        ______     ____ _                 _  ___  
/ \ \      / / ___|   / ___| | ___  _   _  __| |/ _ \
/ _ \ \ /\ / /\___ \  | |   | |/ _ \| | | |/ _` | (_) |
/ ___ \ V  V /  ___) | | |___| | (_) | |_| | (_| |\__, |
/_/   \_\_/\_/  |____/   \____|_|\___/ \__,_|\__,_|  /_/
-----------------------------------------------------------------
CLOUD9 Readme For running on an EC2 Instance

PR TEAM LOCALSTACK README

Instance shuts down after 30 mins latency (this can be changed!)
Instance already has Ubuntu dependencies installed.
These include:
- docker
- docker-compose
- jq
- ffmpeg
- imagemagick
- nvm, npm, node 8.10
- redis

Redis server is running and starts up on reboot of EC2 instance.

Dependencies were installed using `./setup_ubuntu_dependencies.sh`,
in the localstack folder.These don't need to be run again unless you
need a new EC2 instance.

#SETUP

Go to localstack folder.
Run `./local_repos.sh setup` to git clone and setup repos listed in bash script.
Git credentials store manager is already active and contains secured access tokens
to the current repos.

In the artifactory dependencies folder, in order to update all repos
with private repos, here is where you can drop lib-recognition, lib-models
and express-middleware recognition. When you run `./local_repos.sh setup` these
are copied into each repo and overwrite what is in the package.json file.

This ensure the ability to npm install without the need for a VPN.

You can change versions of all 3 repos in `local_repos.sh` at the top.

#RUN

`./localstack setup`. This will setup currently API Gateway, SQS and Lambda mocks
only. It will take all the code of all the repos cloned into Cloud9 and use
their code to setup the lambdas.

After this the `~/.bashrc` file is updated with the env var
`LOCALSTACK` that is then used by `frontend-video-search` to point
to the mock API Gateway setup by Localstack.

Then by running `npm start` you can go through the app and use the
skeleton integration pipeline setup by localstack that hosts our AWS services.

Currently non-mocked services like DynamoDB are called remotely
to ensure the service can run end-to-end successfully.
