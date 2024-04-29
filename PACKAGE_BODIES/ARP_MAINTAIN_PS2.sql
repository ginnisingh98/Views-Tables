--------------------------------------------------------
--  DDL for Package Body ARP_MAINTAIN_PS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_MAINTAIN_PS2" AS
/* $Header: ARTEMP2B.pls 120.26.12010000.5 2009/09/14 12:02:25 rasarasw ship $ */
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/* =======================================================================
 | Global Data Types
 * ======================================================================*/
SUBTYPE ae_doc_rec_type   IS arp_acct_main.ae_doc_rec_type;

------------------------------------------------------------------------
-- Private types
------------------------------------------------------------------------
-- Constants
--
-- Linefeed character
--
CRLF            CONSTANT VARCHAR2(1) := arp_global.CRLF;

MSG_LEVEL_BASIC 	CONSTANT BINARY_INTEGER := arp_global.MSG_LEVEL_BASIC;
MSG_LEVEL_TIMING 	CONSTANT BINARY_INTEGER := arp_global.MSG_LEVEL_TIMING;
MSG_LEVEL_DEBUG 	CONSTANT BINARY_INTEGER := arp_global.MSG_LEVEL_DEBUG;
MSG_LEVEL_DEBUG2 	CONSTANT BINARY_INTEGER := arp_global.MSG_LEVEL_DEBUG2;
MSG_LEVEL_DEVELOP 	CONSTANT BINARY_INTEGER :=
				arp_global.MSG_LEVEL_DEVELOP;

YES			CONSTANT VARCHAR2(1) := arp_global.YES;
NO			CONSTANT VARCHAR2(1) := arp_global.NO;

DEP			CONSTANT VARCHAR2(10) := 'DEP';
GUAR			CONSTANT VARCHAR2(10) := 'GUAR';

FIFO			CONSTANT VARCHAR2(10) := 'FIFO';
LIFO			CONSTANT VARCHAR2(10) := 'LIFO';
PRORATE			CONSTANT VARCHAR2(10) := 'PRORATE';


--
-- User-defined exceptions
--


--
-- Translated error messages
--


-- This record holds general information used by autoaccounting and
-- credit memo module.  Passed as argument to most functions/procs.
--
system_info arp_trx_global.system_info_rec_type :=
	arp_trx_global.system_info;

--
-- This record holds profile information used by autoaccounting and
-- credit memo module.  Passed as argument to most functions/procs.
--
profile_info arp_trx_global.profile_rec_type :=
	arp_trx_global.profile_info;

/*
bug 4891386-4923502 Modified the datatype of every column having
Binary Integer to Number(15) for all record types  select_ips_rec_type,
select_ira_rec_type,select_ups_rec_type, select_iad_rec_type.
*/


TYPE select_ips_rec_type IS RECORD
(
  customer_trx_id 		NUMBER(15),
  trx_number			ra_customer_trx.trx_number%type,
  cust_trx_type_id		NUMBER(15),
  trx_type			ra_cust_trx_types.type%type,
  trx_date			DATE,
  gl_date			DATE,
  customer_id			NUMBER(15),
  site_use_id			NUMBER(15),
  reversed_cash_receipt_id	NUMBER(15),
  currency_code			ra_customer_trx.invoice_currency_code%type,
  precision			NUMBER,
  min_acc_unit			NUMBER,
  exchange_rate_type		ra_customer_trx.exchange_rate_type%type,
  exchange_rate			NUMBER,
  exchange_date			DATE,
  term_id			NUMBER(15),
  first_installment_code	ra_terms.first_installment_code%type,
  rec_acctd_amount		NUMBER,
  total_line_amount		NUMBER,
  total_tax_amount		NUMBER,
  total_freight_amount		NUMBER,
  total_charges_amount		NUMBER,
  term_sequence_num		NUMBER,
  percent			NUMBER,
  due_date			DATE
);


TYPE select_ira_rec_type IS RECORD
(
  customer_trx_id 		NUMBER(15),
  trx_number			ra_customer_trx.trx_number%type,
  cust_trx_type_id		NUMBER(15),
  post_to_gl_flag		ra_cust_trx_types.post_to_gl%type,
  credit_method		        ra_customer_trx.credit_method_for_installments%type,
  trx_date			DATE,
  gl_date			DATE,
  customer_id			NUMBER(15),
  site_use_id			NUMBER(15),
  currency_code			ra_customer_trx.invoice_currency_code%type,
  precision			NUMBER,
  min_acc_unit			NUMBER,
  exchange_rate_type		ra_customer_trx.exchange_rate_type%type,
  exchange_rate			NUMBER,
  exchange_date			DATE,
  rec_acctd_amount		NUMBER,
  total_cm_line_amount		NUMBER,
  total_cm_tax_amount		NUMBER,
  total_cm_freight_amount	NUMBER,
  total_cm_charges_amount	NUMBER,
  code_combination_id		NUMBER(15),
  gl_date_closed		DATE,
  actual_date_closed		DATE,
  inv_customer_trx_id 		NUMBER(15),
  inv_precision			NUMBER,
  inv_min_acc_unit		NUMBER,
  inv_exchange_rate		NUMBER,
  inv_payment_schedule_id 	NUMBER(15),
  inv_amount_due_remaining	NUMBER,
  inv_acctd_amt_due_rem		NUMBER,
  inv_line_remaining		NUMBER,
  inv_tax_remaining		NUMBER,
  inv_freight_remaining		NUMBER,
  inv_charges_remaining		NUMBER,
  inv_amount_credited		NUMBER
);

TYPE select_ups_rec_type IS RECORD
(
  set_of_books_id		NUMBER(15),
  customer_trx_id 		NUMBER(15),
  post_to_gl_flag		ra_cust_trx_types.post_to_gl%type,
  trx_date			DATE,
  gl_date			DATE,
  precision			NUMBER,
  min_acc_unit			NUMBER,
  adjusted_trx_id 	        NUMBER(15),
  subsequent_trx_id 		NUMBER(15),
  commitment_trx_id 		NUMBER(15),
  commitment_type		ra_cust_trx_types.type%type,
  ps_currency_code		ra_customer_trx.invoice_currency_code%type,
  ps_exchange_rate		NUMBER,
  ps_precision			NUMBER,
  ps_min_acc_unit	        NUMBER,
  code_combination_id		NUMBER(15),
  gl_date_closed		DATE,
  actual_date_closed		DATE,
  total_line_amount		NUMBER,
  payment_schedule_id 		NUMBER(15),
  amount_due_remaining		NUMBER,
  acctd_amt_due_rem		NUMBER,
  line_remaining		NUMBER,
  amount_adjusted		NUMBER,
  percent			NUMBER,
  allocate_tax_freight          ra_cust_trx_types_all.allocate_tax_freight%type,
  adjustment_type               ar_adjustments_all.type%type,
  tax_remaining                 NUMBER,
  freight_remaining             NUMBER,
  total_tax_amount              NUMBER,
  total_freight_amount          NUMBER
);


TYPE select_iad_rec_type IS RECORD
(
  set_of_books_id		NUMBER(15),
  customer_trx_id 		NUMBER(15),
  post_to_gl_flag		ra_cust_trx_types.post_to_gl%type,
  trx_date			DATE,
  gl_date			DATE,
  precision			NUMBER,
  min_acc_unit			NUMBER,
  adjusted_trx_id 		NUMBER(15),
  invoice_trx_id 		NUMBER(15),
  ps_currency_code		ra_customer_trx.invoice_currency_code%type,
  ps_exchange_rate		NUMBER,
  ps_precision			NUMBER,
  ps_min_acc_unit		NUMBER,
  commitment_code		NUMBER(15),
  code_combination_id		NUMBER(15),
  gl_date_closed		DATE,
  actual_date_closed		DATE,
  total_cm_line_amount		NUMBER,
  total_inv_adj_amount		NUMBER,
  total_inv_line_remaining	NUMBER,
  payment_schedule_id 		NUMBER(15),
  ps_amount_due_remaining	NUMBER,
  ps_acctd_amt_due_rem		NUMBER,
  ps_line_original		NUMBER,
  ps_line_remaining		NUMBER,
  ps_tax_original               NUMBER,
  ps_tax_remaining              NUMBER,
  ps_freight_original           NUMBER,
  ps_freight_remaining          NUMBER,
  ps_amount_adjusted		NUMBER,
  allocate_tax_freight          ra_cust_trx_types.allocate_tax_freight%type,
  adjustment_type               ar_adjustments.type%type,
  total_cm_tax_amount           NUMBER,
  total_cm_frt_amount           NUMBER,
--  total_inv_line_adj          NUMBER,
--  total_inv_tax_adj           NUMBER,
--  total_inv_frt_adj           NUMBER,
  inv_line_adj                  NUMBER,
  inv_tax_adj                   NUMBER,
  inv_frt_adj                   NUMBER
);


TYPE id_table_type IS
  TABLE OF BINARY_INTEGER
  INDEX BY BINARY_INTEGER;

TYPE number_table_type IS
  TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

TYPE date_table_type IS
  TABLE OF DATE
  INDEX BY BINARY_INTEGER;

id_t 			id_table_type;
null_id_t 		CONSTANT id_table_type := id_t;

number_t 		number_table_type;
null_number_t 		CONSTANT number_table_type := number_t;

date_t			date_table_type;
null_date_t 		CONSTANT date_table_type := date_t;

--
-- For the commitment balance package
--
g_oe_install_flag	VARCHAR2(240);
g_so_source_code	VARCHAR2(240);

------------------------------------------------------------------------
-- Private cursors
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Covers
------------------------------------------------------------------------
PROCEDURE debug( p_line IN VARCHAR2 ) IS
BEGIN
  IF PG_DEBUG IN ('Y','C')
  THEN
    arp_util.debug( p_line );
  END IF;
END;
--
PROCEDURE debug(
	p_str VARCHAR2,
	p_print_level BINARY_INTEGER ) IS
BEGIN
  IF PG_DEBUG IN ('Y', 'C')
  THEN
    arp_util.debug( p_str, p_print_level );
  END IF;
END;
--
PROCEDURE enable_debug IS
BEGIN
  arp_util.enable_debug;
END;
--
PROCEDURE enable_debug( buffer_size NUMBER ) IS
BEGIN
  arp_util.enable_debug( buffer_size );
END;
--
PROCEDURE disable_debug IS
BEGIN
  arp_util.disable_debug;
END;
--
PROCEDURE print_fcn_label( p_label VARCHAR2 ) IS
BEGIN
  IF PG_DEBUG IN ('Y','C')
  THEN
     arp_util.print_fcn_label( p_label );
  END IF;
END;
--
PROCEDURE print_fcn_label2( p_label VARCHAR2 ) IS
BEGIN
  IF PG_DEBUG IN ('Y', 'C')
  THEN
     arp_util.print_fcn_label2( p_label );
  END IF;
END;
--
PROCEDURE close_cursor( p_cursor_handle IN OUT NOCOPY INTEGER ) IS
BEGIN
    arp_util.close_cursor( p_cursor_handle );
END;


----------------------------------------------------------------------------
-- Functions and Procedures
----------------------------------------------------------------------------

PROCEDURE distribute_amount(
	p_count		IN NUMBER,
	p_currency_code	IN VARCHAR2,
	p_total		IN NUMBER,
	p_percent_t	IN number_table_type,
	p_amount_t	IN OUT NOCOPY number_table_type ) IS


    l_balance	NUMBER := p_total;
    l_amount	NUMBER;


BEGIN
    print_fcn_label2('arp_maintain_ps2.distribute_amount()+' );

    DEBUG( '    Total = ' || p_total, MSG_LEVEL_DEBUG);

    FOR i IN 0..p_count - 1 LOOP

        ------------------------------------------------------------------
	-- Check if last index position, if so, use remaining amount
        -- which includes rounding errors
        ------------------------------------------------------------------
	IF( i = p_count - 1 ) THEN

	    p_amount_t( i ) := l_balance;

	ELSE

	    l_amount := arp_util.CurrRound( p_total * p_percent_t( i ),
					    p_currency_code );
	    p_amount_t( i ) := l_amount;
	    l_balance := l_balance - l_amount;

	END IF;

        DEBUG('   Term: ' || i ||
              '  Percent = ' || p_percent_t(i) ||
              '  Amount = ' || p_amount_t(i),
                       MSG_LEVEL_DEBUG);

    END LOOP;


    print_fcn_label2('arp_maintain_ps2.distribute_amount()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.distribute_amount()',
	       MSG_LEVEL_BASIC );
        RAISE;
END distribute_amount;


------------------------------------------------------------------------

PROCEDURE compute_acctd_amount(
	p_count			IN NUMBER,
	p_functional_currency	IN VARCHAR2,
	p_exchange_rate		IN NUMBER,
	p_line_amount_t		IN number_table_type,
	p_tax_amount_t		IN number_table_type,
	p_freight_amount_t	IN number_table_type,
	p_charges_amount_t	IN number_table_type,
	p_acctd_amount_t	IN OUT NOCOPY number_table_type,
	p_acctd_total		IN NUMBER ) IS


    l_balance	NUMBER := p_acctd_total;
    l_amount	NUMBER;


BEGIN
    print_fcn_label2('arp_maintain_ps2.compute_acctd_amount()+' );


    FOR i IN 0..p_count - 1 LOOP

        ------------------------------------------------------------------
	-- Check if last index position, if so, use remaining amount
        -- which includes rounding errors
        ------------------------------------------------------------------
	IF( i = p_count - 1 ) THEN

	    p_acctd_amount_t( i ) := l_balance;

	ELSE

	    l_amount := arp_util.functional_amount(
				p_line_amount_t( i ) +
				  p_tax_amount_t( i ) +
				  p_freight_amount_t( i ) +
				  p_charges_amount_t( i ),
			        p_functional_currency, p_exchange_rate,
				null, null );

	    p_acctd_amount_t( i ) := l_amount;
	    l_balance := l_balance - l_amount;

	END IF;

    END LOOP;


    print_fcn_label2('arp_maintain_ps2.compute_acctd_amount()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.compute_acctd_amount()',
	       MSG_LEVEL_BASIC );
        RAISE;
END compute_acctd_amount;


----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  build_ips_sql
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--        system_info
--        profile_info
--
--      IN/OUT:
--        insert_ps_c
--        select_c
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE build_ips_sql(
	p_system_info 		IN arp_trx_global.system_info_rec_type,
        p_profile_info 		IN arp_trx_global.profile_rec_type,
        p_select_c 		IN OUT NOCOPY INTEGER,
        p_insert_ps_c 		IN OUT NOCOPY INTEGER ) IS

    l_insert_ps_sql	VARCHAR2(5000);
    l_select_sql	VARCHAR2(5000);


BEGIN

    print_fcn_label( 'arp_maintain_ps2.build_ips_sql()+' );

    ------------------------------------------------
    -- Select sql
    ------------------------------------------------
    l_select_sql :=
'SELECT
/* :user_id, */
ctl.customer_trx_id,
/* null, */
sum(decode(ctl.line_type, ''LINE'', ctl.extended_amount,
                        ''CB'', ctl.extended_amount, 0)),
sum(decode(ctl.line_type, ''TAX'', ctl.extended_amount, 0)),
sum(decode(ctl.line_type, ''FREIGHT'', ctl.extended_amount, 0)),
t.term_id,
tl.sequence_num,
/* Bug fix 5589303, If billing_date is not null, billing_date shall be used to calculate due date */
decode(ctt.type, ''CM'', ct.trx_date, nvl(tl.due_date,
    decode(tl.due_days,
           null,
           decode(least(to_number(substrb(nvl(ct.billing_date, ct.trx_date),1,2)),
                        nvl(t.due_cutoff_day,32)),
                  t.due_cutoff_day,
                  last_day(add_months(nvl(ct.billing_date, ct.trx_date),
                                      tl.due_months_forward)) +
                  least(tl.due_day_of_month,
                        to_number(substrb(last_day(add_months(
                               nvl(ct.billing_date, ct.trx_date),
                               tl.due_months_forward + 1)),1,2))),
                  last_day(add_months(nvl(ct.billing_date, ct.trx_date),
                                      (tl.due_months_forward - 1)))
                  + least(tl.due_day_of_month,
                          to_number(substrb(last_day(add_months(
                               nvl(ct.billing_date, ct.trx_date),
                               tl.due_months_forward)),1,2)))),
           nvl(ct.billing_date, ct.trx_date) + tl.due_days))),
ct.bill_to_customer_id,
ctt.type,
ct.bill_to_site_use_id,
ct.cust_trx_type_id,
ct.invoice_currency_code,
/* null, */
ct.exchange_rate_type,
ct.exchange_rate,
ct.exchange_date,
ct.trx_number,
ct.trx_date,
tl.relative_amount / t.base_amount,
c.precision,
/* 1, */
t.first_installment_code,
c.minimum_accountable_unit,
nvl(ctlgd.gl_date, ct.trx_date),
nvl(ctlgd.acctd_amount, 0),
/* null, */
/* :raagixlul, */
sum(decode(ctl.line_type, ''CHARGES'', ctl.extended_amount, 0)),
ct.reversed_cash_receipt_id 	/* Bug3328690 */
FROM
ra_terms t,
ra_terms_lines tl,
ra_cust_trx_types ctt,
ra_customer_trx ct,
ra_cust_trx_line_gl_dist ctlgd,
fnd_currencies c,
ra_customer_trx_lines ctl
WHERE  ct.customer_trx_id = :customer_trx_id
AND    ctl.customer_trx_id = ctlgd.customer_trx_id
AND    ctlgd.account_class = ''REC''
AND    ctlgd.latest_rec_flag = ''Y''
AND    ctl.customer_trx_id = ct.customer_trx_id
AND    ct.invoice_currency_code = c.currency_code
AND    ct.cust_trx_type_id = ctt.cust_trx_type_id
AND    ctt.accounting_affect_flag = ''Y''  /* Open Receivables = Y */
AND    ct.term_id = t.term_id(+)
AND    t.term_id = tl.term_id(+)
and    not (ctt.type = ''CM'' and ct.previous_customer_trx_id is not NULL)
GROUP BY
ctl.customer_trx_id,
t.term_id,
tl.relative_amount,
t.base_amount,
tl.sequence_num,
tl.due_date,
tl.due_days,
ct.trx_date,
t.due_cutoff_day,
tl.due_months_forward,
tl.due_day_of_month,
ct.bill_to_customer_id,
ctt.type,
ct.bill_to_site_use_id,
ct.cust_trx_type_id,
ct.invoice_currency_code,
ct.exchange_rate_type,
ct.exchange_rate,
ct.exchange_date,
ct.trx_number,
c.minimum_accountable_unit,
t.first_installment_code,
ctlgd.gl_date,
ctlgd.acctd_amount,
c.precision,
ct.reversed_cash_receipt_id,	/*Bug3328690 */
ct.billing_date
ORDER BY
ctl.customer_trx_id,
tl.sequence_num';

    debug('  select_sql = ' || CRLF ||
          l_select_sql || CRLF,
          MSG_LEVEL_DEBUG);
    debug('  len(select_sql) = '||
          to_char(length(l_select_sql)) || CRLF,
          MSG_LEVEL_DEBUG);


    ------------------------------------------------
    -- Insert sql
    ------------------------------------------------
    l_insert_ps_sql :=
'INSERT INTO AR_PAYMENT_SCHEDULES
(
created_by,
creation_date,
last_updated_by,
last_update_date,
last_update_login,
request_id,
program_application_id,
program_id,
program_update_date,
payment_schedule_id,
customer_trx_id,
amount_due_original,
amount_due_remaining,
acctd_amount_due_remaining,
amount_line_items_original,
amount_line_items_remaining,
tax_original,
tax_remaining,
freight_original,
freight_remaining,
receivables_charges_charged,
receivables_charges_remaining,
amount_credited,
amount_applied,
term_id,
terms_sequence_number,
due_date,
customer_id,
class,
customer_site_use_id,
cust_trx_type_id,
number_of_due_dates,
status,
invoice_currency_code,
actual_date_closed,
exchange_rate_type,
exchange_rate,
exchange_date,
trx_number,
trx_date,
gl_date_closed,
gl_date,
reversed_cash_receipt_id
,org_id
)
VALUES
(
:user_id,   	/* created_by */
sysdate,	/* creation_date */
:user_id,	/* last_updated_by */
sysdate,	/* last_update_date */
:login_id,	/* last_update_login */
:request_id,  		/* request_id */
decode(:application_id,
       -1, null, :application_id), 		/* program_application_id */
decode(:program_id, -1, null, :program_id), 		/* program_id */
sysdate,		/* program_update_date */
:payment_schedule_id,
:customer_trx_id,	/* customer_trx_id */
:line_amt + nvl(:tax_amt, 0) + nvl(:frt_amt, 0) +
    nvl(:charge_amt, 0),  /* ado */
:line_amt + nvl(:tax_amt, 0) + nvl(:frt_amt, 0) +
    nvl(:charge_amt, 0),  /* adr */
:acctd_adr,		/* acctd_amount_due_remaining */
:line_amt,	/* alio */
:line_amt,	/* alir */
nvl(:tax_amt, 0),	/* tax_original */
nvl(:tax_amt, 0),	/* tax_remaining */
nvl(:frt_amt, 0),	/* freight_original */
nvl(:frt_amt, 0),	/* freight_remaining */
nvl(:charge_amt, 0),	/* receivables_charges_charged */
nvl(:charge_amt, 0),	/* receivables_charges_remaining */
null,		/* amount_credited */
null,		/* amount_applied */
:term_id,		/* term_id */
nvl(:terms_sequence_number,1),	/* terms_sequence_number */
:due_date,
:customer_id,
:type,		/* class */
:site_use_id,	/* customer_site_use_id */
:cust_trx_type_id,	/* cust_trx_type_id */
:number_of_due_dates,	/* number_of_due_dates */
decode(:line_amt + nvl(:tax_amt, 0) + nvl(:frt_amt, 0)+ nvl(:charge_amt, 0),
       0, ''CL'', ''OP''),		/* status */
:currency_code,
       nvl(decode(:line_amt + nvl(:tax_amt,0) + nvl(:frt_amt,0)+
       nvl(:charge_amt,0),
           0, :trx_date, null), to_date(''12/31/4712'',''MM/DD/YYYY'')),/* bug#2678029 lgandhi actual_date_closed */
:exchange_rate_type,
:exchange_rate,
:exchange_date,
:trx_number,
:trx_date,
       nvl(decode(:line_amt + nvl(:tax_amt, 0) + nvl(:frt_amt, 0) +
		nvl(:charge_amt, 0),
              0, nvl(:gl_date, :trx_date), null),to_date(''12/31/4712'',''MM/DD/YYYY'')),		/* gl_date_closed */
nvl(:gl_date, :trx_date),
:reversed_cash_receipt_id
, :org_id--arp_standard.sysparm.org_id /* SSA changes anuj */
)' ;

    debug('  insert_ps_sql = ' || CRLF ||
          l_insert_ps_sql || CRLF,
          MSG_LEVEL_DEBUG);
    debug('  len(insert_ps_sql) = '||
          to_char(length(l_insert_ps_sql)) || CRLF,
          MSG_LEVEL_DEBUG);




    ------------------------------------------------
    -- Parse sql stmts
    ------------------------------------------------
    BEGIN
	debug( '  Parsing stmts', MSG_LEVEL_DEBUG );

        p_insert_ps_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_insert_ps_c, l_insert_ps_sql,
                        dbms_sql.v7 );

        p_select_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_select_c, l_select_sql,
                        dbms_sql.v7 );

    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error parsing stmts', MSG_LEVEL_BASIC );
          RAISE;
    END;

    print_fcn_label( 'arp_maintain_ps2.build_ips_sql()-' );


EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.build_ips_sql()',
	       MSG_LEVEL_BASIC );

        RAISE;
END build_ips_sql;


----------------------------------------------------------------------------
PROCEDURE define_ips_select_columns(
	p_select_c   IN INTEGER,
        p_select_rec IN select_ips_rec_type ) IS

BEGIN

    print_fcn_label2( 'arp_maintain_ps2.define_ips_select_columns()+' );

    dbms_sql.define_column( p_select_c, 1, p_select_rec.customer_trx_id );
    dbms_sql.define_column( p_select_c, 2, p_select_rec.total_line_amount );
    dbms_sql.define_column( p_select_c, 3, p_select_rec.total_tax_amount );
    dbms_sql.define_column( p_select_c, 4, p_select_rec.total_freight_amount );
    dbms_sql.define_column( p_select_c, 5, p_select_rec.term_id );
    dbms_sql.define_column( p_select_c, 6, p_select_rec.term_sequence_num );
    dbms_sql.define_column( p_select_c, 7, p_select_rec.due_date );
    dbms_sql.define_column( p_select_c, 8, p_select_rec.customer_id );
    dbms_sql.define_column( p_select_c, 9, p_select_rec.trx_type, 20 );
    dbms_sql.define_column( p_select_c, 10, p_select_rec.site_use_id );
    dbms_sql.define_column( p_select_c, 11, p_select_rec.cust_trx_type_id );
    dbms_sql.define_column( p_select_c, 12,
			    p_select_rec.currency_code, 15 );
    dbms_sql.define_column( p_select_c, 13,
                            p_select_rec.exchange_rate_type, 30 );
    dbms_sql.define_column( p_select_c, 14, p_select_rec.exchange_rate );
    dbms_sql.define_column( p_select_c, 15, p_select_rec.exchange_date );
    dbms_sql.define_column( p_select_c, 16, p_select_rec.trx_number, 20 );
    dbms_sql.define_column( p_select_c, 17, p_select_rec.trx_date );
    dbms_sql.define_column( p_select_c, 18, p_select_rec.percent );
    dbms_sql.define_column( p_select_c, 19, p_select_rec.precision );
    dbms_sql.define_column( p_select_c, 20,
			    p_select_rec.first_installment_code, 12 );
    dbms_sql.define_column( p_select_c, 21,
			    p_select_rec.min_acc_unit );
    dbms_sql.define_column( p_select_c, 22, p_select_rec.gl_date );

    dbms_sql.define_column( p_select_c, 23, p_select_rec.rec_acctd_amount );
    dbms_sql.define_column( p_select_c, 24,
			    p_select_rec.total_charges_amount );
    dbms_sql.define_column( p_select_c, 25,p_select_rec.reversed_cash_receipt_id); /*Bug3328690 */


    print_fcn_label2( 'arp_maintain_ps2.define_ips_select_columns()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_maintain_ps2.define_ips_select_columns()',
	      MSG_LEVEL_BASIC);
        RAISE;
END define_ips_select_columns;


----------------------------------------------------------------------------
PROCEDURE get_ips_column_values( p_select_c   IN INTEGER,
                             p_select_rec IN OUT NOCOPY select_ips_rec_type ) IS
/* Bug 460927 - Modified IN to IN OUT in the above line - Oracle 8 */
BEGIN
    print_fcn_label2( 'arp_maintain_ps2.get_ips_column_values()+' );

    dbms_sql.column_value( p_select_c, 1, p_select_rec.customer_trx_id );
    dbms_sql.column_value( p_select_c, 2, p_select_rec.total_line_amount );
    dbms_sql.column_value( p_select_c, 3, p_select_rec.total_tax_amount );
    dbms_sql.column_value( p_select_c, 4, p_select_rec.total_freight_amount );
    dbms_sql.column_value( p_select_c, 5, p_select_rec.term_id );
    dbms_sql.column_value( p_select_c, 6, p_select_rec.term_sequence_num );
    dbms_sql.column_value( p_select_c, 7, p_select_rec.due_date );
    dbms_sql.column_value( p_select_c, 8, p_select_rec.customer_id );
    dbms_sql.column_value( p_select_c, 9, p_select_rec.trx_type );
    dbms_sql.column_value( p_select_c, 10, p_select_rec.site_use_id );
    dbms_sql.column_value( p_select_c, 11, p_select_rec.cust_trx_type_id );
    dbms_sql.column_value( p_select_c, 12,
			    p_select_rec.currency_code );
    dbms_sql.column_value( p_select_c, 13,
                            p_select_rec.exchange_rate_type );
    dbms_sql.column_value( p_select_c, 14, p_select_rec.exchange_rate );
    dbms_sql.column_value( p_select_c, 15, p_select_rec.exchange_date );
    dbms_sql.column_value( p_select_c, 16, p_select_rec.trx_number );
    dbms_sql.column_value( p_select_c, 17, p_select_rec.trx_date );
    dbms_sql.column_value( p_select_c, 18, p_select_rec.percent );
    dbms_sql.column_value( p_select_c, 19, p_select_rec.precision );
    dbms_sql.column_value( p_select_c, 20,
			    p_select_rec.first_installment_code );
    dbms_sql.column_value( p_select_c, 21,
			    p_select_rec.min_acc_unit );
    dbms_sql.column_value( p_select_c, 22, p_select_rec.gl_date );

    dbms_sql.column_value( p_select_c, 23, p_select_rec.rec_acctd_amount );
    dbms_sql.column_value( p_select_c, 24, p_select_rec.total_charges_amount );
    dbms_sql.column_value( p_select_c, 25, p_select_rec.reversed_cash_receipt_id); /*Bug3328690 */

    print_fcn_label2( 'arp_maintain_ps2.get_ips_column_values()-' );
EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_maintain_ps2.get_ips_column_values()',
		MSG_LEVEL_BASIC);
        RAISE;
END get_ips_column_values;


----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  dump_ips_select_rec
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--        select_rec
--
--      IN/OUT:
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE dump_ips_select_rec( p_select_rec IN select_ips_rec_type ) IS
BEGIN

    print_fcn_label2( 'arp_maintain_ps2.dump_ips_select_rec()+' );

    debug( '  Dumping select record: ', MSG_LEVEL_DEBUG );
    debug( '  customer_trx_id='
           || p_select_rec.customer_trx_id, MSG_LEVEL_DEBUG );
    debug( '  trx_number='
           || p_select_rec.trx_number, MSG_LEVEL_DEBUG );
    debug( '  cust_trx_type_id='
           || p_select_rec.cust_trx_type_id, MSG_LEVEL_DEBUG );
    debug( '  trx_type='
           || p_select_rec.trx_type, MSG_LEVEL_DEBUG );
    debug( '  trx_date='
           || p_select_rec.trx_date, MSG_LEVEL_DEBUG );
    debug( '  gl_date='
           || p_select_rec.gl_date, MSG_LEVEL_DEBUG );
    debug( '  customer_id='
           || p_select_rec.customer_id, MSG_LEVEL_DEBUG );
    debug( '  site_use_id='
           || p_select_rec.site_use_id, MSG_LEVEL_DEBUG );
    debug( '  reversed_cash_receipt_id='
           || p_select_rec.reversed_cash_receipt_id, MSG_LEVEL_DEBUG );
    debug( '  currency_code='
           || p_select_rec.currency_code, MSG_LEVEL_DEBUG );
    debug( '  precision='
           || p_select_rec.precision, MSG_LEVEL_DEBUG );
    debug( '  min_acc_unit='
           || p_select_rec.min_acc_unit, MSG_LEVEL_DEBUG );
    debug( '  exchange_rate_type='
           || p_select_rec.exchange_rate_type, MSG_LEVEL_DEBUG );
    debug( '  exchange_rate='
           || p_select_rec.exchange_rate, MSG_LEVEL_DEBUG );
    debug( '  exchange_date='
           || p_select_rec.exchange_date, MSG_LEVEL_DEBUG );
    debug( '  term_id='
           || p_select_rec.term_id, MSG_LEVEL_DEBUG );
    debug( '  first_installment_code='
           || p_select_rec.first_installment_code, MSG_LEVEL_DEBUG );
    debug( '  rec_acctd_amount='
           || p_select_rec.rec_acctd_amount, MSG_LEVEL_DEBUG );
    debug( '  total_line_amount='
           || p_select_rec.total_line_amount, MSG_LEVEL_DEBUG );
    debug( '  total_tax_amount='
           || p_select_rec.total_tax_amount, MSG_LEVEL_DEBUG );
    debug( '  total_freight_amount='
           || p_select_rec.total_freight_amount, MSG_LEVEL_DEBUG );
    debug( '  total_charges_amount='
           || p_select_rec.total_charges_amount, MSG_LEVEL_DEBUG );
    debug( '  term_sequence_num='
           || p_select_rec.term_sequence_num, MSG_LEVEL_DEBUG );
    debug( '  percent='
           || p_select_rec.percent, MSG_LEVEL_DEBUG );
    debug( '  due_date='
           || p_select_rec.due_date, MSG_LEVEL_DEBUG );

    print_fcn_label2( 'arp_maintain_ps2.dump_ips_select_rec()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.dump_ips_select_rec()',
               MSG_LEVEL_BASIC );
        RAISE;
END dump_ips_select_rec;


------------------------------------------------------------------------

PROCEDURE process_ips_data(
	p_system_info		IN arp_trx_global.system_info_rec_type,
	p_profile_info 		IN arp_trx_global.profile_rec_type,
        p_insert_ps_c		IN INTEGER,
	p_select_rec		IN select_ips_rec_type,
	p_number_of_due_dates	IN NUMBER,
	p_percent_t		IN number_table_type,
	p_terms_sequence_num_t	IN number_table_type,
	p_due_date_t		IN date_table_type,
	p_line_amount_t		IN OUT NOCOPY number_table_type,
	p_tax_amount_t		IN OUT NOCOPY number_table_type,
	p_freight_amount_t	IN OUT NOCOPY number_table_type,
	p_charges_amount_t	IN OUT NOCOPY number_table_type,
	p_acctd_amt_due_rem_t	IN OUT NOCOPY number_table_type ) IS

    l_ignore 		INTEGER;

    l_ps_id            ar_payment_schedules.payment_schedule_id%type;
    /* BR Sped Project */
    l_jgzz_product_code VARCHAR2(100);
    lcursor  NUMBER;
    lignore  NUMBER;
    sqlstmt  VARCHAR2(254);
    l_return_value_jl NUMBER;
    /* BR Sped Project */
BEGIN
    print_fcn_label2('arp_maintain_ps2.process_ips_data()+' );


    --------------------------------------------------------------------
    -- Distribute line amount
    --------------------------------------------------------------------
    distribute_amount(
		p_number_of_due_dates,
		p_select_rec.currency_code,
		p_select_rec.total_line_amount,
		p_percent_t,
		p_line_amount_t );

    --------------------------------------------------------------------
    -- Distribute charges amount
    --------------------------------------------------------------------
    distribute_amount(
		p_number_of_due_dates,
		p_select_rec.currency_code,
		p_select_rec.total_charges_amount,
		p_percent_t,
		p_charges_amount_t );


    --------------------------------------------------------------------
    -- Distribute tax and freight amount
    --------------------------------------------------------------------
    IF( p_select_rec.first_installment_code = 'INCLUDE' ) THEN

        --------------------------------------------------------------------
        -- Put tax in 1st installment
        --------------------------------------------------------------------
        p_tax_amount_t( 0 ) := p_select_rec.total_tax_amount;

	FOR i IN 1..p_number_of_due_dates - 1 LOOP
	    p_tax_amount_t( i ) := 0;
	END LOOP;

        --------------------------------------------------------------------
        -- Put freight in 1st installment
        --------------------------------------------------------------------
        p_freight_amount_t( 0 ) := p_select_rec.total_freight_amount;

	FOR i IN 1..p_number_of_due_dates - 1 LOOP
	    p_freight_amount_t( i ) := 0;
	END LOOP;


    ELSE

        --------------------------------------------------------------------
        -- Distribute tax amount
        --------------------------------------------------------------------
	distribute_amount(
		p_number_of_due_dates,
		p_select_rec.currency_code,
		p_select_rec.total_tax_amount,
		p_percent_t,
		p_tax_amount_t );

        --------------------------------------------------------------------
        -- Distribute freight amount
        --------------------------------------------------------------------
        distribute_amount(
		p_number_of_due_dates,
		p_select_rec.currency_code,
		p_select_rec.total_freight_amount,
		p_percent_t,
		p_freight_amount_t );
    END IF;

    --------------------------------------------------------------------
    -- Calculate accounted amount due_remaining
    --------------------------------------------------------------------
    compute_acctd_amount(
	p_number_of_due_dates,
	p_system_info.base_currency,
	p_select_rec.exchange_rate,
	p_line_amount_t,
	p_tax_amount_t,
	p_freight_amount_t,
	p_charges_amount_t,
	p_acctd_amt_due_rem_t,
	p_select_rec.rec_acctd_amount );



    -------------------------------------------------------------
    -- Insert into ar_payment_schedules
    -------------------------------------------------------------

    FOR i IN 0..p_number_of_due_dates - 1 LOOP

        -------------------------------------------------------------
        -- Bind vars
        -------------------------------------------------------------
        BEGIN
	    debug( '  Binding insert_ps_c', MSG_LEVEL_DEBUG );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'user_id',
                                    p_profile_info.user_id );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'login_id',
                                    p_profile_info.conc_login_id );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'request_id',
                                    p_profile_info.request_id );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'application_id',
                                    p_profile_info.application_id );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'program_id',
                                    p_profile_info.conc_program_id );

            /* retrieve the next payment schedule id.  Added for
               MRC trigger replacement */

            SELECT ar_payment_schedules_s.nextval
              INTO l_ps_id
             FROM dual;

            dbms_sql.bind_variable( p_insert_ps_c,
                                    'payment_schedule_id',
                                    l_ps_id );


            dbms_sql.bind_variable( p_insert_ps_c,
		                    'customer_trx_id',
                                    p_select_rec.customer_trx_id );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'line_amt',
                                    p_line_amount_t(i) );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'tax_amt',
                                    p_tax_amount_t(i) );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'frt_amt',
                                    p_freight_amount_t(i) );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'charge_amt',
                                    p_charges_amount_t(i) );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'acctd_adr',
                                    p_acctd_amt_due_rem_t(i) );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'terms_sequence_number',
                                    p_terms_sequence_num_t(i) );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'due_date',
                                    p_due_date_t(i) );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'term_id',
                                    p_select_rec.term_id );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'customer_id',
                                    p_select_rec.customer_id );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'type',
                                    p_select_rec.trx_type );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'site_use_id',
                                    p_select_rec.site_use_id );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'cust_trx_type_id',
                                    p_select_rec.cust_trx_type_id );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'currency_code',
                                    p_select_rec.currency_code );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'trx_date',
                                    p_select_rec.trx_date );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'gl_date',
                                    p_select_rec.gl_date );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'trx_number',
                                    p_select_rec.trx_number );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'exchange_rate_type',
                                    p_select_rec.exchange_rate_type );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'exchange_rate',
                                    p_select_rec.exchange_rate );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'exchange_date',
                                    p_select_rec.exchange_date );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'number_of_due_dates',
                                    p_number_of_due_dates );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'reversed_cash_receipt_id',
                                    p_select_rec.reversed_cash_receipt_id );

--anuj
            dbms_sql.bind_variable( p_insert_ps_c,
		                            'org_id',
                                    arp_standard.sysparm.org_id /* SSA changes anuj */ );

        EXCEPTION
          WHEN OTHERS THEN
            debug( 'EXCEPTION: Error in binding rule_insert_dist_c',
                   MSG_LEVEL_BASIC );
            RAISE;
        END;

        -------------------------------------------------------------
        -- Execute
        -------------------------------------------------------------
        BEGIN
	    debug( '  Inserting payment schedules', MSG_LEVEL_DEBUG );
            l_ignore := dbms_sql.execute( p_insert_ps_c );
            debug( to_char(l_ignore) || ' row(s) inserted',
		           MSG_LEVEL_DEBUG );

	    /* Call JL for locking the invoice for approval if JL is installed.
	    l_jgzz_product_code := sys_context('JG','JGZZ_PRODUCT_CODE');*/
	    l_jgzz_product_code := AR_GDF_VALIDATION.is_jg_installed;

            IF (l_jgzz_product_code IS NOT NULL) AND (l_ignore > 0) THEN
            /* JL_BR_SPED_PKG package is installed, so OK to call the package. */
            BEGIN
                         JL_BR_SPED_PKG.SET_TRX_LOCK_STATUS(p_select_rec.customer_trx_id);
	    EXCEPTION
                WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
			arp_standard.debug('LOCK_INVOICE_FROM_WORKBENCH: Exception calling BEGIN JL_BR_SPED_PKG.LOCK_INVOICE_FROM_WORKBENCH.');
			arp_standard.debug('LOCK_INVOICE_FROM_WORKBENCH: ' || SQLERRM);
                END IF;
	    END;
            END IF;

           /*-------------------------------------------+
            | Call central MRC library for insertion    |
            | into MRC tables                           |
            +-------------------------------------------*/

           ar_mrc_engine.maintain_mrc_data(
                      p_event_mode       => 'INSERT',
                      p_table_name       => 'AR_PAYMENT_SCHEDULES',
                      p_mode             => 'SINGLE',
                      p_key_value        => l_ps_id);

        EXCEPTION
          WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing insert ps stmt',
                   MSG_LEVEL_BASIC );
            RAISE;
        END;

    END LOOP;


    print_fcn_label2('arp_maintain_ps2.process_ips_data()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.process_ips_data()',
	       MSG_LEVEL_BASIC );
        RAISE;
END process_ips_data;


----------------------------------------------------------------------------
PROCEDURE insert_inv_ps_private(
	p_system_info		IN arp_trx_global.system_info_rec_type,
	p_profile_info 		IN arp_trx_global.profile_rec_type,
	p_customer_trx_id 		IN BINARY_INTEGER,
	p_reversed_cash_receipt_id	IN BINARY_INTEGER ) IS

    l_ignore 			INTEGER;
    l_old_trx_id		BINARY_INTEGER;
    l_customer_trx_id		BINARY_INTEGER;

    l_terms_sequence_num_t 	number_table_type;
    l_percent_t 		number_table_type;
    l_line_amount_t 		number_table_type;
    l_tax_amount_t 		number_table_type;
    l_freight_amount_t 		number_table_type;
    l_charges_amount_t 		number_table_type;
    l_acctd_amt_due_rem_t	number_table_type;

    l_due_date_t		date_table_type;
    l_table_index		BINARY_INTEGER := 0;

    l_select_rec		select_ips_rec_type;



    PROCEDURE load_tables( p_select_rec IN select_ips_rec_type ) IS

    BEGIN
        print_fcn_label2('arp_maintain_ps2.load_tables()+' );

        l_terms_sequence_num_t( l_table_index ) :=
				p_select_rec.term_sequence_num;
        l_percent_t( l_table_index ) := p_select_rec.percent;
        l_due_date_t( l_table_index ) := p_select_rec.due_date;
        l_table_index := l_table_index + 1;

        print_fcn_label2('arp_maintain_ps2.load_tables()-' );

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: arp_maintain_ps2.load_tables()',
	           MSG_LEVEL_BASIC );
            RAISE;
    END load_tables;


    PROCEDURE clear_tables IS

    BEGIN
        print_fcn_label2('arp_maintain_ps2.clear_tables()+' );


        l_line_amount_t := null_number_t;
        l_tax_amount_t := null_number_t;
        l_freight_amount_t := null_number_t;
        l_charges_amount_t := null_number_t;
        l_acctd_amt_due_rem_t := null_number_t;
        l_terms_sequence_num_t := null_number_t;
        l_percent_t := null_number_t;

        l_due_date_t := null_date_t;

        l_table_index := 0;

        print_fcn_label2('arp_maintain_ps2.clear_tables()-' );

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: arp_maintain_ps2.clear_tables()',
	           MSG_LEVEL_BASIC );
            RAISE;
    END clear_tables;

BEGIN

    print_fcn_label( 'arp_maintain_ps2.insert_inv_ps_private()+' );

    --
    clear_tables;
    --
    IF( NOT( dbms_sql.is_open( ips_select_c ) AND
	     dbms_sql.is_open( ips_insert_ps_c ) )) THEN

        build_ips_sql( system_info,
		       profile_info,
		       ips_select_c,
		       ips_insert_ps_c );
    END IF;

    --
    define_ips_select_columns( ips_select_c, l_select_rec );

    ---------------------------------------------------------------
    -- Bind variables
    ---------------------------------------------------------------
    dbms_sql.bind_variable( ips_select_c,
			    'customer_trx_id',
			    p_customer_trx_id );

    ---------------------------------------------------------------
    -- Execute sql
    ---------------------------------------------------------------
    debug( '  Executing select sql', MSG_LEVEL_DEBUG );

    BEGIN
        l_ignore := dbms_sql.execute( ips_select_c );

    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error executing select sql',
		 MSG_LEVEL_BASIC );
          RAISE;
    END;


    ---------------------------------------------------------------
    -- Fetch rows
    ---------------------------------------------------------------
    BEGIN
        LOOP

            IF dbms_sql.fetch_rows( ips_select_c ) > 0  THEN

	        debug('  Fetched a row', MSG_LEVEL_DEBUG );

                -----------------------------------------------
                -- Load row into record
                -----------------------------------------------
		dbms_sql.column_value( ips_select_c, 1, l_customer_trx_id );

		IF( l_old_trx_id IS NULL OR
		    l_customer_trx_id <> l_old_trx_id ) THEN

		    IF( l_old_trx_id IS NOT NULL ) THEN

			process_ips_data(
				system_info,
				profile_info,
				ips_insert_ps_c,
				l_select_rec,
				l_table_index,
				l_percent_t,
				l_terms_sequence_num_t,
				l_due_date_t,
				l_line_amount_t,
				l_tax_amount_t,
				l_freight_amount_t,
				l_charges_amount_t,
				l_acctd_amt_due_rem_t );
		    END IF;

		    l_old_trx_id := l_customer_trx_id;

		    clear_tables;


		END IF;

		get_ips_column_values( ips_select_c, l_select_rec );

		/* Bug3328690 Check included for reversed_cash_receipt_id.
		If it is created for the first time then p_reversed_cash_receipt_id
		will not be null.During Completion of DM reversal p_reversed_cash_receipt
		will be null */

		IF p_reversed_cash_receipt_id is NOT NULL THEN
		   l_select_rec.reversed_cash_receipt_id :=
					p_reversed_cash_receipt_id;
		END IF;

		dump_ips_select_rec( l_select_rec );

		load_tables( l_select_rec );
		-- >> dump tables

            ELSE
		process_ips_data(
				system_info,
				profile_info,
				ips_insert_ps_c,
				l_select_rec,
				l_table_index,
				l_percent_t,
				l_terms_sequence_num_t,
				l_due_date_t,
				l_line_amount_t,
				l_tax_amount_t,
				l_freight_amount_t,
				l_charges_amount_t,
				l_acctd_amt_due_rem_t );
                EXIT;
            END IF;


        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error fetching select cursor',
                   MSG_LEVEL_BASIC );
            RAISE;

    END;

    print_fcn_label( 'arp_maintain_ps2.insert_inv_ps_private()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.insert_inv_ps_private()',
	       MSG_LEVEL_BASIC );
        RAISE;

END insert_inv_ps_private;


----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  build_ira_sql
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--        system_info
--        profile_info
--
--      IN/OUT:
--        select_c
--        insert_ps_c
--	  insert_ra_c
--	  update_ps_c
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE build_ira_sql(
	p_system_info 		IN arp_trx_global.system_info_rec_type,
        p_profile_info 		IN arp_trx_global.profile_rec_type,
        p_select_c 		IN OUT NOCOPY INTEGER,
	p_insert_ps_c 		IN OUT NOCOPY INTEGER,
	p_insert_ra_c 		IN OUT NOCOPY INTEGER,
        p_update_ps_c 		IN OUT NOCOPY INTEGER ) IS

    l_insert_ps_sql	VARCHAR2(3000);
    l_insert_ra_sql	VARCHAR2(3000);
    l_update_ps_sql	VARCHAR2(2000);
    l_select_sql	VARCHAR2(6000);


BEGIN

    print_fcn_label( 'arp_maintain_ps2.build_ira_sql()+' );

    ------------------------------------------------
    -- Select sql
    ------------------------------------------------
    l_select_sql :=
'SELECT
/* null, */
nvl(ct.trx_date, sysdate),
ct.bill_to_customer_id,
ct.cust_trx_type_id,
ctl.customer_trx_id,
ct.invoice_currency_code,
sum(decode(ctl.line_type,
           ''LINE'', ctl.extended_amount, 0)) /
    (count(distinct nvl(ra.receivable_application_id, -9.9)) *
     count(distinct nvl(adj.adjustment_id, -9.9))),
sum(decode(ctl.line_type, ''FREIGHT'', ctl.extended_amount, 0)) /
    (count(distinct nvl(ra.receivable_application_id, -9.9)) *
     count(distinct nvl(adj.adjustment_id, -9.9))),
sum(decode(ctl.line_type, ''TAX'', ctl.extended_amount, 0)) /
    (count(distinct nvl(ra.receivable_application_id, -9.9)) *
     count(distinct nvl(adj.adjustment_id, -9.9))),
/* null, */
ct.exchange_rate_type,
ct.exchange_rate,
ct.exchange_date,
ct.trx_number,
nvl(ctlgd.gl_date, ct.trx_date),
ctlgd_inv.code_combination_id,
ps.customer_trx_id,
ps.payment_schedule_id,
greatest(nvl(max(decode(ra.confirmed_flag,
				''Y'', ra.gl_date,
                                null, decode(ra.receivable_application_id,
					     null, nvl(ctlgd.gl_date,
					                ct.trx_date),
                                             ra.gl_date),
				nvl(ctlgd.gl_date, ct.trx_date))),
		     nvl(ctlgd.gl_date, ct.trx_date)),
                 nvl(max(decode(adj.status,
				''A'',adj.gl_date,
				nvl(ctlgd.gl_date,ct.trx_date))),
		     nvl(ctlgd.gl_date,ct.trx_date)),
                 nvl(ctlgd.gl_date, ct.trx_date)),
greatest(nvl(max(decode(ra.confirmed_flag,
                                ''Y'', ra.apply_date,
                                null, decode(ra.receivable_application_id,
                                             null, ct.trx_date,
                                             ra.apply_date),
				ct.trx_date)),
		     ct.trx_date),
                 nvl(max(decode(adj.status,
				''A'',adj.apply_date,
				ct.trx_date)),
		     ct.trx_date),
                 ct.trx_date),
c.precision,
nvl(ps.amount_line_items_remaining,0),
nvl(ps.freight_remaining,0),
nvl(ps.tax_remaining,0),
ct.bill_to_site_use_id,
/* 0, */
/* 0, */
/* 0, */
c.minimum_accountable_unit,
ctt.post_to_gl,
/* nvl(ctlgd.gl_date,ct.trx_date), */
ct.credit_method_for_installments,
nvl(ps.amount_credited,0),
ps.amount_due_remaining,
ps.acctd_amount_due_remaining,
/* null, */
/* null, */
c_inv.precision,
c_inv.minimum_accountable_unit,
ct_inv.exchange_rate,
ctlgd.acctd_amount,
/* null, */
/* null, */
/* null, */
/* null, */
sum(decode(ctl.line_type, ''CHARGES'', ctl.extended_amount, 0)) /
    (count(distinct nvl(ra.receivable_application_id, -9.9)) *
     count(distinct nvl(adj.adjustment_id, -9.9))),
/* null, */
nvl(ps.receivables_charges_remaining,0)
/* , 0 */
FROM
ar_receivable_applications ra,
ar_payment_schedules ps,
ar_adjustments adj,
ra_cust_trx_types ctt,
ra_cust_trx_line_gl_dist ctlgd,
ra_customer_trx ct,
fnd_currencies c,
fnd_currencies c_inv,
ra_customer_trx ct_inv,
ra_cust_trx_line_gl_dist ctlgd_inv,
ra_customer_trx_lines ctl
WHERE ct.customer_trx_id = :customer_trx_id
and   ctl.customer_trx_id = ct.customer_trx_id
AND    ct.cust_trx_type_id = ctt.cust_trx_type_id
AND    ctt.type = ''CM''
AND    ctt.accounting_affect_flag = ''Y''
AND    ctl.previous_customer_trx_id = ps.customer_trx_id
AND    ps.customer_trx_id = ra.applied_customer_trx_id (+)
AND    ps.customer_trx_id = adj.customer_trx_id (+)
AND    c.currency_code = ct.invoice_currency_code
AND    ct.customer_trx_id = ctlgd.customer_trx_id
AND    ctlgd.account_class = ''REC''
AND    ctlgd.latest_rec_flag = ''Y''
AND    ps.customer_trx_id = ct_inv.customer_trx_id
AND    ct_inv.customer_trx_id = ctlgd_inv.customer_trx_id
AND    ctlgd_inv.account_class = ''REC''
AND    ctlgd_inv.latest_rec_flag= ''Y''
AND    ct_inv.invoice_currency_code = c_inv.currency_code
GROUP BY
ctl.customer_trx_id,
ct.trx_date,
ct.bill_to_customer_id,
ct.cust_trx_type_id,
ct.invoice_currency_code,
ct.exchange_rate_type,
ct.exchange_rate,
ct.exchange_date,
ct.trx_number,
nvl(ctlgd.gl_date, ct.trx_date),
ctlgd_inv.code_combination_id,
ps.customer_trx_id,
ps.payment_schedule_id,
ps.freight_remaining,
ps.tax_remaining,
ps.amount_line_items_remaining,
ps.gl_date,
ra.applied_customer_trx_id,
adj.customer_trx_id,
ct.bill_to_site_use_id,
c.precision,
c.minimum_accountable_unit,
ctlgd.gl_date,
ct.trx_date,
ct.credit_method_for_installments,
ctt.post_to_gl,
ps.amount_credited,
c_inv.precision,
c_inv.minimum_accountable_unit,
ct_inv.exchange_rate,
ctlgd.acctd_amount,
ps.terms_sequence_number,
ps.amount_due_remaining,
ps.receivables_charges_remaining,
ps.acctd_amount_due_remaining
ORDER BY
ps.customer_trx_id asc,
ctl.customer_trx_id asc,
ps.terms_sequence_number';


    debug('  select_sql = ' || CRLF ||
          l_select_sql || CRLF,
          MSG_LEVEL_DEBUG);
    debug('  len(select_sql) = '||
          to_char(length(l_select_sql)) || CRLF,
          MSG_LEVEL_DEBUG);


    ------------------------------------------------
    -- Insert ps sql
    ------------------------------------------------
    l_insert_ps_sql :=
'INSERT INTO AR_PAYMENT_SCHEDULES
(
created_by,
creation_date,
last_updated_by,
last_update_date,
last_update_login,
request_id,
program_application_id,
program_id,
program_update_date,
payment_schedule_id,
customer_trx_id,
amount_due_original,
amount_due_remaining,
acctd_amount_due_remaining,
amount_line_items_original,
amount_line_items_remaining,
tax_original,
tax_remaining,
freight_original,
freight_remaining,
receivables_charges_charged,
receivables_charges_remaining,
amount_credited,
amount_applied,
term_id,
terms_sequence_number,
due_date,
customer_id,
class,
customer_site_use_id,
cust_trx_type_id,
number_of_due_dates,
status,
invoice_currency_code,
actual_date_closed,
exchange_rate_type,
exchange_rate,
exchange_date,
trx_number,
trx_date,
gl_date_closed,
gl_date
,org_id
)
VALUES
(
:user_id,		/* created_by */
sysdate,		/* creation_date */
:user_id,		/* last_updated_by */
sysdate,		/* last_update_date */
:login_id,		/* last_update_login */
:request_id,
decode(:application_id,
       -1, null, :application_id), 		/* program_application_id */
decode(:program_id, -1, null, :program_id),	/* program_id */
sysdate,				/* program_update_date */
:payment_schedule_id,		/* payment_schedule_id */
:customer_trx_id,
:amount_due_original,
0,				/* amount_due_remaining */
0,				/* acctd_amount_due_remaining */
:amount_line_items_original,
0,				/* amount_line_items_remaining */
:tax_original,
0,				/* tax_remaining */
:freight_original,
0,				/* freight_remaining */
:receivables_charges_charged,
0,				/* receivables_charges_remaining */
0,				/* amount_credited */
:amount_applied,
null,				/* term_id */
1,				/* terms_sequence_number */
:trx_date,
:customer_id,
''CM'',				/* class */
:site_use_id,
:cust_trx_type_id,
1,				/* number_of_due_dates */
''CL'',				/* status */
:currency_code,
nvl(:trx_date, to_date(''12/31/4712'',''MM/DD/YYYY'')),
:exchange_rate_type,
:exchange_rate,
:exchange_date,
:trx_number,
:trx_date,
nvl(:gl_date, to_date(''12/31/4712'',''MM/DD/YYYY'')),			/* gl_date_closed */
:gl_date
,:org_id --arp_standard.sysparm.org_id /* SSA changes anuj */
)' ;

    debug('  insert_ps_sql = ' || CRLF ||
          l_insert_ps_sql || CRLF,
          MSG_LEVEL_DEBUG);
    debug('  len(insert_ps_sql) = '||
          to_char(length(l_insert_ps_sql)) || CRLF,
          MSG_LEVEL_DEBUG);


    ------------------------------------------------
    -- Insert ra sql
    ------------------------------------------------
    l_insert_ra_sql :=
'INSERT INTO AR_RECEIVABLE_APPLICATIONS
(
created_by,
creation_date,
last_updated_by,
last_update_date,
request_id,
program_application_id,
program_id,
program_update_date,
last_update_login,
receivable_application_id,
customer_trx_id,
payment_schedule_id,
gl_date,
code_combination_id,
set_of_books_id,
display,
application_type,
apply_date,
applied_customer_trx_id,
applied_payment_schedule_id,
status,
amount_applied,
acctd_amount_applied_from,
acctd_amount_applied_to,
line_applied,
tax_applied,
freight_applied,
receivables_charges_applied,
application_rule,
postable,
posting_control_id,
cash_receipt_history_id,
ussgl_transaction_code
,org_id
)
SELECT
:user_id,		/* created_by */
sysdate,		/* creation_date */
:user_id,		/* last_updated_by */
sysdate,		/* last_update_date */
:request_id,
:application_id,
:program_id,
sysdate,		/* program_update_date */
:login_id,		/* last_update_login */
:receivable_application_id,
:customer_trx_id,
ps.payment_schedule_id,
:gl_date,
:code_combination_id,
:set_of_books_id,
''Y'',			/* display */
''CM'',			/* application_type */
:trx_date,
:applied_customer_trx_id,
:applied_payment_schedule_id,
''APP'',			/* status */
-:amount_applied,
-:acctd_amount_applied_from,
-:acctd_amount_applied_to,
-:line_applied,
-:tax_applied,
-:freight_applied,
-:receivables_charges_applied,
67,			/* application_rule */
:post_to_gl_flag,
-3,			/* posting_control_id */
null,			/* cash_receipt_history_id */
:ussgl_transaction_code /*Transaction code*/
,ps.org_id /* SSA changes anuj */
FROM AR_PAYMENT_SCHEDULES ps
/*  assumes only one ps line exists for CM */
WHERE :customer_trx_id = ps.customer_trx_id';

    debug('  insert_ra_sql = ' || CRLF ||
          l_insert_ra_sql || CRLF,
          MSG_LEVEL_DEBUG);
    debug('  len(insert_ra_sql) = '||
          to_char(length(l_insert_ra_sql)) || CRLF,
          MSG_LEVEL_DEBUG);


    ------------------------------------------------
   -- Update ps sql
    ------------------------------------------------
-- Modified the update statement to incorporate the hard-coded date if the transaction is open - For Bug:5491085
    l_update_ps_sql :=
'UPDATE AR_PAYMENT_SCHEDULES
SET
last_update_date = sysdate,
last_updated_by = :user_id,
last_update_login = :login_id,
status = decode(:amount_due_remaining, 0, ''CL'', ''OP''),
gl_date_closed = decode(:amount_due_remaining, 0, :gl_date_closed,TO_DATE(''31-12-4712'',''DD-MM-YYYY'')),
actual_date_closed =
	decode(:amount_due_remaining, 0, :actual_date_closed,TO_DATE(''31-12-4712'',''DD-MM-YYYY'')),
amount_due_remaining = :amount_due_remaining,
acctd_amount_due_remaining = :acctd_amount_due_remaining,
amount_line_items_remaining = :amount_line_items_remaining,
freight_remaining = :freight_remaining,
tax_remaining = :tax_remaining,
receivables_charges_remaining = :receivables_charges_remaining,
amount_credited = :amount_credited
WHERE payment_schedule_id = :applied_payment_schedule_id';

    debug('  update_ps_sql = ' || CRLF ||
          l_update_ps_sql || CRLF,
          MSG_LEVEL_DEBUG);
    debug('  len(update_ps_sql) = '||
          to_char(length(l_update_ps_sql)) || CRLF,
          MSG_LEVEL_DEBUG);




    ------------------------------------------------
    -- Parse sql stmts
    ------------------------------------------------
    BEGIN
	debug( '  Parsing stmts', MSG_LEVEL_DEBUG );

	debug( '  Parsing insert_ps_c', MSG_LEVEL_DEBUG );
        p_insert_ps_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_insert_ps_c, l_insert_ps_sql,
                        dbms_sql.v7 );

	debug( '  Parsing insert_ra_c', MSG_LEVEL_DEBUG );
        p_insert_ra_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_insert_ra_c, l_insert_ra_sql,
                        dbms_sql.v7 );

	debug( '  Parsing update_ps_c', MSG_LEVEL_DEBUG );
        p_update_ps_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_update_ps_c, l_update_ps_sql,
                        dbms_sql.v7 );

	debug( '  Parsing select_c', MSG_LEVEL_DEBUG );
        p_select_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_select_c, l_select_sql,
                        dbms_sql.v7 );

    EXCEPTION
      WHEN OTHERS THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug(SQLERRM);
          END IF;
          debug( 'EXCEPTION: Error parsing stmts', MSG_LEVEL_BASIC );
          RAISE;
    END;

    print_fcn_label( 'arp_maintain_ps2.build_ira_sql()-' );


EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.build_ira_sql()',
	       MSG_LEVEL_BASIC );

        RAISE;
END build_ira_sql;


----------------------------------------------------------------------------
PROCEDURE define_ira_select_columns(
	p_select_c   IN INTEGER,
        p_select_rec IN select_ira_rec_type ) IS

BEGIN

    print_fcn_label2( 'arp_maintain_ps2.define_ira_select_columns()+' );

    dbms_sql.define_column( p_select_c, 1, p_select_rec.trx_date );
    dbms_sql.define_column( p_select_c, 2, p_select_rec.customer_id );
    dbms_sql.define_column( p_select_c, 3, p_select_rec.cust_trx_type_id );
    dbms_sql.define_column( p_select_c, 4, p_select_rec.customer_trx_id );
    dbms_sql.define_column( p_select_c, 5, p_select_rec.currency_code, 15 );
    dbms_sql.define_column( p_select_c, 6, p_select_rec.total_cm_line_amount );
    dbms_sql.define_column( p_select_c, 7,
				p_select_rec.total_cm_freight_amount );
    dbms_sql.define_column( p_select_c, 8, p_select_rec.total_cm_tax_amount );
    dbms_sql.define_column( p_select_c, 9,
                            p_select_rec.exchange_rate_type, 30 );
    dbms_sql.define_column( p_select_c, 10, p_select_rec.exchange_rate );
    dbms_sql.define_column( p_select_c, 11, p_select_rec.exchange_date );
    dbms_sql.define_column( p_select_c, 12, p_select_rec.trx_number, 20 );
    dbms_sql.define_column( p_select_c, 13, p_select_rec.gl_date );
    dbms_sql.define_column( p_select_c, 14, p_select_rec.code_combination_id );
    dbms_sql.define_column( p_select_c, 15, p_select_rec.inv_customer_trx_id );
    dbms_sql.define_column( p_select_c, 16,
				p_select_rec.inv_payment_schedule_id );
    dbms_sql.define_column( p_select_c, 17, p_select_rec.gl_date_closed );
    dbms_sql.define_column( p_select_c, 18, p_select_rec.actual_date_closed );
    dbms_sql.define_column( p_select_c, 19, p_select_rec.precision );
    dbms_sql.define_column( p_select_c, 20, p_select_rec.inv_line_remaining );
    dbms_sql.define_column( p_select_c, 21,
				p_select_rec.inv_freight_remaining );
    dbms_sql.define_column( p_select_c, 22, p_select_rec.inv_tax_remaining );
    dbms_sql.define_column( p_select_c, 23, p_select_rec.site_use_id );
    dbms_sql.define_column( p_select_c, 24,
			    p_select_rec.min_acc_unit );
    dbms_sql.define_column( p_select_c, 25,
			    p_select_rec.post_to_gl_flag, 1 );
    dbms_sql.define_column( p_select_c, 26,
			    p_select_rec.credit_method, 30 );
    dbms_sql.define_column( p_select_c, 27,
			    p_select_rec.inv_amount_credited );
    dbms_sql.define_column( p_select_c, 28,
			    p_select_rec.inv_amount_due_remaining );
    dbms_sql.define_column( p_select_c, 29,
			    p_select_rec.inv_acctd_amt_due_rem );
    dbms_sql.define_column( p_select_c, 30, p_select_rec.inv_precision );
    dbms_sql.define_column( p_select_c, 31,
				p_select_rec.inv_min_acc_unit );
    dbms_sql.define_column( p_select_c, 32, p_select_rec.inv_exchange_rate );
    dbms_sql.define_column( p_select_c, 33, p_select_rec.rec_acctd_amount );
    dbms_sql.define_column( p_select_c, 34,
				p_select_rec.total_cm_charges_amount );
    dbms_sql.define_column( p_select_c, 35,
				p_select_rec.inv_charges_remaining );


    print_fcn_label2( 'arp_maintain_ps2.define_ira_select_columns()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_maintain_ps2.define_ira_select_columns()',
	      MSG_LEVEL_BASIC);
        RAISE;
END define_ira_select_columns;


----------------------------------------------------------------------------
PROCEDURE get_ira_column_values( p_select_c   IN INTEGER,
                             p_select_rec IN OUT NOCOPY select_ira_rec_type ) IS
/* Bug 460927 - Modified IN to IN OUT oin the above line - oracle 8 */
BEGIN
    print_fcn_label2( 'arp_maintain_ps2.get_ira_column_values()+' );

    dbms_sql.column_value( p_select_c, 1, p_select_rec.trx_date );
    dbms_sql.column_value( p_select_c, 2, p_select_rec.customer_id );
    dbms_sql.column_value( p_select_c, 3, p_select_rec.cust_trx_type_id );
    dbms_sql.column_value( p_select_c, 4, p_select_rec.customer_trx_id );
    dbms_sql.column_value( p_select_c, 5, p_select_rec.currency_code );
    dbms_sql.column_value( p_select_c, 6, p_select_rec.total_cm_line_amount );
    dbms_sql.column_value( p_select_c, 7,
				p_select_rec.total_cm_freight_amount );
    dbms_sql.column_value( p_select_c, 8, p_select_rec.total_cm_tax_amount );
    dbms_sql.column_value( p_select_c, 9,
                            p_select_rec.exchange_rate_type );
    dbms_sql.column_value( p_select_c, 10, p_select_rec.exchange_rate );
    dbms_sql.column_value( p_select_c, 11, p_select_rec.exchange_date );
    dbms_sql.column_value( p_select_c, 12, p_select_rec.trx_number );
    dbms_sql.column_value( p_select_c, 13, p_select_rec.gl_date );
    dbms_sql.column_value( p_select_c, 14, p_select_rec.code_combination_id );
    dbms_sql.column_value( p_select_c, 15, p_select_rec.inv_customer_trx_id );
    dbms_sql.column_value( p_select_c, 16,
				p_select_rec.inv_payment_schedule_id );
    dbms_sql.column_value( p_select_c, 17, p_select_rec.gl_date_closed );
    dbms_sql.column_value( p_select_c, 18, p_select_rec.actual_date_closed );
    dbms_sql.column_value( p_select_c, 19, p_select_rec.precision );
    dbms_sql.column_value( p_select_c, 20, p_select_rec.inv_line_remaining );
    dbms_sql.column_value( p_select_c, 21,
				p_select_rec.inv_freight_remaining );
    dbms_sql.column_value( p_select_c, 22, p_select_rec.inv_tax_remaining );
    dbms_sql.column_value( p_select_c, 23, p_select_rec.site_use_id );
    dbms_sql.column_value( p_select_c, 24,
			    p_select_rec.min_acc_unit );
    dbms_sql.column_value( p_select_c, 25,
			    p_select_rec.post_to_gl_flag );
    dbms_sql.column_value( p_select_c, 26,
			    p_select_rec.credit_method );
    dbms_sql.column_value( p_select_c, 27,
			    p_select_rec.inv_amount_credited );
    dbms_sql.column_value( p_select_c, 28,
			    p_select_rec.inv_amount_due_remaining );
    dbms_sql.column_value( p_select_c, 29,
			    p_select_rec.inv_acctd_amt_due_rem );
    dbms_sql.column_value( p_select_c, 30, p_select_rec.inv_precision );
    dbms_sql.column_value( p_select_c, 31,
				p_select_rec.inv_min_acc_unit );
    dbms_sql.column_value( p_select_c, 32, p_select_rec.inv_exchange_rate );
    dbms_sql.column_value( p_select_c, 33, p_select_rec.rec_acctd_amount );
    dbms_sql.column_value( p_select_c, 34,
				p_select_rec.total_cm_charges_amount );
    dbms_sql.column_value( p_select_c, 35,
				p_select_rec.inv_charges_remaining );


    print_fcn_label2( 'arp_maintain_ps2.get_ira_column_values()-' );
EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_maintain_ps2.get_ira_column_values()',
		MSG_LEVEL_BASIC);
        RAISE;
END get_ira_column_values;


----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  dump_ira_select_rec
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--        select_rec
--
--      IN/OUT:
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE dump_ira_select_rec( p_select_rec IN select_ira_rec_type ) IS
BEGIN

    print_fcn_label2( 'arp_maintain_ps2.dump_ira_select_rec()+' );

    debug( '  Dumping select record: ', MSG_LEVEL_DEBUG );
    debug( '  customer_trx_id='
           || p_select_rec.customer_trx_id, MSG_LEVEL_DEBUG );
    debug( '  trx_number='
           || p_select_rec.trx_number, MSG_LEVEL_DEBUG );
    debug( '  cust_trx_type_id='
           || p_select_rec.cust_trx_type_id, MSG_LEVEL_DEBUG );
    debug( '  post_to_gl_flag='
           || p_select_rec.post_to_gl_flag, MSG_LEVEL_DEBUG );
    debug( '  credit_method='
           || p_select_rec.credit_method, MSG_LEVEL_DEBUG );
    debug( '  trx_date='
           || p_select_rec.trx_date, MSG_LEVEL_DEBUG );
    debug( '  gl_date='
           || p_select_rec.gl_date, MSG_LEVEL_DEBUG );
    debug( '  customer_id='
           || p_select_rec.customer_id, MSG_LEVEL_DEBUG );
    debug( '  site_use_id='
           || p_select_rec.site_use_id, MSG_LEVEL_DEBUG );
    debug( '  currency_code='
           || p_select_rec.currency_code, MSG_LEVEL_DEBUG );
    debug( '  precision='
           || p_select_rec.precision, MSG_LEVEL_DEBUG );
    debug( '  min_acc_unit='
           || p_select_rec.min_acc_unit, MSG_LEVEL_DEBUG );
    debug( '  exchange_rate_type='
           || p_select_rec.exchange_rate_type, MSG_LEVEL_DEBUG );
    debug( '  exchange_rate='
           || p_select_rec.exchange_rate, MSG_LEVEL_DEBUG );
    debug( '  exchange_date='
           || p_select_rec.exchange_date, MSG_LEVEL_DEBUG );
    debug( '  rec_acctd_amount='
           || p_select_rec.rec_acctd_amount, MSG_LEVEL_DEBUG );
    debug( '  total_cm_line_amount='
           || p_select_rec.total_cm_line_amount, MSG_LEVEL_DEBUG );
    debug( '  total_cm_tax_amount='
           || p_select_rec.total_cm_tax_amount, MSG_LEVEL_DEBUG );
    debug( '  total_cm_freight_amount='
           || p_select_rec.total_cm_freight_amount, MSG_LEVEL_DEBUG );
    debug( '  total_cm_charges_amount='
           || p_select_rec.total_cm_charges_amount, MSG_LEVEL_DEBUG );
    debug( '  code_combination_id='
           || p_select_rec.code_combination_id, MSG_LEVEL_DEBUG );
    debug( '  gl_date_closed='
           || p_select_rec.gl_date_closed, MSG_LEVEL_DEBUG );
    debug( '  actual_date_closed='
           || p_select_rec.actual_date_closed, MSG_LEVEL_DEBUG );
    debug( '  inv_customer_trx_id='
           || p_select_rec.inv_customer_trx_id, MSG_LEVEL_DEBUG );
    debug( '  inv_precision='
           || p_select_rec.inv_precision, MSG_LEVEL_DEBUG );
    debug( '  inv_min_acc_unit='
           || p_select_rec.inv_min_acc_unit, MSG_LEVEL_DEBUG );
    debug( '  inv_exchange_rate='
           || p_select_rec.inv_exchange_rate, MSG_LEVEL_DEBUG );
    debug( '  inv_payment_schedule_id='
           || p_select_rec.inv_payment_schedule_id, MSG_LEVEL_DEBUG );
    debug( '  inv_amount_due_remaining='
           || p_select_rec.inv_amount_due_remaining, MSG_LEVEL_DEBUG );
    debug( '  inv_acctd_amt_due_rem='
           || p_select_rec.inv_acctd_amt_due_rem, MSG_LEVEL_DEBUG );
    debug( '  inv_line_remaining='
           || p_select_rec.inv_line_remaining, MSG_LEVEL_DEBUG );
    debug( '  inv_tax_remaining='
           || p_select_rec.inv_tax_remaining, MSG_LEVEL_DEBUG );
    debug( '  inv_freight_remaining='
           || p_select_rec.inv_freight_remaining, MSG_LEVEL_DEBUG );
    debug( '  inv_charges_remaining='
           || p_select_rec.inv_charges_remaining, MSG_LEVEL_DEBUG );
    debug( '  inv_amount_credited='
           || p_select_rec.inv_amount_credited, MSG_LEVEL_DEBUG );

    print_fcn_label2( 'arp_maintain_ps2.dump_ira_select_rec()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.dump_ira_select_rec()',
               MSG_LEVEL_BASIC );
        RAISE;
END dump_ira_select_rec;


------------------------------------------------------------------------

PROCEDURE distribute_fifo_lifo(
	p_direction		IN NUMBER,	-- 1 for FIFO, -1 for LIFO
	p_start_index		IN NUMBER,
	p_end_index		IN NUMBER,
        p_cm_amount		IN NUMBER,
	p_inv_rem_t		IN OUT NOCOPY number_table_type,
	p_cm_applied_amt_t  	IN OUT NOCOPY number_table_type ) IS


    l_cm_rem		NUMBER;
    l_cm_rem_sign	NUMBER;
    l_inv_rem		NUMBER;
    l_inv_rem_sign	NUMBER;
    l_sum		NUMBER;

    l_index		NUMBER;
    l_high_index	NUMBER;

BEGIN
    print_fcn_label2('arp_maintain_ps2.distribute_fifo_lifo()+' );

    debug( '  p_direction='||p_direction, MSG_LEVEL_DEBUG );
    debug( '  p_start_index='||p_start_index, MSG_LEVEL_DEBUG );
    debug( '  p_end_index='||p_end_index, MSG_LEVEL_DEBUG );
    debug( '  p_cm_amount='||p_cm_amount, MSG_LEVEL_DEBUG );

    l_cm_rem := p_cm_amount;

    l_index := p_start_index;


    WHILE( TRUE ) LOOP
	debug( '  l_index='||l_index, MSG_LEVEL_DEBUG );
	debug( '  l_cm_rem='||l_cm_rem, MSG_LEVEL_DEBUG );

        -------------------------------------------------------------------
	-- Get cm sign
        -------------------------------------------------------------------
        l_cm_rem_sign := SIGN( l_cm_rem );

        -------------------------------------------------------------------
        -- Get inv rem for current line
        -------------------------------------------------------------------
        l_inv_rem := p_inv_rem_t( l_index );
        l_inv_rem_sign := SIGN( l_inv_rem );

        IF( l_cm_rem_sign = 0 OR
	    l_cm_rem_sign = l_inv_rem_sign ) THEN

            ---------------------------------------------------------------
	    -- CM amount is zero or line overapplication
	    -- do not apply
            ---------------------------------------------------------------
	    p_cm_applied_amt_t( l_index ) := 0;

	ELSE

	    l_sum := l_inv_rem + l_cm_rem;

            IF( SIGN(l_sum) = SIGN(l_inv_rem) ) THEN

                -----------------------------------------------------------
		-- Full application, no more cm remaining
                -----------------------------------------------------------
		p_inv_rem_t( l_index ) := l_sum;
		p_cm_applied_amt_t( l_index ) := l_cm_rem;
		l_cm_rem := 0;

	    ELSE
                -----------------------------------------------------------
		-- Partial application
                -----------------------------------------------------------
		p_inv_rem_t( l_index ) := 0;
		p_cm_applied_amt_t( l_index ) := - l_inv_rem;
		l_cm_rem := l_sum;
	    END IF;

	END IF;

	IF( l_index = p_end_index ) THEN

            -----------------------------------------------------------
	    -- Done
            -----------------------------------------------------------
	    EXIT;
	END IF;

        l_index := l_index + p_direction;

    END LOOP;

    -------------------------------------------------------------------
    -- Put any excess CM amount into the LAST array position
    -- (numerically highest index value)
    -------------------------------------------------------------------
    IF( l_cm_rem <> 0 ) THEN

	IF( p_direction = 1 ) THEN
            -----------------------------------------------------------
	    -- FIFO
            -----------------------------------------------------------
	    l_high_index := p_end_index;
	ELSE
            -----------------------------------------------------------
	    -- LIFO
            -----------------------------------------------------------
	    l_high_index := p_start_index;
	END IF;

        p_inv_rem_t( l_high_index ) :=
			p_inv_rem_t( l_high_index ) + l_cm_rem;

	p_cm_applied_amt_t( l_high_index ) :=
			p_cm_applied_amt_t( l_high_index ) + l_cm_rem;

    END IF;


    print_fcn_label2('arp_maintain_ps2.distribute_fifo_lifo()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.distribute_fifo_lifo()',
	       MSG_LEVEL_BASIC );
        RAISE;

END distribute_fifo_lifo;

------------------------------------------------------------------------

PROCEDURE distribute_prorate(
	p_select_rec		IN select_ira_rec_type,
	p_count			IN NUMBER,
	p_cm_amount		IN NUMBER,
	p_inv_rem_t		IN OUT NOCOPY number_table_type,
	p_cm_applied_amt_t  	IN OUT NOCOPY number_table_type ) IS

    l_cm_amount_sign	NUMBER;
    l_inv_rem_sum	NUMBER;
    l_sum		NUMBER;

    l_apply_amount	NUMBER;
    l_excess_amount	NUMBER;

    l_percent_t	number_table_type;


    -----------------------------------------------------------------------
    FUNCTION get_sum(
			p_amount_t number_table_type,
			p_cm_sign NUMBER )
        RETURN NUMBER IS

        l_total	NUMBER := 0;

    BEGIN

        FOR i IN 0..p_count - 1 LOOP

            IF( sign( p_amount_t( i ) ) <> p_cm_sign ) THEN
		l_total := l_total + p_amount_t( i );
	    END IF;

	END LOOP;

	RETURN l_total;

    END get_sum;

    -----------------------------------------------------------------------
    PROCEDURE compute_percents(
		p_cm_amt_sign	IN NUMBER,
		p_amt_rem_sum	IN NUMBER,
		p_amt_rem_t	IN number_table_type,
		p_percent_t	IN OUT NOCOPY number_table_type ) IS

	l_amt_rem	NUMBER;
	l_amt_rem_sign	NUMBER;

    BEGIN

        FOR i in 0..p_count - 1 LOOP

	    l_amt_rem := p_amt_rem_t( i );
            l_amt_rem_sign := SIGN( l_amt_rem );

	    IF( l_amt_rem_sign = p_cm_amt_sign OR
		p_cm_amt_sign = 0 ) THEN

		p_percent_t( i ) := 0;

	    ELSE
                IF (p_amt_rem_sum = 0) THEN
		    p_percent_t( i ) := l_amt_rem;
                ELSE
		    p_percent_t( i ) := l_amt_rem / p_amt_rem_sum;
                END IF;
	    END IF;

	END LOOP;

    END compute_percents;
    -----------------------------------------------------------------------

BEGIN
    print_fcn_label2('arp_maintain_ps2.distribute_prorate()+' );


    debug( '  p_cm_amount='||p_cm_amount, MSG_LEVEL_DEBUG );

    l_cm_amount_sign := SIGN( p_cm_amount );

    l_inv_rem_sum := get_sum( p_inv_rem_t, l_cm_amount_sign );

    compute_percents(
		l_cm_amount_sign,
		l_inv_rem_sum,
		p_inv_rem_t,
		l_percent_t );



    ---------------------------------------------------------------
    -- Get balance after cm application
    ---------------------------------------------------------------
    l_sum := l_inv_rem_sum + p_cm_amount;

    IF( SIGN( l_sum ) = SIGN( l_inv_rem_sum ) ) THEN

        ---------------------------------------------------------------
	-- Full application,  use entire cm amount
        ---------------------------------------------------------------
	l_apply_amount := p_cm_amount;
	l_excess_amount := 0;

    ELSE

        ---------------------------------------------------------------
	-- Partial application
        ---------------------------------------------------------------
	l_apply_amount := -l_inv_rem_sum;
	l_excess_amount := l_sum;

    END IF;

    distribute_amount(
		p_count,
		p_select_rec.currency_code,
		l_apply_amount,
		l_percent_t,
		p_cm_applied_amt_t );

    -------------------------------------------------------------------
    -- Apply excess to last row
    -------------------------------------------------------------------
    IF( l_excess_amount <> 0 ) THEN

	p_cm_applied_amt_t( p_count - 1 ) :=
		p_cm_applied_amt_t( p_count - 1 ) + l_excess_amount;

    END IF;

    --
    -- Update invoice remaining amounts
    --
    FOR i IN 0..p_count - 1 LOOP
	p_inv_rem_t( i ) := p_inv_rem_t( i ) + p_cm_applied_amt_t( i );
    END LOOP;


    print_fcn_label2('arp_maintain_ps2.distribute_prorate()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.distribute_prorate()',
	       MSG_LEVEL_BASIC );
        RAISE;

END distribute_prorate;

------------------------------------------------------------------------

PROCEDURE process_ira_data(
	p_system_info		IN arp_trx_global.system_info_rec_type,
	p_profile_info 		IN arp_trx_global.profile_rec_type,
        p_insert_ps_c			IN INTEGER,
        p_insert_ra_c			IN INTEGER,
        p_update_ps_c			IN INTEGER,
	p_select_rec			IN select_ira_rec_type,
        p_number_records		IN NUMBER,
        p_inv_ps_id_t			IN id_table_type,
        p_inv_amount_due_rem_t 		IN OUT NOCOPY number_table_type,
        p_inv_acctd_amt_due_rem_t	IN OUT NOCOPY number_table_type,
        p_inv_line_rem_t 		IN OUT NOCOPY number_table_type,
        p_inv_tax_rem_t 		IN OUT NOCOPY number_table_type,
        p_inv_freight_rem_t 		IN OUT NOCOPY number_table_type,
        p_inv_charges_rem_t 		IN OUT NOCOPY number_table_type,
        p_inv_amount_credited_t 	IN OUT NOCOPY number_table_type,
        p_line_applied_t 		IN OUT NOCOPY number_table_type,
        p_tax_applied_t 		IN OUT NOCOPY number_table_type,
        p_freight_applied_t 		IN OUT NOCOPY number_table_type,
        p_charges_applied_t 		IN OUT NOCOPY number_table_type,
        p_acctd_amt_applied_from_t	IN OUT NOCOPY number_table_type,
        p_acctd_amt_applied_to_t	IN OUT NOCOPY number_table_type ) IS

     CURSOR get_appl_info (p_rec_app_id NUMBER) IS
            SELECT payment_schedule_id,
                   applied_payment_schedule_id
            from   ar_receivable_applications
            where receivable_application_id = p_rec_app_id;

    l_receivable_application_id ar_receivable_applications.receivable_application_id%TYPE;

    l_ignore 			INTEGER;

    l_direction			NUMBER;	-- 1 for FIFO, -1 for LIFO
    l_start_index		NUMBER;
    l_end_index			NUMBER;

    l_amount_applied		NUMBER;
    l_new_inv_adr		NUMBER;
    l_new_inv_acctd_adr		NUMBER;
    l_new_acctd_amt_applied_to	NUMBER;

    l_ae_doc_rec                ae_doc_rec_type;
    l_ps_class                  ar_payment_schedules.class%type;
    l_ps_is                     ar_payment_schedules.payment_schedule_id%type;
    l_ps_id            ar_payment_schedules.payment_schedule_id%type;

    l_ussgl_transaction_code ar_receivable_applications.ussgl_transaction_code%type;

BEGIN
    print_fcn_label2('arp_maintain_ps2.process_ira_data()+' );

    debug( '  checking credit method', MSG_LEVEL_DEBUG );

    IF( p_select_rec.credit_method in (FIFO, LIFO) ) THEN

	IF( p_select_rec.credit_method = FIFO ) THEN
	    debug( '  FIFO processing', MSG_LEVEL_DEBUG );
	    l_start_index := 0;
	    l_end_index := p_number_records - 1;
	    l_direction := 1;
	ELSE
	    debug( '  LIFO processing', MSG_LEVEL_DEBUG );
	    l_start_index := p_number_records - 1;
	    l_end_index := 0;
	    l_direction := -1;
	END IF;

        --------------------------------------------------------------------
	-- Distribute line amount
        --------------------------------------------------------------------
	distribute_fifo_lifo(
		l_direction,
		l_start_index,
		l_end_index,
		p_select_rec.total_cm_line_amount,
		p_inv_line_rem_t,
		p_line_applied_t );

        --------------------------------------------------------------------
	-- Distribute tax amount
        --------------------------------------------------------------------
	distribute_fifo_lifo(
		l_direction,
		l_start_index,
		l_end_index,
		p_select_rec.total_cm_tax_amount,
		p_inv_tax_rem_t,
		p_tax_applied_t );

        --------------------------------------------------------------------
	-- Distribute freight amount
        --------------------------------------------------------------------
	distribute_fifo_lifo(
		l_direction,
		l_start_index,
		l_end_index,
		p_select_rec.total_cm_freight_amount,
		p_inv_freight_rem_t,
		p_freight_applied_t );

        --------------------------------------------------------------------
	-- Distribute charges amount
        --------------------------------------------------------------------
	distribute_fifo_lifo(
		l_direction,
		l_start_index,
		l_end_index,
		p_select_rec.total_cm_charges_amount,
		p_inv_charges_rem_t,
		p_charges_applied_t );


    ELSE	-- PRORATE processing

	debug( '  PRORATE processing', MSG_LEVEL_DEBUG );

        --------------------------------------------------------------------
	-- Distribute line amount
        --------------------------------------------------------------------
	distribute_prorate(
		p_select_rec,
		p_number_records,
		p_select_rec.total_cm_line_amount,
		p_inv_line_rem_t,
		p_line_applied_t );

        --------------------------------------------------------------------
	-- Distribute tax amount
        --------------------------------------------------------------------
	distribute_prorate(
		p_select_rec,
		p_number_records,
		p_select_rec.total_cm_tax_amount,
		p_inv_tax_rem_t,
		p_tax_applied_t );

        --------------------------------------------------------------------
	-- Distribute freight amount
        --------------------------------------------------------------------
	distribute_prorate(
		p_select_rec,
		p_number_records,
		p_select_rec.total_cm_freight_amount,
		p_inv_freight_rem_t,
		p_freight_applied_t );

        --------------------------------------------------------------------
	-- Distribute charges amount
        --------------------------------------------------------------------
	distribute_prorate(
		p_select_rec,
		p_number_records,
		p_select_rec.total_cm_charges_amount,
		p_inv_charges_rem_t,
		p_charges_applied_t );


    END IF;

    debug( '  updating amount tables', MSG_LEVEL_DEBUG );

    --------------------------------------------------------------------
    -- Update various amounts in tables
    --------------------------------------------------------------------
    FOR i IN 0..p_number_records - 1 LOOP

	l_amount_applied := p_line_applied_t( i ) +
				p_tax_applied_t( i ) +
				p_freight_applied_t( i ) +
				p_charges_applied_t( i );

        --------------------------------------------------------------------
	-- Update amount_credited
        --------------------------------------------------------------------
        p_inv_amount_credited_t( i ) :=
		p_inv_amount_credited_t( i ) + l_amount_applied ;


        --------------------------------------------------------------------
    	-- Compute new acctd_adr (aracc)
        --------------------------------------------------------------------
	arp_util.calc_acctd_amount(
		p_system_info.base_currency,
		NULL,			-- precision
		NULL,			-- mau
		p_select_rec.inv_exchange_rate,
		'+',			-- type
		p_inv_amount_due_rem_t( i ),	-- master_from
		p_inv_acctd_amt_due_rem_t( i ),	-- acctd_master_from
		l_amount_applied,	-- detail
		l_new_inv_adr,		-- master_to
		l_new_inv_acctd_adr,	-- acctd_master_to
		l_new_acctd_amt_applied_to	-- acctd_detail
	);

        --------------------------------------------------------------------
	-- Update amounts
        --------------------------------------------------------------------
	p_inv_amount_due_rem_t( i ) := l_new_inv_adr;
	p_inv_acctd_amt_due_rem_t( i ) := l_new_inv_acctd_adr;
	p_acctd_amt_applied_to_t( i ) := l_new_acctd_amt_applied_to;

    END LOOP;

    --------------------------------------------------------------------
    -- Calculate acctd_amt_applied_from
    --------------------------------------------------------------------
    compute_acctd_amount(
		p_number_records,
		p_system_info.base_currency,
		p_select_rec.exchange_rate,
		p_line_applied_t,
		p_tax_applied_t,
		p_freight_applied_t,
		p_charges_applied_t,
		p_acctd_amt_applied_from_t,
		p_select_rec.rec_acctd_amount );



    -------------------------------------------------------------
    -- Insert into ar_payment_schedules
    -------------------------------------------------------------

        -------------------------------------------------------------
        -- Bind vars
        -------------------------------------------------------------
        BEGIN
	    debug( '  Binding insert_ps_c', MSG_LEVEL_DEBUG );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'user_id',
                                    p_profile_info.user_id );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'login_id',
                                    p_profile_info.conc_login_id );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'request_id',
                                    p_profile_info.request_id );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'application_id',
                                    p_profile_info.application_id );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'program_id',
                                    p_profile_info.conc_program_id );

            /* added for mrc trigger elimination */
            SELECT ar_payment_schedules_s.nextval
              INTO l_ps_id
             FROM dual;

            dbms_sql.bind_variable( p_insert_ps_c,
                                    'payment_schedule_id',
                                    l_ps_id );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'customer_trx_id',
                                    p_select_rec.customer_trx_id );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'amount_due_original',
                                    p_select_rec.total_cm_line_amount +
                                    p_select_rec.total_cm_tax_amount +
                                    p_select_rec.total_cm_freight_amount +
                                    p_select_rec.total_cm_charges_amount );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'amount_line_items_original',
                                    p_select_rec.total_cm_line_amount );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'tax_original',
                                    p_select_rec.total_cm_tax_amount );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'freight_original',
                                    p_select_rec.total_cm_freight_amount );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'receivables_charges_charged',
                                    p_select_rec.total_cm_charges_amount );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'amount_applied',
                                    p_select_rec.total_cm_line_amount +
                                    p_select_rec.total_cm_tax_amount +
                                    p_select_rec.total_cm_freight_amount +
                                    p_select_rec.total_cm_charges_amount );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'trx_date',
                                    p_select_rec.trx_date );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'customer_id',
                                    p_select_rec.customer_id );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'site_use_id',
                                    p_select_rec.site_use_id );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'cust_trx_type_id',
                                    p_select_rec.cust_trx_type_id );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'currency_code',
                                    p_select_rec.currency_code );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'exchange_rate_type',
                                    p_select_rec.exchange_rate_type );


            dbms_sql.bind_variable( p_insert_ps_c,
		                    'exchange_rate',
                                    p_select_rec.exchange_rate );


            dbms_sql.bind_variable( p_insert_ps_c,
		                    'exchange_date',
                                    p_select_rec.exchange_date );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'gl_date',
                                    p_select_rec.gl_date );

            dbms_sql.bind_variable( p_insert_ps_c,
		                    'trx_number',
                                    p_select_rec.trx_number );
--begin anuj
            dbms_sql.bind_variable( p_insert_ps_c,
		                           'org_id',
                                    arp_standard.sysparm.org_id /* SSA changes anuj */
 );
--end anuj


        EXCEPTION
          WHEN OTHERS THEN
            debug( 'EXCEPTION: Error in binding insert_ps',
                   MSG_LEVEL_BASIC );
            RAISE;
        END;

        -------------------------------------------------------------
        -- Execute
        -------------------------------------------------------------
        BEGIN
	    debug( '  Inserting CM payment schedules', MSG_LEVEL_DEBUG );
            l_ignore := dbms_sql.execute( p_insert_ps_c );
            debug( to_char(l_ignore) || ' row(s) inserted',
		           MSG_LEVEL_DEBUG );

           /*-------------------------------------------+
            | Call central MRC library for insertion    |
            | into MRC tables                           |
            +-------------------------------------------*/

           ar_mrc_engine.maintain_mrc_data(
                      p_event_mode       => 'INSERT',
                      p_table_name       => 'AR_PAYMENT_SCHEDULES',
                      p_mode             => 'SINGLE',
                      p_key_value        => l_ps_id);

        EXCEPTION
          WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing insert ps stmt',
                   MSG_LEVEL_BASIC );
            RAISE;
        END;
    -------------------------------------------------------------
    -- Insert into ar_receivable_applications
    -------------------------------------------------------------

    FOR i IN 0..p_number_records - 1 LOOP

        -------------------------------------------------------------
        -- Bind vars
        -------------------------------------------------------------
        BEGIN
	    debug( '  Binding insert_ra_c', MSG_LEVEL_DEBUG );

/*Bug :2246098-Used a bind var for insert*/

	select  ct.default_ussgl_transaction_code into l_ussgl_transaction_code
	from ra_customer_trx ct
	WHERE ct.customer_trx_id=p_select_rec.customer_trx_id;

            dbms_sql.bind_variable( p_insert_ra_c,
		                    'user_id',
                                    p_profile_info.user_id );

            dbms_sql.bind_variable( p_insert_ra_c,
		                    'login_id',
                                    p_profile_info.conc_login_id );

            dbms_sql.bind_variable( p_insert_ra_c,
		                    'request_id',
                                    p_profile_info.request_id );

            dbms_sql.bind_variable( p_insert_ra_c,
		                    'application_id',
                                    p_profile_info.application_id );

            dbms_sql.bind_variable( p_insert_ra_c,
		                    'program_id',
                                    p_profile_info.conc_program_id );


            dbms_sql.bind_variable( p_insert_ra_c,
		                    'customer_trx_id',
                                    p_select_rec.customer_trx_id );

            dbms_sql.bind_variable( p_insert_ra_c,
		                    'gl_date',
                                    p_select_rec.gl_date );

            dbms_sql.bind_variable( p_insert_ra_c,
		                    'code_combination_id',
                                    p_select_rec.code_combination_id );

            dbms_sql.bind_variable(
			p_insert_ra_c,
			'set_of_books_id',
                	arp_standard.sysparm.set_of_books_id );

            dbms_sql.bind_variable( p_insert_ra_c,
		                    'trx_date',
                                    p_select_rec.trx_date );

            dbms_sql.bind_variable( p_insert_ra_c,
		                    'applied_customer_trx_id',
                                    p_select_rec.inv_customer_trx_id );


            dbms_sql.bind_variable( p_insert_ra_c,
		                    'applied_payment_schedule_id',
                                    p_inv_ps_id_t( i ) );

            dbms_sql.bind_variable( p_insert_ra_c,
		                    'amount_applied',
                                    p_line_applied_t( i ) +
                                    p_tax_applied_t( i ) +
                                    p_freight_applied_t( i ) +
                                    p_charges_applied_t( i ) );


            dbms_sql.bind_variable( p_insert_ra_c,
		                    'acctd_amount_applied_from',
                                    p_acctd_amt_applied_from_t( i ) );

            dbms_sql.bind_variable( p_insert_ra_c,
		                    'acctd_amount_applied_to',
                                    p_acctd_amt_applied_to_t( i ) );

            dbms_sql.bind_variable( p_insert_ra_c,
		                    'line_applied',
                                    p_line_applied_t( i ) );

            dbms_sql.bind_variable( p_insert_ra_c,
		                    'tax_applied',
                                    p_tax_applied_t( i ) );

            dbms_sql.bind_variable( p_insert_ra_c,
		                    'freight_applied',
                                    p_freight_applied_t( i ) );

            dbms_sql.bind_variable( p_insert_ra_c,
		                    'receivables_charges_applied',
                                    p_charges_applied_t( i ) );

            dbms_sql.bind_variable( p_insert_ra_c,
		                    'post_to_gl_flag',
                                    p_select_rec.post_to_gl_flag );

            select ar_receivable_applications_s.nextval
            into   l_receivable_application_id
            from   dual;

            dbms_sql.bind_variable( p_insert_ra_c,
		                    'receivable_application_id',
                                    l_receivable_application_id );

	    dbms_sql.bind_variable( p_insert_ra_c,
                                    'ussgl_transaction_code',
                                    l_ussgl_transaction_code );


        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            debug( 'EXCEPTION: Error in selecting sequence nextval',
                   MSG_LEVEL_BASIC );
            RAISE;

          WHEN OTHERS THEN
            debug( 'EXCEPTION: Error in binding insert_ra_c',
                   MSG_LEVEL_BASIC );
            RAISE;
        END;

        -------------------------------------------------------------
        -- Execute
        -------------------------------------------------------------
        BEGIN
	    debug( '  Inserting applications', MSG_LEVEL_DEBUG );
            l_ignore := dbms_sql.execute( p_insert_ra_c );

            debug( to_char(l_ignore) || ' row(s) inserted',
		           MSG_LEVEL_DEBUG );

            FOR l_app_info IN get_appl_info(l_receivable_application_id) LOOP
               ar_mrc_engine3.cm_application(
                           l_app_info.payment_schedule_id,
                           l_app_info.applied_payment_schedule_id,
                           NULL,
                           l_receivable_application_id);
            END LOOP;

        EXCEPTION
          WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing insert ra stmt',
                   MSG_LEVEL_BASIC );
            RAISE;
        END;

   --
   --Release 11.5 VAT changes, create APP record accounting
   --in ar_distributions
   --
    l_ae_doc_rec.document_type             := 'CREDIT_MEMO';
    l_ae_doc_rec.document_id               := p_select_rec.customer_trx_id;
    l_ae_doc_rec.accounting_entity_level   := 'ONE';
    l_ae_doc_rec.source_table              := 'RA';
    l_ae_doc_rec.source_id                 := l_receivable_application_id;
    l_ae_doc_rec.source_id_old             := '';
    l_ae_doc_rec.other_flag                := '';

  --Bug 1329091 - For CM, payment schedule is updated before accounting engine call
    BEGIN
      SELECT class INTO l_ps_class
      FROM   ar_payment_schedules
      WHERE  customer_trx_id = p_select_rec.customer_trx_id;
    EXCEPTION
      WHEN NO_DATA_FOUND then
        l_ps_class := 'CM';
      WHEN OTHERS then
        NULL;
    END;

    --debug('Transaction PS class '||l_ps_class ||' Customer Trx id '||to_char(p_select_rec.customer_trx_id));
    debug('Transaction PS class '||l_ps_class ||' Customer Trx id '||to_char(p_inv_ps_id_t( i )));

    IF l_ps_class = 'CM' THEN
        l_ae_doc_rec.pay_sched_upd_yn := 'Y';
    END IF;
    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);
    /*bug-6976549*/
    arp_balance_check.CHECK_APPLN_BALANCE(l_receivable_application_id,
					  NULL,
					  'N');


    -------------------------------------------------------------
    -- Update ar_payment_schedules
    -------------------------------------------------------------

        -------------------------------------------------------------
        -- Bind vars
        -------------------------------------------------------------
        BEGIN
	    debug( '  Binding update_ps_c', MSG_LEVEL_DEBUG );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'user_id',
                                    p_profile_info.user_id );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'login_id',
                                    p_profile_info.conc_login_id );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'amount_due_remaining',
                                    p_inv_amount_due_rem_t( i ) );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'gl_date_closed',
                                    p_select_rec.gl_date_closed );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'actual_date_closed',
                                    p_select_rec.actual_date_closed );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'amount_line_items_remaining',
                                    p_inv_line_rem_t( i ) );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'amount_credited',
                                    p_inv_amount_credited_t( i ) );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'freight_remaining',
                                    p_inv_freight_rem_t( i ) );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'tax_remaining',
                                    p_inv_tax_rem_t( i ) );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'acctd_amount_due_remaining',
                                    p_inv_acctd_amt_due_rem_t( i ) );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'receivables_charges_remaining',
                                    p_inv_charges_rem_t( i ) );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'applied_payment_schedule_id',
                                    p_inv_ps_id_t( i ) );



        EXCEPTION
          WHEN OTHERS THEN
            debug( 'EXCEPTION: Error in binding update_ps_c',
                   MSG_LEVEL_BASIC );
            RAISE;
        END;

        -------------------------------------------------------------
        -- Execute
        -------------------------------------------------------------
        BEGIN
	    debug( '  Updating invoice payment schedules', MSG_LEVEL_DEBUG );
            l_ignore := dbms_sql.execute( p_update_ps_c );
            debug( to_char(l_ignore) || ' row(s) updated',
		           MSG_LEVEL_DEBUG );

           /*-------------------------------------------+
            | Call central MRC library for update       |
            | of AR_PAYMENT_SCHEDULES                   |
            +-------------------------------------------*/

           ar_mrc_engine.maintain_mrc_data(
                      p_event_mode       => 'UPDATE',
                      p_table_name       => 'AR_PAYMENT_SCHEDULES',
                      p_mode             => 'SINGLE',
                      p_key_value        => p_inv_ps_id_t( i ));

        EXCEPTION
          WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing update ps stmt',
                   MSG_LEVEL_BASIC );
            debug('EXCEPTION: dynamic sql that got executed '||p_update_ps_c,
                   MSG_LEVEL_BASIC);
            debug('EXCEPTION: sqlerrm  '||sqlerrm, MSG_LEVEL_BASIC);
            RAISE;
        END;

    END LOOP;



    print_fcn_label2('arp_maintain_ps2.process_ira_data()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.process_ira_data()',
	       MSG_LEVEL_BASIC );
        RAISE;
END process_ira_data;


----------------------------------------------------------------------------
PROCEDURE insert_cm_ps_private(
	p_system_info		IN arp_trx_global.system_info_rec_type,
	p_profile_info 		IN arp_trx_global.profile_rec_type,
	p_customer_trx_id 	IN BINARY_INTEGER ) IS

    l_ignore 			INTEGER;

    l_old_trx_id		BINARY_INTEGER;
    l_customer_trx_id		BINARY_INTEGER;
    l_old_inv_trx_id		BINARY_INTEGER;
    l_inv_customer_trx_id	BINARY_INTEGER;

    l_load_inv_tables		BOOLEAN := FALSE;

    --
    -- Invoice ps attributes
    --
    l_inv_ps_id_t		id_table_type;
    l_inv_amount_due_rem_t 	number_table_type;
    l_inv_acctd_amt_due_rem_t	number_table_type;
    l_inv_line_rem_t 		number_table_type;
    l_inv_tax_rem_t 		number_table_type;
    l_inv_freight_rem_t 	number_table_type;
    l_inv_charges_rem_t 	number_table_type;
    l_inv_amount_credited_t 	number_table_type;

    --
    -- Derived attributes
    --
    l_line_applied_t 		number_table_type;
    l_tax_applied_t 		number_table_type;
    l_freight_applied_t 	number_table_type;
    l_charges_applied_t 	number_table_type;
    l_acctd_amt_applied_from_t	number_table_type;
    l_acctd_amt_applied_to_t	number_table_type;

    l_table_index		BINARY_INTEGER := 0;

    l_select_rec		select_ira_rec_type;

    -----------------------------------------------------------------------
    PROCEDURE load_tables( p_select_rec IN select_ira_rec_type ) IS

    BEGIN
        print_fcn_label2('arp_maintain_ps2.load_tables()+' );

        l_inv_ps_id_t( l_table_index ) :=
				p_select_rec.inv_payment_schedule_id;
	l_inv_amount_due_rem_t( l_table_index ) :=
				p_select_rec.inv_amount_due_remaining;
	l_inv_acctd_amt_due_rem_t( l_table_index ) :=
				p_select_rec.inv_acctd_amt_due_rem;
	l_inv_line_rem_t( l_table_index ) :=
				p_select_rec.inv_line_remaining;
	l_inv_tax_rem_t( l_table_index ) :=
				p_select_rec.inv_tax_remaining;
	l_inv_freight_rem_t( l_table_index ) :=
				p_select_rec.inv_freight_remaining;
	l_inv_charges_rem_t( l_table_index ) :=
				p_select_rec.inv_charges_remaining;
	l_inv_amount_credited_t( l_table_index ) :=
				p_select_rec.inv_amount_credited;

        l_table_index := l_table_index + 1;

        print_fcn_label2('arp_maintain_ps2.load_tables()-' );

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: arp_maintain_ps2.load_tables()',
	           MSG_LEVEL_BASIC );
            RAISE;
    END load_tables;


    -----------------------------------------------------------------------
    PROCEDURE clear_cm_tables IS

    BEGIN
        print_fcn_label2('arp_maintain_ps2.clear_cm_tables()+' );

        l_line_applied_t := null_number_t;
        l_tax_applied_t := null_number_t;
        l_freight_applied_t := null_number_t;
        l_charges_applied_t := null_number_t;
        l_acctd_amt_applied_from_t := null_number_t;
        l_acctd_amt_applied_to_t := null_number_t;

        print_fcn_label2('arp_maintain_ps2.clear_cm_tables()-' );

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: arp_maintain_ps2.clear_cm_tables()',
	           MSG_LEVEL_BASIC );
            RAISE;
    END clear_cm_tables;


    -----------------------------------------------------------------------
    PROCEDURE clear_all_tables IS

    BEGIN
        print_fcn_label2('arp_maintain_ps2.clear_all_tables()+' );

        l_inv_ps_id_t := null_id_t;
        l_inv_amount_due_rem_t := null_number_t;
        l_inv_acctd_amt_due_rem_t := null_number_t;
        l_inv_line_rem_t := null_number_t;
        l_inv_tax_rem_t := null_number_t;
        l_inv_freight_rem_t := null_number_t;
        l_inv_charges_rem_t := null_number_t;
        l_inv_amount_credited_t := null_number_t;

	clear_cm_tables;

        l_table_index := 0;

        print_fcn_label2('arp_maintain_ps2.clear_all_tables()-' );

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: arp_maintain_ps2.clear_all_tables()',
	           MSG_LEVEL_BASIC );
            RAISE;
    END clear_all_tables;

    -----------------------------------------------------------------------
    FUNCTION is_new_id( p_old_id BINARY_INTEGER, p_new_id BINARY_INTEGER )
        RETURN BOOLEAN IS
    BEGIN

        RETURN( p_old_id IS NULL OR p_old_id <> p_new_id );

    END is_new_id;

    -----------------------------------------------------------------------
    FUNCTION is_new_cm RETURN BOOLEAN IS
    BEGIN

        RETURN( l_old_trx_id IS NULL OR l_old_trx_id <> l_customer_trx_id );

    END is_new_cm;

    -----------------------------------------------------------------------
    FUNCTION is_new_inv RETURN BOOLEAN IS
    BEGIN

        RETURN( l_old_inv_trx_id IS NULL OR
		l_old_inv_trx_id <> l_inv_customer_trx_id );

    END is_new_inv;


BEGIN

    print_fcn_label( 'arp_maintain_ps2.insert_cm_ps_private()+' );

    --
    clear_all_tables;
    --
    IF( NOT( dbms_sql.is_open( ira_select_c ) AND
	     dbms_sql.is_open( ira_insert_ps_c ) AND
	     dbms_sql.is_open( ira_insert_ra_c ) AND
	     dbms_sql.is_open( ira_update_ps_c ) )) THEN

        build_ira_sql(
		system_info,
		profile_info,
		ira_select_c,
		ira_insert_ps_c,
		ira_insert_ra_c,
		ira_update_ps_c );
    END IF;

    --
    define_ira_select_columns( ira_select_c, l_select_rec );

    ---------------------------------------------------------------
    -- Bind variables
    ---------------------------------------------------------------
    dbms_sql.bind_variable( ira_select_c,
			    'customer_trx_id',
			    p_customer_trx_id );

    ---------------------------------------------------------------
    -- Execute sql
    ---------------------------------------------------------------
    debug( '  Executing select sql', MSG_LEVEL_DEBUG );

    BEGIN
        l_ignore := dbms_sql.execute( ira_select_c );

    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error executing select sql',
		 MSG_LEVEL_BASIC );
          RAISE;
    END;


    ---------------------------------------------------------------
    -- Fetch rows
    ---------------------------------------------------------------
    BEGIN
        LOOP

            IF dbms_sql.fetch_rows( ira_select_c ) > 0  THEN

	        debug('  Fetched a row', MSG_LEVEL_DEBUG );

                -----------------------------------------------
                -- Load row into record
                -----------------------------------------------
		dbms_sql.column_value( ira_select_c, 4, l_customer_trx_id );
		dbms_sql.column_value( ira_select_c, 15,
					l_inv_customer_trx_id );

                -----------------------------------------------
		-- Check if invoice or cm changed
                -----------------------------------------------
		IF( is_new_inv OR is_new_cm ) THEN

		    debug( '  new invoice or cm', MSG_LEVEL_DEBUG );

                    -----------------------------------------------
		    -- Check if invoice changed
                    -----------------------------------------------
		    IF( is_new_inv ) THEN

			debug( '  new invoice', MSG_LEVEL_DEBUG );

                        ---------------------------------------------------
			-- Start loading invoice ps tables for new invoice
                        ---------------------------------------------------
			l_load_inv_tables := TRUE;

		    END IF;

		    IF( l_old_inv_trx_id IS NOT NULL ) THEN

			debug( '  process1', MSG_LEVEL_DEBUG );

			process_ira_data(
				system_info,
				profile_info,
				ira_insert_ps_c,
				ira_insert_ra_c,
				ira_update_ps_c,
				l_select_rec,
				l_table_index,
				l_inv_ps_id_t,
				l_inv_amount_due_rem_t,
				l_inv_acctd_amt_due_rem_t,
				l_inv_line_rem_t,
				l_inv_tax_rem_t,
				l_inv_freight_rem_t,
				l_inv_charges_rem_t,
				l_inv_amount_credited_t,
				l_line_applied_t,
				l_tax_applied_t,
				l_freight_applied_t,
				l_charges_applied_t,
				l_acctd_amt_applied_from_t,
				l_acctd_amt_applied_to_t );

		    END IF;

                    -----------------------------------------------
		    -- Check if new invoice
                    -----------------------------------------------
		    IF( is_new_inv ) THEN

			clear_all_tables;

			l_old_inv_trx_id := l_inv_customer_trx_id;
			l_old_trx_id := l_customer_trx_id;

                    -----------------------------------------------
		    -- Else new CM
                    -----------------------------------------------
		    ELSE

			clear_cm_tables;

			l_load_inv_tables := FALSE;
			l_old_trx_id := l_customer_trx_id;

		    END IF;

		END IF;		-- END inv or cm changed

		get_ira_column_values( ira_select_c, l_select_rec );
		dump_ira_select_rec( l_select_rec );


		IF( l_load_inv_tables ) THEN
		    load_tables( l_select_rec );
		END IF;

		-- >> dump tables

            ELSE
                -----------------------------------------------
		-- No more rows to fetch, process last set
                -----------------------------------------------

		debug( '  process2', MSG_LEVEL_DEBUG );

		process_ira_data(
			system_info,
			profile_info,
			ira_insert_ps_c,
			ira_insert_ra_c,
			ira_update_ps_c,
			l_select_rec,
			l_table_index,
			l_inv_ps_id_t,
			l_inv_amount_due_rem_t,
			l_inv_acctd_amt_due_rem_t,
			l_inv_line_rem_t,
			l_inv_tax_rem_t,
			l_inv_freight_rem_t,
			l_inv_charges_rem_t,
			l_inv_amount_credited_t,
			l_line_applied_t,
			l_tax_applied_t,
			l_freight_applied_t,
			l_charges_applied_t,
			l_acctd_amt_applied_from_t,
			l_acctd_amt_applied_to_t );


                EXIT;

            END IF;


        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error fetching select cursor',
                   MSG_LEVEL_BASIC );
            RAISE;

    END;

    print_fcn_label( 'arp_maintain_ps2.insert_cm_ps_private()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.insert_cm_ps_private()',
	       MSG_LEVEL_BASIC );
        RAISE;

END insert_cm_ps_private;


----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  build_ups_sql
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--        system_info
--        profile_info
--
--      IN/OUT:
--        select_c
--        insert_ps_c
--	  insert_ra_c
--	  update_ps_c
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--
--  01-JUN-01  1483656 - Updated select, insert, and update to allocate
--              tax and freight to deposits.
----------------------------------------------------------------------------
PROCEDURE build_ups_sql(
	p_system_info 		IN arp_trx_global.system_info_rec_type,
        p_profile_info 		IN arp_trx_global.profile_rec_type,
        p_select_c 		IN OUT NOCOPY INTEGER,
	p_insert_adj_c 		IN OUT NOCOPY INTEGER,
        p_update_ps_c 		IN OUT NOCOPY INTEGER ) IS

    l_insert_adj_sql	VARCHAR2(2000);
    l_update_ps_sql	VARCHAR2(2000);
    l_select_sql	VARCHAR2(6000);


BEGIN

    print_fcn_label( 'arp_maintain_ps2.build_ups_sql()+' );

    ------------------------------------------------
    -- Select sql
    ------------------------------------------------
    l_select_sql :=
'SELECT
/* :raagixuix, */
ctl.set_of_books_id,
/* -1, */
/* -''Y'',  */
/* ''LINE'', overridden below */
/* -''C'', */
/* -''A'', */
sum(ctl.extended_amount) /
  (count(distinct ps.payment_schedule_id) *
  count(distinct nvl(ra.receivable_application_id, -9.9)) *
  count(distinct nvl(adj.adjustment_id, -9.9))),
nvl(:gl_date, nvl(ctlgd.gl_date, ct.trx_date)),
ctlgd_com.code_combination_id,
decode(ctt_com.type,
       ''DEP'', ctl.customer_trx_id,
        ctl_com.customer_trx_id),
ps.payment_schedule_id,
decode(ctt_com.type,
       ''DEP'', null,
       ctl.customer_trx_id),
''Y'',      /* bugfix 2614759. Instead of ctt.post_to_gl, pass y always. */
ct_com.customer_trx_id,
tl.relative_amount / t.base_amount,
c.precision,
c.minimum_accountable_unit,
greatest(nvl(max(decode(ra.confirmed_flag,
				''Y'', ra.gl_date,
                                null,
                                   decode(ra.receivable_application_id,
					      null, nvl(ctlgd.gl_date,
					                ct.trx_date),
                                              ra.gl_date),
					nvl(ctlgd.gl_date,
                                            ct.trx_date))),
			     nvl(ctlgd.gl_date,ct.trx_date)),
	                 nvl(max(decode(adj.status,
					''A'',adj.gl_date,
					nvl(ctlgd.gl_date,
					    ct.trx_date))),
			     nvl(ctlgd.gl_date,ct.trx_date)),
	                 nvl(:gl_date, nvl(ctlgd.gl_date, ct.trx_date))),
greatest(nvl(max(decode(ra.confirmed_flag,
                                        ''Y'', ra.apply_date,
                                        null,
                                       decode(ra.receivable_application_id,
                                              null, ct.trx_date,
                                              ra.apply_date),
				       ct.trx_date)),
			     ct.trx_date),
	                 nvl(max(decode(adj.status,
					''A'',adj.apply_date,
				ct.trx_date)),
			     ct.trx_date),
	                 nvl(:apply_date, ct.trx_date),
                         ct.trx_date),
nvl(:apply_date, ct.trx_date),
ctt_com.type,
/* :raagixlul, */
/* null, */
nvl(ps.amount_line_items_remaining,0),
ps.amount_due_remaining,
ps.acctd_amount_due_remaining,
nvl(ps.amount_adjusted,0),
c_ps.precision,
c_ps.minimum_accountable_unit,
ct_ps.exchange_rate,
ctl.customer_trx_id,
ct_ps.invoice_currency_code,
ctt_com.allocate_tax_freight,
DECODE(ctt_com.allocate_tax_freight, ''Y'', ''INVOICE'',''LINE''), /*1483656 - LINE or INVOICE */
nvl(ps.tax_remaining, 0),
nvl(ps.freight_remaining, 0),
ARPT_SQL_FUNC_UTIL.get_sum_of_trx_lines(ctl.customer_trx_id, ''TAX''),
ARPT_SQL_FUNC_UTIL.get_sum_of_trx_lines(ctl.customer_trx_id, ''FREIGHT'')
FROM
ra_cust_trx_types ctt,
ra_cust_trx_types ctt_com,
ra_cust_trx_line_gl_dist ctlgd_com,
ar_payment_schedules ps,
ar_receivable_applications ra,
ar_adjustments adj,
fnd_currencies c,
ra_terms t,
ra_terms_lines tl,
ra_customer_trx ct_com,
ra_customer_trx_lines ctl_com,
ra_customer_trx ct_ps,
fnd_currencies c_ps,
ra_customer_trx_lines ctl,
ra_customer_trx ct,
ra_cust_trx_line_gl_dist ctlgd
WHERE ct.customer_trx_id = :customer_trx_id
and   ctl.customer_trx_id = ct.customer_trx_id
and   ctlgd.customer_trx_id = ct.customer_trx_id
and   ctlgd.account_class = ''REC''
and   ctlgd.latest_rec_flag = ''Y''
and   ctl.line_type = ''LINE''
and   exists
        (select ''x''
         from   ra_customer_trx trx
         where  trx.customer_trx_id = ctl.customer_trx_id)
and   ctl.initial_customer_trx_line_id is not null
and   ct.invoice_currency_code = c.currency_code
and   ct.cust_trx_type_id = ctt.cust_trx_type_id
and   ctt.type = ''INV''
and   ctl.initial_customer_trx_line_id = ctl_com.customer_trx_line_id
and   ctl_com.customer_trx_id = ct_com.customer_trx_id
and   ctl_com.customer_trx_line_id = ctlgd_com.customer_trx_line_id
and   ctlgd_com.account_class = ''REV''
and   ct_com.cust_trx_type_id = ctt_com.cust_trx_type_id
and   ps.customer_trx_id =
                decode(ctt_com.type,
                       ''DEP'', ctl.customer_trx_id,
                              ctl_com.customer_trx_id)
and   ps.customer_trx_id = ct_ps.customer_trx_id
and   ct_ps.invoice_currency_code = c_ps.currency_code
and   ps.term_id = t.term_id
and   ps.term_id = tl.term_id
and   ps.terms_sequence_number = tl.sequence_num
and   ps.customer_trx_id = ra.applied_customer_trx_id (+)
and   ps.customer_trx_id = adj.customer_trx_id (+)
and   nvl(ctlgd_com.CCID_CHANGE_FLAG,''Y'') <>''N''  /* Bug 8788491 */
GROUP BY
ctlgd_com.code_combination_id,
ctl.customer_trx_id,
ctl_com.customer_trx_id,
ps.payment_schedule_id,
/* bugfix 2614759. comment out ctt.post_to_gl, */
ctt_com.type,
ctt_com.allocate_tax_freight, /*1483656*/
ct_com.customer_trx_id,
tl.relative_amount / t.base_amount,
c.precision,
c.minimum_accountable_unit,
ra.applied_customer_trx_id,
adj.customer_trx_id,
ctlgd.gl_date,
ct.trx_date,
ctlgd_com.gl_date,
ct_com.trx_date,
ctl.set_of_books_id,
c_ps.precision,
c_ps.minimum_accountable_unit,
ct_ps.exchange_rate,
ps.amount_line_items_remaining,
ps.tax_remaining,
ps.freight_remaining,
ps.amount_due_remaining,
ps.amount_adjusted,
ps.acctd_amount_due_remaining,
ps.terms_sequence_number,
ct_ps.invoice_currency_code
ORDER BY
ct_com.customer_trx_id,
ctl.customer_trx_id,
ps.terms_sequence_number';


    debug('  select_sql = ' || CRLF ||
          l_select_sql || CRLF,
          MSG_LEVEL_DEBUG);
    debug('  len(select_sql) = '||
          to_char(length(l_select_sql)) || CRLF,
          MSG_LEVEL_DEBUG);


    ------------------------------------------------
    -- Insert adj sql
    ------------------------------------------------
    l_insert_adj_sql :=
'INSERT INTO AR_ADJUSTMENTS
(
created_by,
creation_date,
last_updated_by,
last_update_date,
last_update_login,
request_id,
program_application_id,
program_id,
program_update_date,
set_of_books_id,
receivables_trx_id,
automatically_generated,
type,
adjustment_type,
status,
apply_date,
adjustment_id,
gl_date,
code_combination_id,
customer_trx_id,
payment_schedule_id,
subsequent_trx_id,
postable,
adjustment_number,
created_from,
posting_control_id,
amount,
acctd_amount,
line_adjusted,
tax_adjusted,
freight_adjusted
,org_id
)
VALUES
(
:user_id,
sysdate,
:user_id,
sysdate,
:login_id,
:request_id,
:application_id,
:program_id,
sysdate,
:set_of_books_id,
-1,
''Y'',
:adjust_type,
''C'',
''A'',
:trx_date,
:adjustment_id,
:gl_date,
:code_combination_id,
:adjusted_trx_id,
:payment_schedule_id,
:subsequent_trx_id,
:post_to_gl_flag,
to_char(ar_adjustment_number_s.nextval),
''RAXTRX'',
-3,
-1 * :adj_amount,
-1 * :acctd_adj_amount,
-1 * :line_adj_amount,
-1 * :tax_adj_amount,
-1 * :frt_adj_amount
,:org_id --arp_standard.sysparm.org_id /* SSA changes anuj */
)';

    debug('  insert_adj_sql = ' || CRLF ||
          l_insert_adj_sql || CRLF,
          MSG_LEVEL_DEBUG);
    debug('  len(insert_adj_sql) = '||
          to_char(length(l_insert_adj_sql)) || CRLF,
          MSG_LEVEL_DEBUG);


    ------------------------------------------------
    -- Update ps sql
    ------------------------------------------------
 -- Modified the update statement to incorporate the hard-coded date if the transaction is open - For Bug:5491085
    l_update_ps_sql :=
'UPDATE AR_PAYMENT_SCHEDULES
SET    last_update_date = sysdate,
       last_updated_by = :user_id,
       last_update_login = :login_id,
       status = decode(:amount_due_remaining, 0, ''CL'', ''OP''),
       gl_date_closed =
               decode(:amount_due_remaining, 0, :gl_date_closed,TO_DATE(''31-12-4712'',''DD-MM-YYYY'')),
       actual_date_closed =
               decode(:amount_due_remaining, 0, :actual_date_closed,TO_DATE(''31-12-4712'',''DD-MM-YYYY'')),
       amount_due_remaining = :amount_due_remaining,
       acctd_amount_due_remaining = :acctd_amount_due_remaining,
       amount_line_items_remaining = :amount_line_items_remaining,
       amount_adjusted = :amount_adjusted,
       tax_remaining = :tax_remaining,
       freight_remaining = :freight_remaining
WHERE payment_schedule_id = :payment_schedule_id';

    debug('  update_ps_sql = ' || CRLF ||
          l_update_ps_sql || CRLF,
          MSG_LEVEL_DEBUG);
    debug('  len(update_ps_sql) = '||
          to_char(length(l_update_ps_sql)) || CRLF,
          MSG_LEVEL_DEBUG);




    ------------------------------------------------
    -- Parse sql stmts
    ------------------------------------------------
    BEGIN
	debug( '  Parsing stmts', MSG_LEVEL_DEBUG );

	debug( '  Parsing insert_adj_c', MSG_LEVEL_DEBUG );
        p_insert_adj_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_insert_adj_c, l_insert_adj_sql,
                        dbms_sql.v7 );

	debug( '  Parsing update_ps_c', MSG_LEVEL_DEBUG );
        p_update_ps_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_update_ps_c, l_update_ps_sql,
                        dbms_sql.v7 );

	debug( '  Parsing select_c', MSG_LEVEL_DEBUG );
        p_select_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_select_c, l_select_sql,
                        dbms_sql.v7 );

    EXCEPTION
      WHEN OTHERS THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug(SQLERRM);
          END IF;
          debug( 'EXCEPTION: Error parsing stmts', MSG_LEVEL_BASIC );
          RAISE;
    END;

    print_fcn_label( 'arp_maintain_ps2.build_ups_sql()-' );


EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.build_ups_sql()',
	       MSG_LEVEL_BASIC );

        RAISE;
END build_ups_sql;


----------------------------------------------------------------------------
PROCEDURE define_ups_select_columns(
	p_select_c   IN INTEGER,
        p_select_rec IN select_ups_rec_type ) IS

BEGIN

    print_fcn_label2( 'arp_maintain_ps2.define_ups_select_columns()+' );

    dbms_sql.define_column( p_select_c, 1, p_select_rec.set_of_books_id );
    dbms_sql.define_column( p_select_c, 2, p_select_rec.total_line_amount );
    dbms_sql.define_column( p_select_c, 3, p_select_rec.gl_date );
    dbms_sql.define_column( p_select_c, 4, p_select_rec.code_combination_id );
    dbms_sql.define_column( p_select_c, 5,
				p_select_rec.adjusted_trx_id );
    dbms_sql.define_column( p_select_c, 6,
				p_select_rec.payment_schedule_id );
    dbms_sql.define_column( p_select_c, 7,
				p_select_rec.subsequent_trx_id );
    dbms_sql.define_column( p_select_c, 8,
			    p_select_rec.post_to_gl_flag, 1 );
    dbms_sql.define_column( p_select_c, 9,
				p_select_rec.commitment_trx_id );
    dbms_sql.define_column( p_select_c, 10, p_select_rec.percent );
    dbms_sql.define_column( p_select_c, 11, p_select_rec.precision );
    dbms_sql.define_column( p_select_c, 12, p_select_rec.min_acc_unit );
    dbms_sql.define_column( p_select_c, 13, p_select_rec.gl_date_closed );
    dbms_sql.define_column( p_select_c, 14, p_select_rec.actual_date_closed );
    dbms_sql.define_column( p_select_c, 15, p_select_rec.trx_date );
    dbms_sql.define_column( p_select_c, 16, p_select_rec.commitment_type, 20 );
    dbms_sql.define_column( p_select_c, 17, p_select_rec.line_remaining );
    dbms_sql.define_column( p_select_c, 18,
				p_select_rec.amount_due_remaining );
    dbms_sql.define_column( p_select_c, 19,
				p_select_rec.acctd_amt_due_rem );
    dbms_sql.define_column( p_select_c, 20,
				p_select_rec.amount_adjusted );
    dbms_sql.define_column( p_select_c, 21, p_select_rec.ps_precision );
    dbms_sql.define_column( p_select_c, 22, p_select_rec.ps_min_acc_unit );
    dbms_sql.define_column( p_select_c, 23, p_select_rec.ps_exchange_rate );
    dbms_sql.define_column( p_select_c, 24, p_select_rec.customer_trx_id );
    dbms_sql.define_column( p_select_c, 25,
		p_select_rec.ps_currency_code, 15 );
    -- 1483656 new columns for allocating tax and freight
    dbms_sql.define_column( p_select_c, 26, p_select_rec.allocate_tax_freight,1 );
    dbms_sql.define_column( p_select_c, 27, p_select_rec.adjustment_type,8 );
    dbms_sql.define_column( p_select_c, 28, p_select_rec.tax_remaining );
    dbms_sql.define_column( p_select_c, 29, p_select_rec.freight_remaining );
    dbms_sql.define_column( p_select_c, 30, p_select_rec.total_tax_amount );
    dbms_sql.define_column( p_select_c, 31, p_select_rec.total_freight_amount );

    print_fcn_label2( 'arp_maintain_ps2.define_ups_select_columns()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_maintain_ps2.define_ups_select_columns()',
	      MSG_LEVEL_BASIC);
        RAISE;
END define_ups_select_columns;


----------------------------------------------------------------------------
PROCEDURE get_ups_column_values( p_select_c   IN INTEGER,
                             p_select_rec IN OUT NOCOPY select_ups_rec_type ) IS
/* Bug 460927 - Changed IN to IN OUT in the above line - Oracle 8 */
BEGIN
    print_fcn_label2( 'arp_maintain_ps2.get_ups_column_values()+' );

    dbms_sql.column_value( p_select_c, 1, p_select_rec.set_of_books_id );
    dbms_sql.column_value( p_select_c, 2, p_select_rec.total_line_amount );
    dbms_sql.column_value( p_select_c, 3, p_select_rec.gl_date );
    dbms_sql.column_value( p_select_c, 4, p_select_rec.code_combination_id );
    dbms_sql.column_value( p_select_c, 5,
				p_select_rec.adjusted_trx_id );
    dbms_sql.column_value( p_select_c, 6, p_select_rec.payment_schedule_id );
    dbms_sql.column_value( p_select_c, 7, p_select_rec.subsequent_trx_id );
    dbms_sql.column_value( p_select_c, 8, p_select_rec.post_to_gl_flag );
    dbms_sql.column_value( p_select_c, 9, p_select_rec.commitment_trx_id );
    dbms_sql.column_value( p_select_c, 10, p_select_rec.percent );
    dbms_sql.column_value( p_select_c, 11, p_select_rec.precision );
    dbms_sql.column_value( p_select_c, 12, p_select_rec.min_acc_unit );
    dbms_sql.column_value( p_select_c, 13, p_select_rec.gl_date_closed );
    dbms_sql.column_value( p_select_c, 14, p_select_rec.actual_date_closed );
    dbms_sql.column_value( p_select_c, 15, p_select_rec.trx_date );
    dbms_sql.column_value( p_select_c, 16, p_select_rec.commitment_type );
    dbms_sql.column_value( p_select_c, 17, p_select_rec.line_remaining );
    dbms_sql.column_value( p_select_c, 18,
				p_select_rec.amount_due_remaining );
    dbms_sql.column_value( p_select_c, 19, p_select_rec.acctd_amt_due_rem );
    dbms_sql.column_value( p_select_c, 20, p_select_rec.amount_adjusted );
    dbms_sql.column_value( p_select_c, 21, p_select_rec.ps_precision );
    dbms_sql.column_value( p_select_c, 22, p_select_rec.ps_min_acc_unit );
    dbms_sql.column_value( p_select_c, 23, p_select_rec.ps_exchange_rate );
    dbms_sql.column_value( p_select_c, 24, p_select_rec.customer_trx_id );
    dbms_sql.column_value( p_select_c, 25, p_select_rec.ps_currency_code );
    -- 1483656 new columns for allocating tax and freight
    dbms_sql.column_value( p_select_c, 26, p_select_rec.allocate_tax_freight );
    dbms_sql.column_value( p_select_c, 27, p_select_rec.adjustment_type );
    dbms_sql.column_value( p_select_c, 28, p_select_rec.tax_remaining );
    dbms_sql.column_value( p_select_c, 29, p_select_rec.freight_remaining );
    dbms_sql.column_value( p_select_c, 30, p_select_rec.total_tax_amount );
    dbms_sql.column_value( p_select_c, 31, p_select_rec.total_freight_amount );

    print_fcn_label2( 'arp_maintain_ps2.get_ups_column_values()-' );
EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_maintain_ps2.get_ups_column_values()',
		MSG_LEVEL_BASIC);
        RAISE;
END get_ups_column_values;


----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  dump_ups_select_rec
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--        select_rec
--
--      IN/OUT:
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE dump_ups_select_rec( p_select_rec IN select_ups_rec_type ) IS
BEGIN

    print_fcn_label2( 'arp_maintain_ps2.dump_ups_select_rec()+' );

    debug( '  Dumping select record: ', MSG_LEVEL_DEBUG );
    debug( '  set_of_books_id='
           || p_select_rec.set_of_books_id, MSG_LEVEL_DEBUG );
    debug( '  customer_trx_id='
           || p_select_rec.customer_trx_id, MSG_LEVEL_DEBUG );
    debug( '  post_to_gl_flag='
           || p_select_rec.post_to_gl_flag, MSG_LEVEL_DEBUG );
    debug( '  trx_date='
           || p_select_rec.trx_date, MSG_LEVEL_DEBUG );
    debug( '  gl_date='
           || p_select_rec.gl_date, MSG_LEVEL_DEBUG );
    debug( '  precision='
           || p_select_rec.precision, MSG_LEVEL_DEBUG );
    debug( '  min_acc_unit='
           || p_select_rec.min_acc_unit, MSG_LEVEL_DEBUG );
    debug( '  adjusted_trx_id='
           || p_select_rec.adjusted_trx_id, MSG_LEVEL_DEBUG );
    debug( '  subsequent_trx_id='
           || p_select_rec.subsequent_trx_id, MSG_LEVEL_DEBUG );
    debug( '  commitment_trx_id='
           || p_select_rec.commitment_trx_id, MSG_LEVEL_DEBUG );
    debug( '  commitment_type='
           || p_select_rec.commitment_type, MSG_LEVEL_DEBUG );
    debug( '  ps_currency_code='
           || p_select_rec.ps_currency_code, MSG_LEVEL_DEBUG );
    debug( '  ps_exchange_rate='
           || p_select_rec.ps_exchange_rate, MSG_LEVEL_DEBUG );
    debug( '  ps_precision='
           || p_select_rec.ps_precision, MSG_LEVEL_DEBUG );
    debug( '  ps_min_acc_unit='
           || p_select_rec.ps_min_acc_unit, MSG_LEVEL_DEBUG );
    debug( '  code_combination_id='
           || p_select_rec.code_combination_id, MSG_LEVEL_DEBUG );
    debug( '  gl_date_closed='
           || p_select_rec.gl_date_closed, MSG_LEVEL_DEBUG );
    debug( '  actual_date_closed='
           || p_select_rec.actual_date_closed, MSG_LEVEL_DEBUG );
    debug( '  total_line_amount='
           || p_select_rec.total_line_amount, MSG_LEVEL_DEBUG );
    debug( '  payment_schedule_id='
           || p_select_rec.payment_schedule_id, MSG_LEVEL_DEBUG );
    debug( '  amount_due_remamining='
           || p_select_rec.amount_due_remaining, MSG_LEVEL_DEBUG );
    debug( '  acctd_amt_due_rem='
           || p_select_rec.acctd_amt_due_rem, MSG_LEVEL_DEBUG );
    debug( '  line_remaining='
           || p_select_rec.line_remaining, MSG_LEVEL_DEBUG );
    debug( '  amount_adjusted='
           || p_select_rec.amount_adjusted, MSG_LEVEL_DEBUG );
    debug( '  percent='
           || p_select_rec.percent, MSG_LEVEL_DEBUG );
    /* 1483656 - Commitments Project */
    debug( '  tax_remaining='
           || p_select_rec.tax_remaining, MSG_LEVEL_DEBUG );
    debug( '  freight_remaining='
           || p_select_rec.freight_remaining, MSG_LEVEL_DEBUG );
    debug( '  adjustment_type='
           || p_select_rec.adjustment_type, MSG_LEVEL_DEBUG );

    print_fcn_label2( 'arp_maintain_ps2.dump_ups_select_rec()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.dump_ups_select_rec()',
               MSG_LEVEL_BASIC );
        RAISE;
END dump_ups_select_rec;


------------------------------------------------------------------------
-- 1483656 - added 5 new parameters to this proceedure

PROCEDURE process_ups_data(
	p_system_info		IN arp_trx_global.system_info_rec_type,
	p_profile_info 		IN arp_trx_global.profile_rec_type,
        p_insert_adj_c			IN INTEGER,
        p_update_ps_c			IN INTEGER,
	p_select_rec			IN select_ups_rec_type,
        p_number_records		IN NUMBER,
        p_ps_id_t			IN id_table_type,
        p_ps_amount_due_rem_t 		IN OUT NOCOPY number_table_type,
        p_ps_acctd_amt_due_rem_t	IN OUT NOCOPY number_table_type,
        p_ps_line_rem_t 		IN OUT NOCOPY number_table_type,
        p_ps_amount_adjusted_t 		IN OUT NOCOPY number_table_type,
        p_adj_amount_t 			IN OUT NOCOPY number_table_type,
        p_acctd_adj_amount_t 		IN OUT NOCOPY number_table_type,
        p_percent_t 			IN number_table_type,
        p_ps_tax_rem_t                  IN OUT NOCOPY number_table_type,
        p_ps_freight_rem_t              IN OUT NOCOPY number_table_type,
        p_line_adj_t                    IN OUT NOCOPY number_table_type,
        p_tax_adj_t                     IN OUT NOCOPY number_table_type,
        p_frt_adj_t                     IN OUT NOCOPY number_table_type) IS


    l_ignore 			INTEGER;

    l_new_ps_adr		NUMBER;
    l_new_ps_acctd_adr		NUMBER;
    l_new_acctd_adj_amount	NUMBER;

    l_commitment_bal		NUMBER;
    l_amount			NUMBER;
    /* VAT changes */
    l_ae_doc_rec         	ae_doc_rec_type;
    l_adjustment_id	  	ar_adjustments.adjustment_id%type;

    l_total_tax_adj             NUMBER;
    l_total_frt_adj             NUMBER;
    l_total_line_adj            NUMBER;

    /* Bug 3537233 */
    l_line_remaining            NUMBER := 0;
    l_tax_remaining             NUMBER := 0;
    l_freight_remaining         NUMBER := 0;

    /* Bug 3856079 */
    l_line_percent_t            number_table_type;
    l_tax_percent_t             number_table_type;
    l_frt_percent_t             number_table_type;

BEGIN
    print_fcn_label2('arp_maintain_ps2.process_ups_data()+' );

    --------------------------------------------------------------------
    -- Find commitment balance
    --------------------------------------------------------------------
    l_commitment_bal := arp_bal_util.get_commitment_balance(
				p_select_rec.commitment_trx_id,
				null,	-- class
				g_oe_install_flag,	-- oe_installed_flag
				g_so_source_code 	-- so_source_code
			);

    -- 1483656 - figure total amount as either total line or total balance
    --   and determine how much of it should be tax or freight vs line

    IF (p_select_rec.commitment_type = 'DEP')
    THEN
       /* Bug 3431804, 3537233
          Figure total amount remaining (L, T, and F) based on
          amounts for each PS row (installment) */
       FOR i IN p_ps_line_rem_t.FIRST..p_ps_line_rem_t.LAST LOOP
          l_line_remaining := l_line_remaining + nvl(p_ps_line_rem_t(i),0);
          l_tax_remaining :=  l_tax_remaining + nvl(p_ps_tax_rem_t(i),0);
          l_freight_remaining := l_freight_remaining +
                         nvl(p_ps_freight_rem_t(i),0);
       END LOOP;

       /* Bug 3856079 - figure percents for LTF based on
          amounts due remaining in those buckets */
       FOR i IN p_ps_line_rem_t.FIRST..p_ps_line_rem_t.LAST LOOP
          IF l_line_remaining <> 0
          THEN
             l_line_percent_t(i) := p_ps_line_rem_t(i) / l_line_remaining;
          ELSE
             l_line_percent_t(i) := 0;
          END IF;

          IF l_tax_remaining <> 0
          THEN
             l_tax_percent_t(i)  := p_ps_tax_rem_t(i) / l_tax_remaining;
          ELSE
             l_tax_percent_t(i) := 0;
          END IF;

          IF l_freight_remaining <> 0
          THEN
             l_frt_percent_t(i)  := p_ps_freight_rem_t(i) / l_freight_remaining;
          ELSE
             l_frt_percent_t(i) := 0;
          END IF;
       END LOOP;
    ELSE
       /* GUAR case */

       /* Bug 3570404
          Guarantees use SELECT in build_ups_sql differently.
          The joins to PS are for the GUAR rather than the target
          invoice.  This means that we have to use the line totals
          from ra_customer_trx_lines instead. */
       l_line_remaining := p_select_rec.total_line_amount;

       /* Following columns are not used for GUARs - but
          I choose to initialize them for clarity */
       l_tax_remaining  := 0;
       l_freight_remaining := 0;
    END IF;

    IF( p_select_rec.allocate_tax_freight = 'Y') THEN
        /* Only DEPs can allocate tax and freight */

        debug( ' allocating tax and freight (new logic)');

        l_amount := LEAST( l_commitment_bal, (l_line_remaining +
                                              l_tax_remaining  +
                                              l_freight_remaining));

        debug( '  total_invoice_amount='||p_select_rec.total_line_amount,
		MSG_LEVEL_DEBUG );
        debug( '  l_commitment_bal='||l_commitment_bal, MSG_LEVEL_DEBUG );
        debug( '  l_amount='||l_amount, MSG_LEVEL_DEBUG );
        debug( '  total lines          = '|| p_select_rec.total_line_amount, MSG_LEVEL_DEBUG );
        debug( '  total tax lines      = '|| p_select_rec.total_tax_amount, MSG_LEVEL_DEBUG );
        debug( '  total freight lines  = '|| p_select_rec.total_freight_amount, MSG_LEVEL_DEBUG );
        debug( '  lines rem          = '|| l_line_remaining, MSG_LEVEL_DEBUG );
        debug( '  tax rem      = '|| l_tax_remaining, MSG_LEVEL_DEBUG );
        debug( '  freight rem  = '|| l_freight_remaining, MSG_LEVEL_DEBUG );

        -- Determine how much of adjustment amount is tax and freight

        l_total_tax_adj := arpcurr.currround((l_tax_remaining /
                                             (l_line_remaining +
                                              l_tax_remaining +
                                              l_freight_remaining)
                                                * l_amount),
                                              p_select_rec.ps_currency_code);

        l_total_frt_adj := arpcurr.currround((l_freight_remaining /
                                             (l_line_remaining +
                                              l_tax_remaining +
                                              l_freight_remaining)
                                                * l_amount),
                                              p_select_rec.ps_currency_code);

        l_total_line_adj := l_amount - (l_total_tax_adj + l_total_frt_adj);

        debug( '  total line adj       = '||l_total_line_adj, MSG_LEVEL_DEBUG );
        debug( '  total tax adj amount = '||l_total_tax_adj, MSG_LEVEL_DEBUG );
        debug( '  total freight adj amt= '||l_total_frt_adj, MSG_LEVEL_DEBUG );

    ELSE

        debug( ' allocating lines only (original logic) ');

        l_amount := LEAST( l_commitment_bal, l_line_remaining);

        debug( '  total_line_amount='||p_select_rec.total_line_amount,
		MSG_LEVEL_DEBUG );
        debug( '  line remaining = ' || l_line_remaining);
        debug( '  l_commitment_bal='||l_commitment_bal, MSG_LEVEL_DEBUG );
        debug( '  l_amount='||l_amount, MSG_LEVEL_DEBUG );

        -- line and total adjustment are equal
        l_total_line_adj := l_amount;
        l_total_tax_adj  := null;
        l_total_frt_adj  := null;

        debug( '  total line adj       = '||l_total_line_adj, MSG_LEVEL_DEBUG );
        debug( '  total tax adj        = '||l_total_tax_adj, MSG_LEVEL_DEBUG );
        debug( '  total freight adj    = '||l_total_frt_adj, MSG_LEVEL_DEBUG );

    END if;

    --------------------------------------------------------------------
    -- Distribute amounts using percents
    -- 1483656 - The original logic split the entire adjustment
    -- amount across the periods and it was assumed to be
    -- equal to the line amount.  We now split the line
    -- and conditionally the tax and freight.  Then
    -- figure the total adjustment amount in the loop below as
    -- total = line + tax + frt
    --------------------------------------------------------------------

    /* Bug 3856079 - replaced p_percent_t with l_line_percent_t,
        l_tax_percent_t, and l_frt_percent_t so the allocation
        of amounts is driven from the PS.ADR columns

       Bug 4192201 - l_line_percent_t is defined only for DEP,
        for GUAR still use p_percent_t */

    IF (p_select_rec.commitment_type = 'DEP')
    THEN
       distribute_amount(
                p_number_records,
                p_select_rec.ps_currency_code,
                l_total_line_adj,
                l_line_percent_t,
                p_line_adj_t);
    ELSE
       distribute_amount(
                p_number_records,
                p_select_rec.ps_currency_code,
                l_total_line_adj,
                p_percent_t,
                p_line_adj_t);
    END IF;

    IF( p_select_rec.allocate_tax_freight = 'Y') THEN

       distribute_amount(
   		p_number_records,
   		p_select_rec.ps_currency_code,
   		l_total_tax_adj,
		l_tax_percent_t,
		p_tax_adj_t);

       distribute_amount(
		p_number_records,
		p_select_rec.ps_currency_code,
		l_total_frt_adj,
		l_frt_percent_t,
		p_frt_adj_t);

    END IF;

    FOR i IN 0..p_number_records - 1 LOOP

        --------------------------------------------------------------------
        -- 1483656 - figure total adjustment based on sum of line, tax, and
        --           freight.
        --------------------------------------------------------------------

        p_adj_amount_t(i) := p_line_adj_t(i);

        debug( '=== TERM ' || i || ' ===', MSG_LEVEL_DEBUG);
        debug( '  adj amount     = '||p_adj_amount_t(i), MSG_LEVEL_DEBUG );
        debug( '  line adj       = '||p_line_adj_t(i), MSG_LEVEL_DEBUG );

        /* 1483656 - Any attempts to access fields or tables
           that have not been initialized will result in an
           exception.  So, all of the following logic must be
           cased to prevent failure on non-TF commitments */

        IF (p_select_rec.allocate_tax_freight = 'Y') THEN

           p_adj_amount_t(i) := p_adj_amount_t(i) + p_tax_adj_t(i)
                                    + p_frt_adj_t(i);

           p_ps_tax_rem_t(i) := p_ps_tax_rem_t(i) - p_tax_adj_t(i);
           p_ps_freight_rem_t(i) := p_ps_freight_rem_t(i) - p_frt_adj_t(i);

        debug( '  tax adj        = '||p_tax_adj_t(i), MSG_LEVEL_DEBUG);
        debug( '  freight adj    = '||p_frt_adj_t(i), MSG_LEVEL_DEBUG );

        ELSE

        /* Set tax and freight adjustment amounts to NULL
           to prevent errors during insert of ADJ row */

           p_tax_adj_t(i) := NULL;
           p_frt_adj_t(i) := NULL;

        END IF;

        --------------------------------------------------------------------
        -- Update line_items_rem
        --------------------------------------------------------------------
	p_ps_line_rem_t( i ) := p_ps_line_rem_t( i ) - p_line_adj_t( i );

        --------------------------------------------------------------------
        -- Update amount_adj
        --------------------------------------------------------------------
	p_ps_amount_adjusted_t( i ) :=
		p_ps_amount_adjusted_t( i ) - p_adj_amount_t( i );

        --------------------------------------------------------------------
    	-- Compute new acctd_adr (aracc)
        --------------------------------------------------------------------
	arp_util.calc_acctd_amount(
		p_system_info.base_currency,
		NULL,			-- precision
		NULL,			-- mau
		p_select_rec.ps_exchange_rate,
		'-',			-- type
		p_ps_amount_due_rem_t( i ),	-- master_from
		p_ps_acctd_amt_due_rem_t( i ),	-- acctd_master_from
		p_adj_amount_t( i ),	-- detail
		l_new_ps_adr,		-- master_to
		l_new_ps_acctd_adr,	-- acctd_master_to
		l_new_acctd_adj_amount	-- acctd_detail
	);

        --------------------------------------------------------------------
	-- Update amt_due_rem, acctd_amt_due_rem
        --------------------------------------------------------------------
	p_ps_amount_due_rem_t( i ) := l_new_ps_adr;
	p_ps_acctd_amt_due_rem_t( i ) := l_new_ps_acctd_adr;
	p_acctd_adj_amount_t( i ) := l_new_acctd_adj_amount;

    END LOOP;


    -------------------------------------------------------------
    -- Insert into ar_adjustments
    -------------------------------------------------------------

    FOR i IN 0..p_number_records - 1 LOOP

        -------------------------------------------------------------
        -- Skip rows with $0 amounts (do not insert $0 adjustments)
        -------------------------------------------------------------
	IF( p_adj_amount_t( i ) = 0 ) THEN
	    GOTO skip;
	END IF;

        -------------------------------------------------------------
        -- Bind vars
        -------------------------------------------------------------
        BEGIN
	    debug( '  Binding insert_adj_c', MSG_LEVEL_DEBUG );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'user_id',
                                    p_profile_info.user_id );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'login_id',
                                    p_profile_info.conc_login_id );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'request_id',
                                    p_profile_info.request_id );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'application_id',
                                    p_profile_info.application_id );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'program_id',
                                    p_profile_info.conc_program_id );


            dbms_sql.bind_variable(
			p_insert_adj_c,
			'set_of_books_id',
                	p_select_rec.set_of_books_id );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'trx_date',
                                    p_select_rec.trx_date );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'gl_date',
                                    p_select_rec.gl_date );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'code_combination_id',
                                    p_select_rec.code_combination_id );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'adjusted_trx_id',
                                    p_select_rec.adjusted_trx_id );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'payment_schedule_id',
                                    p_ps_id_t( i ) );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'subsequent_trx_id',
                                    p_select_rec.subsequent_trx_id );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'post_to_gl_flag',
                                    p_select_rec.post_to_gl_flag );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'adj_amount',
                                    p_adj_amount_t( i ) );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'acctd_adj_amount',
                                    p_acctd_adj_amount_t( i ) );

	    /* VAT changes */
	    SELECT ar_adjustments_s.nextval
	    INTO l_adjustment_id
	    FROM   dual;

            dbms_sql.bind_variable( p_insert_adj_c,
                                    'adjustment_id',
				    l_adjustment_id );

            -- 1483656 - allocating tax and freight against commitments
            dbms_sql.bind_variable (p_insert_adj_c,
                                    'tax_adj_amount',
                                    p_tax_adj_t(i) );

            dbms_sql.bind_variable (p_insert_adj_c,
                                    'frt_adj_amount',
                                    p_frt_adj_t(i) );

            dbms_sql.bind_variable (p_insert_adj_c,
                                    'line_adj_amount',
                                    p_line_adj_t(i) );

            dbms_sql.bind_variable (p_insert_adj_c,
                                    'adjust_type',
                                    p_select_rec.adjustment_type);

--begin anuj
            dbms_sql.bind_variable (p_insert_adj_c,
                                    'org_id',
                                    arp_standard.sysparm.org_id /* SSA changes anuj */);
  --end anuj

        EXCEPTION
          WHEN OTHERS THEN
            debug( 'EXCEPTION: Error in binding insert_adj_c',
                   MSG_LEVEL_BASIC );
            RAISE;
        END;

        -------------------------------------------------------------
        -- Execute
        -------------------------------------------------------------
        BEGIN
	    debug( '  Inserting adjustments', MSG_LEVEL_DEBUG );
            l_ignore := dbms_sql.execute( p_insert_adj_c );
            debug( to_char(l_ignore) || ' row(s) inserted',
		           MSG_LEVEL_DEBUG );

           /*-------------------------------------------+
            | Call central MRC library for insertion    |
            | into MRC tables                           |
            +-------------------------------------------*/

           ar_mrc_engine.maintain_mrc_data(
                      p_event_mode       => 'INSERT',
                      p_table_name       => 'AR_ADJUSTMENTS',
                      p_mode             => 'SINGLE',
                      p_key_value        => l_adjustment_id);

        EXCEPTION
          WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing insert ra stmt',
                   MSG_LEVEL_BASIC );
            RAISE;
        END;


    -------------------------------------------------------------
    -- Update ar_payment_schedules
    -------------------------------------------------------------

        -------------------------------------------------------------
        -- Bind vars
        -------------------------------------------------------------
        BEGIN
	    debug( '  Binding update_ps_c', MSG_LEVEL_DEBUG );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'user_id',
                                    p_profile_info.user_id );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'login_id',
                                    p_profile_info.conc_login_id );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'amount_due_remaining',
                                    p_ps_amount_due_rem_t( i ) );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'gl_date_closed',
                                    p_select_rec.gl_date_closed );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'actual_date_closed',
                                    p_select_rec.actual_date_closed );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'amount_line_items_remaining',
                                    p_ps_line_rem_t( i ) );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'amount_adjusted',
                                    p_ps_amount_adjusted_t( i ) );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'acctd_amount_due_remaining',
                                    p_ps_acctd_amt_due_rem_t( i ) );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'payment_schedule_id',
                                    p_ps_id_t( i ) );

        /* 1483656 - Commitments Project */
            dbms_sql.bind_variable( p_update_ps_c,
		                    'tax_remaining',
                                    p_ps_tax_rem_t( i ) );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'freight_remaining',
                                    p_ps_freight_rem_t( i ) );


        EXCEPTION
          WHEN OTHERS THEN
            debug( 'EXCEPTION: Error in binding update_ps_c',
                   MSG_LEVEL_BASIC );
            RAISE;
        END;

        -------------------------------------------------------------
        -- Execute
        -------------------------------------------------------------
        BEGIN
	    debug( '  Updating invoice payment schedules', MSG_LEVEL_DEBUG );
            l_ignore := dbms_sql.execute( p_update_ps_c );
            debug( to_char(l_ignore) || ' row(s) updated',
		           MSG_LEVEL_DEBUG );

           /*-------------------------------------------+
            | Call central MRC library for update       |
            | of AR_PAYMENT_SCHEDULES                   |
            +-------------------------------------------*/

           ar_mrc_engine.maintain_mrc_data(
                      p_event_mode       => 'UPDATE',
                      p_table_name       => 'AR_PAYMENT_SCHEDULES',
                      p_mode             => 'SINGLE',
                      p_key_value        =>  p_ps_id_t( i ));

        EXCEPTION
          WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing update ps stmt',
                   MSG_LEVEL_BASIC );
            RAISE;
        END;

    -------------------------------------------------------------
    -- Insert into ar_distributions
    -------------------------------------------------------------
	/* VAT changes : create acct entry */
	l_ae_doc_rec.document_type := 'ADJUSTMENT';
   	l_ae_doc_rec.document_id   := l_adjustment_id;
   	l_ae_doc_rec.accounting_entity_level := 'ONE';
   	l_ae_doc_rec.source_table  := 'ADJ';
   	l_ae_doc_rec.source_id     := l_adjustment_id;
	/* Pass CCID derived by autoaccounting and COMMITMENT flag */

        --Bug 1329091 - PS is updated before Accounting Engine Call

        l_ae_doc_rec.pay_sched_upd_yn := 'Y';

	l_ae_doc_rec.source_id_old := p_select_rec.code_combination_id;
	l_ae_doc_rec.other_flag    := 'COMMITMENT';
   	arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

<<skip>>
	null;

    END LOOP;



    print_fcn_label2('arp_maintain_ps2.process_ups_data()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.process_ups_data()',
	       MSG_LEVEL_BASIC );
        RAISE;
END process_ups_data;


----------------------------------------------------------------------------
PROCEDURE insert_child_adj_private(
	p_system_info		IN arp_trx_global.system_info_rec_type,
	p_profile_info 		IN arp_trx_global.profile_rec_type,
	p_customer_trx_id 	IN BINARY_INTEGER,
        p_adj_date              IN DATE,
        p_gl_date               IN DATE) IS


    l_ignore 			INTEGER;

    l_old_trx_id		BINARY_INTEGER;
    l_customer_trx_id		BINARY_INTEGER;

    l_old_adjusted_trx_id	BINARY_INTEGER;
    l_adjusted_trx_id		BINARY_INTEGER;

    l_load_ps_tables		BOOLEAN := FALSE;

    --
    -- ps attributes
    --
    l_ps_id_t			id_table_type;
    l_ps_amount_due_rem_t 	number_table_type;
    l_ps_acctd_amt_due_rem_t	number_table_type;
    l_ps_line_rem_t 		number_table_type;
    l_ps_amount_adjusted_t 	number_table_type;
    l_percent_t			number_table_type;
    l_ps_tax_rem_t              number_table_type;
    l_ps_freight_rem_t          number_table_type;

    --
    -- Derived attributes
    --
    l_adj_amount_t 		number_table_type;
    l_acctd_adj_amount_t 	number_table_type;
    l_line_adj_t                number_table_type;
    l_tax_adj_t                 number_table_type;
    l_frt_adj_t                 number_table_type;

    l_table_index		BINARY_INTEGER := 0;

    l_select_rec		select_ups_rec_type;

    -----------------------------------------------------------------------
    PROCEDURE load_tables( p_select_rec IN select_ups_rec_type ) IS

    BEGIN
        print_fcn_label2('arp_maintain_ps2.load_tables()+' );

/* DEBUG */
-- arp_standard.enable_file_debug('/sqlcom/out/omvispt3','ARTEMP2B.log');

        l_ps_id_t( l_table_index ) := p_select_rec.payment_schedule_id;
	l_ps_amount_due_rem_t( l_table_index ) :=
				p_select_rec.amount_due_remaining;
	l_ps_acctd_amt_due_rem_t( l_table_index ) :=
				p_select_rec.acctd_amt_due_rem;
	l_ps_line_rem_t( l_table_index ) :=
				p_select_rec.line_remaining;
        -- 1483656
        l_ps_tax_rem_t( l_table_index ) :=
                                p_select_rec.tax_remaining;
        l_ps_freight_rem_t( l_table_index ) :=
                                p_select_rec.freight_remaining;

        l_ps_amount_adjusted_t( l_table_index ) :=
				p_select_rec.amount_adjusted;

	l_percent_t( l_table_index ) := p_select_rec.percent;

        l_table_index := l_table_index + 1;

        print_fcn_label2('arp_maintain_ps2.load_tables()-' );

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: arp_maintain_ps2.load_tables()',
	           MSG_LEVEL_BASIC );
            RAISE;
    END load_tables;


    -----------------------------------------------------------------------
    PROCEDURE clear_inv_tables IS

    BEGIN
        print_fcn_label2('arp_maintain_ps2.clear_cm_tables()+' );

        l_adj_amount_t := null_number_t;
        l_line_adj_t   := null_number_t;
        l_tax_adj_t    := null_number_t;
        l_frt_adj_t    := null_number_t;
        l_acctd_adj_amount_t := null_number_t;

        print_fcn_label2('arp_maintain_ps2.clear_cm_tables()-' );

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: arp_maintain_ps2.clear_cm_tables()',
	           MSG_LEVEL_BASIC );
            RAISE;
    END clear_inv_tables;


    -----------------------------------------------------------------------
    PROCEDURE clear_all_tables IS

    BEGIN
        print_fcn_label2('arp_maintain_ps2.clear_all_tables()+' );



        l_ps_id_t := null_id_t;
        l_ps_amount_due_rem_t := null_number_t;
        l_ps_acctd_amt_due_rem_t := null_number_t;
        l_ps_line_rem_t := null_number_t;
        l_ps_amount_adjusted_t := null_number_t;
        l_percent_t := null_number_t;
        l_ps_tax_rem_t := null_number_t;
        l_ps_freight_rem_t := null_number_t;

	clear_inv_tables;

        l_table_index := 0;

        print_fcn_label2('arp_maintain_ps2.clear_all_tables()-' );

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: arp_maintain_ps2.clear_all_tables()',
	           MSG_LEVEL_BASIC );
            RAISE;
    END clear_all_tables;

    -----------------------------------------------------------------------
    FUNCTION is_new_id( p_old_id BINARY_INTEGER, p_new_id BINARY_INTEGER )
        RETURN BOOLEAN IS
    BEGIN

        RETURN( p_old_id IS NULL OR p_old_id <> p_new_id );

    END is_new_id;

    -----------------------------------------------------------------------
    FUNCTION is_new_inv RETURN BOOLEAN IS
    BEGIN

        RETURN( l_old_trx_id IS NULL OR l_old_trx_id <> l_customer_trx_id );

    END is_new_inv;

    -----------------------------------------------------------------------
    FUNCTION is_new_adjusted_trx RETURN BOOLEAN IS
    BEGIN

        RETURN( l_old_adjusted_trx_id IS NULL OR
		l_old_adjusted_trx_id <> l_adjusted_trx_id );

    END is_new_adjusted_trx;


BEGIN

    print_fcn_label( 'arp_maintain_ps2.insert_child_adj_private()+' );

    --
    clear_all_tables;
    --

    IF( NOT( dbms_sql.is_open( ups_select_c ) AND
	     dbms_sql.is_open( ups_insert_adj_c ) AND
	     dbms_sql.is_open( ups_update_ps_c ) )) THEN

        build_ups_sql(
		system_info,
		profile_info,
		ups_select_c,
		ups_insert_adj_c,
		ups_update_ps_c );
    END IF;

    --
    define_ups_select_columns( ups_select_c, l_select_rec );

    ---------------------------------------------------------------
    -- Bind variables
    ---------------------------------------------------------------
    dbms_sql.bind_variable( ups_select_c,
			    'customer_trx_id',
			    p_customer_trx_id );

    /* bug 3431804 - bind dates for latecoming deposits  */
    dbms_sql.bind_variable( ups_select_c,
                            'gl_date',
                            p_gl_date);

    dbms_sql.bind_variable( ups_select_c,
                            'apply_date',
                            p_adj_date);
    ---------------------------------------------------------------
    -- Execute sql
    ---------------------------------------------------------------
    debug( '  Executing select sql', MSG_LEVEL_DEBUG );

    BEGIN
        l_ignore := dbms_sql.execute( ups_select_c );

    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error executing select sql',
		 MSG_LEVEL_BASIC );
          RAISE;
    END;


    ---------------------------------------------------------------
    -- Fetch rows
    ---------------------------------------------------------------
    BEGIN
        LOOP

            IF dbms_sql.fetch_rows( ups_select_c ) > 0  THEN

	        debug('  Fetched a row', MSG_LEVEL_DEBUG );

                -----------------------------------------------
                -- Load row into record
                -----------------------------------------------
		dbms_sql.column_value( ups_select_c, 24, l_customer_trx_id );
		dbms_sql.column_value( ups_select_c, 5, l_adjusted_trx_id );

                -----------------------------------------------
		-- Check if adjusted trx or invoice changed
                -----------------------------------------------
		IF( is_new_adjusted_trx OR is_new_inv ) THEN

		    debug( '  new adjusted trx or invoice',
				MSG_LEVEL_DEBUG );

                    -----------------------------------------------
		    -- Check if adjusted trx changed
                    -----------------------------------------------
		    IF( is_new_adjusted_trx ) THEN

			debug( '  new adjusted trx', MSG_LEVEL_DEBUG );

                        ---------------------------------------------------
			-- Start loading ps tables for new adjusted trx
                        ---------------------------------------------------
			l_load_ps_tables := TRUE;

		    END IF;

		    IF( l_old_adjusted_trx_id IS NOT NULL ) THEN

			debug( '  process1', MSG_LEVEL_DEBUG );

			process_ups_data(
				system_info,
				profile_info,
				ups_insert_adj_c,
				ups_update_ps_c,
				l_select_rec,
				l_table_index,
				l_ps_id_t,
				l_ps_amount_due_rem_t,
				l_ps_acctd_amt_due_rem_t,
				l_ps_line_rem_t,
				l_ps_amount_adjusted_t,
				l_adj_amount_t,
				l_acctd_adj_amount_t,
				l_percent_t,
                                l_ps_tax_rem_t,
                                l_ps_freight_rem_t,
                                l_line_adj_t,
                                l_tax_adj_t,
                                l_frt_adj_t);

		    END IF;

                    -----------------------------------------------
		    -- Check if new adjusted trx
                    -----------------------------------------------
		    IF( is_new_adjusted_trx ) THEN

			clear_all_tables;

			l_old_adjusted_trx_id := l_adjusted_trx_id;
			l_old_trx_id := l_customer_trx_id;

                    -----------------------------------------------
		    -- Else new invoice
                    -----------------------------------------------
		    ELSE

			clear_inv_tables;

			l_load_ps_tables := FALSE;
			l_old_trx_id := l_customer_trx_id;

		    END IF;

		END IF;		-- END adjusted trx or inv changed

		get_ups_column_values( ups_select_c, l_select_rec );
		dump_ups_select_rec( l_select_rec );


		IF( l_load_ps_tables ) THEN
		    load_tables( l_select_rec );
		END IF;

		-- >> dump tables

            ELSE
                -----------------------------------------------
		-- No more rows to fetch, process last set
                -----------------------------------------------

		debug( '  process2', MSG_LEVEL_DEBUG );

		process_ups_data(
			system_info,
			profile_info,
			ups_insert_adj_c,
			ups_update_ps_c,
			l_select_rec,
			l_table_index,
			l_ps_id_t,
			l_ps_amount_due_rem_t,
			l_ps_acctd_amt_due_rem_t,
			l_ps_line_rem_t,
			l_ps_amount_adjusted_t,
			l_adj_amount_t,
			l_acctd_adj_amount_t,
			l_percent_t,
                        l_ps_tax_rem_t,
                        l_ps_freight_rem_t,
                        l_line_adj_t,
                        l_tax_adj_t,
                        l_frt_adj_t);


                EXIT;

            END IF;


        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error fetching select cursor',
                   MSG_LEVEL_BASIC );
            RAISE;

    END;

    print_fcn_label( 'arp_maintain_ps2.insert_child_adj_private()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.insert_child_adj_private()',
	       MSG_LEVEL_BASIC );
        RAISE;

END insert_child_adj_private;

----------------------------------------------------------------------------
/* Bug 4642526 - new wrapper for insert_child_adj_private */
PROCEDURE insert_child_adj_private(p_customer_trx_id 	IN BINARY_INTEGER,
                           p_adj_date           IN DATE DEFAULT NULL,
                           p_gl_date            IN DATE DEFAULT NULL )
IS
   x_system_info arp_trx_global.system_info_rec_type;
   x_profile_info arp_trx_global.profile_rec_type;
BEGIN

    insert_child_adj_private(x_system_info, x_profile_info,
          p_customer_trx_id, p_adj_date, p_gl_date);

END;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  build_iad_sql
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--        system_info
--        profile_info
--
--      IN/OUT:
--        select_c
--        insert_ps_c
--	  insert_ra_c
--	  update_ps_c
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE build_iad_sql(
	p_system_info 		IN arp_trx_global.system_info_rec_type,
        p_profile_info 		IN arp_trx_global.profile_rec_type,
        p_select_c 		IN OUT NOCOPY INTEGER,
	p_insert_adj_c 		IN OUT NOCOPY INTEGER,
        p_update_ps_c 		IN OUT NOCOPY INTEGER ) IS

    l_insert_adj_sql	VARCHAR2(2000);
    l_update_ps_sql	VARCHAR2(2000);
    l_select_sql	VARCHAR2(8000);


BEGIN

    print_fcn_label( 'arp_maintain_ps2.build_iad_sql()+' );

    ------------------------------------------------
    -- Select sql
    ------------------------------------------------
    l_select_sql :=
'SELECT
ctl.set_of_books_id,
ct.trx_date,
/* nvl(ps.amount_line_items_remaining, 0), */
nvl(ctlgd.gl_date, ct.trx_date),
ctlgd_com.code_combination_id,
decode(ctt_com.type,
       ''DEP'', ct_inv.customer_trx_id,
       ct_com.customer_trx_id),
ps.payment_schedule_id,
ctl.customer_trx_id,
''Y'', /* bugfix 2614759. ctt.post_to_gl */
greatest(nvl(max(decode(ra.confirmed_flag,
                                ''Y'', ra.apply_date,
                                null, decode(ra.receivable_application_id,
                                             null, ct.trx_date,
                                             ra.apply_date),
				ct.trx_date)),
		     ct.trx_date),
                 nvl(max(decode(adj.status,
				''A'',adj.apply_date,
			ct.trx_date)),
		     ct.trx_date),
                 ct.trx_date),
greatest(nvl(max(decode(ra.confirmed_flag,
				''Y'', ra.gl_date,
                                null, decode(ra.receivable_application_id,
					     null, nvl(ctlgd.gl_date,
					               ct.trx_date),
                                             ra.gl_date),
				nvl(ctlgd.gl_date, ct.trx_date))),
		     nvl(ctlgd.gl_date,ct.trx_date)),
                 nvl(max(decode(adj.status,
				''A'',adj.gl_date,
				nvl(ctlgd.gl_date,
				    ct.trx_date))),
		     nvl(ctlgd.gl_date,ct.trx_date)),
                 nvl(ctlgd.gl_date, ct.trx_date)),
c.minimum_accountable_unit,
c.precision,
sum(ctl.extended_amount) /
  (count(distinct ps.payment_schedule_id) *
   count(distinct ps_inv.payment_schedule_id) *
   count(distinct nvl(adj.adjustment_id, -9.9)) *
   count(distinct nvl(adjd.adjustment_id, -9.9)) *
   count(distinct nvl(ra.receivable_application_id, -9.9))),
nvl(sum(decode(adj.adjustment_type, ''C'', adj.amount, 0)),0) /
  (count(distinct ps.payment_schedule_id) *
   count(distinct ps_inv.payment_schedule_id) *
   count(distinct ctl.customer_trx_line_id) *
   count(distinct nvl(ra.receivable_application_id, -9.9))),
decode(ctt_com.type, ''DEP'', 1, 0),
/* nvl(ps.amount_line_items_remaining, 0), */
/* 0, */
ct_inv.customer_trx_id,
/* null, */
nvl(ps.amount_line_items_remaining, 0),
ps.amount_due_remaining,
ps.acctd_amount_due_remaining,
nvl(ps.amount_adjusted, 0),
c_ps.precision,
c_ps.minimum_accountable_unit,
decode(ctt_com.type, ''DEP'', ct_inv.exchange_rate, ct_com.exchange_rate),
sum(nvl(ps_inv.amount_line_items_remaining, 0))/
  (count(distinct ps.payment_schedule_id) *
   count(distinct ctl.customer_trx_line_id) *
   count(distinct nvl(adj.adjustment_id, -9.9)) *
   count(distinct nvl(ra.receivable_application_id, -9.9)) ),
nvl(ps.amount_line_items_original, 0),
/* 0 */
decode(ctt_com.type,
       ''DEP'', ct_inv.invoice_currency_code,
       ct_com.invoice_currency_code),
/* 1483656 */
ctt_com.allocate_tax_freight,
/* adj_type */
DECODE(ctt_com.allocate_tax_freight, ''Y'', ''INVOICE'', ''LINE''),
/* CM TAX and CM FREIGHT totals */
ARPT_SQL_FUNC_UTIL.get_sum_of_trx_lines(ctl.customer_trx_id, ''TAX''),
ARPT_SQL_FUNC_UTIL.get_sum_of_trx_lines(ctl.customer_trx_id, ''FREIGHT''),
/* inv_line_adj, inv_tax_adj, inv_frt_adj */
sum(nvl(decode(adjd.adjustment_type, ''C'', adjd.line_adjusted, 0),0)) /
  (count(distinct ps.payment_schedule_id) *
   count(distinct ps_inv.payment_schedule_id) *
   count(distinct ctl.customer_trx_line_id) *
   count(distinct adj.adjustment_id) *
   count(distinct nvl(ra.receivable_application_id, -9.9))),
sum(nvl(decode(adjd.adjustment_type, ''C'', adjd.tax_adjusted, 0),0)) /
  (count(distinct ps.payment_schedule_id) *
   count(distinct ps_inv.payment_schedule_id) *
   count(distinct ctl.customer_trx_line_id) *
   count(distinct adj.adjustment_id) *
   count(distinct nvl(ra.receivable_application_id, -9.9))),
sum(nvl(decode(adjd.adjustment_type, ''C'', adjd.freight_adjusted, 0),0)) /
  (count(distinct ps.payment_schedule_id) *
   count(distinct ps_inv.payment_schedule_id) *
   count(distinct ctl.customer_trx_line_id) *
   count(distinct adj.adjustment_id) *
   count(distinct nvl(ra.receivable_application_id, -9.9))),
NVL(ps.tax_remaining, 0),
NVL(ps.freight_remaining, 0),
NVL(ps.tax_original, 0),
NVL(ps.freight_original, 0)
FROM
ra_cust_trx_types ctt_com,
ra_cust_trx_types ctt,
ra_cust_trx_line_gl_dist ctlgd_com,
ar_payment_schedules ps,
ar_payment_schedules ps_inv,
ar_receivable_applications ra,
ar_adjustments adj,
ar_adjustments adjd,
fnd_currencies c,
fnd_currencies c_ps,
ra_customer_trx ct_com,
ra_customer_trx ct_inv,
ra_customer_trx_lines ctl,
ra_customer_trx ct,
ra_cust_trx_line_gl_dist ctlgd
WHERE ct.customer_trx_id = :customer_trx_id
and   ctl.customer_trx_id = ct.customer_trx_id
and   ctlgd.customer_trx_id = ct.customer_trx_id
and   ctlgd.account_class = ''REC''
and   ctlgd.latest_rec_flag = ''Y''
and   ctl.line_type = ''LINE''
and   exists
     (select ''x''
      from   ra_customer_trx h
      where  h.customer_trx_id = ctl.customer_trx_id)
and   ct.invoice_currency_code = c.currency_code
and   ct.cust_trx_type_id = ctt.cust_trx_type_id
and   ctt.type = ''CM''
and   ctl.previous_customer_trx_id = ct_inv.customer_trx_id
and   ct_inv.initial_customer_trx_id = ct_com.customer_trx_id
and   ct_com.cust_trx_type_id = ctt_com.cust_trx_type_id
and   ct_com.customer_trx_id = ctlgd_com.customer_trx_id
and   ctlgd_com.account_class = ''REV''
and   ps.customer_trx_id =
        decode(ctt_com.type,
               ''DEP'', ct_inv.customer_trx_id,
               ct_com.customer_trx_id)
and   decode(ctt_com.type, ''DEP'', ct_inv.invoice_currency_code,
                                ct_com.invoice_currency_code)
        = c_ps.currency_code
and   ps.customer_trx_id = ra.applied_customer_trx_id (+)
and   ps.customer_trx_id = adj.customer_trx_id (+)
and   ct_inv.customer_trx_id = ps_inv.customer_trx_id
and   decode(adj.subsequent_trx_id, null, ct_inv.customer_trx_id,
             adj.subsequent_trx_id) = ct_inv.customer_trx_id
and   ps.payment_schedule_id = adjd.payment_schedule_id (+)
and   adjd.adjustment_type (+) = ''C''
and   decode(ctt_com.type,''GUAR'', adjd.subsequent_trx_id,1)
   =  decode(ctt_com.type,''GUAR'',ctl.previous_customer_trx_id,1)
GROUP BY
ctl.set_of_books_id,
ctt_com.type,
ctt_com.allocate_tax_freight,
ctlgd.gl_date,
ct.trx_date,
ps.amount_line_items_remaining,
ctlgd_com.code_combination_id,
ct_inv.customer_trx_id,
ct_com.customer_trx_id,
ps.payment_schedule_id,
ctl.customer_trx_id,
/* Bugfix 2614759. comment out ctt.post_to_gl, */
c.minimum_accountable_unit,
c.precision,
ps.amount_due_remaining,
ps.amount_due_original,
ps.acctd_amount_due_remaining,
ps.amount_adjusted,
ps.tax_original,
ps.tax_remaining,
ps.freight_original,
ps.freight_remaining,
c_ps.precision,
c_ps.minimum_accountable_unit,
ct_inv.exchange_rate,
ct_com.exchange_rate,
ps.terms_sequence_number,
ps.amount_line_items_original,
ct_inv.invoice_currency_code,
ct_com.invoice_currency_code
ORDER BY
5 asc,  /* adjusted_trx_id */
ct_inv.customer_trx_id,
ctl.customer_trx_id,
ps.terms_sequence_number';



    debug('  select_sql = ' || CRLF ||
          l_select_sql || CRLF,
          MSG_LEVEL_DEBUG);
    debug('  len(select_sql) = '||
          to_char(length(l_select_sql)) || CRLF,
          MSG_LEVEL_DEBUG);


    ------------------------------------------------
    -- Insert adj sql
    ------------------------------------------------
    --Bug 1544809 - Modified the string to include bind variable
    --adjustment_id instead of directly taking the value from
    --sequence. Bind variable :adjustment_id is expected while
    --assigning the bind variable

    l_insert_adj_sql :=
'INSERT INTO AR_ADJUSTMENTS
(
created_by,
creation_date,
last_updated_by,
last_update_date,
last_update_login,
request_id,
program_application_id,
program_id,
program_update_date,
set_of_books_id,
receivables_trx_id,
automatically_generated,
type,
adjustment_type,
status,
apply_date,
adjustment_id,
gl_date,
code_combination_id,
customer_trx_id,
payment_schedule_id,
subsequent_trx_id,
postable,
adjustment_number,
created_from,
posting_control_id,
amount,
acctd_amount,
line_adjusted,
tax_adjusted,
freight_adjusted
,org_id
)
VALUES
(
:user_id,
sysdate,
:user_id,
sysdate,
:login_id,
:request_id,
:application_id,
:program_id,
sysdate,
:set_of_books_id,
-1,
''Y'',
:adj_type,
''C'',
''A'',
:trx_date,
:adjustment_id,
:gl_date,
:code_combination_id,
:adjusted_trx_id,
:payment_schedule_id,
:subsequent_trx_id,
:post_to_gl_flag,
to_char(ar_adjustment_number_s.nextval),
''RAXTRX'',
-3,
-1 * :adj_amount,
-1 * :acctd_adj_amount,
-1 * :line_adjusted,
-1 * :tax_adjusted,
-1 * :freight_adjusted
,:org_id --arp_standard.sysparm.org_id /* SSA changes anuj */
)';

    debug('  insert_adj_sql = ' || CRLF ||
          l_insert_adj_sql || CRLF,
          MSG_LEVEL_DEBUG);
    debug('  len(insert_adj_sql) = '||
          to_char(length(l_insert_adj_sql)) || CRLF,
          MSG_LEVEL_DEBUG);


    ------------------------------------------------
    -- Update ps sql
    ------------------------------------------------
 -- Modified the update statement to incorporate the hard-coded date if the transaction is open - For Bug:5491085
    l_update_ps_sql :=
'UPDATE AR_PAYMENT_SCHEDULES
SET    last_update_date = sysdate,
       last_updated_by = :user_id,
       last_update_login = :login_id,
       status = decode(:amount_due_remaining, 0, ''CL'', ''OP''),
       gl_date_closed =
               decode(:amount_due_remaining, 0, :gl_date_closed,TO_DATE(''31-12-4712'',''DD-MM-YYYY'')),
       actual_date_closed =
               decode(:amount_due_remaining, 0, :actual_date_closed,TO_DATE(''31-12-4712'',''DD-MM-YYYY'')),
       amount_due_remaining = :amount_due_remaining,
       acctd_amount_due_remaining = :acctd_amount_due_remaining,
       amount_line_items_remaining = :amount_line_items_remaining,
       amount_adjusted = :amount_adjusted,
       tax_remaining = :tax_remaining,
       freight_remaining = :freight_remaining
WHERE payment_schedule_id = :payment_schedule_id';

    debug('  update_ps_sql = ' || CRLF ||
          l_update_ps_sql || CRLF,
          MSG_LEVEL_DEBUG);
    debug('  len(update_ps_sql) = '||
          to_char(length(l_update_ps_sql)) || CRLF,
          MSG_LEVEL_DEBUG);




    ------------------------------------------------
    -- Parse sql stmts
    ------------------------------------------------
    BEGIN
	debug( '  Parsing stmts', MSG_LEVEL_DEBUG );

	debug( '  Parsing insert_adj_c', MSG_LEVEL_DEBUG );
        p_insert_adj_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_insert_adj_c, l_insert_adj_sql,
                        dbms_sql.v7 );

	debug( '  Parsing update_ps_c', MSG_LEVEL_DEBUG );
        p_update_ps_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_update_ps_c, l_update_ps_sql,
                        dbms_sql.v7 );

	debug( '  Parsing select_c', MSG_LEVEL_DEBUG );
        p_select_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_select_c, l_select_sql,
                        dbms_sql.v7 );

    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error parsing stmts', MSG_LEVEL_BASIC );
          RAISE;
    END;

    print_fcn_label( 'arp_maintain_ps2.build_iad_sql()-' );


EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.build_iad_sql()',
	       MSG_LEVEL_BASIC );

        RAISE;
END build_iad_sql;


----------------------------------------------------------------------------
PROCEDURE define_iad_select_columns(
	p_select_c   IN INTEGER,
        p_select_rec IN select_iad_rec_type ) IS

BEGIN

    print_fcn_label2( 'arp_maintain_ps2.define_iad_select_columns()+' );

    dbms_sql.define_column( p_select_c, 1, p_select_rec.set_of_books_id );
    dbms_sql.define_column( p_select_c, 2, p_select_rec.trx_date );
    dbms_sql.define_column( p_select_c, 3, p_select_rec.gl_date );
    dbms_sql.define_column( p_select_c, 4, p_select_rec.code_combination_id );
    dbms_sql.define_column( p_select_c, 5, p_select_rec.adjusted_trx_id );
    dbms_sql.define_column( p_select_c, 6, p_select_rec.payment_schedule_id );
    dbms_sql.define_column( p_select_c, 7, p_select_rec.customer_trx_id );
    dbms_sql.define_column( p_select_c, 8,
			    p_select_rec.post_to_gl_flag, 1 );
    dbms_sql.define_column( p_select_c, 9, p_select_rec.actual_date_closed );
    dbms_sql.define_column( p_select_c, 10, p_select_rec.gl_date_closed );
    dbms_sql.define_column( p_select_c, 11, p_select_rec.min_acc_unit );
    dbms_sql.define_column( p_select_c, 12, p_select_rec.precision );
    dbms_sql.define_column( p_select_c, 13,
				p_select_rec.total_cm_line_amount );
    dbms_sql.define_column( p_select_c, 14,
				p_select_rec.total_inv_adj_amount );
    dbms_sql.define_column( p_select_c, 15, p_select_rec.commitment_code );
    dbms_sql.define_column( p_select_c, 16, p_select_rec.invoice_trx_id );
    dbms_sql.define_column( p_select_c, 17, p_select_rec.ps_line_remaining );
    dbms_sql.define_column( p_select_c, 18,
				p_select_rec.ps_amount_due_remaining );
    dbms_sql.define_column( p_select_c, 19,
				p_select_rec.ps_acctd_amt_due_rem );
    dbms_sql.define_column( p_select_c, 20,
				p_select_rec.ps_amount_adjusted );
    dbms_sql.define_column( p_select_c, 21, p_select_rec.ps_precision );
    dbms_sql.define_column( p_select_c, 22, p_select_rec.ps_min_acc_unit );
    dbms_sql.define_column( p_select_c, 23, p_select_rec.ps_exchange_rate );
    dbms_sql.define_column( p_select_c, 24,
				p_select_rec.total_inv_line_remaining );
    dbms_sql.define_column( p_select_c, 25, p_select_rec.ps_line_original );
    dbms_sql.define_column( p_select_c, 26,
				p_select_rec.ps_currency_code, 15 );
    dbms_sql.define_column( p_select_c, 27, p_select_rec.allocate_tax_freight, 1);
    dbms_sql.define_column( p_select_c, 28, p_select_rec.adjustment_type, 8);
    dbms_sql.define_column( p_select_c, 29, p_select_rec.total_cm_tax_amount);
    dbms_sql.define_column( p_select_c, 30, p_select_rec.total_cm_frt_amount);
    dbms_sql.define_column( p_select_c, 31, p_select_rec.inv_line_adj);
    dbms_sql.define_column( p_select_c, 32, p_select_rec.inv_tax_adj);
    dbms_sql.define_column( p_select_c, 33, p_select_rec.inv_frt_adj);
    dbms_sql.define_column( p_select_c, 34, p_select_rec.ps_tax_remaining);
    dbms_sql.define_column( p_select_c, 35, p_select_rec.ps_freight_remaining);
    dbms_sql.define_column( p_select_c, 36, p_select_rec.ps_tax_original);
    dbms_sql.define_column( p_select_c, 37, p_select_rec.ps_freight_remaining);

    print_fcn_label2( 'arp_maintain_ps2.define_iad_select_columns()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_maintain_ps2.define_iad_select_columns()',
	      MSG_LEVEL_BASIC);
        RAISE;
END define_iad_select_columns;


----------------------------------------------------------------------------
PROCEDURE get_iad_column_values( p_select_c   IN INTEGER,
                             p_select_rec IN OUT NOCOPY select_iad_rec_type ) IS
/* Bug 460927 - Changed IN to IN OUT in the above line - Oracle 8 */
BEGIN
    print_fcn_label2( 'arp_maintain_ps2.get_iad_column_values()+' );

    dbms_sql.column_value( p_select_c, 1, p_select_rec.set_of_books_id );
    dbms_sql.column_value( p_select_c, 2, p_select_rec.trx_date );
    dbms_sql.column_value( p_select_c, 3, p_select_rec.gl_date );
    dbms_sql.column_value( p_select_c, 4, p_select_rec.code_combination_id );
    dbms_sql.column_value( p_select_c, 5, p_select_rec.adjusted_trx_id );
    dbms_sql.column_value( p_select_c, 6, p_select_rec.payment_schedule_id );
    dbms_sql.column_value( p_select_c, 7, p_select_rec.customer_trx_id );
    dbms_sql.column_value( p_select_c, 8, p_select_rec.post_to_gl_flag );
    dbms_sql.column_value( p_select_c, 9, p_select_rec.actual_date_closed );
    dbms_sql.column_value( p_select_c, 10, p_select_rec.gl_date_closed );
    dbms_sql.column_value( p_select_c, 11, p_select_rec.min_acc_unit );
    dbms_sql.column_value( p_select_c, 12, p_select_rec.precision );
    dbms_sql.column_value( p_select_c, 13, p_select_rec.total_cm_line_amount );
    dbms_sql.column_value( p_select_c, 14, p_select_rec.total_inv_adj_amount );
    dbms_sql.column_value( p_select_c, 15, p_select_rec.commitment_code );
    dbms_sql.column_value( p_select_c, 16, p_select_rec.invoice_trx_id );
    dbms_sql.column_value( p_select_c, 17, p_select_rec.ps_line_remaining );
    dbms_sql.column_value( p_select_c, 18,
				p_select_rec.ps_amount_due_remaining );
    dbms_sql.column_value( p_select_c, 19,
				p_select_rec.ps_acctd_amt_due_rem );
    dbms_sql.column_value( p_select_c, 20,
				p_select_rec.ps_amount_adjusted );
    dbms_sql.column_value( p_select_c, 21, p_select_rec.ps_precision );
    dbms_sql.column_value( p_select_c, 22, p_select_rec.ps_min_acc_unit );
    dbms_sql.column_value( p_select_c, 23, p_select_rec.ps_exchange_rate );
    dbms_sql.column_value( p_select_c, 24,
				p_select_rec.total_inv_line_remaining );
    dbms_sql.column_value( p_select_c, 25, p_select_rec.ps_line_original );
    dbms_sql.column_value( p_select_c, 26, p_select_rec.ps_currency_code );
    dbms_sql.column_value( p_select_c, 27, p_select_rec.allocate_tax_freight);
    dbms_sql.column_value( p_select_c, 28, p_select_rec.adjustment_type);
    dbms_sql.column_value( p_select_c, 29, p_select_rec.total_cm_tax_amount);
    dbms_sql.column_value( p_select_c, 30, p_select_rec.total_cm_frt_amount);
    dbms_sql.column_value( p_select_c, 31, p_select_rec.inv_line_adj);
    dbms_sql.column_value( p_select_c, 32, p_select_rec.inv_tax_adj);
    dbms_sql.column_value( p_select_c, 33, p_select_rec.inv_frt_adj);
    dbms_sql.column_value( p_select_c, 34, p_select_rec.ps_tax_remaining);
    dbms_sql.column_value( p_select_c, 35, p_select_rec.ps_freight_remaining);
    dbms_sql.column_value( p_select_c, 36, p_select_rec.ps_tax_original);
    dbms_sql.column_value( p_select_c, 37, p_select_rec.ps_freight_original);

    print_fcn_label2( 'arp_maintain_ps2.get_iad_column_values()-' );
EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_maintain_ps2.get_iad_column_values()',
		MSG_LEVEL_BASIC);
        RAISE;
END get_iad_column_values;


----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  dump_iad_select_rec
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--        select_rec
--
--      IN/OUT:
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE dump_iad_select_rec( p_select_rec IN select_iad_rec_type ) IS
BEGIN

    print_fcn_label2( 'arp_maintain_ps2.dump_iad_select_rec()+' );

    debug( '  Dumping select record: ', MSG_LEVEL_DEBUG );
    debug( '  set_of_books_id='
           || p_select_rec.set_of_books_id, MSG_LEVEL_DEBUG );
    debug( '  customer_trx_id ='
           || p_select_rec.customer_trx_id , MSG_LEVEL_DEBUG );
    debug( '  post_to_gl_flag='
           || p_select_rec.post_to_gl_flag, MSG_LEVEL_DEBUG );
    debug( '  trx_date='
           || p_select_rec.trx_date, MSG_LEVEL_DEBUG );
    debug( '  gl_date='
           || p_select_rec.gl_date, MSG_LEVEL_DEBUG );
    debug( '  precision='
           || p_select_rec.precision, MSG_LEVEL_DEBUG );
    debug( '  min_acc_unit='
           || p_select_rec.min_acc_unit, MSG_LEVEL_DEBUG );
    debug( '  adjusted_trx_id='
           || p_select_rec.adjusted_trx_id, MSG_LEVEL_DEBUG );
    debug( '  invoice_trx_id='
           || p_select_rec.invoice_trx_id, MSG_LEVEL_DEBUG );
    debug( '  ps_currency_code='
           || p_select_rec.ps_currency_code, MSG_LEVEL_DEBUG );
    debug( '  ps_exchange_rate='
           || p_select_rec.ps_exchange_rate, MSG_LEVEL_DEBUG );
    debug( '  ps_precision='
           || p_select_rec.ps_precision, MSG_LEVEL_DEBUG );
    debug( '  ps_min_acc_unit='
           || p_select_rec.ps_min_acc_unit, MSG_LEVEL_DEBUG );
    debug( '  commitment_code='
           || p_select_rec.commitment_code, MSG_LEVEL_DEBUG );
    debug( '  code_combination_id='
           || p_select_rec.code_combination_id, MSG_LEVEL_DEBUG );
    debug( '  gl_date_closed='
           || p_select_rec.gl_date_closed, MSG_LEVEL_DEBUG );
    debug( '  actual_date_closed='
           || p_select_rec.actual_date_closed, MSG_LEVEL_DEBUG );
    debug( '  total_cm_line_amount='
           || p_select_rec.total_cm_line_amount, MSG_LEVEL_DEBUG );
    debug( '  total_inv_adj_amount='
           || p_select_rec.total_inv_adj_amount, MSG_LEVEL_DEBUG );
    debug( '  total_inv_line_remaining='
           || p_select_rec.total_inv_line_remaining, MSG_LEVEL_DEBUG );
    debug( '  payment_schedule_id='
           || p_select_rec.payment_schedule_id, MSG_LEVEL_DEBUG );
    debug( '  ps_amount_due_remaining='
           || p_select_rec.ps_amount_due_remaining, MSG_LEVEL_DEBUG );
    debug( '  ps_acctd_amt_due_rem='
           || p_select_rec.ps_acctd_amt_due_rem, MSG_LEVEL_DEBUG );
    debug( '  ps_line_original='
           || p_select_rec.ps_line_original, MSG_LEVEL_DEBUG );
    debug( '  ps_line_remaining	='
           || p_select_rec.ps_line_remaining, MSG_LEVEL_DEBUG );
    debug( '  ps_amount_adjusted='
           || p_select_rec.ps_amount_adjusted, MSG_LEVEL_DEBUG );
    /* 1483656 */
    debug( '  allocate_tax_freight='
           || p_select_rec.allocate_tax_freight, MSG_LEVEL_DEBUG);


    print_fcn_label2( 'arp_maintain_ps2.dump_iad_select_rec()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.dump_iad_select_rec()',
               MSG_LEVEL_BASIC );
        RAISE;
END dump_iad_select_rec;


------------------------------------------------------------------------

PROCEDURE process_iad_data(
	p_system_info		IN arp_trx_global.system_info_rec_type,
	p_profile_info 		IN arp_trx_global.profile_rec_type,
        p_insert_adj_c			IN INTEGER,
        p_update_ps_c			IN INTEGER,
	p_select_rec			IN select_iad_rec_type,
        p_number_records		IN NUMBER,
        p_ps_id_t			IN id_table_type,
        p_ps_amount_due_rem_t 		IN OUT NOCOPY number_table_type,
        p_ps_acctd_amt_due_rem_t	IN OUT NOCOPY number_table_type,
        p_ps_line_orig_t 		IN number_table_type,
        p_ps_line_rem_t 		IN OUT NOCOPY number_table_type,
        p_ps_amount_adjusted_t 		IN OUT NOCOPY number_table_type,
        p_adj_amount_t 			IN OUT NOCOPY number_table_type,
        p_acctd_adj_amount_t 		IN OUT NOCOPY number_table_type,
	p_eff_adj_line_total            IN OUT NOCOPY NUMBER,
        p_eff_adj_tax_total             IN OUT NOCOPY NUMBER,
        p_eff_adj_frt_total             IN OUT NOCOPY NUMBER,
        p_eff_line_bal                  IN OUT NOCOPY NUMBER,
        p_eff_tax_bal                   IN OUT NOCOPY NUMBER,
        p_eff_frt_bal                   IN OUT NOCOPY NUMBER,
        p_line_adj_t                    IN OUT NOCOPY number_table_type,
        p_tax_adj_t                     IN OUT NOCOPY number_table_type,
        p_frt_adj_t                     IN OUT NOCOPY number_table_type,
        p_ps_tax_orig_t                 IN OUT NOCOPY number_table_type,
        p_ps_tax_rem_t                  IN OUT NOCOPY number_table_type,
        p_ps_frt_orig_t                 IN OUT NOCOPY number_table_type,
        p_ps_frt_rem_t                  IN OUT NOCOPY number_table_type,
        p_inv_line_adj_t                IN OUT NOCOPY number_table_type,
        p_inv_tax_adj_t                 IN OUT NOCOPY number_table_type,
        p_inv_frt_adj_t                 IN OUT NOCOPY number_table_type,
        p_is_new_adj_trx                IN     boolean
) IS

    l_ignore 			INTEGER;

    l_new_ps_adr		NUMBER;
    l_new_ps_acctd_adr		NUMBER;
    l_new_acctd_adj_amount	NUMBER;

    l_total_ps_orig             NUMBER :=0;
    l_total_ps_rem              NUMBER :=0;

    l_total_ps_line_rem		NUMBER :=0;
    l_total_ps_tax_rem          NUMBER :=0;
    l_total_ps_frt_rem          NUMBER :=0;

    l_total_line_adj            NUMBER :=0;
    l_total_frt_adj             NUMBER :=0;
    l_total_tax_adj             NUMBER :=0;

    l_amount			NUMBER;
    l_reversal_adj 		NUMBER;
    l_percent_t			number_table_type;

    /* VAT changes */
    l_ae_doc_rec                ae_doc_rec_type;
    l_adjustment_id             ar_adjustments.adjustment_id%type;

    /* Bug 3570404 - Guarantees */
    l_max_curr_adj              NUMBER;
    l_bal_sign                  NUMBER;
    l_cm_adjustment_total       NUMBER;


    PROCEDURE reverse_adjustments( p_rows NUMBER,
                                   p_new_adj IN OUT NOCOPY number_table_type,
                                   p_orig_adj IN OUT NOCOPY number_table_type ) IS
    BEGIN
       -- This procedure populates an adjustments
       -- table with the amount of the original
       -- adjustment.  The insert statement uses
       --   -1 * this amount

       FOR i IN 0..p_rows -1 LOOP

          IF p_orig_adj(i) is not null THEN
             p_new_adj(i) := p_orig_adj(i);
          ELSE
             p_new_adj(i) := NULL;
          END IF;

          DEBUG('      Term: ' || i || ' Amount = ' || p_new_adj(i),
                             MSG_LEVEL_DEBUG);

       END LOOP;

    END reverse_adjustments;

BEGIN
    print_fcn_label2('arp_maintain_ps2.process_iad_data()+' );

    /* MODULE FLOW (post 1483656 - TAX/FREIGHT modification)

    1. LOOP to accumulate total PS remaining, total PS original,
       and total INV adj amounts
    2. If new transaction (INV or GUAR), set effective adj amounts
    3. If total PS remaining <> 0, compute percentages
       a. LOOP and compute percentages based on amounts remaining
    4. ELSE (PS remaining = 0)
       a. LOOP and compute percentages based on amounts original
    5. IF COMMITMENT is GUARANTEE
       a. retrieve accumulated credits
       b. calculate amount to be adjusted
          (amount credit vs. amount adj vs. commitment balance)
       b. DISTRIBUTE amount across terms
    6. ELSE (COMMITMENT IS DEPOSIT)
       a. LINE
          i.  CALCULATE adj total for lines
          ii. IF it >= current amount adjusted, REVERSE existing adj
          iii.ELSE DISTRIBUTE amount across terms
       b. IF ra_cust_trx_types.allocate_tax_freight = 'Y'
          i.  TAX
              A.  CALCULATE adj total for tax
              B.  If adj >= current amount adjusted, REVERSE existing adj
              C.  ELSE DISTRIBUTE amount across terms
          ii. FREIGHT
              A.  CALCULATE adj total for freight
              B.  If adj >= current amount adjusted, REVERSE existing adj
              C.  ELSE DISTRIBUTE amount across terms
    7. LOOP
       a. Figure total adjusted as sum of line, tax, and freight adj
       b. Calculate acctd_amount fields
       c. Calculate amount_due_remaining fields
       d. INSERT adjustments
       e. UPDATE payment schedules
       f. INSERT distributions
    */

    --------------------------------------------------------------------
    -- Get total line orig/rem for adjusted ps
    --------------------------------------------------------------------
    FOR i IN 0..p_number_records - 1 LOOP
        l_total_ps_line_rem := l_total_ps_line_rem + p_ps_line_rem_t( i );
        l_total_ps_tax_rem := l_total_ps_tax_rem + p_ps_tax_rem_t( i );
        l_total_ps_frt_rem := l_total_ps_frt_rem + p_ps_frt_rem_t( i );

        l_total_ps_orig := l_total_ps_orig + p_ps_line_orig_t( i );
        l_total_ps_rem  := l_total_ps_rem  + p_ps_line_rem_t( i );

        -- Accumulate total adjustments
        -- (used to determine if we are closing a given term
        --  for deposit invoices)
        l_total_line_adj := l_total_line_adj + p_inv_line_adj_t(i);

       /* 1483656 - include tax and freight where appropriate */
        IF (p_select_rec.allocate_tax_freight = 'Y') THEN

           l_total_ps_orig := l_total_ps_orig + p_ps_tax_orig_t(i) +
                                   p_ps_frt_orig_t(i);
           l_total_ps_rem := l_total_ps_rem + p_ps_tax_rem_t(i) +
                                   p_ps_frt_rem_t(i);

           l_total_tax_adj := l_total_tax_adj + p_inv_tax_adj_t(i);
           l_total_frt_adj := l_total_frt_adj + p_inv_frt_adj_t(i);
        END IF;

    END LOOP;

    -- Set effective adjustment totals (only if this is a new transaction)
    IF (p_is_new_adj_trx) THEN

        DEBUG('    NEW INVOICE - setting eff adj totals', MSG_LEVEL_DEBUG);

        p_eff_adj_line_total := l_total_line_adj;
        p_eff_adj_tax_total := l_total_tax_adj;
        p_eff_adj_frt_total := l_total_frt_adj;

        -- Bug 1859293
        -- override effective balances (also) for new transaction
        -- NOTE:  The sql does not always return these correct, but
        -- my accumulation above has proven more reliable.
        p_eff_line_bal := l_total_ps_line_rem;
        p_eff_tax_bal := l_total_ps_tax_rem;
        p_eff_frt_bal := l_total_ps_frt_rem;

    END IF;

    --------------------------------------------------------------------
    -- Compute percentages
    --------------------------------------------------------------------
    IF( l_total_ps_rem <> 0 ) THEN

        FOR i IN 0..p_number_records - 1 LOOP

            IF (p_select_rec.allocate_tax_freight = 'Y') THEN
                l_percent_t( i ) := (p_ps_line_rem_t( i ) + p_ps_tax_rem_t( i ) +
                                     p_ps_frt_rem_t( i )) / l_total_ps_rem;
            ELSE
                l_percent_t( i ) :=  p_ps_line_rem_t( i ) / l_total_ps_rem;
            END IF;

        END LOOP;

    ELSE

        FOR i IN 0..p_number_records - 1 LOOP

            IF (p_select_rec.allocate_tax_freight = 'Y') THEN
                l_percent_t( i ) := (p_ps_line_orig_t( i ) + p_ps_tax_orig_t( i ) +
                                     p_ps_frt_orig_t( i )) / l_total_ps_orig;
            ELSE
                l_percent_t( i ) :=  p_ps_line_orig_t( i ) / l_total_ps_orig;
            END IF;

        END LOOP;

    END IF;

    --------------------------------------------------------------------
    -- Calculate amount to adjust
    --------------------------------------------------------------------
    debug( '  commitment_code='||p_select_rec.commitment_code,
		MSG_LEVEL_DEBUG );
    debug( '  allocate_tax_freight=' || p_select_rec.allocate_tax_freight,
                MSG_LEVEL_DEBUG );


    IF( p_select_rec.commitment_code = 0 ) THEN

        ----------------------------------------------------------------
	-- GUAR case
        ----------------------------------------------------------------
        debug( '  GUAR case', MSG_LEVEL_DEBUG );
        debug( '  p_eff_adj_line_total='||p_eff_adj_line_total,
        		MSG_LEVEL_DEBUG );
        debug( '  p_eff_line_bal='||p_eff_line_bal,
	         	MSG_LEVEL_DEBUG );
        debug( '  total_inv_line_remaining='||
                  p_select_rec.total_inv_line_remaining,
	         	MSG_LEVEL_DEBUG );
        debug( '  adj_trx_id='||p_select_rec.adjusted_trx_id,
                        MSG_LEVEL_DEBUG );
        debug( '  invoice_trx_id=' || p_select_rec.invoice_trx_id,
                        MSG_LEVEL_DEBUG );

        /* Bug 3570404 - cumulative cms not calculating correctly
            so figure the effect of prior CMs here and now */

           select nvl(sum(adj.line_adjusted),0)
           into   l_cm_adjustment_total
           from   ar_adjustments adj,
                  ra_customer_trx ocm
           where  adj.customer_trx_id = p_select_rec.adjusted_trx_id
           and    adj.subsequent_trx_id = ocm.customer_trx_id
           and    ocm.previous_customer_trx_id = p_select_rec.invoice_trx_id;

        /* set locals for calculations */
        l_max_curr_adj        := p_eff_adj_line_total + l_cm_adjustment_total;
        l_bal_sign            := sign(p_eff_adj_line_total);

        debug(' l_cm_adjustment_total = ' || l_cm_adjustment_total,
                MSG_LEVEL_DEBUG);
        debug(' l_max_curr_adj = ' || l_max_curr_adj,
                MSG_LEVEL_DEBUG);

        /* l_bal_sign is the sign of the adjustment amount currently
           out there against this guarantee for the specified invoice.
           if it is pos(+), then invoice is pos and cm is (usually) neg(-)
           if it is neg(-), then the invoice is neg and cm is pos. */
        IF l_bal_sign = -1
        THEN
            /* This is the NORMAL case, GUAR+, INV+, CM- */
            l_reversal_adj := GREATEST(p_select_rec.total_cm_line_amount,
                                       l_max_curr_adj);
        ELSIF l_bal_sign = 1
        THEN
            /* This is OPPOSITE case, GUAR+, INV-, CM+ */
            l_reversal_adj := LEAST(p_select_rec.total_cm_line_amount,
                                    l_max_curr_adj);
        ELSE
            l_reversal_adj := 0;
        END IF;

        debug(' l_reversal_adj = ' || l_reversal_adj,
                  MSG_LEVEL_DEBUG);

        ----------------------------------------------------------------
	-- Update invoice line balance
        ----------------------------------------------------------------
	p_eff_line_bal := p_eff_line_bal +
					p_select_rec.total_cm_line_amount;

        -- distribute amount across lines (amount_adjusted will be set
        --  later.
        distribute_amount(
	        p_number_records,
	      	p_select_rec.ps_currency_code,
		l_reversal_adj,
		l_percent_t,
		p_line_adj_t );

    ELSIF( p_select_rec.commitment_code = 1 ) THEN

        ----------------------------------------------------------------
	-- DEP case
        -- 1483656 - modified to allocate tax and freight
        ----------------------------------------------------------------
        debug( '  DEP case', MSG_LEVEL_DEBUG );

        ----------------------------------------------------------------
        -- If the amount being credited (for LINE, TAX, or FREIGHT)
        -- will close down the invoice,
        -- Then, make the CM adjustments equal the invoice ones

        -- LINE
        IF (l_total_ps_line_rem +
            p_select_rec.total_cm_line_amount +
           (l_total_line_adj * -1) <= 0)
        THEN
           debug( '  l_total_ps_line_rem        = '||
                 l_total_ps_line_rem, MSG_LEVEL_DEBUG );
           debug( '  p_select_rec.total_cm_line = '||
                 p_select_rec.total_cm_line_amount, MSG_LEVEL_DEBUG );
           debug( '  l_total_inv_adj = '||l_total_line_adj,
                          MSG_LEVEL_DEBUG );


           debug( '  REVERSING LINE', MSG_LEVEL_DEBUG );

           -- reverse remaining LINE adjustments
              reverse_adjustments(p_number_records,
                                  p_line_adj_t,
                                  p_inv_line_adj_t);

           p_eff_line_bal := 0;

        ELSE
        DEBUG('     p_eff_line_bal = ' || p_eff_line_bal,
                      MSG_LEVEL_DEBUG);

        DEBUG('     p_select_rec.total_cm_line_amount = ' ||
                      p_select_rec.total_cm_line_amount,
                      MSG_LEVEL_DEBUG);

        DEBUG('     p_eff_adj_line_total = '||
                      p_eff_adj_line_total,
                      MSG_LEVEL_DEBUG);

           -- figure how much, if any, of the CM amount
           -- gets to be adjusted using logic similar
           -- to the existing logic

           IF( p_eff_line_bal + p_select_rec.total_cm_line_amount < 0 ) THEN

                 l_reversal_adj :=
		     GREATEST( p_eff_adj_line_total,
		   	       p_eff_line_bal +
			       p_select_rec.total_cm_line_amount );
	   ELSE
	         l_reversal_adj := 0;
	   END IF;

           debug( '  DISTRIBUTING LINE', MSG_LEVEL_DEBUG);

              distribute_amount(
	               p_number_records,
	               p_select_rec.ps_currency_code,
		       l_reversal_adj,
		       l_percent_t,
		       p_line_adj_t );

             -- Update invoice line balance
    	     p_eff_line_bal := p_eff_line_bal - l_reversal_adj +
					p_select_rec.total_cm_line_amount;

        END IF;

        -- TAX and FREIGHT
        IF (p_select_rec.allocate_tax_freight = 'Y') THEN

           debug( '   ALLOCATING TAX AND FREIGHT', MSG_LEVEL_DEBUG);

           -- TAX
           debug( '  l_total_ps_tax_rem        = '||l_total_ps_tax_rem,
                              MSG_LEVEL_DEBUG );
           debug( '  p_select_rec.total_cm_tax = '||p_select_rec.total_cm_tax_amount,
                              MSG_LEVEL_DEBUG );
           debug( '  l_total_tax_adj = '||l_total_tax_adj,
                              MSG_LEVEL_DEBUG );

           IF (l_total_ps_tax_rem +
               p_select_rec.total_cm_tax_amount +
              (l_total_tax_adj * -1) <= 0)
           THEN
                debug( '  REVERSING TAX', MSG_LEVEL_DEBUG );

                -- reverse remaining TAX adjustments
                  reverse_adjustments(p_number_records,
                                      p_tax_adj_t,
                                      p_inv_tax_adj_t);
                p_eff_tax_bal := 0;

           ELSE
                debug( '  DISTRIBUTING TAX', MSG_LEVEL_DEBUG );

        DEBUG('     p_eff_tax_bal = ' || p_eff_tax_bal,
                      MSG_LEVEL_DEBUG);

        DEBUG('     p_select_rec.total_cm_tax_amount = ' ||
                      p_select_rec.total_cm_tax_amount,
                      MSG_LEVEL_DEBUG);

        DEBUG('     p_eff_adj_tax_total = '||
                      p_eff_adj_tax_total,
                      MSG_LEVEL_DEBUG);

                IF( p_eff_tax_bal + p_select_rec.total_cm_tax_amount < 0 ) THEN

                     l_reversal_adj :=
	    	         GREATEST( p_eff_adj_tax_total,
		   	           p_eff_tax_bal +
			           p_select_rec.total_cm_tax_amount );
	        ELSE
	             l_reversal_adj := 0;
	        END IF;

                -- calculate and allocate TAX adjustments
                distribute_amount(
   	                    p_number_records,
	                    p_select_rec.ps_currency_code,
		            l_reversal_adj,
		            l_percent_t,
		            p_tax_adj_t );

                -- Update invoice tax balance
	        p_eff_tax_bal := p_eff_tax_bal - l_reversal_adj +
					p_select_rec.total_cm_tax_amount;

           END IF;

           -- FREIGHT
           debug( '  l_total_ps_frt_rem        = '||l_total_ps_frt_rem,
                              MSG_LEVEL_DEBUG );
           debug( '  p_select_rec.total_cm_frt = '||p_select_rec.total_cm_frt_amount,
                              MSG_LEVEL_DEBUG );
           debug( '  l_total_frt_adj = '||l_total_frt_adj,
                              MSG_LEVEL_DEBUG );

           IF (l_total_ps_frt_rem +
               p_select_rec.total_cm_frt_amount +
              (l_total_frt_adj * -1) <= 0 )
           THEN
                debug( '  REVERSING FREIGHT', MSG_LEVEL_DEBUG );

                -- reverse remaining FRT adjustments
                reverse_adjustments(p_number_records,
                                    p_frt_adj_t,
                                    p_inv_frt_adj_t);

                p_eff_frt_bal := 0;

           ELSE
                -- calculate and allocate FRT adjustments

                debug( '  DISTRIBUTING FREIGHT', MSG_LEVEL_DEBUG );

                IF( p_eff_frt_bal + p_select_rec.total_cm_frt_amount < 0 ) THEN

                     l_reversal_adj :=
		         GREATEST( p_eff_adj_frt_total,
		   	           p_eff_frt_bal +
			           p_select_rec.total_cm_frt_amount );
     	        ELSE
	            l_reversal_adj := 0;
	        END IF;

                distribute_amount(
   	                    p_number_records,
	                    p_select_rec.ps_currency_code,
		            l_reversal_adj,
		            l_percent_t,
		            p_frt_adj_t );

                -- Update invoice frt balance
	        p_eff_frt_bal := p_eff_frt_bal - l_reversal_adj +
					p_select_rec.total_cm_frt_amount;

           END IF;

        END IF; -- end ALLOCATE_TAX_FRIEGHT

    ELSE

	debug( '  bad commitment_code',	MSG_LEVEL_DEBUG );
	l_reversal_adj := 0;

    END IF; -- END GUARANTEE/DEPOSIT CASE


    -- Now figure the total adjusted and amounts remaining

    FOR i IN 0..p_number_records - 1 LOOP

        --------------------------------------------------------------------
        -- Figure amount adjusted
        -- Update line_items_rem
        --------------------------------------------------------------------
        p_adj_amount_t( i ) := p_line_adj_t( i );
	p_ps_line_rem_t( i ) := p_ps_line_rem_t( i ) - p_line_adj_t( i );

        IF (p_select_rec.allocate_tax_freight = 'Y') THEN
           p_ps_tax_rem_t( i )  := p_ps_tax_rem_t( i ) - p_tax_adj_t( i );
           p_ps_frt_rem_t( i )  := p_ps_frt_rem_t( i ) - p_frt_adj_t( i );

           -- add tax and freight to adjusted amount
           p_adj_amount_t( i ) := p_adj_amount_t( i ) + p_tax_adj_t( i )
                                                      + p_frt_adj_t( i );
        ELSE
           -- initialize the fields to null for use in the insert
           p_tax_adj_t( i ) := null;
           p_frt_adj_t( i ) := null;

        END IF;

        --------------------------------------------------------------------
        -- Update PS amount_adj
        --------------------------------------------------------------------
	p_ps_amount_adjusted_t( i ) :=
		p_ps_amount_adjusted_t( i ) - p_adj_amount_t( i );

        --------------------------------------------------------------------
    	-- Compute new acctd_adr (aracc)
        --------------------------------------------------------------------
	arp_util.calc_acctd_amount(
		p_system_info.base_currency,
		NULL,			-- precision
		NULL,			-- mau
		p_select_rec.ps_exchange_rate,
		'-',			-- type
		p_ps_amount_due_rem_t( i ),	-- master_from
		p_ps_acctd_amt_due_rem_t( i ),	-- acctd_master_from
		p_adj_amount_t( i ),	-- detail
		l_new_ps_adr,		-- master_to
		l_new_ps_acctd_adr,	-- acctd_master_to
		l_new_acctd_adj_amount	-- acctd_detail
	);

        --------------------------------------------------------------------
	-- Update amt_due_rem, acctd_amt_due_rem
        --------------------------------------------------------------------
	p_ps_amount_due_rem_t( i ) := l_new_ps_adr;
	p_ps_acctd_amt_due_rem_t( i ) := l_new_ps_acctd_adr;
	p_acctd_adj_amount_t( i ) := l_new_acctd_adj_amount;

    END LOOP;


    -------------------------------------------------------------
    -- Insert into ar_adjustments
    -------------------------------------------------------------

    FOR i IN 0..p_number_records - 1 LOOP

        -------------------------------------------------------------
        -- Skip rows with $0 amounts (do not insert $0 adjustments)
        -------------------------------------------------------------
	IF( p_adj_amount_t( i ) = 0 ) THEN
	    GOTO skip;
	END IF;

        -------------------------------------------------------------
        -- Bind vars
        -------------------------------------------------------------
        BEGIN
	    debug( '  Binding insert_adj_c', MSG_LEVEL_DEBUG );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'user_id',
                                    p_profile_info.user_id );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'login_id',
                                    p_profile_info.conc_login_id );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'request_id',
                                    p_profile_info.request_id );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'application_id',
                                    p_profile_info.application_id );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'program_id',
                                    p_profile_info.conc_program_id );


            dbms_sql.bind_variable(
			p_insert_adj_c,
			'set_of_books_id',
                	p_select_rec.set_of_books_id );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'trx_date',
                                    p_select_rec.trx_date );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'gl_date',
                                    p_select_rec.gl_date );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'code_combination_id',
                                    p_select_rec.code_combination_id );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'adjusted_trx_id',
                                    p_select_rec.adjusted_trx_id );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'payment_schedule_id',
                                    p_ps_id_t( i ) );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'subsequent_trx_id',
                                    p_select_rec.customer_trx_id );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'post_to_gl_flag',
                                    p_select_rec.post_to_gl_flag );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'adj_amount',
                                    p_adj_amount_t( i ) );

            dbms_sql.bind_variable( p_insert_adj_c,
		                    'acctd_adj_amount',
                                    p_acctd_adj_amount_t( i ) );

	    /* VAT changes */
            SELECT ar_adjustments_s.nextval
            INTO l_adjustment_id
            FROM   dual;

            dbms_sql.bind_variable( p_insert_adj_c,
                                    'adjustment_id',
                                    l_adjustment_id );

            dbms_sql.bind_variable( p_insert_adj_c,
                                    'adj_type',
                                    p_select_rec.adjustment_type);

            dbms_sql.bind_variable( p_insert_adj_c,
                                    'line_adjusted',
                                    p_line_adj_t(i));

            dbms_sql.bind_variable( p_insert_adj_c,
                                    'tax_adjusted',
                                    p_tax_adj_t(i));

            dbms_sql.bind_variable( p_insert_adj_c,
                                    'freight_adjusted',
                                    p_frt_adj_t(i));
            /* anuj: Corrected typo for SSA retrofit */
            dbms_sql.bind_variable( p_insert_adj_c,
                                    'org_id',
                                    arp_standard.sysparm.org_id);

        EXCEPTION
          WHEN OTHERS THEN
            debug( 'EXCEPTION: Error in binding insert_adj_c',
                   MSG_LEVEL_BASIC );
            RAISE;
        END;

        -------------------------------------------------------------
        -- Execute
        -------------------------------------------------------------
        BEGIN
	    debug( '  Inserting adjustments', MSG_LEVEL_DEBUG );
            l_ignore := dbms_sql.execute( p_insert_adj_c );
            debug( to_char(l_ignore) || ' row(s) inserted',
		           MSG_LEVEL_DEBUG );

           /*-------------------------------------------+
            | Call central MRC library for insertion    |
            | into MRC tables                           |
            +-------------------------------------------*/

           ar_mrc_engine.maintain_mrc_data(
                      p_event_mode       => 'INSERT',
                      p_table_name       => 'AR_ADJUSTMENTS',
                      p_mode             => 'SINGLE',
                      p_key_value        => l_adjustment_id);

        EXCEPTION
          WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing insert ra stmt',
                   MSG_LEVEL_BASIC );
            RAISE;
        END;


    -------------------------------------------------------------
    -- Update ar_payment_schedules
    -------------------------------------------------------------

        -------------------------------------------------------------
        -- Bind vars
        -------------------------------------------------------------
        BEGIN
	    debug( '  Binding update_ps_c', MSG_LEVEL_DEBUG );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'user_id',
                                    p_profile_info.user_id );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'login_id',
                                    p_profile_info.conc_login_id );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'amount_due_remaining',
                                    p_ps_amount_due_rem_t( i ) );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'gl_date_closed',
                                    p_select_rec.gl_date_closed );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'actual_date_closed',
                                    p_select_rec.actual_date_closed );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'amount_line_items_remaining',
                                    p_ps_line_rem_t( i ) );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'amount_adjusted',
                                    p_ps_amount_adjusted_t( i ) );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'acctd_amount_due_remaining',
                                    p_ps_acctd_amt_due_rem_t( i ) );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'payment_schedule_id',
                                    p_ps_id_t( i ) );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'tax_remaining',
                                    p_ps_tax_rem_t( i ) );

            dbms_sql.bind_variable( p_update_ps_c,
		                    'freight_remaining',
                                    p_ps_frt_rem_t( i ) );

        EXCEPTION
          WHEN OTHERS THEN
            debug( 'EXCEPTION: Error in binding update_ps_c',
                   MSG_LEVEL_BASIC );
            RAISE;
        END;

        -------------------------------------------------------------
        -- Execute
        -------------------------------------------------------------
        BEGIN
	    debug( '  Updating invoice payment schedules', MSG_LEVEL_DEBUG );
            l_ignore := dbms_sql.execute( p_update_ps_c );
            debug( to_char(l_ignore) || ' row(s) updated',
		           MSG_LEVEL_DEBUG );

           /*-------------------------------------------+
            | Call central MRC library for update       |
            | of AR_PAYMENT_SCHEDULES                   |
            +-------------------------------------------*/

           ar_mrc_engine.maintain_mrc_data(
                      p_event_mode       => 'UPDATE',
                      p_table_name       => 'AR_PAYMENT_SCHEDULES',
                      p_mode             => 'SINGLE',
                      p_key_value        => p_ps_id_t( i ));

        EXCEPTION
          WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing update ps stmt',
                   MSG_LEVEL_BASIC );
            RAISE;
        END;

    -------------------------------------------------------------
    -- Insert into ar_distributions
    -------------------------------------------------------------
	/* VAT changes : create acct entry */
        l_ae_doc_rec.document_type := 'ADJUSTMENT';
        l_ae_doc_rec.document_id   := l_adjustment_id;
        l_ae_doc_rec.accounting_entity_level := 'ONE';
        l_ae_doc_rec.source_table  := 'ADJ';
        l_ae_doc_rec.source_id     := l_adjustment_id;
	l_ae_doc_rec.source_id_old := p_select_rec.code_combination_id;
	l_ae_doc_rec.other_flag    := 'COMMITMENT';

        --Bug 1329091 - PS is updated before Accounting Engine Call

        l_ae_doc_rec.pay_sched_upd_yn := 'Y';

        arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

<<skip>>
	null;

    END LOOP;



    print_fcn_label2('arp_maintain_ps2.process_iad_data()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.process_iad_data()',
	       MSG_LEVEL_BASIC );
        RAISE;
END process_iad_data;


----------------------------------------------------------------------------
PROCEDURE insert_cm_child_adj_private(
	p_system_info		IN arp_trx_global.system_info_rec_type,
	p_profile_info 		IN arp_trx_global.profile_rec_type,
	p_customer_trx_id 	IN BINARY_INTEGER ) IS

    l_ignore 			INTEGER;

    l_old_trx_id		BINARY_INTEGER;
    l_customer_trx_id		BINARY_INTEGER;

    l_old_inv_trx_id		BINARY_INTEGER;
    l_inv_trx_id		BINARY_INTEGER;

    l_old_adjusted_trx_id	BINARY_INTEGER;
    l_adjusted_trx_id		BINARY_INTEGER;

    l_load_ps_tables		BOOLEAN := FALSE;
    l_is_new_adj_trx            BOOLEAN;

    --
    -- ps attributes
    --
    l_ps_id_t			id_table_type;
    l_ps_amount_due_rem_t 	number_table_type;
    l_ps_acctd_amt_due_rem_t	number_table_type;
    l_ps_line_orig_t 		number_table_type;
    l_ps_line_rem_t 		number_table_type;
    l_ps_amount_adjusted_t 	number_table_type;
    l_ps_tax_orig_t             number_table_type;
    l_ps_tax_rem_t              number_table_type;
    l_ps_frt_orig_t             number_table_type;
    l_ps_frt_rem_t              number_table_type;

    -- Invoice attributes
    -- (these store the amount adjusted
    -- prior to this CM per PS row)
    l_inv_line_adj_t            number_table_type;
    l_inv_tax_adj_t             number_table_type;
    l_inv_frt_adj_t             number_table_type;

    --
    -- Derived attributes
    --
    l_adj_amount_t 		number_table_type;
    l_acctd_adj_amount_t 	number_table_type;
    l_line_adj_t                number_table_type;
    l_tax_adj_t                 number_table_type;
    l_frt_adj_t                 number_table_type;

    -- accumulators
    l_eff_adj_line_total	NUMBER;
    l_eff_adj_tax_total         NUMBER;
    l_eff_adj_frt_total         NUMBER;
    l_eff_line_bal		NUMBER;
    l_eff_tax_bal               NUMBER;
    l_eff_frt_bal               NUMBER;


    l_table_index		BINARY_INTEGER := 0;

    l_select_rec		select_iad_rec_type;

    -----------------------------------------------------------------------
    PROCEDURE load_tables( p_select_rec IN select_iad_rec_type ) IS

    BEGIN
        print_fcn_label2('arp_maintain_ps2.load_tables()+' );

        l_ps_id_t( l_table_index ) := p_select_rec.payment_schedule_id;
	l_ps_amount_due_rem_t( l_table_index ) :=
				p_select_rec.ps_amount_due_remaining;
	l_ps_acctd_amt_due_rem_t( l_table_index ) :=
				p_select_rec.ps_acctd_amt_due_rem;
	l_ps_line_orig_t( l_table_index ) :=
				p_select_rec.ps_line_original;
	l_ps_line_rem_t( l_table_index ) :=
				p_select_rec.ps_line_remaining;
	l_ps_amount_adjusted_t( l_table_index ) :=
				p_select_rec.ps_amount_adjusted;

        l_ps_tax_orig_t( l_table_index) :=
                                p_select_rec.ps_tax_original;
        l_ps_tax_rem_t( l_table_index ) :=
                                p_select_rec.ps_tax_remaining;
        l_ps_frt_orig_t( l_table_index ) :=
                                p_select_rec.ps_freight_original;
        l_ps_frt_rem_t( l_table_index ) :=
                                p_select_rec.ps_freight_remaining;

        l_inv_line_adj_t( l_table_index) :=
                                p_select_rec.inv_line_adj;
        l_inv_tax_adj_t( l_table_index) :=
                                p_select_rec.inv_tax_adj;
        l_inv_frt_adj_t( l_table_index) :=
                                p_select_rec.inv_frt_adj;

        l_table_index := l_table_index + 1;

        print_fcn_label2('arp_maintain_ps2.load_tables()-' );

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: arp_maintain_ps2.load_tables()',
	           MSG_LEVEL_BASIC );
            RAISE;
    END load_tables;


    -----------------------------------------------------------------------
    PROCEDURE clear_cm_tables IS

    BEGIN
        print_fcn_label2('arp_maintain_ps2.clear_cm_tables()+' );

        l_adj_amount_t := null_number_t;
        l_line_adj_t := null_number_t;
        l_tax_adj_t  := null_number_t;
        l_frt_adj_t  := null_number_t;

        l_acctd_adj_amount_t := null_number_t;

        print_fcn_label2('arp_maintain_ps2.clear_cm_tables()-' );

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: arp_maintain_ps2.clear_cm_tables()',
	           MSG_LEVEL_BASIC );
            RAISE;
    END clear_cm_tables;


    -----------------------------------------------------------------------
    PROCEDURE clear_all_tables IS

    BEGIN
        print_fcn_label2('arp_maintain_ps2.clear_all_tables()+' );



        l_ps_id_t := null_id_t;
        l_ps_amount_due_rem_t := null_number_t;
        l_ps_acctd_amt_due_rem_t := null_number_t;
        l_ps_line_orig_t := null_number_t;
        l_ps_line_rem_t := null_number_t;
        l_ps_tax_orig_t := null_number_t;
        l_ps_tax_rem_t  := null_number_t;
        l_ps_frt_orig_t := null_number_t;
        l_ps_frt_rem_t  := null_number_t;
        l_ps_amount_adjusted_t := null_number_t;

        l_inv_line_adj_t := null_number_t;
        l_inv_tax_adj_t := null_number_t;
        l_inv_frt_adj_t := null_number_t;

	clear_cm_tables;

        l_table_index := 0;

        print_fcn_label2('arp_maintain_ps2.clear_all_tables()-' );

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: arp_maintain_ps2.clear_all_tables()',
	           MSG_LEVEL_BASIC );
            RAISE;
    END clear_all_tables;

    -----------------------------------------------------------------------
    FUNCTION is_new_id( p_old_id BINARY_INTEGER, p_new_id BINARY_INTEGER )
        RETURN BOOLEAN IS
    BEGIN

        RETURN( p_old_id IS NULL OR p_old_id <> p_new_id );

    END is_new_id;

    -----------------------------------------------------------------------
    FUNCTION is_new_cm RETURN BOOLEAN IS
    BEGIN

        RETURN( l_old_trx_id IS NULL OR l_old_trx_id <> l_customer_trx_id );

    END is_new_cm;

    -----------------------------------------------------------------------
    FUNCTION is_new_inv RETURN BOOLEAN IS
    BEGIN

        RETURN( l_old_inv_trx_id IS NULL OR
		l_old_inv_trx_id <> l_inv_trx_id );

    END is_new_inv;

    -----------------------------------------------------------------------
    FUNCTION is_new_adjusted_trx RETURN BOOLEAN IS
    BEGIN

        RETURN( l_old_adjusted_trx_id IS NULL OR
		l_old_adjusted_trx_id <> l_adjusted_trx_id );

    END is_new_adjusted_trx;


BEGIN

    print_fcn_label( 'arp_maintain_ps2.insert_cm_child_adj_private()+' );

    --
    clear_all_tables;
    --
    IF( NOT( dbms_sql.is_open( iad_select_c ) AND
	     dbms_sql.is_open( iad_insert_adj_c ) AND
	     dbms_sql.is_open( iad_update_ps_c ) )) THEN

        build_iad_sql(
		system_info,
		profile_info,
		iad_select_c,
		iad_insert_adj_c,
		iad_update_ps_c );

    END IF;

    --
    define_iad_select_columns( iad_select_c, l_select_rec );

    ---------------------------------------------------------------
    -- Bind variables
    ---------------------------------------------------------------
    dbms_sql.bind_variable( iad_select_c,
			    'customer_trx_id',
			    p_customer_trx_id );

    ---------------------------------------------------------------
    -- Execute sql
    ---------------------------------------------------------------
    debug( '  Executing select sql', MSG_LEVEL_DEBUG );

    BEGIN
        l_ignore := dbms_sql.execute( iad_select_c );

    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error executing select sql',
		 MSG_LEVEL_BASIC );
          RAISE;
    END;


    ---------------------------------------------------------------
    -- Fetch rows
    ---------------------------------------------------------------
    BEGIN
        LOOP

            IF dbms_sql.fetch_rows( iad_select_c ) > 0  THEN

	        debug('  Fetched a row', MSG_LEVEL_DEBUG );

                -----------------------------------------------
                -- Load row into record
                -----------------------------------------------
		dbms_sql.column_value( iad_select_c, 7, l_customer_trx_id );
		dbms_sql.column_value( iad_select_c, 5, l_adjusted_trx_id );
		dbms_sql.column_value( iad_select_c, 16, l_inv_trx_id );

                -----------------------------------------------
		-- Check if adjusted trx or invoice changed
                -----------------------------------------------
		IF( is_new_adjusted_trx OR is_new_inv OR is_new_cm ) THEN

		    debug( '  new adjusted trx or invoice or cm',
				MSG_LEVEL_DEBUG );

                    -----------------------------------------------
		    -- Check if adjusted trx changed
                    -----------------------------------------------
		    IF( is_new_adjusted_trx ) THEN

			debug( '  new adjusted trx', MSG_LEVEL_DEBUG );

                        ---------------------------------------------------
			-- Start loading ps tables for new adjusted trx
                        ---------------------------------------------------
			l_load_ps_tables := TRUE;

		    END IF;

		    IF( l_old_adjusted_trx_id IS NOT NULL ) THEN

			debug( '  process1', MSG_LEVEL_DEBUG );

			process_iad_data(
				system_info,
				profile_info,
				iad_insert_adj_c,
				iad_update_ps_c,
				l_select_rec,
				l_table_index,
				l_ps_id_t,
				l_ps_amount_due_rem_t,
				l_ps_acctd_amt_due_rem_t,
				l_ps_line_orig_t,
				l_ps_line_rem_t,
				l_ps_amount_adjusted_t,
				l_adj_amount_t,
				l_acctd_adj_amount_t,
				l_eff_adj_line_total,
                                l_eff_adj_tax_total,
                                l_eff_adj_frt_total,
				l_eff_line_bal,
                                l_eff_tax_bal,
                                l_eff_frt_bal,
                                l_line_adj_t,
                                l_tax_adj_t,
                                l_frt_adj_t,
                                l_ps_tax_orig_t,
                                l_ps_tax_rem_t,
                                l_ps_frt_orig_t,
                                l_ps_frt_rem_t,
                                l_inv_line_adj_t,
                                l_inv_tax_adj_t,
                                l_inv_frt_adj_t,
                                l_is_new_adj_trx );

		    END IF;

                    -----------------------------------------------
		    -- Check if new adjusted trx
                    -----------------------------------------------
		    IF( is_new_adjusted_trx ) THEN

			clear_all_tables;

			l_old_adjusted_trx_id := l_adjusted_trx_id;
			l_old_trx_id := l_customer_trx_id;

			-- get total adjustments for new adjusted trx
                        l_is_new_adj_trx := TRUE;

/*                        dbms_sql.column_value( iad_select_c, 31,
                                                l_eff_adj_line_total );
                        dbms_sql.column_value( iad_select_c, 32,
                                                l_eff_adj_tax_total );
                        dbms_sql.column_value( iad_select_c, 33,
                                                l_eff_adj_frt_total );
*/
                    -----------------------------------------------
		    -- Else if new cm
                    -----------------------------------------------
		    ELSIF( is_new_cm ) THEN

			clear_cm_tables;

			l_load_ps_tables := FALSE;
			l_old_trx_id := l_customer_trx_id;

		    END IF;

		    IF( is_new_inv ) THEN

			l_old_inv_trx_id := l_inv_trx_id;
			-- get invoice line, tax, frt remaining for new invoice
                        dbms_sql.column_value( iad_select_c, 24 ,
                                                l_eff_line_bal );
                        dbms_sql.column_value( iad_select_c, 34 ,
                                                l_eff_tax_bal );
                        dbms_sql.column_value( iad_select_c, 35,
                                                l_eff_frt_bal );

		    END IF;

		END IF;		-- END adjusted trx or inv or cm changed

		get_iad_column_values( iad_select_c, l_select_rec );
		dump_iad_select_rec( l_select_rec );


		IF( l_load_ps_tables ) THEN
		    load_tables( l_select_rec );
		END IF;

		-- >> dump tables

            ELSE
                -----------------------------------------------
		-- No more rows to fetch, process last set
                -----------------------------------------------

		debug( '  process2', MSG_LEVEL_DEBUG );

		process_iad_data(
			system_info,
			profile_info,
			iad_insert_adj_c,
			iad_update_ps_c,
			l_select_rec,
			l_table_index,
			l_ps_id_t,
			l_ps_amount_due_rem_t,
			l_ps_acctd_amt_due_rem_t,
			l_ps_line_orig_t,
			l_ps_line_rem_t,
			l_ps_amount_adjusted_t,
			l_adj_amount_t,
			l_acctd_adj_amount_t,
		        l_eff_adj_line_total,
                        l_eff_adj_tax_total,
                        l_eff_adj_frt_total,
		        l_eff_line_bal,
                        l_eff_tax_bal,
                        l_eff_frt_bal,
                        l_line_adj_t,
                        l_tax_adj_t,
                        l_frt_adj_t,
                        l_ps_tax_orig_t,
                        l_ps_tax_rem_t,
                        l_ps_frt_orig_t,
                        l_ps_frt_rem_t,
                        l_inv_line_adj_t,
                        l_inv_tax_adj_t,
                        l_inv_frt_adj_t,
                        l_is_new_adj_trx  );



                EXIT;

            END IF;


        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error fetching select cursor',
                   MSG_LEVEL_BASIC );
            RAISE;

    END;

    print_fcn_label( 'arp_maintain_ps2.insert_cm_child_adj_private()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps2.insert_cm_child_adj_private()',
	       MSG_LEVEL_BASIC );
        RAISE;

END insert_cm_child_adj_private;


---------------------------------------------------------------------------
-- Test Functions
---------------------------------------------------------------------------

PROCEDURE test_build_ips_sql
IS

BEGIN

    build_ips_sql(system_info, profile_info, ips_select_c, ips_insert_ps_c);


END;

---------------------------------------------------------------------------
PROCEDURE test_build_ira_sql
IS

BEGIN

    build_ira_sql(
		system_info,
		profile_info,
		ira_select_c,
		ira_insert_ps_c,
		ira_insert_ra_c,
		ira_update_ps_c);


END;

---------------------------------------------------------------------------
PROCEDURE test_build_ups_sql
IS

BEGIN

    build_ups_sql(
		system_info,
		profile_info,
		ups_select_c,
		ups_insert_adj_c,
		ups_update_ps_c);


END;

---------------------------------------------------------------------------
PROCEDURE test_build_iad_sql
IS

BEGIN

    build_iad_sql(
		system_info,
		profile_info,
		iad_select_c,
		iad_insert_adj_c,
		iad_update_ps_c);


END;

---------------------------------------------------------------------------
PROCEDURE test_insert_inv_ps(
	p_customer_trx_id BINARY_INTEGER,
	p_reversed_cash_receipt_id	IN BINARY_INTEGER )
IS

BEGIN

    insert_inv_ps_private(
	system_info,
	profile_info,
	p_customer_trx_id,
	p_reversed_cash_receipt_id
	);


END;

---------------------------------------------------------------------------
PROCEDURE test_ai_insert_inv_ps(
		p_request_id BINARY_INTEGER,
		p_select_sql VARCHAR2 )
IS

BEGIN

    print_fcn_label( 'arp_maintain_ps2.test_ai_insert_inv_ps()+' );

    build_ips_sql( system_info,
		       profile_info,
		       ips_select_c,
		       ips_insert_ps_c );


    -- use the select sql passed as arg
    --

    dbms_sql.close_cursor( ips_select_c );
    ips_select_c := dbms_sql.open_cursor;

    debug('  select_sql='||p_select_sql );

    debug('  parsing new select sql');
    dbms_sql.parse( ips_select_c, p_select_sql, dbms_sql.v7 );



    insert_inv_ps_private(
	system_info,
	profile_info,
	p_request_id,
	null);

    print_fcn_label( 'arp_maintain_ps2.test_ai_insert_inv_ps()-' );

END;

---------------------------------------------------------------------------
PROCEDURE test_insert_cm_ps( p_customer_trx_id BINARY_INTEGER )
IS

BEGIN

    insert_cm_ps_private(system_info, profile_info, p_customer_trx_id);


END;

---------------------------------------------------------------------------
PROCEDURE test_ai_insert_cm_ps(
		p_request_id BINARY_INTEGER,
		p_select_sql VARCHAR2 )
IS

BEGIN

    print_fcn_label( 'arp_maintain_ps2.test_ai_insert_cm_ps()+' );

    build_ira_sql( system_info,
		       profile_info,
		       ira_select_c,
			ira_insert_ps_c,
			ira_insert_ra_c,
		       ira_update_ps_c );


    -- use the select sql passed as arg
    --

    dbms_sql.close_cursor( ira_select_c );
    ira_select_c := dbms_sql.open_cursor;

    debug('  select_sql='||p_select_sql );

    debug('  parsing new select sql');
    dbms_sql.parse( ira_select_c, p_select_sql, dbms_sql.v7 );



    insert_cm_ps_private(system_info, profile_info, p_request_id);

    print_fcn_label( 'arp_maintain_ps2.test_ai_insert_cm_ps()-' );

END;
---------------------------------------------------------------------------
PROCEDURE test_insert_child_adj( p_customer_trx_id BINARY_INTEGER )
IS

BEGIN

    insert_child_adj_private(system_info, profile_info, p_customer_trx_id);


END;

---------------------------------------------------------------------------
PROCEDURE test_ai_insert_child_adj(
		p_request_id BINARY_INTEGER,
		p_select_sql VARCHAR2 )
IS

BEGIN

    print_fcn_label( 'arp_maintain_ps2.test_ai_insert_child_adj()+' );

    build_ups_sql( system_info,
		       profile_info,
		       ups_select_c,
			ups_insert_adj_c,
		       ups_update_ps_c );


    -- use the select sql passed as arg
    --

    dbms_sql.close_cursor( ups_select_c );
    ups_select_c := dbms_sql.open_cursor;

    debug('  select_sql='||p_select_sql );

    debug('  parsing new select sql');
    dbms_sql.parse( ups_select_c, p_select_sql, dbms_sql.v7 );



    insert_child_adj_private(system_info, profile_info, p_request_id);

    print_fcn_label( 'arp_maintain_ps2.test_ai_insert_child_adj()-' );

END;

---------------------------------------------------------------------------
PROCEDURE test_insert_cm_child_adj( p_customer_trx_id BINARY_INTEGER )
IS

BEGIN

    insert_cm_child_adj_private(system_info, profile_info, p_customer_trx_id);


END;

---------------------------------------------------------------------------
PROCEDURE test_ai_insert_cm_child_adj(
		p_request_id BINARY_INTEGER,
		p_select_sql VARCHAR2 )
IS

BEGIN

    print_fcn_label( 'arp_maintain_ps2.test_ai_insert_cm_child_adj()+' );

    build_iad_sql( system_info,
		       profile_info,
		       iad_select_c,
			iad_insert_adj_c,
		       iad_update_ps_c );


    -- use the select sql passed as arg
    --

    dbms_sql.close_cursor( iad_select_c );
    iad_select_c := dbms_sql.open_cursor;

    debug('  select_sql='||p_select_sql );

    debug('  parsing new select sql');
    dbms_sql.parse( iad_select_c, p_select_sql, dbms_sql.v7 );



    insert_cm_child_adj_private(system_info, profile_info, p_request_id);

    print_fcn_label( 'arp_maintain_ps2.test_ai_insert_cm_child_adj()-' );

END;

---------------------------------------------------------------------------
--
-- Constructor code
--
PROCEDURE init IS
BEGIN

    print_fcn_label( 'arp_maintain_ps2.constructor()+' );

    DECLARE

       l_result             boolean;
       l_dummy              varchar2(240);

    BEGIN
        l_result := fnd_installation.get_app_info(
			'OE',
                        g_oe_install_flag,
                        l_dummy,
                        l_dummy );
        -- OE/OM changes
        -- fnd_profile.get( 'SO_SOURCE_CODE', g_so_source_code );
        --
        oe_profile.get( 'SO_SOURCE_CODE', g_so_source_code );

	debug( '  g_oe_install_flag='||g_oe_install_flag, MSG_LEVEL_DEBUG );
	debug( '  g_so_source_code='||g_so_source_code, MSG_LEVEL_DEBUG );

    END;


    print_fcn_label( 'arp_maintain_ps2.constructor()-' );


EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_maintain_ps2.constructor()');
        debug(SQLERRM);
        RAISE;
END init;

BEGIN
   init;
END arp_maintain_ps2;

/
