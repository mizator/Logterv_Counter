`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 		GA
// 
// Create Date:    	10:00:00 05/22/2017 
// Design Name: 	16-bit counter
// Module Name:    	counter_tb
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
module counter_tb;
    // Inputs
	reg 			r_clk;
    reg 			r_rst;
    reg 			r_cnt_en;
    reg				r_cnt_ld;
    reg				r_cnt_dir;
    reg				r_cnt_clr;
    reg 	[15:0] 	r_cnt_ld_data;
	wire	[15:0] 	cnt_data;



//---------------------------------------------
// Instantiate the Unit Under Test (UUT)
//---------------------------------------------
counter uut(	
	.i_sysclk(r_clk),				
	.i_sysrst(r_rst),				
	.i_cnt_en(r_cnt_en),				 		
	.i_ld(r_cnt_ld),					
	.i_dir(r_cnt_dir),				
	.i_clr(r_cnt_clr),				
	.i_ld_data(r_cnt_ld_data),				
	.o_cnt_data(cnt_data)				
);
//---------------------------------------------


//---------------------------------------------
initial begin
	// Initialize Inputs
	r_clk = 1;
    r_rst = 1;
    r_cnt_en = 0;
    r_cnt_dir = 1;
    r_cnt_clr = 0;
    r_cnt_ld = 0;
    r_cnt_ld_data = 16'h0000;
    #100 r_rst = 0; 
    #10 r_cnt_ld_data = 16'b0000_0000_0000_1111;
    #10 r_cnt_ld = 1;
    #10 r_cnt_ld = 0;
    #10 r_cnt_ld_data = 16'b1111_0101_0110_1001;
    #10 r_cnt_ld = 1;
    #10 r_cnt_ld = 0;
        r_cnt_clr= 1;
    #10 r_cnt_clr= 0;
    #10 r_cnt_ld_data = 16'b1111_1111_1111_0000;
    #10 r_cnt_ld = 1;
    #10 r_cnt_ld = 0;
    #20 r_cnt_en = 1;
    #500 r_cnt_dir = 0;
end
//---------------------------------------------


//---------------------------------------------
// Generate clock
//---------------------------------------------
always #5 r_clk = ~r_clk;
//---------------------------------------------

endmodule
