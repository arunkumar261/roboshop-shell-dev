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


dnf install maven -y

VALIDATE $? "Installing maven"

if [ $? -ne 0 ]
then 
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app

VALIDATE $? "creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOG_FILE

VALIDATE $? "Downloading shipping"

cd /app

VALIDATE $? "moving to app directory"

unzip -o /tmp/shipping.zip &>> $LOG_FILE

VALIDATE $? "unzipping shipping"

mvn clean package &>> $LOG_FILE

VALIDATE $? "Installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOG_FILE

VALIDATE $? "renaming jar file"

cp /home/centos/roboshop-shell-dev/shipping.service /etc/systemd/system/shipping.service &>> $LOG_FILE

VALIDATE $? "copying shipping service"

systemctl daemon-reload &>> $LOG_FILE

VALIDATE $? "deamon reload"

systemctl enable shipping  &>> $LOG_FILE

VALIDATE $? "enable shipping"

systemctl start shipping &>> $LOG_FILE

VALIDATE $? "start shipping"

dnf install mysql -y &>> $LOG_FILE

VALIDATE $? "install MySQL client"

mysql -h mysql.daws76s.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOG_FILE

VALIDATE $? "loading shipping data"

systemctl restart shipping &>> $LOG_FILE

VALIDATE $? "restart shipping"