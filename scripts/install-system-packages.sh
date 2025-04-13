set -ex

# AWS
mkdir -p ~/.aws
cp -r ecoplant/config ~/.aws/.
cp ./scripts/credentials.sh /tmp/credentials.sh

# Install system packages
apt-get update
apt-get install -y --no-install-recommends apt-utils ca-certificates make gosu sudo git curl tree python3-sphinx jq vim
curl -fsSL https://just.systems/install.sh | bash -s -- --to /usr/local/bin
rm -rf /var/lib/apt/lists/*