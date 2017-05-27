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

	wire 	[7:0] 	prs_ld_data;
	wire 	[15:0]	cnt_ld_data;
	wire 	[15:0]	cnt_data;
	wire 	[15:0] 	cap_cnt_data;



//---------------------------------------------
// Instantiate the Unit Under Test (UUT)
//---------------------------------------------
control_logic control_logic(	
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
	.i_clr(cnt_clr),				
	.i_ld_data(cnt_ld_data),				
	.o_cnt_data(cnt_data)				
);
//---------------------------------------------


//---------------------------------------------
// Instantiate Input Capture
//---------------------------------------------
input_capture input_capture(
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
	r_reg_addr 		<= reg_addr;	// Select Register Address
	r_i_bus_data 	<= bus_data;	// Write data to bus
	r_bus_wr 		<= 1'b1;		// Write Select 
	r_bus_select 	<= 1'b1;		// Select Target
	#10 wait(bus_ack);				// Wait For ACK
	r_bus_wr 		<= 1'b0;		// Release Write
	r_bus_select 	<= 1'b0;		// Release Target
	r_i_bus_data	<= 16'b0;		// Release Data
	r_reg_addr		<= 16'b0;		// Release Register Address	
end
endtask
//-----------------------------------------------


//-----------------------------------------------
// Bus Read
//-----------------------------------------------
task bus_read (input [3:0] reg_addr);
begin
	r_reg_addr 		<= reg_addr;	// Select Register
	r_bus_wr 		<= 1'b0;		// Read Select
	r_bus_select 	<= 1'b1;		// Select Target
	#10 wait(bus_ack);				// Wait For ACK
	r_bus_wr 		<= 1'b0;		// Release Write
	r_bus_select 	<= 1'b0;		// Release Target
	r_reg_addr		<= 16'b0;		// Release Register Address
end
endtask
//---------------------------------------------------------


//---------------------------------------------------------
// Register Map
//---------------------------------------------------------
// TCCR  - Timer Counter Control Register
// TCCR2 - Timer Counter Control Register
// TCNT  - Timer Counter Value   Register
// OCR   - Output Compare 		 Register
// ICR   - Input Capture 		 Register
// TCST  - Timer Counter Status  Register
//---------------------------------------------------------
// Timer Counter Control Register
parameter		ADDR_TCCR 	= 4'b0001;			
//TCCR[0]		Global 					  Enable	(0 - DIS _ 1 - EN)
//TCCR[1]		Global   		Interrupt Enable 	(0 - DIS _ 1 - EN)
//TCCR[2]		Overflow 		Interrupt Enable 	(0 - DIS _ 1 - EN)
//TCCR[3]		CIC   Compare 	Interrupt Enable 	(0 - DIS _ 1 - EN) 	Counter or Input Capture

//TCCR[4]		PWM   Compare 	Interrupt Enable 	(0 - DIS _ 1 - EN)
//TCCR[5]		Input Capture 	Interrupt Enable	(0 - DIS _ 1 - EN)
//TCCR[6]		Counting 				  Enable	(0 - DIS _ 1 - EN)					
//TCCR[7]		Input 			Capture   Enable	(0 - DIS _ 1 - EN)

//TCCR[8]		WMOD[0]								 Waveform Mode [0]				
//TCCR[9]		WMOD[1]			 					 Waveform Mode [1]
//TCCR[10]		Output Pin 				  Enable 	(0 - DIS _ 1 - EN)
//TCCR[11]		Output Pin 		Polarity			(0 - NOR _ 1 - NEG)

//TCCR[12]		Periodic/Single 		  Mode 		(0 - PER _ 1 - SIN)
//---------------------------------------------------------
// 			Waveform Mode 	  Bit		   Flag
//---------------------------------------------------------
parameter		NORMAL 		= 2'b00;	// CNT_OVF_FLG 	- Normal Mode
parameter		COMC 		= 2'b01;	// CIC_CMP_FLG 	- Compare Inner Timer 	 with TOP
parameter		COMI 		= 2'b10;	// CIC_CMP_FLG 	- Compare Input Capture with TOP
parameter		PWM 		= 2'b11;	// PWM_CMP_FLG 	- Pulse Width Modulation
//---------------------------------------------------------
// Timer Counter Command Register 2
parameter		ADDR_TCCR2 	= 4'b0010;
//TCCR2[ 7:0] 	Prescale 		Value Configuration
//TCCR2[11:8]	TOP 	 		Value Configuration
//TCCR2[15:12]	COMPARE_PWM 	Value Configuration
//---------------------------------------------------------
//			TOP/COMPARE_PWM    Values
parameter		OCR_V 		= 4'b0001;	// Output Compare Register Value
parameter		ICR_V 		= 4'b0010;	// Input  Capture Register Value
parameter		BIT08		= 4'b0011;	// 0x00FF
parameter		BIT09		= 4'b0100;	// 0x01FF
parameter		BIT10		= 4'b0101;	// 0x03FF
parameter		BIT11		= 4'b0110;	// 0x07FF
parameter		BIT12		= 4'b0111;	// 0x0FFF
parameter		BIT13		= 4'b1000;	// 0x1FFF
parameter		BIT14		= 4'b1001;	// 0x3FFF
parameter		BIT15		= 4'b1010;	// 0x7FFF
//---------------------------------------------------------
// Timer-Counter Register, current counter value
parameter		ADDR_TCNT 	= 4'b0011;	
//---------------------------------------------------------
// Output Compare Register, compared value	
parameter		ADDR_OCR 	= 4'b0100;
//---------------------------------------------------------
// Input  Capture Register, current input counter value
parameter		ADDR_ICR 	= 4'b0101;		
//---------------------------------------------------------
// Timer Counter Status Register
parameter		ADDR_TCST 	= 4'b0110;
//TCST[0]	Overflow 		Interrupt
//TCST[1]	CIC 	Compare Interrupt
//TCST[2]	PWM 	Compare Interrupt
//TCST[3]	Input  	Capture Interrupt
//TCST[4]	Single  Period  Finished	// Clearing this bit starts over period
//TCST[5]	Input  	Capture Not Empty 	// Clearing this bit clears ICR Register
//---------------------------------------------------------
parameter 		MAX    = 16'hFFFF;
parameter 		BOTTOM = 16'H0000;
//---------------------------------------------------------

initial begin
	// Initialize Inputs
	r_clk = 1;
    r_rst = 1;
	r_cap_pin = 0;
	r_bus_select = 0;
	r_bus_wr = 0;
	r_reg_addr = 4'b0;
	r_i_bus_data = 16'b0;

    #60 r_rst = 0; 
    bus_write(ADDR_TCCR , 16'b0001_0111_1100_1111);
	bus_write(ADDR_TCCR2, 16'h34_01);
	#100
	wait(int_flg);
	#200
	bus_write(ADDR_TCST , 16'h00_00);
//	bus_write(ADDR_OCR  , 16'h02_FF);
//	bus_write(ADDR_TCNT , 16'h00_F0);
//	bus_write(ADDR_TCST , 16'h00_10);
//	bus_write(8'h0a , 16'h00_F0);
//  bus_write(ADDR_TCST , 16'h00_10);
    #200000;
//	bus_write(ADDR_TCCR2, 16'h38_02);

    #30;
//    bus_read (ADDR_TCCR );
//    bus_read (ADDR_TCCR2);
//    bus_read (ADDR_TCNT );
//    bus_read (ADDR_OCR  );
//    bus_read (ADDR_ICR  );
//    bus_read (8'h0a 	);
//    bus_read (ADDR_TCST);
end
//    bus_write(ADDR_TCCR , 16'b0000_0000_0010_1111);
//    bus_write(ADDR_OCR  , 16'b0000_0000_0000_0000);
//    bus_write(ADDR_ICR  , 16'b0000_0000_0000_0000);
//    bus_write(ADDR_TCST , 16'h0000);

//---------------------------------------------
// Generate Input Event
//---------------------------------------------
always 
begin
    #7 r_cap_pin = 1;
    #2 r_cap_pin = 0;  
end
//---------------------------------------------

//---------------------------------------------
// Generate clock
//---------------------------------------------
always #5 r_clk = ~r_clk;
//---------------------------------------------
endmodule
