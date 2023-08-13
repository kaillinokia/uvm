/*------------------------------------------------------------------------------
-- Module       : **
-- Project      : **
-- Author       : 17557295512@163.com
------------------------------------------------------------------------------
*/
`ifndef _TB_TOP_
`define _TB_TOP_


// ----------------------------------------------------------------------------
// Module Definition
// ----------------------------------------------------------------------------
module tb_top;

    // ------------------------------------------------------------------------
    // Package Imports
    // ------------------------------------------------------------------------
    import uvm_pkg::*;
    import params_share_pkg::*;
    import psinr_tc_pkg::*;

    initial 
    begin
 
        uvm_config_db#(virtual dut_top_if            )::set(null, "", "m_dut_top_vif",        dut_top.m_dut_top_if);
        uvm_config_db#(virtual time_mon_if           )::set(null, "", "m_time_mon_vif",       dut_top.m_time_mon_if);
        //combiner interface
        uvm_config_db#(virtual axi_stream_if#(BETA_INOUT_WIDTH+BETA_EXP_WIDTH))::set(null, "", "m_combiner_input_vif", dut_top.m_comb_input_if);
        uvm_config_db#(virtual axi_stream_if#(BETA_CFG_WIDTH ))::set(null, "", "m_combiner_cfg_vif", dut_top.m_comb_cfg_if);
        // uvm_config_db#(virtual axi_stream_if#(BETA_REPC_WIDTH))::set(null, "", "m_combiner_repc_vif", dut_top.m_comb_repc_if);
        uvm_config_db#(virtual axi_stream_if#(BETA_INOUT_WIDTH+BETA_EXP_WIDTH))::set(null, "", "m_combiner_output_vif", dut_top.m_comb_output_if);
        uvm_config_db#(virtual axi_stream_if#(BETA_INOUT_WIDTH+BETA_EXP_WIDTH))::set(null, "", "m_combiner_gain_vif", dut_top.m_comb_gain_if);
        //psinr interface
        uvm_config_db#(virtual axi_stream_if#(BETA_CFG_WIDTH ))::set(null, "", "m_psinr_cfg_vif", dut_top.m_psinr_cfg_if);
        uvm_config_db#(virtual axi_stream_if#(PSINR_DEMAP_WIDTH))::set(null, "", "m_psinr_demap_vif", dut_top.m_psinr_demap_if);
        uvm_config_db#(virtual axi_stream_if#(PSINR_CALC_WIDTH))::set(null, "", "m_psinr_out_vif", dut_top.m_psinr_out_if);
        uvm_config_db#(virtual axi_stream_if#(PSINR_CALC_WIDTH))::set(null, "", "m_psinr_demod_vif", dut_top.m_psinr_demod_if);
        //psinr out interface
        uvm_config_db#(virtual axi_stream_if#(BETA_CFG_WIDTH ))::set(null, "", "m_psinr_out_cfg_vif", dut_top.m_psinr_out_cfg_if);
        uvm_config_db#(virtual axi_stream_if#(3*PSINR_OUT_UCI_WIDTH))::set(null, "", "m_psinr_out_uci_vif", dut_top.m_psinr_out_uci_if);
        uvm_config_db#(virtual axi_stream_if#(PSINR_OUT_REPORT_WIDTH))::set(null, "", "m_psinr_out_report_vif", dut_top.m_psinr_out_report_if);
        run_test();
    end

endmodule:tb_top
`endif