# Lab 01: Setting Up Basic Infrastructure Monitoring Using Zabbix

## Introduction
Zabbix is an enterprise-class open-source monitoring solution for tracking IT infrastructure components including servers, networks, and applications. This lab guides you through installing and configuring Zabbix on Ubuntu 22.04 to monitor your basic infrastructure.

## Objective
By the end of this lab, you will be able to:
- Install and configure Zabbix server with MySQL backend
- Set up the Zabbix web interface
- Access the Zabbix dashboard for basic monitoring

## Prerequisites
- Ubuntu 22.04 system
- sudo privileges
- Basic Linux command line knowledge
- Minimum 2GB RAM (4GB recommended)

---

## Lab Steps

### Step 1: Install Zabbix Packages

1. Download the Zabbix repository package:
```bash
sudo wget https://repo.zabbix.com/zabbix/6.3/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.3-3+ubuntu22.04_all.deb
```

2. Install the downloaded package:
```bash
sudo dpkg -i zabbix-release_6.3-3+ubuntu22.04_all.deb
```

3. Update package lists:
```bash
sudo apt-get update
```

4. Install Zabbix components:
```bash
sudo apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
```

### Step 2: Install MySQL Database

1. Install MySQL server:
```bash
sudo apt install mysql-server
```

2. Start and enable MySQL service:
```bash
sudo systemctl start mysql
sudo systemctl enable mysql
```

### Step 3: Create Initial Database

1. Access MySQL shell:
```bash
sudo mysql
```

2. Create Zabbix database:
```sql
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
```

3. Create Zabbix user:
```sql
CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'pass123';
```

4. Grant privileges:
```sql
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
```

5. Enable binary logging (temporarily):
```sql
SET GLOBAL log_bin_trust_function_creators = 1;
```

6. Exit MySQL:
```sql
quit;
```

### Step 4: Configure Zabbix Database

1. Import initial schema:
```bash
sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix
```
*When prompted, enter password: `pass123`*

2. Disable binary logging:
```bash
sudo mysql -e "SET GLOBAL log_bin_trust_function_creators = 0;"
```

3. Edit Zabbix server configuration:
```bash
sudo vi /etc/zabbix/zabbix_server.conf
```
*Uncomment and set:*
```ini
DBPassword=pass123
```

### Step 5: Start Services

1. Restart services:
```bash
sudo systemctl restart zabbix-server zabbix-agent apache2
sudo systemctl enable zabbix-server zabbix-agent apache2
```

### Step 6: Access Zabbix Web Interface

1. Open in browser:
```
http://localhost/zabbix
```

2. Complete setup wizard:
   - Language: English
   - DB credentials: user=`zabbix`, password=`pass123`
   - Server details: Name=`Your Server Name`
   - Default credentials: Admin/Zabbix

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Database connection failed" | Verify `/etc/zabbix/zabbix_server.conf` has correct DBPassword |
| Apache service not starting | Check `sudo journalctl -xe` for PHP module errors |
| Zabbix dashboard not loading | Ensure SELinux is disabled or properly configured |

---

## Conclusion
You've successfully set up a Zabbix monitoring server that can now:
- Collect metrics from the host system via Zabbix agent
- Store historical data in MySQL
- Provide visualization through the web interface

Next steps would be to:
1. Add additional hosts to monitor
2. Configure email/SMS alerts
3. Set up custom dashboards

## Further Reading
- [Official Zabbix Documentation](https://www.zabbix.com/documentation/current/en)
- [Zabbix Templates Repository](https://share.zabbix.com/)
- [Performance Tuning Guide](https://www.zabbix.com/documentation/current/en/manual/appendix/config/zabbix_server)

> **Pro Tip:** Always change default credentials after installation for security!
