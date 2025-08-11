module WindowGenerator (
    input             clk,
    input             rst,
    
    input [23:0]      input_pixel_1,
    input [23:0]      input_pixel_2,
    input [23:0]      input_pixel_3,
    input             input_is_valid,

    output reg [23:0] output_pixel_1,
    output reg [23:0] output_pixel_2,
    output reg [23:0] output_pixel_3,
    output reg [23:0] output_pixel_4,
    output reg [23:0] output_pixel_5,
    output reg [23:0] output_pixel_6,
    output reg [23:0] output_pixel_7,
    output reg [23:0] output_pixel_8,
    output reg [23:0] output_pixel_9,
    output            output_is_valid
);

    localparam Rows = 512, Columns = 512;
    
    reg [7:0]  PixelCounter;
    reg [23:0] p1, p2, p3, p4, p5, p6, p7, p8, p9;
    
    reg [9:0] Row_counter, Column_counter;
    
    always @(posedge clk)
    begin
        if(rst)
            PixelCounter <= 0;
        else
        begin
            if(input_is_valid) begin
                PixelCounter <= (PixelCounter == 2) ? PixelCounter : PixelCounter + 1;
            end
        end
    end
    
    always @(posedge clk)
    begin
        if(rst)
        begin
            Row_counter <= 0;
            Column_counter <= 0;
        end else
        begin
            if(output_is_valid) begin
                Column_counter <= (Column_counter == Columns - 1) ? 0 : Column_counter + 1;
                        
                if(Column_counter == Columns - 1) begin
                    Row_counter <= (Row_counter == Rows - 1) ? 0 : Row_counter + 1;
                end
            end
        end
    end
    
    always @(posedge clk)
    begin
        if(rst)
        begin
            p1 <= 0; p2 <= 0; p3 <= 0;
            p4 <= 0; p5 <= 0; p6 <= 0;
            p7 <= 0; p8 <= 0; p9 <= 0;
        end else
        begin
            if(input_is_valid) begin
                p1 <= p2; p2 <= p3; p3 <= input_pixel_3;
                p4 <= p5; p5 <= p6; p6 <= input_pixel_2;
                p7 <= p8; p8 <= p9; p9 <= input_pixel_1;
            end
        end
    end
    
    // Handling all cases accordingly
    always @(*)
    begin
        if(rst)
        begin
            output_pixel_1 <= 0; output_pixel_2 <= 0; output_pixel_3 <= 0;
            output_pixel_4 <= 0; output_pixel_5 <= 0; output_pixel_6 <= 0;
            output_pixel_7 <= 0; output_pixel_8 <= 0; output_pixel_9 <= 0;
        end
        
        else
        begin
            if(output_is_valid) 
            begin
                if(Row_counter == 0 && Column_counter == 0) // Top left corner pixel
                begin
                    output_pixel_1 <= p5; output_pixel_2 <= p5; output_pixel_3 <= p6; // Replicate pixel posiitions 1,2,4 with 5
                    output_pixel_4 <= p5; output_pixel_5 <= p5; output_pixel_6 <= p6; // Replicate pixel posiition 3 with 6
                    output_pixel_7 <= p8; output_pixel_8 <= p8; output_pixel_9 <= p9; // Replicate pixel posiition 7 with 8
                end
                else if(Row_counter == 0 && Column_counter > 0 && Column_counter < Columns - 1) // First row edge pixels
                begin
                    output_pixel_1 <= p4; output_pixel_2 <= p5; output_pixel_3 <= p6; // Replicate pixel posiitions 1,2,3 with 4,5,6
                    output_pixel_4 <= p4; output_pixel_5 <= p5; output_pixel_6 <= p6;
                    output_pixel_7 <= p7; output_pixel_8 <= p8; output_pixel_9 <= p9;
                end
                else if(Row_counter == 0 && Column_counter == Columns - 1) // Top right corner pixel
                begin
                    output_pixel_1 <= p4; output_pixel_2 <= p5; output_pixel_3 <= p5; // Replicate pixel posiitions 2,3,6 with 5
                    output_pixel_4 <= p4; output_pixel_5 <= p5; output_pixel_6 <= p5; // Replicate pixel posiition 1 with 4
                    output_pixel_7 <= p7; output_pixel_8 <= p8; output_pixel_9 <= p8; // Replicate pixel posiition 9 with 8
                end
                else if(Row_counter > 0 && Row_counter < Rows - 1 && Column_counter == 0) // First column edge pixels
                begin
                    output_pixel_1 <= p2; output_pixel_2 <= p2; output_pixel_3 <= p3; // Replicate pixel posiitions 1,4,7 with 2,5,8
                    output_pixel_4 <= p5; output_pixel_5 <= p5; output_pixel_6 <= p6;
                    output_pixel_7 <= p8; output_pixel_8 <= p8; output_pixel_9 <= p9;
                end
                else if(Row_counter > 0 && Row_counter < Rows - 1 && Column_counter > 0 && Column_counter < Columns - 1) // Middle(default) cases
                begin
                    output_pixel_1 <= p1; output_pixel_2 <= p2; output_pixel_3 <= p3;
                    output_pixel_4 <= p4; output_pixel_5 <= p5; output_pixel_6 <= p6;
                    output_pixel_7 <= p7; output_pixel_8 <= p8; output_pixel_9 <= p9;
                end
                else if(Row_counter > 0 && Row_counter < Rows - 1 && Column_counter == Columns - 1) // Last column edge pixels
                begin
                    output_pixel_1 <= p1; output_pixel_2 <= p2; output_pixel_3 <= p2; // Replicate pixel positions 3,6,9 with 2,5,8
                    output_pixel_4 <= p4; output_pixel_5 <= p5; output_pixel_6 <= p5;
                    output_pixel_7 <= p7; output_pixel_8 <= p8; output_pixel_9 <= p8;
                end
                else if(Row_counter == Rows - 1 && Column_counter == 0) // Bottom left corner pixel
                begin
                    output_pixel_1 <= p2; output_pixel_2 <= p2; output_pixel_3 <= p3; // Replicate pixel positions 1,4,7 with 2,5,5
                    output_pixel_4 <= p5; output_pixel_5 <= p5; output_pixel_6 <= p6; // Replicate pixel positions 8,9 with 5,6
                    output_pixel_7 <= p5; output_pixel_8 <= p5; output_pixel_9 <= p6;
                end
                else if(Row_counter == Rows - 1 && Column_counter > 0 && Column_counter < Columns - 1) // Last row edge pixels
                begin
                    output_pixel_1 <= p1; output_pixel_2 <= p2; output_pixel_3 <= p3; // Replicate pixel positions 7,8,9 with 4,5,6
                    output_pixel_4 <= p4; output_pixel_5 <= p5; output_pixel_6 <= p6;
                    output_pixel_7 <= p4; output_pixel_8 <= p5; output_pixel_9 <= p6;
                end
                else if(Row_counter == Rows - 1 && Column_counter == Columns - 1) // Bottom right corner pixel
                begin
                output_pixel_1 <= p1; output_pixel_2 <= p2; output_pixel_3 <= p2; // Replicate pixel positions 6,8,9 with 5
                output_pixel_4 <= p4; output_pixel_5 <= p5; output_pixel_6 <= p5; // Replicate pixel positions 3,7 with 2,4
                output_pixel_7 <= p4; output_pixel_8 <= p5; output_pixel_9 <= p5;
                end
            end
        end
    end

    assign output_is_valid = (PixelCounter == 2) ? 1 : 0;
    
endmodule
