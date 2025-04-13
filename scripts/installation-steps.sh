set -ex

# Install system packages
bash scripts/install-system-packages.sh

# For debugging
tree .

# Install Python dependencies
bash scripts/setup-virtualenv.sh
