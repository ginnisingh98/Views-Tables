--------------------------------------------------------
--  DDL for Package FII_AR_BA_TRX_CLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_BA_TRX_CLASS_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBIBTCS.pls 120.0.12000000.1 2007/02/23 02:27:55 applrt ship $ */

-- --------------------------------------------------------------------------
-- Name : get_billing_activity
-- Type : Procedure
-- Description : This procedure passes SQL to PMV for Billing Activity Report
-----------------------------------------------------------------------------

PROCEDURE get_bill_act_trx_class (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                                ba_trx_class_sum_sql out NOCOPY VARCHAR2,
				ba_trx_class_sum_out out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END FII_AR_BA_TRX_CLASS_PKG;

 

/
