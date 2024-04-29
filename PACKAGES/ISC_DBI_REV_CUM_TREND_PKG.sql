--------------------------------------------------------
--  DDL for Package ISC_DBI_REV_CUM_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_REV_CUM_TREND_PKG" AUTHID CURRENT_USER As
/* $Header: ISCRGBNS.pls 115.0 2004/06/15 22:29:27 chu noship $ */

PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END ISC_DBI_REV_CUM_TREND_PKG ;

 

/
