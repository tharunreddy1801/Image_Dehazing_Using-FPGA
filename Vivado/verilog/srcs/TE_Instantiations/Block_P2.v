// Edge Preserving Filter for Diagonal Edges
module Block_P2 (
    input  [7:0] in1,
    input  [7:0] in2,
    input  [7:0] in3,
    input  [7:0] in4,
    input  [7:0] in5,
    input  [7:0] in6,
    input  [7:0] in7,
    input  [7:0] in8,
    input  [7:0] in9,
    
    output [7:0] p2_result
);
    
    wire [11:0] sum;
    assign sum = (in1 << 1) + (in2) + (in3 << 1) + (in4) + (in5 << 2) + (in6) + (in7 << 1) + (in8) + (in9 << 1);
    
    assign p2_result = sum >> 4;
    
endmodule
