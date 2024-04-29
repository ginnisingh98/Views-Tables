--------------------------------------------------------
--  DDL for Package JAI_CMN_RPT_BBR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RPT_BBR_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_rpt_bbr.pls 120.1 2005/07/20 12:57:39 avallabh ship $ */

FUNCTION get_credit_balance(b_start_date DATE, b_bank_account_name VARCHAR,
b_bank_account_num VARCHAR, b_org_id NUMBER) return Number;


FUNCTION get_debit_balance(b_start_date DATE, b_bank_account_name VARCHAR,
b_bank_account_num VARCHAR, b_org_id NUMBER) return Number;


END jai_cmn_rpt_bbr_pkg ;
 

/
