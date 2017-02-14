# midi-ml-0.0.1
Repository to complete projects assigned in the [CUNY GC Machine Learning course](http://haralick.org/ML/lecture_slides.shtml).


## Pre-Requisites
### Install Docker
If on a Mac or Windows, follow [the instructions here](https://www.docker.com/products/docker-toolbox) to install Docker Toolbox.

### Get GCS Service Key (to run notebook/jobs remotely)
In order to run a notebook or jobs remotely, [get a service key in the GCS console](https://console.cloud.google.com/iam-admin/serviceaccounts/). Once you've downloaded this key, rename it `google_service_key.json` and move it to the root directory of the repository.

### Set up Kubernetes and gcloud Command Line
See [instructions here](https://cloud.google.com/container-engine/docs/quickstart#install_the_gcloud_command-line_interface).

## Usage
Use the `deployment.sh` script to orchestrate docker and run the notebook.

```bash
➜  midi-ml git:(setup) sh deployment.sh
Usage: sh deployment.sh [build|run|local-notebook]
```

  * To build the docker image, run `sh deployment.sh build`.

  * To run the image as a container, run `sh deployment.sh run`

  * To get a link to the notebook on your local machine, run `sh deployment.sh local-notebook`
