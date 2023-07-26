help:
	@cat Makefile

.EXPORT_ALL_VARIABLES:

# create an .env file to override the default settings
-include .env
export $(shell sed 's/=.*//' .env)


.PHONY: build docs

# ----------------
# default settings
# ----------------
# user
LOCAL_USER:=$(shell whoami)
LOCAL_USER_ID:=$(shell id -u)
# project
PROJECT_NAME:=new-project
# python
PYTHON?=python
PYTHON_EXEC?=python -m
PYTHONVERSION?=3.8.13
PYTEST?=pytest
SYSTEM=$(shell python -c "import sys; print(sys.platform)")
PYTESTSRC=$(PYTEST) --testmon --mypy --pylint --all
PYTESTNB=$(PYTEST) --testmon --nbmake --overwrite "./examples"
# poetry
PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring
POETRY=poetry
# hydra
HYDRA_FULL_ERROR=1
# docker
DOCKER?=docker
DOCKERFILE?=docker/python-310/Dockerfile
DOCKER_BUILD_MULTIPLATFORM=docker buildx build --platform linux/amd64,linux/arm64
REGISTRY=registry.euranova.eu/rd/bishop
MEMORY=8g
SHM=4g
CPUS=1
DOCKER_COMMON_FLAGS=--cpus=$(CPUS) --memory=$(MEMORY) --shm-size=$(SHM) --network=host --volume $(PWD):/workdir -e LOCAL_USER_ID -e LOCAL_USER -e HYDRA_FULL_ERROR
IMAGE=$(REGISTRY)/$(PROJECT_NAME)
IMAGE_PYTHON=/$(PROJECT_NAME)/bin/python
CUDA_DEVICE=1
BUILD_CMD=$(DOCKER) build -t $(REGISTRY)/$(PROJECT_NAME) --build-arg project_name=$(PROJECT_NAME) -f $(DOCKERFILE) .
CONTAINER_TAG=b2p
# You can set these variables from the command line, and also from the environment for the first two
SPHINXOPTS?=
SPHINXBUILD?=sphinx-build
SOURCEDIR=docs
BUILDDIR=$(SOURCEDIR)/_build

# -----------
# utilities
# -----------
size:
	du -hs * | sort -rh | head -10

system:
	@echo $(SYSTEM)

check-port: PORT=6006
check-port:
	lsof -i :$(PORT)

# -----------
# init
# -----------
install-pyenv:
	curl https://pyenv.run | bash

# correct python version and virtualenv using pyenv
python-install:
	pyenv install $(PYTHONVERSION)

virtualenv:
	pyenv virtualenv-delete $(PROJECT_NAME) || echo "no virtual env found, creating..."
	pyenv virtualenv $(PYTHONVERSION) $(PROJECT_NAME)

activate:
	pyenv shell $(PROJECT_NAME)

init: python-install virtualenv activate

# -----------
# install project's dependencies
# -----------
# dev dependencies
install-init:
	$(PYTHON_EXEC) pip install --upgrade pip
	$(PYTHON_EXEC) pip install --upgrade setuptools virtualenv

# delete poetry's cache
delete-poetry-cache:
	$(PYTHON_EXEC) $(POETRY) cache clear PyPI --all
	$(PYTHON_EXEC) $(POETRY) cache clear _default_cache --all

# install main dependencies with poetry (dynamic installation)
install-w-poetry:
	$(PYTHON_EXEC) pip install --upgrade poetry
	$(PYTHON_EXEC) $(POETRY) install --no-cache

poetry-lock:
	nohup poetry lock 2>&1 > logs/poetry-lock.log &

poetry-add: PACK=
poetry-add:
	PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring $(PYTHON_EXEC) poetry add $(PACK)

# install main dependencies with pip (static installation)
install-w-pip:
	$(PYTHON_EXEC) pip install -r requirements.txt --upgrade --force-reinstall --no-cache

# these need manual installation
install-manual-pkgs:
	bash scripts/install-pyg.sh

# for dynamic installation: export frozen env
install-export-poetry:
	$(PYTHON_EXEC) $(POETRY) export --without-hashes --format=requirements.txt --output frozen-env.txt || echo "could not export frozen environment..."

# for dynamic installation: export frozen env
install-export-pip:
	$(PYTHON_EXEC) pip freeze > frozen-env.txt || echo "Could not export frozen environment..."

# install current project
install-project:
	$(PYTHON_EXEC) pip install -e .

# MAIN: w poetry (dynamic): install dev deps, then main deps, export frozen, then project
poetry-install: install-init
poetry-install: install-w-poetry
poetry-install: install-manual-pkgs
poetry-install: install-project

# MAIN: w pip (static): install dev deps, then main deps, then project
pip-install: install-init
pip-install: install-w-pip
pip-install: install-manual-pkgs
pip-install: install-project

# MAIN: default installation method
install: poetry-install

install-nohup:
	mkdir -p logs || echo "Folder already exists."
	nohup make install 2>&1 > logs/install.log &

# Update
update-util: PACK=
update-util:
	PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring $(PYTHON_EXEC) $(POETRY) update $(PACK)
update: update-util install

# -----------
# testing
# -----------
# mypy
mypy:
	$(PYTHON_EXEC) mypy test

# pytest: -n auto for parallel
pytest-src:
	$(PYTESTSRC)

pytest-nb:
	$(PYTESTNB)

pytest: pytest-src pytest-nb

pytest-nohup:
	mkdir -p logs || echo "Folder already exists."
	nohup $(PYTESTSRC) 2>&1 > logs/pytest.log &

# -----------
# git
# -----------
# push to latest and back to develop
publish:
	git checkout develop
	git pull
	git checkout latest
	git pull
	git merge develop
	git push
	git checkout develop

# delete all local branches that do not have a remote counterpart
git-clean:
	git remote prune origin
	git branch -r | awk '{print $$1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $$1}' | xargs git branch -D

# squash all commits before rebasing, see https://stackoverflow.com/questions/25356810/git-how-to-squash-all-commits-on-branch
git-squash:
	git reset $(git merge-base main $(git branch --show-current))
	git add -A
	git commit -m "squashed commit"

# -----------
# M1
# -----------
check-m1:
	@echo CFLAGS=${CFLAGS}
	@echo LDFLAGS=${LDFLAGS}
	@echo OPENBLAS=${OPENBLAS}
	$(PYTHON_EXEC) python -c 'import torch; print(torch.backends.mps.is_available())'
	$(PYTHON_EXEC) python -c 'import platform; print(platform.processor(), platform.system(), platform.architecture())'
	$(PYTHON_EXEC) python -c 'import pytorch_lightning as pl; trainer = pl.Trainer(accelerator="mps")'

# -----------
# docker
# -----------
# build project's image
build: DOCKER_HOST= 
build:
	$(BUILD_CMD)

build-multiplatform: DOCKER_HOST= 
build-multiplatform: BUILD_CMD=$(DOCKER_BUILD_MULTIPLATFORM) -t $(REGISTRY)/$(PROJECT_NAME) --build-arg project_name=$(PROJECT_NAME) -f $(DOCKERFILE) .
build-multiplatform:
	$(BUILD_CMD)

build-nohup: DOCKER_HOST= 
build-nohup:
	mkdir -p logs || echo "Folder already exists."
	nohup $(BUILD_CMD) 2>&1 > logs/build-$(shell echo "$(DOCKERFILE)" | tr "/" "-").log &

tag:
	$(DOCKER) image tag $(PROJECT_NAME):latest $(REGISTRY)/$(PROJECT_NAME):latest

push: DOCKER_HOST= 
push:
	echo $(CI_JOB_TOKEN) | $(DOCKER) login -u $(LOCAL_USER) $(REGISTRY) --password-stdin
	$(DOCKER) image push $(REGISTRY)/$(PROJECT_NAME):latest

push-nohup:
	nohup make push 2>&1 > logs/push.log &

pull: DOCKER_HOST= 
pull:
	echo $(CI_JOB_TOKEN) | $(DOCKER) login -u $(LOCAL_USER) $(REGISTRY) --password-stdin
	$(DOCKER) pull $(REGISTRY)/$(PROJECT_NAME):latest

# run pytest within a container
docker-pytest: DOCKER_HOST= 
docker-pytest: DOCKER_FLAGS= 
docker-pytest:
	$(DOCKER) run --rm -d $(DOCKER_FLAGS) \
		--name $(PROJECT_NAME)-pytest \
		$(DOCKER_COMMON_FLAGS) \
		-t $(REGISTRY)/$(PROJECT_NAME) bash scripts/pytest.sh

ci-cd: build docker-pytest

# launch dev container
dev-container: DOCKER_HOST= 
dev-container:
	$(DOCKER) run --rm -d $(DOCKER_COMMON_FLAGS) \
		--name $(PROJECT_NAME)-dev \
		-t $(REGISTRY)/$(PROJECT_NAME) bash

# launch bash session within a container
bash: DOCKER_HOST= 
bash:
	$(DOCKER) run --rm -it $(DOCKER_COMMON_FLAGS) \
		--name $(PROJECT_NAME)-bash \
		-t $(REGISTRY)/$(PROJECT_NAME) bash


bash-gpu: DOCKER_HOST= 
bash-gpu:
	$(DOCKER) run --rm -it $(DOCKER_COMMON_FLAGS) \
		$(GPU_FLAGS) \
		--name $(PROJECT_NAME)-bash \
		-t $(REGISTRY)/$(PROJECT_NAME) bash

# launch python session within a container
docker-python: DOCKER_HOST= 
docker-python:
	$(DOCKER) run --rm -it $(DOCKER_COMMON_FLAGS) \
		--name $(PROJECT_NAME)-pytest \
		-t $(REGISTRY)/$(PROJECT_NAME) $(IMAGE_PYTHON)

# [DO NOT CALL THIS COMMAND]
run-base: CONFIG=
run-base: RANDOM=$(shell bash -c 'echo $$RANDOM')
run-base: CONTAINER_NAME=run-$(CONFIG)-$(RANDOM)
run-base: SCRIPT=experiments/main.py
run-base: PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512
run-base: DOCKER_FLAGS=
run-base: OVERRIDE=
run-base: NOW=$(shell date '+%Y-%m-%d_%H:%M:%S')
run-base: CMD=$(IMAGE_PYTHON) -u /workdir/$(SCRIPT) --config-name $(CONFIG) $(OVERRIDE)
run-base:
	$(DOCKER) run --rm -it $(DOCKER_FLAGS) $(DOCKER_COMMON_FLAGS) \
		$(GPU_FLAGS) \
		--name $(PROJECT_NAME)-$(CONTAINER_NAME) \
		-t $(REGISTRY)/$(PROJECT_NAME) \
		$(CMD)

# $(IMAGE_PYTHON) -u $(SCRIPT) --config-name $(CONFIG) $(OVERRIDE)

# run: locally
run: DOCKER_HOST= 
run: run-base

# run-gpu: GPU_FLAGS=--runtime=nvidia --gpus all
# run-gpu: GPU_FLAGS=--runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=1
# run-gpu: GPU_FLAGS=--runtime=nvidia -e CUDA_VISIBLE_DEVICES=1
run-gpu: GPU_FLAGS=--runtime=nvidia --gpus '"device=$(CUDA_DEVICE)"'
run-gpu: run-base

# [DO NOT CALL THIS COMMAND]
run-gmace-base: CONFIG=gmace.yaml
run-gmace-base: RANDOM=$(shell bash -c 'echo $$RANDOM')
run-gmace-base: CONTAINER_NAME=run-$(CONFIG)-$(RANDOM)
run-gmace-base: SCRIPT=experiments/gmace.py
run-gmace-base: PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512
run-gmace-base: DOCKER_FLAGS=
run-gmace-base: OVERRIDE=
run-gmace-base: NOW=$(shell date '+%Y-%m-%d_%H:%M:%S')
run-gmace-base: CMD=$(IMAGE_PYTHON) -u /workdir/$(SCRIPT) --config-name $(CONFIG) $(OVERRIDE)
run-gmace-base:
	$(DOCKER) run --rm -it $(DOCKER_FLAGS) $(DOCKER_COMMON_FLAGS) \
		$(GPU_FLAGS) \
		--name $(PROJECT_NAME)-$(CONTAINER_NAME) \
		-t $(REGISTRY)/$(PROJECT_NAME) \
		$(CMD)

run-gmace: DOCKER_HOST= 
run-gmace: run-gmace-base

run-gmace-gpu: GPU_FLAGS=--runtime=nvidia --gpus '"device=$(CUDA_DEVICE)"'
run-gmace-gpu: run-gmace-base

parity-plots: RANDOM=$(shell bash -c 'echo $$RANDOM')
parity-plots: CONTAINER_NAME=run-parity-plots-$(RANDOM)
parity-plots: SCRIPT=scripts/parity_plots.py
parity-plots: PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512
parity-plots: DOCKER_FLAGS=
parity-plots: OVERRIDE=
parity-plots: CMD=$(IMAGE_PYTHON) -u /workdir/$(SCRIPT)
parity-plots:
	$(DOCKER) run --rm -it $(DOCKER_FLAGS) $(DOCKER_COMMON_FLAGS) \
		$(GPU_FLAGS) \
		--name $(PROJECT_NAME)-$(CONTAINER_NAME) \
		-t $(REGISTRY)/$(PROJECT_NAME) \
		$(CMD)

nndr-plots: RANDOM=$(shell bash -c 'echo $$RANDOM')
nndr-plots: CONTAINER_NAME=run-nndr-plots-$(RANDOM)
nndr-plots: SCRIPT=scripts/nndr.py
nndr-plots: PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512
nndr-plots: DOCKER_FLAGS=
nndr-plots: CMD_FLAGS=
nndr-plots: CMD=$(IMAGE_PYTHON) -u /workdir/$(SCRIPT) $(CMD_FLAGS)
nndr-plots:
	$(DOCKER) run --rm -it $(DOCKER_FLAGS) $(DOCKER_COMMON_FLAGS) \
		$(GPU_FLAGS) \
		--name $(PROJECT_NAME)-$(CONTAINER_NAME) \
		-t $(REGISTRY)/$(PROJECT_NAME) \
		$(CMD)

nndr-plots-gpu: GPU_FLAGS=--runtime=nvidia --gpus '"device=$(CUDA_DEVICE)"'
nndr-plots-gpu: nndr-plots

# run: will run remotely if the DOCKER_HOST variable is set correctly
# TODO: https://stackoverflow.com/questions/51305537/how-can-i-mount-a-volume-of-files-to-a-remote-docker-daemon
run-remote:
	$(DOCKER) volume create data-volume
	$(DOCKER) rm helper || echo "Container may not exist"
	$(DOCKER) create -v data-volume:/workdir --name helper busybox true
	$(DOCKER) cp $(PWD)/src helper:/workdir/src
	$(DOCKER) cp $(PWD)/scripts helper:/workdir/scripts
	$(DOCKER) cp $(PWD)/experiments helper:/workdir/experiments
	$(DOCKER) cp $(PWD)/configs helper:/workdir/configs
	$(DOCKER) rm helper
	$(DOCKER) run --rm -it -d \
		--network=host --volume data-volume:/workdir -e LOCAL_USER_ID -e LOCAL_USER \
		--name $(PROJECT_NAME)-train-$(CONTAINER_NAME) \
		-t $(REGISTRY)/$(PROJECT_NAME) \
		$(IMAGE_PYTHON) -u $(SCRIPT) --config-name $(CONFIG) $(OVERRIDE)

# check your docker information
docker-info:
	DOCKER_HOST=$(DOCKER_HOST) $(DOCKER) info

# Docker-compose: launch a jupyter notebook and tensorboard service
up: DOCKER_HOST= 
up: PORT_JUPY=8889 # Original 8888
up: PORT_TB=6007 # Original 6006
up: PORT_MLFLOW=5003 # Original 5002
up: UNIQUE=$(LOCAL_USER)-$(shell bash -c 'echo $$RANDOM')
up:
	mkdir -p ./logs
	echo $(PROJECT_NAME)-$(UNIQUE) > ./logs/up.log 
	$(DOCKER)-compose -p $(PROJECT_NAME)-$(UNIQUE) up -d

# tear down the notebook and tensorboard
down: DOCKER_HOST= 
down: docker-compose.yml
	$(DOCKER)-compose -p $(shell cat logs/up.log) down --volumes

# Tensorboard
tensorboard: DOCKER_HOST= 
tensorboard: PORT_TB=6006
tensorboard: CONTAINER_NAME=$(shell bash -c 'echo $$RANDOM')
tensorboard: CMD=tensorboard --logdir=lightning_logs --port=6006 --host 0.0.0.0
tensorboard: DOCKER_FLAGS= 
tensorboard:
	$(DOCKER) run --rm -it $(DOCKER_FLAGS) $(DOCKER_COMMON_FLAGS) \
		--name $(PROJECT_NAME)-tensorboard-$(CONTAINER_NAME) \
		-p $(PORT_TB):6006 \
		-t $(REGISTRY)/$(PROJECT_NAME) \
		$(CMD)

# clean dangling images
clean: DOCKER_HOST= 
clean:
	$(DOCKER) system prune

# WARNING: cleans everything, even images you may want to keep
clean-all: DOCKER_HOST= 
clean-all:
	$(DOCKER) rmi $(docker images -f dangling=true -q)
