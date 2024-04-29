--------------------------------------------------------
--  DDL for Package Body BIS_PMV_BSC_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_BSC_API_PUB" AS
/* $Header: BISPVEWB.pls 115.1 2002/12/03 22:33:51 kiprabha noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPVEWB.pls                                                      |
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

-- Global package name
--
G_PKG_NAME CONSTANT VARCHAR2(30) := 'BIS_PMV_BSC_API_PUB';

--
-- Get all the Dimension+Dimension Level combination in the report
-- associated with a Measure, and whether View By applies to those
-- Dimension Levels
--
PROCEDURE Get_DimLevel_Viewby
( p_api_version              IN  NUMBER    DEFAULT NULL
, p_Region_Code              IN  VARCHAR2
, p_Measure_Short_Name       IN  VARCHAR2
, x_DimLevel_Viewby_Tbl      OUT NOCOPY BIS_PMV_BSC_API_PUB.DimLevel_Viewby_Tbl_Type
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
) IS
BEGIN

BIS_PMV_BSC_API_PVT.Get_DimLevel_Viewby
( p_api_version              => p_api_version
, p_Region_Code              => p_Region_Code
, p_Measure_Short_Name       => p_Measure_Short_Name
, x_DimLevel_Viewby_Tbl      => x_DimLevel_Viewby_Tbl
, x_return_status            => x_return_status
, x_msg_count                => x_msg_count
, x_msg_data                 => x_msg_data
);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
    		( 	 p_count => x_msg_count
        		,p_data  => x_msg_data
    		);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
    		( 	 p_count => x_msg_count
        		,p_data  => x_msg_data
    		);

   WHEN others THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
    		( 	 p_count => x_msg_count
        		,p_data  => x_msg_data
    		);


END Get_DimLevel_Viewby;

END BIS_PMV_BSC_API_PUB;

/
