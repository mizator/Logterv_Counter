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
	reg 			r_clk;
    reg 			r_rst;
    reg			    r_cap_pin;
    reg				r_clr;
    reg 			r_en;
    wire 	[15:0] 	w_cnt;


//---------------------------------------------
// Instantiate the Unit Under Test (UUT)
//---------------------------------------------
input_capture uut (
	.i_sysclk(r_clk),		
	.i_sysrst(r_rst),		
	.i_cap_pin(r_cap_pin),					
	.i_clr(r_clr),		
	.i_cnt_en(r_en),			
	.o_ic_flg(ic_flg),
	.o_cnt_data(w_cnt)
);
//---------------------------------------------


//---------------------------------------------
initial begin
	// Initialize Inputs
	r_clk = 1;
    r_rst = 1;
    r_clr = 0;
	r_en  = 0;
    r_cap_pin = 0;
    
    #60 r_rst = 0; 
    #20 r_en  = 1;
    #40 r_clr = 1;
    #10 r_clr = 0;
    #50 r_en  = 0;
    #40 r_clr = 1;
    #10 r_clr = 0;
    #50 r_en  = 1;
end
//---------------------------------------------


//---------------------------------------------
// Generate Clock
//---------------------------------------------
always #5 r_clk = ~r_clk;
//---------------------------------------------


//---------------------------------------------
// Generate Input Event
//---------------------------------------------
always 
begin
    #21 r_cap_pin = 1;
    #3  r_cap_pin = 0;  
end
//---------------------------------------------
endmodule
