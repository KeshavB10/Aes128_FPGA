module AES_Encrypt (
    input wire start,           // Start signal to enable encryption
    input wire [127:0] in,      // Plaintext input
    output wire [127:0] out,    // Ciphertext output
    output wire done_encr        // Done signal indicating encryption completion
);

localparam [127:0] FIXED_KEY = 128'h000102030405060708090a0b0c0d0e0f;
wire [1407:0] fullkeys;
wire [127:0] states [11:0];
wire [127:0] afterSubBytes;
wire [127:0] afterShiftRows;

key_expansion ke (FIXED_KEY,fullkeys);

addRoundKey addrk1(in,states[0],fullkeys[1407-:128]);

genvar i;
generate
	
	for(i=1; i<10 ;i=i+1)begin : loop
		encryptRound er(states[i-1],fullkeys[(1407-(128*i))-:128],states[i]);
	end

endgenerate

sub_bytes sb(states[9],afterSubBytes);
shift_rows sr(afterSubBytes,afterShiftRows);
addRoundKey addrk2(afterShiftRows,states[10],fullkeys[127:0]);


// Output logic: only valid when start is high
    assign out = start ? states[10] : 128'b0; // Output is zero unless start is high
    assign done_encr = start;                  // Done immediately when start is high (combinatorial)

endmodule
