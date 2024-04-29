--------------------------------------------------------
--  DDL for Package Body ARP_AUTOMATIC_CLEARING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_AUTOMATIC_CLEARING_PKG" AS
/* $Header: ARRXACRB.pls 120.8.12010000.6 2009/04/09 09:58:18 nproddut ship $ */
PG_DEBUG	varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
procedure expand_stmt
(
        p_customer_name_low             IN VARCHAR2,
        p_customer_name_high            IN VARCHAR2,
        p_customer_number_low           IN VARCHAR2,
        p_customer_number_high          IN VARCHAR2,
        p_receipt_number_low            IN VARCHAR2,
        p_receipt_number_high           IN VARCHAR2,
        p_remittance_bank_account_id    IN NUMBER,
        p_payment_method_id             IN NUMBER,
	p_batch_id			IN NUMBER,
        statement                       IN OUT NOCOPY VARCHAR2 );
--
procedure main_select_risk
(
        statement 	IN OUT NOCOPY VARCHAR2,
        p_total_workers IN NUMBER DEFAULT 0,
        p_request_id 	IN NUMBER DEFAULT -1      );
--
procedure main_select_factored
(
        statement 	IN OUT NOCOPY VARCHAR2,
        p_total_workers IN NUMBER DEFAULT 0,
        p_request_id 	IN NUMBER DEFAULT -1     );
--
procedure main_select_remitted
(
        statement 	IN OUT NOCOPY VARCHAR2,
        p_total_workers IN NUMBER DEFAULT 0,
        p_request_id 	IN NUMBER DEFAULT -1      );
--
procedure ar_bind_variables
(
        p_customer_name_low             IN VARCHAR2,
        p_customer_name_high            IN VARCHAR2,
        p_customer_number_low           IN VARCHAR2,
        p_customer_number_high          IN VARCHAR2,
        p_receipt_number_low            IN VARCHAR2,
        p_receipt_number_high           IN VARCHAR2,
        p_remittance_bank_account_id    IN NUMBER,
        p_payment_method_id             IN NUMBER,
        p_batch_id                      IN NUMBER,
        c                               IN integer );
--
procedure clr_remit_disc_risk_receipts
(       p_clear_date                    IN DATE,
        p_gl_date                       IN DATE,
        p_customer_name_low             IN VARCHAR2,
        p_customer_name_high            IN VARCHAR2,
        p_customer_number_low           IN VARCHAR2,
        p_customer_number_high          IN VARCHAR2,
        p_receipt_number_low            IN VARCHAR2,
        p_receipt_number_high           IN VARCHAR2,
        p_remittance_bank_account_id    IN NUMBER,
        p_payment_method_id             IN NUMBER,
        p_exchange_rate_type            IN VARCHAR2,
        p_batch_id                      IN NUMBER,
        remitted_or_factored_or_risk    IN integer );
--
procedure clr_remit_disc_risk_rcpts_pa
(	p_worker_number			IN NUMBER,
	p_request_id   			IN NUMBER,
  	remitted_or_factored_or_risk 	IN NUMBER);
--
procedure ar_bind_variables_parallel
(
	p_worker_number			IN NUMBER,
	p_request_id   			IN NUMBER,
	c				IN integer );
--
procedure main_select_remitted_parallel
(
	statement IN OUT NOCOPY VARCHAR2	);
--
procedure main_select_factored_parallel
(
        statement IN OUT NOCOPY VARCHAR2       );
--
procedure main_select_risk_parallel
(
        statement IN OUT NOCOPY VARCHAR2       );
--
procedure populate_interim_table
(	p_clear_date                    IN DATE,
	p_gl_date			IN DATE,
	p_customer_name_low             IN VARCHAR2,
	p_customer_name_high            IN VARCHAR2,
	p_customer_number_low           IN VARCHAR2,
	p_customer_number_high          IN VARCHAR2,
	p_receipt_number_low            IN VARCHAR2,
	p_receipt_number_high           IN VARCHAR2,
	p_remittance_bank_account_id    IN NUMBER,
	p_payment_method_id             IN NUMBER,
	p_exchange_rate_type            IN VARCHAR2,
	p_batch_id       		IN NUMBER,
	remitted_or_factored_or_risk	IN integer,
	p_request_id			IN NUMBER,
	p_total_workers			IN NUMBER);
--
procedure expand_stmt
(
	p_customer_name_low             IN VARCHAR2,
	p_customer_name_high            IN VARCHAR2,
	p_customer_number_low           IN VARCHAR2,
	p_customer_number_high          IN VARCHAR2,
	p_receipt_number_low            IN VARCHAR2,
	p_receipt_number_high           IN VARCHAR2,
	p_remittance_bank_account_id    IN NUMBER,
	p_payment_method_id             IN NUMBER,
	p_batch_id                      IN NUMBER,
	statement			IN OUT NOCOPY VARCHAR2 ) IS
--
BEGIN
--
IF ( p_customer_number_low IS NOT NULL ) THEN
statement := statement ||
        'and c.account_number >= :b_cust_number_low ';
END IF;
--
IF ( p_customer_number_high IS NOT NULL ) THEN
statement := statement ||
        'and c.account_number <= :b_cust_number_high ';
END IF;
--
IF ( p_customer_name_low IS NOT NULL ) THEN
statement := statement ||
        'and party.party_name >= :b_cust_name_low ';
END IF;
--
IF ( p_customer_name_high IS NOT NULL ) THEN
statement := statement ||
        'and party.party_name <= :b_cust_name_high ';
END IF;
--
IF ( p_receipt_number_low IS NOT NULL ) THEN
statement := statement ||
        'and cr.receipt_number >= :b_receipt_number_low ';
END IF;
--
IF ( p_receipt_number_high IS NOT NULL ) THEN
statement := statement ||
        'and cr.receipt_number <= :b_receipt_number_high ';
END IF;
--
IF ( p_remittance_bank_account_id IS NOT NULL ) THEN
statement := statement ||
        'and cr.remit_bank_acct_use_id = :b_remittance_bank_account_id ';
END IF;
--
IF ( p_payment_method_id IS NOT NULL ) THEN
statement := statement ||
        'and cr.receipt_method_id = :b_payment_method ';
END IF;
--
-- Bug 706935.
-- Added these lines.

IF (p_batch_id IS NOT NULL ) THEN
statement := statement ||
        'and crh.batch_id= :b_batch_id';
END IF;
--
EXCEPTION
WHEN OTHERS THEN
        arp_standard.debug('Exception: ar_automatic_clearing_pkg ');
        RAISE;
--
END;
--
procedure main_select_risk
(
        statement IN OUT NOCOPY VARCHAR2,
        p_total_workers IN NUMBER DEFAULT 0,
        p_request_id IN NUMBER DEFAULT -1       ) IS
--
BEGIN
--
/* 07-JUL-2000 J Rautiainen BR Implementation
 * Receipts created by the Bills Receivable transaction remittance process
 * having BR_REMIT receipt class cannot be risk eliminated */
/*5444413 Index hint added*/
statement := statement ||
            'select ' ||
            'cr.cash_receipt_id, ' ||
            ':b_clear_date, ' ||
            'greatest ( crh.gl_date, :b_gl_date ), ' ||
            ' ''AR_AUTOMATIC_CLEARING'', ' ||
            ' ''10.6'', ' ||
            'crh.cash_receipt_history_id  ';
IF p_total_workers <> 0 THEN
    statement := statement ||
                ', MOD(CEIL((DENSE_RANK() over(order by crh.cash_receipt_id))/5000), '
                || p_total_workers ||') + 1, '||
                p_request_id ||' , ''RISK'' ';
END IF;
	statement := statement || 'from ' ||
                        'ar_cash_receipts cr, ' ||
                        'ar_cash_receipt_history crh, ' ||
                        'ar_cash_receipt_history crh2, ' ||
                        'ar_payment_schedules ps, ' ||
                        'hz_customer_profiles cps, ' ||
                        'hz_customer_profiles cpc, ' ||
                        'ar_receipt_method_accounts rma, ' ||
                        'ar_receipt_methods rm, ' ||
                        'ar_receipt_classes rc, ' ||
                        'ce_bank_accounts cba, ' ||
                        'ce_bank_acct_uses ba, ' ||
                        'hz_cust_accounts c, ' ||
                        'hz_parties party ' ||
                  'where ' ||
                        'cr.cash_receipt_id = crh.cash_receipt_id ' ||
                  'and   crh.prv_stat_cash_receipt_hist_id '||
		  '		= crh2.cash_receipt_history_id(+) ' ||
                  'and   cr.cash_receipt_id = ps.cash_receipt_id(+) ' ||
                  'and   greatest( nvl(ps.due_date, cr.deposit_date), ' ||
		  '               nvl( crh2.trx_date, ' ||
		  '		  	nvl(ps.due_date, cr.deposit_date )))'||
                  '              + nvl(rma.risk_elimination_days,0) ' ||
                  '              <= :b_clear_date ' ||
                  'and   crh.current_record_flag = ''Y'' ' ||
                  'and   crh.status = ''CLEARED'' ' ||
                  'and   crh.factor_flag = ''Y'' ' ||
                  'and   rm.receipt_method_id = cr.receipt_method_id ' ||
                  'and   rc.receipt_class_id = rm.receipt_class_id ' ||
                  'and   rc.creation_method_code <> ''BR_REMIT'' ' ||
                  'and   rma.receipt_method_id = cr.receipt_method_id ' ||
                  'and   rma.remit_bank_acct_use_id = ba.bank_acct_use_id ' ||
                  'and   rma.remit_bank_acct_use_id = cr.remit_bank_acct_use_id '||
                  'and   ba.bank_account_id = cba.bank_account_id ' ||
                  'and   cr.pay_from_customer = c.cust_account_id(+) ' ||
                  'and   c.party_id  = party.party_id(+) ' ||
                  'and   cr.pay_from_customer = cpc.cust_account_id(+) ' ||
                  'and   cpc.site_use_id(+) is null ' ||
                  'and   cr.pay_from_customer = cps.cust_account_id(+) ' ||
                  'and   cr.customer_site_use_id = cps.site_use_id(+) ';
IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Inside main_select_risk');
	 arp_standard.debug(   'Statement ' || statement);
END IF;
--
EXCEPTION
WHEN OTHERS THEN
        arp_standard.debug('Exception: ar_automatic_clearing_pkg ');
        RAISE;
--
END;
--
procedure main_select_factored
(
        statement IN OUT NOCOPY VARCHAR2,
        p_total_workers IN NUMBER DEFAULT 0,
        p_request_id IN NUMBER DEFAULT -1       ) IS
--
BEGIN
--
/* Bug 2484984 Modified the call gl_currency_api.get_rate so that
   there is an NVL for the exchange_rate_type parameter rather
   than an NVL for the function call itself . */

/* Bug 3820774 Replaced the get_rate with get_rate_sql. */
/*Bug5444413 Added hint */
statement := statement ||
            'select /*+ INDEX (CRH AR_CASH_RECEIPT_HISTORY_N6) USE_NL(crh,cr,rm,rc,rma,c,party,ba) */ ' ||
                'cr.cash_receipt_id, '||
                ':b_clear_date, ' ||
                'greatest ( crh.gl_date, :b_gl_date ), ' ||
                'nvl(:b_clear_date,crh.exchange_date), ' ||
                'nvl(:b_exchange_rate_type,cr.exchange_rate_type), ' ||
                'decode(nvl(:b_exchange_rate_type,cr.exchange_rate_type), ' ||
		'	''User'',cr.exchange_rate, ' ||
                '       gl_currency_api.get_rate_sql(:b_set_of_bks_id,cr.currency_code,:b_clear_date, ' ||
                '          nvl(:b_exchange_rate_type,cr.exchange_rate_type))), ' ||
                'cba.currency_code, ' ||
                'decode(cr.currency_code,
			cba.currency_code,crh.amount,crh.acctd_amount), ' ||
                'decode(cr.currency_code,
			cba.currency_code,crh.factor_discount_amount,crh.acctd_factor_discount_amount), ' ||
		' ''AR_AUTOMATIC_CLEARING'', ' ||
		' ''10.6'', ' ||
		'crh.cash_receipt_history_id, ' ||
                'crh.amount, ' ||
                'crh.factor_discount_amount, ' ||
                'cr.currency_code, ' ||
                'crh.exchange_rate ' ;
IF p_total_workers <> 0 THEN
    statement := statement ||
                ', MOD(CEIL((DENSE_RANK() over(order by crh.cash_receipt_id))/5000), '
                || p_total_workers ||') + 1, '||
                p_request_id ||' , ''FACTOR'' ';
END IF;
	statement := statement || 'from ' ||
                'ar_cash_receipts cr, ' ||
                'ar_cash_receipt_history crh, ' ||
                'ar_receipt_method_accounts rma, ' ||
                'ce_bank_accounts cba, ' ||
                'ce_bank_acct_uses ba, ' ||
                'ar_receipt_methods rm, ' ||
                'ar_receipt_classes rc, ' ||
                'hz_cust_accounts c,  ' ||
                'hz_parties party ' ||
              'where ' ||
                   'cr.cash_receipt_id = crh.cash_receipt_id ' ||
                'and   crh.trx_date <= :b_clear_date  ' ||
                'and   crh.current_record_flag = ''Y'' ' ||
                'and   crh.status = ''REMITTED'' ' ||
                'and   crh.factor_flag = ''Y'' ' ||
                'and   rma.receipt_method_id = cr.receipt_method_id ' ||
                'and   rm.receipt_method_id = cr.receipt_method_id ' ||
                'and   rc.receipt_class_id = rm.receipt_class_id ' ||
                'and   rc.clear_flag = ''S'' ' ||
                'and   rma.remit_bank_acct_use_id = ba.bank_acct_use_id ' ||
                'and   rma.remit_bank_acct_use_id = cr.remit_bank_acct_use_id ' ||
                'and   ba.bank_account_id = cba.bank_account_id ' ||
                'and   cr.pay_from_customer = c.cust_account_id(+) ' ||
                'and   c.party_id = party.party_id(+) ' ||
-- Bug 706935.
-- ||
-- 'and   crh.batch_id = nvl(:b_batch_id, crh.batch_id) ';
--
-- Bug 2132264
		'and  not exists ( ' ||
		'select ''debit memo reversal'' ' ||
		'from   ar_payment_schedules ps1 ' ||
		'where  ps1.reversed_cash_receipt_id = cr.cash_receipt_id ' ||
		'and    ps1.class = ''DM'') ';
IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Inside main_select_factored');
	 arp_standard.debug(   'Statement ' || statement);
END IF;
EXCEPTION
WHEN OTHERS THEN
        arp_standard.debug('Exception: ar_automatic_clearing_pkg ');
        RAISE;
--
END;
--
procedure main_select_remitted
(
	statement IN OUT NOCOPY VARCHAR2,
    p_total_workers IN NUMBER DEFAULT 0,
    p_request_id IN NUMBER DEFAULT -1	) IS
--
BEGIN
--
/* Bug 2484984 Modified the call gl_currency_api.get_rate so that
   there is an NVL for the exchange_rate_type parameter rather
   than an NVL for the function call itself . */
/* Bug 3820774 Replaced the get_rate with get_rate_sql. */
/*5444413 hint added here*/
statement := statement || 'select  ' ||
                'cr.cash_receipt_id, ' ||
                ':b_clear_date, ' ||
                'greatest ( crh.gl_date, :b_gl_date ), ' ||
                'nvl(:b_clear_date, crh.exchange_date), ' ||
                'nvl(:b_exchange_rate_type,cr.exchange_rate_type), ' ||
                'decode(nvl(:b_exchange_rate_type,cr.exchange_rate_type), ' ||
		'	 ''User'',cr.exchange_rate, ' ||
                '       gl_currency_api.get_rate_sql(:b_set_of_bks_id,cr.currency_code,:b_clear_date, ' ||
                '          nvl(:b_exchange_rate_type,cr.exchange_rate_type))), ' ||
                'cba.currency_code, ' ||
                'decode(cr.currency_code,
			cba.currency_code,crh.amount,crh.acctd_amount), ' ||
                'decode(cr.currency_code,
			cba.currency_code,crh.factor_discount_amount,crh.acctd_factor_discount_amount), ' ||
                ' ''AR_AUTOMATIC_CLEARING'', ' ||
                ' ''10.6'', ' ||
                'crh.cash_receipt_history_id, ' ||
                'crh.amount, ' ||
                'crh.factor_discount_amount, ' ||
                'cr.currency_code, ' ||
                'crh.exchange_rate ' ;
IF p_total_workers <> 0 THEN
    statement := statement ||
                ', MOD(CEIL((DENSE_RANK() over(order by crh.cash_receipt_id))/5000), '
                || p_total_workers ||') + 1, '||
                p_request_id ||' , ''REMIT'' ';
END IF;
	statement := statement || 'from ar_cash_receipts cr, ' ||
                'ar_cash_receipt_history crh, ' ||
                'ar_payment_schedules ps, ' ||
                'hz_customer_profiles cpc, ' ||
                'hz_customer_profiles cps, ' ||
                'ar_receipt_method_accounts rma, ' ||
                'ar_receipt_methods rm, ' ||
                'ar_receipt_classes rc, ' ||
                'ce_bank_accounts cba, ' ||
                'ce_bank_acct_uses ba, ' ||
                'hz_cust_accounts c,  ' ||
                'hz_parties party  ' ||
                'where cr.cash_receipt_id = crh.cash_receipt_id ' ||
                'and   cr.cash_receipt_id = ps.cash_receipt_id(+) ' ||
                'and   greatest( nvl(ps.due_date, cr.deposit_date), ' ||
		'            crh.trx_date )'||
                '       + nvl(nvl(cps.clearing_days, ' ||
                '                      nvl(cpc.clearing_days, ' ||
                '                              rma.clearing_days)), ' ||
                '                      0) ' ||
                '              <= :b_clear_date ' ||
                'and   crh.current_record_flag = ''Y'' ' ||
                'and   crh.status = ''REMITTED'' ' ||
                'and   crh.factor_flag = ''N'' ' ||
                'and   rma.receipt_method_id = cr.receipt_method_id ' ||
                'and   rm.receipt_method_id = cr.receipt_method_id ' ||
                'and   rc.receipt_class_id = rm.receipt_class_id ' ||
                'and   rc.clear_flag = ''S'' ' ||
                'and   rma.remit_bank_acct_use_id = ba.bank_acct_use_id ' ||
                'and   rma.remit_bank_acct_use_id = cr.remit_bank_acct_use_id ' ||
                'and   ba.bank_account_id = cba.bank_account_id ' ||
                'and   cr.pay_from_customer = c.cust_account_id(+) ' ||
                'and   c.party_id = party.party_id(+) ' ||
                'and   cr.pay_from_customer = cpc.cust_account_id(+) ' ||
                'and   cpc.site_use_id(+) is null ' ||
                'and   cr.pay_from_customer = cps.cust_account_id(+) ' ||
                'and   cr.customer_site_use_id = cps.site_use_id(+) ' ||
-- Bug 706935.
-- ||
-- 'and   crh.batch_id = nvl(:b_batch_id, crh.batch_id) ';
-- Bug 2132264
		'and  not exists ( ' ||
		'select ''debit memo reversal'' ' ||
		'from   ar_payment_schedules ps1 ' ||
		'where  ps1.reversed_cash_receipt_id = cr.cash_receipt_id ' ||
		'and    ps1.class = ''DM'') ';
IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Inside main_select_remitted');
	 arp_standard.debug(   'Statement ' || statement);
END IF;
--
EXCEPTION
WHEN OTHERS THEN
        arp_standard.debug('Exception: ar_automatic_clearing_pkg ');
        RAISE;
--
END;
--
procedure ar_bind_variables
(
        p_customer_name_low             IN VARCHAR2,
        p_customer_name_high            IN VARCHAR2,
        p_customer_number_low           IN VARCHAR2,
        p_customer_number_high          IN VARCHAR2,
        p_receipt_number_low            IN VARCHAR2,
        p_receipt_number_high           IN VARCHAR2,
        p_remittance_bank_account_id    IN NUMBER,
        p_payment_method_id             IN NUMBER,
	p_batch_id                      IN NUMBER,  -- added for bug 706935.
	c				IN integer ) IS
l_worker_number NUMBER;
--
BEGIN
--
IF ( p_customer_number_low IS NOT NULL ) THEN
dbms_sql.bind_variable(c, ':b_cust_number_low' ,p_customer_number_low);
END IF;
--
IF ( p_customer_number_high IS NOT NULL ) THEN
dbms_sql.bind_variable(c, ':b_cust_number_high' ,p_customer_number_high);
END IF;
--
IF ( p_customer_name_low IS NOT NULL ) THEN
dbms_sql.bind_variable(c, ':b_cust_name_low' ,p_customer_name_low);
END IF;
--
IF ( p_customer_name_high IS NOT NULL ) THEN
dbms_sql.bind_variable(c, ':b_cust_name_high' ,p_customer_name_high);
END IF;
--
IF ( p_receipt_number_low IS NOT NULL ) THEN
dbms_sql.bind_variable(c, ':b_receipt_number_low' ,p_receipt_number_low);
END IF;
--
IF ( p_receipt_number_high IS NOT NULL ) THEN
dbms_sql.bind_variable(c, ':b_receipt_number_high' ,p_receipt_number_high);
END IF;
--
IF ( p_remittance_bank_account_id IS NOT NULL ) THEN
dbms_sql.bind_variable(c, ':b_remittance_bank_account_id' ,p_remittance_bank_account_id);
END IF;
--
IF ( p_payment_method_id IS NOT NULL ) THEN
dbms_sql.bind_variable(c, ':b_payment_method' ,p_payment_method_id);
END IF;

-- Added for Bug 706935
--
IF ( p_batch_id IS NOT NULL ) THEN
dbms_sql.bind_variable(c, ':b_batch_id' ,p_batch_id);
END IF;
--
EXCEPTION
WHEN OTHERS THEN
        arp_standard.debug('Exception: ar_automatic_clearing_pkg ');
        RAISE;
--
END;
--
procedure clr_remit_disc_risk_receipts
(	p_clear_date                    IN DATE,
	p_gl_date			IN DATE,
	p_customer_name_low             IN VARCHAR2,
	p_customer_name_high            IN VARCHAR2,
	p_customer_number_low           IN VARCHAR2,
	p_customer_number_high          IN VARCHAR2,
	p_receipt_number_low            IN VARCHAR2,
	p_receipt_number_high           IN VARCHAR2,
	p_remittance_bank_account_id    IN NUMBER,
	p_payment_method_id             IN NUMBER,
	p_exchange_rate_type            IN VARCHAR2,
	p_batch_id       		IN NUMBER,
	remitted_or_factored_or_risk	IN integer ) IS
--
statement	varchar2(3000) := NULL;
c		integer;
ignore		integer;
v_cr_id         ar_cash_receipts.cash_receipt_id%TYPE;
v_crh_id        ar_cash_receipt_history.cash_receipt_history_id%TYPE;
v_trx_date      ar_cash_receipt_history.trx_date%TYPE;
v_gl_date       ar_cash_receipt_history.gl_date%TYPE;
v_ex_date       ar_cash_receipt_history.exchange_date%TYPE;
v_ex_rate_type  ar_cash_receipts.exchange_rate_type%TYPE;
v_ex_rate       ar_cash_receipts.exchange_rate%TYPE;
v_currency      ce_bank_accounts.currency_code%TYPE;
v_amount        ar_cash_receipt_history.amount%TYPE;
v_fac_disc_amount ar_cash_receipt_history.factor_discount_amount%TYPE;
v_mod_name      varchar2(30);
v_mod_vers      varchar2(5);
p_crh_id	ar_cash_receipt_history.cash_receipt_history_id%TYPE;
v_set_of_bks_id ar_system_parameters.set_of_books_id%TYPE;
p_cr_rec	ar_cash_receipts%ROWTYPE;
p_crh_rec	ar_cash_receipt_history%ROWTYPE;
locked		BOOLEAN;

-- 785113: Added to compute new acctd amts based on a different exchange rate.
v_crh_amount     ar_cash_receipt_history.amount%TYPE;
v_crh_fac_disc_amt     ar_cash_receipt_history.amount%TYPE;
v_ex_rate_old   ar_cash_receipts.exchange_rate%TYPE;
v_cr_currency   ce_bank_accounts.currency_code%TYPE;

--
BEGIN
--
select set_of_books_id INTO v_set_of_bks_id from ar_system_parameters;
--
IF ( remitted_or_factored_or_risk = 1) THEN
	main_select_remitted(
			statement,
                        0,
                        -1 );
END IF;
--
IF ( remitted_or_factored_or_risk = 2) THEN
    main_select_factored(
                        statement,
                        0,
                        -1 );
END IF;
--
IF ( remitted_or_factored_or_risk = 3) THEN
    main_select_risk(
                        statement,
                        0,
                        -1 );
END IF;
--
c := dbms_sql.open_cursor;
--
-- Build expanded select-statement depending on parameters
--
expand_stmt(	p_customer_name_low,
		p_customer_name_high,
		p_customer_number_low,
		p_customer_number_high,
		p_receipt_number_low,
		p_receipt_number_high,
		p_remittance_bank_account_id,
		p_payment_method_id,
                p_batch_id,
		statement		);
--
dbms_sql.parse(c, statement, dbms_sql.native);
--
-- Bind variables
--
dbms_sql.bind_variable(c, ':b_clear_date' ,p_clear_date);
dbms_sql.bind_variable(c, ':b_gl_date' ,p_gl_date);
--
IF ( remitted_or_factored_or_risk <> 3) THEN
dbms_sql.bind_variable(c, ':b_exchange_rate_type' ,p_exchange_rate_type);
dbms_sql.bind_variable(c, ':b_set_of_bks_id' ,v_set_of_bks_id);

-- Bug 706935.
-- Removed this line.
-- dbms_sql.bind_variable(c, ':b_batch_id' ,p_batch_id);

END IF;
--
ar_bind_variables(	p_customer_name_low,
			p_customer_name_high,
			p_customer_number_low,
			p_customer_number_high,
			p_receipt_number_low,
			p_receipt_number_high,
			p_remittance_bank_account_id,
			p_payment_method_id,
			p_batch_id,
			c	);
--
IF ( remitted_or_factored_or_risk = 3) THEN
	dbms_sql.define_column(c, 1, v_cr_id);
	dbms_sql.define_column(c, 2, v_trx_date);
	dbms_sql.define_column(c, 3, v_gl_date);
	dbms_sql.define_column(c, 4, v_mod_name, 30);
	dbms_sql.define_column(c, 5, v_mod_vers, 5);
	dbms_sql.define_column(c, 6, v_crh_id);
ELSE
	dbms_sql.define_column(c, 1, v_cr_id);
	dbms_sql.define_column(c, 2, v_trx_date);
	dbms_sql.define_column(c, 3, v_gl_date);
	dbms_sql.define_column(c, 4, v_ex_date);
	dbms_sql.define_column(c, 5, v_ex_rate_type, 30);
	dbms_sql.define_column(c, 6, v_ex_rate);
	dbms_sql.define_column(c, 7, v_currency, 15);
	dbms_sql.define_column(c, 8, v_amount);
	dbms_sql.define_column(c, 9, v_fac_disc_amount);
	dbms_sql.define_column(c, 10, v_mod_name, 30);
	dbms_sql.define_column(c, 11, v_mod_vers, 5);
	dbms_sql.define_column(c, 12, v_crh_id);
	dbms_sql.define_column(c, 13, v_crh_amount);
	dbms_sql.define_column(c, 14, v_crh_fac_disc_amt);
	dbms_sql.define_column(c, 15, v_cr_currency, 15);
	dbms_sql.define_column(c, 16, v_ex_rate_old);
END IF;
--
ignore := dbms_sql.execute(c);
--
IF ( remitted_or_factored_or_risk = 3) THEN
  LOOP
	IF dbms_sql.fetch_rows(c) > 0 THEN
                dbms_sql.column_value(c, 1, v_cr_id);
                dbms_sql.column_value(c, 2, v_trx_date);
                dbms_sql.column_value(c, 3, v_gl_date);
                dbms_sql.column_value(c, 4, v_mod_name);
                dbms_sql.column_value(c, 5, v_mod_vers);
                dbms_sql.column_value(c, 6, v_crh_id);
--
		-- Lock rows
--
		BEGIN
		locked := TRUE;
		p_cr_rec.cash_receipt_id := v_cr_id;
		p_crh_rec.cash_receipt_history_id := v_crh_id;
		arp_cash_receipts_pkg.nowaitlock_fetch_p ( p_cr_rec );
		arp_cr_history_pkg.nowaitlock_fetch_p ( p_crh_rec );
		EXCEPTION WHEN OTHERS THEN
			locked := FALSE;
		END;
--
		-- Call Risk Handler
--
		IF ( locked AND p_crh_rec.current_record_flag = 'Y' ) THEN
		    arp_cashbook.risk_eliminate (	v_cr_id,
					v_trx_date,
					v_gl_date,
					v_mod_name,
					v_mod_vers,
					p_crh_id	);
		END IF;
	ELSE
		-- no more rows
        	EXIT;
	END IF;
--
  END LOOP;
ELSE
  LOOP
        IF dbms_sql.fetch_rows(c) > 0 THEN
                dbms_sql.column_value(c, 1, v_cr_id);
                dbms_sql.column_value(c, 2, v_trx_date);
                dbms_sql.column_value(c, 3, v_gl_date);
                dbms_sql.column_value(c, 4, v_ex_date);
                dbms_sql.column_value(c, 5, v_ex_rate_type);
                dbms_sql.column_value(c, 6, v_ex_rate);
                dbms_sql.column_value(c, 7, v_currency);
                dbms_sql.column_value(c, 8, v_amount);
                dbms_sql.column_value(c, 9, v_fac_disc_amount);
                dbms_sql.column_value(c, 10, v_mod_name);
                dbms_sql.column_value(c, 11, v_mod_vers);
                dbms_sql.column_value(c, 12, v_crh_id);
                dbms_sql.column_value(c, 13, v_crh_amount);
                dbms_sql.column_value(c, 14, v_crh_fac_disc_amt);
		dbms_sql.column_value(c, 15, v_cr_currency);
                dbms_sql.column_value(c, 16, v_ex_rate_old);
--
		 -- Lock rows
--
		BEGIN
                locked := TRUE;
                p_cr_rec.cash_receipt_id := v_cr_id;
                p_crh_rec.cash_receipt_history_id := v_crh_id;
                arp_cash_receipts_pkg.nowaitlock_fetch_p ( p_cr_rec );
                arp_cr_history_pkg.nowaitlock_fetch_p ( p_crh_rec );
                EXCEPTION WHEN OTHERS THEN
                        locked := FALSE;
                END;
--
		-- Call Clear Handler
--
/* bug: 3820774 Added the condition for v_ex_rate.
                Deleted the condition of 'v_ex_rate IS NULL'. */

                IF ( locked AND p_crh_rec.current_record_flag = 'Y'
                     AND nvl(v_ex_rate,1) > 0 ) THEN

			IF (v_currency <> v_cr_currency) THEN
			    -- 785113
			    -- Bank currency not equal to receipt currency. Calculate
			    -- new accounted amounts using the receipt amount and exch.rate.
			    --
			    v_amount := arp_util.functional_amount(
					v_crh_amount,
					ARP_GLOBAL.functional_currency,
					nvl(v_ex_rate,nvl(v_ex_rate_old,1)),
					NULL,NULL );
			    v_fac_disc_amount := arp_util.functional_amount(
					nvl(v_crh_fac_disc_amt,0),
					ARP_GLOBAL.functional_currency,
					nvl(v_ex_rate,1),
					NULL,NULL );
			END IF;

arp_standard.debug('Before calling arp_cashbook.clear');
arp_standard.debug('remitted_or_factored_or_risk :' || to_char(remitted_or_factored_or_risk));
arp_standard.debug('v_cr_id                :' || to_char(v_cr_id));
arp_standard.debug('v_trx_date[clear_date] :' || to_char(v_trx_date));
arp_standard.debug('v_ex_date              :' || to_char(v_ex_date));
arp_standard.debug('v_ex_rate              :' || to_char(v_ex_rate));
arp_standard.debug('v_ex_rate_type         :' || v_ex_rate_type);
arp_standard.debug('v_currency             :' || v_currency);
arp_standard.debug('New v_amount           :' || to_char(v_amount));
arp_standard.debug('v_fac_disc_amount      :' || to_char(v_fac_disc_amount));
arp_standard.debug('v_ex_rate_old          :' || to_char(v_ex_rate_old));
arp_standard.debug('v_cr_currency          :' || v_cr_currency);

                	arp_cashbook.clear(        v_cr_id,
                              v_trx_date,
                              v_gl_date,
			      NULL,             -- value date parameter
                              v_ex_date,
                              v_ex_rate_type,
                              v_ex_rate,
                              v_currency,
                              v_amount,
                              v_fac_disc_amount,
                              v_mod_name,
                              v_mod_vers,
			      p_crh_id      );
/* bug: 3820774 Added the handling of exception rate. */
                ELSE
                   IF v_ex_rate = -1
                      THEN
                        arp_standard.debug('ar_automatic_clearing_pkg: NO_RATE');
                        arp_standard.debug('v_cr_id        :' || to_char(v_cr_id));
                        arp_standard.debug('v_ex_date      :' || to_char(v_ex_date));
                        arp_standard.debug('v_ex_rate_type :' || v_ex_rate_type);
                        arp_standard.debug('v_ex_rate      :' || to_char(v_ex_rate));

                        fnd_file.put_line(fnd_file.log,'ar_automatic_clearing_pkg: NO_RATE');
                        fnd_file.put_line(fnd_file.log,'v_cr_id        :' || to_char(v_cr_id));
                        fnd_file.put_line(fnd_file.log,'v_ex_date      :' || to_char(v_ex_date));
                        fnd_file.put_line(fnd_file.log,'v_ex_rate_type :' || v_ex_rate_type);
                        fnd_file.put_line(fnd_file.log,'v_ex_rate      :' || to_char(v_ex_rate));

                      ELSIF v_ex_rate = -2
                      THEN
                        arp_standard.debug('ar_automatic_clearing_pkg: INVALID_CURRENCY');
                        arp_standard.debug('v_cr_id        :' || to_char(v_cr_id));
                        arp_standard.debug('v_ex_date      :' || to_char(v_ex_date));
                        arp_standard.debug('v_ex_rate_type :' || v_ex_rate_type);
                        arp_standard.debug('v_ex_rate      :' || to_char(v_ex_rate));

                        fnd_file.put_line(fnd_file.log,'ar_automatic_clearing_pkg: INVALID_CURRENCY');
                        fnd_file.put_line(fnd_file.log,'v_cr_id        :' || to_char(v_cr_id));
                        fnd_file.put_line(fnd_file.log,'v_ex_date      :' || to_char(v_ex_date));
                        fnd_file.put_line(fnd_file.log,'v_ex_rate_type :' || v_ex_rate_type);
                        fnd_file.put_line(fnd_file.log,'v_ex_rate      :' || to_char(v_ex_rate));

                   END IF;
		END IF;
        ELSE
                -- no more rows
                EXIT;
        END IF;
  END LOOP;
END IF;
--
dbms_sql.close_cursor(c);
--
EXCEPTION
WHEN OTHERS THEN
        arp_standard.debug('Exception: ar_automatic_clearing_pkg ');
        RAISE;
--
END;
--
function ar_automatic_clearing
(
	p_clr_remitted_receipts		IN VARCHAR2,
	p_clr_disc_receipts		IN VARCHAR2,
	p_eliminate_bank_risk		IN VARCHAR2,
	p_clear_date			IN DATE,
	p_gl_date			IN DATE,
	p_customer_name_low		IN VARCHAR2,
	p_customer_name_high		IN VARCHAR2,
	p_customer_number_low		IN VARCHAR2,
	p_customer_number_high		IN VARCHAR2,
	p_receipt_number_low		IN VARCHAR2,
	p_receipt_number_high		IN VARCHAR2,
	p_remittance_bank_account_id	IN NUMBER,
	p_payment_method_id		IN NUMBER,
	p_exchange_rate_type		IN VARCHAR2,
	p_batch_id  		 	IN NUMBER,
	p_undo_clearing			IN VARCHAR2
) RETURN BOOLEAN IS
--
remitted_or_factored_or_risk	integer := 0;
--
BEGIN
--
IF (p_clr_remitted_receipts = 'Y') THEN
	remitted_or_factored_or_risk := 1;
	clr_remit_disc_risk_receipts (
		p_clear_date,
		p_gl_date,
		p_customer_name_low,
		p_customer_name_high,
		p_customer_number_low,
		p_customer_number_high,
		p_receipt_number_low,
		p_receipt_number_high,
		p_remittance_bank_account_id,
		p_payment_method_id,
		p_exchange_rate_type,
		p_batch_id,
		remitted_or_factored_or_risk);
END IF;
--
IF (p_clr_disc_receipts = 'Y') THEN
        remitted_or_factored_or_risk := 2;
        clr_remit_disc_risk_receipts (
                p_clear_date,
                p_gl_date,
                p_customer_name_low,
                p_customer_name_high,
                p_customer_number_low,
                p_customer_number_high,
                p_receipt_number_low,
                p_receipt_number_high,
                p_remittance_bank_account_id,
                p_payment_method_id,
                p_exchange_rate_type,
		p_batch_id,
                remitted_or_factored_or_risk);
END IF;
--
IF (p_eliminate_bank_risk = 'Y') THEN
        remitted_or_factored_or_risk := 3;
        clr_remit_disc_risk_receipts (
                p_clear_date,
                p_gl_date,
                p_customer_name_low,
                p_customer_name_high,
                p_customer_number_low,
                p_customer_number_high,
                p_receipt_number_low,
                p_receipt_number_high,
                p_remittance_bank_account_id,
                p_payment_method_id,
                p_exchange_rate_type,
		p_batch_id,
		remitted_or_factored_or_risk );
END IF;
--
return(TRUE);
--
EXCEPTION
WHEN OTHERS THEN
	arp_standard.debug('Exception: ar_automatic_clearing_pkg ');
	RAISE;
END;
--
/*========================================================================+
 |  PROCEDURE  ar_automatic_clearing_parallel                             |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 | This is created to parallelize the Automatic Clearance for Reecipts    |
 | This procedure is called from ar_auto_clearing_in_parallel()           |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                     Author            Description of Changes      |
 | 19-FEB-2008              aghoraka           Created                    |
 *=========================================================================*/
procedure ar_automatic_clearing_parallel
(	P_ERRBUF                        OUT NOCOPY VARCHAR2,
	P_RETCODE		        OUT NOCOPY NUMBER,
	p_clr_remitted_receipts		IN VARCHAR2,
	p_clr_disc_receipts		IN VARCHAR2,
	p_eliminate_bank_risk		IN VARCHAR2,
	p_worker_number			IN NUMBER DEFAULT 0,
	p_request_id  			IN NUMBER DEFAULT 0
) IS
--
remitted_or_factored_or_risk	integer := 0;
--
BEGIN
--
IF (p_clr_remitted_receipts = 'Y') THEN
	remitted_or_factored_or_risk := 1;
	clr_remit_disc_risk_rcpts_pa (
		p_worker_number,
		p_request_id,
                remitted_or_factored_or_risk  );
END IF;
--
IF (p_clr_disc_receipts = 'Y') THEN
        remitted_or_factored_or_risk := 2;
        clr_remit_disc_risk_rcpts_pa (
		p_worker_number,
		p_request_id,
                remitted_or_factored_or_risk  );
END IF;
--
IF (p_eliminate_bank_risk = 'Y') THEN
        remitted_or_factored_or_risk := 3;
       clr_remit_disc_risk_rcpts_pa (
		p_worker_number,
		p_request_id,
                remitted_or_factored_or_risk  );
END IF;
--
EXCEPTION
WHEN OTHERS THEN
	arp_standard.debug('Exception: ar_automatic_clearing_pkg ');
	RAISE;
END;

--
/*========================================================================+
 |  FUNCTION  ar_auto_clearing_in_parallel                               |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 | This drives the parallelization of Automatic Clearance process.        |
 | This spawns the AUTOCLEAR( ar_automatic_clearing_parallel) program.    |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                     Author            Description of Changes      |
 | 19-FEB-2008              aghoraka           Created                    |
 *=========================================================================*/
function ar_auto_clearing_in_parallel
(       p_clr_remitted_receipts         IN VARCHAR2,
        p_clr_disc_receipts             IN VARCHAR2,
        p_eliminate_bank_risk           IN VARCHAR2,
        p_clear_date                    IN DATE,
        p_gl_date                       IN DATE,
        p_customer_name_low             IN VARCHAR2,
        p_customer_name_high            IN VARCHAR2,
        p_customer_number_low           IN VARCHAR2,
        p_customer_number_high          IN VARCHAR2,
        p_receipt_number_low            IN VARCHAR2,
        p_receipt_number_high           IN VARCHAR2,
        p_remittance_bank_account_id    IN NUMBER,
        p_payment_method_id             IN NUMBER,
        p_exchange_rate_type            IN VARCHAR2,
	p_batch_id       		IN NUMBER,
	p_undo_clearing			IN VARCHAR2,
	P_total_workers			IN NUMBER)
RETURN BOOLEAN IS
--
TYPE req_status_typ  IS RECORD (
    request_id		NUMBER(15),
    dev_phase		VARCHAR2(255),
    dev_status		VARCHAR2(255),
    message		VARCHAR2(2000),
    phase		VARCHAR2(255),
    status		VARCHAR2(255));
    l_org_id		NUMBER;
    l_request_id	NUMBER(15);

   TYPE req_status_tab_typ   IS TABLE OF req_status_typ INDEX BY BINARY_INTEGER;

   l_req_status_tab	req_status_tab_typ;
   l_complete		BOOLEAN := FALSE;
   P_ERRBUF		VARCHAR2(2000);
   P_RETCODE		NUMBER(1) := 0;
   remitted_or_factored_or_risk	integer := 0;
   l_master_request_id NUMBER(15);
   l_count NUMBER;
   error_in_child EXCEPTION;

    PROCEDURE submit_subrequest (p_worker_number IN NUMBER,
                                 p_org_id IN NUMBER,
                                 p_master_request_id IN NUMBER) IS
    BEGIN
	fnd_file.put_line( FND_FILE.LOG, 'submit_subrequest()+' );

	FND_REQUEST.SET_ORG_ID(p_org_id);

	l_request_id := FND_REQUEST.submit_request( 'AR', 'AUTOCLEAR',
				        '',
					SYSDATE,
					FALSE,
					p_clr_remitted_receipts,
					p_clr_disc_receipts,
					p_eliminate_bank_risk,
					p_worker_number,
					p_master_request_id );

	IF (l_request_id = 0) THEN
	    arp_util.debug('Can not start for worker_id: ' ||p_worker_number );
	    P_ERRBUF := fnd_Message.get;
	    P_RETCODE := 2;
	    return;
	ELSE
	    commit;
	    arp_util.debug('Child request id: ' ||l_request_id || ' started for
worker_id: ' ||p_worker_number );
	END IF;

	 l_req_status_tab(p_worker_number).request_id := l_request_id;

	 fnd_file.put_line( FND_FILE.LOG, 'submit_subrequest()-');

    END submit_subrequest;

BEGIN
    fnd_file.put_line( FND_FILE.LOG, 'ar_automatic_clearing_in_parallel()+');

    --fetch org id,need to set it for child requests
    SELECT org_id
    INTO l_org_id
    FROM ar_system_parameters;

    l_master_request_id := arp_standard.profile.request_id;

    IF (p_clr_remitted_receipts = 'Y') THEN
	remitted_or_factored_or_risk := 1;
	populate_interim_table (
		p_clear_date,
		p_gl_date,
		p_customer_name_low,
		p_customer_name_high,
		p_customer_number_low,
		p_customer_number_high,
		p_receipt_number_low,
		p_receipt_number_high,
		p_remittance_bank_account_id,
		p_payment_method_id,
		p_exchange_rate_type,
		p_batch_id,
		remitted_or_factored_or_risk,
		l_master_request_id,
		p_total_workers  );
END IF;
--
IF (p_clr_disc_receipts = 'Y') THEN
        remitted_or_factored_or_risk := 2;
        populate_interim_table (
                p_clear_date,
                p_gl_date,
                p_customer_name_low,
                p_customer_name_high,
                p_customer_number_low,
                p_customer_number_high,
                p_receipt_number_low,
                p_receipt_number_high,
                p_remittance_bank_account_id,
                p_payment_method_id,
                p_exchange_rate_type,
		p_batch_id,
                remitted_or_factored_or_risk,
		l_master_request_id,
		p_total_workers  );
END IF;
--
IF (p_eliminate_bank_risk = 'Y') THEN
        remitted_or_factored_or_risk := 3;
        populate_interim_table (
                p_clear_date,
                p_gl_date,
                p_customer_name_low,
                p_customer_name_high,
                p_customer_number_low,
                p_customer_number_high,
                p_receipt_number_low,
                p_receipt_number_high,
                p_remittance_bank_account_id,
                p_payment_method_id,
                p_exchange_rate_type,
		p_batch_id,
		remitted_or_factored_or_risk,
		l_master_request_id,
		p_total_workers );
END IF;
BEGIN
  select count(*)
  into l_count
  from ar_autoclear_interim
  where request_id = l_master_request_id;
EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line( FND_FILE.LOG, SQLERRM);
    l_count := 0;
END;
fnd_file.put_line( FND_FILE.LOG, 'No of Receipts Selected :'||l_count);
IF l_count > 0 THEN
    --Invoke the child programs
    FOR l_worker_number IN 1..p_total_workers LOOP
	fnd_file.put_line(FND_FILE.LOG,'worker # : ' || l_worker_number );
	submit_subrequest (l_worker_number,l_org_id,l_master_request_id);
    END LOOP;

    arp_standard.debug ( 'The Master program waits for child processes');

    -- Wait for the completion of the submitted requests
    FOR i in 1..p_total_workers LOOP

	l_complete := FND_CONCURRENT.WAIT_FOR_REQUEST(
		   request_id   => l_req_status_tab(i).request_id,
		   interval     => 30,
		   max_wait     =>144000,
		   phase        =>l_req_status_tab(i).phase,
		   status       =>l_req_status_tab(i).status,
		   dev_phase    =>l_req_status_tab(i).dev_phase,
		   dev_status   =>l_req_status_tab(i).dev_status,
		   message      =>l_req_status_tab(i).message);

	IF l_req_status_tab(i).dev_phase <> 'COMPLETE' THEN
	    P_RETCODE := 2;
	    arp_util.debug('Worker # '|| i||' has a phase
                        '||l_req_status_tab(i).dev_phase);

	ELSIF l_req_status_tab(i).dev_phase = 'COMPLETE'
              AND l_req_status_tab(i).dev_status <> 'NORMAL' THEN
	    P_RETCODE := 2;
	    arp_util.debug('Worker # '|| i||' completed with status
                        '||l_req_status_tab(i).dev_status);
	ELSE
	    arp_util.debug('Worker # '|| i||' completed successfully');
	END IF;

    END LOOP;
    DELETE FROM ar_autoclear_interim
    WHERE request_id = l_master_request_id;
    commit;
END IF;

    IF P_RETCODE = 2 THEN
	fnd_file.put_line( FND_FILE.LOG, 'Master Program completed in Error.');
	fnd_file.put_line( FND_FILE.LOG, 'Possibly Child process(es) might have errored out.');
	arp_util.debug('Exception: ar_automatic_clearing_pkg '|| SQLERRM);
	RAISE error_in_child;
    END IF;
    fnd_file.put_line( FND_FILE.LOG, 'ar_automatic_clearing_in_parallel()-');
    return TRUE;
EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('Exception: ar_automatic_clearing_pkg '|| SQLERRM);
    RAISE ;
END;
--
procedure populate_interim_table
(	p_clear_date                    IN DATE,
	p_gl_date			IN DATE,
	p_customer_name_low             IN VARCHAR2,
	p_customer_name_high            IN VARCHAR2,
	p_customer_number_low           IN VARCHAR2,
	p_customer_number_high          IN VARCHAR2,
	p_receipt_number_low            IN VARCHAR2,
	p_receipt_number_high           IN VARCHAR2,
	p_remittance_bank_account_id    IN NUMBER,
	p_payment_method_id             IN NUMBER,
	p_exchange_rate_type            IN VARCHAR2,
	p_batch_id       		IN NUMBER,
	remitted_or_factored_or_risk	IN integer,
	p_request_id			IN NUMBER,
	p_total_workers			IN NUMBER) IS
--
statement	varchar2(5000) := NULL;
c		integer;
ignore		integer;
l_request_id    NUMBER(15);
l_worker_number NUMBER(10);
v_cr_id         ar_cash_receipts.cash_receipt_id%TYPE;
v_crh_id        ar_cash_receipt_history.cash_receipt_history_id%TYPE;
v_trx_date      ar_cash_receipt_history.trx_date%TYPE;
v_gl_date       ar_cash_receipt_history.gl_date%TYPE;
v_ex_date       ar_cash_receipt_history.exchange_date%TYPE;
v_ex_rate_type  ar_cash_receipts.exchange_rate_type%TYPE;
v_ex_rate       ar_cash_receipts.exchange_rate%TYPE;
v_currency      ce_bank_accounts.currency_code%TYPE;
v_amount        ar_cash_receipt_history.amount%TYPE;
v_fac_disc_amount ar_cash_receipt_history.factor_discount_amount%TYPE;
v_mod_name      varchar2(30);
v_mod_vers      varchar2(5);
p_crh_id	ar_cash_receipt_history.cash_receipt_history_id%TYPE;
v_set_of_bks_id ar_system_parameters.set_of_books_id%TYPE;
p_cr_rec	ar_cash_receipts%ROWTYPE;
p_crh_rec	ar_cash_receipt_history%ROWTYPE;
locked		BOOLEAN;

-- 785113: Added to compute new acctd amts based on a different exchange rate.
v_crh_amount     ar_cash_receipt_history.amount%TYPE;
v_crh_fac_disc_amt     ar_cash_receipt_history.amount%TYPE;
v_ex_rate_old   ar_cash_receipts.exchange_rate%TYPE;
v_cr_currency   ce_bank_accounts.currency_code%TYPE;

--
BEGIN
--
fnd_file.put_line( FND_FILE.LOG, 'populate_interim_table()+');
select set_of_books_id INTO v_set_of_bks_id from ar_system_parameters;
--
IF ( remitted_or_factored_or_risk = 1) THEN
    statement := 'INSERT INTO ar_autoclear_interim
                  ( cash_receipt_id,
                    trx_date,
                    gl_date,
                    exchange_date,
                    exchange_rate_type,
                    exchange_rate,
                    currency_code,
                    amount,
                    factor_discount_amount,
                    module_name,
                    module_version,
                    cash_receipt_history_id,
                    crh_amount,
                    crh_factor_discount_amount,
                    cr_currency_code,
                    exchange_rate_old,
                    current_worker,
                    request_id,
                    type
                  ) ';
	main_select_remitted(
			statement,
                        p_total_workers,
                        p_request_id );
END IF;
--
IF ( remitted_or_factored_or_risk = 2) THEN
    statement := 'INSERT INTO ar_autoclear_interim
                  ( cash_receipt_id,
                    trx_date,
                    gl_date,
                    exchange_date,
                    exchange_rate_type,
                    exchange_rate,
                    currency_code,
                    amount,
                    factor_discount_amount,
                    module_name,
                    module_version,
                    cash_receipt_history_id,
                    crh_amount,
                    crh_factor_discount_amount,
                    cr_currency_code,
                    exchange_rate_old,
                    current_worker,
                    request_id,
                    type
                  ) ';
        main_select_factored(
                        statement,
                        p_total_workers,
                        p_request_id  );
END IF;
--
IF ( remitted_or_factored_or_risk = 3) THEN
    statement := 'INSERT INTO ar_autoclear_interim
                  ( cash_receipt_id,
                    trx_date,
                    gl_date,
                    module_name,
                    module_version,
                    cash_receipt_history_id,
                    current_worker,
                    request_id,
                    type
                  ) ';
        main_select_risk(
                        statement,
                        p_total_workers,
                        p_request_id  );
END IF;
--
c := dbms_sql.open_cursor;
--
-- Build expanded select-statement depending on parameters
--
expand_stmt(	p_customer_name_low,
		p_customer_name_high,
		p_customer_number_low,
		p_customer_number_high,
		p_receipt_number_low,
		p_receipt_number_high,
		p_remittance_bank_account_id,
		p_payment_method_id,
                p_batch_id,
		statement		);
--
dbms_sql.parse(c, statement, dbms_sql.native);
--
IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Inside populate_interim_table()');
        arp_standard.debug(   'Statement ' || statement);
END IF;
-- Bind variables
--
dbms_sql.bind_variable(c, ':b_clear_date' ,p_clear_date);
dbms_sql.bind_variable(c, ':b_gl_date' ,p_gl_date);
--
IF ( remitted_or_factored_or_risk <> 3) THEN
dbms_sql.bind_variable(c, ':b_exchange_rate_type' ,p_exchange_rate_type);
dbms_sql.bind_variable(c, ':b_set_of_bks_id' ,v_set_of_bks_id);

-- Bug 706935.
-- Removed this line.
-- dbms_sql.bind_variable(c, ':b_batch_id' ,p_batch_id);

END IF;
--
ar_bind_variables(	p_customer_name_low,
			p_customer_name_high,
			p_customer_number_low,
			p_customer_number_high,
			p_receipt_number_low,
			p_receipt_number_high,
			p_remittance_bank_account_id,
			p_payment_method_id,
			p_batch_id,
			c	);
--
ignore := dbms_sql.execute(c);
IF PG_DEBUG IN ('Y','C') THEN
    fnd_file.put_line(fnd_file.LOG, 'No of Records Selected : '|| ignore);
END IF;
--
commit; -- Commit the values inserted into the interim table.
--
dbms_sql.close_cursor(c);
fnd_file.put_line( FND_FILE.LOG, 'populate_interim_table()-');
--
EXCEPTION
WHEN OTHERS THEN
        arp_standard.debug('Exception: ar_automatic_clearing_pkg ');
        RAISE;
--
END;
--
procedure main_select_risk_parallel
(
        statement IN OUT NOCOPY VARCHAR2       ) IS
--
BEGIN
--
/* 07-JUL-2000 J Rautiainen BR Implementation
 * Receipts created by the Bills Receivable transaction remittance process
 * having BR_REMIT receipt class cannot be risk eliminated */
/*5444413 Index hint added*/
fnd_file.put_line(fnd_file.log, 'main_select_risk_parallel()+');
statement :=    'select ' ||
                        'cash_receipt_id, ' ||
                        'trx_date, ' ||
                        'gl_date , ' ||
                        ' module_name, ' ||
                        ' module_version, ' ||
                        'cash_receipt_history_id  ' ||
                'from ' ||
                        'ar_autoclear_interim ' ||
                'where ' ||
                        'request_id = :b_request_id ' ||
                'and    current_worker = :b_worker_number '||
  'and type = ''RISK'' ';
IF PG_DEBUG in ('Y', 'C') THEN
	 arp_standard.debug(   'Statement ' || statement);
END IF;
fnd_file.put_line(fnd_file.log, 'main_select_risk_parallel()-');
--
EXCEPTION
WHEN OTHERS THEN
        arp_standard.debug('Exception: ar_automatic_clearing_pkg ');
        RAISE;
--
END;
--
procedure main_select_factored_parallel
(
        statement IN OUT NOCOPY VARCHAR2       ) IS
--
BEGIN
--
/* Bug 2484984 Modified the call gl_currency_api.get_rate so that
   there is an NVL for the exchange_rate_type parameter rather
   than an NVL for the function call itself . */

/* Bug 3820774 Replaced the get_rate with get_rate_sql. */
/*Bug5444413 Added hint */
fnd_file.put_line(fnd_file.log, 'main_select_factored_parallel()+');
statement :=    'select ' ||
                        'cash_receipt_id, '||
                        'trx_date, ' ||
                        'gl_date, ' ||
                        'exchange_date, ' ||
                        'exchange_rate_type, ' ||
                        'exchange_rate, ' ||
                        'currency_code, ' ||
                        'amount, ' ||
                        'factor_discount_amount, ' ||
                        ' module_name, ' ||
                        ' module_version, ' ||
                        'cash_receipt_history_id, ' ||
                        'crh_amount, ' ||
                        'crh_factor_discount_amount, ' ||
                        'cr_currency_code, ' ||
                        'exchange_rate_old ' ||
                'from ' ||
                        'ar_autoclear_interim ' ||
                'where ' ||
                        'request_id = :b_request_id ' ||
                'and    current_worker = :b_worker_number '||
                'and    type = ''FACTOR'' ';
IF PG_DEBUG in ('Y', 'C') THEN
	 arp_standard.debug(   'Statement ' || statement);
END IF;
fnd_file.put_line(fnd_file.log, 'main_select_factored_parallel()-');
EXCEPTION
WHEN OTHERS THEN
        arp_standard.debug('Exception: ar_automatic_clearing_pkg ');
        RAISE;
--
END;
--
procedure main_select_remitted_parallel
(
	statement IN OUT NOCOPY VARCHAR2	) IS
--
BEGIN
--
/* Bug 2484984 Modified the call gl_currency_api.get_rate so that
   there is an NVL for the exchange_rate_type parameter rather
   than an NVL for the function call itself . */
/* Bug 3820774 Replaced the get_rate with get_rate_sql. */
/*5444413 hint added here*/
fnd_file.put_line(fnd_file.log, 'main_select_remitted_parallel()+');
statement :=    'select ' ||
                        'cash_receipt_id, '||
                        'trx_date, ' ||
                        'gl_date, ' ||
                        'exchange_date, ' ||
                        'exchange_rate_type, ' ||
        		            'exchange_rate, ' ||
                        'currency_code, ' ||
                        'amount, ' ||
                        'factor_discount_amount, ' ||
        		' module_name, ' ||
        		' module_version, ' ||
        		'cash_receipt_history_id, ' ||
                        'crh_amount, ' ||
                        'crh_factor_discount_amount, ' ||
                        'cr_currency_code, ' ||
                        'exchange_rate_old ' ||
                'from ' ||
                        'ar_autoclear_interim ' ||
                'where ' ||
                        'request_id = :b_request_id ' ||
                'and    current_worker = :b_worker_number '||
                'and    type = ''REMIT'' ';
IF PG_DEBUG in ('Y', 'C') THEN
	 arp_standard.debug(   'Statement ' || statement);
END IF;
fnd_file.put_line(fnd_file.log, 'main_select_remitted_parallel()-');
--
EXCEPTION
WHEN OTHERS THEN
        arp_standard.debug('Exception: ar_automatic_clearing_pkg ');
        RAISE;
--
END;
--
procedure ar_bind_variables_parallel
(
	p_worker_number			IN NUMBER,
	p_request_id   			IN NUMBER,
	c				IN integer ) IS
l_worker_number NUMBER;
--
BEGIN
--
IF ( p_worker_number IS NOT NULL ) THEN
dbms_sql.bind_variable(c, ':b_worker_number' ,p_worker_number);
END IF;
--
IF ( p_request_id IS NOT NULL ) THEN
dbms_sql.bind_variable(c, ':b_request_id' ,p_request_id);
END IF;
--
EXCEPTION
WHEN OTHERS THEN
        arp_standard.debug('Exception: ar_automatic_clearing_pkg ');
        RAISE;
--
END;
--
procedure clr_remit_disc_risk_rcpts_pa
(	p_worker_number			IN NUMBER,
	p_request_id   			IN NUMBER,
  remitted_or_factored_or_risk IN NUMBER) IS
--
statement	varchar2(3000) := NULL;
c		integer;
ignore		integer;
v_cr_id         ar_cash_receipts.cash_receipt_id%TYPE;
v_crh_id        ar_cash_receipt_history.cash_receipt_history_id%TYPE;
v_trx_date      ar_cash_receipt_history.trx_date%TYPE;
v_gl_date       ar_cash_receipt_history.gl_date%TYPE;
v_ex_date       ar_cash_receipt_history.exchange_date%TYPE;
v_ex_rate_type  ar_cash_receipts.exchange_rate_type%TYPE;
v_ex_rate       ar_cash_receipts.exchange_rate%TYPE;
v_currency      ce_bank_accounts.currency_code%TYPE;
v_amount        ar_cash_receipt_history.amount%TYPE;
v_fac_disc_amount ar_cash_receipt_history.factor_discount_amount%TYPE;
v_mod_name      varchar2(30);
v_mod_vers      varchar2(5);
p_crh_id	ar_cash_receipt_history.cash_receipt_history_id%TYPE;
v_set_of_bks_id ar_system_parameters.set_of_books_id%TYPE;
p_cr_rec	ar_cash_receipts%ROWTYPE;
p_crh_rec	ar_cash_receipt_history%ROWTYPE;
locked		BOOLEAN;

-- 785113: Added to compute new acctd amts based on a different exchange rate.
v_crh_amount     ar_cash_receipt_history.amount%TYPE;
v_crh_fac_disc_amt     ar_cash_receipt_history.amount%TYPE;
v_ex_rate_old   ar_cash_receipts.exchange_rate%TYPE;
v_cr_currency   ce_bank_accounts.currency_code%TYPE;

--
BEGIN
--
fnd_file.put_line(fnd_file.log, 'clr_remit_disc_risk_rcpts_pa()+');
select set_of_books_id INTO v_set_of_bks_id from ar_system_parameters;
--
IF ( remitted_or_factored_or_risk = 1) THEN
	main_select_remitted_parallel(
			statement );
END IF;
--
IF ( remitted_or_factored_or_risk = 2) THEN
        main_select_factored_parallel(
                        statement );
END IF;
--
IF ( remitted_or_factored_or_risk = 3) THEN
        main_select_risk_parallel(
                        statement );
END IF;
--
c := dbms_sql.open_cursor;
--
dbms_sql.parse(c, statement, dbms_sql.native);
--
-- Bind variables
--
fnd_file.put_line(fnd_file.log, 'Worker No ' ||p_worker_number);
fnd_file.put_line(fnd_file.log, 'Request_id '||p_request_id);
ar_bind_variables_parallel(
			p_worker_number,
			p_request_id,
			c	);
--
IF ( remitted_or_factored_or_risk = 3) THEN
	dbms_sql.define_column(c, 1, v_cr_id);
	dbms_sql.define_column(c, 2, v_trx_date);
	dbms_sql.define_column(c, 3, v_gl_date);
	dbms_sql.define_column(c, 4, v_mod_name, 30);
	dbms_sql.define_column(c, 5, v_mod_vers, 5);
	dbms_sql.define_column(c, 6, v_crh_id);
ELSE
	dbms_sql.define_column(c, 1, v_cr_id);
	dbms_sql.define_column(c, 2, v_trx_date);
	dbms_sql.define_column(c, 3, v_gl_date);
	dbms_sql.define_column(c, 4, v_ex_date);
	dbms_sql.define_column(c, 5, v_ex_rate_type, 30);
	dbms_sql.define_column(c, 6, v_ex_rate);
	dbms_sql.define_column(c, 7, v_currency, 15);
	dbms_sql.define_column(c, 8, v_amount);
	dbms_sql.define_column(c, 9, v_fac_disc_amount);
	dbms_sql.define_column(c, 10, v_mod_name, 30);
	dbms_sql.define_column(c, 11, v_mod_vers, 5);
	dbms_sql.define_column(c, 12, v_crh_id);
	dbms_sql.define_column(c, 13, v_crh_amount);
	dbms_sql.define_column(c, 14, v_crh_fac_disc_amt);
	dbms_sql.define_column(c, 15, v_cr_currency, 15);
	dbms_sql.define_column(c, 16, v_ex_rate_old);
END IF;
--
ignore := dbms_sql.execute(c);
--
IF ( remitted_or_factored_or_risk = 3) THEN
  LOOP
	IF dbms_sql.fetch_rows(c) > 0 THEN
                dbms_sql.column_value(c, 1, v_cr_id);
                dbms_sql.column_value(c, 2, v_trx_date);
                dbms_sql.column_value(c, 3, v_gl_date);
                dbms_sql.column_value(c, 4, v_mod_name);
                dbms_sql.column_value(c, 5, v_mod_vers);
                dbms_sql.column_value(c, 6, v_crh_id);
--
		-- Lock rows
--
		BEGIN
		locked := TRUE;
		p_cr_rec.cash_receipt_id := v_cr_id;
		p_crh_rec.cash_receipt_history_id := v_crh_id;
		arp_cash_receipts_pkg.nowaitlock_fetch_p ( p_cr_rec );
		arp_cr_history_pkg.nowaitlock_fetch_p ( p_crh_rec );
		EXCEPTION WHEN OTHERS THEN
			locked := FALSE;
		END;
--
		-- Call Risk Handler
--
		IF ( locked AND p_crh_rec.current_record_flag = 'Y' ) THEN
		    arp_cashbook.risk_eliminate (	v_cr_id,
					v_trx_date,
					v_gl_date,
					v_mod_name,
					v_mod_vers,
					p_crh_id	);
		END IF;
	ELSE
		-- no more rows
        	EXIT;
	END IF;
--
  END LOOP;
ELSE
  LOOP
        IF dbms_sql.fetch_rows(c) > 0 THEN
                dbms_sql.column_value(c, 1, v_cr_id);
                dbms_sql.column_value(c, 2, v_trx_date);
                dbms_sql.column_value(c, 3, v_gl_date);
                dbms_sql.column_value(c, 4, v_ex_date);
                dbms_sql.column_value(c, 5, v_ex_rate_type);
                dbms_sql.column_value(c, 6, v_ex_rate);
                dbms_sql.column_value(c, 7, v_currency);
                dbms_sql.column_value(c, 8, v_amount);
                dbms_sql.column_value(c, 9, v_fac_disc_amount);
                dbms_sql.column_value(c, 10, v_mod_name);
                dbms_sql.column_value(c, 11, v_mod_vers);
                dbms_sql.column_value(c, 12, v_crh_id);
                dbms_sql.column_value(c, 13, v_crh_amount);
                dbms_sql.column_value(c, 14, v_crh_fac_disc_amt);
		            dbms_sql.column_value(c, 15, v_cr_currency);
                dbms_sql.column_value(c, 16, v_ex_rate_old);
--
		 -- Lock rows
--
		BEGIN
                locked := TRUE;
                p_cr_rec.cash_receipt_id := v_cr_id;
                p_crh_rec.cash_receipt_history_id:= v_crh_id;
                arp_cash_receipts_pkg.nowaitlock_fetch_p ( p_cr_rec );
                arp_cr_history_pkg.nowaitlock_fetch_p ( p_crh_rec );
                EXCEPTION WHEN OTHERS THEN
                        locked := FALSE;
                END;
--
		-- Call Clear Handler
--
/* bug: 3820774 Added the condition for v_ex_rate.
                Deleted the condition of 'v_ex_rate IS NULL'. */
                IF ( locked AND p_crh_rec.current_record_flag = 'Y'
                     AND v_ex_rate > 0 ) THEN
			IF (v_currency <> v_cr_currency) THEN
			    -- 785113
			    -- Bank currency not equal to receipt currency. Calculate
			    -- new accounted amounts using the receipt amount and exch.rate.
			    --
			    v_amount := arp_util.functional_amount(
					v_crh_amount,
					ARP_GLOBAL.functional_currency,
					nvl(v_ex_rate,nvl(v_ex_rate_old,1)),
					NULL,NULL );
			    v_fac_disc_amount := arp_util.functional_amount(
					nvl(v_crh_fac_disc_amt,0),
					ARP_GLOBAL.functional_currency,
					nvl(v_ex_rate,1),
					NULL,NULL );
			END IF;
arp_standard.debug('Before calling arp_cashbook.clear');
arp_standard.debug('remitted_or_factored_or_risk :' || to_char(remitted_or_factored_or_risk));
arp_standard.debug('v_cr_id                :' || to_char(v_cr_id));
arp_standard.debug('v_trx_date[clear_date] :' || to_char(v_trx_date));
arp_standard.debug('v_ex_date              :' || to_char(v_ex_date));
arp_standard.debug('v_ex_rate              :' || to_char(v_ex_rate));
arp_standard.debug('v_ex_rate_type         :' || v_ex_rate_type);
arp_standard.debug('v_currency             :' || v_currency);
arp_standard.debug('New v_amount           :' || to_char(v_amount));
arp_standard.debug('v_fac_disc_amount      :' || to_char(v_fac_disc_amount));
arp_standard.debug('v_ex_rate_old          :' || to_char(v_ex_rate_old));
arp_standard.debug('v_cr_currency          :' || v_cr_currency);

                	arp_cashbook.clear(        v_cr_id,
                              v_trx_date,
                              v_gl_date,
			      NULL,             -- value date parameter
                              v_ex_date,
                              v_ex_rate_type,
                              v_ex_rate,
                              v_currency,
                              v_amount,
                              v_fac_disc_amount,
                              v_mod_name,
                              v_mod_vers,
			      p_crh_id      );

/* bug: 3820774 Added the handling of exception rate. */
                ELSE
                   IF v_ex_rate = -1
                      THEN
                        arp_standard.debug('ar_automatic_clearing_pkg: NO_RATE');
                        arp_standard.debug('v_cr_id        :' || to_char(v_cr_id));
                        arp_standard.debug('v_ex_date      :' || to_char(v_ex_date));
                        arp_standard.debug('v_ex_rate_type :' || v_ex_rate_type);
                        arp_standard.debug('v_ex_rate      :' || to_char(v_ex_rate));

                        fnd_file.put_line(fnd_file.log,'ar_automatic_clearing_pkg: NO_RATE');
                        fnd_file.put_line(fnd_file.log,'v_cr_id        :' || to_char(v_cr_id));
                        fnd_file.put_line(fnd_file.log,'v_ex_date      :' || to_char(v_ex_date));
                        fnd_file.put_line(fnd_file.log,'v_ex_rate_type :' || v_ex_rate_type);
                        fnd_file.put_line(fnd_file.log,'v_ex_rate      :' || to_char(v_ex_rate));

                      ELSIF v_ex_rate = -2
                      THEN
                        arp_standard.debug('ar_automatic_clearing_pkg: INVALID_CURRENCY');
                        arp_standard.debug('v_cr_id        :' || to_char(v_cr_id));
                        arp_standard.debug('v_ex_date      :' || to_char(v_ex_date));
                        arp_standard.debug('v_ex_rate_type :' || v_ex_rate_type);
                        arp_standard.debug('v_ex_rate      :' || to_char(v_ex_rate));

                        fnd_file.put_line(fnd_file.log,'ar_automatic_clearing_pkg: INVALID_CURRENCY');
                        fnd_file.put_line(fnd_file.log,'v_cr_id        :' || to_char(v_cr_id));
                        fnd_file.put_line(fnd_file.log,'v_ex_date      :' || to_char(v_ex_date));
                        fnd_file.put_line(fnd_file.log,'v_ex_rate_type :' || v_ex_rate_type);
                        fnd_file.put_line(fnd_file.log,'v_ex_rate      :' || to_char(v_ex_rate));

                   END IF;
		END IF;
        ELSE
                -- no more rows
                EXIT;
        END IF;
  END LOOP;
END IF;
--
dbms_sql.close_cursor(c);
fnd_file.put_line(fnd_file.log, 'clr_remit_disc_risk_rcpts_pa()-');
--
EXCEPTION
WHEN OTHERS THEN
        arp_standard.debug('Exception: ar_automatic_clearing_pkg ');
        RAISE;
--
END;
--
END arp_automatic_clearing_pkg;

/
