--------------------------------------------------------
--  DDL for Package Body FII_AP_TRANS_BACKLOG_SUM_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_TRANS_BACKLOG_SUM_C" AS
/* $Header: FIIAP13B.pls 120.1 2005/06/13 11:11:37 sgautam noship $ */

   g_debug_flag  VARCHAR2(1) := NVL(FND_PROFILE.value('EDW_DEBUG'), 'N');
   g_fii_schema   VARCHAR2(30);
   g_tablespace    VARCHAR2(30);

   g_errbuf      VARCHAR2(2000) := NULL;
   g_retcode     VARCHAR2(200) := NULL;
   g_exception_msg  VARCHAR2(200) := NULL;
   g_today DATE;

--------------------------------------------------
-- PROCEDURE POPULATE_FII_AP_TR_BLG_SUMMARY
---------------------------------------------------
procedure POPULATE_FII_AP_TR_BLG_SUMMARY is
  l_stmt    VARCHAR2(6000);
  l_state   VARCHAR2(100);
Begin

  if g_debug_flag = 'Y' then
  	edw_log.put_line('Truncate table FII_AP_TRANS_BACKLOG_SUMMARY');
  end if;

  l_state := 'Truncate FII_AP_TRANS_BACKLOG_SUMMARY';
  l_stmt := 'truncate table '||g_fii_schema||'.FII_AP_TRANS_BACKLOG_SUMMARY';

   if g_debug_flag = 'Y' then
  	edw_log.debug_line('');
  	edw_log.debug_line(l_stmt);
   end if;
  execute immediate l_stmt;

  if g_debug_flag = 'Y' then
  	edw_log.put_line('Populate table FII_AP_TRANS_BACKLOG_SUMMARY');
  end if;
  l_state := 'Insert into FII_AP_TRANS_BACKLOG_SUMMARY';
  l_stmt := 'insert into '||g_fii_schema||'.FII_AP_TRANS_BACKLOG_SUMMARY (
                     operating_unit_pk_key,
						   operating_unit_name,
                     trading_partner_pk_key,
                     trading_partner_name,
                     sch_payment_id,
                     open_payment_amount,
                     invoice_pk_key,
                     invoice_num,
                     invoice_amount,
                     payment_due_date,
                     invoice_date,
                     days_outstanding)
              select org.oper_operating_unit_pk_key OPERATING_UNIT_PK_KEY,
                     org.oper_name OPERATING_UNIT_NAME,
                     partner.tprt_trade_partner_pk_key TRADING_PARTNER_PK_KEY,
                     partner.tprt_name TRADING_PARTNER_NAME,
                     schp.sch_payment_pk_key SCH_PAYMENT_ID,
                     nvl(schp.REMAINING_INV_AMT_AT_RISK_G,0) OPEN_PAYMENT_AMOUNT,
                     schp.inv_fk_key INVOICE_PK_KEY,
                     schp.invoice_num INVOICE_NUM,
                     decode(schp.inv_amt_having_disc_g,0, schp.inv_amt_not_having_disc_g,
                            schp.inv_amt_having_disc_g) INVOICE_AMOUNT,
                     schp.due_date PAYMENT_DUE_DATE,
                     time.calendar_date INVOICE_DATE,
                     round(to_date(''' || to_char(g_today,'DD-MM-YYYY') || ''',''DD-MM-YYYY'') - schp.due_date) days_outstanding
              from fii_ap_sch_paymts_f schp,
                   edw_organization_m org,
                   edw_time_cal_day_ltc time,
                   edw_trd_partner_m partner
              WHERE schp.REMAINING_INV_AMT_AT_RISK_G > 0
              AND schp.payment_status_flag <> ''Y''
              AND schp.due_date <= to_date('''||to_char(g_today,'DD-MM-YYYY')||''',''DD-MM-YYYY'')
              AND schp.inv_date_fk_key = time.CAL_DAY_PK_KEY
              AND schp.org_fk_key = org.ORGA_ORGANIZATION_PK_KEY
              AND schp.org_fk_key > 0
              AND schp.supplier_fk_key = partner.tplo_tpartner_loc_pk_key
              AND schp.supplier_fk_key > 0
              AND schp.inv_fk_key > 0';

  if g_debug_flag = 'Y' then
  	edw_log.debug_line('');
  	edw_log.debug_line(l_stmt);
  end if;
  execute immediate l_stmt;

  if g_debug_flag = 'Y' then
  	edw_log.put_line('Inserted ' || sql%rowcount || ' rows into FII_AP_TRANS_BACKLOG_SUMMARY');
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

END POPULATE_FII_AP_TR_BLG_SUMMARY;

----------------------------------------------------------
--  PROCEDURE LOAD
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
  	edw_log.put_names('FII_AP_TR_BKLG_SUMMARY.log','FII_AP_TR_BKLG_SUMMARY.out',l_dir);


  	fii_util.put_timestamp;
  end if;

  -- --------------------------------------------------------
  -- Find the schema owner and tablespace
  -- FII_AP_TRANS_BACKLOG_SUMMARY is using
  -- --------------------------------------------------------
  IF(FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, g_fii_schema))
  THEN NULL;
  END IF;

  SELECT tablespace_name
  INTO   g_tablespace
  FROM   all_tables
  WHERE  table_name = 'FII_AP_TRANS_BACKLOG_SUMMARY'
  AND    owner = g_fii_schema;

  g_today := FII_TIME_WH_API.today;

   if g_debug_flag = 'Y' then
  	fii_util.start_timer;
   end if;

  POPULATE_FII_AP_TR_BLG_SUMMARY;

  if g_debug_flag = 'Y' then
  	fii_util.stop_timer;
  	fii_util.print_timer('Duration');
  end if;

EXCEPTION
   WHEN OTHERS THEN
     raise;
END Load;

END FII_AP_TRANS_BACKLOG_SUM_C;

/
