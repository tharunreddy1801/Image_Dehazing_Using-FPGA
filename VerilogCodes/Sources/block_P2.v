module block_P2(
    input  wire [7:0] in1,
    input  wire [7:0] in2,
    input  wire [7:0] in3,
    input  wire [7:0] in4,
    input  wire [7:0] in5,
    input  wire [7:0] in6,
    input  wire [7:0] in7,
    input  wire [7:0] in8,
    input  wire [7:0] in9,
    
    output wire [7:0] p2_result
    );
    
    wire [15:0] sum;
    assign sum = (in1 * 2) + (in2 * 1) + (in3 * 2) + (in4 * 1) + (in5 * 4) + (in6 * 1) + (in7 * 2) + (in8 * 1) + (in9 * 2);
    
    assign p2_result = sum/16;
    
    endmodule