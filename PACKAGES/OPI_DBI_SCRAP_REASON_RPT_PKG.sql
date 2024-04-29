--------------------------------------------------------
--  DDL for Package OPI_DBI_SCRAP_REASON_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_SCRAP_REASON_RPT_PKG" AUTHID CURRENT_USER AS
 /*$Header: OPIDSBRRPTS.pls 120.0 2005/09/18 22:09 sberi noship $ */
 PROCEDURE GET_SCRAP_REASON_SQL(
       p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

 END OPI_DBI_SCRAP_REASON_RPT_PKG;

 

/
