# Gunakan base image untuk arsitektur ARM64
FROM varnish:latest
 
USER root
RUN set -ex && apt update && apt install -y net-tools  \
    curl zip vim git telnet python3-pip \
    && pip install supervisor --break-system-packages \
    && pip install git+https://github.com/coderanger/supervisor-stdout --break-system-packages \
    \
    && apt install uuid-runtime -y \
    && uuidgen | tee /etc/varnish/secret \
    \
    && apt purge -y git uuid-runtime \
    && apt autoremove -y && apt clean \
    && rm -rf /var/{cache,log}/* \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/* \
    && rm -rf /tmp/*

WORKDIR /etc/varnish
COPY ./config/default.vcl /etc/varnish/default.vcl
COPY ./config/varnish.params /etc/varnish/varnish.params
COPY ./config/supervisord.conf /etc/supervisord.conf
COPY ./config/backend.txt /etc/varnish/
COPY ./config/Makefile /etc/varnish/
COPY ./config/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8123

CMD sh -c /start.sh
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "curl", "--fail", "localhost:8123/healt" ]