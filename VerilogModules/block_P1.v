module block_P1(
    input  wire [7:0] in0,
    input  wire [7:0] in1,
    input  wire [7:0] in2,
    input  wire [7:0] in3,
    input  wire [7:0] in4,
    input  wire [7:0] in5,
    input  wire [7:0] in6,
    input  wire [7:0] in7,
    input  wire [7:0] in8,
    
    output wire [7:0] p1_result
    );
    
    wire [15:0] sum;
    assign sum = in0 + (in1 * 2) + in2 + (in3 * 2) + (in4 * 4) + (in5 * 2) + in6 + (in7 * 2) + in8;
    
    assign p1_result = sum/16;
    
    endmodule