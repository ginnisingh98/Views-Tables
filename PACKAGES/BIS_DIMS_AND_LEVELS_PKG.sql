--------------------------------------------------------
--  DDL for Package BIS_DIMS_AND_LEVELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_DIMS_AND_LEVELS_PKG" AUTHID CURRENT_USER AS
/* $Header: BISKDDLS.pls 120.0 2005/06/01 15:50:50 appldev noship $ */


FUNCTION bis_kpi_report ( p_params IN BIS_PMV_PAGE_PARAMETER_TBL  )
RETURN VARCHAR2;

FUNCTION bis_measure_report ( p_params IN BIS_PMV_PAGE_PARAMETER_TBL  )
RETURN VARCHAR2;

FUNCTION bis_levels_report ( p_params IN BIS_PMV_PAGE_PARAMETER_TBL  )
RETURN VARCHAR2;

FUNCTION bis_levels_details_report ( p_params IN BIS_PMV_PAGE_PARAMETER_TBL  )
RETURN VARCHAR2;

FUNCTION bis_dimensions_report ( p_params IN BIS_PMV_PAGE_PARAMETER_TBL  )
RETURN VARCHAR2;

FUNCTION get_level_names ( kpi_id IN NUMBER )
RETURN VARCHAR2;

FUNCTION get_kpi_names ( lvl_id IN NUMBER )
RETURN VARCHAR2;


END BIS_DIMS_AND_LEVELS_PKG;

 

/
