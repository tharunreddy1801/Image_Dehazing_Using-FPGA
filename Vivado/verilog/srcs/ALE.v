// Atmospheric Light Estimation Module
`define Image_Size (512 * 512)
module ALE (
    input         clk,
    input         rst,
    
    input         input_is_valid, // Input data valid signal
    input [23:0]  input_pixel_1,
    input [23:0]  input_pixel_2,
    input [23:0]  input_pixel_3,
    input [23:0]  input_pixel_4,
    input [23:0]  input_pixel_5,
    input [23:0]  input_pixel_6,
    input [23:0]  input_pixel_7,
    input [23:0]  input_pixel_8,
    input [23:0]  input_pixel_9,  // 3x3 window input
    
    output [7:0]  A_R,
    output [7:0]  A_G,
    output [7:0]  A_B,            // Atmospheric Light Values
    
    output [15:0] Inv_A_R,
    output [15:0] Inv_A_G,
    output [15:0] Inv_A_B,        // Inverse Atmospheric Light Values(Q0.16)
    
    output        done            // Signal to indicate entire image has been processed
);

    reg [17:0] pixel_counter;
    reg        done_reg;

    // Keep track of the number of pixels processed through the module
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pixel_counter <= 0;
            done_reg <= 0;
        end
        else if (Stage_2_valid) begin
            pixel_counter <= pixel_counter + 1;
            if (pixel_counter == (`Image_Size - 1)) begin
                done_reg <= 1;                            // All pixels have been processed through the ALE module
            end
        end
    end
    
    // Minimum of 9 - R/G/B channels
    wire [7:0] minimum_red, minimum_green, minimum_blue;
    
    // Pipeline Registers (Stage 1)
    reg [7:0] minimum_red_P, minimum_green_P, minimum_blue_P;
    
    always @(posedge clk) begin
        if(rst) begin
            minimum_red_P <= 8'd0;
            minimum_green_P <= 8'd0;
            minimum_blue_P <= 8'd0;
        end
        else begin
            minimum_red_P <= minimum_red;
            minimum_green_P <= minimum_green;
            minimum_blue_P <= minimum_blue;
        end
    end

    // Dark channel pixel value
    wire [7:0] Dark_channel;
    
    // Pipeline Registers (Stage 2)
    reg [7:0]  Dark_channel_P;
    reg [7:0]  AR_P, AG_P, AB_P;
    reg [15:0] Inv_AR_P, Inv_AG_P, Inv_AB_P;
    
    wire [7:0] Dark_channel_Red, Dark_channel_Green, Dark_channel_Blue;
    
    assign Dark_channel_Red = (Dark_channel > Dark_channel_P) ? minimum_red_P : AR_P;
    assign Dark_channel_Green = (Dark_channel > Dark_channel_P) ? minimum_green_P : AG_P;
    assign Dark_channel_Blue = (Dark_channel > Dark_channel_P) ? minimum_blue_P : AB_P;
    
    // LUT outputs
    wire [15:0] LUT_Inv_AR, LUT_Inv_AG, LUT_Inv_AB;
    
    always @(posedge clk) begin
        if(rst) begin
            Dark_channel_P <= 8'd0;
            
            AR_P <= 8'd0;
            AG_P <= 8'd0;
            AB_P <= 8'd0;
            
            Inv_AR_P <= 16'd0;
            Inv_AG_P <= 16'd0;
            Inv_AB_P <= 16'd0;
        end
        else begin
            Dark_channel_P <= (Dark_channel > Dark_channel_P) ? Dark_channel : Dark_channel_P;
            
            AR_P <= Dark_channel_Red;
            AG_P <= Dark_channel_Green;
            AB_P <= Dark_channel_Blue;
            
            Inv_AR_P <= LUT_Inv_AR;
            Inv_AG_P <= LUT_Inv_AG;
            Inv_AB_P <= LUT_Inv_AB;
        end
    end
    
    // Delay the output valid signal by 2 clock cycles
    reg Stage_1_valid, Stage_2_valid;
    always @(posedge clk)
    begin
        if(rst) begin
            Stage_1_valid <= 0;
            Stage_2_valid <= 0;
        end
        else begin
            Stage_1_valid <= input_is_valid;
            Stage_2_valid <= Stage_1_valid;
        end
    end
    
    // Output wire assignments
    assign A_R = AR_P;
    assign A_G = AG_P;
    assign A_B = AB_P;
    
    assign Inv_A_R = Inv_AR_P;
    assign Inv_A_G = Inv_AG_P;
    assign Inv_A_B = Inv_AB_P;
    
    assign done = done_reg;

    /////////////////////////////////////////////////////////////////////////////////
    // BLOCK INSTANCES
    /////////////////////////////////////////////////////////////////////////////////

    // Find the minimum of each of the color channel inputs
    ALE_Minimum_9 Min_Red (
        .input_pixel_1(input_pixel_1[23:16]), .input_pixel_2(input_pixel_2[23:16]), .input_pixel_3(input_pixel_3[23:16]),
        .input_pixel_4(input_pixel_4[23:16]), .input_pixel_5(input_pixel_5[23:16]), .input_pixel_6(input_pixel_6[23:16]),
        .input_pixel_7(input_pixel_7[23:16]), .input_pixel_8(input_pixel_8[23:16]), .input_pixel_9(input_pixel_9[23:16]),
        
        .minimum_pixel(minimum_red)
    );
    
    ALE_Minimum_9 Min_Green (
        .input_pixel_1(input_pixel_1[15:8]), .input_pixel_2(input_pixel_2[15:8]), .input_pixel_3(input_pixel_3[15:8]),
        .input_pixel_4(input_pixel_4[15:8]), .input_pixel_5(input_pixel_5[15:8]), .input_pixel_6(input_pixel_6[15:8]),
        .input_pixel_7(input_pixel_7[15:8]), .input_pixel_8(input_pixel_8[15:8]), .input_pixel_9(input_pixel_9[15:8]),
        
        .minimum_pixel(minimum_green)
    );
    
    ALE_Minimum_9 Min_Blue (
        .input_pixel_1(input_pixel_1[7:0]), .input_pixel_2(input_pixel_2[7:0]), .input_pixel_3(input_pixel_3[7:0]),
        .input_pixel_4(input_pixel_4[7:0]), .input_pixel_5(input_pixel_5[7:0]), .input_pixel_6(input_pixel_6[7:0]),
        .input_pixel_7(input_pixel_7[7:0]), .input_pixel_8(input_pixel_8[7:0]), .input_pixel_9(input_pixel_9[7:0]),
        
        .minimum_pixel(minimum_blue)
    );
    
    // Calculate minimum among the three channels to get Dark Channel
    ALE_Minimum_3 Dark_Channel (
        .R(minimum_red_P),
        .G(minimum_green_P), 
        .B(minimum_blue_P),
        
        .minimum(Dark_channel)
    );
    
    // Look-Up Tables to output the reciprocal of the Atmospheric Light values in Q0.16 format
    ATM_LUT Inverse_Red (
        .in_val(Dark_channel_Red),
        
        .out_val(LUT_Inv_AR)
    );
    
    ATM_LUT Inverse_Green (
        .in_val(Dark_channel_Green),
        
        .out_val(LUT_Inv_AG)
    );
    
    ATM_LUT Inverse_Blue (
        .in_val(Dark_channel_Blue),
        
        .out_val(LUT_Inv_AB)
    );
    
endmodule
