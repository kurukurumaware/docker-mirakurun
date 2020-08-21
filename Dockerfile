FROM kurukurumaware/part-mirakurun-build AS part-mirakurun

FROM kurukurumaware/part-recpt1-build AS part-recpt1

FROM kurukurumaware/part-arib-b25-stream-test AS part-arib-b25-stream-test

FROM alpine:3.12 AS mirakurun-work

RUN set -eux \
    && apk update \
    && apk add --no-cache bash curl tzdata v4l-utils-dvbv5
ADD https://raw.githubusercontent.com/kurukurumaware/extlibcp/master/extlibcp /usr/local/bin
RUN chmod +x /usr/local/bin/extlibcp
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
RUN echo "Asia/Tokyo" > /etc/timezon

RUN extlibcp "/usr/bin/dvbv5-zap /usr/bin/dvbv5-scan" /copydir

COPY --from=part-mirakurun /copydir /copydir
COPY --from=part-recpt1 /copydir /copydir
COPY --from=part-arib-b25-stream-test /copydir /copydir

WORKDIR /tmp
RUN mkdir -p /root/.tzap
RUN curl -fsSL https://github.com/Chinachu/dvbconf-for-isdb/tarball/master | tar -zx --strip-components=1
RUN cat conf/dvbv5_channels_isdbt.conf dvbv5_channels_isdbs.conf \
    | tee /root/.tzap/channels.conf

COPY mirakurun-run /app/mirakurun-run
RUN chmod +x /copydir/app/mirakurun-run

RUN echo "\
    /usr/share/zoneinfo/Asia/Tokyo \
    /etc/localtime \
    /etc/timezone \
    /app/mirakurun-run \
    /root/.tzap/channels.conf \
    "|xargs -n1|xargs -I{} cp --archive --parents --no-dereference {} /copydir

# 本体
FROM node:14.4.0-alpine3.12

COPY --from=mirakurun-work /copydir /

SHELL ["/bin/ash","-l","-c"]
CMD ["app/mirakurun-run"]
