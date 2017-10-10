module rst_synch (RST_n, clk, rst_n);

input clk;           // clk, NEG edge
input RST_n;         // raw input from push button
output logic rst_n;  // synchronous reset active low

logic q1;

always_ff @(negedge clk) begin
	if(!RST_n) begin
		q1 <= 1'b0;
		rst_n <= 1'b0;
	end else begin
		q1 <= 1'b1;
		rst_n <= q1;
	end
end

endmodule