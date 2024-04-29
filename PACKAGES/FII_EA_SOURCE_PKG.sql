--------------------------------------------------------
--  DDL for Package FII_EA_SOURCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_EA_SOURCE_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIEASOURCES.pls 120.1 2005/10/30 05:12:54 appldev noship $ */

-- the get_exp_source procedure is called by Expense Source report.
-- It is a wrapper for get_rev_exp_source function.
PROCEDURE get_exp_source (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                         p_exp_source_sql out NOCOPY VARCHAR2,
                         p_exp_source_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- the get_rev_source procedure is called by Revenue Source report.
-- It is a wrapper for get_rev_exp_source function.
PROCEDURE get_rev_source (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                         p_rev_source_sql out NOCOPY VARCHAR2,
                         p_rev_source_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- This is the main function which constructs the PMV sql.
FUNCTION get_rev_exp_source (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                             p_multi_factor IN NUMBER) return VARCHAR2;


END  FII_EA_SOURCE_PKG;

 

/
