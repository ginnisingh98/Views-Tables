--------------------------------------------------------
--  DDL for Package AR_CC_REFUNDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CC_REFUNDS" AUTHID CURRENT_USER AS
/* $Header: ARCCRFDS.pls 115.6 2004/06/11 17:10:43 sswayamp ship $ */

g_cash_receipt_id AR_CASH_RECEIPTS.cash_receipt_id%type;

PROCEDURE process_refund(
                      cc_currency IN VARCHAR2,
                      cc_price IN VARCHAR2,
                      cc_pay_server_order_num IN OUT NOCOPY VARCHAR2,
		      cc_unique_reference IN VARCHAR2,
                      cc_merchant_id IN VARCHAR2,
                      cc_pmt_instr_id IN VARCHAR2,
                      cc_pmt_instr_exp IN VARCHAR2,
                      cc_status_code IN OUT NOCOPY VARCHAR2,
                      cc_statusmsg  IN OUT NOCOPY VARCHAR2,
                      cc_err_location IN  OUT NOCOPY VARCHAR2,
                      cc_vend_err_code IN OUT NOCOPY VARCHAR2,
                      cc_vend_err_mesg IN  OUT NOCOPY VARCHAR2,
                      cc_return_status IN  OUT NOCOPY VARCHAR2,
                      cc_cash_receipt_id IN VARCHAR2 DEFAULT NULL
                        );

END AR_CC_REFUNDS;

 

/
