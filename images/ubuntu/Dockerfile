FROM ubuntu:22.04

ADD ./scripts /scripts
RUN chmod +x /scripts/*.sh && /scripts/install.sh

CMD [ "/bin/bash" ]
