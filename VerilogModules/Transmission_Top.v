module transmission_estimation(
    input  wire        clk,
    input  wire        rst,

    input  wire [7:0]  Reg_R0,
    input  wire [7:0]  Reg_R1,
    input  wire [7:0]  Reg_R2,
    input  wire [7:0]  Reg_R3,
    input  wire [7:0]  Reg_R4,
    input  wire [7:0]  Reg_R5,
    input  wire [7:0]  Reg_R6,
    input  wire [7:0]  Reg_R7,
    input  wire [7:0]  Reg_R8,
    
    input  wire [7:0]  Reg_G0,
    input  wire [7:0]  Reg_G1,
    input  wire [7:0]  Reg_G2,
    input  wire [7:0]  Reg_G3,
    input  wire [7:0]  Reg_G4,
    input  wire [7:0]  Reg_G5,
    input  wire [7:0]  Reg_G6,
    input  wire [7:0]  Reg_G7,
    input  wire [7:0]  Reg_G8,
    
    input  wire [7:0]  Reg_B0,
    input  wire [7:0]  Reg_B1,
    input  wire [7:0]  Reg_B2,
    input  wire [7:0]  Reg_B3,
    input  wire [7:0]  Reg_B4,
    input  wire [7:0]  Reg_B5,
    input  wire [7:0]  Reg_B6,
    input  wire [7:0]  Reg_B7,
    input  wire [7:0]  Reg_B8,

    input  wire [8:0]  invA_R,
    input  wire [8:0]  invA_G,
    input  wire [8:0]  invA_B,
    
    output wire [11:0] t_out
);

    wire [1:0] ED_1_out, ED_2_out, ED_3_out;
    reg  [7:0] P_reg0, P_reg1, P_reg2;

    //=============================================
    // Stage 4 : Edge Detection
    //=============================================
    ED E1(
        .in0(Reg_R0), .in1(Reg_R1), .in2(Reg_R2), .in3(Reg_R3),
        .in4(Reg_R4), .in5(Reg_R5), .in6(Reg_R6), .in7(Reg_R7),
        .in8(Reg_R8), .ED_out(ED_1_out)
    );
    
    ED E2(
        .in0(Reg_G0), .in1(Reg_G1), .in2(Reg_G2), .in3(Reg_G3),
        .in4(Reg_G4), .in5(Reg_G5), .in6(Reg_G6), .in7(Reg_G7),
        .in8(Reg_G8), .ED_out(ED_2_out)
    );
    
    ED E3(
        .in0(Reg_B0), .in1(Reg_B1), .in2(Reg_B2), .in3(Reg_B3),
        .in4(Reg_B4), .in5(Reg_B5), .in6(Reg_B6), .in7(Reg_B7),
        .in8(Reg_B8), .ED_out(ED_3_out)
    );
    
    //pipeline registers to get inputs from atmospheric light
    reg [8:0] inv_AR_P1, inv_AG_P1, inv_AB_P1;
    reg [8:0] inv_AR_P3, inv_AG_P3, inv_AB_P3;
    reg [8:0] inv_AR_P5, inv_AG_P5, inv_AB_P5;
    
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            inv_AR_P1 <= 9'b0;
            inv_AG_P1 <= 9'b0;
            inv_AB_P1 <= 9'b0;
                    
            inv_AR_P3 <= 9'b0;
            inv_AG_P3 <= 9'b0;
            inv_AB_P3 <= 9'b0;
                                
            inv_AR_P5 <= 9'b0;
            inv_AG_P5 <= 9'b0;
            inv_AB_P5 <= 9'b0;
                    
            P_reg0 <= 2'b00;
            P_reg1 <= 2'b00;
            P_reg2 <= 2'b00;
        end
        else begin
            inv_AR_P1 <= invA_R;
            inv_AG_P1 <= invA_G;
            inv_AB_P1 <= invA_B;
            
            inv_AR_P3 <= invA_R;
            inv_AG_P3 <= invA_G;
            inv_AB_P3 <= invA_B;
            
            inv_AR_P5 <= invA_R;
            inv_AG_P5 <= invA_G;
            inv_AB_P5 <= invA_B;
              
            P_reg0 <= ED_1_out;
            P_reg1 <= ED_2_out;
            P_reg2 <= ED_3_out;
        end
    end
    
    //=============================================
    // Stage 5 : Filter blocks and second pipeline registers
    //=============================================
    wire [1:0] or_out;
    
    or_gate o1(
        .a(P_reg0),
        .b(P_reg1),
        .c(P_reg2),
        .out(or_out)
    );
    
    reg [1:0] p_reg_or1;
    
    reg [8:0] inv_AR_P2, inv_AG_P2, inv_AB_P2;
    reg [8:0] inv_AR_P4, inv_AG_P4, inv_AB_P4;
    reg [8:0] inv_AR_P6, inv_AG_P6, inv_AB_P6;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            p_reg_or1 <= 2'b00;
            
            inv_AR_P2 <= 9'b0;
            inv_AG_P2 <= 9'b0;
            inv_AB_P2 <= 9'b0;
            
            inv_AR_P4 <= 9'b0;
            inv_AG_P4 <= 9'b0;
            inv_AB_P4 <= 9'b0;
                        
            inv_AR_P6 <= 9'b0;
            inv_AG_P6 <= 9'b0;
            inv_AB_P6 <= 9'b0;
        end
        else begin
            p_reg_or1 <= or_out;
            
            inv_AR_P2 <= inv_AR_P1;
            inv_AG_P2 <= inv_AG_P1;
            inv_AB_P2 <= inv_AB_P1;
            
            inv_AR_P4 <= inv_AR_P3;
            inv_AG_P4 <= inv_AG_P3;
            inv_AB_P4 <= inv_AB_P3;
            
            inv_AR_P6 <= inv_AR_P5;
            inv_AG_P6 <= inv_AG_P5;
            inv_AB_P6 <= inv_AB_P5;
            
        end
    end
    
    //=============================================
    // Block P0
    //=============================================
    wire [7:0] p0_red_out, p0_green_out, p0_blue_out;
    
    block_P0 first_block_p0(
        .in0(Reg_R0), .in1(Reg_R1), .in2(Reg_R2), .in3(Reg_R3),
        .in4(Reg_R4), .in5(Reg_R5), .in6(Reg_R6), .in7(Reg_R7),
        .in8(Reg_R8), .p0_result(p0_red_out)
    );
    
    block_P0 second_block_p0(
        .in0(Reg_G0), .in1(Reg_G1), .in2(Reg_G2), .in3(Reg_G3),
        .in4(Reg_G4), .in5(Reg_G5), .in6(Reg_G6), .in7(Reg_G7),
        .in8(Reg_G8), .p0_result(p0_green_out)
    );
    
    block_P0 third_block_p0(
        .in0(Reg_B0), .in1(Reg_B1), .in2(Reg_B2), .in3(Reg_B3),
        .in4(Reg_B4), .in5(Reg_B5), .in6(Reg_B6), .in7(Reg_B7),
        .in8(Reg_B8), .p0_result(p0_blue_out)
    );
    
    //=============================================
    // Block P1
    //=============================================
    wire [7:0] p1_red_out, p1_green_out, p1_blue_out;
    
    block_P1 first_block_p1(
        .in0(Reg_R0), .in1(Reg_R1), .in2(Reg_R2), .in3(Reg_R3),
        .in4(Reg_R4), .in5(Reg_R5), .in6(Reg_R6), .in7(Reg_R7),
        .in8(Reg_R8), .p1_result(p1_red_out)
    );
    
    block_P1 second_block_p1(
        .in0(Reg_G0), .in1(Reg_G1), .in2(Reg_G2), .in3(Reg_G3),
        .in4(Reg_G4), .in5(Reg_G5), .in6(Reg_G6), .in7(Reg_G7),
        .in8(Reg_G8), .p1_result(p1_green_out)
    );
    
    block_P1 third_block_p1(
        .in0(Reg_B0), .in1(Reg_B1), .in2(Reg_B2), .in3(Reg_B3),
        .in4(Reg_B4), .in5(Reg_B5), .in6(Reg_B6), .in7(Reg_B7),
        .in8(Reg_B8), .p1_result(p1_blue_out)
    );
    
    //=============================================
    // Block P2
    //=============================================
    wire [7:0] p2_red_out, p2_green_out, p2_blue_out;
    
    block_P2 first_block_p2(
        .in0(Reg_R0), .in1(Reg_R1), .in2(Reg_R2), .in3(Reg_R3),
        .in4(Reg_R4), .in5(Reg_R5), .in6(Reg_R6), .in7(Reg_R7),
        .in8(Reg_R8), .p2_result(p2_red_out)
    );
    
    block_P2 second_block_p2(
        .in0(Reg_G0), .in1(Reg_G1), .in2(Reg_G2), .in3(Reg_G3),
        .in4(Reg_G4), .in5(Reg_G5), .in6(Reg_G6), .in7(Reg_G7),
        .in8(Reg_G8), .p2_result(p2_green_out)
    );
    
    block_P2 third_block_p2(
        .in0(Reg_B0), .in1(Reg_B1), .in2(Reg_B2), .in3(Reg_B3),
        .in4(Reg_B4), .in5(Reg_B5), .in6(Reg_B6), .in7(Reg_B7),
        .in8(Reg_B8), .p2_result(p2_blue_out)
    );
    
    //=============================================
    // Comparators and Multiplexers Declaration
    //=============================================
    wire [1:0]mul_sel_1;
    wire [8:0]mux_1_8bit_out;
    wire [9:0]mux_1_9bit_out;
    
    mux3to1_8bit m1_8bit(
        .in0(p0_red_out),.in1(p0_green_out),.in2(p0_blue_out),
        .sel(mul_sel_1),.out(mux_1_8bit_out)
    );
    
    comparator_3 c1(
        .a(p0_red_out),.b(p0_green_out),.c(p0_blue_out),
        .smallest(mul_sel_1)
    );
    
    mux3to1_9bit m1_9bit(
         .in0(inv_AR_P2),.in1(inv_AG_P2),.in2(inv_AB_P2),
         .sel(mul_sel_1),.out(mux_1_9bit_out)
    );
    
    wire [1:0]mul_sel_2;
    wire [8:0]mux_2_8bit_out;
    wire [9:0]mux_2_9bit_out;
        
    mux3to1_8bit m2_8bit(
        .in0(p1_red_out),.in1(p1_green_out),.in2(p1_blue_out),
        .sel(mul_sel_2),.out(mux_2_8bit_out)
    );
        
    comparator_3 c2(
        .a(p1_red_out),.b(p1_green_out),.c(p1_blue_out),
        .smallest(mul_sel_2)
    );
        
    mux3to1_9bit m2_9bit(
         .in0(inv_AR_P2),.in1(inv_AG_P2),.in2(inv_AB_P2),
         .sel(mul_sel_2),.out(mux_2_9bit_out)
    );
        
    wire [1:0]mul_sel_3;
    wire [8:0]mux_3_8bit_out;
    wire [9:0]mux_3_9bit_out;
            
    mux3to1_8bit m3_8bit(
       .in0(p2_red_out),.in1(p2_green_out),.in2(p2_blue_out),
       .sel(mul_sel_3),.out(mux_3_8bit_out)
    );
            
    comparator_3 c3(
        .a(p2_red_out),.b(p2_green_out),.c(p2_blue_out),
        .smallest(mul_sel_3)
    );
            
   mux3to1_9bit m3_9bit(
        .in0(inv_AR_P2),.in1(inv_AG_P2),.in2(inv_AB_P2),
        .sel(mul_sel_3),.out(mux_3_9bit_out)
   );


    // Multipliers and Shifters Declaration
    wire [16:0]mul_1_out,mul_2_out,mul_3_out;
    wire [11:0]shift_1_out,shift_2_out,shift_3_out;
    
    multiplier mul_1(
    .a(mux_1_9bit_out),.b(mux_1_8bit_out),.product(mul_1_out)
    );
    
    multiplier mul_2(
    .a(mux_2_9bit_out),.b(mux_2_8bit_out),.product(mul_2_out)
    );
        
    multiplier mul_3(
    .a(mux_3_9bit_out),.b(mux_3_8bit_out),.product(mul_3_out)
    );
    
    right_shifter r1(
    .in(mul_1_out),.out(shift_1_out)
    );
    
    right_shifter r2(
    .in(mul_2_out),.out(shift_2_out)
    );
        
    right_shifter r3(
    .in(mul_3_out),.out(shift_3_out)
    );
    
    //=============================================
    // Stage 6 : second pipeline register for or gate
    //=============================================
    
    reg [1:0] p_reg_or2;
    
    always @(posedge clk or posedge rst) begin
            if (rst) begin
                p_reg_or2 <= 2'b00;
            end
            else begin
                p_reg_or2 <= p_reg_or1;
            end
        end
    
    
    // Final 12 bit mux and subtractor
    wire [11:0]mux_12_bit_out, sub_out;
    reg [11:0] transmission_reg_out;
    
    mux3to1_12bit m_12_bit(
        .in0(shift_1_out),.in1(shift_2_out),.in2(shift_3_out),
        .sel(p_reg_or2),.out(mux_12_bit_out)
    );
    
    subtractor_12_bit s(
        .a(mux_12_bit_out),.b(12'b1),.sub(sub_out)
    );
    
    //=============================================
    // Stage 7 : pipeline regiser for output
    //=============================================
    
    always @(posedge clk or posedge rst) begin
            if (rst) begin
                transmission_reg_out <= 12'b0;
            end
            else begin
                transmission_reg_out <= sub_out;
            end
        end
        
    assign t_out = transmission_reg_out;
    
endmodule