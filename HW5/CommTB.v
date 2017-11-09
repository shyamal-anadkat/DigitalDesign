module CommTB ();

logic clk, rst_n;
logic RX, TX;
logic resp_rdy, frm_snt;
logic [7:0] resp;
logic [7:0] cmd;
logic snd_cmd;
logic [15:0] data;



CommMaster iDUT_CommMaster
(   .resp(resp),
	.resp_rdy(resp_rdy), 
	.frm_snt(frm_snt), 
	.TX(TX), 
	.RX(RX), 
	.cmd(cmd), 
	.snd_cmd(snd_cmd), 
	.data(data), 
	.clk(clk), .rst_n(rst_n));


	initial begin 



	end

//// clk toggle ////
always
#5 clk <= ~clk;

endmodule