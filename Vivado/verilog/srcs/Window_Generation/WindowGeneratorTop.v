module WindowGeneratorTop(
    input         clk,
    input         rst,
    
    input [23:0]  input_pixel,
    input         input_is_valid,

    output [23:0] output_pixel_1,
    output [23:0] output_pixel_2,
    output [23:0] output_pixel_3,
    output [23:0] output_pixel_4,
    output [23:0] output_pixel_5,
    output [23:0] output_pixel_6,
    output [23:0] output_pixel_7,
    output [23:0] output_pixel_8,
    output [23:0] output_pixel_9,
    output        output_is_valid
);

    wire [23:0] dlb_out_1,dlb_out_2,dlb_out_3;
    wire        dlb_out_valid;
    
    Double_LineBuffer Double_LineBuffer(
        .clk(clk),
        .rst(rst),
        
        .input_pixel(input_pixel),
        .input_is_valid(input_is_valid),
    
        .output_pixel_1(dlb_out_1),
        .output_pixel_2(dlb_out_2),
        .output_pixel_3(dlb_out_3),
        .output_is_valid(dlb_out_valid)
    );
    
    WindowGenerator WindowGenerator(
        .clk(clk),
        .rst(rst),
            
        .input_pixel_1(dlb_out_1),
        .input_pixel_2(dlb_out_2),
        .input_pixel_3(dlb_out_3),
        .input_is_valid(dlb_out_valid),
        
        .output_pixel_1(output_pixel_1),
        .output_pixel_2(output_pixel_2),
        .output_pixel_3(output_pixel_3),
        .output_pixel_4(output_pixel_4),
        .output_pixel_5(output_pixel_5),
        .output_pixel_6(output_pixel_6),
        .output_pixel_7(output_pixel_7),
        .output_pixel_8(output_pixel_8),
        .output_pixel_9(output_pixel_9),
        .output_is_valid(output_is_valid)
    );

endmodule
