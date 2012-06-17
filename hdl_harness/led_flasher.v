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

module led_flasher
          (
           clk,
			  LED_flash,
			  LED_out
          );
			 
//////////// INPUTS & OUTPUTS ////////////	 
input clk;
input LED_flash;
output LED_out;
			 
//////////// PARAMETERS ////////////
parameter HIGH_PERIOD = 600; // with clk of 1.5kHz corresponds to 400ms width
parameter LOW_PERIOD = 600; // with clk of 1.5kHz corresponds to 400ms width

parameter s_reset = 2'd0;
parameter s_off = 2'd1;
parameter s_on = 2'd2;


//////////// SIGNALS & REGS ////////////
reg[15:0] cnt = 0;
reg [1:0] state = 2'd0;

//////////// LOGIC ////////////
always @(posedge clk) begin
		case(state)
			s_reset:
				begin
					cnt  <= 16'd0;
					state <= (LED_flash) ? s_on : s_reset;
				end
			
			s_off: 
				begin
					state <= (cnt == LOW_PERIOD && LED_flash) ? s_on : 
								(!LED_flash) ? s_reset : 
								s_off;
					cnt <= (cnt == LOW_PERIOD && LED_flash) ? 16'd0 : cnt + 16'd1;
				end
			
			s_on: 
				begin
					state <= (cnt == HIGH_PERIOD && LED_flash) ? s_off : 
								(!LED_flash) ? s_reset : 
								s_on;
					cnt <= (cnt == HIGH_PERIOD && LED_flash) ? 16'd0 : cnt + 16'd1;
				end
		endcase
end

//////////// OUTPUT ASSIGNS ////////////
assign LED_out = (state == s_on);

endmodule
