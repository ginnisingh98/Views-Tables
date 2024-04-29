--------------------------------------------------------
--  DDL for Package FII_AP_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_DETAIL" AUTHID CURRENT_USER AS
/* $Header: FIIAPDES.pls 120.1 2005/06/16 11:30:56 vrajendr ship $ */


PROCEDURE Get_Inv_Activity_History
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       inv_act_sql out NOCOPY VARCHAR2,
       inv_act_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
 PROCEDURE Get_Sched_Pay_Discount
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       sched_pay_sql out NOCOPY VARCHAR2,
       sched_pay_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
 PROCEDURE Get_Hold_History
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       hold_history_sql out NOCOPY VARCHAR2,
       hold_history_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
 PROCEDURE Get_Inv_Distribution_Detail
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       inv_dist_sql out NOCOPY VARCHAR2,
       inv_dist_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
 FUNCTION Get_Account_Desc(p_chart_of_accounts_id IN NUMBER, p_dist_code_combination_id IN NUMBER)
 return Varchar2;

PROCEDURE get_inv_lines_detail (
                p_page_parameter_tbl            IN 		BIS_PMV_PAGE_PARAMETER_TBL,
                p_inv_lines_detail_sql          OUT     NOCOPY  VARCHAR2,
                p_inv_lines_detail_output       OUT 	NOCOPY	BIS_QUERY_ATTRIBUTES_TBL
);

END FII_AP_DETAIL;

 

/
