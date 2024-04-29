--------------------------------------------------------
--  DDL for Package BIV_CORE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_CORE_PKG" AUTHID CURRENT_USER as
/* $Header: bivcores.pls 115.21 2003/11/10 15:00:15 vganeshk ship $ */
  type g_parameter_array is table of varchar2(100) index by binary_integer;
  g_value_sep       varchar2(10) := '=';
  g_param_sep       varchar2(10) :=
                     fnd_profile.value('JTFB_PARAMETER_DELIMITER');
  g_multi_value_sep varchar2(10) :=
                     fnd_profile.value('JTFB_MULTI_SELECT_DELIMITER');

  procedure get_parameter_values_all(
                         p_param_values in out nocopy g_parameter_array,
                         p_total_values in out nocopy number,
                         p_param_str           varchar2,
                         p_param_name          varchar2
                       )  ;
  procedure prt_parameter_values(p_param_values in out nocopy g_parameter_array,
                                 p_total_values in out nocopy number);
  procedure biv_debug(p_msg varchar2,
                      p_report varchar2) ;
  function  get_parameter_value(p_param_str  varchar2,
                                p_param_name varchar2,
                                p_param_sep  varchar2 default g_param_sep,
                                p_value_sep  varchar2 default g_value_sep)
                   return varchar2 ;
  /*
  function  get_parameter_value(p_param_str  varchar2,
                                p_param_name varchar2,
                                p_param_end_pos in out number,
                                p_start_pos  number default 1,
                                p_param_sep  varchar2 default g_param_sep,
                                p_value_sep  varchar2 default g_value_sep)
                   return varchar2 ;
  **********************************************************************/
  procedure yesterday(x_start_date in out nocopy date,
                      x_end_date   in out nocopy date);
  procedure last_year(x_start_date in out nocopy date,
                      x_end_date   in out nocopy date);
  procedure last_month(x_start_date in out nocopy date,
                       x_end_date   in out nocopy date);
  procedure last_week (x_start_date in out nocopy date,
                       x_end_date   in out nocopy date);
  procedure last_13weeks(x_start_date in out nocopy date,
                         x_end_date   in out nocopy date);
  procedure get_dates   (p_period_type       varchar2,
                         x_start_date in out nocopy date,
                         x_end_date   in out nocopy date);
  function  get_lookup_meaning(p_lookup_code varchar2) return varchar2;

  g_cust_id        biv_core_pkg.g_parameter_array;
  g_cntr_id        biv_core_pkg.g_parameter_array;
  g_ogrp           biv_core_pkg.g_parameter_array;
  g_agrp           biv_core_pkg.g_parameter_array;
  g_prd_id         biv_core_pkg.g_parameter_array;
  g_sev            biv_core_pkg.g_parameter_array;
  g_esc_lvl        biv_core_pkg.g_parameter_array;
  g_prd_ver        biv_core_pkg.g_parameter_array;
  g_comp_id        biv_core_pkg.g_parameter_array;
  g_subcomp_id     biv_core_pkg.g_parameter_array;
  g_platform_id    biv_core_pkg.g_parameter_array;
  g_sts_id         biv_core_pkg.g_parameter_array;
  g_mgr_id         biv_core_pkg.g_parameter_array;
  g_site_id        biv_core_pkg.g_parameter_array;


  g_cust_id_cnt       number;
  g_cntr_id_cnt       number;
  g_ogrp_cnt          number;
  g_agrp_cnt          number;
  g_prd_id_cnt        number;
  g_sev_cnt           number;
  g_esc_lvl_cnt       number;
  g_prd_ver_cnt       number;
  g_comp_id_cnt       number;
  g_subcomp_id_cnt    number;
  g_platform_id_cnt   number;
  g_sts_id_cnt        number;
  g_mgr_id_cnt        number;
  g_site_id_cnt       number;


  g_resl_code        varchar2(80);
  g_time_frame       varchar2(10);
  g_base_column      varchar2(80);
  g_view_by          varchar2(80);
  g_lvl              varchar2(20);
  g_ogrp_lvl         varchar2(20);
  g_agrp_lvl         varchar2(20);
  g_st_date          date;
  g_end_date         date;
  g_srt_by           varchar2(20);
  g_cr_tm_prd        varchar2(80);
  g_cl_tm_prd        varchar2(80);
  g_esc_tm_prd       varchar2(10);
  g_cl_st            date;
  g_cl_end           date;
  g_esc_st           date;
  g_esc_end          date;
  g_cr_st            date;
  g_cr_end           date;
  g_disp             varchar2(60);
  g_unown            varchar2(10);
  g_esc_sr           varchar2(10);

  g_blog               varchar2(20);
  g_eblog              varchar2(20);
  g_oblog              varchar2(20);
  g_other_blog         varchar2(20);
  g_agent_id           varchar2(30);
  g_close_sr           varchar2(10);
  g_new_sr             varchar2(10);
  g_reopen             varchar2(10);
  g_reclose            varchar2(10);
  g_today_only         varchar2(10);
  g_chnl               varchar2(40);
  g_prd_org            varchar2(15) :=
                          fnd_profile.value('CS_INV_VALIDATION_ORG');
  g_tm_zn              varchar2(10);
  g_ott                varchar2(10);
  g_rsc                varchar2(10); -- used for resource availability
  -- this has values as displayed in first column of resource bin.
  -- at presnt it will have null for ALL and WEB for web availavle agents
  g_arvl_tm            varchar2(20);


  g_report_id       varchar2(60);
  g_report_type     varchar2( 2) := 'RT';
/*
        Variable g_ua, g_pr introduced for bug 3093779
*/
  g_ua              varchar2(2) :='Y';
  g_pr              varchar2(100);
/*
        Variable g_total introduced for enh 2914005
*/
  g_total           varchar2(100);
  g_srl_no          number       := 1;
  g_null            varchar2(30) := 'NULL';
  g_debug           varchar2(10) ;
  g_local_chr       varchar2(10) := fnd_global.local_chr(10);

  procedure get_report_parameters(p_param_str varchar2);
  procedure get_where_clause(p_from_clause  in out nocopy varchar2,
                               p_where_clause in out nocopy varchar2);
  procedure bind_all_variables(p_cursor number);
  function  param_for_base_col return varchar2;
  procedure add_a_bind(p_cursor number,
                     p_param_array         biv_core_pkg.g_parameter_array,
                     p_param_array_size    number,
                     p_prefix              varchar2,
                     p_column_name         varchar2);
  procedure add_a_condition(p_param_array    biv_core_pkg.g_parameter_array,
                          p_param_array_size number,
                          p_prefix           varchar2,
                          p_column_name      varchar2,
                          p_table            varchar2,
                          p_where_clause in out nocopy varchar2,
                          p_outer_cond       varchar2 default 'N');
  procedure update_base_col_desc (p_tbl_name varchar2 default null);
  procedure update_description(p_id_type  varchar2,
                               p_id_col   varchar2,
                               p_desc_col varchar2,
                               p_tbl_name varchar2 default null);
  function  are_all_parameters_null return number;
  function  reconstruct_param_str return varchar2;
  procedure reset_view_by_param;

  function  get_session_id return number;
  function  base_column_description(p_param_str varchar2) return varchar2;
  procedure clean_dcf_table(p_code varchar2);
  procedure clean_region_table(p_region varchar2);

end;

 

/
