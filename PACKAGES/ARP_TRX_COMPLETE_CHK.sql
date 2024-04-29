--------------------------------------------------------
--  DDL for Package ARP_TRX_COMPLETE_CHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TRX_COMPLETE_CHK" AUTHID CURRENT_USER AS
/* $Header: ARTUVA2S.pls 120.4.12010000.1 2008/07/24 16:58:16 appldev ship $ */

PROCEDURE do_completion_checking(
                                  p_customer_trx_id       IN
                                          ra_customer_trx.customer_trx_id%type,
                                  p_so_source_code        IN varchar2,
                                  p_so_installed_flag     IN varchar2,
                                  p_error_count          OUT NOCOPY number
                                );

PROCEDURE do_completion_checking(
                                  p_customer_trx_id       IN
                                          ra_customer_trx.customer_trx_id%type,
                                  p_so_source_code        IN varchar2,
                                  p_so_installed_flag     IN varchar2,
                                  p_error_mode            IN VARCHAR2,
                                  p_error_count          OUT NOCOPY number,
                                  p_check_tax_acct        IN VARCHAR2 DEFAULT 'B'
                                );

FUNCTION check_tax_and_accounting(
                                     p_query_string               IN varchar2,
                                     p_error_trx_number          OUT NOCOPY varchar2,
                                     p_error_line_number         OUT NOCOPY number,
                                     p_error_other_line_number   OUT NOCOPY number
                                  ) RETURN BOOLEAN;

/* Bug 3185358 */
PROCEDURE dm_reversal_amount_chk(
				 p_customer_trx_id	IN ra_customer_trx.customer_trx_id%type,
				 p_reversed_cash_receipt_id	IN
					ra_customer_trx.reversed_cash_receipt_id%type,
				 p_status OUT NOCOPY VARCHAR2);

PROCEDURE init;

END ARP_TRX_COMPLETE_CHK;

/
