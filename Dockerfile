FROM python:3.10.10

ENV PROJECT_NAME=$project_name
ENV PYTHON=/$PROJECT_NAME/bin/python

# Create workdir and copy dependency files
RUN mkdir -p /workdir
COPY pyproject.toml /workdir/pyproject.toml
COPY Makefile /workdir/Makefile
COPY scripts /workdir/scripts
COPY README.md /workdir/README.md
COPY LICENSE /workdir/LICENSE
COPY MANIFEST.in /workdir/MANIFEST.in
COPY src /workdir/src
COPY poetry.lock /workdir/

# Change shell to be able to easily activate virtualenv
SHELL ["/bin/bash", "-c"]
WORKDIR /workdir

# Install project
RUN bash scripts/docker-installation-steps.sh

# TensorBoard
EXPOSE 6006
# Jupyter Notebook
EXPOSE 8888

# Handle user-permissions using GOSU (https://denibertovic.com/posts/handling-permissions-with-docker-volumes/): The entrypoint script `entrypoint.sh` is needed to log you in within the container at runtime: this means that any file you create in the container will belong to your user ID, not to root's, thus solving all those annoying permission-related issues

# Set entrypoint and default container command
ENTRYPOINT ["/workdir/scripts/entrypoint.sh"]
