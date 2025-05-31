#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOG_FILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .....$R FAILED $N"   
        exit 1
    else
        echo -e "$2 .....$G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR :: Pls run this script wih root user $N"
    exit 1
else
    echo -e "$G You are a root user $N"
fi

dnf install nginx -y &>> $LOG_FILE

VALIDATE $? "Installing NGINX"

systemctl enable nginx &>> $LOG_FILE

VALIDATE $? "Enabling NGINX"

systemctl start nginx &>> $LOG_FILE

VALIDATE $? "Starting NGINX"

rm -rf /usr/share/nginx/html/* &>> $LOG_FILE

VALIDATE $? "Removing default NGINX html file"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOG_FILE

cd /usr/share/nginx/html &>> $LOG_FILE

VALIDATE $? "moving nginx html directory"

unzip -o /tmp/web.zip &>> $LOG_FILE
 
VALIDATE $? "Unzipping NGINX"

cp /home/centos/roboshop-shell-dev/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOG_FILE

VALIDATE $? "copied roboshop reverse proxy config"

systemctl restart nginx &>> $LOG_FILE

VALIDATE $? "Restarting NGINX"