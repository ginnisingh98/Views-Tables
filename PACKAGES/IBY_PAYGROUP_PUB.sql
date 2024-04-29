--------------------------------------------------------
--  DDL for Package IBY_PAYGROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_PAYGROUP_PUB" AUTHID CURRENT_USER AS
/*$Header: ibypaygs.pls 120.38.12010000.10 2010/03/11 10:45:25 vkarlapu ship $*/

 --
 -- This record corresponds to a row in the IBY_PAYMENTS_ALL table.
 -- A PLSQL table of these records are created after applying
 -- grouping rules and this table is used in bulk inserting
 -- these payments into the IBY_PAYMENTS_ALL table
 --
 -- The record docsInPaymentRecType holds the documents
 -- corresponding to this payment.
 --
 --
 -- This PLSQL table corresponds to IBY_PAYMENTS_ALL and it
 -- will be used in bulk updating the IBY_PAYMENTS_ALL table.
 --
 --TYPE paymentTabType IS TABLE OF paymentRecType
 --    INDEX BY BINARY_INTEGER;
 TYPE paymentTabType IS TABLE OF IBY_PAYMENTS_ALL%ROWTYPE
     INDEX BY BINARY_INTEGER;

 --
 -- This PLSQL record of tables corresponds to IBY_PAYMENTS_ALL and it
 -- will be used in bulk updating the IBY_PAYMENTS_ALL table.
 --
 TYPE t_payment_id IS TABLE OF
     IBY_PAYMENTS_ALL.payment_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_method_code IS TABLE OF
     IBY_PAYMENTS_ALL.payment_method_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_service_request_id IS TABLE OF
     IBY_PAYMENTS_ALL.payment_service_request_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_process_type IS TABLE OF
     IBY_PAYMENTS_ALL.process_type%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_status IS TABLE OF
     IBY_PAYMENTS_ALL.payment_status%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payments_complete_flag IS TABLE OF
     IBY_PAYMENTS_ALL.payments_complete_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_function IS TABLE OF
     IBY_PAYMENTS_ALL.payment_function%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_amount IS TABLE OF
     IBY_PAYMENTS_ALL.payment_amount%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_currency_code IS TABLE OF
     IBY_PAYMENTS_ALL.payment_currency_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_bill_payable_flag IS TABLE OF
     IBY_PAYMENTS_ALL.bill_payable_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_exclusive_payment_flag IS TABLE OF
     IBY_PAYMENTS_ALL.exclusive_payment_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_sep_remit_advice_req_flag IS TABLE OF
     IBY_PAYMENTS_ALL.separate_remit_advice_req_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_internal_bank_account_id IS TABLE OF
     IBY_PAYMENTS_ALL.internal_bank_account_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_org_id IS TABLE OF
     IBY_PAYMENTS_ALL.org_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_org_type IS TABLE OF
     IBY_PAYMENTS_ALL.org_type%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_legal_entity_id IS TABLE OF
     IBY_PAYMENTS_ALL.legal_entity_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_declare_payment_flag IS TABLE OF
     IBY_PAYMENTS_ALL.declare_payment_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_delivery_channel_code IS TABLE OF
     IBY_PAYMENTS_ALL.delivery_channel_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_ext_payee_id IS TABLE OF
     IBY_PAYMENTS_ALL.ext_payee_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_instruction_id IS TABLE OF
     IBY_PAYMENTS_ALL.payment_instruction_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_profile_id IS TABLE OF
     IBY_PAYMENTS_ALL.payment_profile_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_pregrouped_payment_flag IS TABLE OF
     IBY_PAYMENTS_ALL.pregrouped_payment_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_stop_confirmed_flag IS TABLE OF
     IBY_PAYMENTS_ALL.stop_confirmed_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_stop_released_flag IS TABLE OF
     IBY_PAYMENTS_ALL.stop_released_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_stop_request_placed_flag IS TABLE OF
     IBY_PAYMENTS_ALL.stop_request_placed_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_created_by IS TABLE OF
     IBY_PAYMENTS_ALL.created_by%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_creation_date IS TABLE OF
     IBY_PAYMENTS_ALL.creation_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_last_updated_by IS TABLE OF
     IBY_PAYMENTS_ALL.last_updated_by%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_last_update_login IS TABLE OF
     IBY_PAYMENTS_ALL.last_update_login%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_last_update_date IS TABLE OF
     IBY_PAYMENTS_ALL.last_update_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_object_version_number IS TABLE OF
     IBY_PAYMENTS_ALL.object_version_number%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payee_party_id IS TABLE OF
     IBY_PAYMENTS_ALL.payee_party_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_party_site_id IS TABLE OF
     IBY_PAYMENTS_ALL.party_site_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_supplier_site_id IS TABLE OF
     IBY_PAYMENTS_ALL.supplier_site_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_reason_code IS TABLE OF
     IBY_PAYMENTS_ALL.payment_reason_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_reason_comments IS TABLE OF
     IBY_PAYMENTS_ALL.payment_reason_comments%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_date IS TABLE OF
     IBY_PAYMENTS_ALL.payment_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_anticipated_value_date IS TABLE OF
     IBY_PAYMENTS_ALL.anticipated_value_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_declaration_amount IS TABLE OF
     IBY_PAYMENTS_ALL.declaration_amount%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_declaration_currency_code IS TABLE OF
     IBY_PAYMENTS_ALL.declaration_currency_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_discount_amount_taken IS TABLE OF
     IBY_PAYMENTS_ALL.discount_amount_taken%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_details IS TABLE OF
     IBY_PAYMENTS_ALL.payment_details%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_bank_charge_bearer IS TABLE OF
     IBY_PAYMENTS_ALL.bank_charge_bearer%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_bank_charge_amount IS TABLE OF
     IBY_PAYMENTS_ALL.bank_charge_amount%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_settlement_priority IS TABLE OF
     IBY_PAYMENTS_ALL.settlement_priority%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_remittance_message1 IS TABLE OF
     IBY_PAYMENTS_ALL.remittance_message1%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_remittance_message2 IS TABLE OF
     IBY_PAYMENTS_ALL.remittance_message2%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_remittance_message3 IS TABLE OF
     IBY_PAYMENTS_ALL.remittance_message3%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_reference_number IS TABLE OF
     IBY_PAYMENTS_ALL.payment_reference_number%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_paper_document_number IS TABLE OF
     IBY_PAYMENTS_ALL.paper_document_number%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_bank_assigned_ref_code IS TABLE OF
     IBY_PAYMENTS_ALL.bank_assigned_ref_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_external_bank_account_id IS TABLE OF
     IBY_PAYMENTS_ALL.external_bank_account_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_unique_remittance_identifier IS TABLE OF
     IBY_PAYMENTS_ALL.unique_remittance_identifier%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_uri_check_digit IS TABLE OF
     IBY_PAYMENTS_ALL.uri_check_digit%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_bank_instruction1_code IS TABLE OF
     IBY_PAYMENTS_ALL.bank_instruction1_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_bank_instruction2_code IS TABLE OF
     IBY_PAYMENTS_ALL.bank_instruction2_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_bank_instruction_details IS TABLE OF
     IBY_PAYMENTS_ALL.bank_instruction_details%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_text_message1 IS TABLE OF
     IBY_PAYMENTS_ALL.payment_text_message1%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_text_message2 IS TABLE OF
     IBY_PAYMENTS_ALL.payment_text_message2%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_text_message3 IS TABLE OF
     IBY_PAYMENTS_ALL.payment_text_message3%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_maturity_date IS TABLE OF
     IBY_PAYMENTS_ALL.maturity_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_due_date IS TABLE OF
     IBY_PAYMENTS_ALL.payment_due_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_document_category_code IS TABLE OF
     IBY_PAYMENTS_ALL.document_category_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_document_sequence_id IS TABLE OF
     IBY_PAYMENTS_ALL.document_sequence_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_document_sequence_value IS TABLE OF
     IBY_PAYMENTS_ALL.document_sequence_value%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_beneficiary_party IS TABLE OF
     IBY_PAYMENTS_ALL.beneficiary_party%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_stop_confirmed_by IS TABLE OF
     IBY_PAYMENTS_ALL.stop_confirmed_by%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_stop_confirm_date IS TABLE OF
     IBY_PAYMENTS_ALL.stop_confirm_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_stop_confirm_reason IS TABLE OF
     IBY_PAYMENTS_ALL.stop_confirm_reason%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_stop_confirm_reference IS TABLE OF
     IBY_PAYMENTS_ALL.stop_confirm_reference%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_stop_released_by IS TABLE OF
     IBY_PAYMENTS_ALL.stop_released_by%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_stop_release_date IS TABLE OF
     IBY_PAYMENTS_ALL.stop_release_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_stop_release_reason IS TABLE OF
     IBY_PAYMENTS_ALL.stop_release_reason%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_stop_release_reference IS TABLE OF
     IBY_PAYMENTS_ALL.stop_release_reference%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_stop_request_date IS TABLE OF
     IBY_PAYMENTS_ALL.stop_request_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_stop_request_placed_by IS TABLE OF
     IBY_PAYMENTS_ALL.stop_request_placed_by%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_stop_request_reason IS TABLE OF
     IBY_PAYMENTS_ALL.stop_request_reason%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_stop_request_reference IS TABLE OF
     IBY_PAYMENTS_ALL.stop_request_reference%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_voided_by IS TABLE OF
     IBY_PAYMENTS_ALL.voided_by%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_void_date IS TABLE OF
     IBY_PAYMENTS_ALL.void_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_void_reason IS TABLE OF
     IBY_PAYMENTS_ALL.void_reason%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_remit_to_location_id IS TABLE OF
     IBY_PAYMENTS_ALL.remit_to_location_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_completed_pmts_group_id IS TABLE OF
     IBY_PAYMENTS_ALL.completed_pmts_group_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute_category IS TABLE OF
     IBY_PAYMENTS_ALL.attribute_category%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute1 IS TABLE OF
     IBY_PAYMENTS_ALL.attribute1%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute2 IS TABLE OF
     IBY_PAYMENTS_ALL.attribute2%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute3 IS TABLE OF
     IBY_PAYMENTS_ALL.attribute3%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute4 IS TABLE OF
     IBY_PAYMENTS_ALL.attribute4%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute5 IS TABLE OF
     IBY_PAYMENTS_ALL.attribute5%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute6 IS TABLE OF
     IBY_PAYMENTS_ALL.attribute6%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute7 IS TABLE OF
     IBY_PAYMENTS_ALL.attribute7%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute8 IS TABLE OF
     IBY_PAYMENTS_ALL.attribute8%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute9 IS TABLE OF
     IBY_PAYMENTS_ALL.attribute9%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute10 IS TABLE OF
     IBY_PAYMENTS_ALL.attribute10%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute11 IS TABLE OF
     IBY_PAYMENTS_ALL.attribute11%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute12 IS TABLE OF
     IBY_PAYMENTS_ALL.attribute12%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute13 IS TABLE OF
     IBY_PAYMENTS_ALL.attribute13%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute14 IS TABLE OF
     IBY_PAYMENTS_ALL.attribute14%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute15 IS TABLE OF
     IBY_PAYMENTS_ALL.attribute15%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_ext_branch_number IS TABLE OF
     IBY_PAYMENTS_ALL.ext_branch_number%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_ext_bank_number IS TABLE OF
     IBY_PAYMENTS_ALL.ext_bank_number%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_ext_bank_account_name IS TABLE OF
     IBY_PAYMENTS_ALL.ext_bank_account_name%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_ext_bank_account_number IS TABLE OF
     IBY_PAYMENTS_ALL.ext_bank_account_number%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_ext_bank_account_type IS TABLE OF
     IBY_PAYMENTS_ALL.ext_bank_account_type%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_ext_bank_account_iban_number IS TABLE OF
     IBY_PAYMENTS_ALL.ext_bank_account_iban_number%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payee_name IS TABLE OF
     IBY_PAYMENTS_ALL.payee_name%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payee_address1 IS TABLE OF
     IBY_PAYMENTS_ALL.payee_address1%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payee_address2 IS TABLE OF
     IBY_PAYMENTS_ALL.payee_address2%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payee_address3 IS TABLE OF
     IBY_PAYMENTS_ALL.payee_address3%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payee_address4 IS TABLE OF
     IBY_PAYMENTS_ALL.payee_address4%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payee_city IS TABLE OF
     IBY_PAYMENTS_ALL.payee_city%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payee_postal_code IS TABLE OF
     IBY_PAYMENTS_ALL.payee_postal_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payee_state IS TABLE OF
     IBY_PAYMENTS_ALL.payee_state%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payee_province IS TABLE OF
     IBY_PAYMENTS_ALL.payee_province%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payee_county IS TABLE OF
     IBY_PAYMENTS_ALL.payee_county%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payee_country IS TABLE OF
     IBY_PAYMENTS_ALL.payee_country%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_remit_advice_delivery_method IS TABLE OF
     IBY_PAYMENTS_ALL.remit_advice_delivery_method%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_remit_advice_email IS TABLE OF
     IBY_PAYMENTS_ALL.remit_advice_email%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_remit_advice_fax IS TABLE OF
     IBY_PAYMENTS_ALL.remit_advice_fax%TYPE
     INDEX BY BINARY_INTEGER;


/*TPP-Start*/
TYPE t_ext_inv_payee_id IS TABLE OF
     IBY_PAYMENTS_ALL.ext_inv_payee_id%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_party_id IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_party_id%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_party_site_id IS TABLE OF
     IBY_PAYMENTS_ALL.inv_party_site_id%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_supplier_site_id IS TABLE OF
     IBY_PAYMENTS_ALL.inv_supplier_site_id%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_beneficiary_party IS TABLE OF
     IBY_PAYMENTS_ALL.inv_beneficiary_party%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_name IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_name%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_address1 IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_address1%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_address2 IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_address2%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_address3 IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_address3%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_address4 IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_address4%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_city IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_city%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_postal_code IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_postal_code%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_state IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_state%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_province IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_province%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_county IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_county%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_country IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_country%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_party_name IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_party_name%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_le_reg_num IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_le_reg_num%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_tax_reg_num IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_tax_reg_num%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_address_concat IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_address_concat%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_beneficiary_name IS TABLE OF
     IBY_PAYMENTS_ALL.inv_beneficiary_name%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_party_number IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_party_number%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_alternate_name IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_alternate_name%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_site_alt_name IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_site_alt_name%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_supplier_number IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_supplier_number%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_first_party_ref IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_first_party_ref%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_ext_acct_ownr_inv_prty_id IS TABLE OF
     IBY_PAYMENTS_ALL.ext_bnk_acct_ownr_inv_prty_id%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_ext_bnk_branch_inv_prty_id IS TABLE OF
     IBY_PAYMENTS_ALL.ext_bnk_branch_inv_prty_id%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_ext_acct_ownr_inv_prty_nme IS TABLE OF
     IBY_PAYMENTS_ALL.ext_bnk_acct_ownr_inv_prty_nme%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_party_attr_cat IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_party_attr_cat%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_supplier_attr_cat IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_supplier_attr_cat%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_site_attr_cat IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_spplr_site_attr_cat%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_supplier_site_name IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_supplier_site_name%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_spp_site_alt_name IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_spplr_site_alt_name%TYPE
     INDEX BY BINARY_INTEGER;
TYPE t_inv_payee_supplier_id IS TABLE OF
     IBY_PAYMENTS_ALL.inv_payee_supplier_id%TYPE
     INDEX BY BINARY_INTEGER;
/*TPP-End*/

 /*
  * (Stealth) Fix for bug 5475920:
  *
  * Ensure that employee related fields are populated in the
  * payment record.
  */
 TYPE t_address_source IS TABLE OF
     IBY_PAYMENTS_ALL.address_source%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_employee_address_code IS TABLE OF
     IBY_PAYMENTS_ALL.employee_address_code%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_employee_person_id IS TABLE OF
     IBY_PAYMENTS_ALL.employee_person_id%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_employee_address_id IS TABLE OF
     IBY_PAYMENTS_ALL.employee_address_id%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_employee_payment_flag IS TABLE OF
     IBY_PAYMENTS_ALL.employee_payment_flag%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_calling_app_id IS TABLE OF
     IBY_HOOK_PAYMENTS_T.calling_app_id%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_call_app_pay_service_req_cd IS TABLE OF
     IBY_HOOK_PAYMENTS_T.call_app_pay_service_req_code%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_dont_pay_flg IS TABLE OF
     IBY_HOOK_DOCS_IN_PMT_T.dont_pay_flag%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_dont_pay_reason_cd IS TABLE OF
     IBY_HOOK_DOCS_IN_PMT_T.dont_pay_reason_code%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_dont_pay_desc IS TABLE OF
     IBY_HOOK_DOCS_IN_PMT_T.dont_pay_description%TYPE
     INDEX BY BINARY_INTEGER;


TYPE t_remit_advice_req_flg IS TABLE OF
     IBY_HOOK_DOCS_IN_PMT_T.dont_pay_flag%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_payer_party_number IS TABLE OF
     IBY_PAYMENTS_ALL.PAYER_PARTY_NUMBER%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_payer_party_site_name IS TABLE OF
     IBY_PAYMENTS_ALL.PAYER_PARTY_SITE_NAME%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_payer_legal_entity_name IS TABLE OF
     IBY_PAYMENTS_ALL.PAYER_LEGAL_ENTITY_NAME%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_payer_tax_registration_num IS TABLE OF
     IBY_PAYMENTS_ALL.PAYER_TAX_REGISTRATION_NUM%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_payer_le_registration_num IS TABLE OF
     IBY_PAYMENTS_ALL.PAYER_LE_REGISTRATION_NUM%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_payer_party_id IS TABLE OF
     IBY_PAYMENTS_ALL.PAYER_PARTY_ID%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_payer_location_id IS TABLE OF
     IBY_PAYMENTS_ALL.PAYER_LOCATION_ID%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_payer_party_attr_category IS TABLE OF
     IBY_PAYMENTS_ALL.PAYER_PARTY_ATTR_CATEGORY%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_payer_le_attr_category IS TABLE OF
     IBY_PAYMENTS_ALL.PAYER_LE_ATTR_CATEGORY%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_payer_abbr_agency_code IS TABLE OF
     IBY_PAYMENTS_ALL.PAYER_ABBREVIATED_AGENCY_CODE%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_payer_federal_us_employer_id IS TABLE OF
     IBY_PAYMENTS_ALL.PAYER_FEDERAL_US_EMPLOYER_ID%TYPE
     INDEX BY BINARY_INTEGER;



TYPE t_int_bank_name IS TABLE OF
     IBY_PAYMENTS_ALL.INT_BANK_NAME%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_int_bank_number IS TABLE OF
     IBY_PAYMENTS_ALL.INT_BANK_NUMBER%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_int_bank_branch_number IS TABLE OF
     IBY_PAYMENTS_ALL.INT_BANK_BRANCH_NUMBER%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_int_bank_branch_name IS TABLE OF
     IBY_PAYMENTS_ALL.INT_BANK_BRANCH_NAME%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_int_eft_swift_code IS TABLE OF
     IBY_PAYMENTS_ALL.INT_EFT_SWIFT_CODE%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_int_bank_account_number IS TABLE OF
     IBY_PAYMENTS_ALL.INT_BANK_ACCOUNT_NUMBER%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_int_bank_account_name IS TABLE OF
     IBY_PAYMENTS_ALL.INT_BANK_ACCOUNT_NAME%TYPE
     INDEX BY BINARY_INTEGER;


TYPE t_int_bank_account_iban IS TABLE OF
     IBY_PAYMENTS_ALL.INT_BANK_ACCOUNT_IBAN%TYPE
     INDEX BY BINARY_INTEGER;


TYPE t_int_bank_acct_ag_loc_code IS TABLE OF
     IBY_PAYMENTS_ALL.INT_BANK_ACCT_AGENCY_LOC_CODE%TYPE
     INDEX BY BINARY_INTEGER;


TYPE t_int_bank_branch_party_id IS TABLE OF
     IBY_PAYMENTS_ALL.INT_BANK_BRANCH_PARTY_ID%TYPE
     INDEX BY BINARY_INTEGER;


TYPE t_int_bank_alt_name IS TABLE OF
     IBY_PAYMENTS_ALL.INT_BANK_ALT_NAME%TYPE
     INDEX BY BINARY_INTEGER;


TYPE t_int_bank_branch_alt_name IS TABLE OF
     IBY_PAYMENTS_ALL.INT_BANK_BRANCH_ALT_NAME%TYPE
     INDEX BY BINARY_INTEGER;


TYPE t_int_bank_account_alt_name IS TABLE OF
     IBY_PAYMENTS_ALL.INT_BANK_ACCOUNT_ALT_NAME%TYPE
     INDEX BY BINARY_INTEGER;


TYPE t_int_bank_account_num_elec IS TABLE OF
     IBY_PAYMENTS_ALL.INT_BANK_ACCOUNT_NUM_ELEC%TYPE
     INDEX BY BINARY_INTEGER;


TYPE t_int_bank_branch_location_id IS TABLE OF
     IBY_PAYMENTS_ALL.INT_BANK_BRANCH_LOCATION_ID%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_int_bank_branch_eft_user_num IS TABLE OF
     IBY_PAYMENTS_ALL.INT_BANK_BRANCH_EFT_USER_NUM%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_int_bank_branch_rfc_id IS TABLE OF
     IBY_PAYMENTS_ALL.INT_BANK_BRANCH_RFC_IDENTIFIER%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_payee_site_alt_name IS TABLE OF
     IBY_PAYMENTS_ALL.PAYEE_SITE_ALTERNATE_NAME%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_payee_supplier_number IS TABLE OF
     IBY_PAYMENTS_ALL.PAYEE_SUPPLIER_NUMBER%TYPE
     INDEX BY BINARY_INTEGER;


TYPE t_payee_first_party_ref IS TABLE OF
     IBY_PAYMENTS_ALL.PAYEE_FIRST_PARTY_REFERENCE%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_payee_supp_attr_categ IS TABLE OF
     IBY_PAYMENTS_ALL.payee_supplier_attr_category%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_payee_supplier_id IS TABLE OF
     IBY_PAYMENTS_ALL.payee_supplier_id%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_payee_tax_reg_num IS TABLE OF
     IBY_PAYMENTS_ALL.payee_tax_registration_num%TYPE
     INDEX BY BINARY_INTEGER;


TYPE t_payee_le_reg_num IS TABLE OF
     IBY_PAYMENTS_ALL.payee_le_registration_num%TYPE
     INDEX BY BINARY_INTEGER;



TYPE t_payee_spplr_site_attr_categ IS TABLE OF
     IBY_PAYMENTS_ALL.payee_spplr_site_attr_category%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_payee_supplier_site_name IS TABLE OF
     IBY_PAYMENTS_ALL.payee_supplier_site_name%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_ext_bank_name IS TABLE OF
     IBY_PAYMENTS_ALL.ext_bank_name%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_ext_bank_branch_name IS TABLE OF
     IBY_PAYMENTS_ALL.ext_bank_branch_name%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_ext_eft_swift_code IS TABLE OF
     IBY_PAYMENTS_ALL.ext_eft_swift_code%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_ext_bnk_acct_factor_flag IS TABLE OF
     IBY_PAYMENTS_ALL.ext_bank_acct_pmt_factor_flag%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_ext_bank_acct_owner_party_id IS TABLE OF
     IBY_PAYMENTS_ALL.ext_bank_acct_owner_party_id%TYPE
     INDEX BY BINARY_INTEGER;


TYPE t_ext_bank_branch_party_id IS TABLE OF
     IBY_PAYMENTS_ALL.ext_bank_branch_party_id%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_ext_bank_alt_name IS TABLE OF
     IBY_PAYMENTS_ALL.ext_bank_alt_name%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_ext_bank_branch_alt_name IS TABLE OF
     IBY_PAYMENTS_ALL.ext_bank_branch_alt_name%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_ext_bank_account_alt_name IS TABLE OF
     IBY_PAYMENTS_ALL.ext_bank_account_alt_name%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_ext_bank_account_num_elec IS TABLE OF
     IBY_PAYMENTS_ALL.ext_bank_account_num_elec%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_ext_bank_branch_location_id IS TABLE OF
     IBY_PAYMENTS_ALL.ext_bank_branch_location_id%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_ext_acct_owner_party_name IS TABLE OF
     IBY_PAYMENTS_ALL.ext_bank_acct_owner_party_name%TYPE
     INDEX BY BINARY_INTEGER;



TYPE t_payee_address_concat IS TABLE OF
     IBY_PAYMENTS_ALL.payee_address_concat%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_declaration_exch_rate_type IS TABLE OF
     IBY_PAYMENTS_ALL.declaration_exch_rate_type%TYPE
     INDEX BY BINARY_INTEGER;


TYPE t_declaration_format IS TABLE OF
     IBY_PAYMENTS_ALL.declaration_format%TYPE
     INDEX BY BINARY_INTEGER;


TYPE t_bank_instr1_format_value IS TABLE OF
     IBY_PAYMENTS_ALL.bank_instruction1_format_value%TYPE
     INDEX BY BINARY_INTEGER;


TYPE t_bank_instr2_format_value IS TABLE OF
     IBY_PAYMENTS_ALL.bank_instruction2_format_value%TYPE
     INDEX BY BINARY_INTEGER;


TYPE t_payment_profile_acct_name IS TABLE OF
     IBY_PAYMENTS_ALL.payment_profile_acct_name%TYPE
     INDEX BY BINARY_INTEGER;


TYPE t_payment_profile_sys_name IS TABLE OF
     IBY_PAYMENTS_ALL.payment_profile_sys_name%TYPE
     INDEX BY BINARY_INTEGER;


 TYPE t_payment_reason_format_value IS TABLE OF
     IBY_PAYMENTS_ALL.payment_reason_format_value%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_payment_process_request_name IS TABLE OF
     IBY_PAYMENTS_ALL.payment_process_request_name%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_org_name IS TABLE OF
     IBY_PAYMENTS_ALL.org_name%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_del_channel_format_value IS TABLE OF
     IBY_PAYMENTS_ALL.DELIVERY_CHANNEL_FORMAT_VALUE%TYPE
     INDEX BY BINARY_INTEGER;


  TYPE t_source_product IS TABLE OF
     IBY_PAYMENTS_ALL.source_product%TYPE
     INDEX BY BINARY_INTEGER;

  TYPE t_payee_party_number IS TABLE OF
     IBY_PAYMENTS_ALL.payee_party_number%TYPE
     INDEX BY BINARY_INTEGER;

  TYPE t_payee_party_name IS TABLE OF
     IBY_PAYMENTS_ALL.payee_party_name%TYPE
     INDEX BY BINARY_INTEGER;

   TYPE t_payee_alt_name IS TABLE OF
     IBY_PAYMENTS_ALL.PAYEE_ALTERNATE_NAME%TYPE
     INDEX BY BINARY_INTEGER;

TYPE t_payee_party_atr_cat IS TABLE OF
IBY_PAYMENTS_ALL.payee_party_attr_category%TYPE
INDEX BY BINARY_INTEGER;

TYPE t_payee_addressee IS TABLE OF       -- not to be used on B-o-B for ATT
        IBY_PAYMENTS_ALL.payee_addressee%TYPE
INDEX BY BINARY_INTEGER;


 TYPE payment_tab_type IS RECORD
(
 payment_id                                t_payment_id,
 payment_method_code                       t_payment_method_code,
 payment_service_request_id                t_payment_service_request_id,
 process_type                              t_process_type,
 payment_status                            t_payment_status,
 payments_complete_flag                    t_payments_complete_flag,
 payment_function                          t_payment_function,
 payment_amount                            t_payment_amount,
 payment_currency_code                     t_payment_currency_code,
 bill_payable_flag                         t_bill_payable_flag,
 exclusive_payment_flag                    t_exclusive_payment_flag,
 sep_remit_advice_req_flag                 t_sep_remit_advice_req_flag,
 internal_bank_account_id                  t_internal_bank_account_id,
 org_id                                    t_org_id,
 org_type                                  t_org_type,
 legal_entity_id                           t_legal_entity_id,
 declare_payment_flag                      t_declare_payment_flag,
 delivery_channel_code                     t_delivery_channel_code,
 ext_payee_id                              t_ext_payee_id,
 payment_instruction_id                    t_payment_instruction_id,
 payment_profile_id                        t_payment_profile_id,
 pregrouped_payment_flag                   t_pregrouped_payment_flag,
 stop_confirmed_flag                       t_stop_confirmed_flag,
 stop_released_flag                        t_stop_released_flag,
 stop_request_placed_flag                  t_stop_request_placed_flag,
 created_by                                t_created_by,
 creation_date                             t_creation_date,
 last_updated_by                           t_last_updated_by,
 last_update_login                         t_last_update_login,
 last_update_date                          t_last_update_date,
 object_version_number                     t_object_version_number,
 payee_party_id                            t_payee_party_id,
 party_site_id                             t_party_site_id,
 supplier_site_id                          t_supplier_site_id,
 payment_reason_code                       t_payment_reason_code,
 payment_reason_comments                   t_payment_reason_comments,
 payment_date                              t_payment_date,
 anticipated_value_date                    t_anticipated_value_date,
 declaration_amount                        t_declaration_amount,
 declaration_currency_code                 t_declaration_currency_code,
 discount_amount_taken                     t_discount_amount_taken,
 payment_details                           t_payment_details,
 bank_charge_bearer                        t_bank_charge_bearer,
 bank_charge_amount                        t_bank_charge_amount,
 settlement_priority                       t_settlement_priority,
 remittance_message1                       t_remittance_message1,
 remittance_message2                       t_remittance_message2,
 remittance_message3                       t_remittance_message3,
 payment_reference_number                  t_payment_reference_number,
 paper_document_number                     t_paper_document_number,
 bank_assigned_ref_code                    t_bank_assigned_ref_code,
 external_bank_account_id                  t_external_bank_account_id,
 unique_remittance_identifier              t_unique_remittance_identifier,
 uri_check_digit                           t_uri_check_digit,
 bank_instruction1_code                    t_bank_instruction1_code,
 bank_instruction2_code                    t_bank_instruction2_code,
 bank_instruction_details                  t_bank_instruction_details,
 payment_text_message1                     t_payment_text_message1,
 payment_text_message2                     t_payment_text_message2,
 payment_text_message3                     t_payment_text_message3,
 maturity_date                             t_maturity_date,
 payment_due_date                          t_payment_due_date,
 document_category_code                    t_document_category_code,
 document_sequence_id                      t_document_sequence_id,
 document_sequence_value                   t_document_sequence_value,
 beneficiary_party                         t_beneficiary_party,
 stop_confirmed_by                         t_stop_confirmed_by,
 stop_confirm_date                         t_stop_confirm_date,
 stop_confirm_reason                       t_stop_confirm_reason,
 stop_confirm_reference                    t_stop_confirm_reference,
 stop_released_by                          t_stop_released_by,
 stop_release_date                         t_stop_release_date,
 stop_release_reason                       t_stop_release_reason,
 stop_release_reference                    t_stop_release_reference,
 stop_request_date                         t_stop_request_date,
 stop_request_placed_by                    t_stop_request_placed_by,
 stop_request_reason                       t_stop_request_reason,
 stop_request_reference                    t_stop_request_reference,
 voided_by                                 t_voided_by,
 void_date                                 t_void_date,
 void_reason                               t_void_reason,
 remit_to_location_id                      t_remit_to_location_id,
 completed_pmts_group_id                   t_completed_pmts_group_id,
 attribute_category                        t_attribute_category,
 attribute1                                t_attribute1,
 attribute2                                t_attribute2,
 attribute3                                t_attribute3,
 attribute4                                t_attribute4,
 attribute5                                t_attribute5,
 attribute6                                t_attribute6,
 attribute7                                t_attribute7,
 attribute8                                t_attribute8,
 attribute9                                t_attribute9,
 attribute10                               t_attribute10,
 attribute11                               t_attribute11,
 attribute12                               t_attribute12,
 attribute13                               t_attribute13,
 attribute14                               t_attribute14,
 attribute15                               t_attribute15,
 ext_branch_number                         t_ext_branch_number,
 ext_bank_number                           t_ext_bank_number,
 ext_bank_account_name                     t_ext_bank_account_name,
 ext_bank_account_number                   t_ext_bank_account_number,
 ext_bank_account_type                     t_ext_bank_account_type,
 ext_bank_account_iban_number              t_ext_bank_account_iban_number,
 payee_name                                t_payee_name,
 payee_address1                            t_payee_address1,
 payee_address2                            t_payee_address2,
 payee_address3                            t_payee_address3,
 payee_address4                            t_payee_address4,
 payee_city                                t_payee_city,
 payee_postal_code                         t_payee_postal_code,
 payee_state                               t_payee_state,
 payee_province                            t_payee_province,
 payee_county                              t_payee_county,
 payee_country                             t_payee_country,
 remit_advice_delivery_method              t_remit_advice_delivery_method,
 remit_advice_email                        t_remit_advice_email,
 remit_advice_fax                          t_remit_advice_fax,
 address_source                            t_address_source,
 employee_address_code                     t_employee_address_code,
 employee_person_id                        t_employee_person_id,
 employee_address_id                       t_employee_address_id,
 employee_payment_flag                     t_employee_payment_flag,
 calling_app_id                            t_calling_app_id,
 call_app_pay_service_req_cd               t_call_app_pay_service_req_cd,
 dont_pay_flg                              t_dont_pay_flg,
 dont_pay_reason_cd                        t_dont_pay_reason_cd,
 dont_pay_desc                             t_dont_pay_desc,
 /*TPP-Start*/
ext_inv_payee_id 	t_ext_inv_payee_id ,
inv_payee_party_id 	t_inv_payee_party_id ,
inv_party_site_id 	t_inv_party_site_id ,
inv_supplier_site_id 	t_inv_supplier_site_id ,
inv_beneficiary_party 	t_inv_beneficiary_party ,
inv_payee_name 	t_inv_payee_name ,
inv_payee_address1 	t_inv_payee_address1 ,
inv_payee_address2 	t_inv_payee_address2 ,
inv_payee_address3 	t_inv_payee_address3 ,
inv_payee_address4 	t_inv_payee_address4 ,
inv_payee_city 	t_inv_payee_city ,
inv_payee_postal_code 	t_inv_payee_postal_code ,
inv_payee_state 	t_inv_payee_state ,
inv_payee_province 	t_inv_payee_province ,
inv_payee_county 	t_inv_payee_county ,
inv_payee_country 	t_inv_payee_country ,
inv_payee_party_name 	t_inv_payee_party_name ,
inv_payee_le_reg_num	t_inv_payee_le_reg_num,
inv_payee_tax_reg_num	t_inv_payee_tax_reg_num,
inv_payee_address_concat 	t_inv_payee_address_concat ,
inv_beneficiary_name 	t_inv_beneficiary_name ,
inv_payee_party_number 	t_inv_payee_party_number ,
inv_payee_alternate_name 	t_inv_payee_alternate_name ,
inv_payee_site_alt_name	t_inv_payee_site_alt_name,
inv_payee_supplier_number 	t_inv_payee_supplier_number ,
inv_payee_first_party_ref	t_inv_payee_first_party_ref,
ext_bnk_acct_ownr_inv_prty_id	t_ext_acct_ownr_inv_prty_id,
ext_bnk_branch_inv_prty_id	t_ext_bnk_branch_inv_prty_id,
ext_bnk_acct_ownr_inv_prty_nme	t_ext_acct_ownr_inv_prty_nme,
inv_payee_party_attr_cat	t_inv_payee_party_attr_cat,
inv_payee_supplier_attr_cat	t_inv_payee_supplier_attr_cat,
inv_payee_spplr_site_attr_cat	t_inv_payee_site_attr_cat,
inv_payee_supplier_site_name 	t_inv_payee_supplier_site_name,
inv_payee_spplr_site_alt_name 	t_inv_payee_spp_site_alt_name,
inv_payee_supplier_id 	t_inv_payee_supplier_id
/*TPP-End*/

 );

 paymentTab                               payment_tab_type;
 --pmtTable                                 payment_tab_type;



TYPE pmtTable_type IS RECORD
(
 payment_id                                t_payment_id,
 payment_method_code                       t_payment_method_code,
 payment_service_request_id                t_payment_service_request_id,
 process_type                              t_process_type,
 payment_status                            t_payment_status,
 payments_complete_flag                    t_payments_complete_flag,
 payment_function                          t_payment_function,
 payment_amount                            t_payment_amount,
 payment_currency_code                     t_payment_currency_code,
 bill_payable_flag                         t_bill_payable_flag,
 exclusive_payment_flag                    t_exclusive_payment_flag,
 sep_remit_advice_req_flag                 t_sep_remit_advice_req_flag,
 internal_bank_account_id                  t_internal_bank_account_id,
 org_id                                    t_org_id,
 org_type                                  t_org_type,
 legal_entity_id                           t_legal_entity_id,
 declare_payment_flag                      t_declare_payment_flag,
 delivery_channel_code                     t_delivery_channel_code,
 ext_payee_id                              t_ext_payee_id,
 payment_instruction_id                    t_payment_instruction_id,
 payment_profile_id                        t_payment_profile_id,
 pregrouped_payment_flag                   t_pregrouped_payment_flag,
 stop_confirmed_flag                       t_stop_confirmed_flag,
 stop_released_flag                        t_stop_released_flag,
 stop_request_placed_flag                  t_stop_request_placed_flag,
 created_by                                t_created_by,
 creation_date                             t_creation_date,
 last_updated_by                           t_last_updated_by,
 last_update_login                         t_last_update_login,
 last_update_date                          t_last_update_date,
 object_version_number                     t_object_version_number,
 payee_party_id                            t_payee_party_id,
 party_site_id                             t_party_site_id,
 supplier_site_id                          t_supplier_site_id,
 payment_reason_code                       t_payment_reason_code,
 payment_reason_comments                   t_payment_reason_comments,
 payment_date                              t_payment_date,
 anticipated_value_date                    t_anticipated_value_date,
 declaration_amount                        t_declaration_amount,
 declaration_currency_code                 t_declaration_currency_code,
 discount_amount_taken                     t_discount_amount_taken,
 payment_details                           t_payment_details,
 bank_charge_bearer                        t_bank_charge_bearer,
 bank_charge_amount                        t_bank_charge_amount,
 settlement_priority                       t_settlement_priority,
 remittance_message1                       t_remittance_message1,
 remittance_message2                       t_remittance_message2,
 remittance_message3                       t_remittance_message3,
 payment_reference_number                  t_payment_reference_number,
 paper_document_number                     t_paper_document_number,
 bank_assigned_ref_code                    t_bank_assigned_ref_code,
 external_bank_account_id                  t_external_bank_account_id,
 unique_remittance_identifier              t_unique_remittance_identifier,
 uri_check_digit                           t_uri_check_digit,
 bank_instruction1_code                    t_bank_instruction1_code,
 bank_instruction2_code                    t_bank_instruction2_code,
 bank_instruction_details                  t_bank_instruction_details,
 payment_text_message1                     t_payment_text_message1,
 payment_text_message2                     t_payment_text_message2,
 payment_text_message3                     t_payment_text_message3,
 maturity_date                             t_maturity_date,
 payment_due_date                          t_payment_due_date,
 document_category_code                    t_document_category_code,
 document_sequence_id                      t_document_sequence_id,
 document_sequence_value                   t_document_sequence_value,
 beneficiary_party                         t_beneficiary_party,
 stop_confirmed_by                         t_stop_confirmed_by,
 stop_confirm_date                         t_stop_confirm_date,
 stop_confirm_reason                       t_stop_confirm_reason,
 stop_confirm_reference                    t_stop_confirm_reference,
 stop_released_by                          t_stop_released_by,
 stop_release_date                         t_stop_release_date,
 stop_release_reason                       t_stop_release_reason,
 stop_release_reference                    t_stop_release_reference,
 stop_request_date                         t_stop_request_date,
 stop_request_placed_by                    t_stop_request_placed_by,
 stop_request_reason                       t_stop_request_reason,
 stop_request_reference                    t_stop_request_reference,
 voided_by                                 t_voided_by,
 void_date                                 t_void_date,
 void_reason                               t_void_reason,
 remit_to_location_id                      t_remit_to_location_id,
 completed_pmts_group_id                   t_completed_pmts_group_id,
 attribute_category                        t_attribute_category,
 attribute1                                t_attribute1,
 attribute2                                t_attribute2,
 attribute3                                t_attribute3,
 attribute4                                t_attribute4,
 attribute5                                t_attribute5,
 attribute6                                t_attribute6,
 attribute7                                t_attribute7,
 attribute8                                t_attribute8,
 attribute9                                t_attribute9,
 attribute10                               t_attribute10,
 attribute11                               t_attribute11,
 attribute12                               t_attribute12,
 attribute13                               t_attribute13,
 attribute14                               t_attribute14,
 attribute15                               t_attribute15,
 ext_branch_number                         t_ext_branch_number,
 ext_bank_number                           t_ext_bank_number,
 ext_bank_account_name                     t_ext_bank_account_name,
 ext_bank_account_number                   t_ext_bank_account_number,
 ext_bank_account_type                     t_ext_bank_account_type,
 ext_bank_account_iban_number              t_ext_bank_account_iban_number,
 payee_party_number	                   t_payee_party_number,
 payee_party_name 			   t_payee_party_name,

 payee_name                                t_payee_name,
 payee_alt_name			           t_payee_alt_name,
 payee_address1                            t_payee_address1,
 payee_address2                            t_payee_address2,
 payee_address3                            t_payee_address3,
 payee_address4                            t_payee_address4,
 payee_city                                t_payee_city,
 payee_postal_code                         t_payee_postal_code,
 payee_state                               t_payee_state,
 payee_province                            t_payee_province,
 payee_county                              t_payee_county,
 payee_country                             t_payee_country,
-- separate_remit_advice_req_flag            t_remit_advice_req_flg,
 remit_advice_delivery_method              t_remit_advice_delivery_method,
 remit_advice_email                        t_remit_advice_email,
 remit_advice_fax                          t_remit_advice_fax,
 address_source                            t_address_source,
 employee_address_code                     t_employee_address_code,
 employee_person_id                        t_employee_person_id,
 employee_address_id                       t_employee_address_id,
 employee_payment_flag                     t_employee_payment_flag,
 payer_party_number                        t_payer_party_number,
 payer_party_site_name			   t_payer_party_site_name,
 payer_legal_entity_name		   t_payer_legal_entity_name,
 payer_tax_registration_num		   t_payer_tax_registration_num,
 payer_le_registration_num		   t_payer_le_registration_num,
 payer_party_id				   t_payer_party_id,
 payer_location_id			   t_payer_location_id,
 payer_party_attr_category		   t_payer_party_attr_category,
 payer_le_attr_category			   t_payer_le_attr_category,
 payer_abbreviated_agency_code		   t_payer_abbr_agency_code,
 payer_federal_us_employer_id		   t_payer_federal_us_employer_id,
 int_bank_name				   t_int_bank_name,
 int_bank_number			   t_int_bank_number,
 int_bank_branch_number			   t_int_bank_branch_number,
 int_bank_branch_name			   t_int_bank_branch_name,
 int_eft_swift_code			   t_int_eft_swift_code,
 int_bank_account_number		   t_int_bank_account_number,
 int_bank_account_name			   t_int_bank_account_name,
 int_bank_account_iban			   t_int_bank_account_iban,
 int_bank_acct_agency_loc_code		   t_int_bank_acct_ag_loc_code,
 int_bank_branch_party_id		   t_int_bank_branch_party_id,
 int_bank_alt_name			   t_int_bank_alt_name,
 int_bank_branch_alt_name		   t_int_bank_branch_alt_name,
 int_bank_account_alt_name		   t_int_bank_account_alt_name,
 int_bank_account_num_elec		   t_int_bank_account_num_elec,
 int_bank_branch_location_id		   t_int_bank_branch_location_id,
 int_bank_branch_eft_user_num		   t_int_bank_branch_eft_user_num,
 int_bank_branch_rfc_identifier		   t_int_bank_branch_rfc_id,

 payee_site_alternate_name		   t_payee_site_alt_name,
 payee_supplier_number			   t_payee_supplier_number,
 payee_first_party_reference		   t_payee_first_party_ref,
 payee_supplier_attr_category		   t_payee_supp_attr_categ,
 payee_addressee			   t_payee_addressee,
 payee_supplier_id			   t_payee_supplier_id,
 payee_tax_registration_num		   t_payee_tax_reg_num,
 payee_le_registration_num		   t_payee_le_reg_num,

 payee_spplr_site_attr_category            t_payee_spplr_site_attr_categ,
 payee_supplier_site_name                  t_payee_supplier_site_name,
 payee_party_atr_cat                       t_payee_party_atr_cat,
 beneficiary_name        t_inv_beneficiary_name,
 ext_bank_name				   t_ext_bank_name,
 ext_bank_branch_name			   t_ext_bank_branch_name,
 ext_eft_swift_code			   t_ext_eft_swift_code,
 ext_bank_acct_pmt_factor_flag		   t_ext_bnk_acct_factor_flag,
 ext_bank_acct_owner_party_id		   t_ext_bank_acct_owner_party_id,
 ext_bank_branch_party_id		   t_ext_bank_branch_party_id,
 ext_bank_alt_name			   t_ext_bank_alt_name,
 ext_bank_branch_alt_name		   t_ext_bank_branch_alt_name,
 ext_bank_account_alt_name		   t_ext_bank_account_alt_name,
 ext_bank_account_num_elec		   t_ext_bank_account_num_elec,
 ext_bank_branch_location_id		   t_ext_bank_branch_location_id,
 ext_bank_acct_owner_party_name		   t_ext_acct_owner_party_name,
 payee_address_concat                     t_payee_address_concat,

 		declaration_exch_rate_type	t_declaration_exch_rate_type,
		declaration_format		t_declaration_format,
		bank_instruction1_format_value	t_bank_instr1_format_value,
		bank_instruction2_format_value	t_bank_instr2_format_value,
		payment_profile_acct_name	t_payment_profile_acct_name,
		payment_profile_sys_name	t_payment_profile_sys_name,
    payment_reason_format_value   t_payment_reason_format_value,
    delivery_channel_format_value t_del_channel_format_value,
    payment_process_request_name  t_payment_process_request_name,
    source_product                t_source_product,
    org_name                      t_org_name,
    calling_app_id                            t_calling_app_id,
 call_app_pay_service_req_cd               t_call_app_pay_service_req_cd,
 dont_pay_flg                              t_dont_pay_flg,
 dont_pay_reason_cd                        t_dont_pay_reason_cd,
 dont_pay_desc                             t_dont_pay_desc,
 /*TPP-Start*/
ext_inv_payee_id 	t_ext_inv_payee_id ,
inv_payee_party_id 	t_inv_payee_party_id ,
inv_party_site_id 	t_inv_party_site_id ,
inv_supplier_site_id 	t_inv_supplier_site_id ,
inv_beneficiary_party 	t_inv_beneficiary_party ,
inv_payee_name 	t_inv_payee_name ,
inv_payee_address1 	t_inv_payee_address1 ,
inv_payee_address2 	t_inv_payee_address2 ,
inv_payee_address3 	t_inv_payee_address3 ,
inv_payee_address4 	t_inv_payee_address4 ,
inv_payee_city 	t_inv_payee_city ,
inv_payee_postal_code 	t_inv_payee_postal_code ,
inv_payee_state 	t_inv_payee_state ,
inv_payee_province 	t_inv_payee_province ,
inv_payee_county 	t_inv_payee_county ,
inv_payee_country 	t_inv_payee_country ,
inv_payee_party_name 	t_inv_payee_party_name ,
inv_payee_le_reg_num	t_inv_payee_le_reg_num,
inv_payee_tax_reg_num	t_inv_payee_tax_reg_num,
inv_payee_address_concat 	t_inv_payee_address_concat ,
inv_beneficiary_name 	t_inv_beneficiary_name ,
inv_payee_party_number 	t_inv_payee_party_number ,
inv_payee_alternate_name 	t_inv_payee_alternate_name ,
inv_payee_site_alt_name	t_inv_payee_site_alt_name,
inv_payee_supplier_number 	t_inv_payee_supplier_number ,
inv_payee_first_party_ref	t_inv_payee_first_party_ref,
ext_bnk_acct_ownr_inv_prty_id	t_ext_acct_ownr_inv_prty_id,
ext_bnk_branch_inv_prty_id	t_ext_bnk_branch_inv_prty_id,
ext_bnk_acct_ownr_inv_prty_nme	t_ext_acct_ownr_inv_prty_nme,
inv_payee_party_attr_cat	t_inv_payee_party_attr_cat,
inv_payee_supplier_attr_cat	t_inv_payee_supplier_attr_cat,
inv_payee_spplr_site_attr_cat	t_inv_payee_site_attr_cat,
inv_payee_supplier_site_name 	t_inv_payee_supplier_site_name,
inv_payee_spplr_site_alt_name 	t_inv_payee_spp_site_alt_name,
inv_payee_supplier_id 	t_inv_payee_supplier_id
/*TPP-End*/

 );

  pmtTable            pmtTable_type;





TYPE commonAttributesTabType IS RECORD
(
due_date_common_flag VARCHAR2(1),
delv_chnl_common_flag VARCHAR2(1),
uri_common_flag VARCHAR2(1),
prev_pmt_due_date          IBY_DOCS_PAYABLE_ALL.payment_due_date%TYPE,
curr_pmt_due_date         IBY_DOCS_PAYABLE_ALL.payment_due_date%TYPE,
prev_delivery_channel          IBY_DOCS_PAYABLE_ALL.delivery_channel_code%TYPE,
curr_delivery_channel         IBY_DOCS_PAYABLE_ALL.delivery_channel_code%TYPE,
prev_uri           IBY_DOCS_PAYABLE_ALL.unique_remittance_identifier%TYPE,
curr_uri         IBY_DOCS_PAYABLE_ALL.unique_remittance_identifier%TYPE,
prev_uri_checkdigits          IBY_DOCS_PAYABLE_ALL.uri_check_digit%TYPE,
curr_uri_checkdigits         IBY_DOCS_PAYABLE_ALL.uri_check_digit%TYPE

);

TYPE failDocsOfPaymentRecType IS RECORD
(
payment_id                     IBY_DOCS_PAYABLE_ALL.payment_id%TYPE,
document_payable_id            IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
document_status                IBY_DOCS_PAYABLE_ALL.document_status%TYPE,
calling_app_id                 IBY_DOCS_PAYABLE_ALL.calling_app_id%TYPE,
calling_app_doc_unique_ref1    IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref1%TYPE,
calling_app_doc_unique_ref2    IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref2%TYPE,
calling_app_doc_unique_ref3    IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref3%TYPE,
calling_app_doc_unique_ref4    IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref4%TYPE,
calling_app_doc_unique_ref5    IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref5%TYPE,
pay_proc_trxn_type_code        IBY_DOCS_PAYABLE_ALL.pay_proc_trxn_type_code%TYPE,
document_amount                IBY_DOCS_PAYABLE_ALL.document_amount%TYPE,
payment_grouping_number        IBY_DOCS_PAYABLE_ALL.payment_grouping_number%TYPE

);

TYPE failDocsOfPaymentTabType IS TABLE OF failDocsOfPaymentRecType
INDEX BY BINARY_INTEGER;

TYPE failDocsRecType IS RECORD
(
document_payable_id            IBY_HOOK_DOCS_IN_PMT_T.document_payable_id%TYPE,
document_amount                IBY_HOOK_DOCS_IN_PMT_T.document_amount%TYPE,
amount_withheld                IBY_HOOK_DOCS_IN_PMT_T.amount_withheld%TYPE,
dont_pay_flag                  IBY_HOOK_DOCS_IN_PMT_T.dont_pay_flag%TYPE
);

TYPE failDocsTabType IS TABLE OF failDocsRecType
INDEX BY BINARY_INTEGER;

 --
 -- Record to format linked to each profile.
 --
 TYPE profileFormatRecType IS RECORD (
     profile_id             IBY_PAYMENT_PROFILES.
                                payment_profile_id%TYPE,
     payment_format_cd      IBY_PAYMENT_PROFILES.
                                payment_format_code%TYPE,
     bepid                  IBY_PAYMENT_PROFILES.
                                bepid%TYPE,
     transmit_protocol_cd   IBY_PAYMENT_PROFILES.
                                transmit_protocol_code%TYPE
     );

 --
 -- The profile formats table
 --
 TYPE profileFormatTabType IS TABLE OF profileFormatRecType
     INDEX BY BINARY_INTEGER;

  /* holds list of format linked to each profile */
  l_profile_format_tab    profileFormatTabType;


TYPE internalBankAcctType IS RECORD (
     internal_bank_account_id     CE_BANK_ACCOUNTS.bank_account_id%TYPE,
     bank_home_country        CE_BANK_BRANCHES_V.bank_home_country%TYPE,
     country      CE_BANK_BRANCHES_V.country%TYPE,
     allow_zero_pmt_flag       CE_BANK_ACCOUNTS.zero_amount_allowed%TYPE
     );
 --
 TYPE internalBankAcctTabType IS TABLE OF internalBankAcctType
     INDEX BY VARCHAR2(2000);

  int_bank_acct_tbl  internalBankAcctTabType;


 -- Get Employee Full Name from HR tables
 FUNCTION Get_Employee_Full_Name(p_person_id IN NUMBER, p_party_id IN NUMBER,p_party_name IN VARCHAR2)
 RETURN VARCHAR2;


/*--------------------------------------------------------------------
 | NAME:
 |
 | PURPOSE:
 |     This procedure is used to initialize global memory structure
 |     / Destroy the no longer used memory structure
 |
 | PARAMETERS:
 |
 |     NONE
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE delete_paymentTab;


 /*--------------------------------------------------------------------
 | NAME:
 |
 | PURPOSE:
 |     This procedure is used to free up the memory used by
 |     global memory structure [pmtTable]
 |
 | PARAMETERS:
 |
 |     NONE
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE delete_pmtTable;

 --
 -- This data structure will be populated with the data
 -- from paymentRecType record. This record will only store
 -- success payments whereas paymentRecType can store both
 -- successful and failed payments. A table hookPaymentRecType
 -- records will be passed to the calling application via a
 -- hook / callout. The calling application can adjust the
 -- payment amount (and it's constituent document amounts)
 -- for purposes like bank charge calculation, tax withholding etc.
 --
 -- The record hookDocsInPaymentRecType holds the documents
 -- corresponding to this payment.
 --
 --
 -- Table of successful payments to be passed to the
 -- calling application via hook.
 --
 TYPE hookPaymentTabType IS TABLE OF IBY_HOOK_PAYMENTS_T%ROWTYPE
     INDEX BY BINARY_INTEGER;

 --
 -- This record needs to be created because of the fact that
 -- there is no document id column in IBY_PAYMENTS_ALL table. So
 -- we cannot add the document id as a field in the paymentRecType
 -- record (adding this field to the record will cause a syntax
 -- error during the bulk update).
 --
 -- Therefore, we need a separate data structure to keep track
 -- of the documents that are part of a payment. The docsInPaymentRecType
 -- is that data structure. After all the grouping operations are
 -- completed, the IBY_DOCS_PAYABLE_ALL table needs to be
 -- updated to indicate the PAYMENT_ID for each document that
 -- has been put into a payment. The docsInPaymentRecType
 -- is used for this update.
 --
 -- The record paymentRecType holds the payments corresponding
 -- to these documents.
 --
 TYPE docsInPaymentRecType IS RECORD (
     payment_id
         IBY_PAYMENTS_ALL.payment_id%TYPE,
     document_id
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     calling_app_id
         IBY_DOCS_PAYABLE_ALL.calling_app_id%TYPE,
     calling_app_doc_id1
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref1%TYPE,
     calling_app_doc_id2
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref2%TYPE,
     calling_app_doc_id3
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref3%TYPE,
     calling_app_doc_id4
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref4%TYPE,
     calling_app_doc_id5
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref5%TYPE,
     pay_proc_ttype_cd
         IBY_DOCS_PAYABLE_ALL.pay_proc_trxn_type_code%TYPE,
     document_amount
         IBY_DOCS_PAYABLE_ALL.payment_amount%TYPE,
     document_currency
         IBY_DOCS_PAYABLE_ALL.payment_currency_code%TYPE,
     payment_grp_num
         IBY_DOCS_PAYABLE_ALL.payment_grouping_number%TYPE,
     document_status
         IBY_DOCS_PAYABLE_ALL.document_status%TYPE := 'PAYMENT_CREATED',
     amount_withheld
         IBY_DOCS_PAYABLE_ALL.amount_withheld%TYPE := 0,
     pmt_due_date
         IBY_DOCS_PAYABLE_ALL.payment_due_date%TYPE,
     discount_date
         IBY_DOCS_PAYABLE_ALL.discount_date%TYPE,
     int_bank_acct_id
         IBY_DOCS_PAYABLE_ALL.internal_bank_account_id%TYPE,
     ext_payee_id
         IBY_DOCS_PAYABLE_ALL.ext_payee_id%TYPE,
     payee_id
         IBY_DOCS_PAYABLE_ALL.payee_party_id%TYPE,
     payee_site_id
         IBY_DOCS_PAYABLE_ALL.party_site_id%TYPE,
     supplier_site_id
         IBY_DOCS_PAYABLE_ALL.supplier_site_id%TYPE,
     org_id
         IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
     org_type
         IBY_DOCS_PAYABLE_ALL.org_type%TYPE,
     ext_bank_acct_id
         IBY_DOCS_PAYABLE_ALL.external_bank_account_id%TYPE,
     pmt_curr_discount
         IBY_DOCS_PAYABLE_ALL.payment_curr_discount_taken%TYPE,
     delivery_channel
         IBY_DOCS_PAYABLE_ALL.delivery_channel_code%TYPE,
     unique_remit_id
         IBY_DOCS_PAYABLE_ALL.unique_remittance_identifier%TYPE,
     uri_ckdigits
         IBY_DOCS_PAYABLE_ALL.uri_check_digit%TYPE,

	 /*TPP-Start*/
	 inv_payee_party_id         IBY_DOCS_PAYABLE_ALL.inv_payee_party_id%TYPE,
	 inv_party_site_id          IBY_DOCS_PAYABLE_ALL.inv_party_site_id%TYPE,
	 inv_supplier_site_id       IBY_DOCS_PAYABLE_ALL.inv_supplier_site_id%TYPE,
	 inv_beneficiary_party            IBY_DOCS_PAYABLE_ALL.inv_beneficiary_party%TYPE,
	 ext_inv_payee_id           IBY_DOCS_PAYABLE_ALL.ext_inv_payee_id%TYPE,
	 relationship_id            IBY_DOCS_PAYABLE_ALL.relationship_id%TYPE
         /*TPP-End*/
     );

 --
 -- Used to update of the IBY_DOCS_PAYABLE_ALL table.
 --
 TYPE docsInPaymentTabType IS TABLE OF docsInPaymentRecType
     INDEX BY BINARY_INTEGER;

 --
 -- This record stores the count of successful documents
 -- for a particular payment. It is useful in situations
 -- like remittance advice creation where is is necessary
 -- to know how many successful documents exist for a
 -- particular payment.
 --
 TYPE successDocsCountPerPmtRec IS RECORD (
     payment_id
         IBY_PAYMENTS_ALL.payment_id%TYPE,
     success_docs_count
         NUMBER(15)
     );

 --
 -- Table of success docs count per payment
 --
 TYPE successDocsCountPerPmtTab IS TABLE OF successDocsCountPerPmtRec
     INDEX BY BINARY_INTEGER;

 --
 -- A record that stores a payment method code along with it's
 -- maturity days offset.
 --
 TYPE pmtMethodMaturityDaysRec IS RECORD (
     pmt_method_cd
         IBY_PAYMENT_METHODS_VL.payment_method_code%TYPE,
     maturity_offset_days
         IBY_PAYMENT_METHODS_VL.maturity_date_offset_days%TYPE
     );

 --
 -- Table of payment methods and their maturity offset days.
 --
 TYPE pmtMethodMaturityDaysTab IS TABLE OF pmtMethodMaturityDaysRec
     INDEX BY BINARY_INTEGER;

 --
 -- List of documents to be passed to the calling
 -- app via hook.
 --
 -- The record hookPaymentRecType holds the payments
 -- corresponding to these documents.
 --
 -- Table of documents that will be exposed to the hook.
 --
 TYPE hookDocsInPaymentTabType IS TABLE OF IBY_HOOK_DOCS_IN_PMT_T%ROWTYPE
     INDEX BY BINARY_INTEGER;

 --
 -- The document id table
 --
 TYPE docPayTabType IS TABLE OF IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE
     INDEX BY BINARY_INTEGER;

 --
 -- This record stores all the document fields that are used in
 -- as criteria for grouping a document into a payment. Each
 -- of these fields will result in a grouping rule.
 --
 -- Some of the fields of this record are not used specifically
 -- for grouping, but for raising business events etc.
 -- e.g., the calling app pay req id
 --
 -- Some of the grouping criteria are user defined; these are
 -- specified in the IBY_PMT_CREATION_RULES table. This record
 -- contains placeholder for the user defined grouping fields
 -- as well.
 --
 TYPE paymentGroupCriteriaType IS RECORD (
     calling_app_payreq_cd
         IBY_PAY_SERVICE_REQUESTS.call_app_pay_service_req_code%TYPE,
     document_id
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     calling_app_id
         IBY_DOCS_PAYABLE_ALL.calling_app_id%TYPE,
     calling_app_doc_id1
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref1%TYPE,
     calling_app_doc_id2
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref2%TYPE,
     calling_app_doc_id3
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref3%TYPE,
     calling_app_doc_id4
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref4%TYPE,
     calling_app_doc_id5
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref5%TYPE,
     pay_proc_ttype_cd
         IBY_DOCS_PAYABLE_ALL.pay_proc_trxn_type_code%TYPE,
     payment_grp_num
         IBY_DOCS_PAYABLE_ALL.payment_grouping_number%TYPE,
     payment_method_cd
         IBY_DOCS_PAYABLE_ALL.payment_method_code%TYPE,
     int_bank_acct_id
         IBY_DOCS_PAYABLE_ALL.internal_bank_account_id%TYPE,
     ext_bank_acct_id
         IBY_DOCS_PAYABLE_ALL.external_bank_account_id%TYPE,
     payment_profile_id
         IBY_DOCS_PAYABLE_ALL.payment_profile_id%TYPE,
     org_id
         IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
     org_type
         IBY_DOCS_PAYABLE_ALL.org_type%TYPE,
     payment_function
         IBY_DOCS_PAYABLE_ALL.payment_function%TYPE,
     ext_payee_id
         IBY_DOCS_PAYABLE_ALL.ext_payee_id%TYPE,
     payee_party_id
         IBY_DOCS_PAYABLE_ALL.payee_party_id%TYPE,
     payee_party_site_id
         IBY_DOCS_PAYABLE_ALL.party_site_id%TYPE,
     supplier_site_id
         IBY_DOCS_PAYABLE_ALL.supplier_site_id%TYPE,
     remit_loc_id
         IBY_DOCS_PAYABLE_ALL.remit_to_location_id%TYPE,
     amount_withheld
         IBY_DOCS_PAYABLE_ALL.amount_withheld%TYPE,
     bank_inst1_code
         IBY_EXTERNAL_PAYEES_ALL.bank_instruction1_code%TYPE,
     bank_inst2_code
         IBY_EXTERNAL_PAYEES_ALL.bank_instruction2_code%TYPE,
     pmt_txt_msg1
         IBY_EXTERNAL_PAYEES_ALL.payment_text_message1%TYPE,
     pmt_txt_msg2
         IBY_EXTERNAL_PAYEES_ALL.payment_text_message2%TYPE,
     pmt_txt_msg3
         IBY_EXTERNAL_PAYEES_ALL.payment_text_message3%TYPE,
     payment_currency
         IBY_DOCS_PAYABLE_ALL.payment_currency_code%TYPE,
     payment_amount
         IBY_DOCS_PAYABLE_ALL.payment_amount%TYPE,
     payment_date
         IBY_DOCS_PAYABLE_ALL.payment_date%TYPE,
     pay_alone_flag
         IBY_DOCS_PAYABLE_ALL.exclusive_payment_flag%TYPE,
     bank_charge_bearer
         IBY_DOCS_PAYABLE_ALL.bank_charge_bearer%TYPE,
     delivery_channel
         IBY_DOCS_PAYABLE_ALL.delivery_channel_code%TYPE,
     settle_priority
         IBY_DOCS_PAYABLE_ALL.settlement_priority%TYPE,
     supplier_message1
         IBY_DOCS_PAYABLE_ALL.remittance_message1%TYPE,
     supplier_message2
         IBY_DOCS_PAYABLE_ALL.remittance_message2%TYPE,
     supplier_message3
         IBY_DOCS_PAYABLE_ALL.remittance_message3%TYPE,
     unique_remit_id
         IBY_DOCS_PAYABLE_ALL.unique_remittance_identifier%TYPE,
     uri_checkdigit
         IBY_DOCS_PAYABLE_ALL.uri_check_digit%TYPE,
     pmt_reason_code
         IBY_DOCS_PAYABLE_ALL.payment_reason_code%TYPE,
     pmt_reason_comments
         IBY_DOCS_PAYABLE_ALL.payment_reason_comments%TYPE,
     pmt_due_date
         IBY_DOCS_PAYABLE_ALL.payment_due_date%TYPE,
     discount_date
         IBY_DOCS_PAYABLE_ALL.discount_date%TYPE,
     discount_amount
         IBY_DOCS_PAYABLE_ALL.payment_curr_discount_taken%TYPE,
     benef_party
         IBY_DOCS_PAYABLE_ALL.beneficiary_party%TYPE,
     addr_source
         IBY_DOCS_PAYABLE_ALL.address_source%TYPE,
     emp_addr_code
         IBY_DOCS_PAYABLE_ALL.employee_address_code%TYPE,
     emp_person_id
         IBY_DOCS_PAYABLE_ALL.employee_person_id%TYPE,
     emp_address_id
         IBY_DOCS_PAYABLE_ALL.employee_address_id%TYPE,
     emp_payment_flag
         IBY_DOCS_PAYABLE_ALL.employee_payment_flag%TYPE,
     supplier_msg_flag
         IBY_PMT_CREATION_RULES.group_by_remittance_message%TYPE,
     bnk_chg_bearer_flag
         IBY_PMT_CREATION_RULES.group_by_bank_charge_bearer%TYPE,
     delv_channel_flag
         IBY_PMT_CREATION_RULES.group_by_delivery_channel%TYPE,
     settle_priority_flag
         IBY_PMT_CREATION_RULES.group_by_settle_priority_flag%TYPE,
     pmt_details_flag
         IBY_PMT_CREATION_RULES.group_by_payment_details_flag%TYPE,
     pmt_details_length
         IBY_PMT_CREATION_RULES.payment_details_length_limit%TYPE,
     payment_details_formula
         IBY_PMT_CREATION_RULES.payment_details_formula%TYPE,
     max_documents_flag
         IBY_PMT_CREATION_RULES.group_by_max_documents_flag%TYPE,
     max_documents_limit
         IBY_PMT_CREATION_RULES.max_documents_per_payment%TYPE,
     unique_remit_id_flag
         IBY_PMT_CREATION_RULES.group_by_unique_remit_id_flag%TYPE,
     pmt_reason_flag
         IBY_PMT_CREATION_RULES.group_by_payment_reason%TYPE,
     pmt_due_date_flag
         IBY_PMT_CREATION_RULES.group_by_due_date_flag%TYPE,
     processing_type
         IBY_PAYMENT_PROFILES.processing_type%TYPE,
     decl_option
         IBY_PAYMENT_PROFILES.declaration_option%TYPE,
     decl_only_fx_flag
         IBY_PAYMENT_PROFILES.dcl_only_foreign_curr_pmt_flag%TYPE,
     decl_curr_fx_rate_type
         IBY_PAYMENT_PROFILES.declaration_curr_fx_rate_type%TYPE,
     decl_curr_code
         IBY_PAYMENT_PROFILES.declaration_currency_code%TYPE,
     decl_threshold_amount
         IBY_PAYMENT_PROFILES.declaration_threshold_amount%TYPE,
     max_payment_amount
         IBY_PAY_SERVICE_REQUESTS.maximum_payment_amount%TYPE,
     min_payment_amount
         IBY_PAY_SERVICE_REQUESTS.minimum_payment_amount%TYPE,
     allow_zero_pmts_flag
         IBY_PAY_SERVICE_REQUESTS.allow_zero_payments_flag%TYPE,
     support_prom_notes_flag
         IBY_PAYMENT_METHODS_VL.support_bills_payable_flag%TYPE
     );

 --
 -- Table of payment grouping criteria.
 --
 TYPE paymentGroupCriteriaTabType IS TABLE OF paymentGroupCriteriaType
     INDEX BY BINARY_INTEGER;

 --
 -- These are payment related criteria that are passed
 -- in as part of the payment request. Payments should
 -- be validated using these criteria in addition to
 -- the usual payment validation rules.
 --
 TYPE payReqImposedCriteria IS RECORD (
     max_pmt_amt_limit
         IBY_PAY_SERVICE_REQUESTS.maximum_payment_amount%TYPE,
     min_pmt_amt_limit
         IBY_PAY_SERVICE_REQUESTS.minimum_payment_amount%TYPE,
     allow_zero_pmts_flag
         IBY_PAY_SERVICE_REQUESTS.allow_zero_payments_flag%TYPE
     );

 --
 -- This record stores one validation set applicable to
 -- a particular payment.
 --
 TYPE paymentValSetsRec IS RECORD (
     val_assign_id
         IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     val_assign_entity_type
         IBY_VAL_ASSIGNMENTS.val_assignment_entity_type%TYPE,
     val_set_name
         IBY_VALIDATION_SETS_VL.validation_set_display_name%TYPE,
     val_set_code
         IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     val_code_pkg
         IBY_VALIDATION_SETS_VL.validation_code_package%TYPE,
     val_code_entry_pt
         IBY_VALIDATION_SETS_VL.validation_code_entry_point%TYPE
     );

 --
 -- Table of validation sets applicable to a particular payment
 --
 TYPE paymentValSetsTab IS TABLE OF paymentValSetsRec
     INDEX BY BINARY_INTEGER;

 TYPE valSetsOuterRecType IS RECORD (
     val_set_count  NUMBER,
     val_sets_tbl    paymentValSetsTab
     );

 --
 -- Table of validation set records
 --
 TYPE valSetsOuterTabType IS TABLE OF valSetsOuterRecType
     INDEX BY VARCHAR2(4000);

 val_sets_outer_tbl    valSetsOuterTabType;



 --
 -- This record stores some elements of a row from
 -- the IBY_REMIT_ADVICE_SETUP table
 --
 TYPE remitAdviceRec IS RECORD (
     payment_profile_cd
         IBY_REMIT_ADVICE_SETUP.system_profile_code%TYPE,
     doc_count_limit
         IBY_REMIT_ADVICE_SETUP.document_count_limit%TYPE,
     pmt_details_len_limit
         IBY_REMIT_ADVICE_SETUP.payment_details_length_limit%TYPE,
     PAYMENT_DETAILS
         IBY_PAYMENTS_ALL.PAYMENT_DETAILS%TYPE,
     payment_id
         IBY_PAYMENTS_ALL.payment_id%TYPE,
    DOCUMENT_COUNT
         NUMBER
     );

 --
 -- Table of remittance advice records
 --
 TYPE remitAdviceRecTab IS TABLE OF remitAdviceRec
     INDEX BY BINARY_INTEGER;

 --
 -- System options record
 --
 TYPE sysOptionsRecType IS RECORD (
     rej_level              IBY_INTERNAL_PAYERS_ALL.
                                payment_rejection_level_code%TYPE,
     revw_flag              IBY_INTERNAL_PAYERS_ALL.
                                require_prop_pmts_review_flag%TYPE
     );

 --
 -- System options table
 --
 TYPE sysOptionsTabType IS TABLE OF sysOptionsRecType
     INDEX BY BINARY_INTEGER;

 --
 -- Table of payment ids.
 --
 TYPE pmtIdsTab IS TABLE OF IBY_PAYMENTS_ALL.payment_id%TYPE
     INDEX BY BINARY_INTEGER;

 --
 -- Internal bank account with its corresponding legal entity id.
 --
 TYPE bankAccountLERecType IS RECORD (
     int_bank_acct_id   CE_BANK_ACCOUNTS.bank_account_id%TYPE,
     le_id              IBY_PAYMENTS_ALL.legal_entity_id%TYPE
     );

 --
 -- Table of internal bank accounts each with its legal entity.
 --
 TYPE bankAccountLETabType IS TABLE OF bankAccountLERecType
     INDEX BY BINARY_INTEGER;

 --
 -- Stores the denormalized data related to the payer, payee,
 -- payer bank and payee bank. This data is stamped onto
 -- the payment in IBY_PAYMENTS_ALL table for audit purposes.
 --
 TYPE paymentAuditRecType IS RECORD (

     payment_id                                                      -- 01
         IBY_PAYMENTS_ALL.payment_id%TYPE,

     /* PAYER RELATED */
     payer_party_number
         IBY_PAYMENTS_ALL.payer_party_number%TYPE,
     payer_party_site_name
         IBY_PAYMENTS_ALL.payer_party_site_name%TYPE,
     payer_legal_name
         IBY_PAYMENTS_ALL.payer_legal_entity_name%TYPE,
     payer_tax_reg_number
         IBY_PAYMENTS_ALL.payer_tax_registration_num%TYPE,
     payer_le_reg_number
         IBY_PAYMENTS_ALL.payer_le_registration_num%TYPE,
     payer_party_id
         IBY_PAYMENTS_ALL.payer_party_id%TYPE,
     payer_location_id
         IBY_PAYMENTS_ALL.payer_location_id%TYPE,
     payer_party_attr_cat
         IBY_PAYMENTS_ALL.payer_party_attr_category%TYPE,
     payer_le_attr_cat                                               -- 10
         IBY_PAYMENTS_ALL.payer_le_attr_category%TYPE,

     /* PAYER SPECIAL FIELDS */
     payer_abbrev_agency_code
         IBY_PAYMENTS_ALL.payer_abbreviated_agency_code%TYPE,
     payer_us_employer_id
         IBY_PAYMENTS_ALL.payer_federal_us_employer_id%TYPE,

     /* PAYER BANK RELATED */
     payer_bank_name
         IBY_PAYMENTS_ALL.int_bank_name%TYPE,
     payer_bank_number
         IBY_PAYMENTS_ALL.int_bank_number%TYPE,
     payer_bank_branch_number
         IBY_PAYMENTS_ALL.int_bank_branch_number%TYPE,
     payer_bank_branch_name
         IBY_PAYMENTS_ALL.int_bank_branch_name%TYPE,
     payer_bank_swift_code
         IBY_PAYMENTS_ALL.int_eft_swift_code%TYPE,
     payer_bank_acct_num
         IBY_PAYMENTS_ALL.int_bank_account_number%TYPE,
     payer_bank_acct_name
         IBY_PAYMENTS_ALL.int_bank_account_name%TYPE,
     payer_bank_acct_iban                                            -- 20
         IBY_PAYMENTS_ALL.int_bank_account_iban%TYPE,
     payer_bank_agency_loc_code
         IBY_PAYMENTS_ALL.int_bank_acct_agency_loc_code%TYPE,
     payer_bank_branch_party_id
         IBY_PAYMENTS_ALL.int_bank_branch_party_id%TYPE,
     payer_bank_alt_name
         IBY_PAYMENTS_ALL.int_bank_alt_name%TYPE,
     payer_bank_branch_alt_name
         IBY_PAYMENTS_ALL.int_bank_branch_alt_name%TYPE,
     payer_bank_alt_account_name
         IBY_PAYMENTS_ALL.int_bank_account_alt_name%TYPE,
     payer_bank_account_num_elec
         IBY_PAYMENTS_ALL.int_bank_account_num_elec%TYPE,
     payer_bank_branch_location_id
         IBY_PAYMENTS_ALL.int_bank_branch_location_id%TYPE,
     payer_bank_branch_eft_user_num
         IBY_PAYMENTS_ALL.int_bank_branch_eft_user_num%TYPE,


     /* PAYEE RELATED */
     payee_party_number
         IBY_PAYMENTS_ALL.payee_party_number%TYPE,
     payee_party_name                                                -- 30
         IBY_PAYMENTS_ALL.payee_party_name%TYPE,
     payee_name
         IBY_PAYMENTS_ALL.payee_name%TYPE,
     payee_name_alternate
         IBY_PAYMENTS_ALL.payee_alternate_name%TYPE,
     payee_add_line_1
         IBY_PAYMENTS_ALL.payee_address1%TYPE,
     payee_add_line_2
         IBY_PAYMENTS_ALL.payee_address2%TYPE,
     payee_add_line_3
         IBY_PAYMENTS_ALL.payee_address3%TYPE,
     payee_add_line_4
         IBY_PAYMENTS_ALL.payee_address4%TYPE,
     payee_city
         IBY_PAYMENTS_ALL.payee_city%TYPE,
     payee_county
         IBY_PAYMENTS_ALL.payee_county%TYPE,
     payee_province
         IBY_PAYMENTS_ALL.payee_province%TYPE,
     payee_state                                                     -- 40
         IBY_PAYMENTS_ALL.payee_state%TYPE,
     payee_country
         IBY_PAYMENTS_ALL.payee_country%TYPE,
     payee_postal_code
         IBY_PAYMENTS_ALL.payee_postal_code%TYPE,
     payee_address_concat
         IBY_PAYMENTS_ALL.payee_address_concat%TYPE,
     beneficiary_name
         IBY_PAYMENTS_ALL.beneficiary_name%TYPE,
     payee_party_attr_cat
        IBY_PAYMENTS_ALL.payee_party_attr_category%TYPE,
     payee_supplier_site_attr_cat
        IBY_PAYMENTS_ALL.payee_spplr_site_attr_category%TYPE,
     payee_supplier_site_name
        IBY_PAYMENTS_ALL.payee_supplier_site_name%TYPE,
     payee_addressee
        IBY_PAYMENTS_ALL.payee_addressee%TYPE,

     /* VENDOR RELATED */
     payee_site_name_alternate
         IBY_PAYMENTS_ALL.payee_site_alternate_name%TYPE,
     payee_supplier_number
         IBY_PAYMENTS_ALL.payee_supplier_number%TYPE,
     payee_first_party_ref                                           -- 50
         IBY_PAYMENTS_ALL.payee_first_party_reference%TYPE,
     payee_supplier_attr_cat
         IBY_PAYMENTS_ALL.payee_supplier_attr_category%TYPE,
     payee_supplier_id
         IBY_PAYMENTS_ALL.payee_supplier_id%TYPE,

     /* PAYEE SPECIAL FIELDS */
     payee_tax_reg_number
         IBY_PAYMENTS_ALL.payee_tax_registration_num%TYPE,
     payee_le_reg_number
         IBY_PAYMENTS_ALL.payee_le_registration_num%TYPE,

     /* PAYEE BANK RELATED */
     payee_bank_name
         IBY_PAYMENTS_ALL.ext_bank_name%TYPE,
     payee_bank_number
         IBY_PAYMENTS_ALL.ext_bank_number%TYPE,
     payee_bank_branch_number
         IBY_PAYMENTS_ALL.ext_branch_number%TYPE,
     payee_bank_branch_name
         IBY_PAYMENTS_ALL.ext_bank_branch_name%TYPE,
     payee_bank_acct_number
         IBY_PAYMENTS_ALL.ext_bank_account_number%TYPE,
     payee_bank_acct_name                                            -- 60
         IBY_PAYMENTS_ALL.ext_bank_account_name%TYPE,
     payee_bank_acct_iban
         IBY_PAYMENTS_ALL.ext_bank_account_iban_number%TYPE,
     payee_bank_swift_code
         IBY_PAYMENTS_ALL.ext_eft_swift_code%TYPE,
     payee_bank_acct_type
         IBY_PAYMENTS_ALL.ext_bank_account_type%TYPE,
     payee_bank_payment_factor_flag
         IBY_PAYMENTS_ALL.ext_bank_acct_pmt_factor_flag%TYPE,
     payee_bank_owner_party_id
         IBY_PAYMENTS_ALL.ext_bank_acct_owner_party_id%TYPE,
     payee_bank_branch_party_id
         IBY_PAYMENTS_ALL.ext_bank_branch_party_id%TYPE,
     payee_bank_name_alt
         IBY_PAYMENTS_ALL.ext_bank_alt_name%TYPE,
     payee_bank_branch_name_alt
         IBY_PAYMENTS_ALL.ext_bank_branch_alt_name%TYPE,
     payee_bank_alt_account_name
         IBY_PAYMENTS_ALL.ext_bank_account_alt_name%TYPE,
     payee_bank_electronic_acct_num                                  -- 70
         IBY_PAYMENTS_ALL.ext_bank_account_num_elec%TYPE,
     payee_bank_branch_location_id
         IBY_PAYMENTS_ALL.ext_bank_branch_location_id%TYPE,
     payee_bank_acct_owner_name
         IBY_PAYMENTS_ALL.ext_bank_acct_owner_party_name%TYPE,


     /* REMITTANCE ADVICE RELATED */
     remit_advice_delivery_method
         IBY_PAYMENTS_ALL.remit_advice_delivery_method%TYPE,
     remit_advice_email
         IBY_PAYMENTS_ALL.remit_advice_email%TYPE,
     remit_advice_fax
         IBY_PAYMENTS_ALL.remit_advice_fax%TYPE,

     /*
      * Fix for bug 5522421:
      *
      * sra_delivery_method is the same as
      * remit_advice_delivery_method and is
      * being obsoleted.
      */
     --remit_advice_delv_method
     --    IBY_PAYMENTS_ALL.sra_delivery_method%TYPE,

     /* DELIVERY CHANNEL RELATED */
     delivery_channel_format
         IBY_PAYMENTS_ALL.delivery_channel_format_value%TYPE,

     /* DECLARATION REPORT RELATED */
     decl_curr_fx_rate_type
         IBY_PAYMENTS_ALL.declaration_exch_rate_type%TYPE,
     declaration_format
         IBY_PAYMENTS_ALL.declaration_format%TYPE,

     /* PROFILE RELATED */
     payment_acct_profile_name                                       -- 80
         IBY_PAYMENTS_ALL.payment_profile_acct_name%TYPE,
     payment_sys_profile_name
         IBY_PAYMENTS_ALL.payment_profile_sys_name%TYPE,

     /* PAYMENT REASON */
     payment_reason_format
         IBY_PAYMENTS_ALL.payment_reason_format_value%TYPE,

     /* BANK INSTRUCTION */
     bank_instr1_format
         IBY_PAYMENTS_ALL.bank_instruction1_format_value%TYPE,
     bank_instr2_format
         IBY_PAYMENTS_ALL.bank_instruction2_format_value%TYPE,

     /* ORG */
     org_name
         IBY_PAYMENTS_ALL.org_name%TYPE,

     /* RFC */
     payer_bank_branch_rfc_id
         IBY_PAYMENTS_ALL.int_bank_branch_rfc_identifier%TYPE,

     /* REQUEST */
     ppr_name
         IBY_PAYMENTS_ALL.payment_process_request_name%TYPE,
     source_product                                                  -- 88
         IBY_PAYMENTS_ALL.source_product%TYPE,
/*TPP-Start*/

inv_payee_name
     IBY_PAYMENTS_ALL.inv_payee_name%TYPE,
inv_payee_address1
     IBY_PAYMENTS_ALL.inv_payee_address1%TYPE,
inv_payee_address2
     IBY_PAYMENTS_ALL.inv_payee_address2%TYPE,
inv_payee_address3
     IBY_PAYMENTS_ALL.inv_payee_address3%TYPE,
inv_payee_address4
     IBY_PAYMENTS_ALL.inv_payee_address4%TYPE,
inv_payee_city
     IBY_PAYMENTS_ALL.inv_payee_city%TYPE,
inv_payee_postal_code
     IBY_PAYMENTS_ALL.inv_payee_postal_code%TYPE,
inv_payee_state
     IBY_PAYMENTS_ALL.inv_payee_state%TYPE,
inv_payee_province
     IBY_PAYMENTS_ALL.inv_payee_province%TYPE,
inv_payee_county
     IBY_PAYMENTS_ALL.inv_payee_county%TYPE,
inv_payee_country
     IBY_PAYMENTS_ALL.inv_payee_country%TYPE,
inv_payee_party_name
     IBY_PAYMENTS_ALL.inv_payee_party_name%TYPE,
inv_payee_le_reg_num
     IBY_PAYMENTS_ALL.inv_payee_le_reg_num%TYPE,
inv_payee_tax_reg_num
     IBY_PAYMENTS_ALL.inv_payee_tax_reg_num%TYPE,
inv_payee_address_concat
     IBY_PAYMENTS_ALL.inv_payee_address_concat%TYPE,
inv_beneficiary_name
     IBY_PAYMENTS_ALL.inv_beneficiary_name%TYPE,
inv_payee_party_number
     IBY_PAYMENTS_ALL.inv_payee_party_number%TYPE,
inv_payee_alternate_name
     IBY_PAYMENTS_ALL.inv_payee_alternate_name%TYPE,
inv_payee_site_alt_name
    IBY_PAYMENTS_ALL.inv_payee_site_alt_name%TYPE,
inv_payee_supplier_number
     IBY_PAYMENTS_ALL.inv_payee_supplier_number%TYPE,
inv_payee_first_party_ref
     IBY_PAYMENTS_ALL.inv_payee_first_party_ref%TYPE,
ext_bnk_acct_ownr_inv_prty_id
     IBY_PAYMENTS_ALL.ext_bnk_acct_ownr_inv_prty_id%TYPE,
ext_bnk_branch_inv_prty_id
     IBY_PAYMENTS_ALL.ext_bnk_branch_inv_prty_id%TYPE,
ext_bnk_acct_ownr_inv_prty_nme
     IBY_PAYMENTS_ALL.ext_bnk_acct_ownr_inv_prty_nme%TYPE,
inv_payee_party_attr_cat
     IBY_PAYMENTS_ALL.inv_payee_party_attr_cat%TYPE,
inv_payee_supplier_attr_cat
     IBY_PAYMENTS_ALL.inv_payee_supplier_attr_cat%TYPE,
inv_payee_spplr_site_attr_cat
     IBY_PAYMENTS_ALL.inv_payee_spplr_site_attr_cat%TYPE,
inv_payee_supplier_site_name
     IBY_PAYMENTS_ALL.inv_payee_supplier_site_name%TYPE,
inv_payee_spplr_site_alt_name
     IBY_PAYMENTS_ALL.inv_payee_spplr_site_alt_name%TYPE,
inv_payee_supplier_id
     IBY_PAYMENTS_ALL.inv_payee_supplier_id%TYPE
/*TPP-End*/

     );

 --
 -- Table of internal bank accounts each with its legal entity.
 --
 TYPE paymentAuditTabType IS TABLE OF paymentAuditRecType
     INDEX BY BINARY_INTEGER;

 --
 -- Central bank reporting record
 --
 TYPE centralBankReportRecType IS RECORD (
     payment_id             IBY_PAYMENTS_ALL.
                                payment_id%TYPE,
     decl_option            IBY_PAYMENT_PROFILES.
                                declaration_option%TYPE,
     decl_only_fx_flag      IBY_PAYMENT_PROFILES.
                                dcl_only_foreign_curr_pmt_flag%TYPE,
     decl_curr_fx_rate_type IBY_PAYMENT_PROFILES.
                                declaration_curr_fx_rate_type%TYPE,
     decl_curr_code         IBY_PAYMENT_PROFILES.
                                declaration_currency_code%TYPE,
     decl_threshold_amount  IBY_PAYMENT_PROFILES.
                                declaration_threshold_amount%TYPE
     );

 --
 -- Central bank reporting table
 --
 TYPE centralBankReportTabType IS TABLE OF centralBankReportRecType
     INDEX BY BINARY_INTEGER;

/*--------------------------------------------------------------------
 | NAME:
 |     createPayments
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE createPayments(
     p_payment_request_id         IN IBY_PAY_SERVICE_REQUESTS.
                                         payment_service_request_id%TYPE,
     p_pmt_rejection_level        IN IBY_INTERNAL_PAYERS_ALL.
                                         payment_rejection_level_code%TYPE,
     p_review_proposed_pmts_flag  IN IBY_INTERNAL_PAYERS_ALL.
                                         require_prop_pmts_review_flag%TYPE,
                                         p_override_complete_point    IN VARCHAR2,
     p_bill_payable_flag          IN         VARCHAR2,
     p_maturity_date              IN         DATE,
     p_calling_procedure          IN         VARCHAR2,
     x_return_status              IN OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     performDocumentGrouping
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES: Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performDocumentGrouping(
     p_payment_request_id   IN IBY_PAY_SERVICE_REQUESTS.
                                         payment_service_request_id%TYPE,
     x_paymentTab           IN OUT NOCOPY IBY_PAYGROUP_PUB.paymentTabType,
     x_docsInPmtTab         IN OUT NOCOPY IBY_PAYGROUP_PUB.
                                              docsInPaymentTabType,
     x_ca_id                IN OUT NOCOPY IBY_PAY_SERVICE_REQUESTS.
                                              calling_app_id%TYPE,
     x_ca_payreq_cd         IN OUT NOCOPY IBY_PAY_SERVICE_REQUESTS.
                                              call_app_pay_service_req_code
                                              %TYPE,
     x_payReqCriteria       IN OUT NOCOPY IBY_PAYGROUP_PUB.
                                              payReqImposedCriteria
--  ,x_cbrTab               IN OUT NOCOPY IBY_PAYGROUP_PUB.
--                                             centralBankReportTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     performDocumentGrouping
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performDocumentGrouping(
     p_payment_request_id   IN IBY_PAY_SERVICE_REQUESTS.
                                         payment_service_request_id%TYPE,
   --  x_paymentTab           IN OUT NOCOPY IBY_PAYGROUP_PUB.paymentTabType,
     x_ca_id                IN OUT NOCOPY IBY_PAY_SERVICE_REQUESTS.
                                              calling_app_id%TYPE,
     x_ca_payreq_cd         IN OUT NOCOPY IBY_PAY_SERVICE_REQUESTS.
                                              call_app_pay_service_req_code
                                              %TYPE,
     x_payReqCriteria       IN OUT NOCOPY IBY_PAYGROUP_PUB.
                                              payReqImposedCriteria
--  ,x_cbrTab               IN OUT NOCOPY IBY_PAYGROUP_PUB.
--                                             centralBankReportTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     insertDocIntoPayment
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:     Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE insertDocIntoPayment(
     x_paymentRec            IN OUT NOCOPY IBY_PAYMENTS_ALL%ROWTYPE,
     x_paymentTab            IN OUT NOCOPY paymentTabType,
     p_calcDocInfo           IN VARCHAR2,
     p_newPaymentFlag        IN BOOLEAN,
     x_currentPaymentId      IN OUT NOCOPY IBY_PAYMENTS_ALL.payment_id%TYPE,
     x_docsInPmtTab          IN OUT NOCOPY docsInPaymentTabType,
     x_docsInPmtRec          IN OUT NOCOPY docsInPaymentRecType,
     x_docsInPmtCount        IN OUT NOCOPY NUMBER
     );
/*--------------------------------------------------------------------
 | NAME:
 |     insertDocIntoPayment
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:     Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE insertDocIntoPayment(
     x_paymentRec            IN OUT NOCOPY IBY_PAYMENTS_ALL%ROWTYPE,
     x_paymentTab            IN OUT NOCOPY paymentTabType,
     p_calcDocInfo           IN VARCHAR2,
     p_newPaymentFlag        IN BOOLEAN,
     x_currentPaymentId      IN OUT NOCOPY IBY_PAYMENTS_ALL.payment_id%TYPE,
     x_docsInPmtTab          IN OUT NOCOPY docsInPaymentTabType,
     x_docsInPmtRec          IN OUT NOCOPY docsInPaymentRecType,
     x_docsInPmtCount        IN OUT NOCOPY NUMBER,
     x_commonAttributes      IN OUT NOCOPY commonAttributesTabType
     );


/*--------------------------------------------------------------------
 | NAME:
 |     insertDocIntoPayment
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE insertDocIntoPayment(
     x_paymentRec            IN OUT NOCOPY IBY_PAYMENTS_ALL%ROWTYPE,
    -- x_paymentTab            IN OUT NOCOPY paymentTabType,
     p_calcDocInfo           IN VARCHAR2,
     p_newPaymentFlag        IN BOOLEAN,
     x_currentPaymentId      IN OUT NOCOPY IBY_PAYMENTS_ALL.payment_id%TYPE,
     x_docsInPmtCount        IN OUT NOCOPY NUMBER,
     x_commonAttributes      IN OUT NOCOPY commonAttributesTabType,
     p_trx_line_index        IN            BINARY_INTEGER
     );



/*--------------------------------------------------------------------
 | NAME:
 |     insertPayments
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE insertPayments(
     p_paymentTab            IN paymentTabType
     );

 /*--------------------------------------------------------------------
 | NAME:
 |     insertPayments
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE insertPayments;

/*--------------------------------------------------------------------
 | NAME:
 |     updatePayments
 |
 | PURPOSE:
 |     Performs an update of all created payments from PLSQL
 |     table into IBY_PAYMENTS_ALL table.
 |
 |     The created payments have already been inserted into
 |     IBY_PAYMENTS_ALL after grouping. So we only need to update
 |     certain fields of the payment that have been changed
 |     after the grouping was performed.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE updatePayments(
     p_paymentTab    IN paymentTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     getNextPaymentID
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE getNextPaymentID(
     x_paymentID IN OUT NOCOPY IBY_PAYMENTS_ALL.payment_id%TYPE
     );

 /*--------------------------------------------------------------------
 | NAME:
 |     updateDocsWithPaymentID
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:   Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE updateDocsWithPaymentID(
     p_docsInPmtTab  IN docsInPaymentTabType
     );


/*--------------------------------------------------------------------
 | NAME:
 |     updateDocsWithPaymentID
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE updateDocsWithPaymentID;




/*--------------------------------------------------------------------
 | NAME:
 |      updatePayments
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE  updatePayments;


 /*--------------------------------------------------------------------
 | NAME:
 |     performDBUpdates
 |
 | PURPOSE:
 |     This is the top level method that is called by the
 |     payment creation program to:
 |         1. insert payments to DB
 |         2. update documents with payment id
 |         3. update status of payment request
 |
 |     This method will read the 'rejection level' system option
 |     and do updates accordingly.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:     Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performDBUpdates(
     p_payreq_id          IN            IBY_PAY_SERVICE_REQUESTS.
                                          payment_service_request_id%type,
     p_rej_level          IN            VARCHAR2,
     p_review_pmts_flag   IN            VARCHAR2,
     x_paymentTab         IN OUT NOCOPY paymentTabType,
     x_docsInPmtTab       IN OUT NOCOPY docsInPaymentTabType,
     x_allPmtsSuccessFlag IN OUT NOCOPY BOOLEAN,
     x_allPmtsFailedFlag  IN OUT NOCOPY BOOLEAN,
     x_return_status      IN OUT NOCOPY VARCHAR2,
     x_docErrorTab        IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab        IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                            trxnErrTokenTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     performDBUpdates
 |
 | PURPOSE:
 |     This is the top level method that is called by the
 |     payment creation program to:
 |         1. insert payments to DB
 |         2. update documents with payment id
 |         3. update status of payment request
 |
 |     This method will read the 'rejection level' system option
 |     and do updates accordingly.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performDBUpdates(
     p_payreq_id          IN            IBY_PAY_SERVICE_REQUESTS.
                                          payment_service_request_id%type,
     p_rej_level          IN            VARCHAR2,
     p_review_pmts_flag   IN            VARCHAR2,
 --    x_paymentTab         IN OUT NOCOPY paymentTabType,
 --     x_docsInPmtTab       IN OUT NOCOPY docsInPaymentTabType,
     x_allPmtsSuccessFlag IN OUT NOCOPY BOOLEAN,
     x_allPmtsFailedFlag  IN OUT NOCOPY BOOLEAN,
     x_return_status      IN OUT NOCOPY VARCHAR2,
     x_docErrorTab        IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab        IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                            trxnErrTokenTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     performCentralBankReporting
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:       Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performCentralBankReporting(
     x_paymentTab             IN OUT NOCOPY paymentTabType,
     x_docsInPmtTab           IN OUT NOCOPY docsInPaymentTabType
--    ,p_cbrTab                 IN            centralBankReportTabType
     );


/*--------------------------------------------------------------------
 | NAME:
 |     performCentralBankReporting
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performCentralBankReporting(
  l_trx_cbr_index           IN BINARY_INTEGER
  --     x_paymentTab             IN OUT NOCOPY paymentTabType
  --    x_docsInPmtTab           IN OUT NOCOPY docsInPaymentTabType
  --    ,p_cbrTab                 IN            centralBankReportTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     flagSeparateRemitAdvicePmts
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:     Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE flagSeparateRemitAdvicePmts(
     x_paymentTab    IN OUT NOCOPY paymentTabType,
     p_docsInPmtTab  IN            docsInPaymentTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     flagSeparateRemitAdvicePmts
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE flagSeparateRemitAdvicePmts(
	l_ca_payreq_cd  IN VARCHAR2,
        ppr_id          IN IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE
 --    x_paymentTab    IN OUT NOCOPY paymentTabType
 --     p_docsInPmtTab  IN            docsInPaymentTabType
     );

 /*--------------------------------------------------------------------
 | NAME:
 |     getNumSuccessDocsPerPayment
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:     Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE getNumSuccessDocsPerPayment(
     x_paymentTab          IN OUT NOCOPY paymentTabType,
     p_docsInPmtTab        IN            docsInPaymentTabType,
     x_successDocCountTab  IN OUT NOCOPY successDocsCountPerPmtTab
     );

/*--------------------------------------------------------------------
 | NAME:
 |     getNumSuccessDocsPerPayment
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE getNumSuccessDocsPerPayment(
     x_paymentTab          IN OUT NOCOPY paymentTabType,
 --     p_docsInPmtTab        IN            docsInPaymentTabType,
     x_successDocCountTab  IN OUT NOCOPY successDocsCountPerPmtTab
     );

/*--------------------------------------------------------------------
 | NAME:
 |     getFxAmount()
 |
 | PURPOSE:
 |     Calls GL API to get converted amount in foreign currency.
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION getFxAmount(
     p_source_currency   IN VARCHAR2,
     p_target_currency   IN VARCHAR2,
     p_exch_rate_date    IN DATE,
     p_exch_rate_type    IN VARCHAR2,
     p_source_amount     IN NUMBER
     )
     RETURN NUMBER;

 /*
  * This pragma is needed because the GL API enforces it.
  */
 PRAGMA RESTRICT_REFERENCES(getFxAmount, WNDS, WNPS, RNPS);

/*--------------------------------------------------------------------
 | NAME:
 |     performPaymentValidations
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performPaymentValidations(
      p_payment_request_id   IN IBY_PAY_SERVICE_REQUESTS.
                                   payment_service_request_id%TYPE,
     x_paymentTab      IN OUT NOCOPY paymentTabType,
     x_docErrorTab     IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab     IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     performPreHookProcess
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:         Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performPreHookProcess(
     p_cap_payreq_cd     IN            VARCHAR2,
     p_cap_id            IN            NUMBER,
     x_paymentTab        IN OUT NOCOPY paymentTabType,
     x_docsInPmtTab      IN OUT NOCOPY docsInPaymentTabType,
     x_hookPaymentTab    IN OUT NOCOPY hookPaymentTabType,
     x_hookDocsInPmtTab  IN OUT NOCOPY hookDocsInPaymentTabType
     );

 /*--------------------------------------------------------------------
 | NAME:
 |     performPreHookProcess
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performPreHookProcess(
     p_cap_payreq_cd     IN            VARCHAR2,
     p_ppr_id	         IN	       NUMBER,
     l_prehook_cnt       OUT     NOCOPY      NUMBER,
     p_cap_id            IN            NUMBER
 --    x_paymentTab        IN OUT NOCOPY paymentTabType,
 --     x_docsInPmtTab      IN OUT NOCOPY docsInPaymentTabType,
 --    x_hookPaymentTab    IN OUT NOCOPY hookPaymentTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     performPostHookProcess
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:         Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performPostHookProcess(
     x_paymentTab        IN OUT NOCOPY paymentTabType,
     x_docsInPmtTab      IN OUT NOCOPY docsInPaymentTabType,
     x_hookPaymentTab    IN OUT NOCOPY hookPaymentTabType,
     x_hookDocsInPmtTab  IN OUT NOCOPY hookDocsInPaymentTabType,
     x_docErrorTab       IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab        IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                            trxnErrTokenTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     performPostHookProcess
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performPostHookProcess(
 --    x_paymentTab        IN OUT NOCOPY paymentTabType,
 --     x_docsInPmtTab      IN OUT NOCOPY docsInPaymentTabType,
 --    x_hookPaymentTab    IN OUT NOCOPY hookPaymentTabType,
 --    x_hookDocsInPmtTab  IN OUT NOCOPY hookDocsInPaymentTabType,
     p_cap_payreq_cd	 IN VARCHAR2,
     l_prehook_count     IN NUMBER,
     x_docErrorTab       IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab        IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                            trxnErrTokenTabType
     );
/*--------------------------------------------------------------------
 | NAME:
 |     adjustSisterDocsAndPmts
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:         Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE adjustSisterDocsAndPmts(
     x_paymentTab        IN OUT NOCOPY paymentTabType,
     x_docsInPmtTab      IN OUT NOCOPY docsInPaymentTabType,
     x_docErrorTab       IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab        IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                            trxnErrTokenTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     adjustSisterDocsAndPmts
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE adjustSisterDocsAndPmts(
 --    x_paymentTab        IN OUT NOCOPY paymentTabType,
 --     x_docsInPmtTab      IN OUT NOCOPY docsInPaymentTabType,
     x_docErrorTab       IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab        IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                            trxnErrTokenTabType
     );


 PROCEDURE adjustSisterDocsAndPmtsPost(
--     x_paymentTab     IN OUT NOCOPY paymentTabType,
--     x_docsInPmtTab   IN OUT NOCOPY docsInPaymentTabType,
     x_docErrorTab    IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab    IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
     );



/*--------------------------------------------------------------------
 | NAME:
 |     handleJapaneseBankCharges
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:       Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE handleJapaneseBankCharges(
     p_cap_payreq_cd     IN            VARCHAR2,
     p_cap_id            IN            NUMBER,
     x_paymentTab        IN OUT NOCOPY paymentTabType,
     x_docsInPmtTab      IN OUT NOCOPY docsInPaymentTabType,
     x_docErrorTab       IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab        IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                            trxnErrTokenTabType
     );

 /*--------------------------------------------------------------------
 | NAME:
 |     handleJapaneseBankCharges
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE handleJapaneseBankCharges(
     p_cap_payreq_cd     IN            VARCHAR2,
     p_ppr_id	         IN	       NUMBER,
     p_cap_id            IN            NUMBER,
 --    x_paymentTab        IN OUT NOCOPY paymentTabType,
 --     x_docsInPmtTab      IN OUT NOCOPY docsInPaymentTabType,
     x_docErrorTab       IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab        IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                            trxnErrTokenTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     performExtendedWitholding
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:       Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performExtendedWitholding(
     p_cap_payreq_cd     IN            VARCHAR2,
     p_cap_id            IN            NUMBER,
     x_paymentTab        IN OUT NOCOPY paymentTabType,
     x_docsInPmtTab      IN OUT NOCOPY docsInPaymentTabType,
     x_docErrorTab       IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab        IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                            trxnErrTokenTabType
     );

 /*--------------------------------------------------------------------
 | NAME:
 |     performExtendedWitholding
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performExtendedWitholding(
     p_cap_payreq_cd     IN            VARCHAR2,
     p_ppr_id	         IN	       NUMBER,
     p_cap_id            IN            NUMBER,
 --    x_paymentTab        IN OUT NOCOPY paymentTabType,
 --     x_docsInPmtTab      IN OUT NOCOPY docsInPaymentTabType,
     x_docErrorTab       IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab        IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                            trxnErrTokenTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     getDocDetails
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION getDocDetails(
     p_documentID         In NUMBER,
     p_pmtDetailsFormula  IN VARCHAR2
     )
     RETURN VARCHAR2;

/*--------------------------------------------------------------------
 | NAME:
 |     callHook
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE callHook(
     p_payreq_id       IN IBY_PAY_SERVICE_REQUESTS.
                              payment_service_request_id%type
     );

/*--------------------------------------------------------------------
 | NAME:
 |     getAdjustedPaymentData
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:         Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE getAdjustedPaymentData(
     x_hookPaymentTab      IN OUT NOCOPY hookPaymentTabType,
     x_hookDocsInPmtTab    IN OUT NOCOPY hookDocsInPaymentTabType
     );


 /*--------------------------------------------------------------------
 | NAME:
 |     getAdjustedPaymentData
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE getAdjustedPaymentData(
     x_hookPaymentTab      IN OUT NOCOPY hookPaymentTabType
 --    x_hookDocsInPmtTab    IN OUT NOCOPY hookDocsInPaymentTabType
     );


/*--------------------------------------------------------------------
 | NAME:
 |     performPayReqBasedValidations
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:       Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performPayReqBasedValidations(
     p_payReqCriteria  IN            payReqImposedCriteria,
     x_paymentTab      IN OUT NOCOPY paymentTabType,
     x_docsInPmtTab    IN OUT NOCOPY docsInPaymentTabType,
     x_docErrorTab     IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab     IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
     );


/*--------------------------------------------------------------------
 | NAME:
 |     performPayReqBasedValidations
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performPayReqBasedValidations(
     p_payReqCriteria  IN            payReqImposedCriteria,
    -- x_paymentTab      IN OUT NOCOPY paymentTabType,
     p_trx_pmt_line_index IN BINARY_INTEGER,
     x_docErrorTab        IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab        IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     performPmtGrpNumberValidation
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performPmtGrpNumberValidation(
     x_paymentTab     IN OUT NOCOPY paymentTabType,
     x_docsInPmtTab   IN OUT NOCOPY docsInPaymentTabType,
     x_docErrorTab    IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab    IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     failDocsOfPayment
 |
 | PURPOSE:
 |     For a given payment id, this method sets all the documents of
 |     that payment to 'failed' status in the PLSQL table of documents.
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:       Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE failDocsOfPayment(
     p_paymentId      IN            IBY_PAYMENTS_ALL.payment_id%TYPE,
     p_docStatus      IN            IBY_DOCS_PAYABLE_ALL.
                                          document_status%TYPE,
     x_docsInPmtTab   IN OUT NOCOPY docsInPaymentTabType,
     x_docErrorTab    IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab    IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     failDocsOfPayment
 |
 | PURPOSE:
 |     For a given payment id, this method sets all the documents of
 |     that payment to 'failed' status in the PLSQL table of documents.
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE failDocsOfPayment(
     p_paymentId      IN            IBY_PAYMENTS_ALL.payment_id%TYPE,
     p_docStatus      IN            IBY_DOCS_PAYABLE_ALL.
                                          document_status%TYPE,
     x_docErrorTab    IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab    IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     applyPaymentValidationSets
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:       Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE applyPaymentValidationSets(
     p_payment_request_id   IN IBY_PAY_SERVICE_REQUESTS.
                                   payment_service_request_id%TYPE,
     x_paymentTab    IN OUT NOCOPY paymentTabType,
     x_docsInPmtTab  IN OUT NOCOPY docsInPaymentTabType,
     x_docErrorTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     applyPaymentValidationSets
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE applyPaymentValidationSets(
     p_payment_request_id   IN IBY_PAY_SERVICE_REQUESTS.
                                   payment_service_request_id%TYPE,
     --x_paymentTab    IN OUT NOCOPY paymentTabType,
     l_trx_valid_index  IN BINARY_INTEGER,
     x_docErrorTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     raiseBizEvents
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE raiseBizEvents(
     p_payreq_id          IN            VARCHAR2,
     p_cap_payreq_cd      IN            VARCHAR2,
     p_cap_id             IN            NUMBER,
     p_rej_level          IN            VARCHAR2,
     p_review_pmts_flag   IN            VARCHAR2,
     p_allPmtsSuccessFlag IN            BOOLEAN,
     p_allPmtsFailedFlag  IN            BOOLEAN
     );

/*--------------------------------------------------------------------
 | NAME:
 |     getXMLClob
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION getXMLClob(
     p_payreq_id     IN VARCHAR2
     )
     RETURN CLOB;

/*--------------------------------------------------------------------
 | NAME:
 |     getRejectedDocs
 |
 | PURPOSE:
 |     Performs a database query to get all failed documents which
 |     are part of payments created for the given payment request.
 |     These failed documents are put into data structure and
 |     returned to the caller.
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 |
 *---------------------------------------------------------------------*/
 PROCEDURE getRejectedDocs(
     p_payreq_id    IN VARCHAR2,
     x_docIDTab     IN OUT NOCOPY IBY_DISBURSE_UI_API_PUB_PKG.docPayIDTab,
     x_docStatusTab IN OUT NOCOPY IBY_DISBURSE_UI_API_PUB_PKG.docPayStatusTab
     );

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfPmtAlreadyFailed
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION checkIfPmtAlreadyFailed(
     p_paymentId   IN   IBY_PAYMENTS_ALL.payment_id%TYPE,
     p_paymentTab  IN   paymentTabType
     )
 RETURN BOOLEAN;

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfPmtAlreadyAdded
 |
 | PURPOSE:
 |     Checks if a payment has already been added to the list of
 |     negative amount payments that qualify for credit memo adjustment.
 |     If yes, this method returns TRUE; else, it return FALSE.
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION checkIfPmtAlreadyAdded(
     p_paymentId   IN   IBY_PAYMENTS_ALL.payment_id%TYPE,
     p_paymentTab  IN   pmtIdsTab
     )
 RETURN BOOLEAN;

/*--------------------------------------------------------------------
 | NAME:
 |     performCreditMemoHandling
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performCreditMemoHandling(
     x_paymentTab    IN OUT NOCOPY paymentTabType,
     x_docsInPmtTab  IN OUT NOCOPY docsInPaymentTabType
     );


/*--------------------------------------------------------------------
 | NAME:
 |     adjustCreditMemosWithinPmt
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE adjustCreditMemosWithinPmt(
     p_qualifyingPmtsTab IN            pmtIdsTab,
     x_paymentTab        IN OUT NOCOPY paymentTabType,
     x_docsInPmtTab      IN OUT NOCOPY docsInPaymentTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     performMaturityDateCalculation
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:     Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performMaturityDateCalculation(
     x_paymentTab    IN OUT NOCOPY paymentTabType,
     p_docsInPmtTab  IN            docsInPaymentTabType
     );



 /*--------------------------------------------------------------------
 | NAME:
 |     performMaturityDateCalculation
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performMaturityDateCalculation(
     p_trx_mat_index IN BINARY_INTEGER
     );




/*--------------------------------------------------------------------
 | NAME:
 |     loadPmtMethodMaturityDays
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:     Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE loadPmtMethodMaturityDays(
     x_maturityDaysTab    IN OUT NOCOPY pmtMethodMaturityDaysTab
     );

 /*--------------------------------------------------------------------
 | NAME:
 |     getMaturityDaysForPmtMethod
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:       Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 FUNCTION getMaturityDaysForPmtMethod(
     p_pmt_method_code    IN  IBY_PAYMENTS_ALL.payment_method_code%TYPE,
     p_maturityDaysTab    IN  pmtMethodMaturityDaysTab
     ) RETURN NUMBER;

/*--------------------------------------------------------------------
 | NAME:
 |     getMaturityDaysForPmtMethod
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION getMaturityDaysForPmtMethod(
     p_pmt_method_code    IN  IBY_PAYMENTS_ALL.payment_method_code%TYPE
     ) RETURN NUMBER;

/*--------------------------------------------------------------------
 | NAME:
 |     refreshDocAndPmtAmounts
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE refreshDocAndPmtAmounts(
     p_adjustedPmtId      IN            IBY_PAYMENTS_ALL.payment_id%TYPE,
     p_adjustedNegDocsTab IN            docsInPaymentTabType,
     x_paymentTab         IN OUT NOCOPY paymentTabType,
     x_docsInPmtTab       IN OUT NOCOPY docsInPaymentTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     getListOfQualifyingNegPmts
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE getListOfQualifyingNegPmts(
     x_negPmtsTab    IN OUT NOCOPY pmtIdsTab,
     p_paymentTab    IN paymentTabType,
     p_docsInPmtTab  IN docsInPaymentTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     dummyGLAPI
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE dummyGLAPI(
     p_exch_date          IN         DATE,
     p_source_amount      IN         NUMBER,
     p_source_curr        IN         VARCHAR2,
     p_decl_curr          IN         VARCHAR2,
     p_decl_fx_rate_type  IN         VARCHAR2,
     x_decl_amount        OUT NOCOPY NUMBER);

/*--------------------------------------------------------------------
 | NAME:
 |     dummy_paymentsAdjustHook
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE dummy_paymentsAdjustHook(
     x_paymentTab      IN OUT NOCOPY hookPaymentTabType,
     x_docsInPmtTab    IN OUT NOCOPY hookDocsInPaymentTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     dummy_ruleFunction
 |
 | PURPOSE:
 |     Dummy method; to be used for testing purposes.
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION dummy_ruleFunction(
     p_subscription IN            RAW,
     p_event        IN OUT NOCOPY WF_EVENT_T
     )
     RETURN VARCHAR2;

/*--------------------------------------------------------------------
 | NAME:
 |     printDocsInPmtTab
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE printDocsInPmtTab(
     p_docsInPmtTab    IN docsInPaymentTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     getPmtRejLevelSysOption
 |
 | PURPOSE:
 |     Gets the payment rejection level system option.
 |
 |     The handling of payment validation failures is dependent
 |     upon the rejection level setting.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION getPmtRejLevelSysOption RETURN VARCHAR2;

/*--------------------------------------------------------------------
 | NAME:
 |     getReviewPmtsSysOption
 |
 | PURPOSE:
 |     Gets the review payment flag system option.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION getReviewPmtsSysOption RETURN VARCHAR2;

/*--------------------------------------------------------------------
 | NAME:
 |     populateLEsOnPmts
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE populateLEsOnPmts(
     x_paymentTab      IN OUT NOCOPY paymentTabType,
     p_bankAccountLEs  IN            bankAccountLETabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     initializePmts
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE initializePmts(
     x_paymentTab      IN OUT NOCOPY paymentTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     get_payreq_status
 |
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION get_payreq_status (
     l_payreq_id IN IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE)
     RETURN VARCHAR2;

 /*--------------------------------------------------------------------
 | NAME:
 |     rebuildPayments
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:       Mark for Removal after Dependencies Checking
 |
 *---------------------------------------------------------------------*/
 PROCEDURE rebuildPayments(
     p_payment_request_id   IN IBY_PAY_SERVICE_REQUESTS.
                                         payment_service_request_id%TYPE,
     x_paymentTab           IN OUT NOCOPY IBY_PAYGROUP_PUB.paymentTabType,
     x_docsInPmtTab         IN OUT NOCOPY IBY_PAYGROUP_PUB.
                                              docsInPaymentTabType,
     x_ca_id                IN OUT NOCOPY IBY_PAY_SERVICE_REQUESTS.
                                              calling_app_id%TYPE,
     x_ca_payreq_cd         IN OUT NOCOPY IBY_PAY_SERVICE_REQUESTS.
                                              call_app_pay_service_req_code
                                              %TYPE,
     x_payReqCriteria       IN OUT NOCOPY IBY_PAYGROUP_PUB.
                                              payReqImposedCriteria
--  ,x_cbrTab               IN OUT NOCOPY IBY_PAYGROUP_PUB.
--                                            centralBankReportTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     rebuildPayments
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE rebuildPayments(
     p_payment_request_id   IN IBY_PAY_SERVICE_REQUESTS.
                                         payment_service_request_id%TYPE,
     x_paymentTab           IN OUT NOCOPY IBY_PAYGROUP_PUB.paymentTabType,
 --    x_docsInPmtTab         IN OUT NOCOPY IBY_PAYGROUP_PUB.
 --                                             docsInPaymentTabType,
     x_ca_id                IN OUT NOCOPY IBY_PAY_SERVICE_REQUESTS.
                                              calling_app_id%TYPE,
     x_ca_payreq_cd         IN OUT NOCOPY IBY_PAY_SERVICE_REQUESTS.
                                              call_app_pay_service_req_code
                                              %TYPE,
     x_payReqCriteria       IN OUT NOCOPY IBY_PAYGROUP_PUB.
                                              payReqImposedCriteria
--  ,x_cbrTab               IN OUT NOCOPY IBY_PAYGROUP_PUB.
--                                            centralBankReportTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     auditPaymentData
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE auditPaymentData(
     p_paymentTab      IN paymentTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     auditPaymentData
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE auditPaymentData(
    l_trx_audit_index IN BINARY_INTEGER
     );

/*--------------------------------------------------------------------
 | NAME:
 |     insertAuditData
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE insertAuditData(
     p_auditPmtTab    IN paymentAuditTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     sweepCommonPmtAttributes
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE sweepCommonPmtAttributes (
     x_paymentTab      IN OUT NOCOPY IBY_PAYGROUP_PUB.paymentTabType,
     x_docsInPmtTab    IN OUT NOCOPY IBY_PAYGROUP_PUB.docsInPaymentTabType
     );

 /*--------------------------------------------------------------------
 | NAME:
 |     GET_PAYER_INFO
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 |
 |
 *---------------------------------------------------------------------*/
 PROCEDURE GET_PAYER_INFO(
	l_trx_payer_index      IN BINARY_INTEGER
     );



 /*--------------------------------------------------------------------
 | NAME:
 |     GET_PAYER_ACCT_INFO
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 |
 |
 *---------------------------------------------------------------------*/
 PROCEDURE GET_PAYER_ACCT_INFO(
	l_trx_acct_index      IN BINARY_INTEGER
     );


 /*--------------------------------------------------------------------
 | NAME:
 |     GET_VENDOR_INFO
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 |
 |
 *---------------------------------------------------------------------*/
 PROCEDURE GET_VENDOR_INFO(
	l_trx_vend_index      IN BINARY_INTEGER
     );

 PROCEDURE GET_PAYEE(
	l_trx_payee_index      IN BINARY_INTEGER
     );

  /*--------------------------------------------------------------------
 | NAME:
 |     GET_PAYEE_SITE_INFO
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 |
 |
 *---------------------------------------------------------------------*/
 PROCEDURE GET_PAYEE_SITE_INFO(
	l_trx_payee_index      IN BINARY_INTEGER
     );



 /*--------------------------------------------------------------------
 | NAME:
 |     GET_PAYEE_ADDR_INFO
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 |
 |
 *---------------------------------------------------------------------*/
 PROCEDURE GET_PAYEE_ADDR_INFO(
	l_trx_paye_adr_index      IN BINARY_INTEGER
     );

  /*--------------------------------------------------------------------
 | NAME:
 |     GET_PAYEE_BANK_INFO
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 |
 |
 *---------------------------------------------------------------------*/
 PROCEDURE GET_PAYEE_BANK_INFO(
	l_trx_payee_bnk_index      IN BINARY_INTEGER
     );


  PROCEDURE GET_REMITTANCE_INFO(
	l_trx_acct_index      IN BINARY_INTEGER
     );


  PROCEDURE GET_PPR_INFO(
	l_trx_ppr_index      IN BINARY_INTEGER
     );

 PROCEDURE GET_DELIVERY_INFO(
	l_trx_delv_index      IN BINARY_INTEGER
     );

 PROCEDURE GET_ORG_INFO(
	l_trx_org_index      IN BINARY_INTEGER
     );

 PROCEDURE GET_PMTREASON_INFO(
	l_trx_pmtr_index      IN BINARY_INTEGER
     );



 PROCEDURE populatepmtTable(
	ppr_id      IN IBY_PAYMENTS_ALL.PAYMENT_SERVICE_REQUEST_ID%type
     );

 /*--------------------------------------------------------------------
 | NAME:
 |     negativePmtAmountCheck
 |
 | PURPOSE: Validation to check that payment amount is not a negative
 |value
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES: Added for the bug 7344352
 |
 *---------------------------------------------------------------------*/
 PROCEDURE negativePmtAmountCheck(
     p_trx_pmt_line_index IN BINARY_INTEGER,
     x_docErrorTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
     );

 /*--------------------------------------------------------------------
 | NAME:
 |     initialize_pmt_table
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/

 PROCEDURE initialize_pmt_table(l_trx_pmt_index IN BINARY_INTEGER);

END IBY_PAYGROUP_PUB;

/
