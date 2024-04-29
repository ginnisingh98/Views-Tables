--------------------------------------------------------
--  DDL for Package BSC_KPI_MEASURE_PROPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_KPI_MEASURE_PROPS_PVT" AUTHID CURRENT_USER AS
/* $Header: BSCVKMPS.pls 120.0.12000000.1 2007/07/17 07:44:47 appldev noship $ */

G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_KPI_MEASURE_PROPS_PVT';

/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Kpi_Measure_Props (
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
, p_kpi_measure_rec     IN            BSC_KPI_MEASURE_PROPS_PUB.kpi_measure_props_rec
, x_return_status       OUT NOCOPY    VARCHAR2
, x_msg_count           OUT NOCOPY    NUMBER
, x_msg_data            OUT NOCOPY    VARCHAR2
) ;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Update_Kpi_Measure_Props (
  p_commit              IN             VARCHAR2 := FND_API.G_FALSE
, p_kpi_measure_rec     IN             BSC_KPI_MEASURE_PROPS_PUB.kpi_measure_props_rec
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
, x_return_status       OUT NOCOPY     VARCHAR2
, x_msg_count           OUT NOCOPY     NUMBER
, x_msg_data            OUT NOCOPY     VARCHAR2
) ;

/************************************************************************************
************************************************************************************/
PROCEDURE Delete_Obj_Kpi_Measure_Props (
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
, p_objective_id        IN             NUMBER
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


END BSC_KPI_MEASURE_PROPS_PVT;

 

/
