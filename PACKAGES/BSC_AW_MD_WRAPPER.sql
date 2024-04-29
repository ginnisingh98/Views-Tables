--------------------------------------------------------
--  DDL for Package BSC_AW_MD_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_AW_MD_WRAPPER" AUTHID CURRENT_USER AS
/*$Header: BSCAWMWS.pls 120.4 2006/01/14 21:02 vsurendr noship $*/
--program runtime parameters
g_debug boolean;
g_stmt varchar2(32000);
g_context varchar2(40);
--g_context varchar2(40):='AW'; --AW or MODEL etc. olap metadata may store many types of metadata
g_who number;
------types--------------------------------------------------------
type bsc_olap_object_tb is table of bsc_olap_object%rowtype index by pls_integer;
type bsc_olap_object_relation_tb is table of bsc_olap_object_relation%rowtype index by pls_integer;
--
--use property9 column of bsc olap metadata to hold runtime values like when load started, ended, lock etc
type bsc_runtime_r is record(
object bsc_olap_object.object%type,
object_type bsc_olap_object.object_type%type,
parent_object bsc_olap_object.parent_object%type,
parent_object_type bsc_olap_object.parent_object_type%type,
operation varchar2(300), --load,aggregation,lock
operation_type varchar2(100),--initial, inc
start_time varchar2(100), --MM/DD/YYYY HH24:MI:SS
end_time varchar2(100),
sid number,
spid number,
property varchar2(8000)
);
type bsc_runtime_tb is table of bsc_runtime_r index by pls_integer;
--procedures-------------------------------------------------------
procedure set_context(p_context varchar2);
procedure mark_kpi_recreate(
p_kpi varchar2
);
procedure drop_dim(p_dim_name varchar2);
procedure create_dim(p_dimension bsc_aw_adapter_dim.dimension_r);
procedure drop_kpi(p_kpi varchar2);
procedure create_calendar(p_calendar bsc_aw_calendar.calendar_r);
procedure get_bsc_olap_object(
p_object varchar2,
p_type varchar2,
p_parent_object varchar2,
p_parent_type varchar2,
p_bsc_olap_object out nocopy bsc_olap_object_tb
);
procedure get_bsc_olap_object_relation(
p_object varchar2,
p_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_bsc_olap_object_relation out nocopy bsc_olap_object_relation_tb
);
procedure create_kpi(p_kpi bsc_aw_adapter_kpi.kpi_r) ;
procedure create_kpi(p_kpi varchar2,p_dim_set bsc_aw_adapter_kpi.dim_set_r);
procedure insert_olap_object(
p_object varchar2,
p_object_type varchar2,
p_olap_object varchar2,
p_olap_object_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_property1 varchar2
);
procedure insert_olap_object_relation(
p_object varchar2,
p_object_type varchar2,
p_relation_object varchar2,
p_relation_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_property1 varchar2
);
procedure update_olap_object_relation(
p_object varchar2,
p_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_match_columns dbms_sql.varchar2_table,
p_match_values dbms_sql.varchar2_table,
p_set_columns dbms_sql.varchar2_table,
p_set_values dbms_sql.varchar2_table
);
procedure update_olap_object(
p_object varchar2,
p_object_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_match_columns dbms_sql.varchar2_table,
p_match_values dbms_sql.varchar2_table,
p_set_columns dbms_sql.varchar2_table,
p_set_values dbms_sql.varchar2_table
);
procedure create_workspace(p_name varchar2);
procedure drop_workspace(p_name varchar2) ;
procedure default_context_if_null;
procedure delete_olap_object_relation(
p_object varchar2,
p_object_type varchar2,
p_relation_type varchar2,
p_relation_object varchar2,
p_relation_object_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2);
procedure delete_olap_object(
p_object varchar2,
p_object_type varchar2,
p_olap_object varchar2,
p_olap_object_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2);
procedure merge_olap_object(
p_object varchar2,
p_object_type varchar2,
p_olap_object varchar2,
p_olap_object_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_property1 varchar2
);
procedure merge_olap_object_relation(
p_object varchar2,
p_object_type varchar2,
p_relation_object varchar2,
p_relation_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_property1 varchar2
);
procedure analyze_md_tables;
--procedures-------------------------------------------------------
procedure init_all;
procedure log(p_message varchar2);
procedure log_n(p_message varchar2);
-------------------------------------------------------------------

END BSC_AW_MD_WRAPPER;

 

/
