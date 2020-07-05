FROM kurukurumaware/part-mirakurun-build AS part-mirakurun

FROM kurukurumaware/part-recpt1-build AS part-recpt1

FROM kurukurumaware/part-arib-b25-stream-test AS part-arib-b25-stream-test

FROM alpine:3.12 AS mirakurun-work

RUN apk add  --no-cache bash tzdata socat
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
RUN echo "Asia/Tokyo" > /etc/timezone
ADD https://raw.githubusercontent.com/kurukurumaware/DockerTools/master/extractlibrary \
    /usr/local/bin/extractlibrary
RUN chmod +x /usr/local/bin/extractlibrary
#RUN curl -fsSL https://raw.githubusercontent.com/kurukurumaware/DockerTools/master/extractlibrary \
#    -o /usr/local/bin/extractlibrary \
#    && chmod +x /usr/local/bin/extractlibrary


RUN echo /usr/bin/socat >> binlist
RUN extractlibrary binlist /copydir

COPY --from=part-mirakurun /copydir /copydir
COPY --from=part-recpt1 /copydir /copydir
COPY --from=part-arib-b25-stream-test /copydir /copydir
RUN cp --archive --parents --no-dereference /etc/localtime /copydir
RUN cp --archive --parents --no-dereference /etc/timezone /copydir

#FROM node:14.4.0-alpine3.12
ENV LOG_LEVEL=${LOG_LEVEL:-"2"} \
    SERVER_CONFIG_PATH=/app-config/server.yml \
    TUNERS_CONFIG_PATH=/app-config/tuners.yml \
    CHANNELS_CONFIG_PATH=/app-config/channels.yml \
    SERVICES_DB_PATH=/app-data/services.yml \
    PROGRAMS_DB_PATH=/app-data/programs.yml \
    PATH=/opt/bin:$PATH \
    DOCKER=YES

#COPY --from=mirakurun-work /copydir /

ENTRYPOINT [""]
SHELL ["/bin/sh","-l","-c"]
CMD [""]
