--------------------------------------------------------
--  DDL for Package POA_DBI_RET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_RET_PKG" AUTHID CURRENT_USER AS
/* $Header: poadbirets.pls 115.1 2003/06/25 01:00:33 iali noship $ */
--
PROCEDURE status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql OUT NOCOPY VARCHAR2
                    ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
PROCEDURE trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql  OUT  NOCOPY VARCHAR2
                   ,x_custom_output OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
PROCEDURE rtn_rsn_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                     ,x_custom_sql OUT  NOCOPY VARCHAR2
                     ,x_custom_output OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
PROCEDURE kpi_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                 ,x_custom_sql  OUT  NOCOPY VARCHAR2
                 ,x_custom_output OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
END poa_dbi_ret_pkg;

 

/
