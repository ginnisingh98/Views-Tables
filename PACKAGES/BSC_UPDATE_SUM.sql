--------------------------------------------------------
--  DDL for Package BSC_UPDATE_SUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_UPDATE_SUM" AUTHID CURRENT_USER AS
/* $Header: BSCDSUMS.pls 120.0 2005/06/01 17:07:41 appldev noship $ */

-- BSC-MV Note: Global variable to store the name of MV that has been refreshed.
g_refreshed_mvs BSC_UPDATE_UTIL.t_array_of_varchar2;
g_num_refreshed_mvs NUMBER := 0;


/*===========================================================================+
|
|   Name:          Calculate_Period_Summary_Table
|
|   Description:   This function calculates the period of a summary table
|                  based on the possible change of periodicity and origin
|                  period.
|
|   Parameters:	   x_periodicity - periodicity of summary table
|                  x_origin_periodicity - periodicity of origin tables
|                  x_origin_period - minimum period of origin tables
|                  x_current_fy - current fiscal year
|
|   Returns:       NULL - Failure.
|
|   Notes:
|
+============================================================================*/
FUNCTION Calculate_Period_Summary_Table(
	x_periodicity IN NUMBER,
        x_origin_periodicity IN NUMBER,
        x_origin_period IN NUMBER,
        x_current_fy IN NUMBER
        ) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Calculate_Sum_Table
|
|   Description:   This function calculates the summary table and its current
|                  period which is stored in the database.
|
|   Parameters:	   x_sum_table - summary table name
|
|   Returns:       TRUE - Success.
|                  FALSE - Failure.
|
|   Notes:
|
+============================================================================*/
FUNCTION Calculate_Sum_Table(
	x_sum_table IN VARCHAR2
	) RETURN BOOLEAN;

--LOCKING: new function
FUNCTION Calculate_Sum_Table_AT(
	x_sum_table IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Calculate_Sum_Table_MV
|
|   Description:   This function calculates the summary table (in BSC-MV
|                  Architecture) and its current
|                  period which is stored in the database.
|
|   Returns:       TRUE - Success.
|                  FALSE - Failure.
|
|   Notes:
|
+============================================================================*/
FUNCTION Calculate_Sum_Table_MV(
	x_sum_table IN VARCHAR2,
	x_calculated_sys_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_calculated_sys_tables IN NUMBER,
	x_system_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_system_tables IN NUMBER
	) RETURN BOOLEAN;

--LOCKING: new function
FUNCTION Calculate_Sum_Table_MV_AT(
	x_sum_table IN VARCHAR2,
	x_calculated_sys_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_calculated_sys_tables IN NUMBER,
	x_system_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_system_tables IN NUMBER
	) RETURN BOOLEAN;


-- AW_INTEGRATION: new fucntion
/*===========================================================================+
|
|   Name:          Calculate_Sum_Table_AW
|
|   Description:   This function calculates the summary table for the give
|                  table that belongs to a AW indicator
|                  It only needs to calculate the current period of the table
|
|   Returns:       TRUE - Success.
|                  FALSE - Failure.
|
|   Notes:
|
+============================================================================*/
FUNCTION Calculate_Sum_Table_AW(
	x_sum_table IN VARCHAR2
	) RETURN BOOLEAN;

--LOCKING: new function
FUNCTION Calculate_Sum_Table_AW_AT(
	x_sum_table IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Calculate_Sum_Table_Total
|
|   Description:   This function calculates the summary table (support total
|                  and balance fields).
|
|   Parameters:	   x_sum_table - summary table name
|                  x_key_columns - array that contains the key columns of
|                                  summary table
|                  x_key_dim_tables - array that contains the dimension tables
|                                     associated to the keys
|                  x_source_columns - array that contains the source columns
|                                   - of each key column of summary table
|                  x_source_dim_tables - array that contains the dimension tables
|                                     associated to the source keys
|                  x_num_key_columns - number of key columns of summary table
|                  x_data_columns - array that contains the data columns of
|                                   summary table
|                  x_data_formulas - array that contains the data formulas of
|                                    summary table
|                  x_data_measure_types - array that constains the type of each
|                                         data column (1:Total, 2:Balance)
|                  x_num_data_columns - number of data columns of summary table
|                  x_origin_tables - array that contains the name of origin tables
|                  x_num_origin_tables - number of origin tables
|                  x_key_columns_ori - key columns of origin tables
|                  x_num_key_columns_ori - number of key columns of origin tables
|                  x_periodicity - periodicity of summary table
|                  x_origin_periodicity - periodicity of origin tables
|                  x_period - new period of the summary table Fix bug#4177794
|                  x_origin_period - minimum period of origin tables
|                  x_current_fy - current fiscal year
|
|   Returns:       TRUE - Success.
|                  FALSE - Failure.
|
|   Notes:
|
+============================================================================*/
FUNCTION Calculate_Sum_Table_Total(
        x_sum_table IN VARCHAR2,
        x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_key_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_source_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_source_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_key_columns IN NUMBER,
        x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_data_formulas IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_data_measure_types IN BSC_UPDATE_UTIL.t_array_of_number,
        x_num_data_columns IN NUMBER,
        x_origin_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_origin_tables IN NUMBER,
        x_key_columns_ori IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_key_columns_ori IN NUMBER,
        x_periodicity IN NUMBER,
        x_origin_periodicity IN NUMBER,
        x_period IN NUMBER,
        x_origin_period IN NUMBER,
        x_current_fy IN NUMBER
        ) RETURN BOOLEAN;



/*===========================================================================+
|
|   Name:          Get_Minimun_Origin_Period
|
|   Description:   This function returns the minimun period between the current
|                  period of the origin tables given in the array x_origin_tables
|
|   Parameters:	   x_table_name - table name
|                  x_origin_tables - array of origin tables
|                  x_num_origin_tables - number of origin tables
|
|   Returns:       NULL - Failure.
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Minimun_Origin_Period(
	x_origin_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_origin_tables IN NUMBER
        ) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Origin_Tables
|
|   Description:   This function returns in the array x_origin_tables the
|                  tables from where the given table is originated. Look
|                  bsc_db_tables_rels
|
|   Parameters:	   x_table_name - table name
|                  x_origin_tables - array of origin tables
|                  x_num_origin_tables - number of origin tables
|
|   Returns:       TRUE - Success.
|                  FALSE - Failure.
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Origin_Tables(
	x_table_name IN VARCHAR2,
	x_origin_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_origin_tables IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN;


--LOCKING: new procedure
PROCEDURE Refresh_AW_Kpi_AT (
    x_indicator IN NUMBER
);


/*===========================================================================+
|
|   Name:          Refresh_Zero_MVs
|
|   Description:   This function refreshes all the MVs created
|                  for zero codes for the given MV
|
|   Returns:       TRUE - Success.
|                  FALSE - Failure.
|
|   Notes:
|
+============================================================================*/
FUNCTION Refresh_Zero_MVs(
	x_table_name IN VARCHAR2,
	x_mv_name IN VARCHAR2,
        x_error_message IN OUT NOCOPY VARCHAR2
	) RETURN BOOLEAN;

--LOCKING: new function
FUNCTION Refresh_Zero_MVs_AT(
	x_table_name IN VARCHAR2,
	x_mv_name IN VARCHAR2,
        x_error_message IN OUT NOCOPY VARCHAR2
	) RETURN BOOLEAN;


END BSC_UPDATE_SUM;

 

/
