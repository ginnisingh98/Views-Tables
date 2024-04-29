--------------------------------------------------------
--  DDL for Package ENI_DBI_TOO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_TOO_PKG" AUTHID CURRENT_USER AS
/*$Header: ENITOOPS.pls 115.0 2004/01/23 05:36:03 adhachol noship $*/

PROCEDURE get_sql
(
	p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
        x_custom_sql OUT NOCOPY VARCHAR2,
        x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
) ;

END ENI_DBI_TOO_PKG;

 

/
