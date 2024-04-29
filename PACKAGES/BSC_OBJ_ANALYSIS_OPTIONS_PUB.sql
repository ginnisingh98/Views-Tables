--------------------------------------------------------
--  DDL for Package BSC_OBJ_ANALYSIS_OPTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_OBJ_ANALYSIS_OPTIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPOAOS.pls 120.4.12000000.1 2007/07/17 07:44:18 appldev noship $ */


PROCEDURE Create_Analysis_Option_UI(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,p_Analysis_Group_Id     IN   NUMBER := 0
 ,p_Option_Id             IN   NUMBER := 0
 ,p_Parent_Option_Id      IN   NUMBER := 0
 ,p_GrandParent_Option_Id IN   NUMBER := 0
 ,p_Dependency_Flag       IN   NUMBER := 0
 ,p_DataSet_Id            IN   NUMBER := -1
 ,p_DimSet_Id             IN   NUMBER := 0
 ,p_Default_Flag          IN   NUMBER := 0
 ,p_Option_Name           IN   VARCHAR2
 ,p_Option_Help           IN   VARCHAR2
 ,p_Change_Dim_Set        IN   NUMBER := 0
 ,p_default_calculation   IN   NUMBER := NULL
 ,p_time_stamp            IN   VARCHAR2 := NULL
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
);

PROCEDURE Update_Analysis_Option_UI(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,p_Analysis_Group_Id     IN   NUMBER := 0
 ,p_Option_Id             IN   NUMBER := 0
 ,p_Parent_Option_Id      IN   NUMBER := 0
 ,p_GrandParent_Option_Id IN   NUMBER := 0
 ,p_Dependency_Flag       IN   NUMBER := 0
 ,p_DataSet_Id            IN   NUMBER := NULL
 ,p_DimSet_Id             IN   NUMBER := 0
 ,p_Default_Flag          IN   NUMBER := 0
 ,p_Option_Name           IN   VARCHAR2
 ,p_Option_Help           IN   VARCHAR2
 ,p_Change_Dim_Set        IN   NUMBER := 0
 ,p_default_calculation   IN   NUMBER := NULL
 ,p_Create_Flow           IN   VARCHAR2 := FND_API.G_FALSE
 ,p_time_stamp            IN   VARCHAR2 := NULL
 ,p_olddim_Dataset_map    IN   BSC_KPI_SERIES_PUB.Bsc_Dim_Dataset_Table := NULL
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
);

PROCEDURE Delete_Analysis_Option_UI(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,p_Analysis_Group_Id     IN   NUMBER := 0
 ,p_Option_Id             IN   NUMBER := 0
 ,p_Parent_Option_Id      IN   NUMBER := 0
 ,p_GrandParent_Option_Id IN   NUMBER := 0
 ,p_time_stamp            IN   VARCHAR2 := NULL
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
);

PROCEDURE Val_Delete_Analysis_Option(
  p_Indicator             IN   NUMBER
 ,p_Analysis_Group_Id     IN   NUMBER := 0
 ,p_Option_Id             IN   NUMBER := 0
 ,p_Parent_Option_Id      IN   NUMBER := 0
 ,p_GrandParent_Option_Id IN   NUMBER := 0
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
);

PROCEDURE Get_Next_Option_Id (
  p_Indicator            IN NUMBER
 ,p_Analysis_Group_Id   IN NUMBER
 ,p_Parent_Option_Id    IN NUMBER
 ,p_Grandparent_Option_Id  IN NUMBER
 ,x_Option_Id           OUT NOCOPY NUMBER
);

FUNCTION Get_DataSetId_For_AO_Comb (
   p_Indicator              IN  NUMBER
  ,p_Analayis_Group_Id      IN  NUMBER
  ,p_Option_Id              IN  NUMBER
  ,p_Parent_Option_Id       IN  NUMBER
  ,p_GrandParent_Option_Id  IN  NUMBER
) RETURN NUMBER;

FUNCTION Get_Dependency (
  p_Indicator         IN NUMBER
 ,p_Analysis_Group_Id IN NUMBER
) RETURN NUMBER;

FUNCTION Get_Analysis_Option_Default (
  p_Indicator         IN NUMBER
 ,p_Analysis_Group_Id IN NUMBER
) RETURN NUMBER;

PROCEDURE  Get_Parent_GrandParent_Ids(
  p_Indicator             IN NUMBER
 ,p_Analysis_Group_Id     IN NUMBER
 ,p_Parent_Id             IN NUMBER
 ,p_GrandParent_Id        IN NUMBER
 ,p_Independent_Par_Id    IN NUMBER := 0
 ,x_Parent_Id             OUT NOCOPY NUMBER
 ,x_GrandParent_Id        OUT NOCOPY NUMBER
 ,x_Parent_Group_Id       OUT NOCOPY NUMBER
 ,x_GrandParent_Group_Id  OUT NOCOPY NUMBER
);

FUNCTION Get_Analysis_Option_Name(
  p_Indicator        NUMBER,
  p_Analysis_Option0 NUMBER,
  p_Analysis_Option1 NUMBER,
  p_Analysis_Option2 NUMBER,
  p_Group_Id         NUMBER
) RETURN VARCHAR2;

FUNCTION Is_Analayis_Option_Valid(
  p_Indicator        NUMBER,
  p_Analysis_Option0 NUMBER,
  p_Analysis_Option1 NUMBER,
  p_Analysis_Option2 NUMBER,
  p_Group_Id         NUMBER
) RETURN VARCHAR2 ;

FUNCTION Get_Parent_Id (
  p_Indicator        NUMBER,
  p_Analysis_GroupId NUMBER,
  p_Option_Id        NUMBER,
  p_Parent_Id        NUMBER
)RETURN NUMBER;

FUNCTION Get_Grand_Parent_Id (
  p_Indicator        NUMBER,
  p_Analysis_GroupId NUMBER,
  p_Option_Id        NUMBER,
  p_GrandParent_Id   NUMBER
)RETURN NUMBER;

FUNCTION Get_Dim_Set_Id(
  p_Indicator             IN  NUMBER
 ,p_Analysis_Option0      IN  NUMBER := 0
 ,p_Analysis_Option1      IN  NUMBER := 0
 ,p_Analysis_Option2      IN  NUMBER := 0
 ,p_Dim_Set_Group         IN  NUMBER := 0
) RETURN NUMBER;

PROCEDURE Check_YTD_Apply(
  p_commit         IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator      IN   NUMBER
 ,x_return_status  OUT NOCOPY   VARCHAR2
 ,x_msg_count      OUT NOCOPY   NUMBER
 ,x_msg_data       OUT NOCOPY   VARCHAR2
);

FUNCTION Get_Kpi_Property (
   p_Indicator              IN  NUMBER
  ,p_Analayis_Group_Id      IN  NUMBER
  ,p_Option_Id              IN  NUMBER
  ,p_Parent_Option_Id       IN  NUMBER
  ,p_GrandParent_Option_Id  IN  NUMBER
  ,p_Property_Name          IN  VARCHAR2
) RETURN NUMBER;

END BSC_OBJ_ANALYSIS_OPTIONS_PUB;

 

/
