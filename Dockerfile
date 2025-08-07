FROM alpine:3.20

RUN  apk add --no-cache rsync curl

CMD  while true; echo "version 0.5"; do sleep 1000; done
