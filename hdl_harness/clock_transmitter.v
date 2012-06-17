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

// Transmits a 4-byte internal counter value using Serial I/O

// inputs: 	
// clk_fast - 50MHz fast clock for serial I/O
//	clk_slow - speed for counter to increment, and transmission interval
// counter - 4-byte counter to transmit
// header - 8-bit header byte for identification
// go - when to transmit (gets latched)

// outputs:	
//	TxD - output serial transmission
// done - goes high when complete (width of clk_slow period)

module clock_transmitter
          (
           clk_fast,
			  clk_slow,
			  counter,
			  header,
           go,
			  TxD,
			  done
          );
			 
input clk_fast;
input clk_slow;
input [31:0] counter;
input [7:0] header;
input go;
output TxD;
output done;

parameter s_idle = 0;
parameter s_transmit_tx = 1;
parameter s_transmit_wait = 2;
parameter s_inc_byte = 3;
parameter s_finish = 4;

reg[3:0] state = 4'd0;
reg[7:0] data = 8'd0;
reg[3:0] byte_count = 4'd0;

reg go_reg = 1'b0;
reg go_reg_prev = 1'b0;
reg [7:0] header_reg = 8'd0;
reg [31:0] transmit_buf = 8'd0;
wire tx_start_pulse;
reg tx_start = 1'b0;
wire tx_busy;
wire tx_out;

// need these "one pulses" to ensure
// transmitter is only started once during wait period
rising_edge_detect tx_detect
(
 .clk(clk_fast),
 .signal(tx_start),
 .pulse(tx_start_pulse)
);

// state machine:
// sits at idle until receives 'go'
// starts transmitting, then waits for transmission to complete
// transmits next 8-bits
// continues until 32 bits transmitted
always @(posedge clk_slow) begin
	case(state)
		s_idle:
		begin
			go_reg <= go & !go_reg_prev;
			// hold onto header throughout transmission; reset in s_finish
			if (header_reg == 8'd0) header_reg <= header;
			state <= (go_reg) ? s_transmit_tx : s_idle;
			transmit_buf <= (go_reg) ? counter : 32'd0;
			byte_count <= 4'd0;
			go_reg_prev <= go_reg;
		end
			
		s_transmit_tx: 
		begin
			tx_start <= (byte_count < 4'd5); 
			data <= (byte_count == 4'd0) ? header_reg :
					  (byte_count == 4'd1) ? transmit_buf[7:0] :
					  (byte_count == 4'd2) ? transmit_buf[15:8] :
					  (byte_count == 4'd3) ? transmit_buf[23:16] :
					  (byte_count == 4'd4) ? transmit_buf[31:24] :
					  8'b0;
			state <= (byte_count < 4'd5) ? s_transmit_wait : s_finish;
		end
		
		s_transmit_wait: 
		begin
			state <= (tx_busy) ? s_transmit_wait : s_inc_byte;
			tx_start <= 0;
		end
					
		s_inc_byte:
		begin
			byte_count <= byte_count + 4'b1;
			state <= s_transmit_tx;
		end
		
		s_finish:
		begin
			state <= s_idle;
			header_reg <= 8'b0;
		end
	endcase
end

// declare transmitter
async_transmitter tx
	(
	.clk(clk_fast), 
	.TxD_start(tx_start_pulse), 
	.TxD_data(data), 
	.TxD(tx_out), 
	.TxD_busy(tx_busy)
	);
		
// assign outputs
assign done = (state == s_finish);
reg TxD;
always @(posedge clk_fast)
		TxD <= (tx_busy) ? tx_out : 1'b1;
			 
endmodule
