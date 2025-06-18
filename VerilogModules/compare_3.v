module comparator_3(  
    input [7:0] a, b, c,
    output wire [1:0] smallest
);
    
    assign smallest = (a <= b && a <= c) ? 2'b00 : 
                      (b <= a && b <= c) ? 2'b01 : 
                                           2'b10;
    
endmodule