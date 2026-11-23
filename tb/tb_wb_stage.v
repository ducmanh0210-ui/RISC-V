`timescale 1ns/1ps

module tb_wb_stage;

    reg  [31:0] alu_result_i;
    reg  [31:0] mem_data_i;
    reg  [31:0] pc_plus4_i;
    reg  [1:0]  wb_sel_i;
    wire [31:0] wb_data_o;
    integer errors;

    wb_stage dut (
        .alu_result_i (alu_result_i),
        .mem_data_i   (mem_data_i),
        .pc_plus4_i   (pc_plus4_i),
        .wb_sel_i     (wb_sel_i),
        .wb_data_o    (wb_data_o)
    );

    task check_wb;
        input [1:0]  sel;
        input [31:0] expected;
        begin
            wb_sel_i = sel;
            #1;
            if (wb_data_o !== expected) begin
                errors = errors + 1;
                $display("FAIL sel=%b out=%h expected=%h", sel, wb_data_o, expected);
            end
            #9;
        end
    endtask

    initial begin
        errors       = 0;
        alu_result_i = 32'hAAAA0001;
        mem_data_i   = 32'hBBBB0002;
        pc_plus4_i   = 32'h00000004;
        wb_sel_i     = 2'b00;

        // 00: ALU; 01: bo nho; 10: PC+4; 11: du phong -> 0
        check_wb(2'b00, 32'hAAAA0001);
        check_wb(2'b01, 32'hBBBB0002);
        check_wb(2'b10, 32'h00000004);
        check_wb(2'b11, 32'h00000000);

        // Doi du lieu vao khi giu nguyen sel: dau ra phai theo ngay (to hop).
        alu_result_i = 32'h12345678;
        check_wb(2'b00, 32'h12345678);

        if (errors == 0)
            $display("PASS: All wb_stage tests passed.");
        else
            $display("FAIL: %0d checks failed.", errors);
        $stop;
    end
endmodule
