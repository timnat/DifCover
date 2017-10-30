#!/bin/bash

echo "usage: program *.DNAcopyout ref.length"
echo "This program will compute length of each DNAcopy interval and output length of the whole contig to which that interval belongs. Output must be in *.DNAcopyout.len" 

if [ "$#" -ne 2 ]; then
 echo "Wrong number of arguments"
 echo "usage: program DNAcopy_out ref.length"
 exit 1
fi

DNAout=$1
lenout=$1.len
ref_len=$2

v1_pred="qq1"
v2_pred="qq2"


echo "Contig contig_length begin_of_interval length_of_interval ratio" > $lenout
while read v1 v2 v3 v4 v5
do
#        echo "$v1_pred $v1"
 if [[ "$v1" == "$v1_pred" ]]; then
    ((s=v2-v2_pred))
#    echo "contig=$v1_pred sum=$s length_cont=$contig_length"
        echo "$v1_pred $contig_length $v2_pred $s $v5_pred" >> $lenout
 else
      
       ((s=contig_length-v2_pred))
       if [[ "$v1_pred" != "qq1" ]]; then
           echo "$v1_pred $contig_length $v2_pred $s $v5_pred" >> $lenout
       fi

        contig_length=$(grep -w $v1 $ref_len | cut -f2) 
      	

       

	       
 fi
 v1_pred=$v1
 v2_pred=$v2
 v5_pred=$v5

done<$1

	((s=contig_length-v2_pred))
#	echo "contig=$v1_pred sum=$s length_cont=$contig_length"
        echo "$v1_pred $contig_length $v2_pred $s $v5_pred" >> $lenout

