--------------------------------------------------------
--  DDL for Package Body AP_CREDIT_CARD_INVOICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_CREDIT_CARD_INVOICE_PKG" AS
/* $Header: apwcciib.pls 120.16.12010000.5 2009/04/17 11:09:10 rajnisku ship $ */
--------------------------------------------------------------------------------
--
-- PROCEDURE	CreateCreditCardInvoice
--
-- Params:
--	input:
--		p_cardProgramID - credit card program code
--		p_startDate - date to start collecting transaction records
--		p_endDate - date to end collecting transaction records
--
--	output:
--		errbuf - contains error message; required by Concurrent Manager
--    		retcode - contains return code; required by Concurrent Manager
--              p_invoiceID - the invoice id value of the newly generated invoice record
--
-- Returns:
--		none
--
-- Desc:
-- 		Insert the records into AP_INVOICE_LINES_INTERFACE and AP_INVOICES_INTERFACE
--		to create invoice for caredit card isser for payment of records in
-- 		AP_CREDIT_CARD_TRXNS.
--
-- 		After being inserted into invoice open interface, the corresponding records in
-- 		the AP_CREDIT_CARD_TRXNS_ALL need to be updated with COMPANY_PREPAID_FLAG set to
-- 		'Y'
--
-- 		Single record is inserted into AP_INVOICES_INTERFACE and serves as a header to
-- 		those records inserted into AP_INVOICE_LINES_INTERFACE.
--
--              InvoiceId of the newly created Invoice is returned back.
---------------------------------------------------------------------------------
PROCEDURE createCreditCardInvoice(
	errbuf		OUT NOCOPY	VARCHAR2,
	retcode		OUT NOCOPY	NUMBER,
	p_cardProgramID	IN 		NUMBER,
	p_startDate 	IN 		DATE DEFAULT NULL,
	p_endDate 	IN 		DATE DEFAULT NULL,
	p_invoiceId     OUT NOCOPY      NUMBER )
IS
	l_count            	NUMBER := 0;
	l_sum              	AP_WEB_DB_AP_INT_PKG.invIntf_invAmt := 0;
	l_card_trxn_id     	AP_WEB_DB_CCARD_PKG.ccTrxn_trxID;
	l_transaction_date      DATE;                               --3028505, renamed this variable
	l_invoice_id       	AP_WEB_DB_AP_INT_PKG.invLines_invID;
	l_invoice_id_temp  	AP_WEB_DB_AP_INT_PKG.invLines_invID; -- Bug 6687752
	l_invoice_line_id  	AP_WEB_DB_AP_INT_PKG.invLines_invLineID;
	l_party_id        	ap_suppliers.party_id%TYPE;
	l_party_site_id		ap_supplier_sites.party_site_id%TYPE;
	l_vendor_id        	AP_WEB_DB_CCARD_PKG.cardProgs_vendorID;
	l_vendor_site_id   	AP_WEB_DB_CCARD_PKG.cardProgs_vendorSiteID;
	l_terms_id		AP_TERMS.TERM_ID%TYPE; -- Bug: 7234744 populate terms-id in the interface table.
	l_ccid		        AP_WEB_DB_AP_INT_PKG.invLines_distCodeCombID;
	l_invoice_currency_code AP_WEB_DB_AP_INT_PKG.invIntf_invCurrCode;
	l_pay_group_lookup_code	AP_WEB_DB_AP_INT_PKG.vendorSites_payGroupLookupCode;
	l_accts_pay_ccid        AP_WEB_DB_AP_INT_PKG.invIntf_acctsPayCCID;

	l_debugInfo        	VARCHAR2(2000);
    	l_payment_due_code  	VARCHAR2(15);
	l_result		BOOLEAN;
	l_ccard_trxn_cursor	AP_WEB_DB_CCARD_PKG.UnpaidCreditCardTrxnCursor;
    	l_billed_amt        	AP_WEB_DB_CCARD_PKG.ccTrxn_billedAmount;
    	l_billed_curr_code  	AP_WEB_DB_CCARD_PKG.ccTrxn_billedCurrCode;
    	l_masked_cc_number       	AP_WEB_DB_CCARD_PKG.ccTrxn_cardId;

        --3028505, added variables below
        l_period_name           gl_period_statuses.period_name%TYPE;
        l_open_date             date;
        l_full_name             per_people_f.full_name%TYPE;
        l_description           AP_WEB_DB_AP_INT_PKG.invLines_description;
        l_employee_id          per_employees_x.employee_id%type;
	--
        -- 4458253, added variable
        l_org_id                NUMBER;


        x_return_status         VARCHAR2(4000);
        x_msg_count             NUMBER;
        x_msg_data              VARCHAR2(4000);
        l_rejection_list        AP_IMPORT_INVOICES_PKG.rejection_tab_type;

        l_doc_cat_code          AP_WEB_DB_AP_INT_PKG.invIntf_docCategoryCode := 'PAY REQ INV';

	--
	--
BEGIN

        -- Bug 4458253: Should pass org id explicitly into InsertInvoice* calls
	------------------------------------------------------------------
 	l_debugInfo := 'Get Org ID from card program to pass into InsertInvoice*';
 	------------------------------------------------------------------
        SELECT org_id
        INTO   l_org_id
        FROM   ap_card_programs
        WHERE  card_program_id = p_cardProgramID;


	-- Bug 3068119: Transactions with Payment Scenario COMPANY will be processed.
	-------------------------------------------------------------------
	l_debugInfo := 'Set the payment due code';
	-------------------------------------------------------------------
    	l_payment_due_code := 'COMPANY';

	-------------------------------------------------------------------
	l_debugInfo := 'Loop through each of every transaction';
	-------------------------------------------------------------------
	IF ( AP_WEB_DB_CCARD_PKG.GetUnpaidCreditCardTrxnCursor(
			l_ccard_trxn_cursor,
			p_cardProgramID,
			l_payment_due_code,
			p_startDate,
			p_endDate  ) ) THEN

		LOOP
        	FETCH l_ccard_trxn_cursor INTO
            		l_card_trxn_id,
            		l_transaction_date,
            		l_billed_amt,
            		l_masked_cc_number,
                        l_full_name,
                        l_employee_id;

        	EXIT WHEN l_ccard_trxn_cursor%NOTFOUND;

		--3028505, added code below to check if the transaction date is in an open period
		--if not, then increment it to an open period.

                l_period_name := ap_utilities_pkg.get_current_gl_date(l_transaction_date);

                if l_period_name is null then
                  ap_utilities_pkg.get_only_open_gl_date(l_transaction_date,
                                                         l_period_name,
                                                         l_open_date);

                  if l_open_date is not null then
                    l_transaction_date := l_open_date;
                  end if;

                end if;

		-------------------------------------------------------------------
		l_debugInfo := 'Get the clearing account id';
		-------------------------------------------------------------------
		-- Bug 3068119: CardProgramID passed to GetExpenseClearingCCID.

		l_result := AP_WEB_DB_AP_INT_PKG.GetExpenseClearingCCID( l_ccid,
					p_cardProgramID,
					l_employee_id,
					l_transaction_date);

		IF ( l_result <> TRUE ) THEN
			l_ccid := NULL;
		END IF;

		l_count := l_count + 1;
		l_sum := l_sum + l_billed_amt;

		IF ( l_count = 1 ) THEN
			--------------------------------------------------------------------
			l_debugInfo := 'Getting next sequence from AP_INVOICES_INTERFACE_S';
			--------------------------------------------------------------------
			l_result := AP_WEB_DB_AP_INT_PKG.GetNextInvoiceId(
					l_invoice_id );

			IF ( l_result <> TRUE ) THEN
				l_invoice_id := NULL;
			END IF;
		END IF;

	        --------------------------------------------------------------------
	        l_debugInfo := 'Getting next sequence from AP_INVOICE_LINES_INTERFACE_S';
 	        --------------------------------------------------------------------
		l_result := AP_WEB_DB_AP_INT_PKG.GetNextInvoiceLineId(
				l_invoice_line_id );
		IF ( l_result <> TRUE ) THEN
			l_invoice_line_id := NULL;
		END IF;

	 	/*Bug 2889204 : Setting the description for invoice line */
                --l_masked_cc_number := l_masked_cc_number||'/'||l_full_name;
                FND_MESSAGE.SET_NAME('SQLAP','OIE_INVOICE_DESC');
                l_description := FND_MESSAGE.GET;
                l_description := replace(l_description,'EMP_FULL_NAME',l_full_name);
                l_description := replace(l_description,'EMP_CARD_NUM',l_masked_cc_number);
                l_description := replace(l_description,'EXP_RPT_PURPOSE','');
                l_description := substrb(l_description,1,240);
                l_description := rtrim(l_description);

                IF substr(l_description, -1) = '-' THEN
                   l_description := substr(l_description,1, length(l_description) -1);
                END IF;

	        ---------------------------------------------------------------------
	        l_debugInfo := 'Inserting into AP_INVOICE_LINES_INTERFACE';
	        ---------------------------------------------------------------------
		l_result := AP_WEB_DB_AP_INT_PKG.InsertInvoiceLinesInterface(
				l_invoice_id,
				l_invoice_line_id,
				l_count,
				'ITEM',
				l_billed_amt,
				l_transaction_date,
				l_ccid,
				l_card_trxn_id,
                                l_description,
                                l_org_id );

	      ----------------------------------------------------------------------
	      l_debugInfo := 'Write to the log file regarding the progress of the operation';
	      ----------------------------------------------------------------------
              FND_FILE.PUT_LINE( FND_FILE.LOG, '	processing transaction id: ' || l_card_trxn_id );

	      ----------------------------------------------------------------------
	      l_debugInfo := 'Update AP_CREDIT_CARD_TRXNS_ALL.COMPANY_PREPAID_INVOICE_ID';
	      ----------------------------------------------------------------------
	      l_result := AP_WEB_DB_CCARD_PKG.SetCCTrxnInvoiceId(
				l_card_trxn_id,
				l_invoice_id );

	END LOOP;

	CLOSE l_ccard_trxn_cursor;
	END IF;

	----------------------------------------------------------------------
	l_debugInfo := 'Write to the log file regarding the progress of the operation';
	----------------------------------------------------------------------
	FND_FILE.PUT_LINE( FND_FILE.LOG, 'Total processed transactions: ' || l_count );
    	FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_CARD_TRXNS_DONE_ACK' );
    	FND_MESSAGE.SET_TOKEN( 'TOTAL_TRXNS_NUM', l_count );
    	FND_FILE.PUT_LINE( FND_FILE.OUTPUT, FND_MESSAGE.get );
	--
	-- create a summary invoice for this batch of credit card transactions
	--
	IF ( l_count > 0 )
	THEN
	-----------------------------------------------------------------------
	l_debugInfo := 'Retrieving vendor info from card program';
	-----------------------------------------------------------------------
		l_result := AP_WEB_DB_CCARD_PKG.GetCardProgramInfo(
				p_cardProgramID,
				l_vendor_id,
				l_vendor_site_id,
				l_invoice_currency_code );

	-----------------------------------------------------------------------
	l_debugInfo := 'Retrieving Party Id using Vendor Id';
	-----------------------------------------------------------------------
        select party_id
        into   l_party_id
        from   ap_suppliers
        where  vendor_id = l_vendor_id
        and    rownum = 1;

	-----------------------------------------------------------------------
	l_debugInfo := 'Retrieving Pay Group Lookup Code from po_vendors';
	-----------------------------------------------------------------------
		l_result := AP_WEB_DB_AP_INT_PKG.GetPayGroupLookupCode(
				l_vendor_id,
				l_vendor_site_id,
				l_pay_group_lookup_code);

        -----------------------------------------------------------------------
        l_debugInfo := 'Retrieving accts_pay_code_combination_id from po_vendors';
        -----------------------------------------------------------------------
        l_result := AP_WEB_DB_AP_INT_PKG.GetVendorCodeCombID(
                                l_vendor_id,
                                l_accts_pay_ccid);
	-- Bug 	6838894
        BEGIN
	  SELECT party_site_id, nvl(l_accts_pay_ccid,accts_pay_code_combination_id), terms_id
          INTO l_party_site_id, l_accts_pay_ccid, l_terms_id
	  FROM ap_supplier_sites
	  WHERE  vendor_site_id = l_vendor_site_id;
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	     l_party_site_id := null;
	     l_terms_id := null;
	  WHEN OTHERS THEN
	     AP_WEB_DB_UTIL_PKG.RaiseException( 'GetVendorSiteId' );
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

	-- Bug: 7234744 populate terms-id in the interface table.
	IF (l_terms_id IS NULL) THEN
	  BEGIN
	    SELECT terms_id
	    INTO l_terms_id
	    FROM ap_suppliers
	    WHERE vendor_id = l_vendor_id;
	  EXCEPTION
	    WHEN OTHERS THEN
	      l_terms_id := null;
	  END;
	END IF;

        -- UNIQUE:SEQ_NUMBERS takes values, A - Always Used , N  - Not Used ,  P - Partially Used
        IF (FND_PROFILE.VALUE('UNIQUE:SEQ_NUMBERS') = 'N') THEN
         l_doc_cat_code := NULL;
        END IF;
	------------------------------------------------------------------------
	l_debugInfo := 'Inserting into AP_INVOICES_INTERFACE';
	fnd_file.put_line(fnd_file.log, l_debugInfo);
	------------------------------------------------------------------------
		l_result := AP_WEB_DB_AP_INT_PKG.InsertInvoiceInterface(
			l_invoice_id,
			l_party_id,
			l_vendor_id,
			l_vendor_site_id,
			l_sum,
			l_invoice_currency_code,
			'SelfService',
			l_pay_group_lookup_code,
                        l_org_id,
                        l_doc_cat_code,-- Bug:7345524, replaced 'PAY REQ INV',
                        'PAYMENT REQUEST',
                        l_accts_pay_ccid,
			l_party_site_id,
                        l_terms_id);

		p_invoiceID := l_invoice_id;

		FND_FILE.PUT_LINE( FND_FILE.LOG, 'A record with invoice id = ' || l_invoice_id || ' is created' );
        	FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_CARD_NEW_INVOICE_ACK' );
        	FND_MESSAGE.SET_TOKEN( 'INVOICE_ID', l_invoice_id );
        	FND_FILE.PUT_LINE( FND_FILE.OUTPUT, FND_MESSAGE.get );

	  ------------------------------------------------------------------------
	  l_debugInfo := 'Submitting Payment Request';
          fnd_file.put_line(fnd_file.log, l_debugInfo);
	  ------------------------------------------------------------------------

          AP_IMPORT_INVOICES_PKG.g_debug_switch := 'Y';

          l_invoice_id_temp := l_invoice_id; -- Bug 6687752

          AP_IMPORT_INVOICES_PKG.SUBMIT_PAYMENT_REQUEST(
                p_api_version           => 1.0,
                p_invoice_interface_id  => l_invoice_id,
                p_budget_control        => 'N',
                p_needs_invoice_approval=> 'N',
                p_invoice_id            => l_invoice_id,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data,
                x_rejection_list        => l_rejection_list,
                p_calling_sequence      => 'AP_CREDIT_CARD_INVOICE_PKG.createCreditCardInvoice');

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

             /*
                Rejected invoice should be purged from the interface table
             */
             update ap_credit_card_trxns_all
             set    company_prepaid_invoice_id = null
             where  company_prepaid_invoice_id = l_invoice_id_temp -- Bug 6687752
             and    card_program_id = p_cardProgramID;

             /*
             delete from ap_interface_rejections
             where  parent_id = l_invoice_id;

             delete from ap_invoices_interface
             where  invoice_id = l_invoice_id;

             delete from ap_invoice_lines_interface
             where  invoice_id = l_invoice_id;
             */

             FOR i in l_rejection_list.FIRST .. l_rejection_list.LAST LOOP
                l_debugInfo := i||' Errors found interfacing data to AP ...';
                fnd_file.put_line(fnd_file.log, l_debugInfo);
                l_debugInfo := l_rejection_list(i).reject_lookup_code;
                fnd_file.put_line(fnd_file.log, l_debugInfo);
             END LOOP;

	     Else  -- Bug 8365869 start
             update ap_credit_card_trxns_all
             set    company_prepaid_invoice_id = l_invoice_id
             where  company_prepaid_invoice_id = l_invoice_id_temp -- Bug 8365869 update the company_prepaid_invoice_id as invoice_id in ap_invoices_all
             and    card_program_id = p_cardProgramID;
             -- Bug 8365869 end
             COMMIT;

          END IF;

	END IF;

EXCEPTION

	WHEN OTHERS THEN
    	BEGIN
		IF ( SQLCODE <> -20001 )
		THEN
			FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_DEBUG' );
			FND_MESSAGE.SET_TOKEN( 'ERROR', SQLERRM );
			FND_MESSAGE.SET_TOKEN( 'CALLING_SEQUENCE', 'createCreditCardInvoice' );
			FND_MESSAGE.SET_TOKEN( 'DEBUG_INFO', l_debugInfo );
			errbuf := FND_MESSAGE.get;
			retcode := 2;
                ELSE
                        -- Do not need to set the token since it has been done in the
                        -- child process
                        RAISE;
		END IF;
    	END;

END createCreditCardInvoice;   -- Enter further code below as specified in the Package spec.


PROCEDURE createCCardReversals(p_invoiceId          IN NUMBER,
                               p_expReportHeaderId  IN NUMBER,
                               p_glDate             IN DATE,
                               p_periodName         IN VARCHAR2)
IS
    l_cCardLineCursor AP_WEB_DB_EXPLINE_PKG.CCTrxnCursor;
    l_debugInfo     VARCHAR2(2000);
    l_clearingCCID   NUMBER;
    l_invoiceAmt    AP_WEB_DB_AP_INT_PKG.invLines_amount := 0;
    l_baseAmt       AP_WEB_DB_AP_INT_PKG.invAll_baseAmount;
    l_totalCCardAmt  NUMBER := 0;
    l_callingSequence varchar2(100);
    l_minAcctUnit   AP_WEB_DB_COUNTRY_PKG.curr_minAcctUnit ;
    l_precision     AP_WEB_DB_COUNTRY_PKG.curr_precision;
    l_exchangeRate  AP_WEB_DB_AP_INT_PKG.invAll_exchangeRate;
    l_prepaidInvId  AP_WEB_DB_CCARD_PKG.ccTrxn_companyPrepaidInvID;
    l_cCardLineAmt  AP_WEB_DB_EXPLINE_PKG.expLines_amount;
    l_cardProgramID NUMBER;
    l_Personal	    VARCHAR2(10);
    l_org_id        NUMBER;
    l_transaction_date DATE;
    l_employee_id      NUMBER;

BEGIN
    l_callingSequence := 'createCCardReversals';
    ------------------------------------------------------------------
    l_debugInfo := 'Get the invoice amount.';
    ------------------------------------------------------------------
    if (AP_WEB_DB_AP_INT_PKG.GetInvoiceAmt(p_invoiceId,l_invoiceAmt, l_exchangeRate,
                                           l_minAcctUnit, l_precision) <> true) then
        raise NO_DATA_FOUND;
    end if;

    ------------------------------------------------------------------
    l_debugInfo := 'Get the credit card report line cursor.';
    ----------------------------------------------------------------
    if (AP_WEB_DB_EXPLINE_PKG.GetCCardLineCursor(p_expReportHeaderId, l_cCardLineCursor) <> TRUE) THEN
        raise NO_DATA_FOUND;
    END IF;

    ------------------------------------------------------------------
    l_debugInfo := 'Create negative distribution lines in the invoice table.';
    ------------------------------------------------------------------
    LOOP
        FETCH l_cCardLineCursor INTO
            l_cCardLineAmt, l_prepaidInvId, l_cardProgramID, l_Personal, l_org_id,
            l_transaction_date,l_employee_id;
        EXIT WHEN l_cCardLineCursor%NOTFOUND;

	l_totalCCardAmt := l_totalCCardAmt + l_cCardLineAmt;

	IF (l_Personal <> 'PERSONAL') THEN

	-- Bug 3068119: CardProgramID passed to GetExpenseClearingCCID.
        IF (AP_WEB_DB_AP_INT_PKG.GetExpenseClearingCCID(l_clearingCCID,l_cardProgramID,
        	l_employee_id, l_transaction_date) <> true) then
                raise NO_DATA_FOUND;
        END IF;

        IF l_clearingCCID is null THEN
	          raise no_data_found;
        END IF;

        AP_WEB_WRAPPER_PKG.insert_dist(
                         p_invoice_id              => p_invoiceId,
			 p_Line_Type               => 'MISCELLANEOUS',
                         p_GL_Date                 => p_glDate,
                         p_Period_Name             => p_periodName,
                         p_Type_1099               => null,
                         p_Income_Tax_Region       => null,
                         p_Amount                  => (l_cCardLineAmt),
			 p_Vat_Code                => null,
			 p_Code_Combination_Id     => l_clearingCCID,
			 p_PA_Quantity             => null,
			 p_Description             => null,
                         p_Project_Acct_Cont       => null,
                       	 p_Project_Id          	   => null,
                       	 p_Task_Id             	   => null,
                       	 p_Expenditure_Type    	   => null,
                       	 p_Expenditure_Org_Id  	   => null,
                       	 p_Exp_item_date       	   => null,
                         p_Attribute_Category      => null,
                         p_Attribute1              => null,
                         p_Attribute2              => null,
                         p_Attribute3              => null,
                         p_Attribute4              => null,
                         p_Attribute5              => null,
                         p_Attribute6              => null,
                         p_Attribute7              => null,
                         p_Attribute8              => null,
                         p_Attribute9              => null,
                         p_Attribute10             => null,
                         p_Attribute11             => null,
                         p_Attribute12             => null,
                         p_Attribute13             => null,
                         p_Attribute14             => null,
                         p_Attribute15             => null,
			 p_invoice_distribution_id => null,
			 p_Tax_Code_Id             => null,
			 p_tax_recoverable_flag    => null,
			 p_tax_recovery_rate	   => null,
			 p_tax_code_override_flag  => null,
			 p_tax_recovery_override_flag => null,
			 p_po_distribution_id	   => null,
                         p_Calling_Sequence        => l_callingSequence,
                         p_company_prepaid_invoice_id => l_prepaidInvId,
                         p_cc_reversal_flag        => 'Y');
	END IF;
    END LOOP;
    CLOSE l_cCardLineCursor;

    --  Code Fix for bug 1930746.changed greater than to Not Equal to
    if (l_totalCCardAmt <> 0) then
        -------------------------------------------------------------------
        l_debugInfo := 'Update the invoice_amount.';
        -------------------------------------------------------------------
        l_invoiceAmt := l_invoiceAmt - l_totalCCardAmt;
        if (l_minAcctUnit is NULL) then
            l_baseAmt := ROUND(l_invoiceAmt*l_exchangeRate, l_precision);
        else
            l_baseAmt := ROUND(l_invoiceAmt*l_exchangeRate/l_minAcctUnit) * l_minAcctUnit;
        end if;
        if (AP_WEB_DB_AP_INT_PKG.SetInvoiceAmount(p_invoiceId, l_invoiceAmt, l_baseAmt) <> true) then
            raise NO_DATA_FOUND;
        end if;
    end if;

EXCEPTION
  When OTHERS then
   IF (SQLCODE <> -20001) THEN
	FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_DEBUG' );
	FND_MESSAGE.SET_TOKEN( 'ERROR', SQLERRM );
	FND_MESSAGE.SET_TOKEN( 'CALLING_SEQUENCE', l_callingSequence);
	FND_MESSAGE.SET_TOKEN( 'DEBUG_INFO', l_debugInfo );
	APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      -- Do not need to set the token since it has been done in the
      -- child process
      RAISE;
   END IF;
END createCCardReversals;

  ---------------------------------------------------------------
  FUNCTION createCreditCardReversals(p_invoiceId         IN NUMBER,
                                     p_expReportHeaderId IN NUMBER,
                                     p_gl_date           IN DATE,
                                     p_invoiceTotal      IN NUMBER)
    RETURN NUMBER IS
    l_cCardLineCursor AP_WEB_DB_EXPLINE_PKG.CCTrxnCursor;
    l_debugInfo       VARCHAR2(2000);
    l_clearingCCID    NUMBER;
    l_invoiceAmt      AP_WEB_DB_AP_INT_PKG.invLines_amount := p_invoiceTotal;
    l_totalCCardAmt   NUMBER := 0;
    l_prepaidInvId    AP_WEB_DB_CCARD_PKG.ccTrxn_companyPrepaidInvID;
    l_cCardLineAmt    AP_WEB_DB_EXPLINE_PKG.expLines_amount;
    l_cardProgramID   NUMBER;
    l_Personal        VARCHAR2(10);
    l_callingSequence varchar2(100);
    l_org_id          NUMBER;
    l_transaction_date DATE;
    l_employee_id      NUMBER;

  BEGIN
    l_callingSequence := 'createCreditCardReversals';
    ------------------------------------------------------------------
    l_debugInfo := 'Get the credit card report line cursor.';
    ------------------------------------------------------------------
    if (AP_WEB_DB_EXPLINE_PKG.GetCCardLineCursor(p_expReportHeaderId,
                                                 l_cCardLineCursor) <> TRUE) THEN
      raise NO_DATA_FOUND;
    END IF;

    --------------------------------------------------------------------------
    l_debugInfo := 'Create negative distribution lines in the invoice table.';
    --------------------------------------------------------------------------
    LOOP
      FETCH l_cCardLineCursor
        INTO l_cCardLineAmt, l_prepaidInvId, l_cardProgramID, l_Personal, l_org_id,
             l_transaction_date,l_employee_id;
      EXIT WHEN l_cCardLineCursor%NOTFOUND;

      l_totalCCardAmt := l_totalCCardAmt + l_cCardLineAmt;

      IF (l_Personal <> 'PERSONAL') THEN

	-- Bug 3068119: CardProgramID passed to GetExpenseClearingCCID.
        IF (AP_WEB_DB_AP_INT_PKG.GetExpenseClearingCCID(l_clearingCCID,l_cardProgramID,
        	l_employee_id, l_transaction_date) <> true) then
                raise NO_DATA_FOUND;
        END IF;

        IF l_clearingCCID is null THEN
	          raise no_data_found;
        END IF;

        INSERT INTO AP_INVOICE_LINES_INTERFACE
          (INVOICE_ID,
           INVOICE_LINE_ID,
           LINE_TYPE_LOOKUP_CODE,
           ACCOUNTING_DATE,
           AMOUNT,
           ASSETS_TRACKING_FLAG,
           DIST_CODE_COMBINATION_ID,
           ORG_ID,
	   CC_REVERSAL_FLAG)
          SELECT p_invoiceId,
                 AP_INVOICE_LINES_INTERFACE_S.nextval,
                 'MISCELLANEOUS',
                 p_gl_date,
                 -l_cCardLineAmt,
                 DECODE(nvl(gcc.account_type, 'x'),
                        'A',
                        'Y',
                        'N'),
                 l_clearingCCID,
                 l_org_id,
		 'Y'
            FROM gl_code_combinations GCC
           WHERE GCC.code_combination_id = l_clearingCCID;

      END IF;
    END LOOP;
    CLOSE l_cCardLineCursor;

    if (l_totalCCardAmt <> 0) then
      -------------------------------------------------------------------
      l_debugInfo := 'Update the invoice_amount.';
      -------------------------------------------------------------------
      l_invoiceAmt := l_invoiceAmt - l_totalCCardAmt;
    end if;
    RETURN l_invoiceAmt;
  EXCEPTION
    When OTHERS then
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_callingSequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debugInfo);
        APP_EXCEPTION.RAISE_EXCEPTION;
      ELSE
        -- Do not need to set the token since it has been done in the
        -- child process
        RAISE;
      END IF;
      NULL;
END createCreditCardReversals;

END AP_CREDIT_CARD_INVOICE_PKG;

/
