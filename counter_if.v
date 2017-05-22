`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
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
//////////////////////////////////////////////////////////////////////////////////

module counter_if(	
	input			i_sysclk,		// System Clock
	input			i_sysrst,		// System Reset

	input 			i_cap_pin,		// Input Capture Pin
	output 			o_cout_pin,		// Output Capture Pin

	input 			i_bus_select,	// Select Periphery
	input 			i_bus_wr,		// Bus Write
	input 	[3:0]	i_reg_addr,		// Register Address
	input 	[15:0]	i_bus_data,		// Data input
	output 	[15:0]	o_bus_data,		// Data output
	output 			o_bus_ack,

	output 			o_int_flg		// Interrupt flag
);
//---------------------------------------------
// Register Map
//---------------------------------------------
// Timer Counter Control Register
reg 	[15:0] 	TCCR;
parameter		ADDR_TCCR = 4'b0001;			
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
// Timer-Counter Register, current counter value
reg 	[15:0] 	TCNT;
parameter		ADDR_TCNT = 4'b0010;	
//---------------------------------------------
// Output Compare Register, compared value	
reg 	[15:0] 	OCR;
parameter		ADDR_OCR = 4'b0011;
//---------------------------------------------
// Input  Capture Register, Input signals
reg 	[15:0] 	ICR;
parameter		ADDR_ICR = 4'b0100;		
//---------------------------------------------
parameter MAX    = 4'hFFFF;
parameter BOTTOM = 4'H0000;
//---------------------------------------------
// Timer Counter Status Register
reg 	[15:0] 	TCST;
parameter		ADDR_TCST = 4'b0101;
//TCST[0]	Overflow Interrupt
//TCST[1]	Output Capture Interrupt
//TCST[2]	Input Capture Interrupt	
//---------------------------------------------
// Timer Counter Status Register
reg 	[15:0] 	TCCR2;
parameter		ADDR_TCCR2 = 4'b0110;
//TCCR2[0]		// Counter Enable
//TCCR2[1]		// Counter direction
//TCCR2[2]		// Input Capture Enable
//---------------------------------------------

//---------------------------------------------
// Register Read
//---------------------------------------------
reg [15:0] r_obus_data;
reg [15:0] r_ibus_data;
reg [ 3:0] r_ibus_addr;
reg r_ack;
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
		  			ADDR_TCNT  : r_obus_data <= TCNT;
		  			ADDR_OCR   : r_obus_data <= OCR;
		  			ADDR_ICR   : r_obus_data <= ICR;
		  			ADDR_TCST  : r_obus_data <= TCST;
		  			ADDR_TCCR2 : r_obus_data <= TCCR2;
		  			default    : r_obus_data <= 16'b0;
				endcase
			end
			else if(i_bus_wr) begin
				r_ibus_data <= i_bus_data;
				case (i_reg_addr)
		  			ADDR_TCCR  : r_ibus_addr <= ADDR_TCCR;
		  			ADDR_TCNT  : r_ibus_addr <= ADDR_TCNT;
		  			ADDR_OCR   : r_ibus_addr <= ADDR_OCR;
		  			ADDR_ICR   : r_ibus_addr <= ADDR_ICR;
		  			ADDR_TCST  : r_ibus_addr <= ADDR_TCST;
		  			ADDR_TCCR2 : r_ibus_data <= TCCR2;
		  			default    : r_ibus_addr <= 16'b0;
				endcase
			end
			r_ack <= 1'b1;
		end
		else r_ack <= 1'b0;
	end
end
//---------------------------------------------
assign o_bus_data = (i_bus_select & i_bus_wr) ? r_obus_data : 16'b0;
assign o_bus_ack  = r_ack;
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
		 	if(TCCR[5] & cnt_ovf_flg) r_ovf_flg <= 1'b1; else r_ovf_flg <= 1'b0;
		 	//if(TCCR[6] & cap_ocm_flg) r_ocm_flg <= 1'b1; else r_ocm_flg <= 1'b0;
		 	if(TCCR[7] & cap_ic_flg)  r_ic_flg  <= 1'b1; else r_ic_flg  <= 1'b0;
	end
end
//---------------------------------------------
assign w_ovf_flg = r_ovf_flg;
assign w_ocm_flg = r_ocm_flg;
assign w_ic_flg  =  r_ic_flg;
//---------------------------------------------
// TCST Register Write
//---------------------------------------------
always @(posedge i_sysclk) 
begin
	if (i_sysrst) 
		TCST <= 16'b0;
	else if(r_ibus_addr == TCST)begin
		TCST <= r_ibus_data;
	end
	else begin 
		TCST <= {13'b0  ,(w_ic_flg) ?1'b1:TCST[2],
						 (w_ocm_flg)?1'b1:TCST[1],
						 (w_ovf_flg)?1'b1:TCST[0]};
	end
end
//---------------------------------------------
assign  o_int_flg = (TCST[2:0] != 3'b000);
//---------------------------------------------

//---------------------------------------------
// Instantiate Prescaler
//---------------------------------------------
wire 		prs_en;
wire 		prs_ld;
wire [7:0]	prs_ld_data;
wire 		sclk;
wire 		sclk_rise;
wire 		sclk_fall;
//---------------------------------------------
prescaler prescaler(
	.i_sysclk(i_sysclk), 			//
    .i_sysrst(i_sysrst),			//
	.i_mod_en(prs_en),				//
	.i_ld(prs_ld),					//
	.i_ld_data(prs_ld_data), 		//
	.o_sclk(sclk), 					// ??????
	.o_sclk_rise(sclk_rise), 		// ??????
	.o_sclk_fall(sclk_fall)			// ??????
);
//---------------------------------------------
assign prs_ld_data = TCCR[15:8];
assign prs_ld = (r_ibus_addr == ADDR_TCCR);
assign prs_en = (TCCR[0]);
//---------------------------------------------
// TCCR Register Write
//---------------------------------------------
always @(posedge i_sysclk) 
begin
	if (i_sysrst) 
		 TCCR <= 16'b0;
	else if(r_ibus_addr == TCCR)
		TCCR <= r_ibus_data;
end
//---------------------------------------------

//---------------------------------------------
// Instantiate Counter
//---------------------------------------------
wire 		cnt_en;
wire 		cnt_ld;
wire 		cnt_dir;
wire 		cnt_clr;
wire [15:0] cnt_ld_data;
wire 		cnt_ovf_flg;
wire [15:0] cnt_data;
//---------------------------------------------
counter counter(	
	.i_sysclk(i_sysclk),			//
	.i_sysrst(i_sysrst),			//
	.i_cnt_en(cnt_en),				// ????????		
	.i_ld(cnt_ld),					//
	.i_dir(cnt_dir),				//
	.i_clr(cnt_clr),				//
	.i_ld_data(cnt_ld_data),		//
	.o_ovf_flg(cnt_ovf_flg),		//
	.o_cnt(cnt_data)				//
);
//---------------------------------------------
assign cnt_ld_data = TCNT;
assign cnt_ld  = (r_ibus_addr == ADDR_TCNT);
assign cnt_clr = (i_sysrst || (~TCCR2[0]));	
assign cnt_dir = (TCCR2[1]);
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
		TCNT <= cnt_data;
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
// Instantiate Input Capture
//---------------------------------------------
wire 		cap_en;
wire 		cap_clr;
wire 		cap_ic_flg;
wire [15:0] cap_cnt_data;
//---------------------------------------------
input_capture input_capture(
	.i_sysclk(i_sysclk),			//
	.i_sysrst(i_sysrst),			//
	.i_cap_pin(i_cap_pin),			//			
	.i_clr(cap_clr),				//	
	.i_cnt_en(cap_en),				//	
	.o_ic_flg(cap_ic_flg),			//
	.o_cnt(cap_cnt_data)			//
);
//---------------------------------------------
assign cap_clr =   (i_sysrst || (~TCCR2[2]));
assign cap_en  = (~(i_sysrst || (~TCCR2[2])));
//---------------------------------------------
// Input Capture Register Write
//---------------------------------------------
always @(posedge i_sysclk) 
begin
	if (i_sysrst) 
		ICR <= 16'b0;
	else
		ICR <= cap_cnt_data;
end
//---------------------------------------------

//---------------------------------------------
// Output Waveform Generation
//---------------------------------------------


//---------------------------------------------
endmodule
