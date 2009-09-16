/*================================================================================
== @  @
==
==  DESC: generate sine wave output sin(2*pi*f*n*t); f=5kHz, t=0.0001953125
==  USAGE: 
==  INPUTS:
==  OUTPUTS:
==  RETURN:
==  IMP NOTE:
==============================================================================*/
#include <stdio.h>
#include <math.h>

#define PI		(3.142)
#define N_MAX	(1000)
#define FIXPOINT_MAX  (4095)
//double time=0.00000018;
double time=0.0000002;
int freq=5000; //5kHz

void main(void)
{
   FILE * fp = NULL;
   FILE * fp2 = NULL;
   FILE * fp3 = NULL;
   double output=0.0;
   int n=0;
   int fixPoint=0;
   int sawPoint=0;
   fp=fopen("sine_out.txt", "w");
   fp2=fopen("sine_out_fp.txt", "w");
   fp3=fopen("saw_wave.txt", "w");

   while(n<N_MAX)
   {
	  ///-- floating point --
      output=sin(2*PI*freq*n*time);
      fprintf(fp, "%lf,\n", output);

	  ///-- fixed point --
	  /// value range=0 to 2
	  output +=1;
	  fixPoint = (int) (output/2*FIXPOINT_MAX); 
	  fprintf(fp2, "%d,\n", fixPoint);
     //printf("%lf,\n", output);

     ///-- saw_wave --
     sawPoint= (int) ((double) n/1000*FIXPOINT_MAX);
	  fprintf(fp3, "%d,\n", sawPoint);

     ++n;
   }

   fclose(fp);
   fclose(fp2);
}
