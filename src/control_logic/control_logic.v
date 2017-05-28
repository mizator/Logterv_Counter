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
	output 			o_cnt_clr,			// Counter  Clear
	output 	[15:0]	o_cnt_ld_data,		// Counter  Load Data
	input 	[15:0]	i_cnt_data,			// Counter 	Data


	output			o_cap_en,			// Input Capture Enable
	output			o_cap_clr,			// Input Capture Clear
	input 			i_cap_ic_flg,		// Input Capture Flag
	input 	[15:0]	i_cap_cnt_data		// Input Capture Data
);
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
reg 	[15:0] 	TCCR;
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
// Timer Counter Control Register 2
reg 	[15:0] 	TCCR2;
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
reg 	[15:0] 	OCR;
parameter		ADDR_OCR 	= 4'b0100;
//---------------------------------------------------------
// Input  Capture Register, current input counter value
parameter		ADDR_ICR 	= 4'b0101;		
//---------------------------------------------------------
// Timer Counter Status Register
reg 	[15:0] 	TCST;
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
reg 	[15:0] 	ERROR;
//---------------------------------------------------------

//---------------------------------------------------------
// Bus Read-Write
//---------------------------------------------------------
reg [15:0] 	r_obus_data;
reg [15:0] 	r_TCNT_data;
reg 		r_ack;
reg 		r_prs_ld_signal_BUS;
reg 		r_cnt_ld_signal_BUS;
reg 		r_cap_clr_BUS;
//---------------------------------------------------------
always @ (posedge i_sysclk)
begin
	if (i_sysrst)
	begin
		r_obus_data 		<= 16'b0;
		r_TCNT_data			<= 16'b0;
		r_ack 				<= 0;
		r_prs_ld_signal_BUS <= 0;
		r_cnt_ld_signal_BUS <= 0;
		r_cap_clr_BUS		<= 0;
		

		TCCR  		<= 16'b0;
		TCCR2 		<= 16'b0;
		OCR   		<= 16'b0;
		TCST 		<= 16'b0;
		ERROR 		<= 16'b0;
	end 
	else begin
		if (i_bus_select == 1'b1) begin 						// Bus Selected
			if(~i_bus_wr)begin 									// Register Read
				r_TCNT_data <= 16'b0; 							// Clear TNCT_data
				case (i_reg_addr)								// Register Address
		  			ADDR_TCCR  : r_obus_data <= TCCR;			// Control Register 
		  			ADDR_TCCR2 : r_obus_data <= TCCR2;			// Control Register 2
		  			ADDR_TCNT  : r_obus_data <= i_cnt_data;		// Counter Register
		  			ADDR_OCR   : r_obus_data <= OCR;			// Output Compare Register
		  			ADDR_ICR   : r_obus_data <= i_cap_cnt_data;	// Input  Capture Register
		  			ADDR_TCST  : r_obus_data <= TCST;			// Status Register
		  			default    : begin 
								 	ERROR  	 <= 16'h0001;		// ERROR in address
								 	r_obus_data <= 16'b0;		// 0 Output
								 end
				endcase
			end
			else if(i_bus_wr) begin 							// Register Write
				r_obus_data <= 16'b0;							// 0 Output
				case (i_reg_addr)								// Register Address
		  			ADDR_TCCR  : TCCR 		 <= i_bus_data;		// Control Register 
		  			ADDR_TCCR2 : TCCR2 		 <= i_bus_data;		// Control Register 2
		  			ADDR_TCNT  : r_TCNT_data <= i_bus_data;		// Counter Register
		  			ADDR_OCR   : OCR 		 <= i_bus_data;		// Output Compare Register
		  			ADDR_TCST  : TCST 		 <= i_bus_data;		// Status Register
		  			default    : begin
		  							ERROR  	 <= 16'h0001;		// ERROR in address
								 	r_obus_data <= 16'b1;		// 1 Output 
								 end
				endcase											// Input Capture is not writable

				if (i_reg_addr == ADDR_TCCR2) 					// If Control Register 2 addressed
					r_prs_ld_signal_BUS <= 1;					// Load new Prescaler value
				else 											// Else
					r_prs_ld_signal_BUS <= 0; 					// Clear Prescaler load signal

				if (i_reg_addr == ADDR_TCNT) 					// If Counter Register addressed
					r_cnt_ld_signal_BUS <= 1;					// Load new Counter value
				else 											// Else
					r_cnt_ld_signal_BUS <= 0;					// Clear Counter load signal

				if (i_reg_addr == ADDR_TCST) 					// If Status Register addressed
					r_cap_clr_BUS <= (~(i_bus_data[4])); 		// If Capture Register not empty flag deleted, than clear Capture Register
				else 											// Else
					r_cap_clr_BUS <= 0;							// Clear Capture clear signal
			end
			if (   (i_reg_addr == ADDR_TCCR )					// If Address is valid
				|| (i_reg_addr == ADDR_TCCR2)
				|| (i_reg_addr == ADDR_TCNT )
				|| (i_reg_addr == ADDR_OCR  )
				|| (i_reg_addr == ADDR_ICR  )
				|| (i_reg_addr == ADDR_TCST ))
				r_ack <= 1;										// Generate Acknowledge
			else 
			begin
				r_ack <= 0;
				ERROR <= 16'b0;
			end
		end
		else begin 												// If Bus not selected
			r_TCNT_data			<= 16'b0;
			r_obus_data 		<= 16'b0;						// 0 Output
			r_ack 				<= 0;							// ACK flag clear
			r_prs_ld_signal_BUS <= 0;							// Clear Prescaler load signal
			r_cnt_ld_signal_BUS <= 0;							// Clear Counter load signal
			r_cap_clr_BUS 		<= 0;							// Clear Capture clear signal										
		end
		if (~(i_bus_select & i_bus_wr & (i_reg_addr == ADDR_TCST))) begin
			TCST <= {10'b0,	
					((|i_cap_cnt_data) & (~r_cap_clr_BUS)) ? 1'b1 : 1'b0,		// ICR Not Empty and Wont be Cleared
					(TCCR[12] & (w_CIC_CMP_FLG || w_CNT_OVF_FLG))? 1'b1 : TCST[4],
					(TCCR[1] & TCCR[5] &   i_cap_ic_flg) ? 1'b1 : TCST[3],		// Input    Capture	Interrupt		
					(TCCR[1] & TCCR[4] &  w_PWM_CMP_FLG) ? 1'b1 : TCST[2],		// PWM 		Compare Interrupt
					(TCCR[1] & TCCR[3] &  w_CIC_CMP_FLG) ? 1'b1 : TCST[1], 		// Compare  Match 	Interrupt
					(TCCR[1] & TCCR[2] &  w_CNT_OVF_FLG) ? 1'b1 : TCST[0]};		// Overflow 		Interrupt
		end
	end
end
//---------------------------------------------------------
// Acknowledge and Output Data Generation
//---------------------------------------------------------
assign o_bus_data =  r_obus_data;
assign o_bus_ack  =  (r_ack) ? 1'b1 : 1'b0;
//---------------------------------------------------------


//---------------------------------------------------------
// TOP Value Setting  	//	The Counter counting until reaches this value
//---------------------------------------------------------	
reg [15:0] TOP;			//  If WMOD is Normal Counter counting until MAX
//---------------------------------------------------------
always @(posedge i_sysclk) 
begin
	if (i_sysrst)
		TOP <= MAX;								// Default value
	else 
	begin
		case (TCCR2[11:8])						// TOP values - Control Register 2 [11:8] 
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
//---------------------------------------------------------


//---------------------------------------------------------
// COMPARE_PWM Value Setting								// In PWM mode the output toggles when the counter
//---------------------------------------------------------	// reaches this value
reg [15:0] COMPARE_PWM;
//---------------------------------------------------------
always @(posedge i_sysclk) 
begin
	if (i_sysrst)
		COMPARE_PWM <= MAX;						// Default value
	else 
	begin
		case (TCCR2[15:12])						// COMPARE_PWM values - Control Register 2 [15:12] 
		  	OCR_V 	: COMPARE_PWM <= OCR;
		  	ICR_V 	: COMPARE_PWM <= i_cap_cnt_data;
		  	BIT08  	: COMPARE_PWM <= 16'h00FF;
		  	BIT09  	: COMPARE_PWM <= 16'h01FF;
		  	BIT10  	: COMPARE_PWM <= 16'h03FF;
		  	BIT11  	: COMPARE_PWM <= 16'h07FF;
		  	BIT12  	: COMPARE_PWM <= 16'h0FFF;
		  	BIT13  	: COMPARE_PWM <= 16'h1FFF;
		  	BIT14  	: COMPARE_PWM <= 16'h3FFF;
		  	BIT15  	: COMPARE_PWM <= 16'h7FFF;
		  	default : COMPARE_PWM <= MAX;
		endcase
	end
end
//---------------------------------------------------------


//---------------------------------------------------------
// Waveform Generation - Control Register [11:8]
//---------------------------------------------------------
//TCCR[8]		WMOD[0]				 Waveform Mode [0]				
//TCCR[9]		WMOD[1]				 Waveform Mode [1]
//TCCR[10]		Output Pin Enable 	(0 - DIS _ 1 - EN)
//TCCR[11]		Output Pin Polarity	(0 - NOR _ 1 - NEG)
//---------------------------------------------------------
// Bit- Waveform Modes 					Flag
//---------------------------------------------------------
// 00 - Normal							CNT_OVF_FLG
// 01 - Compare Inner Counter to TOP	CIC_CMP_FLG
// 10 - Compare Input Capture to TOP 	CIC_CMP_FLG
// 11 - PWM								PWM_CMP_FLG
//---------------------------------------------------------


//---------------------------------------------------------
// Waveform Generation
//---------------------------------------------------------
reg  r_output;
reg  r_cnt_clr_WF;
reg  r_cap_clr_WF;
reg  r_CIC_CMP_FLG;
reg  r_PWM_CMP_FLG;

wire w_CNT_OVF_FLG;
wire w_CIC_CMP_FLG;
wire w_PWM_CMP_FLG;
//---------------------------------------------------------
always @(posedge i_sysclk) 
begin
	if (i_sysrst)
	begin 
		r_output 		<= 0;
		r_CIC_CMP_FLG 	<= 0;
		r_PWM_CMP_FLG 	<= 0;
		r_cnt_clr_WF 	<= 0;
		r_cap_clr_WF 	<= 0;
	end
	else
	begin
		if (TCCR[0] && (TCCR[6] || TCCR[7])) 				// Global Enable & (Counting or Input Capture Enable) 
		begin
			case (TCCR[9:8])								// Waveform Generation Modes
			  	NORMAL 	: begin 							// Normal Mode
			  				r_cnt_clr_WF  <= 0;				// Never Clear Counter from Waveform
			  				r_cap_clr_WF  <= 0;				// Never Clear Input Capture from Waveform
			  				if((i_cnt_data == MAX)  		// If Counter reached MAX
			  					&& i_prs_sclk_rise) 		// and Prescaler Rising Edge			
			  					r_output  <= 1; 			// Output impulse On MAX
			  				else 							
			  					r_output  <= 0;				// Output 0
			  			  end
			  	COMC 	: begin 							// Counter Compare Mode
			  				r_cap_clr_WF  <= 0;				// Never Clear Input Capture from Waveform
			  				if(i_cnt_data == TOP) 			// If Counter reaches TOP value
			  				begin
			  					r_CIC_CMP_FLG <= 1; 		// Compare Flag  1
			  					r_cnt_clr_WF  <= 1;			// Counter Clear 1
			  					if (i_prs_sclk_rise)		// and Prescaler Rising Edge
			  						r_output <= ~r_output; 	// Output toggles
			  				end
			  				else
			  				begin 							
			  					r_CIC_CMP_FLG <= 0;			// Compare Flag  0
			  			  		r_cnt_clr_WF  <= 0;			// Counter Clear 0
			  			  	end
			  			  end
			  	COMI 	: begin 							// Input Capture Compare Mode 
			  				r_cnt_clr_WF  <= 0;				// Never Clear Counter from Waveform
			  				if((i_cap_cnt_data == TOP) 		// If Input Capture Reaches TOP value
			  				  && (~r_cap_clr_WF))
			  				begin
			  					
			  					r_CIC_CMP_FLG <= 1; 		// Compare Flag 1
			  					r_cap_clr_WF  <= 1;			// Capture Clear Waveform 1
			  				end
			  				else 							
			  				begin 								
			  					r_CIC_CMP_FLG <= 0;			// Compare Flag 0
			  			  		r_cap_clr_WF  <= 0;			// Capture Clear Waveform 0
			  			  		if(r_cap_clr_WF)
			  			  			r_output <= ~r_output; 		// Output toggles
			  			  	end
			  			  end
			  	PWM 	: begin 							// PWM mode
			  				if(i_cnt_data == TOP) 			// If Counter reaches TOP value
			  				begin
			  					r_CIC_CMP_FLG <= 1; 		// Compare Flag  1
			  					r_cnt_clr_WF  <= 1;			// Counter Clear 1
			  				end
			  				else
			  				begin 							
			  					r_CIC_CMP_FLG <= 0;			// Compare Flag  0
			  			  		r_cnt_clr_WF  <= 0;			// Counter Clear 0
			  			  	end
			  				if((i_cap_cnt_data == TOP)
			  					&& (~r_cap_clr_WF))   		// If Input Capture Reaches TOP value
			  				begin
			  					r_cap_clr_WF  <= 1;			// Capture Clear Waveform 1
			  				end
			  				else 							
			  				begin 								
			  			  		r_cap_clr_WF  <= 0;			// Capture Clear Waveform 0
			  			  	end
			  				if (((i_cnt_data < COMPARE_PWM)
			  				 	|| ((i_cnt_data == COMPARE_PWM)
			  					&& (~i_prs_sclk_rise)))
			  					|| ((i_cnt_data == TOP)
			  					&& (i_prs_sclk_rise)))		// If Counter is smaller or equal to COMPARE_PWM value 
			  					r_output <= 1; 				// Output 1
			  				else 							
			  					r_output <= 0; 				// Output 0
			  				if(i_cnt_data == COMPARE_PWM)	// If Counter is equal to COMPARE_PWM
			  					r_PWM_CMP_FLG <= 1; 		// Compare Flag 1
			  				else 							
			  					r_PWM_CMP_FLG <= 0; 		// Compare Flag 0
			  			  end
			endcase
			if (~TCCR[10]) 									// If Output Pin disabled
				r_output <= 0; 								// Output Pin Register Cleared 
		end
	end
end
//---------------------------------------------------------
assign o_out_pin = ( (TCCR[10] && r_output) ^ TCCR[11]);	// (Output Pin Enabled and Output Reg) XOR Output Polarity
//---------------------------------------------------------

//---------------------------------------------------------
// Single Period Generation
//---------------------------------------------------------

//---------------------------------------------------------

//---------------------------------------------------------
// Overflow Interrupt Signal
//---------------------------------------------------------
reg r_CNT_OVF;
//---------------------------------------------------------
always @(posedge i_sysclk) 
begin
	if (i_sysrst) begin
		r_CNT_OVF <= 0;
	end
	else
	begin 
		if(i_cnt_data == MAX) 								// If Counter reached MAX
			r_CNT_OVF <= 1; 								// Overflow Flag 1					
		else
			r_CNT_OVF <= 0;									// Overflow Flag 0					
	end
end
//---------------------------------------------------------
assign w_CNT_OVF_FLG = (r_CNT_OVF && i_prs_sclk_rise);		// Overflow Flag when Counter Reaches BOTTOM value
assign w_CIC_CMP_FLG =   (TCCR[9:8] == NORMAL) ? 1'b0 : 
						((TCCR[9:8] == COMC) 				// Capture Compare Flag
					   ||(TCCR[9:8] == PWM))  ? (r_CIC_CMP_FLG && i_prs_sclk_rise) :
						(TCCR[9:8] == COMI)   ? (r_CIC_CMP_FLG && r_cap_clr_WF): 1'b0;
						
assign w_PWM_CMP_FLG = (r_PWM_CMP_FLG && (i_prs_sclk_rise));// PWM Compare Flag
assign o_int_flg = (|(TCST[3:0]));							// Status Register Interrupt Flags
//---------------------------------------------------------


//---------------------------------------------------------
// Prescaler Control Signals
//---------------------------------------------------------
wire w_prs_block;
assign w_prs_block = (TCST[4] && (TCCR[9:8] != COMI));
assign o_prs_ld = r_prs_ld_signal_BUS;						// Prescaler Load Signal
assign o_prs_ld_data = (r_prs_ld_signal_BUS) 				// if Prescaler Load Signal
					  ? TCCR2[7:0]: 8'b0;					// Load Prescale Value
assign o_prs_en = (TCCR[0] 									// Global Enable
				&& TCCR[6] 									// and Counting Enable
				&& (~r_prs_ld_signal_BUS)
				&& (~w_prs_block)); 	  			//and Not Prescaler Load
//---------------------------------------------------------


//---------------------------------------------------------
// Input Capture Control Signals
//---------------------------------------------------------
wire w_cap_clr;
wire w_cap_block;
assign w_cap_block = (TCST[4] && (TCCR[9:8] == COMI));
assign w_cap_clr = (r_cap_clr_BUS || r_cap_clr_WF); 		// Input Capture Clear from Bus or Waveform
assign o_cap_en  =  (	TCCR[0] && 	TCCR[7] && 	(~w_cap_clr)
						&& (~w_cap_block));							// Global Enable 								// and Input Capture Enable
						  										// and Not Capture Clear
assign o_cap_clr = w_cap_clr;								// Input Capture Clear 				
//---------------------------------------------------------


//---------------------------------------------------------
// Counter Control Signals
//---------------------------------------------------------
wire w_cnt_block;
assign w_cnt_block = (TCST[4] && (TCCR[9:8] != COMI));
assign o_cnt_en  = 	 (TCCR[0] && TCCR[6]  						// Counting Enable
					  && i_prs_sclk_rise  
					  && (~r_cnt_ld_signal_BUS)
					  && (~w_cnt_block));
assign o_cnt_ld  	 = (r_cnt_ld_signal_BUS);						
assign o_cnt_ld_data = (r_cnt_ld_signal_BUS) 
					  ? r_TCNT_data : 16'b0;
assign o_cnt_clr = (r_cnt_clr_WF && i_prs_sclk_rise);						  								
//---------------------------------------------------------
//---------------------------------------------------------
/* !!!!!!    FOR FURTHER USE ONLY   !!!!!!
wire [ 1:0] w_cnt_ld_select;
wire [15:0] w_cnt_ld_data;
assign w_cnt_ld_select = {r_cnt_ld_signal_WF, 
						  r_cnt_ld_signal_BUS};

assign w_cnt_ld_data =  (w_cnt_ld_select == 0) ? 16'b0 : 
						(w_cnt_ld_select == 1) ? r_TCNT_data:
						(w_cnt_ld_select == 2) ? TOP : 16'b0;
assign o_cnt_ld  	 = (|w_cnt_ld_select);								
assign o_cnt_ld_data = (|w_cnt_ld_select) 
					   ? w_cnt_ld_data : 16'b0;

assign o_cnt_en  = 	 (TCCR[0] && TCCR[6]  						// Counting Enable
					  && i_prs_sclk_rise  
					  && ((~r_cnt_ld_signal_BUS) 
					  || (~r_cnt_ld_signal_WF)));
*/
//---------------------------------------------------------

/*
always @(posedge i_sysclk) 
begin
	if (i_sysrst) begin
		
	end
	else if () begin
		
	end
end
*/


//---------------------------------------------------------
endmodule
