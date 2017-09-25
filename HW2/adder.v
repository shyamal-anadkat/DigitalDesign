/*Problem 3 : dataflow RTL impl. 4-bit adder */
module adder (Sum, co, A, B, cin);

localparam sz = 4;

output [sz-1:0] Sum;
output co;

input [sz-1:0] A, B;
input cin;

assign {co,Sum} = A + B + cin;

endmodule