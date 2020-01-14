# for i in range(16):
#    print("next_sram_256x4b #(.ADDR_SPACE(NEXT_ADDR_SPACE),.Q(Q),.BW(NEXT_BW)) \nw%d_next_sram_256x4b(" % i, end='')
#    print(".clk(clk), .wsb(), .wdata(), .waddr(), .raddr(next_sram_raddr), .rdata(next_sram_rdata%d));" % (i))
sss = '''
for(buffj = 0; buffj < Q - 1; buffj = buffj + 1) begin  
    if(psum_set) begin 
        if(export[{0}] == 1 && buffaccum[{0}] > buffj) begin 
            n_buffer_{0}[buffj] = buffer_{0}[buffj + Q];
        end else begin 
            if(buffaccum[{0}] > buffj)  n_buffer_{0}[buffj] = buffer_{0}[buffj]; 
            else                        n_buffer_{0}[buffj] =
                 ((buff_next[0] == 4'd{0}) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd{0}) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd{0}) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd{0}) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd{0}) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd{0}) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd{0}) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd{0}) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd{0}) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd{0}) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd{0}) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd{0}) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd{0}) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd{0}) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd{0}) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd{0}) * (buffer_idx[15] == buffj) * v_gidx[15]);
        end 
    end else begin 
        n_buffer_{0}[buffj] = buffer_{0}[buffj];
    end 
end 
'''
sss2 = '''
for(buffj = Q - 1; buffj < 2*Q-1; buffj = buffj + 1) begin  
    if(psum_set)  
        n_buffer_{0}[buffj] = ((buff_next[0] == 4'd{0}) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd{0}) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd{0}) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd{0}) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd{0}) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd{0}) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd{0}) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd{0}) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd{0}) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd{0}) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd{0}) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd{0}) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd{0}) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd{0}) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd{0}) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd{0}) * (buffer_idx[15] == buffj) * v_gidx[15]);
    else 
        n_buffer_{0}[buffj] = buffer_{0}[buffj];
end 
'''

# bit width
sss = '''
for(buffj = 0; buffj < Q - 1; buffj = buffj + 1) begin  
    if(psum_set) begin 
        if(export[{0}] == 1 && buffaccum[{0}] > buffj[3:0]) begin 
            n_buffer_{0}[buffj] = buffer_{0}[buffj + Q];
        end else begin 
            if(buffaccum[{0}] > buffj[3:0])  n_buffer_{0}[buffj] = buffer_{0}[buffj]; 
            else                        n_buffer_{0}[buffj] =
                 ((buff_next[0] == 4'd{0}) * (buffer_idx[0] == buffj[3:0]) * v_gidx[0]) | ((buff_next[1] == 4'd{0}) * (buffer_idx[1] == buffj[3:0]) * v_gidx[1]) | ((buff_next[2] == 4'd{0}) * (buffer_idx[2] == buffj[3:0]) * v_gidx[2]) | ((buff_next[3] == 4'd{0}) * (buffer_idx[3] == buffj[3:0]) * v_gidx[3]) | ((buff_next[4] == 4'd{0}) * (buffer_idx[4] == buffj[3:0]) * v_gidx[4]) | ((buff_next[5] == 4'd{0}) * (buffer_idx[5] == buffj[3:0]) * v_gidx[5]) | ((buff_next[6] == 4'd{0}) * (buffer_idx[6] == buffj[3:0]) * v_gidx[6]) | ((buff_next[7] == 4'd{0}) * (buffer_idx[7] == buffj[3:0]) * v_gidx[7]) | ((buff_next[8] == 4'd{0}) * (buffer_idx[8] == buffj[3:0]) * v_gidx[8]) | ((buff_next[9] == 4'd{0}) * (buffer_idx[9] == buffj[3:0]) * v_gidx[9]) | ((buff_next[10] == 4'd{0}) * (buffer_idx[10] == buffj[3:0]) * v_gidx[10]) | ((buff_next[11] == 4'd{0}) * (buffer_idx[11] == buffj[3:0]) * v_gidx[11]) | ((buff_next[12] == 4'd{0}) * (buffer_idx[12] == buffj[3:0]) * v_gidx[12]) | ((buff_next[13] == 4'd{0}) * (buffer_idx[13] == buffj[3:0]) * v_gidx[13]) | ((buff_next[14] == 4'd{0}) * (buffer_idx[14] == buffj[3:0]) * v_gidx[14]) | ((buff_next[15] == 4'd{0}) * (buffer_idx[15] == buffj[3:0]) * v_gidx[15]);
        end 
    end else begin 
        n_buffer_{0}[buffj] = buffer_{0}[buffj];
    end 
end 
'''
sss2 = '''
for(buffj = Q - 1; buffj < 2*Q-1; buffj = buffj + 1) begin  
    if(psum_set)  
        n_buffer_{0}[buffj] = ((buff_next[0] == 4'd{0}) * (buffer_idx[0] == buffj[3:0]) * v_gidx[0]) | ((buff_next[1] == 4'd{0}) * (buffer_idx[1] == buffj[3:0]) * v_gidx[1]) | ((buff_next[2] == 4'd{0}) * (buffer_idx[2] == buffj[3:0]) * v_gidx[2]) | ((buff_next[3] == 4'd{0}) * (buffer_idx[3] == buffj[3:0]) * v_gidx[3]) | ((buff_next[4] == 4'd{0}) * (buffer_idx[4] == buffj[3:0]) * v_gidx[4]) | ((buff_next[5] == 4'd{0}) * (buffer_idx[5] == buffj[3:0]) * v_gidx[5]) | ((buff_next[6] == 4'd{0}) * (buffer_idx[6] == buffj[3:0]) * v_gidx[6]) | ((buff_next[7] == 4'd{0}) * (buffer_idx[7] == buffj[3:0]) * v_gidx[7]) | ((buff_next[8] == 4'd{0}) * (buffer_idx[8] == buffj[3:0]) * v_gidx[8]) | ((buff_next[9] == 4'd{0}) * (buffer_idx[9] == buffj[3:0]) * v_gidx[9]) | ((buff_next[10] == 4'd{0}) * (buffer_idx[10] == buffj[3:0]) * v_gidx[10]) | ((buff_next[11] == 4'd{0}) * (buffer_idx[11] == buffj[3:0]) * v_gidx[11]) | ((buff_next[12] == 4'd{0}) * (buffer_idx[12] == buffj[3:0]) * v_gidx[12]) | ((buff_next[13] == 4'd{0}) * (buffer_idx[13] == buffj[3:0]) * v_gidx[13]) | ((buff_next[14] == 4'd{0}) * (buffer_idx[14] == buffj[3:0]) * v_gidx[14]) | ((buff_next[15] == 4'd{0}) * (buffer_idx[15] == buffj[3:0]) * v_gidx[15]);
    else 
        n_buffer_{0}[buffj] = buffer_{0}[buffj];
end 
'''
for i in range(16):
    print(sss.format(i))
    print("//--------")
    print(sss2.format(i))
    print("//--------")