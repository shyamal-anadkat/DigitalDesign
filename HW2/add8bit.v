module add8bit (ov, sum, a, b, cin);

input [7:0] a, b;
input cin; 
output [7:0] sum;
output ov;

wire co0, co1, co2, co3, co4, co5, co6;

FA fa1(.cout(co0),  .sum(sum[0]), .a(a[0]), .b(b[0]), .cin(cin));
FA fa2(.cout(co1),  .sum(sum[1]), .a(a[1]), .b(b[1]), .cin(co0));
FA fa3(.cout(co2),  .sum(sum[2]), .a(a[2]), .b(b[2]), .cin(co1));
FA fa4(.cout(co3),  .sum(sum[3]), .a(a[3]), .b(b[3]), .cin(co2));

FA fa5(.cout(co4),  .sum(sum[4]), .a(a[4]), .b(b[4]), .cin(co3));
FA fa6(.cout(co5),  .sum(sum[5]), .a(a[5]), .b(b[5]), .cin(co4));
FA fa7(.cout(co6),  .sum(sum[6]), .a(a[6]), .b(b[6]), .cin(co5));
FA fa8(.cout(ov),   .sum(sum[7]), .a(a[7]), .b(b[7]), .cin(co6));

endmodule
