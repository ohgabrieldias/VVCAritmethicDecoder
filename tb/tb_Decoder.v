`timescale 1ns / 1ps

module Decoder_tb;
    // Parameters for the testbench
    parameter CLOCK_PERIOD = 10; // Clock period in ns

    // Testbench signals
    reg clk;               // Clock signal
    reg reset;             // Reset signal
    reg bypass;            // Bypass flag
    wire bin;              // Output from the Decoder module

    // Instantiate the Decoder module
    Decoder DECODER (
        .clk(clk),
        .reset(reset),
        .bypass(bypass),
        .bin(bin)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLOCK_PERIOD / 2) clk = ~clk; // Toggle clock
    end

    // Stimulus block
    initial begin
        // Initialize signals
        reset = 1;  // Assert reset
        bypass = 0; // Start without bypass
        #15;         // Wait for 15 ns

        reset = 0; // Deassert reset
        #10;       // Wait for 10 ns

        // Apply different test cases
        // Test Case 1: Normal operation
        bypass = 0;
        #20; // Wait for 20 ns
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | reset: %b | bypass: %b | bin: %b", $time, reset, bypass, bin);
    end
endmodule
