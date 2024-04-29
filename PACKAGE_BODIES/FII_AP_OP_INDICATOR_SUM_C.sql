--------------------------------------------------------
--  DDL for Package Body FII_AP_OP_INDICATOR_SUM_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_OP_INDICATOR_SUM_C" AS
/* $Header: FIIAP12B.pls 120.2 2005/06/13 10:58:56 sgautam noship $ */

	g_debug_flag VARCHAR2(1) := NVL(FND_PROFILE.value('EDW_DEBUG'), 'N');

	g_fii_schema   VARCHAR2(30);
	g_tablespace    VARCHAR2(30);

 	g_errbuf      VARCHAR2(2000) := NULL;
 	g_retcode     VARCHAR2(200) := NULL;
   g_exception_msg  VARCHAR2(200) := NULL;
   g_cur_qtr_start_date DATE;
   g_today DATE;

	G_TABLE_NOT_EXIST      EXCEPTION;
	PRAGMA EXCEPTION_INIT(G_TABLE_NOT_EXIST, -942);

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

Exception
  WHEN G_TABLE_NOT_EXIST THEN
    null;      -- Oracle 942, table does not exist, no actions
  WHEN OTHERS THEN
    raise;
End Drop_Table;

--------------------------------------------------
-- PROCEDURE CREATE_FII_AP_OP_IND_SUM_TEMP
---------------------------------------------------
procedure CREATE_FII_AP_OP_IND_SUM_TEMP is
  l_stmt    VARCHAR2(4000);
  l_state VARCHAR2(200);
Begin
   drop_table('FII_AP_OP_IND_SUMMARY_TEMP1');
   drop_table('FII_AP_OP_IND_SUMMARY_TEMP2');

   if g_debug_flag = 'Y' then
   	edw_log.put_line('Creating FII_AP_OP_IND_SUMMARY_TEMP tables');
   end if;

   l_state := 'Create FII_AP_OP_IND_SUMMARY_TEMP1';
	l_stmt := 'create table '||g_fii_schema||'.FII_AP_OP_IND_SUMMARY_TEMP1(
                  operating_unit_pk_key NUMBER,
                  operating_unit_name VARCHAR2(150),
                  trading_partner_pk_key NUMBER,
                  trading_partner_name VARCHAR2(120),
                  inv_lines_count NUMBER,
                  inv_count NUMBER,
                  inv_amount NUMBER)
                  TABLESPACE '||g_tablespace||'
                  PCTFREE 5
                  storage (INITIAL 4K NEXT 32K)';

    if g_debug_flag = 'Y' then
    	edw_log.debug_line('');
    	edw_log.debug_line(l_stmt);
    end if;
    execute immediate l_stmt;

    l_state := 'Create FII_AP_OP_IND_SUMMARY_TEMP2';
    l_stmt := 'create table '||g_fii_schema||'.FII_AP_OP_IND_SUMMARY_TEMP2(
                  operating_unit_pk_key NUMBER,
                  operating_unit_name VARCHAR2(150),
                  trading_partner_pk_key NUMBER,
                  trading_partner_name VARCHAR2(120),
                  inv_payment_count NUMBER,
                  inv_payment_amount NUMBER)
                  TABLESPACE '||g_tablespace||'
                  PCTFREE 5
                  storage (INITIAL 4K NEXT 32K)';

	if g_debug_flag = 'Y' then
    		edw_log.debug_line('');
    		edw_log.debug_line(l_stmt);
        end if;
    execute immediate l_stmt;

	if g_debug_flag = 'Y' then
    		edw_log.put_line('Populating FII_AP_OP_IND_SUMMARY_TEMP tables');
    	end if;

    -- --------------------------------------
    -- Populate FII_AP_OP_IND_SUMMARY_TEMP tables
    -- --------------------------------------
    l_state := 'Populate FII_AP_OP_IND_SUMMARY_TEMP1';
    l_stmt := 'INSERT INTO '||g_fii_schema||'.FII_AP_OP_IND_SUMMARY_TEMP1 (
               operating_unit_pk_key,
               operating_unit_name,
               trading_partner_pk_key,
               trading_partner_name,
               inv_lines_count,
               inv_count,
               inv_amount)
     SELECT org.OPER_OPERATING_UNIT_PK_KEY operating_unit_pk_key,
            org.oper_name operating_unit_name,
            partner.TPRT_TRADE_PARTNER_PK_KEY trading_partner_pk_key,
            partner.tprt_name trading_partner_name,
            count(invl.inv_line_pk_key) inv_lines_count,
            count(distinct invl.inv_fk_key) inv_count,
            sum(nvl(invl.inv_line_amt_g, 0)) inv_amount
     FROM  fii_ap_inv_lines_f invl,
           edw_organization_m org,
           edw_trd_partner_m partner
     WHERE invl.org_fk_key = org.orga_organization_pk_key
     AND   invl.org_fk_key > 0
     AND   invl.supplier_fk_key = partner.TPLO_TPARTNER_LOC_PK_KEY
     AND   invl.supplier_fk_key > 0
     AND   invl.inv_date between to_date('''
          ||to_char(g_cur_qtr_start_date, 'DD-MM-YYYY')
          ||''', ''DD-MM-YYYY'') and  to_date('''
          || to_char(g_today, 'DD-MM-YYYY') || ''', ''DD-MM-YYYY'')
     GROUP BY org.OPER_OPERATING_UNIT_PK_KEY,
              org.oper_name,
              partner.TPRT_TRADE_PARTNER_PK_KEY,
              partner.tprt_name';

    if g_debug_flag = 'Y' then
   	edw_log.debug_line('');
    	edw_log.debug_line(l_stmt);
    end if;
    execute immediate l_stmt;

    if g_debug_flag = 'Y' then
    	edw_log.debug_line('Inserted ' || sql%rowcount || ' rows into FII_AP_OP_IND_SUMMARY_TEMP1');
    end if;

    l_state := 'Populate FII_AP_OP_IND_SUMMARY_TEMP2';
    l_stmt := 'INSERT INTO '||g_fii_schema||'.FII_AP_OP_IND_SUMMARY_TEMP2 (
               operating_unit_pk_key,
               operating_unit_name,
               trading_partner_pk_key,
               trading_partner_name,
               inv_payment_amount,
               inv_payment_count)
	 select org.OPER_OPERATING_UNIT_PK_KEY operating_unit_pk_key,
           org.oper_name operating_unit_name,
           partner.TPRT_TRADE_PARTNER_PK_KEY trading_partner_pk_key,
           partner.tprt_name trading_partner_name,
           sum(nvl(invp.payment_amt_g, 0)) inv_payment_amount,
           count(invp.inv_payment_pk) inv_payment_count
    from  fii_ap_inv_paymts_f invp,
          edw_organization_m org,
          edw_trd_partner_m partner
    WHERE invp.org_fk_key = org.orga_organization_pk_key
    AND   invp.org_fk_key > 0
    AND   invp.supplier_fk_key = partner.TPLO_TPARTNER_LOC_PK_KEY
    AND   invp.supplier_fk_key > 0
    AND   invp.creation_date between to_date('''
          ||to_char(g_cur_qtr_start_date, 'DD-MM-YYYY')
          ||''', ''DD-MM-YYYY'') and  to_date('''
          || to_char(g_today, 'DD-MM-YYYY') || ''', ''DD-MM-YYYY'')
    GROUP BY org.OPER_OPERATING_UNIT_PK_KEY,
             org.oper_name,
             partner.TPRT_TRADE_PARTNER_PK_KEY,
             partner.tprt_name';

	if g_debug_flag = 'Y' then
    		edw_log.debug_line('');
    		edw_log.debug_line(l_stmt);
    	end if;
    execute immediate l_stmt;

   if g_debug_flag = 'Y' then
    edw_log.debug_line('Inserted ' || sql%rowcount || ' rows into FII_AP_OP_IND_SUMMARY_TEMP2');
   end if;

EXCEPTION
	WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:=sqlcode;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      if g_debug_flag = 'Y' then
      	edw_log.put_line('Error occured while ' || l_state);
      	edw_log.put_line(g_exception_msg);
      end if;
		raise;
END CREATE_FII_AP_OP_IND_SUM_TEMP;

--------------------------------------------------
-- PROCEDURE POPULATE_FII_AP_OP_IND_SUMMARY
---------------------------------------------------
procedure POPULATE_FII_AP_OP_IND_SUMMARY is
  l_stmt    VARCHAR2(6000);
  l_state   VARCHAR2(100);
Begin

  if g_debug_flag = 'Y' then
  	edw_log.put_line('Truncate table FII_AP_OP_INDICATOR_SUMMARY');
  end if;
  l_state := 'Truncate FII_AP_OP_INDICATOR_SUMMARY';
  l_stmt := 'truncate table '||g_fii_schema||'.FII_AP_OP_INDICATOR_SUMMARY';

  if g_debug_flag = 'Y' then
 	 edw_log.debug_line('');
  	edw_log.debug_line(l_stmt);
  end if;
  execute immediate l_stmt;

  if g_debug_flag = 'Y' then
  	edw_log.put_line('Populate table FII_AP_OP_INDICATOR_SUMMARY');
  end if;
  l_state := 'Insert into FII_AP_OP_INDICATOR_SUMMARY';
  l_stmt := 'insert into '||g_fii_schema||'.FII_AP_OP_INDICATOR_SUMMARY (
                    operating_unit_pk_key,
                    operating_unit_name,
                    trading_partner_pk_key,
                    trading_partner_name,
                    inv_lines_count,
                    inv_count,
                    inv_amount,
                    inv_payment_count,
                    inv_payment_amount)
				 select f.operating_unit_pk_key,
                    f.operating_unit_name,
                    f.trading_partner_pk_key,
                    f.trading_partner_name,
                    sum(f.inv_lines_count),
                    sum(f.inv_count),
                    sum(f.inv_amount),
                    sum(f.inv_payment_count),
                    sum(f.inv_payment_amount)
             FROM  (select operating_unit_pk_key,
                           operating_unit_name,
                           trading_partner_pk_key,
                           trading_partner_name,
                           inv_amount,
                           inv_lines_count,
                           inv_count,
                           0 inv_payment_amount,
                           0 inv_payment_count
                    FROM ' ||g_fii_schema||'.fii_ap_op_ind_summary_temp1
                    UNION ALL
                    SELECT operating_unit_pk_key,
                           operating_unit_name,
                           trading_partner_pk_key,
                           trading_partner_name,
                           0 inv_amount,
                           0 inv_lines_count,
                           0 inv_count,
                           inv_payment_amount,
                           inv_payment_count
                    FROM ' ||g_fii_schema||'.fii_ap_op_ind_summary_temp2) f
             GROUP BY f.operating_unit_pk_key,
                      f.operating_unit_name,
                      f.trading_partner_pk_key,
                      f.trading_partner_name';

  if g_debug_flag = 'Y' then
  	edw_log.debug_line('');
  	edw_log.debug_line(l_stmt);
  end if;
  execute immediate l_stmt;

  if g_debug_flag = 'Y' then
  	edw_log.put_line('Inserted ' || sql%rowcount || ' rows into FII_AP_OP_INDICATOR_SUMMARY');
  end if;

  l_state := 'Drop FII_AP_OP_IND_SUMMARY_TEMP tables';
  DROP_TABLE('FII_AP_OP_IND_SUMMARY_TEMP1');
  DROP_TABLE('FII_AP_OP_IND_SUMMARY_TEMP2');
EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:=sqlcode;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      if g_debug_flag = 'Y' then
      	edw_log.put_line('Error occured while ' || l_state);
      	edw_log.put_line(g_exception_msg);
      end if;
      raise;

END POPULATE_FII_AP_OP_IND_SUMMARY;

-----------------------------------------------------------
--  PROCEDURE Load
-----------------------------------------------------------
Procedure Load (Errbuf IN OUT   NOCOPY VARCHAR2,
           Retcode   IN OUT   NOCOPY VARCHAR2) IS
  l_status     VARCHAR2(30);
  l_industry      VARCHAR2(30);
  l_stmt          VARCHAR2(4000);
  l_dir        VARCHAR2(100);
Begin

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
  	edw_log.put_names('FII_AP_OP_IND_SMMARY.log','FII_AP_OP_IND_SUMMARY.out',l_dir);
  end if;

  if g_debug_flag = 'Y' then
  	fii_util.put_timestamp;
  end if;

  -- --------------------------------------------------------
  -- Find the schema owner and tablespace
  -- FII_AP_OP_INDICATOR_SUMMARY is using
  -- --------------------------------------------------------
  IF(FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, g_fii_schema))
  THEN NULL;
  END IF;

  SELECT tablespace_name
  INTO   g_tablespace
  FROM   all_tables
  WHERE  table_name = 'FII_AP_OP_INDICATOR_SUMMARY'
  AND    owner = g_fii_schema;

  if g_debug_flag = 'Y' then
  	edw_log.put_line('Getting current quarter start date');
  end if;
  if g_debug_flag = 'Y' then
  	fii_util.start_timer;
  end if;
  g_cur_qtr_start_date := FII_TIME_WH_API.get_curr_eqtr_start;
  g_today := FII_TIME_WH_API.today;

  if g_debug_flag = 'Y' then
  	fii_util.stop_timer;
  	fii_util.print_timer('Duration');

  	fii_util.start_timer;
  end if;
  CREATE_FII_AP_OP_IND_SUM_TEMP;
  if g_debug_flag = 'Y' then
  	fii_util.stop_timer;
  	fii_util.print_timer('Duration');

  	fii_util.start_timer;
  end if;

  POPULATE_FII_AP_OP_IND_SUMMARY;
  if g_debug_flag = 'Y' then
  	fii_util.stop_timer;
  	fii_util.print_timer('Duration');
  end if;

EXCEPTION
	WHEN OTHERS THEN
	  raise;
END Load;

END FII_AP_OP_INDICATOR_SUM_C;

/
