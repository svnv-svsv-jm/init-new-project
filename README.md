# Start new Python project

This repository exists because every time I have to set up a new Python project, there is just too much I have to do. So here is a useful template for myself. Feel free to clone it or download it if you want.

The project contains a `Makefile` so that useful but long commands can be run without too much thinking. Besides, `mypy`, `pylint` are also configured.

A `.env` file lets you choose the project's name, the Python version and more stuff. Check the file please.

This template is to develop a PyTorch project, but you can change it to whatever you want.

It is implied that you are on Mac/Linux. No Windows.

## Installation via virtual environment

### Pre-requisites

Make sure you have Python `>=3.8.13` (`3.10.10` recommended).

Create a virtual environment with any tool you prefer.

#### Create a virtual environment

Use any tool to create a virtual environment with the indicated Python version.

With [Pyenv](https://github.com/pyenv/pyenv) (**recommended**, here is the [installer](https://github.com/pyenv/pyenv-installer)), it is very easy to install the Python version you want, create a virtual environment and activate it.

Once Pyenv is installed, run:

```bash
pyenv install 3.10.10
pyenv virtualenv 3.10.10 <project-name>
pyenv activate <project-name>
```

or just:

```bash
make init
```

### Getting Started

Once the virtual environment is active, install the present project and all dependencies by running:

```bash
pip install --upgrade pip
pip install --upgrade poetry
poetry install --no-cache
```

Make sure you are calling the correct `python`, `pip` and `poetry`. In case you're not sure, prepend `python -m` before all above commands.

Alternatively, you can also just run:

```bash
make install
```

which does all the work for you.

## Installation via Docker

Build project's image as follows:

```bash
docker build -t <project-name> -f Dockerfile .
# or alternatively
make build
```

The present folder will be mounted at `/workdir`.

### More docker-related features

- To start a Bash session in the container, run: `make bash`
- To start a Jupyter Notebook (+ a Tensorboard), run: `make up`. Then run `make down` when you're done.
- To run PyTest from the container, run: `make pytest-image`
- To start a Python session in the container, run: `make docker-python`
- To start a [development container](https://code.visualstudio.com/docs/remote/create-dev-container), run: `make dev-container` or `make up` (if you go for this one, you can then kill the container with `make down`). Make sure that you're not `root` in the container. To see if a user with your local username and userid exists inside the container, run `cat /etc/passwd`. Then, you can run `su - <your-username>` to change user insinde the dev container.

Please also note that our image's entrypoint is the script [entrypoint.sh](./scripts/entrypoint.sh). This script solves common permission problems for developers who wish to mount their local source code directory on a container, as explained [here](https://denibertovic.com/posts/handling-permissions-with-docker-volumes/). **TL;DR**: you will be logged into your container as your current user, thus avoinding any permission errors.

## Usage

Please check the `examples` folder: [here](./examples)

## Run experiments

Check the `experiments` folder: [readme](experiments/README.md)

## Developer documentation

If you wish to contribute to the project, please see [here](./src/README.md)
