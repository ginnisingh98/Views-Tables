--------------------------------------------------------
--  DDL for Package Body IGIRCBJP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIRCBJP" AS
-- $Header: igircjpb.pls 120.7.12000000.3 2007/11/08 17:28:39 sguduru ship $

    l_debug_level NUMBER;
    l_state_level NUMBER;
    l_proc_level  NUMBER;
    l_event_level NUMBER;
    l_excep_level NUMBER;
    l_error_level NUMBER;
    l_unexp_level NUMBER;
    l_path        VARCHAR2(50);
    l_xah_ar_application_id NUMBER := 222;

    -- RECORD holder for pertinent information about the cash receipt that drives
    -- the posting of an application
    TYPE ReceiptType IS RECORD
    (
        CashReceiptId             ar_cash_receipts.cash_receipt_id%TYPE,
        ReceiptNumber             ar_cash_receipts.receipt_number%TYPE,
        PayFromCustomer           ar_cash_receipts.pay_from_customer%TYPE,
        CustomerNumber            hz_cust_accounts.account_number%TYPE,  -- Bug 3902175
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
        CmPsIdFlag           VARCHAR2(1),
        TrxNumber                    ra_customer_trx.trx_number%TYPE
    );
    --
    -- RECORD holder for pertinent information from a receivable application
    -- of status = 'APP'
    TYPE ApplicationType IS RECORD
    (
        ReceivableApplicationId      ar_receivable_applications.receivable_application_id%TYPE,
        GLDate                       DATE,    -- the gl date of the application
        TrxDate                      DATE,    -- the apply date of the application
        AppType                  ar_receivable_applications.application_type%TYPE,
        CatMeaning           ar_lookups.meaning%TYPE,
        PostingControlId         ar_receivable_applications.posting_control_id%TYPE
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
    l_log_count     NUMBER := 1;
    ArpcbpError     EXCEPTION;
    PRAGMA EXCEPTION_INIT( ArpcbpError, -20000 );
--
-- private procedures
--
    --
    -- Procedures to write Record Types using dbms_output
    --

    PROCEDURE WriteToLogFile  (p_level IN NUMBER, p_path IN VARCHAR2, p_mesg IN VARCHAR2) IS
    BEGIN
        IF (p_level  >=  l_debug_level ) THEN
                  FND_LOG.STRING  (p_level ,l_path || p_path , p_mesg );
        END IF;
    END WriteToLogFile;

   /*PROCEDURE WriteToLogFile  (pp_mesg in varchar2) IS
    BEGIN
        fnd_file.put_line( fnd_file.log , pp_mesg );
    END WriteToLogFile;*/
    PROCEDURE WriteToOutFile  (pp_mesg in varchar2) IS
    BEGIN
        fnd_file.put_line( fnd_file.output , to_char(l_log_count)||' '||pp_mesg );
        l_log_count := l_log_count+ 1;
    END WriteToOutFile;

    PROCEDURE Output( p IN ReceiptType ) IS
    BEGIN
        WriteToLogFile( l_state_level, 'Output', 'Receipt Type' );
        WriteToLogFile( l_state_level, 'Output','CashReceiptId:'||p.CashReceiptId );
        WriteToLogFile( l_state_level, 'Output','ReceiptNumber:'||p.ReceiptNumber );
        WriteToLogFile( l_state_level, 'Output','PayFromCustomer:'||p.PayFromCustomer );
        WriteToLogFile( l_state_level, 'Output','CustomerNumber:'||p.CustomerNumber );
        WriteToLogFile( l_state_level, 'Output','CurrencyCode:'||p.CurrencyCode );
        WriteToLogFile( l_state_level, 'Output','ExchangeRate:'||p.ExchangeRate );
        WriteToLogFile( l_state_level, 'Output','' );
    END;
--
    PROCEDURE Output( p IN TrxType ) IS
    BEGIN
        WriteToLogFile( l_state_level, 'Output','TrxType' );
        WriteToLogFile( l_state_level, 'Output','CmPsIdFlag:'||p.CmPsIdFlag );
        WriteToLogFile( l_state_level, 'Output','PaymentScheduleId:'||p.PaymentScheduleId );
        WriteToLogFile( l_state_level, 'Output','TrxNumber:'||p.TrxNumber );
        WriteToLogFile( l_state_level, 'Output','' );
    END;
--
    PROCEDURE Output( p IN ApplicationType ) IS
    BEGIN
        WriteToLogFile( l_state_level, 'Output','ApplicationType' );
        WriteToLogFile( l_state_level, 'Output','ReceivableApplicationId:'||p.ReceivableApplicationId );
        WriteToLogFile( l_state_level, 'Output','GLDate:'||p.GLDate );
        WriteToLogFile( l_state_level, 'Output','TrxDate:'||p.TrxDate );
        WriteToLogFile( l_state_level, 'Output','AppType:'||p.AppType );
        WriteToLogFile( l_state_level, 'Output','CatMeaning:'||p.CatMeaning );
        WriteToLogFile( l_state_level, 'Output','PostingControlId:'||p.PostingControlId );
        WriteToLogFile( l_state_level, 'Output','' );
    END;
--
    PROCEDURE Output( p IN ApplicationAmountType ) IS
    BEGIN
        WriteToLogFile( l_state_level, 'Output','ApplicationAmountType' );
        WriteToLogFile( l_state_level, 'Output','Amount:'||p.Amount );
        WriteToLogFile( l_state_level, 'Output','AcctdAmount:'||p.AcctdAmount );
        WriteToLogFile( l_state_level, 'Output','LineApplied:'||p.LineApplied );
        WriteToLogFile( l_state_level, 'Output','TaxApplied:'||p.TaxApplied );
        WriteToLogFile( l_state_level, 'Output','FreightApplied:'||p.FreightApplied );
        WriteToLogFile( l_state_level, 'Output','ChargesApplied:'||p.ChargesApplied );
        WriteToLogFile( l_state_level, 'Output','' );
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
 |      The information is extracted from the igi_ar_cash_basis_dists    |
 |          table, and is returned ordered by source ('GL' then 'ADJ') and   |
 |          source_id (ra_cust_trx_line_gl_dist_id or adjustment_id )        |
 |  PARAMETERS                                                               |
 |      p_ps_id           Payment Schedule Id for which current              |
 |                            applications are required                      |
 |      p_type            The type of current applications required -        |
 |                            LINE, TAX, FREIGHT, CHARGES, INVOICE           |
 |      Source            OUT NOCOPY PL/SQL TABLE for the source of the line        |
 |      SourceId          OUT NOCOPY PL/SQL TABLE for the source id of the line     |
 |      Amount            OUT NOCOPY PL/SQL TABLE for the amount of the line        |
 |      NextElement       OUT NOCOPY BINARY_INTEGER Stores the Next Element to be   |
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
            'UNA', cbd.amount, 0 )),0)  UnallocatedAmt
        FROM    igi_ar_cash_basis_dists            cbd
        WHERE   cbd.payment_schedule_id = p_ps_id
    AND     cbd.type                = p_type
    AND     (cbd.posting_control_id+0  > 0
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
            WriteToLogFile( l_state_level, 'Output','CCA%ROWTYPE' );
            WriteToLogFile( l_state_level, 'Output','Amount:'||p_RCa.Amount );
            WriteToLogFile( l_state_level, 'Output','Source:'||p_RCA.Source );
            WriteToLogFile( l_state_level, 'Output','SourceId:'||p_RCa.SourceId );
            WriteToLogFile( l_state_level, 'Output','--------------------------------' );
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
                    WriteToLogFile( l_excep_level, 'CurrentCBDApplications','Exception:CurrentCBDApplications.Loop:');
                    Output( Rca );
                    RAISE;
            END;
        END LOOP;
        TotalAmount := l_TotalAmount;
        NextElement := l_NextElement;
    TotalUnallocatedAmt := l_TotalUnallocatedAmt;
    EXCEPTION
        WHEN OTHERS THEN
            WriteToLogFile( l_excep_level, 'CurrentCBDApplications',' Exception:CurrentCBDApplications:' );
            WriteToLogFile( l_excep_level, 'CurrentCBDApplications','l_NextElement:'||l_NextElement );
            WriteToLogFile( l_excep_level, 'CurrentCBDApplications','l_TotalAmount:'||l_TotalAmount );
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
 |      Source            OUT NOCOPY PL/SQL TABLE for the source of the line        |
 |      SourceId          OUT NOCOPY PL/SQL TABLE for the source id of the line     |
 |      Amount            OUT NOCOPY PL/SQL TABLE for the amount of the line        |
 |      NextElement       OUT NOCOPY BINARY_INTEGER Stores the Next Element to be   |
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
                                    NextElement  OUT NOCOPY    BINARY_INTEGER,
                                    Source       OUT NOCOPY    VC3Type,
                                    SourceId     OUT NOCOPY    IdType,
                                    Ccid         OUT NOCOPY    IdType,
                                    AccntClass   OUT NOCOPY    VC15Type,
                                    Amount       OUT NOCOPY    AmountType,
                                    TotalAmount  OUT NOCOPY    NUMBER
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
    AND     a.customer_trx_id       = ct.customer_trx_id
    AND ct.cust_trx_type_id     = ctt.cust_trx_type_id
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
                WriteToLogFile( l_excep_level, 'CurrentRevDistribution','Exception:CurrentRevDistribution.Select PS Details:' );
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
            SELECT  nvl(sum(nvl(receivables_charges_adjusted,0)),0)
                        INTO    charges_adjusted
            FROM    ar_adjustments
                WHERE   payment_schedule_id = p_ps_id
            AND     status          = 'A'
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
--            WriteToLogFile( l_state_level, 'CurrentRevDistribution','On ps_id:'||p_ps_id||' for Type:'||p_Type||' the Total Distribution=0');
--            WriteToLogFile( l_state_level, 'CurrentRevDistribution','CurrentRevDistribution: TotalAmount = 0' );
--            WriteToLogFile( l_state_level, 'CurrentRevDistribution','p_ps_id:'||p_ps_id );
--            WriteToLogFile( l_state_level, 'CurrentRevDistribution','p_type:'||p_type );
--        END IF;
        TotalAmount := l_TotalAmount;
        NextElement := l_NextElement;
    EXCEPTION
        WHEN OTHERS THEN
            WriteToLogFile( l_excep_level, 'CurrentRevDistribution','Exception:CurrentRevDistribution:' );
            WriteToLogFile( l_excep_level, 'CurrentRevDistribution','l_customer_trx_id:'||l_customer_trx_id );
            WriteToLogFile( l_excep_level, 'CurrentRevDistribution','l_term_fraction:'||l_term_fraction );
            WriteToLogFile( l_excep_level, 'CurrentRevDistribution','l_currency_code:'||l_currency_code );
            WriteToLogFile( l_excep_level, 'CurrentRevDistribution','l_Amount:'||l_Amount );
            WriteToLogFile( l_excep_level, 'CurrentRevDistribution','l_AmountReconcile:'||l_AmountReconcile );
            WriteToLogFile( l_excep_level, 'CurrentRevDistribution','l_FirstInstallmentCode:'||l_FirstInstallmentCode );
            WriteToLogFile( l_excep_level, 'CurrentRevDistribution','l_NextElement:'||l_NextElement );
            WriteToLogFile( l_excep_level, 'CurrentRevDistribution','l_TotalAmount:'||l_TotalAmount );
            WriteToLogFile( l_excep_level, 'CurrentRevDistribution','l_FirstInstallmentFlag:'||l_FirstInstallmentFlag );
            RAISE;
    END;
--
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      CreateDistribution                                                   |
 |  DESCRIPTION                                                              |
 |      Creates a distribution by inserting a record into                    |
 |        igi_ar_cash_basis_dists, and a record into igi_ar_journal_interim  |
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
        CashBasisDistributionId igi_ar_cash_basis_dists.cash_basis_distribution_id%TYPE;
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
        igi_ar_journal_interim
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
        reference30
        )
        SELECT
                'NEW',                          -- status
                'A',                            -- actual flag
                p_Report.ReqId,                 -- request_id
                p_Report.CreatedBy,             -- created_by
                TRUNC( SYSDATE ),               -- date_created
                p_Report.CashSetOfBooksId,          -- set_of_books_id
                'Receivables',            -- user_je_source_name
                'Trade Receipts',                      -- user_je_category_name
                p_App.TrxDate,                         -- trx_date
                p_App.GlDate,                          -- accounting_date
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
        p_App.CatMeaning,           -- reference10,
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
            'CASH','TRADE' ),       -- reference28,
        DECODE(
            P_App.AppType,
            'CASH', 'TRADE_APP',
            'CM',   DECODE(
                    p_Trx.CmPsIdFlag,
                    'Y', 'CMAPP_REC',
                    'CMAPP_APP' )), -- reference29,
                'AR_CASH_BASIS_DISTRIBUTIONS'          -- reference30
        FROM igi_ar_cash_basis_dists cbd
        WHERE cbd.posting_control_id+0 = p_App.PostingControlId
        AND   cbd.receivable_application_id = p_App.ReceivableApplicationId
        AND   cbd.payment_schedule_id = p_Trx.PaymentScheduleId
        AND   cbd.type = p_Type;
        EXCEPTION
            WHEN OTHERS THEN
                WriteToLogFile(l_excep_level, 'CreateDistribution', 'Exception:CreateDistribution.InsertPostedAR:' );
                RAISE;
        END;
   ELSE
--
        SELECT  igi_ar_cash_basis_dists_s.NEXTVAL
        INTO    CashBasisDistributionId
        FROM    dual;
--
        BEGIN
--
--  Posting Control Id is -(req_id+100) is used to be an identifier
--  such that we can delete these records at the end of the process
--  We need to add 100 because pst_contrl_id of -1 to -100  are reserved
--  for other usage
--

                WriteToLogFile ( l_state_level, 'CreateDistribution','>> >> Application id '||p_App.ReceivableApplicationId);
                WriteToLogFile ( l_state_level, 'CreateDistribution','>> >> p_Source       '||p_source );
                WriteToLogFile ( l_state_level, 'CreateDistribution','>> >> p_Sourceid     '||p_sourceid );
                WriteToLogFile ( l_state_level, 'CreateDistribution','>> >> ReqId          '||P_report.reqid );


            INSERT INTO igi_ar_cash_basis_dists
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
                gl_posted_date
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
                - ( p_Report.ReqId +1000 ),
                TRUNC( SYSDATE )
            );
        EXCEPTION
            WHEN OTHERS THEN
                WriteToLogFile( l_excep_level, 'CreateDistribution','Exception:CreateDistribution.InsertCBD:' );
                RAISE;
        END;
--
        BEGIN
        WritetoLogFile ( l_state_level, 'CreateDistribution','CreateDistribution : Insert into AR_JOURNAL_INTERIM...');
        INSERT INTO
        igi_ar_journal_interim
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
        reference30
        )
                VALUES
                (
                'NEW',                          -- status
                'A',                            -- actual flag
        p_Report.ReqId,             -- request_id
                p_Report.CreatedBy,             -- created_by
                TRUNC( SYSDATE ),               -- date_created
                p_Report.CashSetOfBooksId,          -- set_of_books_id
                'Receivables',            -- user_je_source_name
                'Trade Receipts',                      -- user_je_category_name
                p_App.TrxDate,                         -- trx_date
                p_App.GlDate,                          -- accounting_date
                p_Receipt.CurrencyCode,                -- currency_code
                p_Ccid,                                -- code_combination_id
                DECODE
                (
                    SIGN( p_Amount ),
                    -1, -p_Amount,
                    NULL
                ),                                     -- entered_dr
                DECODE
                (
                    SIGN( p_Amount ),
                    -1, NULL,
                    p_Amount
                ),                                     -- entered_cr
                DECODE
                (
                    SIGN( p_AcctdAmount ),
                    -1, -p_AcctdAmount,
                    NULL
                ),                                     -- accounted_dr
                DECODE
                (
                    SIGN( p_AcctdAmount ),
                    -1, NULL,
                    p_AcctdAmount
                ),                                     -- accounted_cr
        p_App.CatMeaning,           -- reference10,
                p_Report.ReqId,                        -- reference21,
                p_Receipt.CashReceiptId,               -- reference22,
                CashBasisDistributionId,               -- reference23,
                p_Receipt.ReceiptNumber,               -- reference24,
                p_Trx.TrxNumber,                       -- reference25,
                p_Receipt.CustomerNumber,              -- reference26,
                p_Receipt.PayFromCustomer,             -- reference27,
        DECODE(
            P_App.AppType,
            'CM', 'CMAPP',
            'CASH','TRADE' ),       -- reference28,
        DECODE(
            P_App.AppType,
            'CASH', 'TRADE_APP',
            'CM',   DECODE(
                    p_Trx.CmPsIdFlag,
                    'Y', 'CMAPP_REC',
                    'CMAPP_APP' )), -- reference29,
                'AR_CASH_BASIS_DISTRIBUTIONS'          -- reference30
            );
        EXCEPTION
            WHEN OTHERS THEN
                WriteToLogFile(l_excep_level, 'CreateDistribution', 'Exception:CreateDistribution.InsertAR:' );
                RAISE;
        END;
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            WriteToLogFile(l_excep_level, 'CreateDistribution', 'Exception:CreateDistribution:' );
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
 |        should be when the current application is included, working out NOCOPY    |
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
    CBD_TotalUnallocatedAmt   NUMBER;
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
        AppToLineThisTime                NUMBER;     -- the actual amount posted, and stored in igi_ar_cash_basis_dists
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
--  Now if Total Revenue Distribution is zero
--  OR if Cash Basis Clearing account is non-zero,
--  Then we need to post to the Cash Basis Clearing account
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
                                        p_Report.CashSetOfBooksId,
                                        p_Type,
                                        p_Report.UnallocatedRevCcid,
                                        'INVOICE' );
        END IF;
    END IF;
   END IF;
    EXCEPTION
        WHEN OTHERS THEN
            WriteToLogFile( l_excep_level, 'DistributeApplicationType','Exception:DistributeApplicationType:' );
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
            WriteToLogFile( l_state_level, 'DistributeLTFApplication','DistributeLTFApplication' );
            WriteToLogFile( l_event_level, 'DistributeLTFApplication','LTF Charges doesn''t equal application amount for ra_id:'||p_App.ReceivableApplicationId );
            WriteToLogFile( l_state_level, 'DistributeLTFApplication','----------------------------------------' );
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
            WriteToLogFile( l_excep_level, 'DistributeLTFApplication','Exception:DistributeLTFApplication:' );
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
 |    12-Apr-1994  D Chu        Created                                  |
 *---------------------------------------------------------------------------*/
    PROCEDURE ReportNonDistApplications( p_Report IN ReportParametersType  ) IS
        CURSOR CRa IS
        SELECT  DISTINCT ra.ROWID                               RaRowid,
                cr.cash_receipt_id                     CashReceiptId,
                cr.receipt_number                      ReceiptNumber,
                cr.pay_from_customer                   PayFromCustomer,
                decode(ra.status,'UNID',null,
                hz_cust_accounts.account_number )      CustomerNumber, -- Bug 3902175
                cr.currency_code                       CurrencyCode,
                ra.receivable_application_id           ReceivableApplicationId,
                ra.gl_date                             GlDate,
                ra.apply_date                          TrxDate,
                ra.amount_applied                      Amount,
                ra.amount_applied_from                 AmountAppFrom,
                ra.acctd_amount_applied_from           AcctdAmount,
                ra.code_combination_id                 CodeCombinationId,
                ra.status                              Status,
                l_cat.meaning                          CatMeaning
        FROM    ar_receivable_applications    ra,
                igi_ar_rec_applications       igira,
                ar_cash_receipts              cr,
		            hz_parties,		-- Bug 3902175
		            hz_cust_accounts, -- Bug 3902175
                ar_lookups                l_cat,
                xla_ae_headers            xah
    WHERE       ra.gl_date          BETWEEN p_Report.GlDateFrom
                                    AND p_Report.GLDateTo
    AND igira.receivable_application_id = ra.receivable_application_id
    AND nvl(ra.postable,'Y')           = 'Y'
    AND nvl(ra.confirmed_flag,'Y')     = 'Y'
    AND ra.status                     <> 'APP'
    AND cr.cash_receipt_id             = ra.cash_receipt_id
	AND	(
                   (cr.pay_from_customer               = hz_cust_accounts.cust_account_id  -- bug 3902175
                    AND ra.status <> 'UNID')
                   OR
                    ra.status = 'UNID'
                )
    AND hz_parties.party_id = hz_cust_accounts.party_id  -- Bug 3902175
    AND l_cat.lookup_type              = 'ARRGTA_FUNCTION_MAPPING'
    AND     l_cat.lookup_code          = decode(ra.amount_applied_from,
                                                       null,'TRADE_APP','CCURR_APP')
    AND     cr.currency_code           = DECODE( p_Report.Currency,
                                null,cr.currency_code,
                                p_Report.Currency)
    AND ra.application_type||''        = 'CASH'
    AND (p_Report.Trade            = 'Y'
                  OR p_Report.Ccurr                = 'Y')
/*    AND     ( igira.arc_posting_control_id            = DECODE( p_Report.PostedStatus,
                                'BOTH', igira.arc_posting_control_id,
                                'UNPOSTED', -3,
                                -8888 )
        OR
              igira.arc_posting_control_id        <> decode( p_Report.PostedStatus,
                                'BOTH', -8888,
                                'POSTED', -3,
                                igira.arc_posting_control_id) )
*/
     AND     (
                (ra.posting_control_id > 0 AND p_Report.CallingMode = 'CBR') OR
                (p_Report.CallingMode = 'ARC')
              )
/*    AND     NVL(igira.arc_gl_posted_date,to_date('01-01-1952','DD-MM-YYYY'))
             BETWEEN
                    DECODE( p_Report.PostedStatus,
                'BOTH', nvl(igira.arc_gl_posted_date,to_date('01-01-1952',
                                    'DD-MM-YYYY')),
                'UNPOSTED',nvl(igira.arc_gl_posted_date,to_date('01-01-1952',
                                  'DD-MM-YYYY')),
                'POSTED', decode( p_Report.PostedDateFrom ,
                        null, nvl(igira.arc_gl_posted_date,to_date('01-01-1952',
                                  'DD-MM-YYYY')),
                                    p_Report.PostedDateFrom))
                AND
                    DECODE( p_Report.PostedStatus,
                'BOTH', nvl(igira.arc_gl_posted_date,to_date('01-01-1952',
                                    'DD-MM-YYYY')),
                'UNPOSTED',nvl(igira.arc_gl_posted_date,to_date('01-01-1952',
                                  'DD-MM-YYYY')),
                'POSTED', decode( p_Report.PostedDateTo,
                        null, nvl(igira.arc_gl_posted_date,to_date('01-01-1952',
                                  'DD-MM-YYYY')),
                                    p_Report.PostedDateTo))
*/
        AND ra.receivable_application_id+0     <  p_Report.NxtReceivableApplicationId
        AND xah.event_id = ra.event_id
        AND xah.application_id = l_xah_ar_application_id
        AND xah.ledger_id = p_Report.CashSetOfBooksId
        AND xah.accounting_date between p_Report.GlDateFrom and p_Report.GlDateTo
        AND xah.gl_transfer_status_code = 'Y'
        AND xah.gl_transfer_date between p_Report.PostedDateFrom and p_Report.PostedDateTo;
--
    l_Count         NUMBER  :=0;

    BEGIN
        WriteToLogFile( l_state_level, 'ReportNonDistApplications',' ' );
        WriteToLogFile( l_state_level, 'ReportNonDistApplications','      AR_RECEIVABLE_APPLICATIONS (non-app)...' );
        FOR RRa IN CRa
        LOOP
            BEGIN

        INSERT INTO
        igi_ar_journal_interim
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
        reference30
        )
                VALUES
                (
                    'NEW',                        -- status
                    'A',                          -- actual flag
            p_Report.ReqId,     -- request_id
                    p_Report.CreatedBy,             -- created_by
                    TRUNC( SYSDATE ),             -- date_created
                    p_Report.CashSetOfBooksId,          -- set_of_books_id
                    'Receivables',            -- user_je_source_name
                    decode(RRa.AmountAppFrom,
                             null,'Trade Receipts','Cross Currency'),   -- user_je_category_name
            RRa.TrxDate,            -- trx_date
                    RRa.GlDate,                   -- accounting_date
                    RRa.CurrencyCode,             -- currency_code
                    RRa.CodeCombinationId,        -- code_combination_id
                DECODE
                (
                    SIGN( RRa.amount ),
                        -1, -nvl(RRa.AmountAppFrom,RRa.amount),
                        NULL
                ),              -- entered_dr
                DECODE
                (
                    SIGN( RRa.amount ),
                        -1, NULL,
                        nvl(RRa.AmountAppFrom,RRa.amount)
                ),              -- entered_cr
                DECODE
                (
                    SIGN( RRa.AcctdAmount ),
                        -1, -RRa.AcctdAmount,
                        NULL
                ),              -- accounted_dr
                DECODE
                (
                    SIGN( RRa.AcctdAmount ),
                        -1, NULL,
                        RRa.AcctdAmount
                ),              -- accounted_cr
                RRa.CatMeaning,                     -- reference10
                    p_Report.ReqId,              -- reference21
                    RRa.CashReceiptId,           -- reference22
                    RRa.ReceivableApplicationId,     -- reference23
                    RRa.ReceiptNumber,           -- reference24
                    NULL,                       -- reference25
                    RRa.CustomerNumber,          -- reference26
                    RRa.PayFromCustomer,         -- reference27
            decode(RRa.AmountAppFrom,
                             null,'TRADE','CROSS CURR'),    -- reference28
                    decode(RRa.AmountAppFrom,
                             null,'TRADE_APP','CCURR_APP'),     -- reference29
                    'AR_RECEIVABLE_APPLICATIONS'       -- reference30
                );
            EXCEPTION
                WHEN OTHERS THEN
                    WriteToLogFile( l_excep_level,'ReportNonDistApplications','Exception:ReportNonDistApplications.INSERT:' );
                    WriteToLogFile(l_excep_level,'ReportNonDistApplications','RRa.CashReceiptId:'||RRa.CashReceiptId );
                    WriteToLogFile(l_excep_level,'ReportNonDistApplications','RRa.ReceiptNumber:'||RRa.ReceiptNumber );
                    WriteToLogFile(l_excep_level,'ReportNonDistApplications','RRa.PayFromCustomer:'||RRa.PayFromCustomer );
                    WriteToLogFile(l_excep_level,'ReportNonDistApplications','RRa.CustomerNumber:'||RRa.CustomerNumber );
                    WriteToLogFile(l_excep_level,'ReportNonDistApplications','RRa.CurrencyCode:'||RRa.CurrencyCode );
                                                                        WriteToLogFile(l_excep_level,'ReportNonDistApplications','RRa.ReceivableApplicationId:'
                    ||RRa.ReceivableApplicationId );
                    WriteToLogFile(l_excep_level,'ReportNonDistApplications','RRa.GlDate:'||RRa.GlDate );
                    WriteToLogFile(l_excep_level,'ReportNonDistApplications','RRa.TrxDate:'||RRa.TrxDate );
                    WriteToLogFile(l_excep_level,'ReportNonDistApplications','RRa.Amount:'||RRa.Amount );
                    WriteToLogFile(l_excep_level,'ReportNonDistApplications','RRa.AcctdAmount:'||RRa.AcctdAmount );
                    WriteToLogFile(l_excep_level,'ReportNonDistApplications','RRa.CodeCombinationId:'||RRa.CodeCombinationId );
                    WriteToLogFile(l_excep_level,'ReportNonDistApplications','RRa.Status:'||RRa.Status );
                    WriteToLogFile(l_excep_level,'ReportNonDistApplications','RRa.CatMeaning:'||RRa.CatMeaning );
                    RAISE;
            END;
--
         l_Count := l_Count + 1;
        END LOOP;
        WriteToLogFile( l_state_level,'ReportNonDistApplications','         '||l_Count||' lines selected' );
    EXCEPTION
        WHEN OTHERS THEN
            WriteToLogFile(l_excep_level,'ReportNonDistApplications', 'Exception:ReportNonDistApplications:' );
            RAISE;
    END;
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      ReportDistributedApplications                                        |
 |                                                                           |
 |  DESCRIPTION                                                              |
 |      post unposted ar_receivable_applications records             |
 |      post unposted ar_receivable_applications records             |
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
            hz_cust_accounts.account_number           CustomerNumber, -- Bug 3902175
                ct.invoice_currency_code               CurrencyCode,
                DECODE(
            ra.application_type,
            'CM', NVL(ctcm.exchange_rate,1),
            'CASH',NVL(crh.exchange_rate,1) )  ExchangeRate,
        DECODE(
            l.lookup_code,
            '1', 'N',
            '2', 'Y'
            )                  CmPsIdFlag,
        DECODE(
            l.lookup_code,
            '1', ra.applied_payment_schedule_id,
            '2', ra.payment_schedule_id
            )                  PaymentScheduleId,
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
            )                  Amount,
        DECODE(
            l.lookup_code,
            '1', ra.acctd_amount_applied_from,
            '2', -ra.acctd_amount_applied_from
            )                  AcctdAmount,
        DECODE(
            l.lookup_code,
            '1', NVL(ra.line_applied,0),
            '2', NVL(-ra.line_applied,0)
            )                  LineApplied,
        DECODE(
            l.lookup_code,
            '1', NVL(ra.tax_applied,0),
            '2', NVL(-ra.tax_applied,0)
            )                  TaxApplied,
        DECODE(
            l.lookup_code,
            '1', NVL(ra.freight_applied,0),
            '2', NVL(-ra.freight_applied,0)
            )                  FreightApplied,
        DECODE(
            l.lookup_code,
            '1', NVL(ra.receivables_charges_applied,0),
            '2', NVL(-ra.receivables_charges_applied,0)
            )                  ChargesApplied,
        l_cat.meaning               CatMeaning,
        igira.arc_posting_control_id           PostingControlId
        FROM    ar_receivable_applications    ra,
                igi_ar_rec_applications       igira,
                ra_cust_trx_types             ctt,
                ra_customer_trx               ct,
                ar_cash_receipts              cr,
                ar_cash_receipt_history       crh,
                ra_customer_trx               ctcm,
                ar_lookups            l,
                ar_lookups            l_cat,
                hz_parties,  -- Bug 3902175
                hz_cust_accounts,  -- Bug 3902175
                xla_ae_headers xah
    WHERE   ra.gl_date          BETWEEN p_Report.GlDateFrom
                                    AND p_Report.GLDateTo
    AND nvl(ra.postable,'Y')           = 'Y'
    AND nvl(ra.confirmed_flag,'Y')     = 'Y'
    AND ra.status||''                  = 'APP'
    AND ra.receivable_application_id   = igira.receivable_application_id
    AND ra.cash_receipt_id             = cr.cash_receipt_id(+)
    AND ra.cash_receipt_history_id     = crh.cash_receipt_history_id(+)
    AND ra.customer_trx_id             = ctcm.customer_trx_id(+)
    AND ctcm.previous_customer_trx_id      IS NULL
    AND ra.applied_customer_trx_id     = ct.customer_trx_id
    AND ct.cust_trx_type_id            = ctt.cust_trx_type_id
    AND hz_parties.party_id			   = hz_cust_accounts.party_id -- Bug 3902175
    AND l.lookup_type              = 'AR_CARTESIAN_JOIN'
    AND     (
                ( l.lookup_code ='1' )
                OR
                ( l.lookup_code = '2'
                      AND
                      ra.application_type = 'CM' )
            )
    AND hz_cust_accounts.cust_account_id           = DECODE( ra.application_type, -- Bug 3902175
                                'CM', ctcm.bill_to_customer_id,
                                cr.pay_from_customer )
        AND     l_cat.lookup_type         = 'ARRGTA_FUNCTION_MAPPING'
        AND     l_cat.lookup_code         = decode( ra.application_type,
                                               'CM', decode( l.lookup_code,
                                    '1', 'CMAPP_APP',
                                    '2', 'CMAPP_REC'),
                            'TRADE_APP')
    AND     ct.invoice_currency_code           = DECODE( p_Report.Currency,
                                null,ct.invoice_currency_code,
                                p_Report.Currency)
    AND ( ( p_Report.Trade = 'Y'  AND ra.application_type||'' = 'CASH' )
          OR
          ( p_Report.CMApp = 'Y'  AND ra.application_type||'' = 'CM' ) )
/*    AND     ( igira.arc_posting_control_id            = DECODE( p_Report.PostedStatus,
                                'BOTH', igira.arc_posting_control_id,
                                'UNPOSTED', -3,
                                -8888 )
        OR
              igira.arc_posting_control_id        <> decode( p_Report.PostedStatus,
                                'BOTH', -8888,
                                'POSTED', -3,
                                igira.arc_posting_control_id) )
*/
    AND     (
                (ra.posting_control_id > 0 AND p_Report.CallingMode = 'CBR') OR
                (p_Report.CallingMode = 'ARC')
              )
/*    AND     NVL(igira.arc_gl_posted_date,to_date('01-01-1952','DD-MM-YYYY'))
             BETWEEN
                    DECODE( p_Report.PostedStatus,
                'BOTH', nvl(igira.arc_gl_posted_date,to_date('01-01-1952',
                                    'DD-MM-YYYY')),
                'UNPOSTED',nvl(igira.arc_gl_posted_date,to_date('01-01-1952',
                                  'DD-MM-YYYY')),
                'POSTED', decode( p_Report.PostedDateFrom ,
                        null, nvl(igira.arc_gl_posted_date,to_date('01-01-1952',
                                  'DD-MM-YYYY')),
                                    p_Report.PostedDateFrom))
                AND
                    DECODE( p_Report.PostedStatus,
                'BOTH', nvl(igira.arc_gl_posted_date,to_date('01-01-1952',
                                    'DD-MM-YYYY')),
                'UNPOSTED',nvl(igira.arc_gl_posted_date,to_date('01-01-1952',
                                  'DD-MM-YYYY')),
                'POSTED', decode( p_Report.PostedDateTo,
                        null, nvl(igira.arc_gl_posted_date,to_date('01-01-1952',
                                  'DD-MM-YYYY')),
                                    p_Report.PostedDateTo))
*/
        AND     ra.receivable_application_id+0     <  p_Report.NxtReceivableApplicationId
        AND xah.event_id = crh.event_id
        AND xah.application_id = l_xah_ar_application_id
        AND xah.ledger_id = p_Report.CashSetOfBooksId
        AND xah.accounting_date between p_Report.GlDateFrom and p_Report.GlDateTo
        AND xah.gl_transfer_status_code = 'Y'
        AND xah.gl_transfer_date between p_Report.PostedDateFrom and p_Report.PostedDateTo
        ORDER BY ra.receivable_application_id, l.lookup_code;
--
        l_Rowid                 ROWID;
        l_Receipt               ReceiptType;
        l_Trx                   TrxType;
        l_App                   ApplicationType;
        l_AppAmount             ApplicationAmountType;
        l_Count                   NUMBER  :=0;
        l_Class                   VARCHAR2(20);

    FUNCTION ExistsINPaymentSchedules ( fp_ps_id in number) return boolean IS
       cursor c_exist is
          select 'x'
          from   ar_payment_schedules
          where  payment_schedule_id = fp_ps_id
          ;
    BEGIN
         FOR l_exist IN C_exist LOOP
            return TRUE;
         END LOOP;
         return FALSE;
    EXCEPTION WHEN OTHERS THEN return FALSE;
    END ExistsInPaymentSchedules;


     BEGIN
        WriteToLogFile(l_state_level,'ReportDistributedApplications',' ' );
        WriteToLogFile(l_state_level,'ReportDistributedApplications', '      AR_RECEIVABLE_APPLICATION (app)...' );
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
                    l_App.PostingControlId;
            EXIT WHEN CRa%NOTFOUND;
--

    IF ExistsINPaymentSchedules ( l_Trx.PaymentScheduleId ) THEN
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

     END IF;

        END LOOP;
        CLOSE Cra;
        WriteToLogFile( l_state_level,'ReportDistributedApplications','         '||l_Count||' lines selected' );
    EXCEPTION
        WHEN OTHERS THEN
            WriteToLogFile(l_excep_level,'ReportDistributedApplications', 'Exception:ReportDistributedApplications:' );
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
 |    12-Apr-1994  D Chu        Created                                  |
 |    21-Mar-1995  C Aldamiz        Modified for 10.6                |
 *---------------------------------------------------------------------------*/
    PROCEDURE ReportCashReceiptHistory( p_Report IN ReportParametersType ) IS
        CURSOR CCrh IS
        SELECT  crh.ROWID                            CrhRowid,
                crh.cash_receipt_history_id          CashReceiptHistoryId,
                crh.cash_receipt_id                  CashReceiptId,
                cr.receipt_number                    ReceiptNumber,
                cr.pay_from_customer                 PayFromCustomer,
                cust.customer_number      			 CustomerNumber, -- Bug 3902175
                DECODE
                (
                    cr.type,
                    'MISC', 'MISC',
                    'TRADE'
                )                                    ModifiedType,
                nvl(d.amount_dr, -d.amount_cr)       Amount,
                nvl(d.acctd_amount_dr, -d.acctd_amount_cr) AcctdAmount,
                d.code_combination_id            AccountCodeCombinationId,
                crh.gl_date                          GlDate,
                crh.trx_date                         TrxDate,
                cr.currency_code                     CurrencyCode,
                DECODE
                (
                    cr.type,
                    'MISC', 'Misc Receipts',
                    'Trade Receipts'
                )                                    Category,
               l_cat.meaning                CatMeaning,
               d.source_type                SourceType
        FROM    ar_cash_receipt_history       crh,
                igi_ar_cash_receipt_hist      igicrh,
                ar_cash_receipts              cr,
	  	(Select hz_cust_accounts.account_number customer_number,hz_cust_accounts.cust_account_id customer_id
	 	 from hz_parties,hz_cust_accounts where hz_parties.party_id = hz_cust_accounts.party_id) cust, -- bug 3902175
        ar_lookups            l_cat,
        ar_distributions          d,
        xla_ae_headers        xah
    WHERE   crh.gl_date             BETWEEN p_Report.GlDateFrom
                                    AND p_Report.GLDateTo
        AND     crh.postable_flag             			= 'Y'
        AND     cr.cash_receipt_id           			= crh.cash_receipt_id
        AND 	  cust.customer_id(+) 				    = cr.pay_from_customer       -- bug 3902175
        AND     l_cat.lookup_type         				= 'ARRGTA_FUNCTION_MAPPING'
        AND     l_cat.lookup_code         = decode( cr.type,
                                               'MISC', 'MISC_',
                                               'TRADE_')||'CASH'
        AND     cr.currency_code           = DECODE( p_Report.Currency,
                                              null,cr.currency_code,
                                              p_Report.Currency)
        AND ( ( p_Report.Trade = 'Y'  AND cr.type = 'CASH' )
           OR
            ( p_Report.Misc = 'Y'  AND cr.type = 'MISC' ) )
/*        AND     ( igicrh.arc_posting_control_id = DECODE( p_Report.PostedStatus,
                        'BOTH', igicrh.arc_posting_control_id,
                        'UNPOSTED', -3,
                        -8888 )
        OR
              igicrh.arc_posting_control_id    <> decode( p_Report.PostedStatus,
                            'BOTH', -8888,
                            'POSTED', -3,
                            igicrh.arc_posting_control_id))
*/
        AND     (
                (crh.posting_control_id > 0 AND p_Report.CallingMode = 'CBR') OR
                (p_Report.CallingMode = 'ARC')
              )
/*        AND     NVL(igicrh.arc_gl_posted_date,to_date('01-01-1952','DD-MM-YYYY'))
             BETWEEN
                    DECODE( p_Report.PostedStatus,
                'BOTH', nvl(igicrh.arc_gl_posted_date,to_date('01-01-1952',
                                    'DD-MM-YYYY')),
                'UNPOSTED',nvl(igicrh.arc_gl_posted_date,to_date('01-01-1952',
                                  'DD-MM-YYYY')),
                'POSTED', decode( p_Report.PostedDateFrom ,
                        null, nvl(igicrh.arc_gl_posted_date,to_date('01-01-1952',
                                  'DD-MM-YYYY')),
                                    p_Report.PostedDateFrom))
                AND
                    DECODE( p_Report.PostedStatus,
                'BOTH', nvl(igicrh.arc_gl_posted_date,to_date('01-01-1952',
                                    'DD-MM-YYYY')),
                'UNPOSTED',nvl(igicrh.arc_gl_posted_date,to_date('01-01-1952',
                                  'DD-MM-YYYY')),
                'POSTED', decode( p_Report.PostedDateTo,
                        null, nvl(igicrh.arc_gl_posted_date,to_date('01-01-1952',
                                  'DD-MM-YYYY')),
                                    p_Report.PostedDateTo))
*/
        AND crh.cash_receipt_history_id = d.source_id
        AND d.source_table = 'CRH'
        AND crh.cash_receipt_history_id = igicrh.cash_receipt_history_id
        AND crh.cash_receipt_history_id+0 < p_Report.NxtCashReceiptHistoryId
        AND xah.event_id = crh.event_id
        AND xah.application_id = l_xah_ar_application_id
        AND xah.ledger_id = p_Report.CashSetOfBooksId
        AND xah.accounting_date between p_Report.GlDateFrom and p_Report.GlDateTo
        AND xah.gl_transfer_status_code = 'Y'
        AND xah.gl_transfer_date between p_Report.PostedDateFrom and p_Report.PostedDateTo;

--
        RCrh  CCrh%ROWTYPE;
    l_Count         NUMBER  :=0;
--
        PROCEDURE InsertIntoAR( RCrh IN CCrh%ROWTYPE ) IS
        BEGIN

        INSERT INTO
        igi_ar_journal_interim
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
        reference30
        )
                VALUES
                (
                'NEW',                        -- status
                'A',                          -- actual flag
        p_Report.ReqId,            -- request_id
                p_Report.CreatedBy,             -- created_by
                TRUNC( SYSDATE ),             -- date_created
                p_Report.CashSetOfBooksId,          -- set_of_books_id
                'Receivables',            -- user_je_source_name
                RCrh.Category,                     -- user_je_category_name
        RCrh.TrxDate,              -- trx_date
                RCrh.GlDate,                       -- accounting_date
                RCrh.CurrencyCode,                 -- currency_code
                RCrh.AccountCodeCombinationId,     -- code_combination_id
                DECODE
                (
                    SIGN( RCrh.Amount ),
                    -1, NULL,
                    RCrh.Amount
                ),                                 -- entered_dr
                DECODE
                (
                    SIGN( RCrh.Amount ),
                    -1, -RCrh.Amount,
                    NULL
                ),                                 -- entered_cr
                DECODE
                (
                    SIGN( RCrh.AcctdAmount ),
                    -1, NULL,
                    RCrh.AcctdAmount
                ),                                 -- accounted_dr
                DECODE
                (
                    SIGN( RCrh.AcctdAmount ),
                    -1, -RCrh.AcctdAmount,
                    NULL
                ),                                 -- accounted_cr
                RCrh.CatMeaning,                   -- reference10
                p_Report.ReqId,                    -- reference21
                RCrh.CashReceiptId,                -- reference22
                RCrh.CashReceiptHistoryId,         -- reference23
                RCrh.ReceiptNumber,                -- reference24
        NULL,                  -- reference25
                RCrh.CustomerNumber,               -- reference26
                RCrh.PayFromCustomer,              -- reference27
                RCrh.ModifiedType,                 -- reference28
                RCrh.ModifiedType||'_'||RCrh.SourceType, -- reference29
                'AR_CASH_RECEIPT_HISTORY'          -- reference30
            );
        EXCEPTION
            WHEN OTHERS THEN
                WriteToLogFile( l_excep_level,'ReportCashReceiptHistory','InsertIntoAR:' );
                RAISE;
        END;
--
-- This is the actual ReportCashReceiptHistory body
--
    BEGIN
        WriteToLogFile(l_state_level,'ReportCashReceiptHistory', ' ' );
        WriteToLogFile(l_state_level,'ReportCashReceiptHistory', '      AR_CASH_RECEIPT_HISTORY...' );
        OPEN CCrh;
        LOOP
            FETCH CCrh
            INTO  RCrh;
            EXIT WHEN CCrh%NOTFOUND;
            InsertIntoAR( RCrh );
        l_Count := l_Count + 1;
        END LOOP;
        CLOSE CCrh;
        WriteToLogFile(l_state_level,'ReportCashReceiptHistory', '         '||l_Count||' lines selected' );
--
    EXCEPTION
        WHEN OTHERS THEN
            WriteToLogFile(l_excep_level,'ReportCashReceiptHistory', 'ReportCashReceiptHistory:' );
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
 |    12-Apr-1994  D Chu        Created                                  |
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
                mcd.gl_date                          gl_date,
                mcd.apply_date                       trx_date,
                cr.currency_code                     currency_code,
                'Misc Receipts'                      category,
                l_cat.meaning                        CatMeaning
        FROM    ar_misc_cash_distributions    mcd,
                igi_ar_misc_cash_dists        igimcd,
                ar_cash_receipts              cr,
                ar_lookups                    l_cat,
                xla_ae_headers                xah
        WHERE   mcd.gl_date             BETWEEN p_Report.GlDateFrom AND p_Report.GLDateTo
        AND     cr.cash_receipt_id              = mcd.cash_receipt_id
        AND     mcd.misc_cash_distribution_id   = igimcd.misc_cash_distribution_id
        AND     l_cat.lookup_type          = 'ARRGTA_FUNCTION_MAPPING'
        AND     l_cat.lookup_code          = 'MISC_MISC'
        AND     cr.currency_code           = DECODE( p_Report.Currency,
                                null,cr.currency_code,
                                p_Report.Currency)
        AND     p_Report.Misc               = 'Y'
/*        AND     ( igimcd.arc_posting_control_id            = DECODE( p_Report.PostedStatus,
                                'BOTH', igimcd.arc_posting_control_id,
                                'UNPOSTED', -3,
                                -8888 )
        OR
              igimcd.arc_posting_control_id       <> decode( p_Report.PostedStatus,
                                'BOTH', -8888,
                                'POSTED', -3,
                                igimcd.arc_posting_control_id) )
*/
        AND     (
                (mcd.posting_control_id > 0 AND p_Report.CallingMode = 'CBR') OR
                (p_Report.CallingMode = 'ARC')
              )
/*        AND     NVL(igimcd.arc_gl_posted_date,to_date('01-01-1952','DD-MM-YYYY'))
             BETWEEN
                    DECODE( p_Report.PostedStatus,
                'BOTH', nvl(igimcd.arc_gl_posted_date,to_date('01-01-1952',
                                    'DD-MM-YYYY')),
                'UNPOSTED',nvl(igimcd.arc_gl_posted_date,to_date('01-01-1952',
                                  'DD-MM-YYYY')),
                'POSTED', decode( p_Report.PostedDateFrom ,
                        null, nvl(igimcd.arc_gl_posted_date,to_date('01-01-1952',
                                  'DD-MM-YYYY')),
                                    p_Report.PostedDateFrom))
                AND
                    DECODE( p_Report.PostedStatus,
                'BOTH', nvl(igimcd.arc_gl_posted_date,to_date('01-01-1952',
                                    'DD-MM-YYYY')),
                'UNPOSTED',nvl(igimcd.arc_gl_posted_date,to_date('01-01-1952',
                                  'DD-MM-YYYY')),
                'POSTED', decode( p_Report.PostedDateTo,
                        null, nvl(igimcd.arc_gl_posted_date,to_date('01-01-1952',
                                  'DD-MM-YYYY')),
                                    p_Report.PostedDateTo))
*/
        AND     mcd.misc_cash_distribution_id+0 < p_Report.NxtMiscCashDistributionId
        AND     xah.event_id = mcd.event_id
        AND     xah.application_id = l_xah_ar_application_id
        AND     xah.ledger_id = p_Report.CashSetOfBooksId
        AND     xah.accounting_date between p_Report.GlDateFrom and p_Report.GlDateTo
        AND     xah.gl_transfer_status_code = 'Y'
        AND     xah.gl_transfer_date between p_Report.PostedDateFrom and p_Report.PostedDateTo;
--
    l_Count         NUMBER  :=0;
    BEGIN
        WriteToLogFile(l_state_level,'ReportMiscCashDistributions', ' ' );
        WriteToLogFile( l_state_level,'ReportMiscCashDistributions','      AR_MISC_CASH_DISTRIBUTIONS...' );
        FOR RMcd IN CMcd
        LOOP

        INSERT INTO
        igi_ar_journal_interim
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
        reference28,
        reference29,
        reference30
        )
                VALUES
                (
                'NEW',                        -- status
                'A',                          -- actual flag
                p_Report.ReqId,            -- request_id
                p_Report.CreatedBy,             -- created_by
                TRUNC( SYSDATE ),             -- date_created
                p_Report.CashSetOfBooksId,          -- set_of_books_id
                'Receivables',            -- user_je_source_name
                RMcd.category,                     -- user_je_category_name
                RMcd.trx_date,                      -- trx_date
                RMcd.gl_date,                      -- accounting_date
                RMcd.currency_code,                -- currency_code
                RMcd.code_combination_id,          -- code_combination_id
                DECODE
                (
                    SIGN( RMcd.amount ),
                    -1, -RMcd.amount,
                    NULL
                ),                                 -- entered_dr
                DECODE
                (
                    SIGN( RMcd.amount ),
                    -1, NULL,
                    RMcd.amount
                ),                                 -- entered_cr
                DECODE
                (
                    SIGN( RMcd.acctd_amount ),
                    -1, -RMcd.acctd_amount,
                    NULL
                ),                                 -- accounted_dr
                DECODE
                (
                    SIGN( RMcd.acctd_amount ),
                    -1, NULL,
                    RMcd.acctd_amount
                ),                                 -- accounted_cr
                RMcd.CatMeaning,           -- reference10
                p_Report.ReqId,                    -- reference21
                RMcd.CashReceiptId,                -- reference22
                RMcd.MiscCashDistributionId,       -- reference23
                RMcd.ReceiptNumber,                -- reference24
                'MISC',                            -- reference28
                'MISC_MISC',                       -- reference29
                'AR_MISC_CASH_DISTRIBUTIONS'       -- reference30
            );
--
        l_Count := l_Count + 1;
        END LOOP;
        WriteToLogFile( l_state_level,'ReportMiscCashDistributions','         '||l_Count||' lines selected' );
    EXCEPTION
        WHEN OTHERS THEN
            WriteToLogFile(l_excep_level,'ReportMiscCashDistributions', 'ReportMiscCashDistributions:' );
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
        DELETE  FROM igi_ar_journal_interim
        WHERE   reference22          = p_BalanceId
         AND    reference28          = p_CategoryCode
         AND    set_of_books_id      = p_Report.CashSetOfBooksId
         AND    request_id           = p_Report.ReqId;

--
    EXCEPTION
        WHEN OTHERS THEN
            WriteToLogFile(l_excep_level,'ClearOOB', 'ClearOOB' );
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
 |      Checks that the records inserted into igi_ar_journal_interim balance for each  |
 |        BalanceId (reference22).                                           |
 |      Any BalanceId that fails to balance will be reported on              |
 |        (via WriteToLogFile), and will be deleted with ClearOOB  |
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
        FROM    igi_ar_journal_interim  i
        WHERE   i.request_id              = p_Report.ReqId
    AND     i.set_of_books_id     = p_Report.CashSetOfBooksId
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
        FROM    igi_ar_journal_interim                   i
        WHERE   i.request_id              = p_Report.ReqId
    AND     i.set_of_books_id           = p_Report.CashSetOfBooksId
        AND     i.reference22           = p_BalanceId
    AND     i.reference28       = p_CategoryCode
        ORDER BY i.reference30,
                 i.reference23;
--
        l_ReceivableApplicationId      ar_receivable_applications.receivable_application_id%TYPE;
    BEGIN
--
        WriteToOutFile( '   ----------------------------------------------------' );
        WriteToOutFile( '   Checking DR/CR balance...' );
        WriteToOutFile( '' );
--
        FOR RBal IN CBal
        LOOP
            WriteToOutFile( 'Out Of balance:'||Rbal.CurrencyCode||' BalanceId:'||RBal.BalanceId );
            FOR RInt IN CInt( RBal.BalanceId, Rbal.CategoryCode )
            LOOP
                IF RInt.TableName = 'AR_CASH_BASIS_DISTRIBUTIONS'
                THEN
                    SELECT  cbd.receivable_application_id
                    INTO    l_ReceivableApplicationId
                    FROM    igi_ar_cash_basis_dists    cbd
                    WHERE   cbd.cash_basis_distribution_id = RInt.Id;
                ELSE
                    l_ReceivableApplicationId := NULL;
                END IF;
                WriteToOutFile( RPAD( Rint.TableName, 30)||
                                          RPAD( RInt.Id, 15 )||
                                          LPAD( NVL(TO_CHAR(RInt.EnteredDr), ' '),15)||
                                          LPAD( NVL(TO_CHAR(RInt.EnteredCr), ' '),15)||
                                          LPAD( NVL(TO_CHAR(RInt.AccountedDr), ' '),15)||
                                          LPAD( NVL(TO_CHAR(RInt.AccountedCr), ' '),15)||
                                          '    '||l_ReceivableApplicationId );
            END LOOP;
            WriteToOutFile( RPAD( 'SUM:', 30)||
                                      RPAD( ' ', 15 )||
                                      LPAD( NVL(TO_CHAR(RBal.SumEnteredDr), ' '),15)||
                                      LPAD( NVL(TO_CHAR(RBal.SumEnteredCr), ' '),15)||
                                      LPAD( NVL(TO_CHAR(RBal.SumAccountedDr), ' '),15)||
                                      LPAD( NVL(TO_CHAR(RBal.SumAccountedCr), ' '),15) );
            WriteToOutFile( '--------------------------------------------------------------------------------------------------------------------' );
            -- ClearOOB( p_Report, RBal.BalanceId, RBal.CategoryCode );
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            WriteToLogFile( l_excep_level,'CheckBalance','CheckBalance:' );
            RAISE;
    END;
--
--
--  Delete from igi_ar_cash_basis_dists for records inserted
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      DeleteFromCBD                                                        |
 |  DESCRIPTION                                                              |
 |   Delete recrods from igi_ar_cash_basis_dists inserted this run       |
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
        DELETE  FROM igi_ar_cash_basis_dists
        WHERE   posting_control_id   = - ( p_Report.ReqId +1000 );
--
    EXCEPTION
        WHEN OTHERS THEN
            WriteToLogFile( l_excep_level,'DeleteFromCBD','DeleteFromCBD' );
            RAISE;
    END DeleteFromCBD;
--
--
   PROCEDURE  CheckUpgradedCustomer(p_FromRel9 OUT NOCOPY VARCHAR2) IS
    l_ColumnId  NUMBER  :=0;
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
            WriteToLogFile( l_excep_level,'DeleteFromCBD','CheckUpgradedCustomer:' );
            RAISE;
   END;

--
--
    PROCEDURE Report( p_Report       IN ReportParametersType ) IS
    l_FromRel9      VARCHAR2(1);
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

                WriteToLogFile ( l_state_level,'DeleteFromCBD','  >> Report Cash Receipt History Data ');
                BEGIN
                  ReportCashReceiptHistory( p_Report );
                EXCEPTION WHEN OTHERS THEN NULL;
                END;
        END IF;
--
        IF p_Report.Misc = 'Y'
        THEN
                WriteToLogFile (l_state_level,'DeleteFromCBD', '  >> Report MIsc Cash Distributions Data ');
                BEGIN
                ReportMiscCashDistributions( p_Report );
                EXCEPTION WHEN OTHERS THEN NULL;
                END;
        END IF;
--
        IF p_Report.Trade = 'Y' OR
                   p_Report.Ccurr = 'Y'
        THEN
                WriteToLogFile (l_state_level,'DeleteFromCBD', '  >> Report Non Dist Applications Data ');
                BEGIN
                ReportNonDistApplications( p_Report );
                EXCEPTION WHEN OTHERS THEN NULL;
                END;
        END IF;
--
        IF p_Report.Trade = 'Y' OR
                   p_Report.Ccurr = 'Y' OR
           p_Report.CMApp = 'Y'
        THEN
               WriteToLogFile ( l_state_level,'DeleteFromCBD','  >> Report Distributed Applications Data ');
                BEGIN
                ReportDistributedApplications( p_Report );
                EXCEPTION WHEN OTHERS THEN NULL;
                END;

        END IF;
--
        IF p_Report.ChkBalance = 'Y' AND
           p_Report.PostedStatus <> 'POSTED'
        THEN
                WriteToLogFile (l_state_level,'DeleteFromCBD', '  >> Check the Balance ');
                CheckBalance( p_Report );
        END IF;
        WriteToLogFile (l_state_level,'DeleteFromCBD', '  >> Delete from Cash Basis Distributions ');
        DeleteFromCBD( p_Report );
    END IF;
     END IF;
    EXCEPTION
        WHEN OTHERS THEN
            WriteToLogFile(l_excep_level,'DeleteFromCBD', 'Exception:IGIRCBJO.Report( p_Report ):'||sqlerrm );
	    IF ( l_unexp_level >= l_debug_level ) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,l_path || 'DeleteFromCBD', TRUE);
            END IF;
            RAISE_APPLICATION_ERROR( -20000, sqlerrm||'$Revision: 120.7.12000000.3 $:Report( p_Report ):' );
    END;
--
FUNCTION SubmitJEUKPGLR
		( p_Report IN ReportParametersType
		, p_ReportName		VARCHAR2
		) RETURN NUMBER IS
l_RequestId	NUMBER(15);
l_yes varchar2(1);
NOT_SUBMITTED	EXCEPTION;
BEGIN
-- bug 3902175 GSCC Warnings Fixed
l_yes  := 'Y';
	l_RequestId := FND_REQUEST.SUBMIT_REQUEST
		( 'IGI'
		, 'IGIRCBJO'
		, null
		, null
 		, TRUE			-- Is a sub request
		, 'P_COAID='||p_Report.ChartOfAccountsId
		, 'P_LAYOUT_DESCRIPTION='||p_ReportName
		, 'P_REQUEST_ID='||p_Report.ReqId
		, 'P_SOB_ID='||p_Report.CashSetOfBooksId
		, 'P_BAL_LOW='||p_Report.CompanySegmentFrom
		, 'P_BAL_HIGH='||p_Report.CompanySegmentTo
		, 'P_ACNT_LOW='||p_Report.AccountSegmentFrom
		, 'P_ACNT_HIGH='||p_Report.AccountSegmentTo
		, 'P_POSTED_LOW='||to_char(p_Report.PostedDateFrom,'YYYY/MM/DD HH24:MI:SS')
		, 'P_POSTED_HIGH='||to_char(p_Report.PostedDateTo,'YYYY/MM/DD HH24:MI:SS')
      , 'P_INV='||l_yes
      , 'P_CM='||l_yes
      , 'P_CB='||l_yes
      , 'P_DM='||l_yes
		, 'P_CMAPP='||p_Report.CMApp
		, 'P_ADJ='||p_Report.Adj
		, 'P_TRADE='||p_Report.Trade
		, 'P_MISC='||p_Report.Misc
      , 'P_CCURR='||p_Report.CCurr
		, 'P_POSTED_FLAG='||p_Report.PostedStatus
		, 'P_LOW_DATE='||to_char(p_Report.GlDateFrom,'YYYY/MM/DD HH24:MI:SS')
		, 'P_HIGH_DATE='||to_char(p_Report.GlDateTo,'YYYY/MM/DD HH24:MI:SS')
		, 'P_CURRENCY_CODE='||p_Report.Currency
		);
	if l_RequestId = 0 THEN
	RAISE NOT_SUBMITTED;
	end if;
	commit;
	RETURN (l_RequestId);
    EXCEPTION
        WHEN NOT_SUBMITTED THEN
            WriteToLogFile( l_excep_level,'SubmitJEUKPGLR','Error Submitting IGIRCBJO' );
            WriteToLogFile( l_excep_level,'SubmitJEUKPGLR','Exception:IGIRCBJO.SubmitJEUKPGLR( p_Report ): Error submitting Concurrent Request for JEUKPGLR' );
            RAISE;
	RETURN (l_RequestId);
        WHEN OTHERS THEN
            WriteToLogFile( l_excep_level,'SubmitJEUKPGLR','Exception:IGIRCBJO.SubmitJEUKPGLR( p_Report ):'||sqlerrm );
            WriteToLogFile( l_excep_level,'SubmitJEUKPGLR','Error Submitting IGIRCBJO' );
            RAISE;
	RETURN (l_RequestId);
end;

--
PROCEDURE ReportOutput
		( p_Report IN ReportParametersType
		) IS
l_DetAccRequestId	NUMBER(15);
l_SumAccRequestId	NUMBER(15);
l_DetCatRequestId	NUMBER(15);
l_SumCatRequestId	NUMBER(15);
l_wait		BOOLEAN;
l_phase		varchar2(20);
l_status		varchar2(20);
l_dev_phase		varchar2(20);
l_dev_status		varchar2(20);
l_message		varchar2(240);
begin
--
-- First Submit the required concurrent requests
--
	if p_Report.DetailByAccount = 'Y' THEN
		l_DetAccRequestId := SubmitJEUKPGLR
			( p_report, 'Detail By Account' );
	end if;
	if p_Report.DetailByCategory = 'Y' THEN
		l_DetCatRequestId := SubmitJEUKPGLR
			( p_report, 'Detail By Category' );
	end if;
	if p_Report.SummaryByAccount = 'Y' THEN
		l_SumAccRequestId := SubmitJEUKPGLR
			( p_report, 'Summary By Account' );
	end if;
	if p_Report.SummaryByCategory = 'Y' THEN
		l_SumCatRequestId := SubmitJEUKPGLR
			( p_report, 'Summary By Category' );
	end if;
--
-- If any requests have been submitted, update the parent.
--
	if nvl(l_DetAccRequestId, 0) > 0
	OR nvl(l_DetCatRequestId, 0) > 0
	OR nvl(l_SumAccRequestId, 0) > 0
	OR nvl(l_SumCatRequestId, 0) > 0 THEN
		UPDATE fnd_concurrent_requests
		   SET has_sub_request = 'Y'
--		     , status_code = 'W'-- This does not work!  The parent
					-- request restarts ad infinitum if
					-- status_code set to 'W' (Paused).
		 WHERE request_id = p_Report.ReqId;
	end if;
--
-- Update each child in turn, waiting for each to complete.
--
	if nvl(l_DetAccRequestId, 0) > 0 THEN
		UPDATE fnd_concurrent_requests
		   SET status_code = 'I'
		 WHERE request_id = l_DetAccRequestId
		   AND status_code = 'Z';
		commit;
		l_wait := fnd_concurrent.wait_for_request
			( l_DetAccRequestId
			, 30
			, 0
			, l_phase
			, l_status
			, l_dev_phase
			, l_dev_status
			, l_message
			);
	end if;
--
	if nvl(l_DetCatRequestId, 0) > 0 THEN
		UPDATE fnd_concurrent_requests
		   SET status_code = 'I'
		 WHERE request_id = l_DetCatRequestId
		   AND status_code = 'Z';
		commit;
		l_wait := fnd_concurrent.wait_for_request
			( l_DetCatRequestId
			, 30
			, 0
			, l_phase
			, l_status
			, l_dev_phase
			, l_dev_status
			, l_message
			);
	end if;
--
	if nvl(l_SumAccRequestId, 0) > 0 THEN
		UPDATE fnd_concurrent_requests
		   SET status_code = 'I'
		 WHERE request_id = l_SumAccRequestId
		   AND status_code = 'Z';
		commit;
		l_wait := fnd_concurrent.wait_for_request
			( l_SumAccRequestId
			, 30
			, 0
			, l_phase
			, l_status
			, l_dev_phase
			, l_dev_status
			, l_message
			);
	end if;
--
	if nvl(l_SumCatRequestId, 0) > 0 THEN
		UPDATE fnd_concurrent_requests
		   SET status_code = 'I'
		 WHERE request_id = l_SumCatRequestId
		   AND status_code = 'Z';
		commit;
		l_wait := fnd_concurrent.wait_for_request
			( l_SumCatRequestId
			, 30
			, 0
			, l_phase
			, l_status
			, l_dev_phase
			, l_dev_status
			, l_message
			);
	end if;

	DELETE igi_ar_journal_interim
    WHERE request_id = p_Report.ReqId;

	commit;
    EXCEPTION
        WHEN OTHERS THEN
            WriteToLogFile(l_excep_level,'ReportOutput', 'Error Submitting Output Reports' );
            RAISE;
end;
--
    PROCEDURE Report
		( errbuf		OUT NOCOPY	VARCHAR2
		, retcode		OUT NOCOPY	NUMBER
		, p_DetailByAccount		VARCHAR2
		, p_DetailByCategory		VARCHAR2
		, p_SummaryByAccount		VARCHAR2
		, p_SummaryByCategory		VARCHAR2
		, p_SetOfBooksId		    NUMBER
		, p_ChartOfAccountsId       NUMBER
		, p_PostedStatus		    VARCHAR2
		, p_GlDateFrom			    VARCHAR2
		, p_GlDateTo			    VARCHAR2
		, p_PostedDateFrom		    VARCHAR2
		, p_PostedDateTo		    VARCHAR2
		, p_Currency			    VARCHAR2
		, p_CMApp			        VARCHAR2
		, p_Adj				        VARCHAR2
		, p_Trade			        VARCHAR2
		, p_Misc			        VARCHAR2
        , p_CCurr                   VARCHAR2
		, p_CompanySegmentFrom		VARCHAR2
		, p_CompanySegmentTo		VARCHAR2
		, p_AccountSegmentFrom		VARCHAR2
		, p_AccountSegmentTo		VARCHAR2
		, p_DebugFlag			VARCHAR2
		) IS
    l_Report  ReportParametersType;
    l_ct   Number;

    FUNCTION  CountInterimJournals ( p_request_id in number ) return number
    IS
      cursor c_e is
        select count(*) ct
        from   igi_ar_journal_interim
        where  request_id = p_request_id
        ;
    BEGIN
        for l_e in c_e  loop
            return l_e.ct;
        end loop;
        return 0;
    END CountInterimJournals;

    BEGIN
--
-- Variables set by parameters passed through from post procedure
--
        l_Report.GlDateFrom := to_date(p_GlDateFrom,'YYYY/MM/DD HH24:MI:SS');
        l_Report.GlDateTo := to_date(p_GlDateTo,'YYYY/MM/DD HH24:MI:SS');
        l_Report.SetOfBooksId := p_SetOfBooksId;
        l_Report.Currency := p_Currency;
	     l_Report.CMApp := p_CMApp;
	     l_Report.Adj := p_Adj;
        l_Report.Trade := p_Trade;
	     l_Report.Misc := p_Misc;
        l_Report.CCurr := p_CCurr;
        l_Report.PostedStatus := p_PostedStatus;
        l_Report.PostedDateFrom := to_date(p_PostedDateFrom,'YYYY/MM/DD HH24:MI:SS');
        l_Report.PostedDateTo := to_date(p_PostedDateTo,'YYYY/MM/DD HH24:MI:SS');
--
	l_Report.DetailByAccount	:= p_DetailByAccount;
	l_Report.DetailByCategory	:= p_DetailByCategory;
	l_Report.SummaryByAccount	:= p_SummaryByAccount;
	l_Report.SummaryByCategory	:= p_SummaryByCategory;
	l_Report.ChartOfAccountsID	:= p_ChartOfAccountsID;
	l_Report.CompanySegmentFrom	:= p_CompanySegmentFrom;
	l_Report.CompanySegmentTo	:= p_CompanySegmentTo;
	l_Report.AccountSegmentFrom	:= p_AccountSegmentFrom;
	l_Report.AccountSegmentTo	:= p_AccountSegmentTo;
--
-- Get the report request ID
--
        FND_PROFILE.GET ('CONC_REQUEST_ID', l_report.ReqId);
   if l_report.ReqId IS NULL	-- Not run through conc manager
   THEN l_report.ReqId := 0;
   end if;

   WriteToLogFile(l_state_level,'Report',' ConcRequestID '|| l_Report.ReqID );
--
-- Variables set from ar_system_parameters
--
        SELECT sp.arc_cash_sob_id
	     , sob.currency_code
             , sp.arc_unalloc_rev_ccid
          INTO l_Report.CashSetOfBooksId
	     , l_Report.FuncCurr
	     , l_Report.UnallocatedRevCcid
          FROM igi_ar_system_options sp
             , gl_sets_of_books sob
         WHERE sp.set_of_books_id = p_SetOfBooksID
           AND sob.set_of_books_id = sp.set_of_books_id;

           if l_Report.CashSetOfBooksId is null then
              WriteToLogFile ( l_state_level,'Report','Accrual Set Of books '|| p_SetOfBooksID );
              WriteToLogFile ( l_event_level,'Report','Unable to get the Cash Set of Books ID information');
              return;
           end if;
--
-- Set Max IDs
--
	SELECT ar_cash_receipt_history_s.nextval
		, ar_receivable_applications_s.nextval
		, ar_misc_cash_distributions_s.nextval
		, ar_adjustments_s.nextval
		, ra_cust_trx_line_gl_dist_s.nextval
	  INTO 	  l_Report.NxtCashReceiptHistoryId
		, l_Report.NxtReceivableApplicationId
		, l_Report.NxtMiscCashDistributionId
		, l_Report.NxtAdjustmentId
		, l_Report.NxtCustTrxLineGlDistId
	  FROM dual;
--
WriteToLogFile(l_state_level,'Report',' ----------------BEGIN PARAMETERS-----------------------------------');
WriteToLogFile(l_state_level,'Report',' NxtCashReceiptHistoryId '|| l_Report.NxtCashReceiptHistoryId );
WriteToLogFile(l_state_level,'Report',' NxtReceivableApplicationId '|| l_Report.NxtReceivableApplicationId );
WriteToLogFile(l_state_level,'Report',' NxtMiscCashDistributionId '|| l_Report.NxtMiscCashDistributionId );
WriteToLogFile(l_state_level,'Report',' NxtAdjustmentId '|| l_Report.NxtAdjustmentId );
WriteToLogFile(l_state_level,'Report',' NxtCustTrxLineGlDistId '|| l_Report.NxtCustTrxLineGlDistId );
WriteToLogFile(l_state_level,'Report',' Posted Status '||p_PostedStatus);
WriteToLogFile(l_state_level,'Report',' ----------------END PARAMETERS-----------------------------------');

--
-- Hard Coded variables
--
        l_Report.ChkBalance := 'Y';
        l_Report.CreatedBy := fnd_global.user_id;
--
--
        if p_PostedStatus <> 'POSTED' THEN
            WriteToLogFile ( l_state_level,'Report','-----------------BEGIN IGIRCBID------------------ ');
           IGIRCBID.Prepare ( to_date(p_GlDateFrom,'YYYY/MM/DD HH24:MI:SS')
                             , to_date(P_gldateTo,'YYYY/MM/DD HH24:MI:SS')
                             , to_date(p_gldateFrom,'YYYY/MM/DD HH24:MI:SS')
                            );
           WriteToLogFile ( l_state_level,'Report','------------------END  IGIRCBID------------------- ');
        end if;

        WriteToLogFile (l_state_level,'Report', '-----------------BEGIN IGIRCBJP------------------ ');
        WriteToLogFile ( l_event_level,'Report','BEGIN  insert (data) into AR_JOURNAL_INTERIM ');
        Report( l_Report );
        WriteToLogFile (l_event_level,'Report', 'END (Successful)  insert (data) into AR_JOURNAL_INTERIM ');
        WriteToLogFile ( l_state_level,'Report','-----------------END   IGIRCBJP------------------ ');

        l_ct := CountInterimJournals ( l_Report.reqid );

        WriteToLogFile (l_event_level,'Report', '>> >> PROCESSED RECORDS IN AR_JOURNAL_INTERIM >> >> '||l_ct );
--
--
        WriteToLogFile (l_state_level,'Report', '-----------------BEGIN IGIRCBJO------------------ ');
        WriteToLogFile (l_event_level,'Report', 'BEGIN  output  (data) from AR_JOURNAL_INTERIM ');
      	ReportOutput (l_Report);
        WriteToLogFile (l_event_level,'Report', 'END (Successful)  output (data) from AR_JOURNAL_INTERIM ');
        WriteToLogFile (l_state_level,'Report', '-----------------END   IGIRCBJO------------------ ');

    EXCEPTION
        WHEN OTHERS THEN
            WriteToLogFile(l_excep_level,'Report','Exception:IGIRCBJO.Report( ... ):'||sqlerrm );
        RAISE;
    END;
BEGIN
-- Bug 3902175 GSCC Warnings Fixed

    l_debug_level :=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_state_level :=	FND_LOG.LEVEL_STATEMENT;
    l_proc_level  :=	FND_LOG.LEVEL_PROCEDURE;
    l_event_level :=	FND_LOG.LEVEL_EVENT;
    l_excep_level :=	FND_LOG.LEVEL_EXCEPTION;
    l_error_level :=	FND_LOG.LEVEL_ERROR;
    l_unexp_level :=	FND_LOG.LEVEL_UNEXPECTED;
    l_path        :=      'IGI.PLSQL.igircjpb.IGIRCBJP.';

END IGIRCBJP;

/
