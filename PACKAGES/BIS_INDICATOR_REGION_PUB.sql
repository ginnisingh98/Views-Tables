--------------------------------------------------------
--  DDL for Package BIS_INDICATOR_REGION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_INDICATOR_REGION_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPREGS.pls 115.29 2003/01/30 09:09:01 sugopal ship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30):='BIS_INDICATOR_REGION_PUB';

TYPE Indicator_Region_Rec_Type IS RECORD (
  Ind_Selection_ID             NUMBER
,  Plug_ID                      NUMBER
,  User_ID                      NUMBER
,  User_Name                    VARCHAR2(100)
,  Responsibility_ID            NUMBER
,  Responsibility_Short_Name    VARCHAR2(100)
,  Responsibility_Name          VARCHAR2(240)
,  Target_Level_ID              NUMBER
,  Target_Level_Short_Name      VARCHAR2(80)
,  Target_Level_Name            VARCHAR2(100)
,  Label                        VARCHAR2(40)
,  Org_Level_Value_ID           VARCHAR2(250)
,  Org_Level_Value_Name         VARCHAR2(250)
,  Dim1_Level_Value_ID          VARCHAR2(250)
,  Dim1_Level_Value_Name        VARCHAR2(250)
,  Dim2_Level_Value_ID          VARCHAR2(250)
,  Dim2_Level_Value_Name        VARCHAR2(250)
,  Dim3_Level_Value_ID          VARCHAR2(250)
,  Dim3_Level_Value_Name        VARCHAR2(250)
,  Dim4_Level_Value_ID          VARCHAR2(250)
,  Dim4_Level_Value_Name        VARCHAR2(250)
,  Dim5_Level_Value_ID          VARCHAR2(250)
  -- mdamle 01/15/2001 - Add Dim6 and Dim7
,  Dim5_Level_Value_Name        VARCHAR2(250)
,  Dim6_Level_Value_ID          VARCHAR2(250)
,  Dim6_Level_Value_Name        VARCHAR2(250)
,  Dim7_Level_Value_ID          VARCHAR2(250)
,  Dim7_Level_Value_Name        VARCHAR2(250)
,  Plan_ID                      NUMBER
,  Plan_Short_Name              VARCHAR2(30)
,  Plan_Name                    VARCHAR2(80)
-- 2400589, ,  rank_level_short_name        VARCHAR2(30)  := NULL
,  rank_level_short_name        VARCHAR2(80)
,  rank_on_change               VARCHAR2(1)
);

/*
TYPE Indicator_Region_Rec_Type IS RECORD (
  Ind_Selection_ID             NUMBER := FND_API.G_MISS_NUM,
  Plug_ID                      NUMBER := FND_API.G_MISS_NUM,
  User_ID                      NUMBER := FND_API.G_MISS_NUM,
  User_Name                    VARCHAR2(100) := FND_API.G_MISS_CHAR,
  Responsibility_ID            NUMBER := FND_API.G_MISS_NUM,
  Responsibility_Short_Name    VARCHAR2(100) := FND_API.G_MISS_CHAR,
  Responsibility_Name          VARCHAR2(240) := FND_API.G_MISS_CHAR,
  Target_Level_ID              NUMBER := FND_API.G_MISS_NUM,
  Target_Level_Short_Name      VARCHAR2(80)  := FND_API.G_MISS_CHAR,
  Target_Level_Name            VARCHAR2(100) := FND_API.G_MISS_CHAR,
  Label                        VARCHAR2(30) := FND_API.G_MISS_CHAR,
  Org_Level_Value_ID           VARCHAR2(80) := FND_API.G_MISS_CHAR,
  Org_Level_Value_Name         VARCHAR2(60) := FND_API.G_MISS_CHAR,
  Dim1_Level_Value_ID          VARCHAR2(250) := FND_API.G_MISS_CHAR,
  Dim1_Level_Value_Name        VARCHAR2(250) := FND_API.G_MISS_CHAR,
  Dim2_Level_Value_ID          VARCHAR2(250) := FND_API.G_MISS_CHAR,
  Dim2_Level_Value_Name        VARCHAR2(250) := FND_API.G_MISS_CHAR,
  Dim3_Level_Value_ID          VARCHAR2(250) := FND_API.G_MISS_CHAR,
  Dim3_Level_Value_Name        VARCHAR2(250) := FND_API.G_MISS_CHAR,
  Dim4_Level_Value_ID          VARCHAR2(250) := FND_API.G_MISS_CHAR,
  Dim4_Level_Value_Name        VARCHAR2(250) := FND_API.G_MISS_CHAR,
  Dim5_Level_Value_ID          VARCHAR2(250) := FND_API.G_MISS_CHAR,
  Dim5_Level_Value_Name        VARCHAR2(250) := FND_API.G_MISS_CHAR,
  Plan_ID                      NUMBER        := FND_API.G_MISS_NUM,
  Plan_Short_Name              VARCHAR2(30) := FND_API.G_MISS_CHAR,
  Plan_Name                    VARCHAR2(80) := FND_API.G_MISS_CHAR);
*/

TYPE Indicator_Region_Tbl_Type IS TABLE of Indicator_Region_Rec_Type
        INDEX BY BINARY_INTEGER;

G_MISS_IND_REGION_REC   Indicator_Region_Rec_Type;
G_MISS_IND_REGION_TBL   Indicator_Region_Tbl_Type;


Procedure Create_User_Ind_Selection(
        p_api_version          IN NUMBER,
        p_Indicator_Region_Rec
          IN BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type,
        x_return_status	       OUT NOCOPY VARCHAR2,
        x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type);

Procedure Retrieve_User_Ind_Selections(
        p_api_version           IN NUMBER,
        p_user_id               IN NUMBER Default BIS_UTILITIES_PUB.G_NULL_NUM,
        p_user_name             IN VARCHAR2 Default BIS_UTILITIES_PUB.G_NULL_CHAR,
        p_plug_id               IN NUMBER,
        p_all_info              IN VARCHAR2 Default FND_API.G_TRUE,
        x_Indicator_Region_Tbl
          OUT NOCOPY BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type,
        x_return_status	        OUT NOCOPY VARCHAR2,
        x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type);


Procedure Retrieve_User_Ind_Selections(
        p_api_version           IN NUMBER,
        p_all_info              IN VARCHAR2 Default FND_API.G_TRUE,
        p_Target_level_rec      IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type,
        x_Indicator_Region_Tbl
          OUT NOCOPY BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type,
        x_return_status	        OUT NOCOPY VARCHAR2,
        x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type);


Procedure Update_User_Ind_Selection(
        p_api_version          IN NUMBER,
        p_user_id               IN NUMBER Default BIS_UTILITIES_PUB.G_NULL_NUM,
        p_user_name             IN VARCHAR2 Default BIS_UTILITIES_PUB.G_NULL_CHAR,
        p_plug_id               IN NUMBER ,
        p_Indicator_Region_Tbl
          IN BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type,
        x_return_status	       OUT NOCOPY VARCHAR2,
        x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type);



Procedure Delete_User_Ind_Selections(
        p_api_version           IN NUMBER,
        p_user_id               IN NUMBER Default BIS_UTILITIES_PUB.G_NULL_NUM,
        p_user_name             IN VARCHAR2 Default BIS_UTILITIES_PUB.G_NULL_CHAR,
        p_plug_id               IN NUMBER,
        x_return_status	        OUT NOCOPY VARCHAR2,
        x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type);


END BIS_INDICATOR_REGION_PUB;

 

/
