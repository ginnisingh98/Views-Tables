--------------------------------------------------------
--  DDL for Package Body XTR_FPS3_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_FPS3_P" as
/* $Header: xtrfps3b.pls 120.8 2005/06/29 07:52:08 badiredd ship $ */
----------------------------------------------------------------------------------------------------------------
--   Procedure to validate foreign key value/query for deal
--  subtype entered
PROCEDURE CHK_DEAL_SUBTYPE (l_deal_type       IN VARCHAR2,
                            l_deal_subtype    IN VARCHAR2,
                            l_subtype_name    IN OUT NOCOPY VARCHAR2,
                            l_limit_weighting IN OUT NOCOPY NUMBER,
                            l_tolerance       IN OUT NOCOPY NUMBER,
                            l_err_code        OUT NOCOPY NUMBER,
                            l_level           OUT NOCOPY VARCHAR2) is
--
--  Since we change NAME's length 35 to 80 so we return NAME as NULL
--- to avoid truncation error
cursor C_DS is
  select NULL NAME,LIMIT_WEIGHTING,TOLERANCE
   from XTR_DEAL_SUBTYPES
   where DEAL_TYPE = l_deal_type
   and DEAL_SUBTYPE = l_deal_subtype;
--
begin
 if (l_deal_type is NOT NULL and l_deal_subtype is NOT NULL) then
  open C_DS;
   fetch C_DS INTO l_subtype_name,l_limit_weighting,l_tolerance;
  if C_DS%NOTFOUND then
    l_err_code := 701; l_level := 'E';--This deal subtype does not exist
  end if;
  close C_DS;
 end if;
end CHK_DEAL_SUBTYPE;

----------------------------------------------------------------------------------------------------------------
--   Procedure to import holidays from GL
PROCEDURE IMPORT_GL_HOLIDAYS(p_calendar_in     IN gl_transaction_calendar.name%TYPE,
                             p_currency_in     IN xtr_holidays.currency%TYPE) IS

  v_calendar         gl_transaction_calendar%ROWTYPE;
  v_holiday_seq      xtr_holidays.hol_seq%TYPE;
  v_nls_adjust       NUMBER;

  cursor get_calendar_id(p_calendar_name gl_transaction_calendar.name%TYPE) is
    select *
      from gl_transaction_calendar
     where name=p_calendar_name;

  cursor get_gl_holidays(p_calendar   gl_transaction_calendar%ROWTYPE,
                         p_currency   xtr_holidays.currency%TYPE,
                         p_sun        NUMBER,
                         p_mon        NUMBER,
                         p_tue        NUMBER,
                         p_wed        NUMBER,
                         p_thu        NUMBER,
                         p_fri        NUMBER,
                         p_sat        NUMBER
                        ) is
    select transaction_date
      from gl_transaction_dates
     where transaction_calendar_id = p_calendar.transaction_calendar_id
       and business_day_flag = 'N'
        -- The following code converts to an american week where Sun=1 to match GL calendar setup
       and 'Y'=decode(((to_char(transaction_date,'D'))-1),
                      p_sun,p_calendar.sun_business_day_flag,
                      p_mon,p_calendar.mon_business_day_flag,
                      p_tue,p_calendar.tue_business_day_flag,
                      p_wed,p_calendar.wed_business_day_flag,
                      p_thu,p_calendar.thu_business_day_flag,
                      p_fri,p_calendar.fri_business_day_flag,
                      p_sat,p_calendar.sat_business_day_flag)
       and not exists (
           select holiday_date
             from xtr_holidays
            where currency=p_currency
              and holiday_date=transaction_date);

BEGIN
  if ((p_calendar_in is not null) and (p_currency_in is not null)) then
    open get_calendar_id(p_calendar_in);
    fetch get_calendar_id into v_calendar;
    close get_calendar_id;

    if (v_calendar.transaction_calendar_id is not null) then
      select XTR_HOLIDAYS_S.nextval
        into v_holiday_seq
        from dual;

      if (v_holiday_seq is null) then
        v_holiday_seq:=1;
      end if;

      -- 01-jan-1995 is Sunday, we need to set up an adjustment value for NLS issues
      v_nls_adjust:=(to_char(to_date('01/01/1995','MM/DD/YYYY'),'D')-1);

      for gl_holiday in get_gl_holidays(v_calendar,
                                        p_currency_in,
                                        (0+v_nls_adjust) mod 7,
                                        (1+v_nls_adjust) mod 7,
                                        (2+v_nls_adjust) mod 7,
                                        (3+v_nls_adjust) mod 7,
                                        (4+v_nls_adjust) mod 7,
                                        (5+v_nls_adjust) mod 7,
                                        (6+v_nls_adjust) mod 7
                                       ) loop
        insert into xtr_holidays(
                   comments,
                   currency,
                   day_desc,
                   holiday_date,
                   hol_seq)
            values (
                   'IG Imported Holiday',
                   p_currency_in,
                   gl_holiday.transaction_date,
                   gl_holiday.transaction_date,
                   v_holiday_seq);
      end loop;
    end if;
  end if;

END IMPORT_GL_HOLIDAYS;






----------------------------------------------------------------------------------------------------------------
--   Procedure to check to if Date is a Holiday or a Week End.
PROCEDURE CHK_HOLIDAY (in_date    IN DATE,
                       l_currency IN VARCHAR2,
                       l_err_code OUT NOCOPY NUMBER,
                       l_level    OUT NOCOPY VARCHAR2) is
--
 v_dummy_count          number;
 v_dummy_char           varchar2(1);
 v_gl_calendar_name     xtr_master_currencies_v.gl_calendar_name%TYPE;
 v_nls_adjust           number;
 v_bHasGLCalendar       boolean := false;

 cursor HOL is
  select count(*)
   from XTR_HOLIDAYS
   where HOLIDAY_DATE =in_date
   and CURRENCY = l_currency;

  cursor get_calendar_name(p_currency xtr_master_currencies_v.currency%TYPE) is
    select gl_calendar_name
      from xtr_master_currencies
     where currency=p_currency
       and authorised='Y';

  cursor get_gl_weekend(p_calendar_name   gl_transaction_calendar.name%TYPE,
                        p_date       DATE,
                        p_sun        NUMBER,
                        p_mon        NUMBER,
                        p_tue        NUMBER,
                        p_wed        NUMBER,
                        p_thu        NUMBER,
                        p_fri        NUMBER,
                        p_sat        NUMBER
                       ) is
    select decode(((to_char(p_date,'D'))-1),
                      p_sun,sun_business_day_flag,
                      p_mon,mon_business_day_flag,
                      p_tue,tue_business_day_flag,
                      p_wed,wed_business_day_flag,
                      p_thu,thu_business_day_flag,
                      p_fri,fri_business_day_flag,
                      p_sat,sat_business_day_flag)
      from gl_transaction_calendar
     where name = p_calendar_name;

--
begin
if in_date is NOT NULL then

  open get_calendar_name(l_currency);
  fetch get_calendar_name into v_gl_calendar_name;
  close get_calendar_name;

  if (v_gl_calendar_name is not null) then

      -- Jan 1st 1995 is a Sunday, this is to fix NLS weekday starts

      v_nls_adjust:=(to_char(to_date('01/01/1995','MM/DD/YYYY'),'D')-1);

      open get_gl_weekend(v_gl_calendar_name,
                         in_date,
                         (0+v_nls_adjust) mod 7,
                         (1+v_nls_adjust) mod 7,
                         (2+v_nls_adjust) mod 7,
                         (3+v_nls_adjust) mod 7,
                         (4+v_nls_adjust) mod 7,
                         (5+v_nls_adjust) mod 7,
                         (6+v_nls_adjust) mod 7
                        );
      fetch get_gl_weekend into v_dummy_char;
      close get_gl_weekend;
      if (v_dummy_char is not null) then
        v_bHasGLCalendar:=true;
      end if;
      if (v_dummy_char='N') then --dummy char is Y for weekday, N for weekend
        l_err_code := 128;
        l_level := 'W';--This date is not a week day
      end if;
  end if;

  if (v_bHasGLCalendar = false) then
    -- force into english where the weekend starts with S
    if ((substrb(
          to_char(in_date,
            'Day',
            'nls_date_language=American'),
          1,
          1)
       )='S') then
    --Changed because NLS settings might dictate Monday to be day 1
    --if not (to_char(in_date,'D') between 2 and 6) then --default to weekends when no calendar
      l_err_code := 128;
      l_level := 'W';--This date is not a week day
    end if;
  end if;

  if (l_level is null) then
    open HOL;
    fetch HOL into v_dummy_count;
    close HOL;
    if (v_dummy_count>0) then
      l_err_code := 126;
      l_level := 'W';--This date is a holiday for this currency
    end if;
  end if;
end if;
end CHK_HOLIDAY;
----------------------------------------------------------------------------------------------------------------
--   Procedure to check that no portfolios already exist for
--  this deal because only one is allowed per deal.
PROCEDURE CHK_NO_PORTFOLIOS (l_company_code IN VARCHAR2,
                             l_deal_number  IN NUMBER,
                             l_err_code     OUT NOCOPY NUMBER,
                             l_level        OUT NOCOPY VARCHAR2) is
 cursor PORT_NOS is
  select 1
   from  xtr_portfolio_deal_amounts
   where company_code = l_company_code
   and   deal_number  = l_deal_number;
--
 v_dummy        number(1);
begin
 open PORT_NOS;
 fetch PORT_NOS INTO v_dummy;
 if PORT_NOS%FOUND then
    close PORT_NOS;
    l_err_code := 240; l_level := 'E';--Only one portfolio may be created for each deal
 else
    close PORT_NOS;
 end if;
end CHK_NO_PORTFOLIOS;
----------------------------------------------------------------------------------------------------------------
--   Procedure to validate the portfolio code.
PROCEDURE CHK_PORT_CODE (l_portfolio_code IN VARCHAR2,
                         l_company_code   IN VARCHAR2,
                         l_portfolio_name IN OUT NOCOPY VARCHAR2,
                         l_err_code       OUT NOCOPY NUMBER,
                         l_level          OUT NOCOPY VARCHAR2) is
--
 cursor PORTFOLIO is
  select NULL NAME
   from  XTR_PORTFOLIOS
   where PORTFOLIO = l_portfolio_code
   and   COMPANY_CODE = l_company_code;
--
begin
  if (l_company_code is NOT NULL and l_portfolio_code is NOT NULL) then
    open PORTFOLIO;
     fetch PORTFOLIO INTO l_portfolio_name;
    if PORTFOLIO%NOTFOUND then
      l_err_code := 701; l_level := 'E';--This portfolio does not exist
     end if;
    close PORTFOLIO;
  end if;
end CHK_PORT_CODE;
----------------------------------------------------------------------------------------------------------------
--   Procedure to check constraint for portfolio nos.
PROCEDURE CHK_PORT_CONST ( l_portfolio_code IN VARCHAR2,
                           l_deal_number    IN NUMBER,
                           l_err_code       OUT NOCOPY NUMBER,
                           l_level          OUT NOCOPY VARCHAR2) is
--
 cursor PORTFOLIO_NOS is
  select  1
   from   XTR_PORTFOLIO_DEAL_AMOUNTS
   where  DEAL_NUMBER = l_deal_number
   and    PORTFOLIO_CODE = l_portfolio_code;
--
 v_dummy          number(1);
begin
 open PORTFOLIO_NOS;
 fetch PORTFOLIO_NOS INTO v_dummy;
 if PORTFOLIO_NOS%FOUND then
   close PORTFOLIO_NOS;
   l_err_code := 212; l_level := 'E';--Row exists already with same Deal No,Portfolio
 else
   close PORTFOLIO_NOS;
 end if;
 close PORTFOLIO_NOS;
end CHK_PORT_CONST ;
----------------------------------------------------------------------------------------------------------------
--   Procedure to check that bank account has been entered if
--  principal amt is not null
PROCEDURE CHK_PRINCIPAL_BANK (l_company_code IN VARCHAR2,
                              l_currency     IN VARCHAR2,
                              l_prin_adjust  IN NUMBER,
                              l_prin_acct    IN VARCHAR2,
                              l_err_code     OUT NOCOPY NUMBER,
                              l_level        OUT NOCOPY VARCHAR2) is
--
 cursor BANK_AC is
  select 1
   from  XTR_BANK_ACCOUNTS
   where PARTY_CODE     = l_company_code
   and   CURRENCY       = l_currency;
--
 v_dummy             number(1);
begin
 if l_prin_adjust <> 0 and l_prin_acct is NULL then
  open BANK_AC;
  fetch BANK_AC into v_dummy;
  if BANK_AC%FOUND then
   close BANK_AC;
   l_err_code := 140; l_level := 'E';--Please enter a bank account for Principal Flow
  else
   close BANK_AC;
  end if;
 end if;
end CHK_PRINCIPAL_BANK;
------------------------------------------------------------------------------------------------------------------
-- Procedure to validate the printer name entered
PROCEDURE CHK_PRINTER_NAME(l_p_name   IN VARCHAR2,
                           l_p_value  IN OUT NOCOPY VARCHAR2,
                           l_err_code OUT NOCOPY NUMBER,
                           l_level    OUT NOCOPY VARCHAR2) is
--
 cursor CHK_PTR is
  select PARAM_VALUE
   from XTR_PRO_PARAM
   where PARAM_NAME = l_p_name
   and PARAM_TYPE = 'PRINTER';
--
begin
 if l_p_name is NOT NULL then
  open CHK_PTR;
   fetch CHK_PTR INTO l_p_value;
  if CHK_PTR%NOTFOUND then
   l_err_code := 701; l_level := 'E';-- Invalid Value, Refer <LIST>.
  end if;
  close CHK_PTR;
 end if;
end CHK_PRINTER_NAME;
----------------------------------------------------------------------------------------------------------------
--   Procedure to check constraint for rollover transactions.
PROCEDURE CHK_ROLLOVER (l_deal_number IN NUMBER,
                        l_start_date  IN DATE,
                        l_err_code    OUT NOCOPY NUMBER,
                        l_level       OUT NOCOPY VARCHAR2) is
--
 cursor CHK_RT_ROW is
  select  1
   from   XTR_ROLLOVER_TRANSACTIONS_V
   where  START_DATE = l_start_date
   and    DEAL_NUMBER = l_deal_number;
--
 v_dummy                   number(1);
begin
 open CHK_RT_ROW;
 fetch CHK_RT_ROW INTO v_dummy;
 if CHK_RT_ROW%FOUND then
   close CHK_RT_ROW;
   l_err_code := 236; l_level := 'E';-- Row exists already with same Start Date, Deal Number
 else
   close CHK_RT_ROW;
 end if;
end CHK_ROLLOVER;
----------------------------------------------------------------------------------------------------------------
--   Procedure to validate deal status code input is correct
PROCEDURE CHK_STATUS_CODE (
                           l_status_code         IN VARCHAR2,
                           l_deal_type           IN VARCHAR2,
                           l_record_status       IN VARCHAR2,
                           l_status_name         IN OUT NOCOPY VARCHAR2,
                           l_statcode_updateable IN OUT NOCOPY VARCHAR2,
                           l_err_code            OUT NOCOPY NUMBER,
                           l_level               OUT NOCOPY VARCHAR2) is
--
 cursor STATUS is
  select NULL DESCRIPTION, UPDATEABLE
   from   XTR_DEAL_STATUSES
   where  STATUS_CODE   = l_status_code
   and    DEAL_TYPE     = l_deal_type
   and    AUTO_USER_SET = decode(l_record_status,'QUERY',
                                   AUTO_USER_SET,'U');
--
begin
 open STATUS;
  fetch STATUS INTO l_status_name, l_statcode_updateable;
 if STATUS%NOTFOUND then
  l_err_code := 701; l_level := 'E';--This Deal Status does not exist
 end if;
 close STATUS;
end CHK_STATUS_CODE;
----------------------------------------------------------------------------------------------------------------
PROCEDURE CHK_FX_TOLERANCE(l_rate        IN NUMBER,
                           l_currency_a  IN VARCHAR2,
                           l_currency_b  IN VARCHAR2,
                           l_tolerance   IN NUMBER,
                           l_err_code    OUT NOCOPY NUMBER,
                           l_level       OUT NOCOPY VARCHAR2) is
--
/* Procedure for FX INSTRUMENTS using tolerance retrieved from Deal
 Subtypes  to calculate allowable base rate and transaction rate ranges. If the tolerance
 is null then there is no further checking. If the tolerance is not null
 then find the latest bid rate found for this buy/sell currency comb and
 add and subtract the tolerance from this to create an acceptable rate
 range.*/
--

/* Bug 3142490
 mkt_rate  number(9,5);
 mkt_rate1 number(9,5);
 mkt_rate2 number(9,5);
 low_rate  number(9,5);
 high_rate number(9,5);
*/

 mkt_rate  number;
 mkt_rate1 number;
 mkt_rate2 number;
 low_rate  number;
 high_rate number;
 ccy_f     varchar2(15);
--
-- Get ccy first
 cursor CF is
  select a.CURRENCY_FIRST
   from XTR_BUY_SELL_COMBINATIONS a
   where ((a.CURRENCY_BUY = l_currency_a and a.CURRENCY_SELL = l_currency_b)
       or (a.CURRENCY_BUY = l_currency_b and a.CURRENCY_SELL = l_currency_a));
--
 cursor TOL1 is
  select a.USD_QUOTED_SPOT
   from XTR_MASTER_CURRENCIES a
   where a.CURRENCY = l_currency_a;
--
 cursor TOL2 is
  select a.USD_QUOTED_SPOT
   from XTR_MASTER_CURRENCIES a
   where a.CURRENCY = l_currency_b;
--
begin
 if l_tolerance is NOT NULL then
  -- Determine which ccy is quoted first
  open CF;
   fetch CF INTO ccy_f;
  close CF;
  -- First Ccy USD spot Rate
  open TOL1;
   fetch TOL1 INTO mkt_rate1;
  close TOL1;
  -- Second Ccy USD spot Rate
  open TOL2;
   fetch TOL2 INTO mkt_rate2;
  close TOL2;
  -- Calc rate
  if l_currency_a = ccy_f then
   mkt_rate := mkt_rate2 / mkt_rate1;
  else
   mkt_rate := mkt_rate1 / mkt_rate2;
  end if;
  --
  low_rate  := mkt_rate - (mkt_rate * (l_tolerance / 100));
  high_rate := mkt_rate + (mkt_rate * (l_tolerance / 100));
  --
  if l_rate < low_rate OR l_rate > high_rate then
   l_err_code := 598; l_level := 'W';--FX Rate does not fall within acceptable
                                     --tolerance
  end if;
 else
  l_err_code := 599; l_level := 'W';--Could not find record in table
 end if;
end CHK_FX_TOLERANCE;
----------------------------------------------------------------------------------------------------------------
PROCEDURE CHK_TOLERANCE (l_rate      IN NUMBER,
                         l_currency  IN VARCHAR2,
                         l_tolerance IN NUMBER,
                         l_period    IN NUMBER,
                         l_unique_id IN VARCHAR2,
                         l_err_code  OUT NOCOPY NUMBER,
                         l_level     OUT NOCOPY VARCHAR2) is
--
/* Procedure for INTEREST RATE INSTRUMENTS using tolerance retrieved from Deal
 Subtypes  to calculate allowable base rate and transaction rate ranges. If the tolerance
 is null then there is no further checking. If the tolerance is not null
 then find the latest bid rate found for this buy/sell currency comb and
 add and subtract the tolerance from this to create an acceptable rate
 range.*/

--

/* BUG 3142490
 mkt_rate  number(9,5);
 low_rate  number(9,5);
 high_rate number(9,5);
*/

 mkt_rate  number;
 low_rate  number;
 high_rate number;

--
 cursor TOL is
  select (a.BID_PRICE + a.ASK_PRICE) / 2
   from XTR_MARKET_PRICES a
   where a.CURRENCY_A = l_currency
   and ((a.NOS_OF_DAYS <= l_period and nvl(l_unique_id,'%') = '%'
           and a.NOS_OF_DAYS <> 0 and a.TERM_TYPE NOT IN('S','F','W','V','O')) or
          (a.RIC_CODE = l_unique_id and nvl(l_unique_id,'%') <> '%'))
   order by NOS_OF_DAYS desc;
--
begin
 if l_tolerance is NOT NULL then
  open TOL;
  fetch TOL INTO mkt_rate;
  if TOL%FOUND then
   low_rate  := mkt_rate - l_tolerance;
   high_rate := mkt_rate + l_tolerance;
  end if;
  close TOL;
 --
  if l_rate < low_rate OR l_rate > high_rate then
   l_err_code := 598; l_level := 'W';--Interest Rate does not fall within acceptable
                                                 --tolerance
  end if;
 else
   l_err_code := 599; l_level := 'W';--Could not find record in table
 end if;
end CHK_TOLERANCE;
----------------------------------------------------------------------------------------------------------------
PROCEDURE CHK_TIME_RESTRICTIONS (l_deal_type       IN VARCHAR2,
                                 l_deal_subtype    IN VARCHAR2,
                                 l_product_type    IN VARCHAR2,
                                 l_cparty_code     IN VARCHAR2,
                                 l_date            IN DATE,
                                 l_max_date        OUT NOCOPY DATE,
                                 l_err_code        OUT NOCOPY NUMBER,
                                 l_level           OUT NOCOPY VARCHAR2) is

--
 cursor T_RES is
  select RANGE -- range is nos of days max period contract can go out until
   from  XTR_TIME_RESTRICTIONS
   where DEAL_TYPE = l_deal_type
   and  (DEAL_SUBTYPE  = l_deal_subtype or DEAL_SUBTYPE is NULL)
   and  (SECURITY_NAME = l_product_type or SECURITY_NAME is NULL)
   and  (CPARTY_CODE   = l_cparty_code or CPARTY_CODE is NULL)
   order by CPARTY_CODE asc,SECURITY_NAME asc,DEAL_SUBTYPE asc;
--
 l_max_days NUMBER(7);
--
begin
 open T_RES;
  fetch T_RES INTO l_max_days;
 if T_RES%FOUND then
  if (l_date - sysdate) > l_max_days then
   -- This Deal exceeds max length of contract allowed
   l_err_code := 124;
   l_level := 'E';
   l_max_date := sysdate + l_max_days;
  end if;
 end if;
 close T_RES;
end CHK_TIME_RESTRICTIONS;


--Bug 2804548
--Previous business day: The convention that if a value date in the future
--falls on a non-business day, the value date will be moved to the previous
--business day.
FUNCTION previous_bus_day(p_date IN DATE,
			p_ccy IN VARCHAR2) RETURN DATE IS
   v_date_out DATE;
BEGIN
   xtr_market_data_p.Modified_Following_Holiday(p_ccy,
				     p_date,
				     v_date_out);
   return v_date_out;
END previous_bus_day;



--Bug 2804548
--Following business day: The convention that if a value date in the future
--falls on a non-business day, the value date will be moved to the next
--business day.
FUNCTION following_bus_day(p_date IN DATE,
			p_ccy IN VARCHAR2) RETURN DATE IS

  v_err_code        number(8);
  v_level           varchar2(2) := ' ';
  v_date            DATE;
  v_date_out DATE;

BEGIN

  v_date:= p_date;
  LOOP
  -- keep on subtracting a day until it's not a holiday or weekend
    v_date := v_date + 1;
    XTR_fps3_P.CHK_HOLIDAY (v_date,
                             p_ccy,
                             v_err_code,
                             v_level);
    EXIT WHEN v_err_code is null;
  END LOOP;
  v_date_out := v_date;
  return v_date_out;

END following_bus_day;



--Bug 2804548
--Modified following business day:  The convention that if a value date in
--the future falls on a non-business day, the value date will be moved to the
--next following business day, unless this moves the value date to the next
--month, in which case the value date is moved back to the previous business
--day.
FUNCTION mod_following_bus_day(p_date IN DATE,
			p_ccy IN VARCHAR2) RETURN DATE IS
   v_in_rec xtr_market_data_p.following_holiday_in_rec_type;
   v_out_rec xtr_market_data_p.following_holiday_out_rec_type;
   v_date_out DATE;
BEGIN
   v_in_rec.p_term_type := 'M';
   v_in_rec.p_currency := p_ccy;
   v_in_rec.p_future_date := p_date;
   v_in_rec.p_period_code := 1;
   xtr_market_data_p.Following_Holiday(v_in_rec,v_out_rec);
   if v_out_rec.p_date_out is null then
      v_date_out := p_date;
   else
      v_date_out := v_out_rec.p_date_out;
   end if;
   return v_date_out;
END mod_following_bus_day;



--Bug 2804548
--Modified previous business day: The convention that if a value date in the
--future falls on a non-business day, the value date will be moved to the
--previous business day, unless this moves the value date to the previous
--month, in which case the value date is moved forward to the following
--business day.
FUNCTION mod_previous_bus_day(p_date IN DATE,
			p_ccy IN VARCHAR2) RETURN DATE IS
  v_date DATE := p_date;
  v_date_out DATE;
  v_err_code        number(8);
  v_level           varchar2(2) := ' ';
BEGIN

  LOOP
  -- keep on adding a day until it's not a holiday or weekend
    v_date:=v_date - 1;
    XTR_fps3_P.CHK_HOLIDAY (v_date,
                             p_ccy,
                             v_err_code,
                             v_level);
    EXIT WHEN v_err_code is null;
  END LOOP;

  -- if the month changed during the loop, do following_bus_day
  IF TO_CHAR(v_date,'MM') <> TO_CHAR(p_date,'MM') THEN
      v_date_out := Following_bus_day(v_date,p_ccy);
  ELSE
      v_date_out := v_date;
  END IF;
  return v_date_out;
END mod_previous_bus_day;



--Bug 2804548
--This procedure calculate the given date using the given Settlement
--Basis
PROCEDURE settlement_basis_calc(p_in_rec  IN settlementbasis_in_rec,
		       p_out_rec IN OUT NOCOPY settlementbasis_out_rec) IS
  v_err_code        number(8);
  v_level           varchar2(2) := ' ';
  v_date            DATE;
BEGIN
   XTR_fps3_P.CHK_HOLIDAY (p_in_rec.date_in,
                             p_in_rec.ccy,
                             v_err_code,
                             v_level);
   if v_err_code is not null then --is holiday
      if p_in_rec.settlement_basis='P' then
         v_date := previous_bus_day(p_in_rec.date_in,
			p_in_rec.ccy);
      elsif p_in_rec.settlement_basis='F' then
         v_date := following_bus_day(p_in_rec.date_in,
			p_in_rec.ccy);
      elsif p_in_rec.settlement_basis='MF' then
         v_date := mod_following_bus_day(p_in_rec.date_in,
			p_in_rec.ccy);
      elsif p_in_rec.settlement_basis='MP' then
         v_date := mod_previous_bus_day(p_in_rec.date_in,
			p_in_rec.ccy);
      else
         v_date := p_in_rec.date_in;
      end if;
   else
      v_date := p_in_rec.date_in;
   end if;
   p_out_rec.date_out := v_date;
END settlement_basis_calc;



--Bug 2804548
--Returning boolean to check whether any components of the CURRENT coupon
--has been settled or not.
PROCEDURE settled_validation(p_in_rec  IN validation_in_rec,
		       p_out_rec IN OUT NOCOPY validation_out_rec) IS
   cursor bond_coupon_settled(p_bond_issue_code VARCHAR2,
			p_coupon_date DATE) is
      select 1
      from xtr_deals d, xtr_rollover_transactions rt, xtr_deal_date_amounts dda
      where rt.deal_number=d.deal_no
      and d.bond_issue=p_bond_issue_code
      and rt.maturity_date=p_coupon_date
      and dda.settle='Y'
      and rt.deal_type='BOND'
      and dda.deal_number=0
      and dda.deal_type='EXP'
      and ((rt.tax_settled_reference is not null
      and dda.transaction_number=rt.tax_settled_reference)
      or (rt.principal_tax_settled_ref is not null
      and dda.transaction_number=rt.principal_tax_settled_ref))
      UNION ALL
      select 1
      from xtr_deals d, xtr_rollover_transactions rt, xtr_deal_date_amounts dda
      where rt.deal_number=d.deal_no
      and d.bond_issue=p_bond_issue_code
      and rt.maturity_date=p_coupon_date
      and dda.settle='Y'
      and rt.deal_type='BOND'
      and dda.deal_number=rt.deal_number
      and dda.transaction_number=rt.transaction_number
      and dda.deal_type='BOND';

   cursor bond_coupon_settled_all(p_bond_issue_code VARCHAR2) is
      select 1
      from xtr_deals d, xtr_rollover_transactions rt, xtr_deal_date_amounts dda
      where rt.deal_number=d.deal_no
      and d.bond_issue=p_bond_issue_code
      and dda.settle='Y'
      and rt.deal_type='BOND'
      and dda.deal_number=0
      and dda.deal_type='EXP'
      and ((rt.tax_settled_reference is not null
      and dda.transaction_number=rt.tax_settled_reference)
      or (rt.principal_tax_settled_ref is not null
      and dda.transaction_number=rt.principal_tax_settled_ref))
      UNION ALL
      select 1
      from xtr_deals d, xtr_rollover_transactions rt, xtr_deal_date_amounts dda
      where rt.deal_number=d.deal_no
      and d.bond_issue=p_bond_issue_code
      and dda.settle='Y'
      and rt.deal_type='BOND'
      and dda.deal_number=rt.deal_number
      and dda.transaction_number=rt.transaction_number
      and dda.deal_type='BOND';

   v_dummy NUMBER;
BEGIN
   p_out_rec.yes := FALSE;
   if p_in_rec.deal_type='BOND' then
      if p_in_rec.bond_coupon_date is not null then
         open bond_coupon_settled(p_in_rec.bond_issue_code,
			p_in_rec.bond_coupon_date);
         fetch bond_coupon_settled into v_dummy;
         p_out_rec.yes := bond_coupon_settled%FOUND;
         close bond_coupon_settled;
      else
         open bond_coupon_settled_all(p_in_rec.bond_issue_code);
         fetch bond_coupon_settled_all into v_dummy;
         p_out_rec.yes := bond_coupon_settled_all%FOUND;
         close bond_coupon_settled_all;
      end if;
   end if;
END settled_validation;



--Bug 2804548
--Returning boolean to check whether any components of the CURRENT coupon
--has been journaled or not.
PROCEDURE journaled_validation(p_in_rec  IN validation_in_rec,
		       p_out_rec IN OUT NOCOPY validation_out_rec) IS
   cursor bond_coupon_journaled (p_bond_issue_code VARCHAR2,
			p_coupon_date DATE) is
      select 1
      from xtr_deals d, xtr_rollover_transactions rt, xtr_journals j
      where rt.deal_number=d.deal_no
      and d.bond_issue=p_bond_issue_code
      and rt.maturity_date=p_coupon_date
      and j.orig_journal_date is not null
      and rt.deal_type='BOND'
      and j.deal_number=rt.deal_number
      and j.deal_type='EXP'
      and ((rt.tax_settled_reference is not null
      and j.transaction_number=rt.tax_settled_reference)
      or (rt.principal_tax_settled_ref is not null
      and j.transaction_number=rt.principal_tax_settled_ref))
      UNION ALL
      select 1
      from xtr_deals d, xtr_rollover_transactions rt, xtr_journals j
      where rt.deal_number=d.deal_no
      and d.bond_issue=p_bond_issue_code
      and rt.maturity_date=p_coupon_date
      and j.orig_journal_date is not null
      and rt.deal_type='BOND'
      and j.deal_type=rt.deal_type
      and rt.deal_number=j.deal_number
      and rt.transaction_number=j.transaction_number;

   cursor bond_coupon_journaled_all (p_bond_issue_code VARCHAR2) is
      select 1
      from xtr_deals d, xtr_rollover_transactions rt, xtr_journals j
      where rt.deal_number=d.deal_no
      and d.bond_issue=p_bond_issue_code
      and j.orig_journal_date is not null
      and rt.deal_type='BOND'
      and j.deal_number=rt.deal_number
      and j.deal_type='EXP'
      and ((rt.tax_settled_reference is not null
      and j.transaction_number=rt.tax_settled_reference)
      or (rt.principal_tax_settled_ref is not null
      and j.transaction_number=rt.principal_tax_settled_ref))
      UNION ALL
      select 1
      from xtr_deals d, xtr_rollover_transactions rt, xtr_journals j
      where rt.deal_number=d.deal_no
      and d.bond_issue=p_bond_issue_code
      and j.orig_journal_date is not null
      and rt.deal_type='BOND'
      and j.deal_type=rt.deal_type
      and rt.deal_number=j.deal_number
      and rt.transaction_number=j.transaction_number;

   v_dummy NUMBER;
BEGIN
   p_out_rec.yes := FALSE;
   if p_in_rec.deal_type='BOND' then
      if p_in_rec.bond_coupon_date is not null then
         open bond_coupon_journaled(p_in_rec.bond_issue_code,
			p_in_rec.bond_coupon_date);
         fetch bond_coupon_journaled into v_dummy;
         p_out_rec.yes := bond_coupon_journaled%FOUND;
         close bond_coupon_journaled;
      else
         open bond_coupon_journaled_all(p_in_rec.bond_issue_code);
         fetch bond_coupon_journaled_all into v_dummy;
         p_out_rec.yes := bond_coupon_journaled_all%FOUND;
         close bond_coupon_journaled_all;
      end if;
   end if;
END journaled_validation;



--Bug 2804548
--Returning boolean to check whether any components of the CURRENT coupon
--has been reconciled or not.
PROCEDURE reconciled_validation(p_in_rec IN validation_in_rec,
		       p_out_rec IN OUT NOCOPY validation_out_rec) IS
   cursor bond_coupon_reconciled (p_bond_issue_code VARCHAR2,
			p_coupon_date DATE) is
      select 1
      from xtr_deals d, xtr_rollover_transactions rt, xtr_deal_date_amounts dda
      where rt.deal_number=d.deal_no
      and d.bond_issue=p_bond_issue_code
      and rt.maturity_date=p_coupon_date
      and dda.reconciled_reference is not null
      and rt.deal_type='BOND'
      and dda.deal_number=0
      and dda.deal_type='EXP'
      and ((rt.tax_settled_reference is not null
      and dda.transaction_number=rt.tax_settled_reference)
      or (rt.principal_tax_settled_ref is not null
      and dda.transaction_number=rt.principal_tax_settled_ref))
      UNION ALL
      select 1
      from xtr_deals d, xtr_rollover_transactions rt, xtr_deal_date_amounts dda
      where rt.deal_number=d.deal_no
      and d.bond_issue=p_bond_issue_code
      and rt.maturity_date=p_coupon_date
      and dda.reconciled_reference is not null
      and rt.deal_type='BOND'
      and dda.deal_number=rt.deal_number
      and dda.transaction_number=rt.transaction_number
      and dda.deal_type='BOND';

   cursor bond_coupon_reconciled_all (p_bond_issue_code VARCHAR2) is
      select 1
      from xtr_deals d, xtr_rollover_transactions rt, xtr_deal_date_amounts dda
      where rt.deal_number=d.deal_no
      and d.bond_issue=p_bond_issue_code
      and dda.reconciled_reference is not null
      and rt.deal_type='BOND'
      and dda.deal_number=0
      and dda.deal_type='EXP'
      and ((rt.tax_settled_reference is not null
      and dda.transaction_number=rt.tax_settled_reference)
      or (rt.principal_tax_settled_ref is not null
      and dda.transaction_number=rt.principal_tax_settled_ref))
      UNION ALL
      select 1
      from xtr_deals d, xtr_rollover_transactions rt, xtr_deal_date_amounts dda
      where rt.deal_number=d.deal_no
      and d.bond_issue=p_bond_issue_code
      and dda.reconciled_reference is not null
      and rt.deal_type='BOND'
      and dda.deal_number=rt.deal_number
      and dda.transaction_number=rt.transaction_number
      and dda.deal_type='BOND';

   v_dummy NUMBER;
BEGIN
   p_out_rec.yes := FALSE;
   if p_in_rec.deal_type='BOND' then
      if p_in_rec.bond_coupon_date is not null then
         open bond_coupon_reconciled(p_in_rec.bond_issue_code,
			p_in_rec.bond_coupon_date);
         fetch bond_coupon_reconciled into v_dummy;
         p_out_rec.yes := bond_coupon_reconciled%FOUND;
         close bond_coupon_reconciled;
      else
         open bond_coupon_reconciled_all(p_in_rec.bond_issue_code);
         fetch bond_coupon_reconciled_all into v_dummy;
         p_out_rec.yes := bond_coupon_reconciled_all%FOUND;
         close bond_coupon_reconciled_all;
      end if;
   end if;
END reconciled_validation;



--Bug 2804548
--Returning boolean to check whether any components of the CURRENT coupon
--has been accrued or not.
PROCEDURE accrued_validation(p_in_rec IN validation_in_rec,
		       p_out_rec IN OUT NOCOPY validation_out_rec) IS
   cursor bond_coupon_accrued (p_bond_issue_code VARCHAR2,
			p_coupon_date DATE) is
      select 1
      from xtr_rollover_transactions rt, xtr_accrls_amort a, xtr_deals d
      where rt.deal_number=a.deal_no
      and rt.transaction_number=a.trans_no
      and d.deal_no=rt.deal_number
      and d.bond_issue=p_bond_issue_code
      and rt.maturity_date=p_coupon_date;

   cursor bond_coupon_accrued_all (p_bond_issue_code VARCHAR2) is
      select 1
      from xtr_accrls_amort a, xtr_deals d
      where amount_type='CPMADJ'
      and d.deal_no=a.deal_no
      and d.bond_issue=p_bond_issue_code;

   v_dummy NUMBER;
BEGIN
   p_out_rec.yes := FALSE;
   if p_in_rec.deal_type='BOND' then
      if p_in_rec.bond_coupon_date is not null then
         open bond_coupon_accrued(p_in_rec.bond_issue_code,
			p_in_rec.bond_coupon_date);
         fetch bond_coupon_accrued into v_dummy;
         p_out_rec.yes := bond_coupon_accrued%FOUND;
         close bond_coupon_accrued;
      else
         open bond_coupon_accrued_all(p_in_rec.bond_issue_code);
         fetch bond_coupon_accrued_all into v_dummy;
         p_out_rec.yes := bond_coupon_accrued_all%FOUND;
         close bond_coupon_accrued_all;
      end if;
   end if;
END accrued_validation;

----------------------------------------------------------------------------------------------------------------
end XTR_FPS3_P;

/
