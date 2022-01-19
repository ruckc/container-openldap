FROM docker.io/debian:stable AS build

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install \
        diffutils file gcc groff-base make \
        libltdl-dev libssl-dev libsasl2-dev \
        -y && \
    apt-get clean && \
    mkdir /src

ADD openldap-2.6.0.tgz /src
WORKDIR /src/openldap-2.6.0
RUN ls && \
    ./configure --prefix=/opt/openldap \
                --with-cyrus-sasl \
                --with-tls=openssl \
                --disable-cleartext \
                --disable-syslog \
                --disable-ipv6 \
                --enable-modules \
                --enable-spasswd \
                --enable-overlays \
                --enable-ppolicy \
                --enable-refint \
                --enable-memberof \
                --enable-dyngroup \
                --enable-dynlist \
                && \
    make depend && \
    make && \
    make install

FROM docker.io/debian:stable

COPY --from=build /opt/openldap/ /opt/openldap

RUN mkdir /data && \
    useradd -u 1000 -m ldap && \
    chown -R ldap:ldap /data && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install libtool openssl libsasl2-2 lsof gettext-base procps -y && \
    apt-get clean && \
    echo "export PATH=$PATH:/opt/openldap/bin:/opt/openldap/sbin" >> /home/ldap/.bashrc && \
    mkdir -p /opt/template /opt/base && \
    cp -rv /opt/openldap/etc/openldap/* /opt/template && \
    chown -R 1000:1000 /opt/template /opt/base

COPY /scripts /scripts
COPY --chown=1000:1000 conf/slapd.d /opt/base/slapd.d

VOLUME /data
VOLUME /tmp

ENV LDAP_SUFFIX=dc=example,dc=com

USER 1000

ENTRYPOINT ["/scripts/entrypoint.sh"]
