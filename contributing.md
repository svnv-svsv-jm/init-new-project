# Developer guide

This document is intended for developers who wish to contribute to the project.

## For VSCode users

We usually prefer [Visual Studio Code](https://code.visualstudio.com/). If you are a VSCode user, you may want to use the following configuration file `.vscode/settings.json`:

```json
{
  "[python]": {
    "editor.defaultFormatter": "ms-python.black-formatter"
  }
}
```

Please make sure to install the Black extension from the VSCode marketplace.

`black` will format your code automatically on save.

## Tools

- This projct uses `make` commands to facilitate users and developers.

- This project contains a working Docker image. You can build and develop in a container running this image if you experience problems in simply installing this project in a virtual environment. You can launch a development container by running `make dev-container`. Check [here](https://code.visualstudio.com/docs/remote/create-dev-container) why you'd like to do this.

- We use [pytest](https://docs.pytest.org/en/7.1.x/) with the following plugins: [pylint](https://pylint.pycqa.org/en/latest/) and [mypy](http://www.mypy-lang.org/). [Coverage](https://coverage.readthedocs.io/en/6.4.4/) is also enforced.

- For reproducibility of experiments, we could use [Hydra](https://hydra.cc/) and/or [MLFlow](https://mlflow.org/). Check out [this repository](https://github.com/ashleve/lightning-hydra-template) for an example.

## Project's layout

We have chosen the "src" layout from the official [PyTest doc](https://docs.pytest.org/en/7.1.x/explanation/goodpractices.html).

```bash
src/
 |--package_1
 |--package_2
 |-- ...
```

Develop any new package within the `src` folder. For example, if creating a package named `cool`, create the folder `src/cool`. Make sure it contains the `__init__.py` file: `src/cool/__init__.py`. Packages can implement an attack, a dataset, a model, or even everything at the same time.

```bash
src/
 |--cool
    |--__init__.py
 |--package_2
 |-- ...
```

The folder `test` will be used to test the code residing in `src`. The `test` folder will contain the `conftest.py` file and then should mimic the layout of the `src` folder as much as possible for all tests. This way, it will be easy to find a specific test for a certain function residing in specific (sub)module.

Eventually, a folder `test/integration` (or any other name) can be used to design cross-module tests.

Notebooks for quick development or to showcase our code can be stored in `notebooks/`. They may import all modules in `src` if needed.

We can use the `results` folder in case we want our repository to store useful results, figures, etc. although it is not recommended to store huge amount of data here on Gitlab.

Code that can be re-used to run specific experiments can be placed in `experiments/`.

## Dependencies

In order to install this project's dependencies, just run:

```bash
make install
```

This is the only command we want to support to install the project. For the user, it will always be `make install`, we can change the backend of the command if we need to.

This command uses [Poetry](https://python-poetry.org/) behind the scenes. [Poetry](https://python-poetry.org/) can make it a lot easier to handle dependencies. It relies on a `pyproject.toml` file with a `tool.poetry.dependencies` section. With `poetry`, you can also specify a different source for each dependency. For example:

```pyproject.toml
torch = [
    { version = "*", source = "pytorch", platform = "linux" },
    { version = "^2.0.0", source = "pypi", platform = "darwin" },
]

[[tool.poetry.source]]
name = "pytorch"
url = "https://download.pytorch.org/whl/cpu"
priority = "explicit"
```

Here (above), install `torch` from the source `"pytorch"` if we are on Linux, or from PyPi if we are on Mac.

### Add new dependencies

To add new dependencies, run:

```bash
poetry add <package-name>
```

Alternatively, manually edit the `pyproject.toml` file, then run `poetry lock`.

## Testing

This project uses `pytest` for test-driven development (TDD). Make sure you're familiar with it: <https://docs.pytest.org/en/7.1.x/>

To run all your tests, you can run:

```bash
python -m pytest --mypy --pylint

# test notebooks too
pytest --nbmake --overwrite "./notebooks
```

You can also just run:

```bash
make pytest
```

here, `pylint`, `mypy` and `coverage` are enforced automatically.

## Useful git commands

To clear all merged branches (local branches that do not have a remote counterpart anymore), **from the `main` branch**, run:

```bash
make git-clean
```

## CI/CD Pipeline

We use a `.gitlab-ci.yml` file to automatically test our code when pushing, so that our fellow other developers can have an easier job when reviewing pull requests.

## Project's image

We build the image locally as follows: `make build`.

**DATA**: all datasets must be saved to the `.data`. This folder is ignored by Git (see the `.gitignore` [file](../.gitignore)). If you do not like this default location, you can store datasets elsewhere, as long as you do not push data to the repository to keep its size small.
