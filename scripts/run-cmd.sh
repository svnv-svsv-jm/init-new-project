#!/bin/bash
set -uxe

# install project
pip install -e /src/.

# run
${1}