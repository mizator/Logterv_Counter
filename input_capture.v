`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 		GA
//
// Create Date: 	19.05.2017 21:51:00
// Design Name: 	16-bit counter
// Module Name: 	input_capture
// Project Name: 	16-bit counter
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module input_capture(	
	input			i_sysclk,		// System Clock
	input			i_sysrst,		// System Reset
	
	input 			i_cap_pin,		// Input Capture Pin
	input			i_clr,			// Clear

	input			i_cnt_en,		// Count enable

	output			o_ic_flg,		// Input Capture Flag
	output 	[15:0]	o_cnt 			// Counter value
);

//---------------------------------------------
//	Input Capture
//---------------------------------------------
reg 		r_icap_0;
reg 		r_icap_1;
reg 		r_icap_2;
wire		w_cap_rise;
wire 		w_cap_fall;
always @ (posedge i_sysclk)
begin
	if (i_sysrst)
	begin
		r_icap_0 	<= 1'b0;
		r_icap_1 	<= 1'b0;
		r_icap_2 	<= 1'b0;
	end
	else
	begin
		r_icap_0 <= i_cap_pin;
		r_icap_1 <= r_icap_0;
		r_icap_2 <= r_icap_1;
	end
end
//---------------------------------------------
assign w_cap_rise = ((~r_icap_2) & r_icap_1);
//---------------------------------------------

//---------------------------------------------
//	Input Capture Counter
//---------------------------------------------
reg [15:0] r_cnt;
always @ (posedge i_sysclk)
begin
	if(i_sysrst)								// System reset
		r_cnt <= 16'h0;
	else 
	begin
		if(i_clr)								// Clear
			r_cnt <= 16'h0;
		else if(i_cnt_en)						// If counting enabled
		begin
			if (w_cap_rise)
					r_cnt <= r_cnt + 1'b1;		// Counting impulse
		end
	end
end
//---------------------------------------------

//---------------------------------------------
// Output signal generation
//---------------------------------------------
assign o_ic_flg = w_cap_rise;
assign o_cnt = r_cnt;
//---------------------------------------------
endmodule
