--------------------------------------------------------
--  DDL for Package AP_RETAINAGE_RELEASE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_RETAINAGE_RELEASE_PKG" AUTHID CURRENT_USER As
/* $Header: apcwrels.pls 120.0 2005/06/25 00:42:39 schitlap noship $ */

TYPE release_shipments_record IS RECORD
		(po_header_id			po_line_locations_all.po_header_id%TYPE,
		 po_line_id			po_line_locations_all.po_line_id%TYPE,
		 po_release_id			po_line_locations_all.po_release_id%TYPE,
		 line_location_id		po_line_locations_all.line_location_id%TYPE,
		 invoice_id			ap_invoices_all.invoice_id%TYPE,
		 line_number			ap_invoice_lines_all.line_number%TYPE,
		 release_amount			number,
		 release_amount_remaining 	number);

TYPE release_shipments_tab IS TABLE OF release_shipments_record INDEX BY BINARY_INTEGER;

Procedure create_release (x_invoice_id		  IN ap_invoices_all.invoice_id%TYPE,
			  x_release_shipments_tab IN release_shipments_tab);
/*
CURSOR c_retained_lines
		(c_line_location_id IN ap_invoice_lines_all.po_line_location_id%TYPE) Is
SELECT ai.invoice_currency_code,
       ai.exchange_rate,
       ail.invoice_id,
       ail.line_number,
       ail.retained_amount_remaining,
       ail.description,
       ail.match_type,
       ail.set_of_books_id,
       ail.unit_meas_lookup_code,
       ail.unit_price,
       ail.ussgl_transaction_code,
       ail.po_header_id,
       ail.po_line_id,
       ail.po_release_id,
       ail.po_line_location_id,
       ail.po_distribution_id,
       ail.rcv_transaction_id,
       ail.final_match_flag,
       ail.asset_book_type_code,
       ail.asset_category_id,
       ail.project_id,
       ail.task_id,
       ail.expenditure_type,
       ail.expenditure_item_date,
       ail.expenditure_organization_id,
       ail.award_id,
       ail.awt_group_id,
       ail.reference_1,
       ail.reference_2,
       ail.receipt_verified_flag,
       ail.receipt_required_flag,
       ail.receipt_missing_flag,
       ail.justification,
       ail.expense_group,
       ail.start_expense_date,
       ail.end_expense_date,
       ail.receipt_currency_code,
       ail.receipt_conversion_rate,
       ail.receipt_currency_amount,
       ail.daily_amount,
       ail.web_parameter_id,
       ail.adjustment_reason,
       ail.merchant_document_number,
       ail.merchant_name,
       ail.merchant_reference,
       ail.merchant_tax_reg_number,
       ail.merchant_taxpayer_id,
       ail.country_of_supply,
       ail.credit_card_trx_id,
       ail.company_prepaid_invoice_id,
       ail.cc_reversal_flag,
       ail.attribute_category,
       ail.attribute1,
       ail.attribute2,
       ail.attribute3,
       ail.attribute4,
       ail.attribute5,
       ail.attribute6,
       ail.attribute7,
       ail.attribute8,
       ail.attribute9,
       ail.attribute10,
       ail.attribute11,
       ail.attribute12,
       ail.attribute13,
       ail.attribute14,
       ail.attribute15,
       ail.global_attribute_category,
       ail.global_attribute1,
       ail.global_attribute2,
       ail.global_attribute3,
       ail.global_attribute4,
       ail.global_attribute5,
       ail.global_attribute6,
       ail.global_attribute7,
       ail.global_attribute8,
       ail.global_attribute9,
       ail.global_attribute10,
       ail.global_attribute11,
       ail.global_attribute12,
       ail.global_attribute13,
       ail.global_attribute14,
       ail.global_attribute15,
       ail.global_attribute16,
       ail.global_attribute17,
       ail.global_attribute18,
       ail.global_attribute19,
       ail.global_attribute20,
       ail.ship_to_location_id,
       ail.primary_intended_use,
       ail.product_fisc_classification,
       ail.trx_business_category,
       ail.product_type,
       ail.product_category,
       ail.user_defined_fisc_class,
       ail.purchasing_category_id,
       ail.wfapproval_status
  FROM ap_invoices_all		ai,
       ap_invoice_lines_all	ail
 WHERE ai.invoice_id = ail.invoice_id
   AND ail.po_line_location_id	= c_line_location_id
   AND ail.retained_amount_remaining > 0
   AND ail.line_type_lookup_code = 'ITEM'
   AND NVL(ail.discarded_flag,'N') <> 'Y'
   AND NVL(ail.line_selected_for_release_flag,'N') <> 'Y'
 ORDER BY ai.creation_date;
*/

--
-- IMPORTANT NOTE:
-- The select columns in c_retained_lines_po and c_retained_lines_inv should always match.
--

CURSOR c_retained_lines_po
		(c_line_location_id IN ap_invoice_lines_all.po_line_location_id%TYPE) Is
SELECT ai.invoice_currency_code,
       ai.exchange_rate,
       ail.*
  FROM ap_invoices_all		ai,
       ap_invoice_lines_all	ail
 WHERE ai.invoice_id = ail.invoice_id
   AND ail.po_line_location_id	= c_line_location_id
   AND ail.retained_amount_remaining > 0
   AND ail.line_type_lookup_code = 'ITEM'
   AND NVL(ail.discarded_flag,'N') <> 'Y'
   AND NVL(ail.line_selected_for_release_flag,'N') <> 'Y'
 ORDER BY ai.creation_date;

CURSOR c_retained_lines_inv
		(c_invoice_id  IN ap_invoice_lines_all.invoice_id%TYPE,
		 c_line_number IN ap_invoice_lines_all.line_number%TYPE) Is
SELECT ai.invoice_currency_code,
       ai.exchange_rate,
       ail.*
  FROM ap_invoices_all		ai,
       ap_invoice_lines_all	ail
 WHERE ai.invoice_id   = ail.invoice_id
   AND ai.invoice_id   = c_invoice_id
   AND ail.line_number = c_line_number
 ORDER BY ai.creation_date;

TYPE retainedLinesType IS TABLE OF c_retained_lines_po%rowtype INDEX BY PLS_INTEGER;

retained_lines_tab	retainedLinesType;

End ap_retainage_release_pkg;

 

/
