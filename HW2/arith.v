module arith (A, B, SUB, SUM, OV);

input [7:0] A,B;		// two 8-bit quantities to be addes/subtracted
input SUB;				// if high operation is A - B, otherwise A + B
output [7:0] SUM;		// result of arithmetic operation
output OV;				// overflow if operands are interpretted as signed.

wire [7:0] b_act;
assign b_act = SUB ? ~B : B;

add8bit mod(.ov(OV), .sum(SUM), .a(A), .b(b_act), .cin(SUB));

endmodule