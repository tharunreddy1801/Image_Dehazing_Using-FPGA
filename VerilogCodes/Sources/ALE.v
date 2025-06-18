module ALE (
    input wire clk,
    input wire rst,
    input wire input_valid,    
   
    input wire [23:0] output_pixel_1,
    input wire [23:0] output_pixel_2,
    input wire [23:0] output_pixel_3,
    input wire [23:0] output_pixel_4,
    input wire [23:0] output_pixel_5,
    input wire [23:0] output_pixel_6,
    input wire [23:0] output_pixel_7,
    input wire [23:0] output_pixel_8,
    input wire [23:0] output_pixel_9,
    
    output reg [7:0] o_a_r,
    output reg [7:0] o_a_g,
    output reg [7:0] o_a_b,
    output reg [15:0] o_inv_a_r,
    output reg [15:0] o_inv_a_g,
    output reg [15:0] o_inv_a_b,
    output reg o_valid
);

    // Define pipeline registers
    reg input_valid_r1, input_valid_r2, input_valid_r3;
    
    // Extract RGB components for each pixel
    wire [7:0] p1_r, p1_g, p1_b;
    wire [7:0] p2_r, p2_g, p2_b;
    wire [7:0] p3_r, p3_g, p3_b;
    wire [7:0] p4_r, p4_g, p4_b;
    wire [7:0] p5_r, p5_g, p5_b;
    wire [7:0] p6_r, p6_g, p6_b;
    wire [7:0] p7_r, p7_g, p7_b;
    wire [7:0] p8_r, p8_g, p8_b;
    wire [7:0] p9_r, p9_g, p9_b;
    
    assign p1_r = output_pixel_1[23:16];
    assign p1_g = output_pixel_1[15:8];
    assign p1_b = output_pixel_1[7:0];
    
    assign p2_r = output_pixel_2[23:16];
    assign p2_g = output_pixel_2[15:8];
    assign p2_b = output_pixel_2[7:0];
    
    assign p3_r = output_pixel_3[23:16];
    assign p3_g = output_pixel_3[15:8];
    assign p3_b = output_pixel_3[7:0];
    
    assign p4_r = output_pixel_4[23:16];
    assign p4_g = output_pixel_4[15:8];
    assign p4_b = output_pixel_4[7:0];
    
    assign p5_r = output_pixel_5[23:16];
    assign p5_g = output_pixel_5[15:8];
    assign p5_b = output_pixel_5[7:0];
    
    assign p6_r = output_pixel_6[23:16];
    assign p6_g = output_pixel_6[15:8];
    assign p6_b = output_pixel_6[7:0];
    
    assign p7_r = output_pixel_7[23:16];
    assign p7_g = output_pixel_7[15:8];
    assign p7_b = output_pixel_7[7:0];
    
    assign p8_r = output_pixel_8[23:16];
    assign p8_g = output_pixel_8[15:8];
    assign p8_b = output_pixel_8[7:0];
    
    assign p9_r = output_pixel_9[23:16];
    assign p9_g = output_pixel_9[15:8];
    assign p9_b = output_pixel_9[7:0];
    
    // Stage 1: Min_9 operation for each color channel
    reg [7:0] min_r_p1;
    reg [7:0] min_g_p1;
    reg [7:0] min_b_p1;
    
    // Min_9 combinational logic for red channel
    wire [7:0] min_r_1 = (p1_r < p2_r) ? p1_r : p2_r;
    wire [7:0] min_r_2 = (p3_r < p4_r) ? p3_r : p4_r;
    wire [7:0] min_r_3 = (p5_r < p6_r) ? p5_r : p6_r;
    wire [7:0] min_r_4 = (p7_r < p8_r) ? p7_r : p8_r;
    wire [7:0] min_r_5 = (min_r_1 < min_r_2) ? min_r_1 : min_r_2;
    wire [7:0] min_r_6 = (min_r_3 < min_r_4) ? min_r_3 : min_r_4;
    wire [7:0] min_r_7 = (min_r_5 < min_r_6) ? min_r_5 : min_r_6;
    wire [7:0] min_r = (min_r_7 < p9_r) ? min_r_7 : p9_r;
    
    // Min_9 combinational logic for green channel
    wire [7:0] min_g_1 = (p1_g < p2_g) ? p1_g : p2_g;
    wire [7:0] min_g_2 = (p3_g < p4_g) ? p3_g : p4_g;
    wire [7:0] min_g_3 = (p5_g < p6_g) ? p5_g : p6_g;
    wire [7:0] min_g_4 = (p7_g < p8_g) ? p7_g : p8_g;
    wire [7:0] min_g_5 = (min_g_1 < min_g_2) ? min_g_1 : min_g_2;
    wire [7:0] min_g_6 = (min_g_3 < min_g_4) ? min_g_3 : min_g_4;
    wire [7:0] min_g_7 = (min_g_5 < min_g_6) ? min_g_5 : min_g_6;
    wire [7:0] min_g = (min_g_7 < p9_g) ? min_g_7 : p9_g;
    
    // Min_9 combinational logic for blue channel
    wire [7:0] min_b_1 = (p1_b < p2_b) ? p1_b : p2_b;
    wire [7:0] min_b_2 = (p3_b < p4_b) ? p3_b : p4_b;
    wire [7:0] min_b_3 = (p5_b < p6_b) ? p5_b : p6_b;
    wire [7:0] min_b_4 = (p7_b < p8_b) ? p7_b : p8_b;
    wire [7:0] min_b_5 = (min_b_1 < min_b_2) ? min_b_1 : min_b_2;
    wire [7:0] min_b_6 = (min_b_3 < min_b_4) ? min_b_3 : min_b_4;
    wire [7:0] min_b_7 = (min_b_5 < min_b_6) ? min_b_5 : min_b_6;
    wire [7:0] min_b = (min_b_7 < p9_b) ? min_b_7 : p9_b;
    
    // Stage 2: Min_3 operation across color channels
    reg [7:0] dark_channel_p2;
    wire [7:0] min_rg = (min_r < min_g) ? min_r : min_g;
    wire [7:0] dark_channel = (min_rg < min_b) ? min_rg : min_b;
    
    // For tracking coordinates of maximum dark channel value
    reg [7:0] max_dark_val;
    reg [7:0] max_r, max_g, max_b;
    
    // Stage 3: Compare and update maximum
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all registers
            input_valid_r1 <= 1'b0;
            input_valid_r2 <= 1'b0;
            input_valid_r3 <= 1'b0;
            min_r_p1 <= 8'h00;
            min_g_p1 <= 8'h00;
            min_b_p1 <= 8'h00;
            dark_channel_p2 <= 8'h00;
            max_dark_val <= 8'h00;
            max_r <= 8'h00;
            max_g <= 8'h00;
            max_b <= 8'h00;
            o_a_r <= 8'h00;
            o_a_g <= 8'h00;
            o_a_b <= 8'h00;
            o_inv_a_r <= 16'h0000;
            o_inv_a_g <= 16'h0000;
            o_inv_a_b <= 16'h0000;
            o_valid <= 1'b0;
        end else begin
            // Pipeline stage 1: Min_9 operation
            min_r_p1 <= min_r;
            min_g_p1 <= min_g;
            min_b_p1 <= min_b;
            input_valid_r1 <= input_valid;
            
            // Pipeline stage 2: Min_3 operation
            dark_channel_p2 <= dark_channel;
            input_valid_r2 <= input_valid_r1;
            
            // Pipeline stage 3: Compare with current maximum
            input_valid_r3 <= input_valid_r2;
            
            // Update maximum if current dark channel value is greater
            if (input_valid_r2 && dark_channel_p2 > max_dark_val) begin
                max_dark_val <= dark_channel_p2;
                // Store the corresponding RGB values
                max_r <= p5_r; // Center pixel of the 3x3 window
                max_g <= p5_g;
                max_b <= p5_b;
            end
            
            // Output stage
            o_valid <= input_valid_r3;
            
            o_a_r <= (max_r * 7) >> 3; 
            o_a_g <= (max_g * 7) >> 3;
            o_a_b <= (max_b * 7) >> 3;

        end
    end
    
//    ATM_LUT Inverse_Red(
//        .in_val(o_a_r),
//        .out_val(o_inv_a_r)
//    );
    
//        ATM_LUT Inverse_Green(
//        .in_val(o_a_g),
//        .out_val(o_inv_a_g)
//    );
    
//        ATM_LUT Inverse_Blue(
//        .in_val(o_a_b),
//        .out_val(o_inv_a_b)
//    );
    
endmodule