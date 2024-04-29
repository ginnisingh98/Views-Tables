--------------------------------------------------------
--  DDL for Package ISC_DBI_DAYS_SHIP_AGING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_DAYS_SHIP_AGING_PKG" AUTHID CURRENT_USER AS
/* $Header: ISCRG93S.pls 115.1 2003/06/07 01:40:15 chu noship $ */

  PROCEDURE Get_Sql (	p_param 	IN 		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output OUT NOCOPY 	BIS_QUERY_ATTRIBUTES_TBL);

END ISC_DBI_DAYS_SHIP_AGING_PKG ;

 

/
