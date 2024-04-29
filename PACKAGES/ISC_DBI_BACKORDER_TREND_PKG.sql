--------------------------------------------------------
--  DDL for Package ISC_DBI_BACKORDER_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_BACKORDER_TREND_PKG" AUTHID CURRENT_USER AS
/* $Header: ISCRGAWS.pls 115.0 2003/06/16 18:12:14 chu noship $ */

PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL);

END ISC_DBI_BACKORDER_TREND_PKG ;

 

/
