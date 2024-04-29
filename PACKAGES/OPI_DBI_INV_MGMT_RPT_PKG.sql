--------------------------------------------------------
--  DDL for Package OPI_DBI_INV_MGMT_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_INV_MGMT_RPT_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDRINVMS.pls 120.1 2005/08/10 03:47:48 srayadur noship $ */


/*
    Report query for viewby = Org, Item, Inv Cat
*/
PROCEDURE inv_val_status_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                              x_custom_sql OUT NOCOPY VARCHAR2,
                              x_custom_output OUT NOCOPY
                  BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE onhand_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                              x_custom_sql OUT NOCOPY VARCHAR2,
                              x_custom_output OUT NOCOPY
                  BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE intransit_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                              x_custom_sql OUT NOCOPY VARCHAR2,
                              x_custom_output OUT NOCOPY
                  BIS_QUERY_ATTRIBUTES_TBL);

/*
    Report query for viewby = Time
*/
PROCEDURE inv_val_trend_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                             x_custom_sql OUT NOCOPY VARCHAR2,
                             x_custom_output OUT NOCOPY
                 BIS_QUERY_ATTRIBUTES_TBL);


/*  Report query for inventory value by type report */
PROCEDURE inv_val_type_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                              x_custom_sql OUT NOCOPY VARCHAR2,
                              x_custom_output OUT NOCOPY
                              BIS_QUERY_ATTRIBUTES_TBL);



END OPI_DBI_INV_MGMT_RPT_PKG;

 

/
