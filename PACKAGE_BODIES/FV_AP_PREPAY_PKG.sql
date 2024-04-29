--------------------------------------------------------
--  DDL for Package Body FV_AP_PREPAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_AP_PREPAY_PKG" AS
-- $Header: FVAPIPPB.pls 120.9 2005/09/13 18:52:01 ksriniva ship $
  g_module_name VARCHAR2(100) := 'fv.plsql.FV_AP_PREPAY_PKG.';
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
                        p_calling_sequence      IN VARCHAR2) IS

BEGIN
 null;
END FUNDS_RESERVE;
------------------------------------------------------------------------------------
-- Purpose :
-- This procedure is called when matching a prepayment invoice to a purchase
-- order.  If the invoice amount plus the tolerance (setup on the Define
-- Federal Options form) is greater than the remaining amount on the purchase
-- order, then the transaction is not allowed.
--
-- History
--
-- Date        Name          Comments

-- 15-JUL-2003 Shiva Nama    Created
-------------------------------------------------------------------------------

PROCEDURE tolerance_check(p_line_location_id IN NUMBER,
			  p_match_amount IN NUMBER,
                          p_min_acc_unit IN NUMBER,
                          p_precision    IN NUMBER,
                          p_tolerance_check_status OUT NOCOPY VARCHAR2) IS


  l_module_name VARCHAR2(200) := g_module_name || 'tolerance_check';
  l_errbuf      VARCHAR2(1024);
   l_prepay_tolerance_flag VARCHAR2(1);
   l_prepay_tolerance      NUMBER;
   l_billed_amount         NUMBER;
   l_total_amount          NUMBER;
   l_remain_amount         NUMBER;

   BEGIN

       p_tolerance_check_status := 'Y';

       SELECT NVL(prepayment_tolerance_flag, 'N'), prepayment_tolerance
       INTO   l_prepay_tolerance_flag, l_prepay_tolerance
       FROM   fv_operating_units;

    IF l_prepay_tolerance IS NOT NULL THEN

      SELECT DECODE(MATCHING_BASIS , 'AMOUNT' ,
      NVL(ll.amount,0)-nvl(ll.amount_cancelled,0),
     (NVL(ll.quantity,0) - NVL(ll.quantity_cancelled,0))* ll.price_override) total_amount,
      decode(matching_basis , 'AMOUNT' , NVL(ll.amount_financed,0) , NVL(ll.quantity_financed,0) * ll.price_override)  billed_amount
       INTO l_total_amount , l_billed_amount
      FROM po_line_locations_all  ll
      WHERE ll.line_location_id = p_line_location_id;


     /* ---------------------- commented out as part of PO-uptake -----------------------
       SELECT (ll.quantity  - ll.quantity_cancelled) * l.unit_price total_amount,
              (ll.quantity_billed * l.unit_price) remain_amount
       INTO l_total_amount , l_billed_amount
       FROM po_line_locations_all ll,
	    po_lines_all l
       WHERE ll.line_location_id = p_line_location_id
       AND l.po_line_id = ll.po_line_id;

      ---------------------- commented out as part of PO-uptake -----------------------  */

       l_remain_amount :=  ( (l_total_amount * ( (100+l_prepay_tolerance)/100)  )  -  l_billed_amount );


       IF (p_min_acc_unit IS NULL) THEN
           l_remain_amount := ROUND(l_remain_amount, p_precision);
        ELSE
           l_remain_amount := ROUND(l_remain_amount / p_min_acc_unit) * (p_min_acc_unit);
       END IF;

       IF l_prepay_tolerance_flag = 'Y' THEN
          IF p_match_amount >  l_remain_amount THEN
             p_tolerance_check_status := 'N';
          END IF;
         ELSE
          IF p_match_amount >  l_remain_amount THEN
             p_tolerance_check_status := 'W';
          END IF;
       END IF;

    END IF;

     EXCEPTION

       WHEN NO_DATA_FOUND THEN
      -- No OPTION defined for this org so pass the check
       NULL;

       WHEN OTHERS THEN
       p_tolerance_check_status := 'N';
       l_errbuf := SQLERRM;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);


  END tolerance_check;
-----------------------------------------------------------------------
-- PROCEDURE Get_Prorated_Amount
-- Gets the prorated prepayment amount per distribution
-- Parameters
   ----------
   -- Distribution_Table  List of Invoice Distribution Identifiers
   -- Invoice_ID Invoice Identifier
   -- Prorated_Amount_Table: OUT NOCOPY contains invoice_dist_id, amount and
   --                         ussgl_transaction_code
-----------------------------------------------------------------------------

  PROCEDURE get_prorated_amount
    (P_Invoice_ID            IN         NUMBER
    ,P_Dist_Tab              IN         dist_tab
    ,P_Prorated_Amt          OUT NOCOPY prorate_amt_tab
    ,P_calling_sequence      IN         VARCHAR2 DEFAULT NULL
    ,p_status                OUT NOCOPY NUMBER
    )
IS

BEGIN
null;
END get_prorated_amount;
-----------------------------------------------------------------------

PROCEDURE create_prepay_lines(p_packet_id IN NUMBER,
                              p_status OUT NOCOPY NUMBER) IS

BEGIN
  null;
END create_prepay_lines;
-----------------------------------------------------------------------
END fv_ap_prepay_pkg;

/
