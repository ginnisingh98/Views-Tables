--------------------------------------------------------
--  DDL for Package FII_AP_PAY_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_PAY_STATUS" AUTHID CURRENT_USER AS
/* $Header: FIIAPPSS.pls 115.5 2003/10/25 00:51:43 djanaswa noship $ */

-- For the Open Payables Status on the portal page --
PROCEDURE GET_OPEN_PAY_TABLE_PORTLET (
	p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
	open_pay_sum_sql        OUT NOCOPY VARCHAR2,
	open_pay_sum_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_pay_liability_pie (
	p_page_parameter_tbl   	IN  BIS_PMV_PAGE_PARAMETER_TBL,
	open_pay_sum_pie_sql   	OUT NOCOPY VARCHAR2,
	open_pay_sum_pie_output	OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_inv_aging (
	p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
	inv_age_sql             OUT NOCOPY VARCHAR2,
	inv_age_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_kpi (
	p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
	kpi_sql                 OUT NOCOPY VARCHAR2,
	kpi_output              OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


PROCEDURE get_hold_sum (
	p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
	get_hold_sum_sql                 OUT NOCOPY VARCHAR2,
	get_hold_sum_output              OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END FII_AP_PAY_STATUS;


 

/
