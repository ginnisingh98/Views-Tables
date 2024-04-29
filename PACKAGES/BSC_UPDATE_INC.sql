--------------------------------------------------------
--  DDL for Package BSC_UPDATE_INC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_UPDATE_INC" AUTHID CURRENT_USER AS
/* $Header: BSCDINCS.pls 120.0 2005/06/01 15:58:18 appldev noship $ */


/*===========================================================================+
|
|   Name:          Add_Related_Tables
|
|   Description:   This recursive function add into the array x_purge_tables
|                  the tables in the graph that are interrelated with the
|                  tables in the array x_tables.
|
|   Parameters:    x_tables -array of table names
|                  x_num_tables -number of tables
|                  x_purge_tables - array to add the interrelated tables
|                  x_num_purge_tables - number of tables
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|   Notes:
|
+============================================================================*/
FUNCTION Add_Related_Tables (
	x_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_tables IN NUMBER,
        x_purge_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_purge_tables IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Do_Incremental
|
|   Description:   This function check if there are any pending task due to
|		   an incremental change like change in fiscal year or there
|                  are indicators with flag 6 (run update process) or 7 (run
|                  coloring process).
|
|   Parameters:
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|   Notes:
|
+============================================================================*/
FUNCTION Do_Incremental RETURN BOOLEAN;

--LOCKING: new function
FUNCTION Do_Incremental_AT RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Changed_Calendars
|
|   Description:   This function initialize the array x_changed_calendars
|                  with the code of the calendars whose fiscal year has changed.
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Changed_Calendars (
	x_changed_calendars IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number,
        x_num_changed_calendars IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Color_Indics_Incremental
|
|   Description:   This function initialize the array x_color_indicators
|                  with the code of the indicators with flag = 7 (re-color).
|
|   Parameters:	   x_color_indicators - array to return the indicators
|                  x_num_color_indicators - number of indicators
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Color_Indics_Incremental (
	x_color_indicators IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number,
	x_num_color_indicators IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Input_Tables
|
|   Description:   This recursive function insert into the array
|                  x_input_tables the input tables from where the system
|                  tables given in the array x_tables are originated.
|
|   Parameters:	   x_input_tables - array to insert the input tables
|                  x_num_input_tables - number of input tables
|                  x_tables - array of system tables
|                  x_num_tables - num system tables
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Input_Tables(
	x_input_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_input_tables IN OUT NOCOPY NUMBER,
	x_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_tables IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Input_Tables_Incremental
|
|   Description:   This function initialize the array x_input_tables
|                  with the name of the input tables of the indicators with
|                  flag = 6 (non-structural changes).
|
|   Parameters:	   x_input_tables     - array to return the input tables
|                  x_num_input_tables - number of input tables returned
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Input_Tables_Incremental (
	x_input_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_input_tables IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Purge_Data_All_Indicators
|
|   Description:   This function purge the data for all indicators.
|
|   Parameters:
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|   Notes:
|
+============================================================================*/
FUNCTION Purge_Data_All_Indicators RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Purge_Data_Indicators_Calendar
|
|   Description:   This function purge the data for indicators using the given
|                  calendar.
|
|   Parameters:
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|   Notes:
|
+============================================================================*/
FUNCTION Purge_Data_Indicators_Calendar(
	x_calendar_id IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Purge_Indicators_Data
|
|   Description:   This function purge the data for all indicators that are
|                  in the array x_purge_indicators and the interrelated
|                  indicators.
|
|   Parameters:    x_purge_indicators - array of indicators to purge
|                  x_num_purge_indicators - number of indicators
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|   Notes:
|
+============================================================================*/
FUNCTION Purge_Indicators_Data (
	x_purge_indicators IN BSC_UPDATE_UTIL.t_array_of_number,
	x_num_purge_indicators IN NUMBER
	) RETURN BOOLEAN;
FUNCTION Purge_Indicators_Data (
	x_purge_indicators IN BSC_UPDATE_UTIL.t_array_of_number,
	x_num_purge_indicators IN NUMBER,
        x_keep_input_data varchar2
	) RETURN BOOLEAN;
--LOCKING: new function
FUNCTION Purge_Indicators_Data_AT (
	x_purge_indicators IN BSC_UPDATE_UTIL.t_array_of_number,
	x_num_purge_indicators IN NUMBER,
        x_keep_input_data varchar2
	) RETURN BOOLEAN;

/*===========================================================================+
|
|   Name:          Reset_Flag_Indicators
|
|   Description:   This function reset to 0 the prototype flag of all
|                  indicators.
|
|   Parameters:
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Reset_Flag_Indicators RETURN BOOLEAN;


--LOCKING: new procedure
PROCEDURE Purge_AW_Indicator_AT (
    x_indicator IN NUMBER
);

END BSC_UPDATE_INC;

 

/
