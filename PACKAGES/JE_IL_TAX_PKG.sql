--------------------------------------------------------
--  DDL for Package JE_IL_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_IL_TAX_PKG" AUTHID CURRENT_USER
-- $Header: jeilwhtaps.pls 120.3.12010000.7 2010/05/26 10:44:21 pakumare ship $
AS

  P_From_Period          VARCHAR2(10);
  P_To_Period            VARCHAR2(10);
  P_Vendor_Type          VARCHAR2(1);
  P_Legal_Entity_ID      NUMBER;
  P_Ledger_ID		 NUMBER;
  P_Method		 VARCHAR2(10);
  P_Order_By		 VARCHAR2(10);
  P_Information_Level	 VARCHAR2(10);
  P_Name_Level		 VARCHAR2(10);
  P_Manual_Rpt_Exist	 VARCHAR2(10);
  P_Comp_Rpt_Exist	 VARCHAR2(10);
  P_Payer_Position	 VARCHAR2(10);
  P_Vendor_Name		 VARCHAR2(200);
  P_Vendor_Site		 VARCHAR2(200);
  P_Report_Name		 VARCHAR2(10);
  P_Year		 VARCHAR2(10);
  P_From_Supplier_Number VARCHAR2(10);
  P_To_Supplier_Number   VARCHAR2(10);
  P_Include_WHT_0	 VARCHAR2(10);
  gn_awt_amount          NUMBER;
  gn_invoice_id          NUMBER;
  gn_check_id            NUMBER;
  p_vendor_name_col      VARCHAR2(1000);
  p_vendor_sitecode_col  VARCHAR2(1000);
  p_vat_reg_no           VARCHAR2(4000);
  p_flex_value_cond      VARCHAR2(1000);
  p_deduction_type_cond  VARCHAR2(1000);
  p_business_sec_cond    VARCHAR2(3000);
  p_tax_payerid_cond     VARCHAR2(3000);
  p_global_cond          VARCHAR2(1000);
  p_supplier_num_from    VARCHAR2(1000);
  p_supplier_num_to      VARCHAR2(1000);
  fnd_debug_log 		 VARCHAR2(3);
  p_vendor_type_col 	 VARCHAR2(100);
  p_vendor_type_cond 	 VARCHAR2(1000);
  p_vendor_name_cond 	 VARCHAR2(500);
  p_vendor_site_cond 	 VARCHAR2(500);
  p_exp_irs_cond 	 VARCHAR2(1000);
  p_supplier_type 	 VARCHAR2(1000);
  p_bank_supplier 	 VARCHAR2(1000);
  p_order_by_cond 	 VARCHAR2(500);
  p_first_party_query    VARCHAR2(8000);
  p_count_lines_query    VARCHAR2(8000);
  p_payment_info_query   VARCHAR2(8000);
  p_awt_taxrates_query   VARCHAR2(8000);
  p_vendor_balance_query VARCHAR2(8000);
  p_count_vendors_query  VARCHAR2(8000);
  l_currency_check       VARCHAR2(8000);
  l_foreign_suppliers_check       VARCHAR2(8000);

  l_primary_ledger_id	 NUMBER;
  l_period_set_name      VARCHAR2(20);


  FUNCTION BeforeReport RETURN BOOLEAN;

  FUNCTION IS_NUMBER (p_str1 VARCHAR2,p_str2 VARCHAR2) RETURN VARCHAR2;

  FUNCTION get_gross_amount(pn_invoice_id NUMBER,pn_check_id NUMBER, pd_start_date DATE, pd_end_date DATE, pv_void NUMBER)RETURN NUMBER;
  FUNCTION get_awt_amount RETURN NUMBER;
  FUNCTION get_invoice_id RETURN NUMBER;
  TYPE check_inv_r IS RECORD
  ( check_id number,
    invoice_id number);
  TYPE check_inv_table IS TABLE OF  check_inv_r INDEX BY BINARY_INTEGER;
   t_check_inv check_inv_table;

END JE_IL_TAX_PKG;

/
