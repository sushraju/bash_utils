#!/usr/bin/bash

if [[ $# == 0 ]]
then
   echo "error: The script needs a URL for download !!!"
   echo "usage: $0 <url>"
   exit 255
else
   SHAFILE_DOWNLOAD_LOC=$1
fi

# defs
FILE_LOC_DIR=$PWD/long
LOG_FILE=$PWD/shacheck.log
SHASUM_CMD=/usr/bin/shasum

# Try to download the SHA1SUMS file and exit on error.
SHASUM_FILE=`echo ${SHAFILE_DOWNLOAD_LOC##*/}`
curl -s $SHAFILE_DOWNLOAD_LOC -o $FILE_LOC_DIR/$SHASUM_FILE
ret=$?
if [[ ${ret} != 0 ]]
then
   echo "error: Cannot download $SHAFILE_DOWNLOAD_LOC" | tee $LOG_FILE
   echo "usage: $0 <url>" | tee -a $LOG_FILE
   exit 255
else
   echo ''
   echo "Downloaded $SHAFILE_DOWNLOAD_LOC. Proceeding to process it..." | tee $LOG_FILE
fi

# read each line from file to process
# split line into shasum and filename to download
# download the file, get the shasum, compare and log.

DOWNLOAD_LOC=`echo ${SHAFILE_DOWNLOAD_LOC%/*}`/zips
echo "Reading contents from $SHAFILE_DOWNLOAD_LOC..." | tee -a $LOG_FILE
echo "Download location for individual files is $DOWNLOAD_LOC" | tee -a $LOG_FILE
echo '' | tee -a $LOG_FILE

while read line
do
   read_shasum=`echo $line | cut -f1 -d' '`
   filename=`echo $line | cut -f2 -d' ' | cut -f2 -d'/'`
   curl -s "$DOWNLOAD_LOC"/"$filename" -o "$FILE_LOC_DIR"/"$filename"
   ret=$?
   if [[ ${ret} != 0 ]]
   then
      echo "error: $FILE_LOC_DIR/$filename cannot be downloaded. Proceeding to next..." | tee -a $LOG_FILE
   else 
      echo "Downloaded $filename to $FILE_LOC_DIR." | tee -a $LOG_FILE
      compute_shasum=`$SHASUM_CMD $FILE_LOC_DIR/$filename | cut -f1 -d' '`

      #compare checksums
      if [[ "$read_shasum" == "$compute_shasum" ]]
      then
         echo "$FILE_LOC_DIR/$filename is a good download." | tee -a $LOG_FILE
      else
         echo "$FILE_LOC_DIR/$filename is not a valid download." | tee -a $LOG_FILE
      fi 
   fi
done < "$FILE_LOC_DIR"/$SHASUM_FILE
