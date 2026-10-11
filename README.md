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


