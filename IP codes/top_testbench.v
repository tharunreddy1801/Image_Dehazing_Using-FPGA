`timescale 1ns/1ps

module Haze_Removal_TB;
    
    // AXI4-Stream Global Signals
    reg         ACLK;
    reg         ARESETn;
    
    // Enable Signal
    reg         enable;
    
    // AXI4-Stream Slave Interface
    reg [31:0]  S_AXIS_TDATA;
    reg         S_AXIS_TVALID;
    reg         S_AXIS_TLAST;
    wire        S_AXIS_TREADY;
    
    // AXI4-Stream Master Interface
    wire [31:0] M_AXIS_TDATA;
    wire        M_AXIS_TVALID;
    wire        M_AXIS_TLAST;
    reg         M_AXIS_TREADY;

    // Instantiate the ALE_TE_Top module
    Haze_Removal_Top dut(
        .ACLK(ACLK),
        .ARESETn(ARESETn),
        .enable(enable),
    
        .S_AXIS_TDATA(S_AXIS_TDATA),
        .S_AXIS_TVALID(S_AXIS_TVALID),
        .S_AXIS_TLAST(S_AXIS_TLAST),
        .S_AXIS_TREADY(S_AXIS_TREADY),

        .M_AXIS_TDATA(M_AXIS_TDATA),
        .M_AXIS_TVALID(M_AXIS_TVALID),
        .M_AXIS_TLAST(M_AXIS_TLAST),
        .M_AXIS_TREADY(M_AXIS_TREADY)
    );

    // Clock generation
    initial ACLK = 0;
    always #5 ACLK = ~ACLK;
    
    // File and image data
    localparam File_Size = 800 * 1024;
    reg [7:0] bmpdata[0:File_Size - 1];
    reg [23:0] result[0:(File_Size / 3) - 1];
    
    integer bmp_size, bmp_start_pos, bmp_width, bmp_height, bmp_count;
    integer i, j;

    // Read from BMP File
    task READ_FILE;
        integer file1;
        begin 
            file1 = $fopen("canyon_512.bmp", "rb");
            if (file1 == 0) begin
                $display("Error: Cannot open BMP file.");
                $finish;
            end else begin
                $fread(bmpdata, file1);
                $fclose(file1);
                
                // Extract BMP header information (little-endian)
                bmp_size       = {bmpdata[5], bmpdata[4], bmpdata[3], bmpdata[2]};
                bmp_start_pos  = {bmpdata[13], bmpdata[12], bmpdata[11], bmpdata[10]};
                bmp_width      = {bmpdata[21], bmpdata[20], bmpdata[19], bmpdata[18]};
                bmp_height     = {bmpdata[25], bmpdata[24], bmpdata[23], bmpdata[22]};
                bmp_count      = {bmpdata[29], bmpdata[28]};

                $display("BMP size         : %d", bmp_size);
                $display("BMP start pos    : %d", bmp_start_pos);
                $display("BMP width        : %d", bmp_width);
                $display("BMP height       : %d", bmp_height);
                $display("BMP bits/pixel   : %d", bmp_count);
                
                if (bmp_count != 24) begin
                    $display("Error: BMP should be 24 bits/pixel.");
                    $finish;
                end
                
                if (bmp_width % 4) begin
                    $display("Warning: BMP width should be divisible by 4 for proper alignment.");
                    $finish;
                end
            end
        end
    endtask

    // Write to BMP File
    task WRITE_FILE;
        integer file2, k;
        begin
            file2 = $fopen("result_image.bmp", "wb");
            
            for (k = 0; k < bmp_start_pos; k = k + 1) begin   
                $fwrite(file2, "%c", bmpdata[k]);
            end
            
            // Write BMP header
            for(k = bmp_start_pos; k < bmp_size; k = k + 3) begin   
                $fwrite(file2, "%c%c%c", 
                            result[(k - bmp_start_pos)/3][7:0],        // Blue
                            result[(k - bmp_start_pos)/3][15:8],       // Green
                            result[(k - bmp_start_pos)/3][23:16]       // Red
                        );
            end
            
            $fclose(file2);
            $display("Write successful");
        end
    endtask
    
    // Main test sequence
    initial begin
        ARESETn = 0;
        enable = 1;
        
        S_AXIS_TDATA = 0;
        S_AXIS_TVALID = 0;
        S_AXIS_TLAST = 0;
        M_AXIS_TREADY = 1;

        // Read input file
        READ_FILE;
        
        #10;
        ARESETn = 1;

        // --------------------------
        // Pass 1: Feed image to ALE
        // --------------------------
        for (i = bmp_start_pos; i < bmp_size; i = i + 3) begin
            S_AXIS_TDATA[7:0]   = bmpdata[i];       // B
            S_AXIS_TDATA[15:8]  = bmpdata[i + 1];   // G
            S_AXIS_TDATA[23:16] = bmpdata[i + 2];   // R
            #10;
            S_AXIS_TVALID = 1;
        end
        
        S_AXIS_TVALID = 0;
        #10;
        
        // ------------------------------
        // Pass 2: Feed image to TE and SRSC
        // ------------------------------

        // Read input file
        READ_FILE;
        #10;
      
        for (i = bmp_start_pos; i < bmp_size; i = i + 3) begin
            S_AXIS_TDATA[7:0]   = bmpdata[i];       // B
            S_AXIS_TDATA[15:8]  = bmpdata[i + 1];   // G
            S_AXIS_TDATA[23:16] = bmpdata[i + 2];   // R
            #10;
            S_AXIS_TVALID = 1;
        end
        
        S_AXIS_TVALID = 0;
        // Write output file
        WRITE_FILE;
        
        #100;
        S_AXIS_TLAST = 1;
        $stop;
    end
    
    // Output Monitor
    always @(posedge ACLK) begin
        if (~ARESETn) begin
            j <= 0;
        end 
        else if (M_AXIS_TVALID) begin
            result[j] <= M_AXIS_TDATA;
            j <= j + 1;
        end
    end
    
endmodule



// `timescale 1ns/1ps

// module Haze_Removal_TB;
    
//     // AXI4-Stream Global Signals
//     reg         ACLK;
//     reg         ARESETn;
    
//     // Enable Signal
//     reg         enable;
    
//     // AXI4-Stream Slave Interface
//     reg [31:0]  S_AXIS_TDATA;
//     reg         S_AXIS_TVALID;
//     reg         S_AXIS_TLAST;
//     wire        S_AXIS_TREADY;
    
//     // AXI4-Stream Master Interface
//     wire [31:0] M_AXIS_TDATA;
//     wire        M_AXIS_TVALID;
//     wire        M_AXIS_TLAST;
//     reg         M_AXIS_TREADY;

//     // Instantiate the ALE_TE_Top module
//     Haze_Removal_Top dut(
//         .ACLK(ACLK),
//         .ARESETn(ARESETn),
//         .enable(enable),
    
//         .S_AXIS_TDATA(S_AXIS_TDATA),
//         .S_AXIS_TVALID(S_AXIS_TVALID),
//         .S_AXIS_TLAST(S_AXIS_TLAST),
//         .S_AXIS_TREADY(S_AXIS_TREADY),

//         .M_AXIS_TDATA(M_AXIS_TDATA),
//         .M_AXIS_TVALID(M_AXIS_TVALID),
//         .M_AXIS_TLAST(M_AXIS_TLAST),
//         .M_AXIS_TREADY(M_AXIS_TREADY),
        
//         .o_intr(o_intr)
//     );

//     // Clock generation
//     initial ACLK = 0;
//     always #5 ACLK = ~ACLK;
    
//     // File and image data
//     localparam File_Size = 800 * 1024;
//     reg [7:0] bmpdata[0:File_Size - 1];
//     reg [23:0] result[0:(File_Size / 3) - 1];
    
//     integer bmp_size, bmp_start_pos, bmp_width, bmp_height, bmp_count;
//     integer i, j;

//     // Read from BMP File
//     task READ_FILE;
//         integer file1;
//         begin 
//             file1 = $fopen("canyon_512.bmp", "rb");
//             if (file1 == 0) begin
//                 $display("Error: Cannot open BMP file.");
//                 $finish;
//             end else begin
//                 $fread(bmpdata, file1);
//                 $fclose(file1);
                
//                 // Extract BMP header information (little-endian)
//                 bmp_size       = {bmpdata[5], bmpdata[4], bmpdata[3], bmpdata[2]};
//                 bmp_start_pos  = {bmpdata[13], bmpdata[12], bmpdata[11], bmpdata[10]};
//                 bmp_width      = {bmpdata[21], bmpdata[20], bmpdata[19], bmpdata[18]};
//                 bmp_height     = {bmpdata[25], bmpdata[24], bmpdata[23], bmpdata[22]};
//                 bmp_count      = {bmpdata[29], bmpdata[28]};

//                 $display("BMP size         : %d", bmp_size);
//                 $display("BMP start pos    : %d", bmp_start_pos);
//                 $display("BMP width        : %d", bmp_width);
//                 $display("BMP height       : %d", bmp_height);
//                 $display("BMP bits/pixel   : %d", bmp_count);
                
//                 if (bmp_count != 24) begin
//                     $display("Error: BMP should be 24 bits/pixel.");
//                     $finish;
//                 end
                
//                 if (bmp_width % 4) begin
//                     $display("Warning: BMP width should be divisible by 4 for proper alignment.");
//                     $finish;
//                 end
//             end
//         end
//     endtask

//     // Write to BMP File
//     task WRITE_FILE;
//         integer file2, k;
//         begin
//             file2 = $fopen("result_image.bmp", "wb");
            
//             for (k = 0; k < bmp_start_pos; k = k + 1) begin   
//                 $fwrite(file2, "%c", bmpdata[k]);
//             end
            
//             // Write BMP header
//             for(k = bmp_start_pos; k < bmp_size; k = k + 3) begin   
//                 $fwrite(file2, "%c%c%c", 
//                             result[(k - bmp_start_pos)/3][7:0],        // Blue
//                             result[(k - bmp_start_pos)/3][15:8],       // Green
//                             result[(k - bmp_start_pos)/3][23:16]       // Red
//                         );
//             end
            
//             $fclose(file2);
//             $display("Write successful");
//         end
//     endtask
    
//     // Main test sequence
//     initial begin
//         ARESETn = 0;

//         S_AXIS_TDATA = 0;
//         S_AXIS_TVALID = 0;
//         S_AXIS_TLAST = 0;

//         M_AXIS_TREADY = 1;

//         enable = 0;
        
//         READ_FILE;
        
//         #10;
//         ARESETn = 1;
        
//         // --------------------------
//         // Pass 1: Feed image to ALE
//         // --------------------------
//         for (i = bmp_start_pos; i < bmp_size; i = i + 3) begin
//             S_AXIS_TDATA[7:0]   = bmpdata[i];       // B
//             S_AXIS_TDATA[15:8]  = bmpdata[i + 1];   // G
//             S_AXIS_TDATA[23:16] = bmpdata[i + 2];   // R
//             S_AXIS_TVALID = 1;
//             #10;
//         end
        
//         S_AXIS_TVALID = 0;
//         #10;
        
//         wait(dut.ALE_done == 1);
//         #10;
//         // ------------------------------
//         // Pass 2: Feed image to TE and SRSC
//         // ------------------------------
//         enable = 1; // Enable TE and SRSC
//         #10;
      
//         READ_FILE;
//         #20;
      
//         for (i = bmp_start_pos; i < bmp_size; i = i + 3) begin
//             S_AXIS_TDATA[7:0]   = bmpdata[i];       // B
//             S_AXIS_TDATA[15:8]  = bmpdata[i + 1];   // G
//             S_AXIS_TDATA[23:16] = bmpdata[i + 2];   // R
//             S_AXIS_TVALID = 1;
//             #10;
//         end
        
//         S_AXIS_TVALID = 0;
//         #100;
        
//         // Write output file
//         WRITE_FILE;
        
//         #10;
//         $stop;
//     end
    
//     // Output Monitor
//     always @(posedge ACLK) begin
//         if (~ARESETn) begin
//             j <= 0;
//         end 
//         else if (M_AXIS_TVALID) begin
//             result[j] <= M_AXIS_TDATA;
//             j <= j + 1;
//         end
//     end
    
// endmodule
