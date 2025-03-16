module fifo_buffer(
		input CLK, RST, READ_BUFFER, WRITETO_BUFFER, PARITY_IN,
		input  [7:0] DATA_IN,
		output [7:0] DATA_OUT,
		output DIRTYBUFFER, FILLED, PARITY_OUT
	);
	
	reg [8:0] current_read;
	wire data_avail_to_read;
	
	reg [8:0] buffer [255:0];
	reg [255:0] buffer_valid;
	
	reg [7:0] write_head, read_head;
	
	always@(posedge CLK or negedge RST) begin
		if (~RST) begin
			write_head <= 8'b0;
			read_head <= 8'b0;
			
			buffer_valid <= 256'b0;
			
		end else begin
			if (WRITETO_BUFFER) begin
				buffer[write_head] <= {PARITY_IN, DATA_IN};
				write_head <= write_head + 8'd1;
			end
			
			if (READ_BUFFER) begin
				current_read <= buffer[read_head];
				read_head <= read_head + 8'd1;
			end
			
			if (WRITETO_BUFFER & READ_BUFFER) begin
				buffer_valid <= buffer_valid & ~(256'b1 << read_head) | (256'b1 << write_head);    // Sets to 0
			end else if (WRITETO_BUFFER) begin
				buffer_valid <= buffer_valid | (256'b1 << write_head); // Sets to 1
			end else if (READ_BUFFER) begin
				buffer_valid <= buffer_valid & ~(256'b1 << read_head); // Sets to 0
			end
		end
	end
	
	assign DIRTYBUFFER = buffer_valid[read_head];
	assign DATA_OUT = current_read[7:0];
	assign PARITY_OUT = current_read[8];	
	assign FILLED = &{buffer_valid};
	
endmodule 