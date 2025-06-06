module key_expansion(
    input [127:0] key_in,
    output reg [1407:0] round_keys 
);

    reg [31:0] w [0:43];
    integer i;

    // Rcon array
    reg [31:0] Rcon [0:10];
    initial begin
        Rcon[0] = 32'h01000000;
        Rcon[1] = 32'h02000000;
        Rcon[2] = 32'h04000000;
        Rcon[3] = 32'h08000000;
        Rcon[4] = 32'h10000000;
        Rcon[5] = 32'h20000000;
        Rcon[6] = 32'h40000000;
        Rcon[7] = 32'h80000000;
        Rcon[8] = 32'h1b000000;
        Rcon[9] = 32'h36000000;
    end

    // S-Box array definition
    reg [7:0] sbox [0:255];
    initial begin
       sbox[  0] = 8'h63; sbox[  1] = 8'h7c; sbox[  2] = 8'h77; sbox[  3] = 8'h7b; //row0
        sbox[  4] = 8'hf2; sbox[  5] = 8'h6b; sbox[  6] = 8'h6f; sbox[  7] = 8'hc5;
        sbox[  8] = 8'h30; sbox[  9] = 8'h01; sbox[ 10] = 8'h67; sbox[ 11] = 8'h2b;
        sbox[ 12] = 8'hfe; sbox[ 13] = 8'hd7; sbox[ 14] = 8'hab; sbox[ 15] = 8'h76;

        sbox[ 16] = 8'hca; sbox[ 17] = 8'h82; sbox[ 18] = 8'hc9; sbox[ 19] = 8'h7d;//row1
        sbox[ 20] = 8'hfa; sbox[ 21] = 8'h59; sbox[ 22] = 8'h47; sbox[ 23] = 8'hf0;
        sbox[ 24] = 8'had; sbox[ 25] = 8'hd4; sbox[ 26] = 8'ha2; sbox[ 27] = 8'haf;
        sbox[ 28] = 8'h9c; sbox[ 29] = 8'ha4; sbox[ 30] = 8'h72; sbox[ 31] = 8'hc0;

        sbox[ 32] = 8'hb7; sbox[ 33] = 8'hfd; sbox[ 34] = 8'h93; sbox[ 35] = 8'h26;//row2
        sbox[ 36] = 8'h36; sbox[ 37] = 8'h3f; sbox[ 38] = 8'hf7; sbox[ 39] = 8'hcc;
        sbox[ 40] = 8'h34; sbox[ 41] = 8'ha5; sbox[ 42] = 8'he5; sbox[ 43] = 8'hf1;
        sbox[ 44] = 8'h71; sbox[ 45] = 8'hd8; sbox[ 46] = 8'h31; sbox[ 47] = 8'h15;

        sbox[ 48] = 8'h04; sbox[ 49] = 8'hc7; sbox[ 50] = 8'h23; sbox[ 51] = 8'hc3;//row3
        sbox[ 52] = 8'h18; sbox[ 53] = 8'h96; sbox[ 54] = 8'h05; sbox[ 55] = 8'h9a;
        sbox[ 56] = 8'h07; sbox[ 57] = 8'h12; sbox[ 58] = 8'h80; sbox[ 59] = 8'he2;
        sbox[ 60] = 8'heb; sbox[ 61] = 8'h27; sbox[ 62] = 8'hb2; sbox[ 63] = 8'h75;

        sbox[ 64] = 8'h09; sbox[ 65] = 8'h83; sbox[ 66] = 8'h2c; sbox[ 67] = 8'h1a;//row4
        sbox[ 68] = 8'h1b; sbox[ 69] = 8'h6e; sbox[ 70] = 8'h5a; sbox[ 71] = 8'ha0;
        sbox[ 72] = 8'h52; sbox[ 73] = 8'h3b; sbox[ 74] = 8'hd6; sbox[ 75] = 8'hb3;
        sbox[ 76] = 8'h29; sbox[ 77] = 8'he3; sbox[ 78] = 8'h2f; sbox[ 79] = 8'h84;

        sbox[ 80] = 8'h53; sbox[ 81] = 8'hd1; sbox[ 82] = 8'h00; sbox[ 83] = 8'hed;//row5
        sbox[ 84] = 8'h20; sbox[ 85] = 8'hfc; sbox[ 86] = 8'hb1; sbox[ 87] = 8'h5b;
        sbox[ 88] = 8'h6a; sbox[ 89] = 8'hcb; sbox[ 90] = 8'hbe; sbox[ 91] = 8'h39;
        sbox[ 92] = 8'h4a; sbox[ 93] = 8'h4c; sbox[ 94] = 8'h58; sbox[ 95] = 8'hcf;
        
        sbox[ 96] = 8'hd0; sbox[ 97] = 8'hef; sbox[ 98] = 8'haa; sbox[ 99] = 8'hfd;//row6
        sbox[100] = 8'h43; sbox[101] = 8'h4d; sbox[102] = 8'h33; sbox[103] = 8'h85;
        sbox[104] = 8'h45; sbox[105] = 8'hf9; sbox[106] = 8'h02; sbox[107] = 8'h7f;
        sbox[108] = 8'h50; sbox[109] = 8'h3c; sbox[110] = 8'h9f; sbox[111] = 8'ha8;
        
        sbox[112] = 8'h51; sbox[113] = 8'ha3; sbox[114] = 8'h40; sbox[115] = 8'h8f;//row7
        sbox[116] = 8'h92; sbox[117] = 8'h9d; sbox[118] = 8'h38; sbox[119] = 8'hf5;
        sbox[120] = 8'hbc; sbox[121] = 8'hb6; sbox[122] = 8'hda; sbox[123] = 8'h21;
        sbox[124] = 8'h10; sbox[125] = 8'hff; sbox[126] = 8'hf3; sbox[127] = 8'hd2;

        sbox[128] = 8'hcd; sbox[129] = 8'h0c; sbox[130] = 8'h13; sbox[131] = 8'hec;//row8
        sbox[132] = 8'h5f; sbox[133] = 8'h97; sbox[134] = 8'h44; sbox[135] = 8'h17;
        sbox[136] = 8'hc4; sbox[137] = 8'ha7; sbox[138] = 8'h7e; sbox[139] = 8'h3d;
        sbox[140] = 8'h64; sbox[141] = 8'h5d; sbox[142] = 8'h19; sbox[143] = 8'h73;

        sbox[144] = 8'h60; sbox[145] = 8'h81; sbox[146] = 8'h4f; sbox[147] = 8'hdc;//row9
        sbox[148] = 8'h22; sbox[149] = 8'h2a; sbox[150] = 8'h90; sbox[151] = 8'h88;
        sbox[152] = 8'h46; sbox[153] = 8'hee; sbox[154] = 8'hb8; sbox[155] = 8'h14;
        sbox[156] = 8'hde; sbox[157] = 8'h5e; sbox[158] = 8'h0b; sbox[159] = 8'hdb;
        
        sbox[160] = 8'he0; sbox[161] = 8'h32; sbox[162] = 8'h3a; sbox[163] = 8'h0a;//row10 (A)
        sbox[164] = 8'h49; sbox[165] = 8'h06; sbox[166] = 8'h24; sbox[167] = 8'h5c;
        sbox[168] = 8'hc2; sbox[169] = 8'hd3; sbox[170] = 8'hac; sbox[171] = 8'h62;
        sbox[172] = 8'h91; sbox[173] = 8'h95; sbox[174] = 8'he4; sbox[175] = 8'h79;

        sbox[176] = 8'he7; sbox[177] = 8'hc8; sbox[178] = 8'h37; sbox[179] = 8'h6d;//row11 (B)
        sbox[180] = 8'h8d; sbox[181] = 8'hd5; sbox[182] = 8'h4e; sbox[183] = 8'ha9;
        sbox[184] = 8'h6c; sbox[185] = 8'h56; sbox[186] = 8'hf4; sbox[187] = 8'hea;
        sbox[188] = 8'h65; sbox[189] = 8'h7a; sbox[190] = 8'hae; sbox[191] = 8'h08;

        sbox[192] = 8'hba; sbox[193] = 8'h78; sbox[194] = 8'h25; sbox[195] = 8'h2e;//row12 (C)
        sbox[196] = 8'h1c; sbox[197] = 8'ha6; sbox[198] = 8'hb4; sbox[199] = 8'hc6;
        sbox[200] = 8'he8; sbox[201] = 8'hdd; sbox[202] = 8'h74; sbox[203] = 8'h1f;
        sbox[204] = 8'h4b; sbox[205] = 8'hbd; sbox[206] = 8'h8b; sbox[207] = 8'h8a;

        sbox[208] = 8'h70; sbox[209] = 8'h3e; sbox[210] = 8'hb5; sbox[211] = 8'h66;//row13 (D)
        sbox[212] = 8'h48; sbox[213] = 8'h03; sbox[214] = 8'hf6; sbox[215] = 8'h0e;
        sbox[216] = 8'h61; sbox[217] = 8'h35; sbox[218] = 8'h57; sbox[219] = 8'hb9;
        sbox[220] = 8'h86; sbox[221] = 8'hc1; sbox[222] = 8'h1d; sbox[223] = 8'h9e;

        sbox[224] = 8'he1; sbox[225] = 8'hf8; sbox[226] = 8'h98; sbox[227] = 8'h11;//row14 (E)
        sbox[228] = 8'h69; sbox[229] = 8'hd9; sbox[230] = 8'h8e; sbox[231] = 8'h94;
        sbox[232] = 8'h9b; sbox[233] = 8'h1e; sbox[234] = 8'h87; sbox[235] = 8'he9;
        sbox[236] = 8'hce; sbox[237] = 8'h55; sbox[238] = 8'h28; sbox[239] = 8'hdf;
        
        sbox[240] = 8'h8c; sbox[241] = 8'ha1; sbox[242] = 8'h89; sbox[243] = 8'h0d;//row15 (F)
        sbox[244] = 8'hbf; sbox[245] = 8'he6; sbox[246] = 8'h42; sbox[247] = 8'h68;
        sbox[248] = 8'h41; sbox[249] = 8'h99; sbox[250] = 8'h2d; sbox[251] = 8'h0f;
        sbox[252] = 8'hb0; sbox[253] = 8'h54; sbox[254] = 8'hbb; sbox[255] = 8'h16;
    end

    function [7:0] SBox;
        input [7:0] byte_in;
        reg [3:0] row, col;
        begin
            row = byte_in[7:4];
            col = byte_in[3:0];
            SBox = sbox[{row, col}];
        end
    endfunction

    reg [31:0] temp;

    always @(*) begin
        for (i = 0; i < 4; i = i + 1) begin
            w[i] = key_in[(127 - i * 32) -: 32];
        end
        for (i = 4; i < 44; i = i + 1) begin
            temp = w[i-1];
            if (i % 4 == 0) begin
                temp = {temp[23:0], temp[31:24]}; 
                temp = {SBox(temp[31:24]), SBox(temp[23:16]), SBox(temp[15:8]), SBox(temp[7:0])}; 
                temp = temp ^ Rcon[(i/4)-1];
            end
            w[i] = w[i-4] ^ temp;
        end
        for (i = 0; i < 11; i = i + 1) begin
        
            round_keys[(1407 - i * 128) -: 128] = {w[i*4], w[i*4+1], w[i*4+2], w[i*4+3]};
        end
    end

endmodule
