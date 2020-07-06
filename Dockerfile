FROM kurukurumaware/part-mirakurun-build AS part-mirakurun

FROM kurukurumaware/part-recpt1-build AS part-recpt1

FROM kurukurumaware/part-arib-b25-stream-test AS part-arib-b25-stream-test

FROM alpine:3.12 AS mirakurun-work

WORKDIR /tmp
RUN apk add  --no-cache bash curl tzdata v4l-utils-dvbv5 
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
RUN echo "Asia/Tokyo" > /etc/timezone
ADD https://raw.githubusercontent.com/kurukurumaware/DockerTools/master/extractlibrary \
    /usr/local/bin/extractlibrary
RUN chmod +x /usr/local/bin/extractlibrary

RUN echo /usr/bin/dvbv5-zap >> binlist
RUN echo /usr/bin/dvbv5-scan >> binlist
RUN extractlibrary binlist /copydir

COPY --from=part-mirakurun /copydir /copydir
COPY --from=part-recpt1 /copydir /copydir
COPY --from=part-arib-b25-stream-test /copydir /copydir
RUN cp --archive --parents --no-dereference /etc/localtime /copydir
RUN cp --archive --parents --no-dereference /etc/timezone /copydir

RUN mkdir -p /copydir/root/.tzap
RUN curl -fsSL https://github.com/Chinachu/dvbconf-for-isdb/tarball/master | tar -zx --strip-components=1
RUN cat conf/dvbv5_channels_isdbt.conf dvbv5_channels_isdbs.conf \
    | tee /copydir/root/.tzap/channels.conf

COPY mirakurun-run /copydir/app/mirakurun-run
RUN chmod +x /copydir/app/mirakurun-run

# 本体
FROM node:14.4.0-alpine3.12

COPY --from=mirakurun-work /copydir /

SHELL ["/bin/ash","-l","-c"]
CMD ["app/mirakurun-run"]
