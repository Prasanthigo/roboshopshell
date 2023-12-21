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
cp ./mongodb.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "COPIED MOGODB REPO"
yum install mongodb-org -y &>> $LOGFILE
VALIDATE $? "installing mongo-db"
systemctl enable mongod &>> $LOGFILE
VALIDATE $? "enabling mongodb-service"
systemctl start mongod &>> $LOGFILE
VALIDATE $? "starting mongodb"
sed -i "/s/127.0.0.1/0.0.0.0/" /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "Edited mongodb conf"
systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restarted mongodb"

