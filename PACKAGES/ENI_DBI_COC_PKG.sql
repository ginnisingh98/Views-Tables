--------------------------------------------------------
--  DDL for Package ENI_DBI_COC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_COC_PKG" AUTHID CURRENT_USER AS
/*$Header: ENICOCPS.pls 115.0 2003/09/08 13:42:05 adhachol noship $*/
PROCEDURE GET_SQL ( p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                  , x_custom_sql        OUT NOCOPY VARCHAR2
                  , x_custom_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END;

 

/
