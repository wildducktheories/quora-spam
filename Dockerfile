FROM alpine:latest
RUN apk add bash jq curl make docker coreutils
RUN adduser -D -h /home/quora-spam quora-spam
ENV LAUNCH_DOCKER=false
ADD quora-spam /usr/local/bin
ENTRYPOINT ["/bin/bash", "/usr/local/bin/quora-spam"]

USER quora-spam
RUN mkdir -p /home/quora-spam/host
WORKDIR /home/quora-spam/host