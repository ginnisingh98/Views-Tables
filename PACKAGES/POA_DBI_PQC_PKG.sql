--------------------------------------------------------
--  DDL for Package POA_DBI_PQC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_PQC_PKG" 
/* $Header: poadbipqcs.pls 115.1 2004/01/28 22:35:40 mangupta noship $*/
AUTHID CURRENT_USER AS
  PROCEDURE status_sql(p_param          IN          BIS_PMV_PAGE_PARAMETER_TBL
                      ,x_custom_sql     OUT NOCOPY  VARCHAR2
                      ,x_custom_output  OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE trend_sql(p_param           IN          BIS_PMV_PAGE_PARAMETER_TBL
                     ,x_custom_sql      OUT NOCOPY  VARCHAR2
                     ,x_custom_output   OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE kpi_sql(p_param         IN          BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql    OUT NOCOPY  VARCHAR2
                   ,x_custom_output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE dtl_rpt_sql(p_param         IN          BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql    OUT NOCOPY  VARCHAR2
                   ,x_custom_output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);

END poa_dbi_pqc_pkg;

 

/
