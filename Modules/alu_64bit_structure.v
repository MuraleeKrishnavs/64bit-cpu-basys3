`timescale 1ns / 1ps
module alu_64bit_structure (
    input         clk,
    input         start,
    input  [63:0] A,
    input  [63:0] B,
    input  [5:0]  alu_sel,
    output reg [63:0] result,
    output reg        alu_done,
    // Flags
    output        flag_zero,
    output        flag_negative,
    output        flag_carry,
    output        flag_overflow,
    output        flag_parity
);
// Internal wires
wire int_addsub_en, int_addsub_mode, int_mul_en, int_div_en;
wire fp_addsub_en, fp_addsub_mode, fp_mul_en, fp_div_en;
wire logic_en;        // Bridge from CU to LU
wire [3:0] logic_sel;
wire [1:0] out_mux_sel;
wire [63:0] int_res, fp_res, lu_res;
wire int_done, fp_done, int_carry;

//Control Unit
alu_control_unit U_CU (
    .alu_sel(alu_sel), .start(start),
    .int_addsub_en(int_addsub_en), .int_addsub_mode(int_addsub_mode),
    .int_mul_en(int_mul_en), .int_div_en(int_div_en),
    .fp_addsub_en(fp_addsub_en), .fp_addsub_mode(fp_addsub_mode),
    .fp_mul_en(fp_mul_en), .fp_div_en(fp_div_en),
    .logic_en(logic_en),   // Connect Control Unit enable
    .logic_sel(logic_sel), 
    .out_mux_sel(out_mux_sel)
);
//Integer Unit
integer_arithmetic_unit_64bit U_IAU (
    .clk(clk), .A(A), .B(B),
    .int_addsub_en(int_addsub_en), .int_addsub_mode(int_addsub_mode),
    .int_mul_en(int_mul_en), .int_div_en(int_div_en),
    .result(int_res), .carry_out(int_carry), .done(int_done)
);
//Floating Point Unit
floating_point_unit_64bit U_FPU (
    .clk(clk), .A(A), .B(B),
    .fp_addsub_en(fp_addsub_en), .fp_addsub_mode(fp_addsub_mode),
    .fp_mul_en(fp_mul_en), .fp_div_en(fp_div_en),
    .result(fp_res), .done(fp_done)
);
//Logic Unit
logic_unit_64bit U_LU (
    .A(A), .B(B), .logic_sel(logic_sel),
    .enable(logic_en), // Connect Logic Unit enable
    .result(lu_res)
);
//Flag Unit
flag_unit_64bit U_FLAGS (
    .A(A), .B(B), .result(result),
    .addsub_en(int_addsub_en), .addsub_mode(int_addsub_mode), .au_carry_in(int_carry),
    .flag_zero(flag_zero), .flag_negative(flag_negative),
    .flag_carry(flag_carry), .flag_overflow(flag_overflow), .flag_parity(flag_parity)
);
//Output Mux & Done Synchronization
reg lu_done_delayed;

always @(posedge clk) begin
    lu_done_delayed <= start; 
end

always @(*) begin
    case(out_mux_sel)
        2'b00: begin 
            result   = int_res; 
            alu_done = int_done; 
        end
        2'b01: begin 
            result   = fp_res;  
            alu_done = fp_done;  
        end
        2'b10: begin 
            result   = lu_res;  
            alu_done = lu_done_delayed; 
        end
        default: begin 
            result   = 64'd0; 
            alu_done = 1'b0;    
        end
    endcase
end
// Simulation Debugging
always @(posedge clk) begin
    if (start) 
        $display("ALU DEBUG: Start received! Sel=%h, Int_En=%b", alu_sel, int_addsub_en);
    if (alu_done) 
        $display("ALU DEBUG: Done! Result=%h", result);
end

endmodule
