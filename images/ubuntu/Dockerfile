FROM ubuntu:22.04

RUN apt update && apt-get install -y \
  && apt-get autoremove -y

ADD ./scripts /scripts
RUN chmod +x /scripts/*.sh && /scripts/install.sh

CMD [ "/bin/bash" ]
