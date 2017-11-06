module SPI_mstr16_tb();

// common inputs
logic clk, rst_n;

// outputs from SPI_mstr16
logic SS_n;  // input to ADC128S
logic SCLK;  // input to ADC128S
logic MOSI;  // input to ADC128S
logic done;
logic [15:0] rd_data;

// inputs to SPI_mstr16
logic wrt; 
logic MISO;            // output from ADC128S
logic [15:0] cmd;      
logic [15:0] i;             // iteration counter

ADC128S     iDUT_slv(.clk(clk),.rst_n(rst_n),.SS_n(SS_n),.SCLK(SCLK),.MISO(MISO),.MOSI(MOSI));
SPI_mstr16  iDUT_mstr(.clk(clk), .rst_n(rst_n), .cmd(cmd), .wrt(wrt), .MISO(MISO), .MOSI(MOSI), .SS_n(SS_n), .SCLK(SCLK), .done(done), .rd_data(rd_data));

initial begin 

  clk = 0;
  rst_n = 0;
  #1;
  rst_n = 1;
  i = 0;

  for(cmd = 16'hC00; cmd >= 16'h10; ) begin

    @(posedge clk) wrt = 1; 
    @(posedge clk) wrt = 0;
    #3000; // wait

    if(done) begin
      if(rd_data != cmd) begin
        $display("ERROR i: %d, rd_data: %d, cmd: %d", i, rd_data, cmd);
        $stop; 
      end
      else begin 
        //$display("SUCCESS");
      end
    end
    else begin
      $display("not done");
      $stop; 
    end
    i = i + 1;
    if(i % 2 == 0)
      cmd = cmd - 16'h10;
  end
  $stop; 
end 

always
  #1 clk = ~clk;

endmodule