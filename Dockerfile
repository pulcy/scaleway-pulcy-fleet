## -*- docker-image-name: "scaleway/ubuntu-coreos:latest" -*-
FROM scaleway/docker:amd64-1.10
# following 'FROM' lines are used dynamically thanks do the image-builder
# which dynamically update the Dockerfile if needed.
#FROM scaleway/docker:armhf-1.10	# arch=armv7l
#FROM scaleway/docker:arm64-1.10	# arch=arm64
#FROM scaleway/docker:i386-1.10		# arch=i386
#FROM scaleway/docker:mips-1.10		# arch=mips
MAINTAINER Ewout Prangsma


# Prepare rootfs for image-builder
RUN /usr/local/sbin/builder-enter

# Install packages
RUN apt-get -q update                   \
 && apt-get --force-yes -y -qq upgrade  \
 && apt-get --force-yes install -y -q build-essential tar \
 && apt-get clean


# Install Go
RUN apt-get -y install golang  && \
    echo "export GOPATH=/usr/src/spouse" >> ~/.bashrc && \
    mkdir /usr/src/spouse

# Install Fleet
RUN cd /usr/src/ && \
    GOPATH=/usr/src/spouse go get golang.org/x/tools/cmd/cover && \
    wget https://github.com/coreos/fleet/archive/v0.11.5.tar.gz && tar xzf v0.11.5.tar.gz && mv fleet-0.11.5 fleet && cd fleet && \
    ./build && \
    ln -s /usr/src/fleet/bin/* /usr/bin/

# Install Etcd
RUN cd /usr/src/ && git clone https://github.com/coreos/etcd.git -b release-2.3 && \
    cd /usr/src/etcd && \
    ./build && \
    ln -s /usr/src/etcd/bin/* /usr/bin/ && \
    mkdir /var/lib/etcd

# Patch rootfs
ADD ./overlay/etc/ /etc/
RUN systemctl disable docker; systemctl enable docker


# Clean rootfs from image-builder
RUN /usr/local/sbin/builder-leave
