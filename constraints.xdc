## Clock constraint (100MHz)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

## Reset button (active-low, R2)
set_property PACKAGE_PIN R2 [get_ports reset_n]
set_property IOSTANDARD LVCMOS33 [get_ports reset_n]
set_property PULLUP true [get_ports reset_n]

## Encryption start switch (recommend T1)
set_property PACKAGE_PIN T1 [get_ports start_encrypt]
set_property IOSTANDARD LVCMOS33 [get_ports start_encrypt]

## Decryption start switch (recommend T2)
set_property PACKAGE_PIN U1 [get_ports start_decrypt]
set_property IOSTANDARD LVCMOS33 [get_ports start_decrypt]

## 7-segment display anodes (active-low)
set_property PACKAGE_PIN W4 [get_ports {an[3]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]
set_property PACKAGE_PIN U2 [get_ports {an[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]

## 7-segment display segments (active-low, CA configuration)
## Correct segment order for Basys3:
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]  
set_property PACKAGE_PIN W6 [get_ports {seg[1]}]  
set_property PACKAGE_PIN U8 [get_ports {seg[2]}]  
set_property PACKAGE_PIN V8 [get_ports {seg[3]}] 
set_property PACKAGE_PIN U5 [get_ports {seg[4]}] 
set_property PACKAGE_PIN V5 [get_ports {seg[5]}]  
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]  
set_property IOSTANDARD LVCMOS33 [get_ports {seg[*]}]



## Optional: LED indicators for operation mode
# set_property PACKAGE_PIN U16 [get_ports encrypt_led]  # If you add status LEDs
# set_property PACKAGE_PIN E19 [get_ports decrypt_led]
# set_property IOSTANDARD LVCMOS33 [get_ports {encrypt_led decrypt_led}]
