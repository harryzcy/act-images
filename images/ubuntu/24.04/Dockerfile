FROM ubuntu:24.04@sha256:72297848456d5d37d1262630108ab308d3e9ec7ed1c3286a32fe09856619a782 AS base

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
