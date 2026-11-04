#!/bin/bash

source ./common.sh
check_root


cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo repo"

dnf install mongodb-org -y   &>> $LOGS_FILE
VALIDATE $? "installing MongoDB"

systemctl enable --now mongod &>> $LOGS_FILE
VALIDATE $? "starting and enabling MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGS_FILE
VALIDATE $? "Allowing remote connetions"

systemctl restart mongod &>> $LOGS_FILE
VALIDATE $? "Restarting MongoDB"

print_total_time