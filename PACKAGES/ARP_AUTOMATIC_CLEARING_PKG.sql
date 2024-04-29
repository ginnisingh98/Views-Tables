--------------------------------------------------------
--  DDL for Package ARP_AUTOMATIC_CLEARING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_AUTOMATIC_CLEARING_PKG" AUTHID CURRENT_USER AS
/* $Header: ARRXACRS.pls 120.0.12010000.3 2008/11/18 18:04:58 aghoraka noship $ */
--
/*========================================================================+
 |  FUNCTION  ar_auto_clearing_in_parallel                               |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 | This drives the parallelization of Automatic Clearance process.        |
 | This spawns the AUTOCLEAR( ar_automatic_clearing_parallel) program.    |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                     Author            Description of Changes      |
 | 19-FEB-2008              aghoraka           Created                    |
 *=========================================================================*/
function ar_auto_clearing_in_parallel
(
        p_clr_remitted_receipts         IN VARCHAR2,
        p_clr_disc_receipts             IN VARCHAR2,
        p_eliminate_bank_risk           IN VARCHAR2,
        p_clear_date                    IN DATE,
        p_gl_date                       IN DATE,
        p_customer_name_low             IN VARCHAR2,
        p_customer_name_high            IN VARCHAR2,
        p_customer_number_low           IN VARCHAR2,
        p_customer_number_high          IN VARCHAR2,
        p_receipt_number_low            IN VARCHAR2,
        p_receipt_number_high           IN VARCHAR2,
        p_remittance_bank_account_id    IN NUMBER,
        p_payment_method_id             IN NUMBER,
        p_exchange_rate_type            IN VARCHAR2,
    	p_batch_id       	        IN NUMBER,
    	p_undo_clearing		     	IN VARCHAR2,
    	P_total_workers		        IN NUMBER)
RETURN BOOLEAN;
--
procedure ar_automatic_clearing_parallel
(       P_ERRBUF                        OUT NOCOPY VARCHAR2,
        P_RETCODE		       	OUT NOCOPY NUMBER,
        p_clr_remitted_receipts         IN VARCHAR2,
        p_clr_disc_receipts             IN VARCHAR2,
        p_eliminate_bank_risk           IN VARCHAR2,
        p_worker_number		        IN NUMBER DEFAULT 0,
        p_request_id  		        IN NUMBER DEFAULT 0);
--
function ar_automatic_clearing
(
        p_clr_remitted_receipts         IN VARCHAR2,
        p_clr_disc_receipts             IN VARCHAR2,
        p_eliminate_bank_risk           IN VARCHAR2,
        p_clear_date                    IN DATE,
        p_gl_date                       IN DATE,
        p_customer_name_low             IN VARCHAR2,
        p_customer_name_high            IN VARCHAR2,
        p_customer_number_low           IN VARCHAR2,
        p_customer_number_high          IN VARCHAR2,
        p_receipt_number_low            IN VARCHAR2,
        p_receipt_number_high           IN VARCHAR2,
        p_remittance_bank_account_id    IN NUMBER,
        p_payment_method_id             IN NUMBER,
        p_exchange_rate_type            IN VARCHAR2,
    	p_batch_id       	        IN NUMBER,
    	p_undo_clearing		        IN VARCHAR2)
RETURN BOOLEAN;

--
END arp_automatic_clearing_pkg;

/
