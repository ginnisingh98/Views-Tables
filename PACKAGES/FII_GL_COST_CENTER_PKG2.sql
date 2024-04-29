--------------------------------------------------------
--  DDL for Package FII_GL_COST_CENTER_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_GL_COST_CENTER_PKG2" AUTHID CURRENT_USER AS
/* $Header: FIIGLC2S.pls 115.8 2003/12/26 22:01:48 juding noship $ */
--   This package will provide sql statements to retrieve data for the portlets
--   on the Expenses page.

BUDGET_TIME_UNIT   VARCHAR2(1);
FORECAST_TIME_UNIT VARCHAR2(1);

PROCEDURE get_exp_by_cat (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                         exp_by_cat_sql out NOCOPY VARCHAR2,
                         exp_by_cat_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL );
FUNCTION get_revexp_cc ( p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, l_fin_type IN VARCHAR2) return VARCHAR2;

PROCEDURE get_cont_marg (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
cont_marg_sql out NOCOPY VARCHAR2, cont_marg_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL, p_opera_marg IN Char DEFAULT 'N');

PROCEDURE get_opera_marg (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,cont_marg_sql out NOCOPY VARCHAR2, cont_marg_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_cogs_cc (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, cgs_cc_sql out NOCOPY VARCHAR2, cgs_cc_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_exp_cc (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, exp_cc_sql out NOCOPY VARCHAR2, exp_cc_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_rev_cc (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, rev_cc_sql out NOCOPY VARCHAR2, rev_cc_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);



END fii_gl_cost_center_pkg2;

 

/
