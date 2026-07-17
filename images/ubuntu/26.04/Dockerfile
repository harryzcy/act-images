FROM ubuntu:26.04@sha256:3131b4cc82a783df6c9df078f86e01819a13594b865c2cad47bd1bca2b7063bb AS base

# checkov:skip=CKV_DOCKER_3:"Allow root user"
# checkov:skip=CKV_DOCKER_2:"No healthcheck"

FROM base AS parse-versions

COPY packages.json /packages.json
RUN apt-get update && apt-get install -y --no-install-recommends \
  jq && \
  jq -r '.[] | .items[] | select(.version) | "\(.name | ascii_upcase | gsub("[ .-]"; "_"))_VERSION=\(.version | @sh)"' /packages.json > /versions.env && \
  cat /versions.env

FROM base AS builder

COPY --from=parse-versions /versions.env /versions.env
COPY ./scripts /scripts
RUN chmod +x /scripts/*.sh && \
  /scripts/build.sh && \
  rm /versions.env && \
  rm -rf /scripts

FROM base AS installer

COPY --from=builder /usr/local/ /usr/local/
COPY --from=builder /root/.cargo/ /root/.cargo/
COPY --from=builder /root/.rustup/ /root/.rustup/

COPY --from=parse-versions /versions.env /versions.env
COPY ./scripts /scripts
RUN chmod +x /scripts/*.sh && \
  /scripts/install.sh && \
  /scripts/configure.sh && \
  /scripts/cleanup.sh && \
  rm /versions.env && \
  rm -rf /scripts

FROM scratch AS final

COPY --from=installer / /

ENV PATH="${PATH}:/usr/local/go/bin:/root/.cargo/bin:/root/.local/bin"

CMD [ "/bin/bash" ]
