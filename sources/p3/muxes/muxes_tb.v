`timescale 1ns / 1ps
`include "muxes.v"

`define ADDR_WIDTH 9
`define DATA_WIDTH 64
`define INC_WIDTH 8
`define PLEN_WIDTH 32 

module muxes_tb;
    
    reg clk;
    
    reg [`ADDR_WIDTH-1:0] sn_addr;
    reg [`DATA_WIDTH-1:0] sn_data;
    reg [`INC_WIDTH-1:0] sn_bytes_inc;
    reg sn_wr_en;
    
    reg [`ADDR_WIDTH-1:0] cpu_addr;
    wire [`DATA_WIDTH-1:0] cpu_data;
    reg cpu_rd_en;
    wire [`PLEN_WIDTH-1:0] cpu_len;
    
    reg [`ADDR_WIDTH-1:0] fwd_addr;
    wire [`DATA_WIDTH-1:0] fwd_data;
    reg fwd_rd_en;
    wire [`PLEN_WIDTH-1:0] fwd_len;
    
    wire [`ADDR_WIDTH-1:0] ping_addr;
    wire [`DATA_WIDTH-1:0] ping_wr_data;
    reg [`DATA_WIDTH-1:0] ping_rd_data;
    wire ping_rd_en;
    wire [`INC_WIDTH-1:0] ping_bytes_inc;
    wire ping_wr_en;
    reg [`PLEN_WIDTH-1:0] ping_len;
    
    wire [`ADDR_WIDTH-1:0] pang_addr;
    wire [`DATA_WIDTH-1:0] pang_wr_data;
    reg [`DATA_WIDTH-1:0] pang_rd_data;
    wire pang_rd_en;
    wire [`INC_WIDTH-1:0] pang_bytes_inc;
    wire pang_wr_en;
    reg [`PLEN_WIDTH-1:0] pang_len;
    
    wire [`ADDR_WIDTH-1:0] pong_addr;
    wire [`DATA_WIDTH-1:0] pong_wr_data;
    reg [`DATA_WIDTH-1:0] pong_rd_data;
    wire pong_rd_en;
    wire [`INC_WIDTH-1:0] pong_bytes_inc;
    wire pong_wr_en;
    reg [`PLEN_WIDTH-1:0] pong_len;
    
    reg [1:0] sn_sel;
    reg [1:0] cpu_sel;
    reg [1:0] fwd_sel;
    
    reg [1:0] ping_sel;
    reg [1:0] pang_sel;
    reg [1:0] pong_sel;
    
    integer fd;
    integer dummy;

    initial begin
        $dumpfile("muxes.vcd");
        $dumpvars;
        $dumplimit(1024000);
        
        clk <= 0;
        sn_addr <= 0;
        sn_data <= 0;
        sn_bytes_inc <= 0;
        sn_wr_en <= 0;
        
        cpu_addr <= 0;
        cpu_rd_en <= 0;
        
        fwd_addr <= 0;
        fwd_rd_en <= 0;
        
        ping_rd_data <= 0;
        ping_len <= 0;
        
        pang_rd_data <= 0;
        pang_len <= 0;
        
        pong_rd_data <= 0;
        pong_len <= 0;
        
        sn_sel <= 2'b10;
        cpu_sel <= 2'b00;
        fwd_sel <= 2'b11;
        
        ping_sel <= 2'b00;
        pang_sel <= 2'b01;
        pong_sel <= 2'b11;
        
        fd = $fopen("muxes_drivers.mem", "r");
        if (fd == 0) begin
            $display("Could not open driver file");
            $finish;
        end
        
        while ($fgetc(fd) != "\n") begin end //Skip first line of comments
        
        #200
        $display("Quitting...");
        $finish;
    end

    always #5 clk <= ~clk;
    
    always @(posedge clk) begin
        ping_rd_data <= {$random, $random};
        pang_rd_data <= {$random, $random};
        pong_rd_data <= {$random, $random};
        
        sn_addr <= $random;
        sn_data <= {$random, $random};
        cpu_addr <= $random;
        fwd_addr <= $random;
    end
    

    muxes # (
        .ADDR_WIDTH(`ADDR_WIDTH),
        .DATA_WIDTH(`DATA_WIDTH),
        .INC_WIDTH(`INC_WIDTH),
        .PLEN_WIDTH(`PLEN_WIDTH)
    ) DUT (
        //Inputs
        //Format is {addr, wr_data, wr_en, bytes_inc}
        .from_sn({sn_addr, sn_data, sn_wr_en, sn_bytes_inc}),
        //Format is {addr, rd_en}
        .from_cpu({cpu_addr, cpu_rd_en}),
        .from_fwd({fwd_addr, fwd_rd_en}),
        //Format is {rd_data, packet_len}
        .from_ping({ping_rd_data, ping_len}),
        .from_pang({pang_rd_data, pang_len}),
        .from_pong({pong_rd_data, pong_len}),
        
        //Outputs
        //Nothing to output to snooper
        //Format is {rd_data, packet_len}
        .to_cpu({cpu_data, cpu_len}),
        .to_fwd({fwd_data, fwd_len}),
        //Format here is {addr, wr_data, wr_en, bytes_inc, rd_en}
        .to_ping({ping_addr, ping_wr_data, ping_wr_en, ping_bytes_inc, ping_rd_en}),
        .to_pang({pang_addr, pang_wr_data, pang_wr_en, pang_bytes_inc, pang_rd_en}),
        .to_pong({pong_addr, pong_wr_data, pong_wr_en, pong_bytes_inc, pong_rd_en}),
        
        //Selects
        .sn_sel(sn_sel),
        .cpu_sel(cpu_sel),
        .fwd_sel(fwd_sel),
        
        .ping_sel(ping_sel),
        .pang_sel(pang_sel),
        .pong_sel(pong_sel)
    );


endmodule