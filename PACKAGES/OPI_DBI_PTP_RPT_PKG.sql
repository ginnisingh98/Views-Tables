--------------------------------------------------------
--  DDL for Package OPI_DBI_PTP_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_PTP_RPT_PKG" AUTHID CURRENT_USER As
/* $Header: OPIDRPTPS.pls 115.1 2003/07/02 19:21:10 weizhou noship $ */

PROCEDURE GET_TBL_SQL(
    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
);

PROCEDURE GET_TRD_SQL(
    p_param in BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
);

PROCEDURE GET_CMLTV_TRD_SQL(
    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
);

END OPI_DBI_PTP_RPT_PKG;

 

/
