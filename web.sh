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
yum install nginx -y &>> $LOGFILE
VALIDATE $? "installing nginx"
systemctl enable nginx &>> $LOGFILE
VALIDATE $? "enabling nginx"
systemctl start nginx &>> $LOGFILE
VALIDATE $? "starting nginx"
rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "removing default files in nginx"
curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "downloading code"
cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "changing the dir"
unzip -o /tmp/web.zip &>> $LOGFILE
VALIDATE $? "unzipping"
cp /home/centos/roboshopshell/roboshop.conf /etc/nginx/default.d/roboshop.conf  &>> $LOGFILE
VALIDATE $? "copying service file"
systemctl restart nginx &>> $LOGFILE
VALIDATE $? "restarting nginx"