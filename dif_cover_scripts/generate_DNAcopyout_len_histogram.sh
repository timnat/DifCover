#!/bin/bash

echo "Usage: generate_DNAcopyout_len_histogram.sh *.DNAcopyout.len bin_value, where bin_value is 10 for 0.1, 100 for 0.01, ..."
echo "This program will compute length of each DNAcopy interval and output length of the whole contig to which that interval belongs. Output must be in *.DNAcopyout.len.hist: log2ratio is binned by 0.1" 

if [ "$#" -ne 2 ]; then
 echo "Wrong number of arguments"
 echo "usage: program DNAcopy_out.len"
 exit 1
fi

bin=$2

awk -v bin="$2" '{print int($5*bin)/bin"\t"$4}' $1 | sort -g -k1 > $1.sort

out=$1.hist_b$bin

if [ -s "$out" ]; then
   rm $out
fi

v1_pred="qq1"
s=0
while read v1 v2
do
 if [[ "$v1" == "$v1_pred" ]]; then
    ((s+=v2))
 else
       if [[ "$v1_pred" != "qq1" ]]; then
         echo "$v1_pred $s" >> $out
       fi
       s=$v2
 fi

 v1_pred=$v1
 v2_pred=$v2

done<$1.sort

       echo "$v1_pred $s" >> $out

rm $1.sort
