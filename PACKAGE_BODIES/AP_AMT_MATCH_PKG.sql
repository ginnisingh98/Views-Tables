--------------------------------------------------------
--  DDL for Package Body AP_AMT_MATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_AMT_MATCH_PKG" AS
/*$Header: apamopob.pls 120.1 2005/07/21 20:25:28 kkotwal noship $*/

PROCEDURE ap_amt_match
	  	  (X_match_mode  	 	VARCHAR2,
                   X_credit_id     		NUMBER,
                   X_invoice_id    		NUMBER,
		   X_dist_num      		NUMBER,
		   X_shipment_id   		NUMBER,
		   X_po_dist_id    		NUMBER,
		   X_rcv_transaction_id		NUMBER,
		   X_receipt_uom		VARCHAR2,
		   X_amount	    		NUMBER,
		   X_quantity	  		NUMBER,
		   X_price	    	 	NUMBER,
		   X_precision     		NUMBER,
		   X_min_acct_unit 	 	NUMBER,
		   X_final	   	   	VARCHAR2,
		   X_ccid	        	NUMBER,
		   X_dist_total	 		NUMBER,
		   X_gl_date			DATE,
		   X_period			VARCHAR2,
		   X_batch_id			NUMBER,
		   X_login_id			NUMBER,
		   X_user_id			NUMBER,
		   X_overbill			VARCHAR2,
		   X_description		VARCHAR2,
		   X_type_1099			VARCHAR2,
		   X_vat_code			VARCHAR2,
		   X_tax_code_override_flag	VARCHAR2,
		   X_tax_recovery_rate		NUMBER,
		   X_tax_recovery_override_flag VARCHAR2,
		   X_tax_recoverable_flag       VARCHAR2,
		   X_tax_region			VARCHAR2,
                -- Removed for bug 4277744
		-- X_ussgl_code			VARCHAR2,
		   X_tax_amount			NUMBER,
		   X_tax_name			VARCHAR2,
		   X_tax_description		VARCHAR2,
		   X_freight_amount		NUMBER,
		   X_freight_tax_name		VARCHAR2,
		   X_freight_description	VARCHAR2,
		   X_misc_amount		NUMBER,
		   X_misc_tax_name		VARCHAR2,
		   X_misc_description		VARCHAR2,
		   X_set_of_books_id		NUMBER,
		   X_awt_group_id		NUMBER,
		   X_calling_sequence		VARCHAR2) IS
BEGIN
  NULL;
END;

PROCEDURE ap_amt_prorate_all(
		   X_invoice_id			NUMBER,
		   X_tax_amount			NUMBER,
		   X_tax_name			VARCHAR2,
		   X_tax_description		VARCHAR2,
		   X_freight_amount		NUMBER,
		   X_freight_tax_name		VARCHAR2,
		   X_freight_description	VARCHAR2,
		   X_misc_amount		NUMBER,
		   X_misc_tax_name		VARCHAR2,
		   X_misc_description		VARCHAR2,
 		   X_start_dist_line_number 	NUMBER,
		   X_user_id			NUMBER,
	           X_login_id			NUMBER,
		   X_calling_sequence		VARCHAR2) IS
BEGIN
  NULL;
END;

FUNCTION get_prepay_ccid (po_dist_ccid  IN NUMBER,
                          l_prepay_ccid IN NUMBER) return number IS
BEGIN
  NULL;
END;


END AP_AMT_MATCH_PKG;

/
