#!/bin/bash
set -ex

PYTHON="${PYTHON:=$(which python)}"

mkdir -p logs

$PYTHON -m pytest -x --testmon --mypy --pylint --all
$PYTHON -m pytest -x --testmon --nbmake --overwrite "./examples"
