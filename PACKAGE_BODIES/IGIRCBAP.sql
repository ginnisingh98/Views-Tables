--------------------------------------------------------
--  DDL for Package Body IGIRCBAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIRCBAP" AS
-- $Header: igircapb.pls 115.18 2004/03/01 09:40:10 sdixit ship $

    l_debug_level NUMBER	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
    l_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
    l_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
    l_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
    l_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
    l_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
    l_path        VARCHAR2(50)  :=      'IGI.PLSQL.igircapb.IGIRCBAP.';

    l_rep_sequence number := 0;


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
        CmPsIdFlag           VARCHAR2(1),
        Class                        ar_payment_schedules.class%TYPE,
        TrxNumber                    ra_customer_trx.trx_number%TYPE
    );
    --
    -- RECORD holder for pertinent information from a receivable application
    -- of status = 'APP'
    TYPE ApplicationType IS RECORD
    (
        ReceivableApplicationId      ar_receivable_applications.receivable_application_id%TYPE,
        GLDate                       DATE,    -- the gl date of the application
        UssglTransactionCode         ar_receivable_applications.ussgl_transaction_code%TYPE,
        AppType                  ar_receivable_applications.application_type%TYPE
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
    TYPE VC30Type   IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE DateType   IS TABLE OF DATE         INDEX BY BINARY_INTEGER;
    TYPE INTEGERType IS TABLE OF BINARY_INTEGER INDEX BY BINARY_INTEGER;
    TYPE ROWIDType   IS TABLE OF ROWID          INDEX BY BINARY_INTEGER;
--
--
    ArpcbpError     EXCEPTION;
    PRAGMA EXCEPTION_INIT( ArpcbpError, -20000 );
--
-- private procedures
--
    --
    -- Write to the log file
    --

    /*PROCEDURE WritetoLog (pp_line in varchar2) IS
    BEGIN
       IF pp_line IS NULL THEN
          return;
       END IF;
       fnd_file.put_line( FND_FILE.log, 'IGIRCBAP '||pp_line );
    END;*/

    PROCEDURE WritetoLog (p_level IN NUMBER, p_path IN VARCHAR2, p_mesg IN VARCHAR2) IS
    BEGIN
       IF (p_level  >=  l_debug_level ) THEN
                  FND_LOG.STRING  (p_level ,l_path || p_path , p_mesg );
       END IF;
    END;

    PROCEDURE WritetoOut (pp_id in number, pp_post_id in number,   pp_line in varchar2) IS
    BEGIN
       IF pp_line IS NULL THEN
          return;
       END IF;

       fnd_file.put_line( FND_FILE.output, 'IGIRCBAP '||pp_line );

       l_rep_sequence := l_rep_sequence + 1;

       insert into igi_plsql_control
          ( report_run_id
          , entry_type
          , sequence
          , entry_text )
       values (  pp_id
              ,  'IGIRCBER'||pp_post_id
              ,  l_rep_sequence
              ,  pp_line );

       if sql%notfound then
          WriteToLog( l_event_level, 'WritetoOut' ,'Unable to write to the temporary table' );
       else
          WriteToLog( l_event_level, 'WritetoOut' ,'Record number '||l_rep_sequence||' is inserted into igi_plsql_control.');
       end if;

    END;

    --
    -- Procedures to write Record Types using dbms_output
    --
    PROCEDURE Output( p IN ReceiptType ) IS
    BEGIN
        WritetoLog( l_state_level, 'Output','Receipt Type' );
        WritetoLog( l_state_level, 'Output','CashReceiptId:'||p.CashReceiptId );
        WritetoLog( l_state_level, 'Output','ReceiptNumber:'||p.ReceiptNumber );
        WritetoLog( l_state_level, 'Output','DocSequenceId:'||p.DocSequenceId );
        WritetoLog( l_state_level, 'Output','DocSequenceValue:'||p.DocSequenceValue );
        WritetoLog( l_state_level, 'Output','PayFromCustomer:'||p.PayFromCustomer );
        WritetoLog( l_state_level, 'Output','CurrencyCode:'||p.CurrencyCode );
        WritetoLog( l_state_level, 'Output','ExchangeRate:'||p.ExchangeRate );
        WritetoLog( l_state_level, 'Output','' );
    END;
--
    PROCEDURE Output( p IN TrxType ) IS
    BEGIN
        WritetoLog( l_state_level, 'Output','TrxType' );
        WritetoLog( l_state_level, 'Output','CmPsIdFlag:'||p.CmPsIdFlag );
        WritetoLog( l_state_level, 'Output','PaymentScheduleId:'||p.PaymentScheduleId );
        WritetoLog( l_state_level, 'Output','Class:'||p.Class );
        WritetoLog( l_state_level, 'Output','TrxNumber:'||p.TrxNumber );
        WritetoLog( l_state_level, 'Output','' );
    END;
--
    PROCEDURE Output( p IN ApplicationType ) IS
    BEGIN
        WritetoLog( l_state_level, 'Output','ApplicationType' );
        WritetoLog( l_state_level, 'Output','ReceivableApplicationId:'||p.ReceivableApplicationId );
        WritetoLog( l_state_level, 'Output','GLDate:'||p.GLDate );
        WritetoLog( l_state_level, 'Output','UssglTransactionCode:'||p.UssglTransactionCode );
        WritetoLog( l_state_level, 'Output','AppType:'||p.AppType );
        WritetoLog( l_state_level, 'Output','' );
    END;
--
    PROCEDURE Output( p IN ApplicationAmountType ) IS
    BEGIN
        WritetoLog( l_state_level, 'Output','ApplicationAmountType' );
        WritetoLog( l_state_level, 'Output','Amount:'||p.Amount );
        WritetoLog( l_state_level, 'Output','AmountAppfrom :'||p.AmountAppFrom);
        WritetoLog( l_state_level, 'Output','AcctdAmount:'||p.AcctdAmount );
        WritetoLog( l_state_level, 'Output','LineApplied:'||p.LineApplied );
        WritetoLog( l_state_level, 'Output','TaxApplied:'||p.TaxApplied );
        WritetoLog( l_state_level, 'Output','FreightApplied:'||p.FreightApplied );
        WritetoLog( l_state_level, 'Output','ChargesApplied:'||p.ChargesApplied );
        WritetoLog( l_state_level, 'Output','' );
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
    PROCEDURE CurrentCBDApplications(
                                   p_ps_id     IN   NUMBER,
                                   p_type      IN   VARCHAR2,
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
        FROM    igi_ar_cash_basis_dists             cbd
        WHERE   cbd.payment_schedule_id = p_ps_id
        AND     cbd.type                = p_type
       --  AND     cbd.set_of_books_id     = p_sob_id
    AND     cbd.posting_control_id+0  > 0
        GROUP BY cbd.source,
                 cbd.source_id
        ORDER BY DECODE( cbd.source, 'GL', 1,
                     'ADJ',2,
                     'UNA',3 ),
                 cbd.source_id;
--
        PROCEDURE Output( p_RCa IN CCA%ROWTYPE ) IS
        BEGIN
            WritetoLog( l_state_level, 'Output','CCA%ROWTYPE' );
            WritetoLog( l_state_level, 'Output','Amount:'||p_RCa.Amount );
            WritetoLog( l_state_level, 'Output','Source:'||p_RCA.Source );
            WritetoLog( l_state_level, 'Output','SourceId:'||p_RCa.SourceId );
            WritetoLog( l_state_level, 'Output','--------------------------------' );
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
                    WritetoLog( l_excep_level, 'CurrentCBDApplications','Exception:CurrentCBDApplications.Loop:');
                    Output( Rca );
                    RAISE;
            END;
        END LOOP;
        TotalAmount := l_TotalAmount;
        NextElement := l_NextElement;
    TotalUnallocatedAmt := l_TotalUnallocatedAmt;
    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( l_excep_level, 'CurrentCBDApplications',' Exception:CurrentCBDApplications:' );
            WritetoLog( l_excep_level, 'CurrentCBDApplications','l_NextElement:'||l_NextElement );
            WritetoLog( l_excep_level, 'CurrentCBDApplications','l_TotalAmount:'||l_TotalAmount );
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
    PROCEDURE CurrentRevDistribution ( p_Post       IN     PostingParametersType,
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
        AND     ctlgd.cust_trx_line_gl_dist_id+0 < p_Post.NxtCustTrxLineGlDistId
        ORDER BY ctlgd.cust_trx_line_gl_dist_id;
--
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
        AND     a.customer_trx_id           = ct.customer_trx_id
        AND     ct.cust_trx_type_id         = ctt.cust_trx_type_id
        AND     a.adjustment_id+0 < p_Post.NxtAdjustmentId
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
                WritetoLog(l_excep_level, 'CurrentRevDistribution', 'Exception:CurrentRevDistribution.Select PS Details:' );
                RAISE;
        END;
--
        FOR GlDistRecord IN gl_dist_cursor( l_customer_trx_id, p_type ) LOOP
            IF l_FirstInstallmentFlag = 'Y' AND l_FirstInstallmentCode = 'INCLUDE' AND p_Type IN ('TAX','FREIGHT') THEN
                l_Amount := GlDistRecord.Amount;
            ELSE
                l_Amount := arpcurr.CurrRound( GlDistRecord.amount * l_term_fraction, l_currency_code );
            END IF;
            l_Amount := nvl(l_Amount,0);
            Amount( l_NextElement )    := l_Amount;
            Source( l_NextElement )    := 'GL';
            SourceId( l_NextElement )  := GlDistRecord.cust_trx_line_gl_dist_id;
            Ccid( l_NextElement )      := GlDistRecord.ccid;
            AccntClass( l_NextElement )      := GlDistRecord.accntclass;
            -- WriteToLog('Source    -> GL');
            -- WriteToLog('Source id -> '||to_char(GlDistRecord.cust_trx_line_gl_dist_id));
            -- WriteToLog('Amount    -> '||to_char(l_amount));
            l_TotalAmount              := l_TotalAmount + l_Amount;
            -- WriteToLog('Total     -> '||to_char(l_TotalAmount));
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
              Amount( l_NextElement-1) := l_Amount + l_AmountReconcile - l_TotalAmount;
              l_TotalAmount := l_AmountReconcile;
        END IF;
--
        -- next get any adjustments
        FOR AdjRecord IN adj_cursor( p_ps_id, p_type ) LOOP
            Amount( l_NextElement )      := AdjRecord.amount;
            Source( l_NextElement )      := 'ADJ';
            SourceId( l_NextElement )    := AdjRecord.adjustment_id;
            Ccid( l_NextElement )        := AdjRecord.ccid;
            AccntClass( l_NextElement )  := AdjRecord.accntclass;
            l_TotalAmount                := l_TotalAmount + AdjRecord.Amount;
            l_NextElement := l_NextElement + 1;
        END LOOP;
--
        TotalAmount := l_TotalAmount;
        NextElement := l_NextElement;
    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( l_excep_level, 'CurrentRevDistribution','Exception:CurrentRevDistribution:' );
            WritetoLog( l_excep_level, 'CurrentRevDistribution','l_customer_trx_id:'||l_customer_trx_id );
            WritetoLog( l_excep_level, 'CurrentRevDistribution','l_term_fraction:'||l_term_fraction );
            WritetoLog( l_excep_level, 'CurrentRevDistribution','l_currency_code:'||l_currency_code );
            WritetoLog( l_excep_level, 'CurrentRevDistribution','l_Amount:'||l_Amount );
            WritetoLog( l_excep_level, 'CurrentRevDistribution','l_AmountReconcile:'||l_AmountReconcile );
            WritetoLog( l_excep_level, 'CurrentRevDistribution','l_FirstInstallmentCode:'||l_FirstInstallmentCode );
            WritetoLog( l_excep_level, 'CurrentRevDistribution','l_NextElement:'||l_NextElement );
            WritetoLog( l_excep_level, 'CurrentRevDistribution','l_TotalAmount:'||l_TotalAmount );
            WritetoLog( l_excep_level, 'CurrentRevDistribution','l_FirstInstallmentFlag:'||l_FirstInstallmentFlag );
            RAISE;
    END;
--
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      CreateDistribution                                                   |
 |  DESCRIPTION                                                              |
 |      Creates a distribution by inserting a record into                    |
 |        igi_ar_cash_basis_dists, and a record into gl_interface        |
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
        CashBasisDistributionId igi_ar_cash_basis_dists.cash_basis_distribution_id%TYPE;
    BEGIN
        IF p_Amount = 0 AND p_AcctdAmount = 0 THEN
            RETURN;
        END IF;
--
        SELECT  igi_ar_cash_basis_dists_s.NEXTVAL
        INTO    CashBasisDistributionId
        FROM    dual;
--
        BEGIN
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
                gl_posted_date,
                receivable_application_id_cash
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
                NULL
            );
        EXCEPTION
            WHEN OTHERS THEN
                WritetoLog( l_excep_level, 'CreateDistribution','Exception:CreateDistribution.InsertCBD:' );
                RAISE;
        END;
--
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
                p_Post.CreatedBy,                      -- created_by,
                TRUNC( SYSDATE ),                      -- date_created,
                'NEW',                                 -- status,
                'A',                                   -- actual_flag,
                p_Post.PostingControlId,               -- group_id,
                p_Post.CashSetOfBooksId,                   -- set_of_books_id,
                p_Post.UserSource,                     -- user_je_source_name,
                decode(p_AmountAppFrom,
                null,p_Post.UserTrade,
                        p_Post.UserCcurr),              -- user_je_category_name,
                p_App.GlDate,                          -- accounting_date,
                p_Receipt.DocSequenceId,                   -- subledger_doc_sequence_id,
                p_Receipt.DocSequenceValue,                -- subledger_doc_sequence_value,
                p_App.UssglTransactionCode,            -- ussgl_transaction_code,
                p_Receipt.CurrencyCode,                -- currency_code,
                p_Ccid,                                -- code_combination_id,
                DECODE
                (
                    SIGN( p_Amount ),
                    -1, -p_Amount,
                    NULL
                ),                                     -- entered_dr,
                DECODE
                (
                    SIGN( p_Amount ),
                    -1, NULL,
                    p_Amount
                ),                                     -- entered_cr,
                DECODE
                (
                    SIGN( p_AcctdAmount ),
                    -1, -p_AcctdAmount,
                    NULL
                ),                                     -- accounted_dr,
                DECODE
                (
                    SIGN( p_AcctdAmount ),
                    -1, NULL,
                    p_AcctdAmount
                ),                                     -- accounted_cr,
                'AR '||p_Post.PostingControlId,        -- reference1,
                DECODE
                (
                    p_Post.SummaryFlag,
                    'Y', NULL,
            DECODE(
            P_App.AppType,
            'CM',
                        'CM '||p_Receipt.ReceiptNumber||p_Post.NlsAppApplied||' '||p_Trx.Class||
                        ' '||p_trx.TrxNumber,
                        p_Post.NlsPreTradeApp||' '||p_Receipt.ReceiptNumber||p_Post.NlsAppApplied||' '||p_Trx.Class||
                        ' '||p_trx.TrxNumber||p_Post.NlsPostTradeApp
               )
                ),                                     -- reference10,
                p_Post.PostingControlId,               -- reference21,
                p_Receipt.CashReceiptId,               -- reference22,
                CashBasisDistributionId,               -- reference23,
                p_Receipt.ReceiptNumber,               -- reference24,
                p_Trx.TrxNumber,                       -- reference25,
                p_Trx.Class,                           -- reference26,
                p_Receipt.PayFromCustomer,             -- reference27,
        DECODE(
            P_App.AppType,
            'CM', 'CMAPP',
            'CASH',
                             decode(p_AmountAppFrom,
                    null,'TRADE','CCURR' )),        -- reference28,
        DECODE(
            P_App.AppType,
            'CASH',
                decode(p_AmountAppFrom,
                       null,'TRADE_APP_'||p_Trx.Class||'_'||p_Source||'_'||p_Type,
                                            'CCURR_APP_'||p_Trx.Class||'_'||p_Source||'_'||p_Type),
            'CM',   DECODE(
                    p_Trx.CmPsIdFlag,
                    'Y', 'CMAPP_REC_CM_'||p_Source||'_'||p_Type,
                    'CMAPP_APP_'||p_Trx.Class||'_'||p_Source||'_'||p_Type )), -- reference29,
                'AR_CASH_BASIS_DISTRIBUTIONS'          -- reference30
            );
        EXCEPTION
            WHEN OTHERS THEN
                WritetoLog( l_excep_level, 'CreateDistribution','Exception:CreateDistribution.InsertGl:' );
                RAISE;
        END;
    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( l_excep_level, 'CreateDistribution','Exception:CreateDistribution:' );
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
       -- Bug 1829871
        MultipleAdjustmentsPresent      BOOLEAN;
        NumberOfAdjustments             NUMBER := 0;
        -- End Bug 1829871
    BEGIN
   -- WritetoLog('Attempting to distribute across revenue lines');
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
    CurrentCBDApplications( p_Trx.PaymentScheduleId,
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
                   WritetoLog(l_state_level, 'DistributeApplicationType','Entering CreateDistribution now...');
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
            WritetoLog(l_excep_level, 'DistributeApplicationType', 'Exception:DistributeApplicationType:' );
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
        -- if RunningTotalAmount doesn't equal the Amount on the application, then report on this, and
        --     treat the difference as a 'LINE' application
        --
/*
        SurplusAmount := p_AppAmount.Amount - RunningTotalAmount;
        IF SurplusAmount <> 0 THEN
            WritetoLog( l_state_level, 'DistributeLTFApplication','DistributeLTFApplication' );
            WritetoLog( l_excep_level, 'DistributeLTFApplication','LTF Charges doesn''t equal application amount for ra_id:'||p_App.ReceivableApplicationId );
            WritetoLog( l_state_level, 'DistributeLTFApplication','----------------------------------------' );
            AcctdAmount := arpcurr.ReconcileAcctdAmounts( p_Receipt.ExchangeRate,
                                           p_AppAmount.Amount,
                                           p_AppAmount.AcctdAmount,
                                           SurplusAmount,
                                           RunningTotalAmount,
                                           RunningTotalAcctdAmount );
            DistributeApplicationType( p_Post, p_Receipt, p_Trx, p_App, 'LINE', SurplusAmount, AcctdAmount, p_AppAmount.AmountAppFrom);
        END IF;
*/
--
--
    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( l_excep_level, 'DistributeLTFApplication','Exception:DistributeLTFApplication:' );
            RAISE;
    END;
--
--
-- post ar_receivable_applications that have status UNAPP, UNID, ACC
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      PostNonDistApplications                                       |
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
 *---------------------------------------------------------------------------*/

    PROCEDURE PostNonDistApplications( p_Post IN PostingParametersType  ) IS
        CURSOR CRa IS
        SELECT  ra.ROWID                               RaRowid,
                igi_ra.ROWID                           IGIRaRowid,
                cr.cash_receipt_id                     CashReceiptId,
                cr.receipt_number                      ReceiptNumber,
                cr.doc_sequence_id                     CrDocSequenceId,
                cr.doc_sequence_value                  CrDocSequenceValue,
                cr.pay_from_customer                   PayFromCustomer,
                cr.currency_code                       CurrencyCode,
                ra.receivable_application_id           ReceivableApplicationId,
                trunc(ra.gl_date)                             GlDate,
                ra.ussgl_transaction_code              UssglTransactionCode,
                ra.amount_applied              Amount,
                ra.amount_applied_from                 AmountAppFrom,
                ra.acctd_amount_applied_from           AcctdAmount,
                ra.code_combination_id                 CodeCombinationId,
                ra.status                              Status
        FROM    ar_receivable_applications    ra,
                igi_ar_rec_applications       igi_ra,
                ar_cash_receipts              cr
        WHERE   ra.receivable_application_id = igi_ra.receivable_application_id
        AND     igi_ra.arc_posting_control_id    =   p_Post.UnpostedPostingControlId
        AND     trunc(ra.gl_date)                >=  p_Post.GlDateFrom
        AND     trunc(ra.gl_date)                <=  p_Post.GlDateTo
        AND nvl(ra.postable,'Y')           = 'Y'
        AND nvl(ra.confirmed_flag,'Y')     = 'Y'
        AND     ra.status                          not in ( 'APP','ACTIVITY')
        AND     ra.application_type||''        = 'CASH'
        AND     cr.cash_receipt_id                 = ra.cash_receipt_id
        AND     ra.receivable_application_id+0     <  p_Post.NxtReceivableApplicationId
        FOR UPDATE OF igi_ra.arc_posting_control_id;
--
    l_Count         NUMBER  :=0;
    BEGIN
        WritetoLog( l_state_level, 'PostNonDistApplications',' ' );
        WritetoLog( l_state_level, 'PostNonDistApplications','      AR_RECEIVABLE_APPLICATIONS (non-app)...' );
        FOR RRa IN CRa
        LOOP
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
                    p_Post.CreatedBy,             -- created_by
                    TRUNC( SYSDATE ),             -- date_created
                    'NEW',                        -- status
                    'A',                          -- actual flag
                    p_Post.PostingControlId,      -- group_id,
                    p_Post.CashSetOfBooksId,          -- set_of_books_id
                    p_Post.UserSource,            -- user_je_source_name
                    decode(RRa.AmountAppFrom,
                        null,p_Post.UserTrade,p_Post.UserCcurr),  -- user_je_category_name
                    RRa.GlDate,                   -- accounting_date
                    RRA.CrDocSequenceId,          -- subledger_doc_sequence_id
                    RRa.CrDocSequenceValue,       -- subledger_doc_sequence_value
                    RRa.UssglTransactionCode,     -- ussgl_transaction_code
                    RRa.CurrencyCode,             -- currency_code
                    RRa.CodeCombinationId,        -- code_combination_id
                DECODE
                    (
                        SIGN( RRa.amount ),
                            -1, -RRa.amount,
                            NULL
                    ),                          -- entered_dr

                DECODE
                    (
                        SIGN( RRa.amount ),
                            -1, NULL,
                            RRa.amount
                    ),                          -- entered_cr

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
           'AR '||to_char(p_Post.PostingControlId),  -- reference1
                    DECODE
                    (
                        p_Post.SummaryFlag,
                        'Y', NULL,
                    p_Post.NlsPreTradeApp||' '||RRa.ReceiptNumber||
                            DECODE
                            (
                                RRa.Status,
                                'ACC',   p_Post.NlsAppOnAcc,
                                'UNAPP', p_Post.NlsAppUnapp,
                                'UNID',  p_Post.NlsAppUnid
                            )||p_Post.NlsPostTradeApp
                ),                                 -- reference10
                    p_Post.PostingControlId,           -- reference21
                    RRa.CashReceiptId,           -- reference22
                    RRa.ReceivableApplicationId,     -- reference23
                    RRa.ReceiptNumber,           -- reference24
                    NULL,                       -- reference25
                    NULL,                           -- reference26
                    RRa.PayFromCustomer,         -- reference27
            decode(RRa.AmountAppFrom,
                            null,'TRADE','CCURR'),  -- reference28
                    decode(RRa.AmountAppFrom,
                            null,'TRADE_APP','CCURR_APP'),      -- reference29
                    'AR_RECEIVABLE_APPLICATIONS'       -- reference30
                );
            EXCEPTION
                WHEN OTHERS THEN
                    WritetoLog(l_excep_level, 'PostNonDistApplications','Exception:PostNonDistApplications.INSERT:' );
                    WritetoLog(l_excep_level, 'PostNonDistApplications','RRa.CashReceiptId:'||RRa.CashReceiptId );
                    WritetoLog(l_excep_level, 'PostNonDistApplications','RRa.ReceiptNumber:'||RRa.ReceiptNumber );
                    WritetoLog(l_excep_level, 'PostNonDistApplications','RRa.CrDocSequenceId:'||RRa.CrDocSequenceId );
                    WritetoLog(l_excep_level, 'PostNonDistApplications','RRa.CrDocSequenceValue:'||RRa.CrDocSequenceValue );
                    WritetoLog(l_excep_level, 'PostNonDistApplications','RRa.PayFromCustomer:'||RRa.PayFromCustomer );
                    WritetoLog(l_excep_level, 'PostNonDistApplications','RRa.CurrencyCode:'||RRa.CurrencyCode );
                    WritetoLog(l_excep_level, 'PostNonDistApplications','RRa.ReceivableApplicationId:'||RRa.ReceivableApplicationId );
                    WritetoLog(l_excep_level, 'PostNonDistApplications','RRa.GlDate:'||RRa.GlDate );
                    WritetoLog(l_excep_level, 'PostNonDistApplications','RRa.UssglTransactionCode:'||RRa.UssglTransactionCode );
                    WritetoLog(l_excep_level, 'PostNonDistApplications','RRa.Amount:'||RRa.Amount );
                    WritetoLog(l_excep_level, 'PostNonDistApplications','RRa.AcctdAmount:'||RRa.AcctdAmount );
                    WritetoLog(l_excep_level, 'PostNonDistApplications','RRa.CodeCombinationId:'||RRa.CodeCombinationId );
                    WritetoLog(l_excep_level, 'PostNonDistApplications','RRa.Status:'||RRa.Status );
                    RAISE;
            END;
--
        UPDATE igi_ar_rec_applications
           SET  arc_posting_control_id = p_Post.PostingControlId,
                arc_gl_posted_date     = p_Post.GlPostedDate
         WHERE  rowid = RRa.IGIRaRowid;

         l_Count := l_Count + 1;
        END LOOP;
        WritetoLog( l_event_level, 'PostNonDistApplications','         '||l_Count||' lines posted' );
    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( l_excep_level, 'PostNonDistApplications','Exception:PostNonDistApplications:' );
            RAISE;
    END;
--
/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |      PostDistributedApplications                                          |
 |                                                                           |
 |  DESCRIPTION                                                              |
 |      post unposted ar_receivable_applications records             |
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
 *---------------------------------------------------------------------------*/
    PROCEDURE PostDistributedApplications( p_Post IN PostingParametersType  ) IS
        CURSOR CRa IS
        SELECT  ra.ROWID                               ra_rowid,
                igira.ROWID                            igira_rowid,
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
                trunc(ra.gl_date)                             GlDate,
                ra.ussgl_transaction_code              UssglTransactionCode,
        ra.application_type                    AppType,
        DECODE(
            l.lookup_code,
            '1', ra.amount_applied,
            '2', -ra.amount_applied
            )                  Amount,
                DECODE(
            ra.application_type,
                         'CM',null,
                         'CASH',ra.amount_applied_from
            )                              AmountAppFrom,

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
            )                  ChargesApplied
        FROM    ar_receivable_applications    ra,
                igi_ar_rec_applications       igira,
                ra_cust_trx_types             ctt,
                ra_customer_trx               ct,
                ar_cash_receipts              cr,
                ar_cash_receipt_history       crh,
        ra_customer_trx               ctcm,
        ar_lookups            l
        WHERE   igira.arc_posting_control_id    = p_Post.UnpostedPostingControlId
        AND     igira.receivable_application_id = ra.receivable_application_id
        AND     trunc(ra.gl_date)         >=  p_Post.GlDateFrom
        AND     trunc(ra.gl_date)         <=  p_Post.GlDateTo
        AND     nvl(ra.postable,'Y')           = 'Y'
        AND     nvl(ra.confirmed_flag,'Y')     = 'Y'
        AND     ra.status||''                  in ( 'APP','ACTIVITY')
        AND     ra.cash_receipt_id         = cr.cash_receipt_id(+)
        AND ra.cash_receipt_history_id     = crh.cash_receipt_history_id(+)
        AND     ra.customer_trx_id         = ctcm.customer_trx_id(+)
        AND ctcm.previous_customer_trx_id      IS NULL
        AND     ra.applied_customer_trx_id     = ct.customer_trx_id
        AND     ct.cust_trx_type_id            = ctt.cust_trx_type_id
        AND l.lookup_type              = 'AR_CARTESIAN_JOIN'
        AND     (
                ( l.lookup_code ='1' )
                OR
                ( l.lookup_code = '2'
                      AND
                      ra.application_type = 'CM' )
            )
        AND     ra.receivable_application_id+0     <  p_Post.NxtReceivableApplicationId
    ORDER BY ra.receivable_application_id, l.lookup_code
        FOR UPDATE OF igira.arc_posting_control_id;
--
        l_Rowid                 ROWID;
        l_IGIRowid              ROWID;
        l_Receipt               ReceiptType;
        l_Trx                   TrxType;
        l_App                   ApplicationType;
        l_AppAmount             ApplicationAmountType;
    l_Count         NUMBER  :=0;

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
        WritetoLog( l_state_level, 'PostDistributedApplications',' ' );
        WritetoLog( l_state_level, 'PostDistributedApplications','      AR_RECEIVABLE_APPLICATION (app)...' );
        OPEN CRa;
        LOOP
            FETCH   CRa
            INTO    l_rowid,
                    l_IGIrowid,
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
                    l_AppAmount.ChargesApplied;
            EXIT WHEN CRa%NOTFOUND;
--
-- In the previous releases of OPSF. A Payment Schedule could be deleted
-- even when there exists applications linked to the payment schedule.
-- This may result in an error while distribution of LTF amounts.
-- So check and ensure dangling references are sorted out NOCOPY here.
--
         IF  ExistsINPaymentSchedules (l_trx.PaymentScheduleId ) THEN

            IF (l_Trx.Class = 'CM') OR (l_Trx.CmPsIdFlag = 'Y')
            THEN
               DistributeApplicationType( p_Post, l_Receipt, l_Trx, l_App, 'INVOICE',
                                          l_AppAmount.Amount, l_AppAmount.AcctdAmount,
                                                            null );
            ELSE
               DistributeLTFApplication( p_Post, l_Receipt, l_Trx, l_App, l_AppAmount );
            END IF;
--
            IF l_Trx.CmPsIdFlag <> 'Y'
            THEN
--
                UPDATE igi_ar_rec_applications
                SET    arc_posting_control_id = p_Post.PostingControlId,
                       arc_gl_posted_date     = p_Post.GlPostedDate
                WHERE  rowid = l_IGIRowid;
--
               l_Count := l_Count + 1;
--
            END IF;
--

         END IF; /* ExistsinPaymentSchedules */

        END LOOP;
        CLOSE Cra;
        WritetoLog( l_event_level, 'PostDistributedApplications','         '||l_Count||' lines posted' );
    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( l_excep_level, 'PostDistributedApplications','Exception:PostDistributedApplications:' );
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
 |    21-Mar-1995  C Aldamiz          Modified for 10.6
 *---------------------------------------------------------------------------*/
    PROCEDURE PostCashReceiptHistory( p_Post IN PostingParametersType ) IS
        CURSOR CCrh IS
        SELECT  crh.ROWID                            CrhRowid,
                igicrh.ROWID                         IGICrhRowid,
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
                d.code_combination_id            AccountCodeCombinationId,
                trunc(crh.gl_date)                          GlDate,
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
        d.source_type                SourceType
        FROM    ar_cash_receipt_history          crh,
                igi_ar_cash_receipt_hist        igicrh,
                ar_cash_receipts                 cr,
                ar_distributions             d
        WHERE  trunc(crh.gl_date)                      >=  p_Post.GlDateFrom
        AND    trunc(crh.gl_date)                      <=  p_Post.GlDateTo
        AND     igicrh.arc_posting_control_id = p_Post.UnpostedPostingControlId
        AND     crh.postable_flag                = 'Y'
        AND     cr.cash_receipt_id               = crh.cash_receipt_id
        AND     crh.cash_receipt_history_id+0    < p_Post.NxtCashReceiptHistoryId
        AND crh.cash_receipt_history_id      = d.source_id
        AND crh.cash_receipt_history_id      = igicrh.cash_receipt_history_id
        AND d.source_table = 'CRH'
        FOR UPDATE OF igicrh.arc_posting_control_id;
--
        RCrh  CCrh%ROWTYPE;
    l_Count         NUMBER  :=0;
--
        PROCEDURE InsertIntoGl( RCrh IN CCrh%ROWTYPE ) IS
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
                reference27,
                reference28,
                reference29,
                reference30
            )
            VALUES
            (
                p_Post.CreatedBy,                  -- created_by
                TRUNC( SYSDATE ),                  -- date_created
                'NEW',                             -- status
                'A',                               -- actual flag
                p_Post.PostingControlId,           -- group_id,
                p_Post.CashSetOfBooksId,               -- set_of_books_id
                p_Post.UserSource,                 -- user_je_source_name
                RCrh.Category,                     -- user_je_category_name
                RCrh.GlDate,                       -- accounting_date
                RCrh.DocSequenceId,                -- subledger_doc_sequence_id
                RCrh.DocSequenceValue,             -- subledger_doc_sequence_value
                RCrh.UssglTransactionCode,         -- ussgl_transaction_code
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
                'AR '||p_Post.PostingControlId,    -- reference1
                DECODE
                (
                    p_Post.SummaryFlag,
                    'Y',  NULL,
                    p_Post.NlsPreReceipt||' '||RCrh.ReceiptNumber||' '||p_Post.NlsPostReceipt
                ),                                 -- reference10
                p_Post.PostingControlId,           -- reference21
                RCrh.CashReceiptId,                -- reference22
                RCrh.CashReceiptHistoryId,         -- reference23
                RCrh.ReceiptNumber,                -- reference24
                RCrh.PayFromCustomer,              -- reference27
                RCrh.ModifiedType,                 -- reference28
                RCrh.ModifiedType||'_'||RCrh.SourceType, -- reference29
                'AR_CASH_RECEIPT_HISTORY'          -- reference30
            );
            if sql%found then
               WriteToLog ( l_state_level, 'InsertIntoGL','Insert into GL interface okay!');
            end if;
        EXCEPTION
            WHEN OTHERS THEN
                WritetoLog( l_excep_level, 'InsertIntoGL','InsertIntoGl:' );
                RAISE;
        END;
--
-- This is the actual PostCashReceiptHistory body
--
    BEGIN
        WritetoLog( l_state_level, 'PostCashReceiptHistory',' ' );
        WritetoLog( l_state_level, 'PostCashReceiptHistory','      AR_CASH_RECEIPT_HISTORY...' );
        OPEN CCrh;
        LOOP
            FETCH CCrh
            INTO  RCrh;
            EXIT WHEN CCrh%NOTFOUND;
            InsertIntoGl( RCrh );
            UPDATE igi_ar_cash_receipt_hist
            SET    arc_posting_control_id = p_Post.PostingControlId,
                   arc_gl_posted_date     = p_Post.GlPostedDate
            WHERE  ROWID                        = RCrh.IGICrhRowid;
        l_Count := l_Count + 1;
        END LOOP;
        CLOSE CCrh;
        WritetoLog( l_event_level, 'PostCashReceiptHistory','         '||l_Count||' lines posted' );
--
    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( l_excep_level, 'PostCashReceiptHistory','PostCashReceiptHistory:' );
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
 *---------------------------------------------------------------------------*/
    PROCEDURE PostMiscCashDistributions( p_Post IN PostingParametersType ) IS
        CURSOR CMcd IS
        SELECT  mcd.ROWID                            McdRowid,
                igimcd.ROWID                         IGIMcdRowid,
                mcd.misc_cash_distribution_id        MiscCashDistributionId,
                cr.cash_receipt_id                   CashReceiptId,
                cr.receipt_number                    ReceiptNumber,
                mcd.amount                           amount,
                mcd.acctd_amount                     acctd_amount,
                mcd.code_combination_id              code_combination_id,
                trunc(mcd.gl_date)                   gl_date,
                cr.currency_code                     currency_code,
                p_Post.UserMisc                      category,
                cr.doc_sequence_id                   doc_sequence_id,
                cr.doc_sequence_value                doc_sequence_value,
                mcd.ussgl_transaction_code           ussgl_transaction_code
        FROM    ar_misc_cash_distributions    mcd,
                igi_ar_misc_cash_dists         igimcd,
                ar_cash_receipts              cr
        WHERE   igimcd.arc_posting_control_id     = p_Post.UnpostedPostingControlId
        AND     trunc(mcd.gl_date)                >=  p_Post.GlDateFrom
        AND     trunc(mcd.gl_date)                <=  p_Post.GlDateTo
        AND     cr.cash_receipt_id                   = mcd.cash_receipt_id
        AND     mcd.misc_cash_distribution_id+0      < p_Post.NxtMiscCashDistributionId
        AND     mcd.misc_cash_distribution_id  = igimcd.misc_cash_distribution_id
        FOR UPDATE OF igimcd.arc_posting_control_id;
--
    l_Count         NUMBER  :=0;
    BEGIN
        WritetoLog( l_state_level, 'PostMiscCashDistributions',' ' );
        WritetoLog( l_state_level, 'PostMiscCashDistributions','      AR_MISC_CASH_DISTRIBUTIONS...' );
        FOR RMcd IN CMcd
        LOOP
            -- first create the debit in gl_interface to the account_code_combination_id
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
                reference28,
                reference29,
                reference30
            )
            VALUES
            (
                p_Post.CreatedBy,                  -- created_by
                TRUNC( SYSDATE ),                  -- date_created
                'NEW',                             -- status
                'A',                               -- actual flag
                p_Post.PostingControlId,           -- group_id,
                p_Post.CashSetOfBooksId,               -- set_of_books_id
                p_Post.UserSource,                 -- user_je_source_name
                RMcd.category,                     -- user_je_category_name
                RMcd.gl_date,                      -- accounting_date
                RMcd.doc_sequence_id,              -- subledger_doc_sequence_id
                RMcd.doc_sequence_value,           -- subledger_doc_sequence_value
                RMcd.ussgl_transaction_code,       -- ussgl_transaction_code
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
                'AR '||p_Post.PostingControlId,    -- reference1
                DECODE
                (
                    p_Post.SummaryFlag,
                    'Y', NULL,
                    p_Post.NlsPreMiscDist||' '||RMcd.ReceiptNumber||p_Post.NlsPostMiscDist
                ),                                 -- reference10
                p_Post.PostingControlId,           -- reference21
                RMcd.CashReceiptId,                -- reference22
                RMcd.MiscCashDistributionId,       -- reference23
                RMcd.ReceiptNumber,                -- reference24
                'MISC',                            -- reference28
                'MISC_MISC',                       -- reference29
                'AR_MISC_CASH_DISTRIBUTIONS'       -- reference30
            );
--
            UPDATE igi_ar_misc_cash_dists
            SET    arc_posting_control_id = p_Post.PostingControlId,
                   arc_gl_posted_date     = p_Post.GlPostedDate
            WHERE  ROWID                        = RMcd.IGIMcdRowid;
        l_Count := l_Count + 1;
        END LOOP;
        WritetoLog( l_state_level, 'PostMiscCashDistributions','         '||l_Count||' lines posted' );
    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( l_excep_level, 'PostMiscCashDistributions','PostMiscCashDistributions:' );
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
    PROCEDURE ClearOOB( p_Post IN PostingParametersType,
                              p_BalanceId IN NUMBER,
                  p_CategoryCode IN VARCHAR2 ) IS
    BEGIN
    IF ( p_CategoryCode = 'TRADE') OR
           (p_CategoryCode  = 'CROSS CURR') OR
           ( p_CategoryCode = 'MISC' )
    THEN
            UPDATE  igi_ar_cash_receipt_hist iacrh
            SET     arc_gl_posted_date      = NULL,
                    arc_posting_control_id  = p_Post.UnpostedPostingControlId
            WHERE   arc_posting_control_id  = p_Post.PostingControlId
            AND     EXISTS
            ( select cash_receipt_id
              from   ar_cash_receipt_history acrh
              where  acrh.cash_receipt_id         = p_BalanceId
              and    acrh.cash_receipt_history_id = iacrh.cash_receipt_history_id
            );
--
            UPDATE  igi_ar_cash_receipt_hist iacrh
            SET     arc_rev_gl_posted_date       = NULL,
                    arc_rev_post_control_id      = p_Post.UnpostedPostingControlId
            WHERE   arc_rev_post_control_id      = p_Post.PostingControlId
            AND     EXISTS
            ( select cash_receipt_id
              from   ar_cash_receipt_history acrh
              where  acrh.cash_receipt_id         = p_BalanceId
              and    acrh.cash_receipt_history_id = iacrh.cash_receipt_history_id
            );
    END IF;
--
    IF p_CategoryCode = 'MISC'
    THEN
            UPDATE  igi_ar_misc_cash_dists iamcd
            SET     arc_gl_posted_date = NULL,
                    arc_posting_control_id  = p_Post.UnpostedPostingControlId
            WHERE   arc_posting_control_id  = p_Post.PostingControlId
            AND     EXISTS
            ( select cash_receipt_id
              from   ar_misc_cash_distributions amcd
              where  amcd.cash_receipt_id         = p_BalanceId
              and    amcd.misc_cash_distribution_id = amcd.misc_cash_distribution_id
            );
    END IF;
--
    IF ( p_CategoryCode = 'TRADE') OR
           ( p_CategoryCode = 'CMAPP' )
    THEN
            UPDATE  igi_ar_rec_applications igiapp
            SET     arc_gl_posted_date      = NULL,
                    arc_posting_control_id  = p_Post.UnpostedPostingControlId
            WHERE   arc_posting_control_id  = p_Post.PostingControlId
            AND     EXISTS
            ( select 'x'
              from   ar_receivable_applications app
              where  app.receivable_application_id = igiapp.receivable_application_id
              and     decode(p_CategoryCode,
                'CMAPP',customer_trx_id,
                'TRADE', cash_receipt_id)     = p_BalanceId
            ) ;
--
            DELETE  FROM igi_ar_cash_basis_dists
            WHERE   cash_basis_distribution_id IN (
                SELECT  reference23
                FROM    gl_interface
                WHERE   reference22          = p_BalanceId
            AND     reference28              = p_CategoryCode
            AND     set_of_books_id          = p_Post.CashSetOfBooksId
                AND     group_id             = p_Post.PostingControlId
                AND     user_je_source_name  = p_Post.UserSource
                AND     reference30          = 'AR_CASH_BASIS_DISTRIBUTIONS'
            );
    END IF;
--
        DELETE  FROM gl_interface
        WHERE   reference22          = p_BalanceId
        AND reference28      = p_CategoryCode
        AND     set_of_books_id      = p_Post.CashSetOfBooksId
        AND     group_id             = p_Post.PostingControlId
        AND     user_je_source_name  = p_Post.UserSource;
--
    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( l_excep_level, 'ClearOOB','ClearOOB' );
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
 |        (via WritetoLog), and will be deleted with ClearOOB  |
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
    PROCEDURE CheckBalance( p_Post IN PostingParametersType
                          , p_balance_flag in out NOCOPY varchar2 ) IS
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
        AND     i.set_of_books_id           = p_Post.CashSetOfBooksId
        AND     i.accounting_date      BETWEEN p_Post.GlDateFrom
                                       AND     p_Post.GlDateTo
        GROUP BY i.reference28,
                 i.reference22
        HAVING ( nvl(decode(i.reference28,'CCURR',
                                  0,sum(nvl(entered_dr,0))),0)<> nvl(decode(i.reference28,'CCURR',
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
        AND     set_of_books_id         = p_Post.CashSetOfBooksId
        AND     i.reference22           = p_BalanceId
        AND     i.reference28       = p_CategoryCode
        ORDER BY i.reference30,
                 i.reference23;
--
        l_plsql_id number;
        l_posting_id number;

        l_ReceivableApplicationId      ar_receivable_applications.receivable_application_id%TYPE;
        isoutofbalance Boolean := FALSE;
        l_outofbal_label1 varchar2(240);
        l_outofbal_label2 varchar2(240);
        l_outofbal_label3 varchar2(240);

        FUNCTION GetMeaning ( p_lookup_code in varchar2 )
        RETURN VARCHAR2 IS
           CURSOR c_look IS
             SELECT meaning
             FROM   igi_lookups
             WHERE  lookup_type = 'IGIRCBER_OUT_OF_BAL_REPORT'
             AND    lookup_code = p_lookup_code
             ;
        BEGIN
           FOR l_look in c_look LOOP
               return l_look.meaning;
           END LOOP;
           return null;
        END GetMeaning;
    BEGIN
--
        select igi_plsql_control_s.nextval , p_Post.PostingControlId
        into   l_plsql_id, l_posting_id
        from   sys.dual;

        l_outofbal_label1 := GetMeaning( 'OB1');
        l_outofbal_label2 := GetMeaning( 'OB2');
        l_outofbal_label3 := GetMeaning( 'OB3');

        WritetoOut(l_plsql_id, l_posting_id,'' );
--
        FOR RBal IN CBal
        LOOP
            isoutofbalance := TRUE;
            WritetoOut( l_plsql_id,l_posting_id,l_outofbal_label1||Rbal.CurrencyCode||l_outofbal_label2||RBal.BalanceId );
            FOR RInt IN CInt( RBal.BalanceId, Rbal.CategoryCode )
            LOOP
                IF RInt.TableName = 'AR_CASH_BASIS_DISTRIBUTIONS'
                THEN
            BEGIN

                    SELECT  cbd.receivable_application_id
                    INTO    l_ReceivableApplicationId
                    FROM    igi_ar_cash_basis_dists    cbd
                    WHERE   cbd.cash_basis_distribution_id = RInt.Id;

            EXCEPTION
            WHEN OTHERS THEN
            l_ReceivableApplicationId := NULL;

            END;

                ELSE
                    l_ReceivableApplicationId := NULL;
                END IF;
                WritetoOut( l_plsql_id,l_posting_id,RPAD( Rint.TableName, 30)||
                                          RPAD( RInt.Id, 15 )||
                                          LPAD( NVL(TO_CHAR(RInt.EnteredDr), ' '),15)||
                                          LPAD( NVL(TO_CHAR(RInt.EnteredCr), ' '),15)||
                                          LPAD( NVL(TO_CHAR(RInt.AccountedDr), ' '),15)||
                                          LPAD( NVL(TO_CHAR(RInt.AccountedCr), ' '),15)||
                                          '    '||l_ReceivableApplicationId );
            END LOOP;
            WritetoOut( l_plsql_id, l_posting_id,RPAD( l_outofbal_label3, 30)||
                                      RPAD( ' ', 15 )||
                                      LPAD( NVL(TO_CHAR(RBal.SumEnteredDr), ' '),15)||
                                      LPAD( NVL(TO_CHAR(RBal.SumEnteredCr), ' '),15)||
                                      LPAD( NVL(TO_CHAR(RBal.SumAccountedDr), ' '),15)||
                                      LPAD( NVL(TO_CHAR(RBal.SumAccountedCr), ' '),15) );
            ClearOOB( p_Post, RBal.BalanceId, RBal.CategoryCode );
        END LOOP;

        if not IsOutofBalance then
                   p_balance_flag := 'Y';
        else
                   p_balance_flag := 'N';
        end if;
    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( l_excep_level, 'CheckBalance','CheckBalance:' );
            RAISE;
    END;
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
            WritetoLog( l_excep_level, 'CheckUpgradedCustomer','CheckUpgradedCustomer:' );
            RAISE;
   END;

--
--
FUNCTION RecordsExistInGLInterface (fp_user_source in varchar2
                                            ,fp_posting_control_id in number
                                            ,fp_cash_sob_id in number
                                            )
 RETURN BOOLEAN IS

       CURSOR c_gl IS
                 SELECT distinct 'x'
                 FROM    gl_interface
                 WHERE   set_of_books_id      = fp_cash_sob_id
                 AND     group_id             = fp_posting_control_id
                 AND     user_je_source_name  = fp_user_source;

BEGIN
       FOR l_gl in c_gl LOOP
                  return TRUE;
       END LOOP;
       return FALSE;
EXCEPTION WHEN OTHERS THEN return TRUE;
END;

--
FUNCTION ar_nls_text
        ( p_message_name    VARCHAR2
        ) RETURN VARCHAR2 IS
l_message_text VARCHAR2(240);
BEGIN
    SELECT message_text
      INTO l_message_text
      FROM fnd_new_messages
     WHERE application_id = 222
       AND message_name = p_message_name;
     return(l_message_text);
EXCEPTION
   WHEN OTHERS THEN
return(p_message_name);
end;

--
-- --------------------------------------------------------------------------
--
--

    PROCEDURE Post( p_Post       IN PostingParametersType
                   ,p_BalanceFlag OUT NOCOPY CHAR ) IS
    l_FromRel9      VARCHAR2(1);
    BalanceFlag         VARCHAR2(1) := 'Y' ;
    BEGIN
     CheckUpgradedCustomer( l_FromRel9 );
     IF l_FromRel9 = 'Y'
     THEN
       arp_standard.fnd_message('AR_WWS_CASH_BASIS');
     ELSE
        PostCashReceiptHistory( p_Post );
        PostMiscCashDistributions( p_Post );
        PostNonDistApplications( p_Post );
        PostDistributedApplications( p_Post );
        CheckBalance( p_Post ,BalanceFlag );
        p_BalanceFlag := BalanceFlag;
     END IF;
    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( l_excep_level, 'Post','Exception:IGIRCBAP.Post( p_Post ):'||sqlerrm );
	    IF ( l_unexp_level >= l_debug_level ) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,l_path || 'Post', TRUE);
            END IF;
            RAISE_APPLICATION_ERROR( -20000, sqlerrm||'$Revision: 115.18 $:Post( p_Post ):' );
    END;



    PROCEDURE Post
                ( p_PostingControlId        IN  NUMBER
        , p_GlDateFrom          IN  DATE
        , p_GlDateTo            IN  DATE
        , p_GlPostedDate        IN  DATE
        , p_CreatedBy           IN  NUMBER
        , p_SummaryFlag         IN  VARCHAR2
        , p_SetOfBooksId        OUT NOCOPY NUMBER
        , p_CashSetOfBooksId        OUT NOCOPY NUMBER
        , p_user_je_source_name     OUT NOCOPY VARCHAR2
        , p_ra_id           OUT NOCOPY NUMBER
        , p_crh_id          OUT NOCOPY NUMBER
        , p_mcd_id          OUT NOCOPY NUMBER
        , p_balanceflag         OUT NOCOPY VARCHAR2
        ) IS
    l_Post  PostingParametersType;
    l_BalanceFlag   Varchar2(1);
    l_je_source_name igi_ar_system_options_all.arc_je_source_name%TYPE := null;
    BEGIN
--
-- Variables set by parameters passed through from post procedure
--
        l_Post.PostingControlId     := p_PostingControlId;
        WriteToLog ( l_excep_level, 'Post',' Posting Control Id '||p_PostingControlId );
        l_Post.GlDateFrom       := trunc(p_GlDateFrom);
        l_Post.GlDateTo         := trunc(p_GlDateTo);
        l_Post.GlPostedDate     := trunc(p_GlPostedDate);
        l_Post.CreatedBy        := nvl(p_CreatedBy,fnd_global.user_id);
        l_Post.SummaryFlag      := p_SummaryFlag;
--
-- Variables set from ar_system_parameters
--
    SELECT sob.currency_code
         , sp.set_of_books_id
         , igisp.arc_cash_sob_id
         , igisp.arc_unalloc_rev_ccid
         , igisp.arc_je_source_name
      INTO l_Post.FuncCurr
         , l_Post.SetOfBooksId
         , l_Post.CashSetOfBooksId
         , l_Post.UnallocatedRevCcid
         , l_je_source_name
      FROM ar_system_parameters sp
         , igi_ar_system_options igisp
         , gl_sets_of_books sob
     WHERE sob.set_of_books_id = sp.set_of_books_id;
--
-- Get the report request ID
--
        FND_PROFILE.GET ('CONC_REQUEST_ID', l_Post.ReqId);
    if l_Post.ReqId IS NULL THEN   -- Not run through conc manager
        l_Post.ReqId := 0;
    end if;
--
--
    SELECT user_je_source_name
          INTO l_Post.UserSource
      FROM gl_je_sources
     WHERE je_source_name = nvl(l_je_source_name,'Receivables');
--
    SELECT user_je_category_name
          INTO l_Post.UserTrade
      FROM gl_je_categories
     WHERE je_category_name = 'Trade Receipts';
--
    SELECT user_je_category_name
          INTO l_Post.UserMisc
      FROM gl_je_categories
     WHERE je_category_name = 'Misc Receipts';

     SELECT user_je_category_name
       INTO    l_Post.UserCcurr
       FROM  gl_je_categories
     WHERE je_category_name = 'Cross Currency';

--
-- Set max ids
--
    BEGIN
-- bug 3446832 sdixit: start
/*** the max id 's returned will always be null as there should not be
     any records in the igi tables for the current posting control id !!!
     hence replacing with contrants
***/
/***
    SELECT nvl(max(crh.cash_receipt_history_id), 999999999999998)+1
          INTO l_Post.NxtCashReceiptHistoryId
      FROM ar_cash_receipt_history crh
      ,    igi_ar_cash_receipt_hist igicrh
     WHERE crh.cash_receipt_history_id = igicrh.cash_receipt_history_id
     AND   igicrh.arc_posting_control_id = p_PostingControlId;

    SELECT nvl(max(app.receivable_application_id), 999999999999998)+1
          INTO l_Post.NxtReceivableApplicationId
      FROM ar_receivable_applications app
      ,    igi_ar_rec_applications igiapp
     WHERE app.receivable_application_id = igiapp.receivable_application_id
     AND   igiapp.arc_posting_control_id = p_PostingControlId;

    SELECT nvl(max(mcd.misc_cash_distribution_id), 999999999999998)+1
          INTO l_Post.NxtMiscCashDistributionId
      FROM ar_misc_cash_distributions mcd
      ,    igi_ar_misc_cash_dists     igimcd
     WHERE mcd.misc_cash_distribution_id = igimcd.misc_cash_distribution_id
     and   igimcd.arc_posting_control_id = p_PostingControlId;

    SELECT nvl(max(adj.adjustment_id), 999999999999998)+1
      INTO l_Post.NxtAdjustmentId
      FROM ar_adjustments adj
      ,    igi_ar_adjustments igiadj
     WHERE adj.adjustment_id = igiadj.adjustment_id
     AND   igiadj.arc_posting_control_id = p_PostingControlId;

    SELECT nvl(max(cust_trx_line_gl_dist_id), 999999999999998)+1
          INTO l_Post.NxtCustTrxLineGlDistId
      FROM ra_cust_trx_line_gl_dist
     WHERE posting_control_id = p_PostingControlId;

***/
    l_Post.NxtCashReceiptHistoryId := 999999999999999;
    l_Post.NxtReceivableApplicationId:= 999999999999999;
    l_Post.NxtMiscCashDistributionId:= 999999999999999;
    l_Post.NxtAdjustmentId:= 999999999999999;
    l_Post.NxtCustTrxLineGlDistId:= 999999999999999;
   END;
--bug 3446832 sdixit end

--
--
-- National Language Support variables
--
        l_Post.NlsPreReceipt    := ar_nls_text('AR_NLS_GLTP_PRE_RECEIPT');
        l_Post.NlsPostReceipt   := ar_nls_text('AR_NLS_GLTP_POST_RECEIPT');
        l_Post.NlsPreMiscDist   := ar_nls_text('AR_NLS_GLTP_PRE_MISC_DIST');
        l_Post.NlsPostMiscDist  := ar_nls_text('AR_NLS_GLTP_POST_MISC_DIST');
        l_Post.NlsPreTradeApp   := ar_nls_text('AR_NLS_GLTP_PRE_TRADEAPP');
        l_Post.NlsPostTradeApp  := ar_nls_text('AR_NLS_GLTP_POST_TRADEAPP');
        l_Post.NlsPreReceiptGl  := ar_nls_text('AR_NLS_GLTP_PRE_RECEIPTGL');
        l_Post.NlsPostReceiptGl := ar_nls_text('AR_NLS_GLTP_POST_RECEIPTGL');
        l_Post.NlsAppOnacc  := ar_nls_text('AR_NLS_APP_ONACC');
        l_Post.NlsAppUnapp  := ar_nls_text('AR_NLS_APP_UNAPP');
        l_Post.NlsAppUnid   := ar_nls_text('AR_NLS_APP_UNID');
        l_Post.NlsAppApplied    := ar_nls_text('AR_NLS_APP_APPLIED');
--
--
-- Hard Coded variables
--
        l_Post.ChkBalance       := 'Y';
        l_Post.UnpostedPostingControlId   := -3;
        l_BalanceFlag           := 'Y';
--
-- Variables to be passed bacjk to the calling report
--
    p_SetOfBooksId      := l_Post.SetOfBooksId;
    p_CashSetOfBooksId  := l_Post.CashSetOfBooksId;
    p_ra_id         := l_Post.NxtReceivableApplicationId;
    p_crh_id        := l_Post.NxtCashReceiptHistoryId;
    p_mcd_id        := l_Post.NxtMiscCashDistributionId;
--
        Post( l_Post, l_BalanceFlag);

-- Pass balance flag back to calling report

    p_BalanceFlag := l_BalanceFlag;
    p_user_je_source_name := l_Post.USerSource;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
 END;
--
--
PROCEDURE SubmitJournalImport
    ( p_posting_control_id           IN   NUMBER
    , p_start_date                   IN   DATE
    , p_post_thru_date               IN   DATE
     )
AS
l_cash_set_of_books_id      NUMBER;
l_cash_gl_interface_run_id  NUMBER;
l_cash_gllezl_request_id    NUMBER;
l_arc_summary_flag          VARCHAR2(1):= 'N';
l_arc_run_gl_import         VARCHAR2(1):='N';
l_je_source_name            GL_JE_SOURCES.JE_SOURCE_NAME%TYPE;
BEGIN
-- Submit Cash GL Journal Import
SELECT  GL_JOURNAL_IMPORT_S.nextval
      , sp.ARC_cash_sob_id
      , nvl(sp.arc_je_source_name, 'Receivables')  arc_je_source_name
INTO    l_cash_gl_interface_run_id
      , l_cash_set_of_books_id
      , l_je_source_name
FROM    igi_ar_system_options sp
,       ar_system_parameters asp
WHERE   sp.set_of_books_id = asp.set_of_books_id
and     nvl(sp.org_id,-99)         = nvl(asp.org_id,-99)
;

SELECT  arc_summary_flag, arc_run_gl_import_flag
INTO    l_Arc_summary_flag, l_arc_run_gl_import
FROM    igi_ar_posting_control
WHERE   arc_posting_control_id = p_posting_control_id
AND   rownum <= 1
;

IF l_arc_run_gl_import <> 'Y' THEN
   return;
END IF;

INSERT INTO gl_interface_control
        ( je_source_name
        , status
        , interface_run_id
        , group_id
        , set_of_books_id)
VALUES  ( l_je_source_name
        , 'S'
        , l_cash_gl_interface_run_id
        , p_posting_control_id
        , l_cash_set_of_books_id
        );

l_cash_gllezl_request_id :=
            FND_REQUEST.SUBMIT_REQUEST
                 ( 'SQLGL'
                 , 'GLLEZL'
                 , null
                 , null
                 , FALSE
                 , l_cash_gl_interface_run_id
                 , l_cash_set_of_books_id
                 , 'N' -- post_errors_to_suspense
                 , to_char(p_start_date,'YYYY/MM/DD')
                 , to_char(p_post_thru_date,'YYYY/MM/DD')
                 , l_arc_summary_flag -- summary journals
                 , 'N' -- descriptive_flexfield_flag
                 );

   if l_cash_gllezl_request_id <> 0 then
       update igi_ar_posting_control
       set    arc_gllezl_request_id = l_cash_gllezl_request_id
       where  arc_posting_control_id = p_posting_control_id
       ;
  end if;
       COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( l_excep_level, 'SubmitJournalImport','Exception:IGIRCBAP.SubmitJournalImport ( ... ):'||sqlerrm );
            IF ( l_unexp_level >= l_debug_level ) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,l_path || 'SubmitJournalImport', TRUE);
            END IF;
	    RAISE_APPLICATION_ERROR( -20000, sqlerrm||'SubmitGlTransfer( ... ):' );
--
end;
--
END IGIRCBAP;

/
