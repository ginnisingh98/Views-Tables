--------------------------------------------------------
--  DDL for Package Body XTR_MAINTAIN_DDA_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_MAINTAIN_DDA_P" AS
/* $Header: xtrprc1b.pls 120.9.12010000.4 2009/12/11 07:54:20 nipant ship $ */

-- Package that Inserts and Maintains the Deal Date Amount Rows for Deals.
--
-- This procedure is called by a DB trigger on table DEALS whenever a Deals record is
-- UPDATED, DELETED or INSERTED.
-- Deal Types currently handled in this procedure are FX, FXO, FRA, NI, IRO, FUT, SWPTN
--
-- Note Bond code is included below in the main body but not yet tested - this is why
-- the first what if excludes bonds at the moment
--


procedure MAINTAIN_DDA_PROC (
            P_ACTION			      	IN  VARCHAR2,
            P_DEAL_TYPE			      	IN  VARCHAR2,
            P_DEAL_NO			      	IN  NUMBER,
            P_TRANSACTION_NUMBER	      	IN  NUMBER,
            P_STATUS_CODE		      	IN  VARCHAR2,
            P_DEAL_SUBTYPE		      	IN  VARCHAR2,
            P_COMPANY_CODE		      	IN  VARCHAR2,
            P_CPARTY_CODE		      	IN  VARCHAR2,
            P_CLIENT_CODE		      	IN  VARCHAR2,
            P_LIMIT_CODE		      	IN  VARCHAR2,
            P_PRODUCT_TYPE		      	IN  VARCHAR2,
            P_PORTFOLIO_CODE		      	IN  VARCHAR2,
            P_CURRENCY			      	IN  VARCHAR2,
	    P_CURRENCY_BUY		      	IN  VARCHAR2,
	    P_CURRENCY_SELL		      	IN  VARCHAR2,
            P_SWAP_DEPO_FLAG              	IN  VARCHAR2,
            P_DEALER_CODE		      	IN  VARCHAR2,
            P_DEAL_DATE			      	IN  DATE,
            P_START_DATE		      	IN  DATE,
            P_MATURITY_DATE		      	IN  DATE,
            P_INTEREST_RATE		      	IN  NUMBER,
            P_FACE_VALUE_AMOUNT	      		IN  NUMBER,
            P_FACE_VALUE_HCE_AMOUNT	      	IN  NUMBER,
    	    P_CPARTY_ACCOUNT_NO 		IN  VARCHAR2,
       	    P_OLD_CPARTY_ACCOUNT_NO 		IN  VARCHAR2,
    	    P_SETTLE_ACCOUNT_NO	      		IN  VARCHAR2,
       	    P_OLD_SETTLE_ACCOUNT_NO	      		IN  VARCHAR2,
            P_SETTLE_ACTION		      	IN  VARCHAR2,
	    P_SETTLE_AMOUNT		      	IN  NUMBER,
            P_SETTLE_HCE_AMOUNT	      		IN  NUMBER,
            P_SETTLE_RATE		      	IN  NUMBER,
            P_EXERCISE_PRICE                    IN  NUMBER,
            P_SETTLE_DATE		      	IN  DATE,
	    P_PREMIUM_ACTION		      	IN  VARCHAR2,
            P_PREMIUM_DATE		      	IN  DATE,
            P_PREMIUM_AMOUNT		      	IN  NUMBER,
	    P_PREMIUM_HCE_AMOUNT	      	IN  NUMBER,
            P_PREMIUM_ACCOUNT_NO	      	IN  VARCHAR2,
            P_OLD_PREMIUM_ACCOUNT_NO	      	IN  VARCHAR2,
	    P_TRANSACTION_RATE	      		IN  NUMBER,
	    P_INSERT_FOR_CASHFLOW	      	IN  VARCHAR2,
 	    P_KNOCK_TYPE		      	IN  VARCHAR2,
	    P_KNOCK_INSERT_TYPE	      	 	IN  VARCHAR2,
	    P_SELL_AMOUNT		        IN  NUMBER,
	    P_BUY_AMOUNT		        IN  NUMBER,
	    P_SELL_HCE_AMOUNT		        IN  NUMBER,
	    P_BUY_HCE_AMOUNT		        IN  NUMBER,
	    P_SELL_ACCOUNT_NO		        IN  VARCHAR2,
   	    P_OLD_SELL_ACCOUNT_NO		        IN  VARCHAR2,
	    P_BUY_ACCOUNT_NO		        IN  VARCHAR2,
   	    P_OLD_BUY_ACCOUNT_NO		        IN  VARCHAR2,
	    P_VALUE_DATE		        IN  DATE,
	    P_EXPIRY_DATE		        IN  DATE,
	    P_OPTION_COMMENCEMENT	        IN  DATE,
	    P_COMMENTS			        IN  VARCHAR2,
  	    P_OLD_STATUS_CODE		        IN  VARCHAR2,
            P_QUICK_INPUT		        IN  VARCHAR2,
	    P_START_AMOUNT			IN  NUMBER,
	    P_START_HCE_AMOUNT			IN  NUMBER,
	    P_MATURITY_AMOUNT			IN  NUMBER,
	    P_MATURITY_HCE_AMOUNT		IN  NUMBER,
	    P_MATURITY_ACCOUNT_NO		IN  VARCHAR2,
   	    P_OLD_MATURITY_ACCOUNT_NO		IN  VARCHAR2,
	    P_MATURITY_BALANCE_AMOUNT		IN  NUMBER,
	    P_MATURITY_BALANCE_HCE_AMOUNT	IN  NUMBER,
	    P_INTEREST_AMOUNT			IN  NUMBER,
	    P_INTEREST_HCE_AMOUNT		IN  NUMBER,
	    P_RISKPARTY_LIMIT_CODE		IN  VARCHAR2,
	    P_RISKPARTY_CODE			IN  VARCHAR2,
	    P_BOND_ISSUE 			IN  VARCHAR2,
	    P_COUPON_ACTION 			IN  VARCHAR2,
	    P_ACCRUED_INTEREST_PRICE 		IN  NUMBER,
	    P_CUM_COUPON_DATE			IN  DATE,
	    P_NEXT_COUPON_DATE			IN  DATE,
	    P_COUPON_RATE 			IN  NUMBER,
	    P_FREQUENCY				IN  NUMBER,
	    P_ACCEPTOR_CODE			IN  VARCHAR2,
	    P_CAPITAL_PRICE			IN  NUMBER,
	    P_PREMIUM_CURRENCY			IN  VARCHAR2,
	    P_CONTRACT_RATE			IN  NUMBER,
	    P_CONTRACT_COMMISSION		IN  NUMBER,
	    P_CONTRACT_FEES			IN  NUMBER,
	    P_BASE_RATE				IN  NUMBER,
	    P_NI_PROFIT_LOSS			IN  NUMBER,
	    P_RATE_FIXING_DATE			IN  DATE,
    	    P_PROFIT_LOSS			IN  NUMBER,
	    P_OLD_PROFIT_LOSS			IN  NUMBER,
	    P_FX_RO_PD_RATE			IN  NUMBER,
	    P_OLD_FX_RO_PD_RATE			IN  NUMBER,
	    P_FX_M1_DEAL_NO			IN  NUMBER,
	    P_OLD_FX_M1_DEAL_NO			IN  NUMBER) is

--
cursor C_GET_COUNTRY (pc_party_code varchar2) is
 select country_code
  from XTR_parties_V
  where party_code = pc_party_code;
cursor C_LIMIT_WEIGHTING (v_deal_type VARCHAR2, v_deal_subtype VARCHAR2) is
 select nvl(limit_weighting,100)
  from xtr_fx_period_weightings_v
  where deal_type = v_deal_type
  and deal_subtype = v_deal_subtype;
v_weighting	number;
---
 v_country_code        varchar2(25);
 v_utilised_amount     number;
 v_hce_utilised_amt    number;
 v_hce_amt             number;
 v_limit_party         varchar2(7);
--
 v_amount_indic		NUMBER :=1;
 v_contra_ccy		VARCHAR2(15) :=NULL;
 v_settle_ref           VARCHAR2(80) :=NULL;
 v_settle_ac            VARCHAR2(20):=NULL;

 v_cparty_account_no xtr_deal_date_amounts.cparty_account_no%type;
 v_settle_account_no xtr_deal_date_amounts.account_no%type;
 v_premium_account_no xtr_deal_date_amounts.account_no%type;
 v_maturity_account_no xtr_deal_date_amounts.account_no%type;
 v_buy_account_no xtr_deal_date_amounts.account_no%type;
 v_sell_account_no xtr_deal_date_amounts.account_no%type;

-- Non Base Table Columns
 --P_CPARTY_ACCOUNT	VARCHAR2(20);
 P_INT_VALUE		NUMBER;
 P_PREM_VALUE 		NUMBER;
 P_BOND_YR_BASIS	NUMBER;
 P_CALC_TYPE		VARCHAR2(15);
 P_RIC_CODE		VARCHAR2(20);
--
--cursor CPARTY_ACCT_NOS is
 --select ACCOUNT_NUMBER
 -- from  XTR_BANK_ACCOUNTS
  --where PARTY_CODE = P_CPARTY_CODE
 -- and   BANK_SHORT_CODE = P_CPARTY_REF
  --and   CURRENCY = decode(P_DEAL_TYPE,'FX',P_CURRENCY_SELL,P_CURRENCY);
--
cursor COM is
 select CURRENCY_FIRST||'/'||CURRENCY_SECOND,CURRENCY_FIRST
  from XTR_BUY_SELL_COMBINATIONS
  where (CURRENCY_BUY = P_CURRENCY_BUY and CURRENCY_SELL = P_CURRENCY_SELL)
  or (CURRENCY_BUY = P_CURRENCY_SELL and CURRENCY_SELL = P_CURRENCY_BUY);
--
 l_combin VARCHAR2(31);
 base_ccy VARCHAR2(15);
--
cursor CFLOW is
 select 1
  from XTR_DEAL_DATE_AMOUNTS_V
  where DEAL_NUMBER = P_DEAL_NO
  and AMOUNT_TYPE = 'FXOBUY'
  and DATE_TYPE = 'VALUE';
--
 l_dummy		number;
--
 coupon_date    DATE;
 l_start_date   DATE;
 coupon         NUMBER;
 coupon_hce     NUMBER;
 hce_rate       NUMBER;
 round_fac      NUMBER;
 l_trans_num    NUMBER;
--
 l_amount       NUMBER;
 l_hce_amount   NUMBER;
--
 cursor CHK_BDO_SETTLE_ROWS is
   select 1
     from XTR_DEAL_DATE_AMOUNTS
    where deal_number     = P_DEAL_NO and
          deal_type       = 'BDO' and
          date_type       = 'SETTLE';
--
 cursor RND_FAC is
  select m.ROUNDING_FACTOR
   from   XTR_PRO_PARAM_V p,
          XTR_MASTER_CURRENCIES_V m
   where  p.PARAM_NAME = 'SYSTEM_FUNCTION_CCY'
   and    m.CURRENCY   =  p.PARAM_VALUE;
--
 cursor HCE(c_currency varchar2) is
  select s.HCE_RATE
   from XTR_MASTER_CURRENCIES s
   where s.CURRENCY = c_currency;

 cursor CHK_ISSUE is
  select YEAR_BASIS,CALC_TYPE,RIC_CODE
   from XTR_BOND_ISSUES
   where BOND_ISSUE_CODE = P_BOND_ISSUE
   and AUTHORISED = 'Y'
   and ((ISSUER=P_COMPANY_CODE and P_DEAL_SUBTYPE='ISSUE') or P_DEAL_SUBTYPE<>'ISSUE')
   and nvl(BOND_OR_DEBENTURE_ISSUE,'B') = 'B';
--
 cursor CHK_NI_BAL_FV is
  select 1
    from XTR_DEAL_DATE_AMOUNTS
   where DEAL_NUMBER = P_DEAL_NO
    and AMOUNT_TYPE = 'BAL_FV'
    and DATE_TYPE = 'MATURE';
--
 cursor CHK_SWPTN_SETTLE_ROWS is
   select 1
     from XTR_DEAL_DATE_AMOUNTS
    where deal_number     = P_DEAL_NO and
          deal_type       = 'SWPTN' and
          date_type       = 'SETTLE';

 -- Bug 8561305 Starts

 cursor CHK_FXO_PREMIUM is
select 1 from xtr_deal_date_amounts
where company_code =P_COMPANY_CODE
	     and deal_number = P_DEAL_NO
	     and deal_type = 'FXO'
	     and transaction_number = 1
	     and amount_type = 'PREMIUM'
	     and date_type = 'PREMIUM';

dda_premium_v number;

-- Bug 8561305 Ends
--
l_sysdate	DATE;
l_user	VARCHAR2(10);
--

begin

/* code below added by Ilavenil to fix the bug # 2065586
   Let us assume, a deal is created using the deal input form.  At the time of creation of deal the
   account numbers are set.  Say for example the account number is 'AAA'.  Xtr_Deals, Xtr_Deal_Date_Amounts
   will store the account number 'AAA'.  User then goes to settlement form
   and goes for a different account number for settlement.  Say for example the account number is 'BBB'.
   Xtr_Deal_Date_Amounts will now save 'BBB' instead of 'AAA' for the same deal no.

   Case i :   User then goes to the input form and queries the same deal number.  In future the user may be allowed to update
   the deal no for the deal.  In that case, let us assume that the user modified the deal account number as
   'CCC' instead of 'AAA'.  Now, Xtr_Deal_Date_Amounts is to be set to 'CCC'.

   Case ii :  User goes to input form and queries the deal number.  User updates a field other than account numbers.
   The updation will be carried to Xtr_Deal_Date_Amounts by this procedure.  Now, account number in
   Xtr_Deal_Date_amounts is to be set as 'BBB' only.  It should not be overwritten by 'AAA'.

   So, we always check whether in Xtr_Deals, the old account number <> new account number.   If yes, then
   update Xtr_Deal_Date_Amounts to new account number of Xtr_Deals.  If no, then leave Xtr_Deal_Date_Amounts
   account number as is.

   We basically do not want to overwrite an account number set at settlement by original account number.

   */

If P_Settle_Account_No <> P_Old_Settle_Account_No then
   v_settle_account_no := P_Settle_Account_No;
Else
   v_settle_account_no := null;
End if;

If P_Premium_Account_No <> P_Old_Premium_Account_No then
   v_premium_account_no := P_Premium_Account_No;
Else
   v_Premium_account_no := null;
End if;

If P_maturity_Account_No <> P_Old_maturity_Account_No then
   v_maturity_account_no := P_maturity_Account_No;
Else
   v_maturity_account_no := null;
End if;

If P_Buy_Account_No <> P_Old_Buy_Account_No then
   v_Buy_account_no := P_Buy_Account_No;
Else
   v_Buy_account_no := null;
End if;

If P_Sell_Account_No <> P_Old_Sell_Account_No then
   v_sell_account_no := P_Sell_Account_No;
Else
   v_sell_account_no := null;
End if;

If P_CPARTY_ACCOUNT_NO <> P_OLD_CPARTY_ACCOUNT_NO then
   v_cparty_account_no := P_CPARTY_ACCOUNT_NO;
Else
   v_cparty_account_no := null;
End if;


-- note although there is sections below for BONDS we have excluded it here at a higher level
-- because code below will need testing
IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
   xtr_debug_pkg.debug('Before MAINTAIN_DDA_PROC on:'||to_char(sysdate,'MM:DD:HH24:MI:SS'));
END IF;
if P_DEAL_TYPE <> 'BOND' then
 l_sysdate	:= trunc(SYSDATE);
 l_user	:= fnd_global.user_id;
 --
 open COM;
  fetch COM INTO l_combin,base_ccy;
 close COM;
 --
 --P_CPARTY_ACCOUNT := NULL;
 --
 --open CPARTY_ACCT_NOS;
 -- fetch CPARTY_ACCT_NOS INTO P_CPARTY_ACCOUNT;
 --close CPARTY_ACCT_NOS;
 --
 -- Rounding factors
 open RND_FAC;
  fetch RND_FAC INTO round_fac;
 close RND_FAC;
 round_fac :=nvl(round_fac,5);
 --
 -- Home currency rate
 open HCE(P_CURRENCY);
  fetch HCE INTO hce_rate;
 close HCE;
 --
 hce_rate := nvl(hce_rate,1);
 --
 if P_DEAL_TYPE = 'BOND' then
  open CHK_ISSUE;
   fetch CHK_ISSUE INTO P_BOND_YR_BASIS,P_CALC_TYPE,P_RIC_CODE;
  close CHK_ISSUE;
  if P_COUPON_ACTION = 'CUM' then
   P_INT_VALUE := nvl(round(P_ACCRUED_INTEREST_PRICE * P_MATURITY_AMOUNT / 100,nvl(round_fac,2)),0);
  else
   P_INT_VALUE := 0;
  end if;
  P_PREM_VALUE := nvl(round((P_CAPITAL_PRICE - 100) * P_MATURITY_AMOUNT / 100,nvl(round_fac,2)),0);
 end if;
 --
 -- For insert of new Rows
 if P_ACTION = 'INSERT' and P_STATUS_CODE = 'CURRENT' then
  if P_DEAL_TYPE = 'FRA' then
   insert into XTR_DEAL_DATE_AMOUNTS
               (deal_type,amount_type,date_type,
                deal_number,transaction_number,transaction_date,currency,
                amount,hce_amount,amount_date,transaction_rate,
                cashflow_amount,company_code,deal_subtype,
                product_type,status_code,portfolio_code,
                dealer_code,client_code,cparty_code,settle,limit_code,
                limit_party,commence_date,quick_input)
   values      ('FRA','FACEVAL','COMENCE',
                P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
                P_FACE_VALUE_AMOUNT,P_FACE_VALUE_HCE_AMOUNT,
                P_START_DATE,P_INTEREST_RATE,0,
                P_COMPANY_CODE,P_DEAL_SUBTYPE,P_PRODUCT_TYPE,
                P_STATUS_CODE,P_PORTFOLIO_CODE,P_DEALER_CODE,
                P_CLIENT_CODE,P_CPARTY_CODE,'N',
                NULL,P_CPARTY_CODE,P_START_DATE,P_QUICK_INPUT);
   -- Dummy row for deal maturity date, this allows a journal action, accruals
   insert into XTR_DEAL_DATE_AMOUNTS
               (deal_type,amount_type,date_type,
                deal_number,transaction_number,transaction_date,currency,
                amount,hce_amount,amount_date,transaction_rate,
                cashflow_amount,company_code,deal_subtype,product_type,
                status_code,dealer_code,client_code,cparty_code,settle,
                portfolio_code,commence_date,QUICK_INPUT)
   values      ('FRA','N/A','MATURE',
                P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
                0,0,P_MATURITY_DATE,P_INTEREST_RATE,0,P_COMPANY_CODE,P_DEAL_SUBTYPE,
                P_PRODUCT_TYPE,P_STATUS_CODE,P_DEALER_CODE,
                P_CLIENT_CODE,P_CPARTY_CODE,'N',nvl(P_PORTFOLIO_CODE,'NOTAPPL'),P_START_DATE,P_QUICK_INPUT);
   -- Dummy row for deal dealt date, this allows a journal action
   -- to be set up for a premium to occur on the deal date (date type DEALT)
   insert into XTR_DEAL_DATE_AMOUNTS
               (deal_type,amount_type,date_type,
                deal_number,transaction_number,transaction_date,currency,
                amount,hce_amount,amount_date,transaction_rate,
                cashflow_amount,company_code,deal_subtype,product_type,
                status_code,dealer_code,client_code,cparty_code,settle,
                portfolio_code,commence_date,QUICK_INPUT)
   values      ('FRA','N/A','DEALT',
                P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
                0,0,P_DEAL_DATE,0,0,P_COMPANY_CODE,P_DEAL_SUBTYPE,
                P_PRODUCT_TYPE,P_STATUS_CODE,P_DEALER_CODE,
                P_CLIENT_CODE,P_CPARTY_CODE,'N',nvl(P_PORTFOLIO_CODE,'NOTAPPL'),P_START_DATE,P_QUICK_INPUT);
   -- Row for date_type of LIMIT so that the risk between the settlement and
   --  exercise date is acknowledged
   insert into XTR_DEAL_DATE_AMOUNTS
               (deal_type,amount_type,date_type,
                deal_number,transaction_number,transaction_date,currency,
                amount,hce_amount,amount_date,
                cashflow_amount,company_code,deal_subtype,product_type,
                status_code,dealer_code,client_code,cparty_code,settle,
                portfolio_code,commence_date,QUICK_INPUT,LIMIT_CODE,LIMIT_PARTY)
   values      ('FRA','N/A','LIMIT',
                P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
                nvl(P_FACE_VALUE_AMOUNT,0),nvl(P_FACE_VALUE_HCE_AMOUNT,0),
                P_START_DATE,0,P_COMPANY_CODE,P_DEAL_SUBTYPE,
                P_PRODUCT_TYPE,P_STATUS_CODE,P_DEALER_CODE,
                P_CLIENT_CODE,P_CPARTY_CODE,'N',nvl(P_PORTFOLIO_CODE,'NOTAPPL'),P_START_DATE,P_QUICK_INPUT,
                nvl(P_LIMIT_CODE,'NILL'),P_CPARTY_CODE);
  if P_RATE_FIXING_DATE is not null then
   -- Dummy row for deal rate set date
   insert into XTR_DEAL_DATE_AMOUNTS
               (deal_type,amount_type,date_type,
                deal_number,transaction_number,transaction_date,currency,
                amount,hce_amount,amount_date,transaction_rate,
                cashflow_amount,company_code,deal_subtype,product_type,
                status_code,dealer_code,client_code,cparty_code,settle,
                portfolio_code,commence_date,QUICK_INPUT)
   values      ('FRA','FACEVAL','RATESET',
                P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
                nvl(P_FACE_VALUE_AMOUNT,0),nvl(P_FACE_VALUE_HCE_AMOUNT,0),
                P_RATE_FIXING_DATE,P_SETTLE_RATE,0,P_COMPANY_CODE,P_DEAL_SUBTYPE,
                P_PRODUCT_TYPE,P_STATUS_CODE,P_DEALER_CODE,
                P_CLIENT_CODE,P_CPARTY_CODE,'N',nvl(P_PORTFOLIO_CODE,'NOTAPPL'),P_START_DATE,P_QUICK_INPUT);
  end if;

   -- Dummy row for deal dealt date, this allows a journal action

 elsif P_DEAL_TYPE = 'FXO' then

  if nvl(P_KNOCK_TYPE,'O') = 'O' then
   insert into XTR_DEAL_DATE_AMOUNTS
         (deal_type,amount_type,date_type,
          deal_number,transaction_number,transaction_date,currency,
          amount,hce_amount,amount_date,transaction_rate,
          cashflow_amount,company_code,deal_subtype,product_type,
          status_code,cparty_code,settle,client_code,
          limit_code,limit_party,portfolio_code,dealer_code,currency_combination,QUICK_INPUT)
   values(P_DEAL_TYPE,'FXOBUY','EXPIRY',
          P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY_BUY,
          P_BUY_AMOUNT,P_BUY_HCE_AMOUNT,
          P_EXPIRY_DATE,P_TRANSACTION_RATE,0,P_COMPANY_CODE,
          P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,
          P_CPARTY_CODE,'N',P_CLIENT_CODE,
          decode(P_CURRENCY_BUY,substr(upper(l_combin),1,3),nvl(P_LIMIT_CODE,'NILL'),NULL),
          decode(P_CURRENCY_BUY,substr(upper(l_combin),1,3),P_CPARTY_CODE,NULL),
          nvl(P_PORTFOLIO_CODE,'NOTAPPL'),P_DEALER_CODE,l_combin,P_QUICK_INPUT);
   --
   insert into XTR_DEAL_DATE_AMOUNTS
         (deal_type,amount_type,date_type,
          deal_number,transaction_number,transaction_date,currency,
          amount,hce_amount,amount_date,transaction_rate,
          cashflow_amount,company_code,deal_subtype,product_type,
          status_code,cparty_code,settle,
          client_code,portfolio_code,limit_code,limit_party,dealer_code,currency_combination,QUICK_INPUT)
   values(P_DEAL_TYPE,'FXOSELL','EXPIRY',P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY_SELL,
          P_SELL_AMOUNT,P_SELL_HCE_AMOUNT,P_EXPIRY_DATE,P_TRANSACTION_RATE,0,
          P_COMPANY_CODE,P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,P_CPARTY_CODE,'N',
          P_CLIENT_CODE,nvl(P_PORTFOLIO_CODE,'NOTAPPL'),
          decode(P_CURRENCY_SELL,substr(upper(l_combin),1,3),nvl(P_LIMIT_CODE,'NILL'),NULL),
          decode(P_CURRENCY_SELL,substr(upper(l_combin),1,3),P_CPARTY_CODE,NULL),
          P_DEALER_CODE,l_combin,P_QUICK_INPUT);
   -- Value Date Amounts (To be used in cashflow Projections if indicated as reqd in deal input
   if nvl(P_INSERT_FOR_CASHFLOW,'N') = 'Y' then
    insert into XTR_DEAL_DATE_AMOUNTS
          (deal_type,amount_type,date_type,
           deal_number,transaction_number,transaction_date,currency,
           amount,hce_amount,amount_date,transaction_rate,
           cashflow_amount,company_code,account_no,
           deal_subtype,product_type,status_code,cparty_code,settle,
           client_code,portfolio_code,dealer_code,currency_combination,
           exposure_ref_date,QUICK_INPUT)
    values(P_DEAL_TYPE,'FXOBUY','VALUE',
           P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY_BUY,
           P_BUY_AMOUNT,P_BUY_HCE_AMOUNT,
           P_VALUE_DATE,P_TRANSACTION_RATE,
           decode(nvl(P_INSERT_FOR_CASHFLOW,'N'),'Y',P_BUY_AMOUNT,0),
           P_COMPANY_CODE,P_BUY_ACCOUNT_NO,P_DEAL_SUBTYPE,
           P_PRODUCT_TYPE,P_STATUS_CODE,P_CPARTY_CODE,'N',
           P_CLIENT_CODE,nvl(P_PORTFOLIO_CODE,'NOTAPPL'),
           P_DEALER_CODE,l_combin,P_START_DATE,P_QUICK_INPUT);
    --
    insert into XTR_DEAL_DATE_AMOUNTS
          (deal_type,amount_type,date_type,
           deal_number,transaction_number,transaction_date,currency,
           amount,hce_amount,amount_date,transaction_rate,
           cashflow_amount,company_code,account_no,
           deal_subtype,product_type,status_code,cparty_code,settle,
           client_code,portfolio_code,dealer_code,currency_combination,
           exposure_ref_date,QUICK_INPUT)
    values(P_DEAL_TYPE,'FXOSELL','VALUE',
           P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY_SELL,
           P_SELL_AMOUNT,P_SELL_HCE_AMOUNT,
           P_VALUE_DATE,P_TRANSACTION_RATE,
           decode(nvl(P_INSERT_FOR_CASHFLOW,'N'),'Y',(-1)*P_SELL_AMOUNT,0),
           P_COMPANY_CODE,P_SELL_ACCOUNT_NO,P_DEAL_SUBTYPE,
           P_PRODUCT_TYPE,P_STATUS_CODE,P_CPARTY_CODE,'N',
           P_CLIENT_CODE,nvl(P_PORTFOLIO_CODE,'NOTAPPL'),
           P_DEALER_CODE,l_combin,P_START_DATE,P_QUICK_INPUT);
   end if;
   --
   if  P_CURRENCY IS NOT NULL and P_PREMIUM_ACTION is NOT NULL and nvl(P_PREMIUM_AMOUNT,0) > 0 then
    insert into XTR_DEAL_DATE_AMOUNTS
          (deal_type,amount_type,date_type,
           deal_number,transaction_number,transaction_date,currency,
           amount,hce_amount,amount_date,transaction_rate,
           cashflow_amount,company_code,account_no,action_code,
           cparty_account_no,deal_subtype,product_type,status_code,
           cparty_code,settle,client_code,portfolio_code,dealer_code,QUICK_INPUT)
    values(P_DEAL_TYPE,'PREMIUM','PREMIUM',
           P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
           P_PREMIUM_AMOUNT,P_PREMIUM_HCE_AMOUNT,
           P_PREMIUM_DATE,0,decode(P_PREMIUM_ACTION,
           'PAY',(-1) * P_PREMIUM_AMOUNT,P_PREMIUM_AMOUNT),
           P_COMPANY_CODE,P_PREMIUM_ACCOUNT_NO,P_PREMIUM_ACTION,
           decode(P_PREMIUM_ACTION,'PAY',P_CPARTY_ACCOUNT_NO),
           P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,P_CPARTY_CODE,
           'N',P_CLIENT_CODE,nvl(P_PORTFOLIO_CODE,'NOTAPPL'),
           P_DEALER_CODE,P_QUICK_INPUT);
   end if;
   -- Dummy rows for deal dealt and commence dates, this allows a journal action
   -- to be set up for a premium to occur on the deal date (date type DEALT) or
   -- the commencment date of the option
   insert into XTR_DEAL_DATE_AMOUNTS
         (deal_type,amount_type,date_type,
          deal_number,transaction_number,transaction_date,currency,
          amount,hce_amount,amount_date,transaction_rate,
          cashflow_amount,company_code,deal_subtype,product_type,
          status_code,dealer_code,client_code,cparty_code,settle,
          portfolio_code,QUICK_INPUT)
    values('FXO','N/A','DEALT',
          P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY_BUY,
          0,0,P_DEAL_DATE,0,0,P_COMPANY_CODE,P_DEAL_SUBTYPE,
          P_PRODUCT_TYPE,P_STATUS_CODE,P_DEALER_CODE,
          P_CLIENT_CODE,P_CPARTY_CODE,'N',
          nvl(P_PORTFOLIO_CODE,'NOTAPPL'),P_QUICK_INPUT);
   --
  elsif P_KNOCK_TYPE = 'I' then
    if  P_CURRENCY IS NOT NULL and P_PREMIUM_ACTION is NOT NULL and nvl(P_PREMIUM_AMOUNT,0) > 0 then
     -- ** WARNING ** a copy of the next insert also appears in UPDATING.
     insert into XTR_DEAL_DATE_AMOUNTS
           (deal_type,amount_type,date_type,
            deal_number,transaction_number,transaction_date,currency,
            amount,hce_amount,amount_date,transaction_rate,
            cashflow_amount,company_code,account_no,action_code,
            cparty_account_no,deal_subtype,product_type,status_code,
            cparty_code,settle,client_code,portfolio_code,dealer_code,QUICK_INPUT)
     values(P_DEAL_TYPE,'PREMIUM','PREMIUM',
            P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
            P_PREMIUM_AMOUNT,P_PREMIUM_HCE_AMOUNT,
            P_PREMIUM_DATE,0,decode(P_PREMIUM_ACTION,
            'PAY',(-1) * P_PREMIUM_AMOUNT,P_PREMIUM_AMOUNT),
            P_COMPANY_CODE,P_PREMIUM_ACCOUNT_NO,P_PREMIUM_ACTION,
            decode(P_PREMIUM_ACTION,'PAY',P_CPARTY_ACCOUNT_NO),
            P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,P_CPARTY_CODE,
            'N',P_CLIENT_CODE,nvl(P_PORTFOLIO_CODE,'NOTAPPL'),P_DEALER_CODE,P_QUICK_INPUT);
    end if;
     -- Dummy rows for deal dealt and commence dates, this allows a journal action
     -- to be set up for a premium to occur on the deal date (date type DEALT) or
     -- the commencment date of the option
     insert into XTR_DEAL_DATE_AMOUNTS
           (deal_type,amount_type,date_type,
            deal_number,transaction_number,transaction_date,currency,
            amount,hce_amount,amount_date,transaction_rate,
            cashflow_amount,company_code,deal_subtype,product_type,
            status_code,dealer_code,client_code,cparty_code,settle,
            portfolio_code,QUICK_INPUT)
     values('FXO','N/A','DEALT',
            P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY_BUY,
            0,0,P_DEAL_DATE,0,0,P_COMPANY_CODE,P_DEAL_SUBTYPE,
            P_PRODUCT_TYPE,P_STATUS_CODE,P_DEALER_CODE,
            P_CLIENT_CODE,P_CPARTY_CODE,'N',
            nvl(P_PORTFOLIO_CODE,'NOTAPPL'),P_QUICK_INPUT);
     --
 end if;
elsif P_DEAL_TYPE = 'FX' then
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,
        currency,amount,hce_amount,amount_date,
        transaction_rate,cashflow_amount,company_code,
        account_no,deal_subtype,product_type,status_code,
        dealer_code,cparty_code,client_code,portfolio_code,
        settle,limit_code,limit_party,currency_combination,QUICK_INPUT)
 values(P_DEAL_TYPE,'BUY','VALUE',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY_BUY,
        P_BUY_AMOUNT,P_BUY_HCE_AMOUNT,P_VALUE_DATE,
        P_TRANSACTION_RATE,decode(P_SWAP_DEPO_FLAG,'B',0,P_BUY_AMOUNT),P_COMPANY_CODE,
        P_BUY_ACCOUNT_NO,P_DEAL_SUBTYPE,nvl(P_PRODUCT_TYPE,'NOT APPLIC'),
        P_STATUS_CODE,P_DEALER_CODE,P_CPARTY_CODE,
        P_CLIENT_CODE,nvl(P_PORTFOLIO_CODE,'NOTAPPL'),'N',
        decode(P_CURRENCY_BUY,base_ccy,nvl(P_LIMIT_CODE,'NILL'),NULL),
        decode(P_CURRENCY_BUY,base_ccy,P_CPARTY_CODE),l_combin,P_QUICK_INPUT);
 --
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,
        currency,amount,hce_amount,amount_date,
        transaction_rate,cashflow_amount,company_code,
        account_no,cparty_account_no,deal_subtype,
        product_type,status_code,dealer_code,cparty_code,
        client_code,portfolio_code,settle,limit_code,limit_party,currency_combination,QUICK_INPUT)
 values(P_DEAL_TYPE,'SELL','VALUE',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY_SELL,
        P_SELL_AMOUNT,nvl(P_BUY_HCE_AMOUNT,0),
        P_VALUE_DATE,P_TRANSACTION_RATE,decode(P_SWAP_DEPO_FLAG,'S',0,(-1) * P_SELL_AMOUNT),
        P_COMPANY_CODE,P_SELL_ACCOUNT_NO,P_CPARTY_ACCOUNT_NO,
        P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,
        P_DEALER_CODE,P_CPARTY_CODE,P_CLIENT_CODE,
        nvl(P_PORTFOLIO_CODE,'NOTAPPL'),'N',
        decode(P_CURRENCY_SELL,base_ccy,nvl(P_LIMIT_CODE,'NILL'),NULL),
        decode(P_CURRENCY_SELL,base_ccy,P_CPARTY_CODE),l_combin,P_QUICK_INPUT);
 --
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,
        currency,amount,hce_amount,amount_date,
        transaction_rate,cashflow_amount,company_code,
        account_no,cparty_account_no,deal_subtype,
        product_type,status_code,dealer_code,cparty_code,
        client_code,portfolio_code,settle,currency_combination,QUICK_INPUT)
 values(P_DEAL_TYPE,'N/A','DEALT',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY_SELL,
        P_SELL_AMOUNT,nvl(P_SELL_HCE_AMOUNT,0),
        P_DEAL_DATE,P_TRANSACTION_RATE,0,
        P_COMPANY_CODE,P_SELL_ACCOUNT_NO,P_CPARTY_ACCOUNT_NO,
        P_DEAL_SUBTYPE,nvl(P_PRODUCT_TYPE,'NOT APPLIC'),P_STATUS_CODE,
        P_DEALER_CODE,P_CPARTY_CODE,P_CLIENT_CODE,
        nvl(P_PORTFOLIO_CODE,'NOTAPPL'),'N',l_combin,P_QUICK_INPUT);
--
elsif P_DEAL_TYPE = 'NI' then

    insert into XTR_DEAL_DATE_AMOUNTS
        (deal_type,amount_type,date_type,
         deal_number,transaction_number,transaction_date,currency,
         amount,hce_amount,amount_date,transaction_rate,
         cashflow_amount,company_code,account_no,
         cparty_account_no,status_code,portfolio_code,dealer_code,
         client_code,deal_subtype,cparty_code,settle,product_type,
         commence_date,quick_input,limit_code)
    values('NI','COMENCE','COMENCE',
         P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
         P_START_AMOUNT,P_START_HCE_AMOUNT,P_START_DATE,P_INTEREST_RATE,
         decode(nvl(P_KNOCK_TYPE,'N'),'N',decode(P_DEAL_SUBTYPE,'BUY',-1,'COVER',-1,1)*P_START_AMOUNT,0),  -- Bug 3776211
         P_COMPANY_CODE,P_MATURITY_ACCOUNT_NO,
         P_CPARTY_ACCOUNT_NO,P_STATUS_CODE,P_PORTFOLIO_CODE,
         P_DEALER_CODE,P_CLIENT_CODE,P_DEAL_SUBTYPE,
         P_CPARTY_CODE,'N',P_PRODUCT_TYPE,P_START_DATE,P_QUICK_INPUT,
         decode(P_RISKPARTY_LIMIT_CODE, null,
                 decode(P_DEAL_SUBTYPE,'SELL','NILL',NULL),NULL));     -- jhung bug 1477157
 --              decode(P_DEAL_SUBTYPE,'ISSUE',NULL,'NILL'),NULL)); --  AW 9/24/99 Bug 996572

    -----------------------------------------------------------------------------
    -- Initial Maturity Face Value Details , before for sell status_code='CLOSED'
    -----------------------------------------------------------------------------
    insert into XTR_DEAL_DATE_AMOUNTS
          (deal_type,amount_type,date_type,
           deal_number,transaction_number,transaction_date,currency,
           amount,hce_amount,amount_date,transaction_rate,
           cashflow_amount,company_code,account_no,
           cparty_account_no,status_code,portfolio_code,dealer_code,
           client_code,deal_subtype,cparty_code,settle,product_type,commence_date,quick_input)
    values('NI','INTL_FV',decode(P_DEAL_SUBTYPE,'SELL','COMENCE','COVER','COMENCE','MATURE'),
           P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
           P_MATURITY_AMOUNT,P_MATURITY_HCE_AMOUNT,
           decode(P_DEAL_SUBTYPE,'SELL',P_START_DATE,'COVER',P_START_DATE,P_MATURITY_DATE),
           p_INTEREST_RATE,0,
           P_COMPANY_CODE,P_MATURITY_ACCOUNT_NO,P_CPARTY_ACCOUNT_NO,
           P_STATUS_CODE,P_PORTFOLIO_CODE,
           P_DEALER_CODE,P_CLIENT_CODE,P_DEAL_SUBTYPE,P_CPARTY_CODE,'N',
           P_PRODUCT_TYPE,P_START_DATE,P_QUICK_INPUT);
 --
    if P_DEAL_SUBTYPE in ('BUY','SHORT','ISSUE') and
       P_MATURITY_BALANCE_AMOUNT is NOT NULL then   /* in Pro0340 this column is null */
       -----------------------------
       -- BALance Face Value Details
       -----------------------------
       insert into XTR_DEAL_DATE_AMOUNTS
           (deal_type,amount_type,date_type,
            deal_number,transaction_number,transaction_date,currency,
            amount,hce_amount,amount_date,transaction_rate,
            cashflow_amount,company_code,account_no,
            cparty_account_no,status_code,portfolio_code,dealer_code,
            client_code,deal_subtype,cparty_code,settle,product_type,
            limit_code,limit_party,commence_date,quick_input)
       values('NI','BAL_FV','MATURE',
            P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
            P_MATURITY_BALANCE_AMOUNT,
            P_MATURITY_BALANCE_HCE_AMOUNT,P_MATURITY_DATE,
   --       P_INTEREST_RATE,decode(P_DEAL_SUBTYPE,'BUY',1,-1) *
            P_INTEREST_RATE,decode(P_DEAL_SUBTYPE,'BUY',1,'SELL',0,-1) *
            P_MATURITY_BALANCE_AMOUNT,P_COMPANY_CODE,
            P_MATURITY_ACCOUNT_NO,P_CPARTY_ACCOUNT_NO,
            P_STATUS_CODE,P_PORTFOLIO_CODE,P_DEALER_CODE,
            P_CLIENT_CODE,P_DEAL_SUBTYPE,P_CPARTY_CODE,'N',
            P_PRODUCT_TYPE,
            nvl(P_RISKPARTY_LIMIT_CODE, decode(P_LIMIT_CODE, null, decode(P_DEAL_SUBTYPE,
            'BUY','NILL','ISSUE', 'NILL', NULL), P_LIMIT_CODE)),
 	    nvl(P_RISKPARTY_CODE,decode(P_DEAL_SUBTYPE,'BUY',P_CPARTY_CODE,null)), --jhung bug 1477157
            P_START_DATE,P_QUICK_INPUT);
    end if;

    ---------------------
    -- INTerest Details
    ---------------------
    insert into XTR_DEAL_DATE_AMOUNTS
          (deal_type,amount_type,date_type,deal_number,
           transaction_number,transaction_date,currency,
           amount,hce_amount,amount_date,transaction_rate,
           cashflow_amount,company_code,portfolio_code,status_code,
           dealer_code,client_code,deal_subtype,cparty_code,
           settle,product_type,commence_date,quick_input)
    values('NI','INT','COMENCE',
           P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
           P_INTEREST_AMOUNT,P_INTEREST_HCE_AMOUNT,
           P_START_DATE,P_INTEREST_RATE,0,
           P_COMPANY_CODE,P_PORTFOLIO_CODE,P_STATUS_CODE,P_DEALER_CODE,
           P_CLIENT_CODE,P_DEAL_SUBTYPE,P_CPARTY_CODE,'N',
           P_PRODUCT_TYPE,P_START_DATE,P_QUICK_INPUT);

    --------------------------
    -- Deal DEALT on Details
    --------------------------
    insert into XTR_DEAL_DATE_AMOUNTS
          (deal_type,amount_type,date_type,
           deal_number,transaction_number,transaction_date,currency,
           amount,hce_amount,amount_date,transaction_rate,
           cashflow_amount,company_code,
           deal_subtype,product_type,status_code,dealer_code,
           client_code,cparty_code,portfolio_code,commence_date,quick_input)
    values('NI','N/A','DEALT',
           P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
           P_START_AMOUNT,P_START_HCE_AMOUNT,P_DEAL_DATE,0,0,P_COMPANY_CODE,
           P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,
           P_DEALER_CODE,P_CLIENT_CODE,P_CPARTY_CODE,
           nvl(P_PORTFOLIO_CODE,'NOTAPPL'),P_START_DATE,P_QUICK_INPUT);

    ------------
    -- NEW NI --
    ---------------------------------
    -- New Date Types/Amount Types --
    ---------------------------------
    if P_DEAL_SUBTYPE in ('BUY','SHORT') then
       insert into XTR_DEAL_DATE_AMOUNTS
             (deal_type,amount_type,date_type,
              deal_number,transaction_number,transaction_date,currency,
              amount,hce_amount,amount_date,transaction_rate,
              cashflow_amount,company_code,account_no,
              cparty_account_no,status_code,portfolio_code,dealer_code,
              client_code,deal_subtype,cparty_code,settle,product_type,
              commence_date,quick_input)
       values('NI','BALCOM','MATURE',
              P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
              P_START_AMOUNT,
              P_START_HCE_AMOUNT,P_MATURITY_DATE,
              P_INTEREST_RATE, 0,
              P_COMPANY_CODE,P_MATURITY_ACCOUNT_NO,
              P_CPARTY_ACCOUNT_NO,P_STATUS_CODE,P_PORTFOLIO_CODE,
              P_DEALER_CODE,P_CLIENT_CODE,P_DEAL_SUBTYPE,
              P_CPARTY_CODE,'N',P_PRODUCT_TYPE,P_START_DATE,P_QUICK_INPUT);
    end if;

elsif P_DEAL_TYPE = 'BOND' then
 --
 if P_DEAL_SUBTYPE <> 'SELL' then
  if nvl(P_CUM_COUPON_DATE,P_NEXT_COUPON_DATE) is NOT NULL then
   if P_COUPON_ACTION = 'CUM' then
    coupon_date := P_CUM_COUPON_DATE;
   else
    coupon_date := P_NEXT_COUPON_DATE;
   end if;
   l_start_date := add_months(coupon_date,-(12 / P_FREQUENCY));
   LOOP
   /*  This needs to be replaced with increment method for transaction number.
    open TRANS_NUM;
     fetch TRANS_NUM INTO l_trans_num;
    close TRANS_NUM;
   */
    if upper(P_CALC_TYPE) = 'VARIABLE COUPON' then
     coupon := round(P_MATURITY_AMOUNT * P_COUPON_RATE * (coupon_date -
                     l_start_date) / (nvl(P_BOND_YR_BASIS,365)
                     * 100),round_fac);
    else
     coupon := round(P_MATURITY_AMOUNT * (P_COUPON_RATE / 100) /
                     nvl(P_FREQUENCY,2),round_fac);
    end if;
    coupon_hce := round(coupon / hce_rate,round_fac);
    --
    insert into XTR_ROLLOVER_TRANSACTIONS
          (deal_number,transaction_number,deal_type,start_date,no_of_days,
           maturity_date,interest_rate,interest,interest_hce,deal_subtype,
           product_type,company_code,cparty_code,client_code,currency,
           deal_date,status_code,created_by,created_on,settle_date)
    values(P_DEAL_NO,l_trans_num,'BOND',l_start_date,(coupon_date -
           l_start_date),coupon_date,P_COUPON_RATE,coupon,coupon_hce,
           P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_COMPANY_CODE,P_CPARTY_CODE,
           P_CLIENT_CODE,P_CURRENCY,P_DEAL_DATE,'CURRENT',L_USER,
           L_SYSDATE,coupon_date);
     --
    insert into XTR_DEAL_DATE_AMOUNTS
          (deal_type,amount_type,date_type,
           deal_number,transaction_number,transaction_date,currency,
           amount,hce_amount,amount_date,transaction_rate,
           cashflow_amount,company_code,account_no,status_code,portfolio_code,
           dealer_code,client_code,deal_subtype,cparty_code,settle,product_type)
    values
         ('BOND','COUPON','COUPON',P_DEAL_NO,l_trans_num,P_DEAL_DATE,
          P_CURRENCY,coupon,coupon_hce,coupon_date,P_COUPON_RATE,
          decode(P_DEAL_SUBTYPE,'BUY',1,-1) * coupon,P_COMPANY_CODE,
          P_MATURITY_ACCOUNT_NO,P_STATUS_CODE,P_PORTFOLIO_CODE,
          P_DEALER_CODE,P_CLIENT_CODE,P_DEAL_SUBTYPE,P_ACCEPTOR_CODE,'N',
          P_PRODUCT_TYPE);
    --
    l_start_date := coupon_date;
    coupon_date  := add_months(coupon_date,(12 / P_FREQUENCY));
   EXIT WHEN coupon_date > P_MATURITY_DATE;
   END LOOP;
  end if;
 end if;
 --
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,account_no,
        cparty_account_no,status_code,portfolio_code,dealer_code,
        client_code,deal_subtype,cparty_code,settle,product_type)
 values('BOND','COMENCE','COMENCE',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        P_START_AMOUNT,P_START_HCE_AMOUNT,
        P_START_DATE,P_INTEREST_RATE,
        decode(P_DEAL_SUBTYPE,'BUY',-1,1) * P_START_AMOUNT,
        P_COMPANY_CODE,P_MATURITY_ACCOUNT_NO,
        P_CPARTY_ACCOUNT_NO,P_STATUS_CODE,P_PORTFOLIO_CODE,
        P_DEALER_CODE,P_CLIENT_CODE,P_DEAL_SUBTYPE,
        P_CPARTY_CODE,'N',P_PRODUCT_TYPE);
 --
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,account_no,
        cparty_account_no,status_code,portfolio_code,dealer_code,
        client_code,deal_subtype,cparty_code,settle,product_type,
        limit_code,limit_party)
 values('BOND','INTL_FV','MATURE',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        P_MATURITY_AMOUNT,P_MATURITY_HCE_AMOUNT,
        P_MATURITY_DATE,P_INTEREST_RATE,
        decode(P_DEAL_SUBTYPE,'BUY',1,-1) *
        P_MATURITY_AMOUNT,P_COMPANY_CODE,
        P_MATURITY_ACCOUNT_NO,P_CPARTY_ACCOUNT_NO,
        P_STATUS_CODE,P_PORTFOLIO_CODE,P_DEALER_CODE,
        P_CLIENT_CODE,P_DEAL_SUBTYPE,P_ACCEPTOR_CODE,'N',
        P_PRODUCT_TYPE,nvl(P_LIMIT_CODE,'NILL'),P_ACCEPTOR_CODE);
 -- if P_COUPON_ACTION = 'CUM' then
 -- Accrued Int values
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,status_code,
        portfolio_code,dealer_code,client_code,deal_subtype,
        cparty_code,settle,product_type)
 values('BOND','INT','COMENCE',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        P_INT_VALUE,round(P_INT_VALUE/hce_rate,round_fac),P_START_DATE,
        P_INTEREST_RATE,0,P_COMPANY_CODE,P_STATUS_CODE,
        P_PORTFOLIO_CODE,P_DEALER_CODE,P_CLIENT_CODE,
        P_DEAL_SUBTYPE,P_CPARTY_CODE,'N',P_PRODUCT_TYPE);
 --- end if;
 -- Premium / Discount Values
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,status_code,
        portfolio_code,dealer_code,client_code,deal_subtype,
        cparty_code,settle,product_type)
 values('BOND',decode(sign(P_PREM_VALUE),-1,'DISC','PREMIUM'),
        'COMENCE',P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        abs(P_PREM_VALUE),abs(round(P_PREM_VALUE/hce_rate,round_fac)),
        P_START_DATE,P_INTEREST_RATE,0,
        P_COMPANY_CODE,P_STATUS_CODE,P_PORTFOLIO_CODE,
        P_DEALER_CODE,P_CLIENT_CODE,P_DEAL_SUBTYPE,
        P_CPARTY_CODE,'N',P_PRODUCT_TYPE);
elsif P_DEAL_TYPE = 'IRO' then
 -- Limit Row / Limit Amount Details
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,
        cashflow_amount,company_code,deal_subtype,product_type,
        status_code,dealer_code,client_code,cparty_code,settle,
        limit_code,limit_party,portfolio_code)
 values('IRO','N/A','LIMIT',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        nvl(nvl(P_FACE_VALUE_AMOUNT,P_MATURITY_AMOUNT),0),
        nvl(nvl(P_FACE_VALUE_HCE_AMOUNT,P_MATURITY_HCE_AMOUNT),0),
        P_EXPIRY_DATE,0,
        P_COMPANY_CODE,P_DEAL_SUBTYPE,P_PRODUCT_TYPE,
        P_STATUS_CODE,P_DEALER_CODE,P_CLIENT_CODE,
        P_CPARTY_CODE,'N',nvl(P_LIMIT_CODE,'NILL'),
        P_CPARTY_CODE,nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
 -- Expiry Date / Face Value Amount Details
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,deal_subtype,product_type,
        status_code,dealer_code,client_code,cparty_code,settle,
        portfolio_code)
 values('IRO','FACEVAL','EXPIRY',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        nvl(nvl(P_FACE_VALUE_AMOUNT,P_MATURITY_AMOUNT),0),
        nvl(nvl(P_FACE_VALUE_HCE_AMOUNT,P_MATURITY_HCE_AMOUNT),0),
        P_EXPIRY_DATE,P_INTEREST_RATE,0,
        P_COMPANY_CODE,P_DEAL_SUBTYPE,P_PRODUCT_TYPE,
        P_STATUS_CODE,P_DEALER_CODE,P_CLIENT_CODE,
        P_CPARTY_CODE,'N',
        nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
 -- Premium Date / Premium Amount Details
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,
        company_code,account_no,action_code,cparty_account_no,
        deal_subtype,product_type,status_code,dealer_code,
        client_code,cparty_code,settle,portfolio_code)
 values('IRO','PREMIUM','PREMIUM',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        nvl(P_PREMIUM_AMOUNT,0),nvl(P_PREMIUM_HCE_AMOUNT,0),
        nvl(P_PREMIUM_DATE,P_START_DATE),0,
        decode(P_PREMIUM_ACTION,'PAY',-(1),1) * nvl(P_PREMIUM_AMOUNT,0),
        P_COMPANY_CODE,P_PREMIUM_ACCOUNT_NO,P_PREMIUM_ACTION,
        decode(P_PREMIUM_ACTION,'PAY',P_CPARTY_ACCOUNT_NO,''),
        P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,
        P_DEALER_CODE,P_CLIENT_CODE,P_CPARTY_CODE,'N',
        nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
 -- Deal Dealt on Details
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,
        deal_subtype,product_type,status_code,dealer_code,
        client_code,cparty_code,portfolio_code)
 values('IRO','FACEVAL','DEALT',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        nvl(nvl(P_FACE_VALUE_AMOUNT,P_MATURITY_AMOUNT),0),
        nvl(nvl(P_FACE_VALUE_HCE_AMOUNT,P_MATURITY_HCE_AMOUNT),0),
        P_DEAL_DATE,0,0,P_COMPANY_CODE,
        P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,
        P_DEALER_CODE,P_CLIENT_CODE,P_CPARTY_CODE,
        nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
 -- AW Bug 894751 American Option
 /*
 values('IRO','N/A','DEALT',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        0,0,P_DEAL_DATE,0,0,P_COMPANY_CODE,
        P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,
        P_DEALER_CODE,P_CLIENT_CODE,P_CPARTY_CODE,
        nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
 */
 -- Physical Commencement Date Details
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,
        deal_subtype,product_type,status_code,dealer_code,
        client_code,cparty_code,portfolio_code)
 values('IRO','FACEVAL','COMENCE',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        nvl(nvl(P_FACE_VALUE_AMOUNT,P_MATURITY_AMOUNT),0),
        0,P_START_DATE,0,0,P_COMPANY_CODE,
        P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,
        P_DEALER_CODE,P_CLIENT_CODE,P_CPARTY_CODE,
        nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
 -- Physical Maturity Date Details
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,
        deal_subtype,product_type,status_code,dealer_code,
        client_code,cparty_code,portfolio_code)
 values('IRO','N/A','MATURE',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        0,0,P_MATURITY_DATE,0,0,P_COMPANY_CODE,
        P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,
        P_DEALER_CODE,P_CLIENT_CODE,P_CPARTY_CODE,
        nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
elsif P_DEAL_TYPE = 'BDO' then
 -- Limit Row / Limit Amount Details
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,
        cashflow_amount,company_code,deal_subtype,product_type,
        status_code,dealer_code,client_code,cparty_code,settle,
        limit_code,limit_party,portfolio_code)
 values('BDO','N/A','LIMIT',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        nvl(nvl(P_FACE_VALUE_AMOUNT,P_MATURITY_AMOUNT),0),
        nvl(nvl(P_FACE_VALUE_HCE_AMOUNT,P_MATURITY_HCE_AMOUNT),0),
        P_EXPIRY_DATE,0,
        P_COMPANY_CODE,P_DEAL_SUBTYPE,P_PRODUCT_TYPE,
        P_STATUS_CODE,P_DEALER_CODE,P_CLIENT_CODE,
        P_CPARTY_CODE,'N',nvl(P_LIMIT_CODE,'NILL'),
        P_CPARTY_CODE,nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
 -- Expiry Date / Face Value Amount Details
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,deal_subtype,product_type,
        status_code,dealer_code,client_code,cparty_code,settle,
        portfolio_code)
 values('BDO','FACEVAL','EXPIRY',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        nvl(nvl(P_FACE_VALUE_AMOUNT,P_MATURITY_AMOUNT),0),
        nvl(nvl(P_FACE_VALUE_HCE_AMOUNT,P_MATURITY_HCE_AMOUNT),0),
        P_EXPIRY_DATE,P_INTEREST_RATE,0,
        P_COMPANY_CODE,P_DEAL_SUBTYPE,P_PRODUCT_TYPE,
        P_STATUS_CODE,P_DEALER_CODE,P_CLIENT_CODE,
        P_CPARTY_CODE,'N',
        nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
 -- Premium Date / Premium Amount Details
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,
        company_code,account_no,action_code,cparty_account_no,
        deal_subtype,product_type,status_code,dealer_code,
        client_code,cparty_code,settle,portfolio_code)
 values('BDO','PREMIUM','PREMIUM',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        nvl(P_PREMIUM_AMOUNT,0),nvl(P_PREMIUM_HCE_AMOUNT,0),
        nvl(P_PREMIUM_DATE,P_START_DATE),0,
        decode(P_PREMIUM_ACTION,'PAY',-(1),1) * nvl(P_PREMIUM_AMOUNT,0),
        P_COMPANY_CODE,P_PREMIUM_ACCOUNT_NO,P_PREMIUM_ACTION,
        decode(P_PREMIUM_ACTION,'PAY',P_CPARTY_ACCOUNT_NO,''),
        P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,
        P_DEALER_CODE,P_CLIENT_CODE,P_CPARTY_CODE,'N',
        nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
 -- Deal Dealt on Details
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,
        deal_subtype,product_type,status_code,dealer_code,
        client_code,cparty_code,portfolio_code)
 values('BDO','FACEVAL','DEALT',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        nvl(nvl(P_FACE_VALUE_AMOUNT,P_MATURITY_AMOUNT),0),
        nvl(nvl(P_FACE_VALUE_HCE_AMOUNT,P_MATURITY_HCE_AMOUNT),0),
        P_DEAL_DATE,0,0,P_COMPANY_CODE,
        P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,
        P_DEALER_CODE,P_CLIENT_CODE,P_CPARTY_CODE,
        nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
 -- AW Bug 894751
 /*
 values('BDO','N/A','DEALT',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        0,0,P_DEAL_DATE,0,0,P_COMPANY_CODE,
        P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,
        P_DEALER_CODE,P_CLIENT_CODE,P_CPARTY_CODE,
        nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
 */
 -- Physical Commencement Date Details
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,
        deal_subtype,product_type,status_code,dealer_code,
        client_code,cparty_code,portfolio_code)
 values('BDO','FACEVAL','COMENCE',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        nvl(nvl(P_FACE_VALUE_AMOUNT,P_MATURITY_AMOUNT),0),
        nvl(nvl(P_FACE_VALUE_HCE_AMOUNT,P_MATURITY_HCE_AMOUNT),0),
        P_START_DATE,0,0,P_COMPANY_CODE,
        P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,
        P_DEALER_CODE,P_CLIENT_CODE,P_CPARTY_CODE,
        nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
 -- Physical Maturity Date Details
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,
        deal_subtype,product_type,status_code,dealer_code,
        client_code,cparty_code,portfolio_code)
 values('BDO','N/A','MATURE',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        0,0,P_MATURITY_DATE,0,0,P_COMPANY_CODE,
        P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,
        P_DEALER_CODE,P_CLIENT_CODE,P_CPARTY_CODE,
        nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
elsif P_DEAL_TYPE = 'FUT' then
 -- Face Value Amount
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,deal_subtype,product_type,
        status_code,dealer_code,client_code,cparty_code,settle,
        limit_code,limit_party,portfolio_code,contract_code)
 values('FUT','FACEVAL','EXPIRY',
        P_DEAL_NO,1,P_DEAL_DATE,
        nvl(P_CURRENCY_BUY,'N/A'),
        nvl(P_START_AMOUNT,0),nvl(P_START_HCE_AMOUNT,
        P_START_AMOUNT),P_EXPIRY_DATE,nvl(P_TRANSACTION_RATE,P_CONTRACT_RATE),0,
        P_COMPANY_CODE,P_DEAL_SUBTYPE,P_PRODUCT_TYPE,
        P_STATUS_CODE,P_DEALER_CODE,P_CLIENT_CODE,
        P_CPARTY_CODE,'N',nvl(P_LIMIT_CODE,'NILL'),
        P_CPARTY_CODE,nvl(P_PORTFOLIO_CODE,'NOTAPPL'),P_BOND_ISSUE);
 if nvl(P_PREMIUM_AMOUNT,0)+nvl(P_CONTRACT_COMMISSION,0)+nvl(P_CONTRACT_FEES,0) > 0 then
  -- Settlement Amount
  insert into XTR_DEAL_DATE_AMOUNTS
        (deal_type,amount_type,date_type,
         deal_number,transaction_number,transaction_date,currency,
         amount,hce_amount,amount_date,transaction_rate,
         cashflow_amount,company_code,account_no,action_code,
         cparty_account_no,deal_subtype,product_type,status_code,
         dealer_code,client_code,cparty_code,settle,
         portfolio_code,contract_code)
  values('FUT','PREMIUM','SETTLE',
         P_DEAL_NO,1,P_DEAL_DATE,P_PREMIUM_CURRENCY,
         nvl(P_PREMIUM_AMOUNT,0)+nvl(P_CONTRACT_COMMISSION,0)+nvl(P_CONTRACT_FEES,0) ,nvl(P_PREMIUM_HCE_AMOUNT,0),
         P_PREMIUM_DATE,0,-(1) * (nvl(P_PREMIUM_AMOUNT,0)+nvl(P_CONTRACT_COMMISSION,0)+nvl(P_CONTRACT_FEES,0)),
         P_COMPANY_CODE,P_SETTLE_ACCOUNT_NO,'PAY',
         P_CPARTY_ACCOUNT_NO,P_DEAL_SUBTYPE,P_PRODUCT_TYPE,
         P_STATUS_CODE,P_DEALER_CODE,P_CLIENT_CODE,
         P_CPARTY_CODE,'N',nvl(P_PORTFOLIO_CODE,'NOTAPPL'),P_BOND_ISSUE);
 end if;
 -- Dummy row for deal dealt date, this allows a journal action
 -- to be set up for a premium to occur on the deal date (date type DEALT)
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,deal_subtype,product_type,
        status_code,dealer_code,client_code,cparty_code,settle,
        portfolio_code)
 values('FUT','DEALT','DEALT',
        P_DEAL_NO,1,P_DEAL_DATE,P_PREMIUM_CURRENCY,
        0,0,P_DEAL_DATE,0,0,P_COMPANY_CODE,P_DEAL_SUBTYPE,
        P_PRODUCT_TYPE,P_STATUS_CODE,P_DEALER_CODE,
        P_CLIENT_CODE,P_CPARTY_CODE,'N',
        nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
elsif P_DEAL_TYPE = 'SWPTN' then
 -- Limit Row / Limit Details
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,
        cashflow_amount,company_code,deal_subtype,product_type,
        status_code,dealer_code,client_code,cparty_code,settle,
        limit_code,limit_party,portfolio_code)
 values('SWPTN','N/A','LIMIT',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        nvl(P_FACE_VALUE_AMOUNT,0),nvl(P_FACE_VALUE_HCE_AMOUNT,0),
        P_EXPIRY_DATE,0,
        P_COMPANY_CODE,P_DEAL_SUBTYPE,P_PRODUCT_TYPE,
        P_STATUS_CODE,P_DEALER_CODE,P_CLIENT_CODE,
        P_CPARTY_CODE,'N',nvl(P_LIMIT_CODE,'NILL'),
        P_CPARTY_CODE,nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
-- Face Value Amount / Expiry Date Details
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,deal_subtype,product_type,
        status_code,dealer_code,client_code,cparty_code,settle,
        portfolio_code)
 values('SWPTN','FACEVAL','EXPIRY',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        nvl(P_FACE_VALUE_AMOUNT,0),nvl(P_FACE_VALUE_HCE_AMOUNT,0),
        P_EXPIRY_DATE,P_INTEREST_RATE,0,
        P_COMPANY_CODE,P_DEAL_SUBTYPE,P_PRODUCT_TYPE,
        P_STATUS_CODE,P_DEALER_CODE,P_CLIENT_CODE,
        P_CPARTY_CODE,'N',
        nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
-- Premium Details
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,account_no,action_code,cparty_account_no,
        deal_subtype,product_type,status_code,dealer_code,
        client_code,cparty_code,settle,portfolio_code)
 values('SWPTN','PREMIUM','PREMIUM',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY_BUY,
        nvl(P_PREMIUM_AMOUNT,0),nvl(P_PREMIUM_HCE_AMOUNT,0),
        nvl(P_PREMIUM_DATE,P_START_DATE),0,
        decode(P_PREMIUM_ACTION,'PAY',-(1),1) * nvl(P_PREMIUM_AMOUNT,0),
        P_COMPANY_CODE,P_PREMIUM_ACCOUNT_NO,P_PREMIUM_ACTION,
        decode(P_PREMIUM_ACTION,'PAY',P_CPARTY_ACCOUNT_NO,''),
        P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,
        P_DEALER_CODE,P_CLIENT_CODE,P_CPARTY_CODE,'N',
        nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
 -- Dummy row for deal dealt date, this allows a journal action
 -- to be set up for a premium to occur on the deal date (date type DEALT)
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,deal_subtype,product_type,
        status_code,dealer_code,client_code,cparty_code,settle,portfolio_code)
 values('SWPTN','FACEVAL','DEALT',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY_BUY,
        nvl(P_PREMIUM_AMOUNT,0),nvl(P_PREMIUM_HCE_AMOUNT,0),
        P_DEAL_DATE,0,0,P_COMPANY_CODE,P_DEAL_SUBTYPE,
        P_PRODUCT_TYPE,P_STATUS_CODE,P_DEALER_CODE,
        P_CLIENT_CODE,P_CPARTY_CODE,'N',nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
 -- AW Bug 894751
 /*
 values('SWPTN','N/A','DEALT',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY_BUY,
        0,0,P_DEAL_DATE,0,0,P_COMPANY_CODE,P_DEAL_SUBTYPE,
        P_PRODUCT_TYPE,P_STATUS_CODE,P_DEALER_CODE,
        P_CLIENT_CODE,P_CPARTY_CODE,'N',nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
 */
 -- Settlement Details
 if P_SETTLE_DATE is NOT NULL then
   xtr_fps2_p.standing_settlements(P_CPARTY_CODE,P_CURRENCY,'SWPTN',
                                   P_DEAL_SUBTYPE,P_PRODUCT_TYPE,'SETTLE',
                                   v_settle_ref,v_settle_ac);
  insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,account_no,action_code,
        cparty_account_no,deal_subtype,product_type,status_code,
        dealer_code,client_code,cparty_code,settle,portfolio_code)
  values('SWPTN','SETTLE','SETTLE',
         P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
         nvl(P_SETTLE_AMOUNT,0),nvl(P_SETTLE_HCE_AMOUNT,0),
         nvl(P_SETTLE_DATE,P_START_DATE),0,
         decode(P_SETTLE_ACTION,'PAY',-(1),1) * nvl(P_SETTLE_AMOUNT,0),
         P_COMPANY_CODE,P_SETTLE_ACCOUNT_NO,P_SETTLE_ACTION,
         nvl(v_settle_ac,P_CPARTY_ACCOUNT_NO), --BUG 2910654
         P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,
         P_DEALER_CODE,P_CLIENT_CODE,P_CPARTY_CODE,'N',
         nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
 end if;
 -- Underlying Physical Start Details
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,deal_subtype,product_type,
        status_code,dealer_code,client_code,cparty_code,settle,
        portfolio_code)
 values('SWPTN','FACEVAL','COMENCE',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        nvl(P_FACE_VALUE_AMOUNT,0),nvl(P_FACE_VALUE_HCE_AMOUNT,0),
        P_START_DATE,P_INTEREST_RATE,0,
        P_COMPANY_CODE,P_DEAL_SUBTYPE,P_PRODUCT_TYPE,
        P_STATUS_CODE,P_DEALER_CODE,P_CLIENT_CODE,
        P_CPARTY_CODE,'N',P_PORTFOLIO_CODE);
 -- Underlying Physical Maturity Details
 insert into XTR_DEAL_DATE_AMOUNTS
       (deal_type,amount_type,date_type,
        deal_number,transaction_number,transaction_date,currency,
        amount,hce_amount,amount_date,transaction_rate,
        cashflow_amount,company_code,deal_subtype,product_type,
        status_code,dealer_code,client_code,cparty_code,settle,portfolio_code)
 values('SWPTN','N/A','MATURE',
        P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
        0,0,P_MATURITY_DATE,P_INTEREST_RATE,0,
        P_COMPANY_CODE,P_DEAL_SUBTYPE,P_PRODUCT_TYPE,
        P_STATUS_CODE,P_DEALER_CODE,P_CLIENT_CODE,
        P_CPARTY_CODE,'N',nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
 -- end of deal types for inserting
 end if;
--
elsif P_ACTION = 'UPDATE' then
 -- Delete rows in DDA for cancelled transactions
 if P_STATUS_CODE = 'CANCELLED' then
    delete from XTR_DEAL_DATE_AMOUNTS
    where deal_number = P_DEAL_NO;
    --
    if P_DEAL_TYPE = 'BOND' then
       -- coupons
       delete from XTR_ROLLOVER_TRANSACTIONS
       where deal_number = P_DEAL_NO;
    elsif P_DEAL_TYPE = 'FX' then
       -- Swapdepo transactions
       update XTR_ROLLOVER_TRANSACTIONS
       set STATUS_CODE = 'CANCELLED'
       where deal_number = P_DEAL_NO;
    end if;
    --
    if P_DEAL_TYPE = 'NI' then
       update XTR_PARCEL_SPLITS
       set    status_code = 'CANCELLED'
       where  deal_no     = P_DEAL_NO
       and    parcel_size = nvl(parcel_remaining,0);
/*
       ------------
       -- NEW NI --
       ------------
       update XTR_ROLLOVER_TRANSACTIONS
       set    STATUS_CODE = 'CANCELLED'
       where  DEAL_NUMBER = P_DEAL_NO
       and    TRANS_CLOSEOUT_NO is null;
*/
    end if;
 --
 -- Where not cancelled
 else
  if P_DEAL_TYPE = 'FRA' then
   update XTR_DEAL_DATE_AMOUNTS
    set amount           = decode(AMOUNT_TYPE,'FACEVAL',P_FACE_VALUE_AMOUNT,amount),
        hce_amount       = decode(AMOUNT_TYPE,'FACEVAL',P_FACE_VALUE_HCE_AMOUNT,hce_amount),
        amount_date      = decode(DATE_TYPE,'COMENCE',P_START_DATE,'MATURE',P_MATURITY_DATE,'DEALT',P_DEAL_DATE,
                                            'RATESET',P_RATE_FIXING_DATE,amount_date),
        transaction_rate = decode(DATE_TYPE,'COMENCE',P_INTEREST_RATE,'MATURE',P_INTEREST_RATE,
                                            'RATESET',P_SETTLE_RATE,transaction_rate),
        transaction_date = P_DEAL_DATE,
        currency         = P_CURRENCY,
        company_code     = P_COMPANY_CODE,
        deal_subtype     = P_DEAL_SUBTYPE,
        product_type     = P_PRODUCT_TYPE,
        portfolio_code   = P_PORTFOLIO_CODE,
        status_code      = P_STATUS_CODE,
        dealer_code      = P_DEALER_CODE,
        client_code      = P_CLIENT_CODE,
        cparty_code      = P_CPARTY_CODE,
        action_code      = NULL,
        limit_code       = decode(P_SETTLE_DATE,NULL,decode(DATE_TYPE,'LIMIT',nvl(P_LIMIT_CODE,'NILL'),NULL),NULL),
        limit_party      = decode(P_SETTLE_DATE,NULL,decode(DATE_TYPE,'LIMIT',P_CPARTY_CODE,NULL),NULL)
    where DEAL_NUMBER = P_DEAL_NO
    and DEAL_TYPE = 'FRA'
    and AMOUNT_TYPE <> 'SETTLE'
    and DATE_TYPE <> 'LIMIT';
    --
    if P_SETTLE_DATE IS NOT NULL then
     open C_LIMIT_WEIGHTING(P_DEAL_TYPE, P_DEAL_SUBTYPE);
     fetch C_LIMIT_WEIGHTING into v_weighting;
     close C_LIMIT_WEIGHTING;
     update XTR_DEAL_DATE_AMOUNTS
      set AMOUNT             = (100/v_weighting*nvl(P_SETTLE_AMOUNT,0)),
          HCE_AMOUNT         = (100/v_weighting*nvl(P_SETTLE_HCE_AMOUNT,0)),
          AMOUNT_DATE        = P_SETTLE_DATE,
          STATUS_CODE        = P_STATUS_CODE,
          transaction_date   = P_DEAL_DATE,
          currency           = P_CURRENCY,
          company_code       = P_COMPANY_CODE,
          deal_subtype       = P_DEAL_SUBTYPE,
          product_type       = P_PRODUCT_TYPE,
          portfolio_code     = P_PORTFOLIO_CODE,
          dealer_code        = P_DEALER_CODE,
          client_code        = P_CLIENT_CODE,
          cparty_code        = P_CPARTY_CODE,
          limit_code         = nvl(P_LIMIT_CODE,'NILL'),
          limit_party        = P_CPARTY_CODE
      where DEAL_NUMBER = P_DEAL_NO
      and DATE_TYPE = 'LIMIT'
      and DEAL_TYPE = 'FRA';
     update XTR_DEAL_DATE_AMOUNTS
      set AMOUNT             = nvl(P_SETTLE_AMOUNT,0),
          ACTION_CODE        = P_SETTLE_ACTION,
          HCE_AMOUNT         = nvl(P_SETTLE_HCE_AMOUNT,0),
          CASHFLOW_AMOUNT    = (decode(P_SETTLE_ACTION,'PAY',-1,1) * nvl(P_SETTLE_AMOUNT,0)),
          CPARTY_ACCOUNT_NO  = nvl(v_cparty_account_no, cparty_account_no),
          ACCOUNT_NO         = nvl(v_SETTLE_ACCOUNT_NO, account_no),
          AMOUNT_DATE        = P_SETTLE_DATE,
          STATUS_CODE        = P_STATUS_CODE,
          TRANSACTION_RATE   = P_SETTLE_RATE,
          transaction_date   = P_DEAL_DATE,
          currency           = P_CURRENCY,
          company_code       = P_COMPANY_CODE,
          deal_subtype       = P_DEAL_SUBTYPE,
          product_type       = P_PRODUCT_TYPE,
          portfolio_code     = P_PORTFOLIO_CODE,
          dealer_code        = P_DEALER_CODE,
          client_code        = P_CLIENT_CODE,
          cparty_code        = P_CPARTY_CODE
      where DEAL_NUMBER = P_DEAL_NO
      and AMOUNT_TYPE = 'SETTLE'
      and DATE_TYPE = 'SETTLE'
      and DEAL_TYPE = 'FRA';
     --
     if SQL%NOTFOUND then
      -- Settlement Row
      insert into XTR_DEAL_DATE_AMOUNTS
            (deal_type,amount_type,date_type,
             deal_number,transaction_number,transaction_date,currency,
             amount,hce_amount,amount_date,transaction_rate,
             cashflow_amount,company_code,account_no,cparty_account_no,action_code,
             deal_subtype,product_type,status_code,portfolio_code,
             dealer_code,client_code,cparty_code,settle)
      values('FRA','SETTLE','SETTLE',
             P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
             nvl(P_SETTLE_AMOUNT,0),nvl(P_SETTLE_HCE_AMOUNT,0),
             P_SETTLE_DATE,nvl(P_SETTLE_RATE,0),
             decode(P_SETTLE_ACTION,'PAY',-1,1) *
             nvl(P_SETTLE_AMOUNT,0),P_COMPANY_CODE,
             P_SETTLE_ACCOUNT_NO,P_CPARTY_ACCOUNT_NO,P_SETTLE_ACTION,P_DEAL_SUBTYPE,
             P_PRODUCT_TYPE,P_STATUS_CODE,P_PORTFOLIO_CODE,
             P_DEALER_CODE,P_CLIENT_CODE,P_CPARTY_CODE,'N');
     end if;
    end if;
  elsif P_DEAL_TYPE = 'FXO' THEN
   update XTR_DEAL_DATE_AMOUNTS
    set amount              = decode(amount_type,'FXOBUY',P_BUY_AMOUNT,P_SELL_AMOUNT),
        hce_amount          = decode(amount_type,'FXOBUY',P_BUY_HCE_AMOUNT,P_SELL_HCE_AMOUNT),
        amount_date         = P_EXPIRY_DATE,
    --    account_no          = decode(amount_type,'FXOBUY',P_BUY_ACCOUNT_NO,P_SELL_ACCOUNT_NO),
    -- for bug 965188 part 2 account number should not be updated at all
        limit_code          = decode(P_STATUS_CODE,'CURRENT',
                                   decode(amount_type,'FXOBUY',
                                        decode(P_CURRENCY_BUY,base_ccy,nvl(P_LIMIT_CODE,'NILL'),NULL),
                                        decode(P_CURRENCY_SELL,base_ccy,nvl(P_LIMIT_CODE,'NILL'),NULL)),NULL),
        limit_party          = decode(P_STATUS_CODE,'CURRENT',
                                   decode(amount_type,'FXOBUY',
                                        decode(P_CURRENCY_BUY,base_ccy,P_CPARTY_CODE,NULL),
                                        decode(P_CURRENCY_SELL,base_ccy,P_CPARTY_CODE,NULL)),NULL),
        transaction_date    = P_DEAL_DATE,
        currency            = decode(amount_type,'FXOBUY',P_CURRENCY_BUY,P_CURRENCY_SELL),
        company_code        = P_COMPANY_CODE,
        deal_subtype        = P_DEAL_SUBTYPE,
        product_type        = P_PRODUCT_TYPE,
        portfolio_code      = P_PORTFOLIO_CODE,
        status_code         = P_STATUS_CODE,
        dealer_code         = P_DEALER_CODE,
        client_code         = P_CLIENT_CODE,
        cparty_code         = P_CPARTY_CODE
    where deal_number = P_DEAL_NO
    and date_type = 'EXPIRY'
    and deal_type = P_DEAL_TYPE;

   if SQL%NOTFOUND then
     if P_STATUS_CODE='CURRENT' and nvl(P_KNOCK_TYPE,'@#@')='I' and nvl(P_KNOCK_INSERT_TYPE,'D')='E'then
   insert into XTR_DEAL_DATE_AMOUNTS
         (deal_type,amount_type,date_type,
          deal_number,transaction_number,transaction_date,currency,
          amount,hce_amount,amount_date,transaction_rate,
          cashflow_amount,company_code,deal_subtype,product_type,
          status_code,cparty_code,settle,client_code,
          limit_code,limit_party,portfolio_code,dealer_code,currency_combination,QUICK_INPUT)
   values(P_DEAL_TYPE,'FXOBUY','EXPIRY',
          P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY_BUY,
          P_BUY_AMOUNT,P_BUY_HCE_AMOUNT,
          P_EXPIRY_DATE,P_TRANSACTION_RATE,0,P_COMPANY_CODE,
          P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,
          P_CPARTY_CODE,'N',P_CLIENT_CODE,
          decode(P_CURRENCY_BUY,base_ccy,nvl(P_LIMIT_CODE,'NILL'),NULL),
          decode(P_CURRENCY_BUY,base_ccy,P_CPARTY_CODE,NULL),
          nvl(P_PORTFOLIO_CODE,'NOTAPPL'),P_DEALER_CODE,l_combin,P_QUICK_INPUT);
   --
   insert into XTR_DEAL_DATE_AMOUNTS
         (deal_type,amount_type,date_type,
          deal_number,transaction_number,transaction_date,currency,
          amount,hce_amount,amount_date,transaction_rate,
          cashflow_amount,company_code,deal_subtype,product_type,
          status_code,cparty_code,settle,
          client_code,portfolio_code,limit_code,limit_party,dealer_code,currency_combination,QUICK_INPUT)
   values(P_DEAL_TYPE,'FXOSELL','EXPIRY',P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY_SELL,
          P_SELL_AMOUNT,P_SELL_HCE_AMOUNT,P_EXPIRY_DATE,P_TRANSACTION_RATE,0,
          P_COMPANY_CODE,P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,P_CPARTY_CODE,'N',
          P_CLIENT_CODE,nvl(P_PORTFOLIO_CODE,'NOTAPPL'),
          decode(P_CURRENCY_SELL,base_ccy,nvl(P_LIMIT_CODE,'NILL'),NULL),
          decode(P_CURRENCY_SELL,base_ccy,P_CPARTY_CODE,NULL),
          P_DEALER_CODE,l_combin,P_QUICK_INPUT);
     end if;
   end if;

   --
   update XTR_DEAL_DATE_AMOUNTS
    set amount_date         = P_DEAL_DATE,
        transaction_date    = P_DEAL_DATE,
        currency            = P_CURRENCY_BUY,
        company_code        = P_COMPANY_CODE,
        deal_subtype        = P_DEAL_SUBTYPE,
        product_type        = P_PRODUCT_TYPE,
        portfolio_code      = P_PORTFOLIO_CODE,
        status_code         = P_STATUS_CODE,
        dealer_code         = P_DEALER_CODE,
        client_code         = P_CLIENT_CODE,
        cparty_code         = P_CPARTY_CODE
    where deal_number = P_DEAL_NO
    and date_type   = 'DEALT'
    and deal_type   = P_DEAL_TYPE;
   --
   update XTR_DEAL_DATE_AMOUNTS
    set amount             = P_PREMIUM_AMOUNT,
        hce_amount         = P_PREMIUM_HCE_AMOUNT,
        amount_date        = P_PREMIUM_DATE,
        cashflow_amount    =  DECODE(P_PREMIUM_ACTION,'PAY',(-1) * P_PREMIUM_AMOUNT,P_PREMIUM_AMOUNT),
        account_no         = nvl(v_PREMIUM_ACCOUNT_NO, account_no),
        cparty_account_no   = nvl(v_cparty_account_no, cparty_account_no),
        transaction_date    = P_DEAL_DATE,
        currency            = P_CURRENCY,
        company_code        = P_COMPANY_CODE,
        deal_subtype        = P_DEAL_SUBTYPE,
        product_type        = P_PRODUCT_TYPE,
        portfolio_code      = P_PORTFOLIO_CODE,
        status_code         = P_STATUS_CODE,
        dealer_code         = P_DEALER_CODE,
        client_code         = P_CLIENT_CODE,
        cparty_code         = P_CPARTY_CODE,
        action_code         = P_PREMIUM_ACTION
   where deal_number         = P_DEAL_NO
   and date_type            = 'PREMIUM'
   and deal_type           = P_DEAL_TYPE;
   --
   if SQL%NOTFOUND AND P_CURRENCY IS NOT NULL
    and P_PREMIUM_ACTION is NOT NULL
    and nvl(P_PREMIUM_AMOUNT,0) > 0 and P_STATUS_CODE <> 'CANCELLED'
     then
    --
--Bug 8561305 Starts
    open CHK_FXO_PREMIUM;
    fetch CHK_FXO_PREMIUM into dda_premium_v;
    close CHK_FXO_PREMIUM;

    if (dda_premium_v <> 1) then

    insert into XTR_DEAL_DATE_AMOUNTS
           (deal_type,amount_type,date_type,
            deal_number,transaction_number,transaction_date,currency,
            amount,hce_amount,amount_date,transaction_rate,
            cashflow_amount,company_code,account_no,action_code,
            cparty_account_no,deal_subtype,product_type,status_code,
            cparty_code,settle,client_code,portfolio_code,dealer_code)
     values(P_DEAL_TYPE,'PREMIUM','PREMIUM',
            P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
            P_PREMIUM_AMOUNT,P_PREMIUM_HCE_AMOUNT,
            P_PREMIUM_DATE,0,decode(P_PREMIUM_ACTION,
            'PAY',(-1) * P_PREMIUM_AMOUNT,P_PREMIUM_AMOUNT),
            P_COMPANY_CODE,P_PREMIUM_ACCOUNT_NO,'SETTLE',
            decode(P_PREMIUM_ACTION,'PAY',P_CPARTY_ACCOUNT_NO),
            P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,P_CPARTY_CODE,
            'N',P_CLIENT_CODE,nvl(P_PORTFOLIO_CODE,'NOTAPPL'),P_DEALER_CODE);

      end if;
      -- Bug 8561305 ends;
   end if;
   --
  if P_STATUS_CODE='CURRENT'
        and (nvl(P_KNOCK_TYPE,'O')='O'
        or (P_KNOCK_TYPE='I' and nvl(P_KNOCK_INSERT_TYPE,'D')='E'))
        and P_INSERT_FOR_CASHFLOW = 'Y' then
   update XTR_DEAL_DATE_AMOUNTS
    set amount             = P_SELL_AMOUNT,
        hce_amount         = P_SELL_HCE_AMOUNT,
        amount_date        = decode(date_type,'VALUE',P_VALUE_DATE,P_EXPIRY_DATE),
        exposure_ref_date  = decode(date_type,'VALUE',P_START_DATE,exposure_ref_date),
        cashflow_amount    = decode(status_code,'CURRENT',
                                                decode(DATE_TYPE,'EXPIRY',0,
                                                decode(P_INSERT_FOR_CASHFLOW,'Y',(-1) * P_SELL_AMOUNT,0))
                                                ,0),
        account_no         = nvl(v_SELL_ACCOUNT_NO, account_no),
        limit_code         = decode(status_code,'EXERCISED',NULL,
                                                decode(DATE_TYPE,'EXPIRY',
                                                decode(P_CURRENCY_SELL,base_ccy,nvl(P_LIMIT_CODE,'NILL'),NULL),NULL)),
        limit_party        = decode(DATE_TYPE,'EXPIRY',decode(P_CURRENCY_SELL,base_ccy,P_CPARTY_CODE,NULL),NULL),
        transaction_date   = P_DEAL_DATE,
        currency           = P_CURRENCY_SELL,
        company_code       = P_COMPANY_CODE,
        deal_subtype       = P_DEAL_SUBTYPE,
        product_type       = P_PRODUCT_TYPE,
        portfolio_code     = P_PORTFOLIO_CODE,
        status_code        = P_STATUS_CODE,
        dealer_code        = P_DEALER_CODE,
        client_code        = P_CLIENT_CODE,
        cparty_code        = P_CPARTY_CODE
    where deal_number = P_DEAL_NO
    and date_type = 'VALUE'
    and deal_type = P_DEAL_TYPE;
   if SQL%NOTFOUND then
     insert into XTR_DEAL_DATE_AMOUNTS
           (deal_type,amount_type,date_type,
            deal_number,transaction_number,transaction_date,currency,
            amount,hce_amount,amount_date,transaction_rate,
            cashflow_amount,company_code,account_no,
            deal_subtype,product_type,status_code,cparty_code,settle,
            client_code,portfolio_code,dealer_code,currency_combination,
            exposure_ref_date)
     values(P_DEAL_TYPE,'FXOBUY','VALUE',
            P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY_BUY,
            P_BUY_AMOUNT,P_BUY_HCE_AMOUNT,
            P_VALUE_DATE,P_TRANSACTION_RATE,P_BUY_AMOUNT,
            P_COMPANY_CODE,P_BUY_ACCOUNT_NO,P_DEAL_SUBTYPE,
            P_PRODUCT_TYPE,P_STATUS_CODE,P_CPARTY_CODE,'N',
            P_CLIENT_CODE,nvl(P_PORTFOLIO_CODE,'NOTAPPL'),
            P_DEALER_CODE,l_combin,P_START_DATE);
     --
     insert into XTR_DEAL_DATE_AMOUNTS
           (deal_type,amount_type,date_type,
            deal_number,transaction_number,transaction_date,currency,
            amount,hce_amount,amount_date,transaction_rate,
            cashflow_amount,company_code,account_no,
            deal_subtype,product_type,status_code,cparty_code,settle,
            client_code,portfolio_code,dealer_code,currency_combination,
            exposure_ref_date)
     values(P_DEAL_TYPE,'FXOSELL','VALUE',
            P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY_SELL,
            P_SELL_AMOUNT,P_SELL_HCE_AMOUNT,
            P_VALUE_DATE,P_TRANSACTION_RATE,(-1) * P_SELL_AMOUNT,
            P_COMPANY_CODE,P_SELL_ACCOUNT_NO,P_DEAL_SUBTYPE,
            P_PRODUCT_TYPE,P_STATUS_CODE,P_CPARTY_CODE,'N',
            P_CLIENT_CODE,nvl(P_PORTFOLIO_CODE,'NOTAPPL'),
            P_DEALER_CODE,l_combin,P_START_DATE);
    end if;
   else
     delete from XTR_DEAL_DATE_AMOUNTS
       where deal_number = P_DEAL_NO
        and  deal_type = P_DEAL_TYPE
        and  date_type = 'VALUE';
   end if;
   --
   if P_STATUS_CODE = 'EXPIRED' then

   -- Bug 8561305 Starts

   if p_deal_type = 'FXO' then
   	if (P_KNOCK_TYPE='I' and P_KNOCK_INSERT_TYPE IS NULL) then
	insert into XTR_DEAL_DATE_AMOUNTS
           (deal_type,amount_type,date_type,
            deal_number,transaction_number,transaction_date,currency,
            amount,hce_amount,amount_date,transaction_rate,
            cashflow_amount,company_code,account_no,action_code,
            cparty_account_no,deal_subtype,product_type,status_code,
            cparty_code,settle,client_code,portfolio_code,dealer_code)
        values(P_DEAL_TYPE,'PREMIUM','PREMIUM',
            P_DEAL_NO,1,sysdate,P_CURRENCY,
            P_PREMIUM_AMOUNT,P_PREMIUM_HCE_AMOUNT,
            P_EXPIRY_DATE,0,decode(P_PREMIUM_ACTION,
            'PAY',(-1) * P_PREMIUM_AMOUNT,P_PREMIUM_AMOUNT),
            P_COMPANY_CODE,P_PREMIUM_ACCOUNT_NO,P_PREMIUM_ACTION,
            decode(P_PREMIUM_ACTION,'PAY',P_CPARTY_ACCOUNT_NO),
            P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,P_CPARTY_CODE,
            'N',P_CLIENT_CODE,nvl(P_PORTFOLIO_CODE,'NOTAPPL'),P_DEALER_CODE);

	else

	delete from XTR_DEAL_DATE_AMOUNTS
	where  deal_number = P_DEAL_NO
	and    deal_type   = P_DEAL_TYPE
	and    date_type = 'VALUE';

	update XTR_DEAL_DATE_AMOUNTS
	set    AMOUNT_DATE      = P_EXPIRY_DATE
	where  DEAL_NUMBER      = P_DEAL_NO
	and    DEAL_TYPE        = P_DEAL_TYPE
	and    DATE_TYPE        = 'EXPIRY';

	end if;

     else
     delete from XTR_DEAL_DATE_AMOUNTS
     where  deal_number = P_DEAL_NO
     and    deal_type   = P_DEAL_TYPE
     and    date_type in ('VALUE','EXPIRY');
     end if;
   --Bug 8561305 ends.

   elsif P_STATUS_CODE = 'EXERCISED' then
     -- AW Bug 894751 American Option
     delete from XTR_DEAL_DATE_AMOUNTS
     where  deal_number = P_DEAL_NO
     and    deal_type   = P_DEAL_TYPE
     and    date_type   = 'VALUE';
     --
     update XTR_DEAL_DATE_AMOUNTS
     set    DATE_TYPE        = 'SETTLE',
            --BUG 8561305 starts
	    AMOUNT_DATE      = p_settle_date,
            --AMOUNT_DATE      = trunc(sysdate),
	    --Bug 8561305 ends
            TRANSACTION_DATE = trunc(sysdate)
     where  DEAL_NUMBER      = P_DEAL_NO
     and    DEAL_TYPE        = P_DEAL_TYPE
     and    DATE_TYPE        = 'EXPIRY';

     --Bug 8561305 starts
     update XTR_DEAL_DATE_AMOUNTS
     set   AMOUNT_DATE      = p_settle_date
     where  DEAL_NUMBER      = P_DEAL_NO
     and    DEAL_TYPE        = P_DEAL_TYPE
     and    DATE_TYPE        = 'SETTLE';
     --Bug 8561305 ends
     --
   end if;
  elsif P_DEAL_TYPE = 'FX' then

/*--------------------------- RVALLAMS FX REARCH ----------------------------- */

    IF ( (P_STATUS_CODE = 'CLOSED' and nvl(P_OLD_STATUS_CODE,'XXX') <> 'CLOSED'
           AND  P_PROFIT_LOSS IS NOT NULL AND P_OLD_PROFIT_LOSS IS NULL
           AND   P_FX_RO_PD_RATE IS NOT NULL AND P_OLD_FX_RO_PD_RATE IS NULL)
      OR
          (P_STATUS_CODE = 'CLOSED' AND P_OLD_STATUS_CODE = 'CLOSED'
           AND  P_FX_M1_DEAL_NO IS NOT NULL AND P_OLD_FX_M1_DEAL_NO IS NOT NULL
	   AND  P_PROFIT_LOSS IS NOT NULL AND P_OLD_PROFIT_LOSS IS NOT NULL
           AND  P_FX_RO_PD_RATE IS NOT NULL AND P_OLD_FX_RO_PD_RATE IS NOT NULL
           AND  P_FX_M1_DEAL_NO <> P_OLD_FX_M1_DEAL_NO
    	  ))

    THEN

    UPDATE XTR_DEAL_DATE_AMOUNTS
    SET AMOUNT               = P_BUY_AMOUNT,
        HCE_AMOUNT           = nvl(P_BUY_HCE_AMOUNT,0),
        STATUS_CODE	     = P_STATUS_CODE,
	AMOUNT_DATE          = P_START_DATE,
        CASHFLOW_AMOUNT      = 0,
	DATE_TYPE	     = 'ROLLPRE',
        ACCOUNT_NO           = nvl(v_BUY_ACCOUNT_NO, account_no ),
        PORTFOLIO_CODE       = P_PORTFOLIO_CODE,
        LIMIT_CODE           = NULL,
        limit_party	     = decode(P_CURRENCY_BUY,base_ccy,P_CPARTY_CODE,NULL),
        currency             = P_CURRENCY_BUY,
        currency_combination = l_combin,
        product_type	     = P_PRODUCT_TYPE,
        company_code         = P_COMPANY_CODE,
        cparty_code          = P_CPARTY_CODE,
        client_code          = P_CLIENT_CODE,
        dealer_code          = P_DEALER_CODE,
        transaction_rate     = P_TRANSACTION_RATE,
        transaction_date     = P_DEAL_DATE
    WHERE   DEAL_NUMBER      = P_DEAL_NO
    AND     DEAL_TYPE        = P_DEAL_TYPE
    AND     DATE_TYPE        = 'VALUE'
    AND     AMOUNT_TYPE      = 'BUY'
    AND     TRANSACTION_NUMBER = 1;

    update XTR_DEAL_DATE_AMOUNTS
    set amount               = P_SELL_AMOUNT,
        hce_amount           = nvl(P_SELL_HCE_AMOUNT,0),
        amount_date          = P_START_DATE,
        cashflow_amount      = 0,
	DATE_TYPE	     = 'ROLLPRE',
        STATUS_CODE          = P_STATUS_CODE,
        account_no           = nvl(v_SELL_ACCOUNT_NO, account_no),
        cparty_account_no    = nvl(v_cparty_account_no, cparty_account_no),
        LIMIT_CODE           = NULL,
        limit_party	     = decode(P_CURRENCY_SELL,base_ccy,P_CPARTY_CODE,NULL),
        currency             = P_CURRENCY_SELL,
        currency_combination = l_combin,
        product_type	     = P_PRODUCT_TYPE,
        portfolio_code       = P_PORTFOLIO_CODE,
        company_code         = P_COMPANY_CODE,
        cparty_code          = P_CPARTY_CODE,
        client_code          = P_CLIENT_CODE,
        dealer_code          = P_DEALER_CODE,
        transaction_rate     = P_TRANSACTION_RATE,
        transaction_date     = P_DEAL_DATE
    where deal_number        = P_DEAL_NO
    and amount_type 	     = 'SELL'
    and deal_type            = P_DEAL_TYPE
    AND date_type            = 'VALUE'
    and transaction_number   = 1;

  update XTR_DEAL_DATE_AMOUNTS
    set amount             = P_SELL_AMOUNT,
        hce_amount         = nvl(P_SELL_HCE_AMOUNT,0),
        status_code        = P_STATUS_CODE,
        amount_date        = P_DEAL_DATE,
        currency	   = P_CURRENCY_SELL,
        account_no         = nvl(v_SELL_ACCOUNT_NO, account_no),
        cparty_account_no  = nvl(v_cparty_account_no, cparty_account_no ),
        product_type       = P_PRODUCT_TYPE,
        portfolio_code     = P_PORTFOLIO_CODE,
        company_code       = P_COMPANY_CODE,
        cparty_code        = P_CPARTY_CODE,
        client_code        = P_CLIENT_CODE,
        dealer_code        = P_DEALER_CODE,
        transaction_rate   = P_TRANSACTION_RATE,
        transaction_date   = P_DEAL_DATE,
        currency_combination = l_combin
    where deal_number = P_DEAL_NO
    and amount_type = 'N/A'
    and deal_type = P_DEAL_TYPE;

/*--------------------------- RVALLAMS FX REARCH ----------------------------- */
   ELSE
   update XTR_DEAL_DATE_AMOUNTS
    set AMOUNT               = P_BUY_AMOUNT,
        HCE_AMOUNT           = nvl(P_BUY_HCE_AMOUNT,0),
        AMOUNT_DATE          = P_VALUE_DATE,
        STATUS_CODE	     = P_STATUS_CODE,
        CASHFLOW_AMOUNT      = P_BUY_AMOUNT,
        ACCOUNT_NO           = nvl(v_BUY_ACCOUNT_NO, account_no),
        PORTFOLIO_CODE       = P_PORTFOLIO_CODE,
        LIMIT_CODE           = decode(P_CURRENCY_BUY,base_ccy,nvl(P_LIMIT_CODE,'NILL'),NULL),
        limit_party	     = decode(P_CURRENCY_BUY,base_ccy,P_CPARTY_CODE,NULL),
        currency             = P_CURRENCY_BUY,
        currency_combination = l_combin,
        product_type	     = P_PRODUCT_TYPE,
        company_code         = P_COMPANY_CODE,
        cparty_code          = P_CPARTY_CODE,
        client_code          = P_CLIENT_CODE,
        dealer_code          = P_DEALER_CODE,
        transaction_rate     = P_TRANSACTION_RATE,
        transaction_date     = P_DEAL_DATE
    where deal_number        = P_DEAL_NO
    and amount_type          = 'BUY'
    and deal_type            = P_DEAL_TYPE
    AND date_type            = 'VALUE'
    and transaction_number = 1;
   --
   update XTR_DEAL_DATE_AMOUNTS
    set amount             = P_SELL_AMOUNT,
        hce_amount         = nvl(P_SELL_HCE_AMOUNT,0),
        amount_date        = P_VALUE_DATE,
        cashflow_amount    = (-1) * P_SELL_AMOUNT,
        STATUS_CODE          = P_STATUS_CODE,
        account_no           = nvl(v_SELL_ACCOUNT_NO, account_no),
        cparty_account_no    = nvl(v_cparty_account_no, cparty_account_no),
        LIMIT_CODE           = decode(P_CURRENCY_SELL,base_ccy,nvl(P_LIMIT_CODE,'NILL'),NULL),
        limit_party	     = decode(P_CURRENCY_SELL,base_ccy,P_CPARTY_CODE,NULL),
        currency             = P_CURRENCY_SELL,
        currency_combination = l_combin,
        product_type	     = P_PRODUCT_TYPE,
        portfolio_code       = P_PORTFOLIO_CODE,
        company_code         = P_COMPANY_CODE,
        cparty_code          = P_CPARTY_CODE,
        client_code          = P_CLIENT_CODE,
        dealer_code          = P_DEALER_CODE,
        transaction_rate     = P_TRANSACTION_RATE,
        transaction_date     = P_DEAL_DATE
    where deal_number        = P_DEAL_NO
    and amount_type          = 'SELL'
    and deal_type            = P_DEAL_TYPE
    AND date_type            = 'VALUE'
    and transaction_number = 1;
   --
   update XTR_DEAL_DATE_AMOUNTS
    set amount             = P_SELL_AMOUNT,
        hce_amount         = nvl(P_SELL_HCE_AMOUNT,0),
        status_code        = P_STATUS_CODE,
        amount_date        = P_DEAL_DATE,
        currency	   = P_CURRENCY_SELL,
        account_no         = nvl(v_SELL_ACCOUNT_NO, account_no),
        cparty_account_no  = nvl(v_cparty_account_no, cparty_account_no),
        product_type       = P_PRODUCT_TYPE,
        portfolio_code     = P_PORTFOLIO_CODE,
        company_code       = P_COMPANY_CODE,
        cparty_code        = P_CPARTY_CODE,
        client_code        = P_CLIENT_CODE,
        dealer_code        = P_DEALER_CODE,
        transaction_rate   = P_TRANSACTION_RATE,
        transaction_date   = P_DEAL_DATE,
        currency_combination = l_combin
    where deal_number = P_DEAL_NO
    and amount_type = 'N/A'
    and deal_type = P_DEAL_TYPE;
END IF;
  --
  elsif P_DEAL_TYPE = 'NI' then
   update XTR_DEAL_DATE_AMOUNTS
    set ACCOUNT_NO        = nvl(v_MATURITY_ACCOUNT_NO, account_no),
	STATUS_CODE       = P_STATUS_CODE,
        CPARTY_ACCOUNT_NO = nvl(v_cparty_account_no, cparty_account_no),
        COMMENCE_DATE     = P_START_DATE,
        CPARTY_CODE       = P_CPARTY_CODE,
        PRODUCT_TYPE      = P_PRODUCT_TYPE,
        PORTFOLIO_CODE    = P_PORTFOLIO_CODE,
        DEAL_SUBTYPE      = P_DEAL_SUBTYPE,
        DEALER_CODE       = P_DEALER_CODE,
        CLIENT_CODE       = P_CLIENT_CODE,
        TRANSACTION_RATE  = P_INTEREST_RATE,
        TRANSACTION_DATE  = P_DEAL_DATE,
        CURRENCY          = P_CURRENCY,
        LIMIT_CODE        = decode(AMOUNT_TYPE,'COMENCE',
                                               decode(P_RISKPARTY_LIMIT_CODE,NULL,'NILL',NULL),
                                               'BAL_FV',
                                               decode(P_RISKPARTY_LIMIT_CODE,NULL,NULL,P_RISKPARTY_LIMIT_CODE),
                                               LIMIT_CODE),
        LIMIT_PARTY       = decode(AMOUNT_TYPE,'COMENCE',
                                               NULL,
                                               'BAL_FV',
                                               decode(P_RISKPARTY_LIMIT_CODE,NULL,NULL,P_RISKPARTY_CODE),
                                               LIMIT_PARTY),
        AMOUNT_DATE       = decode(AMOUNT_TYPE,'COMENCE',P_START_DATE,
                                               'BAL_FV',P_MATURITY_DATE,
                                               'INTL_FV',decode(P_DEAL_SUBTYPE,'SELL',P_START_DATE,
                                                                               'COVER',P_START_DATE,P_MATURITY_DATE),
                                               'INT',P_START_DATE,
                                                     AMOUNT_DATE),
        AMOUNT            = decode(AMOUNT_TYPE,'COMENCE',nvl(P_START_AMOUNT,0),
                                               'BAL_FV',nvl(P_MATURITY_BALANCE_AMOUNT,0),
                                               'INTL_FV', nvl(P_MATURITY_AMOUNT,0),
                                               'INT', nvl(P_INTEREST_AMOUNT,0),
                                                      AMOUNT),
        HCE_AMOUNT        = decode(AMOUNT_TYPE,'COMENCE', nvl(P_START_HCE_AMOUNT,0),
                                               'BAL_FV', nvl(P_MATURITY_BALANCE_HCE_AMOUNT,0),
                                               'INTL_FV', nvl(P_MATURITY_HCE_AMOUNT,0),
                                               'INT', nvl(P_INTEREST_HCE_AMOUNT,0),
                                                      HCE_AMOUNT),
        CASHFLOW_AMOUNT   = decode(AMOUNT_TYPE,'COMENCE',
			    decode(nvl(P_KNOCK_TYPE,'N'),'N',decode(P_DEAL_SUBTYPE,'BUY',-1,'COVER',-1,1)*nvl(P_START_AMOUNT,0),0),
--                                     'BAL_FV', decode(P_DEAL_SUBTYPE,'BUY',1,-1) * nvl(P_MATURITY_BALANCE_AMOUNT,0),
                                       'BAL_FV', decode(P_DEAL_SUBTYPE,'BUY',1,'SELL',0,-1) * nvl(P_MATURITY_BALANCE_AMOUNT,0),
                                               CASHFLOW_AMOUNT)        -- bug  3776211
    where DEAL_NUMBER = P_DEAL_NO
    and DEAL_TYPE = P_DEAL_TYPE;
    /*  AW 9/24/99 Bug 996572
        LIMIT_CODE        = decode(AMOUNT_TYPE,'COMENCE',
                               decode(P_DEAL_SUBTYPE,'SELL',nvl(nvl(P_RISKPARTY_LIMIT_CODE,P_LIMIT_CODE),'NILL'),NULL),
                                               'BAL_FV',
                               decode(P_DEAL_SUBTYPE,'SELL',NULL,nvl(nvl(P_RISKPARTY_LIMIT_CODE,P_LIMIT_CODE),'NILL')),
                                               LIMIT_CODE),
        LIMIT_PARTY       = decode(AMOUNT_TYPE,'COMENCE', decode(P_DEAL_SUBTYPE,'SELL',P_RISKPARTY_CODE,NULL),
                                               'BAL_FV', decode(P_DEAL_SUBTYPE,'SELL',NULL,P_RISKPARTY_CODE),
                                                         LIMIT_PARTY),
    */
   --
   if P_DEAL_SUBTYPE in ('BUY','SHORT','ISSUE') then
      open CHK_NI_BAL_FV;
      fetch CHK_NI_BAL_FV into l_dummy;
      if CHK_NI_BAL_FV%NOTFOUND and nvl(P_MATURITY_BALANCE_AMOUNT,0) <> 0 then
       insert into XTR_DEAL_DATE_AMOUNTS
             (deal_type,amount_type,date_type,
              deal_number,transaction_number,transaction_date,currency,
              amount,hce_amount,amount_date,transaction_rate,
              cashflow_amount,company_code,account_no,
              cparty_account_no,status_code,portfolio_code,dealer_code,
              client_code,deal_subtype,cparty_code,settle,product_type,
              limit_code,limit_party,commence_date,quick_input)
       values('NI','BAL_FV','MATURE',
              P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
              P_MATURITY_BALANCE_AMOUNT,
              P_MATURITY_BALANCE_HCE_AMOUNT,P_MATURITY_DATE,
   --         P_INTEREST_RATE,decode(P_DEAL_SUBTYPE,'BUY',1,-1) *
              P_INTEREST_RATE,decode(P_DEAL_SUBTYPE,'BUY',1,'SELL',0,-1) *
              P_MATURITY_BALANCE_AMOUNT,P_COMPANY_CODE,
              P_MATURITY_ACCOUNT_NO,P_CPARTY_ACCOUNT_NO,
              P_STATUS_CODE,P_PORTFOLIO_CODE,P_DEALER_CODE,
              P_CLIENT_CODE,P_DEAL_SUBTYPE,P_CPARTY_CODE,'N',
              P_PRODUCT_TYPE,decode(P_DEAL_SUBTYPE,'SELL',NULL,nvl(nvl(P_RISKPARTY_LIMIT_CODE,P_LIMIT_CODE),'NILL')),
              decode(P_DEAL_SUBTYPE,'SELL',NULL,P_RISKPARTY_CODE),P_START_DATE,P_QUICK_INPUT);
      end if;
      close CHK_NI_BAL_FV;
   end if;
   --

------------
-- NEW NI --
------------
/* Not required.
---- 06/08/99 Apply PL to dda for sale deal. refer to bug 904365
 if P_DEAL_SUBTYPE='SELL' then
   update XTR_DEAL_DATE_AMOUNTS
    set AMOUNT_DATE     = P_START_DATE,
        AMOUNT          = abs(nvl(P_NI_PROFIT_LOSS,0)),
        HCE_AMOUNT      = abs(nvl(round(P_NI_PROFIT_LOSS/hce_rate,2),0)),
        ACTION_CODE     = decode(sign(nvl(P_NI_PROFIT_LOSS,0)),-1,'LOSS','PROFIT'),
        CASHFLOW_AMOUNT = 0
    where DEAL_NUMBER = P_DEAL_NO
    and AMOUNT_TYPE = 'REAL'
    and DATE_TYPE ='REVAL';
   --
   if SQL%NOTFOUND and nvl(P_NI_PROFIT_LOSS,0) <> 0 then
    -- Set the profit and loss info into the database...
    insert into XTR_DEAL_DATE_AMOUNTS
          (deal_type,amount_type,date_type,
           deal_number,transaction_number,transaction_date,currency,
           amount,hce_amount,amount_date,transaction_rate,
           cashflow_amount,company_code,status_code,dealer_code,
           deal_subtype,product_type,settle,cparty_code,client_code,
           portfolio_code,action_code)
    values('NI','REAL','REVAL',
           P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
           abs(nvl(P_NI_PROFIT_LOSS,0)),abs(nvl(round(P_NI_PROFIT_LOSS/hce_rate,2),0)),
           P_START_DATE,P_INTEREST_RATE,0,P_COMPANY_CODE,
           P_STATUS_CODE,P_DEALER_CODE,P_DEAL_SUBTYPE,
           P_PRODUCT_TYPE,'N',P_CPARTY_CODE,P_CLIENT_CODE,
           nvl(P_PORTFOLIO_CODE,'NOTAPPL'),decode(sign(nvl(P_NI_PROFIT_LOSS,0)),-1,'LOSS','PROFIT'));
   end if;
 end if;
*/
 --
 elsif P_DEAL_TYPE = 'BOND' then
  update XTR_DEAL_DATE_AMOUNTS
   set amount             = P_START_AMOUNT,
       hce_amount         = P_START_HCE_AMOUNT,
       cashflow_amount    = decode(P_DEAL_SUBTYPE,'BUY',1,-1) * P_START_AMOUNT,
       transaction_rate   = P_INTEREST_RATE,
       transaction_date   = P_DEAL_DATE,
       account_no         = nvl(v_MATURITY_ACCOUNT_NO, account_no ),
       cparty_account_no  = nvl(v_cparty_account_no, cparty_account_no)
   where deal_number = P_DEAL_NO
   and amount_date >= L_SYSDATE
   and amount_type = 'COMENCE'
   and date_type = 'COMENCE'
   and deal_type = P_DEAL_TYPE;
  --
  update XTR_DEAL_DATE_AMOUNTS
   set amount             = P_MATURITY_AMOUNT,
       hce_amount         = P_MATURITY_HCE_AMOUNT,
       cashflow_amount    = decode(P_DEAL_SUBTYPE,'BUY',1,-1) * P_MATURITY_AMOUNT,
       transaction_rate   = P_INTEREST_RATE,
       transaction_date   = P_DEAL_DATE,
       account_no         = nvl(v_MATURITY_ACCOUNT_NO, account_no),
       cparty_account_no  = nvl(v_cparty_account_no, cparty_account_no),
       limit_code         = nvl(P_LIMIT_CODE,'NILL')
   where deal_number = P_DEAL_NO
   and amount_type = 'INTL_FV'
   and date_type = 'MATURE'
   and deal_type = P_DEAL_TYPE
   and amount_date >= L_SYSDATE;
  --
  if P_INT_VALUE is not null then
   update XTR_DEAL_DATE_AMOUNTS
    set amount             = P_INT_VALUE,
        hce_amount         = round(P_INT_VALUE/hce_rate,round_fac),
        transaction_date   = P_DEAL_DATE,
        transaction_rate   = P_INTEREST_RATE
    where deal_number = P_DEAL_NO
    and amount_type = 'INT'
    and date_type = 'COMENCE'
    and deal_type = P_DEAL_TYPE
    and amount_date >= L_SYSDATE;
  end if;
  --
  if nvl(P_PREM_VALUE,0) <> 0 then
   update XTR_DEAL_DATE_AMOUNTS
    set amount             = abs(P_PREM_VALUE),
        hce_amount         = abs(round(P_PREM_VALUE/hce_rate,round_fac)),
        transaction_date   = P_DEAL_DATE,
        transaction_rate   = P_INTEREST_RATE
    where deal_number = P_DEAL_NO
    and amount_type IN('DISC','PREMIUM')
    and date_type = 'COMENCE'
    and deal_type = P_DEAL_TYPE
    and amount_date >= L_SYSDATE;
  end if;
 --
 elsif P_DEAL_TYPE = 'IRO' then
  update XTR_DEAL_DATE_AMOUNTS
   set amount           = nvl(nvl(P_FACE_VALUE_AMOUNT,P_MATURITY_AMOUNT),0),
       hce_amount       = nvl(nvl(P_FACE_VALUE_HCE_AMOUNT,P_MATURITY_HCE_AMOUNT),0),
       amount_date      = P_EXPIRY_DATE,
       transaction_rate = P_INTEREST_RATE,
       transaction_date = P_DEAL_DATE,
       currency         = P_CURRENCY,
       company_code     = P_COMPANY_CODE,
       deal_subtype     = P_DEAL_SUBTYPE,
       product_type     = P_PRODUCT_TYPE,
       status_code      = P_STATUS_CODE,
       dealer_code      = P_DEALER_CODE,
       client_code      = P_CLIENT_CODE,
       cparty_code      = P_CPARTY_CODE,
       portfolio_code   = nvl(P_PORTFOLIO_CODE,'NOTAPPL')
   where deal_number = P_DEAL_NO
   and deal_type = 'IRO'
   and date_type = 'EXPIRY';
 --
  update XTR_DEAL_DATE_AMOUNTS
   set amount           = nvl(P_PREMIUM_AMOUNT,0),
       hce_amount       = nvl(P_PREMIUM_HCE_AMOUNT,0),
       amount_date      = nvl(P_PREMIUM_DATE,P_START_DATE),
       transaction_date = P_DEAL_DATE,
       currency         = P_CURRENCY,
       cashflow_amount  = decode(P_PREMIUM_ACTION,'PAY',-(1),1) * nvl(P_PREMIUM_AMOUNT,0),
       company_code     = P_COMPANY_CODE,
       account_no       = nvl(v_PREMIUM_ACCOUNT_NO, account_no),
       cparty_account_no = decode(P_PREMIUM_ACTION,'PAY',nvl(v_cparty_account_no, cparty_account_no),''),
       deal_subtype     = P_DEAL_SUBTYPE,
       product_type     = P_PRODUCT_TYPE,
       status_code      = P_STATUS_CODE,
       dealer_code      = P_DEALER_CODE,
       client_code      = P_CLIENT_CODE,
       cparty_code      = P_CPARTY_CODE,
       action_code      = P_PREMIUM_ACTION,
       portfolio_code   = nvl(P_PORTFOLIO_CODE,'NOTAPPL')
   where deal_number = P_DEAL_NO
   and deal_type = 'IRO'
   and date_type = 'PREMIUM';
  --
  update XTR_DEAL_DATE_AMOUNTS
   set amount_date      = P_DEAL_DATE,
       transaction_date = P_DEAL_DATE,
       currency         = P_CURRENCY,
       company_code     = P_COMPANY_CODE,
       deal_subtype     = P_DEAL_SUBTYPE,
       product_type     = P_PRODUCT_TYPE,
       status_code      = P_STATUS_CODE,
       dealer_code      = P_DEALER_CODE,
       client_code      = P_CLIENT_CODE,
       cparty_code      = P_CPARTY_CODE,
       portfolio_code   = nvl(P_PORTFOLIO_CODE,'NOTAPPL')
   where deal_number = P_DEAL_NO
   and deal_type = 'IRO'
   and date_type = 'DEALT';
  --
  update XTR_DEAL_DATE_AMOUNTS
   set amount_date      = P_MATURITY_DATE,
       transaction_date = P_DEAL_DATE,
       currency         = P_CURRENCY,
       company_code     = P_COMPANY_CODE,
       deal_subtype     = P_DEAL_SUBTYPE,
       product_type     = P_PRODUCT_TYPE,
       status_code      = P_STATUS_CODE,
       dealer_code      = P_DEALER_CODE,
       client_code      = P_CLIENT_CODE,
       cparty_code      = P_CPARTY_CODE,
       portfolio_code   = nvl(P_PORTFOLIO_CODE,'NOTAPPL')
   where deal_number = P_DEAL_NO
   and deal_type = 'IRO'
   and date_type = 'MATURE';
  --
  update XTR_DEAL_DATE_AMOUNTS
   set amount_date      = P_START_DATE,
       transaction_date = P_DEAL_DATE,
       currency         = P_CURRENCY,
       company_code     = P_COMPANY_CODE,
       deal_subtype     = P_DEAL_SUBTYPE,
       product_type     = P_PRODUCT_TYPE,
       status_code      = P_STATUS_CODE,
       dealer_code      = P_DEALER_CODE,
       client_code      = P_CLIENT_CODE,
       cparty_code      = P_CPARTY_CODE,
       portfolio_code   = nvl(P_PORTFOLIO_CODE,'NOTAPPL')
   where deal_number = P_DEAL_NO
   and deal_type = 'IRO'
   and date_type = 'COMENCE';
  --
  if P_STATUS_CODE = 'EXERCISED' then

   --Bug 3060946 Removed call to xtr_fps2_p.standing_settlement

   open C_LIMIT_WEIGHTING(P_DEAL_TYPE, P_DEAL_SUBTYPE);
   fetch C_LIMIT_WEIGHTING into v_weighting;
   close C_LIMIT_WEIGHTING;
   update XTR_DEAL_DATE_AMOUNTS
    set amount           = (100/v_weighting*nvl(P_SETTLE_AMOUNT,0)),
        hce_amount       = (100/v_weighting*nvl(P_SETTLE_HCE_AMOUNT,0)),
        amount_date      = P_SETTLE_DATE,
        transaction_date = P_DEAL_DATE,
        currency         = P_CURRENCY,
        company_code     = P_COMPANY_CODE,
        deal_subtype     = P_DEAL_SUBTYPE,
        product_type     = P_PRODUCT_TYPE,
        status_code      = P_STATUS_CODE,
        dealer_code      = P_DEALER_CODE,
        client_code      = P_CLIENT_CODE,
        cparty_code      = P_CPARTY_CODE,
        portfolio_code   = nvl(P_PORTFOLIO_CODE,'NOTAPPL'),
        limit_code       = nvl(P_LIMIT_CODE,'NILL'),
        limit_party      = P_CPARTY_CODE
    where deal_number = P_DEAL_NO
    and deal_type = 'IRO'
    and date_type = 'LIMIT';
 --
 -- AW Bug 894751
    delete from XTR_DEAL_DATE_AMOUNTS
    where deal_number = P_DEAL_NO
    and deal_type = 'IRO'
    and date_type = 'EXPIRY';
 --
   update XTR_DEAL_DATE_AMOUNTS
    set amount           = nvl(P_SETTLE_AMOUNT,0),
        hce_amount       = nvl(P_SETTLE_HCE_AMOUNT,0),
        amount_date      = P_SETTLE_DATE,
        cashflow_amount  = decode(P_SETTLE_ACTION,'PAY',(-1),1) * nvl(P_SETTLE_AMOUNT,0),
        transaction_rate = P_SETTLE_RATE,
        account_no         = nvl(v_SETTLE_ACCOUNT_NO, account_no),
        transaction_date   = P_DEAL_DATE,
        currency           = P_CURRENCY,
        company_code       = P_COMPANY_CODE,
        action_code        = P_SETTLE_ACTION,
        --Bug 3060946 Removed assignment to cparty_account_no
        deal_subtype       = P_DEAL_SUBTYPE,
        product_type       = P_PRODUCT_TYPE,
        status_code        = P_STATUS_CODE,
        dealer_code        = P_DEALER_CODE,
        client_code        = P_CLIENT_CODE,
        cparty_code        = P_CPARTY_CODE,
        portfolio_code     = nvl(P_PORTFOLIO_CODE,'NOTAPPL')
    where deal_number = P_DEAL_NO
    and deal_type = 'IRO'
    and date_type = 'SETTLE';
   --
   --Bug 3060946 Removed 'Insert into XTR_DEAL_DATE_AMOUNTS' statement
   --
  end if;
 --
 elsif P_DEAL_TYPE = 'BDO' then
  update XTR_DEAL_DATE_AMOUNTS
   set amount           = nvl(nvl(P_FACE_VALUE_AMOUNT,P_MATURITY_AMOUNT),0),
       hce_amount       = nvl(nvl(P_FACE_VALUE_HCE_AMOUNT,P_MATURITY_HCE_AMOUNT),0),
       amount_date      = P_EXPIRY_DATE,
       transaction_rate = P_INTEREST_RATE,
       transaction_date = P_DEAL_DATE,
       currency         = P_CURRENCY,
       company_code     = P_COMPANY_CODE,
       deal_subtype     = P_DEAL_SUBTYPE,
       product_type     = P_PRODUCT_TYPE,
       status_code      = P_STATUS_CODE,
       dealer_code      = P_DEALER_CODE,
       client_code      = P_CLIENT_CODE,
       cparty_code      = P_CPARTY_CODE,
       portfolio_code   = nvl(P_PORTFOLIO_CODE,'NOTAPPL')
   where deal_number = P_DEAL_NO
   and deal_type = 'BDO'
   and date_type = 'EXPIRY';
  --
  update XTR_DEAL_DATE_AMOUNTS
   set amount           = nvl(P_PREMIUM_AMOUNT,0),
       hce_amount       = nvl(P_PREMIUM_HCE_AMOUNT,0),
       amount_date      = nvl(P_PREMIUM_DATE,P_START_DATE),
       transaction_date = P_DEAL_DATE,
       currency         = P_CURRENCY,
       cashflow_amount  = decode(P_PREMIUM_ACTION,'PAY',-(1),1) * nvl(P_PREMIUM_AMOUNT,0),
       company_code     = P_COMPANY_CODE,
       account_no       = nvl(v_PREMIUM_ACCOUNT_NO, account_no),
       cparty_account_no = decode(P_PREMIUM_ACTION,'PAY',nvl(v_cparty_account_no, cparty_account_no),''),
       deal_subtype     = P_DEAL_SUBTYPE,
       product_type     = P_PRODUCT_TYPE,
       status_code      = P_STATUS_CODE,
       dealer_code      = P_DEALER_CODE,
       client_code      = P_CLIENT_CODE,
       cparty_code      = P_CPARTY_CODE,
       action_code      = P_PREMIUM_ACTION,
       portfolio_code   = nvl(P_PORTFOLIO_CODE,'NOTAPPL')
   where deal_number = P_DEAL_NO
   and deal_type = 'BDO'
   and date_type = 'PREMIUM';
  --
  update XTR_DEAL_DATE_AMOUNTS
   set amount_date      = P_DEAL_DATE,
       transaction_date = P_DEAL_DATE,
       currency         = P_CURRENCY,
       company_code     = P_COMPANY_CODE,
       deal_subtype     = P_DEAL_SUBTYPE,
       product_type     = P_PRODUCT_TYPE,
       status_code      = P_STATUS_CODE,
       dealer_code      = P_DEALER_CODE,
       client_code      = P_CLIENT_CODE,
       cparty_code      = P_CPARTY_CODE,
       portfolio_code   = nvl(P_PORTFOLIO_CODE,'NOTAPPL')
   where deal_number = P_DEAL_NO
   and deal_type = 'BDO'
   and date_type = 'DEALT';
  --
  update XTR_DEAL_DATE_AMOUNTS
   set amount_date      = P_MATURITY_DATE,
       transaction_date = P_DEAL_DATE,
       currency         = P_CURRENCY,
       company_code     = P_COMPANY_CODE,
       deal_subtype     = P_DEAL_SUBTYPE,
       product_type     = P_PRODUCT_TYPE,
       status_code      = P_STATUS_CODE,
       dealer_code      = P_DEALER_CODE,
       client_code      = P_CLIENT_CODE,
       cparty_code      = P_CPARTY_CODE,
       portfolio_code   = nvl(P_PORTFOLIO_CODE,'NOTAPPL')
   where deal_number = P_DEAL_NO
   and deal_type = 'BDO'
   and date_type = 'MATURE';
  --
  update XTR_DEAL_DATE_AMOUNTS
   set amount_date      = P_START_DATE,
       transaction_date = P_DEAL_DATE,
       currency         = P_CURRENCY,
       company_code     = P_COMPANY_CODE,
       deal_subtype     = P_DEAL_SUBTYPE,
       product_type     = P_PRODUCT_TYPE,
       status_code      = P_STATUS_CODE,
       dealer_code      = P_DEALER_CODE,
       client_code      = P_CLIENT_CODE,
       cparty_code      = P_CPARTY_CODE,
       portfolio_code   = nvl(P_PORTFOLIO_CODE,'NOTAPPL')
   where deal_number = P_DEAL_NO
   and deal_type = 'BDO'
   and date_type = 'COMENCE';
  --
  if P_STATUS_CODE = 'EXERCISED' then
   xtr_fps2_p.standing_settlements(P_CPARTY_CODE,P_CURRENCY,'BDO',
                                   P_DEAL_SUBTYPE,P_PRODUCT_TYPE,'SETTLE',
                                   v_settle_ref,v_settle_ac);
   -- AW Bug 894751
   delete from XTR_DEAL_DATE_AMOUNTS
   where deal_number = P_DEAL_NO
   and deal_type = 'BDO'
   and date_type = 'EXPIRY';
   --
   if P_EXERCISE_PRICE is not null then
    open C_LIMIT_WEIGHTING(P_DEAL_TYPE, P_DEAL_SUBTYPE);
    fetch C_LIMIT_WEIGHTING into v_weighting;
    close C_LIMIT_WEIGHTING;
    update XTR_DEAL_DATE_AMOUNTS
     set amount           = (100/v_weighting*nvl(P_SETTLE_AMOUNT,0)),
         hce_amount       = (100/v_weighting*nvl(P_SETTLE_HCE_AMOUNT,0)),
         amount_date      = P_SETTLE_DATE,
         transaction_date = P_DEAL_DATE,
         currency         = P_CURRENCY,
         company_code     = P_COMPANY_CODE,
         deal_subtype     = P_DEAL_SUBTYPE,
         product_type     = P_PRODUCT_TYPE,
         status_code      = P_STATUS_CODE,
         dealer_code      = P_DEALER_CODE,
         client_code      = P_CLIENT_CODE,
         cparty_code      = P_CPARTY_CODE,
         portfolio_code   = nvl(P_PORTFOLIO_CODE,'NOTAPPL'),
         limit_code       = nvl(P_LIMIT_CODE,'NILL'),
         limit_party      = P_CPARTY_CODE
     where deal_number = P_DEAL_NO
     and deal_type = 'BDO'
     and date_type = 'LIMIT';
   --
    update XTR_DEAL_DATE_AMOUNTS
    set amount           = nvl(P_SETTLE_AMOUNT,0),
        hce_amount       = nvl(P_SETTLE_HCE_AMOUNT,0),
        amount_date      = P_SETTLE_DATE,
        cashflow_amount  = decode(P_SETTLE_ACTION,'PAY',(-1),1) * nvl(P_SETTLE_AMOUNT,0),
        transaction_rate = P_SETTLE_RATE,
        account_no         = nvl(v_SETTLE_ACCOUNT_NO, account_no),
        transaction_date   = P_DEAL_DATE,
        currency           = P_CURRENCY,
        company_code       = P_COMPANY_CODE,
        action_code        = P_SETTLE_ACTION,
        cparty_account_no  = nvl(v_settle_ac,nvl(v_cparty_account_no, cparty_account_no)), --Bug 2855642
        deal_subtype       = P_DEAL_SUBTYPE,
        product_type       = P_PRODUCT_TYPE,
        status_code        = P_STATUS_CODE,
        dealer_code        = P_DEALER_CODE,
        client_code        = P_CLIENT_CODE,
        cparty_code        = P_CPARTY_CODE,
        portfolio_code     = nvl(P_PORTFOLIO_CODE,'NOTAPPL')
    where deal_number = P_DEAL_NO
    and deal_type = 'BDO'
    and date_type = 'SETTLE';
   --
    if SQL%NOTFOUND and P_SETTLE_DATE is NOT NULL then
     insert into XTR_DEAL_DATE_AMOUNTS
          (deal_type,amount_type,date_type,
           deal_number,transaction_number,transaction_date,currency,
           amount,hce_amount,amount_date,transaction_rate,
           cashflow_amount,company_code,account_no,action_code,
           cparty_account_no,deal_subtype,product_type,status_code,
           dealer_code,client_code,cparty_code,settle,portfolio_code)
     values('BDO','SETTLE','SETTLE',
           P_DEAL_NO,1,P_DEAL_DATE,P_CURRENCY,
           nvl(P_SETTLE_AMOUNT,0),nvl(P_SETTLE_HCE_AMOUNT,0),
           nvl(P_SETTLE_DATE,P_START_DATE),P_SETTLE_RATE,
           decode(P_SETTLE_ACTION,'PAY',-(1),1) * nvl(P_SETTLE_AMOUNT,0),
           P_COMPANY_CODE,P_SETTLE_ACCOUNT_NO,P_SETTLE_ACTION,
           nvl(v_settle_ac,P_CPARTY_ACCOUNT_NO), --Bug 2855642
           P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,
           P_DEALER_CODE,P_CLIENT_CODE,P_CPARTY_CODE,'N',nvl(P_PORTFOLIO_CODE,'NOTAPPL'));
    end if;
   else -- AW Bug 894751
        -- JT bug 1312363 while validating after exercise the insert was giving
        -- duplicate row error a select is added to check whether the row is already
        -- existing or not. if no data found then insert the record

      open CHK_BDO_SETTLE_ROWS;
      fetch CHK_BDO_SETTLE_ROWS into l_dummy;

      if CHK_BDO_SETTLE_ROWS%NOTFOUND then
          insert into XTR_DEAL_DATE_AMOUNTS
                (deal_type,amount_type,date_type,
                 deal_number,transaction_number,transaction_date,currency,
                 amount,hce_amount,amount_date,transaction_rate,
                 cashflow_amount,company_code,deal_subtype,product_type,
                 status_code,dealer_code,client_code,cparty_code,settle,
                 portfolio_code,QUICK_INPUT)
          values('BDO','N/A','SETTLE',
                 P_DEAL_NO,1,trunc(sysdate),P_CURRENCY,
                 0,0,trunc(sysdate),0,0,P_COMPANY_CODE,P_DEAL_SUBTYPE,
                 P_PRODUCT_TYPE,P_STATUS_CODE,P_DEALER_CODE,
                 P_CLIENT_CODE,P_CPARTY_CODE,'N',
                 nvl(P_PORTFOLIO_CODE,'NOTAPPL'),P_QUICK_INPUT);
      end if;
      close CHK_BDO_SETTLE_ROWS;
   end if;
   --
  end if;
 --
 elsif P_DEAL_TYPE = 'FUT' then
  update XTR_DEAL_DATE_AMOUNTS
   set amount             = P_START_AMOUNT,
       hce_amount         = P_START_HCE_AMOUNT,
       transaction_rate   = nvl(P_TRANSACTION_RATE,P_CONTRACT_RATE),
       amount_date        = P_EXPIRY_DATE,
       limit_code         = nvl(P_LIMIT_CODE,'NILL'),
       transaction_date   = P_DEAL_DATE,
       currency           = P_CURRENCY_BUY,
       company_code       = P_COMPANY_CODE,
       deal_subtype       = P_DEAL_SUBTYPE,
       product_type       = P_PRODUCT_TYPE,
       status_code        = P_STATUS_CODE,
       dealer_code        = P_DEALER_CODE,
       client_code        = P_CLIENT_CODE,
       cparty_code        = P_CPARTY_CODE,
       portfolio_code     = nvl(P_PORTFOLIO_CODE,'NOTAPPL'),
       limit_party        = P_CPARTY_CODE,
       contract_code      = P_BOND_ISSUE
   where deal_number = P_DEAL_NO
   and deal_type = 'FUT'
   and amount_type = 'FACEVAL';
  --
  update XTR_DEAL_DATE_AMOUNTS
   set amount             = nvl(P_PREMIUM_AMOUNT,0)+nvl(P_CONTRACT_COMMISSION,0)+nvl(P_CONTRACT_FEES,0),
       hce_amount         = nvl(P_PREMIUM_HCE_AMOUNT,0),
       cashflow_amount    = -(1) * (nvl(P_PREMIUM_AMOUNT,0)+nvl(P_CONTRACT_COMMISSION,0)+nvl(P_CONTRACT_FEES,0)),
       amount_date        = P_PREMIUM_DATE,
       transaction_date   = P_DEAL_DATE,
       currency           = P_PREMIUM_CURRENCY,
       company_code       = P_COMPANY_CODE,
       deal_subtype       = P_DEAL_SUBTYPE,
       account_no		  = nvl(v_SETTLE_ACCOUNT_NO, account_no),
       cparty_account_no  = nvl(v_cparty_account_no, cparty_account_no),
       product_type       = P_PRODUCT_TYPE,
       status_code        = P_STATUS_CODE,
       dealer_code        = P_DEALER_CODE,
       client_code        = P_CLIENT_CODE,
       cparty_code        = P_CPARTY_CODE,
       portfolio_code     = nvl(P_PORTFOLIO_CODE,'NOTAPPL'),
       contract_code      = P_BOND_ISSUE
   where deal_number = P_DEAL_NO
   and deal_type = 'FUT'
   and amount_type = 'PREMIUM';
  --
  if SQL%NOTFOUND and nvl(P_PREMIUM_AMOUNT,0)+nvl(P_CONTRACT_COMMISSION,0)+nvl(P_CONTRACT_FEES,0) > 0 then
   -- Settlement Amount
   insert into XTR_DEAL_DATE_AMOUNTS
         (deal_type,amount_type,date_type,
          deal_number,transaction_number,transaction_date,currency,
          amount,hce_amount,amount_date,transaction_rate,
          cashflow_amount,company_code,account_no,action_code,
          cparty_account_no,deal_subtype,product_type,status_code,
          dealer_code,client_code,cparty_code,settle,
          portfolio_code,contract_code)
   values('FUT','PREMIUM','SETTLE',
          P_DEAL_NO,1,P_DEAL_DATE,P_PREMIUM_CURRENCY,
          nvl(P_PREMIUM_AMOUNT,0)+nvl(P_CONTRACT_COMMISSION,0)+nvl(P_CONTRACT_FEES,0) ,nvl(P_PREMIUM_HCE_AMOUNT,0),
          P_PREMIUM_DATE,0,-(1) * (nvl(P_PREMIUM_AMOUNT,0)+nvl(P_CONTRACT_COMMISSION,0)+nvl(P_CONTRACT_FEES,0)),
          P_COMPANY_CODE,P_SETTLE_ACCOUNT_NO,'PAY',P_CPARTY_ACCOUNT_NO,P_DEAL_SUBTYPE,P_PRODUCT_TYPE,
          'CURRENT',P_DEALER_CODE,P_CLIENT_CODE,
          P_CPARTY_CODE,'N',nvl(P_PORTFOLIO_CODE,'NOTAPPL'),P_BOND_ISSUE);
  end if;
  --
  update XTR_DEAL_DATE_AMOUNTS
   set amount_date        = P_DEAL_DATE,
       transaction_date   = P_DEAL_DATE,
       currency           = P_PREMIUM_CURRENCY,
       company_code       = P_COMPANY_CODE,
       deal_subtype       = P_DEAL_SUBTYPE,
       product_type       = P_PRODUCT_TYPE,
       status_code        = P_STATUS_CODE,
       dealer_code        = P_DEALER_CODE,
       client_code        = P_CLIENT_CODE,
       cparty_code        = P_CPARTY_CODE,
       portfolio_code     = nvl(P_PORTFOLIO_CODE,'NOTAPPL')
   where deal_number = P_DEAL_NO
   and deal_type = 'FUT'
   and amount_type = 'DEALT';
  --
  if P_SETTLE_ACTION is NOT NULL then
   update XTR_DEAL_DATE_AMOUNTS
    set amount             = P_SETTLE_AMOUNT,
        hce_amount         = P_SETTLE_HCE_AMOUNT,
        amount_date        = P_SETTLE_DATE,
        cashflow_amount    =
        decode(P_SETTLE_ACTION,'PAY',(-1),1) * P_SETTLE_AMOUNT,
        transaction_rate   = nvl(P_BASE_RATE,P_SETTLE_RATE),
        account_no         = nvl(v_SETTLE_ACCOUNT_NO, account_no),
        cparty_account_no  = decode(P_SETTLE_ACTION,'PAY',nvl(v_cparty_account_no, cparty_account_no),NULL),
        action_code	   = P_SETTLE_ACTION,
        currency           = P_PREMIUM_CURRENCY,
        company_code       = P_COMPANY_CODE,
        deal_subtype       = P_DEAL_SUBTYPE,
        product_type       = P_PRODUCT_TYPE,
        status_code        = P_STATUS_CODE,
        dealer_code        = P_DEALER_CODE,
        client_code        = P_CLIENT_CODE,
        cparty_code        = P_CPARTY_CODE,
        portfolio_code     = nvl(P_PORTFOLIO_CODE,'NOTAPPL'),
	  contract_code      = P_BOND_ISSUE
    where deal_number = P_DEAL_NO
    and deal_type = 'FUT'
    and amount_type = 'SETTLE';
    if SQL%NOTFOUND then
     insert into XTR_DEAL_DATE_AMOUNTS
           (deal_type,amount_type,date_type,
            deal_number,transaction_number,transaction_date,currency,
            amount,hce_amount,amount_date,transaction_rate,
            cashflow_amount,company_code,account_no,action_code,
            cparty_account_no,deal_subtype,product_type,status_code,
            dealer_code,client_code,cparty_code,settle,
            portfolio_code,contract_code)
     values('FUT','SETTLE','SETTLE',
            P_DEAL_NO,1,P_DEAL_DATE,P_PREMIUM_CURRENCY,
            nvl(P_SETTLE_AMOUNT,0),nvl(P_SETTLE_HCE_AMOUNT,0),
            P_SETTLE_DATE,
            nvl(P_BASE_RATE,P_SETTLE_RATE),decode(P_SETTLE_ACTION,'PAY',-(1),1) * nvl(P_SETTLE_AMOUNT,0),
            P_COMPANY_CODE,P_SETTLE_ACCOUNT_NO,P_SETTLE_ACTION,
            decode(P_SETTLE_ACTION,'PAY',P_CPARTY_ACCOUNT_NO,NULL),
            P_DEAL_SUBTYPE,P_PRODUCT_TYPE,P_STATUS_CODE,
            P_DEALER_CODE,P_CLIENT_CODE,P_CPARTY_CODE,'N',
            nvl(P_PORTFOLIO_CODE,'NOTAPPL'),P_BOND_ISSUE);
    end if;
    --
    update XTR_DEAL_DATE_AMOUNTS
     set limit_code = NULL
     where deal_number = P_DEAL_NO
     and limit_code is NOT NULL;
   end if;
  --
  elsif P_DEAL_TYPE = 'SWPTN' then
   update XTR_DEAL_DATE_AMOUNTS
    set amount_date      = decode(date_type,'DEALT',P_DEAL_DATE,
                                  'COMENCE',P_START_DATE,
                                  'MATURE',P_MATURITY_DATE,amount_date),
        amount           = decode(amount_type,'N/A',0,
                                  'FACEVAL',P_FACE_VALUE_AMOUNT,amount),
        hce_amount       = decode(amount_type,'N/A',0,
                                  'FACEVAL',P_FACE_VALUE_HCE_AMOUNT,hce_amount),
        transaction_date = P_DEAL_DATE,
        transaction_rate = P_INTEREST_RATE,
        company_code     = P_COMPANY_CODE,
        deal_subtype     = P_DEAL_SUBTYPE,
        product_type     = P_PRODUCT_TYPE,
        status_code      = P_STATUS_CODE,
        dealer_code      = P_DEALER_CODE,
        client_code      = P_CLIENT_CODE,
        cparty_code      = P_CPARTY_CODE,
        portfolio_code   = nvl(P_PORTFOLIO_CODE,'NOTAPPL')
    where deal_number = P_DEAL_NO
    and deal_type = 'SWPTN'
    and date_type not in ('EXPIRY','PREMIUM','SETTLE');
   --
   update XTR_DEAL_DATE_AMOUNTS
    set amount_date      = nvl(P_PREMIUM_DATE,P_START_DATE),
        amount           = nvl(P_PREMIUM_AMOUNT,0),
        hce_amount       = nvl(P_PREMIUM_HCE_AMOUNT,0),
        cashflow_amount  = decode(P_PREMIUM_ACTION,'PAY',-(1),1)*nvl(P_PREMIUM_AMOUNT,0),
        currency         = P_CURRENCY_BUY,
        transaction_date = P_DEAL_DATE,
        transaction_rate = P_INTEREST_RATE,
        company_code     = P_COMPANY_CODE,
        deal_subtype     = P_DEAL_SUBTYPE,
        product_type     = P_PRODUCT_TYPE,
        status_code      = P_STATUS_CODE,
        dealer_code      = P_DEALER_CODE,
        client_code      = P_CLIENT_CODE,
        cparty_code      = P_CPARTY_CODE,
        action_code      = P_PREMIUM_ACTION,
        account_no       = nvl(v_PREMIUM_ACCOUNT_NO, account_no),
        cparty_account_no= decode(P_PREMIUM_ACTION,'PAY',nvl(v_cparty_account_no, cparty_account_no),''),
        portfolio_code   = nvl(P_PORTFOLIO_CODE,'NOTAPPL')
    where deal_number = P_DEAL_NO
    and deal_type = 'SWPTN'
    and date_type = 'PREMIUM';
   --
   update XTR_DEAL_DATE_AMOUNTS
    set amount           = P_FACE_VALUE_AMOUNT,
        hce_amount       = P_FACE_VALUE_HCE_AMOUNT,
        amount_date      = P_EXPIRY_DATE,
        transaction_rate = P_INTEREST_RATE,
        status_code      = P_STATUS_CODE,
        transaction_date = P_DEAL_DATE,
        currency         = P_CURRENCY,
        company_code     = P_COMPANY_CODE,
        deal_subtype     = P_DEAL_SUBTYPE,
        product_type     = P_PRODUCT_TYPE,
        dealer_code      = P_DEALER_CODE,
        client_code      = P_CLIENT_CODE,
        cparty_code      = P_CPARTY_CODE,
        portfolio_code   = nvl(P_PORTFOLIO_CODE,'NOTAPPL')
    where deal_number = P_DEAL_NO
    and deal_type = 'SWPTN'
    and date_type = 'EXPIRY';
   --
    if P_STATUS_CODE = 'EXERCISED' then
      xtr_fps2_p.standing_settlements(P_CPARTY_CODE,P_CURRENCY,'SWPTN',
                                   P_DEAL_SUBTYPE,P_PRODUCT_TYPE,'SETTLE',
                                   v_settle_ref,v_settle_ac);
      -- AW Bug 894751
      delete from XTR_DEAL_DATE_AMOUNTS
      where deal_number = P_DEAL_NO
      and deal_type = 'SWPTN'
      and date_type = 'EXPIRY';
      --
      if P_SETTLE_RATE is not null then
         open C_LIMIT_WEIGHTING(P_DEAL_TYPE, P_DEAL_SUBTYPE);
         fetch C_LIMIT_WEIGHTING into v_weighting;
         close C_LIMIT_WEIGHTING;
         update XTR_DEAL_DATE_AMOUNTS
         set amount           = (100/v_weighting*nvl(P_SETTLE_AMOUNT,0)),
             hce_amount       = (100/v_weighting*nvl(P_SETTLE_HCE_AMOUNT,0)),
            amount_date       = P_SETTLE_DATE,
            status_code       = P_STATUS_CODE,
            currency          = P_CURRENCY,
            company_code      = P_COMPANY_CODE,
            deal_subtype      = P_DEAL_SUBTYPE,
            product_type      = P_PRODUCT_TYPE,
            dealer_code       = P_DEALER_CODE,
            client_code       = P_CLIENT_CODE,
            cparty_code       = P_CPARTY_CODE,
            portfolio_code    = nvl(P_PORTFOLIO_CODE,'NOTAPPL'),
             limit_code       = nvl(P_LIMIT_CODE,'NILL'),
             limit_party      = P_CPARTY_CODE
         where deal_number = P_DEAL_NO
         and deal_type = 'SWPTN'
         and date_type = 'LIMIT';
         --
         update XTR_DEAL_DATE_AMOUNTS
         set amount            = nvl(P_SETTLE_AMOUNT,0),
             hce_amount        = nvl(P_SETTLE_HCE_AMOUNT,0),
             amount_date       = P_SETTLE_DATE,
             cashflow_amount   = decode(P_SETTLE_ACTION,'PAY',(-1),1) * nvl(P_SETTLE_AMOUNT,0),
             transaction_rate  = P_SETTLE_RATE,
             account_no        = nvl(v_SETTLE_ACCOUNT_NO, account_no),
             --Bug 3060946 Removed assignement to cparty_account_no
             status_code       = P_STATUS_CODE,
             currency          = P_CURRENCY,
             company_code      = P_COMPANY_CODE,
             deal_subtype      = P_DEAL_SUBTYPE,
             product_type      = P_PRODUCT_TYPE,
             dealer_code       = P_DEALER_CODE,
             client_code       = P_CLIENT_CODE,
             cparty_code       = P_CPARTY_CODE,
             portfolio_code    = nvl(P_PORTFOLIO_CODE,'NOTAPPL')
         where deal_number = P_DEAL_NO
         and deal_type = 'SWPTN'
         and date_type = 'SETTLE';
         --
         --Bug 3060946 Removed 'insert into XTR_DEAL_DATE_AMOUNTS' statement
	 --
      else -- AW Bug 894751
         --  This is for creating swap.
        -- JT bug 1312363 while validating after exercise the insert was giving
        -- duplicate row error a select is added to check whether the row is already
        -- existing or not. if no data found then insert the record

        open CHK_SWPTN_SETTLE_ROWS;
        fetch CHK_SWPTN_SETTLE_ROWS into l_dummy;

        if CHK_SWPTN_SETTLE_ROWS%NOTFOUND then
             insert into XTR_DEAL_DATE_AMOUNTS
                (deal_type,amount_type,date_type,
                 deal_number,transaction_number,transaction_date,currency,
                 amount,hce_amount,amount_date,transaction_rate,
                 cashflow_amount,company_code,deal_subtype,product_type,
                 status_code,dealer_code,client_code,cparty_code,settle,
                 portfolio_code,QUICK_INPUT)
             values('SWPTN','N/A','SETTLE',
                 P_DEAL_NO,1,trunc(sysdate),P_CURRENCY,
                 0,0,trunc(sysdate),0,0,P_COMPANY_CODE,P_DEAL_SUBTYPE,
                 P_PRODUCT_TYPE,P_STATUS_CODE,P_DEALER_CODE,
                 P_CLIENT_CODE,P_CPARTY_CODE,'N',
                 nvl(P_PORTFOLIO_CODE,'NOTAPPL'),P_QUICK_INPUT);
         end if;
         close CHK_SWPTN_SETTLE_ROWS;
      end if;
      --
      update XTR_DEAL_DATE_AMOUNTS
       set limit_code  = NULL,
           status_code = P_STATUS_CODE
       where deal_number = P_DEAL_NO
      and limit_code is not null
      and date_type <> 'LIMIT';
    end if;
  end if;
 end if;
end if;
end if;
IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
   xtr_debug_pkg.debug('After MAINTAIN_DDA_PROC on:'||to_char(sysdate,'MM:DD:HH24:MI:SS'));
END IF;

end MAINTAIN_DDA_PROC;


END XTR_MAINTAIN_DDA_P;

/
