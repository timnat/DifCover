# DifCover 

## **_Description_**

The DifCover pipeline aims to identify regions in a reference genome for which the read coverage of one sample (sample1) is significantly different from the read coverage of another sample (sample2) when aligned to a common reference genome. *“Significantly different”* is determined by user-defined thresholds. The pipeline allows exclusion of regions from consideration based on read coverage. These include regions with low sequence coverage in both samples (regions that are undersampled due to nucleotide content) and regions with exceedingly high sequence coverage (i.e. repetitive sequences). Both cases can be misleading with respect to coverage analyses. The DifCover pipeline is specifically oriented to the analysis of large genomes and can handle very fragmented assemblies. 

## **_Method_**
The alignment of short reads to a reference genome can be characterized by the depth of coverage computed for each genomic position as number of reads mapped over it. Fluctuations of coverage can often yield variable coverage ratios and may interfere with the identification of regions that differ between samples. In many cases, calculating average coverage ratios over windows can more accurately reflect differences in copy number of the underlying fragments. In practice, the locations and sizes of the windows can be defined in a various ways. Traditional tools already offer solutions that allow computing average coverage over intervals of a fixed size (Sambamba, http://lomereiter.github.io/sambamba/) or splitting contig into separate intervals consisting of bases with the same coverage (bedtools, https://github.com/arq5x/bedtools2). However these tools are not, in and of themselves, well suited in practice for the analysis of large complex genomes with large numbers of gaps and repeats. DifCover addresses these issues by introducing the notion of window “stretching”. Essentially each genomic scaffold is scanned sequentially to form windows of variable size, but with predefined number of bases that have coverage within user-defined limits. These stretched windows allow bridging across under- and over-represented fragments permitting more precise analyses. For each window an average coverage is reported and compared to the coverage of another sample. For highly contiguous genomes, adjacent windows with similar coverage ratios can be combined to generate consensus estimates for larger continuous regions. Finally regions with significant difference in coverage can be extracted for downstream analyses.

## USAGE

### Prerequisites (MUST be in your PATH)
	BEDTOOLS
	SAMTOOLS 
	AWK
	DNAcopy (for R) // optional (https://bioconductor.org/packages/release/bioc/html/DNAcopy.html)

### Quick start
The DifCover pipeline includes several bash scripts and one C++ program. They can be run separately stage by stage, to experiment with parameters, or run in a bulk from run_difcover.sh with predefined in it parameters. This section gives an example on how to run entire pipeline.

INPUT: two coordinate sorted BAM files presenting short read alignments from two samples to the same reference

OUTPUT: *.DNAcopyout.upp file with regions of significant coverage difference (p-fragments).  Format details can be found in the next section.

Download DifCover

Copy file DifCover/dif_cover_scripts/run_difcover.sh to the directory with BAM files and replace parameters with your values

	FOLDER_PATH='path to dif_cover_scripts directory'
	BAM1='path to sample1.bam'
	BAM2='path to sample2.bam'
	a=10		# minimum coverage for sample1
	A=219		# maximum coverage for sample1
	b=10		# minimum coverage for sample2
	B=240		# maximum coverage for sample2
	v=1000	# target number of valid bases in stretched windows
	l=500		# minimum size of window to output
	AC=1.095	# Adjustment Coefficient (set AC to 1, if modal coverage is equal) 
	p=2		# enrichment scores threshold (for p=2 will report regions with coverage in sample1 being roughly 4 times larger than coverage in sample2)
	bin=1		# for an auxiliary analytical stage (5); generates enrichment scores histogram with scores in bins with floating precision 1. For more detailed histogram use 10, 100.

Run entire pipeline

./run_difcover.sh

### Pipeline overview and stage by stage usage example
The DifCover pipeline includes several bash scripts and one C++ program. They can be run separately stage by stage, to experiment with parameters, or run in a bulk from run_difcover.sh with predefined in it parameters.

INPUT: coordinate sorted bam files for two samples and mandatory parameters (explained for each stage below) 
OUTPUT:  *.DNAcopyout.up_p file with regions of significant coverage difference (p-fragments)
                   Intermediate files (explained for each stage below)

 	<<  sample1.bam, sample2.bam, a, A, b, B, v, l, AC, p >>
 
        	                \/
			
   	(1)  from_bams_to_unionbed.sh  (sample1.bam, sample2.bam)
   
				\/
				
   	(2)  from_unionbed_to_ratio_per_window (a, A, b, B, v, l)
	
				\/
				
   	(3)  from_ratio_per_window__to__DNAcopy_output.sh (AC)
	
				\/
				
	(4)  from_DNAcopyout_to_p_fragments.sh (p)

				\/
       		<< p-fragments >>

**_Stage by stage usage example_**

*prepare input data*
	cd DifCover
	cp ./dif_cover_scripts/run_difcover.sh test_data/
	cd test_data/

Open run_difcover.sh in text editor. Set FOLDER_PATH to a path to the directory  dif_cover_scripts/

FOLDER_PATH=../dif_cover_scripts

**run stage (1)**

	$FOLDER_PATH/from_bams_to_unionbed.sh sample1.bam sample2.bam

   OUPUT: sample1_sample2.unionbedcv 
          ref.length.Vk1s_sorted     //keep it for following stages
	       
   NOTES: This script calls different functions from BEDTOOLS. File sample1_sample2.unionbedcv stores coverage information from both samples, allowing coverage comparisons between them.

**run stage (2)**

	$FOLDER_PATH/from_unionbed_to_ratio_per_window_CC0 sample1_sample2.unionbedcv 10 219 10 240 1000 500
* Item 1	
a=10 	minimum coverage for sample1
   
   A=219	maximum coverage for sample1
   
   b=10		minimum coverage for sample2
   
   B=240	maximum coverage for sample2
   
   v=1000 	target number of valid bases in the window
   
   l=500	minimum size of window to output (window includes valid and non valid bases)

NOTES:
   1. The program will merge bed intervals constructing stretched windows with v valid bases.
   
   2. Valid bases satisfy following conditions  
   
		1) _C1_ < A and _C2_ < B       **and** 2) _C1_ > a or _C2_ > b.
		
   3.  Each window has approximately v valid bases, but because window is formed from bed intervals it can have
   
        * - fewer than v bases – in a case if the window hits the end of the scaffold
	* - more than v bases – to avoid breaking of the last added bed interval
   
   4. For each window the program computes

Q1 – average coverage of valid bases across all merged bed intervals for sample1  

Q2 – average coverage of valid bases across all merged bed intervals for sample2

W1 – is sum of coverages of merged bed interval for sample1

W2 – is sum of coverages of merged bed interval for sample2

R = W1/W2, if W2>0

R = W1/CC0, if W2=0.

If coverage of sample2 is zero for a given window, the program employs a conservative continuity correction to prevent division by zero, replacing zero values with an arbitrary small value CC0 corresponding to alignment of 0.5 reads over the interval. CC0 is a predefined constant, but we may update this parameter in the future.

** The program from_unionbed_to_ratio_per_window_CC0_v2 calculates R differently: R = Q1/Q2 or Q1/CC0, if Q2=0.

OUTPUT: sample1_sample2.ratio_per_w_CC0_a10_A219_b10_B240_v1000_l500

Columns are: scaffold, window_start, size_of_window, number_of_valid_bases_in_window, Q1, Q2, R
