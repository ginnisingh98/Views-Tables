--------------------------------------------------------
--  DDL for Package ENI_DBI_COA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_COA_PKG" AUTHID CURRENT_USER AS
/*$Header: ENICOAPS.pls 120.0 2005/05/26 19:37:14 appldev noship $*/

PROCEDURE GET_SQL ( p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                  , x_custom_sql        OUT NOCOPY VARCHAR2
                  , x_custom_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END;

 

/
