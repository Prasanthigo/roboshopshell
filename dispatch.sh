DATE=$(date +%F)
LOGS_DIR=/tmp
SCRIPT_NAME=$0
LOGFILE=$LOGS_DIR/$SCRIPT_NAME-$DATE.log
RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"
USERID=$(id -u)
if [ "$USERID" -ne 0 ]; then
    echo -e "$RED ERROR: Please execute the script with root permissions.$ENDCOLOR"
    exit 1
fi
VALIDATE()
{
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ..........$RED failed $ENDCOLOR"
    else
        echo -e "$2 ...........$GREEN success $ENDCOLOR"
    fi
}
yum install golang -y &>> $LOGFILE
USER_EXISTS=$(cat /etc/passwd | grep "roboshop")
if [ $? -ne 0 ]
then
    useradd roboshop
else
    echo "user already exists"
fi
if [ -d /app ]
then
    echo "directory already exists"
else
    mkdir /app
    echo "directory created"
fi
curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>> $LOGFILE
VALIDATE $? "downloding dispatch.zip code"
cd /app &>> $LOGFILE
VALIDATE $? "changinging to /app"
unzip -o /tmp/dispatch.zip &>> $LOGFILE 
VALIDATE $? "unzipping dispatch.zip"
go mod init dispatch &>> $LOGFILE
go get &>> $LOGFILE
go build &>> $LOGFILE
VALIDATE $? "building"

cp /home/centos/roboshopshell/dispatch.service /etc/systemd/system/dispatch.service &>> $LOGFILE
VALIDATE $? "copying service file"
systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading the service"
systemctl enable dispatch &>> $LOGFILE
VALIDATE $? "enabling the service"
systemctl start dispatch &>> $LOGFILE
VALIDATE $? "starting the service"