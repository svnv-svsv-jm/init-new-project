FROM python:3.10.10

ARG project_name=project

ENV PROJECT_NAME=$project_name

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
RUN umask 022 && apt-get update \
    # Install system packages
    && apt-get install -y --no-install-recommends apt-utils ca-certificates gosu sudo git \
    && rm -rf /var/lib/apt/lists/* \
    # Install Python dependencies
    && pip install virtualenv \
    && virtualenv /$PROJECT_NAME \
    && source /$PROJECT_NAME/bin/activate \
    && make install \
    && cp poetry.lock /tmp/. \
    && rm -r /root/.cache \
    # Jupyter notebook configuration
    && source /$PROJECT_NAME/bin/activate \
    && jupyter contrib nbextension install --user \
    && jupyter nbextension install https://github.com/jfbercher/code_prettify/archive/master.zip --user \
    && jupyter nbextension enable code_prettify-master/code_prettify \
    && jupyter nbextension install --py jupyter_highlight_selected_word \
    && jupyter nbextension enable highlight_selected_word/main \
    # Avoid permission problems: this is where the virtual env is installed in the image
    && chmod -R 777 /$PROJECT_NAME

# TensorBoard
EXPOSE 6006
# Jupyter Notebook
EXPOSE 8888

# Handle user-permissions using GOSU (https://denibertovic.com/posts/handling-permissions-with-docker-volumes/): The entrypoint script `entrypoint.sh` is needed to log you in within the container at runtime: this means that any file you create in the container will belong to your user ID, not to root's, thus solving all those annoying permission-related issues

# Set entrypoint and default container command
ENTRYPOINT ["/workdir/scripts/entrypoint.sh"]
