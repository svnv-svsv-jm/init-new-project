set -ex

PIP="${PIP:=python -m pip}"

echo "Using pip=${PIP}"

# Install Python dependencies
$PIP install --upgrade pip
$PIP install uv
just install
rm -r /root/.cache
