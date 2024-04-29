--------------------------------------------------------
--  DDL for Package Body AP_INVOICE_LINES_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_INVOICE_LINES_UTILITY_PKG" AS
/* $Header: apilnutb.pls 120.31.12010000.10 2010/02/09 12:06:07 asansari ship $ */

/*=============================================================================
 |  FUNCTION - get_encumbered_flag()
 |
 |  DESCRIPTION
 |      returns the invoice-level encumbrance status of an invoice.
 |      Establish the invoice line level encumbrance flag.
 |      Function will return one of the following statuses
 |       'Y' - Fully encumbered
 |       'P' - One or more distributions is encumbered, but not all
 |       'N' - No distributions are encumbered
 |       ''  - Budgetary control disabled
 |  PARAMETERS
 |      p_invoice_id - invoice id
 |      p_line_number - invoice line number
 |
 |  NOTES
 |      -- Meaning of distribution encumbrance_flag:
 |      -- Y: Regular line, has already been successfully encumbered by AP.
 |      -- W: Regular line, has been encumbered in advisory mode even though
 |      --    insufficient funds existed.
 |      -- H: Line has not been encumbered yet, since it was put on hold.
 |      -- N or Null : Line not yet seen by this code.
 |      -- D: Same as Y for reversal distribution line.
 |      -- X: Same as W for reversal distribution line.
 |      -- P: Same as H for reversal distribution line.
 |      -- R: Same as N for reversal distribution line.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_encumbered_flag(
                 p_invoice_id  IN  NUMBER,
                 p_line_number IN  NUMBER )
    RETURN VARCHAR2
    IS
      l_purch_encumbrance_flag    VARCHAR2(1) := '';
      l_encumbered_flag           VARCHAR2(1) := '';
      l_distribution_count        number      := 0;
      l_encumbered_count          number      := 0;
      l_org_id                    FINANCIALS_SYSTEM_PARAMS_ALL.ORG_ID%TYPE;

      CURSOR encumbrance_flag_cursor is
      SELECT nvl(encumbered_flag,'N')
      FROM   ap_invoice_distributions
      WHERE  invoice_id = p_invoice_id
        AND  invoice_line_number = p_line_number;
    BEGIN


    -- Added the IF condition for the bug 8763038
    IF ( p_invoice_id IS NOT NULL ) THEN

      SELECT NVL(fsp.purch_encumbrance_flag,'N'),
             ai.org_id
        INTO l_purch_encumbrance_flag,
             l_org_id
        FROM ap_invoices_all ai,
             financials_system_params_all fsp
       WHERE ai.invoice_id = p_invoice_id
         AND ai.org_id = fsp.org_id;

      IF (l_purch_encumbrance_flag = 'N') THEN
        RETURN(NULL);
      END IF;

      OPEN encumbrance_flag_cursor;
      LOOP
      FETCH encumbrance_flag_cursor INTO l_encumbered_flag;
      EXIT WHEN encumbrance_flag_cursor%NOTFOUND;
        IF (l_encumbered_flag in ('Y','D', 'W','X')) THEN
          l_encumbered_count := l_encumbered_count + 1;
        END IF;
          l_distribution_count := l_distribution_count + 1;
      END LOOP;

      IF (l_encumbered_count > 0) THEN
        -- At least one distribution is encumbered
        IF (l_distribution_count = l_encumbered_count) THEN
          -- Invoice Line is fully encumbered
          RETURN('Y');
        ELSE
          -- Invoice Line is partially encumbered
          RETURN('P');
        END IF;
      ELSE
        -- No distributions are encumbered
        RETURN('N');
      END IF;

     ELSE

        RETURN(NULL);

     END IF; -- Bug 8763038

     END get_encumbered_flag;


/*=============================================================================
 |  FUNCTION -  get_posting_status
 |
 |  DESCRIPTION
 |      returns the invoice line posting status.
 |
 |  PARAMETER
 |      p_invoice_id - invoice id
 |      p_line_number - invoice line number
 |
 |  NOTES
 |      'Y' - Posted
 |      'S' - Selected
 |      'P' - Partial
 |      'N' - Unposted
 |      ---------------------------------------------------------------------
 |      -- Declare cursor to establish the invoice-level posting flag
 |      --
 |      -- The first two selects simply look at the posting flags (cash and/or
 |      -- accrual) for the distributions.  The rest is to cover one specific
 |      -- case when some of the distributions are fully posting (Y) and some
 |      -- are unposting (N).  The status should be partial (P).
 |      --
 |      -- MOAC.  Use ap_invoice_distributions_all table instead of SO view
 |      -- since this procedure is called when policy context is not set to
 |      -- the corresponding OU for the invoice_id
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  28-MAY-04    yicao              SLA Obsolescence: Remove some accounting
 |                                  related options
 *============================================================================*/
   FUNCTION get_posting_status(
                 p_invoice_id   IN NUMBER,
                 p_line_number  IN NUMBER )
    RETURN VARCHAR2
    IS

      invoice_line_posting_flag           VARCHAR2(1);
      distribution_posting_flag           VARCHAR2(1);
      l_cash_basis_flag                   VARCHAR2(1);
      l_org_id                            AP_SYSTEM_PARAMETERS_ALL.ORG_ID%TYPE;


      CURSOR posting_cursor IS
      SELECT cash_posted_flag
      FROM   ap_invoice_distributions_all
      WHERE  invoice_id = p_invoice_id
      AND    invoice_line_number = p_line_number
      AND    l_cash_basis_flag = 'Y'
      UNION
      SELECT accrual_posted_flag
      FROM   ap_invoice_distributions_all
      WHERE  invoice_id = p_invoice_id
      AND    invoice_line_number = p_line_number
      AND    l_cash_basis_flag <> 'Y'
      UNION
      SELECT 'P'
      FROM   ap_invoice_distributions_all
      WHERE  invoice_id = p_invoice_id
      AND    invoice_line_number = p_line_number
      AND    ( (cash_posted_flag  = 'Y'
                AND l_cash_basis_flag = 'Y')
              OR
                (accrual_posted_flag = 'Y'
                 AND l_cash_basis_flag <> 'Y'))
      AND EXISTS
               (SELECT 'An N is also in the valid flags'
                FROM   ap_invoice_distributions_all
                WHERE  invoice_id = p_invoice_id
                AND    invoice_line_number = p_line_number
                AND    ((cash_posted_flag  = 'N'
                         AND l_cash_basis_flag = 'Y')
                OR
                       (accrual_posted_flag  = 'N'
                         AND l_cash_basis_flag <> 'Y')));

    BEGIN

    /*-----------------------------------------------------------------+
    |  Get Accounting Methods from gl_sets_of_books                    |
    |      l_cash_basis_flag: 'Y' --cash basis                         |
    |                         'N' --accrual basis                      |
    |  MOAC.  Added org_id to select statement.                        |
    +-----------------------------------------------------------------*/

      SELECT nvl(sob.sla_ledger_cash_basis_flag, 'N'),
             asp.org_id
      INTO l_cash_basis_flag,
           l_org_id
      FROM ap_invoices_all ai,
           ap_system_parameters_all asp,
           gl_sets_of_books sob
      WHERE ai.invoice_id = p_invoice_id
      AND ai.org_id = asp.org_id
      AND asp.set_of_books_id = sob.set_of_books_id;

      invoice_line_posting_flag := 'X';

      OPEN posting_cursor;

      LOOP
      FETCH posting_cursor INTO distribution_posting_flag;
      EXIT WHEN posting_cursor%NOTFOUND;

        IF (distribution_posting_flag = 'S') THEN
          invoice_line_posting_flag := 'S';
        ELSIF (distribution_posting_flag = 'P' AND
               invoice_line_posting_flag <> 'S') THEN
          invoice_line_posting_flag := 'P';
        ELSIF (distribution_posting_flag = 'N' AND
               invoice_line_posting_flag NOT IN ('S','P')) THEN
          invoice_line_posting_flag := 'N';
        ELSIF (invoice_line_posting_flag NOT IN ('S','P','N')) THEN
          invoice_line_posting_flag := 'Y';
        END IF;
      END LOOP;
      CLOSE posting_cursor;

      if (invoice_line_posting_flag = 'X') then
        invoice_line_posting_flag := 'N';
      end if;

      RETURN(invoice_line_posting_flag);
    END get_posting_status;

/*============================================================================
 |  FUNCTION - get_approval_status
 |
 |  DESCRIPTION
 |      returns the invoice line level approval status lookup code.
 |
 |  PARAMETERS
 |      p_invoice_id - invoice id
 |      p_line_number - invoice line number
 |
 |
 |  NOTES
 |      Invoices Line  -'APPROVED'
 |                      'NEEDS REAPPROVAL'
 |                      'NEVER APPROVED'
 |                      'CANCELLED'
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_approval_status(
                 p_invoice_id               IN NUMBER,
                 p_line_number              IN NUMBER)
    RETURN VARCHAR2
    IS

      invoice_line_approval_status    VARCHAR2(25);
      invoice_line_approval_flag      VARCHAR2(1);
      distribution_approval_flag      VARCHAR2(1);
      encumbrance_flag                VARCHAR2(1);
      invoice_holds                   NUMBER;
      sum_distributions               NUMBER;
      dist_var_hold                   NUMBER;
      match_flag_cnt                  NUMBER;
      l_cancelled_count               NUMBER;
      l_discarded_count               NUMBER;
      l_org_id                        FINANCIALS_SYSTEM_PARAMS_ALL.ORG_ID%TYPE;
      ---------------------------------------------------------------------
      -- Declare cursor to establish the invoice-level approval flag
      --
      -- The first select simply looks at the match status flag for the
      -- distributions.  The rest is to cover one specific case when some
      -- of the distributions are tested (T or A) and some are untested
      -- (NULL).  The status should be needs reapproval (N).
      --
      CURSOR approval_cursor IS
      SELECT nvl(match_status_flag, 'N')
      FROM   ap_invoice_distributions_all
      WHERE  invoice_id = p_invoice_id
      AND    invoice_line_number =  p_line_number;

    BEGIN

         ---------------------------------------------------------------------
         -- Get the encumbrance flag
         -- MOAC.  Included select from ap_invoices_all to get the org_id from
         --        the invoice_id since it is unique

      SELECT NVL(fsp.purch_encumbrance_flag,'N'), ai.org_id
      INTO encumbrance_flag, l_org_id
      FROM ap_invoices_all ai,
           financials_system_params_all fsp
      WHERE ai.invoice_id = p_invoice_id
      AND ai.org_id = fsp.org_id;

         ---------------------------------------------------------------------
         -- Get the number of holds for the invoice
         --
      SELECT count(*)
      INTO   invoice_holds
      FROM   ap_holds_all
      WHERE  invoice_id = p_invoice_id
      AND    release_lookup_code is NULL;

         ---------------------------------------------------------------------
         -- Check if DIST VAR hold is placed on this invoice.
         -- DIST VAR is a special case because it could be placed
         -- when no distributions exist and in this case, the invoice
         -- status should be NEEDS REAPPROVAL.
         --
      SELECT count(*)
      INTO   dist_var_hold
      FROM   ap_holds_all
      WHERE  invoice_id = p_invoice_id
      AND    hold_lookup_code = 'DIST VARIANCE'
      AND    release_lookup_code is NULL;

         ---------------------------------------------------------------------
         -- If invoice is cancelled, return 'CANCELLED'.
         --
      SELECT count(*)
      INTO   l_cancelled_count
      FROM   ap_invoice_lines
      WHERE  invoice_id = p_invoice_id
        AND  line_number = p_line_number
        AND  NVL(cancelled_flag, 'N' ) = 'Y';

      IF ( l_cancelled_count > 0 ) THEN
        RETURN('CANCELLED');
      END IF;

         ---------------------------------------------------------------------
         -- Getting the count of distributions with
         -- match_status_flag not null. We will open the approval_cursor
         -- only if the count is more than 0.
         --
      SELECT count(*)
      INTO match_flag_cnt
      FROM ap_invoice_distributions_all aid
      WHERE aid.invoice_id = p_invoice_id
      AND aid.invoice_line_number = p_line_number
      AND aid.match_status_flag IS NOT NULL
      AND rownum < 2;

         ---------------------------------------------------------------------
         -- Establish the invoice line level approval flag
         --
         -- Use the following ordering sequence to determine the invoice-level
         -- approval flag:
         --                     'N' - Needs Reapproval
         --                     'T' - Tested
         --                     'A' - Approved
         --                     NULL  - Never Approved
         --                     'X' - No Distributions Exist
         --
         -- Initialize invoice line level approval flag
         --
      invoice_line_approval_flag := 'X';

      IF match_flag_cnt > 0 THEN

        OPEN approval_cursor;

        LOOP
        FETCH approval_cursor INTO distribution_approval_flag;
        EXIT WHEN approval_cursor%NOTFOUND;

          IF (distribution_approval_flag IS NULL) THEN
            invoice_line_approval_flag := NULL;
          ELSIF (distribution_approval_flag = 'N') THEN
            invoice_line_approval_flag := 'N';
          ELSIF (distribution_approval_flag = 'T' AND
                 (invoice_line_approval_flag <> 'N' or
                  invoice_line_approval_flag is null)) THEN
            invoice_line_approval_flag := 'T';
          ELSIF (distribution_approval_flag = 'A' AND
                 (invoice_line_approval_flag NOT IN ('N','T')
                  or invoice_line_approval_flag is null)) THEN
            invoice_line_approval_flag := 'A';
          END IF;

        END LOOP;

        CLOSE approval_cursor;
      END IF; -- end of match_flag_cnt


         ---------------------------------------------------------------------
         -- Derive the translated approval status from the approval flag
         --
      IF (encumbrance_flag = 'Y') THEN

        IF (invoice_line_approval_flag = 'A' AND invoice_holds = 0) THEN
          invoice_line_approval_status := 'APPROVED';
        ELSIF ((invoice_line_approval_flag in ('A') AND invoice_holds > 0)
               OR (invoice_line_approval_flag IN ('T','N'))) THEN
          invoice_line_approval_status := 'NEEDS REAPPROVAL';
        ELSIF (dist_var_hold >= 1) THEN
                 --It's assumed here that the user won't place this hold
                 --manually before approving.  If he does, status will be
                 --NEEDS REAPPROVAL.  dist_var_hold can result when there
                 --are no distributions or there are but amounts don't
                 --match.  It can also happen when an invoice is created with
                 --no distributions, then approve the invoice, then create the
                 --distribution.  So, in this case, although the match flag
                 --is null, we still want to see the status as NEEDS REAPPR.
          invoice_line_approval_status := 'NEEDS REAPPROVAL';
        ELSIF (invoice_line_approval_flag is null
                OR (invoice_line_approval_flag = 'X' AND dist_var_hold = 0 )) THEN
		--Bug8414549: Undoing changes for bug8340784
		--AND invoice_holds = 0)) THEN  --Bug8340784
		--Added invoice_holds = 0 to above condition
          invoice_line_approval_status := 'NEVER APPROVED';
        END IF;

      ELSIF (encumbrance_flag = 'N') THEN
        IF (invoice_line_approval_flag IN ('A','T') AND invoice_holds = 0) THEN
          invoice_line_approval_status := 'APPROVED';
        ELSIF ((invoice_line_approval_flag IN ('A','T') AND invoice_holds > 0)
                OR
               (invoice_line_approval_flag = 'N')) THEN
          invoice_line_approval_status := 'NEEDS REAPPROVAL';
        ELSIF (dist_var_hold >= 1) THEN
          invoice_line_approval_status := 'NEEDS REAPPROVAL';
        ELSIF (invoice_line_approval_flag is null
               OR (invoice_line_approval_flag = 'X' AND dist_var_hold = 0
			   AND invoice_holds = 0)) THEN  --Bug8340784
				 --Added invoice_holds = 0 to above condition
                 -- A NULL flag indicate that APPROVAL has not
                 -- been run for this invoice, therefore, even if manual
                 -- holds exist, status should be NEVER APPROVED.
          invoice_line_approval_status := 'NEVER APPROVED';
        END IF;
      END IF;

      RETURN(invoice_line_approval_status);
    END get_approval_status;

/*=============================================================================
 |  Public PROCEDURE Is_Line_Discardable
 |
 |      Check if the line is discardable
 |
 |  PROGRAM FLOW
 |
 |      1. return FALSE - if discard flag is Y
 |      2. return FALSE - if line contains distribution that does not have
 |                        an OPEN reversal period name.
 |      3. return FALSE - if line contain distributions which are PO/RCV
 |                        matched whose reversal causes amount/qty billed less
 |                        than 0
 |      4. return FALSE - if line is final match
 |      5. return FALSE - if line is referenced by an active correction
 |      6. return FALSE - if line contains distributions witn invalid account
 |      7. return FALSE - if line contains distributions refereced by active
 |                        distributions which are not cancelled or reversed
 |                        apply to FREIGHT/MISC allocated to Item Line
 |      8. return FALSE - if line with outstanding allocation rule
 |      9. return FALSE - if line is AWT line linked to AWT invoice
 |     10. return FALSE - if prepayment line has been applied (same as Note 1)
 |     14. return FALSE - if invoice is selected for payment
 |
 |  NOTES
 |
 |     1. If line is the prepay application/unapplication - we handle the
 |        business rule on-line. Means from UI we will make sure that one
 |        PREPAY type line can not be discarded unless it is being fully
 |        unapplied.
 |
 |  MODIFICATION HISTORY
 |  Date         Author               Description of Change
 |  03/07/03     sfeng                Created
 |
 *============================================================================*/

  Function Is_Line_Discardable(
               P_line_rec          IN  ap_invoice_lines%ROWTYPE,
               P_error_code            OUT NOCOPY VARCHAR2,
               P_calling_sequence  IN             VARCHAR2) RETURN BOOLEAN

  IS

    l_po_dist_count              NUMBER := 0;
    l_rcv_dist_count             NUMBER := 0; --Bug5000472
    l_reference_count            NUMBER := 0;
    l_active_count               NUMBER := 0;
    l_quick_credit_count         NUMBER := 0;
    l_quick_credit_ref_count     NUMBER := 0;
    l_invalid_acct_count         NUMBER := 0;
    l_final_close_count          NUMBER := 0;
    l_pending_count              NUMBER := 0;
    l_count                      NUMBER := 0;

    l_debug_info                 VARCHAR2(240);
    l_curr_calling_sequence      VARCHAR2(2000);

    TYPE date_tab is TABLE OF DATE INDEX BY BINARY_INTEGER;
    l_gl_date_list               date_tab;
    i                            BINARY_INTEGER := 1;
    l_open_gl_date               DATE :='';
    l_open_period                gl_period_statuses.period_name%TYPE := '';

    l_prepay_amount_applied      NUMBER := 0;
    l_enc_enabled                VARCHAR2(1);    --bug6009101
    l_po_not_approved            VARCHAR2(1);    --bug6009101
    l_org_id  ap_invoices_all.org_id%type;      -- for bug 5936290
    CURSOR dist_gl_date_Cur IS
    SELECT accounting_date
      FROM ap_invoice_distributions AID
     WHERE AID.invoice_id = p_line_rec.invoice_id
       AND AID.invoice_line_number = p_line_rec.line_number
       AND NVL(AID.reversal_flag, 'N') <> 'Y';


  BEGIN

    l_curr_calling_sequence := 'AP_INVOICE_LINE_PKG.IS_Line_Discardable<-' ||
                               P_calling_sequence;

    /*-----------------------------------------------------------------+
     |  Step 0 - If line is discarded, return FALSE                    |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Check if line is already discarded';

    IF ( NVL(p_line_rec.discarded_flag, 'N') = 'Y' ) THEN
      p_error_code := 'AP_INV_LINE_ALREADY_DISCARDED';
      RETURN FALSE;
    END IF;

    /*-----------------------------------------------------------------+
     |  Step 1 - If line is CANCELLED, can not be discarded, return    |
     |           FALSE                                                 |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Check if line is already cancelled';

    IF ( NVL(p_line_rec.cancelled_flag, 'N') = 'Y' ) THEN
      p_error_code := 'AP_INV_CANCELLED';
      RETURN FALSE;
    END IF;

    /*-----------------------------------------------------------------+
     |  Step 2 - If line contains distribution which has no open       |
     |           period, can not be discarded, return FALSE            |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Check if distribution in this line has open period';

    OPEN dist_gl_date_Cur;
    FETCH dist_gl_date_Cur
    BULK COLLECT INTO l_gl_date_list;
    CLOSE dist_gl_date_Cur;

  -- For bug 5936290
  --  we call ap_utilities_pkg.get_current_gl_date
  --  and in ap_utilities_pkg.get_open_gl_date for getting the gl date and
  --  period below.For both these procedures one parameter is org_id
  --  and it's default value is mo_global.get_current_org_id.we do
  --  were not passing the org_id in these procedures calls so
  --  the org_id was getting picked up from mo_global.get_current_org_id
  --  and it's coming null when the Invoice batch option is ON.
  --  So now we are passing the org_id also in these two calls.

    SELECT org_id
    INTO   l_org_id
    FROM   ap_invoices_all
    WHERE  invoice_id = p_line_rec.invoice_id;

    FOR i in NVL(l_gl_date_list.FIRST,0)..NVL(l_gl_date_list.LAST,-1)
    LOOP
      l_open_period := ap_utilities_pkg.get_current_gl_date(l_gl_date_list(i),l_org_id); --added for bug 5936290

      IF ( l_open_period IS NULL ) THEN
        ap_utilities_pkg.get_open_gl_date(
                 l_gl_date_list(i),
                 l_open_period,
                 l_open_gl_date,
                 l_org_id); --added for bug 5936290
        IF ( l_open_period IS NULL ) THEN
          p_error_code := 'AP_DISCARD_NO_FUTURE_PERIODS';
          RETURN FALSE;
        END IF;
      END IF;
    END LOOP;

    /*-----------------------------------------------------------------+
     |  Step 3. if the quantity billed and amount on PO would be       |
     |          reduced to less than zero then return FALSE            |
     |          Always allow Reversal distributions to be cancelled    |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Check if quantity_billed on po_distribution is '
                    || 'would be reduced to < 0';
    --Bug5000472 added condition on po distribution id and rcv_transaction_id
    --and commented GROUP BY in sub queries

    -- Modified the below select statment for the bug #6913924 to consider the
    -- case when prepayment invoice matched to a PO and receipt and with
     --different UOM for PO and receipt.

    BEGIN
    SELECT count(*)
    INTO   l_po_dist_count
    FROM   po_distributions_all POD,
           ap_invoice_distributions AID,
           ap_invoices ai,
           po_line_locations PLL,
           po_lines PL
    WHERE  POD.po_distribution_id = AID.po_distribution_id
    AND    POD.line_location_id = PLL.line_location_id
    AND    PLL.po_line_id = PL.po_line_id
    AND    AID.invoice_id = ai.invoice_id
    AND    AID.invoice_id = p_line_rec.invoice_id
    AND    POD.org_id = AID.org_id
    AND    AID.invoice_line_number = p_line_rec.line_number
    AND    NVL(AID.reversal_flag,'N')<>'Y'
    AND    aid.rcv_transaction_id is null  --Bug5000472
    HAVING (
            (DECODE(ai.invoice_type_lookup_code,'PREPAYMENT',
               SUM(NVL(POD.quantity_financed, 0)),
	           SUM(NVL(POD.quantity_billed, 0)))
                -
                SUM(round(decode(AID.dist_match_type,
                                'PRICE_CORRECTION', 0,
                                'AMOUNT_CORRECTION', 0,
                                 'ITEM_TO_SERVICE_PO', 0,
                                 'ITEM_TO_SERVICE_RECEIPT', 0,
                                  nvl( AID.quantity_invoiced, 0 ) +
                                  nvl( AID.corrected_quantity,0 )
               ) *
                     po_uom_s.po_uom_convert(AID.matched_uom_lookup_code,
                                   nvl(PLL.unit_meas_lookup_code,
                     PL.unit_meas_lookup_code),
                 PL.item_id), 15))
              < 0)
               OR (DECODE(ai.invoice_type_lookup_code,'PREPAYMENT',
                  SUM(NVL(POD.amount_financed, 0)),
		     SUM(NVL(POD.amount_billed, 0))) -
                  SUM(NVL(AID.amount, 0)) < 0 ))
       GROUP BY ai.invoice_type_lookup_code,AID.po_distribution_id;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_po_dist_count := 0;
    END;
      -- end of changes for bug #6913924

    IF (l_po_dist_count > 0  ) THEN
      P_error_code := 'AP_INV_LINE_QTY_BILLED_NOT_NEG';
      RETURN FALSE;
    END IF;

--Bug5000472  Added the following block of code
    /*-----------------------------------------------------------------+
     |  Step 3.1. if the quantity billed and amount on RCV would be    |
     |          reduced to less than zero then return FALSE            |
     |          Always allow Reversal distributions to be cancelled    |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Check if quantity_billed on rcv_transactions '
                    || 'would be reduced to < 0';

    SELECT count(*)
    INTO   l_rcv_dist_count
    FROM   rcv_transactions RT,
           ap_invoice_distributions_all AID
    WHERE  RT.transaction_id = AID.rcv_transaction_id
    AND    AID.invoice_id = p_line_rec.invoice_id
    AND    AID.invoice_line_number = p_line_rec.line_number
    AND    AID.rcv_transaction_id is not null
    AND    NVL(AID.reversal_flag,'N')<>'Y'
    AND    (NVL(rt.quantity_billed,0) <
               (SELECT SUM(decode( AID1.dist_match_type,
                                  'PRICE_CORRECTION', 0,
                                  'AMOUNT_CORRECTION', 0,
                                  'ITEM_TO_SERVICE_PO', 0,
                                  'ITEM_TO_SERVICE_RECEIPT', 0,
                                   nvl( AID1.corrected_quantity,0 ) +
                                   nvl( AID1.quantity_invoiced,0 )
                                                        )
                                                    )
                 FROM ap_invoice_distributions_all aid1
                WHERE aid1.invoice_id = aid.invoice_id
                  AND aid1.invoice_line_number = aid.invoice_line_number
                  AND aid1.rcv_transaction_id=aid.rcv_transaction_id
                       )
             OR
             NVL(rt.amount_billed,0) <  (
                       SELECT SUM(NVL(AID2.amount,0))
                         FROM ap_invoice_distributions_all aid2
                        WHERE aid2.invoice_id = aid.invoice_id
                         AND aid2.invoice_line_number = aid.invoice_line_number
                         AND aid2.rcv_transaction_id=aid.rcv_transaction_id
                          )
             );

    IF (l_rcv_dist_count > 0  ) THEN
      P_error_code := 'AP_INV_LINE_QTY_BILLED_NOT_NEG';
      RETURN FALSE;
    END IF;
--Bug5000472 End

    /*-----------------------------------------------------------------+
     |  Step 4. If invoice is matched to a Finally Closed PO, return   |
     |          FALSE                                                  |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Check if invoice line is matched to a finally'
                    ||'  closed PO shipment';

    SELECT count(*)
    INTO   l_final_close_count
    FROM   ap_invoice_lines AIL,
           po_line_locations PLL
    WHERE  AIL.invoice_id = p_line_rec.invoice_id
    AND    AIL.line_number = p_line_rec.line_number
    AND    AIL.po_line_location_id = PLL.line_location_id
    AND    PLL.closed_code = 'FINALLY CLOSED';

    IF (l_final_close_count > 0) THEN
      P_error_code := 'AP_INV_LINE_PO_FINALLY_CLOSED';
      RETURN FALSE;
    END IF;

    /*-----------------------------------------------------------------+
     |  Step 4.1 If the encumbrance is on and the invoice is matched to
     |           to an unapproved PO, then do not allow discard.(bug6009101)
     +-----------------------------------------------------------------*/

      SELECT NVL(purch_encumbrance_flag,'N')
      INTO   l_enc_enabled
      FROM   financials_system_params_all FSP,
             ap_invoices_all              AI
      WHERE  AI.invoice_id  =  p_line_rec.invoice_id
      AND    FSP.org_id     =  AI.org_id;

    if l_enc_enabled  = 'Y' then

       begin

          select 'Y'
          into   l_po_not_approved
          from   po_headers POH
          where POH.po_header_id = p_line_rec.po_header_id
          and   POH.approved_flag <> 'Y';    --bug6653070

          EXCEPTION
             WHEN OTHERS THEN
                  NULL;

       end;

       if l_po_not_approved = 'Y' then
          p_error_code := 'AP_PO_UNRES_CANT_DISC_LINE';
          return FALSE;
       end if;
   end if;


    /*-----------------------------------------------------------------+
     |  Step 5. If invoice is a quick credit, it can be cancelled at   |
     |          at header level. can not discard individual line. so   |
     |          return FALSE;                                          |
     +-----------------------------------------------------------------*/
    l_debug_info := 'Check if this invoice is a quick credit';

    SELECT count(*)
      INTO l_quick_credit_count
      FROM ap_invoices AI
     WHERE AI.invoice_id = p_line_rec.invoice_id
       AND NVL(AI.quick_credit, 'N') = 'Y';

    IF ( l_quick_credit_count > 0  ) THEN
      P_error_code := 'AP_INV_IS_QUICK_CREDIT';
      RETURN FALSE;
    END IF;

    /*-----------------------------------------------------------------+
     |  Step 6. Check If invoice line is actively referenced           |
     |         If invoice line reference by an active                  |
     |                  correction, return FALSE                       |
     +-----------------------------------------------------------------*/
    l_debug_info := 'Check if this line is refrenced by a correction';

    SELECT count(*)
      INTO l_active_count
      FROM ap_invoice_lines AIL
     WHERE NVL( AIL.discarded_flag, 'N' ) <> 'Y'
       AND NVL( AIL.cancelled_flag, 'N' ) <> 'Y'
       AND AIL.corrected_inv_id = p_line_rec.invoice_id
       AND AIL.corrected_line_number = p_line_rec.line_number;

    IF ( l_active_count > 0) THEN
      P_error_code := 'AP_INV_LINE_REF_BY_CORRECTION';
      RETURN FALSE;
    END IF;

    /*-----------------------------------------------------------------+
     |  Step 7. Check If invoice line is actively referenced           |
     |          If one active quick credit is referencing this         |
     |          invoice, return FALSE                                  |
     +-----------------------------------------------------------------*/
    l_debug_info := 'Check if this line is a refreced by a quick credit';

    -- Bug 5261908. Added rownum condition to improve performance
    BEGIN
    --bug 5475668 Added the if condition.
    --bug 8208823 Added condition for line_type_lookup_code
    if (p_line_rec.invoice_id is not NULL
	AND p_line_rec.line_type_lookup_code <> 'PREPAY') then
      SELECT 1
        INTO l_quick_credit_ref_count
        FROM ap_invoices AI
       WHERE AI.credited_invoice_id = p_line_rec.invoice_id
         AND NVL(AI.quick_credit, 'N') = 'Y'
         AND AI.cancelled_date is null
         AND Rownum = 1;
    end if;
    EXCEPTION
      WHEN no_data_found THEN
           NULL;
    END;

    IF (l_quick_credit_ref_count > 0  ) THEN
      P_error_code := 'AP_INV_LINE_REF_BY_QCK_CREDIT';
      RETURN FALSE;
    END IF;


    /*-----------------------------------------------------------------+
     |  Step 8. If line contain distributions which has invalid account |
     |          return FALSE                                            |
     +-----------------------------------------------------------------*/

    SELECT  count(*)
    INTO    l_invalid_acct_count
    FROM    ap_invoice_distributions D
    WHERE   D.invoice_id = p_line_rec.invoice_id
    AND     D.invoice_line_number = p_line_rec.line_number
    AND     D.posted_flag IN ('N', 'P')
    AND ((EXISTS (select 'x'
                  from gl_code_combinations C
                  where D.dist_code_combination_id = C.code_combination_id (+)
                  and (C.code_combination_id is null
                     or C.detail_posting_allowed_flag = 'N'
                     or C.start_date_active > D.accounting_date
                     or C.end_date_active < D.accounting_date
                     or C.template_id is not null
                     or C.enabled_flag <> 'Y'
                     or C.summary_flag <> 'N'
                     )))
    OR (D.dist_code_combination_id = -1));

    IF (l_invalid_acct_count <> 0) THEN

      P_error_code := 'AP_INV_LINE_INVALID_DIST_ACCT';
      RETURN FALSE;
    END IF;

    /*-----------------------------------------------------------------+
     |  Step 9. If line contain distributions referenced by active     |
     |          distributions, return FALSE. This applies to all the   |
     |          non-charge lines which have active charges lines       |
     |          allocated to themselves. In case that a charge         |
     |          distribution's parent line is not a charge line but    |
     |          and ITEM/ACCRUAL line, we should allow line to be      |
     |          discarded                                              |
     +-----------------------------------------------------------------*/
-- Bug 5114543
-- Commented the following check to allow discard of item line
-- when it has allocated charges.
-- Bug 5386077. Recommenting again. Was checked incorrectly via bug 5000472 (120.20)

/*
    SELECT  count(*)
    INTO    l_reference_count
    FROM    ap_invoice_distributions AID
    WHERE   NVL(AID.cancellation_flag, 'N') <> 'Y'
    AND     NVL(AID.reversal_flag, 'N') <> 'Y'
    AND     AID.invoice_id = p_line_rec.invoice_id
    AND     AID.invoice_line_number <> p_line_rec.line_number
    AND     AID.charge_applicable_to_dist_id IS NOT NULL
    AND     AID.charge_applicable_to_dist_id IN
            ( SELECT AID2.invoice_distribution_id
                FROM ap_invoice_distributions AID2
               WHERE AID2.invoice_id = p_line_rec.invoice_id
                 AND AID2.invoice_line_number = p_line_rec.line_number
                 AND NVL(AID2.cancellation_flag, 'N') <> 'Y'
                 AND NVL(AID2.reversal_flag, 'N') <> 'Y' );

    IF ( l_reference_count <> 0) THEN
      P_error_code := 'AP_INV_LINE_ACTIVE_DIST';
      RETURN FALSE;
    END IF;
*/
    /*------------------------------------------------------------------+
     |  Step 10. If this non-charge line contain active allocation rule |
     |           which is not yet applied, return FALSE                 |
     +------------------------------------------------------------------*/
-- Bug 5114543
-- Commented the following check to allow discard of item line
-- when it has allocated charges.
-- Bug 5386077. Recommenting again. Was checked incorrectly via bug 5000472 (120.20).
/*
    SELECT  count(*)
    INTO    l_pending_count
    FROM    ap_allocation_rules  AR,
            ap_allocation_rule_lines ARL
    WHERE   AR.invoice_id = p_line_rec.invoice_id
    AND     AR.invoice_id = ARL.invoice_id
    AND     AR.chrg_invoice_line_number = ARL.chrg_invoice_line_number
    AND     ARL.to_invoice_line_number = p_line_rec.line_number
    AND     AR.status = 'PENDING';

    IF ( l_pending_count <> 0) THEN
      P_error_code := 'AP_INV_LINE_HAS_ALLOC_RULE';
      RETURN FALSE;
    END IF;
 */
    /*-----------------------------------------------------------------+
     |  Step 11. If line is Automatic AWT line which invoice is fully  |
     |          or partially paid, return FALSE                        |
     +-----------------------------------------------------------------*/

    SELECT  count(*)
    INTO    l_count
    FROM    ap_invoice_lines AIL,
            ap_invoices AI
    WHERE   AIL.invoice_id = P_line_rec.invoice_id
    AND     AIL.line_number = P_line_rec.line_number
    AND     AIL.line_type_lookup_code  = 'AWT'
    AND     NOT EXISTS ( SELECT invoice_distribution_id
                           FROM ap_invoice_distributions aid
                          WHERE aid.invoice_id = AIL.invoice_id
                            AND aid.invoice_line_number = AIL.line_number
                            AND awt_flag = 'M' )
    AND     AI.invoice_id = AIL.invoice_id
    AND     AI.payment_status_flag in ('P', 'Y');

    IF ( l_count <> 0) THEN
      P_error_code := 'AP_INV_LINE_IS_AWT';
      RETURN FALSE;
    END IF;

    /*--------------------------------------------------------------------+
     |  Step 12. If line has some or entire retained amount
     |           released, return FALSE
     +--------------------------------------------------------------------*/

     SELECT count(*)
       INTO l_count
       FROM ap_invoice_lines AIL
      WHERE AIL.invoice_id  = P_line_rec.invoice_id
	AND AIL.line_number = P_line_rec.line_number
	AND (ail.retained_amount           IS NOT NULL AND
	     ail.retained_amount_remaining IS NOT NULL AND
             abs(ail.retained_amount) <> abs(ail.retained_amount_remaining));

     IF ( l_count <> 0) THEN
         P_error_code := 'AP_INV_LINE_RELEASED';
         RETURN FALSE;
     END IF;

    /*-----------------------------------------------------------------+
     |  Step 13. Prepayment line cannot be discarded after prepayment  |
     |           is applied.  If so, return FALSE (Bug #5114854)       |
     +-----------------------------------------------------------------*/
    SELECT count(*)
      INTO l_count
      FROM ap_invoices_all ai
     WHERE invoice_id = p_line_rec.invoice_id
       AND invoice_type_lookup_code = 'PREPAYMENT';

    IF ( l_count > 0 ) THEN

      l_prepay_amount_applied :=
         ap_invoices_pkg.get_prepay_amount_applied(p_line_rec.invoice_id);

      if (l_prepay_amount_applied <> 0) then
         p_error_code := 'AP_INV_DEL_APPLIED_PREPAY';
         RETURN FALSE;
      end if;
    END IF;
    /*-----------------------------------------------------------------+
     |  Step 14. invoice is select for payment and payment is not done |
     |           so, return FALSE (Bug #8366177)                       |
     +-----------------------------------------------------------------*/
      select  nvl(sum(amount_remaining),0)
      INTO l_count
      from ap_payment_schedules_all
      where invoice_id =p_line_rec.invoice_id
      and checkrun_id is not null
      and payment_status_flag <>'Y';
     IF ( l_count > 0 ) THEN
         p_error_code := 'AP_INV_SELECTED_INVOICE';
         RETURN FALSE;
      end if;

    P_error_code := null;
    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
             ' P_invoice_id = '     || p_line_rec.invoice_id
          ||' P_line_number = '     || p_line_rec.line_number );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      IF ( dist_gl_date_Cur%ISOPEN ) THEN
        CLOSE dist_gl_date_Cur;
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Is_Line_Discardable;

 /*=============================================================================
 |  Public FUNCTION Allocation_Exists
 |
 |      Check if the line has allocation rules and lines associated with it.
 |
 |  PROGRAM FLOW
 |
 |       return TRUE  - if allocation rules and lines exist
 |       return FALSE - otherwise.
 |
 |  MODIFICATION HISTORY
 |  Date         Author               Description of Change
 |  03/10/13     bghose               Created
 *============================================================================*/

  FUNCTION Allocation_Exists (p_Invoice_Id        Number,
                              p_Line_Number       Number,
                              p_Calling_Sequence  Varchar2) Return Boolean Is
    dummy number := 0;
    current_calling_sequence   Varchar2(2000);
    debug_info                 Varchar2(100);

  Begin
    -- Update the calling sequence
    --
    current_calling_sequence :=
        'AP_INVOICE_LINES_UTILITY_PKG.ALLOCATION_EXISTS<-'||p_Calling_Sequence;

    debug_info := 'Select from ap_allocation_rules';

    Select count(*)
    Into   dummy
    From   ap_allocation_rules  AR,
           ap_allocation_rule_lines ARL
    Where  AR.invoice_id = p_Invoice_Id
    And    AR.invoice_id = ARL.invoice_id
    And    AR.chrg_invoice_line_number = ARL.chrg_invoice_line_number
    And    ARL.to_invoice_line_number = p_line_number;

    If (dummy >= 1) Then
      return  TRUE;
    End If;

    return FALSE;

  Exception
    WHEN OTHERS THEN
      If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice Id = '||p_Invoice_id
                                     ||', line number = '|| p_Line_Number);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      End If;
      APP_EXCEPTION.RAISE_EXCEPTION;
  End Allocation_Exists;

 /*=============================================================================
 |  Public FUNCTION Inv_Reversed_Via_Qc
 |
 |      Check if the invoice has been reversed via Qucik Credit.
 |
 |  PROGRAM FLOW
 |
 |       return TRUE  - if reversed via Quick Credit
 |       return FALSE - otherwise.
 |
 |  MODIFICATION HISTORY
 |  Date         Author               Description of Change
 |  03/10/13     bghose               Created
 *=============================================================================*/

  Function Inv_Reversed_Via_Qc (p_Invoice_Id        Number,
                                p_Calling_Sequence  Varchar2)  Return Boolean Is
    dummy number := 0;
    current_calling_sequence   Varchar2(2000);
    debug_info                 Varchar2(100);

    Begin
    -- Update the calling sequence
    --
     current_calling_sequence :=
       'AP_INVOICE_LINES_UTILITY_PKG.Inv_Reverse_Via_Qc<-'||p_Calling_Sequence;

     debug_info := 'Select from ap_invoics_all';

     -- Bug 5261908. Added rownum condition to improve performance
     BEGIN
     --bug 5475668 Added the if condition
      if (p_invoice_id is not null) then
       Select 1
       Into   dummy
       From   ap_invoices_all AI
       Where AI.credited_invoice_id = p_Invoice_Id
       AND NVL(AI.quick_credit, 'N') = 'Y'
       AND AI.cancelled_date is null
       AND Rownum = 1;
      end if;
     EXCEPTION
       WHEN no_data_found THEN
            dummy := 0;
     END;

     If (dummy >= 1) Then
       return  TRUE;
     End if;

     return FALSE;

   Exception
    WHEN OTHERS THEN
      If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice Id = '||p_Invoice_id);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      End If;
      APP_EXCEPTION.RAISE_EXCEPTION;
  End Inv_Reversed_Via_Qc;

 /*=============================================================================
 |  Public FUNCTION Is_Line_Dists_Trans_FA
 |
 |      Check if the line has associated distributions which has transfered to
 |      FA.
 |
 |  PROGRAM FLOW
 |
 |       return TRUE  - ifdistributions transferred to FA
 |       return FALSE - otherwise.
 |
 |  MODIFICATION HISTORY
 |  Date         Author               Description of Change
 |  03/10/13     bghose               Created
 *============================================================================*/
  FUNCTION Is_Line_Dists_Trans_FA (p_Invoice_Id        Number,
                              p_Line_Number       Number,
                              p_Calling_Sequence  Varchar2) Return Boolean Is
    dummy number := 0;
    current_calling_sequence   Varchar2(2000);
    debug_info                 Varchar2(100);

  Begin
    -- Update the calling sequence
    --
    current_calling_sequence :=
        'AP_INVOICE_LINES_UTILITY_PKG.IS_LINE_DISTS_TRANS_FA<-'
                      ||p_Calling_Sequence;

    debug_info := 'Select from ap_invoice_distributions_all';

    Select count(*)
    Into   dummy
    From   ap_invoice_distributions_all
    Where invoice_id = p_Invoice_Id
    And invoice_line_number = p_Line_Number
    And assets_addition_flag = 'Y';

    If (dummy >= 1) Then
      return  TRUE;
    End if;

    return FALSE;

  Exception
    WHEN OTHERS THEN
      If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice Id = '||p_Invoice_id
                              ||', line number = '|| p_Line_Number);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      End If;
      APP_EXCEPTION.RAISE_EXCEPTION;
  End Is_Line_Dists_Trans_FA;

 /*=============================================================================
 |  Public FUNCTION Line_Dists_Acct_Event_Created
 |
 |      Check if the line has associated distributions accounting event created
 |
 |  PROGRAM FLOW
 |
 |       return TRUE  - if distributions accounting event created
 |       return FALSE - otherwise.
 |
 |  MODIFICATION HISTORY
 |  Date         Author               Description of Change
 |  03/10/13     bghose               Created
 *============================================================================*/

  FUNCTION Line_Dists_Acct_Event_Created (p_Invoice_Id        Number,
                               p_Line_Number       Number,
                               p_Calling_Sequence  Varchar2) Return Boolean Is
    dummy number := 0;
    current_calling_sequence   Varchar2(2000);
    debug_info                 Varchar2(100);

  Begin
    -- Update the calling sequence
    --
    current_calling_sequence :=
        'AP_INVOICE_LINES_UTILITY_PKG.LINE_DISTS_ACCT_EVENT_CREATED<-'
                      ||p_Calling_Sequence;

    debug_info := 'Select from ap_invoice_distributions_all';

    Select count(*)
    Into   dummy
    From   ap_invoice_distributions_all
    Where invoice_id = p_Invoice_Id
    And invoice_line_number = p_Line_Number
    And accounting_event_id Is Not Null;

    If (dummy >= 1) Then
      return  TRUE;
    End if;

    return FALSE;

  Exception
    WHEN OTHERS THEN
      If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice Id = '||p_Invoice_id
                              ||', line number = '|| p_Line_Number);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      End If;
      APP_EXCEPTION.RAISE_EXCEPTION;
  End Line_Dists_Acct_Event_Created;

 /*=============================================================================
 |  Public FUNCTION Line_Referred_By_Corr
 |
 |      Check if the line has been referred by any correction
 |
 |  PROGRAM FLOW
 |
 |       return TRUE  - if line has been referred by any correction
 |       return FALSE - otherwise.
 |
 |  MODIFICATION HISTORY
 |  Date         Author               Description of Change
 |  03/10/13     bghose               Created
 *============================================================================*/

  FUNCTION Line_Referred_By_Corr (p_Invoice_Id        Number,
                            p_Line_Number       Number,
                            p_Calling_Sequence  Varchar2) Return Boolean Is
    dummy number := 0;
    current_calling_sequence   Varchar2(2000);
    debug_info                 Varchar2(100);

  Begin
    -- Update the calling sequence
    --
    current_calling_sequence :=
        'AP_INVOICE_LINES_UTILITY_PKG.LINE_REFERRED_BY_CORR<-'
                      ||p_Calling_Sequence;

    debug_info := 'Select from ap_invoice_lines_all';

    Select count(*)
    Into   dummy
    From   ap_invoice_lines_all AIL
    Where  NVL(AIL.discarded_flag, 'N' ) <> 'Y'
    And NVL( AIL.cancelled_flag, 'N' ) <> 'Y'
    And AIL.corrected_inv_id = p_Invoice_Id
    And AIL.corrected_line_number = p_Line_Number;

    If (dummy >= 1) Then
      return  TRUE;
    End if;

    return FALSE;

  Exception
    WHEN OTHERS THEN
      If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice Id = '||p_Invoice_id
                              ||', line number = '|| p_Line_Number);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      End If;
      APP_EXCEPTION.RAISE_EXCEPTION;
  End Line_Referred_By_Corr;

 /*=============================================================================
 |  Public FUNCTION Line_Dists_Referred_By_Other
 |
 |      Check if the particular invoice line contains distributions referenced
 |      by active distributions
 |
 |  PROGRAM FLOW
 |
 |       return TRUE  - if line has been referenced by active distributions
 |       return FALSE - otherwise.
 |
 |  MODIFICATION HISTORY
 |  Date         Author               Description of Change
 |  03/10/13     bghose               Created
 *============================================================================*/

  FUNCTION Line_Dists_Referred_By_Other(p_Invoice_Id        Number,
                            p_Line_Number       Number,
                            p_Calling_Sequence  Varchar2) Return Boolean Is
    dummy number := 0;
    current_calling_sequence   Varchar2(2000);
    debug_info                           Varchar2(100);

  Begin
    -- Update the calling sequence
    --
    current_calling_sequence :=
               'AP_INVOICE_LINES_UTILITY_PKG.Line_Dists_Referred_By_Other <-'||
                            p_Calling_Sequence;
    debug_info := 'Select from ap_invoic_distributions_all';

    Select count(*)
    Into   dummy
    From   ap_invoice_distributions_all AID
    Where   NVL(AID.cancellation_flag, 'N') <> 'Y'
    And     NVL(AID.reversal_flag, 'N') <> 'Y'
    And     AID.invoice_id = p_invoice_id
    --Bug9323585 : Commented line to check for inclusive tax also
    --And     AID.invoice_line_number <> p_line_number
    And     AID.charge_applicable_to_dist_id IS NOT NULL
    And     AID.charge_applicable_to_dist_id In
           (Select AID2.invoice_distribution_id
            From ap_invoice_distributions_all AID2
            Where AID2.invoice_id = p_Invoice_Id
            And AID2.invoice_line_number = p_Line_Number
            And NVL(AID2.cancellation_flag, 'N') <> 'Y'
            And NVL(AID2.reversal_flag, 'N') <> 'Y' );

    If (dummy >= 1) Then
      return  TRUE;
    End if;

    return FALSE;

  Exception
    WHEN OTHERS THEN
      If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice Id = '||p_Invoice_id
                              ||', line number = '|| p_Line_Number);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      End If;
      APP_EXCEPTION.RAISE_EXCEPTION;
  End Line_Dists_Referred_By_Other;

 /*=============================================================================
 |  Public FUNCTION Outstanding_Alloc_Exists
 |
 |      Check if the particular invoice line contains outstanding allocation
 |      rule exists (not yet applied)
 |
 |  PROGRAM FLOW
 |
 |       return TRUE  - if line contains outstanding allocations
 |       return FALSE - otherwise.
 |
 |  MODIFICATION HISTORY
 |  Date         Author               Description of Change
 |  03/10/13     bghose               Created
 *============================================================================*/

  FUNCTION Outstanding_Alloc_Exists (p_Invoice_Id        Number,
                            p_Line_Number       Number,
                            p_Calling_Sequence  Varchar2) Return Boolean Is
    dummy number := 0;
    current_calling_sequence   Varchar2(2000);
    debug_info                           Varchar2(100);

  Begin
    -- Update the calling sequence
    --
    current_calling_sequence :=
               'AP_INVOICE_LINES_UTILITY_PKG.Outstanding_Alloc_Exists <-'||
                            p_Calling_Sequence;
    debug_info := 'Select from ap_allocatin_rules';

    Select count(*)
    Into   dummy
    From   ap_allocation_rules  AR,
           ap_allocation_rule_lines ARL
    Where  AR.invoice_id = p_Invoice_Id
    And    AR.invoice_id = ARL.invoice_id (+)
    And    AR.chrg_invoice_line_number = ARL.chrg_invoice_line_number (+)
    --Commented below condition for bug #9143555 and introduced new conditions
    -- And ARL.to_invoice_line_number (+)  = p_line_number
    And    AR.chrg_invoice_line_number  = p_line_number
    And    AR.status = 'PENDING';

    If (dummy >= 1) Then
      return  TRUE;
    End if;

    return FALSE;
  Exception
    WHEN OTHERS THEN
      If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice Id = '||p_Invoice_id
                              ||', line number = '|| p_Line_Number);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      End If;
      APP_EXCEPTION.RAISE_EXCEPTION;
  End Outstanding_Alloc_Exists;

 /*=============================================================================
 |  Public FUNCTION Line_Dists_Trans_Pa
 |
 |      Check if the particular invoice line contains project related
 |      distributions
 |
 |  PROGRAM FLOW
 |
 |       return TRUE  - if line has been referred by any correction
 |       return FALSE - otherwise.
 |
 |  MODIFICATION HISTORY
 |  Date         Author               Description of Change
 |  03/10/13     bghose               Created
 *============================================================================*/

  FUNCTION Line_Dists_Trans_Pa (p_Invoice_Id        Number,
                            p_Line_Number       Number,
                            p_Calling_Sequence  Varchar2) Return Boolean Is
    dummy number := 0;
    current_calling_sequence   Varchar2(2000);
    debug_info                 Varchar2(100);

  Begin
    -- Update the calling sequence
    --
    current_calling_sequence :=
               'AP_INVOICE_LINES_UTILITY_PKG.Line_Dists_Trans_PA <-'||
                            p_Calling_Sequence;
    debug_info := 'Select from ap_invoic_distributions_all';

    Select count(*)
    Into   dummy
    From   ap_invoice_distributions_all
    Where invoice_id = p_Invoice_Id
    And invoice_line_number = p_Line_Number
    And pa_addition_flag In ('T', 'Y', 'Z') ;

    If (dummy >= 1) Then
      return  TRUE;
    End if;

    return FALSE;

  Exception
    WHEN OTHERS THEN
      If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice Id = '||p_Invoice_id
                              ||', line number = '|| p_Line_Number);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      End If;
      APP_EXCEPTION.RAISE_EXCEPTION;
  End Line_Dists_Trans_Pa;

 /*=============================================================================
 |  Public FUNCTION Can_Line_Be_Deleted
 |
 |      Check if the particular invoice line can be deleted
 |
 |  PROGRAM FLOW
 |
 |       return TRUE  - if line can be deleted
 |       return FALSE - otherwise and return error code.
 |
 |  MODIFICATION HISTORY
 |  Date         Author               Description of Change
 |  03/10/13     bghose               Created
 *============================================================================*/

  FUNCTION Can_Line_Be_Deleted (p_line_rec    IN ap_invoice_lines%ROWTYPE,
                              p_error_code  OUT NOCOPY Varchar2,
                              p_Calling_Sequence  Varchar2) Return Boolean Is
    current_calling_sequence   Varchar2(2000);

  Begin
    -- Update the calling sequence
    --
    current_calling_sequence :=
               'AP_INVOICE_LINES_UTILITY_PKG.Can_Line_Be_Deleted <-'||
                            p_Calling_Sequence;

    If (Ap_Invoice_Lines_Utility_Pkg.Line_Dists_Acct_Event_Created
                                   (p_Line_Rec.Invoice_Id,
                                    p_Line_Rec.Line_Number,
                                    Current_calling_sequence) = TRUE)  Then
       p_error_code := 'AP_INV_LINE_DELETE_VALIDATED';
       return False;
    ElsIf (Ap_Invoice_Lines_Utility_Pkg.Line_Referred_By_Corr
                                   (p_Line_Rec.Invoice_Id,
                                    p_Line_Rec.Line_Number,
                                    Current_calling_sequence) = TRUE)  Then
       p_error_code := 'AP_INV_LINE_DELETE_CORR';
       return False;
    ElsIf (NVL(Ap_Invoice_Lines_Utility_Pkg.Get_Encumbered_Flag
                                   (p_Line_Rec.Invoice_Id,
                                    p_Line_Rec.Line_Number), 'N')
                                       In ('Y', 'P'))  Then
       p_error_code := 'AP_INV_LINE_DELETE_ENCUMBERED';
       return False;
    ElsIf (Ap_Invoice_Lines_Utility_Pkg.Get_Posting_Status
                                   (p_Line_Rec.Invoice_Id,
                                    p_Line_Rec.Line_Number)
                                       In ('Y', 'P', 'S'))  Then
       p_error_code := 'AP_INV_LINE_DELETE_ACCOUNTED';
       return False;
    ElsIf (Ap_Invoice_Lines_Utility_Pkg.Line_Dists_Trans_PA
                                   (p_Line_Rec.Invoice_Id,
                                    p_Line_Rec.Line_Number,
                                    Current_calling_sequence) = TRUE)  Then
       p_error_code := 'AP_INV_LINE_DELETE_PA';
       return False;
    ElsIf (Ap_Invoice_Lines_Utility_Pkg.Line_Dists_Referred_By_Other
                                   (p_Line_Rec.Invoice_Id,
                                    p_Line_Rec.Line_Number,
                                    Current_calling_sequence) = TRUE)  Then
       p_error_code := 'AP_INV_LINE_REF_BY_DISTS';
       return False;
    ElsIf (Ap_Invoice_Lines_Utility_Pkg.Outstanding_Alloc_Exists
                                   (p_Line_Rec.Invoice_Id,
                                    p_Line_Rec.Line_Number,
                                    Current_calling_sequence) = TRUE)  Then
       p_error_code := 'AP_INV_LINE_HAS_ALLOC_RULE';
       return False;
    End If;

    p_error_code := null;
    return TRUE;

  Exception
    WHEN OTHERS THEN
      If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice Id = '||
                                p_line_rec.Invoice_id
                              ||', line number = '|| p_line_rec.Line_Number);
      End If;
      APP_EXCEPTION.RAISE_EXCEPTION;
  End Can_Line_Be_Deleted;

 /*=============================================================================
 |  Public FUNCTION Get_Packet_Id
 |
 |      Get the Packet Id for a line
 |
 |  PROGRAM FLOW
 |
 |
 |  MODIFICATION HISTORY
 |  Date         Author               Description of Change
 |  03/10/13     bghose               Created
 *============================================================================*/

  FUNCTION Get_Packet_Id (p_invoice_id In Number,
                          p_Line_Number In Number)    Return Number Is

    l_packet_id number := '';
    Cursor packet_id_cursor Is
    Select decode(count(distinct(packet_id)),1,max(packet_id),'')
    From ap_invoice_distributions
    Where invoice_id = p_Invoice_Id
    And invoice_line_number = p_Line_Number
    And packet_id is not null;

    Begin
      Open packet_id_cursor;
      Fetch packet_id_cursor INTO l_packet_id;
      Close packet_id_cursor;

    Return(l_packet_id);
  End get_packet_id;


/*=============================================================================
 |  FUNCTION - Is_Line_Fully_Distributed
 |
 |  DESCRIPTION
 |    This function returns TRUE if the line is completelly distributed.
 |    It returns FALSE otherwise.
 |
 |  PARAMETERS
 |      P_Invoice_Id - Invoice Id
 |      P_Line_number - line number
 |      P_Calling_Sequence - debug usage
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  30-JUL-2003  SYIDNER            Creation
 |
 *============================================================================*/

  FUNCTION Is_Line_Fully_Distributed(
             P_Invoice_Id           IN NUMBER,
             P_Line_Number          IN NUMBER,
             P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN

  IS

  CURSOR Dist_Var_Cur IS
    SELECT 'Dist Total <> Invoice Line Amount'
    FROM   ap_invoice_lines AIL, ap_invoice_distributions D
    WHERE  AIL.invoice_id  = D.invoice_id
    AND    AIL.line_number = p_line_number
    AND    AIL.invoice_id  = p_invoice_id
    AND    AIL.line_number = D.invoice_line_number
    AND    (D.line_type_lookup_code <> 'RETAINAGE'
    	    OR (AIL.line_type_lookup_code = 'RETAINAGE RELEASE'
    	        and D.line_type_lookup_code = 'RETAINAGE'))
    AND    (AIL.line_type_lookup_code <> 'ITEM'
            or (AIL.line_type_lookup_code = 'ITEM'
                and (D.prepay_distribution_id IS NULL
                     or (D.prepay_distribution_id IS NOT NULL
                         and D.line_type_lookup_code NOT IN ('PREPAY', 'REC_TAX', 'NONREC_TAX')))))
    GROUP BY AIL.invoice_id, AIL.line_number, AIL.amount
    HAVING AIL.amount <> nvl(SUM(nvl(D.amount,0)),0);

    current_calling_sequence   VARCHAR2(4000);
    debug_info                 VARCHAR2(240);
    l_test_var                 VARCHAR2(50);

  BEGIN
      -------------------------------------------------------------
      current_calling_sequence := 'AP_INVOICE_LINES_UTILITY_PKG - Is_Line_Fully_Distributed';
      debug_info := 'Is_Line_Fully_Distributed - Open cursor';
      -------------------------------------------------------------

      OPEN  Dist_Var_Cur;
      FETCH Dist_Var_Cur
       INTO l_test_var;
      CLOSE Dist_Var_Cur;

      RETURN (l_test_var IS NULL);

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice Id = '||P_Invoice_Id);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;

      IF (Dist_Var_Cur%ISOPEN) THEN
        CLOSE Dist_Var_Cur;
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Is_Line_Fully_Distributed;

/*=============================================================================
 |  FUNCTION - Is_PO_RCV_Amount_Exceeded
 |
 |  DESCRIPTION
 |    This function returns TRUE if the reversal of the line makes the
 |    quantity or amount billed go below 0.  It returns FALSE otherwise.
 |
 |  PARAMETERS
 |      P_Invoice_Id - Invoice Id
 |      P_Line_Number - line number
 |      P_Calling_Sequence - debug usage
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  30-JUL-2003  SYIDNER            Creation
 |
 *============================================================================*/

  FUNCTION Is_PO_RCV_Amount_Exceeded(
             P_Invoice_Id           IN NUMBER,
             P_Line_Number          IN NUMBER,
             P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN

  IS
    CURSOR Invoice_Validation IS
    SELECT count(*)
      FROM po_distributions_all POD,
           ap_invoice_distributions AID
     WHERE POD.po_distribution_id = AID.po_distribution_id
       AND AID.invoice_id = P_Invoice_Id
       AND POD.org_id = AID.org_id
       AND AID.invoice_line_number = P_Line_Number
       AND NVL(AID.reversal_flag,'N')<>'Y'
       AND ( NVL(POD.quantity_billed, 0) -
             decode( AID.dist_match_type,
                     'PRICE_CORRECTION',  0,
                     'AMOUNT_CORRECTION', 0,    /* Ampunt Based Matching */
                     'ITEM_TO_SERVICE_PO', 0,
                     'ITEM_TO_SERVICE_RECEIPT', 0,
                     nvl( AID.corrected_quantity,0 ) +
                     nvl( AID.quantity_invoiced,0 ) ) < 0
             OR
             NVL(POD.amount_billed, 0) - NVL(AID.amount, 0) < 0 );

    l_invoice_id               ap_invoices_all.invoice_id%TYPE;
    current_calling_sequence   VARCHAR2(4000);
    debug_info                 VARCHAR2(240);
    l_po_dist_count            NUMBER := 0;
    l_return_var               BOOLEAN := FALSE;


  BEGIN
      current_calling_sequence := 'AP_INVOICE_LINES_UTILITY_PKG - Is_PO_RCV_Amount_Exceeded';
      -------------------------------------------------------------
      debug_info := 'Is_PO_RCV_Amount_Exceeded - Open cursor';
      -------------------------------------------------------------

      OPEN invoice_validation;
      FETCH invoice_validation INTO l_po_dist_count;
      CLOSE invoice_validation;

      -------------------------------------------------------------
      debug_info := 'Check if quantity_billed on po_distribution is
                     brought to 0';
      -------------------------------------------------------------
      IF (l_po_dist_count > 0  ) THEN
        l_return_var := TRUE;
      END IF;

    RETURN l_return_var;

  EXCEPTION
    WHEN OTHERS THEN
      if (SQLCODE <> -20001) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice Id = '||P_Invoice_Id);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      end if;
      debug_info := debug_info || 'Error occurred';

      IF ( invoice_validation%ISOPEN ) THEN
        CLOSE invoice_validation;
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Is_PO_RCV_Amount_Exceeded;

 /*=============================================================================
 |  Public FUNCTION Is_Invoice_Fully_Distributed
 |
 |    Check if an invoice is fully distributed or not. An invoice is
 |    fully distributed if all of its lines were distributed.
 |
 |  PROGRAM FLOW
 |
 |       return TRUE  - if invoice is fully distributed
 |       return FALSE - otherwise.
 |
 |  MODIFICATION HISTORY
 |  Date          Author               Description of Change
 |  24-FEB-2004   ISartawi             Created
 *============================================================================*/

FUNCTION Is_Invoice_Fully_Distributed (
          P_invoice_id  IN NUMBER) RETURN BOOLEAN
IS
  l_count NUMBER;
BEGIN

  -- This function is used to determine if the invoice is fully
  -- distributed or not. The invoice is fully distributed if all
  -- its lines were distributed. In this case the line will have
  -- generate_dists = 'D'. If one line had generate_dists <> 'D'
  -- then the invoice is not fully distributed.

  SELECT COUNT(*)
    INTO l_count
    FROM ap_invoice_lines
   WHERE invoice_id      = p_invoice_id
     AND generate_dists <> 'D'
     AND ROWNUM = 1;

  IF l_count > 0 THEN
    RETURN (FALSE);  -- The Invoice is not fully distributed
  ELSE
    RETURN (TRUE);   -- The Invoice is fully distributed
  END IF;

END Is_Invoice_Fully_Distributed;


--Invoice Lines: Distributions
/*=============================================================================
|  Public FUNCTION Pending_Alloc_Exists_Chrg_Line
|
|  Check if the particular invoice charge line contains outstanding allocation
|      rule exists (not yest applied)
|
|  PROGRAM FLOW
|
|       return TRUE  - if line contains outstanding allocations
|       return FALSE - otherwise.
|
|  MODIFICATION HISTORY
|  Date           Author               Description of Change
|  01/27/2004     surekha myadam       Created
*============================================================================*/
  FUNCTION Pending_Alloc_Exists_Chrg_Line
                           (p_Invoice_Id        Number,
                            p_Line_Number       Number,
                            p_Calling_Sequence  Varchar2) Return Boolean Is
    dummy number := 0;
    current_calling_sequence   Varchar2(2000);
    debug_info                           Varchar2(100);
  Begin
    -- Update the calling sequence
    --
    current_calling_sequence :=
    'AP_INVOICE_LINES_UTILITY_PKG.Pending_Alloc_Exists_Chrg_Line <-'||
                            p_Calling_Sequence;
    debug_info := 'Select from ap_allocatin_rules';

    Select count(*)
    Into   dummy
    From   ap_allocation_rules  AR
    Where  AR.invoice_id = p_Invoice_Id
    And    AR.chrg_invoice_line_number = p_line_number
    And    AR.status = 'PENDING';

    If (dummy >= 1) Then
      return  TRUE;
    End if;

    return FALSE;
  Exception
    WHEN OTHERS THEN
      If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice Id = '||p_Invoice_id
                              ||', line number = '|| p_Line_Number);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      End If;
      APP_EXCEPTION.RAISE_EXCEPTION;
End Pending_Alloc_Exists_Chrg_Line;


/*=============================================================================
|  Public FUNCTION Is_Line_a_Correction
|
|  Check if the particular invoice line is correcting some other invoice line.
|
|  PROGRAM FLOW
|
|       return TRUE  - if line is a correction
|       return FALSE - otherwise.
|
|  MODIFICATION HISTORY
|  Date           Author               Description of Change
|  01-JUL-2004    Surekha Myadam       Created
*============================================================================*/
FUNCTION Is_Line_a_Correction(
                P_Invoice_Id           IN NUMBER,
		P_Line_Number          IN NUMBER,
		P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN IS

is_correction varchar2(1) := 'N';
BEGIN

   SELECT 'Y'
   INTO is_correction
   FROM ap_invoice_lines
   WHERE invoice_id = p_invoice_id
   AND line_number = p_line_number
   AND corrected_inv_id IS NOT NULL
   AND corrected_line_number IS NOT NULL;


   IF (is_correction = 'Y') THEN
    return (TRUE);
   ELSE
    return (FALSE);
   END IF;

EXCEPTION WHEN OTHERS THEN
  RETURN(FALSE);

END Is_Line_a_Correction;



/*=============================================================================
|  Public FUNCTION Line_Referred_By_Adjustment
|
|  Check if the particular invoice line has been adjusted by PO Price Adjustment
|
|  PROGRAM FLOW
|
|       return TRUE  - if line is adjusted by PO Price Adjustment
|       return FALSE - otherwise.
|
|  MODIFICATION HISTORY
|  Date           Author               Description of Change
|  01-JUL-2004    Surekha Myadam       Created
*============================================================================*/
FUNCTION Line_Referred_By_Adjustment(
                P_Invoice_Id           IN NUMBER,
                P_Line_Number          IN NUMBER,
                P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN IS
 l_count NUMBER := 0;
BEGIN

  SELECT count(*)
  INTO l_count
  FROM ap_invoice_lines_all
  WHERE corrected_inv_id = p_invoice_id
  AND corrected_line_number = p_line_number
  AND line_type_lookup_code IN ('RETROITEM')
  AND line_source = 'PO PRICE ADJUSTMENT'
  AND match_type = 'RETRO PRICE ADJUSTMENT';


  IF (l_count > 0) THEN
    RETURN (TRUE);
  ELSE
    RETURN (FALSE);
  END IF;

END Line_Referred_By_Adjustment;


/*=============================================================================
|  Public FUNCTION Is_Line_a_Adjustment
|
|  Check if the particular invoice line has adjusted (po price adjust)
|  some other invoice line.
|
|  PROGRAM FLOW
|
|       return TRUE  - if line is a po price adjustment line.
|       return FALSE - otherwise.
|
|  MODIFICATION HISTORY
|  Date           Author               Description of Change
|  01-JUL-2004    Surekha Myadam       Created
*============================================================================*/
FUNCTION Is_Line_a_Adjustment(
                P_Invoice_Id           IN NUMBER,
                P_Line_Number          IN NUMBER,
                P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN IS
 is_po_price_adjustment VARCHAR2(1) := 'N';
BEGIN

  SELECT 'Y'
  INTO is_po_price_adjustment
  FROM ap_invoice_lines_all
  WHERE invoice_id = p_invoice_id
  AND line_number = p_line_number
  AND line_type_lookup_code = 'RETROITEM'
  AND line_source = 'PO PRICE ADJUSTMENT'
  AND match_type = 'RETRO PRICE ADJUSTMENT';

  IF (is_po_price_adjustment = 'Y') THEN
    RETURN(TRUE);
  ELSE
    RETURN(FALSE);
  END IF;

 EXCEPTION WHEN OTHERS THEN
   RETURN(FALSE);

END Is_Line_a_Adjustment;


/*=============================================================================
| Public FUNCTION Is_Line_a_Prepay
|
| Check if the particular invoice line is a prepayment application/unapplication
|  (Normally this can be identified by looking at the line_type_lookup_code
|   but from the place where this is called (etax windows) the line_type is not
|   available, hence need to code this function.)
|
|  PROGRAM FLOW
|
|       return TRUE  - if line of type PREPAY.
|       return FALSE - otherwise.
|
|  MODIFICATION HISTORY
|  Date           Author               Description of Change
|  01-JUL-2004    Surekha Myadam       Created
*============================================================================*/
FUNCTION Is_Line_a_Prepay(
                P_Invoice_Id           IN NUMBER,
                P_Line_Number          IN NUMBER,
                P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN IS
 is_prepayment varchar2(1) := 'N';
BEGIN

  SELECT 'Y'
  INTO is_prepayment
  FROM ap_invoice_lines
  WHERE invoice_id = p_invoice_id
  AND line_number = p_line_number
  AND line_type_lookup_code = 'PREPAY';

  IF (is_prepayment = 'Y') THEN
    return (TRUE);
  ELSE
    return (FALSE);
  END IF;

EXCEPTION WHEN OTHERS THEN

  return(FALSE);

END Is_Line_a_Prepay;

Function Get_Retained_Amount
		(p_line_location_id IN NUMBER,
		 p_match_amount	    IN NUMBER) RETURN NUMBER IS

  l_ret_status		Varchar2(100);
  l_msg_data		Varchar2(4000);

  l_currency_code       PO_HEADERS_ALL.currency_code%type;

  l_line_loc_tab	PO_TBL_NUMBER;
  l_line_loc_amt_tab	PO_TBL_NUMBER;
  l_amt_to_retain_tab	PO_TBL_NUMBER;

  l_retained_amount     Number;

Begin

  If p_line_location_id Is Not Null Then

     l_line_loc_tab := po_tbl_number();
     l_line_loc_tab.extend;
     l_line_loc_tab(l_line_loc_tab.last) := p_line_location_id;

     l_line_loc_amt_tab := po_tbl_number();
     l_line_loc_amt_tab.extend;
     l_line_loc_amt_tab(l_line_loc_amt_tab.last) := p_match_amount;

     -- bug6882900
     BEGIN

	SELECT currency_code
	INTO l_currency_code
	FROM po_headers_all
	WHERE po_header_id IN
	  (SELECT po_header_id
	   FROM po_line_locations_all
	   WHERE line_location_id = p_line_location_id)
	AND rownum < 2;

     EXCEPTION
        WHEN OTHERS THEN
	  NULL;

     END;


     PO_AP_INVOICE_MATCH_GRP.get_amount_to_retain(
		  p_api_version			=> 1.0
		, p_line_location_id_tbl        => l_line_loc_tab
		, p_line_loc_match_amt_tbl      => l_line_loc_amt_tab
		, x_return_status		=> l_ret_status
		, x_msg_data                    => l_msg_data
		, x_amount_to_retain_tbl        => l_amt_to_retain_tab);

     IF l_amt_to_retain_tab.count > 0 THEN

        l_retained_amount := -1 * l_amt_to_retain_tab(l_amt_to_retain_tab.last);

     END IF;

  End If;

  -- bug6882900
  Return (ap_utilities_pkg.ap_round_currency(l_retained_amount, l_currency_code));

End Get_Retained_Amount;

/* ==========================================================================================
 *  Procedure manual_withhold_tax()
 *  Objective update ap_payment_schedules.remaining_amount for manual entry
 *  withholding lines
 *  This procedire has been moved from payment schedules library since it did
 *  not consider the
 *  ap lines model
 *  This PROCEDURE is added for Bug 6917289
 * =============================================================================================*/
PROCEDURE Manual_Withhold_Tax(p_invoice_id IN number
                             ,p_manual_withhold_amount IN number
                             ) IS

 l_inv_amt_remaining  ap_payment_schedules.amount_remaining%TYPE := 0;
 l_gross_amount       ap_payment_schedules.gross_amount%TYPE := 0;
 l_payment_cross_rate ap_invoices_all.payment_cross_rate%TYPE :=0;
 l_payment_currency_code ap_invoices_all.payment_currency_code%TYPE;

 -- Debug variables
 l_debug_loc                   VARCHAR2(30) := 'Manual_Withhold_Tax';
 l_curr_calling_sequence       VARCHAR2(2000);
 l_debug_info                  VARCHAR2(2000);


BEGIN

  l_curr_calling_sequence := 'AP_INVOICE_LINES_UTILITY_PKG.'||l_debug_loc;

  SELECT nvl(payment_cross_rate,0), payment_currency_code
    INTO l_payment_cross_rate, l_payment_currency_code
    FROM ap_invoices_all
   WHERE invoice_id = p_invoice_id;

  SELECT sum(nvl(amount_remaining,0)), sum(nvl(gross_amount,0))
    INTO l_inv_amt_remaining, l_gross_amount
    FROM ap_payment_schedules
   WHERE invoice_id = p_invoice_id;

  l_debug_info := 'Updating payment schedules due a manual withholding tax';

  IF ((l_inv_amt_remaining <> 0) AND (p_manual_withhold_amount is not null))
  THEN
          update ap_payment_schedules
             set amount_remaining = (amount_remaining +
                                     ap_utilities_pkg.ap_round_currency(
                        (amount_remaining * (p_manual_withhold_amount/l_inv_amt_remaining)
                         * l_payment_cross_rate), l_payment_currency_code))
           where invoice_id = p_invoice_id;

  ELSIF ((l_inv_amt_remaining = 0) and (p_manual_withhold_amount is not null))
     THEN
          update ap_payment_schedules
             set amount_remaining = (amount_remaining +
                                     ap_utilities_pkg.ap_round_currency(
                     (gross_amount * (p_manual_withhold_amount/l_gross_amount)
                      * l_payment_cross_rate), l_payment_currency_code)),
                 payment_status_flag = DECODE(payment_status_flag,'Y','P',payment_status_flag)
           where invoice_id = p_invoice_id;

          update ap_invoices
             set payment_status_flag = DECODE(payment_status_flag,'Y','P',payment_status_flag)
           where invoice_id = p_invoice_id ;

  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       NULL;
  WHEN OTHERS THEN
       IF (SQLCODE <> -20001) THEN
           FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
           FND_MESSAGE.SET_TOKEN('PARAMETERS',
                          'P_Invoice_Id  = '|| p_invoice_id
                      ||', p_manual_withhold_amount= '|| to_char(p_manual_withhold_amount));
           FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
       END IF;

       APP_EXCEPTION.RAISE_EXCEPTION;

END Manual_Withhold_Tax;

/* ==================================================================================
 *  Function get_awt_flag()
 *  Objective Retrun the awt_flag for a given invoice_id and invoice_line_number
 *  This function is called from the invoice lines library
 *  Bug 6917289
 * ==================================================================================*/

FUNCTION get_awt_flag(
             p_invoice_id  IN  NUMBER,
             p_line_number IN  NUMBER )
  RETURN VARCHAR2
  IS
      l_awt_flag ap_invoice_distributions_all.awt_flag%TYPE;

BEGIN

  SELECT awt_flag
    INTO l_awt_flag
    FROM ap_invoice_distributions_all
   WHERE invoice_id = p_invoice_id
     AND invoice_line_number = p_line_number
     AND rownum = 1;

  IF l_awt_flag is null THEN
     RETURN ('Z');
  ELSE
     RETURN (l_awt_flag);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN ('B');
  WHEN Others THEN
       RETURN ('Z');
END get_awt_flag;

END  AP_INVOICE_LINES_UTILITY_PKG;

/
