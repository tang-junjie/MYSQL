#!/bin/bash
##################################
#使用RPM包离线安装MariaDB#########
#时间：20161212			#########
#作者：star				#########
#
#20190904增加my.cnf配置
#1.必须已安装mysql服务
#centos7 安装 MariaDB-10.2.9

#安装 wget https://raw.githubusercontent.com/funet8/MYSQL/master/more-mysql-instance/more-mysql-instance.sh
# sh more-mysql-instance.sh

#MySQL多端口####################
MYSQL_PORY='61920 61921 61922 61923 61924'

#数据库目录####################
mkdir -p /data/mysql/{61920,61921,61922,61923,61924}
#binlog目录####################
mkdir -p /data/mysql/mysqlbinlog/{61920,61921,61922,61923,61924}
#配置目录####################
mkdir -p /data/mysql/etc/
#慢查询目录和权限
mkdir -p /data/mysql/slowQuery/
chmod 777 -R /data/mysql/slowQuery/
####################

#初始化实例-循环
for  port in  $MYSQL_PORY
do
	mysql_install_db --basedir=/usr --datadir=/data/mysql/$port --user=mysql
done

cd /data/mysql/etc/
for  port in  $MYSQL_PORY
do
	wget https://raw.githubusercontent.com/funet8/MYSQL/master/more-mysql-instance/conf/$port.cnf
done

chown mysql.mysql -R /data/mysql/etc/ /data/mysql/mysqlbinlog/

#启动实例
for  port in  $MYSQL_PORY
do
	/usr/bin/mysqld_safe --defaults-file=/data/mysql/etc/$port.cnf &
done

#防火墙开放端口
for  port in  $MYSQL_PORY
do
	iptables -I INPUT -p tcp --dport $port -j ACCEPT
done
service iptables save
systemctl restart iptables


#开机启动
for  port in  $MYSQL_PORY
do
	echo "/usr/bin/mysqld_safe --defaults-file=/data/mysql/etc/${port}.cnf &" >> /etc/rc.local
done

#进入实例
#mysql -u root -S /data/mysql/61920/mysql61920.sock


