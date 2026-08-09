# 64-bit CPU / SoC Core (Basys3 FPGA)

A Verilog implementation of a custom 64-bit CPU core — integer ALU, floating-point unit, register file, program counter, and instruction decoder — wrapped in an SoC top level and targeting the Digilent Basys3 (Artix-7) FPGA board.

> The architecture notes below are inferred from the project's module and file names (this repo currently ships the `.xpr` project file, not the Verilog sources themselves) — worth double-checking against the actual RTL and correcting anything that doesn't match.

## Features

- Custom 64-bit CPU datapath (`cpu_64bit_core`) with instruction decode, ALU, logic unit, and flag generation
- Floating-point unit built on Xilinx Floating-Point Operator IP
- Integer arithmetic unit using dedicated adder/subtractor, multiplier, and divider IP cores
- Register file and 64-bit program counter
- Program memory preloaded from a `.coe` file (`my_program.coe`)
- Testbench (`tb_soc.v`) for simulation in the Vivado Simulator

## Hardware & Tools

| | |
|---|---|
| Board | Digilent Basys3 |
| FPGA | Xilinx Artix-7, `xc7a35tcpg236-2L` |
| HDL | Verilog |
| Toolchain | Xilinx Vivado 2025.1 |
| Top module | `soc_top` |
| Testbench top | `tb_soc` |

## Architecture

| File | Role |
|---|---|
| `soc_top.v` | Top-level SoC — instantiates the CPU core and memory |
| `cpu_64bit_core.v` | CPU datapath and control |
| `instruction_decoder.v` | Decodes fetched instructions |
| `pc_64bit.v` | 64-bit program counter |
| `register_file_64x32.v` | CPU register file |
| `alu_64bit_structure.v` | Top-level ALU |
| `alu_control_unit.v` | ALU operation decode/control |
| `integer_arithematic_unit.v` | Integer add/sub/mul/div, built on the `c_addsub_0`, `mult_gen_0`, `div_gen_0` IP cores |
| `logic_unit_64bit.v` | Bitwise logic operations |
| `floating_point_unit_64bit.v` | Floating-point operations, built on the `floating_point_0/1/2` IP cores |
| `flag_unit_64bit.v` | Status flag generation (zero/carry/overflow, etc.) |
| `generic_memory.v` | Generic memory model (currently disabled in the project in favor of the Block Memory Generator IPs) |

## IP Cores Used

| IP Core | Purpose |
|---|---|
| Floating-Point Operator ×3 (`floating_point_0`, `floating_point_1`, `floating_point_2`) | FPU operations |
| Adder/Subtracter (`c_addsub_0`) | Integer add/sub |
| Multiplier Generator (`mult_gen_0`) | Integer multiply |
| Divider Generator (`div_gen_0`) | Integer divide |
| Block Memory Generator ×2 (`blk_mem_gen_0`, `blk_mem_gen_1`) | Instruction / data memory |

## Repository Structure

```
.
├── 64bit.xpr           # Vivado project file
├── Modules/              # CPU core, ALU, FPU, register file, decoder, etc. (.v)
├── ip/                    # Generated IP cores (.xci) — floating-point, mult/div/addsub, block RAM
├── my_program.coe          # Program memory initialization file
├── LICENSE
└── README.md
```

## Getting Started

1. Clone this repository
2. Open `64bit.xpr` in Vivado 2025.1 (or let Vivado upgrade the project if you're on a newer version)
3. If prompted, let Vivado regenerate the IP cores (`floating_point_0/1/2`, `c_addsub_0`, `mult_gen_0`, `div_gen_0`, `blk_mem_gen_0/1`) — `.xci` files are IP customizations, not portable RTL, and often need a re-generate step on a fresh machine
4. Confirm `my_program.coe` is set as the initialization file for the relevant Block Memory Generator core, so program memory loads correctly
5. Run the `tb_soc` testbench in simulation to verify behavior before building hardware
6. Run Synthesis → Implementation → Generate Bitstream, then program the Basys3 board

## Possible Extensions

- Document the instruction set / ISA the `instruction_decoder` implements
- Add more testbench coverage per functional unit (ALU, FPU, register file) alongside the top-level `tb_soc`
- Re-enable or remove `generic_memory.v` and `design_1.bd` if they're superseded by the current IP-based memory setup
- Add a block diagram of the SoC datapath

## License

Licensed under the [MIT License](LICENSE) — free to use, modify, and share, with attribution.
