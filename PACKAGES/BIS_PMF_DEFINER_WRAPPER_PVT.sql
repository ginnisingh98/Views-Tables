--------------------------------------------------------
--  DDL for Package BIS_PMF_DEFINER_WRAPPER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMF_DEFINER_WRAPPER_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVPFJS.pls 120.0 2005/06/01 15:29:24 appldev noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVPFJS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |    Private API which can be called from Java Program for the          |
REM |    PMF definer.                                                       |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM |                                                                       |
REM | JUL2000 jradhakr Creation                                             |
REM | AUG2000 amkulkar Added wrapper for Targets CRUD                       |
REM |                  and Error Handling using the FND way!!               |
REM |                                                                       |
REM | 26-JUL-2002 rchandra  Fixed for enh 2440739                           |
REM | 30-JAN-03 sugopal FND_API.G_MISS_xxx should not be used in            |
REM |                   initialization or declaration (bug#2774644)         |
REM | 22-APR-2005 akoduri   Enhancement#3865711 -- Obsolete Seeded Objects  |
REM | 03-MAY-2005  akoduri  Enh #4268374 -- Weighted Average Measures       |
REM +=======================================================================+
*/

--2440739
c_show_url CONSTANT VARCHAR2(1) := 'Y';
c_hide_url CONSTANT VARCHAR2(1) := 'N';
--2440739
c_default_appl  NUMBER := -1; --2465354

Procedure Delete_Performance_Measure
(p_Measure_ID                 IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Measure_Short_Name         IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,x_return_status              OUT NOCOPY  VARCHAR2
,x_msg_count                  OUT NOCOPY  VARCHAR2
,x_msg_data                   OUT NOCOPY  VARCHAR2
);

Procedure Update_Performance_Measure
(p_Measure_ID                 IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Measure_Short_Name         IN   VARCHAR2
,p_Measure_Name               IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Description                IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Dimension1_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension2_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension3_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension4_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension5_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension6_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension7_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Unit_Of_Measure_Class      IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
-- Fix for 1850860 starts here
,p_actual_data_source_type    IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_actual_data_source         IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_function_name              IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_comparison_source          IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_increase_in_measure        IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
-- Fix for 1850860 ends here
,p_enable_link                IN   VARCHAR2 := c_hide_url -- 2440739
,p_obsolete                   IN   VARCHAR2 := FND_API.G_FALSE --3865711
,p_measure_type               IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_application_id             IN   NUMBER   := c_default_appl -- 2465354
,x_return_status              OUT NOCOPY VARCHAR2
,x_msg_count                  OUT NOCOPY VARCHAR2
,x_msg_data                   OUT NOCOPY VARCHAR2
);


Procedure Create_Performance_Measure
(p_Measure_ID                 IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Measure_Short_Name         IN   VARCHAR2
,p_Measure_Name               IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Description                IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Dimension1_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension2_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension3_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension4_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension5_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension6_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension7_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Unit_Of_Measure_Class      IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
--Fix for 1850860 starts here
,p_actual_data_source_type    IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_actual_data_source         IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_function_name        IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_comparison_source          IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_increase_in_measure        IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
-- Fix for 1850860 ends here
,p_enable_link                IN   VARCHAR2 := c_hide_url -- 2440739
,p_obsolete                   IN   VARCHAR2 := FND_API.G_FALSE --3865711
,p_measure_type               IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_application_id             IN   NUMBER   := c_default_appl --2465354
,x_return_status              OUT NOCOPY  VARCHAR2
,x_msg_count                  OUT NOCOPY  VARCHAR2
,x_msg_data                   OUT NOCOPY  VARCHAR2
);
--
Procedure Delete_target_levels
(P_TARGET_LEVEL_ID           IN NUMBER
,p_force_delete              IN NUMBER := 0 --gbhaloti #3148615
,P_TARGET_LEVEL_SHORT_NAME   IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,x_return_status             OUT NOCOPY VARCHAR2
,x_msg_count                 OUT NOCOPY VARCHAR2
,x_msg_data                  OUT NOCOPY VARCHAR2
);

Procedure Update_target_levels
(P_TARGET_LEVEL_ID                 IN NUMBER
,P_TARGET_LEVEL_SHORT_NAME         IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_TARGET_LEVEL_NAME               IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_DESCRIPTION                     IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_MEASURE_ID                      IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION1_LEVEL_ID             IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION2_LEVEL_ID             IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION3_LEVEL_ID             IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION4_LEVEL_ID             IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION5_LEVEL_ID             IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION6_LEVEL_ID             IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION7_LEVEL_ID             IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_WORKFLOW_ITEM_TYPE              IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_WORKFLOW_PROCESS_SHORT_NAME     IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_DEFAULT_NOTIFY_RESP_ID          IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DEFAULT_NOT_RESP_SHORT_NAME     IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_COMPUTING_FUNCTION_ID           IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_COMPUTING_FUNCTION_NAME         IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_REPORT_FUNCTION_ID              IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_UNIT_OF_MEASURE                 IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_SOURCE                          IN VARCHAR2
,p_IS_SEED_USER                    IN VARCHAR2 := 'N' --2465354
,x_return_status                   OUT NOCOPY VARCHAR2
,x_msg_count                       OUT NOCOPY VARCHAR2
,x_msg_data                        OUT NOCOPY VARCHAR2
);
--
Procedure Create_target_levels
(P_TARGET_LEVEL_ID               IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_TARGET_LEVEL_SHORT_NAME       IN VARCHAR2
,P_TARGET_LEVEL_NAME             IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_DESCRIPTION                   IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_MEASURE_ID                    IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION1_LEVEL_ID           IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION2_LEVEL_ID           IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION3_LEVEL_ID           IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION4_LEVEL_ID           IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION5_LEVEL_ID           IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION6_LEVEL_ID           IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION7_LEVEL_ID           IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_WORKFLOW_ITEM_TYPE            IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_WORKFLOW_PROCESS_SHORT_NAME   IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_DEFAULT_NOTIFY_RESP_ID        IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DEFAULT_NOT_RESP_SHORT_NAME   IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_COMPUTING_FUNCTION_ID         IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_COMPUTING_FUNCTION_NAME       IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_REPORT_FUNCTION_ID            IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_UNIT_OF_MEASURE               IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_SOURCE                        IN VARCHAR2
,p_IS_SEED_USER                  IN VARCHAR2 := 'N' --2465354
,x_return_status                 OUT NOCOPY VARCHAR2
,x_msg_count                     OUT NOCOPY VARCHAR2
,x_msg_data                      OUT NOCOPY VARCHAR2
);
--
Procedure Create_Measure_Security
(P_Target_Level_ID            IN NUMBER       := BIS_UTILITIES_PUB.G_NULL_NUM
,P_Target_Level_Short_Name    IN VARCHAR2     := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_Responsibility_ID          IN NUMBER       := BIS_UTILITIES_PUB.G_NULL_NUM
,P_Responsibility_Short_Name  IN VARCHAR2     := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_Is_Seed_User               IN VARCHAR2     := 'N' --2465354
,x_return_status              OUT NOCOPY VARCHAR2
,x_msg_count                  OUT NOCOPY VARCHAR2
,x_msg_data                   OUT NOCOPY VARCHAR2
);
--
Procedure Delete_Measure_Security
(P_Target_Level_ID            IN NUMBER       := BIS_UTILITIES_PUB.G_NULL_NUM
,P_Responsibility_ID          IN NUMBER       := BIS_UTILITIES_PUB.G_NULL_NUM
,x_return_status              OUT NOCOPY VARCHAR2
,x_msg_count                  OUT NOCOPY VARCHAR2
,x_msg_data                   OUT NOCOPY VARCHAR2
);
--
PROCEDURE CREATE_TARGET
(p_target_id                       IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_is_dbimeasure            	   IN NUMBER 	  := 0 --gbhaloti #3148615
,p_target_level_id		   IN NUMBER	  := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Target_Level_Short_Name         IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Target_Level_Name		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_plan_id			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_plan_name			   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim1_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim1_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim2_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim2_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim3_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim3_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim4_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim4_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim5_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim5_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim6_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim6_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim7_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim7_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_target			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_range1_low			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_range1_high			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_range2_low			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_range2_high			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_range3_low			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_range3_high			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_notify_resp1_id		   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_notify_resp1_short_name         IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_notify_resp1_name               IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_notify_resp2_id		   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_notify_resp2_short_name         IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_notify_resp2_name               IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_notify_resp3_id		   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_notify_resp3_short_name         IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_notify_resp3_name               IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,x_return_status		   OUT NOCOPY VARCHAR2
,x_msg_count                  OUt NOCOPY NUMBER
,x_msg_data                   OUT NOCOPY VARCHAR2
);
--

--
PROCEDURE DELETE_TARGET
(p_target_id                      IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Target_level_id                IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_target_level_short_name        IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,x_return_Status                  OUT NOCOPY VARCHAR2
,x_msg_count                      OUT NOCOPY NUMBER
,x_msg_Data                        OUT NOCOPY VARCHAR2
);
--
PROCEDURE GET_TIME_LEVEL_ID
(p_performance_measure_id         IN  NUMBER DEFAULT BIS_UTILITIES_PUB.G_NULL_NUM
,p_target_level_id                IN  NUMBER
,p_perf_measure_short_name        IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,p_target_level_short_name        IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,p_source                         IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,x_Sequence_no                    OUT NOCOPY NUMBER
,x_dim_level_id			  OUT NOCOPY NUMBER
,x_dim_level_short_name           OUT NOCOPY VARCHAR2
,x_dim_level_name                 OUT NOCOPY VARCHAR2
,x_return_status                   OUT NOCOPY VARCHAR2
,x_error_tbl                      OUT NOCOPY BIS_UTILITIES_PUB.ERROR_TBL_TYPE
);
--
PROCEDURE GET_TIME_LEVEL_ID
(p_performance_measure_id         IN  NUMBER DEFAULT BIS_UTILITIES_PUB.G_NULL_NUM
,p_target_level_id                IN  NUMBER
,p_perf_measure_short_name        IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,p_target_level_short_name        IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,x_Sequence_no                    OUT NOCOPY NUMBER
,x_dim_level_id                   OUT NOCOPY NUMBER
,x_dim_level_short_name           OUT NOCOPY VARCHAR2
,x_dim_level_name                 OUT NOCOPY VARCHAR2
,x_return_status                   OUT NOCOPY VARCHAR2
);
--
PROCEDURE GET_ORG_LEVEL_ID
(p_performance_measure_id         IN  NUMBER DEFAULT BIS_UTILITIES_PUB.G_NULL_NUM
,p_target_level_id                IN  NUMBER
,p_perf_measure_short_name        IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,p_target_level_short_name        IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,p_source                         IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,x_Sequence_no                    OUT NOCOPY NUMBER
,x_dim_level_id			  OUT NOCOPY NUMBER
,x_dim_level_short_name           OUT NOCOPY VARCHAR2
,x_dim_level_name                 OUT NOCOPY VARCHAR2
,x_return_status                   OUT NOCOPY VARCHAR2
,x_error_tbl                      OUT NOCOPY BIS_UTILITIES_PUB.ERROR_TBL_TYPE
);
--
PROCEDURE GET_ORG_LEVEL_ID
(p_performance_measure_id         IN  NUMBER DEFAULT BIS_UTILITIES_PUB.G_NULL_NUM
,p_target_level_id                IN  NUMBER
,p_perf_measure_short_name        IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,p_target_level_short_name        IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,x_sequence_no                    OUT NOCOPY NUMBER
,x_dim_level_id                   OUT NOCOPY NUMBER
,x_dim_level_short_name           OUT NOCOPY VARCHAR2
,x_dim_level_name                 OUT NOCOPY VARCHAR2
,x_return_status                   OUT NOCOPY VARCHAR2
);
--
PROCEDURE ADD_TO_FND_MSG_STACK
(p_error_tbl	IN	BIS_UTILITIES_PUB.ERROR_TBL_TYPE
,x_msg_count    OUT NOCOPY     NUMBER
,x_msg_data     OUT NOCOPY     VARCHAR2
,x_return_status   OUT NOCOPY     VARCHAR2
);
--added target level_id, changed name
FUNCTION BuildAlertRegURLTL
(p_measure_id           IN      NUMBER
,p_target_level_id      IN      NUMBER
,p_dim1_level_id        IN      NUMBER
,p_dim2_level_id        IN      NUMBER
,p_dim3_level_id        IN      NUMBER
,p_dim4_level_id        IN      NUMBER
,p_dim5_level_id        IN      NUMBER
,p_dim6_level_id        IN      NUMBER
,p_dim7_level_id        IN      NUMBER
)
RETURN VARCHAR2
;
--changed name
--added this function for targets schedulealert
FUNCTION  BuildAlertRegURLTarget
(p_measure_id                  IN   NUMBER := NULL
,p_plan_id		       IN   VARCHAR2 := NULL
,p_target_level_id  	       IN   NUMBER := NULL
,p_parameter1levelId	       IN   VARCHAR2 := NULL
,p_parameter1ValueId	       IN   VARCHAR2 := NULL
,p_parameter2levelId	       IN   VARCHAR2 := NULL
,p_parameter2ValueId	       IN   VARCHAR2 := NULL
,p_parameter3levelId           IN   VARCHAR2 := NULL
,p_parameter3ValueId           IN   VARCHAR2 := NULL
,p_parameter4levelId           IN   VARCHAR2 := NULL
,p_parameter4ValueId           IN   VARCHAR2 := NULL
,p_parameter5levelId           IN   VARCHAR2 := NULL
,p_parameter5ValueId           IN   VARCHAR2 := NULL
,p_parameter6levelId           IN   VARCHAR2 := NULL
,p_parameter6ValueId           IN   VARCHAR2 := NULL
,p_parameter7levelId           IN   VARCHAR2 := NULL
,p_parameter7ValueId           IN   VARCHAR2 := NULL
)
RETURN VARCHAR2
;
PROCEDURE GET_TARGET_DETAILS
(p_measure_id		      IN    NUMBER
,p_measure_short_name	      IN    VARCHAR2   DEFAULT NULL
,p_user_id		      IN    VARCHAR2
,p_responsibility_id          IN    VARCHAR2
,p_dim1_level_short_name      IN    VARCHAR2
,p_dim2_level_short_name      IN    VARCHAR2
,p_dim3_level_short_name      IN    VARCHAR2
,p_Dim4_level_short_name      IN    VARCHAR2
,p_dim5_level_short_name      IN    VARCHAR2
,p_dim6_level_short_name      IN    VARCHAR2
,p_dim7_level_short_name      IN    VARCHAR2
,p_dim1_level_value_id        IN    VARCHAR2
,P_dim2_level_value_id        IN    VARCHAR2
,p_dim3_level_Value_id        IN    VARCHAR2
,p_dim4_level_Value_id        IN    VARCHAR2
,p_dim5_level_Value_id        IN    VARCHAR2
,p_Dim6_level_value_id        IN    VARCHAR2
,p_dim7_level_Value_id        IN    VARCHAR2
,p_plan_id		      IN    NUMBER
,x_target_level_id            OUT NOCOPY   NUMBER
,x_target_level_short_name    OUT NOCOPY   VARCHAR2
,x_target_id                  OUT NOCOPY   NUMBER
,x_target_value               OUT NOCOPY   VARCHAR2
,x_dim1_level_name            OUT NOCOPY   VARCHAR2
,x_dim2_level_name            OUT NOCOPY   VARCHAR2
,x_dim3_level_name            OUT NOCOPY   VARCHAR2
,x_dim4_level_name            OUT NOCOPY   VARCHAR2
,x_dim5_level_name            OUT NOCOPY   VARCHAR2
,x_dim6_level_name            OUT NOCOPY   VARCHAR2
,x_dim7_level_name            OUT NOCOPY   VARCHAR2
,x_dim1_level_value_name      OUT NOCOPY   VARCHAR2
,x_dim2_level_value_name      OUT NOCOPY   VARCHAR2
,x_dim3_level_value_name      OUT NOCOPY   VARCHAR2
,x_dim4_level_value_name      OUT NOCOPY   VARCHAR2
,x_dim5_level_value_name      OUT NOCOPY   VARCHAR2
,x_dim6_level_value_name      OUT NOCOPY   VARCHAR2
,x_dim7_level_value_name      OUT NOCOPY   VARCHAR2
,x_dim1_level_id              OUT NOCOPY   NUMBER
,x_dim2_level_id              OUT NOCOPY   NUMBER
,x_dim3_level_id              OUT NOCOPY   NUMBER
,x_dim4_level_id              OUT NOCOPY   NUMBER
,x_dim5_level_id              OUT NOCOPY   NUMBER
,x_dim6_level_id              OUT NOCOPY   NUMBER
,x_dim7_level_id              OUT NOCOPY   NUMBER
,x_range1_low		      OUT NOCOPY   NUMBER
,x_range2_low                 OUT NOCOPY   NUMBER
,x_range3_low                 OUT NOCOPY   NUMBER
,x_range1_high                OUT NOCOPY   NUMBER
,x_range2_high                OUT NOCOPY   NUMBER
,x_range3_high                OUT NOCOPY   NUMBER
,x_notify_resp1_id            OUT NOCOPY   NUMBER
,x_notify_resp2_id            OUT NOCOPY   NUMBER
,x_notify_resp3_id            OUT NOCOPY   NUMBER
,x_notify_resp1_short_name    OUT NOCOPY   VARCHAR2
,x_notify_resp2_short_name    OUT NOCOPY   VARCHAR2
,x_notify_resp3_short_name    OUT NOCOPY   VARCHAR2
,x_notify_resp1_name          OUT NOCOPY   VARCHAR2
,x_notify_resp2_name          OUT NOCOPY   VARCHAR2
,x_notify_resp3_name          OUT NOCOPY   VARCHAR2
,x_show_subscribe_screen      OUT NOCOPY   VARCHAR2
,x_msg_count                  OUT NOCOPY   NUMBER
,x_return_status              OUT NOCOPY   VARCHAR2
,x_msg_data                   OUT NOCOPY   VARCHAR2
,x_measure_name               OUT NOCOPY   VARCHAR2
,x_plan_name                  OUT NOCOPY   VARCHAR2
,x_measure_id                 OUT NOCOPY   NUMBER
,x_unit_of_measure            OUT NOCOPY   VARCHAR2
,x_dim1_level_value_id        OUT NOCOPY   VARCHAR2
,x_dim2_level_value_id        OUT NOCOPY   VARCHAR2
,x_dim3_level_Value_id        OUT NOCOPY   VARCHAR2
,x_dim4_level_Value_id        OUT NOCOPY   VARCHAR2
,x_dim5_level_Value_id        OUT NOCOPY   VARCHAR2
,x_Dim6_level_value_id        OUT NOCOPY   VARCHAR2
,x_dim7_level_Value_id        OUT NOCOPY   VARCHAR2
,x_dim1_level_short_name      OUT NOCOPY   VARCHAR2
,x_dim2_level_short_name      OUT NOCOPY   VARCHAR2
,x_dim3_level_short_name      OUT NOCOPY   VARCHAR2
,x_Dim4_level_short_name      OUT NOCOPY   VARCHAR2
,x_dim5_level_short_name      OUT NOCOPY   VARCHAR2
,x_dim6_level_short_name      OUT NOCOPY   VARCHAR2
,x_dim7_level_short_name      OUT NOCOPY   VARCHAR2
,x_time_sequence_number       OUT NOCOPY   NUMBER
,x_org_sequence_number        OUT NOCOPY   NUMBER
);
PROCEDURE UPDATE_MEASURE_SECURITY
  (
    p_target_level_id     IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM,
    p_responsibilities    IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY VARCHAR2,
    x_msg_data            OUT NOCOPY VARCHAR2
  );
PROCEDURE GET_TARGET_LEVEL_NAMES
  (
    p_target_level_id     IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM,
    x_measure_name        OUT NOCOPY VARCHAR2,
    x_dim_names           OUT NOCOPY VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY VARCHAR2,
    x_msg_data            OUT NOCOPY VARCHAR2
  );

FUNCTION HAS_TARGET_ACCESS
(
  p_user_id IN NUMBER
 ,p_measure_id IN NUMBER
 ,p_target_level_id IN NUMBER
)
RETURN NUMBER;

-- Fix for 2126074 starts here

Procedure Retrieve_Performance_Measure
(p_Measure_ID                 IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Measure_Short_Name         IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Measure_Name               IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Description                IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Dimension1_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension2_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension3_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension4_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension5_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension6_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension7_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Unit_Of_Measure_Class      IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_actual_data_source_type    IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_actual_data_source         IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_function_name              IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_comparison_source          IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_increase_in_measure        IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,x_return_status              OUT NOCOPY  VARCHAR2
,x_msg_count                  OUT NOCOPY  VARCHAR2
,x_msg_data                   OUT NOCOPY  VARCHAR2
,x_Measure_ID                 OUT NOCOPY  NUMBER
,x_Measure_Short_Name         OUT NOCOPY  VARCHAR2
,x_Measure_Name               OUT NOCOPY  VARCHAR2
,x_Description                OUT NOCOPY  VARCHAR2
,x_Dimension1_ID              OUT NOCOPY  NUMBER
,x_Dimension2_ID              OUT NOCOPY  NUMBER
,x_Dimension3_ID              OUT NOCOPY  NUMBER
,x_Dimension4_ID              OUT NOCOPY  NUMBER
,x_Dimension5_ID              OUT NOCOPY  NUMBER
,x_Dimension6_ID              OUT NOCOPY  NUMBER
,x_Dimension7_ID              OUT NOCOPY  NUMBER
,x_Unit_Of_Measure_Class      OUT NOCOPY  VARCHAR2
,x_actual_data_source_type    OUT NOCOPY  VARCHAR2
,x_actual_data_source         OUT NOCOPY  VARCHAR2
--
,x_region_code                OUT NOCOPY  VARCHAR2
,x_attribute_code             OUT NOCOPY  VARCHAR2
--
,x_function_name              OUT NOCOPY  VARCHAR2
,x_comparison_source          OUT NOCOPY  VARCHAR2
,x_increase_in_measure        OUT NOCOPY  VARCHAR2);

-- Fix for 2126074 ends here

-- overloaded with enable_link param for bug 2440739
Procedure Retrieve_Performance_Measure
(p_Measure_ID                 IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Measure_Short_Name         IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Measure_Name               IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Description                IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Dimension1_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension2_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension3_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension4_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension5_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension6_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension7_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Unit_Of_Measure_Class      IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_actual_data_source_type    IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_actual_data_source         IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_function_name              IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_comparison_source          IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_increase_in_measure        IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_enable_link                IN   VARCHAR2 := c_hide_url
,x_return_status              OUT NOCOPY  VARCHAR2
,x_msg_count                  OUT NOCOPY  VARCHAR2
,x_msg_data                   OUT NOCOPY  VARCHAR2
,x_Measure_ID                 OUT NOCOPY  NUMBER
,x_Measure_Short_Name         OUT NOCOPY  VARCHAR2
,x_Measure_Name               OUT NOCOPY  VARCHAR2
,x_Description                OUT NOCOPY  VARCHAR2
,x_Dimension1_ID              OUT NOCOPY  NUMBER
,x_Dimension2_ID              OUT NOCOPY  NUMBER
,x_Dimension3_ID              OUT NOCOPY  NUMBER
,x_Dimension4_ID              OUT NOCOPY  NUMBER
,x_Dimension5_ID              OUT NOCOPY  NUMBER
,x_Dimension6_ID              OUT NOCOPY  NUMBER
,x_Dimension7_ID              OUT NOCOPY  NUMBER
,x_Unit_Of_Measure_Class      OUT NOCOPY  VARCHAR2
,x_actual_data_source_type    OUT NOCOPY  VARCHAR2
,x_actual_data_source         OUT NOCOPY  VARCHAR2
--
,x_region_code                OUT NOCOPY  VARCHAR2
,x_attribute_code             OUT NOCOPY  VARCHAR2
--
,x_function_name              OUT NOCOPY  VARCHAR2
,x_comparison_source          OUT NOCOPY  VARCHAR2
,x_increase_in_measure        OUT NOCOPY  VARCHAR2
,x_enable_link                OUT NOCOPY  VARCHAR2
);

END BIS_PMF_DEFINER_WRAPPER_PVT;

 

/
