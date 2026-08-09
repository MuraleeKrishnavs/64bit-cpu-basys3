`timescale 1ns / 1ps
module floating_point_unit_64bit (
    input         clk,
    input  [63:0] A, // IEEE 754 Double Precision Format
    input  [63:0] B, // IEEE 754 Double Precision Format
    
    input         fp_addsub_en,
    input         fp_addsub_mode, // Mode can be passed to the IP via tuser or operation stream
    input         fp_mul_en,
    input         fp_div_en,
    
    output reg [63:0] result,
    output reg        done
);
wire [63:0] fp_addsub_res, fp_mul_res, fp_div_res;
wire        fp_addsub_valid, fp_mul_valid, fp_div_valid;

// Vivado Floating-Point IP (Configured for Add/Sub)
floating_point_0 U_FP_ADDSUB (
    .aclk(clk),
    .s_axis_a_tvalid(fp_addsub_en), .s_axis_a_tdata(A),
    .s_axis_b_tvalid(fp_addsub_en), .s_axis_b_tdata(B),
    .m_axis_result_tvalid(fp_addsub_valid), .m_axis_result_tdata(fp_addsub_res)
);
// Vivado Floating-Point IP (Configured for Multiply)
floating_point_1 U_FP_MUL (
    .aclk(clk),
    .s_axis_a_tvalid(fp_mul_en), .s_axis_a_tdata(A),
    .s_axis_b_tvalid(fp_mul_en), .s_axis_b_tdata(B),
    .m_axis_result_tvalid(fp_mul_valid), .m_axis_result_tdata(fp_mul_res)
);
// Vivado Floating-Point IP (Configured for Divide)
floating_point_2 U_FP_DIV (
    .aclk(clk),
    .s_axis_a_tvalid(fp_div_en), .s_axis_a_tdata(A),
    .s_axis_b_tvalid(fp_div_en), .s_axis_b_tdata(B),
    .m_axis_result_tvalid(fp_div_valid), .m_axis_result_tdata(fp_div_res)
);
always @(*) begin
    result = 64'd0;
    done = 1'b0;
    
    if (fp_addsub_valid && fp_addsub_en) begin
        result = fp_addsub_res;
        done = 1'b1;
    end else if (fp_mul_valid && fp_mul_en) begin
        result = fp_mul_res;
        done = 1'b1;
    end else if (fp_div_valid && fp_div_en) begin
        result = fp_div_res;
        done = 1'b1;
    end
end
endmodule
