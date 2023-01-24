#!/bin/bash

echo "Usage: from_bams_to_unionbed.sh sample1.bam sample2.bam"
echo " - This program requires BEDTOOLS and SAMTOOLS installed and to be in your PATH!"
echo " - The input BAM files must be coordinate sorted alignments to the SAME reference genome. They also can be to filtered and subjected to removal of duplicates"
echo " - The main output sample1_sample2.unionbedcv reports coverage for sample1 and sample2 in corresponding columns for each bed interval. Files *.bedcov.Vk1s_sorted report coverage for each sample separately."
echo " - ATTENTION, this script uses unionBedGraphs (from bedtools) that doesn't accept in contig names some symbols like '#', replace them in bedcov files and ref.length with ':'" 

if [ "$#" -ne 2 ]; then
echo "Wrong number of arguments"
echo "Usage: from_bams_to_unionbed.sh sample1.coordinate_sorted_bam_file sample2.coordinate_sorted_bam_file"
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
echo "sample1 is for $bam1" > Renaming.list
echo "sample2 is for $bam2" >> Renaming.list


echo " "
echo "1. Computing coverage for files $bam1 and $bam2. Original file names recorded in Renaming.list"
genomeCoverageBed -bga -ibam $bam1 > sample1.bedcov 
genomeCoverageBed -bga -ibam $bam2 > sample2.bedcov

echo "2. Calculating length of reference_genome scaffolds from $bam1"
samtools view -H $bam1 > $bam1.header

awk -F '[\t:]' '{if($4=="LN") print $3"\t"$5}' $bam1.header  > ref.length # if($4=="LN") because some headers may include extra lines, like "@HD VN:1.6	SO:coordinate" 

echo "3. Sort bedgraphs by contig's names (sort -V) - quite fast BUT requires memory 10 times more than size of the file!"
sort -V -k1 -s sample1.bedcov > sample1.bedcov.Vk1s_sorted 
sort -V -k1 -s sample2.bedcov > sample2.bedcov.Vk1s_sorted
sort -V -k1 -s ref.length > ref.length.Vk1s_sorted  

echo "4. Putting together coverage from two samples in one file"
unionBedGraphs -header -i sample1.bedcov.Vk1s_sorted sample2.bedcov.Vk1s_sorted -names sample1 sample2 -g ref.length.Vk1s_sorted -empty > sample1_sample2.unionbedcv_draft

awk '{if($3!=4294967295) print $0}' sample1_sample2.unionbedcv_draft > sample1_sample2.unionbedcv_draft1 #some times this value appears in the output of 

t=$(wc -l sample1_sample2.unionbedcv_draft | awk '{print $1}'); r=$(wc -l sample1_sample2.unionbedcv_draft1 | awk '{print $1}'); 

#Check file *unionbedcv if it has e+ numbers, if yes, convert them to decimal
$SCRIPT_PATH/convert_exp_to_dec_in_unionbed.sh sample1_sample2.unionbedcv_draft1 > sample1_sample2.unionbedcv

durationall=$SECONDS
echo " - OVERALL time to generate *unionbedcv from $bam1 and $bam2 was $(($durationall / 60)) minutes and $(($durationall % 60)) seconds.";
echo " ";

if [[ "$t" != "$r" ]]; then 
   echo "Warning: found value 4294967295 that signals possible problems with order or format in file sample1_sample2.unionbedcv_draft; corresponding interval was excluded from sample1_sample2.unionbedcv_draft1";  
 else rm sample1_sample2.unionbedcv_draft; rm sample1_sample2.unionbedcv_draft1;
fi

if [ -s "sample1.bedcov" ]; then rm sample1.bedcov; fi
if [ -s "sample2.bedcov" ]; then rm sample2.bedcov; fi
if [ -s "ref.length" ]; then rm ref.length; fi





