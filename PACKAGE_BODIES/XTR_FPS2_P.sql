--------------------------------------------------------
--  DDL for Package Body XTR_FPS2_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_FPS2_P" as
/* $Header: xtrfps2b.pls 120.19 2006/06/23 06:46:16 kbabu ship $ */
-------------------------------------------------------------------------------------------
-- Procedure to Calculate Currency Cross Rates
PROCEDURE CALC_CROSS_RATE(quoted_1st IN varchar2,
                          start_date IN date) is
/*
 This procedure calculates currency cross rates using
 spot rates and loads them into the appropriate table
 It uses the following input parameters :
--
 quoted_1st   - currency quoted first,
 start_date   - start date for calculation,
*/
--
 l_round                 NUMBER;
 ccya                     VARCHAR2(15);
 ccyb                     VARCHAR2(15);
 ccy1                     VARCHAR2(15);
 ccy2                     VARCHAR2(15);
 l_bid_rate               NUMBER;
 l_offer_rate             NUMBER;
 l_last_archive_time DATE;
 l_archive_freq_type VARCHAR2(1);
 l_freq_archive         NUMBER;
--
 cursor PREV_ARCHIVE is
   select  last_archive_time,archive_freq_type,freq_archive
   from XTR_MARKET_PRICES
    where (currency_a = quoted_1st or currency_b = quoted_1st)
    and (currency_a = 'USD' or currency_b = 'USD')
    and term_type = 'S';
 --
 cursor SPOT_CUR is
   select sr1.currency                  tmp_currency_first,
          decode(sr2.currency_a,'USD',sr2.currency_b,sr2.currency_a)
                                                    tmp_currency_second,
          decode(sr2.currency_a,'USD',sr2.bid_price ,(1/sr2.ask_price)) /
                decode(sr3.currency_a, 'USD', sr3.ask_price, (1/sr3.bid_price))
                                                    tmp_bid_rate,
          decode(sr2.currency_a,'USD',sr2.ask_price, (1/sr2.bid_price)) /
                decode(sr3.currency_a, 'USD', sr3.bid_price, (1/sr3.ask_price))
                                                    tmp_offer_rate,
          nvl(sr1.rate_date,sr1.spot_date) tmp_rate_date
   from XTR_MASTER_CURRENCIES sr1,
          XTR_MARKET_PRICES sr2,
	 XTR_MARKET_PRICES sr3
   where  sr1.currency = quoted_1st
   and   (sr2.currency_a = 'USD' or sr2.currency_b = 'USD')
   and   (sr3.currency_a = 'USD' or sr3.currency_b = 'USD')
   and    sr2.currency_a <> quoted_1st
   and    sr2.currency_b <> quoted_1st
   and   (sr3.currency_a = quoted_1st or  sr3.currency_b= quoted_1st)
   and    sr2.term_type = 'S'
   and    sr3.term_type = 'S';
--
 spot spot_cur%rowtype;
--
cursor F1F2 is
 select CURRENCY_FIRST,CURRENCY_SECOND
  from XTR_BUY_SELL_COMBINATIONS
  where ((CURRENCY_BUY = ccy1 and
             CURRENCY_SELL = ccy2) or
            (CURRENCY_BUY = ccy2 and
             CURRENCY_SELL = ccy1));
--
begin
  open PREV_ARCHIVE;
    fetch PREV_ARCHIVE INTO l_last_archive_time,
                                              l_archive_freq_type,
                                              l_freq_archive;
  close PREV_ARCHIVE;
  --
  if ((l_LAST_ARCHIVE_TIME  is NULL) or
         (l_ARCHIVE_FREQ_TYPE = 'A') or
         (l_LAST_ARCHIVE_TIME  is NOT NULL and
         ((l_ARCHIVE_FREQ_TYPE = 'S')
           and (SYSDATE >= (l_LAST_ARCHIVE_TIME
                   + l_FREQ_ARCHIVE / 60 / 60 / 24))) or
         ((l_ARCHIVE_FREQ_TYPE = 'M')
           and (SYSDATE >= (l_LAST_ARCHIVE_TIME
                   + l_FREQ_ARCHIVE / 60 / 24))) or
         ((l_ARCHIVE_FREQ_TYPE = 'H')
           and (SYSDATE >= (l_LAST_ARCHIVE_TIME
                   + l_FREQ_ARCHIVE / 24))) or
         ((l_ARCHIVE_FREQ_TYPE = 'D')
           and (SYSDATE >= (l_LAST_ARCHIVE_TIME
                   + l_FREQ_ARCHIVE))) or
         ((l_ARCHIVE_FREQ_TYPE = 'W')
           and (SYSDATE >= (l_LAST_ARCHIVE_TIME
                   + l_FREQ_ARCHIVE * 7))) or
         ((l_ARCHIVE_FREQ_TYPE = 'T')
           and (l_LAST_ARCHIVE_TIME <
                                                 to_date(to_char(SYSDATE,'DD/MON/YYYY')||':'||
                                                 lpad(to_char(l_FREQ_ARCHIVE),'0',2),
                                                 'DD/MON/YYYY:HH24'))
           and (SYSDATE >= to_date(to_char(SYSDATE,'DD/MON/YYYY')||':'||
                                                 lpad(to_char(l_FREQ_ARCHIVE),'0',2),
                                                 'DD/MON/YYYY:HH24'))))) then
     -- :NEW.LAST_ARCHIVE_TIME := SYSDATE;
     FOR spot IN spot_cur LOOP
      ccy1 := spot.tmp_currency_first;
      ccy2 := spot.tmp_currency_second;
      open F1F2;
       fetch F1F2 INTO ccya,ccyb;
      if F1F2%NOTFOUND then
       -- We Don't require this cross rate to be saved
       close F1F2;
       goto NEXTREC;
      end if;
      close F1F2;
      if ccya <> ccy1 then
       l_bid_rate   := 1 / spot.tmp_offer_rate;
       l_offer_rate := 1 / spot.tmp_bid_rate;
      else
       l_bid_rate   := spot.tmp_bid_rate;
       l_offer_rate := spot.tmp_offer_rate;
      end if;

      begin
        insert into XTR_CURRENCY_CROSS_RATES
         (rate_date,currency_first,currency_second,bid_rate,offer_rate)
        values
         (nvl(spot.tmp_rate_date,SYSDATE),ccya,ccyb,
          l_bid_rate,l_offer_rate);
      exception
      when OTHERS then
        NULL;
      end;
      <<NEXTREC>>
      NULL;
   END LOOP;
 end if;
end CALC_CROSS_RATE;
----------------------------------------------------------------------------------------------------------------
--  Procedure to calculate revaluations
PROCEDURE CALC_REVALS ( p_start_date     IN date,
                        p_end_date       IN date,
                        p_sysdate        IN date,
                        p_user           IN varchar2,
                        p_company_code   IN varchar2,
                        p_deal_type      IN varchar2,
                        p_deal_subtype   IN varchar2,
                        p_product_type   IN varchar2,
                        p_portfolio_code IN varchar2) is
--
begin
-- This is now in its own package ---> REVAL_PROCESS
NULL;
end CALC_REVALS;
----------------------------------------------------------------------------------------------------------------
--   Procedure to calculate the price of a FRA
PROCEDURE CALCULATE_FRA_PRICE (t            IN NUMBER,
                               T1           IN NUMBER,
                               Rt           IN NUMBER,
                               Rt1          IN NUMBER,
                               l_year_basis IN NUMBER,
                               fra_rate     IN OUT NOCOPY NUMBER) is
 --
 -- t    NUMBER (Days from today to start date)
 -- T1   NUMBER (Days from today to maturity date)
 -- Rt   NUMBER (Interest Rate for maturity t days)
 -- RT1  NUMBER (Interest Rate for maturity T1 days)
 --
 l_invest_at NUMBER;
 l_borrow_at NUMBER;
--
begin
 if t is NOT NULL and T1 is NOT NULL and Rt is NOT NULL and Rt1 is NOT NULL and
  l_year_basis is NOT NULL then
  -- Calc for Invest Rate
  l_invest_at := (((1 + RT1 * T1 / (l_year_basis * 100))) /
                  (1 + Rt * t / (l_year_basis * 100)) - 1) *
                  (l_year_basis * 100 / (T1 - t));
  -- Calc for Borrow Rate
  l_borrow_at := (((1 + RT1 * T1 / (l_year_basis * 100))) /
                  (1 + Rt * t / (l_year_basis * 100)) - 1) *
                  (l_year_basis * 100 / (T1 - t));

  fra_rate := (l_invest_at + l_borrow_at) / 2;
 end if;
end CALCULATE_FRA_PRICE;
----------------------------------------------------------------------------------------------------------------
PROCEDURE DEAL_EXISTS (l_date    IN DATE,
                              l_company IN VARCHAR2,
                              l_d_type  IN VARCHAR2,
                              l_d_subty IN VARCHAR2,
                              l_dealer  IN VARCHAR2,
                              l_exists  IN OUT NOCOPY VARCHAR2) as
 cursor DEAL_EXISTS_YN is
  select 'Y'
  from XTR_DEAL_DATE_AMOUNTS_V
  where AMOUNT_DATE = l_date
  and COMPANY_CODE like nvl(l_company,'%')
  and DEAL_TYPE like nvl(l_d_type,'%')
  and DEAL_SUBTYPE like nvl(l_d_subty,'%')
  and DEALER_CODE like nvl(l_dealer,'%');
--
begin
 open DEAL_EXISTS_YN;
 fetch DEAL_EXISTS_YN INTO l_exists;
 close DEAL_EXISTS_YN;
 l_exists := nvl(l_exists,'N');
end DEAL_EXISTS;
----------------------------------------------------------------------------------------------------------------
--  Local Procedure to Default Company, Currency, Portfolio
PROCEDURE DEFAULTS (l_comp      IN OUT NOCOPY VARCHAR2,
                    l_comp_name IN OUT NOCOPY VARCHAR2,
                    l_ccy       IN OUT NOCOPY VARCHAR2,
                    l_ccy_name  IN OUT NOCOPY VARCHAR2,
                    l_port      IN OUT NOCOPY VARCHAR2) is
--
/* Modified below cursors Bug 4647357
 cursor COMP_DFLT is
  select a.PARTY_CODE, a.SHORT_NAME, d.CURRENCY_CODE, b.NAME
    from XTR_PARTIES_V a,
         XTR_MASTER_CURRENCIES b,
         HR_LEGAL_ENTITIES c,
         GL_SETS_OF_BOOKS d
   where a.PARTY_TYPE      = 'C'
   and   a.DEFAULT_COMPANY = 'Y'
   and   c.ORGANIZATION_ID = a.LEGAL_ENTITY_ID
   and   c.SET_OF_BOOKS_ID = d.SET_OF_BOOKS_ID
   and   b.CURRENCY        = d.CURRENCY_CODE;
--
 cursor COMP_CCY is
  select d.CURRENCY_CODE, b.NAME
    from XTR_PARTIES_V a,
         XTR_MASTER_CURRENCIES b,
         HR_LEGAL_ENTITIES c,
         GL_SETS_OF_BOOKS d
   where a.PARTY_TYPE      = 'C'
   and   a.PARTY_CODE      = l_comp
   and   c.ORGANIZATION_ID = a.LEGAL_ENTITY_ID
   and   c.SET_OF_BOOKS_ID = d.SET_OF_BOOKS_ID
   and   b.CURRENCY        = d.CURRENCY_CODE;
*/
cursor COMP_DFLT is
  select a.PARTY_CODE, a.SHORT_NAME, d.CURRENCY_CODE, b.NAME
    from XTR_PARTIES_V a,
         XTR_MASTER_CURRENCIES b,
         GL_LEDGER_LE_V c,
         GL_SETS_OF_BOOKS d
   where a.PARTY_TYPE      = 'C'
   and   a.DEFAULT_COMPANY = 'Y'
   and   c.LEGAL_ENTITY_ID = a.LEGAL_ENTITY_ID
   and   c.LEDGER_ID = d.SET_OF_BOOKS_ID
   and   c.LEDGER_CATEGORY_CODE = 'PRIMARY'
   and   b.CURRENCY        = d.CURRENCY_CODE;
--
 cursor COMP_CCY is
   select d.CURRENCY_CODE, b.NAME
    from XTR_PARTIES_V a,
         XTR_MASTER_CURRENCIES b,
         GL_LEDGER_LE_V c,
         GL_SETS_OF_BOOKS d
   where a.PARTY_TYPE      = 'C'
   and   a.PARTY_CODE      = l_comp
   and   c.LEGAL_ENTITY_ID = a.LEGAL_ENTITY_ID
   and   c.LEDGER_ID = d.SET_OF_BOOKS_ID
   and   c.LEDGER_CATEGORY_CODE = 'PRIMARY'
   and   b.CURRENCY        = d.CURRENCY_CODE;
--
 cursor PORT is
  select PORTFOLIO
   from XTR_PORTFOLIOS
   where COMPANY_CODE = l_comp
   and DEFAULT_PORTFOLIO = 'Y';
--
begin
  if l_comp is NULL then
     open  COMP_DFLT;
     fetch COMP_DFLT INTO l_comp,l_comp_name,l_ccy,l_ccy_name;
     close COMP_DFLT;
  else
     open  COMP_CCY;
     fetch COMP_CCY INTO l_ccy,l_ccy_name;
     close COMP_CCY;
  end if;
  if l_comp is not null then
      open PORT;
      fetch PORT INTO l_port;
      close PORT;
  end if;
end DEFAULTS;
----------------------------------------------------------------------------------------------------------------
/* Bug 1708946
--   Procedure to default currency for the company entered
PROCEDURE DEFAULT_CCY (l_pty      IN VARCHAR2,
                       l_ccy      IN OUT NOCOPY VARCHAR2,
                       l_ccy_name IN OUT NOCOPY VARCHAR2) is
cursor DFLT is
 select a.HOME_CURRENCY,b.NAME
  from XTR_PARTIES_V a,
       XTR_MASTER_CURRENCIES b
  where a.PARTY_CODE = l_pty
  and   b.CURRENCY   = a.HOME_CURRENCY;
--
begin
 if l_pty is NOT NULL then
  open DFLT;
   fetch DFLT INTO l_ccy,l_ccy_name;
  close DFLT;
 end if;
end DEFAULT_CCY;
*/
----------------------------------------------------------------------------------------------------------------
--   Procedure to set default company account number.
PROCEDURE DEFAULT_COMP_ACCT (l_company  IN VARCHAR2,
                             l_currency IN VARCHAR2,
                             l_acct_nos IN OUT NOCOPY VARCHAR2) is
--
 cursor DEFAULT_ACCOUNT is
  select ACCOUNT_NUMBER
   from  XTR_BANK_ACCOUNTS
   where PARTY_CODE = l_company
   and   CURRENCY   = l_currency
   and   DEFAULT_ACCT = 'Y';
--
begin
 open DEFAULT_ACCOUNT;
  fetch DEFAULT_ACCOUNT INTO l_acct_nos;
 close DEFAULT_ACCOUNT;
end DEFAULT_COMP_ACCT;
----------------------------------------------------------------------------------------------------------------
--   Procedure to Default the Spot Date
PROCEDURE DEFAULT_SPOT_DATE (l_sysdate IN DATE,
                             l_ccy1    IN VARCHAR2,
                             l_ccy2    IN VARCHAR2,
                             out_date  IN OUT NOCOPY DATE) is
--
 --in_date VARCHAR2(10);
 v_new_date DATE;

 v_err_code NUMBER;
 v_err_level VARCHAR2(10);
--
/*
 cursor WK_DAY is
  select 1
   from  DUAL
   where to_char(to_date(in_date),'D') between 2 and 6;
--
 cursor HOL is
  select 1
   from XTR_HOLIDAYS
   where HOLIDAY_DATE = in_date
   and CURRENCY IN (l_ccy1,l_ccy2);
--
 v_dummy VARCHAR2(1);
*/
--
begin
 --in_date := to_char(l_sysdate + 2);
 v_new_date := l_sysdate+2;
 if v_new_date is NOT NULL then
  LOOP
   --check currency 1
   XTR_FPS3_P.CHK_HOLIDAY(v_new_date,l_ccy1,v_err_code,v_err_level);
   if (v_err_level is not null) then
     goto REDO;
   end if;
   --check currency 2
   XTR_FPS3_P.CHK_HOLIDAY(v_new_date,l_ccy2,v_err_code,v_err_level);
   if (v_err_level is not null) then
     goto REDO;
   end if;
   -- good to go
   EXIT;
   <<REDO>>
   -- Date is either a Holiday or Weekend then add 1 day and recheck
   --in_date := to_char(to_date(in_date) + 1);
   v_new_date := v_new_date + 1;
  END LOOP;
  out_date := v_new_date;
  --out_date := to_date(in_date);
 end if;
end DEFAULT_SPOT_DATE;
----------------------------------------------------------------------------------------------------------------
--  Procedure to Calulate Yields
PROCEDURE DISCOUNT_INTEREST_CALC(days_in_year IN NUMBER,
                                 amount       IN NUMBER,
                                 rate         IN NUMBER,
                                 no_of_days   IN NUMBER,
                                 round_factor IN NUMBER,
                                 interest     IN OUT NOCOPY NUMBER,
                                 rounding_type IN VARCHAR2) is
/*  This procedure calculates interest amounts.
   It uses the following input parameters :
       amount       - transaction amount,
       rate         - interest rate,
       days_in_year - year basis for this currency,
       no_of_days   - duration of deal,
       round_factor - the rounding factor to be applied for this ccy.
   It returns the following output parameters :
       interest     - amount of interest to be paid/received*/
--
begin
--Change Interest Override
 interest := interest_round(amount  - (amount /
         (1 + (rate / (days_in_year * 100) * no_of_days))),round_factor,nvl(rounding_type,'R'));
--Original-----------------------------------------------
-- interest := round(amount  - (amount /
--        (1 + (rate / (days_in_year * 100) * no_of_days))),round_factor);
--End of Change------------------------------------------
end DISCOUNT_INTEREST_CALC;


--  Procedure to Calulate Present Value (simple interest )
PROCEDURE PRESENT_VALUE_CALC(days_in_year IN NUMBER,
                                 amount       IN NUMBER,
                                 rate         IN NUMBER,
                                 no_of_days   IN NUMBER,
                                 round_factor IN NUMBER,
                                 present_value  IN OUT NOCOPY NUMBER) is
/*  This procedure calculates present values.
   It uses the following input parameters :
       amount       - transaction amount,
       rate         - interest rate,
       days_in_year - year basis for this currency,
       no_of_days   - duration of deal,
       round_factor - the rounding factor to be applied for this ccy.
   It returns the following output parameters :
       present_value  - present value to be paid/received*/
--
begin
 present_value := round(amount /
         (1 + (rate / (days_in_year * 100) * no_of_days)),round_factor);
end PRESENT_VALUE_CALC;

--
--  Procedure to Calulate Present Value (simple interest )
PROCEDURE PRESENT_VALUE_COMPOUND(days_in_year IN NUMBER,
                                 amount       IN NUMBER,
                                 rate         IN NUMBER,
                                 no_of_days   IN NUMBER,
                                 round_factor IN NUMBER,
                                 present_value  IN OUT NOCOPY NUMBER) is
--
begin
if 1+rate/100 >=0 then
 present_value := round(amount /
         POWER((1 + rate/100),no_of_days/days_in_year),round_factor);
end if;

end PRESENT_VALUE_COMPOUND;

--  Procedure to Extrapolate the rate from a specific yield curve
PROCEDURE EXTRAPOLATE_FROM_YIELD_CURVE(l_ccy         IN CHAR,
                           l_days        IN NUMBER,
                           l_yield_curve IN VARCHAR2,
                           l_rate  IN OUT NOCOPY NUMBER) is
--
 l_lower_rate  NUMBER;
 l_lower_days  NUMBER;
 l_higher_rate NUMBER;
 l_higher_days NUMBER;
 l_diff        NUMBER;
--
 cursor GET_LOWER_RATE is
  select (a.BID_PRICE + a.ASK_PRICE) / 2,a.NOS_OF_DAYS
   from XTR_YIELD_CURVE_DETAILS a
   where a.CURRENCY = l_ccy
   and a.GROUP_CODE = l_yield_curve
   and a.NOS_OF_DAYS =
    (select max(c.NOS_OF_DAYS)
      from XTR_YIELD_CURVE_DETAILS c
      where c.GROUP_CODE = l_yield_curve
      and c.CURRENCY = l_ccy
      and c.NOS_OF_DAYS < l_days);
--
 cursor GET_HIGHER_RATE is
  select (a.BID_PRICE + a.ASK_PRICE) / 2,a.NOS_OF_DAYS
   from XTR_YIELD_CURVE_DETAILS a
   where a.CURRENCY = l_ccy
   and a.GROUP_CODE = l_yield_curve
   and a.NOS_OF_DAYS =
    (select max(c.NOS_OF_DAYS)
      from XTR_YIELD_CURVE_DETAILS c
      where c.GROUP_CODE = l_yield_curve
      and c.CURRENCY = l_ccy
      and c.NOS_OF_DAYS >= l_days);
--
begin
 open GET_LOWER_RATE;
  fetch GET_LOWER_RATE INTO l_lower_rate,l_lower_days;
 close GET_LOWER_RATE;
 --
 open GET_HIGHER_RATE;
  fetch GET_HIGHER_RATE INTO l_higher_rate,l_higher_days;
 close GET_HIGHER_RATE;
 if l_lower_days is NULL and l_higher_days is NULL then
  l_rate := 0;
 elsif l_lower_days is NOT NULL and l_higher_days is NULL then
  l_rate := l_lower_rate;
 elsif l_lower_days is NULL and l_higher_days is NOT NULL then
  l_rate := l_higher_rate;
 elsif l_lower_days is NOT NULL and l_higher_days is NOT NULL then
  -- Extrapolate the rate
  l_diff := l_higher_days - l_lower_days;
  if l_diff = 0 then
   l_diff := 1;
  end if;
  l_rate :=
    (l_lower_rate * ((l_higher_days - l_days) / l_diff)) +
    (l_higher_rate * ((l_days - l_lower_days) / l_diff));
 else
  l_rate := 0;
 end if;
 l_rate := round(nvl(l_rate,0),5);
end EXTRAPOLATE_FROM_YIELD_CURVE;
----------------------------------------------------------------------------------------------------------------
--  Procedure to Extrapolate the rate from a specific yield curve
PROCEDURE EXTRAPOLATE_FROM_MARKET_PRICES(l_ccy         IN CHAR,
                           l_days        IN NUMBER,
                           l_rate  IN OUT NOCOPY NUMBER) is
--
 l_lower_rate  NUMBER;
 l_lower_days  NUMBER;
 l_higher_rate NUMBER;
 l_higher_days NUMBER;
 l_diff        NUMBER;
--
 cursor GET_LOWER_RATE is
  select (a.BID_PRICE + a.ASK_PRICE) / 2,a.NOS_OF_DAYS
   from XTR_MARKET_PRICES a
   where a.CURRENCY_A = l_ccy
   and a.TERM_TYPE IN('D','M','Y','A')
   and a.NOS_OF_DAYS =
    (select max(c.NOS_OF_DAYS)
      from XTR_MARKET_PRICES c
      where c.TERM_TYPE IN('D','M','Y','A')
      and c.CURRENCY_A = l_ccy
      and c.NOS_OF_DAYS < l_days);
--
 cursor GET_HIGHER_RATE is
  select (a.BID_PRICE + a.ASK_PRICE) / 2,a.NOS_OF_DAYS
   from XTR_MARKET_PRICES a
   where a.CURRENCY_A = l_ccy
   and a.TERM_TYPE IN('D','M','Y','A')
   and a.NOS_OF_DAYS =
    (select max(c.NOS_OF_DAYS)
      from XTR_MARKET_PRICES c
      where c.TERM_TYPE IN('D','M','Y','A')
      and c.CURRENCY_A = l_ccy
      and c.NOS_OF_DAYS >= l_days);
--
begin
 open GET_LOWER_RATE;
  fetch GET_LOWER_RATE INTO l_lower_rate,l_lower_days;
 close GET_LOWER_RATE;
 --
 open GET_HIGHER_RATE;
  fetch GET_HIGHER_RATE INTO l_higher_rate,l_higher_days;
 close GET_HIGHER_RATE;
 if l_lower_days is NULL and l_higher_days is NULL then
  l_rate := 0;
 elsif l_lower_days is NOT NULL and l_higher_days is NULL then
  l_rate := l_lower_rate;
 elsif l_lower_days is NULL and l_higher_days is NOT NULL then
  l_rate := l_higher_rate;
 elsif l_lower_days is NOT NULL and l_higher_days is NOT NULL then
  -- Extrapolate the rate
  l_diff := l_higher_days - l_lower_days;
  if l_diff = 0 then
   l_diff := 1;
  end if;
  l_rate :=
    (l_lower_rate * ((l_higher_days - l_days) / l_diff)) +
    (l_higher_rate * ((l_days - l_lower_days) / l_diff));
 else
  l_rate := 0;
 end if;
 l_rate := round(nvl(l_rate,0),5);
end EXTRAPOLATE_FROM_MARKET_PRICES;
----------------------------------------------------------------------------------------------------------------
--  Procedure to Extrapolate the rate from the reval rates WITHOUT referring to a
--  specific yield curve
PROCEDURE EXTRAPOLATE_RATE(l_company     IN VARCHAR2,
                           l_period_from IN DATE,
                           l_period_to   IN DATE,
                           l_ccy         IN VARCHAR2,
                           l_days        IN NUMBER,
                           l_reval_rate  IN OUT NOCOPY NUMBER) is
begin
null;
end EXTRAPOLATE_RATE;
----------------------------------------------------------------------------------------------------------------
/*
--- This new procedure has to move to another new parkage PRORATE_DB_PKG, because it causes GPF.
--- old libary,new parkage,new forms  GPF
--- old libary,new parkage,old forms  OK
--- new libary,new parkge,new forms   OK

--  Procedure to Extrapolate the FWDS from the reval rates WITHOUT referring to a
--  specific yield curve
PROCEDURE EXTRAPOLATE_FWDS(l_company     IN VARCHAR2,
                           l_period_from IN DATE,
                           l_period_to   IN DATE,
                           l_ccy         IN VARCHAR2,
                           l_ccyb	     IN VARCHAR2,
                           l_days        IN NUMBER,
                           l_fwds        IN OUT NOCOPY NUMBER) is
--
 l_lower_rate  NUMBER;
 l_lower_days  NUMBER;
 l_higher_rate NUMBER;
 l_higher_days NUMBER;
 l_diff        NUMBER;
--
 l_round_ccy varchar2(15);
 l_round number;
 cursor get_round is
  select rounding_factor
   from master_currencies
   where currency=l_round_ccy;
 cursor GET_LOWER_RATE is
  select a.REVAL_RATE,a.NUMBER_OF_DAYS
   from XTR_REVALUATION_RATES a
   where a.COMPANY_CODE = l_company
   and a.PERIOD_TO = l_period_to
   and a.CURRENCYA = l_ccy
   and a.CURRENCYB = l_ccyb
   and a.VOLATILITY_OR_RATE = 'FWDS'
   and a.NUMBER_OF_DAYS =
    (select max(b.NUMBER_OF_DAYS)
      from XTR_REVALUATION_RATES b
      where b.COMPANY_CODE = l_company
      and b.PERIOD_TO = l_period_to
      and b.CURRENCYA = l_ccy
      and b.CURRENCYB = l_ccyb
      and b.VOLATILITY_OR_RATE = 'FWDS'
      and b.NUMBER_OF_DAYS < l_days);
--
 cursor GET_HIGHER_RATE is
  select a.REVAL_RATE,a.NUMBER_OF_DAYS
   from XTR_REVALUATION_RATES a
   where a.COMPANY_CODE = l_company
   and a.PERIOD_TO = l_period_to
   and a.CURRENCYA = l_ccy
   and a.CURRENCYB = l_ccyb
   and a.VOLATILITY_OR_RATE = 'FWDS'
   and a.NUMBER_OF_DAYS =
    (select min(b.NUMBER_OF_DAYS)
      from XTR_REVALUATION_RATES b
      where b.COMPANY_CODE = l_company
      and b.PERIOD_TO = l_period_to
      and b.CURRENCYA = l_ccy
      and b.CURRENCYB = l_ccyb
      and b.VOLATILITY_OR_RATE = 'FWDS'
      and b.NUMBER_OF_DAYS >= l_days);
--
begin
 open GET_LOWER_RATE;
  fetch GET_LOWER_RATE INTO l_lower_rate,l_lower_days;
 close GET_LOWER_RATE;
 --
 open GET_HIGHER_RATE;
  fetch GET_HIGHER_RATE INTO l_higher_rate,l_higher_days;
 close GET_HIGHER_RATE;
 if l_lower_days is NULL and l_higher_days is NULL then
  l_fwds   := 0;
 else
  -- Extrapolate the rate
  l_diff := nvl(l_higher_days,0) - nvl(l_lower_days,0);
  if l_diff = 0 then
   l_diff := 1;
  end if;
  l_fwds   :=
    (nvl(l_lower_rate,0) * ((nvl(l_higher_days,0) - nvl(l_days,0)) / l_diff)) +
    (nvl(l_higher_rate,0) * ((nvl(l_days,0) - nvl(l_lower_days,0)) / l_diff));
 end if;
  if l_ccy='USD' then
    l_round_ccy :=l_ccyb;
  elsif l_ccyb='USD' then
    l_round_ccy :=l_ccy;
  else
    l_round_ccy :=l_ccyb;
  end if;
   open get_round;
   fetch get_round into l_round;
   close get_round;
   l_fwds   := round(nvl(l_fwds/power(10,nvl(l_round,0)+2),0),5);
end EXTRAPOLATE_FWDS;
*/
----------------------------------------------------------------------------------------------------------------
/*  This procedure calculates interest amounts.
   It uses the following input parameters :
       amount       - transaction amount,
       rate         - interest rate,
       days_in_year - year basis for this currency,
       no_of_days   - duration of deal,
       round_factor - the rounding factor to be applied for this ccy.
   It returns the following output parameters :
       interest     - amount of interest to be paid/received
*/
PROCEDURE INTEREST_CALCULATOR (days_in_year IN NUMBER,
                               amount       IN NUMBER,
                               rate         IN NUMBER,
                               no_of_days   IN NUMBER,
                               round_factor IN NUMBER,
                               interest     IN OUT NOCOPY NUMBER,
			       round_type   IN VARCHAR2
			       ) is
--
begin

   --
   -- Added the rounding_type for the interest override feature
   --
--   interest := round((amount * rate / (days_in_year * 100) *
--                    no_of_days),round_factor);

   interest := interest_round((amount * rate / (days_in_year * 100) *
                      no_of_days),round_factor,round_type);

end INTEREST_CALCULATOR ;
----------------------------------------------------------------------------------------------------------------
--   Procedure to set defaults for Deal block.
PROCEDURE SET_DEFAULTS (l_company_code IN OUT NOCOPY VARCHAR2,
                        l_company_name IN OUT NOCOPY VARCHAR2) is
--
 cursor PTY_CODE is
  select PARTY_CODE, SHORT_NAME
   from  XTR_PARTIES_V
   where PARTY_TYPE = 'C'
   and   DEFAULT_COMPANY = 'Y';
--
begin
 open PTY_CODE;
  fetch PTY_CODE INTO l_company_code,l_company_name;
 close PTY_CODE;
end SET_DEFAULTS;
----------------------------------------------------------------------------------------------------------------
--   Procedure to set defaults for Portfolio block.
PROCEDURE SET_DEFAULTS_PDA (l_company_code   IN VARCHAR2,
                            l_portfolio_code IN OUT NOCOPY VARCHAR2,
                            l_portfolio_name IN OUT NOCOPY VARCHAR2) is
--
-- NOTE this brings back the portfolio name whereas the procedure below
-- brings back only the code
 cursor PORT_DFLT is
  select PORTFOLIO, NULL NAME
   from  xtr_portfolios pf
   where COMPANY_CODE = l_company_code
   and   DEFAULT_PORTFOLIO = 'Y';
--
begin
if l_portfolio_code is NULL then
 open PORT_DFLT;
  fetch PORT_DFLT INTO l_portfolio_code, l_portfolio_name;
 close PORT_DFLT;
end if;
end SET_DEFAULTS_PDA;
----------------------------------------------------------------------------------------------------------------
--   Procedure to set default company portfolio code.
PROCEDURE DEFAULT_PORTFOLIO (l_company_code IN VARCHAR2,
                             l_portfolio_code IN OUT NOCOPY VARCHAR2) is
--
 cursor PORT is
  select PORTFOLIO
   from XTR_PORTFOLIOS
   where COMPANY_CODE = l_company_code
   and DEFAULT_PORTFOLIO = 'Y';
--
begin
 open PORT;
  fetch PORT INTO l_portfolio_code;
 close PORT;
end DEFAULT_PORTFOLIO;
----------------------------------------------------------------------------------------------------------------
--   Procedure to Default Cparty Account Details
PROCEDURE STANDING_SETTLEMENTS (l_party       IN VARCHAR2,
                                l_ccy         IN VARCHAR2,
                                l_deal_type   IN VARCHAR2,
                                l_subtype     IN VARCHAR2,
                                l_product     IN VARCHAR2,
                                l_amount_type IN VARCHAR2,
                                l_cparty_ref  IN OUT NOCOPY VARCHAR2,
                                l_account     IN OUT NOCOPY VARCHAR2) is
--
 cursor DFLT_ACCT is
  select b.BANK_SHORT_CODE,a.ACCOUNT_NO
   from XTR_STANDING_INSTRUCTIONS a,
        XTR_BANK_ACCOUNTS b
   where a.PARTY_CODE = l_party
   and a.CURRENCY = l_ccy
   and (a.DEAL_TYPE = l_deal_type
        or a.DEAL_TYPE is NULL)
   and (a.DEAL_SUBTYPE = l_subtype
        or a.DEAL_SUBTYPE is NULL)
   and (a.PRODUCT_TYPE = l_product
        or a.PRODUCT_TYPE is NULL)
   and (a.AMOUNT_TYPE = l_amount_type
        or a.AMOUNT_TYPE is NULL)
   and  a.PARTY_CODE = b.PARTY_CODE
   and  a.CURRENCY   = b.CURRENCY
   and  a.ACCOUNT_NO = b.ACCOUNT_NUMBER
   and  nvl(b.AUTHORISED,'N') = 'Y'
   order by a.DEAL_TYPE,a.DEAL_SUBTYPE,a.PRODUCT_TYPE,a.AMOUNT_TYPE;
--
 l_dummy   NUMBER;
--
 cursor NO_DFLT_ACCT is
  select a.BANK_SHORT_CODE,a.ACCOUNT_NUMBER
   from XTR_BANK_ACCOUNTS a
   where a.PARTY_CODE = l_party
   and a.CURRENCY = l_ccy
   and nvl(a.AUTHORISED,'N') = 'Y'
   --* bug #1723491, rravunny
   --* default account column should also be checked
   and Nvl(a.Default_Acct,'N') = 'Y'
   --* end of fix
   order by nvl(a.DEFAULT_ACCT,'N') desc;
--
begin
 if l_party is NOT NULL and l_ccy is NOT NULL then
    open DFLT_ACCT;
    fetch DFLT_ACCT INTO l_cparty_ref,l_account;
    if DFLT_ACCT%NOTFOUND then
       close DFLT_ACCT;
       open NO_DFLT_ACCT;
       fetch NO_DFLT_ACCT INTO l_cparty_ref,l_account;
       IF NO_DFLT_ACCT%NOTFOUND then
           l_cparty_ref := NULL;
           l_account := NULL;
       END IF;
       close NO_DFLT_ACCT;
    end if;
    IF DFLT_ACCT%ISOPEN then
       close DFLT_ACCT;
    END IF;
 end if;
end STANDING_SETTLEMENTS;

---------------------------------
--  Local Procedure to default client setup information
PROCEDURE TAX_BROKERAGE_DEFAULTS(l_deal_type       IN VARCHAR2,
                                 l_subtype         IN VARCHAR2,
                                 l_product         IN VARCHAR2,
                                 l_ref_party       IN VARCHAR2,
                                 l_prin_settled_by IN OUT NOCOPY VARCHAR2,
                                 l_bkr_ref         IN OUT NOCOPY VARCHAR2,
                                 l_tax_ref         IN OUT NOCOPY VARCHAR2,
                                 l_int_settled_by  IN OUT NOCOPY VARCHAR2,
                                 l_int_freq        IN OUT NOCOPY VARCHAR2,
                                 l_bkr_amt_type    IN OUT NOCOPY VARCHAR2,
                                 l_tax_amt_type    IN OUT NOCOPY VARCHAR2) is
--
--                               l_deal_date       IN DATE,
--                               l_ref_amount      IN NUMBER,
--                               l_bkr_rate        IN OUT NOCOPY NUMBER,
--                               l_bkr_amount      IN OUT NOCOPY NUMBER,
--                               l_tax_rate        IN OUT NOCOPY NUMBER,
--
 l_dmmy_num  NUMBER;
 l_dmmy_char VARCHAR2(20);
--
 cursor SETTLE_DFLTS is
  select pd.PRINCIPAL_SETTLED_BY,
         pd.INTEREST_SETTLED_BY,
         pd.FREQ_INTEREST_SETTLED
   from XTR_PARTY_DEFAULTS pd,
        XTR_PARTIES_V p
   where p.PARTY_CODE     = l_ref_party
   and   pd.SETTLEMENT_DEFAULT_CATEGORY = p.SETTLEMENT_DEFAULT_CATEGORY
   and   pd.DEFAULT_TYPE  = 'S'
   and   pd.DEAL_TYPE     = l_deal_type
   and  (pd.DEAL_SUBTYPE  = l_subtype or pd.DEAL_SUBTYPE is NULL)
   and  (pd.PRODUCT_TYPE  = l_product or pd.PRODUCT_TYPE is NULL)
   and  (pd.PARTY_CODE    = l_ref_party or pd.PARTY_CODE is NULL)
   order by pd.DEAL_TYPE,pd.DEAL_SUBTYPE,pd.PRODUCT_TYPE;
--
 cursor BROKER_DFLTS is
--select b.BROKERAGE_REFERENCE,nvl(d.INTEREST_RATE,0),d.FLAT_AMOUNT
  select b.BROKERAGE_REFERENCE, d.AMOUNT_TYPE
   from XTR_PARTY_DEFAULTS b,
        XTR_PARTIES_V p,
        XTR_TAX_BROKERAGE_SETUP a,
        XTR_DEDUCTION_CALCS_V d
   where p.PARTY_CODE         = l_ref_party
   and   b.BROKERAGE_CATEGORY = p.BROKERAGE_CATEGORY
   and   b.DEFAULT_TYPE       = 'B'
   and   b.DEAL_TYPE          = l_deal_type
   and  (b.DEAL_SUBTYPE       = l_subtype or b.DEAL_SUBTYPE is NULL)
   and  (b.PRODUCT_TYPE       = l_product or b.PRODUCT_TYPE is NULL)
   and  (b.PARTY_CODE         = l_ref_party or b.PARTY_CODE is NULL)
   and   nvl(a.AUTHORISED,'N')= 'Y'
   and   a.REFERENCE_CODE     = b.BROKERAGE_REFERENCE
   and   a.DEAL_TYPE          = l_deal_type
   and   d.DEAL_TYPE          = a.DEAL_TYPE
   and   d.CALC_TYPE          = a.CALC_TYPE
   order by b.PARTY_CODE;
--
 cursor TAX_DFLTS is
--select b.TAX_REFERENCE, d.INTEREST_RATE
  select b.TAX_REFERENCE, d.AMOUNT_TYPE
   from XTR_PARTY_DEFAULTS b,
        XTR_PARTIES_V p,
        XTR_TAX_BROKERAGE_SETUP a,
        XTR_DEDUCTION_CALCS_V d
   where p.PARTY_CODE     = l_ref_party
   and   b.TAX_CATEGORY   = p.TAX_CATEGORY
   and   b.DEFAULT_TYPE   = 'T'
   and   b.DEAL_TYPE      = l_deal_type
   and  (b.DEAL_SUBTYPE   = l_subtype or b.DEAL_SUBTYPE is NULL)
   and  (b.PRODUCT_TYPE   = l_product or b.PRODUCT_TYPE is NULL)
   and  (b.PARTY_CODE     = l_ref_party or b.PARTY_CODE is NULL)
   and   nvl(a.AUTHORISED,'N')= 'Y'
   and   a.REFERENCE_CODE = b.TAX_REFERENCE
   and   a.DEAL_TYPE      = l_deal_type
   and   d.DEAL_TYPE      = a.DEAL_TYPE
   and   d.CALC_TYPE      = a.CALC_TYPE
   order by b.PARTY_CODE;
--
begin
 open SETTLE_DFLTS;
  fetch SETTLE_DFLTS INTO l_prin_settled_by,l_int_settled_by,l_int_freq;
 if SETTLE_DFLTS%NOTFOUND then
  l_prin_settled_by := 'D';
  l_int_settled_by  := 'D';
  l_int_freq        := 'M';
 end if;
 close SETTLE_DFLTS;
--
 open BROKER_DFLTS;
--fetch BROKER_DFLTS INTO l_bkr_ref,l_bkr_rate,l_bkr_amount;
  fetch BROKER_DFLTS INTO l_bkr_ref,l_bkr_amt_type;
 close BROKER_DFLTS;
--
 open TAX_DFLTS;
--fetch TAX_DFLTS INTO l_tax_ref,l_tax_rate;
  fetch TAX_DFLTS INTO l_tax_ref,l_tax_amt_type;
 close TAX_DFLTS;
end TAX_BROKERAGE_DEFAULTS;
--
----------------------------------------------------------------------------------------------------------------
--  Local Procedure to default client setup information
/*****************************************************************************/
-- This procedure overrides the above procedure, tax_brokerage_defaults,
-- for defaulting tax/brokerage values.  As tax features are added to
-- deals, this procedure should replace tax_brokerage_defaults.
-- Parameters:
--   l_deal_type = deal type
--   l_subtype = deal subtype
--   l_product = product type
--   l_ref_party = client code or counterparty code
--   l_prin_settled_by = principal settled by
--   l_bkr_ref = defaulted brokerage reference code
--   l_prin_tax_ref = defaulted principal tax schedule code
--   l_income_tax_ref = defaulted income tax schedule code
--   l_ccy = for FX, input as buy currency, output as tax currency;
--			else deal currency
--   l_sell_ccy = for FX, sell currency; else null
--   l_int_settled_by = interest settled by
--   l_int_freq = interest frequency
--   l_bkr_amt_type = brokerage amount type; null if l_bkr_ref is null

PROCEDURE TAX_BROKERAGE_DEFAULTING(l_deal_type       IN VARCHAR2,
                                 l_subtype         IN VARCHAR2,
                                 l_product         IN VARCHAR2,
                                 l_ref_party       IN VARCHAR2,
                                 l_prin_settled_by IN OUT NOCOPY VARCHAR2,
                                 l_bkr_ref         IN OUT NOCOPY VARCHAR2,
                                 l_prin_tax_ref    IN OUT NOCOPY VARCHAR2,
				 l_income_tax_ref  IN OUT NOCOPY VARCHAR2,
				 -- for FX deals, inputted as buy ccy
				 -- outputted as tax ccy
				 l_ccy	   	   IN OUT NOCOPY VARCHAR2,
				 l_sell_ccy	   IN     VARCHAR2,
                                 l_int_settled_by  IN OUT NOCOPY VARCHAR2,
                                 l_int_freq        IN OUT NOCOPY VARCHAR2,
                                 l_bkr_amt_type    IN OUT NOCOPY VARCHAR2) is
--
--                               l_deal_date       IN DATE,
--                               l_ref_amount      IN NUMBER,
--                               l_bkr_rate        IN OUT NOCOPY NUMBER,
--                               l_bkr_amount      IN OUT NOCOPY NUMBER,
--                               l_tax_rate        IN OUT NOCOPY NUMBER,
--
 l_dmmy_num  NUMBER;
 l_dmmy_char VARCHAR2(20);

 l_calc_type VARCHAR2(9);

--
 cursor SETTLE_DFLTS is
  select pd.PRINCIPAL_SETTLED_BY,
         pd.INTEREST_SETTLED_BY,
         pd.FREQ_INTEREST_SETTLED
   from XTR_PARTY_DEFAULTS pd,
        XTR_PARTIES_V p
   where p.PARTY_CODE     = l_ref_party
   and   pd.SETTLEMENT_DEFAULT_CATEGORY = p.SETTLEMENT_DEFAULT_CATEGORY
   and   pd.DEFAULT_TYPE  = 'S'
   and   pd.DEAL_TYPE     = l_deal_type
   and  (pd.DEAL_SUBTYPE  = l_subtype or pd.DEAL_SUBTYPE is NULL)
   and  (pd.PRODUCT_TYPE  = l_product or pd.PRODUCT_TYPE is NULL)
   and  (pd.PARTY_CODE    = l_ref_party or pd.PARTY_CODE is NULL)
   order by pd.DEAL_TYPE,pd.DEAL_SUBTYPE,pd.PRODUCT_TYPE;
--
 cursor BROKER_DFLTS is
--select b.BROKERAGE_REFERENCE,nvl(d.INTEREST_RATE,0),d.FLAT_AMOUNT
  select b.BROKERAGE_REFERENCE, d.AMOUNT_TYPE
   from XTR_PARTY_DEFAULTS b,
        XTR_PARTIES_V p,
        XTR_TAX_BROKERAGE_SETUP a,
        XTR_DEDUCTION_CALCS_V d
   where p.PARTY_CODE         = l_ref_party
   and   b.BROKERAGE_CATEGORY = p.BROKERAGE_CATEGORY
   and   b.DEFAULT_TYPE       = 'B'
   and   b.DEAL_TYPE          = l_deal_type
   and  (b.DEAL_SUBTYPE       = l_subtype or b.DEAL_SUBTYPE is NULL)
   and  (b.PRODUCT_TYPE       = l_product or b.PRODUCT_TYPE is NULL)
   and  (b.PARTY_CODE         = l_ref_party or b.PARTY_CODE is NULL)
   and   nvl(a.AUTHORISED,'N')= 'Y'
   and   a.REFERENCE_CODE     = b.BROKERAGE_REFERENCE
   and   a.DEAL_TYPE          = l_deal_type
   and   d.DEAL_TYPE          = a.DEAL_TYPE
   and   d.CALC_TYPE          = a.CALC_TYPE
   order by b.PARTY_CODE;
--
 cursor TAX_DFLTS is
--select b.TAX_REFERENCE, d.INTEREST_RATE
  select b.TAX_REFERENCE, b.INCOME_TAX_REFERENCE, d.CALC_TYPE
   from XTR_PARTY_DEFAULTS b,
        XTR_PARTIES_V p,
        XTR_TAX_BROKERAGE_SETUP a,
        XTR_TAX_DEDUCTION_CALCS_V d
   where p.PARTY_CODE     = l_ref_party
   and   b.TAX_CATEGORY   = p.TAX_CATEGORY
   and   b.DEFAULT_TYPE   = 'T'
   and   b.DEAL_TYPE      = l_deal_type
   and  (b.DEAL_SUBTYPE   = l_subtype or b.DEAL_SUBTYPE is NULL)
   and  (b.PRODUCT_TYPE   = l_product or b.PRODUCT_TYPE is NULL)
   and  (b.PARTY_CODE     = l_ref_party or b.PARTY_CODE is NULL)
   and   nvl(a.AUTHORISED,'N')= 'Y'
   and   a.DEAL_TYPE      = l_deal_type
   and   d.DEAL_TYPE      = a.DEAL_TYPE
   and   d.CALC_TYPE      = a.CALC_TYPE
   order by b.DEAL_TYPE, b.DEAL_SUBTYPE,  nvl(b.PRODUCT_TYPE, '');
--
begin
 open SETTLE_DFLTS;
  fetch SETTLE_DFLTS INTO l_prin_settled_by,l_int_settled_by,l_int_freq;
 if SETTLE_DFLTS%NOTFOUND then
  l_prin_settled_by := 'D';
  l_int_settled_by  := 'D';
  l_int_freq        := 'M';
 end if;
 close SETTLE_DFLTS;
--
 open BROKER_DFLTS;
--fetch BROKER_DFLTS INTO l_bkr_ref,l_bkr_rate,l_bkr_amount;
  fetch BROKER_DFLTS INTO l_bkr_ref,l_bkr_amt_type;
 close BROKER_DFLTS;
--
 open TAX_DFLTS;
--fetch TAX_DFLTS INTO l_tax_ref,l_tax_rate;
  fetch TAX_DFLTS INTO l_prin_tax_ref, l_income_tax_ref, l_calc_type;
 close TAX_DFLTS;

 if (l_deal_type='FX') then
     if (l_calc_type = 'SELL_F') then
	l_ccy := l_sell_ccy;
     end if;
 end if;

end TAX_BROKERAGE_DEFAULTING;
--
----------------------------------------------------------------------------------------------------------------
--  Procedure to find amount type for the broker and tax reference
PROCEDURE TAX_BROKERAGE_AMT_TYPE(l_deal_type       IN VARCHAR2,
                                 l_bkr_ref         IN VARCHAR2,
                                 l_tax_ref         IN VARCHAR2,
                                 l_bkr_amt_type    IN OUT NOCOPY VARCHAR2,
                                 l_tax_amt_type    IN OUT NOCOPY VARCHAR2) is
--
 cursor BKR_AMT_TYPE is
  select d.AMOUNT_TYPE
  from  XTR_TAX_BROKERAGE_SETUP a,
        XTR_DEDUCTION_CALCS_V d
  where  a.DEAL_TYPE          = l_deal_type
   and   a.REFERENCE_CODE     = l_bkr_ref
   and   nvl(a.AUTHORISED,'N')= 'Y'
   and   d.DEAL_TYPE          = a.DEAL_TYPE
   and   d.CALC_TYPE          = a.CALC_TYPE;
--
 cursor TAX_AMT_TYPE is
  select d.AMOUNT_TYPE
  from  XTR_TAX_BROKERAGE_SETUP a,
        XTR_DEDUCTION_CALCS_V d
  where  a.DEAL_TYPE          = l_deal_type
   and   a.REFERENCE_CODE     = l_tax_ref
   and   nvl(a.AUTHORISED,'N')= 'Y'
   and   d.DEAL_TYPE          = a.DEAL_TYPE
   and   d.CALC_TYPE          = a.CALC_TYPE;
--
begin
 open  BKR_AMT_TYPE;
 fetch BKR_AMT_TYPE INTO l_bkr_amt_type;
 close BKR_AMT_TYPE;
--
 open  TAX_AMT_TYPE;
 fetch TAX_AMT_TYPE INTO l_tax_amt_type;
 close TAX_AMT_TYPE;
--
end TAX_BROKERAGE_AMT_TYPE;

----------------------------------------------------------------------------------------------------------------
/******** One Step Settlement Method ****************/
Procedure One_Step_Settlement (p_one_step_rec IN OUT NOCOPY one_step_rec_type)
is
     v_deal_error Boolean;
     v_user_error Boolean;
     v_duplicate_error Boolean;
     v_mandatory_error Boolean;
     v_validation_error Boolean;
     v_limit_error Boolean;

     v_exp_rec Xtr_Exposure_Transactions%Rowtype;
     v_cparty Xtr_Tax_Brokerage_Setup_V.Payee%Type;
     v_settlement_code Xtr_One_Step_Settle_Codes.Settlement_Code%Type;
     v_amount_hce Xtr_Exposure_Transactions.Amount_HCE%Type;
     v_comments Xtr_Exposure_Transactions.Comments%Type;
     v_settle_method Xtr_Tax_Brokerage_Setup.Tax_Settle_Method%Type;
     v_party_type  Xtr_Parties_V.Party_Type%Type;

 cursor CALC_HCE_AMTS is
  select round(abs(p_one_step_rec.p_amount) / s.HCE_RATE,2)
   from  XTR_MASTER_CURRENCIES_V s
   where s.CURRENCY = upper(p_one_step_rec.p_CURRENCY);

BEGIN
/**** for a given schedule code what is the tax settle method defined in setup is derived here *****/

     Begin
        Select tax_settle_method
        Into  v_settle_method
        From Xtr_Tax_Brokerage_Setup_V
        Where reference_code = p_one_step_rec.p_schedule_code;
     Exception
        When no_data_found then
        null;
     End;

     p_one_step_rec.p_settle_method := v_settle_method;

     -- Do not proceed if the schedule settle method is not of One Step
     --   Settlement.  The only exception is if the caller coming from ONC
     --   (p_source = 'TAX_CP_G') and the reneg interest action is
     --   Compound Gross and the settlement method is not NIA.
     If (v_settle_method <> 'OSG' and
         (p_one_step_rec.p_source <> 'TAX_CP_G' or
          v_settle_method = 'NIA')) then
        return;
     End if;

/*****  bug # 2488461 issue 7
       settlement code defined during setup is obtained here.  if not found, then error out *****/
     Begin
        Select settlement_code
        Into v_settlement_code
        From XTR_ONE_STEP_SETTLE_CODES_V
        Where company_code = p_one_step_rec.p_company_code
        And schedule = p_one_step_rec.p_schedule_code;
     Exception
        When NO_DATA_FOUND then
        /***** if no settlement code is found for this schedule, then
        v_settlement_code is equated to null ********/
        v_settlement_code := null;

        When OTHERS then
        null;
     End;

     If v_settlement_code is null then
     /******* bug 2488461 issue 7
     if for the given schedule code no settlement code is found then,
     get settlement code which has no schedule defined ****/
        Begin
          Select settlement_code
          Into v_settlement_code
          From XTR_ONE_STEP_SETTLE_CODES_V
          Where company_code = p_one_step_rec.p_company_code
          And schedule is null;
        Exception
          When NO_DATA_FOUND then
          p_one_step_rec.p_error := 'XTR_MISSING_SETTLE_CODE';
          return;
       End;
     End if;

/***** settlement code name is provided to comments column ****/
    Begin
      Select name
      Into v_comments
      From Xtr_Exposure_Types_V
      Where Exposure_Type = v_settlement_code
      And Company_Code = p_one_step_rec.p_company_code;
    Exception
      When no_data_found then
      p_one_step_rec.p_error := 'XTR_MISSING_SETTLE_CODE_NAME';
      return;
    End;

/**** amount hce is calculated here *****/
   open CALC_HCE_AMTS;
   fetch CALC_HCE_AMTS INTO v_amount_hce;
   if CALC_HCE_AMTS%NOTFOUND then
       v_amount_hce := 0;
       close CALC_HCE_AMTS;
   end if;
   close CALC_HCE_AMTS;

/*************Exp api preparatory ***********************/
v_exp_rec.company_code := p_one_step_rec.p_company_code;
v_exp_rec.DEAL_TYPE := 'EXP';
v_exp_rec.DEAL_SUBTYPE := 'FIRM';
v_exp_rec.EXPOSURE_TYPE := v_settlement_code;
v_exp_rec.CURRENCY := p_one_step_rec.p_Currency;
v_exp_rec.VALUE_DATE := p_one_step_rec.p_settlement_date ;
v_exp_rec.amount :=  abs(p_one_step_rec.p_Amount);
v_exp_rec.SETTLE_ACTION_REQD := 'Y';
v_exp_rec.amount_hce := abs(v_Amount_Hce);
v_exp_rec.THIRDPARTY_CODE := p_one_step_rec.p_Cparty_Code;
v_exp_rec.action_code := 'PAY';
v_exp_rec.AMOUNT_TYPE := 'AMOUNT';
v_exp_rec.account_no := p_one_step_rec.p_Settlement_Account;
v_exp_rec.TAX_BROKERAGE_TYPE := 'Y';
v_exp_rec.COMMENTS := v_comments;
v_exp_rec.CPARTY_ACCOUNT_NO := p_one_step_rec.p_cparty_account_no;

/***** EXP open API which inserts into Xtr_Exposure_Transactions and Xtr_Deal_Date_Amounts ******/

      XTR_EXP_TRANSFERS_PKG.TRANSFER_EXP_DEALS(v_exp_rec,
                                         p_one_step_rec.p_source,
                                         v_user_error,
                                         v_mandatory_error,
                                         v_validation_error,
                                         v_limit_error);
/**** exp transaction number generated in EXP API is passed out to the calling form *****/
p_one_step_rec.p_exp_number := v_exp_rec.Transaction_Number;

END One_Step_Settlement;

----------------------------------------------------------------------------------------------------------------
--   Procedure to update / delete existing journal entries
--  when cancelling a deal(s).
PROCEDURE UPDATE_JOURNALS (l_deal_nos  IN NUMBER,
                           l_trans_nos IN NUMBER,
                           l_deal_type IN VARCHAR2) is
--
 l_sysdate DATE;
 l_user    VARCHAR2(30);
--
/* AW Bug 1216835
 cursor TOD_DATE is
  select sysdate,user
   from DUAL;
*/

 cursor TOD_DATE is
  select sysdate, dealer_code
  from   xtr_dealer_codes_v
  where  user_id = fnd_global.user_id;

--
begin
null;
/* move to db_trigger on deals,rollover_transactions
 open TOD_DATE;
  fetch TOD_DATE INTO l_sysdate,l_user;
 close TOD_DATE;
-- Update rows in journals where journal HAS NOT been transferred to
-- the General Ledger. Set the cancelled_in_gl to Y.
 update JOURNALS
  set JNL_REVERSAL_IND = 'C',
      CANCELLED_IN_GL  = 'Y'
  where DEAL_NUMBER = l_deal_nos
  and   TRANSACTION_NUMBER = l_trans_nos
  and   DEAL_TYPE = l_deal_type
  and   GL_TRANSFER_DATE is null;
--
-- Update rows in journals where journal HAS been transferred to the
-- General Ledger, this indicates that the journal requires reversal.
 update JOURNALS
  set JNL_REVERSAL_IND = 'Y',
      UPDATED_ON       = l_sysdate,
      UPDATED_BY       = l_user
  where DEAL_NUMBER = l_deal_nos
  and   TRANSACTION_NUMBER = l_trans_nos
  and   DEAL_TYPE = l_deal_type
  and   GL_TRANSFER_DATE is not null;
*/
end UPDATE_JOURNALS;

---------------------------------------------------------------
/*************************************************************/
/* Updates transaction's floating rate based on the deal's   */
/* Benchmark Rate and Margin.                                */
/* The parameters are passed in through concurrent program.  */
/*************************************************************/
PROCEDURE RESET_FLOATING_RATES(errbuf       	OUT NOCOPY VARCHAR2,
                      	       retcode      	OUT NOCOPY NUMBER,
			           p_rateset_from   IN VARCHAR2,
                               p_rateset_to     IN VARCHAR2,
                               p_rateset_adj    IN NUMBER,
                               p_deal_type      IN VARCHAR2,
                               p_company        IN VARCHAR2,
                               p_cparty         IN VARCHAR2,
                               p_portfolio      IN VARCHAR2,
                               p_currency       IN VARCHAR2,
                               p_ric_code       IN VARCHAR2,
			       p_source         IN VARCHAR2) IS

   l_buf VARCHAR2(300);
   l_rowid         VARCHAR2(30);
   l_company       XTR_DEALS.COMPANY_CODE%TYPE;
   l_deal_no       NUMBER;
   l_tran_no       NUMBER;
   l_deal_type     XTR_DEALS.DEAL_TYPE%TYPE;
   l_start_date    DATE;
   l_ratefix_date  DATE;
   l_ric_code      XTR_DEALS.RATE_BASIS%TYPE;
   l_margin        NUMBER;
   l_new_rate      NUMBER;
   l_rate          NUMBER;
   l_valid_ok      BOOLEAN;
   l_error         NUMBER;
   l_count         NUMBER:= 0;
   l_hold          VARCHAR2(1);

   /*-------------------------------------------------*/
   /*  Selection criteria for transactions :          */
   /*  - only companies that are authorised to user   */
   /*  - only TMM and IRS deals with Benchmark Rate   */
   /*  - RATE_FIXING_DATE is not null on transaction  */
   /*  - RATE_FIXING_DATE within parameter date range */
   /*-------------------------------------------------*/
   cursor curr_all_tran is
   select distinct a.ROWID,
          a.COMPANY_CODE,
          a.DEAL_NUMBER,
          a.TRANSACTION_NUMBER,
          a.DEAL_TYPE,
          a.START_DATE,
          a.RATE_FIXING_DATE,
          b.RATE_BASIS,
          nvl(b.MARGIN,0)
   from   XTR_ROLLOVER_TRANSACTIONS a,
          XTR_DEALS                 b,
          XTR_PARTIES_V             c
   where  a.deal_type      = NVL(p_deal_type,a.deal_type)
   and    a.deal_type in ('TMM','IRS')
   and    a.company_code   = NVL(p_company,a.company_code)
   and    a.company_code   = c.party_code  -- user access
   and    a.cparty_code    = NVL(p_cparty,a.cparty_code)
   and    a.portfolio_code = NVL(p_portfolio,a.portfolio_code)
   and    a.currency       = NVL(p_currency,a.currency)
   and    a.deal_number    = b.deal_no
   and    a.rate_fixing_date is not null
   and    a.rate_fixing_date between fnd_date.canonical_to_date(p_rateset_from)
                             and     fnd_date.canonical_to_date(p_rateset_to)
   and    b.rate_basis is not null
   and    b.rate_basis   = nvl(p_ric_code, b.rate_basis)
   and    b.STATUS_CODE  = 'CURRENT'
   order by a.deal_type,  a.deal_number,
            a.start_date, a.transaction_number;

   -- The following cursor will determine whether the record is the
   -- latest transaction with the same deal number. If no data found, then
   -- it's the latest transactions and we want to update the subsequent row.
   -- If something found, then we only want to update one row.
   cursor C_ONE_ROW is
   select 'Y'
   from xtr_rollover_transactions
   where deal_number = l_deal_no
   and transaction_number = l_tran_no
   and rate_fixing_date <
        (select max(rate_fixing_date)
         from xtr_rollover_transactions
         where deal_number = l_deal_no
         and rate_fixing_date between fnd_date.canonical_to_date(p_rateset_from)
         and fnd_date.canonical_to_date(p_rateset_to));

Begin

   retcode := 0;
   -- Modified Bug 4514808
  if fnd_date.canonical_to_date(p_rateset_from) > sysdate then
   retcode := 2;
   FND_MESSAGE.SET_NAME('XTR', 'XTR_RESET_DATE_FROM');
      l_buf := FND_MESSAGE.GET;
      fnd_file.put_line(fnd_file.log, l_buf);
 end if;
 if fnd_date.canonical_to_date(p_rateset_to) > sysdate then
   retcode := 2;
   FND_MESSAGE.SET_NAME('XTR', 'XTR_RESET_DATE_TO');
      l_buf := FND_MESSAGE.GET;
      fnd_file.put_line(fnd_file.log, l_buf);
 end if;
If(retcode = 0)then
   OPEN curr_all_tran;
   LOOP
      FETCH curr_all_tran into l_rowid,        l_company,
                               l_deal_no,      l_tran_no,
                               l_deal_type,    l_start_date,
                               l_ratefix_date, l_ric_code,
                               l_margin;
      EXIT when curr_all_tran%notfound;
      l_count := l_count +1;

      VALIDATE_TRANSACTION (l_company,
                            l_deal_no,
		            l_deal_type,
                            l_start_date,
			    l_valid_ok,
			    l_error);

      if l_valid_ok then
         GET_BENCHMARK_RATE(l_ric_code,
		            l_ratefix_date,
                            nvl(p_rateset_adj,0),
			    l_new_rate);

         if l_new_rate is not null then
      	    open C_ONE_ROW;
      	    fetch C_ONE_ROW into l_hold;
            if C_ONE_ROW%FOUND then   -- update only one row
                UPDATE_RATE_ONE_TRANSACTION(l_deal_no,
				       l_tran_no,
                                       l_deal_type,
				       l_start_date,
			               l_new_rate + (l_margin/100));
	        l_rate := l_new_rate + (l_margin/100);
	        FND_MESSAGE.SET_NAME('XTR', 'XTR_UPDATE_BENCH_RATE');
	        FND_MESSAGE.SET_TOKEN('BENCH_RATE', l_rate);
	        FND_MESSAGE.SET_TOKEN('DEAL_TYPE', l_deal_type);
	        FND_MESSAGE.SET_TOKEN('DEAL_NO', l_deal_no);
	        FND_MESSAGE.SET_TOKEN('TRANS_NO', l_tran_no);
	        FND_MESSAGE.SET_TOKEN('RATE_DATE', l_ratefix_date);
                l_buf := FND_MESSAGE.GET;
   	        fnd_file.put_line(fnd_file.log, l_buf);
	    else  --update current record as well as subsequent transactions
		UPDATE_RATE_SEQ_TRANSACTION(l_deal_no,
                                       l_tran_no,
                                       l_deal_type,
                                       l_start_date,
                                       l_new_rate + (l_margin/100));
                l_rate := l_new_rate + (l_margin/100) ;
                FND_MESSAGE.SET_NAME('XTR', 'XTR_UPDATE_BENCH_SEQ_RATE');
                FND_MESSAGE.SET_TOKEN('BENCH_RATE', l_rate);
                FND_MESSAGE.SET_TOKEN('DEAL_TYPE', l_deal_type);
                FND_MESSAGE.SET_TOKEN('DEAL_NO', l_deal_no);
                FND_MESSAGE.SET_TOKEN('TRANS_NO', l_tran_no);
                FND_MESSAGE.SET_TOKEN('RATE_DATE', l_ratefix_date);
                l_buf := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log, l_buf);
	    end if;
	    close C_ONE_ROW;
	 else
	    retcode := 1;
            FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_BENCH_RATE');
            FND_MESSAGE.SET_TOKEN('DEAL_TYPE', l_deal_type);
            FND_MESSAGE.SET_TOKEN('DEAL_NO', l_deal_no);
            FND_MESSAGE.SET_TOKEN('TRANS_NO', l_tran_no);
            FND_MESSAGE.SET_TOKEN('RATE_DATE', l_ratefix_date);
            l_buf := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, l_buf);
         end if;
      else   -- do not pass validation. return error message
	 retcode := 1;
	 if l_error = 1 then  -- deal been settled
            FND_MESSAGE.SET_NAME('XTR', 'XTR_BENCH_SETTLE');
            FND_MESSAGE.SET_TOKEN('DEAL_TYPE', l_deal_type);
            FND_MESSAGE.SET_TOKEN('DEAL_NO', l_deal_no);
            FND_MESSAGE.SET_TOKEN('TRANS_NO', l_tran_no);
            FND_MESSAGE.SET_TOKEN('RATE_DATE', l_ratefix_date);
            l_buf := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, l_buf);
	 elsif l_error = 2 then   -- Accrual has been generated
            FND_MESSAGE.SET_NAME('XTR', 'XTR_BENCH_ACCRUAL');
            FND_MESSAGE.SET_TOKEN('DEAL_TYPE', l_deal_type);
            FND_MESSAGE.SET_TOKEN('DEAL_NO', l_deal_no);
            FND_MESSAGE.SET_TOKEN('TRANS_NO', l_tran_no);
            FND_MESSAGE.SET_TOKEN('RATE_DATE', l_ratefix_date);
            l_buf := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, l_buf);
         elsif l_error = 3 then   -- revalaution has been done
            FND_MESSAGE.SET_NAME('XTR', 'XTR_BENCH_REVAL');
            FND_MESSAGE.SET_TOKEN('DEAL_TYPE', l_deal_type);
            FND_MESSAGE.SET_TOKEN('DEAL_NO', l_deal_no);
            FND_MESSAGE.SET_TOKEN('TRANS_NO', l_tran_no);
            FND_MESSAGE.SET_TOKEN('RATE_DATE', l_ratefix_date);
            l_buf := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, l_buf);
         elsif l_error = 4 then   -- journal has been generated
            FND_MESSAGE.SET_NAME('XTR', 'XTR_BENCH_JOURNAL');
            FND_MESSAGE.SET_TOKEN('DEAL_TYPE', l_deal_type);
            FND_MESSAGE.SET_TOKEN('DEAL_NO', l_deal_no);
            FND_MESSAGE.SET_TOKEN('TRANS_NO', l_tran_no);
            FND_MESSAGE.SET_TOKEN('RATE_DATE', l_ratefix_date);
            l_buf := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, l_buf);
         end if;
     end if;  -- valid OK
   END LOOP;
   CLOSE curr_all_tran;

   if l_count = 0 then
      retcode := 1;
        -- No deals/transactions were found using the specified search criteria.
      FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_ELIGI_BENCH');
      l_buf := FND_MESSAGE.GET;
      fnd_file.put_line(fnd_file.log, l_buf);
   end if;
end if; -- Bug 4514808
End RESET_FLOATING_RATES;

--------------------------------------------------
PROCEDURE VALIDATE_TRANSACTION(p_company        IN VARCHAR2,
                               p_deal_no        IN NUMBER,
                               p_deal_type      IN VARCHAR2,
                               p_start_date     IN DATE,
                               p_valid_ok       OUT NOCOPY BOOLEAN,
			       p_error		OUT NOCOPY NUMBER)IS

 l_error 	BOOLEAN;
 l_date		DATE:= null;


  cursor check_settlement_done is
   select nvl(min(amount_date),p_start_date)    -- Ilavenil modified for witholding tax project
   from   xtr_deal_date_amounts
   where  company_code = p_company
   and    deal_number  = p_deal_no
   and    settle = 'Y'
   and    amount_date > p_start_date
   /******** Ilavenil modified for witholding tax *********/
   union
   select nvl(min(a.amount_date),p_start_date)  -- Ilavenil modified for witholding tax project
   from   xtr_deal_date_amounts a,
   xtr_rollover_transactions b
   where  b.company_code = p_company
   and    b.deal_number  = p_deal_no
   and   (b.tax_settled_reference is not null)
   and    a.company_code = p_company
   and    a.deal_type    = 'EXP'
   and    a.transaction_number in (b.tax_settled_reference)
   and    nvl(a.settle,'N') = 'Y'
   and    b.maturity_date  > p_start_date
   order by 1 desc;
   /**********/


  /********* cursor below added by Ilavenil for witholding tax project *********/
   cursor last_intset_date is
          select nvl(max(journal_date), p_start_date)
          from   xtr_journals
          where  deal_number = p_deal_no
          and    amount_type in ('INTSET','TAX') -- Ilavenil modified for witholding tax
          union
  /********* Ilavenil modified for witholding tax *********/
          select nvl(max(b.maturity_date), p_start_date)
          from   xtr_journals a,
                 xtr_rollover_transactions b
          where  b.company_code =p_company
          and    b.deal_number  = p_deal_no
          and    b.tax_settled_reference is not null
          and    a.company_code = p_company
          and    a.deal_type    = 'EXP'
          and    a.transaction_number = b.tax_settled_reference
          order by 1 desc;
  /**********/

/********************************/
/* Prepaid Interest             */
/********************************/
   Cursor c_prepaid_int is
   select prepaid_interest
   from XTR_DEALS_V
   where deal_no = p_deal_no;
   l_pre_int	VARCHAR2(1) := NULL;

   Cursor last_int_set is
   select max(maturity_date)
   from xtr_rollover_transactions_v
   where deal_number = p_deal_no
   and org_trans_no in  (select min(transaction_number)
				from xtr_deal_date_amounts
				where deal_number = p_deal_no
				and amount_type = 'INTSET'
				and nvl(settle, 'N') = 'Y')
   and maturity_date > p_start_date;
   l_int_set_date DATE := NULL;


 cursor check_jrnl_done is
 select nvl(max(journal_date), p_start_date)
 from   xtr_journals
 where  deal_number = p_deal_no
 and    amount_type in ('INTSET','TAX')
 union
 select nvl(max(b.maturity_date), p_start_date)
 from   xtr_journals a,
        xtr_rollover_transactions b
 where  b.company_code = p_company
 and    b.deal_number  = p_deal_no
 and    b.tax_settled_reference is not null
 and    a.company_code = p_company
 and    a.deal_type    = 'EXP'
 and    a.transaction_number = b.tax_settled_reference
 order by 1 desc;

   Cursor last_int_journal is
   select nvl(max(maturity_date), p_start_date)
   from xtr_rollover_transactions
   where deal_number = p_deal_no
   and transaction_number in (select transaction_number
                                from xtr_deal_date_amounts
                                where deal_number = p_deal_no
                                and amount_type = 'INTSET'
                                and batch_id is NOT NULL);

   l_int_journal_date DATE := NULL;

 cursor check_accrual_done is
 select max(period_to)
 from xtr_accrls_amort
 where deal_no = p_deal_no
 and period_to > p_start_date;

 cursor check_reval_done is
 select max(b.period_end)
 from xtr_batches b, xtr_batch_events e, xtr_revaluation_details r
 where b.batch_id = e.batch_id
 and b.batch_id = r.batch_id
 and r.deal_no = p_deal_no
 and b.company_code = p_company
 and e.event_code = 'REVAL'
 and b.period_end > p_start_date;

Begin
 p_valid_ok := TRUE;
 if p_deal_type = 'TMM' then
    open c_prepaid_int;
    fetch c_prepaid_int into l_pre_int;
    close c_prepaid_int;
 end if;

 Open check_settlement_done;
 Fetch check_settlement_done into l_date;
 If (l_date is NOT NULL and l_date > p_start_date) then
    close check_settlement_done;
    p_valid_ok := FALSE;
    p_error := 1;
    return;
 else
    close check_settlement_done;
    if p_deal_type = 'TMM' and nvl(l_pre_int, 'N') = 'Y' then -- TMM prepaid interest deal
       Open last_int_set;
       Fetch last_int_set into l_int_set_date;
       if l_int_set_date is NOT NULL and l_int_set_date > p_start_date then
	     Close last_int_set;
	     p_valid_ok := FALSE;
	     p_error    := 1;
	     return;
       else
	     Close last_int_set;
             p_valid_ok := TRUE;
       end if;
    else
       p_valid_ok := TRUE;
    end if;
 end if;

 Open check_jrnl_done;
 Fetch check_jrnl_done into l_date;
 if l_date is NOT NULL and l_date > p_start_date then
    close check_jrnl_done;
    p_valid_ok := FALSE;
    p_error := 4;
    return;
 else
    close check_jrnl_done;
    if p_deal_type = 'TMM' and nvl(l_pre_int, 'N') = 'Y' then -- TMM prepaid interest deal
	open last_int_journal;
	fetch last_int_journal into l_int_journal_date;
        if l_int_journal_date is NOT NULL and l_int_journal_date > p_start_date then
             Close last_int_journal;
             p_valid_ok := FALSE;
             p_error    := 4;
             return;
        else
             Close last_int_journal;
             p_valid_ok := TRUE;
        end if;
    else
       p_valid_ok := TRUE;
    end if;
 end if;

 Open check_accrual_done;
 Fetch check_accrual_done into l_date;
 if  l_date is NOT NULL then
    close check_accrual_done;
    p_valid_ok := FALSE;
    p_error := 2;
    return;
 else
    close check_accrual_done;
    p_valid_ok := TRUE;
 end if;

 Open check_reval_done;
 Fetch check_reval_done into l_date;
 if l_date is NOT NULL then
    close check_reval_done;
    p_valid_ok := FALSE;
    p_error := 3;
    return;
 else
    close check_reval_done;
    p_valid_ok := TRUE;
 end if;

 Open last_intset_date;
 Fetch last_intset_date into l_date;
 if (l_date is NOT NULL and l_date > p_start_date )then
    close last_intset_date;
    p_valid_ok := FALSE;
    p_error := 1;
    return;
 else
    close last_intset_date;
    p_valid_ok := TRUE;
 end if;

End VALIDATE_TRANSACTION;

----------------------------------------------------------
/*************************************************************/
/* The following code finds the next interest rate based on  */
/* the benchmark rate of the deal and the rate fixing date   */
/* of the transaction.^                                      */
/* It will first look at BID rate, and if it is null, then   */
/* look for ASK rate, if both are null, then the next closest*/
/* interest rate will be used. If none are found, then log   */
/* this to the file.                                         */
/* Parameters:                                               */
/* p_ric_code    - Benchmark Rate code of the deal           */
/* p_rate_date   - Transaction's Rate Fixing Date            */
/* p_rateset_adj - No of backdated days to search for interest*/
/*                 rate.  Entered by user.                   */
/* p_rate        - The benchmark Interest Rate               */
/*************************************************************/
PROCEDURE GET_BENCHMARK_RATE(p_ric_code         IN VARCHAR2,
                             p_rate_date        IN DATE,
                             p_rateset_adj      IN NUMBER,
                             p_rate             OUT NOCOPY NUMBER)IS
   /*-------------------------------------------------*/
   /*  Select interest rate that is :                 */
   /*  - either BID rate or ASK rate is not null      */
   /*  - closest to the transaction Rate Reset Date,  */
   /*    with rateset day adjustment.                 */
   /*-------------------------------------------------*/
   cursor curr_bench_rate is
   select nvl(BID_RATE,OFFER_RATE)
   from   XTR_INTEREST_PERIOD_RATES_V
   where  UNIQUE_PERIOD_ID = p_ric_code
   and   trunc(rate_date) between (p_rate_date-nvl(p_rateset_adj,0)) -- Bug 5259621
                     and      p_rate_date -- Bug 5259621
   and   (bid_rate is not null or offer_rate is not null)
   order by rate_date desc;

Begin
   p_rate := null;

   OPEN curr_bench_rate;
   LOOP
      FETCH curr_bench_rate into p_rate;
      if curr_bench_rate%notfound then -- No Interest Rate found.
         EXIT;
      else
         if p_rate is not null then  --  New Interest Rate is found.
            EXIT;
         end if;
      end if;
   END LOOP;
   CLOSE curr_bench_rate;

End GET_BENCHMARK_RATE;
--------------------------------------------------------
PROCEDURE UPDATE_RATE_ONE_TRANSACTION(p_deal_no     IN NUMBER,
                                  p_trans_no    IN NUMBER,
                                  p_deal_type   IN VARCHAR2,
            	          p_start_date  IN DATE,
                                  p_new_rate    IN NUMBER)IS
-- Add xtr_deals.rounding_type for Interest Override
 cursor TMM_ROLL is
    select r.deal_subtype, r.currency, r.rowid, r.adjusted_balance,
      r.no_of_days,r.year_basis,r.interest, r.settle_term_interest,
      r.accum_interest_bf, r.accum_interest,r.interest_hce,
      r.interest_settled, r.trans_closeout_no, r.start_date,
      r.maturity_date, r.transaction_number, r.interest_rate,
      r.principal_action,r.principal_adjust, r.balance_out_bf,
      d.rounding_type,
      /**** code below added by Ilavenil for witholding tax project *****/
      r.tax_amount,
      r.tax_code,
      r.tax_settled_reference, r.tax_amount_hce ,
      r.tax_rate,
      r.balance_out,
      d.settle_account_no,
      d.company_code, d.cparty_code, d.year_calc_type
      /**********/
 from XTR_ROLLOVER_TRANSACTIONS r,
 XTR_DEALS d
 where r.deal_number = d.deal_no
 and r.deal_type = p_deal_type
 and r.deal_type = 'TMM'
 and r.deal_number = p_deal_no
 and r.transaction_number = p_trans_no;  -- bug 3814944

 pmt TMM_ROLL%ROWTYPE;

 cursor LAST_TMM is
 select rowid
 from XTR_ROLLOVER_TRANSACTIONS_V
 where deal_number = p_deal_no
 and status_code = 'CURRENT'
 order by maturity_date desc, start_date desc, transaction_number desc;

 last_pmt LAST_TMM%ROWTYPE;

--Add d.rounding_type for Interest Override
 cursor IRS_ROLL is
 select r.currency, r.balance_out, r.no_of_days, d.year_basis,
        d.deal_subtype, d.rounding_type
 from XTR_DEALS d,
      XTR_ROLLOVER_TRANSACTIONS r
 where d.deal_type = p_deal_type
 and d.deal_type = 'IRS'
 and d.deal_no = r.deal_number
 and r.deal_number = p_deal_no
 and r.transaction_number = p_trans_no;

 l_currency     VARCHAR2(15);
 cursor RND_YR_TMM is
 select rounding_factor, hce_rate
 from XTR_MASTER_CURRENCIES_V
 where currency = pmt.currency;

 cursor RND_YR_IRS is
 select rounding_factor, hce_rate
 from XTR_MASTER_CURRENCIES_V
 where currency = l_currency;

 l_no_of_days	NUMBER;
 l_year_basis	NUMBER;
 l_interest	NUMBER;
 l_int_rate	NUMBER;
 l_accum_int	NUMBER;
 l_int_settled  NUMBER;
 l_int_hce	NUMBER;
 l_accum_int_hce NUMBER;
 l_accum_int_bf_hce	NUMBER;
 l_balance_out	NUMBER;
 new_accum_int  NUMBER;
 l_round	NUMBER;
 l_hce_rate	NUMBER;
 l_deal_subtype VARCHAR2(7);
 l_int_settle_hce  NUMBER;
 l_prin_adj	NUMBER;
 l_rounding_type VARCHAR2(1); -- Add Interest Override

 v_RT Xtr_Rollover_Transactions_V%Rowtype;
 v_first_time Char(1) := 'Y';
 v_last_trans Varchar2(1) ;
 v_prncpl_ctype Xtr_Tax_Brokerage_Setup.Calc_Type%type;
 v_prncpl_method Xtr_Tax_Brokerage_Setup.tax_settle_method%type;
 v_income_ctype Xtr_Tax_Brokerage_Setup.Calc_Type%type;
 v_income_method Xtr_Tax_Brokerage_Setup.tax_settle_method%type;

Begin

  If p_deal_type = 'TMM' then
     /*------------------------------*/
     /* XTRINWHL.invalidate_deal     */
     /*------------------------------*/
     Update XTR_CONFIRMATION_DETAILS
     set confirmation_validated_by = null,
          confirmation_validated_on = to_date(null)
     where deal_no = p_deal_no;

     Update XTR_ROLLOVER_TRANSACTIONS
     set interest_rate = p_new_rate
     where deal_number = p_deal_no
     and transaction_number = p_trans_no;

     update XTR_DEAL_DATE_AMOUNTS
     set transaction_rate = p_new_rate
     where deal_number = p_deal_no
     and transaction_number = p_trans_no;

     open LAST_TMM;
     fetch LAST_TMM INTO last_pmt;
     close LAST_TMM;

     /*------------------------------*/
     /* XTRINWHL.recalc_this_dt_row  */
     /*------------------------------*/
     Open TMM_ROLL;
     fetch TMM_ROLL into pmt;
     LOOP
         EXIT when TMM_ROLL%NOTFOUND;
         /******** code below added by Ilavenil for witholding tax project *********/
         If v_first_time = 'Y' then
             XTR_FPS2_P.Get_Settle_Method (null,
                                       v_prncpl_ctype,
                                       v_prncpl_method,
                                       pmt.tax_code,
                                       v_income_ctype,
                                       v_income_method);
             v_first_time := 'N';
         End if;
        /**********/

	 open RND_YR_TMM;
	 fetch RND_YR_TMM into l_round, l_hce_rate;
	 close RND_YR_TMM;

 	l_hce_rate := nvl(l_hce_rate, 1);
	l_round    := nvl(l_round, 2);

        if NVL(pmt.PRINCIPAL_ACTION,'@#@') = 'DECRSE' then
           l_prin_adj := (-1) * nvl(pmt.PRINCIPAL_ADJUST,0);
        else
           l_prin_adj := nvl(pmt.PRINCIPAL_ADJUST,0);
        end if;

        pmt.ADJUSTED_BALANCE := nvl(pmt.BALANCE_OUT_BF,0) + l_prin_adj;

        pmt.accum_interest_bf := nvl(new_accum_int,pmt.accum_interest_bf);
        if pmt.ROWID=last_pmt.ROWID then

  --Add Interest Override
           pmt.interest := INTEREST_ROUND(pmt.balance_out_bf * p_new_rate /100 *
                      pmt.no_of_days / pmt.year_basis, l_round, pmt.rounding_type);
        else
           pmt.interest := INTEREST_ROUND(pmt.adjusted_balance * p_new_rate /100 *
                      pmt.no_of_days / pmt.year_basis, l_round, pmt.rounding_type);
        end if;

	if pmt.SETTLE_TERM_INTEREST = 'Y' then
	   if pmt.trans_closeout_no is null then
	      pmt.accum_interest := 0;
	      pmt.interest_settled := nvl(pmt.accum_interest_bf,0) +
				      nvl(pmt.interest,0);
	   else
	      pmt.accum_interest := nvl(pmt.accum_interest_bf,0) +
				    nvl(pmt.interest,0) - nvl(pmt.interest_settled,0);
	   end if;
	else  -- not settled yet
	   if pmt.trans_closeout_no is null then
	      pmt.interest_settled := 0;
	   end if;
	   pmt.accum_interest := nvl(pmt.accum_interest_bf,0) +
			         nvl(pmt.interest,0) - nvl(pmt.interest_settled,0);
	end if;

	-- Calcuate HCE amounts
        new_accum_int := nvl(pmt.accum_interest,0);
	l_int_hce := round(pmt.interest /l_hce_rate, l_round);
        l_int_settle_hce := round(pmt.interest_settled /l_hce_rate, l_round);
	l_accum_int_hce := round(pmt.accum_interest /l_hce_rate, l_round);
	l_accum_int_bf_hce := round(pmt.accum_interest_bf /l_hce_rate, l_round);

     /******* code below added by Ilavenil *********/
     v_RT.TAX_SETTLED_REFERENCE     := pmt.TAX_SETTLED_REFERENCE;
     v_RT.TAX_RATE                  := pmt.TAX_RATE;
     v_RT.TAX_AMOUNT                := pmt.TAX_AMOUNT;
     v_RT.TAX_AMOUNT_HCE            := pmt.TAX_AMOUNT_HCE;
     v_RT.TAX_CODE                  := pmt.TAX_CODE;

     v_RT.INTEREST_SETTLED          := pmt.INTEREST_SETTLED;
     v_RT.DEAL_NUMBER               := p_DEAL_NO;
     v_RT.TRANSACTION_NUMBER        := pmt.TRANSACTION_NUMBER;
     v_RT.START_DATE                := pmt.START_DATE;
     v_RT.MATURITY_DATE             := pmt.MATURITY_DATE;

     v_RT.CURRENCY                  := pmt.CURRENCY;
     v_RT.COMPANY_CODE              := pmt.COMPANY_CODE;
     v_RT.CPARTY_CODE               := pmt.CPARTY_CODE;
     v_RT.YEAR_CALC_TYPE            := pmt.YEAR_CALC_TYPE;

     if pmt.rowid = last_pmt.rowid then
        v_last_trans := 'Y';
     else
        v_last_trans := 'N';
     end if;

     XTR_FPS2_P.CALC_TMM_TAX (v_prncpl_ctype,
                               v_prncpl_method,
                               v_income_ctype,
                               v_income_method,
                               pmt.settle_account_no,
                               v_last_trans,
    			             v_rt
                               );

     update XTR_ROLLOVER_TRANSACTIONS
     set accum_interest_bf = pmt.accum_interest_bf,
     accum_interest_bf_hce = l_accum_int_bf_hce,
     accum_interest_hce = l_accum_int_hce,
     accum_interest = pmt.accum_interest,
     interest = pmt.interest,
     interest_settled = pmt.interest_settled,
     interest_hce = l_int_hce,
     original_amount = pmt.interest,  --Add Interest Override
     TAX_SETTLED_REFERENCE     = v_RT.TAX_SETTLED_REFERENCE,     -- Ilavenil Bug 234413
     TAX_AMOUNT                = v_RT.TAX_AMOUNT,                -- Ilavenil Bug 234413
     TAX_AMOUNT_HCE            = v_RT.TAX_AMOUNT_HCE             -- Ilavenil Bug 234413
     where rowid = pmt.ROWID;

	update XTR_DEAL_DATE_AMOUNTS
        set amount = pmt.interest,
	    hce_amount = l_int_hce
	where deal_number = p_deal_no
	and transaction_number = pmt.transaction_number
	and amount_type = 'INTERST';

	if pmt.settle_term_interest = 'Y' then
	   update XTR_DEAL_DATE_AMOUNTS
	   set amount = pmt.interest_settled,
	       hce_amount = l_int_settle_hce,
	       cashflow_amount = decode(pmt.deal_subtype, 'FUND', (-1), 1) *
				 pmt.interest_settled
	   where deal_number = p_deal_no
	   and transaction_number = pmt.transaction_number
	   and amount_type = 'INTSET';
	end if;

     Fetch TMM_ROLL into pmt;
     End loop;
     Close TMM_ROLL;

  Elsif p_deal_type = 'IRS' then
     Open IRS_ROLL;
     Fetch IRS_ROLL into l_currency, l_balance_out, l_no_of_days,
	   l_year_basis, l_deal_subtype, l_rounding_type;  --Add Interest Override
     If IRS_ROLL%FOUND then
        open RND_YR_IRS;
        fetch RND_YR_IRS into l_round, l_hce_rate;
        close RND_YR_IRS;

        l_hce_rate := nvl(l_hce_rate, 1);
        l_round    := nvl(l_round, 2);

        l_int_rate := p_new_rate;
--Add Interest Override
        l_interest := INTEREST_ROUND(l_balance_out * l_int_rate /100 *
                      l_no_of_days / l_year_basis, l_round, l_rounding_type);
--ORIGINAL---------------------------------------
--        l_interest := round(l_balance_out * l_int_rate /100 *
--                      l_no_of_days / l_year_basis, l_round);
-------------------------------------------------
        l_int_settled := l_interest;
        l_int_hce := round(l_int_settled /l_hce_rate, l_round);
      End if;
      Close IRS_ROLL;

     Update XTR_ROLLOVER_TRANSACTIONS
     set interest_rate = l_int_rate,
	 interest      = l_interest,
	 interest_settled = l_int_settled,
         interest_hce  = l_int_hce,
               original_amount = l_interest  --Add Interest Override
     where deal_number = p_deal_no
     and transaction_number = p_trans_no;

     Update XTR_DEAL_DATE_AMOUNTS
     set transaction_rate = l_int_rate
     where deal_number = p_deal_no
     and transaction_number = p_trans_no;

     Update XTR_DEAL_DATE_AMOUNTS
     set amount = l_interest,
	 hce_amount = l_int_hce,
         cashflow_amount = decode(l_deal_subtype, 'FUND',
			   l_interest * (-1), l_interest)
     where deal_number = p_deal_no
     and transaction_number = p_trans_no
     and amount_type = 'INTSET';
  End if;


End UPDATE_RATE_ONE_TRANSACTION;
---------------------------------------------------------------------------------------------------
PROCEDURE UPDATE_RATE_SEQ_TRANSACTION(p_deal_no     IN NUMBER,
                                  p_trans_no    IN NUMBER,
                                  p_deal_type   IN VARCHAR2,
                                  p_start_date  IN DATE,
                                  p_new_rate    IN NUMBER)IS
-- Add xtr_deals.rounding_type for Interest Override
 cursor TMM_ROLL is
 select r.deal_subtype, r.currency, r.rowid, r.adjusted_balance, r.no_of_days, r.year_basis,
        r.interest, r.settle_term_interest, r.accum_interest_bf, r.accum_interest,
        r.interest_hce, r.interest_settled, r.trans_closeout_no, r.start_date,
        r.maturity_date, r.transaction_number, r.interest_rate, r.principal_action,
  	  r.principal_adjust, r.balance_out_bf, d.rounding_type,
      /**** code below added by Ilavenil for witholding tax project *****/
      r.tax_amount,
      r.tax_code,
      r.tax_settled_reference, r.tax_amount_hce ,
      r.tax_rate,
      r.balance_out,
      d.settle_account_no,
      d.company_code, d.cparty_code, d.year_calc_type
      /**********/
 from XTR_ROLLOVER_TRANSACTIONS_V r,
         XTR_DEALS d
 where r.deal_number = d.deal_no
 and r.deal_type = p_deal_type
 and r.deal_type = 'TMM'
 and r.deal_number = p_deal_no
 and r.start_date >= p_start_date
 order by r.start_date asc, r.maturity_date asc, r.transaction_number asc;

 pmt TMM_ROLL%ROWTYPE;

 cursor LAST_TMM is
 select rowid
 from XTR_ROLLOVER_TRANSACTIONS_V
 where deal_number = p_deal_no
 and status_code = 'CURRENT'
 order by maturity_date desc, start_date desc, transaction_number desc;

 last_pmt LAST_TMM%ROWTYPE;

--Add d.rounding_type for Interest Override
 cursor IRS_ROLL is
 select r.rowid, r.transaction_number, d.currency, r.balance_out,
        r.no_of_days, d.year_basis, d.deal_subtype, d.rounding_type
 from XTR_DEALS d,
      XTR_ROLLOVER_TRANSACTIONS r
 where d.deal_type = p_deal_type
 and d.deal_type = 'IRS'
 and d.deal_no = r.deal_number
 and d.deal_no = p_deal_no
 and r.start_date >= p_start_date;

 pms IRS_ROLL%ROWTYPE;

 cursor RND_YR_TMM is
 select rounding_factor, hce_rate
 from XTR_MASTER_CURRENCIES_V
 where currency = pmt.currency;

 cursor RND_YR_IRS is
 select rounding_factor, hce_rate
 from XTR_MASTER_CURRENCIES_V
 where currency = pms.currency;

 l_interest     NUMBER;
 l_accum_int    NUMBER;
 l_int_settled  NUMBER;
 l_int_hce      NUMBER;
 l_accum_int_hce NUMBER;
 l_accum_int_bf_hce     NUMBER;
 new_accum_int  NUMBER;
 l_round        NUMBER;
 l_hce_rate     NUMBER;
 l_int_settle_hce  NUMBER;
 l_prin_adj     NUMBER;

 v_RT Xtr_Rollover_Transactions_V%Rowtype;
 v_first_time Char(1) := 'Y';
 v_last_trans Varchar2(1) ;
 v_prncpl_ctype Xtr_Tax_Brokerage_Setup.Calc_Type%type;
 v_prncpl_method Xtr_Tax_Brokerage_Setup.tax_settle_method%type;
 v_income_ctype Xtr_Tax_Brokerage_Setup.Calc_Type%type;
 v_income_method Xtr_Tax_Brokerage_Setup.tax_settle_method%type;

Begin
  If p_deal_type = 'TMM' then
	-- Invalid deals
     Update XTR_CONFIRMATION_DETAILS
     set confirmation_validated_by = null,
          confirmation_validated_on = to_date(null)
     where deal_no = p_deal_no;

     open LAST_TMM;
     fetch LAST_TMM INTO last_pmt;
     close LAST_TMM;

     Open TMM_ROLL;
     fetch TMM_ROLL into pmt;
     LOOP
         EXIT when TMM_ROLL%NOTFOUND;

         /******** code below added by Ilavenil for witholding tax project *********/
         If v_first_time = 'Y' then
             XTR_FPS2_P.Get_Settle_Method (null,
                                       v_prncpl_ctype,
                                       v_prncpl_method,
                                       pmt.tax_code,
                                       v_income_ctype,
                                       v_income_method);
             v_first_time := 'N';
         End if;
        /**********/

         open RND_YR_TMM;
         fetch RND_YR_TMM into l_round, l_hce_rate;
         close RND_YR_TMM;

        l_hce_rate := nvl(l_hce_rate, 1);
        l_round    := nvl(l_round, 2);

        if NVL(pmt.PRINCIPAL_ACTION,'@#@') = 'DECRSE' then
  	   l_prin_adj := (-1) * nvl(pmt.PRINCIPAL_ADJUST,0);
 	else
  	   l_prin_adj := nvl(pmt.PRINCIPAL_ADJUST,0);
        end if;

        pmt.ADJUSTED_BALANCE := nvl(pmt.BALANCE_OUT_BF,0) + l_prin_adj;

        pmt.accum_interest_bf := nvl(new_accum_int,pmt.accum_interest_bf);
        if pmt.ROWID=last_pmt.ROWID then

--Add Interest Override
           pmt.interest := INTEREST_ROUND(pmt.balance_out_bf * p_new_rate /100 *
                      pmt.no_of_days / pmt.year_basis, l_round, pmt.rounding_type);
	else
           pmt.interest := INTEREST_ROUND(pmt.adjusted_balance * p_new_rate /100 *
                      pmt.no_of_days / pmt.year_basis, l_round, pmt.rounding_type);
--ORIGINAL--------------------------------------------------
--           pmt.interest := round(pmt.balance_out_bf * p_new_rate /100 *
--                      pmt.no_of_days / pmt.year_basis, l_round);
--	else
--           pmt.interest := round(pmt.adjusted_balance * p_new_rate /100 *
--                      pmt.no_of_days / pmt.year_basis, l_round);
--End of Change-----------------------------------------------
 	end if;

        if pmt.SETTLE_TERM_INTEREST = 'Y' then
           if pmt.trans_closeout_no is null then
              pmt.accum_interest := 0;
              pmt.interest_settled := nvl(pmt.accum_interest_bf,0) +
                                      nvl(pmt.interest,0);
           else
              pmt.accum_interest := nvl(pmt.accum_interest_bf,0) +
                                    nvl(pmt.interest,0) - nvl(pmt.interest_settled,0);
           end if;
        else  -- not settled yet
           if pmt.trans_closeout_no is null then
              pmt.interest_settled := 0;
           end if;
           pmt.accum_interest := nvl(pmt.accum_interest_bf,0) +
                                 nvl(pmt.interest,0) - nvl(pmt.interest_settled,0);
        end if;

        -- Calcuate HCE amounts
        new_accum_int := nvl(pmt.accum_interest,0);
        l_int_hce := round(pmt.interest /l_hce_rate, l_round);
        l_int_settle_hce := round(pmt.interest_settled /l_hce_rate, l_round);
        l_accum_int_hce := round(pmt.accum_interest /l_hce_rate, l_round);
        l_accum_int_bf_hce := round(pmt.accum_interest_bf /l_hce_rate, l_round);

     /******* code below added by Ilavenil *********/
     v_RT.TAX_SETTLED_REFERENCE     := pmt.TAX_SETTLED_REFERENCE;
     v_RT.TAX_RATE                  := pmt.TAX_RATE;
     v_RT.TAX_AMOUNT                := pmt.TAX_AMOUNT;
     v_RT.TAX_AMOUNT_HCE            := pmt.TAX_AMOUNT_HCE;
     v_RT.TAX_CODE                  := pmt.TAX_CODE;

     v_RT.INTEREST_SETTLED          := pmt.INTEREST_SETTLED;
     v_RT.DEAL_NUMBER               := p_DEAL_NO;
     v_RT.TRANSACTION_NUMBER        := pmt.TRANSACTION_NUMBER;
     v_RT.START_DATE                := pmt.START_DATE;
     v_RT.MATURITY_DATE             := pmt.MATURITY_DATE;

     v_RT.CURRENCY                  := pmt.CURRENCY;
     v_RT.COMPANY_CODE              := pmt.COMPANY_CODE;
     v_RT.CPARTY_CODE               := pmt.CPARTY_CODE;
     v_RT.YEAR_CALC_TYPE            := pmt.YEAR_CALC_TYPE;

     if pmt.rowid = last_pmt.rowid then
        v_last_trans := 'Y';
     else
        v_last_trans := 'N';
     end if;

     XTR_FPS2_P.CALC_TMM_TAX (v_prncpl_ctype,
                               v_prncpl_method,
                               v_income_ctype,
                               v_income_method,
                               pmt.settle_account_no,
                               v_last_trans,
    			             v_rt
                               );

        update XTR_ROLLOVER_TRANSACTIONS
        set interest_rate = p_new_rate,
	    accum_interest_bf = pmt.accum_interest_bf,
            accum_interest_bf_hce = l_accum_int_bf_hce,
            accum_interest_hce = l_accum_int_hce,
            accum_interest = pmt.accum_interest,
            interest = pmt.interest,
            interest_settled = pmt.interest_settled,
            interest_hce = l_int_hce,
            original_amount = pmt.interest,  --Add Interest Override
            TAX_SETTLED_REFERENCE     = v_RT.TAX_SETTLED_REFERENCE,     -- Ilavenil Bug 234413
            TAX_AMOUNT                = v_RT.TAX_AMOUNT,                -- Ilavenil Bug 234413
            TAX_AMOUNT_HCE            = v_RT.TAX_AMOUNT_HCE             -- Ilavenil Bug 234413
        where rowid = pmt.ROWID;

        update XTR_DEAL_DATE_AMOUNTS
        set transaction_rate = p_new_rate
        where deal_number = p_deal_no
        and transaction_number = pmt.transaction_number;

        update XTR_DEAL_DATE_AMOUNTS
        set amount = pmt.interest,
            hce_amount = l_int_hce
        where deal_number = p_deal_no
        and transaction_number = pmt.transaction_number
        and amount_type = 'INTERST';

        if pmt.settle_term_interest = 'Y' then
           update XTR_DEAL_DATE_AMOUNTS
           set amount = pmt.interest_settled,
               hce_amount = l_int_settle_hce,
               cashflow_amount = decode(pmt.deal_subtype, 'FUND', (-1), 1) *
                                 pmt.interest_settled
           where deal_number = p_deal_no
           and transaction_number = pmt.transaction_number
           and amount_type = 'INTSET';
        end if;

     Fetch TMM_ROLL into pmt;
     End loop;
     Close TMM_ROLL;

 Elsif p_deal_type = 'IRS' then
     Open IRS_ROLL;
     fetch IRS_ROLL into pms;
     LOOP
         EXIT when IRS_ROLL%NOTFOUND;
         open RND_YR_IRS;
         fetch RND_YR_IRS into l_round, l_hce_rate;
         close RND_YR_IRS;

         l_hce_rate := nvl(l_hce_rate, 1);
         l_round    := nvl(l_round, 2);

--Add Interest Override
         l_interest := INTEREST_ROUND(pms.balance_out * p_new_rate /100 *
                       pms.no_of_days / pms.year_basis, l_round, pms.rounding_type);
--ORIGINAL--------------------------------------------
--         l_interest := round(pms.balance_out * p_new_rate /100 *
--                      pms.no_of_days / pms.year_basis, l_round);
--End of Change ----------------------------------------
         l_int_settled := l_interest;
         l_int_hce := round(l_int_settled /l_hce_rate, l_round);

         Update XTR_ROLLOVER_TRANSACTIONS
         set interest_rate = p_new_rate,
             interest      = l_interest,
             interest_settled = l_int_settled,
             interest_hce  = l_int_hce,
             original_amount = l_interest  --Add Interest Override
	 where rowid = pms.rowid;

         Update XTR_DEAL_DATE_AMOUNTS
         set transaction_rate = p_new_rate
         where deal_number = p_deal_no
         and transaction_number = pms.transaction_number;

         Update XTR_DEAL_DATE_AMOUNTS
         set amount = l_interest,
             hce_amount = l_int_hce,
             cashflow_amount = decode(pms.deal_subtype, 'FUND',
                           l_interest * (-1), l_interest)
        where deal_number = p_deal_no
        and transaction_number = pms.transaction_number
        and amount_type = 'INTSET';

        Fetch IRS_ROLL into pms;
        End loop;
        Close IRS_ROLL;
 End if;


End UPDATE_RATE_SEQ_TRANSACTION;

FUNCTION ROUNDUP(p_amount       NUMBER,
		 p_round_factor NUMBER) RETURN NUMBER IS

l_amount		number;
l_rounded_amount	number;

BEGIN

   l_amount := abs(p_amount);

   l_rounded_amount := Ceil(l_amount*Power(10,p_round_factor))/Power(10,p_round_factor);

   if p_amount < 0 then
	l_rounded_amount := (-1)*l_rounded_amount;
   end if;

   return(l_rounded_amount);

END ROUNDUP;

FUNCTION INTEREST_ROUND
                (p_amount NUMBER,
		 p_round_factor NUMBER,
		 p_rounding_type VARCHAR2
		 ) RETURN NUMBER IS
BEGIN
   IF p_rounding_type='T' THEN
      RETURN (Trunc(p_amount,p_round_factor));
    ELSIF p_rounding_type='U' THEN
      RETURN (roundup(p_amount,p_round_factor));
    ELSE
      RETURN (Round(p_amount,p_round_factor));
   END IF;

END interest_round;

PROCEDURE CURRENCY_CROSS_RATE (p_currency_from IN VARCHAR2,
			       p_currency_to   IN VARCHAR2,
			       p_rate          OUT NOCOPY NUMBER)
IS
  --
  -- This procedure return the conversion rate for
  -- Ineterest Toeralance checks.
  --

  l_ask_price  NUMBER;
  l_bit_price  NUMBER;

  CURSOR usd_cross IS
     SELECT decode(currency_a, p_currency_from ,ask_price,1/ask_price),
       decode(currency_a, p_currency_from ,bid_price,1/bid_price)
     FROM xtr_market_prices
     WHERE ((currency_a= p_currency_from AND currency_b=p_currency_to)
	      OR (currency_a= p_currency_to AND currency_b=p_currency_from))
     AND term_type='S';

  CURSOR other_cross IS
     select
       decode(sr2.currency_a,p_currency_from,sr2.bid_price ,(1/sr2.ask_price)) /
          decode(sr3.currency_a, p_currency_to, sr3.bid_price, (1/sr3.ask_price)),
       decode(sr2.currency_a,p_currency_from,sr2.ask_price, (1/sr2.bid_price)) /
          decode(sr3.currency_a, p_currency_to, sr3.ask_price, (1/sr3.bid_price))
     from
          XTR_MARKET_PRICES sr2,
          XTR_MARKET_PRICES sr3
       where  (sr2.currency_a = 'USD' or sr2.currency_b = 'USD')
       and   (sr3.currency_a = 'USD' or sr3.currency_b = 'USD')
       and   (sr2.currency_a = p_currency_from or sr2.currency_b = p_currency_from)
       and   (sr3.currency_a = p_currency_to or sr3.currency_b= p_currency_to)
       and    sr2.term_type = 'S'
       and    sr3.term_type = 'S';

  BEGIN

     IF p_currency_from ='USD' OR p_currency_to='USD' THEN
	OPEN usd_cross;
	FETCH usd_cross INTO l_ask_price, l_bit_price;
	CLOSE usd_cross;
     ELSE
	OPEN other_cross;
	FETCH other_cross INTO l_ask_price, l_bit_price;
	CLOSE other_cross;
     END IF;

     p_rate := (l_ask_price + l_bit_price) /2;


END CURRENCY_CROSS_RATE;


PROCEDURE GET_SETTLE_METHOD (p_prncpl_tax     IN VARCHAR2,
                             p_prncpl_ctype   OUT NOCOPY VARCHAR2,
                             p_prncpl_method  OUT NOCOPY VARCHAR2,
                             p_income_tax     IN VARCHAR2,
                             p_income_ctype   OUT NOCOPY VARCHAR2,
                             p_income_method  OUT NOCOPY VARCHAR2) IS

   CURSOR settle_method (l_tax_code  VARCHAR2) IS
   SELECT calc_type,
          tax_settle_method
   FROM   XTR_TAX_BROKERAGE_SETUP
   WHERE  reference_code = l_tax_code;

BEGIN

   p_prncpl_ctype  := null;
   p_prncpl_method := null;
   p_income_ctype  := null;
   p_income_method := null;

   if p_prncpl_tax is not null then
      OPEN  settle_method (p_prncpl_tax);
      FETCH settle_method INTO p_prncpl_ctype, p_prncpl_method;
      CLOSE settle_method;
   end if;

   if p_income_tax is not null then
      OPEN  settle_method (p_income_tax);
      FETCH settle_method INTO p_income_ctype, p_income_method;
      CLOSE settle_method;
   end if;

END GET_SETTLE_METHOD;

PROCEDURE CALC_TMM_TAX (p_prncpl_ctype  IN VARCHAR2,
                        p_prncpl_method IN VARCHAR2,
                        p_income_ctype  IN VARCHAR2,
                        p_income_method IN VARCHAR2,
                        p_settle_acct   IN VARCHAR2,
                        p_last_tran     IN VARCHAR2,
                        p_RT            IN OUT NOCOPY  XTR_ROLLOVER_TRANSACTIONS_V%ROWTYPE) IS

   l_hce_rate          NUMBER;
   l_hce_rounding      NUMBER;
   l_orig_prncpl_amt   NUMBER;
   l_orig_income_amt   NUMBER;
   l_prncpl_amt_hce    NUMBER;
   l_income_amt_hce    NUMBER;
   l_prn_a_amt         NUMBER := 0;
   l_num_days          NUMBER;
   l_dummy_num         NUMBER;
   l_yr_basis          NUMBER;
   l_err_code          NUMBER;
   l_level             VARCHAR2(20);
   l_p_tax_date        DATE;
   l_i_tax_date        DATE;

   --------------------------------------------
   -- Get BALANCE_OUT for each transaction
   --------------------------------------------
   cursor RT_BAL_OUT IS
   select START_DATE,
          MATURITY_DATE,
          BALANCE_OUT
   from   XTR_ROLLOVER_TRANSACTIONS
   where  deal_number = p_RT.deal_number
   order by start_date, maturity_date, transaction_number;

   --------------------------------------------
   -- Get rounding currency and hce_rate
   --------------------------------------------
   cursor ROUND_FACTOR (l_ccy VARCHAR2) is
   select hce_rate
   from   XTR_MASTER_CURRENCIES_V
   where  currency = l_ccy;

   --------------------------------------------
   -- Get home rounding curency
   --------------------------------------------
   cursor HCE_ROUND_FACTOR is
   select a.rounding_factor
   from   XTR_MASTER_CURRENCIES_V a,
          XTR_PRO_PARAM           b
   where  b.param_name = 'SYSTEM_FUNCTIONAL_CCY'
   and    a.currency   =  param_value;

   one_step_rec        ONE_STEP_REC_TYPE;


BEGIN

   l_orig_prncpl_amt := nvl(p_RT.PRINCIPAL_TAX_AMOUNT,0);
   l_orig_income_amt := nvl(p_RT.TAX_AMOUNT,0);

   if p_RT.START_DATE is not null and p_RT.CURRENCY is not null and
     (p_RT.PRINCIPAL_TAX_CODE is not null or p_RT.TAX_CODE is not null) then

      open  ROUND_FACTOR(p_RT.currency);
      fetch ROUND_FACTOR into l_hce_rate;
      close ROUND_FACTOR;

      open  HCE_ROUND_FACTOR;
      fetch HCE_ROUND_FACTOR into l_hce_rounding;
      close HCE_ROUND_FACTOR;

      IF ((p_prncpl_ctype = 'PRN_F'     and p_RT.transaction_number = 1) or
          (p_prncpl_ctype = 'MAT_F'     and p_last_tran = 'Y') or
          (p_prncpl_ctype = 'PRN_INC_F' and p_RT.principal_action = 'INCRSE') or
          (p_prncpl_ctype = 'PRN_DEC_F' and p_RT.principal_action = 'DECRSE')) and
          p_RT.PRINCIPAL_TAX_CODE is not null and p_RT.PRINCIPAL_TAX_RATE is not null THEN

          if p_prncpl_ctype = 'MAT_F' then
             l_p_tax_date := p_RT.maturity_date;
          else
             l_p_tax_date := p_RT.start_date;
          end if;

          XTR_FPS1_P.CALC_TAX_AMOUNT('TMM',                      -- IN deal type
                                     l_p_tax_date,               -- IN deal date
                                     p_RT.PRINCIPAL_TAX_CODE,    -- IN principal tax schedule
                                     null,                       -- IN income tax schedule
                                     p_RT.CURRENCY,              -- IN currency (buy ccy for FX)
                                     null,                       -- IN sell ccy if FX
                                     null,                       -- IN year basis
                                     null,                       -- IN number of days
                                     p_RT.PRINCIPAL_ADJUST,      -- IN principal tax amount
                                     p_RT.PRINCIPAL_TAX_RATE ,   -- IN/OUT principal tax rate
                                     0,                          -- IN income tax amount
                                     l_dummy_num ,               -- IN/OUT income tax rate
                                     p_RT.PRINCIPAL_TAX_AMOUNT,  -- IN/OUT calculated principal tax
                                     l_dummy_num,                -- IN/OUT calculated income tax
                                     l_err_code,                 -- OUT
                                     l_level);                   -- OUT

      END IF;


      IF  p_prncpl_ctype = 'PRN_A'  and p_last_tran = 'Y' and
          p_RT.PRINCIPAL_TAX_CODE is not null and p_RT.PRINCIPAL_TAX_RATE is not null then

          p_RT.PRINCIPAL_TAX_AMOUNT := 0;

          FOR PRN_A in RT_BAL_OUT LOOP

             l_p_tax_date := PRN_A.MATURITY_DATE;
             l_prn_a_amt  := 0;

             XTR_CALC_P.CALC_DAYS_RUN(PRN_A.START_DATE,
                                      PRN_A.MATURITY_DATE,
                                      p_RT.YEAR_CALC_TYPE,
                                      l_num_days,
                                      l_yr_basis);

             XTR_FPS1_P.CALC_TAX_AMOUNT('TMM',                      -- IN deal type
                                        l_p_tax_date,               -- IN deal date
                                        p_RT.PRINCIPAL_TAX_CODE,    -- IN principal tax schedule
                                        null,                       -- IN income tax schedule
                                        p_RT.CURRENCY,              -- IN currency (buy ccy for FX)
                                        null,                       -- IN sell ccy if FX
                                        l_yr_basis,                 -- IN year basis
                                        l_num_days,                 -- IN number of days
                                        PRN_A.BALANCE_OUT,          -- IN principal tax amount
                                        p_RT.PRINCIPAL_TAX_RATE ,   -- IN/OUT principal tax rate
                                        0,                          -- IN income tax amount
                                        l_dummy_num,                -- IN/OUT income tax rate
                                        l_prn_a_amt,                -- IN/OUT calculated principal tax
                                        l_dummy_num,                -- IN/OUT calculated income tax
                                        l_err_code,                 -- OUT
                                        l_level);                   -- OUT

             p_RT.PRINCIPAL_TAX_AMOUNT := p_RT.PRINCIPAL_TAX_AMOUNT  + nvl(l_prn_a_amt,0);

          END LOOP;

      END IF;

      IF p_income_ctype = 'INS_F' and p_RT.TAX_CODE is not null and
         p_RT.TAX_RATE is not null THEN

         l_i_tax_date := p_RT.SETTLE_DATE;  -- Interest Settlement Date -- bug 3018106

         XTR_FPS1_P.CALC_TAX_AMOUNT('TMM',                      -- IN deal type
                                     l_i_tax_date,               -- IN deal date
                                     null,                       -- IN principal tax schedule
                                     p_RT.TAX_CODE,              -- IN income tax schedule
                                     p_RT.CURRENCY,              -- IN currency (buy ccy for FX)
                                     null,                       -- IN sell ccy if FX
                                     null,                       -- IN year basis
                                     null,                       -- IN number of days
                                     null,                       -- IN principal tax amount
                                     l_dummy_num ,               -- IN/OUT principal tax rate
                                     p_RT.INTEREST_SETTLED,      -- IN income tax amount
                                     p_RT.TAX_RATE,              -- IN/OUT income tax rate
                                     l_dummy_num,                -- IN/OUT calculated principal tax
                                     p_RT.TAX_AMOUNT,            -- IN/OUT calculated income tax
                                     l_err_code,                 -- OUT
                                     l_level);                   -- OUT

         p_RT.TAX_AMOUNT_HCE := round(nvl(p_RT.TAX_AMOUNT,0)/l_hce_rate,nvl(l_hce_rounding,2));

      END IF;

      l_prncpl_amt_hce := round(nvl(p_RT.PRINCIPAL_TAX_AMOUNT,0)/l_hce_rate,nvl(l_hce_rounding,2));
      l_income_amt_hce := nvl(p_RT.TAX_AMOUNT_HCE,0);

      -----------------------------------------------------------------------
      -- Delete tax related EXP and DDA  -- Bug 2506786
      -----------------------------------------------------------------------
      if ((p_RT.PRINCIPAL_TAX_SETTLED_REF is not null and
           l_orig_prncpl_amt <> nvl(p_RT.PRINCIPAL_TAX_AMOUNT,0)) or
          (p_RT.TAX_SETTLED_REFERENCE is not null)) then
         DELETE_TAX_EXPOSURE(p_RT.DEAL_NUMBER, p_RT.TRANSACTION_NUMBER);
         p_RT.PRINCIPAL_TAX_SETTLED_REF := null;
         p_RT.TAX_SETTLED_REFERENCE     := null;
      end if;

      ---------------------------------------------------------------------
      -- One Step Method - Generate EXP and DDA
      ---------------------------------------------------------------------
      if p_prncpl_method = 'OSG' and p_RT.PRINCIPAL_TAX_SETTLED_REF is null and
         l_orig_prncpl_amt <> nvl(p_RT.PRINCIPAL_TAX_AMOUNT,0) then
         one_step_rec.p_source             := 'TAX';
         one_step_rec.p_schedule_code      := p_RT.PRINCIPAL_TAX_CODE;
         one_step_rec.p_currency           := p_RT.CURRENCY;
         one_step_rec.p_amount             := p_RT.PRINCIPAL_TAX_AMOUNT;
         one_step_rec.p_settlement_date    := l_p_tax_date;
         one_step_rec.p_settlement_account := p_settle_acct;
         one_step_rec.p_company_code       := p_RT.COMPANY_CODE;
         one_step_rec.p_cparty_code        := p_RT.CPARTY_CODE;

         CALC_TMM_ONE_STEP ('P', p_RT.deal_number,
                                 p_RT.transaction_number,
                                 l_prncpl_amt_hce,
                                 p_RT.PRINCIPAL_TAX_SETTLED_REF,
                                 p_prncpl_method,
                                 null,
                                 null,
                                 one_step_rec);

         p_RT.PRINCIPAL_TAX_SETTLED_REF := one_step_rec.p_exp_number;

      end if;

      if p_income_method = 'OSG' and p_RT.TAX_SETTLED_REFERENCE is null  then
      --    l_orig_income_amt <> nvl(p_RT.TAX_AMOUNT,0) then   -- bug 3018106

         one_step_rec.p_source             := 'TAX';
         one_step_rec.p_schedule_code      := p_RT.TAX_CODE;
         one_step_rec.p_currency           := p_RT.CURRENCY;
         one_step_rec.p_amount             := p_RT.TAX_AMOUNT;
         one_step_rec.p_settlement_date    := l_i_tax_date;
         one_step_rec.p_settlement_account := p_settle_acct;
         one_step_rec.p_company_code       := p_RT.COMPANY_CODE;
         one_step_rec.p_cparty_code        := p_RT.CPARTY_CODE;

         CALC_TMM_ONE_STEP('I', p_RT.deal_number,
                                p_RT.transaction_number,
                                l_income_amt_hce,
                                null,
                                null,
                                p_RT.TAX_SETTLED_REFERENCE,
                                p_income_method,
                                one_step_rec);

         p_RT.TAX_SETTLED_REFERENCE := one_step_rec.p_exp_number;

      end if;

   end if;

END CALC_TMM_TAX;


PROCEDURE CALC_TMM_ONE_STEP (p_tax_type      IN VARCHAR2,
                             p_deal_no       IN NUMBER,
                             p_tran_no       IN NUMBER,
                             p_amt_hce       IN NUMBER,
                             p_prncpl_ref    IN NUMBER,
                             p_prncpl_method IN VARCHAR2,
                             p_income_ref    IN NUMBER,
                             p_income_method IN VARCHAR2,
                             p_one_step      IN OUT NOCOPY ONE_STEP_REC_TYPE) IS

BEGIN

   p_one_step.p_exp_number := null;

   --------------------------------------------------------------------
   -- Principal Tax
   --------------------------------------------------------------------
   if p_tax_type = 'P' then

      if p_prncpl_method = 'OSG' and nvl(p_one_step.p_amount,0) <> 0 then

            ONE_STEP_SETTLEMENT(p_one_step);

      end if;

      ---------------------------------------------------------------------------
   /* The following logic handles update for OSG only if it is a 1-1 relationship
      ---------------------------------------------------------------------------
      if p_prncpl_ref is not null and p_prncpl_method <> 'OSG' then

         ---------------------------------------
         -- Replace this with DELETE_TAX_EXPOSURE
         ---------------------------------------
         delete XTR_EXPOSURE_TRANSACTIONS
         where  TRANSACTION_NUMBER = p_prncpl_ref;

         delete XTR_DEAL_DATE_AMOUNTS
         where  DEAL_TYPE = 'EXP'
         and    TRANSACTION_NUMBER = p_prncpl_ref;

      end if;

      if p_prncpl_method = 'OSG' then

         if p_prncpl_ref is null and nvl(p_one_step.p_amount,0) <> 0 then

            ONE_STEP_SETTLEMENT(p_one_step);

         elsif p_prncpl_ref is not null then

            if nvl(p_one_step.p_amount,0) = 0 then

               delete XTR_EXPOSURE_TRANSACTIONS
               where  TRANSACTION_NUMBER = p_prncpl_ref;

               delete XTR_DEAL_DATE_AMOUNTS
               where  DEAL_TYPE = 'EXP'
               and    TRANSACTION_NUMBER = p_prncpl_ref;

               p_one_step.p_exp_number := null;

            else

               update XTR_EXPOSURE_TRANSACTIONS
               set    AMOUNT     = abs(nvl(p_one_step.p_amount,0)),
                      AMOUNT_HCE = abs(nvl(p_amt_hce,0)),
                      VALUE_DATE = p_one_step.p_settlement_date
               where  TRANSACTION_NUMBER = p_prncpl_ref;

               update XTR_DEAL_DATE_AMOUNTS
               set    AMOUNT          = abs(p_one_step.p_amount),
                      HCE_AMOUNT      = abs(p_amt_hce),
                      AMOUNT_DATE     = p_one_step.p_settlement_date,
                      CASHFLOW_AMOUNT = decode(ACTION_CODE,'PAY',-1,1) * abs(p_one_step.p_amount)
               where  DEAL_TYPE       = 'EXP'
               and    TRANSACTION_NUMBER = p_prncpl_ref;

               p_one_step.p_exp_number := p_prncpl_ref;

            end if;

         end if;

      end if;
   */

   --------------------------------------------------------------------
   -- Income Tax
   --------------------------------------------------------------------
   elsif p_tax_type = 'I' then

      if p_income_method = 'OSG' and nvl(p_one_step.p_amount,0) <> 0 then

            ONE_STEP_SETTLEMENT(p_one_step);

      end if;

      ---------------------------------------------------------------------------
   /* The following logic handles update for OSG only if it is a 1-1 relationship
      ---------------------------------------------------------------------------
      if p_income_ref is not null and p_income_method <> 'OSG' then

         ---------------------------------------
         -- Replace this with Jeremy's procedure
         ---------------------------------------
         delete XTR_EXPOSURE_TRANSACTIONS
         where  TRANSACTION_NUMBER = p_income_ref;

         delete XTR_DEAL_DATE_AMOUNTS
         where  DEAL_TYPE = 'EXP'
         and    TRANSACTION_NUMBER = p_income_ref;

      end if;

      if p_income_method = 'OSG' then

         if p_income_ref is null and nvl(p_one_step.p_amount,0) <> 0 then

            ONE_STEP_SETTLEMENT(p_one_step);

         elsif p_income_ref is not null then

            if nvl(p_one_step.p_amount,0) = 0 then

               delete XTR_EXPOSURE_TRANSACTIONS
               where  TRANSACTION_NUMBER = p_income_ref;

               delete XTR_DEAL_DATE_AMOUNTS
               where  DEAL_TYPE = 'EXP'
               and    TRANSACTION_NUMBER = p_income_ref;

               p_one_step.p_exp_number := null;

            else

               update XTR_EXPOSURE_TRANSACTIONS
               set    AMOUNT     = abs(nvl(p_one_step.p_amount,0)),
                      AMOUNT_HCE = abs(nvl(p_amt_hce,0)),
                      VALUE_DATE = p_one_step.p_settlement_date
               where  TRANSACTION_NUMBER = p_income_ref;

               update XTR_DEAL_DATE_AMOUNTS
               set    AMOUNT          = abs(p_one_step.p_amount),
                      HCE_AMOUNT      = abs(p_amt_hce),
                      AMOUNT_DATE     = p_one_step.p_settlement_date,
                      CASHFLOW_AMOUNT = decode(ACTION_CODE,'PAY',-1,1) * abs(p_one_step.p_amount)
               where  DEAL_TYPE       = 'EXP'
               and    TRANSACTION_NUMBER = p_income_ref;

               p_one_step.p_exp_number := p_income_ref;

            end if;

         end if;

      end if;
   */

   end if;

END CALC_TMM_ONE_STEP;


-- This procedure removes exps and ddas corresponding to a deal_no and
-- transaction number.  It also updates other deals that may refer to the
-- same exp to set their tax ref to null.  It does not commit.
PROCEDURE DELETE_TAX_EXPOSURE(p_deal_no     IN NUMBER,
                         p_trans_no    IN NUMBER)

IS
  -- The following 2 cursors are used if given transaction number
  cursor t_rollover_deal_exposures is
    select a.tax_settled_reference
    from xtr_rollover_transactions a
    where a.deal_number = p_deal_no and
	  a.tax_settled_reference is not null and
          a.transaction_number = p_trans_no;

  cursor t_rollover_deal_exposures_p is
    select a.principal_tax_settled_ref
    from xtr_rollover_transactions a
    where a.deal_number= p_deal_no and
	  a.principal_tax_settled_ref is not null and
          a.transaction_number = p_trans_no;

  -- The following 2 cursor are used if not give a trasaction number
  cursor rollover_deal_exposures is
    select a.tax_settled_reference
    from xtr_rollover_transactions a
    where a.deal_number = p_deal_no and
	  a.tax_settled_reference is not null;

  cursor rollover_deal_exposures_p is
    select a.principal_tax_settled_ref
    from xtr_rollover_transactions a
    where a.deal_number= p_deal_no and
	  a.principal_tax_settled_ref is not null;

  cursor xtr_deals is
    select a.tax_settled_reference
    from xtr_deals a where a.deal_no = p_deal_no;

  --bug 2727920
  cursor xtr_deals_int is
    select a.income_tax_settled_ref
    from xtr_deals a where a.deal_no = p_deal_no;

BEGIN


  --It transaction number is null then all deals in both the deals table
  -- and rollover table have their tax_exps deleted.
  if p_trans_no is null then

    for deal_record in xtr_deals LOOP
      DELETE_TAX_EXP_AND_UPDATE(deal_record.tax_settled_reference);
    END LOOP;

    for deal_record_int in xtr_deals_int LOOP
      DELETE_TAX_EXP_AND_UPDATE(deal_record_int.income_tax_settled_ref);
    END LOOP;

    for roll_record in  rollover_deal_exposures LOOP
      DELETE_TAX_EXP_AND_UPDATE(roll_record.tax_settled_reference);
    END LOOP;

    for roll_record_p in  rollover_deal_exposures_p LOOP
      DELETE_TAX_EXP_AND_UPDATE(roll_record_p.principal_tax_settled_ref);
    END LOOP;

  -- If a transaction number is given only tax_exps related to that
  -- transaction are deleted.
  else
    for trans_roll_record in  t_rollover_deal_exposures LOOP
      DELETE_TAX_EXP_AND_UPDATE(trans_roll_record.tax_settled_reference);
    END LOOP;

    for trans_roll_record_p in  t_rollover_deal_exposures_p LOOP
      DELETE_TAX_EXP_AND_UPDATE(trans_roll_record_p.principal_tax_settled_ref);
    END LOOP;

  end if;

END DELETE_TAX_EXPOSURE;


--Procedure removes exp and dda given a tax reference number.  It also updates
-- any deals with this reference number with a reference number of null.
-- It does not commit.
PROCEDURE DELETE_TAX_EXP_AND_UPDATE(p_tax_settle_no IN NUMBER)
IS

BEGIN

if p_tax_settle_no is not null then
	delete from XTR_EXPOSURE_TRANSACTIONS
  	  where TRANSACTION_NUMBER = p_tax_settle_no;

	delete from XTR_DEAL_DATE_AMOUNTS_V
  	  where DEAL_TYPE = 'EXP'
  	  and deal_number = 0
  	  and TRANSACTION_NUMBER = p_tax_settle_no;

	update XTR_ROLLOVER_TRANSACTIONS
 	  set tax_settled_reference = null
 	  where tax_settled_reference = p_tax_settle_no;

	update XTR_ROLLOVER_TRANSACTIONS
 	  set principal_tax_settled_ref = null
 	  where principal_tax_settled_ref = p_tax_settle_no;

	update XTR_DEALS
 	  set tax_settled_reference = null
 	  where tax_settled_reference = p_tax_settle_no;

	update XTR_DEALS
 	  set income_tax_settled_ref = null
 	  where income_tax_settled_ref = p_tax_settle_no;

END IF;


END DELETE_TAX_EXP_AND_UPDATE;



--Bug 2804548
--This procedure will update the Tax Entries in XTR_DEAL_DATE_AMOUNT
--for One Step and Two Step Settlement Method.
--p_amount = Old Tax Amount - New Tax Amount
--p_exp_number = Tax Settled Reference Number
PROCEDURE UPDATE_TAX_DDA (p_exp_number NUMBER,
			p_amount NUMBER) IS
  cursor get_dda_cashflow is
    select cashflow_amount
    from xtr_deal_date_amounts_v
    where transaction_number=p_exp_number
    and deal_type='EXP'
    and deal_number=0;
  v_cashflow NUMBER;
BEGIN
  open get_dda_cashflow;
  fetch get_dda_cashflow into v_cashflow;
  close get_dda_cashflow;
  if v_cashflow=0 then
  --need to update with ADDition since the DDA cashflow_amount for TAX
  --is always negative
    update xtr_deal_date_amounts_v
      set amount=amount-nvl(p_amount,0)
      where transaction_number=p_exp_number
      and deal_type='EXP'
      and deal_number=0;
  else
    update xtr_deal_date_amounts_v
      set amount=amount-nvl(p_amount,0),
      cashflow_amount=cashflow_amount+nvl(p_amount,0)
      where transaction_number=p_exp_number
      and deal_type='EXP'
      and deal_number=0;
  end if;
END UPDATE_TAX_DDA;



--Bug 2804548
--This procedure will update the Tax Entries in XTR_EXPOSURE_TRANSACTIONS
--for One Step and Two Step Settlement Method.
--p_amount = Old Tax Amount - New Tax Amount
--p_exp_number = Tax Settled Reference Number
PROCEDURE UPDATE_TAX_EXP (p_exp_number NUMBER,
			p_amount NUMBER) IS

BEGIN
  update xtr_exposure_transactions
    set amount=amount-nvl(p_amount,0)
    where transaction_number=p_exp_number;
END update_tax_exp;


end XTR_FPS2_P;

/
