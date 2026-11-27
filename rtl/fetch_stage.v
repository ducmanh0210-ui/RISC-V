`timescale 1ns / 1ps
`default_nettype none

module fetch_stage #(
    parameter [31:0] RESET_PC = 32'h00000000
) (
    input  wire        clk_i,
    input  wire        rst_ni,
    input  wire        stall_i,
    input  wire        redirect_i,
    input  wire [31:0] target_pc_i,

    input  wire [31:0] imem_rdata_i,

    output wire [31:0] imem_addr_o,
    output wire [31:0] pc_o,
    output wire [31:0] pc_plus4_o,
    output wire [31:0] instr_o
);
    pc_unit #(
        .PC_WIDTH (32),
        .RESET_PC (RESET_PC),
        .PC_STEP  (32'd4)
    ) u_pc_unit (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .stall_i    (stall_i),
        .redirect_i (redirect_i),
        .target_i   (target_pc_i),
        .pc_o       (pc_o),
        .pc_seq_o   (pc_plus4_o)
    );
    assign imem_addr_o = pc_o;
    assign instr_o = imem_rdata_i;
endmodule

`default_nettype wire
