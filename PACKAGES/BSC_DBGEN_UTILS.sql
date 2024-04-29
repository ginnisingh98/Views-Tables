--------------------------------------------------------
--  DDL for Package BSC_DBGEN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DBGEN_UTILS" AUTHID CURRENT_USER AS
/* $Header: BSCDBUTS.pls 120.6 2006/01/11 13:47 arsantha noship $ */
g_apps_schema VARCHAR2(100);
g_bsc_schema VARCHAR2(100);
g_ak_schema VARCHAR2(100);
FUNCTION get_bsc_schema return varchar2;
Function get_apps_schema  RETURN VARCHAR2;
FUNCTION get_measure_list(p_expression IN VARCHAR2) RETURN dbms_sql.varchar2_table ;
Function get_kpi_property_value(
    p_kpi IN NUMBER,
	p_property IN VARCHAR2,
	p_default IN NUMBER)
	return NUMBER;
Function Get_New_Big_In_Cond_Number( x_variable_id IN NUMBER, x_column_name IN VARCHAR2) return VARCHAR2;
PROCEDURE Add_Value_Big_In_Cond_Number(x_variable_id IN NUMBER, x_value IN NUMBER) ;
Function Get_New_Big_In_Cond_Varchar2( x_variable_id in number, x_column_name in varchar2) return VARCHAR2 ;
PROCEDURE Add_Value_Big_In_Cond_Varchar2(x_variable_id IN NUMBER, x_value IN VARCHAR2);
FUNCTION get_datatype(p_table_name in varchar2, p_column_name in varchar2) return VARCHAR2;
PROCEDURE add_property(p_properties in out NOCOPY BSC_DBGEN_STD_METADATA.tab_ClsProperties, p_name in varchar2, p_value in varchar2);
PROCEDURE add_property(p_properties in out NOCOPY BSC_DBGEN_STD_METADATA.tab_ClsProperties, p_name in varchar2, p_value in number);
FUNCTION get_property_value(p_properties IN BSC_DBGEN_STD_METADATA.tab_ClsProperties, p_name in varchar2) return VARCHAR2;
FUNCTION get_source_table_names(p_table_name IN VARCHAR2) RETURN DBMS_SQL.VARCHAR2_TABLE;

FUNCTION parse_value(p_string IN VARCHAR2, p_property_name IN VARCHAR2, p_assignment_operator IN VARCHAR2, p_pre_separator IN VARCHAR2, p_post_separator IN VARCHAR2) return varchar2;

--Return I, B, S, T, D or DI
FUNCTION get_table_type(p_table_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION get_mvlog_for_table(p_table_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION get_Objective_Type (p_Short_Name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION get_char_chunks(p_msg IN VARCHAR2, p_chunk_size IN NUMBER default 256) return DBMS_SQL.VARCHAR2_TABLE;
PROCEDURE init;
g_initialized boolean :=false;
Function get_objective_type_for_b_table(p_b_table_name IN VARCHAR2) return  VARCHAR2 ;
FUNCTION IS_TMP_TABLE_EXISTED(Table_Name IN VARCHAR2) RETURN BOOLEAN;

FUNCTION table_exists(p_table_name IN VARCHAR2) return BOOLEAN;
FUNCTION get_table_owner(p_table_name VARCHAR2) RETURN VARCHAR2;

PROCEDURE drop_table(p_table_name IN VARCHAR2);

PROCEDURE add_string(p_varchar2_table IN OUT nocopy DBMS_SQL.VARCHAR2A, p_string IN VARCHAR2);
PROCEDURE execute_immediate(p_varchar2_table IN DBMS_SQL.VARCHAR2A);
PROCEDURE execute_immediate(p_varchar2_table IN DBMS_SQL.VARCHAR2A, p_bind_vars_values dbms_sql.varchar2_table, p_num_bind_vars number);


END BSC_DBGEN_UTILS;

 

/
