module block_P2(
    input  wire [7:0] in0,
    input  wire [7:0] in1,
    input  wire [7:0] in2,
    input  wire [7:0] in3,
    input  wire [7:0] in4,
    input  wire [7:0] in5,
    input  wire [7:0] in6,
    input  wire [7:0] in7,
    input  wire [7:0] in8,
    
    output wire [7:0] p2_result
    );
    
    wire [15:0] sum;
    assign sum = (in0 * 2) + (in1 * 1) + (in2 * 2) + (in3 * 1) + (in4 * 4) + (in5 * 1) + (in6 * 2) + (in7 * 1) + (in8 * 2);
    
    assign p2_result = sum/16;
    
    endmodule