--------------------------------------------------------
--  DDL for Package POA_DBI_CUT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_CUT_PKG" 
/* $Header: poadbicuts.pls 120.1 2005/09/14 05:38:00 sriswami noship $*/


AUTHID CURRENT_USER AS
  PROCEDURE status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
  PROCEDURE con_rpt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
  PROCEDURE ncp_rpt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
  PROCEDURE pcl_rpt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
 PROCEDURE pop_trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
 PROCEDURE trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
 PROCEDURE kpi_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
 PROCEDURE pie_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
 PROCEDURE doctype_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                       x_custom_sql  OUT NOCOPY VARCHAR2,
                       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END poa_dbi_cut_pkg;

 

/
