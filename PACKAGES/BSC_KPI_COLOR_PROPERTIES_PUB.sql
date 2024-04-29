--------------------------------------------------------
--  DDL for Package BSC_KPI_COLOR_PROPERTIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_KPI_COLOR_PROPERTIES_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPKCPS.pls 120.1.12000000.1 2007/07/17 07:44:04 appldev noship $ */


/************************************************************************************
 ************************************************************************************/

PROCEDURE Update_Kpi_Color_Properties (
  p_commit              IN              VARCHAR2 := FND_API.G_FALSE
, p_objective_id	IN		BSC_KPIS_B.indicator%TYPE
, p_kpi_measure_id      IN      	BSC_KPI_ANALYSIS_MEASURES_B.kpi_measure_id%TYPE
, p_disable_color	IN		BSC_KPI_MEASURE_PROPS.disable_color%TYPE
, p_kpi_prototype_color	IN		BSC_KPI_MEASURE_PROPS.prototype_color_id%TYPE
, p_kpi_prototype_trend	IN		BSC_KPI_MEASURE_PROPS.prototype_trend_id%TYPE
, p_color_by_total	IN		BSC_KPI_MEASURE_PROPS.color_by_total%TYPE
, p_disable_trend	IN		BSC_KPI_MEASURE_PROPS.disable_trend%TYPE
, p_need_color_recalc	IN		VARCHAR2 := 'N'
, x_return_status       OUT NOCOPY     	VARCHAR2
, x_msg_count           OUT NOCOPY     	NUMBER
, x_msg_data            OUT NOCOPY     	VARCHAR2
);



/************************************************************************************
 ************************************************************************************/

PROCEDURE Update_Obj_Color_Properties (
  p_commit              	IN              VARCHAR2 := FND_API.G_FALSE
, p_objective_id		IN		BSC_KPIS_B.indicator%TYPE
, p_obj_prototype_color_id	IN		BSC_KPIS_B.prototype_color_id%TYPE
, p_obj_prototype_trend_id	IN		BSC_KPIS_B.prototype_trend_id%TYPE
, p_color_rollup_type		IN		BSC_KPIS_B.color_rollup_type%TYPE
, p_weighted_color_method	IN		BSC_KPIS_B.weighted_color_method%TYPE
, p_need_color_recalc		IN		VARCHAR2 := 'Y'
, x_return_status       	OUT NOCOPY     	VARCHAR2
, x_msg_count           	OUT NOCOPY     	NUMBER
, x_msg_data            	OUT NOCOPY     	VARCHAR2
);


/************************************************************************************
 ************************************************************************************/

PROCEDURE Create_Update_Kpi_Mes_Weights (
  p_commit              IN              VARCHAR2 := FND_API.G_FALSE
, p_objective_id	IN		BSC_KPIS_B.indicator%TYPE
, p_kpi_measure_id      IN      	BSC_KPI_ANALYSIS_MEASURES_B.kpi_measure_id%TYPE
, p_kpi_weight		IN		BSC_KPI_MEASURE_WEIGHTS.weight%TYPE
, x_return_status       OUT NOCOPY     	VARCHAR2
, x_msg_count           OUT NOCOPY     	NUMBER
, x_msg_data            OUT NOCOPY     	VARCHAR2
);


/************************************************************************************
 ************************************************************************************/

PROCEDURE Obj_Prototype_Flag_Change (
  p_objective_id	IN		BSC_KPIS_B.indicator%TYPE
, p_prototype_flag      IN      	NUMBER
, x_return_status       OUT NOCOPY     	VARCHAR2
, x_msg_count           OUT NOCOPY     	NUMBER
, x_msg_data            OUT NOCOPY     	VARCHAR2
);

/************************************************************************************
 ************************************************************************************/

PROCEDURE Kpi_Prototype_Flag_Change (
  p_objective_id	IN		BSC_KPIS_B.indicator%TYPE
, p_kpi_measure_id      IN      	BSC_KPI_ANALYSIS_MEASURES_B.kpi_measure_id%TYPE
, p_prototype_flag      IN      	NUMBER
, x_return_status       OUT NOCOPY     	VARCHAR2
, x_msg_count           OUT NOCOPY     	NUMBER
, x_msg_data            OUT NOCOPY     	VARCHAR2
);

/************************************************************************************
 ************************************************************************************/

PROCEDURE Change_Prototype_Flag (
  p_objective_id        IN		BSC_KPIS_B.indicator%TYPE
, p_kpi_measure_id      IN      	BSC_KPI_ANALYSIS_MEASURES_B.kpi_measure_id%TYPE
, p_prototype_flag      IN      	NUMBER
, x_return_status       OUT NOCOPY     	VARCHAR2
, x_msg_count           OUT NOCOPY     	NUMBER
, x_msg_data            OUT NOCOPY     	VARCHAR2
);


/************************************************************************************
 ************************************************************************************/

PROCEDURE Save_Disable_Color_Of_Kpi (
  p_commit              IN              VARCHAR2 := FND_API.G_FALSE
, p_objective_id	IN		BSC_KPIS_B.indicator%TYPE
, p_kpi_measure_id      IN      	BSC_KPI_ANALYSIS_MEASURES_B.kpi_measure_id%TYPE
, p_disable_color	IN		BSC_KPI_MEASURE_PROPS.disable_color%TYPE
, p_need_color_recalc	IN		VARCHAR2 := 'N'
, x_return_status       OUT NOCOPY     	VARCHAR2
, x_msg_count           OUT NOCOPY     	NUMBER
, x_msg_data            OUT NOCOPY     	VARCHAR2
);

END BSC_KPI_COLOR_PROPERTIES_PUB;

 

/
