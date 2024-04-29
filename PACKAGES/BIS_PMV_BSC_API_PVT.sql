--------------------------------------------------------
--  DDL for Package BIS_PMV_BSC_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_BSC_API_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVVEWS.pls 115.1 2002/12/03 22:45:10 kiprabha noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVVEWS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for getting information about PMV Reports              |
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

TYPE AK_REGION_ITEMS_REC_TYPE IS RECORD
( attribute_type             AK_REGION_ITEMS.attribute1%TYPE
, attribute_value            AK_REGION_ITEMS.attribute2%TYPE
, required_flag              AK_REGION_ITEMS.required_flag%TYPE
);

--
-- PROCEDURE Get_DimLevel_Viewby
--
-- Get all the Dimension+Dimension Level combination in the report
-- associated with a Measure, and whether View By and All applies to those
-- Dimension Levels
--
PROCEDURE Get_DimLevel_Viewby
( p_api_version              IN  NUMBER     DEFAULT NULL
, p_Region_Code              IN  VARCHAR2
, p_Measure_Short_Name       IN  VARCHAR2
, x_DimLevel_Viewby_Tbl      OUT NOCOPY BIS_PMV_BSC_API_PUB.DimLevel_Viewby_Tbl_Type
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
);

--
-- PROCEDURE Populate_DimLevel_Viewby_Rec
--
-- Populate each DimLevel_Viewby_Rec record depending on Attribute Type,
-- Attribute Value, Required Flag and Disable Viewby Parameter
--
PROCEDURE Populate_DimLevel_Viewby_Rec
( p_Attribute_Type          IN  VARCHAR2
, p_Attribute_Value         IN  VARCHAR2
, p_Required_Flag           IN  VARCHAR2
, p_Disable_Viewby          IN  VARCHAR2
, x_DimLevel_Viewby_Rec     OUT NOCOPY BIS_PMV_BSC_API_PUB.DimLevel_Viewby_Rec_Type
);

END BIS_PMV_BSC_API_PVT;

 

/
