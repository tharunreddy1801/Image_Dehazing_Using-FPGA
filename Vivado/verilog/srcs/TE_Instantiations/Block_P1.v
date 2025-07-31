module block_P1(
    input [7:0]  in1,
    input [7:0]  in2,
    input [7:0]  in3,
    input [7:0]  in4,
    input [7:0]  in5,
    input [7:0]  in6,
    input [7:0]  in7,
    input [7:0]  in8,
    input [7:0]  in9,
    
    output [7:0] p1_result
);
    
    wire [15:0] sum;
    assign sum = in1 + (in2 << 1) + in3 + (in4 << 1) + (in5 << 2) + (in6 << 1) + in7 + (in8 << 1) + in9;
    
    assign p1_result = sum >> 4;
    
endmodule
