/*Shyamal Anadkat --- HW2 PROBLEM 4 */
module HW2_prob4 ();

	/* a) the code is incorrect as it models a flip flop not a latch. 
	d and enable should be in sensitivity list. The reason is that outputs should change 
	whenever d(input) changes for a latch. Latches are asynch and don't need clk signal. */


	/* b) the model of a D-FF with an active high synchronous reset. */
	module b(d, rst, clk, q);
		output logic q;
		input d, clk, rst;
		always_ff @ (posedge clk) begin
			if(rst) begin
				q <= 1'b0;
			end else begin
				q <= d;
			end
		end
	endmodule


	/*c) DFF with asynch low rst and active high enable */
	module c(d, rst_n, en, clk, q);
		output logic q;
		input d, rst_n, clk, en;
		always_ff @(posedge clk, negedge rst_n) begin
			if(!rst_n) begin
			q <= 1'b0; //asynch reset
		end else if(en) begin
			q <= d;    //conditionally enabled 
		end else begin
			q <= q;    //keep old value
		end
	end
endmodule

/* d) SR FF with active low asynch reset. */
module d (rst_n, clk, S, R, q);
	output logic q; 
	input clk, rst_n, S, R;
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin		//asynch low reset
			q <= 1'b0; 
		end else if(R) begin    //synch R which resets(preference)
			q <= 1'b0; 
		end else if(S) begin    //synch S which sets
			q <= 1'b1; 
		end
	end
endmodule



/* e) nope, it will just warn us. Its not a certainty.
SystemVerilog LRM states that SystemVerilog parsers, or any other EDA software, 
should only warn if an always_ff procedure does not infer sequential logic.*/

endmodule