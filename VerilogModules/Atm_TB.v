`timescale 1ns / 1ps

module atmospheric_light_top_tb;

    // Clock and Reset
    reg clk;
    reg rst;
    
    // Inputs (9 pixels for each color channel)
    reg [7:0] Reg_R0, Reg_R1, Reg_R2, Reg_R3, Reg_R4, Reg_R5, Reg_R6, Reg_R7, Reg_R8;
    reg [7:0] Reg_G0, Reg_G1, Reg_G2, Reg_G3, Reg_G4, Reg_G5, Reg_G6, Reg_G7, Reg_G8;
    reg [7:0] Reg_B0, Reg_B1, Reg_B2, Reg_B3, Reg_B4, Reg_B5, Reg_B6, Reg_B7, Reg_B8;

    // Outputs
    wire [7:0] A_R, A_G, A_B;
    wire [8:0] invA_R, invA_G, invA_B;

    // Instantiate the DUT (Device Under Test)
    atmospheric_light_top dut (
        .clk(clk),
        .rst(rst),
        .Reg_R0(Reg_R0), .Reg_R1(Reg_R1), .Reg_R2(Reg_R2), .Reg_R3(Reg_R3), .Reg_R4(Reg_R4), .Reg_R5(Reg_R5), .Reg_R6(Reg_R6), .Reg_R7(Reg_R7), .Reg_R8(Reg_R8),
        .Reg_G0(Reg_G0), .Reg_G1(Reg_G1), .Reg_G2(Reg_G2), .Reg_G3(Reg_G3), .Reg_G4(Reg_G4), .Reg_G5(Reg_G5), .Reg_G6(Reg_G6), .Reg_G7(Reg_G7), .Reg_G8(Reg_G8),
        .Reg_B0(Reg_B0), .Reg_B1(Reg_B1), .Reg_B2(Reg_B2), .Reg_B3(Reg_B3), .Reg_B4(Reg_B4), .Reg_B5(Reg_B5), .Reg_B6(Reg_B6), .Reg_B7(Reg_B7), .Reg_B8(Reg_B8),
        .A_R(A_R), .A_G(A_G), .A_B(A_B),
        .invA_R(invA_R), .invA_G(invA_G), .invA_B(invA_B)
    );

    // Clock Generation (50MHz)
    always #10 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        Reg_R0 = 8'd0;  Reg_R1 = 8'd0;  Reg_R2 = 8'd0;  
        Reg_R3 = 8'd0;  Reg_R4 = 8'd0;  Reg_R5 = 8'd0;
        Reg_R6 = 8'd0;  Reg_R7 = 8'd0;  Reg_R8 = 8'd0;
        
        Reg_G0 = 8'd0;  Reg_G1 = 8'd0;  Reg_G2 = 8'd0;  
        Reg_G3 = 8'd0;  Reg_G4 = 8'd0;  Reg_G5 = 8'd0;
        Reg_G6 = 8'd0;  Reg_G7 = 8'd0;  Reg_G8 = 8'd0;
        
        Reg_B0 = 8'd0;  Reg_B1 = 8'd0;  Reg_B2 = 8'd0;  
        Reg_B3 = 8'd0;  Reg_B4 = 8'd0;  Reg_B5 = 8'd0;
        Reg_B6 = 8'd0;  Reg_B7 = 8'd0;  Reg_B8 = 8'd0;

        // Apply Reset
        #20 rst = 0;

        // Test Case 1: Uniform Image (All pixels have same value)
        #20;
        Reg_R0 = 8'd100; Reg_R1 = 8'd100; Reg_R2 = 8'd100;  
        Reg_R3 = 8'd100; Reg_R4 = 8'd100; Reg_R5 = 8'd100;
        Reg_R6 = 8'd100; Reg_R7 = 8'd100; Reg_R8 = 8'd100;
        
        Reg_G0 = 8'd120; Reg_G1 = 8'd120; Reg_G2 = 8'd120;  
        Reg_G3 = 8'd120; Reg_G4 = 8'd120; Reg_G5 = 8'd120;
        Reg_G6 = 8'd120; Reg_G7 = 8'd120; Reg_G8 = 8'd120;
        
        Reg_B0 = 8'd140; Reg_B1 = 8'd140; Reg_B2 = 8'd140;  
        Reg_B3 = 8'd140; Reg_B4 = 8'd140; Reg_B5 = 8'd140;
        Reg_B6 = 8'd140; Reg_B7 = 8'd140; Reg_B8 = 8'd140;

        // Wait for pipeline propagation
        #50;

        // Test Case 2: Random pixel values
        #20;
        Reg_R0 = 8'd50;  Reg_R1 = 8'd200; Reg_R2 = 8'd150;
        Reg_R3 = 8'd180; Reg_R4 = 8'd90;  Reg_R5 = 8'd220;
        Reg_R6 = 8'd130; Reg_R7 = 8'd60;  Reg_R8 = 8'd110;

        Reg_G0 = 8'd10;  Reg_G1 = 8'd210; Reg_G2 = 8'd170;
        Reg_G3 = 8'd190; Reg_G4 = 8'd80;  Reg_G5 = 8'd200;
        Reg_G6 = 8'd140; Reg_G7 = 8'd40;  Reg_G8 = 8'd120;

        Reg_B0 = 8'd90;  Reg_B1 = 8'd180; Reg_B2 = 8'd160;
        Reg_B3 = 8'd200; Reg_B4 = 8'd70;  Reg_B5 = 8'd230;
        Reg_B6 = 8'd120; Reg_B7 = 8'd50;  Reg_B8 = 8'd140;

        // Wait for pipeline propagation
        #50;

        // Additional test cases can be added similarly

        // Finish simulation
        #100;
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t | A_R=%d, A_G=%d, A_B=%d | invA_R=%d, invA_G=%d, invA_B=%d", 
                 $time, A_R, A_G, A_B, invA_R, invA_G, invA_B);
    end

endmodule