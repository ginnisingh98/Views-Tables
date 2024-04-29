--------------------------------------------------------
--  DDL for Package FII_GL_EXPENSE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_GL_EXPENSE_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIGLEXS.pls 115.7 2003/12/26 22:01:55 juding noship $ */

PROCEDURE get_te_per_emp (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, exp_per_emp_sql out NOCOPY VARCHAR2,
  exp_per_emp_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_exp_per_emp (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, exp_per_emp_sql out NOCOPY VARCHAR2,
  exp_per_emp_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_EXPENSES_PER_EMP (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
exp_per_emp_sql out NOCOPY VARCHAR2, exp_per_emp_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END FII_GL_EXPENSE_PKG;

 

/
