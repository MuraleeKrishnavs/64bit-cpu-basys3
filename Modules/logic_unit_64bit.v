`timescale 1ns / 1ps
module logic_unit_64bit (
    input  wire [63:0] A,
    input  wire [63:0] B,
    input  wire [3:0]  logic_sel,
    input  wire        enable,         // Master switch to activate/deactivate LU
    output reg  [63:0] result
);
// Dynamic shift amount (only 6 bits needed for 64-bit shifting)
wire [5:0] shamt = B[5:0]; 
always @(*) begin
    // Default value: Ensures no latches are inferred and output is 0 when disabled
    result = 64'd0;

    if (enable) begin
    case(logic_sel)
        // --- Bitwise Operations ---
        4'b0000: result = A & B;        // AND
        4'b0001: result = A | B;        // OR
        4'b0010: result = A ^ B;        // XOR
        4'b0011: result = ~(A | B);     // NOR
        4'b0100: result = ~(A & B);     // NAND
        4'b0101: result = ~(A ^ B);     // XNOR
        // --- Shifts ---
        4'b0110: result = A << shamt;                           // LSL
        4'b0111: result = A >> shamt;                           // LSR
        4'b1000: result = $signed(A) >>> shamt;                 // ASR
        // --- Rotates ---
        4'b1001: result = (A << shamt) | (A >> (64 - shamt));   // ROL
        4'b1010: result = (A >> shamt) | (A << (64 - shamt));   // ROR
        default: result = 64'd0;
    endcase
    end
end
endmodule
