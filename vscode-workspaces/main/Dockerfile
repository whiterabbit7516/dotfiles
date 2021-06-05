##########################################
# parameters
##########################################

# [Choice] Ubuntu version: bionic, focal
ARG VARIANT="focal"

##########################################
# base image
##########################################

# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.154.0/containers/ubuntu/.devcontainer/base.Dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

##########################################
# context
##########################################

WORKDIR /devcontainer/docker-context
COPY /postCreate.ps1 ./

WORKDIR /devcontainer/docker-build-workdir
USER root

##########################################
# repository setup
##########################################

RUN sudo apt-get update \
    && sudo apt-get install -y wget apt-transport-https software-properties-common \
    && wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb \
    && sudo dpkg -i packages-microsoft-prod.deb 

RUN echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list \
    && sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823

# RUN sudo add-apt-repository universe
RUN sudo apt-get update 

##########################################
# powershell
##########################################

RUN sudo apt-get install -y powershell \
    && pwsh --version

RUN pwsh -noni -nol -nop -c Install-Module PSFzf -Scope AllUsers -Force

SHELL ["/usr/bin/pwsh", "-nop", "-nol", "-c"]

##########################################
# core utilities
##########################################

RUN sudo apt-get install -y file

RUN sudo apt-get install -y tmux vim ranger fzf \
    && tmux -V  \
    && fzf --version

##########################################
# network utilities
##########################################

RUN sudo apt install -y iputils-ping dnsutils socat ipcalc
RUN echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
RUN sudo apt install -y wireshark tshark termshark

##########################################
# linuxbrew
##########################################

RUN git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew \
    && mkdir ~/.linuxbrew/bin \
    && ln -s ~/.linuxbrew/Homebrew/bin/brew ~/.linuxbrew/bin \
    && ln -s ~/.linuxbrew/Homebrew/bin/brew /usr/local/bin/ \
    && /bin/bash -c eval $(~/.linuxbrew/bin/brew shellenv) \
    && brew update

##########################################
# npm
##########################################

RUN sudo apt install -y npm \
    && npm version

##########################################
# docker
##########################################

RUN sudo apt-get install -y docker.io \
    && docker --version

RUN iwr "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-Linux-x86_64" -outfile /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && docker-compose version

##########################################
# github
##########################################

RUN iwr https://github.com/cli/cli/releases/download/v1.9.2/gh_1.9.2_linux_amd64.deb -outfile gh.deb \
    && dpkg -i gh.deb \
    && gh version

##########################################
# dotnet
##########################################

RUN sudo apt-get install -y dotnet-sdk-5.0 \
    && dotnet --version

##########################################
# python
##########################################

RUN sudo apt install -y python3-pip python3.8
RUN python3 --version \
    && pip3 --version

RUN pip3 install virtualenv black pandas numpy

##########################################
# aws
##########################################

RUN iwr "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -outfile "awscliv2.zip" \
    && unzip awscliv2.zip \
    && sudo ./aws/install \
    && rm -rf aws* \
    && aws --version

RUN sudo pwsh -c Install-Module -Scope AllUsers -Name AWSPowerShell.NetCore -Force

##########################################
# terraform
##########################################

RUN iwr "https://releases.hashicorp.com/terraform/0.15.4/terraform_0.15.4_linux_amd64.zip" -outfile "terraform.zip" \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/terraform \
    && rm terraform.zip \
    && terraform version

##########################################
# kubernetes
##########################################

# kubectl
RUN iwr "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" -outfile kubectl \
    && chmod +x kubectl \
    && sudo mv ./kubectl /usr/local/bin/kubectl \
    && kubectl version --client

# k9s
RUN iwr https://github.com/derailed/k9s/releases/download/v0.24.7/k9s_Linux_x86_64.tar.gz -outfile k9s.tar.gz \
    && tar xzf k9s.tar.gz k9s \
    && mv k9s /usr/local/bin/k9s \
    && k9s version

# kubectx
RUN iwr https://github.com/ahmetb/kubectx/releases/download/v0.9.3/kubectx_v0.9.3_linux_x86_64.tar.gz -outfile kubectx.tar.gz \
    && tar xzf kubectx.tar.gz kubectx \
    && mv kubectx /usr/local/bin/kubectx \
    && kubectx --help

# kubens
RUN iwr https://github.com/ahmetb/kubectx/releases/download/v0.9.3/kubens_v0.9.3_linux_x86_64.tar.gz -outfile kubens.tar.gz \
    && tar xzf kubens.tar.gz kubens \
    && mv kubens /usr/local/bin/kubens \
    && kubens --help

# kustomize
RUN iwr https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.1.2/kustomize_v4.1.2_linux_amd64.tar.gz -outfile kustomize.tar.gz \
    && tar xzf kustomize.tar.gz kustomize \
    && mv kustomize /usr/local/bin/kustomize \
    && kustomize version

# kubeseal
RUN iwr https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.15.0/kubeseal-linux-amd64 -outfile kubeseal \
    && chmod +x ./kubeseal \
    && mv kubeseal /usr/local/bin/kubeseal \
    && kubeseal --version

# helm
RUN iwr https://get.helm.sh/helm-v3.5.4-linux-amd64.tar.gz -outfile helm.tar.gz \
    && tar xzf helm.tar.gz linux-amd64/helm \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && helm version

# argo cd
RUN iwr https://github.com/argoproj/argo-cd/releases/download/v2.0.2/argocd-util-linux-amd64 -o argocd \
    && chmod +x ./argocd \
    && mv ./argocd /usr/local/bin/argocd \
    && argocd version --client

# argo workflows
RUN iwr https://github.com/argoproj/argo/releases/download/v2.12.2/argo-linux-amd64.gz -outfile argo-linux-amd64.gz \
    && gunzip argo-linux-amd64.gz \
    && chmod +x argo-linux-amd64 \
    && mv ./argo-linux-amd64 /usr/local/bin/argo \
    && argo version

##########################################
# snyk
##########################################

RUN npm install -g snyk \
    && snyk version

##########################################
# trivy
##########################################

RUN iwr https://github.com/aquasecurity/trivy/releases/download/v0.18.3/trivy_0.18.3_Linux-64bit.deb -o trivy_0.18.3_Linux-64bit.deb \
    && dpkg -i trivy_0.18.3_Linux-64bit.deb  \
    && trivy -v

##########################################
# user
##########################################

RUN groupadd -r containergroup && useradd -r -g containergroup --create-home containeruser
USER root

##########################################
# entrypoint 
##########################################

ENTRYPOINT [ "/bin/pwsh", "-nop", "-nol", "-c"]
CMD [ "while ($true) {start-sleep 30}" ]
WORKDIR /