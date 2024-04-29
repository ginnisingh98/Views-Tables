--------------------------------------------------------
--  DDL for Package Body XTR_RATE_CHANGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_RATE_CHANGE" AS
/* $Header: xtrpdrtb.pls 120.3 2005/06/29 10:48:38 rjose ship $ */



PROCEDURE PRODUCT_RATE_CHANGE(
	errbuf       			OUT NOCOPY VARCHAR2,
	retcode      			OUT NOCOPY VARCHAR2,
	p_effective_from_date		IN	VARCHAR2,
 	p_eff_from_next_rollover_yn	IN	VARCHAR2,
	p_new_interest_rate		IN	VARCHAR2,
	p_change_pi_yn			IN	VARCHAR2,
	p_deal_subtype			IN	VARCHAR2,
	p_payment_schedule_code		IN	VARCHAR2,
	p_currency			IN	VARCHAR2,
	p_min_balance			IN	NUMBER,
	p_max_balance			IN	NUMBER)
IS

  g_expected_balance_bf		NUMBER;
  g_balance_out_bf		NUMBER;
  g_accum_interest_bf		NUMBER;
  g_principal_adjust		NUMBER;
  l_new_pi_amount_due 		NUMBER;
  l_effective_from_date		DATE;
  l_effective_date		DATE;
  l_created_on    		DATE;
  p_created_by    		VARCHAR2(30);
  CHK_DATE			VARCHAR2(1) := 'N';
  l_pi_amount_due 		NUMBER;
  l_pi_amount_received 		NUMBER;
  l_tran_num      		NUMBER;
  l_interest_rate 		NUMBER;
  l_maturity_date		DATE;
  l_row_inserted		VARCHAR2(1) := null;

  cursor DEAL_CUR is
     select 	DEAL_NO, PAYMENT_SCHEDULE_CODE, DEAL_TYPE,
		DEAL_SUBTYPE, PRODUCT_TYPE, INTEREST_RATE,
		PI_AMOUNT_DUE, CURRENCY, SETTLE_DATE,
		PORTFOLIO_CODE,COMPANY_CODE,DEAL_DATE,
      		CPARTY_CODE,CLIENT_CODE,DEALER_CODE
     from XTR_DEALS_V d
     where d.DEAL_TYPE = 'RTMM'
     and   d.DEAL_SUBTYPE = nvl(p_deal_subtype, d.DEAL_SUBTYPE)
     and   d.CURRENCY = nvl(p_currency, d.CURRENCY)
     and   d.PAYMENT_SCHEDULE_CODE = nvl(p_payment_schedule_code, d.PAYMENT_SCHEDULE_CODE)
     and   d.STATUS_CODE = 'CURRENT'
     and   exists( select 'ANY TRANS'
		   from XTR_ROLLOVER_TRANSACTIONS_V  t
    		   where  nvl(t.STATUS_CODE, 'CURRENT') = 'CURRENT'
    		   and    t.BALANCE_OUT between nvl(p_min_balance, 0) and
			       nvl(p_max_balance, t.BALANCE_OUT + 1)
    		   and    t.SETTLE_DATE is NULL
    		   and    t.START_DATE >= l_effective_from_date
		   and    t.START_DATE >= nvl(d.SETTLE_DATE, t.START_DATE)
	           --and    nvl(RATE_EFFECTIVE_CREATED,l_effective_from_date )
                   --	<= l_effective_from_date
    		   and    t.DEAL_NUMBER = d.DEAL_NO);

  cursor CHECK_ON_ROLLOVER(p_deal_no NUMBER, p_date DATE) is
	select 'Y'
	from XTR_ROLLOVER_TRANSACTIONS
	where DEAL_NUMBER = p_deal_no
	and   START_DATE = p_date;

  cursor T_NOS(p_deal_no NUMBER) is
  	select nvl(max(TRANSACTION_NUMBER),0) + 1
   	from XTR_ROLLOVER_TRANSACTIONS_V
   	where DEAL_NUMBER = p_deal_no;

  cursor THIS_ROW(p_deal_no NUMBER, p_date DATE) is
  	select 	PI_AMOUNT_DUE,
		INTEREST_RATE,
		PI_AMOUNT_RECEIVED,
		MATURITY_DATE
   	from XTR_ROLLOVER_TRANSACTIONS_V
   	where DEAL_NUMBER = p_deal_no
   	and START_DATE < p_date
    	and MATURITY_DATE >= p_date
   	and nvl(PI_AMOUNT_DUE,0) <> 0
   	order by START_DATE desc,TRANSACTION_NUMBER desc;

 cursor DEALER is
  select dealer_code
  from   xtr_dealer_codes_v
  where  user_id = fnd_global.user_id;


BEGIN
  --cep_standard.enable_debug;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('XTR_RATE_CHANGE.PRODUCT_RATE_CHANGE');
     xtr_debug_pkg.debug('PRODUCT_RATE_CHANGE: ' || 'p_effective_from_date  = ' ||p_effective_from_date );
     xtr_debug_pkg.debug('PRODUCT_RATE_CHANGE: ' || 'p_deal_subtype  = ' ||p_deal_subtype );
     xtr_debug_pkg.debug('PRODUCT_RATE_CHANGE: ' || 'p_payment_schedule_code  = ' ||p_payment_schedule_code );
     xtr_debug_pkg.debug('PRODUCT_RATE_CHANGE: ' || 'p_currency  = ' ||p_currency );
     xtr_debug_pkg.debug('PRODUCT_RATE_CHANGE: ' || 'p_min_balance  = ' ||p_min_balance );
     xtr_debug_pkg.debug('PRODUCT_RATE_CHANGE: ' || 'p_max_balance  = ' ||p_max_balance );
     xtr_debug_pkg.debug('PRODUCT_RATE_CHANGE: ' || 'p_change_pi_yn	  = ' ||p_change_pi_yn	 );
     xtr_debug_pkg.debug('PRODUCT_RATE_CHANGE: ' || 'p_change_pi_yn	  = ' ||p_change_pi_yn	 );
     xtr_debug_pkg.debug('PRODUCT_RATE_CHANGE: ' || 'p_new_interest_rate  = ' ||p_new_interest_rate );
  END IF;

  open DEALER;
  fetch DEALER into p_created_by;
  if DEALER%NOTFOUND then
     p_created_by := null;
  end if;
  close DEALER;
  l_created_on := sysdate;

  l_effective_from_date := to_date(
	to_date(p_effective_from_date, 'YYYY/MM/DD HH24:MI:SS'), 'DD-MON-RR');

  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('PRODUCT_RATE_CHANGE: ' || 'l_effective_from_date  = ' ||l_effective_from_date );
  END IF;

  FOR deal in DEAL_CUR LOOP
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('PRODUCT_RATE_CHANGE: ' || 'deal_no  = ' ||deal.DEAL_NO );
    END IF;

----IF deal.DEAL_NO = 13135 THEN ----------------------------

    if nvl(deal.SETTLE_DATE, l_effective_from_date) > l_effective_from_date then
      l_effective_date := deal.SETTLE_DATE;
    else
      l_effective_date := l_effective_from_date;
    end if;

    if nvl(p_change_pi_yn, 'N') = 'Y' then
      XTR_RATE_CHANGE.RECALC_PI_AMOUNT( deal.DEAL_NO,
			p_new_interest_rate,
			l_effective_date,
			p_eff_from_next_rollover_yn,
    			l_new_pi_amount_due);
    else
      l_new_pi_amount_due := null;
    end if;

    update XTR_ROLLOVER_TRANSACTIONS_V
    set    INTEREST_RATE          = p_new_interest_rate,
           RATE_EFFECTIVE_CREATED = l_created_on,  -- AW 7/15 sysdate,
 	   PI_AMOUNT_DUE          = nvl(l_new_pi_amount_due, PI_AMOUNT_DUE)
    where  DEAL_NUMBER            = deal.DEAL_NO
    and    nvl(STATUS_CODE, 'CURRENT') = 'CURRENT'
    and    (BALANCE_OUT between nvl(p_min_balance, 0) and
			       nvl(p_max_balance, BALANCE_OUT + 1))
    and    SETTLE_DATE is NULL
    and    START_DATE >= l_effective_date;
    -- and    nvl(RATE_EFFECTIVE_CREATED,l_effective_from_date )
    --             <= l_effective_from_date;

    if SQL%FOUND then
      update XTR_DEALS
      set INTEREST_RATE = p_new_interest_rate
      where DEAL_NO = deal.DEAL_NO;
    end if;

    open CHECK_ON_ROLLOVER(deal.DEAL_NO, l_effective_date);
    fetch CHECK_ON_ROLLOVER into CHK_DATE;
    close CHECK_ON_ROLLOVER;

    if nvl(p_eff_from_next_rollover_yn, 'N') = 'N' and nvl(CHK_DATE, 'N') = 'N' then

      open T_NOS(deal.DEAL_NO);
      fetch T_NOS INTO l_tran_num;
      close T_NOS;

      open THIS_ROW(deal.DEAL_NO, l_effective_date);
      fetch THIS_ROW INTO 	l_pi_amount_due,
				l_interest_rate,
				l_pi_amount_received,
				l_maturity_date;
      close THIS_ROW;

      if l_tran_num is NOT NULL then
        insert into XTR_ROLLOVER_TRANSACTIONS_V
     		(DEAL_NUMBER,
		TRANSACTION_NUMBER,
		DEAL_TYPE,
		RATE_FIXING_DATE,
		START_DATE,
		MATURITY_DATE,
      		INTEREST_RATE,
		NO_OF_DAYS,
		PI_AMOUNT_DUE,
		BALANCE_OUT_BF,
      		BALANCE_OUT,
		CREATED_BY,
		CREATED_ON,
		PRINCIPAL_ADJUST,
		STATUS_CODE,
      		PORTFOLIO_CODE,
		CURRENCY,
		DEAL_SUBTYPE,
		COMPANY_CODE,
		DEAL_DATE,
		PRODUCT_TYPE,
		CPARTY_CODE,
      		CLIENT_CODE,
		DEALER_CODE)
    	  values
     		(deal.DEAL_NO,
		l_tran_num,
		'RTMM',
		l_effective_date,
		l_effective_date,
      		l_maturity_date,
		p_new_interest_rate,
		(l_maturity_date - l_effective_date),
      		l_pi_amount_due,
      		0,
		0,
		'-1',
		SYSDATE,
		0,
      		'CURRENT',
		deal.PORTFOLIO_CODE,
		deal.CURRENCY,
		deal.DEAL_SUBTYPE,
		deal.COMPANY_CODE,
		deal.DEAL_DATE,
      		deal.PRODUCT_TYPE,
		deal.CPARTY_CODE,
		deal.CLIENT_CODE,
		deal.DEALER_CODE);
        end if;

       l_row_inserted := 'Y';

    end if;

    /*  AW 7/15 Bug 914129  Should not allow to update previous actions for this deal !!!
    update XTR_term_actions_V
    set NEW_INTEREST_RATE      = p_new_interest_rate,
        EFFECTIVE_FROM_DATE    = sysdate,
        CREATED_ON	       = SYSDATE,
        CREATED_BY             = '-1'
    where deal_no = deal.DEAL_NO;
    if SQL%NOTFOUND then
    */
      insert into XTR_term_actions_V(
        	DEAL_NO,
        	NEW_INTEREST_RATE,
        	EFFECTIVE_FROM_DATE,
        	CREATED_ON,
       		CREATED_BY,
                MASS_RATE_UPDATE)
      values   (deal.DEAL_NO,
		p_new_interest_rate,
		l_effective_date,  --  AW 7/15 Bug 914129 sysdate,
		l_created_on,      --  AW 7/15 Bug 914129 sysdate,
		p_created_by,
                'Y');
    /*  AW 7/15 Bug 914129
      select    deal.DEAL_NO,
		p_new_interest_rate,
		l_effective_date,  --  AW 7/15 Bug 914129 sysdate,
		l_created_on,      --  AW 7/15 Bug 914129 sysdate,
		'-1'
      from dual;

    end if;
    */

    XTR_CALC_P.RECALC_DT_DETAILS(
              	     deal.DEAL_NO,
                     l_row_inserted,
                     l_effective_date,
                     l_tran_num,
		     'N',
		     'N',
		     g_expected_balance_bf,
                     g_balance_out_bf,
                     g_accum_interest_bf,
                     g_principal_adjust,
                     null,
                     null,
                     null,
                     null,
                     null );


----END IF; ---------------

  END LOOP;

 -- AW 7/27 939515
  update XTR_RATE_SETS
  set    CONCURRENT_REQUEST = 'Y'
  where  EFFECTIVE_FROM           = to_date(p_effective_from_date,'YYYY/MM/DD')
  and    RATE                     = p_new_interest_rate
  and    DEAL_SUBTYPE             = p_deal_subtype
  and    PRODUCT_TYPE             = p_payment_schedule_code
  and    CURRENCY                 = p_currency
  and    LOW_RANGE                = p_min_balance
  and    HIGH_RANGE               = p_max_balance;
  commit;

END PRODUCT_RATE_CHANGE;

PROCEDURE RECALC_PI_AMOUNT(
	p_deal_number			IN	NUMBER,
	p_new_interest_rate 		IN 	NUMBER,
	p_effective_from_date 		IN 	DATE,
	p_eff_from_next_rollover_yn  	IN	VARCHAR2,
	p_new_pi_amount_due 		OUT 	NOCOPY NUMBER)
IS
  cursor DEAL_CUR is
     select 	PAYMENT_SCHEDULE_CODE, DEAL_TYPE,DEAL_SUBTYPE,
		PRODUCT_TYPE, INTEREST_RATE, MATURITY_DATE,
		PI_AMOUNT_DUE, CURRENCY
     from XTR_DEALS_V d
     where d.DEAL_NO = p_deal_number;

  cursor THIS_ROW is
  	select  START_DATE, MATURITY_DATE,
	        EXPECTED_BALANCE_BF,EXPECTED_BALANCE_OUT,
		PRINCIPAL_ADJUST,
	        INTEREST_RATE
   	from  XTR_ROLLOVER_TRANSACTIONS_V
   	where DEAL_NUMBER = p_deal_number
   	and STATUS_CODE = 'CURRENT'
   	and MATURITY_DATE >= p_effective_from_date
 	and START_DATE < p_effective_from_date
   	order by START_DATE asc,TRANSACTION_NUMBER asc;

  cursor START_ROW is
  	select START_DATE,EXPECTED_BALANCE_BF, PRINCIPAL_ADJUST
   	from  XTR_ROLLOVER_TRANSACTIONS_V
   	where DEAL_NUMBER = p_deal_number
   	and STATUS_CODE = 'CURRENT'
   	and START_DATE >= p_effective_from_date
   	order by START_DATE asc,TRANSACTION_NUMBER asc;

  l_payment_schedule_code	varchar2(7);
  l_deal_type 			varchar2(7);
  l_deal_subtype 		varchar2(7);
  l_product_type 		varchar2(10);
  l_interest_rate		NUMBER;
  l_maturity_date 	 	DATE;
  l_pi_amount_due		NUMBER;
  l_currency 		        VARCHAR2(15);
  l_start_date			DATE;
  l_expected_balance_bf		NUMBER;
  l_principal_adjust		NUMBER;
  l_year_basis			NUMBER := 365;
  l_this_start_date 		DATE;
  l_this_maturity_date		DATE;
  l_this_expected_balance_bf	NUMBER;
  l_this_expected_balance_out   NUMBER;
  l_this_principal_adjust	NUMBER;
  l_this_interest_rate		NUMBER;

  cursor FREQ is
  	select PAYMENT_FREQUENCY,
	JAN_YN,FEB_YN,MAR_YN,APR_YN,MAY_YN,JUN_YN,
	JUL_YN,AUG_YN,SEP_YN,OCT_YN,NOV_YN,DEC_YN
   	from  XTR_PAYMENT_SCHEDULE_V
   	where PAYMENT_SCHEDULE_CODE = l_payment_schedule_code
   	and DEAL_TYPE = 'RTMM'
   	and DEAL_SUBTYPE = l_deal_subtype;

  l_mth1           VARCHAR2(1);
  l_mth2           VARCHAR2(1);
  l_mth3           VARCHAR2(1);
  l_mth4           VARCHAR2(1);
  l_mth5           VARCHAR2(1);
  l_mth6           VARCHAR2(1);
  l_mth7           VARCHAR2(1);
  l_mth8           VARCHAR2(1);
  l_mth9           VARCHAR2(1);
  l_mth10          VARCHAR2(1);
  l_mth11          VARCHAR2(1);
  l_mth12          VARCHAR2(1);
  l_pymts_per_year NUMBER;
  l_tot_pymts      NUMBER;

  cursor RND_YR is
  	select ROUNDING_FACTOR
   	from  XTR_MASTER_CURRENCIES_V
   	where CURRENCY = l_currency;

  L_ROUND	 NUMBER;
  L_PAYMENT_FREQ VARCHAR2(12);

BEGIN

  open DEAL_CUR;
  fetch DEAL_CUR into l_payment_schedule_code, l_deal_type, l_deal_subtype,
		      l_product_type, l_interest_rate,l_maturity_date,
		      l_pi_amount_due,l_currency;
  close DEAL_CUR;

  open START_ROW;
  fetch START_ROW into l_start_date, l_expected_balance_bf, l_principal_adjust;
  close START_ROW;

  open THIS_ROW;
  fetch THIS_ROW into  	l_this_start_date, l_this_maturity_date,
			l_this_expected_balance_bf, l_this_expected_balance_out,
			l_this_principal_adjust,l_this_interest_rate;
  close THIS_ROW;

  open FREQ;
  fetch FREQ into  L_PAYMENT_FREQ,l_mth1,l_mth2,l_mth3,l_mth4,l_mth5,
		   l_mth6,l_mth7,l_mth8,l_mth9,l_mth10,l_mth11,l_mth12;
  close FREQ;

  if L_PAYMENT_FREQ = 'WEEKLY' then
    l_pymts_per_year := 52;
  elsif L_PAYMENT_FREQ = 'FORTNIGHTLY' then
    l_pymts_per_year := 26;
  elsif L_PAYMENT_FREQ = 'FOUR WEEKLY' then
    l_pymts_per_year := 12;
  elsif L_PAYMENT_FREQ = 'MONTHLY' then
    l_pymts_per_year := 12;
  elsif L_PAYMENT_FREQ = 'BI MONTHLY' then
    l_pymts_per_year := 6;
  elsif L_PAYMENT_FREQ = 'QUARTERLY' then
    l_pymts_per_year := 4;
  elsif L_PAYMENT_FREQ = 'SEMI ANNUAL' then
    l_pymts_per_year := 2;
  elsif L_PAYMENT_FREQ = 'ANNUAL' then
    l_pymts_per_year := 1;
  elsif L_PAYMENT_FREQ = 'AD HOC' then
    l_pymts_per_year := 0;
    if l_mth1 = 'Y' then
      l_pymts_per_year := l_pymts_per_year + 1;
    end if;
    if l_mth2 = 'Y' then
      l_pymts_per_year := l_pymts_per_year + 1;
    end if;
    if l_mth3 = 'Y' then
      l_pymts_per_year := l_pymts_per_year + 1;
    end if;
    if l_mth4 = 'Y' then
      l_pymts_per_year := l_pymts_per_year + 1;
    end if;
    if l_mth5 = 'Y' then
      l_pymts_per_year := l_pymts_per_year + 1;
    end if;
    if l_mth6 = 'Y' then
      l_pymts_per_year := l_pymts_per_year + 1;
    end if;
    if l_mth7 = 'Y' then
      l_pymts_per_year := l_pymts_per_year + 1;
    end if;
    if l_mth8 = 'Y' then
      l_pymts_per_year := l_pymts_per_year + 1;
    end if;
    if l_mth9 = 'Y' then
      l_pymts_per_year := l_pymts_per_year + 1;
    end if;
    if l_mth10 = 'Y' then
      l_pymts_per_year := l_pymts_per_year + 1;
    end if;
    if l_mth11 = 'Y' then
      l_pymts_per_year := l_pymts_per_year + 1;
    end if;
    if l_mth12 = 'Y' then
      l_pymts_per_year := l_pymts_per_year + 1;
    end if;
  else
    l_pymts_per_year := 12;
  end if;

  l_tot_pymts := round(l_pymts_per_year *
     	  months_between(l_maturity_date, l_start_date)/12, 0);

  OPEN RND_YR;
  FETCH RND_YR INTO L_ROUND;
  CLOSE RND_YR;

  if nvl(p_eff_from_next_rollover_yn, 'N') = 'N' then

	l_expected_balance_bf := l_expected_balance_bf +
		  nvl(round((nvl(l_this_expected_balance_bf, 0)+nvl(l_this_principal_adjust,0)) *
		  (p_new_interest_rate-l_this_interest_rate)*(l_this_maturity_date - p_effective_from_date )
                  / (100 * l_year_basis),l_round),0);

  end if;

  select round((nvl(l_expected_balance_bf,0) + nvl(l_principal_adjust,0)) *
   	  power((1 + (nvl(p_new_interest_rate, 0)/(l_pymts_per_year * 100))),l_tot_pymts)/
 	((power((1 + (nvl(p_new_interest_rate, 0)/(l_pymts_per_year * 100))),l_tot_pymts) - 1) /
              (nvl(p_new_interest_rate, 0)/(l_pymts_per_year * 100))),
              NVL(l_round,2))
  into p_new_pi_amount_due
  from dual;

END RECALC_PI_AMOUNT;

END XTR_RATE_CHANGE;

/
