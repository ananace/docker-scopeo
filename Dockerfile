FROM ubuntu:18.10 AS build

RUN apt-get update -y \
 && apt-get install -y \
      golang btrfs-tools git-core go-md2man \
      libgpgme11-dev libglib2.0-dev

ARG BUILDTAGS=""
ENV GOPATH=/
RUN git clone --depth 1 https://github.com/containers/skopeo $GOPATH/src/github.com/containers/skopeo && \
    cd $GOPATH/src/github.com/containers/skopeo && \
    make binary-local-static BUILDTAGS="$BUILDTAGS" && \
    mkdir -p /etc/containers && \
    cp default-policy.json /etc/containers/policy.json && \
    cp skopeo /skopeo && \
    ./skopeo --help

FROM alpine

COPY --from=build /skopeo /skopeo
COPY --from=build /etc/containers /etc/containers

RUN apk add --no-cache ca-certificates

ENTRYPOINT [ "/skopeo" ]
