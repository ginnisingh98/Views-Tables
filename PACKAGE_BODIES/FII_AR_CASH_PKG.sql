--------------------------------------------------------
--  DDL for Package Body FII_AR_CASH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_CASH_PKG" AS
/* $Header: FIIAR08B.pls 120.2 2004/01/16 06:08:55 sgautam noship $ */


TYPE Instance_Rec IS RECORD (
	instance_code	VARCHAR2(30),
	db_link		VARCHAR2(128),
	same_inst	BOOLEAN,
	valid		BOOLEAN);

TYPE Instance_Tab IS TABLE OF Instance_Rec INDEX BY BINARY_INTEGER;

g_debug_flag 	VARCHAR2(1) := NVL(FND_PROFILE.value('EDW_DEBUG'), 'N');
g_rec		Instance_Tab;
g_fii_schema 	VARCHAR2(30);
g_tablespace    VARCHAR2(30);
g_start_date	DATE;
g_end_date	DATE;
g_ar_rev_installed BOOLEAN;


G_TABLE_NOT_EXIST      EXCEPTION;
G_SYNONYM_NOT_EXIST    EXCEPTION;
PRAGMA EXCEPTION_INIT(G_TABLE_NOT_EXIST, -942);
PRAGMA EXCEPTION_INIT(G_SYNONYM_NOT_EXIST, -1434);


-- ---------------------------------
-- PRIVATE PROCEDURES AND FUNCTIONS
-- ---------------------------------

-------------------
-- PROCEDURE Init
-------------------
PROCEDURE Init is
  l_stmt  		VARCHAR2(200);
  l_status		VARCHAR2(30);
  l_industry		VARCHAR2(30);
  l_db_name1		VARCHAR2(30);
  l_db_name2		VARCHAR2(30);
  l_dummy		NUMBER := NULL;
  i			NUMBER := 0;

  cursor source_instance is
    select instance_code,
	   warehouse_to_instance_link
    from   edw_source_instances;

BEGIN

  -- --------------------------------------------------------
  -- Find the schema owner and tablespace
  -- FII_AR_OPERATIONS_SUMMARY is using
  -- --------------------------------------------------------
  IF(FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, g_fii_schema))
  THEN NULL;
  END IF;

  SELECT tablespace_name
  INTO   g_tablespace
  FROM   all_tables
  WHERE  table_name = 'FII_AR_OPERATIONS_SUMMARY'
  AND    owner = g_fii_schema;

  g_start_date := fii_time_wh_api.get_fqtr_start;
  g_end_date := fii_time_wh_api.get_fqtr_end;

-- DEBUG
--  g_start_date := '01-JAN-1998';
--  g_end_date := '01-APR-1998';


  -- ----------------------------
  -- Findwarehouse database name
  -- ----------------------------
  select  name
  into	  l_db_name1
  from    v$database;

  -- --------------------------------------------------------
  -- Only if the customer is Oracle IT, then we will use
  -- Cons Revenue.  Otherwise, we will use AR Revenue
  -- --------------------------------------------------------
  IF (l_db_name1 = 'EDWAP' or
      l_db_name1 = 'EDWAT' or
      l_db_name1 = 'EDWAS') THEN
    g_ar_rev_installed := FALSE;
  ELSE
    g_ar_rev_installed := TRUE;
  END IF;

-- DEBUG
--   g_ar_rev_installed :=  FALSE;


  -- --------------------------------------------------------
  -- Loop the complete set of instances
  -- --------------------------------------------------------
  FOR c in source_instance LOOP

    i := i + 1;
    g_rec(i).instance_code := c.instance_code;
    g_rec(i).db_link := c.warehouse_to_instance_link;


    -- --------------------------------------------------
    -- Check if we should load data from that instance
    -- Currently, we just check if the fii_ar_oltp_cash_v
    -- exist on the instance and has data.  This is a bit
    -- cludgy but is a temporary solution until we build
    -- the AR Cash Base Fact
    -- --------------------------------------------------
    BEGIN

      l_stmt := 'select sob_id from fii_ar_oltp_cash_v@'||
              g_rec(i).db_link||' where rownum < 2';

      if g_debug_flag = 'Y' then
      	edw_log.debug_line('');
      	edw_log.debug_line(l_stmt);
      end if;
      execute immediate l_stmt into l_dummy;

     IF l_dummy IS NOT NULL THEN
	g_rec(i).valid := TRUE;
      ELSE
	g_rec(i).valid := FALSE;
      END IF;

    exception when others then
      g_rec(i).valid := FALSE;

    END;


    -- ----------------------------
    -- Check if same instance
    -- ----------------------------
    IF g_rec(i).valid THEN
      l_stmt := 'select name '||
	    'from v$database@'||g_rec(i).db_link;

      if g_debug_flag = 'Y' then
 	edw_log.debug_line('');
      	edw_log.debug_line(l_stmt);
      end if;

      execute immediate l_stmt into l_db_name2;

      IF (l_db_name1 = l_db_name2) THEN
	g_rec(i).same_inst := TRUE;
      ELSE
	g_rec(i).same_inst := FALSE;
      END IF;
    END IF;

  END LOOP;

end Init;



---------------------------------------------------
-- PROCEDURE DROP_TABLE
---------------------------------------------------
procedure drop_table (p_table_name in varchar2) is
  l_stmt varchar2(400);
Begin

  l_stmt:='drop table '||g_fii_schema||'.'||p_table_name;

  if g_debug_flag = 'Y' then
  	edw_log.debug_line('');
  	edw_log.debug_line(l_stmt);
  end if;
  execute immediate l_stmt;

  l_stmt:='drop synonym '||p_table_name;

   if g_debug_flag = 'Y' then
  	edw_log.debug_line('');
  	edw_log.debug_line(l_stmt);
  end if;

  execute immediate l_stmt;


Exception
  WHEN G_TABLE_NOT_EXIST THEN
    null;      -- Oracle 942, table does not exist, no actions
  WHEN G_SYNONYM_NOT_EXIST THEN
    null;      -- Oracle 1434, synonym not exist, no actions
  WHEN OTHERS THEN
    raise;
End Drop_Table;



---------------------------------------------------
-- PROCEDURE Extract_OLTP_CASH
---------------------------------------------------
Procedure Extract_OLTP_CASH is
  l_stmt varchar2(1000);
Begin

  -- ------------------------
  -- Create the table needed
  -- ------------------------
  l_stmt := 'create table '||g_fii_schema||'.FII_AR_OLTP_CASH(
	instance_code	varchar2(30),
	org_id		number,
	sob_id		number,
	customer_id	number,
	period_set	varchar2(15),
	period_type	varchar2(15),
	calendar_day	date,
	functional_currency varchar2(15),
	cash_b		number,
	cash_g		number,
	receipt_cnt	number)
	TABLESPACE '||g_tablespace||'
	PCTFREE 5
	storage (INITIAL 4K NEXT 32K)';

    if g_debug_flag = 'Y' then
    	edw_log.debug_line('');
    	edw_log.debug_line(l_stmt);
    end if;
    execute immediate l_stmt;


  -- ------------------------
  -- Populate the table from
  -- all the valid sources
  -- ------------------------

  FOR i IN 1..g_rec.count LOOP

    IF (g_rec(i).valid) THEN
      l_stmt := 'insert into '||g_fii_schema||'.FII_AR_OLTP_CASH T
	(instance_code,
	org_id,
	sob_id,
	customer_id,
	period_set,
	period_type,
	calendar_day,
	functional_currency,
	cash_b,
	cash_g,
	receipt_cnt)
      select /*+ DRIVING_SITE(CASH) */
	instance_code,
	org_id,
	sob_id,
	customer_id,
	period_set,
	period_type,
	trunc(calendar_day),
	functional_currency,
	sum(cash_b),
	sum(cash_g),
	count(distinct(cash_receipt_id))
      from
	fii_ar_oltp_cash_v';

      IF (g_rec(i).same_inst) THEN
        l_stmt := l_stmt||' CASH ';
      ELSE
        l_stmt := l_stmt||'@'||g_rec(i).db_link||' CASH ';
      END IF;

      l_stmt := l_stmt ||'
      where calendar_day >= to_date('''||to_char(g_start_date,'DD-MM-YYYY')||''', ''DD-MM-YYYY'')
      and   calendar_day < to_date('''||to_char(g_end_date,'DD-MM-YYYY')||''', ''DD-MM-YYYY'')
      group by
	instance_code,
	org_id,
	sob_id,
	customer_id,
	period_set,
	period_type,
	trunc(calendar_day),
	functional_currency';

      if g_debug_flag = 'Y' then
      	edw_log.debug_line('');
      	edw_log.debug_line(l_stmt);
      end if;
      execute immediate l_stmt;

     commit;

    END IF;  -- g_rec(i).valid

  END LOOP;

End Extract_OLTP_CASH;



---------------------------------------------------
-- PROCEDURE Extract_EDW_AR_INV_REV
---------------------------------------------------
procedure Extract_AR_INV_REV is
  l_stmt varchar2(2000);
Begin


  -- -------------------------
  -- Create the tables needed
  -- -------------------------
  l_stmt := 'create table '||g_fii_schema||'.FII_AR_EDW_REV(
	set_of_books_fk_key	NUMBER,
	operating_unit_fk_key	NUMBER,
	org_fk_key		NUMBER,
	customer_fk_key		NUMBER,
	functional_currency	VARCHAR2(15),
	calendar_day_fk_key	NUMBER,
	calendar_date		DATE,
	amt_invoiced_ar_b	NUMBER,
	amt_invoiced_ar_g	NUMBER,
	amt_rev_earned_b 	NUMBER,
	amt_rev_earned_g 	NUMBER,
	inv_created_cnt		NUMBER,
	inv_revrec_cnt		NUMBER)
	TABLESPACE '||g_tablespace||'
	PCTFREE 5
	storage (INITIAL 4K NEXT 32K)';

    if g_debug_flag = 'Y' then
    	edw_log.debug_line('');
    	edw_log.debug_line(l_stmt);
    end if;
    execute immediate l_stmt;

  l_stmt := 'create table '||g_fii_schema||'.FII_AR_OLTP_INV(
	instance_code	varchar2(30),
	org_id		number,
	sob_id		number,
    customer_id number,
	period_set	varchar2(15),
	period_type	varchar2(15),
	calendar_day	date,
	functional_currency varchar2(15),
	inv_b		number,
	inv_g		number,
	inv_created_cnt	number)
	TABLESPACE '||g_tablespace||'
	PCTFREE 5
	storage (INITIAL 4K NEXT 32K)';

    if g_debug_flag = 'Y' then
    	edw_log.debug_line('');
    	edw_log.debug_line(l_stmt);
    end if;
    execute immediate l_stmt;



IF (g_ar_rev_installed) THEN

  -- -----------------------------
  -- Populate Revenue and Invoice
  -- info from AR Revenue Fact
  -- -----------------------------

  l_stmt := 'insert into '||g_fii_schema||'.FII_AR_EDW_REV T (
	set_of_books_fk_key,
	operating_unit_fk_key,
	org_fk_key,
	customer_fk_key,
	functional_currency,
	calendar_day_fk_key,
	calendar_date,
	amt_invoiced_ar_b,
	amt_invoiced_ar_g,
	amt_rev_earned_b,
	amt_rev_earned_g,
	inv_created_cnt,
	inv_revrec_cnt)
  select
	f.set_of_books_fk_key,
	org.oper_operating_unit_pk_key,
	f.organization_fk_key,
	cust.tprt_trade_partner_pk_key,
	curr.crnc_currency,
	f.gl_date_fk_key,
	trunc(f.gl_date),
	sum(decode(f.account_class, ''REC'', f.amt_b, 0)),
	sum(decode(f.account_class, ''REC'', f.amt_g, 0)),
	sum(decode(f.account_class, ''REV'', f.amt_b, 0)),
	sum(decode(f.account_class, ''REV'', f.amt_g, 0)),
	count(distinct(decode(f.account_class, ''REC'', invoice_id, to_number(null)))),
	count(distinct(decode(f.account_class, ''REV'', invoice_id, to_number(null))))
  from	fii_ar_trx_dist_f f,
	edw_organization_m org,
	edw_trd_partner_m cust,
	edw_currency_m curr
  where f.gl_date >= to_date('''||to_char(g_start_date,'DD-MM-YYYY')||''', ''DD-MM-YYYY'')
  and   f.gl_date < to_date('''||to_char(g_end_date,'DD-MM-YYYY')||''', ''DD-MM-YYYY'')
  and   f.account_class in (''REV'', ''REC'')
  and   curr.crnc_currency_pk_key = f.functional_currency_fk_key
  and   cust.tplo_tpartner_loc_pk_key = f.bill_to_customer_fk_key
  and   org.orga_organization_pk_key = f.organization_fk_key
  group by
	f.set_of_books_fk_key,
	org.oper_operating_unit_pk_key,
	f.organization_fk_key,
	cust.tprt_trade_partner_pk_key,
	curr.crnc_currency,
	f.gl_date_fk_key,
	trunc(f.gl_date)';

  if g_debug_flag = 'Y' then
  	edw_log.debug_line('');
  	edw_log.debug_line(l_stmt);
  end if;
  execute immediate l_stmt;


ELSE  -- Consolidated Revenue Implementation

  -- -----------------------------
  -- Populate Revenue from Cons Rev
  -- -----------------------------

  l_stmt := 'insert into '||g_fii_schema||'.FII_AR_EDW_REV T (
	set_of_books_fk_key,
	operating_unit_fk_key,
	org_fk_key,
	customer_fk_key,
	functional_currency,
	calendar_day_fk_key,
	calendar_date,
	amt_invoiced_ar_b,
	amt_invoiced_ar_g,
	amt_rev_earned_b,
	amt_rev_earned_g,
	inv_created_cnt,
	inv_revrec_cnt )
  select
	f.gl_set_of_books_fk_key,
	org.oper_operating_unit_pk_key,
	f.organization_fk_key,
	cust.tprt_trade_partner_pk_key,
	curr.crnc_currency,
	f.gl_period_fk_key,
	t.cday_calendar_date,
	0,
	0,
	sum(f.amt_b),
	sum(f.amt_g),
	0,
	count(distinct(f.ar_doc_num_fk_key))
  from	fii_e_revenue_f f,
	edw_time_m t,
	edw_currency_m curr,
	edw_rev_source_m src,
	edw_organization_m org,
	edw_gl_acct3_m acct,
    edw_trd_partner_m cust
  where	t.cday_cal_day_pk_key = f.gl_period_fk_key
  and   src.source_rev_src_pk_key = f.revenue_source_fk_key
  and   src.source_rev_src_pk in (''AR ADJ'', ''AR REV'')
  and	acct.l1_pk_key = f.gl_acct3_fk_key
  and	acct.l1_type = ''Revenue''
  and   t.cday_calendar_date >= to_date('''||to_char(g_start_date,'DD-MM-YYYY')||''', ''DD-MM-YYYY'')
  and   t.cday_calendar_date < to_date('''||to_char(g_end_date,'DD-MM-YYYY')||''', ''DD-MM-YYYY'')
  and   f.base_currency_fk_key = curr.crnc_currency_pk_key
  and   org.orga_organization_pk_key = f.organization_fk_key
  and   cust.tplo_tpartner_loc_pk_key = f.bill_to_customer_fk_key
  group by
	f.gl_set_of_books_fk_key,
	org.oper_operating_unit_pk_key,
	f.organization_fk_key,
    cust.tprt_trade_partner_pk_key,
	curr.crnc_currency,
	f.gl_period_fk_key,
	t.cday_calendar_date';

  if g_debug_flag = 'Y' then
  	edw_log.debug_line('');
  	edw_log.debug_line(l_stmt);
  end if;
  execute immediate l_stmt;


  -- -------------------------------
  -- Populate Invoice info from OLTP
  -- -------------------------------

  FOR i IN 1..g_rec.count LOOP

    IF (g_rec(i).valid) THEN
      l_stmt := 'insert into '||g_fii_schema||'.FII_AR_OLTP_INV T (
	instance_code,
	org_id,
	sob_id,
    customer_id,
	period_set,
	period_type,
	calendar_day,
	functional_currency,
	inv_b,
	inv_g,
	inv_created_cnt)
      select /*+ DRIVING_SITE(INV) */
	instance_code,
	org_id,
	sob_id,
    customer_trx_id,
	period_set,
	period_type,
	trunc(calendar_day),
	functional_currency,
	sum(inv_b),
	sum(inv_g),
	count(distinct(customer_trx_id))
      from
	fii_ar_oltp_inv_v';

      IF (g_rec(i).same_inst) THEN
        l_stmt := l_stmt||' INV ';
      ELSE
        l_stmt := l_stmt||'@'||g_rec(i).db_link||' INV ';
      END IF;

      l_stmt := l_stmt ||'
      where calendar_day >= to_date('''||to_char(g_start_date,'DD-MM-YYYY')||''', ''DD-MM-YYYY'')
      and   calendar_day < to_date('''||to_char(g_end_date,'DD-MM-YYYY')||''', ''DD-MM-YYYY'')
      group by
	instance_code,
	org_id,
	sob_id,
    customer_trx_id,
	period_set,
	period_type,
	trunc(calendar_day),
	functional_currency';

	if g_debug_flag = 'Y' then
      		edw_log.debug_line('');
      		edw_log.debug_line(l_stmt);
      end if;
      execute immediate l_stmt;

      commit;

    END IF;  -- (g_rec(i).valid

  END LOOP;

END IF; -- g_ar_rev_installed


end Extract_AR_INV_REV;


--------------------------------------------------
-- PROCEDURE Populate_AR_OPER_SUMMARY
---------------------------------------------------
procedure Populate_AR_OPER_SUMMARY is
  l_stmt 	VARCHAR2(32767);
Begin


  -- --------------------------------
  -- Populate customer level summary
  -- --------------------------------
  l_stmt := 'truncate table '||g_fii_schema||'.fii_ar_oper_cust_summary_f';

  if g_debug_flag = 'Y' then
  	edw_log.debug_line('');
  	edw_log.debug_line(l_stmt);
  end if;
  execute immediate l_stmt;


  l_stmt := 'insert into fii_ar_oper_cust_summary_f (
	 set_of_books_fk_key,
	 operating_unit_fk_key,
	 org_fk_key,
	 customer_fk_key,
	 functional_currency,
	 calendar_day_fk_key,
	 calendar_date,
	 amt_invoiced_ar_b,
	 amt_invoiced_ar_g,
	 amt_rev_earned_b,
	 amt_rev_earned_g,
	 amt_cash_received_b,
	 amt_cash_received_g,
	 inv_created_cnt,
	 inv_revrec_cnt,
	 receipt_cnt,
	 last_update_date,
	 creation_date)
  select a.set_of_books_fk_key,
	 a.operating_unit_fk_key,
	 a.org_fk_key,
	 a.customer_fk_key,
	 a.functional_currency,
	 a.calendar_day_fk_key,
	 a.calendar_date,
	 sum(a.amt_invoiced_ar_b) 	amt_invoiced_ar_b,
	 sum(a.amt_invoiced_ar_g) 	amt_invoiced_ar_g,
	 sum(a.amt_rev_earned_b) 	amt_rev_earned_b,
	 sum(a.amt_rev_earned_g) 	amt_rev_earned_g,
	 sum(a.amt_cash_received_b) 	amt_cash_received_b,
	 sum(a.amt_cash_received_g) 	amt_cash_received_g,
	 sum(a.inv_created_cnt)		inv_created_cnt,
	 sum(a.inv_revrec_cnt)		inv_revrec_cnt,
	 sum(a.receipt_cnt)		receipt_cnt,
	 sysdate, sysdate
  from ( select	 set_of_books_fk_key,
		 operating_unit_fk_key,
		 org_fk_key,
		 customer_fk_key,
		 functional_currency,
		 calendar_day_fk_key,
		 calendar_date,
		 amt_invoiced_ar_b,
		 amt_invoiced_ar_g,
		 amt_rev_earned_b,
		 amt_rev_earned_g,
		 0 amt_cash_received_b,
		 0 amt_cash_received_g,
		 inv_created_cnt,
		 inv_revrec_cnt,
		 0 receipt_cnt
	  from	 '||g_fii_schema||'.fii_ar_edw_rev
          where set_of_books_fk_key > 0
          and operating_unit_fk_key > 0
          and org_fk_key > 0
          and customer_fk_key > 0
          and calendar_day_fk_key > 0
	  union all';

  IF (g_ar_rev_installed) THEN

  l_stmt := l_stmt||'
	  select sob.fabk_fa_book_pk_key,
		 org.oper_operating_unit_pk_key,
		 org.orga_organization_pk_key,
		 cust.tprt_trade_partner_pk_key,
		 f.functional_currency,
		 t.cday_cal_day_pk_key,
		 f.calendar_day,
		 0 amt_invoiced_ar_b,
		 0 amt_invoiced_ar_g,
		 0 amt_rev_earned_b,
		 0 amt_rev_earned_g,
		 f.cash_b amt_cash_received_b,
		 f.cash_g amt_cash_received_g,
		 0 inv_created_cnt,
		 0 inv_revrec_cnt,
		 f.receipt_cnt
	  from   '||g_fii_schema||'.fii_ar_oltp_cash 	f,
		 edw_time_m 		t,
		 edw_gl_book_m		sob,
		 edw_organization_m	org,
		 edw_trd_partner_m	cust
	  where  sob.fabk_fa_book_pk = to_char(f.sob_id)||''-''||f.instance_code
          and    sob.fabk_fa_book_pk_key > 0
          and    org.oper_operating_unit_pk_key > 0
          and    org.orga_organization_pk_key > 0
          and    cust.tprt_trade_partner_pk_key >= 0   /* bug 3290436 */
          and    t.cday_cal_day_pk_key > 0
	  and	 t.cday_cal_day_pk = to_char(f.calendar_day,''DD-MM-YYYY'')||''-''||
			f.period_set||''-''||period_type||''-''||f.instance_code||''-CD''
	  and	 cust.tplo_tpartner_loc_pk = decode(f.customer_id, -1, ''NA_EDW'',
			to_char(f.customer_id)||''-''||f.instance_code||''-CUST_ACCT-TPRT'' )
	  and    org.orga_organization_pk = to_char(f.org_id)||''-''||f.instance_code';
  ELSE

  l_stmt := l_stmt||'
	  select sob.fabk_fa_book_pk_key,
		 org.oper_operating_unit_pk_key,
		 org.orga_organization_pk_key,
		 cust.tprt_trade_partner_pk_key,
		 f.functional_currency,
		 t.cday_cal_day_pk_key,
		 f.calendar_day,
		 0 amt_invoiced_ar_b,
		 0 amt_invoiced_ar_g,
		 0 amt_rev_earned_b,
		 0 amt_rev_earned_g,
		 f.cash_b amt_cash_received_b,
		 f.cash_g amt_cash_received_g,
		 0 inv_created_cnt,
		 0 inv_revrec_cnt,
		 f.receipt_cnt
	  from   '||g_fii_schema||'.fii_ar_oltp_cash 	f,
		 edw_time_m 		t,
		 edw_gl_book_m		sob,
		 edw_organization_m	org,
         edw_trd_partner_m	cust
	  where  sob.fabk_fa_book_pk = to_char(f.sob_id)||''-''||f.instance_code
          and    sob.fabk_fa_book_pk_key > 0
          and    org.oper_operating_unit_pk_key > 0
          and    org.orga_organization_pk_key > 0
          and    cust.tprt_trade_partner_pk_key >= 0    /* bug 3290436 */
          and    t.cday_cal_day_pk_key > 0
	  and	 t.cday_cal_day_pk = to_char(f.calendar_day,''DD-MM-YYYY'')||''-''||
			f.period_set||''-''||period_type||''-''||f.instance_code||''-CD''
      and	 cust.tplo_tpartner_loc_pk = decode(f.customer_id, -1, ''NA_EDW'',
			to_char(f.customer_id)||''-''||f.instance_code||''-CUST_ACCT-TPRT'' )
	  and    org.orga_organization_pk = to_char(f.org_id)||''-''||f.instance_code';

  END IF;

  l_stmt := l_stmt||'
	  union all
	  select sob.fabk_fa_book_pk_key,
		 org.oper_operating_unit_pk_key,
		 org.orga_organization_pk_key,
		 cust.tprt_trade_partner_pk_key,
		 f.functional_currency,
		 t.cday_cal_day_pk_key,
		 f.calendar_day,
		 f.inv_b amt_invoiced_ar_b,
		 f.inv_g amt_invoiced_ar_g,
		 0 amt_rev_earned_b,
		 0 amt_rev_earned_g,
		 0 amt_cash_received_b,
		 0 amt_cash_received_g,
		 f.inv_created_cnt,
		 0 inv_revrec_cnt,
		 0 receipt_count
	  from   '||g_fii_schema||'.fii_ar_oltp_inv 	f,
		 edw_time_m 		t,
		 edw_gl_book_m		sob,
		 edw_organization_m	org,
         edw_trd_partner_m	cust
	  where  sob.fabk_fa_book_pk = to_char(f.sob_id)||''-''||f.instance_code
          and    sob.fabk_fa_book_pk_key > 0
          and    org.oper_operating_unit_pk_key > 0
          and    org.orga_organization_pk_key > 0
          and    cust.tprt_trade_partner_pk_key > 0
          and    t.cday_cal_day_pk_key > 0
	  and	 t.cday_cal_day_pk = to_char(f.calendar_day,''DD-MM-YYYY'')||''-''||
			f.period_set||''-''||period_type||''-''||f.instance_code||''-CD''
      and	 cust.tplo_tpartner_loc_pk = decode(f.customer_id, -1, ''NA_EDW'',
			to_char(f.customer_id)||''-''||f.instance_code||''-CUST_ACCT-TPRT'' )
	  and    org.orga_organization_pk = to_char(f.org_id)||''-''||f.instance_code) a
  group by	a.set_of_books_fk_key,
		a.operating_unit_fk_key,
		a.org_fk_key,
		a.customer_fk_key,
		a.functional_currency,
		a.calendar_day_fk_key,
		a.calendar_date
  order by 	a.set_of_books_fk_key, a.operating_unit_fk_key, a.calendar_date';

  if g_debug_flag = 'Y' then
  	edw_log.debug_line('');
  	edw_log.debug_line(l_stmt);
  end if;
  execute immediate l_stmt;

  -- --------------------------------
  -- Populate org level summary
  -- --------------------------------
  l_stmt := 'create table '||g_fii_schema||'.fii_ar_operations_summary_new
  TABLESPACE '||g_tablespace||'
  PCTFREE 5
  STORAGE (INITIAL 4K NEXT 64K) AS
  select a.set_of_books_fk_key,
	 a.operating_unit_fk_key,
	 a.functional_currency,
	 a.calendar_day_fk_key,
	 a.calendar_date,
	 sum(a.amt_booked_b) 		amt_booked_b,
	 sum(a.amt_booked_g) 		amt_booked_g,
	 sum(a.amt_shipped_b) 		amt_shipped_b,
	 sum(a.amt_shipped_g) 		amt_shipped_g,
	 sum(a.amt_invoiced_oe_b) 	amt_invoiced_oe_b,
	 sum(a.amt_invoiced_oe_g) 	amt_invoiced_oe_g,
	 sum(a.amt_invoiced_ar_b) 	amt_invoiced_ar_b,
	 sum(a.amt_invoiced_ar_g) 	amt_invoiced_ar_g,
	 sum(a.amt_rev_earned_b) 	amt_rev_earned_b,
	 sum(a.amt_rev_earned_g) 	amt_rev_earned_g,
	 sum(a.amt_cash_received_b) 	amt_cash_received_b,
	 sum(a.amt_cash_received_g) 	amt_cash_received_g,
	 sum(a.order_count)		order_count
  from ( select  set_of_books_fk_key	set_of_books_fk_key,
		 operating_unit_fk_key	operating_unit_fk_key,
		 functional_currency	functional_currency,
		 calendar_day_fk_key	calendar_day_fk_key,
		 calendar_date		calendar_date,
		 amt_booked_b		amt_booked_b,
		 amt_booked_g		amt_booked_g,
		 amt_shipped_b		amt_shipped_b,
		 amt_shipped_g		amt_shipped_g,
		 amt_invoiced_oe_b	amt_invoiced_oe_b,
		 amt_invoiced_oe_g	amt_invoiced_oe_g,
		 0 			amt_invoiced_ar_b,
		 0 			amt_invoiced_ar_g,
		 0 			amt_rev_earned_b,
		 0 			amt_rev_earned_g,
		 0 			amt_cash_received_b,
		 0 			amt_cash_received_g,
		 order_count		order_count
	  from	 fii_ar_operations_summary
	  union all
	  select set_of_books_fk_key,
		 org_fk_key,
		 functional_currency,
		 calendar_day_fk_key,
		 calendar_date,
		 0 amt_booked_b,
		 0 amt_booked_g,
		 0 amt_shipped_b,
		 0 amt_shipped_g,
		 0 amt_invoiced_oe_b,
		 0 amt_invoiced_oe_g,
		 amt_invoiced_ar_b,
		 amt_invoiced_ar_g,
		 amt_rev_earned_b,
		 amt_rev_earned_g,
		 amt_cash_received_b,
		 amt_cash_received_g,
		 0 order_count
	  from	fii_ar_oper_cust_summary_f) a
  group by	a.set_of_books_fk_key,
		a.operating_unit_fk_key,
		a.functional_currency,
		a.calendar_day_fk_key,
		a.calendar_date
  order by 	a.set_of_books_fk_key,
		a.operating_unit_fk_key,
		a.calendar_date';


  if g_debug_flag = 'Y' then
  	edw_log.debug_line('');
  	edw_log.debug_line(l_stmt);
  end if;
  execute immediate l_stmt;

  l_stmt := 'truncate table '||g_fii_schema||'.fii_ar_operations_summary';
  if g_debug_flag = 'Y' then
  	edw_log.debug_line('');
  	edw_log.debug_line(l_stmt);
  end if;
  execute immediate l_stmt;

  l_stmt := '
    insert into fii_ar_operations_summary T (
	set_of_books_fk_key,
	operating_unit_fk_key,
	calendar_day_fk_key,
	calendar_date,
	functional_currency,
	creation_date,
	last_update_date,
	amt_booked_b,
	amt_booked_g,
	amt_shipped_b,
	amt_shipped_g,
	amt_invoiced_oe_b,
	amt_invoiced_oe_g,
	amt_invoiced_ar_b,
	amt_invoiced_ar_g,
	amt_rev_earned_b,
	amt_rev_earned_g,
	amt_cash_received_b,
	amt_cash_received_g,
	order_count)
    select
	set_of_books_fk_key,
	operating_unit_fk_key,
	calendar_day_fk_key,
	calendar_date,
	functional_currency,
	sysdate,
	sysdate,
	amt_booked_b,
	amt_booked_g,
	amt_shipped_b,
	amt_shipped_g,
	amt_invoiced_oe_b,
	amt_invoiced_oe_g,
	amt_invoiced_ar_b,
	amt_invoiced_ar_g,
	amt_rev_earned_b,
	amt_rev_earned_g,
	amt_cash_received_b,
	amt_cash_received_g,
	order_count
    from '||g_fii_schema||'.fii_ar_operations_summary_new S
    where set_of_books_fk_key > 0
    and operating_unit_fk_key > 0
    and calendar_day_fk_key > 0';

  if g_debug_flag = 'Y' then
 	 edw_log.debug_line('');
  	edw_log.debug_line(l_stmt);
  end if;
  execute immediate l_stmt;


End Populate_AR_OPER_SUMMARY;


-- ---------------------------------
-- Public PROCEDURES AND FUNCTIONS
-- ---------------------------------

--------------------------------------------------
-- PROCEDURE Populate_AR_OPER_SUMMARY
---------------------------------------------------
procedure Refresh_Summary(Errbuf	IN OUT	NOCOPY VARCHAR2,
			  Retcode	IN OUT	NOCOPY VARCHAR2) IS

  l_errbuf	VARCHAR2(1000) := NULL;
  l_retcode	VARCHAR2(200)  := NULL;
  l_dir		VARCHAR2(400);
  l_stmt	VARCHAR2(100);
BEGIN

  l_stmt := ' ALTER SESSION SET global_names = false';
  EXECUTE IMMEDIATE l_stmt;

-- DEBUG
  IF (fnd_profile.value('EDW_DEBUG') = 'Y') THEN
     edw_log.g_debug := TRUE;
  END IF;

  l_dir:=fnd_profile.value('EDW_LOGFILE_DIR');
  if l_dir is null then
    l_dir:='/sqlcom/log';
  end if;
  if g_debug_flag = 'Y' then
  	edw_log.put_names('FII_AR_OPER_SUMMARY.log','FII_AR_OPER_SUMMARY.out',l_dir);


  	fii_util.put_timestamp;
  	edw_log.put_line('Initialization');
  	fii_util.start_timer;
  end if;
  Init;
  Drop_table('FII_AR_EDW_REV');
  Drop_table('FII_AR_OLTP_CASH');
  Drop_table('FII_AR_OLTP_INV');
  Drop_table('FII_AR_OPERATIONS_SUMMARY_NEW');
  if g_debug_flag = 'Y' then
  	fii_util.stop_timer;
  	fii_util.print_timer('Duration');


  	edw_log.put_line('');
  	edw_log.put_line('Extracting Cash information');

  end if;
  Extract_OLTP_CASH;
  if g_debug_flag = 'Y' then
  	fii_util.stop_timer;
  	fii_util.print_timer('Duration');

  	edw_log.put_line('');
  	edw_log.put_line('Extracting Revenue and Invoice information');
  	fii_util.start_timer;
  end if;
  Extract_AR_INV_REV;
  if g_debug_flag = 'Y' then
  	fii_util.stop_timer;
  	fii_util.print_timer('Duration');

  	edw_log.put_line('');
  	edw_log.put_line('Merging information into AR Operation Summary Table');
  	fii_util.start_timer;
  end if;
  Populate_AR_OPER_SUMMARY;
  if g_debug_flag = 'Y' then
  	fii_util.stop_timer;
  	fii_util.print_timer('Duration');

  end if;
  Drop_table('FII_AR_EDW_REV');
  Drop_table('FII_AR_OLTP_CASH');
  Drop_table('FII_AR_OLTP_INV');
  Drop_table('FII_AR_OPERATIONS_SUMMARY_NEW');

END Refresh_Summary;



End FII_AR_CASH_PKG;

/
