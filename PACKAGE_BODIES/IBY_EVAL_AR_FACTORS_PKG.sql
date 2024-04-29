--------------------------------------------------------
--  DDL for Package Body IBY_EVAL_AR_FACTORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_EVAL_AR_FACTORS_PKG" AS
/*$Header: ibyevarb.pls 115.5 2002/11/18 22:26:55 jleybovi ship $*/

/*
** Procedure: eval_TrxnCreditLimit
** Purpose: Evaluates the risk associated with Transaction Credit
**          Limit risk factor.
**          The transaction amount will be passed into this routine
**          along with the account number . Compare the
**          transaction credit limit set for this account with the
**          transaction amount and return the risk score.
*/

procedure eval_TrxnCreditLimit(i_acctnumber in varchar2,
                          i_amount in number,
                          i_currency_code in varchar2,
                          i_payeeid in varchar2,
                          o_risk_score out nocopy number)
is

/*
** Get the transaction credit limit set for the given account
*/
cursor c_get_trxn_limit(ci_accountnumber varchar2,
                        ci_currency_code in varchar2) is
select p.trx_credit_limit
from hz_cust_accounts a,
     hz_cust_profile_amts p
where a.account_number = ci_accountnumber and
      a.status = 'A' and
      p.currency_code = ci_currency_code and
      p.site_use_id is null and
      a.cust_account_id = p.cust_account_id;

l_trxnlimit    number;
l_score varchar2(10);
begin
/*
** close the cursor if it is already open.
*/
if ( c_get_trxn_limit%isopen ) then
        close c_get_trxn_limit;
end if;
 --dbms_output.put_line('acct = '||i_acctnumber || 'currency = ' || i_currency_code);
/*
** Raise an exception if accountnumber is null
*/
 if (i_acctnumber is null) then
    raise_application_error(-20000,'IBY_204250#',FALSE);
 end if;
/*
** open the cursor and check if the corresponding trxn_limit exists in the
** database for that account.
*/

 open c_get_trxn_limit(i_acctnumber,i_currency_code);
 fetch c_get_trxn_limit into l_trxnlimit;
 --dbms_output.put_line('Transaction limit : '||  l_trxnlimit);
 if ( l_trxnlimit is null or l_trxnlimit = 0) then
     o_risk_score := 0;
 else
    /*compare trxncreditlimit with trxnamount*/
    if i_amount <= l_trxnlimit then
       o_risk_score := 0;
    else
        o_risk_score := iby_risk_scores_pkg.getscore(i_payeeid,'H');
    end if;

  end if;
end eval_TrxnCreditLimit;

/*
** Procedure: eval_OverallCreditLimit
** Purpose: Evaluates the risk associated with Overall Credit Limit risk factor.
**          The  accountnumber will be passed into this routine
**          Based on the account number get the associated Overall Credit Limit
**          and compare it with the overall balance .
**          Overall Balance is the amount due remaining for all the open
**          transactions of that account
*/

Procedure eval_OverallCreditLimit(i_accountnumber in varchar2,
                                  i_amount in number,
                                  i_currency_code in varchar2,
                                  i_payeeid in varchar2,
                       		  o_risk_score out nocopy number)
is

l_overall_credit_limit    number;
l_customer_id number;
l_debit_balance number;
l_credit_balance number;
l_on_account_cash number;
l_unapplied_cash number;
l_ar_balance number;

l_score varchar2(10);
/*
** Get the transaction credit limit set for the given account
*/
cursor c_get_overall_credit_limit(ci_accountnumber in varchar2,
                                  ci_currency_code in varchar2) is
select p.overall_credit_limit,a.party_id
from hz_cust_accounts a,
     hz_cust_profile_amts p
where a.account_number = ci_accountnumber and
      a.status = 'A' and
      p.currency_code = ci_currency_code and
      p.site_use_id is null and
      a.cust_account_id = p.cust_account_id;
/*
** Get the customer_id

cursor c_get_customer_id(ci_accountnumber in varchar2) is
select party_id
from hz_cust_accounts
where account_number = ci_accountnumber;
*/

/*
** Get the debit Balance
*/
cursor c_get_debit_balance(ci_customer_id in number) is
select nvl(sum(amount_due_remaining),0)
from ar_payment_schedules_all
where customer_id = ci_customer_id and
      class in ('DM','INV') and
      status = 'OP';

/*
** Get Credit Balance
*/
cursor c_get_credit_balance(ci_customer_id in number) is
select nvl(sum(amount_due_remaining),0)
from ar_payment_schedules_all
where customer_id = ci_customer_id and
      class in ('CM') and
      status = 'OP';
/*
** Get on account cash
*/
cursor c_get_on_account_cash(ci_customer_id in number) is
select nvl(sum(decode(app.status,'ACC',(-1*app.amount_applied_from),0)),0)
from ar_receivable_applications_all app,
     ar_payment_schedules_all ps,
     gl_code_combinations cc
where ps.customer_id = ci_customer_id and
      ps.cash_receipt_id = app.cash_receipt_id and
      nvl(app.confirmed_flag ,'Y') = 'Y' and
      app.status in ('ACC') and
      app.code_combination_id = cc.code_combination_id;

/*
** Get unapplied cash
*/
cursor c_get_unapplied_cash(ci_customer_id in number) is
select nvl(sum(decode(app.status,'UNAPP',(-1*app.amount_applied_from),0)),0)
from ar_receivable_applications_all app,
     ar_payment_schedules_all ps,
     gl_code_combinations cc
where ps.customer_id = ci_customer_id and
      ps.cash_receipt_id = app.cash_receipt_id and
      nvl(app.confirmed_flag,'Y') = 'Y' and
      app.status IN ('UNAPP') and
      app.code_combination_id = cc.code_combination_id;

begin
/*
** close the cursor if already open
*/
if (c_get_overall_credit_limit%isopen) then
   close c_get_overall_credit_limit;
end if;
--dbms_output.put_line('acct = '||i_accountnumber || 'currency = ' || i_currency_code);
/*
** Raise an exception if accountnumber is null
*/
 if (i_accountnumber is null) then
    raise_application_error(-20000,'IBY_20450#');
 end if;

/*
** open the cursor and get the overall credit limit for the account
*/
open c_get_overall_credit_limit(i_accountnumber,i_currency_code);
fetch c_get_overall_credit_limit into l_overall_credit_limit,l_customer_id;
--dbms_output.put_line('ov_limit = '|| l_overall_credit_limit || 'cust = '||l_customer_id);
if (l_overall_credit_limit is null or l_overall_credit_limit = 0) then
    o_risk_score := 0;
   --raise_application_error(-20000,'IBY_204560#',FALSE);
else
/*
** close the cursor if already open

   if (c_get_customer_id%isopen) then
      close c_get_customer_id;
   end if;

  ** open the cursor and get the customer_id corresponding to that account

    open c_get_customer_id(i_accountnumber,i_org_id);
    fetch c_get_customer_id into l_customer_id; */
   /*
       ** get debit balance for that customer
       */
          open c_get_debit_balance(l_customer_id);
          fetch c_get_debit_balance into l_debit_balance;
          --dbms_output.put_line('debit = '|| l_debit_balance);
          if (c_get_debit_balance%notfound) then
             l_debit_balance := 0;
          end if;
        /*
        ** get credit balance for that customer
        */
          open c_get_credit_balance(l_customer_id);
          fetch c_get_credit_balance into l_credit_balance;
          --dbms_output.put_line('cred balance = ' || l_credit_balance);
          if (c_get_credit_balance%notfound) then
             l_credit_balance := 0;
          end if;
        /*
        ** get on account cash for that customer
        */
          open c_get_on_account_cash(l_customer_id);
          fetch c_get_on_account_cash into l_on_account_cash;
           --dbms_output.put_line('account cash = '||l_on_account_cash);
          if (c_get_on_account_cash%notfound) then
             l_on_account_cash := 0;
          end if;
        /*
        ** get unapplied cash for that customer
        */
          open c_get_unapplied_cash(l_customer_id);
          fetch c_get_unapplied_cash into l_unapplied_cash;
          --dbms_output.put_line('unapp cash = '||l_unapplied_cash);
          if (c_get_unapplied_cash%notfound) then
             l_unapplied_cash := 0;
          end if;

         /*
         ** Compute the AR balance
         */
          l_ar_balance := nvl(l_debit_balance,0) + nvl(l_credit_balance,0) +
                          nvl(l_on_account_cash,0) + nvl(l_unapplied_cash,0);

         --dbms_output.put_line('AR balance = '||l_ar_balance);
        /*
        ** Compare the AR balance with the Overall Credit Limit
        ** and return the risk score.
        */
           if i_amount <= (l_overall_credit_limit - l_ar_balance) then
              o_risk_score := 0;
           else
              o_risk_score := iby_risk_scores_pkg.getscore(i_payeeid,'H');
           end if;
           --dbms_output.put_line('risk score = '||o_risk_score);
close c_get_debit_balance;
close c_get_credit_balance;
close c_get_on_account_cash;
close c_get_unapplied_cash;
--close c_get_customer_id;

end if; /*overall_credit_limit found*/
close c_get_overall_credit_limit;


end eval_OverallCreditLimit; /* eval_OverallCreditLimit */



/*
** Procedure: eval_CreditRatingCode
** Purpose: Evaluates the risk associated with CreditRating Code risk factor.
**          The accountnumber will be passed into this routine
**          Based on the account number get the associated creditrating code
**          and compare the creditrating code with the creditratingcode mapping
**          stored in iby_mappings and return the appropriate risk score.
*/

Procedure eval_CreditRatingCode(i_accountnumber in varchar2,
                       i_payeeid in varchar2,
                       o_risk_score out nocopy number)
is

l_creditratingcode      varchar2(30);
l_risk_score_code varchar2(30);
l_cnt number;
l_payeeid varchar2(80);
/*
** Get the creditrating code set up for the account
*/
cursor c_get_creditratingcode(ci_accountnumber in varchar2) is
select p.credit_rating
from hz_cust_accounts a,
     hz_customer_profiles p
where a.account_number = ci_accountnumber and
      p.status = 'A' and
      a.status = 'A' and
      p.site_use_id is null and
      a.cust_account_id = p.cust_account_id;
/*
** Get the mapping creditrating_code from iby_mappings table
*/
cursor c_get_mapping_code_value(ci_creditratingcode in varchar2, ci_payeeid in varchar2) is
select m.value
from iby_mappings m
where m.mapping_code = ci_creditratingcode and
      m.mapping_type = 'CREDIT_CODE_TYPE' and
      ((payeeid is null and ci_payeeid is null) or (m.payeeid = ci_payeeid));
begin
/*
** close the cursor if it is already open.
*/
if ( c_get_creditratingcode%isopen ) then
        close c_get_creditratingcode;
end if;
/*
** Raise an exception if accountnumber is null
*/
 if (i_accountnumber is null) then
    raise_application_error(-20000,'IBY_20450#');
 end if;

/*
** open the cursor and check if the corresponding risk_code exists in the
** database for that account.
*/
 open c_get_creditratingcode(i_accountnumber);
 fetch c_get_creditratingcode into l_creditratingcode;
 if (l_creditratingcode is null ) then
      o_risk_score := 0;
 else
    /*
    ** close the cursor if it is already open
    */
    if (c_get_mapping_code_value%isopen) then
       close c_get_mapping_code_value;
    end if;
    /*
    ** check whether this payeeid has any entry in for
    ** creditrating codes.
    ** if not then set payeeid to null
    */
    select count(1) into l_cnt
    from iby_mappings
    where mapping_type = 'CREDIT_CODE_TYPE'
    and payeeid = i_payeeid;

    if (l_cnt = 0) then
       l_payeeid := null;
    else
       l_payeeid := i_payeeid;
    end if;

    /*
    ** open the cursor and check if the corresponding risk_code exists in the
    ** database
    */
    open c_get_mapping_code_value(l_creditratingcode, l_payeeid);
    fetch c_get_mapping_code_value into l_risk_score_code;
    -- if creditrating code is not present then assign norisk value
    -- else get the corresponding value by calling
    -- iby_risk_scores_pkg.getscore method.

    if (c_get_mapping_code_value%notfound) then
       o_risk_score := 0;
    else
      /*
      ** get the riskscore value associated with the riskscore from iby_mappings
      */
       o_risk_score := iby_risk_scores_pkg.getscore(i_payeeid,l_risk_score_code);
    end if;
      close c_get_mapping_code_value;
 close c_get_creditratingcode;
 end if;
end eval_CreditRatingCode;

/*
** Procedure: eval_RiskCode
** Purpose: Evaluates the risk associated with Risk Code risk factor.
**          The accountnumber will be passed into this routine
**          Based on the account number get the associated risk code
**          and compare the riskcode with the riskcode mapping
**          stored in iby_mappings and return the appropriate risk score.
*/

procedure eval_RiskCode(i_accountnumber in varchar2,
                       i_payeeid in varchar2,
                       o_risk_score out nocopy number)
is

l_riskcode	varchar2(30);
l_riskscore_code varchar2(30);
l_cnt number;
l_payeeid varchar2(80);
/*
** Get the risk code set up for the account
*/
cursor c_get_riskcode(ci_accountnumber in varchar2) is
select p.risk_code
from hz_cust_accounts a,
     hz_customer_profiles p
where a.account_number = ci_accountnumber and
      p.status = 'A' and
      a.status = 'A' and
      p.site_use_id is null and
      a.cust_account_id = p.cust_account_id;
/*
** Get the mapping risk_code from iby_mappings table
*/
cursor c_get_mapping_code_value(ci_riskcode in varchar2, ci_payeeid in varchar2) is
select m.value
from iby_mappings m
where m.mapping_code = ci_riskcode and
      m.mapping_type = 'RISK_CODE_TYPE' and
      ((m.payeeid is null and ci_payeeid is null) or (m.payeeid = ci_payeeid));

begin
/*
** close the cursor if it is already open.
*/
if ( c_get_riskcode%isopen ) then
        close c_get_riskcode;
end if;
/*
** Raise an exception if accountnumber is null
*/
 if (i_accountnumber is null) then
    raise_application_error(-20000,'IBY_20450#');
 end if;

/*
** open the cursor and check if the corresponding risk_code exists in the
** database for that account.
*/
 open c_get_riskcode(i_accountnumber);
 fetch c_get_riskcode into l_riskcode;
 if ( l_riskcode is null ) then
    o_risk_score := 0;
 else
    /*
    ** close the cursor if it is already open
    */
    if (c_get_mapping_code_value%isopen) then
       close c_get_mapping_code_value;
    end if;
    /*
    ** check whether this payeeid has any entry in
    ** for RISKcodes.
    ** if not the set payeeid to null.
    */
    select count(1) into l_cnt
    from iby_mappings
    where mapping_type = 'RISK_CODE_TYPE'
    and payeeid = i_payeeid;

    if (l_cnt = 0) then
       l_payeeid := null;
    else
       l_payeeid := i_payeeid;
    end if;
    /*
    ** open the cursor and check if the corresponding risk_code exists in the
    ** database
    */
    open c_get_mapping_code_value(l_riskcode,i_payeeid);
    fetch c_get_mapping_code_value into l_riskscore_code;
    if (c_get_mapping_code_value%notfound) then
       o_risk_score := 0;
    else
      /*
      ** get the riskscore value associated with the riskscore from iby_mappings
      */
      o_risk_score := iby_risk_scores_pkg.getscore(i_payeeid, l_riskscore_code);
      end if;

      close c_get_mapping_code_value;
 close c_get_riskcode;
 end if;
end eval_RiskCode;
end iby_eval_ar_factors_pkg;

/
