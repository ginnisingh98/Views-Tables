--------------------------------------------------------
--  DDL for Package Body AP_ACCOUNTING_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_ACCOUNTING_UTILITIES_PKG" as
/* $Header: apslautb.pls 115.5 2004/04/02 18:49:06 schitlap noship $ */

/*============================================================================
 |  FUNCTION - Get_PO_REVERSED_ENCUMB_AMOUNT
 |
 |  DESCRIPTION
 |      fetch the amount of PO encumbrance reversed against the given PO
 |      distribution from all invoices for a given date range in functional
 |      currency. Calculation includes PO encumbrance which are in GL only.
 |      In case Invoice encumbrance type is the same as PO encumbrance, we
 |      need to exclude the variance.
 |      it returns actual amount or 0 if there is po reversed encumbrance
 |      line existing, otherwise returns NULL.
 |
 |  PARAMETERS
 |      P_Po_distribution_id - po_distribution_id (in)
 |      P_Start_date - Start gl date (in)
 |      P_End_date - End gl date (in)
 |      P_Calling_Sequence - debug usage
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |      1. In case user changes the purchase order encumbrance
 |         type or Invoice encumbrance type after invoice is
 |         validated, this API might not return a valid value.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/

 FUNCTION Get_PO_Reversed_Encumb_Amount(
              P_Po_Distribution_Id   IN            NUMBER,
              P_Start_gl_Date        IN            DATE,
              P_End_gl_Date          IN            DATE,
              P_Calling_Sequence     IN            VARCHAR2 DEFAULT NULL)

 RETURN NUMBER
 IS

   l_current_calling_sequence VARCHAR2(2000);
   l_debug_info               VARCHAR2(100);
   l_debug_loc                VARCHAR2(50) :='Get_PO_Reversed_Encumb_Amount';

   l_unencumbered_amount       NUMBER;
   l_upg_unencumbered_amount   NUMBER;
   l_total_unencumbered_amount NUMBER;

   CURSOR po_enc_reversed_cur IS
   SELECT sum(nvl(ael.accounted_cr,0) - nvl(ael.accounted_dr,0))
     FROM AP_INVOICE_DISTRIBUTIONS aid,
          AP_ENCUMBRANCE_LINES ael,
          financials_system_parameters fsp
    WHERE aid.po_distribution_id = P_po_distribution_id
      AND aid.invoice_distribution_id = ael.invoice_distribution_id
      AND ( ( p_start_gl_date is not null
              and p_start_gl_date <= ael.accounting_date ) or
            ( p_start_gl_date is null ) )
      AND ( (p_end_gl_date is not null
             and  p_end_gl_date >= ael.accounting_date ) or
            (p_end_gl_date is null ) )
      AND ael.encumbrance_line_type not in ('IPV', 'ERV', 'QV')
      AND ( (ael.ae_header_id is null and
             aid.encumbered_flag = 'Y' and
             FSP.purch_encumbrance_type_id <> FSP.inv_encumbrance_type_id) or
            (ael.ae_header_id is not null and
             FSP.purch_encumbrance_type_id = FSP.inv_encumbrance_type_id and
             'Y' = ( select gl_transfer_flag
                     from ap_ae_headers aeh
                     where aeh.ae_header_id = ael.ae_header_id ) )
          )
      AND  nvl(aid.org_id,-1) =  nvl(fsp.org_id,-1)
      AND  ael.encumbrance_type_id =  fsp.purch_encumbrance_type_id;



--3133103, added this cursor as well as logic below that adds its value to the
--value of the cursor above.
   CURSOR upgraded_po_enc_rev_cur IS
   SELECT sum (nvl(nvl(aid.base_amount,aid.amount),0) -
               nvl(aid.base_invoice_price_variance ,0) -
               nvl(aid.exchange_rate_variance,0) -
               nvl(aid.base_quantity_variance,0))
     FROM   ap_invoice_distributions aid,
            po_distributions pd,
            financials_system_parameters fs
    where aid.po_distribution_id = p_po_distribution_id
      and aid.po_distribution_id = pd.po_distribution_id
      and nvl(aid.org_id,-1) = nvl(fs.org_id,-1)
      and fs.inv_encumbrance_type_id <> fs.purch_encumbrance_type_id
      and NVL(PD.accrue_on_receipt_flag,'N') = 'N'
      AND AID.po_distribution_id is not null
      AND nvl(aid.match_status_flag, 'N') = 'A'
      AND nvl(aid.encumbered_flag, 'N') = 'Y'
      AND (aid.accrual_posted_flag = 'Y' or aid.cash_posted_flag = 'Y')
      AND (( p_start_gl_date is not null and p_start_gl_date <= aid.accounting_date) or (p_start_gl_date is null))
      AND ((p_end_gl_date is not null and p_end_gl_date >= aid.accounting_date) or (p_end_gl_date is null))
      AND NOT EXISTS (SELECT 'release 11.5 encumbrance'
                        from ap_encumbrance_lines_all ael
                       where ael.invoice_distribution_id = aid.invoice_distribution_id);




 BEGIN

   l_current_calling_sequence :=  'AP_FUNDS_CONTROL_PKG.'
                                 || 'Get_PO_Reversed_Encumb_Amount<-'
                                 || P_calling_sequence;

   OPEN po_enc_reversed_cur;
   -----------------------------------------------------------
   l_debug_info :=  l_debug_loc || 'Open the po_encumbrance_cur' ;
   -------------------------------------------------------------
   FETCH po_enc_reversed_cur INTO
         l_unencumbered_amount;

   IF (po_enc_reversed_cur%NOTFOUND) THEN
     ------------------------------------------------------------
     l_debug_info :=  l_debug_loc || 'NO encumbrance line exists';
     ------------------------------------------------------------
     l_unencumbered_amount :=  NULL;
   END IF;

   CLOSE po_enc_reversed_cur;

-- Bug 3503864: Added the l_unencumbered_amount check for
--              opening the upgrade cursor

IF l_unencumbered_amount IS NULL THEN

   OPEN upgraded_po_enc_rev_cur;
   -----------------------------------------------------------
   l_debug_info :=  l_debug_loc || 'Open upgraded_po_enc_rev_cur ' ;
   -------------------------------------------------------------
   FETCH upgraded_po_enc_rev_cur INTO
         l_upg_unencumbered_amount;

   IF (upgraded_po_enc_rev_cur%NOTFOUND) THEN
     ------------------------------------------------------------
     l_debug_info :=  l_debug_loc || 'NO upgraded encumbrance reversals exist ';
     ------------------------------------------------------------
     l_upg_unencumbered_amount :=  NULL;
   END IF;

   CLOSE upgraded_po_enc_rev_cur;

END IF;


   IF (l_unencumbered_amount is not null or l_upg_unencumbered_amount is not null) THEN
     l_total_unencumbered_amount := nvl(l_unencumbered_amount,0) + nvl(l_upg_unencumbered_amount,0);
   ELSE
     l_total_unencumbered_amount := NULL;
   END IF;

   RETURN (l_total_unencumbered_amount);

 EXCEPTION
   WHEN OTHERS THEN
--
-- Bug 3546586
-- Commented this portion as FND_MESSAGE is not compliant with the pragma
-- restriction specified in the package spec. Let the calling program
-- handle the exception in this particular case.
--
/*
     IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_current_calling_sequence);
       FND_MESSAGE.SET_TOKEN('PARAMETERS', 'po distribution id =  '
                             || p_po_distribution_id );
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
     END IF;
*/
     IF ( po_enc_reversed_cur%ISOPEN ) THEN
       CLOSE po_enc_reversed_cur;
     END IF;

     RAISE;
 END Get_PO_Reversed_Encumb_Amount;


END AP_ACCOUNTING_UTILITIES_PKG;


/
