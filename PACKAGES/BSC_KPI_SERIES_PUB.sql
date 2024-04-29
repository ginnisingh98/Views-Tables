--------------------------------------------------------
--  DDL for Package BSC_KPI_SERIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_KPI_SERIES_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPSERS.pls 120.1.12000000.1 2007/07/17 07:44:21 appldev noship $ */

TYPE Bsc_Dim_DataSet_Map IS RECORD(
  dim_set_id NUMBER
 ,dataset_id NUMBER
 ,rec_count  NUMBER
);

TYPE Bsc_Dim_Dataset_Table IS TABLE OF Bsc_Dim_DataSet_Map;

PROCEDURE Create_Analysis_Measure_UI(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,p_Analysis_Option0      IN   NUMBER
 ,p_Analysis_Option1      IN   NUMBER
 ,p_Analysis_Option2      IN   NUMBER
 ,p_Series_Id             IN   NUMBER
 ,p_Axis                  IN   NUMBER := 0
 ,p_Series_Type           IN   NUMBER := 0
 ,p_Bm_Flag               IN   NUMBER := 0
 ,p_Budget_Flag           IN   NUMBER := 0
 ,p_Default_Flag          IN   NUMBER := 0
 ,p_Stack_Series_Id       IN   NUMBER := NULL
 ,p_Series_Name           IN   VARCHAR2
 ,p_Series_Help           IN   VARCHAR2
 ,p_dataset_Id            IN   NUMBER := -1
 ,p_Color_Values          IN   FND_TABLE_OF_NUMBER := NULL
 ,p_default_calculation   IN   NUMBER := NULL
 ,p_time_stamp            IN   VARCHAR2 := NULL
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
);

PROCEDURE Update_Analysis_Measure_UI(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,p_Analysis_Option0      IN   NUMBER
 ,p_Analysis_Option1      IN   NUMBER
 ,p_Analysis_Option2      IN   NUMBER
 ,p_Series_Id             IN   NUMBER
 ,p_Axis                  IN   NUMBER := 0
 ,p_Series_Type           IN   NUMBER := 0
 ,p_Bm_Flag               IN   NUMBER := 0
 ,p_Budget_Flag           IN   NUMBER := 0
 ,p_Default_Flag          IN   NUMBER := 0
 ,p_Stack_Series_Id       IN   NUMBER := NULL
 ,p_Series_Name           IN   VARCHAR2
 ,p_Series_Help           IN   VARCHAR2
 ,p_dataset_Id            IN   NUMBER := -1
 ,p_Color_Values          IN   FND_TABLE_OF_NUMBER := NULL
 ,p_default_calculation   IN   NUMBER := NULL
 ,p_time_stamp            IN   VARCHAR2 := NULL
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
);

PROCEDURE Delete_Analysis_Measure_UI(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,p_Analysis_Option0      IN   NUMBER
 ,p_Analysis_Option1      IN   NUMBER
 ,p_Analysis_Option2      IN   NUMBER
 ,p_Series_Id             IN   NUMBER
 ,p_time_stamp            IN   VARCHAR2 := NULL
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
);

PROCEDURE Populate_Kpi_Series_Colors(
  p_commit          IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Anal_Opt_Rec    IN   BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,p_Color_Values    IN   FND_TABLE_OF_NUMBER
 ,x_return_status   OUT NOCOPY   VARCHAR2
 ,x_msg_count       OUT NOCOPY   NUMBER
 ,x_msg_data        OUT NOCOPY   VARCHAR2
);

PROCEDURE Delete_Kpi_Series_Colors(
  p_commit          IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Anal_Opt_Rec    IN   BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status   OUT NOCOPY   VARCHAR2
 ,x_msg_count       OUT NOCOPY   NUMBER
 ,x_msg_data        OUT NOCOPY   VARCHAR2
);

PROCEDURE Check_Color_Props(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,p_Analysis_Option0      IN   NUMBER
 ,p_Analysis_Option1      IN   NUMBER
 ,p_Analysis_Option2      IN   NUMBER
 ,p_Series_Id             IN   NUMBER
 ,p_Budget_Flag           IN   NUMBER := 0
 ,p_Default_Flag          IN   NUMBER := 0
 ,p_Dataset_Id            IN   NUMBER := -1
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
);

PROCEDURE Check_Series_Default_Props(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
);

PROCEDURE Update_Color_Structure_Flags (
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator         IN   NUMBER
 ,p_Action_Flag       IN   NUMBER := 3
 ,x_return_status     OUT NOCOPY   VARCHAR2
 ,x_msg_count         OUT NOCOPY   NUMBER
 ,x_msg_data          OUT NOCOPY   VARCHAR2
);

PROCEDURE Update_Kpi_Time_Stamp(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Indicator           IN      NUMBER
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);


PROCEDURE Check_Series_Structure_Change (
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,p_Analysis_Option0      IN   NUMBER
 ,p_Analysis_Option1      IN   NUMBER
 ,p_Analysis_Option2      IN   NUMBER
 ,p_Series_Id             IN   NUMBER
 ,p_New_Dataset_Map       IN   FND_TABLE_OF_NUMBER
 ,p_Delete_Mode           IN   NUMBER := 0
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
);

PROCEDURE Save_Default_Calculation(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,p_Analysis_Option0      IN   NUMBER
 ,p_Analysis_Option1      IN   NUMBER
 ,p_Analysis_Option2      IN   NUMBER
 ,p_Series_Id             IN   NUMBER
 ,p_default_calculation   IN   NUMBER := NULL
 ,p_casacade_shared       IN   VARCHAR2 := FND_API.G_TRUE
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
);

END BSC_KPI_SERIES_PUB;

 

/
