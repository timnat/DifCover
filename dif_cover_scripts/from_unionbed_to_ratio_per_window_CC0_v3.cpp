
/* Changed command line processing interface compared to v2 */

#include <unistd.h>
#include <stdio.h>

#include <fstream>
#include <string>
#include <string.h>
#include <iostream>
#include <sstream>
#include <stdlib.h>

#define max_cov 1000000 // Default value for upper limit on depth of coverage
#define CC0 50    // if coverage mass accross the window is 0, we artificially replace it with CC0 value that should be approximately a half of read length

using namespace std;
 
int main( int argc , char** argv ) {


   int opt, a=1, A=max_cov, b=1, B=max_cov, v=1000, l=0; //!!! Default values for parameters !!!!
   char fname[1000], fff[1000];
 
   while ((opt = getopt(argc, argv, "a:A:b:B:v:l:")) != -1) {
        switch (opt) {
        case 'a':
	    a = atoi(optarg);
            break;
        case 'A':
	    A = atoi(optarg);
            break;
        case 'b':
            b = atoi(optarg);
            break;
        case 'B':
            B = atoi(optarg);
            break;
        case 'v':
	    v = atoi(optarg);
            break;
        case 'l':
            l = atoi(optarg);
            break;
        default: 
            fprintf(stderr, "Usage: [-a minimum depth of coverage for sample1 [0]] [-A maximum depth of coverage for sample1 [%d]] [-b minimum depth of coverage for sample2 [0]] [-B maximum depth of coverage for sample2 [%d]]  [-v Target number of valid bases in the window [1000]] [-l minimum size of window to output [0]] sample1_sample2.unionbedcv \n", max_cov, max_cov);
            exit(EXIT_FAILURE);
        }
    }
   
    if (optind >= argc) {
        fprintf(stderr, "Expected *.unionbed file\n");
        fprintf(stderr, "Usage: [-a minimum depth of coverage for sample1 [0]] [-A maximum depth of coverage for sample1 [%d]] [-b minimum depth of coverage for sample2 [0]] [-B maximum depth of coverage for sample2 [%d]]  [-v Target number of valid bases in the window [1000]] [-l minimum size of window to output [0]] sample1_sample2.unionbedcv \n", max_cov, max_cov);
        exit(EXIT_FAILURE);
    }

   strncat(fname,argv[optind],strlen(argv[optind]));
   //printf ("fname=%s\n",fname);
     
   std::ifstream unionbed_file( fname ) ;
   if (!unionbed_file) {
	fprintf(stderr, "Can't open union.bed file %s\n",fname);	
        exit(EXIT_FAILURE);
    }
 
   printf("Parameters:\na=%d\nA=%d\nb=%d\nB=%d\nv=%d\nl=%d\n", a,A,b,B,v,l);

   std::string line;
   string scaf = "", scaf_pred= "header_line", begs, ends, cov1s, cov2s, sample1_name, sample2_name;
   int beg,end,cov1,cov2, k=0, wb=-1, r=0, window_size=v, linecount=0;
   float ratio, av1, av2, av_sum_k1=0, av_sum_k2=0;

    sprintf(fff, "%s.ratio_per_w_CC0_a%d_A%d_b%d_B%d_v%d_l%d", "sample1_sample2",a,A,b,B,v,l);
    std::ofstream outfile(fff) ;

    //read header line from unionbed
    getline( unionbed_file , line );
    //std::cout << "header line: " << line << endl; //supposing '\n' to be line end
         stringstream ss(line);
         getline(ss,scaf, '\t');
	 	//cout << "scaf: " << scaf << " scaf_pred: "<<scaf_pred<<endl; 
	
         getline(ss,begs, '\t');
	 beg=atoi(begs.c_str());

	 
         getline(ss,ends, '\t');
	 end=atoi(ends.c_str());
 
         getline(ss,sample1_name, '\t');
	 //cout << "sample1 is "<<sample1_name<<endl;
	
         getline(ss,sample2_name, '\t');
	 //cout << "sample2 is "<< sample2_name<<endl;

      //output header line to result file
outfile<<"scaffold\twindow_start\tsize_of_window\tnumber_of_valid_bases_in_window\t"<<sample1_name<<"_av_cov_over_valid_bs\t"<<sample2_name<<"_av_cov_over_valid_bs\tratio=sum_of_cov(sample1)/sum_of_cov(sample2)\n";

   if ( unionbed_file ) {
      while ( getline( unionbed_file , line ) ) {
	 //std::cout << linecount << ": " << line << '\n' ;//supposing '\n' to be line end
	 linecount++ ;
	 stringstream ss(line);
         getline(ss,scaf, '\t');
	 	//cout << "scaf: " << scaf << " scaf_pred: "<<scaf_pred<<endl; 
	
         getline(ss,begs, '\t');
	 beg=atoi(begs.c_str());

	 
         getline(ss,ends, '\t');
	 end=atoi(ends.c_str());
 
         getline(ss,cov1s, '\t');
	 cov1=atoi(cov1s.c_str());

	
         getline(ss,cov2s, '\t');
	 cov2=atoi(cov2s.c_str());
	 
         //cout << scaf << " " <<beg<<" "<<end<<" "<<cov1<<" "<<cov2<<endl; 


	if(scaf_pred != scaf) 
         {

	  if(av_sum_k1 == 0 && av_sum_k2 == 0) 
              {ratio=CC0*10000;	//both are equal 0, it is impossible when a>0 and b>0 , so will mean the ERROR	
 	       if(k>0) cout<<"There is a window "<< scaf_pred<<" "<<wb<<" with both samples having 0 coverage and k= "<<k<<endl; 	
	      }
          else
	      {
		  if(av_sum_k1 == 0) av_sum_k1=(av_sum_k2<CC0)?av_sum_k2:CC0;   // sample1 == 0 and sample2 >= b; but if av_sum_k2<CC0, - case of misalignment, or alignment on the flank, better to report equal ratio, as both samples are close to ZERO
		  if(av_sum_k2 == 0) av_sum_k2=(av_sum_k1<CC0)?av_sum_k1:CC0;   // sample1 >=a and sample2 == 0
            	  
		  ratio=(float)(av_sum_k1/av_sum_k2);
	       }
 	 

         if(k!= 0)
	  { 
	    av1=av_sum_k1/k;
	    av2=av_sum_k2/k;
          
      // cout <<"NT:"<<scaf_pred<<"\t"<<wb<<"\t"<<k<<"\t"<<av_sum_k1<<"\t"<<av_sum_k2<<"\t"<<av1<<"\t"<<av2<<"\t"<<ratio<<"\n"; 
	//    cout<<"r="<<r<<"\n";
	    if(r>=l)
	//    cout<<"rr="<<r<<"\n";
              outfile<<scaf_pred<<"\t"<<wb<<"\t"<<r<<"\t"<<k<<"\t"<<av1<<"\t"<<av2<<"\t"<<ratio<<"\n"; 
          }
	     av_sum_k1=0; av_sum_k2=0;
	     k=0;
	     wb=-1;
	     r=0;         
         }//end if(scaf_pred!=scaf)

    r+= end-beg;
    // cout<<"R="<<r<<"\n";

    if(wb == -1) wb=beg;  

    //at least one sample should have cov > low_limits && both should have coverage < upper limits !!!
    if( (cov1>=a || cov2>=b) && (cov1<=A && cov2<=B) ){ 
      k+= end-beg;   
      av_sum_k1+=cov1*(end-beg);      av_sum_k2+=cov2*(end-beg);
    }   

    if(k>=window_size){

	  if(av_sum_k1 == 0 && av_sum_k2 == 0) 
              {ratio=CC0*10000;	//both are equal 0, on case if a>0, b>0 it is impossible, so will mean the ERROR	
 	       cout<<"Error: there is a window with both samples having 0 coverage: "<< scaf_pred<<"\t"<<wb<<endl; 	
	      }
          else
	      {
		  if(av_sum_k1 == 0) av_sum_k1=(av_sum_k2<CC0)?av_sum_k2:CC0;   // sample1 == 0 and sample2 >= b; but if av_sum_k2<CC0, - case of misalignment, or alignment on the flank, better to report equal ratio, as both samples are close to ZERO
		  if(av_sum_k2 == 0) av_sum_k2=(av_sum_k1<CC0)?av_sum_k1:CC0;   // sample1 >=a and sample2 == 0
            	  
		  ratio=(float)(av_sum_k1/av_sum_k2); 
	       }
 	  
  	     av1=av_sum_k1/k;
	     av2=av_sum_k2/k;
  
 	    if(r>=l) outfile<<scaf_pred<<"\t"<<wb<<"\t"<<r<<"\t"<<k<<"\t"<<av1<<"\t"<<av2<<"\t"<<ratio<<"\n"; 
          
	     av_sum_k1=0; av_sum_k2=0;
	     k=0;
	     wb=-1;
	     r=0;     

	    
     }

  scaf_pred=scaf;	  
} //end while


	//processing last window in the file
	  if(av_sum_k1 == 0 && av_sum_k2 == 0) 
              {ratio=CC0*10000;	//both are equal 0, on case if a>0, b>0 it is impossible, so will mean the ERROR	
 	       if(k>0) cout<<"There is a window "<< scaf_pred<<" "<<wb<<" with both samples having 0 coverage and k= "<<k<<endl;  	
	      }
          else
	      {
		  if(av_sum_k1 == 0) av_sum_k1=(av_sum_k2<CC0)?av_sum_k2:CC0;   // sample1 == 0 and sample2 >= b; but if av_sum_k2<CC0, - case of misalignment, or alignment on the flank, better to report equal ratio, as both samples are close to ZERO
		  if(av_sum_k2 == 0) av_sum_k2=(av_sum_k1<CC0)?av_sum_k1:CC0;   // sample1 >=a and sample2 == 0
		  ratio=(float)(av_sum_k1/av_sum_k2);  
	       }
 	 
	    
  	     av1=av_sum_k1/k;
	     av2=av_sum_k2/k;

	    
	    if(r>=l) outfile<<scaf_pred<<"\t"<<wb<<"\t"<<r<<"\t"<<k<<"\t"<<av1<<"\t"<<av2<<"\t"<<ratio<<"\n"; 
          

   outfile.close();
   unionbed_file.close();
  }
 else {
  /* could not open directory */
  perror ("Can't open unionbed file ");
 }

   return 0 ;
}


