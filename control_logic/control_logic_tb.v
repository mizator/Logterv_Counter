`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 		GA
// 
// Create Date:    	10:00:00 05/22/2017 
// Design Name: 	16-bit counter
// Module Name:    	control_logic_tb
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
module control_logic_tb;
// Inputs
	reg 			r_clk;
    reg 			r_rst;

	wire 			int_flg;
	wire 			cout_pin;
	reg 			r_cap_pin;

	reg 			r_bus_select;
	reg 			r_bus_wr;
	reg		[3:0]	r_reg_addr;
	reg		[15:0]	r_i_bus_data;
	wire	[15:0]	o_bus_data;
	wire 			bus_ack;

//	wire 			w_prs_en;
//	wire 			w_prs_ld;
	wire 	[7:0] 	prs_ld_data;
//	reg 			r_prs_sclk;
//	reg 			r_prs_sclk_rise;
//	reg 			r_prs_sclk_fall;

//	wire 			w_cnt_en;
//	wire 			w_cnt_ld;
//	wire 			w_cnt_dir;
//	wire 			w_cnt_clr;
	wire 	[15:0]	cnt_ld_data;
	wire 	[15:0]	cnt_data;

//	wire 			w_cap_en;
//	wire 			w_cap_clr;
//	reg 			r_cap_ic_flg;
//	reg 	[15:0] 	r_cap_cnt_data;
	wire 	[15:0] 	cap_cnt_data;


parameter   ADDR_TCCR  = 4'b0001;
parameter   ADDR_TCCR2 = 4'b0010;
parameter   ADDR_TCNT  = 4'b0011;
parameter   ADDR_OCR   = 4'b0100;
parameter   ADDR_ICR   = 4'b0101;
parameter   ADDR_TCST  = 4'b0110;


//---------------------------------------------
// Instantiate the Unit Under Test (UUT)
//---------------------------------------------
control_logic uut(	
	.i_sysclk(r_clk),					// System Clock
	.i_sysrst(r_rst),					// System Reset

	.o_int_flg(int_flg),				// Input Capture Pin
	.o_out_pin(cout_pin),				// Output Capture Pin

	.i_bus_select(r_bus_select),		// Select Periphery
	.i_bus_wr(r_bus_wr),				// Bus Write
	.i_reg_addr(r_reg_addr),			// Register Address
	.i_bus_data(r_i_bus_data),			// Data Input
	.o_bus_data(o_bus_data),			// Data Output
	.o_bus_ack(bus_ack),				// Bus Acknowledge

	.o_prs_en(prs_en),					// Prescaler Enable
	.o_prs_ld(prs_ld),					// Prescaler Load
	.o_prs_ld_data(prs_ld_data),		// Prescaler Load Data
	.i_prs_sclk(prs_sclk),				// Prescaler Clock
	.i_prs_sclk_rise(prs_sclk_rise),	// Prescaler CLock Rising  Edge
	.i_prs_sclk_fall(prs_sclk_fall),	// Prescaler Clock Falling Edge

	.o_cnt_en(cnt_en),					// Counting Enable
	.o_cnt_ld(cnt_ld),					// Counter  Load
	.o_cnt_dir(cnt_dir),				// Counting Direction
	.o_cnt_clr(cnt_clr),				// Counter  Clear
	.o_cnt_ld_data(cnt_ld_data),		// Counter  Load Data
	.i_cnt_data(cnt_data),				// Counter 	Data

	.o_cap_en(cap_en),					// Input Capture Enable
	.o_cap_clr(cap_clr),				// Input Capture Clear
	.i_cap_ic_flg(cap_ic_flg),			// Input Capture Flag
	.i_cap_cnt_data(cap_cnt_data)		// Input Capture Data
);
//-----------------------------------------------


//---------------------------------------------
// Instantiate Prescaler
//---------------------------------------------
prescaler prescaler(
	.i_sysclk(r_clk), 			
    .i_sysrst(r_rst),			
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
	.i_sysclk(r_clk),				
	.i_sysrst(r_rst),				
	.i_cnt_en(cnt_en),				 		
	.i_ld(cnt_ld),					
	.i_dir(cnt_dir),				
	.i_clr(cnt_clr),				
	.i_ld_data(cnt_ld_data),				
	.o_cnt_data(cnt_data)				
);
//---------------------------------------------


//---------------------------------------------
// Instantiate Input Capture
//---------------------------------------------
input_capture input_capture (
	.i_sysclk(r_clk),		
	.i_sysrst(r_rst),		
	.i_cap_pin(r_cap_pin),					
	.i_clr(cap_clr),		
	.i_cnt_en(cap_en),			
	.o_ic_flg(cap_ic_flg),
	.o_cnt_data(cap_cnt_data)
);
//---------------------------------------------


//-----------------------------------------------
// Bus Write
//-----------------------------------------------
task bus_write (input [3:0] reg_addr, input [15:0] bus_data);
begin
	#10 r_reg_addr 		<= reg_addr;	// Select Register
		r_i_bus_data 	<= bus_data;	// Write data to bus
		r_bus_wr 		<= 1'b1;		// Write Select 
		r_bus_select 	<= 1'b1;		// Select Target
	wait(bus_ack);						// Wait For ACK
	#10 r_bus_wr 		<= 1'b0;		// Release Write
		r_bus_select 	<= 1'b0;		// Release Target
end
endtask
//-----------------------------------------------


//-----------------------------------------------
// Bus Read
//-----------------------------------------------
task bus_read (input [3:0] reg_addr);
begin
	#10 r_reg_addr 		<= reg_addr;	// Select Register
		r_bus_wr 		<= 1'b0;		// Read Select
		r_bus_select 	<= 1'b1;		// Select Target
	wait(bus_ack);						// Wait For ACK
	#10 r_bus_wr 		<= 1'b0;		// Release Write
		r_bus_select 	<= 1'b0;		// Release Target
end
endtask
//---------------------------------------------


initial begin
	// Initialize Inputs
	r_clk = 1;
    r_rst = 1;
	r_cap_pin = 0;
	r_bus_select = 0;
	r_bus_wr = 0;
	r_reg_addr = 4'b0;
	r_i_bus_data = 16'b0;
	
//	r_prs_sclk = 0;
//	r_prs_sclk_rise = 0;
//	r_prs_sclk_fall = 0;
//	r_cnt_data = 16'b0;	
//	r_cap_ic_flg = 0;
//	r_cap_cnt_data = 0;

    #60 r_rst = 0; 
    bus_write(ADDR_TCCR , 16'b0000_0000_0111_1111);		// All interrupts enabled
    bus_write(ADDR_TCCR2, 16'b0000_0000_0000_1111);		// TOP = 0xFF, Prescale 0x0F;
 //   bus_write(ADDR_TCNT , 16'b0000_0000_0000_0111);
    bus_write(ADDR_OCR  , 16'b0000_1111_0000_1111);
 //   bus_write(ADDR_ICR  , 16'b0000_0000_0001_1111);
 //   bus_write(ADDR_TCST , 16'b0000_0000_0011_1111);
    #30;
    bus_read (ADDR_TCCR );
    bus_read (ADDR_TCCR2);
//    bus_read (ADDR_TCNT);
    bus_read (ADDR_OCR );
//    bus_read (ADDR_ICR);
//    bus_read (ADDR_TCST);
end



//---------------------------------------------
// Generate Input Event
//---------------------------------------------
always 
begin
    #21 r_cap_pin = 1;
    #3  r_cap_pin = 0;  
end
//---------------------------------------------

//---------------------------------------------
// Generate clock
//---------------------------------------------
always #5 r_clk = ~r_clk;
//---------------------------------------------
endmodule
