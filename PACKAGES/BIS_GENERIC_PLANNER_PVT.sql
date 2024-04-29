--------------------------------------------------------
--  DDL for Package BIS_GENERIC_PLANNER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_GENERIC_PLANNER_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVGPLS.pls 115.13 2002/12/16 10:25:50 rchandra ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVGPLS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for the Generic Planning Service
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM |     APR-2000 irchen   Creation
REM +=======================================================================+
*/
--
-- Constants
--
G_COMP_RESULT_NORMAL        CONSTANT VARCHAR2(100) := 'NORMAL';
G_COMP_RESULT_OUT_OF_RANGE1 VARCHAR2(100) := BIS_TARGET_PUB.G_EXCEPTION_RANGE1;
G_COMP_RESULT_OUT_OF_RANGE2 VARCHAR2(100) := BIS_TARGET_PUB.G_EXCEPTION_RANGE2;
G_COMP_RESULT_OUT_OF_RANGE3 VARCHAR2(100) := BIS_TARGET_PUB.G_EXCEPTION_RANGE3;

--
-- Procedures
--
Procedure Service_Planner_Request
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_alert_type	    	  IN VARCHAR2 := NULL
, p_alert_level	    	  IN VARCHAR2 := NULL
);

Procedure Service_Planner_Request
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, P_notify_set	          IN VARCHAR2
, p_alert_type	    	  IN VARCHAR2
, p_alert_level	    	  IN VARCHAR2
);

Procedure Compare_Values
( p_target_rec		IN BIS_TARGET_PUB.Target_Rec_Type
, p_actual_rec		IN BIS_ACTUAL_PUB.Actual_Rec_Type
, x_comparison_result	OUT NOCOPY VARCHAR2
);

END BIS_GENERIC_PLANNER_PVT;

 

/
