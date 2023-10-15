# docker-desktop-kubernetes
This repository contains an example of a local Kubernetes development setup in which the development is excuted inside devcontainer in Visual Studio Code, and the application is deployed via Helm into local Kubernetes cluster (Docker Desktop).

The application is a simple Flask app running on Python Alpine image. The app itself is serving port 8080 and the ingress is mapping port 80 into port 8080.

It can be run locally inside the devcontainer, inside a Docker container or inside a pod inside a Docker Desktop Kubernetes cluster. In the Docker Desktop Kubernetes, the application is accessed through an ingress which is deployed into the cluster with `nginx` ingress controller.

The Docker Desktop will add the `kubernetes.docker.internal` hostname into Windows' hosts file. It can be then used in the Kubernetes ingress.

```
# Added by Docker Desktop
192.168.68.104 host.docker.internal
192.168.68.104 gateway.docker.internal
# To allow the same kube context to work on the host and the container:
127.0.0.1 kubernetes.docker.internal
# End of section
```

## Requirements

This setup was tested in Windows Pro 11 which had

* Windows Subsystem Linux 2 running Ubuntu 22.04.2
* Docker Desktop v4.22.1 running Kubernetes v1.27.1
* Visual Studio Code 1.81.1 installed in Windows Pro 11
* nginx ingress controller v1.8.1 installed via Helm into the Docker Desktop Kubernetes
* Local Docker registry running at port 5000

### Install nginx ingress controller

Install nginx ingress controller.

```
helm install my-release oci://ghcr.io/nginxinc/charts/nginx-ingress --version 1.0.1
```

### Install local Docker registry

Install local Docker registry.

```
docker run -d -p 5000:5000 --restart=always --name registry registry:2
```

## Setup

Follow these instructions carefully.

Clone the Git repository. Inside the Git repository run `make` to see the available make targets. At first run `docker-override-docker-gid` to override the Docker group id in the `devcontainer.json`. This is required as the Docker group id at host is most likely different as it will be inside the devcontainer after the Docker is installed.

`ctrl+shift+P` and `Dev Containers: Rebuild Container Without Cache`. Once the devcontainer is built, Visual Studio Code will open the Git repository inside the devcontainer.

Once the devcontainer is running run make target `setup`. It will build the application Docker image and push it into the local Docker registry. It will also package the application into Helm chart.

## Run

### Devcontainer

The devcontainer has all the required dependencies for the application. Therefore the application can be executed locally.

```
/workspaces/docker-desktop-kubernetes $ python3 app/app.py
 * Serving Flask app 'app'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:8080
 * Running on http://172.17.0.3:8080
Press CTRL+C to quit
```

Test it by running curl command.

```
/workspaces/docker-desktop-kubernetes $ curl localhost:8080
Hello world!
```

### Docker container

Run the application in Docker container by running make target `docker-run` in one terminal.

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

### Docker Desktop Kubernetes

Run the application in the Docker Desktop Kubernetes by running make target `helm-deploy`.

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

Run make target `helm-undeploy` to delete the Helm release from the Docker Desktop Kubernetes.

## Closing

There you go!
