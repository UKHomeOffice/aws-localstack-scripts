#!/bin/bash

# Env vars
home_directory=$HOME_DIR_LAMBDAS

if [ -z "$home_directory" ]
  then
    printf 'Please follow the following instructions.$HOME_DIR_LAMBDAS can be set as an alternative. Set it then rerun this script.\n\n'
    printf "Is this repo folder in the root directory with all your lambda code? (y/n) : "
    read in_root

    while [ "$in_root" != "n" ] && [ "$in_root" != "y" ]
    do
      printf "Please enter 'y' or 'n'. Try again!\n"
      printf "Are you currently in the root directory for all your lambda code? (y/n) : "
      read in_root
    done
fi

if [ "$in_root" = "y" ]
  then
    home_directory="$(dirname "$PWD")"
else
  while [ -z "$home_directory" ]
  do
    echo "Please input absolute path for root directory of all lambda functions..."
    printf "( e.g. /Users/<user>/Documents/<project_name> )\n\n"
    printf "--> "
    read -r home_directory

    if [ -z "$home_directory" ]
      then
        printf "Nothing was input. Please try again!\n\n"
    fi
  done
fi

for lambda in "$@"
do
  ./lib/create-lambda.sh $lambda $STAGE_NAME $LAMBDA_RUNTIME $home_directory
done
