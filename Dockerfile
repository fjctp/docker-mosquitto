################################################
FROM alpine:3.8 AS build

ENV MOSQUITTO_VER v1.5.3
ENV SRC_DIR /mosquitto
ENV BIN_DIR /mosquitto/install

RUN apk add --no-cache  make \
                        gcc \
                        g++ \
                        wget
RUN apk add --no-cache  util-linux-dev \
                        c-ares-dev \
                        libwebsockets-dev \
                        openssl-dev \
                        musl-dev
    
RUN mkdir /mosquitto && \
    wget https://github.com/eclipse/mosquitto/archive/${MOSQUITTO_VER}.tar.gz && \
    tar -xzvf ${MOSQUITTO_VER}.tar.gz -C /mosquitto --strip-components=1 && \
    mkdir -p ${BIN_DIR}

WORKDIR ${SRC_DIR}
RUN make WITH_SRV=yes \ 
         WITH_UUID=yes \
         WITH_WEBSOCKETS=yes \
         WITH_TLS=yes \
         WITH_DOCS=no \
         prefix=${BIN_DIR} \
         binary

RUN cp lib/libmosquitto.so.1 ${BIN_DIR} && \
    cp client/mosquitto_sub ${BIN_DIR} && \
    cp client/mosquitto_pub ${BIN_DIR} && \
    cp src/mosquitto ${BIN_DIR} && \
    cp src/mosquitto_passwd ${BIN_DIR} && \
    cp mosquitto.conf ${BIN_DIR}

################################################
FROM alpine:3.8
RUN apk add --no-cache  util-linux \
                        c-ares \
                        libwebsockets \
                        openssl \
                        musl
COPY --from=build /mosquitto/install /tool
RUN cp /tool/libmosquitto.so.1 /usr/lib

EXPOSE 1883

VOLUME [ "/data" ]
VOLUME [ "/conf" ]


#USER 1000:1000
CMD [ "/tool/mosquitto" ]
