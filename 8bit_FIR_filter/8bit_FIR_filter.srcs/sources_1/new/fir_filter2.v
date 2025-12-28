`timescale 1ns / 1ps

module fir_filter2 #(parameter NUM_TAPS = 4)(
    input signed [7:0] input_signal,
    input clk, en, rst,
    output reg signed [16:0] output_signal
    );
    
    reg signed [16:0] acc;
    
    localparam integer ORDER = NUM_TAPS - 1;
    
    wire signed [7:0] taps[0:NUM_TAPS-1];
    reg signed [7:0] z_reg[0:ORDER-1];
    
    genvar i;
    generate
        for(i = 1; i < NUM_TAPS; i = i + 1) begin
            assign taps[i] = 8'b00100000;
        end
    endgenerate
    
    assign taps[0] = 8'b00100000;
    
    integer k;
    always @ (posedge clk) begin
        if(rst) begin
            for(k = 0; k < NUM_TAPS-1; k = k + 1)
                z_reg[k] <= 0;
        end
        if(en && ~rst) begin
            acc = taps[0] * input_signal;
            for(k = 1; k < NUM_TAPS; k = k + 1) begin
                acc = acc + (taps[k] * z_reg[k-1]);
            end
        end
        output_signal <= acc;
    end
    
endmodule
