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

module TopLevel(

	//////////// CLOCK //////////
	CLOCK_50,

	//////////// LED //////////
	LED,

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	PIN,
	PIN_IN
);

//=======================================================
//  PARAMETER declarations
//=======================================================


//=======================================================
//  PORT declarations
//=======================================================

//////////// CLOCK //////////
input 		          		CLOCK_50;

//////////// LED //////////
output		     [7:0]		LED;

//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
inout 		    [33:0]		PIN;
input 		     [1:0]		PIN_IN;

//=======================================================
//  REG/WIRE declarations
//=======================================================
wire CLOCK_1_5;	// 1.5kHz clock (output of PLL0)
wire NA1out;
wire NA2out;
wire NA3out;
wire NA4out;
wire NA5out;
wire NA6out;
wire NA7out;

wire NA1widened;
wire NA2widened;
wire NA3widened;
wire NA4widened;
wire NA5widened;
wire NA6widened;
wire NA7widened;

wire pace_en;
wire apace_in;
wire vpace_in;
reg apace;
reg vpace;
wire apace_widened;
wire vpace_widened;
wire vhm_apace_input;
wire vhm_vpace_input;
reg apace_latch;
reg vpace_latch;
reg apace_latch_prev;
reg vpace_latch_prev;

reg[31:0] counter = 32'd0;
reg tx_go;
reg tx_go_prev;
wire tx_go_shortened;
reg [7:0] header;
wire transmit_done;
wire tx;

wire tachyLEDout;
wire bradyLEDout;
wire normalLEDout;

wire rx;
wire recv_pulse;
wire [15:0] SA_rest;
wire [15:0] AV_forw;
wire PACen;
wire PVCen;

//=======================================================
//  Structural coding
//=======================================================

// setup PLL for clock division
altpll0 pll0
	(
	.inclk0(CLOCK_50),
	.c0(CLOCK_1_5)
	);

// setup VHM 
case2mod_new heart
          (
           .clk(CLOCK_1_5),
			  .AP(vhm_apace_input),
		     .VP(vhm_vpace_input),
           .SArest(SA_rest),
           .AVforw(AV_forw), 
           .PAC_en(PACen),
           .PVC_en(PVCen),			  
			  .clk_enable(1'b1),
           .NA1Out(NA1out),
           .NA2Out(NA2out),
           .NA3Out(NA3out),
           .NA4Out(NA4out),
           .NA5Out(NA5out),
           .NA6Out(NA6out),
           .NA7Out(NA7out)
          );
		
		  
// widen NA1 pulse	
output_pulse NA1_SA_pulse
          (
           .clk(CLOCK_1_5),
			  .signal_i(NA1out),
			  .signal_o(NA1widened),
          );

// widen NA2 pulse	
output_pulse NA2_pulse
          (
           .clk(CLOCK_1_5),
			  .signal_i(NA2out),
			  .signal_o(NA2widened),
          );
			 
// widen NA3 pulse	
output_pulse NA3_pulse
          (
           .clk(CLOCK_1_5),
			  .signal_i(NA3out),
			  .signal_o(NA3widened),
          );
			 
// widen NA4 pulse	
output_pulse NA4_pulse
          (
           .clk(CLOCK_1_5),
			  .signal_i(NA4out),
			  .signal_o(NA4widened),
          );
			 
// widen NA5 pulse	
output_pulse NA5_pulse
          (
           .clk(CLOCK_1_5),
			  .signal_i(NA5out),
			  .signal_o(NA5widened),
          );
			 
// widen NA6 pulse	
output_pulse NA6_pulse
          (
           .clk(CLOCK_1_5),
			  .signal_i(NA6out),
			  .signal_o(NA6widened),
          );
			 
// widen NA7 pulse	
output_pulse NA7_pulse
          (
           .clk(CLOCK_1_5),
			  .signal_i(NA7out),
			  .signal_o(NA7widened),
          );
			 
// counter increments every heart clk beat
always @(posedge CLOCK_1_5) begin
	counter <= counter + 32'd1;
end
			 
// set up clock serial transmitter for SA node & AP
// Note: NA1out and apace_widened are apparently
// exclusive, although this conclusion does not make sense.
// ANDing with tx_go_shortened makes sure the header is only
// available for 1 cycle
always @(posedge CLOCK_1_5) begin
	tx_go <=  (NA1out | NA3out | apace_latch | vpace_latch) && !tx_go_prev;
	header <= (NA1out && !apace_latch) ? 8'd1 :
				 (!NA1out && apace_latch) ? 8'd2 :
				 (NA1out && apace_latch) ? 8'd3 :
				 (NA3out && !vpace_latch) ? 8'd4 :
				 (!NA3out && vpace_latch) ? 8'd5 :
				 (NA3out && vpace_latch) ? 8'd6 :
				 8'd0;
	tx_go_prev <= tx_go;
end

// set up warning LED for brady/tachycardia
light_up warning_lighter
          (
           .clk(CLOCK_1_5),
			  .header(header),
			  .counter(counter),
			  .tachy_pin(tachyLEDout),
			  .brady_pin(bradyLEDout),
			  .normal_pin(normalLEDout)
          );		 
			 
// shorten the go signal so it's 1 cycle in width
// this prevents simultaneous events of different
// widths from messing up serial					 
/*
rising_edge_detect go_shortener
				(
				 .clk(CLOCK_1_5),
				 .signal(tx_go),
				 .pulse(tx_go_shortened)
				);
*/
					 
clock_transmitter transmitter
          (
           .clk_fast(CLOCK_50),
			  .clk_slow(CLOCK_1_5),
			  .counter(counter),
			  .header(header),
           .go(tx_go),//.go(tx_go_shortened),
			  .TxD(tx),
			  .done(transmit_done)
          );
	
// latch input pace pins with FF
always @(posedge CLOCK_50) begin
	apace <= apace_in;
	vpace <= vpace_in;
end

// one cycle wide pace signals for serial
always @(posedge CLOCK_1_5) begin
	apace_latch <= apace_widened && !apace_latch_prev && pace_en;
	vpace_latch <= vpace_widened && !vpace_latch_prev && pace_en;
	apace_latch_prev <= apace_latch;
	vpace_latch_prev <= vpace_latch;
end

// widen apace pulse
// the widen amount should be less than ERP
pace_catcher #(2) apace_widener
          (
           .clk_fast(CLOCK_50),
			  .clk_slow(CLOCK_1_5),
			  .signal_i(apace),
			  .signal_o(apace_widened),
          );

// widen vpace pulse	
// the widen amount should be less than ERP 
pace_catcher #(2) vpace_widener
          (
           .clk_fast(CLOCK_50),
			  .clk_slow(CLOCK_1_5),
			  .signal_i(vpace),
			  .signal_o(vpace_widened),
          );
		
// only give pace inputs if enabled		
assign vhm_apace_input = apace_widened && pace_en;
assign vhm_vpace_input = vpace_widened && pace_en;
			 
mode_setter ms
          (
           .clk_fast(CLOCK_50),
			  .clk_slow(CLOCK_1_5),
			  .rx(rx),
			  .recv_pulse(recv_pulse),
			  .pace_en(pace_en),
			  .SA_rest(SA_rest),
			  .AV_forw(AV_forw),
			  .PACen(PACen),
			  .PVCen(PVCen)
          );

// assign LEDs
// LED[5..0]: NA6..1 widened
// LED[6]: toggles with serial reception
// LED[7]: toggles with serial transmission
reg LED7_toggle = 0; 
always @(posedge CLOCK_50) begin
	if (transmit_done) LED7_toggle <= LED7_toggle ^ 1;
end
assign LED[0] = apace_widened;
assign LED[1] = vpace_widened;
assign LED[2] = NA1widened;
assign LED[3] = NA2widened;
assign LED[4] = NA3widened;
assign LED[5] = NA7widened;
assign LED[6] = recv_pulse;
assign LED[7] = LED7_toggle;

// assign pins
// PIN_IN[1..0]: vpace, apace
// PIN[0]: tx
// PIN[1]: rx
// PIN[10..4]: NA7..1 widened
assign apace_in = PIN_IN[0];
assign vpace_in = PIN_IN[1];
assign rx = PIN[0];
assign PIN[1] = tx;
assign PIN[4] = NA1widened;
assign PIN[5] = NA2widened; 
assign PIN[6] = NA3widened;
assign PIN[7] = NA4widened; 
assign PIN[8] = NA5widened;
assign PIN[9] = NA6widened; 	
assign PIN[10] = NA7widened;

// warning indicators
assign PIN[16] = !normalLEDout; // active-low
assign PIN[18] = !bradyLEDout; // active-low
assign PIN[20] = !tachyLEDout; // active-low

// debug signals
assign PIN[22] = tx_go;
assign PIN[24] = CLOCK_1_5;
assign PIN[26] = NA1out;
assign PIN[28] = apace_latch;
assign PIN[30] = NA3out;
assign PIN[32] = vpace_latch;
endmodule
