--------------------------------------------------------
--  DDL for Package Body AP_CANCEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_CANCEL_PKG" AS
/* $Header: apicancb.pls 120.35.12010000.13 2010/03/31 20:09:06 gagrawal ship $ */

  G_CURRENT_RUNTIME_LEVEL      NUMBER                := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(50) := 'AP.PLSQL.AP_CANCEL_PKG.';

-- Forward declaration of Payment Request Cancellation Subscription event
-- procedure. This will be only called if Payment Request is being cancelled
-- From Oracle Payables.
PROCEDURE Subscribe_To_Cancel_Event
                      (P_Event_Type         IN             VARCHAR2,
                       P_Invoice_ID         IN             NUMBER,
                       P_Application_ID     IN             NUMBER,
                       P_Return_Status      OUT     NOCOPY VARCHAR2,
                       P_Msg_Count          OUT     NOCOPY NUMBER,
                       P_Msg_Data           OUT     NOCOPY VARCHAR2,
                       P_Calling_Sequence   IN             VARCHAR2);

/*=============================================================================
 |  PROCEDURE Is_Invoice_Cancellable
 |
 |      Check if the line is cancellable
 |
 |  PROGRAM FLOW
 |      0. If invoice contains distribution that does not have open GL period
 |         return FALSE
 |      1. If invoice has an effective payment, return FALSE
 |      2. If invoice is selected for payment, return FALSE
 |      3. If invoice is already cancelled, return FALSE
 |      4. If invoice is credited invoice, return FALSE
 |      5. If invoices have been applied against this invoice, return FALSE
 |      6. If invoice is matched to Finally Closed PO's, return FALSE
 |      7. If project related invoices have pending adjustments, return FALSE
 |      8. If cancelling will cause qty_billed or amount_billed to less
 |         than 0, return FALSE
 |      9. If none of above, invoice is cancellable return Ture
 |  NOTES
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/
  Function Is_Invoice_Cancellable(
               P_invoice_id        IN NUMBER,
               P_error_code           OUT NOCOPY VARCHAR2,   /* Bug 5300712 */
               P_debug_info        IN OUT NOCOPY VARCHAR2,
               P_calling_sequence  IN            VARCHAR2) RETURN BOOLEAN
  IS

    CURSOR verify_no_pay_batch IS
    SELECT checkrun_id
      FROM ap_payment_schedules
     WHERE invoice_id = P_invoice_id
     FOR UPDATE NOWAIT;

   -- Bug5497058
   CURSOR qty_per_dist_negtive_count_cur IS
   SELECT count(*)
   FROM ap_invoice_distributions AID,
          po_distributions_ap_v POD,
	  po_line_locations PLL,
	  po_lines PL,
          ap_invoices AIV
    WHERE POD.po_distribution_id = AID.po_distribution_id
      AND POD.line_location_id = PLL.line_location_id
      AND PLL.po_line_id = PL.po_line_id
      AND AIV.invoice_id=AID.invoice_id
      AND NVL(AID.reversal_flag, 'N') <> 'Y'
      AND AID.invoice_id = P_invoice_id
       -- Bug 5590826. For amount related decode
      AND AID.line_type_lookup_code IN ('ITEM', 'ACCRUAL', 'IPV')
   HAVING (DECODE(AIV.invoice_type_lookup_code,'PREPAYMENT',
             SUM(NVL(POD.quantity_financed, 0)),SUM(NVL(POD.quantity_billed, 0))
	   ) -
             SUM(round(decode(AID.dist_match_type,
                             'PRICE_CORRECTION', 0,
                             'AMOUNT_CORRECTION', 0,
                             'ITEM_TO_SERVICE_PO', 0,
                             'ITEM_TO_SERVICE_RECEIPT', 0,
                              nvl( AID.quantity_invoiced, 0 ) +
                              nvl( AID.corrected_quantity,0 )
			     ) *
	               po_uom_s.po_uom_convert(AID.matched_uom_lookup_code,         --bug5844328
		                           nvl(PLL.unit_meas_lookup_code,
					       PL.unit_meas_lookup_code),
					   PL.item_id), 15)
	        ) < 0
           OR DECODE(AIV.invoice_type_lookup_code,'PREPAYMENT',
              SUM(NVL(POD.amount_financed, 0)),SUM(NVL(POD.amount_billed, 0))) -
              SUM(NVL(AID.amount, 0)) < 0 )
    GROUP BY AIV.invoice_type_lookup_code,AID.po_distribution_id;


    CURSOR dist_gl_date_cur IS
    SELECT accounting_date
      FROM ap_invoice_distributions AID
     WHERE AID.invoice_id = P_invoice_id
       AND NVL(AID.reversal_flag, 'N') <> 'Y';

    TYPE date_tab is TABLE OF DATE INDEX BY BINARY_INTEGER;
    l_gl_date_list              date_tab;
    i                           BINARY_INTEGER := 1;
    l_open_gl_date              DATE :='';
    l_open_period               gl_period_statuses.period_name%TYPE := '';

    l_curr_calling_sequence     VARCHAR2(2000);
    l_debug_info                VARCHAR2(100):= 'Is_Invoice_Cancellable';

    l_checkrun_id               NUMBER;
    l_cancel_count              NUMBER := 0;
    l_project_related_count     NUMBER := 0;
    l_payment_count             NUMBER := 0;
    l_final_close_count         NUMBER := 0;
    l_prepay_applied_flag       VARCHAR2(1);
    l_po_dist_count             NUMBER := 0;
    l_credited_inv_flag         BOOLEAN := FALSE;
    l_pa_message_name           VARCHAR2(50);
    l_org_id                    NUMBER;
    l_final_closed_shipment_count NUMBER;
    l_allow_cancel              VARCHAR2(1) := 'Y';
    l_return_code               VARCHAR2(30);
    l_enc_enabled               VARCHAR2(1);  --Bug6009101
    l_po_not_approved           VARCHAR2(1);  --Bug6009101


  BEGIN
    l_curr_calling_sequence := 'AP_INVOICE_PKG.IS_INVOICE_CANCELLABLE<-' ||
                               P_calling_sequence;

    /*-----------------------------------------------------------------+
     |  Step 0 - If invoice contain distribtuion which does not have   |
     |           OPEN gl period name, return FALSE                     |
     +-----------------------------------------------------------------*/
    /* bug 4942638. Move the next select here */
    l_debug_info := 'Get the org_id for the invoice';

    SELECT org_id
    INTO   l_org_id
    FROM   ap_invoices_all
    WHERE  invoice_id = p_invoice_id;

    l_debug_info := 'Check if inv distribution has open period';

    OPEN dist_gl_date_Cur;
    FETCH dist_gl_date_Cur
    BULK COLLECT INTO l_gl_date_list;
    CLOSE dist_gl_date_Cur;

    /* Bug 5354259. Added the following IF condition as for
       For unvalidated invoice case most of the cases there wil be no distributions */
    IF l_gl_date_list.count > 0 THEN
    FOR i in l_gl_date_list.FIRST..l_gl_date_list.LAST
    LOOP
      /* bug 4942638. Added l_org_id in the next two function call */
      l_open_period := ap_utilities_pkg.get_current_gl_date(l_gl_date_list(i), l_org_id);
      IF ( l_open_period IS NULL ) THEN
        ap_utilities_pkg.get_open_gl_date(
                 l_gl_date_list(i),
                 l_open_period,
                 l_open_gl_date,
                 l_org_id);
        IF ( l_open_period IS NULL ) THEN
          p_error_code := 'AP_DISTS_NO_OPEN_FUT_PERIOD';
          p_debug_info := l_debug_info;
          RETURN FALSE;
        END IF;
      END IF;
    END LOOP;
    END IF;

    /*-----------------------------------------------------------------+
     |  Step 1 - If invoice has an effective payment, return FALSE     |
     |           This include the check of if invoice itself is a      |
     |           PREPAYMENT type invoice - Actively referenced         |
     |           prepayment type invoice has to be fully paid when it  |
     |           is applied.                                           |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Check if invoice has an effective payment';

     SELECT   count(*)
      INTO   l_payment_count
      FROM   ap_invoice_payments P,ap_payment_schedules PS
     WHERE   P.invoice_id=PS.invoice_id
       AND   P.invoice_id = P_invoice_id
       AND   PS.payment_status_flag <> 'N'
       AND   nvl(P.reversal_flag,'N') <> 'Y'
       AND   P.amount is not NULL
       AND   exists ( select 'non void check'
                      from ap_checks A
                      where A.check_id = P.check_id
                        and void_date is null);--Bug 6135172

    IF ( l_payment_count <> 0 ) THEN
      P_error_code := 'AP_INV_CANCEL_EFF_PAYMENT';
      P_debug_info := l_debug_info;
      RETURN FALSE;
    END IF;

    /*-----------------------------------------------------------------+
     |  Step 2. If invoice is selected for payment, return FALSE       |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Check if invoice is selected for payment';

    BEGIN
      OPEN verify_no_pay_batch;
      LOOP
      FETCH verify_no_pay_batch
       INTO l_checkrun_id;
      EXIT WHEN verify_no_pay_batch%NOTFOUND;
        IF l_checkrun_id IS NOT NULL THEN
          P_error_code := 'AP_INV_CANCEL_SEL_PAYMENT';
          P_debug_info := l_debug_info || 'with no check run id';
          COMMIT;
          RETURN FALSE;
        END IF;
      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        IF ( verify_no_pay_batch%ISOPEN ) THEN
          CLOSE verify_no_pay_batch;
        END IF;
        P_error_code := 'AP_INV_CANCEL_PS_LOCKED';
        P_debug_info := l_debug_info || 'With exceptions';
        COMMIT;
        RETURN FALSE;
    END;

    /*-----------------------------------------------------------------+
     |  Step 3. If invoice is already cancelled, return FALSE          |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Check if invoice is already cancelled';

    SELECT count(*)
    INTO   l_cancel_count
    FROM   ap_invoices
    WHERE  invoice_id = P_invoice_id
    AND    cancelled_date IS NOT NULL;

    IF (l_cancel_count > 0) THEN
      P_error_code := 'AP_INV_CANCEL_ALREADY_CNCL';
      P_debug_info := l_debug_info;
      RETURN FALSE;
    END IF;

    /*-----------------------------------------------------------------+
     |  Step 4. If invoice is a credited invoice return FALSE          |
     +-----------------------------------------------------------------*/
    l_debug_info := 'Check if invoice is a credited invoice';

    l_credited_inv_flag := AP_INVOICES_UTILITY_PKG.Is_Inv_Credit_Referenced(
                               P_invoice_id);

    IF (l_credited_inv_flag <> FALSE ) THEN
      P_error_code := 'AP_INV_IS_CREDITED_INV';
      P_debug_info := l_debug_info;
      RETURN FALSE;
    END IF;

    /*-----------------------------------------------------------------+
     |  Step 5. If invoices have been applied against this invoice     |
     |          return FALSE                                           |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Check if invoices have been applied against this invoice';

    l_prepay_applied_flag :=
        AP_INVOICES_UTILITY_PKG.get_prepayments_applied_flag(P_invoice_id);

    IF (nvl(l_prepay_applied_flag,'N') = 'Y') THEN
      P_error_code := 'AP_INV_PP_NO_CANCEL';
      P_debug_info := l_debug_info;
      RETURN FALSE;
    END IF;

    /*-----------------------------------------------------------------+
     |  Step 6. If invoice is matched to a Finally Closed PO, return   |
     |          FALSE                                                  |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Check if invoice is matched to a finally closed PO';

    -- Bug fix:3488316
    -- Following code in this step has been added for JFMIP related work.
    -- This code has been modified only for federal customers, before modifying
    -- this code please get the code verified with the developer/manager
    -- who added this code.
    /* bug 4942638. Move the next select for l_org_id at the begining */

    IF (FV_INSTALL.ENABLED (l_org_id)) THEN

       BEGIN

          SELECT 'N'
          INTO l_allow_cancel
          FROM ap_invoice_distributions AID,
               po_distributions PD,
               po_line_locations pll
          WHERE aid.invoice_id = p_invoice_id
          --AND aid.final_match_flag in ('N','Y')  For Bug 3489536
          AND aid.po_distribution_id = pd.po_distribution_id
          AND pll.line_location_id = pd.line_location_id
          AND decode(pll.final_match_flag, 'Y', 'D', aid.final_match_flag) in ('N','Y') --Bug 3489536
          AND pll.closed_code = 'FINALLY CLOSED'
          AND rownum = 1;

          IF (l_allow_cancel = 'N') THEN
             P_error_code := 'AP_INV_CANNOT_OPEN_SHIPMENT';
             P_debug_info := l_debug_info;
	      RETURN(FALSE);
          END IF;

       EXCEPTION
        WHEN NO_DATA_FOUND THEN

          SELECT count(distinct pll.line_location_id)
          INTO l_final_closed_shipment_count
          FROM ap_invoice_distributions aid,
               po_line_locations pll,
               po_distributions pd
          WHERE aid.invoice_id = p_invoice_id
          AND aid.po_distribution_id = pd.po_distribution_id
          AND pd.line_location_id = pll.line_location_id
          --AND aid.final_match_flag = 'D' For bug 3489536
          AND decode(pll.final_match_flag, 'Y', 'D', aid.final_match_flag) = 'D' --Bug 3489536
          AND pll.closed_code = 'FINALLY CLOSED';

       END ;

       IF (l_final_closed_shipment_count > 1) THEN

            P_error_code := 'AP_INV_MUL_SHIP_FINALLY_CLOSED' ;
	        P_debug_info := l_debug_info;
            RETURN(FALSE);

        END IF;

        IF (l_final_closed_shipment_count = 1) THEN

          l_debug_info := 'Open the Finally Closed PO Shipment ';
          IF(NOT(FV_AP_CANCEL_PKG.OPEN_PO_SHIPMENT(p_invoice_id,
                                                  l_return_code))) THEN

            P_error_code := 'AP_INV_CANNOT_OPEN_SHIPMENT';
            P_debug_info := l_debug_info;
            RETURN(FALSE);

          END IF;

        END IF;

    ELSE


    SELECT count(*)
    INTO   l_final_close_count
    FROM   ap_invoice_lines AIL,
           po_line_locations_ALL PL
    WHERE  AIL.invoice_id = P_invoice_id
    AND    AIL.po_line_location_id = PL.line_location_id
    AND    AIL.org_id = PL.org_id
    AND    PL.closed_code = 'FINALLY CLOSED';

    IF (l_final_close_count > 0) THEN
      P_error_code := 'AP_INV_PO_FINALLY_CLOSED';
      P_debug_info := l_debug_info;
      RETURN FALSE;
    END IF;
    END IF;
    /*-----------------------------------------------------------------+
     |  Step 7. If projects have pending adjustments then return FALSE |
     +-----------------------------------------------------------------*/
    --
    -- Bug 5349193
    -- As suggested in the bug, this validation is commented in R12.
    --

    /* SELECT count(*)
    INTO   l_project_related_count
    FROM   ap_invoices AI
    WHERE  AI.invoice_id = P_invoice_id
    AND    (AI.project_id is not null OR
            exists (select 'X'
                    from   ap_invoice_distributions AIL
                    where  AIL.invoice_id = AI.invoice_id
                    and    project_id is not null) OR
            exists (select 'X'
                    from   ap_invoice_distributions AID
                    where  AID.invoice_id = AI.invoice_id
                    and    project_id is not null));

    IF (l_project_related_count <> 0) THEN
      l_pa_message_name := pa_integration.pending_vi_adjustments_exists(
                                   P_invoice_id);
      IF (l_pa_message_name <> 'N') THEN
        P_error_code := l_pa_message_name;
        P_debug_info := l_debug_info;
        RETURN FALSE;
      END IF;
    END IF; */

    /*-----------------------------------------------------------------+
     |  Step 8. if the quantity billed and amount on PO would be       |
     |          reduced to less than zero then return FALSE            |
     |          Always allow Reversal distributions to be cancelled    |
     +-----------------------------------------------------------------*/

    BEGIN

      OPEN qty_per_dist_negtive_count_cur;
      FETCH qty_per_dist_negtive_count_cur
      INTO l_po_dist_count;
      CLOSE qty_per_dist_negtive_count_cur;

    END;

    IF ( l_po_dist_count > 0 ) THEN
      P_error_code := 'AP_INV_PO_CANT_CANCEL';
      P_debug_info := l_debug_info;
      RETURN FALSE;
    END IF;

    /*-----------------------------------------------------------------+
     |  Step 9. if the invoice is matched to an unapproved PO, if the
     |          encumbrance is on, then do not allow the invoice
     |		cancellation (bug6009101)
     *-----------------------------------------------------------------*/

  l_debug_info := 'Check if the PO is unapproved';

   SELECT NVL(purch_encumbrance_flag,'N')
   INTO   l_enc_enabled
   FROM   financials_system_params_all
   WHERE  NVL(org_id, -99) = NVL(l_org_id, -99);

    if l_enc_enabled = 'Y' then

       begin

          select 'Y'
          into   l_po_not_approved
          from   po_headers POH,
                 po_distributions POD,
                 ap_invoice_distributions AID,
                 ap_invoices AI
          where  AI.invoice_id = AID.invoice_id
          and    AI.invoice_id = P_invoice_id
          and    AID.po_distribution_id = POD.po_distribution_id
          and    POD.po_header_id = POH.po_header_id
          and    POH.approved_flag <> 'Y'
          and    rownum = 1;

          EXCEPTION
             WHEN OTHERS THEN
                  NULL;

      end;

      if l_po_not_approved = 'Y' then
         p_error_code := 'AP_PO_UNRES_CANT_CANCEL';
         p_debug_info := l_debug_info;
         return FALSE;
       end if;
    end if;


    p_error_code := null;
    P_debug_info := l_debug_info;
    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
             ' P_invoice_id = '     || P_invoice_id );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      IF (qty_per_dist_negtive_count_cur%ISOPEN ) THEN
        CLOSE qty_per_dist_negtive_count_cur;
      END IF;

      IF ( dist_gl_date_cur%ISOPEN ) THEN
        CLOSE dist_gl_date_cur;
      END IF;

      P_debug_info := l_debug_info || 'With exceptions';
      RETURN FALSE;

  END Is_Invoice_Cancellable;


/*=============================================================================
 |  Function Ap_Cancel_Single_Invoice
 |
 |      cancels one invoice by executing the following sequence of steps,
 |      returning TRUE if successful and FALSE otherwise.
 |
 |  PROGRAM FLOW
 |
 |      1. check if invoice cancellable, if yes, proceed otherwise return false
 |      3.(If invoice has had tax withheld, undo withholding) - commented
 |      4. Clear out payment schedules
 |      5. Cancel all the non-discard lines
 |          a. reverse matching
 |          b. fetch the maximum distribution line number
 |          c. Set encumbered flags to 'N'
 |          d. Accounting event generation
 |          e. reverse the distributions
 |          f. update Line level Cancelled information
 |      6. Zero out the Invoice
 |      7. Run AutoApproval for this invoice
 |      8. check posting holds remain on this canncelled invoice
 |          a. if NOT exist - complete the cancellation by updating header
 |             level information set return value to TRUE
 |          b. if exist - no update, set the return valuse to FALSE, NO
 |             DATA rollback.
 |      9. Commit Data
 |      10. Populate the out parameters.
 |
 |  NOTES
 |      1. bug2328225 case of Matching a special charge only invoice to
 |         receipt so we check if the quantity invoiced is not null too
 |      2. Events Project
 |         We no longer need to prevent the cancellation of an invoice
 |         just because the accounting of related payments has not been
 |         created. Therefore, bug fixes 902110 and 2237152 are removed.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

  FUNCTION Ap_Cancel_Single_Invoice(
               P_invoice_id                 IN  NUMBER,
               P_last_updated_by            IN  NUMBER,
               P_last_update_login          IN  NUMBER,
               P_accounting_date            IN  DATE,
               P_message_name               OUT NOCOPY VARCHAR2,
               P_invoice_amount             OUT NOCOPY NUMBER,
               P_base_amount                OUT NOCOPY NUMBER,
               P_temp_cancelled_amount      OUT NOCOPY NUMBER,
               P_cancelled_by               OUT NOCOPY NUMBER,
               P_cancelled_amount           OUT NOCOPY NUMBER,
               P_cancelled_date             OUT NOCOPY DATE,
               P_last_update_date           OUT NOCOPY DATE,
               P_original_prepayment_amount OUT NOCOPY NUMBER,
               P_pay_curr_invoice_amount    OUT NOCOPY NUMBER,
	       P_Token			    OUT NOCOPY VARCHAR2,
               P_calling_sequence           IN  VARCHAR2) RETURN BOOLEAN
  IS

    CURSOR Invoice_Lines_cur IS
    SELECT *
     FROM ap_invoice_lines
    WHERE invoice_id = P_invoice_id
      AND (NVL(discarded_flag, 'N' ) <> 'Y'
           AND NVL(cancelled_flag, 'N') <> 'Y') -- Bug 6669048
  ORDER BY line_type_lookup_code;

   CURSOR Tax_Holds_Cur IS
    SELECT AH.hold_lookup_code
    FROM AP_HOLDS AH,
	 AP_HOLD_CODES AHC
    WHERE AH.invoice_id = P_invoice_id
        AND AH.hold_lookup_code = AHC.hold_lookup_code
        AND AH.release_lookup_code IS NULL
        AND AH.hold_lookup_code IN ('TAX AMOUNT RANGE','TAX VARIANCE');

   -- Cursor added for Payment Request Cancellation from Payables and
   -- notifying the calling product.

    CURSOR c_reg_products  IS
    SELECT Reg_Application_ID
    FROM   AP_Invoices_All AI,
           AP_Product_Registrations APR
    WHERE  AI.Invoice_ID = P_Invoice_ID
    AND    AI.Application_ID = APR.Reg_Application_ID
    AND    APR.Registration_Event_Type = 'INVOICE_CANCELLED';

    cursor dist_debug_cur is
    Select *
    FROM   ap_invoice_distributions_all aid
    WHERE  aid.invoice_id = p_invoice_id;

    l_inv_line_rec_list         Inv_Line_Tab_Type;
    l_ok_to_cancel              BOOLEAN := FALSE;
    l_discard_line_ok           BOOLEAN := FALSE;
    l_count                     NUMBER;
    l_holds_count               NUMBER := 0;
    l_success                   BOOLEAN;
    l_approval_status           VARCHAR2(25);
    l_result_string             VARCHAR2(240);
    l_error_code                VARCHAR2(4000);
    l_approval_return_message   VARCHAR2(2000);
    l_debug_info                VARCHAR2(240);
    l_curr_calling_sequence     VARCHAR2(2000);
    l_tax_already_calculated    BOOLEAN;
    i                           BINARY_INTEGER := 1;
    l_tax_holds_count 		NUMBER := 0;
    l_hold_code_tab		AP_ETAX_SERVICES_PKG.REL_HOLD_CODES_TYPE;
    l_token			VARCHAR2(4000);
    l_invoice_amount            AP_INVOICES_ALL.INVOICE_AMOUNT%TYPE;
    l_invoice_validation_status VARCHAR2(100);
    l_payment_status_flag       AP_INVOICES_ALL.PAYMENT_STATUS_FLAG%TYPE;
    l_invoice_type_lookup_code  AP_INVOICES_ALL.INVOICE_TYPE_LOOKUP_CODE%TYPE;
    Tax_Exception		EXCEPTION;
    --Bug 4539462 DBI logging
    l_dbi_key_value_list        ap_dbi_pkg.r_dbi_key_value_arr;

    -- Bug 6669048
    l_tax_lines_count           NUMBER := 0;
    l_self_assess_tax_count     NUMBER := 0 ; -- Bug 6694536
    l_tax_dist_count            NUMBER := 0;  -- Bug 6815172

    -- Bug 4748638
    l_Accounting_event_ID      AP_INVOICE_DISTRIBUTIONS_ALL.accounting_event_id%TYPE;
    l_cancel_dist_exists       NUMBER := 0;
    l_open_gl_date             AP_INVOICES_ALL.gl_date%type;
    l_funds_return_code        VARCHAR2(30); -- 4276409 (3462325)

    -- Payment request Cancellation Subscription
    l_return_status        varchar2(1);
    l_msg_count            number;
    l_msg_data             varchar2(2000);
    l_application_id       number;

    l_chk_encum       NUMBER := 0;             ---7264524
    l_check_encumbrance  NUMBER := 0;          ---7428195
    p_holds                       AP_APPROVAL_PKG.HOLDSARRAY;      --7264524
    p_hold_count                  AP_APPROVAL_PKG.COUNTARRAY;      --7264524
    p_release_count               AP_APPROVAL_PKG.COUNTARRAY;      --7264524
    l_procedure_name CONSTANT VARCHAR2(50) := 'cancel_single_invoice';
    prob_dist_list            varchar2(1000):=NULL; --9100425
    prob_dist_count           number :=0;           --9100425
    l_cancel_proactive_flag   varchar2(1);          --9100425

  BEGIN
    l_curr_calling_sequence := 'AP_CANCEL_PKG.AP_CANCEL_SINGLE_INVOICE<-' ||
                               P_calling_sequence;

    /*-----------------------------------------------------------------+
     |  Step 1. Check if invoice is cancellable                        |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Check if invoice is cancellable';

    l_ok_to_cancel := Is_Invoice_Cancellable(
                          P_invoice_id       => p_invoice_id,
                          P_error_code       => p_message_name,
                          P_debug_info       => l_debug_info,
                          P_calling_sequence => l_curr_calling_sequence);

    IF ( l_ok_to_cancel = FALSE ) THEN
      RETURN FALSE;
    END IF;
     SAVEPOINT CANCEL_CHECK_1; --9100425
    /*-----------------------------------------------------------------+
     |  Step 2. If invoice has had tax withheld, undo withholding      |
     |                                                                 |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Check if AWT has been performed by AutoApproval';

    SELECT count(*)
    INTO   l_count
    FROM   ap_invoices
    WHERE  invoice_id = P_invoice_id
    AND    NVL(awt_flag,'N') = 'Y';

    IF (l_count > 0) THEN

      AP_WITHHOLDING_PKG.AP_UNDO_WITHHOLDING(
              P_invoice_id,
              'CANCEL INVOICE',
              P_accounting_date,
              NULL,
              P_Last_Updated_By,
              P_Last_Update_Login,
              NULL,
              NULL,
              NULL,
              l_result_string);
    END IF;

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_debug_info);
    END IF;

    /*-----------------------------------------------------------------+
     |  Step 3.  Clear out payment schedules                           |
     |            1. Set hold_flag to 'N' to make cancelled invoice    |
     |               does not show up on 'Invoice on Hold report'.     |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Clear out payment schedules';

    UPDATE    ap_payment_schedules
    SET       gross_amount         = 0
              ,amount_remaining    = 0
              ,payment_status_flag = 'N'
              ,hold_flag           = 'N'
              ,last_updated_by     = P_last_updated_by
              ,last_update_date    = sysdate
	          ,inv_curr_gross_amount =0 --Bug5446999
    WHERE     invoice_id = P_invoice_id;

    --Bug 4539462 DBI logging
    AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_PAYMENT_SCHEDULES',
               p_operation => 'U',
               p_key_value1 => P_invoice_id,
                p_calling_sequence => l_curr_calling_sequence);

   /*-----------------------------------------------------------------+
     |  Step 4a. Delete all unprocessed bc events and update the        |
	 |          encumbered flag to 'R' 								   |
     +-----------------------------------------------------------------*/

    --Start of bug 8733916

     AP_FUNDS_CONTROL_PKG.Encum_Unprocessed_Events_Del
                         (p_invoice_id       => p_invoice_id,
                          p_calling_sequence => l_curr_calling_sequence);

     UPDATE ap_invoice_distributions aid
        SET aid.encumbered_flag = 'R'
      WHERE aid.invoice_id = p_invoice_id
        AND nvl(aid.match_status_flag,'N') <> 'A'
        AND nvl(aid.encumbered_flag,'N') <> 'Y'
        AND aid.parent_reversal_id is null
        AND aid.line_type_lookup_code NOT IN ('REC_TAX','NONREC_TAX','TRV','TERV','TIPV')
        AND nvl(aid.reversal_flag,'N')<>'Y'
	AND EXISTS (SELECT 1
                      FROM financials_system_params_all fsp
                     WHERE fsp.org_id = aid.org_id
                       AND nvl(fsp.purch_encumbrance_flag, 'N') = 'Y');

      --End of bug 8733916

    /*-----------------------------------------------------------------+
     |  Step 4b. Discard Line in Cancel Mode for each line of invoice   |
     +-----------------------------------------------------------------*/

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_debug_info := 'step4 - Now call Discard Lines for the invoice';
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_debug_info);
     END IF;


    BEGIN
      OPEN Invoice_Lines_Cur;
      FETCH Invoice_Lines_Cur
      BULK COLLECT INTO l_inv_line_rec_list;
      CLOSE Invoice_Lines_Cur;
    END;

    SELECT invoice_type_lookup_code,
           payment_status_flag,
	   invoice_amount
    INTO   l_invoice_type_lookup_code,
           l_payment_status_flag,
           l_invoice_amount
    FROM ap_invoices
    WHERE invoice_id =p_invoice_id;

    l_invoice_validation_status := ap_invoices_pkg.get_approval_status(
                                            l_invoice_id => p_invoice_id,
                                            l_invoice_amount => l_invoice_amount,
                                            l_payment_status_flag => l_payment_status_flag,
                                            l_invoice_type_lookup_code => l_invoice_type_lookup_code );

    l_debug_info := 'Dicard Lines for the invoice: Calling etax for Validated Invoice';

    IF (NVL(l_invoice_validation_status,'NEVER APPROVED') IN
			              ('APPROVED','AVAILABLE','UNPAID','FULL')) THEN

        l_success := ap_etax_pkg.calling_etax(
                               P_Invoice_id => p_invoice_id,
                               P_Calling_Mode => 'UNFREEZE INVOICE',
                               P_All_Error_Messages => 'N',
                               P_error_code => l_error_code,
                               P_Calling_Sequence => l_curr_calling_sequence);

        IF (not l_success) THEN
            p_message_name := 'AP_ETX_CANCEL_UNFRZ_INV_FAILED';
            p_token := l_error_code;
            RETURN(FALSE);
        END IF;

    END IF;


    l_debug_info := 'Dicard Lines for the invoice: Discarding Individual line';
    --Bug 5585992
    IF l_inv_line_rec_list.count > 0 THEN

      FOR i in l_inv_line_rec_list.FIRST..l_inv_line_rec_list.LAST
      LOOP
        -- Bug 5585992
        IF l_inv_line_rec_list.exists(i) THEN

           /* Added nvl condition to p_accounting_date for bug #6627060 */
          -- Bug 5584997
          l_inv_line_rec_list(i).accounting_date :=
	                  nvl(p_accounting_date,l_inv_line_rec_list(i).accounting_date);

          l_discard_line_ok := AP_INVOICE_LINES_PKG.Discard_Inv_Line(
                               P_line_rec          => l_inv_line_rec_list(i),
                               P_calling_mode      => 'CANCEL',
                               P_inv_cancellable   => 'Y',
                               P_last_updated_by   => p_last_updated_by,
                               P_last_update_login => p_last_update_login,
                               P_error_code        => l_error_code,
			       P_Token		   => l_token,
                               P_calling_sequence  => l_curr_calling_sequence);

          IF ( l_discard_line_ok = FALSE ) THEN
            P_Message_Name := l_error_code;
            P_Token := l_token;
            RETURN FALSE;
          END IF;

        END IF;

      END LOOP;

    l_inv_line_rec_list.DELETE;

    ELSE

      l_discard_line_ok := TRUE;

    END IF;

    --ETAX:
    l_tax_already_calculated := AP_ETAX_UTILITY_PKG.Is_Tax_Already_Calc_Inv(
				P_Invoice_Id => p_invoice_id,
			 	P_Calling_Sequence => l_curr_calling_sequence);

    IF (l_tax_already_calculated) THEN

      --Commented below 3 SELECT and checking all types of tax lines count
      --together in single SELECT, which needs to cancel. Bug#9244765

      /*
       -- Bug 6669048. Get the count of tax lines that have not been cancelled.
       SELECT count(*)
       INTO   l_tax_lines_count
       FROM   ap_invoice_lines
       WHERE  invoice_id = p_invoice_id
       AND    line_type_lookup_code = 'TAX'
       AND    NVL(cancelled_flag,'N') <> 'Y'
       AND rownum =1;

      -- Bug 6694536. Need to call the etax api to reverse the self assessed tax lines.

        SELECT count(*)
       INTO l_self_assess_tax_count
       FROM ap_self_assessed_tax_dist_all asat,
            zx_rec_nrec_dist zx_dist
       WHERE invoice_id = p_invoice_id
        AND asat.detail_tax_dist_id = zx_dist.rec_nrec_tax_dist_id
        AND zx_dist.self_assessed_flag = 'Y'
        AND nvl(zx_dist.reverse_flag, 'N') <> 'Y'
        AND line_type_lookup_code IN ('REC_TAX', 'NONREC_TAX')
        AND rownum =1;

        -- Bug 	6815172. Get the count of tax distribution lines that
        --  have not been cancelled in case of inclusive tax.

        SELECT count(*)
        INTO l_tax_dist_count
        FROM zx_rec_nrec_dist zx_dist,
             ap_invoice_distributions ap_dist
        WHERE ap_dist.invoice_id = p_invoice_id
        AND ap_dist.detail_tax_dist_id = zx_dist.rec_nrec_tax_dist_id
        AND nvl(zx_dist.reverse_flag, 'N') <> 'Y'
        AND nvl(zx_dist.inclusive_flag, 'N') = 'Y'
        AND ap_dist.line_type_lookup_code IN ('REC_TAX', 'NONREC_TAX')
        AND rownum =1;  */


        SELECT count(*)
        INTO l_tax_lines_count
        FROM zx_lines_summary zls
        WHERE zls.trx_id = p_invoice_id
          and zls.application_id = 200
          and zls.entity_code = 'AP_INVOICES'
	  and zls.event_class_code In ('STANDARD INVOICES',
                                       'PREPAYMENT INVOICES',
                                       'EXPENSE REPORTS')
          and NVL(zls.reporting_only_flag, 'N') = 'N'
          and nvl(zls.cancel_flag, 'N') <> 'Y'
          and  rownum =1;

      --End of 9244765


      -- Bug 7553603
      -- cancelled_flag needs to be set prior to calling the tax api as
      -- the line_level_action needs to be sent as DISCARD. This was
      -- a regression from bug 6669048.

      UPDATE ap_invoice_lines
      SET    cancelled_flag = 'Y'
      WHERE  invoice_id = P_invoice_id
      AND    NVL(discarded_flag, 'N' ) <> 'Y';


         --Bug# 9244765. Commented all counts check and now checking with
	 --only correct count

       /*
       -- Bug 6669048. We should not be calling the etax API if all the tax
       -- lines have already been cancelled.
           IF l_tax_lines_count > 0  OR l_self_assess_tax_count > 0
             OR l_tax_dist_count > 0   -- Bug 6815172    THEN */

	  IF l_tax_lines_count > 0  THEN

	  --End of 9244765


          l_success := ap_etax_pkg.calling_etax(p_invoice_id => p_invoice_id,
			     p_calling_mode => 'CANCEL INVOICE',
			     p_all_error_Messages => 'N',
			     p_error_code => l_error_code,
			     p_calling_sequence => l_curr_calling_sequence);

          IF NOT(l_success) THEN
     	     Raise Tax_Exception;
          END IF;

       END IF;

    END IF;


    /*-----------------------------------------------------------------+
     |  Step 4.5 Proactive Cancellation Check ->fires Based on profile |
     +-----------------------------------------------------------------*/
    -- 9100425
 BEGIN
   fnd_profile.get('AP_ENHANCED_DEBUGGING', l_cancel_proactive_flag);

   IF nvl(l_cancel_proactive_flag,'N') ='C' then

    For I in(select invoice_distribution_id
     from ap_invoice_distributions aid1
     where aid1.invoice_id=P_invoice_id
     and aid1.parent_reversal_id is  null --original dist
     --for original dists there is no reversal dist created
     and ( not exists (select 1 from ap_invoice_distributions aid2
     where aid1.invoice_id=aid2.invoice_id
     and aid2.invoice_id=P_invoice_id
     and aid2.invoice_line_number=aid1.invoice_line_number
     and aid2.parent_reversal_id =aid1.invoice_distribution_id)
     --the reversal dist does not reverse the amount correctly
     or  exists (select 1 from ap_invoice_distributions aid2
     where aid1.invoice_id=aid2.invoice_id
     and aid2.invoice_id=P_invoice_id
     and aid2.invoice_line_number=aid1.invoice_line_number
     and aid2.parent_reversal_id =aid1.invoice_distribution_id
     and -1 * aid2.amount <> aid1.amount)))

     LOOP
       prob_dist_list := prob_dist_list||','||i.invoice_distribution_id;
       prob_dist_count:=prob_dist_count+1;

     end loop;

           IF prob_dist_count > 0 then
           P_message_name := 'AP_INV_DIS_CAN_FAIL';
           P_Token := prob_dist_list;
           ROLLBACK TO SAVEPOINT CANCEL_CHECK_1;

            RETURN (FALSE);
           end if;

   END IF;

 EXCEPTION WHEN OTHERS THEN
 NULL;
END;
--9100425


    /*-----------------------------------------------------------------+
     |  Step 5. Zero out the invoice for main invoice table            |
     +-----------------------------------------------------------------*/

    IF ( l_discard_line_ok )  and prob_dist_count =0 THEN --9100425
      l_debug_info := 'Zero out the invoice';

      UPDATE ap_invoices
      SET    invoice_amount = 0
             ,base_amount = 0
             ,temp_cancelled_amount = DECODE(temp_cancelled_amount, NULL,
                                            invoice_amount,
                                            DECODE(invoice_amount, 0,
                                                   temp_cancelled_amount,
                                                   invoice_amount))
             ,pay_curr_invoice_amount = 0
             ,last_updated_by = P_last_updated_by
             ,last_update_date = sysdate
      WHERE  invoice_id = P_invoice_id;

      -- Bug 6669048. Update the cancelled_flag for all the lines to 'Y' since
      -- at this point all the invoice lines have been discarded including the
      -- tax lines and AWT lines
      UPDATE ap_invoice_lines
      SET    cancelled_flag = 'Y'
      WHERE  invoice_id = P_invoice_id
      AND    NVL(discarded_flag, 'N' ) <> 'Y';

      --Bug 4539462 DBI logginG
      AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICES',
               p_operation => 'U',
               p_key_value1 => P_Invoice_Id,
                p_calling_sequence => l_curr_calling_sequence);

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_debug_info := 'Before call approval pkg again ';
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_debug_info);

         FOR l_inv_dist_rec IN dist_debug_cur
         loop
           l_debug_info :='invoice distribution looks like'||
                         'l_dist_type = ' || l_inv_dist_rec.line_type_lookup_code||
                         'l_amount=' || l_inv_dist_rec.amount ||
                         'l_base_amount =' || l_inv_dist_rec.base_amount ||
                         'l_match_status_flag=' ||l_inv_dist_rec.match_status_flag ;
           FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_debug_info);
         end loop;

     END IF;

    /*-----------------------------------------------------------------+
     |  Step 7. Run Approval again for this cancelled invoice          |
     |           Ignore message returned from APPROVE process          |
     +-----------------------------------------------------------------*/

      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_debug_info := 'Run Approval for this invoice again';
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_debug_info);
      END IF;

      --SMYADAM: Approve procedure calls 4 etax apis (calculate, distribute, validate, freeze).
      --Do we need to call these apis when the invoice is being cancelled also (looks unnecessary)
      --, if we decide not to call these apis for cancellation case,
      --what if the invoice cancellation doesn't go thru due to postable holds which
      --we will know only after the validation has been done, and then since we did not
      --call the etax apis during the approve call and the invoice is not cancelled , won't
      --the tax data on this invoice be stale. ??

      AP_APPROVAL_PKG.APPROVE(
           P_RUN_OPTION         => '',
           P_INVOICE_BATCH_ID   => '',
           P_BEGIN_INVOICE_DATE => '',
           P_END_INVOICE_DATE   => '',
           P_VENDOR_ID          => '',
           P_PAY_GROUP          => '',
           P_INVOICE_ID         => P_invoice_id,
           P_ENTERED_BY         => '',
           P_SET_OF_BOOKS_ID    => '',
           P_TRACE_OPTION       => '',
           P_CONC_FLAG          => 'N',
           P_HOLDS_COUNT        => l_holds_count,
           P_APPROVAL_STATUS    => l_approval_status,
           P_FUNDS_RETURN_CODE  => l_funds_return_code, -- 4276409 (3462325)
	   P_CALLING_MODE	=> 'CANCEL',
           P_CALLING_SEQUENCE   => l_curr_calling_sequence,
           P_COMMIT             => 'N');

      l_approval_return_message := FND_MESSAGE.GET;

      ----7264524 STARTS

       l_debug_info := 'Check for INSUFFICIENT HOLDS and CANT FUNDS CHECK Holds';

       BEGIN

        SELECT count(*)
          INTO l_chk_encum
          FROM ap_holds       AH
               ,ap_hold_codes AHC
         WHERE AH.invoice_id = P_invoice_id
           AND AH.hold_lookup_code = AHC.hold_lookup_code
           AND AH.release_lookup_code IS NULL
           AND AHC.postable_flag = 'N'
	   AND AH.hold_lookup_code IN ('INSUFFICIENT FUNDS','CANT FUNDS CHECK');


	  --7428195 starts
          -- bug8657682
         SELECT count(*)
           INTO l_check_encumbrance
           FROM ap_invoice_distributions_all
           WHERE invoice_id = P_invoice_id
           AND encumbered_flag = 'Y'
           AND rownum < 2;

	  IF (l_chk_encum<>0  AND l_check_encumbrance = 0  ) THEN




		AP_APPROVAL_PKG.Process_Inv_Hold_Status(
						P_invoice_id,
						null,
						null,
						'INSUFFICIENT FUNDS',
						'N',
						null,
						7264524,
						p_holds,
						p_hold_count,
						p_release_count,
						'release before cancel');


		AP_APPROVAL_PKG.Process_Inv_Hold_Status(
						P_invoice_id,
						null,
						null,
						'CANT FUNDS CHECK',
						'N',
						null,
						7264524,
						p_holds,
						p_hold_count,
						p_release_count,
						'release before cancel');

               -- bug9465105
               AP_ACCOUNTING_EVENTS_PKG.Update_Invoice_Events_Status
	                                       (p_invoice_id,
                                                l_curr_calling_sequence);

          END IF;


         EXCEPTION
           WHEN OTHERS THEN
             l_chk_encum := 0;

       END;

      ---7428195 ends
      ---7264524 ENDS
    /*-----------------------------------------------------------------+
     |  Step 8. Check if there are posting hold exist                  |
     +-----------------------------------------------------------------*/

      l_debug_info := 'Get the number of posting holds for invoice';

      BEGIN
        SELECT count(*)
          INTO l_holds_count
          FROM ap_holds       AH
               ,ap_hold_codes AHC
         WHERE AH.invoice_id = P_invoice_id
           AND AH.hold_lookup_code = AHC.hold_lookup_code
           AND AH.release_lookup_code IS NULL
           AND AHC.postable_flag = 'N';
      EXCEPTION
        WHEN OTHERS THEN
          l_holds_count := 0;
      END;


      IF (l_holds_count = 0)  THEN

    /*-----------------------------------------------------------------+
     |  Step 9A. Complete Cancel process if no postable hold           |
     |		  1. Check if any tax holds,if so call etax to 	       |
     |		     release tax holds.				       |
     |            2. Update the invoice header information             |
     |            3. Release all the holds                             |
     |            4. set return value to TRUE - indicate success       |
     +-----------------------------------------------------------------*/
        l_debug_info := 'Check if invoice has any tax holds';

        SELECT count(*)
        INTO l_tax_holds_count
        FROM ap_holds       AH
            ,ap_hold_codes AHC
        WHERE AH.invoice_id = P_invoice_id
        AND AH.hold_lookup_code = AHC.hold_lookup_code
        AND AH.release_lookup_code IS NULL
        AND AH.hold_lookup_code IN ('TAX AMOUNT RANGE','TAX VARIANCE');

        IF (l_tax_holds_count <> 0) THEN

	  OPEN Tax_Holds_Cur;
	  FETCH Tax_Holds_Cur bulk collect into l_hold_code_tab;
	  CLOSE Tax_Holds_Cur;

          l_debug_info := 'Call Etax to release tax holds';

	  l_success:= ap_etax_services_pkg.release_tax_holds(
                             p_invoice_id => p_invoice_id,
                             p_calling_mode => 'RELEASE TAX HOLDS',
                             p_tax_hold_code => l_hold_code_tab,
                             p_all_error_messages => 'N',
                             p_error_code => l_error_code,
                             p_calling_sequence => l_curr_calling_sequence);

          IF NOT(l_success) THEN
	     Raise Tax_Exception;
	  END IF;

        END IF;

    /*-----------------------------------------------------------------+
     |  Step 9A. Complete Cancel process if no postable hold           |
     |		       Create single invoice cancelled accounting event	     |
     |		       This is a code fix combined with the following bugs   |
     |		       3574680, 2993905 while fixing 4748638                 |
     +-----------------------------------------------------------------*/

      -- Start Bug fix 4748638 (4881719)
      --Bug#3574680, determine if cancelled distributions exists
      SELECT COUNT(invoice_distribution_id)
      INTO l_cancel_dist_exists
      FROM ap_invoice_distributions
      WHERE invoice_id=p_invoice_id
      AND cancellation_flag='Y'
      AND rownum=1;

      IF NVL(l_cancel_dist_exists,0) <> 0  THEN

        AP_ACCOUNTING_EVENTS_PKG.Create_Events (
              'INVOICE CANCELLATION'
              ,NULL   -- p_doc_type
              ,p_invoice_id
              ,p_accounting_date
              ,l_Accounting_event_ID
              ,NULL    -- checkrun_name
              ,P_calling_sequence);
      END IF;

      -- BUG fix 4748638 END


        l_debug_info := 'Cancelling the invoice if no postable holds';

        UPDATE ap_invoices
        SET    cancelled_by      = P_last_updated_by
               ,cancelled_amount = temp_cancelled_amount
               ,cancelled_date   = sysdate
               ,last_updated_by  = P_last_updated_by
               ,last_update_date = sysdate
        WHERE  invoice_id = P_invoice_id;

        -- bug9322013
        AP_ACCOUNTING_EVENTS_PKG.Set_Prepay_Event_Noaction
              (p_invoice_id,
               l_curr_calling_sequence);

        UPDATE ap_holds
        SET    release_lookup_code  = 'APPROVED'
               ,release_reason      = ( SELECT description
                                          FROM ap_hold_codes
                                         WHERE hold_lookup_code = 'APPROVED')
               ,last_update_date    = SYSDATE
               ,last_updated_by     = P_last_updated_by
               ,last_update_login   = P_last_update_login
        WHERE  invoice_id           = P_invoice_id
        AND  release_lookup_code IS NULL ;

        l_success := TRUE;

	--Bug 4539462 DBI logging
	AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICES',
               p_operation => 'U',
               p_key_value1 => P_Invoice_id,
                p_calling_sequence => l_curr_calling_sequence);

       AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_HOLDS',
               p_operation => 'U',
               p_key_value1 => P_Invoice_id,
                p_calling_sequence => l_curr_calling_sequence);

        COMMIT;

      ELSE

    /*-----------------------------------------------------------------+
     |  Step 9B. Special treatment for an invoice with POSTABLE HOLD   |
     |            During Cancellation.                                 |
     |            1. populate returned error message                   |
     |            2. set return value to FALSE                         |
     |            Invoice Header Level data will not be marked as      |
     |            CANCELLED to allow user to release any hold when they|
     |            review. We also need to commit data because the      |
     |            postable holds if any will be depending on the       |
     |            reversed data                                        |
     +-----------------------------------------------------------------*/

        l_debug_info := 'Special treatment for an invoice with POSTABLE HOLDS';

        P_message_name := 'AP_INV_CANCEL_POSTING_HOLDS';
        l_success := FALSE;

      END IF;  -- end of check l_hold_count of postable hold

    /*-----------------------------------------------------------------+
     |  Step 10. Commit Data for success cancelled invoice and invoice |
     |           with postable hold                                    |
     +-----------------------------------------------------------------*/

      l_debug_info := 'Committing changes to database';

     /*----------------------------------------------------------------+
     |  Step 10.5. Calling API for Payment Request Cancellation        |
     |             Subscribe Event                                     |
     +-----------------------------------------------------------------*/

      l_debug_info := 'Calling Payment Request Cancellation Subscription API';
     -- Payment request Cancellation from Payables
       IF p_calling_sequence not in ('ar_refund_pvt.cancel_refund','IGS_FI_PRC_APINT.CANCEL_INVOICE')  THEN
           /* added 'IGS_FI_PRC_APINT.CANCEL_INVOICE' for bug 5948586 as we need not call
              the Subscribe_To_Cancel_Event if ap_cancel_single invoice is called from SF module.
              plz see the bug for details. */

          OPEN c_reg_products;
          LOOP
          FETCH c_reg_products INTO l_application_id;
          EXIT WHEN c_reg_products%NOTFOUND;

          AP_CANCEL_PKG.Subscribe_To_Cancel_Event(
               P_Event_Type       => 'INVOICE_CANCELLED',
               P_Invoice_ID       => P_invoice_id,
               P_Application_ID   => l_application_id,
               P_Return_Status    => l_return_status,
               P_Msg_Count        => l_msg_count,
               P_Msg_Data         => l_msg_data,
               P_Calling_Sequence => l_curr_calling_sequence);

          IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
             FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => l_msg_count,
                            p_data    => l_msg_data);
             l_debug_info := l_msg_data;
             RETURN FALSE;
          END IF;

          END LOOP;
        END IF;

    /*-----------------------------------------------------------------+
     |  Step 11. Populate the Out parameter                            |
     +-----------------------------------------------------------------*/

      l_debug_info := 'Populate OUT parameters';

      SELECT invoice_amount
             ,base_amount
             ,temp_cancelled_amount
             ,cancelled_by
             ,cancelled_amount
             ,cancelled_date
             ,last_update_date
             ,original_prepayment_amount
             ,pay_curr_invoice_amount
        INTO P_invoice_amount
             ,P_base_amount
             ,P_temp_cancelled_amount
             ,P_cancelled_by
             ,P_cancelled_amount
             ,P_cancelled_date
             ,P_last_update_date
             ,P_original_prepayment_amount
             ,P_pay_curr_invoice_amount
        FROM ap_invoices
       WHERE invoice_id = P_invoice_id;

      RETURN l_success;

    ELSE
      l_debug_info := 'Discard line(s) is not successful';
      RETURN FALSE;
    END IF; -- end of check l_discard_line_ok flag

  EXCEPTION
    WHEN TAX_EXCEPTION THEN
      IF ( Invoice_Lines_Cur%ISOPEN ) THEN
        CLOSE Invoice_Lines_Cur;
      END IF;
      IF (Tax_Holds_Cur%ISOPEN) THEN
	CLOSE Tax_Holds_Cur;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN FALSE;
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
            ' P_invoice_id = '   || P_invoice_id
          ||' P_last_updated_by = '   || P_last_updated_by
          ||' P_last_update_login = ' || P_last_update_login
          ||' P_accounting_date = '   || P_accounting_date);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      IF ( Invoice_Lines_Cur%ISOPEN ) THEN
        CLOSE Invoice_Lines_Cur;
      END IF;
      IF (Tax_Holds_Cur%ISOPEN) THEN
	CLOSE Tax_Holds_Cur;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN FALSE;

  END Ap_Cancel_Single_Invoice;

/*=============================================================================
 |  PROCEDURE Ap_Cancel_Invoices
 |
 |      Cancels all invoices associated with the payment given by P_check_id
 |
 |  PROGRAM FLOW
 |
 |      Invoices that are not eligible for cancellation:
 |      1. invoices associated with an effective payment,
 |      2. invoices that are selected for payment,
 |      3. invoices that are already cancelled
 |      4. invoices (prepayments) that have been used by other invoices
 |      5. invoices that are matched to Finally Closed PO's)
 |      6. invoices which were paid originally by check but whose payment
 |         was removed prior to the voiding of the check i.e. through an
 |         invoice adjustment are left unaffected.
 |
 |  NOTES
 |      1. AutoApproval is run for each invoice.  If the invoice has posting
 |         holds, it is zeroed out by reversing all invoice distributions and
 |         PO matching, but the invoice is not cancelled.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

  PROCEDURE Ap_Cancel_Invoices(
                P_check_id          IN  NUMBER,
                P_last_updated_by   IN  NUMBER,
                P_last_update_login IN  NUMBER,
                P_accounting_date   IN  DATE,
                P_num_cancelled     OUT NOCOPY NUMBER,
                P_num_not_cancelled OUT NOCOPY NUMBER,
                P_calling_sequence  IN  VARCHAR2)
  IS
    l_num_cancelled              NUMBER := 0;
    l_num_not_cancelled          NUMBER := 0;
    l_success                    BOOLEAN;
    l_message_name               VARCHAR2(30);
    l_invoice_amount             NUMBER;
    -- bug 6883407
    l_invoice_gl_date            DATE;

    l_base_amount                NUMBER;
    l_temp_cancelled_amount      NUMBER;
    l_cancelled_by               NUMBER;
    l_cancelled_amount           NUMBER;
    l_pay_curr_invoice_amount    NUMBER;
    l_cancelled_date             DATE;
    l_last_update_date           DATE;
    l_debug_info                 VARCHAR2(240);
    l_original_prepayment_amount NUMBER;
    l_curr_calling_sequence      VARCHAR2(2000);
    l_token			 VARCHAR2(4000);

    /*-----------------------------------------------------------------+
     |  Declare cursor to select all invoices associated with the      |
     |  payment given by P_check_id and ensuring that the invoice was  |
     |  effectively being paid by the check i.e. the invoice payment   |
     |  wasn't already reversed.                                       |
     +-----------------------------------------------------------------*/

    --bug 5182311 Modified the cursor to ignore already cancelled invoices
    -- Bug 8257752. Commented out the reversal_flag condition.

    CURSOR invoices_cursor IS
    SELECT DISTINCT aip.invoice_id
    FROM   ap_invoice_payments aip,ap_invoices ai
    WHERE  aip.check_id = P_check_id
    --AND    nvl(aip.reversal_flag, 'N') <> 'Y'
    AND    ai.invoice_id=aip.invoice_id
    AND    ai.cancelled_date is null;

    TYPE inv_ib_tab_Type IS TABLE OF ap_invoices.invoice_id%TYPE;

    l_invoice_id_list          inv_ib_tab_Type;
    i                          BINARY_INTEGER :=1;

  BEGIN
    l_curr_calling_sequence := 'AP_CANCEL_PKG.AP_CANCEL_INVOICES<-' ||
                               P_calling_sequence;

    l_debug_info := 'Open invoices_cursor and do bulk fetch';

    OPEN invoices_cursor;
    FETCH invoices_cursor
    BULK COLLECT INTO l_invoice_id_list;
    CLOSE invoices_cursor;

    FOR i IN l_invoice_id_list.FIRST..l_invoice_id_list.LAST
    LOOP

    -- bug 6883407
    l_debug_info := 'Fetch Invoice GL Date.';
    SELECT ai.gl_date
    INTO   l_invoice_gl_date
    FROM   ap_invoices ai
    WHERE  ai.invoice_id = l_invoice_id_list(i);


      l_success := AP_Cancel_Single_Invoice(
                       l_invoice_id_list(i),
                       P_last_updated_by,
                       P_last_update_login,
                       l_invoice_gl_date, --P_accounting_date,-- bug 6883407
                       l_message_name,
                       l_invoice_amount,
                       l_base_amount,
                       l_temp_cancelled_amount,
                       l_cancelled_by,
                       l_cancelled_amount,
                       l_cancelled_date,
                       l_last_update_date,
                       l_original_prepayment_amount,
                       l_pay_curr_invoice_amount,
		       l_token,
                       l_curr_calling_sequence);

      IF (l_success) THEN
        l_num_cancelled := l_num_cancelled + 1;
      ELSE
        l_num_not_cancelled := l_num_not_cancelled + 1;
      END IF;

    END LOOP;

    l_invoice_id_list.DELETE;

    P_num_cancelled := l_num_cancelled;
    P_num_not_cancelled := l_num_not_cancelled;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                              ' P_check_id = '     || P_check_id
          ||' P_last_updated_by = '   || P_last_updated_by
          ||' P_last_update_login = ' || P_last_update_login
          ||' P_accounting_date = '   || P_accounting_date);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      IF ( invoices_cursor%ISOPEN ) THEN
        CLOSE invoices_cursor;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Ap_Cancel_Invoices;

  -- Added for Payment Request Cancellation from Payables.
  -- Procedure to subscribe to the invoice cancellation event by other products
  -- This procedure checks the product registry table for all the product that have
  -- subscribed to cancellation event and calls the product API.
  ---------------------------------------------------------------------------------
  PROCEDURE Subscribe_To_Cancel_Event
                      (P_Event_Type         IN             VARCHAR2,
                       P_Invoice_ID         IN             NUMBER,
                       P_Application_ID     IN             NUMBER,
                       P_Return_Status      OUT     NOCOPY VARCHAR2,
                       P_Msg_Count          OUT     NOCOPY NUMBER,
                       P_Msg_Data           OUT     NOCOPY VARCHAR2,
                       P_Calling_Sequence   IN             VARCHAR2) IS


  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);

  l_stmt                      VARCHAR2(1000);
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);


  CURSOR c_products_registered IS
  SELECT Reg_Application_ID,
         Registration_API
  FROM   AP_Product_Registrations
  WHERE  Reg_Application_ID = P_Application_ID
  AND    Registration_Event_Type = P_Event_Type;

   BEGIN

    -- Update the calling sequence
    --
    current_calling_sequence := 'AP_Cancel_PKG.Subscribe_To_Cancel_Event<-' ||
                                           P_calling_sequence;

    debug_info := 'Calling the subscribe payment event API';

    FOR c_product_rec IN c_products_registered
    LOOP

        l_stmt := 'Begin ' ||
                   c_product_rec.Registration_API ||
                          '(:P_Event_Type,' ||
                           ':P_Invoice_ID,' ||
                           ':l_return_Status,' ||
                           ':l_msg_count,' ||
                           ':l_msg_data);' ||
                  'End;';

        EXECUTE IMMEDIATE l_stmt
                  USING IN  P_Event_Type,
                        IN  P_Invoice_ID,
                        OUT l_return_status,
                        OUT l_msg_count,
                        OUT l_msg_data;

        P_Return_Status := l_return_status;
        P_Msg_Count := l_msg_count;
        P_Msg_Data := l_msg_data;


    END LOOP;

  EXCEPTION

    WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
             FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
             FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
             FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
             FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_id = ' || to_char(P_Invoice_ID));
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
         END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

  END Subscribe_To_Cancel_Event;

END AP_CANCEL_PKG;

/
