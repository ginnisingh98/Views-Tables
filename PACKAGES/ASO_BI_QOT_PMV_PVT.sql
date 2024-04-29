--------------------------------------------------------
--  DDL for Package ASO_BI_QOT_PMV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_BI_QOT_PMV_PVT" AUTHID CURRENT_USER AS
/* $Header: asovbiqpmvs.pls 115.5 2002/11/28 13:22:08 oanandam noship $ */

  PROCEDURE GET_OPEN_QUOTE_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL
			    );

  PROCEDURE GET_QUOTE_CONVERSION_sql(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL
                            );

  PROCEDURE Get_New_Conv_Quote_Sql (
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL
                            );

  PROCEDURE Get_Open_Quote_Graph_Sql(
                            p_pmv_parameters  IN  BIS_PMV_PAGE_PARAMETER_TBL,
                            x_custom_sql      OUT NOCOPY VARCHAR2,
                            x_custom_output   OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
                                   );

  PROCEDURE GET_QUOTE_TO_ORDER_GRAPH_SQL(
                                      p_pmv_parameters  IN BIS_PMV_PAGE_PARAMETER_TBL,
                                      x_custom_sql      OUT NOCOPY VARCHAR2,
                                      x_custom_output   OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
                                      );

END ASO_BI_QOT_PMV_PVT;

 

/
