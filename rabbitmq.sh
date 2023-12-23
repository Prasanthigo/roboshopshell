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
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "Configure YUM Repos from the script"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "Configure YUM Repos for Rabbitmq"
yum install rabbitmq-server -y &>> $LOGFILE
VALIDATE $? "installing rabbitmq-server"
systemctl enable rabbitmq-server &>> $LOGFILE
VALIDATE $? "enable rabbitmq-server"
systemctl start rabbitmq-server &>> $LOGFILE 
VALIDATE $? "start rabbitmq-server"
rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
VALIDATE $? "adding user"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
VALIDATE $? "setting permissions"