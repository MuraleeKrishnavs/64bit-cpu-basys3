`timescale 1ns / 1ps
module register_file_64x32 #(
    parameter MEM_INIT_FILE = "data/reg_init.mem" // Default path relative to project root
)(
    input             clk,
    input             we,
    input      [4:0]  rs1_addr,
    input      [4:0]  rs2_addr,
    input      [4:0]  rd_addr,
    input      [63:0] write_data,
    output     [63:0] rs1_data,
    output     [63:0] rs2_data
);
// Register storage
reg [63:0] registers [0:31];
integer i;
// Initialization (Simulation only)
initial begin
    // Reset registers to 0
    for (i = 0; i < 32; i = i + 1) registers[i] = 64'd0;
    $readmemh(MEM_INIT_FILE, registers);
end
// Synchronous Write Operation
always @(posedge clk) begin
    if (we && (rd_addr != 5'd0)) begin
        registers[rd_addr] <= write_data;
    end
end
// Asynchronous Read Operation
assign rs1_data = (rs1_addr == 5'd0) ? 64'd0 : registers[rs1_addr];
assign rs2_data = (rs2_addr == 5'd0) ? 64'd0 : registers[rs2_addr];

endmodule