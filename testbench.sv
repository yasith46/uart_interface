`timescale 1ns/1ps

module testbench;
	
	// Clock and reset
	reg clk, rst;
	
	initial begin
		clk <= 1'b0;
		
		rst <= 1'b1;
		#20 rst <= 1'b0;
		#30 rst <= 1'b1;
	end
	
	// Microcontroller clock
	always begin
		#5 clk <= ~clk;
	end
	
	
	
	// Processor end
	reg baud_w, mode_w, data_w;
	reg [31:0] in;
	reg read;
	
	initial begin
		// Set baud
		#100;
		in <= 32'd64;
		baud_w <= 1'b1;
		#10 baud_w <= 1'b0;
		$display("Baud rate sent to 64");
		
		// Set mode
		#10;
		in <= 32'b0;
		mode_w <= 1'b1;
		#10 mode_w <= 1'b0;
		$display("Mode set to M8N1");
		
		// Send data
		#100;
		in <= {24'b0, 8'h68}; //h
		data_w <= 1'b1;
		$display("'h' loaded");
		#10 in <= {24'b0, 8'h69}; //i
		$display("'i' loaded");
		#10 data_w <= 1'b0;
	end
	
	
	
	// From outside
	reg [9:0] tx_buffer;
	reg tx;
	integer i;
	
	initial begin
		tx <= 1'b1;
		read <= 1'b0;
		
		#200;
		// b
		tx_buffer <= {1'b0, 8'h62, 1'b1};
		for (i=0; i<10; i=i+1) begin
			#640 tx <= tx_buffer[i];
		end
		$display("'b' received");
		
		// y
		#640;
		tx_buffer <= {1'b0, 8'h79, 1'b1};
		for (i=0; i<10; i=i+1) begin
			#640 tx <= tx_buffer[i];
		end
		$display("'y' received");
		
		// e
		#640;
		tx_buffer <= {1'b0, 8'h65, 1'b1};
		for (i=0; i<10; i=i+1) begin
			#640 tx <= tx_buffer[i];
		end
		$display("'e' received");
		
		tx<= 1'b1;
		#100;
		read <= 1'b1;
		$display("Reading");
		
		#40;
		$stop;
	end

	
	wire rx, parity, busy, interrupt;
	wire [7:0] data_out;
	
	UARTinterface uart(
		.CLK(clk), 
		.RST(rst), 
		.WRITE_TO_TX_BUFFER(data_w), 
		.READ_BUFFER(read), 
		.SET_BR(baud_w), 
		.SET_MODE(mode_w),
		.DATA_IN__CONFIG(in),
		.DATA_OUT(data_out),
		.INTERRUPT(interrupt), 
		.BUSY(busy), 
		.PARITY(parity),
		.RX(tx),
		.TX(rx)
	);

endmodule 