`timescale 1ns / 1ps
module generic_memory #(
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH = 32
)(
    input clk,
    input we,
    input [ADDR_WIDTH-1:0] addr,
    input [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout
);
reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];
// Load the file on simulation start
initial begin
    $readmemh("program.mem", mem);
end
// Read operation (Asynchronous read, synchronous output)
always @(posedge clk) begin
    dout <= mem[addr];
end
// Write operation
always @(posedge clk) begin
    if (we) mem[addr] <= din;
end
endmodule
