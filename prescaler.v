`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 		GA
// 
// Create Date:     10:00:00 05/22/2017 
// Design Name: 	16-bit counter
// Module Name:     prescaler 
// Project Name: 	16-bit counter
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module prescaler(
	input 			i_sysclk, 		// System clock
	input 			i_sysrst, 		// System reset
	input 			i_mod_en, 		// Module enable
	input			i_ld, 			// Load divider value
	input 	[7:0] 	i_ld_data, 		// Divider value
	output 			o_sclk, 		// Sck output
	output 			o_sclk_rise, 	// Sck rising edge
	output 			o_sclk_fall 	// Sck falling edge
);
//---------------------------------------------
// Divider value load
//---------------------------------------------
reg [7:0] r_div_value;
always @(posedge i_sysclk) 
begin
	if (i_sysrst) begin
		r_div_value <= 8'b0;
	end
	else if (i_ld) begin
		r_div_value <= i_ld_data;
	end
end
//---------------------------------------------

//---------------------------------------------
// Counter
//---------------------------------------------
reg [7:0] r_cntr;
always @ (posedge i_sysclk)
begin
	if (i_sysrst)
		r_cntr <= 8'b0;
	else if(i_mod_en) begin
		if(r_cntr == r_div_value)		
			r_cntr <= 8'b0;
		else	
			r_cntr <= r_cntr + 1'b1;
	end
end
//---------------------------------------------

//---------------------------------------------
// Sck register
//---------------------------------------------
reg r_sclk;
always @ (posedge i_sysclk)
begin
	if (i_sysrst)
		r_sclk <= 1'b0;
	else if(~i_mod_en)
		r_sclk <= 1'b0;
	else if(r_cntr == r_div_value)
		r_sclk <= ~r_sclk;
end
//---------------------------------------------

//---------------------------------------------
// Output signal generation		
//---------------------------------------------
assign o_sclk 	   = ( r_sclk  &   i_mod_en);  				
assign o_sclk_rise = (~r_sclk) & (r_cntr == r_div_value) & (i_mod_en);
assign o_sclk_fall = ( r_sclk) & (r_cntr == r_div_value) & (i_mod_en);
//---------------------------------------------
endmodule
