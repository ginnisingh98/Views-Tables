--------------------------------------------------------
--  DDL for Package BIM_DBI_BGT_MGMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_DBI_BGT_MGMT_PVT" AUTHID CURRENT_USER AS
/* $Header: bimvbgts.pls 115.0 2004/01/19 21:41:55 amyu noship $ */

PROCEDURE GET_BGT_SUM_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_BGT_CAT_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_BGT_UTL_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
FUNCTION GET_DIM return VARCHAR2 ;
FUNCTION GET_RESOURCE_ID return NUMBER ;


END BIM_DBI_BGT_MGMT_PVT;

 

/
