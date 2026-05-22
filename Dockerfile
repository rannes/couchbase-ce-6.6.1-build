# Build environment for Couchbase Server 6.6.1 (mad-hatter, CE).
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential ccache curl git python python3 python3-pip \
    libssl-dev libnuma-dev libsnappy-dev liblz4-dev \
    libcurl4-openssl-dev libtool autoconf automake \
    pkg-config m4 ninja-build flex bison ed unzip wget \
    ca-certificates gnupg sudo locales \
    libncurses5 libssl1.1 libsctp1 \
  && locale-gen en_US.UTF-8 \
  && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Bionic ships cmake 3.10; Couchbase 6.6.1 needs >= 3.12.
RUN wget -qO /tmp/cmake.sh https://github.com/Kitware/CMake/releases/download/v3.19.8/cmake-3.19.8-Linux-x86_64.sh \
  && sh /tmp/cmake.sh --skip-license --prefix=/usr/local && rm /tmp/cmake.sh

# Go 1.13 (used by some 6.6.1 components).
RUN wget -qO /tmp/go.tgz https://go.dev/dl/go1.13.15.linux-amd64.tar.gz \
  && tar -C /usr/local -xzf /tmp/go.tgz && rm /tmp/go.tgz
ENV PATH=/usr/local/go/bin:/root/go/bin:$PATH

# Google's repo tool.
RUN curl -sSLo /usr/local/bin/repo https://storage.googleapis.com/git-repo-downloads/repo \
  && chmod +x /usr/local/bin/repo

RUN git config --global user.email "build@local" && git config --global user.name "build"

WORKDIR /work
