#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "Script starting excuted at $(date)" | tee -a $LOG_FILE
if [ $USERID -ne 0 ]; then
    echo "ERROR::Please run the script with root privileges"
    exit 1
fi

VALIDATE () { # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e " $2..... $R is failure $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e " $2..... $G is SUCCESS $N" | tee -a $LOG_FILE
    fi

}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding mongo repo" 

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing mongodb" 

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "enable mongodb" 

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "start mongodb" 

sed -i 's/127.0.0.1/0.0.0.0/g' etc/mongod.conf &>>LOG_FILE
VALIDATE $? "allowing remote connetions tp MongoDB"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarted MongoDB"
