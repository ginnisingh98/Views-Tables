--------------------------------------------------------
--  DDL for Package BIM_DBI_MKTG_MGMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_DBI_MKTG_MGMT_PVT" AUTHID CURRENT_USER AS
/* $Header: bimvsqls.pls 120.1 2005/09/19 00:45:21 arvikuma noship $ */

--FUNCTION GET_KPI_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL) return VARCHAR2 ;
PROCEDURE GET_KPI_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_CPL_KPI(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--FUNCTION GET_PO_RACK_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL) return VARCHAR2 ;
PROCEDURE GET_PO_RACK_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_CS_RACK_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--FUNCTION GET_CPL_GRAPH_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL) return VARCHAR2 ;

PROCEDURE GET_CPL_GRAPH_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
			  x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_TOP_LEADS_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_TOP_OPPS_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_TOP_EVEH_OPPS_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_TOP_CAMP_OPPS_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_TOP_EVEH_LEAD_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_TOP_CAMP_LEAD_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_CPL_RPL_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_rpl_cpl_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_LEAD_OPTY_CONV_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_MKTG_A_LEADS_SQL (
   p_page_parameter_tbl   IN              BIS_PMV_PAGE_PARAMETER_TBL,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_MKTG_NEW_LEADS_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
);

PROCEDURE GET_CAMP_START_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_EVEH_START_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_CSCH_START_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_RESP_SUM_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
);

PROCEDURE GET_RESP_RATE_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
);

PROCEDURE GET_WON_OPTY_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
);

PROCEDURE BIM_MKTG_LEAD_ACT_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
);

PROCEDURE GET_CAMP_DETL_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_CSCH_DETL_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

FUNCTION GET_BIM_TEST return VARCHAR2 ;
FUNCTION GET_DIM return VARCHAR2 ;
FUNCTION GET_DIM_PARAM return VARCHAR2 ;
FUNCTION GET_RESOURCE_ID return NUMBER ;


END BIM_DBI_MKTG_MGMT_PVT;

 

/
