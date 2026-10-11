# MariaDB Replication lab

A three-node MariaDB replication lab.

## Build and Manage Containers

### Build and start a new lab


### Start stopped containers

```bash
docker compose up -d --build   <<< Also use this after changing the Dockerfile or files copied into the image
docker compose start           <<< Start stopped containers
docker compose up -d           <<< Recreate removed containers and start them
docker compose restart         <<< Restart after changing bind-mounted configuration files
```


## Individual Components

### Start individual containers

```bash
docker start mariadb-lab-1
docker start mariadb-lab-2
docker start mariadb-lab-3
```

### Enter each container

Use separate terminals or tmux panes:

```bash
docker exec -it mariadb-lab-1 bash
docker exec -it mariadb-lab-2 bash
docker exec -it mariadb-lab-3 bash
```

### Log in to MariaDB

The container entrypoint starts MariaDB automatically. Once it is running, log in inside each container:

```bash
mariadb -u root
```

### Set the root password

At the MariaDB prompt:

```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'StrongPasswordHere';
```

Exit the SQL client then login with with new password:

```bash
exit;
mariadb -u root -p
```


## Set Up Replication

This setup uses:

- **Primary:** `mariadb-lab-1`
- **Replicas:** `mariadb-lab-2` and `mariadb-lab-3`

Each node is already configured with a unique `server_id` and binary logging enabled.

If the primary already contains application data, seed the replicas from a consistent backup and configure the corresponding GTID position before starting replication.

### Configure the primary

At the MariaDB prompt on `mariadb-lab-1`:

```sql
SET GLOBAL read_only = OFF;

CREATE USER 'repl'@'%' IDENTIFIED BY 'ReplicationPassword';

GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
```


Keep `read_only = ON` on the replicas.

### Configure each replica

At the MariaDB prompt on both `mariadb-lab-2` and `mariadb-lab-3`:

```sql
CHANGE MASTER TO
    MASTER_HOST = 'mariadb-lab-1',
    MASTER_PORT = 3306,
    MASTER_USER = 'repl',
    MASTER_PASSWORD = 'ReplicationPassword',
    MASTER_USE_GTID = slave_pos;

START SLAVE;
```

Use the primary's Compose service name or resolvable network alias for `MASTER_HOST`. Use the same replication password configured on the primary.

### Verify replication

On each replica:

```sql
SHOW SLAVE STATUS\G
```

Confirm the following values:

```text
Slave_IO_Running: Yes
Slave_SQL_Running: Yes
Last_IO_Error:
Last_SQL_Error:
```
