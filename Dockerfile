FROM ubuntu:19.04

RUN apt-get update
RUN apt-get install -y git curl sudo cmake golang protobuf-compiler

RUN git clone https://github.com/libra/libra.git
WORKDIR /libra
COPY dev_setup.sh ./scripts/
RUN ./scripts/dev_setup.sh
RUN apt-get install -y vim

RUN $HOME/.cargo/bin/cargo update
RUN $HOME/.cargo/bin/cargo build

ENTRYPOINT ./scripts/cli/start_cli_testnet.sh
