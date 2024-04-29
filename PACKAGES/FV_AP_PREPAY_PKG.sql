--------------------------------------------------------
--  DDL for Package FV_AP_PREPAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_AP_PREPAY_PKG" AUTHID CURRENT_USER AS
-- $Header: FVAPIPPS.pls 120.0 2003/09/15 21:36:51 snama noship $
PROCEDURE Funds_Reserve(p_invoice_id            IN NUMBER,
                        p_unique_packet_id_per  IN VARCHAR2,
                        p_set_of_books_id       IN NUMBER,
                        p_base_currency_code    IN VARCHAR2,
                        p_inv_enc_type_id       IN NUMBER,
                        p_purch_enc_type_id     IN NUMBER,
                        p_conc_flag             IN VARCHAR2,
                        p_system_user           IN NUMBER,
                        p_ussgl_option          IN VARCHAR2,
                        p_holds                 IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
                        p_hold_count            IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
                        p_release_count         IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
                        p_calling_sequence      IN VARCHAR2);
 ------------------------------------------------------------------------------
-- Purpose :
-- This package is called when matching a prepayment invoice to a purchase
-- order.  If the invoice amount plus the tolerance (setup on the Define
-- Federal Options form) is greater than the remaining amount on the purchase
-- order, then the transaction is not allowed.
--
-- History
--
-- Date        Name          Comments

-- 15-JUL-2003 Shiva Nama    Created


PROCEDURE tolerance_check(p_line_location_id IN NUMBER,
			  p_match_amount IN NUMBER,
                          p_min_acc_unit  in number,
                          p_precision  in number,
			  p_tolerance_check_status OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------------
PROCEDURE create_prepay_lines(p_packet_id IN NUMBER,
			      p_status OUT NOCOPY NUMBER);
--------------------------------------------------------------------------------
TYPE r_dist_info IS RECORD
    (invoice_dist_id  ap_invoice_distributions.invoice_distribution_id%TYPE
     ,item_amount     ap_invoice_distributions.amount%TYPE);

TYPE r_prorate_info IS RECORD
    (invoice_dist_id      ap_invoice_distributions.invoice_distribution_id%TYPE
     ,prorated_amount     ap_invoice_distributions.amount%TYPE
     ,ussgl_transaction_code ap_invoice_distributions.ussgl_transaction_code%TYPE
     ,code_combination_id  ap_invoice_distributions.dist_code_combination_id%TYPE );

TYPE prorate_amt_tab IS TABLE OF r_prorate_info
        INDEX BY BINARY_INTEGER;

TYPE dist_tab IS TABLE OF r_dist_info
        INDEX BY BINARY_INTEGER;

g_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('FV_DEBUG_FLAG'),'N');

PROCEDURE get_prorated_amount(p_invoice_id IN NUMBER
                    	     ,p_dist_tab   IN dist_tab
                    	     ,p_prorated_amt OUT NOCOPY prorate_amt_tab
                    	     ,p_calling_sequence IN VARCHAR2 DEFAULT NULL
			     ,p_status OUT NOCOPY NUMBER);
--------------------------------------------------------------------------------

END FV_AP_PREPAY_PKG;

 

/
