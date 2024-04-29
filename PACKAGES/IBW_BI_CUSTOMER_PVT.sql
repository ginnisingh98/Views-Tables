--------------------------------------------------------
--  DDL for Package IBW_BI_CUSTOMER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBW_BI_CUSTOMER_PVT" AUTHID CURRENT_USER AS
/* $Header: ibwbcuss.pls 120.2 2005/09/25 07:57 narao noship $ */

PROCEDURE GET_CUST_ACQUIS_TREND_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL);

PROCEDURE GET_CUST_ACTY_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL);

PROCEDURE GET_CUST_ACTY_TREND_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL);

END IBW_BI_CUSTOMER_PVT;

 

/
