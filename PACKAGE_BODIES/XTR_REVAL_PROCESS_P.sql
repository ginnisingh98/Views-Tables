--------------------------------------------------------
--  DDL for Package Body XTR_REVAL_PROCESS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_REVAL_PROCESS_P" as
/* $Header: xtrrevlb.pls 120.59.12010000.4 2010/02/05 10:34:04 nipant ship $ */
-------------------------------------------------------------------------------------------------------
/***************************************************************/
/* This procedure get rates information from xtr_market_prices */
/* based on time and input into XTR_REVALUATION_RATES table    */
/* Also it generates a batch ID for the new period             */
/***************************************************************/
PROCEDURE GET_ALL_REVAL_RATES(l_company          IN VARCHAR2,
			      l_start_date       IN DATE,
                              l_end_date         IN DATE,
                              l_upgrade_batch    IN VARCHAR2,
			      l_batch_id         IN OUT NOCOPY NUMBER) IS
--
 p_BATCH_ID           NUMBER;
 p_UNIQUE_REF_NUM     NUMBER;
 p_REVAL_TYPE         VARCHAR2(20);
 p_PERIOD_REF1        NUMBER;
 p_PERIOD_REF2        NUMBER;
 p_CURRENCYA          VARCHAR2(15);
 p_CURRENCYB          VARCHAR2(15);
 p_PERIOD_FROM	      DATE;
 p_RATE_DATE          DATE;
 p_NUMBER_OF_DAYS     NUMBER;
 p_DAY_MTH            VARCHAR2(13);
 p_BID      NUMBER;
 p_ASK      NUMBER;
 p_DAY_COUNT_BASIS    VARCHAR2(30);
 p_VOLATILITY_OR_RATE VARCHAR2(4);
 l_bid_curr_rate      NUMBER;
 l_ask_curr_rate      NUMBER;
 l_day_count_basis    VARCHAR2(30);
 l_latest_rate_date   DATE;
 l_type               VARCHAR2(20);
 l_term_type          VARCHAR2(1);
 l_vol_type           VARCHAR2(1);
 l_vol_code           VARCHAR2(20);
 im_nos_of_days       NUMBER;
 l_sysdate            DATE :=trunc(sysdate);

 cursor BATCH is
   select XTR_BATCHES_S.NEXTVAL
   from DUAL;

 cursor BATCH_EXIST is
   select 1
   from XTR_BATCHES
   where BATCH_ID = l_batch_id;

 l_exist  number;

 cursor NUM is
   select XTR_REVALUATION_DETAILS_S.NEXTVAL
   from  DUAL;

-- Get Volatility (O, V) rows from Market Price table
 cursor OPTION_VOLS is
   select RIC_CODE, CURRENCY_A, CURRENCY_B, TERM_TYPE, TERM_LENGTH,
	  LAST_DOWNLOAD_TIME, NOS_OF_DAYS
   from XTR_MARKET_PRICES
   where TERM_TYPE in ('O', 'V');

-- This Cursor will find the snap shot of  market rate for the above row found
 cursor STORED_VOL_RATE is
  select a.UNIQUE_PERIOD_ID,a.RATE_DATE,a.BID_RATE, a.OFFER_RATE
   from XTR_INTEREST_PERIOD_RATES a
   where a.UNIQUE_PERIOD_ID = l_vol_code
     and ((a.CONTRA_OPTION_CCY = p_CURRENCYB and p_CURRENCYB is NOT NULL) or
         (p_CURRENCYB is NULL))
     and a.RATE_DATE < trunc(l_end_date+1)
   order by a.RATE_DATE desc;


--- Get all Other Maintained Codes from the Market Price table
--- These codes will be used to fetch the LATEST RATES from XTR_MASTER_CURRENCIES and
--- INTEREST_PERIOD_RATES tables
---
---  TERM_TYPE
---  S Day(s)
---  M Month(s)
---  Y Year(s)
---  O Opt Vol(Days)
---  V Opt Vol(Mths)
---  S FX Spot
---  F FX Fwd(Days)
---  W FX Fwd(Mths)
---  B Bond Price

 cursor INSTRUMENTS_MAINTAINED is
  select RIC_CODE,TERM_LENGTH,TERM_YEAR,CURRENCY_A,CURRENCY_B,TERM_TYPE, DAY_COUNT_BASIS,
         nvl(BID_PRICE, 0),nvl(ASK_PRICE,0),LAST_DOWNLOAD_TIME,
         NOS_OF_DAYS
   from XTR_MARKET_PRICES
   where TERM_TYPE not in('O','V','A')
     and ((TERM_TYPE = 'S' and (CURRENCY_A = 'USD' or CURRENCY_B = 'USD'))
          or (TERM_TYPE <> 'S'));

 cursor RATES_FX_SPOT is
  select a.RATE_DATE,
         nvl(a.BID_RATE_AGAINST_USD,0),nvl(a.OFFER_RATE_AGAINST_USD,0)
   from XTR_SPOT_RATES a
    where a.CURRENCY = decode(p_CURRENCYA,'USD',p_CURRENCYB,p_CURRENCYA)
    and a.RATE_DATE < trunc(l_end_date+1)
    order by a.RATE_DATE desc;
--
-- Fetch Rates OTHER RATES from XTR_INTEREST_PERIOD_RATES table
 cursor RATES_NON_FX is
  select a.RATE_DATE,nvl(a.BID_RATE,0), nvl(a.OFFER_RATE,0)
   from XTR_INTEREST_PERIOD_RATES a
   where a.UNIQUE_PERIOD_ID = p_REVAL_TYPE
    and a.RATE_DATE < trunc(l_end_date+1)
   order by a.RATE_DATE desc;
--
/*
 cursor GET_BOND_ISSUE is
  select distinct currency,bond_issue
   from XTR_DEALS
   where deal_type='BOND'
     and status_code='CURRENT'
     and maturity_date >l_end_date;

 l_currency   varchar2(20);
 l_bond_issue varchar2(50);
 l_ric_code varchar2(50);

 cursor GET_BOND_RIC_CODE is
  select ric_code
   from XTR_BOND_ISSUES
   where bond_issue_code=l_bond_issue
   and ric_code IS NOT NULL;

 cursor BOND_PRICE is
  select a.RATE_DATE,nvl(a.BID_RATE,0), nvl(a.OFFER_RATE,0)
   from XTR_INTEREST_PERIOD_RATES a
   where a.UNIQUE_PERIOD_ID = l_ric_code
    and a.RATE_DATE < trunc(l_end_date+1)
   order by a.RATE_DATE desc;
*/

begin
 open BATCH_EXIST;
 fetch BATCH_EXIST into l_exist;
 if BATCH_EXIST%NOTFOUND then   -- check if batch_id exists. If not, generate new one. jhung
    open BATCH;
    fetch BATCH into p_BATCH_ID;
    close BATCH;

    insert into XTR_BATCHES
    (batch_id, company_code, period_start, period_end, created_by, creation_date,
     last_updated_by, last_update_date, last_update_login, gl_group_id, upgrade_batch)
    values
    (p_BATCH_ID, l_company, nvl(l_start_date, to_date('01/01/1980', 'DD/MM/YYYY')),
     l_end_date, fnd_global.user_id, l_sysdate, fnd_global.user_id,
     l_sysdate, fnd_global.login_id, null, nvl(l_upgrade_batch, 'N'));

    l_batch_id := p_BATCH_ID;
 else
    p_BATCH_ID := l_batch_id;
    update XTR_BATCHES
    set    last_updated_by = fnd_global.user_id,
           last_update_date = l_sysdate
    where  BATCH_ID = l_batch_id;
 end if;
 close BATCH_EXIST;

 open OPTION_VOLS;
 LOOP
  fetch OPTION_VOLS INTO l_vol_code, p_CURRENCYA,p_CURRENCYB,l_vol_type,
			 p_PERIOD_REF1, p_RATE_DATE, IM_NOS_OF_DAYS;
  if OPTION_VOLS%NOTFOUND then
    exit;
  else
    p_UNIQUE_REF_NUM := NULL;
    p_VOLATILITY_OR_RATE := 'VOL';
    if l_vol_type = 'O' then
       if p_PERIOD_REF1 = 1 then
          p_DAY_MTH := 'DAY';
       else
          p_DAY_MTH := 'DAYS';
      end if;
    else
      if p_PERIOD_REF1 = 1 then
        p_DAY_MTH := 'MONTH';
      else
        p_DAY_MTH := 'MONTHS';
      end if;
    end if;

   -- Get Rate from XTR_INTEREST_PERIOD_TABLES for the latest date
       open STORED_VOL_RATE;
       fetch STORED_VOL_RATE INTO p_REVAL_TYPE,p_RATE_DATE,p_BID, p_ASK;
       close STORED_VOL_RATE;

   open NUM;
    fetch NUM INTO p_UNIQUE_REF_NUM;
   close NUM;

   insert into XTR_REVALUATION_RATES
    (batch_id,unique_ref_num,company_code,period_from,period_to,reval_type,
     currencya,bid,ask,entered_on,
     entered_by,rate_date,volatility_or_rate,day_mth,day_count_basis,currencyb,period_ref1,
     period_ref2,number_of_days,created_on,created_by)
   values
   (p_BATCH_ID,p_UNIQUE_REF_NUM,l_company,l_start_date,l_end_date,
    l_vol_code,p_CURRENCYA,p_BID,p_ASK,
    l_sysdate,fnd_global.user_id,nvl(p_RATE_DATE,l_end_date),p_VOLATILITY_OR_RATE,
    p_DAY_MTH,p_DAY_COUNT_BASIS,p_CURRENCYB,p_PERIOD_REF1,p_PERIOD_REF2,
    IM_NOS_OF_DAYS,l_sysdate,fnd_global.user_id);
  end if;
 END LOOP;
 close OPTION_VOLS;
 --
 open INSTRUMENTS_MAINTAINED;
  fetch INSTRUMENTS_MAINTAINED INTO p_REVAL_TYPE,p_PERIOD_REF1,p_PERIOD_REF2,
                                    p_CURRENCYA, p_CURRENCYB,l_term_type, l_day_count_basis,
                                    l_bid_curr_rate,l_ask_curr_rate,l_latest_rate_date,
                                    IM_NOS_OF_DAYS;
 WHILE INSTRUMENTS_MAINTAINED%FOUND LOOP
  p_RATE_DATE  := l_latest_rate_date;
  p_BID := l_bid_curr_rate;
  p_ASK := l_ask_curr_rate;
  p_DAY_COUNT_BASIS := l_day_count_basis;
  if l_term_type in('D','F') then
    if p_PERIOD_REF1 = 1 then
      p_DAY_MTH := 'DAY';
    else
      p_DAY_MTH := 'DAYS';
    end if;
    p_NUMBER_OF_DAYS := p_PERIOD_REF1;
  elsif l_term_type in('M','W') then
    if p_PERIOD_REF1 = 1 then
      p_DAY_MTH := 'MONTH';
    else
      p_DAY_MTH := 'MONTHS';
    end if;
    p_NUMBER_OF_DAYS := p_PERIOD_REF1 * 30;
  elsif l_term_type = 'Y' then
    if p_PERIOD_REF1 = 1 then
      p_DAY_MTH := 'YEAR';
    else
      p_DAY_MTH := 'YEARS';
    end if;
    p_NUMBER_OF_DAYS := p_PERIOD_REF1 * 360;
  elsif l_term_type in ('B', 'T') then
    p_DAY_MTH :=null;
    p_NUMBER_OF_DAYS :=null;
  end if;

  if l_term_type in('F','W') then
    p_VOLATILITY_OR_RATE := 'FWDS';
  elsif l_term_type in('B', 'T') then
    p_VOLATILITY_OR_RATE := 'PRIC';
  else
    p_VOLATILITY_OR_RATE := 'RATE';
  end if;

  if l_term_type = 'S' then
    -- Get FX SPOT Rates
    p_UNIQUE_REF_NUM := NULL;
    p_DAY_MTH := NULL;
    open RATES_FX_SPOT;
    fetch RATES_FX_SPOT INTO p_RATE_DATE,p_BID, p_ASK;

    if RATES_FX_SPOT%NOTFOUND then
      p_RATE_DATE := l_latest_rate_date;
      p_BID := l_bid_curr_rate;
      p_ASK := l_ask_curr_rate;
    end if;

    close RATES_FX_SPOT;
    p_NUMBER_OF_DAYS := 2;
    p_PERIOD_REF1 := NULL;
    open NUM;
     fetch NUM INTO p_UNIQUE_REF_NUM;
    close NUM;

   insert into XTR_REVALUATION_RATES
    (batch_id,unique_ref_num,company_code,period_from,period_to,reval_type,
     currencya,bid,ask,entered_on,
     entered_by,rate_date,volatility_or_rate,day_mth,day_count_basis,currencyb,period_ref1,
     period_ref2,number_of_days,created_on,created_by)
   values
    (p_BATCH_ID,p_UNIQUE_REF_NUM,l_company,l_start_date,l_end_date,
     p_REVAL_TYPE,p_CURRENCYA,p_BID,p_ASK,
    l_sysdate,fnd_global.user_id,nvl(p_RATE_DATE,l_end_date),p_VOLATILITY_OR_RATE,
     p_DAY_MTH,p_day_count_basis,p_CURRENCYB,p_PERIOD_REF1,p_PERIOD_REF2,
    IM_NOS_OF_DAYS,l_sysdate,fnd_global.user_id);
  else
    p_UNIQUE_REF_NUM := NULL;
    -- Get OTHER Rates
    open RATES_NON_FX;
    fetch RATES_NON_FX INTO p_RATE_DATE,p_BID, p_ASK;

    if RATES_NON_FX%NOTFOUND then
      p_RATE_DATE := l_latest_rate_date;
      p_BID := l_bid_curr_rate;
      p_ASK := l_ask_curr_rate;
    end if;
   close RATES_NON_FX;

   open NUM;
    fetch NUM INTO p_UNIQUE_REF_NUM;
   close NUM;

   insert into XTR_REVALUATION_RATES
    (batch_id,unique_ref_num,company_code,period_from,period_to,reval_type,
     currencya,bid, ask,entered_on,
     entered_by,rate_date,volatility_or_rate,day_mth,day_count_basis,currencyb,period_ref1,
     period_ref2,number_of_days,created_on,created_by)
   values
    (p_BATCH_ID,p_UNIQUE_REF_NUM,l_company,l_start_date,l_end_date,
     p_REVAL_TYPE,p_CURRENCYA,p_BID,p_ASK,
     l_sysdate,fnd_global.user_id,nvl(p_RATE_DATE,l_end_date),p_VOLATILITY_OR_RATE,
     p_DAY_MTH,p_DAY_COUNT_BASIS,p_CURRENCYB,p_PERIOD_REF1,p_PERIOD_REF2,
     IM_NOS_OF_DAYS,l_sysdate,fnd_global.user_id);
  end if;
  fetch INSTRUMENTS_MAINTAINED INTO p_REVAL_TYPE,p_PERIOD_REF1,p_PERIOD_REF2,
                                    p_CURRENCYA, p_CURRENCYB,l_term_type, l_day_count_basis,
                                    l_bid_curr_rate, l_ask_curr_rate,l_latest_rate_date,
                                    IM_NOS_OF_DAYS;
 END LOOP;
 close INSTRUMENTS_MAINTAINED;

 commit;

end GET_ALL_REVAL_RATES;
-----------------------------------------------------------------------------
/***********************************************************************/
/* This procedure calculation Revaluation details and insert into table*/
/* Before calculating reval detail, we need to make sure:              */
/* (1) the previous batch for the same company has been run            */
/* (2) The batch is not run yet                                        */
/***********************************************************************/
PROCEDURE CALC_REVALS(errbuf       OUT NOCOPY VARCHAR2,
       	              retcode      OUT NOCOPY NUMBER,
	              p_company IN VARCHAR2,
	              p_batch_id IN NUMBER) IS

Cursor CHK_PRE_BATCH is
Select 'Y'
From   XTR_BATCHES CUR, XTR_BATCHES PRE,
       XTR_BATCH_EVENTS EV
Where  cur.batch_id = p_batch_id
and    cur.company_code = pre.company_code
and ((   cur.batch_id > pre.batch_id
and    pre.batch_id = ev.batch_id
and    ev.event_code = 'REVAL' ) or pre.batch_id is null)
order by pre.batch_id desc;

Cursor CHK_BATCH_RUN is
Select 'Y'
From   XTR_BATCH_EVENTS
Where  batch_id = p_batch_id
and    event_code = 'REVAL';

rec xtr_revl_rec;
l_rc NUMBER;
r_rd XTR_REVALUATION_DETAILS%rowtype;
l_cur VARCHAR2(1);  -- cursor holder
l_cur1 VARCHAR2(1);
l_dirname  VARCHAR2(240);
--retcode	NUMBER;

begin
/* TBC comment out temporarily. allow very first batch to run */
/*
 Open CHK_PRE_BATCH;
 Fetch CHK_PRE_BATCH into l_cur;
 If CHK_PRE_BATCH%NOTFOUND then -- The previous batch has not run yet
    Close CHK_PRE_BATCH;
    Raise e_no_pre_batch;
 End If;
    Close CHK_PRE_BATCH;
*/

 Open CHK_BATCH_RUN;
 Fetch CHK_BATCH_RUN into l_cur1;
 If CHK_BATCH_RUN%FOUND then -- the current batch has run
    Close CHK_BATCH_RUN;
    Raise e_batch_been_run;
 End If;
    Close CHK_BATCH_RUN;

   xtr_risk_debug_pkg.start_conc_prog;
  t_log_init;  -- initial the temp error log table
  xtr_revl_main(p_batch_id, rec, r_rd, l_rc);
  if g_status = 1 then
     retcode := 1;
  end if;
   xtr_risk_debug_pkg.stop_conc_debug;

-------------------------------------
/*  For local debugging purpose only
-------------------------------------
 SELECT SUBSTR(value,1,DECODE(INSTR(value,','),0,LENGTH(value),INSTR(value,',')-1) )
 into l_dirname
 from  v$parameter
 where name = 'utl_file_dir';

 xtr_risk_debug_pkg.start_debug(l_dirname, 'reval.log');
  t_log_init;  -- initial the temp error log table
  xtr_revl_main(p_batch_id, rec, r_rd, retcode);
 xtr_risk_debug_pkg.stop_debug;
*/

EXCEPTION
 When e_no_pre_batch then
   FND_MESSAGE.Set_Name('XTR', 'XTR_NO_PRE_REVAL');
   FND_MESSAGE.Set_Token('BATCH', p_batch_id);
   APP_EXCEPTION.raise_exception;
 When e_batch_been_run then
   FND_MESSAGE.Set_Name('XTR', 'XTR_BATCH_IN_REVAL');
   FND_MESSAGE.Set_Token('BATCH', p_batch_id);
   APP_EXCEPTION.raise_exception;

end CALC_REVALS;
--------------------------------------------------------
/********************************************************/
/* The real process to calculate revaluation details    */
/********************************************************/
PROCEDURE xtr_revl_main(
            p_batch_id IN NUMBER,
            rec IN OUT NOCOPY xtr_revl_rec,
            r_rd IN OUT NOCOPY XTR_REVALUATION_DETAILS%rowtype,
            retcode  OUT NOCOPY NUMBER) IS
l_buf Varchar2(500);
l_batch_end     DATE;
l_batch_start   DATE;
l_company_code  VARCHAR2(7);
l_accounting    VARCHAR2(30);
l_exchange_type VARCHAR2(30);
l_sob_ccy       VARCHAR2(15); -- company SOB currency
l_fv            NUMBER; -- fairvalue
l_rc            NUMBER := 0; -- return code
l_end_fv	NUMBER;
unrel_pl_value  NUMBER; -- unrealized P/L
rel_pl_value    NUMBER; -- realized P/L
cum_pl_value    NUMBER:= null; -- cumulative unrealized P/L
rel_sob_gl      NUMBER; -- realized G/L in SOB currency
unrel_sob_gl    NUMBER; -- unrealized G/L in SOB currency
currency_gl     NUMBER; -- G/L in reval currency
rel_curr_gl	NUMBER;
unrel_curr_gl	NUMBER;
fv_sob_amt	NUMBER; -- Fair value of SOB currency
l_ca_acct	VARCHAR2(20);  -- Account number for CA
ca_deal_no	NUMBER;
ca_currency     VARCHAR2(15);
ca_port	        VARCHAR2(7);
ig_deal_no	NUMBER;
ig_currency	VARCHAR2(15);
ig_product      VARCHAR2(10);
onc_deal_no	NUMBER;
onc_currency    VARCHAR2(15);
onc_subtype	VARCHAR2(7);
rel_currency_gl NUMBER; -- For IG, CA, and ONC
unrel_currency_gl 	NUMBER; -- For IG, CA, and ONC
l_tmp		xtr_eligible_rec;
l_round		NUMBER;
l_reneg_date	DATE;
l_ni_pl		NUMBER;
l_dummy		NUMBER;
l_dummy1	NUMBER;
l_dummy2	NUMBER;
l_port		VARCHAR2(7);
l_ca_rate       NUMBER;
r_fx_rate xtr_revl_fx_rate; -- record type
l_sob_curr_rate NUMBER;
l_first	       BOOLEAN;
l_deno          NUMBER;
l_numer         NUMBER;
l_base_ccy      VARCHAR2(15);
l_contra_ccy    VARCHAR2(15);
l_reverse      BOOLEAN;
l_fx_rate	NUMBER;
l_fx_param	VARCHAR2(50);
l_complete_flag       VARCHAR2(1);
l_hedge_flag    VARCHAR2(1) := 'N';
l_close_no	NUMBER;
r_err_log       err_log; -- record type

   /**************************************************************/
   /* Find all eligible deals for each deal type for revaluation */
   /**************************************************************/
cursor c_bdo_deal is
Select * from XTR_BDO_ELIGIBLE_DEALS_V
   where eligible_date <= l_batch_end and company_code = l_company_code;

Cursor c_bond_deal is
Select * from XTR_BOND_ELIGIBLE_DEALS_V
   where eligible_date <= l_batch_end and company_code = l_company_code;

Cursor c_fra_deal is
   Select * from XTR_FRA_ELIGIBLE_DEALS_V
   where eligible_date <= l_batch_end and company_code = l_company_code;

Cursor c_hedge is
Select * from XTR_ELIGIBLE_HEDGES_V
   where eligible_date <= l_batch_end and company_code = l_company_code;

Cursor c_fx_hedge_deal is
Select * from XTR_FX_ELIGIBLE_DEALS_V
where eligible_date <= l_batch_end and company_code = l_company_code
and deal_no in (select h.primary_code
                from xtr_hedge_relationships H, xtr_revaluation_details R
                where h.instrument_item_flag = 'U'
                and r.batch_id = p_batch_id
                and h.hedge_attribute_id = r.deal_no);

Cursor c_fx_deal is
Select * from XTR_FX_ELIGIBLE_DEALS_V
where eligible_date <= l_batch_end and company_code = l_company_code
and deal_no not in (select h.primary_code
		from xtr_hedge_relationships H, xtr_revaluation_details R
		where h.instrument_item_flag = 'U'
		and r.batch_id = p_batch_id
		and h.hedge_attribute_id = r.deal_no);

Cursor c_fxo_deal is
   Select * from XTR_FXO_ELIGIBLE_DEALS_V
   where eligible_date <= l_batch_end and company_code = l_company_code;

-- For IG, we calculate currency G/L for each deal number of the company
-- which is the unique combination of company, cparty, and currency
Cursor c_ig_deal is
   Select distinct deal_no, currencya from XTR_IG_ELIGIBLE_DEALS_V
   where eligible_date <= l_batch_end and company_code = l_company_code;

Cursor c_iro_deal is
   Select * from XTR_IRO_ELIGIBLE_DEALS_V
   where eligible_date <= l_batch_end and company_code = l_company_code;

Cursor c_irs_deal is
Select * from XTR_IRS_ELIGIBLE_DEALS_V
   where eligible_date <= l_batch_end and company_code = l_company_code;

Cursor c_ni_deal is
   Select * from XTR_NI_ELIGIBLE_DEALS_V
   where eligible_date <= l_batch_end and company_code = l_company_code;

Cursor c_onc_deal is
   Select distinct deal_no, deal_subtype, currencya, portfolio_code
   from XTR_ONC_ELIGIBLE_DEALS_V
   where eligible_date <= l_batch_end and company_code = l_company_code;

Cursor c_swptn_deal is
   Select * from XTR_SWPTN_ELIGIBLE_DEALS_V
   where eligible_date <= l_batch_end and company_code = l_company_code;

Cursor c_rtmm_deal is
   Select * from XTR_RTMM_ELIGIBLE_DEALS_V
   where eligible_date <= l_batch_end and company_code = l_company_code
   and deal_no in (select deal_no from xtr_deals where deal_type = 'RTMM'
	           and last_reval_batch_id is null);

Cursor c_stock_deal is
   select * from XTR_STOCK_ELIGIBLE_DEALS_V
   where eligible_date <= l_batch_end and company_code = l_company_code;

Cursor c_tmm_deal is
Select * from XTR_TMM_ELIGIBLE_DEALS_V
   where eligible_date <= l_batch_end  and company_code = l_company_code;

-- For CA, we calculate currency G/L for each account number of the company
Cursor c_ca_acct is
Select distinct ca.account_no, ca.currencya, dda.deal_number,
       ca.portfolio_code
from XTR_CA_ELIGIBLE_DEALS_V CA,
     XTR_DEAL_DATE_AMOUNTS DDA
where ca.company_code = l_company_code
   and ca.eligible_date <= l_batch_end
   and ca.company_code = dda.company_code
   and ca.currencya   = dda.currency
   and dda.deal_type = 'CA'
   and ca.account_no = dda.account_no;

begin
-- set the flag to indicate it is called by concurrent program
-- so that error log will write to the output file
    set_call_by_curr;

    select PERIOD_END, COMPANY_CODE, PERIOD_START
    into l_batch_end, l_company_code, l_batch_start
    from xtr_batches
    where BATCH_ID = p_batch_id;

    select PARAMETER_VALUE_CODE into l_accounting
    from xtr_company_parameters
    where COMPANY_CODE = l_company_code and
        PARAMETER_CODE = C_DEAL_SETTLE_ACCOUNTING;

    select PARAMETER_VALUE_CODE into l_exchange_type
    from xtr_company_parameters
    where COMPANY_CODE = l_company_code and
      PARAMETER_CODE = C_EXCHANGE_RATE_TYPE;

    select sob.currency_code
    into l_sob_ccy
    from gl_sets_of_books sob, xtr_party_info pinfo
    where pinfo.party_code = l_company_code
    and pinfo.set_of_books_id = sob.SET_OF_BOOKS_ID;

    select param_value
    into l_fx_param
    from XTR_PRO_PARAM
    where param_type = 'DFLTVAL'
    and param_name = 'FX_REALIZED_RATE';

    rec.batch_id       := p_batch_id;
    rec.batch_start    := l_batch_start;
    rec.company_code   := l_company_code;
    rec.revldate       := l_batch_end;
    rec.sob_ccy        := l_sob_ccy;
    rec.ex_rate_type   := l_exchange_type;

--  Insert into XTR_BATCH_EVENTS table
    xtr_insert_event(p_batch_id);

   /********************* BDO revaluation ***********************/
    for l_tmp in c_bdo_deal loop
        xtr_get_deal_value(l_tmp, rec, r_rd);
        xtr_revl_get_fairvalue(rec, l_fv, retcode);
        rec.fair_value := l_fv;

      if l_tmp.effective_date <=  l_batch_end  and
         (rec.status_code = 'EXPIRED' or rec.status_code = 'EXERCISED') then
 	 -- Insert realized g/l info to XTR_REVALUATION_DETAILS
	 rel_pl_value := rec.fair_value - rec.init_fv;
         xtr_revl_exchange_rate(rec, retcode);
         xtr_revl_get_curr_gl(rec, null, rel_pl_value,
             fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
	 xtr_revl_real_log(rec, rel_pl_value, fv_sob_amt, rel_sob_gl, currency_gl, r_rd, retcode);

         -- Also insert the last unrealized g/l info to XTR_REVALUATION_DETAILS
         xtr_get_fv_from_batch(rec, l_dummy, l_dummy1, cum_pl_value, l_dummy2);
         unrel_pl_value := rel_pl_value - cum_pl_value;
         xtr_revl_get_curr_gl(rec, unrel_pl_value, null,
             fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
         xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
	     unrel_sob_gl, currency_gl, r_rd, retcode);
      else
         xtr_revl_get_unrel_pl(rec, unrel_pl_value,cum_pl_value, retcode);
         xtr_revl_exchange_rate(rec, retcode);
         xtr_revl_get_curr_gl(rec, unrel_pl_value, rel_pl_value,
             fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
         xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
	     unrel_sob_gl, currency_gl, r_rd, retcode);
      end if;
    cum_pl_value:= null;
    END loop;
    l_tmp := null;

   /********************* BOND revaluation ***********************/
    for l_tmp in c_bond_deal loop
      xtr_get_deal_value(l_tmp, rec, r_rd);
      xtr_revl_get_fairvalue(rec, l_fv, retcode);
      rec.fair_value := l_fv;

    END loop;
   l_tmp := null;

   /********************* FRA revaluation ***********************/
    for l_tmp in c_fra_deal loop
        xtr_get_deal_value(l_tmp, rec,r_rd);
        xtr_revl_get_fairvalue(rec, l_fv, retcode);
        rec.fair_value := l_fv;

      if l_rc = 0 then
         if l_tmp.effective_date <=  l_batch_end and rec.status_code = 'SETTLED'  then
            -- Insert realized g/l info to XTR_REVALUATION_DETAILS
            rel_pl_value := rec.fair_value - rec.init_fv;
            xtr_revl_exchange_rate(rec, retcode);
            xtr_revl_get_curr_gl(rec, null, rel_pl_value,
                fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
            xtr_revl_real_log(rec, rel_pl_value, fv_sob_amt, rel_sob_gl, currency_gl, r_rd, retcode);

             -- Also insert the last unrealized g/l info to XTR_REVALUATION_DETAILS
            xtr_get_fv_from_batch(rec, l_dummy, l_dummy1, cum_pl_value, l_dummy2);
            unrel_pl_value := rel_pl_value - cum_pl_value;
            xtr_revl_get_curr_gl(rec, unrel_pl_value, null,
                fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
            xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
	        unrel_sob_gl, currency_gl, r_rd, retcode);

         else  -- calculate unrealized g/l
	    if l_tmp.effective_date <= l_batch_end and l_tmp.settle_amount is null then
-- this deal should be mature, but user does not settle it. Still create unrealized g/l row
               unrel_pl_value := 0;
               fv_sob_amt     := 0;
	       unrel_sob_gl   := 0;
	       currency_gl    := 0;
	    else
               xtr_revl_get_unrel_pl(rec, unrel_pl_value,cum_pl_value, retcode);
               xtr_revl_exchange_rate(rec, retcode);
               xtr_revl_get_curr_gl(rec, unrel_pl_value, rel_pl_value,
                fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
	    end if;
            xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
	       unrel_sob_gl, currency_gl, r_rd, retcode);
         end if;
      end if;
    cum_pl_value:= null;
    END loop;
    l_tmp := null;
--
   /********************** HEDGE revaluation ***********************/
   for l_tmp in c_hedge loop
      xtr_get_deal_value(l_tmp, rec, r_rd);
      xtr_revl_fv_hedge(rec);
   end loop;
   l_tmp :=  NULL;

---
   /********************* Hedge associated FX revaluation ***********************/
   /* This process needs to be done after Hedge item been revalued. So system   */
   /* system can find hedge related FX deals based on xtr_revaluation_details   */
   /* table.                                                                    */
   /*****************************************************************************/
    for l_tmp in c_fx_hedge_deal loop
      xtr_get_deal_value(l_tmp, rec, r_rd);
      xtr_revl_fv_fxh(rec, r_rd);
      cum_pl_value:= null;
    end loop;
    l_tmp := NULL;
--

   /********************* FX revaluation ***********************/
    for l_tmp in c_fx_deal loop
      xtr_get_deal_value(l_tmp, rec, r_rd);

      if l_tmp.effective_date <= l_batch_end then
         -- Insert realized g/l info to XTR_REVALUATION_DETAILS
         if rec.status_code = 'CLOSED' then  -- this deal is predeliever/rollover
	    select profit_loss, fx_ro_pd_rate
	    into rel_pl_value, l_fx_rate
	    from XTR_DEALS
	    where deal_no = rec.deal_no;

	    rec.fair_value := rel_pl_value + rec.init_fv;
	    rec.reval_rate := l_fx_rate;
            rec.reval_fx_fwd_rate := null;
	 else  -- status = 'CURRENT'. Hold to maturity
               if l_fx_param = 'Y' then    -- system parameter for FX realized records
		  rec.effective_date := rec.revldate;
	       end if;

               xtr_revl_getrate_fx(rec, l_hedge_flag, r_fx_rate);
               rec.reval_rate := r_fx_rate.fx_forward_rate;
               xtr_revl_fv_fx(rec, r_fx_rate, l_hedge_flag, l_fv, l_sob_curr_rate);
               rec.reval_fx_fwd_rate := l_sob_curr_rate;
               rec.fair_value := l_fv;

               rel_pl_value := rec.fair_value - rec.init_fv;
	 end if;
	 xtr_revl_fx_curr_gl(rec, l_hedge_flag, TRUE, currency_gl);
         xtr_revl_real_log(rec, rel_pl_value, rec.fair_value, rel_pl_value,
		currency_gl, r_rd, retcode);

         -- Also insert the last unrealized g/l info to XTR_REVALUATION_DETAILS
	 -- For spot, we only show one realized record. This part is not needed
            xtr_get_fv_from_batch(rec, l_dummy, l_dummy1, cum_pl_value, l_dummy2);
            unrel_pl_value := rel_pl_value - cum_pl_value;
            xtr_revl_fx_curr_gl(rec, l_hedge_flag, FALSE, currency_gl);
            xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, rec.fair_value,
	     unrel_pl_value, currency_gl, r_rd, retcode);

      else  -- calculate unrealized g/l
         if rec.deal_subtype = 'FORWARD' then
              xtr_revl_getrate_fx(rec, l_hedge_flag, r_fx_rate);
              rec.reval_rate := r_fx_rate.fx_forward_rate;
              xtr_revl_fv_fx(rec, r_fx_rate, l_hedge_flag, l_fv, l_sob_curr_rate);
              rec.reval_fx_fwd_rate := l_sob_curr_rate;
              rec.fair_value := l_fv;
         else   -- SPOT
	    rec.reval_rate := rec.transaction_rate;
            rec.fair_value := 0;
            rec.reval_fx_fwd_rate := null;
         end if;

            xtr_revl_get_unrel_pl(rec, unrel_pl_value,cum_pl_value, retcode);
            xtr_revl_fx_curr_gl(rec, l_hedge_flag, FALSE, currency_gl);
       /** For FX, the reval ccy is SOB ccy, so the unrel_pl_value = unrel_sob_gl */
            xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, rec.fair_value,
	    unrel_pl_value, currency_gl, r_rd, retcode);
      end if;
    cum_pl_value:= null;
    END loop;
   l_tmp := null;
--

   /********************* FXO revaluation ***********************/
   for l_tmp in c_fxo_deal loop
      xtr_get_deal_value(l_tmp, rec, r_rd);
      xtr_revl_get_fairvalue(rec, l_fv, retcode);
      rec.fair_value := l_fv;

      if l_rc = 0 then
         if l_tmp.effective_date <=  l_batch_end  and
         (rec.status_code = 'EXPIRED' or rec.status_code = 'EXERCISED') then
            -- The deal is mature. We may calculate realized g/l
            -- Insert realized g/l info to XTR_REVALUATION_DETAILS
            rel_pl_value := rec.fair_value - rec.init_fv;
            xtr_revl_exchange_rate(rec, retcode);
            xtr_revl_get_curr_gl(rec, null, rel_pl_value,
                fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
            xtr_revl_real_log(rec, rel_pl_value, fv_sob_amt, rel_sob_gl, currency_gl, r_rd, retcode);

             -- Also insert the last unrealized g/l info to XTR_REVALUATION_DETAILS
            xtr_get_fv_from_batch(rec, l_dummy, l_dummy1, cum_pl_value, l_dummy2);
            unrel_pl_value := rel_pl_value - cum_pl_value;
            xtr_revl_get_curr_gl(rec, unrel_pl_value, null,
                fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
            xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
	        unrel_sob_gl, currency_gl, r_rd, retcode);

         else  -- calculate unrealized g/l
            xtr_revl_get_unrel_pl(rec, unrel_pl_value,cum_pl_value, retcode);
            xtr_revl_exchange_rate(rec, retcode);
            xtr_revl_get_curr_gl(rec, unrel_pl_value, rel_pl_value,
                fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
            xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
		unrel_sob_gl, currency_gl, r_rd, retcode);
         end if;
      end if;
    cum_pl_value:= null;
    END loop;
   l_tmp := null;
--
   /********************* IRO revaluation ***********************/
    for l_tmp in c_iro_deal loop
      xtr_get_deal_value(l_tmp, rec, r_rd);
      xtr_revl_get_fairvalue(rec, l_fv, retcode);
      rec.fair_value := l_fv;

      if l_rc = 0 then
         if l_tmp.effective_date <=  l_batch_end  and
         (rec.status_code = 'EXPIRED' or rec.status_code = 'EXERCISED') then
            -- The deal is mature. We may calculate realized g/l
            -- Insert realized g/l info to XTR_REVALUATION_DETAILS
            rel_pl_value := rec.fair_value - rec.init_fv;
            xtr_revl_exchange_rate(rec, retcode);
            xtr_revl_get_curr_gl(rec, null, rel_pl_value,
                fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
            xtr_revl_real_log(rec, rel_pl_value, fv_sob_amt, rel_sob_gl, currency_gl, r_rd, retcode);

             -- Also insert the last unrealized g/l info to XTR_REVALUATION_DETAILS
            xtr_get_fv_from_batch(rec, l_dummy, l_dummy1, cum_pl_value, l_dummy2);
            unrel_pl_value := rel_pl_value - cum_pl_value;
            xtr_revl_get_curr_gl(rec, unrel_pl_value, null,
                fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
            xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
		unrel_sob_gl, currency_gl, r_rd, retcode);

         else  -- calculate unrealized g/l
            xtr_revl_get_unrel_pl(rec, unrel_pl_value,cum_pl_value, retcode);
            xtr_revl_exchange_rate(rec, retcode);
            xtr_revl_get_curr_gl(rec, unrel_pl_value, rel_pl_value,
                fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
            xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
		unrel_sob_gl, currency_gl, r_rd, retcode);
         end if;
      end if;
    cum_pl_value:= null;
    END loop;
    l_tmp := null;
--
   /********************* IRS revaluation ***********************/
    for l_tmp in c_irs_deal loop
      xtr_get_deal_value(l_tmp, rec, r_rd);
      xtr_revl_get_fairvalue(rec, l_fv, retcode);
      rec.fair_value := l_fv;
      rec.reval_rate := null;

      if l_rc = 0 then
         if l_tmp.effective_date <=  l_batch_end  then
            -- The deal is mature. We may calculate realized g/l
            -- Insert realized g/l info to XTR_REVALUATION_DETAILS
            rel_pl_value := rec.fair_value - rec.init_fv;
            xtr_revl_exchange_rate(rec, retcode);

	    if rec.discount_yield = 'Y' then
	       -- there is principal exchange. Currency G/L is same as TMM curr G/L
	       xtr_revl_tmm_curr_gl(rec, rel_curr_gl, unrel_curr_gl);
               fv_sob_amt   := rec.fair_value * rec.reval_ex_rate_one;
               unrel_sob_gl := unrel_pl_value  * rec.reval_ex_rate_one;
               rel_sob_gl   := rel_pl_value    * rec.reval_ex_rate_one;
               xtr_revl_real_log(rec, rel_pl_value, fv_sob_amt, rel_sob_gl, rel_curr_gl,r_rd, retcode);
	    else  -- no principal cashflow. Use normal currency G/L
               xtr_revl_get_curr_gl(rec, null, rel_pl_value,
                fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
               xtr_revl_real_log(rec, rel_pl_value, fv_sob_amt, rel_sob_gl, currency_gl,r_rd, retcode);
	    end if;

             -- Also insert the last unrealized g/l info to XTR_REVALUATION_DETAILS
            xtr_get_fv_from_batch(rec, l_dummy, l_dummy1, cum_pl_value, l_dummy2);
            unrel_pl_value := rel_pl_value - cum_pl_value;
	    if rec.discount_yield = 'N' then
               xtr_revl_get_curr_gl(rec, unrel_pl_value, null,
                   fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
               xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
                unrel_sob_gl, currency_gl, r_rd, retcode);
	    else
               xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
                unrel_sob_gl, unrel_curr_gl, r_rd, retcode);
	    end if;
         else  -- calculate unrealized g/l
            xtr_revl_get_unrel_pl(rec, unrel_pl_value,cum_pl_value, retcode);
            xtr_revl_exchange_rate(rec, retcode);
	    if rec.discount_yield = 'Y' then
               xtr_revl_tmm_curr_gl(rec, rel_curr_gl, unrel_curr_gl);
               fv_sob_amt   := rec.fair_value * rec.reval_ex_rate_one;
               unrel_sob_gl := unrel_pl_value  * rec.reval_ex_rate_one;
               rel_sob_gl   := rel_pl_value    * rec.reval_ex_rate_one;
               xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
                unrel_sob_gl, unrel_curr_gl, r_rd, retcode);

               if nvl(rel_curr_gl, 0) <> 0 then
               -- We do have realized G/L for this record. insert a new row
                  xtr_revl_real_log(rec, 0, 0, 0, rel_curr_gl, r_rd, retcode);
               end if;
	    else
               xtr_revl_get_curr_gl(rec, unrel_pl_value, rel_pl_value,
                fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
               xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
                unrel_sob_gl, currency_gl, r_rd, retcode);
	    end if;
         end if;
       end if;
    cum_pl_value:= null;
    END loop;
   l_tmp := null;
--
   /********************* NI revaluation ***********************/
    for l_tmp in c_ni_deal loop
      xtr_get_deal_value(l_tmp, rec, r_rd);

      l_close_no := NULL;
      select trans_closeout_no, ni_profit_loss, initial_fair_value
      into l_close_no, l_ni_pl, rec.init_fv
      from xtr_rollover_transactions
      where deal_number = rec.deal_no
      and transaction_number = rec.trans_no;

      if l_close_no is NOT NULL then
        select decode(l_accounting, 'TRADE', deal_date, start_date)
        into l_reneg_date
        from XTR_DEALS
        where deal_no = l_close_no;
      end if;

      xtr_revl_get_fairvalue(rec, l_fv, retcode);
      rec.fair_value := l_fv;

      if l_rc = 0 then
         if (l_tmp.effective_date <=  l_batch_end) or
	    (rec.status_code = 'CLOSED' and l_reneg_date <= l_batch_end) then
            if (rec.status_code = 'CLOSED' and l_reneg_date <= l_batch_end) then
            -- This parcel has been resale or covered. We get realized G/L from
            -- rollover table ni_profit_loss column and + initial fv = FV.
	       rec.effective_date := l_reneg_date;
	       rec.period_end := l_reneg_date;
               rel_pl_value   := l_ni_pl;
               rec.fair_value := rel_pl_value + rec.init_fv;
               -- Insert reval rate equal to new resale deal's rate
               select interest_rate
               into rec.reval_rate
               from XTR_DEALS
               where deal_no = (select trans_closeout_no
                                from XTR_ROLLOVER_TRANSACTIONS
                                where deal_number = rec.deal_no
                                and transaction_number = rec.trans_no);
            else  -- The deal is mature. We may calculate realized g/l
               rel_pl_value := 0;
   	       xtr_end_fv(rec, rec.fair_value);
               rec.reval_rate := 0;
            end if;

            xtr_get_fv_from_batch(rec, l_dummy, l_dummy1, cum_pl_value, l_dummy2);
            xtr_revl_exchange_rate(rec, retcode);
            xtr_revl_get_curr_gl(rec, null, rel_pl_value,
                fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
            xtr_revl_real_log(rec, rel_pl_value, fv_sob_amt, rel_sob_gl, currency_gl, r_rd, retcode);

             -- Also insert the last unrealized g/l info to XTR_REVALUATION_DETAILS
            unrel_pl_value := rel_pl_value - cum_pl_value;
            xtr_revl_get_curr_gl(rec, unrel_pl_value, null,
                fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
	    xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
		unrel_sob_gl, currency_gl, r_rd, retcode);

         else  -- calculate unrealized g/l
            xtr_revl_get_unrel_pl(rec, unrel_pl_value,cum_pl_value, retcode);
            xtr_revl_exchange_rate(rec, retcode);
            xtr_revl_get_curr_gl(rec, unrel_pl_value, rel_pl_value,
                fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
            xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
		unrel_sob_gl, currency_gl, r_rd, retcode);
         end if;
      end if;
    cum_pl_value:= null;
    END loop;
   l_tmp := null;
--
   /********************* STOCK revaluation ***********************/
    for l_tmp in c_stock_deal loop
       xtr_get_deal_value(l_tmp, rec, r_rd);
       xtr_revl_get_fairvalue(rec, l_fv, retcode);
       rec.fair_value := l_fv;
    end loop;
    l_tmp := null;
--

   /********************* RTMM revaluation ***********************/
    for l_tmp in c_rtmm_deal loop
       xtr_get_deal_value(l_tmp, rec, r_rd);
       xtr_revl_get_fairvalue(rec, l_fv, retcode);
       rec.fair_value := l_fv;

       if l_tmp.effective_date <=  l_batch_end  then
          -- The deal is mature. We may calculate realized g/l
          -- Insert realized g/l info to XTR_REVALUATION_DETAILS
          rel_pl_value := rec.fair_value - rec.init_fv;
          xtr_revl_exchange_rate(rec, retcode);
          xtr_revl_get_curr_gl(rec, null, rel_pl_value,
              fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
          xtr_revl_real_log(rec, rel_pl_value, fv_sob_amt, rel_sob_gl, currency_gl, r_rd, retcode);

          -- Also insert the last unrealized g/l info to XTR_REVALUATION_DETAILS
          xtr_get_fv_from_batch(rec, l_dummy, l_dummy1, cum_pl_value, l_dummy2);
          unrel_pl_value := rel_pl_value - cum_pl_value;
          xtr_revl_get_curr_gl(rec, unrel_pl_value, null,
              fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
          xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
		unrel_sob_gl, currency_gl, r_rd, retcode);

       else  -- calculate unrealized g/l
          xtr_revl_get_unrel_pl(rec, unrel_pl_value,cum_pl_value, retcode);
          xtr_revl_exchange_rate(rec, retcode);
          xtr_revl_get_curr_gl(rec, unrel_pl_value, rel_pl_value,
              fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
          xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
		unrel_sob_gl, currency_gl, r_rd, retcode);
       end if;
    cum_pl_value:= null;
    END loop;
    l_tmp := null;
--
   /********************* SWPTN revaluation ***********************/
    for l_tmp in c_swptn_deal loop
      xtr_get_deal_value(l_tmp, rec, r_rd);
      xtr_revl_get_fairvalue(rec, l_fv, retcode);
      rec.fair_value := l_fv;

      if l_tmp.effective_date <=  l_batch_end  and
         (rec.status_code = 'EXPIRED' or rec.status_code = 'EXERCISED') then
         -- The deal is mature. We may calculate realized g/l
         -- Insert realized g/l info to XTR_REVALUATION_DETAILS
            rel_pl_value := rec.fair_value - rec.init_fv;
            xtr_revl_exchange_rate(rec, retcode);
            xtr_revl_get_curr_gl(rec, null, rel_pl_value,
                fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
            xtr_revl_real_log(rec, rel_pl_value, fv_sob_amt, rel_sob_gl, currency_gl, r_rd, retcode);

             -- Also insert the last unrealized g/l info to XTR_REVALUATION_DETAILS
            xtr_get_fv_from_batch(rec, l_dummy, l_dummy1, cum_pl_value, l_dummy2);
            unrel_pl_value := rel_pl_value - cum_pl_value;
            xtr_revl_get_curr_gl(rec, unrel_pl_value, null,
                fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
            xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
		unrel_sob_gl, currency_gl, r_rd, retcode);
       else
            xtr_revl_get_unrel_pl(rec, unrel_pl_value,cum_pl_value, retcode);
	    xtr_revl_exchange_rate(rec, retcode);
            xtr_revl_get_curr_gl(rec, unrel_pl_value, rel_pl_value,
                fv_sob_amt, rel_sob_gl, unrel_sob_gl, currency_gl);
            xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
		unrel_sob_gl, currency_gl, r_rd, retcode);
       end if;
    cum_pl_value:= null;
    END loop;
    l_tmp := null;

/********************* TMM revaluation ***********************/
    for l_tmp in c_tmm_deal loop
      xtr_get_deal_value(l_tmp, rec, r_rd);
      xtr_revl_get_fairvalue(rec, l_fv, retcode);
      rec.fair_value := l_fv;

      if l_rc = 0 then
         if l_tmp.effective_date <=  l_batch_end  then
            -- The deal is mature. We may calculate realized g/l
            -- Insert realized g/l info to XTR_REVALUATION_DETAILS
            rel_pl_value := rec.fair_value - rec.init_fv;
            xtr_get_fv_from_batch(rec, l_dummy, l_dummy1, cum_pl_value, l_dummy2);
            unrel_pl_value := rel_pl_value - cum_pl_value;
            xtr_revl_tmm_curr_gl(rec, rel_curr_gl, unrel_curr_gl);
	    xtr_revl_exchange_rate(rec, retcode);
	    fv_sob_amt   := rec.fair_value * rec.reval_ex_rate_one;
            unrel_sob_gl := unrel_pl_value  * rec.reval_ex_rate_one;
	    rel_sob_gl   := rel_pl_value    * rec.reval_ex_rate_one;
            xtr_revl_real_log(rec, rel_pl_value, fv_sob_amt, rel_sob_gl, rel_curr_gl, r_rd, retcode);

             -- Also insert the last unrealized g/l info to XTR_REVALUATION_DETAILS
            xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
		unrel_sob_gl, unrel_curr_gl, r_rd, retcode);

         else  -- calculate unrealized g/l
            xtr_revl_get_unrel_pl(rec, unrel_pl_value,cum_pl_value, retcode);
            xtr_revl_tmm_curr_gl(rec, rel_curr_gl, unrel_curr_gl);
            xtr_revl_exchange_rate(rec, retcode);
            fv_sob_amt   := rec.fair_value * rec.reval_ex_rate_one;
            unrel_sob_gl := unrel_pl_value  * rec.reval_ex_rate_one;
            rel_sob_gl   := rel_pl_value    * rec.reval_ex_rate_one;
            xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
		unrel_sob_gl, unrel_curr_gl, r_rd, retcode);

	    if nvl(rel_curr_gl, 0) <> 0 then
	    -- We do have realized G/L for this record. insert a new row
		xtr_revl_real_log(rec, 0, 0, 0, rel_curr_gl, r_rd, retcode);
	    end if;
         end if;
      end if;
    cum_pl_value:= null;
    END loop;
    l_tmp := null;
--
   /********************* ONC revaluation ***********************/
    Open c_onc_deal;
    Fetch c_onc_deal into onc_deal_no,onc_subtype, onc_currency, l_port;
    -- Calculate each deal no's currency G/L
    While c_onc_deal%FOUND Loop
       rec.deal_type := 'ONC';
       rec.deal_subtype := onc_subtype;
       rec.deal_no   := onc_deal_no;
       rec.currencya := onc_currency;
       rec.reval_ccy := onc_currency;
       rec.portfolio_code := l_port;
       rec.account_no   := NULL;

       xtr_revl_onc_curr_gl(rec, l_rc);
       if l_rc = 1 then -- deal is incomplete
	  rec.trans_no := 1;
          select nvl(sum(principal_adjust), 0)
	  into rec.face_value
          from XTR_ROLLOVER_TRANSACTIONS
          where deal_number = rec.deal_no
          and  deal_type = 'ONC'
          and transaction_number in (select transaction_number
                           from XTR_ROLLOVER_TRANSACTIONS
                           where deal_number = rec.deal_no
                           and start_date <= rec.revldate
                           and (cross_ref_to_trans is null));

         rec.fair_value   := rec.face_value;
         rec.period_start := rec.batch_start;
         rec.period_end   := rec.revldate;
         r_rd.transaction_period := rec.period_end - rec.period_start;
         rec.effective_date := rec.revldate;
         r_rd.effective_days := rec.period_end - rec.period_start;
         r_rd.amount_type   := 'CCYUNRL';
         xtr_revl_unreal_log(rec, 0, 0, 0, 0, null, r_rd, retcode);
       end if;

       fetch c_onc_deal into onc_deal_no, onc_subtype, onc_currency, l_port;
    End Loop;
    Close c_onc_deal;

    l_tmp := null;
--
   /********************* IG revaluation ***********************/
    Open c_ig_deal;
    Fetch c_ig_deal into ig_deal_no, ig_currency;  -- Calculate each deal no's currency G/L
    While c_ig_deal%FOUND Loop
       rec.deal_type := 'IG';
       rec.deal_subtype := 'INVEST';
       rec.deal_no   := ig_deal_no;
       rec.currencya := ig_currency;
       rec.reval_ccy := rec.sob_ccy;
       rec.transaction_rate := 0;
       rec.account_no     := NULL;

       xtr_revl_ig_curr_gl(rec, l_rc);
       if l_rc = 1 then -- deal is incomplete
         select face_value, product_type
         into rec.face_value, rec.product_type
         from xtr_ig_eligible_deals_v
         where deal_no  = rec.deal_no
         and company_code = rec.company_code
	 and transaction_no = (select max(transaction_no)
			       from xtr_ig_eligible_deals_v
			       where deal_no = rec.deal_no
			       and effective_date = (select max(effective_date)
         			                       from xtr_ig_eligible_deals_v
                               			       where deal_no = rec.deal_no
		                                       and company_code = rec.company_code
                       			               and eligible_date <= rec.revldate));
         rec.fair_value   := rec.face_value;
         rec.trans_no := 1;
         rec.period_start := rec.batch_start;
         rec.period_end   := rec.revldate;
         r_rd.transaction_period := rec.period_end - rec.period_start;
         rec.effective_date := rec.revldate;
         r_rd.effective_days := rec.period_end - rec.period_start;
         r_rd.amount_type   := 'CCYUNRL';
         xtr_revl_unreal_log(rec, 0, 0, 0, 0, null, r_rd, retcode);
	 update XTR_INTERGROUP_TRANSFERS
	 set first_batch_id = rec.batch_id
	 where company_code = rec.company_code
         and deal_number = rec.deal_no
	 and transfer_date <= rec.revldate;
       end if;

       Fetch c_ig_deal into ig_deal_no, ig_currency;
    End Loop;
    Close c_ig_deal;
    l_tmp := null;

   /********************* CA revaluation ***********************/
    Open c_ca_acct;
    Fetch c_ca_acct into l_ca_acct, ca_currency, ca_deal_no, ca_port;
        -- calculate each account's G/L
    While c_ca_acct%FOUND Loop
       rec.deal_type   := 'CA';
       rec.portfolio_code := ca_port;
       rec.account_no  := l_ca_acct;
       rec.currencya   := ca_currency;
       rec.reval_ccy   := rec.sob_ccy;
       rec.deal_no     := ca_deal_no;
       rec.trans_no    := 1;
       rec.product_type:= 'N/A';

       xtr_revl_ca_curr_gl(rec, l_rc);
       if l_rc = 1 then -- deal is incomplete
         select nvl(face_value,0), transaction_rate      -- added nvl for R12
         into rec.face_value, rec.transaction_rate
         from xtr_ca_eligible_deals_v
         where account_no = rec.account_no
         and company_code = rec.company_code
         and effective_date = (select max(effective_date)
                               from xtr_ca_eligible_deals_v
                               where account_no = rec.account_no
                               and company_code = rec.company_code
                               and eligible_date <= rec.revldate);
         rec.fair_value   := rec.face_value;
         if rec.fair_value >= 0 then
            rec.deal_subtype := 'INVEST';
         else
            rec.deal_subtype := 'FUND';
         end if;
         rec.period_start := rec.batch_start;
         rec.period_end   := rec.revldate;
         r_rd.transaction_period := rec.period_end - rec.period_start;
         rec.effective_date := rec.revldate;
         r_rd.effective_days := rec.period_end - rec.period_start;
         r_rd.amount_type := 'CCYUNRL';
         xtr_revl_unreal_log(rec, 0, 0, 0, 0, null, r_rd, retcode);
         update XTR_BANK_BALANCES
         set first_batch_id = rec.batch_id
         where company_code = rec.company_code
         and account_number = rec.account_no
         and balance_date <= rec.revldate;
       end if;

       fetch c_ca_acct into l_ca_acct, ca_currency, ca_deal_no, ca_port;
    End Loop;
    Close c_ca_acct;

    t_log_dump;


EXCEPTION
  when GL_CURRENCY_API.no_rate then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_GL_RATE');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
         set_err_log(retcode);
         FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_RATE_CURRENCY_GL');
         FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
         FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
         FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
         l_buf := FND_MESSAGE.GET;
         FND_FILE.put_line(fnd_file.log, l_buf);
      end if;
  when GL_CURRENCY_API.invalid_currency then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_INVALID_CURRENCY');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      FND_MESSAGE.set_token('CURRENCY', rec.currencya);
      APP_EXCEPTION.raise_exception;
    else
         set_err_log(retcode);
         FND_MESSAGE.SET_NAME('XTR', 'XTR_INVALID_CURRENCY_TYPE');
         FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
         FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
         FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
         l_buf := FND_MESSAGE.GET;
         FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_main');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
end xtr_revl_main;
--------------------------------------------------------
/********************************************************/
/* This procedure get necessary deal info in order to   */
/* calculate fair value and other G/L values            */
/********************************************************/
PROCEDURE xtr_get_deal_value(
	  l_tmp  IN xtr_eligible_rec,
  	  rec    IN OUT NOCOPY xtr_revl_rec,
	  r_rd   OUT NOCOPY XTR_REVALUATION_DETAILS%rowtype) is

 Cursor C_ITEM_TOTAL is
 select sum(reference_amount)
 from xtr_hedge_relationships
 where hedge_attribute_id = rec.deal_no
 and instrument_item_flag = 'I';

 Cursor C_HEDGE_BAL is
 select min(reclass_balance_amt)
 from XTR_RECLASS_DETAILS
 where hedge_attribute_id = rec.deal_no
 and reclass_date <= rec.batch_start;

--Bug 9336651 starts
 Cursor C_FACEVAL_SIGN is
 SELECT FROM_VALUE
FROM XTR_HEDGE_CRITERIA
WHERE hedge_attribute_id = rec.deal_no
and criteria_code = 'ITEM_SOURCE';
--Bug 9336651 ends

l_buf Varchar2(500);
l_first         BOOLEAN;  -- return TRUE or FALSE to see if it's the first batch
l_hedge_bal   NUMBER;
l_item_total    NUMBER;
retcode		NUMBER;
r_err_log       err_log; -- record type
l_faceval_sign  XTR_HEDGE_STRATEGIES.objective_code%TYPE; -- Bug 9336651

BEGIN
      rec.deal_no 	  := l_tmp.DEAL_NO;
      rec.deal_type 	  := l_tmp.DEAL_TYPE;
      rec.deal_subtype    := l_tmp.DEAL_SUBTYPE;
      rec.product_type    := l_tmp.PRODUCT_TYPE;
      rec.fair_value      := NULL;
      rec.trans_no 	  := l_tmp.TRANSACTION_NO;
      rec.ow_type         := NULL;
      rec.ow_value 	  := NULL;
      rec.year_calc_type  := l_tmp.YEAR_CALC_TYPE;
      rec.year_basis      := l_tmp.YEAR_BASIS;
      rec.discount_yield  := l_tmp.DISCOUNT_YIELD;
      rec.deal_date       := l_tmp.deal_date;
      rec.start_date      := l_tmp.start_date;
      rec.maturity_date   := l_tmp.maturity_date;
      rec.expiry_date     := l_tmp.expiry_date;
      rec.settle_date     := l_tmp.settle_date;
      rec.settle_amount   := l_tmp.settle_amount;
      rec.settle_action   := l_tmp.settle_action;
      rec.premium_action  := l_tmp.premium_action;
      rec.premium_amount  := l_tmp.premium_amount;
      rec.market_data_set := l_tmp.market_data_set;
      rec.pricing_model   := l_tmp.pricing_model;
      rec.brokerage_amount:= l_tmp.brokerage_amount;
      rec.portfolio_code := l_tmp.PORTFOLIO_CODE;
      rec.transaction_rate := l_tmp.transaction_rate;
      rec.currencya      := l_tmp.currencya;
      rec.currencyb      := l_tmp.currencyb;
      rec.effective_date := l_tmp.effective_date;
      rec.contract_code  := l_tmp.contract_code;
      rec.face_value     := l_tmp.face_value;
      rec.fxo_sell_ref_amount := l_tmp.fxo_sell_ref_amount;
      rec.cap_or_floor   := l_tmp.cap_or_floor;
      rec.swap_ref       := l_tmp.swap_ref;
      rec.eligible_date  := l_tmp.eligible_date;
      rec.status_code    := l_tmp.status_code;

/* determine the period_from value for XTR_REVALUATION_DETAILS */
/* If it's first reval for the deal, use begin date. Otherwise */
/* use batch start date which is already defaulted             */
     xtr_first_reval(rec, l_first);
  if l_first = TRUE then
     rec.period_start := l_tmp.eligible_date;
  else
     rec.period_start := rec.batch_start;
  end if;

-- If deal is mature, use effective date, otherwise use batch end date
     if l_tmp.effective_date < rec.revldate then
	rec.period_end := l_tmp.effective_date;
     else
        rec.period_end := rec.revldate;
     end if;

     if rec.deal_type = 'FX' or rec.deal_type = 'HEDGE' then  --bug 4256416
	rec.reval_ccy := rec.sob_ccy;
     elsif rec.deal_type = 'FXO' then
	rec.reval_ccy := l_tmp.premium_ccy;
     else
        rec.reval_ccy    := l_tmp.currencya;
     end if;

     if l_tmp.effective_date > rec.revldate then
        r_rd.effective_days := l_tmp.effective_date - rec.revldate;
	r_rd.transaction_period := l_tmp.effective_date - rec.revldate;
     else
        r_rd.effective_days := 0;
	r_rd.transaction_period := 0;
     end if;

     if rec.deal_type in ('NI', 'ONC') then
	select initial_fair_value
	into rec.init_fv
	from XTR_ROLLOVER_TRANSACTIONS
	where deal_number = rec.deal_no
	and transaction_number = rec.trans_no;
     elsif rec.deal_type = 'HEDGE' then
        rec.init_fv := 0;
     else
        select initial_fair_value
        into rec.init_fv
        from XTR_DEALS
        where deal_no = rec.deal_no;
     end if;

     if rec.deal_type = 'STOCK' then
	rec.quantity := l_tmp.FX_REVAL_PRINCIPAL_BAL;
	rec.remaining_quantity := l_tmp.FXO_SELL_REF_AMOUNT;
     end if;

     if rec.deal_type = 'HEDGE' then
        Open C_HEDGE_BAL;
        Fetch C_HEDGE_BAL into l_hedge_bal;
     --   If C_HEDGE_BAL%FOUND then  -- Hedge has been reclassified
        If l_hedge_bal is NOT NULL then  -- Hedge has been reclassified
           If sign(rec.face_value) = -1 then
              rec.face_value := (-1) * l_hedge_bal;
           else
              rec.face_value := l_hedge_bal;
           end if;
        Else    -- No reclassification. Determine hedge amt based on hedge approach

           if rec.product_type = 'FORECAST' then  -- Bug 9336651 starts
	      Open C_FACEVAL_SIGN;
	      Fetch C_FACEVAL_SIGN into l_faceval_sign;
	      IF l_faceval_sign = 'AP' then
			rec.face_value := (-1) * rec.face_value;
	      END IF;
	      Close C_FACEVAL_SIGN; -- Bug 9336651 Ends

           Else Open C_ITEM_TOTAL;
              Fetch C_ITEM_TOTAL into l_item_total;
              if C_ITEM_TOTAL%FOUND then
                rec.face_value := l_item_total;
              end if;
              Close C_ITEM_TOTAL;
	   end if;
         end if;
	 Close C_HEDGE_BAL;
      end if;

EXCEPTION
    when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_get_deal_value');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
END;
--------------------------------------------------------------------------
/************************************************************/
/* This procedure returns deal fair value and reval rate    */
/* for each deal type                                       */
/************************************************************/
PROCEDURE xtr_revl_get_fairvalue(
         rec IN OUT NOCOPY xtr_revl_rec,
	 fair_value OUT NOCOPY NUMBER,
         retcode  OUT NOCOPY NUMBER) IS
l_buf Varchar2(500);
l_round     NUMBER;
l_put_price NUMBER;
l_call_price NUMBER;
l_spot_rate NUMBER;
l_fra_price NUMBER;
l_sob_curr_rate NUMBER; -- out parameter for FX
l_revl_rate NUMBER;  -- out parameter for NI
l_rec	   xtr_revl_rec;
l_int_sum NUMBER;  -- out parameter for TMM
l_fwd_rate NUMBER;  -- out parameter for TMM
l_clean_price NUMBER;  -- out parameter for BOND
l_stock_price NUMBER;	-- out parameter for STOCK
l_settle_date   DATE;
r_fx_rate xtr_revl_fx_rate; -- record type
r_md_in        xtr_market_data_p.md_from_set_in_rec_type;
r_md_out       xtr_market_data_p.md_from_set_out_rec_type;
l_market_set   VARCHAR2(30);
l_ric_code      XTR_BOND_ISSUES.ric_code%TYPE;
l_dummy		NUMBER;
l_dummy1	NUMBER;
l_knock_type    XTR_DEALS.knock_type%TYPE;
l_knock_date    DATE;
l_strike_price  NUMBER;
l_base_ccy      VARCHAR2(15);
l_contra_ccy    VARCHAR2(15);
l_deno          NUMBER;
l_numer         NUMBER;
gl_end_rate     NUMBER;
l_reverse      BOOLEAN;
l_hedge_flag    VARCHAR2(1):= 'N';
r_err_log err_log; -- record type

begin
   select rounding_factor
   into l_round
   from xtr_master_currencies_v
   where currency = rec.reval_ccy;

   l_market_set  :=  rec.MARKET_DATA_SET;
   xtr_revl_get_mds(l_market_set, rec);

-- for all the deal has overwrite type = FAIR_VALUE should
-- never call this procedure.
if rec.ow_type = 'FAIR_VALUE' then
    raise e_invalid_code;
end if;

/**************   BDO  fair value  *******************/
if rec.deal_type = 'BDO' then
  if rec.effective_date <= rec.revldate and rec.status_code  = 'CURRENT' then  -- unrealized
     fair_value     := 0;
     rec.reval_rate := null;
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_DEAL_EXPIRY');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
  elsif rec.expiry_date <= rec.revldate and rec.status_code = 'EXPIRED' then  -- realized
     if rec.contract_code is not null then
        select RIC_CODE
        into l_ric_code
        from XTR_BOND_ISSUES
        where bond_issue_code = rec.contract_code;
        xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
        C_BOND_IND, rec.expiry_date, null, rec.currencya, NULL,
        NULL, C_INTERPOL_LINER, 'M', rec.batch_id, l_ric_code);
        XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
        rec.reval_rate := r_md_out.p_md_out;
     else
        rec.reval_rate := null;
     end if;
     fair_value := 0;  -- realized
  elsif rec.effective_date <= rec.revldate and rec.status_code = 'EXERCISED' then  -- realized
     if rec.settle_amount is not null then  -- Cash settlement
        select exercise_price
        into rec.reval_rate
	from xtr_deals
        where deal_no = rec.deal_no;

        fair_value := rec.settle_amount;
     else
        select base_rate, capital_price  -- Get exercise price for BDO
        into rec.reval_rate, l_strike_price
        from xtr_deals
        where deal_no = rec.deal_no;

        fair_value := round((rec.face_value * (rec.reval_rate - l_strike_price) /100), l_round);
	if rec.deal_subtype in ('BFLOOR', 'SCAP') then
	  fair_value := fair_value * (-1);
	end if;
    end if;
  else    -- unrealized
     fair_value := null; -- user need to provide  unrealized Fair value
  end if;

/**************   SWPTN  fair value  *******************/
 elsif rec.deal_type = 'SWPTN' then
    if rec.effective_date <= rec.revldate and rec.status_code  = 'CURRENT' then  -- unrealized
        rec.reval_rate := null;
        fair_value := 0;
        set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_DEAL_EXPIRY');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    elsif rec.expiry_date <= rec.revldate and rec.status_code = 'EXPIRED' then  -- realized
        rec.reval_rate := null;
        fair_value := 0;  -- realized
    elsif rec.effective_date <= rec.revldate and rec.status_code = 'EXERCISED' then  -- realized
       if rec.settle_amount is not null then -- Cash settlement
	  select settle_rate
	  into rec.reval_rate
	  from XTR_DEALS
	  where deal_no = rec.deal_no;
       else  -- Create Interest Swap, the reval rate is equal to the interest rate
	 -- on Pay or Rec side of created swap(other side from Swaption 'Action')
          select interest_rate
	  into rec.reval_rate
	  from XTR_DEALS
	  where int_swap_ref = (select swap_ref from XTR_DEALS
				where deal_no = rec.deal_no)
	  and deal_subtype = (select decode(D.coupon_action, 'REC', 'FUND', 'INVEST')
			      from XTR_DEALS D where d.deal_no = rec.deal_no);
       end if;
       xtr_end_fv(rec, fair_value);
    else
        fair_value := null; -- user need to provide  unrealized Fair value
    end if;

/**************   FRA fair value  *******************/
  elsif rec.deal_type = 'FRA' then
    if rec.effective_date <= rec.revldate and rec.status_code = 'CURRENT' then  -- unrealized
       if rec.pricing_model in ('FRA_DISC', 'FRA_YIELD') then
           xtr_get_fv_from_batch(rec, fair_value, l_dummy, l_dummy1, l_revl_rate);
           rec.reval_rate := l_revl_rate;
       else      -- 'FAIR_VALUE' or user provided
          fair_value     := null;
          rec.reval_rate := null;
       end if;
       set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SETTLE_DEAL');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    elsif rec.effective_date <= rec.revldate and rec.status_code = 'SETTLED' then  -- realized
       select settle_rate
       into rec.reval_rate
       from xtr_deals
       where deal_no = rec.deal_no;

       xtr_end_fv(rec, fair_value);   -- realized, fair value = ending fair value
    else    -- unrealized. Using formula
       if rec.pricing_model in ('FRA_DISC', 'FRA_YIELD') then
          if rec.ow_type = 'RATE' then
             l_fra_price := rec.ow_value;
          else
             xtr_revl_getprice_fwd(rec, FALSE, l_fra_price);
          end if;
          xtr_revl_fv_fra(rec, l_fra_price, fair_value);
          rec.reval_rate := l_fra_price;
       else  -- 'FAIR_VALUE' or others
          fair_value     := null;
          rec.reval_rate := null;
       end if;
    end if;

/**************   FX fair value  *******************/
  elsif rec.deal_type = 'FX' then
    if rec.effective_date <= rec.revldate and rec.status_code = 'CURRENT' then
	-- get realized fair value
	xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE, C_SPOT_RATE_IND,
	rec.effective_date, NULL, rec.currencya, rec.currencyb, NULL, NULL, 'M',
	rec.batch_id, NULL);
	XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
        rec.reval_rate := r_md_out.p_md_out;

        xtr_end_fv(rec, fair_value);
    elsif rec.effective_date > rec.revldate and rec.status_code = 'CURRENT' then  -- unrealized
       if rec.pricing_model = 'FX_FORWARD' then
          xtr_revl_getrate_fx(rec, l_hedge_flag, r_fx_rate);
          rec.reval_rate := r_fx_rate.fx_forward_rate;
          xtr_revl_fv_fx(rec, r_fx_rate, l_hedge_flag, fair_value, l_sob_curr_rate);
          rec.reval_fx_fwd_rate := l_sob_curr_rate;
       elsif rec.pricing_model = 'FX_GL' then
          l_base_ccy       :=  rec.currencya;
          l_contra_ccy     :=  rec.currencyb;
          xtr_get_base_contra(l_base_ccy, l_contra_ccy, l_reverse);

          GL_CURRENCY_API.get_triangulation_rate(l_base_ccy, l_contra_ccy,
          rec.revldate, rec.ex_rate_type,l_deno, l_numer, gl_end_rate);
          rec.reval_rate := gl_end_rate;
          r_fx_rate.fx_forward_rate := gl_end_rate;
          xtr_revl_fv_fx(rec, r_fx_rate, l_hedge_flag, fair_value, l_sob_curr_rate);
          rec.reval_fx_fwd_rate := l_sob_curr_rate;
       else
          fair_value     := null;
          rec.reval_rate := null;
       end if;
    end if;

/**************   FXO fair value  *******************/
  elsif rec.deal_type = 'FXO' then
    select knock_type, knock_execute_date
    into l_knock_type, l_knock_date
    from XTR_DEALS
    where deal_no = rec.deal_no;

    if rec.effective_date <= rec.revldate and rec.status_code  = 'CURRENT' then
      -- This deal should be mature, but not settled yet, create unrealized record.
	if rec.pricing_model = 'GARMAN_KOHL' then
           fair_value := 0;
           xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE, C_SPOT_RATE_IND,
           rec.expiry_date, NULL, rec.currencya, rec.currencyb, NULL, NULL, 'M',
           rec.batch_id, NULL);
           XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
           rec.reval_rate := r_md_out.p_md_out;
        else   -- 'FAIR_VALUE' other others
           fair_value     := null;
           rec.reval_rate := null;
        end if;
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_DEAL_EXPIRY');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    elsif rec.effective_date <= rec.revldate and rec.status_code = 'EXPIRED' then  -- realized
        xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE, C_SPOT_RATE_IND,
        rec.expiry_date, NULL, rec.currencya, rec.currencyb, NULL, NULL, 'M',
        rec.batch_id, NULL);
        XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
        rec.reval_rate := r_md_out.p_md_out;
        fair_value := 0;
    elsif rec.effective_date <= rec.revldate and rec.status_code = 'EXERCISED' then  -- realized
	select base_rate
        into rec.reval_rate
	from xtr_deals
	where deal_no = (select fxo_deal_no
			 from xtr_deals
			 where deal_no = rec.deal_no);
        xtr_end_fv(rec, fair_value);
    else     -- calcualte unrealized fair value using formula
       if (l_knock_type = 'I' and l_knock_date is null) or   -- Not yet knock-in. fair value is 0
 	  ((rec.revldate < l_knock_date) and (l_knock_date < rec.effective_date)) then
	  fair_value := 0;
          rec.reval_rate := null;
       else
          if rec.pricing_model = 'GARMAN_KOHL' then
             xtr_revl_getprice_fxo(rec, l_spot_rate, l_put_price, l_call_price);
             xtr_revl_fv_fxo(rec, l_spot_rate, l_put_price, l_call_price,
                             fair_value);
          else
	     fair_value     := null;
             rec.reval_rate := null;
          end if;
       end if;
    end if;

/**************   NI fair value  *******************/
  elsif rec.deal_type = 'NI' then  -- handle reval rate in the cursor level
    if rec.effective_date <= rec.revldate then   -- realized
	xtr_end_fv(rec, fair_value);
    else   -- unrealized
       if rec.pricing_model = 'DISC_METHOD' then
          if rec.ow_type = 'RATE' then
             l_revl_rate := rec.ow_value;
          end if;
          xtr_revl_fv_ni(rec, fair_value, l_revl_rate);
          rec.reval_rate := l_revl_rate;
       else
	  fair_value     := null;
          rec.reval_rate := null;
       end if;
    end if;

/**************   IRO fair value  *******************/
  elsif rec.deal_type = 'IRO' then
    if rec.effective_date <= rec.revldate and rec.status_code = 'CURRENT' then  -- unrealized
       if rec.pricing_model = 'BLACK' then
          fair_value := 0;
       else
          fair_value := null;
       end if;
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SETTLE_DEAL');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    elsif rec.expiry_date <= rec.revldate and rec.status_code = 'EXPIRED' then  -- realized
        rec.reval_rate := rec.transaction_rate;
        fair_value := 0;
    elsif rec.effective_date <= rec.revldate and rec.status_code = 'EXERCISED' then  -- realized
       select settle_rate
       into rec.reval_rate
       from xtr_deals
       where deal_no = rec.deal_no;
       xtr_end_fv(rec, fair_value);   -- realized, fair value = ending fair value
    else    -- unrealized. Using formula
       if rec.pricing_model = 'BLACK' then
          xtr_revl_fv_iro(rec, fair_value);
       else
	  rec.reval_rate := null;
	  fair_value := null;
       end if;
    end if;

/**************   IRS fair value  *******************/
  elsif rec.deal_type = 'IRS' then
    if rec.effective_date <= rec.revldate then  -- realized
       rec.reval_rate := null;
       xtr_end_fv(rec, fair_value);
    else
       if rec.pricing_model in ('DISC_CASHFLOW', 'DISC_CASHSTA') then  -- unrealized,using formula
          xtr_revl_fv_irs(rec, fair_value);
       else
	  rec.reval_rate := null;
	  fair_value     := null;
       end if;
    end if;

/**************   BOND fair value  *******************/
  elsif rec.deal_type = 'BOND' then
     -- reval rate is handled in the procedure
     if rec.ow_type = 'PRICE' then  -- Overwrite rate
        l_clean_price := rec.ow_value;
     else
        l_clean_price := null;
     end if;
     xtr_revl_fv_bond(rec, l_clean_price, fair_value);

/**************   STOCK fair value  *******************/
  elsif rec.deal_type = 'STOCK' then
     -- reval rate is handled in the procedure
     if rec.ow_type = 'PRICE' then  -- Overwrite rate
        l_stock_price := rec.ow_value;
     else
        l_stock_price := null;
     end if;
     xtr_revl_fv_stock(rec, l_stock_price, fair_value);

/**************   ONC, CA, IG fair value  *******************/
  elsif rec.deal_type in ('ONC', 'CA', 'IG') then
    rec.reval_rate := null;
    fair_value := rec.face_value;

/**************   RTMM fair value  *******************/
  elsif rec.deal_type = 'RTMM' then
    rec.reval_rate := null;
    fair_value := null;

/**************   TMM fair value  *******************/
  elsif rec.deal_type = 'TMM' then
    if rec.effective_date <= rec.revldate then  -- realized
       rec.reval_rate := null;
       xtr_end_fv(rec, fair_value);
    else
       if rec.pricing_model in ('DISC_CASHFLOW', 'DISC_CASHSTA') then
          if rec.ow_type = 'RATE' then
             l_fwd_rate := rec.ow_value;
          end if;
          xtr_revl_fv_tmm(rec, fair_value, l_int_sum, l_fwd_rate);
          rec.reval_rate := l_fwd_rate;
       else
	  rec.reval_rate := null;
	  fair_value := null;
       end if;
    end if;
  else
    raise e_invalid_dealtype;
  end if;

  fair_value := round(fair_value, l_round);
  rec.fair_value := fair_value;

EXCEPTION
  when e_invalid_dealtype then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_INVALID_DEAL_TYPE');
      FND_MESSAGE.Set_Token('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_INVALID_DEALTYPE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when e_invalid_transno then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_INVALID_TRANS_NUM');
      FND_MESSAGE.Set_Token('DEAL_NO', rec.deal_no);
      FND_MESSAGE.Set_Token('TRANS_NO', rec.trans_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_INVALID_TRANSNUM');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when e_invalid_price_model then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_INVALID_PRICE_MODEL');
      FND_MESSAGE.Set_Token('PRICE_MODEL', rec.pricing_model);
      FND_MESSAGE.Set_Token('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.Set_Token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_INVALID_PRICEMODEL');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when e_date_order_error then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_DATE_ORDER_ERROR');
      FND_MESSAGE.Set_Token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SPOTDATE_REVALDATE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when e_invalid_code then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_INVALID_CODE');
      FND_MESSAGE.Set_Token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_INTERNAL_ERR');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when XTR_MARKET_DATA_P.e_mdcs_no_data_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_MARKET');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_MARKETDATASET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when XTR_MARKET_DATA_P.e_mdcs_no_curve_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_CURVE');
      FND_MESSAGE.set_token('MARKET', rec.market_data_set);
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_CURVEMARKET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_get_fairvalue');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
end xtr_revl_get_fairvalue;
-----------------------------------------
/************************************************************/
/* This procedure returns unrealized P/L and cummulative pl */
/* value in order to calculate last unrealized P/L          */
/************************************************************/
PROCEDURE xtr_revl_get_unrel_pl(
         rec IN OUT NOCOPY xtr_revl_rec,
         unrel_pl_value OUT NOCOPY NUMBER,
	 cum_pl_value OUT NOCOPY NUMBER,
         retcode  OUT NOCOPY NUMBER) AS
l_buf Varchar2(500);
l_ex_fv      NUMBER;
l_in_pri_adjust NUMBER:= NULL; -- for TMM and RTMM increased principal
l_de_pri_adjust  NUMBER:= NULL; -- for TMM and RTMM decreased principal
l_pri_adjust    NUMBER := NULL;
l_recon		NUMBER := NULL; -- for RTMM reconciation
l_int		NUMBER := NULL;
r_err_log    err_log; -- record type
l_round	     NUMBER;
l_pre_disc_amt NUMBER;
l_ni_disc_amt NUMBER;
l_eff_interest NUMBER;
l_dummy	     NUMBER;
l_dummy1	NUMBER;
l_dummy2	NUMBER;

begin
   select rounding_factor
   into l_round
   from xtr_master_currencies_v
   where currency = rec.reval_ccy;

   xtr_get_fv_from_batch(rec, l_ex_fv, l_dummy, cum_pl_value, l_dummy2);

-- For ONC, CA and IG, we do not need to calculate G/L, but only curency G/L
if rec.deal_type in ('ONC', 'CA', 'IG') then
   unrel_pl_value := 0;
   cum_pl_value   := 0;

elsif rec.deal_type in ('TMM', 'IRS') then
-- For TMM and IRS, we need to take principal adjust(increase or decrease) into
-- consideration when calculating the (un)realized P/L.
  if xtr_get_pre_batchid(rec) = -1 then
    -- this is the first one, no previous batch exists
     select sum(PRINCIPAL_ADJUST)
     into l_in_pri_adjust
     from xtr_rollover_transactions
     where principal_action = 'INCRSE'
       and DEAL_NUMBER = rec.deal_no
       and START_DATE <= rec.revldate
       and start_date <> (select start_date
			  from XTR_DEALS
			  where deal_no = rec.deal_no);

     select sum(PRINCIPAL_ADJUST)
     into l_de_pri_adjust
     from xtr_rollover_transactions
     where principal_action = 'DECRSE'
       and DEAL_NUMBER = rec.deal_no
       and START_DATE <= rec.revldate
       and start_date <> (select maturity_date
			  from XTR_DEALS
			  where deal_no = rec.deal_no);

     l_pri_adjust := nvl(l_in_pri_adjust,0) - nvl(l_de_pri_adjust,0);
  else
     select sum(PRINCIPAL_ADJUST)
     into l_in_pri_adjust
     from xtr_rollover_transactions
     where principal_action = 'INCRSE'
       and DEAL_NUMBER = rec.deal_no
       and START_DATE <= rec.revldate
       and START_DATE >= rec.period_start
       and start_date <> (select start_date
                          from XTR_DEALS
                          where deal_no = rec.deal_no);

     select sum(PRINCIPAL_ADJUST)
     into l_de_pri_adjust
     from xtr_rollover_transactions
     where principal_action = 'DECRSE'
       and DEAL_NUMBER = rec.deal_no
       and START_DATE <= rec.revldate
       and START_DATE >= rec.period_start
       and start_date <> (select maturity_date
                          from XTR_DEALS
                          where deal_no = rec.deal_no);

     l_pri_adjust := nvl(l_in_pri_adjust,0) - nvl(l_de_pri_adjust,0);
  end if;

    if rec.deal_subtype = 'FUND' then
	l_pri_adjust := l_pri_adjust * (-1);
    end if;
    xtr_get_fv_from_batch(rec, l_ex_fv, l_dummy, l_dummy1, l_dummy2);
    if rec.deal_type = 'TMM' or (rec.deal_type = 'IRS' and rec.discount_yield = 'Y') then
       unrel_pl_value := round((rec.fair_value - l_pri_adjust - l_ex_fv), l_round);
    else
       unrel_pl_value := round((rec.fair_value - l_ex_fv), l_round);
    end if;
    cum_pl_value := cum_pl_value + unrel_pl_value;

-- For RTMM, need to consider the principal adjust and repayment from bank reconcilation.
elsif rec.deal_type = 'RTMM' then
  if xtr_get_pre_batchid(rec) = -1 then
    -- this is the first one, no previous batch exists
     select sum(PRINCIPAL_ADJUST)
     into l_in_pri_adjust
     from xtr_rollover_transactions
     where principal_action = 'INCRSE'
       and DEAL_NUMBER = rec.deal_no
       and START_DATE <= rec.revldate
       and start_date <> (select start_date
                          from XTR_DEALS
                          where deal_no = rec.deal_no);

     select sum(PRINCIPAL_ADJUST)
     into l_de_pri_adjust
     from xtr_rollover_transactions
     where principal_action = 'DECRSE'
       and DEAL_NUMBER = rec.deal_no
       and START_DATE <= rec.revldate
       and start_date <> (select maturity_date
                          from XTR_DEALS
                          where deal_no = rec.deal_no);

     select sum(pi_amount_received)
     into l_recon
     from xtr_rollover_transactions
     where deal_number = rec.deal_no
     and nvl(settle_date,maturity_date) <= rec.revldate;

     select sum(interest)
     into l_int
     from xtr_rollover_transactions
     where deal_number = rec.deal_no
     and nvl(settle_date,maturity_date) <= rec.revldate
     and nvl(pi_amount_received, 0) <> 0;

     l_pri_adjust := nvl(l_in_pri_adjust,0) - nvl(l_de_pri_adjust,0) - nvl(l_recon, 0) + nvl(l_int,0);
  else
     select sum(PRINCIPAL_ADJUST)
     into l_in_pri_adjust
     from xtr_rollover_transactions
     where principal_action = 'INCRSE'
       and DEAL_NUMBER = rec.deal_no
       and START_DATE <= rec.revldate
       and START_DATE >= rec.period_start
       and start_date <> (select start_date
                          from XTR_DEALS
                          where deal_no = rec.deal_no);
     select sum(PRINCIPAL_ADJUST)
     into l_de_pri_adjust
     from xtr_rollover_transactions
     where principal_action = 'DECRSE'
       and DEAL_NUMBER = rec.deal_no
       and START_DATE <= rec.revldate
       and START_DATE >= rec.period_start
       and start_date <> (select maturity_date
                          from XTR_DEALS
                          where deal_no = rec.deal_no);

     select sum(pi_amount_received)
     into l_recon
     from xtr_rollover_transactions
     where deal_number = rec.deal_no
     and nvl(settle_date,maturity_date) <= rec.revldate
     and nvl(settle_date,maturity_date) >= rec.period_start;

     select sum(interest)
     into l_int
     from xtr_rollover_transactions
     where deal_number = rec.deal_no
     and nvl(settle_date,maturity_date) <= rec.revldate
     and nvl(settle_date,maturity_date) >= rec.period_start
     and nvl(pi_amount_received, 0) <> 0;

     l_pri_adjust := nvl(l_in_pri_adjust,0) - nvl(l_de_pri_adjust,0) - nvl(l_recon, 0) + nvl(l_int,0);
  end if;

    if rec.deal_subtype = 'FUND' then
        l_pri_adjust := l_pri_adjust * (-1);
    end if;
    xtr_get_fv_from_batch(rec, l_ex_fv, l_dummy, l_dummy1, l_dummy2);
    unrel_pl_value := round((rec.fair_value - l_pri_adjust - l_ex_fv), l_round);
    cum_pl_value := cum_pl_value + unrel_pl_value;

--For NI, the unrealized G/L = current FV - pre FV -(+) Effective interest
elsif rec.deal_type = 'NI' then
   xtr_get_fv_from_batch(rec, l_ex_fv, l_pre_disc_amt, l_dummy1, l_dummy2);
   xtr_ni_eff_interest(rec, l_pre_disc_amt, l_ni_disc_amt, l_eff_interest);
   rec.ni_disc_amount := l_ni_disc_amt;
   if rec.deal_subtype = 'BUY' then
      unrel_pl_value := rec.fair_value - l_ex_fv - l_eff_interest;
   elsif rec.deal_subtype = 'ISSUE' then
      unrel_pl_value := rec.fair_value - l_ex_fv + l_eff_interest;
   end if;
   cum_pl_value := cum_pl_value + unrel_pl_value;

else
-- for most of the deal types, unrealized P/L is always the
-- current fair value - previous fair value
   xtr_get_fv_from_batch(rec, l_ex_fv, l_dummy, l_dummy1, l_dummy2);
   unrel_pl_value := round((rec.fair_value - l_ex_fv), l_round);
   cum_pl_value := cum_pl_value + unrel_pl_value;
end if;

EXCEPTION
  when e_invalid_dealtype then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_INVALID_DEAL_TYPE');
      FND_MESSAGE.set_token('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_INVALID_DEALTYPE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when e_invalid_deal_subtype then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_INVALID_DEAL_SUBTYPE');
      FND_MESSAGE.set_token('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.set_token('DEAL_SUBTYPE', rec.deal_subtype);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_INVALID_DEALSUBTYPE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('DEAL_SUBTYPE', rec.deal_subtype);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_get_unrel_pl');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
end xtr_revl_get_unrel_pl;
--------------------------------------------------------------
/*************************************************************************************/
/* This procedure gets all rates information for XTR_REVALUATION_DETAILS and         */
/* XTR_DEALS                                                                         */
/* For Revaluation table: exchange_rate_one = reval_ccy/SOB ccy on revaluation date  */
/* except for FX, exchange_rate_one = base_ccy/SOB ccy on revaluation date           */
/* exchange_rate_two for FX = contra_ccy/SOB ccy on revaluation date                 */
/* ctr_curr_sob_curr_fwd_rate = contra_ccy/SOB FX forward rate                       */
/* For Deals table, exchange_rate_one and exchange_rate_two will be the same currency*/
/* consideration except the date will be the deal_date/start_date depending on       */
/* company parameter settting.                                                       */
/*************************************************************************************/
PROCEDURE xtr_revl_exchange_rate(
                        rec IN OUT NOCOPY xtr_revl_rec,
                        retcode OUT NOCOPY NUMBER)IS
l_accounting    VARCHAR2(30);
l_base_ccy	VARCHAR2(15);
l_contra_ccy	VARCHAR2(15);
l_deno		NUMBER;
l_numer         NUMBER;
l_dummy		BOOLEAN;
r_err_log       err_log; -- record type
l_buf Varchar2(500);
Begin

  select PARAMETER_VALUE_CODE into l_accounting
  from xtr_company_parameters
  where COMPANY_CODE = rec.company_code and
      PARAMETER_CODE = C_DEAL_SETTLE_ACCOUNTING;

  If rec.deal_type = 'FX' then
  -- Get base and contra currency for FX.
     l_base_ccy    := rec.currencya;
     l_contra_ccy  := rec.currencyb;
     xtr_get_base_contra(l_base_ccy, l_contra_ccy, l_dummy);
  End If;

  rec.deal_ex_rate_one :=NULL;
  rec.deal_ex_rate_two :=NULL;
  rec.reval_ex_rate_one :=NULL;
  rec.reval_ex_rate_two :=NULL;

-- Get XTR_DEALS table exchange_rate_one and exchange_rate_two
  If rec.deal_type = 'FX' then
     GL_CURRENCY_API.get_triangulation_rate
    	        (l_base_ccy, rec.sob_ccy, rec.eligible_date, rec.ex_rate_type,
	         l_deno, l_numer, rec.deal_ex_rate_one);
     GL_CURRENCY_API.get_triangulation_rate
		(l_contra_ccy, rec.sob_ccy, rec.eligible_date, rec.ex_rate_type,
		l_deno, l_numer, rec.deal_ex_rate_two);

  Else  -- for other deal types, only exchange_rate_one is used
     GL_CURRENCY_API.get_triangulation_rate
		(rec.reval_ccy, rec.sob_ccy, rec.eligible_date, rec.ex_rate_type,
		l_deno, l_numer, rec.deal_ex_rate_one);
     rec.deal_ex_rate_two := null;
  End If;

  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_exchange_rate: ' || 'deal_date exchange rate');
     xtr_risk_debug_pkg.dlog('xtr_revl_exchange_rate: ' || 'rec.deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_exchange_rate: ' || 'reval ccy' , rec.reval_ccy);
     xtr_risk_debug_pkg.dlog('xtr_revl_exchange_rate: ' || 'sob ccy' , rec.sob_ccy);
     xtr_risk_debug_pkg.dlog('xtr_revl_exchange_rate: ' || 'rec.eligible_date' , rec.eligible_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_exchange_rate: ' || 'ex rate type' , rec.ex_rate_type);
     xtr_risk_debug_pkg.dlog('xtr_revl_exchange_rate: ' || 'ex rate ' , rec.deal_ex_rate_one);
     xtr_risk_debug_pkg.dpop('xtr_revl_exchange_rate: ' || 'deal_date exchange rate');
  END IF;

-- Get XTR_REVALUATION_DETAILS table exchange_rate_one, exchange_rate_two, and Fx forwad rate
  If rec.effective_date <= rec.revldate then  -- deal is realized. Used maturity date rate
     If rec.deal_type = 'FX' then
        GL_CURRENCY_API.get_triangulation_rate
		(l_base_ccy, rec.sob_ccy, rec.effective_date, rec.ex_rate_type,
		l_deno, l_numer, rec.reval_ex_rate_one);
        GL_CURRENCY_API.get_triangulation_rate
		(l_contra_ccy, rec.sob_ccy, rec.effective_date, rec.ex_rate_type,
                l_deno, l_numer, rec.reval_ex_rate_two);
     Else
        GL_CURRENCY_API.get_triangulation_rate
		(rec.reval_ccy, rec.sob_ccy, rec.effective_date, rec.ex_rate_type,
                l_deno, l_numer, rec.reval_ex_rate_one);
        rec.reval_ex_rate_two := null;
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_exchange_rate: ' || 'END_EX_RATE');
     xtr_risk_debug_pkg.dlog('xtr_revl_exchange_rate: ' || 'rec.deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_exchange_rate: ' || 'reval ccy' , rec.reval_ccy);
     xtr_risk_debug_pkg.dlog('xtr_revl_exchange_rate: ' || 'sob ccy' , rec.sob_ccy);
     xtr_risk_debug_pkg.dlog('xtr_revl_exchange_rate: ' || 'rec.effective_date' , rec.effective_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_exchange_rate: ' || 'rec.revldate' , rec.revldate);
     xtr_risk_debug_pkg.dlog('xtr_revl_exchange_rate: ' || 'ex rate type' , rec.ex_rate_type);
     xtr_risk_debug_pkg.dlog('xtr_revl_exchange_rate: ' || 'end rate ' , rec.reval_ex_rate_one);
     xtr_risk_debug_pkg.dpop('xtr_revl_exchange_rate: ' || 'END_EX_RATE');
  END IF;

     End If;
  Else  -- deal is unrealized. Use reval date's G/L rate
     If rec.deal_type = 'FX' then
       GL_CURRENCY_API.get_triangulation_rate
		(l_base_ccy, rec.sob_ccy, rec.revldate, rec.ex_rate_type,
                l_deno, l_numer, rec.reval_ex_rate_one);
       GL_CURRENCY_API.get_triangulation_rate
		(l_contra_ccy, rec.sob_ccy, rec.revldate, rec.ex_rate_type,
                l_deno, l_numer, rec.reval_ex_rate_two);
     Else
       GL_CURRENCY_API.get_triangulation_rate
		(rec.reval_ccy, rec.sob_ccy, rec.revldate, rec.ex_rate_type,
                l_deno, l_numer, rec.reval_ex_rate_one);
        rec.reval_ex_rate_two := null;
     End If;
  End If;

  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_exchange_rate: ' || 'reval_date exchange rate');
     xtr_risk_debug_pkg.dlog('xtr_revl_exchange_rate: ' || 'rec.deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_exchange_rate: ' || 'reval ccy' , rec.reval_ccy);
     xtr_risk_debug_pkg.dlog('xtr_revl_exchange_rate: ' || 'sob ccy' , rec.sob_ccy);
     xtr_risk_debug_pkg.dlog('xtr_revl_exchange_rate: ' || 'revaldate' , rec.revldate);
     xtr_risk_debug_pkg.dlog('xtr_revl_exchange_rate: ' || 'ex rate type' , rec.ex_rate_type);
     xtr_risk_debug_pkg.dlog('xtr_revl_exchange_rate: ' || 'ex rate ' , rec.reval_ex_rate_one);
     xtr_risk_debug_pkg.dpop('xtr_revl_exchange_rate: ' || 'reval_date exchange rate');
  END IF;

EXCEPTION
  when GL_CURRENCY_API.no_rate then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_GL_RATE');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_RATE_CURRENCY_GL');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when GL_CURRENCY_API.invalid_currency then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_INVALID_CURRENCY');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      FND_MESSAGE.set_token('CURRENCY', rec.currencya);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_INVALID_CURRENCY_TYPE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_exchange_rate');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
End xtr_revl_exchange_rate;
-----------------------------------------------------------------------------------
/*************************************************************************************/
/* The procedure should return following values in reval table    		     */
/* 1. SOB fair value amount (X_SOB_FAIR_VALUE_AMOUNT)- fv_sob_amt   		     */
/* 2. SOB Fair value g/l (SOB_FV_GAIN_LOSS_AMOUNT)- rel_sob_gl, unrel_sob_gl         */
/* 3. Currency g/l amount (CURR_GAIN_LOSS_AMOUNT) - currency_gl    		     */
/* ***********************************************************************************/
PROCEDURE xtr_revl_get_curr_gl(
                        rec IN OUT NOCOPY xtr_revl_rec,
                        unrel_pl_value IN NUMBER,
                        rel_pl_value IN NUMBER,
                        fv_sob_amt OUT NOCOPY NUMBER,
                        rel_sob_gl OUT NOCOPY NUMBER,
                        unrel_sob_gl OUT NOCOPY NUMBER,
                        currency_gl OUT NOCOPY NUMBER) IS

r_err_log       err_log; -- record type
l_pre_batch	NUMBER;
l_pre_gl_rate   NUMBER; -- The previous Batch  G/L rate
l_pre_sob_fv	NUMBER; -- The previous Batch  SOB fair value
l_init_fv       NUMBER;
l_deal_rate1    NUMBER;
l_reval_rate1   NUMBER;
l_rate0         NUMBER;
l_rate1         NUMBER;
l_date0       DATE;  -- reference date for l_r0
l_date1       DATE;  -- reference date for l_r1
l_round		NUMBER;
l_first		BOOLEAN; -- return TURE if it's the first reval for the deal
l_begin_fv      VARCHAR2(30);  -- END or BEGIN to calucation different currency G/L
l_fair_value    NUMBER; -- fair value used to calculation curency G/L.
l_dummy		NUMBER;
l_dummy1	NUMBER;
l_dummy2	NUMBER;
retcode		NUMBER;
l_buf           Varchar2(500);
Begin
   select PARAMETER_VALUE_CODE into l_begin_fv
   from xtr_company_parameters
   where COMPANY_CODE = rec.company_code and
       PARAMETER_CODE = C_BEGIN_FV;

   select rounding_factor
   into l_round
   from xtr_master_currencies_v
   where currency = rec.sob_ccy;

   if l_begin_fv = 'BEGIN' then  -- currency G/L = last batch's fair value * (rate1 - rate0)
      xtr_get_fv_from_batch(rec, l_fair_value, l_dummy, l_dummy1, l_dummy2);
   else  -- 'END', currency G/L = current fair value * (rate1 - rate0)
      l_fair_value :=  rec.fair_value;
   end if;

   l_rate1  := rec.reval_ex_rate_one;
  -- Calculate realized SOB currency G/L info and obtain reval rate info
  If rel_pl_value is not null then
     l_rate0  := rec.deal_ex_rate_one;

     -- For FRA, since it's initial fair value is 0, we provide estimate number for user
     -- by using ending fair value.
     if rec.deal_type = 'FRA' then
        currency_gl := round((rec.fair_value * (l_rate1 - l_rate0)), l_round);
     else
        currency_gl:= round((rec.init_fv * (l_rate1 - l_rate0)), l_round);
     end if;
     fv_sob_amt := round((rec.fair_value * l_rate1), l_round);
     rel_sob_gl := round((rel_pl_value   * l_rate1), l_round);
  End if;

  If unrel_pl_value is not null then
     -- calculate unrealized SOB currency G/L info and obtain reval rate info
     xtr_first_reval(rec, l_first);
     if l_first = FALSE then
-- not the first reval batch. compare with last batch
    	l_pre_batch := xtr_get_pre_batchid(rec);
        select exchange_rate_one, sob_fair_value_amount
        into  l_pre_gl_rate, l_pre_sob_fv
        from XTR_REVALUATION_DETAILS
        where deal_no = rec.deal_no
        and transaction_no = rec.trans_no
	and nvl(realized_flag, 'N') = 'N'
        and batch_id = l_pre_batch;

        l_rate0 := l_pre_gl_rate;
     else  -- first time reval, use exchange rate on deal date
	l_rate0 := rec.deal_ex_rate_one;
     end if;

	fv_sob_amt := round((rec.fair_value * l_rate1), l_round);
	currency_gl:= round((l_fair_value * (l_rate1 - l_rate0)), l_round);
	unrel_sob_gl:= round((unrel_pl_value * l_rate1), l_round);
   End If;

EXCEPTION
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_get_curr_gl');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
end xtr_revl_get_curr_gl;
-------------------------------------------------------------------
/*******************************************************************/
/* This procedure is to calculate currency G/L for TMM.            */
/*******************************************************************/
PROCEDURE xtr_revl_tmm_curr_gl(
                        rec IN OUT NOCOPY xtr_revl_rec,
                        rel_currency_gl OUT NOCOPY NUMBER,
			unrel_currency_gl OUT NOCOPY NUMBER)IS
l_buf Varchar2(500);
l_batch_end_rate  NUMBER;
l_trans_no0     NUMBER;
l_trans_no1     NUMBER;
l_start_date0   DATE;
l_start_date1   DATE;
l_principal0    NUMBER;
l_principal1    NUMBER;
l_balance_out0	NUMBER;
l_balance_out1  NUMBER;
l_prin_action0  VARCHAR2(7);
l_prin_action1  VARCHAR2(7);
l_first_batch0  NUMBER;
l_avg_rate      NUMBER;
l_trans_ex_rate0   NUMBER;
l_trans_ex_rate1   NUMBER;
l_unrel_start_rate NUMBER;
l_unrel_end_rate   NUMBER;
l_unrel_curr_gl	   NUMBER;
l_rel_start_rate   NUMBER;
l_rel_end_rate     NUMBER;
l_rel_curr_gl      NUMBER;
l_sum_rel_curr_gl   NUMBER:= null;
l_sum_unrel_curr_gl NUMBER:= null;
l_deno		NUMBER;
l_numer		NUMBER;
l_pre_batch_id	NUMBER;
l_first_batch_id NUMBER := null;
l_last_batch_id NUMBER := null;
l_pre_avg_rate	NUMBER;
l_pre_balance_out NUMBER;
l_round		NUMBER;
l_first		BOOLEAN;
r_err_log       err_log; -- record type
retcode		NUMBER;

Cursor C_PAIR_PRINCIPAL is
 Select a.start_date, a.transaction_number, a.principal_adjust,
	a.principal_action, a.balance_out, a.first_reval_batch_id,
        b.start_date, b.transaction_number, b.principal_adjust,
        b.principal_action, b.balance_out
from xtr_rollover_transactions a,
     xtr_rollover_transactions b
where a.deal_number = rec.deal_no
  and a.deal_number = b.deal_number
  and a.start_date < b.start_date
  and b.start_date <= rec.revldate
  and nvl(a.principal_adjust, 0) <> 0
  and nvl(b.principal_adjust, 0) <> 0
  and a.start_date =
      (select max(c.start_date)
       from xtr_rollover_transactions c
       where c.deal_number = a.deal_number
         and nvl(c.principal_adjust,0) <> 0
         and c.start_date < b.start_date)
  and a.last_reval_batch_id is null
  and b.last_reval_batch_id is null
  order by a.start_date;

Cursor C_LAST_PRIN_ADJ is
 select start_date, transaction_number, principal_adjust, principal_action,
        balance_out, first_reval_batch_id
 from XTR_ROLLOVER_TRANSACTIONS
 where deal_number = rec.deal_no
   and nvl(principal_adjust, 0) <> 0
   and start_date  <= rec.revldate
 order by start_date desc, transaction_number desc;


Begin
    select rounding_factor
    into l_round
    from xtr_master_currencies_v
    where currency = rec.sob_ccy;

 if rec.reval_ccy = rec.sob_ccy then  -- No curency G/L calculation needed
    rel_currency_gl := 0;
    unrel_currency_gl := 0;
    return;
 end if;

-- Obtain GL exchange rate on the batch end date
 GL_CURRENCY_API.get_triangulation_rate (rec.reval_ccy, rec.sob_ccy,
    rec.revldate, rec.ex_rate_type, l_deno, l_numer, l_batch_end_rate);

-- Calculate pair
 open C_PAIR_PRINCIPAL;
 fetch C_PAIR_PRINCIPAL into l_start_date0, l_trans_no0,
       l_principal0, l_prin_action0, l_balance_out0, l_first_batch0,
       l_start_date1, l_trans_no1, l_principal1, l_prin_action1, l_balance_out1;

 while C_PAIR_PRINCIPAL%FOUND loop
    -- Determine the 'Previous exchange rate'
    if l_first_batch0 is null then  -- transaction been first revaled
	GL_CURRENCY_API.get_triangulation_rate (rec.reval_ccy, rec.sob_ccy,
	l_start_date0, rec.ex_rate_type, l_deno, l_numer, l_trans_ex_rate0);

	l_unrel_start_rate := l_trans_ex_rate0;
	l_first_batch_id   := rec.batch_id;
    else
       l_pre_batch_id := xtr_get_pre_batchid(rec);
        select exchange_rate_one
	into l_unrel_start_rate
	from XTR_REVALUATION_DETAILS
	where batch_id = l_pre_batch_id
	and deal_no = rec.deal_no
        and nvl(realized_flag, 'N') = 'N';
    end if;

    -- Determine the 'Ending exchange rate'
    GL_CURRENCY_API.get_triangulation_rate(rec.reval_ccy, rec.sob_ccy,
       l_start_date1, rec.ex_rate_type, l_deno, l_numer, l_trans_ex_rate1);
    l_unrel_end_rate := l_trans_ex_rate1;

    -- Calculate UCGL  = balance_out * (ending ex rate - start ex rate)
    l_unrel_curr_gl := l_balance_out0 * (l_unrel_end_rate - l_unrel_start_rate);
    if rec.deal_subtype = 'FUND' then
       l_unrel_curr_gl := l_unrel_curr_gl * (-1);
    end if;
    l_sum_unrel_curr_gl := round((nvl(l_sum_unrel_curr_gl,0) + nvl(l_unrel_curr_gl,0)), l_round);

    l_last_batch_id := rec.batch_id;

    if l_first_batch0 is null then
    -- This transaction is the first time reval. For principal action = 'INCRSE',
    -- we need to calculate new average rate. For 'DECRSE', we need to calculate
    -- RCGL
       xtr_first_reval(rec, l_first);
       if l_first = TRUE and l_trans_no0 = 1  then  -- first time reval for the whole deal
          l_pre_avg_rate := l_trans_ex_rate0;
          l_pre_balance_out := l_balance_out0;
       else
          select average_exchange_rate -- Get previous transaction's average rate
          into l_pre_avg_rate
          from xtr_rollover_transactions
          where deal_number = rec.deal_no
          and average_exchange_rate is NOT NULL   -- bug 4598526
          and (start_date, maturity_date) = (select max(start_date),max(maturity_date) -- bug 5598286
                           from xtr_rollover_transactions
                           where deal_number = rec.deal_no
                           and nvl(principal_adjust, 0) <> 0
                           and start_date < l_start_date0
                           and average_exchange_rate is NOT NULL);

          select balance_out  -- Get previous transaction's outstandin balance
          into l_pre_balance_out
          from xtr_rollover_transactions
          where deal_number = rec.deal_no
          and  nvl(principal_adjust, 0) <> 0     -- bug 4598526
          and (start_date,maturity_date) = (select max(start_date),max(maturity_date) -- bug 5598286
                           from xtr_rollover_transactions
                           where deal_number = rec.deal_no
                           and nvl(principal_adjust, 0) <> 0
                           and start_date < l_start_date0);
       end if;

       if l_prin_action0 = 'INCRSE' then
	  if l_trans_no0 = 1 then  -- the first transaction of the deal
	     l_avg_rate := l_trans_ex_rate0;
	  else
	     l_avg_rate := (l_principal0 * l_trans_ex_rate0 +
			    l_pre_balance_out * l_pre_avg_rate) /l_balance_out0;

          end if;
       elsif l_prin_action0 = 'DECRSE' then  -- principal action is 'DECRSE'
	  l_rel_curr_gl := l_principal0 * (l_trans_ex_rate0 - l_pre_avg_rate);
          if rec.deal_subtype = 'FUND' then
	     l_rel_curr_gl := l_rel_curr_gl * (-1);
          end if;
    	  l_sum_rel_curr_gl := round((nvl(l_sum_rel_curr_gl, 0) + nvl(l_rel_curr_gl, 0)),l_round);
       end if;
    end if;

    Update XTR_ROLLOVER_TRANSACTIONS
    set first_reval_batch_id = nvl(first_reval_batch_id, l_first_batch_id),
        last_reval_batch_id = nvl(last_reval_batch_id, l_last_batch_id),
	currency_exchange_rate = nvl(currency_exchange_rate, l_trans_ex_rate0),
        average_exchange_rate  = nvl(average_exchange_rate, l_avg_rate)
    where deal_number = rec.deal_no
      and transaction_number = l_trans_no0;

    fetch C_PAIR_PRINCIPAL into l_start_date0, l_trans_no0,
    l_principal0, l_prin_action0, l_balance_out0, l_first_batch0,
    l_start_date1, l_trans_no1, l_principal1, l_prin_action1, l_balance_out1;
 end loop;
 close C_PAIR_PRINCIPAL;

-- Calculate the last transaction of the batch. This transaction will be still
-- eligible for next batch revaluation
 open C_LAST_PRIN_ADJ;
 fetch C_LAST_PRIN_ADJ into l_start_date0, l_trans_no0,
       l_principal0, l_prin_action0, l_balance_out0, l_first_batch0;
 if C_LAST_PRIN_ADJ%FOUND then
        -- Determine the 'Previous exchange rate'
    if l_first_batch0 is null then  -- transaction been first revaled
        GL_CURRENCY_API.get_triangulation_rate (rec.reval_ccy, rec.sob_ccy,
        l_start_date0, rec.ex_rate_type, l_deno, l_numer, l_trans_ex_rate0);

        l_unrel_start_rate := l_trans_ex_rate0;
        l_first_batch_id   := rec.batch_id;
    else
       l_pre_batch_id := xtr_get_pre_batchid(rec);
        select exchange_rate_one
        into l_unrel_start_rate
        from XTR_REVALUATION_DETAILS
        where batch_id = l_pre_batch_id
        and deal_no = rec.deal_no
   	and nvl(realized_flag, 'N') = 'N';
    end if;

    -- Determine the 'Ending exchange rate'
    l_unrel_end_rate := l_batch_end_rate;

    -- Calculate UCGL  = balance_out * (ending ex rate - start ex rate)
    l_unrel_curr_gl := l_balance_out0 * (l_unrel_end_rate - l_unrel_start_rate);
    if rec.deal_subtype = 'FUND' then
	l_unrel_curr_gl := l_unrel_curr_gl * (-1);
    end if;
    l_sum_unrel_curr_gl := round((nvl(l_sum_unrel_curr_gl,0) + nvl(l_unrel_curr_gl,0)), l_round);

    if l_first_batch0 is null then
    -- This transaction is the first time reval. For principal action = 'INCRSE',
    -- we need to calculate new average rate. For 'DECRSE', we need to calculate
    -- RCGL
       if l_trans_no0 <> 1 then
          select average_exchange_rate -- Get previous transaction's average rate
          into l_pre_avg_rate
          from xtr_rollover_transactions
          where deal_number = rec.deal_no
          and average_exchange_rate is NOT NULL      -- bug 4598526
          and (start_date, maturity_date) = (select max(start_date), max(maturity_date) -- bug 5598286
                           from xtr_rollover_transactions
                           where deal_number = rec.deal_no
                           and nvl(principal_adjust, 0) <> 0
                           and start_date < l_start_date0
                           and average_exchange_rate is NOT NULL);

          select balance_out  -- Get previous transaction's outstandin balance
          into l_pre_balance_out
          from xtr_rollover_transactions
          where deal_number = rec.deal_no
          and nvl(principal_adjust, 0) <> 0      -- bug 4598526
          and (start_date, maturity_date) = (select max(start_date),max(maturity_date) -- bug 5598286
                           from xtr_rollover_transactions
                           where deal_number = rec.deal_no
                           and nvl(principal_adjust, 0) <> 0
                           and start_date < l_start_date0);
       end if;

       if l_prin_action0 = 'INCRSE' then
          if l_trans_no0 = 1 then  -- the first transaction of the deal
             l_avg_rate := l_trans_ex_rate0;
          else
             l_avg_rate := (l_principal0 * l_trans_ex_rate0 +
                            l_pre_balance_out * l_pre_avg_rate) /l_balance_out0;

          end if;
       elsif l_prin_action0 = 'DECRSE' then  -- principal action is 'DECRSE'
          l_rel_curr_gl := l_principal0 * (l_trans_ex_rate0 - l_pre_avg_rate);
          if rec.deal_subtype = 'FUND' then
	     l_rel_curr_gl := l_rel_curr_gl * (-1);
	  end if;
          l_sum_rel_curr_gl := round((nvl(l_sum_rel_curr_gl,0) + nvl(l_rel_curr_gl,0)), l_round);
       end if;
    end if;
    rel_currency_gl := l_sum_rel_curr_gl;
    unrel_currency_gl := l_sum_unrel_curr_gl;

    Update XTR_ROLLOVER_TRANSACTIONS
    set first_reval_batch_id = nvl(first_reval_batch_id, l_first_batch_id),
        currency_exchange_rate = nvl(currency_exchange_rate, l_trans_ex_rate0),
        average_exchange_rate  = nvl(average_exchange_rate, l_avg_rate)
    where deal_number = rec.deal_no
      and transaction_number = l_trans_no0;
 end if;
 close C_LAST_PRIN_ADJ;

EXCEPTION
  when GL_CURRENCY_API.no_rate then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_GL_RATE');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_RATE_CURRENCY_GL');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when GL_CURRENCY_API.invalid_currency then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_INVALID_CURRENCY');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      FND_MESSAGE.set_token('CURRENCY', rec.currencya);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_INVALID_CURRENCY_TYPE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_tmm_curr_gl');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
End;
--------------------------------------------------------
/*******************************************************************/
/* This procedure pass one account no for each company and calculate */
/* (un)realized currency G/L and average exchange rate for the row */
/* in xtr_bank_balances for deal type CA                           */
/*******************************************************************/
PROCEDURE xtr_revl_ca_curr_gl(
			rec IN OUT NOCOPY xtr_revl_rec,
			retcode OUT NOCOPY NUMBER) IS
l_buf Varchar2(500);
l_bal_date0	DATE;
l_bal_date1	DATE;
l_bal_amt0 	NUMBER;
l_bal_amt1      NUMBER;
l_ex_rate0	NUMBER;
l_ex_rate1	NUMBER;
l_avg_rate	NUMBER;
l_avg_rate0	NUMBER;
l_avg_rate1	NUMBER;
l_last_bal_date DATE;
l_last_bal_amt  NUMBER;
l_last_avg_rate NUMBER;
l_gl_rate	NUMBER;
l_currency_gl   NUMBER;
r_err_log       err_log; -- record type
l_bed_rate	NUMBER; --the GL exchange rate on the batch end date
l_deno		NUMBER;
l_numer		NUMBER;
l_first_batch_id NUMBER;
l_last_batch_id  NUMBER;
l_last_unrel_date DATE;
l_unrel_start_rate NUMBER;
l_unrel_end_rate   NUMBER;
l_increase      NUMBER;
l_decrease	NUMBER;
l_pre_balance	NUMBER;
l_unrel_cur_gl  NUMBER;
l_rel_cur_gl    NUMBER;
l_pre_batch_id  NUMBER;
l_rc            NUMBER:= 0;
r_rd XTR_REVALUATION_DETAILS%rowtype;
l_trans_rate0 NUMBER;
l_trans_rate1 NUMBER;
l_round		NUMBER;

--------------------------------------------------------------------------------------
--Select pair of balances row to calculate UCGL and RCGL (not include last single row)
--------------------------------------------------------------------------------------
Cursor C_PAIR_BALANCE is
  SELECT a.balance_date, nvl(a.balance_cflow,0), a.first_batch_id,
         a.interest_rate,
         b.balance_date, nvl(b.balance_cflow,0), b.interest_rate
   FROM   xtr_bank_balances a,
          xtr_bank_balances b
  Where  a.company_code = rec.company_code
    and  a.company_code = b.company_code
    and  a.account_number = rec.account_no
    and  a.account_number = b.account_number
    and  a.balance_date < b.balance_date
    and  b.balance_date <= rec.revldate
    and  a.balance_date =
  	(SELECT max(c.balance_date)
         FROM   xtr_bank_balances c
   	 where  c.company_code   = a.company_code
   	  AND   c.account_number = a.account_number
          AND   c.balance_date   < b.balance_date)
    and a.last_batch_id is null
    and b.last_batch_id is null
  ORDER by 1;

------------------------------------------------------------
-- select last eligible row of the account to calculate UCGL
------------------------------------------------------------
Cursor C_LAST_BALANCE is
  Select balance_date, nvl(balance_cflow,0), first_batch_id, interest_rate
  From XTR_BANK_BALANCES
  Where company_code = rec.company_code
  and account_number = rec.account_no
  and balance_date =
      (select max(effective_date)
       from XTR_CA_ELIGIBLE_DEALS_V
       where company_code = rec.company_code
       and account_no = rec.account_no
       and effective_date <= rec.revldate)
  and last_batch_id is null;


------------- AW 25/10/01 ------------------------
-- Select the last balance's average exchange rate
--------------------------------------------------
CURSOR c_last_ca_avg_rate IS
SELECT average_exchange_rate
FROM   xtr_bank_balances
WHERE  company_code   = rec.company_code
AND    account_number = rec.account_no
AND    first_batch_id = l_pre_batch_id
ORDER BY balance_date desc;

Begin
retcode := 1;
    select rounding_factor
    into l_round
    from xtr_master_currencies_v
    where currency = rec.sob_ccy;

 ----------------------------------------------------------------------
 -- Obtain GL exchange rate on the batch end date
 ----------------------------------------------------------------------
 GL_CURRENCY_API.get_triangulation_rate (rec.currencya, rec.sob_ccy,
    rec.revldate, rec.ex_rate_type, l_deno, l_numer, l_bed_rate);

 ----------------------------------------------------------------------
 -- Calculate pair records (un)realized currency G/L
 ----------------------------------------------------------------------
 Open C_PAIR_BALANCE;
 Fetch C_PAIR_BALANCE into l_bal_date0, l_bal_amt0, l_first_batch_id, l_trans_rate0,
       l_bal_date1, l_bal_amt1, l_trans_rate1;
 While C_PAIR_BALANCE%FOUND loop
    ----------------------------------------------------------------------
    -- Get date and rate information for 1st record of the pair
    ----------------------------------------------------------------------
    if l_first_batch_id is null then

       GL_CURRENCY_API.get_triangulation_rate(rec.currencya, rec.sob_ccy,
	l_bal_date0, rec.ex_rate_type, l_deno, l_numer, l_ex_rate0);
 xtr_risk_debug_pkg.dpush('FIRST_BATCH_CA');
 xtr_risk_debug_pkg.dlog('l_ex_rate0', l_ex_rate0);
   xtr_risk_debug_pkg.dpop('FIRST_BATCH_CA');

       l_last_unrel_date := l_bal_date0;
       l_avg_rate0       := nvl(l_avg_rate0, l_ex_rate0);
       l_unrel_start_rate:= l_ex_rate0;
    else
       l_pre_batch_id := xtr_get_pre_batchid(rec);
       if l_pre_batch_id <> -1 then
	  select exchange_rate_one, (period_to + 1)
          into l_unrel_start_rate, l_last_unrel_date
          from XTR_REVALUATION_DETAILS
          where batch_id = l_pre_batch_id
	    and company_code = rec.company_code
	    and account_no = rec.account_no
	    and effective_date = l_bal_date0
 	    and nvl(realized_flag, 'N') = 'N';

            --------------- AW 25/10/01 ----------------
            l_ex_rate0 := l_unrel_start_rate;

            OPEN c_last_ca_avg_rate;
            FETCH c_last_ca_avg_rate INTO l_avg_rate0;
            CLOSE c_last_ca_avg_rate;
            l_avg_rate0 := nvl(l_avg_rate0, l_ex_rate0);
            ---------------------------------------------

 xtr_risk_debug_pkg.dpush('SEC_BATCH_CA');
 xtr_risk_debug_pkg.dlog('l_ex_rate0', l_ex_rate0);
 xtr_risk_debug_pkg.dlog('company_code', rec.company_code);
 xtr_risk_debug_pkg.dlog('account_no', rec.account_no);
 xtr_risk_debug_pkg.dlog('l_pre_batch_id', l_pre_batch_id);
   xtr_risk_debug_pkg.dpop('SEC_BATCH_CA');

       else
          GL_CURRENCY_API.get_triangulation_rate(rec.currencya, rec.sob_ccy,
           l_bal_date0, rec.ex_rate_type, l_deno, l_numer, l_ex_rate0);
          l_last_unrel_date := l_bal_date0;
          l_avg_rate0       := nvl(l_avg_rate0, l_ex_rate0);
          l_unrel_start_rate:= l_ex_rate0;
 xtr_risk_debug_pkg.dpush('SEC_BATCH_CA1');
 xtr_risk_debug_pkg.dlog('l_ex_rate0', l_ex_rate0);
   xtr_risk_debug_pkg.dpop('SEC_BATCH_CA1');

       end if;
    end if;


    l_first_batch_id := rec.batch_id;

    ----------------------------------------------------------------------
    -- Get date and rate information for 2nd record of the pair
    ----------------------------------------------------------------------
    GL_CURRENCY_API.get_triangulation_rate(rec.currencya, rec.sob_ccy,
       l_bal_date1, rec.ex_rate_type, l_deno, l_numer, l_ex_rate1);
    l_unrel_end_rate := l_ex_rate1;

    ----------------------------------------------------------------------
    -- Determine the increase and decrease
    ----------------------------------------------------------------------
    l_increase := 0;
    l_decrease := 0;
    l_pre_balance := 0;

   if (sign(l_bal_amt0) + sign(l_bal_amt1)) > 0 then
      -----------------------------------------------------------
      --both balances are positives or one is positive, one is 0
      -----------------------------------------------------------
      if (l_bal_amt1 > l_bal_amt0) then
	 l_increase := l_bal_amt1 - l_bal_amt0;
	 l_pre_balance := l_bal_amt0;
      else
	 l_decrease := l_bal_amt0 - l_bal_amt1;
      end if;

   elsif (sign(l_bal_amt0) + sign(l_bal_amt1)) < 0 then
      -----------------------------------------------------------
      --both balances are negatives or one is negative, one is 0
      -----------------------------------------------------------
      if abs(l_bal_amt1) > abs(l_bal_amt0) then
	 l_increase := abs(l_bal_amt1) - abs(l_bal_amt0);
	 l_pre_balance := abs(l_bal_amt0);
      else
	 l_decrease := l_bal_amt0 - l_bal_amt1;
      end if;
   else
      -----------------------------------------------------------
      -- balance A and B are on opposite side of 0 balance line
      -- or both balances = 0
      -----------------------------------------------------------
      l_increase    := abs(l_bal_amt1);
      l_pre_balance := 0;
      l_decrease    := l_bal_amt0;
   end if;

   ----------------------------------------------------------------------
   -- Calculate unrealized G/L for the first record of the pair and insert
   -- into xtr_revaluation_details table
   ----------------------------------------------------------------------
   l_unrel_cur_gl := round((l_bal_amt0 * (l_unrel_end_rate - l_unrel_start_rate)), l_round);
   rec.deal_subtype := 'INVEST';
   rec.fair_value := l_bal_amt0;
   rec.face_value := l_bal_amt0;
   rec.transaction_rate := l_trans_rate0;
   rec.effective_date := l_bal_date0;
   r_rd.effective_days := l_bal_date0 - rec.revldate;
   rec.period_start   := l_last_unrel_date;
   rec.period_end     := l_bal_date1;
   r_rd.transaction_period := rec.period_end - rec.period_start;
   r_rd.amount_type   := 'CCYUNRL';
   if rec.fair_value >= 0 then
      rec.deal_subtype := 'INVEST';
   else
      rec.deal_subtype := 'FUND';
   end if;
   ------------- AW 26/10/01 ------------
   rec.reval_ex_rate_one := l_ex_rate1;
  -- rec.reval_ex_rate_one := l_ex_rate0;
   --------------------------------------
   xtr_revl_unreal_log(rec, 0, 0, 0, 0, l_unrel_cur_gl, r_rd, retcode);

   xtr_risk_debug_pkg.dpush('CA_UNREL_CURR_GL');
   xtr_risk_debug_pkg.dlog('l_bal_date0', l_bal_date0);
   xtr_risk_debug_pkg.dlog('l_bal_amt0', l_bal_amt0);
   xtr_risk_debug_pkg.dlog('l_bal_date1', l_bal_date1);
   xtr_risk_debug_pkg.dlog('l_bal_amt1', l_bal_amt1);
   xtr_risk_debug_pkg.dlog('l_unrel_cur_gl', l_unrel_cur_gl);
   xtr_risk_debug_pkg.dlog('l_ex_rate0', l_ex_rate0);
   xtr_risk_debug_pkg.dlog('l_ex_rate1', l_ex_rate1);
   xtr_risk_debug_pkg.dpop('CA_UNREL_CURR_GL');

   if l_decrease <> 0 then
      ----------------------------------------------------------------------
      -- Calculate realized G/L for the second record of the pair and insert
      -- into xtr_revaluation_details table
      ----------------------------------------------------------------------
      l_rel_cur_gl := round((l_decrease * (l_ex_rate1 - l_avg_rate0)), l_round);
      rec.fair_value := l_bal_amt1;
      rec.face_value := l_bal_amt1;
      rec.transaction_rate := l_trans_rate1;
      rec.effective_date := l_bal_date1;
      r_rd.effective_days := rec.effective_date - rec.revldate;
      rec.period_start := l_bal_date0;
      rec.period_end   := l_bal_date1;
      r_rd.transaction_period := rec.period_end - rec.period_start;
      r_rd.amount_type   := 'CCYREAL';
      l_avg_rate   := l_avg_rate0;
      rec.reval_ex_rate_one := l_ex_rate1;
      if rec.fair_value >= 0 then
         rec.deal_subtype := 'INVEST';
      else
         rec.deal_subtype := 'FUND';
      end if;

      xtr_revl_real_log(rec, 0, 0, 0, l_rel_cur_gl, r_rd, retcode);

   xtr_risk_debug_pkg.dpush('CA_REAL_CURR_GL');
   xtr_risk_debug_pkg.dlog('l_bal_date0', l_bal_date0);
   xtr_risk_debug_pkg.dlog('l_bal_amt0', l_bal_amt0);
   xtr_risk_debug_pkg.dlog('l_bal_date1', l_bal_date1);
   xtr_risk_debug_pkg.dlog('l_bal_amt1', l_bal_amt1);
   xtr_risk_debug_pkg.dlog('l_ex_rate1', l_ex_rate1);
   xtr_risk_debug_pkg.dlog('l_avg_rate0', l_avg_rate0);
   xtr_risk_debug_pkg.dlog('l_rel_cur_gl', l_rel_cur_gl);
   xtr_risk_debug_pkg.dpop('CA_REAL_CURR_GL');

   end if;

   l_last_batch_id := rec.batch_id;

   if l_increase <> 0 then
   ----------------------------------------------------------------------
   -- Calcualte new average rate for second record of the pair.
   ----------------------------------------------------------------------
     l_avg_rate := ((l_increase * l_ex_rate1) + (l_pre_balance * l_avg_rate0))
		   / abs(l_bal_amt1);
   else
     l_avg_rate := l_avg_rate0;
   end if;

   ----------------------------------------------------------------------
   -- Update the first record of the pair in XTR_BANK_BALANCES table
   ----------------------------------------------------------------------
   update XTR_BANK_BALANCES
   set first_batch_id = nvl(first_batch_id, l_first_batch_id),
       last_batch_id  = nvl(last_batch_id, l_last_batch_id),
       exchange_rate  = nvl(exchange_rate, l_ex_rate0),
       average_exchange_rate = nvl(average_exchange_rate, l_avg_rate0)
   where company_code = rec.company_code
     and account_number = rec.account_no
     and balance_date = l_bal_date0;

   ----------------------------------------------------------------------
   -- Update the second record of the pair in XTR_BANK_BALANCES table
   ----------------------------------------------------------------------
   update XTR_BANK_BALANCES
   set average_exchange_rate = l_avg_rate
   where company_code = rec.company_code
     and account_number = rec.account_no
     and balance_date   = l_bal_date1;

   ----------------------------------------------------------------------
   -- Reset rate and date for next pair records comparison
   ----------------------------------------------------------------------
   l_unrel_start_rate := l_ex_rate1;
   l_last_unrel_date  :=  l_bal_date1;
   l_avg_rate0        := l_avg_rate;

  Fetch C_PAIR_BALANCE into l_bal_date0, l_bal_amt0, l_first_batch_id, l_trans_rate0,
        l_bal_date1, l_bal_amt1, l_trans_rate1;
 End Loop;
 Close C_PAIR_BALANCE;

  ----------------------------------------------------------------
  -- For the last row, we always calculate unrealized currency G/L
  ----------------------------------------------------------------
  Open  C_LAST_BALANCE;
  Fetch C_LAST_BALANCE into l_bal_date0, l_bal_amt0, l_first_batch_id, l_trans_rate0;

  if C_LAST_BALANCE%FOUND then
  if l_first_batch_id is null then
     GL_CURRENCY_API.get_triangulation_rate(rec.currencya, rec.sob_ccy,
     l_bal_date0, rec.ex_rate_type, l_deno, l_numer, l_ex_rate0);
     l_last_unrel_date := l_bal_date0;
     l_avg_rate0       := l_ex_rate0;
     l_unrel_start_rate:= l_ex_rate0;
  else
     l_pre_batch_id := xtr_get_pre_batchid(rec);
     if l_pre_batch_id <> -1 then
        select exchange_rate_one, (period_to + 1)
        into l_unrel_start_rate, l_last_unrel_date
        from XTR_REVALUATION_DETAILS
        where batch_id = l_pre_batch_id
        and company_code = rec.company_code
        and account_no = rec.account_no
        and effective_date = l_bal_date0
        and nvl(realized_flag, 'N') = 'N';
        -------- AW 25/10/01 ------------
        l_ex_rate0 := l_unrel_start_rate;
        ---------------------------------
     else
        GL_CURRENCY_API.get_triangulation_rate(rec.currencya, rec.sob_ccy,
        l_bal_date0, rec.ex_rate_type, l_deno, l_numer, l_ex_rate0);
        l_last_unrel_date := l_bal_date0;
        l_avg_rate0       := l_ex_rate0;
        l_unrel_start_rate:= l_ex_rate0;
     end if;
  end if;

  l_first_batch_id := rec.batch_id;
  if l_last_unrel_date <> rec.revldate then
     l_unrel_end_rate := l_bed_rate;
  else
     l_unrel_end_rate := l_ex_rate0;
  end if;

  l_unrel_cur_gl := round((l_bal_amt0 * (l_unrel_end_rate - l_unrel_start_rate)), l_round);
   rec.fair_value := l_bal_amt0;
   rec.face_value := l_bal_amt0;
   rec.transaction_rate := l_trans_rate0;
   rec.effective_date := l_bal_date0;
   r_rd.effective_days := l_bal_date0 - rec.revldate;
   rec.period_start   := l_last_unrel_date;
   rec.period_end     := rec.revldate;
   r_rd.transaction_period := rec.period_end - rec.period_start;
   r_rd.amount_type   := 'CCYUNRL';
   rec.reval_ex_rate_one := l_unrel_end_rate;
   if rec.fair_value >= 0 then
      rec.deal_subtype := 'INVEST';
   else
      rec.deal_subtype := 'FUND';
   end if;
   xtr_revl_unreal_log(rec, 0, 0, 0, 0, l_unrel_cur_gl, r_rd, retcode);

   xtr_risk_debug_pkg.dpush('CA_LAST_UNREL');
   xtr_risk_debug_pkg.dlog('l_bal_date0', l_bal_date0);
   xtr_risk_debug_pkg.dlog('l_bal_amt0', l_bal_amt0);
   xtr_risk_debug_pkg.dlog('l_unrel_cur_gl', l_unrel_cur_gl);
   xtr_risk_debug_pkg.dpop('CA_LAST_UNREL');

   ----------------------------------------------------------------------
   -- Update the last row into XTR_BANK_BALANCES table
   ----------------------------------------------------------------------
   update XTR_BANK_BALANCES
   set first_batch_id = nvl(first_batch_id, l_first_batch_id),
       exchange_rate  = nvl(exchange_rate, l_ex_rate0),
       average_exchange_rate = nvl(average_exchange_rate, l_avg_rate0)
   where company_code = rec.company_code
     and account_number = rec.account_no
     and balance_date = l_bal_date0;
 END if;
 Close  C_LAST_BALANCE;
 retcode  := 0;

EXCEPTION
  when GL_CURRENCY_API.no_rate then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_GL_RATE');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_RATE_CURRENCY_GL');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when GL_CURRENCY_API.invalid_currency then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_INVALID_CURRENCY');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      FND_MESSAGE.set_token('CURRENCY', rec.currencya);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_INVALID_CURRENCY_TYPE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_ca_curr_gl');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;

End;

--------------------------------------------------------------
/******************************************************************/
/* This procedure pass one deal no for each company and calculate */
/* (un)realized currency G/L and average exchange rate for the row */
/* in xtr_intergroup_transfers for deal type IG                    */
/*******************************************************************/
PROCEDURE xtr_revl_ig_curr_gl(
                        rec IN OUT NOCOPY xtr_revl_rec,
                        retcode OUT NOCOPY NUMBER) IS
l_buf Varchar2(500);
l_trans_no0	NUMBER;
l_trans_no1	NUMBER;
l_bal_date0     DATE;
l_bal_date1     DATE;
l_bal_amt0      NUMBER;
l_bal_amt1      NUMBER;
l_ex_rate0      NUMBER;
l_ex_rate1      NUMBER;
l_avg_rate0     NUMBER;
l_avg_rate1     NUMBER;
l_avg_rate	NUMBER;
l_last_bal_date DATE;
l_last_bal_amt  NUMBER;
l_last_avg_rate NUMBER;
l_last_trans_no NUMBER;
l_gl_rate       NUMBER;
l_currency_gl   NUMBER;
r_err_log       err_log; -- record type
l_bed_rate      NUMBER; --the GL exchange rate on the batch end date
l_deno          NUMBER;
l_numer         NUMBER;
l_first_batch_id NUMBER;
l_last_batch_id  NUMBER;
l_last_unrel_date DATE;
l_unrel_start_rate NUMBER;
l_unrel_end_rate   NUMBER;
l_increase      NUMBER;
l_decrease      NUMBER;
l_pre_balance   NUMBER;
l_unrel_cur_gl  NUMBER;
l_rel_cur_gl    NUMBER;
l_pre_batch_id  NUMBER;
r_rd XTR_REVALUATION_DETAILS%rowtype;
l_product0	VARCHAR2(10);
l_product1	VARCHAR2(10);
l_port0	 	VARCHAR2(7);
l_port1		VARCHAR2(7);
l_rc            NUMBER := 1;
l_round		NUMBER;

/*-----------------------------------------------------------------------------------
Cursor C_PAIR_BALANCE is
   SELECT a.transfer_date, a.balance_out, a.transaction_number, a.first_batch_id,
	  a.product_type, a.portfolio,
          b.transfer_date, b.balance_out, b.transaction_number, b.product_type,
	  b.portfolio
   FROM   XTR_INTERGROUP_TRANSFERS a,
          XTR_INTERGROUP_TRANSFERS b
   WHERE  a.company_code   =  rec.company_code
   AND    a.company_code   = b.company_code
   AND    a.deal_number = rec.deal_no
   AND    a.deal_number = b.deal_number
   AND    b.transfer_date <= rec.revldate
   AND   ((b.transaction_number > a.transaction_number and a.transfer_date = b.transfer_date)
        or(b.transfer_date > a.transfer_date))
   AND  a.transfer_date =
        (select max(transfer_date)
         from XTR_INTERGROUP_TRANSFERS c
         where c.deal_number = a.deal_number
            and  ((c.transfer_date < b.transfer_date) or
                  (c.transaction_number < b.transaction_number and c.transfer_date = b.transfer_date)))
   AND a.last_batch_id is null
   AND b.last_batch_id is null
   ORDER by 1;
-------------------------------------------------------------------------------------*/

Cursor C_CURR_BALANCE is
   SELECT b.transfer_date, b.balance_out, b.transaction_number,
          b.product_type,  b.portfolio
   FROM   XTR_INTERGROUP_TRANSFERS b
   WHERE  b.company_code   = rec.company_code
   AND    b.deal_number    = rec.deal_no
   AND    b.transfer_date <= rec.revldate
   AND    b.last_batch_id is null
   ORDER by b.transfer_date, b.transaction_number;

Cursor C_PREV_BALANCE is
   SELECT a.transfer_date, a.balance_out, a.transaction_number, a.first_batch_id,
	  a.product_type, a.portfolio
   FROM   XTR_INTERGROUP_TRANSFERS a
   WHERE  a.company_code   = rec.company_code
   AND    a.deal_number    = rec.deal_no
   AND   ((l_trans_no1 > a.transaction_number and a.transfer_date = l_bal_date1)
        or(l_bal_date1 > a.transfer_date))
   AND    a.last_batch_id is null
   ORDER by a.transfer_date desc, a.transaction_number desc;

 -------------------------------------------------------------------------------
 -- This cursor will fetch the last row for the deal number with latest transfer
 -- date and transaction number
 -------------------------------------------------------------------------------
 Cursor C_LAST_BALANCE is
   SELECT transaction_number, transfer_date, balance_out,
          first_batch_id, product_type, portfolio
   FROM   XTR_INTERGROUP_TRANSFERS
   Where  deal_number    = rec.deal_no
   AND    transfer_date <= rec.revldate
   AND    last_batch_id is null
   ORDER BY transfer_date desc, transaction_number desc;

 /*-------------------------- AW 25/10/01 ----------------------
     and transfer_date = (select max(transfer_date)
			  from XTR_INTERGROUP_TRANSFERS
			  where deal_number = rec.deal_no)
     and transaction_number = (select max(transaction_number)
			       from XTR_INTERGROUP_TRANSFERS
			       where deal_number = rec.deal_no)
     and last_batch_id is null;
 */-------------------------------------------------------------


 ---------------- AW 25/10/01 ------------------------
 -- Select the last balance's average exchange rate
 -----------------------------------------------------
 CURSOR c_last_ig_avg_rate IS
 SELECT average_exchange_rate
 FROM   xtr_intergroup_transfers
 WHERE  deal_number     = rec.deal_no
 AND    transfer_date  <= l_bal_date0
 AND    first_batch_id  = l_pre_batch_id
 ORDER BY transfer_date desc, transaction_number desc;
 -----------------------------------------------------

Begin
retcode := 1;
    select rounding_factor
    into l_round
    from xtr_master_currencies_v
    where currency = rec.sob_ccy;

 -------------------------------------------------
 -- Obtain GL exchange rate on the batch end date
 -------------------------------------------------
 GL_CURRENCY_API.get_triangulation_rate (rec.currencya, rec.sob_ccy,
    rec.revldate, rec.ex_rate_type, l_deno, l_numer, l_bed_rate);

 ----------------------------------------------------
 -- Calculate pair records (un)realized currency G/L
 ----------------------------------------------------
 Open C_CURR_BALANCE;
 Fetch C_CURR_BALANCE into l_bal_date1, l_bal_amt1, l_trans_no1, l_product1, l_port1;
 While C_CURR_BALANCE%FOUND loop
    ------------------------------------------------------------
    -- Get date and rate information for 1st record of the pair
    ------------------------------------------------------------

   OPEN C_PREV_BALANCE;
   FETCH C_PREV_BALANCE into l_bal_date0,      l_bal_amt0,  l_trans_no0,
                             l_first_batch_id, l_product0,  l_port0;
   if C_PREV_BALANCE%FOUND then
    if l_first_batch_id is null then
       GL_CURRENCY_API.get_triangulation_rate(rec.currencya,    rec.sob_ccy, l_bal_date0,
                                              rec.ex_rate_type, l_deno, l_numer, l_ex_rate0);
       l_last_unrel_date := l_bal_date0;
       l_avg_rate0       := nvl(l_avg_rate0, l_ex_rate0);
       l_unrel_start_rate:= l_ex_rate0;
    else
       l_pre_batch_id := xtr_get_pre_batchid(rec);
       if l_pre_batch_id <> -1 then
          select exchange_rate_one, (period_to +1)
          into l_unrel_start_rate, l_last_unrel_date
          from XTR_REVALUATION_DETAILS
          where batch_id = l_pre_batch_id
	  and deal_no    = rec.deal_no
	  and deal_type  = rec.deal_type
	  and transaction_no = l_trans_no0
          and nvl(realized_flag, 'N') = 'N';

          ---------- AW 25/10/01 --------------------
          l_ex_rate0 := l_unrel_start_rate;

          OPEN c_last_ig_avg_rate;
          FETCH c_last_ig_avg_rate INTO l_avg_rate0;
          CLOSE c_last_ig_avg_rate;
          l_avg_rate0 := nvl(l_avg_rate0, l_ex_rate0);
          -------------------------------------------

       else
          GL_CURRENCY_API.get_triangulation_rate(rec.currencya, rec.sob_ccy,
           l_bal_date0, rec.ex_rate_type, l_deno, l_numer, l_ex_rate0);
          l_last_unrel_date := l_bal_date0;
          l_avg_rate0       := nvl(l_avg_rate0, l_ex_rate0);
          l_unrel_start_rate:= l_ex_rate0;
       end if;
    end if;

    l_first_batch_id := rec.batch_id;

    ------------------------------------------------------------
    -- Get date and rate information for 2nd record of the pair
    ------------------------------------------------------------
    GL_CURRENCY_API.get_triangulation_rate(rec.currencya, rec.sob_ccy, l_bal_date1,
                                           rec.ex_rate_type, l_deno, l_numer, l_ex_rate1);
    l_unrel_end_rate := l_ex_rate1;

    ------------------------------------------------------------
    -- Determine the increase and decrease
    ------------------------------------------------------------
    l_increase := 0;
    l_decrease := 0;
    l_pre_balance := 0;

   if (sign(l_bal_amt0) + sign(l_bal_amt1)) > 0 then
      ------------------------------------------------------------
      --both balances are positives or one is positive, one is 0
      ------------------------------------------------------------
      if (l_bal_amt1 > l_bal_amt0) then
         l_increase := l_bal_amt1 - l_bal_amt0;
         l_pre_balance := l_bal_amt0;
      else
         l_decrease := l_bal_amt0 - l_bal_amt1;
      end if;

   elsif (sign(l_bal_amt0) + sign(l_bal_amt1)) < 0 then
      ------------------------------------------------------------
      --both balances are negatives or one is negative, one is 0
      ------------------------------------------------------------
      if abs(l_bal_amt1) > abs(l_bal_amt0) then
         l_increase := abs(l_bal_amt1) - abs(l_bal_amt0);
         l_pre_balance := abs(l_bal_amt0);
      else
         l_decrease := l_bal_amt0 - l_bal_amt1;
      end if;
   else
      ------------------------------------------------------------
      -- balance A and B are on opposite side of 0 balance line
      -- or both balances = 0
      ------------------------------------------------------------
      l_increase    := abs(l_bal_amt1);
      l_pre_balance := 0;
      l_decrease    := l_bal_amt0;
   end if;

   ------------------------------------------------------------------------
   -- Calculate unrealized G/L for the first record of the pair and insert
   -- into xtr_revaluation_details table
   ------------------------------------------------------------------------
   l_unrel_cur_gl := round((l_bal_amt0 * (l_unrel_end_rate - l_unrel_start_rate)), l_round);
   rec.trans_no   := l_trans_no0;
   rec.fair_value := l_bal_amt0;
   rec.face_value := l_bal_amt0;
   rec.product_type   := l_product0;
   rec.portfolio_code := l_port0;
   rec.effective_date := l_bal_date0;
   r_rd.effective_days:= rec.revldate - l_bal_date0;
   rec.trans_no := l_trans_no0;
   rec.period_start := l_last_unrel_date;
   rec.period_end   := l_bal_date1;
   r_rd.transaction_period := rec.period_end - rec.period_start;
   r_rd.amount_type   := 'CCYUNRL';
   if rec.fair_value >= 0 then
      rec.deal_subtype := 'INVEST';
   else
      rec.deal_subtype := 'FUND';
   end if;

   ------------- AW 26/10/01 ---------------
   rec.reval_ex_rate_one := l_ex_rate1;
   --rec.reval_ex_rate_one := l_ex_rate0;
   -----------------------------------------

   xtr_revl_unreal_log(rec, 0, 0, 0, 0, l_unrel_cur_gl, r_rd, retcode);
   if l_decrease <> 0 then
   ------------------------------------------------------------------------
   -- Calculate realized G/L for the second record of the pair and insert
   -- into xtr_revaluation_details table
   ------------------------------------------------------------------------
      l_rel_cur_gl := round((l_decrease * (l_ex_rate1 - l_avg_rate0)), l_round);
      rec.trans_no   := l_trans_no1;
      rec.fair_value := l_bal_amt1;
      rec.face_value := l_bal_amt1;
      rec.effective_date := l_bal_date1;
      r_rd.effective_days := rec.effective_date - rec.revldate;
      rec.period_start := l_bal_date0;
      rec.period_end   := l_bal_date1;
      rec.product_type   := l_product1;
      rec.portfolio_code := l_port1;
      r_rd.transaction_period := rec.period_end - rec.period_start;
      rec.trans_no := l_trans_no1;
      l_avg_rate   := l_avg_rate0;
      rec.reval_ex_rate_one := l_ex_rate1;
      r_rd.amount_type   := 'CCYREAL';
      if rec.fair_value >= 0 then
         rec.deal_subtype := 'INVEST';
      else
         rec.deal_subtype := 'FUND';
      end if;
      xtr_revl_real_log(rec, 0, 0, 0, l_rel_cur_gl, r_rd, retcode);
      l_avg_rate   := l_avg_rate0;
   end if;

   l_last_batch_id := rec.batch_id;

   if l_increase <> 0 then
   -----------------------------------------------------------
   -- Calcualte new average rate for second record of the pair.
   -----------------------------------------------------------
     l_avg_rate := ((l_increase * l_ex_rate1) + (l_pre_balance * l_avg_rate0))
                   / abs(l_bal_amt1);
   else
     l_avg_rate := l_avg_rate0;
   end if;

   -------------------------------------------------------------------------
   -- Update the first record of the pair in XTR_INTERGROUP_TRANSFERS table
   -------------------------------------------------------------------------
   update XTR_INTERGROUP_TRANSFERS
   set first_batch_id = nvl(first_batch_id, l_first_batch_id),
       last_batch_id  = nvl(last_batch_id, l_last_batch_id),
       exchange_rate  = nvl(exchange_rate, l_ex_rate0),
       average_exchange_rate = nvl(average_exchange_rate, l_avg_rate0)
   where company_code = rec.company_code
     and deal_number  = rec.deal_no
     and transaction_number = l_trans_no0;

   -------------------------------------------------------------------------
   -- Update the second record of the pair in XTR_INTERGROUP_TRANSFERS table
   -------------------------------------------------------------------------
   update XTR_INTERGROUP_TRANSFERS
   set average_exchange_rate = l_avg_rate
   where company_code = rec.company_code
     and deal_number  = rec.deal_no
     and transaction_number = l_trans_no1;
   --------------------------------------------------------
   -- Reset rate and date for next pair records comparison
   --------------------------------------------------------
   l_unrel_start_rate := l_ex_rate1;
   l_last_unrel_date  :=  l_bal_date1;
   l_avg_rate0        := l_avg_rate;

   end if;  -- C_PREV_BALANCE%FOUND
   CLOSE C_PREV_BALANCE;

   Fetch C_CURR_BALANCE into l_bal_date1, l_bal_amt1, l_trans_no1, l_product1, l_port1;

 End Loop;
 Close C_CURR_BALANCE;

  ------------------------------------------------------------------
  -- For the last row, we always calculate unrealized currency G/L
  ------------------------------------------------------------------
  Open  C_LAST_BALANCE;
  Fetch C_LAST_BALANCE into l_trans_no0, l_bal_date0, l_bal_amt0, l_first_batch_id,
        l_product0, l_port0;

  if C_LAST_BALANCE%FOUND then
  if l_first_batch_id is null then
     GL_CURRENCY_API.get_triangulation_rate(rec.currencya, rec.sob_ccy,
     l_bal_date0, rec.ex_rate_type, l_deno, l_numer, l_ex_rate0);
     l_last_unrel_date := l_bal_date0;
     l_avg_rate0       := l_ex_rate0;
     l_unrel_start_rate:= l_ex_rate0;
  else
     l_pre_batch_id := xtr_get_pre_batchid(rec);
     if l_pre_batch_id <> -1 then
         select exchange_rate_one, (period_to +1)
         into l_unrel_start_rate, l_last_unrel_date
         from XTR_REVALUATION_DETAILS
         where batch_id = l_pre_batch_id
         and deal_no    = rec.deal_no
	 and deal_type  = rec.deal_type
         and transaction_no = l_trans_no0
         and nvl(realized_flag, 'N') = 'N';

         -------- AW 25/10/01 ------------
         l_ex_rate0 := l_unrel_start_rate;
         ---------------------------------

     else
          GL_CURRENCY_API.get_triangulation_rate(rec.currencya, rec.sob_ccy,
           l_bal_date0, rec.ex_rate_type, l_deno, l_numer, l_ex_rate0);
          l_last_unrel_date := l_bal_date0;
          l_avg_rate0       := l_ex_rate0;
          l_unrel_start_rate:= l_ex_rate0;
     end if;
  end if;
  l_first_batch_id := rec.batch_id;
  if l_last_unrel_date <> rec.revldate then
     l_unrel_end_rate := l_bed_rate;
  else
     l_unrel_end_rate := l_ex_rate0;
  end if;

   l_unrel_cur_gl := round((l_bal_amt0 * (l_unrel_end_rate - l_unrel_start_rate)), l_round);
   rec.trans_no   := l_trans_no0;
   rec.fair_value := l_bal_amt0;
   rec.face_value := l_bal_amt0;
   rec.effective_date := l_bal_date0;
   r_rd.effective_days := l_bal_date0 - rec.revldate;
   rec.period_start   := l_last_unrel_date;
   rec.period_end     := rec.revldate;
   rec.product_type   := l_product0;
   rec.portfolio_code := l_port0;
   r_rd.transaction_period := rec.period_end - rec.period_start;
   r_rd.amount_type   := 'CCYUNRL';
   rec.reval_ex_rate_one := l_unrel_end_rate;
   if rec.fair_value >= 0 then
      rec.deal_subtype := 'INVEST';
   else
      rec.deal_subtype := 'FUND';
   end if;
   xtr_revl_unreal_log(rec, 0, 0, 0, 0, l_unrel_cur_gl, r_rd, retcode);

   ------------------------------------------------------------------
   -- Update the last row into XTR_INTERGROUP_TRANSFERS table
   ------------------------------------------------------------------
   update XTR_INTERGROUP_TRANSFERS
   set first_batch_id = nvl(first_batch_id, l_first_batch_id),
       exchange_rate  = nvl(exchange_rate, l_ex_rate0),
       average_exchange_rate = nvl(average_exchange_rate, l_avg_rate0)
   where company_code = rec.company_code
     and deal_number = rec.deal_no
     and transaction_number = rec.trans_no;
 End if;
  Close  C_LAST_BALANCE;

retcode := 0;
EXCEPTION
  when GL_CURRENCY_API.no_rate then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_GL_RATE');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_RATE_CURRENCY_GL');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when GL_CURRENCY_API.invalid_currency then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_INVALID_CURRENCY');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      FND_MESSAGE.set_token('CURRENCY', rec.currencya);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_INVALID_CURRENCY_TYPE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_ig_curr_gl');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
End;
-----------------------------------------------------------------
/*******************************************************************/
/* This procedure pass one deal no for each company and calculate  */
/* (un)realized currency G/L and average exchange rate for the row */
/* in xtr_rollover_transactions for deal type ONC                  */
/*******************************************************************/
PROCEDURE xtr_revl_onc_curr_gl(
                        rec IN OUT NOCOPY xtr_revl_rec,
                        retcode OUT NOCOPY NUMBER) IS
l_buf Varchar2(500);
l_trans_first_batch 	NUMBER;
l_trans_last_batch	NUMBER;
l_batch_end_rate	NUMBER;
l_unrel_start_rate	NUMBER;
l_unrel_start_date	DATE;
l_unrel_end_rate	NUMBER;
l_unrel_end_date	DATE;
l_rel_start_date	DATE;
l_trans_avg_rate	NUMBER;
l_trans_gl_rate		NUMBER;
l_deno			NUMBER;
l_numer			NUMBER;
l_repay_amount		NUMBER;
l_first_batch_id	NUMBER;
l_pre_avg_rate		NUMBER;
l_cross_trans_no	NUMBER;
l_dummy		        NUMBER;
l_sum			NUMBER:= 0;
l_pre_balance		NUMBER;
l_pre_rate		NUMBER;
l_pre_batch_id		NUMBER;
l_unrel_curr_gl		NUMBER;
l_rel_curr_gl		NUMBER;
l_round			NUMBER;
l_int_action		VARCHAR2(7);
l_accum_int             NUMBER;
r_rd XTR_REVALUATION_DETAILS%rowtype;
l_rc            NUMBER := 1; -- return code
l_rowid                 VARCHAR2(30);
r_err_log       err_log; -- record type

 cursor c_eligi_roll is
 select r.deal_subtype, r.transaction_number,
        decode(cp.parameter_value_code, 'TRADE', r.deal_date,
        r.start_date) start_date,
        r.maturity_date, r.balance_out, r.repay_amount,
        r.first_reval_batch_id, r.interest_rate,
        r.average_exchange_rate, r.cross_ref_to_trans, r.product_type,
        r.currency_exchange_rate, r.accum_int_action,  r.accum_interest_bf  --bug 2895074
 from XTR_ROLLOVER_TRANSACTIONS R,
      XTR_COMPANY_PARAMETERS CP
 where r.deal_number = rec.deal_no
 and cp.company_code = r.company_code
 and cp.parameter_code = 'ACCNT_TSDTM'
 and decode(cp.parameter_value_code, 'TRADE', r.deal_date,
           r.start_date) <= rec.revldate
  and last_reval_batch_id is null
  and status_code <> 'CANCELLED'
 order by transaction_number asc;

 cursor c_trans_avg_rate is
 select balance_out, currency_exchange_rate,
        average_exchange_rate --bug 3041100
 from   XTR_ROLLOVER_TRANSACTIONS
 where  deal_number = rec.deal_no
   and  cross_ref_to_trans = rec.trans_no;

 Cursor CHK_LOCK_ROLL is
  select rowid
   from  XTR_ROLLOVER_TRANSACTIONS
   Where  DEAL_NUMBER = rec.deal_no
   And    TRANSACTION_NUMBER = rec.trans_no
   And    DEAL_TYPE = 'ONC'
   for  update of FIRST_REVAL_BATCH_ID NOWAIT;

Begin
retcode := 1;
 select rounding_factor
 into l_round
 from xtr_master_currencies_v
 where currency = rec.sob_ccy;

 GL_CURRENCY_API.get_triangulation_rate
      (rec.reval_ccy, rec.sob_ccy, rec.revldate, rec.ex_rate_type,
       l_deno, l_numer, l_batch_end_rate);

 for l_tmp in c_eligi_roll loop
    l_sum:=0; --bug 3041100
    l_trans_first_batch := NULL;
    l_trans_last_batch  := NULL;
    rec.deal_subtype  := l_tmp.deal_subtype;
    rec.trans_no      := l_tmp.transaction_number;
    rec.start_date    := l_tmp.start_date;
    rec.effective_date:= l_tmp.start_date;
    rec.maturity_date := l_tmp.maturity_date;
    rec.fair_value    := l_tmp.balance_out;
    rec.face_value    := l_tmp.balance_out;
    rec.transaction_rate := l_tmp.interest_rate;
    rec.reval_rate    := null;
    rec.product_type  := l_tmp.product_type;
    r_rd.effective_days := rec.effective_date - rec.revldate;
    r_rd.transaction_period := rec.effective_date - rec.revldate;

    l_cross_trans_no  := l_tmp.cross_ref_to_trans;
    l_repay_amount    := l_tmp.repay_amount;
    l_first_batch_id  := l_tmp.first_reval_batch_id;
    l_int_action      := l_tmp.accum_int_action;
    l_accum_int       := l_tmp.accum_interest_bf;

    If l_first_batch_id is null then  -- First time reval   Section A
       -- Get GL rate on start date
       GL_CURRENCY_API.get_triangulation_rate
       (rec.reval_ccy, rec.sob_ccy, rec.effective_date, rec.ex_rate_type,
       l_deno, l_numer, l_trans_gl_rate);
--FND_FILE.put_line(fnd_file.log, 'l_trans_gl_rate = '||l_trans_gl_rate);
       l_unrel_start_rate := l_trans_gl_rate;
       l_unrel_start_date := rec.start_date;

       select count(*)
       into l_dummy
       from xtr_rollover_transactions
       where deal_number = rec.deal_no
         and cross_ref_to_trans = rec.trans_no;

       if l_dummy > 1 then
	-- the transaction is the result of consolidating previous transactions
	-- Need to calculate new average rate for current transaction
	  for l_tmp in c_trans_avg_rate loop
	     l_pre_balance := l_tmp.balance_out;
	     l_pre_rate    := l_tmp.average_exchange_rate;
	     l_sum := l_sum + (l_pre_balance * l_pre_rate);
          end loop;
	  --Principal Incrs bug 2961502,2895074
          --This is to handle case where consolidating with Principal Increase
          if nvl(l_repay_amount,0)<0 then
            if l_int_action in ('COMPNET', 'RENEG') then  -- bug 3672879
                l_trans_avg_rate := (l_sum +(l_trans_gl_rate*((-1)*l_repay_amount +
                nvl(l_accum_int,0)))) / rec.face_value;
            else
               l_trans_avg_rate := (l_sum+l_repay_amount*-1*l_trans_gl_rate)
                /(rec.face_value+l_repay_amount*-1);
            end if;
          elsif l_int_action in ('COMPNET', 'RENEG') then  -- bug 3672879
             l_trans_avg_rate := (l_sum + (l_trans_gl_rate * l_accum_int))
                                  / (rec.face_value+ nvl(l_repay_amount,0));
          else
             l_trans_avg_rate := l_sum / (rec.face_value + nvl(l_repay_amount,0));
          end if;

       elsif l_dummy = 1 then
	-- the transaction the result of reneg of previous transaction
  	  select nvl(average_exchange_rate,currency_exchange_rate),balance_out
             into l_pre_avg_rate, l_pre_balance
             from   XTR_ROLLOVER_TRANSACTIONS
             where  deal_number = rec.deal_no
             and  cross_ref_to_trans = rec.trans_no;
          --begin bug 2895074, 2961502
          if nvl(l_repay_amount,0)<0 then --ONC Principal Increase Case
             --recalc average rate using the formula in HLD
             if l_int_action in ('COMPNET', 'RENEG') then  -- bug 3672879
                l_trans_avg_rate := (l_pre_avg_rate*l_pre_balance +
                l_trans_gl_rate*((-1)*l_repay_amount+nvl(l_accum_int,0)))
                /rec.face_value;
             else
                l_trans_avg_rate := (l_pre_avg_rate*l_pre_balance+
                l_trans_gl_rate*l_repay_amount*-1)/(l_pre_balance+l_repay_amount*-1);
             end if;
          elsif l_int_action in ('COMPNET', 'RENEG') then  -- bug 3672879
             l_trans_avg_rate := ((l_pre_avg_rate * l_pre_balance) +
                                  (l_trans_gl_rate * l_accum_int))
                                  / (rec.face_value+ nvl(l_repay_amount,0));
          else
             l_trans_avg_rate := l_pre_avg_rate;
          end if;
       else
	  l_trans_avg_rate := l_trans_gl_rate;
       end if;

       l_trans_first_batch := rec.batch_id;

   else    -- this deal is not the first time reval
       l_pre_batch_id := xtr_get_pre_batchid(rec);
       select exchange_rate_one
       into   l_unrel_start_rate
       from   XTR_REVALUATION_DETAILS
       where  batch_id = l_pre_batch_id
       and    deal_no  = rec.deal_no
       and    transaction_no = rec.trans_no
       and    deal_type = rec.deal_type
       and    nvl(realized_flag, 'N') = 'N';

       l_unrel_start_date := rec.batch_start;
    end if;  -- B section

    if l_cross_trans_no is not null then
       -- the transaction is reneg or consolidated
       if rec.maturity_date >= rec.revldate then
	  if rec.maturity_date = rec.revldate then
	     l_trans_last_batch := rec.batch_id;
	     l_unrel_end_rate := l_batch_end_rate;
             l_unrel_end_date := rec.revldate;
	  else
	     l_unrel_end_rate := l_batch_end_rate;
	     l_unrel_end_date := rec.revldate;
	  end if;
       else
	  GL_CURRENCY_API.get_triangulation_rate
          (rec.reval_ccy, rec.sob_ccy, rec.maturity_date,
           rec.ex_rate_type, l_deno, l_numer, l_unrel_end_rate);
	  l_unrel_end_date := rec.maturity_date;
          l_trans_last_batch := rec.batch_id;
       end if;
    else   -- the current transctions is not reneg or consolidated
       l_unrel_end_rate := l_batch_end_rate;
       l_unrel_end_date := rec.revldate;
    end if;   -- C section
    l_unrel_curr_gl :=round((rec.face_value *(l_unrel_end_rate -l_unrel_start_rate)), l_round);
    if rec.deal_subtype = 'FUND' then
       l_unrel_curr_gl := l_unrel_curr_gl * (-1);
    end if;

    -- Insert period unrealized G/L amount for the transaction
    rec.period_start := l_unrel_start_date;
    rec.period_end   := l_unrel_end_date;
    rec.reval_ex_rate_one := l_unrel_end_rate;
    r_rd.amount_type   := 'CCYUNRL';
    xtr_revl_unreal_log(rec, 0, 0, 0, 0, l_unrel_curr_gl, r_rd, l_rc);

    --if (l_first_batch_id is NULL) and (l_repay_amount <> 0) then
    if (l_first_batch_id is NULL) and (l_repay_amount > 0 )then --bug 2895074
       -- exclude ONC Principal Increase, l_repay_amount<0.
       -- this condition is met if the transaction is reneg or consolidated
       -- we should insert a realized row
      -- if l_int_action in ('COMPNET', 'RENEG') then
       --   l_rel_curr_gl := round(((rec.face_value - l_pre_balance) * (l_trans_gl_rate - l_trans_avg_rate)), l_round);
       --else
          l_rel_curr_gl := round((l_repay_amount * (l_trans_gl_rate - l_trans_avg_rate)), l_round);
       -- end if;
       if rec.deal_subtype = 'FUND' then
	  l_rel_curr_gl := l_rel_curr_gl * (-1);
       end if;

-- Insert a realized G/L row into XTR_REVALUATION_DETAILS table
       select min(start_date)
       into l_rel_start_date
       from XTR_ROLLOVER_TRANSACTIONS
       where cross_ref_to_trans = rec.trans_no;

       rec.period_start := l_rel_start_date;
       rec.period_end   := rec.start_date;
       rec.fair_value   := l_repay_amount;
       rec.reval_ex_rate_one := l_trans_gl_rate;
       r_rd.amount_type   := 'CCYREAL';
       xtr_revl_real_log(rec, 0, 0, 0, l_rel_curr_gl, r_rd, l_rc);
    end if;

-- Update rollover table to update column values
   Open CHK_LOCK_ROLL;
   Fetch CHK_LOCK_ROLL into l_rowid;
   if CHK_LOCK_ROLL%FOUND then
      close CHK_LOCK_ROLL;
      Update XTR_ROLLOVER_TRANSACTIONS
      Set FIRST_REVAL_BATCH_ID = nvl(l_trans_first_batch, FIRST_REVAL_BATCH_ID),
          LAST_REVAL_BATCH_ID = nvl(l_trans_last_batch, LAST_REVAL_BATCH_ID),
          CURRENCY_EXCHANGE_RATE = nvl(CURRENCY_EXCHANGE_RATE, l_trans_gl_rate),
          AVERAGE_EXCHANGE_RATE  = nvl(AVERAGE_EXCHANGE_RATE, l_trans_avg_rate)
       Where rowid = l_rowid;
   else
      Close CHK_LOCK_ROLL;
   end if;

 end loop;

retcode := 0;
EXCEPTION
  when GL_CURRENCY_API.no_rate then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_GL_RATE');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_RATE_CURRENCY_GL');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when GL_CURRENCY_API.invalid_currency then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_INVALID_CURRENCY');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      FND_MESSAGE.set_token('CURRENCY', rec.currencya);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_INVALID_CURRENCY_TYPE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_onc_curr_gl');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
end;
---------------------------------------------------------------
/***************************************************************/
/* Get fair value, NI discount amount, cummulative unrealized  */
/* G/L, reval_rate, from previous batch for the deal.          */
/* If there is not previous batch, then return:                */
/* fair value =  initial fair value.                           */
/* NI discount amount = Balance out - interest                 */
/* cummulative unrealizd G/L = 0                               */
/* reval rate = rec.transaction_rate                           */
/***************************************************************/
PROCEDURE xtr_get_fv_from_batch(
          rec IN xtr_revl_rec,
	  p_fair_value OUT NOCOPY NUMBER,
	  p_ni_disc_amt OUT NOCOPY NUMBER,
	  p_cumm_unrel_gl OUT NOCOPY NUMBER,
	  p_reval_rate  OUT NOCOPY NUMBER) IS

l_batch_id xtr_batches.BATCH_ID%type; -- previous batch id
l_found  boolean := FALSE;
r_err_log       err_log; -- record type
retcode		NUMBER;
l_buf Varchar2(500);
cursor c_fv is
select fair_value, cumm_gain_loss_amount, reval_rate
from xtr_revaluation_details
where DEAL_NO = rec.deal_no
  and TRANSACTION_NO = rec.trans_no
  and nvl(realized_flag, 'N') = 'N'
  and BATCH_ID = l_batch_id
  order by period_to desc;   -- bug 4214521 issue 1

cursor c_disc is
select ni_disc_amount
from xtr_revaluation_details
where DEAL_NO = rec.deal_no
  and TRANSACTION_NO = rec.trans_no
  and BATCH_ID = l_batch_id;

Begin
  l_batch_id := xtr_get_pre_batchid(rec);

  if l_batch_id <> -1 then
     open c_fv;
     fetch c_fv into p_fair_value, p_cumm_unrel_gl, p_reval_rate;
     if p_fair_value is not null then
	l_found := TRUE;
     end if;
     close c_fv;
  end if;

  if l_found = false then
     if rec.deal_type in ('NI', 'ONC') then
	select initial_fair_value
	into p_fair_value
  	from XTR_ROLLOVER_TRANSACTIONS
 	where deal_number = rec.deal_no
	and  transaction_number = rec.trans_no;
     else
	select   initial_fair_value
        into p_fair_value
	from XTR_DEALS
	where deal_no = rec.deal_no;
     end if;
     p_reval_rate    := rec.transaction_rate;
     p_cumm_unrel_gl := 0;
  end if;

  if rec.deal_type = 'NI' then
     open c_disc;
     fetch c_disc into p_ni_disc_amt;
     if p_ni_disc_amt is not null then
        l_found := TRUE;
     end if;
     close c_disc;

     if l_found = false then
	select interest
	into p_ni_disc_amt
	from xtr_rollover_transactions
	where deal_number = rec.deal_no
	and   transaction_number = rec.trans_no;
     end if;
  end if;

EXCEPTION
    when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_get_fv_from_batch');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
end xtr_get_fv_from_batch;

--------------------------------------------------------
/*********************************************************/
/* this function returns the initial fairvalue when deal */
/* inception.  we need this value for calculating the P/L*/
/*********************************************************/
FUNCTION xtr_init_fv(rec IN xtr_revl_rec)
return NUMBER is
l_buf Varchar2(500);
init_fv     NUMBER := NULL;
l_inclu_cost   VARCHAR2(30) := NULL;
l_discount  VARCHAR2(1); -- for IRS
l_brk_amt   NUMBER;
l_pre_action VARCHAR2(7);
l_pre_amt    NUMBER;
l_face_value NUMBER;
l_int_rate   NUMBER;
l_deal_subtype VARCHAR2(7);
r_err_log err_log; -- record type
retcode		NUMBER;

begin
  select PARAMETER_VALUE_CODE  -- determine if we are going to include transaction cost in deal type
  into l_inclu_cost
  from xtr_company_parameters
  where company_code = rec.company_code
  and parameter_code = C_INCOST;

  if rec.deal_type = 'FRA' then
     init_fv := 0;

  elsif rec.deal_type = 'IRS' then
     select discount
     into l_discount
     from xtr_deals
     where deal_no = rec.deal_no;

     if nvl(l_discount, 'N') = 'N' then -- No principal cashflow, IFV = 0
	init_fv := 0;
     else
        select face_value_amount, deal_subtype
        into init_fv, l_deal_subtype
        from xtr_deals
        where deal_no = rec.deal_no;

	if l_deal_subtype = 'FUND' then
	   init_fv := init_fv * (-1);
	end if;
     end if;

  elsif rec.deal_type = 'FX' then
     if l_inclu_cost = 'Y' then
	select brokerage_amount
        into init_fv
	from xtr_deals
	where deal_no = rec.deal_no;
     else
	init_fv := 0;
     end if;

  elsif rec.deal_type in ('BDO', 'FXO', 'IRO', 'SWPTN') then
   -- For these Options, no transaction cost column shown on form,
   -- so we don't need to consider for now.
    select premium_action, premium_amount
    into l_pre_action, l_pre_amt
    from xtr_deals
    where deal_no = rec.deal_no;

    if l_pre_action = 'PAY' then
	init_fv := l_pre_amt;
    elsif l_pre_action = 'REC' then
        init_fv := l_pre_amt * (-1);
    end if;

  elsif rec.deal_type = 'NI' then
    select decode(l_inclu_cost, 'N', (BALANCE_OUT - INTEREST),
		  (BALANCE_OUT - INTEREST + nvl(BROKERAGE_AMOUNT, 0))),
	   deal_subtype
    into init_fv, l_deal_subtype
    from xtr_rollover_transactions
    where DEAL_NUMBER = rec.deal_no
    and TRANSACTION_NUMBER = rec.trans_no;

    if l_deal_subtype in ('SHORT', 'ISSUE') then
	init_fv := init_fv * (-1);
    end if;

  elsif rec.deal_type = 'BOND' then
    select maturity_amount, brokerage_amount,
	   nvl(base_rate, capital_price), deal_subtype
    into l_face_value, l_brk_amt, l_int_rate, l_deal_subtype
    from xtr_deals
    where deal_no = rec.deal_no;

    if l_inclu_cost = 'Y' then
	init_fv := (l_face_value * l_int_rate)/100
		   + l_brk_amt;
    else
        init_fv := (l_face_value * l_int_rate)/100;
    end if;

    if l_deal_subtype in ('SHORT', 'ISSUE') then
        init_fv := init_fv * (-1);
    end if;

  elsif rec.deal_type = 'STOCK' then
    select start_amount, brokerage_amount
    into  l_face_value, l_brk_amt
    from XTR_DEALS
    where deal_no = rec.deal_no;

    if l_inclu_cost = 'Y' then
	init_fv := l_face_value + nvl(l_brk_amt, 0);
    else
	init_fv := l_face_value;
    end if;

  elsif rec.deal_type in ('RTMM', 'TMM') then
    select face_value_amount, brokerage_amount, deal_subtype
    into l_face_value, l_brk_amt, l_deal_subtype
    from xtr_deals
    where deal_no = rec.deal_no;

    if l_inclu_cost = 'Y' then
	init_fv := l_face_value + nvl(l_brk_amt, 0);
    else
        init_fv := l_face_value;
    end if;

    if l_deal_subtype = 'FUND' then
        init_fv := init_fv * (-1);
    end if;

  elsif rec.deal_type = 'ONC' then
    -- ONC's FV is for reference only. We don't take it to calculate G/L.
    if rec.deal_subtype = 'INVEST' then
       init_fv := rec.face_value;
    else
       init_fv := rec.face_value * (-1);
    end if;

  elsif rec.deal_type = 'IG' then
    -- IG's FV is for reference only. We don't take it to calculate G/L.
    select BALANCE_OUT
    into init_fv
    from XTR_INTERGROUP_TRANSFERS_V
    where DEAL_NUMBER = rec.deal_no
    and TRANSACTION_NUMBER = rec.trans_no;

  elsif rec.deal_type = 'CA' then
    -- CA's FV is for reference only. We don't take it to calculate G/L.
    select STATEMENT_BALANCE
    into init_fv
    from XTR_BANK_BALANCES_V
    where company_code = rec.company_code
      and account_number = rec.account_no
      and BALANCE_DATE <= rec.revldate;
  end if;
  return init_fv;

EXCEPTION
    when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_init_fv');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
end xtr_init_fv;

-------------------------------------------------------------------
Procedure      xtr_ins_init_fv
(p_company_code in XTR_PARTY_INFO.PARTY_CODE%TYPE,
 p_deal_no in XTR_DEALS.DEAL_NO%TYPE,
 p_deal_type in XTR_DEALS.DEAL_TYPE%TYPE,
 p_transaction_no in XTR_DEALS.TRANSACTION_NO%TYPE,
 p_day_count_type in XTR_DEALS.DAY_COUNT_TYPE%TYPE
)
IS
--
-- Purpose: This Procedure inserts the INITIAL_FAIR_VALUE into the
-- tables XTR_DEALS or XTR_ROLLOVER_TRANSACTIONS or others depending
-- on the Deal Type.This will be callled from the forms either after
-- the POST-DATA-BASE-COMMIT Trigger or POST-INSERT Triggers or other
-- appropriate triggers.
-- This procedure uses xtr_reval_process_p.xtr_init_fv() for getting
-- the initial fair value.
-- MODIFICATION HISTORY
-- Person      Date          Comments
-- ---------   -----------   --------------------------------------------------
-- Rvallams    22-May-2001   Initial Creation
-- Declare program variables as shown above
    rec xtr_revl_rec;
    fv number;
    l_inclu_cost VARCHAR2(30);
    l_brk_amt    NUMBER;
    l_face_value NUMBER;
    l_start_date DATE;
    l_end_date   DATE;
    l_year_calc_type VARCHAR2(15);
    l_no_of_days NUMBER;
    l_year_basis NUMBER;
    l_disc_yield VARCHAR2(8);
    l_all_in_rate NUMBER;

BEGIN
    rec.company_code := p_company_code;
    rec.deal_type    := p_deal_type;
    rec.deal_no      := p_deal_no;
    rec.trans_no     := p_transaction_no;
    fv := xtr_init_fv(rec);

If p_deal_type in ('FRA', 'IRS','FX','BDO', 'FXO', 'IRO', 'STOCK',
		   'SWPTN','BOND','RTMM', 'TMM') then
    If p_transaction_no is NOT NULL then
        update xtr_deals set initial_fair_value = fv
        where   deal_no        = p_deal_no and
                deal_type      = p_deal_type and
                transaction_no = p_transaction_no and
                company_code   = p_company_code;
    Else
        update xtr_deals set initial_fair_value = fv
        where   deal_no        = p_deal_no and
                deal_type      = p_deal_type and
                company_code   = p_company_code;
    End If;
Elsif p_deal_type in ('NI') then
    If p_transaction_no is NOT NULL then
        update xtr_rollover_transactions set initial_fair_value = fv
        where   deal_number        = p_deal_no and
                deal_type          = p_deal_type and
                transaction_number = p_transaction_no and
                company_code       = p_company_code;
    Else
        update xtr_rollover_transactions set initial_fair_value = fv
        where   ((deal_number    = p_deal_no) or (trans_closeout_no = p_deal_no)) and
                deal_type      = p_deal_type and
                company_code   = p_company_code;
    End if;

      /* AW Bug 2184427
      -- Also insert ALL_IN_RATE to xtr_rollover_transactions table
      select PARAMETER_VALUE_CODE
      into   l_inclu_cost
      from   XTR_COMPANY_PARAMETERS
      where  company_code = p_company_code
      and    parameter_code =  C_INCOST;
      */

      -------------------------------------------------------
      -- AW Bug 2184427   Should use Yield rate calculation.
      -------------------------------------------------------
      select rt.balance_out, nvl(rt.brokerage_amount, 0), d.year_calc_type,
             d.calc_basis, rt.start_date, rt.maturity_date
      into   l_face_value, l_brk_amt, l_year_calc_type, l_disc_yield, l_start_date, l_end_date
      from   xtr_deals D,
             xtr_rollover_transactions RT
      where  D.deal_no = p_deal_no
      and    D.deal_no = RT.deal_number
      and    RT.transaction_number = p_transaction_no;

      -------------------------------------------------------
      -- AW Bug 2184427   Should use Yield rate calculation.
      -------------------------------------------------------
      XTR_CALC_P.calc_days_run(l_start_date, l_end_date, l_year_calc_type,
                               l_no_of_days, l_year_basis, null, p_day_count_type, 'Y');

      -------------------------------------------------------
      -- AW Bug 2184427  Should use Yield rate calculation.
      -------------------------------------------------------
      l_all_in_rate := (l_year_basis * 100) / l_no_of_days * (l_face_value / abs(fv) - 1);

      /*  AW Bug 2184427  Should use Yield rate calculation.
      if l_inclu_cost = 'Y' then
	 select rt.balance_out, nvl(rt.brokerage_amount, 0), d.year_calc_type,
                d.calc_basis, rt.start_date, rt.maturity_date
         into   l_face_value, l_brk_amt, l_year_calc_type, l_disc_yield,
                l_start_date, l_end_date
         from   xtr_deals D, xtr_rollover_transactions RT
         where  D.deal_no = p_deal_no
         and    D.deal_no = RT.deal_number
         and    RT.transaction_number = p_transaction_no;

	 if l_brk_amt <> 0 then
	    XTR_CALC_P.calc_days_run(l_start_date, l_end_date, l_year_calc_type,
	                             l_no_of_days, l_year_basis, null, p_day_count_type, 'Y');
 	    if l_disc_yield = 'DISCOUNT'  then  -- 'DISCOUNT'
	       l_all_in_rate := ((l_face_value - abs(fv)) * (l_year_basis * 100))/
	   		     (l_no_of_days * l_face_value);
	    else -- 'YIELD'
	       l_all_in_rate := (l_year_basis * 100) / l_no_of_days *
			     (l_face_value / abs(fv) - 1);
            end if;

	 else

	    select interest_rate
	    into   l_all_in_rate
	    from   xtr_rollover_transactions
	    where  deal_number = p_deal_no
	    and    transaction_number = p_transaction_no;

	 end if;

      else  -- not including cost

	 select interest_rate
	 into l_all_in_rate
	 from xtr_rollover_transactions
	 where deal_number = p_deal_no
	 and transaction_number = p_transaction_no;

      end if;
      */

      If p_transaction_no is NOT NULL then
         update xtr_rollover_transactions
         set all_in_rate = l_all_in_rate
         where   deal_number         = p_deal_no and
                  deal_type          = p_deal_type and
                  transaction_number = p_transaction_no and
                  company_code       = p_company_code;
      Else
         update xtr_rollover_transactions
         set all_in_rate = l_all_in_rate
         where  ((deal_number   = p_deal_no) or (trans_closeout_no = p_deal_no)) and
                  deal_type      = p_deal_type and
                  company_code   = p_company_code;
      End if;

Elsif p_deal_type in ('ONC') then
    If p_transaction_no is NOT NULL then
        update xtr_rollover_transactions set initial_fair_value = fv
        where   deal_number        = p_deal_no and
                deal_type          = p_deal_type and
                transaction_number = p_transaction_no and
                company_code       = p_company_code;
    Else
        update xtr_rollover_transactions set initial_fair_value = fv
        where   deal_number    = p_deal_no and
                deal_type      = p_deal_type and
                company_code   = p_company_code;
    End If;
Elsif p_deal_type in ('CA','IG') then
    Null;  -- Not Applicable for these Deal Types;
End If;
EXCEPTION
    WHEN others THEN
       APP_EXCEPTION.raise_exception;
END xtr_ins_init_fv;

--------------------------------------------------------
/********************************************************/
/* This procedure return ending fair value for each deal*/
/* type in order to calculate realized G/L              */
/********************************************************/
PROCEDURE xtr_end_fv(
          rec IN OUT NOCOPY xtr_revl_rec,
	  end_fv OUT NOCOPY NUMBER) IS
l_buff Varchar2(500);
l_rc            NUMBER := 0; -- return code
l_value_date	DATE;
l_gl_rate 	NUMBER; -- GL daily rate for FX FWD
l_sob_ccy	VARCHAR2(15);
l_base_ccy		VARCHAR2(15);
l_contra_ccy		VARCHAR2(15);
l_base_amt		NUMBER;
l_contra_amt		NUMBER;
l_buf			NUMBER;
p_sob_curr_rate	NUMBER;
l_spot_rate		NUMBER;
l_reverse      BOOLEAN;
l_round		NUMBER;
r_err_log err_log; -- record type
l_market_set   VARCHAR2(30);
r_md_in        xtr_market_data_p.md_from_set_in_rec_type;
r_md_out       xtr_market_data_p.md_from_set_out_rec_type;
l_buy_amt	NUMBER;
l_sell_amt	NUMBER;
retcode		NUMBER;

begin
   select rounding_factor
   into l_round
   from xtr_master_currencies_v
   where currency = rec.reval_ccy;

/*********** TMM ending FV **********************/
  if rec.deal_type = 'TMM' then
     select R.BALANCE_OUT_BF
     into end_fv
     from XTR_ROLLOVER_TRANSACTIONS R
     where deal_number = rec.deal_no
       and transaction_number =
	(select max(transaction_number)
	 from xtr_rollover_transactions
	 where deal_number = rec.deal_no);

     if rec.deal_subtype = 'FUND' then
	end_fv := end_fv * (-1);
     end if;

/*********** IRS ending FV **********************/
  elsif rec.deal_type = 'IRS' then
     end_fv := 0;

/*********** FRA ending FV **********************/
  elsif rec.deal_type = 'FRA' then
     end_fv := rec.settle_amount;
     if rec.settle_date is null then
        set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SETTLE_DEAL');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
     end if;
     if rec.settle_action = 'PAY' then
	end_fv := end_fv * (-1);
     end if;

/*********** NI, BOND ending FV **********************/
  elsif rec.deal_type in ('NI',  'BOND') then
  -- For NI, it's the BALANCE_OUT in parcel level.
  -- For BOND, it's the MATURITY_BALANCE_AMOUNT in deal level
     end_fv := rec.face_value;

     if rec.deal_subtype in ('SHORT', 'ISSUE') then
	end_fv := end_fv * (-1);
     end if;

/*********** BDO, IRO ending FV **********************/
  elsif rec.deal_type in ('BDO', 'IRO') then
     if rec.settle_amount is not null then -- Cash settlement
        end_fv := rec.settle_amount;
        if rec.settle_action = 'PAY' then
           end_fv := end_fv * (-1);
        end if;
     else
	end_fv := 0;
     end if;

/*********** SWPTN ending FV **********************/
  elsif rec.deal_type = 'SWPTN'  then
  -- Calculate ending fair value when status = 'EXERCISED'
     if rec.settle_amount is not null then -- Cash settlement
        end_fv := rec.settle_amount;
        if rec.settle_action = 'PAY' then
           end_fv := end_fv * (-1);
        end if;
     else  -- Create Swap deal
        if rec.cap_or_floor = 'PAY' then -- paying leg is the default leg of Swap deal
	      select decode(discount,'Y', (initial_fair_value - face_value_amount),
		            initial_fair_value)
	      into end_fv
	      from XTR_DEALS
	      where deal_subtype = 'FUND'
	      and int_swap_ref = (select swap_ref
				  from XTR_DEALS
				  where deal_no = rec.deal_no);
	else   -- 'REC'
              select decode(discount,'Y', (initial_fair_value - face_value_amount),
			    initial_fair_value)
              into end_fv
              from XTR_DEALS
              where deal_subtype = 'INVEST'
              and int_swap_ref = (select swap_ref
                                  from XTR_DEALS
                                  where deal_no = rec.deal_no);
	End if;
     End if;

/*********** FXO ending FV **********************/
  elsif rec.deal_type = 'FXO' then
     if rec.status_code in ('EXPIRED', 'CURRENT') then
 	end_fv := 0;
     elsif rec.status_code in ('EXERCISED') then
	-- the FXO is exercised and become physical FX deals
        l_base_ccy       :=  rec.currencya;   -- buy currency
        l_contra_ccy     :=  rec.currencyb;   -- sell currency
        l_market_set     :=  rec.MARKET_DATA_SET;
        xtr_revl_get_mds(l_market_set, rec);
        l_sell_amt     :=  rec.fxo_sell_ref_amount; -- deal sell amount
        l_buy_amt       :=  rec.face_value;          -- deal buy amount
        xtr_get_base_contra(l_base_ccy, l_contra_ccy, l_reverse);

        if l_reverse = TRUE then -- buy currency is different from system base currency
	   if rec.currencya = rec.reval_ccy then  -- premium currency is buy currency
		end_fv := l_buy_amt - (l_sell_amt * rec.reval_rate);
	   else    -- premium currency is sell currency
		end_fv := l_buy_amt / rec.reval_rate - l_sell_amt;
	   end if;
	else   -- buy currency is the same as system base currency
	   if rec.currencya = rec.reval_ccy then
		end_fv := l_buy_amt - (l_sell_amt /rec.reval_rate);
	   else
		end_fv := l_buy_amt * rec.reval_rate - l_sell_amt;
	   end if;
	end if;
     end if;

/*********** FX ending FV **********************/
  elsif rec.deal_type = 'FX' then
     if rec.deal_subtype = 'FORWARD' then
	xtr_revl_get_fairvalue(rec, end_fv, retcode);
     elsif rec.deal_subtype = 'SPOT' then
	end_fv := 0;
     end if;
     end_fv := round(end_fv, l_round);

/*********** RTMM ending FV **********************/
  elsif rec.deal_type = 'RTMM' then
     end_fv := null;  -- Ending fv has to be provided by user.

/*********** ONC, CA, IG ending FV **********************/
  elsif rec.deal_type in ('ONC', 'CA', 'IG') then
    -- We don't need to calcualte G/L for ONC, CA, and IG. So EFV does not matter
     end_fv := 0 ;
  else
    raise e_invalid_dealtype;
  end if;
  end_fv := round(end_fv, l_round);

EXCEPTION
  when GL_CURRENCY_API.no_rate then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_GL_RATE');
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_RATE_CURRENCY_GL');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
  when GL_CURRENCY_API.invalid_currency then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_INVALID_CURRENCY');
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_INVALID_CURRENCY_TYPE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_end_fv');
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
end xtr_end_fv;
--------------------------------------------------------
/*********************************************************/
/* This function input current batch Id and company to   */
/* find the most recent batch ID                         */
/* It returns either batch ID or -1(no previous batch ID)*/
/*********************************************************/
FUNCTION xtr_get_pre_batchid(
	  rec IN xtr_revl_rec) return NUMBER is

cursor c_batchid is
select batch_id
from xtr_batches
where COMPANY_CODE = rec.company_code
and PERIOD_END = (select max(b.period_end)
              from xtr_batches b, xtr_revaluation_details r
              where b.BATCH_ID <> rec.batch_id
               and r.deal_no = rec.deal_no
               and b.batch_id = r.batch_id)
               and nvl(upgrade_batch, 'N') <> 'Y'
               and batch_type is NULL;

begin
  for l_tmp in c_batchid loop
    return l_tmp.BATCH_ID;
  end loop;
  return -1;
end xtr_get_pre_batchid;

--------------------------------------------------------
/****************************************************************/
/* This procedure get forward rate for the following deal types:*/
/* FRA, IRO, IRS, and TMM                                       */
/* For FRA and IRO, start_date and maturity_date come from      */
/* XTR_DEALS table.                                             */
/* For TMM and IRS, start_date and maturity_date come from      */
/* XTR_ROLLOVER_TRANSACTIONS table                              */
/****************************************************************/
PROCEDURE xtr_revl_getprice_fwd(
            rec IN xtr_revl_rec, has_transno IN BOOLEAN,
            fwd_rate OUT NOCOPY NUMBER) IS
l_buf Varchar2(500);
l_start_date	DATE;
l_maturity_date	DATE;
l_day_count VARCHAR2(20);
l_side VARCHAR2(5);
l_days_t1 NUMBER;
l_days_t2 NUMBER;
l_year NUMBER;
r_md_in    xtr_market_data_p.md_from_set_in_rec_type;
r_md_out   xtr_market_data_p.md_from_set_out_rec_type;
r_mm_in    XTR_MM_COVERS.int_forw_rate_in_rec_type;
r_mm_out   XTR_MM_COVERS.int_forw_rate_out_rec_type;
l_market_set   VARCHAR2(30);
l_rt1 NUMBER;
l_rt2 NUMBER;
retcode NUMBER;
r_err_log err_log; -- record type

-- for deal_type = TMM and IRS, we need to calculate in transacation level
cursor c_roll is
select START_DATE, MATURITY_DATE
from xtr_rollover_transactions
where DEAL_NUMBER = rec.deal_no and TRANSACTION_NUMBER =
      rec.trans_no;

begin
  if has_transno = TRUE then
    for l_tmp in c_roll loop
      l_start_date := l_tmp.START_DATE;
      l_maturity_date := l_tmp.MATURITY_DATE;
    end loop;
  else
     l_start_date    := rec.start_date;
     l_maturity_date := rec.maturity_date;
  end if;
    l_market_set := rec.MARKET_DATA_SET;
    xtr_revl_get_mds(l_market_set, rec);

  if rec.deal_subtype in ('BUY', 'FUND', 'BCAP', 'SCAP') then
    l_side := 'A';
  else
    l_side := 'B';
  end if;

  -- For FRA, if start_date < batch end date and settle date is null,
  -- we don't need to calculate price. Just use previous batch FV.
  If rec.deal_type in ('FRA', 'IRO') and
		(l_start_date <= rec.revldate and rec.settle_date is null) then
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SETTLE_DEAL');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
  Else
     XTR_CALC_P.calc_days_run(rec.revldate, l_start_date,
  	 rec.year_calc_type, l_days_t1, l_year);
     xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
    	  C_YIELD_IND, rec.revldate, l_start_date,
      	rec.currencya, NULL, rec.year_calc_type,
      	C_INTERPOL_LINER, l_side, rec.batch_id, NULL);
     XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
  	l_rt1 := r_md_out.p_md_out;

     XTR_CALC_P.calc_days_run(rec.revldate, l_maturity_date,
    	rec.year_calc_type, l_days_t2, l_year);
     xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
        C_YIELD_IND, rec.revldate, l_maturity_date,
      	rec.currencya, NULL, rec.year_calc_type,
      	C_INTERPOL_LINER, l_side, rec.batch_id, NULL);
     XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
  	l_rt2 := r_md_out.p_md_out;

  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_getprice_fwd');
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_fwd: ' || 'rec.trans_no', rec.trans_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_fwd: ' || 'rec.revldate', rec.revldate);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_fwd: ' || 'rec.year_calc_type', rec.year_calc_type);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_fwd: ' || 'l_start_date', l_start_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_fwd: ' || 'l_days_t1' , l_days_t1);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_fwd: ' || 'l_rt1' , l_rt1);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_fwd: ' || 'l_days_t2' , l_days_t2);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_fwd: ' || 'l_rt2' , l_rt2);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_fwd: ' || 'l_year' , l_year);
     xtr_risk_debug_pkg.dpop('xtr_revl_getprice_fwd');
  END IF;


-- Calculate FWD price
  If l_days_t1 = l_days_t2 then
     fwd_rate := 0;
  Else
     r_mm_in.p_indicator := C_YEAR_RATE;
     r_mm_in.p_t         := l_days_t1;
     r_mm_in.p_T1        := l_days_t2;
     r_mm_in.p_Rt        := l_rt1;
     r_mm_in.p_Rt1       := l_rt2;
     r_mm_in.p_year_basis:= l_year;
     XTR_MM_COVERS.interest_forward_rate(r_mm_in, r_mm_out);
     fwd_rate := r_mm_out.p_fra_rate;
  End If;

  End If;

EXCEPTION
  when XTR_MARKET_DATA_P.e_mdcs_no_data_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_MARKET');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_MARKETDATASET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when XTR_MARKET_DATA_P.e_mdcs_no_curve_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_CURVE');
      FND_MESSAGE.set_token('MARKET', rec.market_data_set);
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_CURVEMARKET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_getprice_fwd');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
end xtr_revl_getprice_fwd;
--------------------------------------------------------
/*********************************************************/
/* This procedure returns fair value for deal type FRA   */
/*********************************************************/
PROCEDURE xtr_revl_fv_fra(
            rec IN OUT NOCOPY xtr_revl_rec,
            p_fra_price IN NUMBER,
            fair_value OUT NOCOPY NUMBER) IS
l_buf Varchar2(500);
l_settle_amt     NUMBER;
l_market_set  VARCHAR2(30);
l_discount_date_method VARCHAR2(30);
l_discount_date  DATE;
l_day         NUMBER;
l_year        NUMBER;
l_side        VARCHAR2(5);
l_settle_rate   NUMBER;
l_discount_rate NUMBER;
r_md_in       xtr_market_data_p.md_from_set_in_rec_type;
r_md_out      xtr_market_data_p.md_from_set_out_rec_type;
r_fra_in      XTR_MM_COVERS.fra_settlement_in_rec_type;
r_fra_out     XTR_MM_COVERS.fra_settlement_out_rec_type;
l_dummy		NUMBER;
l_dummy1	NUMBER;
l_reval_rate	NUMBER;
r_mm_in	      XTR_MM_COVERS.presentValue_in_rec_type;
r_mm_out      XTR_MM_COVERS.presentValue_out_rec_type;
retcode		NUMBER;
r_err_log err_log; -- record type

begin
  select PARAMETER_VALUE_CODE into l_discount_date_method
  from xtr_company_parameters
  where COMPANY_CODE = rec.company_code and
      PARAMETER_CODE = C_FRA_DISCOUNT_METHOD;

    l_market_set := rec.market_data_set;
    xtr_revl_get_mds(l_market_set, rec);

  If rec.settle_date is not null and rec.effective_date <= rec.revldate then
     -- Calculate realized G/L
       xtr_end_fv(rec, fair_value);
  Elsif (rec.start_date <= rec.revldate) and rec.settle_date is null then
     -- Pass expiry data and deal not settled yet. get fv and reval rate from previous batch
       xtr_get_fv_from_batch(rec, fair_value, l_dummy, l_dummy1, l_reval_rate);
       rec.reval_rate := l_reval_rate;
  Else  -- calculate unrealized G/L
     if(rec.deal_subtype = 'FUND') then
        l_side := 'A';
     else
        l_side := 'B';
     end if;

     XTR_CALC_P.calc_days_run(rec.start_date, rec.maturity_date,
     rec.year_calc_type, l_day, l_year);
     xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
      C_YIELD_IND, rec.start_date, rec.maturity_date,
      rec.currencya, NULL, rec.year_calc_type,
      C_INTERPOL_LINER, l_side, rec.batch_id, NULL);
     XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
     l_settle_rate := r_md_out.p_md_out;

     if(rec.pricing_model = C_P_MODEL_FRA_D) then -- 'FRA_DISC'
        r_fra_in.p_indicator := 'DR';
     elsif (rec.pricing_model = C_P_MODEL_FRA_Y) then -- 'FRA_YIELD'
        r_fra_in.p_indicator := 'Y';
     elsif rec.pricing_model is null then
        raise e_invalid_price_model;
     else
 	fair_value := null;
	return;
     end if;

     r_fra_in.p_fra_price  := rec.transaction_rate;
     r_fra_in.p_settlement_rate := p_fra_price;
     r_fra_in.p_face_value := rec.face_value;  -- deal's face_value_amount
     r_fra_in.p_day_count := l_day;
     r_fra_in.p_annual_basis := l_year;
     r_fra_in.p_deal_subtype := rec.deal_subtype;
     XTR_MM_COVERS.fra_settlement_amount(r_fra_in, r_fra_out);
     l_settle_amt := r_fra_out.p_settlement_amount;

     if(l_discount_date_method = 'REVAL') then
        if rec.deal_subtype = 'FUND' then
       	   if l_settle_amt < 0 then
        	l_side := 'A';
           else
                l_side := 'B';
           end if;
        else  -- rec.deal_subtype = 'INVEST'
           if l_settle_amt >= 0 then
        	l_side := 'A';
           else
        	l_side := 'B';
           end if;
        end if;


        XTR_CALC_P.calc_days_run(rec.revldate, rec.start_date,
     	rec.year_calc_type, l_day, l_year);
     	xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
        C_YIELD_IND, rec.revldate, rec.start_date,
        rec.currencya, NULL, rec.year_calc_type,
        C_INTERPOL_LINER, l_side, rec.batch_id, NULL);
        XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);

        l_discount_rate := r_md_out.p_md_out;

        r_mm_in.P_INDICATOR    := C_YIELD_IND;
	r_mm_in.P_FUTURE_VAL   := l_settle_amt;
	r_mm_in.P_RATE         := l_discount_rate;
	r_mm_in.P_DAY_COUNT    := l_day;
	r_mm_in.P_ANNUAL_BASIS := l_year;
        XTR_MM_COVERS.present_value(r_mm_in, r_mm_out);

	fair_value := r_mm_out.P_PRESENT_VAL;
/*
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_fv_fra: ' || 'FRA_FAIR_VALUE');
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fra: ' || 'rec.deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fra: ' || 'rec.revldate', rec.revldate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fra: ' || 'rec.start_date', rec.start_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fra: ' || 'year calc type', rec.year_calc_type);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fra: ' || 'currency', rec.currencya);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fra: ' || 'r_mm_in.P_INDICATOR', r_mm_in.P_INDICATOR);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fra: ' || 'r_mm_in.P_RATE', r_mm_in.P_RATE);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fra: ' || 'r_mm_in.P_DAY_COUNT', r_mm_in.P_DAY_COUNT);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fra: ' || 'r_mm_in.P_ANNUAL_BASIS', r_mm_in.P_ANNUAL_BASIS);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fra: ' || 'r_mm_in.P_FUTURE_VAL', r_mm_in.P_FUTURE_VAL);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fra: ' || 'discount date method', l_discount_date_method);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fra: ' || 'fair value', fair_value);
     xtr_risk_debug_pkg.dpop('xtr_revl_fv_fra: ' || 'FRA_FAIR_VALUE');
  END IF;
*/
    else
       fair_value := l_settle_amt;
    end if;
 End If;

EXCEPTION
  when XTR_MARKET_DATA_P.e_mdcs_no_data_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_MARKET');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_MARKETDATASET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when XTR_MARKET_DATA_P.e_mdcs_no_curve_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_CURVE');
      FND_MESSAGE.set_token('MARKET', rec.market_data_set);
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_CURVEMARKET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_fv_fra');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
end xtr_revl_fv_fra;
-----------------------------------------
/*********************************************************/
/* This procedure returns fair value for deal type FX    */
/*********************************************************/
PROCEDURE xtr_revl_fv_fx(
            rec IN xtr_revl_rec,
            r_fx_rate IN xtr_revl_fx_rate,
	    p_hedge_flag IN VARCHAR2,
            fair_value OUT NOCOPY NUMBER,
            p_sob_curr_rate OUT NOCOPY NUMBER) IS
l_buff Varchar2(500);
l_spot_date    DATE;
l_future_date  DATE;
l_base_ccy     VARCHAR2(15);
l_contra_ccy   VARCHAR2(15);
l_base1		VARCHAR2(15);
l_contra1	VARCHAR2(15);
l_market_set   VARCHAR2(30);
l_base_amt     NUMBER;
l_contra_amt   NUMBER;
l_buf          NUMBER;
l_contra_sob_side VARCHAR2(5);
l_reverse      BOOLEAN;
r_md_in        xtr_market_data_p.md_from_set_in_rec_type;
r_md_out       xtr_market_data_p.md_from_set_out_rec_type;
l_discount_date_method VARCHAR2(30);
l_future_fv    NUMBER;
l_base_val     NUMBER;
l_contra_val   NUMBER;
p_spot_rate    NUMBER;
p_contra_yield_rate NUMBER;
p_sob_yield_rate NUMBER;
l_num_days    NUMBER;
l_year_basis    NUMBER;
l_end_fv        NUMBER;
l_begin_fv      NUMBER;
l_begin_base_contra_rate NUMBER;
l_begin_contra_sob_rate NUMBER;
l_begin_date    DATE;
l_end_date      DATE;
l_end_base_contra_rate   NUMBER;
l_end_contra_sob_rate   NUMBER;
l_round         NUMBER;
l_dummy         VARCHAR2(1);
l_indicator     VARCHAR2(1);
l_mature        VARCHAR2(1);
l_source	VARCHAR2(1);
l_deno          NUMBER;
l_numer         NUMBER;
r_mm_in    XTR_MM_COVERS.presentValue_in_rec_type;
r_mm_out   XTR_MM_COVERS.presentValue_out_rec_type;
r_err_log err_log; -- record type
l_fx_param	VARCHAR2(50);
retcode		NUMBER;

begin

  If rec.pricing_model = 'FAIR_VALUE' then   -- bug 3184136
     p_sob_curr_rate := NULL;
     fair_value := NULL;
     return;
  End if;

  select PARAMETER_VALUE_CODE
  into l_discount_date_method
  from xtr_company_parameters
  where COMPANY_CODE = rec.company_code and
      PARAMETER_CODE = C_FX_DISCOUNT_METHOD;

  select param_value
  into l_fx_param
  from XTR_PRO_PARAM
  where param_type = 'DFLTVAL'
  and param_name = 'FX_REALIZED_RATE';

  select rounding_factor
  into l_round
  from xtr_master_currencies_v
  where currency = rec.reval_ccy;

  if  g_call_by_form = TRUE then
   -- called from form for FX rollover/predelive
     l_source := C_HIST_SOURCE; -- look currency system rate table
  else
     l_source := C_SOURCE; -- look reval rate table
  end if;

  l_future_date    :=  rec.effective_date;	-- deal value date
  l_base_ccy       :=  rec.currencya;
  l_contra_ccy     :=  rec.currencyb;
  l_market_set     :=  rec.MARKET_DATA_SET;
  xtr_revl_get_mds(l_market_set, rec);
  l_contra_amt     :=  rec.fxo_sell_ref_amount; -- deal sell amount
  l_base_amt       :=  rec.face_value;	  -- deal buy amount

  if (l_future_date <= rec.revldate and l_fx_param = 'N') or g_call_by_form = TRUE then
    l_spot_date := l_future_date;
    l_source := 'C';
    l_mature    := 'Y';
    l_end_date  := l_future_date;
  elsif l_future_date <= rec.revldate and l_fx_param = 'Y' then
    l_spot_date := rec.revldate;
    l_source := 'R';
    l_mature    := 'Y';
    l_end_date  := l_future_date;
  else
    if(nvl(p_hedge_flag,'N') = 'Y') then -- If condition Added bug 4276964
       l_spot_date := rec.period_end;
    else
       l_spot_date := rec.revldate;
    end if;
    l_source := 'R';
    l_mature    := 'N';
    l_end_date  := rec.revldate;
  end if;

  xtr_get_base_contra(l_base_ccy, l_contra_ccy, l_reverse);
-- set p_side depend on ask or bid
  if (l_reverse = true) then
    l_buf := l_base_amt;
    l_base_amt := -l_contra_amt;
    l_contra_amt := l_buf;
  else
    l_contra_amt := -l_contra_amt;
  end if;

  -- Fair value in Contra ccy without discount
  fair_value := round((l_base_amt * r_fx_rate.fx_forward_rate +
                  l_contra_amt), l_round);
/*
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_fv_fx: ' || 'FX_FAIR_VALUE');
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'rec.deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'l_base_amt', l_base_amt);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'l_contra_amt', l_contra_amt);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'forward rate', r_fx_rate.fx_forward_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'fair value', fair_value);
     xtr_risk_debug_pkg.dpop('xtr_revl_fv_fx: ' || 'FX_FAIR_VALUE');
  END IF;
*/

   /***********************************************************/
   /* Convert the fair value in contra currency to SOB        */
   /* currency equivalent                                     */
   /***********************************************************/
   if rec.pricing_model <> 'FX_GL' then
      l_contra_sob_side := 'M';
      if l_contra_ccy = rec.sob_ccy then
         p_sob_curr_rate := 1;

          -- get sob currency yield rate from market data set
         XTR_CALC_P.calc_days_run(l_spot_date, l_future_date,
         rec.year_calc_type, l_num_days, l_year_basis);

        xtr_revl_mds_init(r_md_in, l_market_set, l_source,
        C_YIELD_IND, l_spot_date, l_future_date,
        rec.sob_ccy, NULL, rec.year_calc_type,
        C_INTERPOL_LINER, l_contra_sob_side, rec.batch_id, NULL);
        XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
        p_sob_yield_rate := r_md_out.p_md_out;
      else
        l_base1 := l_contra_ccy;
        l_contra1 := rec.sob_ccy;
        xtr_get_base_contra(l_base1, l_contra1, l_reverse);
        XTR_CALC_P.calc_days_run(l_spot_date, l_future_date,
         rec.year_calc_type, l_num_days, l_year_basis);

        xtr_revl_mds_init(r_md_in, l_market_set, l_source,
        C_SPOT_RATE_IND, l_spot_date, NULL,
        l_base1, l_contra1, NULL,
        NULL, l_contra_sob_side, rec.batch_id, NULL);
        XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
       p_spot_rate := r_md_out.p_md_out;
/*
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_fv_fx: ' || 'CONTRA_SOB_CONVERT: spot rate');
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'rec.deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'indicator', l_indicator);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'C_SPOT_RATE_IND', C_SPOT_RATE_IND);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'spot date' , l_spot_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'contra ccy' , l_contra_ccy);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'sob ccy' , rec.sob_ccy);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'spot side' , l_contra_sob_side);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'spot rate', p_spot_rate);
     xtr_risk_debug_pkg.dpop('xtr_revl_fv_fx: ' || 'CONTRA_SOB_CONVERT: spot rate');
  END IF;  */

        if l_mature = 'Y' then
            p_sob_curr_rate := p_spot_rate;
        else
     -- get contra currency yield rate from market data set
            xtr_revl_mds_init(r_md_in, l_market_set, l_source,
            C_YIELD_IND, l_spot_date, l_future_date,
            l_base1, NULL, rec.year_calc_type,
            C_INTERPOL_LINER, l_contra_sob_side, rec.batch_id, NULL);
            XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
            p_contra_yield_rate := r_md_out.p_md_out;

     -- get sob currency yield rate from market data set
            xtr_revl_mds_init(r_md_in, l_market_set, l_source,
            C_YIELD_IND, l_spot_date, l_future_date,
             l_contra1, NULL, rec.year_calc_type,
            C_INTERPOL_LINER, l_contra_sob_side, rec.batch_id, NULL);
            XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
            p_sob_yield_rate := r_md_out.p_md_out;

  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_fv_fx: ' || 'CONTRA_SOB_CONVERT: contra yield rate');
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'rec.deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'l_indicator', l_indicator);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'C_YIELD_IND', C_YIELD_IND);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'spot date' , l_spot_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'future date' , l_future_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'contra ccy' , l_contra_ccy);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'calc type' , rec.year_calc_type);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'C_INTERPOL_LINER' , C_INTERPOL_LINER);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'contra side', l_contra_sob_side);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'contra yield rate', p_contra_yield_rate);
     xtr_risk_debug_pkg.dpop('xtr_revl_fv_fx: ' || 'CONTRA_SOB_CONVERT: contra yield rate');
  END IF;

      -- get fx forward rate for SOB currency(r_fx_rate.fx_forward_rate)
         XTR_FX_FORMULAS.fx_forward_rate(
          p_spot_rate,
          p_contra_yield_rate,
          p_sob_yield_rate,
          l_num_days,
          l_num_days,
          l_year_basis,
          l_year_basis,
          p_sob_curr_rate);
        end if;
     end if;
  end if;

  if l_contra_ccy <> rec.sob_ccy and rec.pricing_model = 'FX_GL' then
     -- use GL daily rate between SOB and Contra ccy instead of forward rate
        l_base1 := l_contra_ccy;
        l_contra1 := rec.sob_ccy;
        xtr_get_base_contra(l_base1, l_contra1, l_reverse);
        GL_CURRENCY_API.get_triangulation_rate(l_base1, l_contra1,
        l_spot_date, rec.ex_rate_type,l_deno, l_numer, p_sob_curr_rate);
  elsif l_contra_ccy = rec.sob_ccy and rec.pricing_model = 'FX_GL' then
        p_sob_curr_rate := 1;
  end if;

-- Fair value in term of SOB currency
  if l_reverse = TRUE then
     fair_value := round((fair_value / p_sob_curr_rate), l_round);
  else
     fair_value := round((fair_value * p_sob_curr_rate), l_round);
  end if;

/*
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_fv_fx: ' || 'FAIR_VALUE_IN_SOB');
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'p_spot_rate', p_spot_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'p_contra_yield_rate', p_contra_yield_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'p_sob_yield_rate', p_sob_yield_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'l_num_days', l_num_days);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'l_year_basis', l_year_basis);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'p_sob_curr_rate', p_sob_curr_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'fair_value', fair_value);
     xtr_risk_debug_pkg.dpop('xtr_revl_fv_fx: ' || 'FAIR_VALUE_IN_SOB');
  END IF;  */

-- If company parameter set to 'REVAL', then we should get discount fair value
  if (l_discount_date_method = 'REVAL') and (rec.effective_date > rec.revldate)
      and rec.pricing_model = 'FX_FORWARD' then
     r_mm_in.P_FUTURE_VAL := fair_value;
     r_mm_in.P_INDICATOR  := C_YIELD_IND;
     r_mm_in.P_RATE       := p_sob_yield_rate;
     r_mm_in.P_DAY_COUNT  := l_num_days;
     r_mm_in.P_ANNUAL_BASIS:= l_year_basis;
     XTR_MM_COVERS.present_value(r_mm_in, r_mm_out);
     fair_value := round(r_mm_out.P_PRESENT_VAL, l_round);
/*
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_fv_fx: ' || 'FAIR_VALUE_DISCOUNT');
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'rec.deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'p_sob_yield_rate', r_mm_in.P_RATE);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'future value', r_mm_in.P_FUTURE_VAL);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'l_num_days', r_mm_in.P_DAY_COUNT);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'l_year_basis', r_mm_in.P_ANNUAL_BASIS);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'P_INDICATOR', r_mm_in.P_INDICATOR);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'fair value', fair_value);
     xtr_risk_debug_pkg.dpop('xtr_revl_fv_fx: ' || 'FAIR_VALUE_DISCOUNT');
  END IF;  */
  end if;

EXCEPTION
  when GL_CURRENCY_API.no_rate then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_GL_RATE');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_RATE_CURRENCY_GL');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
  when GL_CURRENCY_API.invalid_currency then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_INVALID_CURRENCY');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      FND_MESSAGE.set_token('CURRENCY', rec.currencya);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_INVALID_CURRENCY_TYPE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
  when XTR_MARKET_DATA_P.e_mdcs_no_data_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_MARKET');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_MARKETDATASET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
  when XTR_MARKET_DATA_P.e_mdcs_no_curve_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_CURVE');
      FND_MESSAGE.set_token('MARKET', rec.market_data_set);
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_CURVEMARKET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_fv_fx');
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
end xtr_revl_fv_fx;
--------------------------------------------------------
/*************************************************************/
/* Calculate FX currency G/L, we cannot use normal procedure */
/* to derive currency_gl                                     */
/*************************************************************/
PROCEDURE xtr_revl_fx_curr_gl(
            rec IN OUT NOCOPY xtr_revl_rec,
	    p_hedge_flag IN VARCHAR2,
            p_realized  IN BOOLEAN,
            currency_gl OUT NOCOPY NUMBER) IS

l_end_fv        NUMBER;
l_begin_fv      NUMBER;
l_begin_base_contra_rate NUMBER;
l_begin_contra_sob_rate NUMBER;
l_begin_date    DATE;
l_end_date      DATE;
l_end_base_contra_rate   NUMBER;
l_end_contra_sob_rate   NUMBER;
l_round         NUMBER;
l_deno          NUMBER;
l_numer         NUMBER;
l_base_ccy	VARCHAR2(15);
l_contra_ccy	VARCHAR2(15);
l_base_amt	NUMBER;
l_contra_amt	NUMBER;
l_reverse	BOOLEAN;
l_buf		NUMBER;
l_dummy		VARCHAR2(1);
r_err_log err_log; -- record type
retcode		NUMBER;
l_buff Varchar2(500);

 cursor c_fx is
 select 'Y'
 from XTR_REVALUATION_DETAILS R,
      XTR_BATCHES B
 where r.deal_no = rec.deal_no
   and r.batch_id = b.batch_id
 and r.batch_id <> rec.batch_id
 and b.upgrade_batch <> 'Y';

Begin
  rec.deal_ex_rate_one :=NULL;
  rec.deal_ex_rate_two :=NULL;
  rec.reval_ex_rate_one :=NULL;
  rec.reval_ex_rate_two :=NULL;

   select rounding_factor
   into l_round
   from xtr_master_currencies_v
   where currency = rec.reval_ccy;

    l_base_ccy       :=  rec.currencya;
    l_contra_ccy     :=  rec.currencyb;
    l_contra_amt     :=  rec.fxo_sell_ref_amount; -- deal sell amount
    l_base_amt       :=  rec.face_value;          -- deal buy amount
  xtr_get_base_contra(l_base_ccy, l_contra_ccy, l_reverse);
 if (l_reverse = true) then
    l_buf := l_base_amt;
    l_base_amt := -l_contra_amt;
    l_contra_amt := l_buf;
  else
    l_contra_amt := -l_contra_amt;
  end if;

-- Determine the begin and end date to get rate on that date
   if nvl(p_hedge_flag, 'N') = 'Y' then -- hedge associated FX
       if p_realized = FALSE then    --  bug 4214521 issue 2 added lines
          l_begin_date := rec.period_start;
       else
          l_begin_date := rec.deal_date;
       end if;                       --  bug 4214521 issue 2 ended lines
   else
      open c_fx;
      fetch c_fx into l_dummy;
      close c_fx;
      if nvl(l_dummy, 'N') = 'Y' and p_realized = FALSE then
         -- deal is not first time reval or it's unrealized records
         l_begin_date := rec.batch_start - 1; --(previous batch end date)
      else
         l_begin_date := rec.deal_date;
      end if;
   end if;

   if nvl(p_hedge_flag, 'N') = 'Y' then
      l_end_date := rec.period_end;
   else
      if rec.effective_date <= rec.revldate then
         l_end_date := rec.effective_date;
      else
         l_end_date := rec.revldate;
      end if;
   end if;

   ------------------------------------------------------------
   -- Get exchange rate between base and contra, contra ccy and sob ccy in
   --  min(batch end date, deal value date) as end rate
   ------------------------------------------------------------
   GL_CURRENCY_API.get_triangulation_rate(l_base_ccy, l_contra_ccy,
   l_end_date, rec.ex_rate_type,l_deno, l_numer, l_end_base_contra_rate);

   GL_CURRENCY_API.get_triangulation_rate(l_contra_ccy, rec.sob_ccy,
   l_end_date, rec.ex_rate_type,l_deno, l_numer, l_end_contra_sob_rate);

   rec.reval_ex_rate_one := l_end_base_contra_rate;
   rec.reval_ex_rate_two := l_end_contra_sob_rate;

/* --------------------------------------------------------------------
   This part is for later use if we decide to change the definition of exchange rate
   ------------------------------------------------------------
   -- Store base-> SOB currency as exchange_rate_one and
   --  store contra -> SOB currency as exchange_rate_two in reval table
   ------------------------------------------------------------
   GL_CURRENCY_API.get_triangulation_rate(l_base_ccy, rec.sob_ccy,
   l_end_date, rec.ex_rate_type,l_deno, l_numer, rec.reval_ex_rate_one);

   GL_CURRENCY_API.get_triangulation_rate(l_contra_ccy, rec.sob_ccy,
   l_end_date, rec.ex_rate_type,l_deno, l_numer, rec.reval_ex_rate_two);
---------------------------------------------------------------------------------
*/

    l_end_fv := round(((l_base_amt * l_end_base_contra_rate + l_contra_amt)
                 * l_end_contra_sob_rate), l_round);

   ------------------------------------------------------------
   -- Get exchange rate between base and contra, contra and sob ccy in
   -- nvl(last batch end date, deal.deal_date) as begin rate
   ------------------------------------------------------------
   GL_CURRENCY_API.get_triangulation_rate(l_base_ccy, l_contra_ccy,
   l_begin_date, rec.ex_rate_type,l_deno, l_numer, l_begin_base_contra_rate);

   GL_CURRENCY_API.get_triangulation_rate(l_contra_ccy, rec.sob_ccy,
   l_begin_date, rec.ex_rate_type,l_deno, l_numer, l_begin_contra_sob_rate);

   rec.deal_ex_rate_one  := l_begin_base_contra_rate;
   rec.deal_ex_rate_two  := l_begin_contra_sob_rate;

/* --------------------------------------------------------------------
   This part is for later use if we decide to change the definition of exchange rate
   ------------------------------------------------------------
   -- Store base-> SOB currency as exchange_rate_one and
   --  store contra -> SOB currency as exchange_rate_two in xtr_deals table
   ------------------------------------------------------------
   GL_CURRENCY_API.get_triangulation_rate(l_base_ccy, rec.sob_ccy,
   l_begin_date, rec.ex_rate_type,l_deno, l_numer, rec.deal_ex_rate_one);

   GL_CURRENCY_API.get_triangulation_rate(l_contra_ccy, rec.sob_ccy,
   l_begin_date, rec.ex_rate_type,l_deno, l_numer, rec.deal_ex_rate_two);
   ------------------------------------------------------------------------
*/

    l_begin_fv := round(((l_base_amt * l_begin_base_contra_rate + l_contra_amt)
                 * l_begin_contra_sob_rate), l_round);

    currency_gl := l_end_fv - l_begin_fv;

  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_fv_fx: ' || 'xtr_fx_currency_gl');
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'rec.deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'base ccy', l_base_ccy);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'contra ccy', l_contra_ccy);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'sob ccy', rec.sob_ccy);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'base amount', l_base_amt);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'contra amount', l_contra_amt);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'end date', l_end_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'end base contra rate', l_end_base_contra_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'end contra sob rate', l_end_contra_sob_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'begin date', l_begin_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'begin base contra rate', l_begin_base_contra_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'begin contra sob rate', l_begin_contra_sob_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'end fv', l_end_fv);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'begin fv', l_begin_fv);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'currency gl', currency_gl);
     xtr_risk_debug_pkg.dpop('xtr_revl_fv_fx: ' || 'xtr_fx_currency_gl');
  END IF;

EXCEPTION
  when GL_CURRENCY_API.no_rate then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_GL_RATE');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_RATE_CURRENCY_GL');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
  when GL_CURRENCY_API.invalid_currency then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_INVALID_CURRENCY');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      FND_MESSAGE.set_token('CURRENCY', rec.currencya);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_INVALID_CURRENCY_TYPE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_fx_curr_gl');
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
End;
----------------------------------------------------------------
/*********************************************************/
/* This procedure returns reval rate for deal type FX    */
/*********************************************************/
PROCEDURE xtr_revl_getrate_fx(
            rec IN xtr_revl_rec,
	    p_hedge_flag in VARCHAR2,
            r_fx_rate OUT NOCOPY xtr_revl_fx_rate) IS
l_spot_date    DATE;
l_future_date  DATE;
l_base_ccy     VARCHAR2(15);
l_contra_ccy   VARCHAR2(15);
l_market_set   VARCHAR2(30);
l_base_amt     NUMBER;
l_contra_amt   NUMBER;
l_buf          NUMBER;
-- 'A' ask, 'B' bid. if l_base_amt<0 then 'B' else 'A'
l_side         VARCHAR2(5);
l_reverse      BOOLEAN;
l_spot_side    VARCHAR2(5);
l_contra_side  VARCHAR2(5);
l_base_side    VARCHAR2(5);
l_indicator    VARCHAR2(1);
l_mature       VARCHAR2(1);
r_md_in        xtr_market_data_p.md_from_set_in_rec_type;
r_md_out       xtr_market_data_p.md_from_set_out_rec_type;
r_err_log err_log; -- record type
retcode		NUMBER;
l_buff Varchar2(500);
l_gl_rate	NUMBER;
l_deno		NUMBER;
l_numer		NUMBER;

begin
    l_future_date :=  rec.effective_date;      -- deal value date
    l_base_ccy    :=  rec.currencya;
    l_contra_ccy  :=  rec.currencyb;
    l_market_set  :=  rec.MARKET_DATA_SET;
    xtr_revl_get_mds(l_market_set, rec);
    l_contra_amt  :=  rec.fxo_sell_ref_amount;  -- deal sell amount
    l_base_amt    :=  rec.face_value;           -- deal buy amount

-- bug 4214525 modified the if condition for hedge deals
if nvl(p_hedge_flag, 'N') = 'Y' then
       l_spot_date := rec.period_end;
    if l_future_date <= rec.revldate then
       l_indicator := 'C';
       l_mature    := 'Y';
    else
       l_indicator := 'R';
       l_mature    := 'N';
    end if;
else
    if l_future_date <= rec.revldate then
       l_spot_date := l_future_date;
       l_indicator := 'C';
       l_mature    := 'Y';
    else
       l_spot_date := rec.revldate;
       l_indicator := 'R';
       l_mature    := 'N';
    end if;
end if;

/*
  if l_future_date <= rec.revldate then
    l_spot_date := l_future_date;
    l_indicator := 'C';
    l_mature    := 'Y';
  else
    if nvl(p_hedge_flag, 'N') = 'Y' then  -- hedge assoicated FX
       l_spot_date := rec.period_end;
    else
       l_spot_date := rec.revldate;
    end if;
    l_indicator := 'R';
    l_mature    := 'N';
  end if;
*/

  xtr_get_base_contra(l_base_ccy, l_contra_ccy, l_reverse);


/*******************************************************************/
/* Introduce new FX pricing model, if GL-deal, then use either     */
/* batch end date or maturity date G/L rate as fx rate to reval    */
/*******************************************************************/
  if rec.pricing_model = 'FX_GL' then
     GL_CURRENCY_API.get_triangulation_rate(l_base_ccy, l_contra_ccy,
     l_spot_date, rec.ex_rate_type,l_deno, l_numer, l_gl_rate);
     r_fx_rate.fx_forward_rate := l_gl_rate;

  else

-- set p_side depend on ask or bid
  if (l_reverse = true) then
    l_buf := l_base_amt;
    l_base_amt := -l_contra_amt;
    l_contra_amt := l_buf;
    l_side := 'B';
  else
    l_side := 'A';
    l_contra_amt := -l_contra_amt;
  end if;

  /*  determine FX rates using 'FX Forward' price model  */
  XTR_CALC_P.calc_days_run(l_spot_date, l_future_date,
   rec.year_calc_type, r_fx_rate.num_days, r_fx_rate.year_basis);
  if (l_side = 'B') then
    l_spot_side := 'B';
    l_contra_side := 'B';
    l_base_side := 'A';
  elsif (l_side = 'A') then
    l_spot_side := 'A';
    l_contra_side := 'A';
    l_base_side := 'B';
  else
    l_spot_side := 'M';
    l_contra_side := 'M';
    l_base_side := 'M';
  end if;

-- get spot rate between base/contra from market data set
  xtr_revl_mds_init(
	r_md_in,
	l_market_set,
	l_indicator,
        C_SPOT_RATE_IND,
	l_spot_date,
	NULL,
        l_base_ccy,
	l_contra_ccy,
	NULL,
      	NULL,
	l_spot_side,
	rec.batch_id,
	NULL);

  XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
  r_fx_rate.spot_rate := r_md_out.p_md_out;

/*
 IF xtr_risk_debug_pkg.g_Debug THEN
    xtr_risk_debug_pkg.dpush('xtr_revl_fv_fx: ' || 'xtr_revl_getrate_fx: spot rate');
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'rec.deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'C_SOURCE', C_SOURCE);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'C_SPOT_RATE_IND', C_SPOT_RATE_IND);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'spot date' , l_spot_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'base ccy' , l_base_ccy);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'contra ccy' , l_contra_ccy);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'spot side' , l_spot_side);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'spot rate', r_fx_rate.spot_rate);
     xtr_risk_debug_pkg.dpop('xtr_revl_fv_fx: ' || 'xtr_revl_getrate_fx: spot rate');
  END IF;  */

  if l_mature = 'Y' then
     r_fx_rate.fx_forward_rate := r_fx_rate.spot_rate;
  else

-- get base currency yield rate from market data set
  xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
     C_YIELD_IND, l_spot_date, l_future_date,
     l_base_ccy, NULL, rec.year_calc_type,
     C_INTERPOL_LINER, l_base_side, rec.batch_id, NULL);
  XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
  r_fx_rate.base_yield_rate := r_md_out.p_md_out;

 IF xtr_risk_debug_pkg.g_Debug THEN
    xtr_risk_debug_pkg.dpush('xtr_revl_fv_fx: ' || 'xtr_revl_getrate_fx: base yield rate');
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'rec.deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'C_SOURCE', C_SOURCE);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'C_YIELD_IND', C_YIELD_IND);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'spot date' , l_spot_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'future date' , l_future_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'base ccy' , l_base_ccy);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'calc type' , rec.year_calc_type);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'C_INTERPOL_LINER' , C_INTERPOL_LINER);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'base side', l_base_side);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'base yield rate', r_fx_rate.base_yield_rate);
     xtr_risk_debug_pkg.dpop('xtr_revl_fv_fx: ' || 'xtr_revl_getrate_fx: base yield rate');
  END IF;

-- get contra currency yield rate from market data set
  xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
      C_YIELD_IND, l_spot_date, l_future_date,
      l_contra_ccy, NULL, rec.year_calc_type,
      C_INTERPOL_LINER, l_contra_side, rec.batch_id, NULL);
  XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
  r_fx_rate.contra_yield_rate := r_md_out.p_md_out;

  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_fv_fx: ' || 'xtr_revl_getrate_fx: contra yield rate');
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'rec.deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'C_SOURCE', C_SOURCE);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'C_YIELD_IND', C_YIELD_IND);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'spot date' , l_spot_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'future date' , l_future_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'contra ccy' , l_contra_ccy);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'calc type' , rec.year_calc_type);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'C_INTERPOL_LINER' , C_INTERPOL_LINER);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'contra side', l_contra_side);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'contra yield rate', r_fx_rate.contra_yield_rate);
     xtr_risk_debug_pkg.dpop('xtr_revl_fv_fx: ' || 'xtr_revl_getrate_fx: contra yield rate');
  END IF;

-- set fx forward rate (r_fx_rate.fx_forward_rate)
  XTR_FX_FORMULAS.fx_forward_rate(
       r_fx_rate.spot_rate,
       r_fx_rate.base_yield_rate,
       r_fx_rate.contra_yield_rate,
       r_fx_rate.num_days,
       r_fx_rate.num_days,
       r_fx_rate.year_basis,
       r_fx_rate.year_basis,
       r_fx_rate.fx_forward_rate);
  end if;
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_fv_fx: ' || 'xtr_revl_getrate_fx: forward rate');
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'rec.deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'spot_rate', r_fx_rate.spot_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'base rate' , r_fx_rate.base_yield_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'contra rate' , r_fx_rate.contra_yield_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'num of days' , r_fx_rate.num_days);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'year basis', r_fx_rate.year_basis);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_fx: ' || 'forward rate', r_fx_rate.fx_forward_rate);
     xtr_risk_debug_pkg.dpop('xtr_revl_fv_fx: ' || 'xtr_revl_getrate_fx: forward rate');
  END IF;

 end if;

EXCEPTION
  when GL_CURRENCY_API.no_rate then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_GL_RATE');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
         set_err_log(retcode);
         FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_RATE_CURRENCY_GL');
         FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
         FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
         FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
         l_buff := FND_MESSAGE.GET;
         FND_FILE.put_line(fnd_file.log, l_buff);
      end if;
  when GL_CURRENCY_API.invalid_currency then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_INVALID_CURRENCY');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      FND_MESSAGE.set_token('CURRENCY', rec.currencya);
      APP_EXCEPTION.raise_exception;
    else
         set_err_log(retcode);
         FND_MESSAGE.SET_NAME('XTR', 'XTR_INVALID_CURRENCY_TYPE');
         FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
         FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
         FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
         l_buff := FND_MESSAGE.GET;
         FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
  when XTR_MARKET_DATA_P.e_mdcs_no_data_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_MARKET');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_MARKETDATASET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
  when XTR_MARKET_DATA_P.e_mdcs_no_curve_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_CURVE');
      FND_MESSAGE.set_token('MARKET', rec.market_data_set);
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_CURVEMARKET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_getrate_fx');
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
end xtr_revl_getrate_fx;


----------------------------------------------------------------
/***************************************************************/
/* This procedure handel hedge associated FX deals revaluations*/
/***************************************************************/
PROCEDURE xtr_revl_fv_fxh (rec IN OUT NOCOPY xtr_revl_rec,
			   r_rd IN OUT NOCOPY XTR_REVALUATION_DETAILS%rowtype) IS

/***************************************************/
/* This cursor returns the max of batch end date   */
/* that includes the FX deals                      */
/***************************************************/
cursor C_LAST_END_DATE is
select max(b.period_end)
from xtr_batches b, xtr_revaluation_details r
where b.batch_id = r.batch_id
and b.company_code = rec.company_code
and b.batch_type is NULL
and r.deal_no = rec.deal_no;

/******************************************************/
/* This cursor will return the broken down pieces of  */
/* end date if hedge item's start date, discontinue   */
/* date, end date, or reclass date is fallen into     */
/* batch range.                                       */
/******************************************************/
cursor C_REVAL_DATE(p_last_end_date DATE) is
select a.start_date reval_date
from XTR_HEDGE_ATTRIBUTES a,
     XTR_HEDGE_RELATIONSHIPS r
where a.hedge_attribute_id = r.hedge_attribute_id
and   r.primary_code = rec.deal_no
and   r.instrument_item_flag = 'U'
and a.start_date < rec.revldate
and a.start_date >= p_last_end_date
union
select nvl(discontinue_date, end_date) reval_date
from XTR_HEDGE_ATTRIBUTES a,
     XTR_HEDGE_RELATIONSHIPS r
where a.hedge_attribute_id = r.hedge_attribute_id
and   r.primary_code = rec.deal_no
and   r.instrument_item_flag = 'U'
and nvl(a.discontinue_date, a.end_date) < rec.revldate
and nvl(a.discontinue_date, a.end_date) >= p_last_end_date
union
select c.reclass_date reval_date
from XTR_RECLASS_DETAILS c, xtr_hedge_relationships R
where c.hedge_attribute_id = r.hedge_attribute_id
and   r.primary_code = rec.deal_no
and   r.instrument_item_flag = 'U'
and c.reclass_date > p_last_end_date    -- bug 4214523
and c.reclass_date < rec.revldate
union
select effective_date reval_date
from xtr_fx_eligible_deals_v
where deal_no = rec.deal_no
and effective_date < rec.revldate
union
select period_end reval_date
from xtr_batches
where batch_id = rec.batch_id
order by reval_date asc;

 l_first		BOOLEAN;
 l_last_end_date	DATE;
 l_reval_date		DATE;
 l_hedge_flag		VARCHAR2(1) := 'Y';
 l_sob_curr_rate 	NUMBER;
 r_fx_rate 		xtr_revl_fx_rate; -- record type
 l_fv			NUMBER;
 unrel_pl_value		NUMBER;
 rel_pl_value		NUMBER;
 cum_pl_value		NUMBER;
 currency_gl		NUMBER;
 r_prev_hedge	        XTR_PREV_HEDGE;
 retcode			NUMBER;

BEGIN
 xtr_first_reval(rec, l_first);
 if l_first = TRUE then
     rec.period_start := rec.deal_date;
     l_last_end_date := rec.period_start;
 else
     rec.period_start := rec.batch_start -1;
     open  C_LAST_END_DATE;
     fetch  C_LAST_END_DATE into l_last_end_date;
     close  C_LAST_END_DATE;
 end if;

 open C_REVAL_DATE(l_last_end_date);
 fetch C_REVAL_DATE into l_reval_date;
 while C_REVAL_DATE%FOUND loop
   if l_first = TRUE and rec.period_start = l_reval_date then
        fetch C_REVAL_DATE into l_reval_date;
   else
        rec.period_end := l_reval_date;
	xtr_revl_getrate_fx(rec, l_hedge_flag, r_fx_rate);
        rec.reval_rate := r_fx_rate.fx_forward_rate;
        xtr_revl_fv_fx(rec, r_fx_rate, l_hedge_flag, l_fv, l_sob_curr_rate);
        rec.reval_fx_fwd_rate := l_sob_curr_rate;
        rec.fair_value := l_fv;

        /*****************/
        /* Realized FX   */
        /*****************/
        if rec.effective_date = l_reval_date then
           rel_pl_value := rec.fair_value;
           xtr_revl_fx_curr_gl(rec, l_hedge_flag, TRUE, currency_gl);
           xtr_revl_real_log(rec, rel_pl_value, rec.fair_value, rel_pl_value,
                currency_gl, r_rd, retcode);

           -- Also insert the last unrealized g/l info to XTR_REVALUATION_DETAILS
            xtr_get_prev_fv_rate(rec, r_prev_hedge);
            unrel_pl_value := rel_pl_value - r_prev_hedge.cum_pl;
            xtr_revl_fx_curr_gl(rec, l_hedge_flag, FALSE, currency_gl);
            xtr_revl_unreal_log(rec, unrel_pl_value, r_prev_hedge.cum_pl,
                rec.fair_value, unrel_pl_value, currency_gl, r_rd, retcode);

            Close C_REVAL_DATE;
            Return;
        else
        /*****************/
        /* Unrealized FX   */
        /*****************/
           if l_first = TRUE and rec.period_start = rec.deal_date then
              unrel_pl_value := l_fv;
              cum_pl_value   := unrel_pl_value;
           else
              xtr_get_prev_fv_rate(rec, r_prev_hedge);
              unrel_pl_value := l_fv - r_prev_hedge.fair_value;
              cum_pl_value := r_prev_hedge.cum_pl + unrel_pl_value;
           end if;
           xtr_revl_fx_curr_gl(rec, l_hedge_flag, FALSE, currency_gl);
           xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, rec.fair_value,
            unrel_pl_value, currency_gl, r_rd, retcode);
        end if;

    rec.period_start := l_reval_date; -- this period end will be next period start
    fetch C_REVAL_DATE into l_reval_date;
    end if;
 end loop;
 Close C_REVAL_DATE;

END xtr_revl_fv_fxh;

----------------------------------------------------------------
/**************************************************************/
/* This procedure calculates and insert record into table     */
/* for Hedge Items Revaluations                               */
/**************************************************************/

PROCEDURE xtr_revl_fv_hedge (rec IN OUT NOCOPY xtr_revl_rec) IS

Cursor C_REVAL_DATE is  -- Find hedge reclass date within the batch range
select reclass_date reval_date
from XTR_RECLASS_DETAILS
where hedge_attribute_id = rec.deal_no
and reclass_date < rec.revldate
and last_reval_batch_id is NULL
union
select nvl(discontinue_date, end_date) reval_date
from XTR_HEDGE_ATTRIBUTES
where hedge_attribute_id = rec.deal_no
and nvl(discontinue_date, end_date) < rec.revldate
union
select effective_date reval_date
from XTR_ELIGIBLE_HEDGES_V
where deal_no = rec.deal_no
and effective_date < rec.revldate
union
select period_end reval_date
from xtr_batches
where batch_id = rec.batch_id
order by reval_date asc;

-- Bug 4234575 This cursor has been added so that totally reclassified
-- hedges are not picked up for revaluation
cursor C_BALANCE_AMT(p_revldate DATE)  is
select RECLASS_BALANCE_AMT
from xtr_reclass_details
where HEDGE_ATTRIBUTE_ID = rec.deal_no
and RECLASS_DATE = (select max(RECLASS_DATE) from xtr_reclass_details
where HEDGE_ATTRIBUTE_ID = rec.deal_no  and rECLASS_DATE < p_revldate);



 cursor C_PROS_FREQ is
 select pros_frequency_num, pros_frequency_unit
 from XTR_HEDGE_ATTRIBUTES
 where hedge_attribute_id = rec.deal_no
 and PROS_METHOD <> 'NOTEST';

/* This Cursor is added to populate hedge date when */
/* the prospective test is not done initially Bug 4201031 */
 cursor C_PROS_NOT_FOUND is
 select start_date
 from XTR_HEDGE_ATTRIBUTES
 where hedge_attribute_id = rec.deal_no
 and PROS_METHOD <> 'NOTEST';

-- bug 4214554
/* This cursor is added to check that the date on which the
prospective test is required should not exceed the hedge end date */
 cursor C_PROS_NOT_REQUIRED is
 select least( nvl(discontinue_date, end_date),reclass_date)
 from XTR_HEDGE_ATTRIBUTES hat , XTR_RECLASS_DETAILS rd
 where hat.hedge_attribute_id = rec.deal_no
 and PROS_METHOD <> 'NOTEST'
 and reclass_balance_amt = 0
 and hat.hedge_attribute_id = rd.hedge_attribute_id;



 cursor C_PROS_TEST is
 select max(result_date)
 from XTR_HEDGE_PRO_TESTS
 where hedge_attribute_id = rec.deal_no;

 l_start_date   DATE;
 l_end_date     DATE;
 l_hedge_end    DATE;
 l_prev_end_date        DATE;
 l_test         VARCHAR2(30);
 l_freq_num     NUMBER;
 l_freq_unit    VARCHAR2(1);
 l_result_date  DATE;
 l_next_test_date       DATE;
 l_complete_flag VARCHAR2(1) := 'Y';
 l_first	BOOLEAN;
 l_buff Varchar2(500);
 retcode	NUMBER;
 l_balance_amt NUMBER := -1;

BEGIN
  LOG_MSG('Entering procedure xtr_revl_fv_hedge');
  -- Check Prospective Tests status
  select PARAMETER_VALUE_CODE
  into l_test
  from xtr_company_parameters
  where COMPANY_CODE = rec.company_code and
  PARAMETER_CODE = C_BTEST;

  if nvl(l_test, 'N') = 'Y' then
     open C_PROS_FREQ;
     Fetch C_PROS_FREQ into l_freq_num, l_freq_unit;
     if C_PROS_FREQ%FOUND then  -- prospective test is required
        Open C_PROS_TEST;
        Fetch C_PROS_TEST into l_result_date;
        --if C_PROS_TEST%FOUND then
        if l_result_date is NOT NULL then
           if l_freq_unit = 'D' then
              l_next_test_date := l_result_date + l_freq_num;
           elsif l_freq_unit = 'W' then
              l_next_test_date := l_result_date + (7 * l_freq_num);
           elsif l_freq_unit = 'M' then
              l_next_test_date := add_months(l_result_date, l_freq_num);
           elsif l_freq_unit = 'Q' then
             l_next_test_date := add_months(l_result_date, l_freq_num * 3);
           elsif l_freq_unit = 'Y' then
             l_next_test_date := add_months(l_result_date, l_freq_num * 12);
           end if;

            open C_PROS_NOT_REQUIRED;
           fetch C_PROS_NOT_REQUIRED into l_hedge_end ;
           close C_PROS_NOT_REQUIRED;

           if l_next_test_date < rec.revldate and  l_next_test_date <
nvl(l_hedge_end,rec.revldate)  then
             l_complete_flag := 'N';
           end if;
        else  -- No prospective test record exists
           l_complete_flag := 'N';
           open C_PROS_NOT_FOUND;
           fetch C_PROS_NOT_FOUND into l_next_test_date;
           close C_PROS_NOT_FOUND;
        end if;
        CLose C_PROS_TEST;
      End if;
     Close C_PROS_FREQ;
  end if;

  if l_complete_flag = 'N' then
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_REVAL_PROS_FAIL');
      FND_MESSAGE.SET_TOKEN('HEDGE_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('NEXT_TEST_DATE', l_next_test_date);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
  end if;

  xtr_first_reval(rec, l_first);
  if l_first = TRUE then -- first time reval
     l_start_date := rec.start_date;
  else
     l_start_date := rec.batch_start - 1;
  end if;
  Open C_REVAL_DATE;
  Fetch C_REVAL_DATE into l_end_date;
  While C_REVAL_DATE%FOUND loop
   if l_end_date >= rec.batch_start then  -- bug 4214523
        if l_end_date > rec.effective_date then
           Close C_REVAL_DATE;
           Return;
        else
           -- bug 4234575
           open c_balance_amt(l_end_date);
           fetch c_balance_amt into l_balance_amt;
           close c_balance_amt;

           LOG_MSG('xtr_revl_fv_hedge rec.deal_no',rec.deal_no);
           LOG_MSG('xtr_revl_fv_hedge l_start_date',l_start_date);
           LOG_MSG('xtr_revl_fv_hedge l_end_date',l_end_date);
           LOG_MSG('xtr_revl_fv_hedge rec.face_value',rec.face_value);

           if nvl(l_balance_amt, -1) <> 0  then
              if rec.pricing_model = 'NONE' then -- forward rate model
                 XTR_HEDGE_FWD_RATE(rec, l_start_date, l_end_date, l_complete_flag);
              else
                 XTR_HEDGE_GL_RATE(rec, l_start_date, l_end_date, l_complete_flag);
              end if;
           else
              return;
           end if;
        end if;
        l_start_date := l_end_date;     -- bug 42145323
    end if;
     Fetch C_REVAL_DATE into l_end_date;
  End loop;
  Close C_REVAL_DATE;

  LOG_MSG('Ending xtr_revl_fv_hedge');
END xtr_revl_fv_hedge;
----------------------------------------------------------------
/**************************************************************/
/* This procedure calculates Hedge item currency gain/loss for*/
/* pricing mode 'GL Rate' (exclusion item value is TIME)      */
/**************************************************************/
PROCEDURE xtr_hedge_gl_rate (rec IN OUT NOCOPY xtr_revl_rec,
                             p_start_date IN DATE,
                             p_end_date IN DATE,
                             p_complete_flag IN VARCHAR2) IS

 cursor C_CUR_HEDGE_AMT is
 select reclass_details_id, reclass_balance_amt
 from XTR_RECLASS_DETAILS
 where hedge_attribute_id = rec.deal_no
 and reclass_date >= p_start_date
 and reclass_date < p_end_date;

 l_buff Varchar2(500);
 r_rd XTR_REVALUATION_DETAILS%rowtype;
 retcode        NUMBER;
 l_first        BOOLEAN;
 l_reclass_id	NUMBER;
 l_cur_hedge_amt NUMBER;
 l_last_reval   BOOLEAN;
 l_begin_fv     NUMBER;
 l_end_fv       NUMBER;
 l_begin_rate   NUMBER;
 l_end_rate     NUMBER;
 l_deno         NUMBER;
 l_numer        NUMBER;
 l_round        NUMBER;
 currency_gl    NUMBER;
 fv_sob_amt	NUMBER;
 unrel_sob_gl	NUMBER;
 l_hedge_flag VARCHAR2(1);
 r_prev_hedge	XTR_PREV_HEDGE;

BEGIN
 select rounding_factor
 into l_round
 from xtr_master_currencies_v
 where currency = rec.reval_ccy;

 /* Derive the correct current hedge amount for the broken down piece */
 open C_CUR_HEDGE_AMT;
 Fetch C_CUR_HEDGE_AMT into l_reclass_id, l_cur_hedge_amt;
 if C_CUR_HEDGE_AMT%FOUND then
    rec.face_value := l_cur_hedge_amt;

    Update XTR_RECLASS_DETAILS
    Set last_reval_batch_id = rec.batch_id
    where reclass_details_id = l_reclass_id;
 end if;
 Close C_CUR_HEDGE_AMT;

 rec.fair_value   := rec.face_value;
 rec.reval_rate   := NULL;
 rec.period_start := p_start_date;
 rec.period_end   := p_end_date;
 r_rd.amount_type  := 'CCYUNRL';
 r_rd.transaction_period := p_end_date - p_start_date;
 if rec.effective_date < rec.revldate then
    r_rd.effective_days := 0;
 else
    r_rd.effective_days     := rec.effective_date - rec.revldate;
 end if;

  -- Find beginning GL rate
  xtr_first_reval(rec, l_first);
  if l_first = TRUE then -- first time reval
 -- Bug 9280321 starts
     -- GL_CURRENCY_API.get_triangulation_rate (rec.reval_ccy, rec.sob_ccy, rec.period_start, rec.ex_rate_type,l_deno, l_numer, l_begin_rate);
     GL_CURRENCY_API.get_triangulation_rate (rec.currencya, rec.sob_ccy, rec.period_start, rec.ex_rate_type,l_deno, l_numer, l_begin_rate);
 -- Bug 9280321 stops
      rec.deal_ex_rate_one := l_begin_rate;
  else
      XTR_GET_PREV_FV_RATE(rec, r_prev_hedge);
      l_begin_rate := r_prev_hedge.rate;
      if l_begin_rate is NULL then
     -- Bug 9280321 starts
       --  GL_CURRENCY_API.get_triangulation_rate (rec.reval_ccy, rec.sob_ccy, rec.period_start, rec.ex_rate_type,l_deno, l_numer, l_begin_rate);
       GL_CURRENCY_API.get_triangulation_rate (rec.currencya, rec.sob_ccy, rec.period_start, rec.ex_rate_type,l_deno, l_numer, l_begin_rate);
      -- Bug 9280321 ends
      end if;
  end if;

  -- Find ending GL rate
 -- Bug 9280321 starts
 --GL_CURRENCY_API.get_triangulation_rate (rec.reval_ccy, rec.sob_ccy, rec.period_end, rec.ex_rate_type,l_deno, l_numer, l_end_rate);
 GL_CURRENCY_API.get_triangulation_rate (rec.currencya, rec.sob_ccy, rec.period_end, rec.ex_rate_type,l_deno, l_numer, l_end_rate);
-- Bug 9280321 ends

  l_begin_fv := round(rec.fair_value * l_begin_rate, l_round);
  l_end_fv   := round(rec.fair_value * l_end_rate, l_round);

  currency_gl := l_end_fv - l_begin_fv;
  rec.reval_ex_rate_one := l_end_rate;

  if currency_gl is NULL or p_complete_flag = 'N' then
     l_hedge_flag := 'N';
  end if;

  XTR_REVL_UNREAL_LOG(rec, 0, 0, l_end_fv, 0,
                      currency_gl, r_rd, retcode, l_hedge_flag );


EXCEPTION
  when GL_CURRENCY_API.no_rate then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_GL_RATE');
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_RATE_CURRENCY_GL');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
  when GL_CURRENCY_API.invalid_currency then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_INVALID_CURRENCY');
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_INVALID_CURRENCY_TYPE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_hedge_gl_rate' );
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;

END xtr_hedge_gl_rate;


---------------------------------------------------------------
/**************************************************************/
/* This procedure calculates Hedge item unrealized gain/loss  */
/* for pricing mode 'Forward Rate' (Exclusion item is NONE)   */
/**************************************************************/
PROCEDURE xtr_hedge_fwd_rate(rec IN OUT NOCOPY xtr_revl_rec,
                             p_start_date IN DATE,
                             p_end_date IN DATE,
                             p_complete_flag IN VARCHAR2) IS

 cursor C_CUR_HEDGE_AMT is
 select reclass_details_id, reclass_balance_amt
 from XTR_RECLASS_DETAILS
 where hedge_attribute_id = rec.deal_no
 and reclass_date >= p_start_date
 and reclass_date < p_end_date;   -- bug 4276970



 l_buff Varchar2(500);
 r_rd XTR_REVALUATION_DETAILS%rowtype;
 retcode        NUMBER;
 l_reclass_id	NUMBER;
 l_cur_hedge_amt        NUMBER;
 l_last_reval   BOOLEAN;
 l_begin_date   DATE;
 l_begin_spot_rate      NUMBER;
 l_begin_base_rate      NUMBER;
 l_begin_contra_rate    NUMBER;
 l_begin_fwd_rate       NUMBER;
 l_spot_rate    NUMBER;
 l_base_yield_rate      NUMBER;
 l_contra_yield_rate    NUMBER;
 l_sob_yield_rate       NUMBER;
 l_forward_rate NUMBER;
 l_begin_fv     NUMBER;
 l_end_fv       NUMBER;
 l_base_ccy     VARCHAR2(15);
 l_contra_ccy   VARCHAR2(15);
 l_market_set   VARCHAR2(30);
 l_reverse      BOOLEAN ;
 l_first        BOOLEAN;
 l_base_side            VARCHAR2(1);
 l_contra_side          VARCHAR2(1);
 l_spot_side            VARCHAR2(1);
 l_spot_date    DATE;
 l_future_date  DATE;
 r_md_in        xtr_market_data_p.md_from_set_in_rec_type;
 r_md_out       xtr_market_data_p.md_from_set_out_rec_type;
 l_discount_date_method VARCHAR2(30);
 l_round        NUMBER;
 l_deno         NUMBER;
 l_no_of_days   NUMBER;
 l_year_basis   NUMBER;
 l_numer        NUMBER;
 currency_gl    NUMBER;
 unrel_pl_value NUMBER;
 l_hedge_flag VARCHAR2(1);
 r_prev_hedge	XTR_PREV_HEDGE;
 r_mm_in    XTR_MM_COVERS.presentValue_in_rec_type;
 r_mm_out   XTR_MM_COVERS.presentValue_out_rec_type;
 l_first_call   NUMBER;       -- bug 4145664 issue 12
BEGIN
 LOG_MSG('Entering xtr_hedge_fwd_rate');

 select rounding_factor
 into l_round
 from xtr_master_currencies_v
 where currency = rec.reval_ccy;

 /* Derive the correct current hedge amount for the broken down piece */
 open C_CUR_HEDGE_AMT;
 Fetch C_CUR_HEDGE_AMT into l_reclass_id, l_cur_hedge_amt;
 if C_CUR_HEDGE_AMT%FOUND then
    rec.face_value := l_cur_hedge_amt;

    LOG_MSG(' xtr_hedge_fwd_rate rec.face_value',rec.face_value);

    Update XTR_RECLASS_DETAILS
    Set last_reval_batch_id = rec.batch_id
    where reclass_details_id = l_reclass_id;
 end if;
 Close C_CUR_HEDGE_AMT;


 l_spot_date      := p_end_date;
 l_future_date    := rec.maturity_date;   -- hedge end date
 l_first_call     := 1;
 rec.period_start := p_start_date;
 rec.period_end   := p_end_date;
 currency_gl      := 0;  -- No need to calculate currency gain/loss
 r_rd.amount_type  := 'UNREAL';
 r_rd.transaction_period := p_end_date - p_start_date;
 if rec.effective_date < rec.revldate then
    r_rd.effective_days := 0;
 else
    r_rd.effective_days     := rec.effective_date - rec.revldate;
 end if;

 l_base_ccy       :=  rec.currencya;
 l_contra_ccy     :=  rec.sob_ccy;
 xtr_get_base_contra(l_base_ccy, l_contra_ccy, l_reverse);

 -- set p_side depend on ask or bid
  if (l_reverse = true) then
    l_spot_side := 'B';
    l_contra_side := 'B';
    l_base_side := 'A';
  else
    l_spot_side := 'A';
    l_contra_side := 'A';
    l_base_side := 'B';
  end if;

  l_market_set     :=  rec.MARKET_DATA_SET;
  xtr_revl_get_mds(l_market_set, rec);

/**********************************************************************/
/* Determine the beginning forward rate and FV at hedge start date    */
/*********************************************************************/
  xtr_first_reval(rec, l_first);

  if l_first = TRUE then -- first time reval
     l_begin_date := rec.start_date;

     XTR_CALC_P.calc_days_run(l_begin_date, l_future_date,
     rec.year_calc_type, l_no_of_days, l_year_basis);
     -- get spot rate between hedge ccy/sob ccy at hedge start date
     xtr_revl_mds_init(
        r_md_in,
        l_market_set,
        'R',
        C_SPOT_RATE_IND,
        l_begin_date,
        NULL,
        l_base_ccy,
        l_contra_ccy,
        NULL,
        NULL,
        l_spot_side,
        rec.batch_id,
        NULL);

     XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out, l_first_call);
     l_begin_spot_rate := r_md_out.p_md_out;

  -- get base currency yield rate from market data set
     xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
     C_YIELD_IND, l_begin_date, l_future_date,
     l_base_ccy, NULL, rec.year_calc_type,
     C_INTERPOL_LINER, l_base_side, rec.batch_id, NULL);
     XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
     l_begin_base_rate := r_md_out.p_md_out;

  -- get contra currency yield rate from market data set
     xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
      C_YIELD_IND, l_begin_date, l_future_date,
      l_contra_ccy, NULL, rec.year_calc_type,
      C_INTERPOL_LINER, l_contra_side, rec.batch_id, NULL);
     XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
     l_begin_contra_rate := r_md_out.p_md_out;

  -- Get forward-forward rate
     XTR_FX_FORMULAS.fx_forward_rate(
       l_begin_spot_rate,
       l_begin_base_rate,
       l_begin_contra_rate,
       l_no_of_days,
       l_no_of_days,
       l_year_basis,
       l_year_basis,
       l_begin_fwd_rate);

      rec.deal_ex_rate_one := l_begin_fwd_rate;

  Else  -- not the first time reval. Get fwd rate from previous record.
     XTR_GET_PREV_FV_RATE(rec, r_prev_hedge);
     l_begin_fwd_rate := r_prev_hedge.rate;
  end if;

/***********************************************************/
/* Determine the ending forward rate and FV at end date    */
/***********************************************************/
  XTR_CALC_P.calc_days_run(l_spot_date, l_future_date,
    rec.year_calc_type, l_no_of_days, l_year_basis);
  -- get spot rate between hedge ccy/sob ccy at hedge start date
  xtr_revl_mds_init(
        r_md_in,
        l_market_set,
        'R',
        C_SPOT_RATE_IND,
        l_spot_date,
        NULL,
        l_base_ccy,
        l_contra_ccy,
        NULL,
        NULL,
        l_spot_side,
        rec.batch_id,
        NULL);

  XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
  l_spot_rate := r_md_out.p_md_out;

  -- get base currency yield rate from market data set
     xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
     C_YIELD_IND, l_spot_date, l_future_date,
     l_base_ccy, NULL, rec.year_calc_type,
     C_INTERPOL_LINER, l_base_side, rec.batch_id, NULL);
     XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
     l_base_yield_rate := r_md_out.p_md_out;

  -- get contra currency yield rate from market data set
     xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
      C_YIELD_IND, l_spot_date, l_future_date,
      l_contra_ccy, NULL, rec.year_calc_type,
      C_INTERPOL_LINER, l_contra_side, rec.batch_id, NULL);
     XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
     l_contra_yield_rate := r_md_out.p_md_out;

  -- Get forward-forward rate
     XTR_FX_FORMULAS.fx_forward_rate(
       l_spot_rate,
       l_base_yield_rate,
       l_contra_yield_rate,
       l_no_of_days,
       l_no_of_days,
       l_year_basis,
       l_year_basis,
       l_forward_rate);

  if l_reverse = TRUE then
     l_begin_fv := round((rec.face_value / l_begin_fwd_rate), l_round);
     l_end_fv   := round((rec.face_value / l_forward_rate), l_round);
  else
     l_begin_fv := round((rec.face_value * l_begin_fwd_rate), l_round);
     l_end_fv   := round((rec.face_value * l_forward_rate), l_round);
  end if;
  rec.reval_rate := l_forward_rate;

-- If company parameter set to 'REVAL', then we should get discount fair value
  if (l_discount_date_method = 'REVAL') and (rec.effective_date > rec.revldate) then
     if l_reverse = TRUE then
        l_sob_yield_rate  := l_base_yield_rate;
     else
        l_sob_yield_rate  := l_contra_yield_rate;
     end if;

     r_mm_in.P_FUTURE_VAL := rec.fair_value;
     r_mm_in.P_INDICATOR  := C_YIELD_IND;
     r_mm_in.P_RATE       := l_sob_yield_rate;
     r_mm_in.P_DAY_COUNT  := l_no_of_days;
     r_mm_in.P_ANNUAL_BASIS:= l_year_basis;
     XTR_MM_COVERS.present_value(r_mm_in, r_mm_out);
     l_end_fv   := round(r_mm_out.P_PRESENT_VAL, l_round);
   end if;

  rec.fair_value := l_end_fv;
  unrel_pl_value := rec.fair_value - l_begin_fv;

  if currency_gl is NULL or p_complete_flag = 'N' then
     l_hedge_flag := 'N';
  end if;

  XTR_REVL_UNREAL_LOG(rec, unrel_pl_value, 0, l_end_fv, unrel_pl_value,
                      currency_gl, r_rd, retcode, l_hedge_flag);


EXCEPTION
  when XTR_MARKET_DATA_P.e_mdcs_no_data_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_MARKET');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_MARKETDATASET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
  when XTR_MARKET_DATA_P.e_mdcs_no_curve_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_CURVE');
      FND_MESSAGE.set_token('MARKET', rec.market_data_set);
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_CURVEMARKET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
     set_err_log(retcode);
     FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_RATE_REF');
     FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
     FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
     FND_MESSAGE.SET_TOKEN('ISSUE_CODE', rec.contract_code);
     l_buff := FND_MESSAGE.GET;
     fnd_file.put_line(fnd_file.log, l_buff);
    end if;
END xtr_hedge_fwd_rate;

---------------------------------------------------------------
/****************************************************************/
/* This procedure returns either previous currency exchange rate*/
/* for GL rate pricing model or previous forward-forward rate   */
/* for forward rate pricing model.                              */
/****************************************************************/
PROCEDURE xtr_get_prev_fv_rate(rec IN OUT NOCOPY xtr_revl_rec,
			     r_prev_hedge OUT NOCOPY xtr_prev_hedge) IS

cursor C_GL_RATE is
select fair_value,  exchange_rate_one, cumm_gain_loss_amount
from XTR_REVALUATION_DETAILS
where deal_no = rec.deal_no
and company_code = rec.company_code
and period_to = (select max(period_to)
                 from xtr_revaluation_details
                 where company_code = rec.company_code
                 and deal_no = rec.deal_no
		 and nvl(realized_flag, 'N') = 'N');

Cursor C_FWD_RATE is
select fair_value, reval_rate, CTR_CURR_SOB_CURR_FWD_RATE,
        cumm_gain_loss_amount
from XTR_REVALUATION_DETAILS
where deal_no = rec.deal_no
and company_code = rec.company_code
and period_to = (select max(period_to)
                 from xtr_revaluation_details
                 where company_code = rec.company_code
                 and deal_no = rec.deal_no
		 and nvl(realized_flag, 'N') = 'N');

l_gl_rate       NUMBER;
l_fwd_rate      NUMBER;
l_sob_fwd_rate  NUMBER;
l_fv		NUMBER;
l_cum_pl	NUMBER;

BEGIN
 if (rec.deal_type = 'HEDGE' and rec.pricing_model = 'TIME') or
    (rec.deal_type = 'FX' and rec.pricing_model = 'FX_GL') then -- GL rate model
     Open C_GL_RATE;
     Fetch C_GL_RATE into l_fv, l_gl_rate, l_cum_pl;
     Close C_GL_RATE;

     r_prev_hedge.fair_value := nvl(l_fv, 0);
     r_prev_hedge.rate       := l_gl_rate;
     r_prev_hedge.cum_pl     := l_cum_pl;

 Elsif (rec.deal_type = 'HEDGE' and rec.pricing_model = 'NONE') or
    (rec.deal_type = 'FX' and rec.pricing_model = 'FX_FORWARD') then -- Forward rate model
     Open C_FWD_RATE;
     Fetch C_FWD_RATE into l_fv, l_fwd_rate, l_sob_fwd_rate, l_cum_pl;
     Close C_FWD_RATE;

     r_prev_hedge.fair_value := nvl(l_fv, 0);
     r_prev_hedge.rate       := l_fwd_rate;
     r_prev_hedge.sob_rate   := l_sob_fwd_rate;
     r_prev_hedge.cum_pl     := l_cum_pl;
 end if;

END xtr_get_prev_fv_rate;

--------------------------------------------------------
/*********************************************************/
/* This procedure returns fair value for deal type FXO   */
/*********************************************************/
PROCEDURE xtr_revl_fv_fxo(
            rec IN xtr_revl_rec,
 	    p_spot_rate IN NUMBER,
            p_put_price IN NUMBER,
            p_call_price IN NUMBER,
            fair_value OUT NOCOPY NUMBER) IS

l_ref_ccy VARCHAR2(15);
l_counter_ccy VARCHAR2(15);
l_base_ccy VARCHAR2(15);
l_contra_ccy VARCHAR2(15);
l_deal_base_ccy VARCHAR2(15);
l_cap_floor VARCHAR2(5);
l_base_amt NUMBER;
l_side VARCHAR2(5);
l_ccy VARCHAR2(15);
l_dummy BOOLEAN;
retcode  NUMBER;

begin

-- determine counter currency and base amount
  l_base_ccy := rec.currencya;
  l_contra_ccy := rec.currencyb;

-- get base contra ccy here
  xtr_get_base_contra(l_base_ccy, l_contra_ccy, l_dummy);

  if (rec.deal_subtype = 'BUY' and rec.cap_or_floor = 'C') or
  (rec.deal_subtype = 'SELL' and rec.cap_or_floor = 'P')then
    l_ref_ccy     := rec.currencya;
    l_counter_ccy := rec.currencyb;
  else
    l_ref_ccy     := rec.currencyb;
    l_counter_ccy := rec.currencya;
  end if;

  if (l_ref_ccy <> l_base_ccy) then
-- turn around the floor cap
    if (rec.cap_or_floor = 'C') then
      l_cap_floor := 'P';
    else
      l_cap_floor := 'C';
    end if;
  else
    l_cap_floor := rec.cap_or_floor;
  end if;

  if (l_base_ccy = rec.currencya) then
    l_base_amt := rec.face_value;       -- deal buy amount
  else
    l_base_amt := rec.fxo_sell_ref_amount; -- deal sell amount
  end if;

  if (l_cap_floor = 'C') then  -- fair value in contra ccy
    fair_value := p_call_price * l_base_amt;
  else
    fair_value := p_put_price * l_base_amt;
  end if;

  if (rec.reval_ccy <> l_contra_ccy) then --fair value in premium ccy
      fair_value := fair_value/p_spot_rate;
  end if;

  if rec.deal_subtype = 'SELL' then
     fair_value := fair_value * (-1);
  end if;

end xtr_revl_fv_fxo;
--------------------------------------------------------
/*********************************************************/
/* This procedure returns reval rate for deal type FXO   */
/*********************************************************/
PROCEDURE xtr_revl_getprice_fxo(
            rec IN OUT NOCOPY xtr_revl_rec,
	    p_spot_rate IN OUT NOCOPY NUMBER,
            p_put_price IN OUT NOCOPY NUMBER,
            p_call_price IN OUT NOCOPY NUMBER) IS
l_buf Varchar2(500);
l_no_of_days NUMBER;
l_year NUMBER;
l_base_ccy VARCHAR2(15);
l_contra_ccy VARCHAR2(15);
l_side VARCHAR2(5);
l_dummy BOOLEAN;
r_md_in    xtr_market_data_p.md_from_set_in_rec_type;
r_md_out   xtr_market_data_p.md_from_set_out_rec_type;
l_volatility    NUMBER;
l_trans_rate_buy  NUMBER;
l_trans_rate_sell NUMBER;
l_trans_rate    NUMBER;
l_num_year	NUMBER;
l_market_set    VARCHAR2(30);
l_fwd_rate      NUMBER;
l_base_rate     NUMBER;
l_contra_rate   NUMBER;
r_fx_in	 	XTR_FX_FORMULAS.GK_OPTION_CV_IN_REC_TYPE;
r_fx_out	XTR_FX_FORMULAS.GK_OPTION_CV_OUT_REC_TYPE;
r_err_log err_log; -- record type
retcode		NUMBER;

BEGIN
    l_market_set := rec.MARKET_DATA_SET;
    xtr_revl_get_mds(l_market_set, rec);

  if rec.pricing_model <> C_P_MODEL_GARMAN then
    return;
  end if;

  if rec.expiry_date <= rec.revldate and rec.status_code = 'CURRENT' then
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_DEAL_EXPIRY');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
  Else
    XTR_CALC_P.calc_days_run(rec.revldate, rec.expiry_date,
    rec.year_calc_type, l_no_of_days, l_year);

    l_num_year := l_no_of_days/l_year;

-- determine counter currency and base amount
  l_base_ccy   := rec.currencya;        -- deal buy currency
  l_contra_ccy := rec.currencyb;        -- deal sell currency

-- get base contra ccy here
  xtr_get_base_contra(l_base_ccy, l_contra_ccy, l_dummy);

  if(rec.deal_subtype = 'BUY') then
    l_side := 'A';
  else
    l_side := 'B';
  end if;

-- Get volatility rate
  xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
      C_VOLATILITY_IND, rec.revldate, rec.expiry_date,
      l_base_ccy, l_contra_ccy, rec.year_calc_type,
      C_INTERPOL_LINER, l_side, rec.batch_id, NULL);

  XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
  l_volatility := r_md_out.p_md_out;

-- return a interest rate for Buy currency
  l_side := 'A';
    xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
      C_YIELD_IND, rec.revldate, rec.expiry_date,
      rec.currencya, l_contra_ccy, rec.year_calc_type,
      C_INTERPOL_LINER, l_side, rec.batch_id, NULL);
  XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
  l_trans_rate_buy := r_md_out.p_md_out;

-- return a interest rate for Sell currency
  l_side := 'B';

  xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
      C_YIELD_IND, rec.revldate, rec.expiry_date,
      rec.currencyb, l_contra_ccy, rec.year_calc_type,
      C_INTERPOL_LINER, l_side, rec.batch_id, NULL);
  XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
  l_trans_rate_sell := r_md_out.p_md_out;

-- get FX spot rate
  if(rec.currencyb = l_base_ccy) then
    l_side := 'B';
  else
    l_side := 'A';
  end if;

  xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
      C_SPOT_RATE_IND, rec.start_date, NULL,
      l_base_ccy, l_contra_ccy, rec.year_calc_type,
      C_INTERPOL_LINER, l_side, rec.batch_id, NULL);
  XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
  p_spot_rate := r_md_out.p_md_out;

  if (l_base_ccy = rec.currencya) then
    l_base_rate := l_trans_rate_buy;
    l_contra_rate := l_trans_rate_sell;
  else
    l_base_rate := l_trans_rate_sell;
    l_contra_rate := l_trans_rate_buy;
  end if;

  r_fx_in.p_spot_date    := rec.revldate;
  r_fx_in.p_maturity_date:= rec.expiry_date;
  r_fx_in.p_rate_dom     := l_contra_rate;
  r_fx_in.p_day_count_basis_dom := rec.year_calc_type;
  r_fx_in.p_rate_for     := l_base_rate;
  r_fx_in.p_day_count_basis_for := rec.year_calc_type;
  r_fx_in.p_spot_rate    := p_spot_rate;
  r_fx_in.p_strike_rate  := rec.transaction_rate;
  r_fx_in.p_volatility   := l_volatility;

  XTR_FX_FORMULAS.fx_gk_option_price_cv(r_fx_in, r_fx_out);
  p_call_price  := r_fx_out.p_CALL_PRICE;
  p_put_price   := r_fx_out.p_PUT_PRICE;
  l_fwd_rate    := r_fx_out.p_FX_FWD_RATE;
/*
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_getprice_fxo: ' || 'fx_gk_option_price_cv');
     xtr_risk_debug_pkg.dlog ('xtr_revl_getprice_fxo: ' || 'deal no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_fxo: ' || 'spot date', r_fx_in.p_spot_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_fxo: ' || 'mature date', r_fx_in.p_maturity_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_fxo: ' || 'l_base_rate', r_fx_in.p_rate_dom);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_fxo: ' || 'l_contra_rate', r_fx_in.p_rate_for);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_fxo: ' || 'p_spot_rate', r_fx_in.p_spot_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_fxo: ' || 'l_trans_rate', r_fx_in.p_strike_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_fxo: ' || 'l_volatility', r_fx_in.p_volatility);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_fxo: ' || 'p_call_price', p_call_price);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_fxo: ' || 'p_put_price', p_put_price);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_fxo: ' || 'l_fwd_rate', l_fwd_rate);
     xtr_risk_debug_pkg.dpop('xtr_revl_getprice_fxo: ' || 'fx_gk_option_price_cv');
  END IF; */

 End If;
 rec.reval_rate := l_fwd_rate;

EXCEPTION
  when XTR_MARKET_DATA_P.e_mdcs_no_data_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_MARKET');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_MARKETDATASET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when XTR_MARKET_DATA_P.e_mdcs_no_curve_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_CURVE');
      FND_MESSAGE.set_token('MARKET', rec.market_data_set);
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_CURVEMARKET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_getprice_fxo');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
end xtr_revl_getprice_fxo;
--------------------------------------------------------
/*********************************************************/
/* This procedure returns fair value for deal type NI    */
/*********************************************************/
PROCEDURE xtr_revl_fv_ni(
            rec IN xtr_revl_rec,
            fair_value IN OUT NOCOPY NUMBER,
            p_revl_rate IN OUT NOCOPY NUMBER) IS
l_buf Varchar2(500);
l_spot_date      DATE;
l_start_date     DATE;
l_end_date	 DATE;
l_market_set     VARCHAR2(30);
l_discount_date_method VARCHAR2(30);
l_side        VARCHAR2(5);
l_rate_type   VARCHAR2(1);
r_md_in       xtr_market_data_p.md_from_set_in_rec_type;
r_md_out      xtr_market_data_p.md_from_set_out_rec_type;
r_present_in  XTR_MM_COVERS.presentValue_in_rec_type;
r_present_out XTR_MM_COVERS.presentValue_out_rec_type;
l_day           NUMBER;
l_year          NUMBER;
l_int_rate	NUMBER;
l_margin        NUMBER;
l_parcel_amt    NUMBER;
l_disc_yield_basis VARCHAR2(8);
p_indicator     VARCHAR2(2);
r_err_log       err_log; -- record type
retcode		NUMBER;

begin
  select PARAMETER_VALUE_CODE into l_discount_date_method
  from xtr_company_parameters
  where COMPANY_CODE = rec.company_code and
      PARAMETER_CODE = C_FUTURE_DATE_NI; -- 'REVAL_FDNDR'

--  select BALANCE_OUT - INTEREST
  select BALANCE_OUT
  into l_parcel_amt
  from xtr_rollover_transactions
  where DEAL_NUMBER = rec.deal_no and
  TRANSACTION_NUMBER = rec.trans_no;

  select MARGIN, CALC_BASIS
  into l_margin, l_disc_yield_basis
  from XTR_DEALS
  where deal_no = rec.deal_no;

  l_int_rate   := rec.transaction_rate;
  l_market_set := rec.MARKET_DATA_SET;
  xtr_revl_get_mds(l_market_set, rec);

  if rec.pricing_model <> C_P_MODEL_DIS then
    if rec.pricing_model is null then
       raise e_invalid_price_model;
    else
      fair_value := null;
      return;
    end if;
  end if;

-- Only reval BUY, SHORT, and ISSUE, not COVER and SELL
  if(rec.deal_subtype = 'BUY') then
    l_side := 'B';
  elsif rec.deal_subtype in ('SHORT', 'ISSUE') then
    l_side := 'A';
  else
    raise e_invalid_deal_subtype;
  end if;

  if rec.start_date <= rec.revldate then
    l_rate_type := 'Y';  --yield
  else
    l_rate_type := 'F';
  end if;
  l_start_date := rec.start_date;
  l_spot_date := rec.revldate;
  l_end_date  := rec.maturity_date;

  xtr_revl_getrate_ni(rec, l_rate_type, l_market_set,
        rec.batch_id, rec.currencya, l_spot_date, l_start_date,
    	rec.maturity_date, rec.year_calc_type, l_side, l_disc_yield_basis,
        l_int_rate, l_day, l_year);

  -- If use overwrite rate, we do not need to take calcualted rate
  If p_revl_rate is null then
     p_revl_rate := l_int_rate + nvl(l_margin, 0)/100;
  End If;

  if l_disc_yield_basis = C_CALC_BASIS_D then  -- 'DISCOUNT'
     p_indicator := C_DISCOUNT_IND;  -- 'DR'
  else     -- YIELD
     p_indicator := C_YIELD_IND;     -- 'Y'
  end if;

  r_present_in.p_indicator   := p_indicator;
  r_present_in.p_future_val  := l_parcel_amt;
  r_present_in.p_rate        := p_revl_rate;
  r_present_in.p_day_count   := l_day;
  r_present_in.p_annual_basis := l_year;
  XTR_MM_COVERS.present_value(r_present_in, r_present_out);

  fair_value := r_present_out.p_present_val;

/* If trade date accounting is being used, the company parameter
is set to discount back to revaluation date, and the revaluation
date is < the deal start date, we have to perform another
calculation to obtain the fair value of the deal on the date
of revaluation. */
  if (l_discount_date_method = 'YRSRD' and rec.revldate < rec.start_date) then
  	l_rate_type  := 'Y';  --yield
    	l_start_date := rec.revldate;
    	l_spot_date  := rec.revldate;
    	l_end_date   := rec.start_date;
    	xtr_revl_getrate_ni(rec, l_rate_type, l_market_set,
      	rec.batch_id, rec.currencya, l_spot_date, l_start_date,
      	l_end_date, rec.year_calc_type, l_side, l_disc_yield_basis,
      	l_int_rate, l_day, l_year);

  -- If use overwrite rate, we do not need to take calcualted rate
     If p_revl_rate is null then
        p_revl_rate := l_int_rate;
     End if;

     if l_disc_yield_basis = C_CALC_BASIS_D then  -- 'DISCOUNT'
        p_indicator := C_DISCOUNT_IND;  -- 'DR'
     else     -- YIELD
        p_indicator := C_YIELD_IND;     -- 'Y'
     end if;
     r_present_in.p_indicator   := p_indicator;
     r_present_in.p_future_val  := l_parcel_amt;
     r_present_in.p_rate        := p_revl_rate;
     r_present_in.p_day_count   := l_day;
     r_present_in.p_annual_basis := l_year;
     XTR_MM_COVERS.present_value(r_present_in, r_present_out);

     fair_value := r_present_out.p_present_val;
  end if;

  if rec.deal_subtype in ('SHORT', 'ISSUE') then
     fair_value := fair_value * (-1);
  end if;

EXCEPTION
    when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_fv_ni');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
end xtr_revl_fv_ni;
--------------------------------------------------------
/*********************************************************/
/* This procedure returns reval rate for deal type NI    */
/*********************************************************/
PROCEDURE xtr_revl_getrate_ni(
            rec IN xtr_revl_rec,
            p_rate_type IN VARCHAR2,
            p_market_set IN VARCHAR2,
            p_batch_id IN NUMBER,
            p_ccy IN VARCHAR2,
            p_spot_date IN DATE,
            p_start_date IN DATE,
            p_end_date IN DATE,
            p_day_count IN VARCHAR2,
            p_side IN VARCHAR2,
            p_deal_basis IN VARCHAR2,
            p_int_rate OUT NOCOPY NUMBER,
            p_day OUT NOCOPY NUMBER,
            p_year OUT NOCOPY NUMBER) IS
l_buf Varchar2(500);
l_ind     VARCHAR2(1);
l_date    DATE;
r_md_in   xtr_market_data_p.md_from_set_in_rec_type;
r_md_out  xtr_market_data_p.md_from_set_out_rec_type;
r_err_log err_log; -- record type
retcode	NUMBER;

begin
  if p_rate_type = 'Y' then
    l_ind := C_YIELD_IND;
  else
    l_ind := NULL; -- for forward rate
  end if;

  if p_spot_date > p_start_date then
    l_date := p_spot_date;
  else
    l_date := p_start_date;
  end if;

  xtr_revl_mds_init(r_md_in, p_market_set, C_SOURCE,
      l_ind, l_date, p_end_date,
      p_ccy, NULL, p_day_count,
      C_INTERPOL_LINER, p_side, p_batch_id, NULL);
  if l_ind is not NULL then
    XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
    p_int_rate := r_md_out.p_md_out;
  else
    xtr_revl_getprice_fwd(rec, FALSE, p_int_rate); -- get forward forward rate
  end if;

  XTR_CALC_P.calc_days_run(l_date, p_end_date,
    p_day_count, p_day, p_year);

  if p_deal_basis = 'DISCOUNT' then
    XTR_RATE_CONVERSION.yield_to_discount_rate(
      p_int_rate, p_day, p_year, p_int_rate);
  end if;

EXCEPTION
  when XTR_MARKET_DATA_P.e_mdcs_no_data_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_MARKET');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_MARKETDATASET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when XTR_MARKET_DATA_P.e_mdcs_no_curve_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_CURVE');
      FND_MESSAGE.set_token('MARKET', rec.market_data_set);
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_CURVEMARKET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_getrate_ni');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;

end xtr_revl_getrate_ni;
-------------------------------------------------------------
/*********************************************************/
/* This procedure returns reval rate for deal type BOND  */
/*********************************************************/
PROCEDURE xtr_revl_getprice_bond(
           rec IN xtr_revl_rec,
           p_bond_clean_price OUT NOCOPY NUMBER) IS
l_bond_issue    XTR_DEALS.bond_issue%TYPE;
l_ric_code      XTR_BOND_ISSUES.ric_code%TYPE;
l_margin	XTR_DEALS.margin%TYPE;
l_coupon_action XTR_DEALS.coupon_action%TYPE;
l_side		VARCHAR2(1);
l_bond_yield_m  NUMBER;
l_yield		NUMBER;
l_accrued_interest NUMBER;
l_settle_date   DATE;
l_dirty_price   NUMBER;
l_market_set   VARCHAR2(30);
l_clean_price   NUMBER;
r_md_in     xtr_market_data_p.md_from_set_in_rec_type;
r_md_out    xtr_market_data_p.md_from_set_out_rec_type;
r_err_log err_log; -- record type
retcode		NUMBER;
l_buf VARCHAR2(300);
l_buff Varchar2(500);

Begin
  -- We only reval BOND when the pricing model = 'MARKET'
  if rec.pricing_model <> C_P_MODEL_MARKET then
     return;
  end if;

  If rec.revldate <=  rec.maturity_date then
     l_settle_date := rec.revldate;
  Else
     l_settle_date := rec.maturity_date;
  End if;

  select MARGIN, COUPON_ACTION
  into l_margin, l_coupon_action
  from XTR_DEALS
  where DEAL_NO = rec.deal_no;

  select RIC_CODE
  into l_ric_code
  from XTR_BOND_ISSUES
  where bond_issue_code = rec.contract_code;

  l_market_set := rec.MARKET_DATA_SET;
  xtr_revl_get_mds(l_market_set, rec);

  if rec.deal_subtype = 'BUY' then
     l_side := 'B';
  elsif rec.deal_subtype = 'ISSUE' then
     l_side := 'A';
  else
    raise e_invalid_deal_subtype;
  end if;

  /*** Get clean price from market data set  ***/
    xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
        C_BOND_IND, rec.revldate, rec.revldate, rec.currencya, NULL,
        NULL, NULL, l_side, rec.batch_id, l_ric_code);
     XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
     p_bond_clean_price    := r_md_out.p_md_out;

/*
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_getprice_bond: ' || 'BOND fair value');
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_bond: ' || 'batch_id',rec.batch_id);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_bond: ' || 'market data set is '||l_market_set);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_bond: ' || 'reval date', rec.revldate);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_bond: ' || 'l_ric_code is ', l_ric_code);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_bond: ' || 'p_bond_clean_price is ', p_bond_clean_price);
     xtr_risk_debug_pkg.dpop('xtr_revl_getprice_bond: ' || 'BOND fair value');
  END IF;
*/
  If l_margin is not null then
     -- margin involved, convert bond price to YTM. Add margin to result.
     -- Then convert the sum back to a bond price
     XTR_CALC_P.calculate_bond_price_yield (
	p_bond_issue_code	=> rec.contract_code,
    	p_settlement_date	=> rec.revldate,
	p_ex_cum_next_coupon	=> l_coupon_action,
	p_calculate_yield_or_price => 'Y',
	p_yield			=> l_yield,
	p_accrued_interest	=> l_accrued_interest,
	p_clean_price		=> p_bond_clean_price,
	p_dirty_price		=> l_dirty_price,
	p_input_or_calculator	=> 'I',
	p_commence_date		=> null,
	p_maturity_date		=> null,
	p_prev_coupon_date	=> null,
	p_next_coupon_date	=> null,
	p_calc_type		=> null,
	p_year_calc_type	=> null,
	p_accrued_int_calc_basis=> null,
	p_coupon_freq		=> null,
	p_calc_rounding		=> null,
	p_price_rounding	=> null,
	p_price_round_type	=> null,
	p_yield_rounding	=> null,
	p_yield_round_type	=> null,
	p_coupon_rate		=> null,
	p_num_coupons_remain	=> null
     );
/*
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_getprice_bond: ' || 'BOND fair value');
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_bond: ' || 'batch_id',rec.batch_id);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_bond: ' || 'l_bond_issue is ', l_bond_issue);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_bond: ' || 'reval date', rec.revldate);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_bond: ' || 'l_yield is ', l_yield);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_bond: ' || 'l_accrued_interest is ', l_accrued_interest);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_bond: ' || 'p_bond_clean_price', p_bond_clean_price);
     xtr_risk_debug_pkg.dlog('xtr_revl_getprice_bond: ' || 'l_dirty_price is ', l_dirty_price);
     xtr_risk_debug_pkg.dpop('xtr_revl_getprice_bond: ' || 'BOND fair value');
  END IF;
*/
	/* Add in margin  */
     l_bond_yield_m := l_yield + nvl(l_margin,0)/100;

	/* Convert yield with margin back to clean price  */
     XTR_CALC_P.calculate_bond_price_yield (
        p_bond_issue_code       => rec.contract_code,
        p_settlement_date       => l_settle_date,
        p_ex_cum_next_coupon    => l_coupon_action,
        p_calculate_yield_or_price => 'P',
        p_yield                 => l_bond_yield_m,
        p_accrued_interest      => l_accrued_interest,
        p_clean_price           => l_clean_price,
        p_dirty_price           => l_dirty_price,
        p_input_or_calculator   => 'I',
        p_commence_date         => null,
        p_maturity_date         => null,
        p_prev_coupon_date      => null,
        p_next_coupon_date      => null,
        p_calc_type             => null,
        p_year_calc_type        => null,
        p_accrued_int_calc_basis=> null,
        p_coupon_freq           => null,
        p_calc_rounding         => null,
        p_price_rounding        => null,
        p_price_round_type      => null,
        p_yield_rounding        => null,
        p_yield_round_type      => null,
        p_coupon_rate           => null,
        p_num_coupons_remain    => null
     );
     p_bond_clean_price := l_clean_price;
  End If;

EXCEPTION
  when XTR_MARKET_DATA_P.e_mdcs_no_data_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_MARKET');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_MARKETDATASET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
  when XTR_MARKET_DATA_P.e_mdcs_no_curve_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_CURVE');
      FND_MESSAGE.set_token('MARKET', rec.market_data_set);
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_CURVEMARKET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
     set_err_log(retcode);
     FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_RATE_REF');
     FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
     FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
     FND_MESSAGE.SET_TOKEN('ISSUE_CODE', rec.contract_code);
     l_buff := FND_MESSAGE.GET;
     fnd_file.put_line(fnd_file.log, l_buff);
    end if;
End xtr_revl_getprice_bond;
-------------------------------------------------------------
/*********************************************************/
/* This procedure returns fair value for deal type BOND  */
/*********************************************************/
PROCEDURE xtr_revl_fv_bond(
           rec IN OUT NOCOPY xtr_revl_rec,
           p_clean_price IN NUMBER,
           fair_value OUT NOCOPY NUMBER) IS

Cursor c_bond_alloc is
Select bond.deal_no, bond.cross_ref_no, bond.face_value, bond.initial_fair_value,
       bond.amc_real_gain_loss, bond.mtm_real_gain_loss, bond.cross_ref_clean_px,
       decode(cp.parameter_value_code, 'TRADE', bond.cross_ref_deal_date,
       bond.cross_ref_start_date) resale_rec_date
from XTR_BOND_ALLOC_DETAILS BOND,
     XTR_COMPANY_PARAMETERS CP,
     XTR_DEALS D
Where bond.deal_no = rec.deal_no
and bond.deal_no = d.deal_no
and bond.batch_id is null
and cp.company_code = d.company_code
and cp.parameter_code = 'ACCNT_TSDTM'
and decode(cp.parameter_value_code, 'TRADE', bond.cross_ref_deal_date,
	   bond.cross_ref_start_date) <= rec.revldate;
l_buf Varchar2(500);
bo_rec	       xtr_bond_rec;   -- BOND record type
l_pre_batch    NUMBER;
l_first        BOOLEAN;
l_resale       BOOLEAN := null;  -- Indicate if the record is result of resale
l_overwrite    BOOLEAN := FALSE;
l_rounding     NUMBER;
r_err_log       err_log; -- record type
retcode		NUMBER;

Begin
 select ROUNDING_FACTOR
 into l_rounding
 from XTR_MASTER_CURRENCIES_V
 where currency = rec.currencya;

 bo_rec.batch_id  := rec.batch_id;
 xtr_first_reval(rec, l_first);
 if l_first = TRUE then  -- first time reval
    bo_rec.maturity_face_value := rec.face_value;   -- xtr_deals.maturity_amount
    bo_rec.start_face_value := rec.face_value;
    bo_rec.cum_unrel_gl := 0;
    bo_rec.cum_unrel_gl_bal := 0;
    bo_rec.start_fair_value := rec.init_fv;
    bo_rec.pre_gl_rate := null;
 else  -- not the first reval, got info from previous reval batch
    l_pre_batch := xtr_get_pre_batchid(rec);
    select fair_value, face_value, exchange_rate_one, cumm_gain_loss_amount
    into bo_rec.start_fair_value, bo_rec.maturity_face_value,
	 bo_rec.pre_gl_rate, bo_rec.cum_unrel_gl
    from XTR_REVALUATION_DETAILS
    where batch_id = l_pre_batch
    and deal_no = rec.deal_no
    and nvl(realized_flag, 'N') = 'N'
    and transaction_no = 1;

    bo_rec.start_face_value := bo_rec.maturity_face_value;
    bo_rec.cum_unrel_gl_bal := bo_rec.cum_unrel_gl;
 end if;

 Open C_BOND_ALLOC;
 Fetch C_BOND_ALLOC into bo_rec.deal_no, bo_rec.cross_ref_no,
       bo_rec.face_value, bo_rec.init_fv, bo_rec.amc_real,
       bo_rec.mtm_real, bo_rec.clean_px, bo_rec.resale_rec_date;
 While C_BOND_ALLOC%FOUND loop
    l_resale  := TRUE;
    XTR_REVL_BOND_REALAMC(rec, bo_rec);
    XTR_REVL_BOND_REALMTM(rec, bo_rec, l_resale);
    XTR_REVL_BOND_UNREAL(rec, bo_rec, l_resale, l_overwrite);

    -- Update xtr_bond_alloc_details record so this record will not be
    -- eligible for next time
    Update XTR_BOND_ALLOC_DETAILS
    Set batch_id = rec.batch_id
    where deal_no = bo_rec.deal_no
    and cross_ref_no = bo_rec.cross_ref_no;

    Fetch C_BOND_ALLOC into bo_rec.deal_no, bo_rec.cross_ref_no,
    bo_rec.face_value, bo_rec.init_fv, bo_rec.amc_real,
    bo_rec.mtm_real, bo_rec.clean_px, bo_rec.resale_rec_date;
 End loop;

 if bo_rec.maturity_face_value = 0 then
    update XTR_DEALS
    set last_reval_batch_id = rec.batch_id
    where deal_no = rec.deal_no;
 else
    l_resale   := FALSE;
    if rec.maturity_date <= rec.revldate then -- deal matured
       XTR_REVL_BOND_REALMTM(rec, bo_rec, l_resale);

       -- Bug 2990046 - Issue #6.
       -- Corrected oversight from original flow logic to update last batch id
       -- of a deal which has matured, making it ineligible for future revaluation batch.

       update XTR_DEALS
       set last_reval_batch_id = rec.batch_id
       where deal_no = rec.deal_no;

       -- End 2990046 - Issue #6 additions.

    end if;
    -- Only this part allow overwritten from form
    if p_clean_price is not null then  -- user provide overwrite Rate
       rec.reval_rate := p_clean_price;
       l_overwrite    := TRUE;
    end if;
    XTR_REVL_BOND_UNREAL(rec, bo_rec, l_resale, l_overwrite);
    fair_value := rec.fair_value;
 end if;

EXCEPTION
    when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_fv_bond');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
End;
--------------------------------------------------------
/*********************************************************/
/* This procedure insert value to revaluation details    */
/* table with BOND amount type 'REALAMC' information     */
/*********************************************************/
PROCEDURE xtr_revl_bond_realamc(rec IN OUT NOCOPY xtr_revl_rec,
                                bo_rec IN xtr_bond_rec) IS
l_buf Varchar2(500);
r_rd XTR_REVALUATION_DETAILS%rowtype;
l_begin_fv	NUMBER;
rel_pl_value 	NUMBER;
fv_sob_amt	NUMBER;
rel_sob_gl	NUMBER;
unrel_sob_gl	NUMBER;
currency_gl	NUMBER;
l_rc 	        NUMBER;
r_err_log err_log; -- record type
retcode 	NUMBER;

Begin
  rec.init_fv      := bo_rec.init_fv;
  rec.trans_no     := bo_rec.cross_ref_no;
  rec.face_value   := bo_rec.face_value;
  rec.fair_value   := bo_rec.init_fv + bo_rec.amc_real;
  rec.period_start := rec.eligible_date;
  rec.period_end   := bo_rec.resale_rec_date;
  rec.effective_date:= bo_rec.resale_rec_date;
  r_rd.transaction_period := rec.period_end - rec.period_start;
  r_rd.effective_days := rec.period_end - rec.period_start;
  r_rd.amount_type := C_REALAMC;   -- 'REALAMC'
  rec.reval_ccy    := rec.currencya;
  rec.reval_rate   := bo_rec.clean_px;
  rel_pl_value     := bo_rec.amc_real;

  If rec.reval_ccy = rec.sob_ccy then
     rec.reval_ex_rate_one := 1;
     rec.deal_ex_rate_one  := 1;
     currency_gl := 0;
     fv_sob_amt  := rec.fair_value;
     rel_sob_gl  := rel_pl_value;
  Else
     xtr_revl_exchange_rate(rec, retcode);
     xtr_revl_get_curr_gl(rec, null, rel_pl_value, fv_sob_amt,
	rel_sob_gl, unrel_sob_gl, currency_gl);
  End if;

  xtr_revl_real_log(rec, rel_pl_value, fv_sob_amt, rel_sob_gl, currency_gl, r_rd, retcode);

EXCEPTION
    when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_bond_realamc');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
End xtr_revl_bond_realamc;
-------------------------------------------------------------
/*********************************************************/
/* This procedure insert value to revaluation details    */
/* table with BOND amount type 'REALMTM' information     */
/*********************************************************/
PROCEDURE xtr_revl_bond_realmtm(rec IN OUT NOCOPY xtr_revl_rec,
                                bo_rec IN xtr_bond_rec,
				p_resale IN BOOLEAN) IS
l_buf Varchar2(500);
r_rd XTR_REVALUATION_DETAILS%rowtype;
l_begin_fv      NUMBER;
l_bond_init_fv  NUMBER;
rel_pl_value    NUMBER;
fv_sob_amt      NUMBER;
rel_sob_gl      NUMBER;
unrel_sob_gl    NUMBER;
currency_gl     NUMBER;
l_rc            NUMBER;
l_rate0         NUMBER;
l_rate1         NUMBER;
l_round         NUMBER;
r_err_log err_log; -- record type
retcode		NUMBEr;

l_full_init_fv	NUMBER := 0; 	-- Bug 3046471 addition.

Begin
 select rounding_factor
 into l_round
 from xtr_master_currencies_v
 where currency = rec.reval_ccy;

 r_rd.amount_type := 'REAL';   -- 'REALMTM'
 rec.reval_ccy    := rec.currencya;

 If p_resale = TRUE then  -- record is a result of resale
    rec.trans_no     := bo_rec.cross_ref_no;
    rec.face_value   := bo_rec.face_value;
    rec.init_fv      := bo_rec.init_fv;

    -- 2879858.  Bond Repurchase Project.

    If (rec.deal_subtype in ('ISSUE','SHORT')) then
       rec.fair_value := -rec.face_value * bo_rec.clean_px / 100;
    Else
       rec.fair_value := rec.face_value * bo_rec.clean_px / 100;
    End If;

    -- End 2879858.

    rec.period_start := rec.effective_date;
    rec.period_end   := bo_rec.resale_rec_date;
    rec.effective_date:= bo_rec.resale_rec_date;
    r_rd.transaction_period := rec.period_end - rec.period_start;
    rec.reval_rate   := bo_rec.clean_px;
    rel_pl_value     := bo_rec.mtm_real;
 Else  -- record not a result of resale. Deal is mature
    rec.trans_no     := 1;
    rec.period_start := rec.eligible_date;
    rec.period_end   := rec.maturity_date;
    rec.effective_date:= rec.maturity_date;
    r_rd.transaction_period := rec.period_end - rec.period_start;
    rec.reval_rate   := 100;
    rec.fair_value   := rec.fxo_sell_ref_amount; -- xtr_deals.maturity_balance_amount

    if rec.deal_subtype in ('SHORT', 'ISSUE') then
	rec.fair_value := rec.fair_value * (-1);
    end if;

    -- Bug 3046471 additions.
    -- Re-fetch initial fair value for full deal face value to properly calculate
    -- last period's realized MTM gain/loss at time of maturity.

    Select nvl(initial_fair_value,rec.fair_value)
      into l_full_init_fv
      from xtr_deals
     where deal_no = rec.deal_no;

    -- End 3046471 additions.

    if rec.face_value = rec.fxo_sell_ref_amount then
       -- Deal is not resale for the whole period. Hold until maturity.
--3046471       l_begin_fv  := rec.init_fv;
       l_begin_fv := l_full_init_fv;		-- 3046471.
    else
       select sum(initial_fair_value)		-- 2879585.  Correction from initial design.
       into l_bond_init_fv
       from xtr_bond_alloc_details
       where deal_no = rec.deal_no;
--3046471       l_begin_fv  := rec.init_fv - l_bond_init_fv;
       l_begin_fv := l_full_init_fv - l_bond_init_fv;	-- 3046471.
    end if;
    rec.face_value   := rec.fxo_sell_ref_amount; -- xtr_deals.maturity_balance_amount
    rel_pl_value     := rec.fair_value - l_begin_fv;
 End if;

  If rec.reval_ccy = rec.sob_ccy then
     rec.reval_ex_rate_one := 1;
     rec.deal_ex_rate_one  := 1;
     currency_gl := 0;
     fv_sob_amt  := rec.fair_value;
     rel_sob_gl  := rel_pl_value;
  Else
   if p_resale = TRUE then
      xtr_revl_exchange_rate(rec, retcode);
      xtr_revl_get_curr_gl(rec, null, rel_pl_value, fv_sob_amt,
                          rel_sob_gl, unrel_sob_gl, currency_gl);
    else
     xtr_revl_exchange_rate(rec, retcode);
      l_rate1 := rec.reval_ex_rate_one;
      l_rate0 := rec.deal_ex_rate_one;
        fv_sob_amt := round((rec.fair_value * l_rate1), l_round);
        currency_gl:= round((l_begin_fv * (l_rate1 - l_rate0)), l_round);
        rel_sob_gl:= round((rel_pl_value * l_rate1), l_round);
    end if;
  End if;
  r_rd.effective_days := rec.period_end - rec.period_start;
  xtr_revl_real_log(rec, rel_pl_value, fv_sob_amt, rel_sob_gl, currency_gl, r_rd, retcode);

EXCEPTION
    when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_bond_realmtm');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
End xtr_revl_bond_realmtm;
---------------------------------------------------------------
/*********************************************************/
/* This procedure insert value to revaluation details    */
/* table with BOND amount type 'UNREAL' information      */
/* We only allow overwrite Price for UNREAL amount type  */
/* with transaction no = 1                               */
/*********************************************************/
PROCEDURE xtr_revl_bond_unreal(rec IN OUT NOCOPY xtr_revl_rec,
                               bo_rec IN OUT NOCOPY xtr_bond_rec,
                               p_resale IN BOOLEAN,
			       p_overwrite IN BOOLEAN) IS
l_buf Varchar2(500);
r_rd XTR_REVALUATION_DETAILS%rowtype;
l_begin_fv      NUMBER;
unrel_pl_value    NUMBER;
fv_sob_amt      NUMBER;
rel_sob_gl      NUMBER;
unrel_sob_gl    NUMBER;
currency_gl     NUMBER;
cum_pl_value    NUMBER;
l_resale_cum_gl NUMBER;
l_resale_unrel_gl NUMBER;
l_bond_clean_px NUMBER;
l_end_fv	NUMBER;
l_rc            NUMBER;
l_deno          NUMBER;
l_numer         NUMBER;
l_rate0		NUMBER;
l_rate1		NUMBER;
l_round		NUMBER;
l_mtm_real      NUMBER;
l_reval_rate    NUMBER;
r_err_log       err_log; -- record type
retcode		NUMBER;

Begin
r_rd.amount_type := C_UNREAL;   -- 'UNREAL'
rec.reval_ccy    := rec.currencya;
if rec.batch_start > rec.eligible_date then
   rec.period_start := rec.batch_start;
else
   rec.period_start := rec.eligible_date;
end if;

 select rounding_factor
 into l_round
 from xtr_master_currencies_v
 where currency = rec.reval_ccy;

 If p_resale = TRUE then
   -- record is a result of resale. Create last unrealized G/L record for resold amount.

    l_resale_cum_gl  := bo_rec.cum_unrel_gl * (bo_rec.face_value /bo_rec.start_face_value);
    l_resale_unrel_gl:= bo_rec.mtm_real - l_resale_cum_gl;
    rec.trans_no     := bo_rec.cross_ref_no;
    rec.face_value   := bo_rec.face_value;
    rec.period_end   := bo_rec.resale_rec_date;
    rec.reval_rate   := bo_rec.clean_px;
    rec.effective_date:= bo_rec.resale_rec_date;
    r_rd.transaction_period := rec.period_end - rec.period_start;

    -- 2879858.  Bond Repurchase Project.
    -- Ensure signage of fair value is properly presented for an ISSUE deal.

    If (rec.deal_subtype = 'ISSUE') then
       rec.fair_value   := -rec.face_value * bo_rec.clean_px / 100;
    Else
       rec.fair_value   := rec.face_value * bo_rec.clean_px / 100;
    End If;

    -- End 2879858.

    unrel_pl_value   := l_resale_unrel_gl;
    cum_pl_value     := bo_rec.mtm_real;

    if (bo_rec.maturity_face_value  - bo_rec.face_value) > 0 then
       bo_rec.maturity_face_value := bo_rec.maturity_face_value  - bo_rec.face_value;
    else
       bo_rec.maturity_face_value := 0;
    end if;

    -- Bug 2990046 - Issue #1.
    -- Corrected bug existing since XTR.F which incorrectly resets the cumulative unrealized
    -- gain/loss amount for any remaining face value going forward to zero if the cum amount
    -- is a loss.

    /*
    if (bo_rec.cum_unrel_gl_bal - l_resale_cum_gl) > 0 then
       bo_rec.cum_unrel_gl_bal := bo_rec.cum_unrel_gl_bal - l_resale_cum_gl;
    else
       bo_rec.cum_unrel_gl_bal := 0;
    end if;
    */

    bo_rec.cum_unrel_gl_bal := bo_rec.cum_unrel_gl_bal - l_resale_cum_gl;

    -- End bug 2990046 - Issue #1 fix.


    GL_CURRENCY_API.get_triangulation_rate
           (rec.reval_ccy, rec.sob_ccy, rec.effective_date, rec.ex_rate_type,
           l_deno, l_numer, rec.reval_ex_rate_one);

 Else   -- UNREAL record is not result of resale
    rec.trans_no     := 1;
    rec.effective_date := rec.maturity_date;
    if rec.maturity_date <= rec.revldate then -- deal matured
       select realised_pl, reval_rate
       into l_mtm_real, l_reval_rate
       from XTR_REVALUATION_DETAILS
       where batch_id = rec.batch_id
       and deal_no = rec.deal_no
       and transaction_no = rec.trans_no
       and amount_type = 'REAL';

       rec.face_value := rec.fxo_sell_ref_amount;  -- xtr_deals.maturity_balance_amount
       rec.fair_value := rec.fxo_sell_ref_amount;
       rec.period_end := rec.maturity_date;
       unrel_pl_value := l_mtm_real - bo_rec.cum_unrel_gl_bal;
       cum_pl_value   := l_mtm_real;
       rec.reval_rate   := l_reval_rate;
       if rec.deal_subtype in ('SHORT', 'ISSUE') then
           rec.fair_value := rec.fair_value * (-1);
       end if;

    else    -- deal not mature
       if p_overwrite = FALSE then
          xtr_revl_getprice_bond(rec, l_bond_clean_px);
          rec.reval_rate := l_bond_clean_px;
       end if;
       l_end_fv       := bo_rec.maturity_face_value * (rec.reval_rate /100);
       if bo_rec.start_face_value = bo_rec.maturity_face_value then
	  -- no recognized resaled have occured since last reval
	  l_begin_fv  := bo_rec.start_fair_value;
       else
	  l_begin_fv  := bo_rec.start_fair_value *
			 (bo_rec.maturity_face_value / bo_rec.start_face_value);
       end if;
       rec.face_value := bo_rec.maturity_face_value;
       rec.period_end := rec.revldate;
       if rec.pricing_model = 'MARKET' then
          rec.fair_value := l_end_fv;
          if rec.deal_subtype in ('SHORT', 'ISSUE') then
             rec.fair_value := rec.fair_value * (-1);
          end if;
       else
          rec.fair_value := null;
       end if;
       unrel_pl_value := rec.fair_value - l_begin_fv;
       cum_pl_value   := bo_rec.cum_unrel_gl_bal + unrel_pl_value;
    end if;
    r_rd.transaction_period := rec.period_end - rec.period_start;
 End if;

 If rec.reval_ccy = rec.sob_ccy then
     rec.reval_ex_rate_one := 1;
     rec.deal_ex_rate_one  := 1;
     currency_gl := 0;
     fv_sob_amt  := rec.fair_value;
     unrel_sob_gl  := unrel_pl_value;
 Else
    if p_resale <> TRUE then
      xtr_revl_exchange_rate(rec, retcode);
      xtr_revl_get_curr_gl(rec, unrel_pl_value, null, fv_sob_amt,
		          rel_sob_gl, unrel_sob_gl, currency_gl);
    else
      if p_resale <> TRUE and (rec.maturity_date <= rec.revldate) then
         if bo_rec.pre_gl_rate is NULL then
            l_rate0 := rec.deal_ex_rate_one;
         else
            l_rate0 := bo_rec.pre_gl_rate;
         end if;
         l_rate1 := rec.reval_ex_rate_one;
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_bond_unreal: ' || 'BOND_UNREAL');
     xtr_risk_debug_pkg.dlog('xtr_revl_bond_unreal: ' || 'rec.deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_bond_unreal: ' || 'l_rate1' , l_rate1);
     xtr_risk_debug_pkg.dlog('xtr_revl_bond_unreal: ' || 'l_rate0' , l_rate0);
     xtr_risk_debug_pkg.dlog('xtr_revl_bond_unreal: ' || 'fair value' , rec.fair_value);
     xtr_risk_debug_pkg.dpop('xtr_revl_bond_unreal: ' || 'BOND_UNREAL');
  END IF;

      elsif p_resale = TRUE then
         l_rate1 := rec.reval_ex_rate_one;
         l_rate0 := rec.deal_ex_rate_one;
      end if;
        fv_sob_amt := round((rec.fair_value * l_rate1), l_round);
        currency_gl:= round((rec.fair_value * (l_rate1 - l_rate0)), l_round);
        unrel_sob_gl:= round((unrel_pl_value * l_rate1), l_round);
    end if;
 End if;

 r_rd.effective_days := rec.period_end - rec.period_start;
 if p_overwrite = FALSE then  -- insert new record from concurrent program
    xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
 		      unrel_sob_gl, currency_gl, r_rd, retcode);
 end if;

EXCEPTION
  when GL_CURRENCY_API.no_rate then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_GL_RATE');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_RATE_CURRENCY_GL');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when GL_CURRENCY_API.invalid_currency then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_INVALID_CURRENCY');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      FND_MESSAGE.set_token('CURRENCY', rec.currencya);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_INVALID_CURRENCY_TYPE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_bond_unreal');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
End xtr_revl_bond_unreal;
----------------------------------------------------------------
/*********************************************************/
/* This procedure returns fair value for deal type TMM   */
/*********************************************************/
PROCEDURE xtr_revl_fv_tmm(
            rec IN OUT NOCOPY xtr_revl_rec,
            fair_value IN OUT NOCOPY NUMBER,
            p_accum_int_sum IN OUT NOCOPY NUMBER,
            p_fwd_rate IN NUMBER) IS
l_buf Varchar2(500);
l_trans_no       NUMBER;
l_start_date     DATE;
l_maturity_date  DATE;
l_settle_date	 DATE;
l_price_model    VARCHAR2(30);
l_market_set     VARCHAR2(30);
l_settle_term    VARCHAR2(1);
l_side        VARCHAR2(5);
l_day         NUMBER;
l_year        NUMBER;
l_pri_action  VARCHAR2(7);
l_pri_adjust  NUMBER;
l_acc_int     NUMBER;
l_balance_out NUMBER;
l_future_val  NUMBER;
l_principal   NUMBER;
l_coupon_cf   NUMBER;
l_coupon_rate NUMBER;
l_coupon_int  NUMBER;
l_int_settle  NUMBER;
l_int_rate    NUMBER;
l_accrued_int NUMBER;
l_interest    NUMBER;
l_last_rec_trans NUMBER;
l_round	      NUMBER;
l_day_count_type VARCHAR2(1);
l_round_type     VARCHAR2(1);
l_first_trans_flag VARCHAR2(1);
l_pre_int	VARCHAR2(1);
l_int_refund	NUMBER;
l_pv_refund	NUMBER;
r_err_log err_log; -- record type
retcode		NUMBER;

cursor c_roll is
select TRANSACTION_NUMBER, START_DATE, MATURITY_DATE, PRINCIPAL_ACTION,
       INTEREST_RATE, INTEREST_SETTLED, PRINCIPAL_ADJUST, ACCUM_INTEREST,
       BALANCE_OUT, SETTLE_TERM_INTEREST, INTEREST, INTEREST_REFUND, SETTLE_DATE
from xtr_rollover_transactions
where DEAL_NUMBER = rec.deal_no
  and maturity_date >= rec.revldate
order by start_date, transaction_number asc;

Begin
   select day_count_type, rounding_type, prepaid_interest
   into l_day_count_type, l_round_type, l_pre_int
   from XTR_DEALS_V
   where deal_no = rec.deal_no;

   select rounding_factor
   into l_round
   from xtr_master_currencies_v
   where currency = rec.reval_ccy;

   l_market_set := rec.MARKET_DATA_SET;
   xtr_revl_get_mds(l_market_set, rec);

-- determine the last record's transaction number
  select max(transaction_number)
  into l_last_rec_trans
  from xtr_rollover_transactions
  where DEAL_NUMBER=rec.deal_no
  and START_DATE = MATURITY_DATE;

  for l_tmp in c_roll loop
    l_trans_no	    := l_tmp.TRANSACTION_NUMBER;
    l_start_date    := l_tmp.START_DATE;
    l_maturity_date := l_tmp.MATURITY_DATE;
    l_settle_date   := l_tmp.SETTLE_DATE;
    l_pri_action    := l_tmp.PRINCIPAL_ACTION;
    l_pri_adjust    := nvl(l_tmp.PRINCIPAL_ADJUST, 0);
    l_acc_int       := l_tmp.ACCUM_INTEREST;
    l_balance_out   := l_tmp.BALANCE_OUT;
    l_int_settle    := l_tmp.INTEREST_SETTLED;
    l_int_rate      := l_tmp.INTEREST_RATE;
    l_settle_term   := l_tmp.SETTLE_TERM_INTEREST;
    l_interest      := l_tmp.INTEREST;
    l_int_refund    := l_tmp.INTEREST_REFUND;

    l_principal     := 0;
    l_coupon_cf     := 0;
    l_accrued_int   := 0;

    if l_day_count_type = 'B' and l_trans_no = 1 then
	l_first_trans_flag := 'Y';
    else
	l_first_trans_flag := 'N';
    end if;

/*********************************************/
/* Calculate the present value of Principal  */
/*********************************************/
if rec.revldate < l_start_date then
  if l_pri_adjust <> 0 then
    if l_pri_action = 'INCRSE' then
      if(rec.deal_subtype = 'FUND') then
        l_side := 'B';
      else
        l_side := 'A';
      end if;
      l_future_val := l_pri_adjust;

      xtr_revl_present_value_tmm(rec, rec.batch_id, rec.year_calc_type,
        rec.revldate, l_start_date, l_future_val, rec.currencya,
        l_market_set, l_side, l_principal);
    elsif l_pri_action = 'DECRSE' then
      if(rec.deal_subtype = 'FUND') then
        l_side := 'A';
      else
        l_side := 'B';
      end if;
      l_future_val := l_pri_adjust;
      xtr_revl_present_value_tmm(rec, rec.batch_id, rec.year_calc_type,
        rec.revldate, l_start_date, l_future_val, rec.currencya,
        l_market_set, l_side, l_principal);
    end if;
  else
    l_principal := 0;
  end if;
  l_principal := round(l_principal, l_round);
end if;

  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_fv_tmm: ' || 'TMM_PRINCIPAL');
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'trans no', l_trans_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'year_calc_type', rec.year_calc_type);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'l_start_date', l_start_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'l_future_val', l_future_val);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'rec.currencya', rec.currencya);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'l_market_set', l_market_set);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'l_side', l_side);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'l_principal', l_principal);
     xtr_risk_debug_pkg.dpop('xtr_revl_fv_tmm: ' || 'TMM_PRINCIPAL');
  END IF;

  if(rec.deal_subtype = 'FUND') then
    l_side := 'A';
  else
    l_side := 'B';
  end if;

/****************************************************/
/* Calculate the present value of Coupon(Interest)  */
/****************************************************/
  if l_last_rec_trans = l_trans_no then  -- last record
    l_future_val := nvl(-l_int_settle,0) - nvl(p_accum_int_sum,0);
/*    if nvl(l_pre_int, 'N') = 'Y' and rec.deal_type = 'TMM' then
       xtr_revl_present_value_tmm(rec, rec.batch_id, rec.year_calc_type,
       rec.revldate, l_start_date, l_future_val, rec.currencya,
       l_market_set, l_side, l_coupon_cf);
    else
*/
       xtr_revl_present_value_tmm(rec, rec.batch_id, rec.year_calc_type,
       rec.revldate, l_settle_date, l_future_val, rec.currencya,
       l_market_set, l_side, l_coupon_cf);
--    end if;

  elsif(rec.revldate<= rec.settle_date and
        rec.settle_date is not NULL) then
    -- fixed rate
    l_side := 'A';
    l_future_val  := l_int_settle;
    l_coupon_rate := l_int_rate;

   /*** Prepaid Interest  ****/
/*    if nvl(l_pre_int, 'N') = 'Y' and rec.deal_type = 'TMM' then
       if l_start_date < rec.revldate then
	  l_coupon_cf := 0;
       else
          xtr_revl_present_value_tmm(rec, rec.batch_id, rec.year_calc_type,
          rec.revldate, l_start_date, l_future_val, rec.currencya,
          l_market_set, l_side, l_coupon_cf);
       end if;
    else
*/
       xtr_revl_present_value_tmm(rec, rec.batch_id, rec.year_calc_type,
       rec.revldate, l_settle_date, l_future_val, rec.currencya,
       l_market_set, l_side, l_coupon_cf);
--    end if;

    l_coupon_int := l_interest;
  else
    -- floating rate
    if rec.revldate > l_start_date then
      l_coupon_rate := l_int_rate;
    else
      if p_fwd_rate is NULL then
        -- no overwrite
        rec.trans_no := l_trans_no;
        xtr_revl_getprice_fwd(rec, TRUE, l_coupon_rate);
      else
        l_coupon_rate := p_fwd_rate;
      end if;
    end if;  -- rec.revldate >
    rec.reval_rate := l_coupon_rate;

    if rec.pricing_model = 'DISC_CASHFLOW' then
       l_coupon_int := xtr_calc_interest(l_balance_out,
       l_start_date, l_maturity_date, l_coupon_rate,
       rec.year_calc_type);
    else  -- 'DISC_CASHSTA' take overwrite value from TMM record
       l_coupon_int := l_interest;
    end if;


  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_fv_tmm: ' || 'TMM_REVAL_RATE');
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'trans no', l_trans_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'rec.revldate', rec.revldate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'l_start_date', l_start_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'l_int_rate', l_int_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'l_coupon_rate', l_coupon_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'rec.reval_rate', rec.reval_rate);
     xtr_risk_debug_pkg.dpop('xtr_revl_fv_tmm: ' || 'TMM_REVAL_RATE');
  END IF;


/* for Interest Overwrite project
    l_coupon_int := xtr_calc_interest(l_balance_out,
      l_start_date, l_maturity_date, l_coupon_rate,
      rec.year_calc_type);   */
  --  l_coupon_int := l_interest;

    if l_settle_term = 'Y' and nvl(l_int_settle, 0)<> 0 then
       if rec.deal_subtype = 'FUND' then
          l_side := 'A';
          l_future_val := l_coupon_int;
       else
          l_side := 'B';
          l_future_val := l_coupon_int;
       end if;

       /*** Prepaid Interest  ****/
/*       if nvl(l_pre_int, 'N') = 'Y' and rec.deal_type = 'TMM' then
          if l_start_date < rec.revldate then
             l_coupon_cf := 0;
          else
             xtr_revl_present_value_tmm(rec, rec.batch_id, rec.year_calc_type,
             rec.revldate, l_start_date, l_future_val, rec.currencya,
             l_market_set, l_side, l_coupon_cf);
          end if;
       else
*/
          xtr_revl_present_value_tmm(rec, rec.batch_id, rec.year_calc_type,
          rec.revldate, l_settle_date, l_future_val, rec.currencya,
          l_market_set, l_side, l_coupon_cf);
--       end if;
    elsif l_settle_term = 'Y' and nvl(l_int_settle, 0) = 0 then
	l_coupon_cf := 0;
    else
      p_accum_int_sum := nvl(p_accum_int_sum,0) + nvl(l_coupon_int,0) +
                         nvl(l_acc_int,0);
    end if;

-- for Interest Overwrite project
    if l_round_type = 'U' then
       l_coupon_cf := xtr_fps2_p.roundup(l_coupon_cf, l_round);
    elsif l_round_type = 'T' then
       l_coupon_cf := trunc(l_coupon_cf, l_round);
    else
       l_coupon_cf := round(l_coupon_cf, l_round);
    end if;
  end if;

  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_fv_tmm: ' || 'TMM_INTEREST');
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'trans no', l_trans_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'year_calc_type', rec.year_calc_type);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'rec.revldate', rec.revldate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'l_maturity_date', l_maturity_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'l_future_val', l_future_val);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'rec.currencya', rec.currencya);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'l_market_set', l_market_set);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'l_side', l_side);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'l_coupon_cf', l_coupon_cf);
     xtr_risk_debug_pkg.dpop('xtr_revl_fv_tmm: ' || 'TMM_INTEREST');
  END IF;

/*********************************************/
/* Calculate the Accrued Interest            */
/*********************************************/
-- for Interest Overwrite project
  if rec.revldate  > l_start_date then  -- BUG 30043228
   /*** Prepaid Interest  ****/
    if nvl(l_pre_int, 'N') = 'Y' and rec.deal_type = 'TMM' then
        if rec.revldate = l_maturity_date then
           l_accrued_int := 0;
        else
           /* BUG 3004328
           l_accrued_int := xtr_calc_interest(l_balance_out,
           rec.revldate +1, l_maturity_date, l_coupon_rate, rec.year_calc_type,
           l_day_count_type, l_first_trans_flag);
           */
           l_accrued_int := xtr_calc_interest(l_balance_out,
           l_start_date, rec.revldate, l_coupon_rate, rec.year_calc_type,
           l_day_count_type, l_first_trans_flag)
           -xtr_calc_interest(l_balance_out,
           l_start_date, l_maturity_date, l_coupon_rate, rec.year_calc_type,
           l_day_count_type, l_first_trans_flag);
           l_accrued_int := - l_accrued_int; -- Code assumes positive values for prepaid TMM
           -- END BUG 30043228
        end if;
    else
        if rec.revldate = l_maturity_date then
  	   l_accrued_int := l_coupon_int;
        else
           l_accrued_int := xtr_calc_interest(l_balance_out,
           l_start_date, rec.revldate, l_coupon_rate, rec.year_calc_type,
	   l_day_count_type, l_first_trans_flag);
        end if;
    end if;

    if l_round_type = 'U' then
       l_accrued_int := xtr_fps2_p.roundup(l_accrued_int, l_round);
    elsif l_round_type = 'T' then
       l_accrued_int := trunc(l_accrued_int, l_round);
    else
       l_accrued_int := round(l_accrued_int, l_round);
    end if;
  end if;

  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_fv_tmm: ' || 'TMM_ACCRU_INT');
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'trans no', l_trans_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'year_calc_type', rec.year_calc_type);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'l_balance_out', l_balance_out);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'l_start_date', l_start_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'rec.revldate', rec.revldate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'l_coupon_rate', l_coupon_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_tmm: ' || 'l_accrued_int', l_accrued_int);
     xtr_risk_debug_pkg.dpop('xtr_revl_fv_tmm: ' || 'TMM_ACCRU_INT');
  END IF;

/***** Prepaid Interest   *******/
  if nvl(l_pre_int, 'N') = 'Y'  and rec.deal_type = 'TMM' then
     if (l_start_date < rec.revldate) or nvl(l_int_refund, 0) = 0 then
	l_pv_refund := 0;
     else
        xtr_revl_present_value_tmm(rec, rec.batch_id, rec.year_calc_type,
        rec.revldate, l_settle_date, l_int_refund, rec.currencya,
        l_market_set, l_side, l_pv_refund);
     end if;

     fair_value := nvl(fair_value,0) + nvl(l_principal,0) + nvl(l_pv_refund,0)
                + nvl(l_coupon_cf,0) + nvl(l_accrued_int,0);
  else
     fair_value := nvl(fair_value,0) + nvl(l_principal,0)
		+ nvl(l_coupon_cf,0) - nvl(l_accrued_int,0);
  end if;
  End loop;

  if rec.deal_subtype = 'FUND' then
     fair_value := fair_value * (-1);
  end if;

EXCEPTION
    when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_fv_tmm');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
end xtr_revl_fv_tmm;
--------------------------------------------------------
PROCEDURE xtr_revl_present_value_tmm(
            rec IN xtr_revl_rec,
            p_batch_id IN NUMBER,
            p_day_count IN VARCHAR2,
            p_revl_date IN DATE,
            p_start_date IN DATE,
            p_future_val IN NUMBER,
            p_ccy IN VARCHAR2,
            p_market_set IN VARCHAR2,
            p_side IN VARCHAR2,
            p_present_value OUT NOCOPY NUMBER) is
l_buf Varchar2(500);
r_md_in     xtr_market_data_p.md_from_set_in_rec_type;
r_md_out    xtr_market_data_p.md_from_set_out_rec_type;
r_mm_in     XTR_MM_COVERS.PresentValue_in_rec_type;
r_mm_out    XTR_MM_COVERS.PresentValue_out_rec_type;
l_day       NUMBER;
l_year      NUMBER;
r_err_log err_log; -- record type
retcode		NUMBER;

begin
if p_revl_date > p_start_date then
    p_present_value := 0;
else

   XTR_CALC_P.calc_days_run(p_revl_date, p_start_date,
   p_day_count, l_day, l_year);
   xtr_revl_mds_init(r_md_in, p_market_set, C_SOURCE,
      C_DISCOUNT_FAC, p_revl_date, p_start_date,
      p_ccy, NULL, p_day_count,
      C_INTERPOL_LINER, p_side, p_batch_id, NULL);
   XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
   r_mm_in.p_indicator := C_DISCOUNT_FAC;
   r_mm_in.p_future_val:= p_future_val;
   r_mm_in.p_rate := r_md_out.p_md_out;
   r_mm_in.p_day_count := l_day;
   r_mm_in.p_annual_basis := l_year;
   XTR_MM_COVERS.present_value(r_mm_in, r_mm_out);
   p_present_value := r_mm_out.p_present_val;
end if;

  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_present_value_tmm: ' || 'PRESENT_VALUE');
     xtr_risk_debug_pkg.dlog('xtr_revl_present_value_tmm: ' || 'p_revl_date', p_revl_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_present_value_tmm: ' || 'p_start_date', p_start_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_present_value_tmm: ' || 'p_day_count', p_day_count);
     xtr_risk_debug_pkg.dlog('xtr_revl_present_value_tmm: ' || 'l_day', l_day);
     xtr_risk_debug_pkg.dlog('xtr_revl_present_value_tmm: ' || 'l_year', l_year);
     xtr_risk_debug_pkg.dlog('xtr_revl_present_value_tmm: ' || 'p_indicator', r_mm_in.p_indicator);
     xtr_risk_debug_pkg.dlog('xtr_revl_present_value_tmm: ' || 'p_future_val', r_mm_in.p_future_val);
     xtr_risk_debug_pkg.dlog('xtr_revl_present_value_tmm: ' || 'p_rate', r_mm_in.p_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_present_value_tmm: ' || 'p_day_count', r_mm_in.p_day_count);
     xtr_risk_debug_pkg.dlog('xtr_revl_present_value_tmm: ' || 'p_annual_basis', r_mm_in.p_annual_basis);
     xtr_risk_debug_pkg.dlog('xtr_revl_present_value_tmm: ' || 'p_present_value', p_present_value);
     xtr_risk_debug_pkg.dpop('xtr_revl_present_value_tmm: ' || 'PRESENT_VALUE');
  END IF;

EXCEPTION
  when XTR_MARKET_DATA_P.e_mdcs_no_data_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_MARKET');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_MARKETDATASET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when XTR_MARKET_DATA_P.e_mdcs_no_curve_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_CURVE');
      FND_MESSAGE.set_token('MARKET', rec.market_data_set);
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_CURVEMARKET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_present_value_tmm');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;

end xtr_revl_present_value_tmm;
--------------------------------------------------------
/*********************************************************/
/* This procedure calculates the fair value of STOCK     */
/*********************************************************/
PROCEDURE xtr_revl_fv_stock(rec IN OUT NOCOPY xtr_revl_rec,
			    p_price	IN NUMBER,
			    fair_value	OUT NOCOPY NUMBER) is

Cursor c_stock_alloc is
Select stock.deal_no, stock.cross_ref_no, stock.fair_value, stock.init_consideration,
       stock.real_gain_loss, stock.quantity, stock.remaining_quantity,
       stock.price_per_share, decode(cp.parameter_value_code, 'TRADE',
       stock.cross_ref_deal_date, stock.cross_ref_start_date) resale_rec_date
from XTR_STOCK_ALLOC_DETAILS STOCK,
     XTR_COMPANY_PARAMETERS CP,
     XTR_DEALS D
Where stock.deal_no = rec.deal_no
and stock.deal_no = d.deal_no
and stock.batch_id is null
and cp.company_code = d.company_code
and cp.parameter_code = 'ACCNT_TSDTM'
and decode(cp.parameter_value_code, 'TRADE', stock.cross_ref_deal_date,
           stock.cross_ref_start_date) <= rec.revldate
Order by resale_rec_date asc, stock.cross_ref_no asc;

st_rec         xtr_stock_rec;   -- STOCK record type
l_pre_batch    NUMBER;
l_first        BOOLEAN;
l_resale       BOOLEAN := null;  -- Indicate if the record is result of resale
l_overwrite    BOOLEAN := FALSE;
l_rounding     NUMBER;
l_dummy		NUMBER;
l_dummy1	NUMBER;
l_dummy2	NUMBER;
r_err_log       err_log; -- record type
retcode         NUMBER;
l_buf Varchar2(500);
BEGIN
 select ROUNDING_FACTOR
 into l_rounding
 from XTR_MASTER_CURRENCIES_V
 where currency = rec.currencya;
 xtr_first_reval(rec, l_first);
 if l_first = TRUE then  -- first time reval
    l_pre_batch := NULL;
    st_rec.prev_price := rec.transaction_rate;
    st_rec.init_quantity := rec.quantity;
    st_rec.quantity := rec.quantity;
    st_rec.remaining_quantity := rec.quantity;
    st_rec.cum_unrel_gl := 0;
    st_rec.pre_gl_rate := NULL;

 else   -- not the first time reval
    l_pre_batch := xtr_get_pre_batchid(rec);
    select quantity, quantity, reval_rate, exchange_rate_one, cumm_gain_loss_amount
    into st_rec.init_quantity, st_rec.remaining_quantity, st_rec.prev_price,
         st_rec.pre_gl_rate, st_rec.cum_unrel_gl
    from XTR_REVALUATION_DETAILS
    where batch_id = l_pre_batch
    and deal_no = rec.deal_no
    and nvl(realized_flag, 'N') = 'N'
    and transaction_no = 1;

 end if;

 Open C_STOCK_ALLOC;
 Fetch C_STOCK_ALLOC into st_rec.deal_no, st_rec.cross_ref_no,
       st_rec.fair_value, st_rec.init_cons, st_rec.real_gl,
       st_rec.quantity, st_rec.remaining_quantity, st_rec.price_per_share,
       st_rec.resale_rec_date;
 While C_STOCK_ALLOC%FOUND loop
    l_resale  := TRUE;
    XTR_REVL_STOCK_REAL(rec, st_rec);
    XTR_REVL_STOCK_UNREAL(rec, st_rec, l_resale, l_overwrite, l_dummy, l_dummy1, l_dummy2);

    -- Update xtr_bond_alloc_details record so this record will not be
    -- eligible for next time
    Update XTR_STOCK_ALLOC_DETAILS
    Set batch_id = rec.batch_id
    where deal_no = st_rec.deal_no
    and cross_ref_no = st_rec.cross_ref_no;

    Fetch C_STOCK_ALLOC into st_rec.deal_no, st_rec.cross_ref_no,
       st_rec.fair_value, st_rec.init_cons, st_rec.real_gl,
       st_rec.quantity, st_rec.remaining_quantity, st_rec.price_per_share,
       st_rec.resale_rec_date;

 End loop;

 If st_rec.remaining_quantity = 0 and
    nvl(st_rec.resale_rec_date, rec.revldate +1) <= rec.revldate then  -- totally resale
    update XTR_DEALS
    set last_reval_batch_id = rec.batch_id
    where deal_no = rec.deal_no;
 Else
    l_resale := FALSE;
    if p_price is not null then  -- user provide overwrite Rate
       rec.reval_rate := p_price;
       l_overwrite    := TRUE;
    end if;
    XTR_REVL_STOCK_UNREAL(rec, st_rec, l_resale, l_overwrite, l_dummy, l_dummy1, l_dummy2);
    fair_value := rec.fair_value;
 end if;

EXCEPTION
    when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_fv_stock');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;

END;

-----------------------------------------------------------
/*********************************************************/
/* This procedure inserts STOCK realized G/L records     */
/*********************************************************/
PROCEDURE xtr_revl_stock_real(rec IN OUT NOCOPY xtr_revl_rec,
			      st_rec IN xtr_stock_rec) is
l_buf Varchar2(500);
r_rd XTR_REVALUATION_DETAILS%rowtype;
rel_pl_value    NUMBER;
fv_sob_amt      NUMBER;
rel_sob_gl      NUMBER;
unrel_sob_gl    NUMBER;
currency_gl     NUMBER;
l_rc            NUMBER;
r_err_log       err_log; -- record type
retcode         NUMBER;


BEGIN
 rec.reval_ccy    := rec.currencya;
 rec.trans_no     := st_rec.cross_ref_no;
 rec.face_value   := st_rec.init_cons;
 rec.init_fv      := st_rec.init_cons;
 rec.fair_value   := st_rec.fair_value;
 rec.period_start := rec.eligible_date;
 rec.period_end   := st_rec.resale_rec_date;
 rec.effective_date := st_rec.resale_rec_date;
 rec.reval_rate   := st_rec.price_per_share;
 r_rd.amount_type := 'REAL';
 r_rd.quantity    := st_rec.quantity;
 r_rd.transaction_period := rec.period_end - rec.period_start;
 r_rd.effective_days := rec.period_end - rec.period_start;
 rel_pl_value     := st_rec.real_gl;

If rec.reval_ccy = rec.sob_ccy then
     rec.reval_ex_rate_one := 1;
     rec.deal_ex_rate_one  := 1;
     currency_gl := 0;
     fv_sob_amt  := rec.fair_value;
     rel_sob_gl  := rel_pl_value;
  Else
     xtr_revl_exchange_rate(rec, retcode);
     xtr_revl_get_curr_gl(rec, null, rel_pl_value, fv_sob_amt,
        rel_sob_gl, unrel_sob_gl, currency_gl);
  End if;

  xtr_revl_real_log(rec, rel_pl_value, fv_sob_amt, rel_sob_gl, currency_gl, r_rd, retcode);

EXCEPTION
    when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_stock_real');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;

END;

-------------------------------------------------------------
/**********************************************************/
/* This procedure inserts STOCK unrealized G/L records    */
/* We only allow overwrite Price for UNREAL amount type  */
/* with transaction no = 1                               */
/*********************************************************/
PROCEDURE xtr_revl_stock_unreal(rec IN OUT NOCOPY xtr_revl_rec,
                                st_rec IN xtr_stock_rec,
                                p_resale IN BOOLEAN,
                                p_overwrite IN BOOLEAN,
                                unrel_pl_value IN OUT NOCOPY NUMBER,
                                cum_pl_value IN OUT NOCOPY NUMBER,
				currency_gl IN OUT NOCOPY NUMBER) IS

l_buf Varchar2(500);
r_rd XTR_REVALUATION_DETAILS%rowtype;
fv_sob_amt      NUMBER;
rel_sob_gl      NUMBER;
unrel_sob_gl    NUMBER;
l_resale_cum_gl NUMBER;
l_resale_unrel_gl NUMBER;
l_begin_fv	NUMBER;
l_end_fv        NUMBER;
l_rc            NUMBER;
l_deno          NUMBER;
l_numer         NUMBER;
l_rate0         NUMBER;
l_rate1         NUMBER;
l_round         NUMBER;
l_reval_rate    NUMBER;
l_stock_price	NUMBER;
l_pre_batch	NUMBER;
l_first        BOOLEAN;
r_err_log       err_log; -- record type
retcode         NUMBER;

BEGIN
r_rd.amount_type := C_UNREAL;   -- 'UNREAL'
rec.reval_ccy    := rec.currencya;
if rec.batch_start > rec.eligible_date then
   rec.period_start := rec.batch_start;
else
   rec.period_start := rec.eligible_date;
end if;

 select rounding_factor
 into l_round
 from xtr_master_currencies_v
 where currency = rec.reval_ccy;

 If p_resale = TRUE then
   -- record is a result of resale. Create last unrealized G/L record for resold amount.
    rec.trans_no     := st_rec.cross_ref_no;
    rec.face_value   := st_rec.init_cons;
    rec.period_end   := st_rec.resale_rec_date;
    rec.reval_rate   := st_rec.price_per_share;
    rec.effective_date := st_rec.resale_rec_date;
    rec.fair_value   := st_rec.fair_value;
    rec.quantity     := st_rec.quantity;
    unrel_pl_value   := st_rec.real_gl - (st_rec.cum_unrel_gl *
			(st_rec.quantity /st_rec.init_quantity));
    cum_pl_value     := st_rec.cum_unrel_gl + unrel_pl_value;

    If rec.reval_ccy = rec.sob_ccy then
       rec.reval_ex_rate_one := 1;
       rec.deal_ex_rate_one  := 1;
       currency_gl := 0;
       fv_sob_amt  := rec.fair_value;
       unrel_sob_gl  := unrel_pl_value;

    Else
       xtr_first_reval(rec, l_first);
       if l_first = FALSE then  -- not the first reval
          l_pre_batch := xtr_get_pre_batchid(rec);
          select exchange_rate_one
          into rec.deal_ex_rate_one
          from XTR_REVALUATION_DETAILS
          where deal_no = rec.deal_no
          and transaction_no = 1
          and nvl(realized_flag, 'N') = 'N'
          and batch_id = l_pre_batch;

       else
          GL_CURRENCY_API.get_triangulation_rate
                (rec.reval_ccy, rec.sob_ccy, rec.eligible_date, rec.ex_rate_type,
                l_deno, l_numer, rec.deal_ex_rate_one);
       end if;

       GL_CURRENCY_API.get_triangulation_rate
           (rec.reval_ccy, rec.sob_ccy, rec.effective_date, rec.ex_rate_type,
           l_deno, l_numer, rec.reval_ex_rate_one);

       fv_sob_amt := round((rec.fair_value * rec.reval_ex_rate_one), l_round);
       currency_gl:= round((rec.fair_value * (rec.reval_ex_rate_one - rec.deal_ex_rate_one)), l_round);
       unrel_sob_gl:= round((unrel_pl_value * rec.reval_ex_rate_one), l_round);
/*
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_stock_unreal: ' || 'UNREAL_CURR');
     xtr_risk_debug_pkg.dlog('xtr_revl_stock_unreal: ' || 'deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_stock_unreal: ' || 'trans no', rec.trans_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_stock_unreal: ' || 'rate0', rec.deal_ex_rate_one);
     xtr_risk_debug_pkg.dlog('xtr_revl_stock_unreal: ' || 'rate1', rec.reval_ex_rate_one);
     xtr_risk_debug_pkg.dlog('xtr_revl_stock_unreal: ' || 'fv', rec.fair_value);
     xtr_risk_debug_pkg.dpop('xtr_revl_stock_unreal: ' || 'UNREAL_CURR');
  END IF;
*/

    End if;


 Else   -- UNREAL record is not result of resale
    rec.trans_no     := 1;
    rec.effective_date := rec.revldate;

    if p_overwrite = FALSE then   -- Get STOCK price from API
       xtr_revl_getprice_stock(rec, l_stock_price);
       rec.reval_rate := l_stock_price;
       l_end_fv := nvl(st_rec.remaining_quantity, rec.quantity) * rec.reval_rate;
       rec.fair_value := l_end_fv;

/*
       if st_rec.init_quantity = st_rec.remaining_quantity then
           -- no recognized resale since the last reval
           l_begin_fv := st_rec.remaining_quantity * st_rec.prev_price;
       else
           -- resales have occurred since the last reval
           l_begin_fv := st_rec.prev_price * (st_rec.init_quantity /st_rec.remaining_quantity);
       end if;
*/
           l_begin_fv := nvl(st_rec.remaining_quantity, rec.quantity) * st_rec.prev_price;

       rec.quantity := nvl(st_rec.remaining_quantity, rec.quantity);

    else --  p_overwrite = TRUE
       if rec.ow_type = 'PRICE' then
	  l_end_fv := rec.quantity * rec.reval_rate;
	  rec.fair_value := l_end_fv;
       else  --user overwrite FAIR VALUE
          l_end_fv := rec.fair_value;
       end if;
       xtr_first_reval(rec, l_first);
       if l_first = FALSE then  -- not the first reval
          l_pre_batch := xtr_get_pre_batchid(rec);
	  select fair_value
	  into l_begin_fv
	  from XTR_REVALUATION_DETAILS
	  where deal_no = rec.deal_no
	  and transaction_no = 1
	  and nvl(realized_flag, 'N') = 'N'
          and batch_id = l_pre_batch;
       else
	  l_begin_fv := rec.quantity * rec.transaction_rate;
       end if;
    end if;

    rec.period_end := rec.revldate;
    rec.face_value := rec.quantity * rec.transaction_rate;
    unrel_pl_value := rec.fair_value - l_begin_fv;
    cum_pl_value   := unrel_pl_value + (st_rec.cum_unrel_gl
			* nvl(st_rec.remaining_quantity, rec.quantity) / st_rec.init_quantity);

   -- Calculate currency G/L and other SOB related fields
    If rec.reval_ccy = rec.sob_ccy then
       rec.reval_ex_rate_one := 1;
       rec.deal_ex_rate_one  := 1;
       currency_gl := 0;
       fv_sob_amt  := rec.fair_value;
       unrel_sob_gl  := unrel_pl_value;
    Else
       if p_overwrite <> TRUE then
         xtr_revl_exchange_rate(rec, retcode);
         xtr_revl_get_curr_gl(rec, unrel_pl_value, null, fv_sob_amt,
                          rel_sob_gl, unrel_sob_gl, currency_gl);
       else
         xtr_revl_get_curr_gl(rec, unrel_pl_value, null, fv_sob_amt,
                          rel_sob_gl, unrel_sob_gl, currency_gl);
       end if;
    End if;


 End if;

 r_rd.transaction_period := rec.period_end - rec.period_start;
 r_rd.effective_days := rec.period_end - rec.period_start;

 if p_overwrite = FALSE then  -- insert new record from concurrent program
    xtr_revl_unreal_log(rec, unrel_pl_value, cum_pl_value, fv_sob_amt,
                      unrel_sob_gl, currency_gl, r_rd, retcode);
 end if;

EXCEPTION
  when GL_CURRENCY_API.no_rate then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_GL_RATE');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_RATE_CURRENCY_GL');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when GL_CURRENCY_API.invalid_currency then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_INVALID_CURRENCY');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      FND_MESSAGE.set_token('CURRENCY', rec.currencya);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_INVALID_CURRENCY_TYPE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
     set_err_log(retcode);
     FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_RATE_REF');
     FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
     FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
     APP_EXCEPTION.raise_exception;
    end if;
END xtr_revl_stock_unreal;

------------------------------------------------------------------
/*********************************************************/
/* This procedure returns reval rate for deal type STOCK  */
/*********************************************************/
PROCEDURE xtr_revl_getprice_stock(
           rec IN xtr_revl_rec,
           p_stock_price OUT NOCOPY NUMBER) IS

l_stock_issue    XTR_DEALS.bond_issue%TYPE;
l_ric_code      XTR_BOND_ISSUES.ric_code%TYPE;
l_side          VARCHAR2(1);
r_md_in     xtr_market_data_p.md_from_set_in_rec_type;
r_md_out    xtr_market_data_p.md_from_set_out_rec_type;
r_err_log err_log; -- record type
retcode         NUMBER;
l_market_set   VARCHAR2(30);
l_buf VARCHAR2(300);
l_buff Varchar2(500);
Begin
  -- We only reval STOCK when the pricing model = 'MARKET'
  if rec.pricing_model <> C_P_MODEL_MARKET then
     return;
  end if;

  select RIC_CODE
  into l_ric_code
  from XTR_STOCK_ISSUES
  where stock_issue_code = rec.contract_code;

  l_market_set := rec.MARKET_DATA_SET;
  xtr_revl_get_mds(l_market_set, rec);

  l_side := 'B';  -- Always BUY deal, use BID

  /*** Get stock price from market data set  ***/
    xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
        C_STOCK_IND, rec.revldate, rec.revldate, rec.currencya, NULL,
        NULL, NULL, l_side, rec.batch_id, l_ric_code);
     XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
     p_stock_price    := r_md_out.p_md_out;

EXCEPTION
  when XTR_MARKET_DATA_P.e_mdcs_no_data_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_MARKET');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_MARKETDATASET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
  when XTR_MARKET_DATA_P.e_mdcs_no_curve_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_CURVE');
      FND_MESSAGE.set_token('MARKET', rec.market_data_set);
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_CURVEMARKET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buff := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buff);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
     set_err_log(retcode);
     FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_RATE_REF');
     FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
     FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
     FND_MESSAGE.SET_TOKEN('ISSUE_CODE', rec.contract_code);
     l_buff := FND_MESSAGE.GET;
     fnd_file.put_line(fnd_file.log, l_buff);
    end if;
End xtr_revl_getprice_stock;

-----------------------------------------------------------
/*********************************************************/
/* This procedure returns fair value for deal type IRO   */
/*********************************************************/
PROCEDURE xtr_revl_fv_iro(
            rec IN OUT NOCOPY xtr_revl_rec,
            fair_value IN OUT NOCOPY NUMBER) is
l_buf Varchar2(500);
l_market_set     VARCHAR2(30);
l_ccy         VARCHAR2(15);
l_side        VARCHAR2(5);
l_day_t1      NUMBER;
l_year_t1     NUMBER;
l_day_t2      NUMBER;
l_year_t2     NUMBER;
l_face_amt    NUMBER;
l_int_rate    NUMBER;
l_fwd_rate    NUMBER;
l_volatility  NUMBER;
l_short_rate  NUMBER;
l_long_rate   NUMBER;
r_md_in     xtr_market_data_p.md_from_set_in_rec_type;
r_md_out    xtr_market_data_p.md_from_set_out_rec_type;
r_black_in    XTR_MM_COVERS.black_opt_cv_in_rec_type;
r_black_out   XTR_MM_COVERS.black_opt_cv_out_rec_type;
l_dummy		NUMBER;
l_dummy1	NUMBER;
l_reval_rate	NUMBER;
r_err_log err_log; -- record type
retcode		NUMBER;

BEGIN
    l_market_set := rec.MARKET_DATA_SET;
    xtr_revl_get_mds(l_market_set, rec);

  If rec.settle_date is not null and rec.effective_date <= rec.revldate then
     -- realized.
     xtr_end_fv(rec, fair_value);
  Elsif (rec.effective_date <= rec.revldate) and rec.settle_date is null then
     -- pass expiry date and deal not settled yet. Get fv from previous batch
     xtr_get_fv_from_batch(rec, fair_value, l_dummy, l_dummy1, l_reval_rate);
     rec.reval_rate := l_reval_rate;
  Else  -- calculated unrealized FV
     XTR_CALC_P.calc_days_run(rec.revldate, rec.start_date,
  	 rec.year_calc_type, l_day_t1, l_year_t1);
     XTR_CALC_P.calc_days_run(rec.revldate, rec.maturity_date,
   	rec.year_calc_type, l_day_t2, l_year_t2);
     if rec.deal_subtype in ('BCAP', 'BFLOOR') then
    	l_side := 'A';
     else
    	l_side := 'B';
     end if;

-- Get volatility rate
     xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
    	C_VOLATILITY_IND, rec.revldate, rec.maturity_date,
    	rec.currencya, NULL, rec.year_calc_type,
    	C_INTERPOL_LINER, l_side, rec.batch_id, NULL);
     XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
     l_volatility := r_md_out.p_md_out;

     if rec.deal_subtype in ('BCAP', 'SCAP') then
    	l_side := 'A';
     else
    	l_side := 'B';
     end if;

-- get int rate between reval date and start date based on Actual/365
     xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
        C_YIELD_IND, rec.revldate, rec.start_date,
        rec.currencya, NULL, 'ACTUAL365',   -- bug 3509267
        C_INTERPOL_LINER, l_side, rec.batch_id, NULL);
     XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
     l_short_rate := r_md_out.p_md_out;

-- get int rate between reval date and maturity date based on Actual/365
     xtr_revl_mds_init(r_md_in, l_market_set, C_SOURCE,
        C_YIELD_IND, rec.revldate, rec.maturity_date,
        rec.currencya, NULL, 'ACTUAL365',    -- bug 3509267
        C_INTERPOL_LINER, l_side, rec.batch_id, NULL);
     XTR_MARKET_DATA_P.get_md_from_set(r_md_in, r_md_out);
     l_long_rate := r_md_out.p_md_out;

     if rec.pricing_model = C_P_MODEL_BLACK then
        r_black_in.p_principal    := rec.face_value;    -- deal face_value_amount
        r_black_in.p_strike_rate  := rec.transaction_rate;
        r_black_in.p_day_count_basis_strike := rec.year_calc_type;
        r_black_in.p_day_count_basis_short := 'ACTUAL365';
        r_black_in.p_day_count_basis_long := 'ACTUAL365';
        r_black_in.p_ir_short     := l_short_rate;
        r_black_in.p_ir_long      := l_long_rate;
        r_black_in.p_spot_date    := rec.revldate;
        r_black_in.p_start_date    := rec.start_date;
        r_black_in.p_maturity_date := rec.maturity_date;
        r_black_in.p_volatility := l_volatility;
        XTR_MM_COVERS.black_option_price_cv(r_black_in, r_black_out);
        rec.reval_rate := r_black_out.p_forward_forward_rate;

        if rec.deal_subtype in ('BCAP', 'SCAP') then
     		fair_value := r_black_out.p_caplet_price;
        else
      		fair_value := r_black_out.p_floorlet_price;
        end if;

	if rec.deal_subtype in ('SCAP', 'SFLOOR') then
	   fair_value := fair_value * (-1);
  	end if;
     else
        if rec.pricing_model is null then
    	   raise e_invalid_price_model;
        else
	   fair_value := null;
	   return;
	end if;
     end if;
  End If;

EXCEPTION
  when XTR_MARKET_DATA_P.e_mdcs_no_data_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_MARKET');
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_MARKETDATASET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when XTR_MARKET_DATA_P.e_mdcs_no_curve_found then
    if g_call_by_form = true then
      FND_MESSAGE.set_name('XTR', 'XTR_NO_CURVE');
      FND_MESSAGE.set_token('MARKET', rec.market_data_set);
      FND_MESSAGE.set_token('DEAL_NO', rec.deal_no);
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_CURVEMARKET');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no);
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_fv_iro');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
end xtr_revl_fv_iro;
--------------------------------------------------------
/*********************************************************/
/* This procedure returns fair value for deal type FRA   */
/*********************************************************/
PROCEDURE xtr_revl_fv_irs(
            rec IN OUT NOCOPY xtr_revl_rec,
            fair_value IN OUT NOCOPY NUMBER) IS
l_buf Varchar2(500);
l_trans_no       NUMBER;
l_start_date     DATE;
l_maturity_date  DATE;
l_settle_date	 DATE;
l_price_model    VARCHAR2(30);
l_market_set     VARCHAR2(30);
l_side        VARCHAR2(5);
l_day         NUMBER;
l_year        NUMBER;
l_pri_action  VARCHAR2(7);
l_pri_adjust  NUMBER;
l_acc_int     NUMBER;
l_balance_out NUMBER;
l_future_val  NUMBER;
l_principal   NUMBER;
l_coupon_cf   NUMBER;
l_coupon_rate NUMBER;
l_coupon_int  NUMBER;
l_int_settle  NUMBER;
l_int_rate    NUMBER;
l_accrued_int NUMBER;
l_last_rec_trans NUMBER;
l_fix_float   VARCHAR2(5);
l_round       NUMBER;
l_day_count_type VARCHAR2(1);
l_round_type     VARCHAR2(1);
l_deal_begin_date DATE;
l_max_trans_no   NUMBER;
l_first_trans_flag VARCHAR2(1);
l_interest	NUMBER;
l_margin        NUMBER;
r_err_log err_log; -- record type
retcode		NUMBER;

cursor c_roll is
select TRANSACTION_NUMBER, START_DATE, MATURITY_DATE, PRINCIPAL_ACTION,
       INTEREST_RATE, INTEREST_SETTLED, PRINCIPAL_ADJUST, ACCUM_INTEREST,
       BALANCE_OUT, SETTLE_TERM_INTEREST, INTEREST, SETTLE_DATE
from xtr_rollover_transactions
where DEAL_NUMBER = rec.deal_no
  and maturity_date >= rec.revldate
order by transaction_number asc;

Begin
 select rounding_factor
 into l_round
 from xtr_master_currencies_v
 where currency = rec.reval_ccy;

 select fixed_or_floating_rate, day_count_type, rounding_type, start_date, margin
 into l_fix_float, l_day_count_type, l_round_type, l_deal_begin_date,
      l_margin  -- Bug 3230779
 from XTR_DEALS_V
 where deal_no = rec.deal_no;

 select max(transaction_number)
 into l_max_trans_no
 from XTR_ROLLOVER_TRANSACTIONS_V
 where deal_number = rec.deal_no
 and start_date = l_deal_begin_date;

 l_market_set := rec.MARKET_DATA_SET;
 xtr_revl_get_mds(l_market_set, rec);

 for l_tmp in c_roll loop
    l_trans_no      := l_tmp.TRANSACTION_NUMBER;
    l_start_date    := l_tmp.START_DATE;
    l_maturity_date := l_tmp.MATURITY_DATE;
    l_settle_date   := l_tmp.SETTLE_DATE;
    l_pri_action    := l_tmp.PRINCIPAL_ACTION;
    l_pri_adjust    := nvl(l_tmp.PRINCIPAL_ADJUST, 0);
    l_acc_int       := l_tmp.ACCUM_INTEREST;
    l_balance_out   := l_tmp.BALANCE_OUT;
    l_int_settle    := l_tmp.INTEREST_SETTLED;
    l_int_rate      := l_tmp.INTEREST_RATE;
    l_interest      := l_tmp.INTEREST;
    l_principal     := 0;
    l_coupon_cf     := 0;
    l_accrued_int   := 0;

-- for Interest Overwrite project
    if l_day_count_type = 'B' and l_trans_no = l_max_trans_no then
        l_first_trans_flag := 'Y';
    else
        l_first_trans_flag := 'N';
    end if;

/*********************************************/
/* Calculate the present value of Principal  */
/*********************************************/
if rec.discount_yield = 'N' then  -- No principal cashflow
   l_principal := 0;
else   -- principal cashflow is exchanged
  if rec.revldate < l_start_date then
    if l_pri_adjust <> 0 then
      if l_pri_action = 'INCRSE' then
         if(rec.deal_subtype = 'FUND') then
            l_side := 'B';
         else
            l_side := 'A';
         end if;
         l_future_val := l_pri_adjust;

        xtr_revl_present_value_tmm(rec, rec.batch_id, rec.year_calc_type,
        rec.revldate, l_start_date, l_future_val, rec.currencya,
        l_market_set, l_side, l_principal);
      elsif l_pri_action = 'DECRSE' then
        if(rec.deal_subtype = 'FUND') then
           l_side := 'A';
        else
           l_side := 'B';
        end if;
        l_future_val := l_pri_adjust;
        xtr_revl_present_value_tmm(rec, rec.batch_id, rec.year_calc_type,
        rec.revldate, l_start_date, l_future_val, rec.currencya,
        l_market_set, l_side, l_principal);
      end if;
    else
      l_principal := 0;
    end if;
    l_principal := round(l_principal, l_round);
  end if;
end if;

  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_fv_irs: ' || 'IRS_PRINCIPAL');
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'trans no', l_trans_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'year_calc_type', rec.year_calc_type);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'l_start_date', l_start_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'l_future_val', l_future_val);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'rec.currencya', rec.currencya);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'l_market_set', l_market_set);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'l_side', l_side);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'l_principal', l_principal);
     xtr_risk_debug_pkg.dpop('xtr_revl_fv_irs: ' || 'IRS_PRINCIPAL');
  END IF;

  if(rec.deal_subtype = 'FUND') then
    l_side := 'A';
  else
    l_side := 'B';
  end if;

/****************************************************/
/* Calculate the present value of Coupon(Interest)  */
/****************************************************/
 if  l_fix_float = 'FIXED' then -- fixed rate
    l_future_val  := l_int_settle;
    l_coupon_rate := l_int_rate;
    xtr_revl_present_value_tmm(rec, rec.batch_id, rec.year_calc_type,
      rec.revldate, l_settle_date, l_future_val, rec.currencya,
      l_market_set, l_side, l_coupon_cf);

     l_coupon_int := l_interest;
 else   -- floating rate
    if rec.revldate > l_start_date then
      l_coupon_rate := l_int_rate;
      rec.reval_rate := l_coupon_rate;
    else
      rec.trans_no := l_trans_no;
      xtr_revl_getprice_fwd(rec, TRUE, l_coupon_rate);
      rec.reval_rate := l_coupon_rate + nvl(l_margin, 0)/100; -- bug 3230779
    end if;  -- rec.revldate >

    if rec.pricing_model = 'DISC_CASHFLOW' then
       l_coupon_int := xtr_calc_interest(l_balance_out,
       l_start_date, l_maturity_date, rec.reval_rate,
       rec.year_calc_type);
    else   -- 'DISC_CASHSTA' take user overwriten interest from IRS deal
       l_coupon_int := l_interest;
    end if;

  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_fv_irs: ' || 'IRS_REVAL_RATE');
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'trans no', l_trans_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'rec.revldate', rec.revldate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'l_start_date', l_start_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'l_int_rate', l_int_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'l_coupon_rate', l_coupon_rate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'rec.reval_rate', rec.reval_rate);
     xtr_risk_debug_pkg.dpop('xtr_revl_fv_irs: ' || 'IRS_REVAL_RATE');
  END IF;

/* for Interest Overwrite project
    l_coupon_int := xtr_calc_interest(l_balance_out,
      l_start_date, l_maturity_date, l_coupon_rate,
      rec.year_calc_type);   */
--    l_coupon_int := l_interest;

    if rec.deal_subtype = 'FUND' then
       l_side := 'A';
    else
        l_side := 'B';
    end if;
    l_future_val := l_coupon_int;
    xtr_revl_present_value_tmm(rec, rec.batch_id, rec.year_calc_type,
        rec.revldate, l_settle_date, l_future_val, rec.currencya,
        l_market_set, l_side, l_coupon_cf);

-- for Interest Overwrite project
    if l_round_type = 'U' then
       l_coupon_cf := xtr_fps2_p.roundup(l_coupon_cf, l_round);
    elsif l_round_type = 'T' then
       l_coupon_cf := trunc(l_coupon_cf, l_round);
    else
       l_coupon_cf := round(l_coupon_cf, l_round);
    end if;
  end if;

  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('xtr_revl_fv_irs: ' || 'IRS_INTEREST');
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'trans no', l_trans_no);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'year_calc_type', rec.year_calc_type);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'rec.revldate', rec.revldate);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'l_maturity_date', l_maturity_date);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'l_future_val', l_future_val);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'rec.currencya', rec.currencya);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'l_market_set', l_market_set);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'l_side', l_side);
     xtr_risk_debug_pkg.dlog('xtr_revl_fv_irs: ' || 'l_coupon_cf', l_coupon_cf);
     xtr_risk_debug_pkg.dpop('xtr_revl_fv_irs: ' || 'IRS_INTEREST');
  END IF;

-- for Interest Overwrite project
  if rec.revldate  > l_start_date then
    if rec.revldate = l_maturity_date then
	l_accrued_int := l_coupon_int;
    else
      if  l_fix_float = 'FIXED' then -- Bug 3230779
           l_accrued_int := xtr_calc_interest(l_balance_out, l_start_date,
            rec.revldate, l_coupon_rate, rec.year_calc_type,
            l_day_count_type, l_first_trans_flag);
        else  -- floating leg
           l_accrued_int := xtr_calc_interest(l_balance_out, l_start_date,
	       rec.revldate, l_coupon_rate, rec.year_calc_type,
	       l_day_count_type, l_first_trans_flag);
     end if;
   end if;

    if l_round_type = 'U' then
       l_accrued_int := xtr_fps2_p.roundup(l_accrued_int, l_round);
    elsif l_round_type = 'T' then
       l_accrued_int := trunc(l_accrued_int, l_round);
    else
       l_accrued_int := round(l_accrued_int, l_round);
    end if;
  end if;

  fair_value := nvl(fair_value,0) + nvl(l_principal,0)
                + nvl(l_coupon_cf,0) - nvl(l_accrued_int,0);
  End loop;
  if rec.deal_subtype = 'FUND' then
     fair_value := fair_value * (-1);
  end if;

  rec.trans_no := 1;
EXCEPTION
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_revl_fv_irs');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
end xtr_revl_fv_irs;

-------------------------------------------------------------
/*******************************************************/
/* This function return interest base on principle,    */
/* rate and number of days                             */
/*******************************************************/
FUNCTION xtr_calc_interest(
          p_principle  IN NUMBER,
          p_start_date IN DATE,
          p_end_date IN DATE,
          p_rate IN NUMBER,
          p_day_count_basis IN VARCHAR2,
	  p_day_count_type IN VARCHAR2,
	  p_first_trans_flag IN VARCHAR2) return NUMBER IS

l_day  NUMBER;
l_year NUMBER;
begin
  XTR_CALC_P.calc_days_run(p_start_date, p_end_date,
   p_day_count_basis, l_day, l_year, null, p_day_count_type, p_first_trans_flag);
  return (p_principle * p_rate * l_day) / (l_year * 100);
end xtr_calc_interest;
--------------------------------------------------------
/*********************************************************/
/* This procedure returns base and contra currency info  */
/* from system rate setup.Also return TRUE               */
/* if we need to invert base and contra                  */
/*********************************************************/
PROCEDURE xtr_get_base_contra(
          p_base  IN OUT NOCOPY VARCHAR2,
          p_contra  IN OUT NOCOPY VARCHAR2,
          p_reverse  OUT NOCOPY BOOLEAN) IS

l_cur VARCHAR2(15) := NULL;
cursor c_cur is
select CURRENCY_FIRST
from XTR_BUY_SELL_COMBINATIONS
where (CURRENCY_BUY = p_base and CURRENCY_SELL = p_contra)
    or (CURRENCY_BUY = p_contra and CURRENCY_SELL = p_base);

begin
  for l_tmp in c_cur loop
    l_cur := l_tmp.CURRENCY_FIRST;
  end loop;

  if l_cur = p_base then
    p_reverse := false;
  else
    -- swap it
    p_reverse := true;
    p_contra := p_base;
    p_base := l_cur;
  end if;

end xtr_get_base_contra;
----------------------------------------------------------------
/**********************************************************/
/* This procedure returns NI discount amount and effective*/
/* interest for calculatin NI unrealized P/L              */
/**********************************************************/
PROCEDURE xtr_ni_eff_interest(
	rec IN xtr_revl_rec,
        pre_disc_amt IN NUMBER,
	disc_amount OUT NOCOPY NUMBER,
	eff_interest OUT NOCOPY NUMBER) IS
l_buf Varchar2(500);
l_all_in_rate NUMBER;
l_dummy	      NUMBER;
l_disc_yield  VARCHAR2(1);
l_round       NUMBER;
l_no_of_days  NUMBER;
l_year_basis  NUMBER;
r_err_log err_log; -- record type
retcode		NUMBER;
l_rounding_type VARCHAR2(10);

Begin
   select rounding_factor
   into l_round
   from xtr_master_currencies_v
   where currency = rec.reval_ccy;

  select all_in_rate,  rounding_type
  into l_all_in_rate,  l_rounding_type  -- 5130446
  from xtr_rollover_transactions, xtr_deals
  where deal_number = rec.deal_no
    and deal_number= deal_no
    and transaction_number = rec.trans_no;

  if rec.discount_yield = 'Y' then -- 'DISCOUNT'
     l_disc_yield := 'D';
  else     			   -- 'YIELD'
     l_disc_yield := 'Y';
  end if;

  XTR_ACCRUAL_PROCESS_P.calculate_effective_interest(
  rec.face_value, l_all_in_rate, rec.start_date, rec.revldate,
  rec.maturity_date, 'Y', rec.year_calc_type, l_disc_yield, pre_disc_amt,
  l_no_of_days, l_year_basis, disc_amount, eff_interest);

  eff_interest := xtr_fps2_p.interest_round(eff_interest,l_round,l_rounding_type);  --bug 5130446

  xtr_risk_debug_pkg.dpush('EFF_INTEREST');
   xtr_risk_debug_pkg.dlog('face value', rec.face_value);
   xtr_risk_debug_pkg.dlog('all in rate', l_all_in_rate);
   xtr_risk_debug_pkg.dlog('batch end date', rec.revldate);
   xtr_risk_debug_pkg.dlog('maturity date', rec.maturity_date);
   xtr_risk_debug_pkg.dlog('disc_yield', l_disc_yield);
   xtr_risk_debug_pkg.dlog('pre disc amt', pre_disc_amt);
   xtr_risk_debug_pkg.dlog('no of days', l_no_of_days);
   xtr_risk_debug_pkg.dlog('year basis', l_year_basis);
   xtr_risk_debug_pkg.dlog('disc amount', disc_amount);
   xtr_risk_debug_pkg.dlog('effective interest', eff_interest);
   xtr_risk_debug_pkg.dpop('EFF_INTEREST');

EXCEPTION
  when others then
    if g_call_by_form = true then
      APP_EXCEPTION.raise_exception;
    else
      set_err_log(retcode);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_SQL_FAILURE');
      FND_MESSAGE.SET_TOKEN('DEAL_NO', rec.deal_no);
      FND_MESSAGE.SET_TOKEN('DEAL_TYPE', rec.deal_type);
      FND_MESSAGE.SET_TOKEN('TRANS_NO', rec.trans_no||' in procedure xtr_ni_eff_interest');
      l_buf := FND_MESSAGE.GET;
      FND_FILE.put_line(fnd_file.log, l_buf);
    end if;
End;
--------------------------------------------------------
/*******************************************************/
/* This procedure gathers necessary information from   */
/* XTR_MARKET_DATA table for calcuating the spot rate  */
/* or interest rate                                    */
/*******************************************************/
PROCEDURE xtr_revl_mds_init(
   rec       out NOCOPY XTR_MARKET_DATA_P.md_from_set_in_rec_type,
   p_md_set_code          VARCHAR2,
   p_source               VARCHAR2,
   p_indicator            VARCHAR2,
   p_spot_date            DATE,
   p_future_date          DATE,
   p_ccy                  VARCHAR2,
   p_contra_ccy           VARCHAR2,
   p_day_count_basis_out  VARCHAR2,
   p_interpolation_method VARCHAR2,
   p_side                 VARCHAR2,
   p_batch_id             NUMBER,
   p_bond_code            VARCHAR2) IS

begin
  if (p_future_date is not NULL and
      p_spot_date > p_future_date) then
    raise e_date_order_error;
  end if;
  rec.p_md_set_code := p_md_set_code;
  rec.p_source := p_source;
  rec.p_indicator := p_indicator;
  rec.p_spot_date := p_spot_date;
  rec.p_future_date := p_future_date;
  rec.p_ccy := p_ccy;
  rec.p_contra_ccy := p_contra_ccy;
  rec.p_day_count_basis_out := p_day_count_basis_out;
  rec.p_interpolation_method := p_interpolation_method;
  rec.p_side := p_side;
  rec.p_batch_id := p_batch_id;
  rec.p_bond_code := p_bond_code;

end xtr_revl_mds_init;

--------------------------------------------------------
/************************************************************/
/* this flag determine the error message will write to the  */
/* log or prompt to the user immediately                    */
/************************************************************/
PROCEDURE set_call_by_curr IS
begin
  g_call_by_form := FALSE;
end set_call_by_curr;

--------------------------------------------------------
PROCEDURE set_call_by_form IS
begin
  g_call_by_form := TRUE;
end set_call_by_form;

--------------------------------------------------------
PROCEDURE set_err_log(retcode OUT NOCOPY NUMBER) IS
begin
  g_status := 1;
  retcode := 1;
end set_err_log;

-------------------------------------------------------------
/************************************************************/
/* This procedure writes the t_log array to concurrent      */
/* program default output file                              */
/************************************************************/
PROCEDURE t_log_dump is
  l_tmp NUMBER := 1;
  l_buf VARCHAR2(300);
  l_dirname VARCHAR2(512);

begin
  if t_log_count = 0 then
    return;
  end if;

  while (l_tmp<=t_log_count) loop
    l_buf := 'Deal number: '|| t_log(l_tmp).deal_id ||
             '  Deal type: '|| t_log(l_tmp).deal_type;

    if t_log(l_tmp).err_warn = 0 then  -- This is a warning
      l_buf := l_buf || '  Warning: ' || t_log(l_tmp).log;
    Else
      if t_log(l_tmp).trans_no is NULL then
        l_buf := l_buf || '  Error: ' || t_log(l_tmp).log;
      else
        l_buf := l_buf || '  Transaction no: ' ||
               t_log(l_tmp).trans_no ||  '  Error: ' ||
               t_log(l_tmp).log;
      end if;
    End If;
    fnd_file.put_line(fnd_file.log, l_buf);
    l_tmp := l_tmp + 1;
  end loop;
fnd_file.close;
end t_log_dump;

--------------------------------------------------------
PROCEDURE t_log_init is
begin
  t_log.delete;
end t_log_init;

--------------------------------------------------------
FUNCTION t_log_count return NUMBER is
begin
  return t_log.count;
end t_log_count;

--------------------------------------------------------
/*****************************************************************/
/* This procedure insert unrealized values into xtr_revaluation_details table*/
/* Also update xtr_deals and xtr_rollover_transactions,           */
/* xtr_bank_balance, xtr_intergroup_transfers                     */
/******************************************************************/
PROCEDURE xtr_revl_unreal_log(
     rec IN xtr_revl_rec,
     unrel_pl_value IN NUMBER,
     cum_pl_value IN NUMBER,
     fv_sob_amt IN NUMBER,
     unrel_sob_gl IN NUMBER,
     currency_gl IN NUMBER,
     r in XTR_REVALUATION_DETAILS%rowtype,
     retcode  OUT NOCOPY NUMBER,
     p_hedge_flag IN VARCHAR2 DEFAULT NULL) IS

l_ROWID     VARCHAR2(20);
l_reval_detail_id NUMBER;
l_event_id   XTR_BATCH_EVENTS.BATCH_EVENT_ID%TYPE;
l_sysdate   DATE := trunc(sysdate);
l_complete  VARCHAR2(1);
l_deal_rowid VARCHAR2(30);
r_err_log err_log; -- record type

 Cursor CHK_LOCK_DEAL is
 select rowid
  from  XTR_DEALS
 where  DEAL_NO = rec.deal_no
   and  DEAL_TYPE not in ('NI', 'ONC', 'CA', 'IG')
   and  FIRST_REVAL_BATCH_ID is null
   for  update of FIRST_REVAL_BATCH_ID NOWAIT;

 Cursor CHK_LOCK_ROLL is
  select rowid
   from  XTR_ROLLOVER_TRANSACTIONS
   Where  DEAL_NUMBER = rec.deal_no
   And    TRANSACTION_NUMBER = rec.trans_no
   And    DEAL_TYPE = 'NI'
   And    FIRST_REVAL_BATCH_ID is null
   for  update of FIRST_REVAL_BATCH_ID NOWAIT;

 Cursor CHK_LOCK_HEDGE is
 select rowid
 from XTR_HEDGE_ATTRIBUTES
 where hedge_attribute_id = rec.deal_no
 and first_batch_id is NULL
 for update of first_batch_id NOWAIT;

 Cursor CHK_LAST_HEDGE is
 select rowid
 from XTR_HEDGE_ATTRIBUTES
 where hedge_attribute_id = rec.deal_no
 and last_batch_id is NULL
 for update of last_batch_id NOWAIT;


begin
    select XTR_REVALUATION_DETAILS_S.NEXTVAL
    into l_reval_detail_id from DUAL;

-- we consider the deal is complete if all FV P/L and currency G/L has been derived
    if rec.fair_value is not null and currency_gl is not null
       and p_hedge_flag is NULL then
	l_complete := 'Y';
    else
        l_complete := 'N';
    End if;

    XTR_REVALUATION_DETAILS_PKG.INSERT_ROW(
	X_ROWID 		=> l_ROWID,
	X_REVALUATION_DETAILS_ID=> l_reval_detail_id,
	X_REVAL_CURR_FV_AMOUNT  => rec.fair_value,
	X_COMPLETE_FLAG		=> l_complete,
	X_FAIR_VALUE		=> rec.fair_value,
	X_CUMM_GAIN_LOSS_AMOUNT => cum_pl_value,
	X_CURR_GAIN_LOSS_AMOUNT => currency_gl,
	X_SOB_FV_GAIN_LOSS_AMOUNT => unrel_sob_gl,
	X_SOB_FAIR_VALUE_AMOUNT => fv_sob_amt,
	X_CTR_CURR_SOB_CURR_FWD_RATE => rec.reval_fx_fwd_rate,
	X_EXCHANGE_RATE_TWO     => rec.reval_ex_rate_two,
	X_ACTION_CODE		=> null,  -- obsolete
	X_COMPANY_CODE		=> rec.company_code,
	X_CONTRACT_CODE		=> rec.CONTRACT_CODE,
	X_CURRENCYA		=> rec.CURRENCYA,
	X_CURRENCYB		=> rec.CURRENCYB,
	X_DEAL_NO		=> rec.deal_no,
	X_DEAL_SUBTYPE		=> rec.deal_subtype,
	X_DEAL_TYPE		=> rec.deal_type,
	X_EFFECTIVE_DATE	=> rec.EFFECTIVE_DATE,
	X_EFFECTIVE_DAYS	=> r.EFFECTIVE_DAYS,
	X_ENTERED_BY		=> fnd_global.user_id,
	X_ENTERED_ON		=> l_sysdate,
	X_FACE_VALUE		=> rec.FACE_VALUE,
	X_FXO_SELL_REF_AMOUNT	=> rec.FXO_SELL_REF_AMOUNT,
	X_PERIOD_FROM		=> rec.period_start,
	X_PERIOD_TO		=> rec.period_end,
	X_PORTFOLIO_CODE	=> rec.PORTFOLIO_CODE,
	X_PRODUCT_TYPE		=> nvl(rec.PRODUCT_TYPE, 'NOT APPLIC'),
	X_REALISED_PL		=> null,
	X_REVAL_CCY		=> rec.REVAL_CCY,
	X_REVAL_RATE		=> rec.REVAL_RATE,
	X_TRANSACTION_NO	=> rec.trans_no,
	X_TRANSACTION_PERIOD	=> r.TRANSACTION_PERIOD,
	X_TRANSACTION_RATE	=> rec.TRANSACTION_RATE,
	X_UNREALISED_PL		=> unrel_pl_value,
	X_UPDATED_BY		=> fnd_global.user_id,
	X_UPDATED_ON		=> l_sysdate,
	X_YEAR_BASIS		=> rec.YEAR_BASIS,
	X_CREATED_ON		=> l_sysdate,
	X_EXCHANGE_RATE_ONE	=> rec.reval_ex_rate_one,
	X_REALIZED_FLAG		=> 'N',
	X_OVERWRITE_TYPE	=> rec.ow_type,
	X_OVERWRITE_VALUE	=> rec.ow_value,
	X_OVERWRITE_REASON	=> null,
	X_BATCH_ID		=> rec.batch_id,
	X_CREATED_BY		=> fnd_global.user_id,
        X_ACCOUNT_NO		=> rec.account_no,
	X_SWAP_REF		=> rec.swap_ref,
	X_NI_DISC_AMOUNT        => rec.ni_disc_amount,
	X_AMOUNT_TYPE		=> nvl(r.amount_type, 'UNREAL'),
	X_QUANTITY		=> rec.quantity
    );

-- Insert FIRST_REVAL_BATCH_ID to deal table for the first time revaluation
-- For NI and ONC, we insert into Rollover table, other deal types go to XTR_DEALS

   Open CHK_LOCK_DEAL;
   Fetch CHK_LOCK_DEAL into l_deal_rowid;
   if CHK_LOCK_DEAL%FOUND then
      Update XTR_DEALS
      Set FIRST_REVAL_BATCH_ID = rec.batch_id,
          EXCHANGE_RATE_ONE = rec.deal_ex_rate_one,
          EXCHANGE_RATE_TWO = rec.deal_ex_rate_two
      Where rowid = l_deal_rowid;
      close CHK_LOCK_DEAL;
   else
      Close CHK_LOCK_DEAL;
   end if;

   Open CHK_LOCK_ROLL;
   Fetch CHK_LOCK_ROLL into l_deal_rowid;
   if CHK_LOCK_ROLL%FOUND then
      Update XTR_ROLLOVER_TRANSACTIONS
      Set FIRST_REVAL_BATCH_ID = rec.batch_id,
          CURRENCY_EXCHANGE_RATE = rec.deal_ex_rate_one
      Where rowid = l_deal_rowid;
      close CHK_LOCK_ROLL;
   else
      Close CHK_LOCK_ROLL;
   end if;

   if rec.deal_type = 'HEDGE' then
      Open CHK_LOCK_HEDGE;
      Fetch CHK_LOCK_HEDGE into l_deal_rowid;
      if CHK_LOCK_HEDGE%FOUND then
         Update XTR_HEDGE_ATTRIBUTES
         Set FIRST_BATCH_ID = rec.batch_id,
	     INIT_FAIR_VALUE_RATE = rec.deal_ex_rate_one
         Where rowid = l_deal_rowid;
         close CHK_LOCK_HEDGE;
      else
         Close CHK_LOCK_HEDGE;
      end if;

      if rec.effective_date <= rec.revldate then
        Open CHK_LAST_HEDGE;
         Fetch CHK_LAST_HEDGE into l_deaL_rowid;
         if CHK_LAST_HEDGE%FOUND then
            Update XTR_HEDGE_ATTRIBUTES
            Set LAST_BATCH_ID = rec.batch_id
            Where rowid = l_deal_rowid;
            close CHK_LAST_HEDGE;
         else
            Close CHK_LAST_HEDGE;
         end if;
      end if;
  end if;

Exception
When app_exceptions.RECORD_LOCK_EXCEPTION then
  if CHK_LOCK_DEAL%ISOPEN then
     close CHK_LOCK_DEAL;
  end if;

  if CHK_LOCK_ROLL%ISOPEN then
     close CHK_LOCK_ROLL;
  end if;

  if CHK_LOCK_HEDGE%ISOPEN then
     close CHK_LOCK_HEDGE;
  end if;

  if CHK_LAST_HEDGE%ISOPEN then
     close CHK_LAST_HEDGE;
  end if;
  FND_MESSAGE.Set_name('XTR', 'XTR_DEAL_LOCK');
  FND_MESSAGE.Set_token('DEAL_NO', rec.deal_no);
  FND_MESSAGE.Set_token('DEAL_TYPE', rec.deal_type);
  Raise app_exceptions.RECORD_LOCK_EXCEPTION;

end xtr_revl_unreal_log;

--------------------------------------------------------------------
/*****************************************************************/
/* This procedure insert realized values into xtr_revaluation_details table*/
/* Also update xtr_deals and xtr_rollover_transactions,           */
/* xtr_bank_balance, xtr_intergroup_transfers                     */
/******************************************************************/
PROCEDURE xtr_revl_real_log (
                     rec IN xtr_revl_rec,
                     rel_pl_value IN NUMBER,
		     fv_sob_amt IN NUMBER,
                     rel_sob_gl IN NUMBER,
                     currency_gl IN NUMBER,
                     r in XTR_REVALUATION_DETAILS%rowtype,
                     retcode  OUT NOCOPY NUMBER) IS

l_ROWID     VARCHAR2(20);
l_reval_detail_id NUMBER;
l_event_id   XTR_BATCH_EVENTS.BATCH_EVENT_ID%TYPE;
l_sysdate   DATE := trunc(sysdate);
l_complete  VARCHAR2(1);
l_deal_rowid VARCHAR2(30);
r_err_log err_log; -- record type

 Cursor CHK_LOCK_DEAL is
 select rowid
  from  XTR_DEALS
 where  DEAL_NO = rec.deal_no
   and  ((DEAL_TYPE not in ('NI', 'ONC', 'CA', 'IG', 'BOND', 'STOCK','TMM', 'IRS'))
         or (DEAL_TYPE in ('TMM', 'IRS') and rec.effective_date <= rec.revldate))
   for  update of FIRST_REVAL_BATCH_ID NOWAIT;

 Cursor CHK_LOCK_ROLL is
  select rowid
   from  XTR_ROLLOVER_TRANSACTIONS
   Where  DEAL_NUMBER = rec.deal_no
   And    TRANSACTION_NUMBER = rec.trans_no
   And    DEAL_TYPE = 'NI'
   for  update of FIRST_REVAL_BATCH_ID NOWAIT;

begin
    select XTR_REVALUATION_DETAILS_S.NEXTVAL
    into l_reval_detail_id from DUAL;

-- we consider the deal is complete if all FV P/L and currency G/L has been derived
    if rec.fair_value is not null  and currency_gl is not null then
        l_complete := 'Y';
    else
        l_complete := 'N';
    End if;

    XTR_REVALUATION_DETAILS_PKG.INSERT_ROW(
        X_ROWID                 => l_ROWID,
	X_REVALUATION_DETAILS_ID=> l_reval_detail_id,
        X_REVAL_CURR_FV_AMOUNT  => rec.fair_value,
        X_COMPLETE_FLAG         => l_complete,
        X_FAIR_VALUE            => rec.fair_value,
        X_CUMM_GAIN_LOSS_AMOUNT => 0,
        X_CURR_GAIN_LOSS_AMOUNT => currency_gl,
        X_SOB_FV_GAIN_LOSS_AMOUNT => rel_sob_gl,
        X_SOB_FAIR_VALUE_AMOUNT => fv_sob_amt,
        X_CTR_CURR_SOB_CURR_FWD_RATE => rec.reval_fx_fwd_rate,
        X_EXCHANGE_RATE_TWO     => rec.reval_ex_rate_two,
        X_ACTION_CODE           => null,  -- obsolete
        X_COMPANY_CODE          => rec.company_code,
        X_CONTRACT_CODE         => rec.CONTRACT_CODE,
        X_CURRENCYA             => rec.CURRENCYA,
        X_CURRENCYB             => rec.CURRENCYB,
        X_DEAL_NO               => rec.deal_no,
        X_DEAL_SUBTYPE          => rec.deal_subtype,
        X_DEAL_TYPE             => rec.deal_type,
        X_EFFECTIVE_DATE        => rec.EFFECTIVE_DATE,
        X_EFFECTIVE_DAYS        => r.EFFECTIVE_DAYS,
        X_ENTERED_BY            => fnd_global.user_id,
        X_ENTERED_ON            => l_sysdate,
        X_FACE_VALUE            => rec.FACE_VALUE,
        X_FXO_SELL_REF_AMOUNT   => rec.FXO_SELL_REF_AMOUNT,
        X_PERIOD_FROM           => rec.period_start,
        X_PERIOD_TO             => rec.period_end,
        X_PORTFOLIO_CODE        => rec.portfolio_code,
        X_PRODUCT_TYPE          => nvl(rec.PRODUCT_TYPE, 'NOT APPLICABLE'),
        X_REALISED_PL           => rel_pl_value,
        X_REVAL_CCY             => rec.REVAL_CCY,
        X_REVAL_RATE            => rec.REVAL_RATE,
        X_TRANSACTION_NO        => rec.trans_no,
        X_TRANSACTION_PERIOD    => r.TRANSACTION_PERIOD,
        X_TRANSACTION_RATE      => rec.TRANSACTION_RATE,
        X_UNREALISED_PL         => null,
        X_UPDATED_BY            => fnd_global.user_id,
        X_UPDATED_ON            => l_sysdate,
        X_YEAR_BASIS            => rec.YEAR_BASIS,
        X_CREATED_ON            => l_sysdate,
        X_EXCHANGE_RATE_ONE     => rec.reval_ex_rate_one,
        X_REALIZED_FLAG         => 'Y',
        X_OVERWRITE_TYPE        => rec.ow_type,
        X_OVERWRITE_VALUE       => rec.ow_value,
        X_OVERWRITE_REASON      => null,
        X_BATCH_ID              => rec.batch_id,
        X_CREATED_BY            => fnd_global.user_id,
        X_ACCOUNT_NO            => rec.account_no,
        X_SWAP_REF              => rec.swap_ref,
        X_NI_DISC_AMOUNT        => rec.ni_disc_amount,
	X_AMOUNT_TYPE		=> nvl(r.amount_type, 'REAL'),
	X_QUANTITY		=> rec.quantity
    );

-- Insert LAST_REVAL_BATCH_ID to deal table once realized G/L has obtained.
-- For NI and ONC, we insert into Rollover table, other deal types go to XTR_DEALS

   Open CHK_LOCK_DEAL;
   Fetch CHK_LOCK_DEAL into l_deal_rowid;
   if CHK_LOCK_DEAL%FOUND then
      close CHK_LOCK_DEAL;
      Update XTR_DEALS
      Set LAST_REVAL_BATCH_ID = rec.batch_id
      Where rowid = l_deal_rowid;
   else
      Close CHK_LOCK_DEAL;
   end if;

   Open CHK_LOCK_ROLL;
   Fetch CHK_LOCK_ROLL into l_deal_rowid;
   if CHK_LOCK_ROLL%FOUND then
      close CHK_LOCK_ROLL;
      Update XTR_ROLLOVER_TRANSACTIONS
      Set LAST_REVAL_BATCH_ID = rec.batch_id
      Where rowid = l_deal_rowid;
   else
      Close CHK_LOCK_ROLL;
   end if;

Exception
When app_exceptions.RECORD_LOCK_EXCEPTION then
  if CHK_LOCK_DEAL%ISOPEN then
     close CHK_LOCK_DEAL;
  end if;

  if CHK_LOCK_ROLL%ISOPEN then
     close CHK_LOCK_ROLL;
  end if;

  FND_MESSAGE.Set_name('XTR', 'XTR_DEAL_LOCK');
  FND_MESSAGE.Set_token('DEAL_NO', rec.deal_no);
  FND_MESSAGE.Set_token('DEAL_TYPE', rec.deal_type);
  Raise app_exceptions.RECORD_LOCK_EXCEPTION;

end xtr_revl_real_log;

------------------------------------------------------------------------------
/***********************************************************/
/* This procedure insert value into XTR_BATCH_EVENTS table */
/***********************************************************/
PROCEDURE xtr_insert_event(
                     p_batch_ID  IN NUMBER) is

Cursor CHK_BATCH_RUN is
Select 'Y'
From   XTR_BATCH_EVENTS
Where  batch_id = p_batch_id
and    event_code = 'REVAL';

l_event_id    XTR_BATCH_EVENTS.BATCH_EVENT_ID%TYPE;
l_sysdate    DATE := trunc(sysdate);
l_cur	     VARCHAR2(1);
Begin
 Open CHK_BATCH_RUN;
 Fetch CHK_BATCH_RUN into l_cur;
 If CHK_BATCH_RUN%FOUND then -- the current batch has run
    Close CHK_BATCH_RUN;
    Raise e_batch_been_run;
 End If;
    Close CHK_BATCH_RUN;

--  insert new row to XTR_BATCH_EVENTS table
        select XTR_BATCH_EVENTS_S.NEXTVAL
        into l_event_id from DUAL;

      Insert into XTR_BATCH_EVENTS(batch_event_id, batch_id, event_code, authorized,
                                   authorized_by, authorized_on, created_by, creation_date,
                                   last_updated_by, last_update_date, last_update_login)
      values(l_event_id, p_batch_id, 'REVAL', 'N', null, null, fnd_global.user_id,
             l_sysdate, fnd_global.user_id, l_sysdate, fnd_global.login_id);

EXCEPTION
 When e_batch_been_run then
   FND_MESSAGE.Set_Name('XTR', 'XTR_BATCH_IN_REVAL');
   FND_MESSAGE.Set_Token('BATCH', p_batch_id);
   APP_EXCEPTION.raise_exception;

End;
--------------------------------------------------------
PROCEDURE dump_xtr_mds_rec(
   p_name IN VARCHAR2,
   rec in XTR_MARKET_DATA_P.md_from_set_in_rec_type) IS

begin
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('dump_xtr_mds_rec: ' || p_name);
     xtr_risk_debug_pkg.dlog('dump_xtr_mds_rec: ' || 'mds set code',rec.p_md_set_code);
     xtr_risk_debug_pkg.dlog('dump_xtr_mds_rec: ' || 'source', rec.p_source);
     xtr_risk_debug_pkg.dlog('dump_xtr_mds_rec: ' || 'ind', rec.p_indicator);
     xtr_risk_debug_pkg.dlog('dump_xtr_mds_rec: ' || 'spot date', rec.p_spot_date);
     xtr_risk_debug_pkg.dlog('dump_xtr_mds_rec: ' || 'future date', rec.p_future_date);
     xtr_risk_debug_pkg.dlog('dump_xtr_mds_rec: ' || 'currency', rec.p_ccy);
     xtr_risk_debug_pkg.dlog('dump_xtr_mds_rec: ' || 'contra ccy', rec.p_contra_ccy);
     xtr_risk_debug_pkg.dlog('dump_xtr_mds_rec: ' || 'day count basis', rec.p_day_count_basis_out);
     xtr_risk_debug_pkg.dlog('dump_xtr_mds_rec: ' || 'interpolation', rec.p_interpolation_method);
     xtr_risk_debug_pkg.dlog('dump_xtr_mds_rec: ' || 'side', rec.p_side);
     xtr_risk_debug_pkg.dlog('dump_xtr_mds_rec: ' || 'batch id', rec.p_batch_id);
     xtr_risk_debug_pkg.dlog('dump_xtr_mds_rec: ' || 'bond code', rec.p_bond_code);
     xtr_risk_debug_pkg.dpop('dump_xtr_mds_rec: ' || p_name);
  END IF;

end dump_xtr_mds_rec;

--------------------------------------------------------
PROCEDURE dump_xtr_revl_rec(
            p_name IN VARCHAR2,
            rec IN xtr_revl_rec) is
begin
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('dump_xtr_revl_rec: ' || p_name);
     xtr_risk_debug_pkg.dlog('dump_xtr_revl_rec: ' || 'company_code', rec.company_code);
     xtr_risk_debug_pkg.dlog('dump_xtr_revl_rec: ' || 'deal_no', rec.deal_no);
     xtr_risk_debug_pkg.dlog('dump_xtr_revl_rec: ' || 'deal_type', rec.deal_type);
     xtr_risk_debug_pkg.dlog('dump_xtr_revl_rec: ' || 'deal_subtype', rec.deal_subtype);
     xtr_risk_debug_pkg.dlog('dump_xtr_revl_rec: ' || 'batch_id', rec.batch_id);
     xtr_risk_debug_pkg.dlog('dump_xtr_revl_rec: ' || 'fair_value', rec.fair_value);
     xtr_risk_debug_pkg.dlog('dump_xtr_revl_rec: ' || 'trans_no', rec.trans_no);
     xtr_risk_debug_pkg.dlog('dump_xtr_revl_rec: ' || 'ow_type', rec.ow_type);
     xtr_risk_debug_pkg.dlog('dump_xtr_revl_rec: ' || 'ow_value', rec.ow_value);
     xtr_risk_debug_pkg.dlog('dump_xtr_revl_rec: ' || 'revldate', rec.revldate);
     xtr_risk_debug_pkg.dpop('dump_xtr_revl_rec: ' || p_name);
  END IF;

end dump_xtr_revl_rec;

--------------------------------------------------------
/* this procedure should retire later once the new deal
input form the market data set become a not null field or
has default value.
*/

PROCEDURE xtr_revl_get_mds(
    p_mds IN OUT NOCOPY VARCHAR2,
    rec   IN xtr_revl_rec) is

cursor c_mds is
select DEFAULT_MARKET_DATA_SET
from xtr_product_types
where DEAL_TYPE = rec.deal_type and
      PRODUCT_TYPE = rec.product_type;

begin
  if p_mds is not null then
    return;
  end if;

  for l_tmp in c_mds loop
    p_mds := l_tmp.DEFAULT_MARKET_DATA_SET;
  end loop;


  if p_mds is not null then
    return;
  else
    select PARAMETER_VALUE_CODE into p_mds
    from xtr_company_parameters
    where COMPANY_CODE = rec.company_code and
        PARAMETER_CODE = C_MARKET_DATA_SET;
  end if;

end xtr_revl_get_mds;
--------------------------------------------------------------
/********************************************************************/
/* This procedure determine whether the deal is reval at first time. */
/* If it's the first time, return TRUE, else return FALSE            */
/* NOTE: this procedure is not working for CA and IG because the     */
/* first_batch_id is stored in xtr_bank_balances and xtr_intergroup  */
/* table. Since these two deals do not call procedure. So no worry   */
/* We may enhance later                                              */
/*********************************************************************/
PROCEDURE xtr_first_reval(
    rec   IN xtr_revl_rec,
    p_out OUT NOCOPY BOOLEAN) is

 cursor C_FIRST_DEAL is
 select 'Y'
 from XTR_DEALS
 where deal_no = rec.deal_no
 and deal_type not in ('CA', 'IG', 'ONC', 'NI')
 and first_reval_batch_id is NOT NULL
 and first_reval_batch_id <> rec.batch_id;

 cursor C_FIRST_ROLL is
 select 'Y'
 from XTR_ROLLOVER_TRANSACTIONS
 where deal_number = rec.deal_no
 and transaction_number = rec.trans_no
 and deal_type in ('NI', 'ONC')
 and first_reval_batch_id is NOT NULL
 and first_reval_batch_id <> rec.batch_id;

 cursor C_FIRST_HEDGE is
 select 'Y'
 from XTR_HEDGE_ATTRIBUTES
 where hedge_attribute_id = rec.deal_no
 and first_batch_id is NOT NULL;

 l_dummy VARCHAR2(1);
Begin
 If rec.deal_type not in ('CA', 'IG', 'ONC', 'NI', 'HEDGE') then
    Open C_FIRST_DEAL;
    Fetch C_FIRST_DEAL into l_dummy;
    If C_FIRST_DEAL%FOUND then -- have record in reval table. Not the first time
       p_out := FALSE;
    else
       p_out := TRUE;
    end If;
    Close c_FIRST_DEAL;
 Elsif rec.deal_type in ('NI', 'ONC') then
        Open C_FIRST_ROLL;
    Fetch C_FIRST_ROLL into l_dummy;
    If C_FIRST_ROLL%FOUND then -- have record in reval table. Not the first time
       p_out := FALSE;
    else
       p_out := TRUE;
    end If;
    Close c_FIRST_ROLL;
 Elsif rec.deal_type = 'HEDGE' then
    Open C_FIRST_HEDGE;
    Fetch C_FIRST_HEDGE into l_dummy;
    If C_FIRST_HEDGE%FOUND then
       p_out := FALSE;
    else
       p_out := TRUE;
    end If;
    Close c_FIRST_HEDGE;
 End if;

End;
---------------------------------------------------------------
PROCEDURE UPDATE_FX_REVALS (l_deal_no        IN NUMBER,
                            l_transaction_no IN NUMBER,
                            l_deal_type      IN VARCHAR2) is

Begin
   Delete from xtr_revaluation_details
   where  deal_no = l_deal_no
   and    transaction_no = l_transaction_no
   and    deal_type = l_deal_type;

Exception
    When NO_DATA_FOUND then
         Null;
    When OTHERS then
         RAISE;
End UPDATE_FX_REVALS;
-------------------------------------------------------------
PROCEDURE LOG_MSG(P_TEXT IN VARCHAR2 DEFAULT NULL, P_VALUE IN VARCHAR2 DEFAULT
NULL) IS

l_flag VARCHAR2(1) ;

BEGIN

   if l_flag = 'D' then
      /*dbms_output.put_line(p_text||' : '||p_value);*/
	null;
   elsif l_flag = 'C' then
      fnd_file.put_line(1,p_text||' : '||p_value);
   else
      xtr_risk_debug_pkg.dlog(p_text, p_value);
   end if;

END LOG_MSG;
-------------------------------
end XTR_REVAL_PROCESS_P;

/
