--------------------------------------------------------
--  DDL for Package POA_DBI_NCP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_NCP_PKG" 
/* $Header: poadbincps.pls 115.3 2003/11/13 14:25:30 sriswami noship $ */

AUTHID CURRENT_USER AS
  PROCEDURE status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY  VARCHAR2,
                      x_custom_output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);

END poa_dbi_ncp_pkg;

 

/
