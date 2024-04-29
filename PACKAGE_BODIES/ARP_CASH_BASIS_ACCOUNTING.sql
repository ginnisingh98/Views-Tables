--------------------------------------------------------
--  DDL for Package Body ARP_CASH_BASIS_ACCOUNTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CASH_BASIS_ACCOUNTING" AS
/* $Header: ARPLCBPB.pls 120.15 2006/02/24 22:42:40 kmaheswa ship $    */

    -- RECORD holder for pertinent information about the cash receipt that drives
    -- the posting of an application
    TYPE ReceiptType IS RECORD
    (
        CashReceiptId             ar_cash_receipts.cash_receipt_id%TYPE,
        ReceiptNumber             ar_cash_receipts.receipt_number%TYPE,
        DocSequenceId             ar_cash_receipts.doc_sequence_id%TYPE,
        DocSequenceValue          ar_cash_receipts.doc_sequence_value%TYPE,
        PayFromCustomer           ar_cash_receipts.pay_from_customer%TYPE,
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
        Class                        ar_payment_schedules.class%TYPE,
        TrxNumber                    ra_customer_trx.trx_number%TYPE,
        OrgId			     ra_customer_trx.org_id%TYPE
    );
    --
    -- RECORD holder for pertinent information from a receivable application
    -- of status = 'APP'
    TYPE ApplicationType IS RECORD
    (
        ReceivableApplicationId      ar_receivable_applications.receivable_application_id%TYPE,
        GLDate		                 DATE,    -- the gl date of the application
        UssglTransactionCode         ar_receivable_applications.ussgl_transaction_code%TYPE,
        AppType		             ar_receivable_applications.application_type%TYPE
    );
    --
    -- holds ApplicationAmount values
    --
    TYPE ApplicationAmountType IS RECORD
    (
        Amount                    NUMBER,
        AmountAppFrom             NUMBER,
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
           arp_standard.debug('Output: ' ||  'DocSequenceId:'||p.DocSequenceId );
           arp_standard.debug('Output: ' ||  'DocSequenceValue:'||p.DocSequenceValue );
           arp_standard.debug('Output: ' ||  'PayFromCustomer:'||p.PayFromCustomer );
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
           arp_standard.debug('Output: ' ||  'Class:'||p.Class );
           arp_standard.debug('Output: ' ||  'TrxNumber:'||p.TrxNumber );
           arp_standard.debug('Output: ' ||  'OrgId:'||p.OrgId );
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
           arp_standard.debug('Output: ' ||  'UssglTransactionCode:'||p.UssglTransactionCode );
           arp_standard.debug('Output: ' ||  'AppType:'||p.AppType );
           arp_standard.debug('Output: ' ||  '' );
        END IF;
    END;
--
    PROCEDURE Output( p IN ApplicationAmountType ) IS
    BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('Output: ' ||  'ApplicationAmountType' );
           arp_standard.debug('Output: ' ||  'Amount:'||p.Amount );
           arp_standard.debug('Output: ' || 'AmountAppfrom :'||p.AmountAppFrom);
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
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      CreateInterface                                                      |
 |  DESCRIPTION                                                              |
 |      Insert record into gl_interface                                      |
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
 |    13-JUL-2004  Hiroshi Yoshihara  bug3692482 Created                     |
 *---------------------------------------------------------------------------*/
    PROCEDURE CreateInterface( p_interface_rec  IN gl_interface%ROWTYPE) IS
    BEGIN
            INSERT INTO gl_interface
            (
                created_by,
                date_created,
                status,
                actual_flag,
                group_id,
                set_of_books_id,
                user_je_source_name,
                user_je_category_name,
                accounting_date,
                subledger_doc_sequence_id,
                subledger_doc_sequence_value,
                ussgl_transaction_code,
                currency_code,
                code_combination_id,
                entered_dr,
                entered_cr,
                accounted_dr,
                accounted_cr,
                reference1,
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
                reference30
            )
            VALUES
            (
                p_interface_rec.created_by,
                p_interface_rec.date_created,
                p_interface_rec.status,
                p_interface_rec.actual_flag,
                p_interface_rec.group_id,
                p_interface_rec.set_of_books_id,
                p_interface_rec.user_je_source_name,
                p_interface_rec.user_je_category_name,
                p_interface_rec.accounting_date,
                p_interface_rec.subledger_doc_sequence_id,
                p_interface_rec.subledger_doc_sequence_value,
                p_interface_rec.ussgl_transaction_code,
                p_interface_rec.currency_code,
                p_interface_rec.code_combination_id,
                p_interface_rec.entered_dr,
                p_interface_rec.entered_cr,
                p_interface_rec.accounted_dr,
                p_interface_rec.accounted_cr,
                p_interface_rec.reference1,
                p_interface_rec.reference10,
                p_interface_rec.reference21,
                p_interface_rec.reference22,
                p_interface_rec.reference23,
                p_interface_rec.reference24,
                p_interface_rec.reference25,
                p_interface_rec.reference26,
                p_interface_rec.reference27,
                p_interface_rec.reference28,
                p_interface_rec.reference29,
                p_interface_rec.reference30
            );
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:CreateInterface:' );
            RAISE;
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
 |      p_Post       RECORD type that contains posting parameters
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
    PROCEDURE CurrentCBDApplications(  p_Post      IN  PostingParametersType,
                                       p_ps_id     IN  NUMBER,
                                       p_type      IN  VARCHAR2,
                                       Source      OUT NOCOPY VC3Type,
                                       SourceId    OUT NOCOPY IdType,
                                       Amount      OUT NOCOPY AmountType,
                                       NextElement OUT NOCOPY BINARY_INTEGER,
                                       TotalAmount OUT NOCOPY NUMBER,
				       TotalUnallocatedAmt OUT NOCOPY NUMBER
                                 ) IS
        l_TotalAmount   NUMBER := 0;
        l_TotalUnallocatedAmt   NUMBER := 0;
        l_NextElement   BINARY_INTEGER := 0;

        CURSOR CCA IS
        SELECT  SUM( cbd.amount )                       Amount,
                cbd.source                              Source,
                cbd.source_id                           SourceId,
                NVL(SUM( DECODE(cbd.source,
			'UNA', cbd.amount, 0 )),0)	UnallocatedAmt
        FROM    ar_cash_basis_distributions             cbd
        WHERE   cbd.payment_schedule_id = p_ps_id
        AND     cbd.type                = p_type
	AND 	cbd.posting_control_id+0  > 0
        GROUP BY cbd.source,
                 cbd.source_id
        ORDER BY DECODE( cbd.source, 'GL', 1,
				     'ADJ',2,
				     'UNA',3 ),
                 cbd.source_id;
--{BUG4301323
/*
        CURSOR CCA_MRC IS
        SELECT  SUM( cbd.amount )                       Amount,
                cbd.source                              Source,
                cbd.source_id                           SourceId,
                NVL(SUM( DECODE(cbd.source,
			'UNA', cbd.amount, 0 )),0)	UnallocatedAmt
        FROM    ar_cash_basis_dists_mrc_v               cbd
        WHERE   cbd.payment_schedule_id = p_ps_id
        AND     cbd.type                = p_type
	AND 	cbd.posting_control_id+0  > 0
        GROUP BY cbd.source,
                 cbd.source_id
        ORDER BY DECODE( cbd.source, 'GL', 1,
				     'ADJ',2,
				     'UNA',3 ),
                 cbd.source_id;
*/
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

    BEGIN
      -- bug3769452 modified IF condition
      IF (NVL(p_Post.SetOfBooksType,'P') <> 'R')
      THEN
        /* Primary SOB */
        FOR RCA IN CCA LOOP
            BEGIN
                Source( l_NextElement )    := RCA.Source;
                SourceId( l_NextElement )  := RCA.SourceId;
                Amount( l_NextElement )    := RCA.Amount;

                l_TotalAmount := l_TotalAmount + RCA.Amount;
                l_NextElement := l_NextElement + 1;
		l_TotalUnallocatedAmt := l_TotalUnallocatedAmt + RCA.UnallocatedAmt;

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
      ELSE /* Reporting */
--{BUG4301323
NULL;
/*
        FOR RCA IN CCA_MRC LOOP
            BEGIN
                Source( l_NextElement )    := RCA.Source;
                SourceId( l_NextElement )  := RCA.SourceId;
                Amount( l_NextElement )    := RCA.Amount;

                l_TotalAmount := l_TotalAmount + RCA.Amount;
                l_NextElement := l_NextElement + 1;
		l_TotalUnallocatedAmt := l_TotalUnallocatedAmt + RCA.UnallocatedAmt;

            EXCEPTION
                WHEN OTHERS THEN
                    arp_standard.debug( 'Exception:CurrentCBDApplications.Loop:');
                    Output( Rca );
                    RAISE;
            END;
        END LOOP;
*/
      END IF;
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
 |      p_Post       RECORD type that contains posting parameters            |
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
    PROCEDURE CurrentRevDistribution ( p_Post       IN     PostingParametersType,
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

        CURSOR gl_dist_cursor( cp_ctid NUMBER, cp_type VARCHAR2 ) IS
        SELECT  ctlgd.cust_trx_line_gl_dist_id,
                ctlgd.amount                 amount,
                ctlgd.code_combination_id    ccid,
		substrb(decode(ctlgd.account_class,
				'REV','LINE',
				ctlgd.account_class),1,15) accntclass
        FROM    ra_cust_trx_line_gl_dist     ctlgd
        WHERE   ctlgd.customer_trx_id = cp_ctid
        AND     ctlgd.account_class
                IN ( 'REV', 'TAX', 'FREIGHT','CHARGES')
        AND     ctlgd.account_class   = DECODE
                                        (
                                            cp_type,
                                            'LINE', 'REV',
                                            'TAX',  'TAX',
                                            'FREIGHT', 'FREIGHT',
                                            'CHARGES', 'CHARGES',
                                            ctlgd.account_class
                                        )
        AND     ctlgd.cust_trx_line_gl_dist_id+0 < p_Post.NxtCustTrxLineGlDistId
        ORDER BY ctlgd.cust_trx_line_gl_dist_id;

        CURSOR adj_cursor( cp_ps_id NUMBER, cp_type VARCHAR2 ) IS
        SELECT  a.adjustment_id            adjustment_id,
                DECODE
                (
                    cp_type,
                    'LINE',    nvl(a.line_adjusted,0),
                    'TAX',     nvl(a.tax_adjusted,0),
                    'FREIGHT', nvl(a.freight_adjusted,0),
                    'CHARGES', nvl(a.receivables_charges_adjusted,0),
                    a.amount
                )                           amount,
                a.code_combination_id       ccid,
	        substrb(a.type,1,15)         accntclass
        FROM    ar_adjustments              a,
                ra_customer_trx             ct,
		ra_cust_trx_types           ctt
        WHERE   a.payment_schedule_id       = cp_ps_id
	AND     a.receivables_trx_id        <> -1
        AND     a.type                      = cp_type
        AND     a.status                    = 'A'
	AND 	a.customer_trx_id	    = ct.customer_trx_id
	AND	ct.cust_trx_type_id	    = ctt.cust_trx_type_id
        AND     a.adjustment_id+0 < p_Post.NxtAdjustmentId
        ORDER BY a.adjustment_id;

    BEGIN
        -- first get the ps details
        /* Bug 2967037 - no need to retrofit this - we are not using any MRC columns */
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

        FOR GlDistRecord IN gl_dist_cursor( l_customer_trx_id, p_type ) LOOP
            IF l_FirstInstallmentFlag = 'Y'
               AND l_FirstInstallmentCode = 'INCLUDE'
               AND p_Type IN ('TAX','FREIGHT') THEN
                l_Amount := GlDistRecord.Amount;
            ELSE
                l_Amount := arpcurr.CurrRound( GlDistRecord.amount * l_term_fraction, l_currency_code );
            END IF;
            Amount( l_NextElement )    := l_Amount;
            Source( l_NextElement )    := 'GL';
            SourceId( l_NextElement )  := GlDistRecord.cust_trx_line_gl_dist_id;
            Ccid( l_NextElement )      := GlDistRecord.ccid;
            AccntClass( l_NextElement ):= GlDistRecord.accntclass;
            l_TotalAmount              := l_TotalAmount + l_Amount;
            l_NextElement              := l_NextElement + 1;
        END LOOP;


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
            Amount( l_NextElement-1) := l_Amount + l_AmountReconcile - l_TotalAmount;
            l_TotalAmount := l_AmountReconcile;
        END IF;

        -- next get adjustments that are NOT receipt-related
        FOR AdjRecord IN adj_cursor( p_ps_id, p_type ) LOOP
            Amount( l_NextElement )      := AdjRecord.amount;
            Source( l_NextElement )      := 'ADJ';
            SourceId( l_NextElement )    := AdjRecord.adjustment_id;
            Ccid( l_NextElement )        := AdjRecord.ccid;
            AccntClass( l_NextElement )  := AdjRecord.accntclass;
            l_TotalAmount                := l_TotalAmount + AdjRecord.Amount;
            l_NextElement := l_NextElement + 1;
        END LOOP;

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
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      CreateDistribution                                                   |
 |  DESCRIPTION                                                              |
 |      Creates a distribution by inserting a record into                    |
 |        ar_cash_basis_distributions, and a record into gl_interface        |
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
    PROCEDURE CreateDistribution(  p_Post         IN PostingParametersType,
                                   p_Receipt      IN ReceiptType,
                                   p_Trx          IN TrxType,
                                   p_App          IN ApplicationType,
                                   p_Amount       IN NUMBER,
                                   p_AcctdAmount  IN NUMBER,
                                   p_Source       IN VARCHAR2,
                                   p_SourceId     IN NUMBER,
                                   p_Type         IN VARCHAR2,
                                   p_Ccid         IN NUMBER,
				   p_AccntClass   IN VARCHAR2,
				   p_AmountAppFrom IN NUMBER ) IS
        CashBasisDistributionId ar_cash_basis_distributions.cash_basis_distribution_id%TYPE;
        l_gl_interface  gl_interface%ROWTYPE;
        l_gl_interface_null  gl_interface%ROWTYPE;
    BEGIN
        IF p_Amount = 0 AND p_AcctdAmount = 0 THEN
            RETURN;
        END IF;

        SELECT  ar_cash_basis_distributions_s.NEXTVAL
        INTO    CashBasisDistributionId
        FROM    dual;

        BEGIN

          IF (NVL(p_Post.SetOfBooksType,'P') <> 'R')
          THEN
            /* Primary SOB */
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
                receivable_application_id_cash,
                org_id
            )
            VALUES
            (
                CashBasisDistributionId,
                p_Post.CreatedBy,
                TRUNC( SYSDATE ),
                p_Post.CreatedBy,
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
                p_Post.PostingControlId,
                p_Post.GlPostedDate,
                NULL,
                p_Trx.OrgId
            );

          ELSE
             /* Reporting */
--{BUG4301323
             NULL;
--            INSERT INTO ar_mc_cash_basis_dists_all
--            (
--                set_of_books_id,
--                cash_basis_distribution_id,
--                created_by,
--                creation_date,
--                last_updated_by,
--                last_update_date,
--                receivable_application_id,
--                source,
--                source_id,
--                type,
--                payment_schedule_id,
--                gl_date,
--                currency_code,
--                amount,
--                acctd_amount,
--                code_combination_id,
--                posting_control_id,
--                gl_posted_date,
--                receivable_application_id_cash,
--                org_id
--            )
--            VALUES
--            (
--                p_Post.SetOfBooksId,
--                CashBasisDistributionId,
--                p_Post.CreatedBy,
--                TRUNC( SYSDATE ),
--                p_Post.CreatedBy,
--                TRUNC( SYSDATE ),
--                p_App.ReceivableApplicationId,
--                p_Source,
--                p_SourceId,
--                p_Type,
--                p_Trx.PaymentScheduleId,
--                p_App.GlDate,
--                p_Receipt.CurrencyCode,
--                p_Amount,
--                p_AcctdAmount,
--                p_Ccid,
--                p_Post.PostingControlId,
--                p_Post.GlPostedDate,
--                NULL,
--                ar_mc_info.org_id
--            );
--}
          END IF;

        EXCEPTION
            WHEN OTHERS THEN
                arp_standard.debug( 'Exception:CreateDistribution.InsertCBD:' );
                RAISE;
        END;

--{BUG4301323
-- Execute only for Primary
     IF (NVL(p_Post.SetOfBooksType,'P') <> 'R')
     THEN

        BEGIN
	    /* bug3692482 replace insert stmt with CreateInterface procedure */
            l_gl_interface := l_gl_interface_null;

            l_gl_interface.created_by := p_Post.CreatedBy;
            l_gl_interface.date_created := TRUNC( SYSDATE );
            l_gl_interface.status := 'NEW';
            l_gl_interface.actual_flag := 'A';
            l_gl_interface.group_id := p_Post.PostingControlId;
            l_gl_interface.set_of_books_id := p_Post.SetOfBooksId;
            l_gl_interface.user_je_source_name := p_Post.UserSource;

            IF p_AmountAppFrom IS NULL
            THEN
              l_gl_interface.user_je_category_name := p_Post.UserTrade ;
            ELSE
              l_gl_interface.user_je_category_name := p_Post.UserCcurr ;
            END IF;

            l_gl_interface.accounting_date := p_App.GlDate;
            l_gl_interface.subledger_doc_sequence_id := p_Receipt.DocSequenceId;
            l_gl_interface.subledger_doc_sequence_value := p_Receipt.DocSequenceValue;
            l_gl_interface.ussgl_transaction_code := p_App.UssglTransactionCode;
            l_gl_interface.currency_code := p_Receipt.CurrencyCode;
            l_gl_interface.code_combination_id := p_Ccid;

            IF p_Amount < 0
            THEN
              l_gl_interface.entered_dr := -p_Amount;
            ELSE
              l_gl_interface.entered_cr := p_Amount;
            END IF;

            IF p_AcctdAmount < 0
            THEN
              l_gl_interface.accounted_dr := -p_AcctdAmount;
            ELSE
              l_gl_interface.accounted_cr := p_AcctdAmount;
            END IF;

            l_gl_interface.reference1 := 'AR '||p_Post.PostingControlId;

            IF p_Post.SummaryFlag = 'Y'
            THEN
              l_gl_interface.reference10 := NULL;
            ELSE
              IF P_App.AppType = 'CM'
              THEN
                l_gl_interface.reference10 := 'CM '||p_Receipt.ReceiptNumber||p_Post.NlsAppApplied||' '||p_Trx.Class|| ' '||p_trx.TrxNumber;
              ELSE
                l_gl_interface.reference10 := p_Post.NlsPreTradeApp||' '||p_Receipt.ReceiptNumber||p_Post.NlsAppApplied||' '||p_Trx.Class||' '||p_trx.TrxNumber||p_Post.NlsPostTradeApp;
              END IF;
            END IF;

            l_gl_interface.reference21 := p_Post.PostingControlId;
            l_gl_interface.reference22 := p_Receipt.CashReceiptId;
            l_gl_interface.reference23 := CashBasisDistributionId;
            l_gl_interface.reference24 := p_Receipt.ReceiptNumber;
            l_gl_interface.reference25 := p_Trx.TrxNumber;
            l_gl_interface.reference26 := p_Trx.Class;
            l_gl_interface.reference27 := p_Receipt.PayFromCustomer;

            IF P_App.AppType = 'CM'
            THEN
              l_gl_interface.reference28 := 'CMAPP';
            ELSIF P_App.AppType = 'CASH'
            THEN
              IF p_AmountAppFrom IS NULL
              THEN
                l_gl_interface.reference28 := 'TRADE';
              ELSE
                l_gl_interface.reference28 := 'CCURR';
              END IF;
            END IF;

            IF P_App.AppType = 'CASH'
            THEN
              IF p_AmountAppFrom IS NULL
              THEN
                l_gl_interface.reference29 := 'TRADE_APP_'||p_Trx.Class||'_'||p_Source||'_'||p_Type;
              ELSE
                l_gl_interface.reference29 := 'CCURR_APP_'||p_Trx.Class||'_'||p_Source||'_'||p_Type;
              END IF;
            ELSIF P_App.AppType = 'CM'
            THEN
              IF p_Trx.CmPsIdFlag = 'Y'
              THEN
                l_gl_interface.reference29 := 'CMAPP_REC_CM_'||p_Source||'_'||p_Type;
              ELSE
                l_gl_interface.reference29 := 'CMAPP_APP_'||p_Trx.Class||'_'||p_Source||'_'||p_Type;
              END IF;
            END IF;

            l_gl_interface.reference30 := 'AR_CASH_BASIS_DISTRIBUTIONS';

            CreateInterface( l_gl_interface );

        EXCEPTION
            WHEN OTHERS THEN
                arp_standard.debug( 'Exception:CreateDistribution.InsertGl:' );
                RAISE;
        END;

    END IF;
--}

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
    PROCEDURE DistributeApplicationType( p_Post        IN PostingParametersType,
                                         p_Receipt     IN ReceiptType,
                                         p_Trx         IN TrxType,
                                         p_App         IN ApplicationType,
                                         p_Type        IN VARCHAR2,
                                         p_Amount      IN NUMBER,
                                         p_AcctdAmount IN NUMBER,
					 p_AmountAppFrom IN NUMBER ) IS
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
        -- Bug 1829871
        MultipleAdjustmentsPresent      BOOLEAN;
        NumberOfAdjustments             NUMBER := 0;
        -- End Bug 1829871
    BEGIN
        CurrentRevDistribution (  p_Post,
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
	CurrentCBDApplications(  p_Post,
                                 p_Trx.PaymentScheduleId,
                                 p_Type,
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
        --Bug 1829871
        -- if number of adjustments are more than one, do the changes suggested
        -- in bug 1397969
        WHILE CRD_i <> CRD_NextElement
            LOOP
                if(CRD_Source(CRD_i) ='ADJ') then
                  NumberOfAdjustments := NumberOfAdjustments +1;
                end if;
                CRD_i := CRD_i + 1;
        END LOOP;
        if NumberOfAdjustments >1 then
         MultipleAdjustmentsPresent := TRUE;
        end if;
        CBD_i := 0;
        CRD_i := 0;
        -- End Bug 1829871

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

                        -- if pro-rating formula comes up with an amount greater that the grandtotalapplied
                        -- just make the 2 amounts equal
                        -- Bug 1829871
                       if(MultipleAdjustmentsPresent) then
                        if abs(NewAppToLine) > abs(GrandTotalApplied) then
                           NewApptoLine := GrandTotalApplied;
                           -- 1397969 : since we've used up GrandTotalApplied, set CRD_TotalAmount to zero
                           -- so that no additional entries are created
                           CRD_TotalAmount := 0;
                        end if;
                      end if;
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
	                CreateDistribution( p_Post,
        	                            p_Receipt,
	                                    p_Trx,
	                                    p_App,
	                                    AppToLineThisTime,
	                                    AcctdAppToLineThisTime,
	                                    CRD_Source( CRD_i ),
	                                    CRD_SourceId( CRD_i ),
	                                    p_Type,
	                                    CRD_Ccid( CRD_i ),
	                                    CRD_AccntClass( CRD_i ),
					    p_AmountAppFrom );
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
                AcctdAppToLineThisTime :=
                     arpcurr.ReconcileAcctdAmounts(
                       p_Receipt.ExchangeRate,
                       p_Amount,            -- total of distributions reconciles to the applied amount
                       p_AcctdAmount,
                       AppToLineThisTime,
                       RunningAppToLineThisTime,
                       RunningAcctdAppToLineThisTime );
--
		IF AcctdAppToLineThisTime <> 0
		THEN
--
	                CreateDistribution( p_Post,
        	                            p_Receipt,
	                                    p_Trx,
	                                    p_App,
	                                    AppToLineThisTime,
	                                    AcctdAppToLineThisTime,
	                                    'UNA',
	                                    p_Post.SetOfBooksId,
	                                    p_Type,
	                                    p_Post.UnallocatedRevCcid,
	                                    'INVOICE',
					     p_AmountAppFrom );
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
    PROCEDURE DistributeLTFApplication(  p_Post      IN PostingParametersType,
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
   DistributeApplicationType( p_Post, p_Receipt, p_Trx, p_App, 'CHARGES', p_AppAmount.ChargesApplied, AcctdAmount,
												p_AppAmount.AmountAppFrom);
        END IF;
--
        IF p_AppAmount.FreightApplied <> 0 THEN
            AcctdAmount := arpcurr.ReconcileAcctdAmounts( p_Receipt.ExchangeRate,
                                           p_AppAmount.Amount,
                                           p_AppAmount.AcctdAmount,
                                           p_AppAmount.FreightApplied,
                                           RunningTotalAmount,
                                           RunningTotalAcctdAmount );
            DistributeApplicationType( p_Post, p_Receipt, p_Trx, p_App, 'FREIGHT', p_AppAmount.FreightApplied, AcctdAmount,
												p_AppAmount.AmountAppFrom);
        END IF;
--
        IF p_AppAmount.TaxApplied <> 0 THEN
            AcctdAmount := arpcurr.ReconcileAcctdAmounts( p_Receipt.ExchangeRate,
                                           p_AppAmount.Amount,
                                           p_AppAmount.AcctdAmount,
                                           p_AppAmount.TaxApplied,
                                           RunningTotalAmount,
                                           RunningTotalAcctdAmount );
            DistributeApplicationType( p_Post, p_Receipt,p_Trx,  p_App, 'TAX', p_AppAmount.TaxApplied, AcctdAmount,
												p_AppAmount.AmountAppFrom);
        END IF;
--
        IF p_AppAmount.LineApplied <> 0 THEN
            AcctdAmount := arpcurr.ReconcileAcctdAmounts( p_Receipt.ExchangeRate,
                                           p_AppAmount.Amount,
                                           p_AppAmount.AcctdAmount,
                                           p_AppAmount.LineApplied,
                                           RunningTotalAmount,
                                           RunningTotalAcctdAmount );
            DistributeApplicationType( p_Post, p_Receipt, p_Trx, p_App, 'LINE', p_AppAmount.LineApplied, AcctdAmount,
												p_AppAmount.AmountAppFrom);
        END IF;
--
--
--
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:DistributeLTFApplication:' );
            RAISE;
    END;
--
--
-- post ar_receivable_applications that have status UNAPP, UNID, ACC,OTHER ACC
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      PostNonDistApplications                                              |
 |  DESCRIPTION                                                              |
 |      post unposted ar_receivable_applications records                     |
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
 |    23-Jul-1993  Alan Fothergill    Created                                |
 |    20-Aug-1993  Alan Fothergill    Placed exception handler around insert |
 |                                      statement                            |
 |    16-JAN-2002  R Kader            Modified the cursor CRa to fetch the   |
 |                                    ACTIVITY records also.                 |
 |                                    See bug 2177009 / 2187023 for details  |
 |    03-JUN-2003  M Raymond          Removed MRC schema dependency
 |    03-DEC-2004  M Raymond          Changed source of AmountAppFrom
 |                                    for MRC rows - see bug 3904994 for dets.
 *---------------------------------------------------------------------------*/
    PROCEDURE PostNonDistApplications( p_Post IN PostingParametersType  ) IS
        CURSOR CRa IS
        SELECT  ra.ROWID                               RaRowid,
                cr.cash_receipt_id                     CashReceiptId,
                cr.receipt_number                      ReceiptNumber,
                cr.doc_sequence_id                     CrDocSequenceId,
                cr.doc_sequence_value                  CrDocSequenceValue,
                cr.pay_from_customer                   PayFromCustomer,
                cr.currency_code                       CurrencyCode,
                ra.receivable_application_id           ReceivableApplicationId,
                ra.gl_date                             GlDate,
                ra.ussgl_transaction_code              UssglTransactionCode,
                ra.amount_applied 		       Amount,
                ra.amount_applied_from                 AmountAppFrom,
                ra.acctd_amount_applied_from           AcctdAmount,
                ra.code_combination_id                 CodeCombinationId,
                ra.status                              Status
        FROM    ar_receivable_applications    ra,
                ar_cash_receipts              cr
        WHERE   ra.posting_control_id              = p_Post.UnpostedPostingControlId
        AND     ra.gl_date   			   BETWEEN p_Post.GlDateFrom
                                                   AND     p_Post.GlDateTo
   	AND	nvl(ra.postable,'Y')		   = 'Y'
   	AND	nvl(ra.confirmed_flag,'Y')	   = 'Y'
        AND     ra.status                          <> 'APP'  -- Bug 2187023
	AND     ra.application_type||''		   = 'CASH'
        AND     cr.cash_receipt_id                 = ra.cash_receipt_id
        AND     ra.receivable_application_id+0     <  p_Post.NxtReceivableApplicationId
        FOR UPDATE OF ra.receivable_application_id;

        /* Bug 3904994 - changed amount_applied_from from
           ra_mrc to ra table.  The corresponding MRC view
           also relies upon the primary table for this column */

--{BUG4301323
/*
        CURSOR CRa_mrc IS
        SELECT  ra_mrc.ROWID                           RaRowid,
                cr.cash_receipt_id                     CashReceiptId,
                cr.receipt_number                      ReceiptNumber,
                cr.doc_sequence_id                     CrDocSequenceId,
                cr.doc_sequence_value                  CrDocSequenceValue,
                cr.pay_from_customer                   PayFromCustomer,
                cr.currency_code                       CurrencyCode,
                ra.receivable_application_id           ReceivableApplicationId,
                ra.gl_date                             GlDate,
                ra.ussgl_transaction_code              UssglTransactionCode,
                ra_mrc.amount_applied 		       Amount,
                ra.amount_applied_from                 AmountAppFrom,
                ra_mrc.acctd_amount_applied_from       AcctdAmount,
                ra.code_combination_id                 CodeCombinationId,
                ra_mrc.status                          Status
        FROM    ar_receivable_applications    ra,
                ar_mc_receivable_apps         ra_mrc,
                ar_cash_receipts              cr
        WHERE   ra_mrc.posting_control_id          = p_Post.UnpostedPostingControlId
        AND     ra.gl_date   			   BETWEEN p_Post.GlDateFrom
                                                   AND     p_Post.GlDateTo
   	AND	nvl(ra.postable,'Y')		   = 'Y'
   	AND	nvl(ra.confirmed_flag,'Y')	   = 'Y'
        AND     ra.status                          <> 'APP'  -- Bug 2187023
	AND     ra.application_type||''		   = 'CASH'
        AND     cr.cash_receipt_id                 = ra.cash_receipt_id
        AND     ra.receivable_application_id+0     <  p_Post.NxtReceivableApplicationId
        AND     ra.receivable_application_id = ra_mrc.receivable_application_id
        AND     ra_mrc.set_of_books_id             = p_Post.SetOfBooksId
        FOR UPDATE OF ra_mrc.receivable_application_id;
*/

	l_Count			NUMBER  :=0;

        l_gl_interface  gl_interface%ROWTYPE;
        l_gl_interface_null  gl_interface%ROWTYPE;
    BEGIN
        arp_standard.debug( ' ' );
        arp_standard.debug( '      AR_RECEIVABLE_APPLICATIONS (non-app)...' );

        -- bug3769452 modified IF condition
        IF (p_Post.SetOfBooksType <> 'R')
        THEN

          arp_standard.debug('     Primary sob');

          FOR RRa IN CRa
          LOOP
            BEGIN
	    /* bug3692482 replace insert stmt with CreateInterface procedure */
              l_gl_interface := l_gl_interface_null ;

              l_gl_interface.created_by := p_Post.CreatedBy;
              l_gl_interface.date_created := TRUNC( SYSDATE );
              l_gl_interface.status := 'NEW';
              l_gl_interface.actual_flag := 'A';
              l_gl_interface.group_id := p_Post.PostingControlId;
              l_gl_interface.set_of_books_id := p_Post.SetOfBooksId;
              l_gl_interface.user_je_source_name := p_Post.UserSource;

              IF RRa.AmountAppFrom IS NULL
              THEN
                l_gl_interface.user_je_category_name := p_Post.UserTrade ;
              ELSE
                l_gl_interface.user_je_category_name := p_Post.UserCcurr ;
              END IF;

              l_gl_interface.accounting_date := RRa.GlDate;
              l_gl_interface.subledger_doc_sequence_id := RRA.CrDocSequenceId;
              l_gl_interface.subledger_doc_sequence_value := RRa.CrDocSequenceValue;
              l_gl_interface.ussgl_transaction_code := RRa.UssglTransactionCode;
              l_gl_interface.Currency_code := RRa.CurrencyCode;
              l_gl_interface.code_combination_id := RRa.CodeCombinationId;

              IF RRa.amount < 0
              THEN
                l_gl_interface.entered_dr := -RRa.amount;
              ELSE
                l_gl_interface.entered_cr := RRa.amount;
              END IF;

              IF RRa.AcctdAmount < 0
              THEN
                l_gl_interface.accounted_dr := -RRa.AcctdAmount;
              ELSE
                l_gl_interface.accounted_cr := RRa.AcctdAmount;
              END IF;

              l_gl_interface.reference1 :=
		   'AR '||to_char(p_Post.PostingControlId);

              IF p_Post.SummaryFlag = 'Y'
              THEN
                l_gl_interface.reference10 := NULL;
              ELSE
                l_gl_interface.reference10 := p_Post.NlsPreTradeApp||' '||RRa.ReceiptNumber;
                IF RRa.Status = 'ACC'
                THEN
                  l_gl_interface.reference10 :=
                    l_gl_interface.reference10 || p_Post.NlsAppOnAcc;
                ELSIF RRa.Status = 'OTHER ACC'
                THEN
                  l_gl_interface.reference10 :=
                    l_gl_interface.reference10 || p_Post.NlsAppOtherAcc;
                ELSIF RRa.Status = 'UNAPP'
                THEN
                  l_gl_interface.reference10 :=
                    l_gl_interface.reference10 || p_Post.NlsAppUnapp;
                ELSIF RRa.Status = 'UNID'
                THEN
                  l_gl_interface.reference10 :=
                    l_gl_interface.reference10 || p_Post.NlsAppUnid;
                ELSIF RRa.Status = 'ACTIVITY'
                THEN
                  l_gl_interface.reference10 :=
                    l_gl_interface.reference10 || p_Post.NlsAppActivity;
                END IF;

                l_gl_interface.reference10 :=
                  l_gl_interface.reference10 || p_Post.NlsPostTradeApp;
              END IF;

              l_gl_interface.reference21 := p_Post.PostingControlId;
              l_gl_interface.reference22 := RRa.CashReceiptId;
              l_gl_interface.reference23 := RRa.ReceivableApplicationId;
              l_gl_interface.reference24 := RRa.ReceiptNumber;
              l_gl_interface.reference25 := NULL;
              l_gl_interface.reference26 := NULL;
              l_gl_interface.reference27 := RRa.PayFromCustomer;

              IF RRa.AmountAppFrom IS NULL
              THEN
                l_gl_interface.reference28 := 'TRADE';
                l_gl_interface.reference29 := 'TRADE_APP';
              ELSE
                l_gl_interface.reference28 := 'CCURR';
                l_gl_interface.reference29 := 'CCURR_APP';
              END IF;
              l_gl_interface.reference30 := 'AR_RECEIVABLE_APPLICATIONS' ;

              CreateInterface(l_gl_interface) ;

            EXCEPTION
              WHEN OTHERS THEN
                    arp_standard.debug( 'Exception:PostNonDistApplications.INSERT:' );
                    arp_standard.debug('RRa.CashReceiptId:'||RRa.CashReceiptId );
                    arp_standard.debug('RRa.ReceiptNumber:'||RRa.ReceiptNumber );
                    arp_standard.debug('RRa.CrDocSequenceId:'||RRa.CrDocSequenceId );
                    arp_standard.debug('RRa.CrDocSequenceValue:'||RRa.CrDocSequenceValue );
                    arp_standard.debug('RRa.PayFromCustomer:'||RRa.PayFromCustomer );
                    arp_standard.debug('RRa.CurrencyCode:'||RRa.CurrencyCode );
                    arp_standard.debug('RRa.ReceivableApplicationId:'||RRa.ReceivableApplicationId );
                    arp_standard.debug('RRa.GlDate:'||RRa.GlDate );
                    arp_standard.debug('RRa.UssglTransactionCode:'||RRa.UssglTransactionCode );
                    arp_standard.debug('RRa.Amount:'||RRa.Amount );
                    arp_standard.debug('RRa.AcctdAmount:'||RRa.AcctdAmount );
                    arp_standard.debug('RRa.CodeCombinationId:'||RRa.CodeCombinationId );
                    arp_standard.debug('RRa.Status:'||RRa.Status );
                    RAISE;
            END;

            UPDATE ar_receivable_applications
             SET  posting_control_id = p_Post.PostingControlId,
                  gl_posted_date     = p_Post.GlPostedDate
            WHERE  rowid = RRa.RaRowid;

	    l_Count := l_Count + 1;
          END LOOP;

        /* reporting sob */
        ELSE
          NULL;

--          arp_standard.debug('    Reporting sob');
--          FOR RRa IN CRa_mrc
--          LOOP
--            BEGIN
	    /* bug3692482 replace insert stmt with CreateInterface procedure */
--              l_gl_interface := l_gl_interface_null ;

--              l_gl_interface.created_by := p_Post.CreatedBy;
--              l_gl_interface.date_created := TRUNC( SYSDATE );
--              l_gl_interface.status := 'NEW';
--              l_gl_interface.actual_flag := 'A';
--              l_gl_interface.group_id := p_Post.PostingControlId;
--              l_gl_interface.set_of_books_id := p_Post.SetOfBooksId;
--              l_gl_interface.user_je_source_name := p_Post.UserSource;

--              IF RRa.AmountAppFrom IS NULL
--              THEN
--                l_gl_interface.user_je_category_name := p_Post.UserTrade ;
--              ELSE
--                l_gl_interface.user_je_category_name := p_Post.UserCcurr ;
--              END IF;

--              l_gl_interface.accounting_date := RRa.GlDate;
--              l_gl_interface.subledger_doc_sequence_id := RRA.CrDocSequenceId;
--              l_gl_interface.subledger_doc_sequence_value := RRa.CrDocSequenceValue;
--              l_gl_interface.ussgl_transaction_code := RRa.UssglTransactionCode;
--              l_gl_interface.Currency_code := RRa.CurrencyCode;
--              l_gl_interface.code_combination_id := RRa.CodeCombinationId;

--              IF RRa.amount < 0
--              THEN
--                l_gl_interface.entered_dr := -RRa.amount;
--              ELSE
--                l_gl_interface.entered_cr := RRa.amount;
--              END IF;

--              IF RRa.AcctdAmount < 0
--              THEN
--                l_gl_interface.accounted_dr := -RRa.AcctdAmount;
--              ELSE
--                l_gl_interface.accounted_cr := RRa.AcctdAmount;
--              END IF;

--              l_gl_interface.reference1 :=
--		   'AR '||to_char(p_Post.PostingControlId);

--              IF p_Post.SummaryFlag = 'Y'
--              THEN
--                l_gl_interface.reference10 := NULL;
--              ELSE
--                l_gl_interface.reference10 := p_Post.NlsPreTradeApp||' '||RRa.ReceiptNumber;
--                IF RRa.Status = 'ACC'
--                THEN
--                  l_gl_interface.reference10 :=
--                    l_gl_interface.reference10 || p_Post.NlsAppOnAcc;
--                ELSIF RRa.Status = 'OTHER ACC'
--                THEN
--                  l_gl_interface.reference10 :=
--                    l_gl_interface.reference10 || p_Post.NlsAppOtherAcc;
--                ELSIF RRa.Status = 'UNAPP'
--                THEN
--                  l_gl_interface.reference10 :=
--                    l_gl_interface.reference10 || p_Post.NlsAppUnapp;
--                ELSIF RRa.Status = 'UNID'
--                THEN
--                  l_gl_interface.reference10 :=
--                    l_gl_interface.reference10 || p_Post.NlsAppUnid;
--                ELSIF RRa.Status = 'ACTIVITY'
--                THEN
--                  l_gl_interface.reference10 :=
--                    l_gl_interface.reference10 || p_Post.NlsAppActivity;
--                END IF;

--                l_gl_interface.reference10 :=
--                  l_gl_interface.reference10 || p_Post.NlsPostTradeApp;
--              END IF;

--              l_gl_interface.reference21 := p_Post.PostingControlId;
--              l_gl_interface.reference22 := RRa.CashReceiptId;
--              l_gl_interface.reference23 := RRa.ReceivableApplicationId;
--              l_gl_interface.reference24 := RRa.ReceiptNumber;
--              l_gl_interface.reference25 := NULL;
--              l_gl_interface.reference26 := NULL;
--              l_gl_interface.reference27 := RRa.PayFromCustomer;


--              IF RRa.AmountAppFrom IS NULL
--              THEN
--                l_gl_interface.reference28 := 'TRADE';
--                l_gl_interface.reference29 := 'TRADE_APP';
--              ELSE
--                l_gl_interface.reference28 := 'CCURR';
--                l_gl_interface.reference29 := 'CCURR_APP';
--              END IF;

--              l_gl_interface.reference30 := 'AR_RECEIVABLE_APPLICATIONS' ;

--              CreateInterface(l_gl_interface) ;

--            EXCEPTION
--                WHEN OTHERS THEN
--                    arp_standard.debug( 'Exception:PostNonDistApplications.INSERT:' );
--                    arp_standard.debug('RRa.CashReceiptId:'||RRa.CashReceiptId );
--                    arp_standard.debug('RRa.ReceiptNumber:'||RRa.ReceiptNumber );
--                    arp_standard.debug('RRa.CrDocSequenceId:'||RRa.CrDocSequenceId );
--                    arp_standard.debug('RRa.CrDocSequenceValue:'||RRa.CrDocSequenceValue );
--                    arp_standard.debug('RRa.PayFromCustomer:'||RRa.PayFromCustomer );
--                    arp_standard.debug('RRa.CurrencyCode:'||RRa.CurrencyCode );
--                    arp_standard.debug('RRa.ReceivableApplicationId:'||RRa.ReceivableApplicationId );
--                    arp_standard.debug('RRa.GlDate:'||RRa.GlDate );
--                    arp_standard.debug('RRa.UssglTransactionCode:'||RRa.UssglTransactionCode );
--                    arp_standard.debug('RRa.Amount:'||RRa.Amount );
--                    arp_standard.debug('RRa.AcctdAmount:'||RRa.AcctdAmount );
--                    arp_standard.debug('RRa.CodeCombinationId:'||RRa.CodeCombinationId );
--                    arp_standard.debug('RRa.Status:'||RRa.Status );
--                    RAISE;
--            END;

--	    UPDATE ar_mc_receivable_apps
--	    SET  posting_control_id = p_Post.PostingControlId,
--	         gl_posted_date     = p_Post.GlPostedDate
--	    WHERE  rowid = RRa.RaRowid;

--            l_Count := l_Count + 1;

--          END LOOP;
--}
        END IF;

        arp_standard.debug( '         '||l_Count||' lines posted' );
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:PostNonDistApplications:' );
            RAISE;
    END;
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      PostDistributedApplications                                          |
 |                                                                           |
 |  DESCRIPTION                                                              |
 |      post unposted ar_receivable_applications records		     |
 |      We need to have ORDER BY clause in the select statement because      |
 |      when comparing with Journal Entry report, they need to match,        |
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
 |    22-NOV-2000  M Raymond          Changed exchange rate calc in cursor
 |                                    for receipts (CRa) to utilize the
 |                                    trans_to_receipt_rate from the
 |                                    ar_receivable_applications table.
 |                                    See bug 1429867 for details.
 |                                    New exchange rate is calculated as:
 |                                      NVL(crh.exchange_rate,1) *
 |                                      NVL(ra.trans_to_receipt_rate,1)
 |    18-APR-01    S.Nambiar          Modified the sql to fetch activity record
 |                                    also
 |    16-JAN-2002  R Kader            Modified the cursor CRa not to fetch
 |                                    ACTIVITY records
 |                                    See bug 2177009 / 2187023 for details
 |    03-JUN-2003  M Raymond          Removed MRC schema dependency
 |                                    this one looks iffy!
 *---------------------------------------------------------------------------*/
    PROCEDURE PostDistributedApplications( p_Post IN PostingParametersType  ) IS
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
			'CM', ctcm.doc_sequence_id,
			'CASH',cr.doc_sequence_id )    CrDocSequenceId,
                DECODE(
			ra.application_type,
			'CM', ctcm.doc_sequence_value,
			'CASH',cr.doc_sequence_value ) CrDocSequenceValue,
                DECODE(
			ra.application_type,
			'CM', ctcm.bill_to_customer_id,
			'CASH',cr.pay_from_customer )  PayFromCustomer,
                /*Bug3235636 ct.invoice_currency_code commented to take it from
                  get_currency_code*/
                /*ct.invoice_currency_code               CurrencyCode,*/
                /*For Bug 4936298 change ar_ta_util_pub to arpt_sql_func_util*/
                arpt_sql_func_util.get_currency_code(ra.application_type,ra.status,
		'CURR_',cr.currency_code,ct.invoice_currency_code)     CurrencyCode,
                DECODE(
			ra.application_type,
			'CM', NVL(ctcm.exchange_rate,1),
			'CASH',NVL(crh.exchange_rate,1) *
                               NVL(ra.trans_to_receipt_rate, 1))  ExchangeRate,
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
                ra.gl_date                             GlDate,
                ra.ussgl_transaction_code              UssglTransactionCode,
		ra.application_type                    AppType,
		DECODE(
			l.lookup_code,
			'1', ra.amount_applied,
			'2', -ra.amount_applied
			)			       Amount,
                DECODE(
			ra.application_type,
                         'CM',null,
                         'CASH',ra.amount_applied_from
			)                              AmountAppFrom,

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
                ct.org_id                                 OrgId
        FROM    ar_receivable_applications    ra,
                ra_cust_trx_types             ctt,
                ra_customer_trx               ct,
                ar_cash_receipts              cr,
                ar_cash_receipt_history       crh,
		ra_customer_trx               ctcm,
		ar_lookups	 	      l
        WHERE   ra.posting_control_id              = p_Post.UnpostedPostingControlId
        AND     ra.gl_date                         BETWEEN p_Post.GlDateFrom
                                                   AND     p_Post.GlDateTo
   	AND	nvl(ra.postable,'Y')		   = 'Y'
   	AND	nvl(ra.confirmed_flag,'Y')	   = 'Y'
        AND     ra.status||''                      = 'APP'    -- Bug 2187023
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
        AND     ra.receivable_application_id+0     <  p_Post.NxtReceivableApplicationId
	ORDER BY ra.receivable_application_id, l.lookup_code
        FOR UPDATE OF ra.receivable_application_id;

--{BUG4301323
--        CURSOR CRa_mrc IS
--        SELECT  ra.ROWID                               ra_rowid,
--                DECODE(
--			ra.application_type,
--			'CM', ctcm.customer_trx_id,
--			'CASH',cr.cash_receipt_id )    CashReceiptId,
--                DECODE(
--			ra.application_type,
--			'CM', ctcm.trx_number,
--			'CASH',cr.receipt_number )     ReceiptNumber,
--                DECODE(
--			ra.application_type,
--			'CM', ctcm.doc_sequence_id,
--			'CASH',cr.doc_sequence_id )    CrDocSequenceId,
--                DECODE(
--			ra.application_type,
--			'CM', ctcm.doc_sequence_value,
--			'CASH',cr.doc_sequence_value ) CrDocSequenceValue,
--                DECODE(
--			ra.application_type,
--			'CM', ctcm.bill_to_customer_id,
--			'CASH',cr.pay_from_customer )  PayFromCustomer,
--                /*Bug3235636 ct.invoice_currency_code commented to take it from
--                  get_currency_code*/
--                /*ct.invoice_currency_code               CurrencyCode,*/
--                ar_ta_util_pub.get_currency_code(ra.application_type,ra.status,
--		'CURR_',cr.currency_code,ct.invoice_currency_code)     CurrencyCode,
--                DECODE(
--			ra.application_type,
--			'CM', NVL(ctcm.exchange_rate,1),
--			'CASH',NVL(crh.exchange_rate,1) *
--                               NVL(ra.trans_to_receipt_rate, 1))  ExchangeRate,
--		DECODE(
--			l.lookup_code,
--			'1', 'N',
--			'2', 'Y'
--			)			       CmPsIdFlag,
--		DECODE(
--			l.lookup_code,
--			'1', ra.applied_payment_schedule_id,
--			'2', ra.payment_schedule_id
--			)			       PaymentScheduleId,
--                ctt.type                               Class,
--                ct.trx_number                          TrxNumber,
--                ra.receivable_application_id           ReceivableApplicationId,
--                ra.gl_date                             GlDate,
--                ra.ussgl_transaction_code              UssglTransactionCode,
--		ra.application_type                    AppType,
--		DECODE(
--			l.lookup_code,
--			'1', ra.amount_applied,
--			'2', -ra.amount_applied
--			)			       Amount,
--                DECODE(
--			ra.application_type,
--                         'CM',null,
--                         'CASH',ra.amount_applied_from
--			)                              AmountAppFrom,
--		DECODE(
--			l.lookup_code,
--			'1', ra.acctd_amount_applied_from,
--			'2', -ra.acctd_amount_applied_from
--			)			       AcctdAmount,
--		DECODE(
--			l.lookup_code,
--			'1', NVL(ra.line_applied,0),
--			'2', NVL(-ra.line_applied,0)
--			)			       LineApplied,
--		DECODE(
--			l.lookup_code,
--			'1', NVL(ra.tax_applied,0),
--			'2', NVL(-ra.tax_applied,0)
--			)			       TaxApplied,
--		DECODE(
--			l.lookup_code,
--			'1', NVL(ra.freight_applied,0),
--			'2', NVL(-ra.freight_applied,0)
--			)			       FreightApplied,
--		DECODE(
--			l.lookup_code,
--			'1', NVL(ra.receivables_charges_applied,0),
--			'2', NVL(-ra.receivables_charges_applied,0)
--			)			       ChargesApplied
--      FROM    ar_receivable_apps_mrc_v      ra,
--                ra_cust_trx_types             ctt,
--                ra_customer_trx               ct,
--                ar_cash_receipts              cr,
--                ar_cash_receipt_hist_mrc_v    crh,
--		ra_customer_trx_mrc_v         ctcm,
--		ar_lookups	 	      l
--        WHERE   ra.posting_control_id              = p_Post.UnpostedPostingControlId
--        AND     ra.gl_date                         BETWEEN p_Post.GlDateFrom
--                                                   AND     p_Post.GlDateTo
--   	AND	nvl(ra.postable,'Y')		   = 'Y'
--   	AND	nvl(ra.confirmed_flag,'Y')	   = 'Y'
--        AND     ra.status||''                      = 'APP'    -- Bug 2187023
--	AND 	ra.cash_receipt_id 		   = cr.cash_receipt_id(+)
--	AND	ra.cash_receipt_history_id 	   = crh.cash_receipt_history_id(+)
--	AND     ra.customer_trx_id		   = ctcm.customer_trx_id(+)
--	AND	ctcm.previous_customer_trx_id	   IS NULL
--	AND 	ra.applied_customer_trx_id 	   = ct.customer_trx_id
--	AND 	ct.cust_trx_type_id     	   = ctt.cust_trx_type_id
--	AND	l.lookup_type			   = 'AR_CARTESIAN_JOIN'
--	AND 	(
--	     		( l.lookup_code ='1' )
--	     		OR
--	 	     	( l.lookup_code = '2'
--        	       	  AND
--	               	  ra.application_type = 'CM' )
-- 	    	)
--        AND     ra.receivable_application_id+0     <  p_Post.NxtReceivableApplicationId
--	ORDER BY ra.receivable_application_id, l.lookup_code
--        FOR UPDATE OF ra.receivable_application_id;


        l_Rowid                 ROWID;
        l_Receipt               ReceiptType;
        l_Trx                   TrxType;
        l_App                   ApplicationType;
        l_AppAmount             ApplicationAmountType;
	l_Count			NUMBER  :=0;
    BEGIN
        arp_standard.debug( ' ' );
        arp_standard.debug( '      AR_RECEIVABLE_APPLICATION (app)...' );

        -- bug3769452 modified IF condition
        IF (NVL(p_Post.SetOfBooksType,'P') <> 'R')
        THEN
          arp_standard.debug('      Primary sob');

          OPEN CRa;
          LOOP
            FETCH   CRa
            INTO    l_rowid,
                    l_Receipt.CashReceiptId,
                    l_Receipt.ReceiptNumber,
                    l_Receipt.DocSequenceId,
                    l_Receipt.DocSequenceValue,
                    l_Receipt.PayFromCustomer,
                    l_Receipt.CurrencyCode,
                    l_Receipt.ExchangeRate,
                    l_Trx.CmPsIdFlag,
                    l_Trx.PaymentScheduleId,
                    l_Trx.Class,
                    l_Trx.TrxNumber,
                    l_App.ReceivableApplicationId,
                    l_App.GlDate,
                    l_App.UssglTransactionCode,
		    l_App.AppType,
                    l_AppAmount.Amount,
  		    l_AppAmount.AmountAppfrom,
                    l_AppAmount.AcctdAmount,
                    l_AppAmount.LineApplied,
                    l_AppAmount.TaxApplied,
                    l_AppAmount.FreightApplied,
                    l_AppAmount.ChargesApplied,
                    l_trx.OrgId;
              EXIT WHEN CRa%NOTFOUND;

            IF (l_Trx.Class = 'CM') OR (l_Trx.CmPsIdFlag = 'Y')
	    THEN
	    	DistributeApplicationType( p_Post, l_Receipt, l_Trx, l_App, 'INVOICE', l_AppAmount.Amount, l_AppAmount.AcctdAmount,
															null );
	    ELSE
	        DistributeLTFApplication( p_Post, l_Receipt, l_Trx, l_App, l_AppAmount );
	    END IF;

	    IF l_Trx.CmPsIdFlag <> 'Y'
	    THEN

                UPDATE ar_receivable_applications
                SET    posting_control_id = p_Post.PostingControlId,
                       gl_posted_date     = p_Post.GlPostedDate
                WHERE  rowid = l_Rowid;

		l_Count := l_Count + 1;

	    END IF;

        END LOOP;
        CLOSE Cra;

        /* reporting sob */
        ELSE
--{BUG4301323
NULL;
--          arp_standard.debug('      Reporting sob');
--          OPEN CRa_mrc;
--          LOOP
--            FETCH   CRa_mrc
--            INTO    l_rowid,
--                    l_Receipt.CashReceiptId,
--                    l_Receipt.ReceiptNumber,
--                    l_Receipt.DocSequenceId,
--                    l_Receipt.DocSequenceValue,
--                    l_Receipt.PayFromCustomer,
--                    l_Receipt.CurrencyCode,
--                    l_Receipt.ExchangeRate,
--                    l_Trx.CmPsIdFlag,
--                    l_Trx.PaymentScheduleId,
--                    l_Trx.Class,
--                    l_Trx.TrxNumber,
--                    l_App.ReceivableApplicationId,
--                    l_App.GlDate,
--                    l_App.UssglTransactionCode,
--		    l_App.AppType,
--                    l_AppAmount.Amount,
--  		    l_AppAmount.AmountAppfrom,
--                    l_AppAmount.AcctdAmount,
--                    l_AppAmount.LineApplied,
--                    l_AppAmount.TaxApplied,
--                    l_AppAmount.FreightApplied,
--                    l_AppAmount.ChargesApplied;
--              EXIT WHEN CRa_mrc%NOTFOUND;

--            IF (l_Trx.Class = 'CM') OR (l_Trx.CmPsIdFlag = 'Y')
--	    THEN
--	    	DistributeApplicationType( p_Post, l_Receipt, l_Trx, l_App, 'INVOICE', l_AppAmount.Amount, l_AppAmount.AcctdAmount,
--															null );
--	    ELSE
--	        DistributeLTFApplication( p_Post, l_Receipt, l_Trx, l_App, l_AppAmount );
--	    END IF;

--	    IF l_Trx.CmPsIdFlag <> 'Y'
--	    THEN

--                UPDATE ar_mc_receivable_apps
--                SET    posting_control_id = p_Post.PostingControlId,
--                       gl_posted_date     = p_Post.GlPostedDate
--                WHERE  rowid = l_Rowid;

--		l_Count := l_Count + 1;

--	    END IF;

--        END LOOP;
--        CLOSE Cra_mrc;
--}
        END IF;

        arp_standard.debug( '         '||l_Count||' lines posted' );
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:PostDistributedApplications:' );
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
 |      PostCashReceiptHistory                                               |
 |  DESCRIPTION                                                              |
 |      Posts unposted cash receipt history records                          |
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
 |      The two selects must be maintained in parallel, as the InsertIntoGl  |
 |        relies on the ROWTYPE of each select cursor being the same         |
 |                                                                           |
 |  HISTORY                                                                  |
 |    23-Jul-1993  Alan Fothergill    Created                                |
 |    21-Mar-1995  C Aldamiz	      Modified for 10.6
 |    03-JUN-2003  M Raymond          Removed MRC schema dependency
 *---------------------------------------------------------------------------*/
    PROCEDURE PostCashReceiptHistory( p_Post IN PostingParametersType ) IS
        CURSOR CCrh IS
        SELECT  crh.ROWID                            CrhRowid,
                crh.cash_receipt_history_id          CashReceiptHistoryId,
                crh.cash_receipt_id                  CashReceiptId,
                cr.receipt_number                    ReceiptNumber,
                cr.pay_from_customer                 PayFromCustomer,
                DECODE
                (
                    cr.type,
                    'MISC', 'MISC',
                    'TRADE'
                )                                    ModifiedType,
                nvl(d.amount_dr, -d.amount_cr)       Amount,
                nvl(d.acctd_amount_dr, -d.acctd_amount_cr) AcctdAmount,
                d.code_combination_id  		     AccountCodeCombinationId,
                crh.gl_date                          GlDate,
                cr.currency_code                     CurrencyCode,
                DECODE
                (
                    cr.type,
                    'MISC', p_Post.UserMisc,
                    p_Post.UserTrade
                )                                    Category,
                cr.doc_sequence_id                   DocSequenceId,
                cr.doc_sequence_value                DocSequenceValue,
                cr.ussgl_transaction_code            UssglTransactionCode,
		d.source_type			     SourceType
        FROM    ar_cash_receipt_history       crh,
                ar_cash_receipts              cr,
		ar_distributions	      d
        WHERE   crh.gl_date                   BETWEEN p_Post.GlDateFrom
                                              AND     p_Post.GlDateTo
        AND     crh.posting_control_id        = p_Post.UnpostedPostingControlId
        AND     crh.postable_flag             = 'Y'
        AND     cr.cash_receipt_id            = crh.cash_receipt_id
        AND     crh.cash_receipt_history_id+0 < p_Post.NxtCashReceiptHistoryId
	AND	crh.cash_receipt_history_id   = d.source_id
	AND	d.source_table = 'CRH'
        FOR UPDATE OF crh.cash_receipt_history_id;
--{BUG4301323
--        CURSOR CCrh_rsob IS
--        SELECT  crh_mc.ROWID                         CrhRowid,
--                crh_mc.cash_receipt_history_id      CashReceiptHistoryId,
--                crh.cash_receipt_id                  CashReceiptId,
--                cr.receipt_number                    ReceiptNumber,
--                cr.pay_from_customer                 PayFromCustomer,
--                DECODE
--                (
--                    cr.type,
--                    'MISC', 'MISC',
--                    'TRADE'
--                )                                    ModifiedType,
--                nvl(d.amount_dr, -d.amount_cr)       Amount,
--                nvl(d.acctd_amount_dr, -d.acctd_amount_cr) AcctdAmount,
--                d.code_combination_id  		     AccountCodeCombinationId,
--                crh.gl_date                          GlDate,
--                cr.currency_code                     CurrencyCode,
--                DECODE
--                (
--                    cr.type,
--                    'MISC', p_Post.UserMisc,
--                    p_Post.UserTrade
--                )                                    Category,
--                cr.doc_sequence_id                   DocSequenceId,
--                cr.doc_sequence_value                DocSequenceValue,
--                cr.ussgl_transaction_code            UssglTransactionCode,
--		d.source_type			     SourceType
--        FROM    ar_mc_cash_receipt_hist       crh_mc,
--                ar_cash_receipt_history       crh,
--                ar_cash_receipts              cr,
--		ar_distributions_mrc_v	      d
--        WHERE   crh.gl_date                   BETWEEN p_Post.GlDateFrom
--                                              AND     p_Post.GlDateTo
--        AND     crh_mc.posting_control_id     = p_Post.UnpostedPostingControlId
--        AND     crh.postable_flag             = 'Y'
--        AND     cr.cash_receipt_id            = crh.cash_receipt_id
--        AND     crh.cash_receipt_history_id+0 < p_Post.NxtCashReceiptHistoryId
--	AND	crh.cash_receipt_history_id   = d.source_id
--	AND	d.source_table                = 'CRH'
--        AND     d.set_of_books_id             = crh_mc.set_of_books_id
--        AND     crh.cash_receipt_history_id   = crh_mc.cash_receipt_history_id
--        AND     crh_mc.set_of_books_id        = p_Post.SetOfBooksId
--        FOR UPDATE OF crh_mc.cash_receipt_history_id;
--}
        RCrh  CCrh%ROWTYPE;
	l_Count			NUMBER  :=0;

        PROCEDURE InsertIntoGl( RCrh IN CCrh%ROWTYPE ) IS
          l_gl_interface  gl_interface%ROWTYPE ;
          l_gl_interface_null  gl_interface%ROWTYPE ;
        BEGIN
	  /* bug3692482 replace insert stmt with CreateInterface procedure */
          l_gl_interface := l_gl_interface_null;

          l_gl_interface.created_by := p_Post.CreatedBy;
          l_gl_interface.date_created := TRUNC( SYSDATE );
          l_gl_interface.status := 'NEW';
          l_gl_interface.actual_flag := 'A';
          l_gl_interface.group_id := p_Post.PostingControlId;
          l_gl_interface.set_of_books_id := p_Post.SetOfBooksId;
          l_gl_interface.user_je_source_name := p_Post.UserSource;
          l_gl_interface.user_je_category_name := RCrh.Category;
          l_gl_interface.accounting_date := RCrh.GlDate;
          l_gl_interface.subledger_doc_sequence_id := RCrh.DocSequenceId;
          l_gl_interface.subledger_doc_sequence_value := RCrh.DocSequenceValue;
          l_gl_interface.ussgl_transaction_code := RCrh.UssglTransactionCode;
          l_gl_interface.Currency_code := RCrh.CurrencyCode;
          l_gl_interface.code_combination_id := RCrh.AccountCodeCombinationId;

          IF RCrh.amount < 0
          THEN
            l_gl_interface.entered_cr := -RCrh.amount;
          ELSE
            l_gl_interface.entered_dr := RCrh.amount;
          END IF;

          IF RCrh.AcctdAmount < 0
          THEN
            l_gl_interface.accounted_cr := -RCrh.AcctdAmount;
          ELSE
            l_gl_interface.accounted_dr := RCrh.AcctdAmount;
          END IF;

          l_gl_interface.reference1 := 'AR '||p_Post.PostingControlId;

          IF p_Post.SummaryFlag = 'Y'
          THEN
            l_gl_interface.reference10 := NULL;
          ELSE
            l_gl_interface.reference10 := p_Post.NlsPreReceipt||' '||RCrh.ReceiptNumber||' '||p_Post.NlsPostReceipt ;
          END IF;

          l_gl_interface.reference21 := p_Post.PostingControlId;
          l_gl_interface.reference22 := RCrh.CashReceiptId;
          l_gl_interface.reference23 := RCrh.CashReceiptHistoryId;
          l_gl_interface.reference24 := RCrh.ReceiptNumber;
          l_gl_interface.reference27 := RCrh.PayFromCustomer;
          l_gl_interface.reference28 := RCrh.ModifiedType;
          l_gl_interface.reference29 := RCrh.ModifiedType||'_'||RCrh.SourceType;
          l_gl_interface.reference30 := 'AR_CASH_RECEIPT_HISTORY' ;

          CreateInterface( l_gl_interface );

        EXCEPTION
            WHEN OTHERS THEN
                arp_standard.debug( 'InsertIntoGl:' );
                RAISE;
        END;
--
-- This is the actual PostCashReceiptHistory body
--
    BEGIN
        arp_standard.debug( ' ' );
        arp_standard.debug( '      AR_CASH_RECEIPT_HISTORY...' );

        -- bug3769452 modified IF condition
        IF (p_Post.SetOfBooksType <> 'R')
        THEN
           arp_standard.debug('       Primary sob');
           OPEN CCrh;
           LOOP
               FETCH CCrh
               INTO  RCrh;
               EXIT WHEN CCrh%NOTFOUND;
               InsertIntoGl( RCrh );
               UPDATE ar_cash_receipt_history
               SET    posting_control_id      = p_Post.PostingControlId,
                      gl_posted_date          = p_Post.GlPostedDate
               WHERE  ROWID                   = RCrh.CrhRowid;
	       l_Count := l_Count + 1;
           END LOOP;
           CLOSE CCrh;

        /* reporting sob */
        ELSE
--{BUG4301323
NULL;
--           arp_standard.debug('       Reporting sob');
--           OPEN CCrh_rsob;
--           LOOP
--               FETCH CCrh_rsob
--               INTO  RCrh;
--               EXIT WHEN CCrh_rsob%NOTFOUND;
--               InsertIntoGl( RCrh );
--               UPDATE ar_mc_cash_receipt_hist
--               SET    posting_control_id      = p_Post.PostingControlId,
--                      gl_posted_date          = p_Post.GlPostedDate
--               WHERE  ROWID                   = RCrh.CrhRowid;
--	       l_Count := l_Count + 1;
--           END LOOP;
--           CLOSE CCrh_rsob;
--}
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'PostCashReceiptHistory:' );
            RAISE;
    END;
--
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      PostMiscCashDistributions                                            |
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
 |    23-Jul-1993  Alan Fothergill    Created                                |
 |    03-JUN-2003  M Raymond          Removed MRC schema dependency
 *---------------------------------------------------------------------------*/
    PROCEDURE PostMiscCashDistributions( p_Post IN PostingParametersType ) IS
        CURSOR CMcd IS
        SELECT  mcd.ROWID                            McdRowid,
                mcd.misc_cash_distribution_id        MiscCashDistributionId,
                cr.cash_receipt_id                   CashReceiptId,
                cr.receipt_number                    ReceiptNumber,
                mcd.amount                           amount,
                mcd.acctd_amount                     acctd_amount,
                mcd.code_combination_id              code_combination_id,
                mcd.gl_date			     gl_date,
                cr.currency_code                     currency_code,
                p_Post.UserMisc                      category,
                cr.doc_sequence_id                   doc_sequence_id,
                cr.doc_sequence_value                doc_sequence_value,
                mcd.ussgl_transaction_code           ussgl_transaction_code
        FROM    ar_misc_cash_distributions    mcd,
                ar_cash_receipts              cr
        WHERE   mcd.posting_control_id        = p_Post.UnpostedPostingControlId
        AND     mcd.gl_date                   BETWEEN p_Post.GlDateFrom
                                                   AND     p_Post.GlDateTo
        AND     cr.cash_receipt_id              = mcd.cash_receipt_id
        AND     mcd.misc_cash_distribution_id+0 < p_Post.NxtMiscCashDistributionId
        FOR UPDATE OF mcd.misc_cash_distribution_id;
--{BUG4301323
/*
        CURSOR CMcd_mrc IS
        SELECT  mcd_mrc.ROWID                        McdRowid,
                mcd_mrc.misc_cash_distribution_id    MiscCashDistributionId,
                cr.cash_receipt_id                   CashReceiptId,
                cr.receipt_number                    ReceiptNumber,
                mcd_mrc.amount                       amount,
                mcd_mrc.acctd_amount                 acctd_amount,
                mcd.code_combination_id              code_combination_id,
                mcd.gl_date			     gl_date,
                cr.currency_code                     currency_code,
                p_Post.UserMisc                      category,
                cr.doc_sequence_id                   doc_sequence_id,
                cr.doc_sequence_value                doc_sequence_value,
                mcd.ussgl_transaction_code           ussgl_transaction_code
        FROM    ar_misc_cash_distributions    mcd,
                ar_mc_misc_cash_dists         mcd_mrc,
                ar_cash_receipts              cr
        WHERE   mcd.posting_control_id        = p_Post.UnpostedPostingControlId
        AND     mcd.gl_date                   BETWEEN p_Post.GlDateFrom
                                                   AND     p_Post.GlDateTo
        AND     cr.cash_receipt_id              = mcd.cash_receipt_id
        AND     mcd.misc_cash_distribution_id+0 < p_Post.NxtMiscCashDistributionId
        AND     mcd.misc_cash_distribution_id = mcd_mrc.misc_cash_distribution_id
        AND     mcd_mrc.set_of_books_id = p_Post.SetOfBooksId
        FOR UPDATE OF mcd_mrc.misc_cash_distribution_id;
*/

	l_Count			NUMBER  :=0;

        l_gl_interface  gl_interface%ROWTYPE;
        l_gl_interface_null  gl_interface%ROWTYPE;

    BEGIN
        arp_standard.debug( ' ' );
        arp_standard.debug( '      AR_MISC_CASH_DISTRIBUTIONS...' );

        -- bug3769452 modified IF condition
        IF (p_Post.SetOfBooksType <> 'R')
        THEN
          arp_standard.debug('      Primary sob');
          FOR RMcd IN CMcd
          LOOP
	    /* bug3692482 replace insert stmt with CreateInterface procedure */
            l_gl_interface := l_gl_interface_null;

            /* first create the debit in gl_interface to the
               account_code_combination_id */
            l_gl_interface.created_by := p_Post.CreatedBy;
            l_gl_interface.date_created := TRUNC( SYSDATE );
            l_gl_interface.status := 'NEW';
            l_gl_interface.actual_flag := 'A';
            l_gl_interface.group_id := p_Post.PostingControlId;
            l_gl_interface.set_of_books_id := p_Post.SetOfBooksId;
            l_gl_interface.user_je_source_name := p_Post.UserSource;
            l_gl_interface.user_je_category_name := RMcd.category;
            l_gl_interface.accounting_date := RMcd.gl_date;
            l_gl_interface.subledger_doc_sequence_id := RMcd.doc_sequence_id;
            l_gl_interface.subledger_doc_sequence_value := RMcd.doc_sequence_value;
            l_gl_interface.ussgl_transaction_code :=
RMcd.ussgl_transaction_code;
            l_gl_interface.currency_code := RMcd.currency_code;
            l_gl_interface.code_combination_id := RMcd.code_combination_id;

            IF RMcd.amount < 0
            THEN
              l_gl_interface.entered_dr := -RMcd.amount;
            ELSE
              l_gl_interface.entered_cr := RMcd.amount;
            END IF;

            IF RMcd.Acctd_Amount < 0
            THEN
              l_gl_interface.accounted_dr := -RMcd.acctd_amount;
            ELSE
              l_gl_interface.accounted_cr := RMcd.acctd_amount;
            END IF;

            l_gl_interface.reference1 := 'AR '||p_Post.PostingControlId;

            IF p_Post.SummaryFlag = 'Y'
            THEN
              l_gl_interface.reference10 := NULL;
            ELSE
              l_gl_interface.reference10 := p_Post.NlsPreMiscDist||' '||RMcd.ReceiptNumber||p_Post.NlsPostMiscDist;
            END IF;

            l_gl_interface.reference21 := p_Post.PostingControlId;
            l_gl_interface.reference22 := RMcd.CashReceiptId;
            l_gl_interface.reference23 := RMcd.MiscCashDistributionId;
            l_gl_interface.reference24 := RMcd.ReceiptNumber;
            l_gl_interface.reference28 := 'MISC';
            l_gl_interface.reference29 := 'MISC_MISC';
            l_gl_interface.reference30 := 'AR_MISC_CASH_DISTRIBUTIONS';

            CreateInterface( l_gl_interface );

--
            UPDATE ar_misc_cash_distributions
            SET    posting_control_id        = p_Post.PostingControlId,
                   gl_posted_date            = p_Post.GlPostedDate
            WHERE  ROWID                     = RMcd.McdRowid;
	    l_Count := l_Count + 1;
          END LOOP;
          arp_standard.debug( '         '||l_Count||' lines posted' );
        ELSE
          /* Reporting SOB */
--{BUG4301323
NULL;

--          arp_standard.debug('       Reporting sob');
--          FOR RMcd IN CMcd_mrc
--          LOOP
	    /* bug3692482 replace insert stmt with CreateInterface procedure */
            l_gl_interface := l_gl_interface_null ;

            /* first create the debit in gl_interface to the
               account_code_combination_id */

--            l_gl_interface.created_by := p_Post.CreatedBy;
--            l_gl_interface.date_created := TRUNC( SYSDATE );
--            l_gl_interface.status := 'NEW';
--            l_gl_interface.actual_flag := 'A';
--            l_gl_interface.group_id := p_Post.PostingControlId;
--            l_gl_interface.set_of_books_id := p_Post.SetOfBooksId;
--            l_gl_interface.user_je_source_name := p_Post.UserSource;
--            l_gl_interface.user_je_category_name := RMcd.category;
--            l_gl_interface.accounting_date := RMcd.gl_date;
--            l_gl_interface.subledger_doc_sequence_id := RMcd.doc_sequence_id;
--            l_gl_interface.subledger_doc_sequence_value := RMcd.doc_sequence_value;
--            l_gl_interface.ussgl_transaction_code :=
--RMcd.ussgl_transaction_code;
--            l_gl_interface.currency_code := RMcd.currency_code;
--            l_gl_interface.code_combination_id := RMcd.code_combination_id;

--            IF RMcd.amount < 0
--            THEN
--              l_gl_interface.entered_dr := -RMcd.amount;
--            ELSE
--              l_gl_interface.entered_cr := RMcd.amount;
--            END IF;

--            IF RMcd.Acctd_Amount < 0
--            THEN
--              l_gl_interface.accounted_dr := -RMcd.acctd_amount;
--            ELSE
--              l_gl_interface.accounted_cr := RMcd.acctd_amount;
--            END IF;

--            l_gl_interface.reference1 := 'AR '||p_Post.PostingControlId;

--            IF p_Post.SummaryFlag = 'Y'
--            THEN
--              l_gl_interface.reference10 := NULL;
--            ELSE
--              l_gl_interface.reference10 := p_Post.NlsPreMiscDist||' '||RMcd.ReceiptNumber||p_Post.NlsPostMiscDist;
--            END IF;

--            l_gl_interface.reference21 := p_Post.PostingControlId;
--            l_gl_interface.reference22 := RMcd.CashReceiptId;
--            l_gl_interface.reference23 := RMcd.MiscCashDistributionId;
--            l_gl_interface.reference24 := RMcd.ReceiptNumber;
--            l_gl_interface.reference28 := 'MISC';
--            l_gl_interface.reference29 := 'MISC_MISC';
--            l_gl_interface.reference30 := 'AR_MISC_CASH_DISTRIBUTIONS';

--            CreateInterface( l_gl_interface ) ;

--
--            UPDATE ar_mc_misc_cash_dists
--            SET    posting_control_id        = p_Post.PostingControlId,
--                   gl_posted_date            = p_Post.GlPostedDate
--            WHERE  ROWID                     = RMcd.McdRowid;
--	    l_Count := l_Count + 1;
--          END LOOP;
--          arp_standard.debug( '         '||l_Count||' lines posted' );
--}
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'PostMiscCashDistributions:' );
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
 |    03-JUN-2003  M Raymond          Removed MRC schema dependency
 *---------------------------------------------------------------------------*/
    PROCEDURE ClearOOB( p_Post IN PostingParametersType,
                              p_BalanceId IN NUMBER,
			      p_CategoryCode IN VARCHAR2 ) IS
    BEGIN
	IF ( p_CategoryCode = 'TRADE') OR
           (p_CategoryCode  = 'CROSS CURR') OR
           ( p_CategoryCode = 'MISC' )
	THEN

             -- bug3769452 modified IF condition
             IF (p_Post.SetOfBooksType <> 'R')
             THEN
	        UPDATE  ar_cash_receipt_history
	        SET     gl_posted_date = NULL,
	                posting_control_id  = p_Post.UnpostedPostingControlId
	        WHERE   posting_control_id  = p_Post.PostingControlId
	        AND     cash_receipt_id     = p_BalanceId;

	        UPDATE  ar_cash_receipt_history
	        SET     reversal_gl_posted_date      = NULL,
	                reversal_posting_control_id  = p_Post.UnpostedPostingControlId
	        WHERE   reversal_posting_control_id  = p_Post.PostingControlId
	        AND     cash_receipt_id              = p_BalanceId;
             /* reporting sob */
             ELSE
--{BUG4301323
NULL;
/*
	        UPDATE  ar_mc_cash_receipt_hist
	        SET     gl_posted_date = NULL,
	                posting_control_id  = p_Post.UnpostedPostingControlId
	        WHERE   posting_control_id  = p_Post.PostingControlId
	        AND     cash_receipt_id     = p_BalanceId
                AND     set_of_books_id     = p_Post.SetOfBooksId;

	        UPDATE  ar_mc_cash_receipt_hist
	        SET     reversal_gl_posted_date      = NULL,
	                reversal_posting_control_id  = p_Post.UnpostedPostingControlId
	        WHERE   reversal_posting_control_id  = p_Post.PostingControlId
	        AND     cash_receipt_id              = p_BalanceId
                AND     set_of_books_id     = p_Post.SetOfBooksId;
*/

             END IF;
	END IF;
--
	IF p_CategoryCode = 'MISC'
	THEN
            -- bug3769452 modified IF condition
            IF (p_Post.SetOfBooksType <> 'R')
            THEN
	        UPDATE  ar_misc_cash_distributions
	        SET     gl_posted_date = NULL,
	                posting_control_id  = p_Post.UnpostedPostingControlId
	        WHERE   posting_control_id  = p_Post.PostingControlId
	        AND     cash_receipt_id     = p_BalanceId;
            /* reporting sob */
            ELSE
--{BUG4301323
NULL;
/*
	        UPDATE  ar_mc_misc_cash_dists
	        SET     gl_posted_date = NULL,
	                posting_control_id  = p_Post.UnpostedPostingControlId
	        WHERE   posting_control_id  = p_Post.PostingControlId
	        AND     cash_receipt_id     = p_BalanceId
                AND     set_of_books_id     = p_Post.SetOfBooksID;
*/
            END IF;

	END IF;

	IF ( p_CategoryCode = 'TRADE') OR
           ( p_CategoryCode = 'CMAPP' )
	THEN
           -- bug3769452 modified IF condition
           IF (p_Post.SetOfBooksType <> 'R')
           THEN
	        UPDATE  ar_receivable_applications
	        SET     gl_posted_date      = NULL,
	                posting_control_id  = p_Post.UnpostedPostingControlId
	        WHERE   posting_control_id  = p_Post.PostingControlId
	        AND     decode(p_CategoryCode,
				'CMAPP',customer_trx_id,
				'TRADE', cash_receipt_id)     = p_BalanceId;

	        DELETE  FROM ar_cash_basis_distributions
	        WHERE   cash_basis_distribution_id IN (
	            SELECT  reference23
	            FROM    gl_interface
	            WHERE   reference22          = p_BalanceId
		    AND     reference28		 = p_CategoryCode
		    AND     set_of_books_id	 = p_Post.SetOfBooksId
	            AND     group_id             = p_Post.PostingControlId
	            AND     user_je_source_name  = p_Post.UserSource
	            AND     reference30          = 'AR_CASH_BASIS_DISTRIBUTIONS'
	        );
	   /* reporting sob */
           ELSE
--{BUG4301323
NULL;
/*
	        UPDATE  ar_mc_receivable_apps
	        SET     gl_posted_date      = NULL,
	                posting_control_id  = p_Post.UnpostedPostingControlId
	        WHERE   posting_control_id  = p_Post.PostingControlId
                AND     set_of_books_id     = p_Post.SetOfBooksId
	        AND     receivable_application_id IN (
                    SELECT ra.receivable_application_id
                    FROM   ar_receivable_applications ra
                    WHERE  p_CategoryCode = 'CMAPP'
                    AND    ra.customer_trx_id = p_BalanceId
                  UNION
                    SELECT ra.receivable_application_id
                    FROM   ar_receivable_applications ra
                    WHERE  p_CategoryCode = 'TRADE'
                    AND    ra.cash_receipt_id = p_BalanceId);
*/
                /* Able to use MRC view here because view contains
                   only one table */
/*
	        DELETE  FROM ar_mc_cash_basis_dists_all
	        WHERE   set_of_books_id = p_Post.SetOfBooksId
                AND     cash_basis_distribution_id IN (
	            SELECT  reference23
	            FROM    gl_interface
	            WHERE   reference22          = p_BalanceId
		    AND     reference28		 = p_CategoryCode
		    AND     set_of_books_id	 = p_Post.SetOfBooksId
	            AND     group_id             = p_Post.PostingControlId
	            AND     user_je_source_name  = p_Post.UserSource
	            AND     reference30          = 'AR_CASH_BASIS_DISTRIBUTIONS'
	        );
*/
           END IF;
	END IF;

        DELETE  FROM gl_interface
        WHERE   reference22          = p_BalanceId
	AND	reference28	     = p_CategoryCode
	AND     set_of_books_id	     = p_Post.SetOfBooksId
        AND     group_id             = p_Post.PostingControlId
        AND     user_je_source_name  = p_Post.UserSource;

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
 |      Checks that the records inserted into gl_interface balance for each  |
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
    PROCEDURE CheckBalance( p_Post IN PostingParametersType ) IS
        CURSOR CBal  IS
        SELECT  MIN(i.currency_code)        CurrencyCode,
                i.reference22          BalanceId,
                i.reference28          CategoryCode,
                SUM(nvl(i.entered_dr,0))      SumEnteredDr,
                SUM(nvl(i.entered_cr,0))      SumEnteredCr,
                SUM(nvl(i.accounted_dr,0))    SumAccountedDr,
                SUM(nvl(i.accounted_cr,0))    SumAccountedCr
        FROM    gl_interface  i
        WHERE   i.group_id              = p_Post.PostingControlId
        AND     i.user_je_source_name   = p_Post.UserSource
	AND     i.set_of_books_id	        = p_Post.SetOfBooksId
        AND     i.accounting_date      BETWEEN p_Post.GlDateFrom
                                       AND     p_Post.GlDateTo
        GROUP BY i.reference28,
                 i.reference22
        HAVING ( nvl(decode(i.reference28,'CCURR',
                                  0,sum(nvl(entered_dr,0))),0)<>nvl(decode(i.reference28,'CCURR',
                                                                0,sum(nvl(entered_cr,0))),0)
        OR     SUM( NVL(i.accounted_dr,0)) <> SUM( NVL(i.accounted_cr, 0)));
--
        CURSOR CInt( p_BalanceId NUMBER, p_CategoryCode VARCHAR2 ) IS
        SELECT  i.entered_dr                    EnteredDr,
                i.entered_cr                    EnteredCr,
                i.accounted_dr                  AccountedDr,
                i.accounted_cr                  AccountedCr,
                i.reference30                   TableName,
                i.reference23                   Id
        FROM    gl_interface                   i
        WHERE   i.group_id              = p_Post.PostingControlId
        AND     i.user_je_source_name   = p_Post.UserSource
	AND     set_of_books_id	        = p_Post.SetOfBooksId
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

                  IF p_Post.SetOfBooksType <> 'R'
                  THEN
                    /* Primary */
                    SELECT  cbd.receivable_application_id
                    INTO    l_ReceivableApplicationId
                    FROM    ar_cash_basis_distributions    cbd
                    WHERE   cbd.cash_basis_distribution_id = RInt.Id;
                  ELSE
--{BUG4301323
                    NULL;
                    /* Reporting */
--                    SELECT  cbd.receivable_application_id
--                    INTO    l_ReceivableApplicationId
--                    FROM    ar_mc_cash_basis_dists_all cbd
--                    WHERE   cbd.cash_basis_distribution_id = RInt.Id
--                    AND     cbd.set_of_books_id = p_Post.SetOfBooksId;
--}
                  END IF;
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
            ClearOOB( p_Post, RBal.BalanceId, RBal.CategoryCode );
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'CheckBalance:' );
            RAISE;
    END;
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
    PROCEDURE Post( p_Post       IN OUT NOCOPY PostingParametersType ) IS
    l_FromRel9		VARCHAR2(1);
    BEGIN
     CheckUpgradedCustomer( l_FromRel9 );
     IF l_FromRel9 = 'Y'
     THEN
	   arp_standard.fnd_message('AR_WWS_CASH_BASIS');
     ELSE

        /* Bug 2977037 - set p_Post.SetOfBooksType here */
        SELECT nvl(mrc_sob_type_code,'P')
        INTO   p_Post.SetOfBooksType
        FROM   gl_sets_of_books
        WHERE  set_of_books_id = p_Post.SetOfBooksID;

--{BUG4301323
IF p_Post.SetOfBooksType = 'P' THEN
        PostCashReceiptHistory( p_Post );
        PostMiscCashDistributions( p_Post );
        PostNonDistApplications( p_Post );
        PostDistributedApplications( p_Post );
END IF;
--}
	IF p_Post.ChkBalance = 'Y'
	THEN
--{BUG4301323
IF p_Post.SetOfBooksType = 'P' THEN
	        CheckBalance( p_Post );
END IF;
--}
	END IF;
  END IF;
  EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:arp_cash_basis_accounting.Post( p_Post ):'||sqlerrm );
            RAISE_APPLICATION_ERROR( -20000, sqlerrm||'$Revision: 120.15 $:Post( p_Post ):' );
    END;
--
--
    PROCEDURE Post( p_PostingControlId          NUMBER,
                    p_FuncCurr                  VARCHAR2,
                    p_ChkBalance                VARCHAR2,
                    p_GlDateFrom                DATE,
                    p_GlDateTo                  DATE,
                    p_SetOfBooksId              NUMBER,
		    p_UnallocatedRevCcid	NUMBER,
                    p_GlPostedDate              DATE,
                    p_CreatedBy                 NUMBER,
                    p_UserSource                VARCHAR2,
                    p_UserTrade                 VARCHAR2,
                    p_UserMisc                  VARCHAR2,
		    p_UserCcurr                 VARCHAR2,
                    p_NxtCashReceiptHistoryId     NUMBER,
                    p_NxtReceivableApplicationId  NUMBER,
                    p_NxtMiscCashDistributionId   NUMBER,
                    p_NxtAdjustmentId             NUMBER,
                    p_NxtCustTrxLineGlDistId      NUMBER,
                    p_SummaryFlag               VARCHAR2,
                    p_NlsPreReceipt             VARCHAR2,
                    p_NlsPostReceipt            VARCHAR2,
                    p_NlsPreMiscDist            VARCHAR2,
                    p_NlsPostMiscDist           VARCHAR2,
                    p_NlsPreTradeApp            VARCHAR2,
                    p_NlsPostTradeApp           VARCHAR2,
                    p_NlsPreReceiptGl            VARCHAR2,
                    p_NlsPostReceiptGl           VARCHAR2,
                    p_NlsAppOnacc               VARCHAR2,
                    p_NlsAppOtheracc            VARCHAR2,
                    p_NlsAppUnapp               VARCHAR2,
                    p_NlsAppUnid                VARCHAR2,
                    p_NlsAppApplied             VARCHAR2,
                    p_NlsAppActivity            VARCHAR2,
                    p_UnpostedPostingControlId  ar_posting_control.posting_control_id%TYPE ) IS
    l_Post  PostingParametersType;
    BEGIN
        l_Post.PostingControlId := p_PostingControlId;
        l_Post.FuncCurr := p_FuncCurr;
        l_Post.ChkBalance := p_ChkBalance;
        l_Post.GlDateFrom := p_GlDateFrom;
        l_Post.GlDateTo := p_GlDateTo;
        l_Post.SetOfBooksId := p_SetOfBooksId;
        l_Post.UnallocatedRevCcid := p_UnallocatedRevCcid;
        l_Post.GlPostedDate := p_GlPostedDate;
        l_Post.CreatedBy := p_CreatedBy;
        l_Post.UserSource := p_UserSource;
        l_Post.UserTrade := p_UserTrade;
        l_Post.UserMisc := p_UserMisc;
        l_Post.UserCcurr := p_UserCcurr;
        l_Post.NxtCashReceiptHistoryId := p_NxtCashReceiptHistoryId;
        l_Post.NxtReceivableApplicationId := p_NxtReceivableApplicationId;
        l_Post.NxtMiscCashDistributionId := p_NxtMiscCashDistributionId;
        l_Post.NxtAdjustmentId := p_NxtAdjustmentId;
        l_Post.NxtCustTrxLineGlDistId := p_NxtCustTrxLineGlDistId;
        l_Post.SummaryFlag := p_SummaryFlag;
        l_Post.NlsPreReceipt := p_NlsPreReceipt;
        l_Post.NlsPostReceipt := p_NlsPostReceipt;
        l_Post.NlsPreMiscDist := p_NlsPreMiscDist;
        l_Post.NlsPostMiscDist := p_NlsPostMiscDist;
        l_Post.NlsPreTradeApp := p_NlsPreTradeApp;
        l_Post.NlsPostTradeApp := p_NlsPostTradeApp;
        l_Post.NlsPreReceiptGl := p_NlsPreReceiptGl;
        l_Post.NlsPostReceiptGl := p_NlsPostReceiptGl;
        l_Post.NlsAppOnacc := p_NlsAppOnacc;
        l_Post.NlsAppOtheracc := p_NlsAppOnacc;
        l_Post.NlsAppUnapp := p_NlsAppUnapp;
        l_Post.NlsAppUnid := p_NlsAppUnid;
        l_Post.NlsAppApplied := p_NlsAppApplied;
        l_Post.NlsAppActivity := p_NlsAppActivity;
        l_Post.UnpostedPostingControlId := p_UnpostedPostingControlId;
--
        Post( l_Post );
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:arp_cash_basis_accounting.Post( ... ):'||sqlerrm );
            RAISE_APPLICATION_ERROR( -20000, sqlerrm||'$Revision: 120.15 $:Post( ... ):' );
    END;
--
END arp_cash_basis_accounting;

/
