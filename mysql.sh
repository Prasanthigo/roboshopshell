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
yum module disable mysql -y &>> $LOGFILE
VALIDATE $? "diabling mysql default version"
cp /home/centos/roboshopshell/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE
VALIDATE $? "copying mysql.repo"
yum install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "installing mysql-community-server"
systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "enabling mysqld"
systemctl start mysqld &>> $LOGFILE
VALIDATE $? "starting mysqld"
mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
VALIDATE $? "setting root password for my-sql"
mysql -uroot -pRoboShop@1 &>> $LOGFILE
VALIDATE $? "checking the new password working or not "