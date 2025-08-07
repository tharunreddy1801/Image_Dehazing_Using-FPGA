// Mean Filter when no edges are detected
module Block_P0 (
    input  [7:0] in1,
    input  [7:0] in2,
    input  [7:0] in3,
    input  [7:0] in4,
    input  [7:0] in5,
    input  [7:0] in6,
    input  [7:0] in7,
    input  [7:0] in8,
    input  [7:0] in9,
    
    output [7:0] p0_result
);
    
    wire [11:0] sum;
    assign sum = in1 + in2 + in3 + in4 + in5 + in6 + in7 + in8 + in9;
    
    assign p0_result = sum / 9;
    
endmodule
