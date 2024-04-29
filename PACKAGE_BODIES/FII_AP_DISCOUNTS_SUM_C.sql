--------------------------------------------------------
--  DDL for Package Body FII_AP_DISCOUNTS_SUM_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_DISCOUNTS_SUM_C" AS
/* $Header: FIIAP14B.pls 120.1 2005/06/13 11:14:23 sgautam noship $ */

   g_debug_flag   VARCHAR2(1) := NVL(FND_PROFILE.value('EDW_DEBUG'), 'N');
   g_fii_schema   VARCHAR2(30);
   g_tablespace    VARCHAR2(30);

   g_errbuf      VARCHAR2(2000) := NULL;
   g_retcode     VARCHAR2(200) := NULL;
   g_exception_msg  VARCHAR2(200) := NULL;
   g_cur_qtr_start_date DATE;
   g_cur_qtr_end_date DATE;
   g_today DATE;

--------------------------------------------------
-- PROCEDURE POPULATE_FII_AP_DISC_SUMMARY
---------------------------------------------------
procedure POPULATE_FII_AP_DISC_SUMMARY is
  l_stmt    VARCHAR2(6000);
  l_state   VARCHAR2(100);
Begin

  if g_debug_flag = 'Y' then
  	edw_log.put_line('Truncate table FII_AP_DISCOUNTS_SUMMARY');
  end if;
  l_state := 'Truncate FII_AP_DISCOUNTS_SUMMARY';
  l_stmt := 'truncate table '||g_fii_schema||'.FII_AP_DISCOUNTS_SUMMARY';

  if g_debug_flag = 'Y' then
  	edw_log.debug_line('');
  	edw_log.debug_line(l_stmt);
  end if;
  execute immediate l_stmt;

  if g_debug_flag = 'Y' then
  	edw_log.put_line('Populate table FII_AP_DISCOUNTS_SUMMARY');
  end if;
  l_state := 'Insert into FII_AP_DISCOUNTS_SUMMARY';
  l_stmt := 'insert into '||g_fii_schema||'.FII_AP_DISCOUNTS_SUMMARY (
       				   OPERATING_UNIT_PK_KEY,
                     OPERATING_UNIT_NAME,
                     TRADING_PARTNER_PK_KEY,
                     TRADING_PARTNER_NAME,
                     RECORD_ID,
                     INVOICE_NUM,
                     INVOICE_DATE,
                     INVOICE_UNIQUE_IDENTIFIER,
                     INVOICE_AMOUNT,
                     DISCOUNT_AVAILABLE,
                     DISCOUNT_LOST,
                     DISCOUNT_DATE,
                     RECORD_TYPE)
              select org.oper_operating_unit_pk_key OPERATING_UNIT_PK_KEY,
                     org.oper_name OPERATING_UNIT_NAME,
                     partner.tprt_trade_partner_pk_key TRADING_PARTNER_PK_KEY,
                     partner.tprt_name TRADING_PARTNER_NAME,
                     invp.inv_payment_pk RECORD_ID,
                     invp.inv_num INVOICE_NUM,
                     to_date(NULL) INVOICE_DATE,
                     invp.inv_fk_key INVOICE_UNIQUE_IDENTIFIER,
                     NVL(invp.payment_amt_g,0) INVOICE_AMOUNT,
                     0 DISCOUNT_AVAILABLE,
                     NVL(invp.disc_amt_lost_g,0) DISCOUNT_LOST,
                     to_date(NULL) DISCOUNT_DATE,
                     ''L'' RECORD_TYPE
               from  fii_ap_inv_paymts_f invp,
                     edw_organization_m org,
                     edw_trd_partner_m partner
               WHERE invp.check_date between to_date('''
                        ||to_char(g_cur_qtr_start_date, 'DD-MM-YYYY')
                        ||''', ''DD-MM-YYYY'') and  to_date('''
                        || to_char(g_today, 'DD-MM-YYYY') || ''', ''DD-MM-YYYY'')
               AND   invp.org_fk_key = org.orga_organization_pk_key
               AND   invp.org_fk_key > 0
               AND   invp.supplier_fk_key = partner.tplo_tpartner_loc_pk_key
               AND   invp.supplier_fk_key > 0
               AND   NVL(invp.disc_amt_lost_g,0) > 0
               UNION ALL
               select org.oper_operating_unit_pk_key OPERATING_UNIT_PK_KEY,
                      org.oper_name OPERATING_UNIT_NAME,
                      partner.tprt_trade_partner_pk_key TRADING_PARTNER_PK_KEY,
                      partner.tprt_name TRADING_PARTNER_NAME,
                      schp.sch_payment_pk RECORD_ID,
                      schp.invoice_num INVOICE_NUM,
                      time.calendar_date INVOICE_DATE,
                      schp.inv_fk_key INVOICE_UNIQUE_IDENTIFIER,
                      decode(schp.inv_amt_having_disc_g,0, schp.inv_amt_not_having_disc_g,
                             schp.inv_amt_having_disc_g) INVOICE_AMOUNT,
                      NVL(schp.remaining_disc_amt_at_risk_g,0) DISCOUNT_AVAILABLE,
                      0 DISCOUNT_LOST,
                      DECODE(sign(first_disc_date-to_date('''||to_char(g_today,'DD-MM-YYYY')||''',''DD-MM-YYYY'')),1,first_disc_date,
                             0,first_disc_date,
                            (DECODE(sign(second_disc_date-to_date('''||to_char(g_today,'DD-MM-YYYY')||''',''DD-MM-YYYY'')),1,second_disc_date,
                                    0, second_disc_date,third_disc_date))) DISCOUNT_DATE,
                      ''R'' RECORD_TYPE
                from  fii_ap_sch_paymts_f schp,
                      edw_organization_m org,
                      edw_time_cal_day_ltc time,
                      edw_trd_partner_m partner
                 WHERE schp.org_fk_key = org.orga_organization_pk_key
                 AND   schp.org_fk_key > 0
                 AND   schp.supplier_fk_key = partner.tplo_tpartner_loc_pk_key
                 AND   schp.supplier_fk_key > 0
                 AND   NVL(schp.remaining_disc_amt_at_risk_g,0) > 0
                 AND   schp.inv_date_fk_key = time.CAL_DAY_PK_KEY
                 AND   (schp.first_disc_date between to_date(''' ||to_char(g_today,'DD-MM-YYYY')||''',''DD-MM-YYYY'')
                       and to_date('''||to_char(g_cur_qtr_end_date,'DD-MM-YYYY')||''',''DD-MM-YYYY'') OR
                       schp.second_disc_date between to_date(''' ||to_char(g_today,'DD-MM-YYYY')||''',''DD-MM-YYYY'')
                       and to_date('''||to_char(g_cur_qtr_end_date,'DD-MM-YYYY')||''',''DD-MM-YYYY'') OR
                       schp.third_disc_date between to_date(''' ||to_char(g_today,'DD-MM-YYYY')|| ''',''DD-MM-YYYY'')
                       and to_date('''||to_char(g_cur_qtr_end_date,'DD-MM-YYYY')||''',''DD-MM-YYYY''))';

  if g_debug_flag = 'Y' then
  	edw_log.debug_line('');
  	edw_log.debug_line(l_stmt);
  end if;
  execute immediate l_stmt;

  if g_debug_flag = 'Y' then
  	edw_log.put_line('Inserted ' || sql%rowcount || ' rows into FII_AP_DISCOUNTS_SUMMARY');
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

END POPULATE_FII_AP_DISC_SUMMARY;

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
  -- FII_AP_DISCOUNTS_SUMMARY is using
  -- --------------------------------------------------------
  IF(FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, g_fii_schema))
  THEN NULL;
  END IF;

  SELECT tablespace_name
  INTO   g_tablespace
  FROM   all_tables
  WHERE  table_name = 'FII_AP_DISCOUNTS_SUMMARY'
  AND    owner = g_fii_schema;

  if g_debug_flag = 'Y' then
  	edw_log.put_line('Getting current quarter start date and end date');
  	fii_util.start_timer;
  end if;
  g_cur_qtr_start_date := FII_TIME_WH_API.get_curr_eqtr_start;
  g_cur_qtr_end_date := FII_TIME_WH_API.get_curr_eqtr_end;
  g_today := FII_TIME_WH_API.today;
  if g_debug_flag = 'Y' then
  	fii_util.stop_timer;
  	fii_util.print_timer('Duration');

  	fii_util.start_timer;
  end if;
  POPULATE_FII_AP_DISC_SUMMARY;
  if g_debug_flag = 'Y' then
  	fii_util.stop_timer;
  	fii_util.print_timer('Duration');
  end if;

EXCEPTION
   WHEN OTHERS THEN
     raise;
END Load;

END FII_AP_DISCOUNTS_SUM_C;

/
