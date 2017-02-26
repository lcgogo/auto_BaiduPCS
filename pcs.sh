#!/bin/bash
folderToSync=Ericsson

# kill old pcs process
hourMinNow=`date +\%H:\%M`
pcsExist=`ps -ef | grep pcs | grep -v "$hourMinNow" | grep -v grep | awk '{print $2}'`
pcsArray=($pcsExist)
if [ ! -z ${pcsArray[0]} ];then
  for pcsPro in ${pcsArray[@]}
    do
      echo Kill old PCS process id $pcsPro.
      kill -9 $pcsPro
    done
fi

# write the folder size
folderSize=/Baidu_Backup/$folderToSync/size.log
if [ ! -e $folderSize ];then
  touch $folderSize
fi
theSizeNow=`du -s -m /Baidu_Backup/$folderToSync/ | awk '{print $1}'`
echo "The Size of /Baidu_Backup/$folderToSync/ is $theSizeNow MB at `date`." >> $folderSize

PCS(){
  echo "Caculate the size of /Baidu_Backup/$folderToSync."
  /usr/local/bin/pcs --context=/home/root/.pcs/pcs.context synch -cdr /Baidu_Backup/$folderToSync /$folderToSync
}

line_folderSize=`wc -l $folderSize | awk '{print $1}'`

if [ $line_folderSize -ge 2 ];then

    folderSize_OneBefore=`tail -n 1 /Baidu_Backup/$folderToSync/size.log | awk '{print $6}'`
    if [ -z $folderSize_OneBefore ];then
      PCS
      exit 1
    fi

    folderSize_TwoBefore=`tail -n 2 /Baidu_Backup/$folderToSync/size.log | head -n 1 | awk '{print $6}'`
    if [ -z $folderSize_TwoBefore ];then
      PCS
      exit 1
    fi

#folderSize_OneBefore=100023
#folderSize_TwoBefore=100023
    echo folderSize_OneBefore is $folderSize_OneBefore MB.
    echo folderSize_TwoBefore is $folderSize_TwoBefore MB.

    if [ $folderSize_OneBefore -eq $folderSize_TwoBefore ];then
      echo "The 1 hour and 2 hours before folder size is same."
      echo "Send email to lcgogo123@163.com" 
      echo "The folder $folderToSync size is $folderSize_TwoBefore MB." | mail -s "$folderToSync done" lcgogo123@163.com
      exit 0
    fi

    PCS

  else

  PCS

fi
