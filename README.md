# MariaDB + Consul Replication Lab

A three-node MariaDB replication lab with Consul.

## Build and Manage Containers

### Build and start a new lab

Also use this after changing the Dockerfile or files copied into the image:

```bash
docker compose up -d --build
```

### Start stopped containers

```bash
docker compose start
```

### Recreate removed containers and start them

```bash
docker compose up -d
```

Also use this after changing Compose settings, such as ports or environment variables.

### Restart after changing bind-mounted configuration files

```bash
docker compose restart
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

Exit the SQL client:

```sql
EXIT;
```

Then test password login from the container shell:

```bash
mariadb -u root -p
```

Repeat on each node as needed. Replace the example password before use.

## Set Up Replication

This setup uses:

- **Primary:** `mariadb-lab-1`
- **Replicas:** `mariadb-lab-2` and `mariadb-lab-3`

Each node must have a unique `server_id` and binary logging enabled.

If the primary already contains application data, seed the replicas from a consistent backup and configure the corresponding GTID position before starting replication.

### Configure the primary

At the MariaDB prompt on `mariadb-lab-1`:

```sql
SET GLOBAL read_only = OFF;

CREATE USER 'repl'@'%' IDENTIFIED BY 'ReplicationPassword';

GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
```

Persist the primary's writable setting in its `my.cnf`:

```ini
[mysqld]
read_only = OFF
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
