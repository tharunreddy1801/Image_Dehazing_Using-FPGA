`timescale 1ns/1ps

module atmospheric_light_top(
    input  wire        clk,
    input  wire        rst,
    
    input  wire [7:0]  Reg_R0, Reg_R1, Reg_R2, Reg_R3, Reg_R4, Reg_R5, Reg_R6, Reg_R7, Reg_R8,
    input  wire [7:0]  Reg_G0, Reg_G1, Reg_G2, Reg_G3, Reg_G4, Reg_G5, Reg_G6, Reg_G7, Reg_G8,
    input  wire [7:0]  Reg_B0, Reg_B1, Reg_B2, Reg_B3, Reg_B4, Reg_B5, Reg_B6, Reg_B7, Reg_B8,

    output wire [7:0]  A_R,
    output wire [7:0]  A_G,
    output wire [7:0]  A_B,
    output wire [8:0]  invA_R,
    output wire [8:0]  invA_G,
    output wire [8:0]  invA_B
);

    //-------------------------------------------------------------------------
    // Stage 2 wires: outputs of Min_9 blocks and pipeline registers
    //-------------------------------------------------------------------------
    wire [7:0] min9_R_out, min9_G_out, min9_B_out;

    // min_9 modules for each color channel
    min_9 u_min9_R(
        .in0(Reg_R0), .in1(Reg_R1), .in2(Reg_R2),
        .in3(Reg_R3), .in4(Reg_R4), .in5(Reg_R5),
        .in6(Reg_R6), .in7(Reg_R7), .in8(Reg_R8),
        .min_out(min9_R_out)
    );
    
    min_9 u_min9_G(
        .in0(Reg_G0), .in1(Reg_G1), .in2(Reg_G2),
        .in3(Reg_G3), .in4(Reg_G4), .in5(Reg_G5),
        .in6(Reg_G6), .in7(Reg_G7), .in8(Reg_G8),
        .min_out(min9_G_out)
    );
    
    min_9 u_min9_B(
        .in0(Reg_B0), .in1(Reg_B1), .in2(Reg_B2),
        .in3(Reg_B3), .in4(Reg_B4), .in5(Reg_B5),
        .in6(Reg_B6), .in7(Reg_B7), .in8(Reg_B8),
        .min_out(min9_B_out)
    );
    
    // Pipeline registers at the end of stage 2
    reg [7:0] p2_min9_R, p2_min9_G, p2_min9_B;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            p2_min9_R <= 8'b0;
            p2_min9_G <= 8'b0;
            p2_min9_B <= 8'b0;
        end else begin
            p2_min9_R <= min9_R_out;
            p2_min9_G <= min9_G_out;
            p2_min9_B <= min9_B_out;
        end
    end

    //-------------------------------------------------------------------------
    // Stage 3: Min_3 of the three min_9 outputs, comparators, LUTs, and muxes
    //-------------------------------------------------------------------------
    wire [7:0] min3_out;
    
    // min3 block
    min_3 u_min3(
        .in0(p2_min9_R),
        .in1(p2_min9_G),
        .in2(p2_min9_B),
        .min3_out(min3_out)
    );
    
    wire [7:0] mux_out;
    wire cmp_out;
    reg [7:0] mux_in_out;
    
    // comparator
    cmp_8bit CMP(
        .a(mux_in_out),
        .b(min3_out),
        .gt(cmp_out)
    );
    
    // top mux
    mux m1(
        .a(min3_out),
        .b(mux_in_out),
        .sel(cmp_out),
        .y(mux_out)
    );
    
    // wire and reg declaration for muxes
    wire [7:0] m2_out, m3_out, m4_out;
    reg [7:0] P2_AR, P4_AG, P6_AB;
    
    // mux for red pixels
    mux m2(
        .a(p2_min9_R),
        .b(P2_AR),
        .sel(cmp_out),
        .y(m2_out)
    );
    
    // mux for green pixels
    mux m3(
        .a(p2_min9_G),
        .b(P4_AG),
        .sel(cmp_out),
        .y(m3_out)
    );
    
    // mux for blue pixels
    mux m4(
        .a(p2_min9_B),
        .b(P6_AB),
        .sel(cmp_out),
        .y(m4_out)
    );

    // wire and reg declarations for the LUTs
    reg [8:0] P1_AinvR, P3_AinvG, P5_AinvB;
    wire [8:0] L1_out, L2_out, L3_out;
   
    // LUT for red pixels
    LUT L1(
        .in(m2_out),
        .out(L1_out)
    );
    
    // LUT for green pixels
    LUT L2(
        .in(m3_out),
        .out(L2_out)
    );
    
    // LUT for blue pixels
    LUT L3(
        .in(m4_out),
        .out(L3_out)
    );
    
    // reset and posedge assign logic for stage 3
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mux_in_out <= 8'b0;
            P2_AR <= 8'b0;
            P4_AG <= 8'b0;
            P6_AB <= 8'b0;
            P1_AinvR <= 9'b0;
            P3_AinvG <= 9'b0;
            P5_AinvB <= 9'b0;
        end else begin
            mux_in_out <= mux_out;
            P2_AR <= m2_out;
            P4_AG <= m3_out;
            P6_AB <= m4_out;
            P1_AinvR <= L1_out;
            P3_AinvG <= L2_out;
            P5_AinvB <= L3_out;
        end
    end
    
    assign A_R = P2_AR;
    assign A_G = P4_AG;
    assign A_B = P6_AB;
    assign invA_R = P1_AinvR;
    assign invA_G = P3_AinvG;
    assign invA_B = P5_AinvB;
    
endmodule