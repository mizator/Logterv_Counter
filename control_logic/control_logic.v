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
	input 	[15:0]	i_cnt_data,			// Counter 	Data


	output			o_cap_en,			// Input Capture Enable
	output			o_cap_clr,			// Input Capture Clear
	input 			i_cap_ic_flg,		// Input Capture Flag
	input 	[15:0]	i_cap_cnt_data		// Input Capture Data

);

//---------------------------------------------
// Register Map
//---------------------------------------------
// Timer Counter Control Register
reg 	[15:0] 	TCCR;
parameter		ADDR_TCCR 	= 4'b0001;			
//TCCR[0]		Global 					  Enable	(0 - DIS _ 1 - EN)
//TCCR[1]		Global   		Interrupt Enable 	(0 - DIS _ 1 - EN)
//TCCR[2]		Overflow 		Interrupt Enable 	(0 - DIS _ 1 - EN)
//TCCR[3]		Output Compare 	Interrupt Enable 	(0 - DIS _ 1 - EN)
//TCCR[4]		Input Capture 	Interrupt Enable	(0 - DIS _ 1 - EN)
//TCCR[5]		Counting 				  Enable	(0 - DIS _ 1 - EN)
//TCCR[6]		Counting 		Direction			(0 - DWN _ 1 - UP)			
//TCCR[7]		Input 			Capture   Enable	(0 - DIS _ 1 - EN)
//TCCR[8]		Normal  	/	Compare   Mode		(0 - NOR _ 1 - CC)
//TCCR[9]		Single 		/ 	Periodic  Mode 		(0 - SIN _ 1 - PER)
//TCCR[10]		Fast PWM 				  Mode 		(0 - DIS _ 1 - EN)
//TCCR[11]		Output Pin 		Polarity			(0 - NOR _ 1 - NEG)
//---------------------------------------------
// Timer Counter Command Register 2
reg 	[15:0] 	TCCR2;
parameter		ADDR_TCCR2 	= 4'b0010;
//TCCR2[ 7:0] 	Prescale value
//TCCR2[11:8]	TOP 	 value
parameter		BIT08		= 4'b0001;
parameter		BIT09		= 4'b0010;
parameter		BIT10		= 4'b0011;
parameter		BIT11		= 4'b0100;
parameter		BIT12		= 4'b0101;
parameter		BIT13		= 4'b0110;
parameter		BIT14		= 4'b0111;
parameter		BIT15		= 4'b1000;	
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
//TCST[3]	Input Capture Not Empty 			// Clearing this bit will clear ICR Register
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
reg 		r_bus_w;
//---------------------------------------------
always @ (posedge i_sysclk)
begin
	if (i_sysrst)
	begin
		r_obus_data <= 16'b0;
		r_ibus_data <= 16'b0;
		r_ibus_addr <= 4'b0;
		r_ack 		<= 0;
		r_bus_w 	<= 0;

		TCCR  		<= 16'b0;
		TCCR2 		<= 16'b0;
		TCNT 		<= 16'b0;
		OCR   		<= 16'b0;
		ICR 		<= 16'b0; 
		TCST 		<= 16'b0;
	end 
	else begin
		if (i_bus_select == 1'b1) begin
			if(~i_bus_wr)begin
				r_bus_w = 0; 							//Register Read
				r_ibus_addr <= 4'b0;
				r_ibus_data <= 16'b0;
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
			else if(i_bus_wr) begin 					//Register Read
				r_bus_w = 1;
				r_ibus_addr <= i_reg_addr;
				r_ibus_data <= i_bus_data;
				case (i_reg_addr)
		  			ADDR_TCCR  : TCCR 	<= i_bus_data;		
		  			ADDR_TCCR2 : TCCR2 	<= i_bus_data;
		  			ADDR_TCNT  : TCNT 	<= i_bus_data;
		  			ADDR_OCR   : OCR 	<= i_bus_data;
		  			ADDR_ICR   : ICR 	<= i_bus_data;
		  			ADDR_TCST  : TCST 	<= i_bus_data;
		  			default    : ?? <= 16'b0;
				endcase
			end
			r_ack <= 1;
		end
		else begin
			r_ack <= 0;
			TCNT <= i_cnt_data;
			ICR <= i_cap_cnt_data;
			if (TCCR[1]) begin 														// Global   		Interrupt Enable
				TCST <= {12'b0  ,	(|ICR || i_cap_ic_flg)	 ? 1'b1 : 1'b0, 3'b0};			// ICR Not Empty Bit
									//(TCCR[4] & i_cap_ic_flg) ? 1'b1 : TCST[2],0,0};		// Input    Capture	Interrupt Enable
						 			//(TCCR[3] &  cap_ocm_flg) ? 1'b1 : TCST[1], 		// Compare  Match 	Interrupt Enable
						 			//(TCCR[2] &  cnt_ovf_flg) ? 1'b1 : TCST[0]};	// Overflow 		Interrupt Enable
			end	
		end
	end
end
//---------------------------------------------
// Acknowledge Generation
//---------------------------------------------
assign o_bus_data = (i_bus_select & ~(i_bus_wr)) ? r_obus_data : 16'b0;
assign o_bus_ack  =  (r_ack)?1:0;
//---------------------------------------------


//---------------------------------------------
// Interrupt Generation
//---------------------------------------------
assign  o_int_flg = (|(TCST[2:0]));				// Status Register Interrupt Flags
//---------------------------------------------


//---------------------------------------------
// TOP Value Setting
//---------------------------------------------
reg [15:0] TOP;
//---------------------------------------------
always @(posedge i_sysclk) 
begin
	if (i_sysrst)
		TOP <= MAX;
	else if (|TCCR2[11:8]) 
	begin
		case (TCCR2[11:8])
		  	BIT08  : TOP <= 16'h00FF;
		  	BIT09  : TOP <= 16'h01FF;
		  	BIT10  : TOP <= 16'h03FF;
		  	BIT11  : TOP <= 16'h07FF;
		  	BIT12  : TOP <= 16'h0FFF;
		  	BIT13  : TOP <= 16'h1FFF;
		  	BIT14  : TOP <= 16'h3FFF;
		  	BIT15  : TOP <= 16'h7FFF;
		  	default: TOP <= MAX;
		endcase
	end
end
//---------------------------------------------


//---------------------------------------------
// Prescaler Control Signals
//---------------------------------------------
assign o_prs_ld_data = TCCR2[7:0];							// Prescale Value
assign o_prs_ld = ((r_bus_w) && (r_ibus_addr == ADDR_TCCR2));
assign o_prs_en = (TCCR[5]);								// Counting Enable
//---------------------------------------------


//---------------------------------------------
// Input Capture Control Signals
//---------------------------------------------
assign o_cap_en  =  (TCCR[7]);					// Input Capture Enable
assign o_cap_clr =	((r_bus_w) && (r_ibus_addr == ADDR_TCST) && (~(r_ibus_data[3])));	//nem biztos hogy jó				// Input Capture Clear
//---------------------------------------------


//---------------------------------------------
// Counter Control Signals
//---------------------------------------------
assign o_cnt_ld_data = TCNT;

//assign o_cnt_en  = (TCCR[5] && );				// Counting Enable
assign o_cnt_ld  = ((r_bus_w) && (r_ibus_addr == ADDR_TCNT));
//assign o_cnt_clr = (~(TCCR[5]));				// nem jó
assign o_cnt_dir =   (TCCR[6]);					//  Counting Direction
//---------------------------------------------

//---------------------------------------------
// Waveform Generator
//---------------------------------------------
//TCCR[0]		Global 					  Enable	(0 - DIS _ 1 - EN)
//TCCR[8]		Normal  	/	Compare   Mode		(0 - NOR _ 1 - CC)
//TCCR[9]		Single 		/ 	Periodic  Mode 		(0 - SIN _ 1 - PER)
//TCCR[10]		Fast PWM 				  Mode 		(0 - DIS _ 1 - EN)
//TCCR[11]		Output Pin 		Polarity			(0 - NOR _ 1 - INV)

//assign o_out_pin = (TCCR[11]) ? : ~ ;
//---------------------------------------------
endmodule
