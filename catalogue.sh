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
        echo -e "$2 ......$R FAILED $N"
        exit 1
    else
        echo -e "$2 ......$G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR :: Pls run this with root user $N"
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

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOG_FILE

VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOG_FILE

VALIDATE $? "Downloading Zip file"

cd /app &>> $LOG_FILE

VALIDATE $? "changing directory"

unzip -o /tmp/catalogue.zip &>> $LOG_FILE

VALIDATE $? "unzipping catalogue file"

npm install &>> $LOG_FILE

VALIDATE $? "Installing dependencies"

# use absolute, because catalogue.service exists there
cp /home/centos/roboshop-shell-dev/catalogue.service /etc/systemd/system/catalogue.service &>> $LOG_FILE

VALIDATE $? "Copying catalogue service file"

systemctl daemon-reload &>> $LOG_FILE

VALIDATE $? "Catalogue Deamon reload"

systemctl enable catalogue &>> $LOG_FILE

VALIDATE $? "Enabling catalogue service"

systemctl start catalogue &>> $LOG_FILE

VALIDATE $? "Starting catalogue service"

cd /home/centos/roboshop-shell-dev/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE

VALIDATE $? "Copying mongo repo"

dnf install mongodb-org-shell -y &>> $LOG_FILE

VALIDATE $? "Installing mongodb clent to load data"

mongo --host $MONGODBSERVERIPADDRESS </app/schema/catalogue.js &>> $LOG_FILE

VALIDATE $? "Loading catalouge data into MongoDB"

