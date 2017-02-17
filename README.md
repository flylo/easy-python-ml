# easy-python-ml:0.0.1
Repository to provide simple model deployment that can be run as either a pipeline or an interactive notebook on GCP.


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
(.venv) ➜  sh deployment.sh
Usage: sh deployment.sh [build|run|local-notebook]
```

  * To build the docker image, run `sh deployment.sh build`.

  * To run the image as a container, run `sh deployment.sh run`

  * To get a link to the notebook on your local machine, run `sh deployment.sh local-notebook`

  **NOTE** Notebooks created on your local machine will not save automatically - they must be downloaded to persist.
