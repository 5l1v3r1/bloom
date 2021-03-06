FROM rustlang/rust:nightly-slim AS build

RUN apt-get update
RUN apt-get install -y musl-tools

RUN rustup --version
RUN rustup install nightly-2020-01-02 && \
    rustup default nightly-2020-01-02 && \
    rustup target add x86_64-unknown-linux-musl

RUN rustc --version && \
    rustup --version && \
    cargo --version

WORKDIR /app
COPY . /app
RUN cargo clean && cargo build --release --target x86_64-unknown-linux-musl
RUN strip ./target/x86_64-unknown-linux-musl/release/bloom

FROM scratch

WORKDIR /usr/src/bloom

COPY --from=build /app/target/x86_64-unknown-linux-musl/release/bloom /usr/local/bin/bloom

CMD [ "bloom", "-c", "/etc/bloom.cfg" ]

EXPOSE 8080 8811
