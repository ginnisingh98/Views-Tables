--------------------------------------------------------
--  DDL for Package BSC_COLOR_CALC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_COLOR_CALC_UTIL" AUTHID CURRENT_USER AS
/* $Header: BSCCUTLS.pls 120.1.12000000.1 2007/07/17 07:43:39 appldev noship $ */

DEFAULT_KPI       CONSTANT  VARCHAR2(11) := 'DEFAULT_KPI';
BEST              CONSTANT  VARCHAR2(5)  := 'BEST';
WORST             CONSTANT  VARCHAR2(5)  := 'WORST';
MOST_FREQUENT     CONSTANT  VARCHAR2(13) := 'MOST_FREQUENT';
WEIGHTED_AVERAGE  CONSTANT  VARCHAR2(16) := 'WEIGHTED_AVERAGE';

TYPE Threshold_Prop IS RECORD (
  threshold  NUMBER
, color_id   bsc_color_ranges.color_id%TYPE
);

TYPE Threshold_Prop_Table IS TABLE OF Threshold_Prop
  INDEX BY BINARY_INTEGER;

PROCEDURE Calc_Obj_Color_By_Default_Kpi (
  p_objective_color_rec  IN BSC_UPDATE_COLOR.t_objective_color_rec
 ,x_kpi_measure_id       OUT NOCOPY NUMBER
 ,x_color_flag           OUT NOCOPY BOOLEAN
);

PROCEDURE Calc_Obj_Color_By_Single_Kpi (
  p_objective_color_rec  IN BSC_UPDATE_COLOR.t_objective_color_rec
 ,p_rollup_type          IN bsc_kpis_b.color_rollup_type%TYPE
 ,x_kpi_measure_id       OUT NOCOPY NUMBER
 ,x_color_flag           OUT NOCOPY BOOLEAN
);

FUNCTION Calc_Obj_Color_By_Weights (
  p_objective_color_rec  IN BSC_UPDATE_COLOR.t_objective_color_rec
)
RETURN BOOLEAN;

FUNCTION Get_Kpi_Measure_Threshold (
  p_indicator       IN NUMBER
, p_kpi_measure_id  IN NUMBER
)
RETURN Threshold_Prop_Table;

FUNCTION Get_Obj_Color_Rollup_Type (
  p_objective_id  IN NUMBER
)
RETURN VARCHAR2;

FUNCTION Get_Default_Kpi_Measure_Id (
  p_objective_id  IN NUMBER
)
RETURN NUMBER;

END BSC_COLOR_CALC_UTIL;

 

/
