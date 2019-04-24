FROM ubuntu:18.10 AS build

RUN apt-get update -y \
 && apt-get install -y \
      golang git-core go-md2man \
      libglib2.0-dev

ARG BUILDTAGS=""
ENV GOPATH=/
RUN git clone --depth 1 https://github.com/containers/skopeo $GOPATH/src/github.com/containers/skopeo && \
    cd $GOPATH/src/github.com/containers/skopeo && \
    make binary-local-static DISABLE_CGO=1 && \
    mkdir -p /etc/containers && \
    cp default-policy.json /etc/containers/policy.json && \
    cp skopeo /skopeo && \
    ./skopeo --help

FROM frolvlad/alpine-glibc

COPY --from=build /skopeo /skopeo
COPY --from=build /etc/containers /etc/containers

RUN apk add --no-cache ca-certificates

ENTRYPOINT [ "/skopeo" ]
