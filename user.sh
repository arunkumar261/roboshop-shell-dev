#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGODBSERVERIPADDRESS="mongodb.arundev.store"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOG_FILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ..... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ..... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR :: Pls run this script with the root user$N"
    exit 1
else
    echo -e "$G You are a root user $N"
fi

dnf module disable nodejs -y &>> $LOG_FILE

VALIDATE $? "Disabling default nodejs version"

dnf module enable nodejs:18 -y &>> $LOG_FILE

VALIDATE $? "Enabling specific nodejs version"

dnf install nodejs -y &>> $LOG_FILE

VALIDATE $? "Installing NodeJS"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app 

VALIDATE $? "Creating app dir"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOG_FILE

VALIDATE $? "Downloading user zip file"

cd /app 

# VALIDATE $? "Changing to app dir"

unzip -o /tmp/user.zip &>> $LOG_FILE

VALIDATE $? "Unzipping user file"

npm install &>> $LOG_FILE

VALIDATE $? "Instaling NPM Dependencies"

cp /home/centos/roboshop-shell-dev/user.service /etc/systemd/system/user.service

VALIDATE $? "Copying user service file"

systemctl daemon-reload &>> $LOG_FILE

VALIDATE $? "Deamon reload of user"

systemctl enable user &>> $LOG_FILE

VALIDATE $? "Enabling user service"
 
systemctl start user &>> $LOG_FILE

VALIDATE $? "Starting user"

cp /home/centos/roboshop-shell-dev/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying user"

dnf install mongodb-org-shell -y &>> $LOG_FILE

VALIDATE $? "Installing Mongodb client"

mongo --host $MONGODBSERVERIPADDRESS </app/schema/user.js &>> $LOG_FILE

VALIDATE $? "Downloading user data into MongoDB"