--------------------------------------------------------
--  DDL for Package OPI_DBI_CURR_VAR_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_CURR_VAR_RPT_PKG" 
/*$Header: OPIDCUVRPTS.pls 115.0 2003/06/16 17:52:43 ltong noship $ */
AUTHID CURRENT_USER as

 PROCEDURE curr_status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL, x_custom_sql  OUT NOCOPY VARCHAR2, x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

end opi_dbi_curr_var_rpt_pkg;

 

/
