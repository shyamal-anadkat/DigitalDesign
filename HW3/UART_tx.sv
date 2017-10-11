module UART_tx (clk, rst_n, trmt, tx_data, TX, tx_done);

//////////////////////////////////////////////////////////////////////
input logic clk, rst_n, trmt; //100MHz system clock & active low reset
input logic [7:0] tx_data;    //Byte to transmit (response from LA)
output logic tx_done;         //Assert w/ byte dn trnsmt.Stay high till nxt byte trnsmt.
output logic TX;      		  //Serial data output back to host

logic load, shift, transmitting; //state machine signals
logic [3:0] bit_cnt; 
logic [11:0] baud_cnt;
logic [9:0] tx_shft_reg;
logic set_done, clr_done;

typedef enum reg[1:0] {IDLE, TRANS, DONE} state_t;
state_t state, nxt_state;
//////////////////////////////////////////////////////////////////////

// shift module on the right
always_ff @(posedge clk, negedge rst_n) begin 
	if(~rst_n) begin
		tx_shft_reg <= 10'b0; 
	end else if(load) begin
		tx_shft_reg <= {1'b1, tx_data, 1'b0};
	end else if(shift) begin
		tx_shft_reg <= {1'b1, tx_shft_reg[9:1]}; //right shift
	end
end

assign TX = tx_shft_reg[0];

// baud_cnt blob in the middle 
always_ff @(posedge clk) begin 
	if(load) begin
		baud_cnt <= 12'h000;
	end else if(transmitting) begin
		baud_cnt <= baud_cnt + 1; 
	end
end

assign shift = (baud_cnt == 2604);

// bit_cnt FF on the left
always_ff @(posedge clk) begin 
	if(load) begin
		bit_cnt <= 4'b0000;
	end else if(shift) begin
		bit_cnt <= bit_cnt + 1;
	end
end

//tx_done SR flip flop 
always @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		tx_done <= 1'b0;
	else if (clr_done)
		tx_done <= 1'b0;
	else if (set_done)
		tx_done <= 1'b1;
	else
	tx_done <= tx_done;
end


//////////////////////////////////////////////////////////////////////
//STATE MACHINE LOGIC 
//////////////////////////////////////////////////////////////////////
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		state <= IDLE;
	end else begin
		state <= nxt_state;
	end
end

always_comb begin
	set_done = 1'b0;
	clr_done = 1'b0;
	load = 1'b0;
	transmitting = 1'b0; 
	shift = 1'b0;

	case(state)
		IDLE:
		if(trmt) begin
			nxt_state = TRANS;
			clr_done = 1'b1;
			load = 1'b1;
			transmitting = 1'b1;
		end
		else begin 
			nxt_state = IDLE;
		end

		TRANS:
		if(shift) begin
			transmitting = 1'b1;
			nxt_state = DONE;
		end
		else begin
			nxt_state = TRANS;
			transmitting = 1'b1;
		end
		DONE:
		if(bit_cnt == 4'b1010) begin
			set_done = 1'b1;
			nxt_state = IDLE;
		end
		else begin
			transmitting = 1'b1;
			nxt_state = TRANS;
		end

		default:
		nxt_state = IDLE;

	endcase // state
end
endmodule