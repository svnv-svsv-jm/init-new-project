set -ex

# Install system packages
apt-get update
apt-get install -y --no-install-recommends apt-utils ca-certificates gosu sudo git rustc curl tree texlive texlive-latex-extra texlive-fonts-recommended dvipng
curl https://sh.rustup.rs -sSf | sh -s -- -y
source "$HOME/.cargo/env"
rm -rf /var/lib/apt/lists/*

# For debugging
tree .

# Install Python dependencies
pip install virtualenv
virtualenv "/$PROJECT_NAME"
source "/$PROJECT_NAME/bin/activate"
make install
cp poetry.lock /tmp/.
rm -r /root/.cache

# Avoid permission problems: this is where the virtual env is installed in the image
chmod -R 777 "/$PROJECT_NAME"