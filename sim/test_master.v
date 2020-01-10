// `timescale 1ns/100ps
module test_master;
localparam N = 4096;
localparam K = 16;
localparam NEXT_BW = 4;
localparam PRO_BW = 8;
localparam VID_BW = 12;
localparam Q = 16; 
localparam MAX_EPOCH = 256; // 4096 / 16
real CYCLE = 10;
integer fptr;
//====== module I/O =====
reg clk;
reg rst_n;
reg enable;

// input, assign from gold 
reg [NEXT_BW*Q-1:0] in_next_arr;
reg [PRO_BW*K-1:0] in_mi_j; 
reg [PRO_BW*K-1:0] in_mj_i; 
reg [VID_BW*Q-1:0] in_v_gidx; 
reg [PRO_BW*Q-1:0] in_proposal_nums;

// output 
wire [7:0] epoch;
wire [K-1:0] vidsram_wen; // 0 at MSB  
wire ready; // TODO: if ready == 1 , check at negedge clk     
// =================== instance sram ================================
// master_top #(
//  // 
// )
master_top master_instn (
    .clk(clk),
    .enable(enable),
    .rst_n(rst_n),
    .in_next_arr(in_next_arr),
    .in_mi_j(in_mi_j),
    .in_mj_i(in_mj_i),
    .in_v_gidx(in_v_gidx),
    .in_proposal_nums(in_proposal_nums),
    // output 
    .epoch(epoch),
    .vidsram_wen(vidsram_wen),
    .ready(ready)
);
reg [NEXT_BW*Q-1:0] file_next_arr[0:MAX_EPOCH-1];
reg [PRO_BW*K-1:0] file_mi_j[0:MAX_EPOCH-1]; 
reg [PRO_BW*K-1:0] file_mj_i[0:MAX_EPOCH-1]; 
reg [VID_BW*Q-1:0] file_v_gidx[0:MAX_EPOCH-1]; 
reg [PRO_BW*Q-1:0] file_proposal_nums[0:MAX_EPOCH-1];

reg [7:0] gold_epoch;
reg [K-1:0] gold_wen;
reg [Q * VID_BW - 1:0] gold_wdata; 
reg [4 - 1:0] gold_waddr;
reg [7:0] chars[0:2];
always #(CYCLE/2) clk = ~clk;
integer ccc;
integer check_epoch;
initial begin 
    clk = 0;
    rst_n = 1;
    enable = 1'b0;

    $readmemh("../software/gold_master/next_arr.dat", file_next_arr);
    $write("file_next_arr 0: %h\n", file_next_arr[0]);
    $write("file_next_arr 1: %h\n", file_next_arr[1]);
    $readmemh("../software/gold_master/v_gidx.dat", file_v_gidx);
    $write("file_v_gidx 0: %h\n", file_v_gidx[0]);
    $write("file_v_gidx 1: %h\n", file_v_gidx[1]);
    $readmemh("../software/gold_master/mi_j.dat", file_mi_j);
    $write("file_mi_j 0: %h\n", file_mi_j[0]);
    $write("file_mi_j 1: %h\n", file_mi_j[1]);
    $readmemh("../software/gold_master/mj_i.dat", file_mj_i);
    $write("file_mj_i 0: %h\n", file_mj_i[0]);
    $write("file_mj_i 1: %h\n", file_mj_i[1]);
    $readmemh("../software/gold_master/proposal_nums.dat", file_proposal_nums);
    $write("file_proposal_nums 0: %h\n", file_proposal_nums[0]);
    $write("file_proposal_nums 1: %h\n", file_proposal_nums[1]);
    #(CYCLE) rst_n = 0; 
    // input test pattern, epoch should = 0 
    in_next_arr = file_next_arr[epoch];
    in_mi_j = file_mi_j[epoch];
    in_mj_i = file_mj_i[epoch];
    in_v_gidx = file_v_gidx[epoch];
    in_proposal_nums = file_proposal_nums[epoch];
    enable = 1'b1;
    #(CYCLE) rst_n = 1;   
    #(CYCLE)
    while(epoch <= MAX_EPOCH) begin 
        @(negedge clk)
        in_next_arr = file_next_arr[epoch-1 >= 0 ? epoch - 1: 0];
        in_mi_j = file_mi_j[epoch-1 >= 0 ? epoch - 1: 0];
        in_mj_i = file_mj_i[epoch-1 >= 0 ? epoch - 1: 0];
        in_v_gidx = file_v_gidx[epoch-4 >= 0 ? epoch - 4: 0];
        in_proposal_nums = file_proposal_nums[epoch-1 >= 0 ? epoch - 1: 0];
    end 
    $finish;
end 

reg [K-1:0] checkbit;
integer checki;
reg [NEXT_BW-1:0] banknum; 
initial begin 
    fptr = $fopen("../software/gold_master/wdata.dat", "r");
    check_epoch = 0;
    wait(ready == 1);
    while(check_epoch < MAX_EPOCH) begin 
        @(negedge clk)
        ccc = $fscanf(fptr, "%h %h", gold_epoch, gold_wen);
        $display("tbepoch: %d %h; %d", gold_epoch, gold_wen, check_epoch);
        if(check_epoch == gold_epoch) begin 
            if(gold_wen !== vidsram_wen) begin 
                $write("gold_wen %h vs vidsram_wen %h\n", gold_wen, vidsram_wen);
                $finish;
            end 
            // else begin 
                if(gold_wen > 0) begin 
                    checkbit = 16'h8000;
                    for(checki = 0; checki < K; checki = checki + 1) begin 
                        if((checkbit & gold_wen) > 0) begin 
                            ccc = $fscanf(fptr, "%h", banknum); 
                            $write("banknum: %d\t\t", banknum);
                            ccc = $fscanf(fptr, "%h", gold_wdata);
                            $write("wdata: %h\n", gold_wdata);
                            if(master_instn.vidsram_wdata[banknum] !== gold_wdata) begin
                                $write("FAIL check: %h vs %h (gold)", master_instn.vidsram_wdata[banknum], gold_wdata); 
                            end 
                        end 
                        checkbit = checkbit >>1;
                    end
                    $write("-------\n"); 
                end 
            // end 
        end
        else begin 
            $display("fscanf fail to sync!");
        end 
        check_epoch = check_epoch + 1;
    end 
end 
initial begin 
    #(CYCLE*1000000);
    $finish;
end 
initial begin 
    // wait(epoch == 100000);
    // $finish;
end 
// initial begin
// 	$fsdbDumpfile("test_master.fsdb");q
// 	$fsdbDumpvars("+mda");
// end
endmodule

