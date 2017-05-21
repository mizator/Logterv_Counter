`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.05.2017 21:51:00
// Design Name: 
// Module Name: counter
// Project Name: 
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


module counter(	i_clk,	//1 bit
				i_rst,	//1 bit
				i_ce,	//1 bit
				//i_no_operation,	//1 bit ???
				i_counter_mode,	//2 bit
				i_match_mode,	//1 bit
				i_compare_value, // 16 bit
				i_pwm_mode,		//1 bit
				i_load,			//1 bit
				i_load_data,	//16 bit
				i_duty,
				o_counter,		//16 bit
				o_pwm			//1 bit
				//o_interrupt
				);	//1 bit
	
	parameter counter_width = 16;
	
	input	wire		i_clk;
	input	wire		i_rst;
	input	wire		i_ce;
	input	wire		i_no_operation;
	input	wire [1:0]	i_counter_mode;
	input	wire		i_match_mode;
	input	wire	[ counter_width - 1 : 0] i_compare_value;
	input	wire		i_pwm_mode;
	input	wire		i_load;
	input	wire	[ counter_width - 1 : 0] i_load_data;
	input	wire	[ counter_width - 1 : 0] i_duty;
	output	wire	[ counter_width - 1 : 0] o_counter;
	output	wire		o_pwm;
	output	wire		o_interrupt;
    
	reg [counter_width-1:0] r_counter = {counter_width{1'b0}};
	reg	r_pwm = 1'b0;
	wire [35:0] control0;
	wire [35:0] control1;
	

	assign o_counter	= r_counter;
	assign o_pwm		= r_pwm;
	

	always @ (posedge i_clk)
	begin
		if (i_rst)
			 r_counter <= {counter_width{1'b0}};
		else if (i_ce)
			begin
				if (i_load)
					r_counter <= i_load_data;
				else if (i_counter_mode == 2'b00)
				 	begin
				 		if(i_match_mode == 1'b1)
				 			begin
					 			if(r_counter == i_compare_value)
					 				r_counter <= {counter_width{1'b0}};
					 			else begin
					 				r_counter <= r_counter + 1'b1;
					 			end
						end
				 		else begin
							r_counter <= r_counter + 1'b1;
						end
				end
				else if (i_counter_mode == 2'b01)
					begin
				 		if(i_match_mode == 1'b1)
					 		begin
								if(r_counter == {counter_width{1'b0}})
				 					r_counter <= i_compare_value;
					 			else begin
					 				r_counter <= r_counter - 1'b1;
					 			end
						end
						else begin
							r_counter <= r_counter - 1'b1;
						end

				end
		end
	end

	always @ (i_pwm_mode, r_counter, i_duty) // syncronous - posedge i_clk
	begin
		if(i_rst)
			begin
				r_pwm	<= 1'b0;
			end
		else
			begin
				if(i_pwm_mode == 1'b1)
					begin
						if(r_counter < i_duty)
							begin
								r_pwm	<= 1'b1;
						end
						else
							begin
								r_pwm	<= 1'b0;
						end
				end
				else
					begin
						r_pwm	<= 1'b0;
				end
		end
	end
	
    icon icon_cs (
        .CONTROL0(control0), // INOUT BUS [35:0]
        .CONTROL1(control1) // INOUT BUS [35:0]
    );
    
    vio chipscope_vio (
        .CONTROL(control0), // INOUT BUS [35:0]
        .CLK(i_clk), // IN
        .SYNC_IN({  i_duty,
                    i_load_data,
                    i_load,
                    i_compare_value,
                    i_pwm_mode,
                    i_match_mode,
                    i_counter_mode,
                    i_ce,
                    i_rst}) // IN BUS [54:0]
    );
					
        ila chipscope_ila (
        .CONTROL(control1), // INOUT BUS [35:0]
        .CLK(i_clk), // IN
        .TRIG0({i_load,
                i_pwm_mode,
                i_match_mode,
                i_counter_mode,
                i_ce,
                i_rst}), // IN BUS [7:0]
        .TRIG1(i_compare_value), // IN BUS [15:0]
        .TRIG2(i_load_data), // IN BUS [15:0]
        .TRIG3(i_duty), // IN BUS [15:0]
        .TRIG4(o_counter) // IN BUS [15:0]
    );
endmodule
