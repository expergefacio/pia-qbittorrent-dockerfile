FROM alpine:latest

RUN apk add --no-cache curl bash inotify-tools

COPY update-qbit-port.sh /usr/local/bin/update-qbit-port.sh

CMD ["bash", "/usr/local/bin/update-qbit-port.sh"]
