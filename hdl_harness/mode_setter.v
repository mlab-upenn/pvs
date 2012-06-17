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

// receives mode to switch via serial
// bit order:
// first 15-bits: SA_rest (little-endian)
// next 1-bit: pace_en
// next 14-bits: AV_forw (little-endian)
// next 1-bit: PACen
// next 1-bit: PVCen
// total: 32-bits, 4 byte transmission

// DEFAULT CONFIGURATION
// SA_rest = 700
// pace_en = 1
// AV_forw = 200
// PACen = 0
// PVCen = 0
// KEEP IN MIND THE VHM DOES NOT REGISTER THESE INPUTS! (so this should!)

module mode_setter
          (
           clk_fast,
			  clk_slow,
			  rx,
			  recv_pulse,
			  pace_en,
			  SA_rest,
			  AV_forw,
			  PACen,
			  PVCen,
          );
			 
//////////// INPUTS & OUTPUTS ////////////	 
input clk_fast;
input clk_slow;
input rx;
output recv_pulse;
output pace_en;
output [15:0] SA_rest;
output [15:0] AV_forw;
output  PACen;
output  PVCen;
			 
//////////// PARAMETERS ////////////
parameter s_idle = 1'b0;
parameter s_out = 1'b1;
parameter CLOCK_RATIO = 16'd33334; // 50MHz / 1.5kHz
parameter NUM_BYTES = 4'd4; // two for SA_rest, two for AV_forw

//////////// SIGNALS & REGS ////////////
wire [7:0] recv_data; // data from receiver
wire recv_data_ready; // data ready from receiver (1 clock pulse)
reg [7:0] recv_data_reg; // data latched from reg

reg state; // state machine for determining if output is ready
reg recv_pulse_reg = 1'b0; // output ready pulse, used for reset by heart
reg [15:0] SA_rest_reg = 16'd900; // DEFAULT CASE
reg [15:0] SA_rest_temp_reg = 16'd900;
reg pace_en_reg = 1'b1;		// DEFAULT CASE
reg pace_en_temp_reg = 1'b1;
reg [15:0] AV_forw_reg = 16'd50; // DEFAULT CASE
reg [15:0] AV_forw_temp_reg = 16'd50;
reg PACen_reg = 1'd0; // DEFAULT CASE
reg PACen_temp_reg = 1'd0;
reg PVCen_reg = 1'd0; // DEFAULT CASE
reg PVCen_temp_reg = 1'd0;
reg [15:0] cnt = 16'd0; // counter to keep signals stable
reg [3:0] byte_cnt = 4'd0; // cnt of bytes received so far

//////////// LOGIC ////////////
async_receiver receiver 
			(
			.clk(clk_fast), 
			.RxD(rx), 
			.RxD_data_ready(recv_data_ready), 
			.RxD_data(recv_data), 
			//.RxD_endofpacket, 
			//.RxD_idle
			);
	
always @(posedge clk_fast) begin
		case(state)
			s_idle:
			begin
				state <= (byte_cnt >= NUM_BYTES) ? s_out : s_idle;
				// recv_pulse, PACen, and PVCen should only be 1 cycle wide
				recv_pulse_reg <= 1'b0;
				PACen_reg <= 1'b0;
				PVCen_reg <= 1'b0;
				// = instead of <= on purpose from here
				recv_data_reg = recv_data;
				if (recv_data_ready && byte_cnt == 4'd0) begin
					SA_rest_temp_reg[7:0] = recv_data_reg;
				end
				else if (recv_data_ready && byte_cnt == 4'd1) begin
					SA_rest_temp_reg[14:8] = recv_data_reg[6:0];
					SA_rest_temp_reg[15] = 1'b0;
					pace_en_temp_reg = recv_data_reg[7];
				end
				else if (recv_data_ready && byte_cnt == 4'd2) begin
					AV_forw_temp_reg[7:0] = recv_data_reg;
				end
				else if (recv_data_ready && byte_cnt == 4'd3) begin
					AV_forw_temp_reg[15:8] = {2'b0,recv_data_reg[5:0]};
					PACen_temp_reg = recv_data_reg[6];
					PVCen_temp_reg = recv_data_reg[7];
				end
				cnt <= 16'd0;
				if (recv_data_ready)
					byte_cnt <= byte_cnt + 4'd1;
			end
			s_out:
			begin
				state <= (cnt >= CLOCK_RATIO) ? s_idle : s_out;
				recv_pulse_reg <= 1'b1;
				SA_rest_reg <= SA_rest_temp_reg;
				pace_en_reg <= pace_en_temp_reg;
				AV_forw_reg <= AV_forw_temp_reg;
				PACen_reg <= PACen_temp_reg;
				PVCen_reg <= PVCen_temp_reg;
				cnt <= cnt + 16'd1;
				byte_cnt <= 4'd0;
			end
		endcase
end
			

//////////// OUTPUT ASSIGNS ////////////
assign recv_pulse = recv_pulse_reg;
assign pace_en = pace_en_reg;
assign SA_rest = SA_rest_reg;
assign AV_forw = AV_forw_reg;
assign PACen = PACen_reg;
assign PVCen = PVCen_reg;

endmodule
