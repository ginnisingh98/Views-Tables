--------------------------------------------------------
--  DDL for Package ARP_TRX_DEFAULTS_2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TRX_DEFAULTS_2" AUTHID CURRENT_USER AS
/* $Header: ARTUDF2S.pls 120.3.12010000.1 2008/07/24 16:57:51 appldev ship $ */

PROCEDURE get_source_default(
                              p_batch_source_id             IN
                                        ra_batch_sources.batch_source_id%type,
                              p_ctt_class                   IN
                                       ra_cust_trx_types.type%type,
                              p_trx_date                    IN
                                        ra_customer_trx.trx_date%type,
                              p_trx_number                  IN
                                        ra_customer_trx.trx_number%type,
                              p_default_batch_source_id    OUT NOCOPY
                                        ra_batch_sources.batch_source_id%type,
                              p_default_batch_source_name  OUT NOCOPY
                                        ra_batch_sources.name%type,
                              p_auto_trx_numbering_flag    OUT NOCOPY
                                ra_batch_sources.auto_trx_numbering_flag%type,
                              p_batch_source_type          OUT NOCOPY
                                       ra_batch_sources.batch_source_type%type,
                              p_copy_doc_number_flag       OUT NOCOPY
                                        ra_batch_sources.copy_doc_number_flag%type,
                              p_default_cust_trx_type_id   OUT NOCOPY
                                        ra_cust_trx_types.cust_trx_type_id%type
                            );

PROCEDURE get_type_defaults(
                             p_cust_trx_type_id       IN
                                     ra_cust_trx_types.cust_trx_type_id%type,
                             p_trx_date               IN
                                     ra_customer_trx.trx_date%type,
                             p_ctt_class              IN
                                     ra_cust_trx_types.type%type,
                             p_row_id                 IN varchar2,
                             p_invoicing_rule_id      IN ra_rules.rule_id%type,
                             p_rev_recog_run_flag     IN varchar2,
                             p_complete_flag          IN
                                     ra_customer_trx.complete_flag%type,
                             p_open_receivables_flag  IN
                                 ra_cust_trx_types.accounting_affect_flag%type,
                             p_customer_trx_id        IN
                                     ra_customer_trx.customer_trx_id%type,
                             p_default_cust_trx_type_id        OUT NOCOPY
                                     ra_cust_trx_types.cust_trx_type_id%type,
                             p_default_type_name               OUT NOCOPY
                                     ra_cust_trx_types.name%type,
                             p_default_class                   OUT NOCOPY
                                     ra_cust_trx_types.type%type,
                             p_deflt_open_receivables_flag     OUT NOCOPY
                                 ra_cust_trx_types.accounting_affect_flag%type,
                             p_default_post_to_gl_flag         OUT NOCOPY
                                     ra_cust_trx_types.post_to_gl%type,
                             p_default_allow_freight_flag      OUT NOCOPY
                                     ra_cust_trx_types.allow_freight_flag%type,
                             p_default_creation_sign           OUT NOCOPY
                                     ra_cust_trx_types.creation_sign%type,
                             p_default_allow_overapp_flag      OUT NOCOPY
                          ra_cust_trx_types.allow_overapplication_flag%type,
                             p_deflt_natural_app_only_flag   OUT NOCOPY
                          ra_cust_trx_types.natural_application_only_flag%type,
                             p_default_tax_calculation_flag    OUT NOCOPY
                                  ra_cust_trx_types.tax_calculation_flag%type,
                             p_default_status_code             OUT NOCOPY
                                  ar_lookups.lookup_code%type,
                             p_default_status                  OUT NOCOPY
                                  ar_lookups.meaning%type,
                             p_default_printing_option_code    OUT NOCOPY
                                  ar_lookups.lookup_code%type,
                             p_default_printing_option         OUT NOCOPY
                                  ar_lookups.meaning%type,
                             p_default_term_id                 OUT NOCOPY
                                  ra_terms.term_id%type,
                             p_default_term_name               OUT NOCOPY
                                  ra_terms.name%type,
                             p_number_of_due_dates             OUT NOCOPY number,
                             p_term_due_date                   OUT NOCOPY
                                  ra_customer_trx.term_due_date%type,
                             p_security_inv_enter_flag      IN
                                  varchar2   DEFAULT 'Y',
                             p_security_cm_enter_flag       IN
                                  varchar2   DEFAULT 'Y',
                             p_security_dm_enter_flag       IN
                                  varchar2   DEFAULT 'Y',
                             p_security_commit_enter_flag    IN
                                  varchar2   DEFAULT 'Y'
                          );

PROCEDURE init;

END ARP_TRX_DEFAULTS_2;

/