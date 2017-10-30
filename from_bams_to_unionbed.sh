#!/bin/bash

echo "Usage: program sample1.bam sample2.bam"
echo "This program requires BEDTOOLS and SAMTOOLS installed and to be in your PATH!"
echo "The input files must be alignments to the SAME reference genome. Bam files MUST BE coordinate sorted and we suggest (but not required) to filter them with samtools view -F2308 q5 (filter out all unmapped reads, not primary alignments, secondary alignments)."
echo "The output file *.unionbedcv records for each bed interval coverage for sample1 and sample 2 in corresponding columns. Program also generates and store bedcoverage files *.bedcov.Vk1s_sorted for each sample. ATTENTION, this script uses unionBedGraphs (from bedtools) that doesn't accept some symbols like '#', have to replace them in bedcov files and ref.length with ':' ." 

if [ "$#" -ne 2 ]; then
echo "Wrong number of arguments"
echo "Usage: program sample1.coordinate_sorted_bam_file sample2.coordinate_sorted_bam_file"
  exit 1
fi

SCRIPT_PATH=$(dirname `which $0`)
bam1=$1
bam2=$2

if [ ! -f "$bam1" ]; then
	echo "file $bam1 not found."
	exit;
fi
if [ ! -f "$bam2" ]; then
	echo "file $bam2 not found."
	exit;
fi


SECONDS=0
echo " "
echo "sample1 is for $bam1" > Renaming.list
echo "sample2 is for $bam2" >> Renaming.list


echo " "
echo "1.1. Computing coverage for file $bam1 using bedtools: result in sample1.bedcov"
genomeCoverageBed -bga -ibam $bam1 > sample1.bedcov

echo "1.2. Computing coverage for file $bam2 using bedtools: result in sample2.bedcov"
genomeCoverageBed -bga -ibam $bam2 > sample2.bedcov

echo "2. Calculating length of reference_genome scaffolds from $bam1"

samtools view -H $bam1 > $bam1.header
awk -F '[\t:]' '{print $3"\t"$5}' $bam1.header  > ref.length

echo "3. Sort bedgraphs by contig's names (use stabilized sort with -V flag) - quite fast BUT requires memory 10 times more than size of file!"
sort -V -k1 -s sample1.bedcov > sample1.bedcov.Vk1s_sorted
sort -V -k1 -s sample2.bedcov > sample2.bedcov.Vk1s_sorted
sort -V -k1 -s ref.length > ref.length.Vk1s_sorted

echo "4. Putting together coverage from two samples in one file"

unionBedGraphs -header -i sample1.bedcov.Vk1s_sorted sample2.bedcov.Vk1s_sorted -names sample1 sample2 -g ref.length.Vk1s_sorted -empty > sample1_sample2.unionbedcv_draft

awk '{if($3!=4294967295) print $0}' sample1_sample2.unionbedcv_draft > sample1_sample2.unionbedcv_draft1
rm sample1_sample2.unionbedcv_draft

#Check file *unionbedcv if it has e+ numbers, if yes, convert them to decimal

$SCRIPT_PATH/convert_exp_to_dec_in_unionbed.sh sample1_sample2.unionbedcv_draft1 > sample1_sample2.unionbedcv

durationall=$SECONDS
echo "    OVERALL time to generate *unionbedcv from $bam1 and $bam2 was $(($durationall / 60)) minutes and $(($durationall % 60)) seconds."

rm sample1.bedcov
rm sample2.bedcov
#rm sample1.bedcov.Vk1s_sorted
#rm sample2.bedcov.Vk1s_sorted
rm sample1_sample2.unionbedcv_draft1
rm ref.length




