#!/bin/bash

echo "Usage: program DNAcopy_out.len"
echo "This utility calculates histogram for bases distribution according to their enrichment scores, scores presented in bins such that all bases with scores X-0.25 and X+0.25 are reported in bin X"

if [ "$#" -ne 1 ]; then
 echo "Wrong number of arguments"
 echo "usage: program DNAcopy_out.len"
 exit 1
fi

infile=$1

out=$1.step0.5.histo
if [ -s "$out" ]; then
  rm $out
fi

#sort file by score values, record scores and corresponding lengths
awk '{print int($5*10000)"\t"$4}' $infile | sort -k1 -g > $infile.10000

#initial minimum value to start with (all multiplied by 10000 to work in integers)
D=$(head -n 1 $infile.10000 | awk '{print 10000*int(($1-10000)/10000)-2500}')
#echo "D=$D"
s=0
bin5=5000

echo "bin=0.5"
echo "score_in_the_center_of_the_bin	bases" > $out

while read v1 v2
do
   #echo D=$D v1=$v1
   if [[ "$v1" -lt "$D" ]];then
      ((s+=v2))
       #echo "ss=$s";
    else
       F=$(echo $D | awk '{print -0.25+$1/10000}') 
       echo "$F $s" >> $out
       s=0;
       (( D+=bin5 ))
       while [[ "$D" -le "$v1" ]] 
	do 
	   if [[ "$D" -le "$v1" ]]; then	
              F=$(echo $D | awk '{print -0.25+$1/10000}') 
              echo "$F $s" >> $out
           fi
           (( D+=bin5 ))
        done
        s=$v2
   fi
done<$infile.10000

       F=$(echo $D | awk '{print -0.25+$1/10000}') 
       echo "$F $s" >> $out

#rm $infile.10000
