--------------------------------------------------------
--  DDL for Package ENI_DBI_CDE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_CDE_PKG" AUTHID CURRENT_USER AS
   /*$Header: ENICDEPS.pls 115.0 2004/02/12 08:48:57 skadamal noship $*/

PROCEDURE GET_SQL ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                  , x_custom_sql        OUT NOCOPY VARCHAR2
                  , x_custom_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END ENI_DBI_CDE_PKG;

 

/
