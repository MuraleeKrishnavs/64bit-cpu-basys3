`timescale 1ns / 1ps
module integer_arithmetic_unit_64bit (
    input             clk,
    input             rst,
    input      [63:0] A,
    input      [63:0] B,
    
    input             int_addsub_en,
    input             int_addsub_mode, // 0=Add, 1=Sub
    input             int_mul_en,
    input             int_div_en,
    
    output reg [63:0] result,
    output reg        carry_out, 
    output reg        done
);
// Internal wires
wire [63:0] addsub_res;
wire        addsub_cout;
wire [127:0] mul_res;
wire [127:0] div_res;
wire         div_valid; 
// ADDSUB IP 
c_addsub_0 U_INT_ADDSUB (
    .A(A), 
    .B(B), 
    .ADD(~int_addsub_mode), 
    .CE(int_addsub_en),      
    .CLK(clk), 
    .S(addsub_res), 
    .C_OUT(addsub_cout) 
);
//MULTIPLIER IP 
mult_gen_0 U_INT_MUL (
    .CLK(clk), 
    .A(A), 
    .B(B), 
    .P(mul_res)
);
//DIVIDER IP (AXI-Stream)
div_gen_0 U_INT_DIV (
    .aclk(clk), 
    .s_axis_divisor_tvalid(int_div_en), 
    .s_axis_divisor_tdata(B),
    .s_axis_dividend_tvalid(int_div_en), 
    .s_axis_dividend_tdata(A),
    .m_axis_dout_tvalid(div_valid), 
    .m_axis_dout_tdata(div_res)
);
//Latency Management
reg [2:0] addsub_pipe;
reg [2:0] mul_pipe;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        addsub_pipe <= 3'b0;
        mul_pipe    <= 3'b0;
    end else begin
        addsub_pipe <= {addsub_pipe[1:0], int_addsub_en};
        mul_pipe    <= {mul_pipe[1:0], int_mul_en};
    end
end

//Output Logic
always @(*) begin
    // Defaults to prevent latch inference
    result    = 64'd0;
    carry_out = 1'b0; 
    done      = 1'b0;
    
    if (addsub_pipe[2]) begin 
        result    = addsub_res;
        carry_out = addsub_cout;
        done      = 1'b1;
    end 
    else if (mul_pipe[2]) begin 
        result    = mul_res[63:0];
        done      = 1'b1;
    end 
    else if (div_valid) begin 
        result    = div_res[63:0]; 
        done      = 1'b1;
    end
end
endmodule