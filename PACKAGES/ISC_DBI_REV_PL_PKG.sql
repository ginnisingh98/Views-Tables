--------------------------------------------------------
--  DDL for Package ISC_DBI_REV_PL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_REV_PL_PKG" AUTHID CURRENT_USER As
/* $Header: ISCRGBDS.pls 115.0 2003/11/20 02:30:08 gchien noship $ */

PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END ISC_DBI_REV_PL_PKG ;

 

/
