module ALE_TE_Top(
    input        clk,
    input        enable,
    input        reset,
    input [23:0] pixel_input,
    input        pixel_valid,
    
    output [7:0] transmission_value,
    output       transmission_ready,
    output       processing_complete
);

    // 3x3 sliding window pixel outputs
    wire [23:0] window_pixel_1, window_pixel_2, window_pixel_3;
    wire [23:0] window_pixel_4, window_pixel_5, window_pixel_6;
    wire [23:0] window_pixel_7, window_pixel_8, window_pixel_9;
    wire        window_data_valid;

    // Sliding window generator instance
    WindowGeneratorTop WindowGenerator (
        .clk(clk),
        .rst(reset),
        .input_pixel(pixel_input),
        .input_is_valid(pixel_valid),
        .output_pixel_1(window_pixel_1),
        .output_pixel_2(window_pixel_2),
        .output_pixel_3(window_pixel_3),
        .output_pixel_4(window_pixel_4),
        .output_pixel_5(window_pixel_5),
        .output_pixel_6(window_pixel_6),
        .output_pixel_7(window_pixel_7),
        .output_pixel_8(window_pixel_8),
        .output_pixel_9(window_pixel_9),
        .output_is_valid(window_data_valid)
    );

    // Atmospheric Light Estimation (ALE) signals
    wire        ale_processing_done;
    wire [7:0]  atmospheric_light_red;
    wire [7:0]  atmospheric_light_green;
    wire [7:0]  atmospheric_light_blue;
    wire [15:0] inverse_atm_red;
    wire [15:0] inverse_atm_green;
    wire [15:0] inverse_atm_blue;
    wire        ale_output_valid;
    wire        ale_enable = (~enable) & window_data_valid;

    // Atmospheric Light Estimation module
    ALE ALE (
        .clk(clk),
        .rst(reset),
        
        .input_is_valid(ale_enable),
        .input_pixel_1(window_pixel_1),
        .input_pixel_2(window_pixel_2),
        .input_pixel_3(window_pixel_3),
        .input_pixel_4(window_pixel_4),
        .input_pixel_5(window_pixel_5),
        .input_pixel_6(window_pixel_6),
        .input_pixel_7(window_pixel_7),
        .input_pixel_8(window_pixel_8),
        .input_pixel_9(window_pixel_9),
        
        .A_R(atmospheric_light_red),
        .A_G(atmospheric_light_green),
        .A_B(atmospheric_light_blue),
        .Inv_A_R(inverse_atm_red),
        .Inv_A_G(inverse_atm_green),
        .Inv_A_B(inverse_atm_blue),
        
        .output_is_valid(ale_output_valid),
        .done(ale_processing_done)
    );

    // Latched atmospheric light values for transmission estimation
    reg [15:0] latched_inverse_atm_red;
    reg [15:0] latched_inverse_atm_green;
    reg [15:0] latched_inverse_atm_blue;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            latched_inverse_atm_red   <= 16'b0;
            latched_inverse_atm_green <= 16'b0;
            latched_inverse_atm_blue  <= 16'b0;
        end else if (ale_processing_done) begin
            latched_inverse_atm_red   <= inverse_atm_red;
            latched_inverse_atm_green <= inverse_atm_green;
            latched_inverse_atm_blue  <= inverse_atm_blue;
        end
    end

    // Transmission Estimation (TE) signals
    wire [7:0] calculated_transmission;
    wire       te_output_valid;
    wire       te_enable = enable & window_data_valid;

    // Transmission Estimation module
    TE TE (
        .clk(clk),
        .rst(reset),
        
        .input_is_valid(te_enable),
        .in1(window_pixel_1),
        .in2(window_pixel_2),
        .in3(window_pixel_3),
        .in4(window_pixel_4),
        .in5(window_pixel_5),
        .in6(window_pixel_6),
        .in7(window_pixel_7),
        .in8(window_pixel_8),
        .in9(window_pixel_9),
        
        .inv_ar(latched_inverse_atm_red),
        .inv_ag(latched_inverse_atm_green),
        .inv_ab(latched_inverse_atm_blue),
        
        .transmission(calculated_transmission),
        .output_is_valid(te_output_valid)
    );

    // Output assignments
    assign transmission_value    = calculated_transmission;
    assign transmission_ready    = te_output_valid;
    assign processing_complete   = ale_processing_done;

endmodule
