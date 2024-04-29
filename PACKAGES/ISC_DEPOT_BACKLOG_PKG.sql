--------------------------------------------------------
--  DDL for Package ISC_DEPOT_BACKLOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DEPOT_BACKLOG_PKG" AUTHID CURRENT_USER AS
--$Header: iscdepotbklgrqs.pls 120.0 2005/05/25 17:45:38 appldev noship $

PROCEDURE GET_BACKLOG_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                              x_custom_sql OUT NOCOPY VARCHAR2,
                              x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_BACKLOG_TRD_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                              x_custom_sql OUT NOCOPY VARCHAR2,
                              x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_BACKLOG_DTL_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
				  x_custom_sql OUT NOCOPY VARCHAR2,
				  x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_PAST_DUE_AGNG_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
				    x_custom_sql OUT NOCOPY VARCHAR2,
				    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_PAST_DUE_DTL_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
				   x_custom_sql OUT NOCOPY VARCHAR2,
				   x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_DAYS_UNTIL_PROM_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
	   			      x_custom_sql OUT NOCOPY VARCHAR2,
				      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END ISC_DEPOT_BACKLOG_PKG;

 

/
