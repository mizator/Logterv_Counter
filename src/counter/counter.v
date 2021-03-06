`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 		GA
//
// Create Date: 	19.05.2017 21:51:00
// Design Name: 	16-bit counter
// Module Name: 	counter
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

module counter(	
	input			i_sysclk,		// System Clock
	input			i_sysrst,		// System Reset

	input			i_ld,			// Load
	input	[15:0]	i_ld_data,		// Load data

	input			i_clr,			// Clear
	input			i_cnt_en,		// Count enable

	output 	[15:0]	o_cnt_data		// Counter value
);

//---------------------------------------------
//	Counter
//---------------------------------------------
reg [15:0] 	r_cnt;
always @ (posedge i_sysclk)
begin
	if(i_sysrst)						// System reset
		r_cnt <= 16'h0;
	else 
	begin
		if(i_ld)						// Load data
			r_cnt <= i_ld_data;
		else if(i_clr)					// Clear
			r_cnt <= 16'h0;
		else if(i_cnt_en)				// If counting enabled
			r_cnt <= r_cnt + 1'b1;
	end
end
//---------------------------------------------
assign o_cnt_data = r_cnt;
//---------------------------------------------
endmodule
