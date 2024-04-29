--------------------------------------------------------
--  DDL for Package IBE_BI_PROD_CATG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_BI_PROD_CATG_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVBICATEGS.pls 120.1 2005/09/16 05:57:56 appldev ship $ */

/****************************************************************************/
/* This procedure returns the SQL for Activity By Product Category Portlet  */
/****************************************************************************/

PROCEDURE GET_ACTY_BY_CATG_PORT_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL );

END IBE_BI_PROD_CATG_PVT;

 

/
