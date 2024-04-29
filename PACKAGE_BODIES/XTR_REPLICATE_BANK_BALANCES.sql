--------------------------------------------------------
--  DDL for Package Body XTR_REPLICATE_BANK_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_REPLICATE_BANK_BALANCES" AS
/* |  $Header: xtrbbalb.pls 120.17.12010000.2 2009/06/11 07:18:39 srsampat ship $ | */
--
-- To replicate the data from CE tables to xtr_bank_balances table
--
--
-- Purpose: This package will insert/delete/update the bank balances
--  from CE tables to the xtr_bank_balances table.

-- replicate_bank_account is the main procedure through which the
-- insert/delete/update procedures will be called.
--
--  -- MODIFICATION HISTORY
-- Person             Date                Comments
-- Eakta Aggarwal    19-May-2005           Created
-- ---------          ------          ----------------------------------



PROCEDURE REPLICATE_BANK_BALANCE
     ( p_balance_rec IN xtr_bank_balances%ROWTYPE,
       p_action_flag IN VARCHAR2,
       x_return_status   		OUT NOCOPY  	VARCHAR2,
       x_msg_count			OUT NOCOPY 	NUMBER,
       x_msg_data			OUT NOCOPY 	VARCHAR2)
IS

CURSOR C_BALANCE_DETAILS IS
    SELECT company_code,account_number,balance_date,statement_balance
            ,balance_adjustment,balance_cflow,ce_bank_account_balance_id
    FROM XTR_BANK_BALANCES
    WHERE CE_BANK_ACCOUNT_BALANCE_ID = p_balance_rec.ce_bank_account_balance_id;



    l_balance_date_updated BOOLEAN;
    l_balance_rec XTR_BANK_BALANCES%ROWTYPE;


BEGIN
        l_balance_date_updated := FALSE;
        FND_MSG_PUB.Initialize;
        IF(p_action_flag in ('U','D')) THEN

            OPEN C_BALANCE_DETAILS;
            FETCH C_BALANCE_DETAILS INTO l_balance_rec.company_code,l_balance_rec.account_number
                                ,l_balance_rec.balance_date,l_balance_rec.statement_balance,l_balance_rec.balance_adjustment
                                ,l_balance_rec.balance_cflow,l_balance_rec.ce_bank_account_balance_id;
            CLOSE C_BALANCE_DETAILS;


            IF(nvl(p_balance_rec.balance_date,sysdate) <> nvl(l_balance_rec.balance_date,sysdate)
                AND p_balance_rec.balance_date is not null AND l_balance_rec.balance_date is not null
                AND p_action_flag = 'U') THEN

                l_balance_date_updated := TRUE;

            END IF;

        END IF;




       IF(NOT l_balance_date_updated) THEN -- Balance date is not updated
        IF (p_action_flag in ('I','U') )THEN
            VALIDATE_BANK_BALANCE(
                            p_balance_rec.company_code,
                            p_balance_rec.account_number,
                            p_balance_rec.balance_date,
                            p_balance_rec.ce_bank_account_balance_id,
                            p_balance_rec.statement_balance+p_balance_rec.balance_adjustment,
                            p_balance_rec.balance_cflow,
                            p_action_flag,
                            x_return_status );
        END IF;
        IF (p_action_flag in ('D')) THEN
            VALIDATE_BANK_BALANCE(
                            l_balance_rec.company_code,
                            l_balance_rec.account_number,
                            l_balance_rec.balance_date,
                            p_balance_rec.ce_bank_account_balance_id,
                            l_balance_rec.statement_balance+l_balance_rec.balance_adjustment,
                            l_balance_rec.balance_cflow,
                            'D',
                            x_return_status );
        END IF;


            IF  x_return_status = FND_API.G_RET_STS_SUCCESS  THEN

                IF    p_action_flag = 'I'    THEN /* Insertion of a record */

                     INSERT_BANK_BALANCE ( p_balance_rec, x_return_status);

                ELSIF   p_action_flag = 'U'   THEN   /* Updation of a balance */

                     UPDATE_BANK_BALANCE ( p_balance_rec, x_return_status);

                ELSIF   p_action_flag = 'D'   THEN   /* Deletion of a balance */

                     DELETE_BANK_BALANCE( l_balance_rec, x_return_status);

                ELSE
                     x_return_status    := FND_API.G_RET_STS_ERROR;
                    LOG_ERR_MSG('XTR_INV_PARAM','ACTION_FLAG');

                END IF;

            END IF;


        IF (p_action_flag in ('I','U') )THEN

            IF  x_return_status = FND_API.G_RET_STS_SUCCESS  THEN
             UPDATE_BANK_ACCOUNT (  p_balance_rec.company_code,
                                    p_balance_rec.account_number,
                                    p_balance_rec.balance_date ,
                                    p_action_flag ,
                                    x_return_status );

            END IF;

       END IF;

       IF (p_action_flag in ('D') )THEN

            IF  x_return_status = FND_API.G_RET_STS_SUCCESS  THEN
             UPDATE_BANK_ACCOUNT (  l_balance_rec.company_code,
                                    l_balance_rec.account_number,
                                    l_balance_rec.balance_date ,
                                    'D' ,
                                    x_return_status );

            END IF;

       END IF;

    ELSIF(l_balance_date_updated) THEN

            VALIDATE_BANK_BALANCE(
                            p_balance_rec.company_code,
                            p_balance_rec.account_number,
                            p_balance_rec.balance_date,
                            p_balance_rec.ce_bank_account_balance_id,
                            p_balance_rec.statement_balance+p_balance_rec.balance_adjustment,
                            p_balance_rec.balance_cflow,
                            'D',
                            x_return_status );
            IF  x_return_status = FND_API.G_RET_STS_SUCCESS  THEN
                DELETE_BANK_BALANCE( p_balance_rec, x_return_status);
            END IF;
            IF  x_return_status = FND_API.G_RET_STS_SUCCESS  THEN
             UPDATE_BANK_ACCOUNT (  p_balance_rec.company_code,
                                    p_balance_rec.account_number,
                                    p_balance_rec.balance_date ,
                                    'D' ,
                                    x_return_status );

            END IF;
            IF  x_return_status = FND_API.G_RET_STS_SUCCESS  THEN
                VALIDATE_BANK_BALANCE(
                            p_balance_rec.company_code,
                            p_balance_rec.account_number,
                            p_balance_rec.balance_date,
                            p_balance_rec.ce_bank_account_balance_id,
                            p_balance_rec.statement_balance+p_balance_rec.balance_adjustment,
                            p_balance_rec.balance_cflow,
                            'I',
                            x_return_status );
            END IF;
            IF  x_return_status = FND_API.G_RET_STS_SUCCESS  THEN
                INSERT_BANK_BALANCE( p_balance_rec, x_return_status);
            END IF;
            IF  x_return_status = FND_API.G_RET_STS_SUCCESS  THEN
             UPDATE_BANK_ACCOUNT (  p_balance_rec.company_code,
                                    p_balance_rec.account_number,
                                    p_balance_rec.balance_date ,
                                    'I',
                                    x_return_status );

            END IF;


        END IF;

    FND_MSG_PUB.Count_And_Get -- Returns the error message if there is only 1 error
    (   p_count         =>      x_msg_count     ,
        p_data          =>      x_msg_data
    );


EXCEPTION

      WHEN others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          LOG_ERR_MSG ('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));

      FND_MSG_PUB.Count_And_Get -- Returns the error message if there is only 1 error
    (   p_count         =>      x_msg_count     ,
        p_data          =>      x_msg_data
    );

END REPLICATE_BANK_BALANCE;

PROCEDURE REPLICATE_BANK_BALANCE
     ( p_ce_bank_account_balance_id	IN	XTR_BANK_BALANCES.ce_bank_account_balance_id%TYPE,
       p_company_code	IN	XTR_BANK_BALANCES.company_code%TYPE,
       p_account_number	IN	XTR_BANK_BALANCES.account_number%TYPE,
       p_balance_date	IN	XTR_BANK_BALANCES.balance_date%TYPE,
       p_ledger_balance	IN	CE_BANK_ACCT_BALANCES.ledger_balance%TYPE,
       p_available_balance	IN	CE_BANK_ACCT_BALANCES.available_balance%TYPE,
       p_interest_calculated_balance	IN	CE_BANK_ACCT_BALANCES.value_dated_balance%TYPE,
       p_one_day_float	IN	XTR_BANK_BALANCES.one_day_float%TYPE,
       p_two_day_float	IN	XTR_BANK_BALANCES.two_day_float%TYPE,
       p_action_flag IN varchar2,
       x_return_status   	OUT NOCOPY  VARCHAR2,
       x_msg_count			OUT NOCOPY 	NUMBER,
       x_msg_data			OUT NOCOPY 	VARCHAR2) IS

 l_xtr_bank_balances_rec  XTR_BANK_BALANCES%ROWTYPE;
 l_bank_account_id  CE_BANK_ACCT_USES_ALL.BANK_ACCOUNT_ID%TYPE;
 l_cashpool_id      CE_CASHPOOLS.CASHPOOL_ID%TYPE;
 l_conc_account_id  CE_CASHPOOL_SUB_ACCTS.ACCOUNT_ID%TYPE;


      cursor c_bank_account_id is
           select bank_account_id from ce_bank_acct_uses_all
           where bank_account_id = (select bank_account_id from
                                    ce_bank_acct_balances
                                    where bank_acct_balance_id =
                                    p_ce_bank_account_balance_id)
           and xtr_use_enable_flag = 'Y';


      cursor c_conc_cashpool_id is
           select sub.cashpool_id, sub.account_id
           from  ce_bank_acct_uses_all acct
	       , ce_Cashpool_sub_accts sub
	   where acct.bank_account_id = sub.account_id
           and acct.xtr_use_enable_flag = 'Y'
	   and sub.type = 'CONC'
           and cashpool_id = (select subacct.cashpool_id
	                      from ce_cashpool_sub_accts  subacct
                                   , ce_cashpools pool
   			      where account_id = l_bank_account_id
                              and subacct.cashpool_id = pool.cashpool_id
		              and pool.type = 'NOTIONAL' );


BEGIN

        l_xtr_bank_balances_rec.ce_bank_account_balance_id	:=	p_ce_bank_account_balance_id;
	l_xtr_bank_balances_rec.company_code	:=	p_company_code;
	l_xtr_bank_balances_rec.account_number	:=	p_account_number;
	l_xtr_bank_balances_rec.balance_date	:=	p_balance_date;
	l_xtr_bank_balances_rec.statement_balance	:=	nvl(p_ledger_balance,0);
	l_xtr_bank_balances_rec.balance_adjustment	:=	(nvl(p_interest_calculated_balance,0) - nvl(p_ledger_balance,0));
	l_xtr_bank_balances_rec.balance_cflow	:=	nvl(p_available_balance,0);
	l_xtr_bank_balances_rec.one_day_float	:=	p_one_day_float;
	l_xtr_bank_balances_rec.two_day_float	:=	p_two_day_float;


         -- added for notional bank accounts

      open c_bank_account_id;
      fetch c_bank_account_id into l_bank_account_id;

      if c_bank_account_id%found  then

    	      REPLICATE_BANK_BALANCE( l_xtr_bank_balances_rec,p_action_flag
                            ,x_return_status,x_msg_count,x_msg_data);


     else

          open c_conc_cashpool_id;
          fetch c_conc_cashpool_id into l_cashpool_id, l_conc_account_id;
          if c_conc_cashpool_id%found then
                close c_conc_cashpool_id;
                xtr_account_bal_maint_p.maintain_setoffs(p_company_code,
                                                            l_cashpool_id,
                                                            l_conc_account_id,
                                                            p_balance_date);

          else
              close c_conc_cashpool_id;
              x_return_status := FND_API.G_RET_STS_SUCCESS;

          end if;


     end if;

     close c_bank_account_id;



    EXCEPTION

      WHEN others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          LOG_ERR_MSG ('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));

      FND_MSG_PUB.Count_And_Get -- Returns the error message if there is only 1 error
    (   p_count         =>      x_msg_count     ,
        p_data          =>      x_msg_data
    );

END REPLICATE_BANK_BALANCE;




PROCEDURE INSERT_BANK_BALANCE
     ( p_balance_rec IN xtr_bank_balances%ROWTYPE,
       x_return_status   	 IN	OUT NOCOPY  	VARCHAR2
     )
IS

l_prv_date  XTR_BANK_BALANCES.balance_date%TYPE;
l_prv_rate  XTR_BANK_BALANCES.interest_rate%TYPE;
l_prv_bal   XTR_BANK_BALANCES.balance_cflow%TYPE;
l_int_bf    XTR_BANK_BALANCES.ACCUM_INT_CFWD%TYPE;
l_prv_accrual_int XTR_BANK_BALANCES.accrual_interest%TYPE;
l_prv_day_count_type  XTR_BANK_BALANCES.day_count_type%TYPE;
l_prv_rounding_type   XTR_BANK_BALANCES.rounding_type%TYPE;


l_ccy   xtr_bank_accounts.currency%TYPE;
l_portfolio_code  xtr_bank_accounts.portfolio_code%TYPE;
l_bank_code  xtr_bank_accounts.bank_code%TYPE;
l_yr_type  xtr_bank_accounts.year_calc_type%TYPE;
l_rounding_type   xtr_bank_accounts.rounding_type%TYPE;
l_day_count_type  xtr_bank_accounts.day_count_type%TYPE;
l_ce_bank_account_id    xtr_bank_accounts.ce_bank_account_id%TYPE;

l_round_factor XTR_MASTER_CURRENCIES_V.ROUNDING_FACTOR%TYPE;
l_yr_basis  XTR_MASTER_CURRENCIES_V.YEAR_BASIS%TYPE;
l_hce_rate  XTR_MASTER_CURRENCIES_V.HCE_RATE%TYPE;

l_prv_prv_day_count_type XTR_BANK_BALANCES.day_count_type%TYPE;
l_oldest_date  XTR_BANK_BALANCES.balance_date%TYPE;

l_first_trans_flag  VARCHAR2(1);
l_invest_limit_code ce_bank_acct_uses_all.investment_limit_code%TYPE;
l_fund_limit_code ce_bank_acct_uses_all.funding_limit_code%TYPE;


l_no_days NUMBER;


l_int_cf    NUMBER;
l_interest  NUMBER;
l_original_amount NUMBER;
l_accrual_int NUMBER;
l_new_rate  NUMBER;


 -- Get the details of the latest balance for a bank account
CURSOR PREV_DETAILS IS
   SELECT a.BALANCE_DATE,NVL(a.STATEMENT_BALANCE,0)+NVL(a.BALANCE_ADJUSTMENT,0),a.ACCUM_INT_CFWD,
          a.INTEREST_RATE,a.accrual_interest,
          a.rounding_type, day_count_type
   FROM XTR_BANK_BALANCES a
   WHERE a.ACCOUNT_NUMBER = p_balance_rec.account_number
   AND   a.COMPANY_CODE = p_balance_rec.company_code
   AND   a.BALANCE_DATE = (SELECT max(b.BALANCE_DATE)
                           FROM XTR_BANK_BALANCES b
                           WHERE b.ACCOUNT_NUMBER = p_balance_rec.account_number
			               AND   b.COMPANY_CODE   = p_balance_rec.company_code);


-- Check whether the bank account exist in the xtr_bank_accounts table
CURSOR BANK_ACCT_DETAILS IS
  SELECT CURRENCY,PORTFOLIO_CODE,BANK_CODE,nvl(YEAR_CALC_TYPE,'ACTUAL/ACTUAL') year_calc_type,rounding_type, day_count_type,ce_bank_account_id
  FROM XTR_BANK_ACCOUNTS
  WHERE ACCOUNT_NUMBER = p_balance_rec.account_number
  AND   PARTY_CODE     = p_balance_rec.company_code;
--

-- Get the details of the rounding factor for the currency
CURSOR CURRENCY_RNDING IS
  SELECT ROUNDING_FACTOR,YEAR_BASIS,HCE_RATE
  FROM  XTR_MASTER_CURRENCIES_V
  WHERE CURRENCY = l_ccy;



-- Getting the limit code
CURSOR GET_LIM_CODE is
  select investment_limit_code, funding_limit_code
  from ce_bank_acct_uses_all
  where bank_account_id in ( select bank_account_id from
               ce_bank_acct_balances
              where bank_acct_balance_id = p_balance_rec.ce_bank_account_balance_id
              );


-- Getting the oldest balacne date for that bank account
CURSOR oldest_date IS
    SELECT MIN(a.balance_date)
    FROM   xtr_bank_balances a
    WHERE a.account_number = p_balance_rec.account_number
    AND a.COMPANY_CODE = p_balance_rec.company_code;


CURSOR PRV_PRV_DETAILS IS
    SELECT a.day_count_type
    FROM xtr_bank_balances a
    WHERE  a.account_number = p_balance_rec.account_number
    AND a.COMPANY_CODE = p_balance_rec.company_code
    AND a.balance_date = (SELECT max(b.BALANCE_DATE)
                           FROM XTR_BANK_BALANCES b
                           WHERE b.ACCOUNT_NUMBER = p_balance_rec.account_number
			               AND   b.COMPANY_CODE   = p_balance_rec.company_code
			               AND   b.balance_date < l_prv_date);





BEGIN
   -- x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    OPEN PREV_DETAILS;
    FETCH PREV_DETAILS INTO l_prv_date,l_prv_bal,l_int_bf,l_prv_rate,l_prv_accrual_int,
                            l_prv_rounding_type, l_prv_day_count_type;
    IF  PREV_DETAILS%NOTFOUND THEN
        l_prv_date := trunc(p_balance_rec.balance_date);
        l_prv_bal  := 0;
        l_prv_rate := 0;
        l_int_bf   := 0;
        l_no_days  := 0;
        l_prv_accrual_int := 0;
        l_prv_rounding_type := NULL;
        l_prv_day_count_type := NULL;
    END IF;
    CLOSE PREV_DETAILS;


    OPEN BANK_ACCT_DETAILS;
    FETCH BANK_ACCT_DETAILS INTO l_ccy,l_portfolio_code,l_bank_code,
                           l_yr_type, l_rounding_type, l_day_count_type,l_ce_bank_account_id;
    IF  BANK_ACCT_DETAILS%FOUND THEN
    CLOSE BANK_ACCT_DETAILS;

        OPEN CURRENCY_RNDING;
        FETCH CURRENCY_RNDING INTO l_round_factor,l_yr_basis,l_hce_rate;
        CLOSE CURRENCY_RNDING;

-- bug 4870347
      open GET_LIM_CODE;
       FETCH GET_LIM_CODE INTO l_invest_limit_code, l_fund_limit_code;
       IF GET_LIM_CODE%NOTFOUND  THEN
          l_invest_limit_code := NULL;
          l_fund_limit_code := NULL;
        END IF;
     	CLOSE GET_LIM_CODE;

       OPEN oldest_date;
       FETCH oldest_date INTO l_oldest_date;
       CLOSE oldest_date;
       --
       IF trunc(l_prv_date) <  trunc(p_balance_rec.balance_date) THEN

  	            OPEN prv_prv_details;
                FETCH prv_prv_details INTO l_prv_prv_day_count_type;
                CLOSE prv_prv_details;
                IF (l_prv_day_count_type ='B' AND l_prv_date = l_oldest_date)
	               OR (l_prv_prv_day_count_type ='F' AND l_prv_day_count_type ='B' ) THEN
	                 l_first_trans_flag :='Y';
        	    ELSE
	                 l_first_trans_flag :=NULL;
	            END IF;

	            XTR_CALC_P.CALC_DAYS_RUN(trunc(l_prv_date),
			           trunc(p_balance_rec.balance_date),
				       l_yr_type,
			    	   l_no_days,
				       l_yr_basis,
				       NULL,
				       l_prv_day_count_type,
				       l_first_trans_flag);


	           IF l_prv_date <> l_oldest_date AND
	           ((Nvl(l_prv_prv_day_count_type,l_prv_day_count_type) ='L' AND l_prv_day_count_type ='F')
	           OR (Nvl(l_prv_prv_day_count_type,l_prv_day_count_type) ='B' AND l_prv_day_count_type ='F'))
	           THEN
	                 l_no_days := l_no_days -1;
	           END IF;

       ELSE
              l_no_days :=0;
              l_yr_basis :=365;
       END IF;

     /* Commented the below line in R12. Interest is calculated using CE API
       l_interest := xtr_fps2_p.interest_round(l_prv_bal * l_prv_rate / 100 * l_no_days
						     / l_yr_basis,l_round_factor,l_prv_rounding_type); */
    -- Added the below line R12 Bug 4593594
        CE_INTEREST_CALC.int_cal_xtr( trunc(l_prv_date),
            trunc(p_balance_rec.balance_date),
            l_ce_bank_account_id,
            l_prv_rate,
            'TREASURY',
            l_interest );


       l_original_amount := l_int_bf + nvl(l_interest,0);
       l_int_cf := l_original_amount;

       l_accrual_int :=nvl(l_prv_accrual_int,0) + nvl(l_interest,0);


/*
       XTR_ACCOUNT_BAL_MAINT_P.FIND_INT_RATE(p_balance_rec.account_number
                            , p_balance_rec.statement_balance
                            , p_balance_rec.company_code
                            , l_bank_code
                            , l_ccy
                            , p_balance_rec.balance_date
                            , l_new_rate);
*/
        l_new_rate := CE_INTEREST_CALC.GET_INTEREST_RATE(l_ce_bank_account_id,p_balance_rec.balance_date
                                ,NVL(p_balance_rec.STATEMENT_BALANCE,0)+NVL(p_balance_rec.BALANCE_ADJUSTMENT,0)
                                ,l_new_rate);
        IF l_new_rate IS NULL THEN
            l_new_rate := 0;
        END IF;

        INSERT INTO XTR_BANK_BALANCES
        ( company_code
         ,account_number
         ,balance_date
         ,no_of_days
         ,statement_balance
         ,balance_adjustment
         ,balance_cflow
         ,accum_int_bfwd
         ,interest
         ,interest_rate
         ,interest_settled
         ,interest_settled_hce
         ,accum_int_cfwd
         ,limit_code
         ,created_on
         ,created_by
         ,accrual_interest
         ,rounding_type
         ,day_count_type
         ,original_amount
         ,one_day_float
         ,two_day_float
         ,ce_bank_account_balance_id)
          VALUES
        ( p_balance_rec.company_code
         ,p_balance_rec.account_number
         ,p_balance_rec.balance_date
         ,l_no_days
         ,p_balance_rec.statement_balance
         ,p_balance_rec.balance_adjustment
         ,p_balance_rec.balance_cflow
         ,l_int_bf
         ,nvl(l_interest,0)
         ,l_new_rate
         ,0
         ,0
         ,l_int_cf
         ,decode(sign(nvl(p_balance_rec.statement_balance,0)), -1,l_fund_limit_code,l_invest_limit_code)
         ,sysdate
         ,fnd_global.user_id
         ,l_accrual_int
         ,l_rounding_type
         ,l_day_count_type
         ,l_original_amount
         ,p_balance_rec.one_day_float
         ,p_balance_rec.two_day_float
         ,p_balance_rec.ce_bank_account_balance_id);

   ELSE
        CLOSE BANK_ACCT_DETAILS;
        LOG_ERR_MSG('XTR_INV_PARAM', p_balance_rec.ce_bank_account_balance_id);
        x_return_status := FND_API.G_RET_STS_ERROR;

   END IF;

EXCEPTION

          WHEN others THEN
          x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
          LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));

END INSERT_BANK_BALANCE ;




PROCEDURE UPDATE_BANK_BALANCE
     ( p_balance_rec IN xtr_bank_balances%ROWTYPE,
       x_return_status   	IN	OUT NOCOPY  	VARCHAR2
       )
IS

CURSOR c_chk_lock IS
SELECT ce_bank_account_balance_id
FROM  xtr_bank_balances
WHERE  company_code = p_balance_rec.company_code
       AND  account_number = p_balance_rec.account_number
       AND  ce_bank_account_balance_id = p_balance_rec.ce_bank_account_balance_id
FOR UPDATE NOWAIT;


l_ce_bank_acct_bal_id  xtr_bank_balances.ce_bank_account_balance_id%TYPE;


BEGIN
      --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      OPEN c_chk_lock;
      FETCH c_chk_lock INTO  l_ce_bank_acct_bal_id;
      IF c_chk_lock%FOUND THEN

      CLOSE c_chk_lock;

      UPDATE xtr_bank_balances SET
              statement_balance = nvl(p_balance_rec.statement_balance,0)
             ,balance_cflow = nvl(p_balance_rec.balance_cflow,0)
             ,one_day_float = nvl(p_balance_rec.one_day_float,0)
             ,two_day_float = nvl(p_balance_rec.two_day_float,0)
             ,balance_adjustment = p_balance_rec.balance_adjustment
             ,balance_date = p_balance_rec.balance_date
             ,updated_by = fnd_global.user_id
             ,updated_on = sysdate
       WHERE  company_code = p_balance_rec.company_code
       AND  account_number = p_balance_rec.account_number
       AND  ce_bank_account_balance_id = p_balance_rec.ce_bank_account_balance_id;

      ELSE
      CLOSE c_chk_lock;
      END IF;


    EXCEPTION
        WHEN app_exceptions.RECORD_LOCK_EXCEPTION THEN
            IF C_CHK_LOCK%ISOPEN THEN
                CLOSE C_CHK_LOCK;
            END IF;
            LOG_ERR_MSG('CHK_LOCK');
            x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN others THEN
          x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
          LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));

END UPDATE_BANK_BALANCE;



PROCEDURE DELETE_BANK_BALANCE
     ( p_balance_rec IN xtr_bank_balances%ROWTYPE,
       x_return_status   	  IN OUT NOCOPY  	VARCHAR2
       )
IS

l_cross_ref  xtr_party_info.cross_ref_to_other_party%TYPE;
l_exists   VARCHAR2(1);
l_ce_bank_acct_bal_id  xtr_bank_balances.ce_bank_account_balance_id%TYPE;
l_ccy xtr_bank_accounts.currency%TYPE;

-- Finding the subsidiary for the company
CURSOR C_CROSS_REF IS
   SELECT CROSS_REF_TO_OTHER_PARTY
   FROM   XTR_PARTIES_V
   WHERE  PARTY_CODE = p_balance_rec.company_code;


-- Finding the currency for the account number and company combination
CURSOR C_CURRENCY IS
  SELECT CURRENCY
  FROM  XTR_BANK_ACCOUNTS
  WHERE PARTY_CODE = P_BALANCE_REC.COMPANY_CODE
  AND ACCOUNT_NUMBER = P_BALANCE_REC.ACCOUNT_NUMBER;


 -- Checking whether the row exists in the DDA table
CURSOR C_BAL_SETTLED IS
   SELECT 'Y'
   FROM xtr_deal_date_amounts
   WHERE DEAL_TYPE   = 'CA'
   AND  AMOUNT_TYPE  = 'INTSET'
   AND  ACCOUNT_NO   = p_balance_rec.account_number
   AND  CURRENCY     = l_ccy
   AND  COMPANY_CODE = nvl(l_cross_ref,p_balance_rec.company_code)
   AND  AMOUNT_DATE  = p_balance_rec.balance_date;

-- Checking the lock on the xtr_bank_balances table
CURSOR c_chk_acct_lock IS
   SELECT ce_bank_account_balance_id
   FROM  xtr_bank_balances
   WHERE  company_code = p_balance_rec.company_code
   AND  account_number = p_balance_rec.account_number
   AND  ce_bank_account_balance_id = p_balance_rec.ce_bank_account_balance_id
   FOR UPDATE NOWAIT;

-- Checking the lock on the xtr_deal_date_amounts table
CURSOR c_chk_dda_lock IS
   SELECT ce_bank_account_balance_id
   FROM  xtr_bank_balances
   WHERE  company_code = p_balance_rec.company_code
   AND  account_number = p_balance_rec.account_number
   AND  ce_bank_account_balance_id = p_balance_rec.ce_bank_account_balance_id
   FOR UPDATE NOWAIT;


BEGIN
      --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      OPEN c_chk_acct_lock;
      FETCH c_chk_acct_lock INTO  l_ce_bank_acct_bal_id;
      IF c_chk_acct_lock%FOUND THEN

            CLOSE c_chk_acct_lock;

            OPEN C_CROSS_REF;
            FETCH C_CROSS_REF INTO l_cross_ref;
            CLOSE C_CROSS_REF;

            DELETE FROM XTR_BANK_BALANCES
            WHERE company_code = p_balance_rec.company_code
            AND account_number = p_balance_rec.account_number
            AND balance_date = p_balance_rec.balance_date
            AND ce_bank_account_balance_id = p_balance_rec.ce_bank_account_balance_id;


      ELSE
            CLOSE c_chk_acct_lock;

      END IF;

      OPEN C_CURRENCY;
      FETCH C_CURRENCY INTO l_ccy;
      CLOSE C_CURRENCY;

      OPEN C_bal_settled;
      FETCH C_bal_settled INTO l_exists;

      OPEN c_chk_dda_lock;
      FETCH c_chk_dda_lock INTO  l_ce_bank_acct_bal_id;
      IF c_chk_dda_lock%FOUND THEN

            CLOSE c_chk_dda_lock;

            IF c_bal_settled%FOUND THEN

                 DELETE FROM XTR_DEAL_DATE_AMOUNTS_V
                      WHERE DEAL_TYPE   = 'CA'
                      AND  AMOUNT_TYPE  = 'INTSET'
                      AND  ACCOUNT_NO   = p_balance_rec.account_number
                      AND  CURRENCY     = l_ccy
                      AND  COMPANY_CODE = nvl(l_cross_ref,p_balance_rec.company_code)
                      AND  AMOUNT_DATE  = p_balance_rec.balance_date;

            END IF;
            CLOSE c_bal_settled;
      ELSE
            CLOSE c_chk_dda_lock;

      END IF;


EXCEPTION
        WHEN app_exceptions.RECORD_LOCK_EXCEPTION THEN

             IF C_CHK_acct_LOCK%ISOPEN THEN
                CLOSE C_CHK_acct_LOCK;
             END IF;

             IF C_CHK_DDA_LOCK%ISOPEN THEN
                CLOSE C_CHK_DDA_LOCK;
             END IF;

             LOG_ERR_MSG('CHK_LOCK');
             x_return_status := FND_API.G_RET_STS_ERROR;


        WHEN others THEN

           LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));
           x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;

END DELETE_BANK_BALANCE;



PROCEDURE VALIDATE_BANK_BALANCE
     ( p_company_code IN xtr_bank_balances.company_code%TYPE,
       p_account_number IN xtr_bank_balances.account_number%TYPE,
       p_balance_date IN xtr_bank_balances.balance_date%TYPE,
       p_ce_bank_account_balance_id IN xtr_bank_balances.ce_bank_account_balance_id%TYPE DEFAULT NULL,
       p_interest_calc_balance IN NUMBER,
       p_available_balance IN NUMBER,
       p_action_flag IN VARCHAR2,
       x_return_status   		OUT NOCOPY  	VARCHAR2
       )
IS

l_portfolio_code     xtr_bank_accounts.portfolio_code%TYPE;
l_currency           xtr_bank_accounts.currency%TYPE;
l_bank_code     xtr_bank_accounts.bank_code%TYPE;
l_result        BOOLEAN;
l_duplicate     NUMBER;
l_return_error  VARCHAR2(30);
l_authorised    VARCHAR2(1);
l_ce_bank_account_id xtr_bank_accounts.ce_bank_account_id%TYPE ;
l_int_schedule_id ce_bank_accounts.interest_schedule_id%TYPE ;
l_pricing_model  xtr_bank_accounts.pricing_model%TYPE;


-- Check whether the portfolio code exists for the bank account for which balacnes
-- are to be entered
CURSOR C_PORTFOLIO IS
   SELECT PORTFOLIO_CODE, CURRENCY , BANK_CODE, PRICING_MODEL,
	  ce_bank_account_id		/* Bug 5346243 */
   FROM  xtr_bank_accounts
   WHERE ACCOUNT_NUMBER = p_account_number
   AND   PARTY_CODE     = p_company_code;


-- Check whether the balance does not already exist for
CURSOR C_DUPLICATE_DATE IS
  SELECT 1
   FROM  XTR_BANK_BALANCES_V A,
         XTR_BANK_ACCOUNTS_V B
   WHERE A.BALANCE_DATE   = p_balance_date
   AND   A.ACCOUNT_NUMBER = B.ACCOUNT_NUMBER
   AND   A.COMPANY_CODE   = B.PARTY_CODE
   AND   B.CURRENCY       = l_currency
   AND   B.ACCOUNT_NUMBER = p_account_number
   AND   B.BANK_CODE      = l_bank_code
   AND   B.PARTY_CODE     = p_company_code;


cursor c_pm_authorized is
   select 1
   from   xtr_price_models_v
   where  deal_type = 'CA'
   and    code = l_pricing_model
   and    authorized = 'Y';

/* Bug 5346243 */

Cursor c_int_schedule ( l_ce_bank_account_id Number ) Is
Select interest_schedule_id
From   ce_bank_accounts
Where  bank_account_id = l_ce_bank_account_id ;



BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

OPEN c_portfolio;
FETCH c_portfolio INTO l_portfolio_code, l_currency,l_bank_code, l_pricing_model, l_ce_bank_account_id ;

-- Validation at the time of insertion/updation of the record


       IF   p_action_flag IN ( 'I' , 'U') THEN

             IF   p_action_flag  =  'I' AND  (l_portfolio_code Is null)  THEN
 --  Checking whether the portfolio code exists for the bank account
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    LOG_ERR_MSG ( 'XTR_PORTFOLIO');
             END IF;

CLOSE c_portfolio;

 --  Checking whether the balance date is greater than sysdate
               IF p_balance_date > sysdate THEN
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  LOG_ERR_MSG ( 'XTR_104');
               END IF;

 -- Checking whether an interest schedule is assigned to the bank account
 /* Bug 5346243 */
		Open	c_int_schedule(l_ce_bank_account_id) ;
		fetch	c_int_schedule into l_int_schedule_id ;
		close	c_int_schedule ;

		If l_int_schedule_id is Null Then
			x_return_status := FND_API.G_RET_STS_ERROR;
			LOG_ERR_MSG ( 'CE_NO_SCHED_BANK_ACCT');
		End If ;

 -- Checking whether the pricing model is authorised
    If l_pricing_model Is Not Null Then
              OPEN c_pm_authorized;
              FETCH c_pm_authorized into l_authorised;
              if c_pm_authorized%NOTFOUND then
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  LOG_ERR_MSG ( 'XTR_INV_PRICING_MODEL');
              end if;
              close c_pm_authorized;
    End If ;

 -- Checking the balance does not exist for the date being entered by the user
              OPEN c_duplicate_date;
              FETCH c_duplicate_date INTO l_duplicate;
              IF c_duplicate_date%FOUND AND p_action_flag = 'I' THEN
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  LOG_ERR_MSG ( 'XTR_1237');
              END IF;
              CLOSE c_duplicate_date;
-- Checking for interest includes/ interest rounding
              IF ((NOT CHK_ROUNDING_CHANGE ( p_company_code ,p_account_number ,p_balance_date )) AND p_interest_calc_balance IS NOT NULL) THEN
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  LOG_ERR_MSG ( 'XTR_TYPES_CHANGED');
              END IF;

-- Checking for revaluations

              l_return_error := chk_reval( p_company_code,
                                      p_account_number,
                                      l_currency,
                                      p_balance_date,
                                      p_ce_bank_account_balance_id,
                                      p_available_balance,
                                      p_action_flag,
                                      'E');


               IF nvl(l_return_error, 'XXX') = 'XTR_CA_REVAL_DONE' THEN
                      x_return_status := FND_API.G_RET_STS_ERROR;
                       LOG_ERR_MSG ( 'XTR_CA_REVAL_DONE');
               ELSIF nvl(l_return_error, 'XXX') = 'XTR_REVAL_ACCRL_DATE' THEN
                      x_return_status := FND_API.G_RET_STS_ERROR;
                       LOG_ERR_MSG ( 'XTR_REVAL_ACCRL_DATE',p_balance_date);
               ELSIF nvl(l_return_error, 'XXX') = 'XTR_BANK_REVAL_DONE' THEN
                      x_return_status := FND_API.G_RET_STS_ERROR;
                       LOG_ERR_MSG ( 'XTR_BANK_REVAL_DONE',p_balance_date);
               END IF;


 -- Checking for accruals

              l_return_error := chk_accrual( p_company_code,
                                      p_account_number,
                                      l_currency,
                                      p_balance_date,
                                      p_ce_bank_account_balance_id,
                                      p_interest_calc_balance,
                                      p_action_flag,
                                      'E');

               IF nvl(l_return_error, 'XXX') = 'XTR_BANK_ACCRLS_EXIST' THEN
                      x_return_status := FND_API.G_RET_STS_ERROR;
                       LOG_ERR_MSG ( 'XTR_BANK_ACCRLS_EXIST',p_balance_date);

               ELSIF nvl(l_return_error, 'XXX') = 'XTR_REVAL_ACCRL_DATE' THEN
                      x_return_status := FND_API.G_RET_STS_ERROR;
                       LOG_ERR_MSG ( 'XTR_REVAL_ACCRL_DATE',p_balance_date);
               END IF;

       ELSIF  p_action_flag = 'D'  THEN

              CLOSE c_portfolio;


               -- Checking for interest includes/ interest rounding

              IF ((NOT CHK_ROUNDING_CHANGE( p_company_code ,p_account_number ,p_balance_date )) AND p_interest_calc_balance IS NOT NULL) THEN
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  LOG_ERR_MSG ( 'XTR_CHANGED_DAYCOUNT_ROUND');
              END IF;

              -- Checking for revaluations
              l_return_error := chk_reval( p_company_code,
                                      p_account_number,
                                      l_currency,
                                      p_balance_date,
                                      p_ce_bank_account_balance_id,
                                      p_available_balance,
                                      'D',
                                      'E');

               IF nvl(l_return_error, 'XXX') = 'XTR_ACCT_DELETE' THEN
                      x_return_status := FND_API.G_RET_STS_ERROR;
                       LOG_ERR_MSG ( 'XTR_ACCT_DELETE');
               END IF;


              -- Checking for accruals
              l_return_error := chk_accrual( p_company_code,
                                      p_account_number,
                                      l_currency,
                                      p_balance_date,
                                      p_ce_bank_account_balance_id,
                                      p_interest_calc_balance,
                                      'D',
                                      'E');

               IF nvl(l_return_error, 'XXX') = 'XTR_DEAL_ACCRLS_EXIST' THEN
                      x_return_status := FND_API.G_RET_STS_ERROR;
                      LOG_ERR_MSG ( 'XTR_DEAL_ACCRLS_EXIST',p_balance_date);
               END IF;

       END IF ;  --  p_action_flag

EXCEPTION
  WHEN others THEN

           LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));
           x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;

END VALIDATE_BANK_BALANCE;


PROCEDURE VALIDATE_BANK_BALANCE
    ( p_company_code IN xtr_bank_balances.company_code%TYPE,
      p_account_number IN xtr_bank_balances.account_number%TYPE,
      p_balance_date IN xtr_bank_balances.balance_date%TYPE,
      p_ce_bank_account_balance_id IN xtr_bank_balances.ce_bank_account_balance_id%TYPE default null,
      p_interest_calc_balance IN NUMBER,
      p_available_balance in NUMBER,
      p_action_flag IN VARCHAR2,
      x_return_status   		OUT NOCOPY  	VARCHAR2,
      x_msg_count			OUT NOCOPY 	NUMBER,
      x_msg_data			OUT NOCOPY 	VARCHAR2) IS

CURSOR C_BALANCE_DETAILS IS
    SELECT company_code,account_number,balance_date,statement_balance
            ,balance_adjustment,balance_cflow,ce_bank_account_balance_id
    FROM XTR_BANK_BALANCES
    WHERE CE_BANK_ACCOUNT_BALANCE_ID = p_ce_bank_account_balance_id;


    l_balance_date_updated BOOLEAN;
    l_balance_rec XTR_BANK_BALANCES%ROWTYPE;

BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_balance_date_updated := FALSE;
        FND_MSG_PUB.Initialize;
        IF(p_action_flag in ('U','D')) THEN

            OPEN C_BALANCE_DETAILS;
            FETCH C_BALANCE_DETAILS INTO l_balance_rec.company_code,l_balance_rec.account_number
                                ,l_balance_rec.balance_date,l_balance_rec.statement_balance,l_balance_rec.balance_adjustment
                                ,l_balance_rec.balance_cflow,l_balance_rec.ce_bank_account_balance_id;
            CLOSE C_BALANCE_DETAILS;


            IF(nvl(p_balance_date,sysdate) <> nvl(l_balance_rec.balance_date,sysdate)
                AND p_balance_date is not null AND l_balance_rec.balance_date is not null
                AND p_action_flag = 'U') THEN

                l_balance_date_updated := TRUE;

            END IF;

        END IF;

        IF(NOT l_balance_date_updated) THEN -- Balance date is not updated
          IF (p_action_flag in ('I','U') )THEN
            VALIDATE_BANK_BALANCE(
                            p_company_code,
                            p_account_number,
                            p_balance_date,
                            p_ce_bank_account_balance_id,
                            p_interest_calc_balance,
                            p_available_balance,
                            p_action_flag,
                            x_return_status );
        END IF;
        IF (p_action_flag in ('D')) THEN
            VALIDATE_BANK_BALANCE(
                            l_balance_rec.company_code,
                            l_balance_rec.account_number,
                            l_balance_rec.balance_date,
                            p_ce_bank_account_balance_id,
                            l_balance_rec.statement_balance+l_balance_rec.balance_adjustment,
                            l_balance_rec.balance_cflow,
                            'D',
                            x_return_status );
        END IF;

    ELSIF(l_balance_date_updated) THEN

              VALIDATE_BANK_BALANCE(
                            p_company_code,
                            p_account_number,
                            p_balance_date,
                            p_ce_bank_account_balance_id,
                            p_interest_calc_balance,
                            p_available_balance,
                            'D',
                            x_return_status );

              IF  x_return_status = FND_API.G_RET_STS_SUCCESS  THEN
                VALIDATE_BANK_BALANCE(
                            p_company_code,
                            p_account_number,
                            p_balance_date,
                            p_ce_bank_account_balance_id,
                            p_interest_calc_balance,
                            p_available_balance,
                            'I',
                            x_return_status );
            END IF;


    END IF;

    FND_MSG_PUB.Count_And_Get -- Returns the error message if there is only 1 error
    (   p_count         =>      x_msg_count     ,
        p_data          =>      x_msg_data
    );


EXCEPTION

      WHEN others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          LOG_ERR_MSG ('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));

      FND_MSG_PUB.Count_And_Get -- Returns the error message if there is only 1 error
    (   p_count         =>      x_msg_count     ,
        p_data          =>      x_msg_data
    );

END VALIDATE_BANK_BALANCE;




FUNCTION CHK_ACCRUAL ( p_company_code IN xtr_bank_balances.company_code%TYPE
                        , p_account_number IN xtr_bank_balances.account_number%TYPE
                        , p_currency IN xtr_bank_accounts.currency%TYPE
                        , p_balance_date IN xtr_bank_balances.balance_date%TYPE
                        , p_ce_bank_account_balance_id IN xtr_bank_balances.ce_bank_account_balance_id%TYPE DEFAULT NULL
                        , p_interest_calc_balance IN NUMBER
                        , p_action_flag IN VARCHAR2
                        , p_val_type IN VARCHAR2)
                        RETURN VARCHAR2
IS

l__val_type varchar2(1);
l_error VARCHAR2(50);
l_accrual_deal_date   DATE;
l_accrual_batch_date  DATE;
l_interest_calc_balance NUMBER;

-- Check whether the accruals have been run for that particular deal
CURSOR c_accrl_deal  IS
   SELECT max(period_to)
   FROM
          xtr_bank_balances bb, xtr_bank_accounts ba,
          xtr_deal_date_amounts dd, xtr_accrls_amort aa
   WHERE bb.company_code   = p_company_code
   AND   bb.account_number = p_account_number
   AND 	 bb.company_code   = ba.party_code
   AND   bb.account_number = ba.account_number
   AND   ba.currency       = p_currency
   AND 	 bb.company_code   = dd.company_code
   AND   bb.account_number = dd.account_no
   AND   ba.currency       = dd.currency
   AND   dd.deal_number    = aa.deal_no;

-- Check whether the accruals have been run for period greater than the
-- balance date entered by the user
CURSOR c_accrl_comp IS
   SELECT max(period_end)
   FROM
          xtr_batches b, xtr_batch_events e
   WHERE  b.company_code = p_company_code
   AND   b.batch_id     = e.batch_id
   AND   e.event_code   = 'ACCRUAL'
   AND   b.period_end   >=p_balance_date;


-- Getting the interest calc amount from the database for the updated record
CURSOR c_accrl_amount IS
   SELECT BALANCE_ADJUSTMENT + STATEMENT_BALANCE
   FROM
         xtr_bank_balances bb
   WHERE
	     bb.company_code   = p_company_code
   AND   bb.account_number = p_account_number
   AND   ce_bank_account_balance_id = p_ce_bank_account_balance_id;



BEGIN
     IF p_action_flag  IN ('D','U') THEN

         OPEN  c_accrl_deal;
         FETCH c_accrl_deal INTO l_accrual_deal_date;
         CLOSE c_accrl_deal;

         IF l_accrual_deal_date IS NOT NULL AND l_accrual_deal_date >= p_balance_date THEN

                IF p_action_flag = 'U' THEN

                    OPEN  c_accrl_amount;
                    FETCH c_accrl_amount INTO l_interest_calc_balance;
                    CLOSE c_accrl_amount;

                    IF l_interest_calc_balance <> p_interest_calc_balance
                        AND p_val_type = 'E' THEN
                          l_error := 'XTR_DEAL_ACCRLS_EXIST';

                    END IF;

                ELSIF p_action_flag = 'D' AND p_val_type = 'E'THEN
                     	  l_error := 'XTR_DEAL_ACCRLS_EXIST';
	            END IF;
         END IF;
    ELSIF (p_action_flag = 'I'  AND nvl(p_interest_calc_balance,0) <> 0) THEN
            OPEN  c_accrl_deal;
            FETCH c_accrl_deal INTO l_accrual_deal_date;
            CLOSE c_accrl_deal;
            IF l_accrual_deal_date IS NULL THEN
                   OPEN  c_accrl_comp;
                   FETCH c_accrl_comp INTO l_accrual_batch_date;
             	   CLOSE c_accrl_comp;

                   IF l_accrual_batch_date IS NOT NULL
                          AND l_accrual_batch_date >= p_balance_date AND p_val_type = 'W' THEN
                           l_error := 'XTR_DEALS_BEFORE_ACCRUAL'; -- Warning message

                   END IF;
            ELSIF l_accrual_deal_date IS NOT NULL
                         AND l_accrual_deal_date >= p_balance_date AND p_val_type = 'E' THEN

                          l_error := 'XTR_DEALS_ACCRLS_EXIST';

            END IF;


    END IF; -- p_action_flag
RETURN l_error;
END CHK_ACCRUAL;



-- This function checks whether the revaluations have been run at the time of
-- insertion/updation/deletion

FUNCTION    CHK_REVAL ( p_company_code IN xtr_bank_balances.company_code%TYPE
                        , p_account_number IN xtr_bank_balances.account_number%TYPE
                        , p_currency IN xtr_bank_accounts.currency%TYPE
                        , p_balance_date IN xtr_bank_balances.balance_date%TYPE
                        , p_ce_bank_account_balance_id IN xtr_bank_balances.ce_bank_account_balance_id%TYPE DEFAULT NULL
                        , p_balance_cflow IN xtr_bank_balances.balance_cflow%TYPE
                        , p_action_flag IN VARCHAR2
                        , p_val_type IN VARCHAR2 )
                        RETURN VARCHAR2
IS

l_error VARCHAR2(50);
l_reval_deal_date   DATE;
l_reval_batch_date  DATE;
l_reval_delete_date DATE;
l_balance_cflow  xtr_bank_balances.balance_cflow%TYPE;


-- Check whether the revaluations have been run for period greater than the
-- balance date entered by the user
CURSOR c_reval_comp IS
   SELECT max(period_end)
   FROM
         xtr_batches b,xtr_batch_events e
   WHERE
         b.company_code = p_company_code
   AND   b.batch_id     = e.batch_id
   AND   e.event_code   = 'REVAL'
   AND   b.period_end  >= p_balance_date;


CURSOR c_deal_delete IS
   SELECT max(bb.balance_date)
   FROM
         xtr_bank_balances bb,xtr_bank_accounts ba
   WHERE
	 bb.company_code   = p_company_code
   AND   bb.account_number = p_account_number
   AND 	 bb.company_code   = ba.party_code
   AND   bb.account_number = ba.account_number
   AND   ba.currency       = p_currency
   AND   bb.first_batch_id IS NOT NULL;


-- Check whether the revaluations have been run for that particular deal
CURSOR c_reval_deal IS
   SELECT max(period_to)
   FROM
         xtr_bank_balances bb,xtr_bank_accounts ba,
         xtr_revaluation_details rd
   WHERE
	     bb.company_code   = p_company_code
   AND   bb.account_number = p_account_number
   AND 	 bb.company_code   = ba.party_code
   AND   bb.account_number = ba.account_number
   AND   ba.currency       = p_currency
   AND   bb.account_number = rd.account_no
   AND   rd.deal_type      = 'CA';

-- Getting the cashflow amount from the database for the updated record
CURSOR c_reval_amount IS
   SELECT BALANCE_CFLOW
   FROM
         xtr_bank_balances bb
   WHERE
	     bb.company_code   = p_company_code
   AND   bb.account_number = p_account_number
   AND   ce_bank_account_balance_id = p_ce_bank_account_balance_id;



BEGIN
  -- checking at time of updation of balance
   IF p_action_flag = 'U' THEN

       OPEN   c_reval_deal;
	   FETCH  c_reval_deal INTO l_reval_deal_date;
       CLOSE  c_reval_deal;

       IF l_reval_deal_date IS NOT NULL AND l_reval_deal_date >= p_balance_date THEN
           -- checks whether the changed amount is same as the database amount
            OPEN   c_reval_amount;
	        FETCH  c_reval_amount INTO l_balance_cflow;
            CLOSE  c_reval_amount;
            IF (l_balance_cflow <> p_balance_cflow AND p_val_type = 'E')THEN
                  l_error := 'XTR_DEAL_REVAL_DONE';
            END IF;

        END IF;

   -- checking at time deletion of balance
   ELSIF p_action_flag = 'D' THEN

       OPEN  c_deal_delete ;
       FETCH c_deal_delete  INTO l_reval_delete_date;
       CLOSE c_deal_delete ;

       IF l_reval_delete_date IS NOT NULL AND l_reval_delete_date >= p_BALANCE_DATE
           AND p_val_type = 'E'THEN
	       l_error :='XTR_ACCT_DELETE';
	   END IF;

   -- checking at time insertion of balance
   -- Added the condition for checking balance not 0
   ELSIF (p_action_flag = 'I' AND nvl(p_balance_cflow,0) <> 0) THEN

       OPEN  c_reval_deal;
       FETCH c_reval_deal INTO l_reval_deal_date;
       CLOSE c_reval_deal;
       IF l_reval_deal_date IS NULL THEN
           OPEN  c_reval_comp;
           FETCH c_reval_comp INTO l_reval_batch_date;
           CLOSE c_reval_comp;

           IF l_reval_batch_date IS NOT NULL AND l_reval_batch_date >= p_balance_date
              AND p_val_type = 'W' THEN
                 l_error := 'XTR_DEALS_BEFORE_REVAL'; -- warning message
           END IF;

       ELSIF l_reval_deal_date IS NOT NULL AND l_reval_deal_date >= p_balance_date
             AND p_val_type = 'E' THEN
              l_error := 'XTR_CA_REVAL_DONE';

       END IF;

  END IF;  --  p_action_flag

RETURN l_error;

END CHK_REVAL;



PROCEDURE UPDATE_BANK_ACCOUNT
     ( p_company_code IN xtr_bank_balances.company_code%TYPE,
       p_account_number IN xtr_bank_balances.account_number%TYPE,
       p_balance_date IN xtr_bank_balances.balance_date%TYPE,
       p_action_flag IN VARCHAR2,
       x_return_status   OUT NOCOPY  	VARCHAR2
       )
IS

l_ccy   xtr_bank_accounts.currency%TYPE;
l_portfolio_code  xtr_bank_accounts.portfolio_code%TYPE;
l_bank_code  xtr_bank_accounts.bank_code%TYPE;
l_cross_ref  xtr_party_info.cross_ref_to_other_party%TYPE;
l_bal_exists  VARCHAR2(10);
l_dummy_num   VARCHAR2(1);
l_bal_date    xtr_bank_balances.balance_date%TYPE;
l_accum_int_cfwd  xtr_bank_balances.accum_int_cfwd%TYPE;

CURSOR C_SUBSIDIARY IS
   SELECT CROSS_REF_TO_OTHER_PARTY
   FROM   XTR_PARTIES_V
   WHERE  PARTY_CODE = p_company_code;


CURSOR C_ACCT_DETAILS IS
  SELECT CURRENCY,PORTFOLIO_CODE,BANK_CODE
  FROM XTR_BANK_ACCOUNTS
  WHERE ACCOUNT_NUMBER = p_account_number
  AND   PARTY_CODE     = p_company_code;

-- To check whether the 'BAL' row exists in DDA table
CURSOR C_BAL_EXISTS IS
  SELECT 'Y'
  FROM   XTR_DEAL_DATE_AMOUNTS_V
  WHERE  ACCOUNT_NO   = p_account_number
  AND    COMPANY_CODE = nvl(l_cross_ref,p_company_code)
  AND    CURRENCY     = l_ccy
  AND    AMOUNT_DATE  = p_balance_date
  AND    AMOUNT_TYPE  = 'BAL';

-- To find the latest date which is less the than date for the user
-- is deleting the balance

CURSOR C_BAL_DATE IS
  SELECT max(BALANCE_DATE)
  FROM   XTR_BANK_BALANCES_V
  WHERE  ACCOUNT_NUMBER = p_account_number
  AND    COMPANY_CODE   = p_company_code
  AND    BALANCE_DATE   < p_balance_date;


--
CURSOR C_ACCUM_INT IS
 SELECT ACCUM_INT_CFWD
 FROM XTR_BANK_BALANCES
 WHERE ACCOUNT_NUMBER = P_ACCOUNT_NUMBER
 AND COMPANY_CODE = P_COMPANY_CODE
 AND BALANCE_DATE = (SELECT MAX(BALANCE_DATE) FROM
                    XTR_BANK_BALANCES
                    WHERE ACCOUNT_NUMBER = P_ACCOUNT_NUMBER
                    AND COMPANY_CODE = P_COMPANY_CODE);

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS; -- Added Bug 4546183
OPEN C_ACCT_DETAILS;
FETCH C_ACCT_DETAILS INTO l_ccy,l_portfolio_code, l_bank_code;
CLOSE C_ACCT_DETAILS;


OPEN C_SUBSIDIARY;
FETCH C_SUBSIDIARY INTO l_cross_ref;
CLOSE C_SUBSIDIARY;


OPEN C_ACCUM_INT;
FETCH C_ACCUM_INT INTO L_ACCUM_INT_CFWD;
IF l_accum_int_cfwd is null then
   l_accum_int_cfwd := 0 ;
end if;
CLOSE C_ACCUM_INT;

IF p_action_flag = 'I' THEN

          XTR_ACCOUNT_BAL_MAINT_P.UPDATE_BANK_ACCTS(
                  p_account_number,
			      l_ccy,
				  l_bank_code,
				  l_portfolio_code,
				  l_cross_ref,
				  p_company_code,
				  p_balance_date,
				  l_accum_int_cfwd,
				  l_dummy_num
			      );

ELSIF p_action_flag = 'D' THEN

       OPEN C_BAL_EXISTS;
       FETCH C_BAL_EXISTS INTO l_bal_exists;
       IF C_BAL_EXISTS%FOUND THEN
            OPEN C_BAL_DATE;
            FETCH C_BAL_DATE INTO l_bal_date;
            CLOSE C_BAL_DATE;
       END IF;
       CLOSE C_BAL_EXISTS;

       XTR_ACCOUNT_BAL_MAINT_P.UPDATE_BANK_ACCTS(
                  p_account_number,
			      l_ccy,
				  l_bank_code,
				  l_portfolio_code,
				  l_cross_ref,
				  p_company_code,
				  nvl(l_bal_date, p_balance_date),
				  l_accum_int_cfwd,
				  l_dummy_num
			      );

ELSIF p_action_flag = 'U' THEN

       XTR_ACCOUNT_BAL_MAINT_P.UPDATE_BANK_ACCTS(
                  p_account_number,
			      l_ccy,
				  l_bank_code,
				  l_portfolio_code,
				  l_cross_ref,
				  p_company_code,
				  p_balance_date,
				  l_accum_int_cfwd,
				  l_dummy_num
			      );

END IF;

END UPDATE_BANK_ACCOUNT;


/*
  This FUNCTION will be called BY CE AT THE TIME WHEN THE balance page IS rendered
  TO ENABLE/DISABLE THE balance DATE

  THE same fuction will be also called FOR VALIDATION OF THE RECORD during
  insertion/updation/deletion

*/

FUNCTION CHK_ROUNDING_CHANGE ( p_company_code IN xtr_bank_balances.company_code%TYPE,
                               p_account_number IN xtr_bank_balances.account_number%TYPE,
                               p_balance_date IN xtr_bank_balances.balance_date%TYPE)
                               RETURN BOOLEAN IS

 CURSOR c_chk_bal IS
  SELECT count(balance_date)
  FROM XTR_BANK_BALANCES  a
  WHERE a.ACCOUNT_NUMBER = p_account_number
  AND a.COMPANY_CODE = p_company_code;


 CURSOR c_chk_type IS
  SELECT COUNT(DISTINCT ROUNDING_TYPE||'-'||DAY_COUNT_TYPE)
  FROM XTR_BANK_BALANCES  a
  WHERE a.ACCOUNT_NUMBER = p_account_number
  AND a.COMPANY_CODE = p_company_code
  AND a.BALANCE_DATE >=  (SELECT max(balance_date)
			FROM xtr_bank_balances b
			WHERE b.account_number = p_account_number
			AND b.company_code = p_company_code
			AND b.balance_date < p_balance_date);

 l_chk_bal      NUMBER;
 l_count	NUMBER;
BEGIN

 OPEN c_chk_bal;
 FETCH c_chk_bal INTO l_chk_bal;
 CLOSE c_chk_bal;

  IF l_chk_bal >= 1 THEN  -- Bug 5393641
     OPEN c_chk_type;
     FETCH c_chk_type INTO l_count;
     CLOSE c_chk_type;

     IF l_count <= 1 THEN
          RETURN(TRUE);
     ELSE
         RETURN(FALSE);
     END IF;
  ELSE
      RETURN(TRUE);
  END IF;

END CHK_ROUNDING_CHANGE;



/* This function will be called by CE when the one account- multiple balance
 * date page is rendered to enable/disable the balance date and delete button

This will be also called by the validate_bank_balance procedure at the time of
deletion of the record
*/

FUNCTION CHK_INTEREST_SETTLED
        (  p_ce_bank_account_id IN xtr_bank_accounts.ce_bank_account_id%TYPE
           , p_balance_date IN xtr_bank_balances.balance_date%TYPE
        )return VARCHAR2 is

l_return VARCHAR2(2);
l_dummy   VARCHAR2(1);
l_company_code XTR_BANK_ACCOUNTS.party_code%TYPE;
l_account_number XTR_BANK_ACCOUNTS.account_number%TYPE;
l_currency XTR_BANK_ACCOUNTS.currency%TYPE;


  CURSOR c_account_details IS
    SELECT party_code, account_number,currency
    FROM XTR_BANK_ACCOUNTS
    WHERE ce_bank_account_id = p_ce_bank_account_id;

  cursor INT_SETTLED is
  select 'Y'
    from XTR_DEAL_DATE_AMOUNTS_V
   where DEAL_TYPE    = 'CA'
     and AMOUNT_TYPE  = 'INTSET'
     and ACCOUNT_NO   = l_account_number
     and CURRENCY     = l_currency
     and COMPANY_CODE = l_company_code
     and AMOUNT_DATE  = p_balance_date
     and (Batch_Id IS NOT NULL or nvl(SETTLE, 'N') = 'Y');


BEGIN

     l_return := 'Y';

     IF(p_ce_bank_account_id is not null and p_balance_date is not null) THEN

        OPEN c_account_details;
        FETCH c_account_details INTO l_company_code,l_account_number,l_currency;
        CLOSE c_account_details;

        open INT_SETTLED;
        fetch INT_SETTLED into l_dummy;
        if INT_SETTLED%FOUND then
            close INT_SETTLED;
            l_return := 'N';
        else
            close INT_SETTLED;
            l_return := 'Y';
        end if;

     END If;

END CHK_INTEREST_SETTLED;




-- This function will be called by CE at the time when the balabce page is rendered
-- to enable/disable the available balance

FUNCTION CHK_REVAL_ON_RENDER
                       ( p_company_code IN xtr_bank_balances.company_code%TYPE
                        , p_account_number IN xtr_bank_balances.account_number%TYPE
                        , p_currency IN xtr_bank_accounts.currency%TYPE
                        , p_balance_date IN xtr_bank_balances.balance_date%TYPE
                       )RETURN BOOLEAN
IS

l_reval_deal_date   DATE;
l_reval_delete_date DATE;

-- Check whether the revaluations have been run for that particular deal
CURSOR c_reval_deal IS
   SELECT max(period_to)
   FROM
         xtr_bank_balances bb,xtr_bank_accounts ba,
         xtr_revaluation_details rd
   WHERE
	     bb.company_code   = p_company_code
   AND   bb.account_number = p_account_number
   AND 	 bb.company_code   = ba.party_code
   AND   bb.account_number = ba.account_number
   AND   ba.currency       = p_currency
   AND   bb.account_number = rd.account_no
   AND   rd.deal_type      = 'CA';


CURSOR c_deal_delete IS
   SELECT max(bb.balance_date)
   FROM
         xtr_bank_balances bb,xtr_bank_accounts ba
   WHERE
	 bb.company_code   = p_company_code
   AND   bb.account_number = p_account_number
   AND 	 bb.company_code   = ba.party_code
   AND   bb.account_number = ba.account_number
   AND   ba.currency       = p_currency
   AND   bb.first_batch_id IS NOT NULL;

BEGIN

      OPEN   c_reval_deal;
	  FETCH  c_reval_deal INTO l_reval_deal_date;
      CLOSE  c_reval_deal;

      OPEN  c_deal_delete ;
      FETCH c_deal_delete  INTO l_reval_delete_date;
      CLOSE c_deal_delete ;


      IF (l_reval_deal_date IS NOT NULL AND l_reval_deal_date >= p_balance_date)
          OR ( l_reval_delete_date IS NOT NULL AND l_reval_delete_date >= p_BALANCE_DATE) THEN
           RETURN(FALSE);
      ELSE
           RETURN(TRUE);
      END IF;

END CHK_REVAL_ON_RENDER;


-- This function will be called by CE at the time when the balabce page is rendered
-- to enable/disable the interest calculated balance
FUNCTION CHK_ACCRUAL_ON_RENDER
                       ( p_company_code IN xtr_bank_balances.company_code%TYPE
                        , p_account_number IN xtr_bank_balances.account_number%TYPE
                        , p_currency IN xtr_bank_accounts.currency%TYPE
                        , p_balance_date IN xtr_bank_balances.balance_date%TYPE
                       )RETURN BOOLEAN
IS

l_accrual_deal_date   DATE;

-- Check whether the accruals have been run for that particular deal
CURSOR c_accrl_deal  IS
   SELECT max(period_to)
   FROM
          xtr_bank_balances bb, xtr_bank_accounts ba,
          xtr_deal_date_amounts dd, xtr_accrls_amort aa
   WHERE bb.company_code   = p_company_code
   AND   bb.account_number = p_account_number
   AND 	 bb.company_code   = ba.party_code
   AND   bb.account_number = ba.account_number
   AND   ba.currency       = p_currency
   AND 	 bb.company_code   = dd.company_code
   AND   bb.account_number = dd.account_no
   AND   ba.currency       = dd.currency
   AND   dd.deal_number    = aa.deal_no;



BEGIN

OPEN  c_accrl_deal;
      FETCH c_accrl_deal INTO l_accrual_deal_date;
      CLOSE c_accrl_deal;

      IF l_accrual_deal_date IS NOT NULL AND l_accrual_deal_date >= p_balance_date THEN
            RETURN(FALSE);
      ELSE
            RETURN(TRUE);
      END IF;

END CHK_ACCRUAL_ON_RENDER;

FUNCTION CHK_ACCRUAL_ON_RENDER
                       (  p_ce_bank_account_id IN xtr_bank_accounts.ce_bank_account_id%TYPE
                        , p_balance_date IN xtr_bank_balances.balance_date%TYPE
                       )return VARCHAR2 is
l_return VARCHAR2(2);
l_company_code XTR_BANK_ACCOUNTS.party_code%TYPE;
l_account_number XTR_BANK_ACCOUNTS.account_number%TYPE;
l_currency XTR_BANK_ACCOUNTS.currency%TYPE;
CURSOR c_account_details IS
    SELECT party_code, account_number,currency
    FROM XTR_BANK_ACCOUNTS
    WHERE ce_bank_account_id = p_ce_bank_account_id;
BEGIN
    l_return := 'Y';
  IF(p_ce_bank_account_id is not null and p_balance_date is not null) THEN
    OPEN c_account_details;
    FETCH c_account_details INTO l_company_code,l_account_number,l_currency;
    CLOSE c_account_details;
    IF( NOT CHK_ACCRUAL_ON_RENDER(l_company_code,l_account_number,l_currency,p_balance_date)) THEN
          l_return := 'N';
       END IF;

   END IF;

       RETURN l_return;
END CHK_ACCRUAL_ON_RENDER;



FUNCTION CHK_REVAL_ON_RENDER
                       (  p_ce_bank_account_id IN xtr_bank_accounts.ce_bank_account_id%TYPE
                        , p_balance_date IN xtr_bank_balances.balance_date%TYPE
                       )return VARCHAR2 is
l_return VARCHAR2(2);
l_company_code XTR_BANK_ACCOUNTS.party_code%TYPE;
l_account_number XTR_BANK_ACCOUNTS.account_number%TYPE;
l_currency XTR_BANK_ACCOUNTS.currency%TYPE;

CURSOR c_account_details IS
    SELECT party_code, account_number,currency
    FROM XTR_BANK_ACCOUNTS
    WHERE ce_bank_account_id = p_ce_bank_account_id;

BEGIN
    l_return := 'Y';

IF(p_ce_bank_account_id is not null and p_balance_date is not null) THEN
    OPEN c_account_details;
    FETCH c_account_details INTO l_company_code,l_account_number,l_currency;
    CLOSE c_account_details;
    IF( NOT CHK_REVAL_ON_RENDER(l_company_code,l_account_number,l_currency,p_balance_date)) THEN
        l_return := 'N';
    END IF;
END IF;
    RETURN l_return;
END CHK_REVAL_ON_RENDER;




PROCEDURE LOG_ERR_MSG
     (  p_error_code    IN  VARCHAR2,
        p_field_name    IN  VARCHAR2 DEFAULT NULL,
        p_balance_date  IN  xtr_bank_balances.balance_date%TYPE  DEFAULT NULL
     )
 IS

 BEGIN

        IF  p_error_code = 'XTR_PORTFOLIO' THEN
               FND_MESSAGE.Set_Name('XTR','XTR_2208');
               FND_MSG_PUB.ADD;

        ELSIF  p_error_code = 'XTR_INV_PRICING_MODEL' THEN
               FND_MESSAGE.Set_Name('XTR','XTR_INV_PRICING_MODEL');
               FND_MSG_PUB.ADD;

	ELSIF  p_error_code = 'CE_NO_SCHED_BANK_ACCT' THEN
               FND_MESSAGE.Set_Name('CE','CE_NO_SCHED_BANK_ACCT');
               FND_MSG_PUB.ADD;


        ELSIF  p_error_code = 'XTR_REVAL_ACCRL_BANK' THEN
         /* warning has to be raised  will look into this later */
               FND_MESSAGE.Set_Name ('XTR', 'XTR_REVAL_ACCRL_BANK');
               FND_MESSAGE.Set_Token ('DATE',p_balance_date);
                FND_MSG_PUB.ADD;

        ELSIF  p_error_code = 'XTR_BANK_ACCRLS_EXIST' THEN
               FND_MESSAGE.Set_Name ('XTR', 'XTR_BANK_ACCRLS_EXIST');
               FND_MESSAGE.Set_Token ('DATE',p_balance_date);
               FND_MSG_PUB.ADD;

        ELSIF  p_error_code = 'XTR_BANK_REVAL_DONE' THEN
               FND_MESSAGE.Set_Name ('XTR', 'XTR_BANK_REVAL_DONE');
               FND_MESSAGE.Set_Token ('DATE',p_balance_date);
               FND_MSG_PUB.ADD;

        ELSIF  p_error_code = 'XTR_ACCT_DELETE' THEN
               FND_MESSAGE.Set_Name ('XTR', 'XTR_ACCT_DELETE');
               FND_MSG_PUB.ADD;

         ELSIF  p_error_code = 'XTR_REVAL_ACCRL_DATE' THEN
          /* warning has to be raised  will look into this later */
               FND_MESSAGE.Set_Name ('XTR', 'XTR_REVAL_ACCRL_DATE');
               FND_MESSAGE.Set_Token ('DATE',p_balance_date);
               FND_MSG_PUB.ADD;

         ELSIF  p_error_code = 'XTR_CA_REVAL_DONE' THEN
               FND_MESSAGE.Set_Name ('XTR', 'XTR_CA_REVAL_DONE');
               FND_MSG_PUB.ADD;

          ELSIF  p_error_code = 'XTR_104' THEN
                FND_MESSAGE.Set_Name ( 'XTR','XTR_104');
                FND_MSG_PUB.ADD;

          ELSIF  p_error_code = 'XTR_1237' THEN
                FND_MESSAGE.Set_Name ( 'XTR','XTR_1237');
                FND_MSG_PUB.ADD;

          ELSIF p_error_code = 'XTR_UNEXP_ERROR' THEN
                FND_MESSAGE.Set_Name('XTR','XTR_UNEXP_ERROR');
                FND_MESSAGE.Set_Token('SQLCODE', p_field_name);
                FND_MSG_PUB.ADD; -- Adds the error messages to the list.

           ELSIF p_error_code = 'CHK_LOCK' THEN
               FND_MESSAGE.Set_Name('XTR','XTR_1999');
               FND_MSG_PUB.ADD;


           ELSIF p_error_code = 'XTR_INV_PARAM' THEN
               FND_MESSAGE.Set_Name('XTR','XTR_INV_PARAM');
                FND_MESSAGE.Set_Token('FIELD', p_field_name);
               FND_MSG_PUB.ADD;

           ELSIF p_error_code = 'XTR_TYPES_CHANGED' THEN
               FND_MESSAGE.Set_Name('XTR','XTR_TYPES_CHANGED');
               -- FND_MESSAGE.Set_Token('FIELD', p_field_name);
               FND_MSG_PUB.ADD;

           ELSIF p_error_code = 'XTR_CHANGED_DAYCOUNT_ROUND' THEN
               FND_MESSAGE.Set_Name('XTR', 'XTR_CHANGED_DAYCOUNT_ROUND');
             --  FND_MESSAGE.Set_Token('FIELD', p_field_name);
               FND_MSG_PUB.ADD;




        END IF;

END LOG_ERR_MSG;


/* This procedure updates the rounding_type and the day_count_type in the
xtr_bank_balances IF THE same has been updated IN THE xtr_bank_accounts TABLE

This will be called FORM xtr_replicate_bank_accounts API WHEN THE rounding TYPE/
day_count_type has been updated IN THE interest schedules page OR THE
schedule has been changed BY THE USER */


PROCEDURE UPDATE_ROUNDING_DAYCOUNT
                   (p_ce_bank_account_id xtr_bank_accounts.ce_bank_account_id%TYPE
                    ,p_rounding_type  xtr_bank_accounts.rounding_type%TYPE
                    ,p_day_count_type xtr_bank_accounts.day_count_type%TYPE
                    ,x_return_status  OUT NOCOPY 	VARCHAR2
                    )

IS

l_old_rounding_type  xtr_bank_accounts.rounding_type%TYPE;
l_old_day_count_type xtr_bank_accounts.day_count_type%TYPE;
l_day_count_type xtr_bank_accounts.day_count_type%TYPE;
l_party_code  xtr_bank_accounts.party_code%TYPE;
l_account_number xtr_bank_accounts.account_number%TYPE;
l_latest_date  DATE;
l_oldest_date  DATE;
l_acc_status  varchar2(20);
l_batch_error varchar2(20);

-- This cursor gets the existing rounding type/day count type from the
-- xtr_bank_accounts table

CURSOR c_old_types IS
  SELECT rounding_type, day_count_type, party_code, account_number
  FROM XTR_BANK_ACCOUNTS
  WHERE ce_bank_account_id = p_ce_bank_account_id;

-- Gets the maximum balance date and the minimum balance date for that
-- company and account
CURSOR c_bal_date IS
  SELECT max(balance_date), min(balance_date)
  FROM XTR_BANK_BALANCES
  WHERE company_code = l_party_code
  AND account_number = l_account_number;

-- Checking for record lock
CURSOR c_chk_lock IS
SELECT day_count_type
FROM  xtr_bank_balances
WHERE  company_code = l_party_code
       AND  account_number = l_account_number
FOR UPDATE NOWAIT;



BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_old_types;
    FETCH c_old_types INTO l_old_rounding_type, l_old_day_count_type,l_party_code,l_account_number;
    CLOSE c_old_types;

    IF l_old_rounding_type <> p_rounding_type
       OR l_old_day_count_type <> p_day_count_type THEN

            OPEN c_bal_date;
            FETCH c_bal_date INTO l_latest_date, l_oldest_date;

            IF c_bal_date%FOUND then

                 CLOSE c_bal_date;

                 l_batch_error := chk_int_override(l_party_code,l_account_number, l_oldest_date);
                 l_acc_status  := chk_accrual_int(l_party_code,l_account_number);

                 OPEN c_chk_lock;
                 FETCH c_chk_lock INTO  l_day_count_type;
                 IF c_chk_lock%FOUND THEN

                      CLOSE c_chk_lock;

                      IF l_batch_error IS NULL THEN

                          UPDATE xtr_bank_balances
                          SET rounding_type = p_rounding_type,
                    	  day_count_type = p_day_count_type
                          WHERE company_code =l_party_code
                          AND account_number = l_account_number;

                          UPDATE_BANK_ACCOUNT(l_party_code,
                                    l_account_number,
                                    l_oldest_date,
                                    'U' ,
                                    x_return_status );



                      ELSIF l_batch_error IS NOT NULL AND l_acc_status IS NOT NULL THEN

                          UPDATE xtr_bank_balances
                          SET rounding_type = p_rounding_type,
                     	  day_count_type = p_day_count_type
                          WHERE company_code =l_party_code
                          AND account_number = l_account_number
                          AND balance_date = l_latest_date;

                      END IF;     -- l_batch_error

                 ELSE
                      CLOSE c_chk_lock;

                 END IF;  -- c_chk_lock

            ELSE

               close c_bal_date;

            END IF; -- c_bal_date

    END IF;

EXCEPTION
        WHEN app_exceptions.RECORD_LOCK_EXCEPTION THEN
            IF C_CHK_LOCK%ISOPEN THEN
                CLOSE C_CHK_LOCK;
            END IF;
            LOG_ERR_MSG('CHK_LOCK');
            x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN others THEN
          x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
          LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));

END UPDATE_ROUNDING_DAYCOUNT;



FUNCTION CHK_INT_OVERRIDE (
            p_party_code xtr_bank_accounts.party_code%type
           ,p_account_number xtr_bank_accounts.account_number%type
           ,p_oldest_date DATE
           ) RETURN VARCHAR2 IS

l_check_status	varchar2(1);
l_batch_error varchar2(20);


-- Settlement Check cursor
  cursor CHK_SETTLE is
    select 'Y'
    from xtr_bank_balances
    where account_number = p_ACCOUNT_NUMBER
    and nvl(interest_settled,0) <> 0;

-- Accrual Check cursor
  cursor CHK_ACCRLS is
     select 'Y'
     from xtr_batches b, xtr_batch_events e
     where b.company_code = p_PARTY_CODE
     and b.batch_id = e.batch_id
     and e.event_code = 'ACCRUAL'
     and b.period_end > p_oldest_date;

-- Journal Check cursor
  cursor CHK_JNLS is
      select 'Y'
      from xtr_batches b, xtr_batch_events e
      where b.company_code =p_PARTY_CODE
      and b.batch_id = e.batch_id
      and e.event_code = 'JRNLGN'
      and b.period_end > p_oldest_date;

BEGIN

   l_check_status := 'N';
   l_batch_error := NULL;

   /* Check Settlement */
   Open CHK_SETTLE;
   fetch CHK_SETTLE into l_check_status;
   if CHK_SETTLE%FOUND then
      l_batch_error := 'SETTLE';
   end if;
   close CHK_SETTLE;

   IF l_batch_error is NULL then
    /* Check Accruals */
        open CHK_ACCRLS;
        fetch CHK_ACCRLS into l_check_status;
        if CHK_ACCRLS%FOUND then
              l_batch_error := 'ACCRUE';
        END IF;
        close CHK_ACCRLS;
   END IF;

   IF l_batch_error is NULL then
     /* Check Journals */
        open CHK_JNLS;
        fetch CHK_JNLS into l_check_status;
        if CHK_JNLS%FOUND then
              l_batch_error := 'JOURL';
        END IF;
        close CHK_JNLS;

   END IF;
RETURN l_batch_error;
END CHK_INT_OVERRIDE;



FUNCTION  CHK_ACCRUAL_INT (
              p_party_code xtr_bank_accounts.party_code%type
             ,p_account_number xtr_bank_accounts.account_number%type
              )RETURN varchar2 IS

 l_acc_int	number;
 l_acc_status  varchar2(20);

 cursor CHK_ACC_INT is
   select accum_int_cfwd
     from xtr_bank_balances
    where account_number = p_ACCOUNT_NUMBER
      and company_code = p_PARTY_CODE
      and balance_date = (select max(balance_date)
                            from xtr_bank_balances
                            where account_number = p_Account_Number
                            and company_code = p_PARTY_CODE);

BEGIN
  l_acc_status := null;

  open CHK_ACC_INT;
  fetch CHK_ACC_INT into l_acc_int;

  if CHK_ACC_INT%FOUND then

      if nvl(l_acc_int ,0) = 0 then
         	l_acc_status :='ZERO';
      end if;

  end if;
  close CHK_ACC_INT;
RETURN l_acc_status;
END CHK_ACCRUAL_INT;


PROCEDURE CHK_ACCRUAL_REVAL_WARNINGS
                   (p_ce_bank_account_id IN xtr_bank_accounts.ce_bank_account_id%TYPE
                    ,p_balance_date IN xtr_bank_balances.balance_date%TYPE
                    ,p_ce_bank_account_balance_id IN xtr_bank_balances.ce_bank_account_balance_id%TYPE default null
                    ,p_interest_calc_balance IN NUMBER
                    ,p_balance_cflow IN xtr_bank_balances.balance_cflow%TYPE
                    ,p_action_flag IN VARCHAR2
                    ,x_return_status  OUT NOCOPY 	VARCHAR2
                    ,x_msg_count  OUT NOCOPY 	NUMBER
                    ,x_msg_data	 OUT NOCOPY 	VARCHAR2 )IS

CURSOR c_bank_acct_details IS
    SELECT party_code,account_number,currency
    FROM XTR_BANK_ACCOUNTS
    WHERE ce_bank_account_id = p_ce_bank_account_id;

l_company_code xtr_bank_accounts.party_code%TYPE;
l_account_number xtr_bank_accounts.account_number%TYPE;
l_currency xtr_bank_accounts.currency%TYPE;
l_return_error VARCHAR2(30);

BEGIN
    FND_MSG_PUB.Initialize;

    OPEN c_bank_acct_details;
    FETCH c_bank_acct_details INTO l_company_code,l_account_number,l_currency;
    IF c_bank_acct_details%FOUND THEN
        CLOSE c_bank_acct_details;

        l_return_error := chk_reval(  l_company_code,
                                      l_account_number,
                                      l_currency,
                                      p_balance_date,
                                      p_ce_bank_account_balance_id,
                                      p_balance_cflow,
                                      p_action_flag,
                                      'W');
        IF nvl(l_return_error, '$$$') = 'XTR_DEALS_BEFORE_REVAL' THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            LOG_ERR_MSG ( 'XTR_DEALS_BEFORE_REVAL',p_balance_date);
        END IF;

        l_return_error := chk_accrual(l_company_code,
                                      l_account_number,
                                      l_currency,
                                      p_balance_date,
                                      p_ce_bank_account_balance_id,
                                      p_interest_calc_balance,
                                      p_action_flag,
                                      'W');

        IF nvl(l_return_error, '$$$') = 'XTR_DEALS_BEFORE_ACCRUAL' THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            LOG_ERR_MSG ( 'XTR_DEALS_BEFORE_ACCRUAL',p_balance_date);
        END IF;

    ELSE
        CLOSE c_bank_acct_details;
         x_return_status    := FND_API.G_RET_STS_ERROR;
         LOG_ERR_MSG('XTR_INV_PARAM','ACTION_FLAG');
    END IF;

    FND_MSG_PUB.Count_And_Get -- Returns the error message if there is only 1 error
    (   p_count         =>      x_msg_count     ,
        p_data          =>      x_msg_data
    );

    EXCEPTION

          WHEN others THEN
          x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
          LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));
          FND_MSG_PUB.Count_And_Get -- Returns the error message if there is only 1 error
            (   p_count         =>      x_msg_count     ,
                p_data          =>      x_msg_data
            );

END CHK_ACCRUAL_REVAL_WARNINGS;

END XTR_REPLICATE_BANK_BALANCES;


/
