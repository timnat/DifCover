#!/bin/bash

#DifCover version 3 (changed interface compare to version 2)

FOLDER_PATH=../dif_cover_scripts

BAM1='sample1.bam'
BAM2='sample2.bam'
a=10		#minimum coverage for sample1
A=219		#maximum coverage for sample1
b=10		#minimum coverage for sample2
B=240		#maximum coverage for sample2
v=1000		#target number of valid bases in the window
l=500		#minimum size of window to output (window includes valid and non valid bases)
AC=1.095	#adjustment coefficient - usually computed as ratio (modal coverage of sample2)/(modal coverage of sample1)
bin=1		#for an auxiliary analytical stage (5); generates enrichment scores histogram with scores in bins with floating precision 1. For more detailed histogram use 10, 100
p=2		#threshold for enrichment scores to report in a separate file (for p=2 will report regions with coverage in sample1 being roughly 4 times larger than coverage in sample2)

## run stage (1)
echo "# Stage 1"
$FOLDER_PATH/from_bams_to_unionbed.sh $BAM1 $BAM2
if [ ! -s "sample1_sample2.unionbedcv" ]; then
    echo "File sample1_sample2.unionbedcv is empty, exit now"; 
    exit;
fi

## run stage (2)
echo "# Stage 2"
$FOLDER_PATH/from_unionbed_to_ratio_per_window_CC0 -a $a -A $A -b $b -B $B -v $v -l $l sample1_sample2.unionbedcv
if [ ! -s "sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l ]; then
    echo "File "sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l is empty, exit now"; 
    exit;
fi
echo " ";

## run stage (3)
echo "# Stage 3"
$FOLDER_PATH/from_ratio_per_window__to__DNAcopy_output.sh "sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l $AC
if [ ! -s "sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l".log2adj_"$AC".DNAcopyout" ]; then
    echo "File "sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l".log2adj_"$AC".DNAcopyout" is empty, exit now"; 
    exit;
fi

## run stage (4)
echo "# Stage 4"
$FOLDER_PATH/get_DNAcopyout_with_length_of_intervals.sh "sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l".log2adj_"$AC".DNAcopyout" ref.length.Vk1s_sorted

$FOLDER_PATH/generate_DNAcopyout_len_histogram.sh "sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l".log2adj_"$AC".DNAcopyout.len" $bin
echo " ";

## run stage (5)
echo "# Stage 5"
$FOLDER_PATH/from_DNAcopyout_to_p_fragments.sh "sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l".log2adj_"$AC".DNAcopyout" $p
