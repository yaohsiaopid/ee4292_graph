module master_top #(
parameter Q = 16,
parameter PRO_BW = 8,
parameter NEXT_BW = 4,
parameter K = 16,
parameter VID_BW = 16,
parameter BUF_BW = 5, // log(2*Q)
parameter OFFSET_BW = 4 // log(Q)
) (
input clk,
input rst_n,
input enable,
// inputs 
input [PRO_BW-1:0] pro_num, // vertex' proposal number 

// outputs 
output [7:0] reg epoch,

);
// epoch[7:4] -> i, current partition
reg [NEXT_BW-1:0] next_arr[0:Q-1];      // register             
reg [PRO_BW-1:0] proposal_nums[0:Q-1];  // register         
reg [PRO_BW-1:0] mi_j[0:K-1];           // register 
reg [PRO_BW-1:0] mj_i[0:K-1];           // register 
reg [NEXT_BW-1:0] real_next_arr[0:Q-1], nreal_next_arr[0:Q-1], buff_next[0:Q-1];
// ================================================
// TOOD: prepare: next_arr, mi_j, mj_i, v_gidx , propsal_nums

// ================================================
reg [VID_BW-1:0] v_gidx[0:Q-1]; // from vid sram
// K buffers, each of Q 
reg [VID_BW-1:0] buffer [0:K-1] [0:2*Q-1], n_buffer[0:K-1][0:2*Q-1];
reg [BUF_BW-1:0] accum[0:K-1], n_accum[0:K-1]; // buffer size for each of K buffers
reg [BUF_BW-1:0] buffer_idx[0:Q-1], nbuffer_idx[0:Q-1]; // additioanl bit??
reg [BUF_BW-1:0] offset[0:Q-1];
reg export[0:K-1], n_export[0:K-1];
reg [BUF_BW-1:0] buffaccum[0:K-1], n_buffaccum[0:K-1]; // for buffer indexing's accum
// compute offset 
reg [K-1:0] onehot[0:Q-1];
reg [OFFSET_BW-1:0] partial_sum[0:Q-1][0:K-1];
integer o_idx, in_idx;
integer accumidx;
integer partial_i, partial_j, check_i;
integer buffi,buffj;
wire [BUF_BW:0] check_acc[0:K-1];
for(check_i = 0; check_i < K; check_i = check_i + 1) 
    assign check_acc[check_i] = accum[check_i] + partial_sum[15][check_i];

always @* begin 
    for(o_idx = 0; o_idx < Q; o_idx = o_idx + 1) begin 
        for(in_idx = 0; in_idx < K; in_idx = in_idx + 1) begin
            onehot[o_idx][in_idx] = real_next_arr[o_idx] == in_idx;
        end 
    end 
    
    for(partial_j = 0; partial_j < K; partial_j = partial_j + 1) begin
        partial_sum[0][partial_j] =  onehot[0][partial_j];
        partial_sum[1][partial_j] =  onehot[0][partial_j]+onehot[1][partial_j];
        partial_sum[2][partial_j] =  onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j];
        partial_sum[3][partial_j] =  onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j];
        partial_sum[4][partial_j] =  onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j];
        partial_sum[5][partial_j] =  onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j];
        partial_sum[6][partial_j] =  onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j];
        partial_sum[7][partial_j] =  onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j]+onehot[7][partial_j];
        partial_sum[8][partial_j] =  onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j]+onehot[7][partial_j]+onehot[8][partial_j];
        partial_sum[9][partial_j] =  onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j]+onehot[7][partial_j]+onehot[8][partial_j]+onehot[9][partial_j];
        partial_sum[10][partial_j] = onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j]+onehot[7][partial_j]+onehot[8][partial_j]+onehot[9][partial_j]+onehot[10][partial_j];
        partial_sum[11][partial_j] = onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j]+onehot[7][partial_j]+onehot[8][partial_j]+onehot[9][partial_j]+onehot[10][partial_j]+onehot[11][partial_j];
        partial_sum[12][partial_j] = onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j]+onehot[7][partial_j]+onehot[8][partial_j]+onehot[9][partial_j]+onehot[10][partial_j]+onehot[11][partial_j]+onehot[12][partial_j];
        partial_sum[13][partial_j] = onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j]+onehot[7][partial_j]+onehot[8][partial_j]+onehot[9][partial_j]+onehot[10][partial_j]+onehot[11][partial_j]+onehot[12][partial_j]+onehot[13][partial_j];
        partial_sum[14][partial_j] = onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j]+onehot[7][partial_j]+onehot[8][partial_j]+onehot[9][partial_j]+onehot[10][partial_j]+onehot[11][partial_j]+onehot[12][partial_j]+onehot[13][partial_j]+onehot[14][partial_j];
        partial_sum[15][partial_j] = onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j]+onehot[7][partial_j]+onehot[8][partial_j]+onehot[9][partial_j]+onehot[10][partial_j]+onehot[11][partial_j]+onehot[12][partial_j]+onehot[13][partial_j]+onehot[14][partial_j]+onehot[15][partial_j];
    
    end 
    
    for(partial_i = 0; partial_i < Q; partial_i = partial_i + 1) 
        nbuffer_idx[partial_i] = (partial_sum[partial_i][real_next_arr[partial_i]] - 1) + (accum[real_next_arr[partial_j]] >= Q ? accum[real_next_arr[partial_j]] - Q : accum[real_next_arr[partial_j]]) ;
        // TODO: accum[q] == Q also update to partial_sum[15][q], / transfer out 
    
       
    for(accumidx = 0; accumidx < K; accumidx = accumidx + 1) begin 
        if(check_acc[accumidx] >= Q) begin 
        n_accum[accumidx] = check_acc[accumidx] - Q;
        n_export[accumidx] = 1;
        n_buffaccum[accumidx] = accum[accumidx]; // retain the offset that to be FIFOed
        end else begin 
        n_accum[accumidx] = check_acc[accumidx];
        n_export[accumidx] = 0;
        n_buffaccum[accumidx] = 0;
        end 
    end 
    for(buffi = 0; buffi < K; buffi = buffi + 1) begin 
        for(buffj = 0; buffj < 2*Q; buffj = buffj + 1) begin  
            if(buffj < Q && export[buffi] == 1] && buffj < buffaccum[buffi]) begin 
                // shift 
                n_buffer[buffi][buffj] = buffer[buffi][buffj + Q];
            end else begin 
                // take new 
                n_buffer[buffi][buffj] =(buff_next[0] == buffi) * (buffer_idx[0] == buffj) * v_gidx[0] +
                                        (buff_next[1] == buffi) * (buffer_idx[1] == buffj) * v_gidx[1] +
                                        (buff_next[2] == buffi) * (buffer_idx[2] == buffj) * v_gidx[2] +
                                        (buff_next[3] == buffi) * (buffer_idx[3] == buffj) * v_gidx[3] +
                                        (buff_next[4] == buffi) * (buffer_idx[4] == buffj) * v_gidx[4] +
                                        (buff_next[5] == buffi) * (buffer_idx[5] == buffj) * v_gidx[5] +
                                        (buff_next[6] == buffi) * (buffer_idx[6] == buffj) * v_gidx[6] +
                                        (buff_next[7] == buffi) * (buffer_idx[7] == buffj) * v_gidx[7] +
                                        (buff_next[8] == buffi) * (buffer_idx[8] == buffj) * v_gidx[8] +
                                        (buff_next[9] == buffi) * (buffer_idx[9] == buffj) * v_gidx[9] +
                                        (buff_next[10] == buffi) * (buffer_idx[10] == buffj) * v_gidx[10] +
                                        (buff_next[11] == buffi) * (buffer_idx[11] == buffj) * v_gidx[11] +
                                        (buff_next[12] == buffi) * (buffer_idx[12] == buffj) * v_gidx[12] +
                                        (buff_next[13] == buffi) * (buffer_idx[13] == buffj) * v_gidx[13] +
                                        (buff_next[14] == buffi) * (buffer_idx[14] == buffj) * v_gidx[14] +
                                        (buff_next[15] == buffi) * (buffer_idx[15] == buffj) * v_gidx[15];
            end 
        end 
    end 

    
end 

// comb7 get xij
reg [PRO_BW-1:0] xijs[0:K-1]; // n_xijs[0:K-1];

integer j, qiter;
always @* begin 
    for(j = 0; j < K; j = j + 1) begin 
        xijs[j] = mi_j[j] < mj_i[j] ? mi_j[j] : mj_i[j];
    end 
    for(qiter = 0; qiter < Q; qiter = qiter + 1) begin
        nreal_next_arr[qiter] = xijs[next_arr[qiter]] > proposal_nums[qiter] ? next_arr[qiter] : epoch[7:4]; // < xij move, if not stay at current 
    end 
    
end 
// total epoch = N(4096) / Q(16)
always @(posedge clk) begin 
    if(~rst_n) begin 
        
    end else begin 
    // buffer_idx <= nbuffer_idx
    // accum <= n_accum, export <= n_export , buffaccum <= n_buffaccum
    // real_nextarr <= n_real_nextarr
    // if(export == 1) wdata <= buffer !! 
    // buff_next <= real_nextarr
    end 
end 


endmodule





// case(next_arr[o_idx])
//     4'd0: onehot[o_idx] = 16'b0000000000000001;
//     4'd1: onehot[o_idx] = 16'b0000000000000010;
//     4'd2: onehot[o_idx] = 16'b0000000000000100;
// endcase 