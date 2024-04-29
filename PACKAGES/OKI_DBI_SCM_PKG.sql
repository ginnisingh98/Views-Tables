--------------------------------------------------------
--  DDL for Package OKI_DBI_SCM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DBI_SCM_PKG" AUTHID CURRENT_USER As
/* $Header: OKIRKPIS.pls 115.5 2003/04/25 18:25:56 brrao noship $ */

PROCEDURE GET_KPI_BALANCE_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_KPI_OTHERS_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_KPI_RATES_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_CBALANCE_TREND_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
END OKI_DBI_SCM_PKG ;

 

/
