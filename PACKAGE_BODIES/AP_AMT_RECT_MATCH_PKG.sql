--------------------------------------------------------
--  DDL for Package Body AP_AMT_RECT_MATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_AMT_RECT_MATCH_PKG" AS
/* $Header: apamorcb.pls 120.0 2005/05/20 22:44:55 bghose noship $ */

Procedure AP_AMT_RECPT_MATCH (
	X_invoice_id		IN	NUMBER,
	X_parent_invoice_id	IN	NUMBER,
	X_rcv_transaction_id	IN	NUMBER,
	X_po_line_location_id	IN	NUMBER,
	X_po_distribution_id	IN	NUMBER,
	X_amount		IN	NUMBER,
	X_quantity		IN	NUMBER,
	X_price			IN	NUMBER,
	X_ccid			IN	NUMBER,
	X_item_description	IN	VARCHAR2,
	X_type_1099		IN	VARCHAR2,
	X_vat_code		IN	VARCHAR2,
	X_tax_code_override_flag IN	VARCHAR2,
        X_tax_recovery_rate	IN	NUMBER,
        X_tax_recovery_override_flag IN  VARCHAR2,
        X_tax_recoverable_flag  IN     VARCHAR2,
	X_login_id		IN	NUMBER,
	X_user_id		IN	NUMBER,
	X_tax_amount		IN	NUMBER,
	X_tax_name		IN	VARCHAR2,
	X_tax_id		IN	NUMBER,
	X_tax_description	IN	VARCHAR2,
	X_freight_amount	IN	NUMBER,
	X_freight_tax_name	IN	VARCHAR2,
	X_freight_tax_id	IN	NUMBER,
	X_freight_description	IN	VARCHAR2,
	X_misc_amount		IN	NUMBER,
	X_misc_tax_name		IN 	VARCHAR2,
	X_misc_tax_id		IN	NUMBER,
	X_misc_description	IN	VARCHAR2,
	X_calling_sequence	IN	VARCHAR2) IS
BEGIN
  NULL;
END;



END AP_AMT_RECT_MATCH_PKG;

/
