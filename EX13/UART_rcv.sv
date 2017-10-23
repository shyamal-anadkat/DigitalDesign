/* Shyamal Anadkat - UART Receiver - ECE 551 */

module UART_rcv (clk, rst_n, RX, clr_rdy, rdy, rx_data);

//////////////////////////////////////////////////////////////////////
input logic clk, rst_n; //100MHz system clock & active low reset
input logic RX;         //Serial data carrying command from host computer

//Asserted to knock down the rdy signal. 
input logic clr_rdy;

//Asserted when a byte has been received. Falls
//when new start bit comes, or when clr_rdy knocks
//it down.
output logic rdy;
output logic [7:0] rx_data;  //Byte received (serves as command to LA)

//state machine
typedef enum reg {IDLE, RCV} rcv_state;
rcv_state state, nxt_state;
//////////////////////////////////////////////////////////////////////

/*INTERNAL SIGNALS*/
logic RX_ff1, RX_ff2;
logic set_rdy, start, shift, is_rcv, clr_baud;
logic [3:0] bit_cnt;
logic [9:0] rx_shft_reg;
logic [11:0] baud_cnt;
logic clr_rdy_fsm;

//////////////////////////////////////////////////////////////////////

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


// rdy and clr_rdy signal flop
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		rdy <= 0;
	end else if(clr_rdy == 1'b1) begin
		rdy <= 0;
	end else if(clr_rdy_fsm) begin
		rdy <= 0;
	end else if(set_rdy) begin
		rdy <= 1;
	end
end


//bit_cnt logic (same as tx)
always_ff @(posedge clk) begin 
	if(start) begin
		bit_cnt <= 4'h0;
	end else if(shift) begin
		bit_cnt <= bit_cnt + 1;
	end
end

//baud rate counter driven by start, is_rcv, and clr_baud signals
always_ff @(posedge clk) begin 
	if(start) begin
		baud_cnt <= 12'h000;
	end else if(clr_baud) begin
		baud_cnt <= 12'h000;
	end else if(is_rcv) begin
		baud_cnt <= baud_cnt + 1; 
	end
end

assign shift = (baud_cnt == 12'd1302);    //sample at middle
assign clr_baud = (baud_cnt == 12'd2604); //clr when another bit


//shifter logic which is driven by the shift signal
always_ff @(posedge clk, negedge rst_n) begin 
	if(!rst_n) begin
		rx_shft_reg <= 10'h3FF; 
	end else if(start) begin
		rx_shft_reg <= 10'h3FF; 
	end else if(shift) begin
		rx_shft_reg <= {RX_ff2, rx_shft_reg[9:1]};
	end
end
assign rx_data = rx_shft_reg[8:1];

//////////////////////////////////////////////////////////////////////
//STATE MACHINE LOGIC 
//////////////////////////////////////////////////////////////////////

//next state flop logic
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		state <= IDLE;
	end else begin
		state <= nxt_state;
	end
end

always_comb begin 

	// reset-signals 
	start = 1'b0;
	is_rcv = 1'b0;
	set_rdy = 1'b0;
	nxt_state = IDLE;

	case(state)
		IDLE: begin
			//go to RCV on start bit
			if(!RX_ff2) begin
				nxt_state = RCV;
				start = 1'b1;
			end else begin
				nxt_state = IDLE;
			end
		end
		RCV: begin
			// stay in RCV till 10 bits poured through
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