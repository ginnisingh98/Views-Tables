--------------------------------------------------------
--  DDL for Package FII_AR_BILL_ACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_BILL_ACT_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBIBAS.pls 120.0.12000000.1 2007/02/23 02:27:48 applrt ship $ */

-- --------------------------------------------------------------------------
-- Name : get_billing_activity
-- Type : Procedure
-- Description : This procedure passes SQL to PMV for Billing Activity Report
-----------------------------------------------------------------------------

PROCEDURE get_billing_activity (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                                bill_act_sum_sql out NOCOPY VARCHAR2,
				bill_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END FII_AR_BILL_ACT_PKG;

 

/
