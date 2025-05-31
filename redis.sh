#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOG_FILE

if [ $ID -ne 0 ]
then 
    echo -e "$R ERROR :: Pls run this script with root user $N"
    exit
else
    echo -e "$G You are a root user $N"
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 ..... $R FAILED $N"
        exit 1
    else
          echo -e "$2 .....$G SUCCESS $N"
    fi
}

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.6.rpm -y &>> $LOG_FILE

VALIDATE $? "Installing Remi release"

dnf module enable redis:remi-6.2 -y &>> $LOG_FILE

VALIDATE $? "Enabling redis module"

dnf install redis -y &>> $LOG_FILE

VALIDATE $? "Installing redis module"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/redis/redis.conf &>> $LOG_FILE

VALIDATE $? "allowing remote connections"

systemctl enable redis &>> $LOG_FILE

VALIDATE $? "Enabling redis service"

systemctl start redis &>> $LOG_FILE

VALIDATE $? "Starting redis"