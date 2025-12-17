FROM ubuntu:24.04

LABEL maintainer="alexdp"
LABEL description="Ubuntu 24.04 base image with essential tools"
LABEL version="1.0.0"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    vim \
    nano \
    net-tools \
    iputils-ping \
    tini \
    psmisc \
    cups cups-client cups-daemon libusb-0.1-4 libcupsimage2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Declare ls and ll shortcut
RUN echo '/bin/ls -alF --color=auto "$@"' > /usr/local/bin/ll && chmod +x /usr/local/bin/ll
# Set default shell bash
SHELL ["/bin/bash", "-c"]

COPY drivers/suldr-keyring_4_all.deb /tmp/
COPY drivers/suld-ppd-4_1.00.39-2_all.deb /tmp/
COPY drivers/suld-driver2-1.00.39_1.00.39-2_amd64.deb /tmp/
COPY drivers/suld-driver2-common-1_1-14_all.deb /tmp/

RUN dpkg -i /tmp/suldr-keyring_4_all.deb \
 && dpkg -i /tmp/suld-ppd-4_1.00.39-2_all.deb \
 && dpkg -i /tmp/suld-driver2-common-1_1-14_all.deb \
 && dpkg -i /tmp/suld-driver2-1.00.39_1.00.39-2_amd64.deb

# Copier un script d'initialisation (créé à part)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 631

ENTRYPOINT /usr/bin/tini -- /entrypoint.sh
