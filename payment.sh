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
yum install python36 gcc python3-devel -y
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
curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip
cd /app 
unzip /tmp/payment.zip
pip3.6 install -r requirements.txt
cp /home/centos/roboshopshell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "copying service file"
systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading the service"
systemctl enable payment &>> $LOGFILE
VALIDATE $? "enabling the service"
systemctl start payment &>> $LOGFILE
VALIDATE $? "starting the service"