#!/bin/bash
START_TIME=$(date +%s)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)

MONGODB_HOST=mongodb.sgrdevsecops.fun
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_DIR=$PWD
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
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling default NodeJS"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling NodeJs:20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJs 20"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating app directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading cart application"

cd /app &>>$LOG_FILE
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/cart.zip &>>$LOG_FILE
VALIDATE $? "unzip catalogue"

npm install &>>$LOG_FILE
VALIDATE $? "Install dependenceis"

cp $SCRIPT_DIR/cart.repo /etc/systemd/system/cart.service &>>$LOG_FILE
VALIDATE $? "Adding cart repo" 

systemctl daemon-reload
systemctl enable cart &>>$LOG_FILE
VALIDATE $? "Enable cart"

systemctl start cart &>>$LOG_FILE
VALIDATE $? "Starting cart"