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
	input	[15:0]	i_ld_data,	// Load data

	input			i_clr,			// Clear
	input			i_cnt_en,		// Count enable
	input			i_dir,			// Direction

	output 			o_ovf_flg,		// Overflow flag
	output 	[15:0]	o_cnt 			// Counter value
);
parameter MAX    = 4'hFFFF;
parameter BOTTOM = 4'H0000;
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
		begin
			if(i_dir == 1'b0)				// Counting downward
				r_cnt <= r_cnt - 1'b1;
			else if(i_dir == 1'b1)		// Counting upward
				r_cnt <= r_cnt + 1'b1;
		end
	end
end
//---------------------------------------------
assign o_cnt = r_cnt;
assign o_ovf_flg = (o_cnt == MAX);
//---------------------------------------------
endmodule
