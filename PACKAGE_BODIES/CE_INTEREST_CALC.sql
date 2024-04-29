--------------------------------------------------------
--  DDL for Package Body CE_INTEREST_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_INTEREST_CALC" as
/* $Header: ceintcab.pls 120.12.12010000.2 2008/08/10 14:27:39 csutaria ship $ */

  l_DEBUG varchar2(1) := NVL(FND_PROFILE.value('CE_DEBUG'), 'N');
--  l_DEBUG varchar2(1) := 'Y';


-- cursor not used
CURSOR cashpool_accts_cur(p_cashpool_id number ) IS
select
  ACCOUNT_ID
from CE_CASHPOOL_SUB_ACCTS SA
where
  SA.TYPE IN ('CONC', 'ACCT', 'NEST')
AND  SA.CASHPOOL_ID = p_cashpool_id
order by ACCOUNT_ID;

CURSOR calc_detail_cur(p_from_date 		date,
		       p_to_date 		date,
		       p_bank_account_id 	number,
		       p_interest_schedule_id 	number,
		       p_interest_acct_type 	varchar2,
		       p_cashpool_id 		number
		      ) IS
select
  FROM_DATE
, TO_DATE
, VALUE_DATED_BALANCE
, nvl(INTEREST_RATE,0)
, INTEREST_CALC_DETAIL_ID
from CE_INT_CALC_DETAILS_GT
where INTEREST_SCHEDULE_ID = p_interest_schedule_id
--and BANK_ACCOUNT_ID 	   = p_bank_account_id
and INTEREST_ACCT_TYPE 	   = p_interest_acct_type
and CASHPOOL_ID 	   = p_cashpool_id
UNION ALL
select
  FROM_DATE
, TO_DATE
, VALUE_DATED_BALANCE
, nvl(INTEREST_RATE,0)
, INTEREST_CALC_DETAIL_ID
from CE_INT_CALC_DETAILS_GT
where INTEREST_SCHEDULE_ID = p_interest_schedule_id
and BANK_ACCOUNT_ID 	   = p_bank_account_id
and INTEREST_ACCT_TYPE 	   = p_interest_acct_type
and CASHPOOL_ID 	  is null
order by from_date;

CURSOR end_date_cur(p_from_date 		date,
		    p_to_date 			date,
		    p_bank_account_id 		number,
		    p_interest_schedule_id 	number,
		    p_interest_acct_type 	varchar2,
		    p_cashpool_id 		number
		      ) IS
select from_date
, rownum
, INTEREST_CALC_DETAIL_ID
from CE_INT_CALC_DETAILS_GT
where
  INTEREST_SCHEDULE_ID  = p_interest_schedule_id
--and BANK_ACCOUNT_ID 	= p_bank_account_id
and INTEREST_ACCT_TYPE 	= p_interest_acct_type
and CASHPOOL_ID 	= p_cashpool_id
UNION ALL
select from_date
, rownum
, INTEREST_CALC_DETAIL_ID
from CE_INT_CALC_DETAILS_GT
where
  INTEREST_SCHEDULE_ID  = p_interest_schedule_id
and BANK_ACCOUNT_ID 	= p_bank_account_id
and INTEREST_ACCT_TYPE 	= p_interest_acct_type
and CASHPOOL_ID is null
order by from_date desc
;

CURSOR xtr_cur(p_from_date 		date,
		    p_to_date 			date,
		    p_bank_account_id 		number,
		    p_interest_schedule_id 	number,
		    p_interest_acct_type 	varchar2
		      ) IS
select from_date
, rownum
, INTEREST_CALC_DETAIL_ID
from CE_INT_CALC_DETAILS_GT
where
  INTEREST_SCHEDULE_ID  = p_interest_schedule_id
and BANK_ACCOUNT_ID 	= p_bank_account_id
and INTEREST_ACCT_TYPE 	= p_interest_acct_type
and CASHPOOL_ID is null
order by from_date desc
;

CURSOR balance_info(p_from_date 		date,
			p_to_date 		date,
		       	p_bank_account_id 	number,
		       	p_interest_schedule_id 	number
		      ) IS

 select
   BAB.BANK_ACCOUNT_ID
 , max(BAB.BALANCE_DATE)   BALANCE_DATE_FROM
 , BAB.VALUE_DATED_BALANCE
 , IBR.BALANCE_RANGE_ID
 , (select distinct ir.interest_rate
   from  CE_INTEREST_RATES  IR
   where ir.balance_range_id = IBR.BALANCE_RANGE_ID
	and ir.effective_date =
		(select max(ir2.effective_date)
		 from CE_INTEREST_RATES  IR2
		 where ir2.effective_date <= p_from_date --'31-DEC-2003' --max(BAB.BALANCE_DATE)
		 and ir2.balance_range_id = ir.BALANCE_RANGE_ID
		)
  ) INTEREST_RATES
 , 'Y' FIRST_ROW
 , rownum
 from
   CE_BANK_ACCT_BALANCES BAB
 --, CE_BANK_ACCOUNTS	BA
 , CE_INTEREST_SCHEDULES  cIS
 , CE_INTEREST_BAL_RANGES	IBR
 WHERE
      cIS.INTEREST_SCHEDULE_ID =  IBR.INTEREST_SCHEDULE_ID
  and cIS.INTEREST_SCHEDULE_ID =  p_interest_schedule_id --10002
  --AND  cIS.INTEREST_SCHEDULE_ID =  ba.INTEREST_SCHEDULE_ID
  --and BA.BANK_ACCOUNT_ID = BAB.BANK_ACCOUNT_ID
  AND BAB.BALANCE_DATE <= p_from_date --'31-DEC-2003'
  and BAB.VALUE_DATED_BALANCE >=  nvl(IBR.FROM_BALANCE_AMOUNT, BAB.VALUE_DATED_BALANCE )
  and BAB.VALUE_DATED_BALANCE <= nvl(IBR.TO_BALANCE_AMOUNT, BAB.VALUE_DATED_BALANCE )
  AND BAB.BANK_ACCOUNT_ID = p_bank_account_id --10001
  group by
  BAB.BANK_ACCOUNT_ID
  , BAB.BALANCE_DATE
  , BAB.VALUE_DATED_BALANCE
  , IBR.BALANCE_RANGE_ID
  , rownum
  having max(BAB.BALANCE_DATE) =  (select max(bab2.balance_date)
					from CE_BANK_ACCT_BALANCES BAB2
					where BAb2.BANK_ACCOUNT_ID = BAB.BANK_ACCOUNT_ID
					and BAB2.BALANCE_DATE <= p_from_date) --'01-May-2004')
 UNION ALL
 select
   BAB.BANK_ACCOUNT_ID
 , BAB.BALANCE_DATE   BALANCE_DATE_FROM
 , BAB.VALUE_DATED_BALANCE
 , IBR.BALANCE_RANGE_ID
 , (select distinct ir.interest_rate
   from  CE_INTEREST_RATES  IR
   where ir.balance_range_id = IBR.BALANCE_RANGE_ID
	and ir.effective_date =
		(select max(ir2.effective_date)
		 from CE_INTEREST_RATES  IR2
		 where ir2.effective_date <= BAB.BALANCE_DATE
		 and ir2.balance_range_id = ir.BALANCE_RANGE_ID
		)
  ) INTEREST_RATES
 , 'N' FIRST_ROW
 , rownum
 from
   CE_BANK_ACCT_BALANCES BAB
 --, CE_BANK_ACCOUNTS	BA
 , CE_INTEREST_SCHEDULES  cIS
 , CE_INTEREST_BAL_RANGES	IBR
 WHERE
     cIS.INTEREST_SCHEDULE_ID =  IBR.INTEREST_SCHEDULE_ID
 and cIS.INTEREST_SCHEDULE_ID =   p_interest_schedule_id --10002
 --AND cIS.INTEREST_SCHEDULE_ID =  ba.INTEREST_SCHEDULE_ID
 --and BA.BANK_ACCOUNT_ID = BAB.BANK_ACCOUNT_ID
 AND BAB.BALANCE_DATE >= p_from_date --'31-DEC-2003'
 AND BAB.BALANCE_DATE <= p_to_date --'31-JAN-2004'
 AND BAB.BALANCE_DATE <> p_from_date --'31-DEC-2003'
 and BAB.VALUE_DATED_BALANCE >=  nvl(IBR.FROM_BALANCE_AMOUNT , BAB.VALUE_DATED_BALANCE )
 and BAB.VALUE_DATED_BALANCE <= nvl(IBR.TO_BALANCE_AMOUNT, BAB.VALUE_DATED_BALANCE )
 AND BAB.BANK_ACCOUNT_ID = p_bank_account_id --10001
 order by  BALANCE_DATE_FROM
 ;



CURSOR interest_info(p_from_date 		date,
			p_to_date 		date,
			p_bank_account_id 	number,
			p_interest_schedule_id 	number,
			p_interest_acct_type 	varchar2) IS
 select distinct
   tmp2.BANK_ACCOUNT_ID
 , IR.EFFECTIVE_DATE
 , tmp2.VALUE_DATED_BALANCE
/* , (select distinct tmp.VALUE_DATED_BALANCE
	from CE_INT_CALC_DETAILS_GT tmp
	where tmp.bank_account_id = bab.bank_account_id
	and tmp.balance_range_id = ir.balance_range_id
	and tmp.INTEREST_SCHEDULE_ID = cis.interest_schedule_id
	and tmp.interest_acct_type = p_interest_acct_type
	and tmp.from_date =
		(select max(tmp2.from_date)
		from CE_INT_CALC_DETAILS_GT tmp2
		where tmp2.from_date < ir.effective_date -- tmp.from_date
		and tmp.bank_account_id = tmp2.bank_account_id
		and tmp2.interest_acct_type = p_interest_acct_type
		)
	)  VALUE_DATED_BALANCE */
 , IR.BALANCE_RANGE_ID
 , IR.INTEREST_RATE
 from
   --CE_BANK_ACCT_BALANCES 	BAB
   CE_INT_CALC_DETAILS_GT 	tmp2  --, CE_BANK_ACCOUNTS		BA
 , CE_INTEREST_SCHEDULES  	CIS
 , CE_INTEREST_BAL_RANGES	IBR
 , CE_INTEREST_RATES		IR
 WHERE
    CIS.INTEREST_SCHEDULE_ID 	=  IBR.INTEREST_SCHEDULE_ID
 AND IBR.BALANCE_RANGE_ID 	= IR.BALANCE_RANGE_ID
 AND IR.EFFECTIVE_DATE 		>= p_from_date --'31-DEC-2003'
 AND IR.EFFECTIVE_DATE 		<=  p_to_date  -- '31-JAN-2004'
 and tmp2.VALUE_DATED_BALANCE 	>=  nvl(IBR.FROM_BALANCE_AMOUNT , tmp2.VALUE_DATED_BALANCE ) --y_int_calc_balance1
 and tmp2.VALUE_DATED_BALANCE 	<= nvl(IBR.TO_BALANCE_AMOUNT, tmp2.VALUE_DATED_BALANCE ) --y_int_calc_balance1
 --and BAB.VALUE_DATED_BALANCE 	>=  nvl(IBR.FROM_BALANCE_AMOUNT , BAB.VALUE_DATED_BALANCE ) --y_int_calc_balance1
 --and BAB.VALUE_DATED_BALANCE 	<= nvl(IBR.TO_BALANCE_AMOUNT, BAB.VALUE_DATED_BALANCE ) --y_int_calc_balance1
 --and p_int_calc_balance 	>=  nvl(IBR.FROM_BALANCE_AMOUNT , p_int_calc_balance )
 --and p_int_calc_balance 	<= nvl(IBR.TO_BALANCE_AMOUNT,p_int_calc_balance )
 --AND BA.BANK_ACCOUNT_ID 	= BAB.BANK_ACCOUNT_ID
 --AND cIS.INTEREST_SCHEDULE_ID =  BA.INTEREST_SCHEDULE_ID
 AND cIS.INTEREST_SCHEDULE_ID 	= p_interest_schedule_id --10002
 --AND BAB.BALANCE_DATE 	>= p_from_date --'31-DEC-2003'
 --AND BAB.BALANCE_DATE 	<= p_to_date --'31-JAN-2004'
 --AND BAB.BANK_ACCOUNT_ID 	= p_bank_account_id  --10001
 AND tmp2.from_DATE 		>=  p_from_date  --'31-DEC-2003'
 AND nvl(tmp2.to_DATE, p_to_date) <= p_to_date --'31-JAN-2004'
 AND tmp2.BANK_ACCOUNT_ID 	= p_bank_account_id  --10001
 AND IR.BALANCE_RANGE_ID 	= tmp2.BALANCE_RANGE_ID
 and tmp2.interest_acct_type 	= p_interest_acct_type
 and  cIS.INTEREST_SCHEDULE_ID 	=  tmp2.INTEREST_SCHEDULE_ID
 and  IR.EFFECTIVE_DATE 	> tmp2.from_date
 and  tmp2.from_date =	(select max(tmp.from_date)
		from CE_INT_CALC_DETAILS_GT tmp
		where tmp.from_date < ir.effective_date
		and tmp.bank_account_id = tmp2.bank_account_id
		and tmp.interest_acct_type = p_interest_acct_type
		)
 and not exists (select tmp.from_date from CE_INT_CALC_DETAILS_GT tmp
		where tmp.from_date = IR.EFFECTIVE_DATE
		and tmp.bank_account_id = tmp2.BANK_ACCOUNT_ID
		and tmp.from_date>=p_from_date --'31-DEC-2003'
		and tmp.from_date<=p_to_date --'31-JAN-2004'
		and tmp.INTEREST_SCHEDULE_ID = p_interest_schedule_id --10002
		and tmp.interest_acct_type = p_interest_acct_type
		)
 and exists (select tmp.balance_range_id from CE_INT_CALC_DETAILS_GT tmp
		where tmp.balance_range_id = IR.BALANCE_RANGE_ID
		and tmp.bank_account_id = tmp2.BANK_ACCOUNT_ID
		and tmp.from_date>=p_from_date --'31-DEC-2003'
		and tmp.from_date<=p_to_date --'31-JAN-2004'
		and tmp.INTEREST_SCHEDULE_ID = p_interest_schedule_id --10002
		and tmp.interest_acct_type = p_interest_acct_type
		)
 ;


CURSOR missing_interest_info(p_from_date date, p_to_date date,
			p_bank_account_id number, p_interest_schedule_id number ) IS
 select ir.interest_rate,
 tmp.from_date,
 tmp.INTEREST_CALC_DETAIL_ID
 from
   CE_INTEREST_BAL_RANGES	IBR
 , ce_interest_rates   ir
 , CE_INT_CALC_DETAILS_GT tmp
 where
   ibr.balance_range_id = ir.balance_range_id
 and nvl(ibr.TO_BALANCE_AMOUNT, tmp.VALUE_DATED_BALANCE) <= tmp.VALUE_DATED_BALANCE
 and tmp.interest_rate is null
 and tmp.interest_schedule_id = p_interest_schedule_id --10741
 and tmp.bank_account_id = p_bank_account_id  --16000
 and tmp.interest_schedule_id = ibr.interest_schedule_id
 and ir.effective_date <= tmp.from_date
 and ir.effective_date = (select max(ir.effective_date)
			  from
			    CE_INTEREST_BAL_RANGES	IBR
			  , ce_interest_rates   ir
			  , CE_INT_CALC_DETAILS_GT tmp2
			  where
			    ibr.balance_range_id = ir.balance_range_id
			  and nvl(ibr.TO_BALANCE_AMOUNT, tmp2.VALUE_DATED_BALANCE) <= tmp.VALUE_DATED_BALANCE
			  and tmp2.interest_rate is null
			  and tmp2.interest_schedule_id = 10741
			  and tmp2.bank_account_id = 16000
			  and tmp2.interest_schedule_id = ibr.interest_schedule_id
			  and ir.effective_date <= tmp2.from_date
			  and tmp2.from_date = tmp.from_date
			 )
 ;

 --CURSOR DR_RANGE(p_from_date date, p_to_date date,
 CURSOR DR_RANGE(p_balance_date_from date, p_balance_date_to date,
			p_bank_account_id number, p_interest_schedule_id number,
			l_amount number ) IS
 select
  nvl(FROM_BALANCE_AMOUNT, l_amount),
  nvl(TO_BALANCE_AMOUNT, 0),
  ir.interest_rate
 from ce_interest_bal_ranges  ibr
 , ce_interest_rates  ir
 where ibr.INTEREST_SCHEDULE_ID =  p_interest_schedule_id
 and  ibr.TO_BALANCE_AMOUNT >=  l_amount
 and  ibr.TO_BALANCE_AMOUNT <= 0
 and ibr.balance_range_id = ir.balance_range_id
  and ir.effective_date=
		(select max(ir2.effective_date)
		 from CE_INTEREST_RATES  IR2
		 where ir2.effective_date <= p_balance_date_from --'31-DEC-2003' --max(BAB.BALANCE_DATE)
		 and ir2.balance_range_id = ir.BALANCE_RANGE_ID)
;

/*  select MIN_AMT,MAX_AMT,nvl(INTEREST_RATE,0)
   from XTR_INTEREST_RATE_RANGES
   where REF_CODE = l_acct
   and PARTY_CODE = l_bank_code
-- and PARTY_CODE = l_setoff_party
   and CURRENCY = L_CURRENCY
   and MAX_AMT >= l_amount
   and MIN_AMT <0
   and EFFECTIVE_FROM_DATE =(select max(EFFECTIVE_FROM_DATE)
                              from XTR_INTEREST_RATE_RANGES
                              where REF_CODE = l_acct
                              and PARTY_CODE = l_bank_code
                            --and PARTY_CODE = l_setoff_party
                              and CURRENCY = L_CURRENCY
                              and MAX_AMT >= l_amount
                              and MIN_AMT <0
                              and EFFECTIVE_FROM_DATE<= L_BALANCE_DATE)
   order by MAX_AMT desc;
*/
--

 --CURSOR CR_RANGE(p_from_date date, p_to_date date,
 CURSOR CR_RANGE(p_balance_date_from date, p_balance_date_to date,
		 p_bank_account_id number, p_interest_schedule_id number,
		 l_amount number ) IS
 select
  nvl(FROM_BALANCE_AMOUNT, -1),
  nvl(TO_BALANCE_AMOUNT, l_amount),
 /*  (select distinct ir.interest_rate
   from  CE_INTEREST_RATES  IR
   where ir.balance_range_id = IBR.BALANCE_RANGE_ID
        and ir.effective_date =
                (select max(ir2.effective_date)
                 from CE_INTEREST_RATES  IR2
                 where ir2.effective_date <= p_balance_date_from --'31-DEC-2003' --max(BAB.BALANCE_DATE)
                 and ir2.balance_range_id = ir.BALANCE_RANGE_ID
                )
  ) INTEREST_RATES*/
 ir.interest_rate
 from ce_interest_bal_ranges  ibr
,    ce_interest_rates  ir
 where ibr.INTEREST_SCHEDULE_ID = p_interest_schedule_id
 and  ibr.FROM_BALANCE_AMOUNT <=  l_amount
 and  ibr.FROM_BALANCE_AMOUNT >= 0
 and ibr.balance_range_id = ir.balance_range_id
 and ir.effective_date=
                (select max(ir2.effective_date)
                 from CE_INTEREST_RATES  IR2
                 where ir2.effective_date <= p_balance_date_from --'31-DEC-2003' --max(BAB.BALANCE_DATE)
                 and ir2.balance_range_id = ir.BALANCE_RANGE_ID)
;

/*  select MIN_AMT,MAX_AMT,nvl(INTEREST_RATE,0)
   from XTR_INTEREST_RATE_RANGES
   where REF_CODE = l_acct
   and PARTY_CODE = l_bank_code
-- and PARTY_CODE = l_setoff_party
   and CURRENCY = L_CURRENCY
   and MIN_AMT <= l_amount
   and MAX_AMT >= 0
   and EFFECTIVE_FROM_DATE =(select max(EFFECTIVE_FROM_DATE)
                              from XTR_INTEREST_RATE_RANGES
                              where REF_CODE = l_acct
                              and PARTY_CODE = l_bank_code
                           -- and PARTY_CODE = l_setoff_party
                              and CURRENCY = L_CURRENCY
                              and MIN_AMT <= l_amount
                              and MAX_AMT >= 0
                              and EFFECTIVE_FROM_DATE<= L_BALANCE_DATE)
   order by MIN_AMT desc;
*/

/* =====================================================================
| Pool cursor                                                           |
|
 --------------------------------------------------------------------- */
CURSOR range_and_rate_cur(p_from_date 		date,
		       p_to_date 		date,
		       p_bank_account_id 	number,
		       p_interest_schedule_id 	number,
		       p_interest_acct_type 	varchar2,
			p_cashpool_id  		number
		      ) IS
select
  tmp.INTEREST_CALC_DETAIL_ID
--, tmp.VALUE_DATED_BALANCE
, IBR.BALANCE_RANGE_ID
--, IR.INTEREST_RATE
 , (select distinct ir.interest_rate
   from  CE_INTEREST_RATES  IR
   where ir.balance_range_id = IBR.BALANCE_RANGE_ID
	and ir.effective_date =
		(select max(ir2.effective_date)
		 from CE_INTEREST_RATES  IR2
		 where ir2.effective_date <= tmp.from_date --p_from_date --max(BAB.BALANCE_DATE)
		 and ir2.balance_range_id = ir.BALANCE_RANGE_ID
		)
  ) INTEREST_RATES
from CE_INT_CALC_DETAILS_GT	tmp
 , CE_INTEREST_BAL_RANGES	IBR
-- , CE_INTEREST_RATES		IR
where tmp.INTEREST_SCHEDULE_ID = p_interest_schedule_id
 and  tmp.INTEREST_SCHEDULE_ID =  IBR.INTEREST_SCHEDULE_ID
-- AND IBR.BALANCE_RANGE_ID = IR.BALANCE_RANGE_ID
 and tmp.VALUE_DATED_BALANCE >=  nvl(IBR.FROM_BALANCE_AMOUNT , tmp.VALUE_DATED_BALANCE )
 and tmp.VALUE_DATED_BALANCE <= nvl(IBR.TO_BALANCE_AMOUNT, tmp.VALUE_DATED_BALANCE )
-- and IR.EFFECTIVE_DATE 	>= p_from_date --'31-DEC-2003'
-- AND IR.EFFECTIVE_DATE 	<=  p_to_date  -- '31-JAN-2004'
 and tmp.BANK_ACCOUNT_ID 	= p_bank_account_id
 and tmp.INTEREST_ACCT_TYPE 	= p_interest_acct_type
 and tmp.cashpool_id 		= p_cashpool_id
 order by tmp.from_date;

 CURSOR balance_pool_info(p_from_date 		date,
			p_to_date 		date,
		       	p_bank_account_id 	number,
		       	p_interest_schedule_id 	number,
			p_interest_acct_type varchar2,
			p_cashpool_id  		number
		      ) IS
 select
   BAB.BANK_ACCOUNT_ID
 , max(BAB.BALANCE_DATE)   BALANCE_DATE_FROM
 , ce_bal_util.get_pool_balance(p_cashpool_id, p_from_date) VALUE_DATED_BALANCE --BAB.VALUE_DATED_BALANCE
 , NULL BALANCE_RANGE_ID --IBR.BALANCE_RANGE_ID
 , NULL INTEREST_RATES
 /*, (select distinct ir.interest_rate
   from  CE_INTEREST_RATES  IR
   where ir.balance_range_id = IBR.BALANCE_RANGE_ID
	and ir.effective_date =
		(select max(ir2.effective_date)
		 from CE_INTEREST_RATES  IR2
		 where ir2.effective_date <= p_from_date --'31-DEC-2003' --max(BAB.BALANCE_DATE)
		 and ir2.balance_range_id = ir.BALANCE_RANGE_ID
		)
  ) INTEREST_RATES*/
 , 'Y' FIRST_ROW
 , rownum
 from
   CE_BANK_ACCT_BALANCES BAB
 --, CE_BANK_ACCOUNTS	BA
 , CE_INTEREST_SCHEDULES  cIS
 --, CE_INTEREST_BAL_RANGES	IBR
 WHERE
      --cIS.INTEREST_SCHEDULE_ID =  IBR.INTEREST_SCHEDULE_ID
   cIS.INTEREST_SCHEDULE_ID =  p_interest_schedule_id --10002
  --AND  cIS.INTEREST_SCHEDULE_ID =  ba.INTEREST_SCHEDULE_ID
  --and BA.BANK_ACCOUNT_ID = BAB.BANK_ACCOUNT_ID
  AND BAB.BALANCE_DATE <= p_from_date --'31-DEC-2003'
  --and BAB.VALUE_DATED_BALANCE >=  nvl(IBR.FROM_BALANCE_AMOUNT, BAB.VALUE_DATED_BALANCE )
  --and BAB.VALUE_DATED_BALANCE <= nvl(IBR.TO_BALANCE_AMOUNT, BAB.VALUE_DATED_BALANCE )
  AND BAB.BANK_ACCOUNT_ID = p_bank_account_id --10001
  and not exists (select tmp.from_date from CE_INT_CALC_DETAILS_GT tmp
		where tmp.from_date = p_from_date --max(BAB.BALANCE_DATE)
		--and tmp.bank_account_id = BAB.BANK_ACCOUNT_ID
		and tmp.from_date>=p_from_date --'31-DEC-2003'
		and tmp.from_date<=p_to_date --'31-JAN-2004'
		and tmp.INTEREST_SCHEDULE_ID = p_interest_schedule_id --10002
		and tmp.interest_acct_type = p_interest_acct_type
		and tmp.cashpool_id = p_cashpool_id
		)
  group by
  BAB.BANK_ACCOUNT_ID
  , BAB.BALANCE_DATE
  , BAB.VALUE_DATED_BALANCE
  --, IBR.BALANCE_RANGE_ID
  , rownum
  having max(BAB.BALANCE_DATE) =  (select max(bab2.balance_date)
					from CE_BANK_ACCT_BALANCES BAB2
					where BAb2.BANK_ACCOUNT_ID = BAB.BANK_ACCOUNT_ID
					and BAB2.BALANCE_DATE <= p_from_date) --'01-May-2004')
 UNION ALL
 select
   BAB.BANK_ACCOUNT_ID
 , BAB.BALANCE_DATE   --BALANCE_DATE_FROM
 , ce_bal_util.get_pool_balance(p_cashpool_id, BAB.BALANCE_DATE) --VALUE_DATED_BALANCE --BAB.VALUE_DATED_BALANCE
 , NULL BALANCE_RANGE_ID --IBR.BALANCE_RANGE_ID
 , NULL INTEREST_RATES
/* , (select distinct ir.interest_rate
   from  CE_INTEREST_RATES  IR
   where ir.balance_range_id = IBR.BALANCE_RANGE_ID
	and ir.effective_date =
		(select max(ir2.effective_date)
		 from CE_INTEREST_RATES  IR2
		 where ir2.effective_date <= BAB.BALANCE_DATE
		 and ir2.balance_range_id = ir.BALANCE_RANGE_ID
		)
  ) INTEREST_RATES*/
 , 'N' FIRST_ROW
 , rownum
 from
   CE_BANK_ACCT_BALANCES BAB
 --, CE_BANK_ACCOUNTS	BA
 , CE_INTEREST_SCHEDULES  cIS
 --, CE_INTEREST_BAL_RANGES	IBR
 WHERE
     --cIS.INTEREST_SCHEDULE_ID =  IBR.INTEREST_SCHEDULE_ID
  cIS.INTEREST_SCHEDULE_ID =   p_interest_schedule_id --10002
 --AND cIS.INTEREST_SCHEDULE_ID =  ba.INTEREST_SCHEDULE_ID
 --and BA.BANK_ACCOUNT_ID = BAB.BANK_ACCOUNT_ID
 AND BAB.BALANCE_DATE >= p_from_date --'31-DEC-2003'
 AND BAB.BALANCE_DATE <= p_to_date --'31-JAN-2004'
 AND BAB.BALANCE_DATE <> p_from_date --'31-DEC-2003'
 --and BAB.VALUE_DATED_BALANCE >=  nvl(IBR.FROM_BALANCE_AMOUNT , BAB.VALUE_DATED_BALANCE )
 --and BAB.VALUE_DATED_BALANCE <= nvl(IBR.TO_BALANCE_AMOUNT, BAB.VALUE_DATED_BALANCE )
 AND BAB.BANK_ACCOUNT_ID = p_bank_account_id --10001
 and not exists (select tmp.from_date from CE_INT_CALC_DETAILS_GT tmp
		where tmp.from_date = BAB.BALANCE_DATE
		--and tmp.bank_account_id = BAB.BANK_ACCOUNT_ID
		and tmp.from_date>=p_from_date --'31-DEC-2003'
		and tmp.from_date<=p_to_date --'31-JAN-2004'
		and tmp.INTEREST_SCHEDULE_ID = p_interest_schedule_id --10002
		and tmp.interest_acct_type = p_interest_acct_type
		and tmp.cashpool_id = p_cashpool_id
		)
 order by  BALANCE_DATE_FROM
 ;


CURSOR interest_pool_info(p_from_date 		date,
			p_to_date 		date,
			p_bank_account_id 	number,
			p_interest_schedule_id 	number,
			p_interest_acct_type 	varchar2,
			p_cashpool_id  		number) IS
 select distinct
   tmpx.BANK_ACCOUNT_ID
 , IR.EFFECTIVE_DATE
 , tmpx.VALUE_DATED_BALANCE
 /* , (select distinct tmp.VALUE_DATED_BALANCE
	from CE_INT_CALC_DETAILS_GT tmp
	where tmp.bank_account_id = tmpx.bank_account_id
	and tmp.balance_range_id = ir.balance_range_id
	and tmp.INTEREST_SCHEDULE_ID = cis.interest_schedule_id
	and tmp.interest_acct_type = p_interest_acct_type
	and tmp.cashpool_id = p_cashpool_id
	and tmp.from_date =
		(select max(tmp2.from_date)
		from CE_INT_CALC_DETAILS_GT tmp2
		where tmp2.from_date < ir.effective_date -- tmp.from_date
		and tmp.bank_account_id = tmp2.bank_account_id
		and tmp2.interest_acct_type = p_interest_acct_type
		and tmp2.cashpool_id = p_cashpool_id
		)
	)  VALUE_DATED_BALANCE*/
 , IR.BALANCE_RANGE_ID
 , IR.INTEREST_RATE
 from
  -- CE_BANK_ACCT_BALANCES 	BAB
 --, CE_BANK_ACCOUNTS		BA
  CE_INTEREST_SCHEDULES  	cIS
 , CE_INTEREST_BAL_RANGES	IBR
 , CE_INTEREST_RATES		IR
 , CE_INT_CALC_DETAILS_GT tmpx
 WHERE
    cIS.INTEREST_SCHEDULE_ID =  IBR.INTEREST_SCHEDULE_ID
 AND IBR.BALANCE_RANGE_ID = IR.BALANCE_RANGE_ID
 and  IR.EFFECTIVE_DATE >= p_from_date --'31-DEC-2003'
 AND IR.EFFECTIVE_DATE <=  p_to_date  -- '31-JAN-2004'
 and tmpx.VALUE_DATED_BALANCE >=  nvl(IBR.FROM_BALANCE_AMOUNT , tmpx.VALUE_DATED_BALANCE ) --y_int_calc_balance1
 and tmpx.VALUE_DATED_BALANCE <= nvl(IBR.TO_BALANCE_AMOUNT, tmpx.VALUE_DATED_BALANCE ) --y_int_calc_balance1
 --and BAB.VALUE_DATED_BALANCE >=  nvl(IBR.FROM_BALANCE_AMOUNT , BAB.VALUE_DATED_BALANCE ) --y_int_calc_balance1
 --and BAB.VALUE_DATED_BALANCE <= nvl(IBR.TO_BALANCE_AMOUNT, BAB.VALUE_DATED_BALANCE ) --y_int_calc_balance1
 --and p_int_calc_balance >=  nvl(IBR.FROM_BALANCE_AMOUNT , p_int_calc_balance )
 --and p_int_calc_balance <= nvl(IBR.TO_BALANCE_AMOUNT,p_int_calc_balance )
 --AND BA.BANK_ACCOUNT_ID = BAB.BANK_ACCOUNT_ID
 --AND cIS.INTEREST_SCHEDULE_ID =  BA.INTEREST_SCHEDULE_ID
 AND cIS.INTEREST_SCHEDULE_ID = p_interest_schedule_id --10002
 --AND BAB.BALANCE_DATE >= p_from_date --'31-DEC-2003'
 --AND BAB.BALANCE_DATE <= p_to_date --'31-JAN-2004'
 --AND BAB.BANK_ACCOUNT_ID = p_bank_account_id  --10001
 AND tmpx.BANK_ACCOUNT_ID = p_bank_account_id  --10001
 AND tmpx.from_DATE 		>=  p_from_date  --'31-DEC-2003'
 AND nvl(tmpx.to_DATE, p_to_date) <= p_to_date --'31-JAN-2004'
 AND IR.BALANCE_RANGE_ID 	= tmpx.BALANCE_RANGE_ID
 and tmpx.interest_acct_type 	= p_interest_acct_type
 and  CIS.INTEREST_SCHEDULE_ID 	=  tmpx.INTEREST_SCHEDULE_ID
 and  IR.EFFECTIVE_DATE 	> tmpx.from_date
 and  tmpx.from_date =	(select max(tmp.from_date)
		from CE_INT_CALC_DETAILS_GT tmp
		where tmp.from_date < ir.effective_date
		and tmp.bank_account_id = tmpx.bank_account_id
		and tmp.interest_acct_type = p_interest_acct_type
		)
and not exists (select tmp.from_date from CE_INT_CALC_DETAILS_GT tmp
		where tmp.from_date = IR.EFFECTIVE_DATE
		and tmp.bank_account_id = tmpx.BANK_ACCOUNT_ID
		--and tmp.bank_account_id = BAB.BANK_ACCOUNT_ID
		and tmp.from_date>=p_from_date --'31-DEC-2003'
		and tmp.from_date<=p_to_date --'31-JAN-2004'
		and tmp.INTEREST_SCHEDULE_ID = p_interest_schedule_id --10002
		and tmp.interest_acct_type = p_interest_acct_type
		)
 and exists (select tmp.balance_range_id from CE_INT_CALC_DETAILS_GT tmp
		where tmp.balance_range_id = IR.BALANCE_RANGE_ID
		and tmp.bank_account_id = tmpx.BANK_ACCOUNT_ID
		--and tmp.bank_account_id = BAB.BANK_ACCOUNT_ID
		and tmp.from_date>=p_from_date --'31-DEC-2003'
		and tmp.from_date<=p_to_date --'31-JAN-2004'
		and tmp.INTEREST_SCHEDULE_ID = p_interest_schedule_id --10002
		and tmp.interest_acct_type = p_interest_acct_type
		)
 ;


/* --------------------------------------------------------------------
|  PRIVATE Function                                                     |
|      ROUNDUP			                                        |
|                                                                       |
|  CALLED BY                                                            |
|      calculate_interest                                               |
|                                                                       |
|  DESCRIPTION                                                          |
|      Function uses for rounding up an amount				|
|        							        |
|  RETURN      					                        |
|     NUMBER   					                        |
 --------------------------------------------------------------------- */
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

/* --------------------------------------------------------------------
|  PRIVATE Function                                                     |
|      IsLeapYear		                                        |
|                                                                       |
|  CALLED BY                                                            |
|      calculate_interest                                               |
|                                                                       |
|  DESCRIPTION                                                          |
|      Function uses to check if the year is in a leap year		|
|        - use to determine how many days are in that year              |
|  RETURN      					                        |
|     Boolean  					                        |
 --------------------------------------------------------------------- */
Function IsLeapYear(dDate number) RETURN Boolean IS
IsLeapYear  varchar2(10);

BEGIN

select decode( mod(dDate, 4), 0,
          decode( mod(dDate, 400), 0, 'TRUE',
             decode( mod(dDate, 100), 0, 'FALSE', 'TRUE')
          ), 'FALSE'
       )
into IsLeapYear
from   dual;

IF (IsLeapYear = 'FALSE')  THEN
	return(FALSE);
ELSE
	return(TRUE);

END IF;

End IsLeapYear;

/*=======================================================================+
| PUBLIC FUNCTION get_interest_rate                                     |
|                                                                       |
| DESCRIPTION                                                           |
|   Get interest rate                                                   |
| EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
|                                                                       |
| ARGUMENTS                                                             |
|   IN:                                                                 |
|     p_bank_account_id, p_balance_date, P_balance_amount 		   |
|   OUT:                                                                |
|     P_INTEREST_RATE                                                   |
 +=======================================================================*/
 FUNCTION get_interest_rate( p_bank_account_id IN NUMBER,
				p_balance_date   IN DATE,
				p_balance_amount IN NUMBER,
				p_interest_rate  IN OUT NOCOPY NUMBER ) RETURN NUMBER IS

 BEGIN
   IF l_DEBUG in ('Y', 'C') THEN
	  cep_standard.debug('>> CE_INTEREST_CALC.get_interest_rate');
   END IF;

   BEGIN
     IF (p_balance_amount > 0)  THEN
       select  ir.interest_rate
       into   p_interest_rate
       from
         CE_BANK_ACCOUNTS	BA
       , CE_INTEREST_SCHEDULES  cIS
       , CE_INTEREST_BAL_RANGES	IBR
       , CE_INTEREST_RATES  IR
       WHERE
          BA.BANK_ACCOUNT_ID = p_bank_account_id --10001
        AND cIS.INTEREST_SCHEDULE_ID =  BA.INTEREST_SCHEDULE_ID
        AND cIS.INTEREST_SCHEDULE_ID =  IBR.INTEREST_SCHEDULE_ID
        and IBR.FROM_BALANCE_AMOUNT  <= p_balance_amount
	and IBR.FROM_BALANCE_AMOUNT > 0
        and nvl(IBR.TO_BALANCE_AMOUNT, p_balance_amount ) >= p_balance_amount
        and ir.balance_range_id = IBR.BALANCE_RANGE_ID
        and ir.effective_date  =
		(select max(ir2.effective_date)
		 from CE_INTEREST_RATES  IR2
		 where ir2.effective_date <= p_balance_date --'31-DEC-2003'
		 and ir2.balance_range_id = ir.BALANCE_RANGE_ID
		) ;
     ELSE
       select  ir.interest_rate
       into   p_interest_rate
       from
         CE_BANK_ACCOUNTS	BA
       , CE_INTEREST_SCHEDULES  cIS
       , CE_INTEREST_BAL_RANGES	IBR
       , CE_INTEREST_RATES  IR
       WHERE
          BA.BANK_ACCOUNT_ID = p_bank_account_id --10001
        AND cIS.INTEREST_SCHEDULE_ID =  BA.INTEREST_SCHEDULE_ID
        AND cIS.INTEREST_SCHEDULE_ID =  IBR.INTEREST_SCHEDULE_ID
        and nvl(IBR.FROM_BALANCE_AMOUNT, p_balance_amount ) <= p_balance_amount
        and IBR.TO_BALANCE_AMOUNT >= p_balance_amount
        and IBR.TO_BALANCE_AMOUNT <= 0
        and ir.balance_range_id = IBR.BALANCE_RANGE_ID
        and ir.effective_date  =
		(select max(ir2.effective_date)
		 from CE_INTEREST_RATES  IR2
		 where ir2.effective_date <= p_balance_date --'31-DEC-2003'
		 and ir2.balance_range_id = ir.BALANCE_RANGE_ID
		) ;
     END IF;
    EXCEPTION
      WHEN no_data_found THEN
       p_interest_rate := NULL;
      WHEN TOO_MANY_ROWS THEN
       p_interest_rate := NULL;

    END;
    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('CE_INTEREST_CALC.get_interest_rate p_interest_rate '||p_interest_rate);
    END IF;

    RETURN p_interest_rate;

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('<< CE_INTEREST_CALC.get_interest_rate ');
    END IF;

EXCEPTION
	WHEN OTHERS THEN
  	cep_standard.debug('EXCEPTION: get_interest_rate');
  	RAISE;
END get_interest_rate;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      delete_schedule_account	                                        |
|                                                                       |
|  CALLED BY                                                            |
|      int_cal_detail_main                                              |
|                                                                       |
|  DESCRIPTION                                                          |
|      Delete accounts from 						|
|        CE_INT_CALC_DETAILS_GT		                        |
 --------------------------------------------------------------------- */
PROCEDURE  delete_schedule_account( p_interest_schedule_id 	number,
				    p_bank_account_id 		number,
 				    p_interest_acct_type 	varchar2,
				    p_cashpool_id  	   number
				    )  IS
 x_balance_date_from 	DATE;
 x_balance_date_to 	DATE;
 x_bank_account_id  	NUMBER;
 x_int_calc_balance  	NUMBER;
 x_balance_range_id	NUMBER;
 x_days 	 	NUMBER;
 x_first_row 	 	varchar2(1);
 x_rownum 	 	NUMBER;
 x_interest_rate 	NUMBER;

 y_balance_date_from 	DATE;
 y_balance_date_to 	DATE;
 y_bank_account_id  	NUMBER;
 y_int_calc_balance  	NUMBER;
 y_balance_range_id	NUMBER;
 y_days 	 	NUMBER;
 y_rownum 	 	NUMBER;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('>> CE_INTEREST_CALC.delete_schedule_account');
  END IF;

  -- bug 5493399
  --IF (p_interest_acct_type = 'BANK_ACCOUNT') THEN
  IF (p_interest_acct_type in ('BANK_ACCOUNT', 'TREASURY')) THEN
    IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('delete p_interest_acct_type BANK_ACCOUNT');
    END IF;
    DELETE CE_INT_CALC_DETAILS_GT
    WHERE INTEREST_SCHEDULE_ID 	= p_interest_schedule_id
    and  BANK_ACCOUNT_ID	= p_bank_account_id
    AND INTEREST_ACCT_TYPE 	= p_interest_acct_type;
  ELSIF (p_interest_acct_type = 'NOTIONAL') THEN
    IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('delete p_interest_acct_type NOTIONAL');
    END IF;
    DELETE CE_INT_CALC_DETAILS_GT
    WHERE INTEREST_SCHEDULE_ID 	= p_interest_schedule_id
    --and  BANK_ACCOUNT_ID	= p_bank_account_id
    AND CASHPOOL_ID 		= p_cashpool_id
    AND INTEREST_ACCT_TYPE 	= p_interest_acct_type;
  END IF;


  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('<< CE_INTEREST_CALC.delete_schedule_account');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_INTEREST_CALC.delete_schedule_account');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_CALC.delete_schedule_account');
    fnd_msg_pub.add;
END delete_schedule_account;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      get_balance_info		                                        |
|                                                                       |
|  CALLED BY                                                            |
|      int_cal_detail_main                                              |
|                                                                       |
|  DESCRIPTION                                                          |
|      Get Interest Calculated balances information and insert in       |
|        CE_INT_CALC_DETAILS_GT		                        |
 --------------------------------------------------------------------- */
PROCEDURE  get_balance_info(  p_from_date 		date,
				p_to_date 		date,
				p_interest_schedule_id 	number,
				p_bank_account_id 	number,
 				p_interest_acct_type 	varchar2,
				p_cashpool_id  		number,
				p_row_count OUT NOCOPY  NUMBER)  IS
 x_balance_date_from 	DATE;
 x_balance_date_to 	DATE;
 x_bank_account_id  	NUMBER;
 x_int_calc_balance  	NUMBER;
 x_balance_range_id	NUMBER;
 x_days 	 	NUMBER;
 x_first_row 	 	varchar2(1);
 x_rownum 	 	NUMBER;
 x_interest_rate 	NUMBER;

 y_balance_date_from 	DATE;
 y_balance_date_to 	DATE;
 y_bank_account_id  	NUMBER;
 y_int_calc_balance  	NUMBER;
 y_balance_range_id	NUMBER;
 y_days 	 	NUMBER;
 y_rownum 	 	NUMBER;
 y_first_row 	 	varchar2(1);
 y_record_from 	 	varchar2(15);
 y_row_count 	 	NUMBER;
 y_interest_rate 	NUMBER;


BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('>> CE_INTEREST_CALC.get_balance_info');
  END IF;

    OPEN balance_info (p_from_date, p_to_date,p_bank_account_id, p_interest_schedule_id );
    LOOP
      FETCH balance_info  INTO x_bank_account_id ,
                             x_balance_date_from,
                             x_int_calc_balance ,
                             x_balance_range_id,
                             x_interest_rate,
                             x_first_row,
                             x_rownum;


      EXIT WHEN balance_info%NOTFOUND OR balance_info%NOTFOUND IS NULL;

      y_bank_account_id 	:= x_bank_account_id;
      y_balance_date_from       := x_balance_date_from;
      y_balance_range_id        := x_balance_range_id;
      y_int_calc_balance        := x_int_calc_balance;
      y_interest_rate           := x_interest_rate;
      y_rownum                  := x_rownum;
      y_first_row               := x_first_row;
      y_record_from := 'BALANCE';


      IF (x_first_row = 'Y')  THEN
	   y_balance_date_from  := p_from_date;
      END IF;


      IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('y_bank_account_id = '||  y_bank_account_id);
  	 cep_standard.debug('y_balance_date_from = '||  y_balance_date_from);
   	 cep_standard.debug('y_int_calc_balance = '||  y_int_calc_balance);
   	 cep_standard.debug('y_interest_rate = '|| y_interest_rate);
   	 cep_standard.debug('y_first_row = '|| y_first_row);
    	 cep_standard.debug('y_record_from = '||  y_record_from);
      END IF;
	 insert into CE_INT_CALC_DETAILS_GT
		 (INTEREST_CALC_DETAIL_ID,
		  INTEREST_SCHEDULE_ID, BANK_ACCOUNT_ID,  FROM_DATE, TO_DATE,
		  VALUE_DATED_BALANCE, NUMBER_OF_DAYS , INTEREST_AMOUNT,INTEREST_RATE,
		  BALANCE_RANGE_ID, RECORD_FROM,
		  INTEREST_ACCT_TYPE, CASHPOOL_ID,
		  LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,  CREATED_BY,
		  LAST_UPDATE_LOGIN)
	 values
		( CE_INT_CALC_DETAILS_GT_S.nextval,
		  p_interest_schedule_id, p_bank_account_id, y_balance_date_from, null,
		  y_int_calc_balance, null, null, y_interest_rate,
		  y_balance_range_id, y_record_from,
		  p_interest_acct_type, p_cashpool_id,
		  sysdate, -1, sysdate, -1, null);

      IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('insert into CE_INT_CALC_DETAILS_GT completed  ');
      END IF;
    END LOOP; --balance_info
    p_row_count := balance_info%ROWCOUNT;
      IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('p_row_count  = '||  p_row_count );
      END IF;

    CLOSE balance_info;


  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('<< CE_INTEREST_CALC.get_balance_info');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_INTEREST_CALC.get_balance_info');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_CALC.get_balance_info');
    fnd_msg_pub.add;
END get_balance_info;
/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      get_balance_pool_info		                                |
|                                                                       |
|  CALLED BY                                                            |
|      int_cal_detail_main                                              |
|                                                                       |
|  DESCRIPTION                                                          |
|      Get Interest Calculated balances information and insert in       |
|        CE_INT_CALC_DETAILS_GT		                        |
 --------------------------------------------------------------------- */
PROCEDURE  get_balance_pool_info(  p_from_date 		date,
				p_to_date 		date,
				p_interest_schedule_id 	number,
				p_bank_account_id 	number,
 				p_interest_acct_type 	varchar2,
				p_cashpool_id  		number,
				p_row_count OUT NOCOPY  NUMBER)  IS
 x_balance_date_from 	DATE;
 x_balance_date_to 	DATE;
 x_bank_account_id  	NUMBER;
 x_int_calc_balance  	NUMBER;
 x_balance_range_id	NUMBER;
 x_days 	 	NUMBER;
 x_first_row 	 	varchar2(1);
 x_rownum 	 	NUMBER;
 x_interest_rate 	NUMBER;

 y_balance_date_from 	DATE;
 y_balance_date_to 	DATE;
 y_bank_account_id  	NUMBER;
 y_int_calc_balance  	NUMBER;
 y_balance_range_id	NUMBER;
 y_days 	 	NUMBER;
 y_rownum 	 	NUMBER;
 y_first_row 	 	varchar2(1);
 y_record_from 	 	varchar2(15);
 y_row_count 	 	NUMBER;
 y_interest_rate 	NUMBER;


BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('>> CE_INTEREST_CALC.get_balance_pool_info');
  END IF;

    OPEN balance_pool_info (p_from_date, p_to_date,p_bank_account_id, p_interest_schedule_id,
				 p_interest_acct_type, p_cashpool_id  );
    LOOP
      FETCH balance_pool_info  INTO x_bank_account_id ,
                             x_balance_date_from,
                             x_int_calc_balance ,
                             x_balance_range_id,
                             x_interest_rate,
                             x_first_row,
                             x_rownum;


      EXIT WHEN balance_pool_info%NOTFOUND OR balance_pool_info%NOTFOUND IS NULL;

      y_bank_account_id 	:= x_bank_account_id;
      y_balance_date_from       := x_balance_date_from;
      y_balance_range_id        := x_balance_range_id;
      y_int_calc_balance        := x_int_calc_balance;
      y_interest_rate           := x_interest_rate;
      y_rownum                  := x_rownum;
      y_first_row               := x_first_row;
      y_record_from := 'BALANCE';


      IF (x_first_row = 'Y')  THEN
	   y_balance_date_from  := p_from_date;
      END IF;


      IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('y_bank_account_id = '||  y_bank_account_id);
  	 cep_standard.debug('y_balance_date_from = '||  y_balance_date_from);
   	 cep_standard.debug('y_int_calc_balance = '||  y_int_calc_balance);
   	 cep_standard.debug('y_interest_rate = '|| y_interest_rate);
   	 cep_standard.debug('y_first_row = '|| y_first_row);
    	 cep_standard.debug('y_record_from = '||  y_record_from);
      END IF;
	 insert into CE_INT_CALC_DETAILS_GT
		 (INTEREST_CALC_DETAIL_ID,
		  INTEREST_SCHEDULE_ID, BANK_ACCOUNT_ID,  FROM_DATE, TO_DATE,
		  VALUE_DATED_BALANCE, NUMBER_OF_DAYS , INTEREST_AMOUNT,INTEREST_RATE,
		  BALANCE_RANGE_ID, RECORD_FROM,
		  INTEREST_ACCT_TYPE, CASHPOOL_ID,
		  LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,  CREATED_BY,
		  LAST_UPDATE_LOGIN)
	 values
		( CE_INT_CALC_DETAILS_GT_S.nextval,
		  p_interest_schedule_id, p_bank_account_id, y_balance_date_from, null,
		  y_int_calc_balance, null, null, y_interest_rate,
		  y_balance_range_id, y_record_from,
		  p_interest_acct_type, p_cashpool_id,
		  sysdate, -1, sysdate, -1, null);

      IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('insert into CE_INT_CALC_DETAILS_GT completed  ');
      END IF;
    END LOOP; --balance_pool_info
    p_row_count := balance_pool_info%ROWCOUNT;
      IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('p_row_count  = '||  p_row_count );
      END IF;

    CLOSE balance_pool_info;


  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('<< CE_INTEREST_CALC.get_balance_pool_info');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_INTEREST_CALC.get_balance_pool_info');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_CALC.get_balance_pool_info');
    fnd_msg_pub.add;
END get_balance_pool_info;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      get_interest_info	                                        |
|                                                                       |
|  CALLED BY                                                            |
|      int_cal_detail_main                                              |
|                                                                       |
|  DESCRIPTION                                                          |
|      Some Interest Calculated balances that are returned from         |
|        get_balance_info might have interest rate changes within the   |
|        same balance. This procedure is used to handle the additional  |
|        break down of the from/to date range with same balance, but    |
|        difference interest rate.                                      |
|                                                                       |
|                                                                       |
 --------------------------------------------------------------------- */
PROCEDURE  get_interest_info(  p_from_date 		date,
				p_to_date 		date,
				p_interest_schedule_id 	number,
				p_bank_account_id 	number,
 				p_interest_acct_type 	varchar2,
				p_cashpool_id  		number,
				p_row_count OUT NOCOPY  NUMBER)  IS
 x_balance_date_from 	DATE;
 x_balance_date_to 	DATE;
 x_bank_account_id  	NUMBER;
 x_int_calc_balance  	NUMBER;
 x_balance_range_id	NUMBER;
 x_days 	 	NUMBER;
 x_first_row 	 	varchar2(1);
 x_rownum 	 	NUMBER;
 x_interest_rate 	NUMBER;

 y_balance_date_from 	DATE;
 y_balance_date_to 	DATE;
 y_bank_account_id  	NUMBER;
 y_int_calc_balance  	NUMBER;
 y_balance_range_id	NUMBER;
 y_days 	 	NUMBER;
 y_rownum 	 	NUMBER;
 y_first_row 	 	varchar2(1);
 y_record_from 	 	varchar2(15);
 y_row_count 	 	NUMBER;
 y_interest_rate 	NUMBER;

BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('>> CE_INTEREST_CALC.get_interest_info');
  END IF;

    OPEN interest_info (p_from_date, p_to_date, p_bank_account_id, p_interest_schedule_id, p_interest_acct_type    );
    LOOP
      FETCH interest_info  INTO x_bank_account_id ,
                             x_balance_date_from,
                             x_int_calc_balance ,
                             x_balance_range_id,
                             x_interest_rate;



      EXIT WHEN interest_info%NOTFOUND OR interest_info%NOTFOUND IS NULL;

      y_bank_account_id 	:= x_bank_account_id;
      y_balance_date_from       := x_balance_date_from;
      y_balance_range_id        := x_balance_range_id;
      y_int_calc_balance        := x_int_calc_balance;
      y_interest_rate           := x_interest_rate;

      --y_rownum                  := x_rownum;
      --y_first_row               := x_first_row;
      y_record_from := 'INTEREST';

      IF (x_first_row = 'Y')  THEN
	   y_balance_date_from       := p_from_date;
      END IF;


      IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('y_bank_account_id = '||  y_bank_account_id);
  	 cep_standard.debug('y_balance_date_from = '||  y_balance_date_from);
   	 cep_standard.debug('y_int_calc_balance = '||  y_int_calc_balance);
   	 cep_standard.debug('y_balance_range_id = '||  y_balance_range_id);
   	 cep_standard.debug('y_interest_rate   = '||  y_interest_rate  );

      END IF;
	 insert into CE_INT_CALC_DETAILS_GT
		 (INTEREST_CALC_DETAIL_ID,
		  INTEREST_SCHEDULE_ID, BANK_ACCOUNT_ID,  FROM_DATE, TO_DATE,
		  VALUE_DATED_BALANCE, NUMBER_OF_DAYS , INTEREST_AMOUNT,INTEREST_RATE,
		  BALANCE_RANGE_ID, RECORD_FROM,
		  INTEREST_ACCT_TYPE, CASHPOOL_ID,
		  LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,  CREATED_BY,
		  LAST_UPDATE_LOGIN)
	 values
		( CE_INT_CALC_DETAILS_GT_S.nextval,
		  p_interest_schedule_id, p_bank_account_id, y_balance_date_from, null,
		  y_int_calc_balance, null, null, y_interest_rate,
		  y_balance_range_id, y_record_from,
		  p_interest_acct_type, p_cashpool_id,
		  sysdate, -1, sysdate, -1, null);

    END LOOP; --interest_info
    p_row_count := interest_info%ROWCOUNT;
      IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('p_row_count  = '||  p_row_count );
      END IF;

    CLOSE interest_info;


  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('<< CE_INTEREST_CALC.get_interest_info');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_INTEREST_CALC.get_interest_info');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_CALC.get_interest_info');
    fnd_msg_pub.add;

END get_interest_info;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      get_interest_pool_info	                                        |
|                                                                       |
|  CALLED BY                                                            |
|      int_cal_detail_main                                              |
|                                                                       |
|  DESCRIPTION                                                          |
|      Some Interest Calculated balances that are returned from         |
|        get_balance_info might have interest rate changes within the   |
|        same balance. This procedure is used to handle the additional  |
|        break down of the from/to date range with same balance, but    |
|        difference interest rate.                                      |
|                                                                       |
|                                                                       |
 --------------------------------------------------------------------- */
PROCEDURE  get_interest_pool_info(  p_from_date 		date,
				p_to_date 		date,
				p_interest_schedule_id 	number,
				p_bank_account_id 	number,
 				p_interest_acct_type 	varchar2,
				p_cashpool_id  		number,
				p_row_count OUT NOCOPY  NUMBER)  IS
 x_balance_date_from 	DATE;
 x_balance_date_to 	DATE;
 x_bank_account_id  	NUMBER;
 x_int_calc_balance  	NUMBER;
 x_balance_range_id	NUMBER;
 x_days 	 	NUMBER;
 x_first_row 	 	varchar2(1);
 x_rownum 	 	NUMBER;
 x_interest_rate 	NUMBER;

 y_balance_date_from 	DATE;
 y_balance_date_to 	DATE;
 y_bank_account_id  	NUMBER;
 y_int_calc_balance  	NUMBER;
 y_balance_range_id	NUMBER;
 y_days 	 	NUMBER;
 y_rownum 	 	NUMBER;
 y_first_row 	 	varchar2(1);
 y_record_from 	 	varchar2(15);
 y_row_count 	 	NUMBER;
 y_interest_rate 	NUMBER;

BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('>> CE_INTEREST_CALC.get_interest_pool_info');
  END IF;

    OPEN interest_pool_info (p_from_date, p_to_date, p_bank_account_id, p_interest_schedule_id,
				 p_interest_acct_type, p_cashpool_id  );
    LOOP
      FETCH interest_pool_info  INTO x_bank_account_id ,
                             x_balance_date_from,
                             x_int_calc_balance ,
                             x_balance_range_id,
                             x_interest_rate;



      EXIT WHEN interest_pool_info%NOTFOUND OR interest_pool_info%NOTFOUND IS NULL;

      y_bank_account_id 	:= x_bank_account_id;
      y_balance_date_from       := x_balance_date_from;
      y_balance_range_id        := x_balance_range_id;
      y_int_calc_balance        := x_int_calc_balance;
      y_interest_rate           := x_interest_rate;

      --y_rownum                  := x_rownum;
      --y_first_row               := x_first_row;
      y_record_from := 'INTEREST';

      IF (x_first_row = 'Y')  THEN
	   y_balance_date_from       := p_from_date;
      END IF;


      IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('y_bank_account_id = '||  y_bank_account_id);
  	 cep_standard.debug('y_balance_date_from = '||  y_balance_date_from);
   	 cep_standard.debug('y_int_calc_balance = '||  y_int_calc_balance);
   	 cep_standard.debug('y_balance_range_id = '||  y_balance_range_id);
   	 cep_standard.debug('y_interest_rate   = '||  y_interest_rate  );

      END IF;
	 insert into CE_INT_CALC_DETAILS_GT
		 (INTEREST_CALC_DETAIL_ID,
		  INTEREST_SCHEDULE_ID, BANK_ACCOUNT_ID,  FROM_DATE, TO_DATE,
		  VALUE_DATED_BALANCE, NUMBER_OF_DAYS , INTEREST_AMOUNT,INTEREST_RATE,
		  BALANCE_RANGE_ID, RECORD_FROM,
		  INTEREST_ACCT_TYPE, CASHPOOL_ID,
		  LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,  CREATED_BY,
		  LAST_UPDATE_LOGIN)
	 values
		( CE_INT_CALC_DETAILS_GT_S.nextval,
		  p_interest_schedule_id, p_bank_account_id, y_balance_date_from, null,
		  y_int_calc_balance, null, null, y_interest_rate,
		  y_balance_range_id, y_record_from,
		  p_interest_acct_type, p_cashpool_id,
		  sysdate, -1, sysdate, -1, null);

    END LOOP; --interest_pool_info
    p_row_count := interest_pool_info%ROWCOUNT;
      IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('p_row_count  = '||  p_row_count );
      END IF;

    CLOSE interest_pool_info;


  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('<< CE_INTEREST_CALC.get_interest_pool_info');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_INTEREST_CALC.get_interest_pool_info');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_CALC.get_interest_pool_info');
    fnd_msg_pub.add;

END get_interest_pool_info;


PROCEDURE  get_missing_interest_info(  p_from_date date,
				p_to_date date,
				p_interest_schedule_id number,
				p_bank_account_id number,
				p_row_count OUT NOCOPY  NUMBER)  IS
 x_balance_date_from 	DATE;
 x_balance_date_to 	DATE;
 x_bank_account_id  	NUMBER;
 x_int_calc_balance  	NUMBER;
 x_balance_range_id	NUMBER;
 x_days 	 	NUMBER;
 x_first_row 	 	varchar2(1);
 x_rownum 	 	NUMBER;
 x_interest_rate 	NUMBER;

 y_balance_date_from 	DATE;
 y_balance_date_to 	DATE;
 y_bank_account_id  	NUMBER;
 y_int_calc_balance  	NUMBER;
 y_balance_range_id	NUMBER;
 y_days 	 	NUMBER;
 y_rownum 	 	NUMBER;
 y_first_row 	 	varchar2(1);
 y_record_from 	 	varchar2(15);
 y_row_count 	 	NUMBER;
 y_interest_rate 	NUMBER;
 x_interest_calc_detail_id 	number;
 y_interest_calc_detail_id 	number;

BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('>> CE_INTEREST_CALC.get_interest_info');
  END IF;

    OPEN missing_interest_info (p_from_date, p_to_date,p_bank_account_id, p_interest_schedule_id );
    LOOP
      FETCH missing_interest_info  INTO x_interest_rate,
	                             	x_balance_date_from,
					x_interest_calc_detail_id;

      EXIT WHEN missing_interest_info%NOTFOUND OR missing_interest_info%NOTFOUND IS NULL;

      y_balance_date_from       := x_balance_date_from;
      y_interest_rate           := x_interest_rate;
      y_interest_calc_detail_id := x_interest_calc_detail_id;

      --y_rownum                  := x_rownum;
      --y_first_row               := x_first_row;

      IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('y_bank_account_id = '||  y_bank_account_id);
  	 cep_standard.debug('y_balance_date_from = '||  y_balance_date_from);
   	 cep_standard.debug('y_int_calc_balance = '||  y_int_calc_balance);
   	 cep_standard.debug('y_interest_rate   = '||  y_interest_rate  );
   	 cep_standard.debug('y_interest_calc_detail_id   = '||  y_interest_calc_detail_id);

      END IF;

	update CE_INT_CALC_DETAILS_GT
	  set INTEREST_RATE = y_interest_rate,
	  LAST_UPDATE_DATE = sysdate
        where   from_date =  y_balance_date_from
	and bank_account_id =  p_bank_account_id
  	and INTEREST_SCHEDULE_ID = p_interest_schedule_id
	and interest_calc_detail_id = y_interest_calc_detail_id;


    END LOOP; --missing_interest_info

    CLOSE missing_interest_info;


  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('<< CE_INTEREST_CALC.get_missing_interest_info');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_INTEREST_CALC.get_missing_interest_info');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_CALC.get_missing_interest_info');
    fnd_msg_pub.add;

END get_missing_interest_info;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      set_range_and_rate
|                                                                       |
|  CALLED BY                                                            |
|      int_cal_detail_main                                              |
|                                                                       |
|  DESCRIPTION                                                          |
|      Use to set the balance range id and interest rate
|          on CE_INT_CALC_DETAILS_GT for cashpool accounts only         |
|                                                                       |
 --------------------------------------------------------------------- */
PROCEDURE  set_range_and_rate(p_from_date 		date,
				p_to_date 		date,
				p_interest_schedule_id 	number,
				p_bank_account_id 	number,
 				p_interest_acct_type 	varchar2,
				p_cashpool_id  		number
			) IS
 x_balance_date_from 	DATE;
 x_balance_date_to 	DATE;
 x_bank_account_id  	NUMBER;
 x_days 	 	NUMBER;

 x_rownum 	 	NUMBER;
 x_previous_date_from 	DATE := null;

 y_balance_date_from 	DATE;
 y_end_date 		DATE := null;
 y_rownum 	 	NUMBER;
 x_balance_range_id  	NUMBER;
 x_interest_rate  	NUMBER;
 y_balance_range_id  	NUMBER;
 y_interest_rate  	NUMBER;
 x_interest_calc_detail_id 	number;
 y_interest_calc_detail_id 	number;

 i			number := 0;

BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('>> CE_INTEREST_CALC.range_and_rate_cur');
  END IF;

    OPEN range_and_rate_cur (p_from_date, p_to_date,p_bank_account_id, p_interest_schedule_id, p_interest_acct_type,p_cashpool_id  );
    LOOP
      FETCH range_and_rate_cur  INTO x_interest_calc_detail_id,
                             	x_balance_range_id,
				x_interest_rate;

      EXIT WHEN range_and_rate_cur%NOTFOUND OR range_and_rate_cur%NOTFOUND IS NULL;

      y_balance_range_id        := x_balance_range_id;
      y_interest_rate           := x_interest_rate;
      y_interest_calc_detail_id := x_interest_calc_detail_id ;

      IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('y_balance_range_id   	= '||  y_balance_range_id  );
   	 cep_standard.debug('y_interest_rate 		= '||  y_interest_rate);
   	 cep_standard.debug('y_interest_calc_detail_id 	= '||  y_interest_calc_detail_id);
      END IF;

      update CE_INT_CALC_DETAILS_GT
      set BALANCE_RANGE_ID 	= y_balance_range_id,
	  INTEREST_RATE 	= y_interest_rate
      where
	  bank_account_id 	=  p_bank_account_id
  	and INTEREST_ACCT_TYPE 		= p_interest_acct_type
  	and cashpool_id 		= p_cashpool_id
	and interest_calc_detail_id 	= y_interest_calc_detail_id;

    END LOOP; --range_and_rate_cur

    CLOSE range_and_rate_cur;


  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('<< CE_INTEREST_CALC.set_range_and_rate');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_INTEREST_CALC.set_range_and_rate');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_CALC.set_range_and_rate');
    fnd_msg_pub.add;

END set_range_and_rate;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      set_end_date		                                        |
|                                                                       |
|  CALLED BY                                                            |
|      int_cal_detail_main                                              |
|                                                                       |
|  DESCRIPTION                                                          |
|      Use to set the TO_DATE on CE_INT_CALC_DETAILS_GT	        |
|                                                                       |
 --------------------------------------------------------------------- */
PROCEDURE  set_end_date(  	p_from_date 		date,
				p_to_date 		date,
				p_interest_schedule_id 	number,
				p_bank_account_id 	number,
 				p_interest_acct_type 	varchar2,
				p_cashpool_id  		number
			) IS
 x_balance_date_from 	DATE;
 x_balance_date_to 	DATE;
 x_bank_account_id  	NUMBER;
 x_days 	 	NUMBER;

 x_rownum 	 	NUMBER;
 x_previous_date_from 	DATE := null;

 y_balance_date_from 	DATE;
 y_end_date 		DATE := null;
 y_rownum 	 	NUMBER;
 x_interest_calc_detail_id 	number;
 y_interest_calc_detail_id 	number;

 i			number := 0;
 p_row_count 	 	NUMBER;

BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('>> CE_INTEREST_CALC.set_end_date');
  END IF;

    OPEN end_date_cur (p_from_date, p_to_date,p_bank_account_id, p_interest_schedule_id,
			 p_interest_acct_type, p_cashpool_id  );
    LOOP
      FETCH end_date_cur  INTO x_balance_date_from,
                             	x_rownum,
				x_interest_calc_detail_id;

      EXIT WHEN end_date_cur%NOTFOUND OR end_date_cur%NOTFOUND IS NULL;

      y_balance_date_from        := x_balance_date_from;
      y_rownum                  := x_rownum;
      y_interest_calc_detail_id := x_interest_calc_detail_id ;

      i :=i + 1;
      IF (i = 1)  THEN
	   y_end_date       := p_to_date;

      ELSE
	  -- bug 5393669/5479708
	   --y_end_date       := (x_previous_date_from - 1);
	   y_end_date       := x_previous_date_from;

      END IF;


      IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('y_balance_date_from = '||  y_balance_date_from);
   	 cep_standard.debug('y_end_date = '||  y_end_date);
   	 cep_standard.debug('y_interest_calc_detail_id = '||  y_interest_calc_detail_id);
  	 cep_standard.debug(' i = '||  i);

      END IF;

      update CE_INT_CALC_DETAILS_GT
      set to_date =  y_end_date,
	  LAST_UPDATE_DATE = sysdate
      where   from_date =  x_balance_date_from
	--and bank_account_id =  p_bank_account_id
  	and INTEREST_SCHEDULE_ID = p_interest_schedule_id
	and interest_calc_detail_id = y_interest_calc_detail_id;

      x_previous_date_from := x_balance_date_from;

      IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('x_previous_date_from = '||  x_previous_date_from);

      END IF;

    END LOOP; --end_date_cur

    CLOSE end_date_cur;


  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('<< CE_INTEREST_CALC.set_end_date');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_INTEREST_CALC.set_end_date');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_CALC.set_end_date');
    fnd_msg_pub.add;

END set_end_date;


/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      set_int_rate		                                        |
|                                                                       |
|  CALLED BY                                                            |
|      int_cal_xtr                                              |
|                                                                       |
|  DESCRIPTION                                                          |
|      Use to set the INTEREST_RATE on CE_INT_CALC_DETAILS_GT	        |
|                                                                       |
 --------------------------------------------------------------------- */
PROCEDURE  set_int_rate(  	p_from_date 		date,
				p_to_date 		date,
				p_interest_schedule_id 	number,
				p_bank_account_id 	number,
 				p_interest_acct_type 	varchar2,
				p_interest_rate		number
			) IS
 x_balance_date_from 	DATE;
 x_balance_date_to 	DATE;
 x_bank_account_id  	NUMBER;
 x_days 	 	NUMBER;

 x_rownum 	 	NUMBER;
 x_previous_date_from 	DATE := null;

 y_balance_date_from 	DATE;
 y_end_date 		DATE := null;
 y_rownum 	 	NUMBER;
 x_interest_calc_detail_id 	number;
 y_interest_calc_detail_id 	number;

 i			number := 0;

BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('>> CE_INTEREST_CALC.set_int_rate');
  END IF;

    OPEN xtr_cur (p_from_date, p_to_date,p_bank_account_id, p_interest_schedule_id,
			 p_interest_acct_type);
    LOOP
      FETCH xtr_cur  INTO x_balance_date_from,
                             	x_rownum,
				x_interest_calc_detail_id;

      EXIT WHEN xtr_cur%NOTFOUND OR xtr_cur%NOTFOUND IS NULL;

      y_balance_date_from       := x_balance_date_from;
      y_rownum                  := x_rownum;
      y_interest_calc_detail_id := x_interest_calc_detail_id ;

      IF l_DEBUG in ('Y', 'C') THEN
   	 cep_standard.debug('y_interest_calc_detail_id = '||  y_interest_calc_detail_id);
      END IF;

      update CE_INT_CALC_DETAILS_GT
      set INTEREST_RATE = p_interest_rate
      where interest_calc_detail_id = y_interest_calc_detail_id;


    END LOOP; --xtr_cur

    CLOSE xtr_cur;


  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('<< CE_INTEREST_CALC.set_int_rate');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_INTEREST_CALC.set_int_rate');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_CALC.set_int_rate');
    fnd_msg_pub.add;

END set_int_rate;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      calculate_interest
|                                                                       |
|  CALLED BY                                                            |
|      int_cal_detail_main
|      int_cal_xtr                                                      |
|                                                                       |
|  CALLS	                                                        |
|                                                                       |
|  DESCRIPTION                                                          |
|      Handles Interest Calculation			|
|         					                        |
 --------------------------------------------------------------------- */

PROCEDURE  calculate_interest(  p_from_date 		date,
				p_to_date 		date,
				p_interest_schedule_id 	number,
				p_bank_account_id 	number,
				p_interest_acct_type 	varchar2,
				p_cashpool_id  		number
				) IS
 x_balance_date_from 	DATE;
 x_balance_date_to 	DATE;
 x_min_balance_date 	DATE;
 x_max_balance_date 	DATE;

 x_days 	 	NUMBER;
 x_days_from 	 	NUMBER;
 x_days_to	 	NUMBER;
 x_days_over_year 	NUMBER;
 x_days_over_year_from  NUMBER;
 x_days_over_year_to 	NUMBER;

 x_basis		varchar2(30);
 x_interest_includes 	varchar2(30);
 x_interest_rounding	varchar2(30);
 x_day_count_basis 	varchar2(30);

 x_int_calc_balance  	NUMBER;
 x_add_days  		NUMBER;
 x_days_in_yr		NUMBER;
 x_days_in_yr_from	NUMBER;
 x_days_in_yr_to	NUMBER;
 x_interest_amount	NUMBER;
 x_interest_amount_round	NUMBER;
 x_interest_rate	NUMBER;
 x_new_interest_rate	number;
 x_currency_code 	varchar2(15);
 x_from_year		number;
 x_to_year		number;
 x_from_year_leap	BOOLEAN;
 x_to_year_leap		BOOLEAN;
 x_num_of_yrs		number;
 X_ADD_NUM_OF_YRS	number;
 x_interest_calc_detail_id 	number;

 l_count  NUMBER;
 l_diff   NUMBER;
 l_amount NUMBER;
 l_balance NUMBER;
 l_min    NUMBER;
 l_max    NUMBER;
 l_rate   NUMBER;
 l_wavg   NUMBER;
 l_int_rate NUMBER;
 x_add_min_pre_amt NUMBER;

precision		NUMBER default NULL;
ext_precision		NUMBER default NULL;
min_acct_unit		NUMBER default NULL;

BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('>> CE_INTEREST_CALC.calculate_interest');
  	 cep_standard.debug('p_from_date='||p_from_date||', p_to_date='||p_to_date);
  END IF;

  select DAY_COUNT_BASIS,
    INTEREST_INCLUDES,
    INTEREST_ROUNDING,
    BASIS,
    CURRENCY_CODE
  INTO
     x_day_count_basis ,
     x_interest_includes ,
     x_interest_rounding,
     x_basis,
     x_currency_code
  from CE_INTEREST_SCHEDULES
  WHERE INTEREST_SCHEDULE_ID = p_interest_schedule_id;

  FND_CURRENCY.get_info(x_currency_code,
				 precision,
				 ext_precision,
				 min_acct_unit);

  -- bug 5393669/5479708
  select min(BALANCE_DATE) ,  max(BALANCE_DATE)
  INTO  x_min_balance_date , x_max_balance_date
  from  ce_bank_acct_balances
  where bank_account_id = p_bank_account_id;

  SELECT MIN(FROM_BALANCE_AMOUNT)
  INTO x_add_min_pre_amt
  FROM ce_interest_bal_ranges
  WHERE   INTEREST_SCHEDULE_ID = p_interest_schedule_id
  AND FROM_BALANCE_AMOUNT > 0;

     IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('x_basis = '|| x_basis);
  	 cep_standard.debug('x_interest_includes  = '||  x_interest_includes );
  	 cep_standard.debug('x_interest_rounding = '||  x_interest_rounding );
 	 cep_standard.debug('x_day_count_basis = '||  x_day_count_basis );
    	 cep_standard.debug('precision = '||  precision);
    	 cep_standard.debug('ext_precision = '||  ext_precision);
    	 cep_standard.debug('min_acct_unit = '||  min_acct_unit);

    	 cep_standard.debug('x_add_min_pre_amt = '||  x_add_min_pre_amt);

    	 cep_standard.debug('x_min_balance_date = '||  x_min_balance_date);
    	 cep_standard.debug('x_max_balance_date = '||  x_max_balance_date);

      END IF;

/*
  IF (nvl(x_interest_includes,'F') in ('F', 'L')) THEN
    x_add_days := 1;
  ELSE
    x_add_days := 2;
  END IF;
*/

  IF (nvl(x_day_count_basis,'ACTUAL365') =  'ACTUAL365') THEN
	x_days_in_yr := 365;
  ELSIF (x_day_count_basis  = 'ACTUAL360') THEN
	x_days_in_yr := 360;
  ELSIF (x_day_count_basis  = 'ACTUAL/ACTUAL') THEN
	x_days_in_yr := null;
  END IF;

  -----------------------------------------------------------------------------

    -- Bug 6825932 start
    if calc_detail_cur%isopen then
    close calc_detail_cur ;
    end if;
    -- Bug 6825932 end
    OPEN calc_detail_cur (p_from_date, p_to_date,p_bank_account_id, p_interest_schedule_id, p_interest_acct_type, p_cashpool_id  );
    LOOP
      FETCH calc_detail_cur  INTO x_balance_date_from,
				  x_balance_date_to ,
				  x_int_calc_balance ,
 				  x_interest_rate,
				  x_interest_calc_detail_id ;


      EXIT WHEN calc_detail_cur%NOTFOUND OR calc_detail_cur%NOTFOUND IS NULL;

      -- bug 5393669/5479708
/*    IF (nvl(x_interest_includes,'F') = 'F') THEN
        IF ( p_from_date = p_to_date) THEN
          x_add_days := 1;
        ELSIF (p_to_date=x_balance_date_to) THEN
          x_add_days := 0;
        ELSE
          x_add_days := 1;
        END IF;
      ELSIF (nvl(x_interest_includes,'F') = 'L') THEN
        IF ( p_from_date = p_to_date) THEN
          x_add_days := 1;
        ELSIF (p_from_date=x_balance_date_from) THEN
          x_add_days := 0;
        ELSIF (p_to_date=x_balance_date_to) THEN
          x_add_days := 1;
        ELSE
          x_add_days := 1;
        END IF;
      ELSIF (nvl(x_interest_includes,'F') = 'B') THEN
        IF ( p_from_date = p_to_date) THEN
          x_add_days := 1;
        ELSIF (p_from_date=x_balance_date_from) THEN
          x_add_days := 1;
        ELSIF (p_to_date=x_balance_date_to) THEN
          x_add_days := 1;
        ELSE
          x_add_days := 1;
        END IF;
      END IF;
*/

      IF (nvl(x_interest_includes,'F') in ('L', 'F')) THEN
          x_add_days := 0;
      ELSIF (nvl(x_interest_includes,'F') = 'B') THEN
        IF ( p_from_date = p_to_date) THEN
          x_add_days := 0;
        --ELSIF ((p_from_date=x_balance_date_from) and
	--	(x_balance_date_from =x_min_balance_date)) THEN
        ELSIF (x_balance_date_from =x_min_balance_date) THEN
          x_add_days := 1;
        ELSE
          x_add_days := 0;
        END IF;
      END IF;

      IF (x_day_count_basis = 'ACTUAL/ACTUAL') THEN
	-- find days in yr
	x_days_in_yr := null;
	x_from_year  := to_char(x_balance_date_from, 'yyyy');
	x_to_year    := to_char(x_balance_date_to, 'yyyy');

	IF (x_from_year = x_to_year) THEN
	  x_from_year_leap := IsLeapYear(to_char(x_balance_date_from, 'yyyy'));
	  IF  (x_from_year_leap) THEN
	     x_days_in_yr := 366;
	  ELSE
	     x_days_in_yr := 365;
          END IF;

          x_days := (x_balance_date_to - x_balance_date_from + x_add_days );
 	  x_days_over_year := x_days/nvl(x_days_in_yr,1);

	ELSE
	  x_from_year_leap := IsLeapYear(to_char(x_balance_date_from, 'yyyy'));
	  x_to_year_leap := IsLeapYear(to_char(x_balance_date_to, 'yyyy'));
	  x_add_num_of_yrs := (x_to_year - x_from_year - 1 );

	  IF  (x_from_year_leap) THEN
	     x_days_in_yr_from := 366;
	  ELSE
	     x_days_in_yr_from := 365;
          END IF;

	  IF  (x_to_year_leap) THEN
	     x_days_in_yr_to := 366;
	  ELSE
	     x_days_in_yr_to := 365;
          END IF;

         -- Bug 6825932 Start
	  x_days_from := to_date('31-Dec-'||x_from_year) - to_date(x_balance_date_from) ;
          x_days_to :=  to_date('01-Jan'||x_to_year) - to_date(x_balance_date_to) ;
         -- Bug 6825932 end
 	  --x_days_over_year := x_days/x_days_in_yr_from;
	  x_days_over_year_from := x_days_from/x_days_in_yr_from;
	  x_days_over_year_to   := x_days_to/x_days_in_yr_to;
	  x_days_over_year      := x_days_over_year_from + x_days_over_year_to + x_add_num_of_yrs ;

        END IF; --(x_from_year = x_to_year)
      ELSE  -- not 'ACTUAL/ACTUAL'
        x_days := (x_balance_date_to - x_balance_date_from + x_add_days );
	x_days_over_year := x_days/nvl(x_days_in_yr,1) ;

      END IF; --(x_day_count_basis = 'ACTUAL/ACTUAL')

      IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('---------- new balance range ------------');
   	 cep_standard.debug('x_balance_date_from = '||  x_balance_date_from);
 	 cep_standard.debug('x_balance_date_to = '||  x_balance_date_to);
 	 cep_standard.debug('x_int_calc_balance  = '||  x_int_calc_balance );
 	 cep_standard.debug('x_interest_rate  = '||  x_interest_rate );
  	 cep_standard.debug('x_add_days = '||  x_add_days);
  	 cep_standard.debug('x_days_over_year = '||  x_days_over_year);
  	 cep_standard.debug('x_days = '||  x_days);
      END IF;
  --------------------------------------------------------------------------------------------
      --x_days := (x_balance_date_to - x_balance_date_from + x_add_days );

      -- calculate the interest amount
      IF (nvl(x_basis, 'FLAT') = 'FLAT') THEN
	--x_interest_amount := (x_int_calc_balance * x_interest_rate/100 * 1/nvl(x_days_in_yr,1) * x_days);
	x_interest_amount := (x_int_calc_balance * x_interest_rate/100 * x_days_over_year);
      ELSE  -- STEP

        l_amount := x_int_calc_balance; --l_balance;
        IF l_DEBUG in ('Y', 'C') THEN
  	    cep_standard.debug('l_amount = '||  l_amount);
        END IF;

        if l_amount <= 0 then

          IF l_DEBUG in ('Y', 'C') THEN
  	    cep_standard.debug('open DR_RANGE');
          END IF;

          --open DR_RANGE(p_from_date , p_to_date ,
          open DR_RANGE(x_balance_date_from, x_balance_date_to ,
			p_bank_account_id, p_interest_schedule_id, l_amount);
	  l_wavg := 0;
	  l_count := 0;
          LOOP
            fetch DR_RANGE INTO l_min,l_max,l_rate;
            EXIT WHEN DR_RANGE%NOTFOUND;

       	    IF l_DEBUG in ('Y', 'C') THEN
  	        cep_standard.debug('-------------');
  	 	cep_standard.debug('l_min = '|| l_min );
  	 	cep_standard.debug('l_max = '||  l_max );
  	 	cep_standard.debug('l_rate = '||  l_rate );
      	    END IF;


            if l_max > 0 then
              l_max := 0;
            end if;
            if l_min < l_amount then
              l_min := l_amount;
            end if;

      	    IF l_DEBUG in ('Y', 'C') THEN
  	 	cep_standard.debug('new l_min = '|| l_min );
  	 	cep_standard.debug('new l_max = '||  l_max );

      	    END IF;

            l_diff := (l_amount - l_max) - (l_amount - l_min);

      	    IF l_DEBUG in ('Y', 'C') THEN
  	 	cep_standard.debug('l_diff = '||  l_diff );
 	 	cep_standard.debug('current l_wavg = '|| l_wavg );
  	 	cep_standard.debug('current l_count = '|| l_count );
      	    END IF;

            l_wavg := l_wavg + (l_diff * l_rate);
            l_count := l_count + 1;

	    IF l_DEBUG in ('Y', 'C') THEN
  		 cep_standard.debug('l_min = '|| l_min );
	  	 cep_standard.debug('l_max = '||  l_max );
  		 cep_standard.debug('l_rate = '||  l_rate );
	  	 cep_standard.debug('l_diff = '||  l_diff );
  		 cep_standard.debug('l_wavg = '|| l_wavg );
	    END IF;

         END LOOP;
         close DR_RANGE;
         --if nvl(l_balance,0) <>0 then
         --  l_int_rate := round(l_wavg /l_balance,5);

         if nvl(x_int_calc_balance,0) <> 0 then
           l_int_rate := round(l_wavg /x_int_calc_balance,5);
         end if;

         IF l_DEBUG in ('Y', 'C') THEN
  	    cep_standard.debug('-------------');
  	    cep_standard.debug('l_int_rate = '||  l_int_rate);
         END IF;

       else
          IF l_DEBUG in ('Y', 'C') THEN
  	    cep_standard.debug('open CR_RANGE');
          END IF;

         --open CR_RANGE(p_from_date , p_to_date ,
         open CR_RANGE(x_balance_date_from, x_balance_date_to ,
			p_bank_account_id, p_interest_schedule_id, l_amount);
         l_wavg := 0;
         l_count := 0;
         LOOP
           fetch CR_RANGE INTO l_min,l_max,l_rate;
           EXIT WHEN CR_RANGE%NOTFOUND;

      	   IF l_DEBUG in ('Y', 'C') THEN
  	        cep_standard.debug('-------------');
  	 	cep_standard.debug('l_min = '|| l_min );
  	 	cep_standard.debug('l_max = '||  l_max );
  	 	cep_standard.debug('l_rate = '||  l_rate );
      	   END IF;

           if l_min < 0 then
             l_min := 0;
           end if;
           if l_max > l_amount then
             l_max := l_amount;
           end if;

      	   IF l_DEBUG in ('Y', 'C') THEN
  	 	cep_standard.debug('new l_min = '|| l_min );
  	 	cep_standard.debug('new l_max = '||  l_max );

      	   END IF;

           l_diff := (((l_amount - l_min) - (l_amount - l_max)) + x_add_min_pre_amt);

     	   IF l_DEBUG in ('Y', 'C') THEN
  	 	cep_standard.debug('l_diff = '||  l_diff );
 	 	cep_standard.debug('current l_wavg = '|| l_wavg );
  	 	cep_standard.debug('current l_count = '|| l_count );
      	   END IF;

           l_wavg := l_wavg + (l_diff * l_rate);
           l_count := l_count + 1;

      	   IF l_DEBUG in ('Y', 'C') THEN
  	 	cep_standard.debug('new l_wavg = '|| l_wavg );
  	 	cep_standard.debug('new l_count = '|| l_count );
      	   END IF;

         END LOOP;
         close CR_RANGE;
         --if nvl(l_balance,0) <>0 then
         --  l_int_rate := round(l_wavg /l_balance,5);
         if nvl(x_int_calc_balance,0) <> 0 then
           l_int_rate := round(l_wavg /x_int_calc_balance,5);
         end if;

         IF l_DEBUG in ('Y', 'C') THEN
  	    cep_standard.debug('-------------');
  	    cep_standard.debug('l_int_rate = '||  l_int_rate);
        END IF;

        end if;

	x_new_interest_rate := l_int_rate;
	x_interest_amount := (x_int_calc_balance * l_int_rate/100 * x_days_over_year);

      END IF; -- end step
  ------------------------------------------------------------------------------
      -- round interest amount
      IF (nvl(x_interest_rounding, 'R') = 'R')  THEN
 	  x_interest_amount_round := round(x_interest_amount, precision) ;
      ELSIF (x_interest_rounding = 'T')  THEN
 	  x_interest_amount_round := trunc(x_interest_amount, precision) ;
      ELSIF (x_interest_rounding = 'U')  THEN
 	  x_interest_amount_round := roundup(x_interest_amount, precision) ;
      END IF;

      IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('l_wavg = '|| l_wavg );
  	 cep_standard.debug('x_interest_amount = '||  x_interest_amount );
  	 cep_standard.debug('x_interest_amount_round = '||  x_interest_amount_round );
  	 cep_standard.debug('x_new_interest_rate = '||  x_new_interest_rate );
      END IF;

      IF (x_basis = 'STEP') THEN
	--x_new_interest_rate := (x_interest_amount/(nvl((x_int_calc_balance * x_days_over_year),1) * 100));
        update CE_INT_CALC_DETAILS_GT
        set interest_amount  	= x_interest_amount_round,
	  NUMBER_OF_DAYS   	= x_days,
	  interest_rate 	= x_new_interest_rate,
	  LAST_UPDATE_DATE 	= sysdate
        where
	  from_date 		   = x_balance_date_from
	  --and bank_account_id 	   =  p_bank_account_id
  	  and INTEREST_SCHEDULE_ID = p_interest_schedule_id
	  and interest_calc_detail_id  = x_interest_calc_detail_id ;
      ELSE
        update CE_INT_CALC_DETAILS_GT
        set interest_amount  	= x_interest_amount_round,
	  NUMBER_OF_DAYS   	= x_days,
	  LAST_UPDATE_DATE 	= sysdate
        where
	  from_date 		   =  x_balance_date_from
	  --and bank_account_id 	   =  p_bank_account_id
  	  and INTEREST_SCHEDULE_ID = p_interest_schedule_id
	  and interest_calc_detail_id  = x_interest_calc_detail_id ;
      END IF;

    END LOOP; --calc_detail_cur
    CLOSE calc_detail_cur;

  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('<< CE_INTEREST_CALC.calculate_interest');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_INTEREST_CALC.calculate_interest');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_CALC.calculate_interest');
    fnd_msg_pub.add;

END calculate_interest;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      int_cal_xtr	                                        |
|                                                                       |
|  CALLED BY                                                            |
|      Treasury        |
|                                                                       |
|  CALLS	                                                        |
|                                                                       |
|  DESCRIPTION                                                          |
|      Procedure used for Interest Calculation by Treasury		|
|         					                        |
 --------------------------------------------------------------------- */
PROCEDURE  int_cal_xtr( p_from_date 		IN	date,
			p_to_date  		IN	date,
			p_bank_account_id  	IN	number,
			p_interest_rate   	IN      NUMBER,
			p_interest_acct_type 	IN      varchar2,
			p_interest_amount	OUT NOCOPY number)  IS

 x_balance_date_from 	DATE;
 x_balance_date_to 	DATE;
 x_bank_account_id  	NUMBER;
 x_int_calc_balance  	NUMBER;
 p_interest_schedule_id	NUMBER;
 p_cashpool_id		NUMBER;
 x_days 	 	NUMBER;
 x_rownum 	 	NUMBER;

 y_balance_date_from 	DATE;
 y_balance_date_to 	DATE;
 y_bank_account_id  	NUMBER;
 y_int_calc_balance  	NUMBER;
 y_days 	 	NUMBER;
 y_rownum 	 	NUMBER;
 p_row_count 	 	NUMBER;

precision		NUMBER default NULL;
ext_precision		NUMBER default NULL;
min_acct_unit		NUMBER default NULL;

BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('>> CE_INTEREST_CALC.int_cal_xtr');
  	 cep_standard.debug('p_from_date  ='||p_from_date  || ', p_to_date  ='||p_to_date );
  	 cep_standard.debug(' p_bank_account_id  ='||p_bank_account_id  ||
				', p_interest_acct_type  ='||p_interest_acct_type ||
				', p_interest_rate  ='||p_interest_rate );

  END IF;

  p_cashpool_id	:= null;

  IF (p_from_date >  p_to_date)  THEN
          FND_MESSAGE.set_name( 'CE','CE_FROM_GREATER_TO_DATE');
          fnd_msg_pub.add;
  ELSE
    IF (p_interest_acct_type = 'TREASURY') THEN
  	 cep_standard.debug(' TREASURY');
      IF (p_bank_account_id is not null)  THEN
  	 cep_standard.debug(' p_bank_account_id is not null');
	SELECT INTEREST_SCHEDULE_ID
	INTO P_INTEREST_SCHEDULE_ID
	FROM  CE_BANK_ACCOUNTS
	WHERE BANK_ACCOUNT_ID = p_bank_account_id;

  	 cep_standard.debug(' p_interest_schedule_id  ='||p_interest_schedule_id );

	IF (P_INTEREST_SCHEDULE_ID is not null) THEN
      	  delete_schedule_account(  p_interest_schedule_id ,
				p_bank_account_id,
				p_interest_acct_type,
				p_cashpool_id
			     );

          -- found available balances
      	  get_balance_info(p_from_date , p_to_date,
		     p_interest_schedule_id, p_bank_account_id,
		     p_interest_acct_type, p_cashpool_id, p_row_count  );

      IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('p_row_count  = '||  p_row_count );
      END IF;

      	  IF (p_row_count > 0) THEN
	  /*
            get_interest_info(p_from_date , p_to_date,
		     p_interest_schedule_id, p_bank_account_id,
		     p_interest_acct_type, p_cashpool_id, p_row_count );
	  */
            set_int_rate(p_from_date , p_to_date,
		     p_interest_schedule_id, p_bank_account_id,
		     p_interest_acct_type, p_interest_rate  );

            set_end_date(p_from_date , p_to_date,
		     p_interest_schedule_id, p_bank_account_id,
		     p_interest_acct_type, p_cashpool_id  );

            calculate_interest(p_from_date , p_to_date,
		     p_interest_schedule_id, p_bank_account_id,
		     p_interest_acct_type, p_cashpool_id  );

	   select sum(INTEREST_AMOUNT)
	   into p_interest_amount
	   from CE_INT_CALC_DETAILS_GT
	   where INTEREST_SCHEDULE_ID	= p_interest_schedule_id
	   and BANK_ACCOUNT_ID 	   	= p_bank_account_id
	   and INTEREST_ACCT_TYPE 	= p_interest_acct_type
	   and FROM_DATE  		>= p_from_date
	   and TO_DATE			<= p_to_date
	   and CASHPOOL_ID 	  is null;

            IF l_DEBUG in ('Y', 'C') THEN
  	      cep_standard.debug(' p_interest_amount  ='||p_interest_amount );
            END IF;

	  END IF;
        ELSE
          FND_MESSAGE.set_name( 'CE','CE_NO_SCHED_BANK_ACCT');
          fnd_msg_pub.add;
        END IF;
      ELSE
        FND_MESSAGE.set_name( 'CE','CE_MISSING_BANK_ACCT_ID');
        fnd_msg_pub.add;
      END IF;
    ELSE
      FND_MESSAGE.set_name( 'CE','CE_INVALID_INT_ACCT_TYPE');
      FND_MESSAGE.Set_Token('INTEREST_ACCT_TYPE', p_interest_acct_type);
      fnd_msg_pub.add;
    END IF;

  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('<< CE_INTEREST_CALC.int_cal_xtr');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_INTEREST_CALC.int_cal_xtr');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_CALC.int_cal_xtr');
    fnd_msg_pub.add;

END int_cal_xtr;


/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      int_cal_detail_main	                                        |
|                                                                       |
|  CALLED BY                                                            |
|      InterestAMImpl.java (InterestCalculateCO)                        |
|                                                                       |
|  CALLS	                                                        |
|      get_interest_info                                                |
|      set_end_date        	                                        |
|      calculate_interest	                                        |
|                                                                       |
|  DESCRIPTION                                                          |
|      Main procedure use for Interest Calculation			|
|         					                        |
 --------------------------------------------------------------------- */
PROCEDURE  int_cal_detail_main( p_from_date 		date,
				p_to_date 		date,
				p_interest_schedule_id 	number,
				p_bank_account_id 	number,
				p_interest_acct_type 	varchar2,
				p_cashpool_id  		number)  IS
 x_balance_date_from 	DATE;
 x_balance_date_to 	DATE;
 x_bank_account_id  	NUMBER;
 x_int_calc_balance  	NUMBER;

 x_days 	 	NUMBER;
 x_rownum 	 	NUMBER;

 y_balance_date_from 	DATE;
 y_balance_date_to 	DATE;
 y_bank_account_id  	NUMBER;
 y_int_calc_balance  	NUMBER;
 y_days 	 	NUMBER;
 y_rownum 	 	NUMBER;
 p_row_count 	 	NUMBER;
 p_num_of_range 	NUMBER;
precision		NUMBER default NULL;
ext_precision		NUMBER default NULL;
min_acct_unit		NUMBER default NULL;

BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('>> CE_INTEREST_CALC.int_cal_detail_main');
  	 cep_standard.debug('p_from_date = '||p_from_date||', p_to_date = '||p_to_date);
  	 cep_standard.debug('p_interest_schedule_id ='|| p_interest_schedule_id ||
				', p_bank_account_id  ='||p_bank_account_id  ||
				', p_interest_acct_type  ='||p_interest_acct_type ||
				', p_cashpool_id  ='||p_cashpool_id );

  END IF;

  IF (p_from_date >  p_to_date)  THEN
          FND_MESSAGE.set_name( 'CE','CE_FROM_GREATER_TO_DATE');
          fnd_msg_pub.add;
  ELSE
    IF (p_interest_acct_type = 'BANK_ACCOUNT') THEN

      delete_schedule_account(  p_interest_schedule_id ,
				p_bank_account_id,
				p_interest_acct_type,
				 p_cashpool_id
			     );

      -- found available balances
      get_balance_info(p_from_date , p_to_date,
		     p_interest_schedule_id, p_bank_account_id,
		     p_interest_acct_type, p_cashpool_id, p_row_count  );

      IF (p_row_count > 0) THEN
        get_interest_info(p_from_date , p_to_date,
		     p_interest_schedule_id, p_bank_account_id,
		     p_interest_acct_type, p_cashpool_id, p_row_count );

        set_end_date(p_from_date , p_to_date,
		     p_interest_schedule_id, p_bank_account_id,
		     p_interest_acct_type, p_cashpool_id  );

        calculate_interest(p_from_date , p_to_date,
		     p_interest_schedule_id, p_bank_account_id,
		     p_interest_acct_type, p_cashpool_id  );

      END IF;
    ELSIF (p_interest_acct_type = 'NOTIONAL')   THEN
      delete_schedule_account( p_interest_schedule_id ,
				 x_bank_account_id,
				 p_interest_acct_type,
				 p_cashpool_id
				     );

      -- do not call cashpool_accts_cur
      --   ce_bal_util.get_pool_balance(p_cashpool_id, p_from_date) will get total
      --   balances for cashpool accounts (includes: ('CONC', 'ACCT', 'NEST'))
      --OPEN cashpool_accts_cur (p_cashpool_id );
      --LOOP
       --FETCH cashpool_accts_cur  INTO x_bank_account_id;
       --EXIT WHEN cashpool_accts_cur%NOTFOUND OR cashpool_accts_cur%NOTFOUND IS NULL;

      --IF l_DEBUG in ('Y', 'C') THEN
  	-- cep_standard.debug('x_bank_account_id = '|| x_bank_account_id );
      --END IF;

        -- found available balances for each cashpool
        get_balance_pool_info(p_from_date , p_to_date,
		     p_interest_schedule_id, p_bank_account_id,
		     p_interest_acct_type, p_cashpool_id, p_row_count  );

      IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('p_row_count = '|| p_row_count );
      END IF;
        IF (p_row_count > 0) THEN

	  set_range_and_rate(p_from_date , p_to_date,
		     p_interest_schedule_id, p_bank_account_id,
		     p_interest_acct_type, p_cashpool_id);

          get_interest_pool_info(p_from_date , p_to_date,
		     p_interest_schedule_id, p_bank_account_id,
		     p_interest_acct_type, p_cashpool_id, p_row_count );


          set_end_date(p_from_date , p_to_date,
		     p_interest_schedule_id, p_bank_account_id,
		     p_interest_acct_type, p_cashpool_id  );

          calculate_interest(p_from_date , p_to_date,
		     p_interest_schedule_id, p_bank_account_id,
		     p_interest_acct_type, p_cashpool_id  );
	END IF;
      --END LOOP; --cashpool_accts_cur
    /*  set_end_date(p_from_date , p_to_date,
		     p_interest_schedule_id, p_bank_account_id,
		     p_interest_acct_type, p_cashpool_id  );

      calculate_interest(p_from_date , p_to_date,
		     p_interest_schedule_id, p_bank_account_id,
		     p_interest_acct_type, p_cashpool_id  ); */

    ELSE
      FND_MESSAGE.set_name( 'CE','CE_INVALID_INT_ACCT_TYPE');
      FND_MESSAGE.Set_Token('INTEREST_ACCT_TYPE', p_interest_acct_type);
      fnd_msg_pub.add;
    END IF;
    --commit;

    --bug 5479708, removed last date range
    if (p_cashpool_id is null) THEN
      select count(*) into p_num_of_range
      from CE_INT_CALC_DETAILS_GT
      where
	  INTEREST_SCHEDULE_ID  = p_interest_schedule_id
	and BANK_ACCOUNT_ID 	= p_bank_account_id
	and INTEREST_ACCT_TYPE 	= p_interest_acct_type
	and CASHPOOL_ID is null;

      IF  (p_num_of_range > 1) THEN
	delete CE_INT_CALC_DETAILS_GT
	where
	  INTEREST_SCHEDULE_ID  = p_interest_schedule_id
	and BANK_ACCOUNT_ID 	= p_bank_account_id
	and INTEREST_ACCT_TYPE 	= p_interest_acct_type
	and CASHPOOL_ID is null
	and FROM_DATE = 	p_to_date ;

      END IF;

    else  -- p_cashpool_id is not null
      select count(*) into p_num_of_range
      from CE_INT_CALC_DETAILS_GT
      where   INTEREST_SCHEDULE_ID  = p_interest_schedule_id
      --and BANK_ACCOUNT_ID 	= p_bank_account_id
      and INTEREST_ACCT_TYPE 	= p_interest_acct_type
      and CASHPOOL_ID 	= p_cashpool_id;

      IF  (p_num_of_range > 1) THEN
	delete CE_INT_CALC_DETAILS_GT
        where   INTEREST_SCHEDULE_ID  = p_interest_schedule_id
        --and BANK_ACCOUNT_ID 	= p_bank_account_id
        and INTEREST_ACCT_TYPE 	= p_interest_acct_type
        and CASHPOOL_ID 	= p_cashpool_id
	and FROM_DATE = 	p_to_date ;
      END IF;
    end if;  --p_cashpool_id is null

    IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('p_num_of_range '|| p_num_of_range );
    END IF;

  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('<< CE_INTEREST_CALC.int_cal_detail_main');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_INTEREST_CALC.int_cal_detail_main');
    END IF;
    FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.Set_Token('PROCEDURE', 'CE_INTEREST_CALC.int_cal_detail_main');
    fnd_msg_pub.add;

END int_cal_detail_main;

END CE_INTEREST_CALC;

/
