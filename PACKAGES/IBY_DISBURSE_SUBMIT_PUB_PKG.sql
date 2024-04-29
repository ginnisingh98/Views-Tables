--------------------------------------------------------
--  DDL for Package IBY_DISBURSE_SUBMIT_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_DISBURSE_SUBMIT_PUB_PKG" AUTHID CURRENT_USER AS
/*$Header: ibybilds.pls 120.22.12010000.7 2010/02/05 00:31:15 svinjamu ship $*/

 TYPE payreq_tbl_type IS TABLE of iby_pay_service_requests.
                                      payment_service_request_id%TYPE
    INDEX BY BINARY_INTEGER;

 --
 -- These two records store the distinct payment
 -- functions, and orgs that are present in a
 -- payment request.
 --
 -- The disbursement UI uses the data in this table to
 -- restrict access to the user (depending upon the
 -- users' payment function and organization).
 --
 --
 -- Table of distinct access types.
 --
 TYPE distinctPmtFxAccessTab IS TABLE OF IBY_PROCESS_FUNCTIONS%ROWTYPE
     INDEX BY BINARY_INTEGER;

 TYPE distinctOrgAccessTab IS TABLE OF IBY_PROCESS_ORGS%ROWTYPE
     INDEX BY BINARY_INTEGER;

 -- Bug 5709596
 -- Table of Payment Process Profiles
 --
 TYPE paymentProfilesTabType IS TABLE OF IBY_PAYMENT_PROFILES%ROWTYPE
     INDEX BY BINARY_INTEGER;

 paymentProfilesTab paymentProfilesTabType;

 --
 -- Record that stores the default processing attributes derived
 -- from the payment profile. These processing attributes are
 -- used in payment instruction creation.
 --
 TYPE profileProcessAttribs IS RECORD (
     processing_type
         IBY_SYS_PMT_PROFILES_B.processing_type%TYPE,
     payment_doc_id
         CE_PAYMENT_DOCUMENTS.payment_document_id%TYPE,
     printer_name
         IBY_SYS_PMT_PROFILES_B.default_printer%TYPE,
     print_now_flag
         IBY_SYS_PMT_PROFILES_B.print_instruction_immed_flag%TYPE,
     transmit_now_flag
         IBY_SYS_PMT_PROFILES_B.transmit_instr_immed_flag%TYPE
 );

 TYPE t_pay_proc_trxn_type_code IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.pay_proc_trxn_type_code%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_calling_app_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.calling_app_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_calling_app_doc_ref_number IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.calling_app_doc_ref_number%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_call_app_pay_srvc_req_cd IS TABLE OF
     IBY_GEN_DOCS_PAYABLE.call_app_pay_service_req_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_document_payable_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_function IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.payment_function%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_date IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.payment_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_document_date IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.document_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_document_type IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.document_type%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_document_status IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.document_status%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_document_currency_code IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.document_currency_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_document_amount IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.document_amount%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_currency_code IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.payment_currency_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_amount IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.payment_amount%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_payment_service_request_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.payment_service_request_id%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_payment_method_code IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.payment_method_code%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_exclusive_payment_flag IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.exclusive_payment_flag%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_straight_through_flag IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.straight_through_flag%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_ext_payee_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.ext_payee_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payee_party_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.payee_party_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_legal_entity_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.legal_entity_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_org_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.org_id%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_allow_removing_document_flag IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.allow_removing_document_flag%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_created_by IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.created_by%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_creation_date IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.creation_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_last_updated_by IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.last_updated_by%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_last_update_date IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.last_update_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_object_version_number IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.object_version_number%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_calling_app_doc_unique_ref1 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref1%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_calling_app_doc_unique_ref2 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref2%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_calling_app_doc_unique_ref3 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref3%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_calling_app_doc_unique_ref4 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref4%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_calling_app_doc_unique_ref5 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref5%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_last_update_login IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.last_update_login%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_party_site_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.party_site_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_supplier_site_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.supplier_site_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_beneficiary_party IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.beneficiary_party%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_org_type IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.org_type%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_anticipated_value_date IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.anticipated_value_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_po_number IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.po_number%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_document_description IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.document_description%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_document_currency_tax_amount IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.document_currency_tax_amount%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_document_curr_charge_amount IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.document_curr_charge_amount%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_amount_withheld IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.amount_withheld%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_curr_discount_taken IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.payment_curr_discount_taken%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_discount_date IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.discount_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_due_date IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.payment_due_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_profile_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.payment_profile_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.payment_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_formatting_payment_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.formatting_payment_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_internal_bank_account_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.internal_bank_account_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_external_bank_account_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.external_bank_account_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_bank_charge_bearer IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.bank_charge_bearer%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_interest_rate IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.interest_rate%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_grouping_number IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.payment_grouping_number%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_reason_code IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.payment_reason_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_reason_comments IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.payment_reason_comments%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_settlement_priority IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.settlement_priority%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_remittance_message1 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.remittance_message1%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_remittance_message2 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.remittance_message2%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_remittance_message3 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.remittance_message3%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_unique_remittance_identifier IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.unique_remittance_identifier%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_uri_check_digit IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.uri_check_digit%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_delivery_channel_code IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.delivery_channel_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_format_code IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.payment_format_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_document_sequence_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.document_sequence_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_document_sequence_value IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.document_sequence_value%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_document_category_code IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.document_category_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_bank_assigned_ref_code IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.bank_assigned_ref_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_remit_to_location_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.remit_to_location_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_completed_pmts_group_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.completed_pmts_group_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_rejected_docs_group_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.rejected_docs_group_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute_category IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.attribute_category%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute1 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.attribute1%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute2 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.attribute2%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute3 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.attribute3%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute4 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.attribute4%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute5 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.attribute5%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute6 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.attribute6%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute7 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.attribute7%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute8 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.attribute8%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute9 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.attribute9%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute10 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.attribute10%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute11 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.attribute11%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute12 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.attribute12%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute13 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.attribute13%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute14 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.attribute14%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute15 IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.attribute15%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_address_source IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.address_source%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_employee_address_code IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.employee_address_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_employee_payment_flag IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.employee_payment_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_employee_person_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.employee_person_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_employee_address_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.employee_address_id%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_bank_instruction1_code IS TABLE OF
     IBY_EXTERNAL_PAYEES_ALL.bank_instruction1_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_bank_instruction2_code IS TABLE OF
     IBY_EXTERNAL_PAYEES_ALL.bank_instruction2_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_text_message1 IS TABLE OF
     IBY_EXTERNAL_PAYEES_ALL.payment_text_message1%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_text_message2 IS TABLE OF
     IBY_EXTERNAL_PAYEES_ALL.payment_text_message2%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_text_message3 IS TABLE OF
     IBY_EXTERNAL_PAYEES_ALL.payment_text_message3%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_group_by_remittance_message IS TABLE OF
     IBY_PMT_CREATION_RULES.group_by_remittance_message%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_group_by_bank_charge_bearer IS TABLE OF
     IBY_PMT_CREATION_RULES.group_by_bank_charge_bearer%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_group_by_delivery_channel IS TABLE OF
     IBY_PMT_CREATION_RULES.group_by_delivery_channel%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_grp_by_settle_priority_flag IS TABLE OF
     IBY_PMT_CREATION_RULES.group_by_settle_priority_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_grp_by_payment_details_flag IS TABLE OF
     IBY_PMT_CREATION_RULES.group_by_payment_details_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_details_length_limit IS TABLE OF
     IBY_PMT_CREATION_RULES.payment_details_length_limit%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_details_formula IS TABLE OF
     IBY_PMT_CREATION_RULES.payment_details_formula%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_group_by_max_documents_flag IS TABLE OF
     IBY_PMT_CREATION_RULES.group_by_max_documents_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_max_documents_per_payment IS TABLE OF
     IBY_PMT_CREATION_RULES.max_documents_per_payment%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_grp_by_unique_remit_id_flag IS TABLE OF
     IBY_PMT_CREATION_RULES.group_by_unique_remit_id_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_group_by_payment_reason IS TABLE OF
     IBY_PMT_CREATION_RULES.group_by_payment_reason%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_group_by_due_date_flag IS TABLE OF
     IBY_PMT_CREATION_RULES.group_by_due_date_flag%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_processing_type IS TABLE OF
     IBY_PAYMENT_PROFILES.processing_type%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_declaration_option IS TABLE OF
     IBY_PAYMENT_PROFILES.declaration_option%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_dcl_only_foren_curr_pmt_flag IS TABLE OF
     IBY_PAYMENT_PROFILES.dcl_only_foreign_curr_pmt_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_dcl_curr_fx_rate_type IS TABLE OF
     IBY_PAYMENT_PROFILES.declaration_curr_fx_rate_type%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_declaration_currency_code IS TABLE OF
     IBY_PAYMENT_PROFILES.declaration_currency_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_declaration_threshold_amount IS TABLE OF
     IBY_PAYMENT_PROFILES.declaration_threshold_amount%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_maximum_payment_amount IS TABLE OF
     IBY_PAY_SERVICE_REQUESTS.maximum_payment_amount%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_minimum_payment_amount IS TABLE OF
     IBY_PAY_SERVICE_REQUESTS.minimum_payment_amount%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_allow_zero_payments_flag IS TABLE OF
     IBY_PAY_SERVICE_REQUESTS.allow_zero_payments_flag%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_support_bills_payable_flag IS TABLE OF
     IBY_PAYMENT_METHODS_B.support_bills_payable_flag%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_iba_legal_entity_id IS TABLE OF
     CE_BANK_ACCOUNTS.account_owner_org_id%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_int_bank_country_code IS TABLE OF
     CE_BANK_BRANCHES_V.country%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_ext_bank_country_code IS TABLE OF
     IBY_EXT_BANK_ACCOUNTS_V.country_code%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE t_foreign_pmts_allowed_flag IS TABLE OF
     IBY_EXT_BANK_ACCOUNTS_V.foreign_payment_use_flag%TYPE
     INDEX BY BINARY_INTEGER;

  /*TPP-Start*/
 TYPE t_inv_payee_party_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.inv_payee_party_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_inv_party_site_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.inv_party_site_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_inv_supplier_site_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.inv_supplier_site_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_inv_beneficiary_party IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.inv_beneficiary_party%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_ext_inv_payee_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.ext_inv_payee_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_relationship_id IS TABLE OF
     IBY_DOCS_PAYABLE_ALL.relationship_id%TYPE
     INDEX BY BINARY_INTEGER;
  /*TPP-End*/

  /*German Format*/
 TYPE t_global_attribute_category IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute_category%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute1 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute1%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute2 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute2%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute3 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute3%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute4 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute4%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute5 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute5%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute6 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute6%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute7 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute7%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute8 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute8%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute9 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute9%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute10 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute10%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute11 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute11%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute12 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute12%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute13 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute13%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute14 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute14%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute15 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute15%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute16 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute16%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute17 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute17%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute18 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute18%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute19 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute19%TYPE
   INDEX BY BINARY_INTEGER;
 TYPE t_global_attribute20 IS TABLE OF
   IBY_DOCS_PAYABLE_ALL.global_attribute20%TYPE
   INDEX BY BINARY_INTEGER;
  /*German Format*/

 TYPE t_dont_pay_flag IS TABLE OF
     VARCHAR2(1)
     INDEX BY BINARY_INTEGER;

 TYPE t_dont_pay_reason_code IS TABLE OF
     VARCHAR2(30)
     INDEX BY BINARY_INTEGER;

 TYPE t_dont_pay_description IS TABLE OF
     VARCHAR2(255)
     INDEX BY BINARY_INTEGER;

TYPE docs_pay_tab_type IS RECORD
(
 pay_proc_trxn_type_code                  t_pay_proc_trxn_type_code,
 calling_app_id                           t_calling_app_id,
 calling_app_doc_ref_number               t_calling_app_doc_ref_number,
 call_app_pay_service_req_code            t_call_app_pay_srvc_req_cd,
 document_payable_id                      t_document_payable_id,
 payment_function                         t_payment_function,
 payment_date                             t_payment_date,
 document_date                            t_document_date,
 document_type                            t_document_type,
 document_status                          t_document_status,
 document_currency_code                   t_document_currency_code,
 document_amount                          t_document_amount,
 payment_currency_code                    t_payment_currency_code,
 payment_amount                           t_payment_amount,
 payment_service_request_id               t_payment_service_request_id,
 payment_method_code                      t_payment_method_code,
 exclusive_payment_flag                   t_exclusive_payment_flag,
 straight_through_flag                    t_straight_through_flag,
 ext_payee_id                             t_ext_payee_id,
 payee_party_id                           t_payee_party_id,
 legal_entity_id                          t_legal_entity_id,
 org_id                                   t_org_id,
 allow_removing_document_flag             t_allow_removing_document_flag,
 created_by                               t_created_by,
 creation_date                            t_creation_date,
 last_updated_by                          t_last_updated_by,
 last_update_date                         t_last_update_date,
 object_version_number                    t_object_version_number,
 calling_app_doc_unique_ref1              t_calling_app_doc_unique_ref1,
 calling_app_doc_unique_ref2              t_calling_app_doc_unique_ref2,
 calling_app_doc_unique_ref3              t_calling_app_doc_unique_ref3,
 calling_app_doc_unique_ref4              t_calling_app_doc_unique_ref4,
 calling_app_doc_unique_ref5              t_calling_app_doc_unique_ref5,
 last_update_login                        t_last_update_login,
 party_site_id                            t_party_site_id,
 supplier_site_id                         t_supplier_site_id,
 beneficiary_party                        t_beneficiary_party,
 org_type                                 t_org_type,
 anticipated_value_date                   t_anticipated_value_date,
 po_number                                t_po_number,
 document_description                     t_document_description,
 document_currency_tax_amount             t_document_currency_tax_amount,
 document_curr_charge_amount              t_document_curr_charge_amount,
 amount_withheld                          t_amount_withheld,
 payment_curr_discount_taken              t_payment_curr_discount_taken,
 discount_date                            t_discount_date,
 payment_due_date                         t_payment_due_date,
 payment_profile_id                       t_payment_profile_id,
 payment_id                               t_payment_id,
 formatting_payment_id                    t_formatting_payment_id,
 internal_bank_account_id                 t_internal_bank_account_id,
 external_bank_account_id                 t_external_bank_account_id,
 bank_charge_bearer                       t_bank_charge_bearer,
 interest_rate                            t_interest_rate,
 payment_grouping_number                  t_payment_grouping_number,
 payment_reason_code                      t_payment_reason_code,
 payment_reason_comments                  t_payment_reason_comments,
 settlement_priority                      t_settlement_priority,
 remittance_message1                      t_remittance_message1,
 remittance_message2                      t_remittance_message2,
 remittance_message3                      t_remittance_message3,
 unique_remittance_identifier             t_unique_remittance_identifier,
 uri_check_digit                          t_uri_check_digit,
 delivery_channel_code                    t_delivery_channel_code,
 payment_format_code                      t_payment_format_code,
 document_sequence_id                     t_document_sequence_id,
 document_sequence_value                  t_document_sequence_value,
 document_category_code                   t_document_category_code,
 bank_assigned_ref_code                   t_bank_assigned_ref_code,
 remit_to_location_id                     t_remit_to_location_id,
 completed_pmts_group_id                  t_completed_pmts_group_id,
 rejected_docs_group_id                   t_rejected_docs_group_id,
 attribute_category                       t_attribute_category,
 attribute1                               t_attribute1,
 attribute2                               t_attribute2,
 attribute3                               t_attribute3,
 attribute4                               t_attribute4,
 attribute5                               t_attribute5,
 attribute6                               t_attribute6,
 attribute7                               t_attribute7,
 attribute8                               t_attribute8,
 attribute9                               t_attribute9,
 attribute10                              t_attribute10,
 attribute11                              t_attribute11,
 attribute12                              t_attribute12,
 attribute13                              t_attribute13,
 attribute14                              t_attribute14,
 attribute15                              t_attribute15,
 address_source                           t_address_source,
 employee_address_code                    t_employee_address_code,
 employee_payment_flag                    t_employee_payment_flag,
 employee_person_id                       t_employee_person_id,
 employee_address_id                      t_employee_address_id,
 bank_instruction1_code                   t_bank_instruction1_code,
 bank_instruction2_code                   t_bank_instruction2_code,
 payment_text_message1                    t_payment_text_message1,
 payment_text_message2                    t_payment_text_message2,
 payment_text_message3                    t_payment_text_message3,
 group_by_remittance_message              t_group_by_remittance_message,
 group_by_bank_charge_bearer              t_group_by_bank_charge_bearer,
 group_by_delivery_channel                t_group_by_delivery_channel,
 group_by_settle_priority_flag            t_grp_by_settle_priority_flag,
 group_by_payment_details_flag            t_grp_by_payment_details_flag,
 payment_details_length_limit             t_payment_details_length_limit,
 payment_details_formula                  t_payment_details_formula,
 group_by_max_documents_flag              t_group_by_max_documents_flag,
 max_documents_per_payment                t_max_documents_per_payment,
 group_by_unique_remit_id_flag            t_grp_by_unique_remit_id_flag,
 group_by_payment_reason                  t_group_by_payment_reason,
 group_by_due_date_flag                   t_group_by_due_date_flag,
 processing_type                          t_processing_type,
 declaration_option                       t_declaration_option,
 dcl_only_foreign_curr_pmt_flag           t_dcl_only_foren_curr_pmt_flag,
 declaration_curr_fx_rate_type            t_dcl_curr_fx_rate_type,
 declaration_currency_code                t_declaration_currency_code,
 declaration_threshold_amount             t_declaration_threshold_amount,
 maximum_payment_amount                   t_maximum_payment_amount,
 minimum_payment_amount                   t_minimum_payment_amount,
 allow_zero_payments_flag                 t_allow_zero_payments_flag,
 support_bills_payable_flag               t_support_bills_payable_flag,
 iba_legal_entity_id                      t_iba_legal_entity_id,
 int_bank_country_code                    t_int_bank_country_code,
 ext_bank_country_code                    t_ext_bank_country_code,
 foreign_pmts_allowed_flag                t_foreign_pmts_allowed_flag,

  /*TPP-Start*/
 inv_payee_party_id         t_inv_payee_party_id,
 inv_party_site_id          t_inv_party_site_id,
 inv_supplier_site_id       t_inv_supplier_site_id,
 inv_beneficiary_party      t_inv_beneficiary_party,
 ext_inv_payee_id           t_ext_inv_payee_id,
 relationship_id            t_relationship_id,
  /*TPP-End*/

  /*German Format*/
 global_attribute_category               t_global_attribute_category,
 global_attribute1                       t_global_attribute1,
 global_attribute2                       t_global_attribute2,
 global_attribute3                       t_global_attribute3,
 global_attribute4                       t_global_attribute4,
 global_attribute5                       t_global_attribute5,
 global_attribute6                       t_global_attribute6,
 global_attribute7                       t_global_attribute7,
 global_attribute8                       t_global_attribute8,
 global_attribute9                       t_global_attribute9,
 global_attribute10                      t_global_attribute10,
 global_attribute11                      t_global_attribute11,
 global_attribute12                      t_global_attribute12,
 global_attribute13                      t_global_attribute13,
 global_attribute14                      t_global_attribute14,
 global_attribute15                      t_global_attribute15,
 global_attribute16                      t_global_attribute16,
 global_attribute17                      t_global_attribute17,
 global_attribute18                      t_global_attribute18,
 global_attribute19                      t_global_attribute19,
 global_attribute20                      t_global_attribute20,
  /*German Format*/
 dont_pay_flag                            t_dont_pay_flag,
 dont_pay_reason_code                     t_dont_pay_reason_code,
 dont_pay_description                     t_dont_pay_description

 );

 docspayTab                               docs_pay_tab_type;

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
 PROCEDURE delete_docspayTab;

/*--------------------------------------------------------------------
 | NAME:
 |     submit_payment_process_request
 |
 | PURPOSE:
 |     This is the top level procedure of the build program; This
 |     procedure will run as a concurrent program.
 |
 | PARAMETERS:
 |
 |     IN
 |
 |     p_calling_app_id
 |         The 3-character product code of te calling application
 |
 |     p_calling_app_payreq_id
 |         Id of the payment service request from the calling app's
 |         point of view. For a given calling app, this id should be
 |         unique; the build program will communicate back to the calling
 |         app using this payment request id.
 |
 |     p_internal_bank_account_id
 |        The internal bank account to pay from.
 |
 |     p_payment_profile_id
 |        Payment profile
 |
 |     p_allow_zero_payments_flag
 |        'Y' / 'N' flag indicating whether zero value payments are allowed.
 |        If not set, this value will be defaulted to 'N'.
 |
 |     p_payment_date
 |        The payment date.
 |
 |     p_anticipated_value_date
 |        The anticipated value date.
 |
 |     p_maximum_payment_amount
 |        Maximum allowed amount for a single payment. Payments will be
 |        validated against this ceiling.
 |
 |     p_minimum_payment_amount
 |        Minimum allowed amount for a single payment. Payments will be
 |        validated against this floor.
 |
 |     p_create_instrs_flag
 |        'Y' / 'N' flag indicating whether payment instruction creation
 |        should be invoked for this payment service request as soon the
 |        Build Program completes.
 |
 |     p_args12 - p_args100
 |        These 89 parameters are mandatory for any stored procedure
 |        that is submitted from Oracle Forms as a concurrent request.
 |        (to get the total number of args to the concurrent procedure
 |         to 100).
 |
 |     OUT
 |
 |     x_errbuf
 |     x_retcode
 |
 |        These two are mandatory output paramaters for a concurrent
 |        program. They will store the error message and error code
 |        to indicate a successful/failed run of the concurrent request.
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE submit_payment_process_request(
     x_errbuf                     OUT NOCOPY VARCHAR2,
     x_retcode                    OUT NOCOPY VARCHAR2,
     p_calling_app_id             IN         VARCHAR2,
     p_calling_app_payreq_cd      IN         VARCHAR2,
     p_internal_bank_account_id   IN         VARCHAR2 DEFAULT NULL,
     p_payment_profile_id         IN         VARCHAR2 DEFAULT NULL,
     p_allow_zero_payments_flag   IN         VARCHAR2 DEFAULT 'N',
     p_maximum_payment_amount     IN         VARCHAR2 DEFAULT NULL,
     p_minimum_payment_amount     IN         VARCHAR2 DEFAULT NULL,
     p_document_rejection_level   IN         VARCHAR2 DEFAULT NULL,
     p_payment_rejection_level    IN         VARCHAR2 DEFAULT NULL,
     p_review_proposed_pmts_flag  IN         VARCHAR2 DEFAULT 'X',
     p_create_instrs_flag         IN         VARCHAR2 DEFAULT 'N',
     p_payment_document_id        IN         VARCHAR2 DEFAULT NULL,
     p_attribute_category  IN VARCHAR2 DEFAULT NULL, p_attribute1  IN VARCHAR2 DEFAULT NULL,
     p_attribute2  IN VARCHAR2 DEFAULT NULL, p_attribute3  IN VARCHAR2 DEFAULT NULL,
     p_attribute4  IN VARCHAR2 DEFAULT NULL, p_attribute5 IN VARCHAR2 DEFAULT NULL,
     p_attribute6  IN VARCHAR2 DEFAULT NULL, p_attribute7  IN VARCHAR2 DEFAULT NULL,
     p_attribute8  IN VARCHAR2 DEFAULT NULL, p_attribute9  IN VARCHAR2 DEFAULT NULL,
     p_attribute10 IN VARCHAR2 DEFAULT NULL, p_attribute11  IN VARCHAR2 DEFAULT NULL,
     p_attribute12  IN VARCHAR2 DEFAULT NULL, p_attribute13  IN VARCHAR2 DEFAULT NULL,
     p_attribute14  IN VARCHAR2 DEFAULT NULL, p_attribute15  IN VARCHAR2 DEFAULT NULL,
     p_arg30  IN VARCHAR2 DEFAULT NULL, p_arg31  IN VARCHAR2 DEFAULT NULL,
     p_arg32  IN VARCHAR2 DEFAULT NULL, p_arg33  IN VARCHAR2 DEFAULT NULL,
     p_arg34  IN VARCHAR2 DEFAULT NULL, p_arg35  IN VARCHAR2 DEFAULT NULL,
     p_arg36  IN VARCHAR2 DEFAULT NULL, p_arg37  IN VARCHAR2 DEFAULT NULL,
     p_arg38  IN VARCHAR2 DEFAULT NULL, p_arg39  IN VARCHAR2 DEFAULT NULL,
     p_arg40  IN VARCHAR2 DEFAULT NULL, p_arg41  IN VARCHAR2 DEFAULT NULL,
     p_arg42  IN VARCHAR2 DEFAULT NULL, p_arg43  IN VARCHAR2 DEFAULT NULL,
     p_arg44  IN VARCHAR2 DEFAULT NULL, p_arg45  IN VARCHAR2 DEFAULT NULL,
     p_arg46  IN VARCHAR2 DEFAULT NULL, p_arg47  IN VARCHAR2 DEFAULT NULL,
     p_arg48  IN VARCHAR2 DEFAULT NULL, p_arg49  IN VARCHAR2 DEFAULT NULL,
     p_arg50  IN VARCHAR2 DEFAULT NULL, p_arg51  IN VARCHAR2 DEFAULT NULL,
     p_arg52  IN VARCHAR2 DEFAULT NULL, p_arg53  IN VARCHAR2 DEFAULT NULL,
     p_arg54  IN VARCHAR2 DEFAULT NULL, p_arg55  IN VARCHAR2 DEFAULT NULL,
     p_arg56  IN VARCHAR2 DEFAULT NULL, p_arg57  IN VARCHAR2 DEFAULT NULL,
     p_arg58  IN VARCHAR2 DEFAULT NULL, p_arg59  IN VARCHAR2 DEFAULT NULL,
     p_arg60  IN VARCHAR2 DEFAULT NULL, p_arg61  IN VARCHAR2 DEFAULT NULL,
     p_arg62  IN VARCHAR2 DEFAULT NULL, p_arg63  IN VARCHAR2 DEFAULT NULL,
     p_arg64  IN VARCHAR2 DEFAULT NULL, p_arg65  IN VARCHAR2 DEFAULT NULL,
     p_arg66  IN VARCHAR2 DEFAULT NULL, p_arg67  IN VARCHAR2 DEFAULT NULL,
     p_arg68  IN VARCHAR2 DEFAULT NULL, p_arg69  IN VARCHAR2 DEFAULT NULL,
     p_arg70  IN VARCHAR2 DEFAULT NULL, p_arg71  IN VARCHAR2 DEFAULT NULL,
     p_arg72  IN VARCHAR2 DEFAULT NULL, p_arg73  IN VARCHAR2 DEFAULT NULL,
     p_arg74  IN VARCHAR2 DEFAULT NULL, p_arg75  IN VARCHAR2 DEFAULT NULL,
     p_arg76  IN VARCHAR2 DEFAULT NULL, p_arg77  IN VARCHAR2 DEFAULT NULL,
     p_arg78  IN VARCHAR2 DEFAULT NULL, p_arg79  IN VARCHAR2 DEFAULT NULL,
     p_arg80  IN VARCHAR2 DEFAULT NULL, p_arg81  IN VARCHAR2 DEFAULT NULL,
     p_arg82  IN VARCHAR2 DEFAULT NULL, p_arg83  IN VARCHAR2 DEFAULT NULL,
     p_arg84  IN VARCHAR2 DEFAULT NULL, p_arg85  IN VARCHAR2 DEFAULT NULL,
     p_arg86  IN VARCHAR2 DEFAULT NULL, p_arg87  IN VARCHAR2 DEFAULT NULL,
     p_arg88  IN VARCHAR2 DEFAULT NULL, p_arg89  IN VARCHAR2 DEFAULT NULL,
     p_arg90  IN VARCHAR2 DEFAULT NULL, p_arg91  IN VARCHAR2 DEFAULT NULL,
     p_arg92  IN VARCHAR2 DEFAULT NULL, p_arg93  IN VARCHAR2 DEFAULT NULL,
     p_arg94  IN VARCHAR2 DEFAULT NULL, p_arg95  IN VARCHAR2 DEFAULT NULL,
     p_arg96  IN VARCHAR2 DEFAULT NULL, p_arg97  IN VARCHAR2 DEFAULT NULL,
     p_arg98  IN VARCHAR2 DEFAULT NULL, p_arg99  IN VARCHAR2 DEFAULT NULL,
     p_arg100 IN VARCHAR2 DEFAULT NULL
     );

/*--------------------------------------------------------------------
 | NAME:
 |     get_payreq_list
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
 FUNCTION get_payreq_list (
     p_status IN IBY_PAY_SERVICE_REQUESTS.payment_service_request_status%TYPE)
     RETURN payreq_tbl_type;

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
 |     insert_payreq
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
 FUNCTION insert_payreq (
     p_calling_app_id         IN IBY_PAY_SERVICE_REQUESTS.calling_app_id%TYPE,
     p_calling_app_payreq_cd  IN IBY_PAY_SERVICE_REQUESTS.
                                    call_app_pay_service_req_code%TYPE,
     p_internal_bank_account_id
                              IN IBY_PAY_SERVICE_REQUESTS.
                                     internal_bank_account_id%TYPE,
     p_payment_profile_id
                              IN IBY_PAY_SERVICE_REQUESTS.
                                     payment_profile_id%TYPE,
     p_allow_zero_payments_flag
                              IN IBY_PAY_SERVICE_REQUESTS.
                                     allow_zero_payments_flag%TYPE,
     p_maximum_payment_amount IN IBY_PAY_SERVICE_REQUESTS.
                                     maximum_payment_amount%TYPE,
     p_minimum_payment_amount IN IBY_PAY_SERVICE_REQUESTS.
                                     minimum_payment_amount%TYPE,
     p_doc_rej_level          IN IBY_PAY_SERVICE_REQUESTS.
                                     document_rejection_level_code%TYPE,
     p_pmt_rej_level          IN IBY_PAY_SERVICE_REQUESTS.
                                     payment_rejection_level_code%TYPE,
     p_revw_prop_pmts_flag    IN IBY_PAY_SERVICE_REQUESTS.
                                     require_prop_pmts_review_flag%TYPE,
     p_create_instrs_flag     IN IBY_PAY_SERVICE_REQUESTS.
                                     create_pmt_instructions_flag%TYPE,
     p_payment_document_id    IN IBY_PAY_SERVICE_REQUESTS.
                                     payment_document_id%TYPE,
     p_attribute_category     IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute_category%TYPE,
     p_attribute1             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute1%TYPE,
     p_attribute2             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute2%TYPE,
     p_attribute3             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute3%TYPE,
     p_attribute4             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute4%TYPE,
     p_attribute5             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute5%TYPE,
     p_attribute6             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute6%TYPE,
     p_attribute7             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute7%TYPE,
     p_attribute8             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute8%TYPE,
     p_attribute9             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute9%TYPE,
     p_attribute10             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute10%TYPE,
     p_attribute11             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute11%TYPE,
     p_attribute12             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute12%TYPE,
     p_attribute13             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute13%TYPE,
     p_attribute14             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute14%TYPE,
     p_attribute15             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute15%TYPE
     )
     RETURN NUMBER;

/*--------------------------------------------------------------------
 | NAME:
 |     getNextPayReqID
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
 FUNCTION getNextPayReqID
     RETURN NUMBER;

/*--------------------------------------------------------------------
 | NAME:
 |     insert_payreq_documents
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
 FUNCTION insert_payreq_documents (
     p_calling_app_id        IN IBY_PAY_SERVICE_REQUESTS.calling_app_id%TYPE,
     p_calling_app_payreq_cd IN IBY_PAY_SERVICE_REQUESTS.
                                    call_app_pay_service_req_code%TYPE,
     p_payreq_id             IN IBY_PAY_SERVICE_REQUESTS.
                                    payment_service_request_id%TYPE
     )
     RETURN NUMBER;

/*--------------------------------------------------------------------
 | NAME:
 |     getNextDocumentPayableID
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
 FUNCTION getNextDocumentPayableID
     RETURN NUMBER;

/*--------------------------------------------------------------------
 | NAME:
 |     getNextDocumentPayableLineID
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
 FUNCTION getNextDocumentPayableLineID
     RETURN NUMBER;

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfDuplicate
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
 FUNCTION checkIfDuplicate(
     p_calling_app_id         IN IBY_PAY_SERVICE_REQUESTS.calling_app_id%TYPE,
     p_calling_app_payreq_cd  IN IBY_PAY_SERVICE_REQUESTS.
                                    call_app_pay_service_req_code%TYPE
     )
     RETURN NUMBER;

/*--------------------------------------------------------------------
 | NAME:
 |     derivePayeeIdFromContext
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
 FUNCTION derivePayeeIdFromContext(
     p_payee_party_id         IN IBY_EXTERNAL_PAYEES_ALL.payee_party_id%TYPE,
     p_payee_party_site_id    IN IBY_EXTERNAL_PAYEES_ALL.party_site_id%TYPE,
     p_supplier_site_id       IN IBY_EXTERNAL_PAYEES_ALL.supplier_site_id%TYPE,
     p_org_id                 IN IBY_EXTERNAL_PAYEES_ALL.org_id%TYPE,
     p_org_type               IN IBY_EXTERNAL_PAYEES_ALL.org_type%TYPE,
     p_pmt_function           IN IBY_EXTERNAL_PAYEES_ALL.payment_function%TYPE
     )
     RETURN NUMBER;

/*--------------------------------------------------------------------
 | NAME:
 |     deriveExactPayeeIdFromContext
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
 FUNCTION deriveExactPayeeIdFromContext(
     p_payee_party_id         IN IBY_EXTERNAL_PAYEES_ALL.payee_party_id%TYPE,
     p_payee_party_site_id    IN IBY_EXTERNAL_PAYEES_ALL.party_site_id%TYPE,
     p_supplier_site_id       IN IBY_EXTERNAL_PAYEES_ALL.supplier_site_id%TYPE,
     p_org_id                 IN IBY_EXTERNAL_PAYEES_ALL.org_id%TYPE,
     p_org_type               IN IBY_EXTERNAL_PAYEES_ALL.org_type%TYPE,
     p_pmt_function           IN IBY_EXTERNAL_PAYEES_ALL.payment_function%TYPE
     )
     RETURN NUMBER;

/*--------------------------------------------------------------------
 | NAME:
 |     deriveDistinctAccessTypsForReq
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
 PROCEDURE deriveDistinctAccessTypsForReq(
     p_payreq_id           IN IBY_DOCS_PAYABLE_ALL.payment_service_request_id
                                  %TYPE,
     p_pmt_function   IN IBY_DOCS_PAYABLE_ALL.payment_function%TYPE,
     p_org_id         IN IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
     p_org_type       IN IBY_DOCS_PAYABLE_ALL.org_type%TYPE,
     x_pmtFxAccessTypesTab IN OUT NOCOPY distinctPmtFxAccessTab,
     x_orgAccessTypesTab   IN OUT NOCOPY distinctOrgAccessTab
     );

/*--------------------------------------------------------------------
 | NAME:
 |     insertDistinctAccessTypsForReq
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
 PROCEDURE insertDistinctAccessTypsForReq(
     p_pmtFxAccessTypesTab IN distinctPmtFxAccessTab,
     p_orgAccessTypesTab   IN distinctOrgAccessTab
     );

/*--------------------------------------------------------------------
 | NAME:
 |     set_profile_attribs
 |
 |
 | PURPOSE:
 |     Sets the attributes of the payment profile structure
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
 PROCEDURE set_profile_attribs(
     p_profile_id         IN IBY_PAYMENT_PROFILES.payment_profile_id%TYPE
     );

/*--------------------------------------------------------------------
 | NAME:
 |     get_profile_process_attribs
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
 PROCEDURE get_profile_process_attribs(
     p_profile_id         IN IBY_PAYMENT_PROFILES.payment_profile_id%TYPE,
     x_profile_attribs    IN OUT NOCOPY  profileProcessAttribs
     );

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfDefaultPmtDocOnProfile
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
 PROCEDURE checkIfDefaultPmtDocOnProfile (
     p_profile_id   IN     IBY_PAYMENT_PROFILES.payment_profile_id%TYPE,
     x_profile_name IN OUT NOCOPY IBY_PAYMENT_PROFILES.system_profile_name%TYPE,
     x_return_flag  IN OUT NOCOPY BOOLEAN
     );

/*--------------------------------------------------------------------
 | NAME:
 |     print_debuginfo
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
 PROCEDURE print_debuginfo(
     p_module      IN VARCHAR2,
     p_debug_text  IN VARCHAR2,
     p_debug_level IN VARCHAR2  DEFAULT FND_LOG.LEVEL_STATEMENT
     );

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfPmtsInModifiedStatus
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
 FUNCTION checkIfPmtsInModifiedStatus(
     l_payreq_id IN IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE)
     RETURN BOOLEAN;

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfPmtsInModBankAccStatus
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
 FUNCTION checkIfPmtsInModBankAccStatus(
     l_payreq_id IN IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE)
     RETURN BOOLEAN;

/*--------------------------------------------------------------------
 | NAME:
 |     launchPPRStatusReport
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
 PROCEDURE launchPPRStatusReport(
     p_payreq_id      IN      IBY_PAY_SERVICE_REQUESTS.
                                  payment_service_request_id%TYPE
     );


/*--------------------------------------------------------------------
 | NAME:
 |     update_payreq_status
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
 PROCEDURE update_payreq_status (
     l_payreq_id IN IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE,
     l_payreq_status IN IBY_PAY_SERVICE_REQUESTS.payment_service_request_status%TYPE,
     x_return_status  IN OUT NOCOPY VARCHAR2);

 PROCEDURE print_log(
     p_module      IN VARCHAR2,
     p_debug_text  IN VARCHAR2
          );

END IBY_DISBURSE_SUBMIT_PUB_PKG;

/
