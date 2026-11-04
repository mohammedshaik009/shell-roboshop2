#!/bin/bash

source ./common.sh
check_root


cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo  &>> $LOGS_FILE
VALIDATE $? "Adding rabbitmq repo"

dnf install rabbitmq-server -y  &>> $LOGS_FILE
VALIDATE $? "installing rabbitmq-server"

systemctl enable --now rabbitmq-server  &>> $LOGS_FILE
VALIDATE $? "enabling and starting"

rabbitmqctl add_user roboshop roboshop123  &>> $LOGS_FILE
VALIDATE $? "adding roboshop user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>> $LOGS_FILE
VALIDATE $? "setting up permissions"

print_total_time