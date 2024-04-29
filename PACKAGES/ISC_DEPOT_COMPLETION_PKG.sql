--------------------------------------------------------
--  DDL for Package ISC_DEPOT_COMPLETION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DEPOT_COMPLETION_PKG" AUTHID CURRENT_USER AS
--$Header: iscdepotcomprqs.pls 120.0 2005/05/25 17:17:07 appldev noship $

PROCEDURE GET_COMPLETION_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                              x_custom_sql OUT NOCOPY VARCHAR2,
                              x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_COMPLETION_TRD_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                              x_custom_sql OUT NOCOPY VARCHAR2,
                              x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_COMPLETION_DTL_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
				     x_custom_sql OUT NOCOPY VARCHAR2,
				     x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_LAT_COMP_DTL_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
				    x_custom_sql OUT NOCOPY VARCHAR2,
				    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_LAT_COMP_AGNG_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
				   x_custom_sql OUT NOCOPY VARCHAR2,
				   x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

FUNCTION GET_BUCKET_DRILL_ACROSS_URL (p_function_name VARCHAR2,
                                      p_bucket_number NUMBER)
RETURN VARCHAR2;

END ISC_DEPOT_COMPLETION_PKG;

 

/
