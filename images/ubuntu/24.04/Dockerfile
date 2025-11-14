FROM ubuntu:24.04@sha256:e96e81f410a9f9cae717e6cdd88cc2a499700ff0bb5061876ad24377fcc517d7 AS base

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
