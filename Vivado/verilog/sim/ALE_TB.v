`timescale 1ns/1ps

module ALE_TB;
    reg         clk;
    reg         rst;
    reg [23:0]  input_pixel;
    reg         input_is_valid;

    wire [7:0]  A_R;
    wire [7:0]  A_G;
    wire [7:0]  A_B;
    wire [15:0] Inv_A_R;
    wire [15:0] Inv_A_G;
    wire [15:0] inv_a_b;
    wire        output_is_valid;

    ALE_Top dut (
        .clk           (clk),
        .rst           (rst),
        .input_pixel   (input_pixel),
        .input_is_valid(input_is_valid),

        .A_R            (A_R),
        .A_G            (A_G),
        .A_B            (A_B),
        .Inv_A_R        (Inv_A_R),
        .Inv_A_G        (Inv_A_G),
        .Inv_A_B        (Inv_A_B),
        
        .output_is_valid(output_is_valid)
    );

    // Clock generation
    initial clk = 1;
    always #5 clk = ~clk;

    // File and image data
    localparam File_Size = 800*1024;

    reg [23:0] result[0:File_Size - 1];
    reg [7:0]  bmpdata[0:File_Size - 1];

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
                    $display("Error: BMP width must be divisible by 4.");
                    $finish;
                end
            end
        end
    endtask

    // Write to BMP file
    task WRITE_FILE;
        integer file2, i;
        begin
            file2 = $fopen("output_file.bmp", "wb");

            for (i = 0; i < bmp_start_pos; i = i + 1) begin   
                $fwrite(file2, "%c", bmpdata[i]);
            end

            for (i = bmp_start_pos; i < bmp_size; i = i + 1) begin   
                $fwrite(file2, "%c%c%c", 
                    result[i - bmp_start_pos][7:0],
                    result[i - bmp_start_pos][15:8],                                           
                    result[i - bmp_start_pos][23:16]);
            end

            $fclose(file2);
            $display("write successful");
        end
    endtask

    initial begin
        rst = 1;
        input_is_valid = 0;
        input_pixel = 0;
     
        READ_FILE;
     
        #10;
        rst = 0;

        for (i = bmp_start_pos; i < bmp_size; i = i + 3) begin
            input_pixel[7:0]    = bmpdata[i];
            input_pixel[15:8]   = bmpdata[i + 1];
            input_pixel[23:16]  = bmpdata[i + 2];
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

    // Output Monitor
    always @(posedge clk) begin
        if (rst)
            j <= 0;
        else if (output_is_valid) begin
            $display("Output Pixel %0d:", j);
            $display("A_R: %d, A_G: %d, A_B: %d", A_R, A_G, A_B);
            $display("Inv_AR: %d, Inv_AG: %d, Inv_AB: %d", Inv_A_R, Inv_A_G, Inv_A_B);
            j <= j + 1;
        end
    end

endmodule

// `timescale 1ns/1ps

// module ale_tb;

//     reg clk;
//     reg rst;
//     reg [23:0] in;
//     reg input_is_valid;

//     wire [23:0]out;
//     wire ale_valid;

//     // Instantiate DUT
//      top UUT (
//             .clk(clk),
//             .rst(rst),
//             .input_pixel(in),
//             .input_is_valid(input_is_valid),
//             .out_pixel(out),
//             .output_is_valid(ale_valid)
//         );

//     // Clock generation
//     initial clk = 1;
//     always #5 clk = ~clk;

//     // File and image data
//     localparam array_length = 800*1024;
    

//     reg [23:0] result[0:array_length-1];
//     reg [7:0] bmpdata[0:array_length-1];
    
//     integer bmp_size, bmp_start_pos, bmp_width, bmp_height, bmp_count;
//     integer i, j;
//     // Task: Read BMP File
//     task read_file;
//         integer file1;
//         begin 
//             file1 = $fopen("canyon_512.bmp", "rb");
//             if (file1 == 0) begin
//                 $display("Error: Cannot open BMP file.");
//                 $finish;
//             end else begin
//                 $fread(bmpdata, file1);
//                 $fclose(file1);

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
//                     $display("Error: BMP width must be divisible by 4.");
//                     $finish;
//                 end
//             end
//         end
//     endtask
    
//     //write BMP file
//     task write_file;
//         integer file2,i;
//         begin
//         file2 = $fopen("output_file.bmp","wb");
        
//         for(i = 0;i < bmp_start_pos; i = i + 1)
//         begin   
//                 $fwrite(file2, "%c", bmpdata[i]);
//         end
        
//          for(i = bmp_start_pos;i < bmp_size; i = i + 1)
//                begin   
//                        $fwrite(file2, "%c%c%c",result [i-bmp_start_pos][7:0],
//                                                                     result [i-bmp_start_pos][15:8],                                           
//                                                                     result [i-bmp_start_pos][23:16]);
                       
//                end
        
//         $fclose(file2);
//         $display("write successful");
        
//         end
//     endtask

//     // Stimulus
//     initial begin
//         rst = 1;
//         input_is_valid = 0;
//         in=0;
//         read_file;
//         #10;
//         rst = 0;

//         for (i = bmp_start_pos; i < bmp_size; i = i + 3) begin
//             in[7:0]  = bmpdata[i];     // BMP stores pixels as BGR
//             in[15:8] = bmpdata[i + 1];
//             in[23:16]   = bmpdata[i + 2];
//             #10;
//            input_is_valid = 1;
//         end
        
        
//         #10;
//         input_is_valid = 0;
//         #10;
//         write_file;
//         #10;
//         $stop;
//     end

//     // Output Monitor
//     always @(posedge clk) begin
//         if (rst)
//             j <= 0;
//         else if (ale_valid) begin
//             result[j] = out ;
//             j <= j + 1;
//         end
//     end

// endmodule
