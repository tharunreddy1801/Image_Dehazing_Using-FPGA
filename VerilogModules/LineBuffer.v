`timescale 1ns/1ps
module LineBuffer(
    input wire clk,rst,
    input wire[23:0]input_pixel,
    input wire input_is_valid,
    input wire read_buffer_enable,
    output wire [71:0] output_pixel
);

parameter Row_Size = 512;
parameter Pixel_Size = 24;

reg [8:0] wr_counter, rd_counter;
reg [Pixel_Size - 1:0] line_buffer_mem[Row_Size - 1:0];
reg [71:0] buffer_out;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        wr_counter <= 'b0;
        rd_counter <= 'b0;
        buffer_out <= 'b0;
    end
    else
    begin
        if(input_is_valid)
        begin
             line_buffer_mem[wr_counter] <= input_pixel;
             wr_counter <= wr_counter + 1;
        end
        if(read_buffer_enable)
        begin
            if(rd_counter == 510)
                buffer_out <= { line_buffer_mem[rd_counter], line_buffer_mem[rd_counter + 1], 24'b1 };
            else if(rd_counter == 511)
                buffer_out <= { line_buffer_mem[rd_counter], 24'b1, 24'b1 };
            else
                buffer_out <= { line_buffer_mem[rd_counter], line_buffer_mem[rd_counter + 1], line_buffer_mem[rd_counter + 2] };
                
            rd_counter <= rd_counter + 1;
        end
    end
end

assign output_pixel = buffer_out;
endmodule