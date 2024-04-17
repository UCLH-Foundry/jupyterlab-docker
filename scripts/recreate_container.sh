#!/bin/sh
# recreate_container.sh
#
# Stops, deletes, and recreates the Docker container for the given user.
# Usage:
#   /bin/sh scripts/recreate_container.sh username
#
# -h, --help  Display this help message
# -y, --yes   Ignore all prompts.
#             (WARNING: containers will be removed without asking permission)
#

set -e  # Exit on any error

SKIP_PROMPT=0
USERNAME=


#####################################################################################################
#       Helper functions                                                                            #
#####################################################################################################

source scripts/util.sh

#
# Prints the help message.
#
print_help() {
  echo
  echo "Usage:"
  echo "  /bin/sh recreate_container.sh username [-y|--yes] [-h|--help]"
  echo
  echo "-h, --help        Display this help message."
  echo "-y, --yes         Ignore all prompts."
  echo "                  (WARNING: containers will be removed without asking permission)"
  echo
}

#
# Handles input parameters.
#
# Parameters:
#   args        List of arguments as given to this script.
#
# Usage:
#   process_params "$@"
#
process_params() {
  while (( $# )); do
    case $1 in
      -[y?] | --yes)
        SKIP_PROMPT=1
        ;;

      -[h?] | --help)
        print_help
        exit 0
        ;;

      *)
        if [ "$USERNAME" == "" ]
        then
          USERNAME=$1
        else
          error "Unrecognised parameter \"$1\""
        fi
    esac
    shift
  done
}


#####################################################################################################


# Process parameters and determine actions
process_params "$@"

# Verify at least the username has been given
if [ " $USERNAME " == "  " ]
then
  error "ERROR: Incorrect usage. Please provide a username."
else
  echo
  echo "Username: $USERNAME"
fi

# Warn if prompts will be skipped
if [ $SKIP_PROMPT -eq 1 ]
then
  echo
  echo "WARNING: All prompts will be skipped"
fi


COMPOSE_FILE="users/${USERNAME}.yml"
CONTAINER="criu-jupyterlab-$USERNAME"

echo
echo "----- Stopping container -----"
docker compose -f "$COMPOSE_FILE" stop $USERNAME

echo
echo "----- Deleting container -----"
confirm_and_run \
  "About to delete container $CONTAINER. " \
  docker container rm $CONTAINER

echo
echo "----- Start container -----"
docker compose -f "$COMPOSE_FILE" up -d $USERNAME
