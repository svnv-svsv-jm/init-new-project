#!/bin/bash
set -ex

PYTHON="${PYTHON:=$(which python)}"

mkdir -p logs

$PYTHON -m pytest -x --testmon --nbmake --overwrite "./examples"
$PYTHON -m mypy test
$PYTHON -m pytest -x --testmon --pylint --cov-fail-under 98
