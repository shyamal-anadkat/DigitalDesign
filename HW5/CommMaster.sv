module CommMaster 
	(TX, resp, resp_rdy, cmd, snd_cmd, data, clk, rst_n);

//outputs
output logic TX;
output logic [7:0] resp;
output logic resp_rdy;

//inputs 
input clk, rst_n;
input [7:0] cmd;
input snd_cmd;
input [15:0] data;

//internal signals
logic [1:0] sel;
logic snd_frm;
logic trmt;
logic tx_done;
logic frm_snt;
logic set_cmplt, clr_cmplt;

//input to UART
logic [7:0] tx_data;

//// Define state as enumerated type /////
typedef enum reg {IDLE, WAITH, WAITM, WAITL} state_t;
state_t state, nxt_state;


//assign tx_data = (sel = 2'b10) ? 

UART uart_mod (.clk(clk),
	.rst_n(rst_n),
	.RX(),.TX(),
	.rx_rdy(),
	.clr_rx_rdy(),
	.rx_data(),
	.trmt(),
	.tx_data(),
	.tx_done(tx_done));


always_comb begin 
	sel = 2'b10;
	trmt = 0;
	set_cmplt = 0;
	clr_cmplt = 0;

	case (state)
		IDLE: begin 
			if(snd_frm) begin
				trmt = 1;
				clr_cmplt = 1;
				nxt_state = WAITH;
			end else begin
				nxt_state = IDLE;
			end
		end

		WAITH: begin
			if(tx_done) begin 
				sel = 2'b01;
				trmt = 1;
				nxt_state = WAITM;
			end else begin 
				nxt_state = WAITH;
			end
		end

		WAITM: begin
			if(tx_done) begin
				sel = 2'b00;
				trmt = 1;
				nxt_state = WAITL;
			end else begin
				nxt_state = WAITM;
			end

		end

	default : begin //WAITL STATE
		if(tx_done) begin
			set_cmplt = 1;
			nxt_state = IDLE;
		end else begin
			nxt_state = WAITL;
		end
	end
endcase

end



////////////////////////////
// Infer state flop next //
//////////////////////////
always_ff @(posedge clk or negedge rst_n)
if (!rst_n)
	state <= IDLE;
else
state <= nxt_state;

endmodule