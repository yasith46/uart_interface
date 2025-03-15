module UARTinterface(
		// Microcontroller bound:
		input CLK, RST, WRITE_TO_TX_BUFFER, READ_BUFFER, SET_BR, SET_MODE,
		input [31:0] DATA_IN__CONFIG,
		
		output [7:0] DATA_OUT,
		output INTERRUPT, BUSY, PARITY,
		
		// To outside:
		input RX,
		output TX
	);
	
	//   Baudrate generator
	wire baudclk, baudclkx32;
	
	baudPLL pll(
		.CLK(CLK), 
		.RST(RST), 
		.SET(SET_BR),
		.BAUDRATE(DATA_IN__CONFIG),
		.BAUD_TICK(baudclk),
		.BAUD_TICK_X32(baudclkx32)
	); 
	
	
	//   Tx
	wire read_byte_from_tx_buffer, data_avail_to_read;
	wire [7:0] current_byte;
	
	fifo_buffer tx_buffer(
		.CLK(CLK), 
		.RST(RST), 
		.READ_BUFFER(read_byte_from_tx_buffer), 
		.WRITETO_BUFFER(WRITE_TO_TX_BUFFER),
		.DATA_IN(DATA_IN__CONFIG[7:0]),
		.DATA_OUT(current_byte),
		.DIRTYBUFFER(data_avail_to_read),
		.FILLED(BUSY),
		.PARITY_IN(1'b0),
		.PARITY_OUT()
	);
	
	reg [1:0] mode;
	
	always@(posedge CLK or negedge RST) begin
		if (~RST)
			mode <= 2'b0;
		else
			if (SET_MODE) mode <= DATA_IN__CONFIG[1:0];
	end
	
	wire tx_busy;
	
	tx tx(
		.CLK(baudclk), 
		.RST(RST), 
		.DATA_AVAILABLE(data_avail_to_read),
		.DATA(current_byte),
		.MODE(mode),
		.BUSY(tx_busy), 
		.TX(TX)
	);
	
	assign read_byte_from_tx_buffer = data_avail_to_read & ~tx_busy;
	
	
	// Rx
	wire [7:0] out_byte;
	wire write_to_rx_buffer, interrupt, parity;
	
	rx rx(
		.CLK(baudclkx32), 
		.RST(RST), 
		.RX(RX),
		.MODE(mode),
		.DATA_DONE(write_to_rx_buffer),
		.DATA(out_byte),
		.PARITY(parity)
	);
	
	fifo_buffer rx_buffer(
		.CLK(CLK), 
		.RST(RST), 
		.READ_BUFFER(READ_BUFFER), 
		.WRITETO_BUFFER(write_to_rx_buffer),
		.DATA_IN(out_byte),
		.DATA_OUT(DATA_OUT),
		.DIRTYBUFFER(interrupt),
		.FILLED(),
		.PARITY_IN(parity),
		.PARITY_OUT(PARITY)
	);
	
	assign INTERRUPT = {7'b0, interrupt};
	
endmodule 