FROM ubuntu:22.04@sha256:e6173d4dc55e76b87c4af8db8821b1feae4146dd47341e4d431118c7dd060a74 as base

FROM base as builder

ADD ./scripts /scripts
RUN chmod +x /scripts/*.sh && \
  /scripts/build.sh && \
  rm -rf /scripts

FROM base as installer

COPY --from=builder /usr/local/ /usr/local/

ADD ./scripts /scripts
RUN chmod +x /scripts/*.sh && \
  /scripts/install.sh && \
  /scripts/configure.sh && \
  /scripts/cleanup.sh && \
  rm -rf /scripts

FROM scratch as final

COPY --from=installer / /

ENV PATH="${PATH}:/usr/local/go/bin:/root/.cargo/bin:/root/.local/bin"

CMD [ "/bin/bash" ]
