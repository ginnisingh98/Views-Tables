--------------------------------------------------------
--  DDL for Package ENI_DBI_COL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_COL_PKG" AUTHID CURRENT_USER AS
/*$Header: ENICOLPS.pls 115.1 2003/11/18 06:49:50 adhachol noship $*/

PROCEDURE GET_SQL ( p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                  , x_custom_sql        OUT NOCOPY VARCHAR2
                  , x_custom_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_COL_PARAMETERS (p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL,
                          p_report               OUT NOCOPY VARCHAR2,
			  p_start_date           OUT NOCOPY DATE,
			  p_end_date             OUT NOCOPY DATE
			  );

END;

 

/
