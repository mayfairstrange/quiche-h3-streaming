FROM rust:1.82 AS build

WORKDIR /build

COPY Cargo.toml ./
COPY apps/ ./apps/
COPY buffer-pool ./buffer-pool/
COPY datagram-socket/ ./datagram-socket/
COPY h3i/ ./h3i/
COPY octets/ ./octets/
COPY qlog/ ./qlog/
COPY quiche/ ./quiche/
COPY task-killswitch ./task-killswitch/
COPY tokio-quiche ./tokio-quiche/

RUN apt-get update && apt-get install -y cmake && rm -rf /var/lib/apt/lists/*

RUN cargo build \
    --release \
    --features sfv \
    --bin quiche-server \
    --manifest-path apps/Cargo.toml
	
##
## quiche-base: quiche image for apps
##
FROM debian:latest AS quiche-base

RUN apt-get update && apt-get install -y ca-certificates && \
    rm -rf /var/lib/apt/lists/*
	
## Install iproute2 so we can call `tc`:

# install ca-certs (for HTTPS), tc (iproute2) and openssl
RUN apt-get update && \
    apt-get install -y \
      ca-certificates \
      iproute2 \
      openssl && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build \
     /build/target/release/quiche-server \
     /usr/local/bin/

# copy your entrypoint script in
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# copy your htdocs folder (test.html, .glb files, etc)
COPY htdocs/ /srv/quiche/htdocs/
# copy the Quiche demo certificate & key
COPY apps/src/bin/cert.crt /srv/quiche/htdocs/cert.pem
COPY apps/src/bin/cert.key /srv/quiche/htdocs/key.pem

ENV PATH="/usr/local/bin:${PATH}"
ENV RUST_LOG=info

# expose UDP+TCP for port 4433
EXPOSE 4433/udp
EXPOSE 4433/tcp


##
## quiche-qns: quiche image for quic-interop-runner
## https://github.com/marten-seemann/quic-network-simulator
## https://github.com/marten-seemann/quic-interop-runner
##
FROM martenseemann/quic-network-simulator-endpoint:latest AS quiche-qns

WORKDIR /quiche

RUN apt-get update && apt-get install -y wait-for-it && rm -rf /var/lib/apt/lists/*

COPY --from=build \
     /build/target/release/quiche-server \
     /build/apps/run_endpoint.sh \
     ./

ENV RUST_LOG=trace

ENTRYPOINT [ "./run_endpoint.sh" ]


##
## quiche-server: shaped‐network HTTP/3 server
##
FROM quiche-base AS quiche-server

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]