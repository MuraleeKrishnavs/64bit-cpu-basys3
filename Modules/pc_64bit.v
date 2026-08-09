`timescale 1ns / 1ps
module pc_64bit (
    input             clk,
    input             rst,
    input             stall,         // Halts the PC (useful for multi-cycle ALU ops like DIV)
    input             branch_en,     // High if a jump/branch is taken
    input      [63:0] branch_target, // The address to jump to
    
    output reg [63:0] pc_out         // Current instruction address
);
// In pc_64bit.v
always @(posedge clk) begin
    if (rst) begin
        pc_out <= 64'd0;
    end else begin
        if (!stall) begin
            if (branch_en)
                pc_out <= branch_target;
            else
                pc_out <= pc_out + 4;
        end
    end
end
endmodule
