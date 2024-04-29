--------------------------------------------------------
--  DDL for Package Body ARP_DUAL_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_DUAL_CURRENCY" AS
/* $Header: ARPLDUCB.pls 120.2 2005/09/01 13:10:54 mantani ship $ */
--
/*
    ArpducError     EXCEPTION;
    PRAGMA EXCEPTION_INIT( ArpducError, -20000 );
*/
--
--
PROCEDURE DualCurrency(
		    p_PostingControlId          NUMBER,
                    p_DualCurr                  VARCHAR2,
                    p_GlDateFrom                DATE,
                    p_GlDateTo                  DATE,
                    p_SetOfBooksId              NUMBER,
                    p_UserSource                VARCHAR2 ) IS

--PeriodLastDate DATE;

BEGIN
/*
-- This is to be used for Bill In Arrears Invoices. If gl_date
-- is different from its transaction date, then use this last date of
-- the period to be the transaction date for looking for rate.

   select end_date
   into   PeriodLastDate
   from   gl_period_statuses
   where  p_GLDateFrom between start_date and end_date
   and    application_id = 101
   and    set_of_books_id = p_SetOfBooksId
   and    adjustment_period_flag = 'N'
   and    rownum = 1
   order by period_num;

-- #1
-- This is for ar_cash_receipt_history,
--	        ar_misc_cash_distributions,
--		CASH in ar_receivable_applications
--

update gl_interface int
set
(int.transaction_date,
 int.reference3) = (
	select
	cr.receipt_date,
	tre.translation_rate
	from
	ar_cash_receipts cr,
	gl_transaction_rate_exceptions tre
	where int.reference22 = cr.cash_receipt_id
	and   tre.transaction_type(+) = 'ARRA_TRADE'
	and   tre.identifier1(+) = cr.cash_receipt_id
	and   tre.identifier2(+) = -1
	and   tre.to_currency_code(+) = p_DualCurr
	and   tre.set_of_books_id(+) = cr.set_of_books_id )
where int.transaction_date is null
and   int.user_je_source_name = p_UserSource
and   int.set_of_books_id = p_SetOfBooksId
and   int.group_id = p_PostingControlId
and   int.accounting_date between
               p_GlDateFrom
               and
               p_GlDateTo
and  (int.reference30 in ( 'AR_CASH_RECEIPT_HISTORY',
			   'AR_MISC_CASH_DISTRIBUTIONS')
	or
      int.reference29 in ( 'TRADE_APP','TRADE_GL')
     );

-- #2
-- This is for non CB adjustment,
--

update gl_interface int
set
(int.transaction_date,
 int.reference3) = (
	select
	ct.trx_date,
	tre.translation_rate
	from
	ar_adjustments adj,
	ra_customer_trx ct,
	gl_transaction_rate_exceptions tre
	where int.reference23 = adj.adjustment_id
	and   adj.customer_trx_id = ct.customer_trx_id
	and   tre.source_table(+) = 'RA_CUSTOMER_TRX'
	and   tre.identifier1(+) = ct.customer_trx_id
	and   tre.identifier2(+) = -1
	and   tre.to_currency_code(+) = p_DualCurr
	and   tre.set_of_books_id(+) = ct.set_of_books_id )
where int.transaction_date is null
and   int.user_je_source_name = p_UserSource
and   int.set_of_books_id = p_SetOfBooksId
and   int.group_id = p_PostingControlId
and   int.accounting_date between
               p_GlDateFrom
               and
               p_GlDateTo
and   int.reference30 = 'AR_ADJUSTMENTS'
and   int.reference26 <> 'CB';

-- #3
-- This is for CB adjustment,
--

update gl_interface int
set
(int.transaction_date,
 int.reference3) = (
	select
	ctinv.trx_date,
	tre.translation_rate
	from
	ar_adjustments adjcb,
	ar_adjustments adjinv,
	ra_customer_trx ctinv,
	gl_transaction_rate_exceptions tre
	where int.reference23 = adjcb.adjustment_id
	and   adjinv.receivables_trx_id = -11
	and   adjinv.chargeback_customer_trx_id = adjcb.customer_trx_id
	and   adjinv.customer_trx_id = ctinv.customer_trx_id
	and   tre.source_table(+) = 'RA_CUSTOMER_TRX'
	and   tre.identifier1(+) = ctinv.customer_trx_id
	and   tre.identifier2(+) = -1
	and   tre.to_currency_code(+) = p_DualCurr
	and   tre.set_of_books_id(+) = ctinv.set_of_books_id )
where int.transaction_date is null
and   int.user_je_source_name = p_UserSource
and   int.set_of_books_id = p_SetOfBooksId
and   int.group_id = p_PostingControlId
and   int.accounting_date between
               p_GlDateFrom
               and
               p_GlDateTo
and   int.reference30 = 'AR_ADJUSTMENTS'
and   int.reference26 = 'CB';

-- #4
-- This is for non CB and  non regular CM transactions in
-- ra_cust_trx_line_gl_dist
--

update gl_interface int
set
(int.transaction_date,
 int.reference3) = (
	select
	decode( ct.invoicing_rule_id,
		-3,
		decode( ct.trx_date,
			int.accounting_date,
			ct.trx_date,
			PeriodLastDate ),
		ct.trx_date ),
	tre.translation_rate
	from
	ra_customer_trx ct,
	gl_transaction_rate_exceptions tre
	where int.reference22 = ct.customer_trx_id
	and   tre.source_table(+) = 'RA_CUSTOMER_TRX'
	and   tre.identifier1(+) = ct.customer_trx_id
	and   tre.identifier2(+) = -1
	and   tre.to_currency_code(+) = p_DualCurr
	and   tre.set_of_books_id(+) = ct.set_of_books_id )
where int.transaction_date is null
and   int.user_je_source_name = p_UserSource
and   int.set_of_books_id = p_SetOfBooksId
and   int.group_id = p_PostingControlId
and   int.accounting_date between
               p_GlDateFrom
               and
               p_GlDateTo
and   int.reference30 = 'RA_CUST_TRX_LINE_GL_DIST'
and   int.reference28 <> 'CB'
and   int.reference22 in
		(select ct2.customer_trx_id
		 from	ra_customer_trx ct2
		 where  ct2.customer_trx_id = int.reference22
		 and    ct2.previous_customer_trx_id is null );

-- #5
-- This is for Regular CM in
-- ra_cust_trx_line_gl_dist
--

update gl_interface int
set
(int.transaction_date,
 int.reference3) = (
	select
	ctinv.trx_date,
	tre.translation_rate
	from
	ra_customer_trx ctinv,
	ra_customer_trx ctcm,
	gl_transaction_rate_exceptions tre
	where int.reference22 = ctcm.customer_trx_id
	and   ctcm.previous_customer_trx_id = ctinv.customer_trx_id
	and   tre.source_table(+) = 'RA_CUSTOMER_TRX'
	and   tre.identifier1(+) = ctinv.customer_trx_id
	and   tre.identifier2(+) = -1
	and   tre.to_currency_code(+) = p_DualCurr
	and   tre.set_of_books_id(+) = ctinv.set_of_books_id )
where int.transaction_date is null
and   int.user_je_source_name = p_UserSource
and   int.set_of_books_id = p_SetOfBooksId
and   int.group_id = p_PostingControlId
and   int.accounting_date between
               p_GlDateFrom
               and
               p_GlDateTo
and   int.reference30 = 'RA_CUST_TRX_LINE_GL_DIST'
and   int.reference22 in
		(select ct2.customer_trx_id
		 from   ra_customer_trx ct2
		 where  ct2.customer_trx_id = int.reference22
		 and    ct2.previous_customer_trx_id is not null);

-- #6
-- This is for CB in
-- ra_cust_trx_line_gl_dist
--

update gl_interface int
set
(int.transaction_date,
 int.reference3) = (
	select
	ctinv.trx_date,
	tre.translation_rate
	from
	ar_adjustments adj,
	ra_customer_trx ctinv,
	gl_transaction_rate_exceptions tre
	where int.reference22 = adj.chargeback_customer_trx_id
	and   adj.receivables_trx_id = -11
	and   adj.customer_trx_id = ctinv.customer_trx_id
	and   tre.source_table(+) = 'RA_CUSTOMER_TRX'
	and   tre.identifier1(+) = ctinv.customer_trx_id
	and   tre.identifier2(+) = -1
	and   tre.to_currency_code(+) = p_DualCurr
	and   tre.set_of_books_id(+) = ctinv.set_of_books_id )
where int.transaction_date is null
and   int.user_je_source_name = p_UserSource
and   int.set_of_books_id = p_SetOfBooksId
and   int.group_id = p_PostingControlId
and   int.accounting_date between
               p_GlDateFrom
               and
               p_GlDateTo
and   int.reference30 = 'RA_CUST_TRX_LINE_GL_DIST'
and   int.reference28 = 'CB';


-- #7
-- This is for non CB Discount
-- in ar_receivable_applications
--

update gl_interface int
set
(int.transaction_date,
 int.reference3) = (
	select
	ct.trx_date,
	tre.translation_rate
	from
	ar_receivable_applications ra,
	ra_customer_trx ct,
	gl_transaction_rate_exceptions tre
	where int.reference23 = ra.receivable_application_id
	and   ra.applied_customer_trx_id = ct.customer_trx_id
	and   tre.source_table(+) = 'RA_CUSTOMER_TRX'
	and   tre.identifier1(+) = ct.customer_trx_id
	and   tre.identifier2(+) = -1
	and   tre.to_currency_code(+) = p_DualCurr
	and   tre.set_of_books_id(+) = ct.set_of_books_id )
where int.transaction_date is null
and   int.user_je_source_name = p_UserSource
and   int.set_of_books_id = p_SetOfBooksId
and   int.group_id = p_PostingControlId
and   int.accounting_date between
               p_GlDateFrom
               and
               p_GlDateTo
and   int.reference30 = 'AR_RECEIVABLE_APPLICATIONS'
and   int.reference26 <> 'CB'
and   int.reference29 like '%_DISC%';

-- #8
-- This is for CB Discount
-- in ar_receivable_applications
--

update gl_interface int
set
(int.transaction_date,
 int.reference3) = (
	select
	ctinv.trx_date,
	tre.translation_rate
	from
	ar_receivable_applications ra,
	ar_adjustments adj,
	ra_customer_trx ctinv,
	gl_transaction_rate_exceptions tre
	where int.reference23 = ra.receivable_application_id
	and   ra.applied_customer_trx_id = adj.chargeback_customer_trx_id
	and   adj.receivables_trx_id = -11
	and   adj.customer_trx_id = ctinv.customer_trx_id
	and   tre.source_table(+) = 'RA_CUSTOMER_TRX'
	and   tre.identifier1(+) = ctinv.customer_trx_id
	and   tre.identifier2(+) = -1
	and   tre.to_currency_code(+) = p_DualCurr
	and   tre.set_of_books_id(+) = ctinv.set_of_books_id )
where int.transaction_date is null
and   int.user_je_source_name = p_UserSource
and   int.set_of_books_id = p_SetOfBooksId
and   int.group_id = p_PostingControlId
and   int.accounting_date between
               p_GlDateFrom
               and
               p_GlDateTo
and   int.reference30 = 'AR_RECEIVABLE_APPLICATIONS'
and   int.reference26 = 'CB'
and   int.reference29 like '%_DISC%';

-- #9
-- This is for OnAccnt CM
-- in ar_receivable_applications
--

update gl_interface int
set
(int.transaction_date,
 int.reference3) = (
	select
	ct.trx_date,
	tre.translation_rate
	from
	ar_receivable_applications ra,
	ra_customer_trx ct,
	gl_transaction_rate_exceptions tre
	where int.reference23 = ra.receivable_application_id
	and   ra.customer_trx_id = ct.customer_trx_id
	and   tre.source_table(+) = 'RA_CUSTOMER_TRX'
	and   tre.identifier1(+) = ct.customer_trx_id
	and   tre.identifier2(+) = -1
	and   tre.to_currency_code(+) = p_DualCurr
	and   tre.set_of_books_id(+) = ct.set_of_books_id )
where int.transaction_date is null
and   int.user_je_source_name = p_UserSource
and   int.set_of_books_id = p_SetOfBooksId
and   int.group_id = p_PostingControlId
and   int.accounting_date between
               p_GlDateFrom
               and
               p_GlDateTo
and   int.reference30 = 'AR_RECEIVABLE_APPLICATIONS'
and   int.reference28 = 'CMAPP'
and   int.reference23 in
		(select ra2.receivable_application_id
		 from   ar_receivable_applications ra2,
		        ra_customer_trx ct2
		 where  ra2.receivable_application_id = int.reference23
		 and    ra2.customer_trx_id = ct2.customer_trx_id
		 and    ct2.previous_customer_trx_id is null);

-- #10
-- This is for Regular CM applies to non CB
-- in ar_receivable_applications
--

update gl_interface int
set
(int.transaction_date,
 int.reference3) = (
	select
	ctinv.trx_date,
	tre.translation_rate
	from
	ar_receivable_applications ra,
	ra_customer_trx ctinv,
	gl_transaction_rate_exceptions tre
	where int.reference23 = ra.receivable_application_id
	and   ra.applied_customer_trx_id = ctinv.customer_trx_id
	and   tre.source_table(+) = 'RA_CUSTOMER_TRX'
	and   tre.identifier1(+) = ctinv.customer_trx_id
	and   tre.identifier2(+) = -1
	and   tre.to_currency_code(+) = p_DualCurr
	and   tre.set_of_books_id(+) = ctinv.set_of_books_id )
where int.transaction_date is null
and   int.user_je_source_name = p_UserSource
and   int.set_of_books_id = p_SetOfBooksId
and   int.group_id = p_PostingControlId
and   int.accounting_date between
               p_GlDateFrom
               and
               p_GlDateTo
and   int.reference30 = 'AR_RECEIVABLE_APPLICATIONS'
and   int.reference28 = 'CMAPP'
and   int.reference26 <> 'CB'
and   int.reference23 in
		(select ra2.receivable_application_id
		 from   ar_receivable_applications ra2,
		        ra_customer_trx ct2
		 where  ra2.receivable_application_id = int.reference23
		 and    ra2.customer_trx_id = ct2.customer_trx_id
		 and    ct2.previous_customer_trx_id is not null);


-- #11
-- This is for Regular CM applies to CB
-- in ar_receivable_applications
--

update gl_interface int
set
(int.transaction_date,
 int.reference3) = (
	select
	ctinv.trx_date,
	tre.translation_rate
	from
	ar_receivable_applications ra,
	ar_adjustments adj,
	ra_customer_trx ctinv,
	gl_transaction_rate_exceptions tre
	where int.reference23 = ra.receivable_application_id
	and   ra.applied_customer_trx_id = adj.chargeback_customer_trx_id
	and   adj.receivables_trx_id = -11
	and   adj.customer_trx_id = ctinv.customer_trx_id
	and   tre.source_table(+) = 'RA_CUSTOMER_TRX'
	and   tre.identifier1(+) = ctinv.customer_trx_id
	and   tre.identifier2(+) = -1
	and   tre.to_currency_code(+) = p_DualCurr
	and   tre.set_of_books_id(+) = ctinv.set_of_books_id )
where int.transaction_date is null
and   int.user_je_source_name = p_UserSource
and   int.set_of_books_id = p_SetOfBooksId
and   int.group_id = p_PostingControlId
and   int.accounting_date between
               p_GlDateFrom
               and
               p_GlDateTo
and   int.reference30 = 'AR_RECEIVABLE_APPLICATIONS'
and   int.reference28 = 'CMAPP'
and   int.reference26 = 'CB'
and   int.reference23 in
		(select ra2.receivable_application_id
		 from   ar_receivable_applications ra2,
		        ra_customer_trx ct2
		 where  ra2.receivable_application_id = int.reference23
		 and    ra2.customer_trx_id = ct2.customer_trx_id
		 and    ct2.previous_customer_trx_id is not null);
--
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:arp_dual_currency.DualCurrency( ... ):'||sqlerrm );
            RAISE_APPLICATION_ERROR( -20000, sqlerrm||'DualCurrency( ... ):' );
*/
NULL;
    END;
--
END arp_dual_currency;

/
