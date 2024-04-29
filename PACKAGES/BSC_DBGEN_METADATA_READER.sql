--------------------------------------------------------
--  DDL for Package BSC_DBGEN_METADATA_READER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DBGEN_METADATA_READER" AUTHID CURRENT_USER AS
/* $Header: BSCMDRDS.pls 120.12 2006/01/12 13:56 arsantha noship $ */
PROCEDURE Initialize(p_metadata_source IN VARCHAR2) ;
FUNCTION Get_Facts_To_Process(p_process_id IN NUMBER) return BSC_DBGEN_STD_METADATA.tab_clsFact ;
FUNCTION Get_Measures_For_Fact(p_fact IN VARCHAR2, p_dim_set IN NUMBER, p_include_derived_columns IN BOOLEAN default false) return BSC_DBGEN_STD_METADATA.tab_clsMeasure;
FUNCTION Get_Periodicities_For_Fact(p_fact IN VARCHAR2) RETURN BSC_DBGEN_STD_METADATA.tab_ClsPeriodicity;
Function Get_Dimensions_For_Fact(p_fact IN VARCHAR2, p_dim_set IN NUMBER, p_include_missing_levels in boolean default false) RETURN BSC_DBGEN_STD_METADATA.tab_clsDimension;
gRecDims bsc_varchar2_table_type;
function get_parents_for_level(p_level_name varchar2, p_num_levels number default 1000000) RETURN BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship;
function get_children_for_level(p_level_name varchar2, p_num_levels number default 1000000) RETURN BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship;
function get_level_info(p_level varchar2) return BSC_DBGEN_STD_METADATA.clsLevel ;
function get_facts_for_levels(p_levels dbms_sql.varchar2_table) return BSC_DBGEN_STD_METADATA.tab_clsFact;
function is_dim_recursive(p_dim_level varchar2) return boolean ;
function get_fact_ids_for_calendar(p_calendar_id number) return dbms_sql.number_table;
function get_calendar_id_for_fact(p_fact varchar2) return number ;
function get_dim_sets_for_fact(p_fact varchar2) return dbms_sql.number_table;
function is_target_at_higher_level(p_fact varchar2, p_dim_set varchar2) return boolean;
function get_filter_for_dim_level(p_fact varchar2, p_level varchar2) return varchar2 ;
function get_s_views(p_fact IN VARCHAR2, p_dim_set IN NUMBER) return dbms_sql.varchar2_table;
function get_levels_for_table(p_table_name varchar2) return BSC_DBGEN_STD_METADATA.tab_clsLevel ;
function get_b_table_measures_for_fact(p_fact varchar2,p_dim_set varchar2,p_base_table varchar2, p_include_derived_columns boolean) return BSC_DBGEN_STD_METADATA.tab_clsMeasure ;
function get_periodicity_for_table(p_table varchar2) return NUMBER ;
function get_db_calendar_column(p_calendar_id number, p_periodicity_id number) return varchar2 ;
function get_base_tables_for_dim_set(p_fact in varchar2, p_dim_set in varchar2, p_targets in boolean) return dbms_sql.varchar2_table;
function get_current_period_for_fact(p_fact varchar2, p_periodicity number) return number ;
function get_current_year_for_fact(p_fact varchar2) return number ;
/*
returns all the kpi that have been implemented in AW
*/
function get_zero_code_levels(
p_fact varchar2,
p_dim_set varchar2) return BSC_DBGEN_STD_METADATA.tab_clsLevel;
function is_projection_enabled_for_kpi(p_kpi in varchar2) return varchar2;
function get_all_facts_in_aw return dbms_sql.varchar2_table;

function get_z_s_views(p_fact IN VARCHAR2, p_dim_set IN NUMBER) return dbms_sql.varchar2_table;
Function get_all_levels_for_fact(p_fact IN VARCHAR2) RETURN DBMS_SQL.VARCHAR2_TABLE ;

function get_dimension_level_short_name(p_dim_level_table_name IN VARCHAR2) return VARCHAR2;

function get_measures_for_short_names(p_short_names in dbms_sql.varchar2_table) return dbms_sql.varchar2_table;

function get_dim_levels_for_short_names(p_short_names in dbms_sql.varchar2_table) return dbms_sql.varchar2_table;

function get_fact_implementation_type(p_fact varchar2) return varchar2;


--- Added 08/08/2005 as this is reqd by Venu to track dim level changes
function is_level_used_by_aw_fact(p_level_name in varchar2) return boolean;
function get_parents_for_level_aw(p_level_name varchar2, p_num_levels number default 1000000) RETURN BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship;
function get_children_for_level_aw(p_level_name varchar2, p_num_levels number default 1000000) RETURN BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship;

procedure mark_facts_in_process(p_facts in dbms_sql.varchar2_table);
g_assume_production_facts dbms_sql.varchar2_table;

function get_target_per_for_b_table(p_fact in varchar2, p_dim_set in number, p_b_table in varchar2) return dbms_sql.varchar2_table;

function get_max_partitions return number;
function get_partition_clause return varchar2;

function get_table_properties(p_table_name in VARCHAR2, p_property_list in dbms_sql.VARCHAR2_table) return dbms_sql.VARCHAR2_table ;
function get_table_properties(p_table_name in VARCHAR2, p_property varchar2) return varchar2;


function get_partition_info(p_table_name in varchar2) return BSC_DBGEN_STD_METADATA.clsTablePartition;

TYPE rec_properties IS RECORD (
value varchar2(4000));
TYPE tab_properties is table of rec_properties index by varchar2(300);
g_initora_parameters tab_properties;
g_num_partitions number := -1;


function get_last_update_date_for_fact(p_fact in varchar2) return date;

g_bsc_schema varchar2(100);

function get_fact_cols_from_b_table(
p_fact in varchar2,
p_dim_set in number,
p_b_table_name in varchar2,
p_col_type in varchar2
) return BSC_DBGEN_STD_METADATA.tab_clsColumnMaps;

procedure set_table_property(p_table_name in varchar2, p_property_name in varchar2, p_property_value in varchar2);


FUNCTION get_denorm_dimension_table(p_dim_short_name VARCHAR2) return VARCHAR2 ;


--added Jan 12, 2006 for Venu
function get_current_period_for_table( p_table_name varchar2) return number ;
function get_current_year_for_table(p_table_name varchar2) return number ;

END BSC_DBGEN_METADATA_READER ;

 

/
