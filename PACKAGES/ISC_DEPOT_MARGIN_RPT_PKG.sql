--------------------------------------------------------
--  DDL for Package ISC_DEPOT_MARGIN_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DEPOT_MARGIN_RPT_PKG" AUTHID CURRENT_USER AS
--$Header: iscdepotmrgrqs.pls 120.0 2005/05/25 17:29:09 appldev noship $

PROCEDURE get_ro_mrg_tbl_sql(
    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
);

PROCEDURE get_ro_mrg_trd_sql(
    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
);

PROCEDURE get_chg_summ_tbl_sql(
    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
);

PROCEDURE get_chg_summ_trd_sql(
    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
);

PROCEDURE get_cst_summ_tbl_sql(
    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
);

PROCEDURE get_cst_summ_trd_sql(
    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
);

PROCEDURE get_mrg_summ_tbl_sql(
    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
);

PROCEDURE get_mrg_summ_trd_sql(
    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
);

PROCEDURE get_mrg_dtl_tbl_sql(
    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
);

END ISC_DEPOT_MARGIN_RPT_PKG;

 

/
