module top (
    input wire clk,      // Clock input
    input wire rst,      // Reset input (active high)
    output reg [3:0] q   // 4-bit counter output
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 4'b0000; // Reset counter to 0
        end else begin
            q <= q + 1;   // Increment counter
        end
    end

endmodule

