// Find the dark channel
module ALE_Minimum_3(
    input  [7:0] R,
    input  [7:0] G,
    input  [7:0] B,
    
    output [7:0] minimum
);

    function [7:0] min;
        input [7:0] x, y, z;
        begin
            min = (x < y) ? ((x < z) ? x : z) : ((y < z) ? y : z);
        end
    endfunction
    
    assign minimum = min(R, G, B);

endmodule
