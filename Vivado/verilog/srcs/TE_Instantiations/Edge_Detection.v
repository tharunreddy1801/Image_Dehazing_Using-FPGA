
module ED (
    input  [7:0] input_pixel_1,
    input  [7:0] input_pixel_2,
    input  [7:0] input_pixel_3,
    input  [7:0] input_pixel_4,

    input  [7:0] input_pixel_6,
    input  [7:0] input_pixel_7,
    input  [7:0] input_pixel_8,
    input  [7:0] input_pixel_9,
    
    output [1:0] ED_out
);

    parameter DIAGONAL_EDGE = 2, 
              VERTICAL_HORIZONTAL_EDGE = 1, 
              NO_EDGE = 0;
    
    parameter THRESHOLD = 80; // Threshold Value for Edge Detection
    
    wire [7:0] diagonal1  = (input_pixel_1 > input_pixel_9) ? (input_pixel_1 - input_pixel_9) : (input_pixel_9 - input_pixel_1);
    wire [7:0] diagonal2  = (input_pixel_3 > input_pixel_7) ? (input_pixel_3 - input_pixel_7) : (input_pixel_7 - input_pixel_3);
    wire [7:0] horizontal = (input_pixel_4 > input_pixel_6) ? (input_pixel_4 - input_pixel_6) : (input_pixel_6 - input_pixel_4);
    wire [7:0] vertical   = (input_pixel_2 > input_pixel_8) ? (input_pixel_2 - input_pixel_8) : (input_pixel_8 - input_pixel_2);
    
    wire cond1 = (diagonal1 >= THRESHOLD) || (diagonal2 >= THRESHOLD);
    wire cond2 = (horizontal >= THRESHOLD) || (vertical >= THRESHOLD);
    
    assign ED_out = cond1 ? DIAGONAL_EDGE : 
                    cond2 ? VERTICAL_HORIZONTAL_EDGE : 
                    NO_EDGE;

endmodule
