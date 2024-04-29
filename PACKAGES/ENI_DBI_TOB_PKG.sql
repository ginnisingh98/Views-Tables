--------------------------------------------------------
--  DDL for Package ENI_DBI_TOB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_TOB_PKG" AUTHID CURRENT_USER AS
/*$Header: ENITOBPS.pls 115.0 2003/10/31 13:59:16 adhachol noship $*/

PROCEDURE get_sql
(
	p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
        x_custom_sql OUT NOCOPY VARCHAR2,
        x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
) ;

END ENI_DBI_TOB_PKG;

 

/
