--------------------------------------------------------
--  DDL for Package ENI_DBI_PCO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_PCO_PKG" AUTHID CURRENT_USER AS
/*$Header: ENIPCOPS.pls 115.2 2004/05/21 13:15:22 gratnam noship $*/

PROCEDURE GET_SQL ( p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                  , x_custom_sql        OUT NOCOPY VARCHAR2
                  , x_custom_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END;

 

/
