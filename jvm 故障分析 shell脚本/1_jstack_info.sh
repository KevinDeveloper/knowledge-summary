#!/bin/bash
#
# 当JVM占用CPU特别高时，查看CPU正在做什么
# 可输入两个参数：1、pid Java进程ID，必须参数  2、打印线程ID上下文行数，可选参数，默认打印10行
#

pid=$1

if test -z $pid
then
 echo "pid can not be null!"
 exit
else
 echo "checking pid($pid)"
fi

if test -z "$(jps -l | cut -d '' -f 1 | grep $pid)"
then
 echo "process of $pid is not exists"
 exit
fi

lineNum=$2
if test -z $lineNum
then
    lineNum=10
fi

jstack $pid >> "$pid".bak

ps -mp $pid -o THREAD,tid,time | sort -k2r | awk '{if ($1 !="USER" && $2 != "0.0" && $8 !="-") print $8;}' | xargs printf "%x\n" >> "$pid".tmp

tidArray="$( cat $pid.tmp)"

for tid in $tidArray
do
    echo "******************************************************************* ThreadId=$tid **************************************************************************"
    cat "$pid".bak | grep $tid -A $lineNum
done

rm -rf $pid.bak
rm -rf $pid.tmp