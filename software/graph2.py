for i in range(16):
    print("locsram_wdata%d," % i, end='')

for i in range(16):
    print("locsram_wdata%d <= {D{1'b1, buff_next[%d]}};" % (i,i))
print("------------------------")
print("reg [VID_BW-1:0] ", end='')
for i in range(16):
    print("buffer_%d[0:2*Q-1]" % i, end=",")
    if(i % 4 == 3):
        print()
print(";")
print("------------------------")
print("reg [VID_BW-1:0] ", end='')
for i in range(16):
    print("n_buffer_%d[0:2*Q-1]" % i, end=",")
    if(i % 4 == 3):
        print()
print(";")

print("----------buffer--------------")

# {1} < Q
sss = '''
if(psum_set) begin 
    if(export[{0}] == 1'b1 && buffaccum[{0}] > 5'd{1}) begin 
        n_buffer_{0}[{1}] = buffer_{0}[{1} + Q];
    end else begin 
        if(buffaccum[{0}] > 5'd{1}) 
            n_buffer_{0}[{1}] = buffer_{0}[{1}]; 
        else  
            n_buffer_{0}[{1}] = ((buff_next[0] == 4'd{0}) * (buffer_idx[0] == 5'd{1}) * v_gidx[0]) | ((buff_next[1] == 4'd{0}) * (buffer_idx[1] == 5'd{1}) * v_gidx[1]) | ((buff_next[2] == 4'd{0}) * (buffer_idx[2] == 5'd{1}) * v_gidx[2]) | ((buff_next[3] == 4'd{0}) * (buffer_idx[3] == 5'd{1}) * v_gidx[3]) | ((buff_next[4] == 4'd{0}) * (buffer_idx[4] == 5'd{1}) * v_gidx[4]) | ((buff_next[5] == 4'd{0}) * (buffer_idx[5] == 5'd{1}) * v_gidx[5]) | ((buff_next[6] == 4'd{0}) * (buffer_idx[6] == 5'd{1}) * v_gidx[6]) | ((buff_next[7] == 4'd{0}) * (buffer_idx[7] == 5'd{1}) * v_gidx[7]) | ((buff_next[8] == 4'd{0}) * (buffer_idx[8] == 5'd{1}) * v_gidx[8]) | ((buff_next[9] == 4'd{0}) * (buffer_idx[9] == 5'd{1}) * v_gidx[9]) | ((buff_next[10] == 4'd{0}) * (buffer_idx[10] == 5'd{1}) * v_gidx[10]) | ((buff_next[11] == 4'd{0}) * (buffer_idx[11] == 5'd{1}) * v_gidx[11]) | ((buff_next[12] == 4'd{0}) * (buffer_idx[12] == 5'd{1}) * v_gidx[12]) | ((buff_next[13] == 4'd{0}) * (buffer_idx[13] == 5'd{1}) * v_gidx[13]) | ((buff_next[14] == 4'd{0}) * (buffer_idx[14] == 5'd{1}) * v_gidx[14]) | ((buff_next[15] == 4'd{0}) * (buffer_idx[15] == 5'd{1}) * v_gidx[15]);
    end 
end else 
    n_buffer_{0}[{1}] = buffer_{0}[{1}];
'''
# {1} >= Q
sss2 = '''
if(psum_set) begin 
    if(buffaccum[{0}] > 5'd{1}) 
        n_buffer_{0}[{1}] = buffer_{0}[{1}]; 
    else  
        n_buffer_{0}[{1}] = ((buff_next[0] == 4'd{0}) * (buffer_idx[0] == 5'd{1}) * v_gidx[0]) | ((buff_next[1] == 4'd{0}) * (buffer_idx[1] == 5'd{1}) * v_gidx[1]) | ((buff_next[2] == 4'd{0}) * (buffer_idx[2] == 5'd{1}) * v_gidx[2]) | ((buff_next[3] == 4'd{0}) * (buffer_idx[3] == 5'd{1}) * v_gidx[3]) | ((buff_next[4] == 4'd{0}) * (buffer_idx[4] == 5'd{1}) * v_gidx[4]) | ((buff_next[5] == 4'd{0}) * (buffer_idx[5] == 5'd{1}) * v_gidx[5]) | ((buff_next[6] == 4'd{0}) * (buffer_idx[6] == 5'd{1}) * v_gidx[6]) | ((buff_next[7] == 4'd{0}) * (buffer_idx[7] == 5'd{1}) * v_gidx[7]) | ((buff_next[8] == 4'd{0}) * (buffer_idx[8] == 5'd{1}) * v_gidx[8]) | ((buff_next[9] == 4'd{0}) * (buffer_idx[9] == 5'd{1}) * v_gidx[9]) | ((buff_next[10] == 4'd{0}) * (buffer_idx[10] == 5'd{1}) * v_gidx[10]) | ((buff_next[11] == 4'd{0}) * (buffer_idx[11] == 5'd{1}) * v_gidx[11]) | ((buff_next[12] == 4'd{0}) * (buffer_idx[12] == 5'd{1}) * v_gidx[12]) | ((buff_next[13] == 4'd{0}) * (buffer_idx[13] == 5'd{1}) * v_gidx[13]) | ((buff_next[14] == 4'd{0}) * (buffer_idx[14] == 5'd{1}) * v_gidx[14]) | ((buff_next[15] == 4'd{0}) * (buffer_idx[15] == 5'd{1}) * v_gidx[15]);
end else 
    n_buffer_{0}[{1}] = buffer_{0}[{1}];
'''

for buffi in range(16):
    for buffj in range(32):
        if(buffj < 16):
            print(sss.format(str(buffi), str(buffj)))
        else:
            print(sss2.format(str(buffi), str(buffj)))
    print("//============================")

print("for(bif = 0; bif < 2 * Q; bif = bif + 1) begin ")
for i in range(16):
    print("buffer_%d[bfi] <= {VID_BW{1'b0}};  " % i, end='')
    if(i % 4 == 3):
        print()
print("end")
print("--------------------")
# print("for(bfidxw = 0; bfidxw < 2 * Q; bfidxw = bfidxw + 1) begin")
for i in range(16):
    print("buffer_%d[bfidxw] <= 0;  " % i, end='')
    if(i % 4 == 3):
        print()
for i in range(16):
    print("buffer_%d[bfidxw] <= n_buffer_%d[bfidxw]; " % (i,i), end='')
    if(i % 4 == 3):
        print()
print("--------------------")
tmps = '''buffer_{0}[0],buffer_{0}[1],buffer_{0}[2],buffer_{0}[3],buffer_{0}[4],buffer_{0}[5],buffer_{0}[6],buffer_{0}[7],buffer_{0}[8],buffer_{0}[9],buffer_{0}[10],buffer_{0}[11],buffer_{0}[12],buffer_{0}[13],buffer_{0}[14],buffer_{0}[15]'''
for i in range(16):
    print("{" + tmps.format(str(i)) + "};")
    # print("-----")