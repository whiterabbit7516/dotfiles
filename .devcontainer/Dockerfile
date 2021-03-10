
##########################################
# parameters
##########################################

# [Choice] Ubuntu version: bionic, focal
ARG VARIANT="focal"

# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"
# [Option] Enable non-root Docker access in container
ARG ENABLE_NONROOT_DOCKER="true"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG SOURCE_SOCKET=/var/run/docker-host.sock
ARG TARGET_SOCKET=/var/run/docker.sock

##########################################
# base image
##########################################

# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.154.0/containers/ubuntu/.devcontainer/base.Dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

##########################################
# scripts
##########################################

COPY library-scripts/*.sh /tmp/library-scripts/

##########################################
# repository setup
##########################################

RUN sudo apt-get update \
    && sudo apt-get install -y wget apt-transport-https software-properties-common \
    && wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb \
    && sudo dpkg -i packages-microsoft-prod.deb 

# RUN sudo add-apt-repository universe
RUN sudo apt-get update 

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

RUN sudo apt install -y iputils-ping dnsutils

##########################################
# linuxbrew
##########################################

RUN git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew \
    && mkdir ~/.linuxbrew/bin \
    && ln -s ~/.linuxbrew/Homebrew/bin/brew ~/.linuxbrew/bin \
    && ln -s ~/.linuxbrew/Homebrew/bin/brew /usr/local/bin/ \
    && eval $(~/.linuxbrew/bin/brew shellenv) \
    && brew help

##########################################
# powershell
##########################################

RUN sudo apt-get install -y powershell \
    && pwsh --version

RUN pwsh -noni -nol -nop -c Install-Module PSFzf -Scope AllUsers -Force

##########################################
# docker
##########################################

RUN sudo apt-get install -y docker.io \
    && docker --version

##########################################
# python
##########################################

RUN sudo apt update && apt install -y python3-pip
RUN python3 --version \
    && pip3 --version

##########################################
# go
##########################################

RUN sudo apt install -y golang \
    && go version

##########################################