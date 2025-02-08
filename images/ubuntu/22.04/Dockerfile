FROM ubuntu:22.04@sha256:ed1544e454989078f5dec1bfdabd8c5cc9c48e0705d07b678ab6ae3fb61952d2 AS base

# checkov:skip=CKV_DOCKER_3:"Allow root user"
# checkov:skip=CKV_DOCKER_2:"No healthcheck"

# FROM base AS builder

# COPY ./scripts /scripts
# RUN chmod +x /scripts/*.sh && \
#   /scripts/build.sh && \
#   rm -rf /scripts

# FROM base AS installer

# COPY --from=builder /usr/local/ /usr/local/

# COPY ./scripts /scripts
# RUN chmod +x /scripts/*.sh && \
#   /scripts/install.sh && \
#   /scripts/configure.sh && \
#   /scripts/cleanup.sh && \
#   rm -rf /scripts

# FROM scratch AS final

# COPY --from=installer / /

# ENV PATH="${PATH}:/usr/local/go/bin:/root/.cargo/bin:/root/.local/bin"

CMD [ "/bin/bash" ]
