--------------------------------------------------------
--  DDL for Package POA_DBI_APM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_APM_PKG" AUTHID CURRENT_USER as
/* $Header: poadbiapmis.pls 115.4 2003/11/13 14:24:03 sriswami noship $ */


 PROCEDURE status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
 PROCEDURE trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY  VARCHAR2,
                      x_custom_output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);
 PROCEDURE kpi_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
end poa_dbi_apm_pkg;

 

/
