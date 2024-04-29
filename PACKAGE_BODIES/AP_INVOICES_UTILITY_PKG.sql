--------------------------------------------------------
--  DDL for Package Body AP_INVOICES_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_INVOICES_UTILITY_PKG" AS
/* $Header: apinvutb.pls 120.56.12010000.19 2010/12/24 04:15:44 pgayen ship $ */

/*=============================================================================
 |  FUNCTION - get_prepay_number
 |
 |  DESCRIPTION
 |      returns the prepayment number that the prepayment distribution  is
 |      associated with.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_prepay_number (l_prepay_dist_id IN NUMBER)
    RETURN VARCHAR2 IS
      l_prepay_number VARCHAR2(50);

      CURSOR c_prepay_number IS
      SELECT invoice_num
      FROM   ap_invoices
      WHERE invoice_id =
                (SELECT invoice_id
                   FROM ap_invoice_distributions
                  WHERE invoice_distribution_id = l_prepay_dist_id);
    BEGIN

      OPEN  c_prepay_number;
      FETCH c_prepay_number
      INTO  l_prepay_number;
      CLOSE c_prepay_number;

      RETURN(l_prepay_number);

    END get_prepay_number;

/*=============================================================================
 |  FUNCTION - get_prepay_dist_number
 |
 |  DESCRIPTION
 |      Returns the distribution_line_number that the prepayment associated
 |      with.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_prepay_dist_number (l_prepay_dist_id IN NUMBER)
    RETURN VARCHAR2 IS
      l_prepay_dist_number VARCHAR2(50);

      CURSOR c_prepay_dist_number IS
      SELECT distribution_line_number
      FROM   ap_invoice_distributions
      WHERE  invoice_distribution_id = l_prepay_dist_id;

    BEGIN

      OPEN c_prepay_dist_number;
      FETCH c_prepay_dist_number
      INTO l_prepay_dist_number;
      CLOSE c_prepay_dist_number;

      RETURN(l_prepay_dist_number);

    END get_prepay_dist_number;

/*=============================================================================
 |  FUNCTION - get_distribution_total
 |
 |  DESCRIPTION
 |      returns the total distribution amount for the invoice.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |      1. Bug 1121323. Excluding the tax on the prepayment from the
 |         distribution total.
 |      2. Bug 1639039. Including the Prepayment and Prepayment Tax from
 |         the distribution total if the invoice_includes_prepay_flag is
 |         set to Y
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_distribution_total(
                  l_invoice_id IN NUMBER
                       )
    RETURN NUMBER IS

      distribution_total NUMBER := 0;
      --Bugfix:3854385
      l_Y	VARCHAR2(1) := 'Y';

    BEGIN

       -- eTax Uptake.  Modified to exclude REC_TAX and NONREC_TAX
       -- distributions created for prepayment applications
       SELECT SUM(NVL(aid.amount,0))
         INTO distribution_total
         FROM ap_invoice_distributions_all aid,
              ap_invoice_lines_all ail
        WHERE ail.invoice_id = l_invoice_id
          AND aid.invoice_id = ail.invoice_id
          AND aid.invoice_line_number = ail.line_number
          AND ((aid.line_type_lookup_code NOT IN ('PREPAY', 'AWT')
                AND aid.prepay_distribution_id IS NULL)
              OR NVL(ail.invoice_includes_prepay_flag,'N') = l_y);


      RETURN(distribution_total);

    END get_distribution_total;


/*===========================================================================
 |  FUNCTION -  get_posting_status
 |
 |  DESCRIPTION
 |      returns the invoice posting status flag.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES
 |      'Y' - Posted
 |      'N' - Unposted
 |      'S' - Selected
 |      'P' - Partially Posted
 |      ---------------------------------------------------------------------
 |      -- Declare cursor to establish the invoice-level posting flag
 |      --
 |      -- The first two selects simply look at the posting flags. The 'S'
 |      -- one means the invoice distributions are selected for accounting
 |      -- processing. The 'P' is to cover one specific case when some of
 |      -- the distributions are fully posting (Y) and some are unposting (N).
 |      -- The status should be partial (P).
 |      --
 |      -- MOAC.  Use ap_invoice_distributions_all table instead of SO view
 |      -- since this procedure is called when policy context is not set to
 |      -- the corresponding OU for the invoice_id
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  04-Mar-05    Yicao              Rewrite the procedure for SLA project
 *==========================================================================*/
  FUNCTION get_posting_status(l_invoice_id IN NUMBER)
    RETURN VARCHAR2 IS
      invoice_posting_flag           VARCHAR2(1);
      distribution_posting_flag      VARCHAR2(1);
      l_cash_basis_flag              VARCHAR2(1);
      l_org_id                       AP_SYSTEM_PARAMETERS_ALL.ORG_ID%TYPE;


       CURSOR posting_cursor IS
       SELECT cash_posted_flag
         FROM ap_invoice_distributions_all
        WHERE invoice_id = l_invoice_id
          AND l_cash_basis_flag = 'Y'
        UNION
       SELECT accrual_posted_flag
         FROM ap_invoice_distributions_all
        WHERE invoice_id = l_invoice_id
          AND l_cash_basis_flag <>'Y'
        UNION
       SELECT 'P'
         FROM ap_invoice_distributions_all
        WHERE invoice_id = l_invoice_id
          AND ((cash_posted_flag = 'Y' AND l_cash_basis_flag = 'Y')
               OR
               (accrual_posted_flag = 'Y' AND l_cash_basis_flag <> 'Y'))
          AND EXISTS
             (SELECT 'An N is also in the valid flags'
                FROM ap_invoice_distributions_all
               WHERE invoice_id = l_invoice_id
                 AND ((cash_posted_flag = 'N'
                       AND l_cash_basis_flag = 'Y')
                       OR
                       (accrual_posted_flag = 'N'
                       AND l_cash_basis_flag <> 'Y'))  -- bug fix 6975868
 	       UNION             /*Added for bug 10039729*/
 	      SELECT 'An N is also in the valid flags'
 		FROM ap_prepay_history_all
 	       WHERE invoice_id = l_invoice_id
 		 AND posted_flag = 'N'
 		 AND transaction_type = 'PREPAYMENT APPLICATION ADJ'
               UNION
              SELECT 'An N is also in the valid flags'
                FROM ap_self_assessed_tax_dist_all
               WHERE invoice_id = l_invoice_id
                 AND ((cash_posted_flag = 'N'
                       AND l_cash_basis_flag = 'Y')
                       OR
                       (accrual_posted_flag = 'N'
                       AND l_cash_basis_flag <> 'Y'))
   	     )
      -- bug fix 6975868  begin
        UNION
       SELECT cash_posted_flag
         FROM ap_self_assessed_tax_dist_all
        WHERE invoice_id = l_invoice_id
          AND l_cash_basis_flag = 'Y'
        UNION
       SELECT accrual_posted_flag
         FROM ap_self_assessed_tax_dist_all
        WHERE invoice_id = l_invoice_id
          AND l_cash_basis_flag <>'Y'
        UNION
       SELECT 'P'
         FROM ap_self_assessed_tax_dist_all
        WHERE invoice_id = l_invoice_id
          AND ((cash_posted_flag = 'Y'
              AND l_cash_basis_flag = 'Y')
              OR
            (accrual_posted_flag = 'Y'
             AND l_cash_basis_flag <> 'Y'))
          AND EXISTS
             (SELECT 'An N is also in the valid flags'
                FROM   ap_self_assessed_tax_dist_all
               WHERE  invoice_id = l_invoice_id
                 AND ((cash_posted_flag = 'N'
                      AND l_cash_basis_flag = 'Y')
                      OR
                      (accrual_posted_flag = 'N'
                       AND l_cash_basis_flag <> 'Y'))
               UNION   /*Added for bug 10039729*/
              SELECT 'An N is also in the valid flags'
                FROM   ap_invoice_distributions_all
               WHERE  invoice_id = l_invoice_id
                 AND  ((cash_posted_flag = 'N'
                      AND l_cash_basis_flag = 'Y')
                      OR
                      (accrual_posted_flag = 'N'
                      AND l_cash_basis_flag <> 'Y'))
	       UNION
   	      SELECT 'An N is also in the valid flags'
 		FROM ap_prepay_history_all
 	       WHERE invoice_id = l_invoice_id
 		 AND  posted_flag = 'N'
 		 AND transaction_type = 'PREPAYMENT APPLICATION ADJ')
        UNION
       -- bug9440144
       SELECT posted_flag
         FROM ap_prepay_history_all
        WHERE invoice_id = l_invoice_id
          AND transaction_type = 'PREPAYMENT APPLICATION ADJ'
        UNION   /*Added for bug 10039729*/
       SELECT 'P'
         FROM ap_prepay_history_all
        WHERE invoice_id = l_invoice_id
          AND transaction_type = 'PREPAYMENT APPLICATION ADJ'
          AND posted_flag = 'Y'
          AND EXISTS
             (SELECT 'An N is also in the valid flags'
                FROM ap_invoice_distributions_all
               WHERE invoice_id = l_invoice_id
                 AND ((cash_posted_flag = 'N'
                      AND l_cash_basis_flag = 'Y')
                      OR
                      (accrual_posted_flag = 'N'
                       AND l_cash_basis_flag <> 'Y'))
  	       UNION
 	      SELECT 'An N is also in the valid flags'
 	   	FROM ap_prepay_history_all
 	       WHERE invoice_id = l_invoice_id
 		 AND posted_flag = 'N'
   		 AND transaction_type = 'PREPAYMENT APPLICATION ADJ'
               UNION
 	      SELECT 'An N is also in the valid flags'
                FROM ap_self_assessed_tax_dist_all
               WHERE invoice_id = l_invoice_id
                 AND ((cash_posted_flag = 'N'
                       AND l_cash_basis_flag = 'Y')
                       OR
                       (accrual_posted_flag = 'N'
                       AND l_cash_basis_flag <> 'Y'))
 		); -- bug fix 6975868;


     -- bug fix 6975868  end
    BEGIN

    /*-----------------------------------------------------------------+
    |  Get Accounting Methods                                          |
    |  MOAC.  Added org_id to select statement.                        |
    +-----------------------------------------------------------------*/

      SELECT nvl(sob.sla_ledger_cash_basis_flag, 'N'),
             asp.org_id
      INTO   l_cash_basis_flag,
             l_org_id
      FROM ap_invoices_all ai,
           ap_system_parameters_all asp,
           gl_sets_of_books sob
      WHERE ai.invoice_id = l_invoice_id
      AND ai.org_id = asp.org_id
      AND asp.set_of_books_id = sob.set_of_books_id;

      invoice_posting_flag := 'X';

      OPEN posting_cursor;

      LOOP
      FETCH posting_cursor INTO distribution_posting_flag;
      EXIT WHEN posting_cursor%NOTFOUND;

        IF (distribution_posting_flag = 'S') THEN
          invoice_posting_flag := 'S';
        ELSIF (distribution_posting_flag = 'P' AND
               invoice_posting_flag <> 'S') THEN
          invoice_posting_flag := 'P';
        ELSIF (distribution_posting_flag = 'N' AND
               invoice_posting_flag NOT IN ('S','P')) THEN
          invoice_posting_flag := 'N';
	ELSIF (distribution_posting_flag IS NULL) THEN
          invoice_posting_flag := 'N';
        END IF;

        IF (invoice_posting_flag NOT IN ('S','P','N')) THEN
          invoice_posting_flag := 'Y';
        END IF;
      END LOOP;
      CLOSE posting_cursor;

      if (invoice_posting_flag = 'X') then
        invoice_posting_flag := 'N';
      end if;

      --bug6160540
      if invoice_posting_flag = 'N' then

         BEGIN
          SELECT 'D'
          INTO   invoice_posting_flag
          FROM   ap_invoice_distributions_all AID,
                  xla_events                   XE
          WHERE  AID.invoice_id = l_invoice_id
          AND    AID.accounting_event_id = XE.event_id
          AND    ((AID.accrual_posted_flag = 'N' AND l_cash_basis_flag = 'N') OR
                  (AID.cash_posted_flag = 'N' AND l_cash_basis_flag  = 'Y'))
          AND    XE.process_status_code = 'D'
          AND    rownum < 2;
        EXCEPTION
           WHEN OTHERS THEN
              NULL;
       END;

     end if;

     RETURN(invoice_posting_flag);
    END get_posting_status;

/*=============================================================================
 |  FUNCTION -  CHECK_UNIQUE
 |
 |  DESCRIPTION
 |      Check if the invoice number within one vendor is unique.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    PROCEDURE CHECK_UNIQUE (
                  X_ROWID             VARCHAR2,
                  X_INVOICE_NUM       VARCHAR2,
                  X_VENDOR_ID         NUMBER,
                  X_ORG_ID            NUMBER,   -- Bug 5407785
		  X_PARTY_SITE_ID     NUMBER, /*Bug9105666*/
	          X_VENDOR_SITE_ID    NUMBER, /*Bug9105666*/
                  X_calling_sequence  IN VARCHAR2) IS

      dummy_a number := 0;
      dummy_b number := 0;
      current_calling_sequence    VARCHAR2(2000);
      debug_info                  VARCHAR2(100);

    BEGIN

      current_calling_sequence := 'AP_INVOICES_UTILITY_PKG.CHECK_UNIQUE<-'||
                                  X_calling_sequence;

      debug_info := 'Count for same vendor_id,party_site_id and invoice_num'; /*Bug9105666*/

      select count(1)
      into   dummy_a
      from   ap_invoices_all
      where  invoice_num = X_INVOICE_NUM
      and    vendor_id = X_VENDOR_ID
      and    org_id    = X_ORG_ID   -- Bug 5407785
      AND (party_site_id = X_PARTY_SITE_ID /*Bug9105666*/
        OR (party_site_id is null and X_PARTY_SITE_ID is null)) /*Bug9105666*/
      and    ((X_ROWID is null) or (rowid <> X_ROWID));

      if (dummy_a >= 1) then
        fnd_message.set_name('SQLAP','AP_ALL_DUPLICATE_VALUE');
        app_exception.raise_exception;
      end if;

      debug_info := 'Count for same vendor_id,party_site_id invoice_num amount purged invoices'; /*Bug9105666*/

      select count(1)
      into   dummy_b
      from   ap_history_invoices_all ahi,
             ap_supplier_sites_all ass /*Bug9105666*/
      where ahi.vendor_id = ass.vendor_id /*Bug9105666*/
      and ahi.org_id = ass.org_id /*Bug9105666*/
      and ahi.invoice_num = X_INVOICE_NUM
      and ahi.vendor_id = X_VENDOR_ID   -- Bug 5407785
      and ahi.org_id    = X_ORG_ID
      AND (ass.party_site_id = X_PARTY_SITE_ID /*Bug9105666*/
      OR (ass.party_site_id is null and X_PARTY_SITE_ID is null)); /*Bug9105666*/

      if (dummy_b >= 1) then
        fnd_message.set_name('SQLAP','AP_ALL_DUPLICATE_VALUE');
        app_exception.raise_exception;
      end if;


    EXCEPTION
      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
              'X_Rowid = '      ||X_Rowid
          ||', X_INVOICE_NUM = '||X_INVOICE_NUM
          ||', X_VENDOR_ID = '  ||X_VENDOR_ID
                                    );
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
    end CHECK_UNIQUE;

/*=============================================================================
 |  procedure - CHECK_UNIQUE_VOUCHER_NUM
 |
 |  DESCRIPTION
 |      Check if the invoice number within one vendor is unique.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    PROCEDURE CHECK_UNIQUE_VOUCHER_NUM (
                  X_ROWID            VARCHAR2,
                  X_VOUCHER_NUM      VARCHAR2,
                  X_calling_sequence IN VARCHAR2) IS

      dummy number := 0;
      current_calling_sequence    VARCHAR2(2000);
      debug_info                  VARCHAR2(100);

    BEGIN

      current_calling_sequence := 'AP_INVOICES_PKG.CHECK_UNIQUE_VOUCHER_NUM<-'
                                  || X_calling_sequence;

      debug_info := 'Count other invoices with same voucher num';

      select count(1)
      into   dummy
      from   ap_invoices
      where  voucher_num = X_VOUCHER_NUM
      and    ((X_ROWID is null) or (rowid <> X_ROWID));

      IF (dummy >= 1) THEN
        fnd_message.set_name('SQLAP','AP_ALL_DUPLICATE_VALUE');
        app_exception.raise_exception;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                                current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
                                'X_Rowid = '      ||X_Rowid
                                ||', X_VOUCHER_NUM = '||X_VOUCHER_NUM);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;

    END CHECK_UNIQUE_VOUCHER_NUM;

/*=============================================================================
 |  FUNCTION - get_approval_status
 |
 |  DESCRIPTION
 |      returns the invoice approval status lookup code.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES
 |      Invoices -'APPROVED'
 |                'NEEDS REAPPROVAL'
 |                'NEVER APPROVED'
 |                 'CANCELLED'
 |
 |     Prepayments - 'AVAILABLE'
 |                   'CANCELLED'
 |                   'FULL'
 |                   'UNAPPROVED'
 |                   'UNPAID'
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_approval_status(
                 l_invoice_id               IN NUMBER,
                 l_invoice_amount           IN NUMBER,
                 l_payment_status_flag      IN VARCHAR2,
                 l_invoice_type_lookup_code IN VARCHAR2)
    RETURN VARCHAR2 IS

      invoice_approval_status       VARCHAR2(25);
      invoice_approval_flag         VARCHAR2(2);
      distribution_approval_flag    VARCHAR2(1);
      encumbrance_flag              VARCHAR2(1);
      invoice_holds                 NUMBER;
      cancelled_date                DATE;
      sum_distributions             NUMBER;
      dist_var_hold                 NUMBER;
      match_flag_cnt                NUMBER;
      self_match_flag_cnt           NUMBER; --Bug8223290
      l_validated_cnt               NUMBER;
      l_org_id                      FINANCIALS_SYSTEM_PARAMS_ALL.ORG_ID%TYPE;
      l_force_revalidation_flag     VARCHAR2(1);
      --Bugfix: 3854385
      l_dist_variance		    VARCHAR2(20) := 'DIST VARIANCE';
      l_line_variance		    VARCHAR2(20) := 'LINE VARIANCE';

       --9503673
      l_net_of_retainage_flag       VARCHAR2(1);
      l_retained_amt                NUMBER := 0;
         ---------------------------------------------------------------------
         -- Declare cursor to establish the invoice-level approval flag
         --
         -- The first select simply looks at the match status flag for the
         -- distributions.  The rest is to cover one specific case when some
         -- of the distributions are tested (T or A) and some are untested
         -- (NULL).  The status should be needs reapproval (N).
         --
         -- Bug 963755: Modified the approval_cursor below to select the records
         -- correctly.

         -- MOAC. Use the tables instead of the SO views in this function

      -- bug6822570, changed the cursor to fetch
      -- 'N', in place of NULL, as for match_status_flag
      -- NULL and 'N' are the same.

	-- bug 9078049 We will consider flag 'Z' for null values or new distributions
        -- Flag 'N' will only be used for modified distributions

      CURSOR approval_cursor IS
      SELECT nvl(match_status_flag, 'Z')
      FROM   ap_invoice_distributions_all
      WHERE  invoice_id = l_invoice_id
      UNION  --Bug8223290
      SELECT nvl(match_status_flag, 'Z')
      FROM   ap_self_Assessed_tax_dist_All
      WHERE  invoice_id = l_invoice_id;

    BEGIN

         ---------------------------------------------------------------------
         -- Get the encumbrance flag
         -- MOAC.  Included select from ap_invoices_all to get the org_id from
         --        the invoice_id since it is unique



      SELECT NVL(fsp.purch_encumbrance_flag,'N'),
             ai.org_id,
	     ai.force_revalidation_flag,
	     NVL(ai.net_of_retainage_flag,'N')  --9503673
      INTO encumbrance_flag,
           l_org_id,
	   l_force_revalidation_flag,
	   l_net_of_retainage_flag   --9503673
      FROM ap_invoices_all ai,
           financials_system_params_all fsp
      WHERE ai.invoice_id = l_invoice_id
      AND ai.set_of_books_id = fsp.set_of_books_id
      AND ai.org_id = fsp.org_id;

         ---------------------------------------------------------------------
         -- Get the number of holds for the invoice
         --
      SELECT count(*)
      INTO   invoice_holds
      FROM   ap_holds_all
      WHERE  invoice_id = l_invoice_id
      AND    release_lookup_code is NULL;

         ---------------------------------------------------------------------
         -- Bug 787373: Check if DIST VAR hold is placed on this invoice.
         -- DIST VAR is a special case because it could be placed
         -- when no distributions exist and in this case, the invoice
         -- status should be NEEDS REAPPROVAL.
         --
      --Bugfix:4539514, added line_variance to the WHERE clause
      SELECT count(*)
      INTO   dist_var_hold
      FROM   ap_holds_all
      WHERE  invoice_id = l_invoice_id
      AND    hold_lookup_code IN  (l_dist_variance, l_line_variance)
      AND    release_lookup_code is NULL;

         ---------------------------------------------------------------------
         -- If invoice is cancelled, return 'CANCELLED'.
         --
      SELECT ai.cancelled_date
      INTO   cancelled_date
      FROM   ap_invoices_all ai
      WHERE  ai.invoice_id = l_invoice_id;

      IF (cancelled_date IS NOT NULL) THEN
        RETURN('CANCELLED');
      END IF;

         ---------------------------------------------------------------------
         -- Bug 963755: Getting the count of distributions with
         -- match_status_flag not null. We will open the approval_cursor
         -- only if the count is more than 0.
         --
      SELECT count(*)
      INTO match_flag_cnt
      FROM ap_invoice_distributions_all aid
      WHERE aid.invoice_id = l_invoice_id
      AND aid.match_status_flag IS NOT NULL
      AND rownum < 2;

      SELECT count(*) --Bug8223290
      INTO self_match_flag_cnt
      FROM ap_self_assessed_tax_dist_all aid
      WHERE aid.invoice_id = l_invoice_id
      --AND aid.match_status_flag IS NOT NULL
      AND rownum < 2;

         ---------------------------------------------------------------------
         -- Establish the invoice-level approval flag
         --
         -- Use the following ordering sequence to determine the invoice-level
         -- approval flag:
	 --                     'Z' - Never Approved
         --                     'N' - Needs Reapproval
         --                     'T' - Tested
         --                     'A' - Approved
         --                     ''  - Never Approved (Old)
         --                     'NA'  - Never Approved (New per bug 6705321 - epajaril)
         --                             Handled the status 'NA' in the code (bug6822570)
         --                     'X' - No Distributions Exist! --666401
         --
         -- Initialize invoice-level approval flag
         --
      invoice_approval_flag := 'X';

     IF match_flag_cnt > 0 OR self_match_flag_cnt > 0 THEN --Bug8223290

        OPEN approval_cursor;

        LOOP
        FETCH approval_cursor INTO distribution_approval_flag;
        EXIT WHEN approval_cursor%NOTFOUND;

          -- bug6822570, changed the logic of the Invoice level
          -- approval status derivation, as there were a few
          -- cases failing with the previous approach

          IF (distribution_approval_flag = 'Z') THEN

               -- If the distribution approval_flag encountered
               -- is 'Z' (which is so, when the match_status_flag
               -- is NULL), we have the following options

               IF invoice_approval_flag IN ('NA','X') THEN

                    -- If the current status of the Invoice is
                    -- no distributions ('X') or Never Validated ('NA')
                    -- then mark the Invoice as never validated

                    invoice_approval_flag := 'NA';

               ELSIF invoice_approval_flag IN ('A','T','N') THEN

                   -- If the Invoice has been validated at least
                   -- once, or currently has a needs revalidation
                   -- status, then make it needs revalidation

                   invoice_approval_flag := 'N';

               END IF;
	       END IF;

	     -- bug 9078049 If the distribution approval_flag encountered
             -- is 'N' ( which means need revalidation )

	      IF (distribution_approval_flag = 'N') THEN

               invoice_approval_flag := 'N';


           ELSIF (distribution_approval_flag = 'T') THEN

                 -- If then the next distribution encountered is tested
                 -- then folowing are the options

                 IF invoice_approval_flag IN ('T','A','X') THEN

                    -- If currently the Invoice is Approved, or
                    -- Tested or this is the first distributionn then
                    -- mark the Invoice as tested

                   invoice_approval_flag := 'T';

                ELSIF invoice_approval_flag IN ('NA','N') THEN

                   -- If currently the Invoice is Never Approved
                   -- or at needs revalidation, then the Invoice
                   -- status should become needs revalidation

                   invoice_approval_flag := 'N';

                END IF;

           ELSIF (distribution_approval_flag = 'A') THEN

                 -- If the current distribution is approved,
                 -- then we have following options

                 IF invoice_approval_flag IN ('A', 'X') THEN

                    -- If currently the Invoice is approved or
                    -- the Invoice has no distributions then
                    -- Invoice status should become approved

                    invoice_approval_flag := 'A';

                 ELSIF invoice_approval_flag = 'T' THEN

                   -- If the current invoice status is tested
                   -- it should remain tested

                   invoice_approval_flag := 'T';

                 ELSIF invoice_approval_flag IN ('N','NA') THEN

                   -- If the current invoice status is Needs
                   -- Reapproval or Never Validated, then the status
                   -- should become Neeeds Reapproval

                   invoice_approval_flag := 'N';

                 END IF;

          END IF;

        END LOOP;

        CLOSE approval_cursor;
      END IF; -- end of match_flag_cnt

      --ETAX: Invwkb

      -- bug6822570, validated that the condition is correct for the present
      -- logic
      IF l_force_revalidation_flag = 'Y' THEN
         IF invoice_approval_flag NOT IN ('X','NA') THEN
	    invoice_approval_flag := 'N';
         ELSE
            IF match_flag_cnt > 0 THEN

               SELECT count(*)
                 INTO l_validated_cnt
                 FROM ap_invoice_distributions_all aid
                WHERE aid.invoice_id = l_invoice_id
                  AND aid.match_status_flag = 'N'
                  AND rownum < 2;

               IF l_validated_cnt > 0 THEN
                  invoice_approval_flag := 'N';
               END IF;

            END IF;
         END IF;
      END IF;


      --Bugfix:4745464, 4923489 (modified the IF condition)

        -- bug6822570
        -- Changed the condition since the Invoice Approval
        -- Flag would never be NULL, and this check is required
        -- only when the Invoice status is approved, and there
        -- is no dist var hold

	IF ((invoice_approval_flag IN  ('A', 'T')) AND
            (dist_var_hold = 0)) THEN

          BEGIN

           SELECT 'N'
           INTO invoice_approval_flag
           FROM ap_invoice_lines_all ail
           WHERE ail.invoice_id = l_invoice_id
           AND ail.amount <>
             ( SELECT NVL(SUM(NVL(aid.amount,0)),0)
      	       FROM ap_invoice_distributions_all aid
	       WHERE aid.invoice_id = ail.invoice_id
	       AND   aid.invoice_line_number = ail.line_number
	       --bugfix:4959567
               AND   ( aid.line_type_lookup_code <> 'RETAINAGE'
                        OR (ail.line_type_lookup_code = 'RETAINAGE RELEASE' AND
                            aid.line_type_lookup_code = 'RETAINAGE') )
               /*
	       AND   (ail.line_type_lookup_code <> 'ITEM'
	              OR (aid.line_type_lookup_code <> 'PREPAY'
	                  and aid.prepay_tax_parent_id IS  NULL)
                     )
               */
	       AND   (AIL.line_type_lookup_code NOT IN ('ITEM', 'RETAINAGE RELEASE')
                      OR (AIL.line_type_lookup_code IN ('ITEM', 'RETAINAGE RELEASE')
                          AND (AID.prepay_distribution_id IS NULL
                               OR (AID.prepay_distribution_id IS NOT NULL
                                   AND AID.line_type_lookup_code NOT IN ('PREPAY', 'REC_TAX', 'NONREC_TAX')))))
	       );

           EXCEPTION WHEN OTHERS THEN
              NULL;
           END;

         END IF;

        -- bug6047348
        -- Changed this condition also same as the above

        IF ((invoice_approval_flag in ('A', 'T')) AND
            (dist_var_hold = 0))  THEN

          BEGIN

	   SELECT 'N'
           INTO   invoice_approval_flag
           FROM   ap_invoice_lines_all AIL, ap_invoices_all A
           WHERE  AIL.invoice_id = A.invoice_id
           AND    AIL.invoice_id = l_invoice_id
           AND    ((AIL.line_type_lookup_code <> 'TAX'
                   and (AIL.line_type_lookup_code NOT IN ('AWT','PREPAY')
                        or NVL(AIL.invoice_includes_prepay_flag,'N') = 'Y') OR
                  (AIL.line_type_lookup_code = 'TAX'
                  /* bug 5222316 */
                   and (AIL.prepay_invoice_id IS NULL
                        or (AIL.prepay_invoice_id is not null
                            and NVL(AIL.invoice_includes_prepay_flag, 'N') = 'Y')))))
               --    and AIL.prepay_invoice_id IS NULL)))
           GROUP BY A.invoice_id, A.invoice_amount, A.net_of_retainage_flag
           HAVING A.invoice_amount <>
                  nvl(SUM(nvl(AIL.amount,0) + decode(A.net_of_retainage_flag,
                                 'Y', nvl(AIL.retained_amount,0),0)),0);

           EXCEPTION WHEN OTHERS THEN
              NULL;
           END;

         END IF;


         ---------------------------------------------------------------------
         -- Bug 719322: Bug 719322 was created by the fix to bug 594189. Re-fix
         -- for bug 594189 would fix bug 719322.

         -- Re-fix for bug 594189
         -- With encumbrance on, if after an invoice has been approved, the
         -- user changes the invoice amount, then the invoice amount would
         -- no longer match the sum of the distribution amounts. In this case,
         -- the status should go to 'NEEDS REAPPROVAL'.

         -- eTax Uptake.  Use of prepay_distribution_id to determine
         -- if the REC_TAX and NONREC_TAX distribution are related
         -- to the prepayment application and should be included in the
         -- total of the distributions if the invoice_includes_prepay_flag is
         -- Y.  Included ap_invoice_lines_all in select since the flag
         -- at the dist level is obsolete.

      IF (encumbrance_flag = 'Y') AND (invoice_approval_flag = 'A') THEN

         SELECT NVL(SUM(nvl(aid.amount,0)), 0)
           INTO sum_distributions
           FROM ap_invoice_distributions_all aid,
                ap_invoice_lines_all ail
          WHERE ail.invoice_id = l_invoice_id
            AND aid.invoice_id = ail.invoice_id
            AND aid.invoice_line_number = ail.line_number
            AND (aid.line_type_lookup_code <> 'RETAINAGE'
                 OR (ail.line_type_lookup_code = 'RETAINAGE RELEASE'
                     and aid.line_type_lookup_code = 'RETAINAGE') )
            AND ((aid.line_type_lookup_code NOT IN ('AWT','PREPAY')
                  AND aid.prepay_distribution_id IS NULL)
                OR NVL(ail.invoice_includes_prepay_flag,'N') = 'Y');

          --Start 9503673
             IF l_net_of_retainage_flag = 'Y' THEN
                l_retained_amt := ABS(AP_INVOICES_UTILITY_PKG.Get_retained_Total(
                                                    l_invoice_id,l_org_id));
             END IF;
          --End 9503673

        --Introduces l_retained_amt in below IF clause for bug#9503673
        IF (l_invoice_amount + l_retained_amt <> sum_distributions) THEN
          invoice_approval_flag := 'N';
        END IF;
      END IF;  -- end of check encumbrance_flag

         ---------------------------------------------------------------------
         -- Derive the translated approval status from the approval flag
         --
      IF (encumbrance_flag = 'Y') THEN

        IF (invoice_approval_flag = 'A' AND invoice_holds = 0) THEN
          invoice_approval_status := 'APPROVED';
        ELSIF ((invoice_approval_flag in ('A') AND invoice_holds > 0)
               OR (invoice_approval_flag IN ('T','N'))) THEN
          invoice_approval_status := 'NEEDS REAPPROVAL';
        ELSIF (dist_var_hold >= 1) THEN
                 --It's assumed here that the user won't place this hold
                 --manually before approving.  If he does, status will be
                 --NEEDS REAPPROVAL.  dist_var_hold can result when there
                 --are no distributions or there are but amounts don't
                 --match.  It can also happen when an invoice is created with
                 --no distributions, then approve the invoice, then create the
                 --distribution.  So, in this case, although the match flag
                 --is null, we still want to see the status as NEEDS REAPPR.
          invoice_approval_status := 'NEEDS REAPPROVAL';
        -- bug6822570, removed the condition for the Invoice Approval flag
        -- being NULL, and added the condition for 'NA'
        ELSIF (invoice_approval_flag IN ('X','NA') AND dist_var_hold = 0) THEN
            invoice_approval_status := 'NEVER APPROVED';
        END IF;

      ELSIF (encumbrance_flag = 'N') THEN
        IF (invoice_approval_flag IN ('A','T') AND invoice_holds = 0) THEN
          invoice_approval_status := 'APPROVED';
        ELSIF ((invoice_approval_flag IN ('A','T') AND invoice_holds > 0) OR
               (invoice_approval_flag = 'N')) THEN
          invoice_approval_status := 'NEEDS REAPPROVAL';
        ELSIF (dist_var_hold >= 1) THEN
          invoice_approval_status := 'NEEDS REAPPROVAL';
        -- bug6822570, removed the condition for the invoice approval flag
        -- being NULL, and added the condition for 'NA'
        ELSIF (invoice_approval_flag IN ('X','NA') AND dist_var_hold = 0) THEN
                 -- Bug 787373: A NULL flag indicate that APPROVAL has not
                 -- been run for this invoice, therefore, even if manual
                 -- holds exist, status should be NEVER APPROVED.
          invoice_approval_status := 'NEVER APPROVED';
        END IF;
      END IF;

         ---------------------------------------------------------------------
         -- If this a prepayment, find the appropriate prepayment status
         --
      if (l_invoice_type_lookup_code = 'PREPAYMENT') then
        if (invoice_approval_status = 'APPROVED') then
          if (NVL(l_payment_status_flag , 'N') <> 'Y') then --bug6598052
            invoice_approval_status := 'UNPAID';
          else
            -- This prepayment is paid
            if (AP_INVOICES_UTILITY_PKG.get_prepay_amount_remaining(l_invoice_id) = 0) then
              invoice_approval_status := 'FULL';
            elsif (AP_INVOICES_UTILITY_PKG.get_prepayment_type(l_invoice_id) = 'PERMANENT') THEN
              invoice_approval_status := 'PERMANENT';
            else
              invoice_approval_status := 'AVAILABLE';
            end if; -- end of check AP_INVOICES_UTILITY_PKG call
          end if; -- end of check l_payment_status_flag
        elsif (invoice_approval_status = 'NEVER APPROVED') then
             -- This prepayment in unapproved
          invoice_approval_status := 'UNAPPROVED';
        end if; -- end of invoice_approval_status
      end if; -- end of l_invoice_type_lookup_code

      RETURN(invoice_approval_status);
    END get_approval_status;


/*===========================================================================
 |  FUNCTION - get_po_number
 |
 |  DESCRIPTION
 |      returns the PO number matched to invoice, or
 |      with. the 'UNMATCHED' lookup code if not matched, or the
 |      'ANY MULTIPLE'lookup code if matched to multiple POs.
 |      Because of Lines project, price correction, quantity correction should
 |      be taken into account on top op base match. The logic is based on the
 |      following assumptions:
 |        1. po_header_id and po_line_location_id are populated for both
 |           receipt matching and po matching
 |        2. it does not take CHARGES_TO_RECEIPT match type into account.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |      Bug# 450052: Added GROUP BY and HAVING clauses to make sure that
 |      if all distributions matched to a PO have been reversed, it is not
 |      considered matched
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/

    FUNCTION get_po_number(l_invoice_id IN NUMBER)
    RETURN VARCHAR2 IS
      po_number VARCHAR2(50) := 'UNMATCHED'; -- for CLM Bug 9503239
      l_line_matched_amount  NUMBER;
      l_po_header_id NUMBER;
      l_corrected_amount NUMBER;
      l_invoice_type ap_invoices_all.invoice_type_lookup_code%TYPE; --7550789

     /* Bug 4669905. Modified the Cursor */
      CURSOR po_number_cursor IS
      SELECT DISTINCT NVL(ph.CLM_DOCUMENT_NUMBER , ph.segment1), ph.po_header_id,  -- for CLM Bug 9503239
             NVL(SUM(L.amount),0)
      FROM   ap_invoice_lines_all L,
             po_headers PH
      WHERE  L.invoice_id = l_invoice_id
      AND    L.po_header_id = PH.po_header_id
      AND    L.match_type IN ( 'PRICE_CORRECTION', 'QTY_CORRECTION',
                               'ITEM_TO_PO', 'ITEM_TO_RECEIPT', 'AMOUNT_CORRECTION',
                               'RETRO PRICE ADJUSTMENT','ITEM_TO_SERVICE_PO','ITEM_TO_SERVICE_RECEIPT')  --Bug6931134
			       --added ITEM_TO_SERVICE_RECEIPT in bug 8891266
      AND    NVL (L.discarded_flag, 'N' ) <> 'Y'
      AND    NVL (L.cancelled_flag, 'N' ) <> 'Y'
      GROUP BY PH.po_header_id, NVL(ph.CLM_DOCUMENT_NUMBER , ph.segment1)      -- for CLM Bug 9503239
      HAVING ( NVL(SUM(L.amount), 0) <> 0 OR
               NVL(SUM(L.quantity_invoiced), 0) <> 0);

    BEGIN

      OPEN po_number_cursor;
      LOOP
      FETCH po_number_cursor
      INTO  po_number, l_po_header_id,
            l_line_matched_amount;
      EXIT WHEN po_number_cursor%NOTFOUND;

	--Added below Select for bug 7550789

      SELECT invoice_type_lookup_code
      INTO   l_invoice_type
      FROM   ap_invoices_all
      WHERE  invoice_id=l_invoice_id;

        IF (po_number_cursor%ROWCOUNT > 1) THEN
          po_number := 'ANY MULTIPLE';
          EXIT;
        ELSE  /* Bug 4669905 */
          SELECT NVL(SUM(AIL.amount), 0)
          INTO   l_corrected_amount
          FROM   ap_invoice_lines_all AIL
          WHERE  corrected_inv_id = l_invoice_id
          AND    po_header_id = l_po_header_id
          AND    NVL( AIL.discarded_flag, 'N' ) <> 'Y'
          AND    NVL( AIL.cancelled_flag, 'N' ) <> 'Y' ;

        IF l_invoice_type IN ('CREDIT','DEBIT') THEN                            --bug7550789
          IF ((-1)*l_corrected_amount >= (-1)*l_line_matched_amount) THEN
            po_number := 'UNMATCHED';
          END IF;
        ELSE
          IF ((-1)*l_corrected_amount >= l_line_matched_amount) THEN
            po_number := 'UNMATCHED';
          END IF;
	END IF;                                                                 --bug7550789
        END IF;
      END LOOP;
      CLOSE po_number_cursor;

      RETURN(po_number);

    END get_po_number;

/*=============================================================================
 |  FUNCTION - get_release_number
 |
 |  DESCRIPTION
 |      returns the release number matched to invoice  for a BLANKET PO, or
 |      the 'UNMATCHED' lookup code if not matched or matched to a combination
 |      of BLANKET/NON-BLANKET POs, or the 'ANY MULTIPLE' lookup code if
 |      matched to multiple POs (all of which must be BLANKET).
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_release_number(l_invoice_id IN NUMBER)
    RETURN VARCHAR2 IS
      po_release_number VARCHAR2(25) := 'UNMATCHED';
      l_shipment_type   po_line_locations.shipment_type%TYPE;

      CURSOR po_shipment_type_cursor IS
      SELECT DISTINCT(pll.shipment_type)
      FROM   ap_invoice_lines L,
             po_line_locations PLL
      WHERE  L.invoice_id = l_invoice_id
      AND   NOT EXISTS (SELECT  AIL.corrected_inv_id
                          FROM  ap_invoice_lines AIL
                         WHERE NVL( AIL.discarded_flag, 'N' ) <> 'Y'
                           AND NVL( AIL.cancelled_flag, 'N' ) <> 'Y'
                           AND  AIL.corrected_inv_id =  L.invoice_id)
      AND    L.po_line_location_id = PLL.line_location_id
      AND    L.match_type IN ( 'PRICE_CORRECTION', 'QTY_CORRECTION',
                               'ITEM_TO_PO', 'ITEM_TO_RECEIPT',
                               'RETRO PRICE ADJUSTMENT')
/*
5000309 fbreslin: exclude line if discared or cancled
*/
      AND    NVL (L.discarded_flag, 'N' ) <> 'Y'
      AND    NVL (L.cancelled_flag, 'N' ) <> 'Y'
      GROUP BY PLL.shipment_type
      HAVING ( NVL(SUM(L.amount), 0) <> 0 OR
               NVL(SUM(L.quantity_invoiced), 0) <> 0);


      CURSOR po_release_number_cursor IS
      SELECT DISTINCT(PRL.release_num)
      FROM ap_invoice_lines L,
           po_line_locations PLL,
           po_releases PRL
      WHERE  L.invoice_id = l_invoice_id
      AND NOT EXISTS (SELECT  AIL.corrected_inv_id
                          FROM  ap_invoice_lines AIL
                         WHERE NVL( AIL.discarded_flag, 'N' ) <> 'Y'
                           AND NVL( AIL.cancelled_flag, 'N' ) <> 'Y'
                           AND  AIL.corrected_inv_id =  L.invoice_id)
      AND    L.po_line_location_id = PLL.line_location_id
      AND    L.match_type IN ( 'PRICE_CORRECTION', 'QTY_CORRECTION',
                               'ITEM_TO_PO', 'ITEM_TO_RECEIPT',
                                'RETRO PRICE ADJUSTMENT')
/*
5000309 fbreslin: exclude line if discared or cancled
*/
      AND    NVL (L.discarded_flag, 'N' ) <> 'Y'
      AND    NVL (L.cancelled_flag, 'N' ) <> 'Y'
      AND   PRL.po_release_id = PLL.po_release_id
      GROUP BY PRL.release_num
      HAVING ( NVL(SUM(L.amount), 0) <> 0 OR
               NVL(SUM(L.quantity_invoiced), 0) <> 0);

    BEGIN

      OPEN po_shipment_type_cursor;
      LOOP
      FETCH po_shipment_type_cursor INTO l_shipment_type;
      EXIT WHEN po_shipment_type_cursor%NOTFOUND;

        IF (po_shipment_type_cursor%ROWCOUNT > 1) THEN
          po_release_number := NULL;
          EXIT;
        END IF;
      END LOOP;
      CLOSE po_shipment_type_cursor;

      if (po_release_number is not NULL) then
        OPEN po_release_number_cursor;
        LOOP
        FETCH po_release_number_cursor INTO po_release_number;
        EXIT WHEN po_release_number_cursor%NOTFOUND;
          IF (po_release_number_cursor%ROWCOUNT > 1) THEN
            po_release_number := 'ANY MULTIPLE';
            EXIT;
          END IF;
        END LOOP;
        CLOSE po_release_number_cursor;
      else
        po_release_number := 'UNMATCHED';
      end if;

      RETURN(po_release_number);

    END get_release_number;

/*=============================================================================
 |  FUNCTION - get_receipt_number
 |
 |  DESCRIPTION
 |      returns the receipt number matched to invoice, or the 'UNMATCHED'
 |      lookup code if not matched, or the 'ANY MULTIPLE' lookup code if
 |      matched to multiple receipts.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_receipt_number(l_invoice_id IN NUMBER)
    RETURN VARCHAR2 IS
      receipt_number VARCHAR2(25) := 'UNMATCHED';

      CURSOR receipt_number_cursor IS
      SELECT DISTINCT(rsh.receipt_num)
      FROM   ap_invoice_lines L,
             rcv_transactions RTXN,
             rcv_shipment_headers RSH
      WHERE  L.invoice_id = l_invoice_id
      AND NOT EXISTS (SELECT  AIL.corrected_inv_id
                          FROM  ap_invoice_lines AIL
                         WHERE NVL( AIL.discarded_flag, 'N' ) <> 'Y'
                           AND NVL( AIL.cancelled_flag, 'N' ) <> 'Y'
                           AND  AIL.corrected_inv_id =  L.invoice_id)
      AND    L.rcv_transaction_id = RTXN.transaction_id
      AND    RSH.shipment_header_id = RTXN.shipment_header_id
      AND    L.match_type IN ( 'PRICE_CORRECTION', 'QTY_CORRECTION',
                               'ITEM_TO_RECEIPT',
                               'RETRO PRICE ADJUSTMENT')
/*
5000309 fbreslin: exclude line if discared or cancled
*/
      AND    NVL (L.discarded_flag, 'N' ) <> 'Y'
      AND    NVL (L.cancelled_flag, 'N' ) <> 'Y'
      GROUP BY rsh.shipment_header_id, rsh.receipt_num
      HAVING ( NVL(SUM(L.amount), 0) <> 0 OR
               NVL(SUM(L.quantity_invoiced), 0) <> 0);

    BEGIN

      OPEN receipt_number_cursor;
      LOOP
      FETCH receipt_number_cursor INTO receipt_number;
      EXIT WHEN receipt_number_cursor%NOTFOUND;

        IF (receipt_number_cursor%ROWCOUNT > 1) THEN
          receipt_number := 'ANY MULTIPLE';
          EXIT;
        END IF;

      END LOOP;
      CLOSE receipt_number_cursor;

      RETURN(receipt_number);
    END get_receipt_number;

/*=============================================================================
 |  FUNCTION -  get_po_number_list
 |
 |  DESCRIPTION
 |      returns all the PO Numbers matched to this invoice (comma delimited)
 |      or NULL if not matched.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |      Bug# 450052: Added GROUP BY and HAVING clauses to make sure that
 |      if all distributions matched to a PO have been reversed, it is not
 |      considered matched
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_po_number_list(l_invoice_id IN NUMBER)
    RETURN VARCHAR2 IS
      po_number      VARCHAR2(50); -- for CLM Bug 9503239
      po_number_list VARCHAR2(5000) := NULL; -- for CLM Bug 9503239

     CURSOR po_number_cursor IS
      SELECT DISTINCT(NVL(ph.CLM_DOCUMENT_NUMBER , ph.segment1)) -- for CLM Bug 9503239
      FROM   ap_invoice_lines L,
             po_headers PH
      WHERE  L.invoice_id = l_invoice_id
      AND   NOT EXISTS (SELECT  AIL.corrected_inv_id
                          FROM  ap_invoice_lines AIL
                         WHERE NVL( AIL.discarded_flag, 'N' ) <> 'Y'
                           AND NVL( AIL.cancelled_flag, 'N' ) <> 'Y'
                           AND  AIL.corrected_inv_id =  L.invoice_id)
      AND    L.po_header_id = PH.po_header_id
      AND    L.match_type IN ( 'PRICE_CORRECTION', 'QTY_CORRECTION',
                               'ITEM_TO_PO', 'ITEM_TO_RECEIPT',
                               'RETRO PRICE ADJUSTMENT')
/*
5000309 fbreslin: exclude line if discared or cancled
*/
      AND    NVL (L.discarded_flag, 'N' ) <> 'Y'
      AND    NVL (L.cancelled_flag, 'N' ) <> 'Y'
      GROUP BY PH.po_header_id, NVL(ph.CLM_DOCUMENT_NUMBER , ph.segment1) -- for CLM Bug 9503239
      HAVING ( NVL(SUM(L.amount), 0) <> 0 OR
               NVL(SUM(L.quantity_invoiced), 0) <> 0);

    BEGIN

      OPEN po_number_cursor;
      LOOP
      FETCH po_number_cursor INTO po_number;
      EXIT WHEN po_number_cursor%NOTFOUND;
        IF (po_number_list IS NOT NULL) THEN
          po_number_list := po_number_list || ', ';
        END IF;
        po_number_list := po_number_list || po_number;

      END LOOP;
      CLOSE po_number_cursor;

      RETURN(po_number_list);

    END get_po_number_list;

/*=============================================================================
 |  FUNCTION -  get_amount_withheld
 |
 |  DESCRIPTION
 |      returns the AWT withheld amount on an invoice.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_amount_withheld(l_invoice_id IN NUMBER)
    RETURN NUMBER IS
      amount_withheld           NUMBER := 0;
    BEGIN

      select (0 - sum(nvl(amount,0)))
      into   amount_withheld
      from   ap_invoice_distributions
      where  invoice_id = l_invoice_id
      and    line_type_lookup_code = 'AWT';

      return(amount_withheld);

    END get_amount_withheld;

/*=============================================================================
 |  FUNCTION -  get_prepaid_amount
 |
 |  DESCRIPTION
 |      rreturns the prepayment amount on on an invoice.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_prepaid_amount(l_invoice_id IN NUMBER)
    RETURN NUMBER IS
      l_prepaid_amount           NUMBER := 0;
    BEGIN
      -- eTax Uptake.  This function maybe obsolete in the future, but for
      -- now it should be consistent.  Use the ap_prepay_utils_pkg API.

      l_prepaid_amount := ap_prepay_utils_pkg.get_prepaid_amount(l_invoice_id);

     return(l_prepaid_amount);

    END get_prepaid_amount;


/*=============================================================================
 |  FUNCTION -  get_notes_count
 |
 |  DESCRIPTION
 |      returns the number of notes associated with an invoice
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_notes_count(l_invoice_id IN NUMBER)
    RETURN NUMBER IS
      notes_count           NUMBER := 0;
    BEGIN

      SELECT COUNT(*)
      INTO   notes_count
      FROM   po_note_references
      WHERE  table_name = 'AP_INVOICES'
      AND    foreign_id = l_invoice_id;

      return(notes_count);

    END get_notes_count;

/*=============================================================================
 |  FUNCTION -  get_holds_count
 |
 |  DESCRIPTION
 |      returns the number of unreleased holds placed on an invoice.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_holds_count(l_invoice_id IN NUMBER)
    RETURN NUMBER
    IS
      holds_count           NUMBER := 0;
    BEGIN

      SELECT COUNT(*)
      INTO   holds_count
      FROM   ap_holds
      WHERE  release_lookup_code is null
      AND    invoice_id = l_invoice_id;

      RETURN (holds_count);

    END get_holds_count;

/*=============================================================================
 |  FUNCTION -  get_sched_holds_count
 |
 |  DESCRIPTION
 |      returns the number of unreleased holds placed on an payment schedules.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_sched_holds_count(l_invoice_id IN NUMBER)
    RETURN NUMBER
    IS
      holds_count           NUMBER := 0;
    BEGIN

      SELECT COUNT(*)
      INTO   holds_count
      FROM   ap_payment_schedules_all
      WHERE  hold_flag = 'Y'
      AND    invoice_id = l_invoice_id;

      RETURN (holds_count);

    END get_sched_holds_count;

/*=============================================================================
 |  FUNCTION -  get_total_prepays
 |
 |  DESCRIPTION
 |      returns the total number of prepayments that exist for a vendor
 |      (not fully applied, not permanent).We've declared a server-side
 |      function that can be accessed from our invoices view so as to improve
 |      performance when retrieving invoices in the Invoice Gateway.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_total_prepays(
                 l_vendor_id    IN NUMBER,
                 l_org_id       IN NUMBER)
    RETURN NUMBER
    IS
      prepay_count           NUMBER := 0;
    BEGIN

      SELECT  COUNT(*)
      INTO   prepay_count
      FROM   ap_invoices ai
      WHERE  vendor_id = l_vendor_id
      AND    (( l_org_id IS NOT NULL AND
                ai.org_id = l_org_id)
             OR l_org_id IS NULL)
      AND    invoice_type_lookup_code = 'PREPAYMENT'
      AND    earliest_settlement_date IS NOT NULL
      AND    AP_INVOICES_UTILITY_PKG.get_prepay_amount_remaining(ai.invoice_id) > 0;

         RETURN(prepay_count);

     END get_total_prepays;

/*=============================================================================
 |  FUNCTION -  get_available_prepays
 |
 |  DESCRIPTION
 |      returns the number of available prepayments to a vendor which can be
 |      applied. We've declared a server-side function that can be accessed
 |      from our invoices view so as to improve performance when retrieving
 |      invoices in the Invoice Gateway.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 | 09-JAN-06     KGURUMUR           Made changes for improving performance
 *============================================================================*/

    FUNCTION get_available_prepays(
                 l_vendor_id    IN NUMBER,
                 l_org_id       IN NUMBER)
    RETURN NUMBER
    IS
      prepay_count           NUMBER := 0;
      l_prepay_amount_remaining NUMBER:=0;
         /*Bug4579216
           Replaced the existing logic with a cursor defined for the same
           which just selects the prepayment invoices for the vendor.This
           is done for performance overheads.The comparison of earliest
           settlement date would be done with the cursor variable,also the
           earlier select statement which would call the get_total_prepays
           as a filter is removed and logic is implemented here as this                    would reduce the wait time*/
         CURSOR prepayment_invoices IS
         SELECT earliest_settlement_date,invoice_id
         from
         ap_invoices
         where vendor_id=l_vendor_id
         and invoice_type_lookup_code='PREPAYMENT'
         /*7015402*/
         and payment_status_flag = 'Y'
         and earliest_settlement_date is not null
         AND    (( l_org_id IS NOT NULL AND
                   org_id = l_org_id)
                   OR l_org_id IS NULL);

     BEGIN
         /*Bug 4579216*/
         for i in prepayment_invoices
         loop
          if(i.earliest_settlement_date<=(sysdate)) then
             l_prepay_amount_remaining:=0;
             l_prepay_amount_remaining:=
             AP_INVOICES_UTILITY_PKG.get_prepay_amount_remaining(i.invoice_id);
             if(l_prepay_amount_remaining>0) then
                    prepay_count:=prepay_count+1;
             end if;
          end if;
         end loop;
         return(prepay_count);

END get_available_prepays;

/*=============================================================================
 |  FUNCTION - get_encumbered_flag()
 |
 |  DESCRIPTION
 |      returns the invoice-level encumbrance status of an invoice.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 | ---------------------------------------------------------------------
 |      -- Establish the invoice-level encumbrance flag.
 |      -- Function will return one of the following statuses
 |      --
 |      --                     'Y' - Fully encumbered
 |      --                     'P' - One or more distributions is
 |      --                           encumbered, but not all
 |      --                     'N' - No distributions are encumbered
 |      --                     ''  - Budgetary control disabled
 |      --
 |  ---------------------------------------------------------------------
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

    FUNCTION get_encumbered_flag(l_invoice_id IN NUMBER)
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
      WHERE  invoice_id = l_invoice_id;

      /*7388641 - Checking encumbrance for invoice having just self
        assessed tax distributions, not a normal distributions and
	encumbrance is enabled */

      CURSOR encumb_flag_in_self_tax_cursor is
      SELECT nvl(encumbered_flag,'N')
      FROM   ap_self_assessed_tax_dist
      WHERE  invoice_id = l_invoice_id;

    BEGIN

      SELECT NVL(fsp.purch_encumbrance_flag,'N'), ai.org_id
        INTO l_purch_encumbrance_flag, l_org_id
        FROM ap_invoices_all ai,
             financials_system_params_all fsp
       WHERE ai.invoice_id = l_invoice_id
         AND ai.org_id = fsp.org_id;

      IF (l_purch_encumbrance_flag = 'N') THEN
        RETURN('');
      END IF;

      OPEN encumbrance_flag_cursor;
      LOOP
      FETCH encumbrance_flag_cursor INTO l_encumbered_flag;
      EXIT WHEN encumbrance_flag_cursor%NOTFOUND;
        IF (l_encumbered_flag in ('Y','D','W','X')) THEN
          l_encumbered_count := l_encumbered_count + 1;
        END IF;
          l_distribution_count := l_distribution_count + 1;
      END LOOP;

      /*7388641   Taking the count of encumbrance distributions
        if self assed tax distributions exists for invoice */
      OPEN encumb_flag_in_self_tax_cursor;
      LOOP
         FETCH encumb_flag_in_self_tax_cursor INTO l_encumbered_flag;
         EXIT WHEN encumb_flag_in_self_tax_cursor%NOTFOUND;
            IF (l_encumbered_flag in ('Y','D','W','X')) THEN
              l_encumbered_count := l_encumbered_count + 1;
            END IF;
            l_distribution_count := l_distribution_count + 1;
      END LOOP;

      --End of 7388641

      IF (l_encumbered_count > 0) THEN
        -- At least one distribution is encumbered
        IF (l_distribution_count = l_encumbered_count) THEN
          -- Invoice is fully encumbered
          RETURN('Y');
        ELSE
          -- Invoice is partially encumbered
          RETURN('P');
        END IF;
      ELSE
        -- No distributions are encumbered
        RETURN('N');
      END IF;

     END get_encumbered_flag;

/*=============================================================================
 |  FUNCTION - get_amount_hold_flag
 |
 |  DESCRIPTION
 |      returns a flag designating whether an invoice has unreleased amounts
 |      holds We've declared a server-side function that can be accessed from
 |      our invoices view so as to improve performance when retrieving invoices
 |      in the Invoice Gateway.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_amount_hold_flag(l_invoice_id IN NUMBER)
    RETURN VARCHAR2
    IS
      l_amount_hold_flag  VARCHAR2(1) := 'N';
      --Bugfix:3854385
      l_amount	VARCHAR2(10) := 'AMOUNT';

      cursor amount_hold_flag_cursor is
      SELECT 'Y'
        FROM ap_holds
       WHERE invoice_id = l_invoice_id
         AND hold_lookup_code = l_amount
         AND release_lookup_code IS NULL;

    BEGIN

      OPEN amount_hold_flag_cursor;
      FETCH amount_hold_flag_cursor INTO l_amount_hold_flag;
      CLOSE amount_hold_flag_cursor;

      RETURN (l_amount_hold_flag);

    END get_amount_hold_flag;

/*=============================================================================
 |  FUNCTION - get_vendor_hold_flag
 |
 |  DESCRIPTION
 |      returns a flag designating whether an invoice has unreleased vendor
 |      holds We've declared a server-side function that can be accessed from
 |      our invoices view so as to improve performance when retrieving invoices
 |      in the Invoice Gateway.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/
    FUNCTION get_vendor_hold_flag(l_invoice_id IN NUMBER)
    RETURN VARCHAR2
    IS
      --Bugfix: 3854385
      l_vendor	varchar2(20) := 'VENDOR';
      l_vendor_hold_flag  VARCHAR2(1) := 'N';

      cursor vendor_hold_flag_cursor is
      SELECT 'Y'
        FROM ap_holds
       WHERE invoice_id = l_invoice_id
         AND hold_lookup_code = l_vendor
         AND release_lookup_code IS NULL;

    BEGIN
      OPEN vendor_hold_flag_cursor;
      FETCH vendor_hold_flag_cursor INTO l_vendor_hold_flag;
      CLOSE vendor_hold_flag_cursor;

      RETURN (l_vendor_hold_flag);

    END get_vendor_hold_flag;

/*=============================================================================
 |  FUNCTION - get_similar_drcr_memo
 |
 |  DESCRIPTION
 |      returns the invoice_num of an credit/debit memo that has the same
 |      vendor, vendor_site, currency, and amount as the debit/credit memo
 |      being validated. If this is a CREDIT then look for a similar DEBIT memo
 |      If this is a DEBIT then look for a similar CREDIT memo. This is to try
 |      and catch the case when the user enters a DEBIT for some returned
 |      goods and then the vendor sends a DEBIT memo for the same return
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_similar_drcr_memo(
                 P_vendor_id                IN number,
                 P_vendor_site_id           IN number,
                 P_invoice_amount           IN number,
                 P_invoice_type_lookup_code IN varchar2,
                 P_invoice_currency_code    IN varchar2,
                 P_calling_sequence         IN varchar2) RETURN varchar2
    IS
      CURSOR similar_memo_cursor IS
      SELECT invoice_num
        FROM ap_invoices
       WHERE vendor_id = P_vendor_id
         AND vendor_site_id = P_vendor_site_id
         AND invoice_amount = P_invoice_amount
         AND invoice_currency_code = P_invoice_currency_code
         AND invoice_type_lookup_code =
                 DECODE(P_invoice_type_lookup_code,
                        'CREDIT','DEBIT',
                        'DEBIT','CREDIT');

      l_invoice_num               ap_invoices.invoice_num%TYPE;
      current_calling_sequence    VARCHAR2(2000);
      debug_info                  VARCHAR2(100);

    BEGIN

      current_calling_sequence := 'AP_INVOICES_PKG.get_similar_drcr_memo<-'||
                                   P_calling_sequence;

      debug_info := 'Open cursor similar_memo_cursor';

      OPEN similar_memo_cursor;
      FETCH similar_memo_cursor
       INTO l_invoice_num;

      debug_info := 'Close cursor similar_memo_cursor';

      CLOSE similar_memo_cursor;

      RETURN(l_invoice_num);

    EXCEPTION
      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
              'P_vendor_id = '                 ||P_vendor_id
            ||', P_vendor_site_id = '          ||P_vendor_site_id
            ||', P_invoice_amount = '          ||P_invoice_amount
            ||', P_invoice_type_lookup_code = '||P_invoice_type_lookup_code
            ||', P_invoice_currency_code = '   ||P_invoice_currency_code
                                    );
           FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;
    END get_similar_drcr_memo;

/*=============================================================================
 |  FUNCTION - eft_bank_details_exist
 |
 |  DESCRIPTION
 |      returns TRUE if the bank details needed for payment method EFT are
 |      present for a particular vendor site. Function returns FALSE otherwise.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION eft_bank_details_exist (
                 P_vendor_site_id   IN number,
                 P_calling_sequence IN varchar2) RETURN boolean
    IS

      l_vendor_id    number;
      l_ext_bank_acct_id number;
      current_calling_sequence    VARCHAR2(2000);
      debug_info                  VARCHAR2(100);

    BEGIN

      current_calling_sequence := 'AP_INVOICES_Utility_PKG.eft_bank_details_exist<-'||
                                  P_calling_sequence;

      debug_info := 'Call AP IBY API';

      SELECT vendor_id
      INTO l_vendor_id
      FROM PO_VENDOR_SITES_ALL
      WHERE vendor_site_id = P_vendor_site_id;

      l_ext_bank_acct_id := AP_IBY_UTILITY_PKG.Get_Default_Iby_Bank_Acct_Id
                           (x_vendor_id => l_vendor_id,
                            x_vendor_site_id =>  p_vendor_site_id,
                            x_payment_function => NULL,
                            x_org_id => NULL,
                            x_currency_code => NULL,
                            x_calling_sequence => 'Ap_Invoices_Utility_Pkg');

      IF l_ext_bank_acct_id IS NOT NULL THEN
        RETURN True;
      ELSE
        RETURN False;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
            'P_vendor_site_id = '||P_vendor_site_id);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;
    END eft_bank_details_exist;

/*=============================================================================
 |  FUNCTION - eft_bank_curr_details_exist
 |
 |  DESCRIPTION
 |      returns TRUE if the bank details (including the matching currency code)
 |      needed for payment method EFT are present for a particular vendor
 |      site. Function returns FALSE otherwise.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION eft_bank_curr_details_exist (
                 P_vendor_site_id   IN number,
                 P_currency_code    IN varchar2,
                 P_calling_sequence IN varchar2) RETURN boolean
    IS

      l_vendor_id    number;
      l_ext_bank_acct_id number;
      current_calling_sequence    VARCHAR2(2000);
      debug_info                  VARCHAR2(100);

    BEGIN

      current_calling_sequence := 'AP_INVOICES_Utility_PKG.eft_bank_details_exist<-'||
                                  P_calling_sequence;

      debug_info := 'Call AP IBY API';

      SELECT vendor_id
      INTO l_vendor_id
      FROM PO_VENDOR_SITES_ALL
      WHERE vendor_site_id = P_vendor_site_id;

      l_ext_bank_acct_id := AP_IBY_UTILITY_PKG.Get_Default_Iby_Bank_Acct_Id
                            (x_vendor_id => l_vendor_id,
                            x_vendor_site_id =>  p_vendor_site_id,
                            x_payment_function => NULL,
                            x_org_id => NULL,
                            x_currency_code => NULL,
                            x_calling_sequence => 'Ap_Invoices_Utility_Pkg');

      IF l_ext_bank_acct_id IS NOT NULL THEN
        RETURN True;
      ELSE
        RETURN False;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
              'P_vendor_site_id = '||P_vendor_site_id);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;
    END eft_bank_curr_details_exist;

     -----------------------------------------------------------------------
     -- Function selected_for_payment_flag returns 'Y' if an invoice
     -- has been selected for payment; function returns 'N' otherwise.
     -----------------------------------------------------------------------

/*=============================================================================
 |  FUNCTION - selected_for_payment_flag
 |
 |  DESCRIPTION
 |      returns 'Y' if an invoice has been selected for payment; function
 |      returns 'N' otherwise.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION selected_for_payment_flag (P_invoice_id IN number)
    RETURN varchar2
    IS
      l_flag varchar2(1) := 'N';
      CURSOR selected_for_payment_cursor IS
      SELECT 'Y'
        FROM   AP_SELECTED_INVOICES
       WHERE  invoice_id = P_invoice_id
      UNION
      SELECT 'Y'
        FROM AP_PAYMENT_SCHEDULES_ALL
        WHERE invoice_id = P_invoice_id
        AND checkrun_id IS NOT NULL;

    BEGIN

       OPEN selected_for_payment_cursor;
      FETCH selected_for_payment_cursor
       INTO l_flag;
      CLOSE selected_for_payment_cursor;

      RETURN(l_flag);

    END selected_for_payment_flag;

/*=============================================================================
 |  FUNCTION - get_discount_pay_dists_flag
 |
 |  DESCRIPTION
 |      returns 'Y' if there are any payment distributions associated with an
 |      invoice which are of type DISCOUNT.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_discount_pay_dists_flag (P_invoice_id IN number)
    RETURN varchar2
    IS
      l_flag varchar2(1) := 'N';

      CURSOR payment_cursor IS
      SELECT 'Y'
      FROM   ap_invoice_payments
      WHERE  invoice_id = P_invoice_id
      AND    nvl(discount_taken,0) <> 0;

    BEGIN

       OPEN payment_cursor;
      FETCH payment_cursor
       INTO l_flag;
      CLOSE payment_cursor;

      RETURN(l_flag);

    END get_discount_pay_dists_flag;

/*=============================================================================
 |  FUNCTION - get_unposted_void_payment
 |
 |  DESCRIPTION
 |       returns 'Y' if an invoice has an unposted payment which is linked to
 |       a voided check AND either the Primary or Secondary set of books is
 |       'Cash'.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/
    FUNCTION get_unposted_void_payment (P_invoice_id IN number)
    RETURN varchar2
    IS
      l_flag     varchar2(1) := 'N';
      l_org_id   AP_SYSTEM_PARAMETERS_ALL.ORG_ID%TYPE;

      CURSOR payment_cursor IS
      SELECT 'Y', p.org_id
        FROM ap_invoice_payments p,
             ap_checks c,
             ap_system_parameters SP
       WHERE  p.invoice_id = P_invoice_id
         AND  p.org_id = sp.org_id
         AND  nvl(p.cash_posted_flag,'N') <> 'Y'
         AND  p.check_id = c.check_id
         AND  c.void_date IS NOT NULL
         AND  (sp.accounting_method_option = 'Cash' OR
               sp.secondary_accounting_method = 'Cash');

    BEGIN

       OPEN payment_cursor;
      FETCH payment_cursor
       INTO l_flag, l_org_id;
      CLOSE payment_cursor;

      RETURN(l_flag);

    END get_unposted_void_payment;

/*=============================================================================
 |  FUNCTION - get_prepayments_applied_flag
 |
 |  DESCRIPTION
 |       returns 'Y' if an invoice has prepayments applied to it.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_prepayments_applied_flag (P_invoice_id IN number)
    RETURN varchar2
    IS
      l_flag varchar2(1) := 'N';
    BEGIN

      IF ( sign (AP_INVOICES_UTILITY_PKG.get_prepay_amount_applied(
                        P_invoice_id)) = 1 ) THEN
        l_flag := 'Y';
      ELSE
        l_flag := null;
      END IF;

      RETURN (l_flag);

    END get_prepayments_applied_flag;

/*=============================================================================
 |  FUNCTION - get_payments_exist_flag
 |
 |  DESCRIPTION
 |      returns 'Y' if an invoice has corresponding records in
 |      ap_invoice_payments
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_payments_exist_flag (P_invoice_id IN number)
    RETURN varchar2
    IS
      l_flag varchar2(1) := 'N';

      CURSOR payments_exist_cursor IS
      SELECT 'Y'
        FROM ap_invoice_payments
       WHERE invoice_id = P_invoice_id;

    BEGIN
      OPEN payments_exist_cursor;
      FETCH payments_exist_cursor INTO l_flag;
      CLOSE payments_exist_cursor;

      RETURN (l_flag);

    END get_payments_exist_flag;

/*=============================================================================
 |  FUNCTION - get_prepay_amount_applied
 |
 |  DESCRIPTION
 |      returns the sum of the applied prepayment amounts for a given
 |      prepayment
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_prepay_amount_applied (P_invoice_id IN number)
    RETURN number
    IS
      l_prepay_amount         number := 0;

    BEGIN

      -- eTax Uptake.  This function may be obsolete in the future.
      -- for now call ap_prepay_utils_pkg.
      l_prepay_amount :=
        AP_PREPAY_UTILS_PKG.get_prepay_amount_applied(P_invoice_id);

      RETURN (l_prepay_amount);

    END get_prepay_amount_applied;


/*=============================================================================
 |  FUNCTION - get_prepay_amount_remaining
 |
 |  DESCRIPTION
 |      returns the sum of the unapplied prepayment amounts for a given
 |      prepayment
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |      Bug 1029985. Including the tax on the prepayment when calculating
 |      the prepay_amount_remaining.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_prepay_amount_remaining (P_invoice_id IN number)
    RETURN number
    IS
      l_prepay_amount_remaining NUMBER := 0;

    BEGIN
      -- eTax Uptake.  This function may be obsolete in the future.
      -- for now call ap_prepay_utils_pkg.
      l_prepay_amount_remaining :=
        AP_PREPAY_UTILS_PKG.get_prepay_amount_remaining(P_invoice_id);

      RETURN(l_prepay_amount_remaining);

    END get_prepay_amount_remaining;

 ---------------------------------------------------------------------------
  -- Function get_prepay_amt_rem_set was created for bug 4413272
  -- The prepay amount remaining function  was also required to take care
  -- of the settlement date while calculating the amount for iexpenses team
 -------------------------------------------------------------------------

     FUNCTION get_prepay_amt_rem_set(P_invoice_id IN number)
       RETURN number
     IS
        l_prepay_amount_remaining number:=0;
        cursor c_prepay_amount_remaining IS
        SELECT SUM(nvl(prepay_amount_remaining,amount))
        FROM  ap_invoice_distributions_all aid,ap_invoices_all ai
        WHERE aid.invoice_id = P_invoice_id
        AND   aid.line_type_lookup_code IN ('ITEM','TAX')
        AND   nvl(aid.reversal_flag,'N') <> 'Y'
        AND  ai.invoice_id = P_invoice_id
        AND  ai.invoice_type_lookup_code = 'PREPAYMENT'
        AND  ai.earliest_settlement_date IS NOT NULL
        AND  ai.earliest_settlement_date <= trunc(SYSDATE);
    BEGIN
        OPEN c_prepay_amount_remaining;
        FETCH c_prepay_amount_remaining INTO l_prepay_amount_remaining;
        CLOSE c_prepay_amount_remaining;
        RETURN(l_prepay_amount_remaining);
    END get_prepay_amt_rem_set;


/*=============================================================================
 |  FUNCTION - get_prepayment_type
 |
 |  DESCRIPTION
 |      returns whether prepayment is of type "PERMANENT' which cannot be
 |      applied or 'TEMPORARY' which can be applied.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_prepayment_type (P_invoice_id IN number)
    RETURN varchar2
    IS
      l_prepayment_type VARCHAR2(9);

      CURSOR c_prepayment_type IS
      SELECT decode(AI.EARLIEST_SETTLEMENT_DATE,null,'PERMANENT','TEMPORARY')
        FROM ap_invoices_all ai
       WHERE ai.invoice_id = P_invoice_id;
    BEGIN

      OPEN c_prepayment_type;
      FETCH c_prepayment_type INTO l_prepayment_type;
      CLOSE c_prepayment_type;

      RETURN(l_prepayment_type);
    END get_prepayment_type;

/*=============================================================================
 |  FUNCTION - get_packet_id
 |
 |  DESCRIPTION
 |      returns the invoice-level packet_id. If only one unique packet_id
 |      exists for all distributions on an invoice, that packet_id is the
 |      invoice-level packet_id, otherwise there is none.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_packet_id (P_invoice_id IN number)
    RETURN number
    IS
      l_packet_id number := '';

      cursor packet_id_cursor is
      select decode(count(distinct(packet_id)),1,max(packet_id),'')
        from ap_invoice_distributions
       where invoice_id = P_Invoice_Id
         and packet_id is not null;

    BEGIN
      OPEN packet_id_cursor;
      FETCH packet_id_cursor INTO l_packet_id;
      CLOSE packet_id_cursor;

      RETURN (l_packet_id);

    END get_packet_id;

/*=============================================================================
 |  FUNCTION - get_payment_status
 |
 |  DESCRIPTION
 |      will read through every line of the payment schedules to check the
 |      payment_status_flag value. It will return 'Y' if it is fully paid.
 |      Other values are 'N' and 'P'
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION  get_payment_status( p_invoice_id  IN  NUMBER )
    RETURN VARCHAR2
    IS
      l_return_val    VARCHAR2(25);
      l_curr_ps_flag  VARCHAR2(25);
      temp_ps_flag    VARCHAR2(25);
      l_ps_count      NUMBER := 0;

      CURSOR c_select_payment_status (cv_invoice_id NUMBER ) IS
      SELECT payment_status_flag
        FROM ap_payment_schedules_all
       WHERE invoice_id = cv_invoice_id;

    BEGIN

      OPEN c_select_payment_status ( p_invoice_id );
      LOOP
      FETCH c_select_payment_status into temp_ps_flag;
      EXIT when c_select_payment_status%NOTFOUND;
        l_ps_count := l_ps_count +1;

        IF ( l_ps_count = 1 ) THEN
          l_curr_ps_flag := temp_ps_flag;
        ELSE
          IF ( l_curr_ps_flag <> temp_ps_flag ) THEN
            l_curr_ps_flag := 'P';
             EXIT;
          ELSE
            l_curr_ps_flag := temp_ps_flag;
          END IF; -- END of l_curr_ps_flag check
        END IF; -- END of l_ps_count  check
      END LOOP;
      CLOSE c_select_payment_status;

      IF ( l_ps_count > 0 ) THEN
        l_return_val := l_curr_ps_flag;
      ELSE
        l_return_val := 'N';
      END IF;
      RETURN (l_return_val );

    END get_payment_status;

/*=============================================================================
 |  FUNCTION - is_inv_pmt_prepay_posted
 |
 |  DESCRIPTION
 |      returns TRUE if an invoice has been paid/prepaid and accounting has
 |      been done for payment/reconciliation or prepayment accordingly.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION is_inv_pmt_prepay_posted(
                 P_invoice_id             IN NUMBER,
                 P_org_id                 IN NUMBER,
                 P_discount_taken         IN NUMBER,
                 P_prepaid_amount         IN NUMBER,
                 P_automatic_offsets_flag IN VARCHAR2,
                 P_discount_dist_method   IN VARCHAR2,
                 P_payment_status_flag    IN VARCHAR2)
    RETURN BOOLEAN
    IS
      l_count_pmt_posted       NUMBER := 0;
      l_count_pmt_hist_posted  NUMBER := 0;
      l_count_prepaid_posted   NUMBER := 0;
      l_primary_acctg_method   VARCHAR2(25);
      l_secondary_acctg_method VARCHAR2(25);
      l_org_id                 AP_SYSTEM_PARAMETERS_ALL.ORG_ID%TYPE;
    BEGIN

      select asp.accounting_method_option,
             nvl(asp.secondary_accounting_method, 'None'),
             asp.org_id
        into l_primary_acctg_method,
             l_secondary_acctg_method,
             l_org_id
        from ap_system_parameters_all asp
        where asp.org_id = P_org_id;


    /*-----------------------------------------------------------------+
     |  If the invoice has been fully or partially paid and any of the |
     |  following is true, then check for accounting of the payment:   |
     |  1. Auto offsets is on                                          |
     |  2. Running cash basis                                          |
     |  3. There was a discount and the discount method is other than  |
     |     system                                                      |
     +-----------------------------------------------------------------*/


      IF ((p_payment_status_flag <> 'N') AND
          ((nvl(p_automatic_offsets_flag, 'N') = 'Y') OR
          (l_primary_acctg_method = 'Cash')          OR
          (l_secondary_acctg_method = 'Cash')        OR
          ((nvl(p_discount_taken, 0) <> 0) AND
          (nvl(p_discount_dist_method, 'EXPENSE') <> 'SYSTEM')))) THEN

        select count(*)
          into l_count_pmt_posted
          from ap_invoice_payments aip
         where aip.posted_flag = 'Y'
           and aip.invoice_id = p_invoice_id;

        select count(*)
          into l_count_pmt_hist_posted
          from ap_payment_history aph
         where aph.posted_flag = 'Y'
           and aph.check_id in (select check_id
                                  from ap_invoice_payments aip
                                 where aip.invoice_id = p_invoice_id);

      END IF;

    /*-----------------------------------------------------------------+
     |  If a prepayment has been applied against the invoice and       |
     |  any of the following is true, then check for accounting of     |
     |  the prepayment application:                                    |
     |  1. Auto offsets is on                                          |
     |  2. Running cash basis                                          |
     +-----------------------------------------------------------------*/

      IF ((nvl(p_prepaid_amount, 0) <> 0) AND
          (nvl(p_automatic_offsets_flag, 'N') = 'Y' OR
           l_primary_acctg_method = 'Cash' OR
           l_secondary_acctg_method = 'Cash')) THEN

        select count(*)
          into l_count_prepaid_posted
          from ap_invoice_distributions aid
         where aid.posted_flag <> 'N'
           and aid.invoice_id = p_invoice_id
           and aid.line_type_lookup_code = 'PREPAY';
      END IF;

      IF (l_count_pmt_posted <> 0 OR
          l_count_pmt_hist_posted <> 0 OR
          l_count_prepaid_posted <> 0) THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;

    END is_inv_pmt_prepay_posted;


/*=============================================================================
 |  FUNCTION - get_pp_amt_applied_on_date
 |
 |  DESCRIPTION
 |      returns the sum of the applied prepayment amounts to an invoice by a
 |      prepayment for a given date. This has been added to fix the bug 977563
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_pp_amt_applied_on_date (
                 P_invoice_id       IN NUMBER,
                 P_prepay_id        IN NUMBER,
                 P_application_date IN DATE)
    RETURN number
    IS
      l_prepay_amt_applied NUMBER := 0;

    BEGIN

      SELECT SUM(aid1.amount * -1)
        INTO l_prepay_amt_applied
        FROM ap_invoice_distributions aid1, ap_invoice_distributions aid2
       WHERE aid1.invoice_id = P_invoice_id
         AND aid1.line_type_lookup_code = 'PREPAY'
         AND aid1.prepay_distribution_id = aid2.invoice_distribution_id
         AND aid2.invoice_id = P_prepay_id
         AND aid2.last_update_date = P_application_date ;

      RETURN (l_prepay_amt_applied);

    END get_pp_amt_applied_on_date;

/*=============================================================================
 |  FUNCTION - get_dist_count
 |
 |  DESCRIPTION
 |      returns the count of distributions available for the given invoice_id.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES
 |      The same function is added as an enhancement to the Key indicators
 |      report. The bug for the same is 1728036.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION get_dist_count (p_invoice_id IN NUMBER)
    RETURN NUMBER
    IS
      l_count_distributions NUMBER;
    BEGIN

      SELECT count(invoice_distribution_id)
        INTO l_count_distributions
        FROM ap_invoice_distributions
       WHERE invoice_id = p_invoice_id;

      RETURN l_count_distributions;

    EXCEPTION
    WHEN others THEN
      RETURN 0;
    END get_dist_count;


/*=============================================================================
 |  FUNCTION - get_amt_applied_per_prepay
 |
 |  DESCRIPTION
 |      returns the sum of the applied prepayment amounts to an invoice by a
 |      prepayment. This has been added to do not use a new select statement in
 |      the expense report import program.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/

    FUNCTION get_amt_applied_per_prepay (
                 P_invoice_id          IN NUMBER,
                 P_prepay_id           IN NUMBER)
    RETURN number
    IS
      l_prepay_amt_applied NUMBER := 0;

    BEGIN

      SELECT SUM(aid1.amount * -1)
        INTO l_prepay_amt_applied
        FROM ap_invoice_distributions aid1, ap_invoice_distributions aid2
       WHERE aid1.invoice_id = P_invoice_id
         AND aid1.line_type_lookup_code = 'PREPAY'
         AND aid1.prepay_distribution_id = aid2.invoice_distribution_id
         AND aid2.invoice_id = P_prepay_id;

      RETURN (l_prepay_amt_applied);

    END get_amt_applied_per_prepay;

/*=============================================================================
 |  FUNCTION - get_explines_count
 |
 |  DESCRIPTION
 |      added to get the count of expense report lines for a given expense
 |      report header id. This function was added for the enhancement to the
 |      key indicators report.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |      Bug 2298873 Code added by MSWAMINA.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/
    FUNCTION get_explines_count (p_expense_report_id IN NUMBER)
    RETURN NUMBER
    IS
      l_explines_count NUMBER;
    BEGIN

      SELECT count(*)
      INTO   l_explines_count
      FROM   ap_expense_report_lines
      WHERE  report_header_id = p_expense_report_id;

      RETURN l_explines_count;

    EXCEPTION
      WHEN OTHERS THEN
        l_explines_count := 0;
        RETURN l_explines_count;
    END get_explines_count;


/*=============================================================================
 |  FUNCTION - get_expense_type
 |
 |  DESCRIPTION
 |      added to decide whether the information is available in in expense
 |      reports table as well as in ap invoices or only in ap invoices
 |
 |  KNOWN ISSUES:
 |
 |  NOTES
 |      If the information is available in both the table we should get the
 |      information from ap expense report headers, if not we should get the
 |      information from ap invoices. This was added based on the requirement
 |      from GSI and confirmed by lauren
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/

    FUNCTION get_expense_type (
                 p_source in varchar2,
                 p_invoice_id in number)
    RETURN varchar2
    IS
      l_return_type VARCHAR2(1);
    BEGIN

      IF p_source IN ('XpenseXpress', 'SelfService') THEN

        SELECT 'E'
        INTO   l_return_type
        FROM   ap_expense_report_headers aerh
        WHERE  aerh.vouchno = p_invoice_id;

      ELSE

        l_return_type := 'I';

      END IF;

      RETURN l_return_type;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_return_type := 'I';
        RETURN l_return_type;
      WHEN OTHERS THEN
        l_return_type := 'I';
        RETURN l_return_type;

    END get_expense_type;

/*=============================================================================
 |  FUNCTION - get_max_inv_line_num
 |
 |  DESCRIPTION
 |      returns the highest line number of invoice lines belonging to
 |      invoice P_invoice_id
 |
 |  KNOWN ISSUES
 |
 |  NOTES
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/

    FUNCTION GET_MAX_INV_LINE_NUM(P_invoice_id IN NUMBER)
    RETURN NUMBER
    IS
      l_max_inv_line_num NUMBER := 0;
    BEGIN

      SELECT nvl( MAX(line_number),0 )
        INTO l_max_inv_line_num
        FROM ap_invoice_lines
       WHERE invoice_id = P_invoice_id;

      RETURN (l_max_inv_line_num);

    END GET_MAX_INV_LINE_NUM;


/*=============================================================================
 |  FUNCTION - get_line_total
 |
 |  DESCRIPTION
 |      returns the total invoice line amount for the invoice.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/

    FUNCTION GET_LINE_TOTAL(P_invoice_id IN NUMBER)
    RETURN NUMBER
    IS
      line_total NUMBER := 0;
    BEGIN

       -- eTax uptake.   Included condition to know if a TAX line is
       -- Do not include prepayment application amount if the prepayment
       -- is not included in the invoice.  (invoice_includes_prepay_flag = N)

       SELECT SUM(NVL(amount,0))
         INTO line_total
         FROM ap_invoice_lines ail
        WHERE ail.invoice_id = p_invoice_id
          AND ((ail.line_type_lookup_code not in ('PREPAY','AWT') --Bug 7372061 Excluded 'AWT' amount from the total line amount.
               AND ail.prepay_invoice_id IS NULL
               AND ail.prepay_line_number IS NULL)
               OR nvl(ail.invoice_includes_prepay_flag,'N') = 'Y');

      RETURN(line_total);

    END GET_LINE_TOTAL;

/*=============================================================================
 |  FUNCTION - ROUND_BASE_AMTS
 |
 |  DESCRIPTION
 |      returns the rounded base amount if there is any. it returns FALSE if
 |      no rounding amount necessary, otherwise it returns TRUE.
 |
 |  Business Assumption
 |      1. Called after base amount of all lines is populated
 |      2. Same exchange rate for all the lines
 |      3. It will be called by Primary ledger (AP) or Reporting ledger (MRC)
 |      4. Returns FALSE if sum of lines amount is different than invoice
 |         amount, since in that case the rounding is meaningless.
 |
 |  PARAMETERS
 |      X_Invoice_Id - Invoice Id
 |      X_Reporting_Ledger_Id - For ALC/MRC use only.
 |      X_Rounded_Line_Numbers - returns the line numbers that can be adjusted
 |      X_Rounded_Amt - rounded amount
 |      X_Debug_Info - debug information
 |      X_Debug_Context - error context
 |      X_Calling_Sequence - debug usage
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  19-MAY-2008  KPASIKAN           modified for 6892789 to get the lines that
 |                                  can be adjusted
 *============================================================================*/

    FUNCTION round_base_amts(
                       X_Invoice_Id          IN NUMBER,
                       X_Reporting_Ledger_Id IN NUMBER DEFAULT NULL,
                       X_Rounded_Line_Numbers OUT NOCOPY inv_line_num_tab_type,
                       X_Rounded_Amt         OUT NOCOPY NUMBER,
                       X_Debug_Info          OUT NOCOPY VARCHAR2,
                       X_Debug_Context       OUT NOCOPY VARCHAR2,
                       X_Calling_sequence    IN VARCHAR2)
    RETURN BOOLEAN IS
    l_rounded_amt             NUMBER := 0;
    l_rounded_line_numbers    inv_line_num_tab_type;
    l_base_currency_code      ap_system_parameters.base_currency_code%TYPE;
    l_base_amount             ap_invoices.base_amount%TYPE;
    l_invoice_amount          ap_invoices.invoice_amount%TYPE;
    l_invoice_currency_code   ap_invoices.invoice_currency_code%TYPE;
    l_reporting_currency_code ap_invoices.invoice_currency_code%TYPE;
    l_sum_base_amt            NUMBER;
    l_sum_amt                 NUMBER;
    l_sum_rpt_base_amt        NUMBER;

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

    cursor invoice_cursor is
      -- inv_base_amt/rep_base_amt
      SELECT decode(x_reporting_ledger_id, null, AI.base_amount, null),
             AI.invoice_amount, -- invoice amount
             AI.invoice_currency_code, -- invoice_currency_code
             ASP.base_currency_code -- base_currency_code
        FROM ap_invoices AI, ap_system_parameters ASP
       WHERE AI.invoice_id = X_invoice_id
         AND ASP.org_id = AI.org_id;

  BEGIN

    current_calling_sequence := 'AP_INVOICES_UTILITY_PKG - Round_Base_Amt ' ||
                                X_calling_sequence;

    -------------------------------------------------------------
    debug_info := 'Round_Base_Amt - Open cursor invoice_cursor';
    -------------------------------------------------------------

    OPEN invoice_cursor;
    FETCH invoice_cursor
      INTO l_base_amount,
           l_invoice_amount,
           l_invoice_currency_code,
           l_base_currency_code;
    IF (invoice_cursor%NOTFOUND) THEN
      CLOSE invoice_cursor;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE invoice_cursor;

    IF (X_Reporting_Ledger_Id IS NULL) THEN
      --------------------------------------------------------------------
      debug_info := 'Round_base_amt Case 1 - Rounding for primary ledger';
      --------------------------------------------------------------------

      IF (l_invoice_currency_code <> l_base_currency_code) THEN
        BEGIN
          SELECT SUM(base_amount), SUM(amount)
            INTO l_sum_base_amt, l_sum_amt
            FROM ap_invoice_lines AIL
           WHERE AIL.invoice_id = X_INVOICE_ID
             AND line_type_lookup_code <> 'AWT'
             AND (invoice_includes_prepay_flag = 'Y' OR
                 line_type_lookup_code <> 'PREPAY');
          --  eTax: Tax lines that do not contribute to lines total
          --  should be excluded.
        END;

        IF (l_sum_amt = l_invoice_amount) THEN
          l_rounded_amt := l_base_amount - l_sum_base_amt;
        ELSE
          X_ROUNDED_AMT      := 0;
          X_Rounded_Line_Numbers.delete;
          X_debug_context    := current_calling_sequence;
          X_debug_info       := debug_info;
          RETURN(FALSE);
        END IF;
      ELSE
        ---------------------------------------------------------------------
        debug_info := 'Round_Base_Amt - same inv currency/base currency';
        ---------------------------------------------------------------------
        X_ROUNDED_AMT      := 0;
        X_Rounded_Line_Numbers.delete;
        X_debug_context    := current_calling_sequence;
        X_debug_info       := debug_info;
        RETURN(FALSE);
      END IF; -- end of check currency for primary

    ELSE

      Null; -- Removed the code here due to MRC obsoletion

    END IF; -- end of check x_reporting_ledger_id

    IF (l_rounded_amt <> 0) THEN
      --------------------------------------------------------------------
      debug_info := 'Round_Base_Amt - round amt exists and find the line';
      --------------------------------------------------------------------
      BEGIN

        SELECT ail1.line_number
          BULK COLLECT INTO l_Rounded_Line_Numbers
          FROM ap_invoice_lines ail1
         WHERE ail1.invoice_id = X_invoice_id
           AND ail1.amount <> 0
           AND LINE_TYPE_LOOKUP_CODE <> 'TAX' -- bug 9582952
           AND (EXISTS
                (SELECT 'UNPOSTED'
                   FROM ap_invoice_distributions D1
                  WHERE D1.invoice_id = ail1.invoice_id
                    AND D1.invoice_line_number = ail1.line_number
                    AND NVL(D1.posted_flag, 'N') = 'N') OR
                (NOT EXISTS
                 (SELECT 'X'
                    FROM ap_invoice_distributions D2
                   WHERE D2.invoice_id = ail1.invoice_id
                     AND D2.invoice_line_number = ail1.line_number)))
          ORDER BY ail1.base_amount desc;

      END;

      X_ROUNDED_AMT      := l_rounded_amt;
      X_Rounded_Line_Numbers := l_rounded_line_numbers;
      X_debug_context    := current_calling_sequence;
      X_debug_info       := debug_info;
      RETURN(TRUE);
    ELSE
      ---------------------------------------------------------------------
      debug_info := 'Round_Base_Amt - round_amt is 0 ';
      ---------------------------------------------------------------------
      X_ROUNDED_AMT      := 0;
      X_Rounded_Line_Numbers.delete;
      X_debug_context    := current_calling_sequence;
      X_debug_info       := debug_info;
      RETURN(FALSE);
    END IF; -- end of check l_rounded_amt

  EXCEPTION
    WHEN OTHERS THEN
      if (SQLCODE <> -20001) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                              'Invoice Id = ' || X_Invoice_Id);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      end if;
      debug_info      := debug_info || 'Error occurred';
      X_debug_context := current_calling_sequence;
      X_debug_info    := debug_info;
      Return(FALSE);
  END round_base_amts;

 /*============================================================================
 |  FUNCTION - Is_Inv_Credit_Referenced
 |
 |  DESCRIPTION
 |      Added to check if the invoice has a QUICK CREDIT invoice against it or
 |      if this invoice has any active (non discard/non cancelled) corrections.
 |
 |  KNOWN ISSUES
 |
 |  NOTES
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/
    FUNCTION Is_Inv_Credit_Referenced( P_invoice_id  IN NUMBER )
    RETURN BOOLEAN
    IS
      l_retVal              BOOLEAN := FALSE;
      l_active_count        NUMBER;
      l_quick_credit_count  NUMBER:=0;
    BEGIN

      -- Perf bug 5173995 , removed count(*) from below 2 SQLs
      BEGIN
        SELECT 1
        INTO   l_active_count
        FROM   ap_invoice_lines AIL
        WHERE  ( NVL( AIL.discarded_flag, 'N' ) <> 'Y' AND
                 NVL( AIL.cancelled_flag, 'N' ) <> 'Y' )
        AND    AIL.corrected_inv_id = p_invoice_id
        AND    ROWNUM = 1 ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_active_count := 0;
      END;

      BEGIN
      --bug 5475668
      if (P_invoice_id is not null) then
        SELECT 1
        INTO   l_quick_credit_count
        FROM   ap_invoices AI
        WHERE  AI.credited_invoice_id = P_invoice_id
        AND  NVL(AI.quick_credit, 'N') = 'Y'
        AND  AI.cancelled_date is null
        AND  ROWNUM = 1 ;
       end if;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_quick_credit_count := 0;
      END;

      IF ( l_active_count <> 0 or l_quick_credit_count <> 0 ) THEN
        l_retVal := TRUE;
      END IF;

      RETURN l_retVal;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN FALSE;
    END Is_Inv_Credit_Referenced;

/*=============================================================================
 |  FUNCTION - Inv_With_PQ_Corrections
 |
 |  DESCRIPTION
 |      This function returns TRUE if the invoice contains price or quantity
 |      corrections.  It returns FALSE otherwise.
 |
 |  PARAMETERS
 |      P_Invoice_Id - Invoice Id
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

  FUNCTION Inv_With_PQ_Corrections(
             P_Invoice_Id           IN NUMBER,
             P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN

  IS
    CURSOR Invoice_Validation IS
    SELECT i.invoice_id
      FROM ap_invoices_all i
     WHERE i.invoice_id = P_Invoice_Id
       AND EXISTS
           (SELECT il.invoice_id
              FROM ap_invoice_lines_all il
             WHERE il.invoice_id = i.invoice_id
               AND NVL(il.discarded_flag, 'N') <> 'Y'
               AND NVL(il.cancelled_flag, 'N') <> 'Y'
               AND il.match_type IN ('PRICE_CORRECTION',
                                     'QTY_CORRECTION'));

    l_invoice_id               ap_invoices_all.invoice_id%TYPE;
    current_calling_sequence   VARCHAR2(4000);
    debug_info                 VARCHAR2(240);
    l_return_var               BOOLEAN := FALSE;

  BEGIN
      current_calling_sequence := 'AP_INVOICES_UTILITY_PKG - Inv_With_PQ_Corrections';

      -------------------------------------------------------------
      debug_info := 'Inv_With_PQ_Corrections - Open cursor';
      -------------------------------------------------------------
      OPEN invoice_validation;
      FETCH invoice_validation INTO l_invoice_id;
      IF (invoice_validation%NOTFOUND) THEN
        CLOSE invoice_validation;
        l_invoice_id := null;

      END IF;

      IF ( invoice_validation%ISOPEN ) THEN
        CLOSE invoice_validation;
      END IF;

      IF (l_invoice_id IS NOT NULL) THEN
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

  END Inv_With_PQ_Corrections;

/*=============================================================================
 |  FUNCTION -  Inv_With_Prepayments
 |
 |  DESCRIPTION
 |    This function returns TRUE if the invoice contains prepayment applications.
 |    It returns FALSE otherwise.
 |
 |  PARAMETERS
 |      X_Invoice_Id - Invoice Id
 |      X_Calling_Sequence - debug usage
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

  FUNCTION Inv_With_Prepayments(
             P_Invoice_Id           IN NUMBER,
             P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN

  IS
    CURSOR Invoice_Validation IS
    SELECT i.invoice_id
      FROM ap_invoices_all i
     WHERE i.invoice_id = P_Invoice_Id
       AND EXISTS
           (SELECT il.invoice_id
              FROM ap_invoice_lines_all il
             WHERE il.invoice_id = i.invoice_id
              AND il.line_type_lookup_code = 'PREPAY'
              AND NVL(il.discarded_flag, 'N') <> 'Y'
              AND NVL(il.cancelled_flag, 'N') <> 'Y');

    l_invoice_id               ap_invoices_all.invoice_id%TYPE;
    current_calling_sequence   VARCHAR2(4000);
    debug_info                 VARCHAR2(240);
    l_return_var               BOOLEAN := FALSE;

  BEGIN
      current_calling_sequence := 'AP_INVOICES_UTILITY_PKG - Inv_With_Prepayments';

      -------------------------------------------------------------
      debug_info := 'Inv_With_Prepayments - Open cursor';
      -------------------------------------------------------------
      OPEN invoice_validation;
      FETCH invoice_validation INTO l_invoice_id;
      IF (invoice_validation%NOTFOUND) THEN
        CLOSE invoice_validation;
        l_invoice_id := null;

      END IF;

      IF ( invoice_validation%ISOPEN ) THEN
        CLOSE invoice_validation;
      END IF;

      IF (l_invoice_id IS NOT NULL) THEN
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

  END Inv_With_Prepayments;

/*=============================================================================
 |  FUNCTION - Invoice_Includes_Awt
 |
 |  DESCRIPTION
 |    This function returns TRUE if the invoice contains withholding tax.
 |    It returns FALSE otherwise.
 |
 |  PARAMETERS
 |      X_Invoice_Id - Invoice Id
 |      X_Calling_Sequence - debug usage
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

  FUNCTION Invoice_Includes_Awt(
             P_Invoice_Id           IN NUMBER,
             P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN

  IS
    CURSOR Invoice_Validation IS
    SELECT i.invoice_id
      FROM ap_invoices_all i
     WHERE i.invoice_id = P_Invoice_Id
       AND EXISTS
           (SELECT il.invoice_id
              FROM ap_invoice_lines_all il
             WHERE il.invoice_id = i.invoice_id
               AND il.line_type_lookup_code = 'AWT'
               AND NVL(il.discarded_flag, 'N') <> 'Y'
               AND NVL(il.cancelled_flag, 'N') <> 'Y');

    l_invoice_id               ap_invoices_all.invoice_id%TYPE;
    current_calling_sequence   VARCHAR2(4000);
    debug_info                 VARCHAR2(240);
    l_return_var               BOOLEAN := FALSE;

  BEGIN
      current_calling_sequence := 'AP_INVOICES_UTILITY_PKG - Invoice_Includes_Awt';

      -------------------------------------------------------------
      debug_info := 'Invoice_Includes_Awt - Open cursor';
      -------------------------------------------------------------
      OPEN invoice_validation;
      FETCH invoice_validation INTO l_invoice_id;
      IF (invoice_validation%NOTFOUND) THEN
        CLOSE invoice_validation;
        l_invoice_id := null;

      END IF;

      IF ( invoice_validation%ISOPEN ) THEN
        CLOSE invoice_validation;
      END IF;

      IF (l_invoice_id IS NOT NULL) THEN
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

  END Invoice_Includes_Awt;

/*=============================================================================
 |  FUNCTION - Inv_Matched_Finally_Closed_Po
 |
 |  DESCRIPTION
 |    This function returns TRUE if the invoice is matched to a finally closed
 |    PO.  It returns FALSE otherwise.
 |
 |  PARAMETERS
 |      X_Invoice_Id - Invoice Id
 |      X_Calling_Sequence - debug usage
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  15-DEC-2003  SYIDNER            Creation
 |
 *============================================================================*/
  FUNCTION Inv_Matched_Finally_Closed_Po(
             P_Invoice_Id           IN NUMBER,
             P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN

  IS
    CURSOR Invoice_Validation IS
    SELECT i.invoice_id
      FROM ap_invoices_all i
     WHERE i.invoice_id = P_Invoice_Id
       AND EXISTS
           (SELECT ail.invoice_id
              FROM ap_invoice_lines_all ail,
                   po_line_locations_all pll
             WHERE ail.invoice_id = i.invoice_id
               AND ail.po_line_location_id = pll.line_location_id
               AND ail.org_id = pll.org_id
               AND pll.closed_code = 'FINALLY CLOSED');

    l_invoice_id               ap_invoices_all.invoice_id%TYPE;
    current_calling_sequence   VARCHAR2(4000);
    debug_info                 VARCHAR2(240);
    l_return_var               BOOLEAN := FALSE;

  BEGIN
    current_calling_sequence := 'AP_INVOICES_UTILITY_PKG - Inv_Matched_Finally_Closed_Po';

    ------------------------------------------------------------
    debug_info := 'Open cursor to verify if the invoice is '||
                  'matched to a finally closed PO';
    -------------------------------------------------------------
    OPEN invoice_validation;
    FETCH invoice_validation INTO l_invoice_id;
    IF (invoice_validation%NOTFOUND) THEN
      CLOSE invoice_validation;
      l_invoice_id := null;

    END IF;

    IF ( invoice_validation%ISOPEN ) THEN
      CLOSE invoice_validation;
    END IF;

    IF (l_invoice_id IS NOT NULL) THEN
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

  END Inv_Matched_Finally_Closed_Po;

  --Invoice Lines: Distributions
  --Added the procedure to retrieve the max dist line number
  --for a particular invoice line.
  -----------------------------------------------------------------------
  -- Function get_max_dist_line_num returns the highest distribution line
  -- number of distributions belonging to invoice P_invoice_id for invoice line
  -- p_invoice_line_number.
  -----------------------------------------------------------------------
  FUNCTION get_max_dist_line_num (P_invoice_id IN number,
                                  P_invoice_line_number IN number) RETURN number
  IS
    l_max_dist_line_num NUMBER := 0;
  BEGIN

     select nvl(max(distribution_line_number),0)
     into   l_max_dist_line_num
     from   ap_invoice_distributions
     where  invoice_id = P_invoice_id
     and    invoice_line_number = P_invoice_line_number;

     return(l_max_dist_line_num);

  END get_max_dist_line_num;


 ---------------------------------------------------------------------
 --ETAX: Invwkb
 --This function when provided with a invoice_id, will return the
 --corresponding invoice_number.
 ---------------------------------------------------------------------
 FUNCTION get_invoice_num (P_Invoice_Id IN Number) RETURN VARCHAR2 IS
  l_invoice_num VARCHAR2(50) := NULL;
 BEGIN

   SELECT invoice_num
   INTO l_invoice_num
   FROM ap_invoices
   WHERE invoice_id = p_invoice_id;

   RETURN(l_invoice_num);


 EXCEPTION WHEN OTHERS THEN
   RETURN(NULL);

 END get_invoice_num;

/*=============================================================================
 |  FUNCTION - get_retained_total
 |
 |  DESCRIPTION
 |      returns the total retained amount for the invoice.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/

    FUNCTION GET_RETAINED_TOTAL(P_Invoice_Id IN NUMBER, P_Org_Id IN NUMBER)
    RETURN NUMBER
    IS
      retained_total NUMBER := 0;
    BEGIN

       SELECT SUM(NVL(amount,0))
         INTO retained_total
         FROM ap_invoice_distributions_all aid
        WHERE aid.invoice_id = p_invoice_id
          AND aid.line_type_lookup_code = 'RETAINAGE'
          AND EXISTS
                  (SELECT 'X' FROM ap_invoice_lines_all ail
                    WHERE ail.invoice_id = p_invoice_id
                      AND ail.line_number = aid.invoice_line_number
                      AND ail.line_type_lookup_code <> 'RETAINAGE RELEASE');

        return (retained_total);

    END GET_RETAINED_TOTAL;

/*=============================================================================
 |  FUNCTION -  get_item_total
 |
 |  DESCRIPTION
 |      returns the total item amount
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION Get_Item_Total(P_Invoice_Id IN NUMBER, P_Org_Id IN NUMBER)
		    RETURN NUMBER IS

      item_total NUMBER := 0;

    BEGIN

      select sum(nvl(amount,0)) - sum(nvl(included_tax_amount,0))
      into   item_total
      from   ap_invoice_lines_all
      where  invoice_id = p_invoice_id
      and    line_type_lookup_code IN ('ITEM','RETAINAGE RELEASE');

      return(item_total);

    END Get_Item_Total;

/*=============================================================================
 |  FUNCTION -  get_freight_total
 |
 |  DESCRIPTION
 |      returns the total item amount
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION Get_Freight_Total(P_Invoice_Id IN NUMBER, P_Org_Id IN NUMBER)
		    RETURN NUMBER IS

      freight_total NUMBER := 0;

    BEGIN

      select sum(nvl(amount,0)) - sum(nvl(included_tax_amount,0))
      into   freight_total
      from   ap_invoice_lines_all
      where  invoice_id = p_invoice_id
      and    org_id     = p_org_id
      and    line_type_lookup_code = 'FREIGHT';

      return(freight_total);

    END Get_Freight_Total;


/*=============================================================================
 |  FUNCTION -  get_misc_total
 |
 |  DESCRIPTION
 |      returns the total item amount
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION Get_Misc_Total(P_Invoice_Id IN NUMBER, P_Org_Id IN NUMBER)
		    RETURN NUMBER IS

      misc_total NUMBER := 0;

    BEGIN

      select sum(nvl(amount,0)) - sum(nvl(included_tax_amount,0))
      into   misc_total
      from   ap_invoice_lines_all
      where  invoice_id = p_invoice_id
      and    org_id     = p_org_id
      and    line_type_lookup_code = 'MISCELLANEOUS';

      return(misc_total);

    END Get_Misc_Total;

/*=============================================================================
 |  FUNCTION -  get_prepay_app_total
 |
 |  DESCRIPTION
 |      returns the total prepayments applied including recoupments
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

    FUNCTION Get_Prepay_App_Total(P_Invoice_Id IN NUMBER, P_Org_Id IN NUMBER)
		    RETURN NUMBER IS

      prepay_app_total NUMBER := 0;

    BEGIN

      select sum(nvl(amount,0))
      into   prepay_app_total
      from   ap_invoice_distributions_all
      where  invoice_id = p_invoice_id
      and    org_id     = p_org_id
      and    line_type_lookup_code = 'PREPAY';

      return(prepay_app_total);

    END Get_Prepay_App_Total;

/*=============================================================================
 |  FUNCTION - get_invoice_status
 |
 |  DESCRIPTION
 |      returns the invoice status lookup code.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES
 |      ISP Invoice Statuses
 |                   IN_PROCESS
 |                   UNSUBMITTED
 |                   IN_NEGOTIATION
 |                   CANCELLED
 |
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/
 -- Bug 5345946 XBuild7 Code Cleanup
    FUNCTION get_invoice_status(
                 p_invoice_id               IN NUMBER,
                 p_invoice_amount           IN NUMBER,
                 p_payment_status_flag      IN VARCHAR2,
                 p_invoice_type_lookup_code IN VARCHAR2)
    RETURN VARCHAR2 IS

      l_invoice_status       		VARCHAR2(25);
      l_approval_ready_flag        	VARCHAR2(1);
      l_cancelled_date 			    DATE;
      l_negotiate_lines_count		NUMBER;
      l_invoice_source			    VARCHAR2(25);
      l_invoice_type_lookup_code    VARCHAR2(30);

    BEGIN
      --
      SELECT ai.cancelled_date,
             ai.approval_ready_flag,
             ai.invoice_type_lookup_code,
             ai.source
      INTO   l_cancelled_date,
             l_approval_ready_flag,
             l_invoice_type_lookup_code,
             l_invoice_source
      FROM   ap_invoices_all ai
      WHERE  ai.invoice_id = p_invoice_id
        AND  ai.source = 'ISP';

      -- If cancelled date is not null, return 'CANCELLED'
      --
      IF ( l_cancelled_date IS NOT NULL) THEN
        RETURN('CANCELLED');
      END IF;

      -- If invoice is saved for later in ISP, return 'UNSUBMITTED'.
      -- Temporarily approval_ready_flag = 'S' in ap_invoices_all  handles the
      -- the unsubmitted invoices.
      IF ( l_approval_ready_flag = 'S' ) THEN
        RETURN('UNSUBMITTED');
      END IF;


      -- If invoice is in negotiation, return 'IN_NEGOTIATION'.
      --
      IF ( l_approval_ready_flag <> 'S' ) THEN

         IF (l_invoice_type_lookup_code = 'INVOICE REQUEST') THEN

		      SELECT count(*)
		      INTO   l_negotiate_lines_count
		      FROM   ap_apinv_approvers
		      WHERE  invoice_id = p_invoice_id
		      AND    approval_status = 'NEGOTIATE'
		      AND rownum =1;

		      IF ( l_negotiate_lines_count > 0 ) THEN
		        RETURN('IN_NEGOTIATION');
		      END IF;

	      ELSE  --- Standard, Credit-Memo or Prepayments

		      SELECT count(*)
		      INTO   l_negotiate_lines_count
		      FROM   ap_holds_all
		      WHERE  invoice_id = p_invoice_id
		      AND    wf_status = 'NEGOTIATE'
		      AND rownum =1;

		      IF ( l_negotiate_lines_count > 0 ) THEN
		        RETURN('IN_NEGOTIATION');
		      END IF;

	      END IF;
	      --
	   END IF;
	   --
	   RETURN('IN_PROCESS');
       --
    END get_invoice_status;

    PROCEDURE get_bank_details(
	p_invoice_currency_code	IN VARCHAR2,
	p_party_id				IN NUMBER,
	p_party_site_id			IN NUMBER,
	p_supplier_site_id			IN NUMBER,
	p_org_id				IN NUMBER,
	x_bank_account_name		OUT NOCOPY VARCHAR2,
	x_bank_account_id		OUT NOCOPY VARCHAR2,
	x_bank_account_number	OUT NOCOPY VARCHAR2) IS

	cursor c_get_bank_details is
		select  t.bank_account_name,
			t.bank_account_id,
			t.bank_account_number
		from (
		SELECT  b.bank_account_name,
			b.ext_bank_account_id bank_account_id,
			b.bank_account_number,
			rank() over (partition by ibyu.instrument_id, ibyu.instrument_type order by ibyu.instrument_payment_use_id) not_dup,
			ibypayee.supplier_site_id,/*bug 8345877*/
			ibypayee.party_site_id,/*bug 8345877*/
			ibypayee.org_id,/*bug 8345877*/
			ibyu.order_of_preference /*bug 8345877*/
		  FROM  IBY_PMT_INSTR_USES_ALL ibyu,
			IBY_EXT_BANK_ACCOUNTS_V b,
			IBY_EXTERNAL_PAYEES_ALL ibypayee
		 WHERE ibyu.instrument_id = b.ext_bank_account_id
		   AND ibyu.instrument_type = 'BANKACCOUNT'
		   AND (b.currency_code = p_invoice_currency_code OR b.currency_code is null
			OR NVL(b.foreign_payment_use_flag,'N')='Y')
		   AND ibyu.ext_pmt_party_id = ibypayee.ext_payee_id
		   AND ibyu.payment_flow = 'DISBURSEMENTS'
		   AND ibypayee.payment_function = 'PAYABLES_DISB'
		   AND ibypayee.payee_party_id = p_party_id
		   /*bug 9462285. Modified end_date condition */
		   AND trunc(sysdate) between trunc(NVL(ibyu.start_date,sysdate-1)) AND trunc(decode(ibyu.end_date, null, sysdate+1, ibyu.end_date-1))
		   AND trunc(sysdate) between trunc(NVL(b.start_date,sysdate-1)) AND trunc(decode(b.end_date, null, sysdate+1, b.end_date-1))
		   AND (ibypayee.party_site_id is null OR ibypayee.party_site_id = p_party_site_id)
		   AND (ibypayee.supplier_site_id is null OR ibypayee.supplier_site_id = p_supplier_site_id)
		   AND (ibypayee.org_id is null OR
			(ibypayee.org_id = p_org_id AND ibypayee.org_type = 'OPERATING_UNIT'))) t
		where t.not_dup=1 /*bug 8345877*/
                  order by t.supplier_site_id,
                           t.party_site_id,
                           t.org_id,
                           t.order_of_preference/*bug 8345877*/;

    BEGIN

	OPEN c_get_bank_details;
	FETCH c_get_bank_details INTO x_bank_account_name, x_bank_account_id, x_bank_account_number;
	CLOSE c_get_bank_details;

    EXCEPTION
	WHEN OTHERS THEN
		x_bank_account_name		:= NULL;
		x_bank_account_id		:= NULL;
		x_bank_account_number	:= NULL;
    END get_bank_details;

 /*==========================================================================
 |  FUNCTION - get_interface_po_number
 |
 |  DESCRIPTION
 |      returns the PO number for invoice to be displayed in the Quick
 |      invoices form.
 |      Added for the CLM Document Numbering Project Bug 9503239
 |
 |
 |
 |
 |
 |
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |
 |
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/

    FUNCTION get_interface_po_number(p_po_number IN VARCHAR2,
                                     p_org_id    IN NUMBER)
    RETURN VARCHAR2 IS
      l_po_number         VARCHAR2(50) := NULL;

      CURSOR int_po_number_cursor IS
      SELECT NVL(ph.clm_document_number, ph.segment1)
      FROM   po_headers PH
      WHERE  ph.segment1=p_po_number
      AND    ph.org_id=p_org_id;

    BEGIN
      IF p_po_number IS NULL THEN
        RETURN NULL;
      ELSE
        IF ap_clm_pvt_pkg.is_clm_installed = 'Y' THEN

          OPEN  int_po_number_cursor;
          FETCH int_po_number_cursor INTO  l_po_number;
          CLOSE int_po_number_cursor;

          RETURN(l_po_number);
        ELSE
          RETURN p_po_number;
        END IF; --if clm installed
      END IF; --if p_po_number is null
    END get_interface_po_number;

END AP_INVOICES_UTILITY_PKG;


/
