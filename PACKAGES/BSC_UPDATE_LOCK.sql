--------------------------------------------------------
--  DDL for Package BSC_UPDATE_LOCK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_UPDATE_LOCK" AUTHID CURRENT_USER AS
/* $Header: BSCDLCKS.pls 120.0 2005/06/01 16:22:00 appldev noship $ */


FUNCTION Lock_AW_Indicator_Cubes(
    x_indicator IN NUMBER
) RETURN BOOLEAN;

FUNCTION Lock_Calendar (
    x_calendar_id IN NUMBER
) RETURN BOOLEAN;

FUNCTION Lock_Calendar_Change (
    x_calendar_id IN NUMBER
) RETURN BOOLEAN;

FUNCTION Lock_Color_Indicator(
    x_indicator IN NUMBER
) RETURN BOOLEAN;

FUNCTION Lock_Color_Indicators(
    x_indicators IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_indicators IN NUMBER
) RETURN BOOLEAN;

FUNCTION Lock_DBI_Dimension(
    x_dim_short_name IN VARCHAR2
) RETURN BOOLEAN;

FUNCTION Lock_Import_Dbi_Plans RETURN BOOLEAN;

FUNCTION Lock_Import_ITable(
    x_input_table IN VARCHAR2
) RETURN BOOLEAN;

FUNCTION Lock_Incremental_Indicators RETURN BOOLEAN;

FUNCTION Lock_Indicators (
    x_input_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_input_tables IN NUMBER
) RETURN BOOLEAN;

FUNCTION Lock_Indicators_by_Calendar (
    x_calendars IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_calendars IN NUMBER
) RETURN BOOLEAN;

FUNCTION Lock_Indicators_To_Delete (
    x_indicators IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_indicators IN NUMBER
) RETURN BOOLEAN;

FUNCTION Lock_Load_Dimension_Table (
    x_dim_table IN VARCHAR2,
    x_input_table IN VARCHAR2
) RETURN BOOLEAN;

FUNCTION Lock_Period_Indicator(
    x_indicator IN NUMBER
) RETURN BOOLEAN;

FUNCTION Lock_Period_Indicators(
    x_indicators IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_indicators IN NUMBER
) RETURN BOOLEAN;

FUNCTION Lock_Period_Indicators(
    x_table_name IN VARCHAR2
) RETURN BOOLEAN;

FUNCTION Lock_Prototype_Indicator(
    x_indicator IN NUMBER
) RETURN BOOLEAN;

FUNCTION Lock_Prototype_Indicators(
    x_calendar_id IN NUMBER
) RETURN BOOLEAN;

FUNCTION Lock_Prototype_Indicators
RETURN BOOLEAN;

FUNCTION Lock_Refresh_AW_Indicator(
    x_indicator IN NUMBER
) RETURN BOOLEAN;

FUNCTION Lock_Refresh_AW_Table(
    x_summary_table IN VARCHAR2
) RETURN BOOLEAN;

FUNCTION Lock_Refresh_MV(
    x_summary_table IN VARCHAR2
) RETURN BOOLEAN;

FUNCTION Lock_Refresh_Sum_Table(
    x_summary_table IN VARCHAR2
) RETURN BOOLEAN;

FUNCTION Lock_Update_Base_Table(
    x_input_table IN VARCHAR2,
    x_base_table IN VARCHAR2
) RETURN BOOLEAN;

FUNCTION Lock_Update_Date RETURN BOOLEAN;

FUNCTION Lock_Table(
    x_table IN VARCHAR2
) RETURN BOOLEAN;

FUNCTION Lock_Tables(
    x_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_tables IN NUMBER
) RETURN BOOLEAN;

FUNCTION Lock_Temp_Tables(
    x_type IN VARCHAR2
) RETURN BOOLEAN;

/*===========================================================================+
|
|   Name:          Request_Lock
|
|   Description:   This function locks all the given objects. It waits
|                  all the time necessary to get all the locks.
|
+============================================================================*/
FUNCTION Request_Lock (
    x_object_keys IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_object_types IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_lock_types IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_cascade_levels IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_objects IN NUMBER
) RETURN BOOLEAN;

END BSC_UPDATE_LOCK;

 

/
