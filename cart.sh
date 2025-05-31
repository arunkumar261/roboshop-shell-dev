#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip

VALIDATE $? "Downloading cart application"

cd /app 

unzip -o /tmp/cart.zip  &>> $LOG_FILE

VALIDATE $? "unzipping cart"

npm install  &>> $LOG_FILE

VALIDATE $? "Installing dependencies"

# use absolute, because cart.service exists there
cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOG_FILE

VALIDATE $? "Copying cart service file"

systemctl daemon-reload &>> $LOG_FILE

VALIDATE $? "cart daemon reload"

systemctl enable cart &>> $LOG_FILE

VALIDATE $? "Enable cart"

systemctl start cart &>> $LOG_FILE

VALIDATE $? "Starting cart"