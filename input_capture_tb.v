`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 		GA
// 
// Create Date:    	10:00:00 05/22/2017 
// Design Name: 	16-bit counter
// Module Name:    	input_capture_tb
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
module input_capture_tb;
// Inputs
	reg 			clk;
    reg 			rst;

    reg			cap_pin;
    reg				clr;

    reg 			r_en;
    wire			en;

    wire			ic_flg;
    wire 	[15:0] 	w_cnt;



// Instantiate the Unit Under Test (UUT)
input_capture uut (
	.i_sysclk(clk),		
	.i_sysrst(rst),		
	.i_capture(cap_pin),					
	.i_clr(clr),		
	.i_cnt_en(en),			
	.o_ic_flg(ic_flg),
	.o_cnt(w_cnt)
);

initial begin
	// Initialize Inputs
	clk = 1;
    rst = 1;
    clr = 0;
	r_en = 0;
    cap_pin = 0;
    
    #102 rst = 0; 
    #20 r_en = 1;
end

always #10 clk = ~clk;
always #60 cap_pin = ~cap_pin;

assign en = r_en;
endmodule
