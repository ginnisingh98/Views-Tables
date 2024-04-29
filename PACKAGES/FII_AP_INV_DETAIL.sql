--------------------------------------------------------
--  DDL for Package FII_AP_INV_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_INV_DETAIL" AUTHID CURRENT_USER AS
/* $Header: FIIAPD1S.pls 120.1 2005/10/30 05:05:10 appldev noship $ */

-- To show the as-of-date in the report title --
FUNCTION get_report_title(
	p_page_parameter_tbl    BIS_PMV_PAGE_PARAMETER_TBL) RETURN VARCHAR2;


-- To get last_update_date for Past Due Invoices report --

FUNCTION get_past_due_inv_up_date RETURN VARCHAR2;


-- For Current Past Due Invoices report --
PROCEDURE get_current_top_pdue  (
	p_page_parameter_tbl	IN  BIS_PMV_PAGE_PARAMETER_TBL,
	inv_dtl_sql		OUT NOCOPY VARCHAR2,
	inv_dtl_output		OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- For the Invoice Detail report --
PROCEDURE get_inv_detail (
	p_page_parameter_tbl	IN  BIS_PMV_PAGE_PARAMETER_TBL,
	inv_dtl_sql		OUT NOCOPY VARCHAR2,
	inv_dtl_output		OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END FII_AP_INV_DETAIL;

-- End of package


 

/
