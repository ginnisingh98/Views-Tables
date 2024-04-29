--------------------------------------------------------
--  DDL for Package Body POS_VENDOR_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_VENDOR_PUB_PKG" AS
/* $Header: POSVNDRB.pls 120.47.12010000.20 2011/10/28 13:31:46 ashgup ship $ */

g_module_name VARCHAR2(30) := 'POS_VENDOR_PUB_PKG';

PROCEDURE log_vendor_rec
  (p_vendor_rec IN ap_vendor_pub_pkg.r_vendor_rec_type, p_flow IN VARCHAR2)
  IS
BEGIN

   IF (fnd_log.level_procedure < fnd_log.g_current_runtime_level) THEN
      RETURN;
   END IF;

   pos_log.set_msg_prefix(p_flow || ': p_vendor_rec');
   pos_log.set_msg_module(g_module_name);

   pos_log.log_field('vendor_id', p_vendor_rec.vendor_id);
   pos_log.log_field('segment1', p_vendor_rec.segment1);
   pos_log.log_field('vendor_name', p_vendor_rec.vendor_name);
   pos_log.log_field('vendor_name_alt', p_vendor_rec.vendor_name_alt);
   pos_log.log_field('summary_flag', p_vendor_rec.summary_flag);
   pos_log.log_field('enabled_flag', p_vendor_rec.enabled_flag);
   pos_log.log_field('segment2', p_vendor_rec.segment2);
   pos_log.log_field('segment3', p_vendor_rec.segment3);
   pos_log.log_field('segment4', p_vendor_rec.segment4);
   pos_log.log_field('segment5', p_vendor_rec.segment5);
   pos_log.log_field('employee_id', p_vendor_rec.employee_id);
   pos_log.log_field('vendor_type_lookup_code', p_vendor_rec.vendor_type_lookup_code);
   pos_log.log_field('customer_num', p_vendor_rec.customer_num);
   pos_log.log_field('one_time_flag', p_vendor_rec.one_time_flag);
   pos_log.log_field('parent_vendor_id', p_vendor_rec.parent_vendor_id);
   pos_log.log_field('min_order_amount', p_vendor_rec.min_order_amount);
   pos_log.log_field('terms_id', p_vendor_rec.terms_id);
   pos_log.log_field('set_of_books_id', p_vendor_rec.set_of_books_id);
   pos_log.log_field('always_take_disc_flag', p_vendor_rec.always_take_disc_flag);
   pos_log.log_field('pay_date_basis_lookup_code', p_vendor_rec.pay_date_basis_lookup_code);
   pos_log.log_field('pay_group_lookup_code', p_vendor_rec.pay_group_lookup_code);
   pos_log.log_field('payment_priority', p_vendor_rec.payment_priority);
   pos_log.log_field('invoice_currency_code', p_vendor_rec.invoice_currency_code);
   pos_log.log_field('payment_currency_code', p_vendor_rec.payment_currency_code);
   pos_log.log_field('invoice_amount_limit', p_vendor_rec.invoice_amount_limit);
   pos_log.log_field('hold_all_payments_flag', p_vendor_rec.hold_all_payments_flag);
   pos_log.log_field('hold_future_payments_flag', p_vendor_rec.hold_future_payments_flag);
   pos_log.log_field('hold_reason', p_vendor_rec.hold_reason);
   pos_log.log_field('type_1099', p_vendor_rec.type_1099);
   pos_log.log_field('withholding_status_lookup_code', p_vendor_rec.withholding_status_lookup_code);
   pos_log.log_field('withholding_start_date', p_vendor_rec.withholding_start_date);
   pos_log.log_field('organization_type_lookup_code', p_vendor_rec.organization_type_lookup_code);
   pos_log.log_field('start_date_active', p_vendor_rec.start_date_active);
   pos_log.log_field('end_date_active', p_vendor_rec.end_date_active);
   pos_log.log_field('minority_group_lookup_code', p_vendor_rec.minority_group_lookup_code);
   pos_log.log_field('women_owned_flag', p_vendor_rec.women_owned_flag);
   pos_log.log_field('small_business_flag', p_vendor_rec.small_business_flag);
   pos_log.log_field('hold_flag', p_vendor_rec.hold_flag);
   pos_log.log_field('purchasing_hold_reason', p_vendor_rec.purchasing_hold_reason);
   pos_log.log_field('hold_by', p_vendor_rec.hold_by);
   pos_log.log_field('hold_date', p_vendor_rec.hold_date);
   pos_log.log_field('terms_date_basis', p_vendor_rec.terms_date_basis);
   pos_log.log_field('inspection_required_flag', p_vendor_rec.inspection_required_flag);
   pos_log.log_field('receipt_required_flag', p_vendor_rec.receipt_required_flag);
   pos_log.log_field('qty_rcv_tolerance', p_vendor_rec.qty_rcv_tolerance);
   pos_log.log_field('qty_rcv_exception_code', p_vendor_rec.qty_rcv_exception_code);
   pos_log.log_field('enforce_ship_to_location_code', p_vendor_rec.enforce_ship_to_location_code);
   pos_log.log_field('days_early_receipt_allowed', p_vendor_rec.days_early_receipt_allowed);
   pos_log.log_field('days_late_receipt_allowed', p_vendor_rec.days_late_receipt_allowed);
   pos_log.log_field('receipt_days_exception_code', p_vendor_rec.receipt_days_exception_code);
   pos_log.log_field('receiving_routing_id', p_vendor_rec.receiving_routing_id);
   pos_log.log_field('allow_substitute_receipts_flag', p_vendor_rec.allow_substitute_receipts_flag);
   pos_log.log_field('allow_unordered_receipts_flag', p_vendor_rec.allow_unordered_receipts_flag);
   pos_log.log_field('hold_unmatched_invoices_flag', p_vendor_rec.hold_unmatched_invoices_flag);
   pos_log.log_field('tax_verification_date', p_vendor_rec.tax_verification_date);
   pos_log.log_field('name_control', p_vendor_rec.name_control);
   pos_log.log_field('state_reportable_flag', p_vendor_rec.state_reportable_flag);
   pos_log.log_field('federal_reportable_flag', p_vendor_rec.federal_reportable_flag);
   pos_log.log_field('attribute_category', p_vendor_rec.attribute_category);
   pos_log.log_field('attribute1', p_vendor_rec.attribute1);
   pos_log.log_field('attribute2', p_vendor_rec.attribute2);
   pos_log.log_field('attribute3', p_vendor_rec.attribute3);
   pos_log.log_field('attribute4', p_vendor_rec.attribute4);
   pos_log.log_field('attribute5', p_vendor_rec.attribute5);
   pos_log.log_field('attribute6', p_vendor_rec.attribute6);
   pos_log.log_field('attribute7', p_vendor_rec.attribute7);
   pos_log.log_field('attribute8', p_vendor_rec.attribute8);
   pos_log.log_field('attribute9', p_vendor_rec.attribute9);
   pos_log.log_field('attribute10', p_vendor_rec.attribute10);
   pos_log.log_field('attribute11', p_vendor_rec.attribute11);
   pos_log.log_field('attribute12', p_vendor_rec.attribute12);
   pos_log.log_field('attribute13', p_vendor_rec.attribute13);
   pos_log.log_field('attribute14', p_vendor_rec.attribute14);
   pos_log.log_field('attribute15', p_vendor_rec.attribute15);
   pos_log.log_field('auto_calculate_interest_flag', p_vendor_rec.auto_calculate_interest_flag);
   pos_log.log_field('validation_number', p_vendor_rec.validation_number);
   pos_log.log_field('exclude_freight_from_discount', p_vendor_rec.exclude_freight_from_discount);
   pos_log.log_field('tax_reporting_name', p_vendor_rec.tax_reporting_name);
   pos_log.log_field('check_digits', p_vendor_rec.check_digits);
   pos_log.log_field('allow_awt_flag', p_vendor_rec.allow_awt_flag);
   pos_log.log_field('awt_group_id', p_vendor_rec.awt_group_id);
    pos_log.log_field('pay_awt_group_id', p_vendor_rec.pay_awt_group_id);
   pos_log.log_field('awt_group_name', p_vendor_rec.awt_group_name);
   pos_log.log_field('pay_awt_group_name', p_vendor_rec.pay_awt_group_name);
   pos_log.log_field('global_attribute1', p_vendor_rec.global_attribute1);
   pos_log.log_field('global_attribute2', p_vendor_rec.global_attribute2);
   pos_log.log_field('global_attribute3', p_vendor_rec.global_attribute3);
   pos_log.log_field('global_attribute4', p_vendor_rec.global_attribute4);
   pos_log.log_field('global_attribute5', p_vendor_rec.global_attribute5);
   pos_log.log_field('global_attribute6', p_vendor_rec.global_attribute6);
   pos_log.log_field('global_attribute7', p_vendor_rec.global_attribute7);
   pos_log.log_field('global_attribute8', p_vendor_rec.global_attribute8);
   pos_log.log_field('global_attribute9', p_vendor_rec.global_attribute9);
   pos_log.log_field('global_attribute10', p_vendor_rec.global_attribute10);
   pos_log.log_field('global_attribute11', p_vendor_rec.global_attribute11);
   pos_log.log_field('global_attribute12', p_vendor_rec.global_attribute12);
   pos_log.log_field('global_attribute13', p_vendor_rec.global_attribute13);
   pos_log.log_field('global_attribute14', p_vendor_rec.global_attribute14);
   pos_log.log_field('global_attribute15', p_vendor_rec.global_attribute15);
   pos_log.log_field('global_attribute16', p_vendor_rec.global_attribute16);
   pos_log.log_field('global_attribute17', p_vendor_rec.global_attribute17);
   pos_log.log_field('global_attribute18', p_vendor_rec.global_attribute18);
   pos_log.log_field('global_attribute19', p_vendor_rec.global_attribute19);
   pos_log.log_field('global_attribute20', p_vendor_rec.global_attribute20);
   pos_log.log_field('global_attribute_category', p_vendor_rec.global_attribute_category);
   pos_log.log_field('bank_charge_bearer', p_vendor_rec.bank_charge_bearer);
   pos_log.log_field('match_option', p_vendor_rec.match_option);
   pos_log.log_field('create_debit_memo_flag', p_vendor_rec.create_debit_memo_flag);
   pos_log.log_field('party_id', p_vendor_rec.party_id);
   pos_log.log_field('parent_party_id', p_vendor_rec.parent_party_id);
   pos_log.log_field('jgzz_fiscal_code', p_vendor_rec.jgzz_fiscal_code);
   pos_log.log_field('sic_code', p_vendor_rec.sic_code);
   pos_log.log_field('tax_reference', p_vendor_rec.tax_reference);
   pos_log.log_field('inventory_organization_id', p_vendor_rec.inventory_organization_id);
   pos_log.log_field('terms_name', p_vendor_rec.terms_name);
   pos_log.log_field('default_terms_id', p_vendor_rec.default_terms_id);
   pos_log.log_field('vendor_interface_id', p_vendor_rec.vendor_interface_id);
   pos_log.log_field('ni_number', p_vendor_rec.ni_number);
   --pos_log.log_field('ext_payee_rec', p_vendor_rec.ext_payee_rec);

   pos_log.finish_log_field;

END log_vendor_rec;

PROCEDURE log_vendor_site_rec
  (p_vendor_site_rec IN ap_vendor_pub_pkg.r_vendor_site_rec_type, p_flow IN VARCHAR2)
  IS
BEGIN
   IF (fnd_log.level_procedure < fnd_log.g_current_runtime_level) THEN
      RETURN;
   END IF;

   pos_log.set_msg_prefix(p_flow || ': p_vendor_site_rec');
   pos_log.set_msg_module(g_module_name);

   pos_log.log_field('area_code', p_vendor_site_rec.area_code);
   pos_log.log_field('phone', p_vendor_site_rec.phone);
   pos_log.log_field('customer_num', p_vendor_site_rec.customer_num);
   pos_log.log_field('ship_to_location_id', p_vendor_site_rec.ship_to_location_id);
   pos_log.log_field('bill_to_location_id', p_vendor_site_rec.bill_to_location_id);
   pos_log.log_field('ship_via_lookup_code', p_vendor_site_rec.ship_via_lookup_code);
   pos_log.log_field('freight_terms_lookup_code', p_vendor_site_rec.freight_terms_lookup_code);
   pos_log.log_field('fob_lookup_code', p_vendor_site_rec.fob_lookup_code);
   pos_log.log_field('inactive_date', p_vendor_site_rec.inactive_date);
   pos_log.log_field('fax', p_vendor_site_rec.fax);
   pos_log.log_field('fax_area_code', p_vendor_site_rec.fax_area_code);
   pos_log.log_field('telex', p_vendor_site_rec.telex);
   pos_log.log_field('terms_date_basis', p_vendor_site_rec.terms_date_basis);
   pos_log.log_field('distribution_set_id', p_vendor_site_rec.distribution_set_id);
   pos_log.log_field('accts_pay_code_combination_id', p_vendor_site_rec.accts_pay_code_combination_id);
   pos_log.log_field('prepay_code_combination_id', p_vendor_site_rec.prepay_code_combination_id);
   pos_log.log_field('pay_group_lookup_code', p_vendor_site_rec.pay_group_lookup_code);
   pos_log.log_field('payment_priority', p_vendor_site_rec.payment_priority);
   pos_log.log_field('terms_id', p_vendor_site_rec.terms_id);
   pos_log.log_field('invoice_amount_limit', p_vendor_site_rec.invoice_amount_limit);
   pos_log.log_field('pay_date_basis_lookup_code', p_vendor_site_rec.pay_date_basis_lookup_code);
   pos_log.log_field('always_take_disc_flag', p_vendor_site_rec.always_take_disc_flag);
   pos_log.log_field('invoice_currency_code', p_vendor_site_rec.invoice_currency_code);
   pos_log.log_field('payment_currency_code', p_vendor_site_rec.payment_currency_code);
   pos_log.log_field('vendor_site_id', p_vendor_site_rec.vendor_site_id);
   pos_log.log_field('last_update_date', p_vendor_site_rec.last_update_date);
   pos_log.log_field('last_updated_by', p_vendor_site_rec.last_updated_by);
   pos_log.log_field('vendor_id', p_vendor_site_rec.vendor_id);
   pos_log.log_field('vendor_site_code', p_vendor_site_rec.vendor_site_code);
   pos_log.log_field('vendor_site_code_alt', p_vendor_site_rec.vendor_site_code_alt);
   pos_log.log_field('purchasing_site_flag', p_vendor_site_rec.purchasing_site_flag);
   pos_log.log_field('rfq_only_site_flag', p_vendor_site_rec.rfq_only_site_flag);
   pos_log.log_field('pay_site_flag', p_vendor_site_rec.pay_site_flag);
   pos_log.log_field('attention_ar_flag', p_vendor_site_rec.attention_ar_flag);
   pos_log.log_field('hold_all_payments_flag', p_vendor_site_rec.hold_all_payments_flag);
   pos_log.log_field('hold_future_payments_flag', p_vendor_site_rec.hold_future_payments_flag);
   pos_log.log_field('hold_reason', p_vendor_site_rec.hold_reason);
   pos_log.log_field('hold_unmatched_invoices_flag', p_vendor_site_rec.hold_unmatched_invoices_flag);
   pos_log.log_field('tax_reporting_site_flag', p_vendor_site_rec.tax_reporting_site_flag);
   pos_log.log_field('attribute_category', p_vendor_site_rec.attribute_category);
   pos_log.log_field('attribute1', p_vendor_site_rec.attribute1);
   pos_log.log_field('attribute2', p_vendor_site_rec.attribute2);
   pos_log.log_field('attribute3', p_vendor_site_rec.attribute3);
   pos_log.log_field('attribute4', p_vendor_site_rec.attribute4);
   pos_log.log_field('attribute5', p_vendor_site_rec.attribute5);
   pos_log.log_field('attribute6', p_vendor_site_rec.attribute6);
   pos_log.log_field('attribute7', p_vendor_site_rec.attribute7);
   pos_log.log_field('attribute8', p_vendor_site_rec.attribute8);
   pos_log.log_field('attribute9', p_vendor_site_rec.attribute9);
   pos_log.log_field('attribute10', p_vendor_site_rec.attribute10);
   pos_log.log_field('attribute11', p_vendor_site_rec.attribute11);
   pos_log.log_field('attribute12', p_vendor_site_rec.attribute12);
   pos_log.log_field('attribute13', p_vendor_site_rec.attribute13);
   pos_log.log_field('attribute14', p_vendor_site_rec.attribute14);
   pos_log.log_field('attribute15', p_vendor_site_rec.attribute15);
   pos_log.log_field('validation_number', p_vendor_site_rec.validation_number);
   pos_log.log_field('exclude_freight_from_discount', p_vendor_site_rec.exclude_freight_from_discount);
   pos_log.log_field('bank_charge_bearer', p_vendor_site_rec.bank_charge_bearer);
   pos_log.log_field('org_id', p_vendor_site_rec.org_id);
   pos_log.log_field('check_digits', p_vendor_site_rec.check_digits);
   pos_log.log_field('allow_awt_flag', p_vendor_site_rec.allow_awt_flag);
   pos_log.log_field('awt_group_id', p_vendor_site_rec.awt_group_id);
   pos_log.log_field('pay_awt_group_id', p_vendor_site_rec.pay_awt_group_id);
   pos_log.log_field('default_pay_site_id', p_vendor_site_rec.default_pay_site_id);
   pos_log.log_field('pay_on_code', p_vendor_site_rec.pay_on_code);
   pos_log.log_field('pay_on_receipt_summary_code', p_vendor_site_rec.pay_on_receipt_summary_code);
   pos_log.log_field('global_attribute_category', p_vendor_site_rec.global_attribute_category);
   pos_log.log_field('global_attribute1', p_vendor_site_rec.global_attribute1);
   pos_log.log_field('global_attribute2', p_vendor_site_rec.global_attribute2);
   pos_log.log_field('global_attribute3', p_vendor_site_rec.global_attribute3);
   pos_log.log_field('global_attribute4', p_vendor_site_rec.global_attribute4);
   pos_log.log_field('global_attribute5', p_vendor_site_rec.global_attribute5);
   pos_log.log_field('global_attribute6', p_vendor_site_rec.global_attribute6);
   pos_log.log_field('global_attribute7', p_vendor_site_rec.global_attribute7);
   pos_log.log_field('global_attribute8', p_vendor_site_rec.global_attribute8);
   pos_log.log_field('global_attribute9', p_vendor_site_rec.global_attribute9);
   pos_log.log_field('global_attribute10', p_vendor_site_rec.global_attribute10);
   pos_log.log_field('global_attribute11', p_vendor_site_rec.global_attribute11);
   pos_log.log_field('global_attribute12', p_vendor_site_rec.global_attribute12);
   pos_log.log_field('global_attribute13', p_vendor_site_rec.global_attribute13);
   pos_log.log_field('global_attribute14', p_vendor_site_rec.global_attribute14);
   pos_log.log_field('global_attribute15', p_vendor_site_rec.global_attribute15);
   pos_log.log_field('global_attribute16', p_vendor_site_rec.global_attribute16);
   pos_log.log_field('global_attribute17', p_vendor_site_rec.global_attribute17);
   pos_log.log_field('global_attribute18', p_vendor_site_rec.global_attribute18);
   pos_log.log_field('global_attribute19', p_vendor_site_rec.global_attribute19);
   pos_log.log_field('global_attribute20', p_vendor_site_rec.global_attribute20);
   pos_log.log_field('tp_header_id', p_vendor_site_rec.tp_header_id);
   pos_log.log_field('edi_id_number', p_vendor_site_rec.edi_id_number);
   pos_log.log_field('ece_tp_location_code', p_vendor_site_rec.ece_tp_location_code);
   pos_log.log_field('pcard_site_flag', p_vendor_site_rec.pcard_site_flag);
   pos_log.log_field('match_option', p_vendor_site_rec.match_option);
   pos_log.log_field('country_of_origin_code', p_vendor_site_rec.country_of_origin_code);
   pos_log.log_field('future_dated_payment_ccid', p_vendor_site_rec.future_dated_payment_ccid);
   pos_log.log_field('create_debit_memo_flag', p_vendor_site_rec.create_debit_memo_flag);
   pos_log.log_field('supplier_notif_method', p_vendor_site_rec.supplier_notif_method);
   pos_log.log_field('email_address', p_vendor_site_rec.email_address);
   pos_log.log_field('primary_pay_site_flag', p_vendor_site_rec.primary_pay_site_flag);
   pos_log.log_field('shipping_control', p_vendor_site_rec.shipping_control);
   pos_log.log_field('selling_company_identifier', p_vendor_site_rec.selling_company_identifier);
   pos_log.log_field('gapless_inv_num_flag', p_vendor_site_rec.gapless_inv_num_flag);
   pos_log.log_field('location_id', p_vendor_site_rec.location_id);
   pos_log.log_field('party_site_id', p_vendor_site_rec.party_site_id);
   pos_log.log_field('org_name', p_vendor_site_rec.org_name);
   pos_log.log_field('duns_number', p_vendor_site_rec.duns_number);
   pos_log.log_field('address_style', p_vendor_site_rec.address_style);
   pos_log.log_field('language', p_vendor_site_rec.language);
   pos_log.log_field('province', p_vendor_site_rec.province);
   pos_log.log_field('country', p_vendor_site_rec.country);
   pos_log.log_field('address_line1', p_vendor_site_rec.address_line1);
   pos_log.log_field('address_line2', p_vendor_site_rec.address_line2);
   pos_log.log_field('address_line3', p_vendor_site_rec.address_line3);
   pos_log.log_field('address_line4', p_vendor_site_rec.address_line4);
   pos_log.log_field('address_lines_alt', p_vendor_site_rec.address_lines_alt);
   pos_log.log_field('county', p_vendor_site_rec.county);
   pos_log.log_field('city', p_vendor_site_rec.city);
   pos_log.log_field('state', p_vendor_site_rec.state);
   pos_log.log_field('zip', p_vendor_site_rec.zip);
   pos_log.log_field('terms_name', p_vendor_site_rec.terms_name);
   pos_log.log_field('default_terms_id', p_vendor_site_rec.default_terms_id);
   pos_log.log_field('awt_group_name', p_vendor_site_rec.awt_group_name);
   pos_log.log_field('pay_awt_group_name', p_vendor_site_rec.awt_group_name);
   pos_log.log_field('distribution_set_name', p_vendor_site_rec.distribution_set_name);
   pos_log.log_field('ship_to_location_code', p_vendor_site_rec.ship_to_location_code);
   pos_log.log_field('bill_to_location_code', p_vendor_site_rec.bill_to_location_code);
   pos_log.log_field('default_dist_set_id', p_vendor_site_rec.default_dist_set_id);
   pos_log.log_field('default_ship_to_loc_id', p_vendor_site_rec.default_ship_to_loc_id);
   pos_log.log_field('default_bill_to_loc_id', p_vendor_site_rec.default_bill_to_loc_id);
   pos_log.log_field('tolerance_id', p_vendor_site_rec.tolerance_id);
   pos_log.log_field('tolerance_name', p_vendor_site_rec.tolerance_name);
   pos_log.log_field('vendor_interface_id', p_vendor_site_rec.vendor_interface_id);
   pos_log.log_field('vendor_site_interface_id', p_vendor_site_rec.vendor_site_interface_id);
   --pos_log.log_field('ext_payee_rec', p_vendor_site_rec.ext_payee_rec);
   pos_log.log_field('retainage_rate', p_vendor_site_rec.retainage_rate);
   pos_log.log_field('services_tolerance_id', p_vendor_site_rec.services_tolerance_id);
   pos_log.log_field('services_tolerance_name', p_vendor_site_rec.services_tolerance_name);

   pos_log.finish_log_field;

END log_vendor_site_rec;

procedure hack_org_id
  (px_vendor_rec IN OUT nocopy AP_VENDOR_PUB_PKG.r_vendor_rec_type)
  IS
     CURSOR l_cur IS
	SELECT organization_id
	  FROM hr_operating_units m
	     , financials_system_params_all fspa
	     , ap_system_parameters_all aspa
	     , po_system_parameters_all pspa
         WHERE m.organization_id = fspa.org_id
           AND m.organization_id = aspa.org_id
	   AND m.organization_id = pspa.org_id
	   AND mo_global.check_access(m.organization_id) = 'Y' ;

     l_org_id NUMBER;
BEGIN
   --IF px_vendor_rec.org_id IS NOT NULL THEN
   --   RETURN;
   --END IF;

   --OPEN l_cur;
   --FETCH l_cur INTO l_org_id;
   --IF l_cur%found THEN
   --   px_vendor_rec.org_id := l_org_id;
   --END IF;
   --CLOSE l_cur;
   NULL;
END hack_org_id;

function check_for_dupe_vendor(p_vendor_name in varchar2)
return number
is
l_count number;
begin
    select count(*)
    into l_count
    from ap_suppliers
    where upper(vendor_name) like upper(p_vendor_name)
    AND nvl(VENDOR_TYPE_LOOKUP_CODE,'nonemp') <> 'EMPLOYEE';

    return l_count;

end;

function get_nls_language(p_language_code in varchar2)
return varchar2
is
l_nls_language fnd_languages.nls_language%TYPE;

cursor l_nls_lang_cur is
    select nls_language
    from fnd_languages_vl
    where language_code = p_language_code;

begin
    l_nls_language := null;

    open l_nls_lang_cur;
    fetch l_nls_lang_cur into l_nls_language;
    close  l_nls_lang_cur;

    return l_nls_language;
end;


PROCEDURE check_for_site_errors
(
  p_vendor_site_rec IN ap_vendor_pub_pkg.r_vendor_site_rec_type,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_count      OUT NOCOPY NUMBER,
  x_msg_data       OUT NOCOPY VARCHAR2
)
IS

l_primary_pay_flag AP_SUPPLIER_SITES.primary_pay_site_flag%TYPE;
l_org_id AP_SUPPLIER_SITES.ORG_ID%TYPE;
l_count number;
l_vendor_site_code AP_SUPPLIER_SITES.VENDOR_SITE_CODE%TYPE;
l_vendor_site_id number;
BEGIN

    l_primary_pay_flag := p_vendor_site_rec.primary_pay_site_flag;

    if (l_primary_pay_flag is null or l_primary_pay_flag <> 'Y' ) then
       x_return_status := FND_API.g_ret_sts_success;
       x_msg_count :=0;
       x_msg_data := null;
       return;
    end if;

    l_org_id := p_vendor_site_rec.org_id;
    l_vendor_site_id := p_vendor_site_rec.vendor_site_id;

    if (l_vendor_site_id is null) then
        -- if the vendor site is being created vendor site will be null
        l_vendor_site_id := -23123;
    end if;


    select  count(*)
    into l_count
    from ap_supplier_sites_all
    where org_id = l_org_id
    and primary_pay_site_flag = l_primary_pay_flag
    and vendor_id = p_vendor_site_rec.vendor_id
    and vendor_site_id <> l_vendor_site_id
    and ( inactive_date is null or inactive_date > sysdate );

    if (l_count = 0) then
       x_return_status := FND_API.g_ret_sts_success;
       x_msg_count :=0;
       x_msg_data := null;
       return;
    end if;

    select  vendor_site_code
    into l_vendor_site_code
    from ap_supplier_sites_all
    where org_id = l_org_id
    and primary_pay_site_flag = l_primary_pay_flag
    and vendor_id = p_vendor_site_rec.vendor_id
    and vendor_site_id <> l_vendor_site_id
    and ( inactive_date is null or inactive_date > sysdate )
    and rownum = 1;

    if ( l_vendor_site_code is not null ) then
        x_msg_count := 1;
        fnd_message.set_name('POS','POS_HT_SP_DUP_PRIMARY_PAY');
        --fnd_message.set_token('VENDOR_SITE_CODE', p_vendor_site_rec.vendor_site_code);
        x_msg_data  := fnd_message.get();
        x_return_status := 'E';
    else
       x_return_status := FND_API.g_ret_sts_success;
       x_msg_count :=0;
       x_msg_data := null;
    end if;

END;

PROCEDURE Create_Vendor
( p_vendor_rec     IN  AP_VENDOR_PUB_PKG.r_vendor_rec_type,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_count      OUT NOCOPY NUMBER,
  x_msg_data       OUT NOCOPY VARCHAR2,
  x_vendor_id      OUT NOCOPY NUMBER,
  x_party_id       OUT NOCOPY NUMBER
) IS
   l_step VARCHAR2(100);
   l_vendor_rec AP_VENDOR_PUB_PKG.r_vendor_rec_type;
   --l_temp_party_id number;
   l_party_usage_rec HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type;

   /* Bug No: 8973060.
      Added following varirables to build the message with bind variables.*/
   l_segment1    AP_SUPPLIERS.SEGMENT1%TYPE;
   l_vendor_id   AP_SUPPLIERS.VENDOR_ID%TYPE;
   l_vendor_name AP_SUPPLIERS.VENDOR_NAME%TYPE;
   l_party_id    HZ_PARTIES.PARTY_ID%TYPE;
    event_id Number;
BEGIN

   savepoint crt_vndr_a;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                      , g_module_name
                      , 'Enter Create Vendor Procedure'
                      );
   END IF;

   l_step := 'Log vendor rec values';

   log_vendor_rec (p_vendor_rec, 'create vendor');

   l_step := 'Check for duplicate vendors';

  /*  Added for bug6779711
      If the vendor is of EMPLOYEE type then do not
      perform duplicate check for supplier name
  */

  if (p_vendor_rec.vendor_type_lookup_code = 'EMPLOYEE') then
    null;
  else
   if ( check_for_dupe_vendor(p_vendor_rec.vendor_name) > 0 ) then
    x_msg_count := 1;

   /* Bug 8973060 - Start
   Added following code to build messages with bind variables.*/

   select segment1, vendor_name, party_id, vendor_id
   INTO l_segment1, l_vendor_name, l_party_id, l_vendor_id
   from ap_suppliers
   where upper(vendor_name) like upper(p_vendor_rec.vendor_name);

   fnd_message.set_name('POS','POS_HT_SP_DUP_VENDOR');
   fnd_message.set_token('VENDOR_NAME',l_vendor_name);
   fnd_message.set_token('VENDOR_NUMBER',l_segment1);
   x_msg_data  := fnd_message.get;
   x_vendor_id := l_vendor_id;
   x_party_id  := l_party_id;

   /*Bug 8973060 - End*/

    x_return_status := 'E';
    return;
   end if;
  end if;

   -- create the party usage
    --l_temp_party_id := p_vendor_rec.party_id;
    if (p_vendor_rec.party_id > 0 ) then
        l_step := 'Create party usage for organization';
        l_party_usage_rec.party_id := p_vendor_rec.party_id;
        l_party_usage_rec.party_usage_code := 'SUPPLIER';
        l_party_usage_rec.created_by_module := 'POS_SUPPLIER_MGMT';
        HZ_PARTY_USG_ASSIGNMENT_PUB.assign_party_usage (
            p_init_msg_list => FND_API.G_TRUE,
            p_party_usg_assignment_rec => l_party_usage_rec,
            x_return_status            => x_return_status,
            x_msg_count                => x_msg_count,
            x_msg_data                 => x_msg_data
        );
        IF  (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_ERROR
                         , g_module_name
                         , l_step
                         || ' x_return_status = ' || x_return_status
                         || ', x_msg_count = ' || x_msg_count
                         || ', x_msg_data = ' || x_msg_data);

      END IF;

        if (x_return_status <> 'S') then
            return;
        end if;
    end if;

   -- hack: we should not need to set org_id as this is vendor not site
   --       but there is a bug in ap api right now.
   --       so set it here temporarily
   l_vendor_rec := p_vendor_rec;
   hack_org_id(l_vendor_rec);

   l_step := 'Call AP_VENDOR_PUB_PKG.Create_Vendor';

   AP_VENDOR_PUB_PKG.Create_Vendor
     (  p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_TRUE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_vendor_rec            => l_vendor_rec,
        x_vendor_id             => x_vendor_id,
        x_party_id              => x_party_id
        );

   IF x_return_status IS NOT NULL AND
     x_return_status = FND_API.g_ret_sts_success THEN
      -- succeed

      /* Begin Supplier Hub - Supplier Data Publication */
      /* Raise Supplier Creation/Approval event*/
        event_id:= pos_appr_rej_supp_event_raise.raise_appr_rej_supp_event('oracle.apps.pos.supplier.approvesupplier', x_vendor_id, x_party_id);

      /* End Supplier Hub - Supplier Data Publication */

      IF  (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                         , g_module_name
                         , l_step
                         || ' x_return_status = ' || x_return_status
                         || ', x_vendor_id = '  || x_vendor_id
                         || ', x_party_id = '   || x_party_id);
      END IF;
    ELSE
      -- failed
      rollback to crt_vndr_a;
      IF  (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_ERROR
                         , g_module_name
                         , l_step
                         || ' x_return_status = ' || x_return_status
                         || ', x_msg_count = ' || x_msg_count
                         || ', x_msg_data = ' || x_msg_data);

      END IF;
   END IF;

END Create_Vendor;

-- Notes: This API will not update any TCA tables. It updates vendor info only.
--        This is because the procedure calls the corresponding procedure in
--        AP_VENDOR_PUB_PKG which does not update TCA tables.
PROCEDURE Update_Vendor
( p_vendor_rec      IN  AP_VENDOR_PUB_PKG.r_vendor_rec_type,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2
) IS
   l_step VARCHAR2(100);
BEGIN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                      , g_module_name
                      , 'Enter Update Vendor Procedure'
                      );
   END IF;

   l_step := 'Log vendor rec values';

   log_vendor_rec (p_vendor_rec, 'update vendor');

   l_step := 'Call AP_VENDOR_PUB_PKG.Update_Vendor';

   savepoint upd_vndr_a;
   AP_VENDOR_PUB_PKG.Update_Vendor
     (  p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_TRUE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_vendor_rec            => p_vendor_rec,
        p_vendor_id             => p_vendor_rec.vendor_id
        );

   IF x_return_status IS NOT NULL AND
     x_return_status = FND_API.g_ret_sts_success THEN
      -- succeed
      IF  (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                         , g_module_name
                         , l_step
                         || ' x_return_status = ' || x_return_status
                         );
      END IF;
    ELSE
      -- failed
      rollback to upd_vndr_a;
      IF  (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_ERROR
                         , g_module_name
                         , l_step
                         || ' x_return_status = ' || x_return_status
                         || ', x_msg_count = ' || x_msg_count
                         || ', x_msg_data = ' || x_msg_data);

      END IF;
   END IF;

END Update_Vendor;

-- Notes:
--   p_mode: Indicates whether the calling code is in insert or update mode.
--           (I, U)
--
--   p_party_valid:  Indicates how valid the calling program's party_id was
--                   (V, N, F) Valid, Null or False

PROCEDURE Validate_Vendor
( p_vendor_rec     IN  OUT NOCOPY AP_VENDOR_PUB_PKG.r_vendor_rec_type,
  p_mode           IN  VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_count      OUT NOCOPY NUMBER,
  x_msg_data       OUT NOCOPY VARCHAR2,
  x_party_valid    OUT NOCOPY VARCHAR2
) IS
   l_step        VARCHAR2(100);
   l_payee_valid VARCHAR2(1);
BEGIN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                      , g_module_name
                      , 'Enter Validate Vendor Procedure'
                      );
   END IF;

   l_step := 'Log vendor rec values';

   log_vendor_rec (p_vendor_rec, 'validate vendor');

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_STATEMENT
                      , g_module_name
                      , 'p_mode = ' || p_mode
                      );
   END IF;

   l_step := 'Validate p_mode';

   IF p_mode IS NULL OR p_mode NOT IN ('I','U') THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_msg_data := 'Invalid p_mode ' || p_mode || ' passed. Expects I or U.';
      RETURN;
   END IF;

   l_step := 'Call AP_VENDOR_PUB_PKG.Validate_Vendor';

   AP_VENDOR_PUB_PKG.Validate_Vendor
     (  p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_TRUE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_vendor_rec            => p_vendor_rec,
        p_mode                  => p_mode,
        p_calling_prog          => g_module_name || '.' || 'Validate_Vendor',
        x_party_valid           => x_party_valid,
	x_payee_valid           => l_payee_valid,
        p_vendor_id             => p_vendor_rec.vendor_id
        );

   IF x_return_status IS NOT NULL AND
     x_return_status = FND_API.g_ret_sts_success THEN
      -- succeed
      IF  (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                         , g_module_name
                         , l_step
                         || ' x_return_status = ' || x_return_status
                         || ', x_party_valid = '   || x_party_valid);
      END IF;
    ELSE
      -- failed
      IF  (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_ERROR
                         , g_module_name
                         , l_step
                         || ' x_return_status = ' || x_return_status
                         || ', x_msg_count = ' || x_msg_count
                         || ', x_msg_data = ' || x_msg_data);

      END IF;
   END IF;

END Validate_Vendor;

PROCEDURE vendor_site_create_default
  (x_vendor_site_rec IN OUT nocopy ap_vendor_pub_pkg.r_vendor_site_rec_type
   )
  IS
     CURSOR l_phone_cur (p_party_site_id IN NUMBER) IS
	SELECT phone_area_code,
	       phone_number
	  FROM hz_contact_points
	 WHERE owner_table_name = 'HZ_PARTY_SITES'
           AND owner_table_id = p_party_site_id
           AND contact_point_type = 'PHONE'
           AND phone_line_type = 'GEN'
           AND primary_flag = 'Y'
           AND status = 'A' ;

     CURSOR l_fax_cur (p_party_site_id IN NUMBER) IS
	SELECT phone_area_code fax_area_code,
	       phone_number fax_number
	  FROM hz_contact_points
	 WHERE owner_table_name = 'HZ_PARTY_SITES'
           AND owner_table_id = p_party_site_id
           AND contact_point_type = 'PHONE'
           AND phone_line_type = 'FAX'
	   AND status = 'A' ;

     CURSOR l_email_cur (p_party_site_id IN NUMBER) IS
	SELECT email_address
	  FROM hz_contact_points
	 WHERE owner_table_name = 'HZ_PARTY_SITES'
           AND owner_table_id = p_party_site_id
           AND contact_point_type = 'EMAIL'
           AND primary_flag = 'Y'
           AND status = 'A' ;

  l_phone_rec l_phone_cur%ROWTYPE;
  l_fax_rec   l_fax_cur%ROWTYPE;
  l_email_rec l_email_cur%ROWTYPE;

BEGIN
   IF x_vendor_site_rec.party_site_id IS NULL THEN
      RETURN;
   END IF;

   OPEN l_phone_cur(x_vendor_site_rec.party_site_id);
   fetch l_phone_cur INTO l_phone_rec;
   CLOSE l_phone_cur;

   OPEN l_fax_cur(x_vendor_site_rec.party_site_id);
   fetch l_fax_cur INTO l_fax_rec;
   CLOSE l_fax_cur;

   OPEN l_email_cur(x_vendor_site_rec.party_site_id);
   fetch l_email_cur INTO l_email_rec;
   CLOSE l_email_cur;

   IF (x_vendor_site_rec.phone IS NULL OR x_vendor_site_rec.phone = fnd_api.g_null_char) AND
      (x_vendor_site_rec.area_code IS NULL OR x_vendor_site_rec.area_code = fnd_api.g_null_char) THEN
      x_vendor_site_rec.phone := l_phone_rec.phone_number;
      x_vendor_site_rec.area_code := l_phone_rec.phone_area_code;
   END IF;

   IF (x_vendor_site_rec.fax IS NULL OR x_vendor_site_rec.fax = fnd_api.g_null_char) AND
      (x_vendor_site_rec.fax_area_code IS NULL OR x_vendor_site_rec.fax_area_code = fnd_api.g_null_char) THEN
      x_vendor_site_rec.fax := l_fax_rec.fax_number;
      x_vendor_site_rec.fax_area_code := l_fax_rec.fax_area_code;
   END IF;

   IF (x_vendor_site_rec.email_address IS NULL OR x_vendor_site_rec.email_address = fnd_api.g_null_char) THEN
      x_vendor_site_rec.email_address := l_email_rec.email_address;
   END IF;

END vendor_site_create_default;

PROCEDURE Create_Vendor_Site
( p_vendor_site_rec IN  ap_vendor_pub_pkg.r_vendor_site_rec_type,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2,
  x_vendor_site_id  OUT NOCOPY NUMBER,
  x_party_site_id   OUT NOCOPY NUMBER,
  x_location_id     OUT NOCOPY NUMBER
) IS
   l_step VARCHAR2(100);
   l_vendor_site_rec ap_vendor_pub_pkg.r_vendor_site_rec_type;
BEGIN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                      , g_module_name
                      , 'Enter Create_Vendor_Site Procedure'
                      );
   END IF;

   l_step := 'Log vendor site rec values';

   l_vendor_site_rec := p_vendor_site_rec;

   log_vendor_site_rec (l_vendor_site_rec,'create vendor site');

   l_step := 'Call Check_for_site_errors';


   -- Check for errors
   check_for_site_errors(l_vendor_site_rec, x_return_status,
        x_msg_count, x_msg_data );

   IF ( (x_return_status IS NULL) OR (x_return_status <> FND_API.g_ret_sts_success) ) THEN
    -- Found an error in validation
      IF  (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_ERROR
                         , g_module_name
                         , l_step
                         || ' x_return_status = ' || x_return_status
                         || ', x_msg_count = ' || x_msg_count
                         || ', x_msg_data = ' || x_msg_data);
      END IF;

      return;
   END IF;

   savepoint crt_vndr_st_a;
   l_step := 'Call AP_VENDOR_PUB_PKG.Create_Vendor_Site';
   AP_VENDOR_PUB_PKG.Create_Vendor_Site
     (  p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_TRUE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_vendor_site_rec       => l_vendor_site_rec,
        x_vendor_site_id        => x_vendor_site_id,
        x_party_site_id         => x_party_site_id,
        x_location_id           => x_location_id
        );

   IF x_return_status IS NOT NULL AND
     x_return_status = FND_API.g_ret_sts_success THEN
      -- succeed
      IF  (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                         , g_module_name
                         , l_step
                         || ' x_return_status = ' || x_return_status
                         || ', x_vendor_site_id = '  || x_vendor_site_id
                         || ', x_party_site_id = '  || x_party_site_id
                         || ', x_location_id = '  || x_location_id);
      END IF;
    ELSE
      -- failed
      rollback to crt_vndr_st_a;
      IF  (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_ERROR
                         , g_module_name
                         , l_step
                         || ' x_return_status = ' || x_return_status
                         || ', x_msg_count = ' || x_msg_count
                         || ', x_msg_data = ' || x_msg_data);
      END IF;
   END IF;

END Create_Vendor_Site;

--  Notes: This API will not update any TCA records.
--         It will only update vendor site info.
--         This is because the procedure calls the corresponding procedure in
--         AP_VENDOR_PUB_PKG which does not update TCA tables.
--
PROCEDURE Update_Vendor_Site
( p_vendor_site_rec IN  AP_VENDOR_PUB_PKG.r_vendor_site_rec_type,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2
  ) IS
     l_step VARCHAR2(100);
BEGIN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                      , g_module_name
                      , 'Enter Update_Vendor_Site Procedure'
                      );
   END IF;

   l_step := 'Log vendor site rec values';

   log_vendor_site_rec (p_vendor_site_rec, 'update vendor site');



   l_step := 'Call check_for_site_errors';
   -- Check for errors
   check_for_site_errors(p_vendor_site_rec, x_return_status,
        x_msg_count, x_msg_data );

   IF ( (x_return_status IS NULL) OR (x_return_status <> FND_API.g_ret_sts_success) ) THEN
    -- Found an error in validation
      IF  (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_ERROR
                         , g_module_name
                         , l_step
                         || ' x_return_status = ' || x_return_status
                         || ', x_msg_count = ' || x_msg_count
                         || ', x_msg_data = ' || x_msg_data);
      END IF;
      return;
   END IF;

   savepoint upd_vndr_st_a;
   l_step := 'Call AP_VENDOR_PUB_PKG.Update_Vendor_Site';
   AP_VENDOR_PUB_PKG.Update_Vendor_Site
     (  p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_TRUE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_vendor_site_rec       => p_vendor_site_rec,
        p_vendor_site_id        => p_vendor_site_rec.vendor_site_id
        );

   IF x_return_status IS NOT NULL AND
     x_return_status = FND_API.g_ret_sts_success THEN
      -- succeed
      IF  (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                         , g_module_name
                         , l_step
                         || ' x_return_status = ' || x_return_status
                         );
      END IF;
    ELSE
      -- failed
      rollback to upd_vndr_st_a;
      IF  (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_ERROR
                         , g_module_name
                         , l_step
                         || ' x_return_status = ' || x_return_status
                         || ', x_msg_count = ' || x_msg_count
                         || ', x_msg_data = ' || x_msg_data);
      END IF;
   END IF;

END Update_Vendor_Site;


-- Notes:
--   p_mode: Indicates whether the calling code is in insert or update mode.
--           (I, U)
--
--   x_party_site_valid: Indicates how valid the calling program's party_site_id was
--                   (V, N, F) Valid, Null or False

PROCEDURE Validate_Vendor_Site
( p_vendor_site_rec   IN  OUT NOCOPY AP_VENDOR_PUB_PKG.r_vendor_site_rec_type,
  p_mode              IN  VARCHAR2,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2,
  x_party_site_valid  OUT NOCOPY VARCHAR2,
  x_location_valid    OUT NOCOPY VARCHAR2
) IS
   l_step        VARCHAR2(100);
   l_payee_valid VARCHAR2(1);
BEGIN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                      , g_module_name
                      , 'Enter Validate_Vendor_Site Procedure'
                      );
   END IF;

   l_step := 'Log vendor site rec values';

   log_vendor_site_rec (p_vendor_site_rec, 'validate vendor site');

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_STATEMENT
                      , g_module_name
                      , 'p_mode = ' || p_mode
                      );
   END IF;

   l_step := 'Validate p_mode';

   IF p_mode IS NULL OR p_mode NOT IN ('I','U') THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_msg_data := 'Invalid p_mode ' || p_mode || ' passed. Expects I or U.';
      RETURN;
   END IF;

   l_step := 'Call AP_VENDOR_PUB_PKG.Validate_Vendor_Site';

   AP_VENDOR_PUB_PKG.Validate_Vendor_Site
     (  p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_TRUE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_vendor_site_rec       => p_vendor_site_rec,
        p_mode                  => p_mode,
        p_calling_prog          => 'POS_VENDOR_PUB_PKG',
        x_party_site_valid      => x_party_site_valid,
        x_location_valid        => x_location_valid,
	x_payee_valid           => l_payee_valid,
        p_vendor_site_id        => p_vendor_site_rec.vendor_site_id
        );

   IF x_return_status IS NOT NULL AND
     x_return_status = FND_API.g_ret_sts_success THEN
      -- succeed
      IF  (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                         , g_module_name
                         , l_step
                         || ' x_return_status = ' || x_return_status
                         || ', x_party_site_valid = ' || x_party_site_valid
                         || ', x_location_valid = ' || x_location_valid
                         );
      END IF;
    ELSE
      -- failed
      IF  (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_ERROR
                         , g_module_name
                         , l_step
                         || ' x_return_status = ' || x_return_status
                         || ', x_msg_count = ' || x_msg_count
                         || ', x_msg_data = ' || x_msg_data);
      END IF;
   END IF;

END Validate_Vendor_Site;

PROCEDURE create_vendor_contact
( p_vendor_contact_rec  IN  ap_vendor_pub_pkg.r_vendor_contact_rec_type,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  x_vendor_contact_id   OUT NOCOPY NUMBER,
  x_per_party_id        OUT NOCOPY NUMBER,
  x_rel_party_id        OUT NOCOPY NUMBER,
  x_rel_id              OUT NOCOPY NUMBER,
  x_org_contact_id      OUT NOCOPY NUMBER,
  x_party_site_id       OUT NOCOPY NUMBER
)
  IS
     l_step VARCHAR2(100);
BEGIN
   l_step := 'call ap_vendor_pub_pkg.create_vendor_contact';
   ap_vendor_pub_pkg.create_vendor_contact
     (  p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_TRUE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
	p_vendor_contact_rec    => p_vendor_contact_rec,
	x_vendor_contact_id     => x_vendor_contact_id,
	x_per_party_id          => x_per_party_id,
	x_rel_party_id          => x_rel_party_id,
	x_rel_id                => x_rel_id,
	x_org_contact_id        => x_org_contact_id,
	x_party_site_id         => x_party_site_id
        );

   IF x_return_status IS NOT NULL AND
     x_return_status = FND_API.g_ret_sts_success THEN
      -- succeed
      IF  (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                         , g_module_name
                         , l_step
			|| ' x_return_status = ' || x_return_status
			|| ' x_vendor_contact_id = ' || x_vendor_contact_id
			|| ' x_per_party_id = ' || x_per_party_id
			|| ' x_rel_party_id = ' || x_rel_party_id
			|| ' x_rel_id = ' || x_rel_id
			|| ' x_org_contact_id = ' || x_org_contact_id
			|| ' x_party_site_id = ' || x_party_site_id
			);
      END IF;
    ELSE
      -- failed
      IF  (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_ERROR
                         , g_module_name
                         , l_step
			|| ' x_return_status = ' || x_return_status
			|| ', x_msg_count = ' || x_msg_count
			|| ', x_msg_data = ' || x_msg_data);
      END IF;
   END IF;

END create_vendor_contact;

PROCEDURE combine_err_msg
  (p_return_status IN  VARCHAR2,
   p_msg_count     IN  NUMBER,
   p_msg_data      IN  VARCHAR2,
   x_msg_data      OUT NOCOPY VARCHAR2
   )
  IS
BEGIN
   IF p_return_status = fnd_api.g_ret_sts_success THEN
      RETURN;
   END IF;

   IF p_msg_count = 1 THEN
      x_msg_data := fnd_msg_pub.get(1,'F');
      IF x_msg_data IS NULL THEN
	 x_msg_data := p_msg_data;
      END IF;
      RETURN;
   END IF;

   FOR l_idx IN 1..p_msg_count LOOP
      x_msg_data := x_msg_data || ' ' || fnd_msg_pub.get(l_idx,'F');
   END LOOP;

END combine_err_msg;


PROCEDURE Create_Vendor
(
  p_vendor_id                       IN  NUMBER   DEFAULT NULL,
  p_segment1                        IN  VARCHAR2 DEFAULT NULL,
  p_vendor_name                     IN  VARCHAR2 DEFAULT NULL,
  p_vendor_name_alt                 IN  VARCHAR2 DEFAULT NULL,
  p_summary_flag                    IN  VARCHAR2 DEFAULT NULL,
  p_enabled_flag                    IN  VARCHAR2 DEFAULT NULL,
  p_segment2                        IN  VARCHAR2 DEFAULT NULL,
  p_segment3                        IN  VARCHAR2 DEFAULT NULL,
  p_segment4                        IN  VARCHAR2 DEFAULT NULL,
  p_segment5                        IN  VARCHAR2 DEFAULT NULL,
  p_employee_id                     IN  NUMBER   DEFAULT NULL,
  p_vendor_type_lookup_code         IN  VARCHAR2 DEFAULT NULL,
  p_customer_num                    IN  VARCHAR2 DEFAULT NULL,
  p_one_time_flag                   IN  VARCHAR2 DEFAULT NULL,
  p_parent_vendor_id                IN  NUMBER   DEFAULT NULL,
  p_min_order_amount                IN  NUMBER   DEFAULT NULL,
  p_terms_id                        IN  NUMBER   DEFAULT NULL,
  p_set_of_books_id                 IN  NUMBER   DEFAULT NULL,
  p_always_take_disc_flag           IN  VARCHAR2 DEFAULT NULL,
  p_pay_date_basis_lookup_code      IN  VARCHAR2 DEFAULT NULL,
  p_pay_group_lookup_code           IN  VARCHAR2 DEFAULT NULL,
  p_payment_priority                IN  NUMBER   DEFAULT NULL,
  p_invoice_currency_code           IN  VARCHAR2 DEFAULT NULL,
  p_payment_currency_code           IN  VARCHAR2 DEFAULT NULL,
  p_invoice_amount_limit            IN  NUMBER   DEFAULT NULL,
  p_hold_all_payments_flag          IN  VARCHAR2 DEFAULT NULL,
  p_hold_future_payments_flag       IN  VARCHAR2 DEFAULT NULL,
  p_hold_reason                     IN  VARCHAR2 DEFAULT NULL,
  p_type_1099                       IN  VARCHAR2 DEFAULT NULL,
  p_withhold_status_lookup_code     IN  VARCHAR2 DEFAULT NULL,
  p_withholding_start_date          IN  DATE     DEFAULT NULL,
  p_org_type_lookup_code            IN  VARCHAR2 DEFAULT NULL,
  p_start_date_active               IN  DATE     DEFAULT NULL,
  p_end_date_active                 IN  DATE     DEFAULT NULL,
  p_minority_group_lookup_code      IN  VARCHAR2 DEFAULT NULL,
  p_women_owned_flag                IN  VARCHAR2 DEFAULT NULL,
  p_small_business_flag             IN  VARCHAR2 DEFAULT NULL,
  p_hold_flag                       IN  VARCHAR2 DEFAULT NULL,
  p_purchasing_hold_reason          IN  VARCHAR2 DEFAULT NULL,
  p_hold_by                         IN  NUMBER   DEFAULT NULL,
  p_hold_date                       IN  DATE     DEFAULT NULL,
  p_terms_date_basis                IN  VARCHAR2 DEFAULT NULL,
  p_inspection_required_flag        IN  VARCHAR2 DEFAULT NULL,
  p_receipt_required_flag           IN  VARCHAR2 DEFAULT NULL,
  p_qty_rcv_tolerance               IN  NUMBER   DEFAULT NULL,
  p_qty_rcv_exception_code          IN  VARCHAR2 DEFAULT NULL,
  p_enforce_ship_to_loc_code        IN  VARCHAR2 DEFAULT NULL,
  p_days_early_receipt_allowed      IN  NUMBER   DEFAULT NULL,
  p_days_late_receipt_allowed       IN  NUMBER   DEFAULT NULL,
  p_receipt_days_exception_code     IN  VARCHAR2 DEFAULT NULL,
  p_receiving_routing_id            IN  NUMBER   DEFAULT NULL,
  p_allow_substi_receipts_flag      IN  VARCHAR2 DEFAULT NULL,
  p_allow_unorder_receipts_flag     IN  VARCHAR2 DEFAULT NULL,
  p_hold_unmatched_invoices_flag    IN  VARCHAR2 DEFAULT NULL,
  p_tax_verification_date           IN  DATE     DEFAULT NULL,
  p_name_control                    IN  VARCHAR2 DEFAULT NULL,
  p_state_reportable_flag           IN  VARCHAR2 DEFAULT NULL,
  p_federal_reportable_flag         IN  VARCHAR2 DEFAULT NULL,
  p_attribute_category              IN  VARCHAR2 DEFAULT NULL,
  p_attribute1                      IN  VARCHAR2 DEFAULT NULL,
  p_attribute2                      IN  VARCHAR2 DEFAULT NULL,
  p_attribute3                      IN  VARCHAR2 DEFAULT NULL,
  p_attribute4                      IN  VARCHAR2 DEFAULT NULL,
  p_attribute5                      IN  VARCHAR2 DEFAULT NULL,
  p_attribute6                      IN  VARCHAR2 DEFAULT NULL,
  p_attribute7                      IN  VARCHAR2 DEFAULT NULL,
  p_attribute8                      IN  VARCHAR2 DEFAULT NULL,
  p_attribute9                      IN  VARCHAR2 DEFAULT NULL,
  p_attribute10                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute11                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute12                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute13                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute14                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute15                     IN  VARCHAR2 DEFAULT NULL,
  p_auto_calculate_interest_flag    IN  VARCHAR2 DEFAULT NULL,
  p_validation_number               IN  NUMBER   DEFAULT NULL,
  p_exclude_freight_from_discnt     IN  VARCHAR2 DEFAULT NULL,
  p_tax_reporting_name              IN  VARCHAR2 DEFAULT NULL,
  p_check_digits                    IN  VARCHAR2 DEFAULT NULL,
  p_allow_awt_flag                  IN  VARCHAR2 DEFAULT NULL,
  p_awt_group_id                    IN  NUMBER   DEFAULT NULL,
  p_pay_awt_group_id                    IN  NUMBER   DEFAULT NULL,
  p_awt_group_name                  IN  VARCHAR2 DEFAULT NULL,
  p_pay_awt_group_name                  IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute1               IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute2               IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute3               IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute4               IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute5               IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute6               IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute7               IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute8               IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute9               IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute10              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute11              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute12              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute13              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute14              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute15              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute16              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute17              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute18              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute19              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute20              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute_category       IN  VARCHAR2 DEFAULT NULL,
  p_bank_charge_bearer              IN  VARCHAR2 DEFAULT NULL,
  p_bank_branch_type                IN  VARCHAR2 DEFAULT NULL,
  p_match_option                    IN  VARCHAR2 DEFAULT NULL,
  p_create_debit_memo_flag          IN  VARCHAR2 DEFAULT NULL,
  p_party_id                        IN  NUMBER   DEFAULT NULL,
  p_parent_party_id                 IN  NUMBER   DEFAULT NULL,
  p_jgzz_fiscal_code                IN  VARCHAR2 DEFAULT NULL,
  p_sic_code                        IN  VARCHAR2 DEFAULT NULL,
  p_tax_reference                   IN  VARCHAR2 DEFAULT NULL,
  p_inventory_organization_id       IN  NUMBER   DEFAULT NULL,
  p_terms_name                      IN  VARCHAR2 DEFAULT NULL,
  p_default_terms_id                IN  NUMBER   DEFAULT NULL,
  p_ni_number                       IN  VARCHAR2 DEFAULT NULL,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_error_msg      OUT NOCOPY VARCHAR2,
  x_vendor_id      OUT NOCOPY NUMBER,
  x_party_id       OUT NOCOPY NUMBER
) IS
   l_vendor_rec ap_vendor_pub_pkg.r_vendor_rec_type;
   l_msg_count  NUMBER;
   l_msg_data   VARCHAR2(4000);
BEGIN

   l_vendor_rec.vendor_id                      := p_vendor_id;
   l_vendor_rec.segment1                       := p_segment1;
   l_vendor_rec.vendor_name                    := p_vendor_name;
   l_vendor_rec.vendor_name_alt                := p_vendor_name_alt;
   l_vendor_rec.summary_flag                   := p_summary_flag;
   l_vendor_rec.enabled_flag                   := p_enabled_flag;
   l_vendor_rec.segment2                       := p_segment2;
   l_vendor_rec.segment3                       := p_segment3;
   l_vendor_rec.segment4                       := p_segment4;
   l_vendor_rec.segment5                       := p_segment5;
   l_vendor_rec.employee_id                    := p_employee_id;
   l_vendor_rec.vendor_type_lookup_code        := p_vendor_type_lookup_code;
   l_vendor_rec.customer_num                   := p_customer_num;
   l_vendor_rec.one_time_flag                  := p_one_time_flag;
   l_vendor_rec.parent_vendor_id               := p_parent_vendor_id;
   l_vendor_rec.min_order_amount               := p_min_order_amount;
   l_vendor_rec.terms_id                       := p_terms_id;
   l_vendor_rec.set_of_books_id                := p_set_of_books_id;
   l_vendor_rec.always_take_disc_flag          := p_always_take_disc_flag;
   l_vendor_rec.pay_date_basis_lookup_code     := p_pay_date_basis_lookup_code;
   l_vendor_rec.pay_group_lookup_code          := p_pay_group_lookup_code;
   l_vendor_rec.payment_priority               := p_payment_priority;
   l_vendor_rec.invoice_currency_code          := p_invoice_currency_code;
   l_vendor_rec.payment_currency_code          := p_payment_currency_code;
   l_vendor_rec.invoice_amount_limit           := p_invoice_amount_limit;
   l_vendor_rec.hold_all_payments_flag         := p_hold_all_payments_flag;
   l_vendor_rec.hold_future_payments_flag      := p_hold_future_payments_flag;
   l_vendor_rec.hold_reason                    := p_hold_reason;
   l_vendor_rec.type_1099                      := p_type_1099;
   l_vendor_rec.withholding_status_lookup_code := p_withhold_status_lookup_code;
   l_vendor_rec.withholding_start_date         := p_withholding_start_date;
   l_vendor_rec.organization_type_lookup_code  := p_org_type_lookup_code;
   l_vendor_rec.start_date_active              := p_start_date_active;
   l_vendor_rec.end_date_active                := p_end_date_active;
   l_vendor_rec.minority_group_lookup_code     := p_minority_group_lookup_code;
   l_vendor_rec.women_owned_flag               := p_women_owned_flag;
   l_vendor_rec.small_business_flag            := p_small_business_flag;
   l_vendor_rec.hold_flag                      := p_hold_flag;
   l_vendor_rec.purchasing_hold_reason         := p_purchasing_hold_reason;
   l_vendor_rec.hold_by                        := p_hold_by;
   l_vendor_rec.hold_date                      := p_hold_date;
   l_vendor_rec.terms_date_basis               := p_terms_date_basis;
   l_vendor_rec.inspection_required_flag       := p_inspection_required_flag;
   l_vendor_rec.receipt_required_flag          := p_receipt_required_flag;
   l_vendor_rec.qty_rcv_tolerance              := p_qty_rcv_tolerance;
   l_vendor_rec.qty_rcv_exception_code         := p_qty_rcv_exception_code;
   l_vendor_rec.enforce_ship_to_location_code  := p_enforce_ship_to_loc_code;
   l_vendor_rec.days_early_receipt_allowed     := p_days_early_receipt_allowed;
   l_vendor_rec.days_late_receipt_allowed      := p_days_late_receipt_allowed;
   l_vendor_rec.receipt_days_exception_code    := p_receipt_days_exception_code;
   l_vendor_rec.receiving_routing_id           := p_receiving_routing_id;
   l_vendor_rec.allow_substitute_receipts_flag := p_allow_substi_receipts_flag;
   l_vendor_rec.allow_unordered_receipts_flag  := p_allow_unorder_receipts_flag;
   l_vendor_rec.hold_unmatched_invoices_flag   := p_hold_unmatched_invoices_flag;
   l_vendor_rec.tax_verification_date          := p_tax_verification_date;
   l_vendor_rec.name_control                   := p_name_control;
   l_vendor_rec.state_reportable_flag          := p_state_reportable_flag;
   l_vendor_rec.federal_reportable_flag        := p_federal_reportable_flag;
   l_vendor_rec.attribute_category             := p_attribute_category;
   l_vendor_rec.attribute1                     := p_attribute1;
   l_vendor_rec.attribute2                     := p_attribute2;
   l_vendor_rec.attribute3                     := p_attribute3;
   l_vendor_rec.attribute4                     := p_attribute4;
   l_vendor_rec.attribute5                     := p_attribute5;
   l_vendor_rec.attribute6                     := p_attribute6;
   l_vendor_rec.attribute7                     := p_attribute7;
   l_vendor_rec.attribute8                     := p_attribute8;
   l_vendor_rec.attribute9                     := p_attribute9;
   l_vendor_rec.attribute10                    := p_attribute10;
   l_vendor_rec.attribute11                    := p_attribute11;
   l_vendor_rec.attribute12                    := p_attribute12;
   l_vendor_rec.attribute13                    := p_attribute13;
   l_vendor_rec.attribute14                    := p_attribute14;
   l_vendor_rec.attribute15                    := p_attribute15;
   l_vendor_rec.auto_calculate_interest_flag   := p_auto_calculate_interest_flag;
   l_vendor_rec.validation_number              := p_validation_number;
   l_vendor_rec.exclude_freight_from_discount  := p_exclude_freight_from_discnt;
   l_vendor_rec.tax_reporting_name             := p_tax_reporting_name;
   l_vendor_rec.check_digits                   := p_check_digits;
   l_vendor_rec.allow_awt_flag                 := p_allow_awt_flag;
   l_vendor_rec.awt_group_id                   := p_awt_group_id;
   l_vendor_rec.pay_awt_group_id               := p_pay_awt_group_id;
   l_vendor_rec.awt_group_name                 := p_awt_group_name;
   l_vendor_rec.pay_awt_group_name             := p_pay_awt_group_name;
   l_vendor_rec.global_attribute1              := p_global_attribute1;
   l_vendor_rec.global_attribute2              := p_global_attribute2;
   l_vendor_rec.global_attribute3              := p_global_attribute3;
   l_vendor_rec.global_attribute4              := p_global_attribute4;
   l_vendor_rec.global_attribute5              := p_global_attribute5;
   l_vendor_rec.global_attribute6              := p_global_attribute6;
   l_vendor_rec.global_attribute7              := p_global_attribute7;
   l_vendor_rec.global_attribute8              := p_global_attribute8;
   l_vendor_rec.global_attribute9              := p_global_attribute9;
   l_vendor_rec.global_attribute10             := p_global_attribute10;
   l_vendor_rec.global_attribute11             := p_global_attribute11;
   l_vendor_rec.global_attribute12             := p_global_attribute12;
   l_vendor_rec.global_attribute13             := p_global_attribute13;
   l_vendor_rec.global_attribute14             := p_global_attribute14;
   l_vendor_rec.global_attribute15             := p_global_attribute15;
   l_vendor_rec.global_attribute16             := p_global_attribute16;
   l_vendor_rec.global_attribute17             := p_global_attribute17;
   l_vendor_rec.global_attribute18             := p_global_attribute18;
   l_vendor_rec.global_attribute19             := p_global_attribute19;
   l_vendor_rec.global_attribute20             := p_global_attribute20;
   l_vendor_rec.global_attribute_category      := p_global_attribute_category;
   l_vendor_rec.bank_charge_bearer             := p_bank_charge_bearer;
   --l_vendor_rec.bank_branch_type               := p_bank_branch_type;
   l_vendor_rec.match_option                   := p_match_option;
   l_vendor_rec.create_debit_memo_flag         := p_create_debit_memo_flag;
   l_vendor_rec.party_id                       := p_party_id;
   l_vendor_rec.parent_party_id                := p_parent_party_id;
   l_vendor_rec.jgzz_fiscal_code               := p_jgzz_fiscal_code;
   l_vendor_rec.sic_code                       := p_sic_code;
   l_vendor_rec.tax_reference                  := p_tax_reference;
   l_vendor_rec.inventory_organization_id      := p_inventory_organization_id;
   l_vendor_rec.terms_name                     := p_terms_name;
   l_vendor_rec.default_terms_id               := p_default_terms_id;
   l_vendor_rec.ni_number                      := p_ni_number;

   Create_Vendor
     (
      p_vendor_rec      => l_vendor_rec,
      x_return_status   => x_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data,
      x_vendor_id       => x_vendor_id,
      x_party_id        => x_party_id
      );

   combine_err_msg(x_return_status, l_msg_count, l_msg_data, x_error_msg);

END Create_Vendor;

-- Notes: This API will not update any TCA tables. It updates vendor info only.
--        This is because the procedure calls the corresponding procedure in
--        AP_VENDOR_PUB_PKG which does not update TCA tables.
PROCEDURE Update_Vendor
(
  p_vendor_id                       IN  NUMBER   ,
  p_segment1                        IN  VARCHAR2 ,
  p_vendor_name                     IN  VARCHAR2 ,
  p_vendor_name_alt                 IN  VARCHAR2 ,
  p_summary_flag                    IN  VARCHAR2 ,
  p_enabled_flag                    IN  VARCHAR2 ,
  p_segment2                        IN  VARCHAR2 ,
  p_segment3                        IN  VARCHAR2 ,
  p_segment4                        IN  VARCHAR2 ,
  p_segment5                        IN  VARCHAR2 ,
  p_employee_id                     IN  NUMBER   ,
  p_vendor_type_lookup_code         IN  VARCHAR2 ,
  p_customer_num                    IN  VARCHAR2 ,
  p_one_time_flag                   IN  VARCHAR2 ,
  p_parent_vendor_id                IN  NUMBER   ,
  p_min_order_amount                IN  NUMBER   ,
  p_terms_id                        IN  NUMBER   ,
  p_set_of_books_id                 IN  NUMBER   ,
  p_always_take_disc_flag           IN  VARCHAR2 ,
  p_pay_date_basis_lookup_code      IN  VARCHAR2 ,
  p_pay_group_lookup_code           IN  VARCHAR2 ,
  p_payment_priority                IN  NUMBER   ,
  p_invoice_currency_code           IN  VARCHAR2 ,
  p_payment_currency_code           IN  VARCHAR2 ,
  p_invoice_amount_limit            IN  NUMBER   ,
  p_hold_all_payments_flag          IN  VARCHAR2 ,
  p_hold_future_payments_flag       IN  VARCHAR2 ,
  p_hold_reason                     IN  VARCHAR2 ,
  p_type_1099                       IN  VARCHAR2 ,
  p_withhold_status_lookup_code     IN  VARCHAR2 ,
  p_withholding_start_date          IN  DATE     ,
  p_org_type_lookup_code            IN  VARCHAR2 ,
  p_start_date_active               IN  DATE     ,
  p_end_date_active                 IN  DATE     ,
  p_minority_group_lookup_code      IN  VARCHAR2 ,
  p_women_owned_flag                IN  VARCHAR2 ,
  p_small_business_flag             IN  VARCHAR2 ,
  p_hold_flag                       IN  VARCHAR2 ,
  p_purchasing_hold_reason          IN  VARCHAR2 ,
  p_hold_by                         IN  NUMBER   ,
  p_hold_date                       IN  DATE     ,
  p_terms_date_basis                IN  VARCHAR2 ,
  p_inspection_required_flag        IN  VARCHAR2 ,
  p_receipt_required_flag           IN  VARCHAR2 ,
  p_qty_rcv_tolerance               IN  NUMBER   ,
  p_qty_rcv_exception_code          IN  VARCHAR2 ,
  p_enforce_ship_to_loc_code        IN  VARCHAR2 ,
  p_days_early_receipt_allowed      IN  NUMBER   ,
  p_days_late_receipt_allowed       IN  NUMBER   ,
  p_receipt_days_exception_code     IN  VARCHAR2 ,
  p_receiving_routing_id            IN  NUMBER   ,
  p_allow_substi_receipts_flag      IN  VARCHAR2 ,
  p_allow_unorder_receipts_flag     IN  VARCHAR2 ,
  p_hold_unmatched_invoices_flag    IN  VARCHAR2 ,
  p_tax_verification_date           IN  DATE     ,
  p_name_control                    IN  VARCHAR2 ,
  p_state_reportable_flag           IN  VARCHAR2 ,
  p_federal_reportable_flag         IN  VARCHAR2 ,
  p_attribute_category              IN  VARCHAR2 ,
  p_attribute1                      IN  VARCHAR2 ,
  p_attribute2                      IN  VARCHAR2 ,
  p_attribute3                      IN  VARCHAR2 ,
  p_attribute4                      IN  VARCHAR2 ,
  p_attribute5                      IN  VARCHAR2 ,
  p_attribute6                      IN  VARCHAR2 ,
  p_attribute7                      IN  VARCHAR2 ,
  p_attribute8                      IN  VARCHAR2 ,
  p_attribute9                      IN  VARCHAR2 ,
  p_attribute10                     IN  VARCHAR2 ,
  p_attribute11                     IN  VARCHAR2 ,
  p_attribute12                     IN  VARCHAR2 ,
  p_attribute13                     IN  VARCHAR2 ,
  p_attribute14                     IN  VARCHAR2 ,
  p_attribute15                     IN  VARCHAR2 ,
  p_auto_calculate_interest_flag    IN  VARCHAR2 ,
  p_validation_number               IN  NUMBER   ,
  p_exclude_freight_from_discnt     IN  VARCHAR2 ,
  p_tax_reporting_name              IN  VARCHAR2 ,
  p_check_digits                    IN  VARCHAR2 ,
  p_allow_awt_flag                  IN  VARCHAR2 ,
  p_awt_group_id                    IN  NUMBER   ,
  p_pay_awt_group_id                IN  NUMBER   ,
  p_awt_group_name                  IN  VARCHAR2 ,
  p_pay_awt_group_name              IN  VARCHAR2 ,
  p_global_attribute1               IN  VARCHAR2 ,
  p_global_attribute2               IN  VARCHAR2 ,
  p_global_attribute3               IN  VARCHAR2 ,
  p_global_attribute4               IN  VARCHAR2 ,
  p_global_attribute5               IN  VARCHAR2 ,
  p_global_attribute6               IN  VARCHAR2 ,
  p_global_attribute7               IN  VARCHAR2 ,
  p_global_attribute8               IN  VARCHAR2 ,
  p_global_attribute9               IN  VARCHAR2 ,
  p_global_attribute10              IN  VARCHAR2 ,
  p_global_attribute11              IN  VARCHAR2 ,
  p_global_attribute12              IN  VARCHAR2 ,
  p_global_attribute13              IN  VARCHAR2 ,
  p_global_attribute14              IN  VARCHAR2 ,
  p_global_attribute15              IN  VARCHAR2 ,
  p_global_attribute16              IN  VARCHAR2 ,
  p_global_attribute17              IN  VARCHAR2 ,
  p_global_attribute18              IN  VARCHAR2 ,
  p_global_attribute19              IN  VARCHAR2 ,
  p_global_attribute20              IN  VARCHAR2 ,
  p_global_attribute_category       IN  VARCHAR2 ,
  p_bank_charge_bearer              IN  VARCHAR2 ,
  p_bank_branch_type                IN  VARCHAR2 ,
  p_match_option                    IN  VARCHAR2 ,
  p_create_debit_memo_flag          IN  VARCHAR2 ,
  p_party_id                        IN  NUMBER   ,
  p_parent_party_id                 IN  NUMBER   ,
  p_jgzz_fiscal_code                IN  VARCHAR2 ,
  p_sic_code                        IN  VARCHAR2 ,
  p_tax_reference                   IN  VARCHAR2 ,
  p_inventory_organization_id       IN  NUMBER   ,
  p_terms_name                      IN  VARCHAR2 ,
  p_default_terms_id                IN  NUMBER   ,
  p_ni_number                       IN  VARCHAR2 ,
  p_last_update_date                IN  DATE DEFAULT NULL,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_error_msg       OUT NOCOPY VARCHAR2
)
  IS
   l_vendor_rec ap_vendor_pub_pkg.r_vendor_rec_type;
   l_msg_count  NUMBER;
   l_msg_data   VARCHAR2(4000);
   l_last_update_date DATE;
   is_supp_ccr VARCHAR2(1);

BEGIN

   -- BUG 5926560
   if p_last_update_date is not NULL then
    select last_update_date into l_last_update_date
    from ap_suppliers where vendor_id = p_vendor_id;
    if l_last_update_date > p_last_update_date then
      x_error_msg :=  fnd_message.get_string('POS','POS_LOCK_SUPPLIER_ROW');
      x_return_status := 'E';
      return;
    end if;
   end if;

   l_vendor_rec.vendor_id                      := p_vendor_id;
   l_vendor_rec.segment1                       := Nvl(p_segment1, fnd_api.g_null_char);
   l_vendor_rec.vendor_name                    := Nvl(p_vendor_name, fnd_api.g_null_char);
   l_vendor_rec.vendor_name_alt                := Nvl(p_vendor_name_alt, fnd_api.g_null_char);
   l_vendor_rec.summary_flag                   := Nvl(p_summary_flag, fnd_api.g_null_char);
   l_vendor_rec.enabled_flag                   := Nvl(p_enabled_flag, fnd_api.g_null_char);
   l_vendor_rec.segment2                       := Nvl(p_segment2, fnd_api.g_null_char);
   l_vendor_rec.segment3                       := Nvl(p_segment3, fnd_api.g_null_char);
   l_vendor_rec.segment4                       := Nvl(p_segment4, fnd_api.g_null_char);
   l_vendor_rec.segment5                       := Nvl(p_segment5, fnd_api.g_null_char);
   l_vendor_rec.employee_id                    := p_employee_id;
   l_vendor_rec.vendor_type_lookup_code        := Nvl(p_vendor_type_lookup_code, fnd_api.g_null_char);
   l_vendor_rec.customer_num                   := Nvl(p_customer_num, fnd_api.g_null_char);
   l_vendor_rec.one_time_flag                  := Nvl(p_one_time_flag, fnd_api.g_null_char);
   l_vendor_rec.parent_vendor_id               := Nvl(p_parent_vendor_id, fnd_api.g_null_num);
   l_vendor_rec.min_order_amount               := Nvl(p_min_order_amount, fnd_api.g_null_num);
   l_vendor_rec.terms_id                       := Nvl(p_terms_id, fnd_api.g_null_num);
   l_vendor_rec.set_of_books_id                := Nvl(p_set_of_books_id, fnd_api.g_null_num);
   l_vendor_rec.always_take_disc_flag          := Nvl(p_always_take_disc_flag, fnd_api.g_null_char);
   l_vendor_rec.pay_date_basis_lookup_code     := Nvl(p_pay_date_basis_lookup_code, fnd_api.g_null_char);
   l_vendor_rec.pay_group_lookup_code          := Nvl(p_pay_group_lookup_code, fnd_api.g_null_char);
   l_vendor_rec.payment_priority               := Nvl(p_payment_priority, fnd_api.g_null_num);
   l_vendor_rec.invoice_currency_code          := Nvl(p_invoice_currency_code, fnd_api.g_null_char);
   l_vendor_rec.payment_currency_code          := Nvl(p_payment_currency_code, fnd_api.g_null_char);
   l_vendor_rec.invoice_amount_limit           := Nvl(p_invoice_amount_limit, fnd_api.g_null_num);
   l_vendor_rec.hold_all_payments_flag         := Nvl(p_hold_all_payments_flag, fnd_api.g_null_char);
   l_vendor_rec.hold_future_payments_flag      := Nvl(p_hold_future_payments_flag, fnd_api.g_null_char);
   l_vendor_rec.hold_reason                    := Nvl(p_hold_reason, fnd_api.g_null_char);
   l_vendor_rec.type_1099                      := Nvl(p_type_1099, fnd_api.g_null_char);
   l_vendor_rec.withholding_status_lookup_code := Nvl(p_withhold_status_lookup_code, fnd_api.g_null_char);
   l_vendor_rec.withholding_start_date         := Nvl(p_withholding_start_date, fnd_api.g_null_date);
   l_vendor_rec.organization_type_lookup_code  := Nvl(p_org_type_lookup_code, fnd_api.g_null_char);
   l_vendor_rec.start_date_active              := Nvl(p_start_date_active, fnd_api.g_null_date);
   l_vendor_rec.end_date_active                := Nvl(p_end_date_active, fnd_api.g_null_date);
   l_vendor_rec.minority_group_lookup_code     := Nvl(p_minority_group_lookup_code, fnd_api.g_null_char);
   l_vendor_rec.women_owned_flag               := Nvl(p_women_owned_flag, fnd_api.g_null_char);
   l_vendor_rec.small_business_flag            := Nvl(p_small_business_flag, fnd_api.g_null_char);
   l_vendor_rec.hold_flag                      := Nvl(p_hold_flag, fnd_api.g_null_char);
   l_vendor_rec.purchasing_hold_reason         := Nvl(p_purchasing_hold_reason, fnd_api.g_null_char);
   l_vendor_rec.hold_by                        := Nvl(p_hold_by, fnd_api.g_null_num);
   l_vendor_rec.hold_date                      := Nvl(p_hold_date, fnd_api.g_null_date);
   l_vendor_rec.terms_date_basis               := Nvl(p_terms_date_basis, fnd_api.g_null_char);
   l_vendor_rec.inspection_required_flag       := Nvl(p_inspection_required_flag, fnd_api.g_null_char);
   l_vendor_rec.receipt_required_flag          := Nvl(p_receipt_required_flag, fnd_api.g_null_char);
   l_vendor_rec.qty_rcv_tolerance              := Nvl(p_qty_rcv_tolerance, fnd_api.g_null_num);
   l_vendor_rec.qty_rcv_exception_code         := Nvl(p_qty_rcv_exception_code, fnd_api.g_null_char);
   l_vendor_rec.enforce_ship_to_location_code  := Nvl(p_enforce_ship_to_loc_code, fnd_api.g_null_char);
   l_vendor_rec.days_early_receipt_allowed     := Nvl(p_days_early_receipt_allowed, fnd_api.g_null_num);
   l_vendor_rec.days_late_receipt_allowed      := Nvl(p_days_late_receipt_allowed, fnd_api.g_null_num);
   l_vendor_rec.receipt_days_exception_code    := Nvl(p_receipt_days_exception_code, fnd_api.g_null_char);
   l_vendor_rec.receiving_routing_id           := Nvl(p_receiving_routing_id, fnd_api.g_null_num);
   l_vendor_rec.allow_substitute_receipts_flag := Nvl(p_allow_substi_receipts_flag, fnd_api.g_null_char);
   l_vendor_rec.allow_unordered_receipts_flag  := Nvl(p_allow_unorder_receipts_flag, fnd_api.g_null_char);
   l_vendor_rec.hold_unmatched_invoices_flag   := Nvl(p_hold_unmatched_invoices_flag, fnd_api.g_null_char);
   l_vendor_rec.tax_verification_date          := Nvl(p_tax_verification_date, fnd_api.g_null_date);
   l_vendor_rec.name_control                   := Nvl(p_name_control, fnd_api.g_null_char);
   l_vendor_rec.state_reportable_flag          := Nvl(p_state_reportable_flag, fnd_api.g_null_char);
   l_vendor_rec.federal_reportable_flag        := Nvl(p_federal_reportable_flag, fnd_api.g_null_char);
   l_vendor_rec.attribute_category             := Nvl(p_attribute_category, fnd_api.g_null_char);
   l_vendor_rec.attribute1                     := Nvl(p_attribute1, fnd_api.g_null_char);
   l_vendor_rec.attribute2                     := Nvl(p_attribute2, fnd_api.g_null_char);
   l_vendor_rec.attribute3                     := Nvl(p_attribute3, fnd_api.g_null_char);
   l_vendor_rec.attribute4                     := Nvl(p_attribute4, fnd_api.g_null_char);
   l_vendor_rec.attribute5                     := Nvl(p_attribute5, fnd_api.g_null_char);
   l_vendor_rec.attribute6                     := Nvl(p_attribute6, fnd_api.g_null_char);
   l_vendor_rec.attribute7                     := Nvl(p_attribute7, fnd_api.g_null_char);
   l_vendor_rec.attribute8                     := Nvl(p_attribute8, fnd_api.g_null_char);
   l_vendor_rec.attribute9                     := Nvl(p_attribute9, fnd_api.g_null_char);
   l_vendor_rec.attribute10                    := Nvl(p_attribute10, fnd_api.g_null_char);
   l_vendor_rec.attribute11                    := Nvl(p_attribute11, fnd_api.g_null_char);
   l_vendor_rec.attribute12                    := Nvl(p_attribute12, fnd_api.g_null_char);
   l_vendor_rec.attribute13                    := Nvl(p_attribute13, fnd_api.g_null_char);
   l_vendor_rec.attribute14                    := Nvl(p_attribute14, fnd_api.g_null_char);
   l_vendor_rec.attribute15                    := Nvl(p_attribute15, fnd_api.g_null_char);
   l_vendor_rec.auto_calculate_interest_flag   := Nvl(p_auto_calculate_interest_flag, fnd_api.g_null_char);
   l_vendor_rec.validation_number              := Nvl(p_validation_number, fnd_api.g_null_num);
   l_vendor_rec.exclude_freight_from_discount  := Nvl(p_exclude_freight_from_discnt, fnd_api.g_null_char);
   l_vendor_rec.tax_reporting_name             := Nvl(p_tax_reporting_name, fnd_api.g_null_char);
   l_vendor_rec.check_digits                   := Nvl(p_check_digits, fnd_api.g_null_char);
   l_vendor_rec.allow_awt_flag                 := Nvl(p_allow_awt_flag, fnd_api.g_null_char);
   l_vendor_rec.awt_group_id                   := Nvl(p_awt_group_id, fnd_api.g_null_num);
   l_vendor_rec.pay_awt_group_id                   := Nvl(p_pay_awt_group_id, fnd_api.g_null_num);
   l_vendor_rec.awt_group_name                 := p_awt_group_name;
   l_vendor_rec.pay_awt_group_name                 := p_pay_awt_group_name;
   l_vendor_rec.global_attribute1              := Nvl(p_global_attribute1, fnd_api.g_null_char);
   l_vendor_rec.global_attribute2              := Nvl(p_global_attribute2, fnd_api.g_null_char);
   l_vendor_rec.global_attribute3              := Nvl(p_global_attribute3, fnd_api.g_null_char);
   l_vendor_rec.global_attribute4              := Nvl(p_global_attribute4, fnd_api.g_null_char);
   l_vendor_rec.global_attribute5              := Nvl(p_global_attribute5, fnd_api.g_null_char);
   l_vendor_rec.global_attribute6              := Nvl(p_global_attribute6, fnd_api.g_null_char);
   l_vendor_rec.global_attribute7              := Nvl(p_global_attribute7, fnd_api.g_null_char);
   l_vendor_rec.global_attribute8              := Nvl(p_global_attribute8, fnd_api.g_null_char);
   l_vendor_rec.global_attribute9              := Nvl(p_global_attribute9, fnd_api.g_null_char);
   l_vendor_rec.global_attribute10             := Nvl(p_global_attribute10, fnd_api.g_null_char);
   l_vendor_rec.global_attribute11             := Nvl(p_global_attribute11, fnd_api.g_null_char);
   l_vendor_rec.global_attribute12             := Nvl(p_global_attribute12, fnd_api.g_null_char);
   l_vendor_rec.global_attribute13             := Nvl(p_global_attribute13, fnd_api.g_null_char);
   l_vendor_rec.global_attribute14             := Nvl(p_global_attribute14, fnd_api.g_null_char);
   l_vendor_rec.global_attribute15             := Nvl(p_global_attribute15, fnd_api.g_null_char);
   l_vendor_rec.global_attribute16             := Nvl(p_global_attribute16, fnd_api.g_null_char);
   l_vendor_rec.global_attribute17             := Nvl(p_global_attribute17, fnd_api.g_null_char);
   l_vendor_rec.global_attribute18             := Nvl(p_global_attribute18, fnd_api.g_null_char);
   l_vendor_rec.global_attribute19             := Nvl(p_global_attribute19, fnd_api.g_null_char);
   l_vendor_rec.global_attribute20             := Nvl(p_global_attribute20, fnd_api.g_null_char);
   l_vendor_rec.global_attribute_category      := Nvl(p_global_attribute_category, fnd_api.g_null_char);
   l_vendor_rec.bank_charge_bearer             := Nvl(p_bank_charge_bearer, fnd_api.g_null_char);
   l_vendor_rec.match_option                   := Nvl(p_match_option, fnd_api.g_null_char);
   l_vendor_rec.create_debit_memo_flag         := Nvl(p_create_debit_memo_flag, fnd_api.g_null_char);
   l_vendor_rec.party_id                       := Nvl(p_party_id, fnd_api.g_null_num);
   l_vendor_rec.parent_party_id                := Nvl(p_parent_party_id, fnd_api.g_null_num);
   l_vendor_rec.jgzz_fiscal_code               := Nvl(p_jgzz_fiscal_code, fnd_api.g_null_char);
   l_vendor_rec.sic_code                       := p_sic_code;
   l_vendor_rec.tax_reference                  := Nvl(p_tax_reference, fnd_api.g_null_char);
   l_vendor_rec.inventory_organization_id      := Nvl(p_inventory_organization_id, fnd_api.g_null_num);
   l_vendor_rec.terms_name                     := p_terms_name;
   l_vendor_rec.default_terms_id               := Nvl(p_default_terms_id, fnd_api.g_null_num);
   l_vendor_rec.ni_number                      := Nvl(p_ni_number, fnd_api.g_null_char);
   -- ccr code starts
   is_supp_ccr := POS_UTIL_PKG.IS_SUPP_CCR(1.0,null,l_vendor_rec.vendor_id);
   if is_supp_ccr = 'T' then
      l_vendor_rec.jgzz_fiscal_code := null;
   end if;
   -- ccr code ends
   Update_Vendor
     (
      p_vendor_rec      => l_vendor_rec,
      x_return_status   => x_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data
      );

   combine_err_msg(x_return_status, l_msg_count, l_msg_data, x_error_msg);

END Update_Vendor;

-- Notes:
--   p_mode: Indicates whether the calling code is in insert or update mode.
--           (I, U)
--
--   p_party_valid:  Indicates how valid the calling program's party_id was
--                   (V, N, F) Valid, Null or False

PROCEDURE Validate_Vendor
(
  p_vendor_id                       IN  NUMBER   ,
  p_segment1                        IN  VARCHAR2 ,
  p_vendor_name                     IN  VARCHAR2 ,
  p_vendor_name_alt                 IN  VARCHAR2 ,
  p_summary_flag                    IN  VARCHAR2 ,
  p_enabled_flag                    IN  VARCHAR2 ,
  p_segment2                        IN  VARCHAR2 ,
  p_segment3                        IN  VARCHAR2 ,
  p_segment4                        IN  VARCHAR2 ,
  p_segment5                        IN  VARCHAR2 ,
  p_employee_id                     IN  NUMBER   ,
  p_vendor_type_lookup_code         IN  VARCHAR2 ,
  p_customer_num                    IN  VARCHAR2 ,
  p_one_time_flag                   IN  VARCHAR2 ,
  p_parent_vendor_id                IN  NUMBER   ,
  p_min_order_amount                IN  NUMBER   ,
  p_terms_id                        IN  NUMBER   ,
  p_set_of_books_id                 IN  NUMBER   ,
  p_always_take_disc_flag           IN  VARCHAR2 ,
  p_pay_date_basis_lookup_code      IN  VARCHAR2 ,
  p_pay_group_lookup_code           IN  VARCHAR2 ,
  p_payment_priority                IN  NUMBER   ,
  p_invoice_currency_code           IN  VARCHAR2 ,
  p_payment_currency_code           IN  VARCHAR2 ,
  p_invoice_amount_limit            IN  NUMBER   ,
  p_hold_all_payments_flag          IN  VARCHAR2 ,
  p_hold_future_payments_flag       IN  VARCHAR2 ,
  p_hold_reason                     IN  VARCHAR2 ,
  p_type_1099                       IN  VARCHAR2 ,
  p_withhold_status_lookup_code     IN  VARCHAR2 ,
  p_withholding_start_date          IN  DATE     ,
  p_org_type_lookup_code            IN  VARCHAR2 ,
  p_start_date_active               IN  DATE     ,
  p_end_date_active                 IN  DATE     ,
  p_minority_group_lookup_code      IN  VARCHAR2 ,
  p_women_owned_flag                IN  VARCHAR2 ,
  p_small_business_flag             IN  VARCHAR2 ,
  p_hold_flag                       IN  VARCHAR2 ,
  p_purchasing_hold_reason          IN  VARCHAR2 ,
  p_hold_by                         IN  NUMBER   ,
  p_hold_date                       IN  DATE     ,
  p_terms_date_basis                IN  VARCHAR2 ,
  p_inspection_required_flag        IN  VARCHAR2 ,
  p_receipt_required_flag           IN  VARCHAR2 ,
  p_qty_rcv_tolerance               IN  NUMBER   ,
  p_qty_rcv_exception_code          IN  VARCHAR2 ,
  p_enforce_ship_to_loc_code        IN  VARCHAR2 ,
  p_days_early_receipt_allowed      IN  NUMBER   ,
  p_days_late_receipt_allowed       IN  NUMBER   ,
  p_receipt_days_exception_code     IN  VARCHAR2 ,
  p_receiving_routing_id            IN  NUMBER   ,
  p_allow_substi_receipts_flag      IN  VARCHAR2 ,
  p_allow_unorder_receipts_flag     IN  VARCHAR2 ,
  p_hold_unmatched_invoices_flag    IN  VARCHAR2 ,
  p_tax_verification_date           IN  DATE     ,
  p_name_control                    IN  VARCHAR2 ,
  p_state_reportable_flag           IN  VARCHAR2 ,
  p_federal_reportable_flag         IN  VARCHAR2 ,
  p_attribute_category              IN  VARCHAR2 ,
  p_attribute1                      IN  VARCHAR2 ,
  p_attribute2                      IN  VARCHAR2 ,
  p_attribute3                      IN  VARCHAR2 ,
  p_attribute4                      IN  VARCHAR2 ,
  p_attribute5                      IN  VARCHAR2 ,
  p_attribute6                      IN  VARCHAR2 ,
  p_attribute7                      IN  VARCHAR2 ,
  p_attribute8                      IN  VARCHAR2 ,
  p_attribute9                      IN  VARCHAR2 ,
  p_attribute10                     IN  VARCHAR2 ,
  p_attribute11                     IN  VARCHAR2 ,
  p_attribute12                     IN  VARCHAR2 ,
  p_attribute13                     IN  VARCHAR2 ,
  p_attribute14                     IN  VARCHAR2 ,
  p_attribute15                     IN  VARCHAR2 ,
  p_auto_calculate_interest_flag    IN  VARCHAR2 ,
  p_validation_number               IN  NUMBER   ,
  p_exclude_freight_from_discnt     IN  VARCHAR2 ,
  p_tax_reporting_name              IN  VARCHAR2 ,
  p_check_digits                    IN  VARCHAR2 ,
  p_allow_awt_flag                  IN  VARCHAR2 ,
  p_awt_group_id                    IN  NUMBER   ,
  p_pay_awt_group_id                    IN  NUMBER   ,
  p_awt_group_name                  IN  VARCHAR2 ,
  p_pay_awt_group_name                  IN  VARCHAR2 ,
  p_global_attribute1               IN  VARCHAR2 ,
  p_global_attribute2               IN  VARCHAR2 ,
  p_global_attribute3               IN  VARCHAR2 ,
  p_global_attribute4               IN  VARCHAR2 ,
  p_global_attribute5               IN  VARCHAR2 ,
  p_global_attribute6               IN  VARCHAR2 ,
  p_global_attribute7               IN  VARCHAR2 ,
  p_global_attribute8               IN  VARCHAR2 ,
  p_global_attribute9               IN  VARCHAR2 ,
  p_global_attribute10              IN  VARCHAR2 ,
  p_global_attribute11              IN  VARCHAR2 ,
  p_global_attribute12              IN  VARCHAR2 ,
  p_global_attribute13              IN  VARCHAR2 ,
  p_global_attribute14              IN  VARCHAR2 ,
  p_global_attribute15              IN  VARCHAR2 ,
  p_global_attribute16              IN  VARCHAR2 ,
  p_global_attribute17              IN  VARCHAR2 ,
  p_global_attribute18              IN  VARCHAR2 ,
  p_global_attribute19              IN  VARCHAR2 ,
  p_global_attribute20              IN  VARCHAR2 ,
  p_global_attribute_category       IN  VARCHAR2 ,
  p_bank_charge_bearer              IN  VARCHAR2 ,
  p_bank_branch_type                IN  VARCHAR2 ,
  p_match_option                    IN  VARCHAR2 ,
  p_create_debit_memo_flag          IN  VARCHAR2 ,
  p_party_id                        IN  NUMBER   ,
  p_parent_party_id                 IN  NUMBER   ,
  p_jgzz_fiscal_code                IN  VARCHAR2 ,
  p_sic_code                        IN  VARCHAR2 ,
  p_tax_reference                   IN  VARCHAR2 ,
  p_inventory_organization_id       IN  NUMBER   ,
  p_terms_name                      IN  VARCHAR2 ,
  p_default_terms_id                IN  NUMBER   ,
  p_ni_number                       IN  VARCHAR2 ,
  p_mode           IN  VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_error_msg      OUT NOCOPY VARCHAR2,
  x_party_valid    OUT NOCOPY VARCHAR2
)
  IS
   l_vendor_rec ap_vendor_pub_pkg.r_vendor_rec_type;
   l_msg_count  NUMBER;
   l_msg_data   VARCHAR2(4000);
   is_supp_ccr VARCHAR2(1);
BEGIN

   l_vendor_rec.vendor_id                      := p_vendor_id;
   l_vendor_rec.segment1                       := Nvl(p_segment1, fnd_api.g_null_char);
   l_vendor_rec.vendor_name                    := Nvl(p_vendor_name, fnd_api.g_null_char);
   l_vendor_rec.vendor_name_alt                := Nvl(p_vendor_name_alt, fnd_api.g_null_char);
   l_vendor_rec.summary_flag                   := Nvl(p_summary_flag, fnd_api.g_null_char);
   l_vendor_rec.enabled_flag                   := Nvl(p_enabled_flag, fnd_api.g_null_char);
   l_vendor_rec.segment2                       := Nvl(p_segment2, fnd_api.g_null_char);
   l_vendor_rec.segment3                       := Nvl(p_segment3, fnd_api.g_null_char);
   l_vendor_rec.segment4                       := Nvl(p_segment4, fnd_api.g_null_char);
   l_vendor_rec.segment5                       := Nvl(p_segment5, fnd_api.g_null_char);
   l_vendor_rec.employee_id                    := p_employee_id;
   l_vendor_rec.vendor_type_lookup_code        := Nvl(p_vendor_type_lookup_code, fnd_api.g_null_char);
   l_vendor_rec.customer_num                   := Nvl(p_customer_num, fnd_api.g_null_char);
   l_vendor_rec.one_time_flag                  := Nvl(p_one_time_flag, fnd_api.g_null_char);
   l_vendor_rec.parent_vendor_id               := Nvl(p_parent_vendor_id, fnd_api.g_null_num);
   l_vendor_rec.min_order_amount               := Nvl(p_min_order_amount, fnd_api.g_null_num);
   l_vendor_rec.terms_id                       := Nvl(p_terms_id, fnd_api.g_null_num);
   l_vendor_rec.set_of_books_id                := Nvl(p_set_of_books_id, fnd_api.g_null_num);
   l_vendor_rec.always_take_disc_flag          := Nvl(p_always_take_disc_flag, fnd_api.g_null_char);
   l_vendor_rec.pay_date_basis_lookup_code     := Nvl(p_pay_date_basis_lookup_code, fnd_api.g_null_char);
   l_vendor_rec.pay_group_lookup_code          := Nvl(p_pay_group_lookup_code, fnd_api.g_null_char);
   l_vendor_rec.payment_priority               := Nvl(p_payment_priority, fnd_api.g_null_num);
   l_vendor_rec.invoice_currency_code          := Nvl(p_invoice_currency_code, fnd_api.g_null_char);
   l_vendor_rec.payment_currency_code          := Nvl(p_payment_currency_code, fnd_api.g_null_char);
   l_vendor_rec.invoice_amount_limit           := Nvl(p_invoice_amount_limit, fnd_api.g_null_num);
   l_vendor_rec.hold_all_payments_flag         := Nvl(p_hold_all_payments_flag, fnd_api.g_null_char);
   l_vendor_rec.hold_future_payments_flag      := Nvl(p_hold_future_payments_flag, fnd_api.g_null_char);
   l_vendor_rec.hold_reason                    := Nvl(p_hold_reason, fnd_api.g_null_char);
   l_vendor_rec.type_1099                      := Nvl(p_type_1099, fnd_api.g_null_char);
   l_vendor_rec.withholding_status_lookup_code := Nvl(p_withhold_status_lookup_code, fnd_api.g_null_char);
   l_vendor_rec.withholding_start_date         := Nvl(p_withholding_start_date, fnd_api.g_null_date);
   l_vendor_rec.organization_type_lookup_code  := Nvl(p_org_type_lookup_code, fnd_api.g_null_char);
   l_vendor_rec.start_date_active              := Nvl(p_start_date_active, fnd_api.g_null_date);
   l_vendor_rec.end_date_active                := Nvl(p_end_date_active, fnd_api.g_null_date);
   l_vendor_rec.minority_group_lookup_code     := Nvl(p_minority_group_lookup_code, fnd_api.g_null_char);
   l_vendor_rec.women_owned_flag               := Nvl(p_women_owned_flag, fnd_api.g_null_char);
   l_vendor_rec.small_business_flag            := Nvl(p_small_business_flag, fnd_api.g_null_char);
   l_vendor_rec.hold_flag                      := Nvl(p_hold_flag, fnd_api.g_null_char);
   l_vendor_rec.purchasing_hold_reason         := Nvl(p_purchasing_hold_reason, fnd_api.g_null_char);
   l_vendor_rec.hold_by                        := Nvl(p_hold_by, fnd_api.g_null_num);
   l_vendor_rec.hold_date                      := Nvl(p_hold_date, fnd_api.g_null_date);
   l_vendor_rec.terms_date_basis               := Nvl(p_terms_date_basis, fnd_api.g_null_char);
   l_vendor_rec.inspection_required_flag       := Nvl(p_inspection_required_flag, fnd_api.g_null_char);
   l_vendor_rec.receipt_required_flag          := Nvl(p_receipt_required_flag, fnd_api.g_null_char);
   l_vendor_rec.qty_rcv_tolerance              := Nvl(p_qty_rcv_tolerance, fnd_api.g_null_num);
   l_vendor_rec.qty_rcv_exception_code         := Nvl(p_qty_rcv_exception_code, fnd_api.g_null_char);
   l_vendor_rec.enforce_ship_to_location_code  := Nvl(p_enforce_ship_to_loc_code, fnd_api.g_null_char);
   l_vendor_rec.days_early_receipt_allowed     := Nvl(p_days_early_receipt_allowed, fnd_api.g_null_num);
   l_vendor_rec.days_late_receipt_allowed      := Nvl(p_days_late_receipt_allowed, fnd_api.g_null_num);
   l_vendor_rec.receipt_days_exception_code    := Nvl(p_receipt_days_exception_code, fnd_api.g_null_char);
   l_vendor_rec.receiving_routing_id           := Nvl(p_receiving_routing_id, fnd_api.g_null_num);
   l_vendor_rec.allow_substitute_receipts_flag := Nvl(p_allow_substi_receipts_flag, fnd_api.g_null_char);
   l_vendor_rec.allow_unordered_receipts_flag  := Nvl(p_allow_unorder_receipts_flag, fnd_api.g_null_char);
   l_vendor_rec.hold_unmatched_invoices_flag   := Nvl(p_hold_unmatched_invoices_flag, fnd_api.g_null_char);
   l_vendor_rec.tax_verification_date          := Nvl(p_tax_verification_date, fnd_api.g_null_date);
   l_vendor_rec.name_control                   := Nvl(p_name_control, fnd_api.g_null_char);
   l_vendor_rec.state_reportable_flag          := Nvl(p_state_reportable_flag, fnd_api.g_null_char);
   l_vendor_rec.federal_reportable_flag        := Nvl(p_federal_reportable_flag, fnd_api.g_null_char);
   l_vendor_rec.attribute_category             := Nvl(p_attribute_category, fnd_api.g_null_char);
   l_vendor_rec.attribute1                     := Nvl(p_attribute1, fnd_api.g_null_char);
   l_vendor_rec.attribute2                     := Nvl(p_attribute2, fnd_api.g_null_char);
   l_vendor_rec.attribute3                     := Nvl(p_attribute3, fnd_api.g_null_char);
   l_vendor_rec.attribute4                     := Nvl(p_attribute4, fnd_api.g_null_char);
   l_vendor_rec.attribute5                     := Nvl(p_attribute5, fnd_api.g_null_char);
   l_vendor_rec.attribute6                     := Nvl(p_attribute6, fnd_api.g_null_char);
   l_vendor_rec.attribute7                     := Nvl(p_attribute7, fnd_api.g_null_char);
   l_vendor_rec.attribute8                     := Nvl(p_attribute8, fnd_api.g_null_char);
   l_vendor_rec.attribute9                     := Nvl(p_attribute9, fnd_api.g_null_char);
   l_vendor_rec.attribute10                    := Nvl(p_attribute10, fnd_api.g_null_char);
   l_vendor_rec.attribute11                    := Nvl(p_attribute11, fnd_api.g_null_char);
   l_vendor_rec.attribute12                    := Nvl(p_attribute12, fnd_api.g_null_char);
   l_vendor_rec.attribute13                    := Nvl(p_attribute13, fnd_api.g_null_char);
   l_vendor_rec.attribute14                    := Nvl(p_attribute14, fnd_api.g_null_char);
   l_vendor_rec.attribute15                    := Nvl(p_attribute15, fnd_api.g_null_char);
   l_vendor_rec.auto_calculate_interest_flag   := Nvl(p_auto_calculate_interest_flag, fnd_api.g_null_char);
   l_vendor_rec.validation_number              := Nvl(p_validation_number, fnd_api.g_null_num);
   l_vendor_rec.exclude_freight_from_discount  := Nvl(p_exclude_freight_from_discnt, fnd_api.g_null_char);
   l_vendor_rec.tax_reporting_name             := Nvl(p_tax_reporting_name, fnd_api.g_null_char);
   l_vendor_rec.check_digits                   := Nvl(p_check_digits, fnd_api.g_null_char);
   l_vendor_rec.allow_awt_flag                 := Nvl(p_allow_awt_flag, fnd_api.g_null_char);
   l_vendor_rec.awt_group_id                   := Nvl(p_awt_group_id, fnd_api.g_null_num);
   l_vendor_rec.pay_awt_group_id                   := Nvl(p_pay_awt_group_id, fnd_api.g_null_num);
   l_vendor_rec.awt_group_name                 := p_awt_group_name;
   l_vendor_rec.pay_awt_group_name                 := p_pay_awt_group_name;
   l_vendor_rec.global_attribute1              := Nvl(p_global_attribute1, fnd_api.g_null_char);
   l_vendor_rec.global_attribute2              := Nvl(p_global_attribute2, fnd_api.g_null_char);
   l_vendor_rec.global_attribute3              := Nvl(p_global_attribute3, fnd_api.g_null_char);
   l_vendor_rec.global_attribute4              := Nvl(p_global_attribute4, fnd_api.g_null_char);
   l_vendor_rec.global_attribute5              := Nvl(p_global_attribute5, fnd_api.g_null_char);
   l_vendor_rec.global_attribute6              := Nvl(p_global_attribute6, fnd_api.g_null_char);
   l_vendor_rec.global_attribute7              := Nvl(p_global_attribute7, fnd_api.g_null_char);
   l_vendor_rec.global_attribute8              := Nvl(p_global_attribute8, fnd_api.g_null_char);
   l_vendor_rec.global_attribute9              := Nvl(p_global_attribute9, fnd_api.g_null_char);
   l_vendor_rec.global_attribute10             := Nvl(p_global_attribute10, fnd_api.g_null_char);
   l_vendor_rec.global_attribute11             := Nvl(p_global_attribute11, fnd_api.g_null_char);
   l_vendor_rec.global_attribute12             := Nvl(p_global_attribute12, fnd_api.g_null_char);
   l_vendor_rec.global_attribute13             := Nvl(p_global_attribute13, fnd_api.g_null_char);
   l_vendor_rec.global_attribute14             := Nvl(p_global_attribute14, fnd_api.g_null_char);
   l_vendor_rec.global_attribute15             := Nvl(p_global_attribute15, fnd_api.g_null_char);
   l_vendor_rec.global_attribute16             := Nvl(p_global_attribute16, fnd_api.g_null_char);
   l_vendor_rec.global_attribute17             := Nvl(p_global_attribute17, fnd_api.g_null_char);
   l_vendor_rec.global_attribute18             := Nvl(p_global_attribute18, fnd_api.g_null_char);
   l_vendor_rec.global_attribute19             := Nvl(p_global_attribute19, fnd_api.g_null_char);
   l_vendor_rec.global_attribute20             := Nvl(p_global_attribute20, fnd_api.g_null_char);
   l_vendor_rec.global_attribute_category      := Nvl(p_global_attribute_category, fnd_api.g_null_char);
   l_vendor_rec.bank_charge_bearer             := Nvl(p_bank_charge_bearer, fnd_api.g_null_char);
   --l_vendor_rec.bank_branch_type               := Nvl(p_bank_branch_type, fnd_api.g_null_char);
   l_vendor_rec.match_option                   := Nvl(p_match_option, fnd_api.g_null_char);
   l_vendor_rec.create_debit_memo_flag         := Nvl(p_create_debit_memo_flag, fnd_api.g_null_char);
   l_vendor_rec.party_id                       := Nvl(p_party_id, fnd_api.g_null_num);
   l_vendor_rec.parent_party_id                := Nvl(p_parent_party_id, fnd_api.g_null_num);
   l_vendor_rec.jgzz_fiscal_code               := Nvl(p_jgzz_fiscal_code, fnd_api.g_null_char);
   l_vendor_rec.sic_code                       := Nvl(p_sic_code, fnd_api.g_null_char);
   l_vendor_rec.tax_reference                  := Nvl(p_tax_reference, fnd_api.g_null_char);
   l_vendor_rec.inventory_organization_id      := Nvl(p_inventory_organization_id, fnd_api.g_null_num);
   l_vendor_rec.terms_name                     := p_terms_name;
   l_vendor_rec.default_terms_id               := Nvl(p_default_terms_id, fnd_api.g_null_num);
   l_vendor_rec.ni_number                      := Nvl(p_ni_number, fnd_api.g_null_char);

   -- ccr code starts
   if p_mode = 'U' then
      is_supp_ccr := POS_UTIL_PKG.IS_SUPP_CCR(1.0,null,l_vendor_rec.vendor_id);
      if is_supp_ccr = 'T' then
         l_vendor_rec.jgzz_fiscal_code := null;
      end if;
   end if;
   -- ccr code ends


   Validate_Vendor
     (
      p_vendor_rec      => l_vendor_rec,
      p_mode            => p_mode,
      x_return_status   => x_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data,
      x_party_valid     => x_party_valid
      );

   combine_err_msg(x_return_status, l_msg_count, l_msg_data, x_error_msg);

END Validate_Vendor;

PROCEDURE Create_Vendor_Site
(
  p_area_code                      IN  VARCHAR2 DEFAULT NULL,
  p_phone                          IN  VARCHAR2 DEFAULT NULL,
  p_customer_num                   IN  VARCHAR2 DEFAULT NULL,
  p_ship_to_location_id            IN  NUMBER   DEFAULT NULL,
  p_bill_to_location_id            IN  NUMBER   DEFAULT NULL,
  p_ship_via_lookup_code           IN  VARCHAR2 DEFAULT NULL,
  p_freight_terms_lookup_code      IN  VARCHAR2 DEFAULT NULL,
  p_fob_lookup_code                IN  VARCHAR2 DEFAULT NULL,
  p_inactive_date                  IN  DATE     DEFAULT NULL,
  p_fax                            IN  VARCHAR2 DEFAULT NULL,
  p_fax_area_code                  IN  VARCHAR2 DEFAULT NULL,
  p_telex                          IN  VARCHAR2 DEFAULT NULL,
  p_terms_date_basis               IN  VARCHAR2 DEFAULT NULL,
  p_distribution_set_id            IN  NUMBER   DEFAULT NULL,
  p_accts_pay_code_combo_id        IN  NUMBER   DEFAULT NULL,
  p_prepay_code_combination_id     IN  NUMBER   DEFAULT NULL,
  p_pay_group_lookup_code          IN  VARCHAR2 DEFAULT NULL,
  p_payment_method_lookup_code     IN  VARCHAR2 DEFAULT NULL,
  p_payment_priority               IN  NUMBER   DEFAULT NULL,
  p_terms_id                       IN  NUMBER   DEFAULT NULL,
  p_invoice_amount_limit           IN  NUMBER   DEFAULT NULL,
  p_pay_date_basis_lookup_code     IN  VARCHAR2 DEFAULT NULL,
  p_always_take_disc_flag          IN  VARCHAR2 DEFAULT NULL,
  p_invoice_currency_code          IN  VARCHAR2 DEFAULT NULL,
  p_payment_currency_code          IN  VARCHAR2 DEFAULT NULL,
  p_vendor_site_id                 IN  NUMBER   DEFAULT NULL,
  p_last_update_date               IN  DATE     DEFAULT NULL,
  p_last_updated_by                IN  NUMBER   DEFAULT NULL,
  p_vendor_id                      IN  NUMBER   DEFAULT NULL,
  p_vendor_site_code               IN  VARCHAR2 DEFAULT NULL,
  p_vendor_site_code_alt           IN  VARCHAR2 DEFAULT NULL,
  p_purchasing_site_flag           IN  VARCHAR2 DEFAULT NULL,
  p_rfq_only_site_flag             IN  VARCHAR2 DEFAULT NULL,
  p_pay_site_flag                  IN  VARCHAR2 DEFAULT NULL,
  p_attention_ar_flag              IN  VARCHAR2 DEFAULT NULL,
  p_hold_all_payments_flag         IN  VARCHAR2 DEFAULT NULL,
  p_hold_future_payments_flag      IN  VARCHAR2 DEFAULT NULL,
  p_hold_reason                    IN  VARCHAR2 DEFAULT NULL,
  p_hold_unmatched_invoices_flag   IN  VARCHAR2 DEFAULT NULL,
  p_tax_reporting_site_flag        IN  VARCHAR2 DEFAULT NULL,
  p_attribute_category             IN  VARCHAR2 DEFAULT NULL,
  p_attribute1                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute2                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute3                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute4                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute5                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute6                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute7                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute8                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute9                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute10                    IN  VARCHAR2 DEFAULT NULL,
  p_attribute11                    IN  VARCHAR2 DEFAULT NULL,
  p_attribute12                    IN  VARCHAR2 DEFAULT NULL,
  p_attribute13                    IN  VARCHAR2 DEFAULT NULL,
  p_attribute14                    IN  VARCHAR2 DEFAULT NULL,
  p_attribute15                    IN  VARCHAR2 DEFAULT NULL,
  p_validation_number              IN  NUMBER   DEFAULT NULL,
  p_exclude_freight_from_discnt    IN  VARCHAR2 DEFAULT NULL,
  p_bank_charge_bearer             IN  VARCHAR2 DEFAULT NULL,
  p_org_id                         IN  NUMBER   DEFAULT NULL,
  p_check_digits                   IN  VARCHAR2 DEFAULT NULL,
  p_allow_awt_flag                 IN  VARCHAR2 DEFAULT NULL,
  p_awt_group_id                   IN  NUMBER   DEFAULT NULL,
  p_pay_awt_group_id                   IN  NUMBER   DEFAULT NULL,
  p_default_pay_site_id            IN  NUMBER   DEFAULT NULL,
  p_pay_on_code                    IN  VARCHAR2 DEFAULT NULL,
  p_pay_on_receipt_summary_code    IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute_category      IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute1              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute2              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute3              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute4              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute5              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute6              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute7              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute8              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute9              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute10             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute11             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute12             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute13             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute14             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute15             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute16             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute17             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute18             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute19             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute20             IN  VARCHAR2 DEFAULT NULL,
  p_tp_header_id                   IN  NUMBER   DEFAULT NULL,
  p_edi_id_number                  IN  VARCHAR2 DEFAULT NULL,
  p_ece_tp_location_code           IN  VARCHAR2 DEFAULT NULL,
  p_pcard_site_flag                IN  VARCHAR2 DEFAULT NULL,
  p_match_option                   IN  VARCHAR2 DEFAULT NULL,
  p_country_of_origin_code         IN  VARCHAR2 DEFAULT NULL,
  p_future_dated_payment_ccid      IN  NUMBER   DEFAULT NULL,
  p_create_debit_memo_flag         IN  VARCHAR2 DEFAULT NULL,
  p_supplier_notif_method          IN  VARCHAR2 DEFAULT NULL,
  p_email_address                  IN  VARCHAR2 DEFAULT NULL,
  p_primary_pay_site_flag          IN  VARCHAR2 DEFAULT NULL,
  p_shipping_control               IN  VARCHAR2 DEFAULT NULL,
  p_selling_company_identifier     IN  VARCHAR2 DEFAULT NULL,
  p_gapless_inv_num_flag           IN  VARCHAR2 DEFAULT NULL,
  p_location_id                    IN  NUMBER   DEFAULT NULL,
  p_party_site_id                  IN  NUMBER   DEFAULT NULL,
  p_org_name                       IN  VARCHAR2 DEFAULT NULL,
  p_duns_number                    IN  VARCHAR2 DEFAULT NULL,
  p_address_style                  IN  VARCHAR2 DEFAULT NULL,
  p_language                       IN  VARCHAR2 DEFAULT NULL,
  p_province                       IN  VARCHAR2 DEFAULT NULL,
  p_country                        IN  VARCHAR2 DEFAULT NULL,
  p_address_line1                  IN  VARCHAR2             ,
  p_address_line2                  IN  VARCHAR2 DEFAULT NULL,
  p_address_line3                  IN  VARCHAR2 DEFAULT NULL,
  p_address_line4                  IN  VARCHAR2 DEFAULT NULL,
  p_address_lines_alt              IN  VARCHAR2 DEFAULT NULL,
  p_county                         IN  VARCHAR2 DEFAULT NULL,
  p_city                           IN  VARCHAR2 DEFAULT NULL,
  p_state                          IN  VARCHAR2 DEFAULT NULL,
  p_zip                            IN  VARCHAR2 DEFAULT NULL,
  p_terms_name                     IN  VARCHAR2 DEFAULT NULL,
  p_default_terms_id               IN  NUMBER   DEFAULT NULL,
  p_awt_group_name                 IN  VARCHAR2 DEFAULT NULL,
  p_pay_awt_group_name                 IN  VARCHAR2 DEFAULT NULL,
  p_distribution_set_name          IN  VARCHAR2 DEFAULT NULL,
  p_ship_to_location_code          IN  VARCHAR2 DEFAULT NULL,
  p_bill_to_location_code          IN  VARCHAR2 DEFAULT NULL,
  p_default_dist_set_id            IN  NUMBER   DEFAULT NULL,
  p_default_ship_to_loc_id         IN  NUMBER   DEFAULT NULL,
  p_default_bill_to_loc_id         IN  NUMBER   DEFAULT NULL,
  p_tolerance_id                   IN  NUMBER   DEFAULT NULL,
  p_tolerance_name                 IN  VARCHAR2 DEFAULT NULL,
  p_retainage_rate                 IN  NUMBER   DEFAULT NULL,
  p_service_tolerance_id           IN  NUMBER   DEFAULT NULL,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_error_msg       OUT NOCOPY VARCHAR2,
  x_vendor_site_id  OUT NOCOPY NUMBER,
  x_party_site_id   OUT NOCOPY NUMBER,
  x_location_id     OUT NOCOPY NUMBER
)
  IS
   l_vendor_site_rec ap_vendor_pub_pkg.r_vendor_site_rec_type;
   l_msg_count  NUMBER;
   l_msg_data   VARCHAR2(4000);
   l_addr_pay_flag VARCHAR2(1);
   l_addr_pur_flag VARCHAR2(1);
   l_addr_rfq_flag VARCHAR2(1);
BEGIN



   l_vendor_site_rec.area_code                     := p_area_code;
   l_vendor_site_rec.phone                         := p_phone;
   l_vendor_site_rec.customer_num                  := p_customer_num;
   l_vendor_site_rec.ship_to_location_id           := p_ship_to_location_id;
   l_vendor_site_rec.bill_to_location_id           := p_bill_to_location_id;
   l_vendor_site_rec.ship_via_lookup_code          := p_ship_via_lookup_code;
   l_vendor_site_rec.freight_terms_lookup_code     := p_freight_terms_lookup_code;
   l_vendor_site_rec.fob_lookup_code               := p_fob_lookup_code;
   l_vendor_site_rec.inactive_date                 := p_inactive_date;
   l_vendor_site_rec.fax                           := p_fax;
   l_vendor_site_rec.fax_area_code                 := p_fax_area_code;
   l_vendor_site_rec.telex                         := p_telex;
   l_vendor_site_rec.terms_date_basis              := p_terms_date_basis;
   l_vendor_site_rec.distribution_set_id           := p_distribution_set_id;
   l_vendor_site_rec.accts_pay_code_combination_id := p_accts_pay_code_combo_id;
   l_vendor_site_rec.prepay_code_combination_id    := p_prepay_code_combination_id;
   l_vendor_site_rec.pay_group_lookup_code         := p_pay_group_lookup_code;
   l_vendor_site_rec.ext_payee_rec.default_pmt_method:= p_payment_method_lookup_code;
   l_vendor_site_rec.payment_priority              := p_payment_priority;
   l_vendor_site_rec.terms_id                      := p_terms_id;
   l_vendor_site_rec.invoice_amount_limit          := p_invoice_amount_limit;
   l_vendor_site_rec.pay_date_basis_lookup_code    := p_pay_date_basis_lookup_code;
   l_vendor_site_rec.always_take_disc_flag         := p_always_take_disc_flag;
   l_vendor_site_rec.invoice_currency_code         := p_invoice_currency_code;
   l_vendor_site_rec.payment_currency_code         := p_payment_currency_code;
   l_vendor_site_rec.vendor_site_id                := p_vendor_site_id;
   l_vendor_site_rec.last_update_date              := p_last_update_date;
   l_vendor_site_rec.last_updated_by               := p_last_updated_by;
   l_vendor_site_rec.vendor_id                     := p_vendor_id;
   l_vendor_site_rec.vendor_site_code              := p_vendor_site_code;
   l_vendor_site_rec.vendor_site_code_alt          := p_vendor_site_code_alt;

   l_vendor_site_rec.purchasing_site_flag          := p_purchasing_site_flag;
   l_vendor_site_rec.rfq_only_site_flag            := p_rfq_only_site_flag ;
   l_vendor_site_rec.pay_site_flag                 := p_pay_site_flag ;
   l_vendor_site_rec.attention_ar_flag             := p_attention_ar_flag;
   l_vendor_site_rec.hold_all_payments_flag        := p_hold_all_payments_flag;
   l_vendor_site_rec.hold_future_payments_flag     := p_hold_future_payments_flag;
   l_vendor_site_rec.hold_reason                   := p_hold_reason;
   l_vendor_site_rec.hold_unmatched_invoices_flag  := p_hold_unmatched_invoices_flag;
   l_vendor_site_rec.tax_reporting_site_flag       := p_tax_reporting_site_flag;
   l_vendor_site_rec.attribute_category            := p_attribute_category;
   l_vendor_site_rec.attribute1                    := p_attribute1;
   l_vendor_site_rec.attribute2                    := p_attribute2;
   l_vendor_site_rec.attribute3                    := p_attribute3;
   l_vendor_site_rec.attribute4                    := p_attribute4;
   l_vendor_site_rec.attribute5                    := p_attribute5;
   l_vendor_site_rec.attribute6                    := p_attribute6;
   l_vendor_site_rec.attribute7                    := p_attribute7;
   l_vendor_site_rec.attribute8                    := p_attribute8;
   l_vendor_site_rec.attribute9                    := p_attribute9;
   l_vendor_site_rec.attribute10                   := p_attribute10;
   l_vendor_site_rec.attribute11                   := p_attribute11;
   l_vendor_site_rec.attribute12                   := p_attribute12;
   l_vendor_site_rec.attribute13                   := p_attribute13;
   l_vendor_site_rec.attribute14                   := p_attribute14;
   l_vendor_site_rec.attribute15                   := p_attribute15;
   l_vendor_site_rec.validation_number             := p_validation_number;
   l_vendor_site_rec.exclude_freight_from_discount := p_exclude_freight_from_discnt;
   l_vendor_site_rec.bank_charge_bearer            := p_bank_charge_bearer;
   l_vendor_site_rec.org_id                        := p_org_id;
   l_vendor_site_rec.check_digits                  := p_check_digits;
   l_vendor_site_rec.allow_awt_flag                := p_allow_awt_flag;
   l_vendor_site_rec.awt_group_id                  := p_awt_group_id;
   l_vendor_site_rec.pay_awt_group_id                  := p_pay_awt_group_id;
   l_vendor_site_rec.default_pay_site_id           := p_default_pay_site_id;
   l_vendor_site_rec.pay_on_code                   := p_pay_on_code;
   l_vendor_site_rec.pay_on_receipt_summary_code   := p_pay_on_receipt_summary_code;
   l_vendor_site_rec.global_attribute_category     := p_global_attribute_category;
   l_vendor_site_rec.global_attribute1             := p_global_attribute1;
   l_vendor_site_rec.global_attribute2             := p_global_attribute2;
   l_vendor_site_rec.global_attribute3             := p_global_attribute3;
   l_vendor_site_rec.global_attribute4             := p_global_attribute4;
   l_vendor_site_rec.global_attribute5             := p_global_attribute5;
   l_vendor_site_rec.global_attribute6             := p_global_attribute6;
   l_vendor_site_rec.global_attribute7             := p_global_attribute7;
   l_vendor_site_rec.global_attribute8             := p_global_attribute8;
   l_vendor_site_rec.global_attribute9             := p_global_attribute9;
   l_vendor_site_rec.global_attribute10            := p_global_attribute10;
   l_vendor_site_rec.global_attribute11            := p_global_attribute11;
   l_vendor_site_rec.global_attribute12            := p_global_attribute12;
   l_vendor_site_rec.global_attribute13            := p_global_attribute13;
   l_vendor_site_rec.global_attribute14            := p_global_attribute14;
   l_vendor_site_rec.global_attribute15            := p_global_attribute15;
   l_vendor_site_rec.global_attribute16            := p_global_attribute16;
   l_vendor_site_rec.global_attribute17            := p_global_attribute17;
   l_vendor_site_rec.global_attribute18            := p_global_attribute18;
   l_vendor_site_rec.global_attribute19            := p_global_attribute19;
   l_vendor_site_rec.global_attribute20            := p_global_attribute20;
   l_vendor_site_rec.tp_header_id                  := p_tp_header_id;
   l_vendor_site_rec.edi_id_number                 := p_edi_id_number;
   l_vendor_site_rec.ece_tp_location_code          := p_ece_tp_location_code;
   l_vendor_site_rec.pcard_site_flag               := p_pcard_site_flag;
   l_vendor_site_rec.match_option                  := p_match_option;
   l_vendor_site_rec.country_of_origin_code        := p_country_of_origin_code;
   l_vendor_site_rec.future_dated_payment_ccid     := p_future_dated_payment_ccid;
   l_vendor_site_rec.create_debit_memo_flag        := p_create_debit_memo_flag;
   l_vendor_site_rec.supplier_notif_method         := p_supplier_notif_method;
   l_vendor_site_rec.email_address                 := p_email_address;
   l_vendor_site_rec.primary_pay_site_flag         := p_primary_pay_site_flag;
   l_vendor_site_rec.shipping_control              := p_shipping_control;
   l_vendor_site_rec.selling_company_identifier    := p_selling_company_identifier;
   l_vendor_site_rec.gapless_inv_num_flag          := p_gapless_inv_num_flag;
   l_vendor_site_rec.location_id                   := p_location_id;
   l_vendor_site_rec.party_site_id                 := p_party_site_id;
   l_vendor_site_rec.org_name                      := p_org_name;
   l_vendor_site_rec.duns_number                   := p_duns_number;
   l_vendor_site_rec.address_style                 := p_address_style;
   l_vendor_site_rec.language                      := get_nls_language(p_language);
   l_vendor_site_rec.province                      := p_province;
   l_vendor_site_rec.country                       := p_country;
   l_vendor_site_rec.address_line1                 := p_address_line1;
   l_vendor_site_rec.address_line2                 := p_address_line2;
   l_vendor_site_rec.address_line3                 := p_address_line3;
   l_vendor_site_rec.address_line4                 := p_address_line4;
   l_vendor_site_rec.address_lines_alt             := p_address_lines_alt;
   l_vendor_site_rec.county                        := p_county;
   l_vendor_site_rec.city                          := p_city;
   l_vendor_site_rec.state                         := p_state;
   l_vendor_site_rec.zip                           := p_zip;
   l_vendor_site_rec.terms_name                    := p_terms_name;
   l_vendor_site_rec.default_terms_id              := p_default_terms_id;
   l_vendor_site_rec.awt_group_name                := p_awt_group_name;
   l_vendor_site_rec.pay_awt_group_name                := p_pay_awt_group_name;
   l_vendor_site_rec.distribution_set_name         := p_distribution_set_name;
   l_vendor_site_rec.ship_to_location_code         := p_ship_to_location_code;
   l_vendor_site_rec.bill_to_location_code         := p_bill_to_location_code;
   l_vendor_site_rec.default_dist_set_id           := p_default_dist_set_id;
   l_vendor_site_rec.default_ship_to_loc_id        := p_default_ship_to_loc_id;
   l_vendor_site_rec.default_bill_to_loc_id        := p_default_bill_to_loc_id;
   l_vendor_site_rec.tolerance_id                  := p_tolerance_id;
   l_vendor_site_rec.tolerance_name                := p_tolerance_name;
   l_vendor_site_rec.retainage_rate                := p_retainage_rate;
   l_vendor_site_rec.services_tolerance_id          := p_service_tolerance_id;
   -- If primary pay flag is selected, pay flag should also be selected
   if (l_vendor_site_rec.primary_pay_site_flag is not null
        and l_vendor_site_rec.primary_pay_site_flag = 'Y' ) then
        l_vendor_site_rec.pay_site_flag := 'Y';
   end if;

   Create_Vendor_Site
     (
      p_vendor_site_rec => l_vendor_site_rec,
      x_return_status   => x_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data,
      x_vendor_site_id  => x_vendor_site_id,
      x_party_site_id   => x_party_site_id,
      x_location_id     => x_location_id
      );

   combine_err_msg(x_return_status, l_msg_count, l_msg_data, x_error_msg);

END Create_Vendor_Site;

--  Notes: This API will not update any TCA records.
--         It will only update vendor site info.
--         This is because the procedure calls the corresponding procedure in
--         AP_VENDOR_PUB_PKG which does not update TCA tables.
--
PROCEDURE Update_Vendor_Site
(
  p_area_code                      IN  VARCHAR2 ,
  p_phone                          IN  VARCHAR2 ,
  p_customer_num                   IN  VARCHAR2 ,
  p_ship_to_location_id            IN  NUMBER   ,
  p_bill_to_location_id            IN  NUMBER   ,
  p_ship_via_lookup_code           IN  VARCHAR2 ,
  p_freight_terms_lookup_code      IN  VARCHAR2 ,
  p_fob_lookup_code                IN  VARCHAR2 ,
  p_inactive_date                  IN  DATE     ,
  p_fax                            IN  VARCHAR2 ,
  p_fax_area_code                  IN  VARCHAR2 ,
  p_telex                          IN  VARCHAR2 ,
  p_terms_date_basis               IN  VARCHAR2 ,
  p_distribution_set_id            IN  NUMBER   ,
  p_accts_pay_code_combo_id        IN  NUMBER   ,
  p_prepay_code_combination_id     IN  NUMBER   ,
  p_pay_group_lookup_code          IN  VARCHAR2 ,
  p_payment_priority               IN  NUMBER   ,
  p_terms_id                       IN  NUMBER   ,
  p_invoice_amount_limit           IN  NUMBER   ,
  p_pay_date_basis_lookup_code     IN  VARCHAR2 ,
  p_always_take_disc_flag          IN  VARCHAR2 ,
  p_invoice_currency_code          IN  VARCHAR2 ,
  p_payment_currency_code          IN  VARCHAR2 ,
  p_vendor_site_id                 IN  NUMBER   ,
  p_last_update_date               IN  DATE     ,
  p_last_updated_by                IN  NUMBER   ,
  p_vendor_id                      IN  NUMBER   ,
  p_vendor_site_code               IN  VARCHAR2 ,
  p_vendor_site_code_alt           IN  VARCHAR2 ,
  p_purchasing_site_flag           IN  VARCHAR2 ,
  p_rfq_only_site_flag             IN  VARCHAR2 ,
  p_pay_site_flag                  IN  VARCHAR2 ,
  p_attention_ar_flag              IN  VARCHAR2 ,
  p_hold_all_payments_flag         IN  VARCHAR2 ,
  p_hold_future_payments_flag      IN  VARCHAR2 ,
  p_hold_reason                    IN  VARCHAR2 ,
  p_hold_unmatched_invoices_flag   IN  VARCHAR2 ,
  p_tax_reporting_site_flag        IN  VARCHAR2 ,
  p_attribute_category             IN  VARCHAR2 ,
  p_attribute1                     IN  VARCHAR2 ,
  p_attribute2                     IN  VARCHAR2 ,
  p_attribute3                     IN  VARCHAR2 ,
  p_attribute4                     IN  VARCHAR2 ,
  p_attribute5                     IN  VARCHAR2 ,
  p_attribute6                     IN  VARCHAR2 ,
  p_attribute7                     IN  VARCHAR2 ,
  p_attribute8                     IN  VARCHAR2 ,
  p_attribute9                     IN  VARCHAR2 ,
  p_attribute10                    IN  VARCHAR2 ,
  p_attribute11                    IN  VARCHAR2 ,
  p_attribute12                    IN  VARCHAR2 ,
  p_attribute13                    IN  VARCHAR2 ,
  p_attribute14                    IN  VARCHAR2 ,
  p_attribute15                    IN  VARCHAR2 ,
  p_validation_number              IN  NUMBER   ,
  p_exclude_freight_from_discnt    IN  VARCHAR2 ,
  p_bank_charge_bearer             IN  VARCHAR2 ,
  p_org_id                         IN  NUMBER   ,
  p_check_digits                   IN  VARCHAR2 ,
  p_allow_awt_flag                 IN  VARCHAR2 ,
  p_awt_group_id                   IN  NUMBER   ,
  p_pay_awt_group_id                   IN  NUMBER   ,
  p_default_pay_site_id            IN  NUMBER   ,
  p_pay_on_code                    IN  VARCHAR2 ,
  p_pay_on_receipt_summary_code    IN  VARCHAR2 ,
  p_global_attribute_category      IN  VARCHAR2 ,
  p_global_attribute1              IN  VARCHAR2 ,
  p_global_attribute2              IN  VARCHAR2 ,
  p_global_attribute3              IN  VARCHAR2 ,
  p_global_attribute4              IN  VARCHAR2 ,
  p_global_attribute5              IN  VARCHAR2 ,
  p_global_attribute6              IN  VARCHAR2 ,
  p_global_attribute7              IN  VARCHAR2 ,
  p_global_attribute8              IN  VARCHAR2 ,
  p_global_attribute9              IN  VARCHAR2 ,
  p_global_attribute10             IN  VARCHAR2 ,
  p_global_attribute11             IN  VARCHAR2 ,
  p_global_attribute12             IN  VARCHAR2 ,
  p_global_attribute13             IN  VARCHAR2 ,
  p_global_attribute14             IN  VARCHAR2 ,
  p_global_attribute15             IN  VARCHAR2 ,
  p_global_attribute16             IN  VARCHAR2 ,
  p_global_attribute17             IN  VARCHAR2 ,
  p_global_attribute18             IN  VARCHAR2 ,
  p_global_attribute19             IN  VARCHAR2 ,
  p_global_attribute20             IN  VARCHAR2 ,
  p_tp_header_id                   IN  NUMBER   ,
  p_edi_id_number                  IN  VARCHAR2 ,
  p_ece_tp_location_code           IN  VARCHAR2 ,
  p_pcard_site_flag                IN  VARCHAR2 ,
  p_match_option                   IN  VARCHAR2 ,
  p_country_of_origin_code         IN  VARCHAR2 ,
  p_future_dated_payment_ccid      IN  NUMBER   ,
  p_create_debit_memo_flag         IN  VARCHAR2 ,
  p_supplier_notif_method          IN  VARCHAR2 ,
  p_email_address                  IN  VARCHAR2 ,
  p_primary_pay_site_flag          IN  VARCHAR2 ,
  p_shipping_control               IN  VARCHAR2 ,
  p_selling_company_identifier     IN  VARCHAR2 ,
  p_gapless_inv_num_flag           IN  VARCHAR2 ,
  p_location_id                    IN  NUMBER   ,
  p_party_site_id                  IN  NUMBER   ,
  p_org_name                       IN  VARCHAR2 ,
  p_duns_number                    IN  VARCHAR2 ,
  p_address_style                  IN  VARCHAR2 ,
  p_language                       IN  VARCHAR2 ,
  p_province                       IN  VARCHAR2 ,
  p_country                        IN  VARCHAR2 ,
  p_address_line1                  IN  VARCHAR2 ,
  p_address_line2                  IN  VARCHAR2 ,
  p_address_line3                  IN  VARCHAR2 ,
  p_address_line4                  IN  VARCHAR2 ,
  p_address_lines_alt              IN  VARCHAR2 ,
  p_county                         IN  VARCHAR2 ,
  p_city                           IN  VARCHAR2 ,
  p_state                          IN  VARCHAR2 ,
  p_zip                            IN  VARCHAR2 ,
  p_terms_name                     IN  VARCHAR2 ,
  p_default_terms_id               IN  NUMBER   ,
  p_awt_group_name                 IN  VARCHAR2 ,
  p_pay_awt_group_name                 IN  VARCHAR2 ,
  p_distribution_set_name          IN  VARCHAR2 ,
  p_ship_to_location_code          IN  VARCHAR2 ,
  p_bill_to_location_code          IN  VARCHAR2 ,
  p_default_dist_set_id            IN  NUMBER   ,
  p_default_ship_to_loc_id         IN  NUMBER   ,
  p_default_bill_to_loc_id         IN  NUMBER   ,
  p_tolerance_id                   IN  NUMBER   ,
  p_tolerance_name                 IN  VARCHAR2 ,
  p_retainage_rate                 IN  NUMBER   ,
  p_service_tolerance_id           IN  NUMBER   ,
  p_ship_network_loc_id            IN  NUMBER   ,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_error_msg       OUT NOCOPY VARCHAR2
  )
IS
   l_vendor_site_rec ap_vendor_pub_pkg.r_vendor_site_rec_type;
   l_msg_count  NUMBER;
   l_msg_data   VARCHAR2(4000);
   l_last_update_date DATE;
   is_site_ccr VARCHAR2(1);
BEGIN

-- Start Bug 6620664 - Handling Concurrent updates on Suppliers>>Accounting page
   IF p_last_update_date IS NOT NULL then
      SELECT last_update_date INTO l_last_update_date
        FROM ap_supplier_sites_all
       WHERE vendor_site_id = p_vendor_site_id
         AND vendor_id = p_vendor_id;
      IF l_last_update_date > p_last_update_date then
        x_error_msg := fnd_message.get_string('POS','POS_LOCK_SITE_ROW');
        x_return_status := 'E';
        RETURN;
      END IF;
   END IF;
-- End Bug 6620664 - Handling Concurrent updates on Suppliers>>Accounting page

   l_vendor_site_rec.area_code                     := Nvl(p_area_code, fnd_api.g_null_char);
   l_vendor_site_rec.phone                         := Nvl(p_phone, fnd_api.g_null_char);
   l_vendor_site_rec.customer_num                  := Nvl(p_customer_num, fnd_api.g_null_char);
   l_vendor_site_rec.ship_to_location_id           := Nvl(p_ship_to_location_id, fnd_api.g_null_num);
   l_vendor_site_rec.bill_to_location_id           := Nvl(p_bill_to_location_id, fnd_api.g_null_num);
   l_vendor_site_rec.ship_via_lookup_code          := Nvl(p_ship_via_lookup_code, fnd_api.g_null_char);
   l_vendor_site_rec.freight_terms_lookup_code     := Nvl(p_freight_terms_lookup_code, fnd_api.g_null_char);
   l_vendor_site_rec.fob_lookup_code               := Nvl(p_fob_lookup_code, fnd_api.g_null_char);
   l_vendor_site_rec.inactive_date                 := Nvl(p_inactive_date, fnd_api.g_null_date);
   l_vendor_site_rec.fax                           := Nvl(p_fax, fnd_api.g_null_char);
   l_vendor_site_rec.fax_area_code                 := Nvl(p_fax_area_code, fnd_api.g_null_char);
   l_vendor_site_rec.telex                         := Nvl(p_telex, fnd_api.g_null_char);
   l_vendor_site_rec.terms_date_basis              := Nvl(p_terms_date_basis, fnd_api.g_null_char);
   l_vendor_site_rec.distribution_set_id           := Nvl(p_distribution_set_id, fnd_api.g_null_num);
   l_vendor_site_rec.accts_pay_code_combination_id := Nvl(p_accts_pay_code_combo_id, fnd_api.g_null_num);
   l_vendor_site_rec.prepay_code_combination_id    := Nvl(p_prepay_code_combination_id, fnd_api.g_null_num);
   l_vendor_site_rec.pay_group_lookup_code         := Nvl(p_pay_group_lookup_code, fnd_api.g_null_char);
   l_vendor_site_rec.payment_priority              := Nvl(p_payment_priority, fnd_api.g_null_num);
   l_vendor_site_rec.terms_id                      := Nvl(p_terms_id, fnd_api.g_null_num);
   l_vendor_site_rec.invoice_amount_limit          := Nvl(p_invoice_amount_limit, fnd_api.g_null_num);
   l_vendor_site_rec.pay_date_basis_lookup_code    := Nvl(p_pay_date_basis_lookup_code, fnd_api.g_null_char);
   l_vendor_site_rec.always_take_disc_flag         := Nvl(p_always_take_disc_flag, fnd_api.g_null_char);
   l_vendor_site_rec.invoice_currency_code         := Nvl(p_invoice_currency_code, fnd_api.g_null_char);
   l_vendor_site_rec.payment_currency_code         := Nvl(p_payment_currency_code, fnd_api.g_null_char);
   l_vendor_site_rec.vendor_site_id                := p_vendor_site_id;
   l_vendor_site_rec.last_update_date              := Nvl(p_last_update_date, fnd_api.g_null_date);
   l_vendor_site_rec.last_updated_by               := Nvl(p_last_updated_by, fnd_api.g_null_num);
   l_vendor_site_rec.vendor_id                     := Nvl(p_vendor_id, fnd_api.g_null_num);
   l_vendor_site_rec.vendor_site_code              := p_vendor_site_code;
   l_vendor_site_rec.vendor_site_code_alt          := Nvl(p_vendor_site_code_alt, fnd_api.g_null_char);
   l_vendor_site_rec.purchasing_site_flag          := Nvl(p_purchasing_site_flag, fnd_api.g_null_char);
   l_vendor_site_rec.rfq_only_site_flag            := Nvl(p_rfq_only_site_flag, fnd_api.g_null_char);
   l_vendor_site_rec.pay_site_flag                 := Nvl(p_pay_site_flag, fnd_api.g_null_char);
   l_vendor_site_rec.attention_ar_flag             := Nvl(p_attention_ar_flag, fnd_api.g_null_char);
   l_vendor_site_rec.hold_all_payments_flag        := Nvl(p_hold_all_payments_flag, fnd_api.g_null_char);
   l_vendor_site_rec.hold_future_payments_flag     := Nvl(p_hold_future_payments_flag, fnd_api.g_null_char);
   l_vendor_site_rec.hold_reason                   := Nvl(p_hold_reason, fnd_api.g_null_char);
   l_vendor_site_rec.hold_unmatched_invoices_flag  := Nvl(p_hold_unmatched_invoices_flag, fnd_api.g_null_char);
   l_vendor_site_rec.tax_reporting_site_flag       := Nvl(p_tax_reporting_site_flag, fnd_api.g_null_char);
   l_vendor_site_rec.attribute_category            := Nvl(p_attribute_category, fnd_api.g_null_char);
   l_vendor_site_rec.attribute1                    := Nvl(p_attribute1, fnd_api.g_null_char);
   l_vendor_site_rec.attribute2                    := Nvl(p_attribute2, fnd_api.g_null_char);
   l_vendor_site_rec.attribute3                    := Nvl(p_attribute3, fnd_api.g_null_char);
   l_vendor_site_rec.attribute4                    := Nvl(p_attribute4, fnd_api.g_null_char);
   l_vendor_site_rec.attribute5                    := Nvl(p_attribute5, fnd_api.g_null_char);
   l_vendor_site_rec.attribute6                    := Nvl(p_attribute6, fnd_api.g_null_char);
   l_vendor_site_rec.attribute7                    := Nvl(p_attribute7, fnd_api.g_null_char);
   l_vendor_site_rec.attribute8                    := Nvl(p_attribute8, fnd_api.g_null_char);
   l_vendor_site_rec.attribute9                    := Nvl(p_attribute9, fnd_api.g_null_char);
   l_vendor_site_rec.attribute10                   := Nvl(p_attribute10, fnd_api.g_null_char);
   l_vendor_site_rec.attribute11                   := Nvl(p_attribute11, fnd_api.g_null_char);
   l_vendor_site_rec.attribute12                   := Nvl(p_attribute12, fnd_api.g_null_char);
   l_vendor_site_rec.attribute13                   := Nvl(p_attribute13, fnd_api.g_null_char);
   l_vendor_site_rec.attribute14                   := Nvl(p_attribute14, fnd_api.g_null_char);
   l_vendor_site_rec.attribute15                   := Nvl(p_attribute15, fnd_api.g_null_char);
   l_vendor_site_rec.validation_number             := Nvl(p_validation_number, fnd_api.g_null_num);
   l_vendor_site_rec.exclude_freight_from_discount := Nvl(p_exclude_freight_from_discnt, fnd_api.g_null_char);
   l_vendor_site_rec.bank_charge_bearer            := Nvl(p_bank_charge_bearer, fnd_api.g_null_char);
   l_vendor_site_rec.org_id                        := Nvl(p_org_id, fnd_api.g_null_num);
   l_vendor_site_rec.check_digits                  := Nvl(p_check_digits, fnd_api.g_null_char);
   l_vendor_site_rec.allow_awt_flag                := Nvl(p_allow_awt_flag, fnd_api.g_null_char);
   l_vendor_site_rec.awt_group_id                  := Nvl(p_awt_group_id, fnd_api.g_null_num);
    l_vendor_site_rec.pay_awt_group_id                  := Nvl(p_pay_awt_group_id, fnd_api.g_null_num);
   l_vendor_site_rec.default_pay_site_id           := Nvl(p_default_pay_site_id, fnd_api.g_null_num);
   l_vendor_site_rec.pay_on_code                   := Nvl(p_pay_on_code, fnd_api.g_null_char);
   l_vendor_site_rec.pay_on_receipt_summary_code   := Nvl(p_pay_on_receipt_summary_code, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute_category     := Nvl(p_global_attribute_category, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute1             := Nvl(p_global_attribute1, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute2             := Nvl(p_global_attribute2, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute3             := Nvl(p_global_attribute3, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute4             := Nvl(p_global_attribute4, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute5             := Nvl(p_global_attribute5, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute6             := Nvl(p_global_attribute6, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute7             := Nvl(p_global_attribute7, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute8             := Nvl(p_global_attribute8, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute9             := Nvl(p_global_attribute9, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute10            := Nvl(p_global_attribute10, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute11            := Nvl(p_global_attribute11, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute12            := Nvl(p_global_attribute12, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute13            := Nvl(p_global_attribute13, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute14            := Nvl(p_global_attribute14, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute15            := Nvl(p_global_attribute15, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute16            := Nvl(p_global_attribute16, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute17            := Nvl(p_global_attribute17, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute18            := Nvl(p_global_attribute18, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute19            := Nvl(p_global_attribute19, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute20            := Nvl(p_global_attribute20, fnd_api.g_null_char);
   l_vendor_site_rec.tp_header_id                  := Nvl(p_tp_header_id, fnd_api.g_null_num);
   l_vendor_site_rec.edi_id_number                 := Nvl(p_edi_id_number, fnd_api.g_null_char);
   l_vendor_site_rec.ece_tp_location_code          := Nvl(p_ece_tp_location_code, fnd_api.g_null_char);
   l_vendor_site_rec.pcard_site_flag               := Nvl(p_pcard_site_flag, fnd_api.g_null_char);
   l_vendor_site_rec.match_option                  := Nvl(p_match_option, fnd_api.g_null_char);
   l_vendor_site_rec.country_of_origin_code        := Nvl(p_country_of_origin_code, fnd_api.g_null_char);
   l_vendor_site_rec.future_dated_payment_ccid     := Nvl(p_future_dated_payment_ccid, fnd_api.g_null_num);
   l_vendor_site_rec.create_debit_memo_flag        := Nvl(p_create_debit_memo_flag, fnd_api.g_null_char);
   l_vendor_site_rec.supplier_notif_method         := Nvl(p_supplier_notif_method, fnd_api.g_null_char);
   l_vendor_site_rec.email_address                 := Nvl(p_email_address, fnd_api.g_null_char);
   l_vendor_site_rec.primary_pay_site_flag         := Nvl(p_primary_pay_site_flag, fnd_api.g_null_char);
   l_vendor_site_rec.shipping_control              := Nvl(p_shipping_control, fnd_api.g_null_char);
   l_vendor_site_rec.selling_company_identifier    := Nvl(p_selling_company_identifier, fnd_api.g_null_char);
   l_vendor_site_rec.gapless_inv_num_flag          := Nvl(p_gapless_inv_num_flag, fnd_api.g_null_char);
   l_vendor_site_rec.location_id                   := Nvl(p_location_id, fnd_api.g_null_num);
   l_vendor_site_rec.party_site_id                 := Nvl(p_party_site_id, fnd_api.g_null_num);
   l_vendor_site_rec.org_name                      := p_org_name;
   l_vendor_site_rec.duns_number                   := Nvl(p_duns_number, fnd_api.g_null_char);
   l_vendor_site_rec.address_style                 := Nvl(p_address_style, fnd_api.g_null_char);
   l_vendor_site_rec.language                      := Nvl(get_nls_language(p_language), fnd_api.g_null_char);
   l_vendor_site_rec.province                      := Nvl(p_province, fnd_api.g_null_char);
   l_vendor_site_rec.country                       := Nvl(p_country, fnd_api.g_null_char);
   l_vendor_site_rec.address_line1                 := Nvl(p_address_line1, fnd_api.g_null_char);
   l_vendor_site_rec.address_line2                 := Nvl(p_address_line2, fnd_api.g_null_char);
   l_vendor_site_rec.address_line3                 := Nvl(p_address_line3, fnd_api.g_null_char);
   l_vendor_site_rec.address_line4                 := Nvl(p_address_line4, fnd_api.g_null_char);
   l_vendor_site_rec.address_lines_alt             := Nvl(p_address_lines_alt, fnd_api.g_null_char);
   l_vendor_site_rec.county                        := Nvl(p_county, fnd_api.g_null_char);
   l_vendor_site_rec.city                          := Nvl(p_city, fnd_api.g_null_char);
   l_vendor_site_rec.state                         := Nvl(p_state, fnd_api.g_null_char);
   l_vendor_site_rec.zip                           := Nvl(p_zip, fnd_api.g_null_char);
   l_vendor_site_rec.terms_name                    := p_terms_name;
   l_vendor_site_rec.default_terms_id              := Nvl(p_default_terms_id, fnd_api.g_null_num);
   l_vendor_site_rec.awt_group_name                := p_awt_group_name;
   l_vendor_site_rec.pay_awt_group_name                := p_pay_awt_group_name;
   l_vendor_site_rec.distribution_set_name         := p_distribution_set_name;
   l_vendor_site_rec.ship_to_location_code         := Nvl(p_ship_to_location_code, fnd_api.g_null_char);
   l_vendor_site_rec.bill_to_location_code         := Nvl(p_bill_to_location_code, fnd_api.g_null_char);
   l_vendor_site_rec.default_dist_set_id           := Nvl(p_default_dist_set_id, fnd_api.g_null_num);
   l_vendor_site_rec.default_ship_to_loc_id        := Nvl(p_default_ship_to_loc_id, fnd_api.g_null_num);
   l_vendor_site_rec.default_bill_to_loc_id        := Nvl(p_default_bill_to_loc_id, fnd_api.g_null_num);
   l_vendor_site_rec.tolerance_id                  := Nvl(p_tolerance_id, fnd_api.g_null_num);
   l_vendor_site_rec.tolerance_name                := p_tolerance_name;
   l_vendor_site_rec.retainage_rate                := Nvl(p_retainage_rate, fnd_api.g_null_num);
   l_vendor_site_rec.services_tolerance_id         := Nvl(p_service_tolerance_id, fnd_api.g_null_num);
   l_vendor_site_rec.shipping_location_id          := Nvl(p_ship_network_loc_id, fnd_api.g_null_num);


   -- If primary pay flag is selected, pay flag should also be selected
   if (l_vendor_site_rec.primary_pay_site_flag is not null
        and l_vendor_site_rec.primary_pay_site_flag = 'Y' ) then
        l_vendor_site_rec.pay_site_flag := 'Y';
   end if;

   -- ccr code starts
   is_site_ccr := POS_UTIL_PKG.IS_SITE_CCR(1.0,null,l_vendor_site_rec.vendor_site_id);
   if is_site_ccr = 'T' then
      l_vendor_site_rec.duns_number := null;
      l_vendor_site_rec.country := null;
      l_vendor_site_rec.address_line1 := null;
      l_vendor_site_rec.address_line2 := null;
      l_vendor_site_rec.address_line3 := null;
      l_vendor_site_rec.address_line4 := null;
      l_vendor_site_rec.city := null;
      l_vendor_site_rec.state := null;
      l_vendor_site_rec.zip := null;
      l_vendor_site_rec.province := null;
   end if;
   -- ccr code ends

   Update_Vendor_Site
     (
      p_vendor_site_rec => l_vendor_site_rec,
      x_return_status   => x_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data
      );

   combine_err_msg(x_return_status, l_msg_count, l_msg_data, x_error_msg);

END Update_Vendor_Site;

-- Notes:
--   p_mode: Indicates whether the calling code is in insert or update mode.
--           (I, U)
--
--   x_party_site_valid: Indicates how valid the calling program's party_site_id was
--                   (V, N, F) Valid, Null or False

PROCEDURE Validate_Vendor_Site
(
  p_area_code                      IN  VARCHAR2 ,
  p_phone                          IN  VARCHAR2 ,
  p_customer_num                   IN  VARCHAR2 ,
  p_ship_to_location_id            IN  NUMBER   ,
  p_bill_to_location_id            IN  NUMBER   ,
  p_ship_via_lookup_code           IN  VARCHAR2 ,
  p_freight_terms_lookup_code      IN  VARCHAR2 ,
  p_fob_lookup_code                IN  VARCHAR2 ,
  p_inactive_date                  IN  DATE     ,
  p_fax                            IN  VARCHAR2 ,
  p_fax_area_code                  IN  VARCHAR2 ,
  p_telex                          IN  VARCHAR2 ,
  p_terms_date_basis               IN  VARCHAR2 ,
  p_distribution_set_id            IN  NUMBER   ,
  p_accts_pay_code_combo_id        IN  NUMBER   ,
  p_prepay_code_combination_id     IN  NUMBER   ,
  p_pay_group_lookup_code          IN  VARCHAR2 ,
  p_payment_priority               IN  NUMBER   ,
  p_terms_id                       IN  NUMBER   ,
  p_invoice_amount_limit           IN  NUMBER   ,
  p_pay_date_basis_lookup_code     IN  VARCHAR2 ,
  p_always_take_disc_flag          IN  VARCHAR2 ,
  p_invoice_currency_code          IN  VARCHAR2 ,
  p_payment_currency_code          IN  VARCHAR2 ,
  p_vendor_site_id                 IN  NUMBER   ,
  p_last_update_date               IN  DATE     ,
  p_last_updated_by                IN  NUMBER   ,
  p_vendor_id                      IN  NUMBER   ,
  p_vendor_site_code               IN  VARCHAR2 ,
  p_vendor_site_code_alt           IN  VARCHAR2 ,
  p_purchasing_site_flag           IN  VARCHAR2 ,
  p_rfq_only_site_flag             IN  VARCHAR2 ,
  p_pay_site_flag                  IN  VARCHAR2 ,
  p_attention_ar_flag              IN  VARCHAR2 ,
  p_hold_all_payments_flag         IN  VARCHAR2 ,
  p_hold_future_payments_flag      IN  VARCHAR2 ,
  p_hold_reason                    IN  VARCHAR2 ,
  p_hold_unmatched_invoices_flag   IN  VARCHAR2 ,
  p_tax_reporting_site_flag        IN  VARCHAR2 ,
  p_attribute_category             IN  VARCHAR2 ,
  p_attribute1                     IN  VARCHAR2 ,
  p_attribute2                     IN  VARCHAR2 ,
  p_attribute3                     IN  VARCHAR2 ,
  p_attribute4                     IN  VARCHAR2 ,
  p_attribute5                     IN  VARCHAR2 ,
  p_attribute6                     IN  VARCHAR2 ,
  p_attribute7                     IN  VARCHAR2 ,
  p_attribute8                     IN  VARCHAR2 ,
  p_attribute9                     IN  VARCHAR2 ,
  p_attribute10                    IN  VARCHAR2 ,
  p_attribute11                    IN  VARCHAR2 ,
  p_attribute12                    IN  VARCHAR2 ,
  p_attribute13                    IN  VARCHAR2 ,
  p_attribute14                    IN  VARCHAR2 ,
  p_attribute15                    IN  VARCHAR2 ,
  p_validation_number              IN  NUMBER   ,
  p_exclude_freight_from_discnt    IN  VARCHAR2 ,
  p_bank_charge_bearer             IN  VARCHAR2 ,
  p_org_id                         IN  NUMBER   ,
  p_check_digits                   IN  VARCHAR2 ,
  p_allow_awt_flag                 IN  VARCHAR2 ,
  p_awt_group_id                   IN  NUMBER   ,
  p_pay_awt_group_id                   IN  NUMBER   ,
  p_default_pay_site_id            IN  NUMBER   ,
  p_pay_on_code                    IN  VARCHAR2 ,
  p_pay_on_receipt_summary_code    IN  VARCHAR2 ,
  p_global_attribute_category      IN  VARCHAR2 ,
  p_global_attribute1              IN  VARCHAR2 ,
  p_global_attribute2              IN  VARCHAR2 ,
  p_global_attribute3              IN  VARCHAR2 ,
  p_global_attribute4              IN  VARCHAR2 ,
  p_global_attribute5              IN  VARCHAR2 ,
  p_global_attribute6              IN  VARCHAR2 ,
  p_global_attribute7              IN  VARCHAR2 ,
  p_global_attribute8              IN  VARCHAR2 ,
  p_global_attribute9              IN  VARCHAR2 ,
  p_global_attribute10             IN  VARCHAR2 ,
  p_global_attribute11             IN  VARCHAR2 ,
  p_global_attribute12             IN  VARCHAR2 ,
  p_global_attribute13             IN  VARCHAR2 ,
  p_global_attribute14             IN  VARCHAR2 ,
  p_global_attribute15             IN  VARCHAR2 ,
  p_global_attribute16             IN  VARCHAR2 ,
  p_global_attribute17             IN  VARCHAR2 ,
  p_global_attribute18             IN  VARCHAR2 ,
  p_global_attribute19             IN  VARCHAR2 ,
  p_global_attribute20             IN  VARCHAR2 ,
  p_tp_header_id                   IN  NUMBER   ,
  p_edi_id_number                  IN  VARCHAR2 ,
  p_ece_tp_location_code           IN  VARCHAR2 ,
  p_pcard_site_flag                IN  VARCHAR2 ,
  p_match_option                   IN  VARCHAR2 ,
  p_country_of_origin_code         IN  VARCHAR2 ,
  p_future_dated_payment_ccid      IN  NUMBER   ,
  p_create_debit_memo_flag         IN  VARCHAR2 ,
  p_supplier_notif_method          IN  VARCHAR2 ,
  p_email_address                  IN  VARCHAR2 ,
  p_primary_pay_site_flag          IN  VARCHAR2 ,
  p_shipping_control               IN  VARCHAR2 ,
  p_selling_company_identifier     IN  VARCHAR2 ,
  p_gapless_inv_num_flag           IN  VARCHAR2 ,
  p_location_id                    IN  NUMBER   ,
  p_party_site_id                  IN  NUMBER   ,
  p_org_name                       IN  VARCHAR2 ,
  p_duns_number                    IN  VARCHAR2 ,
  p_address_style                  IN  VARCHAR2 ,
  p_language                       IN  VARCHAR2 ,
  p_province                       IN  VARCHAR2 ,
  p_country                        IN  VARCHAR2 ,
  p_address_line1                  IN  VARCHAR2 ,
  p_address_line2                  IN  VARCHAR2 ,
  p_address_line3                  IN  VARCHAR2 ,
  p_address_line4                  IN  VARCHAR2 ,
  p_address_lines_alt              IN  VARCHAR2 ,
  p_county                         IN  VARCHAR2 ,
  p_city                           IN  VARCHAR2 ,
  p_state                          IN  VARCHAR2 ,
  p_zip                            IN  VARCHAR2 ,
  p_terms_name                     IN  VARCHAR2 ,
  p_default_terms_id               IN  NUMBER   ,
  p_awt_group_name                 IN  VARCHAR2 ,
  p_pay_awt_group_name                 IN  VARCHAR2 ,
  p_distribution_set_name          IN  VARCHAR2 ,
  p_ship_to_location_code          IN  VARCHAR2 ,
  p_bill_to_location_code          IN  VARCHAR2 ,
  p_default_dist_set_id            IN  NUMBER   ,
  p_default_ship_to_loc_id         IN  NUMBER   ,
  p_default_bill_to_loc_id         IN  NUMBER   ,
  p_tolerance_id                   IN  NUMBER   ,
  p_tolerance_name                 IN  VARCHAR2 ,
  p_retainage_rate                 IN  NUMBER   ,
  p_mode              IN  VARCHAR2,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_error_msg         OUT NOCOPY VARCHAR2,
  x_party_site_valid  OUT NOCOPY VARCHAR2,
  x_location_valid    OUT NOCOPY VARCHAR2
)
IS
   l_vendor_site_rec ap_vendor_pub_pkg.r_vendor_site_rec_type;
   l_msg_count  NUMBER;
   l_msg_data   VARCHAR2(4000);
   is_site_ccr VARCHAR2(1);
BEGIN

  if (p_mode <> 'I' ) then
   l_vendor_site_rec.area_code                     := Nvl(p_area_code, fnd_api.g_null_char);
   l_vendor_site_rec.phone                         := Nvl(p_phone, fnd_api.g_null_char);
   l_vendor_site_rec.customer_num                  := Nvl(p_customer_num, fnd_api.g_null_char);
   l_vendor_site_rec.ship_to_location_id           := Nvl(p_ship_to_location_id, fnd_api.g_null_num);
   l_vendor_site_rec.bill_to_location_id           := Nvl(p_bill_to_location_id, fnd_api.g_null_num);
   l_vendor_site_rec.ship_via_lookup_code          := Nvl(p_ship_via_lookup_code, fnd_api.g_null_char);
   l_vendor_site_rec.freight_terms_lookup_code     := Nvl(p_freight_terms_lookup_code, fnd_api.g_null_char);
   l_vendor_site_rec.fob_lookup_code               := Nvl(p_fob_lookup_code, fnd_api.g_null_char);
   l_vendor_site_rec.inactive_date                 := Nvl(p_inactive_date, fnd_api.g_null_date);
   l_vendor_site_rec.fax                           := Nvl(p_fax, fnd_api.g_null_char);
   l_vendor_site_rec.fax_area_code                 := Nvl(p_fax_area_code, fnd_api.g_null_char);
   l_vendor_site_rec.telex                         := Nvl(p_telex, fnd_api.g_null_char);
   l_vendor_site_rec.terms_date_basis              := Nvl(p_terms_date_basis, fnd_api.g_null_char);
   l_vendor_site_rec.distribution_set_id           := Nvl(p_distribution_set_id, fnd_api.g_null_num);
   l_vendor_site_rec.accts_pay_code_combination_id := Nvl(p_accts_pay_code_combo_id, fnd_api.g_null_num);
   l_vendor_site_rec.prepay_code_combination_id    := Nvl(p_prepay_code_combination_id, fnd_api.g_null_num);
   l_vendor_site_rec.pay_group_lookup_code         := Nvl(p_pay_group_lookup_code, fnd_api.g_null_char);
   l_vendor_site_rec.payment_priority              := Nvl(p_payment_priority, fnd_api.g_null_num);
   l_vendor_site_rec.terms_id                      := Nvl(p_terms_id, fnd_api.g_null_num);
   l_vendor_site_rec.invoice_amount_limit          := Nvl(p_invoice_amount_limit, fnd_api.g_null_num);
   l_vendor_site_rec.pay_date_basis_lookup_code    := Nvl(p_pay_date_basis_lookup_code, fnd_api.g_null_char);
   l_vendor_site_rec.always_take_disc_flag         := Nvl(p_always_take_disc_flag, fnd_api.g_null_char);
   l_vendor_site_rec.invoice_currency_code         := Nvl(p_invoice_currency_code, fnd_api.g_null_char);
   l_vendor_site_rec.payment_currency_code         := Nvl(p_payment_currency_code, fnd_api.g_null_char);
   l_vendor_site_rec.vendor_site_id                := Nvl(p_vendor_site_id, fnd_api.g_null_num);
   l_vendor_site_rec.last_update_date              := Nvl(p_last_update_date, fnd_api.g_null_date);
   l_vendor_site_rec.last_updated_by               := Nvl(p_last_updated_by, fnd_api.g_null_num);
   l_vendor_site_rec.vendor_id                     := Nvl(p_vendor_id, fnd_api.g_null_num);
   l_vendor_site_rec.vendor_site_code              := p_vendor_site_code;
   l_vendor_site_rec.vendor_site_code_alt          := Nvl(p_vendor_site_code_alt, fnd_api.g_null_char);
   l_vendor_site_rec.purchasing_site_flag          := Nvl(p_purchasing_site_flag, fnd_api.g_null_char);
   l_vendor_site_rec.rfq_only_site_flag            := Nvl(p_rfq_only_site_flag, fnd_api.g_null_char);
   l_vendor_site_rec.pay_site_flag                 := Nvl(p_pay_site_flag, fnd_api.g_null_char);
   l_vendor_site_rec.attention_ar_flag             := Nvl(p_attention_ar_flag, fnd_api.g_null_char);
   l_vendor_site_rec.hold_all_payments_flag        := Nvl(p_hold_all_payments_flag, fnd_api.g_null_char);
   l_vendor_site_rec.hold_future_payments_flag     := Nvl(p_hold_future_payments_flag, fnd_api.g_null_char);
   l_vendor_site_rec.hold_reason                   := Nvl(p_hold_reason, fnd_api.g_null_char);
   l_vendor_site_rec.hold_unmatched_invoices_flag  := Nvl(p_hold_unmatched_invoices_flag, fnd_api.g_null_char);
   l_vendor_site_rec.tax_reporting_site_flag       := Nvl(p_tax_reporting_site_flag, fnd_api.g_null_char);
   l_vendor_site_rec.attribute_category            := Nvl(p_attribute_category, fnd_api.g_null_char);
   l_vendor_site_rec.attribute1                    := Nvl(p_attribute1, fnd_api.g_null_char);
   l_vendor_site_rec.attribute2                    := Nvl(p_attribute2, fnd_api.g_null_char);
   l_vendor_site_rec.attribute3                    := Nvl(p_attribute3, fnd_api.g_null_char);
   l_vendor_site_rec.attribute4                    := Nvl(p_attribute4, fnd_api.g_null_char);
   l_vendor_site_rec.attribute5                    := Nvl(p_attribute5, fnd_api.g_null_char);
   l_vendor_site_rec.attribute6                    := Nvl(p_attribute6, fnd_api.g_null_char);
   l_vendor_site_rec.attribute7                    := Nvl(p_attribute7, fnd_api.g_null_char);
   l_vendor_site_rec.attribute8                    := Nvl(p_attribute8, fnd_api.g_null_char);
   l_vendor_site_rec.attribute9                    := Nvl(p_attribute9, fnd_api.g_null_char);
   l_vendor_site_rec.attribute10                   := Nvl(p_attribute10, fnd_api.g_null_char);
   l_vendor_site_rec.attribute11                   := Nvl(p_attribute11, fnd_api.g_null_char);
   l_vendor_site_rec.attribute12                   := Nvl(p_attribute12, fnd_api.g_null_char);
   l_vendor_site_rec.attribute13                   := Nvl(p_attribute13, fnd_api.g_null_char);
   l_vendor_site_rec.attribute14                   := Nvl(p_attribute14, fnd_api.g_null_char);
   l_vendor_site_rec.attribute15                   := Nvl(p_attribute15, fnd_api.g_null_char);
   l_vendor_site_rec.validation_number             := Nvl(p_validation_number, fnd_api.g_null_num);
   l_vendor_site_rec.exclude_freight_from_discount := Nvl(p_exclude_freight_from_discnt, fnd_api.g_null_char);
   l_vendor_site_rec.bank_charge_bearer            := Nvl(p_bank_charge_bearer, fnd_api.g_null_char);
   l_vendor_site_rec.org_id                        := Nvl(p_org_id, fnd_api.g_null_num);
   l_vendor_site_rec.check_digits                  := Nvl(p_check_digits, fnd_api.g_null_char);
   l_vendor_site_rec.allow_awt_flag                := Nvl(p_allow_awt_flag, fnd_api.g_null_char);
   l_vendor_site_rec.awt_group_id                  := Nvl(p_awt_group_id, fnd_api.g_null_num);
   l_vendor_site_rec.pay_awt_group_id                  := Nvl(p_pay_awt_group_id, fnd_api.g_null_num);
   l_vendor_site_rec.default_pay_site_id           := Nvl(p_default_pay_site_id, fnd_api.g_null_num);
   l_vendor_site_rec.pay_on_code                   := Nvl(p_pay_on_code, fnd_api.g_null_char);
   l_vendor_site_rec.pay_on_receipt_summary_code   := Nvl(p_pay_on_receipt_summary_code, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute_category     := Nvl(p_global_attribute_category, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute1             := Nvl(p_global_attribute1, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute2             := Nvl(p_global_attribute2, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute3             := Nvl(p_global_attribute3, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute4             := Nvl(p_global_attribute4, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute5             := Nvl(p_global_attribute5, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute6             := Nvl(p_global_attribute6, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute7             := Nvl(p_global_attribute7, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute8             := Nvl(p_global_attribute8, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute9             := Nvl(p_global_attribute9, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute10            := Nvl(p_global_attribute10, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute11            := Nvl(p_global_attribute11, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute12            := Nvl(p_global_attribute12, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute13            := Nvl(p_global_attribute13, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute14            := Nvl(p_global_attribute14, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute15            := Nvl(p_global_attribute15, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute16            := Nvl(p_global_attribute16, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute17            := Nvl(p_global_attribute17, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute18            := Nvl(p_global_attribute18, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute19            := Nvl(p_global_attribute19, fnd_api.g_null_char);
   l_vendor_site_rec.global_attribute20            := Nvl(p_global_attribute20, fnd_api.g_null_char);
   l_vendor_site_rec.tp_header_id                  := Nvl(p_tp_header_id, fnd_api.g_null_num);
   l_vendor_site_rec.edi_id_number                 := Nvl(p_edi_id_number, fnd_api.g_null_char);
   l_vendor_site_rec.ece_tp_location_code          := Nvl(p_ece_tp_location_code, fnd_api.g_null_char);
   l_vendor_site_rec.pcard_site_flag               := Nvl(p_pcard_site_flag, fnd_api.g_null_char);
   l_vendor_site_rec.match_option                  := Nvl(p_match_option, fnd_api.g_null_char);
   l_vendor_site_rec.country_of_origin_code        := Nvl(p_country_of_origin_code, fnd_api.g_null_char);
   l_vendor_site_rec.future_dated_payment_ccid     := Nvl(p_future_dated_payment_ccid, fnd_api.g_null_num);
   l_vendor_site_rec.create_debit_memo_flag        := Nvl(p_create_debit_memo_flag, fnd_api.g_null_char);
   l_vendor_site_rec.supplier_notif_method         := Nvl(p_supplier_notif_method, fnd_api.g_null_char);
   l_vendor_site_rec.email_address                 := Nvl(p_email_address, fnd_api.g_null_char);
   l_vendor_site_rec.primary_pay_site_flag         := Nvl(p_primary_pay_site_flag, fnd_api.g_null_char);
   l_vendor_site_rec.shipping_control              := Nvl(p_shipping_control, fnd_api.g_null_char);
   l_vendor_site_rec.selling_company_identifier    := Nvl(p_selling_company_identifier, fnd_api.g_null_char);
   l_vendor_site_rec.gapless_inv_num_flag          := Nvl(p_gapless_inv_num_flag, fnd_api.g_null_char);
   l_vendor_site_rec.location_id                   := Nvl(p_location_id, fnd_api.g_null_num);
   l_vendor_site_rec.party_site_id                 := Nvl(p_party_site_id, fnd_api.g_null_num);
   l_vendor_site_rec.org_name                      := p_org_name;
   l_vendor_site_rec.duns_number                   := Nvl(p_duns_number, fnd_api.g_null_char);
   l_vendor_site_rec.address_style                 := Nvl(p_address_style, fnd_api.g_null_char);
   l_vendor_site_rec.language                      := Nvl(get_nls_language(p_language), fnd_api.g_null_char);
   l_vendor_site_rec.province                      := Nvl(p_province, fnd_api.g_null_char);
   l_vendor_site_rec.country                       := Nvl(p_country, fnd_api.g_null_char);
   l_vendor_site_rec.address_line1                 := Nvl(p_address_line1, fnd_api.g_null_char);
   l_vendor_site_rec.address_line2                 := Nvl(p_address_line2, fnd_api.g_null_char);
   l_vendor_site_rec.address_line3                 := Nvl(p_address_line3, fnd_api.g_null_char);
   l_vendor_site_rec.address_line4                 := Nvl(p_address_line4, fnd_api.g_null_char);
   l_vendor_site_rec.address_lines_alt             := Nvl(p_address_lines_alt, fnd_api.g_null_char);
   l_vendor_site_rec.county                        := Nvl(p_county, fnd_api.g_null_char);
   l_vendor_site_rec.city                          := Nvl(p_city, fnd_api.g_null_char);
   l_vendor_site_rec.state                         := Nvl(p_state, fnd_api.g_null_char);
   l_vendor_site_rec.zip                           := Nvl(p_zip, fnd_api.g_null_char);
   l_vendor_site_rec.terms_name                    := p_terms_name;
   l_vendor_site_rec.default_terms_id              := Nvl(p_default_terms_id, fnd_api.g_null_num);
   l_vendor_site_rec.awt_group_name                := p_awt_group_name;
   l_vendor_site_rec.pay_awt_group_name                := p_pay_awt_group_name;
   l_vendor_site_rec.distribution_set_name         := p_distribution_set_name;
   l_vendor_site_rec.ship_to_location_code         := Nvl(p_ship_to_location_code, fnd_api.g_null_char);
   l_vendor_site_rec.bill_to_location_code         := Nvl(p_bill_to_location_code, fnd_api.g_null_char);
   l_vendor_site_rec.default_dist_set_id           := Nvl(p_default_dist_set_id, fnd_api.g_null_num);
   l_vendor_site_rec.default_ship_to_loc_id        := Nvl(p_default_ship_to_loc_id, fnd_api.g_null_num);
   l_vendor_site_rec.default_bill_to_loc_id        := Nvl(p_default_bill_to_loc_id, fnd_api.g_null_num);
   l_vendor_site_rec.tolerance_id                  := Nvl(p_tolerance_id, fnd_api.g_null_num);
   l_vendor_site_rec.tolerance_name                := p_tolerance_name;
   l_vendor_site_rec.retainage_rate                := Nvl(p_retainage_rate, fnd_api.g_null_num);
  else
   l_vendor_site_rec.area_code                     := p_area_code;
   l_vendor_site_rec.phone                         := p_phone;
   l_vendor_site_rec.customer_num                  := p_customer_num;
   l_vendor_site_rec.ship_to_location_id           := p_ship_to_location_id;
   l_vendor_site_rec.bill_to_location_id           := p_bill_to_location_id;
   l_vendor_site_rec.ship_via_lookup_code          := p_ship_via_lookup_code;
   l_vendor_site_rec.freight_terms_lookup_code     := p_freight_terms_lookup_code;
   l_vendor_site_rec.fob_lookup_code               := p_fob_lookup_code;
   l_vendor_site_rec.inactive_date                 := p_inactive_date;
   l_vendor_site_rec.fax                           := p_fax;
   l_vendor_site_rec.fax_area_code                 := p_fax_area_code;
   l_vendor_site_rec.telex                         := p_telex;
   l_vendor_site_rec.terms_date_basis              := p_terms_date_basis;
   l_vendor_site_rec.distribution_set_id           := p_distribution_set_id;
   l_vendor_site_rec.accts_pay_code_combination_id := p_accts_pay_code_combo_id;
   l_vendor_site_rec.prepay_code_combination_id    := p_prepay_code_combination_id;
   l_vendor_site_rec.pay_group_lookup_code         := p_pay_group_lookup_code;
   l_vendor_site_rec.payment_priority              := p_payment_priority;
   l_vendor_site_rec.terms_id                      := p_terms_id;
   l_vendor_site_rec.invoice_amount_limit          := p_invoice_amount_limit;
   l_vendor_site_rec.pay_date_basis_lookup_code    := p_pay_date_basis_lookup_code;
   l_vendor_site_rec.always_take_disc_flag         := p_always_take_disc_flag;
   l_vendor_site_rec.invoice_currency_code         := p_invoice_currency_code;
   l_vendor_site_rec.payment_currency_code         := p_payment_currency_code;
   l_vendor_site_rec.vendor_site_id                := p_vendor_site_id;
   l_vendor_site_rec.last_update_date              := p_last_update_date;
   l_vendor_site_rec.last_updated_by               := p_last_updated_by;
   l_vendor_site_rec.vendor_id                     := p_vendor_id;
   l_vendor_site_rec.vendor_site_code              := p_vendor_site_code;
   l_vendor_site_rec.vendor_site_code_alt          := p_vendor_site_code_alt;
   l_vendor_site_rec.purchasing_site_flag          := p_purchasing_site_flag;
   l_vendor_site_rec.rfq_only_site_flag            := p_rfq_only_site_flag;
   l_vendor_site_rec.pay_site_flag                 := p_pay_site_flag;
   l_vendor_site_rec.attention_ar_flag             := p_attention_ar_flag;
   l_vendor_site_rec.hold_all_payments_flag        := p_hold_all_payments_flag;
   l_vendor_site_rec.hold_future_payments_flag     := p_hold_future_payments_flag;
   l_vendor_site_rec.hold_reason                   := p_hold_reason;
   l_vendor_site_rec.hold_unmatched_invoices_flag  := p_hold_unmatched_invoices_flag;
   l_vendor_site_rec.tax_reporting_site_flag       := p_tax_reporting_site_flag;
   l_vendor_site_rec.attribute_category            := p_attribute_category;
   l_vendor_site_rec.attribute1                    := p_attribute1;
   l_vendor_site_rec.attribute2                    := p_attribute2;
   l_vendor_site_rec.attribute3                    := p_attribute3;
   l_vendor_site_rec.attribute4                    := p_attribute4;
   l_vendor_site_rec.attribute5                    := p_attribute5;
   l_vendor_site_rec.attribute6                    := p_attribute6;
   l_vendor_site_rec.attribute7                    := p_attribute7;
   l_vendor_site_rec.attribute8                    := p_attribute8;
   l_vendor_site_rec.attribute9                    := p_attribute9;
   l_vendor_site_rec.attribute10                   := p_attribute10;
   l_vendor_site_rec.attribute11                   := p_attribute11;
   l_vendor_site_rec.attribute12                   := p_attribute12;
   l_vendor_site_rec.attribute13                   := p_attribute13;
   l_vendor_site_rec.attribute14                   := p_attribute14;
   l_vendor_site_rec.attribute15                   := p_attribute15;
   l_vendor_site_rec.validation_number             := p_validation_number;
   l_vendor_site_rec.exclude_freight_from_discount := p_exclude_freight_from_discnt;
   l_vendor_site_rec.bank_charge_bearer            := p_bank_charge_bearer;
   l_vendor_site_rec.org_id                        := p_org_id;
   l_vendor_site_rec.check_digits                  := p_check_digits;
   l_vendor_site_rec.allow_awt_flag                := p_allow_awt_flag;
   l_vendor_site_rec.awt_group_id                  := p_awt_group_id;
   l_vendor_site_rec.pay_awt_group_id                  := p_pay_awt_group_id;
   l_vendor_site_rec.default_pay_site_id           := p_default_pay_site_id;
   l_vendor_site_rec.pay_on_code                   := p_pay_on_code;
   l_vendor_site_rec.pay_on_receipt_summary_code   := p_pay_on_receipt_summary_code;
   l_vendor_site_rec.global_attribute_category     := p_global_attribute_category;
   l_vendor_site_rec.global_attribute1             := p_global_attribute1;
   l_vendor_site_rec.global_attribute2             := p_global_attribute2;
   l_vendor_site_rec.global_attribute3             := p_global_attribute3;
   l_vendor_site_rec.global_attribute4             := p_global_attribute4;
   l_vendor_site_rec.global_attribute5             := p_global_attribute5;
   l_vendor_site_rec.global_attribute6             := p_global_attribute6;
   l_vendor_site_rec.global_attribute7             := p_global_attribute7;
   l_vendor_site_rec.global_attribute8             := p_global_attribute8;
   l_vendor_site_rec.global_attribute9             := p_global_attribute9;
   l_vendor_site_rec.global_attribute10            := p_global_attribute10;
   l_vendor_site_rec.global_attribute11            := p_global_attribute11;
   l_vendor_site_rec.global_attribute12            := p_global_attribute12;
   l_vendor_site_rec.global_attribute13            := p_global_attribute13;
   l_vendor_site_rec.global_attribute14            := p_global_attribute14;
   l_vendor_site_rec.global_attribute15            := p_global_attribute15;
   l_vendor_site_rec.global_attribute16            := p_global_attribute16;
   l_vendor_site_rec.global_attribute17            := p_global_attribute17;
   l_vendor_site_rec.global_attribute18            := p_global_attribute18;
   l_vendor_site_rec.global_attribute19            := p_global_attribute19;
   l_vendor_site_rec.global_attribute20            := p_global_attribute20;
   l_vendor_site_rec.tp_header_id                  := p_tp_header_id;
   l_vendor_site_rec.edi_id_number                 := p_edi_id_number;
   l_vendor_site_rec.ece_tp_location_code          := p_ece_tp_location_code;
   l_vendor_site_rec.pcard_site_flag               := p_pcard_site_flag;
   l_vendor_site_rec.match_option                  := p_match_option;
   l_vendor_site_rec.country_of_origin_code        := p_country_of_origin_code;
   l_vendor_site_rec.future_dated_payment_ccid     := p_future_dated_payment_ccid;
   l_vendor_site_rec.create_debit_memo_flag        := p_create_debit_memo_flag;
   l_vendor_site_rec.supplier_notif_method         := p_supplier_notif_method;
   l_vendor_site_rec.email_address                 := p_email_address;
   l_vendor_site_rec.primary_pay_site_flag         := p_primary_pay_site_flag;
   l_vendor_site_rec.shipping_control              := p_shipping_control;
   l_vendor_site_rec.selling_company_identifier    := p_selling_company_identifier;
   l_vendor_site_rec.gapless_inv_num_flag          := p_gapless_inv_num_flag;
   l_vendor_site_rec.location_id                   := p_location_id;
   l_vendor_site_rec.party_site_id                 := p_party_site_id;
   l_vendor_site_rec.org_name                      := p_org_name;
   l_vendor_site_rec.duns_number                   := p_duns_number;
   l_vendor_site_rec.address_style                 := p_address_style;
   l_vendor_site_rec.language                      := get_nls_language(p_language);
   l_vendor_site_rec.province                      := p_province;
   l_vendor_site_rec.country                       := p_country;
   l_vendor_site_rec.address_line1                 := p_address_line1;
   l_vendor_site_rec.address_line2                 := p_address_line2;
   l_vendor_site_rec.address_line3                 := p_address_line3;
   l_vendor_site_rec.address_line4                 := p_address_line4;
   l_vendor_site_rec.address_lines_alt             := p_address_lines_alt;
   l_vendor_site_rec.county                        := p_county;
   l_vendor_site_rec.city                          := p_city;
   l_vendor_site_rec.state                         := p_state;
   l_vendor_site_rec.zip                           := p_zip;
   l_vendor_site_rec.terms_name                    := p_terms_name;
   l_vendor_site_rec.default_terms_id              := p_default_terms_id;
   l_vendor_site_rec.awt_group_name                := p_awt_group_name;
   l_vendor_site_rec.pay_awt_group_name                := p_pay_awt_group_name;
   l_vendor_site_rec.distribution_set_name         := p_distribution_set_name;
   l_vendor_site_rec.ship_to_location_code         := p_ship_to_location_code;
   l_vendor_site_rec.bill_to_location_code         := p_bill_to_location_code;
   l_vendor_site_rec.default_dist_set_id           := p_default_dist_set_id;
   l_vendor_site_rec.default_ship_to_loc_id        := p_default_ship_to_loc_id;
   l_vendor_site_rec.default_bill_to_loc_id        := p_default_bill_to_loc_id;
   l_vendor_site_rec.tolerance_id                  := p_tolerance_id;
   l_vendor_site_rec.tolerance_name                := p_tolerance_name;
   l_vendor_site_rec.retainage_rate                := p_retainage_rate;

   end if;

   -- ccr code starts
   is_site_ccr := POS_UTIL_PKG.IS_SITE_CCR(1.0,null,l_vendor_site_rec.vendor_site_id);
   if is_site_ccr = 'T' AND p_mode = 'U' then
      l_vendor_site_rec.duns_number := null;
      l_vendor_site_rec.country := null;
      l_vendor_site_rec.address_line1 := null;
      l_vendor_site_rec.address_line2 := null;
      l_vendor_site_rec.address_line3 := null;
      l_vendor_site_rec.address_line4 := null;
      l_vendor_site_rec.city := null;
      l_vendor_site_rec.state := null;
      l_vendor_site_rec.zip := null;
      l_vendor_site_rec.province := null;
   end if;
   -- ccr code ends

   Validate_Vendor_Site
     (
      p_vendor_site_rec  => l_vendor_site_rec,
      p_mode             => p_mode,
      x_return_status    => x_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data,
      x_party_site_valid => x_party_site_valid,
      x_location_valid   => x_location_valid
      );

   combine_err_msg(x_return_status, l_msg_count, l_msg_data, x_error_msg);

END Validate_Vendor_Site;

--
-- Begin Supplier Hub: Data Publication
--
PROCEDURE Process_User_Attrs_Data (
    p_api_version                   IN   NUMBER,
    p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE,
    p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE,
    p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY,
    p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY,
    p_user_privileges_on_object     IN   EGO_VARCHAR_TBL_TYPE DEFAULT NULL,
    p_entity_id                     IN   NUMBER     DEFAULT NULL,
    p_entity_index                  IN   NUMBER     DEFAULT NULL,
    p_entity_code                   IN   VARCHAR2   DEFAULT NULL,
    p_debug_level                   IN   NUMBER     DEFAULT 0,
    p_init_error_handler            IN   VARCHAR2   DEFAULT NULL,
    p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT NULL,
    p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT NULL,
    p_log_errors                    IN   VARCHAR2   DEFAULT NULL,
    p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT NULL,
    p_commit                        IN   VARCHAR2   DEFAULT NULL,
    x_failed_row_id_list            OUT NOCOPY VARCHAR2,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_errorcode                     OUT NOCOPY NUMBER,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2
) IS
--
-- This version of EGO's UDA Process User Attributes Data API is
-- almost identical to the original version in ego_user_attrs_data_pub
-- with the exception of hardcoding the object name HZ_PARTIES which
-- is the only object name expected when accessing UDA for Supplier
-- related entities.
--
-- Another minor difference is the following optional parameters.  In the
-- original EGO API they are defined as having DEFAULT fnd_api.g_false.
-- This can be finessed as memory is allocated for each even if
-- user skips them.  Now changed to DEFAULT NULL, retaining the same
-- default semantics by NVL in the body.  This is done according to
-- current performance coding standard.
--
--    p_init_error_handler            IN   VARCHAR2   DEFAULT NULL,
--    p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT NULL,
--    p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT NULL,
--    p_log_errors                    IN   VARCHAR2   DEFAULT NULL,
--    p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT NULL,
--    p_commit                        IN   VARCHAR2   DEFAULT NULL,
--
-- Mon Aug 31 09:26:11 PDT 2009 bso R12.1.2
--
        l_extension_id              NUMBER          := NULL;
        l_mode                      VARCHAR2(2000)  := NULL;
        l_return_status             VARCHAR2(2000)  := NULL;
        l_error_code                VARCHAR2(2000)  := NULL;
        l_msg_count                 NUMBER          := NULL;
        l_msg_data                  VARCHAR2(2000)  := NULL;

        --l_object_id                 NUMBER          := NULL;
        l_object_name               VARCHAR2(430)   := NULL;

        l_row_attrs_table           EGO_USER_ATTR_DATA_TABLE            := NULL;
        l_data_level_pairs          EGO_COL_NAME_VALUE_PAIR_ARRAY       := NULL;

        l_entity_id                 VARCHAR2(1000)    := NULL;
        l_message_type              VARCHAR2(1000)    := NULL;

BEGIN
      SAVEPOINT	Process_User_Attrs_Data_PUB;
      l_object_name := 'HZ_PARTIES';
      x_return_status := 'S';

      FOR i IN 1 .. p_attributes_row_table.count LOOP
        IF (p_attributes_row_table(i).data_level = 'SUPP_LEVEL') THEN
          l_data_level_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
              EGO_COL_NAME_VALUE_PAIR_OBJ('IS_PROSPECT', p_attributes_row_table(i).data_level_1));
        ELSIF (p_attributes_row_table(i).data_level = 'SUPP_ADDR_LEVEL') THEN
          l_data_level_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
              EGO_COL_NAME_VALUE_PAIR_OBJ('IS_PROSPECT', p_attributes_row_table(i).data_level_1)
            , EGO_COL_NAME_VALUE_PAIR_OBJ('PK1_VALUE', p_attributes_row_table(i).data_level_2));
        ELSIF (p_attributes_row_table(i).data_level = 'SUPP_ADDR_SITE_LEVEL') THEN
          l_data_level_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
              EGO_COL_NAME_VALUE_PAIR_OBJ('IS_PROSPECT', p_attributes_row_table(i).data_level_1)
            , EGO_COL_NAME_VALUE_PAIR_OBJ('PK1_VALUE', p_attributes_row_table(i).data_level_2)
            , EGO_COL_NAME_VALUE_PAIR_OBJ('PK2_VALUE', p_attributes_row_table(i).data_level_3));
        END IF;
        IF (l_row_attrs_table IS NOT NULL) THEN
          l_row_attrs_table.DELETE;
        END IF;
        l_row_attrs_table := EGO_USER_ATTR_DATA_TABLE();

        FOR j IN 1 .. p_attributes_data_table.count LOOP
          IF (p_attributes_data_table(j).row_identifier = p_attributes_row_table(i).row_identifier) THEN
            l_row_attrs_table.EXTEND;
            l_row_attrs_table(l_row_attrs_table.LAST) := p_attributes_data_table(j);
          END IF;
        END LOOP;

        ego_user_attrs_data_pvt.Process_Row(
                  p_api_version                   =>  p_api_version
                , p_object_id                     =>  NULL --l_object_id-- 22 for HZ_PARTIES, 87 for EGO_ITEM
                , p_object_name                   =>  l_object_name-- HZ_PARTIES/EGO_ITEM
                , p_attr_group_id                 =>  p_attributes_row_table(i).attr_group_id-- input
                , p_application_id                =>  p_attributes_row_table(i).attr_group_app_id-- 177 for supplier, 431 for item
                , p_attr_group_type               =>  p_attributes_row_table(i).attr_group_type-- POS_SUPP_PROFMGMT_GROUP/EGO_ITEMMGMT_GROUP
                , p_attr_group_name               =>  p_attributes_row_table(i).attr_group_name-- input
                , p_validate_hierarchy            =>  FND_API.G_FALSE
                , p_pk_column_name_value_pairs    =>  p_pk_column_name_value_pairs-- input
                , p_class_code_name_value_pairs   =>  p_class_code_name_value_pairs-- input
                , p_data_level                    =>  p_attributes_row_table(i).data_level-- input
                , p_data_level_name_value_pairs   =>  l_data_level_pairs-- input
                , p_extension_id                  =>  NULL
                , p_attr_name_value_pairs         =>  l_row_attrs_table-- input
                , p_entity_id                     =>  NULL
                , p_entity_index                  =>  NULL
                , p_entity_code                   =>  NULL
                , p_validate_only                 =>  FND_API.G_FALSE
                , p_language_to_process           =>  NULL
                , p_mode                          =>  p_attributes_row_table(i).transaction_type
                , p_change_obj                    =>  NULL
                , p_pending_b_table_name          =>  NULL
                , p_pending_tl_table_name         =>  NULL
                , p_pending_vl_name               =>  NULL
                , p_init_fnd_msg_list             =>  FND_API.G_FALSE
                , p_add_errors_to_fnd_stack       =>  FND_API.G_FALSE
                , p_commit                        =>  FND_API.G_FALSE
                , p_raise_business_event          =>  FALSE
                , x_extension_id                  =>  l_extension_id
                , x_mode                          =>  l_mode
                , x_return_status                 =>  l_return_status
                , x_errorcode                     =>  l_error_code
                , x_msg_count                     =>  l_msg_count
                , x_msg_data                      =>  l_msg_data
        );

        IF (l_return_status <> 'S') THEN
          ROLLBACK TO Process_User_Attrs_Data_PUB;
          ERROR_HANDLER.Get_Message(x_msg_data, x_errorcode, l_entity_id, l_message_type);
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          EXIT;
        END IF;

    END LOOP;

END Process_User_Attrs_Data;


PROCEDURE Get_User_Attrs_Data (
    p_api_version                   IN   NUMBER,
    p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY,
    p_attr_group_request_table      IN   EGO_ATTR_GROUP_REQUEST_TABLE,
    p_user_privileges_on_object     IN   EGO_VARCHAR_TBL_TYPE DEFAULT NULL,
    p_entity_id                     IN   VARCHAR2   DEFAULT NULL,
    p_entity_index                  IN   NUMBER     DEFAULT NULL,
    p_entity_code                   IN   VARCHAR2   DEFAULT NULL,
    p_debug_level                   IN   NUMBER     DEFAULT 0,
    p_init_error_handler            IN   VARCHAR2   DEFAULT NULL,
    p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT NULL,
    p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT NULL,
    x_attributes_row_table          OUT NOCOPY EGO_USER_ATTR_ROW_TABLE,
    x_attributes_data_table         OUT NOCOPY EGO_USER_ATTR_DATA_TABLE,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_errorcode                     OUT NOCOPY NUMBER,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2
) IS
--
-- This version of EGO's UDA Get User Attributes Data API is
-- almost identical to the original version in ego_user_attrs_data_pub
-- with the exception of hardcoding the object name HZ_PARTIES which
-- is the only object name expected when accessing UDA for Supplier
-- related entities.
--
-- Another minor difference is the following optional parameters.  In the
-- original EGO API they are defined as having DEFAULT fnd_api.g_false.
-- This can be finessed as memory is allocated for each even if
-- user skips them.  Now changed to DEFAULT NULL, retaining the same
-- default semantics by NVL in the body.  This is done according to
-- current performance coding standard.
--
--    p_init_error_handler            IN   VARCHAR2   DEFAULT NULL,
--    p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT NULL,
--    p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT NULL,
--
-- Tue Sep  1 09:51:26 PDT 2009 bso R12.1.2
--
BEGIN
    ego_user_attrs_data_pub.get_user_attrs_data(
        p_api_version => p_api_version,
        p_object_name => 'HZ_PARTIES',
        p_pk_column_name_value_pairs => p_pk_column_name_value_pairs,
        p_attr_group_request_table => p_attr_group_request_table,
        p_user_privileges_on_object => p_user_privileges_on_object,
        p_entity_id => p_entity_id,
        p_entity_index => p_entity_index,
        p_entity_code => p_entity_code,
        p_debug_level => p_debug_level,
        p_init_error_handler =>
            nvl(p_init_error_handler, fnd_api.g_false),
        p_init_fnd_msg_list =>
            nvl(p_init_fnd_msg_list, fnd_api.g_false),
        p_add_errors_to_fnd_stack =>
            nvl(p_add_errors_to_fnd_stack, fnd_api.g_false),
        p_commit => fnd_api.g_false,
        x_attributes_row_table => x_attributes_row_table,
        x_attributes_data_table => x_attributes_data_table,
        x_return_status => x_return_status,
        x_errorcode => x_errorcode,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
    );
END Get_User_Attrs_Data;


--
-- End Supplier Hub: Data Publication
--


END POS_VENDOR_PUB_PKG;

/
