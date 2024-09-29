FROM --platform=linux/amd64 ubuntu:18.04

RUN apt-get update && \
    apt-get install -y sudo \
    apt-utils \
    curl \
    wget \
    vim \
    build-essential \
    cmake \
    git \
    libgmp3-dev \
    libprocps-dev \
    python-markdown \
    libboost-all-dev \
    libssl-dev \
    pkg-config

ENV GOLANG_VERSION=1.19.2
ENV GOROOT=/usr/local/go
ENV GOPATH=/root/go
ENV PATH=$GOROOT/bin:$GOPATH/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib

RUN wget https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    sudo tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    rm go${GOLANG_VERSION}.linux-amd64.tar.gz

RUN mkdir -p /root/go \
    mkdir -p $GOPATH/src/github.com

SHELL ["/bin/bash", "-c"]

RUN echo "export GOROOT=/usr/local/go" >> /root/.profile && \
    echo "export GOPATH=/root/go" >> /root/.profile && \
    echo "export PATH=\$PATH:/usr/local/go/bin:\$GOPATH/bin" >> /root/.profile

COPY . /root/go/src/github.com/ethereum

RUN cd $GOPATH/src/github.com/ethereum && \
    mkdir prfKey && \
    cd libsnark-vnt && \
    mkdir build && cd build && mkdir output && \
    cmake .. && make

RUN cd $GOPATH/src/github.com/ethereum/libsnark-vnt/build && \
    ./src/mint_key > ./output/mint_output.txt && \
    ./src/send_key > ./output/send_output.txt && \
    ./src/deposit_key > ./output/deposit_output.txt && \
    ./src/redeem_key > ./output/redeem_output.txt

CMD ["/bin/bash"]