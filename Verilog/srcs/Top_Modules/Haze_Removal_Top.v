module Haze_Removal_Top(

    // AXI4-Stream Global Signals
    input         ACLK,
    input         ARESETn,
    
    // Enable Signal
    input         enable,
    
    // AXI4-Stream Slave Interface
    input [31:0]  S_AXIS_TDATA,
    input         S_AXIS_TVALID,
    input         S_AXIS_TLAST,
    output        S_AXIS_TREADY,
    
    // AXI4-Stream Master Interface
    output [31:0] M_AXIS_TDATA,
    output        M_AXIS_TVALID,
    output        M_AXIS_TLAST,
    input         M_AXIS_TREADY
);
    
    wire ALE_clk, TE_SRSC_clk;
    
    assign S_AXIS_TREADY = 1'b1; // Always ready to accept data
    assign M_AXIS_TLAST = 1'b0; // Continuous stream

    // 3x3 Window of RGB pixels generated from Line Buffers
    wire [23:0] Pixel_00, Pixel_01, Pixel_02;
    wire [23:0] Pixel_10, Pixel_11, Pixel_12;
    wire [23:0] Pixel_20, Pixel_21, Pixel_22;
    
    // Window valid signal
    wire window_valid;

    // Instance of 3x3 Window Generator
    WindowGeneratorTop WindowGenerator (
        .clk(ACLK),
        .rst(~ARESETn),
        
        .input_pixel(S_AXIS_TDATA),
        .input_is_valid(S_AXIS_TVALID & S_AXIS_TREADY),
        
        .output_pixel_1(Pixel_00), .output_pixel_2(Pixel_01), .output_pixel_3(Pixel_02),
        .output_pixel_4(Pixel_10), .output_pixel_5(Pixel_11), .output_pixel_6(Pixel_12),
        .output_pixel_7(Pixel_20), .output_pixel_8(Pixel_21), .output_pixel_9(Pixel_22),
        .output_is_valid(window_valid)
    );
    
    wire [7:0] A_R, A_G, A_B;
    wire [15:0] Inv_AR, Inv_AG, Inv_AB;
    
    wire ALE_done;
    wire ALE_enable = ~ALE_done & enable;

    // Atmospheric Light Estimation
    ALE ALE (
        .clk(ALE_clk),
        .rst(~ARESETn),
        
        .input_is_valid(window_valid & ALE_enable),
        .input_pixel_1(Pixel_00), .input_pixel_2(Pixel_01), .input_pixel_3(Pixel_02),
        .input_pixel_4(Pixel_10), .input_pixel_5(Pixel_11), .input_pixel_6(Pixel_12),
        .input_pixel_7(Pixel_20), .input_pixel_8(Pixel_21), .input_pixel_9(Pixel_22),
        
        .A_R(A_R), .A_G(A_G), .A_B(A_B),
        
        .Inv_A_R(Inv_AR), .Inv_A_G(Inv_AG), .Inv_A_B(Inv_AB),
        
        .done(ALE_done)
    );

    // Final registers for ALE output
    reg [7:0] Final_A_R, Final_A_G, Final_A_B;
    reg [15:0] Final_Inv_AR, Final_Inv_AG, Final_Inv_AB;

    always @(posedge ACLK or negedge ARESETn) begin
        if (~ARESETn) begin
            Final_A_R <= 0; Final_A_G <= 0; Final_A_B <= 0;
            
            Final_Inv_AR <= 0; Final_Inv_AG <= 0; Final_Inv_AB <= 0;
        end else if (ALE_done) begin
            Final_A_R <= A_R; Final_A_G <= A_G; Final_A_B <= A_B;
            
            Final_Inv_AR <= Inv_AR; Final_Inv_AG <= Inv_AG; Final_Inv_AB <= Inv_AB;
        end
    end

    wire [7:0] J_R, J_G, J_B;
    assign M_AXIS_TDATA = {8'h00, J_R, J_G, J_B};

    wire TE_SRSC_enable = ALE_done & enable;
    wire TE_SRSC_done;
    
    // Transmission Estimation, Scene Recovery and Saturation Correction
    TE_and_SRSC TE_SRSC (
        .clk(TE_SRSC_clk),
        .rst(~ARESETn),
        
        .input_is_valid(window_valid & TE_SRSC_enable),
        .in1(Pixel_00), .in2(Pixel_01), .in3(Pixel_02),
        .in4(Pixel_10), .in5(Pixel_11), .in6(Pixel_12),
        .in7(Pixel_20), .in8(Pixel_21), .in9(Pixel_22),
        
        .A_R(Final_A_R), .A_G(Final_A_G), .A_B(Final_A_B),
        
        .Inv_AR(Final_Inv_AR), .Inv_AG(Final_Inv_AG), .Inv_AB(Final_Inv_AB),
        
        .J_R(J_R), .J_G(J_G), .J_B(J_B),
        .output_valid(M_AXIS_TVALID),
        
        .done(TE_SRSC_done)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Clock Gating Cell Instantiations for ALE AND TE_SRSC
    ///////////////////////////////////////////////////////////////////////////////////////////////////

    Clock_Gating_Cell ALE_CGC(
        .clk(ACLK),
        .clk_enable(ALE_enable),
        .rstn(~ARESETn),
        
        .clk_gated(ALE_clk)
    );
    
    Clock_Gating_Cell TE_SRSC_CGC(
        .clk(ACLK),
        .clk_enable(TE_SRSC_enable),
        .rstn(~ARESETn),
        
        .clk_gated(TE_SRSC_clk)
    );

endmodule

///////////////////////////////////////////////////////////////////////////////////////////////////
// Clock Gating Cell for power saving
///////////////////////////////////////////////////////////////////////////////////////////////////
// module Clock_Gating_Cell(
//     input  clk,
//     input  clk_enable,
//     input  rstn,
    
//     output clk_gated
// );
    
//     reg latch;
    
//     always @(posedge clk) begin
//         if (rstn)
//             latch <= 1'b0;
//         else
//             latch <= clk_enable;
//     end

//     assign clk_gated = latch & clk;

// endmodule

module Clock_Gating_Cell (
    input clk,        // Input clock
    input clk_enable,    // Enable signal for clock gating
    input rstn,          // Active-low reset
    output clk_gated       // Output gated clock
);
// try to use asynchronous reset assertion and deassertion make sure to be synchronouse of main clock. so here rstn usage is useless.
    // BUFGCE for clock enable functionality (automatic clock gating)
    BUFGCE u_bufgce (
        .I(clk),       // Input clock
        .CE(clk_enable),  // Clock enable signal to gate the clock
        .O(clk_gated)       // Output gated clock
    );

endmodule







// module Haze_Removal_Top (
//     input         clk,
//     input         rst,
//     input         enable,
    
//     input [23:0]  input_pixel,
//     input         input_is_valid,

//     output [23:0] output_pixel,
//     output        output_is_valid
// );

//     // 3x3 Window of RGB pixels generated from Line Buffers
//     wire [23:0] Pixel_00, Pixel_01, Pixel_02;
//     wire [23:0] Pixel_10, Pixel_11, Pixel_12;
//     wire [23:0] Pixel_20, Pixel_21, Pixel_22;
    
//     // Window valid signal
//     wire window_valid;

//     // Instance of 3x3 Window Generator
//     WindowGeneratorTop WindowGenerator (
//         .clk(clk),
//         .rst(rst),
        
//         .input_pixel(input_pixel),
//         .input_is_valid(input_is_valid),
        
//         .output_pixel_1(Pixel_00), .output_pixel_2(Pixel_01), .output_pixel_3(Pixel_02),
//         .output_pixel_4(Pixel_10), .output_pixel_5(Pixel_11), .output_pixel_6(Pixel_12),
//         .output_pixel_7(Pixel_20), .output_pixel_8(Pixel_21), .output_pixel_9(Pixel_22),
//         .output_is_valid(window_valid)
//     );
    
//     wire [7:0]  A_R, A_G, A_B;
//     wire [15:0] Inv_AR, Inv_AG, Inv_AB;
//     wire        ALE_done;

//     wire ALE_enable = (~enable) & window_valid;

//     // Atmospheric Light Estimation
//     ALE ALE (
//         .clk(clk),
//         .rst(rst),
        
//         .input_is_valid(ALE_enable),
//         .input_pixel_1(Pixel_00), .input_pixel_2(Pixel_01), .input_pixel_3(Pixel_02),
//         .input_pixel_4(Pixel_10), .input_pixel_5(Pixel_11), .input_pixel_6(Pixel_12),
//         .input_pixel_7(Pixel_20), .input_pixel_8(Pixel_21), .input_pixel_9(Pixel_22),
        
//         .A_R(A_R), .A_G(A_G), .A_B(A_B),
        
//         .Inv_A_R(Inv_AR), .Inv_A_G(Inv_AG), .Inv_A_B(Inv_AB),
        
//         .done(ALE_done)
//     );

//     // Final registers for ALE output
//     reg [7:0]  Final_A_R, Final_A_G, Final_A_B;
//     reg [15:0] Final_Inv_AR, Final_Inv_AG, Final_Inv_AB;

//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             Final_A_R <= 0; Final_A_G <= 0; Final_A_B <= 0;
            
//             Final_Inv_AR <= 0; Final_Inv_AG <= 0; Final_Inv_AB <= 0;
//         end else if (ALE_done) begin
//             Final_A_R <= A_R; Final_A_G <= A_G; Final_A_B <= A_B;
            
//             Final_Inv_AR <= Inv_AR; Final_Inv_AG <= Inv_AG; Final_Inv_AB <= Inv_AB;
//         end
//     end

//     wire [7:0] J_R, J_G, J_B;
//     assign output_pixel = {J_R, J_G, J_B};

//     wire TE_SRSC_enable = enable & window_valid;
    
//     // Transmission Estimation, Scene Recovery and Saturation Correction
//     TE_and_SRSC TE_SRSC (
//         .clk(clk),
//         .rst(rst),
        
//         .input_is_valid(TE_SRSC_enable),
//         .in1(Pixel_00), .in2(Pixel_01), .in3(Pixel_02),
//         .in4(Pixel_10), .in5(Pixel_11), .in6(Pixel_12),
//         .in7(Pixel_20), .in8(Pixel_21), .in9(Pixel_22),
        
//         .A_R(Final_A_R), .A_G(Final_A_G), .A_B(Final_A_B),
        
//         .Inv_AR(Final_Inv_AR), .Inv_AG(Final_Inv_AG), .Inv_AB(Final_Inv_AB),
        
//         .J_R(J_R), .J_G(J_G), .J_B(J_B),
        
//         .output_valid(output_is_valid)
//     );

// endmodule
