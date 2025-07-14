module ALE_Top(
    input         clk,
    input         rst,
    
    // Input pixel stream
    input [23:0]  input_pixel,
    input         input_is_valid,
    
    // Atmospheric Light Values
    output [7:0]  A_R,
    output [7:0]  A_G,
    output [7:0]  A_B,
    
    // Inverse Atmospheric Light Values
    output [15:0] Inv_A_R,
    output [15:0] Inv_A_G,
    output [15:0] Inv_A_B,
    
    // Output valid signal
    output        output_is_valid
);

    wire [23:0] window_pixel_1, window_pixel_2, window_pixel_3;
    wire [23:0] window_pixel_4, window_pixel_5, window_pixel_6;
    wire [23:0] window_pixel_7, window_pixel_8, window_pixel_9;
    wire        window_valid;

    WindowGeneratorTop WindowGenerator (
        .clk(clk),
        .rst(rst),
        .input_pixel(input_pixel),
        .input_is_valid(input_is_valid),
        
        .output_pixel_1(window_pixel_1),
        .output_pixel_2(window_pixel_2),
        .output_pixel_3(window_pixel_3),
        .output_pixel_4(window_pixel_4),
        .output_pixel_5(window_pixel_5),
        .output_pixel_6(window_pixel_6),
        .output_pixel_7(window_pixel_7),
        .output_pixel_8(window_pixel_8),
        .output_pixel_9(window_pixel_9),
        .output_is_valid(window_valid)
    );

    ALE ALE (
        .clk(clk),
        .rst(rst),
        .input_is_valid(window_valid),
        
        .input_pixel_1(window_pixel_1),
        .input_pixel_2(window_pixel_2),
        .input_pixel_3(window_pixel_3),
        .input_pixel_4(window_pixel_4),
        .input_pixel_5(window_pixel_5),
        .input_pixel_6(window_pixel_6),
        .input_pixel_7(window_pixel_7),
        .input_pixel_8(window_pixel_8),
        .input_pixel_9(window_pixel_9),
        
        .A_R(A_R),
        .A_G(A_G),
        .A_B(A_B),
        
        .Inv_A_R(Inv_A_R),
        .Inv_A_G(Inv_A_G),
        .Inv_A_B(Inv_A_B),
        
        .output_is_valid(output_is_valid)
    );

endmodule
