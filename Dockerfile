FROM ubuntu:16.04

MAINTAINER Erwin Mueller "erwin.mueller@nttdata.com"

# Configuration variables.
ENV DEBIAN_FRONTEND noninteractive
ENV ZIMBRA_NAME zcs-8.7.1_GA_1670.UBUNTU16_64.20161025045114
ENV ZIMBRA_ARCHIVE $ZIMBRA_NAME.tgz
ENV ZIMBRA_URL https://files.zimbra.com/downloads/8.7.1_GA/$ZIMBRA_ARCHIVE
ENV ZIMBRA_HASH_URL https://files.zimbra.com/downloads/8.7.1_GA/$ZIMBRA_ARCHIVE.sha256
ENV ZIMBRA_HOST_IP 127.0.0.1
ENV HOST_DOMAIN local
ENV PACKAGE_SERVER repo.zimbra.com

# Download directory.
WORKDIR /tmp

# For local build.
COPY $ZIMBRA_ARCHIVE /tmp/

# Install Zimbra.
RUN set -x \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9BE6ED79 \
    && apt-get update --quiet \
    && apt-get install --quiet --yes \
        apt-transport-https \
    && echo "deb     [arch=amd64] https://$PACKAGE_SERVER/apt/87 xenial zimbra" > /etc/apt/sources.list.d/zimbra.list \
    && echo "deb-src [arch=amd64] https://$PACKAGE_SERVER/apt/87 xenial zimbra" >> /etc/apt/sources.list.d/zimbra.list \
    && apt-get update --quiet \
    && apt-get upgrade --quiet --yes \
    && echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections \
    && apt-get install --quiet --yes \
        wget perl mime-support lsb-release net-tools \
        netcat-openbsd sudo libidn11 libpcre3 libgmp10 libexpat1 libstdc++6 libperl5.22 libaio1 resolvconf unzip pax sysstat sqlite3 \
        rsyslog \
        openssh-server openssh-client \
        supervisor \
    && groupadd -r postdrop \
    && useradd -r -U postfix \
    # Download Zimbra.
    && if [ ! -f $ZIMBRA_ARCHIVE ]; then \
       wget "$ZIMBRA_URL" \
    ; fi \
    && wget "$ZIMBRA_HASH_URL" \
    && echo "`cat $ZIMBRA_ARCHIVE.sha256`" | shasum -c - \
    && tar xf $ZIMBRA_ARCHIVE \
    && mv $ZIMBRA_NAME /usr/local/src \
    && ln -s /usr/local/src/$ZIMBRA_NAME /usr/local/src/zimbra \
    && cd /usr/local/src/zimbra \
    && dpkg -i packages/*.deb; apt-get -f --quiet --yes install \
    && apt-get --yes install zimbra-memcached \
    # Clean up.
    #&& rm -rf /usr/local/src/zimbra/packages/*.deb \
    && apt-get autoclean \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/man/* \
    && rm -rf /usr/share/info/* \
    && rm -rf /var/cache/man/*

# Remote Queue Manager
EXPOSE 22

# Postfix
EXPOSE 25

# HTTP
EXPOSE 80

# POP3
EXPOSE 110

# IMAP
EXPOSE 143

# LDAP
EXPOSE 389

# HTTPS
EXPOSE 443

# Mailboxd IMAP SSL
EXPOSE 993

# Mailboxd Pop SSL
EXPOSE 995

# Mailboxd LMTP
EXPOSE 7025

# Zimbra installation directory.
WORKDIR /opt/zimbra

# Add entrypoint script.
COPY docker-entrypoint.sh /usr/local/bin/

# Add make-persistent script.
COPY make-persistent.sh /usr/local/bin/

# Add make-persistent script.
COPY install-zimbra.sh /usr/local/bin/

# Set entrypoint script.
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Run supervisord.
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

# Add supervisor configuration.
COPY supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY supervisor/zimbra.conf /etc/supervisor/conf.d/
COPY supervisor/cron.conf /etc/supervisor/conf.d/
COPY supervisor/openssh.conf /etc/supervisor/conf.d/

# Set default configuration.
RUN set -x \
    # Make sure scripts is executable.
    && chmod +x /usr/local/bin/*.sh \
    && mkdir -p /opt/etc \
    && mkdir -p /opt/var

# Zimbra directories.
VOLUME ["/opt/etc", "/opt/var", "/opt/zimbra/data", "/opt/zimbra/db", "/opt/zimbra/index", "/opt/zimbra/mariadb", "/opt/zimbra/store", "/opt/zimbra/zmstat"]
