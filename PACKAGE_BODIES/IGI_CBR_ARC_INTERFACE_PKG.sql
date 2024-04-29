--------------------------------------------------------
--  DDL for Package Body IGI_CBR_ARC_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CBR_ARC_INTERFACE_PKG" as
 /* $Header: igircbib.pls 120.5 2008/02/15 10:04:01 sharoy ship $ */


     PROCEDURE Insert_Rows(p_request_id     NUMBER, p_CashSetOfBooksId NUMBER)
       IS

        BEGIN

            INSERT INTO igi_cbr_arc_interface
            (SEGMENT1
            ,SEGMENT2
            ,SEGMENT3
            ,SEGMENT4
            ,SEGMENT5
            ,SEGMENT6
            ,SEGMENT7
            ,SEGMENT8
            ,SEGMENT9
            ,SEGMENT10
            ,SEGMENT11
            ,SEGMENT12
            ,SEGMENT13
            ,SEGMENT14
            ,SEGMENT15
            ,SEGMENT16
            ,SEGMENT17
            ,SEGMENT18
            ,SEGMENT19
            ,SEGMENT20
            ,SEGMENT21
            ,SEGMENT22
            ,SEGMENT23
            ,SEGMENT24
            ,SEGMENT25
            ,SEGMENT26
            ,SEGMENT27
            ,SEGMENT28
            ,SEGMENT29
            ,SEGMENT30
            ,REQUEST_ID
            ,CURRENCY_CODE
            ,DOC_SEQ_NUM
            ,TRANS_NUMBER
            ,CUSTOMER_NUMBER
            ,CUSTOMER_NAME
            ,ACCOUNTING_DATE
            ,AMOUNT
            )

            SELECT

             SEGMENT1
            ,SEGMENT2
            ,SEGMENT3
            ,SEGMENT4
            ,SEGMENT5
            ,SEGMENT6
            ,SEGMENT7
            ,SEGMENT8
            ,SEGMENT9
            ,SEGMENT10
            ,SEGMENT11
            ,SEGMENT12
            ,SEGMENT13
            ,SEGMENT14
            ,SEGMENT15
            ,SEGMENT16
            ,SEGMENT17
            ,SEGMENT18
            ,SEGMENT19
            ,SEGMENT20
            ,SEGMENT21
            ,SEGMENT22
            ,SEGMENT23
            ,SEGMENT24
            ,SEGMENT25
            ,SEGMENT26
            ,SEGMENT27
            ,SEGMENT28
            ,SEGMENT29
            ,SEGMENT30
            ,REQUEST_ID
            ,CURRENCY_CODE
            ,DOC_SEQ_NUM
            ,TRANS_NUMBER
            ,CUSTOMER_NUMBER
            ,CUSTOMER_NAME
            ,ACCOUNTING_DATE
            ,AMOUNT

            FROM (SELECT c.SEGMENT1, c.SEGMENT2, c.SEGMENT3, c.SEGMENT4, c.SEGMENT5,
       c.SEGMENT6, c.SEGMENT7, c.SEGMENT8, c.SEGMENT9, c.SEGMENT10,
       c.SEGMENT11, c.SEGMENT12, c.SEGMENT13, c.SEGMENT14, c.SEGMENT15,
       c.SEGMENT16, c.SEGMENT17, c.SEGMENT18, c.SEGMENT19, c.SEGMENT20,
       c.SEGMENT21, c.SEGMENT22, c.SEGMENT23, c.SEGMENT24, c.SEGMENT25,
       c.SEGMENT26, c.SEGMENT27, c.SEGMENT28, c.SEGMENT29, c.SEGMENT30,
       rep.request_id, rep.currency_code, rct.doc_sequence_value doc_seq_num,
       rep.reference25 trans_number, rep.reference26 customer_number,
       hz.party_name customer_name, rep.accounting_date,
       decode(rep.reference30||rep.reference29 , 'AR_ADJUSTMENTSADJ_ADJ' ,
       nvl(rep.accounted_cr, 0)-nvl(rep.accounted_dr, 0) , 0 ) amount
FROM   IGI_AR_JOURNAL_INTERIM rep, IGI_CBR_ARC_RECONCILE_V aat,
       AR_ADJUSTMENTS aad, RA_CUSTOMER_TRX rct, HZ_PARTIES hz,
       HZ_CUST_ACCOUNTS hca, GL_CODE_COMBINATIONS c, AR_LOOKUPS l
WHERE  rep.CODE_COMBINATION_ID = c.code_combination_id(+)
AND    l.lookup_type = 'ARRGTA_CATEGORIES'
AND    rep.reference28 = l.lookup_code
AND    rep.reference25 = aat.trans_num
AND    rep.reference25 = rct.trx_number
AND    rep.reference22 = to_char(aad.adjustment_id)
AND    (rep.accounted_cr <> 0 OR rep.accounted_dr <> 0)
AND    rep.reference25 is not null
AND    rep.reference29 = 'ADJ_ADJ'
AND    rep.reference30 = 'AR_ADJUSTMENTS'
AND    rep.reference26 = hca.account_number
AND    hz.party_id = hca.party_id
AND    nvl(rep.accounted_dr,0)-nvl(rep.accounted_cr,0) <> 0
UNION
SELECT c.SEGMENT1, c.SEGMENT2, c.SEGMENT3, c.SEGMENT4, c.SEGMENT5,
       c.SEGMENT6, c.SEGMENT7, c.SEGMENT8, c.SEGMENT9, c.SEGMENT10,
       c.SEGMENT11, c.SEGMENT12, c.SEGMENT13, c.SEGMENT14, c.SEGMENT15,
       c.SEGMENT16, c.SEGMENT17, c.SEGMENT18, c.SEGMENT19, c.SEGMENT20,
       c.SEGMENT21, c.SEGMENT22, c.SEGMENT23, c.SEGMENT24, c.SEGMENT25,
       c.SEGMENT26, c.SEGMENT27, c.SEGMENT28, c.SEGMENT29, c.SEGMENT30,
       rep.request_id, rep.currency_code, rct.doc_sequence_value doc_seq_num,
       rep.reference25 trans_number, rep.reference26 customer_number,
       hz.party_name customer_name, rep.accounting_date,
       decode(rep.reference30||rep.reference29 ,'AR_RECEIVABLE_APPLICATIONSTRADE_GL' ,
       nvl(rep.accounted_cr,0)-nvl(rep.accounted_dr,0) , 0 ) amount
FROM   IGI_AR_JOURNAL_INTERIM rep, IGI_CBR_ARC_RECONCILE_V aat,
       AR_CASH_RECEIPTS acr, RA_CUSTOMER_TRX rct, HZ_PARTIES hz, HZ_CUST_ACCOUNTS hca,
       GL_CODE_COMBINATIONS c, AR_LOOKUPS l
WHERE  rep.CODE_COMBINATION_ID = c.code_combination_id(+)
AND l.lookup_type = 'ARRGTA_CATEGORIES'
AND rep.reference28 = l.lookup_code
AND rep.reference25 = aat.trans_num
AND rep.reference25 = rct.trx_number
AND rep.reference22 = to_char(acr.cash_receipt_id)
AND (rep.accounted_cr <> 0 OR rep.accounted_dr <> 0)
AND rep.reference25 is not null
AND rep.reference29 = 'TRADE_GL'
AND rep.reference30 = 'AR_RECEIVABLE_APPLICATIONS'
AND rep.reference26 = hca.account_number
AND hca.party_id = hz.party_id
AND nvl(rep.accounted_dr,0)-nvl(rep.accounted_cr,0) <> 0
UNION
SELECT c.SEGMENT1, c.SEGMENT2, c.SEGMENT3, c.SEGMENT4, c.SEGMENT5,
       c.SEGMENT6, c.SEGMENT7, c.SEGMENT8, c.SEGMENT9, c.SEGMENT10,
       c.SEGMENT11, c.SEGMENT12, c.SEGMENT13, c.SEGMENT14, c.SEGMENT15,
       c.SEGMENT16, c.SEGMENT17, c.SEGMENT18, c.SEGMENT19, c.SEGMENT20,
       c.SEGMENT21, c.SEGMENT22, c.SEGMENT23, c.SEGMENT24, c.SEGMENT25,
       c.SEGMENT26, c.SEGMENT27, c.SEGMENT28, c.SEGMENT29, c.SEGMENT30,
       rep.request_id, rep.currency_code, rct.doc_sequence_value doc_seq_num,
       rep.reference25 trans_number, rep.reference26 customer_number,
       hz.party_name customer_name, nvl(rep.accounting_date,sysdate),
       decode(rep.reference30||rep.reference29 ,'RA_CUST_TRX_LINE_GL_DISTINV_REV' ,
       nvl(rep.accounted_cr,0)-nvl(rep.accounted_dr,0) ,'RA_CUST_TRX_LINE_GL_DISTINV_TAX' ,
       nvl(rep.accounted_cr,0)-nvl(rep.accounted_dr,0) ,'RA_CUST_TRX_LINE_GL_DISTCM_TAX' ,
       nvl(rep.accounted_cr,0)-nvl(rep.accounted_dr,0) ,'RA_CUST_TRX_LINE_GL_DISTCM_REV' ,
       nvl(rep.accounted_cr,0)-nvl(rep.accounted_dr,0) , 0 ) amount
FROM   IGI_AR_JOURNAL_INTERIM rep, HZ_PARTIES hz,  HZ_CUST_ACCOUNTS hca,
       RA_CUSTOMER_TRX rct, IGI_CBR_ARC_RECONCILE_V aat,
       GL_CODE_COMBINATIONS c, AR_LOOKUPS l
WHERE  rep.CODE_COMBINATION_ID = c.code_combination_id(+)
AND l.lookup_type = 'ARRGTA_CATEGORIES'
AND rep.reference28 = l.lookup_code
AND rep.reference25 = aat.trans_num
AND rep.reference25 = rct.trx_number
 AND rep.reference22 = to_char(rct.customer_trx_id)
 AND (nvl(rep.accounted_cr,0) <> 0 OR nvl(rep.accounted_dr,0) <> 0 )
AND rep.reference25 is not null
AND rep.reference29 <> 'INV_REC'
AND rep.reference29 <> 'CM_REC' AND rep.reference30 = 'RA_CUST_TRX_LINE_GL_DIST'
AND rep.reference26 = hca.account_number
AND hz.party_id = hca.party_id
AND nvl(rep.accounted_dr,0) - nvl(rep.accounted_cr,0) <> 0
UNION
SELECT c.SEGMENT1, c.SEGMENT2, c.SEGMENT3, c.SEGMENT4, c.SEGMENT5,
       c.SEGMENT6, c.SEGMENT7, c.SEGMENT8, c.SEGMENT9, c.SEGMENT10,
       c.SEGMENT11, c.SEGMENT12, c.SEGMENT13, c.SEGMENT14, c.SEGMENT15,
       c.SEGMENT16, c.SEGMENT17, c.SEGMENT18, c.SEGMENT19, c.SEGMENT20,
       c.SEGMENT21, c.SEGMENT22, c.SEGMENT23, c.SEGMENT24, c.SEGMENT25,
       c.SEGMENT26, c.SEGMENT27, c.SEGMENT28, c.SEGMENT29, c.SEGMENT30,
       rep.request_id, rep.currency_code, rct.doc_sequence_value doc_seq_num,
       rep.reference25 trans_number, rep.reference26 customer_number,
       substr(hp.party_name,1,50) customer_name, rep.accounting_date,
       decode(rep.reference30||rep.reference29 ,'AR_CASH_BASIS_DISTRIBUTIONSCMAPP_APP' ,
       nvl(rep.accounted_dr,0)-nvl(rep.accounted_cr,0) ,'AR_CASH_BASIS_DISTRIBUTIONSCMAPP_REC' ,
       nvl(rep.accounted_dr,0)-nvl(rep.accounted_cr,0)) amount
FROM IGI_AR_JOURNAL_INTERIM rep, IGI_CBR_ARC_RECONCILE_V aat,
     RA_CUSTOMER_TRX rct, hz_parties hp, hz_cust_accounts hca, GL_CODE_COMBINATIONS c,
     AR_LOOKUPS l
WHERE rep.CODE_COMBINATION_ID = c.code_combination_id(+)
AND l.lookup_type = 'ARRGTA_CATEGORIES'
AND rep.reference28 = l.lookup_code
AND rep.reference25 = aat.trans_num
AND rep.reference22 = to_char(rct.customer_trx_id)
AND (rep.accounted_cr <> 0 OR rep.accounted_dr <> 0)
AND rep.reference25 is not null
AND rep.reference29 in ( 'CMAPP_APP','CMAPP_REC')
AND rep.reference30 = 'AR_CASH_BASIS_DISTRIBUTIONS'
AND rep.reference26 = hca.account_number
AND nvl(rep.accounted_dr,0) - nvl(rep.accounted_cr,0) <> 0
AND hca.party_id = hp.party_id
UNION ALL
SELECT c.SEGMENT1, c.SEGMENT2, c.SEGMENT3, c.SEGMENT4, c.SEGMENT5,
       c.SEGMENT6, c.SEGMENT7, c.SEGMENT8, c.SEGMENT9, c.SEGMENT10,
       c.SEGMENT11, c.SEGMENT12, c.SEGMENT13, c.SEGMENT14, c.SEGMENT15,
       c.SEGMENT16, c.SEGMENT17, c.SEGMENT18, c.SEGMENT19, c.SEGMENT20,
       c.SEGMENT21, c.SEGMENT22, c.SEGMENT23, c.SEGMENT24, c.SEGMENT25,
       c.SEGMENT26, c.SEGMENT27, c.SEGMENT28, c.SEGMENT29, c.SEGMENT30,
       rep.request_id, rep.currency_code, acr.doc_sequence_value doc_seq_num,
       rep.reference25 trans_number, rep.reference26 customer_number,
       hz.party_name customer_name, rep.accounting_date,
       decode(rep.reference30||rep.reference29 ,'AR_CASH_BASIS_DISTRIBUTIONSTRADE_APP' ,
       nvl(-rep.accounted_cr,0)-nvl(-rep.accounted_dr,0)) amount
FROM   IGI_AR_JOURNAL_INTERIM rep, IGI_CBR_ARC_RECONCILE_V aat, AR_CASH_RECEIPTS acr,
       HZ_PARTIES hz, HZ_CUST_ACCOUNTS hca, GL_CODE_COMBINATIONS c, AR_LOOKUPS l
WHERE  rep.CODE_COMBINATION_ID = c.code_combination_id(+)
AND l.lookup_type = 'ARRGTA_CATEGORIES'
AND rep.reference28 = l.lookup_code
AND rep.reference25 = aat.trans_num
AND rep.reference22 = to_char(acr.cash_receipt_id)
AND (rep.accounted_cr <> 0 OR rep.accounted_dr <> 0)
AND rep.reference25 is not null
AND rep.reference29 <> 'INV_REC'
AND rep.reference29 <> 'CM_REC'
AND rep.reference29 <> 'CMAPP_APP'
AND rep.reference30 = 'AR_CASH_BASIS_DISTRIBUTIONS'
AND rep.reference26 = hca.account_number
AND hz.party_id = hca.party_id
AND nvl(rep.accounted_dr,0) - nvl(rep.accounted_cr,0) <> 0
UNION ALL
SELECT c.SEGMENT1, c.SEGMENT2, c.SEGMENT3, c.SEGMENT4, c.SEGMENT5,
       c.SEGMENT6, c.SEGMENT7, c.SEGMENT8, c.SEGMENT9, c.SEGMENT10,
       c.SEGMENT11, c.SEGMENT12, c.SEGMENT13, c.SEGMENT14, c.SEGMENT15,
       c.SEGMENT16, c.SEGMENT17, c.SEGMENT18, c.SEGMENT19, c.SEGMENT20,
       c.SEGMENT21, c.SEGMENT22, c.SEGMENT23, c.SEGMENT24, c.SEGMENT25,
       c.SEGMENT26, c.SEGMENT27, c.SEGMENT28, c.SEGMENT29, c.SEGMENT30,
       rep.request_id, rep.currency_code, acr.doc_sequence_value doc_seq_num,
       nvl(rep.reference25,rep.reference24) trans_number, rep.reference26 customer_number,
       null customer_name, rep.accounting_date,
       nvl(rep.accounted_dr,0) - nvl(rep.accounted_cr,0) amount
FROM IGI_AR_JOURNAL_INTERIM rep, GL_CODE_COMBINATIONS c, AR_CASH_RECEIPTS_ALL acr
WHERE rep.code_combination_id = c.code_combination_id
AND nvl(rep.accounted_dr,0) - nvl(rep.accounted_cr,0) <> 0
AND rep.reference28 in ('TRADE','MISC')
AND rep.reference22 = to_char(acr.cash_receipt_id)
AND rep.set_of_books_id = nvl(p_CashSetOfBooksId,0)
AND rep.reference30 <> 'AR_CASH_BASIS_DISTRIBUTIONS') icav
            WHERE icav.request_id = p_request_id;
     END Insert_Rows;


END IGI_CBR_ARC_INTERFACE_PKG;

/
