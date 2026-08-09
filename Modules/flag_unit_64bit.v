`timescale 1ns / 1ps
module flag_unit_64bit (
    input  [63:0] A,
    input  [63:0] B,
    input  [63:0] result,        // The final 64-bit result of the ALU
    // Control signals passed from the Control Unit & Integer Unit
    input         addsub_en,     // High if an integer Add/Sub is happening
    input         addsub_mode,   // 0 = Add, 1 = Sub
    input         au_carry_in,   // Raw carry-out bit captured from the Adder/Subtractor IP
    // The 5 standard processor status flags
    output        flag_zero,
    output        flag_negative,
    output        flag_carry,
    output        flag_overflow,
    output        flag_parity
);
// 1. Zero Flag (Z)
// High if all 64 bits of the result are 0.
assign flag_zero = (result == 64'd0);
// 2. Negative Flag (N)
// High if the Most Significant Bit (MSB) is 1, indicating a negative two's complement number.
assign flag_negative = result[63];
// 3. Parity Flag (P)
// High if there is an EVEN number of 1s in the result (using XNOR reduction).
assign flag_parity = ~^result;
// 4. Carry Flag (C)
// Only valid during Arithmetic Addition/Subtraction. Otherwise, default to 0.
assign flag_carry = addsub_en ? au_carry_in : 1'b0;
// 5. Overflow Flag (V)
// Only valid for SIGNED arithmetic. High if the result crosses the 64-bit signed boundary.
wire sign_a = A[63];
wire sign_b = B[63];
wire sign_r = result[63];

// Addition Overflow: Positive + Positive = Negative OR Negative + Negative = Positive
// Subtraction Overflow: Positive - Negative = Negative OR Negative - Positive = Positive
assign flag_overflow = (addsub_en && !addsub_mode) ? ((sign_a == sign_b) && (sign_r != sign_a)) : 
                       (addsub_en && addsub_mode)  ? ((sign_a != sign_b) && (sign_r != sign_a)) : 
                       1'b0;
                       
endmodule

