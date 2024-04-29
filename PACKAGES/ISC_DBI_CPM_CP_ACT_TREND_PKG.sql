--------------------------------------------------------
--  DDL for Package ISC_DBI_CPM_CP_ACT_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_CPM_CP_ACT_TREND_PKG" AUTHID CURRENT_USER AS
/* $Header: ISCRGBMS.pls 115.0 2004/02/15 08:33:48 scheung noship $ */

PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL);

END ISC_DBI_CPM_CP_ACT_TREND_PKG;

 

/
