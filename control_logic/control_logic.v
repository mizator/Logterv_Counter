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
//TCCR[8]		WMOD[0]								 Waveform Mode [0]				
//TCCR[9]		WMOD[1]			 					 Waveform Mode [1]
//TCCR[10]		Output Pin 				  Enable 	(0 - DIS _ 1 - EN)
//TCCR[11]		Output Pin 		Polarity			(0 - NOR _ 1 - NEG)
//---------------------------------------------
// 			Waveform Mode 	  Bit		   Flag
//---------------------------------------------
parameter		NORMAL 		= 2'b00;	//  OVF_FLG 	// Normal Mode
parameter		COMC 		= 2'b01;	// COMC_FLG 	// Compare Inner Timer 	 with TOP
parameter		COMI 		= 2'b10;	// COMI_FLG 	// Compare Input Capture with TOP
parameter		PWM 		= 2'b11;	// CPWM_FLG 	// Pulse Width Modulation
//---------------------------------------------
// Timer Counter Command Register 2
reg 	[15:0] 	TCCR2;
parameter		ADDR_TCCR2 	= 4'b0010;
//TCCR2[ 7:0] 	Prescale Value Configuration 
//TCCR2[11:8]	TOP 	 Value Configuration
//TCCR2[15:12]	COMPARE  Value Configuration
// Possible TOP - COMPARE Values
parameter		OCR_V 		= 4'b0001;		// Output Compare Register
parameter		ICR_V 		= 4'b0010;		// Input Capture Register
parameter		BIT08		= 4'b0011;		// 0x00FF
parameter		BIT09		= 4'b0100;		// 0x01FF
parameter		BIT10		= 4'b0101;		// 0x03FF
parameter		BIT11		= 4'b0110;		// 0x07FF
parameter		BIT12		= 4'b0111;		// 0x0FFF
parameter		BIT13		= 4'b1000;		// 0x1FFF
parameter		BIT14		= 4'b1001;		// 0x3FFF
parameter		BIT15		= 4'b1010;		// 0x7FFF
//---------------------------------------------
// Timer-Counter Register, current counter value
parameter		ADDR_TCNT 	= 4'b0011;	
//---------------------------------------------
// Output Compare Register, compared value	
reg 	[15:0] 	OCR;
parameter		ADDR_OCR 	= 4'b0100;
//---------------------------------------------
// Input  Capture Register, current input counter value
parameter		ADDR_ICR 	= 4'b0101;		
//---------------------------------------------
// Timer Counter Status Register
reg 	[15:0] 	TCST;
parameter		ADDR_TCST 	= 4'b0110;
//TCST[0]	Overflow Interrupt
//TCST[1]	Output Capture Interrupt
//TCST[2]	Input  Capture Interrupt
//TCST[3]	Input Capture Not Empty 			// Clearing this bit will clear ICR Register
//---------------------------------------------
parameter 		MAX    = 16'hFFFF;
parameter 		BOTTOM = 16'H0000;
reg 	[15:0] 	ERROR;
//---------------------------------------------

//---------------------------------------------
// Bus Read-Write
//---------------------------------------------
reg [15:0] 	r_obus_data;
reg [15:0] 	r_TCNT_data;
reg 		r_ack;
reg 		r_prs_ld_signal;
reg 		r_cnt_ld_signal_BUS;
reg 		r_cap_clr;
//---------------------------------------------
always @ (posedge i_sysclk)
begin
	if (i_sysrst)
	begin
		r_obus_data <= 16'b0;
		r_ack 		<= 0;
		r_prs_ld_signal <=0;
		r_cnt_ld_signal_BUS <=0;
		r_cap_clr		<=0;

		TCCR  		<= 16'b0;
		TCCR2 		<= 16'b0;
		OCR   		<= 16'b0;
		TCST 		<= 16'b0;
		ERROR 		<= 16'b0;
	end 
	else begin
		if (i_bus_select == 1'b1) begin
			if(~i_bus_wr)begin 							//Register Read
				r_TCNT_data <= 16'b0;
				case (i_reg_addr)
		  			ADDR_TCCR  : r_obus_data <= TCCR;
		  			ADDR_TCCR2 : r_obus_data <= TCCR2;
		  			ADDR_TCNT  : r_obus_data <= i_cnt_data;		//TCNT
		  			ADDR_OCR   : r_obus_data <= OCR;
		  			ADDR_ICR   : r_obus_data <= i_cap_cnt_data;	//ICR
		  			ADDR_TCST  : r_obus_data <= TCST;
		  			default    : r_obus_data <= 16'b0;
				endcase
			end
			else if(i_bus_wr) begin 					//Register Write
				r_obus_data <= 16'b0;
				case (i_reg_addr)
		  			ADDR_TCCR  : TCCR 		 <= i_bus_data;		
		  			ADDR_TCCR2 : TCCR2 		 <= i_bus_data;
		  			ADDR_TCNT  : r_TCNT_data <= i_bus_data;		
		  			ADDR_OCR   : OCR 		 <= i_bus_data;
		  			ADDR_TCST  : TCST 		 <= i_bus_data;
		  			default    : ERROR  	 <= 16'h0001;
				endcase

				if (i_reg_addr == ADDR_TCCR2) 
					r_prs_ld_signal <= 1;
				else
					r_prs_ld_signal <= 0;

				if (i_reg_addr == ADDR_TCNT) 
					r_cnt_ld_signal_BUS <= 1;
				else
					r_cnt_ld_signal_BUS <= 0;

				if (i_reg_addr == ADDR_TCST) 
					r_cap_clr <= (~(i_bus_data[3]));
				else
					r_cap_clr <= 0;
			end
			r_ack <= 1;
		end
		else begin
			r_obus_data <= 16'b0;
			r_ack <= 0;
			r_prs_ld_signal <= 0;
			r_cnt_ld_signal_BUS <= 0;
			r_cap_clr <= 0;

			if (TCCR[1]) begin 															// Global   		Interrupt Enable
				TCST <= {12'b0  ,	(|i_cap_cnt_data && ~r_cap_clr)	 ? 1'b1 : 1'b0,		// ICR Not Empty Bit
									(TCCR[4] &  i_cap_ic_flg ) ? 1'b1 : TCST[2],			// Input    Capture	Interrupt Enable		
						 			(TCCR[3] &  w_cap_cmp_flg) ? 1'b1 : TCST[1], 			// Compare  Match 	Interrupt Enable
						 			(TCCR[2] &  w_cnt_ovf_flg) ? 1'b1 : TCST[0]};		// Overflow 		Interrupt Enable
			end	
		end
	end
end
//---------------------------------------------
// Acknowledge Generation
//---------------------------------------------
assign o_bus_data =  r_obus_data;
assign o_bus_ack  =  (r_ack)?1:0;
//---------------------------------------------


//---------------------------------------------
// Interrupt Generation
//---------------------------------------------
assign  o_int_flg = (|(TCST[2:0]));				// Status Register Interrupt Flags
//---------------------------------------------





//---------------------------------------------
// Prescaler Control Signals
//---------------------------------------------
assign o_prs_ld_data = (r_prs_ld_signal) ? TCCR2[7:0]: 8'b0;	// Prescale Value
assign o_prs_ld = r_prs_ld_signal;
assign o_prs_en = (TCCR[0] && TCCR[5] && (~r_prs_ld_signal)); 	// Global Enable  && Counting Enable
//---------------------------------------------


//---------------------------------------------
// Input Capture Control Signals
//---------------------------------------------
assign o_cap_en  =  (TCCR[0] && TCCR[7] && (~r_cap_clr));		// Global Enable && Input Capture Enable
assign o_cap_clr =	r_cap_clr;									// Input Capture Clear  				
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
	else 
	begin
		case (TCCR2[11:8])
		  	OCR_V 	: TOP <= OCR;
			ICR_V 	: TOP <= i_cap_cnt_data;
		  	BIT08  	: TOP <= 16'h00FF;
		  	BIT09  	: TOP <= 16'h01FF;
		  	BIT10  	: TOP <= 16'h03FF;
		  	BIT11  	: TOP <= 16'h07FF;
		  	BIT12  	: TOP <= 16'h0FFF;
		  	BIT13  	: TOP <= 16'h1FFF;
		  	BIT14  	: TOP <= 16'h3FFF;
		  	BIT15  	: TOP <= 16'h7FFF;
		  	default : TOP <= MAX;
		endcase
	end
end
//---------------------------------------------


//---------------------------------------------
// COMPARE Value Setting
//---------------------------------------------
reg [15:0] COMPARE;
//---------------------------------------------
always @(posedge i_sysclk) 
begin
	if (i_sysrst)
		COMPARE <= MAX;
	else 
	begin
		case (TCCR2[15:12])
		  	OCR_V 	: COMPARE <= OCR;
		  	ICR_V 	: COMPARE <= i_cap_cnt_data;
		  	BIT08  	: COMPARE <= 16'h00FF;
		  	BIT09  	: COMPARE <= 16'h01FF;
		  	BIT10  	: COMPARE <= 16'h03FF;
		  	BIT11  	: COMPARE <= 16'h07FF;
		  	BIT12  	: COMPARE <= 16'h0FFF;
		  	BIT13  	: COMPARE <= 16'h1FFF;
		  	BIT14  	: COMPARE <= 16'h3FFF;
		  	BIT15  	: COMPARE <= 16'h7FFF;
		  	default : COMPARE <= MAX;
		endcase
	end
end
//---------------------------------------------


//---------------------------------------------
// Waveform Generator
//---------------------------------------------
//TCCR[8]		WMOD[0]								 Waveform Mode [0]				
//TCCR[9]		WMOD[1]			 					 Waveform Mode [1]
//TCCR[10]		Output Pin 				  Enable 	(0 - DIS _ 1 - EN)
//TCCR[11]		Output Pin 		Polarity			(0 - NOR _ 1 - NEG)
//---------------------------------------------
//Bit - Waveform Mode 					Flag
// 00 - Normal							OVF
// 01 - Compare Inner Counter to TOP	CTC
// 10 - Compare Input Caputer to TOP 	CIC
// 11 - PWM								CPWM
//---------------------------------------------
reg  r_output;
reg  r_cnt_ld_signal_WF;
reg  r_cnt_clr;
reg  r_cap_cmp_flg;
wire w_cap_cmp_flg;
//---------------------------------------------
always @(posedge i_sysclk) 
begin
	if (i_sysrst)
	begin 
		r_output <= 0;
		r_cap_cmp_flg <= 0;
	end
	else
	begin
		if (TCCR[10] && i_prs_sclk_fall) 
		begin
			case (TCCR[9:8])
			  	NORMAL 	: begin
			  				if(i_cnt_data == MAX)
			  					r_output <= 1;
			  				else
			  					r_output <= 0;	
			  			  end
			  	COMC 	: begin
			  				if(i_cnt_data == TOP) 
			  				begin
			  					r_output <= ~r_output;
			  					r_cap_cmp_flg <= 1;
			  				end
			  				else
			  					r_cap_cmp_flg <= 0;	
			  			  end
			  	COMI 	: begin
			  				if(i_cap_cnt_data == TOP)
			  				begin
			  					r_output <= ~r_output;
			  					r_cap_cmp_flg <= 1;
			  				end
			  				else
			  					r_cap_cmp_flg <= 0;
			  			  end
			  	PWM 	: begin
			  				if(i_cnt_data <= COMPARE)
			  					r_output <= 1;
			  				else
			  					r_output <= 0;
			  				if(i_cnt_data == COMPARE)
			  					r_cap_cmp_flg <= 1;
			  				else
			  					r_cap_cmp_flg <= 0;
			  			  end
			endcase
		end
		else 
		begin
			r_cap_cmp_flg <= 0;
			if (~TCCR[10])
				r_output <= 0;
		end	
	end
end
//---------------------------------------------
assign o_out_pin = ( (TCCR[10] && r_output) ^ TCCR[11]);
assign w_cap_cmp_flg = r_cap_cmp_flg;
//---------------------------------------------

//---------------------------------------------
// Overflow Flag Generation
//---------------------------------------------
reg 		r_cnt_ovf;
wire 		w_cnt_ovf_flg;
//---------------------------------------------
always @(posedge i_sysclk) 
begin
	if (i_sysrst)
		r_cnt_ovf <= 0;
	else begin
		if ((i_cnt_data == MAX) || (i_cnt_data == BOTTOM))
			r_cnt_ovf <= 1;
		else 
			r_cnt_ovf <= 0;
	end
end
//---------------------------------------------
assign  w_cnt_ovf_flg = (    r_cnt_ovf && 
						(((i_cnt_data == BOTTOM) &&   TCCR[6]) 
					  || ((i_cnt_data == MAX   ) && (~TCCR[6]))));				
//---------------------------------------------


//---------------------------------------------
// Counter Control Signals
//---------------------------------------------
assign o_cnt_ld  = (r_cnt_ld_signal_BUS);								
assign o_cnt_ld_data = (r_cnt_ld_signal_BUS) ? r_TCNT_data : 16'b0;
assign o_cnt_en  = 	 (TCCR[0] && TCCR[5] && 
						 i_prs_sclk_rise && 
						 (~r_cnt_ld_signal_BUS));					// Counting Enable
assign o_cnt_dir =   (TCCR[6]);									//  Counting Direction

//wire w_cnt_clr_signal;
//assign w_cnt_clr_signal = 		
//assign o_cnt_clr = w_cnt_clr_signal;				
//---------------------------------------------


/*
always @(posedge i_sysclk) 
begin
	if (i_sysrst) begin
		
	end
	else if () begin
		
	end
end
*/


//---------------------------------------------
endmodule
