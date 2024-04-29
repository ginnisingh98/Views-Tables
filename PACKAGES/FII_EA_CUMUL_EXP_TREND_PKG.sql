--------------------------------------------------------
--  DDL for Package FII_EA_CUMUL_EXP_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_EA_CUMUL_EXP_TREND_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIEACETS.pls 120.1 2005/10/30 05:05:50 appldev noship $ */


-- This package provides procedure which generates different SQL statements
-- and will be used to retrieve data for Cumulative Expense Trend Report

-- Procedure get_cumul_exp_trend

   PROCEDURE get_cumul_exp_trend

   ( 	p_page_parameter_tbl         IN  BIS_PMV_PAGE_PARAMETER_TBL
       ,p_cumulative_expense_sql     OUT NOCOPY VARCHAR2
       ,p_cumulative_expense_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   );
END fii_ea_cumul_exp_trend_pkg;

 

/
