--------------------------------------------------------
--  DDL for Package AP_OTHR_CHRG_MATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_OTHR_CHRG_MATCH_PKG" AUTHID CURRENT_USER AS
/* $Header: apothmts.pls 120.4 2005/03/10 03:10:39 smyadam noship $ */

    -- Type definition of pl/sql table for passing special charges
    TYPE othr_chrg_rectype IS RECORD
	    (rcv_txn_id		rcv_transactions.transaction_id%TYPE,
	     charge_amt		ap_invoice_lines.amount%TYPE,
	     base_amt		ap_invoice_lines.base_amount%TYPE,
             rounding_amt       ap_invoice_lines.rounding_amt%TYPE,
	     rcv_qty		rcv_transactions.quantity%TYPE);

    TYPE othr_chrg_match_tabtype IS TABLE OF othr_chrg_rectype
	INDEX BY BINARY_INTEGER;

    Procedure OTHR_CHRG_MATCH (
		    X_invoice_id            IN      NUMBER,
		    X_invoice_line_number   IN      NUMBER,
		    X_line_type             IN      VARCHAR2,
		    X_Cost_Factor_Id        IN      NUMBER DEFAULT NULL,
		    X_prorate_flag          IN      VARCHAR2,
		    X_account_id            IN      NUMBER,
		    X_description           IN      VARCHAR2,
		    X_total_amount          IN      NUMBER,
	    	    X_othr_chrg_tab         IN      OTHR_CHRG_MATCH_TABTYPE,
		    X_row_count             IN      NUMBER,
		    X_calling_sequence      IN      VARCHAR2);


END AP_OTHR_CHRG_MATCH_PKG;

 

/
