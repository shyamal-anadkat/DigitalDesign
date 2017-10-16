module UART_rcv (clk, rst_n, RX, clr_rdy, rdy, cmd);

//////////////////////////////////////////////////////////////////////
input logic clk, rst_n; //100MHz system clock & active low reset
input logic RX;         //Serial data carrying command from host computer

//Asserted to knock down the rdy signal. 
input logic clr_rdy;

//Asserted when a byte has been received. Falls
//when new start bit comes, or when clr_rdy knocks
//it down.
output logic rdy;
output logic [7:0] cmd;  //Byte received (serves as command to LA)

//state machine
typedef enum reg {IDLE, RCV} rcv_state;
rcv_state state, nxt_state;
//////////////////////////////////////////////////////////////////////

logic RX_ff1, RX_ff2;
logic set_rdy, load, shift, is_rcv, clr_baud;
logic strt;
logic [3:0] bit_cnt;
logic [9:0] rx_shft_reg;
logic [11:0] baud_cnt;

//double flop RX  - metastability
always_ff @(posedge clk, negedge rst_n) begin 
	if(~rst_n) begin
		RX_ff1 <= 1'b0;
		RX_ff2 <= 1'b0;
	end else begin
		RX_ff1 <= RX;
		RX_ff2 <= RX_ff1;
	end
end


// rdy signal flop
always_ff @(posedge clk, negedge rst_n) begin
	if(~rst_n) begin
		rdy <= 0;
	end else if(clr_rdy || load) begin
		rdy <= 0;
	end else if(set_rdy) begin
		rdy <= 1;
	end
end


//bit_cnt logic (same as tx)
always_ff @(posedge clk) begin 
	if(load) begin
		bit_cnt <= 4'h0;
	end else if(shift) begin
		bit_cnt <= bit_cnt + 1;
	end
end

//baud rate counter - 2604 (12 bit).
always_ff @(posedge clk) begin 
	if(load) begin
		baud_cnt <= 12'h000;
	end else if(clr_baud) begin
		baud_cnt <= 12'h000;
	end else if(is_rcv) begin
		baud_cnt <= baud_cnt + 1; 
	end
end

assign shift = (baud_cnt == 1302);    //sample at middle
assign clr_baud = (baud_cnt == 2604); //clr when another bit


// Shifter logic which is driven by load, shift.
always_ff @(posedge clk, negedge rst_n) begin 
	if(~rst_n) begin
		rx_shft_reg <= 10'h000; 
	end else if(load) begin
		rx_shft_reg <= 10'h000;
	end else if(shift) begin
		rx_shft_reg <= {RX_ff2, rx_shft_reg[9:1]};
	end
end
assign cmd = rx_shft_reg[8:1];

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
	load = 1'b0;
	is_rcv = 1'b0;
	set_rdy = 1'b0;
	nxt_state = IDLE;

	case(state)
		IDLE: begin
			if(!RX_ff2) begin
				nxt_state = RCV;
				load = 1'b1;
			end else begin
				nxt_state = IDLE;
			end
		end
		RCV: begin
			if(bit_cnt == 4'b1010) begin
				nxt_state = IDLE;
				set_rdy = 1'b1;
			end else begin
				is_rcv = 1'b1;
				nxt_state = RCV;
			end
		end
		default:
		nxt_state = IDLE;
		
	endcase // state
end

endmodule