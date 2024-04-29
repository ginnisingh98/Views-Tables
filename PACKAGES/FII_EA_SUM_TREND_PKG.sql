--------------------------------------------------------
--  DDL for Package FII_EA_SUM_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_EA_SUM_TREND_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIEASUMS.pls 120.2 2006/07/19 08:49:36 wywong noship $ */

--   This package will provide sql statements to retrieve data for Expense Summary, Revenue Summary,
--   Expense Rolling Trend and Revenue Rolling Trend reports

PROCEDURE get_exp_sum (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
exp_sum_sql out NOCOPY VARCHAR2, exp_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_rev_sum (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
rev_sum_sql out NOCOPY VARCHAR2, rev_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_cgs_sum (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
rev_sum_sql out NOCOPY VARCHAR2, rev_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

FUNCTION get_revexp_sum (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL) return VARCHAR2;

PROCEDURE get_exp_trend (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
exp_trend_sql out NOCOPY VARCHAR2, exp_trend_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_rev_trend (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
rev_trend_sql out NOCOPY VARCHAR2, rev_trend_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_cogs_trend (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
p_cogs_trend_sql out NOCOPY VARCHAR2, p_cogs_trend_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

FUNCTION get_revexp_trend (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL) return VARCHAR2;


END fii_ea_sum_trend_pkg;

 

/
