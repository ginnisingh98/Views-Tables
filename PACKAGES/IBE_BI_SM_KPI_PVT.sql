--------------------------------------------------------
--  DDL for Package IBE_BI_SM_KPI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_BI_SM_KPI_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVBISMKPIS.pls 120.1 2005/09/16 05:51:58 appldev ship $ */

/***********************************************************************/
/* This procedure will return the Query for New Customers KPI          */
/***********************************************************************/

PROCEDURE GET_NEW_CUST_KPI_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL );

/***********************************************************************/
/* This procedure will return the Query for Average Order Value KPI    */
/***********************************************************************/

PROCEDURE GET_CART_ORD_KPIS_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL );

/***********************************************************************/
/***********************************************************************/
/* This procedure will return the Query for Average Order Value KPI    */
/***********************************************************************/

PROCEDURE GET_AVG_ORD_KPI_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL );

/***********************************************************************/
/* This procedure will return the Query for Booked Order Value KPI     */
/***********************************************************************/

PROCEDURE GET_BOOK_ORD_KPI_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL );

/***********************************************************************/
/* This procedure will return the Query for Carts KPI                  */
/***********************************************************************/

PROCEDURE GET_CARTS_KPI_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL );

/***********************************************************************/
/* This procedure will return the Query for Converted Carts KPI        */
/***********************************************************************/

PROCEDURE GET_CARTS_CONV_KPI_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL );

/***********************************************************************/
/* This procedure will return the Query for Average Order Discount KPI */
/***********************************************************************/

PROCEDURE GET_AVG_DISC_KPI_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL );

/***********************************************************************/
/* This procedure will return the Query for Campaign Orders KPI        */
/***********************************************************************/

PROCEDURE GET_CAMP_ORD_KPI_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL );

END IBE_BI_SM_KPI_PVT;

 

/
