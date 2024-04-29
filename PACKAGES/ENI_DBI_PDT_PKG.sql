--------------------------------------------------------
--  DDL for Package ENI_DBI_PDT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_PDT_PKG" AUTHID CURRENT_USER AS
/*$Header: ENIPDTPS.pls 115.1 2003/11/03 21:42:10 pthambu noship $*/

PROCEDURE GET_SQL ( p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                  , x_custom_sql        OUT NOCOPY VARCHAR2
                  , x_custom_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END;

 

/
