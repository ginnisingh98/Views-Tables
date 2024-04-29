--------------------------------------------------------
--  DDL for Package Body JL_BR_AR_BALANCE_MAINTENANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AR_BALANCE_MAINTENANCE" as
/* $Header: jlbrrbmb.pls 120.5 2005/04/07 18:36:12 appradha ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES                                              |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    JL_BR_AR_BAL_MAINTENANCE                                                |
 |                                                                            |
 | DESCRIPTION                                                                |
 |                                                                            |
 | PARAMETERS                                                                 |
 |   INPUT                                                                    |
 |     par_posting_control_id     Number -- Posting Control Id                |
 |                                                                            |
 |   OUTPUT                                                                   |
 |                                                                            |
 |                                                                            |
 | HISTORY                                                                    |
 |   28-Aug-97      Aniz Buissa Jr.  Created                                  |
 *----------------------------------------------------------------------------*/

/*-----------------------------------------------------------*/
/*<<<<<            JL_BR_AR_BAL_MAINTENANCE             >>>>>*/
/*-----------------------------------------------------------*/
PROCEDURE	JL_BR_AR_BAL_MAINTENANCE (
		par_posting_control_id	IN NUMBER)   IS

pl_period_num		number;
pl_sob                  number;
pl_per                  varchar2(15);
pl_per_set              varchar2(15);
pl_min_pyear		number;
pl_max_pyear		number;
pl_pyear		number;
pl_min_pnum		number;
pl_max_pnum		number;
pl_pnum			number;
pl_ccid                 number;
pl_cust                 number;
pl_sign			varchar2(1);
pl_val			number;
pl_ival2                number;
pl_user			number	:= 9999;

cursor c_bmb 		is
SELECT /*+ ORDERED */
	racust0.set_of_books_id sob, gldist0.code_combination_id ccid,
	r0.period_year pyear, r0.period_num pnum,
        s0.period_set_name perset,
        gldist0.gl_date accd,
        racust0.bill_to_customer_id cust,
        racust0.trx_number num,
        racust0.customer_trx_id invid,
        racust0.trx_date idat,
        racust0.invoice_currency_code cur,
	gldist0.cust_trx_line_gl_dist_id inst,
-- bug 2054372
--        decode(type0.type,'CM',
--	         decode(sign(nvl(gldist0.acctd_amount,gldist0.amount)),-1,
--		       decode(gldist0.account_class,'REV',
--			      'D','C'),
--		       decode(gldist0.account_class,'REC',
--			      'D','C')),
--		decode(gldist0.account_class,'REC',
--			       'D','C' ) ) isign,
decode(type0.type,'CM',
          decode(sign(nvl(gldist0.acctd_amount,gldist0.amount)),-1,
           decode(gldist0.account_class,'REC','C','REV','D','UNEARN','D','D'),1,
           decode(gldist0.account_class,'REC','D','REV','C','UNEARN','C','C'),0,'C'),
-- DM
           decode(sign(nvl(gldist0.acctd_amount,gldist0.amount)),-1,
           decode(gldist0.account_class,'REC','C','REV','D','UNEARN','D','D'),1,
           decode(gldist0.account_class,'REC','D','REV','C','UNEARN','C','C'),0,'C')) isign,
	abs(nvl(gldist0.acctd_amount,nvl(gldist0.amount,0))) ival,
        glps0.period_name per,
        decode(type0.type,'CM','Nota de Credito','Nota de Debito') hist,
        batch0.name bat, batch0.batch_id batid,
        racust0.org_id
FROM    ra_cust_trx_line_gl_dist gldist0,
	ra_customer_trx_all racust0,
	hz_cust_accounts_all hzcus0,
        ra_cust_trx_types_all type0,
        gl_period_statuses glps0,
        ra_batches_all batch0,
	gl_sets_of_books s0,
	gl_periods r0
WHERE   gldist0.posting_control_id = par_posting_control_id
and     gldist0.gl_date is not null
and 	racust0.bill_to_customer_id = hzcus0.cust_account_id
and     gldist0.customer_trx_id = racust0.customer_trx_id
and     type0.type <>'INV'
and     racust0.cust_trx_type_id = type0.cust_trx_type_id
and     glps0.application_id = 222
and     racust0.set_of_books_id = glps0.set_of_books_id
and     gldist0.gl_date between glps0.start_date and glps0.end_date
and  	racust0.set_of_books_id = s0.set_of_books_id
and  	s0.period_set_name = r0.period_set_name
and  	glps0.period_name = r0.period_name
and     racust0.batch_id = batch0.batch_id (+)
UNION ALL
SELECT /*+ ORDERED */
 racust1.set_of_books_id sob, gldist1.code_combination_id ccid,
	r1.period_year pyear, r1.period_num pnum,
	s1.period_set_name perset,
        gldist1.gl_date accd,
        racust1.bill_to_customer_id cust,
        racust1.trx_number num,
	racust1.customer_trx_id invid,
        racust1.trx_date idat,
        racust1.invoice_currency_code cur,
	gldist1.cust_trx_line_gl_dist_id inst,
-- bug 2054372
--        decode(gldist1.account_class,'REC',
--                       'D','C') isign,
          decode(sign(nvl(gldist1.acctd_amount,gldist1.amount)),-1,
          decode(gldist1.account_class,'REC','C','REV','D','UNEARN','D','D'),1,
          decode(gldist1.account_class,'REC','D','REV','C','UNEARN','C','C'),0,'C') isign,
	abs(nvl(gldist1.acctd_amount,nvl(gldist1.amount,0))) ival,
        glps1.period_name per,
        'Entrada de Dcto' hist,
        batch1.name bat, batch1.batch_id batid,
        racust1.org_id
FROM    ra_cust_trx_line_gl_dist gldist1,
        ra_customer_trx_all racust1,
        hz_cust_accounts_all hzcus1,
        ra_cust_trx_types_all type1,
        gl_period_statuses glps1,
        ra_batches_all batch1,
        gl_sets_of_books s1,
        gl_periods r1
WHERE   gldist1.posting_control_id = par_posting_control_id
and     gldist1.gl_date is not null
and     gldist1.customer_trx_id = racust1.customer_trx_id
and     racust1.bill_to_customer_id = hzcus1.cust_account_id
and     racust1.cust_trx_type_id = type1.cust_trx_type_id
and     type1.type = 'INV'
and     glps1.application_id = 222
and     glps1.set_of_books_id = racust1.set_of_books_id
and     racust1.trx_date between glps1.start_date and glps1.end_date
and     racust1.complete_flag = 'Y'
and     racust1.batch_id = batch1.batch_id (+)
and     racust1.set_of_books_id = s1.set_of_books_id
and     s1.period_set_name = r1.period_set_name
and     glps1.period_name = r1.period_name
UNION ALL
SELECT  /*+ ORDERED */
	recapp2.set_of_books_id sob, recapp2.code_combination_id ccid,
	r2.period_year pyear, r2.period_num pnum,
	s2.period_set_name perset,
        recapp2.gl_date accd,
        cash2.pay_from_customer cust,
        to_char(cash2.cash_receipt_id) num,
        cash2.cash_receipt_id invid,
        recapp2.apply_date idat,
        cash2.currency_code cur,
	recapp2.receivable_application_id inst,
        decode(sign(recapp2.acctd_amount_applied_from),-1,'D','C') isign,
        abs(recapp2.acctd_amount_applied_from) ival,
        glps2.period_name per,
        'Receb. Dcto (Aplicado)' hist,
        batch2.name bat, batch2.batch_id batid,
        cash2.org_id
FROM    ar_receivable_applications recapp2,
	ar_cash_receipts_all cash2,
        hz_cust_accounts_all hzcus2,
	gl_sets_of_books s2,
	gl_periods r2,
        gl_period_statuses glps2,
        ra_batches_all batch2
WHERE   recapp2.posting_control_id = par_posting_control_id
and 	cash2.cash_receipt_id = recapp2.cash_receipt_id
and     cash2.pay_from_customer = hzcus2.cust_account_id
and     cash2.selected_remittance_batch_id = batch2.batch_id (+)
and     recapp2.gl_date between glps2.start_date and glps2.end_date
and     glps2.application_id = 222
and     cash2.set_of_books_id = glps2.set_of_books_id
and  	cash2.set_of_books_id = s2.set_of_books_id
and  	s2.period_set_name = r2.period_set_name
and  	glps2.period_name = r2.period_name
UNION ALL
SELECT  /*+ ORDERED */
	recapp3.set_of_books_id sob, recapp3.code_combination_id ccid,
	r3.period_year pyear, r3.period_num pnum,
	s3.period_set_name perset,
        recapp3.gl_date accd,
       	inv3.bill_to_customer_id  cust,
        cm3.trx_number num,
        cm3.customer_trx_id invid,
	recapp3.apply_date idat,
	inv3.invoice_currency_code cur,
	recapp3.receivable_application_id inst,
        decode(sign(recapp3.acctd_amount_applied_from),-1,'D','C') isign,
        abs(recapp3.acctd_amount_applied_from) ival,
        glps3.period_name per,
        'Nota de Cred (Aplic.)' hist,
        batch3.name bat, batch3.batch_id batid,
        inv3.org_id
FROM	ar_receivable_applications recapp3,
	ra_customer_trx_all cm3,
        ra_customer_trx_all inv3,
        hz_cust_accounts_all hzcus3,
        ra_batches_all batch3,
	gl_period_statuses glps3,
	gl_periods r3,
	gl_sets_of_books s3
WHERE   recapp3.posting_control_id = par_posting_control_id
and	recapp3.customer_trx_id = cm3.customer_trx_id
and 	recapp3.applied_customer_trx_id = inv3.customer_trx_id
and     inv3.bill_to_customer_id = hzcus3.cust_account_id
and     cm3.batch_id = batch3.batch_id (+)
and     recapp3.gl_date between glps3.start_date and glps3.end_date
and  	inv3.set_of_books_id = s3.set_of_books_id
and     glps3.application_id = 222
and     inv3.set_of_books_id = glps3.set_of_books_id
and  	s3.period_set_name = r3.period_set_name
and  	glps3.period_name = r3.period_name
UNION ALL
SELECT /*+ ORDERED */
	misc4.set_of_books_id sob, misc4.code_combination_id ccid,
	r4.period_year pyear, r4.period_num pnum,
	s4.period_set_name perset,
	misc4.gl_date accd,
	cash4.pay_from_customer cust,
        to_char(cash4.cash_receipt_id) num,
        cash4.cash_receipt_id invid,
	misc4.apply_date idat,
	cash4.currency_code cur,
        misc4.misc_cash_distribution_id inst,
	decode(sign(misc4.acctd_amount),-1,'D','C') isign,
	abs(nvl(misc4.acctd_amount,0)) ival,
        glps4.period_name per,
        'Receb Dcto (Nao Aplic)' hist,
        batch4.name bat, batch4.batch_id batid,
        cash4.org_id
FROM	ar_misc_cash_distributions misc4,
	ar_cash_receipts_all cash4,
	hz_cust_accounts_all hzcus4,
        ra_batches_all batch4,
	gl_sets_of_books s4,
	gl_periods r4,
	gl_period_statuses glps4
WHERE   misc4.posting_control_id = par_posting_control_id
and	misc4.cash_receipt_id = cash4.cash_receipt_id
and	cash4.pay_from_customer is not null
and     cash4.pay_from_customer = hzcus4.cust_account_id
and     cash4.selected_remittance_batch_id = batch4.batch_id (+)
and 	misc4.gl_date between glps4.start_date and glps4.end_date
and	misc4.set_of_books_id = glps4.set_of_books_id
and	glps4.application_id = 222
and  	misc4.set_of_books_id = s4.set_of_books_id
and  	s4.period_set_name = r4.period_set_name
and  	glps4.period_name = r4.period_name
UNION ALL
SELECT  /*+ ORDERED */
        adj5.set_of_books_id sob, dis5.code_combination_id ccid,
        r5.period_year pyear, r5.period_num pnum,
        s5.period_set_name perset,
        adj5.gl_date accd,
        racust5.bill_to_customer_id cust,
        adj5.adjustment_number num,
        adj5.adjustment_id invid,
        adj5.apply_date idat,
        racust5.invoice_currency_code cur,
        adj5.adjustment_id inst,
        decode (dis5.acctd_amount_dr, NULL, 'C', 'D') isign,
        nvl (dis5.acctd_amount_dr, dis5.acctd_amount_cr) ival,
        glps5.period_name per,
        'Ajuste' hist,
        batch5.name bat, batch5.batch_id batid,
        racust5.org_id
FROM    ar_adjustments adj5,
        ra_customer_trx_all racust5,
        hz_cust_accounts_all hzcus5,
        ra_batches_all batch5,
        gl_sets_of_books s5,
        gl_periods r5,
        gl_period_statuses glps5,
        ar_distributions_all dis5
WHERE   adj5.posting_control_id = par_posting_control_id
and     adj5.customer_trx_id = racust5.customer_trx_id
and     racust5.bill_to_customer_id = hzcus5.cust_account_id
and     racust5.batch_id = batch5.batch_id (+)
and     adj5.set_of_books_id = glps5.set_of_books_id
and     glps5.application_id = 222
and     adj5.gl_date between glps5.start_date and glps5.end_date
and     adj5.set_of_books_id = s5.set_of_books_id
and     s5.period_set_name = r5.period_set_name
and     glps5.period_name = r5.period_name
and     adj5.adjustment_id = dis5.source_id
and     dis5.source_type = 'ADJ'
UNION ALL
SELECT  /*+ ORDERED */
	cash6.set_of_books_id sob, hist6.account_code_combination_id ccid,
	r6.period_year pyear, r6.period_num pnum,
	s6.period_set_name perset,
	hist6.gl_date accd,
	cash6.pay_from_customer cust,
        to_char(cash6.cash_receipt_id) num,
	cash6.cash_receipt_id invid,
	hist6.trx_date idat,
	cash6.currency_code cur,
	hist6.cash_receipt_history_id inst,
	decode(sign(hist6.acctd_amount),1,'D','C') isign,
	abs(nvl(hist6.acctd_amount,0)) ival,
        glps6.period_name per,
        'Recebim de Dcto' hist,
        batch6.name bat, batch6.batch_id batid,
        cash6.org_id
FROM	ar_cash_receipt_history hist6,
	ar_cash_receipts_all cash6,
        hz_cust_accounts_all hzcus6,
        ra_batches_all batch6,
	gl_sets_of_books s6,
	gl_periods r6,
	gl_period_statuses glps6
WHERE   hist6.posting_control_id = par_posting_control_id
and 	hist6.status = 'CLEARED'
and	hist6.cash_receipt_id = cash6.cash_receipt_id
and	cash6.pay_from_customer is not null
and     cash6.pay_from_customer = hzcus6.cust_account_id
and     cash6.selected_remittance_batch_id = batch6.batch_id (+)
and	cash6.set_of_books_id = glps6.set_of_books_id
and	glps6.application_id = 222
and 	hist6.gl_date between glps6.start_date and glps6.end_date
and  	cash6.set_of_books_id = s6.set_of_books_id
and  	s6.period_set_name = r6.period_set_name
and  	glps6.period_name = r6.period_name
UNION ALL
SELECT  /*+ ORDERED */
	cash6b.set_of_books_id sob, hist6b.account_code_combination_id ccid,
	r6b.period_year pyear, r6b.period_num pnum,
	s6b.period_set_name perset,
	hist6b.gl_date accd,
	cash6b.pay_from_customer cust,
        to_char(cash6b.cash_receipt_id) num,
	cash6b.cash_receipt_id invid,
	hist6b.trx_date idat,
	cash6b.currency_code cur,
	hist6b.cash_receipt_history_id inst,
	decode(sign(hist6b.acctd_amount),-1,'D','C') isign,
	abs(nvl(hist6b.acctd_amount,0)) ival,
        glps6b.period_name per,
        'Recebim. Revertido' hist,
        batch6b.name bat, batch6b.batch_id batid,
        cash6b.org_id
FROM	ar_cash_receipt_history hist6b,
	ar_cash_receipts_all cash6b,
        hz_cust_accounts_all hzcus6b,
	gl_period_statuses glps6b,
        ra_batches_all batch6b,
	gl_periods r6b,
	gl_sets_of_books s6b
WHERE   hist6b.posting_control_id = par_posting_control_id
and 	hist6b.status = 'CLEARED'
and	hist6b.cash_receipt_id = cash6b.cash_receipt_id
and	cash6b.status = 'REV'
and	cash6b.pay_from_customer is not null
and     cash6b.pay_from_customer = hzcus6b.cust_account_id
and	glps6b.application_id = 222
and	cash6b.set_of_books_id = glps6b.set_of_books_id
and 	hist6b.gl_date between glps6b.start_date and glps6b.end_date
and     cash6b.selected_remittance_batch_id = batch6b.batch_id (+)
and  	cash6b.set_of_books_id = s6b.set_of_books_id
and  	s6b.period_set_name = r6b.period_set_name
and  	glps6b.period_name = r6b.period_name
UNION ALL
SELECT  /*+ ORDERED */
	gldist7.set_of_books_id sob, gldist7.code_combination_id ccid,
	r7.period_year pyear, r7.period_num pnum,
	s7.period_set_name perset,
        recapp7.gl_date accd,
       	inv7.bill_to_customer_id  cust,
        cm7.trx_number num,
	cm7.customer_trx_id invid,
	recapp7.apply_date idat,
	inv7.invoice_currency_code cur,
	recapp7.receivable_application_id inst,
        decode(sign(recapp7.acctd_amount_applied_from),-1,'C','D') isign,  --Bug 3934716
        abs(recapp7.acctd_amount_applied_from) ival,
        glps7.period_name per,
        'Nota Cred (Cta Receb)' hist,
        batch7.name bat, batch7.batch_id batid,
        inv7.org_id
FROM	ra_cust_trx_line_gl_dist gldist7,
	ra_customer_trx_all cm7,
	ar_receivable_applications_all recapp7,
        ra_customer_trx_all inv7,
        hz_cust_accounts_all hzcus7,
       	ra_batches_all batch7,
	gl_period_statuses glps7,
	gl_sets_of_books s7,
	gl_periods r7
WHERE   gldist7.posting_control_id = par_posting_control_id
and	gldist7.account_class = 'REC'
and     gldist7.customer_trx_id = cm7.customer_trx_id
and	cm7.customer_trx_id = recapp7.customer_trx_id
and	recapp7.applied_customer_trx_id = inv7.customer_trx_id
and     inv7.bill_to_customer_id = hzcus7.cust_account_id
and     cm7.batch_id = batch7.batch_id (+)
and     glps7.application_id = 222
and     inv7.set_of_books_id = glps7.set_of_books_id
and     recapp7.gl_date between glps7.start_date and glps7.end_date
and  	inv7.set_of_books_id = s7.set_of_books_id
and  	s7.period_set_name = r7.period_set_name
and  	glps7.period_name = r7.period_name
UNION ALL
SELECT  /*+ ORDERED */
        gldist8.set_of_books_id sob, gldist8.code_combination_id ccid,
        r8.period_year pyear, r8.period_num pnum,
        s8.period_set_name perset,
        adj8.gl_date accd,
        racust8.bill_to_customer_id cust,
        adj8.adjustment_number num,
        adj8.adjustment_id invid,
        adj8.apply_date idat,
        racust8.invoice_currency_code cur,
        gldist8.cust_trx_line_gl_dist_id inst,
        decode (dis8.acctd_amount_dr, NULL, 'C', 'D') isign,
        nvl (dis8.acctd_amount_dr, dis8.acctd_amount_cr) ival,
        glps8.period_name per,
        'Ajuste (Conta Recebim)' hist,
        batch8.name bat, batch8.batch_id batid,
        racust8.org_id
FROM    ra_cust_trx_line_gl_dist gldist8,
        ar_adjustments_all adj8,
        ra_customer_trx_all racust8,
        hz_cust_accounts_all hzcus8,
        ra_batches_all batch8,
        gl_sets_of_books s8,
        gl_period_statuses glps8,
        gl_periods r8,
        ar_distributions_all dis8
WHERE   gldist8.posting_control_id = par_posting_control_id
and     gldist8.account_class = 'REC'
and     gldist8.customer_trx_id = adj8.customer_trx_id
and     adj8.customer_trx_id = racust8.customer_trx_id
and     racust8.bill_to_customer_id = hzcus8.cust_account_id
and     racust8.batch_id = batch8.batch_id (+)
and     glps8.application_id = 222
and     adj8.set_of_books_id = glps8.set_of_books_id
and     adj8.gl_date between glps8.start_date and glps8.end_date
and     adj8.set_of_books_id = s8.set_of_books_id
and     s8.period_set_name = r8.period_set_name
and     glps8.period_name = r8.period_name
and     adj8.adjustment_id = dis8.source_id
and     dis8.source_type = 'REC'
order by 1,3,4;

/*  r_bmb					c_bmb%rowtype;  */
l_org_id          NUMBER;
l_country_code    VARCHAR2(5);
l_product_code    VARCHAR2(5);
begin
-- fix for bug # 2587958
  l_org_id := MO_GLOBAL.get_current_org_id;
  l_country_code := JG_ZZ_SHARED_PKG.GET_COUNTRY(l_org_id,null);
  l_product_code := JG_ZZ_SHARED_PKG.GET_PRODUCT(l_org_id,null);
  IF l_product_code <> 'JL' or  l_country_code <> 'BR' then
    return;
end if;

FOR r_bmb in c_bmb LOOP

        pl_sob  	:= r_bmb.sob;
        pl_per  	:= r_bmb.per;
        pl_per_set  	:= r_bmb.perset;
        pl_ccid 	:= r_bmb.ccid;
        pl_cust  	:= r_bmb.cust;
	pl_sign 	:= r_bmb.isign;
	pl_val  	:= r_bmb.ival;
	pl_pyear 	:= r_bmb.pyear;
	pl_pnum 	:= r_bmb.pnum;

        select decode(r_bmb.isign,'D',-1*r_bmb.ival,r_bmb.ival)
          into pl_ival2
          from dual;

/*  Always insert all posted transactions from AR to GL */

 begin
   insert into JL_BR_JOURNALS (
   APPLICATION_ID                 ,
   SET_OF_BOOKS_ID               ,
   PERIOD_SET_NAME                 ,
   PERIOD_NAME                 ,
   CODE_COMBINATION_ID        ,
   PERSONNEL_ID              ,
   TRANS_CURRENCY_CODE    ,
   BATCH_ID,
   BATCH_NAME              ,
   ACCOUNTING_DATE        ,
   TRANS_ID,
   TRANS_NUM           ,
   TRANS_DATE         ,
   TRANS_DESCRIPTION   ,
   INSTALLMENT,
   TRANS_VALUE_SIGN   ,
   TRANS_VALUE       ,
   JOURNAL_BALANCE_FLAG,
   LAST_UPDATE_DATE           ,
   LAST_UPDATED_BY             ,
   LAST_UPDATE_LOGIN         ,
   CREATION_DATE            ,
   CREATED_BY,
   ORG_ID              )        VALUES       (
            	222,
		r_bmb.sob,
		r_bmb.perset,
		r_bmb.per,
		r_bmb.ccid,
		r_bmb.cust,
                r_bmb.cur,
		r_bmb.batid,
		r_bmb.bat,
                r_bmb.accd,
		r_bmb.invid,
		r_bmb.num,
		r_bmb.idat,
		r_bmb.hist,
		r_bmb.inst,
                r_bmb.isign,
		r_bmb.ival,
		'N',
		sysdate,
		pl_user,
		'',
		'',
		'',
		r_bmb.org_id);


   end;
 end loop;

END JL_BR_AR_BAL_MAINTENANCE;

END JL_BR_AR_BALANCE_MAINTENANCE;

/
