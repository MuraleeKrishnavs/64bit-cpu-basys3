`timescale 1ns / 1ps
module instruction_decoder (
    input      [31:0] instruction, 
    // Register File Control
    output     [4:0]  rs1_addr,
    output     [4:0]  rs2_addr,
    output     [4:0]  rd_addr,
    output reg        reg_write_en,
    // ALU Control
    output reg        alu_start,
    output     [5:0]  alu_sel,
    // System Control
    output reg        is_branch,
    output reg        is_memory_op // High for Load/Store operations
);
// Unpack the instruction bit-fields
wire [5:0] main_opcode = instruction[31:26];
assign rs1_addr = instruction[25:21];
assign rs2_addr = instruction[20:16];
assign rd_addr  = instruction[15:11];
assign alu_sel  = instruction[10:5];

always @(*) begin
    reg_write_en = 1'b0;
    alu_start    = 1'b0;
    is_branch    = 1'b0;
    is_memory_op = 1'b0;

    case (main_opcode)
        6'b000000: begin
            reg_write_en = 1'b1;
            alu_start    = 1'b1; 
        end
        6'b000001: begin 
            reg_write_en = 1'b1;
            is_memory_op = 1'b1;
        end
        6'b000010: begin 
            reg_write_en = 1'b0; 
            is_memory_op = 1'b1;
        end
        6'b000011: begin 
            is_branch = 1'b1;
            alu_start = 1'b1; 
        end
        6'b100001: begin // Example Opcode for OR
             reg_write_en = 1'b1;
             alu_start    = 1'b1;
        end
        default: begin
            // NOP (No Operation) or Unrecognized Opcode
        end
    endcase
end
endmodule
