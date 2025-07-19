module AES_Display_Top (
    input wire clk,            // 100MHz clock
    input wire reset_n,        // Active-low reset
    input wire start_encrypt,  // Slider switch for encryption
    input wire start_decrypt,  // Slider switch for decryption
    output reg [6:0] seg,      // 7-segment segments (a-g)
    output reg [3:0] an        // 7-segment anodes (W4=an[3], U2=an[0])
);

    // Embedded data
    localparam [127:0] EMBEDDED_PLAINTEXT = 128'h00112233445566778899aabbccddeeff;
    reg [127:0] EMBEDDED_CIPHERTEXT;
    reg [127:0] REGENERATED_PLAINTEXT;
    
    // AES Interface
    wire [127:0] encrypt_out, decrypt_out;
    wire done_encr, done_decr;
    reg encrypt_start, decrypt_start;
    
    // Display Control
    reg [31:0] delay_counter;
    reg [3:0] display_state;
    reg [1:0] display_mode;  // 00: plaintext, 01: ciphertext, 10: regenerated plaintext
    reg [127:0] display_data;
    localparam DISPLAY_DELAY = 200_000_000; // 2 seconds @ 100MHz
    
    // Multiplexing Control
    reg [19:0] refresh_counter;
    wire [1:0] led_sel;
    wire [3:0] digit_data;
    wire [15:0] current_group;
    reg show_dash;  // Flag to control dash display
    
    // AES Modules
    AES_Encrypt encryptor (
        .start(encrypt_start),
        .in(EMBEDDED_PLAINTEXT),
        .out(encrypt_out),
        .done_encr(done_encr)
    );
    
    AES_Decrypt decryptor (
        .start(decrypt_start),
        .in(EMBEDDED_CIPHERTEXT),
        .out(decrypt_out),
        .done_decr(done_decr)
    );
    
    // Hex to 7-segment decoder (active-low)
    function [6:0] hex_to_seg;
        input [3:0] hex;
        begin
            case(hex)
                4'h0: hex_to_seg = 7'b0111111; // 0
                4'h1: hex_to_seg = 7'b0000110; // 1
                4'h2: hex_to_seg = 7'b1011011; // 2
                4'h3: hex_to_seg = 7'b1001111; // 3
                4'h4: hex_to_seg = 7'b1100110; // 4
                4'h5: hex_to_seg = 7'b1101101; // 5
                4'h6: hex_to_seg = 7'b1111101; // 6
                4'h7: hex_to_seg = 7'b0000111; // 7
                4'h8: hex_to_seg = 7'b1111111; // 8
                4'h9: hex_to_seg = 7'b1101111; // 9
                4'hA: hex_to_seg = 7'b1110111; // A
                4'hB: hex_to_seg = 7'b1111100; // B
                4'hC: hex_to_seg = 7'b0111001; // C
                4'hD: hex_to_seg = 7'b1011110; // D
                4'hE: hex_to_seg = 7'b1111001; // E
                4'hF: hex_to_seg = 7'b1110001; // F
                default: hex_to_seg = 7'b0111111; // -
            endcase
        end
    endfunction
    
    // Select current display group (corrected order)
      assign current_group = 
        (display_state[2:0] == 0) ? display_data[127:112] :
        (display_state[2:0] == 1) ? display_data[111:96]  :
        (display_state[2:0] == 2) ? display_data[95:80]   :
        (display_state[2:0] == 3) ? display_data[79:64]   :
        (display_state[2:0] == 4) ? display_data[63:48]   :
        (display_state[2:0] == 5) ? display_data[47:32]   :
        (display_state[2:0] == 6) ? display_data[31:16]   :
        (display_state[2:0] == 7) ? display_data[15:0]    :
        16'hFFFF;  // Default to dashes if invalid state

    
    assign led_sel = refresh_counter[19:18];
    assign digit_data = show_dash ? 4'hF :  // Show dash when flag is set
                      (led_sel == 0) ? current_group[15:12] :
                      (led_sel == 1) ? current_group[11:8] :
                      (led_sel == 2) ? current_group[7:4] :
                      current_group[3:0];
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Reset all registers
            display_mode <= 2'b00;
            display_data <= EMBEDDED_PLAINTEXT;
            EMBEDDED_CIPHERTEXT <= 0;
            REGENERATED_PLAINTEXT <= 0;
            encrypt_start <= 0;
            decrypt_start <= 0;
            display_state <= 0;
            delay_counter <= 0;
            refresh_counter <= 0;
            show_dash <= 0;
        end else begin
            // Encryption control
            if (start_encrypt && !start_decrypt && !encrypt_start && !decrypt_start && !done_encr) begin
                encrypt_start <= 1;
                display_mode <= 2'b00;
            end 
            else if (done_encr) begin
                encrypt_start <= 0;
                EMBEDDED_CIPHERTEXT <= encrypt_out;
                display_mode <= 2'b01;
            end
            
            // Decryption control
            if (start_decrypt && !start_encrypt && !decrypt_start && !encrypt_start && !done_decr) begin
                decrypt_start <= 1;
                display_mode <= 2'b01;
            end
            else if (done_decr) begin
                decrypt_start <= 0;
                REGENERATED_PLAINTEXT <= decrypt_out;
                display_mode <= 2'b10;
            end
            
            // Update display data based on mode
            case (display_mode)
                2'b00: display_data <= EMBEDDED_PLAINTEXT;
                2'b01: display_data <= EMBEDDED_CIPHERTEXT;
                2'b10: display_data <= REGENERATED_PLAINTEXT;
                default: display_data <= EMBEDDED_PLAINTEXT;
            endcase
            
            // Display multiplexing
            refresh_counter <= refresh_counter + 1;
            case(led_sel)
                0: begin an <= 4'b0111; seg <= ~hex_to_seg(digit_data); end
                1: begin an <= 4'b1011; seg <= ~hex_to_seg(digit_data); end
                2: begin an <= 4'b1101; seg <= ~hex_to_seg(digit_data); end
                3: begin an <= 4'b1110; seg <= ~hex_to_seg(digit_data); end
            endcase
            
            // State machine with dash display after final state
            if (delay_counter >= DISPLAY_DELAY) begin
                delay_counter <= 0;
                
                if (display_state == 7) begin
                    show_dash <= 1;  // Show dashes after last data group
                    display_state <= display_state + 1;
                end
                else if (display_state == 8) begin
                    show_dash <= 0;  // Return to normal display
                    display_state <= 0;
                end
                else begin
                    display_state <= display_state + 1;
                end
            end else begin
                delay_counter <= delay_counter + 1;
            end
        end
    end
endmodule
