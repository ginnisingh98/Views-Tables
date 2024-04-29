--------------------------------------------------------
--  DDL for Package BIM_I_LEAD_MGMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_I_LEAD_MGMT_PVT" AUTHID CURRENT_USER AS
/* $Header: bimvldis.pls 120.0 2005/05/31 13:15:27 appldev noship $ */


   PROCEDURE GET_KPI_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

   PROCEDURE GET_LEAD_AGE_KPI_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

   PROCEDURE GET_LEAD_ACT_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

   PROCEDURE GET_LEAD_AGING_QU_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE GET_LEAD_AGING_SG_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE GET_LEAD_OPP_CHART_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
  PROCEDURE GET_LEAD_QUALITY_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
  PROCEDURE GET_LEAD_CONV_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
  PROCEDURE GET_LEAD_CONV_P_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
 PROCEDURE GET_LEAD_DETAIL_SQL (p_page_parameter_tbl    in          BIS_PMV_PAGE_PARAMETER_TBL,
		      x_custom_sql            OUT NOCOPY  VARCHAR2,
		      x_custom_output         OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_LEAD_CAMP_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


   FUNCTION GET_SALES_GROUP_ID RETURN VARCHAR2;
   FUNCTION get_params RETURN varchar2;
   FUNCTION get_params_new RETURN varchar2;
   PROCEDURE TEST_KPI_SQL;
   PROCEDURE RESET_ATTRIBUTES;
   FUNCTION get_dummy_sql
   RETURN varchar2;
   FUNCTION GLbl( p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL,colno in number ) RETURN VARCHAR2;



END;

 

/
