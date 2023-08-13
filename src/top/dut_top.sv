/*------------------------------------------------------------------------------
-- Module       : **
-- Project      : **
-- Author       : 17557295512@163.com
------------------------------------------------------------------------------
*/
`ifndef __DUT_TOP_SV__
`define __DUT_TOP_SV__

// ----------------------------------------------------------------------------
// Global Imports
// ----------------------------------------------------------------------------
import params_share_pkg::*;

module dut_top;

    bit     m_rst_n;
    bit     m_rst;
    bit     m_clock;

    int     m_slot;
    int     m_symble;
    int     m_clk;

    dut_top_if                                                   m_dut_top_if();
    time_mon_if                                                  m_time_mon_if();
    // combiner interface
    axi_stream_if#(BETA_INOUT_WIDTH+BETA_EXP_WIDTH)              m_comb_input_if();
    axi_stream_if#(BETA_CFG_WIDTH)                               m_comb_cfg_if();
    
    axi_stream_if#(BETA_INOUT_WIDTH+BETA_EXP_WIDTH)              m_comb_output_if();
    axi_stream_if#(BETA_INOUT_WIDTH+BETA_EXP_WIDTH)              m_comb_gain_if();
    //combiner internal interface
    axi_stream_if#(BETA_INT_WIDTH)                               m_comb_acc_if();
    axi_stream_if#(BETA_INT_WIDTH)                               m_comb_avgShift_if();


    // psinr interface
    axi_stream_if#(BETA_CFG_WIDTH)                               m_psinr_cfg_if();
    axi_stream_if#(PSINR_DEMAP_WIDTH)                            m_psinr_demap_if();
    axi_stream_if#(PSINR_CALC_WIDTH)                             m_psinr_out_if();
    axi_stream_if#(PSINR_CALC_WIDTH)                             m_psinr_demod_if();

    //psinr out interface
    axi_stream_if#(BETA_CFG_WIDTH)                               m_psinr_out_cfg_if();
    axi_stream_if#(PSINR_OUT_REPORT_WIDTH)                       m_psinr_out_report_if();
    axi_stream_if#(3*PSINR_OUT_UCI_WIDTH)                        m_psinr_out_uci_if();

    assign m_dut_top_if.clk = m_clock;
    assign m_rst_n = ~m_dut_top_if.rst;

    //combiner interface
    assign m_comb_input_if.aclk = m_clock;
    assign m_comb_input_if.arstn = m_rst_n;
    assign m_comb_cfg_if.aclk = m_clock;
    assign m_comb_cfg_if.arstn = m_rst_n;
    assign m_comb_output_if.aclk = m_clock;
    assign m_comb_output_if.arstn = m_rst_n;
    assign m_comb_gain_if.aclk = m_clock;
    assign m_comb_gain_if.arstn = m_rst_n;
    
    //combiner internal interface
    assign m_comb_acc_if.aclk               = inst_dut_top.u_combiner.i_combiner_proc.clk;
    assign m_comb_acc_if.arstn              = m_rst_n;
    assign m_comb_acc_if.tvalid             = inst_dut_top.u_combiner.i_combiner_proc.combiner_valid_vec[3] && inst_dut_top.u_combiner.i_combiner_proc.combiner_last_sym_vec[5];
    assign m_comb_acc_if.tdata[26:0]        = inst_dut_top.u_combiner.i_combiner_proc.beta_rhh_acc;
    assign m_comb_acc_if.tdata[31:27]       = 5'b0;
    assign m_comb_avgShift_if.aclk          = inst_dut_top.u_combiner.i_combiner_proc.clk;
    assign m_comb_avgShift_if.arstn         = m_rst_n;
    assign m_comb_avgShift_if.tvalid        = inst_dut_top.u_combiner.i_combiner_proc.combiner_valid_vec[5] && inst_dut_top.u_combiner.i_combiner_proc.combiner_last_sym_vec[5];
    assign m_comb_avgShift_if.tdata[30:0]   = inst_dut_top.u_combiner.i_combiner_proc.beta_rhh_acc_avg.a;
    assign m_comb_avgShift_if.tdata[31]     = 1'b0;


    //psinr interface
    assign m_psinr_cfg_if.aclk = m_clock;
    assign m_psinr_cfg_if.arstn = m_rst_n;
    assign m_psinr_demap_if.aclk = m_clock;
    assign m_psinr_demap_if.arstn = m_rst_n;
    assign m_psinr_out_if.aclk = m_clock;
    assign m_psinr_out_if.arstn = m_rst_n;
    assign m_psinr_demod_if.aclk = m_clock;
    assign m_psinr_demod_if.arstn = m_rst_n;

    //psinr out interface
    assign m_psinr_out_cfg_if.aclk = m_clock;
    assign m_psinr_out_cfg_if.arstn = m_rst_n;    
    assign m_psinr_out_report_if.aclk = m_clock;
    assign m_psinr_out_report_if.arstn = m_rst_n;
    assign m_psinr_out_uci_if.aclk = m_clock;
    assign m_psinr_out_uci_if.arstn = m_rst_n;

    assign m_time_mon_if.clk = m_clock;

    assign m_slot    = m_time_mon_if.time_val_tab[2];
    assign m_symble  = m_time_mon_if.time_val_tab[1];
    assign m_clk     = m_time_mon_if.time_val_tab[0];


    rtl_top_wrapper inst_dut_top(
        .clk(m_dut_top_if.clk),
        .arst_n(m_dut_top_if.arst_n),
        .reset(m_dut_top_if.rst),
        .comb_tvalid(m_comb_input_if.tvalid),
        .comb_tdata(m_comb_input_if.tdata[BETA_INOUT_WIDTH-1:0]),
        .comb_texp(m_comb_input_if.tdata[BETA_INOUT_WIDTH+BETA_EXP_WIDTH-1:BETA_INOUT_WIDTH]),
        .comb_tlast(m_comb_input_if.tlast),
        .comb_tready(m_comb_input_if.tready),
        .comb_cfg(m_comb_cfg_if.tdata),
        .comb_cfg_valid(m_comb_cfg_if.tvalid),
        .comb_cfg_ready(m_comb_cfg_if.tready),
        .comb_psinr_tdata(m_comb_output_if.tdata[BETA_INOUT_WIDTH-1:0]),
        .comb_psinr_texp(m_comb_output_if.tdata[BETA_INOUT_WIDTH+BETA_EXP_WIDTH-1:BETA_INOUT_WIDTH]),
        .comb_psinr_tvalid(m_comb_output_if.tvalid),
        .comb_psinr_tlast(m_comb_output_if.tlast),
        .comb_gain_tdata(m_comb_gain_if.tdata[BETA_INOUT_WIDTH-1:0]),
        .comb_gain_texp(m_comb_gain_if.tdata[BETA_INOUT_WIDTH+BETA_EXP_WIDTH-1:BETA_INOUT_WIDTH]),
        .comb_gain_tvalid(m_comb_gain_if.tvalid),
        .comb_gain_tlast(m_comb_gain_if.tlast),
        .comb_gain_tready(1'b1),
        .psinr_cfg_data         (m_psinr_cfg_if.tdata),                      
        .psinr_cfg_valid        (m_psinr_cfg_if.tvalid),               
        .psinr_cfg_ready        (m_psinr_cfg_if.tready),              
        .psinr_layer_dmap_tdata (m_psinr_demap_if.tdata),                      
        .psinr_layer_dmap_tvalid(m_psinr_demap_if.tvalid),                      
        .psinr_layer_dmap_tlast (m_psinr_demap_if.tlast),                      
        .psinr_layer_dmap_tready(1'b1),                      
        .psinr_psinr_out_tdata  (m_psinr_out_if.tdata),                     
        .psinr_psinr_out_tvalid (m_psinr_out_if.tvalid),                     
        .psinr_psinr_out_tlast  (m_psinr_out_if.tlast),                     
        // .psinr_psinr_out_tready (1'b1),                     
        .psinr_dmod_tdata       (m_psinr_demod_if.tdata),                
        .psinr_dmod_tvalid      (m_psinr_demod_if.tvalid),                
        .psinr_dmod_tlast       (m_psinr_demod_if.tlast),                
        .psinr_dmod_tready      (1'b1),
        .psinr_out_cfg          (m_psinr_out_cfg_if.tdata),
        .psinr_out_cfg_valid    (m_psinr_out_cfg_if.tvalid),
        .psinr_out_cfg_ready    (m_psinr_out_cfg_if.tready),       
        .UCI_ack_Psinr          (m_psinr_out_uci_if.tdata[255:0]),                             
        .UCI_csi1_Psinr         (m_psinr_out_uci_if.tdata[511:256]),                 
        .UCI_data_csi2_Psinr    (m_psinr_out_uci_if.tdata[767:512]),                 
        .UCI_Psinr_out_valid    (m_psinr_out_uci_if.tvalid),                 
        .Psinr_out_UCI_tready   (m_psinr_out_uci_if.tready),                   
        .Psinr_out_Report_tdata (m_psinr_out_report_if.tdata),                             
        .Psinr_out_Report_tvalid(m_psinr_out_report_if.tvalid),                             
        .Psinr_out_Report_tlast (m_psinr_out_report_if.tlast[1:0]),                             
        .Psinr_out_Report_tready(1'b1)                                          
    );

    //clk gen
    initial 
    begin
        m_clock = 0;
        forever 
        begin
            #(CLK_CYCLE/2);
            m_clock = ~m_clock;
        end
    end

    // rst gen
    initial 
    begin
        m_dut_top_if.fpga_reset();
        m_dut_top_if.asic_resetn();
    end


endmodule: dut_top


`endif //__DUT_TOP_SV__