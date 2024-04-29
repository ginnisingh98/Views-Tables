--------------------------------------------------------
--  DDL for Package BIS_DIM_LEVEL_VALUE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_DIM_LEVEL_VALUE_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPDMVS.pls 115.7 2003/06/26 15:17:59 rchandra ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPDMVS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for managing dimension level valuesfor the
REM |     Key Performance Framework.
REM |
REM |     This package should be maintaind by EDW once it gets integrated
REM |     with BIS.
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | 26-JUN-03 RCHANDRA  do away with hard coded length for name and       |
REM |                      description for bug 2910316                      |
REM |                      for dimension and dimension levels               |
REM +=======================================================================+
*/
--
-- Data Types: Records
--
TYPE Dim_Level_Value_Rec_Type IS RECORD
( Dimension_Level_ID         NUMBER
, Dimension_Level_Short_Name VARCHAR2(30)
, Dimension_Level_Name       bis_levels_tl.name%TYPE
, Dimension_Level_Value_ID   VARCHAR2(250)
, Dimension_Level_Value_Name VARCHAR2(250)
);
--
-- Data Types: Tables
--
TYPE Dim_Level_Value_Tbl_Type IS TABLE of Dim_Level_Value_Rec_Type
INDEX BY BINARY_INTEGER;
--
-- missing values
G_MISS_DIM_LEVEL_VALUE_REC Dim_Level_Value_Rec_Type;
G_MISS_DIM_LEVEL_VALUE_TBL Dim_Level_Value_Tbl_Type;
--
--
/*
Procedure Retrieve_Dim_Level_Values
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dim_Level_Value_Tbl OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Retrieve_Resp_Dim_Level_Values
( p_api_version         IN  NUMBER
, p_Responsibility_ID   IN  NUMBER
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dim_Level_Value_Tbl OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
*/
--
--
END BIS_DIM_LEVEL_VALUE_PUB;

 

/
