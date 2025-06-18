`timescale 1ns / 1ps
`define headerSize 54
`define imageSize 512*512

module tb_ALE();
    reg clk;
    reg reset;
    reg [23:0] imgData;
    integer file, i;
    reg imgDataValid;
    integer sentSize;
    wire intr;
    
    wire [7:0] a_r, a_g, a_b;
    wire [15:0] inv_a_r, inv_a_g, inv_a_b;
    wire ale_valid;
    
    integer receivedData = 0;
    reg [7:0] red, green, blue;

    initial
    begin
        clk = 1'b0;
        forever
        begin
            #5 clk = ~clk;
        end
    end

    initial
    begin
        reset = 0;
        sentSize = 0;
        imgDataValid = 0;
        #100;
        reset = 1;
        #100;
        file = $fopen("canyon_512.bmp","rb");
        
        if (file == 0) begin
            $display("Error: Failed to open input file");
            $finish;
        end

        for(i=0; i<`headerSize; i=i+1)
        begin
            $fscanf(file,"%c",red);
        end

        for(i=0; i<4*512; i=i+1)
        begin
            @(posedge clk);
            $fscanf(file,"%c",blue);
            $fscanf(file,"%c",green);
            $fscanf(file,"%c",red);
            imgData <= {red, green, blue};
            imgDataValid <= 1'b1;
        end
        sentSize = 4*512;
        @(posedge clk);
        imgDataValid <= 1'b0;

        while(sentSize < `imageSize)
        begin
            @(posedge intr);
            for(i=0; i<512; i=i+1)
            begin
                @(posedge clk);
                $fscanf(file,"%c",blue);
                $fscanf(file,"%c",green);
                $fscanf(file,"%c",red);
                imgData <= {red, green, blue};
                imgDataValid <= 1'b1;    
            end
            @(posedge clk);
            imgDataValid <= 1'b0;
            sentSize = sentSize+512;
        end

        @(posedge clk);
        imgDataValid <= 1'b0;
        @(posedge intr);
        for(i=0; i<512; i=i+1)
        begin
            @(posedge clk);
            imgData <= 24'd0;
            imgDataValid <= 1'b1;    
        end
        @(posedge clk);
        imgDataValid <= 1'b0;
        @(posedge intr);
        for(i=0; i<512; i=i+1)
        begin
            @(posedge clk);
            imgData <= 24'd0;
            imgDataValid <= 1'b1;    
        end
        @(posedge clk);
        imgDataValid <= 1'b0;
        $fclose(file);

        #10000;
        $display("Simulation completed.");
        $finish;
    end
    
    always @(posedge clk)
    begin
        if(ale_valid)
        begin
            $display("Atmospheric Light Values - R: %d, G: %d, B: %d", 
                     a_r, a_g, a_b);
            $display("Inverse Atmospheric Light Values - R: %d, G: %d, B: %d", 
                     inv_a_r, inv_a_g, inv_a_b);
            receivedData = receivedData + 1;
        end
    end

    ALE_Top dut(
        .clk(clk),
        .rst(~reset),
        .i_pixel_data(imgData),
        .i_pixel_data_valid(imgDataValid),
        .o_a_r(a_r),
        .o_a_g(a_g),
        .o_a_b(a_b),
        .o_inv_a_r(inv_a_r),
        .o_inv_a_g(inv_a_g),
        .o_inv_a_b(inv_a_b),
        .o_ale_valid(ale_valid),
        .o_intr(intr)
    );   
    
endmodule
