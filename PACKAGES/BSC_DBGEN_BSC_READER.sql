--------------------------------------------------------
--  DDL for Package BSC_DBGEN_BSC_READER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DBGEN_BSC_READER" AUTHID CURRENT_USER AS
/* $Header: BSCBSRDS.pls 120.7 2006/01/12 13:56 arsantha noship $ */
Function is_parent_1N(p_child_level IN VARCHAR2, p_parent_level IN VARCHAR2 ) RETURN boolean ;
Function is_parent_MN(p_child_level IN VARCHAR2, p_parent_level IN VARCHAR2 ) RETURN boolean ;

FUNCTION Get_Facts_To_Process(p_process_id IN NUMBER) return BSC_DBGEN_STD_METADATA.tab_clsFact;
FUNCTION Get_Measures_For_Fact(p_fact IN VARCHAR2, p_dim_set IN NUMBER, p_include_derived_columns IN BOOLEAN default false) return BSC_DBGEN_STD_METADATA.tab_clsMeasure;
FUNCTION Get_Periodicities_For_Fact(p_fact IN VARCHAR2) RETURN BSC_DBGEN_STD_METADATA.tab_ClsPeriodicity ;
Function get_dimensions_for_fact(p_fact IN VARCHAR2, p_dim_set IN NUMBER, p_include_missing_levels IN boolean) RETURN BSC_DBGEN_STD_METADATA.tab_clsDimension;


function get_children_for_level(p_level_name varchar2, p_num_levels number default 1000000) RETURN BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship;
function get_parents_for_level(p_level_name varchar2, p_num_levels number default 1000000) RETURN BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship;
function get_level_info(p_level varchar2) return BSC_DBGEN_STD_METADATA.clsLevel;
Function get_dim_sets_for_fact(p_fact VARCHAR2) return DBMS_SQL.NUMBER_TABLE;

function get_s_views(p_fact IN VARCHAR2,p_dim_set IN NUMBER)return dbms_sql.varchar2_table;
function get_levels_for_table(p_table_name varchar2,p_table_type VARCHAR2) return BSC_DBGEN_STD_METADATA.tab_clsLevel ;

function get_b_table_measures_for_fact(p_fact varchar2,p_dim_set varchar2,p_base_table varchar2, p_include_derived_columns boolean) return BSC_DBGEN_STD_METADATA.tab_clsMeasure ;

function get_periodicity_for_table(p_table varchar2) return NUMBER ;
function get_db_calendar_column(p_calendar_id number,p_periodicity_id number) return varchar2;

function get_zero_code_levels(p_fact varchar2, p_dim_set varchar2) return BSC_DBGEN_STD_METADATA.tab_clsLevel;

function get_base_tables_for_dim_set(p_fact varchar2,p_dim_set in number,p_targets in boolean) return dbms_sql.varchar2_table;
function get_facts_for_levels(p_levels dbms_sql.varchar2_table) return BSC_DBGEN_STD_METADATA.tab_clsFact;
function get_filter_for_dim_level(p_fact varchar2, p_level varchar2) return varchar2 ;
function get_current_period_for_fact(p_fact varchar2, p_periodicity number) return number ;
function get_current_year_for_fact(p_fact varchar2) return number ;

function is_projection_enabled_for_kpi(p_kpi in varchar2) return varchar2;
function get_all_facts_in_aw return  dbms_sql.varchar2_table;
function get_z_s_views(p_fact IN VARCHAR2, p_dim_set IN NUMBER) return dbms_sql.varchar2_table;
Function get_all_levels_for_fact(p_fact IN VARCHAR2) RETURN DBMS_SQL.VARCHAR2_TABLE ;
function get_dimension_level_short_name(p_dim_level_table_name IN VARCHAR2) return VARCHAR2;

function get_measures_for_short_names(p_short_names in dbms_sql.varchar2_table) return dbms_sql.varchar2_table;

function get_dim_levels_for_short_names(p_short_names in dbms_sql.varchar2_table) return dbms_sql.varchar2_table;

function get_fact_implementation_type(p_fact in varchar2) return varchar2;

--- Added 08/08/2005 as this is reqd by Venu to track dim level changes
function is_level_used_by_aw_fact(p_level_name in varchar2) return boolean;
function get_parents_for_level_aw(p_level_name varchar2, p_num_levels number default 1000000) RETURN BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship;
function get_children_for_level_aw(p_level_name varchar2, p_num_levels number default 1000000) RETURN BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship;


function get_target_per_for_b_table(p_fact in varchar2, p_dim_set in number, p_b_table in varchar2) return dbms_sql.varchar2_table;


function get_last_update_date_for_fact(p_fact in varchar2) return date;

function get_fact_cols_from_b_table(
p_fact in varchar2,
p_dim_set in number,
p_b_table_name in varchar2,
p_col_type in varchar2
) return BSC_DBGEN_STD_METADATA.tab_clsColumnMaps;

procedure set_table_property(p_table_name in varchar2, p_property_name in varchar2, p_property_value in varchar2);

g_initialized boolean :=false;




--added Jan 12, 2006 for Venu
function get_current_period_for_table( p_table_name varchar2) return number ;
function get_current_year_for_table(p_table_name varchar2) return number ;

END BSC_DBGEN_BSC_READER ;

 

/
