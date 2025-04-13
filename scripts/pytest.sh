#!/bin/bash
set -ex

PYTHON="${PYTHON:=$(which python)}"

echo "Using ${PYTHON}"

mkdir -p logs

$PYTHON -m mypy test
$PYTHON -m pytest -x --testmon --pylint --cov-fail-under 95
$PYTHON -m pytest -x --testmon --nbmake --overwrite "./examples"
