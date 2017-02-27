#!/bin/bash
#folderToSync="Ericsson"
folderToSync="qq"
#localFolder="/Baidu_Backup/$folderToSync"
localFolder="/tmp/$folderToSync"

# kill old pcs process if any
hourMinNow=`date +\%H:\%M`
pcsExist=`ps -ef | grep pcs | grep -v "$hourMinNow" | grep -v grep | grep -v MacOS | grep -v vi | awk '{print $2}'`
pcsArray=($pcsExist)
if [ ! -z ${pcsArray[0]} ];then
  for pcsProcess in ${pcsArray[@]}
    do
      echo Kill old PCS process id $pcsProcess.
      kill -9 $pcsProcess
    done
fi

# write the folder size to the size.log
folderSize=$localFolder/size.log
if [ ! -e $folderSize ];then
  touch $folderSize
fi
theSizeNow=`du -s -m $localFolder | awk '{print $1}'`
echo "The Size of $localFolder is $theSizeNow MB at `date`." >> $folderSize

# main function
function PCS(){
  echo "Caculate the size of $localFolder and write to $folderSize."
  pcsLocation=`which pcs`
  if [ ! -e $pcsLocation ];then
    echo "No /usr/local/bin/pcs found. Please install pcs at first."
    exit 2
  fi
  if [ ! -e ~/.pcs/pcs.context ];then
    echo "No ~/.pcs/pcs.context config found. Please run pcs login at first."
    exit 2
  fi
  $pcsLocation --context=~/.pcs/pcs.context synch -cdr $localFolder /$folderToSync
}

# compare with the size with one hour and two hours before
line_folderSize=`wc -l $folderSize | awk '{print $1}'`

if [ $line_folderSize -ge 2 ];then

    folderSize_OneBefore=`tail -n 1 $folderSize | awk '{print $6}'`
    if [ -z $folderSize_OneBefore ];then
      PCS
      exit 1
    fi

    folderSize_TwoBefore=`tail -n 2 $folderSize | head -n 1 | awk '{print $6}'`
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
