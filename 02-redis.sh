#!/bin/bash

source ./common.sh
check_root

dnf module disable redis -y  &>> $LOGS_FILE
dnf module enable redis:7 -y &>> $LOGS_FILE
dnf install redis -y &>> $LOGS_FILE
VALIDATE $? "installing Redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf  &>> $LOGS_FILE
VALIDATE $? "Allowing remote connetions to all"

systemctl enable --now redis &>> $LOGS_FILE
VALIDATE $? "enabling and starting redis"

print_total_time