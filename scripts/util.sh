#!/bin/sh
# util.sh
#
# Collection of functions to be included in other bash scripts.
# Usage:
#   source "util.sh"
#


#
# (NOTE: Redefine in your main script)
#
# Prints the help message.
#
print_help() {
  echo "REDEFINE THIS FUNCTION IN YOUR MAIN SCRIPT"
}


#
# (NOTE: Redefine in your main script)
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
      -[h?] | --help)
        print_help
        exit 0
        ;;

      *)
        error "Unrecognised parameter \"$1\""
    esac
    shift
  done
}


#
# Prints an error followed by the help.
#
# Parameters:
#   message    Error message to display.
#
# Usage:
#   error "Something bad happened."
#
error() {
  echo
  1>&2 echo "$@"
  print_help
  exit 1
}


#
# Helper to wait for confirmation.
#
# Parameters:
#   message     Message to display before awaiting confirmation.
#
# Usage:
#   See "confirm_or_abort" below.
#
await_confirmation() {
  local YES_OPTIONS=("y" "Y" "yes" "YES")
  local CONTINUE_YN=

  if [ $SKIP_PROMPT -eq 1 ]
  then
    echo "true"
    return
  fi

  if [ " $1 " == "  " ]
  then
    MSG="Continue? (y/N): "
  else
    MSG="$1 Continue? (y/N): "
  fi

  read -p "$MSG" CONTINUE_YN

  if [[ " ${YES_OPTIONS[@]} " =~ " ${CONTINUE_YN} " ]]
  then
    echo "true"
  fi
}


#
# Awaits confirmation and exits the process if not confirmed.
#
# Parameters:
#   message     Message to display before awaiting confirmation.
#
# Usage:
#   confirm_or_abort "Dangerous action X is about to be performed."
#
confirm_or_abort() {
  local CONTINUE_YN=$(await_confirmation "$1")
  if ! [ $CONTINUE_YN ]
  then
    echo "Aborted"
    exit 0
  fi
}


#
# Awaits confirmation and executes the command if confirmed, otherwise skips the command.
#
# Parameters:
#   message     Message to display before awaiting confirmation.
#   command     Command with parameters to execute if confirmed.
#
# Usage:
#   confirm_and_run "About to execute X" process_x param1 param2
#
confirm_and_run() {
  if [ $# -lt 2 ]
  then
    echo "Bad call. Expected at least two parameters, but received $# instead."
    return
  fi

  local CONTINUE_YN=$(await_confirmation "$1")
  if [ $CONTINUE_YN ]
  then
    shift
    eval $@
  else
    echo "Skipped"
  fi
}
