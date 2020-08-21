FROM node:14.4.0-alpine3.12 AS Mirakurun-build
WORKDIR /app
ENV DOCKER=YES

RUN set -eux && apk upgrade --update
RUN apk add --no-cache curl alpine-sdk
RUN curl -fsSL https://github.com/Chinachu/Mirakurun/tarball/master | tar -xz --strip-components=1
RUN npm install
RUN npm run build
RUN npm install -g --unsafe-perm --production

FROM scratch
WORKDIR /copydir/app
COPY --from=Mirakurun-build /usr/local/lib/node_modules/mirakurun /copydir/app

