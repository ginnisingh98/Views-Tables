--------------------------------------------------------
--  DDL for Package BSC_KPI_MEASURE_WEIGHTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_KPI_MEASURE_WEIGHTS_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPKMWS.pls 120.0.12000000.1 2007/07/17 07:44:11 appldev noship $ */

G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_KPI_MEASURE_WEIGHTS_PUB';

TYPE kpi_measure_weights_rec IS RECORD (
  objective_id           BSC_KPI_MEASURE_WEIGHTS.indicator%TYPE
, kpi_measure_id         BSC_KPI_MEASURE_WEIGHTS.kpi_measure_id%TYPE
, weight                 BSC_KPI_MEASURE_WEIGHTS.weight%TYPE
, created_by             BSC_KPI_MEASURE_WEIGHTS.created_by%TYPE
, creation_date          BSC_KPI_MEASURE_WEIGHTS.creation_date%TYPE
, last_updated_by        BSC_KPI_MEASURE_WEIGHTS.last_updated_by%TYPE
, last_update_date       BSC_KPI_MEASURE_WEIGHTS.last_update_date%TYPE
, last_update_login      BSC_KPI_MEASURE_WEIGHTS.last_update_login%TYPE
);

/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Kpi_Measure_Weights (
  p_commit                   IN            VARCHAR2 := FND_API.G_FALSE
, p_kpi_measure_weights_rec  IN            BSC_KPI_MEASURE_WEIGHTS_PUB.kpi_measure_weights_rec
, p_cascade_shared           IN            BOOLEAN := TRUE
, x_return_status            OUT NOCOPY    VARCHAR2
, x_msg_count                OUT NOCOPY    NUMBER
, x_msg_data                 OUT NOCOPY    VARCHAR2
) ;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Update_Kpi_Measure_Weights (
  p_commit                   IN             VARCHAR2 := FND_API.G_FALSE
, p_kpi_measure_weights_rec  IN             BSC_KPI_MEASURE_WEIGHTS_PUB.kpi_measure_weights_rec
, p_cascade_shared           IN             BOOLEAN := TRUE
, x_return_status            OUT NOCOPY     VARCHAR2
, x_msg_count                OUT NOCOPY     NUMBER
, x_msg_data                 OUT NOCOPY     VARCHAR2
);

/************************************************************************************
************************************************************************************/
PROCEDURE Del_Kpi_Measure_Weights (
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
PROCEDURE Del_Obj_Kpi_Measure_Weights (
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
, p_objective_id        IN             NUMBER
, p_cascade_shared      IN             BOOLEAN := TRUE
, x_return_status       OUT NOCOPY     VARCHAR2
, x_msg_count           OUT NOCOPY     NUMBER
, x_msg_data            OUT NOCOPY     VARCHAR2
) ;

/************************************************************************************
************************************************************************************/
PROCEDURE Retrieve_Kpi_Measure_Weights (
  p_objective_id             IN             NUMBER
, p_kpi_measure_id           IN             NUMBER
, x_kpi_measure_weights_rec  OUT NOCOPY     BSC_KPI_MEASURE_WEIGHTS_PUB.kpi_measure_weights_rec
, x_return_status            OUT NOCOPY     VARCHAR2
, x_msg_count                OUT NOCOPY     NUMBER
, x_msg_data                 OUT NOCOPY     VARCHAR2
) ;


END BSC_KPI_MEASURE_WEIGHTS_PUB;

 

/
