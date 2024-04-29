--------------------------------------------------------
--  DDL for Package QP_PS_ATTR_GRP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PS_ATTR_GRP_PVT" AUTHID CURRENT_USER as
/* $Header: QPXPATGS.pls 120.0.12010000.3 2010/01/29 09:12:20 jputta noship $ */

type number_tbl_type is table of number index by binary_integer;
type date_tbl_type is table of date index by binary_integer;
type varchar1_tbl_type is table of varchar2(1) index by binary_integer;
type varchar3_tbl_type is table of varchar2(3) index by binary_integer;
type varchar30_tbl_type is table of varchar2(30) index by binary_integer;
type varchar240_tbl_type is table of varchar2(240) index by binary_integer;
type varchar2000_tbl_type is table of varchar2(2000) index by binary_integer;
type varchar4000_tbl_type is table of varchar2(4000) index by binary_integer;

type pattern_upg_slab_rec is record
	(worker number,
	 low_list_line_id number,
	 high_list_line_id number);
type pattern_upg_slab_table is table of pattern_upg_slab_rec index by binary_integer;

g_delimiter                                     varchar2(1) := '|';
g_call_from_setup                               varchar2(1) := 'N';
g_list_type					VARCHAR2(30) :='JP';
G_QP_DEBUG					VARCHAR2(1):='Y';


-- cursor tables
g_list_header_id_c_tbl                          number_tbl_type;
g_list_line_id_c_tbl                            number_tbl_type;
g_segment_id_c_tbl                              number_tbl_type;
g_active_flag_c_tbl                             varchar1_tbl_type;
g_list_type_code_c_tbl                          varchar30_tbl_type;
g_start_date_active_q_c_tbl                     date_tbl_type;
g_end_date_active_q_c_tbl                       date_tbl_type;
g_currency_code_c_tbl                           varchar30_tbl_type;
g_ask_for_flag_c_tbl                            varchar1_tbl_type;
g_header_limit_exists_c_tbl                     varchar1_tbl_type;
g_line_limit_exists_c_tbl                     varchar1_tbl_type;
g_source_system_code_c_tbl                      varchar30_tbl_type;
g_effective_precedence_c_tbl                    number_tbl_type;
g_qual_grouping_no_c_tbl                        number_tbl_type;
g_comparison_opr_code_c_tbl                     varchar30_tbl_type;
g_pricing_phase_id_c_tbl                        number_tbl_type;
g_modifier_level_code_c_tbl                     varchar30_tbl_type;
g_qual_datatype_c_tbl                           varchar30_tbl_type;
g_qual_attr_val_c_tbl                           varchar240_tbl_type;
g_attribute_type_c_tbl                          varchar30_tbl_type;
g_product_uom_code_c_tbl                        varchar30_tbl_type; -- only used in pp
g_prc_brk_typ_code_c_tbl			varchar30_tbl_type;
g_pte_code_c_tbl				varchar30_tbl_type;
------- jagan
g_header_quals_exist_c_tbl			varchar1_tbl_type;
g_orig_org_id_c_tbl                             number_tbl_type;
g_global_flag_c_tbl                             varchar1_tbl_type;
g_product_uom_code_j_c_tbl                      varchar30_tbl_type;
g_creation_date_c_tbl                           date_tbl_type;

g_created_by_c_tbl                              number_tbl_type;
g_request_id_c_tbl	                        number_tbl_type;
g_program_update_date_c_tbl			date_tbl_type;
g_program_id_c_tbl				number_tbl_type;
g_program_applic_id_c_tbl		        number_tbl_type;
g_start_date_act_firs_c_tbl                     date_tbl_type;
g_end_date_act_firs_c_tbl			date_tbl_type;
g_start_date_act_sec_c_tbl			date_tbl_type;
g_end_date_act_sec_c_tbl			date_tbl_type;
g_start_date_act_h_c_tbl                        date_tbl_type;
g_end_date_act_h_c_tbl                          date_tbl_type;
g_start_date_act_l_c_tbl                        date_tbl_type;
g_end_date_act_l_c_tbl                          date_tbl_type;
g_eq_flag_c_tbl					varchar1_tbl_type;
g_act_date_firs_type_c_tbl                  varchar30_tbl_type;
g_act_date_sec_type_c_tbl                    varchar30_tbl_type;
g_currency_header_id_c_tbl			number_tbl_type;
g_desc_quals_exist_c_tbl			varchar1_tbl_type;
g_list_line_typ_code_c_tbl			varchar30_tbl_type;
g_automatic_flag_c_tbl				varchar1_tbl_type;


--------jagan


-- temp tables
g_list_header_id_tmp_tbl                          number_tbl_type;
g_list_line_id_tmp_tbl                            number_tbl_type;
g_active_flag_tmp_tbl                             varchar1_tbl_type;
g_list_type_code_tmp_tbl                          varchar30_tbl_type;
g_start_date_active_q_tmp_tbl                     date_tbl_type;
g_end_date_active_q_tmp_tbl                       date_tbl_type;
g_currency_code_tmp_tbl                           varchar30_tbl_type;
g_ask_for_flag_tmp_tbl                            varchar1_tbl_type;
g_header_limit_exists_tmp_tbl                     varchar1_tbl_type;
g_line_limit_exists_tmp_tbl                     varchar1_tbl_type;
g_source_system_code_tmp_tbl                      varchar30_tbl_type;
g_effective_precedence_tmp_tbl                    number_tbl_type;
g_qual_grouping_no_tmp_tbl                        number_tbl_type;
g_pricing_phase_id_tmp_tbl                        number_tbl_type;
g_modifier_level_code_tmp_tbl                     varchar30_tbl_type;
g_hash_key_tmp_tbl                                varchar2000_tbl_type;
g_cache_key_tmp_tbl                               varchar240_tbl_type;
g_pat_string_tmp_tbl                              varchar2000_tbl_type;
g_product_uom_code_tmp_tbl                        varchar30_tbl_type; -- only used in pp
g_pricing_attr_count_tmp_tbl                      number_tbl_type; -- only used in pp
g_comparison_opr_code_tmp_tbl                     varchar30_tbl_type;  -- jagan
g_pte_code_tmp_tbl				varchar30_tbl_type;
------- jagan
g_header_quals_exist_tmp_tbl			        varchar1_tbl_type;
g_orig_org_id_tmp_tbl                             number_tbl_type;
g_global_flag_tmp_tbl                             varchar1_tbl_type;
g_product_uom_code_j_tmp_tbl                      varchar30_tbl_type;
g_creation_date_tmp_tbl                           date_tbl_type;

g_created_by_tmp_tbl                              number_tbl_type;
g_request_id_tmp_tbl	                          number_tbl_type;
g_program_update_date_tmp_tbl			  date_tbl_type;
g_program_id_tmp_tbl				  number_tbl_type;
g_program_applic_id_tmp_tbl			  number_tbl_type;
g_start_date_act_firs_tmp_tbl                     date_tbl_type;
g_end_date_act_firs_tmp_tbl                       date_tbl_type;
g_start_date_act_sec_tmp_tbl                      date_tbl_type;
g_end_date_act_sec_tmp_tbl                        date_tbl_type;
g_start_date_act_h_tmp_tbl                        date_tbl_type;
g_end_date_act_h_tmp_tbl                          date_tbl_type;
g_start_date_act_l_tmp_tbl                        date_tbl_type;
g_end_date_act_l_tmp_tbl                          date_tbl_type;
g_eq_flag_tmp_tbl			          varchar1_tbl_type;
g_attribute_type_tmp_tbl                            varchar30_tbl_type;
g_act_date_firs_type_tmp_tbl                      varchar30_tbl_type;
g_act_date_sec_type_tmp_tbl                       varchar30_tbl_type;
g_currency_header_id_tmp_tbl			  number_tbl_type;
g_other_oprt_count_tmp_tbl				number_tbl_type;
g_null_other_oprt_cnt_tmp_tbl			  number_tbl_type;
g_desc_quals_exist_tmp_tbl			varchar1_tbl_type;
g_prc_brk_typ_code_tmp_tbl			varchar30_tbl_type;
g_list_line_typ_code_tmp_tbl			varchar30_tbl_type;
g_automatic_flag_tmp_tbl				varchar1_tbl_type;

--------jagan

-- final tables
g_list_header_id_final_tbl                          number_tbl_type;
g_list_line_id_final_tbl                            number_tbl_type;
g_active_flag_final_tbl                             varchar1_tbl_type;
g_list_type_code_final_tbl                          varchar30_tbl_type;
g_st_date_active_q_final_tbl                        date_tbl_type;
g_end_date_active_q_final_tbl                       date_tbl_type;
g_pattern_id_final_tbl                              number_tbl_type;
g_currency_code_final_tbl                           varchar30_tbl_type;
g_ask_for_flag_final_tbl                            varchar1_tbl_type;
g_header_limit_exists_fnl_tbl                     varchar1_tbl_type;
g_line_limit_exists_fnl_tbl                     varchar1_tbl_type;
g_source_system_code_final_tbl                      varchar30_tbl_type;
g_effec_precedence_final_tbl                        number_tbl_type;
g_qual_grouping_no_final_tbl                        number_tbl_type;
g_pricing_phase_id_final_tbl                        number_tbl_type;
g_modifier_lvl_code_final_tbl                       varchar30_tbl_type;
g_hash_key_final_tbl                                varchar2000_tbl_type;
g_cache_key_final_tbl                               varchar240_tbl_type;
g_product_uom_code_final_tbl                        varchar30_tbl_type; -- only used in pp
g_pricing_attr_count_final_tbl                      number_tbl_type; -- only used in pp
g_pattern_segment_ind_fnl_tbl			    number_tbl_type;
g_prc_brk_typ_code_fnl_tbl			varchar30_tbl_type;
g_pte_code_fnl_tbl				varchar30_tbl_type;
g_list_line_typ_code_fnl_tbl			varchar30_tbl_type;
g_automatic_flag_fnl_tbl			varchar1_tbl_type;

------- jagan
g_header_quals_exist_fnl_tbl			    varchar1_tbl_type;
g_orig_org_id_fnl_tbl                               number_tbl_type;
g_global_flag_fnl_tbl                               varchar1_tbl_type;
g_product_uom_code_j_fnl_tbl                        varchar30_tbl_type;
g_request_id_fnl_tbl	                            number_tbl_type;
g_program_update_date_fnl_tbl			    date_tbl_type;
g_program_id_fnl_tbl				    number_tbl_type;
g_program_applic_id_fnl_tbl			    number_tbl_type;
g_start_date_act_firs_fnl_tbl                       date_tbl_type;
g_end_date_act_firs_fnl_tbl			    date_tbl_type;
g_start_date_act_sec_fnl_tbl			    date_tbl_type;
g_end_date_act_sec_fnl_tbl                          date_tbl_type;
g_start_date_act_h_fnl_tbl                          date_tbl_type;
g_end_date_act_h_fnl_tbl                            date_tbl_type;
g_start_date_act_l_fnl_tbl                          date_tbl_type;
g_end_date_act_l_fnl_tbl                            date_tbl_type;
g_eq_flag_fnl_tbl				    varchar1_tbl_type;
g_act_date_first_type_fnl_tbl                    varchar30_tbl_type;
g_act_date_sec_type_fnl_tbl                   varchar30_tbl_type;
g_currency_header_id_fnl_tbl			number_tbl_type;
g_other_oprt_count_fnl_tbl				number_tbl_type;
g_null_other_oprt_cnt_fnl_tbl			  number_tbl_type;
g_desc_quals_exist_fnl_tbl			varchar1_tbl_type;

--------jagan
-- the standard who columns for qp_attribute_grps and qp_list_lines
g_creation_date_final_tbl                           date_tbl_type;
g_created_by_final_tbl                              number_tbl_type;
g_last_update_date_final_tbl                        date_tbl_type;
g_last_updated_by_final_tbl                         number_tbl_type;
g_last_update_login_final_tbl                       number_tbl_type;
g_program_appl_id_final_tbl                         number_tbl_type;
g_program_id_final_tbl                              number_tbl_type;
g_program_upd_date_final_tbl                        date_tbl_type;
g_request_id_final_tbl                              number_tbl_type;

g_pattern_grouping_no_tmp_tbl                     number_tbl_type;
g_pattern_segment_id_tmp_tbl                      number_tbl_type;

g_pattern_pattern_id_final_tbl                    number_tbl_type;
g_pattern_segment_id_final_tbl                    number_tbl_type;
g_pattern_pat_type_final_tbl                      varchar30_tbl_type;
g_pattern_pat_string_final_tbl                    varchar2000_tbl_type;
-- the standard who columns for qp_patterns
g_pattern_cr_dt_final_tbl                         date_tbl_type;
g_pattern_cr_by_final_tbl                         number_tbl_type;
g_pattern_lst_up_dt_final_tbl                     date_tbl_type;
g_pattern_lt_up_by_final_tbl                      number_tbl_type;
g_pattern_lt_up_lg_final_tbl                      number_tbl_type;
g_pattern_pr_ap_id_final_tbl                      number_tbl_type;
g_pattern_pr_id_final_tbl                         number_tbl_type;
g_pattern_pr_up_dt_final_tbl                      date_tbl_type;
g_pattern_req_id_final_tbl                        number_tbl_type;

g_pattern_upg_slab_table			  pattern_upg_slab_table;
g_pattern_upg_chunk_table			  pattern_upg_slab_table;

g_init_val constant number := -99999;
g_qp_pattern_search VARCHAR2(1) default nvl(FND_PROFILE.VALUE('QP_PATTERN_SEARCH'),'N');
--g_eq_flag  VARCHAR2(1) DEFAULT NULL;

PROCEDURE Pattern_Upgrade (
 err_buff out NOCOPY VARCHAR2,
 retcode out NOCOPY NUMBER,
 p_list_header_id          IN NUMBER default null,
 p_low_list_line_id IN NUMBER default null,
 p_high_list_line_id IN NUMBER default NULL,
 p_no_of_threads IN NUMBER default 1,
 p_spawned_request IN VARCHAR2 default 'N',
 p_debug VARCHAR2 DEFAULT 'N');

procedure   generate_hp_atgrps(p_list_header_id  number
                              ,p_qualifier_group number);
procedure   generate_lp_atgrps(p_list_header_id  number
                              ,p_qualifier_group number
                              ,p_low_list_line_id    number
                              ,p_high_list_line_id    number);
procedure   update_pp_lines(p_list_header_id  number
                              ,p_low_list_line_id    number
                              ,p_high_list_line_id    number);
procedure   process_c_tables(p_pattern_type  VARCHAR2);
procedure   process_c_tables_pp(p_pattern_type  VARCHAR2);
procedure   Move_data_from_tmp_to_final(p_pattern_type  VARCHAR2);
procedure   populate_patterns;
procedure   populate_atgrps;
procedure   update_list_lines;
procedure   populate_pp_atgrps;
procedure   Reset_c_tables;
procedure   Reset_tmp_tables;
procedure   Reset_final_tables;
function get_pattern_id(p_pattern_type varchar2, p_pat_string varchar2,
                        p_grp_no number)
    return number;

PROCEDURE Populate_Pattern_Phases (
 p_list_header_id                    IN NUMBER,
 p_pricing_phase_id                  IN NUMBER,
 p_pattern_id                        IN NUMBER);

-- main procedure to process product pattern
PROCEDURE Product_Pattern_Main (
 p_list_header_id                    IN NUMBER ,
 p_list_line_id                      IN NUMBER ,
 p_setup_action                      IN VARCHAR2 );

-- main procedure to process header pattern
PROCEDURE Header_Pattern_Main (
  p_list_header_id      IN NUMBER
 ,p_qualifier_group     IN NUMBER
 ,p_setup_action        IN VARCHAR2
);

-- main procedure to process line pattern
PROCEDURE Line_Pattern_Main (
 p_list_header_id     IN NUMBER
 ,p_list_line_id      IN NUMBER
 ,p_qualifier_group   IN NUMBER
 ,p_setup_action      IN VARCHAR2 );

-- procedure to remove product pattern
PROCEDURE Remove_Prod_Pattern_for_Line(p_list_line_id      IN  NUMBER);

PROCEDURE Update_Qual_Segment_id(p_list_header_id  IN  NUMBER
                                ,p_qualifier_group IN  NUMBER
                                ,p_low_list_line_id    number
                                ,p_high_list_line_id    number);

PROCEDURE Update_Prod_Pric_Segment_id(p_list_header_id  IN  NUMBER
                              ,p_low_list_line_id    number
                              ,p_high_list_line_id    number);

procedure   update_list_lines_cache_key;

PROCEDURE write_log
	 (log_text VARCHAR2);
end QP_PS_ATTR_GRP_PVT; -- end package

/
