`timescale 1ns/1ps
`default_nettype none

module tb_fetch_stage;

    localparam [31:0] RESET_PC = 32'h00000100;

    reg         clk_i;
    reg         rst_ni;
    reg         stall_i;
    reg         redirect_i;
    reg  [31:0] target_pc_i;
    reg  [31:0] imem_rdata_i;

    wire [31:0] imem_addr_o;
    wire [31:0] pc_o;
    wire [31:0] pc_plus4_o;
    wire [31:0] instr_o;

    // Cho phep thay du lieu bo nho khi PC dang giu nguyen.
    reg  [31:0] instruction_at_100;

    integer errors;
    integer tests;

    fetch_stage #(
        .RESET_PC (RESET_PC)
    ) dut (
        .clk_i        (clk_i),
        .rst_ni       (rst_ni),
        .stall_i      (stall_i),
        .redirect_i   (redirect_i),
        .target_pc_i  (target_pc_i),
        .imem_rdata_i (imem_rdata_i),
        .imem_addr_o  (imem_addr_o),
        .pc_o         (pc_o),
        .pc_plus4_o   (pc_plus4_o),
        .instr_o      (instr_o)
    );

    initial clk_i = 1'b0;
    always #5 clk_i = ~clk_i;

    // Bo nho lenh gia lap, doc to hop.
    always @(*) begin
        case (imem_addr_o)
            32'h00000100: imem_rdata_i = instruction_at_100;
            32'h00000104: imem_rdata_i = 32'h00200113;
            32'h00000108: imem_rdata_i = 32'h002081B3;
            32'h0000010C: imem_rdata_i = 32'h00302023;
            32'h00000200: imem_rdata_i = 32'h00900293;
            32'h00000204: imem_rdata_i = 32'h00328313;
            32'h00000300: imem_rdata_i = 32'h00100393;
            default:      imem_rdata_i = 32'h00000013;
        endcase
    end

    task check_fetch;
        input [31:0] expected_pc;
        input [31:0] expected_instr;
        reg   [31:0] expected_plus4;
        begin
            tests = tests + 1;
            expected_plus4 = expected_pc + 32'd4;

            if ((pc_o !== expected_pc) ||
                (imem_addr_o !== expected_pc) ||
                (pc_plus4_o !== expected_plus4) ||
                (instr_o !== expected_instr)) begin

                errors = errors + 1;
                $display("FAIL test=%0d t=%0t", tests, $time);
                $display(
                    "  pc=%h addr=%h expected_pc=%h",
                    pc_o, imem_addr_o, expected_pc
                );
                $display(
                    "  pc_plus4=%h expected=%h",
                    pc_plus4_o, expected_plus4
                );
                $display(
                    "  instr=%h expected=%h",
                    instr_o, expected_instr
                );
            end
        end
    endtask

    task step_fetch;
        input        test_stall;
        input        test_redirect;
        input [31:0] test_target;
        input [31:0] expected_pc;
        input [31:0] expected_instr;
        begin
            @(negedge clk_i);
            stall_i     = test_stall;
            redirect_i  = test_redirect;
            target_pc_i = test_target;

            @(posedge clk_i);
            #1;
            check_fetch(expected_pc, expected_instr);
        end
    endtask

    initial begin
        errors             = 0;
        tests              = 0;
        rst_ni             = 1'b1;
        stall_i            = 1'b0;
        redirect_i         = 1'b0;
        target_pc_i        = 32'd0;
        instruction_at_100 = 32'h00100093;

        // 1. Reset bat dong bo va lay lenh tai RESET_PC.
        #1;
        rst_ni = 1'b0;
        #1;
        check_fetch(32'h00000100, 32'h00100093);

        @(negedge clk_i);
        rst_ni = 1'b1;

        // 2. Lay lenh tiep theo.
        @(posedge clk_i);
        #1;
        check_fetch(32'h00000104, 32'h00200113);

        // 3. Tiep tuc lay lenh tuan tu.
        step_fetch(0, 0, 32'd0,
                   32'h00000108, 32'h002081B3);

        // 4-5. Stall: PC va dia chi bo nho giu nguyen.
        step_fetch(1, 0, 32'd0,
                   32'h00000108, 32'h002081B3);
        step_fetch(1, 0, 32'd0,
                   32'h00000108, 32'h002081B3);

        // 6. Nha stall.
        step_fetch(0, 0, 32'd0,
                   32'h0000010C, 32'h00302023);

        // 7. Redirect den 0x200.
        step_fetch(0, 1, 32'h00000200,
                   32'h00000200, 32'h00900293);

        // 8. Lay lenh tiep theo tai 0x204.
        step_fetch(0, 0, 32'd0,
                   32'h00000204, 32'h00328313);

        // 9. Redirect uu tien hon stall.
        step_fetch(1, 1, 32'h00000300,
                   32'h00000300, 32'h00100393);

        // 10. Tat redirect, giu stall.
        step_fetch(1, 0, 32'd0,
                   32'h00000300, 32'h00100393);

        // 11. Reset uu tien hon redirect va stall.
        @(negedge clk_i);
        stall_i     = 1'b1;
        redirect_i  = 1'b1;
        target_pc_i = 32'h00000200;

        #2;
        rst_ni = 1'b0;
        #1;
        check_fetch(32'h00000100, 32'h00100093);

        // 12. Giu reset qua canh len.
        @(posedge clk_i);
        #1;
        check_fetch(32'h00000100, 32'h00100093);

        @(negedge clk_i);
        rst_ni     = 1'b1;
        redirect_i = 1'b0;
        stall_i    = 1'b1;

        // 13. Sau reset, stall giu PC tai 0x100.
        @(posedge clk_i);
        #1;
        check_fetch(32'h00000100, 32'h00100093);

        // 14. PC khong doi, du lieu bo nho doi:
        // instr_o phai theo du lieu moi, khong cho canh clock.
        @(negedge clk_i);
        instruction_at_100 = 32'h00700093;
        #1;
        check_fetch(32'h00000100, 32'h00700093);

        // 15. Nha stall, tiep tuc lay lenh.
        step_fetch(0, 0, 32'd0,
                   32'h00000104, 32'h00200113);

        if (errors == 0)
            $display("PASS: All %0d Fetch Stage checks passed.", tests);
        else
            $display("FAIL: %0d/%0d Fetch Stage checks failed.",
                     errors, tests);

        $stop;
        $finish;
    end

endmodule

`default_nettype wire
