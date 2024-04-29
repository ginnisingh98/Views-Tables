--------------------------------------------------------
--  DDL for Package POA_DBI_IAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_IAP_PKG" AUTHID CURRENT_USER AS
/* $Header: poadbiavgprs.pls 120.0 2005/09/29 15:42 nnewadka noship $ */
--
PROCEDURE status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql  OUT  NOCOPY VARCHAR2
                   ,x_custom_output OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE iapd_rpt_sql (p_param in BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql  OUT  NOCOPY VARCHAR2
                   ,x_custom_output OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE iapd_dtl_sql (p_param in BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql  OUT  NOCOPY VARCHAR2
                   ,x_custom_output OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE iap_trend_rpt_sql (p_param in BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql  OUT  NOCOPY VARCHAR2
                   ,x_custom_output OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END poa_dbi_iap_pkg ;

 

/
