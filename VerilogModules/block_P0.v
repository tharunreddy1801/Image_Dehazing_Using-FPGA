module block_P0(
    input  wire [7:0] in0,
    input  wire [7:0] in1,
    input  wire [7:0] in2,
    input  wire [7:0] in3,
    input  wire [7:0] in4,
    input  wire [7:0] in5,
    input  wire [7:0] in6,
    input  wire [7:0] in7,
    input  wire [7:0] in8,
    
    output wire [7:0] p0_result
    );
    
    wire [11:0] sum;
    assign sum = in0 + in1 + in2 + in3 + in4 + in5 + in6 + in7 + in8;
    
    assign p0_result = sum/9;
    
    endmodule