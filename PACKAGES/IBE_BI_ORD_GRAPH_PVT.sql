--------------------------------------------------------
--  DDL for Package IBE_BI_ORD_GRAPH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_BI_ORD_GRAPH_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVBIORDGRAS.pls 120.1 2005/09/16 06:11:14 appldev ship $ */
/**************************************************************************/
/* This procedure will return the Query for Order Graph Portlet           */
/**************************************************************************/

PROCEDURE GET_ORDER_GRAPH_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL );

/**************************************************************************/
/* This procedure will return the Query for Average Order                 */
/* Value Graph Portlet                                                    */
/**************************************************************************/

PROCEDURE GET_AVG_ORD_GRAPH_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL );

/**************************************************************************/
/* This procedure will return the Query for Average Order Discount        */
/* Graph Portlet                                                          */
/**************************************************************************/

PROCEDURE GET_AVG_DISC_GRAPH_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL );
END IBE_BI_ORD_GRAPH_PVT;

 

/
