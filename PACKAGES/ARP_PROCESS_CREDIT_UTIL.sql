--------------------------------------------------------
--  DDL for Package ARP_PROCESS_CREDIT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_CREDIT_UTIL" AUTHID CURRENT_USER AS
/* $Header: ARTECMUS.pls 120.4.12010000.1 2008/07/24 16:55:43 appldev ship $ */

FUNCTION get_commitment_adjustments(
  p_ct_id                 IN ra_customer_trx.customer_trx_id%type,
  p_commit_ct_id          IN ra_customer_trx.customer_trx_id%type)
RETURN number;

PROCEDURE get_commitment_adj_detail(
  p_ct_id                 IN ra_customer_trx.customer_trx_id%type,
  p_commit_ct_id          IN ra_customer_trx.customer_trx_id%type,
  p_amount                IN OUT NOCOPY number,
  p_line_amount           IN OUT NOCOPY number,
  p_tax_amount            IN OUT NOCOPY number,
  p_freight_amount        IN OUT NOCOPY number);

PROCEDURE get_credited_trx_details(
  p_ct_id                 IN ra_customer_trx.customer_trx_id%type,
  p_commit_ct_id          IN ra_customer_trx.customer_trx_id%type,
  p_orig_line_amount     OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_orig_tax_amount      OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_orig_frt_amount      OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_orig_tot_amount      OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_bal_line_amount      OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_bal_tax_amount       OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_bal_frt_amount       OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_bal_tot_amount       OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_num_line_lines       OUT NOCOPY number,
  p_num_tax_lines        OUT NOCOPY number,
  p_num_frt_lines        OUT NOCOPY number,
  p_num_installments     OUT NOCOPY number,
  p_payment_exist_flag   OUT NOCOPY varchar2);


PROCEDURE get_credit_memo_amounts(
  p_ct_id                 IN ra_customer_trx.customer_trx_id%type,
  p_cm_line_amount        OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_cm_tax_amount         OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_cm_frt_amount         OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_num_line_lines        OUT NOCOPY number,
  p_num_tax_lines         OUT NOCOPY number,
  p_num_frt_lines         OUT NOCOPY number);

PROCEDURE get_cm_header_defaults(
  p_trx_date                     IN
                          ra_customer_trx.trx_date%type,
  p_crtrx_ct_id                  IN
                          ra_customer_trx.customer_trx_id%type,
  p_ct_id                        IN
                          ra_customer_trx.customer_trx_id%type,
  p_bs_id                        IN
                          ra_batch_sources.batch_source_id%type,
  p_gl_date                      IN
                          ra_cust_trx_line_gl_dist.gl_date%type,
  p_currency_code                IN
                          fnd_currencies.currency_code%type,
  p_cust_trx_type_id             IN
                          ra_cust_trx_types.cust_trx_type_id%type,
  p_ship_to_customer_id          IN
                          hz_cust_accounts.cust_account_id%type,
  p_ship_to_site_use_id          IN
                          hz_cust_site_uses.site_use_id%type,
  p_ship_to_contact_id           IN
                          hz_cust_account_roles.cust_account_role_id%type,
  p_bill_to_customer_id          IN
                          hz_cust_accounts.cust_account_id%type,
  p_bill_to_site_use_id          IN
                          hz_cust_site_uses.site_use_id%type,
  p_bill_to_contact_id           IN
                          hz_cust_account_roles.cust_account_role_id%type,
  p_primary_salesrep_id          IN
                          ra_salesreps.salesrep_id%type,
  p_receipt_method_id            IN
                          ar_receipt_methods.receipt_method_id%type,
  p_customer_bank_account_id     IN
                          ce_bank_accounts.bank_account_id%type,
  p_paying_customer_id           IN
                          hz_cust_accounts.cust_account_id%type,
  p_paying_site_use_id           IN
                          hz_cust_site_uses.site_use_id%type,
  p_ship_via                     IN
                          ra_customer_trx.ship_via%type,
  p_fob_point                    IN
                          ra_customer_trx.fob_point%type,
  p_invoicing_rule_id            IN
                          ra_customer_trx.invoicing_rule_id%type,
  p_rev_recog_run_flag           IN
                          varchar2,
  p_complete_flag                IN
                          ra_customer_trx.complete_flag%type,
  p_salesrep_required_flag       IN
                          ar_system_parameters.salesrep_required_flag%type,
--
  p_crtrx_bs_id                  IN
                          ra_batch_sources.batch_source_id%type,
  p_crtrx_cm_bs_id               IN
                          ra_batch_sources.batch_source_id%type,
  p_batch_bs_id                  IN
                          ra_batch_sources.batch_source_id%type,
  p_profile_bs_id                IN
                          ra_batch_sources.batch_source_id%type,
  p_crtrx_type_id                IN
                          ra_cust_trx_types.cust_trx_type_id%type,
  p_crtrx_cm_type_id             IN
                          ra_cust_trx_types.cust_trx_type_id%type,
  p_crtrx_gl_date                IN
                          ra_cust_trx_line_gl_dist.gl_date%type,
  p_batch_gl_date                IN
                          ra_batches.gl_date%type,
--
  p_crtrx_ship_to_customer_id    IN
                          hz_cust_accounts.cust_account_id%type,
  p_crtrx_ship_to_site_use_id    IN
                          hz_cust_site_uses.site_use_id%type,
  p_crtrx_ship_to_contact_id     IN
                          hz_cust_account_roles.cust_account_role_id%type,
  p_crtrx_bill_to_customer_id    IN
                          hz_cust_accounts.cust_account_id%type,
  p_crtrx_bill_to_site_use_id    IN
                          hz_cust_site_uses.site_use_id%type,
  p_crtrx_bill_to_contact_id     IN
                          hz_cust_account_roles.cust_account_role_id%type,
  p_crtrx_primary_salesrep_id    IN
                          ra_salesreps.salesrep_id%type,
  p_crtrx_open_rec_flag          IN
                          ra_cust_trx_types.accounting_affect_flag%type,
--
  p_crtrx_receipt_method_id      IN
                          ar_receipt_methods.receipt_method_id%type,
  p_crtrx_cust_bank_account_id   IN
                          ce_bank_accounts.bank_account_id%type,
  p_crtrx_ship_via               IN
                          ra_customer_trx.ship_via%type,
  p_crtrx_ship_date_actual       IN
                          ra_customer_trx.ship_date_actual%type,
  p_crtrx_waybill_number         IN
                          ra_customer_trx.waybill_number%type,
  p_crtrx_fob_point              IN
                          ra_customer_trx.fob_point%type,
--
  p_default_bs_id                OUT NOCOPY
                          ra_batch_sources.batch_source_id%type,
  p_default_bs_name              OUT NOCOPY
                          ra_batch_sources.name%type,
  p_auto_trx_numbering_flag      OUT NOCOPY
                          ra_batch_sources.auto_trx_numbering_flag%type,
  p_bs_type                      OUT NOCOPY
                          ra_batch_sources.batch_source_type%type,
  p_copy_doc_number_flag         OUT NOCOPY
                          ra_batch_sources.copy_doc_number_flag%type,
  p_bs_default_cust_trx_type_id  OUT NOCOPY
                          ra_cust_trx_types.cust_trx_type_id%type,
  p_default_cust_trx_type_id     OUT NOCOPY
                          ra_cust_trx_types.cust_trx_type_id%type,
  p_default_type_name            OUT NOCOPY
                          ra_cust_trx_types.name%type,
  p_open_receivable_flag         OUT NOCOPY
                          ra_cust_trx_types.accounting_affect_flag%type,
  p_post_to_gl_flag              OUT NOCOPY
                          ra_cust_trx_types.post_to_gl%type,
  p_allow_freight_flag           OUT NOCOPY
                          ra_cust_trx_types.allow_freight_flag%type,
  p_creation_sign                OUT NOCOPY
                          ra_cust_trx_types.creation_sign%type,
  p_allow_overapplication_flag   OUT NOCOPY
                          ra_cust_trx_types.allow_overapplication_flag%type,
  p_natural_app_only_flag        OUT NOCOPY
                          ra_cust_trx_types.natural_application_only_flag%type,
  p_tax_calculation_flag         OUT NOCOPY
                          ra_cust_trx_types.tax_calculation_flag%type,
  p_default_printing_option      OUT NOCOPY
                          ra_customer_trx.printing_option%type,
--
  p_default_gl_date              OUT NOCOPY
                          ra_cust_trx_line_gl_dist.gl_date%type,
  p_default_ship_to_customer_id  OUT NOCOPY
                          hz_cust_accounts.cust_account_id%type,
  p_default_ship_to_site_use_id  OUT NOCOPY
                          hz_cust_site_uses.site_use_id%type,
  p_default_ship_to_contact_id   OUT NOCOPY
                          hz_cust_account_roles.cust_account_role_id%type,
  p_default_bill_to_customer_id  OUT NOCOPY
                          hz_cust_accounts.cust_account_id%type,
  p_default_bill_to_site_use_id  OUT NOCOPY
                          hz_cust_site_uses.site_use_id%type,
  p_default_bill_to_contact_id   OUT NOCOPY
                          hz_cust_account_roles.cust_account_role_id%type,
  p_default_primary_salesrep_id  OUT NOCOPY
                          ra_salesreps.salesrep_id%type,
  p_default_receipt_method_id    OUT NOCOPY
                          ar_receipt_methods.receipt_method_id%type,
  p_default_cust_bank_account_id OUT NOCOPY
                          ce_bank_accounts.bank_account_id%type,
  p_default_paying_customer_id   OUT NOCOPY
                          hz_cust_accounts.cust_account_id%type,
  p_default_paying_site_use_id   OUT NOCOPY
                          hz_cust_site_uses.site_use_id%type,
  p_default_ship_via             OUT NOCOPY
                          ra_customer_trx.ship_via%type,
  p_default_ship_date_actual     OUT NOCOPY
                          ra_customer_trx.ship_date_actual%type,
  p_default_waybill_number       OUT NOCOPY
                          ra_customer_trx.waybill_number%type,
  p_default_fob_point            OUT NOCOPY
                          ra_customer_trx.fob_point%type);


FUNCTION check_payment_method(
   p_trx_date               IN
                                     ra_customer_trx.trx_date%type,
   p_customer_id            IN
                                     ra_customer_trx.customer_trx_id%type,
   p_site_use_id            IN
                                     hz_cust_site_uses.site_use_id%type,
   p_parent_customer_id     IN
                                     hz_cust_accounts.cust_account_id%type,
   p_parent_site_use_id     IN
                                     hz_cust_site_uses.site_use_id%type,
   p_currency_code          IN
                                     fnd_currencies.currency_code%type,
   p_crtrx_receipt_method_id IN
                                     ar_receipt_methods.receipt_method_id%type,
   p_payment_method_name   OUT NOCOPY
                                     ar_receipt_methods.name%type,
   p_receipt_method_id     OUT NOCOPY
                                     ar_receipt_methods.receipt_method_id%type,
   p_creation_method_code  OUT NOCOPY
                                   ar_receipt_classes.creation_method_code%type
                             ) RETURN BOOLEAN;

FUNCTION check_bank_account(
  p_trx_date                     IN
                          ra_customer_trx.trx_date%type,
  p_currency_code                IN
                          fnd_currencies.currency_code%type,
  p_bill_to_customer_id          IN
                          hz_cust_accounts.cust_account_id%type,
  p_bill_to_site_use_id          IN
                          hz_cust_site_uses.site_use_id%type,
  p_parent_customer_id           IN
                          hz_cust_accounts.cust_account_id%type,
  p_parent_site_use_id           IN
                          hz_cust_site_uses.site_use_id%type,
  p_crtrx_cust_bank_account_id   IN
                          ce_bank_accounts.bank_account_id%type,
  p_cust_bank_account_id         OUT NOCOPY
                          ce_bank_accounts.bank_account_id%type,
  p_paying_customer_id           OUT NOCOPY
                          hz_cust_accounts.cust_account_id%type)
RETURN BOOLEAN;

FUNCTION check_cm_trxtype (
  p_inv_trx_type_id             IN
                          ra_cust_trx_types.cust_trx_type_id%type,
  p_inv_open_rec_flag          IN
                          ra_cust_trx_types.accounting_affect_flag%type,
  p_cm_trx_type_id             IN
                          ra_cust_trx_types.cust_trx_type_id%type
  )
RETURN BOOLEAN;

PROCEDURE init;

END ARP_PROCESS_CREDIT_UTIL;


/
