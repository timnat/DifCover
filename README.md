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

