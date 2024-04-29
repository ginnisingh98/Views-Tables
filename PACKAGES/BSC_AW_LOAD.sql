--------------------------------------------------------
--  DDL for Package BSC_AW_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_AW_LOAD" AUTHID CURRENT_USER AS
/*$Header: BSCAWLOS.pls 120.3 2006/01/14 20:48 vsurendr noship $*/
--program runtime parameters
g_debug boolean;
g_stmt varchar2(32000);
--procedures-------------------------------------------------------
procedure load_dim(
p_dim_level_list dbms_sql.varchar2_table,
p_options varchar2
);
procedure load_kpi(
p_kpi_list dbms_sql.varchar2_table,
p_options varchar2
);
procedure load_base_table(
p_base_table_list dbms_sql.varchar2_table,
p_kpi_list dbms_sql.varchar2_table,
p_options varchar2
);
procedure purge_kpi(p_kpi varchar2,p_options varchar2);
procedure purge_dim(
p_dim_level_list dbms_sql.varchar2_table,
p_options varchar2
);
procedure dmp_dim_level_into_table(
p_dim_level_list dbms_sql.varchar2_table,
p_options varchar2
) ;
procedure dmp_kpi_cubes_into_table(
p_kpi varchar2,
p_dimset varchar2,
p_dim_levels dbms_sql.varchar2_table,
p_table_name varchar2,
p_options varchar2);
procedure dmp_kpi_cubes_into_table(
p_kpi varchar2,
p_table_name varchar2,
p_options varchar2,
p_tables out nocopy dbms_sql.varchar2_table
);
procedure init_bt_change_vector(p_base_table varchar2);
function get_bt_next_change_vector(p_base_table varchar2) return number;
procedure update_bt_change_vector(p_base_table varchar2, p_value number);
procedure drop_bt_change_vector(p_base_table varchar2);
procedure update_bt_current_period(p_base_table varchar2,p_period number,p_year number);
--procedures-------------------------------------------------------
procedure init_all;
procedure log(p_message varchar2);
procedure log_n(p_message varchar2);
-------------------------------------------------------------------

END BSC_AW_LOAD;

 

/
