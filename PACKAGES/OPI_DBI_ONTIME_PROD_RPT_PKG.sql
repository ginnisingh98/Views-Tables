--------------------------------------------------------
--  DDL for Package OPI_DBI_ONTIME_PROD_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_ONTIME_PROD_RPT_PKG" AUTHID CURRENT_USER AS
 /*$Header: OPIDOTPRPTS.pls 120.1 2005/08/11 03:16 sberi noship $ */
 PROCEDURE GET_ONTIME_PROD_SQL(
       p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

 END OPI_DBI_ONTIME_PROD_RPT_PKG;

 

/
