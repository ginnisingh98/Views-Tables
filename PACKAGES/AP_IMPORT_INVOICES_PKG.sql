--------------------------------------------------------
--  DDL for Package AP_IMPORT_INVOICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_IMPORT_INVOICES_PKG" AUTHID CURRENT_USER AS
/* $Header: apiimpts.pls 120.32.12010000.9 2010/10/27 12:51:55 dawasthi ship $ */

-- Declaring the global variables
g_pa_allows_overrides            VARCHAR2(30) := 'N';
g_source                         VARCHAR2(80);
g_debug_switch                   VARCHAR2(1) := 'N';
g_inv_sysdate                    DATE;
g_program_application_id         NUMBER;
g_program_id                     NUMBER;
g_conc_request_id                NUMBER;
g_invoices_table                 VARCHAR2(30);
g_invoice_lines_table            VARCHAR2(30);
g_instructions_table             VARCHAR2(30);
g_segment_delimiter              VARCHAR2(10); -- 6349739 - for RETEK

-- Added for Payment Requests
g_invoice_id                     NUMBER;


-- For Period_name in            Get_item_line_info/
--                               Get_non_item_line_info
lg_many_controller               fnd_plsql_cache.cache_1tom_controller_type;
lg_generic_storage               fnd_plsql_cache.generic_cache_values_type;

-- For fnd_flex.validate_segs in v_check_line_project_info/
--                               v_check_line_account_info
lg_many_controller1              fnd_plsql_cache.cache_1tom_controller_type;
lg_generic_storage1              fnd_plsql_cache.generic_cache_values_type;

-- For gl_code_combinations in   get_item_line_info/
--                               insert_from_dis_sets/
--                               overlay_for_po_matched/
--                               get_non_item_line_info/
--                               prorate_dists
lg_many_controller2              fnd_plsql_cache.cache_1tom_controller_type;
lg_generic_storage2              fnd_plsql_cache.generic_cache_values_type;

-- Bug 5572876
lg_incometax_controller          fnd_plsql_cache.cache_1tom_controller_type;
lg_incometax_storage             fnd_plsql_cache.generic_cache_values_type;

-- Bug 5572876
lg_incometaxr_controller         fnd_plsql_cache.cache_1tom_controller_type;
lg_incometaxr_storage            fnd_plsql_cache.generic_cache_values_type;

TYPE r_invoice_info_rec IS RECORD (
invoice_id               AP_INVOICES_INTERFACE.invoice_id%TYPE,
invoice_num              AP_INVOICES_INTERFACE.invoice_num%TYPE,
invoice_type_lookup_code
          AP_INVOICES_INTERFACE.invoice_type_lookup_code%TYPE,
invoice_date             AP_INVOICES_INTERFACE.invoice_date%TYPE,
po_number                AP_INVOICES_INTERFACE.po_number%TYPE,
vendor_id                AP_INVOICES_INTERFACE.vendor_id%TYPE,
vendor_num               AP_INVOICES_INTERFACE.vendor_num%TYPE,
vendor_name              AP_INVOICES_INTERFACE.vendor_name%TYPE,
vendor_site_id           AP_INVOICES_INTERFACE.vendor_site_id%TYPE,
vendor_site_code         AP_INVOICES_INTERFACE.vendor_site_code%TYPE,
invoice_amount           AP_INVOICES_INTERFACE.invoice_amount%TYPE,
invoice_currency_code    AP_INVOICES_INTERFACE.invoice_currency_code%TYPE,
exchange_rate            AP_INVOICES_INTERFACE.exchange_rate%TYPE,
exchange_rate_type       AP_INVOICES_INTERFACE.exchange_rate_type%TYPE,
exchange_date            AP_INVOICES_INTERFACE.exchange_date%TYPE,
terms_id                 AP_INVOICES_INTERFACE.terms_id%TYPE,
terms_name               AP_INVOICES_INTERFACE.terms_name%TYPE,
terms_date               AP_INVOICES_INTERFACE.terms_date%TYPE,
description              AP_INVOICES_INTERFACE.description%TYPE,
awt_group_id             AP_INVOICES_INTERFACE.awt_group_id%TYPE,
awt_group_name           AP_INVOICES_INTERFACE.awt_group_name%TYPE,
pay_awt_group_id             AP_INVOICES_INTERFACE.pay_awt_group_id%TYPE,--bug6639866
pay_awt_group_name           AP_INVOICES_INTERFACE.pay_awt_group_name%TYPE,--bug6639866
amount_applicable_to_discount
          AP_INVOICES_INTERFACE.amount_applicable_to_discount%TYPE,
last_update_date         AP_INVOICES_INTERFACE.last_update_date%TYPE,
last_updated_by          AP_INVOICES_INTERFACE.last_updated_by%TYPE,
last_update_login        AP_INVOICES_INTERFACE.last_update_login%TYPE,
creation_date            AP_INVOICES_INTERFACE.creation_date%TYPE,
created_by               AP_INVOICES_INTERFACE.created_by%TYPE,
status                   AP_INVOICES_INTERFACE.status%TYPE,
attribute_category       AP_INVOICES_INTERFACE.attribute_category%TYPE,
attribute1               AP_INVOICES_INTERFACE.attribute1%TYPE,
attribute2               AP_INVOICES_INTERFACE.attribute2%TYPE,
attribute3               AP_INVOICES_INTERFACE.attribute3%TYPE,
attribute4               AP_INVOICES_INTERFACE.attribute4%TYPE,
attribute5               AP_INVOICES_INTERFACE.attribute5%TYPE,
attribute6               AP_INVOICES_INTERFACE.attribute6%TYPE,
attribute7               AP_INVOICES_INTERFACE.attribute7%TYPE,
attribute8               AP_INVOICES_INTERFACE.attribute8%TYPE,
attribute9               AP_INVOICES_INTERFACE.attribute9%TYPE,
attribute10              AP_INVOICES_INTERFACE.attribute10%TYPE,
attribute11              AP_INVOICES_INTERFACE.attribute11%TYPE,
attribute12              AP_INVOICES_INTERFACE.attribute12%TYPE,
attribute13              AP_INVOICES_INTERFACE.attribute13%TYPE,
attribute14              AP_INVOICES_INTERFACE.attribute14%TYPE,
attribute15              AP_INVOICES_INTERFACE.attribute15%TYPE,
global_attribute_category
          AP_INVOICES_INTERFACE.global_attribute_category%TYPE,
global_attribute1        AP_INVOICES_INTERFACE.global_attribute1%TYPE,
global_attribute2        AP_INVOICES_INTERFACE.global_attribute2%TYPE,
global_attribute3        AP_INVOICES_INTERFACE.global_attribute3%TYPE,
global_attribute4        AP_INVOICES_INTERFACE.global_attribute4%TYPE,
global_attribute5        AP_INVOICES_INTERFACE.global_attribute5%TYPE,
global_attribute6        AP_INVOICES_INTERFACE.global_attribute6%TYPE,
global_attribute7        AP_INVOICES_INTERFACE.global_attribute7%TYPE,
global_attribute8        AP_INVOICES_INTERFACE.global_attribute8%TYPE,
global_attribute9        AP_INVOICES_INTERFACE.global_attribute9%TYPE,
global_attribute10       AP_INVOICES_INTERFACE.global_attribute10%TYPE,
global_attribute11       AP_INVOICES_INTERFACE.global_attribute11%TYPE,
global_attribute12       AP_INVOICES_INTERFACE.global_attribute12%TYPE,
global_attribute13       AP_INVOICES_INTERFACE.global_attribute13%TYPE,
global_attribute14       AP_INVOICES_INTERFACE.global_attribute14%TYPE,
global_attribute15       AP_INVOICES_INTERFACE.global_attribute15%TYPE,
global_attribute16       AP_INVOICES_INTERFACE.global_attribute16%TYPE,
global_attribute17       AP_INVOICES_INTERFACE.global_attribute17%TYPE,
global_attribute18       AP_INVOICES_INTERFACE.global_attribute18%TYPE,
global_attribute19       AP_INVOICES_INTERFACE.global_attribute19%TYPE,
global_attribute20       AP_INVOICES_INTERFACE.global_attribute20%TYPE,
payment_currency_code    AP_INVOICES_INTERFACE.payment_currency_code%TYPE,
payment_cross_rate       AP_INVOICES_INTERFACE.payment_cross_rate%TYPE,
payment_cross_rate_type  AP_INVOICES_INTERFACE.payment_cross_rate_type%TYPE,
payment_cross_rate_date  AP_INVOICES_INTERFACE.payment_cross_rate_date%TYPE,
doc_category_code        AP_INVOICES_INTERFACE.doc_category_code%TYPE,
voucher_num              AP_INVOICES_INTERFACE.voucher_num%TYPE,
payment_method_code
          AP_INVOICES_INTERFACE.payment_method_code%TYPE,
pay_group_lookup_code    AP_INVOICES_INTERFACE.pay_group_lookup_code%TYPE,
goods_received_date      AP_INVOICES_INTERFACE.goods_received_date%TYPE,
invoice_received_date    AP_INVOICES_INTERFACE.invoice_received_date%TYPE,
gl_date                  AP_INVOICES_INTERFACE.gl_date%TYPE,
accts_pay_code_combination_id
          AP_INVOICES_INTERFACE.accts_pay_code_combination_id%TYPE,
-- bug 6509776 - added field
accts_pay_code_concatenated
          AP_INVOICES_INTERFACE.accts_pay_code_concatenated%TYPE,

--Removed for bug 4277744
--ussgl_transaction_code AP_INVOICES_INTERFACE.ussgl_transaction_code%TYPE,
exclusive_payment_flag   AP_INVOICES_INTERFACE.exclusive_payment_flag%TYPE,
prepay_num               AP_INVOICES_INTERFACE.prepay_num%TYPE,
prepay_line_num          AP_INVOICES_INTERFACE.prepay_line_num%TYPE,
prepay_apply_amount      AP_INVOICES_INTERFACE.prepay_apply_amount%TYPE,
prepay_gl_date           AP_INVOICES_INTERFACE.prepay_gl_date%TYPE,
invoice_includes_prepay_flag
          AP_INVOICES_INTERFACE.invoice_includes_prepay_flag%TYPE,
no_xrate_base_amount     AP_INVOICES_INTERFACE.no_xrate_base_amount%TYPE,
requester_id             AP_INVOICES_INTERFACE.requester_id%TYPE,
org_id                   AP_INVOICES_INTERFACE.org_id%TYPE,
operating_unit           AP_INVOICES_INTERFACE.operating_unit%TYPE,
source                   AP_INVOICES_INTERFACE.source%TYPE,
group_id                 AP_INVOICES_INTERFACE.group_id%TYPE,
request_id               AP_INVOICES_INTERFACE.request_id%TYPE,
workflow_flag            AP_INVOICES_INTERFACE.workflow_flag%TYPE,
vendor_email_address     AP_INVOICES_INTERFACE.vendor_email_address%TYPE,
calc_tax_during_import_flag
  AP_INVOICES_INTERFACE.calc_tax_during_import_flag%TYPE,
control_amount AP_INVOICES_INTERFACE.control_amount%TYPE,
add_tax_to_inv_amt_flag AP_INVOICES_INTERFACE.add_tax_to_inv_amt_flag%TYPE,
tax_related_invoice_id AP_INVOICES_INTERFACE.tax_related_invoice_id%TYPE,
taxation_country AP_INVOICES_INTERFACE.taxation_country%TYPE,
document_sub_type AP_INVOICES_INTERFACE.document_sub_type%TYPE,
supplier_tax_invoice_number
  AP_INVOICES_INTERFACE.supplier_tax_invoice_number%TYPE,
supplier_tax_invoice_date
  AP_INVOICES_INTERFACE.supplier_tax_invoice_date%TYPE,
supplier_tax_exchange_rate
  AP_INVOICES_INTERFACE.supplier_tax_exchange_rate%TYPE,
tax_invoice_recording_date
  AP_INVOICES_INTERFACE.tax_invoice_recording_date%TYPE,
tax_invoice_internal_seq
  AP_INVOICES_INTERFACE.tax_invoice_internal_seq%TYPE,
legal_entity_id AP_INVOICES_INTERFACE.legal_entity_id%TYPE,
set_of_books_id AP_SYSTEM_PARAMETERS_ALL.set_of_books_id%TYPE,
tax_only_rcv_matched_flag VARCHAR2(1),
tax_only_flag VARCHAR2(1),
apply_advances_flag      AP_INVOICES_INTERFACE.apply_advances_flag%TYPE,
application_id	AP_INVOICES_INTERFACE.application_id%TYPE,
product_table	AP_INVOICES_INTERFACE.product_table%TYPE,
reference_key1  AP_INVOICES_INTERFACE.reference_key1%TYPE,
reference_key2  AP_INVOICES_INTERFACE.reference_key2%TYPE,
reference_key3  AP_INVOICES_INTERFACE.reference_key3%TYPE,
reference_key4  AP_INVOICES_INTERFACE.reference_key4%TYPE,
reference_key5  AP_INVOICES_INTERFACE.reference_key5%TYPE,
reference_1	AP_INVOICES_INTERFACE.reference_1%TYPE,
reference_2	AP_INVOICES_INTERFACE.reference_2%TYPE,
net_of_retainage_flag AP_INVOICES_INTERFACE.net_of_retainage_flag%TYPE,
cust_registration_code AP_INVOICES_INTERFACE.cust_registration_code%TYPE,
cust_registration_number AP_INVOICES_INTERFACE.cust_registration_number%TYPE,
paid_on_behalf_employee_id AP_INVOICES_INTERFACE.paid_on_behalf_employee_id%TYPE,
party_id                   AP_INVOICES_INTERFACE.party_id%TYPE,
party_site_id              AP_INVOICES_INTERFACE.party_site_id%TYPE,
pay_proc_trxn_type_code    AP_INVOICES_INTERFACE.pay_proc_trxn_type_code%TYPE,
payment_function           AP_INVOICES_INTERFACE.payment_function%TYPE,
payment_priority           AP_INVOICES_INTERFACE.payment_priority%TYPE,
BANK_CHARGE_BEARER         AP_INVOICES_INTERFACE.BANK_CHARGE_BEARER%TYPE,
REMITTANCE_MESSAGE1        AP_INVOICES_INTERFACE.REMITTANCE_MESSAGE1%TYPE,
REMITTANCE_MESSAGE2        AP_INVOICES_INTERFACE.REMITTANCE_MESSAGE2%TYPE,
REMITTANCE_MESSAGE3        AP_INVOICES_INTERFACE.REMITTANCE_MESSAGE3%TYPE,
UNIQUE_REMITTANCE_IDENTIFIER
                     AP_INVOICES_INTERFACE.UNIQUE_REMITTANCE_IDENTIFIER%TYPE,
URI_CHECK_DIGIT            AP_INVOICES_INTERFACE.URI_CHECK_DIGIT%TYPE,
SETTLEMENT_PRIORITY        AP_INVOICES_INTERFACE.SETTLEMENT_PRIORITY%TYPE,
PAYMENT_REASON_CODE        AP_INVOICES_INTERFACE.PAYMENT_REASON_CODE%TYPE,
PAYMENT_REASON_COMMENTS    AP_INVOICES_INTERFACE.PAYMENT_REASON_COMMENTS%TYPE,
DELIVERY_CHANNEL_CODE      AP_INVOICES_INTERFACE.DELIVERY_CHANNEL_CODE%TYPE,
EXTERNAL_BANK_ACCOUNT_ID   AP_INVOICES_INTERFACE.EXTERNAL_BANK_ACCOUNT_ID %TYPE,
--Bug 7357218 Quick Pay and Dispute Resolution Project
ORIGINAL_INVOICE_AMOUNT    AP_INVOICES_INTERFACE.ORIGINAL_INVOICE_AMOUNT%TYPE,
DISPUTE_REASON             AP_INVOICES_INTERFACE.DISPUTE_REASON%TYPE,
--Third party payments
REMIT_TO_SUPPLIER_NAME	AP_INVOICES_INTERFACE.REMIT_TO_SUPPLIER_NAME%TYPE,
REMIT_TO_SUPPLIER_ID	 	AP_INVOICES_INTERFACE.REMIT_TO_SUPPLIER_ID%TYPE,
REMIT_TO_SUPPLIER_SITE	AP_INVOICES_INTERFACE.REMIT_TO_SUPPLIER_SITE%TYPE,
REMIT_TO_SUPPLIER_SITE_ID	AP_INVOICES_INTERFACE.REMIT_TO_SUPPLIER_SITE_ID%TYPE,
RELATIONSHIP_ID			AP_INVOICES_INTERFACE.RELATIONSHIP_ID%TYPE,
REMIT_TO_SUPPLIER_NUM	AP_INVOICES_INTERFACE.REMIT_TO_SUPPLIER_NUM%TYPE
/* Added for bug 10226070 */
,REQUESTER_LAST_NAME      AP_INVOICES_INTERFACE.REQUESTER_LAST_NAME%TYPE
,REQUESTER_FIRST_NAME     AP_INVOICES_INTERFACE.REQUESTER_FIRST_NAME%TYPE
 );

-- Retropricing
TYPE t_invoice_table is TABLE of r_invoice_info_rec
                 index by BINARY_INTEGER;
-- Retropricing
TYPE r_line_info_rec IS RECORD (
row_id                   ROWID,
invoice_line_id          AP_INVOICE_LINES_INTERFACE.invoice_line_id%TYPE,
line_type_lookup_code    AP_INVOICE_LINES_INTERFACE.line_type_lookup_code%TYPE,
line_number              AP_INVOICE_LINES_INTERFACE.line_number%TYPE,
line_group_number        AP_INVOICE_LINES_INTERFACE.line_group_number%TYPE,
amount                   AP_INVOICE_LINES_INTERFACE.amount%TYPE,
base_amount              AP_INVOICE_LINES_INTERFACE.amount%TYPE,
accounting_date          AP_INVOICE_LINES_INTERFACE.accounting_date%TYPE,
period_name              AP_INVOICE_LINES.period_name%TYPE,
deferred_acctg_flag      AP_INVOICE_LINES_INTERFACE.deferred_acctg_flag%TYPE,
def_acctg_start_date     AP_INVOICE_LINES_INTERFACE.def_acctg_start_date%TYPE,
def_acctg_end_date       AP_INVOICE_LINES_INTERFACE.def_acctg_end_date%TYPE,
def_acctg_number_of_periods
          AP_INVOICE_LINES_INTERFACE.def_acctg_number_of_periods%TYPE,
def_acctg_period_type    AP_INVOICE_LINES_INTERFACE.def_acctg_period_type%TYPE,
description              AP_INVOICE_LINES_INTERFACE.description%TYPE,
prorate_across_flag      AP_INVOICE_LINES_INTERFACE.prorate_across_flag%TYPE,
match_type               AP_INVOICE_LINES.MATCH_TYPE%TYPE,
po_header_id             AP_INVOICE_LINES_INTERFACE.po_header_id%TYPE,
po_number                AP_INVOICE_LINES_INTERFACE.po_number%TYPE,
po_line_id               AP_INVOICE_LINES_INTERFACE.po_line_id%TYPE,
po_line_number           AP_INVOICE_LINES_INTERFACE.po_line_number%TYPE,
po_release_id            AP_INVOICE_LINES_INTERFACE.po_release_id%TYPE,
release_num              AP_INVOICE_LINES_INTERFACE.release_num%TYPE,
po_line_location_id      AP_INVOICE_LINES_INTERFACE.po_line_location_id%TYPE,
po_shipment_num          AP_INVOICE_LINES_INTERFACE.po_shipment_num%TYPE,
po_distribution_id       AP_INVOICE_LINES_INTERFACE.po_distribution_id%TYPE,
po_distribution_num      AP_INVOICE_LINES_INTERFACE.po_distribution_num%TYPE,
unit_of_meas_lookup_code
          AP_INVOICE_LINES_INTERFACE.unit_of_meas_lookup_code%TYPE,
inventory_item_id        AP_INVOICE_LINES_INTERFACE.inventory_item_id%TYPE,
item_description         AP_INVOICE_LINES_INTERFACE.item_description%TYPE,
quantity_invoiced        AP_INVOICE_LINES_INTERFACE.quantity_invoiced%TYPE,
ship_to_location_code    AP_INVOICE_LINES_INTERFACE.ship_to_location_code%TYPE,
unit_price               AP_INVOICE_LINES_INTERFACE.unit_price%TYPE,
final_match_flag         AP_INVOICE_LINES_INTERFACE.final_match_flag%TYPE,
distribution_set_id      AP_INVOICE_LINES_INTERFACE.distribution_set_id%TYPE,
distribution_set_name    AP_INVOICE_LINES_INTERFACE.distribution_set_name%TYPE,
partial_segments         VARCHAR2(1),
dist_code_concatenated   AP_INVOICE_LINES_INTERFACE.dist_code_concatenated%TYPE,
dist_code_combination_id
          AP_INVOICE_LINES_INTERFACE.dist_code_combination_id%TYPE,
awt_group_id             AP_INVOICE_LINES_INTERFACE.awt_group_id%TYPE,
awt_group_name           AP_INVOICE_LINES_INTERFACE.awt_group_name%TYPE,
pay_awt_group_id         AP_INVOICE_LINES_INTERFACE.pay_awt_group_id%TYPE,--bug6639866
pay_awt_group_name       AP_INVOICE_LINES_INTERFACE.pay_awt_group_name%TYPE,--bug6639866
balancing_segment        AP_INVOICE_LINES_INTERFACE.balancing_segment%TYPE,
cost_center_segment      AP_INVOICE_LINES_INTERFACE.cost_center_segment%TYPE,
account_segment          AP_INVOICE_LINES_INTERFACE.account_segment%TYPE,
attribute_category       AP_INVOICE_LINES_INTERFACE.attribute_category%TYPE,
attribute1               AP_INVOICE_LINES_INTERFACE.attribute1%TYPE,
attribute2               AP_INVOICE_LINES_INTERFACE.attribute2%TYPE,
attribute3               AP_INVOICE_LINES_INTERFACE.attribute3%TYPE,
attribute4               AP_INVOICE_LINES_INTERFACE.attribute4%TYPE,
attribute5               AP_INVOICE_LINES_INTERFACE.attribute5%TYPE,
attribute6               AP_INVOICE_LINES_INTERFACE.attribute6%TYPE,
attribute7               AP_INVOICE_LINES_INTERFACE.attribute7%TYPE,
attribute8               AP_INVOICE_LINES_INTERFACE.attribute8%TYPE,
attribute9               AP_INVOICE_LINES_INTERFACE.attribute9%TYPE,
attribute10              AP_INVOICE_LINES_INTERFACE.attribute10%TYPE,
attribute11              AP_INVOICE_LINES_INTERFACE.attribute11%TYPE,
attribute12              AP_INVOICE_LINES_INTERFACE.attribute12%TYPE,
attribute13              AP_INVOICE_LINES_INTERFACE.attribute13%TYPE,
attribute14              AP_INVOICE_LINES_INTERFACE.attribute14%TYPE,
attribute15              AP_INVOICE_LINES_INTERFACE.attribute15%TYPE,
global_attribute_category
          AP_INVOICE_LINES_INTERFACE.global_attribute_category%TYPE,
global_attribute1        AP_INVOICE_LINES_INTERFACE.global_attribute1%TYPE,
global_attribute2        AP_INVOICE_LINES_INTERFACE.global_attribute2%TYPE,
global_attribute3        AP_INVOICE_LINES_INTERFACE.global_attribute3%TYPE,
global_attribute4        AP_INVOICE_LINES_INTERFACE.global_attribute4%TYPE,
global_attribute5        AP_INVOICE_LINES_INTERFACE.global_attribute5%TYPE,
global_attribute6        AP_INVOICE_LINES_INTERFACE.global_attribute6%TYPE,
global_attribute7        AP_INVOICE_LINES_INTERFACE.global_attribute7%TYPE,
global_attribute8        AP_INVOICE_LINES_INTERFACE.global_attribute8%TYPE,
global_attribute9        AP_INVOICE_LINES_INTERFACE.global_attribute9%TYPE,
global_attribute10       AP_INVOICE_LINES_INTERFACE.global_attribute10%TYPE,
global_attribute11       AP_INVOICE_LINES_INTERFACE.global_attribute11%TYPE,
global_attribute12       AP_INVOICE_LINES_INTERFACE.global_attribute12%TYPE,
global_attribute13       AP_INVOICE_LINES_INTERFACE.global_attribute13%TYPE,
global_attribute14       AP_INVOICE_LINES_INTERFACE.global_attribute14%TYPE,
global_attribute15       AP_INVOICE_LINES_INTERFACE.global_attribute15%TYPE,
global_attribute16       AP_INVOICE_LINES_INTERFACE.global_attribute16%TYPE,
global_attribute17       AP_INVOICE_LINES_INTERFACE.global_attribute17%TYPE,
global_attribute18       AP_INVOICE_LINES_INTERFACE.global_attribute18%TYPE,
global_attribute19       AP_INVOICE_LINES_INTERFACE.global_attribute19%TYPE,
global_attribute20       AP_INVOICE_LINES_INTERFACE.global_attribute20%TYPE,
project_id               AP_INVOICE_LINES_INTERFACE.project_id%TYPE,
task_id                  AP_INVOICE_LINES_INTERFACE.task_id%TYPE,
award_id                 AP_INVOICE_LINES_INTERFACE.award_id%TYPE,
expenditure_type         AP_INVOICE_LINES_INTERFACE.expenditure_type%TYPE,
expenditure_item_date    AP_INVOICE_LINES_INTERFACE.expenditure_item_date%TYPE,
expenditure_organization_id
          AP_INVOICE_LINES_INTERFACE.expenditure_organization_id%TYPE,
pa_addition_flag         AP_INVOICE_LINES_INTERFACE.pa_addition_flag%TYPE,
pa_quantity              AP_INVOICE_LINES_INTERFACE.pa_quantity%TYPE,
--Removed for bug 4277744
--ussgl_transaction_code AP_INVOICE_LINES_INTERFACE.ussgl_transaction_code%TYPE,
stat_amount              AP_INVOICE_LINES_INTERFACE.stat_amount%TYPE,
type_1099                AP_INVOICE_LINES_INTERFACE.type_1099%TYPE,
income_tax_region        AP_INVOICE_LINES_INTERFACE.income_tax_region%TYPE,
assets_tracking_flag     AP_INVOICE_LINES_INTERFACE.assets_tracking_flag%TYPE,
asset_book_type_code     AP_INVOICE_LINES_INTERFACE.asset_book_type_code%TYPE,
asset_category_id        AP_INVOICE_LINES_INTERFACE.asset_category_id%TYPE,
serial_number            AP_INVOICE_LINES_INTERFACE.serial_number%TYPE,
manufacturer             AP_INVOICE_LINES_INTERFACE.manufacturer%TYPE,
model_number             AP_INVOICE_LINES_INTERFACE.model_number%TYPE,
warranty_number          AP_INVOICE_LINES_INTERFACE.warranty_number%TYPE,
price_correction_flag    AP_INVOICE_LINES_INTERFACE.price_correction_flag%TYPE,
price_correct_inv_num    AP_INVOICE_LINES_INTERFACE.price_correct_inv_num%TYPE,
corrected_inv_id         AP_INVOICE_LINES_ALL.corrected_inv_id%TYPE,
price_correct_inv_line_num
          AP_INVOICE_LINES_INTERFACE.price_correct_inv_line_num%TYPE,
receipt_number           AP_INVOICE_LINES_INTERFACE.receipt_number%TYPE,
receipt_line_number      AP_INVOICE_LINES_INTERFACE.receipt_line_number%TYPE,
rcv_transaction_id       AP_INVOICE_LINES_INTERFACE.rcv_transaction_id%TYPE,
-- bug 7344899 - added field
rcv_shipment_line_id	 AP_INVOICE_LINES.RCV_SHIPMENT_LINE_ID%TYPE,
match_option             AP_INVOICE_LINES_INTERFACE.match_option%TYPE,
packing_slip             AP_INVOICE_LINES_INTERFACE.packing_slip%TYPE,
vendor_item_num          AP_INVOICE_LINES_INTERFACE.vendor_item_num%TYPE,
taxable_flag             AP_INVOICE_LINES_INTERFACE.taxable_flag%TYPE,
pa_cc_ar_invoice_id      AP_INVOICE_LINES_INTERFACE.pa_cc_ar_invoice_id%TYPE,
pa_cc_ar_invoice_line_num
          AP_INVOICE_LINES_INTERFACE.pa_cc_ar_invoice_line_num%TYPE,
pa_cc_processed_code     AP_INVOICE_LINES_INTERFACE.pa_cc_processed_code%TYPE,
reference_1              AP_INVOICE_LINES_INTERFACE.reference_1%TYPE,
reference_2              AP_INVOICE_LINES_INTERFACE.reference_2%TYPE,
credit_card_trx_id       AP_INVOICE_LINES_INTERFACE.credit_card_trx_id%TYPE,
requester_id             AP_INVOICE_LINES_INTERFACE.requester_id%TYPE,
org_id                   AP_INVOICE_LINES_INTERFACE.org_id%TYPE,
program_application_id   AP_INVOICE_LINES.PROGRAM_APPLICATION_ID%TYPE,
program_id               AP_INVOICE_LINES.PROGRAM_ID%TYPE,
request_id               AP_INVOICE_LINES.REQUEST_ID%TYPE,
program_update_date      AP_INVOICE_LINES.PROGRAM_UPDATE_DATE%TYPE,
control_amount           AP_INVOICE_LINES_INTERFACE.control_amount%TYPE,
assessable_value         AP_INVOICE_LINES_INTERFACE.assessable_value%TYPE,
default_dist_ccid        AP_INVOICE_LINES_INTERFACE.default_dist_ccid%TYPE,
primary_intended_use     AP_INVOICE_LINES_INTERFACE.primary_intended_use%TYPE,
ship_to_location_id      AP_INVOICE_LINES_INTERFACE.ship_to_location_id%TYPE,
product_type             AP_INVOICE_LINES_INTERFACE.product_type%TYPE,
product_category         AP_INVOICE_LINES_INTERFACE.product_category%TYPE,
product_fisc_classification
  AP_INVOICE_LINES_INTERFACE.product_fisc_classification%TYPE,
user_defined_fisc_class  AP_INVOICE_LINES_INTERFACE.user_defined_fisc_class%TYPE,
trx_business_category    AP_INVOICE_LINES_INTERFACE.trx_business_category%TYPE,
tax_regime_code          AP_INVOICE_LINES_INTERFACE.tax_regime_code%TYPE,
tax                      AP_INVOICE_LINES_INTERFACE.tax%TYPE,
tax_jurisdiction_code    AP_INVOICE_LINES_INTERFACE.tax_jurisdiction_code%TYPE,
tax_status_code          AP_INVOICE_LINES_INTERFACE.tax_status_code%TYPE,
tax_rate_id              AP_INVOICE_LINES_INTERFACE.tax_rate_id%TYPE,
tax_rate_code            AP_INVOICE_LINES_INTERFACE.tax_rate_code%TYPE,
tax_rate                 AP_INVOICE_LINES_INTERFACE.tax_rate%TYPE,
incl_in_taxable_line_flag
  AP_INVOICE_LINES_INTERFACE.incl_in_taxable_line_flag%TYPE,
application_id	AP_INVOICE_LINES_INTERFACE.application_id%TYPE,
product_table	AP_INVOICE_LINES_INTERFACE.product_table%TYPE,
reference_key1  AP_INVOICE_LINES_INTERFACE.reference_key1%TYPE,
reference_key2  AP_INVOICE_LINES_INTERFACE.reference_key2%TYPE,
reference_key3  AP_INVOICE_LINES_INTERFACE.reference_key3%TYPE,
reference_key4  AP_INVOICE_LINES_INTERFACE.reference_key4%TYPE,
reference_key5  AP_INVOICE_LINES_INTERFACE.reference_key5%TYPE,
purchasing_category_id AP_INVOICE_LINES_INTERFACE.purchasing_category_id%TYPE,
purchasing_category   VARCHAR2(2000),
cost_factor_id  AP_INVOICE_LINES_INTERFACE.cost_factor_id%TYPE,
cost_factor_name AP_INVOICE_LINES_INTERFACE.cost_factor_name%TYPE,
source_application_id   AP_INVOICE_LINES_INTERFACE.source_application_id%TYPE,
source_entity_code      AP_INVOICE_LINES_INTERFACE.source_entity_code%TYPE,
source_event_class_code AP_INVOICE_LINES_INTERFACE.source_event_class_code%TYPE,
source_trx_id           AP_INVOICE_LINES_INTERFACE.source_trx_id%TYPE,
source_line_id          AP_INVOICE_LINES_INTERFACE.source_line_id%TYPE,
source_trx_level_type   AP_INVOICE_LINES_INTERFACE.source_trx_level_type%TYPE,
tax_classification_code AP_INVOICE_LINES_INTERFACE.tax_classification_code%TYPE,
retained_amount		AP_INVOICE_LINES_ALL.retained_amount%TYPE,
amount_includes_tax_flag AP_INVOICE_LINES_INTERFACE.amount_includes_tax_flag%TYPE,
--Bug6167068 starts Added the following columns to record
CC_REVERSAL_FLAG                AP_INVOICE_LINES_INTERFACE.CC_REVERSAL_FLAG%TYPE,
COMPANY_PREPAID_INVOICE_ID	AP_INVOICE_LINES_INTERFACE.COMPANY_PREPAID_INVOICE_ID%TYPE,
EXPENSE_GROUP                   AP_INVOICE_LINES_INTERFACE.EXPENSE_GROUP%TYPE,
JUSTIFICATION                   AP_INVOICE_LINES_INTERFACE.JUSTIFICATION%TYPE,
MERCHANT_DOCUMENT_NUMBER        AP_INVOICE_LINES_INTERFACE.MERCHANT_DOCUMENT_NUMBER%TYPE,
MERCHANT_NAME                   AP_INVOICE_LINES_INTERFACE.MERCHANT_NAME%TYPE,
MERCHANT_REFERENCE              AP_INVOICE_LINES_INTERFACE.MERCHANT_REFERENCE%TYPE,
MERCHANT_TAXPAYER_ID            AP_INVOICE_LINES_INTERFACE.MERCHANT_TAXPAYER_ID%TYPE,
MERCHANT_TAX_REG_NUMBER         AP_INVOICE_LINES_INTERFACE.MERCHANT_TAX_REG_NUMBER%TYPE,
RECEIPT_CONVERSION_RATE         AP_INVOICE_LINES_INTERFACE.RECEIPT_CONVERSION_RATE%TYPE,
RECEIPT_CURRENCY_AMOUNT         AP_INVOICE_LINES_INTERFACE.RECEIPT_CURRENCY_AMOUNT%TYPE,
RECEIPT_CURRENCY_CODE           AP_INVOICE_LINES_INTERFACE.RECEIPT_CURRENCY_CODE%TYPE,
COUNTRY_OF_SUPPLY               AP_INVOICE_LINES_INTERFACE.COUNTRY_OF_SUPPLY%TYPE
--Bug6167068 ends

--Bug 8658097 starts
,EXPENSE_START_DATE		AP_INVOICE_LINES_INTERFACE.EXPENSE_START_DATE%TYPE
,EXPENSE_END_DATE		AP_INVOICE_LINES_INTERFACE.EXPENSE_END_DATE%TYPE
--Bug 8658097 ends
/* Added for bug 10226070 */
,REQUESTER_LAST_NAME      AP_INVOICE_LINES_INTERFACE.REQUESTER_LAST_NAME%TYPE
,REQUESTER_FIRST_NAME     AP_INVOICE_LINES_INTERFACE.REQUESTER_FIRST_NAME%TYPE
);


TYPE t_lines_table is TABLE of r_line_info_rec
                 index by BINARY_INTEGER;


TYPE rejection_rec_type IS RECORD
  (parent_table         AP_INTERFACE_REJECTIONS.parent_table%TYPE,
   parent_id            AP_INTERFACE_REJECTIONS.parent_id%TYPE,
   reject_lookup_code   AP_INTERFACE_REJECTIONS.reject_lookup_code%TYPE);

TYPE rejection_tab_type IS TABLE OF rejection_rec_type
                 index by BINARY_INTEGER;

-- Bug 5448579. Following new variables are added
TYPE moac_ou_rec_type IS RECORD
  (org_id                  HR_OPERATING_UNITS.Organization_Id%TYPE,
   org_name                HR_OPERATING_UNITS.Name%TYPE);

TYPE moac_ou_tab_type IS TABLE OF moac_ou_rec_type
                index by BINARY_INTEGER;

TYPE fsp_org_rec_type IS RECORD
  (org_id                  FINANCIALS_SYSTEM_PARAMS_ALL.Org_Id%TYPE);

TYPE fsp_org_tab_type IS TABLE OF fsp_org_rec_type
                index by BINARY_INTEGER;

TYPE pay_group_rec_type IS RECORD
  (pay_group          PO_LOOKUP_CODES.Lookup_Code%Type);

TYPE pay_group_tab_type IS TABLE OF pay_group_rec_type
                index by BINARY_INTEGER;

TYPE payment_method_rec_type IS RECORD
  (payment_method          IBY_PAYMENT_METHODS_VL.Payment_Method_Code%Type);

TYPE payment_method_tab_type IS TABLE OF payment_method_rec_type
                index by BINARY_INTEGER;

TYPE fnd_currency_rec_type IS RECORD
  (currency_code           FND_CURRENCIES.currency_code%TYPE,
   start_date_active       FND_CURRENCIES.start_date_active%TYPE,
   end_date_active         FND_CURRENCIES.end_date_active%TYPE,
   minimum_accountable_unit FND_CURRENCIES.minimum_accountable_unit%TYPE,
   precision               FND_CURRENCIES.precision%TYPE,
   enabled_flag            FND_CURRENCIES.enabled_flag%TYPE);

TYPE fnd_currency_tab_type IS TABLE OF fnd_currency_rec_type
                index by BINARY_INTEGER;

g_moac_ou_tab              moac_ou_tab_type;
g_fsp_ou_tab               fsp_org_tab_type;
g_pay_group_tab            pay_group_tab_type;
g_payment_method_tab       payment_method_tab_type;
g_fnd_currency_tab         fnd_currency_tab_type;
g_structure_id             mtl_default_sets_view.structure_id%TYPE;

FUNCTION IMPORT_INVOICES(
    p_batch_name           IN             VARCHAR2,
    p_gl_date              IN             DATE,
    p_hold_code            IN             VARCHAR2,
    p_hold_reason          IN             VARCHAR2,
    p_commit_cycles        IN             NUMBER,
    p_source               IN             VARCHAR2,
    p_group_id             IN             VARCHAR2,
    p_conc_request_id      IN             NUMBER,
    p_debug_switch         IN             VARCHAR2,
    p_org_id               IN             NUMBER,
    p_batch_error_flag        OUT NOCOPY  VARCHAR2,
    p_invoices_fetched        OUT NOCOPY  NUMBER,
    p_invoices_created        OUT NOCOPY  NUMBER,
    p_total_invoice_amount    OUT NOCOPY  NUMBER,
    p_print_batch             OUT NOCOPY  VARCHAR2,
    p_calling_sequence     IN             VARCHAR2,
    p_invoice_interface_id IN             NUMBER DEFAULT NULL,
    p_needs_invoice_approval  IN          VARCHAR2 DEFAULT 'N',
    p_commit                  IN          VARCHAR2 DEFAULT 'Y') RETURN BOOLEAN;


FUNCTION IMPORT_PURGE(
    p_source               IN             VARCHAR2,
    p_group_id             IN             VARCHAR2,
    p_org_id               IN             NUMBER,
    p_commit_cycles        IN             NUMBER,
    p_calling_sequence     IN             VARCHAR2) RETURN BOOLEAN;

FUNCTION XML_IMPORT_PURGE(
    p_group_id             IN             VARCHAR2,
    p_calling_sequence     IN             VARCHAR2) RETURN BOOLEAN;


PROCEDURE SUBMIT_PAYMENT_REQUEST(
    p_api_version             IN          VARCHAR2 DEFAULT '1.0',
    p_invoice_interface_id    IN          NUMBER,
    p_budget_control          IN          VARCHAR2 DEFAULT 'Y',
    p_needs_invoice_approval  IN          VARCHAR2 DEFAULT 'N',
    p_invoice_id              OUT NOCOPY  NUMBER,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    x_rejection_list          OUT NOCOPY  rejection_tab_type,
    p_calling_sequence        IN          VARCHAR2,
    p_commit                  IN          VARCHAR2 DEFAULT 'Y',
    p_batch_name              IN          VARCHAR2 DEFAULT NULL, --Bug 8361660
    p_conc_request_id         IN          NUMBER   DEFAULT NULL  --Bug 8492591
);


END AP_IMPORT_INVOICES_PKG;

/
