--------------------------------------------------------
--  DDL for Package FII_GL_EXPENSE_PKG_TREND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_GL_EXPENSE_PKG_TREND" AUTHID CURRENT_USER AS
/* $Header: FIIGLE2S.pls 115.5 2003/12/26 22:01:51 juding noship $ */

  PROCEDURE get_exp_per_emp_trend(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, exp_per_emp_trend_sql out NOCOPY VARCHAR2,
  exp_per_emp_trend_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END fii_gl_expense_pkg_trend;

 

/
