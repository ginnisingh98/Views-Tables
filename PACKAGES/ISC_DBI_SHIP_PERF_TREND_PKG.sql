--------------------------------------------------------
--  DDL for Package ISC_DBI_SHIP_PERF_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_SHIP_PERF_TREND_PKG" AUTHID CURRENT_USER As
/* $Header: ISCRG66S.pls 115.3 2002/12/26 23:17:24 scheung ship $ */


PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END ISC_DBI_SHIP_PERF_TREND_PKG ;

 

/
