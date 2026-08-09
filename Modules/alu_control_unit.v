`timescale 1ns / 1ps
module alu_control_unit (
    input  [5:0] alu_sel,
    input        start,
    // Integer Arithmetic Unit (IAU) Enables
    output reg   int_addsub_en,
    output reg   int_addsub_mode, 
    output reg   int_mul_en,
    output reg   int_div_en,
    // Floating-Point Unit (FPU) Enables
    output reg   fp_addsub_en,
    output reg   fp_addsub_mode,
    output reg   fp_mul_en,
    output reg   fp_div_en,
    // Logic Unit (LU) Control
    output reg   logic_en,      //Explicit enable for the Logic Unit
    output reg [3:0] logic_sel,
    // Final Output Routing (00 = IAU, 01 = FPU, 10 = LU)
    output reg [1:0] out_mux_sel  
);
always @(*) begin
    // Defaults: Turn everything OFF by default to prevent accidental triggers
    int_addsub_en = 0; int_addsub_mode = 0; int_mul_en = 0; int_div_en = 0;
    fp_addsub_en  = 0; fp_addsub_mode  = 0; fp_mul_en  = 0; fp_div_en  = 0;
    logic_en      = 0; // Logic is OFF by default
    logic_sel     = 4'b0000;
    out_mux_sel   = 2'b00; // Default to IAU
    
    if (start) begin
        case(alu_sel)
            // --- Integer Arithmetic (00xxxx) ---
            6'b000000: begin out_mux_sel = 2'b00; int_addsub_en = 1; int_addsub_mode = 0; end
            6'b000001: begin out_mux_sel = 2'b00; int_addsub_en = 1; int_addsub_mode = 1; end
            6'b000010: begin out_mux_sel = 2'b00; int_mul_en = 1; end
            6'b000011: begin out_mux_sel = 2'b00; int_div_en = 1; end
            
            // --- Floating-Point Arithmetic (01xxxx) ---
            6'b010000: begin out_mux_sel = 2'b01; fp_addsub_en = 1; fp_addsub_mode = 0; end
            6'b010001: begin out_mux_sel = 2'b01; fp_addsub_en = 1; fp_addsub_mode = 1; end
            6'b010010: begin out_mux_sel = 2'b01; fp_mul_en = 1; end
            6'b010011: begin out_mux_sel = 2'b01; fp_div_en = 1; end
            
            // --- Logic & Shift Operations (10xxxx) ---
            6'b100000: begin out_mux_sel = 2'b10; logic_en = 1; logic_sel = 4'b0000; end // AND
            6'b100001: begin out_mux_sel = 2'b10; logic_en = 1; logic_sel = 4'b0001; end // OR
            6'b100010: begin out_mux_sel = 2'b10; logic_en = 1; logic_sel = 4'b0010; end // XOR
            
            default:   begin out_mux_sel = 2'b00; end
        endcase
    end
end
endmodule
