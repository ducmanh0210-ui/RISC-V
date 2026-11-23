`timescale 1ns/1ps

module tb_alu;

    reg  [31:0] a;
    reg  [31:0] b;
    reg  [3:0]  op;

    wire [31:0] res;

    integer errors;
    integer test_id;

    localparam [3:0]
        ALU_ADD  = 4'b0000,
        ALU_SUB  = 4'b0001,
        ALU_AND  = 4'b0010,
        ALU_OR   = 4'b0011,
        ALU_XOR  = 4'b0100,
        ALU_SLL  = 4'b0101,
        ALU_SRL  = 4'b0110,
        ALU_SRA  = 4'b0111,
        ALU_SLT  = 4'b1000,
        ALU_SLTU = 4'b1001;

    alu dut (
        .a   (a),
        .b   (b),
        .op  (op),
        .res (res)
    );

    task check_alu;
        input [3:0]  test_op;
        input [31:0] test_a;
        input [31:0] test_b;
        input [31:0] expected;

        begin
            test_id = test_id + 1;

            op = test_op;
            a  = test_a;
            b  = test_b;

            #1;

            if (res !== expected) begin
                errors = errors + 1;
                $display(
                    "FAIL test=%0d op=%h a=%h b=%h res=%h expected=%h",
                    test_id, op, a, b, res, expected
                );
            end

            #9;
        end
    endtask

    initial begin
        a       = 0;
        b       = 0;
        op      = 0;
        errors  = 0;
        test_id = 0;

        // 1. ADD: 10 + 20 = 30
        check_alu(ALU_ADD, 32'd10, 32'd20, 32'd30);

        // 2. SUB: 20 - 10 = 10
        check_alu(ALU_SUB, 32'd20, 32'd10, 32'd10);

        // 3. SUB: 10 - 20 = -10 (bu hai)
        check_alu(ALU_SUB, 32'd10, 32'd20, 32'hFFFFFFF6);

        // 4. AND
        check_alu(ALU_AND, 32'h0000000C, 32'h0000000A,
                          32'h00000008);

        // 5. OR
        check_alu(ALU_OR, 32'h0000000C, 32'h0000000A,
                         32'h0000000E);

        // 6. XOR
        check_alu(ALU_XOR, 32'h0000000C, 32'h0000000A,
                          32'h00000006);

        // 7. SLL: 1 << 4 = 16
        check_alu(ALU_SLL, 32'd1, 32'd4, 32'd16);

        // 8. SRL: chen 0 vao ben trai
        check_alu(ALU_SRL, 32'h80000000, 32'd4,
                          32'h08000000);

        // 9. SRA: lap lai bit dau
        check_alu(ALU_SRA, 32'h80000000, 32'd4,
                          32'hF8000000);

        // 10. SLT: -1 < 1 -> dung
        check_alu(ALU_SLT, 32'hFFFFFFFF, 32'd1, 32'd1);

        // 11. SLTU: 4294967295 < 1 -> sai
        check_alu(ALU_SLTU, 32'hFFFFFFFF, 32'd1, 32'd0);

        // 12. ADD: chi giu 32 bit thap
        check_alu(ALU_ADD, 32'hFFFFFFFF, 32'd1, 32'd0);

        // 13. Chi dung b[4:0]: 36 -> dich 4 bit
        check_alu(ALU_SLL, 32'd1, 32'd36, 32'd16);

        // 14. Hai gia tri bang nhau: khong nho hon
        check_alu(ALU_SLT, 32'd5, 32'd5, 32'd0);

        // 15. SLTU: 1 < 2 -> dung
        check_alu(ALU_SLTU, 32'd1, 32'd2, 32'd1);

        // 16. SLT: 1 < -1 -> sai
        check_alu(ALU_SLT, 32'd1, 32'hFFFFFFFF, 32'd0);

        if (errors == 0)
            $display("PASS: All %0d ALU tests passed.", test_id);
        else
            $display("FAIL: %0d ALU tests failed.", errors);

        $stop;
    end

endmodule
