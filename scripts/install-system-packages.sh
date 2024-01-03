set -ex

# Install system packages
apt-get update
apt-get install -y --no-install-recommends apt-utils ca-certificates gosu sudo git curl tree texlive texlive-latex-extra texlive-fonts-recommended dvipng
apt-get install -y --no-install-recommends rustc
curl https://sh.rustup.rs -sSf | sh -s -- -y
source "$HOME/.cargo/env"
rm -rf /var/lib/apt/lists/*
