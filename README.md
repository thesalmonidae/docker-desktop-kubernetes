# docker-desktop-kubernetes
This repository contains an example of a local Kubernetes development setup in which the development is excuted inside devcontainer (on top of Alpine linux) in Visual Studio Code, and the application is deployed via Helm into local Kubernetes cluster (Docker Desktop).

The application is accessed through an ingress which is deployed into the cluster with `nginx` ingress controller.

The application is a simple Flask app running on Python Alpine image. The app itself is serving port 8080 and the ingress is mapping port 80 into port 8080.

## Requirements

This setup was tested in Windows Pro 11 which had

* Windows Subsystem Linux 2 running Ubuntu 22.04.2
* Docker Desktop v4.22.1 running Kubernetes v1.27.1
* Visual Studio Code 1.81.1 installed in Windows Pro 11
* nginx ingress controller v1.8.1 installed via Helm into the Docker Desktop Kubernetes
* Local Docker registry running at port 5000

## Setup

Follow these instructions carefully.

Clone the Git repository. Inside the Git repository run `make` to see the available make targets. At first run `docker-override-docker-gid` to override the Docker group id in the `devcontainer.json`. This is required as the Docker group id at host is most likely different as it will be inside the devcontainer after the Docker is installed.

`ctrl+shift+P` and `Dev Containers: Rebuild Container Without Cache`. Once the devcontainer is built, Visual Studio Code will open the Git repository inside the devcontainer.

Once the devcontainer is running run make target `setup`.

## Run

First run the application in Docker container by running make target `docker-run` in one terminal.

```
/workspaces/docker-desktop-kubernetes $ make docker-run
docker run -it --rm -p 8080:8080 localhost:5000/app:latest
 * Serving Flask app 'app'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:8080
 * Running on http://172.17.0.4:8080
Press CTRL+C to quit
```

Then open another terminal and run `curl kubernetes.docker.internal:8080`.

```
/workspaces/docker-desktop-kubernetes $ curl kubernetes.docker.internal:8080
Hello world!
```

Secondly, open another terminal and deploy the application into Kubernetes by running make target `helm-deploy`.

```
/workspaces/docker-desktop-kubernetes $ make helm-deploy
helm install app .build/app-1.0.0.tgz
NAME: app
LAST DEPLOYED: Sat Sep  2 20:50:56 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

Then run `curl kubernetes.docker.internal`.

```
/workspaces/docker-desktop-kubernetes $ curl kubernetes.docker.internal
Hello world!
```

There you go!
