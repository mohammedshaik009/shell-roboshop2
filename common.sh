#!/bin/bash

LOGS_FOLDER=/var/log/shell-script
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo -e "$TIMESTAMP [INFO] script started"

USERID=$(id -u)
#check root access or not
check_root(){
    if [ $USERID -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $R please run this script with root access $N" | tee -a $LOGS_FILE
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2 is...$R FAILED $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$TIMESTAMP [INFO] $2 is...$G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

print_total_time(){

    echo -e "$TIMESTAMP [INFO] script executed in $G $SECONDS seconds $N"  
}

app_setup(){
    id roboshop &>> $LOGS_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
        VALIDATE $? "creating system user"
    else
        echo -e "system user already created ....$Y SKIPPING $N" 
    fi

rm -rf /app &>> $LOGS_FILE
VALIDATE $? "removing app directory"

mkdir -p /app &>> $LOGS_FILE
VALIDATE $? "creating app directory" 

rm -rf /tmp/$app_name.zip  &>> $LOGS_FILE
VALIDATE $? "removing existing code"

curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>> $LOGS_FILE
cd /app 
unzip /tmp/$app_name.zip &>> $LOGS_FILE
VALIDATE $? "download and extracted $app_name code"
}

nodejs_setup(){   
dnf module disable nodejs -y   &>> $LOGS_FILE
dnf module enable nodejs:20 -y   &>> $LOGS_FILE
dnf install nodejs -y   &>> $LOGS_FILE
VALIDATE $? "installing nodejs"
npm install &>> $LOGS_FILE
VALIDATE $? "installing dependencies"
}

systemd_setup(){
cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service &>> $LOGS_FILE
VALIDATE $? "created systemctl service"
systemctl daemon-reload
systemctl enable $app_name  $LOGS_FILE
VALIDATE $? $app_name
}

app_restart(){
systemctl restart $app_name &>> $LOGS_FILE
VALIDATE $? "restarting $app_name"
}