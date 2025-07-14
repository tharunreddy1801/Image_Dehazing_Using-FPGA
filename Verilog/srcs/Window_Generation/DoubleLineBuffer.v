module Double_LineBuffer(
    input         clk,
    input         rst,
    
    input [23:0]  input_pixel,
    input         input_is_valid,

    output [23:0] output_pixel_1,
    output [23:0] output_pixel_2,
    output [23:0] output_pixel_3,
    output        output_is_valid
);

    wire        lb1_valid, lb2_valid;
    wire [23:0] lb1_out, lb2_out;
    
    assign output_pixel_1 = input_pixel;
    assign output_pixel_2 = lb1_out;
    assign output_pixel_3 = lb2_out;
    assign output_is_valid = lb1_valid;

    LineBuffer LB1(
        .clk(clk),
        .rst(rst),
        
        .input_pixel(input_pixel),
        .input_is_valid(input_is_valid),
    
        .output_pixel(lb1_out),
        .output_is_valid(lb1_valid)
    );
    
    LineBuffer LB2(
        .clk(clk),
        .rst(rst),
        
        .input_pixel(lb1_out),
        .input_is_valid(lb1_valid),
    
        .output_pixel(lb2_out),
        .output_is_valid(lb2_valid)
    );
    
endmodule
