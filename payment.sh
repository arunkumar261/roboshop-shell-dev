#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR :: Pls run this script wih root user $N"
    exit 1
else
    echo -e "$G You are a root user $N"
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        else -e "$R ..... FAILED $N "
        exit 1
    else
        else -e "$G ..... SUCCESS $N "
    fi
}


dnf install python36 gcc python3-devel -y &>> $LOG_FILE

VALIDATE $? "Installing python module"

id roboshop
if [ $? -ne 0 ]
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app 

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOG_FILE

VALIDATE $? "Downloading the payment zip file"

cd /app 

unzip -o /tmp/payment.zip &>> $LOG_FILE

VALIDATE $? "Unzipping the payment"

pip3.6 install -r requirements.txt &>> $LOG_FILE

VALIDATE $? "Installing Dependencies"

cp /home/centos/roboshop-shell-dev/payment.service /etc/systemd/system/payment.service &>> $LOG_FILE

VALIDATE $? "Copying payment service file"

systemctl daemon-reload &>> $LOG_FILE
 
VALIDATE $? "Deamon reload"

systemctl enable payment &>> $LOG_FILE

VALIDATE $? "Enabling payment"

systemctl start payment &>> $LOG_FILE

VALIDATE $? "Starting Payment"

