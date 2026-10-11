# MariaDB + Consul Replication Lab

## Build

```bash
docker compose up -d --build   <<< If starting a new lab, or Dockerfile or compose settings changed
docker compose start           <<< containers stopped but still exist
docker compose up -d           <<< if containers were removed
docker compose restart         <<< if bind-mounted my.cnf or entrypoint script changed



## Individual Components

### Start containers

```bash
docker start mariadb-lab-1
docker start mariadb-lab-2
docker start mariadb-lab-1

### Enter each container ideally using tmux and start MariaDB 

```bash
docker exec -it mariadb-lab-1 bash
docker exec -it mariadb-lab-2 bash
docker exec -it mariadb-lab-3 bash


Start MariaDB with and login
```bash 
/etc/init.d/mariadb start
mysql


NOTE: Setup a root password after initial login

```bash
ALTER USER 'root'@'localhost' IDENTIFIED BY 'StrongPasswordHere';
mysql -u root -p



## Setup Relication

### On the primary node, enable writes and create a replication user:

```bash
SET GLOBAL read_only = 0;
CREATE USER 'repl'@'%' IDENTIFIED BY 'ReplicationPassword';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';


### On each of the remaining two replica nodes, setup replication 

````bash
CHANGE MASTER TO
    MASTER_HOST = 'mariadb-lab-1',
    MASTER_PORT = 3306,
    MASTER_USER = 'repl',
    MASTER_PASSWORD = 'YourReplicationPassword',
    MASTER_USE_GTID = slave_pos;

START SLAVE; SHOW SLAVE STATUS\G
