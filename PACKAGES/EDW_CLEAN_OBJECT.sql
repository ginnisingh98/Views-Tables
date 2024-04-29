--------------------------------------------------------
--  DDL for Package EDW_CLEAN_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_CLEAN_OBJECT" AUTHID CURRENT_USER AS
/*$Header: EDWOCLNS.pls 115.5 2002/11/23 00:09:34 vsurendr noship $*/

g_object_name varchar2(400);
g_dim varchar2(400);
g_dim_ilog varchar2(400);
g_dim_owner varchar2(400);
g_bis_owner varchar2(400);
g_ltc_tables EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_lstg_tables EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_ltc_snplogs EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_ltc number;
g_op_tables EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_op_tables number;

g_status_message varchar2(4000);
g_status boolean;
g_truncate_stg varchar2(40);

g_fstg_table varchar2(400);
g_fact_snplog varchar2(400);
g_fact_dlog varchar2(400);
g_fact_ilog varchar2(400);
g_fact_ok_table varchar2(400);
g_base_fact_ilog EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_base_fact_dlog EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_ilog number;
g_derv_fact_ilog EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_derv_fact_dlog EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_derv_number_ilog number;


procedure clean_up_object(
Errbuf out NOCOPY varchar2,
Retcode out NOCOPY varchar2,
p_object_name in varchar2,
p_truncate_stg in varchar2);
procedure init_all;
function clean_up_dimension(p_dim varchar2) return boolean;
function clean_up_fact(p_fact varchar2) return boolean;
function read_metadata(p_dim varchar2) return boolean ;
procedure write_to_log_file(p_message varchar2);
function clean_dim_objects return boolean ;
function execute_stmt(p_stmt varchar2) return boolean;
function is_dimension(p_object_name varchar2) return boolean ;
function read_fact_metadata(p_fact varchar2) return boolean ;
function get_short_name_for_long(p_name varchar2) return varchar2 ;
END EDW_CLEAN_OBJECT;

 

/
