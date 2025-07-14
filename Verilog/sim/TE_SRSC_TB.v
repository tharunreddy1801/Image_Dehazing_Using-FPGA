`timescale 1ns/1ps
module TE_SRSC_Tb;
    reg        clk;
    reg        rst;
  
    reg [23:0] input_pixel;
    reg        input_is_valid;
  
    wire [7:0] J_R;
    wire [7:0] J_G;
    wire [7:0] J_B;
  
    wire       output_valid;
    
    TE_SRSC_Top dut (
        .clk(clk),
        .rst(rst),
        .input_pixel(input_pixel),
        .input_is_valid(input_is_valid),
        .J_R(J_R),
        .J_G(J_G),
        .J_B(J_B),
        .output_valid(output_valid)
    );
    
    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;
    
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
            file2 = $fopen("output_file.bmp", "wb");
            
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
        rst = 1;
        input_is_valid = 0;
        input_pixel = 0;
        
        READ_FILE;
        
        #10;
        rst = 0;
        
        for (i = bmp_start_pos; i < bmp_size; i = i + 3) begin
            input_pixel[7:0]   = bmpdata[i];     // Blue
            input_pixel[15:8]  = bmpdata[i + 1]; // Green  
            input_pixel[23:16] = bmpdata[i + 2]; // Red
            #10;
            input_is_valid = 1;
        end
        
        #10;
        input_is_valid = 0;
        
        #10;
        WRITE_FILE;
        
        #10;
        $stop;
    end
    
    // Store the outputs
    always @(posedge clk) begin
        if (rst) begin
            j <= 0;
        end else if (output_valid) begin
            result[j] <= {J_R, J_G, J_B};
            j <= j + 1;
        end
    end
    
endmodule
