FROM ubuntu:22.04@sha256:4f838adc7181d9039ac795a7d0aba05a9bd9ecd480d294483169c5def983b64d AS base

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
