--------------------------------------------------------
--  DDL for Package FII_AR_BILL_ACT_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_BILL_ACT_TREND_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBIBATS.pls 120.0.12000000.1 2007/02/23 02:27:51 applrt ship $ */

PROCEDURE get_billing_act_trend (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
bill_act_trend_sql out NOCOPY VARCHAR2, bill_trend_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

FUNCTION get_view_by return VARCHAR2;

END FII_AR_BILL_ACT_TREND_PKG;

 

/
