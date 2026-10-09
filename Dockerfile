FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taipei

ARG CONSUL_VERSION=1.22.7

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone

# Install system packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        dnsutils \
        gnupg2 \
        inetutils-ping \
        inetutils-tools \
        iptables \
        jq \
        lsb-release \
        ncdu \
        net-tools \
        netcat-openbsd \
        ntp \
        openssh-client \
        openssh-server \
        percona-toolkit \
        pv \
        rsyslog \
        software-properties-common \
        sysstat \
        telnet \
        unzip \
        curl \
    && rm -rf /var/lib/apt/lists/*


# MariaDB installation from official repository
RUN curl -LsS \
        https://r.mariadb.com/downloads/mariadb_repo_setup \
        -o /tmp/mariadb_repo_setup \
    && chmod +x /tmp/mariadb_repo_setup \
    && /tmp/mariadb_repo_setup \
        --mariadb-server-version="mariadb-10.11" \
        --skip-maxscale \
        --skip-tools \
    && rm -f /tmp/mariadb_repo_setup

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        mariadb-server \
        mariadb-client \
    && rm -rf /var/lib/apt/lists/*


# MariaDB filesystem Setup, as I don't want to use default mariadb filesystem for maintainability
RUN mkdir -p \
        /data/mysql/data \
        /data/mysql/logs \
        /data/mysql/binlog \
        /data/mysql/relaylog \
        /data/mysql/config \
        /run/mysqld \
        /run/sshd 

RUN rm -rf /var/lib/mysql /data/mysql/data \
    && chown -R mysql:mysql /data/mysql /run/mysqld \
    && ln -s /data/mysql/data /var/lib/mysql


# Entrypoint
COPY ./scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh


# Exposed ports
EXPOSE 3306
EXPOSE 22  

# Startup
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
