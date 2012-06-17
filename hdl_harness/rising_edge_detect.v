// from http://hdlsnippets.com/verilog_rising_edge_detect
module rising_edge_detect
(
 input  clk,
 input  signal,
 output pulse
);
 
reg     signal_prev;
 
always @(posedge clk) signal_prev <= signal;
 
assign pulse = signal & ~signal_prev;
 
endmodule