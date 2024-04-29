--------------------------------------------------------
--  DDL for Package FII_AP_OPEN_PAY_SUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_OPEN_PAY_SUM" AUTHID CURRENT_USER AS
/* $Header: FIIAPS1S.pls 115.1 2003/06/24 19:51:11 djanaswa noship $ */

-- For the Open Payables Summary report --
PROCEDURE get_pay_liability (
	p_page_parameter_tbl	IN  BIS_PMV_PAGE_PARAMETER_TBL,
	open_pay_sum_sql	OUT NOCOPY VARCHAR2,
	open_pay_sum_output	OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- For the Discount Opportunities Summary report --
PROCEDURE get_discount_opp_sum (
	p_page_parameter_tbl	IN  BIS_PMV_PAGE_PARAMETER_TBL,
	disc_opp_sum_sql	OUT NOCOPY VARCHAR2,
	disc_opp_sum_output	OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- For the Invoice Due Aging Summary report --
PROCEDURE get_inv_due_age (
	p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
	inv_due_sum_sql         OUT NOCOPY VARCHAR2,
	inv_due_sum_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- For the Invoice Past Due Aging Summary report --
PROCEDURE get_inv_past_due_age (
	p_page_parameter_tbl	IN  BIS_PMV_PAGE_PARAMETER_TBL,
	inv_past_due_sum_sql	OUT NOCOPY VARCHAR2,
	inv_past_due_sum_output	OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END fii_ap_open_pay_sum;
-- End of summary package


 

/
