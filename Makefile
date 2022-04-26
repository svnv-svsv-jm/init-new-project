help:
	@cat Makefile

.EXPORT_ALL_VARIABLES:

include .env
export $(shell sed 's/=.*//' .env)

USER?=$(shell bash -c 'whoami')
SRC?=`pwd`

# docker
DOCKER_FILE?=Dockerfile
DOCKER?=docker

# prettify docker
SUFFIX:=$(shell bash -c 'echo $$RANDOM')

# pytest
PYTEST_RUN?=python -m pytest --mypy --pylint


# -----------
# Recipes
# -----------
# correct python version and virtualenv using pyenv
init:
	pyenv install $(PYTHONVERSION)
	pyenv virtualenv $(PYTHONVERSION) $(PROJECT_NAME)
	pyenv activate $(PROJECT_NAME)

# install project's dependencies
install:
	pyenv exec pip install -r requirements.txt
	pyenv exec pip install -e .

# show python location and version
which:
	pyenv which python
	pyenv version python

# --- docker ---
# build project's image
build: $(DOCKER_FILE)
	$(DOCKER) build -t $(PROJECT_NAME) -f $(DOCKER_FILE) . 2>&1 | tee logs/build.log

pytest:
	pyenv exec $(PYTEST_RUN)

pytest-docker:
	$(DOCKER) run -d -it -v $(SRC):/src -e LOCAL_USER_ID=`id -u $(USER)` --name $(USER)-pytest-$(SUFFIX) $(PROJECT_NAME) bash sh/run-cdm.sh "$(PYTEST_RUN)"

# Docker-compose
config: docker-compose.yml
	$(DOCKER)-compose config | tee logs/config.yml

up: build config
	$(DOCKER)-compose --compatibility up -d 2>&1 | tee logs/up.log
	@echo "--- done." | tee -a logs/up.log
	@echo "Connect to http://localhost:8888 or http://localhost:6006"

down: docker-compose.yml
	$(DOCKER)-compose down --volumes 2>&1 | tee logs/down.log

ps:
	$(DOCKER)-compose ps


############################### Cleanup containers ###############################
rm:
	@echo "Remove all non running containers"
	docker container prune -f

rmi:
	docker rmi `docker images -q $(IMGNAME)`

rmi-all:
	docker rmi `docker images -aq` --force

clean: rm
	docker system prune -f --volumes

uninstall:
	pyenv exec pip freeze > freeze.txt
	pyenv exec pip uninstall -r freeze.txt -y
	rm freeze.txt