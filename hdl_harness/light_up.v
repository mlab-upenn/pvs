// Copyright 2012 Sriram Radhakrishnan, Varun Sampath, Shilpa Sarode
// 
// This file is part of PVS.
// 
// PVS is free software: you can redistribute it and/or modify it under the
// terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
// 
// PVS is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License along with
// PVS.  If not, see <http://www.gnu.org/licenses/>.

`timescale 1 ns / 1 ns

// Widens the output signal using COUNT

// inputs: 	
// CLK


// output:	

// parameter: 
// HIGH_PERIOD 

module light_up
          (
           clk,
			  header,
			  counter,
			  tachy_pin,
			  brady_pin,
			  normal_pin
          );
			 
//////////// INPUTS & OUTPUTS ////////////	 
input clk;
input[7:0] header;
input[31:0] counter;
output tachy_pin;
output brady_pin;
output normal_pin;
			 
//////////// PARAMETERS ////////////

parameter FAST_BEAT = 32'd750; // with clk of 1.5kHz corresponds to 120 beats per minute
parameter SLOW_BEAT = 32'd1800; // with clk of 1.5kHz corresponds to 50 beats per minute 
parameter CORRECT_HEAD1 = 8'd4; // RV & !vp
parameter CORRECT_HEAD2 = 8'd6; // RV & vp

//////////// SIGNALS & REGS ////////////

reg brady_flash;
reg tachy_flash;
reg[31:0] counter_previous;

wire[31:0] difference; 
wire correct_header;
wire too_fast;
wire too_slow;

//////////// LOGIC ////////////
assign correct_header = (header == CORRECT_HEAD1 || header == CORRECT_HEAD2);
assign difference = counter - counter_previous;
assign too_fast = difference <= FAST_BEAT;
assign too_slow = difference >= SLOW_BEAT;

always @(posedge clk) begin
	if (correct_header) begin
		tachy_flash <= too_fast;
		brady_flash <= too_slow;
		counter_previous <= counter;
	end
end

led_flasher tachy_flasher
          (
           .clk(clk),
			  .LED_flash(tachy_flash),
			  .LED_out(tachy_pin)
          );
			 
led_flasher brady_flasher
          (
           .clk(clk),
			  .LED_flash(brady_flash),
			  .LED_out(brady_pin)
          );
			 
//////////// OUTPUT ASSIGNS ////////////
assign normal_pin = !tachy_flash && !brady_flash;

endmodule
