`timescale 1ns/1ps

module tb_register_file;

    reg         clk;
    reg         rst;
    reg         we;
    reg  [4:0]  rs1_addr;
    reg  [4:0]  rs2_addr;
    reg  [4:0]  rd_addr;
    reg  [31:0] rd_data;

    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    integer errors;

    register_file dut (
        .clk      (clk),
        .rst      (rst),
        .we       (we),
        .rs1_addr (rs1_addr),
        .rs2_addr (rs2_addr),
        .rd_addr  (rd_addr),
        .rd_data  (rd_data),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data)
    );

    // Chu ky clock: 10 ns.
    initial clk = 1'b0;
    always #5 clk = ~clk;

    task check_read;
        input [31:0] expected1;
        input [31:0] expected2;
        begin
            if ((rs1_data !== expected1) || (rs2_data !== expected2)) begin
                errors = errors + 1;
                $display("FAIL t=%0t: read1=%h, read2=%h", $time, rs1_data, rs2_data);
            end
        end
    endtask

    initial begin
        errors   = 0;
        rst      = 1;
        we       = 0;
        rs1_addr = 1;
        rs2_addr = 2;
        rd_addr  = 0;
        rd_data  = 0;

        // Reset duoc thuc hien tai canh len t=5 ns.
        @(posedge clk);
        #1;
        check_read(32'd0, 32'd0);

        // Ghi x1 = 10 tai canh len t=15 ns.
        @(negedge clk);
        rst     = 0;
        we      = 1;
        rd_addr = 1;
        rd_data = 10;

        @(posedge clk);
        #1;
        check_read(32'd10, 32'd0);

        // Ghi x2 = 20 tai canh len t=25 ns.
        @(negedge clk);
        rd_addr = 2;
        rd_data = 20;

        @(posedge clk);
        #1;
        check_read(32'd10, 32'd20);

        // we=0: khong duoc ghi de x1 bang 99.
        @(negedge clk);
        we      = 0;
        rd_addr = 1;
        rd_data = 99;

        @(posedge clk);
        #1;
        check_read(32'd10, 32'd20);

        // Thu ghi x0 = 123: phai bi bo qua.
        @(negedge clk);
        we       = 1;
        rd_addr  = 0;
        rd_data  = 123;
        rs1_addr = 0;

        @(posedge clk);
        #1;
        check_read(32'd0, 32'd20);

        // Doi dia chi doc giua hai canh len clock.
        @(negedge clk);
        we       = 0;
        rs1_addr = 2;
        rs2_addr = 1;

        #1;
        check_read(32'd20, 32'd10);

        // Reset lai sau khi da ghi du lieu.
        @(negedge clk);
        rst = 1;

        @(posedge clk);
        #1;
        check_read(32'd0, 32'd0);

        if (errors == 0)
            $display("PASS: All register file tests passed.");
        else
            $display("FAIL: %0d checks failed.", errors);

        #4;
        $stop;
    end

endmodule
