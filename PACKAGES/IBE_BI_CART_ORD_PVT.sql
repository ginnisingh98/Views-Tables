--------------------------------------------------------
--  DDL for Package IBE_BI_CART_ORD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_BI_CART_ORD_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVBICARTORDS.pls 120.1 2005/09/16 05:59:19 appldev ship $ */
/****************************************************************/
/* This Procedure will return the SQL Query for Cart and Order  */
/* Activity Portlet                                             */
/****************************************************************/

PROCEDURE GET_CART_ORD_PORT_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL );

END IBE_BI_CART_ORD_PVT;

 

/
