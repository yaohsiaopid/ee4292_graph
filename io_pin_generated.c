//This is the file to dump IO_pin.tdf
// But the "\" couldn't be print out,so need to be modified by notepas++
#include <stdio.h>		
#include <stdlib.h>		

int main() {    
	int i,j;
	//parameter
	int K = 16;
    int D = 256;
    int DIST_BW = 1;
    int DIST_ADDR_SPACE = 16;
    int LOC_BW = 5;
    int LOC_ADDR_SPACE = 4;
    int NEXT_BW = 4;
    int NEXT_ADDR_SPACE = 4;
    int PRO_BW = 8;
    int PRO_ADDR_SPACE = 4;
    int VID_BW = 16;  // 12???
    int VID_ADDR_SPACE = 4;
    int Q = 16;
    
//1. #Left-side pins from bottom to top : input loc_rdata[0:511], total: 512
	printf("#Left-side pins from bottom to top\n");
	
	for (i = 0; i < D * (LOC_BW - 1) / 2; i++) {
		printf("set_pin_physical_constraints -side 1 -pin_name loc_rdata\\[%d\\]	-order %d	-offset 0\n", i, i + 1);
	}


//2. #Top-side pins from left to right : input vid_rdata(256) + dist_rdata(256) + batch_num(8), total: 520
	printf("\n#Top-side pins from left to right\n");
    // vid_rdata : Q * VID = 256 bits
	for (i = 0; i < Q * VID_BW; i++) {
		printf("set_pin_physical_constraints -side 2 -pin_name vid_rdata\\[%d\\]	-order %d	-offset 0\n", i, i + 1);
	}

	// dist_rdata : D * DIST_BW = 256 bits
	for (i = 0; i < D * DIST_BW; i++) {
		printf("set_pin_physical_constraints -side 2 -pin_name dist_rdata\\[%d\\]	-order %d	-offset 0\n", i, i + 257);
	}
	
	// batch_num: 8 bits
	for (i = 0; i < 8; i++) {
		printf("set_pin_physical_constraints -side 2 -pin_name batch_num\\[%d\\]	-order %d	-offset 0\n", i, i + 513);
	}


//3. #Right-side pins from bottom to top : input loc_rdata[512:1023], total: 512
	printf("\n#Right-side pins from bottom to top\n");
	
	for (i = D * (LOC_BW - 1) / 2; i < D * (LOC_BW - 1); i++) {
		printf("set_pin_physical_constraints -side 3 -pin_name loc_rdata\\[%d\\]	-order %d	-offset 0\n", i, i - 511);
	}

//4.  #Bottom-side pads from left to right : output sub_bat(4), vid(16), next_bytemask(16), next_wdata(64), next_waddr(4), pro_bytemask(16), clk(1), en(1), rst_n(1), pro_wdata(128), pro_waddr(4), ready(1), batch_finish(1), wen(1) : 120 + 3 + 135
	printf("\n#Bottom-side pads from left to right\n");
	
	// sub_bat : 4 bits
	for (i = 0; i < 4; i++) {
		printf("set_pin_physical_constraints -side 4 -pin_name sub_bat\\[%d\\]	-order %d	-offset 0\n", i, i + 1);
	}
	
	// vid : 16 bits
	for (i = 0; i < VID_BW; i++) {
		printf("set_pin_physical_constraints -side 4 -pin_name vid\\[%d\\]	-order %d	-offset 0\n", i, i + 5);
	}

	// next_bytemask : 16 bits
	for (i = 0; i < Q; i++) {
		printf("set_pin_physical_constraints -side 4 -pin_name next_bytemask\\[%d\\]	-order %d	-offset 0\n", i, i + 21);
	}

	// next_wdata : Q * NEXT_BW = 64
	for (i = 0; i < Q * NEXT_BW; i++) {
			printf("set_pin_physical_constraints -side 4 -pin_name next_wdata\\[%d\\]	-order %d	-offset 0\n", i, i + 37);
	}
	// next_waddr : NEXT_ADDR_SPACE = 4
	for (i = 0; i < NEXT_ADDR_SPACE; i++) {
			printf("set_pin_physical_constraints -side 4 -pin_name next_waddr\\[%d\\]	-order %d	-offset 0\n", i, i + 101);
	}

	// pro_bytemask : 16 bits
	for (i = 0; i < Q; i++) {
		printf("set_pin_physical_constraints -side 4 -pin_name pro_bytemask\\[%d\\]	-order %d	-offset 0\n", i, i + 105);
	}

    // clk , en, rst_n
    printf("set_pin_physical_constraints -side 4 -pin_name clk	-order 121	-offset 0\n");
    printf("set_pin_physical_constraints -side 4 -pin_name en	-order 122	-offset 0\n");
	printf("set_pin_physical_constraints -side 4 -pin_name rst_n	-order 123	-offset 0\n");

	// pro_wdata : Q * PRO_BW = 128
	for (i = 0; i < Q * PRO_BW; i++) {
			printf("set_pin_physical_constraints -side 4 -pin_name pro_wdata\\[%d\\]	-order %d	-offset 0\n", i, i + 124);
	}
	// pro_waddr : PRO_ADDR_SPACE = 4
	for (i = 0; i < PRO_ADDR_SPACE; i++) {
			printf("set_pin_physical_constraints -side 4 -pin_name pro_waddr\\[%d\\]	-order %d	-offset 0\n", i, i + 252);
	}

    // ready, batch_finish, wen
    printf("set_pin_physical_constraints -side 4 -pin_name ready	-order 256	-offset 0\n");
    printf("set_pin_physical_constraints -side 4 -pin_name batch_finish	-order 257	-offset 0\n");
	printf("set_pin_physical_constraints -side 4 -pin_name wen	-order 258	-offset 0\n");

	return 0;
} 

