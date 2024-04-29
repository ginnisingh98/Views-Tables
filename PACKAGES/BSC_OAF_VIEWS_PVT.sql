--------------------------------------------------------
--  DDL for Package BSC_OAF_VIEWS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_OAF_VIEWS_PVT" AUTHID CURRENT_USER AS
/* $Header: BSCOAFVS.pls 120.1 2007/02/08 09:43:32 ankgoel ship $ */
/*===========================================================================+
|
|   Name:          GET_AOPTS_SERIES_NAMES
|
|   Description:   Check if the menu name and User name are unique to
|		   insert as a new menu.
|   Return :       'N' : Name Invalid, The name alreday exist
|                  'U' : User Name Invalid, The user name alreday exist
|                  'T' : True , The names don't exist. It can be added
|   Parameters:    X_MENU_ID 		Menu Id that will be inserted
| 	   	   X_MENU_NAME  	Menu Name
|      		   X_USER_MENU_NAME 	User Menu Name
+============================================================================*/
FUNCTION  GET_AOPTS_SERIES_NAMES(X_INDICATOR in NUMBER,
	  X_A0 in NUMBER,
	  X_A1 in NUMBER,
	  X_A2 in NUMBER,
	  X_SERIES_ID in NUMBER
	) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(GET_AOPTS_SERIES_NAMES, WNDS);

/* ===========================================================
 | Description : Return the Alarm Color for Kpi measure.
 |		 This color is showed buy Ibuilder
 |
 |Psuedo logic
 |        If DefaultMeasure  = "BSC"  Then
 |		Color = KPI Color    -> BSC_DESIGNER_PVT.GET_KPI_COLOR
 |        Elseif Measure is BSC and not DEFault THEN
 |		Color = No Color 'WHITE'
 |        Elseif Measure is PMF and kpi <> PRODUCTION THEN
 |		Color = KPI Color    -> BSC_DESIGNER_PVT.GET_KPI_COLOR
 |        Elseif Measure is PMF and kpi = PRODUCTION THEN
 |		Color = No Color 'WHITE'
 |	end if;
 ===========================================================*/
/*FUNCTION  GET_MEASURE_COLOR(X_INDICATOR in NUMBER,
	  X_A0 in NUMBER,
	  X_A1 in NUMBER,
	  X_A2 in NUMBER,
	  X_SERIES_ID in NUMBER
	) RETURN VARCHAR2;*/

function Get_Aopts_Display_Flag(
  x_indicator   IN      number
 ,x_a0          IN      number
 ,x_a1          IN      number
 ,x_a2          IN      number
 ,x_series_id   IN      number
) return number;

/* ===========================================================
 | Description : Return the parent level names of a given level
 |		 in a string
 |
 |Psuedo logic
 ===========================================================*/
FUNCTION  GET_LEVEL_PARENT_NAMES(p_level_id IN NUMBER
	) RETURN VARCHAR2;

/* ===========================================================
 | Description :
 |	This function returns the flag value that identify the default
 |      Analsyis option combination for the kpi.
 |
 ===========================================================*/
FUNCTION GET_AOPTS_DEFAULT_FLAG(
  x_indicator 	IN 	number
 ,x_a0 		IN 	number
 ,x_a1 		IN 	number
 ,x_a2 		IN 	number
 ,x_series_id 	IN 	number
) return number;

function Is_Parent_Tab(
  p_tab_id              number
) return varchar2;
/*===========================================================================+
|
|   Name:          GET_DATASET_SOURCE
|
|   Description:   Return if the dataset_id is BSC OR PMV
|   Return :       'BSC' : BSC measure
|                  'PMF' : PMF measure
|   Parameters:    X_DATASET_ID 	Menu Id that will be inserted
+============================================================================*/
FUNCTION  GET_DATASET_SOURCE(X_DATASET_ID in NUMBER
	) RETURN VARCHAR2;

h_dataset NUMBER:=-5;
h_source  VARCHAR2(10) :='BSC';

END BSC_OAF_VIEWS_PVT;

/
