#!/bin/bash

app_name=catalogue
source ./common.sh
check_root
app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGS_FILE
VALIDATE $? "adding mongo repo"

dnf install mongodb-mongosh -y &>> $LOGS_FILE
VALIDATE $? "installing mongodb client"

INDEX=$(mongosh --host mongodb.mohammed.world --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $INDEX -lt 0 ]; then
    mongosh --host mongodb.mohammed.world </app/db/master-data.js &>> $LOGS_FILE
    VALIDATE $? "Load products"
else
    echo -e "products already loaded ....$Y SKIPPING $N"
fi

print_total_time