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
	reg 			clk;
    reg 			rst;
    reg 			r_en;
    reg				ld;
    reg 	[7:0] 	scale_data;
	wire 	[7:0] 	scale;
	wire 			sclk;
	wire			en;

// Instantiate the Unit Under Test (UUT)
prescaler uut (
	.i_sysclk(clk), 
    .i_sysrst(rst),
	.i_mod_en(en),
	.i_ld(ld),
	.i_ld_data(scale), 
	.o_sclk(sclk), 
	.o_sclk_rise(sclk_rise), 
	.o_sclk_fall(sclk_fall)
);

initial begin
	// Initialize Inputs
	clk = 1;
	r_en = 0;
    rst = 1;
    ld = 1;
    scale_data = 8'b00000011;
    #102 rst = 0; 
    #20 r_en = 1;
end

always #10 clk = ~clk;

assign scale = scale_data;
assign en = r_en;
endmodule
