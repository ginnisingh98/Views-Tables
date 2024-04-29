--------------------------------------------------------
--  DDL for Package ENI_DBI_PCM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_PCM_PKG" AUTHID CURRENT_USER AS
   /*$Header: ENIPCMPS.pls 115.3 2004/05/21 13:16:20 gratnam noship $*/

PROCEDURE GET_SQL ( p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                  , x_custom_sql        OUT NOCOPY VARCHAR2
                  , x_custom_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END;

 

/
