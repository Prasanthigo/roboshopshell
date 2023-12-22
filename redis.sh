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
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
VALIDATE $? "Installing redis repo"
yum module enable redis:remi-6.2 -y &>> $LOGFILE
VALIDATE $? "enabling redis repo"
yum install redis -y &>> $LOGFILE
VALIDATE $? "installing redis"
sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf &>> $LOGFILE
VALIDATE $? "editing redis conf"
systemctl enable redis &>> $LOGFILE
VALIDATE $? "enabling redis"
systemctl start redis &>> $LOGFILE
VALIDATE $? "starting redis"

