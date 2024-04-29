--------------------------------------------------------
--  DDL for Package ISC_DBI_SHIP_LATE_D_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_SHIP_LATE_D_PKG" AUTHID CURRENT_USER As
/* $Header: ISCRG68S.pls 115.3 2003/04/11 00:17:22 gchien ship $ */


PROCEDURE GET_SQL (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END ISC_DBI_SHIP_LATE_D_PKG ;

 

/
