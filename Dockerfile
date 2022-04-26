############################################################
# Dockerfile
# Based on official pytorch container
############################################################
FROM pytorchlightning/pytorch_lightning:base-cuda-py3.8-torch1.8

# Install system packages
RUN apt-get update &&\
    apt-get install -y --no-install-recommends gosu &&\
    rm -rf /var/lib/apt/lists/*

# Python packages
COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip setuptools wheel &&\
    pip install -r /tmp/requirements.txt

# Handle user-permissions using GOSU: from https://denibertovic.com/posts/handling-permissions-with-docker-volumes/
# The entrypoint script `entrypoint.sh` is needed to log you in within the container at runtime: this means that any file you create in the container will belong to your user ID, not to root's, thus solving all those annoying permission-related issues that happen with mounted volumes, which we're using for data and source code
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# TenseBoard
EXPOSE 6006
# Jupyter
EXPOSE 8888

# Set the working directory
WORKDIR $WORK_DIR

# Set entrypoint and default container command
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
