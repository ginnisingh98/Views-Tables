--------------------------------------------------------
--  DDL for Package BSC_UPDATE_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_UPDATE_CALC" AUTHID CURRENT_USER AS
/* $Header: BSCDCALS.pls 120.0 2005/05/31 19:03:16 appldev noship $ */
--
-- Global Constants
--

--
-- Procedures and Fuctions
--


/*===========================================================================+
|
|   Name:          Apply_Filters
|
|   Description:   This function applies filters on the given table if the
|                  table belong to any indicator that has filter.
|
|   Parameters:	   x_table_name - table name,
|
|   Returns:	   TRUE - Success
|		   FALSE - There was some error executing the function
|
|   Notes:
|
+============================================================================*/
FUNCTION Apply_Filters(
	x_table_name IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Calculate_Profit
|
|   Description:   This function calculate the profit on the given table.
|                  We suppose that the table has an account dimension.
|
|   Parameters:	   x_table_name - table name,
|		   x_key_columns - array with table key columns
|                  x_num_key_columns - number of key columns of the table
|                  x_data_columns - array of data columns
|                  x_num_data_columns - number of data columns
|
|   Returns:	   TRUE - Success
|		   FALSE - There was some error executing the function
|
|   Notes:
|
+============================================================================*/
FUNCTION Calculate_Profit(
	x_table_name IN VARCHAR2,
	x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_key_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_key_columns IN NUMBER,
        x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_data_columns IN NUMBER,
        x_aw_flag IN BOOLEAN,
        x_change_vector_value IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Calculate_Proj_Avg_Last_Year
|
|   Description:   This function calculate the projection of a data column
|                  of the table with the method: average last year
|
|   Returns:	   TRUE - Success
|		   FALSE - There was some error executing the function
|
|   Notes:
|
+============================================================================*/
FUNCTION Calculate_Proj_Avg_Last_Year(
	x_table_name IN VARCHAR2,
	x_periodicity IN NUMBER,
        x_period IN NUMBER,
	x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_key_columns IN NUMBER,
	x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_data_columns IN NUMBER,
        x_lst_data_temp IN VARCHAR2, -- list of data columns in the projection table i.e: 'DATA1, DATA5'
	x_current_fy IN NUMBER,
	x_num_of_years IN NUMBER,
	x_previous_years IN NUMBER,
     	x_is_base IN BOOLEAN,
        x_aw_flag IN BOOLEAN
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Calculate_Proj_3_Periods_Perf
|
|   Description:   This function calculate the projection of a data column
|                  of the table with the method: 3 periods performance
|
|   Parameters:	   x_table_name - table name.
|                  x_periodicity - periodicity code
|                  x_period - period of the table
|                  x_key_columns - array with table key columns
|                  x_num_key_columns - number of key columns of the table
|                  x_data_column - data column
|                  x_current_fy - current fiscal year
|
|   Returns:	   TRUE - Success
|		   FALSE - There was some error executing the function
|
|   Notes:
|
+============================================================================*/
FUNCTION Calculate_Proj_3_Periods_Perf(
	x_table_name IN VARCHAR2,
	x_periodicity IN NUMBER,
        x_period IN NUMBER,
	x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_key_columns IN NUMBER,
	x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_data_columns IN NUMBER,
        x_lst_data_temp IN VARCHAR2, -- list of data columns in the projection table i.e: 'DATA1, DATA5'
        x_current_fy IN NUMBER,
        x_is_base IN BOOLEAN,
        x_aw_flag IN BOOLEAN
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Calculate_Proj_User_Defined
|
|   Description:   This function calculate the projection of a data column
|                  of the table with the method: user provide projection data
|
|   Parameters:	   x_table_name - table name.
|                  x_periodicity - periodicity code
|                  x_period - period of the table
|                  x_key_columns - array with table key columns
|                  x_num_key_columns - number of key columns of the table
|                  x_data_column - data column
|                  x_current_fy - current fiscal year
|
|   Returns:	   TRUE - Success
|		   FALSE - There was some error executing the function
|
|   Notes:
|
+============================================================================*/
FUNCTION Calculate_Proj_User_Defined(
	x_table_name IN VARCHAR2,
	x_periodicity IN NUMBER,
        x_period IN NUMBER,
	x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_key_columns IN NUMBER,
	x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_data_columns IN NUMBER,
        x_lst_data_temp IN VARCHAR2, -- list of data columns in the projection table i.e: 'DATA1, DATA5'
        x_current_fy IN NUMBER,
     	x_is_base IN BOOLEAN,
        x_aw_flag IN BOOLEAN
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Calculate_Projection
|
|   Description:   This function calculate the projection on the table
|
|   Parameters:	   x_table_name - table name.
|                  x_periodicity - periodicity code
|                  x_period - period of the table
|                  x_key_columns - array with table key columns
|                  x_num_key_columns - number of key columns of the table
|                  x_data_columns - array with table data columns
|                  x_data_proj_methods -array with data projection methods
|                  x_num_data_columns - number of data columns of the table
|                  x_num_of_years - number of years used by the table
|                  x_previous_years - number of previous years
|                  x_is_base - true - base table, false - summary table
|
|   Returns:	   TRUE - Success
|		   FALSE - There was some error executing the function
|
|   Notes:
|
+============================================================================*/
FUNCTION Calculate_Projection(
	x_table_name IN VARCHAR2,
	x_periodicity IN NUMBER,
        x_period IN NUMBER,
	x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_key_columns IN NUMBER,
	x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_data_proj_methods IN BSC_UPDATE_UTIL.t_array_of_number,
	x_num_data_columns IN NUMBER,
	x_current_fy IN NUMBER,
	x_num_of_years IN NUMBER,
	x_previous_years IN NUMBER,
	x_is_base IN BOOLEAN,
        x_aw_flag IN BOOLEAN,
        x_change_vector_value IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Calculate_Zero_Code
|
|   Description:   This function calculate the zero code in the table.
|
|   Parameters:	   x_table_name - table name.
|                  x_zero_code_calc_method - zero code calculation method
|                  x_src_table If this parameter is different from null
|                              it does not calculate zero code in keys where
|                              the source table already has zero code.
|
|   Returns:	   TRUE - Success
|		   FALSE - There was some error executing the function
|
|   Notes:
|
+============================================================================*/
FUNCTION Calculate_Zero_Code(
	x_table_name IN VARCHAR2,
        x_zero_code_calc_method IN NUMBER,
        x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_key_columns IN NUMBER,
        x_src_table IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Create_Proj_Temps
|
|   Description:   This function creates temporary tables for projection.
|
|   Parameters:	   x_periodicity - periodicity code
|                  x_num_of_years - number of years used by the table
|                  x_previous_years - number of previous years
|
|   Returns:	   TRUE - Success
|		   FALSE - There was some error executing the function
|
|   Notes:
|
+============================================================================*/
FUNCTION Create_Proj_Temps(
        x_periodicity IN NUMBER,
        x_current_fy IN NUMBER,
        x_num_of_years IN NUMBER,
        x_previous_years IN NUMBER,
        x_trunc_proj_table IN BOOLEAN
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Init_Projection_Table
|
|   Description:   This function initialize the projection table BSC_TMP_PROJ_CALC
|                  with the projection rows
|
|   Parameters:	   x_table_name - table name.
|                  x_periodicity - periodicity code
|                  x_key_columns - array with table key columns
|                  x_num_key_columns - number of key columns of the table
|                  x_current_fy - current fiscal year
|                  x_is_base - true - base table, false - summary table
|
|   Returns:	   TRUE - Success
|		   FALSE - There was some error executing the function
|
|   Notes:
|
+============================================================================*/
FUNCTION Init_Projection_Table(
	x_table_name IN VARCHAR2,
	x_periodicity IN NUMBER,
	x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_key_columns IN NUMBER,
        x_current_fy IN NUMBER,
        x_current_period IN NUMBER,
        x_is_base IN BOOLEAN,
        x_aw_flag IN BOOLEAN,
        x_change_vector_value IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Delete_Projection
|
|   Description:   This function delete the projection of a table
|
|   Parameters:	   x_table_name - table name.
|                  x_periodicity - periodicity code
|                  x_period - current period
|                  x_data_columns - array with table data columns
|                  x_data_proj_methods - array with the data projection methods
|                  x_num_data_columns - number of data columns of the table
|                  x_current_fy - current fiscal year
|
|   Returns:	   TRUE - Success
|		   FALSE - There was some error executing the function
|
|   Notes:
|
+============================================================================*/
FUNCTION Delete_Projection(
	x_table_name IN VARCHAR2,
	x_periodicity IN NUMBER,
	x_period IN NUMBER,
	x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_data_proj_methods IN BSC_UPDATE_UTIL.t_array_of_number,
	x_num_data_columns IN NUMBER,
        x_current_fy IN NUMBER,
        x_is_base IN BOOLEAN
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Delete_Projection_Base_Table
|
|   Description:   This function delete the projection of a base table.
|                  It update the data with NULL for periods > x_current_period
|                  and <=x_new_current_period
|
|   Returns:	   TRUE - Success
|		   FALSE - There was some error executing the function
|
|   Notes:
|
+============================================================================*/
FUNCTION Delete_Projection_Base_Table(
	x_table_name IN VARCHAR2,
	x_periodicity IN NUMBER,
	x_current_period IN NUMBER,
        x_new_current_period IN NUMBER,
	x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_data_proj_methods IN BSC_UPDATE_UTIL.t_array_of_number,
	x_num_data_columns IN NUMBER,
        x_current_fy IN NUMBER,
        x_aw_flag IN BOOLEAN,
        x_change_vector_value IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Drop_Proj_Temps
|
|   Description:   This function drop temporary tables for projection.
|
|   Parameters:
|
|   Returns:	   TRUE - Success
|		   FALSE - There was some error executing the function
|
|   Notes:
|
+============================================================================*/
FUNCTION Drop_Proj_Temps RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Zero_Code_Calc_Method
|
|   Description:   This function returns the code zero method of the table.
|                  A table only has one zero code calculation method.
|
|   Parameters:	   x_table_name - table name
|
|   Returns:	   NULL - There was some error executing the function.
|                  # - Code zero method (3 or 4). If the table doesn't
|                      calculate zero code then returns 0.
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Zero_Code_Calc_Method(
	x_table_name IN VARCHAR2
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Merge_Data_From_Tables
|
|   Description:   Merge data from another tables in the given table.
|                  Rules:
|                  -- Target table can have multiple source tables and are
|                     in BSC_DB_CALCULATIONS as CALCULATION_TYPE = 5.
|                  -- Source tables must have same dimensions and periodicity
|                     as the target table.
|                  -- The data column are specify by source table in
|                     BSC_DB_CALCULATIONS (PARAMETER2). The specified data
|                     columns must exist in both the source and target table.
|
|   Parameters:	   x_table_name - table name
|                  x_key_columns -  array with table key columns
|                  x_num_key_columns - number of key columns of the table
|
|   Returns:	   TRUE - Success
|		   FALSE - There was some error executing the function
|
|   Notes:
|
+============================================================================*/
FUNCTION Merge_Data_From_Tables(
	x_table_name IN VARCHAR2,
        x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_key_columns IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
| FUNCTION Merge_Projection						     |
+============================================================================*/
FUNCTION Merge_Projection(
    x_table_name VARCHAR2,
    x_key_columns BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_key_columns NUMBER,
    x_data_columns BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_data_columns NUMBER,
    x_is_base BOOLEAN,
    x_aw_flag BOOLEAN
) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Refresh_EDW_Views
|
|   Description:   This function refresh the materialized view associated to
|                  the given BSC table. Also deletes rows from the bsc table
|                  which exist in the materialized view. Finally recreate
|                  the union view (bsc table + materialized view).
|                  Returns in x_current_period the maximun period reported in
|                  the materialized view.
|
|   Returns        TRUE - Success
|		   FALSE - There was some error executing the function
|
|   Notes:
|
+============================================================================*/
FUNCTION Refresh_EDW_Views(
	x_table_name IN VARCHAR2,
	x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2 ,
        x_num_key_columns IN NUMBER ,
        x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_data_columns IN NUMBER,
	x_current_fy IN NUMBER,
	x_periodicity IN NUMBER,
        x_current_period OUT NOCOPY NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Rollup_Projection
|
|   Description:   This function calculate the projection for a higher
|                  periodicity based on the projection already calculated
|                  for the base periodicity.
|
|   Notes:
|
+============================================================================*/
FUNCTION Rollup_Projection(
	x_periodicity IN NUMBER,
        x_period IN NUMBER,
        x_base_periodicity IN NUMBER,
        x_base_period IN NUMBER,
	x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_key_columns IN NUMBER,
	x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_data_formulas IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_data_measure_types IN BSC_UPDATE_UTIL.t_array_of_number,
	x_num_data_columns IN NUMBER,
	x_current_fy IN NUMBER,
        x_is_base IN BOOLEAN
        ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Table_Has_Profit_Calc
|
|   Description:   This function say if the table has prifit calculation.
|
|   Parameters:	   x_table_name - Table name.
|
|   Returns:	   TRUE - Table has profit calculation
|		   FALSE - Table doesn't have profit calculation
|                  NULL - There was some error executing the function
|
|   Notes:
|
+============================================================================*/
FUNCTION Table_Has_Profit_Calc(
	x_table_name IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Table_Has_Proj_Calc
|
|   Description:   This function say if the table has projection calculation.
|
|   Parameters:	   x_table_name - Table name.
|
|   Returns:	   TRUE - Table has projection calculation
|		   FALSE - Table doesn't have projection calculation
|                  NULL - There was some error executing the function
|
|   Notes:
|
+============================================================================*/
FUNCTION Table_Has_Proj_Calc(
	x_table_name IN VARCHAR2
	) RETURN BOOLEAN;


END BSC_UPDATE_CALC;

 

/
