--------------------------------------------------------
--  DDL for Package Body IGIRCABJP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIRCABJP" AS
-- $Header: igircajb.pls 120.8.12000000.5 2007/11/27 11:05:50 pshivara ship $

    DebugMode BOOLEAN;

--following variables added for bug 3199481: fnd logging changes: sdixit
   l_debug_level number;
   l_state_level number;
   l_proc_level number;
   l_event_level number;
   l_excep_level number;
   l_error_level number;
   l_unexp_level number;

   l_xah_ar_application_id NUMBER := 222;

    PROCEDURE WriteToLogFile  (pp_mesg in varchar2) IS
    BEGIN
       IF DebugMode THEN
        fnd_file.put_line( fnd_file.log , pp_mesg );
       END IF;
    END WriteToLogFile;
--
    PROCEDURE GetAdjustments  ( p_Report      IN     ReportParametersType ) IS
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
        'NEW'                                                   status,
        'A'                                                     actual_flag,
        p_Report.ReqId                                          request_id,
        fnd_global.user_id                                      created_by,
        trunc(sysdate)                                          date_created,
        p_Report.SetOfBooksId                                   sob_id,
        'Receivables'                                           source,
        'Adjustment'                                            category,
        adj.apply_date                                          trx_date,
        adj.gl_date                                             gl_date,
        ct.invoice_currency_code                                currency,
        ard.code_combination_id                                 ccid,
        ard.amount_dr                                           entered_dr,
        ard.amount_cr                                           entered_cr,
        ard.acctd_amount_dr                                     acctd_dr,
        ard.acctd_amount_cr                                     acctd_cr,
        l_cat.meaning                                           ref10,
        to_char(p_Report.ReqId)                                 ref21,
        to_char(adj.adjustment_id)                              ref22,
        to_char(ard.line_id)                                    ref23,
        to_char(null)                                           ref24,
        ct.trx_number                                           ref25,
        hz_cust_accounts.account_number                         ref26,  -- Bug 3902175
        ct.bill_to_customer_id                                  ref27,
        'ADJ'                                                   ref28,
        'ADJ' || ard.source_type                                ref29,
        'AR_ADJUSTMENTS'                                        ref30
        FROM
        ra_customer_trx_all ct,
        ra_cust_trx_types_all ctt,
        ar_distributions_all ard,
        hz_parties,  -- Bug 3902175
        hz_cust_accounts,  -- Bug 3902175
        ar_adjustments_all adj,
        ar_lookups l_cat,
        xla_ae_headers xah
        WHERE
            adj.adjustment_id +0 < p_Report.NxtAdjustmentId
        and adj.set_of_books_id = p_Report.SetOfBooksId
        and nvl(adj.postable,'Y') = 'Y'
        and adj.adjustment_id = ard.source_id
        and ard.source_table = 'ADJ'
        and adj.customer_trx_id = ct.customer_trx_id
        and ctt.cust_trx_type_id = ct.cust_trx_type_id
        and hz_cust_accounts.cust_account_id = ct.bill_to_customer_id  -- Bug 3902175
        and hz_parties.party_id = hz_cust_accounts.party_id  -- Bug 3902175
        and l_cat.lookup_type = 'ARRGTA_FUNCTION_MAPPING'
        and l_cat.lookup_code = 'ADJ_' || ard.source_type
        and ct.invoice_currency_code = decode( p_Report.FuncCurr,
                                        null,ct.invoice_currency_code,
                                        p_Report.FuncCurr)
        and p_Report.adj = 'Y'
        and adj.gl_date between   p_Report.GlDateFrom
                            and   p_Report.GlDateTo
        and adj.posting_control_id > 0
        and xah.event_id = adj.event_id
        and xah.application_id = l_xah_ar_application_id
        and xah.ledger_id = adj.set_of_books_id
        and xah.ledger_id = p_Report.SetOfBooksId
        and xah.accounting_date between p_Report.GlDateFrom and p_Report.GlDateTo
        and xah.gl_transfer_status_code = 'Y'
        and xah.gl_transfer_date between p_Report.PostedDateFrom and p_Report.PostedDateTo
/* Added for bug 6647672 start */
        and NOT EXISTS ( select 'Y'
                         from xla_ae_headers xah2
                         where xah2.event_id = adj.event_id
        		 and xah2.application_id = l_xah_ar_application_id
        		 and xah2.ledger_id = adj.set_of_books_id
         		 and xah2.ledger_id = p_Report.CashSetOfBooksId
        		 and xah2.accounting_date between p_Report.GlDateFrom and p_Report.GlDateTo
        		 and xah2.gl_transfer_status_code = 'Y'
          		 and xah2.gl_transfer_date between p_Report.PostedDateFrom and p_Report.PostedDateTo );
/* end bug 6647672 */
/*        and exists ( select 'x'
                     from igi_ar_adjustments
                     where a  djustment_id = adj.adjustment_id
                     and   arc_posting_control_id = -3
                    )
         and nvl(adj.gl_posted_date,to_date('01-01-1952','DD-MM-YYYY'))
             between
                 decode(p_Report.PostedDateFrom ,
                            null, nvl(adj.gl_posted_date,to_date('01-01-1952',
                                                          'DD-MM-YYYY')),
                            p_Report.PostedDateFrom )
               and
                decode(  p_Report.PostedDateTo ,
                            null, nvl(adj.gl_posted_date,to_date('01-01-1952',
                                                          'DD-MM-YYYY')),
                            p_Report.PostedDateTo );
*/

    EXCEPTION
      WHEN OTHERS THEN

      FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message

      IF ( l_unexp_level >= l_debug_level ) THEN

           FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
           FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
           FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
           FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igircajb.IGIRCABJP.GetAdjustments',TRUE);
      END IF;

         RAISE;
    END;
--
--
    PROCEDURE GetTxnDistributions(  p_Report         IN ReportParametersType )
    IS
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
        'NEW'                                                   status,
        'A'                                                     actual_flag,
        p_Report.ReqId                                           request_id,
        fnd_global.user_id                                               created_by,
        trunc(sysdate)                                          date_created,
        p_Report.SetOfBooksId                                                sob_id,
        'Receivables'                                           source,
        decode(ctt.type,
                'CM', 'Credit Memos',
                'DM', 'Debit Memos',
                'CB', 'Chargebacks',
               'Sales Invoices')                                category,
        ct.trx_date                                             trx_date,
        ctlgd.gl_date                                           gl_date,
        ct.invoice_currency_code                                currency,
        ctlgd.code_combination_id                               ccid,
        decode(ctlgd.account_class,
                'REC', decode(sign(nvl(ctlgd.amount,0)),
                                -1,null,nvl(ctlgd.amount,0)),
                decode(sign(nvl(ctlgd.amount,0)),
                        -1,-nvl(ctlgd.amount,0),null))          entered_dr,
        decode(ctlgd.account_class,
                'REC', decode(sign(nvl(ctlgd.amount,0)),
                                -1,-nvl(ctlgd.amount,0),null),
                decode(sign(nvl(ctlgd.amount,0)),
                        -1,null,nvl(ctlgd.amount,0)))           entered_cr,
        decode(ctlgd.account_class,
                'REC', decode(sign(nvl(ctlgd.acctd_amount,0)),
                                -1,null,nvl(ctlgd.acctd_amount,0)),
                decode(sign(nvl(ctlgd.acctd_amount,0)),
                        -1,-nvl(ctlgd.acctd_amount,0),null))    acctd_dr,
        decode(ctlgd.account_class,
                'REC', decode(sign(nvl(ctlgd.acctd_amount,0)),
                                -1,-nvl(ctlgd.acctd_amount,0),null),
                decode(sign(nvl(ctlgd.acctd_amount,0)),
                        -1,null,nvl(ctlgd.acctd_amount,0)))     acctd_cr,
        l_cat.meaning                                           ref10,
        to_char(p_Report.ReqId)                                   ref21,
        to_char(ct.customer_trx_id)                             ref22,
        to_char(ctlgd.cust_trx_line_gl_dist_id)                 ref23,
        to_char(null)                                           ref24,
        ct.trx_number                                           ref25,
        hz_cust_accounts.account_number                         ref26,  -- Bug 3902175
        to_char(ct.bill_to_customer_id)                         ref27,
        decode(ctt.type,
                'CM', 'CM',
                'DM', 'DM',
                'CB', 'CB',
                'INV')                                          ref28,
        decode(ctt.type,
                'CM', 'CM_',
                'DM', 'DM_',
                'CB', 'CB_',
                'INV_')||ctlgd.account_class                    ref29,
        'RA_CUST_TRX_LINE_GL_DIST'                              ref30
        FROM
        ar_lookups l_cat,
        ra_cust_trx_types ctt,
        hz_parties, 	  -- Bug 3902175
        hz_cust_accounts, -- Bug 3902175
        ra_customer_trx_all ct,
        ra_cust_trx_line_gl_dist ctlgd,
        xla_ae_headers xah
        WHERE
            ctlgd.cust_trx_line_gl_dist_id+0 < p_Report.NxtCustTrxLineGlDistId
        and ctlgd.set_of_books_id = p_Report.SetOfBooksId
        and ctlgd.account_set_flag = 'N'
        and ctlgd.customer_trx_id = ct.customer_trx_id
        and ct.complete_flag = 'Y'
        and ct.cust_trx_type_id = ctt.cust_trx_type_id
        and hz_parties.party_id = hz_cust_accounts.party_id -- Bug 3902175
        and hz_cust_accounts.cust_account_id = ct.bill_to_customer_id  -- Bug 3902175
        and l_cat.lookup_type = 'ARRGTA_FUNCTION_MAPPING'
        and l_cat.lookup_code = decode(ctt.type,
                                       'CM', 'CM_',
                                       'DM', 'DM_',
                                       'CB', 'CB_',
                                       'INV_')||nvl(ctlgd.account_class,'REV')
        and ct.invoice_currency_code = decode( p_Report.FuncCurr,
                                        null,ct.invoice_currency_code,
                                        p_Report.FuncCurr)
        and ( ('Y' = 'Y' and ctt.type in ( 'INV','GUAR','DEP' ))
               OR
             ('Y' = 'Y'   and ctt.type = 'DM' )
               OR
             ('Y' = 'Y'   and ctt.type = 'CB' )
               OR
             ('Y' = 'Y'   and ctt.type = 'CM' )
           )
        and ctlgd.gl_date between p_Report.GlDateFrom
                          and   p_Report.GlDateTo
        and ctlgd.posting_control_id > 0
        and xah.event_id = ctlgd.event_id
        and xah.application_id = l_xah_ar_application_id
        and xah.ledger_id = ctlgd.set_of_books_id
        and xah.ledger_id = p_Report.SetOfBooksId
        and xah.accounting_date between p_Report.GlDateFrom and p_Report.GlDateTo
        and xah.gl_transfer_status_code = 'Y'
        and xah.gl_transfer_date between p_Report.PostedDateFrom and p_Report.PostedDateTo
/* Added for bug 6647672 start */
  and NOT EXISTS ( select 'Y'
                         from xla_ae_headers xah2
                         where xah2.event_id = ctlgd.event_id
        		 and xah2.application_id = l_xah_ar_application_id
        		 and xah2.ledger_id = ctlgd.set_of_books_id
        		 and xah2.ledger_id = p_Report.CashSetOfBooksId
        		 and xah2.accounting_date between p_Report.GlDateFrom and p_Report.GlDateTo
        		 and xah2.gl_transfer_status_code = 'Y'
        		 and xah2.gl_transfer_date between p_Report.PostedDateFrom and p_Report.PostedDateTo ) ;
/* end bug 6647672 */
/*        and exists ( select 'x'
                     from igi_ar_cash_basis_dists_all cbd
                     where cbd.source = 'GL'
                     and   cbd.source_id = ctlgd.cust_trx_line_gl_dist_id
                     and   ( ( exists( select 'x'
                                       from igi_ar_rec_applications_all
                                       where receivable_application_id = cbd.receivable_application_id
                                       and   arc_posting_control_id = -3
                                       )
                             ) or
                             ( cbd.receivable_application_id_cash is not null and
                               ( exists
                                   ( select receivable_application_id
                                     from   igi_ar_rec_applications_all
                                     where   receivable_application_id =cbd.receivable_application_id
                                       and   arc_posting_control_id = -3
                                   )
                               )
                             )
                           )
                   )
        and nvl(ctlgd.gl_posted_date,to_date('01-01-1952','DD-MM-YYYY'))
               between
               decode( p_Report.PostedDateFrom ,
                          null, nvl(ctlgd.gl_posted_date,to_date('01-01-1952',
                                                          'DD-MM-YYYY')),
                            p_Report.PostedDateFrom )
               and
               decode( p_Report.PostedDateTo,
                          null, nvl(ctlgd.gl_posted_date,to_date('01-01-1952',
                                                          'DD-MM-YYYY')),
                            p_Report.PostedDateTo  );
*/
  EXCEPTION
      WHEN OTHERS THEN

      IF ( l_unexp_level >= l_debug_level ) THEN

           FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
           FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
           FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
           FND_LOG.MESSAGE ( l_unexp_level,'igi.pls.igircajb.IGIRCABJB.GetTxnDistributions',TRUE);
      END IF;

      RAISE;
  END;
--
--
    PROCEDURE GetRxptHistory( p_Report        IN ReportParametersType ) IS
    BEGIN
--
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
        'NEW'                                                           status,
        'A'                                                             actual_flag,
        p_Report.ReqId                                                  request_id,
        fnd_global.user_id                                              created_by,
        trunc(sysdate)                                                  date_created,
        p_Report.SetOfBooksId                                           sob_id,
        'Receivables'                                                   source_name,
        decode(cr.type,
               'MISC', 'Misc Receipts',
               'Trade Receipts')                                        category,
        crh.trx_date                                                    trx_date,
        crh.gl_date                                                     gl_date,
        cr.currency_code                                                currency,
        ard.code_combination_id                                         ccid,
        to_number(ard.amount_dr)                                        entered_dr,
        to_number(ard.amount_cr)                                        entered_cr,
        to_number(ard.acctd_amount_dr)                                  acctd_dr,
        to_number(ard.acctd_amount_cr)                                  acctd_cr,
        l_cat.meaning                                                   ref10,
        to_char(p_Report.ReqId)                                           ref21,
        decode(cr.type,
               'CASH',to_char(cr.cash_receipt_id)||'C'||
                      to_char(crh.cash_receipt_history_id),
               'MISC',to_char(cr.cash_receipt_id))                      ref22,
        to_char(ard.line_id)                                            ref23,
        cr.receipt_number                                               ref24,
        decode(cr.type,
               'CASH',to_char(null),
               'MISC',to_char(crh.cash_receipt_history_id))             ref25,
        cust.customer_number                                 			ref26, -- Bug 3902175
        to_char(cr.pay_from_customer)                                   ref27,
        decode( cr.type,
               'MISC', 'MISC',
               'TRADE')                                                 ref28,
        decode( cr.type,
               'MISC', 'MISC_',
               'TRADE_')||ard.source_type                               ref29,
        'AR_CASH_RECEIPT_HISTORY'                                       ref30
        FROM
        ar_lookups l_cat,
       	(Select hz_cust_accounts.account_number customer_number,hz_cust_accounts.cust_account_id customer_id
	 from hz_parties,hz_cust_accounts where hz_parties.party_id = hz_cust_accounts.party_id) cust, -- bug 3902175
        ar_distributions ard,
        ar_cash_receipts cr,
        ar_cash_receipt_history_all crh,
        xla_ae_headers xah
        WHERE  crh.cash_receipt_history_id+0 < p_Report.NxtCashReceiptHistoryId
        and crh.cash_receipt_history_id = ard.source_id
        and ard.source_table = 'CRH'
        and cr.set_of_books_id = p_Report.SetOfBooksId
        and crh.postable_flag = 'Y'
        and crh.cash_receipt_id = cr.cash_receipt_id
        and cust.customer_id(+) = cr.pay_from_customer -- Bug 3902175
        and l_cat.lookup_type = 'ARRGTA_FUNCTION_MAPPING'
        and l_cat.lookup_code = decode( cr.type,
                                       'MISC', 'MISC_',
                                       'TRADE_')||ard.source_type
        and cr.currency_code = decode( p_Report.FuncCurr,
                                        null,cr.currency_code,
                                         p_Report.FuncCurr )
        and ( (p_Report.trade = 'Y' and cr.type <> 'MISC')
               OR
             (p_Report.misc = 'Y'   and cr.type = 'MISC' ))
        and crh.gl_date between p_Report.GlDateFrom
               and p_Report.GldateTo
        and crh.posting_control_id > 0
        and xah.event_id = crh.event_id
        and xah.application_id = l_xah_ar_application_id
        and xah.ledger_id = cr.set_of_books_id
        and xah.ledger_id = p_Report.SetOfBooksId
        and xah.accounting_date between p_Report.GlDateFrom and p_Report.GlDateTo
        and xah.gl_transfer_status_code = 'Y'
        and xah.gl_transfer_date between p_Report.PostedDateFrom and p_Report.PostedDateTo
/* Added for bug 6647672 start */
  and NOT EXISTS ( select 'Y'
                         from xla_ae_headers xah2
                         where xah2.event_id = crh.event_id
        		 and xah2.application_id = l_xah_ar_application_id
        		 and xah2.ledger_id = cr.set_of_books_id
        		 and xah2.ledger_id = p_Report.CashSetOfBooksId
        		 and xah2.accounting_date between p_Report.GlDateFrom and p_Report.GlDateTo
        		 and xah2.gl_transfer_status_code = 'Y'
        		 and xah2.gl_transfer_date between p_Report.PostedDateFrom and p_Report.PostedDateTo ) ;
/* end bug 6647672 */
/*
        and  exists ( select 'x'
                      from igi_ar_cash_receipt_hist_all
                      where cash_receipt_history_id = crh.cash_receipt_history_id
                      and   arc_posting_control_id  = -3
                    )
        and nvl(crh.gl_posted_date,to_date('01-01-1952','DD-MM-YYYY'))
            between
               decode( p_Report.PostedDateFrom ,
                            null, nvl(crh.gl_posted_date,to_date('01-01-1952',
                                                          'DD-MM-YYYY')),
                            p_Report.PostedDateFrom )
               and
                decode( p_Report.PostedDateTo,
                            null, nvl(crh.gl_posted_date,to_date('01-01-1952',
                                                          'DD-MM-YYYY')),
                            p_Report.PostedDateTo );
*/


    EXCEPTION
        WHEN OTHERS THEN

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igircajb.IGIRCABJB.GetRxptHistory',TRUE);
           END IF;

            RAISE;
    END;
--
--
    PROCEDURE GetRecApplications(  p_Report      IN ReportParametersType ) IS
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
        SELECT
        'NEW'                                                           status,
        'A'                                                             actual_flag,
        p_Report.ReqId                                                  request_id,
        fnd_global.user_id                                              created_by,
        trunc(sysdate)                                                  date_created,
        p_Report.SetOfBooksId                                           sob_id,
        'Receivables'                                                   source,
        decode(ra.amount_applied_from,
                 null,'Trade Receipts','Cross Currency')                category,
        ra.apply_date                                                   trx_date,
        ra.gl_date                                                      gl_date,
        cr.currency_code                                                currency,
        ard.code_combination_id                                         ccid,
        ard.amount_dr                                                   entered_dr,
        ard.amount_cr                                                   entered_cr,
        ard.acctd_amount_dr                                             acctd_dr,
        ard.acctd_amount_cr                                             acctd_cr,
        decode(ard.source_type,
                'EXCH_GAIN',to_char(ard.code_combination_id),
                'EXCH_LOSS',to_char(ard.code_combination_id),
                null)                                                   ref1,
        l_cat.meaning                                                   ref10,
        to_char(p_Report.ReqId)                                           ref21,
        decode(ra.application_type,
                'CASH',to_char(cr.cash_receipt_id)||'C'||
                       to_char(ra.receivable_application_id),
                'CM', to_char(ra.receivable_application_id))            ref22,
        to_char(ard.line_id)                                            ref23,
        cr.receipt_number                                               ref24,
        ctinv.trx_number                                                ref25,
        cust.customer_number			                                ref26,  -- Bug 3902175
        to_char(cr.pay_from_customer)                                   ref27,
        decode(ra.amount_applied_from,
                  null,'TRADE','CCURR')                                 ref28,
        decode(ra.amount_applied_from,
                 null, 'TRADE_',
                       'CCURR_') || ard.source_type                     ref29,
        'AR_RECEIVABLE_APPLICATIONS'                                    ref30
        FROM
        ar_receivable_applications ra,
        ar_cash_receipts cr,
        ar_distributions ard,
        ra_customer_trx ctinv,
        ar_lookups l_cat,
        ar_posting_control pc,
        ar_system_parameters sp,
        gl_sets_of_books gl,
	(Select hz_cust_accounts.account_number customer_number,hz_cust_accounts.cust_account_id customer_id
	 from hz_parties,hz_cust_accounts where hz_parties.party_id = hz_cust_accounts.party_id) cust, -- bug 3902175
        xla_ae_headers xah
        WHERE
            ra.receivable_application_id+0 < p_Report.NxtReceivableApplicationId
        and ard.source_table = 'RA'
        and ard.source_id = ra.receivable_application_id
        and nvl(ra.postable,'Y') = 'Y'
        and nvl(ra.confirmed_flag,'Y') = 'Y'
        and ra.cash_receipt_id = cr.cash_receipt_id(+)
        and ra.applied_customer_trx_id = ctinv.customer_trx_id(+)
	and cust.customer_id(+) = cr.pay_from_customer  -- Bug 3902175
        and l_cat.lookup_type = 'ARRGTA_FUNCTION_MAPPING'
        and l_cat.lookup_code = decode(ra.amount_applied_from,
                                         null, 'TRADE_',
                                               'CCURR_') || ard.source_type
        and sp.set_of_books_id = p_Report.SetOfBooksId
        and sp.set_of_books_id = gl.set_of_books_id
        and ra.set_of_books_id = sp.set_of_books_id
        and pc.posting_control_id(+) = ra.posting_control_id
        and cr.currency_code = decode( p_Report.FuncCurr,
                                        null,cr.currency_code,
                                        p_Report.FuncCurr)
        and (p_Report.Trade = 'Y'  OR p_Report.ccurr = 'Y')
        and ra.gl_date between p_Report.GlDateFrom
                       and     p_Report.GlDateFrom
        and ra.posting_control_id > 0
        and xah.event_id = ra.event_id
        and xah.application_id = l_xah_ar_application_id
        and xah.ledger_id = ra.set_of_books_id
        and xah.ledger_id = p_Report.SetOfBooksId
        and xah.accounting_date between p_Report.GlDateFrom and p_Report.GlDateTo
        and xah.gl_transfer_status_code = 'Y'
        and xah.gl_transfer_date between p_Report.PostedDateFrom and p_Report.PostedDateTo
/* Added for bug 6647672 start */
  and NOT EXISTS ( select 'Y'
                         from xla_ae_headers xah2
                         where xah2.event_id = ra.event_id
        		 and xah2.application_id = l_xah_ar_application_id
        		 and xah2.ledger_id = ra.set_of_books_id
        		 and xah2.ledger_id = p_Report.CashSetOfBooksId
        		 and xah2.accounting_date between p_Report.GlDateFrom and p_Report.GlDateTo
        		 and xah2.gl_transfer_status_code = 'Y'
        		 and xah2.gl_transfer_date between p_Report.PostedDateFrom and p_Report.PostedDateTo )
/* end bug 6647672 */
/*        and exists ( select 'x'
                     from igi_ar_rec_applications_all
                     where receivable_application_id = ra.receivable_application_id
                     and  arc_posting_control_id = -3
                   )
        and nvl(ra.gl_posted_date,to_date('01-01-1952','DD-MM-YYYY'))
               between
                decode( p_Report.PostedDateTo ,
                            null, nvl(ra.gl_posted_date,to_date('01-01-1952',
                                                          'DD-MM-YYYY')),
                            fnd_date.canonical_to_date(p_Report.PostedDateTo))
               and
                decode( p_Report.PostedDateTo,
                            null, nvl(ra.gl_posted_date,to_date('01-01-1952',
                                                          'DD-MM-YYYY')),
                            fnd_date.canonical_to_date(p_Report.PostedDateTo))
*/
        UNION ALL
        SELECT
        'NEW'                                                           status,
        'A'                                                             actual_flag,
        p_Report.ReqId                                                    request_id,
        fnd_global.user_id                                                       created_by,
        trunc(sysdate)                                                  date_created,
        p_Report.SetOfBooksId                                                        sob_id,
        'Receivables'                                                   source,
        'Credit Memo Applications'                                      category,
        ra.apply_date                                                   trx_date,
        ra.gl_date                                                      gl_date,
        ctcm.invoice_currency_code                                      currency,
        ard.code_combination_id                                         ccid,
        ard.amount_dr                                                   entered_dr,
        ard.amount_cr                                                   entered_cr,
        ard.acctd_amount_dr                                             acctd_dr,
        ard.acctd_amount_cr                                             acctd_cr,
        decode(ard.source_type,
                'EXCH_GAIN',to_char(ard.code_combination_id),
                'EXCH_LOSS',to_char(ard.code_combination_id),
                null)                                                   ref1,
        l_cat.meaning                                                   ref10,
        to_char(p_Report.ReqId)                                           ref21,
        to_char(ra.receivable_application_id)                           ref22,
        to_char(ard.line_id)                                            ref23,
        ctcm.trx_number                                                 ref24,
        ctinv.trx_number                                                ref25,
        hz_cust_accounts.account_number                                 ref26, -- Bug 3902175
        to_char(ctcm.bill_to_customer_id)                               ref27,
        'CMAPP'                                                         ref28,
        'CMAPP_' || ard.source_type                                     ref29,
        'AR_RECEIVABLE_APPLICATIONS'                                    ref30
        FROM
        ar_receivable_applications ra,
        ra_customer_trx ctcm,
        ar_distributions ard,
        ra_cust_trx_line_gl_dist ctlgdcm,
        ra_customer_trx ctinv,
        ar_lookups l_cat,
        ar_posting_control pc,
        ar_system_parameters sp,
        gl_sets_of_books gl,
	hz_parties,
	hz_cust_accounts,
        xla_ae_headers xah
        WHERE
            ra.receivable_application_id+0 < p_Report.NxtReceivableApplicationId
        and ard.source_table = 'RA'
        and ard.source_id = ra.receivable_application_id
        and nvl(ra.postable,'Y') = 'Y'
        and nvl(ra.confirmed_flag,'Y') = 'Y'
        and ra.status||'' = 'APP'
        and ra.customer_trx_id = ctcm.customer_trx_id
        and ra.customer_trx_id = ctlgdcm.customer_trx_id
        and ctlgdcm.account_class = 'REC'
        and ctlgdcm.latest_rec_flag = 'Y'
        and ra.applied_customer_trx_id = ctinv.customer_trx_id
	and hz_parties.party_id = hz_cust_accounts.party_id -- Bug 3902175
        and hz_cust_accounts.cust_account_id = ctcm.bill_to_customer_id -- Bug 3902175
        and l_cat.lookup_type = 'ARRGTA_FUNCTION_MAPPING'
        and l_cat.lookup_code = 'CMAPP_' || ard.source_type
        and sp.set_of_books_id = p_Report.SetOfBooksId
        and sp.set_of_books_id = gl.set_of_books_id
        and ra.set_of_books_id = sp.set_of_books_id
        and pc.posting_control_id(+) = ra.posting_control_id
        and ctcm.invoice_currency_code = decode( p_Report.FuncCurr,
                                        null,ctcm.invoice_currency_code,
                                        p_Report.FuncCurr)
        and p_Report.CMApp = 'Y'
        and ra.gl_date between p_Report.GlDateFrom
               and  p_Report.GLDateTo
        and ra.posting_control_id > 0
        and xah.event_id = ra.event_id
        and xah.application_id = l_xah_ar_application_id
        and xah.ledger_id = ra.set_of_books_id
        and xah.ledger_id = p_Report.SetOfBooksId
        and xah.accounting_date between p_Report.GlDateFrom and p_Report.GlDateTo
        and xah.gl_transfer_status_code = 'Y'
        and xah.gl_transfer_date between p_Report.PostedDateFrom and p_Report.PostedDateTo
/* Added for bug 6647672 start */
  and NOT EXISTS ( select 'Y'
                         from xla_ae_headers xah2
                         where xah2.event_id = ra.event_id
        		 and xah2.application_id = l_xah_ar_application_id
        		 and xah2.ledger_id = ra.set_of_books_id
        		 and xah2.ledger_id = p_Report.CashSetOfBooksId
        		 and xah2.accounting_date between p_Report.GlDateFrom and p_Report.GlDateTo
        		 and xah2.gl_transfer_status_code = 'Y'
        		 and xah2.gl_transfer_date between p_Report.PostedDateFrom and p_Report.PostedDateTo );
/* end bug 6647672 */
/*        and exists ( select 'x'
                     from igi_ar_rec_applications_all
                     where receivable_application_id = ra.receivable_application_id
                     and  arc_posting_control_id = -3
                   )
        and nvl(ra.gl_posted_date,to_date('01-01-1952','DD-MM-YYYY'))
               between
               decode( p_Report.PostedDateTo ,
                            null, nvl(ra.gl_posted_date,to_date('01-01-1952',
                                                          'DD-MM-YYYY')),
                            fnd_date.canonical_to_date(p_Report.PostedDateTo))
               and
               decode( p_Report.PostedDateTo,
                            null, nvl(ra.gl_posted_date,to_date('01-01-1952',
                                                          'DD-MM-YYYY')),
                            fnd_date.canonical_to_date(p_Report.PostedDateTo));
*/

    EXCEPTION
        WHEN OTHERS THEN

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igircajb.IGIRCABJP.GetRecApplications',TRUE);
           END IF;
            RAISE;
    END;
--
    PROCEDURE GetMiscCashDists( p_Report IN ReportParametersType  ) IS
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
        'NEW'                                                   status,
        'A'                                                     actual_flag,
        p_Report.ReqId                                            request_id,
        fnd_global.user_id                                               created_by,
        trunc(sysdate)                                          date_created,
        p_Report.SetOfBooksId                                                sob_id,
        'Receivables'                                           source_name,
        'Misc Receipts'                                         category,
        mcd.apply_date                                          trx_date,
        mcd.gl_date                                             gl_date,
        cr.currency_code                                        currency,
        mcd.code_combination_id                                 ccid,
        ard.amount_dr                                           entered_dr,
        ard.amount_cr                                           entered_cr,
        ard.acctd_amount_dr                                     acctd_dr,
        ard.acctd_amount_cr                                     acctd_cr,
        l_cat.meaning                                           ref10,
        to_char(p_Report.ReqId)                                   ref21,
        to_char(cr.cash_receipt_id)                             ref22,
        to_char(ard.line_id)                                    ref23,
        cr.receipt_number                                       ref24,
        to_char(mcd.misc_cash_distribution_id)                  ref25,
        null                                                    ref26,
        null                                                    ref27,
        'MISC'                                                  ref28,
        'MISC_' || ard.source_type                              ref29,
        'AR_MISC_CASH_DISTRIBUTIONS'                            ref30
        FROM
        ar_misc_cash_distributions mcd,
        ar_distributions ard,
        ar_cash_receipts cr,
        ar_lookups l_cat,
        xla_ae_headers xah
        WHERE mcd.misc_cash_distribution_id+0 < p_Report.NxtMiscCashDistributionId
        and mcd.set_of_books_id = p_Report.SetOfBooksId
        and mcd.cash_receipt_id = cr.cash_receipt_id
        and ard.source_table = 'MCD'
        and ard.source_id = mcd.misc_cash_distribution_id
        and l_cat.lookup_type = 'ARRGTA_FUNCTION_MAPPING'
        and l_cat.lookup_code = 'MISC_' || ard.source_type
        and cr.currency_code = decode( p_Report.FuncCurr,
                                        null,cr.currency_code,
                                        p_Report.FuncCurr)
        and p_Report.Misc = 'Y'
        and mcd.gl_date between
                      p_Report.GlDateFrom
               and
                      p_Report.GlDateTo
        and ( mcd.posting_control_id > 0 )
        and xah.event_id = mcd.event_id
        and xah.application_id = l_xah_ar_application_id
        and xah.ledger_id = mcd.set_of_books_id
        and xah.ledger_id = p_Report.SetOfBooksId
        and xah.accounting_date between p_Report.GlDateFrom and p_Report.GlDateTo
        and xah.gl_transfer_status_code = 'Y'
        and xah.gl_transfer_date between p_Report.PostedDateFrom and p_Report.PostedDateTo
/* Added for bug 6647672 start */
  and NOT EXISTS ( select 'Y'
                         from xla_ae_headers xah2
                         where xah2.event_id = mcd.event_id
        		 and xah2.application_id = l_xah_ar_application_id
        		 and xah2.ledger_id = mcd.set_of_books_id
        		 and xah2.ledger_id = p_Report.CashSetOfBooksId
        		 and xah2.accounting_date between p_Report.GlDateFrom and p_Report.GlDateTo
        		 and xah2.gl_transfer_status_code = 'Y'
        		 and xah2.gl_transfer_date between p_Report.PostedDateFrom and p_Report.PostedDateTo );
/* end bug 6647672 */
/*        and exists ( select 'x'
                     from igi_ar_misc_cash_dists_all
                     where misc_cash_distribution_id = mcd.misc_cash_distribution_id
                     and  arc_posting_control_id = -3
                   )
        and nvl(mcd.gl_posted_date,to_date('01-01-1952','DD-MM-YYYY'))
               between
               decode( p_Report.PostedDateTo ,
                            null, nvl(mcd.gl_posted_date,to_date('01-01-1952',
                                                          'DD-MM-YYYY')),
                            fnd_date.canonical_to_date(p_Report.PostedDateTo))
               and
               decode(  p_Report.PostedDateTo,
                            null, nvl(mcd.gl_posted_date,to_date('01-01-1952',
                                                          'DD-MM-YYYY')),
                            fnd_date.canonical_to_date(p_Report.PostedDateTo));
*/

    EXCEPTION
        WHEN OTHERS THEN

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igircajb.IGIRCABJB.GetMiscCashDates',TRUE);
           END IF;

           RAISE;
    END;
--

--
    PROCEDURE CheckBalance( p_Report IN ReportParametersType ) IS
        CURSOR CBal  IS
        select
        max(je_category_name)                        cat_name,
        max(currency_code)                           curr_code,
        max(accounting_date)                         acctg_date,
        max(nvl(reference24,reference25))            trx_num,
        reference28                                  cat_code,
        decode(instr(reference22,'C'),0, reference22,
               substr(reference22,1,instr(reference22,'C')-1))
                                                     balance_id,
        nvl(sum(nvl(entered_dr,0)),0)                entered_dr,
        nvl(sum(nvl(entered_cr,0)),0)                entered_cr,
        nvl(sum(nvl(accounted_dr,0)),0)              accounted_dr,
        nvl(sum(nvl(accounted_cr,0)),0)              accounted_cr
        from igi_ar_journal_interim
        where je_source_name = 'Receivables'
        and   set_of_books_id = p_Report.SetOfBooksId
        and   request_id = p_Report.ReqId
        group by
        reference28,
        decode(instr(reference22,'C'),0, reference22,
               substr(reference22,1,instr(reference22,'C')-1))
        having
        ( nvl(sum(nvl(entered_dr,0)),0)<> nvl(sum(nvl(entered_cr,0)),0)
          OR
          nvl(sum(nvl(accounted_dr,0)),0)<> nvl(sum(nvl(accounted_cr,0)),0));
--
    BEGIN
--
--
        FOR RBal IN CBal
        LOOP
           delete from igi_ar_journal_interim iaji
           where  iaji.je_source_name = 'Receivables'
           and    iaji.set_of_books_id = p_Report.SetOfBooksId
           and    iaji.request_id      = p_Report.ReqID
           and    iaji.reference23     = RBal.balance_id
           and    iaji.reference28     = RBal.cat_code
           and    iaji.je_category_name = RBal.cat_name
           ;
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igircajb.IGIRCABJP.CheckBalance',TRUE);
           END IF;

           RAISE;
    END;
--
    PROCEDURE Report( p_Report       IN ReportParametersType ) IS
    BEGIN

        IF (l_proc_level >=  l_debug_level ) THEN
            FND_LOG.STRING  (l_proc_level , 'igi.plsql.igircajb.IGIRCABJP.Report',
                          ' Begin Accrual reconciliation program ');
        END IF;

        GetAdjustments  ( p_Report );
        GetTxnDistributions(  p_Report   );
        GetRxptHistory( p_Report );
        GetRecApplications(  p_Report );
        GetMiscCashDists( p_Report   );
--
        IF p_Report.ChkBalance = 'Y' AND
           p_Report.PostedStatus <> 'POSTED'
        THEN
                IF (l_state_level >=  l_debug_level ) THEN
                   FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.Report',
                          '  >> Check the Balance ');
                END IF;
                CheckBalance( p_Report );
        END IF;

        IF (l_proc_level >=  l_debug_level ) THEN
            FND_LOG.STRING  (l_proc_level , 'igi.plsql.igircajb.IGIRCABJP.Report',
                          ' End Accrual reconciliation program ');
        END IF;

    EXCEPTION
        WHEN OTHERS THEN

            IF ( l_unexp_level >= l_debug_level ) THEN

                FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
                FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igircajb.IGIRCABJP.Report',TRUE);
            END IF;

            RAISE_APPLICATION_ERROR( -20000, sqlerrm||'$Revision: 120.8.12000000.5 $:Report( p_Report ):' );
    END;
--
FUNCTION SubmitReconcileReport ( p_request_id   in number
                               , p_sob_id       in number
                               , p_coa          in number
                               , p_start_period in varchar2
                               , p_end_period   in varchar2
                               , p_start_date   in date
                               , p_end_date     in date
                               , p_account_segment_from in varchar2
                               , p_account_segment_to in varchar2
                               )
RETURN NUMBER IS
l_RequestId NUMBER(15);
l_yes varchar2(1);
l_segment_name varchar2(40);
NOT_SUBMITTED   EXCEPTION;
BEGIN
-- Bug 3902175 GSCC warnings Fixed
l_yes := 'Y';

  select distinct substr(application_column_name, 1, 15)
  into   l_segment_name
  from   fnd_segment_attribute_values
  where  segment_attribute_type = 'GL_ACCOUNT'
  and    attribute_value = 'Y'
  and    id_flex_num     = p_coa
  ;

    l_RequestId := FND_REQUEST.SUBMIT_REQUEST
        ( 'IGI'
        , 'IGIRCCBR'
        , null
        , null
        , FALSE          -- Is a sub request
        , 'P_REQUEST_ID='||p_request_id
        , 'P_SOB_ID='||p_sob_id
        , 'P_SEG_NAME='||l_segment_name
        , 'P_START_DATE='||p_start_date
        , 'P_END_DATE='||p_end_date
        , 'P_START_PERIOD='||p_start_period
        , 'P_END_PERIOD='||p_end_period
        , 'P_ACCOUNT_SEGMENT_FROM='||p_account_segment_from
        , 'P_ACCOUNT_SEGMENT_TO='||p_account_segment_to
        );
    IF l_RequestId = 0 THEN
      RAISE NOT_SUBMITTED;
    END IF;

    commit;
    RETURN (l_RequestId);

    EXCEPTION
        WHEN OTHERS THEN
   --bug 3199481 fnd logging changes: sdixit: start block
      --standard way to handle when-others as per FND logging guidelines
      --FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
      --retcode := 2;
      --errbuf :=  Fnd_message.get;

          IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igircajb.IGIRCABJB.SubmitReconcileReport',TRUE);
          END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

             RETURN (l_RequestId);
end;

--
PROCEDURE ReportOutput
        ( p_Report IN ReportParametersType
        ) IS
l_Reconcile   NUMBER(15);
l_wait      BOOLEAN;
l_phase     varchar2(20);
l_status        varchar2(20);
l_dev_phase     varchar2(20);
l_dev_status        varchar2(20);
l_message       varchar2(240);
begin
--
--

        l_reconcile := SubmitReconcileReport
            ( p_report.ReqId, p_Report.SetOfBooksId
            , p_report.ChartOfAccountsId
            , p_report.StartPeriod
            , p_report.Endperiod
            , p_report.GLDateFrom
            , p_report.GLDateTo
            , p_report.AccountSegmentFrom
            , p_report.AccountSegmentTo
            );

--
-- Update each child in turn, waiting for each to complete.
--
    IF nvl(l_reconcile, 0) > 0 THEN
        l_wait := fnd_concurrent.wait_for_request
            ( l_reconcile
            , 30
            , 0
            , l_phase
            , l_status
            , l_dev_phase
            , l_dev_status
            , l_message
            );
    END IF;
    commit;
--
    EXCEPTION
        WHEN OTHERS THEN
   --bug 3199481 fnd logging changes: sdixit: start block
            --WriteToLogFile( 'Error Submitting Output Reports' );
            --standard way to handle when-others as per FND logging guidelines

            IF ( l_unexp_level >= l_debug_level ) THEN

                FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
                FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igircajb.IGIRCABJP.ReportQutput',TRUE);
            END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
            RAISE;
end;

    PROCEDURE ReportCBR
                ( errbuf                OUT NOCOPY     VARCHAR2
                , retcode               OUT NOCOPY     NUMBER
                , p_DataAccessSetId             NUMBER
                , p_SetOfBooksId                NUMBER
                , p_CashSetOfBooksId            NUMBER   -- CBR AR change
                , p_ChartOfAccountsId           NUMBER
                , p_PostedStatus                VARCHAR2
                , p_PeriodFrom                  VARCHAR2
                , p_PeriodTo                    VARCHAR2
                , p_AccountSegmentFrom          VARCHAR2
                , p_AccountSegmentTo            VARCHAR2
                ) IS
    l_Report  ReportParametersType;
    l_accrual_ct   Number;
    l_cash_ct      Number;

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


          FUNCTION GetStartDate ( p_period_name in varchar2
                                , p_sob_id      in number
                                )
          return   DATE
          IS
             cursor c_date is
                select start_date
                from   gl_period_statuses
                where  set_of_books_id = p_sob_id
                and    period_name    =  p_period_name
                and    application_id = ( select application_id
                                          from   fnd_application
                                          where  application_short_name = 'AR'
                                        );
          BEGIN
             for l_date in c_date loop
                 return l_date.start_date;
             end loop;
             return sysdate;
          END  GetStartDate;

          FUNCTION GetEndDate ( p_period_name in varchar2
                                , p_sob_id      in number
                                )
          return   DATE
          IS
             cursor c_date is
                select end_date
                from   gl_period_statuses
                where  set_of_books_id = p_sob_id
                and    period_name    =  p_period_name
                and    application_id = ( select application_id
                                          from   fnd_application
                                          where  application_short_name = 'AR'
                                        );
          BEGIN
             for l_date in c_date loop
                 return l_date.end_date;
             end loop;
             return sysdate-1;
          END  GetEndDate;


    BEGIN
--
-- Variables set by parameters passed through from post procedure
--
        IF (l_proc_level>=  l_debug_level ) THEN
            FND_LOG.STRING  (l_proc_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                          'Start procedure IGIRCABJP.ReportCBR');
        END IF;

        l_Report.GlDateFrom := GetStartDate( p_PeriodFrom, p_setofBooksid );
        l_Report.GlDateTo := GetEndDate( p_PeriodTo, p_setofBooksid );
        l_Report.SetOfBooksId := p_SetOfBooksId;
        l_Report.CashSetOfBooksId := p_CashSetOfBooksId;
        l_Report.StartPeriod := p_PeriodFrom;
        l_Report.EndPeriod := p_PeriodTo;

        select currency_code
        into   l_Report.Currency
        from   gl_sets_of_books
        where  set_of_books_id = p_SetOfBooksId
        ;

        select currency_code
        into   l_Report.FuncCurr
        from   gl_sets_of_books
        where  set_of_books_id = p_CashSetOfBooksId
        ;

        l_Report.CMApp := 'Y';
        l_Report.Adj := 'Y';
        l_Report.Trade := 'Y';
        l_Report.Misc := 'Y';
        l_Report.CCurr := 'Y';

        l_Report.DetailByAccount	:= 'N';
        l_Report.DetailByCategory	:= 'N';
        l_Report.SummaryByAccount	:= 'N';
        l_Report.SummaryByCategory	:= 'N';
        l_Report.ChartOfAccountsID	:= p_ChartOfAccountsId;
        l_Report.AccountSegmentFrom	:= p_AccountSegmentFrom;
        l_Report.AccountSegmentTo	:= p_AccountSegmentTo;


--
-- Get the report request ID
--
        FND_PROFILE.GET ('CONC_REQUEST_ID', l_report.ReqId);
        IF l_report.ReqId IS NULL	-- Not run through conc manager
        THEN l_report.ReqId := 0;
        END IF;

       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                       ' ConcRequestID '|| l_Report.ReqID );
       END IF;

--
-- Variables set from ar_system_parameters
--

/* Check for arc_unalloc_rev_ccid -- *CBRAP*
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
 Check for arc_unalloc_rev_ccid -- *CBRAP* */

           IF l_Report.CashSetOfBooksId is null THEN

              IF (l_state_level >=  l_debug_level ) THEN
                  FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                          'Accrual Set Of books '|| p_SetOfBooksID );
                  FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                          'Cash Set of Books ID is not input');
              END IF;

              errbuf := 'Cash Set of Books Parameter is not input';
              retcode := 2;
              return;
           END IF;
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

IF (l_state_level >=  l_debug_level ) THEN
    FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                          '----------------BEGIN PARAMETERS-----------------------------------');
    FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                          ' NxtCashReceiptHistoryId '|| l_Report.NxtCashReceiptHistoryId );
    FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                          ' NxtReceivableApplicationId '|| l_Report.NxtReceivableApplicationId );
    FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                          ' NxtMiscCashDistributionId '|| l_Report.NxtMiscCashDistributionId );
    FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                          ' NxtAdjustmentId '|| l_Report.NxtAdjustmentId );
    FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                          ' NxtCustTrxLineGlDistId '|| l_Report.NxtCustTrxLineGlDistId );
    FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                          ' Posted Status '||p_PostedStatus);
    FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                          ' ----------------END PARAMETERS-----------------------------------');
    FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                              ' l_Report.GlDateFrom '|| l_Report.GlDateFrom );

    FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                              ' l_Report.GlDateTo '|| l_Report.GlDateTo );

    FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                              ' l_Report.SetOfBooksId '|| l_Report.SetOfBooksId );

    FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                              ' l_Report.CashSetOfBooksId '|| l_Report.CashSetOfBooksId );

    FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                              ' l_Report.StartPeriod '|| l_Report.StartPeriod );

    FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                              ' l_Report.EndPeriod '|| l_Report.EndPeriod );

    FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                              ' l_Report.Currency '|| l_Report.Currency );

    FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                              ' l_Report.FuncCurr '|| l_Report.FuncCurr );

END IF;


--
-- Hard Coded variables
--
        l_Report.ChkBalance := 'N';
        l_Report.CreatedBy := fnd_global.user_id;
--
--
        IF  DebugMode THEN
           delete from igi_ar_journal_interim
        --   where  request_id = l_Report.ReqId
           ;
        END IF;

        IF (l_state_level >=  l_debug_level ) THEN
            FND_LOG.STRING  (l_state_level ,'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                          'Synchronize AR data with ARC data -> IGIRCBID.prepare');
        END IF;

      /* Commented below code for bug 6647672 */
      /*  IGIRCBID.Prepare ( l_Report.GlDateFrom, l_Report.GlDateTo, l_Report.GlDateFrom,
                           l_Report.SetOfBooksId, l_Report.CashSetOfBooksId); */


        IF (l_state_level >=  l_debug_level ) THEN
            FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                          'Get accrual data into IGI_AR_JOURNAL_INTERIM ');
        END IF;

       IF l_Report.PostedDateFrom IS NULL THEN
          l_Report.PostedDateFrom := to_date('01-01-1952', 'DD-MM-YYYY');
       END IF;
       IF l_Report.PostedDateTo IS NULL THEN
          l_Report.PostedDateTo := SYSDATE;
       END IF;


        l_report.CallingMode  := 'ARC';
        l_report.PostedStatus := 'POSTED';
        Report( l_Report );  -- Get Accrual Data
        l_accrual_ct := CountInterimJournals ( l_Report.reqid );

        IF (l_state_level >=  l_debug_level ) THEN
            FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                          'Number of records processed Primary Ledger (accrual) is '||to_char(l_accrual_ct) );
        END IF;

         /* Commented below code for bug 6647672 */
       /*  l_Report.CallingMode := 'CBR';
        l_Report.PostedStatus := 'UNPOSTED';
        IGIRCBJP.Report ( l_report );  -- Get Cash Data
        l_cash_ct := CountInterimJournals ( l_Report.reqid );
        l_cash_ct := l_cash_ct - l_accrual_ct;

        IF (l_state_level >=  l_debug_level ) THEN
           FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                          'Number of records processed Secondary Ledger (Cash) is '||to_char(l_cash_ct) );
        END IF;  */

        IF (l_state_level >=  l_debug_level ) THEN
           FND_LOG.STRING  (l_state_level ,'igi.plsql.igircajb.IGIRCABJP.ReportCBR','');
           FND_LOG.STRING  (l_state_level ,'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                          'Create data into CBR interface table -> IGI_CBR_ARC_INTERFACE_PKG.Insert_rows');
        END IF;


        IGI_CBR_ARC_INTERFACE_PKG.Insert_Rows (l_Report.reqid, l_Report.CashSetOfBooksId);

        IF (l_state_level >=  l_debug_level ) THEN
           FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                   'Submit the Reports');
        END IF;

        ReportOutput (l_Report);

        IF (l_state_level >=  l_debug_level ) THEN
           FND_LOG.STRING  (l_state_level , 'igi.plsql.igircajb.IGIRCABJP.ReportCBR',
                          'Delete records from IGI_AR_JOURNAL_INTERIM (IF not debug)');
        END IF;


        IF NOT DebugMode THEN
           delete from igi_ar_journal_interim
           where  request_id = l_Report.ReqId
           ;
        END IF;

        delete from igi_cbr_arc_interface
        where request_id = l_Report.ReqId
        ;
        commit;

        errbuf := 'Successful Completion';
        retcode := 0;

    EXCEPTION
        WHEN OTHERS THEN

      FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
      retcode := 2;
      errbuf :=  Fnd_message.get;

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igircajb.IGIRCABJP.ReportCBR',TRUE);
           END IF;

            RAISE;
    END;
BEGIN

   DebugMode    := FALSE;

   l_debug_level 	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level 	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level  	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level 	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level 	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level 	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level 	:=	FND_LOG.LEVEL_UNEXPECTED;

END IGIRCABJP;

/
