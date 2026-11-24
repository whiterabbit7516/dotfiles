FROM ghcr.io/whiterabbit7516/devcontainers/devenv-main-arm64:latest

##########################################
# setup
##########################################

WORKDIR /devcontainer/

##########################################
# resources
##########################################

COPY /resources/ /devcontainer/resources/

##########################################
# config
##########################################

COPY /config/ /devcontainer/config/

##########################################
# scripts
##########################################

COPY /scripts/ /devcontainer/scripts/

##########################################
# certificates
##########################################

COPY /certs/ /devcontainer/certs/

# requires .crt extension
COPY /certs/ /usr/local/share/ca-certificates/
RUN update-ca-certificates

##########################################
# finalization
##########################################

WORKDIR /
USER root
