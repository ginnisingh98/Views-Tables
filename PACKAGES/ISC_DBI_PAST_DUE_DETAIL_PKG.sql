--------------------------------------------------------
--  DDL for Package ISC_DBI_PAST_DUE_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_PAST_DUE_DETAIL_PKG" AUTHID CURRENT_USER AS
/* $Header: ISCRG76S.pls 115.2 2002/12/26 23:24:32 scheung noship $ */

PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL);

END ISC_DBI_PAST_DUE_DETAIL_PKG ;

 

/
