`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 		GA
// 
// Create Date:    	10:00:00 05/22/2017 
// Design Name: 	16-bit counter
// Module Name:    	counter_if_tb
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
module counter_if_tb;
// Inputs
	reg 			clk;
    reg 			rst;

	reg 			cap_pin;
	wire 			cout_pin;
	reg 			bus_select;
	reg 			bus_wr;

	reg		[3:0]	i_reg_addr;
	reg		[15:0]	i_bus_data;
	wire	[15:0]	o_bus_data;
	wire 			o_int_flg;
	wire 			o_bus_ack;

parameter   ADDR_TCCR = 4'b0001;
parameter   ADDR_TCNT = 4'b0010;
parameter   ADDR_OCR = 4'b0011;
parameter   ADDR_ICR = 4'b0100;
parameter   ADDR_TCST = 4'b0101;
parameter   ADDR_TCCR2 = 4'b0110; 

//---------------------------------------------
// Instantiate the Unit Under Test (UUT)
//---------------------------------------------
counter_if uut(	
	.i_sysclk(clk),		// System Clock
	.i_sysrst(rst),		// System Reset

	.i_cap_pin(cap_pin),	// Input Capture Pin
	.o_cout_pin(cout_pin),	// Output Capture Pin

	.i_bus_select(bus_select),	// Select Periphery
	.i_bus_wr(bus_wr),		// Bus Write
	.i_reg_addr(reg_addr),	// Register Address
	.i_bus_data(i_bus_data),	// Data input
	.o_bus_data(o_bus_data),	// Data output
	.o_bus_ack(bus_ack),
	.o_int_flg(int_flg)
);
//-----------------------------------------------

//-----------------------------------------------
// Bus Write
//-----------------------------------------------
task bus_write (input [3:0] reg_addr, input [15:0] bus_data);
begin
	#10 i_reg_addr 	<= reg_addr;
		i_bus_data 	<= bus_data;
		bus_wr 		<= 1'b1;
		bus_select 	<= 1'b1;
	wait(bus_ack);
	#10 bus_wr 		<= 1'b0;
		bus_select 	<= 1'b0;
end
endtask
//-----------------------------------------------

//-----------------------------------------------
// Bus Read
//-----------------------------------------------
task bus_read (input [3:0] reg_addr);
begin
	#10 i_reg_addr 	<= reg_addr;
		bus_wr 		<= 1'b0;
		bus_select 	<= 1'b1;
	wait(bus_ack);
	#10 bus_wr 		<= 1'b0;
		bus_select 	<= 1'b0;
end
endtask
//---------------------------------------------


initial begin
	// Initialize Inputs
	clk = 1;
    rst = 1;
    cap_pin = 0;
    #102 rst = 0; 
    bus_write(ADDR_TCCR, 16'b0000_1111_0000_0001);
    bus_read (ADDR_TCCR);
end

always #40 cap_pin = ~cap_pin;

//---------------------------------------------
// Generate clock
//---------------------------------------------
always #5 clk = ~clk;
//---------------------------------------------


endmodule
