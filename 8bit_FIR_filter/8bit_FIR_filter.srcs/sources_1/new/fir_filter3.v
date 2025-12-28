`timescale 1ns / 1ps

module fir_filter3 #(parameter NUM_TAPS = 4, parameter Q = 7)(
    input signed [7:0] input_signal,
    input clk, en, rst,
    output reg signed [16:0] output_signal
    );
    
    reg signed [16:0] acc;                  // accumulator variable
    
    reg signed [7:0] taps[0:NUM_TAPS-1];    // all the taps
    reg signed [7:0] z_reg[0:NUM_TAPS-1];   // hold x[n-k] samples (z^-1 blocks, but includes [n-0] sample)
    
    localparam integer Q_SCALE = 1 << Q;                // scaled to 2^Q                         
    localparam signed [7:0] tap_value = Q_SCALE / NUM_TAPS;    // added into taps array
        
    // initialize taps and samples to corresponding values    
    integer i;
    initial begin
        for(i = 0; i < NUM_TAPS; i = i + 1) begin
            taps[i] = tap_value;  // 0.25 (1/(# taps), so 1/4)
            z_reg[i] = 8'b0;        // initialize to 0
        end
    end
    
    // MAC block -> main computation
    integer k;
    always @ (*) begin
        acc = input_signal * taps[0];
        for(k = 1; k < NUM_TAPS; k = k + 1) begin
            acc = acc + z_reg[k - 1] * taps[k];
        end
    end
    
    // functionality and register update block
    always @ (posedge clk) begin
        if(rst) begin
            for(k = 0; k < NUM_TAPS; k = k + 1)
                z_reg[k] <= 0;  // reset samples to 0
            output_signal <= 0; // reset output to 0
        end
        else if (en) begin
            for(k = NUM_TAPS-1; k > 0; k = k - 1) 
                z_reg[k] <= z_reg[k-1]; // shift samples down (left shift technically)
            z_reg[0] <= input_signal;   // shift input signal into first z_reg sample
            output_signal <= (acc >>> Q);       // arithmetically shift accumulator variable, set output to accumulator variable
        end
    
    end
    
endmodule
