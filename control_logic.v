`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 		GA
// 
// Create Date:     10:00:00 05/22/2017 
// Design Name: 	16-bit counter
// Module Name:     control_logic 
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
module control_logic(
	input 			i_sysclk, 			// System clock
	input 			i_sysrst, 			// System reset
	input			i_module_en,		// Module enable


	output 			o_int_flg,			// Interrupt Flag
	output 			o_out_pin,			// Output Pin

	input 			i_bus_select,		// Select Periphery
	input 			i_bus_wr,			// Bus Write
	input 	[3:0]	i_reg_addr,			// Register Address
	input 	[15:0]	i_bus_data,			// Data Input
	output 	[15:0]	o_bus_data,			// Data Output
	output 			o_bus_ack,			// Bus Acknowledge


	output 			o_prs_en,			// Prescaler Enable
	output			o_prs_ld,			// Prescaler Load
	output	[7:0]	o_prs_ld_data,		// Prescaler Load Data
	input			i_prs_sclk,			// Prescaler Clock 
	input			i_prs_sclk_rise,	// Prescaler CLock Rising  Edge
	input			i_prs_sclk_fall,	// Prescaler Clock Falling Edge


	output 			o_cnt_en,			// Counting Enable
	output			o_cnt_ld,			// Counter  Load
	output 			o_cnt_dir, 			// Counting Direction
	output 			o_cnt_clr,			// Counter  Clear
	output 	[15:0]	o_cnt_ld_data,		// Counter  Load Data
	input 			i_cnt_ovf_flg,		// Counter  Overflow Flag
	input 	[15:0]	i_cnt_data,			// Counter 	Data


	output			o_cap_en,			// Input Capture Enable
	output			o_cap_clr,			// Input Capture Clear
	input 			i_cap_ic_flg,			// Input Capture Flag
	input 	[15:0]	i_cap_cnt_data		// Input Capture Data

);

//---------------------------------------------
// Register Map
//---------------------------------------------
// Timer Counter Control Register
reg 	[15:0] 	TCCR;
parameter		ADDR_TCCR 	= 4'b0001;			
//TCCR[0]		Global enable
//TCCR[1]		Normal / Compare  	mode
//TCCR[2]		Single / Periodic 	mode
//TCCR[3]		Fast PWM 			mode
//TCCR[4]		Global   		Interrupt Enable
//TCCR[5]		Overflow 		Interrupt Enable
//TCCR[6]		Output Captuer 	Interrupt Enable
//TCCR[7]		Input Capture 	Interrupt Enable
//TCCR[15:8] 	Prescale value
//---------------------------------------------
// Timer Counter Command Register 2
reg 	[15:0] 	TCCR2;
parameter		ADDR_TCCR2 	= 4'b0010;
//TCCR2[0]		// Counter Enable
//TCCR2[1]		// Counter direction
//TCCR2[2]		// Input Capture Enable
//---------------------------------------------
// Timer-Counter Register, current counter value
reg 	[15:0] 	TCNT;
parameter		ADDR_TCNT 	= 4'b0011;	
//---------------------------------------------
// Output Compare Register, compared value	
reg 	[15:0] 	OCR;
parameter		ADDR_OCR 	= 4'b0100;
//---------------------------------------------
// Input  Capture Register, Input signals
reg 	[15:0] 	ICR;
parameter		ADDR_ICR 	= 4'b0101;		
//---------------------------------------------
// Timer Counter Status Register
reg 	[15:0] 	TCST;
parameter		ADDR_TCST 	= 4'b0110;
//TCST[0]	Overflow Interrupt
//TCST[1]	Output Capture Interrupt
//TCST[2]	Input Capture Interrupt	
//---------------------------------------------
parameter MAX    = 16'hFFFF;
parameter BOTTOM = 16'H0000;
//---------------------------------------------

//---------------------------------------------
// Bus Read-Write
//---------------------------------------------
reg [15:0] 	r_obus_data;
reg [15:0] 	r_ibus_data;
reg [ 3:0] 	r_ibus_addr;
reg 		r_ack;
//---------------------------------------------
always @ (posedge i_sysclk)
begin
	if (i_sysrst)
	begin
		r_obus_data <= 16'b0;
		r_ibus_data <= 16'b0;
	end
	else begin
		if (i_bus_select == 1'b1) begin
			if(~i_bus_wr)begin 
				case (i_reg_addr)
		  			ADDR_TCCR  : r_obus_data <= TCCR;
		  			ADDR_TCCR2 : r_obus_data <= TCCR2;
		  			ADDR_TCNT  : r_obus_data <= TCNT;
		  			ADDR_OCR   : r_obus_data <= OCR;
		  			ADDR_ICR   : r_obus_data <= ICR;
		  			ADDR_TCST  : r_obus_data <= TCST;
		  			default    : r_obus_data <= 16'b0;
				endcase
			end
			else if(i_bus_wr) begin
				r_ibus_data <= i_bus_data;
				case (i_reg_addr)
		  			ADDR_TCCR  : r_ibus_addr <= ADDR_TCCR;
		  			ADDR_TCCR2 : r_ibus_addr <= ADDR_TCCR2;
		  			ADDR_TCNT  : r_ibus_addr <= ADDR_TCNT;
		  			ADDR_OCR   : r_ibus_addr <= ADDR_OCR;
		  			ADDR_ICR   : r_ibus_addr <= ADDR_ICR;
		  			ADDR_TCST  : r_ibus_addr <= ADDR_TCST;
		  			default    : r_ibus_addr <= 16'b0;
				endcase
			end
			r_ack <= 1'b1;
		end
		else r_ack <= 1'b0;
	end
end
//---------------------------------------------
// Acknowledge Generation
//---------------------------------------------
assign o_bus_data = (i_bus_select & ~(i_bus_wr)) ? r_obus_data : 16'b0;
assign o_bus_ack  =  r_ack;
//---------------------------------------------


//---------------------------------------------
// TCCR Register Write
//---------------------------------------------
always @(posedge i_sysclk) 
begin
	if (i_sysrst) 
		TCCR <= 16'b0;
	else if(r_ibus_addr == ADDR_TCCR)
		TCCR <= r_ibus_data;
end
//---------------------------------------------


//---------------------------------------------
// TCCR2 Register Write
//---------------------------------------------
always @(posedge i_sysclk) 
begin
	if (i_sysrst) 
		TCCR2 <= 16'b0;
	else if(r_ibus_addr == ADDR_TCCR2)
		TCCR2 <= r_ibus_data;
end
//---------------------------------------------


//---------------------------------------------
// TCNT Register Write
//---------------------------------------------
always @(posedge i_sysclk) 
begin
	if (i_sysrst) 
		TCNT <= 16'b0;
	else if(r_ibus_addr == ADDR_TCNT)
		TCNT <= r_ibus_data;
	else
		TCNT <= i_cnt_data;
end
//---------------------------------------------


//---------------------------------------------
// OCR Register Write
//---------------------------------------------
always @(posedge i_sysclk) 
begin
	if (i_sysrst) 
		OCR <= 16'b0;
	else if(r_ibus_addr == ADDR_OCR)
		OCR <= r_ibus_data;
end
//---------------------------------------------


//---------------------------------------------
// ICR Write
//---------------------------------------------
always @(posedge i_sysclk) 
begin
	if (i_sysrst) 
		ICR <= 16'b0;
	else
		ICR <= i_cap_cnt_data;
end
//---------------------------------------------


//---------------------------------------------
// TCST Register Write
//---------------------------------------------
always @(posedge i_sysclk) 
begin
	if (i_sysrst) 
		TCST <= 16'b0;
	else if(r_ibus_addr == ADDR_TCST)begin
		TCST <= r_ibus_data;
	end
	else begin 			//Concatenate TCST new value from the interrupt flags
		TCST <= {13'b0  ,(w_ic_flg)  ? 1'b1 : TCST[2],
						 (w_ocm_flg) ? 1'b1 : TCST[1],
						 (w_ovf_flg) ? 1'b1 : TCST[0]};
	end
end
//---------------------------------------------


//---------------------------------------------
// Interrupt Generation
//---------------------------------------------
reg  r_ovf_flg;		
reg  r_ocm_flg;
reg  r_ic_flg;
wire w_ovf_flg;
wire w_ocm_flg;
wire w_ic_flg;
//---------------------------------------------
always @(posedge i_sysclk) 
begin
	if (i_sysrst) 
	begin
		r_ovf_flg <= 1'b0;
		r_ocm_flg <= 1'b0;
		r_ic_flg  <= 1'b0;
	end
	else if (TCCR[4]) begin
		 	r_ovf_flg <= (TCCR[5] & i_cnt_ovf_flg) ? 1'b1 : 1'b0;
		 	//r_ocm_flg <= (TCCR[6] &   cap_ocm_flg) ? 1'b1 : 1'b0;
		 	r_ic_flg  <= (TCCR[7] & i_cap_ic_flg)  ? 1'b1 : 1'b0;
	end
end
//---------------------------------------------
assign w_ovf_flg = r_ovf_flg;
assign w_ocm_flg = r_ocm_flg;
assign w_ic_flg  =  r_ic_flg;
//---------------------------------------------
assign  o_int_flg = (TCST[2:0] != 3'b000);
//---------------------------------------------


//---------------------------------------------
// Prescaler Control Signals
//---------------------------------------------
assign o_prs_ld_data = TCCR[15:8];
assign o_prs_ld = (r_ibus_addr == ADDR_TCCR);
assign o_prs_en = (TCCR[0]);
//---------------------------------------------


//---------------------------------------------
// Input Capture Control Signals
//---------------------------------------------
assign o_cap_clr = (~(TCCR2[2]));
assign o_cap_en  =   (TCCR2[2]);
//---------------------------------------------


//---------------------------------------------
// Counter Control Signals
//---------------------------------------------
assign o_cnt_ld_data = TCNT;
assign o_cnt_ld  = (r_ibus_addr == ADDR_TCNT);
assign o_cnt_clr = (~(TCCR2[0]));	
assign o_cnt_dir =   (TCCR2[1]);
//---------------------------------------------

//---------------------------------------------
endmodule
