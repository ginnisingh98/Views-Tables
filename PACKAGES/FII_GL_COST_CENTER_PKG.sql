--------------------------------------------------------
--  DDL for Package FII_GL_COST_CENTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_GL_COST_CENTER_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIGLC1S.pls 115.20 2004/07/08 07:39:00 hpoddar noship $ */

--   This package will provide sql statements to retrieve data for the portlets
--   on the Expenses page.

PROCEDURE get_exp_by_cat (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL, l_fin_category IN VARCHAR2,
exp_by_cat_sql out NOCOPY VARCHAR2, exp_by_cat_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL );

PROCEDURE get_rev_cc (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
rev_cc_sql out NOCOPY VARCHAR2, rev_cc_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_cogs_cc (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
cogs_cc_sql out NOCOPY VARCHAR2, cogs_cc_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_exp_cc (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
exp_cc_sql out NOCOPY VARCHAR2, exp_cc_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_te_cc (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, te_cc_sql out NOCOPY VARCHAR2, te_cc_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

FUNCTION get_revexp_cc (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL) return VARCHAR2;

PROCEDURE get_exp_cc_by_cat1 (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
exp_cc_by_cat1_sql out NOCOPY VARCHAR2, exp_cc_by_cat1_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL, fin_type VARCHAR2);

PROCEDURE get_exp_cc_by_cat (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, exp_cc_by_cat_sql out NOCOPY VARCHAR2,
  exp_cc_by_cat_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_rev_cc_by_cat (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, rev_cc_by_cat_sql out NOCOPY VARCHAR2,
  rev_cc_by_cat_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_cogs_cc_by_cat (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, cogs_cc_by_cat_sql out NOCOPY VARCHAR2,
  cogs_cc_by_cat_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_cont_marg (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
cont_marg_sql out NOCOPY VARCHAR2, cont_marg_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL, p_opera_marg IN Char DEFAULT 'N');

/* procedure added by ilavenil */
PROCEDURE get_opera_marg (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
cont_marg_sql out NOCOPY VARCHAR2, cont_marg_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


PROCEDURE get_revexp_tr(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
revexp_tr_sql out NOCOPY VARCHAR2, revexp_tr_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL, l_fin_type in VARCHAR2);

PROCEDURE get_rev_tr (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, rev_tr_sql out NOCOPY VARCHAR2,rev_tr_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_exp_tr (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, exp_tr_sql out NOCOPY VARCHAR2,exp_tr_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_cogs_tr (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, cogs_tr_sql out NOCOPY VARCHAR2,cogs_tr_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_te_tr (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, te_tr_sql out NOCOPY VARCHAR2,te_tr_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_exp_ccc_mgr (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
	exp_ccc_mgr_sql out NOCOPY VARCHAR2,
  exp_ccc_mgr_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END fii_gl_cost_center_pkg;

 

/
