#!/bin/bash
echo "Usage: get_DNAcopyout_with_length_of_intervals.sh *.DNAcopyout ref.length"
echo "This program computes length of each DNAcopy interval that was created by merging windows. Output is stored in *.DNAcopyout.len with following columns: contig, contig_length, begin_of_interval, length_of_interval, enrichment score" 

if [ "$#" -ne 2 ]; then
 echo "Wrong number of arguments"
 echo "Usage: program *DNAcopy_out ref.length"
 exit 1
fi

DNAout=$1
lenout=$1.len
ref_len=$2

v1_pred="qq1"
v2_pred="qq2"

echo "Contig contig_length begin_of_interval length_of_interval score" > $lenout
while read v1 v2 v3 v4 v5
do
	# echo "$v1_pred $v1"
 if [[ "$v1" == "$v1_pred" ]]; then
	# echo "v2=$v2 v2_pred=$v2_pred contig=$v1_pred sum=$s length_cont=$contig_length"
    ((s=v2-v2_pred))
        echo "$v1_pred $contig_length $v2_pred $s $v5_pred" >> $lenout
 else
      
       ((s=contig_length-v2_pred))
       if [[ "$v1_pred" != "qq1" ]]; then
           echo "$v1_pred $contig_length $v2_pred $s $v5_pred" >> $lenout
       fi

        contig_length=$(grep -w $v1 $ref_len | awk -v w=$v1 '{if($1==w) print $2}')   ##fixed for the cases when scaffolds do not have a prefix, just number, and this number may coinside with the length of another scaffold
	# echo "contig_length=$contig_length"
     	
  	       
 fi
 v1_pred=$v1
 v2_pred=$v2
 v5_pred=$v5

done<$1

	((s=contig_length-v2_pred))
	# echo "contig=$v1_pred sum=$s length_cont=$contig_length"
        echo "$v1_pred $contig_length $v2_pred $s $v5_pred" >> $lenout



