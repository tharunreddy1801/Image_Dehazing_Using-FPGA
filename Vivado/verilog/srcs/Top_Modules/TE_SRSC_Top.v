module TE_SRSC_Top (
    input        clk,
    input        rst,
    input [23:0] input_pixel,
    input        input_is_valid,

    output [7:0] J_R,
    output [7:0] J_G,
    output [7:0] J_B,
    
    output       output_valid
);

    // Wires for 3x3 window pixels from WindowGeneratorTop
    wire [23:0] output_pixel_1;
    wire [23:0] output_pixel_2;
    wire [23:0] output_pixel_3;
    wire [23:0] output_pixel_4;
    wire [23:0] output_pixel_5;
    wire [23:0] output_pixel_6;
    wire [23:0] output_pixel_7;
    wire [23:0] output_pixel_8;
    wire [23:0] output_pixel_9;

    wire window_valid;

    // Instance of 3x3 Window Generator
    WindowGeneratorTop dut (
        .clk(clk),
        .rst(rst),
        .input_pixel(input_pixel),
        .input_is_valid(input_is_valid),

        .output_pixel_1(output_pixel_1),
        .output_pixel_2(output_pixel_2),
        .output_pixel_3(output_pixel_3),
        .output_pixel_4(output_pixel_4),
        .output_pixel_5(output_pixel_5),
        .output_pixel_6(output_pixel_6),
        .output_pixel_7(output_pixel_7),
        .output_pixel_8(output_pixel_8),
        .output_pixel_9(output_pixel_9),
        .output_is_valid(window_valid)
    );

  // Instance of design module
  TE_and_SRSC TE_SRSC(
        .clk(clk),
        .rst(rst),
        .input_is_valid(window_valid),

        .in1(output_pixel_1),
        .in2(output_pixel_2),
        .in3(output_pixel_3),
        .in4(output_pixel_4),
        .in5(output_pixel_5),
        .in6(output_pixel_6),
        .in7(output_pixel_7),
        .in8(output_pixel_8),
        .in9(output_pixel_9),
         .A_R('d205),
         .A_G('d207),
         .A_B('d203),
         .Inv_AR('d320), 
         .Inv_AG('d317), 
         .Inv_AB('d323),
         .J_R(J_R),
         .J_G(J_G),
         .J_B(J_B),
        .output_valid(output_valid)
    );

endmodule
