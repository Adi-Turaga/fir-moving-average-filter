`timescale 1ns / 1ps

module testbench();

    parameter NUM_TAPS = 32;

    reg clk = 0, en, rst;
    reg signed [7:0] input_signal;
    reg signed [7:0] data[299:0];
    wire signed [16:0] output_signal;
    
    fir_filter3 #(.NUM_TAPS(NUM_TAPS), .Q(7)) UUT (
        .clk(clk), .en(en), .rst(rst),
        .input_signal(input_signal), .output_signal(output_signal)
    );
    
    integer k; // counter for loop
    integer FILE1; // file for filtered data
    
    reg [8*32-1:0] file_name;
    
    always #10 clk = ~clk;
    
    initial begin
        k = 0;
        
        $sformat(file_name, "output_%0dtaps.dat", NUM_TAPS); // format output data filename
        $readmemh("input.dat", data);
        FILE1 = $fopen(file_name, "w");

        if (FILE1 == 0) begin
            $display("ERROR: cannot open output.dat for writing.");
            $finish;
        end 
        
        clk = 0;
        #20;
        rst = 1'b1;
        en = 1'b0;
        #40;
        
        rst = 1'b0;
        en = 1'b1;
        input_signal <= data[k];
        #10;
        
        for(k = 1; k < 299; k = k + 1) begin
            @ (posedge clk);
            $fdisplay(FILE1, "%h", output_signal);
            input_signal <= data[k];
        end 
        
        $fclose(FILE1);
        $finish;
        
    end

endmodule
