`timescale 1ns / 1ps

module top_tb;

    // Testbench signals
    reg clk;
    reg rst;
    wire [3:0] q;

    // Instantiate the top module
    top uut (
        .clk(clk),
        .rst(rst),
        .q(q)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Test sequence
    initial begin
        // Initialize signals
        rst = 0;

        // Apply reset
        #10 rst = 1;
        #10 rst = 0;

        // Wait for some time to observe the counter
        #100;

        // Finish simulation
        $finish;
    end

    // Monitor counter value
    initial begin
        $monitor("At time %t, q = %h", $time, q);
    end

    // Dump signals to VCD file
    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
    end

endmodule

