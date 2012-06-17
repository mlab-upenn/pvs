// -------------------------------------------------------------
// 
// File Name: hdlsrc\NA_simple.v
// Created: 2011-11-29 18:11:32
// 
// Generated by MATLAB 7.12 and Simulink HDL Coder 2.1
// 
// -------------------------------------------------------------


// -------------------------------------------------------------
// 
// Module: NA_simple
// Source Path: test_simple_gen/NA_simple
// Hierarchy Level: 1
// 
// -------------------------------------------------------------

`timescale 1 ns / 1 ns

module NA_simple
          (
           clk,
           reset,
           enb,
           inActive,
           Active,
           State,
           NdSt
          );


  input   clk;
  input   reset;
  input   enb;
  input   inActive;
  output  Active;
  output  [7:0] State;  // uint8
  output  [7:0] NdSt;  // uint8

  parameter [15:0] b_TERP_defs = 0;  // uint16
  parameter [15:0] b_TRRP_def = 100;  // uint16
  parameter [15:0] b_Trest_def = 800;  // uint16
  parameter [15:0] b_TERP_start = 320;  // uint16
  parameter [15:0] b_TRRP_start = 100;  // uint16
  parameter [15:0] b_Trest_start = 800;  // uint16
  parameter [15:0] b_Terp_min = 150;  // uint16
  parameter [15:0] b_Terp_max = 300;  // uint16
  parameter IN_ERP = 0, IN_RRP = 1, IN_Rest = 2;

  reg  Memory1_out1;
  wire Memory1_out1_1;
  reg [1:0] is_NodeAutomaton;  // uint8
  reg [15:0] TERP_cur;  // uint16
  reg [15:0] TRRP_cur;  // uint16
  reg [15:0] Trest_cur;  // uint16
  wire node_aut_out1;
  wire [7:0] node_aut_out2;  // uint8
  reg [15:0] TERP_def;  // uint16
  wire [7:0] node_aut_out3;  // uint8
  reg  Active_reg;
  reg [7:0] NdSt_reg;  // uint8
  reg [7:0] state_reg;  // uint8
  reg [1:0] is_NodeAutomaton_next;  // enumerated type (3 enums)
  reg [15:0] TERP_cur_next;  // uint16
  reg [15:0] TRRP_cur_next;  // uint16
  reg [15:0] Trest_cur_next;  // uint16
  reg [15:0] TERP_def_next;  // uint16
  reg  Active_reg_next;
  reg [7:0] NdSt_reg_next;  // uint8
  reg [7:0] state_reg_next;  // uint8
  reg  Memory2_out1;
  wire Memory1_out1_2;
  reg [7:0] Memory3_out1;  // uint8


  assign Memory1_out1_1 = Memory1_out1 | inActive;



  always @(posedge clk or posedge reset)
    begin : SimpleModeling_c2_node_aut_process
      if (reset == 1'b1) begin
        state_reg <= 1'b0;
        Active_reg <= 1'b0;
        Trest_cur <= b_Trest_start;
        TERP_def <= b_TERP_defs;
        TERP_cur <= b_TERP_start;
        TRRP_cur <= b_TRRP_start;
        NdSt_reg <= 1'b0;
        is_NodeAutomaton <= IN_Rest;
      end
      else begin
        if (enb) begin
          is_NodeAutomaton <= is_NodeAutomaton_next;
          TERP_cur <= TERP_cur_next;
          TRRP_cur <= TRRP_cur_next;
          Trest_cur <= Trest_cur_next;
          TERP_def <= TERP_def_next;
          Active_reg <= Active_reg_next;
          NdSt_reg <= NdSt_reg_next;
          state_reg <= state_reg_next;
        end
      end
    end

  always @(is_NodeAutomaton, TERP_cur, TRRP_cur, Trest_cur, Memory1_out1_1, TERP_def, Active_reg, 
      NdSt_reg, state_reg) begin
    TERP_def_next = TERP_def;
    is_NodeAutomaton_next = is_NodeAutomaton;
    TERP_cur_next = TERP_cur;
    TRRP_cur_next = TRRP_cur;
    Trest_cur_next = Trest_cur;
    Active_reg_next = Active_reg;
    NdSt_reg_next = NdSt_reg;
    state_reg_next = state_reg;

    case ( is_NodeAutomaton)
      IN_ERP :
        begin
          if (Memory1_out1_1) begin
            TERP_cur_next = b_Terp_min;
            TERP_def_next = b_Terp_min;
            NdSt_reg_next = 2;
            Active_reg_next = 1'b0;
            is_NodeAutomaton_next = IN_ERP;
          end
          else if ( ! Memory1_out1_1 && (TERP_cur == 0)) begin
            TERP_cur_next = TERP_def;
            NdSt_reg_next = 1'b0;
            Active_reg_next = 1'b0;
            is_NodeAutomaton_next = IN_RRP;
          end
          else begin
            TERP_cur_next = TERP_cur - 1'b1;
            NdSt_reg_next = 1'b0;
            Active_reg_next = 1'b0;
            state_reg_next = 2;
          end
        end
      IN_RRP :
        begin
          if (Memory1_out1_1) begin
            TERP_def_next = b_Terp_min;
            NdSt_reg_next = 3;
            TERP_cur_next = b_Terp_min;
            TRRP_cur_next = b_TRRP_def;
            is_NodeAutomaton_next = IN_ERP;
          end
          else if ( ! Memory1_out1_1 && (TRRP_cur == 0)) begin
            TRRP_cur_next = b_TRRP_def;
            NdSt_reg_next = 1'b0;
            is_NodeAutomaton_next = IN_Rest;
          end
          else begin
            TRRP_cur_next = TRRP_cur - 1'b1;
            state_reg_next = 3;
          end
        end
      IN_Rest :
        begin
          if ( ! Memory1_out1_1 && (Trest_cur == 0)) begin
            Trest_cur_next = b_Trest_def;
            Active_reg_next = 1'b1;
            NdSt_reg_next = 1'b0;
            is_NodeAutomaton_next = IN_ERP;
          end
          else if (Memory1_out1_1) begin
            Trest_cur_next = b_Trest_def;
            TERP_def_next = b_Terp_max;
            TERP_cur_next = b_Terp_max;
            NdSt_reg_next = 1'b1;
            is_NodeAutomaton_next = IN_ERP;
          end
          else begin
            Trest_cur_next = Trest_cur - 1'b1;
            state_reg_next = 1'b1;
          end
        end
      default :
        begin
          Active_reg_next = 1'b0;
          Trest_cur_next = b_Trest_start;
          TERP_def_next = b_TERP_defs;
          TERP_cur_next = b_TERP_start;
          TRRP_cur_next = b_TRRP_start;
          NdSt_reg_next = 1'b0;
          is_NodeAutomaton_next = IN_Rest;
        end
    endcase

  end

  assign node_aut_out1 = Active_reg_next;
  assign node_aut_out2 = NdSt_reg_next;
  assign node_aut_out3 = state_reg_next;



  always @(posedge clk or posedge reset)
    begin : Memory1_process
      if (reset == 1'b1) begin
        Memory1_out1 <= 1'b0;
      end
      else begin
        if (enb) begin
          Memory1_out1 <= node_aut_out1;
        end
      end
    end



  always @(posedge clk or posedge reset)
    begin : Memory2_process
      if (reset == 1'b1) begin
        Memory2_out1 <= 1'b0;
      end
      else begin
        if (enb) begin
          Memory2_out1 <= inActive;
        end
      end
    end



  assign Memory1_out1_2 = Memory1_out1 | Memory2_out1;



  assign Active = Memory1_out1_2;

  assign State = node_aut_out3;

  always @(posedge clk or posedge reset)
    begin : Memory3_process
      if (reset == 1'b1) begin
        Memory3_out1 <= 0;
      end
      else begin
        if (enb) begin
          Memory3_out1 <= node_aut_out2;
        end
      end
    end



  assign NdSt = Memory3_out1;

endmodule  // NA_simple

