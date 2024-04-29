--------------------------------------------------------
--  DDL for Package OPI_DBI_PROD_SCRAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_PROD_SCRAP_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDRSCRAPS.pls 115.0 2003/06/11 20:25:02 digupta noship $ */


/*
    Report query for viewby = Org, Item, Inv Cat
*/
PROCEDURE scrap_status_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                            x_custom_sql OUT NOCOPY VARCHAR2,
                            x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

/*
    Report query for viewby = Time
*/
PROCEDURE scrap_trend_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql OUT NOCOPY VARCHAR2,
                           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END opi_dbi_prod_scrap_pkg;

 

/
