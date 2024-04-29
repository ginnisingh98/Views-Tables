--------------------------------------------------------
--  DDL for Package FII_AP_PAID_INV_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_PAID_INV_DETAIL" AUTHID CURRENT_USER AS
/* $Header: FIIAPD2S.pls 115.2 2003/06/24 19:44:58 djanaswa ship $ */


PROCEDURE Get_Payment_Detail
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       pay_detail_sql out NOCOPY VARCHAR2,
       pay_detail_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
 PROCEDURE Get_Paid_Inv_Detail
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       paid_inv_sql out NOCOPY VARCHAR2,
       paid_inv_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
 PROCEDURE Get_Pay_Activity_History
      ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       pay_act_sql out NOCOPY VARCHAR2,
       pay_act_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END FII_AP_PAID_INV_DETAIL;

 

/
