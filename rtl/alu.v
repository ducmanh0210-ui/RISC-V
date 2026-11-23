`timescale 1ns/1ps

module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  op,

    output reg  [31:0] res
);

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

    always @(*) begin
        case (op)
            ALU_ADD:  res = a + b;
            ALU_SUB:  res = a - b;

            ALU_AND:  res = a & b;
            ALU_OR:   res = a | b;
            ALU_XOR:  res = a ^ b;

            ALU_SLL:  res = a << b[4:0];
            ALU_SRL:  res = a >> b[4:0];
            ALU_SRA:  res = $signed(a) >>> b[4:0];

            ALU_SLT:  res = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;

            ALU_SLTU: res = (a < b) ? 32'd1 : 32'd0;

            default:  res = 32'd0;
        endcase
    end

endmodule
