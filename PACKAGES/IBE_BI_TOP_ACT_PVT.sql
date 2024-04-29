--------------------------------------------------------
--  DDL for Package IBE_BI_TOP_ACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_BI_TOP_ACT_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVBITOPACTS.pls 120.1 2005/09/16 05:52:17 appldev ship $ */

/**************************************************************************/
/* This procedure will return the SQL for Store Top Orders Portlet        */
/**************************************************************************/

PROCEDURE GET_TOP_ORDERS_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL );

/**************************************************************************/
/* This procedure will return the SQL for Store Top Carts Portlet         */
/**************************************************************************/

PROCEDURE GET_TOP_CARTS_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL );

/**************************************************************************/
/* This procedure will return the SQL for Store Top Customers Portlet     */
/**************************************************************************/

PROCEDURE GET_TOP_CUSTOMERS_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL );

/**************************************************************************/
/* This procedure will return the SQL for Store Top Products Portlet      */
/**************************************************************************/

PROCEDURE GET_TOP_PRODUCTS_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL );

END IBE_BI_TOP_ACT_PVT;

 

/
