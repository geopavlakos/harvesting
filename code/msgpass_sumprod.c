#define INF 1E20
#include <math.h>
#include "mex.h"

double square(double x) { return x*x; }
#define MAX(x, y) (((x) > (y)) ? (x) : (y))
#define MIN(x, y) (((x) < (y)) ? (x) : (y))

void mexFunction(int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[])
{
    double *pr_in;
    double offset, sigma, th;
    const mwSize *ndims;
    
    double *pr_out;
    double *prior;
    
    int i,j,k;
    
    pr_in = (double *)mxGetPr(prhs[0]);
    ndims = mxGetDimensions(prhs[0]);
    offset = (double)mxGetScalar(prhs[1]);
    sigma = (double)mxGetScalar(prhs[2]);
    th = (double)mxGetScalar(prhs[3]);
    
    plhs[0] = mxCreateNumericArray(3,ndims,mxDOUBLE_CLASS,mxREAL);
    pr_out = (double *)mxGetPr(plhs[0]);

    /*
    prior = calloc(ndims[0]*ndims[1]*ndims[2],sizeof(double));
    for(i=0;i<ndims[0];i++){
        for(j=0;j<ndims[1];j++){
            for(k=0;k<ndims[2];k++){
                prior[i+j*ndims[0]+k*ndims[0]*ndims[1]] =
                       exp( - square(sqrt(square(i)+square(j)+square(k)) - offset) / (2*square(sigma)));
            }
        }
    }
    */
    
    #pragma omp parallel for private(i,j,k)
    for(i=0;i<ndims[0];i++){
        for(j=0;j<ndims[1];j++){
            for(k=0;k<ndims[2];k++){
                
                int ind1,ind2;
                int x,y,z;
                int xmin,xmax,ymin,ymax,zmin,zmax;
                double dx,dy,dz;
                double lmax,lmin;
                double pr;
                
                ind1 = i + j*ndims[0] + k*ndims[0]*ndims[1];
                
                pr = 0;
                
                xmin = (int)MAX(floor((double)i-offset-th),0);
                xmax = (int)MIN(ceil((double)i+offset+th),ndims[0]-1);
                
                for(x=xmin;x<=xmax;x++){
                    
                    dx = fabs((double)(x-i));
                    lmax = sqrt(square(offset+th)-square(dx));
                    ymin = (int)MAX(floor((double)j-lmax),0);
                    ymax = (int)MIN(ceil((double)j+lmax),ndims[1]-1);
                    
                    for(y=ymin;y<=ymax;y++){
                        
                        dy = fabs((double)(y-j));
                        
                        lmax = ceil(sqrt(MAX(square(offset+th)-square(dx)-square(dy),0)));
                        lmin = floor(sqrt(MAX(square(offset-th)-square(dx)-square(dy),0)));
                        
                        zmin = (int)((double)k+lmin);
                        zmax = (int)MIN(((double)k+lmax),ndims[2]-1);
                        for(z=zmin;z<=zmax;z++){
                            dz = fabs((double)(z-k));
                            ind2 = x + y*ndims[0] + z*ndims[0]*ndims[1];
                            pr = pr + pr_in[ind2];
                        }
                        
                        zmin = (int)MAX(((double)k-lmax),0);
                        zmax = (int)((double)k-lmin);
                        for(z=zmin;z<=zmax;z++){
                            dz = fabs((double)(z-k));
                            ind2 = x + y*ndims[0] + z*ndims[0]*ndims[1];
                            pr = pr + pr_in[ind2];
                        }
                    }
                }
                
                pr_out[ind1] = pr;
                
            }
        }
    }   
}

