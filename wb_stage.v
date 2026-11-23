`timescale 1ns/1ps

module wb_stage (
    input  wire [31:0] alu_result_i,
    input  wire [31:0] mem_data_i,
    input  wire [31:0] pc_plus4_i,
    input  wire [1:0]  wb_sel_i,

    output reg  [31:0] wb_data_o
);
    always @(*) begin
        case (wb_sel_i)
            2'b00:   wb_data_o = alu_result_i;
            2'b01:   wb_data_o = mem_data_i;
            2'b10:   wb_data_o = pc_plus4_i;
            default: wb_data_o = 32'd0;   // 2'b11: du phong
        endcase
    end
endmodule
