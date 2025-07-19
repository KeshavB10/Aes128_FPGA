module decryptRound(in,key,out);
input [127:0] in;
output [127:0] out;
input [127:0] key;
wire [127:0] afterSubBytes;
wire [127:0] afterShiftRows;
wire [127:0] afterMixColumns;
wire [127:0] afterAddroundKey;

inv_shift_rows r(in,afterShiftRows);
inv_sub_bytes s(afterShiftRows,afterSubBytes);
addRoundKey b(afterSubBytes,afterAddroundKey,key);
inv_mix_columns m(afterAddroundKey,out);
		
endmodule

module addRoundKey(data, out, key);

input [127:0] data;
input [127:0] key;
output [127:0] out;

assign out = key ^ data;

endmodule
