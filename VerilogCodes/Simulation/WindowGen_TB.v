`timescale 1ns/1ps

module ale_tb;
reg clk;
reg rst;
reg [23:0]input_pixel;
reg input_is_valid;

wire [7:0] a_r;
wire [7:0] a_g;
wire [7:0] a_b;
wire [15:0] inv_a_r;
wire [15:0] inv_a_g;
wire [15:0] inv_a_b;
wire ale_valid;

ale_top dut(
clk,
rst,
input_pixel,
input_is_valid,

 a_r,
 a_g,
 a_b,
 inv_a_r,
 inv_a_g,
 inv_a_b,
 ale_valid
);

   // Clock generation
   initial clk = 1;
   always #5 clk = ~clk;

   // File and image data
   localparam array_length = 800*1024;
    
   reg [23:0] result[0:array_length-1];
   reg [7:0] bmpdata[0:array_length-1];
    
   integer bmp_size, bmp_start_pos, bmp_width, bmp_height, bmp_count;
   integer i, j;
   // Task: Read BMP File
   task read_file;
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
    
   //write BMP file
   task write_file;
       integer file2,i;
       begin
       file2 = $fopen("output_file.bmp","wb");
        
       for(i = 0;i < bmp_start_pos; i = i + 1)
       begin   
               $fwrite(file2, "%c", bmpdata[i]);
       end
        
        for(i = bmp_start_pos;i < bmp_size; i = i + 1)
              begin   
                      $fwrite(file2, "%c%c%c",result [i-bmp_start_pos][7:0],
                                                                   result [i-bmp_start_pos][15:8],                                           
                                                                   result [i-bmp_start_pos][23:16]);
                       
              end
        
       $fclose(file2);
       $display("write successful");
        
       end
   endtask

   initial begin
       rst = 1;
       input_is_valid = 0;
       input_pixel=0;
       read_file;
       #10;
       rst = 0;

       for (i = bmp_start_pos; i < bmp_size; i = i + 3) begin
           input_pixel[7:0]  = bmpdata[i];
           input_pixel[15:8] = bmpdata[i + 1];
           input_pixel[23:16]   = bmpdata[i + 2];
           #10;
          input_is_valid = 1;
       end
        
        
       #10;
       input_is_valid = 0;
       #10;
       write_file;
       #10;
       $stop;
   end

   // Output Monitor
   always @(posedge clk) begin
       if (rst)
           j <= 0;
       else if (ale_valid) begin
           $display("Output Pixel %0d:", j);
           $display("a_r: %d, a_g: %d, a_b: %d", a_r, a_g, a_b);
           $display("inv_a_r: %d, inv_a_g: %d, inv_a_b: %d", inv_a_r, inv_a_g, inv_a_b);
           j <= j+1;
       end
   end

endmodule
