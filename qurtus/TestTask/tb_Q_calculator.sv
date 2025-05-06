`timescale 1ns/1ps
module tb_Q_calculator;

  parameter int WIDTH      = 16;
  parameter int CLK_PERIOD = 10;
  parameter int NUM_TESTS  = 20;

  logic clk = 0;
  logic rst;
  logic valid_in;
  logic signed [WIDTH-1:0] a, b, c, d;
  logic signed [WIDTH-1:0] Q;
  logic valid_out;

  Q_calculator #(.WIDTH(WIDTH)) dut (
    .clk       (clk),
    .rst       (rst),
    .valid_in  (valid_in),
    .a         (a),
    .b         (b),
    .c         (c),
    .d         (d),
    .Q         (Q),
    .valid_out (valid_out)
  );

  always #(CLK_PERIOD/2) clk = ~clk;

  typedef struct packed {
    logic signed [WIDTH-1:0] a, b, c, d;
  } tv_t;

  tv_t tests[NUM_TESTS] = '{
    '{-74, -34,  20,  58},
    '{-72,  -6,  23,  96},
    '{ 78,  29,  16, -67},
    '{ 37,  27,   6, -35},
    '{  6, -87,  15,  20},
    '{  3, -99, -85,  77},
    '{-46,  35, -28, -61},
    '{ 32,  89, -61, -14},
    '{-56, -48, -17, -50},
    '{-79,  45, -36, -59},
    '{  5, -97,  79, -73},
    '{-22,  74, -23,  69},
    '{-78,  26,  90, -47},
    '{-63,  50, -20, -95},
    '{ 61,  32,  99,  59},
    '{-58, -89,  67, -96},
    '{-88,  64, -17,  87},
    '{-88, -87,  33, -73},
    '{ 49, -34, -75, -58},
    '{-73, -88,  33, -91}
  };

  function automatic logic signed [WIDTH-1:0] reference
    (input logic signed [WIDTH-1:0] aa,
     input logic signed [WIDTH-1:0] bb,
     input logic signed [WIDTH-1:0] cc,
     input logic signed [WIDTH-1:0] dd);
    reference = ((aa - bb) * (3*cc + 1) - 4*dd) >>> 1;
  endfunction

  logic signed [WIDTH-1:0] exp_Q;
  int i;

  initial begin
    rst = 1;
    valid_in = 0;
    a = 0; b = 0; c = 0; d = 0;
    #(2*CLK_PERIOD);
    rst = 0;

    for (i = 0; i < NUM_TESTS; i++) begin
      a = tests[i].a;
      b = tests[i].b;
      c = tests[i].c;
      d = tests[i].d;
      valid_in = 1;
      @(posedge clk);
      valid_in = 0;

      wait (valid_out == 1);
      exp_Q = reference(a, b, c, d);

      if (Q !== exp_Q)
        $error("FAIL test %0d: exp=%0d got=%0d", i, exp_Q, Q);
      else
        $display("PASS test %0d: Q=%0d", i, Q);

      @(posedge clk);
    end

    $finish;
  end

endmodule