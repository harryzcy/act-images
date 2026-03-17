FROM ubuntu:24.04@sha256:0d39fcc8335d6d74d5502f6df2d30119ff4790ebbb60b364818d5112d9e3e932 AS base

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
