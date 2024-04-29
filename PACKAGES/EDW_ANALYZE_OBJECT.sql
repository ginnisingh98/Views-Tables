--------------------------------------------------------
--  DDL for Package EDW_ANALYZE_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_ANALYZE_OBJECT" AUTHID CURRENT_USER AS
/*$Header: EDWANYZS.pls 115.5 2002/11/23 00:08:56 vsurendr noship $*/
g_dim EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_dim_long EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_dim number;
g_fact EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_fact_long EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_fact number;
g_parallel number;
g_status boolean;
g_status_message varchar2(4000);
g_mode number;
procedure Analyze_Dimension(Errbuf out NOCOPY varchar2,Retcode out NOCOPY varchar2,
p_dim_name in varchar2,p_mode number);
procedure Analyze_Fact(Errbuf out NOCOPY varchar2,Retcode out NOCOPY varchar2,
p_fact_name in varchar2,p_mode number);
function analyze_dimension(p_dim_name varchar2) return boolean;
function get_dims(p_dim_name varchar2) return boolean;
function analyze_dims return boolean;
function analyze_fact(p_fact_name varchar2) return boolean;
function get_facts(p_fact_name varchar2) return boolean;
function analyze_facts return boolean;
procedure analyze_table(p_object varchar2);
procedure init_all;
function get_time return varchar2;
procedure write_to_log_file(p_message varchar2);
procedure write_to_log_file_n(p_message varchar2);
procedure write_to_out_file(p_message varchar2);
procedure write_to_out_file_n(p_message varchar2);
function analyze_dims_lstg return boolean ;
function analyze_facts_fstg return boolean ;
END EDW_ANALYZE_OBJECT;

 

/
