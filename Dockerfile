FROM docker.io/library/ubuntu:22.04 AS build

RUN apt-get update -y \
 && apt-get install -y \
      golang git-core go-md2man \
      libglib2.0-dev make

ARG BUILDTAGS=""
ENV GOPATH=/
RUN set -x \
 && git clone --depth 1 https://github.com/containers/skopeo $GOPATH/src/github.com/containers/skopeo \
 && cd $GOPATH/src/github.com/containers/skopeo \
 && make bin/skopeo DISABLE_CGO=1 \
 && mkdir -p /etc/containers/registries.d \
 && cp default-policy.json /etc/containers/policy.json \
 && cp default.yaml /etc/containers/registries.d/default.yaml \
 && cp bin/skopeo /skopeo \
 && /skopeo --version

FROM docker.io/frolvlad/alpine-glibc

COPY --from=build /skopeo /skopeo
COPY --from=build /etc/containers /etc/containers

RUN apk add --no-cache ca-certificates \
 && /skopeo --version \
 && /skopeo --help

ENTRYPOINT [ "/skopeo" ]
