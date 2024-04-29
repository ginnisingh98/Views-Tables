--------------------------------------------------------
--  DDL for Package BSC_UPDATE_BASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_UPDATE_BASE" AUTHID CURRENT_USER AS
/* $Header: BSCDBASS.pls 120.0 2005/05/31 19:04:11 appldev noship $ */


/*===========================================================================+
|
|   Name:          Calc_New_Period_Base_Table
|
|   Description:   Calculate the update period of the base based on the update
|                  period and subperiod of the input table and the possible
|                  change of periodicity.
|
|   Parameters:	   x_base_table - base table name
|                  x_periodicity_base_table - periodicity of base table
|                  x_periodicity_input_table - periodicity of input table
|                  x_current_fy - current fiscal year
|                  x_per_input_table - update period of input table
|                  x_subper_input_table -update subperiod of input table
|                  x_current_per_base_table - current period of base table
|                  x_per_base_table - new update period of base table
|
|   Returns:       TRUE - Success.
|                  FALSE - Failure.
|
|   Notes:
|
+============================================================================*/
FUNCTION Calc_New_Period_Base_Table(
	x_base_table IN VARCHAR2,
        x_periodicity_base_table IN NUMBER,
        x_periodicity_input_table IN NUMBER,
        x_current_fy IN NUMBER,
        x_per_input_table IN NUMBER,
        x_subper_input_table IN NUMBER,
        x_current_per_base_table OUT NOCOPY NUMBER,
        x_per_base_table OUT NOCOPY NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Calc_New_Period_Input_Table
|
|   Description:   Calculate the update period and sub-period of the input
|                  table according to its current update period and
|                  sub-period and the maximum period of a real data reported
|                  in the table.
|
|   Parameters:	   x_input_table - input table name
|                  x_periodicity - periodicity of the input table
|                  x_period_col_name - period column name in the input table
|                  x_subperiod_col_name - subperiod column name
|                  x_current_fy - current fiscal year
|                  x_period - update period
|                  x_subperiod - update subperiod
|
|   Returns:       TRUE - Success.
|                  FALSE - Failure.
|
|   Notes:
|
+============================================================================*/
FUNCTION Calc_New_Period_Input_Table(
	x_input_table IN VARCHAR2,
 	x_periodicity IN NUMBER,
        x_period_col_name IN VARCHAR2,
        x_subperiod_col_name IN VARCHAR2,
        x_current_fy IN NUMBER,
	x_period OUT NOCOPY NUMBER,
	x_subperiod OUT NOCOPY NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Calculate_Base_Table
|
|   Description:   This function calculate the base table.
|                  - Update the data of the base table with the data of the
|                    input table.
|                  - Calculates the current period of the base table and
|                    the input table and stores them in the database
|                  - Deletes the data from the input table after updating
|                    the base table.
|
|   Parameters:	   x_base_table - base table name
|                  x_input_table - input table name
|
|   Returns:       TRUE - Success.
|                  FALSE - Failure.
|
|   Notes:
|
+============================================================================*/
FUNCTION Calculate_Base_Table(
	x_base_table IN VARCHAR2,
        x_input_table IN VARCHAR2,
        x_correction_flag IN BOOLEAN,
        x_aw_flag IN BOOLEAN
	) RETURN BOOLEAN;

--LOCKING: new function
FUNCTION Calculate_Base_Table_AT(
        x_base_table IN VARCHAR2,
        x_input_table IN VARCHAR2,
        x_correction_flag IN BOOLEAN,
        x_aw_flag IN BOOLEAN
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:   	   Create_Generic_Temp_Tables
|
|   Description:   Create generic temporal tables for base table calculation
|
|   Returns:
|
|   Notes:
|
+============================================================================*/
FUNCTION Create_Generic_Temp_Tables RETURN BOOLEAN;

--LOCKING: new function
FUNCTION Create_Generic_Temp_Tables_AT RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:   	   Update_Base_Table
|
|   Description:   Updates a basic system table from the data in a user
|		   input table.
|
|   Returns:
|
|   Notes:
|
+============================================================================*/
FUNCTION Update_Base_Table(
	x_base_tbl		VARCHAR2,
	x_in_tbl		VARCHAR2,
	x_key_columns 		BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_key_dim_tables	BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_key_columns 	NUMBER,
        x_data_columns 		BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_data_formulas		BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_data_measure_types    BSC_UPDATE_UTIL.t_array_of_number,
        x_num_data_columns 	NUMBER,
	x_base_percode		NUMBER,
	x_in_percode		NUMBER,
	x_in_per_fld		VARCHAR2,
	x_in_subper_fld		VARCHAR2,
	x_projection_flag	VARCHAR2,
        x_current_fy            NUMBER,
        x_current_per_base_table NUMBER,
        x_prev_current_period NUMBER, -- Fix bug#4235448: need this parameter
        x_correction_flag       BOOLEAN,
        x_aw_flag               BOOLEAN,
        x_change_vector_value   NUMBER
        ) RETURN BOOLEAN;


-- AW_INTEGRATION: New function
/*===========================================================================+
|
|   Name:   	   Get_Base_AW_Table_Name
|
|   Description:   Returns the name of the AW table created for the base table
|
+============================================================================*/
FUNCTION Get_Base_AW_Table_Name(
	x_base_tbl IN VARCHAR2
    ) RETURN VARCHAR2;


END BSC_UPDATE_BASE;

 

/
