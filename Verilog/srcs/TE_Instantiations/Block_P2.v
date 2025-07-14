module block_P2(
    input [7:0]  in1,
    input [7:0]  in2,
    input [7:0]  in3,
    input [7:0]  in4,
    input [7:0]  in5,
    input [7:0]  in6,
    input [7:0]  in7,
    input [7:0]  in8,
    input [7:0]  in9,
    
    output [7:0] p2_result
);
    
    wire [15:0] sum;
    assign sum = (in1 * 2) + (in2 * 1) + (in3 * 2) + (in4 * 1) + (in5 * 4) + (in6 * 1) + (in7 * 2) + (in8 * 1) + (in9 * 2);
    
    assign p2_result = sum >> 4;
    
endmodule
