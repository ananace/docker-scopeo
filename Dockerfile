FROM alpine

RUN apk add --no-cache ca-certificates skopeo \
 && ln -s /usr/bin/skopeo /skopeo \
 && /skopeo --help

ENTRYPOINT [ "/skopeo" ]
