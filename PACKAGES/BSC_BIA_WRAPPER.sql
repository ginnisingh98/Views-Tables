--------------------------------------------------------
--  DDL for Package BSC_BIA_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_BIA_WRAPPER" AUTHID CURRENT_USER AS
/* $Header: BSCBIAWS.pls 120.1 2006/04/19 11:36:20 meastmon noship $ */

-- bug 3835059
-- adding it here instead of bsc_metadata_optimizer_pkg as this
-- may need to be backported to 5.1.1 and 5.1.1.1 wherein VB
-- will call this API (in these versions bsc_metadata_optimizer_pkg
-- does not exist)

MAX_ALLOWED_LEVELS constant number := 8;

--Fix bug#5069433
g_projection_kpis BSC_UPDATE_UTIL.t_array_of_number;
g_projection_kpis_set BOOLEAN := FALSE;


/*===========================================================================+
|
|   Name:          Analyze_Table
|
|   Description:   Analyze the given table.

|   Notes:
|
+============================================================================*/
PROCEDURE Analyze_Table(
    p_table_name IN VARCHAR2
);

/*===========================================================================+
|
|   Name:          Do_Analyze
|
|   Description:   This function returns TRUE if we want to Analyze the MVs
|                  after refresh
|
|   Notes:
|
+============================================================================*/
FUNCTION Do_Analyze RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Drop_Rpt_Key_Table
|
|   Description:   Drop the tables bsc_rpt_keys_%
|
|   Notes:
|
+============================================================================*/
FUNCTION Drop_Rpt_Key_Table(
    p_user_id NUMBER,
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Drop_Rpt_Key_Table_VB
|
|   Description:   Drop the tables bsc_rpt_keys_%
|                  This procedure is to be called from Metadata optmizer.
|                  In case of error it insert the error in BSC_MESSAGE_LOGS
|   Notes:
|
+============================================================================*/
PROCEDURE Drop_Rpt_Key_Table_VB(
    p_user_id NUMBER
);


/*===========================================================================+
|
|   Name:          Drop_Summary_MV
|
|   Description:   This function drops the give MV.
|                  Returns False in case of error along with the error
|                  message in x_error_message
|
|   Notes:
|
+============================================================================*/
FUNCTION Drop_Summary_MV(
    p_mv IN VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Drop_Summary_MV_VB
|
|   Description:   This function drops the give MV.
|                  This procedure is to be called from Metadata optmizer.
|                  In case of error it insert the error in BSC_MESSAGE_LOGS
|
|   Notes:
|
+============================================================================*/
PROCEDURE Drop_Summary_MV_VB(
    p_mv IN VARCHAR2
);


/*===========================================================================+
|
|   Name:          Get_Sum_Table_MV_Name
|
|   Description:   Returns the MV name of the given summary table
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Sum_Table_MV_Name(
	p_table_name IN VARCHAR2
) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Get_Sum_Table_MV_Name, WNDS);


/*===========================================================================+
|
|   Name:          Implement_Bsc_MV
|
|   Description:   This function creates all the MVs required for the given kpi.
|                  Returns False in case of error along with the error
|                  message in x_error_message
|
|   Notes:
|
+============================================================================*/
FUNCTION Implement_Bsc_MV(
    p_kpi IN NUMBER,
    p_adv_sum_level IN NUMBER,
    p_reset_mv_levels IN BOOLEAN,
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Indicator_Has_Projection
|
|   Description:   This procedure returns TRUE is any measure of the Kpi
|                  needs projection.
|
|   Notes:
|
+============================================================================*/
FUNCTION Indicator_Has_Projection(
    p_kpi IN NUMBER
) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Implement_Bsc_MV_VB
|
|   Description:   This procedure creates all the MVs required for the given kpi.
|                  This procedure is to be called from Metadata optmizer.
|                  In case of error it insert the error in BSC_MESSAGE_LOGS
|
|   Notes:
|
+============================================================================*/
PROCEDURE Implement_Bsc_MV_VB(
    p_kpi IN NUMBER,
    p_adv_sum_level IN NUMBER,
    p_reset_mv_levels IN BOOLEAN
);


/*===========================================================================+
|
|   Name:          Load_Reporting_Calendar
|
|   Description:   This function will populate the reporting calendar.
|
|   Notes:
|
+============================================================================*/
FUNCTION Load_Reporting_Calendar(
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

--Fix bug#4027813: Add this function to load reporting calendar for only
-- the specified calendar id
FUNCTION Load_Reporting_Calendar(
    x_calendar_id IN NUMBER,
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

--LOCKING: new function
FUNCTION Load_Reporting_Calendar_AT(
    x_calendar_id IN NUMBER,
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Load_Reporting_Calendar_VB
|
|   Description:   This function will populate the reporting calendar.
|                  This procedure is to be called from Metadata optmizer.
|                  In case of error it insert the error in BSC_MESSAGE_LOGS

|   Notes:
|
+============================================================================*/
PROCEDURE Load_Reporting_Calendar_VB;


/*===========================================================================+
|
|   Name:          Refresh_Summary_MV
|
|   Description:   This function refreshes the given MV.
|                  Returns False in case of error along with the error
|                  message in x_error_message
|
|   Notes:
|
+============================================================================*/
FUNCTION Refresh_Summary_MV(
    p_mv IN VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

--LOCKING: new function
FUNCTION Refresh_Summary_MV_AT(
    p_mv IN VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

END BSC_BIA_WRAPPER;

 

/
