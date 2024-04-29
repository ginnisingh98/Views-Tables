--------------------------------------------------------
--  DDL for Package ISC_DBI_FULF_PERF_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_FULF_PERF_TREND_PKG" AUTHID CURRENT_USER AS
/* $Header: ISCRG98S.pls 115.0 2003/07/03 23:52:10 scheung noship $ */

PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL);

END ISC_DBI_FULF_PERF_TREND_PKG;

 

/
