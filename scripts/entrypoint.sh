#!/bin/bash
# This script is supposed to be run in the Docker image of the project

set -ex

# Add local user: either use the LOCAL_USER_ID if passed in at runtime or fallback
# export $(grep -v '^#' .env | xargs)
DEFAULT_USER=$(whoami)
DEFAULT_ID=$(id -u)
echo "DEFAULT_USER=${DEFAULT_USER}"
USER="${LOCAL_USER:${DEFAULT_USER}}"
USER_ID="${LOCAL_USER_ID:${DEFAULT_ID}}"

echo "USER: $USER -- UID: $USER_ID"
# umask 022 # by default, all newly created files have open permissions
VENV=/new-project
ACTIVATE="source $VENV/bin/activate"
INSTALL_PROJECT="$ACTIVATE && poetry install || echo 'skipped installation'"

# If $USER is empty, pretend to be root
if [[ $USER = "" ]] || [[ -z $USER ]]; then
    USER="$DEFAULT_USER"
    USER_ID="$DEFAULT_ID"
fi

# Check who we are and based on that decide what to do
if [[ $USER = "root" ]]; then
    # If root, just install
    bash -c "$INSTALL_PROJECT"
else
    # If not root, create user and give them root powers
    useradd --shell /bin/bash -u $USER_ID -o -c "" -m $USER
    sudo -H -u $USER bash -c 'echo "Running as USER=$USER, with UID=$UID"'
    sudo -H -u $USER bash -c "echo \"$ACTIVATE\" >> \$HOME/.bashrc"
    sudo -H -u $USER bash -c "$INSTALL_PROJECT"
fi

exec gosu $USER "$@"
