#!/usr/bin/env bash

image_version="0.0.5"
project_name=`python scripts/lookup_value_from_json google_service_key.json project_id`
repo_name="gcr.io/${project_name}/easy_ml"
user_name="$( echo $USER | tr '[:upper:]' '[:lower:]')"
cluster_name="${user_name}-ml-cluster"
zone="us-east1-b"
remote_image=`gcloud beta container images list-tags ${repo_name} | grep ${image_version} | tr -d '[:space:]'`

echoRun() {
    echo "${yellow}> $1${reset}"
    eval $1
}

patch() {
    bumpversion patch --allow-dirty
}


build() {
    docker build -t ${repo_name} .
}

push() {
    if [ -z ${remote_image} ]
    then
        echo "building and pushing image version ${image_version}"
        docker build  -t ${repo_name}:${image_version} .
        gcloud docker -- push ${repo_name}:${image_version}
    else
        echo "Current version tag already in container repository. If you've made changes, please bump the version with 'sh deployment.sh patch'"
        exit 1
    fi
}

make_disk() {
    disk_name=${user_name}-notebook-persistent-disk
    if gcloud compute disks list | grep -q "^${disk_name}[[:space:]]"
    then
        echo "Persistent disk ${disk_name} found"
    else
        echo "Persistent disk ${disk_name} not found, creating"
        gcloud compute disks create --size=500GB --zone=${zone} ${disk_name}
    fi
}

make_cluster() {
    if gcloud container clusters list | grep -q "^${cluster_name}[[:space:]]"
    then
        echo "Kubernetes Cluster ${cluster_name} found"
    else
        echo "Kubernetes Cluster ${cluster_name} not found, creating"
        gcloud container clusters create ${cluster_name} --zone=${zone} --num-nodes=1 --machine-type=n1-standard-4
    fi

    gcloud container clusters get-credentials ${cluster_name}
}

make_pod() {
    if kubectl get pod | grep -q jupyter-server-pod
    then
        echo ""
        cat jupyter-server.yaml | sed "s#NOTEBOOK_IMAGE#${repo_name}:${image_version}#" \
            | sed "s/DISK_NAME/${disk_name}/" \
            | kubectl delete -f -
    fi

    cat jupyter-server.yaml | sed "s#NOTEBOOK_IMAGE#${repo_name}:${image_version}#" \
        | sed "s/DISK_NAME/${disk_name}/" \
        | kubectl create -f -
}

deploy() {
    if [ -z ${remote_image} ]
    then
        echo "Current version tag not yet in container repository. Please push with 'sh deployment.sh push'"
        exit 1
    fi

    make_disk
    make_cluster
    make_pod
}

tear_down() {
    if gcloud container clusters list | grep -q "^${cluster_name}[[:space:]]"
    then
        echo "Deleting cluster ${cluster_name}"
        gcloud container clusters delete ${cluster_name}
    else
        echo "Cluster ${cluster_name} not found"
        exit 1
    fi
}

port_forward() {
    pod_name=`kubectl get pod -o=custom-columns=NAME:.metadata.name | grep jupyter-server-pod`
    if [ -z ${pod_name} ]
    then
        echo "No running jupyter pod found. Please deploy one first"
        exit 1
    fi

    status=`kubectl get pod ${pod_name} -o=custom-columns=NAME:.status.phase --no-headers`
    while [ ${status} = "ContainerCreating" ] || [ ${status} = "Pending" ]
    do
        sleep 2
        printf "."
        status=`kubectl get pod ${pod_name} -o=custom-columns=NAME:.status.phase --no-headers`
    done

    if [ ${status} != "Running" ]
    then
        echo "Pod status is ${status}, aborting"
        exit 1
    fi

    echo "Notebook running at http://localhost:8889"
    kubectl port-forward ${pod_name} 8889:8888
}

run_local_notebook() {
    echo "starting local notebook at `docker-machine ls | grep default | \
            awk '{print $5}' | \
            awk '{ gsub("tcp://", "http://") ; system( "echo "  $0)}' | \
            awk '{ gsub(":2376", ":8888") ; system("echo " $0)}'`"
    docker run -it -p 8888:8888 ${repo_name}:${image_version}
}
