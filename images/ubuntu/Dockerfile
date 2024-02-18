FROM ubuntu:22.04@sha256:f9d633ff6640178c2d0525017174a688e2c1aef28f0a0130b26bd5554491f0da as base

# checkov:skip=CKV_DOCKER_3:"Allow root user"
# checkov:skip=CKV_DOCKER_2:"No healthcheck"

FROM base as builder

COPY ./scripts /scripts
RUN chmod +x /scripts/*.sh && \
  /scripts/build.sh && \
  rm -rf /scripts

FROM base as installer

COPY --from=builder /usr/local/ /usr/local/

COPY ./scripts /scripts
RUN chmod +x /scripts/*.sh && \
  /scripts/install.sh && \
  /scripts/configure.sh && \
  /scripts/cleanup.sh && \
  rm -rf /scripts

FROM scratch as final

COPY --from=installer / /

ENV PATH="${PATH}:/usr/local/go/bin:/root/.cargo/bin:/root/.local/bin"

CMD [ "/bin/bash" ]
