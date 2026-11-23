`timescale 1ns / 1ps
`default_nettype none

module pc_unit #(
    parameter integer PC_WIDTH = 32,
    parameter [PC_WIDTH-1:0] RESET_PC = 0,
    parameter [PC_WIDTH-1:0] PC_STEP  = 4
) (
    input  wire                clk_i,
    input  wire                rst_ni,       
    input  wire                stall_i,      
    input  wire                redirect_i,   
    input  wire [PC_WIDTH-1:0] target_i,     
    output reg  [PC_WIDTH-1:0] pc_o,         
    output wire [PC_WIDTH-1:0] pc_seq_o      
);

    assign pc_seq_o = pc_o + PC_STEP;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            pc_o <= RESET_PC;
        else if (redirect_i)
            pc_o <= target_i;
        else if (!stall_i)
            pc_o <= pc_seq_o;
    end

endmodule

`default_nettype wire
