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
	reg 			clk;
    reg 			rst;

	wire			en;
    reg 			r_en;

    reg				cnt_ld;
    reg				cnt_dir;
    reg				cnt_clr;

    reg 	[15:0] 	cnt_ld_data;
	wire	[15:0] 	count;
	wire 			cnt_ovf_flg;



//---------------------------------------------
// Instantiate the Unit Under Test (UUT)
//---------------------------------------------
counter uut(	
	.i_sysclk(clk),				
	.i_sysrst(rst),				
	.i_cnt_en(en),				 		
	.i_ld(cnt_ld),					
	.i_dir(cnt_dir),				
	.i_clr(cnt_clr),				
	.i_ld_data(cnt_ld_data),		
	.o_ovf_flg(cnt_ovf_flg),		
	.o_cnt(count)				
);
//---------------------------------------------

initial begin
	// Initialize Inputs
	clk = 1;
	r_en = 0;
    rst = 1;
    cnt_dir = 1;
    cnt_clr = 0;
    cnt_ld = 0;
    cnt_ld_data = 16'h0000;
    #100 rst = 0; 
    cnt_ld_data = 16'b0000_0000_0000_1111;
    cnt_ld = 1;
    #10 cnt_ld = 0;
    cnt_ld_data = 16'b1111_0101_0110_1001;
    cnt_ld = 1;
    #10 cnt_ld = 0;
    cnt_clr= 1;
    #40 cnt_clr= 0;
    cnt_ld_data = 16'b1111_1111_1111_0000;
    cnt_ld = 1;
    #10 cnt_ld = 0;
    #20 r_en = 1;
    #500 cnt_dir = 0;
end

always #10 clk = ~clk;

assign en 	 = r_en;
endmodule
