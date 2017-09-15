// Author: Shyamal Anadkat
module synch_detect(asynch_sig_in, clk, fall_edge);

input asynch_sig_in;
input clk;
output fall_edge;

wire sig_ff1, sig_ff2, sig_ff3;

// initially two flops for metastability freeing
dff dff1(.D(asynth_sig_in),.clk(clk),.Q(sig_ff1));
dff dff2(.D(sig_ff1),.clk(clk),.Q(sig_ff2));

// edge detection use
dff dff3(.D(sig_ff2),.clk(clk),.Q(sig_ff3));

// output high after falling edge
and(fall_edge, sig_ff3, ~sig_ff2);

endmodule