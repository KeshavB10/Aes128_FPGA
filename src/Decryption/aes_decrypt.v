module AES_Decrypt (
    input wire start,           // Start signal to enable encryption
    input wire [127:0] in,      // Ciphered input
    output wire [127:0] out,    // deciphered output
    output wire done_decr        // Done signal indicating decryption completion
);
localparam [127:0] FIXED_KEY = 128'h000102030405060708090a0b0c0d0e0f;

wire [1407 :0] fullkeys;
wire [127:0] states [11:0] ;
wire [127:0] afterSubBytes;
wire [127:0] afterShiftRows;

key_expansion ke(FIXED_KEY,fullkeys);

addRoundKey addrk1 (in,states[0],fullkeys[127:0]);

genvar i;
generate
	
	for(i=1; i<10 ;i=i+1)begin : loop
		decryptRound dr(states[i-1],fullkeys[i*128+:128],states[i]);
		end
endgenerate

inv_shift_rows sr(states[9],afterShiftRows);
inv_sub_bytes sb(afterShiftRows,afterSubBytes);
addRoundKey addrk2(afterSubBytes,states[10],fullkeys[1407-:128]);


// Output logic: only valid when start is high
    assign out = start ? states[10] : 128'b0; // Output is zero unless start is high
    assign done_decr = start;                  // Done immediately when start is high (combinatorial)

endmodule
