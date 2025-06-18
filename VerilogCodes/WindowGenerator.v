`timescale 1ns/1ps
module WindowGenerator(
    input wire r_clk, r_rst,
    input wire [23:0] input_pixel_data,
    input wire input_is_valid,
    
    output wire [71:0] red_window_out,
    output wire [71:0] green_window_out,
    output wire [71:0] blue_window_out,
    output wire output_is_valid, 
    output reg interrupt
);
parameter Pixel_Size = 24; //rgb pixel
parameter Row_Size = 512; //line buffer size
reg [12:0] image_pixel_count; // counts total pixels read of image
reg [1:0] current_write_buffer; // monitors which line buffer is currently being written to
reg [8:0] write_pixel_count; // counts how many pixels have been written to a line buffer so far
reg [7:0] red_window[8:0]; // red window output
reg [7:0] green_window[8:0]; //green window output
reg [7:0] blue_window[8:0]; //blue window output
reg start_window_gen; //control signal to begin window generation
wire [71:0]lb0_out,lb1_out,lb2_out,lb3_out; //output data from line buffers
//valid control signals for line buffers
wire LB0_data_valid,LB1_data_valid,LB2_data_valid,LB3_data_valid;
reg [3:0]rd_line_buffers; //indicates which buffers must be read from
//updates number of pixels written to a buffer
always @(posedge r_clk)
begin
    if(r_rst)
        write_pixel_count <= 0;
    else if(input_is_valid)
        write_pixel_count <= write_pixel_count + 1;
end
//switches the line buffer which has to be written to, as well the line buffers being read from
always @(posedge r_clk)
begin
    if(r_rst)
        begin
            current_write_buffer <= 2'b00;
            rd_line_buffers <= 4'b0000;
        end
    else if(write_pixel_count == 511)
        begin
            current_write_buffer <= (current_write_buffer == 2'b11 ? 2'b00 : current_write_buffer + 1);
            case(rd_line_buffers)
            4'b1110: rd_line_buffers <= 'b0111;
            4'b0111: rd_line_buffers <= 'b1011;
            4'b1011: rd_line_buffers <= 'b1101;
            4'b1101: rd_line_buffers <= 'b1110;
            default: rd_line_buffers <= 4'b0000;
            endcase
        end
end
//updates total pixels read from image
always @(posedge r_clk)
begin
    if(r_rst)
        image_pixel_count <= 'b0;
    else if(input_is_valid)
        image_pixel_count <= image_pixel_count + 1;
end
//asserts window generation control signal when three line buffers are full
always @(posedge r_clk)
begin
    if(r_rst || image_pixel_count < 1536)
        begin
            start_window_gen <= 'b0;
            interrupt <= 0;
        end
    else if(image_pixel_count == 1536)
        begin
            start_window_gen <= 'b1;
            rd_line_buffers <= 'b1110;
            interrupt <= 1;
        end
    else
        begin
            start_window_gen <= 'b1;
            interrupt <= 1;
        end
end
// assign the line buffer valid inputs
assign LB0_data_valid = input_is_valid & ~current_write_buffer[0] & ~current_write_buffer[1];
assign LB1_data_valid = input_is_valid & ~current_write_buffer[0] &  current_write_buffer[1];
assign LB2_data_valid = input_is_valid &  current_write_buffer[0] & ~current_write_buffer[1];
assign LB3_data_valid = input_is_valid &  current_write_buffer[0] &  current_write_buffer[1];
//window generation
always @(posedge r_clk)
begin
    if(start_window_gen)
    begin
        case(current_write_buffer)
        2'b11:
            begin
                red_window[0] <= lb0_out[71:64]; red_window[1] <= lb0_out[47:40]; red_window[2] <= lb0_out[23:16];
                red_window[3] <= lb1_out[71:64]; red_window[4] <= lb1_out[47:40]; red_window[5] <= lb1_out[23:16];
                red_window[6] <= lb2_out[71:64]; red_window[7] <= lb2_out[47:40]; red_window[8] <= lb2_out[23:16];
            
                green_window[0] <= lb0_out[63:56]; green_window[1] <= lb0_out[39:32]; green_window[2] <= lb0_out[15:8];
                green_window[3] <= lb1_out[63:56]; green_window[4] <= lb1_out[39:32]; green_window[5] <= lb1_out[15:8];
                green_window[6] <= lb2_out[63:56]; green_window[7] <= lb2_out[39:32]; green_window[8] <= lb2_out[15:8];
            
                blue_window[0] <= lb0_out[55:48]; blue_window[1] <= lb0_out[31:24]; blue_window[2] <= lb0_out[7:0];
                blue_window[3] <= lb1_out[55:48]; blue_window[4] <= lb1_out[31:24]; blue_window[5] <= lb1_out[7:0];
                blue_window[6] <= lb2_out[55:48]; blue_window[7] <= lb2_out[31:24]; blue_window[8] <= lb2_out[7:0];
            end
        
        2'b10:
            begin
                red_window[0] <= lb3_out[71:64]; red_window[1] <= lb3_out[47:40]; red_window[2] <= lb3_out[23:16];
                red_window[3] <= lb0_out[71:64]; red_window[4] <= lb0_out[47:40]; red_window[5] <= lb0_out[23:16];
                red_window[6] <= lb1_out[71:64]; red_window[7] <= lb1_out[47:40]; red_window[8] <= lb1_out[23:16];                    
                
                green_window[0] <= lb3_out[63:56]; green_window[1] <= lb3_out[39:32]; green_window[2] <= lb3_out[15:8];
                green_window[3] <= lb0_out[63:56]; green_window[4] <= lb0_out[39:32]; green_window[5] <= lb0_out[15:8];
                green_window[6] <= lb1_out[63:56]; green_window[7] <= lb1_out[39:32]; green_window[8] <= lb1_out[15:8];
                    
                blue_window[0] <= lb3_out[55:48]; blue_window[1] <= lb3_out[31:24]; blue_window[2] <= lb3_out[7:0];
                blue_window[3] <= lb0_out[55:48]; blue_window[4] <= lb0_out[31:24]; blue_window[5] <= lb0_out[7:0];
                blue_window[6] <= lb1_out[55:48]; blue_window[7] <= lb1_out[31:24]; blue_window[8] <= lb1_out[7:0];
            end
        
        2'b01:
            begin
                red_window[0] <= lb2_out[71:64]; red_window[1] <= lb2_out[47:40]; red_window[2] <= lb2_out[23:16];
                red_window[3] <= lb3_out[71:64]; red_window[4] <= lb3_out[47:40]; red_window[5] <= lb3_out[23:16];
                red_window[6] <= lb0_out[71:64]; red_window[7] <= lb0_out[47:40]; red_window[8] <= lb0_out[23:16];
                        
                green_window[0] <= lb2_out[63:56]; green_window[1] <= lb2_out[39:32]; green_window[2] <= lb2_out[15:8];
                green_window[3] <= lb3_out[63:56]; green_window[4] <= lb3_out[39:32]; green_window[5] <= lb3_out[15:8];
                green_window[6] <= lb0_out[63:56]; green_window[7] <= lb0_out[39:32]; green_window[8] <= lb0_out[15:8];
                      
                blue_window[0] <= lb2_out[55:48]; blue_window[1] <= lb2_out[31:24]; blue_window[2] <= lb2_out[7:0];
                blue_window[3] <= lb3_out[55:48]; blue_window[4] <= lb3_out[31:24]; blue_window[5] <= lb3_out[7:0];
                blue_window[6] <= lb0_out[55:48]; blue_window[7] <= lb0_out[31:24]; blue_window[8] <= lb0_out[7:0];
            end
                    
        2'b00:
            begin
                red_window[0] <= lb1_out[71:64]; red_window[1] <= lb1_out[47:40]; red_window[2] <= lb1_out[23:16];
                red_window[3] <= lb2_out[71:64]; red_window[4] <= lb2_out[47:40]; red_window[5] <= lb2_out[23:16];
                red_window[6] <= lb3_out[71:64]; red_window[7] <= lb3_out[47:40]; red_window[8] <= lb3_out[23:16];                    
                            
                green_window[0] <= lb1_out[63:56]; green_window[1] <= lb1_out[39:32]; green_window[2] <= lb1_out[15:8];
                green_window[3] <= lb2_out[63:56]; green_window[4] <= lb2_out[39:32]; green_window[5] <= lb2_out[15:8];
                green_window[6] <= lb3_out[63:56]; green_window[7] <= lb3_out[39:32]; green_window[8] <= lb3_out[15:8];
                                
                blue_window[0] <= lb1_out[55:48]; blue_window[1] <= lb1_out[31:24]; blue_window[2] <= lb1_out[7:0];
                blue_window[3] <= lb2_out[55:48]; blue_window[4] <= lb2_out[31:24]; blue_window[5] <= lb2_out[7:0];
                blue_window[6] <= lb3_out[55:48]; blue_window[7] <= lb3_out[31:24]; blue_window[8] <= lb3_out[7:0];
            end
        
        endcase
    end
end
//line buffer instantiations
LineBuffer lb0(
    .clk(r_clk),
    .rst(r_rst),
    .input_pixel(input_pixel_data),
    .input_is_valid(LB0_data_valid),
    .read_buffer_enable(rd_line_buffers[3]),
    .output_pixel(lb0_out)
);
LineBuffer lb1(
    .clk(r_clk),
    .rst(r_rst),
    .input_pixel(input_pixel_data),
    .input_is_valid(LB1_data_valid),
    .read_buffer_enable(rd_line_buffers[2]),
    .output_pixel(lb1_out)
);
LineBuffer lb2(
    .clk(r_clk),
    .rst(r_rst),
    .input_pixel(input_pixel_data),
    .input_is_valid(LB2_data_valid),
    .read_buffer_enable(rd_line_buffers[1]),
    .output_pixel(lb2_out)
);
LineBuffer lb3(
    .clk(r_clk),
    .rst(r_rst),
    .input_pixel(input_pixel_data),
    .input_is_valid(LB3_data_valid),
    .read_buffer_enable(rd_line_buffers[0]),
    .output_pixel(lb3_out)
);
assign output_is_valid = start_window_gen;
//output windows assignment
assign red_window_out = {red_window[8],red_window[7],red_window[6],
                            red_window[5],red_window[4],red_window[3],
                                red_window[2],red_window[1],red_window[0]};
                                
assign green_window_out = {green_window[8],green_window[7],green_window[6],
                            green_window[5],green_window[4],green_window[3],
                                green_window[2],green_window[1],green_window[0]};
                                
assign blue_window_out = {blue_window[8],blue_window[7],blue_window[6],
                            blue_window[5],blue_window[4],blue_window[3],
                                blue_window[2],blue_window[1],blue_window[0]};
endmodule
