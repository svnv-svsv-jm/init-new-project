# Developer guide

This document is intended for developers who wish to contribute to the project. For all dependencies, see the [installation guide](./README.md).

## Tools

We usually prefer [Visual Studio Code](https://code.visualstudio.com/). If you are a VSCode user, you may want to use the following configuration file `.vscode/settings.json`:

```json
{
  "python.defaultInterpreterPath": "<path-to-your-python-interpreter>",
  "python.linting.enabled": true,
  "python.linting.mypyEnabled": true,
  "python.linting.lintOnSave": true,
  "python.linting.pylintEnabled": true,
  "python.formatting.provider": "black",
  "esbonio.sphinx.confDir": ""
}
```

You can have [Black](https://black.readthedocs.io/en/stable/) installed by following the [installation guide](./README.md) or you can do so manually as follows:

```bash
pip install black
```

`black` will format your code automatically on save.

## Technologies

- This projct uses `make` commands to facilitate users and developers.

- This project contains a working Docker image. You can build and develop in a container running this image if you experience problems in simply installing this project in a virtual environment. You can launch a development container by running `make dev-container`. Check [here](https://code.visualstudio.com/docs/remote/create-dev-container) why you'd like to do this.

- We use [pytest](https://docs.pytest.org/en/7.1.x/) with the following plugins: [pylint](https://pylint.pycqa.org/en/latest/) and [mypy](http://www.mypy-lang.org/). [Coverage](https://coverage.readthedocs.io/en/6.4.4/) is also enforced.

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

At the moment, we are developing one package `package`, with different modules.

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

Which uses [Poetry](https://python-poetry.org/) behind the scenes. [Poetry](https://python-poetry.org/) can make it a lot easier to handle dependencies. It relies on a `pyproject.toml` file with a `tool.poetry.dependencies` section.

### Add new dependencies

To add new dependencies, run:

```bash
poetry add <package-name>
# or
make poetry-add PACK=<package-name> # this sets PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring automatically, which fixes a poetry bug
```

Alternatively, just run:

```bash
make install
```

## Testing

This project uses `pytest` for test-driven development (TDD). Make sure you're familiar with it: <https://docs.pytest.org/en/7.1.x/>

To run all your tests, run:

```bash
python -m pytest
# test notebooks too
pytest --nbmake --overwrite "./notebooks
```

`pylint`, `mypy` and `coverage` may be enforced automatically.

You can also just run:

```bash
make pytest
```

## Useful git commands

To clear all merged branches (local branches that do not have a remote counterpart anymore), **from the `main` branch**, run:

```bash
# from the main branch
git branch --merged | egrep -v '(^\*|main|master|develop)' | xargs git branch -d
```

or

```bash
# from the main branch
git remote prune origin
git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -D
```

## CI/CD Pipeline

We use a `.gitlab-ci.yml` file to automatically test our code when pushing, so that our fellow other developers can have an easier job when reviewing pull requests.

We only test the source code here, not the notebooks, or the tests may be too long and we must stay within one hour.

## Project's image

We build the image locally (`make build`), push it (`make push`) and then let the pipeline run in the container. You will need the `CI_JOB_TOKEN` to actually push to the registry.

## Development rules

- Issues must have a small scope and must have a clear definition for when they can be considered solved (definition of "done").
- Notebooks must be small, readable and tested. Always go for an easy user interface / API. For example, `from <package-name> import ...` is preferable than slapping a user with hundreds of lines to show them how to do stuff.
- Workflow:
  - create an issue
  - create associated branch
  - code around: define tests (source code and notebooks) and pass them locally (see above how to run tests)
  - MR: the CI/CD pipeline runs all tests
  - review
  - squash commits, merge and delete branch
  - no merge must be possible if the pipeline does not succeed!

> **DATA**: all datasets must be saved to the `.data`. This folder is ignored by Git (see the `.gitignore` [file](./.gitignore)). If you do not like this default location, you can store datasets elsewhere, as long as you do not push data to the repository to keep its size small.
