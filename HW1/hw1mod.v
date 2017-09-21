//** Shyamal H Anadkat **//
//** Negative Edge FF** //
module hw1mod(q, clk, d);

input d;
input clk;
output q;

wire mq, md, sd, w1;

/*Behavior : on 0 enable (neg clock edge) the first tri state will be disabled and 
  second tri state will be enabled and will output value of d that was stored before */

// tri-state 1 on the left with some delay for proper simulation
// d is input to first tri-state and mq is input to second tristate 
notif1 	#1 (md, d, clk);

not	    (mq, md);
not 	(weak0,weak1) (md, mq); 

not 	(w1, clk);

// tri-state 2 on the right with some delay for proper simulation
notif1 #1 (sd, mq, w1);

not	    (q, sd);
not 	(weak0, weak1) (sd, q);

endmodule