--------------------------------------------------------
--  DDL for Package OPI_DBI_PRD_CST_MARGIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_PRD_CST_MARGIN_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDRPPGMS.pls 115.1 2004/02/04 21:28:04 adwajan noship $ */

/*
    Report query for viewby = Org, Prd Cat, Cust, Item
*/
PROCEDURE margin_status_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                            x_custom_sql OUT NOCOPY VARCHAR2,
                            x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

/*
    Report query for viewby = Time
*/
PROCEDURE margin_trend_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql OUT NOCOPY VARCHAR2,
                           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END opi_dbi_prd_cst_margin_pkg;

 

/
