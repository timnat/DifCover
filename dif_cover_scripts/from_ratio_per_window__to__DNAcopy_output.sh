#!/bin/bash
SCRIPT_PATH=$(dirname `which $0`)
if [ "$#" -ne 2 ]; then
echo "Wrong number of arguments!"
echo "Usage: program *.ratio_per_windows adj_coef, where adj_coef recommended to be (modal_cov_sample2/modal_cov_sample1)"
  exit 1
fi
in_file=$1
adj_coef=$2

if [ ! -f "$1" ]; then
	echo "file $1 not found."
	exit;
fi

echo "Prepear input for DNAcopy in file $in_file.log2adj_$adj_coef"
echo " "
echo "scaffold	window_start	$adj_coef*log2(ratio)" > $in_file.log2adj_$adj_coef
awk -v AC="$adj_coef" '{if($2!="window_start") print $1"\t"$2"\t"log(AC*$7)/log(2)}' $in_file >> $in_file.log2adj_$adj_coef

echo "Running DNAcopy"
echo " "

SECONDS=0
Rscript $SCRIPT_PATH/run_DNAcopy_from_bash.R $in_file.log2adj_$adj_coef

echo " "
duration=$SECONDS
echo "DNAcopy took $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
echo "The output must be in file: $in_file.log2adj_$adj_coef.DNAcopyout[pdf]"
echo " "
