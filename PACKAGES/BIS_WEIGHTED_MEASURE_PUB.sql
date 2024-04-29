--------------------------------------------------------
--  DDL for Package BIS_WEIGHTED_MEASURE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_WEIGHTED_MEASURE_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPWMES.pls 120.2.12000000.2 2007/01/31 11:09:58 akoduri ship $ */
/*======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BISPWMES.pls                                                     |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      April 11, 2005                                                  |
 | Creator:                                                                             |
 |                      William Cano                                                    |
 |                                                                                      |
 | Description:                                                                         |
 |                      Public spec version.		                     				|
 |			This package creates a BSC Scorecard				                        |
 |                                                                                      |
 |  05/12/05  jxyu added  Set_Weights_Data API.                                         |
 |  07/12/05  sawu  Bug#4482736: added Get_Dep_KPI_Format_Mask                          |
 |  09/15/05  jxyu  Bug# 4427932: added Update_WM_Last_Update_Info API                  |
 |  01/11/07  akoduri  Bug# 5594225: Performance issue in Mass Update UI                |
 +======================================================================================*/

-- Abbreviation Used"
--   WM -> Weighted Measure
--   SN -> Short Name

TYPE Bis_WM_Rec is RECORD(
 ----------------------  BIS_WEIGHTED_MEASURE_DEPENDENCIES
 weighted_measure_id     BIS_WEIGHTED_MEASURE_DEPENDS.weighted_measure_id%TYPE
 ,dependent_measure_id    BIS_WEIGHTED_MEASURE_DEPENDS.dependent_measure_id%TYPE
 ------------------------ BIS_WEIGHTED_MEASURE_DEFINITIONS
 ,weighted_definition_id    BIS_WEIGHTED_MEASURE_DEFNS.weighted_definition_id%TYPE
--weighted_measure_id       BIS_WEIGHTED_MEASURE_DEPENDS.weighted_measure_id%TYPE
 ,viewby_dimension_sn       BIS_WEIGHTED_MEASURE_DEFNS.viewby_dimension_short_name%TYPE
 ,viewby_dim_level_sn       BIS_WEIGHTED_MEASURE_DEFNS.viewby_dim_level_short_name%TYPE
 ,filter_dimension_sn       BIS_WEIGHTED_MEASURE_DEFNS.filter_dimension_short_name%TYPE
 ,filter_dim_level_sn       BIS_WEIGHTED_MEASURE_DEFNS.filter_dim_level_short_name%TYPE
 ,time_dimension_short_name  BIS_WEIGHTED_MEASURE_DEFNS.time_dimension_short_name%TYPE
 ,time_dim_level_short_name  BIS_WEIGHTED_MEASURE_DEFNS.time_dim_level_short_name%TYPE
 ---------------------------- BIS_WEIGHTED_MEASURE_PARAMETERS
 ,weighted_parameter_id      BIS_WEIGHTED_MEASURE_PARAMS.weighted_parameter_id%TYPE
--,weighted_definition_id    BIS_WEIGHTED_MEASURE_DEFNS.weighted_definition_id%TYPE
 ,time_level_value_id        BIS_WEIGHTED_MEASURE_PARAMS.time_level_value_id%TYPE
 ,filter_level_value_id      BIS_WEIGHTED_MEASURE_PARAMS.filter_level_value_id%TYPE
 ----------------------------- BIS_WEIGHTED_MEASURE_WEIGHTS
 ,weight_id                  bis_weighted_measure_weights.weight_id%TYPE
--,weighted_parameter_id     BIS_WEIGHTED_MEASURE_PARAMS.weighted_parameter_id%TYPE
--,dependent_measure_id      bis_weighted_measure_weights.dependent_measure_id%TYPE
 ,weight                     bis_weighted_measure_weights.weight%TYPE
 -------------------------- BIS_WEIGHTED_MEASURE_SCORES
--,weight_id                 bis_weighted_measure_weights.weight_id%TYPE
 ,low_range                  bis_weighted_measure_scores.low_range%TYPE
 ,high_range                 bis_weighted_measure_scores.high_range%TYPE
 ,score                      bis_weighted_measure_scores.score%TYPE
 --------------------------- Who Columns
 , Creation_Date             DATE    --  WHO COLUMN
 , Created_By                NUMBER  --  WHO COLUMN
 , Last_Update_Date          DATE    --  WHO COLUMN
 , Last_Updated_By           NUMBER  --  WHO COLUMN
 , Last_Update_Login         NUMBER  --  WHO COLUMN

);

TYPE Bis_WM_Rec_Tbl IS TABLE OF Bis_WM_Rec
  INDEX BY BINARY_INTEGER;

DEFAULT_TIME_LEVEL_VALUE  VARCHAR2(30) := 'DEFAULT';
DEFAULT_FILTER_LEVEL_VALUE  VARCHAR2(30) := 'DEFAULT';

G_POSITIVE_WEIGHTS VARCHAR2(1) := 'P';
G_ZERO_WEIGHTS VARCHAR2(1) := 'Z';
G_NO_WEIGHTS VARCHAR2(1) := 'N';

/*
-- This is tempporal whil it is tested
PROCEDURE Delete_Cascade_WM_Parameters(
  p_commit                 IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_definition_id IN NUMBER
 ,x_return_status          OUT NOCOPY VARCHAR2
 ,x_msg_count              OUT NOCOPY NUMBER
 ,x_msg_data                OUT NOCOPY VARCHAR2
) ;
*/

 ------- APIs for tables BIS_WEIGHTED_MEASURE_DEPENDS

PROCEDURE Create_WM_Dependency(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Retrieve_WM_Dependency(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Update_WM_Dependency(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_WM_Dependency(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

 ------- APIs for table BIS_WEIGHTED_MEASURE_DEFNS

PROCEDURE Create_WM_Definition(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Retrieve_WM_Definition(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Update_WM_Definition(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_WM_Definition(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

 ------- APIs for table BIS_WEIGHTED_MEASURE_PARAMS

PROCEDURE Create_WM_Parameter(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Retrieve_WM_Parameter(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Update_WM_Parameter(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_WM_Parameter(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

------- APIs for table BIS_WEIGHTED_MEASURE_WEIGHTS

PROCEDURE Create_WM_Weight(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Retrieve_WM_Weight(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Update_WM_Weight(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_WM_Weight(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

------- APIs for table BIS_WEIGHTED_MEASURE_SCORES
PROCEDURE Create_WM_Score(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Retrieve_WM_Score(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Update_WM_Score(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_WM_Score(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);
/**************************************************************************

   *********   WRAPPER APIS FOR RECORD APIS   *****************

***************************************************************************/
 ------- APIs for table BIS_WEIGHTED_MEASURE_DEFNS

PROCEDURE Create_WM_Definition(
 p_commit                      IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_definition_id     IN NUMBER
 ,p_weighted_measure_id        IN NUMBER
 ,p_viewby_dimension_sn        IN VARCHAR2
 ,p_viewby_dim_level_sn        IN VARCHAR2
 ,p_filter_dimension_sn        IN VARCHAR2
 ,p_filter_dim_level_sn        IN VARCHAR2
 ,p_time_dimension_sn          IN VARCHAR2
 ,p_time_dim_level_sn          IN VARCHAR2
 ,x_weighted_definition_id     OUT NOCOPY NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
);

PROCEDURE Retrieve_WM_Definition(
 p_weighted_definition_id     IN NUMBER
 ,x_weighted_measure_id        OUT NOCOPY NUMBER
 ,x_viewby_dimension_sn        OUT NOCOPY VARCHAR2
 ,x_viewby_dim_level_sn        OUT NOCOPY VARCHAR2
 ,x_filter_dimension_sn        OUT NOCOPY VARCHAR2
 ,x_filter_dim_level_sn        OUT NOCOPY VARCHAR2
 ,x_time_dimension_sn          OUT NOCOPY VARCHAR2
 ,x_time_dim_level_sn          OUT NOCOPY VARCHAR2
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
);

PROCEDURE Update_WM_Definition(
 p_commit                      IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_definition_id     IN NUMBER
 ,p_weighted_measure_id        IN NUMBER
 ,p_viewby_dimension_sn        IN VARCHAR2
 ,p_viewby_dim_level_sn        IN VARCHAR2
 ,p_filter_dimension_sn        IN VARCHAR2
 ,p_filter_dim_level_sn        IN VARCHAR2
 ,p_time_dimension_sn          IN VARCHAR2
 ,p_time_dim_level_sn          IN VARCHAR2
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_WM_Definition(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_definition_id     IN NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
);

PROCEDURE Create_WM_Dependency(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_measure_id        IN NUMBER
 ,p_dependent_measure_id       IN NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_WM_Dependency(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_measure_id        IN NUMBER
 ,p_dependent_measure_id       IN NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
);

PROCEDURE Create_WM_Parameter(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_parameter_id      IN NUMBER
 ,p_weighted_definition_id     IN NUMBER
 ,p_time_level_value_id        IN VARCHAR2
 ,p_filter_level_value_id      IN VARCHAR2
 ,x_weighted_parameter_id      OUT NOCOPY NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_WM_Parameter(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_parameter_id      IN NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
);

PROCEDURE Create_WM_Weight(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,P_weight_id                  IN NUMBER
 ,p_weighted_parameter_id      IN NUMBER
 ,p_dependent_measure_id       IN NUMBER
 ,p_weight                     IN NUMBER
 ,x_weight_id                  OUT NOCOPY NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
);

PROCEDURE Update_WM_Weight(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weight_id                  IN NUMBER
 ,p_weight                     IN NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_WM_Weight(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weight_id                  IN NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
);

PROCEDURE Create_WM_Score(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weight_id                  IN NUMBER
 ,p_low_range                  IN NUMBER
 ,p_high_range                 IN NUMBER
 ,p_score                      IN NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_WM_Score(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weight_id                  IN NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
);


/**************************************************************************
      WRAPPER APIS TO BE CALL FROM JAVA:
***************************************************************************/

/*******************************************************************
   Check_Defined_Weights
      Check if some weight hadbeen defined for the Weighted Measure
      or for a scpecific dependint Measure.

   Input Parameters:

      p_weighted_measure_id -> This is the Weighted Measure Id
      p_dependent_measure_Id -> if null is passed it check for the whole
                                 Weighted Measure
  Return
     P  -> Positive Weights Defined
     Z  -> Zero Wheioghts Defined
     N  -> No Weights Defined
     NULL ->  It is returned when and error happen or p_weighted_measure_id
              is passed as null

 *******************************************************************/
FUNCTION get_Defined_Weights_Status (
  p_weighted_measure_id     IN NUMBER
 ,p_dependent_measure_Id    IN NUMBER
) RETURN VARCHAR;

PROCEDURE Delete_Weighted_Measure_data(
  p_commit                 IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_measure_id    IN NUMBER
 ,x_return_status          OUT NOCOPY VARCHAR2
 ,x_msg_count              OUT NOCOPY NUMBER
 ,x_msg_data               OUT NOCOPY VARCHAR2
);

PROCEDURE Create_Weighted_Measure_data(
  p_commit                       IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_measure_id          IN NUMBER
 ,p_dependent_measure_ids        IN VARCHAR2
 ,p_viewby_dimension_short_name  IN VARCHAR2
 ,p_viewby_dim_level_short_name  IN VARCHAR2
 ,p_filter_dimension_short_name  IN VARCHAR2
 ,p_filter_dim_level_short_name  IN VARCHAR2
 ,p_time_dimension_short_name    IN VARCHAR2
 ,p_time_dim_level_short_names   IN VARCHAR2
 ,x_return_status                OUT NOCOPY VARCHAR2
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2
);

PROCEDURE Set_Weight_Data(
  p_commit                  IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_measure_id     NUMBER
 ,p_dependent_measure_id    NUMBER
 ,p_weight                  NUMBER
 ,x_return_status          OUT NOCOPY VARCHAR2
 ,x_msg_count              OUT NOCOPY NUMBER
 ,x_msg_data               OUT NOCOPY VARCHAR2
);

Procedure Set_Weights_Data(
  p_commit                  		IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_measure_id     		IN NUMBER
 ,p_depend_measure_short_names   	IN  FND_TABLE_OF_VARCHAR2_30
 ,p_weights                 		IN  FND_TABLE_OF_NUMBER
 ,x_return_status           		OUT NOCOPY VARCHAR2
 ,x_msg_count               		OUT NOCOPY NUMBER
 ,x_msg_data                		OUT NOCOPY VARCHAR2
);

FUNCTION Get_Dep_KPI_Format_Mask (
  p_wkpi_id      IN          BIS_INDICATORS.INDICATOR_ID%TYPE,
  p_dep_kpi_id   IN          BIS_INDICATORS.INDICATOR_ID%TYPE
) RETURN AK_REGION_ITEMS_VL.ATTRIBUTE7%TYPE;

PROCEDURE Update_WM_Last_Update_Info(
  p_commit          IN VARCHAR2 := FND_API.G_FALSE
 ,p_Weighted_Measure_Id      IN NUMBER
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Save_Mass_Update_Values(
  p_commit                 IN VARCHAR2 := FND_API.G_FALSE
 ,p_weighted_measure_id    IN NUMBER
 ,p_dependent_measure_id   IN NUMBER
 ,p_Time_Level             IN VARCHAR2
 ,p_Filter_Level           IN VARCHAR2
 ,p_Selected_Period_Ids    IN BIS_TABLE_OF_VARCHAR
 ,p_Selected_DimObj_Ids    IN BIS_TABLE_OF_VARCHAR
 ,p_Score_Values           IN FND_TABLE_OF_NUMBER
 ,p_Lower_Ranges           IN FND_TABLE_OF_NUMBER
 ,p_Upper_Ranges           IN FND_TABLE_OF_NUMBER
 ,x_return_status          OUT NOCOPY VARCHAR2
 ,x_msg_count              OUT NOCOPY NUMBER
 ,x_msg_data               OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_Overwrite_Scores(
  p_weighted_measure_id    IN NUMBER
 ,p_dependent_measure_id   IN NUMBER
 ,p_Selected_Period_Ids    IN BIS_TABLE_OF_VARCHAR
 ,p_Selected_DimObj_Ids    IN BIS_TABLE_OF_VARCHAR
 ,x_Param_Count            OUT NOCOPY NUMBER
);


END BIS_WEIGHTED_MEASURE_PUB;

 

/
