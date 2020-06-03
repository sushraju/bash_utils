#!/bin/bash

# watchdog to restart processes
# change PROC_NAME to adopt this for other processes.

# cron entry
# */5 * * * * sh namedog.sh > /dev/null

DATE=`date +%Y-%m-%dT%H-%M-%S-%Z`
PROC_NAME="NameNode"
JPS=/usr/bin/jps
GREP=/bin/grep
CUT=/bin/cut
HADOOP_HOME2_6=/usr/local/hadoop/hadoop-2.6.0-cdh5.4.0
HADOOP_HOME2_9=/usr/local/hadoop/hadoop-2.9.0

if [ -d $HADOOP_HOME2_6 ]
then
   START="$HADOOP_HOME2_6/bin/start_namenode.sh"
else
   START="$HADOOP_HOME2_9/bin/start_namenode.sh"
fi

LOGDIR=/home/appusr/utils/dogs
LOGFILE=$LOGDIR/namedog.log

if [ ! -d $LOGDIR ]
then
   echo "$DATE: ERROR - Log directory $LOGDIR not present. Fix it!!!"
   exit 255
fi

if [ ! -f $LOGFILE ]
then
   # touch the file and move on.  We know the directory exists from the check above.
   touch $LOGFILE
fi

pids=`$JPS | $GREP ${PROC_NAME} | $CUT -f1 -d' '`

if [ "$pids" == "" ]
then
   if [ -f $START ]
   then
      /bin/sh $START
      if [ -z $MAIL_TO ]
      then
         echo "$DATE: ${PROC_NAME} restarted." >> ${LOGFILE}
      else
         # Configure email routine here.  TODO for Simon Ip.
         echo "$DATE: ${PROC_NAME} restarted. Sent email to ${MAIL_TO}" >> ${LOGFILE}
      fi
   else
      echo "$DATE: ERROR - ${PROC_NAME} cannot be restarted. No start script ${START} present. Fix it!!!" >> ${LOGFILE}
      exit 255
   fi
else
   echo "$DATE: ${PROC_NAME} running. Nothing to do." >> ${LOGFILE}
fi

exit 0
