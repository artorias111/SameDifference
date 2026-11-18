FROM debian:bookworm-slim

ARG NGSPARALOG_COMMIT=43340896457d0da03a9162699259df5a103980b0

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential git ca-certificates samtools \
    && git clone https://github.com/tplinderoth/ngsParalog.git /opt/ngsParalog \
    && cd /opt/ngsParalog \
    && git checkout ${NGSPARALOG_COMMIT} \
    && make \
    && cp ngsParalog /usr/local/bin/ \
    && cd / && rm -rf /opt/ngsParalog /var/lib/apt/lists/*

LABEL ngsparalog.commit=${NGSPARALOG_COMMIT}