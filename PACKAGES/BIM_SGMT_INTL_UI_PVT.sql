--------------------------------------------------------
--  DDL for Package BIM_SGMT_INTL_UI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_SGMT_INTL_UI_PVT" AUTHID CURRENT_USER AS
/* $Header: bimsiuis.pls 120.2 2005/09/23 04:44:14 sbassi noship $ */

PROCEDURE GET_SGMT_VALUE_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


PROCEDURE GET_SGMT_REVENUE_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_SGMT_SIZE_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                               x_custom_sql  OUT NOCOPY VARCHAR2,
                               x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_SGMT_AVG_TXN_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                               x_custom_sql  OUT NOCOPY VARCHAR2,
                               x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_CAMP_EFF_SQL	(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                               x_custom_sql  OUT NOCOPY VARCHAR2,
                               x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_CAMP_ACT_SQL	(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                               x_custom_sql  OUT NOCOPY VARCHAR2,
                               x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_CAMP_TREND_SQL (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                               x_custom_sql  OUT NOCOPY VARCHAR2,
                               x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_ACTIVE_CUST_SQL (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                               x_custom_sql  OUT NOCOPY VARCHAR2,
                               x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

FUNCTION GLb ( p_page_parameter_tbl    IN BIS_PMV_PAGE_PARAMETER_TBL,
				num  in number
			 )  RETURN VARCHAR2;


END BIM_SGMT_INTL_UI_PVT;

 

/
