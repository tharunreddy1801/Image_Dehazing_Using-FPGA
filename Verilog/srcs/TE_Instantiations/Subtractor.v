//module Subtractor(
//    input [15:0] a,
//    output [15:0] diff
//);
//    parameter [16:0] One = 17'd65536;
//    parameter [15:0] T0 = 16'd16383;
    
//    assign diff = (a < 16'd49152) ? One - a : T0;
//endmodule

module Subtractor(
    input [15:0]  a,
    output [15:0] diff
);
    parameter signed [16:0] One = 17'd65535; // 1.0 in Q0.16
    parameter [15:0] T0_min = 16'd16384;     // 0.25 in Q0.16
    
    wire signed [16:0] temp_diff = One - {1'b0, a};
    
    assign diff = (temp_diff <= $signed({1'b0, T0_min})) ? T0_min :
                  temp_diff[15:0];
    
endmodule
