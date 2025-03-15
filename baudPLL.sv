module baudPLL(
		input CLK, RST, SET,
		input [31:0] BAUDRATE,
		output BAUD_TICK, BAUD_TICK_X32
	);
	
	reg [31:0] baudrate_reg, baud_count_reg, oversample32_count_reg;
	
	always@(posedge CLK or negedge RST) begin
		if (~RST) begin
			baudrate_reg <= 32'b0;
			baud_count_reg <= 32'b0;
			oversample32_count_reg <= 32'b0;
		end else begin
			if (SET) begin
				baudrate_reg <= BAUDRATE;
				baud_count_reg <= 32'b0;
				oversample32_count_reg <= 32'b0;
			end else begin
				if (BAUD_TICK)
					baud_count_reg <= 32'b0;
				else
					baud_count_reg <= baud_count_reg + 32'd1;
				
				if (BAUD_TICK_X32)
					oversample32_count_reg <= 32'b0;
				else
					oversample32_count_reg <= oversample32_count_reg + 32'd1;
			end
		end
	end
	
	assign BAUD_TICK = {baud_count_reg == baudrate_reg};
	assign BAUD_TICK_X32 = {oversample32_count_reg == baudrate_reg >> 5};
endmodule 