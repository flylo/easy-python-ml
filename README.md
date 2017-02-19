# easy-python-ml:0.0.3
Quickly and easily spin up a notebook server in GCP.

This repository includes utility functions for reading data from Google Cloud Storage.


## Pre-Requisites
### Install Docker
If on a Mac or Windows, follow [the instructions here](https://www.docker.com/products/docker-toolbox) to install Docker Toolbox.

### Get GCS Service Key (to run notebook/jobs remotely)
In order to run a notebook or jobs remotely, [get a service key in the GCS console](https://console.cloud.google.com/iam-admin/serviceaccounts/). Once you've downloaded this key, rename it `google_service_key.json` and move it to the root directory of the repository.

### Set up Kubernetes and gcloud Command Line
See [instructions here](https://cloud.google.com/container-engine/docs/quickstart#install_the_gcloud_command-line_interface).

### Set up versioning with bumpversion
Run `pip install --upgrade bumpversion`

## Usage
Use the `deployment.sh` script to orchestrate docker and run the notebook.

```bash
(.venv) ➜  easy-python-ml git:(master) sh deployment.sh
Usage: sh deployment.sh [patch|build|push|deploy|port-forward|run-local-notebook]
```

  * To bump the version after making small changes, run `sh deployment.sh patch`

  * To build the docker image, run `sh deployment.sh build`.

  * To push the docker image to the remote container repository, run `sh deployment.sh push`

  * To deploy the notebook server, run `sh deployment.sh deploy`. This will:

    1. Make a new persistent disk (or use an existing one from a previous run)
    2. Spin up a Kubernetes cluster (or use an existing one from a previous run)
    3. Deploy a "pod" (server) to host the notebook on

  * To port-forward into a running pod, run `sh deployment.sh port-forward`

  * To run the notebook locally, run `sh deployment.sh run-local-notebook`

  **NOTE** Notebooks created on your local machine will not save automatically - they must be downloaded to persist.
