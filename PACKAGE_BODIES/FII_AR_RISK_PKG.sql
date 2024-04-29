--------------------------------------------------------
--  DDL for Package Body FII_AR_RISK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_RISK_PKG" AS
/* $Header: FIIAR09B.pls 120.2 2005/06/13 11:17:20 sgautam noship $ */


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
  -- FII_AR_RISK_INDICATOR is using
  -- --------------------------------------------------------
  IF(FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, g_fii_schema))
  THEN NULL;
  END IF;

  SELECT tablespace_name
  INTO   g_tablespace
  FROM   all_tables
  WHERE  table_name = 'FII_AR_RISK_INDICATOR_F'
  AND    owner = g_fii_schema;


  -- ----------------------------
  -- Find warehouse database name
  -- ----------------------------
  select  name
  into	  l_db_name1
  from    v$database;

  -- --------------------------------------------------------
  -- Loop the complete set of instances
  -- --------------------------------------------------------
  FOR c in source_instance LOOP

    i := i + 1;
    g_rec(i).instance_code := c.instance_code;
    g_rec(i).db_link := c.warehouse_to_instance_link;


    -- --------------------------------------------------
    -- Check if we should load data from that instance
    -- Currently, we just check if the fii_ar_oltp_open_inv_v
    -- exist on the instance and has data.  This is a bit
    -- cludgy but is a temporary solution until we build
    -- the AR Installment Base Fact
    -- --------------------------------------------------
    BEGIN

      l_stmt := 'select sob_id from fii_ar_oltp_open_inv_v@'||
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
-- PROCEDURE Extract_OLTP_OPEN_INV
---------------------------------------------------
Procedure Extract_OLTP_OPEN_INV is
  l_stmt varchar2(1000);
Begin

  -- ------------------------
  -- Create the table needed
  -- ------------------------
  l_stmt := 'create table '||g_fii_schema||'.FII_AR_OLTP_OPEN_INV(
	instance_code		varchar2(30),
	org_id			number,
	sob_id			number,
	customer_site_id	number,
	receivable_g		number,
	receivable_b		number,
	receivable_t		number,
	unapp_receipt_g		number,
	unapp_receipt_b		number,
	unapp_receipt_t		number,
	functional_currency	varchar2(15),
	invoice_currency	varchar2(15),
	invoice_number		varchar2(30),
	installment_number 	number,
	invoice_date		date,
	due_date		date,
	type			varchar2(1))
	TABLESPACE '||g_tablespace||'
	NOLOGGING PCTFREE 5
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
      l_stmt := 'insert into '||g_fii_schema||'.FII_AR_OLTP_OPEN_INV T
	(instance_code,
	org_id,
	sob_id,
	customer_site_id,
	receivable_g,
	receivable_b,
	receivable_t,
	unapp_receipt_g,
	unapp_receipt_b,
	unapp_receipt_t,
	functional_currency,
	invoice_currency,
	invoice_number,
	installment_number,
	invoice_date,
	due_date,
	type)
      select /*+ DRIVING_SITE(INV) */
	instance_code,
	org_id,
	sob_id,
	customer_site_id,
	receivable_g,
	receivable_b,
	receivable_t,
	unapp_receipt_g,
	unapp_receipt_b,
	unapp_receipt_t,
	functional_currency,
	invoice_currency,
	invoice_number,
	installment_number,
	invoice_date,
	due_date,
	type
      from
	fii_ar_oltp_open_inv_v';

      IF (g_rec(i).same_inst) THEN
        l_stmt := l_stmt||' CASH ';
      ELSE
        l_stmt := l_stmt||'@'||g_rec(i).db_link||' INV ';
      END IF;

      if g_debug_flag = 'Y' then
      	edw_log.debug_line('');
      	edw_log.debug_line(l_stmt);
      end if;

      execute immediate l_stmt;

     commit;

    END IF;  -- g_rec(i).valid

  END LOOP;

End Extract_OLTP_OPEN_INV;



--------------------------------------------------
-- PROCEDURE Populate_RISK_INDICATOR
---------------------------------------------------
procedure Populate_RISK_INDICATOR is
  l_stmt 	VARCHAR2(4000);
Begin


  -- --------------------------------------
  -- Populate open invoice installment fact
  -- --------------------------------------
  l_stmt := 'truncate table '||g_fii_schema||'.fii_ar_open_installment_f';

  if g_debug_flag = 'Y' then
  	edw_log.debug_line('');
  	edw_log.debug_line(l_stmt);
  end if;
  execute immediate l_stmt;


  l_stmt := 'insert into fii_ar_open_installment_f (
	functional_currency_fk_key,
	set_of_books_fk_key,
	operating_unit_fk_key,
	customer_fk_key,
	receivable_g,
	receivable_b,
	receivable_t,
	unapp_receipt_g,
	unapp_receipt_b,
	unapp_receipt_t,
	functional_currency,
	invoice_currency,
	customer_name,
	invoice_number,
	installment_number,
	invoice_date,
	due_date,
	date_of_snapshot,
	age_bucket,
	type,
	creation_date,
	last_update_date)
  select curr.crnc_currency_pk_key,
	 sob.fabk_fa_book_pk_key,
	 org.oper_operating_unit_pk_key,
	 cust.tprt_trade_partner_pk_key,
	 f.receivable_g,
	 f.receivable_b,
	 f.receivable_t,
	 f.unapp_receipt_g,
	 f.unapp_receipt_b,
	 f.unapp_receipt_t,
	 f.functional_currency,
	 f.invoice_currency,
	 cust.tprt_name,
	 f.invoice_number,
	 f.installment_number,
	 f.invoice_date,
	 f.due_date,
	 trunc(sysdate),
	 case when (f.due_date >= trunc(sysdate)) then 1
              when (f.due_date between trunc(sysdate)-30 and trunc(sysdate)-1) then 2
              when (f.due_date between trunc(sysdate)-60 and trunc(sysdate)-31) then 3
              when (f.due_date between trunc(sysdate)-90 and trunc(sysdate)-61) then 4
	      else 5 end,
	 f.type,
	 trunc(sysdate),
	 trunc(sysdate)
  from   '||g_fii_schema||'.fii_ar_oltp_open_inv f,
	 edw_gl_book_m		sob,
	 edw_currency_m		curr,
	 edw_organization_m	org,
	 edw_trd_partner_m	cust
  where  sob.fabk_fa_book_pk = to_char(f.sob_id)||''-''||f.instance_code
  and    curr.crnc_currency_pk_key > 0
  and    sob.fabk_fa_book_pk_key >  0
  and    org.oper_operating_unit_pk_key > 0
  and    cust.tprt_trade_partner_pk_key > 0
  and	 cust.tplo_tpartner_loc_pk = decode(f.customer_site_id, -1, ''NA_EDW'',
		to_char(f.customer_site_id)||''-''||f.instance_code||''-CUST_SITE_USE'' )
  and    org.orga_organization_pk = to_char(f.org_id)||''-''||f.instance_code
  and 	 curr.crnc_currency_pk = f.functional_currency' ;

  if g_debug_flag = 'Y' then
  	edw_log.debug_line('');
  	edw_log.debug_line(l_stmt);
  end if;
  execute immediate l_stmt;

  -- --------------------------------
  -- Populate org level summary
  -- --------------------------------
  l_stmt := 'truncate table '||g_fii_schema||'.fii_ar_risk_indicator_f';
  if g_debug_flag = 'Y' then
  	edw_log.debug_line('');
  	edw_log.debug_line(l_stmt);
  end if;
  execute immediate l_stmt;

  l_stmt := '
  insert into fii_ar_risk_indicator_f (
	functional_currency_fk_key,
	set_of_books_fk_key,
	operating_unit_fk_key,
	operating_unit_name,
	ship_bklg_amt_b,
	ship_bklg_amt_g,
	dlqt_bklg_amt_b,
	dlqt_bklg_amt_g,
	open_rec_amt_b,
	open_rec_amt_g,
	pastdue_rec_amt_b,
	pastdue_rec_amt_g,
	date_of_snapshot,
	creation_date,
	last_update_date)
  select
	a.functional_currency_fk_key,
	a.set_of_books_fk_key,
	a.operating_unit_fk_key,
	a.operating_unit_name,
	sum(a.ship_bklg_amt_b),
	sum(a.ship_bklg_amt_g),
	sum(a.dlqt_bklg_amt_b),
	sum(a.dlqt_bklg_amt_g),
	sum(open_rec_amt_b),
	sum(open_rec_amt_g),
	sum(pastdue_rec_amt_b),
	sum(pastdue_rec_amt_g),
	trunc(sysdate),
	trunc(sysdate),
	trunc(sysdate)
  from ( select a.functional_currency_fk_key,
		a.set_of_books_fk_key,
		a.operating_unit_fk_key,
		b.name operating_unit_name,
		0 ship_bklg_amt_b,
		0 ship_bklg_amt_g,
		0 dlqt_bklg_amt_b,
		0 dlqt_bklg_amt_g,
		a.receivable_b open_rec_amt_b,
		a.receivable_g  open_rec_amt_g,
		decode(a.age_bucket, 1, 0, a.receivable_b) pastdue_rec_amt_b,
		decode(a.age_bucket, 1, 0, a.receivable_g) pastdue_rec_amt_g
	 from	fii_ar_open_installment_f a,
		edw_orga_oper_unit_ltc b
	 where  b.operating_unit_pk_key = a.operating_unit_fk_key
     and    a.functional_currency_fk_key > 0
     and    a.operating_unit_fk_key > 0
     and    a.set_of_books_fk_key > 0
	 union all
	 select functional_currency_fk_key,
		set_of_books_fk_key,
		operating_unit_fk_key,
		operating_unit_name,
		ship_bklg_amt_b,
		ship_bklg_amt_g,
		dlqt_bklg_amt_b,
		dlqt_bklg_amt_g,
		0 open_rec_amt_b,
		0 open_rec_amt_g,
		0 pastdue_rec_amt_b,
		0 pastdue_rec_amt_g
	 from	isc_edw_backlog_sum1_f
     where  functional_currency_fk_key > 0
     and    set_of_books_fk_key > 0
     and    operating_unit_fk_key > 0) a
  group by	a.functional_currency_fk_key,
		a.set_of_books_fk_key,
		a.operating_unit_fk_key,
		a.operating_unit_name
  order by 	a.set_of_books_fk_key,
		a.operating_unit_fk_key';


  if g_debug_flag = 'Y' then
  	edw_log.debug_line('');
  	edw_log.debug_line(l_stmt);
  end if;
  execute immediate l_stmt;


End Populate_RISK_INDICATOR;




-- ---------------------------------
-- Public PROCEDURES AND FUNCTIONS
-- ---------------------------------

--------------------------------------------------
-- PROCEDURE Refresh Summary
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
--  IF (fnd_profile.value('EDW_DEBUG') = 'Y') THEN
     edw_log.g_debug := TRUE;
--  END IF;

  l_dir:=fnd_profile.value('EDW_LOGFILE_DIR');
  if l_dir is null then
    l_dir:='/sqlcom/log';
  end if;
  if g_debug_flag = 'Y' then
  	edw_log.put_names('FII_AR_RISK_INDICATOR_F.log','FII_AR_RISK_INDICATOR_F.out',l_dir);


  	fii_util.put_timestamp;
  	edw_log.put_line('Initialization');
  	fii_util.start_timer;
  end if;
  Init;
  Drop_table('FII_AR_OLTP_OPEN_INV');
  if g_debug_flag = 'Y' then
  	fii_util.stop_timer;
  	fii_util.print_timer('Duration');

 	 fii_util.put_timestamp;
  	edw_log.put_line('Summarzing OE backlog information');
  	fii_util.start_timer;
  end if;
-- DEBUG
  isc_edw_backlog_sum1_f_c.Populate(l_errbuf, l_retcode);
  if g_debug_flag = 'Y' then
  	fii_util.stop_timer;
  	fii_util.print_timer('Duration');


  	edw_log.put_line('');
  	edw_log.put_line('Extracting Open Invoice Installments');
  	fii_util.start_timer;
  end if;
  Extract_OLTP_OPEN_INV;
  if g_debug_flag = 'Y' then
  	fii_util.stop_timer;
  	fii_util.print_timer('Duration');

  	edw_log.put_line('');
  	edw_log.put_line('Summarizing into AR Risk Summary Table');
  	fii_util.start_timer;
  end if;
  Populate_RISK_INDICATOR;
  if g_debug_flag = 'Y' then
  	fii_util.stop_timer;
  	fii_util.print_timer('Duration');
  end if;

  Drop_table('FII_AR_OLTP_OPEN_INV');

END Refresh_Summary;



End FII_AR_RISK_PKG;

/
