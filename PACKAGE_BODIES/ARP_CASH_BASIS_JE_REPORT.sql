--------------------------------------------------------
--  DDL for Package Body ARP_CASH_BASIS_JE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CASH_BASIS_JE_REPORT" AS
/* $Header: ARPLCBJB.pls 120.5 2005/06/14 18:49:55 vcrisost ship $    */

    -- RECORD holder for pertinent information about the cash receipt that drives
    -- the posting of an application
    TYPE ReceiptType IS RECORD
    (
        CashReceiptId             ar_cash_receipts.cash_receipt_id%TYPE,
        ReceiptNumber             ar_cash_receipts.receipt_number%TYPE,
        PayFromCustomer           ar_cash_receipts.pay_from_customer%TYPE,
        CustomerNumber            hz_cust_accounts.account_number%TYPE,
        CurrencyCode              ar_cash_receipts.currency_code%TYPE,
        ExchangeRate              NUMBER
    );
    --
    -- RECORD holder of information about the Trx to which the application
    -- is being applied when CM_PSID_Flag is 'N'
    -- If the CM_PSID_Flag is 'Y', this means that the PaymentScheduleId holds
    -- the ps_id of the CM if the application_type is 'CM', but the class
    -- and the TrxNumber still holds the invoice that the CM applies to.
    --
    TYPE TrxType IS RECORD
    (
        PaymentScheduleId            ar_payment_schedules.payment_schedule_id%TYPE,
        CmPsIdFlag		     VARCHAR2(1),
        TrxNumber                    ra_customer_trx.trx_number%TYPE,
        OrgId                        ra_customer_trx.org_id%TYPE
    );
    --
    -- RECORD holder for pertinent information from a receivable application
    -- of status = 'APP'
    TYPE ApplicationType IS RECORD
    (
        ReceivableApplicationId      ar_receivable_applications.receivable_application_id%TYPE,
        GLDate		                 DATE,    -- the gl date of the application
        TrxDate		                 DATE,    -- the apply date of the application
        AppType		             ar_receivable_applications.application_type%TYPE,
        CatMeaning		     ar_lookups.meaning%TYPE,
        PostingControlId	     ar_receivable_applications.posting_control_id%TYPE
    );
    --
    -- holds ApplicationAmount values
    --
    TYPE ApplicationAmountType IS RECORD
    (
        Amount                    NUMBER,
        AcctdAmount               NUMBER,
        LineApplied               NUMBER,
        TaxApplied                NUMBER,
        FreightApplied            NUMBER,
        ChargesApplied            NUMBER
    );
--
    TYPE IdType     IS TABLE OF NUMBER(15)   INDEX BY BINARY_INTEGER;
    TYPE AmountType IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;
    TYPE VC15Type   IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
    TYPE VC3Type    IS TABLE OF VARCHAR2(3)  INDEX BY BINARY_INTEGER;
--
--
    ArpcbpError     EXCEPTION;
    PRAGMA EXCEPTION_INIT( ArpcbpError, -20000 );
--
-- private procedures
--
    --
    -- Procedures to write Record Types using dbms_output
    --
    PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE Output( p IN ReceiptType ) IS
    BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('Output: ' ||  'Receipt Type' );
           arp_standard.debug('Output: ' ||  'CashReceiptId:'||p.CashReceiptId );
           arp_standard.debug('Output: ' ||  'ReceiptNumber:'||p.ReceiptNumber );
           arp_standard.debug('Output: ' ||  'PayFromCustomer:'||p.PayFromCustomer );
           arp_standard.debug('Output: ' ||  'CustomerNumber:'||p.CustomerNumber );
           arp_standard.debug('Output: ' ||  'CurrencyCode:'||p.CurrencyCode );
           arp_standard.debug('Output: ' ||  'ExchangeRate:'||p.ExchangeRate );
           arp_standard.debug('Output: ' ||  '' );
        END IF;
    END;
--
    PROCEDURE Output( p IN TrxType ) IS
    BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('Output: ' ||  'TrxType' );
           arp_standard.debug('Output: ' ||  'CmPsIdFlag:'||p.CmPsIdFlag );
           arp_standard.debug('Output: ' ||  'PaymentScheduleId:'||p.PaymentScheduleId );
           arp_standard.debug('Output: ' ||  'TrxNumber:'||p.TrxNumber );
           arp_standard.debug('Output: ' ||  'OrgId:'||p.orgid);
           arp_standard.debug('Output: ' ||  '' );
        END IF;
    END;
--
    PROCEDURE Output( p IN ApplicationType ) IS
    BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('Output: ' ||  'ApplicationType' );
           arp_standard.debug('Output: ' ||  'ReceivableApplicationId:'||p.ReceivableApplicationId );
           arp_standard.debug('Output: ' ||  'GLDate:'||p.GLDate );
           arp_standard.debug('Output: ' ||  'TrxDate:'||p.TrxDate );
           arp_standard.debug('Output: ' ||  'AppType:'||p.AppType );
           arp_standard.debug('Output: ' ||  'CatMeaning:'||p.CatMeaning );
           arp_standard.debug('Output: ' ||  'PostingControlId:'||p.PostingControlId );
           arp_standard.debug('Output: ' ||  '' );
        END IF;
    END;
--
    PROCEDURE Output( p IN ApplicationAmountType ) IS
    BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('Output: ' ||  'ApplicationAmountType' );
           arp_standard.debug('Output: ' ||  'Amount:'||p.Amount );
           arp_standard.debug('Output: ' ||  'AcctdAmount:'||p.AcctdAmount );
           arp_standard.debug('Output: ' ||  'LineApplied:'||p.LineApplied );
           arp_standard.debug('Output: ' ||  'TaxApplied:'||p.TaxApplied );
           arp_standard.debug('Output: ' ||  'FreightApplied:'||p.FreightApplied );
           arp_standard.debug('Output: ' ||  'ChargesApplied:'||p.ChargesApplied );
           arp_standard.debug('Output: ' ||  '' );
        END IF;
    END;
--
--
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      CurrentCBDApplications                                               |
 |                                                                           |
 |  DESCRIPTION                                                              |
 |      Populates the TABLE types passed to the procedure with the total     |
 |          amounts of a given type (LINE, TAX, FREIGHT, CHARGES, INVOICE)   |
 |          that are currently applied to a given payment schedule.          |
 |      The information is extracted from the ar_cash_basis_distributions    |
 |          table, and is returned ordered by source ('GL' then 'ADJ') and   |
 |          source_id (ra_cust_trx_line_gl_dist_id or adjustment_id )        |
 |  PARAMETERS                                                               |
 |      p_ps_id           Payment Schedule Id for which current              |
 |                            applications are required                      |
 |      p_type            The type of current applications required -        |
 |                            LINE, TAX, FREIGHT, CHARGES, INVOICE           |
 |      Source            OUT PL/SQL TABLE for the source of the line        |
 |      SourceId          OUT PL/SQL TABLE for the source id of the line     |
 |      Amount            OUT PL/SQL TABLE for the amount of the line        |
 |      NextElement       OUT BINARY_INTEGER Stores the Next Element to be   |
 |                          populated in the PL/SQL table (also, the number  |
 |                          of elements in the table                         |
 |      TotalAmount       SUM of the Amounts                                 |
 |                                                                           |
 |  EXCEPTIONS RAISED                                                        |
 |                                                                           |
 |  ERRORS RAISED                                                            |
 |                                                                           |
 |  KNOWN BUGS                                                               |
 |                                                                           |
 |  NOTES                                                                    |
 |                                                                           |
 |  HISTORY                                                                  |
 |    23-Jul-1993  Alan Fothergill    Created                                |
 *---------------------------------------------------------------------------*/
    PROCEDURE CurrentCBDApplications( p_ps_id     IN   NUMBER,
                                   p_type      IN   VARCHAR2,
				   p_req_id    IN   NUMBER,
                                   Source      OUT NOCOPY  VC3Type,
                                   SourceId    OUT NOCOPY IdType,
                                   Amount      OUT NOCOPY AmountType,
                                   NextElement OUT NOCOPY BINARY_INTEGER,
                                   TotalAmount OUT NOCOPY NUMBER,
				   TotalUnallocatedAmt OUT NOCOPY NUMBER
                                 ) IS
        l_TotalAmount   NUMBER := 0;
        l_TotalUnallocatedAmt   NUMBER := 0;
        l_NextElement   BINARY_INTEGER := 0;
--
        CURSOR CCA IS
        SELECT  SUM( cbd.amount )                       Amount,
                cbd.source                              Source,
                cbd.source_id                           SourceId,
                NVL(SUM( DECODE(cbd.source,
			'UNA', cbd.amount, 0 )),0)	UnallocatedAmt
        FROM    ar_cash_basis_distributions             cbd
        WHERE   cbd.payment_schedule_id = p_ps_id
	AND     cbd.type                = p_type
	AND 	(cbd.posting_control_id+0  > 0
		 or
		 cbd.posting_control_id+0 = - ( p_req_id +100 ))
        GROUP BY cbd.source,
                 cbd.source_id
        ORDER BY DECODE( cbd.source, 'GL', 1,
				     'ADJ',2,
				     'UNA',3 ),
                 cbd.source_id;
--
        PROCEDURE Output( p_RCa IN CCA%ROWTYPE ) IS
        BEGIN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Output: ' ||  'CCA%ROWTYPE' );
               arp_standard.debug('Output: ' ||  'Amount:'||p_RCa.Amount );
               arp_standard.debug('Output: ' ||  'Source:'||p_RCA.Source );
               arp_standard.debug('Output: ' ||  'SourceId:'||p_RCa.SourceId );
               arp_standard.debug('Output: ' ||  '--------------------------------' );
            END IF;
        END Output;
--
    BEGIN
        FOR RCA IN CCA LOOP
            BEGIN
                Source( l_NextElement )    := RCA.Source;
                SourceId( l_NextElement )  := RCA.SourceId;
                Amount( l_NextElement )    := RCA.Amount;
--
                l_TotalAmount := l_TotalAmount + RCA.Amount;
                l_NextElement := l_NextElement + 1;
		l_TotalUnallocatedAmt := l_TotalUnallocatedAmt + RCA.UnallocatedAmt;
--
            EXCEPTION
                WHEN OTHERS THEN
                    arp_standard.debug( 'Exception:CurrentCBDApplications.Loop:');
                    Output( Rca );
                    RAISE;
            END;
        END LOOP;
        TotalAmount := l_TotalAmount;
        NextElement := l_NextElement;
	TotalUnallocatedAmt := l_TotalUnallocatedAmt;
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( ' Exception:CurrentCBDApplications:' );
            arp_standard.debug( 'l_NextElement:'||l_NextElement );
            arp_standard.debug( 'l_TotalAmount:'||l_TotalAmount );
            RAISE;
    END;
--
--
--
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      CurrentRevDistribution                                               |
 |  DESCRIPTION                                                              |
 |      Populates PL/SQL tables with the current 'revenue' distribution of   |
 |        the given Payment Schedule for a given type.                       |
 |      For type 'LINE' the distributions include ra_cust_trx_line_gl_dist   |
 |        records of account_class 'REV' and adjustments where               |
 |        line_adjusted IS NOT NULL                                          |
 |      For type 'TAX' the distributions include ra_cust_trx_line_gl_dist    |
 |        records of account_class 'TAX' and adjustments where               |
 |        tax_adjusted IS NOT NULL                                           |
 |      For type 'FREIGHT' the distributions include ra_cust_trx_line_gl_dist|
 |        records of account_class 'FREIGHT' and adjustments where           |
 |        freight_adjusted IS NOT NULL                                       |
 |      For type 'CHARGES' the distributions include adjustments where       |
 |        receivables_charges_adjusted IS NOT NULL                           |
 |      For type 'INVOICE' the distributions include all                     |
 |        ra_cust_trx_line_gl_dist records and all adjustments               |
 |      The lines are returned ordered by Source ('GL' then 'ADJ' and then   |
 |        source_id (ra_cust_trx_line_gl_dist_id or adjustment_id )          |
 |                                                                           |
 |  PARAMETERS                                                               |
 |      p_Report       RECORD type that contains posting parameters            |
 |      p_ps_id      payment_schedule_id for which distribution is required  |
 |      p_type       type of distributions required LINE, TAX, FREIGHT,      |
 |                     CHARGES or INVOICE                                    |
 |      NextElement  Next element to be populated in table (also number of   |
 |                     elements in table)                                    |
 |      Source            OUT PL/SQL TABLE for the source of the line        |
 |      SourceId          OUT PL/SQL TABLE for the source id of the line     |
 |      Amount            OUT PL/SQL TABLE for the amount of the line        |
 |      NextElement       OUT BINARY_INTEGER Stores the Next Element to be   |
 |                          populated in the PL/SQL table (also, the number  |
 |                          of elements in the table                         |
 |      TotalAmount       SUM of the Amounts                                 |
 |  EXCEPTIONS RAISED                                                        |
 |                                                                           |
 |  ERRORS RAISED                                                            |
 |                                                                           |
 |  KNOWN BUGS                                                               |
 |                                                                           |
 |  NOTES                                                                    |
 |                                                                           |
 |  HISTORY                                                                  |
 |    23-Jul-1993  Alan Fothergill    Created                                |
 *---------------------------------------------------------------------------*/
    PROCEDURE CurrentRevDistribution ( p_Report       IN     ReportParametersType,
                                    p_ps_id      IN     NUMBER,
                                    p_type       IN     VARCHAR2, -- 'LINE' 'TAX' 'FREIGHT' 'CHARGES' 'INVOICE'
                                    NextElement  OUT NOCOPY   BINARY_INTEGER,
                                    Source       OUT NOCOPY   VC3Type,
                                    SourceId     OUT NOCOPY   IdType,
                                    Ccid         OUT NOCOPY   IdType,
                                    AccntClass   OUT NOCOPY   VC15Type,
                                    Amount       OUT NOCOPY   AmountType,
                                    TotalAmount  OUT NOCOPY   NUMBER
                       ) IS
        l_customer_trx_id        NUMBER(15);
        l_term_fraction          NUMBER;
        l_currency_code          VARCHAR2(15);
        l_Amount                 NUMBER;
        l_AmountReconcile        NUMBER;
        l_FirstInstallmentCode   VARCHAR2(12);
        l_NextElement            BINARY_INTEGER := 0;
        l_TotalAmount            NUMBER         := 0;
        l_FirstInstallmentFlag   VARCHAR2(1);
        charges_adjusted         NUMBER         := 0;
--
        CURSOR gl_dist_cursor( cp_ctid NUMBER, cp_type VARCHAR2 ) IS
        SELECT  ctlgd.cust_trx_line_gl_dist_id,
                ctlgd.amount                 amount,
                ctlgd.code_combination_id    ccid,
		substrb(decode(ctlgd.account_class,
				'REV','LINE',
				ctlgd.account_class),1,15) accntclass
        FROM    ra_cust_trx_line_gl_dist     ctlgd
        WHERE   ctlgd.customer_trx_id = cp_ctid
        AND     ctlgd.account_class   IN ( 'REV', 'TAX', 'FREIGHT','CHARGES' )  -- we are only interested in these classes
        AND     ctlgd.account_class   = DECODE
                                        (
                                            cp_type,
                                            'LINE', 'REV',
                                            'TAX',  'TAX',
                                            'FREIGHT', 'FREIGHT',
                                            'CHARGES', 'CHARGES',
                                            ctlgd.account_class
                                        )
        AND     ctlgd.cust_trx_line_gl_dist_id+0 < p_Report.NxtCustTrxLineGlDistId
        ORDER BY ctlgd.cust_trx_line_gl_dist_id;
--
        CURSOR adj_cursor( cp_ps_id NUMBER, cp_type VARCHAR2 ) IS
        SELECT  a.adjustment_id            adjustment_id,
                DECODE
                (
                    cp_type,
                    'LINE',    a.line_adjusted,
                    'TAX',     a.tax_adjusted,
                    'FREIGHT', a.freight_adjusted,
                    'CHARGES', a.receivables_charges_adjusted,
                    a.amount
                )                           amount,
                a.code_combination_id       ccid,
	        substrb(a.type,1,15)         accntclass
        FROM    ar_adjustments              a,
                ra_customer_trx             ct,
		ra_cust_trx_types           ctt
        WHERE   a.payment_schedule_id       = cp_ps_id
	AND     a.receivables_trx_id        <> -1
        AND     a.status                    = 'A'
	AND 	a.customer_trx_id	    = ct.customer_trx_id
	AND	ct.cust_trx_type_id	    = ctt.cust_trx_type_id
        AND (
	      ( ctt.creation_sign = 'N'
		AND
		DECODE
                (
                    cp_type,
                    'LINE',    a.line_adjusted,
                    'TAX',     a.tax_adjusted,
                    'FREIGHT', a.freight_adjusted,
                    'CHARGES', a.receivables_charges_adjusted,
                    a.amount
                ) < 0
	      )
	      OR
	      ( ctt.creation_sign <> 'N'
		AND
		DECODE
                (
                    cp_type,
                    'LINE',    a.line_adjusted,
                    'TAX',     a.tax_adjusted,
                    'FREIGHT', a.freight_adjusted,
                    'CHARGES', a.receivables_charges_adjusted,
                    a.amount
                ) > 0
	      )
	    )
        AND     a.adjustment_id+0 < p_Report.NxtAdjustmentId
        ORDER BY a.adjustment_id;
--
    BEGIN
        -- first get the ps details
        BEGIN
            SELECT  ps.customer_trx_id,
                    NVL(tl.relative_amount, 100 )/NVL( t.base_amount, 100 ),
                    t.first_installment_code,
                    ps.invoice_currency_code,
                    NVL
                    (
                        DECODE
                        (
                            p_Type,
                            'LINE',    ps.amount_line_items_original,
                            'TAX',     ps.tax_original,
                            'FREIGHT', ps.freight_original,
			    'CHARGES', ps.receivables_charges_charged,
                            'INVOICE', ps.amount_due_original,
                            0
                        ),
                        0
                    ),
                    DECODE
                    (
                        MIN(tl_first.sequence_num),
                        tl.sequence_num, 'Y',
                        'N'
                    )               first_installment_flag
	    INTO    l_customer_trx_id,
                    l_term_fraction,
                    l_FirstInstallmentCode,
                    l_currency_code,
                    l_AmountReconcile,
                    l_FirstInstallmentFlag
            FROM    ar_payment_schedules   ps,
                    ra_terms               t,
                    ra_terms_lines         tl,
                    ra_terms_lines         tl_first
            WHERE   ps.payment_schedule_id = p_ps_id
            AND     tl.term_id(+)          = ps.term_id
            AND     tl.sequence_num(+)     = ps.terms_sequence_number
            AND     t.term_id(+)           = tl.term_id
            AND     tl_first.term_id(+)    = t.term_id
            GROUP BY ps.customer_trx_id,
                     tl.relative_amount,
                     t.base_amount,
                     t.first_installment_code,
                     ps.invoice_currency_code,
                     ps.amount_line_items_original,
                     ps.tax_original,
                     ps.freight_original,
		     ps.receivables_charges_charged,
                     ps.amount_due_original,
                     tl.sequence_num;
        EXCEPTION
            WHEN OTHERS THEN
                arp_standard.debug( 'Exception:CurrentRevDistribution.Select PS Details:' );
                RAISE;
        END;
--
        FOR GlDistRecord IN gl_dist_cursor( l_customer_trx_id, p_type ) LOOP
            IF l_FirstInstallmentFlag = 'Y' AND l_FirstInstallmentCode = 'INCLUDE' AND p_Type IN ('TAX','FREIGHT') THEN
                l_Amount := GlDistRecord.Amount;
            ELSE
                l_Amount := arpcurr.CurrRound( GlDistRecord.amount * l_term_fraction, l_currency_code );
            END IF;
            Amount( l_NextElement )    := l_Amount;
            Source( l_NextElement )    := 'GL';
            SourceId( l_NextElement )  := GlDistRecord.cust_trx_line_gl_dist_id;
            Ccid( l_NextElement )      := GlDistRecord.ccid;
            AccntClass( l_NextElement )      := GlDistRecord.accntclass;
            l_TotalAmount              := l_TotalAmount + l_Amount;
            l_NextElement              := l_NextElement + 1;
        END LOOP;
--
        IF l_NextElement <> 0
        THEN
		IF ( p_type = 'CHARGES' ) AND ( l_TotalAmount <> 0 )
		THEN
			SELECT 	nvl(sum(nvl(receivables_charges_adjusted,0)),0)
                        INTO   	charges_adjusted
			FROM   	ar_adjustments
		        WHERE   payment_schedule_id	= p_ps_id
 			AND     status			= 'A'
		        AND     type in ('INVOICE','CHARGES');

			l_AmountReconcile := l_AmountReconcile - charges_adjusted;
		END IF;

		IF ( p_type = 'CHARGES' ) AND ( l_TotalAmount = 0 )
		THEN
			l_AmountReconcile := 0;
		END IF;

            -- place the reconcile amount on to the last distribution
            Amount( l_NextElement-1) := l_Amount +
                                            l_AmountReconcile - l_TotalAmount;
            l_TotalAmount := l_AmountReconcile;
        END IF;
--
        -- next get any adjustments
        FOR AdjRecord IN adj_cursor( p_ps_id, p_type ) LOOP
            Amount( l_NextElement )      := AdjRecord.amount;
            Source( l_NextElement )      := 'ADJ';
            SourceId( l_NextElement )    := AdjRecord.adjustment_id;
            Ccid( l_NextElement )        := AdjRecord.ccid;
            AccntClass( l_NextElement )        := AdjRecord.accntclass;
            l_TotalAmount                := l_TotalAmount + AdjRecord.Amount;
            l_NextElement := l_NextElement + 1;
        END LOOP;
--
        -- if the total amount comes to zero, report on this
--        IF l_TotalAmount = 0
--        THEN
--              arp_standard.debug( 'On ps_id:'||p_ps_id||' for Type:'||p_Type||' the Total Distribution=0');
--            arp_standard.debug( 'CurrentRevDistribution: TotalAmount = 0' );
--            arp_standard.debug( 'p_ps_id:'||p_ps_id );
--            arp_standard.debug( 'p_type:'||p_type );
--        END IF;
        TotalAmount := l_TotalAmount;
        NextElement := l_NextElement;
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:CurrentRevDistribution:' );
            arp_standard.debug( 'l_customer_trx_id:'||l_customer_trx_id );
            arp_standard.debug( 'l_term_fraction:'||l_term_fraction );
            arp_standard.debug( 'l_currency_code:'||l_currency_code );
            arp_standard.debug( 'l_Amount:'||l_Amount );
            arp_standard.debug( 'l_AmountReconcile:'||l_AmountReconcile );
            arp_standard.debug( 'l_FirstInstallmentCode:'||l_FirstInstallmentCode );
            arp_standard.debug( 'l_NextElement:'||l_NextElement );
            arp_standard.debug( 'l_TotalAmount:'||l_TotalAmount );
            arp_standard.debug( 'l_FirstInstallmentFlag:'||l_FirstInstallmentFlag );
            RAISE;
    END;
--
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      CreateInterim                                                        |
 |  DESCRIPTION                                                              |
 |      Inserts a record into ar_journal_interim                             |
 |  PARAMETERS                                                               |
 |                                                                           |
 |  EXCEPTIONS RAISED                                                        |
 |                                                                           |
 |  ERRORS RAISED                                                            |
 |                                                                           |
 |  KNOWN BUGS                                                               |
 |                                                                           |
 |  NOTES                                                                    |
 |                                                                           |
 |  HISTORY                                                                  |
 |    02-Jul-2004  Hiroshi Yoshihara  bug3718694 Created                     |
 *---------------------------------------------------------------------------*/
    PROCEDURE CreateInterim( p_interim_rec  IN ar_journal_interim%ROWTYPE) IS
    BEGIN
	INSERT INTO
	ar_journal_interim
	(
        status,
        actual_flag,
        request_id,
	created_by,
	date_created,
	set_of_books_id,
        je_source_name,
	je_category_name,
       	transaction_date,
	accounting_date,
	currency_code,
	code_combination_id,
	entered_dr,
	entered_cr,
	accounted_dr,
	accounted_cr,
        reference10,
        reference21,
	reference22,
	reference23,
	reference24,
	reference25,
	reference26,
	reference27,
	reference28,
	reference29,
	reference30,
        org_id
	)
       VALUES
       (
        p_interim_rec.status,
        p_interim_rec.actual_flag,
        p_interim_rec.request_id,
	p_interim_rec.created_by,
	p_interim_rec.date_created,
	p_interim_rec.set_of_books_id,
        p_interim_rec.je_source_name,
	p_interim_rec.je_category_name,
       	p_interim_rec.transaction_date,
	p_interim_rec.accounting_date,
	p_interim_rec.currency_code,
	p_interim_rec.code_combination_id,
	p_interim_rec.entered_dr,
	p_interim_rec.entered_cr,
	p_interim_rec.accounted_dr,
	p_interim_rec.accounted_cr,
        p_interim_rec.reference10,
        p_interim_rec.reference21,
	p_interim_rec.reference22,
	p_interim_rec.reference23,
	p_interim_rec.reference24,
	p_interim_rec.reference25,
	p_interim_rec.reference26,
	p_interim_rec.reference27,
	p_interim_rec.reference28,
	p_interim_rec.reference29,
	p_interim_rec.reference30,
        p_interim_rec.org_id
        );
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:CreateInterim:' );
            RAISE;
    END;
--
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      CreateDistribution                                                   |
 |  DESCRIPTION                                                              |
 |      Creates a distribution by inserting a record into                    |
 |        ar_cash_basis_distributions, and a record into ar_journal_interim  |
 |  PARAMETERS                                                               |
 |                                                                           |
 |  EXCEPTIONS RAISED                                                        |
 |                                                                           |
 |  ERRORS RAISED                                                            |
 |                                                                           |
 |  KNOWN BUGS                                                               |
 |                                                                           |
 |  NOTES                                                                    |
 |                                                                           |
 |  HISTORY                                                                  |
 |    23-Jul-1993  Alan Fothergill    Created                                |
 *---------------------------------------------------------------------------*/
    PROCEDURE CreateDistribution(  p_Report         IN ReportParametersType,
                                   p_Receipt      IN ReceiptType,
                                   p_Trx          IN TrxType,
                                   p_App          IN ApplicationType,
                                   p_Amount       IN NUMBER,
                                   p_AcctdAmount  IN NUMBER,
                                   p_Source       IN VARCHAR2,
                                   p_SourceId     IN NUMBER,
                                   p_Type         IN VARCHAR2,
                                   p_Ccid         IN NUMBER,
				   p_AccntClass   IN VARCHAR2 ) IS
        CashBasisDistributionId ar_cash_basis_distributions.cash_basis_distribution_id%TYPE;


    BEGIN
    IF p_Amount = 0 AND p_AcctdAmount = 0 THEN
	RETURN;
    END IF;
--
-- If the record has been posted, then just select the records from cash basis distribution table
--
   IF p_App.PostingControlId > 0
   THEN
        BEGIN
		INSERT INTO
		ar_journal_interim
		(
	        status,
	        actual_flag,
	        request_id,
		created_by,
		date_created,
		set_of_books_id,
	        je_source_name,
		je_category_name,
        	transaction_date,
		accounting_date,
		currency_code,
		code_combination_id,
		entered_dr,
		entered_cr,
		accounted_dr,
		accounted_cr,
	        reference10,
	        reference21,
		reference22,
		reference23,
		reference24,
		reference25,
		reference26,
		reference27,
		reference28,
		reference29,
		reference30,
                org_id
		)
		SELECT
                'NEW',                          -- status
                'A',                            -- actual flag
		p_Report.ReqId,		        -- request_id
                p_Report.CreatedBy,             -- created_by
                TRUNC( SYSDATE ),               -- date_created
                p_Report.SetOfBooksId,          -- set_of_books_id
                'Receivables',            -- user_je_source_name
                'Trade Receipts',                      -- user_je_category_name
                p_App.TrxDate,	                       -- trx_date
                p_App.GlDate,	                       -- accounting_date
                p_Receipt.CurrencyCode,                -- currency_code
                cbd.code_combination_id,               -- code_combination_id
                DECODE
                (
                    SIGN( cbd.amount ),
                    -1, -cbd.amount,
                    NULL
                ),                                     -- entered_dr
                DECODE
                (
                    SIGN( cbd.amount ),
                    -1, NULL,
                    cbd.amount
                ),                                     -- entered_cr
                DECODE
                (
                    SIGN( cbd.acctd_amount ),
                    -1, -cbd.acctd_amount,
                    NULL
                ),                                     -- accounted_dr
                DECODE
                (
                    SIGN( cbd.acctd_amount ),
                    -1, NULL,
                    cbd.acctd_amount
                ),                                     -- accounted_cr
		p_App.CatMeaning,			-- reference10,
                p_Report.ReqId,                        -- reference21,
                p_Receipt.CashReceiptId,               -- reference22,
                cbd.cash_basis_distribution_id,        -- reference23,
                p_Receipt.ReceiptNumber,               -- reference24,
                p_Trx.TrxNumber,                       -- reference25,
                p_Receipt.CustomerNumber,              -- reference26,
                p_Receipt.PayFromCustomer,             -- reference27,
		DECODE(
			P_App.AppType,
			'CM', 'CMAPP',
			'CASH','TRADE' ),		-- reference28,
		DECODE(
			P_App.AppType,
			'CASH', 'TRADE_APP',
			'CM',	DECODE(
					p_Trx.CmPsIdFlag,
					'Y', 'CMAPP_REC',
					'CMAPP_APP' )), -- reference29,
                'AR_CASH_BASIS_DISTRIBUTIONS',          -- reference30
                cbd.org_id
		FROM ar_cash_basis_distributions cbd
		WHERE cbd.posting_control_id+0 = p_App.PostingControlId
		AND   cbd.receivable_application_id = p_App.ReceivableApplicationId
		AND   cbd.payment_schedule_id = p_Trx.PaymentScheduleId
		AND   cbd.type = p_Type;
        EXCEPTION
            WHEN OTHERS THEN
                arp_standard.debug( 'Exception:CreateDistribution.InsertPostedAR:' );
                RAISE;
        END;
   ELSE
--
        SELECT  ar_cash_basis_distributions_s.NEXTVAL
        INTO    CashBasisDistributionId
        FROM    dual;
--
        BEGIN
--
--	Posting Control Id is -(req_id+100) is used to be an identifier
--	such that we can delete these records at the end of the process
--	We need to add 100 because pst_contrl_id of -1 to -100  are reserved
--	for other usage
--
            INSERT INTO ar_cash_basis_distributions
            (
                cash_basis_distribution_id,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                receivable_application_id,
                source,
                source_id,
                type,
                payment_schedule_id,
                gl_date,
                currency_code,
                amount,
                acctd_amount,
                code_combination_id,
                posting_control_id,
                gl_posted_date,
                org_id
            )
            VALUES
            (
                CashBasisDistributionId,
                p_Report.CreatedBy,
                TRUNC( SYSDATE ),
                p_Report.CreatedBy,
                TRUNC( SYSDATE ),
                p_App.ReceivableApplicationId,
                p_Source,
                p_SourceId,
                p_Type,
                p_Trx.PaymentScheduleId,
                p_App.GlDate,
                p_Receipt.CurrencyCode,
                p_Amount,
                p_AcctdAmount,
                p_Ccid,
                - ( p_Report.ReqId +100 ),
                TRUNC( SYSDATE ),
                p_trx.OrgId
            );
        EXCEPTION
            WHEN OTHERS THEN
                arp_standard.debug( 'Exception:CreateDistribution.InsertCBD:' );
                RAISE;
        END;
--
	-- bug3718694 Call CreateInterim procedure to insert record into
	-- ar_journal_interim .
	DECLARE
        	l_interim_rec  ar_journal_interim%ROWTYPE;
        BEGIN
		l_interim_rec.status := 'NEW';
		l_interim_rec.actual_flag := 'A';
		l_interim_rec.request_id := p_Report.ReqId;
		l_interim_rec.created_by := p_Report.CreatedBy;
		l_interim_rec.date_created := TRUNC( SYSDATE );
		l_interim_rec.set_of_books_id := p_Report.SetOfBooksId;
		l_interim_rec.je_source_name := 'Receivables';
		l_interim_rec.je_category_name := 'Trade Receipts';
		l_interim_rec.transaction_date := p_App.TrxDate;
		l_interim_rec.accounting_date := p_App.GlDate;
		l_interim_rec.currency_code := p_Receipt.CurrencyCode;
		l_interim_rec.code_combination_id := p_Ccid;

		IF p_Amount < 0
		THEN
		  l_interim_rec.entered_dr := -p_Amount ;
		ELSE
		  l_interim_rec.entered_cr := p_Amount ;
		END IF;

		IF p_AcctdAmount < 0
		THEN
		  l_interim_rec.accounted_dr := -p_AcctdAmount ;
		ELSE
		  l_interim_rec.accounted_cr := p_AcctdAmount ;
		END IF;

		l_interim_rec.reference10 := p_App.CatMeaning;
		l_interim_rec.reference21 := p_Report.ReqId;
		l_interim_rec.reference22 := p_Receipt.CashReceiptId;
		l_interim_rec.reference23 := CashBasisDistributionId;
		l_interim_rec.reference24 := p_Receipt.ReceiptNumber;
		l_interim_rec.reference25 := p_Trx.TrxNumber;
		l_interim_rec.reference26 := p_Receipt.CustomerNumber;
		l_interim_rec.reference27 := p_Receipt.PayFromCustomer;

		IF P_App.AppType = 'CM'
		THEN
		  l_interim_rec.reference28 := 'CMAPP';
		ELSIF P_App.AppType = 'CASH'
		THEN
		  l_interim_rec.reference28 := 'TRADE';
		END IF;

		IF P_App.AppType = 'CASH'
		THEN
		  l_interim_rec.reference29 := 'TRADE_APP';
		ELSIF P_App.AppType = 'CM'
		THEN
		  IF p_Trx.CmPsIdFlag = 'Y'
		  THEN
		    l_interim_rec.reference29 := 'CMAPP_REC';
		  ELSE
		    l_interim_rec.reference29 := 'CMAPP_APP';
		  END IF;
		END IF;

		l_interim_rec.reference30 := 'AR_CASH_BASIS_DISTRIBUTIONS';
                l_interim_rec.org_id      := p_trx.OrgId;

		CreateInterim ( l_interim_rec );
        EXCEPTION
            WHEN OTHERS THEN
                arp_standard.debug( 'Exception:CreateDistribution.InsertAR:' );
                RAISE;
        END;
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:CreateDistribution:' );
            RAISE;
    END;
--
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      DistributeApplicationType                                            |
 |  DESCRIPTION                                                              |
 |      An amount of a certain type is distributed to a payment schedule     |
 |      The procedure works by calculating what the pro-rated distributions  |
 |        should be when the current application is included, working out    |
 |        what the current applications are, and creating a distribution     |
 |        for the difference.                                                |
 |      Distributions are calculated and made at the line (gl dist or        |
 |        adjustment) level (rather than the account level)                  |
 |  PARAMETERS                                                               |
 |                                                                           |
 |  EXCEPTIONS RAISED                                                        |
 |                                                                           |
 |  ERRORS RAISED                                                            |
 |                                                                           |
 |  KNOWN BUGS                                                               |
 |                                                                           |
 |  NOTES                                                                    |
 |                                                                           |
 |  HISTORY                                                                  |
 |    23-Jul-1993  Alan Fothergill    Created                                |
 |    25-Aug-1993  Alan Fothergill    If the total of distributions of the   |
 |                                      invoice is zero, then post the       |
 |                                      application to the CBPBALANCE account|
 *---------------------------------------------------------------------------*/
    PROCEDURE DistributeApplicationType( p_Report        IN ReportParametersType,
                                         p_Receipt     IN ReceiptType,
                                         p_Trx         IN TrxType,
                                         p_App         IN ApplicationType,
                                         p_Type        IN VARCHAR2,
                                         p_Amount      IN NUMBER,
                                         p_AcctdAmount IN NUMBER ) IS
        CBD_Source        VC3Type;
        CBD_SourceId      IdType;
        CBD_Amount        AmountType;
        CBD_NextElement   BINARY_INTEGER;
        CBD_TotalAmount   NUMBER;
	CBD_TotalUnallocatedAmt	  NUMBER;
--
        CRD_Source        VC3Type;
        CRD_SourceId      IdType;
        CRD_Amount        AmountType;
        CRD_Ccid          IdType;
        CRD_AccntClass    VC15Type;
        CRD_NextElement   BINARY_INTEGER;
        CRD_TotalAmount   NUMBER;
--
        CBD_i BINARY_INTEGER;
        CRD_i BINARY_INTEGER;
--
        NewAppToLine              NUMBER;            -- the amount that will be applied to a line
                                                     --     after the current application has been made
        RunningNewAppToLine       NUMBER := 0;       -- this is the running total of NewAppToLine
                                                     --     the final NewAppToLine is adjusted
                                                     --     so that the value of RunningNewAppToLine is equal to
                                                     --     GrandTotalApplied
        GrandTotalApplied                NUMBER;
        AppToLineThisTime                NUMBER;     -- the actual amount posted, and stored in ar_cash_basis_distributions
        AcctdAppToLineThisTime           NUMBER;
        RunningAppToLineThisTime         NUMBER := 0;
        RunningAcctdAppToLineThisTime    NUMBER := 0;
    BEGIN
--
-- If the record has been posted, then just select the records from cash basis distribution table
--
   IF p_App.PostingControlId > 0
   THEN
	CreateDistribution( p_Report,
        	            p_Receipt,
	                    p_Trx,
	                    p_App,
		            p_Amount,
			    p_AcctdAmount,
			    '0',0,p_Type,0,'0' );
   ELSE
        CurrentRevDistribution (  p_Report,
                               p_Trx.PaymentScheduleId,
                               p_Type,
                               CRD_NextElement,
                               CRD_Source,
                               CRD_SourceId,
                               CRD_Ccid,
                               CRD_AccntClass,
                               CRD_Amount,
                               CRD_TotalAmount );
--
	CurrentCBDApplications( p_Trx.PaymentScheduleId,
                                 p_Type,
				p_Report.ReqId,
                                 CBD_Source,
                                 CBD_SourceId,
                                 CBD_Amount,
                                 CBD_NextElement,
                                 CBD_TotalAmount,
				 CBD_TotalUnallocatedAmt );
--
    	CBD_i := 0;
       	CRD_i := 0;
        GrandTotalApplied := CBD_TotalAmount + p_Amount;
--
        WHILE CRD_i <> CRD_NextElement
            LOOP
                IF ( CRD_i = CRD_NextElement - 1 ) AND
                   ( CRD_TotalAmount <> 0 )        AND
		   ( CBD_TotalUnallocatedAmt = 0 )
		THEN
                    -- this is the final distribution if Total Revenue Distribution is non-zero
		    -- and Cash Basis Clearing account is zero
                    NewAppToLine := GrandTotalApplied - RunningNewAppToLine;
                ELSE
		     IF CRD_TotalAmount = 0
		     THEN
			NewAppToLine := 0;
		     ELSE
	                NewAppToLine := arpcurr.CurrRound( CRD_Amount( CRD_i ) * GrandTotalApplied/
                                                 CRD_TotalAmount, p_Receipt.CurrencyCode );
		     END IF;
                END IF;
                RunningNewAppToLine := RunningNewAppToLine + NewAppToLine;
--
                IF CBD_i <> CBD_NextElement                    AND
                   CBD_Source( CBD_i )    = CRD_Source( CRD_i )  AND
                   CBD_SourceId( CBD_i )  = CRD_SourceId( CRD_i )
                -- the above is acceptable. If the first boolean fails, then
                -- the remainder will not be executed. Therefore, at the limit
                -- when CBD_i = CBD_NextElement, the remaining expressions will not
                -- be evaluated (which would have caused an unitilaised element
                -- to be accessed)
                THEN
                    -- amount to apply this time is equal to what the total application
                    -- should be, minus the amount already applied
                    AppToLineThisTime := NewAppToLine - CBD_Amount( CBD_i );
                    CBD_i := CBD_i + 1;
                ELSE
                    -- amount to apply this time is equal to what the total amount should
                    -- be, because there is not an existing appliation to the line
                    AppToLineThisTime := NewAppToLine;
                END IF;
                AcctdAppToLineThisTime := arpcurr.ReconcileAcctdAmounts( p_Receipt.ExchangeRate,
                                   p_Amount,            -- total of distributions reconciles to the applied amount
                                   p_AcctdAmount,
                                   AppToLineThisTime,
                                   RunningAppToLineThisTime,
                                   RunningAcctdAppToLineThisTime );
--
		IF AcctdAppToLineThisTime <> 0
		THEN
	                CreateDistribution( p_Report,
        	                            p_Receipt,
	                                    p_Trx,
	                                    p_App,
	                                    AppToLineThisTime,
	                                     AcctdAppToLineThisTime,
	                                     CRD_Source( CRD_i ),
	                                     CRD_SourceId( CRD_i ),
	                                    p_Type,
	                                    CRD_Ccid( CRD_i ),
	                                    CRD_AccntClass( CRD_i ) );
		END IF;
                CRD_i := CRD_i + 1;
	END LOOP;
--
--	Now if Total Revenue Distribution is zero
--	OR if Cash Basis Clearing account is non-zero,
--	Then we need to post to the Cash Basis Clearing account
--
       	IF ( CRD_TotalAmount = 0 )    OR
	   ( CBD_TotalUnallocatedAmt <> 0 )
	THEN
 	        NewAppToLine := GrandTotalApplied - RunningNewAppToLine;
                RunningNewAppToLine := RunningNewAppToLine + NewAppToLine;
           	AppToLineThisTime := NewAppToLine - CBD_TotalUnallocatedAmt;
                AcctdAppToLineThisTime := arpcurr.ReconcileAcctdAmounts( p_Receipt.ExchangeRate,
                                   p_Amount,            -- total of distributions reconciles to the applied amount
                                   p_AcctdAmount,
                                   AppToLineThisTime,
                                   RunningAppToLineThisTime,
                                   RunningAcctdAppToLineThisTime );
--
		IF AcctdAppToLineThisTime <> 0
		THEN
--
	                CreateDistribution( p_Report,
        	                            p_Receipt,
	                                    p_Trx,
	                                    p_App,
	                                    AppToLineThisTime,
	                                    AcctdAppToLineThisTime,
	                                    'UNA',
	                                    p_Report.SetOfBooksId,
	                                    p_Type,
	                                    p_Report.UnallocatedRevCcid,
	                                    'INVOICE' );
		END IF;
	END IF;
   END IF;
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:DistributeApplicationType:' );
            RAISE;
    END;
--
--
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      DistributeLTFApplication                                             |
 |  DESCRIPTION                                                              |
 |      Distribute the Line, Tax, Freight and Charges of an application      |
 |        separately                                                         |
 |  PARAMETERS                                                               |
 |                                                                           |
 |  EXCEPTIONS RAISED                                                        |
 |                                                                           |
 |  ERRORS RAISED                                                            |
 |                                                                           |
 |  KNOWN BUGS                                                               |
 |                                                                           |
 |  NOTES                                                                    |
 |                                                                           |
 |  HISTORY                                                                  |
 |    23-Jul-1993  Alan Fothergill    Created                                |
 *---------------------------------------------------------------------------*/
    PROCEDURE DistributeLTFApplication(  p_Report      IN ReportParametersType,
                                         p_Receipt   IN ReceiptType,
                                         p_Trx       IN TrxType,
                                         p_App       IN ApplicationType,
                                         p_AppAmount IN ApplicationAmountType ) IS
        RunningTotalAmount       NUMBER := 0;
        RunningTotalAcctdAmount  NUMBER := 0;
        AcctdAmount       NUMBER;
        SurplusAmount     NUMBER;
    BEGIN
        IF p_AppAmount.ChargesApplied <> 0 THEN
            AcctdAmount := arpcurr.ReconcileAcctdAmounts( p_Receipt.ExchangeRate,
                                           p_AppAmount.Amount,
                                           p_AppAmount.AcctdAmount,
                                           p_AppAmount.ChargesApplied,
                                           RunningTotalAmount,
                                           RunningTotalAcctdAmount );
            DistributeApplicationType( p_Report, p_Receipt, p_Trx, p_App, 'CHARGES', p_AppAmount.ChargesApplied, AcctdAmount );
        END IF;
--
        IF p_AppAmount.FreightApplied <> 0 THEN
            AcctdAmount := arpcurr.ReconcileAcctdAmounts( p_Receipt.ExchangeRate,
                                           p_AppAmount.Amount,
                                           p_AppAmount.AcctdAmount,
                                           p_AppAmount.FreightApplied,
                                           RunningTotalAmount,
                                           RunningTotalAcctdAmount );
            DistributeApplicationType( p_Report, p_Receipt, p_Trx, p_App, 'FREIGHT', p_AppAmount.FreightApplied, AcctdAmount );
        END IF;
--
        IF p_AppAmount.TaxApplied <> 0 THEN
            AcctdAmount := arpcurr.ReconcileAcctdAmounts( p_Receipt.ExchangeRate,
                                           p_AppAmount.Amount,
                                           p_AppAmount.AcctdAmount,
                                           p_AppAmount.TaxApplied,
                                           RunningTotalAmount,
                                           RunningTotalAcctdAmount );
            DistributeApplicationType( p_Report, p_Receipt,p_Trx,  p_App, 'TAX', p_AppAmount.TaxApplied, AcctdAmount );
        END IF;
--
        IF p_AppAmount.LineApplied <> 0 THEN
            AcctdAmount := arpcurr.ReconcileAcctdAmounts( p_Receipt.ExchangeRate,
                                           p_AppAmount.Amount,
                                           p_AppAmount.AcctdAmount,
                                           p_AppAmount.LineApplied,
                                           RunningTotalAmount,
                                           RunningTotalAcctdAmount );
            DistributeApplicationType( p_Report, p_Receipt, p_Trx, p_App, 'LINE', p_AppAmount.LineApplied, AcctdAmount );
        END IF;
--
        --
        -- if RunningTotalAmount doesn't equal the Amount on the application, then report on this, and
        --     treat the difference as a 'LINE' application
        --
/*
        SurplusAmount := p_AppAmount.Amount - RunningTotalAmount;
        IF SurplusAmount <> 0 THEN
            arp_standard.debug( 'DistributeLTFApplication' );
            arp_standard.debug( 'LTF Charges doesn''t equal application amount for ra_id:'||p_App.ReceivableApplicationId );
            arp_standard.debug( '----------------------------------------' );
            AcctdAmount := arpcurr.ReconcileAcctdAmounts( p_Receipt.ExchangeRate,
                                           p_AppAmount.Amount,
                                           p_AppAmount.AcctdAmount,
                                           SurplusAmount,
                                           RunningTotalAmount,
                                           RunningTotalAcctdAmount );
            DistributeApplicationType( p_Report, p_Receipt, p_Trx, p_App, 'LINE', SurplusAmount, AcctdAmount );
        END IF;
*/
--
--
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:DistributeLTFApplication:' );
            RAISE;
    END;
--
--
-- post ar_receivable_applications that have status UNAPP, UNID, ACC
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      ReportNonDistApplications                                     |
 |  DESCRIPTION                                                              |
 |      non-APP ar_receivable_applications records                           |
 |                                                                           |
 |                                                                           |
 |  PARAMETERS                                                               |
 |                                                                           |
 |  EXCEPTIONS RAISED                                                        |
 |                                                                           |
 |  ERRORS RAISED                                                            |
 |                                                                           |
 |  KNOWN BUGS                                                               |
 |                                                                           |
 |  NOTES                                                                    |
 |                                                                           |
 |  HISTORY                                                                  |
 |    12-Apr-1994  D Chu	    Created                                  |
 *---------------------------------------------------------------------------*/
    PROCEDURE ReportNonDistApplications( p_Report IN ReportParametersType  ) IS
        CURSOR CRa IS
        SELECT  ra.ROWID                               RaRowid,
                cr.cash_receipt_id                     CashReceiptId,
                cr.receipt_number                      ReceiptNumber,
                cr.pay_from_customer                   PayFromCustomer,
                cust.account_number                    CustomerNumber,
                cr.currency_code                       CurrencyCode,
                ra.receivable_application_id           ReceivableApplicationId,
                ra.gl_date                             GlDate,
                ra.apply_date                          TrxDate,
                ra.amount_applied                      Amount,
                ra.amount_applied_from                 AmountAppFrom,
                ra.acctd_amount_applied_from           AcctdAmount,
                ra.code_combination_id                 CodeCombinationId,
                ra.status                              Status,
		l_cat.meaning                          CatMeaning,
                cr.org_id                              OrgId
        FROM    ar_receivable_applications    ra,
                ar_cash_receipts              cr,
		hz_cust_accounts              cust,
		ar_lookups		      l_cat
	WHERE   ra.gl_date 			BETWEEN p_Report.GlDateFrom
			  	                    AND p_Report.GLDateTo
   	AND	nvl(ra.postable,'Y')		   = 'Y'
   	AND	nvl(ra.confirmed_flag,'Y')	   = 'Y'
        AND     ra.status                          <> 'APP'
        AND     cr.cash_receipt_id                 = ra.cash_receipt_id
	AND	cr.pay_from_customer               = cust.cust_account_id
        AND	l_cat.lookup_type 		   = 'ARRGTA_FUNCTION_MAPPING'
        AND 	l_cat.lookup_code 		   = decode(ra.amount_applied_from,
                                                       null,'TRADE_APP','CCURR_APP')
	AND 	cr.currency_code 		   = DECODE( p_Report.Currency,
								null,cr.currency_code,
								p_Report.Currency)
	AND	ra.application_type||'' 	   = 'CASH'
	AND	(p_Report.Trade			   = 'Y'
                  OR p_Report.Ccurr                = 'Y')
	AND 	( ra.posting_control_id            = DECODE( p_Report.PostedStatus,
								'BOTH', ra.posting_control_id,
								'UNPOSTED', -3,
								-8888 )
		OR
	      	  ra.posting_control_id 	   <> decode( p_Report.PostedStatus,
								'BOTH', -8888,
								'POSTED', -3,
								ra.posting_control_id) )
	AND 	NVL(ra.gl_posted_date,to_date('01-01-1952','DD-MM-YYYY'))
	      	 BETWEEN
	               	DECODE( p_Report.PostedStatus,
				'BOTH', nvl(ra.gl_posted_date,to_date('01-01-1952',
								    'DD-MM-YYYY')),
				'UNPOSTED',nvl(ra.gl_posted_date,to_date('01-01-1952',
								  'DD-MM-YYYY')),
				'POSTED', decode( p_Report.PostedDateFrom ,
					    null, nvl(ra.gl_posted_date,to_date('01-01-1952',
								  'DD-MM-YYYY')),
		                      	    p_Report.PostedDateFrom))
               	AND
	               	DECODE( p_Report.PostedStatus,
				'BOTH', nvl(ra.gl_posted_date,to_date('01-01-1952',
								    'DD-MM-YYYY')),
				'UNPOSTED',nvl(ra.gl_posted_date,to_date('01-01-1952',
								  'DD-MM-YYYY')),
				'POSTED', decode( p_Report.PostedDateTo,
					    null, nvl(ra.gl_posted_date,to_date('01-01-1952',
								  'DD-MM-YYYY')),
		                      	    p_Report.PostedDateTo))
        AND     ra.receivable_application_id+0     <  p_Report.NxtReceivableApplicationId;
--
	l_Count			NUMBER  :=0;

    BEGIN
        arp_standard.debug( ' ' );
        arp_standard.debug( '      AR_RECEIVABLE_APPLICATIONS (non-app)...' );
        FOR RRa IN CRa
        LOOP
	    -- bug3718694 Call CreateInterim procedure to insert record into
	    -- ar_journal_interim .
	    DECLARE
		l_interim_rec  ar_journal_interim%ROWTYPE;

            BEGIN
		l_interim_rec.status := 'NEW';
		l_interim_rec.actual_flag := 'A';
		l_interim_rec.request_id := p_Report.ReqId;
		l_interim_rec.created_by := p_Report.CreatedBy;
		l_interim_rec.date_created := TRUNC( SYSDATE );
		l_interim_rec.set_of_books_id := p_Report.SetOfBooksId;
		l_interim_rec.je_source_name := 'Receivables';

		IF RRa.AmountAppFrom IS NULL
		THEN
		  l_interim_rec.je_category_name := 'Trade Receipts';
		ELSE
		  l_interim_rec.je_category_name := 'Cross Currency';
		END IF;

		l_interim_rec.transaction_date := RRa.TrxDate;
		l_interim_rec.accounting_date := RRa.GlDate;
		l_interim_rec.currency_code := RRa.CurrencyCode;
		l_interim_rec.code_combination_id := RRa.CodeCombinationId;

		IF RRa.amount < 0
		THEN
		  l_interim_rec.entered_dr := -nvl(RRa.AmountAppFrom,RRa.amount);
		ELSE
		  l_interim_rec.entered_cr := nvl(RRa.AmountAppFrom,RRa.amount);
		END IF;

		IF RRa.AcctdAmount < 0
		THEN
		  l_interim_rec.accounted_dr := -RRa.AcctdAmount;
		ELSE
		  l_interim_rec.accounted_cr := RRa.AcctdAmount;
		END IF;

		l_interim_rec.reference10 := RRa.CatMeaning;
		l_interim_rec.reference21 := p_Report.ReqId;
		l_interim_rec.reference22 := RRa.CashReceiptId;
		l_interim_rec.reference23 := RRa.ReceivableApplicationId;
		l_interim_rec.reference24 := RRa.ReceiptNumber;
		l_interim_rec.reference25 := NULL;
		l_interim_rec.reference26 := RRa.CustomerNumber;
		l_interim_rec.reference27 := RRa.PayFromCustomer;

		IF RRa.AmountAppFrom IS NULL
		THEN
		  l_interim_rec.reference28 := 'TRADE';
		ELSE
		  l_interim_rec.reference28 := 'CROSS CURR';
		END IF;

		IF RRa.AmountAppFrom IS NULL
		THEN
		  l_interim_rec.reference29 := 'TRADE_APP';
		ELSE
		  l_interim_rec.reference29 := 'CCURR_APP';
		END IF;

		l_interim_rec.reference30 := 'AR_RECEIVABL_APPLICATIONS';
                l_interim_rec.org_id      := RRa.OrgId;

		CreateInterim ( l_interim_rec ) ;

            EXCEPTION
                WHEN OTHERS THEN
                    arp_standard.debug( 'Exception:ReportNonDistApplications.INSERT:' );
                    arp_standard.debug('RRa.CashReceiptId:'||RRa.CashReceiptId );
                    arp_standard.debug('RRa.ReceiptNumber:'||RRa.ReceiptNumber );
                    arp_standard.debug('RRa.PayFromCustomer:'||RRa.PayFromCustomer );
                    arp_standard.debug('RRa.CustomerNumber:'||RRa.CustomerNumber );
                    arp_standard.debug('RRa.CurrencyCode:'||RRa.CurrencyCode );
                    arp_standard.debug('RRa.ReceivableApplicationId:'||RRa.ReceivableApplicationId );
                    arp_standard.debug('RRa.GlDate:'||RRa.GlDate );
                    arp_standard.debug('RRa.TrxDate:'||RRa.TrxDate );
                    arp_standard.debug('RRa.Amount:'||RRa.Amount );
                    arp_standard.debug('RRa.AcctdAmount:'||RRa.AcctdAmount );
                    arp_standard.debug('RRa.CodeCombinationId:'||RRa.CodeCombinationId );
                    arp_standard.debug('RRa.Status:'||RRa.Status );
                    arp_standard.debug('RRa.CatMeaning:'||RRa.CatMeaning );
                    RAISE;
            END;
--
	     l_Count := l_Count + 1;
        END LOOP;
        arp_standard.debug( '         '||l_Count||' lines selected' );
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:ReportNonDistApplications:' );
            RAISE;
    END;
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      ReportDistributedApplications                                        |
 |                                                                           |
 |  DESCRIPTION                                                              |
 |      post unposted ar_receivable_applications records		     |
 |      post unposted ar_receivable_applications records		     |
 |      We need to have ORDER BY clause in the select statement because      |
 |      when comparing with GL Transfer entries, they need to match,         |
 |      If order by is not used, there will be rounding difference.          |
 |                                                                           |
 |  PARAMETERS                                                               |
 |                                                                           |
 |  EXCEPTIONS RAISED                                                        |
 |                                                                           |
 |  ERRORS RAISED                                                            |
 |                                                                           |
 |  KNOWN BUGS                                                               |
 |                                                                           |
 |  NOTES                                                                    |
 |                                                                           |
 |  HISTORY                                                                  |
 |    23-Jul-1993  Alan Fothergill    Created                                |
 *---------------------------------------------------------------------------*/
    PROCEDURE ReportDistributedApplications( p_Report IN ReportParametersType  ) IS
        CURSOR CRa IS
        SELECT  ra.ROWID                               ra_rowid,
                DECODE(
			ra.application_type,
			'CM', ctcm.customer_trx_id,
			'CASH',cr.cash_receipt_id )    CashReceiptId,
                DECODE(
			ra.application_type,
			'CM', ctcm.trx_number,
			'CASH',cr.receipt_number )     ReceiptNumber,
                DECODE(
			ra.application_type,
			'CM', ctcm.bill_to_customer_id,
			'CASH',cr.pay_from_customer )  PayFromCustomer,
		cust.account_number		       CustomerNumber,
                ct.invoice_currency_code               CurrencyCode,
                DECODE(
			ra.application_type,
			'CM', NVL(ctcm.exchange_rate,1),
			'CASH',NVL(crh.exchange_rate,1) )  ExchangeRate,
		DECODE(
			l.lookup_code,
			'1', 'N',
			'2', 'Y'
			)			       CmPsIdFlag,
		DECODE(
			l.lookup_code,
			'1', ra.applied_payment_schedule_id,
			'2', ra.payment_schedule_id
			)			       PaymentScheduleId,
                ctt.type                               Class,
                ct.trx_number                          TrxNumber,
                ra.receivable_application_id           ReceivableApplicationId,
                ra.apply_date                          TrxDate,
                ra.gl_date                             GlDate,
		ra.application_type                    AppType,
		DECODE(
			l.lookup_code,
			'1', ra.amount_applied,
			'2', -ra.amount_applied
			)			       Amount,
		DECODE(
			l.lookup_code,
			'1', ra.acctd_amount_applied_from,
			'2', -ra.acctd_amount_applied_from
			)			       AcctdAmount,
		DECODE(
			l.lookup_code,
			'1', NVL(ra.line_applied,0),
			'2', NVL(-ra.line_applied,0)
			)			       LineApplied,
		DECODE(
			l.lookup_code,
			'1', NVL(ra.tax_applied,0),
			'2', NVL(-ra.tax_applied,0)
			)			       TaxApplied,
		DECODE(
			l.lookup_code,
			'1', NVL(ra.freight_applied,0),
			'2', NVL(-ra.freight_applied,0)
			)			       FreightApplied,
		DECODE(
			l.lookup_code,
			'1', NVL(ra.receivables_charges_applied,0),
			'2', NVL(-ra.receivables_charges_applied,0)
			)			       ChargesApplied,
		l_cat.meaning				CatMeaning,
		ra.posting_control_id			PostingControlId,
                ct.org_id                              OrgID
        FROM    ar_receivable_applications    ra,
                ra_cust_trx_types             ctt,
                ra_customer_trx               ct,
                ar_cash_receipts              cr,
                ar_cash_receipt_history       crh,
		ra_customer_trx               ctcm,
		ar_lookups	 	      l,
	        ar_lookups 		      l_cat,
		hz_cust_accounts              cust
	WHERE   ra.gl_date 			BETWEEN p_Report.GlDateFrom
			  	                    AND p_Report.GLDateTo
   	AND	nvl(ra.postable,'Y')		   = 'Y'
   	AND	nvl(ra.confirmed_flag,'Y')	   = 'Y'
        AND     ra.status||''                      = 'APP'
	AND 	ra.cash_receipt_id 		   = cr.cash_receipt_id(+)
	AND	ra.cash_receipt_history_id 	   = crh.cash_receipt_history_id(+)
	AND     ra.customer_trx_id		   = ctcm.customer_trx_id(+)
	AND	ctcm.previous_customer_trx_id	   IS NULL
	AND 	ra.applied_customer_trx_id 	   = ct.customer_trx_id
	AND 	ct.cust_trx_type_id     	   = ctt.cust_trx_type_id
	AND	l.lookup_type			   = 'AR_CARTESIAN_JOIN'
	AND 	(
	     		( l.lookup_code ='1' )
	     		OR
	 	     	( l.lookup_code = '2'
        	       	  AND
	               	  ra.application_type = 'CM' )
 	    	)
	AND	cust.cust_account_id 		   = DECODE( ra.application_type,
								'CM', ctcm.bill_to_customer_id,
								cr.pay_from_customer )
        AND     l_cat.lookup_type 	      = 'ARRGTA_FUNCTION_MAPPING'
        AND 	l_cat.lookup_code 	      = decode( ra.application_type,
		                                       'CM', decode( l.lookup_code,
									'1', 'CMAPP_APP',
									'2', 'CMAPP_REC'),
							'TRADE_APP')
	AND 	ct.invoice_currency_code 		   = DECODE( p_Report.Currency,
								null,ct.invoice_currency_code,
								p_Report.Currency)
	AND	( ( p_Report.Trade = 'Y'  AND ra.application_type||'' = 'CASH' )
		  OR
		  ( p_Report.CMApp = 'Y'  AND ra.application_type||'' = 'CM' ) )
	AND 	( ra.posting_control_id            = DECODE( p_Report.PostedStatus,
								'BOTH', ra.posting_control_id,
								'UNPOSTED', -3,
								-8888 )
		OR
	      	  ra.posting_control_id 	   <> decode( p_Report.PostedStatus,
								'BOTH', -8888,
								'POSTED', -3,
								ra.posting_control_id) )
	AND 	NVL(ra.gl_posted_date,to_date('01-01-1952','DD-MM-YYYY'))
	      	 BETWEEN
	               	DECODE( p_Report.PostedStatus,
				'BOTH', nvl(ra.gl_posted_date,to_date('01-01-1952',
								    'DD-MM-YYYY')),
				'UNPOSTED',nvl(ra.gl_posted_date,to_date('01-01-1952',
								  'DD-MM-YYYY')),
				'POSTED', decode( p_Report.PostedDateFrom ,
					    null, nvl(ra.gl_posted_date,to_date('01-01-1952',
								  'DD-MM-YYYY')),
		                      	    p_Report.PostedDateFrom))
               	AND
	               	DECODE( p_Report.PostedStatus,
				'BOTH', nvl(ra.gl_posted_date,to_date('01-01-1952',
								    'DD-MM-YYYY')),
				'UNPOSTED',nvl(ra.gl_posted_date,to_date('01-01-1952',
								  'DD-MM-YYYY')),
				'POSTED', decode( p_Report.PostedDateTo,
					    null, nvl(ra.gl_posted_date,to_date('01-01-1952',
								  'DD-MM-YYYY')),
		                      	    p_Report.PostedDateTo))
        AND     ra.receivable_application_id+0     <  p_Report.NxtReceivableApplicationId
        ORDER BY ra.receivable_application_id, l.lookup_code;
--
        l_Rowid                 ROWID;
        l_Receipt               ReceiptType;
        l_Trx                   TrxType;
        l_App                   ApplicationType;
        l_AppAmount             ApplicationAmountType;
	l_Count			NUMBER  :=0;
        l_Class                   VARCHAR2(20);
    BEGIN
        arp_standard.debug( ' ' );
        arp_standard.debug( '      AR_RECEIVABLE_APPLICATION (app)...' );
        OPEN CRa;
        LOOP
            FETCH   CRa
            INTO    l_rowid,
                    l_Receipt.CashReceiptId,
                    l_Receipt.ReceiptNumber,
                    l_Receipt.PayFromCustomer,
                    l_Receipt.CustomerNumber,
                    l_Receipt.CurrencyCode,
                    l_Receipt.ExchangeRate,
                    l_Trx.CmPsIdFlag,
                    l_Trx.PaymentScheduleId,
		    l_Class,
                    l_Trx.TrxNumber,
                    l_App.ReceivableApplicationId,
                    l_App.TrxDate,
                    l_App.GlDate,
		    l_App.AppType,
                    l_AppAmount.Amount,
                    l_AppAmount.AcctdAmount,
                    l_AppAmount.LineApplied,
                    l_AppAmount.TaxApplied,
                    l_AppAmount.FreightApplied,
                    l_AppAmount.ChargesApplied,
		    l_App.CatMeaning,
		    l_App.PostingControlId,
                    l_Trx.OrgId;
            EXIT WHEN CRa%NOTFOUND;
--
	    IF (l_Class = 'CM') OR (l_Trx.CmPsIdFlag = 'Y')
	    THEN
	    	DistributeApplicationType( p_Report, l_Receipt, l_Trx, l_App, 'INVOICE', l_AppAmount.Amount, l_AppAmount.AcctdAmount );
	    ELSE
  	    	DistributeLTFApplication( p_Report, l_Receipt, l_Trx, l_App, l_AppAmount );
	    END IF;
--
	    IF l_Trx.CmPsIdFlag <> 'Y'
	    THEN
		l_Count := l_Count + 1;
	    END IF;
--
        END LOOP;
        CLOSE Cra;
        arp_standard.debug( '         '||l_Count||' lines selected' );
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:ReportDistributedApplications:' );
            Output( l_AppAmount );
            Output( l_App );
            Output( l_Trx );
            Output( l_Receipt );
            RAISE;
    END;
--
--
--  finds unposted cash receipt history records in the period.
--
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      ReportCashReceiptHistory                                             |
 |  DESCRIPTION                                                              |
 |     cash receipt history records                                          |
 |  PARAMETERS                                                               |
 |                                                                           |
 |  EXCEPTIONS RAISED                                                        |
 |                                                                           |
 |  ERRORS RAISED                                                            |
 |                                                                           |
 |  KNOWN BUGS                                                               |
 |                                                                           |
 |  NOTES                                                                    |
 |      This is implemented as two cursors one to select cash receipt history|
 |        the other to select reversals. It had to be implemented this way   |
 |        because FOR UPDATE OF is not allowed in a UNION                    |
 |      The two selects must be maintained in parallel, as the InsertIntoAR  |
 |        relies on the ROWTYPE of each select cursor being the same         |
 |                                                                           |
 |  HISTORY                                                                  |
 |    12-Apr-1994  D Chu	    Created                                  |
 |    21-Mar-1995  C Aldamiz	    Modified for 10.6			     |
 *---------------------------------------------------------------------------*/
    PROCEDURE ReportCashReceiptHistory( p_Report IN ReportParametersType ) IS
        CURSOR CCrh IS
        SELECT  crh.ROWID                            CrhRowid,
                crh.cash_receipt_history_id          CashReceiptHistoryId,
                crh.cash_receipt_id                  CashReceiptId,
                cr.receipt_number                    ReceiptNumber,
                cr.pay_from_customer                 PayFromCustomer,
                cust.account_number                  CustomerNumber,
                DECODE
                (
                    cr.type,
                    'MISC', 'MISC',
                    'TRADE'
                )                                    ModifiedType,
                nvl(d.amount_dr, -d.amount_cr)       Amount,
                nvl(d.acctd_amount_dr, -d.acctd_amount_cr) AcctdAmount,
                d.code_combination_id      	     AccountCodeCombinationId,
                crh.gl_date                          GlDate,
                crh.trx_date                         TrxDate,
                cr.currency_code                     CurrencyCode,
                DECODE
                (
                    cr.type,
                    'MISC', 'Misc Receipts',
                    'Trade Receipts'
                )                                    Category,
		l_cat.meaning			     CatMeaning,
		d.source_type			     SourceType,
                cr.org_id                            OrgId
        FROM    ar_cash_receipt_history       crh,
                ar_cash_receipts              cr,
		hz_cust_accounts              cust,
		ar_lookups		      l_cat,
		ar_distributions	      d
	WHERE   crh.gl_date 			BETWEEN p_Report.GlDateFrom
			  	                    AND p_Report.GLDateTo
        AND     crh.postable_flag             = 'Y'
        AND     cr.cash_receipt_id            = crh.cash_receipt_id
	AND	cust.cust_account_id(+)	      = cr.pay_from_customer
        AND     l_cat.lookup_type 	      = 'ARRGTA_FUNCTION_MAPPING'
        AND 	l_cat.lookup_code 	      = decode( cr.type,
		                                       'MISC', 'MISC_',
		                                       'TRADE_')||'CASH'
	AND 	cr.currency_code 		   = DECODE( p_Report.Currency,
							null,cr.currency_code,
							p_Report.Currency)
	AND	( ( p_Report.Trade = 'Y'  AND cr.type = 'CASH' )
		  OR
		  ( p_Report.Misc = 'Y'  AND cr.type = 'MISC' ) )
	AND 	( crh.posting_control_id = DECODE( p_Report.PostedStatus,
						'BOTH', crh.posting_control_id,
						'UNPOSTED', -3,
						-8888 )
		OR
	      	  crh.posting_control_id    <> decode( p_Report.PostedStatus,
							'BOTH', -8888,
							'POSTED', -3,
							crh.posting_control_id))
	AND 	NVL(crh.gl_posted_date,to_date('01-01-1952','DD-MM-YYYY'))
	      	 BETWEEN
	               	DECODE( p_Report.PostedStatus,
				'BOTH', nvl(crh.gl_posted_date,to_date('01-01-1952',
								    'DD-MM-YYYY')),
				'UNPOSTED',nvl(crh.gl_posted_date,to_date('01-01-1952',
								  'DD-MM-YYYY')),
				'POSTED', decode( p_Report.PostedDateFrom ,
					    null, nvl(crh.gl_posted_date,to_date('01-01-1952',
								  'DD-MM-YYYY')),
		                      	    p_Report.PostedDateFrom))
               	AND
	               	DECODE( p_Report.PostedStatus,
				'BOTH', nvl(crh.gl_posted_date,to_date('01-01-1952',
								    'DD-MM-YYYY')),
				'UNPOSTED',nvl(crh.gl_posted_date,to_date('01-01-1952',
								  'DD-MM-YYYY')),
				'POSTED', decode( p_Report.PostedDateTo,
					    null, nvl(crh.gl_posted_date,to_date('01-01-1952',
								  'DD-MM-YYYY')),
		                      	    p_Report.PostedDateTo))
	AND	crh.cash_receipt_history_id = d.source_id
	AND	d.source_table = 'CRH'
        AND     crh.cash_receipt_history_id+0 < p_Report.NxtCashReceiptHistoryId;

--
        RCrh  CCrh%ROWTYPE;
	l_Count			NUMBER  :=0;
--
	-- bug3718694 Call CreateInterim procedure to insert record into
	-- ar_journal_interim .
        PROCEDURE InsertIntoAR( RCrh IN CCrh%ROWTYPE ) IS
		l_interim_rec  ar_journal_interim%ROWTYPE;
        BEGIN
		l_interim_rec.status := 'NEW';
		l_interim_rec.actual_flag := 'A';
		l_interim_rec.request_id := p_Report.ReqId;
		l_interim_rec.created_by := p_Report.CreatedBy;
		l_interim_rec.date_created := TRUNC( SYSDATE );
		l_interim_rec.set_of_books_id := p_Report.SetOfBooksId;
		l_interim_rec.je_source_name := 'Receivables';
		l_interim_rec.je_category_name := RCrh.Category;
		l_interim_rec.transaction_date := RCrh.TrxDate;
		l_interim_rec.accounting_date := RCrh.GlDate;
		l_interim_rec.currency_code := RCrh.CurrencyCode;
		l_interim_rec.code_combination_id := RCrh.AccountCodeCombinationId;

		IF RCrh.Amount < 0
		THEN
		  l_interim_rec.entered_cr := -RCrh.Amount ;
		ELSE
		  l_interim_rec.entered_dr := RCrh.Amount ;
		END IF;

		IF RCrh.AcctdAmount < 0
		THEN
		  l_interim_rec.accounted_cr := -RCrh.AcctdAmount ;
		ELSE
		  l_interim_rec.accounted_dr := RCrh.AcctdAmount ;
		END IF;

		l_interim_rec.reference10 := RCrh.CatMeaning;
		l_interim_rec.reference21 := p_Report.ReqId;
		l_interim_rec.reference22 := RCrh.CashReceiptId;
		l_interim_rec.reference23 := RCrh.CashReceiptHistoryId;
		l_interim_rec.reference24 := RCrh.ReceiptNumber;
		l_interim_rec.reference25 := NULL;
		l_interim_rec.reference26 := RCrh.CustomerNumber;
		l_interim_rec.reference27 := RCrh.PayFromCustomer;
		l_interim_rec.reference28 := RCrh.ModifiedType;
		l_interim_rec.reference29 := RCrh.ModifiedType||'_'||RCrh.SourceType;
		l_interim_rec.reference30 := 'AR_CASH_RECEIPT_HISTORY';

                l_interim_rec.org_id      := RCrh.OrgId;

		CreateInterim(l_interim_rec) ;

        EXCEPTION
            WHEN OTHERS THEN
                arp_standard.debug( 'InsertIntoAR:' );
                RAISE;
        END;
--
-- This is the actual ReportCashReceiptHistory body
--
    BEGIN
        arp_standard.debug( ' ' );
        arp_standard.debug( '      AR_CASH_RECEIPT_HISTORY...' );
        OPEN CCrh;
        LOOP
            FETCH CCrh
            INTO  RCrh;
            EXIT WHEN CCrh%NOTFOUND;
            InsertIntoAR( RCrh );
	    l_Count := l_Count + 1;
        END LOOP;
        CLOSE CCrh;
        arp_standard.debug( '         '||l_Count||' lines selected' );
--
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'ReportCashReceiptHistory:' );
            RAISE;
    END;
--
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      ReportMiscCashDistributions                                            |
 |  DESCRIPTION                                                              |
 |      post unposted ar_misc_cash_distributions records                     |
 |        within the posting range                                           |
 |                                                                           |
 |  PARAMETERS                                                               |
 |                                                                           |
 |  EXCEPTIONS RAISED                                                        |
 |                                                                           |
 |  ERRORS RAISED                                                            |
 |                                                                           |
 |  KNOWN BUGS                                                               |
 |                                                                           |
 |  NOTES                                                                    |
 |                                                                           |
 |  HISTORY                                                                  |
 |    12-Apr-1994  D Chu	    Created                                  |
 *---------------------------------------------------------------------------*/
    PROCEDURE ReportMiscCashDistributions( p_Report IN ReportParametersType ) IS
        CURSOR CMcd IS
        SELECT  mcd.ROWID                            McdRowid,
                mcd.misc_cash_distribution_id        MiscCashDistributionId,
                cr.cash_receipt_id                   CashReceiptId,
                cr.receipt_number                    ReceiptNumber,
                mcd.amount                           amount,
                mcd.acctd_amount                     acctd_amount,
                mcd.code_combination_id              code_combination_id,
                mcd.gl_date			     gl_date,
                mcd.apply_date			     trx_date,
                cr.currency_code                     currency_code,
                'Misc Receipts'                      category,
		l_cat.meaning			     CatMeaning,
                cr.org_id                            OrgId
        FROM    ar_misc_cash_distributions    mcd,
                ar_cash_receipts              cr,
		ar_lookups		      l_cat
	WHERE   mcd.gl_date      		BETWEEN p_Report.GlDateFrom
			  	                    AND p_Report.GLDateTo
        AND     cr.cash_receipt_id              = mcd.cash_receipt_id
        AND	l_cat.lookup_type 		   = 'ARRGTA_FUNCTION_MAPPING'
        AND 	l_cat.lookup_code 		   = 'MISC_MISC'
	AND 	cr.currency_code 		   = DECODE( p_Report.Currency,
								null,cr.currency_code,
								p_Report.Currency)
	AND 	p_Report.Misc			    = 'Y'
	AND 	( mcd.posting_control_id            = DECODE( p_Report.PostedStatus,
								'BOTH', mcd.posting_control_id,
								'UNPOSTED', -3,
								-8888 )
		OR
	      	  mcd.posting_control_id 	   <> decode( p_Report.PostedStatus,
								'BOTH', -8888,
								'POSTED', -3,
								mcd.posting_control_id) )
	AND 	NVL(mcd.gl_posted_date,to_date('01-01-1952','DD-MM-YYYY'))
	      	 BETWEEN
	               	DECODE( p_Report.PostedStatus,
				'BOTH', nvl(mcd.gl_posted_date,to_date('01-01-1952',
								    'DD-MM-YYYY')),
				'UNPOSTED',nvl(mcd.gl_posted_date,to_date('01-01-1952',
								  'DD-MM-YYYY')),
				'POSTED', decode( p_Report.PostedDateFrom ,
					    null, nvl(mcd.gl_posted_date,to_date('01-01-1952',
								  'DD-MM-YYYY')),
		                      	    p_Report.PostedDateFrom))
               	AND
	               	DECODE( p_Report.PostedStatus,
				'BOTH', nvl(mcd.gl_posted_date,to_date('01-01-1952',
								    'DD-MM-YYYY')),
				'UNPOSTED',nvl(mcd.gl_posted_date,to_date('01-01-1952',
								  'DD-MM-YYYY')),
				'POSTED', decode( p_Report.PostedDateTo,
					    null, nvl(mcd.gl_posted_date,to_date('01-01-1952',
								  'DD-MM-YYYY')),
		                      	    p_Report.PostedDateTo))
        AND     mcd.misc_cash_distribution_id+0 < p_Report.NxtMiscCashDistributionId;
--
	l_Count			NUMBER  :=0;

	-- bug3718694
	l_interim_rec  ar_journal_interim%ROWTYPE;
	l_interim_rec_null  ar_journal_interim%ROWTYPE;
    BEGIN
        arp_standard.debug( ' ' );
        arp_standard.debug( '      AR_MISC_CASH_DISTRIBUTIONS...' );
        FOR RMcd IN CMcd
        LOOP
		-- bug3718694 Call CreateInterim procedure to insert record into
		-- ar_journal_interim .
		l_interim_rec := l_interim_rec_null ;

		l_interim_rec.status := 'NEW';
		l_interim_rec.actual_flag := 'A';
		l_interim_rec.request_id := p_Report.ReqId;
		l_interim_rec.created_by := p_Report.CreatedBy;
		l_interim_rec.date_created := TRUNC( SYSDATE );
		l_interim_rec.set_of_books_id := p_Report.SetOfBooksId;
		l_interim_rec.je_source_name := 'Receivables';
		l_interim_rec.je_category_name := RMcd.category;
		l_interim_rec.transaction_date := RMcd.trx_date;
		l_interim_rec.accounting_date := RMcd.gl_date;
		l_interim_rec.currency_code := RMcd.currency_code;
		l_interim_rec.code_combination_id := RMcd.code_combination_id;

		IF RMcd.amount < 0
		THEN
		  l_interim_rec.entered_dr := -RMcd.amount ;
		ELSE
		  l_interim_rec.entered_cr := RMcd.amount ;
		END IF;

		IF RMcd.acctd_amount < 0
		THEN
		  l_interim_rec.accounted_dr := -RMcd.acctd_amount ;
		ELSE
		  l_interim_rec.accounted_cr := RMcd.acctd_amount ;
		END IF;

		l_interim_rec.reference10 := RMcd.CatMeaning;
		l_interim_rec.reference21 := p_Report.ReqId;
		l_interim_rec.reference22 := RMcd.CashReceiptId;
		l_interim_rec.reference23 := RMcd.MiscCashDistributionId;
		l_interim_rec.reference24 := RMcd.ReceiptNumber;
		l_interim_rec.reference28 := 'MISC';
		l_interim_rec.reference29 := 'MISC_MISC';
		l_interim_rec.reference30 := 'AR_MISC_CASH_DISTRIBUTIONS';
                l_interim_rec.org_id      := RMcd.OrgId;

		CreateInterim (l_interim_rec);
--
	    l_Count := l_Count + 1;
        END LOOP;
        arp_standard.debug( '         '||l_Count||' lines selected' );
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'ReportMiscCashDistributions:' );
            RAISE;
    END;
--
--
--  rollback any posting activity that is related to the given
--      balance id
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      ClearOOB                                                       |
 |  DESCRIPTION                                                              |
 |      rollback (by deleting and updating) any posting activity that is     |
 |        related to the given balance id                                    |
 |  PARAMETERS                                                               |
 |                                                                           |
 |  EXCEPTIONS RAISED                                                        |
 |                                                                           |
 |  ERRORS RAISED                                                            |
 |                                                                           |
 |  KNOWN BUGS                                                               |
 |                                                                           |
 |  NOTES                                                                    |
 |                                                                           |
 |  HISTORY                                                                  |
 |    23-Jul-1993  Alan Fothergill    Created                                |
 *---------------------------------------------------------------------------*/
    PROCEDURE ClearOOB( p_Report IN ReportParametersType,
                              p_BalanceId IN NUMBER,
			      p_CategoryCode IN VARCHAR2 ) IS
    BEGIN
--
        DELETE  FROM ar_journal_interim
        WHERE   reference22          = p_BalanceId
	AND	reference28	     = p_CategoryCode
	AND     set_of_books_id	     = p_Report.SetOfBooksId
        AND     request_id           = p_Report.ReqId;
--
    EXCEPTION
        WHEN OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'ClearOOB' );
            END IF;
            RAISE;
    END ClearOOB;

--
--
--
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      CheckBalance                                                         |
 |  DESCRIPTION                                                              |
 |      Checks that the records inserted into ar_journal_interim balance for each  |
 |        BalanceId (reference22).                                           |
 |      Any BalanceId that fails to balance will be reported on              |
 |        (via arp_standard.debug), and will be deleted with ClearOOB  |
 |  PARAMETERS                                                               |
 |                                                                           |
 |  EXCEPTIONS RAISED                                                        |
 |                                                                           |
 |  ERRORS RAISED                                                            |
 |                                                                           |
 |  KNOWN BUGS                                                               |
 |                                                                           |
 |  NOTES                                                                    |
 |                                                                           |
 |  HISTORY                                                                  |
 |    23-Jul-1993  Alan Fothergill    Created                                |
 *---------------------------------------------------------------------------*/
    PROCEDURE CheckBalance( p_Report IN ReportParametersType ) IS
        CURSOR CBal  IS
        SELECT  MIN(i.currency_code)        CurrencyCode,
                i.reference22          BalanceId,
                i.reference28          CategoryCode,
                SUM(nvl(i.entered_dr,0))      SumEnteredDr,
                SUM(nvl(i.entered_cr,0))      SumEnteredCr,
                SUM(nvl(i.accounted_dr,0))    SumAccountedDr,
                SUM(nvl(i.accounted_cr,0))    SumAccountedCr
        FROM    ar_journal_interim  i
        WHERE   i.request_id              = p_Report.ReqId
	AND     i.set_of_books_id	  = p_Report.SetOfBooksId
        GROUP BY i.reference28,
                 i.reference22
        HAVING SUM( NVL(i.entered_dr,0) )  <> SUM( NVL(i.entered_cr, 0 ))
        OR     SUM( NVL(i.accounted_dr,0)) <> SUM( NVL(i.accounted_cr, 0));
--
        CURSOR CInt( p_BalanceId NUMBER, p_CategoryCode VARCHAR2 ) IS
        SELECT  i.entered_dr                    EnteredDr,
                i.entered_cr                    EnteredCr,
                i.accounted_dr                  AccountedDr,
                i.accounted_cr                  AccountedCr,
                i.reference30                   TableName,
                i.reference23                   Id
        FROM    ar_journal_interim                   i
        WHERE   i.request_id              = p_Report.ReqId
	AND     i.set_of_books_id	        = p_Report.SetOfBooksId
        AND     i.reference22           = p_BalanceId
	AND     i.reference28		= p_CategoryCode
        ORDER BY i.reference30,
                 i.reference23;
--
        l_ReceivableApplicationId      ar_receivable_applications.receivable_application_id%TYPE;
    BEGIN
--
        arp_standard.debug( '   ----------------------------------------------------' );
        arp_standard.debug( '   Checking DR/CR balance...' );
        arp_standard.debug( '' );
--
        FOR RBal IN CBal
        LOOP
            arp_standard.debug( 'Out Of balance:'||Rbal.CurrencyCode||' BalanceId:'||RBal.BalanceId );
            FOR RInt IN CInt( RBal.BalanceId, Rbal.CategoryCode )
            LOOP
                IF RInt.TableName = 'AR_CASH_BASIS_DISTRIBUTIONS'
                THEN
                    SELECT  cbd.receivable_application_id
                    INTO    l_ReceivableApplicationId
                    FROM    ar_cash_basis_distributions    cbd
                    WHERE   cbd.cash_basis_distribution_id = RInt.Id;
                ELSE
                    l_ReceivableApplicationId := NULL;
                END IF;
                arp_standard.debug( RPAD( Rint.TableName, 30)||
                                          RPAD( RInt.Id, 15 )||
                                          LPAD( NVL(TO_CHAR(RInt.EnteredDr), ' '),15)||
                                          LPAD( NVL(TO_CHAR(RInt.EnteredCr), ' '),15)||
                                          LPAD( NVL(TO_CHAR(RInt.AccountedDr), ' '),15)||
                                          LPAD( NVL(TO_CHAR(RInt.AccountedCr), ' '),15)||
                                          '    '||l_ReceivableApplicationId );
            END LOOP;
            arp_standard.debug( RPAD( 'SUM:', 30)||
                                      RPAD( ' ', 15 )||
                                      LPAD( NVL(TO_CHAR(RBal.SumEnteredDr), ' '),15)||
                                      LPAD( NVL(TO_CHAR(RBal.SumEnteredCr), ' '),15)||
                                      LPAD( NVL(TO_CHAR(RBal.SumAccountedDr), ' '),15)||
                                      LPAD( NVL(TO_CHAR(RBal.SumAccountedCr), ' '),15) );
            arp_standard.debug( '--------------------------------------------------------------------------------------------------------------------' );
            ClearOOB( p_Report, RBal.BalanceId, RBal.CategoryCode );
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'CheckBalance:' );
            RAISE;
    END;
--
--
--  Delete from ar_cash_basis_distributions for records inserted
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      DeleteFromCBD                                                        |
 |  DESCRIPTION                                                              |
 |   Delete recrods from ar_cash_basis_distributions inserted this run       |
 |  PARAMETERS                                                               |
 |                                                                           |
 |  EXCEPTIONS RAISED                                                        |
 |                                                                           |
 |  ERRORS RAISED                                                            |
 |                                                                           |
 |  KNOWN BUGS                                                               |
 |                                                                           |
 |  NOTES                                                                    |
 |                                                                           |
 |  HISTORY                                                                  |
 |    13-Apr-1994  D Chu    Created                                          |
 *---------------------------------------------------------------------------*/
    PROCEDURE DeleteFromCBD( p_Report IN ReportParametersType ) IS
    BEGIN
--
        DELETE  FROM ar_cash_basis_distributions
        WHERE   posting_control_id   = - ( p_Report.ReqId +100 );
--
    EXCEPTION
        WHEN OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'DeleteFromCBD' );
            END IF;
            RAISE;
    END DeleteFromCBD;
--
--
   PROCEDURE  CheckUpgradedCustomer(p_FromRel9 OUT NOCOPY VARCHAR2) IS
	l_ColumnId	NUMBER	:=0;
--
	CURSOR SelColumn IS
	SELECT column_id
        FROM   user_tab_columns
        WHERE  table_name = 'AR_CASH_BASIS_DISTRIBUTIONS'
        AND    column_name = 'CUSTOMER_TRX_LINE_ID';
--
   BEGIN

	OPEN SelColumn;
	FETCH SelColumn into l_ColumnId;

	IF SelColumn%NOTFOUND
	THEN
	   p_FromRel9 := 'N';
	ELSE
    	   p_FromRel9 := 'Y';
	END IF;
	CLOSE SelColumn;
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'CheckUpgradedCustomer:' );
            RAISE;
   END;

--
--
    PROCEDURE Report( p_Report       IN ReportParametersType ) IS
    l_FromRel9		VARCHAR2(1);
    BEGIN
     CheckUpgradedCustomer( l_FromRel9 );
     IF l_FromRel9 = 'Y'
     THEN
	   arp_standard.fnd_message('AR_WWS_CASH_BASIS');
     ELSE
        IF p_Report.Trade = 'Y' OR
           p_Report.Misc = 'Y'  OR
           p_Report.Ccurr = 'Y' OR
           p_Report.CMApp= 'Y'
        THEN
--
		IF p_Report.Trade = 'Y' OR
                   p_Report.Ccurr = 'Y' OR
		   p_Report.Misc = 'Y'
		THEN
		        ReportCashReceiptHistory( p_Report );
		END IF;
--
		IF p_Report.Misc = 'Y'
		THEN
		        ReportMiscCashDistributions( p_Report );
		END IF;
--
		IF p_Report.Trade = 'Y' OR
                   p_Report.Ccurr = 'Y'
		THEN
		        ReportNonDistApplications( p_Report );
		END IF;
--
		IF p_Report.Trade = 'Y' OR
                   p_Report.Ccurr = 'Y' OR
		   p_Report.CMApp = 'Y'
		THEN
		        ReportDistributedApplications( p_Report );
		END IF;
--
		IF p_Report.ChkBalance = 'Y' AND
		   p_Report.PostedStatus <> 'POSTED'
		THEN
		        CheckBalance( p_Report );
		END IF;
	        DeleteFromCBD( p_Report );
	END IF;
     END IF;
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:arp_cash_basis_je_report.Report( p_Report ):'||sqlerrm );
            RAISE_APPLICATION_ERROR( -20000, sqlerrm||'$Revision: 120.5 $:Report( p_Report ):' );
    END;
--
--
    PROCEDURE Report( p_ReqId                   NUMBER,
                    p_ChkBalance                VARCHAR2,
                    p_GlDateFrom                DATE,
                    p_GlDateTo                  DATE,
                    p_SetOfBooksId              NUMBER,
		    p_UnallocatedRevCcid	NUMBER,
                    p_CreatedBy                 NUMBER,
                    p_NxtCashReceiptHistoryId     NUMBER,
                    p_NxtReceivableApplicationId  NUMBER,
                    p_NxtMiscCashDistributionId   NUMBER,
                    p_NxtAdjustmentId             NUMBER,
                    p_NxtCustTrxLineGlDistId      NUMBER,
		    p_Currency			VARCHAR2,
		    p_Inv			VARCHAR2,
		    p_DM			VARCHAR2,
		    p_CB			VARCHAR2,
		    p_CM			VARCHAR2,
		    p_CMApp			VARCHAR2,
		    p_Adj			VARCHAR2,
		    p_Trade			VARCHAR2,
		    p_Misc			VARCHAR2,
                    p_Ccurr                     VARCHAR2,
		    p_PostedStatus		VARCHAR2,
		    p_PostedDateFrom		DATE,
		    p_PostedDateTo		DATE ) IS
    l_Report  ReportParametersType;
    BEGIN
        l_Report.ReqId := p_ReqId;
        l_Report.ChkBalance := p_ChkBalance;
        l_Report.GlDateFrom := p_GlDateFrom;
        l_Report.GlDateTo := p_GlDateTo;
        l_Report.SetOfBooksId := p_SetOfBooksId;
        l_Report.UnallocatedRevCcid := p_UnallocatedRevCcid;
        l_Report.CreatedBy := p_CreatedBy;
        l_Report.NxtCashReceiptHistoryId := p_NxtCashReceiptHistoryId;
        l_Report.NxtReceivableApplicationId := p_NxtReceivableApplicationId;
        l_Report.NxtMiscCashDistributionId := p_NxtMiscCashDistributionId;
        l_Report.NxtAdjustmentId := p_NxtAdjustmentId;
        l_Report.NxtCustTrxLineGlDistId := p_NxtCustTrxLineGlDistId;
        l_Report.Currency := p_Currency;
	l_Report.Inv := p_Inv;
	l_Report.DM := p_DM;
	l_Report.CB := p_CB;
	l_Report.CM := p_CM;
	l_Report.CMApp := p_CMApp;
	l_Report.Adj := p_Adj;
	l_Report.Trade := p_Trade;
	l_Report.Misc := p_Misc;
        l_Report.Ccurr := p_Ccurr;
        l_Report.PostedStatus := p_PostedStatus;
        l_Report.PostedDateFrom := p_PostedDateFrom;
        l_Report.PostedDateTo := p_PostedDateTo;
--
        Report( l_Report );
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:arp_cash_basis_je_report.Report( ... ):'||sqlerrm );
            RAISE_APPLICATION_ERROR( -20000, sqlerrm||'$Revision: 120.5 $:Report( ... ):' );
    END;
--
END arp_cash_basis_je_report;

/
