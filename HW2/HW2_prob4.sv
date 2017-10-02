module HW2_prob4 ();



// the code is correct as at positive clock edge
// the output(q) will update to input(d). 



//the model of a D-FF with an active high synchronous reset. 
always @ (posedge)

if(rst) begin
	q <= 1'b0;
end else begin
	q <= d;
end

end

endmodule




always_ff @(posedge clk or negedge rst_n) 
	if(~rst_n) begin
		q <= 1'b0;
	else 
		q <= d;
end



logic q; 
always @(posedge clk, negedge rst_n)
	if(!rst_n)
		q <= 1'b0; //asynch reset
	else if(en)
		q <= d;    //conditionally enabled 
	else
		q <= q;    //keep old value


logic q; 
always @(posedge clk, negedge rst_n)
	if(!rst_n)
		q <= 1'b0; //asynch reset
	else if(en)
		q <= d;    //conditionally enabled 
	else
		q <= q;    //keep old value