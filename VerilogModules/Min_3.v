`timescale 1ns/1ps
module min_3(
  input  wire [7:0] in0,
  input  wire [7:0] in1,
  input  wire [7:0] in2,
  output wire [7:0] min3_out
);
  reg [7:0] min_val;
  always @(*) begin
    min_val = in0;
    if(in1 < min_val) min_val = in1;
    if(in2 < min_val) min_val = in2;
  end
  assign min3_out = min_val;
endmodule
