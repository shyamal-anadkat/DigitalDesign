module PB_release (clk, rst_n, PB, released);

	input clk; 
	input rst_n; 
	input PB;
	output logic released;
	logic out1, out2, out3; 

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			out1 <= 1'b1;
			out2 <= 1'b1;
			out3 <= 1'b1;
		end else begin
			out1 <= PB;
			out2 <= out1;
			out3 <= out2;
		end
	end
	assign released = (~out3 & out2);
endmodule