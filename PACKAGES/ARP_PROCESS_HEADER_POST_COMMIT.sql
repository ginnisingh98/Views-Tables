--------------------------------------------------------
--  DDL for Package ARP_PROCESS_HEADER_POST_COMMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_HEADER_POST_COMMIT" AUTHID CURRENT_USER AS
/* $Header: ARTEHPCS.pls 120.3.12010000.1 2008/07/24 16:56:12 appldev ship $ */


PROCEDURE post_commit( p_form_name                    IN varchar2,
                       p_form_version                 IN number,
                       p_customer_trx_id              IN
                                      ra_customer_trx.customer_trx_id%type,
                       p_previous_customer_trx_id     IN
                               ra_customer_trx.previous_customer_trx_id%type,
                       p_complete_flag                IN
                               ra_customer_trx.complete_flag%type,
                       p_trx_open_receivables_flag    IN
                                 ra_cust_trx_types.accounting_affect_flag%type,
                       p_prev_open_receivables_flag   IN
                                 ra_cust_trx_types.accounting_affect_flag%type,
                       p_creation_sign                IN
                                 ra_cust_trx_types.creation_sign%type,
                       p_allow_overapplication_flag   IN
                             ra_cust_trx_types.allow_overapplication_flag%type,
                       p_natural_application_flag     IN
                          ra_cust_trx_types.natural_application_only_flag%type,
                       p_cash_receipt_id              IN
                          ar_cash_receipts.cash_receipt_id%type DEFAULT NULL,
                       p_error_mode                   IN VARCHAR2
                     );

PROCEDURE init;

END ARP_PROCESS_HEADER_POST_COMMIT;

/
