FROM golang:1.24 AS builder

ARG PLAYTIME_EJS_REPO_URL
ARG PLAYTIME_EJS_REVISION
ARG PLAYTIME_EJS_CORES_URL

ENV DEBIAN_FRONTEND=noninteractive
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn,direct
ADD . /build

RUN cd /build &&\
    CGO_ENABLED=0 GOOS=linux go build -a -o app . &&\
    ./install.sh

###############################################################################

FROM ubuntu:22.04

COPY --from=builder /build/assets /app/assets/
COPY --from=builder /build/templates /app/templates/
COPY --from=builder /build/app /app/

ADD docker/run.sh /app/

ENV DEBIAN_FRONTEND=noninteractive

RUN useradd --user-group --system playtime &&\
    cd /app &&\
    mkdir -m 0777 data uploads &&\
    chmod 0777 /app &&\
    chown -R playtime:playtime /app

USER playtime
WORKDIR /app
EXPOSE 3000

VOLUME ["/app/data", "/app/uploads"]

CMD ["./run.sh"]
