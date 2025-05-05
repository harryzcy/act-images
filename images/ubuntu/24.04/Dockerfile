FROM ubuntu:24.04@sha256:6015f66923d7afbc53558d7ccffd325d43b4e249f41a6e93eef074c9505d2233 AS base

# checkov:skip=CKV_DOCKER_3:"Allow root user"
# checkov:skip=CKV_DOCKER_2:"No healthcheck"

FROM base AS builder

COPY ./scripts /scripts
RUN chmod +x /scripts/*.sh && \
  /scripts/build.sh && \
  rm -rf /scripts

FROM base AS installer

COPY --from=builder /usr/local/ /usr/local/

COPY ./scripts /scripts
RUN chmod +x /scripts/*.sh && \
  /scripts/install.sh && \
  /scripts/configure.sh && \
  /scripts/cleanup.sh && \
  rm -rf /scripts

FROM scratch AS final

COPY --from=installer / /

ENV PATH="${PATH}:/usr/local/go/bin:/root/.cargo/bin:/root/.local/bin"

CMD [ "/bin/bash" ]
