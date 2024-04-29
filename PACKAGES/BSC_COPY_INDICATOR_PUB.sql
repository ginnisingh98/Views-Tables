--------------------------------------------------------
--  DDL for Package BSC_COPY_INDICATOR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_COPY_INDICATOR_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPCINS.pls 120.2.12000000.1 2007/07/17 07:43:43 appldev noship $ */
/*=======================================================================+
 |  Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |                      BSCPCINS.pls                                     |
 |                                                                       |
 | Creation Date:                                                        |
 |                      March 21, 2007                                   |
 |                                                                       |
 | Creator:                                                              |
 |                      Ajitha Koduri                                    |
 |                                                                       |
 | Description:                                                          |
 |          Public version.                                              |
 |          This package contains all the APIs related to copy and move  |
 |          indicators                                                   |
 |                                                                       |
 | History:                                                              |
 |          21-MAR-2007 akoduri Copy Indicator Enh#5943238               |
 |          06-JUN-2007 akoduri Bug 5958688 Enable YTD as default at KPI |
 *=======================================================================*/


INDICATOR_BESIDE_NAME   CONSTANT NUMBER := 0;
INDICATOR_BELOW_NAME    CONSTANT NUMBER := 1;

PROCEDURE Move_Indicator_UI_Wrap (
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_Indicator                IN    NUMBER
, p_New_Indicator_Group      IN    NUMBER
, p_New_Position             IN    NUMBER
, p_Time_Stamp               IN    VARCHAR2 := NULL
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
);

PROCEDURE CopyNew_Indicator_UI_Wrap (
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_DbLink_Name              IN    VARCHAR2
, p_Name                     IN    VARCHAR2 := NULL
, p_Description              IN    VARCHAR2 := NULL
, p_Source_Indicator         IN    NUMBER
, p_Target_Group             IN    NUMBER
, p_New_Position             IN    NUMBER
, p_Old_Dim_Levels           IN    FND_TABLE_OF_NUMBER
, p_New_Dim_Levels           IN    FND_TABLE_OF_NUMBER
, p_Old_Dim_Groups           IN    FND_TABLE_OF_NUMBER
, p_New_Dim_Groups           IN    FND_TABLE_OF_NUMBER
, p_Old_DataSet_Map          IN    FND_TABLE_OF_NUMBER
, p_New_DataSet_Map          IN    FND_TABLE_OF_NUMBER
, p_Target_Calendar          IN    NUMBER
, p_Old_Periodicities        IN    FND_TABLE_OF_NUMBER
, p_New_Periodicities        IN    FND_TABLE_OF_NUMBER
, p_Time_Stamp               IN    VARCHAR2 := NULL
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
);

PROCEDURE Move_Indicator (
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_Indicator                IN    NUMBER
, p_New_Indicator_Group      IN    NUMBER
, p_Assign_Group_To_Tab      IN    VARCHAR2 := FND_API.G_TRUE
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
);

PROCEDURE Create_Kpi_Access_Wrap(
  p_commit                       IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Comma_Sep_Resposibility_Key  IN          VARCHAR2
 ,p_Indicator_Id                 IN          NUMBER
 ,x_return_status                OUT NOCOPY  VARCHAR2
 ,x_msg_count                    OUT NOCOPY  NUMBER
 ,x_msg_data                     OUT NOCOPY  VARCHAR2
);

FUNCTION Is_Numeric_Field_Equal(
 p_Old_Value NUMBER
,p_New_Value NUMBER
) RETURN BOOLEAN;

FUNCTION Is_Varchar2_Field_Equal(
 p_Old_Value VARCHAR2
,p_New_Value VARCHAR2
) RETURN BOOLEAN;

END BSC_COPY_INDICATOR_PUB;

 

/
