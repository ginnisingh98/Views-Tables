--------------------------------------------------------
--  DDL for Package BSC_AW_ADAPTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_AW_ADAPTER" AUTHID CURRENT_USER AS
/*$Header: BSCAWAPS.pls 120.6 2006/02/27 23:16 vsurendr noship $*/
--program runtime parameters
g_debug boolean;
g_status boolean;
g_status_message varchar2(4000);
g_apps_owner varchar2(200);
g_bsc_owner varchar2(200);
g_stmt varchar2(32000);
g_adv_sum_profile number;
g_init boolean;
--procedures-------------------------------------------------------
procedure implement_kpi_aw(
p_kpi_list dbms_sql.varchar2_table,
p_options varchar2
);
procedure implement_kpi_aw(
p_kpi_list dbms_sql.varchar2_table,
p_options varchar2,
p_affected_kpi out nocopy dbms_sql.varchar2_table
);
procedure implement_kpi_aw(
p_kpi_list dbms_sql.varchar2_table,
p_affected_kpi out nocopy dbms_sql.varchar2_table
);
procedure set_up(p_options varchar2);
procedure create_dim(
p_dim_level_list dbms_sql.varchar2_table,
p_options varchar2
);
procedure drop_kpi(p_kpi_list dbms_sql.varchar2_table,p_options varchar2);
procedure drop_kpi(p_kpi_list dbms_sql.varchar2_table);
procedure upgrade(p_options varchar2);
procedure upgrade(p_new_version number,p_old_version number);
--procedures-------------------------------------------------------
procedure init_all;
procedure log(p_message varchar2);
procedure log_n(p_message varchar2);
-------------------------------------------------------------------

END BSC_AW_ADAPTER;

 

/
