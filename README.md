# Start new Python project

This repository exists because every time I have to set up a new Python project, there is just too much I have to do. So here is a useful template for myself. Feel free to clone it or download it if you want.

The project contains a `Makefile` so that useful but long commands can be run without too much thinking. Besides, `mypy`, `pylint` are also configured.

A `.env` file lets you choose the project's name, the Python version and more stuff. Check the file please.

This template is to develop a PyTorch project, but you can change it to whatever you want.

## Python envs

Install `pyenv`, then create a virtual environment for the project by running:

```bash
make init
```

then install all dependencies:

```bash
make install
```

Then have fun developing, then run your tests:

```bash
make pytest
```

## Docker

Virtual environments may not be the best for reproducible builds, so you may want to use Docker. There is a `Dockerfile` and a `make build` command here, plus a `docker-compose.yml` file that would set up Jupyter Notebook and Tensorboard services using the image you would build with the `Dockerfile`, but it is up to you to code the `Dockerfile`.

The pains in the ass about Docker are related to permissions and impossibility to edit code dynamically. You want to dynamically mount the project's repository to the containers but they run images with different users, plus if you mount it instead of copying it directly to the image then you have to instlal it every time...

So here's the fix:
* mount the repository to the container;
* use a script as entrypoint that would let you log in into the container as yourself using `gosu`;
* run commands in the container by providing them as input to a script that installs this repository first.

Check the `scripts` folder.

For example:

```bash
$docker run -d -it -v $(SRC):/src -e LOCAL_USER_ID=`id -u $(USER)` --name $(PROJECT_NAME) bash sh/run-cdm.sh "echo yo"
```

Instead of running your command directly (`echo yo`), you pass it as argument to a script that first executes some stuff and then actually runs that.

Launch Jupyter and Tensorboard:

```bash
make up
```