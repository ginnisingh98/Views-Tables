--------------------------------------------------------
--  DDL for Package ARP_TRX_DEFAULTS_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TRX_DEFAULTS_3" AUTHID CURRENT_USER AS
/* $Header: ARTUDF3S.pls 120.9.12010000.1 2008/07/24 16:57:53 appldev ship $ */

TYPE address_rec_type IS RECORD (
              cust_acct_site_id  NUMBER,
              address1           hz_locations.address1%type,
              address2           hz_locations.address2%type,
              address3           hz_locations.address3%type,
              address4           hz_locations.address4%type,
              city               hz_locations.city%type,
              state              hz_locations.state%type,
              province           hz_locations.province%type,
              postal_code        hz_locations.postal_code%type,
              country            fnd_territories_vl.territory_short_name%type -- hz_locations.city%type
                                );

PROCEDURE get_default_remit_to(
                                p_remit_to_address_id OUT NOCOPY
                                               NUMBER,
                                p_remit_to_address_rec OUT NOCOPY address_rec_type
                              );

PROCEDURE get_remit_to_address(
                                p_match_state           IN
                                      hz_locations.state%type,
                                p_match_country         IN
                                      hz_locations.country%type,
                                p_match_postal_code     IN
                                      hz_locations.postal_code%type,
                                p_match_address_id      IN
                                      NUMBER,
                                p_match_site_use_id     IN
                                      NUMBER,
                                p_remit_to_address_id  OUT NOCOPY
                                      NUMBER,
                                p_remit_to_address_rec OUT NOCOPY
                                     address_rec_type
                              );

PROCEDURE get_remit_to_default(
                              p_state        IN  hz_locations.state%type,
                              p_postal_code  IN  hz_locations.postal_code%type,
                              p_country      IN  hz_locations.country%type,
                              p_address_id   OUT NOCOPY  NUMBER,
                              p_address1     OUT NOCOPY  hz_locations.address1%type,
                              p_address2     OUT NOCOPY  hz_locations.address2%type,
                              p_address3     OUT NOCOPY  varchar2,
                              p_concatenated_address OUT NOCOPY varchar2
                          );



PROCEDURE get_payment_method_default(
                                      p_trx_date               IN
                                            ra_customer_trx.trx_date%type,
                                      p_currency_code          IN
                                            fnd_currencies.currency_code%type,
                                      p_paying_customer_id     IN
                                          hz_cust_accounts.cust_account_id%type,
                                      p_paying_site_use_id     IN
                                           hz_cust_site_uses.site_use_id%type,
                                      p_bill_to_customer_id    IN
                                            hz_cust_accounts.cust_account_id%type,
                                      p_bill_to_site_use_id    IN
                                            hz_cust_site_uses.site_use_id%type,
                                      p_payment_method_name   OUT NOCOPY
                                            ar_receipt_methods.name%type,
                                      p_receipt_method_id     OUT NOCOPY
                                     ar_receipt_methods.receipt_method_id%type,
                                      p_creation_method_code  OUT NOCOPY
                                   ar_receipt_classes.creation_method_code%type,
                                      p_trx_manual_flag        IN VARCHAR2  DEFAULT 'N'
                          );

FUNCTION check_payment_method(
                               p_trx_date               IN
                                     ra_customer_trx.trx_date%type,
                               p_customer_id            IN
                                     ra_customer_trx.customer_trx_id%type,
                               p_site_use_id            IN
                                     hz_cust_site_uses.site_use_id%type,
                               p_currency_code          IN
                                     fnd_currencies.currency_code%type,
                               p_payment_method_name   OUT NOCOPY
                                     ar_receipt_methods.name%type,
                               p_receipt_method_id     OUT NOCOPY
                                     ar_receipt_methods.receipt_method_id%type,
                               p_creation_method_code  OUT NOCOPY
                                   ar_receipt_classes.creation_method_code%type
                             ) RETURN BOOLEAN;


PROCEDURE get_bank_defaults(
                                      p_trx_date               IN
                                            ra_customer_trx.trx_date%type,
                                      p_currency_code          IN
                                            fnd_currencies.currency_code%type,
                                      p_paying_customer_id     IN
                                            hz_cust_accounts.cust_account_id%type,
                                      p_paying_site_use_id     IN
                                            hz_cust_site_uses.site_use_id%type,
                                      p_bill_to_customer_id    IN
                                            hz_cust_accounts.cust_account_id%type,
                                      p_bill_to_site_use_id    IN
                                            hz_cust_site_uses.site_use_id%type,
                                      p_payment_type_code      IN
                                  ar_receipt_methods.payment_type_code%type,
                                      p_customer_bank_account_id  OUT NOCOPY
                           ce_bank_accounts.bank_account_id%type,
                                      p_bank_account_num          OUT NOCOPY
                                        ce_bank_accounts.bank_account_num%type,
                                      p_bank_name                 OUT NOCOPY
                                             ce_bank_branches_v.bank_name%type,
                                      p_bank_branch_name          OUT NOCOPY
                                        ce_bank_branches_v.bank_branch_name%type,
                                      p_bank_branch_id            OUT NOCOPY
                                      ce_bank_branches_v.branch_party_id%TYPE,
                                      p_trx_manual_flag        IN VARCHAR2  DEFAULT 'N'
                          );

PROCEDURE get_pay_method_and_bank_deflts(
                                      p_trx_date                   IN
                                            ra_customer_trx.trx_date%type,
                                      p_currency_code              IN
                                            fnd_currencies.currency_code%type,
                                      p_paying_customer_id         IN
                                            hz_cust_accounts.cust_account_id%type,
                                      p_paying_site_use_id         IN
                                            hz_cust_site_uses.site_use_id%type,
                                      p_bill_to_customer_id        IN
                                            hz_cust_accounts.cust_account_id%type,
                                      p_bill_to_site_use_id        IN
                                            hz_cust_site_uses.site_use_id%type,
                                      p_payment_type_code      IN
                                  ar_receipt_methods.payment_type_code%type,
                                      p_payment_method_name       OUT NOCOPY
                                            ar_receipt_methods.name%type,
                                      p_receipt_method_id         OUT NOCOPY
                                     ar_receipt_methods.receipt_method_id%type,
                                      p_creation_method_code      OUT NOCOPY
                                  ar_receipt_classes.creation_method_code%type,
                                      p_customer_bank_account_id  OUT NOCOPY
                           ce_bank_accounts.bank_account_id%type,
                                      p_bank_account_num          OUT NOCOPY
                                        ce_bank_accounts.bank_account_num%type,
                                      p_bank_name                 OUT NOCOPY
                                             ce_bank_branches_v.bank_name%type,
                                      p_bank_branch_name          OUT NOCOPY
                                        ce_bank_branches_v.bank_branch_name%type,
                                      p_bank_branch_id            OUT NOCOPY
                                          ce_bank_branches_v.branch_party_id%TYPE,
                                      p_trx_manual_flag        IN VARCHAR2  DEFAULT 'N'
                          );

PROCEDURE get_term_default(
                             p_term_id        IN ra_terms.term_id%type,
                             p_type_term_id   IN ra_terms.term_id%type,
                             p_type_term_name IN ra_terms.name%type,
                             p_customer_id    IN hz_cust_accounts.cust_account_id%type,
                             p_site_use_id    IN hz_cust_site_uses.site_use_id%type,
                             p_trx_date       IN ra_customer_trx.trx_date%type,
                             p_class          IN ra_cust_trx_types.type%type,
                             p_cust_trx_type_id  IN ra_cust_trx_types.cust_trx_type_id%type,
                             p_default_term_id      OUT NOCOPY ra_terms.term_id%type,
                             p_default_term_name    OUT NOCOPY ra_terms.name%type,
                             p_number_of_due_dates  OUT NOCOPY number,
                             p_term_due_date        OUT NOCOPY
                                   ra_customer_trx.term_due_date%type
                          );

PROCEDURE Get_Additional_Customer_Info(
                                       p_customer_id              IN number,
                                       p_site_use_id              IN number,
                                       p_invoice_currency_code    IN varchar2,
                                       p_previous_customer_trx_id IN number,
                                       p_ct_prev_initial_cust_trx_id IN number,
                                       p_trx_date                 IN date,
                                       p_code_combination_id_gain IN number,
                                       p_override_terms          OUT NOCOPY varchar2,
                                       p_commitments_exist_flag  OUT NOCOPY varchar2,
                                       p_agreements_exist_flag   OUT NOCOPY varchar2);


FUNCTION  get_payment_channel_name(
                                      p_payment_channel_code      IN
                                        ar_receipt_methods.payment_channel_code%type
                                  ) RETURN VARCHAR2;

FUNCTION  get_party_id (
                                     p_cust_account_id           IN
                                       hz_cust_accounts.cust_account_id%type
                       ) RETURN NUMBER;

FUNCTION  get_payment_instrument(
                                      p_payment_trxn_extension_id      IN
                                        ra_customer_trx.payment_trxn_extension_id%type,
                                      p_payment_channel_code      IN
                                        ar_receipt_methods.payment_channel_code%type
                                ) RETURN VARCHAR2;


--4778839
PROCEDURE get_br_bank_defaults(    p_payment_trxn_extension_id      IN
                                        ra_customer_trx.payment_trxn_extension_id%type,
                                   p_payment_channel_code      IN
                                        ar_receipt_methods.payment_channel_code%type,
                                   p_bank_name OUT NOCOPY
                                         iby_trxn_extensions_v.bank_name%type,
                                   p_branch_name OUT NOCOPY
                                         iby_trxn_extensions_v.bank_branch_name%type,
                                   p_instr_assign_id OUT NOCOPY
                                          iby_trxn_extensions_v.instr_assignment_id%type,
                                   p_instr_number OUT NOCOPY
                                          iby_trxn_extensions_v.account_number%type);


--Bug 5507178
PROCEDURE get_instr_defaults(p_org_id IN   ra_customer_trx.org_id%type,
                             p_paying_customer_id  IN  ra_customer_trx.paying_customer_id%type,
                             p_paying_site_use_id IN iby_fndcpt_payer_assgn_instr_v.acct_site_use_id%type,
                             p_instrument_type IN iby_fndcpt_payer_assgn_instr_v.instrument_type%type,
                             p_currency_code IN    iby_fndcpt_payer_assgn_instr_v.currency_code%type             ,
                             p_instrument_assignment_id OUT NOCOPY  iby_trxn_extensions_v.instr_assignment_id%type
                           );

PROCEDURE init;

END ARP_TRX_DEFAULTS_3;

/
