--------------------------------------------------------
--  DDL for Package POA_DBI_UFR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_UFR_PKG" 
/* $Header: poadbiufrs.pls 120.0 2005/06/01 15:00:07 appldev noship $ */
AUTHID CURRENT_USER AS


  PROCEDURE amt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
  PROCEDURE sum_rpt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
  PROCEDURE status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                       x_custom_sql  OUT NOCOPY VARCHAR2,
                       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
  PROCEDURE dtl_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                       x_custom_sql  OUT NOCOPY VARCHAR2,
                       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
  PROCEDURE age_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                       x_custom_sql  OUT NOCOPY VARCHAR2,
                       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
END poa_dbi_ufr_pkg;

 

/
