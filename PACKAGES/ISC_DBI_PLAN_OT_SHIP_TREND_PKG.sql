--------------------------------------------------------
--  DDL for Package ISC_DBI_PLAN_OT_SHIP_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_PLAN_OT_SHIP_TREND_PKG" AUTHID CURRENT_USER As
/* $Header: ISCRGATS.pls 115.0 2003/07/25 21:22:03 gchien noship $ */

PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END ISC_DBI_PLAN_OT_SHIP_TREND_PKG ;

 

/