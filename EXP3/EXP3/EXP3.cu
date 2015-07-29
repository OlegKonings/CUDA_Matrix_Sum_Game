#include <algorithm>
#include <iostream>
#include <fstream>
#include <sstream>
#include <utility>
#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <string>
#include <cmath>
//#include <map>
#include <ctime>
#include <cuda.h>
#include <math_functions.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <Windows.h>
#include <MMSystem.h>
#pragma comment(lib, "winmm.lib")
#define _CRTDBG_MAP_ALLOC
#include <crtdbg.h>
using namespace std;

typedef long long ll;


#define _DTH cudaMemcpyDeviceToHost
#define _DTD cudaMemcpyDeviceToDevice
#define _HTD cudaMemcpyHostToDevice

#define THREADS 256//do not change
#define MEGA 33232930569601LL//ditto

const int blockSize0=16384;//ditto

long long POW_SEVEN_ARR[17];

bool InitMMTimer(UINT wTimerRes);
void DestroyMMTimer(UINT wTimerRes, bool init);

inline int get_adj_size(const long long num_elem){
	double p=double(num_elem)/double(MEGA);
	if(p>0.8)return 6;
	else if(p>0.6)return 4;
	else if(p>0.4)return 3;
	else if(p>0.2)return 2;
	else
		return 1;
}
inline int get_dynamic_block_size(const int adj_size,const int blkSize){
	return (1<<(adj_size-1))*blkSize;//chk
}

__device__ long long BigPow(long long num, int exp){
	long long ret=1LL;
	while(exp){
		if(exp&1)ret*=num;
		exp>>=1;
		num*=num;
	}
	return ret;
}

void show_arr(const int *Arr, const int d){
	cout<<"board= \n";
	for(int i=0;i<d;i++){
		cout<<Arr[i]<<' ';
		if((i+1)%4==0)cout<<'\n';
	}
	cout<<'\n';
}
void CPU_derive_from_num(long long num, int *Arr, const int digits,const int range, const long long *POw_Arr){
	long long a;
	for(int i=digits-1;i>0;i--){
		a=long long(range-1);
		while(a*POw_Arr[i]>num){a--;}
		Arr[i]=int(a);
		num-=a*POw_Arr[i];
	}
	Arr[0]=int(num);
}


template<int blockWork>
__global__ void GPU_step0(int *best_val, long long *bnum){

	const long long offset=long long(threadIdx.x)+long long(blockIdx.x)*long long(blockWork);
	const int reps=blockWork>>8;
	const int warpIndex = threadIdx.x%32;

	 __shared__ int blk_best[8];
     __shared__ int2 mask_val[8];

	int Arr[16];
	long long pos;//a
	int ii=0,jj,tot=0;
	int2 mask_as_int2,t2;

	for(;ii<reps;ii++){
		pos=offset+long long(ii*THREADS);
		Arr[15]=t2.x=int(pos/4747561509943LL);
		pos-=long long(t2.x)*4747561509943LL;
		Arr[14]=t2.x=int(pos/678223072849LL);
		pos-=long long(t2.x)*678223072849LL;
		Arr[13]=t2.x=int(pos/96889010407LL);
		pos-=long long(t2.x)*96889010407LL;
		Arr[12]=t2.x=int(pos/13841287201LL);
		pos-=long long(t2.x)*13841287201LL;
		Arr[11]=t2.x=int(pos/1977326743LL);
		pos-=long long(t2.x)*1977326743LL;
		t2.y=int(pos);
		Arr[10]=t2.x=t2.y/282475249;
		t2.y-=t2.x*282475249;
		Arr[9]=t2.x=t2.y/40353607;
		t2.y-=t2.x*40353607;
		Arr[8]=t2.x=t2.y/5764801;
		t2.y-=t2.x*5764801;
		Arr[7]=t2.x=t2.y/823543;
		t2.y-=t2.x*823543;
		Arr[6]=t2.x=t2.y/117649;
		t2.y-=t2.x*117649;
		Arr[5]=t2.x=t2.y/16807;
		t2.y-=t2.x*16807;
		Arr[4]=t2.x=t2.y/2401;
		t2.y-=t2.x*2401;
		Arr[3]=t2.x=t2.y/343;
		t2.y-=t2.x*343;
		Arr[2]=t2.x=t2.y/49;
		t2.y-=t2.x*49;
		Arr[1]=t2.x=t2.y/7;
		t2.y-=t2.x*7;	
		Arr[0]=t2.y;

		jj=int(Arr[0]+Arr[1]+Arr[2]+Arr[3]==10)+int(Arr[4]+Arr[5]+Arr[6]+Arr[7]==10)+
			int(Arr[8]+Arr[9]+Arr[10]+Arr[11]==10)+int(Arr[12]+Arr[13]+Arr[14]+Arr[15]==10)+
			int(Arr[0]+Arr[4]+Arr[8]+Arr[12]==10)+int(Arr[1]+Arr[5]+Arr[9]+Arr[13]==10)+
			int(Arr[2]+Arr[6]+Arr[10]+Arr[14]==10)+int(Arr[3]+Arr[7]+Arr[11]+Arr[15]==10)+
			int(Arr[0]+Arr[5]+Arr[10]+Arr[15]==10)+int(Arr[3]+Arr[6]+Arr[9]+Arr[12]==10);

		if(jj>tot){
			tot=jj;
			pos=offset+long long(ii*THREADS);
			mask_as_int2=*reinterpret_cast<int2 *>(&pos);
		}
	}

	for(ii=16;ii>0;ii>>=1){
		jj=__shfl(tot,warpIndex+ii);
		t2.x=__shfl(mask_as_int2.x,warpIndex+ii);
        t2.y=__shfl(mask_as_int2.y,warpIndex+ii);
		if(jj>tot){
			tot=jj;
			mask_as_int2=t2;
		}
	}

	if(warpIndex==0){
		blk_best[threadIdx.x>>5]=tot;
		mask_val[threadIdx.x>>5]=mask_as_int2;
	}
	__syncthreads();

	if(threadIdx.x==0){
		tot=blk_best[0];
		t2=mask_val[0];
		if(blk_best[1]>tot){
			tot=blk_best[1];
			t2=mask_val[1];
		}
		if(blk_best[2]>tot){
			tot=blk_best[2];
			t2=mask_val[2];
		}
		if(blk_best[3]>tot){
			tot=blk_best[3];
			t2=mask_val[3];
		}
		if(blk_best[4]>tot){
			tot=blk_best[4];
			t2=mask_val[4];
		}
		if(blk_best[5]>tot){
			tot=blk_best[5];
			t2=mask_val[5];
		}
		if(blk_best[6]>tot){
			tot=blk_best[6];
			t2=mask_val[6];
		}
		if(blk_best[7]>tot){
			tot=blk_best[7];
			t2=mask_val[7];
		}

		best_val[blockIdx.x]=tot;
		bnum[blockIdx.x]=*reinterpret_cast<long long *>(&t2);
	}
}

__global__ void last_step(int *best_val, long long *bnum,const long long rem_start, const long long bound, const int num_blox){

	const long long offset=long long(threadIdx.x)+rem_start;
	const int warpIndex = threadIdx.x%32;

	__shared__ int blk_best[8];
    __shared__ int2 mask_val[8];

	int Arr[16];
	long long pos,adj=0LL;
	int ii=1,jj,tot=0;
	int2 mask_as_int2,t2;

	for(;(offset+adj)<bound;ii++){
		pos=offset+adj;

		Arr[15]=t2.x=int(pos/4747561509943LL);
		pos-=long long(t2.x)*4747561509943LL;
		Arr[14]=t2.x=int(pos/678223072849LL);
		pos-=long long(t2.x)*678223072849LL;
		Arr[13]=t2.x=int(pos/96889010407LL);
		pos-=long long(t2.x)*96889010407LL;
		Arr[12]=t2.x=int(pos/13841287201LL);
		pos-=long long(t2.x)*13841287201LL;
		Arr[11]=t2.x=int(pos/1977326743LL);
		pos-=long long(t2.x)*1977326743LL;
		t2.y=int(pos);
		Arr[10]=t2.x=t2.y/282475249;
		t2.y-=t2.x*282475249;
		Arr[9]=t2.x=t2.y/40353607;
		t2.y-=t2.x*40353607;
		Arr[8]=t2.x=t2.y/5764801;
		t2.y-=t2.x*5764801;
		Arr[7]=t2.x=t2.y/823543;
		t2.y-=t2.x*823543;
		Arr[6]=t2.x=t2.y/117649;
		t2.y-=t2.x*117649;
		Arr[5]=t2.x=t2.y/16807;
		t2.y-=t2.x*16807;
		Arr[4]=t2.x=t2.y/2401;
		t2.y-=t2.x*2401;
		Arr[3]=t2.x=t2.y/343;
		t2.y-=t2.x*343;
		Arr[2]=t2.x=t2.y/49;
		t2.y-=t2.x*49;
		Arr[1]=t2.x=t2.y/7;
		t2.y-=t2.x*7;	
		Arr[0]=t2.y;

		jj=int(Arr[0]+Arr[1]+Arr[2]+Arr[3]==10)+int(Arr[4]+Arr[5]+Arr[6]+Arr[7]==10)+
			int(Arr[8]+Arr[9]+Arr[10]+Arr[11]==10)+int(Arr[12]+Arr[13]+Arr[14]+Arr[15]==10)+
			int(Arr[0]+Arr[4]+Arr[8]+Arr[12]==10)+int(Arr[1]+Arr[5]+Arr[9]+Arr[13]==10)+
			int(Arr[2]+Arr[6]+Arr[10]+Arr[14]==10)+int(Arr[3]+Arr[7]+Arr[11]+Arr[15]==10)+
			int(Arr[0]+Arr[5]+Arr[10]+Arr[15]==10)+int(Arr[3]+Arr[6]+Arr[9]+Arr[12]==10);

		if(jj>tot){
			tot=jj;
			pos=offset+adj;
			mask_as_int2=*reinterpret_cast<int2 *>(&pos);
		}
		adj=(long long(ii)<<8LL);
	}

	adj=0LL;
	for(ii=1;(threadIdx.x+int(adj))<num_blox;ii++){
		jj=(threadIdx.x+int(adj));
		if(best_val[jj]>tot){
			tot=best_val[jj];
			pos=bnum[jj];
			mask_as_int2=*reinterpret_cast<int2 *>(&pos);
		}
		adj=(long long(ii)<<8LL);
	}

	for(ii=16;ii>0;ii>>=1){
		jj=__shfl(tot,warpIndex+ii);
		t2.x=__shfl(mask_as_int2.x,warpIndex+ii);
        t2.y=__shfl(mask_as_int2.y,warpIndex+ii);
		if(jj>tot){
			tot=jj;
			mask_as_int2=t2;
		}
	}

	if(warpIndex==0){
		blk_best[threadIdx.x>>5]=tot;
		mask_val[threadIdx.x>>5]=mask_as_int2;
	}
	__syncthreads();

	if(threadIdx.x==0){
		tot=blk_best[0];
		t2=mask_val[0];
		if(blk_best[1]>tot){
			tot=blk_best[1];
			t2=mask_val[1];
		}
		if(blk_best[2]>tot){
			tot=blk_best[2];
			t2=mask_val[2];
		}
		if(blk_best[3]>tot){
			tot=blk_best[3];
			t2=mask_val[3];
		}
		if(blk_best[4]>tot){
			tot=blk_best[4];
			t2=mask_val[4];
		}
		if(blk_best[5]>tot){
			tot=blk_best[5];
			t2=mask_val[5];
		}
		if(blk_best[6]>tot){
			tot=blk_best[6];
			t2=mask_val[6];
		}
		if(blk_best[7]>tot){
			tot=blk_best[7];
			t2=mask_val[7];
		}

		best_val[0]=tot;
		bnum[0]=*reinterpret_cast<long long *>(&t2);
	}
}


int main(){


	cudaError_t err;

	POW_SEVEN_ARR[0]=1LL;
	for(int i=1;i<=16;i++){
		POW_SEVEN_ARR[i]=7LL*POW_SEVEN_ARR[i-1];
	}
	//long long num=7LL;
	//const int range=7;
	const int digits=16;
	int *Board=(int *)malloc(digits*sizeof(int));
	
	//CPU_derive_from_num(num,Board,digits,range,POW_SEVEN_ARR);
	//show_arr(Board,digits);
	const long long range=POW_SEVEN_ARR[16];
	const int adj_size=get_adj_size(range);
	const int temp_blocks_sz=get_dynamic_block_size(adj_size,blockSize0);
	const int num_blx=int(range/long long(temp_blocks_sz));
	const long long rem_start=range-(range-long long(num_blx)*long long(temp_blocks_sz));
	std::cout<<"\nnum_blx= "<<num_blx<<'\n';

	int GPU_answer=0;
	long long GPU_board=0LL;

	int *best_val;
	long long *bnum;

	err=cudaMalloc((void**)&best_val,num_blx*sizeof(int));
	if(err!=cudaSuccess){printf("%s in %s at line %d\n",cudaGetErrorString(err),__FILE__,__LINE__);}
	err=cudaMalloc((void**)&bnum,num_blx*sizeof(long long));
	if(err!=cudaSuccess){printf("%s in %s at line %d\n",cudaGetErrorString(err),__FILE__,__LINE__);}

	
    UINT wTimerRes = 0;
	DWORD GPU_time=0;
    bool init = InitMMTimer(wTimerRes);
    DWORD startTime=timeGetTime();


	GPU_step0<blockSize0><<<num_blx,THREADS>>>(best_val,bnum);
	err = cudaThreadSynchronize();
	if(err!=cudaSuccess){printf("%s in %s at line %d\n",cudaGetErrorString(err),__FILE__,__LINE__);}

	last_step<<<1,THREADS>>>(best_val,bnum,rem_start,range,num_blx);
	err = cudaThreadSynchronize();
	if(err!=cudaSuccess){printf("%s in %s at line %d\n",cudaGetErrorString(err),__FILE__,__LINE__);}

	err=cudaMemcpy(&GPU_answer,best_val,sizeof(int),_DTH);
	if(err!=cudaSuccess){printf("%s in %s at line %d\n",cudaGetErrorString(err),__FILE__,__LINE__);}

	err=cudaMemcpy(&GPU_board,bnum,sizeof(long long),_DTH);
	if(err!=cudaSuccess){printf("%s in %s at line %d\n",cudaGetErrorString(err),__FILE__,__LINE__);}


	DWORD endTime = timeGetTime();
	GPU_time=endTime-startTime;
	DestroyMMTimer(wTimerRes, init);


	err=cudaFree(best_val);
	if(err!=cudaSuccess){printf("%s in %s at line %d\n",cudaGetErrorString(err),__FILE__,__LINE__);}
	err=cudaFree(bnum);
	if(err!=cudaSuccess){printf("%s in %s at line %d\n",cudaGetErrorString(err),__FILE__,__LINE__);}

	cout<<"\nGPU timing= "<<GPU_time<<'\n';
	cout<<"\nOptimal score = "<<GPU_answer<<'\n';
	CPU_derive_from_num(GPU_board,Board,digits,7,POW_SEVEN_ARR);
	show_arr(Board,digits);
	cout<<"number = "<<GPU_board<<'\n';


	free(Board);

	err=cudaDeviceReset();
	if(err!=cudaSuccess){printf("%s in %s at line %d\n",cudaGetErrorString(err),__FILE__,__LINE__);}

	return 0;
}

bool InitMMTimer(UINT wTimerRes){
	TIMECAPS tc;
	if (timeGetDevCaps(&tc, sizeof(TIMECAPS)) != TIMERR_NOERROR) {return false;}
	wTimerRes = min(max(tc.wPeriodMin, 1), tc.wPeriodMax);
	timeBeginPeriod(wTimerRes); 
	return true;
}

void DestroyMMTimer(UINT wTimerRes, bool init){
	if(init)
		timeEndPeriod(wTimerRes);
}
