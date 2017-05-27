`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 		GA
// 
// Create Date:    	10:00:00 05/22/2017 
// Design Name: 	16-bit counter
// Module Name:    	prescaler_tb
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
module prescaler_tb;
    // Inputs
	reg 			r_clk;
    reg 			r_rst;
    reg 			r_en;
    reg				r_ld;
    reg 	[7:0] 	r_scale_data;


//---------------------------------------------
// Instantiate the Unit Under Test (UUT)
//---------------------------------------------
prescaler uut (
	.i_sysclk(r_clk), 
    .i_sysrst(r_rst),
	.i_module_en(r_en),
	.i_ld(r_ld),
	.i_ld_data(r_scale_data), 
	.o_sclk(sclk), 
	.o_sclk_rise(sclk_rise), 
	.o_sclk_fall(sclk_fall)
);
//---------------------------------------------


//---------------------------------------------
initial begin
	// Initialize Inputs
	r_clk = 1;
	r_en  = 0;
    r_rst = 1;
    r_ld  = 0;
    r_scale_data = 8'b0000_0000;
    #60 r_rst = 0;
    #20 r_en  = 1;
    #60;
    #10 r_scale_data = 8'b0000_0111;     
    #10 r_ld  = 1;
    #10 r_ld  = 0;
end
//---------------------------------------------


//---------------------------------------------
// Generate Clock
//---------------------------------------------
always #5 r_clk = ~r_clk;
//---------------------------------------------
endmodule
