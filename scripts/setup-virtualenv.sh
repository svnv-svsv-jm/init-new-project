set -ex

# Install Python dependencies
pip install virtualenv
virtualenv "/$PROJECT_NAME"
source "/$PROJECT_NAME/bin/activate"
make install
cp poetry.lock /tmp/.
rm -r /root/.cache

# Avoid permission problems: this is where the virtual env is installed in the image
chmod -R 777 "/$PROJECT_NAME"