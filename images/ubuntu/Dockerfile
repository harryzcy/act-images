FROM ubuntu:22.04

ADD ./scripts /scripts
RUN chmod +x /scripts/*.sh && /scripts/install.sh && /scripts/configure.sh && rm -rf /scripts

ENV PATH="${PATH}:/root/.local/bin"

CMD [ "/bin/bash" ]
