#!/bin/bash

echo "Usage: from_DNAcopyout_to_p_fragments.sh *.DNAcopyout p"
echo "The input file *.DNAcopyout must be in the format: scaffold fragment_start fragment_size number_of_windows_merged_into_fragment av(adj_coef*log2ratio). p - filter only intervals with |enrichment scores| > p" 

if [ "$#" -ne 2 ]; then
echo "Wrong number of arguments"
echo "Usage: program *.DNAcopyout p"
  exit 1
fi

in_file=$1
p=$2

awk -v p="$p" '{if($5>=p) print $0}' $in_file > $in_file.up$p # sample1_coverage > sample2_coverage 
awk -v p="$p" '{if($5<=-p) print $0}' $in_file > $in_file.down-$p # sample2_coverage > sample1_coverage







