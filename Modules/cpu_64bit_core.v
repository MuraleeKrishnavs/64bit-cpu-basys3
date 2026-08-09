`timescale 1ns / 1ps
module cpu_64bit_core (
    input             clk,
    input             rst,
    output     [63:0] imem_addr,
    input      [31:0] instruction,
    output     [63:0] dmem_addr,
    output     [63:0] dmem_write_data,
    output            dmem_we,
    input      [63:0] dmem_read_data
);
// --- FETCH STAGE ---
reg [31:0] instr_pipe [1:0];
always @(posedge clk) begin
    if (rst) begin
        instr_pipe[0] <= 32'd0;
        instr_pipe[1] <= 32'd0;
    end else if (!stall_pipeline) begin
        instr_pipe[0] <= instruction;
        instr_pipe[1] <= instr_pipe[0];
    end
end
wire [31:0] decoded_instr = instr_pipe[1];

// --- DECODE STAGE ---
wire [4:0]  rs1_addr, rs2_addr, rd_addr;
wire        reg_write_en, alu_start, is_branch, is_memory_op;
wire [5:0]  alu_sel;

instruction_decoder U_DECODER (
    .instruction(decoded_instr), 
    .rs1_addr(rs1_addr), .rs2_addr(rs2_addr), .rd_addr(rd_addr),
    .reg_write_en(reg_write_en), .alu_start(alu_start),
    .alu_sel(alu_sel), .is_branch(is_branch), .is_memory_op(is_memory_op)
);

// ---EXECUTE STAGE ---
wire [63:0] rs1_data, rs2_data, alu_result;
wire        alu_done;

// Pulse generator to start ALU once
reg alu_start_reg;
always @(posedge clk or posedge rst) begin
    if (rst) alu_start_reg <= 1'b0;
    else     alu_start_reg <= alu_start;
end
wire start_pulse = alu_start && !alu_start_reg; 

// Register File
register_file_64x32 U_REG_FILE (
    .clk(clk),
    .we(reg_write_en_latched && alu_done), 
    .rs1_addr(rs1_addr), .rs2_addr(rs2_addr), 
    .rd_addr(rd_addr_latched),
    .write_data(reg_write_data),
    .rs1_data(rs1_data), .rs2_data(rs2_data)
);

alu_64bit_structure U_ALU_CORE (
    .clk(clk), .start(start_pulse),
    .A(rs1_data), .B(rs2_data), .alu_sel(alu_sel),
    .result(alu_result), .alu_done(alu_done)
);

// --- WRITEBACK / MEMORY STAGE ---
assign stall_pipeline = (alu_start && !alu_done);

reg [4:0]  rd_addr_latched;
reg        reg_write_en_latched;
reg [63:0] reg_write_data;

always @(posedge clk) begin
    if (rst) begin
        rd_addr_latched      <= 5'd0;
        reg_write_en_latched <= 1'b0;
    end else if (start_pulse) begin
        rd_addr_latched      <= rd_addr;
        reg_write_en_latched <= reg_write_en;
    end
end

always @(*) begin
    reg_write_data = is_memory_op ? dmem_read_data : alu_result;
end

assign dmem_addr   = alu_result; 
assign dmem_write_data = rs2_data;
assign dmem_we     = is_memory_op && (decoded_instr[31:26] == 6'b000010);

pc_64bit U_PC (.clk(clk), .rst(rst), .stall(stall_pipeline), .pc_out(imem_addr));

endmodule
