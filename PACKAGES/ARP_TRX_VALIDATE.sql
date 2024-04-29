--------------------------------------------------------
--  DDL for Package ARP_TRX_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TRX_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: ARTUVALS.pls 120.9.12010000.1 2008/07/24 16:58:24 appldev ship $ */

   TYPE Message_Rec_Type IS RECORD
        (
           customer_trx_id       ra_customer_trx.customer_trx_id%type,
           line_number           ra_customer_trx_lines.line_number%type,
           other_line_number       ra_customer_trx_lines.line_number%type,
           line_index              BINARY_INTEGER,
           tax_index               BINARY_INTEGER,
           freight_index           BINARY_INTEGER,
           salescredit_index       BINARY_INTEGER,
           message_name            VARCHAR2(30),
           token_name_1            VARCHAR2(100),
           token_1               VARCHAR2(2000),
           token_name_2           VARCHAR2(100),
           token_2           VARCHAR2(2000),
           encoded_message         VARCHAR2(2000),
           translated_message      VARCHAR2(1000)
        );

   TYPE Message_Tbl_Type       IS TABLE OF  Message_Rec_Type
                               INDEX BY BINARY_INTEGER;

   pg_message_tbl            Message_Tbl_Type;


PROCEDURE ar_entity_version_check(p_form_name    IN varchar2,
                                  p_form_version IN number);

PROCEDURE check_dup_line_number( p_line_number      IN  NUMBER,
                                 p_customer_trx_id  IN  NUMBER,
                                 p_customer_trx_line_id  IN  NUMBER);

PROCEDURE check_has_one_line( p_customer_trx_id  IN  NUMBER,
                              p_display_message  IN  varchar2  default  'Y');

PROCEDURE check_sign_and_overapp(
                      p_customer_trx_id          IN  NUMBER,
                      p_previous_customer_trx_id          IN  NUMBER,
                      p_trx_open_receivables_flag    IN  VARCHAR2,
                      p_prev_open_receivables_flag    IN  VARCHAR2,
                      p_creation_sign            IN  VARCHAR2,
                      p_allow_overapplication_flag  IN  VARCHAR2,
                      p_natural_application_flag  IN  VARCHAR2
                   );

PROCEDURE validate_trx_number( p_batch_source_id           IN  NUMBER,
                               p_trx_number                IN  VARCHAR2,
                               p_customer_trx_id           IN  NUMBER  );

PROCEDURE validate_trx_date( p_trx_date                      IN  DATE,
                             p_prev_trx_date                 IN  DATE,
                             p_commitment_trx_date           IN  DATE,
                             p_customer_trx_id               IN  NUMBER,
                             p_trx_number                    IN  VARCHAR2,
                             p_previous_customer_trx_id      IN  NUMBER,
                             p_initial_customer_trx_id       IN  NUMBER,
                             p_agreement_id                  IN  NUMBER,
                             p_batch_source_id               IN  NUMBER,
                             p_cust_trx_type_id              IN  NUMBER,
                             p_term_id                       IN  NUMBER,
                             p_ship_method_code              IN  VARCHAR2,
                             p_primary_salesrep_id           IN  NUMBER,
                             p_reason_code                   IN  VARCHAR2,
                             p_status_trx                    IN  VARCHAR2,
                             p_invoice_currency_code         IN  VARCHAR2,
                             p_receipt_method_id             IN  NUMBER,
                             p_bank_account_id               IN  NUMBER,
                             p_due_date                     OUT NOCOPY date,
                             p_result_flag                  OUT NOCOPY boolean,
                             p_commitment_invalid_flag      OUT NOCOPY boolean,
                             p_invalid_agreement_flag       OUT NOCOPY boolean,
                             p_invalid_source_flag          OUT NOCOPY boolean,
                             p_invalid_type_flag            OUT NOCOPY boolean,
                             p_invalid_term_flag            OUT NOCOPY boolean,
                             p_invalid_ship_method_flag     OUT NOCOPY boolean,
                             p_invalid_primary_srep_flag    OUT NOCOPY boolean,
                             p_invalid_reason_flag          OUT NOCOPY boolean,
                             p_invalid_status_flag          OUT NOCOPY boolean,
                             p_invalid_currency_flag        OUT NOCOPY boolean,
                             p_invalid_payment_mthd_flag    OUT NOCOPY boolean,
                             p_invalid_bank_flag            OUT NOCOPY boolean,
                             p_invalid_salesrep_flag        OUT NOCOPY boolean,
                             p_invalid_memo_line_flag       OUT NOCOPY boolean,
                             p_invalid_uom_flag             OUT NOCOPY boolean,
                             p_invalid_tax_flag             OUT NOCOPY boolean,
                             p_invalid_cm_date_flag         OUT NOCOPY boolean,
                             p_invalid_child_date_flag      OUT NOCOPY boolean,
                             p_error_count               IN OUT NOCOPY integer
                       );

PROCEDURE validate_trx_date(
                             p_error_mode                    IN VARCHAR2,
                             p_trx_date                      IN  DATE,
                             p_prev_trx_date                 IN  DATE,
                             p_commitment_trx_date           IN  DATE,
                             p_customer_trx_id               IN  NUMBER,
                             p_trx_number                    IN  VARCHAR2,
                             p_previous_customer_trx_id      IN  NUMBER,
                             p_initial_customer_trx_id       IN  NUMBER,
                             p_agreement_id                  IN  NUMBER,
                             p_batch_source_id               IN  NUMBER,
                             p_cust_trx_type_id              IN  NUMBER,
                             p_term_id                       IN  NUMBER,
                             p_ship_method_code              IN  VARCHAR2,
                             p_primary_salesrep_id           IN  NUMBER,
                             p_reason_code                   IN  VARCHAR2,
                             p_status_trx                    IN  VARCHAR2,
                             p_invoice_currency_code         IN  VARCHAR2,
                             p_receipt_method_id             IN  NUMBER,
                             p_bank_account_id               IN  NUMBER,
                             p_due_date                     OUT NOCOPY date,
                             p_result_flag                  OUT NOCOPY boolean,
                             p_commitment_invalid_flag      OUT NOCOPY boolean,
                             p_invalid_agreement_flag       OUT NOCOPY boolean,
                             p_invalid_source_flag          OUT NOCOPY boolean,
                             p_invalid_type_flag            OUT NOCOPY boolean,
                             p_invalid_term_flag            OUT NOCOPY boolean,
                             p_invalid_ship_method_flag     OUT NOCOPY boolean,
                             p_invalid_primary_srep_flag    OUT NOCOPY boolean,
                             p_invalid_reason_flag          OUT NOCOPY boolean,
                             p_invalid_status_flag          OUT NOCOPY boolean,
                             p_invalid_currency_flag        OUT NOCOPY boolean,
                             p_invalid_payment_mthd_flag    OUT NOCOPY boolean,
                             p_invalid_bank_flag            OUT NOCOPY boolean,
                             p_invalid_salesrep_flag        OUT NOCOPY boolean,
                             p_invalid_memo_line_flag       OUT NOCOPY boolean,
                             p_invalid_uom_flag             OUT NOCOPY boolean,
                             p_invalid_tax_flag             OUT NOCOPY boolean,
                             p_invalid_cm_date_flag         OUT NOCOPY boolean,
                             p_invalid_child_date_flag      OUT NOCOPY boolean,
                             p_error_count               IN OUT NOCOPY integer
                       );

PROCEDURE val_gl_dist_amounts(
                      p_customer_trx_line_id  IN  NUMBER,
                      p_result OUT NOCOPY boolean );

FUNCTION validate_paying_customer( p_paying_customer_id           IN NUMBER,
                                   p_trx_date                     IN date,
                                   p_bill_to_customer_id          IN NUMBER,
                                   p_ct_prev_paying_customer_id   IN NUMBER,
                                   p_currency_code                IN varchar2,
                                   p_pay_unrelated_invoices_flag  IN varchar2,
                                   p_ct_prev_trx_date             IN date)
                                 RETURN BOOLEAN;

PROCEDURE val_and_dflt_pay_mthd_and_bank(
                                     p_trx_date                    IN  date,
                                     p_currency_code               IN  varchar2,
                                     p_paying_customer_id          IN  number,
                                     p_paying_site_use_id          IN  number,
                                     p_bill_to_customer_id         IN  number,
                                     p_bill_to_site_use_id         IN  number,
                                     p_in_receipt_method_id        IN  number,
                                     p_in_customer_bank_account_id IN  number,
                                     p_payment_type_code           IN  varchar2,
                                     p_payment_method_name        OUT NOCOPY  varchar2,
                                     p_receipt_method_id          OUT NOCOPY  number,
                                     p_creation_method_code       OUT NOCOPY  varchar2,
                                     p_customer_bank_account_id   OUT NOCOPY  number,
                                     p_bank_account_num           OUT NOCOPY  varchar2,
                                     p_bank_name                  OUT NOCOPY  varchar2,
                                     p_bank_branch_name           OUT NOCOPY  varchar2,
                                     p_bank_branch_id             OUT NOCOPY  number,
                                     p_trx_manual_flag            IN VARCHAR2  DEFAULT 'N'
                          );

PROCEDURE do_completion_checking(
                                  p_customer_trx_id        IN  NUMBER,
                                  p_so_source_code        IN varchar2,
                                  p_so_installed_flag     IN varchar2,
                                  p_error_mode            IN VARCHAR2,
                                  p_error_count          OUT NOCOPY number
                                );

PROCEDURE add_to_error_list(
                                  p_mode              IN VARCHAR2,
                                  p_error_count       IN OUT NOCOPY INTEGER,
                                  p_customer_trx_id    IN  NUMBER,
                                  p_trx_number         IN  VARCHAR2,
                                  p_line_number        IN  NUMBER,
                                  p_other_line_number  IN  NUMBER,
                                  p_message_name       IN  VARCHAR2,
                                  p_error_location    IN varchar2 DEFAULT NULL,
                                  p_token_name_1      IN varchar2 DEFAULT NULL,
                                  p_token_1           IN varchar2 DEFAULT NULL,
                                  p_token_name_2      IN varchar2 DEFAULT NULL,
                                  p_token_2           IN varchar2 DEFAULT NULL,
                                  p_line_index        IN NUMBER   DEFAULT NULL,
                                  p_tax_index         IN NUMBER   DEFAULT NULL,
                                  p_freight_index     IN NUMBER   DEFAULT NULL,
                                  p_salescredit_index IN NUMBER   DEFAULT NULL
                                );

PROCEDURE validate_doc_number( p_cust_trx_type_id          IN  NUMBER,
                               p_doc_sequence_value        IN  NUMBER,
                               p_customer_trx_id           IN  NUMBER  );

/*Bug3041195*/
PROCEDURE check_sign_and_overapp(
                      p_customer_trx_id              IN  NUMBER,
                      p_previous_customer_trx_id     IN  NUMBER,
                      p_trx_open_receivables_flag    IN  VARCHAR2,
                      p_prev_open_receivables_flag   IN  VARCHAR2,
                      p_creation_sign                IN  VARCHAR2,
                      p_allow_overapplication_flag   IN  VARCHAR2,
                      p_natural_application_flag     IN  VARCHAR2,
                      p_error_mode                   IN  VARCHAR2,
                      p_error_count    OUT NOCOPY      NUMBER
                   );

PROCEDURE init;

END ARP_TRX_VALIDATE;

/
