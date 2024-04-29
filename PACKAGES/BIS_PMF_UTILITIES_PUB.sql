--------------------------------------------------------
--  DDL for Package BIS_PMF_UTILITIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMF_UTILITIES_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPPMUS.pls 115.2 99/10/11 15:03:55 porting sh $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPPMUS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for PMF utilities                                      |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 10-AUG-99 surao Creation                                              |
REM |                                                                       |
REM +=======================================================================+
*/
--
--
TYPE Target_Level_Rec_Type IS RECORD
( Description VARCHAR2(2000) := NULL );
--
TYPE l_target_level_Tbl_Type IS
TABLE OF Target_Level_Rec_Type
INDEX BY BINARY_INTEGER;
--
FUNCTION Get_Target_For_Target_Level
( p_TARGET_LEVEL_SHORT_NAME IN VARCHAR2
, p_ORG_LEVEL_VALUE         IN VARCHAR2
, p_TIME_LEVEL_VALUE        IN VARCHAR2
, p_DIMENSION1_LEVEL_VALUE  IN VARCHAR2
, p_DIMENSION2_LEVEL_VALUE  IN VARCHAR2
, p_DIMENSION3_LEVEL_VALUE  IN VARCHAR2
, p_DIMENSION4_LEVEL_VALUE  IN VARCHAR2
, p_DIMENSION5_LEVEL_VALUE  IN VARCHAR2
, p_PLAN_NAME               IN VARCHAR2
)
RETURN NUMBER;
--
FUNCTION Get_Target_For_Level_ID
( p_MEASURE_SHORT_NAME     IN VARCHAR2
, p_ORG_LEVEL              IN NUMBER
, p_TIME_LEVEL             IN NUMBER
, p_DIMENSION1_LEVEL       IN NUMBER
, p_DIMENSION2_LEVEL       IN NUMBER
, p_DIMENSION3_LEVEL       IN NUMBER
, p_DIMENSION4_LEVEL       IN NUMBER
, p_DIMENSION5_LEVEL       IN NUMBER
, p_ORG_LEVEL_VALUE        IN VARCHAR2
, p_TIME_LEVEL_VALUE       IN VARCHAR2
, p_DIMENSION1_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION2_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION3_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION4_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION5_LEVEL_VALUE IN VARCHAR2
, p_PLAN_NAME              IN VARCHAR2
)
RETURN NUMBER;
--
FUNCTION Get_Target_For_Level
( p_MEASURE_SHORT_NAME     IN VARCHAR2
, p_ORG_LEVEL              IN VARCHAR2
, p_TIME_LEVEL             IN VARCHAR2
, p_DIMENSION1_LEVEL       IN VARCHAR2
, p_DIMENSION2_LEVEL       IN VARCHAR2
, p_DIMENSION3_LEVEL       IN VARCHAR2
, p_DIMENSION4_LEVEL       IN VARCHAR2
, p_DIMENSION5_LEVEL       IN VARCHAR2
, p_ORG_LEVEL_VALUE        IN VARCHAR2
, p_TIME_LEVEL_VALUE       IN VARCHAR2
, p_DIMENSION1_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION2_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION3_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION4_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION5_LEVEL_VALUE IN VARCHAR2
, p_PLAN_NAME              IN VARCHAR2
)
RETURN NUMBER;
--
FUNCTION Get_Target_Value
( p_TARGET_LEVEL_ID        IN NUMBER
, p_ORG_LEVEL_VALUE        IN VARCHAR2
, p_TIME_LEVEL_VALUE       IN VARCHAR2
, p_DIMENSION1_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION2_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION3_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION4_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION5_LEVEL_VALUE IN VARCHAR2
, p_PLAN_NAME              IN VARCHAR2
)
RETURN NUMBER;
--
--
END BIS_PMF_UTILITIES_PUB;

 

/
