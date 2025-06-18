`timescale 1ns/1ps
module min_9(
  input  wire [7:0] in0,
  input  wire [7:0] in1,
  input  wire [7:0] in2,
  input  wire [7:0] in3,
  input  wire [7:0] in4,
  input  wire [7:0] in5,
  input  wire [7:0] in6,
  input  wire [7:0] in7,
  input  wire [7:0] in8,
  output wire [7:0] min_out
);

  reg [7:0] min_val;
  always @(*) begin
    min_val = in0;
    if(in1 < min_val) min_val = in1;
    if(in2 < min_val) min_val = in2;
    if(in3 < min_val) min_val = in3;
    if(in4 < min_val) min_val = in4;
    if(in5 < min_val) min_val = in5;
    if(in6 < min_val) min_val = in6;
    if(in7 < min_val) min_val = in7;
    if(in8 < min_val) min_val = in8;
  end
  assign min_out = min_val;
endmodule
