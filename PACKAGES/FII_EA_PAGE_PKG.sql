--------------------------------------------------------
--  DDL for Package FII_EA_PAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_EA_PAGE_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIEAPAGES.pls 120.1 2005/10/30 05:05:56 appldev noship $ */

--   This package will provide sql statements to retrieve data for Expense Summary report

PROCEDURE get_exp (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
exp_ana_page_sql out NOCOPY VARCHAR2, exp_ana_page_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

FUNCTION get_revexp (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL) return VARCHAR2;

END fii_ea_page_pkg;

 

/
