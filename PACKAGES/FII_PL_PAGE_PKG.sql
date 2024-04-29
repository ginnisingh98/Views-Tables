--------------------------------------------------------
--  DDL for Package FII_PL_PAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_PL_PAGE_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIPLPGS.pls 120.2.12000000.1 2007/04/10 13:58:21 dhmehra ship $ */


PROCEDURE get_pl_graph (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
pl_graph_sql out NOCOPY VARCHAR2, pl_graph_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


FUNCTION get_pl_graph_val (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL) return VARCHAR2;


PROCEDURE get_rev_trend (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  expense_sum_sql out NOCOPY VARCHAR2,
  expense_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_exp_trend (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  expense_sum_sql out NOCOPY VARCHAR2,
  expense_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_cogs_trend (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  expense_sum_sql out NOCOPY VARCHAR2,
  expense_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_mar_trend (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  expense_sum_sql out NOCOPY VARCHAR2,
  expense_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_expense_sum(
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  expense_sum_sql out NOCOPY VARCHAR2,
  expense_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_margin_sum(
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  expense_sum_sql out NOCOPY VARCHAR2,
  expense_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- Following procedure is used to form PMV SQL, which is used to retrieve data
-- for Gross Margin Table portlet and Gross Margin Summary report

PROCEDURE get_gross_margin( p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL
                           ,p_gross_margin_sql    OUT NOCOPY VARCHAR2
                           ,p_gross_margin_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
			  );

-- Following procedure is used to form PMV SQL, which is used to retrieve data
-- for Operating Margin Table portlet and Operating Margin Summary report

PROCEDURE get_oper_margin( p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL
                          ,p_oper_margin_sql     OUT NOCOPY VARCHAR2
                          ,p_oper_margin_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
			  );

END fii_pl_page_pkg;

 

/
