--------------------------------------------------------
--  DDL for Package ISC_DBI_SHIP_LATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_SHIP_LATE_PKG" AUTHID CURRENT_USER As
/* $Header: ISCRG67S.pls 115.2 2002/12/26 23:18:23 scheung ship $ */

PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END ISC_DBI_SHIP_LATE_PKG ;

 

/
