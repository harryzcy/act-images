FROM ubuntu:22.04 as base

FROM base as builder

ADD ./scripts /scripts
RUN chmod +x /scripts/*.sh && \
  /scripts/build.sh && \
  rm -rf /scripts

FROM base as final

COPY --from=builder /usr/local/ /usr/local/

ADD ./scripts /scripts
RUN chmod +x /scripts/*.sh && \
  /scripts/install.sh && \
  /scripts/configure.sh && \
  /scripts/cleanup.sh && \
  rm -rf /scripts

ENV PATH="${PATH}:/usr/local/go/bin:/root/.cargo/bin:/root/.local/bin"

CMD [ "/bin/bash" ]
