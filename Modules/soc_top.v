`timescale 1ns / 1ps
module soc_top (
    input clk,
    input rst,
    output led_0
);
// Wires to connect CPU to Instruction BRAM
wire [63:0] inst_addr;
wire [31:0] inst_data;

// Wires to connect CPU to Data BRAM
wire [63:0] data_addr;
wire [63:0] data_write;
wire        data_we;
wire [63:0] data_read;

//Instantiate Your CPU Core
cpu_64bit_core U_CPU (
    .clk(clk),
    .rst(rst),
    // Instruction Interface
    .imem_addr(inst_addr),
    .instruction(inst_data),
    // Data Interface
    .dmem_addr(data_addr),
    .dmem_write_data(data_write),
    .dmem_we(data_we),
    .dmem_read_data(data_read)
);

//Call the Instruction BRAM 
//Single Port ROM.
//32-bit instruction.
blk_mem_gen_0 U_INSTRUCTION_BRAM (
    .clka(clk),
    .ena(1'b1),            // Always enabled
    .addra(inst_addr[15:2]), // Truncate 64-bit addr to match BRAM depth 
    .douta(inst_data)      // Feeds directly into CPU 'instruction' port
);

//Call the Data BRAM (Generated in Vivado)
//Single Port RAM.
// It handles both reads (LOAD) and writes (STORE) from the CPU.
blk_mem_gen_1 U_DATA_BRAM (
    .clka(clk),
    .ena(1'b1),
    .wea(data_we),           // Write Enable from CPU
    .addra(data_addr[15:3]), // Truncate addr for 64-bit word alignment
    .dina(data_write),       // Data coming FROM CPU to save
    .douta(data_read)        // Data going TO CPU to read
);
assign led_0 = inst_addr[10];
endmodule
