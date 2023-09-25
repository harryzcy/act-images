FROM ubuntu:22.04

ADD ./scripts /scripts
RUN chmod +x /scripts/*.sh && \
  /scripts/install.sh && \
  /scripts/configure.sh && \
  /scripts/cleanup.sh && \
  rm -rf /scripts

ENV PATH="${PATH}:/root/.local/bin:/usr/local/go/bin:/root/.cargo/bin"

CMD [ "/bin/bash" ]
