#!/bin/bash

#Changed interface for from_unionbed_to_ratio_per_window_CC0_v3

FOLDER_PATH=../dif_cover_scripts

BAM1='sample1.bam'
BAM2='sample2.bam'
a=10
A=219
b=10
B=240
v=1000
l=500
AC=1.095
bin=1
p=2


## run stage (1)
echo "stage 1"
$FOLDER_PATH/from_bams_to_unionbed.sh $BAM1 $BAM2

## run stage (2)
echo "stage 2"
$FOLDER_PATH/from_unionbed_to_ratio_per_window_CC0_v3 -a $a -A $A -b $b -B $B -v $v -l $l sample1_sample2.unionbedcv

## run stage (3)
echo "stage 3"
$FOLDER_PATH/from_ratio_per_window__to__DNAcopy_output.sh "sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l $AC

## run stage (4)
echo "stage 4"
$FOLDER_PATH/get_DNAcopyout_with_length_of_intervals.sh "sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l".log2adj_"$AC".DNAcopyout" ref.length.Vk1s_sorted

$FOLDER_PATH/generate_DNAcopyout_len_histogram.sh "sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l".log2adj_"$AC".DNAcopyout.len" $bin

## run stage (5)
echo "stage 5"
$FOLDER_PATH/from_DNAcopyout_to_p_fragments.sh "sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l".log2adj_"$AC".DNAcopyout" $p
