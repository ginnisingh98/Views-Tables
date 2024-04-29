--------------------------------------------------------
--  DDL for Package AR_IREC_APPLY_CREDITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_IREC_APPLY_CREDITS" AUTHID CURRENT_USER AS
/* $Header: ARIAPCRS.pls 120.4 2006/05/22 14:08:09 rsinthre noship $ */


PROCEDURE copy_transaction_list_records(p_customer_id           IN NUMBER,
                                        p_customer_site_use_id  IN NUMBER DEFAULT NULL,
                                        p_currency_code         IN VARCHAR2);

PROCEDURE copy_open_debits(p_customer_id           IN NUMBER,
                           p_customer_site_use_id  IN NUMBER DEFAULT NULL,
                           p_currency_code         IN VARCHAR2);

PROCEDURE copy_open_credits(p_customer_id           IN NUMBER,
                            p_customer_site_use_id  IN NUMBER DEFAULT NULL,
                            p_currency_code         IN VARCHAR2);

PROCEDURE create_apply_credits_record(  p_payment_schedule_id   IN NUMBER,
				       p_customer_id IN NUMBER,
				       p_customer_site_id IN NUMBER );

PROCEDURE delete_all_credits(p_customer_id           IN NUMBER,
                             p_customer_site_use_id  IN NUMBER DEFAULT NULL,
                             p_currency_code         IN VARCHAR2
                            );

PROCEDURE delete_all_debits(p_customer_id           IN NUMBER,
                            p_customer_site_use_id  IN NUMBER DEFAULT NULL,
                            p_currency_code         IN VARCHAR2
                            );

PROCEDURE delete_apply_credits_record( p_payment_schedule_id   IN NUMBER
                                      );

PROCEDURE delete_all_records(p_customer_id           IN NUMBER,
                             p_customer_site_use_id  IN NUMBER DEFAULT NULL,
                             p_currency_code         IN VARCHAR2
                            );

PROCEDURE apply_credits(p_customer_id           IN NUMBER,
                        p_customer_site_use_id  IN NUMBER DEFAULT NULL,
				p_driving_customer_id   IN NUMBER,
                        p_currency_code         IN VARCHAR2,
                        p_credit_memos_only     IN VARCHAR2,
                        x_open_invoices_status  OUT NOCOPY VARCHAR2,
                        x_dup_appln_dbt_psid    OUT NOCOPY NUMBER,
                        x_dup_appln_crdt_psid   OUT NOCOPY NUMBER,
                        x_cash_receipt_id       OUT NOCOPY NUMBER,
                        x_msg_count             OUT NOCOPY NUMBER,
                        x_msg_data              OUT NOCOPY VARCHAR2,
                        x_return_status         OUT NOCOPY VARCHAR2
                        );

PROCEDURE copy_apply_credits_records( p_customer_id           IN NUMBER,
                                      p_customer_site_use_id  IN NUMBER DEFAULT NULL,
                                      p_currency_code         IN VARCHAR2
                                     );

END AR_IREC_APPLY_CREDITS ;

 

/
