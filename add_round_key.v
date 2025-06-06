module addRoundKey(data, out, key);

input [127:0] data;
input [127:0] key;
output [127:0] out;

assign out = key ^ data;

endmodule

module encryptRound(in,key,out);
input [127:0] in;
output [127:0] out;
input [127:0] key;
wire [127:0] afterSubBytes;
wire [127:0] afterShiftRows;
wire [127:0] afterMixColumns;
wire [127:0] afterAddroundKey;

sub_bytes s(in,afterSubBytes);
shift_rows r(afterSubBytes,afterShiftRows);
mixColumns m(afterShiftRows,afterMixColumns);
addRoundKey b(afterMixColumns,out,key);
		
endmodule
