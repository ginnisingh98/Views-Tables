--------------------------------------------------------
--  DDL for Package ISC_DBI_BOOK_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_BOOK_DETAIL_PKG" AUTHID CURRENT_USER AS
/* $Header: ISCRGB9S.pls 115.0 2003/11/12 02:59:48 chu noship $ */

PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL);

END ISC_DBI_BOOK_DETAIL_PKG;

 

/
