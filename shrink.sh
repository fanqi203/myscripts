#!/bin/bash

# given a file consisting non-consecutive and consecutive dates, 
# unify those consecutive dates so that only one item is output 
# example: 
# before the command the file has:
#21.4002 at 18Z05JAN1948
#20.6422 at 00Z06JAN1948
#20.6022 at 12Z07JAN1948
#22.973 at 12Z10FEB1948
#21.8048 at 12Z14FEB1948
#20.5769 at 00Z28MAR1948
#20.0000 at 00Z29MAR1948

# after the command the output is:
#21.4002 at 18Z05JAN1948
#22.973 at 12Z10FEB1948
#21.8048 at 12Z14FEB1948
#20.5769 at 00Z28MAR1948

#starting from 19480101
past_day=19480101
# input file is $1

while read line 
do
#echo $line
date_str=$(echo $line |cut -d" " -f 3,3)
date_str=${date_str:3:9}
current_day=$(date -u --date="${date_str}" +%Y%m%d)
next_day=$(date -u --date="${past_day} +1 day" +%Y%m%d)
if [ ${current_day} -eq ${next_day} ]; then
past_day=${next_day}
else
echo ${line}
past_day=${current_day}
fi
done < $1 
