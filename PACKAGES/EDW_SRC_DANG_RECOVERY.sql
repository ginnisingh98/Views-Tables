--------------------------------------------------------
--  DDL for Package EDW_SRC_DANG_RECOVERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_SRC_DANG_RECOVERY" AUTHID CURRENT_USER as
/*$Header: EDWSRDTS.pls 115.4 2002/12/12 20:29:44 vsurendr noship $*/
Type varcharTableType is Table of varchar2(400) index by binary_integer;
Type L_varcharTableType is Table of varchar2(4000) index by binary_integer;
Type LL_varcharTableType is Table of varchar2(10000) index by binary_integer;
Type LLL_varcharTableType is Table of varchar2(20000) index by binary_integer;
Type numberTableType is Table of number index by binary_integer;
Type dateTableType is Table of date index by binary_integer;
Type booleanTableType is Table of boolean index by binary_integer;
Type rowidTableType is Table of rowid index by binary_integer;

g_status_message varchar2(4000);
g_object_name varchar2(400);
g_object_id number;
g_db_link varchar2(400);
g_db_link_stmt varchar2(400);--this is @g_db_link. it will be null for single instance
g_src_op_table_space varchar2(400);
g_src_parallel number;
g_src_bis_owner varchar2(400);
g_debug boolean;
g_instance varchar2(100);
g_read_cfig_options boolean;
g_auto_dang_flag boolean;
g_dang_table varchar2(400);
g_wh_dang_table varchar2(400);
g_wh_dang_table_cols varcharTableType;
g_number_wh_dang_table_cols number;
g_dang_table_count number;
g_new_dang_table varchar2(400);
g_new_dang_table_count number;
g_level_table varchar2(400);--holds the ltc name and ltc id
g_src_same_wh_flag boolean;
g_missing_key_view varchar2(400);
g_pk_view varchar2(400);
g_pk_view_cols varcharTableType;
g_number_pk_view_cols number;
g_profile_options varcharTableType;
g_number_profile_options number;
g_pk_porfile_number numberTableType;
g_pk_cols varcharTableType;--from the profile option
g_number_pk_cols number;
g_err_rec_flag boolean;
function get_dangling_keys(p_dim_name varchar2,p_db_link varchar2,
p_pk_view varchar2 default null,p_missing_key_view varchar2 default null) return boolean ;
function get_dangling_keys return boolean ;
function get_ll_keys_from_wh return boolean ;
function init_all return boolean ;
procedure write_to_log_file(p_message varchar2) ;
procedure write_to_log_file_n(p_message varchar2) ;
function get_time return varchar2;
function get_dim_id(p_object_name varchar2) return number;
function get_db_user(p_product varchar2) return varchar2;
function get_this_instance return varchar2 ;
function get_default_tablespace return varchar2 ;
function read_profile_options return boolean ;
function read_cfig_options return boolean ;
function get_src_option(p_option_code varchar2) return varchar2 ;
function drop_table (p_table_name varchar2,p_owner varchar2 default null) return boolean ;
function check_table(p_table varchar2, p_owner varchar2 default null) return boolean ;
function get_hl_keys_from_view return boolean ;
function get_db_columns_for_table(
    p_table varchar2,
    p_columns OUT NOCOPY varcharTableType,
    p_number_columns OUT NOCOPY number,
    p_owner varchar2 default null) return boolean;
procedure analyze_table_stats(p_table varchar2, p_owner varchar2) ;
function get_pk_structure return boolean ;
function value_in_table(
    p_table varcharTableType,
    l_number_table number,
    p_value varchar2) return boolean ;
function get_pk_for_level(p_level_prefix varchar2) return varchar2 ;
function does_table_have_data(p_table varchar2, p_where varchar2 default null) return number;
function create_missing_key_view return boolean ;
procedure truncate_dang_table;
END EDW_SRC_DANG_RECOVERY;

 

/
