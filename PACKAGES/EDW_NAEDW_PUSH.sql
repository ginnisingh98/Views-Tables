--------------------------------------------------------
--  DDL for Package EDW_NAEDW_PUSH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_NAEDW_PUSH" AUTHID CURRENT_USER AS
/*$Header: EDWNAEDS.pls 115.15 2002/11/23 00:09:31 vsurendr ship $*/

g_dim_name EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_dim_id EDW_OWB_COLLECTION_UTIL.numberTableType;
g_number_dims number;

g_levels  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_status  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_child_level_number  EDW_OWB_COLLECTION_UTIL.numberTableType;
g_child_levels  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_child_fk  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_parent_pk  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_levels integer;

g_level_fk EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_fk_datatype EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_pk EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_pk_datatype EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_varchar_pk_index number;
g_level_pk_number number;
g_level_fk_number number;
g_level_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_cols_length EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_cols_datatype EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_col_number number;

g_unassigned varchar2(3000);
g_unassigned_length number;
g_invalid varchar2(3000);
g_invalid_length number;

g_status boolean;
g_status_message varchar2(30000);

g_insert_stmt varchar2(30000);
g_update_stmt varchar2(30000);--if not insert then update
g_check_stmt varchar2(10000);
G_BODY_INSERT_UPDATE_STMT varchar2(30000);

g_err_insert_stmt varchar2(30000);
g_err_update_stmt varchar2(30000);--if not insert then update
g_err_check_stmt varchar2(10000);
G_err_BODY_INSERT_UPDATE_STMT varchar2(30000);


g_exec_flag boolean;
g_naedw_varchar2 varchar2(400);
g_err_varchar2 varchar2(400);
g_naedw_date varchar2(400);
g_naedw_number varchar2(400);
g_err_number varchar2(400);
G_ALL_VARCHAR2 varchar2(400);
G_ALL_VARCHAR2_MESG varchar2(3000);--fills the user cols of all level
g_all_varchar2_mesg_length number;
g_all_number varchar2(400);
g_all_date varchar2(400);
g_dim_string_flag boolean;
g_conc_program_id number;
g_conc_program_name varchar2(400);
g_all_dims_ok boolean;
g_naedw_in boolean;
g_err_in boolean;
g_dim_pk varchar2(400);
g_coll_engine_call boolean;
g_level_fk_parent EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_all_level varchar2(400);
PROCEDURE PUSH (Errbuf out NOCOPY varchar2,
		retcode out NOCOPY varchar2);
PROCEDURE PUSH(Errbuf out NOCOPY varchar2,
		retcode out NOCOPY varchar2,
                p_dim_string in varchar2);
/*
called from collection engine for a specific dimension
*/
PROCEDURE PUSH(Errbuf out NOCOPY varchar2,
		retcode out NOCOPY varchar2,
        p_dim_string in varchar2,
        p_debug boolean);
PROCEDURE Read_Metadata;

PROCEDURE Parse_Metadata(p_dim_index number);
PROCEDURE Make_insert_stmt(p_level_index number);
PROCEDURE Make_Update_Stmt(p_level_index number) ;
PROCEDURE Init_all;
function get_status_message return varchar2 ;
PROCEDURE Execute_insert_stmt_level(p_level_index number);
PROCEDURE Execute_insert_stmt;
PROCEDURE make_body_insert_update_stmt(p_level_index number, p_insert_flag boolean) ;
PROCEDURE parse_dim_names(p_dim_string varchar2) ;
procedure finish_all(p_flag boolean);
function get_time return varchar2 ;
procedure write_to_log_file(p_message varchar2) ;
procedure write_to_log_file_n(p_message varchar2) ;
function get_one_dim_name(p_dim_string varchar2,p_type varchar2) return boolean;
function naedw_in_star(p_dim varchar2) return boolean;
function get_dim_pk(p_dim varchar2) return boolean;
function err_in_star(p_dim varchar2) return boolean;
PROCEDURE Execute_err_insert_stmt_level(p_level_index number);
PROCEDURE make_err_body_insert_stmt(p_level_index number, p_insert_flag boolean);

END EDW_NAEDW_PUSH;

 

/
