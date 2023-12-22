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
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE
VALIDATE $? "setting up NPM source"
yum install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing Nodejs"
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
curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "Downloading application code to /tmp"
cd /app &>> $LOGFILE
VALIDATE $? "changing to app dir"
unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "unzipping cart zip file"
npm install &>> $LOGFILE
VALIDATE $? "Downloading dependencies"
cp /home/centos/roboshopshell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading the service"
systemctl enable cart &>> $LOGFILE
VALIDATE $? "enabling the service"
systemctl start cart &>> $LOGFILE
VALIDATE $? "starting the service"
