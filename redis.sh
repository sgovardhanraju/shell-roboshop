#!/bin/bash
START_TIME=$(date +%s)
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

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling default Redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling Redis 7"

dnf install redis -y &>>$LOG_FILE
VALIDATE "Installing Redis"

#127.0.0.1 to 0.0.0.0 protected-mode from yes to no
sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing Remote connections to Redis"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enablig Redis"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "Starting Redis" 

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))
echo -e "Sctipt executed in: $Y $TOTAL_TIME Seconds"