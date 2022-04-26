#!/bin/bash
set -uxe

# install project
pip install -e /src/.

# run
python -m pytest --mypy --pylint