--------------------------------------------------------
--  DDL for Package OPI_DBI_WMS_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_WMS_RPT_PKG" AUTHID CURRENT_USER AS
 /* $Header: OPIDRWWAAS.pls 120.0 2005/05/24 18:06:16 appldev noship $ */
 PROCEDURE GET_PICK_EX_SQL(
       p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

 PROCEDURE GET_EX_REASON_SQL(
       p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

 PROCEDURE GET_PICK_TRD_SQL (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                             x_custom_sql OUT NOCOPY VARCHAR2,
                             x_custom_output OUT NOCOPY
                             BIS_QUERY_ATTRIBUTES_TBL);

 PROCEDURE GET_OPP_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql OUT NOCOPY VARCHAR2,
                           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

 PROCEDURE GET_OP_EX_REASON_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql OUT NOCOPY VARCHAR2,
                           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

 END OPI_DBI_WMS_RPT_PKG;

 

/
