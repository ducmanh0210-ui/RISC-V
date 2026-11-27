`timescale 1ns/1ps
`default_nettype none

module tb_pc_unit;

    localparam [31:0] RESET_PC = 32'h00000100;

    reg         clk_i;
    reg         rst_ni;
    reg         stall_i;
    reg         redirect_i;
    reg  [31:0] target_i;

    wire [31:0] pc_o;
    wire [31:0] pc_seq_o;

    integer errors;
    integer tests;

    pc_unit #(
        .PC_WIDTH (32),
        .RESET_PC (RESET_PC),
        .PC_STEP  (32'd4)
    ) dut (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .stall_i    (stall_i),
        .redirect_i (redirect_i),
        .target_i   (target_i),
        .pc_o       (pc_o),
        .pc_seq_o   (pc_seq_o)
    );

    initial clk_i = 1'b0;
    always #5 clk_i = ~clk_i;

    task check_pc;
        input [31:0] expected_pc;
        reg   [31:0] expected_seq;
        begin
            tests = tests + 1;
            expected_seq = expected_pc + 32'd4;

            if ((pc_o !== expected_pc) ||
                (pc_seq_o !== expected_seq)) begin
                errors = errors + 1;
                $display(
                    "FAIL test=%0d t=%0t pc=%h expected=%h seq=%h expected_seq=%h",
                    tests, $time, pc_o, expected_pc,
                    pc_seq_o, expected_seq
                );
            end
        end
    endtask

    // Dat dieu khien tai canh xuong, kiem tra sau canh len.
    task step_pc;
        input        test_stall;
        input        test_redirect;
        input [31:0] test_target;
        input [31:0] expected_pc;
        begin
            @(negedge clk_i);
            stall_i    = test_stall;
            redirect_i = test_redirect;
            target_i   = test_target;

            @(posedge clk_i);
            #1;
            check_pc(expected_pc);
        end
    endtask

    initial begin
        errors     = 0;
        tests      = 0;
        rst_ni     = 1'b1;
        stall_i    = 1'b0;
        redirect_i = 1'b0;
        target_i   = 32'd0;

        // 1. Reset bat dong bo: kiem tra truoc canh len dau tien.
        #1;
        rst_ni = 1'b0;
        #1;
        check_pc(RESET_PC);

        // 2. Giu reset qua canh len.
        @(posedge clk_i);
        #1;
        check_pc(RESET_PC);

        @(negedge clk_i);
        rst_ni = 1'b1;

        // 3. Tang PC sau khi nha reset.
        @(posedge clk_i);
        #1;
        check_pc(32'h00000104);

        // 4. Tang PC binh thuong.
        step_pc(0, 0, 32'd0, 32'h00000108);

        // 5-6. Stall trong hai chu ky.
        step_pc(1, 0, 32'd0, 32'h00000108);
        step_pc(1, 0, 32'd0, 32'h00000108);

        // 7. Bo stall, tiep tuc tang PC.
        step_pc(0, 0, 32'd0, 32'h0000010C);

        // 8. Redirect.
        step_pc(0, 1, 32'h00000200, 32'h00000200);

        // 9. Sau redirect, tang tu dia chi dich.
        step_pc(0, 0, 32'd0, 32'h00000204);

        // 10. Redirect uu tien hon stall.
        step_pc(1, 1, 32'h00000300, 32'h00000300);

        // 11. Tat redirect nhung van stall: giu PC.
        step_pc(1, 0, 32'd0, 32'h00000300);

        // 12. Reset giua chu ky, khi stall va redirect cung bat.
        @(negedge clk_i);
        stall_i    = 1'b1;
        redirect_i = 1'b1;
        target_i   = 32'h00000400;

        #2;
        rst_ni = 1'b0;
        #1;
        check_pc(RESET_PC);

        // 13. Reset van uu tien tai canh len.
        @(posedge clk_i);
        #1;
        check_pc(RESET_PC);

        @(negedge clk_i);
        rst_ni     = 1'b1;
        stall_i    = 1'b0;
        redirect_i = 1'b0;

        // 14. Hoat dong lai sau reset.
        @(posedge clk_i);
        #1;
        check_pc(32'h00000104);

        // 15. PC+4 tran 32 bit.
        step_pc(0, 1, 32'hFFFFFFFC, 32'hFFFFFFFC);

        // 16. PC quay ve 0.
        step_pc(0, 0, 32'd0, 32'h00000000);

        if (errors == 0)
            $display("PASS: All %0d PC Unit checks passed.", tests);
        else
            $display("FAIL: %0d/%0d PC Unit checks failed.",
                     errors, tests);

        $stop;
        $finish;
    end

endmodule

`default_nettype wire
