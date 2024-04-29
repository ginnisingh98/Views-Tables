--------------------------------------------------------
--  DDL for Package FII_GL_EXP_TREND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_GL_EXP_TREND" AUTHID CURRENT_USER AS
/* $Header: FIIGLETS.pls 115.5 2003/12/26 22:01:52 juding noship $ */

 PROCEDURE get_te_sum (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, expense_sum_sql out NOCOPY VARCHAR2, expense_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_exp_sum (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, expense_sum_sql out NOCOPY VARCHAR2, expense_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


  PROCEDURE get_expense_sum(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, expense_sum_sql out NOCOPY VARCHAR2, expense_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END fii_gl_exp_trend;

 

/
