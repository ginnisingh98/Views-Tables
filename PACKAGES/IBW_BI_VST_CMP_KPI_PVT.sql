--------------------------------------------------------
--  DDL for Package IBW_BI_VST_CMP_KPI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBW_BI_VST_CMP_KPI_PVT" AUTHID CURRENT_USER AS
/* $Header: ibwbvcks.pls 120.1 2005/09/25 08:03 narao noship $ */

PROCEDURE GET_VISTR_CONV_TRND_SQL (
                                     p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                                     x_custom_sql     OUT NOCOPY VARCHAR2,
                                     x_custom_output  OUT NOCOPY bis_query_attributes_TBL
                                   );


PROCEDURE GET_VISIT_TREND_SQL(
                               p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                               x_custom_sql     OUT NOCOPY VARCHAR2,
                               x_custom_output  OUT NOCOPY bis_query_attributes_TBL
                             );

PROCEDURE GET_WEB_CAMPAIGN_SQL
                             (
                              p_param         IN  BIS_PMV_PAGE_PARAMETER_TBL,
                              x_custom_sql    OUT NOCOPY VARCHAR2,
                              x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
                             );

PROCEDURE GET_KPI_SQL(
                      p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                      x_custom_sql     OUT NOCOPY VARCHAR2,
                      x_custom_output  OUT NOCOPY bis_query_attributes_TBL
                     );

END IBW_BI_VST_CMP_KPI_PVT;

 

/
