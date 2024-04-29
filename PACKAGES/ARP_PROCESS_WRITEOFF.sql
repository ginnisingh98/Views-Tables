--------------------------------------------------------
--  DDL for Package ARP_PROCESS_WRITEOFF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_WRITEOFF" AUTHID CURRENT_USER AS
/* $Header: ARPWRTFS.pls 120.2.12000000.2 2007/04/27 06:11:25 nemani ship $ */

/*5444407*/

TYPE rec_wrt_off_type IS RECORD
     (batch_id       ar_batches.batch_id%TYPE);

TYPE t_rec_wrt_off_type IS TABLE OF rec_wrt_off_type
     INDEX BY BINARY_INTEGER;

gt_rec_wrt_off_type t_rec_wrt_off_type;

PROCEDURE create_receipt_writeoff (
       errbuf                           IN OUT NOCOPY VARCHAR2,
       retcode                          IN OUT NOCOPY VARCHAR2,
       p_receipt_currency_code   	IN ar_cash_receipts.currency_code%type,
       p_unapp_amount                   IN VARCHAR2,
       p_unapp_amount_percent	        IN VARCHAR2,
       p_receipt_date_from              IN VARCHAR2,
       p_receipt_date_to                IN VARCHAR2,
       p_receipt_gl_date_from           IN VARCHAR2,
       p_receipt_gl_date_to             IN VARCHAR2,
       p_receipt_method_id 		IN VARCHAR2,
       p_customer_number  		IN VARCHAR2,
       p_receipt_number			IN ar_cash_receipts.receipt_number%type,
       p_receivable_trx_id  		IN VARCHAR2,
       p_apply_date   			IN VARCHAR2,
       p_gl_date          		IN VARCHAR2,
       p_comments    			IN ar_receivable_applications.comments%type
       );

FUNCTION unapplied_amount(p_cash_receipt_id IN NUMBER,
                          p_currency_code   IN ar_cash_receipts.currency_code%TYPE,
                          p_user_id         IN ar_approval_user_limits.user_id%TYPE,
                          p_request_id      IN NUMBER DEFAULT NULL, /*5444407*/
			  p_exchange_rate   IN ar_cash_receipts.exchange_rate%TYPE
					default NULL,
			  p_amount_from     IN NUMBER default null,
			  p_amount_to       IN NUMBER default null)
RETURN NUMBER;

FUNCTION applied_amount(p_cash_receipt_id IN NUMBER,
                        p_request_id      IN NUMBER DEFAULT 0)
RETURN NUMBER;

FUNCTION on_account_amount(p_cash_receipt_id IN NUMBER) RETURN NUMBER;

FUNCTION balancing_segment(p_code_combination_id IN NUMBER) RETURN VARCHAR2;


END ARP_PROCESS_WRITEOFF;

 

/
