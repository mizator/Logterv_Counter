`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 		GA
//
// Create Date: 	19.05.2017 21:51:00
// Design Name: 	16-bit counter
// Module Name: 	counter_if
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
/////////////////////////////////////////////////////////////////

module counter_if(	
	input			i_sysclk,		// System Clock
	input			i_sysrst,		// System Reset
	input 			i_module_en,	// Module enable

	input 			i_cap_pin,		// Input Capture Pin
	output 			o_out_pin,		// Output Capture Pin
	output 			o_int_flg,		// Interrupt flag

	input 			i_bus_select,	// Select Periphery
	input 			i_bus_wr,		// Bus Write
	input 	[3:0]	i_reg_addr,		// Register Address
	input 	[15:0]	i_bus_data,		// Data input
	output 	[15:0]	o_bus_data,		// Data output
	output 			o_bus_ack		// Bus Acknowledge
);

//---------------------------------------------
// Inner Signals
//---------------------------------------------
wire 		prs_en;
wire 		prs_ld;
wire [7:0]	prs_ld_data;
wire 		prs_sclk;
wire 		prs_sclk_rise;
wire 		prs_sclk_fall;
//---------------------------------------------
wire 		cnt_en;
wire 		cnt_ld;
wire 		cnt_dir;
wire 		cnt_clr;
wire [15:0] cnt_ld_data;
wire 		cnt_ovf_flg;
wire [15:0] cnt_data;
//---------------------------------------------
wire 		cap_en;
wire 		cap_clr;
wire 		cap_ic_flg;
wire [15:0] cap_cnt_data;
//---------------------------------------------


//---------------------------------------------
// Instantiate Control Logic
//---------------------------------------------
control_logic control_logic(
	.i_sysclk(i_sysclk), 			
    .i_sysrst(i_sysrst),			
	.i_module_en(i_module_en),
	.o_int_flg(o_int_flg),
	.o_out_pin(o_out_pin),

	.i_bus_select(i_bus_select),
	.i_bus_wr(i_bus_wr),
	.i_reg_addr(i_reg_addr),
	.i_bus_data(i_bus_data),
	.o_bus_data(o_bus_data),
	.o_bus_ack(o_bus_ack),

	.o_prs_en(prs_en),
	.o_prs_ld(prs_ld),
	.o_prs_ld_data(prs_ld_data),
	.i_prs_sclk(prs_sclk),
	.i_prs_sclk_rise(prs_sclk_rise),
	.i_prs_sclk_fall(prs_sclk_fall),

	.o_cnt_en(cnt_en),
	.o_cnt_ld(cnt_ld),
	.o_cnt_dir(cnt_dir),
	.o_cnt_clr(cnt_clr),
	.o_cnt_ld_data(cnt_ld_data),
	.i_cnt_ovf_flg(cnt_ovf_flg),
	.i_cnt_data(cnt_data),

	.o_cap_en(cap_en),
	.o_cap_clr(cap_clr),
	.i_cap_ic_flg(cap_ic_flg),
	.i_cap_cnt_data(cap_cnt_data)
);
//---------------------------------------------


//---------------------------------------------
// Instantiate Prescaler
//---------------------------------------------
prescaler prescaler(
	.i_sysclk(i_sysclk), 			
    .i_sysrst(i_sysrst),			
	.i_module_en(prs_en),				
	.i_ld(prs_ld),					
	.i_ld_data(prs_ld_data), 		
	.o_sclk(prs_sclk), 				
	.o_sclk_rise(prs_sclk_rise), 	
	.o_sclk_fall(prs_sclk_fall)		
);
//---------------------------------------------


//---------------------------------------------
// Instantiate Counter
//---------------------------------------------
counter counter(	
	.i_sysclk(i_sysclk),			
	.i_sysrst(i_sysrst),			
	.i_cnt_en(cnt_en),						
	.i_ld(cnt_ld),					
	.i_dir(cnt_dir),				
	.i_clr(cnt_clr),				
	.i_ld_data(cnt_ld_data),		
	.o_ovf_flg(cnt_ovf_flg),		
	.o_cnt(cnt_data)				
);
//---------------------------------------------


//---------------------------------------------
// Instantiate Input Capture
//---------------------------------------------
input_capture input_capture(
	.i_sysclk(i_sysclk),			
	.i_sysrst(i_sysrst),			
	.i_cap_pin(i_cap_pin),					
	.i_clr(cap_clr),				
	.i_cnt_en(cap_en),					
	.o_ic_flg(cap_ic_flg),			
	.o_cnt_data(cap_cnt_data)			
);
//---------------------------------------------


//---------------------------------------------
endmodule
