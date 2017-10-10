module cnt4 (clk, rst_n, en, cnt);

	input clk;
	input rst_n;
	input en;
	output logic [3:0] cnt;

//4 bit cntr flip flop module
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		assign cnt = 4'b0000;
	end
	else if(en) begin
		assign cnt = cnt + 1; 
	end
end

endmodule