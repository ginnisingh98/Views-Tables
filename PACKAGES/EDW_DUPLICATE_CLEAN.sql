--------------------------------------------------------
--  DDL for Package EDW_DUPLICATE_CLEAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_DUPLICATE_CLEAN" AUTHID CURRENT_USER AS
/*$Header: EDWDCLNS.pls 115.7 2003/11/05 22:17:29 vsurendr noship $*/
g_dim_name varchar2(400);
g_dim_pk varchar2(400);
g_dim_pk_key varchar2(400);
g_ltc_tables EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_ltc_pk EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_ltc_pk_key EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_ltc number;
g_bis_owner varchar2(100);
g_parallel number;
g_fact_name varchar2(400);
g_fact_pk varchar2(400);
g_fact_pk_key varchar2(400);

g_status_message varchar2(2000);
g_status boolean;
g_op_table_space varchar2(400);

function clean_dimension_duplicates(p_dim_name varchar2) return boolean;
function clean_fact_duplicates(p_fact_name varchar2) return boolean;
function clean_dimension_duplicates return boolean ;
function clean_fact_duplicates return boolean ;
function get_dimension_pks return boolean ;
function get_fact_pks return boolean ;
function get_ltc_tables return boolean ;
function get_ltc_pks  return boolean ;
function get_table_pks(p_table varchar2,p_pk out NOCOPY varchar2,p_pk_key out NOCOPY varchar2,
p_option varchar2) return boolean ;
function delete_dim_duplicates return boolean ;
function delete_fact_duplicates return boolean ;
function delete_table_duplicates(p_table varchar2,p_pk varchar2,p_pk_key varchar2) return boolean ;
procedure init_all ;
procedure write_to_log_file(p_message varchar2) ;
procedure write_to_log_file_n(p_message varchar2) ;
function get_time return varchar2 ;
function get_short_name_for_long(p_name varchar2) return varchar2;
procedure clean_up_object(Errbuf out NOCOPY varchar2,Retcode out NOCOPY varchar2,p_object_name in varchar2);
function is_dimension(p_object_name varchar2) return boolean ;
function get_fact_fk_for_dim(
p_dim_name varchar2,
p_fact out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_fact_fk out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_fact_fk out nocopy number
)return boolean;
function delete_dim_duplicate_data(
p_dim_name varchar2,
p_dim_pk varchar2,
p_dim_pk_key varchar2
)return boolean;
END EDW_DUPLICATE_CLEAN;

 

/
