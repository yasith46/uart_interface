module fifo_buffer(
		input CLK, RST, READ_BUFFER, WRITETO_BUFFER,
		input  [7:0] DATA_IN,
		output [7:0] DATA_OUT,
		output DIRTYBUFFER, FILLED
	);
	
	reg [7:0] current_byte;
	wire data_avail_to_read;
	
	reg [9:0] buffer [255:0];
	reg [255:0] buffer_valid;
	
	reg [7:0] write_head, read_head;
	
	always@(posedge CLK or negedge RST) begin
		if (~RST) begin
			write_head <= 8'b0;
			read_head <= 8'b0;
			buffer_valid <= 256'b0;
		end else begin
			if (WRITETO_BUFFER) begin
				buffer[write_head] <= DATA_IN;
				buffer_valid <= buffer_valid | (1'b1 << write_head);	// Sets to 1
				write_head <= write_head + 8'd1;
			end
			
			if (READ_BUFFER) begin
				current_byte <= buffer[read_head];
				buffer_valid <= buffer_valid & ~(1'b1 << read_head);  // Sets to 0
				read_head <= read_head + 8'd1;
			end
		end
	end
	
	assign DIRTYBUFFER = buffer_valid[read_head];
	assign DATA_OUT = current_byte;
	assign FILLED = &{buffer_valid};
	
endmodule 