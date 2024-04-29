--------------------------------------------------------
--  DDL for Package BSC_KPI_MEASURE_PROPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_KPI_MEASURE_PROPS_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPKMPS.pls 120.1.12000000.1 2007/07/17 07:44:07 appldev noship $ */

G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_KPI_MEASURE_PROPS_PUB';

C_TREND_UNACC_DECREASE  CONSTANT        NUMBER := 3;
TYPE kpi_measure_props_rec IS RECORD (
  objective_id           BSC_KPI_MEASURE_PROPS.indicator%TYPE
, kpi_measure_id         BSC_KPI_MEASURE_PROPS.kpi_measure_id%TYPE
, prototype_color        BSC_KPI_MEASURE_PROPS.prototype_color_id%TYPE
, prototype_trend        BSC_KPI_MEASURE_PROPS.prototype_trend_id%TYPE
, color_by_total         BSC_KPI_MEASURE_PROPS.color_by_total%TYPE
, disable_color          BSC_KPI_MEASURE_PROPS.disable_color%TYPE
, disable_trend          BSC_KPI_MEASURE_PROPS.disable_trend%TYPE
, apply_color_flag       BSC_KPI_MEASURE_PROPS.apply_color_flag%TYPE
, default_calculation    BSC_KPI_MEASURE_PROPS.default_calculation%TYPE
, created_by             BSC_KPI_MEASURE_PROPS.created_by%TYPE
, creation_date          BSC_KPI_MEASURE_PROPS.creation_date%TYPE
, last_updated_by        BSC_KPI_MEASURE_PROPS.last_updated_by%TYPE
, last_update_date       BSC_KPI_MEASURE_PROPS.last_update_date%TYPE
, last_update_login      BSC_KPI_MEASURE_PROPS.last_update_login%TYPE
);

/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Kpi_Measure_Props (
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
, p_kpi_measure_rec     IN            BSC_KPI_MEASURE_PROPS_PUB.kpi_measure_props_rec
, p_cascade_shared      IN            BOOLEAN := TRUE
, x_return_status       OUT NOCOPY    VARCHAR2
, x_msg_count           OUT NOCOPY    NUMBER
, x_msg_data            OUT NOCOPY    VARCHAR2
) ;

PROCEDURE Create_Default_Kpi_Meas_Props (
  p_commit          IN            VARCHAR2 := FND_API.G_FALSE
, p_objective_id    IN            NUMBER
, p_kpi_measure_id  IN            NUMBER
, p_cascade_shared  IN            BOOLEAN := TRUE
, x_return_status   OUT NOCOPY    VARCHAR2
, x_msg_count       OUT NOCOPY    NUMBER
, x_msg_data        OUT NOCOPY    VARCHAR2
);

/************************************************************************************
 ************************************************************************************/
PROCEDURE Update_Kpi_Measure_Props (
  p_commit              IN             VARCHAR2 := FND_API.G_FALSE
, p_kpi_measure_rec     IN             BSC_KPI_MEASURE_PROPS_PUB.kpi_measure_props_rec
, p_cascade_shared      IN             BOOLEAN := TRUE
, x_return_status       OUT NOCOPY     VARCHAR2
, x_msg_count           OUT NOCOPY     NUMBER
, x_msg_data            OUT NOCOPY     VARCHAR2
);

/************************************************************************************
************************************************************************************/
PROCEDURE Delete_Kpi_Measure_Props (
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
, p_objective_id        IN             NUMBER
, p_kpi_measure_id      IN             NUMBER
, p_cascade_shared      IN             BOOLEAN := TRUE
, x_return_status       OUT NOCOPY     VARCHAR2
, x_msg_count           OUT NOCOPY     NUMBER
, x_msg_data            OUT NOCOPY     VARCHAR2
) ;

/************************************************************************************
************************************************************************************/
PROCEDURE Delete_Obj_Kpi_Measure_Props (
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
, p_objective_id        IN             NUMBER
, p_cascade_shared      IN             BOOLEAN := TRUE
, x_return_status       OUT NOCOPY     VARCHAR2
, x_msg_count           OUT NOCOPY     NUMBER
, x_msg_data            OUT NOCOPY     VARCHAR2
) ;

/************************************************************************************
************************************************************************************/
PROCEDURE Retrieve_Kpi_Measure_Props (
  p_objective_id        IN             NUMBER
, p_kpi_measure_id      IN             NUMBER
, x_kpi_measure_rec     OUT NOCOPY     BSC_KPI_MEASURE_PROPS_PUB.kpi_measure_props_rec
, x_return_status       OUT NOCOPY     VARCHAR2
, x_msg_count           OUT NOCOPY     NUMBER
, x_msg_data            OUT NOCOPY     VARCHAR2
) ;

/************************************************************************************
************************************************************************************/
FUNCTION get_shared_obj_kpi_measure (
  p_objective_id         IN NUMBER
, p_kpi_measure_id       IN NUMBER
, p_shared_objective_id  IN NUMBER
) RETURN NUMBER;


END BSC_KPI_MEASURE_PROPS_PUB;

 

/
