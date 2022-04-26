#!/bin/bash
set -ux

# Add local user: either use the LOCAL_USER_ID if passed in at runtime or fallback
USER_ID=${LOCAL_USER_ID:-9001}

echo "Starting with UID: $USER_ID"
useradd --shell /bin/bash -u $USER_ID -o -c "" -m user
export HOME=/home/user

sudo -H -u user bash -c 'echo "Running as USER=$USER, with UID=$UID"; python -m pip install -e /src/.'
sudo chown user -R /src
umask 022
exec gosu user "$@"