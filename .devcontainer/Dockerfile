ARG     ALPINE_LINUX_VERSION
FROM    alpine:${ALPINE_LINUX_VERSION}

ARG     DOCKER_GROUP_ID
ARG     USER="dev"
ARG     KUBECTL_VERSION="v1.27.1"
ARG     HELM_VERSION="v3.12.3"

RUN     apk add curl doas docker gcc git make openssh shadow vim && \
        adduser -D ${USER} && \
        addgroup ${USER} docker && \
        groupmod --gid ${DOCKER_GROUP_ID} docker && \
        git config --global core.editor "vim" && \
        curl -LO https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
        chmod +x kubectl && \
        mv kubectl /usr/local/bin/kubectl && \
        curl -LO https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
        tar -zxvf helm-${HELM_VERSION}-linux-amd64.tar.gz && \
        mv linux-amd64/helm /usr/local/bin/helm
