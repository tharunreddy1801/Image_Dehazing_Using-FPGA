module LineBuffer(
    input         clk,
    input         rst,
    
    input [23:0]  input_pixel,
    input         input_is_valid,

    output [23:0] output_pixel,
    output        output_is_valid
);

parameter Buffer_Size = 512;

reg [$clog2(Buffer_Size):0] wr_counter;
reg [$clog2(Buffer_Size):0] rd_counter;

reg [23:0] line_buffer_mem [0:Buffer_Size - 1];

reg [$clog2(Buffer_Size):0] PixelCounter;

always @(posedge clk)
begin
    if(rst)
        PixelCounter <= 'b0;
    else begin
        if(input_is_valid)
            PixelCounter <= (PixelCounter == Buffer_Size) ? PixelCounter : PixelCounter + 1; 
    end
end

always @(posedge clk)
begin
    if(rst)
        wr_counter <= 'b0;
    else
    begin
        if(input_is_valid)
        begin
            line_buffer_mem[wr_counter] <= input_pixel;
            wr_counter <= (wr_counter == Buffer_Size - 1) ? 0 : wr_counter + 1; 
        end
    end
end

always @(posedge clk)
begin
    if(rst)
        rd_counter <= 'b0;
    else
    begin
        if(input_is_valid)
        begin
            if(PixelCounter == Buffer_Size)
                rd_counter <= (rd_counter == Buffer_Size -1 ) ? 0 : rd_counter + 1;
        end
    end
end

assign output_is_valid = (PixelCounter == Buffer_Size);
assign output_pixel = line_buffer_mem[rd_counter];

endmodule
