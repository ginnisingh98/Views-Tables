--------------------------------------------------------
--  DDL for Package ENI_DBI_PDA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_PDA_PKG" AUTHID CURRENT_USER AS
/*$Header: ENIPDAPS.pls 115.0 2003/10/22 19:15:12 pthambu noship $*/

PROCEDURE GET_SQL ( p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                  , x_custom_sql        OUT NOCOPY VARCHAR2
                  , x_custom_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END;

 

/
