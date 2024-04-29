--------------------------------------------------------
--  DDL for Package BIS_PMV_BSC_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_BSC_API_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPVEWS.pls 120.0 2005/06/01 16:35:46 appldev noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPVEWS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for getting information about PMV Reports              |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | Date              Developer           Comments                        |
REM | 22-AUG-2002       nbarik              Creation                        |
REM |                                                                       |
REM |                                                                       |
REM +=======================================================================+
*/
--
-- Data Type: Record
--

TYPE Dimlevel_Viewby_Rec_Type IS RECORD
( Dim_DimLevel                 VARCHAR2(150)
, Viewby_Applicable            VARCHAR2(1)
, All_Applicable               VARCHAR2(1)
, Hide_Level		       VARCHAR2(1)
);

--
-- Data Type: Table
--

TYPE DimLevel_Viewby_Tbl_Type IS TABLE of Dimlevel_Viewby_Rec_Type
        INDEX BY BINARY_INTEGER;

--
-- Global Missing Composite Types
--
-- if needed will be uncommented later
--
-- G_MISS_DIMLEVEL_VIEWBY_REC       Dimlevel_Viewby_Rec_Type;
-- G_MISS_DIMLEVEL_VIEWBY_TBL       DimLevel_Viewby_Tbl_Type;


--
--
-- PROCEDURE Get_DimLevel_Viewby
--
-- Get all the Dimension+Dimension Level combination in the report
-- associated with a Measure, and whether View By applies to those
-- Dimension Levels
--

PROCEDURE Get_DimLevel_Viewby
( p_api_version              IN  NUMBER   DEFAULT NULL
, p_Region_Code              IN  VARCHAR2
, p_Measure_Short_Name       IN  VARCHAR2
, x_DimLevel_Viewby_Tbl      OUT NOCOPY BIS_PMV_BSC_API_PUB.DimLevel_Viewby_Tbl_Type
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
);

END BIS_PMV_BSC_API_PUB;

 

/
