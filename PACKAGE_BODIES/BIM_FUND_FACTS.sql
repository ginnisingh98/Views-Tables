--------------------------------------------------------
--  DDL for Package Body BIM_FUND_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_FUND_FACTS" AS
/* $Header: bimbgtfb.pls 120.4 2005/11/11 05:27:54 arvikuma noship $*/

G_PKG_NAME  CONSTANT  VARCHAR2(20) :='BIM_FUND_FACTS';
G_FILE_NAME CONSTANT  VARCHAR2(20) :='bimbgtfb.pls';
l_to_currency  VARCHAR2(100) := fnd_profile.value('AMS_DEFAULT_CURR_CODE');
l_conversion_type VARCHAR2(30):= fnd_profile.VALUE('AMS_CURR_CONVERSION_TYPE');
---------------------------------------------------------------------
-- FUNCTION
--    Convert_Currency
-- NOTE: Given from currency, from amount, converts to default currency amount.
--       Default currency can be get from profile value.
-- PARAMETER
--   p_from_currency      IN  VARCHAR2,
--   p_to_currency        IN  VARCHAR2,
--   p_from_amount        IN  NUMBER,
-- RETURN   NUMBER
---------------------------------------------------------------------
FUNCTION  convert_currency(
   p_from_currency          VARCHAR2  ,
   p_from_amount            NUMBER) return NUMBER
IS
   l_user_rate                  CONSTANT NUMBER       := 1;
   l_max_roll_days              CONSTANT NUMBER       := -1;
   l_denominator      NUMBER;   -- Not used in Marketing.
   l_numerator        NUMBER;   -- Not used in Marketing.
   l_to_amount    NUMBER;
   l_rate         NUMBER;
BEGIN

     -- Conversion type cannot be null in profile
     IF l_conversion_type IS NULL THEN
       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_EXCHANGE_TYPE');
         fnd_msg_pub.add;
       END IF;
       RETURN 0;
     END IF;

   -- Call the proper GL API to convert the amount.
   gl_currency_api.convert_closest_amount(
      x_from_currency => p_from_currency
     ,x_to_currency => l_to_currency
     ,x_conversion_date =>sysdate
     ,x_conversion_type => l_conversion_type
     ,x_user_rate => l_user_rate
     ,x_amount => p_from_amount
     ,x_max_roll_days => l_max_roll_days
     ,x_converted_amount => l_to_amount
     ,x_denominator => l_denominator
     ,x_numerator => l_numerator
     ,x_rate => l_rate);
RETURN (l_to_amount);
EXCEPTION
   WHEN gl_currency_api.no_rate THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_RATE');
         fnd_msg_pub.add;
      END IF;
      RETURN 0;
   WHEN gl_currency_api.invalid_currency THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_CURR');
         fnd_msg_pub.add;
      END IF;
      RETURN 0;
   WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg('OZF_UTLITY_PVT', 'Convert_curency');
      END IF;
      RETURN 0;
END convert_currency;

---------------------------------------------------------------------
-- PROCEDURE
--    update_balance
-- NOTE: This procedure will be called only once within FUND_FIRST_LOAD
--       It inserts data into bim_r_fund_balance, which is a daily balance
--       table. It gathers data from bim_r_fund_daily_facts,
--       and bim_r_fdsp_daily_facts. Calculates balance based on data from
--       those two tables.
---------------------------------------------------------------------
PROCEDURE update_balance
IS
l_id number;
l_week DATE;
l_index_tablespace varchar2(100);

/*cursor balance_cur is to get all the fund_id, and all the
  transaction date excluding the minimum date. */
CURSOR balance_cur IS
SELECT fund_id,week_date
FROM bim_r_fund_balance a
WHERE exists --week_date not in
( SELECT /*+ index_desc(b,bim_r_fund_balance_n6) */ null
  FROM bim_r_fund_balance b
  WHERE b.fund_id = a.fund_id
  AND   b.week_date < a.week_date )
order by fund_id, week_date ;


/*cursor min_date is to get all the info about each fund's minimum date.
  ie. the initial balance would be the original budget*/
CURSOR min_date IS
SELECT b.fund_id fund_id,
       c.week_date week_date,
       nvl(b.original_budget,0) original,
       nvl(b.original_budget,0)+nvl(b.transfer_in,0)-nvl(b.transfer_out,0) available,
       nvl(c.commited_amt,0) commited,
       nvl(c.commited_amt,0) commited_sum,
       nvl(b.original_budget,0)+nvl(b.transfer_in,0)-nvl(b.transfer_out,0)-nvl(c.commited_amt,0) balance,
       nvl(c.utilized_amt,0) utilized,
       nvl(c.planned,0) planned,
       nvl(c.paid,0) paid
FROM bim_r_fund_daily_facts b ,
      (SELECT
             c1.fund_id fund_id,
             c1.week_date week_date,
             SUM(nvl(fdsp.commited_amt,0)) commited_amt,
             SUM(nvl(fdsp.standard_discount,0)+nvl(fdsp.market_expense,0)+nvl(fdsp.accrual,0)) utilized_amt,
             SUM(nvl(fdsp.planned_amt,0)) planned,
             SUM(nvl(fdsp.paid_amt,0)) paid
       FROM   bim_r_fdsp_daily_facts fdsp,
             (SELECT fund_id fund_id,
                     MIN(transaction_create_date) week_date
              FROM   bim_r_fund_daily_facts
              GROUP BY fund_id) c1
       WHERE fdsp.fund_id(+) = c1.fund_id
       AND   fdsp.transaction_create_date(+) = c1.week_date
       GROUP BY c1.fund_id, c1.week_date ) c
WHERE b.fund_id = c.fund_id
AND   c.week_date = b.transaction_create_date;

    l_status                      VARCHAR2(5);
    l_industry                    VARCHAR2(5);
    l_schema                      VARCHAR2(30);
    l_return                       BOOLEAN;

    BEGIN
      l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);
  begin
  fnd_message.set_name('BIM','BIM_R_PROC_START');
  fnd_message.set_token('proc_name', 'UPDATE_BALANCE', FALSE);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
  EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fund_daily_facts noparallel';
  EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fdsp_daily_facts noparallel';
  EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fund_balance noparallel';
  exception
  WHEN OTHERS THEN
  ams_utility_pvt.write_conc_log('error alter tablebalance:'||sqlerrm(sqlcode));
   --dbms_output.put_line('error alter table balance'||sqlerrm(sqlcode));
   END;

  EXECUTE IMMEDIATE 'truncate table '||l_schema||'.bim_r_fund_balance';
  --dbms_output.put_line('inside update balance');

  --Insert all the fund_id, and transaction date to start with
  INSERT into BIM_R_FUND_BALANCE (fund_id, week_date,fis_month, fis_qtr, fis_year)
  SELECT fund_id,transaction_create_date,fis_month, fis_qtr, fis_year
  FROM bim_r_fund_daily_facts;


  select i.index_tablespace into l_index_tablespace
  from fnd_product_installations i, fnd_application a
  where a.application_short_name = 'BIM'
  and a.application_id = i.application_id;

  BEGIN
  EXECUTE IMMEDIATE 'drop index bim_r_fund_facts_n6';
  EXCEPTION
     WHEN OTHERS THEN
     null;
  END;

  BEGIN
  EXECUTE IMMEDIATE
  'create index bim_r_fund_facts_n6 on bim_r_fund_daily_facts
  (fund_id,
   transaction_create_date) tablespace '||l_index_tablespace||' compute statistics';
  EXCEPTION
     WHEN OTHERS THEN
     null;
  END;

  BEGIN
  EXECUTE IMMEDIATE 'drop index bim_r_fdsp_facts_n6';
  EXCEPTION
     WHEN OTHERS THEN
     null;
  END;

  BEGIN
  EXECUTE IMMEDIATE
  'create index bim_r_fdsp_facts_n6 on bim_r_fdsp_daily_facts
  (fund_id,
   transaction_create_date) tablespace '||l_index_tablespace||' compute statistics';
  EXCEPTION
     WHEN OTHERS THEN
     null;
  END;

  BEGIN
  EXECUTE IMMEDIATE 'drop index bim_r_fund_balance_n6';
  EXCEPTION
     WHEN OTHERS THEN
     null;
  END;

  BEGIN
  EXECUTE IMMEDIATE 'create index bim_r_fund_balance_n6 on
  bim_r_fund_balance(fund_id,week_date) tablespace '||l_index_tablespace||' compute statistics';
   EXCEPTION
     WHEN OTHERS THEN
     null;
  END;

 BEGIN
   DBMS_STATS.gather_table_stats('BIM','BIM_R_FUND_BALANCE', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);
 END;

  --Update the record of mininum date for each fund
  For l in min_date LOOP
  BEGIN
  UPDATE BIM_R_FUND_BALANCE a
  SET current_available = l.available,
      past_available = l.original,
      commited =l.commited,
      commited_sum=l.commited_sum,
      current_balance =l.balance,
      utilized=l.utilized,
      planned = l.planned,
      paid = l.paid
  WHERE a.fund_id = l.fund_id
  AND a.week_date = l.week_date;

   EXCEPTION
   WHEN OTHERS THEN
   ams_utility_pvt.write_conc_log('error updateing minimum balance'||sqlerrm(sqlcode));
   --dbms_output.put_line('error updateing minimum balance'||sqlerrm(sqlcode));
   END;
  END LOOP;

  /* Update in loop: for each fund, each date, populate the balance,
     commited, utilized, planned, paid */
  FOR x in balance_cur LOOP
  BEGIN
  UPDATE bim_r_fund_balance fb
  SET (past_available,current_available,commited,commited_sum,
       current_balance, utilized,planned, paid)
        =(
       select /*+ use_nl(maxdate ba) */
              nvl(ba.current_available,0),
              nvl(ba.current_available,0)+nvl(a.transfer_in,0) - nvl(a.transfer_out,0),
              nvl(fdsp.commited_amt,0),
              nvl(ba.commited_sum,0) + nvl(fdsp.commited_amt,0),
              nvl(ba.current_available,0)+nvl(a.transfer_in,0) - nvl(a.transfer_out,0) -nvl(ba.commited_sum,0)-nvl(fdsp.commited_amt,0),
              nvl(fdsp.utilized_amt,0),
              nvl(fdsp.planned, 0),
              nvl(fdsp.paid,0)
       from  (select max(week_date)  max_date
              from bim_r_fund_balance
              where fund_id = x.fund_id
	      and week_date < x.week_date) maxdate,
	      bim_r_fund_balance ba,
	      bim_r_fund_daily_facts a,
            (select fund_id fund_id,
                    SUM(nvl(commited_amt,0)) commited_amt,
                    SUM(nvl(planned_amt,0)) planned,
                    SUM(nvl(paid_amt,0)) paid,
                    SUM(nvl(standard_discount,0)+nvl(market_expense,0)+nvl(accrual,0)) utilized_amt,
                    transaction_create_date week_date
             from bim_r_fdsp_daily_facts
             WHERE fund_id = x.fund_id
             AND transaction_create_date = x.week_date
            group by fund_id, transaction_create_date) fdsp
       where a.fund_id =x.fund_id
       and a.transaction_create_date = x.week_date
       and fdsp.fund_id(+) = a.fund_id
       and fdsp.week_date(+)=a.transaction_create_date
       and ba.week_date =maxdate.max_date
       and ba.fund_id = x.fund_id
       and ba.fund_id = a.fund_id
	    )
where   fb.fund_id = x.fund_id
and fb.week_date = x.week_date ;
EXCEPTION
WHEN OTHERS THEN
  ams_utility_pvt.write_conc_log('error updateing balance in loop'||sqlerrm(sqlcode));
   --dbms_output.put_line('error updateing balance in loop'||sqlerrm(sqlcode));
   END;
END LOOP;
   fnd_message.set_name('BIM','BIM_R_PROC_END');
  fnd_message.set_token('proc_name', 'UPDATE_BALANCE', FALSE);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
EXCEPTION
WHEN OTHERS THEN
   ams_utility_pvt.write_conc_log('error updateing balance'||sqlerrm(sqlcode));
   --dbms_output.put_line('error updateing balance'||sqlerrm(sqlcode));
   --x_return_status := FND_API.G_RET_STS_ERROR;
   --FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
   --FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
   --FND_MSG_PUB.Add;
END update_balance;

---------------------------------------------------------------------
-- PROCEDURE
--    update_sub_balance
-- NOTE: This procedure will be called every time when FUND_SUB_LOAD
--       get executed. It inserts more data into bim_r_fund_balance.
--       It includes the new balance for existing fund, as well as for
--       new funds, which didn't have entry in bim_r_fund_balance.
---------------------------------------------------------------------
PROCEDURE update_sub_balance(p_start_date DATE, p_end_date DATE)
IS
l_oldid NUMBER:=0;
l_index_tablespace varchar2(100);

/* cursor fund_cur is to get the new funds, and the transaction
   date which don't have entry in bim_r_fund_balance */
CURSOR fund_cur IS
SELECT distinct w.fund_id, w.transaction_create_date
FROM bim_r_fund_daily_facts w
WHERE not exists( select 1
                 from bim_r_fund_balance b
                 where b.fund_id = w.fund_id
                 and b.week_date = w.transaction_create_date)
order by w.fund_id, w.transaction_create_date;

/* cursor fund_cur_delta is to get the exsiting funds, and its maximum
   date entry in bim_r_fund_balance, so that new balance will be calcuated
   based on it. */
CURSOR fund_cur_delta(p_date DATE) IS
SELECT distinct fund_id fund_id, max(week_date) mdate
FROM bim_r_fund_balance
WHERE week_date<p_date
GROUP BY fund_id;

 l_status                      VARCHAR2(5);
 l_industry                    VARCHAR2(5);
 l_schema                      VARCHAR2(30);
 l_return                       BOOLEAN;

  BEGIN
      l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);
  fnd_message.set_name('BIM','BIM_R_PROC_START');
  fnd_message.set_token('proc_name', 'UPDATE_SUB_BALANCE', FALSE);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fund_daily_facts noparallel';
    EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fdsp_daily_facts noparallel';
    EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fund_balance noparallel';
  EXCEPTION
  WHEN OTHERS THEN
  FND_FILE.put_line(fnd_file.log,'error alter table in balance'||sqlerrm(sqlcode));
  END;

  SELECT i.index_tablespace into l_index_tablespace
  FROM fnd_product_installations i, fnd_application a
  WHERE a.application_short_name = 'BIM'
  AND a.application_id = i.application_id;

  BEGIN
  EXECUTE IMMEDIATE 'drop index bim_r_fund_facts_n6';
  EXCEPTION
     WHEN OTHERS THEN
     null;
  END;

  BEGIN
  EXECUTE IMMEDIATE
  'create index bim_r_fund_facts_n6 on bim_r_fund_daily_facts
  (fund_id,
   transaction_create_date) tablespace '||l_index_tablespace||' compute statistics';
  EXCEPTION
     WHEN OTHERS THEN
     null;
  END;

  BEGIN
  EXECUTE IMMEDIATE 'drop index bim_r_fdsp_facts_n6';
  EXCEPTION
     WHEN OTHERS THEN
     null;
  END;

  BEGIN
  EXECUTE IMMEDIATE
  'create index bim_r_fdsp_facts_n6 on bim_r_fdsp_daily_facts
  (fund_id,
   transaction_create_date) tablespace '||l_index_tablespace||' compute statistics';
  EXCEPTION
     WHEN OTHERS THEN
     null;
  END;

  BEGIN
  EXECUTE IMMEDIATE 'drop index bim_r_fund_balance_n6';
  EXCEPTION
     WHEN OTHERS THEN
     null;
  END;

  BEGIN
  EXECUTE IMMEDIATE 'create index bim_r_fund_balance_n6 on
  bim_r_fund_balance(fund_id,week_date) tablespace '||l_index_tablespace||' compute statistics';
   EXCEPTION
     WHEN OTHERS THEN
     null;
  END;

  --populate balance for existing funds.
  BEGIN
   FOR x in fund_cur_delta(p_start_date) LOOP
   INSERT INTO bim_r_fund_balance(
     FUND_ID
   , WEEK_DATE
   , CURRENT_AVAILABLE
   , PAST_AVAILABLE
   , COMMITED
   , COMMITED_SUM
   , CURRENT_BALANCE
   , UTILIZED
   , PLANNED
   , PAID
   , FIS_MONTH
   , FIS_QTR
   , FIS_YEAR)
  SELECT x.fund_id,
         a.transaction_create_date,
         nvl(ba.current_available,0)+nvl(a.transfer_in,0) - nvl(a.transfer_out, 0) ,
         nvl(ba.current_available, 0),
         nvl(fdsp.commited_amt,0),
         nvl(ba.commited_sum,0) + nvl(fdsp.commited_amt, 0),
         nvl(ba.current_available,0)+nvl(a.transfer_in,0) - nvl(a.transfer_out,0) -nvl(ba.commited_sum,0)-nvl(fdsp.
         commited_amt, 0),
         nvl(fdsp.utilized,0),
         nvl(fdsp.planned,0),
         nvl(fdsp.paid,0),
         a.fis_month,
         a.fis_qtr,
         a.fis_year
  FROM   bim_r_fund_balance ba,
         bim_r_fund_daily_facts a,
         (SELECT fund_id fund_id,
                 SUM(nvl(commited_amt,0)) commited_amt,
                 SUM(nvl(standard_discount,0)+nvl(accrual,0)+
                     nvl(market_expense,0)) utilized,
                 SUM(nvl(planned_amt,0)) planned,
                 SUM(nvl(paid_amt,0)) paid,
                 transaction_create_date week_date
          FROM bim_r_fdsp_daily_facts
          WHERE fund_id = x.fund_id
          AND  transaction_create_date between p_start_date and p_end_date+0.99999
          GROUP BY fund_id, transaction_create_date) fdsp
  WHERE a.fund_id =x.fund_id
  and a.transaction_create_date between p_start_date and p_end_date+0.99999
  and fdsp.fund_id(+) = a.fund_id
  and fdsp.week_date(+)=a.transaction_create_date
  and ba.week_date =x.mdate
  and ba.fund_id = a.fund_id;
  END LOOP;
  EXCEPTION
   WHEN OTHERS THEN
   FND_FILE.put_line(fnd_file.log,'error updateing delta balance'||sqlerrm(sqlcode));
  END;

  --Insert new funds which don't have entries in bim_r_fund_balance.
  BEGIN
    FOR x in fund_cur LOOP
    -- This is to populate the initial balance for each fund.
    IF (x.fund_id <>l_oldid) THEN
      INSERT INTO bim_r_fund_balance(
       FUND_ID
     , WEEK_DATE
     , CURRENT_AVAILABLE
     , PAST_AVAILABLE
     , COMMITED
     , COMMITED_SUM
     , CURRENT_BALANCE
     , UTILIZED
     , PLANNED
     , PAID
     , FIS_MONTH
     , FIS_QTR
     , FIS_YEAR)
      SELECT x.fund_id,
             x.transaction_create_date,
             nvl(a.original_budget,0)+nvl(a.transfer_in,0) - nvl(a.transfer_out,0),
             nvl(a.original_budget,0),
             nvl(fdsp.commited_amt,0),
             nvl(fdsp.commited_amt,0),
             nvl(a.original_budget,0)+nvl(a.transfer_in,0)-nvl(a.transfer_out,0)-nvl(fdsp.commited_amt,0),
             nvl(fdsp.utilized,0),
             nvl(fdsp.planned,0),
             nvl(fdsp.paid,0),
             a.fis_month,
             a.fis_qtr,
             a.fis_year
      FROM   bim_r_fund_daily_facts a,
            (SELECT fund_id fund_id,
                    SUM(nvl(commited_amt,0)) commited_amt,
                    SUM(nvl(standard_discount,0)+nvl(accrual,0)+
                     nvl(market_expense,0)) utilized,
                    SUM(nvl(planned_amt,0)) planned,
                    SUM(nvl(paid_amt,0)) paid,
                    transaction_create_date week_date
             FROM bim_r_fdsp_daily_facts
             WHERE fund_id = x.fund_id
             AND transaction_create_date = x.transaction_create_date
             GROUP BY fund_id, transaction_create_date) fdsp
      WHERE a.fund_id =x.fund_id
      AND a.transaction_create_date = x.transaction_create_date
      AND fdsp.fund_id(+) = a.fund_id
      AND fdsp.week_date(+)=a.transaction_create_date;
   ELSE --to populate the balance for subsequent dates.
     INSERT INTO bim_r_fund_balance(
     FUND_ID
   , WEEK_DATE
   , PAST_AVAILABLE
   , CURRENT_AVAILABLE
   , COMMITED
   , COMMITED_SUM
   , CURRENT_BALANCE
   , UTILIZED
   , PLANNED
   , PAID
   , FIS_MONTH
   , FIS_QTR
   , FIS_YEAR)
   SELECT     x.fund_id,
              x.transaction_create_date,
              nvl(ba.current_available,0),
              nvl(ba.current_available,0)+nvl(a.transfer_in,0) - nvl(a.transfer_out,0),
              nvl(fdsp.commited_amt,0),
              nvl(ba.commited_sum,0) + nvl(fdsp.commited_amt,0),
              nvl(ba.current_available,0)+nvl(a.transfer_in,0) - nvl(a.transfer_out,0) - nvl(ba.commited_sum,0)-nvl( fdsp.commited_amt,0),
              nvl(fdsp.utilized,0),
              nvl(fdsp.planned,0),
              nvl(fdsp.paid,0),
              a.fis_month,
              a.fis_qtr,
              a.fis_year
   FROM  (select max(week_date)  max_date
              from bim_r_fund_balance
              where fund_id = x.fund_id
              and week_date < x.transaction_create_date) maxdate,
              bim_r_fund_balance ba,
              bim_r_fund_daily_facts a,
            (select fund_id fund_id,
                    sum(nvl(commited_amt,0)) commited_amt,
                    SUM(nvl(standard_discount,0)+nvl(accrual,0)+
                     nvl(market_expense,0)) utilized,
                    SUM(nvl(planned_amt,0)) planned,
                    SUM(nvl(paid_amt,0)) paid,
                    transaction_create_date week_date
             from bim_r_fdsp_daily_facts
             where fund_id = x.fund_id
             and transaction_create_date = x.transaction_create_date
             group by fund_id, transaction_create_date) fdsp
  WHERE a.fund_id =x.fund_id
  and a.transaction_create_date = x.transaction_create_date
  and fdsp.fund_id(+) = a.fund_id
  and fdsp.week_date(+)=a.transaction_create_date
  and ba.week_date =maxdate.max_date
  and ba.fund_id = x.fund_id;
  END IF;
  l_oldid :=x.fund_id;
END LOOP;
 fnd_message.set_name('BIM','BIM_R_PROC_END');
  fnd_message.set_token('proc_name', 'UPDATE_SUB_BALANCE', FALSE);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
EXCEPTION
   WHEN OTHERS THEN
   FND_FILE.put_line(fnd_file.log,'error updateing new balance'||sqlerrm(sqlcode));
END;
END update_sub_balance;

---------------------------------------------------------------------
-- PROCEDURE
--    POPULATE
-- NOTE This procedure can be called externally, ie: from concurrent
--      manager. Depending on the parameter, and bim_rep_history data,
--      FUND_FIRST_LOAD or FUND_SUB_LOAD will be called accordingly.
---------------------------------------------------------------------
PROCEDURE POPULATE
   (
    p_api_version_number      IN   NUMBER        ,
    p_init_msg_list           IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level        IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_commit                  IN   VARCHAR2     := FND_API.G_FALSE,
    x_msg_count               OUT NOCOPY  NUMBER       ,
    x_msg_data                OUT NOCOPY VARCHAR2     ,
    x_return_status           OUT NOCOPY VARCHAR2     ,
    p_object                  IN   VARCHAR2     ,
    p_start_date              IN   DATE         ,
    p_end_date                IN   DATE         ,
    p_para_num                IN   NUMBER
    ) IS
    v_error_code              NUMBER;
    v_error_text              VARCHAR2(1500);
    l_last_update_date        DATE;
    l_end_date                DATE;
    l_user_id                 NUMBER := FND_GLOBAL.USER_ID();
    l_api_version_number      CONSTANT NUMBER       := 1.0;
    l_api_name                CONSTANT     VARCHAR2(30) := 'POPULATE';
    l_date                    DATE;
    l_sdate                   DATE :=to_date('01/01/1950', 'DD/MM/YYYY') ;

    -- The maximum end date of the object being populated.
    CURSOR last_update_history IS
    SELECT MAX(end_date)
    FROM bim_rep_history
    WHERE object = p_object;



 l_status                      VARCHAR2(5);
 l_industry                    VARCHAR2(5);
 l_schema                      VARCHAR2(30);
 l_return                       BOOLEAN;

  BEGIN
      l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);

  -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list IF p_init_msg_list IS set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
   FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

   -- Initialize API RETURN status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  fnd_message.set_name('BIM','BIM_R_START_FACTS');
  fnd_message.set_token('p_object', 'Fund', FALSE);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
   -- Always make sure data be populated up to sysdate-1
   IF (trunc(p_end_date) =trunc(sysdate)) THEN
      l_end_date :=trunc(sysdate-1);
   ELSE
      l_end_date :=p_end_date;
   END IF;

   -- test GL period
   DECLARE
        l_start_date DATE;
        BEGIN

        SELECT  start_date
        INTO    l_start_date
        FROM    gl_periods
        WHERE   start_date <
                (select nvl(min(start_date_active),sysdate)
                from ozf_funds_all_b
                )
        AND     rownum < 2;

        IF      (l_start_date IS NULL) THEN
         fnd_message.set_name('BIM','BIM_R_GL_PERIODS');
         fnd_file.put_line(fnd_file.log,fnd_message.get);
        END IF ;
        EXCEPTION
        WHEN OTHERS THEN
        fnd_message.set_name('BIM','BIM_R_GL_PERIODS');
         fnd_file.put_line(fnd_file.log,fnd_message.get);
        END;


   OPEN last_update_history;
   FETCH last_update_history INTO l_last_update_date;
   CLOSE last_update_history;

    --Logic check.When load subsequently, p_start_date should be null.
    IF (l_last_update_date IS NOT NULL AND p_start_date IS NOT NULL) THEN

      fnd_message.set_name('BIM','BIM_R_FIRST_LOAD');
      fnd_message.set_token('end_date', l_last_update_date, FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_start_date IS NOT NULL THEN
        IF (p_start_date >= p_end_date) THEN
        fnd_message.set_name('BIM',' BIM_R_DATE_VALIDATION');
        fnd_file.put_line(fnd_file.log,fnd_message.get) ;
        RAISE FND_API.G_EXC_ERROR;
        END IF;

        FUND_FIRST_LOAD(p_start_datel =>TRUNC(p_start_date)
                       ,p_end_datel =>  TRUNC(l_end_date)
                       ,p_para_num  =>p_para_num
                       ,x_msg_count => x_msg_count
                       ,x_msg_data   => x_msg_data
                       ,x_return_status => x_return_status);
        IF    x_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
        ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                 RAISE FND_API.g_exc_unexpected_error;
        END IF;
    ELSE
        IF l_last_update_date IS NOT NULL THEN
           IF (p_end_date <= l_last_update_date) THEN
             ams_utility_pvt.write_conc_log('The current end date cannot be less than the last end date ');
             RAISE FND_API.g_exc_error;
          END IF;
         -- dbms_output.put_line('in sub load');

         --Load fund subsequently
         FUND_SUB_LOAD(p_start_datel => TRUNC(l_last_update_date + 1)
                         ,p_end_datel => TRUNC(l_end_date)
                         ,p_para_num  => p_para_num
                         ,x_msg_count => x_msg_count
                         ,x_msg_data => x_msg_data
                         ,x_return_status => x_return_status);
        END IF;
           IF    x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
           ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
           END IF;
     END IF;

 --Standard check of commit
   IF FND_API.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count IS 1, get message info.
   FND_msg_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
      );
  fnd_message.set_name('BIM','BIM_R_END_FACTS');
  fnd_message.set_token('object_name', 'Fund', FALSE);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and IF count=1, get the message
     FND_msg_PUB.Count_And_Get (
          --  p_encoded => FND_API.G_FALSE,
              p_count   => x_msg_count,
              p_data    => x_msg_data     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and IF count=1, get the message
     FND_msg_PUB.Count_And_Get (
            --p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_msg_PUB.Check_msg_Level ( FND_msg_PUB.G_msg_LVL_UNEXP_ERROR)
     THEN
        FND_msg_PUB.Add_Exc_msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and IF count=1, get the message
     FND_msg_PUB.Count_And_Get (
            -- p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END POPULATE;
 -----------------------------------------------------------------------
 -- PROCEDURE
 --    LOG_HISTORY
 --
 -- Note
 --    Insert history data for each load: first time or subsequent mode.
--------------------------------------------------------------------------
PROCEDURE LOG_HISTORY(
    p_object                      VARCHAR2        ,
    p_start_time                  DATE            ,
    p_end_time                    DATE            ,
    x_msg_count              OUT NOCOPY NUMBER          ,
    x_msg_data               OUT NOCOPY VARCHAR2        ,
    x_return_status          OUT NOCOPY VARCHAR2
 )
IS
    l_user_id            NUMBER := FND_GLOBAL.USER_ID();
    l_table_name         VARCHAR2(100):='bim_rep_history';
BEGIN
    INSERT INTO
    bim_rep_history
       (creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        object_last_updated_date,
        object,
        start_date,
        end_date)
    VALUES
       (sysdate,
        sysdate,
        l_user_id,
        l_user_id,
        sysdate,
        p_object,
        p_start_time,
        p_end_time);
EXCEPTION
   WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
   FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
   FND_MSG_PUB.Add;
   fnd_file.put_line(fnd_file.log,fnd_message.get);
END LOG_HISTORY;

---------------------------------------------------------------------
-- PROCEDURE
--    FUND_FIRST_LOAD
-- NOTE This procedure will be executed when load data for first time.
--      Transactions for funds whose active date during p_start_date
--      and p_end_date will be inserted into bim_r_fund_daily_facts,
--      and transactions happened before fund active data are also captured.
---------------------------------------------------------------------
PROCEDURE FUND_FIRST_LOAD(
    p_start_datel          DATE,
    p_end_datel            DATE,
    p_para_num             NUMBER       ,
    x_msg_count            OUT NOCOPY NUMBER       ,
    x_msg_data             OUT NOCOPY VARCHAR2     ,
    x_return_status        OUT NOCOPY VARCHAR2
   )
   IS
   l_user_id    NUMBER := FND_GLOBAL.USER_ID();
   l_min_date              DATE;
   l_last_update_date      DATE;
   l_success               VARCHAR2(1) := 'F';
   l_api_version_number    CONSTANT NUMBER       := 1.0;
   l_api_name              CONSTANT VARCHAR2(30) := 'FUND_FIRST_LOAD';
   l_table_name            VARCHAR2(100);
   l_def_tablespace        VARCHAR2(100);
   l_index_tablespace      VARCHAR2(100);
   l_oracle_username       VARCHAR2(100);
   l_count                 NUMBER:=0;
   l_old_index             VARCHAR2(100);
   l_col_num               VARCHAR2(100);

   TYPE  generic_number_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   TYPE  generic_char_table IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

   l_pct_free	          generic_number_table;
   l_ini_trans            generic_number_table;
   l_max_trans  	  generic_number_table;
   l_initial_extent       generic_number_table;
   l_next_extent  	  generic_number_table;
   l_min_extents 	  generic_number_table;
   l_max_extents          generic_number_table;
   l_pct_increase 	  generic_number_table;

   l_owner 		  generic_char_table;
   l_index_name 	  generic_char_table;
   l_ind_column_name      generic_char_table;
   l_index_table_name     generic_char_table;
   i			  NUMBER;

   l_status      VARCHAR2(30);
   l_industry    VARCHAR2(30);
   l_orcl_schema VARCHAR2(30);
   l_bol         BOOLEAN := fnd_installation.get_app_info ('BIM',l_status,l_industry,l_orcl_schema);


   -- Get the original tablespace, index space for application ID:'BIM'
   CURSOR    get_ts_name IS
   SELECT    i.tablespace, i.index_tablespace, u.oracle_username
   FROM      fnd_product_installations i, fnd_application a, fnd_oracle_userid u
   WHERE     a.application_short_name = 'BIM'
   AND 	     a.application_id = i.application_id
   AND 	     u.oracle_id = i.oracle_id;

   -- Get all the index defination
   CURSOR    get_index_params (l_schema VARCHAR2) IS
   SELECT    a.owner,a.index_name,b.table_name,b.column_name,pct_free,ini_trans,max_trans
             ,initial_extent,next_extent,min_extents,
	     max_extents, pct_increase
   FROM      all_indexes a, all_ind_columns b
   WHERE     a.index_name = b.index_name
   AND       a.owner = l_schema
   AND       a.owner = b.index_owner
   AND 	     (a.index_name like 'BIM_R_FUND%_FACTS%'
   OR        a.index_name like 'BIM_R_FDSP%_FACTS%')
   ORDER BY a.index_name;



 l_schema                      VARCHAR2(30);
 l_return                       BOOLEAN;

  BEGIN
      l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        l_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Debug Message
   --AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

   -- Initialize API RETURN status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

      /* In order to speed up insertion. We drop all the index before inserting, and
         create them back after inserting. But we want to keep the parameters(tablespace,
         indexspace etc) they were created before. */
      OPEN  get_ts_name;
      FETCH get_ts_name INTO l_def_tablespace, l_index_tablespace, l_oracle_username;
      CLOSE get_ts_name;

      fnd_message.set_name('BIM','BIM_R_DROP_INDEXES');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      /* Piece of Code for retrieving,storing storage parameters and Dropping the indexes */
      BEGIN
      i := 1;
      l_old_index :='N';
      FOR x in get_index_params(l_orcl_schema) LOOP

	  l_pct_free(i) :=  x.pct_free;
	  l_ini_trans(i) := x.ini_trans;
	  l_max_trans(i) := x.max_trans;
   	  l_initial_extent(i) := x.initial_extent;
   	  l_next_extent(i)    := x.next_extent;
   	  l_min_extents(i)    := x.min_extents;
   	  l_max_extents(i)    := x.max_extents;
   	  l_pct_increase(i)   := x.pct_increase;

	  l_owner(i) :=x.owner;
	  l_index_name(i) :=x.index_name;
	  l_index_table_name(i) := x.table_name;
	  l_ind_column_name(i)  := x.column_name;

      --dbms_output.put_line('l_index:'||l_index_name(i)||' '||'i:'||i||'l_old:'|| l_old_index);

      IF l_index_name(i)<>l_old_index THEN --
      EXECUTE IMMEDIATE 'DROP INDEX  '|| l_owner(i) || '.'|| l_index_name(i) ;
      -- dbms_output.put_line('dropping:'||i||' '||l_owner(i) || '.'|| l_index_name(i));
      END IF;
      l_old_index:= l_index_name(i);
      i := i + 1;
      END LOOP;
      EXCEPTION
      WHEN others THEN
      --dbms_output.put_line('error dropping index:'||sqlerrm(sqlcode));
       FND_FILE.put_line(fnd_file.log,'error dropping index'||sqlerrm(sqlcode));
       x_return_status := FND_API.G_RET_STS_ERROR;
      END;

   BEGIN

   --for performance reasons
   EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fund_daily_facts nologging';
   EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fund_weekly_facts nologging';
   EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fdsp_daily_facts nologging';
   EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fdsp_weekly_facts nologging';
   EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fund_daily_facts_s CACHE 1000';

   l_table_name :='bim_r_fund_daily_facts';
   fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
   fnd_message.set_token('TABLE_NAME','bim_r_fund_daily_facts', FALSE);
   fnd_file.put_line(fnd_file.log,fnd_message.get);
   /* First insert: Insert all the transactions: transfer in/out for funds whose active date between p_start_date and p_end_date */
   INSERT /*+ append parallel(fdf,p_para_num) */
   INTO bim_r_fund_daily_facts fdf(
         fund_transaction_id
        ,creation_date
        ,last_update_date
        ,created_by
        ,last_updated_by
        ,last_update_login
        ,fund_id
        ,parent_fund_id
        ,fund_number
        ,start_date
        ,end_date
        ,start_period
        ,end_period
        ,set_of_books_id
        ,fund_type
        --,region
        ,country
        ,org_id
        ,category_id
        ,status
        ,original_budget
        ,transfer_in
        ,transfer_out
        ,holdback_amt
        ,currency_code_fc
        ,delete_flag
        ,transaction_create_date
        ,load_date
        ,fis_month
        ,fis_qtr
        ,fis_year
        ,business_unit_id)
SELECT  /*+ parallel(inner, p_para_num) */
bim_r_fund_daily_facts_s.nextval,
       sysdate,
       sysdate,
       l_user_id,
       l_user_id,
       l_user_id,
       inner.fund_id,
       inner.parent_fund_id,
       inner.fund_number,
       inner.start_date,
       inner.end_date,
       inner.start_period,
       inner.end_period,
       inner.set_of_books_id,
       inner.fund_type,
       --inner.region,
       inner.country,
       inner.org_id,
       inner.category_id,
       inner.status,
       inner.original_budget,
       inner.transfer_in,
       inner.transfer_out,
       inner.holdback,
       inner.currency_code_fc,
       'N',
       inner.transaction_create_date,
       inner.weekend_date,
       BIM_SET_OF_BOOKS.get_fiscal_month(inner.transaction_create_date,204),
       BIM_SET_OF_BOOKS.get_fiscal_qtr(inner.transaction_create_date,204),
       BIM_SET_OF_BOOKS.get_fiscal_year(inner.transaction_create_date,204),
       inner.business_unit_id
FROM (
SELECT    fund_id fund_id,
          fund_number fund_number,
          start_date start_date,
          end_date end_date,
          start_period start_period,
          end_period end_period,
          category_id category_id,
          status status,
          fund_type fund_type,
          parent_fund_id parent_fund_id,
          country country,
          org_id org_id,
          business_unit_id business_unit_id,
          set_of_books_id set_of_books_id,
          currency_code_fc currency_code_fc,
          original_budget original_budget,
          transaction_create_date transaction_create_date,
          weekend_date weekend_date,
          SUM(transfer_in) transfer_in,
          SUM(transfer_out) transfer_out,
          SUM(holdback) holdback
FROM      (
SELECT    ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_code country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          ad.original_budget original_budget,
          ad.tr_date transaction_create_date,
          trunc((decode(decode( to_char(ad.tr_date,'MM') , to_char(next_day(ad.tr_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(ad.tr_date , (next_day(ad.tr_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,ad.tr_date
      	        ,'FALSE'
      	        ,next_day(ad.tr_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(ad.tr_date,'MM'),to_char(next_day(ad.tr_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(ad.tr_date)))))         weekend_date,
          nvl(SUM(convert_currency(bu1.approved_in_currency,nvl(bu1.approved_original_amount,0))),0) transfer_in,
          0     transfer_out,
          0     holdback
   FROM   (SELECT a.fund_id fund_id,
          a.fund_number fund_number,
          a.start_date_active start_date_active,
          a.end_date_active end_date_active,
          a.start_period_name start_period_name,
          a.end_period_name end_period_name,
          a.category_id category_id,
          a.status_code status_code,
          a.fund_type fund_type,
          a.parent_fund_id parent_fund_id,
          a.business_unit_id business_unit_id,
          a.country_id country_code,
          --b.area2_code area2_code,
          a.org_id org_id,
          a.set_of_books_id set_of_books_id,
          a.currency_code_fc currency_code_fc,
        --  decode(trunc(d.trdate),trunc(a.PROGRAM_UPDATE_DATE),a.original_budget,0) original_budget,
	  a.original_budget original_budget,
          trunc(d.trdate)  tr_date
          FROM ozf_funds_all_b a,
               bim_intl_dates d
          WHERE a.status_code in ('ACTIVE', 'CANCELLED', 'CLOSED')
          AND   d.trdate between a.start_date_active and least(nvl(a.end_date_active,sysdate-1),p_end_datel)
          AND   a.start_date_active between p_start_datel and p_end_datel
          GROUP BY a.fund_id,
                   trunc(d.trdate),
	--			   trunc(a.PROGRAM_UPDATE_DATE),
                   a.fund_number,
                   a.start_date_active,
                   a.end_date_active,
                   a.start_period_name,
                   a.end_period_name,
                   a.category_id,
                   a.status_code,
                   a.fund_type,
                   a.parent_fund_id,
                   a.country_id,
                   a.org_id,
                   a.business_unit_id,
                   a.set_of_books_id,
                   a.currency_code_fc,
                   a.original_budget
                          ) ad,
                  ozf_act_budgets BU1
   WHERE  bu1.approval_date(+) between ad.tr_date and ad.tr_date + 0.99999
   AND    bu1.transfer_type in ('TRANSFER','REQUEST')
   AND    bu1.status_code(+) = 'APPROVED'
   AND    bu1.arc_act_budget_used_by(+) = 'FUND'
   AND    bu1.act_budget_used_by_id(+) = ad.fund_id
   AND    bu1.budget_source_type(+) ='FUND'
   GROUP BY ad.fund_id,
          ad.tr_date ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_code,
          ad.business_unit_id,
          ad.org_id ,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget
UNION ALL
  SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_code country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          ad.original_budget original_budget,
          ad.tr_date transaction_create_date,
          trunc((decode(decode( to_char(ad.tr_date,'MM') , to_char(next_day(ad.tr_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(ad.tr_date , (next_day(ad.tr_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,ad.tr_date
      	        ,'FALSE'
      	        ,next_day(ad.tr_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(ad.tr_date,'MM'),to_char(next_day(ad.tr_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(ad.tr_date)))))         weekend_date,
          0   transfer_in,
          nvl(SUM(decode(bu2.transfer_type,'TRANSFER', convert_currency(bu2.approved_in_currency,nvl(bu2.approved_original_amount,0)))),0)
          +nvl(SUM(decode(bu2.transfer_type,'REQUEST', convert_currency(bu2.approved_in_currency,nvl(bu2.approved_original_amount,0)))),0) transfer_out,
          --nvl(SUM(convert_currency(bu2.approved_in_currency,nvl(bu2.approved_original_amount,0))),0)  transfer_out,
          nvl(SUM(decode(bu2.transfer_type, 'RESERVE', convert_currency(bu2.approved_in_currency,nvl(bu2.approved_original_amount,0)))),0)-
          nvl(SUM(decode(bu2.transfer_type, 'RELEASE', convert_currency(bu2.approved_in_currency,nvl(bu2.approved_original_amount,0)))),0) holdback
   FROM   (SELECT a.fund_id fund_id,
          a.fund_number fund_number,
          a.start_date_active start_date_active,
          a.end_date_active end_date_active,
          a.start_period_name start_period_name,
          a.end_period_name end_period_name,
          a.category_id category_id,
          a.status_code status_code,
          a.fund_type fund_type,
          a.parent_fund_id parent_fund_id,
          a.country_id country_code,
          a.org_id org_id,
          a.business_unit_id business_unit_id,
          a.set_of_books_id set_of_books_id,
          a.currency_code_fc currency_code_fc,
      --    decode(trunc(d.trdate),trunc(a.PROGRAM_UPDATE_DATE),a.original_budget,0) original_budget,
	a.original_budget original_budget,
          trunc(d.trdate)  tr_date
          FROM ozf_funds_all_b a,
               bim_intl_dates d
          WHERE a.status_code in ('ACTIVE', 'CANCELLED', 'CLOSED')
          AND   d.trdate between a.start_date_active and least(nvl(a.end_date_active,sysdate-1),p_end_datel)
          AND   a.start_date_active between p_start_datel and p_end_datel
          GROUP BY a.fund_id,
                   trunc(d.trdate),
	--			   trunc(a.PROGRAM_UPDATE_DATE),
                   a.fund_number,
                   a.start_date_active,
                   a.end_date_active,
                   a.start_period_name,
                   a.end_period_name,
                   a.category_id,
                   a.status_code,
                   a.fund_type,
                   a.parent_fund_id,
                   a.country_id,
                   a.org_id,
                   a.business_unit_id,
                   a.set_of_books_id,
                   a.currency_code_fc,
                   a.original_budget
                          ) ad,
                  ozf_act_budgets BU2
   WHERE  bu2.approval_date(+) between ad.tr_date and ad.tr_date + 0.99999
   AND    bu2.status_code(+) = 'APPROVED'
   AND    bu2.arc_act_budget_used_by(+) = 'FUND'
   AND    bu2.budget_source_type(+) ='FUND'
   AND    bu2.budget_source_id (+)= ad.fund_id
   GROUP BY ad.fund_id,
          ad.tr_date ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_code,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget)
   GROUP BY
          fund_id,
          transaction_create_date,
          weekend_date,
          fund_number,
          start_date,
          end_date,
          start_period,
          end_period,
          category_id,
          status,
          fund_type,
          parent_fund_id,
          country,
          org_id,
          business_unit_id,
          set_of_books_id,
          currency_code_fc,
          original_budget
           )inner;
          l_count:=l_count+SQL%ROWCOUNT;
          EXECUTE IMMEDIATE 'COMMIT';
      EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fund_daily_facts_s CACHE 20';
      EXCEPTION
      WHEN others THEN
        EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fund_daily_facts_s CACHE 20';
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
        FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
        FND_MSG_PUB.Add;
        fnd_file.put_line(fnd_file.log,fnd_message.get);
      END;

     /*Second insert: more records which transact before active date */
     BEGIN
    -- dbms_output.put_line('inserting extra');
    fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
   fnd_message.set_token('table_name', 'bim_r_fund_daily_facts', FALSE);
   fnd_file.put_line(fnd_file.log,fnd_message.get);
   INSERT
   INTO bim_r_fund_daily_facts fdf(
         fund_transaction_id
        ,creation_date
        ,last_update_date
        ,created_by
        ,last_updated_by
        ,last_update_login
        ,fund_id
        ,parent_fund_id
        ,fund_number
        ,start_date
        ,end_date
        ,start_period
        ,end_period
        ,set_of_books_id
        ,fund_type
        --,region
        ,country
        ,org_id
        ,category_id
        ,status
        ,original_budget
        ,transfer_in
        ,transfer_out
        ,holdback_amt
        ,currency_code_fc
        ,delete_flag
        ,transaction_create_date
        ,load_date
        ,fis_month
        ,fis_qtr
        ,fis_year
        ,business_unit_id)
--        ,security_group_id)
SELECT
       bim_r_fund_daily_facts_s.nextval,
       sysdate,
       sysdate,
       l_user_id,
       l_user_id,
       l_user_id,
       inner.fund_id,
       inner.parent_fund_id,
       inner.fund_number,
       inner.start_date,
       inner.end_date,
       inner.start_period,
       inner.end_period,
       inner.set_of_books_id,
       inner.fund_type,
       --inner.region,
       inner.country,
       inner.org_id,
       inner.category_id,
       inner.status,
       inner.original_budget,
       inner.transfer_in,
       inner.transfer_out,
       inner.holdback,
       inner.currency_code_fc,
       'N',
       inner.transaction_create_date,
       inner.weekend_date,
       BIM_SET_OF_BOOKS.get_fiscal_month(inner.transaction_create_date,204),
       BIM_SET_OF_BOOKS.get_fiscal_qtr(inner.transaction_create_date,204),
       BIM_SET_OF_BOOKS.get_fiscal_year(inner.transaction_create_date,204),
       inner.business_unit_id
FROM (
SELECT  transaction_create_date transaction_create_date,
        trunc((decode(decode( to_char(transaction_create_date,'MM') , to_char(next_day(transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(transaction_create_date , (next_day(transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,transaction_create_date
      	        ,'FALSE'
      	        ,next_day(transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(transaction_create_date,'MM'),to_char(next_day(transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(transaction_create_date)))))         weekend_date,
        SUM(transfer_in) transfer_in,
        SUM(transfer_out) transfer_out,
        SUM(holdback) holdback,
        fund_id ,
        fund_number ,
        start_date ,
        end_date ,
        start_period ,
        end_period ,
        category_id ,
        status ,
        fund_type ,
        parent_fund_id ,
        business_unit_id ,
        country ,
        org_id ,
        set_of_books_id ,
        currency_code_fc ,
        original_budget
FROM    (
SELECT    trunc(bu1.approval_date) transaction_create_date,
          nvl(SUM(convert_currency(bu1.approved_in_currency,nvl(bu1.approved_original_amount,0))),0) transfer_in,
          0 transfer_out,
          0 holdback,
          o.fund_id fund_id,
          o.fund_number fund_number,
          o.start_date_active start_date,
          o.end_date_active end_date,
          o.start_period_name start_period,
          o.end_period_name end_period,
          o.category_id category_id,
          o.status_code status,
          o.fund_type fund_type,
          o.parent_fund_id parent_fund_id,
          o.business_unit_id business_unit_id,
          o.country_id country,
          o.org_id org_id,
          o.set_of_books_id set_of_books_id,
          o.currency_code_fc currency_code_fc,
          o.original_budget original_budget
FROM      ozf_funds_all_b o,
          ozf_act_budgets BU1
WHERE  o.start_date_active between p_start_datel and p_end_datel
AND    o.status_code in ('ACTIVE','CANCELLED', 'CLOSED')
AND    bu1.transfer_type in ('TRANSFER', 'REQUEST')
AND    bu1.approval_date <trunc(o.start_date_active)
AND    bu1.status_code(+) = 'APPROVED'
AND    bu1.arc_act_budget_used_by(+) = 'FUND'
AND    bu1.act_budget_used_by_id(+) = o.fund_id
AND    bu1.budget_source_type(+) ='FUND'
GROUP BY  trunc(bu1.approval_date),
          o.fund_id ,
          o.fund_number ,
          o.start_date_active ,
          o.end_date_active ,
          o.start_period_name ,
          o.end_period_name ,
          o.category_id ,
          o.status_code ,
          o.fund_type ,
          o.parent_fund_id ,
          o.business_unit_id ,
          o.country_id ,
          o.org_id ,
          o.set_of_books_id ,
          o.currency_code_fc ,
          o.original_budget
UNION ALL
SELECT    trunc(bu2.approval_date) transaction_create_date,
          0 transfer_in,
          nvl(SUM(decode(bu2.transfer_type,'TRANSFER', convert_currency(bu2.approved_in_currency,nvl(bu2.approved_original_amount,0)))),0)
          +nvl(SUM(decode(bu2.transfer_type,'REQUEST', convert_currency(bu2.approved_in_currency,nvl(bu2.approved_original_amount,0)))),0) transfer_out,
          nvl(SUM(decode(bu2.transfer_type, 'RESERVE', convert_currency(bu2.approved_in_currency,nvl(bu2.approved_original_amount,0)))),0)-
          nvl(SUM(decode(bu2.transfer_type, 'RELEASE', convert_currency(bu2.approved_in_currency,nvl(bu2.approved_original_amount,0)))),0) holdback,
          --nvl(SUM(convert_currency(bu2.approved_in_currency,nvl(bu2.approved_original_amount,0))),0) transfer_out,
          --nvl(SUM(decode(bu2.transfer_type, 'RESERVE', convert_currency(bu2.approved_in_currency,nvl(bu2.approved_original_amount,0)))),0) holdback,
          o.fund_id fund_id,
          o.fund_number fund_number,
          o.start_date_active start_date,
          o.end_date_active end_date,
          o.start_period_name start_period,
          o.end_period_name end_period,
          o.category_id category_id,
          o.status_code status,
          o.fund_type fund_type,
          o.parent_fund_id parent_fund_id,
          o.business_unit_id business_unit_id,
          o.country_id country,
          o.org_id org_id,
          o.set_of_books_id set_of_books_id,
          o.currency_code_fc currency_code_fc,
          o.original_budget original_budget
FROM      ozf_funds_all_b o,
          ozf_act_budgets BU2
WHERE  o.start_date_active between p_start_datel and p_end_datel
AND    o.status_code in ('ACTIVE','CANCEL', 'CLOSED')
AND    bu2.approval_date <trunc(o.start_date_active)
AND    bu2.status_code(+) = 'APPROVED'
AND    bu2.arc_act_budget_used_by(+) = 'FUND'
AND    bu2.budget_source_type(+) ='FUND'
AND    bu2.budget_source_id (+)= o.fund_id
GROUP BY trunc(bu2.approval_date),
          o.fund_id ,
          o.fund_number ,
          o.start_date_active ,
          o.end_date_active ,
          o.start_period_name ,
          o.end_period_name ,
          o.category_id ,
          o.status_code ,
          o.fund_type ,
          o.parent_fund_id ,
          o.business_unit_id ,
          o.country_id ,
          o.org_id ,
          o.set_of_books_id ,
          o.currency_code_fc ,
          o.original_budget  )
   GROUP BY transaction_create_date,
        fund_id ,
        fund_number ,
        start_date ,
        end_date ,
        start_period ,
        end_period ,
        category_id ,
        status ,
        fund_type ,
        parent_fund_id ,
        business_unit_id ,
        country ,
        org_id ,
        set_of_books_id ,
        currency_code_fc ,
        original_budget    )inner;
   l_count:=l_count+SQL%ROWCOUNT;
   EXECUTE IMMEDIATE 'commit';
      --End inserting transactions happened before start_date
     EXCEPTION
      WHEN others THEN
        FND_FILE.put_line(fnd_file.log,'error insert into fund_daily for transactions happened b4 start date'||sqlerrm(sqlcode));
        --dbms_output.put_line('error looping inserting INTO bim_r_fund_daily_facts'||sqlerrm(sqlcode));
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
        FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
        FND_MSG_PUB.Add;
      END;
      /* Start inserting into 'bim_r_fdsp_daily_facts' */
      l_table_name :='bim_r_fdsp_daily_facts';
      fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
      fnd_message.set_token('table_name', 'bim_r_fdsp_load', FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fdsp_daily_facts_s CACHE 1000';
      EXECUTE IMMEDIATE 'truncate table '||l_schema||'.bim_r_fdsp_load';
      /* bim_r_fdsp_load is a intermediate table which holds commited amount, planned amount etc for all objects */
      BEGIN
       INSERT /*+ append parallel(bfl,p_para_num) */
       INTO  bim_r_fdsp_load bfl(
            spend_transaction_id
            ,creation_date
            ,last_update_date
            ,created_by
            ,last_updated_by
            ,last_update_login
            ,fund_id
            ,business_unit_id
            ,util_org_id
            ,standard_discount
            ,accrual
            ,market_expense
            ,commited_amt
            ,planned_amt
            ,paid_amt
            ,delete_flag
            ,transaction_create_date
            ,load_date
            ,object_id
            ,object_type)
        SELECT /*+ parallel(act_util, p_para_num) */
             0,
             sysdate,
             sysdate,
             -1,
             -1,
             -1,
             act_util.fund_id,
             0,
             0,
             act_util.standard_discount,
             act_util.accrual,
             act_util.market_expense,
             act_util.commited_amt,
             act_util.planned_amt,
             act_util.paid_amt,
             'Y',
             act_util.creation_date,
             sysdate,
             act_util.object_id,
             act_util.object_type
      FROM  (SELECT fund_id fund_id,
                    object_id object_id,
                    object_type object_type,
                    creation_date  creation_date,
                    SUM(nvl(planned_amt,0)) planned_amt,
                    SUM(nvl(commited_amt,0)) commited_amt,
                    SUM(nvl(standard_discount,0)) standard_discount,
                    SUM(nvl(accrual,0)) accrual,
                    SUM(nvl(market_expense,0)) market_expense,
                    SUM(nvl(paid_amt,0)) paid_amt
             FROM  (
                    SELECT budget_source_id fund_id,
                           act_budget_used_by_id object_id,
                           arc_act_budget_used_by object_type,
                           trunc(nvl(request_date,creation_date)) creation_date,
                           SUM(convert_currency(request_currency, nvl(request_amount,0))) planned_amt,
                           0  commited_amt,
                           0 standard_discount,
                           0 accrual,
                           0 market_expense,
                           0 paid_amt
                    FROM ozf_act_budgets
                    WHERE budget_source_type ='FUND'
                    AND   status_code ='PENDING'
                    AND   ARC_ACT_BUDGET_USED_BY <> 'FUND'
                    GROUP BY trunc(nvl(request_date ,creation_date)),
                             budget_source_id,act_budget_used_by_id,
                             arc_act_budget_used_by
                    UNION ALL
                    SELECT budget_source_id fund_id,
                           act_budget_used_by_id object_id,
                           arc_act_budget_used_by object_type,
                           trunc(nvl(approval_date,last_update_date))  creation_date,
                           --0-SUM(convert_currency(request_currency, nvl(request_amount,0))) planned_amt,
			   0 planned_amt,
                           SUM(convert_currency(approved_in_currency,nvl(approved_original_amount,0)))  commited_amt,
                           0 standard_discount,
                           0 accrual,
                           0 market_expense,
                           0 paid_amt
                    FROM ozf_act_budgets
                    WHERE budget_source_type ='FUND'
                    AND   ARC_ACT_BUDGET_USED_BY <> 'FUND'
                    AND   status_code ='APPROVED'
                    GROUP BY trunc(nvl(approval_date,last_update_date)),
                          budget_source_id,act_budget_used_by_id,
                          arc_act_budget_used_by
                    UNION ALL
                    SELECT act_budget_used_by_id fund_id,
                           budget_source_id object_id,
                           budget_source_type object_type,
                           trunc(nvl(approval_date,last_update_date))  creation_date,
                           0 planned_amt,
                           0-SUM(convert_currency(approved_in_currency,nvl(approved_original_amount,0)))  commited_amt,
                           0 standard_discount,
                           0 accrual,
                           0 market_expense,
                           0 paid_amt
                    FROM ozf_act_budgets
                    WHERE arc_act_budget_used_by ='FUND'
                    AND   budget_source_type<>'FUND'
                    AND   status_code ='APPROVED'
                    GROUP BY trunc(nvl(approval_date,last_update_date)),
                          act_budget_used_by_id, budget_source_id,
                          budget_source_type
                    UNION ALL
                    SELECT fund_id fund_id,
                           plan_id object_id,
                           plan_type  object_type,
                           trunc(creation_date) creation_date,
                           0 planned_amt,
                           0 commited_amt,
                           SUM(decode(component_type,'OFFR',decode(utilization_type, 'UTILIZED',convert_currency(currency_code,nvl(amount,0)), 0),0)) standard_discount,
                           SUM(decode(component_type,'OFFR', decode(utilization_type, 'ACCRUAL', convert_currency(currency_code,nvl(amount,0)), 0),0) +
                           decode(component_type,'OFFR', decode(utilization_type, 'ADJUSTMENT', convert_currency(currency_code,nvl(amount,0)), 0),0)) accrual,
                           SUM(decode(component_type,'OFFR',0, decode(utilization_type, 'UTILIZED', convert_currency(currency_code,nvl(amount,0)), 0))) market_expense,
                           sum(decode(component_type,'OFFR',0,convert_currency(currency_code,(nvl(amount,0)-NVL(amount_remaining,0))))) paid_amt
                   FROM ozf_funds_utilized_all_b
                   WHERE utilization_type in ('UTILIZED','ACCRUAL','ADJUSTMENT')
                   GROUP BY trunc(creation_date),fund_id,plan_id,plan_type
                   )
             GROUP BY creation_date, fund_id, object_id,object_type
              ) act_util;
              EXECUTE IMMEDIATE 'COMMIT';
        EXCEPTION
        WHEN OTHERS THEN
        FND_FILE.put_line(fnd_file.log,'error insert fdsp daily'||sqlerrm(sqlcode));
        --dbms_output.put_line('error inserting INTO bim_r_fdsp_daily_facts'||sqlerrm(sqlcode));
        EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fdsp_daily_facts_s CACHE 20';
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
        FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
        FND_MSG_PUB.Add;
        END ;  --end of insertion into bim_r_fdsp_load.

  -- dbms_output.put_line('inside fist inserting into fdsp daily');
   fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
   fnd_message.set_token('table_name', l_table_name, FALSE);
   fnd_file.put_line(fnd_file.log,fnd_message.get);
   /* First insert: insert into bim_r_fdsp_daily_facts for the funds whose active
      date between p_start_date and p_end_date. Fund transactions are: commited, planned, utilized
      etc. The measures are on object level. Object are like campaigns, events, offers, etc. */
   BEGIN
   INSERT /*+ append parallel(fdf,p_para_num) */
   INTO bim_r_fdsp_daily_facts fdf(
         spend_transaction_id
         ,creation_date
         ,last_update_date
         ,created_by
         ,last_updated_by
         ,last_update_login
         ,fund_id
         ,business_unit_id
         ,util_org_id
         ,standard_discount
         ,accrual
         ,market_expense
         ,commited_amt
         ,planned_amt
         ,paid_amt
         ,delete_flag
         ,transaction_create_date
         ,load_date
         ,object_id
         ,object_type
         ,fis_month
         ,fis_qtr
         ,fis_year
         )
   SELECT /*+ parallel(inner, p_para_num) */
         bim_r_fdsp_daily_facts_s.nextval,
          sysdate,
          sysdate,
          l_user_id,
          l_user_id,
          l_user_id,
          inner.fund_id,
          inner.business_unit_id,
          inner.org_id,
          inner.standard_discount,
          inner.accrual,
          inner.market_expense,
          inner.commited_amt,
          inner.planned_amt,
          inner.paid_amt,
          'N',
          inner.transaction_create_date,
          trunc((decode(decode( to_char(inner.transaction_create_date,'MM') , to_char(next_day(inner.transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(inner.transaction_create_date , (next_day(inner.transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,inner.transaction_create_date
      	        ,'FALSE'
      	        ,next_day(inner.transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(inner.transaction_create_date,'MM'),to_char(next_day(inner.transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(inner.transaction_create_date)))))         weekend_date
         ,inner.object_id
         ,inner.object_type
         ,BIM_SET_OF_BOOKS.get_fiscal_month(inner.transaction_create_date,204)
         ,BIM_SET_OF_BOOKS.get_fiscal_qtr(inner.transaction_create_date,204)
         ,BIM_SET_OF_BOOKS.get_fiscal_year(inner.transaction_create_date,204)
   FROM  (SELECT AD.fund_id fund_id,
  	         U.business_unit_id business_unit_id,
  	         U.org_id org_id,
  	         NVL(AU.standard_discount,0) standard_discount,
  	         NVL(AU.accrual,0) accrual,
  	         NVL(AU.market_expense,0) market_expense,
  	         NVL(AU.commited_amt,0) commited_amt,
  	         NVL(AU.planned_amt,0) planned_amt,
  	         NVL(AU.paid_amt,0) paid_amt,
  	         AU.object_id object_id,
  	         U.object_type object_type,
  	         AD.trdate transaction_create_date
          FROM   (SELECT A.fund_id fund_id,TRUNC(DA.trdate) trdate
                 FROM ozf_funds_all_b A,
                 bim_intl_dates DA
                 WHERE A.status_code IN ( 'ACTIVE','CANCELLED','CLOSED'  )
                 AND   DA.trdate between A.start_date_active
                       and least(nvl(A.end_date_active,sysdate-1),p_end_datel)
                 AND   A.start_date_active between p_start_datel and p_end_datel
                 ) AD,
                 bim_r_fdsp_load AU,
                (SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'CAMP' object_type_J,'CAMP' object_type, D.campaign_id object_id
                FROM ams_campaigns_all_b D
               UNION ALL
               SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'CSCH' object_type_J,'CSCH' object_type,B.SCHEDULE_ID object_id
               FROM
                    ams_campaigns_all_b D,
                    ams_campaign_schedules_b B
               WHERE B.campaign_id = D.campaign_id (+)
               UNION ALL
               SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'EVEH' object_type_J,'EVEH' object_type, D.event_header_id object_id
               FROM
                    ams_event_headers_all_b D
               UNION ALL
               SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'EVEO' object_type_J, 'EVEO' object_type, D.event_offer_id object_id
               FROM
                    ams_event_offers_all_b D
               WHERE event_header_id is not null
               UNION ALL
               SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'EONE' object_type_J, 'EONE' object_type, D.event_offer_id object_id
               FROM
                    ams_event_offers_all_b D
               WHERE event_header_id is null
               UNION ALL
               SELECT
                 BC.business_unit_id business_unit_id,BC.org_id org_id,
                 'OFFR' object_type_J, 'OFFR' object_type, D.qp_list_header_id object_id
               FROM
                    ams_campaigns_all_b BC,
                    ams_act_offers D
               WHERE
                  D.arc_act_offer_used_by (+)   = 'CAMP'  AND D.act_offer_used_by_id =
                 BC.campaign_id (+)    AND BC.show_campaign_flag (+)   = 'Y'
               UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'CAMPDELV' object_type,  D.using_object_id object_id
                FROM
                     ams_campaigns_all_b BA,
                     ams_object_associations D
                WHERE
                 D.using_object_type='DELV' AND
                 D.master_object_type (+)   = 'CAMP'  AND
                 D.master_object_id = BA.campaign_id (+)
                UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'CSCHDELV' object_type, D.using_object_id object_id
                FROM
                     ams_campaigns_all_b BA,
                     ams_campaign_schedules_b E,
                     ams_object_associations D
                WHERE
                 D.master_object_type (+)   = 'CSCH'  AND D.master_object_id = E.SCHEDULE_ID
                 (+)    AND E.campaign_id = BA.campaign_id (+)
                 AND D.using_object_type (+)   = 'DELV'
                UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'EVEHDELV' object_type, D.using_object_id object_id
                FROM
                     ams_event_headers_all_b BA,
                     ams_object_associations D
                WHERE 	D.using_object_type(+) = 'DELV'
                AND  	D.master_object_type(+) = 'EVEH'
                AND 	D.master_object_id = BA.event_header_id (+)
                UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'EVEODELV' object_type, D.using_object_id object_id
                FROM
                     ams_event_offers_all_b BA,
                     ams_object_associations D
                WHERE 	D.using_object_type(+) = 'DELV'
                AND  	D.master_object_type(+) = 'EVEO'
                AND 	D.master_object_id = BA.event_offer_id (+)
                UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'EONEDELV' object_type, D.using_object_id object_id
                FROM
                     ams_event_offers_all_b BA,
                     ams_object_associations D
                WHERE 	D.using_object_type(+) = 'DELV'
                AND  	D.master_object_type(+) = 'EONE'
                AND 	D.master_object_id = BA.event_offer_id (+)
                 ) U
               WHERE 	AU.object_type  = U.object_type_J (+)
               AND 	AU.object_id = U.object_id (+)
               AND 	AU.fund_id (+)   = AD.fund_id
               AND 	AU.transaction_create_date (+)   BETWEEN TRUNC(AD.trdate) AND TRUNC(AD.trdate) + 0.99999
               ) inner;
             l_count :=l_count +SQL%ROWCOUNT;
             EXECUTE IMMEDIATE 'COMMIT';
             EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fdsp_daily_facts_s CACHE 20';
        EXCEPTION
        WHEN OTHERS THEN
        FND_FILE.put_line(fnd_file.log,'error insert fdsp daily'||sqlerrm(sqlcode));
       --dbms_output.put_line('error inserting INTO bim_r_fdsp_daily_facts'||sqlerrm(sqlcode));
        EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fdsp_daily_facts_s CACHE 20';
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
        FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
        FND_MSG_PUB.Add;
        END ;

     /* Second insert: extra records which happened before start date active */
    fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
   fnd_message.set_token('table_name', l_table_name, FALSE);
   fnd_file.put_line(fnd_file.log,fnd_message.get);
     BEGIN
     INSERT INTO bim_r_fdsp_daily_facts fdf(
            spend_transaction_id
            ,creation_date
            ,last_update_date
            ,created_by
            ,last_updated_by
            ,last_update_login
            ,fund_id
            ,business_unit_id
            ,util_org_id
            ,standard_discount
            ,accrual
            ,market_expense
            ,commited_amt
            ,planned_amt
            ,paid_amt
            ,delete_flag
            ,transaction_create_date
            ,load_date
            ,object_id
            ,object_type
            ,fis_month
            ,fis_qtr
            ,fis_year
            )
      SELECT
            bim_r_fdsp_daily_facts_s.nextval,
             sysdate,
             sysdate,
             l_user_id,
             l_user_id,
             l_user_id,
             inner.fund_id,
             inner.business_unit_id,
             inner.org_id,
             inner.standard_discount,
             inner.accrual,
             inner.market_expense,
             inner.commited_amt,
             inner.planned_amt,
             inner.paid_amt,
             'N',
             inner.transaction_create_date,
            trunc((decode(decode( to_char(inner.transaction_create_date,'MM') , to_char(next_day(inner.transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(inner.transaction_create_date , (next_day(inner.transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,inner.transaction_create_date
      	        ,'FALSE'
      	        ,next_day(inner.transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(inner.transaction_create_date,'MM'),to_char(next_day(inner.transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(inner.transaction_create_date)))))         weekend_date
            ,inner.object_id
            ,inner.object_type
           ,BIM_SET_OF_BOOKS.get_fiscal_month(inner.transaction_create_date,204)
            ,BIM_SET_OF_BOOKS.get_fiscal_qtr(inner.transaction_create_date,204)
            ,BIM_SET_OF_BOOKS.get_fiscal_year(inner.transaction_create_date,204)
FROM      (SELECT AD.fund_id fund_id,
  	         U.business_unit_id business_unit_id,
  	         U.org_id org_id,
  	         NVL(AU.standard_discount,0) standard_discount,
  	         NVL(AU.accrual,0) accrual,
  	         NVL(AU.market_expense,0) market_expense,
  	         NVL(AU.commited_amt,0) commited_amt,
  	         NVL(AU.planned_amt,0) planned_amt,
  	         NVL(AU.paid_amt,0) paid_amt,
  	         AU.object_id object_id,
  	         U.object_type object_type,
  	         AU.transaction_create_date transaction_create_date
          FROM   ozf_funds_all_b AD,
                 bim_r_fdsp_load AU,
                (SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'CAMP' object_type_J,'CAMP' object_type, D.campaign_id object_id
                FROM ams_campaigns_all_b D
               UNION ALL
               SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'CSCH' object_type_J,'CSCH' object_type,B.SCHEDULE_ID object_id
               FROM
                    ams_campaigns_all_b D,
                    ams_campaign_schedules_b B
               WHERE B.campaign_id = D.campaign_id (+)
               UNION ALL
               SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'EVEH' object_type_J,'EVEH' object_type, D.event_header_id object_id
               FROM
                    ams_event_headers_all_b D
               UNION ALL
               SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'EVEO' object_type_J, 'EVEO' object_type, D.event_offer_id object_id
               FROM
                    ams_event_offers_all_b D
               WHERE event_header_id is not null
               UNION ALL
               SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'EONE' object_type_J, 'EONE' object_type, D.event_offer_id object_id
               FROM
                    ams_event_offers_all_b D
               WHERE event_header_id is null
               UNION ALL
               SELECT
                 BC.business_unit_id business_unit_id,BC.org_id org_id,
                 'OFFR' object_type_J, 'OFFR' object_type, D.qp_list_header_id object_id
               FROM
                    ams_campaigns_all_b BC,
                    ams_act_offers D
               WHERE
                  D.arc_act_offer_used_by (+)   = 'CAMP'  AND D.act_offer_used_by_id =
                 BC.campaign_id (+)    AND BC.show_campaign_flag (+)   = 'Y'
               UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'CAMPDELV' object_type,  D.using_object_id object_id
                FROM
                     ams_campaigns_all_b BA,
                     ams_object_associations D
                WHERE
                 D.using_object_type='DELV' AND
                 D.master_object_type (+)   = 'CAMP'  AND
                 D.master_object_id = BA.campaign_id (+)
                UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'CSCHDELV' object_type, D.using_object_id object_id
                FROM
                     ams_campaigns_all_b BA,
                     ams_campaign_schedules_b E,
                     ams_object_associations D
                WHERE
                 D.master_object_type (+)   = 'CSCH'  AND D.master_object_id = E.SCHEDULE_ID
                 (+)    AND E.campaign_id = BA.campaign_id (+)
                 AND D.using_object_type (+)   = 'DELV'
                UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'EVEHDELV' object_type, D.using_object_id object_id
                FROM
                     ams_event_headers_all_b BA,
                     ams_object_associations D
                WHERE 	D.using_object_type(+) = 'DELV'
                AND  	D.master_object_type(+) = 'EVEH'
                AND 	D.master_object_id = BA.event_header_id (+)
                UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'EVEODELV' object_type, D.using_object_id object_id
                FROM
                     ams_event_offers_all_b BA,
                     ams_object_associations D
                WHERE 	D.using_object_type(+) = 'DELV'
                AND  	D.master_object_type(+) = 'EVEO'
                AND 	D.master_object_id = BA.event_offer_id (+)
                UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'EONEDELV' object_type, D.using_object_id object_id
                FROM
                     ams_event_offers_all_b BA,
                     ams_object_associations D
                WHERE 	D.using_object_type(+) = 'DELV'
                AND  	D.master_object_type(+) = 'EONE'
                AND 	D.master_object_id = BA.event_offer_id (+)
                 ) U
               WHERE 	AD.start_date_active between p_start_datel and p_end_datel
               AND      AD.status_code in ('ACTIVE', 'CANCELLED', 'CLOSED')
               AND 	AU.fund_id (+)   = AD.fund_id
               AND      AU.object_type  = U.object_type_J (+)
               AND 	AU.object_id = U.object_id (+)
               AND 	AU.transaction_create_date <AD.start_date_active
               ) inner;
               l_count :=l_count+SQL%ROWCOUNT;
            EXECUTE IMMEDIATE 'commit';
     EXCEPTION
      WHEN others THEN
       FND_FILE.put_line(fnd_file.log,'error insert extras into fdsp daily'||sqlerrm(sqlcode));
        --dbms_output.put_line('error inserting extra INTO bim_r_fdsp_daily_facts'||sqlerrm(sqlcode));
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
        FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
        FND_MSG_PUB.Add;
   END;
  -- dbms_output.put_line('l_count'||l_count);
   fnd_message.set_name('BIM','BIM_R_CALL_PROC');
   fnd_message.set_token('proc_name', 'LOG_HISTORY', FALSE);
   fnd_file.put_line(fnd_file.log,fnd_message.get);
  /* Insert into history table */
   --IF l_count>0  THEN
     LOG_HISTORY(
     'FUND',
     p_start_datel,
     p_end_datel,
     x_msg_count,
     x_msg_data,
     x_return_status) ;
   --END IF;

   /* There are discrete dates in bim_r_fund_daily_facts and bim_r_fdsp_daily_facts,because of
      the pre-approvals. So, we want to make them have the same dates by inserting into each
      table the dates in one table but not in another table for the same funds.*/
   BEGIN
  -- dbms_output.put_line('balancing');

    /* Insert into bim_r_fund_daily_facts the dates which are in bim_r_fdsp_daily_facts
       but not in bim_r_fund_daily_facts. */
     fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
     fnd_message.set_token('table_name', 'BIM_R_FUND_DAILY_FACTS', FALSE);
     fnd_file.put_line(fnd_file.log,fnd_message.get);
    INSERT into bim_r_fund_daily_facts(
         fund_transaction_id
        ,creation_date
        ,last_update_date
        ,created_by
        ,last_updated_by
        ,last_update_login
        ,fund_id
        ,parent_fund_id
        ,fund_number
        ,start_date
        ,end_date
        ,start_period
        ,end_period
        ,set_of_books_id
        ,fund_type
        --,region
        ,country
        ,org_id
        ,category_id
        ,status
        ,original_budget
        ,transfer_in
        ,transfer_out
        ,holdback_amt
        ,currency_code_fc
        ,delete_flag
        ,transaction_create_date
        ,load_date
        ,fis_month
        ,fis_qtr
        ,fis_year
        ,business_unit_id)
    SELECT
        bim_r_fund_daily_facts_s.nextval,
        sysdate,
        sysdate,
        l_user_id,
        l_user_id,
        l_user_id,
        a.fund_id ,
        a.parent_fund_id parent_fund_id,
        a.fund_number fund_number,
        a.start_date_active start_date,
        a.end_date_active end_date,
        a.start_period_name start_period,
        a.end_period_name end_period,
        a.set_of_books_id set_of_book_id,
        a.fund_type fund_type,
        a.country_id country,
        a.org_id org_id,
        a.category_id fund_category,
        a.status_code fund_status,
        a.original_budget original_amount,
        0,
        0,
        0,
        a.currency_code_fc,
        'N',
        b2.transaction_create_date,
        trunc((decode(decode( to_char(transaction_create_date,'MM') , to_char(next_day(transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(transaction_create_date , (next_day(transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,transaction_create_date
      	        ,'FALSE'
      	        ,next_day(transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(transaction_create_date,'MM'),to_char(next_day(transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(transaction_create_date))))),
        b2.fis_month,
        b2.fis_qtr,
        b2.fis_year,
        a.business_unit_id
    FROM ozf_funds_all_b a,
         (SELECT distinct(fund_id) fund_id,
                 fis_month fis_month,
                 fis_qtr fis_qtr,
                 fis_year fis_year,
                 transaction_create_date transaction_create_date
          FROM   bim_r_fdsp_daily_facts fdsp
         WHERE fund_id is not null
         AND transaction_create_date is not null
         AND (fund_id, transaction_create_date) not in
          ( SELECT /*+ hash_aj */ fund_id, transaction_create_date
            from bim_r_fund_daily_facts b1
            )) b2
    WHERE b2.fund_id = a.fund_id;
    EXECUTE IMMEDIATE 'commit';
 EXCEPTION
 WHEN OTHERS THEN
        FND_FILE.put_line(fnd_file.log,'error insert fund daily for balancing'||sqlerrm(sqlcode));
       -- dbms_output.put_line('error insert fund_daily for balancing with fdsp'||sqlerrm(sqlcode));
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
        FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
        FND_MSG_PUB.Add;
        fnd_file.put_line(fnd_file.log,fnd_message.get);
 END;
 /* Start of inserting into 'bim_r_fund_weekly_facts'.
    Weekly table are summarized on daily tables. */
 BEGIN
 l_table_name :='bim_r_fund_weekly_facts';
   fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
   fnd_message.set_token('table_name', l_table_name, FALSE);
   fnd_file.put_line(fnd_file.log,fnd_message.get);
   EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fund_weekly_facts_s CACHE 1000';
   INSERT /*+ append parallel(fwf,p_para_num) */ INTO bim_r_fund_weekly_facts fwf(
      fund_transaction_id
     ,creation_date
     ,last_update_date
     ,created_by
     ,last_updated_by
     ,last_update_login
     ,fund_id
     ,parent_fund_id
     ,fund_number
     ,start_date
     ,end_date
     ,start_period
     ,end_period
     ,set_of_books_id
     ,fund_type
    -- ,region
     ,country
     ,org_id
     ,category_id
     ,status
     ,original_budget
     ,transfer_in
     ,transfer_out
     ,holdback_amt
     ,currency_code_fc
     ,delete_flag
     ,transaction_create_date
     ,load_date
     ,fis_month
     ,fis_qtr
     ,fis_year
     ,business_unit_id)
  SELECT /*+ parallel(inner, p_para_num) */
      bim_r_fund_weekly_facts_s.nextval
     ,sysdate
     ,sysdate
     ,l_user_id
     ,l_user_id
     ,l_user_id
     ,inner.fund_id
     ,inner.parent_fund_id
     ,inner.fund_number
     ,inner.start_date
     ,inner.end_date
     ,inner.start_period
     ,inner.end_period
     ,inner.set_of_books_id
     ,inner.fund_type
     --,inner.region
     ,inner.country
     ,inner.org_id
     ,inner.category_id
     ,inner.status
     ,inner.original_budget
     ,inner.transfer_in
     ,inner.transfer_out
     ,inner.holdback_amt
     ,inner.currency_code_fc
     ,'N'
     ,inner.load_date
     ,inner.load_date
     ,BIM_SET_OF_BOOKS.get_fiscal_month(inner.load_date,204)
     ,BIM_SET_OF_BOOKS.get_fiscal_qtr(inner.load_date,204)
     ,BIM_SET_OF_BOOKS.get_fiscal_year(inner.load_date,204)
     ,inner.business_unit_id
FROM(SELECT fund_id fund_id
            ,parent_fund_id parent_fund_id
            ,fund_number fund_number
            ,start_date start_date
            ,end_date end_date
            ,start_period start_period
            ,end_period  end_period
            ,set_of_books_id set_of_books_id
            ,fund_type fund_type
            --,region region
            ,country country
            ,org_id  org_id
            ,business_unit_id business_unit_id
            ,category_id category_id
            ,status status
            ,original_budget original_budget
            ,SUM(transfer_in) transfer_in
            ,SUM(transfer_out) transfer_out
            ,SUM(holdback_amt) holdback_amt
            ,currency_code_fc  currency_code_fc
            ,load_date load_date
     FROM bim_r_fund_daily_facts
     GROUP BY
           fund_id
          ,load_date
          ,parent_fund_id
          ,fund_number
          ,start_date
          ,end_date
          ,start_period
          ,end_period
          ,set_of_books_id
          ,fund_type
         -- ,region
          ,country
          ,org_id
          ,business_unit_id
          ,category_id
          ,status
          ,original_budget
          ,currency_code_fc) inner;
           EXECUTE IMMEDIATE 'commit';
    EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fund_weekly_facts_s CACHE 20';
    EXCEPTION
      WHEN others THEN
        FND_FILE.put_line(fnd_file.log,'Error insertg fund weekly:'||sqlerrm(sqlcode));
       -- dbms_output.put_line('Errorin inserting fund weekly:'||sqlerrm(sqlcode));
          EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fund_weekly_facts_s CACHE 20';
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
          FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
          FND_MSG_PUB.Add;
    END;
/* Insert into bim_r_fdsp_weekly_facts. */
BEGIN
  l_table_name :='bim_r_fdsp_weekly_facts';
  fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
   fnd_message.set_token('table_name', l_table_name, FALSE);
   fnd_file.put_line(fnd_file.log,fnd_message.get);
  EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fdsp_weekly_facts_s CACHE 1000';
 INSERT /*+ append parallel(fwf,p_para_num) */
 INTO bim_r_fdsp_weekly_facts fwf(
   spend_transaction_id
  ,creation_date
  ,last_update_date
  ,created_by
  ,last_updated_by
  ,last_update_login
  ,fund_id
  ,business_unit_id
  ,util_org_id
  ,standard_discount
  ,accrual
  ,market_expense
  ,commited_amt
  ,planned_amt
  ,paid_amt
  ,delete_flag
  ,transaction_create_date
  ,load_date
  ,object_id
  ,object_type
  ,fis_month
  ,fis_qtr
  ,fis_year
  )
  SELECT /*+ parallel(inner.p_para_num) */
  bim_r_fdsp_weekly_facts_s.nextval
  ,sysdate
  ,sysdate
  ,l_user_id
  ,l_user_id
  ,l_user_id
  ,inner.fund_id
  ,inner.business_unit_id
  ,inner.util_org_id
  ,inner.standard_discount
  ,inner.accrual
  ,inner.market_expense
  ,inner.commited_amt
  ,inner.planned_amt
  ,inner.paid_amt
  ,'N'
  ,inner.load_date
  ,inner.load_date
  ,inner.object_id
  ,inner.object_type
  ,BIM_SET_OF_BOOKS.get_fiscal_month(inner.load_date,204)
  ,BIM_SET_OF_BOOKS.get_fiscal_qtr(inner.load_date,204)
  ,BIM_SET_OF_BOOKS.get_fiscal_year(inner.load_date,204)
FROM
   (SELECT fund_id fund_id
  ,business_unit_id business_unit_id
  ,util_org_id util_org_id
  ,object_id object_id
  ,object_type object_type
  ,SUM(standard_discount) standard_discount
  ,SUM(accrual) accrual
  ,SUM(market_expense) market_expense
  ,SUM(commited_amt) commited_amt
  ,SUM(planned_amt) planned_amt
  ,SUM(paid_amt)  paid_amt
  ,load_date load_date
  FROM bim_r_fdsp_daily_facts
  GROUP BY load_date
  ,business_unit_id
  ,object_id
  ,object_type
  ,fund_id
  ,util_org_id) inner;
  EXECUTE IMMEDIATE 'commit';
  EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fdsp_weekly_facts_s CACHE 20';
EXCEPTION
      when others THEN
      FND_FILE.put_line(fnd_file.log,'error insert fdsp_weekly'||sqlerrm(sqlcode));
       -- dbms_output.put_line('error inserting INTO bim_r_fdsp_weekly_facts'||sqlerrm(sqlcode));
        EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fdsp_weekly_facts_s CACHE 20';
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
        FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
        FND_MSG_PUB.Add;
 END;

fnd_message.set_name('BIM','BIM_R_RECREATE_INDEXES');
fnd_file.put_line(fnd_file.log,fnd_message.get);
 /* Piece of Code for Recreating the index on the same tablespace with the same storage parameters */
BEGIN
i := i - 1;
WHILE(i>=1) LOOP

IF (i>1) AND (l_index_name(i) =l_index_name(i-1)) THEN
  l_col_num :=l_col_num||l_ind_column_name(i)||',';
ELSE
  l_col_num :=l_col_num||l_ind_column_name(i);

  EXECUTE IMMEDIATE 'CREATE INDEX '
    || l_owner(i)
    || '.'
    || l_index_name(i)
    ||' ON '
    || l_owner(i)
    ||'.'
    || l_index_table_name(i)
    || ' ('
    || l_col_num
    || ' )'
            || ' tablespace '  || l_index_tablespace
            || ' pctfree     ' || l_pct_free(i)
            || ' initrans '    || l_ini_trans(i)
            || ' maxtrans  '   || l_max_trans(i)
            || ' storage ( '
            || ' initial '     || l_initial_extent(i)
            || ' next '        || l_next_extent(i)
            || ' minextents '  || l_min_extents(i)
            || ' maxextents '  || l_max_extents(i)
            || ' pctincrease ' || l_pct_increase(i)
            || ')'
            || ' compute statistics';
  l_col_num :='';
END IF;
            i := i - 1;
 END LOOP;
EXCEPTION
WHEN OTHERS THEN
 null;
  --FND_FILE.put_line(fnd_file.log,'error creating all indexes'||sqlerrm(sqlcode));
-- DBMS_OUTPUT.PUT_LINE(sqlerrm(sqlcode));
END;

  -- For performance reasons.
  BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fund_weekly_facts noparallel';
  EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fdsp_weekly_facts noparallel';
  EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fund_balance noparallel';
  EXCEPTION
  WHEN OTHERS THEN
  null;
  END;
  BEGIN
   DBMS_STATS.gather_table_stats('BIM','BIM_R_FUND_DAILY_FACTS', estimate_percent => 5,
                               degree => 8, granularity => 'GLOBAL', cascade =>TRUE);
  END;
  BEGIN
   DBMS_STATS.gather_table_stats('BIM','BIM_R_FUND_WEEKLY_FACTS', estimate_percent => 5,
                               degree => 8, granularity => 'GLOBAL', cascade =>TRUE);
  END;
  BEGIN
   DBMS_STATS.gather_table_stats('BIM','BIM_R_FDSP_DAILY_FACTS', estimate_percent => 5,
                               degree => 8, granularity => 'GLOBAL', cascade =>TRUE);
  END;
  BEGIN
   DBMS_STATS.gather_table_stats('BIM','BIM_R_FDSP_WEEKLY_FACTS', estimate_percent => 5,
                               degree => 8, granularity => 'GLOBAL', cascade =>TRUE);
  END;
  fnd_message.set_name('BIM','BIM_R_CALL_PROC');
   fnd_message.set_token('proc_name', 'UPDATE_BALANCE', FALSE);
   fnd_file.put_line(fnd_file.log,fnd_message.get);
  update_balance;
   EXECUTE IMMEDIATE 'COMMIT';
  fnd_message.set_name('BIM','BIM_R_PROG_COMPLETION');
  fnd_message.set_token('program_name', 'Fund first load', FALSE);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
END FUND_FIRST_LOAD;


---------------------------------------------------------------------
-- PROCEDURE
--    FUND_SUB_LOAD
-- NOTE This procedure will be executed when load data subsequently.
--      p_start_datel is replaced by the maximum loading date from
--      history table,
--      and transactions happened before fund active data are also captured.
---------------------------------------------------------------------
PROCEDURE FUND_SUB_LOAD(
    p_start_datel           DATE,
    p_end_datel             DATE,
    p_para_num              NUMBER       ,
    x_msg_count             OUT NOCOPY NUMBER       ,
    x_msg_data              OUT NOCOPY VARCHAR2     ,
    x_return_status         OUT NOCOPY VARCHAR2
   )
   IS
   l_user_id    NUMBER := FND_GLOBAL.USER_ID();
   l_last_update_date   DATE;
   l_success   varchar2(1) := 'F';
   l_api_version_number      CONSTANT NUMBER       := 1.0;
   l_api_name                CONSTANT VARCHAR2(30) := 'FUND_SUB_LOAD';
   l_table_name            VARCHAR2(100);
   l_count                 NUMBER:=0;
   l_end_date              DATE;



 l_status                      VARCHAR2(5);
 l_industry                    VARCHAR2(5);
 l_schema                      VARCHAR2(30);
 l_return                       BOOLEAN;

  BEGIN
      l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        l_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Debug Message
   --AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

   -- Initialize API RETURN status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Make sure p_end_date is not greate than sysdate-1
   IF (trunc(p_end_datel) =trunc(sysdate)) THEN
      l_end_date :=trunc(sysdate-1);
   ELSE
      l_end_date :=p_end_datel;
   END IF;
   l_table_name :='bim_r_fund_daily_facts';
   fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
   fnd_message.set_token('table_name', l_table_name, FALSE);
   fnd_file.put_line(fnd_file.log,fnd_message.get);
   --dbms_output.put_line('b4 first inserting into fund daily');

   BEGIN -- Alter table for performance reasons
   EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fund_daily_facts nologging';
   EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fund_weekly_facts nologging';
   EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fdsp_daily_facts nologging';
   EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fdsp_weekly_facts nologging';
   EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fund_daily_facts_s CACHE 1000';

   /* First insert: Insert transactions happened between p_start_date and p_end_date. */
   INSERT /*+ append parallel(fdf,p_para_num) */
   INTO bim_r_fund_daily_facts fdf(
         fund_transaction_id
        ,creation_date
        ,last_update_date
        ,created_by
        ,last_updated_by
        ,last_update_login
        ,fund_id
        ,parent_fund_id
        ,fund_number
        ,start_date
        ,end_date
        ,start_period
        ,end_period
        ,set_of_books_id
        ,fund_type
        --,region
        ,country
        ,org_id
        ,category_id
        ,status
        ,original_budget
        ,transfer_in
        ,transfer_out
        ,holdback_amt
        ,currency_code_fc
        ,delete_flag
        ,transaction_create_date
        ,load_date
        ,fis_month
        ,fis_qtr
        ,fis_year
        ,business_unit_id)
        --,security_group_id)
SELECT  /*+ parallel(inner, p_para_num) */
bim_r_fund_daily_facts_s.nextval,
       sysdate,
       sysdate,
       l_user_id,
       l_user_id,
       l_user_id,
       inner.fund_id,
       inner.parent_fund_id,
       inner.fund_number,
       inner.start_date,
       inner.end_date,
       inner.start_period,
       inner.end_period,
       inner.set_of_books_id,
       inner.fund_type,
       --inner.region,
       inner.country,
       inner.org_id,
       inner.category_id,
       inner.status,
       inner.original_budget,
       inner.transfer_in,
       inner.transfer_out,
       inner.holdback,
       inner.currency_code_fc,
       'N',
       inner.transaction_create_date,
       inner.weekend_date,
       BIM_SET_OF_BOOKS.get_fiscal_month(inner.transaction_create_date,204),
       BIM_SET_OF_BOOKS.get_fiscal_qtr(inner.transaction_create_date,204),
       BIM_SET_OF_BOOKS.get_fiscal_year(inner.transaction_create_date,204),
       inner.business_unit_id
FROM (
SELECT    fund_id fund_id,
          fund_number fund_number,
          start_date start_date,
          end_date end_date,
          start_period start_period,
          end_period end_period,
          category_id category_id,
          status status,
          fund_type fund_type,
          parent_fund_id parent_fund_id,
          country country,
          org_id org_id,
          business_unit_id business_unit_id,
          set_of_books_id set_of_books_id,
          currency_code_fc currency_code_fc,
          original_budget original_budget,
          transaction_create_date transaction_create_date,
          trunc((decode(decode( to_char(transaction_create_date,'MM') , to_char(next_day(transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(transaction_create_date , (next_day(transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,transaction_create_date
      	        ,'FALSE'
      	        ,next_day(transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(transaction_create_date,'MM'),to_char(next_day(transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(transaction_create_date)))))         weekend_date,
          SUM(transfer_in) transfer_in,
          SUM(transfer_out) transfer_out,
          SUM(holdback) holdback
FROM
(SELECT    ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          ad.original_budget original_budget,
          trunc(bu1.approval_date) transaction_create_date,
          nvl(SUM(convert_currency(bu1.approved_in_currency,nvl(bu1.approved_original_amount,0))),0) transfer_in,
          0     transfer_out,
          0     holdback
FROM      ozf_funds_all_b ad,
          ozf_act_budgets BU1
   WHERE  bu1.approval_date between p_start_datel and p_end_datel + 0.99999
   AND    ad.status_code in ('ACTIVE', 'CANCELLED', 'CLOSED')
   AND    bu1.transfer_type in ('TRANSFER','REQUEST')
   AND    bu1.status_code(+) = 'APPROVED'
   AND    bu1.arc_act_budget_used_by(+) = 'FUND'
   AND    bu1.act_budget_used_by_id(+) = ad.fund_id
   AND    bu1.budget_source_type(+) ='FUND'
   GROUP BY ad.fund_id,
          trunc(bu1.approval_date),
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.business_unit_id,
          ad.org_id ,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget
UNION ALL
  SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          ad.original_budget original_budget,
          TRUNC(bu2.approval_date) transaction_create_date,
          0   transfer_in,
          nvl(SUM(decode(bu2.transfer_type,'TRANSFER', convert_currency(bu2.approved_in_currency,nvl(bu2.approved_original_amount,0)))),0)
          +nvl(SUM(decode(bu2.transfer_type,'REQUEST', convert_currency(bu2.approved_in_currency,nvl(bu2.approved_original_amount,0)))),0) transfer_out,
          nvl(SUM(decode(bu2.transfer_type, 'RESERVE', convert_currency(bu2.approved_in_currency,nvl(bu2.approved_original_amount,0)))),0)-
          nvl(SUM(decode(bu2.transfer_type, 'RELEASE', convert_currency(bu2.approved_in_currency,nvl(bu2.approved_original_amount,0)))),0) holdback
   FROM   ozf_funds_all_b ad,
          ozf_act_budgets BU2
   WHERE  bu2.approval_date between p_start_datel and p_end_datel + 0.99999
   AND    ad.status_code in ('ACTIVE', 'CANCELLED', 'CLOSED')
   AND    bu2.status_code = 'APPROVED'
   AND    bu2.arc_act_budget_used_by = 'FUND'
   AND    bu2.budget_source_type ='FUND'
   AND    bu2.budget_source_id = ad.fund_id
   GROUP BY ad.fund_id,
          trunc(bu2.approval_date) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget)
   GROUP BY
          fund_id,
          transaction_create_date,
          fund_number,
          start_date,
          end_date,
          start_period,
          end_period,
          category_id,
          status,
          fund_type,
          parent_fund_id,
          country,
          org_id,
          business_unit_id,
          set_of_books_id,
          currency_code_fc,
          original_budget
           )inner;
          l_count:=l_count+SQL%ROWCOUNT;
          EXECUTE IMMEDIATE 'COMMIT';
      EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fund_daily_facts_s CACHE 20';
      EXCEPTION
      WHEN others THEN
       FND_FILE.put_line(fnd_file.log,'error insert into fund_daily'||sqlerrm(sqlcode));
        --dbms_output.put_line('error inserting INTO bim_r_fund_daily_facts'||sqlerrm(sqlcode));
      EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fund_daily_facts_s CACHE 20';
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
        FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
        FND_MSG_PUB.Add;
      END;

     /*Second insert: For funds whose active date is between p_start_date and p_end_date, insert
      transactions happened before active date */
     fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
     fnd_message.set_token('table_name', l_table_name, FALSE);
     fnd_file.put_line(fnd_file.log,fnd_message.get);
     BEGIN
   INSERT /*+ append parallel(fdf,p_para_num) */
   INTO bim_r_fund_daily_facts fdf(
         fund_transaction_id
        ,creation_date
        ,last_update_date
        ,created_by
        ,last_updated_by
        ,last_update_login
        ,fund_id
        ,parent_fund_id
        ,fund_number
        ,start_date
        ,end_date
        ,start_period
        ,end_period
        ,set_of_books_id
        ,fund_type
        --,region
        ,country
        ,org_id
        ,category_id
        ,status
        ,original_budget
        ,transfer_in
        ,transfer_out
        ,holdback_amt
        ,currency_code_fc
        ,delete_flag
        ,transaction_create_date
        ,load_date
        ,fis_month
        ,fis_qtr
        ,fis_year
        ,business_unit_id)
        --,security_group_id)
SELECT  /*+ parallel(inner, p_para_num) */
bim_r_fund_daily_facts_s.nextval,
       sysdate,
       sysdate,
       l_user_id,
       l_user_id,
       l_user_id,
       inner.fund_id,
       inner.parent_fund_id,
       inner.fund_number,
       inner.start_date,
       inner.end_date,
       inner.start_period,
       inner.end_period,
       inner.set_of_books_id,
       inner.fund_type,
       --inner.region,
       inner.country,
       inner.org_id,
       inner.category_id,
       inner.status,
       inner.original_budget,
       inner.transfer_in,
       inner.transfer_out,
       inner.holdback,
       inner.currency_code_fc,
       'N',
       inner.transaction_create_date,
       inner.weekend_date,
       BIM_SET_OF_BOOKS.get_fiscal_month(inner.transaction_create_date,204),
       BIM_SET_OF_BOOKS.get_fiscal_qtr(inner.transaction_create_date,204),
       BIM_SET_OF_BOOKS.get_fiscal_year(inner.transaction_create_date,204),
       inner.business_unit_id
FROM (
SELECT    fund_id fund_id,
          fund_number fund_number,
          start_date start_date,
          end_date end_date,
          start_period start_period,
          end_period end_period,
          category_id category_id,
          status status,
          fund_type fund_type,
          parent_fund_id parent_fund_id,
          country country,
          org_id org_id,
          business_unit_id business_unit_id,
          set_of_books_id set_of_books_id,
          currency_code_fc currency_code_fc,
          original_budget original_budget,
          transaction_create_date transaction_create_date,
          trunc((decode(decode( to_char(transaction_create_date,'MM') , to_char(next_day(transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(transaction_create_date , (next_day(transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,transaction_create_date
      	        ,'FALSE'
      	        ,next_day(transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(transaction_create_date,'MM'),to_char(next_day(transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(transaction_create_date)))))         weekend_date,
          SUM(transfer_in) transfer_in,
          SUM(transfer_out) transfer_out,
          SUM(holdback) holdback
FROM
(SELECT    ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          ad.original_budget original_budget,
          trunc(bu1.approval_date) transaction_create_date,
          nvl(SUM(convert_currency(bu1.approved_in_currency,nvl(bu1.approved_original_amount,0))),0) transfer_in,
          0     transfer_out,
          0     holdback
FROM      ozf_funds_all_b ad,
          ozf_act_budgets BU1
   WHERE  bu1.approval_date < p_start_datel
   AND    ad.status_code in ('ACTIVE', 'CANCELLED', 'CLOSED')
   AND    ad.start_date_active between p_start_datel and p_end_datel
   AND    bu1.transfer_type in ('TRANSFER','REQUEST')
   AND    bu1.status_code = 'APPROVED'
   AND    bu1.arc_act_budget_used_by = 'FUND'
   AND    bu1.act_budget_used_by_id = ad.fund_id
   AND    bu1.budget_source_type ='FUND'
   GROUP BY ad.fund_id,
          trunc(bu1.approval_date),
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.business_unit_id,
          ad.org_id ,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget
UNION ALL
  SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          ad.original_budget original_budget,
          TRUNC(bu2.approval_date) transaction_create_date,
          0   transfer_in,
          nvl(SUM(decode(bu2.transfer_type,'TRANSFER', convert_currency(bu2.approved_in_currency,nvl(bu2.approved_original_amount,0)))),0)
          +nvl(SUM(decode(bu2.transfer_type,'REQUEST', convert_currency(bu2.approved_in_currency,nvl(bu2.approved_original_amount,0)))),0) transfer_out,
          nvl(SUM(decode(bu2.transfer_type, 'RESERVE', convert_currency(bu2.approved_in_currency,nvl(bu2.approved_original_amount,0)))),0)-
          nvl(SUM(decode(bu2.transfer_type, 'RELEASE', convert_currency(bu2.approved_in_currency,nvl(bu2.approved_original_amount,0)))),0) holdback
   FROM   ozf_funds_all_b ad,
          ozf_act_budgets BU2
   WHERE  bu2.approval_date < p_start_datel
   AND    ad.status_code in ('ACTIVE', 'CANCELLED', 'CLOSED')
   AND    ad.start_date_active between p_start_datel and p_end_datel
   AND    bu2.status_code = 'APPROVED'
   AND    bu2.arc_act_budget_used_by = 'FUND'
   AND    bu2.budget_source_type ='FUND'
   AND    bu2.budget_source_id = ad.fund_id
   GROUP BY ad.fund_id,
          trunc(bu2.approval_date) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget)
   GROUP BY
          fund_id,
          transaction_create_date,
          fund_number,
          start_date,
          end_date,
          start_period,
          end_period,
          category_id,
          status,
          fund_type,
          parent_fund_id,
          country,
          org_id,
          business_unit_id,
          set_of_books_id,
          currency_code_fc,
          original_budget
           )inner;
   l_count:=l_count+SQL%ROWCOUNT;
   EXECUTE IMMEDIATE 'commit';
      --End inserting transactions happened before start_date
     EXCEPTION
      WHEN others THEN
        FND_FILE.put_line(fnd_file.log,'error insert into fund_daily for transactions happened b4 start date'||sqlerrm(sqlcode));
        --dbms_output.put_line('error looping inserting INTO bim_r_fund_daily_facts'||sqlerrm(sqlcode));
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
        FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
        FND_MSG_PUB.Add;
      END;

      /* insert dummy 0s for dates between p_start_date/start_date_active and p_end_date/end_date_active,
       but has no transactions.*/
      fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
      fnd_message.set_token('table_name', l_table_name, FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      BEGIN
       INSERT /*+ append parallel(fdf,p_para_num) */
       INTO bim_r_fund_daily_facts fdf(
         fund_transaction_id
        ,creation_date
        ,last_update_date
        ,created_by
        ,last_updated_by
        ,last_update_login
        ,fund_id
        ,parent_fund_id
        ,fund_number
        ,start_date
        ,end_date
        ,start_period
        ,end_period
        ,set_of_books_id
        ,fund_type
        --,region
        ,country
        ,org_id
        ,category_id
        ,status
        ,original_budget
        ,transfer_in
        ,transfer_out
        ,holdback_amt
        ,currency_code_fc
        ,delete_flag
        ,transaction_create_date
        ,load_date
        ,fis_month
        ,fis_qtr
        ,fis_year
        ,business_unit_id)
        --,security_group_id)
SELECT  /*+ parallel(inner, p_para_num) */
bim_r_fund_daily_facts_s.nextval,
       sysdate,
       sysdate,
       l_user_id,
       l_user_id,
       l_user_id,
       inner.fund_id,
       inner.parent_fund_id,
       inner.fund_number,
       inner.start_date,
       inner.end_date,
       inner.start_period,
       inner.end_period,
       inner.set_of_books_id,
       inner.fund_type,
       --inner.region,
       inner.country,
       inner.org_id,
       inner.category_id,
       inner.status,
       inner.original_budget,
       0,
       0,
       0,
       inner.currency_code_fc,
       'N',
       inner.trdate,
       trunc((decode(decode( to_char(inner.trdate,'MM') , to_char(next_day(inner.trdate,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(inner.trdate , (next_day(inner.trdate, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,inner.trdate
      	        ,'FALSE'
      	        ,next_day(inner.trdate, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(inner.trdate,'MM'),to_char(next_day(inner.trdate,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(inner.trdate))))) ,
       BIM_SET_OF_BOOKS.get_fiscal_month(inner.trdate,204),
       BIM_SET_OF_BOOKS.get_fiscal_qtr(inner.trdate,204),
       BIM_SET_OF_BOOKS.get_fiscal_year(inner.trdate,204),
       inner.business_unit_id
FROM  (
   SELECT distinct a.fund_id fund_id,
          a.fund_number fund_number,
          a.start_date start_date,
          a.end_date end_date,
          a.start_period start_period,
          a.end_period end_period,
          a.category_id category_id,
          a.status status,
          a.fund_type fund_type,
          a.parent_fund_id parent_fund_id,
          a.business_unit_id business_unit_id,
          a.country country,
          a.org_id org_id,
          a.set_of_books_id set_of_books_id,
          a.currency_code_fc currency_code_fc,
          a.original_budget original_budget,
          trunc(b.trdate) trdate
   FROM bim_r_fund_daily_facts a,
        bim_intl_dates b
   WHERE b.trdate between p_start_datel and p_end_datel+0.99999
   AND   b.trdate between a.start_date and nvl(a.end_date,p_end_datel)+0.99999
   AND (a.fund_id, trunc(b.trdate)) not in (select c.fund_id, c.transaction_create_date
                                     from bim_r_fund_daily_facts c
				     where c.fund_id = a.fund_id
				     and c.transaction_create_date = trunc(b.trdate))) inner;
			l_count :=l_count +SQL%ROWCOUNT;
    EXECUTE IMMEDIATE 'commit';
      EXCEPTION
      WHEN others THEN
        FND_FILE.put_line(fnd_file.log,'error insert into fund_daily for missing date'||sqlerrm(sqlcode));
        --dbms_output.put_line('error insert into fund_daily for missing date'||sqlerrm(sqlcode));
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
        FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
        FND_MSG_PUB.Add;
      END;

       /* insert dummy 0s for funds created between p_start_datel and p_end_datel,
       and in those dates between p_start_date/start_date_active and p_end_date/end_date_active,
       but has no transactions.*/
      fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
      fnd_message.set_token('table_name', l_table_name, FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      BEGIN
       INSERT /*+ append parallel(fdf,p_para_num) */
       INTO bim_r_fund_daily_facts fdf(
         fund_transaction_id
        ,creation_date
        ,last_update_date
        ,created_by
        ,last_updated_by
        ,last_update_login
        ,fund_id
        ,parent_fund_id
        ,fund_number
        ,start_date
        ,end_date
        ,start_period
        ,end_period
        ,set_of_books_id
        ,fund_type
        --,region
        ,country
        ,org_id
        ,category_id
        ,status
        ,original_budget
        ,transfer_in
        ,transfer_out
        ,holdback_amt
        ,currency_code_fc
        ,delete_flag
        ,transaction_create_date
        ,load_date
        ,fis_month
        ,fis_qtr
        ,fis_year
        ,business_unit_id)
        --,security_group_id)
SELECT  /*+ parallel(inner, p_para_num) */
bim_r_fund_daily_facts_s.nextval,
       sysdate,
       sysdate,
       l_user_id,
       l_user_id,
       l_user_id,
       inner.fund_id,
       inner.parent_fund_id,
       inner.fund_number,
       inner.start_date,
       inner.end_date,
       inner.start_period,
       inner.end_period,
       inner.set_of_books_id,
       inner.fund_type,
       --inner.region,
       inner.country,
       inner.org_id,
       inner.category_id,
       inner.status,
       inner.original_budget,
       0,
       0,
       0,
       inner.currency_code_fc,
       'N',
       inner.trdate,
       trunc((decode(decode( to_char(inner.trdate,'MM') , to_char(next_day(inner.trdate,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(inner.trdate , (next_day(inner.trdate, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,inner.trdate
      	        ,'FALSE'
      	        ,next_day(inner.trdate, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(inner.trdate,'MM'),to_char(next_day(inner.trdate,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(inner.trdate))))) ,
       BIM_SET_OF_BOOKS.get_fiscal_month(inner.trdate,204),
       BIM_SET_OF_BOOKS.get_fiscal_qtr(inner.trdate,204),
       BIM_SET_OF_BOOKS.get_fiscal_year(inner.trdate,204),
       inner.business_unit_id
FROM  (
      SELECT    ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          ad.original_budget original_budget,
          trunc(b.trdate) trdate,
          0 transfer_in,
          0     transfer_out,
          0     holdback
FROM      ozf_funds_all_b ad,
          bim_intl_dates b
WHERE     ad.status_code in ('ACTIVE', 'CANCELLED', 'CLOSED')
AND       ad.start_date_active between p_start_datel and p_end_datel
AND       b.trdate between p_start_datel and p_end_datel+0.99999
AND       b.trdate between ad.start_date_active and nvl(ad.end_date_active,p_end_datel)+0.99999
AND      (ad.fund_id, trunc(b.trdate)) not in (select c.fund_id, c.transaction_create_date
                                     from bim_r_fund_daily_facts c
                                     where c.fund_id = ad.fund_id
                                     and c.transaction_create_date = trunc(b.trdate))) inner;
       			l_count :=l_count +SQL%ROWCOUNT;
    EXECUTE IMMEDIATE 'commit';
      EXCEPTION
      WHEN others THEN
        FND_FILE.put_line(fnd_file.log,'error insert into fund_daily for missing date 2'||sqlerrm(sqlcode));
        --dbms_output.put_line('error insert into fund_daily for missing date 2'||sqlerrm(sqlcode));
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
        FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
        FND_MSG_PUB.Add;
      END;

      /* Inserting into 'bim_r_fdsp_load' all the objects information */
      l_table_name :='bim_r_fdsp_daily_facts';
      fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
      fnd_message.set_token('table_name', 'bim_r_fdsp_load', FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fdsp_daily_facts_s CACHE 1000';
      EXECUTE IMMEDIATE 'truncate table '||l_schema||'.bim_r_fdsp_load';
      BEGIN
       INSERT /*+ append parallel(bfl,p_para_num) */
       INTO  bim_r_fdsp_load bfl(
            spend_transaction_id
            ,creation_date
            ,last_update_date
            ,created_by
            ,last_updated_by
            ,last_update_login
            ,fund_id
            ,business_unit_id
            ,util_org_id
            ,standard_discount
            ,accrual
            ,market_expense
            ,commited_amt
            ,planned_amt
            ,paid_amt
            ,delete_flag
            ,transaction_create_date
            ,load_date
            ,object_id
            ,object_type)
        SELECT /*+ parallel(act_util, p_para_num) */
             0,
             sysdate,
             sysdate,
             -1,
             -1,
             -1,
             act_util.fund_id,
             0,
             0,
             act_util.standard_discount,
             act_util.accrual,
             act_util.market_expense,
             act_util.commited_amt,
             act_util.planned_amt,
             act_util.paid_amt,
             'Y',
             act_util.creation_date,
             sysdate,
             act_util.object_id,
             act_util.object_type
      FROM  (SELECT fund_id fund_id,
                    object_id object_id,
                    object_type object_type,
                    creation_date  creation_date,
                    SUM(nvl(planned_amt,0)) planned_amt,
                    SUM(nvl(commited_amt,0)) commited_amt,
                    SUM(nvl(standard_discount,0)) standard_discount,
                    SUM(nvl(accrual,0)) accrual,
                    SUM(nvl(market_expense,0)) market_expense,
                    SUM(nvl(paid_amt,0)) paid_amt
             FROM  (
                    SELECT budget_source_id fund_id,
                           act_budget_used_by_id object_id,
                           arc_act_budget_used_by object_type,
                           trunc(nvl(request_date,creation_date)) creation_date,
                           SUM(convert_currency(request_currency, nvl(request_amount,0))) planned_amt,
                           0  commited_amt,
                           0 standard_discount,
                           0 accrual,
                           0 market_expense,
                           0 paid_amt
                    FROM ozf_act_budgets
                    WHERE budget_source_type ='FUND'
                    AND   status_code ='PENDING'
                    AND   ARC_ACT_BUDGET_USED_BY <> 'FUND'
                    GROUP BY trunc(nvl(request_date ,creation_date)),
                             budget_source_id,act_budget_used_by_id,
                             arc_act_budget_used_by
                    UNION ALL
                    SELECT budget_source_id fund_id,
                           act_budget_used_by_id object_id,
                           arc_act_budget_used_by object_type,
                           trunc(nvl(approval_date,last_update_date))  creation_date,
                           0-SUM(convert_currency(request_currency, nvl(request_amount,0))) planned_amt,
                           SUM(convert_currency(approved_in_currency,nvl(approved_original_amount,0)))  commited_amt,
                           0 standard_discount,
                           0 accrual,
                           0 market_expense,
                           0 paid_amt
                    FROM ozf_act_budgets
                    WHERE budget_source_type ='FUND'
                    AND   ARC_ACT_BUDGET_USED_BY <> 'FUND'
                    AND   status_code ='APPROVED'
                    GROUP BY trunc(nvl(approval_date,last_update_date)),
                          budget_source_id,act_budget_used_by_id,
                          arc_act_budget_used_by
                    UNION ALL
                    SELECT act_budget_used_by_id fund_id,
                           budget_source_id object_id,
                           budget_source_type object_type,
                           trunc(nvl(approval_date,last_update_date))  creation_date,
                           0 planned_amt,
                           0-SUM(convert_currency(approved_in_currency,nvl(approved_original_amount,0)))  commited_amt,
                           0 standard_discount,
                           0 accrual,
                           0 market_expense,
                           0 paid_amt
                    FROM ozf_act_budgets
                    WHERE arc_act_budget_used_by ='FUND'
                    AND   budget_source_type<>'FUND'
                    AND   status_code ='APPROVED'
                    GROUP BY trunc(nvl(approval_date,last_update_date)),
                          act_budget_used_by_id, budget_source_id,
                          budget_source_type
                    UNION ALL
                    SELECT fund_id fund_id,
                           plan_id object_id,
                           plan_type  object_type,
                           trunc(creation_date) creation_date,
                           0 planned_amt,
                           0 commited_amt,
                           SUM(decode(component_type,'OFFR',decode(utilization_type, 'UTILIZED',convert_currency(currency_code,nvl(amount,0)), 0),0)) standard_discount,
                           SUM(decode(component_type,'OFFR', decode(utilization_type, 'ACCRUAL', convert_currency(currency_code,nvl(amount,0)), 0),0) +
                           decode(component_type,'OFFR', decode(utilization_type, 'ADJUSTMENT', convert_currency(currency_code,nvl(amount,0)), 0),0)) accrual,
                           SUM(decode(component_type,'OFFR',0, decode(utilization_type, 'UTILIZED', convert_currency(currency_code,nvl(amount,0)), 0))) market_expense,
                           sum(decode(component_type,'OFFR',0,convert_currency(currency_code,(nvl(amount,0)-NVL(amount_remaining,0))))) paid_amt
                   FROM ozf_funds_utilized_all_b
                   WHERE utilization_type in ('UTILIZED','ACCRUAL','ADJUSTMENT')
                   GROUP BY trunc(creation_date),fund_id,plan_id,plan_type
                   )
             GROUP BY creation_date, fund_id, object_id,object_type
              ) act_util;
              EXECUTE IMMEDIATE 'COMMIT';
        EXCEPTION
        WHEN OTHERS THEN
        FND_FILE.put_line(fnd_file.log,'error insert fdsp daily'||sqlerrm(sqlcode));
       --dbms_output.put_line('error inserting INTO bim_r_fdsp_daily_facts'||sqlerrm(sqlcode));
        EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fdsp_daily_facts_s CACHE 20';
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
        FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
        FND_MSG_PUB.Add;
        END ;  --end of insertion into bim_r_fdsp_load.

   --dbms_output.put_line('inside fist inserting into fdsp daily');
    /* First insert:Insert into 'bim_r_fdsp_daily_facts' the transactions happend between
      p_start_date and p_end_date */
      fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
      fnd_message.set_token('table_name', l_table_name, FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
   BEGIN
   INSERT /*+ append parallel(fdf,p_para_num) */
   INTO bim_r_fdsp_daily_facts fdf(
         spend_transaction_id
         ,creation_date
         ,last_update_date
         ,created_by
         ,last_updated_by
         ,last_update_login
         ,fund_id
         ,business_unit_id
         ,util_org_id
         ,standard_discount
         ,accrual
         ,market_expense
         ,commited_amt
         ,planned_amt
         ,paid_amt
         ,delete_flag
         ,transaction_create_date
         ,load_date
         ,object_id
         ,object_type
         ,fis_month
         ,fis_qtr
         ,fis_year
         )
   SELECT /*+ parallel(inner, p_para_num) */
         bim_r_fdsp_daily_facts_s.nextval,
          sysdate,
          sysdate,
          l_user_id,
          l_user_id,
          l_user_id,
          inner.fund_id,
          inner.business_unit_id,
          inner.org_id,
          inner.standard_discount,
          inner.accrual,
          inner.market_expense,
          inner.commited_amt,
          inner.planned_amt,
          inner.paid_amt,
          'N',
          inner.transaction_create_date,
          trunc((decode(decode( to_char(inner.transaction_create_date,'MM') , to_char(next_day(inner.transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(inner.transaction_create_date , (next_day(inner.transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,inner.transaction_create_date
      	        ,'FALSE'
      	        ,next_day(inner.transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(inner.transaction_create_date,'MM'),to_char(next_day(inner.transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(inner.transaction_create_date)))))       weekend_date
	,inner.object_id
         ,inner.object_type
         ,BIM_SET_OF_BOOKS.get_fiscal_month(inner.transaction_create_date,204)
         ,BIM_SET_OF_BOOKS.get_fiscal_qtr(inner.transaction_create_date,204)
         ,BIM_SET_OF_BOOKS.get_fiscal_year(inner.transaction_create_date,204)
   FROM  (SELECT AD.fund_id fund_id,
  	         U.business_unit_id business_unit_id,
  	         U.org_id org_id,
  	         NVL(AU.standard_discount,0) standard_discount,
  	         NVL(AU.accrual,0) accrual,
  	         NVL(AU.market_expense,0) market_expense,
  	         NVL(AU.commited_amt,0) commited_amt,
  	         NVL(AU.planned_amt,0) planned_amt,
  	         NVL(AU.paid_amt,0) paid_amt,
  	         AU.object_id object_id,
  	         U.object_type object_type,
  	         AU.transaction_create_date transaction_create_date
          FROM   ozf_funds_all_b AD,
                 bim_r_fdsp_load AU,
                (SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'CAMP' object_type_J,'CAMP' object_type, D.campaign_id object_id
                FROM ams_campaigns_all_b D
               UNION ALL
               SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'CSCH' object_type_J,'CSCH' object_type,B.SCHEDULE_ID object_id
               FROM
                    ams_campaigns_all_b D,
                    ams_campaign_schedules_b B
               WHERE B.campaign_id = D.campaign_id (+)
               UNION ALL
               SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'EVEH' object_type_J,'EVEH' object_type, D.event_header_id object_id
               FROM
                    ams_event_headers_all_b D
               UNION ALL
                SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'EVEO' object_type_J, 'EVEO' object_type, D.event_offer_id object_id
               FROM
                    ams_event_offers_all_b D
               WHERE event_header_id is not null
               UNION ALL
               SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'EONE' object_type_J, 'EONE' object_type, D.event_offer_id object_id
               FROM
                    ams_event_offers_all_b D
               WHERE event_header_id is null
               UNION ALL
               SELECT
                 BC.business_unit_id business_unit_id,BC.org_id org_id,
                 'OFFR' object_type_J, 'OFFR' object_type, D.qp_list_header_id object_id
               FROM
                    ams_campaigns_all_b BC,
                    ams_act_offers D
               WHERE
                  D.arc_act_offer_used_by (+)   = 'CAMP'  AND D.act_offer_used_by_id =
                 BC.campaign_id (+)    AND BC.show_campaign_flag (+)   = 'Y'
               UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'CAMPDELV' object_type,  D.using_object_id object_id
                FROM
                     ams_campaigns_all_b BA,
                     ams_object_associations D
                WHERE
                 D.using_object_type='DELV' AND
                 D.master_object_type (+)   = 'CAMP'  AND
                 D.master_object_id = BA.campaign_id (+)
                UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'CSCHDELV' object_type, D.using_object_id object_id
                FROM
                     ams_campaigns_all_b BA,
                     ams_campaign_schedules_b E,
                     ams_object_associations D
                WHERE
                 D.master_object_type (+)   = 'CSCH'  AND D.master_object_id = E.SCHEDULE_ID
                 (+)    AND E.campaign_id = BA.campaign_id (+)
                 AND D.using_object_type (+)   = 'DELV'
                UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'EVEHDELV' object_type, D.using_object_id object_id
                FROM
                     ams_event_headers_all_b BA,
                     ams_object_associations D
                WHERE 	D.using_object_type(+) = 'DELV'
                AND  	D.master_object_type(+) = 'EVEH'
                AND 	D.master_object_id = BA.event_header_id (+)
                UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'EVEODELV' object_type, D.using_object_id object_id
                FROM
                     ams_event_offers_all_b BA,
                     ams_object_associations D
                WHERE 	D.using_object_type(+) = 'DELV'
                AND  	D.master_object_type(+) = 'EVEO'
                AND 	D.master_object_id = BA.event_offer_id (+)
                UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'EONEDELV' object_type, D.using_object_id object_id
                FROM
                     ams_event_offers_all_b BA,
                     ams_object_associations D
                WHERE 	D.using_object_type(+) = 'DELV'
                AND  	D.master_object_type(+) = 'EONE'
                AND 	D.master_object_id = BA.event_offer_id (+)
                 ) U
               WHERE AD.status_code IN ( 'ACTIVE','CANCELLED','CLOSED'  )
               AND   AU.transaction_create_date BETWEEN p_start_datel AND p_end_datel + 0.99999
               AND   AU.object_type  = U.object_type_J (+)
               AND   AU.object_id = U.object_id (+)
               AND   AU.fund_id = AD.fund_id
               ) inner;
             l_count :=l_count +SQL%ROWCOUNT;
             EXECUTE IMMEDIATE 'COMMIT';
             EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fdsp_daily_facts_s CACHE 20';
        EXCEPTION
        WHEN OTHERS THEN
        FND_FILE.put_line(fnd_file.log,'first insert:error insert fdsp daily'||sqlerrm(sqlcode));
       -- dbms_output.put_line('error inserting INTO bim_r_fdsp_daily_facts'||sqlerrm(sqlcode));
        EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fdsp_daily_facts_s CACHE 20';
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
        FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
        FND_MSG_PUB.Add;
        END ;

     /* Second insert: Insert extra records which happened before start date active */
     fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
      fnd_message.set_token('table_name', l_table_name, FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
     BEGIN
   INSERT /*+ append parallel(fdf,p_para_num) */
   INTO bim_r_fdsp_daily_facts fdf(
         spend_transaction_id
         ,creation_date
         ,last_update_date
         ,created_by
         ,last_updated_by
         ,last_update_login
         ,fund_id
         ,business_unit_id
         ,util_org_id
         ,standard_discount
         ,accrual
         ,market_expense
         ,commited_amt
         ,planned_amt
         ,paid_amt
         ,delete_flag
         ,transaction_create_date
         ,load_date
         ,object_id
         ,object_type
         ,fis_month
         ,fis_qtr
         ,fis_year
         )
   SELECT /*+ parallel(inner, p_para_num) */
         bim_r_fdsp_daily_facts_s.nextval,
          sysdate,
          sysdate,
          l_user_id,
          l_user_id,
          l_user_id,
          inner.fund_id,
          inner.business_unit_id,
          inner.org_id,
          inner.standard_discount,
          inner.accrual,
          inner.market_expense,
          inner.commited_amt,
          inner.planned_amt,
          inner.paid_amt,
          'N',
          inner.transaction_create_date,
          trunc((decode(decode( to_char(inner.transaction_create_date,'MM') , to_char(next_day(inner.transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(inner.transaction_create_date , (next_day(inner.transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,inner.transaction_create_date
      	        ,'FALSE'
      	        ,next_day(inner.transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(inner.transaction_create_date,'MM'),to_char(next_day(inner.transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(inner.transaction_create_date)))))         weekend_date
         ,inner.object_id
         ,inner.object_type
         ,BIM_SET_OF_BOOKS.get_fiscal_month(inner.transaction_create_date,204)
         ,BIM_SET_OF_BOOKS.get_fiscal_qtr(inner.transaction_create_date,204)
         ,BIM_SET_OF_BOOKS.get_fiscal_year(inner.transaction_create_date,204)
   FROM  (SELECT AD.fund_id fund_id,
  	         U.business_unit_id business_unit_id,
  	         U.org_id org_id,
  	         NVL(AU.standard_discount,0) standard_discount,
  	         NVL(AU.accrual,0) accrual,
  	         NVL(AU.market_expense,0) market_expense,
  	         NVL(AU.commited_amt,0) commited_amt,
  	         NVL(AU.planned_amt,0) planned_amt,
  	         NVL(AU.paid_amt,0) paid_amt,
  	         AU.object_id object_id,
  	         U.object_type object_type,
  	         AU.transaction_create_date transaction_create_date
          FROM   ozf_funds_all_b AD,
                 bim_r_fdsp_load AU,
                (SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'CAMP' object_type_J,'CAMP' object_type, D.campaign_id object_id
                FROM ams_campaigns_all_b D
               UNION ALL
               SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'CSCH' object_type_J,'CSCH' object_type,B.SCHEDULE_ID object_id
               FROM
                    ams_campaigns_all_b D,
                    ams_campaign_schedules_b B
               WHERE B.campaign_id = D.campaign_id (+)
               UNION ALL
               SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'EVEH' object_type_J,'EVEH' object_type, D.event_header_id object_id
               FROM
                    ams_event_headers_all_b D
               UNION ALL
               SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'EVEO' object_type_J, 'EVEO' object_type, D.event_offer_id object_id
               FROM
                    ams_event_offers_all_b D
               WHERE event_header_id is not null
               UNION ALL
               SELECT
                 D.business_unit_id business_unit_id,D.org_id org_id,
                 'EONE' object_type_J, 'EONE' object_type, D.event_offer_id object_id
               FROM
                    ams_event_offers_all_b D
               WHERE event_header_id is null
               UNION ALL
               SELECT
                 BC.business_unit_id business_unit_id,BC.org_id org_id,
                 'OFFR' object_type_J, 'OFFR' object_type, D.qp_list_header_id object_id
               FROM
                    ams_campaigns_all_b BC,
                    ams_act_offers D
               WHERE
                  D.arc_act_offer_used_by (+)   = 'CAMP'  AND D.act_offer_used_by_id =
                 BC.campaign_id (+)    AND BC.show_campaign_flag (+)   = 'Y'
               UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'CAMPDELV' object_type,  D.using_object_id object_id
                FROM
                     ams_campaigns_all_b BA,
                     ams_object_associations D
                WHERE
                 D.using_object_type='DELV' AND
                 D.master_object_type (+)   = 'CAMP'  AND
                 D.master_object_id = BA.campaign_id (+)
                UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'CSCHDELV' object_type, D.using_object_id object_id
                FROM
                     ams_campaigns_all_b BA,
                     ams_campaign_schedules_b E,
                     ams_object_associations D
                WHERE
                 D.master_object_type (+)   = 'CSCH'  AND D.master_object_id = E.SCHEDULE_ID
                 (+)    AND E.campaign_id = BA.campaign_id (+)
                 AND D.using_object_type (+)   = 'DELV'
                UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'EVEHDELV' object_type, D.using_object_id object_id
                FROM
                     ams_event_headers_all_b BA,
                     ams_object_associations D
                WHERE 	D.using_object_type(+) = 'DELV'
                AND  	D.master_object_type(+) = 'EVEH'
                AND 	D.master_object_id = BA.event_header_id (+)
                UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'EVEODELV' object_type, D.using_object_id object_id
                FROM
                     ams_event_offers_all_b BA,
                     ams_object_associations D
                WHERE 	D.using_object_type(+) = 'DELV'
                AND  	D.master_object_type(+) = 'EVEO'
                AND 	D.master_object_id = BA.event_offer_id (+)
                UNION ALL
                SELECT
                 BA.business_unit_id business_unit_id,BA.org_id org_id,
                 'DELV' object_type_J, 'EONEDELV' object_type, D.using_object_id object_id
                FROM
                     ams_event_offers_all_b BA,
                     ams_object_associations D
                WHERE 	D.using_object_type(+) = 'DELV'
                AND  	D.master_object_type(+) = 'EONE'
                AND 	D.master_object_id = BA.event_offer_id (+)
                 ) U
               WHERE AD.status_code IN ( 'ACTIVE','CANCELLED','CLOSED'  )
               AND   AD.start_date_active BETWEEN p_start_datel AND p_end_datel + 0.99999
               AND   AU.transaction_create_date < p_start_datel
               AND   AU.object_type  = U.object_type_J (+)
               AND   AU.object_id = U.object_id (+)
               AND   AU.fund_id    = AD.fund_id
               ) inner;
               l_count :=l_count+SQL%ROWCOUNT;
            EXECUTE IMMEDIATE 'commit';
     EXCEPTION
      WHEN others THEN
       FND_FILE.put_line(fnd_file.log,'error insert extras into fdsp daily'||sqlerrm(sqlcode));
       -- dbms_output.put_line('error inserting extra INTO bim_r_fdsp_daily_facts'||sqlerrm(sqlcode));
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
        FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
        FND_MSG_PUB.Add;
   END;

   /* Insert dummy 0s for the dates between p_start_date/start_date_active and p_end_date/end_date_active,
      but has no transactions. */
      fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
      fnd_message.set_token('table_name', l_table_name, FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
   BEGIN
   INSERT /*+ append parallel(fdf,p_para_num) */
   INTO bim_r_fdsp_daily_facts fdf(
         spend_transaction_id
         ,creation_date
         ,last_update_date
         ,created_by
         ,last_updated_by
         ,last_update_login
         ,fund_id
         ,business_unit_id
         ,util_org_id
         ,standard_discount
         ,accrual
         ,market_expense
         ,commited_amt
         ,planned_amt
         ,paid_amt
         ,delete_flag
         ,transaction_create_date
         ,load_date
         ,object_id
         ,object_type
         ,fis_month
         ,fis_qtr
         ,fis_year
         )
   SELECT /*+ parallel(inner, p_para_num) */
         bim_r_fdsp_daily_facts_s.nextval,
          sysdate,
          sysdate,
          l_user_id,
          l_user_id,
          l_user_id,
          inner.fund_id,
          null,
          null,
          0,
          0,
          0,
          0,
          0,
          0,
          'N',
          inner.trdate,
          trunc((decode(decode( to_char(inner.trdate,'MM') , to_char(next_day(inner.trdate,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(inner.trdate , (next_day(inner.trdate, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,inner.trdate
      	        ,'FALSE'
      	        ,next_day(inner.trdate, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(inner.trdate,'MM'),to_char(next_day(inner.trdate,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(inner.trdate)))))         weekend_date
         ,null
         ,null
         ,BIM_SET_OF_BOOKS.get_fiscal_month(inner.trdate,204)
         ,BIM_SET_OF_BOOKS.get_fiscal_qtr(inner.trdate,204)
         ,BIM_SET_OF_BOOKS.get_fiscal_year(inner.trdate,204)
   FROM  (
   SELECT distinct a.fund_id fund_id,
          TRUNC(b.trdate) trdate
   FROM   bim_r_fdsp_daily_facts a,
          ozf_funds_all_b f,
          bim_intl_dates b
   WHERE  b.trdate between greatest(p_start_datel, f.start_date_active)
          and least(p_end_datel, nvl(f.end_date_active,p_end_datel))
   and  f.fund_id = a.fund_id
   and (a.fund_id, TRUNC(b.trdate)) not in (select c.fund_id, c.transaction_create_date
                                     from bim_r_fdsp_daily_facts c
				     where c.fund_id = a.fund_id
				     and c.transaction_create_date = TRUNC(b.trdate)) )inner;
            l_count :=l_count+SQL%ROWCOUNT;
           -- dbms_output.put_line('missing fdsp:l_count'||l_count);
            EXECUTE IMMEDIATE 'commit';
     EXCEPTION
      WHEN others THEN
       FND_FILE.put_line(fnd_file.log,'error insert fdsp daily for missing dates'||sqlerrm(sqlcode));
       -- dbms_output.put_line('error inserting fdsp daily for missing dates'||sqlerrm(sqlcode));
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
        FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
        FND_MSG_PUB.Add;
   END;

 /* Insert into bim_r_fdsp_daily_facts the dates which are in bim_r_fund_daily_facts
    but not in bim_r_fdsp_daily_facts. */
      fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
      fnd_message.set_token('table_name', l_table_name, FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
 BEGIN --insert into fdsp for balancing
 l_table_name :='bim_r_fdsp_daily_facts';
 INSERT /*+ append parallel(fdf,p_para_num) */
   INTO bim_r_fdsp_daily_facts fdf(
         spend_transaction_id
         ,creation_date
         ,last_update_date
         ,created_by
         ,last_updated_by
         ,last_update_login
         ,fund_id
         ,business_unit_id
         ,util_org_id
         ,standard_discount
         ,accrual
         ,market_expense
         ,commited_amt
         ,planned_amt
         ,paid_amt
         ,delete_flag
         ,transaction_create_date
         ,load_date
         ,object_id
         ,object_type
         ,fis_month
         ,fis_qtr
         ,fis_year
         )
   SELECT /*+ parallel(inner, p_para_num) */
         bim_r_fdsp_daily_facts_s.nextval,
          sysdate,
          sysdate,
          l_user_id,
          l_user_id,
          l_user_id,
          b1.fund_id,
          b1.business_unit_id,
          b1.util_org_id,
          0,
          0,
          0,
          0,
          0,
          0,
          'N',
          b1.transaction_create_date,
          b1.load_date,
          b1.object_id,
          b1.object_type,
          b1.fis_month,
          b1.fis_qtr,
          b1.fis_year
  FROM    bim_r_fdsp_daily_facts b1,
          (SELECT distinct fund_id fund_id,
                 transaction_create_date transaction_create_date
          FROM   bim_r_fund_daily_facts fd
          WHERE (fund_id, transaction_create_date) not in
          ( SELECT /*+ hash_aj */ fund_id, transaction_create_date
            from bim_r_fdsp_daily_facts
            where fund_id is not null
            and transaction_create_date is not null
            )) b2
  WHERE b1.fund_id = b2.fund_id
  AND   b1.transaction_create_date = b2.transaction_create_date ;
  EXECUTE IMMEDIATE 'commit';
  EXCEPTION
 WHEN OTHERS THEN
        FND_FILE.put_line(fnd_file.log,'error insert fdsp daily for balancing'||sqlerrm(sqlcode));
       -- dbms_output.put_line('error inserting bim_r_fdsp_daily_facts for balancing'||sqlerrm(sqlcode));
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
        FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
        FND_MSG_PUB.Add;
 END;
--Insert dummy records into bim_r_fund_daily_facts for balancing
/* Insert into bim_r_fund_daily_facts dates which are in bim_r_fdsp_daily_facts
   but not in bim_r_fund_daily_facts */
 BEGIN
    l_table_name :='bim_r_fund_daily_facts';
    fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
    fnd_message.set_token('table_name', l_table_name, FALSE);
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    INSERT into bim_r_fund_daily_facts(
         fund_transaction_id
        ,creation_date
        ,last_update_date
        ,created_by
        ,last_updated_by
        ,last_update_login
        ,fund_id
        ,parent_fund_id
        ,fund_number
        ,start_date
        ,end_date
        ,start_period
        ,end_period
        ,set_of_books_id
        ,fund_type
        --,region
        ,country
        ,org_id
        ,category_id
        ,status
        ,original_budget
        ,transfer_in
        ,transfer_out
        ,holdback_amt
        ,currency_code_fc
        ,delete_flag
        ,transaction_create_date
        ,load_date
        ,fis_month
        ,fis_qtr
        ,fis_year
        ,business_unit_id)
    SELECT
        bim_r_fund_daily_facts_s.nextval,
        sysdate,
        sysdate,
        l_user_id,
        l_user_id,
        l_user_id,
        a.fund_id ,
        a.parent_fund_id parent_fund_id,
        a.fund_number fund_number,
        a.start_date_active start_date,
        a.end_date_active end_date,
        a.start_period_name start_period,
        a.end_period_name end_period,
        a.set_of_books_id set_of_book_id,
        a.fund_type fund_type,
        a.country_id country,
        a.org_id org_id,
        a.category_id fund_category,
        a.status_code fund_status,
        a.original_budget original_amount,
        0,
        0,
        0,
        a.currency_code_fc,
        'N',
        b2.transaction_create_date,
        trunc((decode(decode( to_char(transaction_create_date,'MM') , to_char(next_day(transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(transaction_create_date , (next_day(transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,transaction_create_date
      	        ,'FALSE'
      	        ,next_day(transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(transaction_create_date,'MM'),to_char(next_day(transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(transaction_create_date)))))         weekend_date,
        b2.fis_month,
        b2.fis_qtr,
        b2.fis_year,
        a.business_unit_id
    FROM ozf_funds_all_b a,
         (SELECT distinct(fund_id) fund_id,
                 fis_month fis_month,
                 fis_qtr fis_qtr,
                 fis_year fis_year,
                 transaction_create_date transaction_create_date
          FROM   bim_r_fdsp_daily_facts fdsp
         WHERE fund_id is not null
         AND transaction_create_date is not null
         AND (fund_id, transaction_create_date) not in
          ( SELECT /*+ hash_aj */ fund_id, transaction_create_date
            from bim_r_fund_daily_facts b1
            )) b2
    WHERE b2.fund_id = a.fund_id;
    EXECUTE IMMEDIATE 'commit';
 EXCEPTION
 WHEN OTHERS THEN
        FND_FILE.put_line(fnd_file.log,'error insert fund daily for balancing'||sqlerrm(sqlcode));
       -- dbms_output.put_line('error insert fund_daily for balancing with fdsp'||sqlerrm(sqlcode));
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
        FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
        FND_MSG_PUB.Add;
 END;

 --Insert into history table.
 FND_FILE.put_line(fnd_file.log,'Insert into log history');
--   IF l_count>0  THEN
     LOG_HISTORY(
     'FUND',
     p_start_datel,
     p_end_datel,
     x_msg_count,
     x_msg_data,
     x_return_status) ;
 --  END IF;
   EXECUTE IMMEDIATE 'truncate table '||l_schema||'.bim_r_fund_weekly_facts';
   --Start of inserting into 'bim_r_fund_weekly_facts'
BEGIN
   l_table_name :='bim_r_fund_weekly_facts';
   fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
   fnd_message.set_token('table_name', l_table_name, FALSE);
   fnd_file.put_line(fnd_file.log,fnd_message.get);
   EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fund_weekly_facts_s CACHE 1000';
   INSERT /*+ append parallel(fwf,p_para_num) */ INTO bim_r_fund_weekly_facts fwf(
      fund_transaction_id
     ,creation_date
     ,last_update_date
     ,created_by
     ,last_updated_by
     ,last_update_login
     ,fund_id
     ,parent_fund_id
     ,fund_number
     ,start_date
     ,end_date
     ,start_period
     ,end_period
     ,set_of_books_id
     ,fund_type
     -- ,region
     ,country
     ,org_id
     ,category_id
     ,status
     ,original_budget
     ,transfer_in
     ,transfer_out
     ,holdback_amt
     ,currency_code_fc
     ,delete_flag
     ,transaction_create_date
     ,load_date
     ,fis_month
     ,fis_qtr
     ,fis_year
     ,business_unit_id)
  SELECT /*+ parallel(inner, p_para_num) */
      bim_r_fund_weekly_facts_s.nextval
     ,sysdate
     ,sysdate
     ,l_user_id
     ,l_user_id
     ,l_user_id
     ,inner.fund_id
     ,inner.parent_fund_id
     ,inner.fund_number
     ,inner.start_date
     ,inner.end_date
     ,inner.start_period
     ,inner.end_period
     ,inner.set_of_books_id
     ,inner.fund_type
     --,inner.region
     ,inner.country
     ,inner.org_id
     ,inner.category_id
     ,inner.status
     ,inner.original_budget
     ,inner.transfer_in
     ,inner.transfer_out
     ,inner.holdback_amt
     ,inner.currency_code_fc
     ,'N'
     ,inner.load_date
     ,inner.load_date
     ,BIM_SET_OF_BOOKS.get_fiscal_month(inner.load_date,204)
     ,BIM_SET_OF_BOOKS.get_fiscal_qtr(inner.load_date,204)
     ,BIM_SET_OF_BOOKS.get_fiscal_year(inner.load_date,204)
     ,inner.business_unit_id
FROM(SELECT fund_id fund_id
            ,parent_fund_id parent_fund_id
            ,fund_number fund_number
            ,start_date start_date
            ,end_date end_date
            ,start_period start_period
            ,end_period  end_period
            ,set_of_books_id set_of_books_id
            ,fund_type fund_type
            --,region region
            ,country country
            ,org_id  org_id
            ,business_unit_id business_unit_id
            ,category_id category_id
            ,status status
            ,original_budget original_budget
            ,SUM(transfer_in) transfer_in
            ,SUM(transfer_out) transfer_out
            ,SUM(holdback_amt) holdback_amt
            ,currency_code_fc  currency_code_fc
            ,load_date load_date
     FROM bim_r_fund_daily_facts
     GROUP BY
           fund_id
          ,load_date
          ,parent_fund_id
          ,fund_number
          ,start_date
          ,end_date
          ,start_period
          ,end_period
          ,set_of_books_id
          ,fund_type
         -- ,region
          ,country
          ,org_id
          ,business_unit_id
          ,category_id
          ,status
          ,original_budget
          ,currency_code_fc) inner;
           EXECUTE IMMEDIATE 'commit';
    EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fund_weekly_facts_s CACHE 20';
    EXCEPTION
      WHEN others THEN
        FND_FILE.put_line(fnd_file.log,'Error insertg fund weekly:'||sqlerrm(sqlcode));
        --dbms_output.put_line('Errorin inserting fund weekly:'||sqlerrm(sqlcode));
          EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fund_weekly_facts_s CACHE 20';
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
          FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
          FND_MSG_PUB.Add;
    END;
BEGIN
   EXECUTE IMMEDIATE 'truncate table '||l_schema||'.bim_r_fdsp_weekly_facts';
  l_table_name :='bim_r_fdsp_weekly_facts';
  fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
   fnd_message.set_token('table_name', l_table_name, FALSE);
   fnd_file.put_line(fnd_file.log,fnd_message.get);
  EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fdsp_weekly_facts_s CACHE 1000';
  --dbms_output.put_line('inside fist inserting into fdsp weekly');

  --Insert into bim_r_fdsp_weekly_facts
 INSERT /*+ append parallel(fwf,p_para_num) */
 INTO bim_r_fdsp_weekly_facts fwf(
   spend_transaction_id
  ,creation_date
  ,last_update_date
  ,created_by
  ,last_updated_by
  ,last_update_login
  ,fund_id
  ,business_unit_id
  ,util_org_id
  ,standard_discount
  ,accrual
  ,market_expense
  ,commited_amt
  ,planned_amt
  ,paid_amt
  ,delete_flag
  ,transaction_create_date
  ,load_date
  ,object_id
  ,object_type
  ,fis_month
  ,fis_qtr
  ,fis_year
  )
  SELECT /*+ parallel(inner.p_para_num) */
  bim_r_fdsp_weekly_facts_s.nextval
  ,sysdate
  ,sysdate
  ,l_user_id
  ,l_user_id
  ,l_user_id
  ,inner.fund_id
  ,inner.business_unit_id
  ,inner.util_org_id
  ,inner.standard_discount
  ,inner.accrual
  ,inner.market_expense
  ,inner.commited_amt
  ,inner.planned_amt
  ,inner.paid_amt
  ,'N'
  ,inner.load_date
  ,inner.load_date
  ,inner.object_id
  ,inner.object_type
  ,BIM_SET_OF_BOOKS.get_fiscal_month(inner.load_date,204)
  ,BIM_SET_OF_BOOKS.get_fiscal_qtr(inner.load_date,204)
  ,BIM_SET_OF_BOOKS.get_fiscal_year(inner.load_date,204)
FROM
   (SELECT fund_id fund_id
  ,business_unit_id business_unit_id
  ,util_org_id util_org_id
  ,object_id object_id
  ,object_type object_type
  ,SUM(standard_discount) standard_discount
  ,SUM(accrual) accrual
  ,SUM(market_expense) market_expense
  ,SUM(commited_amt) commited_amt
  ,SUM(planned_amt) planned_amt
  ,SUM(paid_amt)  paid_amt
  ,load_date load_date
  FROM bim_r_fdsp_daily_facts
  GROUP BY load_date
  ,business_unit_id
  ,object_id
  ,object_type
  ,fund_id
  ,util_org_id) inner;
  EXECUTE IMMEDIATE 'commit';
  EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fdsp_weekly_facts_s CACHE 20';
EXCEPTION
      when others THEN
      FND_FILE.put_line(fnd_file.log,'error insert fdsp_weekly'||sqlerrm(sqlcode));
        --dbms_output.put_line('error inserting INTO bim_r_fdsp_weekly_facts'||sqlerrm(sqlcode));
        EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_fdsp_weekly_facts_s CACHE 20';
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
        FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
        FND_MSG_PUB.Add;
 END;
  -- for performance reasons
  BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fund_weekly_facts noparallel';
  EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fdsp_weekly_facts noparallel';
  EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_fund_balance noparallel';
  EXCEPTION
  WHEN OTHERS THEN
  null;
  END;

  --Analysis tables for better performance
  BEGIN
   DBMS_STATS.gather_table_stats('BIM','BIM_R_FUND_DAILY_FACTS', estimate_percent => 5,
                               degree => 8, granularity => 'GLOBAL', cascade =>TRUE);
  END;
  BEGIN
   DBMS_STATS.gather_table_stats('BIM','BIM_R_FUND_WEEKLY_FACTS', estimate_percent => 5,
                               degree => 8, granularity => 'GLOBAL', cascade =>TRUE);
  END;
  BEGIN
   DBMS_STATS.gather_table_stats('BIM','BIM_R_FDSP_DAILY_FACTS', estimate_percent => 5,
                               degree => 8, granularity => 'GLOBAL', cascade =>TRUE);
  END;
  BEGIN
   DBMS_STATS.gather_table_stats('BIM','BIM_R_FDSP_WEEKLY_FACTS', estimate_percent => 5,
                               degree => 8, granularity => 'GLOBAL', cascade =>TRUE);
  END;

  --call update subsequent balance
  fnd_message.set_name('BIM','BIM_R_CALL_PROC');
  fnd_message.set_token('proc_name', 'UPDATE_SUB_BALANCE', FALSE);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
  update_sub_balance(p_start_datel, p_end_datel);
  fnd_message.set_name('BIM','BIM_R_PROG_COMPLETION');
  fnd_message.set_token('program_name', 'Fund first load', FALSE);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
END FUND_SUB_LOAD;
END BIM_FUND_FACTS;

/
