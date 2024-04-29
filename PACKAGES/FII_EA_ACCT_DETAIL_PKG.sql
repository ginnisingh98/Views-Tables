--------------------------------------------------------
--  DDL for Package FII_EA_ACCT_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_EA_ACCT_DETAIL_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIEAACCDTLS.pls 120.3 2006/07/19 11:27:58 sajgeo noship $ */

-- the get_exp_trend_dtl procedure is called by Cost Of Goods Sold Trend by Account Detail report.
-- It is a wrapper for get_rev_exp_trend_dtl.
PROCEDURE get_cgs_trend_dtl (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                             p_exp_trend_dtl_sql out NOCOPY VARCHAR2,
                             p_exp_trend_dtl_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- the get_exp_trend_dtl procedure is called by Expense Trend by Account Detail report.
-- It is a wrapper for get_rev_exp_trend_dtl.
PROCEDURE get_exp_trend_dtl (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                             p_exp_trend_dtl_sql out NOCOPY VARCHAR2,
                             p_exp_trend_dtl_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- the get_rev_trend_dtl procedure is called by Revenue Trend by Account Detai report.
-- It is a wrapper for get_rev_exp_trend_dtl.
PROCEDURE get_rev_trend_dtl (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                             p_rev_trend_dtl_sql out NOCOPY VARCHAR2,
                             p_rev_trend_dtl_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- This is the main function which constructs the PMV sql.
FUNCTION get_rev_exp_trend_dtl (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                                 p_fin_cat IN VARCHAR2) RETURN VARCHAR2;



END FII_EA_ACCT_DETAIL_PKG;


 

/
