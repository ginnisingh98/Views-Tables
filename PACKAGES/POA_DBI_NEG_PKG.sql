--------------------------------------------------------
--  DDL for Package POA_DBI_NEG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_NEG_PKG" AUTHID CURRENT_USER AS
/* $Header: poadbinegs.pls 120.0 2005/09/30 11:33:15 sriswami noship $ */
--
PROCEDURE status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql OUT NOCOPY VARCHAR2
                    ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
PROCEDURE awd_status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql OUT NOCOPY VARCHAR2
                    ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
PROCEDURE avg_cycle_time_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql OUT NOCOPY VARCHAR2
                    ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
PROCEDURE realized_status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql OUT NOCOPY VARCHAR2
                    ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
PROCEDURE awd_trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql  OUT  NOCOPY VARCHAR2
                   ,x_custom_output OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
PROCEDURE avg_cycle_trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql  OUT  NOCOPY VARCHAR2
                   ,x_custom_output OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
PROCEDURE prj_svng_trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql  OUT  NOCOPY VARCHAR2
                   ,x_custom_output OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
PROCEDURE prj_svng_ln_trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql  OUT  NOCOPY VARCHAR2
                   ,x_custom_output OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
PROCEDURE real_svng_trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql  OUT  NOCOPY VARCHAR2
                   ,x_custom_output OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
PROCEDURE neg_po_trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql  OUT  NOCOPY VARCHAR2
                   ,x_custom_output OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
PROCEDURE dtl_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql  OUT  NOCOPY VARCHAR2
                   ,x_custom_output OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
FUNCTION get_dtl_filter(p_doctype_id IN VARCHAR2, show_rfi IN VARCHAR2) return VARCHAR2;
END poa_dbi_neg_pkg;

 

/
