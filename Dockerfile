FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taipei
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# setup maria datadir
RUN mkdir -p /data/mysql
RUN mkdir /data/mysql/logs

RUN apt-get update && apt-get install -y \
    software-properties-common \
    lsb-release \
    gnupg2 \
    wget \
    curl \
    vim \
    less \
    unzip \
    bash \
    inetutils-ping \
    inetutils-tools \
    net-tools \
    lsb-release \
    percona-toolkit \
    dnsutils \
    software-properties-common \
    ntp \
    gnupg2 \
    tmux \
    netcat \
    rsyslog \
    telnet \
    pv \
    ncdu \
    jq \
    iptables \
    sysstat \
    openssh-server \
    openssh-client \
    ca-certificates \
    && apt-get clean

# Add the MariaDB 10.11 repository
RUN curl -fsSL https://mariadb.org/mariadb-release.key | tee /etc/apt/trusted.gpg.d/mariadb.asc
RUN DISTRO=$(lsb_release -c | awk '{print $2}') && echo "deb [arch=amd64,arm64,ppc64el] https://mirrors.fossho.st/mariadb/repo/10.11/ubuntu $DISTRO main" > /etc/apt/sources.list.d/mariadb.list

# Update the package list and install MariaDB server
RUN apt-get update && apt-get install -y mariadb-server

# Expose the default MariaDB port
EXPOSE 3306

# Expose consul ports
EXPOSE 8500 8600 8300 8301 8302 8400 8501 8601

# move datadir
RUN mv /var/lib/mysql /data/mysql/data
RUN chmod 775 /data/mysql/data
RUN chown mysql:mysql -R /data/mysql/data
RUN ln -s /data/mysql/data /var/lib/mysql

# setup binlig dir
RUN mkdir /data/mysql/binlog
RUN chown mysql:mysql -R /data/mysql/binlog

# setup relay dir
RUN mkdir /data/mysql/relaylog
RUN chown mysql:mysql -R /data/mysql/relaylog

# setup config files
RUN rm -rf /etc/mysql/mariadb.conf.d
COPY ./config/mariadb.conf.d /data/mysql/config
RUN ln -s /data/mysql/config /etc/mysql/mariadb.conf.d
RUN chown mysql:mysql -R /data/mysql/config

# Start MariaDB service and set the default command
#CMD ["mysqld"]
