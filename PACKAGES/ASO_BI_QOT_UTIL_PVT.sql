--------------------------------------------------------
--  DDL for Package ASO_BI_QOT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_BI_QOT_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: asovbiutls.pls 120.0 2005/05/31 01:27:03 appldev noship $  */

-- Used to get conversion rate
FUNCTION GET_CUR_CONV_RATE(p_currency_code IN VARCHAR2,p_asof_date IN DATE)
  RETURN NUMBER;

-- Used for defaulting in parameter portlet
FUNCTION GET_DBI_PARAMS(p_region_id IN VARCHAR2) RETURN VARCHAR2;

-- Parse and obtain the various input parameters
Procedure GET_PAGE_PARAMS(p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_TBL,
                          x_conv_rate  OUT NOCOPY NUMBER,
                          x_record_type_id OUT NOCOPY NUMBER,
                          x_sysdate OUT NOCOPY DATE,
                          x_sg_id OUT NOCOPY NUMBER,
                          x_sr_id OUT NOCOPY NUMBER,
                          x_asof_date  OUT NOCOPY DATE,
                          x_priorasof_date OUT NOCOPY DATE,
                          x_fdcp_date OUT NOCOPY DATE,
                          x_fdpp_date OUT NOCOPY DATE,
                          x_period_type OUT NOCOPY  VARCHAR2,
                          x_comparision_type OUT NOCOPY  VARCHAR2,
                          x_orderBy  OUT NOCOPY  VARCHAR2,
                          x_sortBy   OUT NOCOPY VARCHAR2,
                          x_viewby OUT NOCOPY VARCHAR2,
                          x_prodcat_id OUT NOCOPY VARCHAR2,
                          x_product_id OUT NOCOPY VARCHAR2);

-- Write the query to log tables
PROCEDURE write_query (p_query IN VARCHAR2, p_module IN VARCHAR2);

END ASO_BI_QOT_UTIL_PVT;

 

/
