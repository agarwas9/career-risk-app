FROM jenkins/jenkins:lts

USER root

# Install Docker CLI
RUN apt-get update && apt-get install -y docker.io curl

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/v1.30.1/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Kind
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64 \
    && chmod +x ./kind \
    && mv ./kind /usr/local/bin/kind

USER jenkins