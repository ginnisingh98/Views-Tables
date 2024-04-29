--------------------------------------------------------
--  DDL for Package BSC_PMF_UI_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_PMF_UI_API_PUB" AUTHID CURRENT_USER as
/* $Header: BSCUIAPS.pls 120.0 2005/06/01 16:56:43 appldev noship $ */


/*  ------- Temporaly Definition for Dimension Levels View By API ------------ */
TYPE Dimlevel_Viewby_Rec_Type IS RECORD
( Dim_DimLevel                 VARCHAR2(150)
, Viewby_Applicable            VARCHAR2(1)
, All_Applicable               VARCHAR2(1)
);

TYPE DimLevel_Viewby_Tbl_Type IS TABLE of Dimlevel_Viewby_Rec_Type
        INDEX BY BINARY_INTEGER;
/* --------------------------------------------------------------------------- */

TYPE Bsc_Pmf_Ui_Rec_Type is RECORD(
  Kpi_Id            number
 ,Kpi_Group_Id          number
 ,Tab_Id            number
 ,Measure_Short_Name        varchar2(30)
 ,Measure_Long_Name     varchar2(255)
 ,Dimension_Short_Name      varchar2(30)
 ,Dimension_Long_Name       varchar2(255)
 ,Option_Name           varchar2(80) -- changed for bug 3165012
 ,Option_Description        varchar2(240)
 ,Language          varchar2(5)
 ,Source_Language       varchar2(5)
);

TYPE Bsc_Pmf_Ui_Tbl_Type IS TABLE OF Bsc_Pmf_Ui_Rec_Type
  INDEX BY BINARY_INTEGER;

TYPE Bsc_Pmf_Dim_Rec_Type is RECORD(
  Dimension_Short_Name      varchar2(30)
 ,Dimension_Long_Name       varchar2(255)
 ,Dimension_Level_Disp_Size number
 ,Dimension_Level_Short_Name    varchar2(30)
 ,Dimension_Level_Status    varchar2(15)
 ,Dimension_Level_Long_Name varchar2(255)
 ,Dimension_Level_View_Name varchar2(30)
 ,Dimension_Level_Pk_Key    varchar2(30)
 ,Dimension_Level_Pk_Key_edw    varchar2(30)
 ,Dimension_Level_Name_Column   varchar2(30)
 ,Dimension_Level_Source    varchar2(5)
);

TYPE Bsc_Pmf_Dim_Tbl_Type IS TABLE OF Bsc_Pmf_Dim_Rec_Type
  INDEX BY BINARY_INTEGER;

procedure Bsc_Pmf_Ui_Api(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Ui_Rec      IN      BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Rec_Type
 ,p_Bsc_Pmf_Dim_Tbl IN  BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Tbl_Type
 ,p_Dim_Count       IN  number
 ,x_bad_level       OUT NOCOPY  varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Get_Measure_Long_Name(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Ui_Rec      IN      BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Get_Dimension_Long_Name(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Ui_Rec      IN      BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

/*
procedure Get_Dimension_Level_Name(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Ui_Rec      IN      BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);
*/

procedure Modify_Passed_Parameters(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Ui_Rec      IN      BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Rec_Type
 ,p_Bsc_Pmf_Dim_Tbl     IN      BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Tbl_Type
 ,p_Dim_Count       IN  number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Bsc_Dataset(
  p_commit              IN             varchar2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Ui_Rec      IN             BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);


procedure Create_Bsc_Dimension(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Dim_Tbl IN  BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Tbl_Type
 ,p_Dim_Count       IN  number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Bsc_Dataset(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Ui_Rec      IN      BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Bsc_Dimension_Set(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Ui_Rec      IN      BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Rec_Type
 ,p_Bsc_Pmf_Dim_Tbl IN  BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Tbl_Type
 ,p_Dim_Count       IN  number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Bsc_Analysis_Option(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

/*********************************************************************************
-- Procedures to Handle Relationships between Dimension Levels
**********************************************************************************/

procedure Import_PMF_Dim_Level(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Dim_Rec     IN      BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Populate_Bsc_Pmf_Dim_Rec(
  p_commit                IN    varchar2 := FND_API.G_TRUE
 ,p_Dim_Level_Short_Name  IN    varchar2
 ,x_Bsc_Pmf_Dim_Rec     OUT NOCOPY     BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

FUNCTION get_Dim_Level_View_Name(
   p_Short_Name IN VARCHAR2
) RETURN VARCHAR2;

/*********************************************************************************
**********************************************************************************/

PROCEDURE Get_DimLevel_Viewby
( p_api_version              IN  NUMBER
, p_Region_Code              IN  VARCHAR2
, p_Measure_Short_Name       IN  VARCHAR2
, x_DimLevel_Viewby_Tbl      OUT NOCOPY DimLevel_Viewby_Tbl_Type  /* BIS_PMV_BSC_API_PUB.DimLevel_Viewby_Tbl_Type */
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
);

/*********************************************************************************
**********************************************************************************/


end BSC_PMF_UI_API_PUB;

 

/
