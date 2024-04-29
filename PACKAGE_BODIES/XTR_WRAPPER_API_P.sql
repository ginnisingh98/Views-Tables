--------------------------------------------------------
--  DDL for Package Body XTR_WRAPPER_API_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_WRAPPER_API_P" as
/* $Header: xtrwrapb.pls 120.17.12010000.3 2009/11/04 20:03:21 srsampat ship $ */

--Local procedure for doing Reval/Accrual related Validations.

Procedure bank_balance_validate(P_COMPANY_CODE IN VARCHAR2,
		       P_ACCOUNT_NUMBER IN VARCHAR2,
		       P_CURRENCY_CODE IN VARCHAR2,
               	       P_BALANCE_DATE IN DATE,
                       P_EVENT_CODE IN VARCHAR2,
		       P_ACTION IN VARCHAR2,
		       P_RESULT OUT NOCOPY VARCHAR2,
		       P_ERROR_MSG OUT NOCOPY VARCHAR2);

-- Package that is called by CE for Reconciliation

     Procedure Xtr_Wrapper_API(P_XTR_Procedure_Code IN VARCHAR2,
			       P_Settlement_Summary_ID IN NUMBER,
 			       P_Task IN VARCHAR2,
			       P_Reconciled_Method IN CHAR,
		               P_Org_ID IN NUMBER,
			       P_ce_bank_account_id IN NUMBER,
			       P_currency_Code IN VARCHAR2,
                               P_Sec_Bank_Account_ID IN NUMBER,
	     		       P_Trans_Amount IN NUMBER,
                               P_Balance_Date IN DATE,
                               P_Balance_Amount_A IN NUMBER,
     			       P_Balance_Amount_B IN NUMBER,
	                       P_Balance_Amount_C IN NUMBER,
	                       P_One_Day_Float IN NUMBER,
	                       P_Two_Day_Float IN NUMBER,
                               P_Result OUT NOCOPY VARCHAR2,
     			       P_error_Msg OUT NOCOPY VARCHAR2) is
     BEGIN
/* This procedure is called by CE before or after reconciliation */
         IF (P_XTR_Procedure_Code = 1) THEN
             Bank_Account_Verification(P_org_ID,
                                       P_ce_bank_account_id,
                                       P_Currency_Code,
                                       P_Result,
                                       P_Error_Msg);
         ELSIF (P_XTR_Procedure_Code = 2) THEN
             Reconciliation(P_Settlement_Summary_ID,
                            P_Task,
                            P_Reconciled_Method,
                            P_Result,null,null);
         ELSIF (P_XTR_Procedure_Code = 3) THEN
             IF (P_Balance_Amount_A IS NOT NULL) THEN
                 Bank_Balance_Upload(P_Org_ID,
                                     P_ce_bank_account_id,
                                     P_Currency_Code,
                                     P_Balance_Date,
                                     P_Balance_Amount_A,
                                     P_Balance_Amount_B,
                                     P_Balance_Amount_C,
                                     P_One_Day_Float,
                                     P_Two_Day_Float,
                                     P_Result,
                                     P_error_Msg);
             END IF;
         ELSE
             p_result := 'XTR5_FAIL';
        END IF;
     END Xtr_Wrapper_API;

     Procedure Reconciliation(P_Settlement_Summary_ID IN Number,
                              P_Task IN Varchar2,
		              P_Reconciled_Method IN Char,
                              P_Result OUT NOCOPY Varchar2,P_RECON_AMT IN NUMBER,
		P_VAL_DATE IN DATE ) is
         v_settlement_number number;
         v_net_Id number;
         v_reconciled_reference number;
	 l_adjust number;
	 l_dda_amount number;
	 u_deal_number Number;
	 u_transaction_number Number;
	 u_date_type XTR_DEAL_DATE_AMOUNTS.DATE_TYPE%TYPE;
         u_amount_type XTR_DEAL_DATE_AMOUNTS.AMOUNT_TYPE%TYPE;
	 u_amount_date XTR_DEAL_DATE_AMOUNTS.AMOUNT_DATE%TYPE;
	 u_currency XTR_DEAL_DATE_AMOUNTS.CURRENCY%TYPE;
	 u_account_number XTR_DEAL_DATE_AMOUNTS.ACCOUNT_NO%TYPE;
	 u_Settlement_Number XTR_DEAL_DATE_AMOUNTS.SETTLEMENT_NUMBER%TYPE;
	 l_amount NUMBER;
	  l_hce_amt NUMBER;
	  l_test_number NUMBER;
		l_cashflow_amt NUMBER;
		l_deal_type XTR_DEAL_DATE_AMOUNTS.DEAL_TYPE%TYPE;

         Cursor C1 is
         Select *
         From Xtr_Deal_Date_Amounts
         Where settlement_number in
               (Select settlement_number
                From Xtr_Settlement_Summary
                Where net_ID = p_settlement_summary_ID)
         For update of reconciled_reference;


	 cursor pop_dda_var is
	 select deal_number,transaction_number,date_type,amount_type,amount_date,currency,account_no,settlement_number
	 from xtr_deal_date_amounts  Where settlement_number in
               (Select settlement_number
                From Xtr_Settlement_Summary
                Where settlement_summary_id = p_settlement_summary_ID);


	  cursor DDA (P_DEAL_NO number, P_TRANS_NO number, P_DATE_TYPE varchar2,
             P_AMOUNT_TYPE varchar2, P_AMOUNT_DATE date, P_CURR varchar2,
             P_ACCOUNT_NO varchar2, P_SETTLEMENT_NUMBER number) is
  select rowid,
         RECONCILED_REFERENCE,
         RECONCILED_PASS_CODE,
         RECONCILED_DAYS_ADJUST,
         AMOUNT_DATE,
         DATE_TYPE,
         AMOUNT,
         HCE_AMOUNT,
         CASHFLOW_AMOUNT,
/******** code below added by Ilavenil for CE Reconciliation project *******/
         SETTLEMENT_NUMBER,
         NETOFF_NUMBER
  from   XTR_DEAL_DATE_AMOUNTS_V
  where  DEAL_NUMBER = p_deal_no
  and    TRANSACTION_NUMBER = p_trans_no
  and    DATE_TYPE = p_date_type
  and    AMOUNT_TYPE = p_amount_type
  and    AMOUNT_DATE = p_amount_date
  and    CURRENCY = p_curr
  and    ACCOUNT_NO = p_account_no
/**** AND clause below added by Ilavenil for CE Recon project ***/
  and    SETTLEMENT_NUMBER = nvl(p_settlement_number, settlement_number)
  and    STATUS_CODE <> 'CANCELLED'
/******/
  for update of reconciled_reference, reconciled_pass_code, reconciled_days_adjust,
                amount_date, date_type, amount, hce_amount, cashflow_amount;
--
 dda_row dda%rowtype;

     Begin

/* After CE is done with Reconciliation this procedure updates the necessary records in XTR tables to denote the completion
   of Reconciliation */

	 If p_task = 'REC' then

    -- ER 7601596 Start

          select deal_type into l_deal_type from xtr_deal_date_amounts where settlement_number in
	 (Select settlement_number
                From Xtr_Settlement_Summary
                Where settlement_summary_id = p_settlement_summary_ID);


		if l_deal_type ='RTMM' then

	 /* Calculate Adjustments */
	 select amount into l_dda_amount from xtr_deal_date_amounts where settlement_number in
	 (Select settlement_number
                From Xtr_Settlement_Summary
                Where settlement_summary_id = p_settlement_summary_ID);

      l_adjust := nvl(abs(P_RECON_AMT),0) - nvl(abs(l_dda_amount),0);


 /* Update DDA */

 Open pop_dda_var ;


 fetch pop_dda_var into u_deal_number, u_transaction_number, u_date_type,
                      u_amount_type,u_amount_date,u_currency,u_account_number,u_Settlement_Number;

close pop_dda_var ;

    Open DDA (u_deal_number, u_transaction_number, u_date_type,
                      u_amount_type,u_amount_date,u_currency,u_account_number,u_Settlement_Number);

	    Fetch DDA into dda_row;

	    While DDA%FOUND loop

	       l_amount  := nvl(DDA_ROW.amount,0) + nvl(l_adjust,0);


	       if nvl(DDA_ROW.hce_amount, 0) <> 0 then
                  l_hce_amt := nvl(DDA_ROW.hce_amount,0) + nvl(l_adjust,0) *
                               (DDA_ROW.amount / DDA_ROW.hce_amount);
	       else
		  l_hce_amt := 0;
	       end if;

               If (DDA_ROW.cashflow_amount <= 0) then
                  l_cashflow_amt := nvl(DDA_ROW.cashflow_amount,0) - l_adjust;
               Else
                  l_cashflow_amt := nvl(DDA_ROW.cashflow_amount,0) + l_adjust;
               End If;

	       Select Xtr_Deal_Date_Amounts_S.Nextval
            Into v_reconciled_reference
            From dual;


	       update XTR_DEAL_DATE_AMOUNTS_V
                  set RECONCILED_REFERENCE   = v_reconciled_reference,
                      RECONCILED_PASS_CODE   = decode(DATE_TYPE,'FORCAST','^'||'M','M'),
                      RECONCILED_DAYS_ADJUST = (nvl(P_VAL_DATE,SYSDATE) - U_AMOUNT_DATE),
                      AMOUNT_DATE            = decode(DATE_TYPE,'FORCAST',nvl(P_VAL_DATE,SYSDATE),AMOUNT_DATE),
                      DATE_TYPE              = decode(DATE_TYPE,'FORCAST','SETTLE',DATE_TYPE),
                      AMOUNT                 = decode(DATE_TYPE,'FORCAST',l_amount,AMOUNT),
                      HCE_AMOUNT             = decode(DATE_TYPE,'FORCAST',l_hce_amt,HCE_AMOUNT),
                      CASHFLOW_AMOUNT        = decode(DATE_TYPE,'FORCAST',l_cashflow_amt,CASHFLOW_AMOUNT)
                where rowid = DDA_ROW.rowid;

                  Update Xtr_Settlement_Summary
                  Set status = 'R'
                  Where settlement_number = DDA_ROW.Settlement_Number;

                  exit;

	    END LOOP;

            Close DDA;
	    COMMIT;





	    XTR_AUTO_RECONCILIATION.UPDATE_ROLL_TRANS_RTMM(
			null,
			v_reconciled_reference,
                        v_reconciled_reference,
			'MANUAL',P_VAL_DATE);
			commit;
-- ER 7601596 End
	else

/* This is to update Xtr_Settlement_Summary about the successful completion of Reconciliation */
            Update xtr_settlement_summary
            set status = 'R'
            Where settlement_summary_id = p_settlement_summary_ID;

            If SQL%Found then
               P_Result := 'XTR2_SUCCESS';
            Else
               P_Result := 'XTR2_FAIL';
            End if;

            Select settlement_number
            Into v_settlement_number
            From Xtr_Settlement_Summary
            Where settlement_summary_id = p_settlement_summary_ID;

            Select Xtr_Deal_Date_Amounts_S.Nextval
            Into v_reconciled_reference
            From dual;

/* This is to update DDA about the successful completion of Reconciliation */
            Update Xtr_Deal_Date_Amounts
            Set Reconciled_Reference = v_reconciled_reference,
                Reconciled_Pass_Code = p_reconciled_method
            Where settlement_number = v_settlement_number;

            If SQL%NOTFOUND then
                For C1_Rec in C1
                Loop
                    Update Xtr_Deal_Date_Amounts
                    Set reconciled_reference = v_reconciled_reference,
                    reconciled_pass_code = p_reconciled_method
                    Where current of C1;
                End Loop;
            End if;

      End if;

	 Else
-- ER 7601596 Start for Unreconciliation

         select distinct deal_type into l_deal_type from xtr_deal_date_amounts where settlement_number in
	 (Select settlement_number
                From Xtr_Settlement_Summary
                Where settlement_summary_id = p_settlement_summary_ID);

		if l_deal_type ='RTMM' then
			declare
			v_recon_ref number;
			begin

			SELECT DISTINCT reconciled_reference into v_recon_ref FROM xtr_deal_date_amounts
                        WHERE settlement_number IN
			(SELECT settlement_number FROM xtr_settlement_summary WHERE settlement_summary_id = p_settlement_summary_ID);

			XTR_AUTO_RECONCILIATION.REVERSE_ROLL_TRANS_RTMM(
			null,
			v_recon_ref,
                        v_recon_ref,
			'MANUAL',P_VAL_DATE); end;
		end if;
		-- ER 7601596 End

/* After successful Un-Reconciliation, Xtr_Settlement_Summary is updated for availability of record for future reconciliation */
            Update xtr_settlement_summary
            set status = 'A'
            Where settlement_summary_id = p_settlement_summary_ID;
            If SQL%Found then
               P_Result := 'XTR2_SUCCESS';
            Else
               P_Result := 'XTR2_FAIL';
            End if;

            Select settlement_number
            Into v_settlement_number
            From Xtr_Settlement_Summary
            Where settlement_summary_id = p_settlement_summary_ID;

            Update Xtr_Deal_Date_Amounts
            Set Reconciled_Reference = null,
                Reconciled_Pass_Code = null
            Where settlement_number = v_settlement_number;

            If SQL%NOTFOUND then
                For C1_Rec in C1
                Loop
/* After successful un-reconciliation, DDA is updated such that the records are available for future reconciliation */
                    Update Xtr_Deal_Date_Amounts
                    Set reconciled_reference = null,
                    reconciled_pass_code = null
                    Where current of C1;
                End Loop;
            End if;
          -- ER 7601596 Start
	  Update Xtr_Deal_Date_Amounts
            Set settlement_number = null
            Where settlement_number = v_settlement_number and deal_type ='RTMM' and amount_type='PRINFLW'
	    and exists(select 1 from Xtr_Deal_Date_Amounts where settlement_number = v_settlement_number and deal_type ='RTMM' and amount_type='INTSET')  ;
	    -- ER 7601596 End
         End if;

         If p_result = 'XTR2_SUCCESS' then
            commit;
         Else
            Rollback;
         End if;

     End Reconciliation;

     Procedure Bank_Account_Verification(P_ORG_ID             IN NUMBER,
		           P_ce_bank_account_id IN NUMBER,
                   P_CURRENCY_CODE      IN VARCHAR2,
                   P_RESULT             OUT NOCOPY VARCHAR2,
                   P_ERROR_MSG          OUT NOCOPY VARCHAR2)is


      cursor GET_AUTH_COMPANY is
      select xp.PARTY_CODE COMPANY_CODE
      from XTR_PARTY_INFO xp  -- BUG 2811315
       where xp.legal_entity_id = P_ORG_ID    -- bug 3862743
       and xp.authorised = 'Y';


      cursor GET_COMPANY is
      select xp.PARTY_CODE COMPANY_CODE
      from XTR_PARTY_INFO xp
       where xp.legal_entity_id = P_ORG_ID;    -- bug 3862743

      cursor FIND_AP_ACCT_ID is
      select ce_bank_account_id from
      xtr_bank_accounts
      where ce_bank_account_id = P_ce_bank_account_id
      and   ce_bank_account_id is not null;

      Cursor CUR_AUTH_ACCT IS
      select ce_bank_account_id from
             xtr_bank_accounts b,
	     xtr_party_info p
      where  b.ce_bank_account_id is not null
      and    ce_bank_account_id  = P_ce_bank_account_id
      and    p.party_code = b.party_code
      and    p.party_type = b.party_type
      and    p.legal_entity_id = P_ORG_ID    -- bug 3862743
      and    currency = P_CURRENCY_CODE
      and    b.authorised = 'Y';

      Cursor CUR_UNAUTH_ACCT IS
      select ce_bank_account_id,account_number from
             xtr_bank_accounts b,
	     xtr_party_info p
      where  b.ce_bank_account_id is not null
      and    ce_bank_account_id  = P_ce_bank_account_id
      and    p.party_code = b.party_code
      and    p.party_type = b.party_type
      and    p.legal_entity_id = P_ORG_ID    -- bug 3862743
      and    currency = P_CURRENCY_CODE;

      ap_acct_id   NUMBER;
      l_company    VARCHAR2(30);
      l_account_no VARCHAR2(30);

Begin
   open  FIND_AP_ACCT_ID;
   fetch FIND_AP_ACCT_ID into ap_acct_id;
   if    FIND_AP_ACCT_ID%NOTFOUND then
      P_RESULT := 'XTR1_AP';
   Else
          open GET_AUTH_COMPANY;
          fetch GET_AUTH_COMPANY into l_company;
          if GET_AUTH_COMPANY%FOUND then
             /*Authorised Company found.Check the Account. */
             open CUR_AUTH_ACCT;
             fetch CUR_AUTH_ACCT into ap_acct_id;
             if CUR_AUTH_ACCT%FOUND then
                P_RESULT := 'XTR1_SHARED';
             else
                open CUR_UNAUTH_ACCT;
                fetch CUR_UNAUTH_ACCT into ap_acct_id,l_account_no;
                /* if if the Account exists but is not Authorised */
                if CUR_UNAUTH_ACCT%FOUND then
                   FND_MESSAGE.SET_NAME('XTR','XTR_BANK_BAL_ACCT_AUTH');
                   FND_MESSAGE.SET_TOKEN('P_ACCOUNT',l_account_no);
                   P_ERROR_MSG := FND_MESSAGE.GET;
                /* if if the Account is not set up for the company and currency */
                Else
                   FND_MESSAGE.SET_NAME('XTR','XTR_BANK_BAL_INV_ACCT');
                   FND_MESSAGE.SET_TOKEN('P_ACCOUNT_ID',P_ce_bank_account_id);
                   FND_MESSAGE.SET_TOKEN('P_COMPANY',l_company);
                   FND_MESSAGE.SET_TOKEN('P_CURRENCY',P_CURRENCY_CODE);
                   P_ERROR_MSG := FND_MESSAGE.GET;
                End if;
        	    close CUR_UNAUTH_ACCT;
                P_RESULT := 'XTR1_NOT_SETUP';
             end if;
       	  close CUR_AUTH_ACCT;

          else
             /*Authorised Company not found. See if Company exists at all*/

             open GET_COMPANY;
             fetch GET_COMPANY into l_company;
             if GET_COMPANY%FOUND then
                /* This means Company is not Authorised or the user doesnot have access*/
                FND_MESSAGE.SET_NAME('XTR','XTR_BANK_BAL_COMP_AUTH');
                FND_MESSAGE.SET_TOKEN('P_COMPANY',l_company);
                P_ERROR_MSG := FND_MESSAGE.GET;
               /* No Company is setup with the given org ID*/
             else
                FND_MESSAGE.SET_NAME('XTR','XTR_BANK_BAL_INV_COMP');
                FND_MESSAGE.SET_TOKEN('P_ORG_ID',P_ORG_ID);
                P_ERROR_MSG := FND_MESSAGE.GET;
             end if;
             Close GET_COMPANY;
             P_RESULT := 'XTR1_NOT_SETUP';
           end if;
       	   close GET_AUTH_COMPANY;
   End If;
   Close FIND_AP_ACCT_ID;
End Bank_Account_Verification;


/*------------------------------------------------------------------------------/
    Bank_Balance_Upload takes input parameters from 'CE' and uploads
    balances into XTR_BANK_BALANCES if the data passes validations.
    USes local procedure bank_balance_validate for doing reval or accrual
    related validations.

    Output Params:
       P_RESULT: Possible values are 'XTR3_BU_WARNING',XTR3_BU_SUCCESS,XTR3_BU_FAIL
           1) 'XTR3_BU_WARNING' : indicates various validation errors/warnings.
           2) 'XTR3_BU_SUCCESS' : Successful Upload.
           3) 'XTR3_BU_FAIL'    :Failure for some other reasons.


       P_ERROR_MSG: Will return the following messages:
                    XTR_BANK_BALANCE_VAL_ERROR,
                    XTR_BANK_BALANCE_VAL_WARN
                    XTR_BANK_BAL_OVERWRITE
                    XTR_BANK_BAL_FUTURE_DATE

/---------------------------------------------------------------------*/

 Procedure Bank_Balance_Upload(P_ORG_ID IN NUMBER,
		P_ce_bank_account_id IN NUMBER,
                P_CURRENCY_CODE IN VARCHAR2,
                P_BALANCE_DATE IN DATE,
                P_BALANCE_AMOUNT_A IN NUMBER,
                P_BALANCE_AMOUNT_B IN NUMBER,
                P_BALANCE_AMOUNT_C IN NUMBER,
                P_ONE_DAY_FLOAT IN NUMBER,
                P_TWO_DAY_FLOAT IN NUMBER,
                P_RESULT OUT NOCOPY VARCHAR2,
                P_ERROR_MSG OUT NOCOPY VARCHAR2) is
  l_dummy     VARCHAR2(1);
  l_comp      VARCHAR2(7);
  l_ccy       VARCHAR2(15);
  l_setoff    VARCHAR2(5);
  acct_no     VARCHAR2(20);
  new_company VARCHAR2(7);
  new_date    DATE;
  new_bal_ledger   NUMBER;
  new_bal_cashflow NUMBER;
  new_bal_intcalc  NUMBER;
  new_bal_ledger_hce NUMBER;
  v_cross_ref XTR_PARTY_INFO.cross_ref_to_other_party%TYPE;
  v_dummy_num NUMBER;
  int_rate    NUMBER;
  roundfac    NUMBER;
  yr_basis    NUMBER;
  l_no_days   NUMBER;
  l_setoff_recalc_date  DATE;
  l_prv_date  DATE;
  l_prv_rate  NUMBER;
  l_prv_bal   NUMBER;
  l_int_bf    NUMBER;
  l_int_cf    NUMBER;
  l_interest  NUMBER;
  l_new_rate  NUMBER;
  l_hc_rate   NUMBER;
  l_yr_type   VARCHAR2(20);
  --add
  l_limit_code varchar2(7);
  l_portfolio_code varchar2(7);
  l_bank_code varchar2(7);
  --
  l_prv_accrual_int NUMBER;
  l_accrual_int     NUMBER;
  cursor RNDING is
   select ROUNDING_FACTOR,YEAR_BASIS,HCE_RATE
    from  XTR_MASTER_CURRENCIES_V
    where CURRENCY = l_ccy;

  --
  Cursor CUR_ACCT_NO IS
  select account_number from
         xtr_bank_accounts b,
         xtr_party_info p
  where  b.ce_bank_account_id is not null
  and    ce_bank_account_id  = P_ce_bank_account_id
  and    p.party_code = b.party_code
  and    p.party_type = b.party_type
  and    p.legal_entity_id = P_ORG_ID        -- bug 3862743
  and    currency = P_CURRENCY_CODE
  and    b.authorised = 'Y';

  --
  cursor ACCT_DETAILS is
   select
  PARTY_CODE,CURRENCY,SETOFF,PORTFOLIO_CODE,BANK_CODE,nvl(YEAR_CALC_TYPE,'ACTUAL/ACTUAL')
  YEAR_CALC_TYPE
  ,rounding_type, day_count_type  -- Added for Interest Override
    from XTR_BANK_ACCOUNTS
    where ACCOUNT_NUMBER = acct_no
    and   PARTY_CODE     = new_company;
  --
  cursor PREV_DETAILS is
   select
     a.BALANCE_DATE,a.BALANCE_CFLOW,a.ACCUM_INT_CFWD,a.INTEREST_RATE,A.ACCRUAL_INTEREST,
     a.rounding_type, a.day_count_type -- Added for Interest Override
     from XTR_BANK_BALANCES a
    where a.ACCOUNT_NUMBER = acct_no
    and   a.COMPANY_CODE = new_company
    and   a.BALANCE_DATE = (select max(b.BALANCE_DATE)
                             from XTR_BANK_BALANCES b
                             where b.ACCOUNT_NUMBER = acct_no
                             and   b.COMPANY_CODE   = new_company);
  --
  cursor CHK_EXISTING_DATE is
   select 'x'
    from XTR_BANK_BALANCES
    where ACCOUNT_NUMBER = acct_no
    and   COMPANY_CODE   = new_company
    and   TRUNC(BALANCE_DATE)  = TRUNC(new_date);
  --
  cursor GET_LIM_CODE_BAL is
   select LIMIT_CODE
    from XTR_BANK_BALANCES
    where ACCOUNT_NUMBER = acct_no
    and   COMPANY_CODE   = new_company
    and   BALANCE_DATE   < new_date
    and ((new_bal_ledger >= 0 and BALANCE_CFLOW >= 0)
      or (new_bal_ledger <= 0 and BALANCE_CFLOW <= 0))
    order by BALANCE_DATE;
  --
  cursor GET_LIM_CODE_CPARTY is
   select cl.LIMIT_CODE
     from  XTR_COUNTERPARTY_LIMITS cl, XTR_LIMIT_TYPES lt
    where cl.COMPANY_CODE = new_company
    and   cl.CPARTY_CODE  = l_bank_code
    and   cl.LIMIT_TYPE   = lt.LIMIT_TYPE
    and   ((new_bal_ledger >= 0 and lt.FX_INVEST_FUND_TYPE = 'I')
        or (new_bal_ledger <= 0 and lt.FX_INVEST_FUND_TYPE = 'OD'));
  --
  cursor CROSS_REF is
     select CROSS_REF_TO_OTHER_PARTY
     from   XTR_PARTIES_V
     where  PARTY_CODE = l_comp;
  --
  cursor GET_COMPANY is
  select xp.PARTY_CODE COMPANY_CODE
    from XTR_PARTY_INFO xp
   where xp.legal_entity_id = P_ORG_ID;        -- bug 3862743


-- Added for Interest Override
  CURSOR oldest_date IS
   SELECT MIN(a.balance_date)
     FROM   xtr_bank_balances a
     WHERE a.account_number = acct_no
     AND a.COMPANY_CODE = new_company;

  CURSOR PRV_PRV_DETAILS IS
   SELECT a.day_count_type
     FROM xtr_bank_balances a
     WHERE  a.account_number = acct_no
     AND a.COMPANY_CODE = new_company
     AND a.balance_date = (select max(b.BALANCE_DATE)
                           from XTR_BANK_BALANCES b
                           where b.ACCOUNT_NUMBER = acct_no
			   and   b.COMPANY_CODE   = new_company
			   AND   b.balance_date < l_prv_date);

  l_rounding_type   VARCHAR2(1);
  l_day_count_type  VARCHAR2(1);
  l_prv_rounding_type   VARCHAR2(1);
  l_prv_day_count_type  VARCHAR2(1);
  l_oldest_date     DATE;
  l_first_trans_flag VARCHAR2(1);
  l_original_amount NUMBER;
  l_prv_prv_day_count_type VARCHAR2(1);

Begin
      Open CUR_ACCT_NO;
      FETCH CUR_ACCT_NO INTO acct_no;
      CLOSE CUR_ACCT_NO;

      new_date := TRUNC(p_balance_date);
      new_bal_ledger   := nvl(p_balance_amount_a,0);
      new_bal_cashflow := nvl(p_balance_amount_b,new_bal_ledger);
      new_bal_intcalc  := nvl(p_balance_amount_c,0)-new_bal_ledger;
      open GET_COMPANY;
      fetch GET_COMPANY INTO new_company;
      close GET_COMPANY;

  If p_balance_date < trunc(sysdate) then

      open PREV_DETAILS;
      fetch PREV_DETAILS INTO
	l_prv_date,l_prv_bal,l_int_bf,l_prv_rate,l_prv_accrual_int,
	l_prv_rounding_type, l_prv_day_count_type; -- Added for Interest Override
      if PREV_DETAILS%NOTFOUND then
        l_prv_date := trunc(new_date);
        l_prv_bal  := 0;
        l_prv_rate := 0;
        l_int_bf   := 0;
        l_no_days  := 0;
        l_prv_accrual_int := 0;
	l_prv_rounding_type := NULL;
	l_prv_day_count_type := NULL;
      end if;
      close PREV_DETAILS;
      open ACCT_DETAILS;
      fetch ACCT_DETAILS INTO
	l_comp,l_ccy,l_setoff,l_portfolio_code,l_bank_code,l_yr_type,
	l_rounding_type, l_day_count_type;  -- Added for Interest Override
      if ACCT_DETAILS%FOUND then -- Account is loaded in the system
        close ACCT_DETAILS;
        open RNDING;
        fetch RNDING INTO roundfac,yr_basis,l_hc_rate;
        close RNDING;
        open GET_LIM_CODE_BAL;
        fetch GET_LIM_CODE_BAL INTO l_limit_code;
        if GET_LIM_CODE_BAL%NOTFOUND or l_limit_code IS NULL then
          open GET_LIM_CODE_CPARTY;
          fetch GET_LIM_CODE_CPARTY INTO l_limit_code;
          if GET_LIM_CODE_CPARTY%NOTFOUND then
            l_limit_code := Null;
          end if;
          close GET_LIM_CODE_CPARTY;
        end if;
        close GET_LIM_CODE_BAL;

	-- Added for Interest Override
	OPEN oldest_date;
	FETCH oldest_date INTO l_oldest_date;
	CLOSE oldest_date;
	IF l_day_count_type ='B' AND l_prv_date = l_oldest_date THEN
	   l_first_trans_flag :='Y';
	 ELSE
	   l_first_trans_flag := NULL;
	END IF;
	--
        if trunc(l_prv_date) <  trunc(new_date) then
	  -- Added for Interest Override
	  OPEN prv_prv_details;
	  FETCH prv_prv_details INTO l_prv_prv_day_count_type;
	  CLOSE prv_prv_details;
	  --
          XTR_CALC_P.CALC_DAYS_RUN(trunc(l_prv_date),

				   trunc(new_date),
				   l_yr_type,
				   l_no_days,
				   yr_basis,
				   NULL,
				   l_prv_day_count_type,
				   l_first_trans_flag);
	 -- Added for Interest Override
	 IF l_prv_date <> l_oldest_date AND l_prv_day_count_type ='F'
	    AND (Nvl(l_prv_prv_day_count_type,l_prv_day_count_type) ='L'
		 OR Nvl(l_prv_prv_day_count_type,l_prv_day_count_type) ='B')
	 THEN
	    l_no_days := l_no_days -1;
	 END IF;
	 --
        else
           l_no_days :=0;
           yr_basis :=365;
        end if;

	-- Changed for Interest Override
/*
        l_interest := xtr_fps2_p.interest_round(l_prv_bal * l_prv_rate / 100 * l_no_days
				   / yr_basis,roundfac,l_prv_rounding_type);
*/
  -- bug 5192026

    CE_INTEREST_CALC.int_cal_xtr( trunc(l_prv_date),
            trunc(new_date),
            p_ce_bank_account_id,
            l_prv_rate,
            'TREASURY',
            l_interest );

	    l_interest := nvl(l_interest,0) ; -- Bug 5280690

        l_original_amount := nvl(l_int_bf,0) + nvl(l_interest,0); -- Bug 5280690 added nvl condition
        l_int_cf := l_original_amount;
	--
        l_accrual_int :=nvl(l_prv_accrual_int,0) + nvl(l_interest,0);
/*
        XTR_ACCOUNT_BAL_MAINT_P.FIND_INT_RATE(acct_no,
        new_bal_ledger,
                            new_company,l_bank_code,l_ccy,new_date,l_new_rate);
*/
-- bug 5192026
        l_new_rate :=
CE_INTEREST_CALC.GET_INTEREST_RATE(p_ce_bank_account_id,new_date
                                , new_bal_ledger,l_new_rate);



        if l_new_rate is null then
          l_new_rate := 0;
        end if;
        open CHK_EXISTING_DATE;
        fetch CHK_EXISTING_DATE INTO l_dummy;
        if CHK_EXISTING_DATE%NOTFOUND then
           bank_balance_validate(new_company,acct_no,p_currency_code,new_date,'REVAL','INSERT',p_result,p_error_msg);
           if p_error_msg is null and p_result is null then
              bank_balance_validate(new_company,acct_no,p_currency_code,new_date,'ACCRUAL','INSERT',p_result,p_error_msg);
           end if;
           if nvl(p_result,'XX') = 'XTR3_BU_VAL_ERROR' then
              P_RESULT := 'XTR3_BU_WARNING';
              return;
           elsif nvl(p_result,'XX') = 'XTR3_BU_VAL_WARN' then
              insert into XTR_BANK_BALANCES
                (company_code,account_number,balance_date,no_of_days,
                 statement_balance,balance_adjustment,balance_cflow,
                 accum_int_bfwd,interest,interest_rate,interest_settled,
                 interest_settled_hce,accum_int_cfwd,setoff,limit_code,
                 created_on,created_by,accrual_interest,
		 original_amount, rounding_type, day_count_type,  -- Added for Interest Override
		 one_day_float, two_day_float)
             values
                (l_comp,acct_no,new_date,l_no_days,
                 new_bal_ledger,new_bal_intcalc,new_bal_cashflow,
                 l_int_bf,l_interest,l_new_rate,0,
                 0,l_int_cf,l_setoff,l_limit_code,
                 sysdate, fnd_global.user_id,l_accrual_int,
		 l_original_amount, l_rounding_type, l_day_count_type,   -- Added for Interest Override
		 P_ONE_DAY_FLOAT, P_TWO_DAY_FLOAT);
                 new_bal_ledger_hce := round(new_bal_ledger / l_hc_rate,roundfac);
                 P_RESULT := 'XTR3_BU_WARNING';
           else
          -- the uploaded date is the latest date then ok to insert
             insert into XTR_BANK_BALANCES
                (company_code,account_number,balance_date,no_of_days,
                 statement_balance,balance_adjustment,balance_cflow,
                 accum_int_bfwd,interest,interest_rate,interest_settled,
                 interest_settled_hce,accum_int_cfwd,setoff,limit_code,
                 created_on,created_by,accrual_interest,
		 original_amount, rounding_type, day_count_type,  -- Added for Interest Override
		 one_day_float, two_day_float)
             values
                (l_comp,acct_no,new_date,l_no_days,
                 new_bal_ledger,new_bal_intcalc,new_bal_cashflow,
                 l_int_bf,l_interest,l_new_rate,0,
                 0,l_int_cf,l_setoff,l_limit_code,
                 sysdate, fnd_global.user_id,l_accrual_int,
		 l_original_amount, l_rounding_type, l_day_count_type,  -- Added for Interest Override
		 P_ONE_DAY_FLOAT, P_TWO_DAY_FLOAT);
                 new_bal_ledger_hce := round(new_bal_ledger / l_hc_rate,roundfac);
                 P_RESULT := 'XTR3_BU_SUCCESS';
                 P_ERROR_MSG := NULL;
           end if;
          --
        else
           bank_balance_validate(new_company,acct_no,p_currency_code,new_date,'REVAL','UPDATE',P_RESULT,P_ERROR_MSG);
           if p_error_msg is null and p_result is null then
              bank_balance_validate(new_company,acct_no,p_currency_code,new_date,'ACCRUAL','UPDATE',P_RESULT,P_ERROR_MSG);
           end if;
           if nvl(p_result,'XX') = 'XTR3_BU_VAL_ERROR' then
              P_RESULT := 'XTR3_BU_WARNING';
              return;
           elsif nvl(p_result,'XX') = 'XTR3_BU_VAL_WARN' then
              update XTR_BANK_BALANCES
              set    statement_balance=new_bal_ledger,
                     balance_adjustment=new_bal_intcalc,
                     balance_cflow=new_bal_cashflow,
                     accum_int_bfwd=l_int_bf,
                     interest=l_interest,
                     interest_rate=l_new_rate,
                     interest_settled=0,
                     interest_settled_hce=0,
                     accum_int_cfwd=l_int_cf,
                     setoff=l_setoff,
                     limit_code=l_limit_code,
                     updated_on=sysdate,
                     updated_by=fnd_global.user_id,
		     accrual_interest=l_accrual_int,
		     original_amount = l_original_amount, -- Added for Interest Override
		     rounding_type = l_rounding_type,
		     day_count_type = l_day_count_type,
		     one_day_float = P_ONE_DAY_FLOAT,
		     two_day_float = P_TWO_DAY_FLOAT
              where ACCOUNT_NUMBER = acct_no
              and   COMPANY_CODE   = new_company
              and   TRUNC(BALANCE_DATE)  = TRUNC(new_date);
              P_RESULT := 'XTR3_BU_WARNING';
           else
              update XTR_BANK_BALANCES
              set    statement_balance=new_bal_ledger,
                     balance_adjustment=new_bal_intcalc,
                     balance_cflow=new_bal_cashflow,
                     accum_int_bfwd=l_int_bf,
                     interest=l_interest,
                     interest_rate=l_new_rate,
                     interest_settled=0,
                     interest_settled_hce=0,
                     accum_int_cfwd=l_int_cf,
                     setoff=l_setoff,
                     limit_code=l_limit_code,
                     updated_on=sysdate,
                     updated_by=fnd_global.user_id,
                     accrual_interest=l_accrual_int,
		     original_amount = l_original_amount, -- Added for Interest Override
		     rounding_type = l_rounding_type,
		     day_count_type = l_day_count_type,
		     one_day_float = P_ONE_DAY_FLOAT,
		     two_day_float = P_TWO_DAY_FLOAT
              where ACCOUNT_NUMBER = acct_no
              and   COMPANY_CODE   = new_company
              and   TRUNC(BALANCE_DATE)  = TRUNC(new_date);
 --             P_RESULT := 'XTR3_BU_OVERWRITE';
              P_RESULT := 'XTR3_BU_WARNING';
              FND_MESSAGE.SET_NAME('XTR','XTR_BANK_BAL_OVERWRITE');
              FND_MESSAGE.SET_TOKEN('P_DATE',trunc(new_date));
              FND_MESSAGE.SET_TOKEN('P_COMPANY',new_company);
              FND_MESSAGE.SET_TOKEN('P_ACCOUNT',acct_no);
              P_ERROR_MSG := FND_MESSAGE.GET;
          End if;
          --
             /* Balance for this date and company already exists in the system. Overwriting everything. */
        end if;
          close CHK_EXISTING_DATE;
--          P_RESULT := 'XTR3_BU_SUCCESS';
          --
          open CROSS_REF;
          fetch CROSS_REF INTO v_cross_ref;
          close CROSS_REF;
          XTR_ACCOUNT_BAL_MAINT_P.UPDATE_BANK_ACCTS(acct_no,
                              l_ccy,
                              l_bank_code,
                              l_portfolio_code,
                              v_cross_ref,
                              l_comp,
                              new_date,
                              v_dummy_num,-- for bug 6247219
                              l_setoff);-- for bug 6247219
      else
        -- P_RESULT := 'XTR3_BU_FAIL';  /* This Account does not exist for this company */
         if ACCT_DETAILS%ISOPEN then
            close ACCT_DETAILS;
         end if;
      end if;
    else
--        P_RESULT := 'XTR3_BU_FUTURE_DATE';  /* Balance date must be less than sysdate */
        P_RESULT := 'XTR3_BU_WARNING';
        FND_MESSAGE.SET_NAME('XTR','XTR_BANK_BAL_FUTURE_DATE');
        FND_MESSAGE.SET_TOKEN('P_DATE',trunc(new_date));
        FND_MESSAGE.SET_TOKEN('P_COMPANY',new_company);
        FND_MESSAGE.SET_TOKEN('P_ACCOUNT',acct_no);
        P_ERROR_MSG := FND_MESSAGE.GET;
    end if;
    commit;
    --
End Bank_Balance_Upload;

/*----------------------------------------------------------------------------/
    bank_balance_validate is a LOCAL PROCEDURE to check the
    validations related to Accrual or Reval.
/----------------------------------------------------------------------------*/

Procedure bank_balance_validate(P_COMPANY_CODE IN VARCHAR2,
		       P_ACCOUNT_NUMBER IN VARCHAR2,
		       P_CURRENCY_CODE IN VARCHAR2,
              	       P_BALANCE_DATE IN DATE,
	               P_EVENT_CODE IN VARCHAR2,
		       P_ACTION IN VARCHAR2,
		       P_RESULT OUT NOCOPY VARCHAR2,
		       P_ERROR_MSG OUT NOCOPY VARCHAR2) IS

cursor cur_reval_comp IS
   SELECT max(period_end)
   FROM
         xtr_batches b,xtr_batch_events e
   WHERE
         b.company_code = p_company_code
   AND   b.batch_id     = e.batch_id
   AND   e.event_code   = p_event_code;

--bug 7631275 starts
   /*cursor cur_reval_insbal IS
   SELECT max(period_to)
   FROM
         xtr_bank_balances bb,xtr_bank_accounts ba,
         xtr_deal_date_amounts dd,xtr_revaluation_details rd
   WHERE
     	 bb.company_code   = p_company_code
   AND   bb.account_number = p_account_number
   AND 	 bb.company_code   = ba.party_code
   AND   bb.account_number = ba.account_number
   AND   ba.currency       = p_currency_code
   AND 	 bb.company_code   = dd.company_code
   AND   bb.account_number = dd.account_no
   AND   ba.currency       = dd.currency
   AND   dd.deal_number    = rd.deal_no;*/

   cursor cur_reval_insbal IS
   select max(period_to)
   FROM
        xtr_bank_accounts ba,
        xtr_deal_date_amounts dd,
        xtr_revaluation_details rd
 WHERE ba.currency = p_currency_code
    AND ba.currency = dd.currency
    AND dd.deal_number = rd.deal_no
    AND dd.company_code = ba.party_code
    AND dd.account_no = ba.account_number
    AND dd.company_code = p_company_code
    and dd.account_no = p_account_number
    and exists (select 1 from xtr_bank_balances bb
                 where bb.company_code = dd.company_code
                   and bb.account_number =  dd.account_no);

/*cursor cur_accrl_insbal IS
   SELECT max(period_to)
   FROM
          xtr_bank_balances bb,xtr_bank_accounts ba,
          xtr_deal_date_amounts dd,xtr_accrls_amort aa
   WHERE
    	 bb.company_code   = p_company_code
   AND   bb.account_number = p_account_number
   AND 	 bb.company_code   = ba.party_code
   AND   bb.account_number = ba.account_number
   AND   ba.currency       = p_currency_code
   AND 	 bb.company_code   = dd.company_code
   AND   bb.account_number = dd.account_no
   AND   ba.currency       = dd.currency
   AND   dd.deal_number    = aa.deal_no;*/

   cursor cur_accrl_insbal IS
   select max(period_to)
   FROM
        xtr_bank_accounts ba,
        xtr_deal_date_amounts dd,
        xtr_accrls_amort aa
 WHERE ba.currency = p_currency_code
    AND ba.currency = dd.currency
    AND dd.deal_number = aa.deal_no
    AND dd.company_code = ba.party_code
    AND dd.account_no = ba.account_number
    AND dd.company_code = p_company_code
    and dd.account_no = p_account_number
    and exists (select 1 from xtr_bank_balances bb
                 where bb.company_code = dd.company_code
                   and bb.account_number =  dd.account_no);

--bug 7631275 ends
   l_rdate      date;
   l_bdate      date;
   l_error_code   VARCHAR2(30);

BEGIN
   If p_event_code = 'REVAL' then
      Open  cur_reval_insbal;
      Fetch cur_reval_insbal into l_rdate;
      Close cur_reval_insbal;
   Elsif p_event_code = 'ACCRUAL' then
      Open  cur_accrl_insbal;
      Fetch cur_accrl_insbal into l_rdate;
      Close cur_accrl_insbal;
   End If;

   If P_ACTION = 'UPDATE' then
      If l_rdate is NOT NULL and l_rdate > p_balance_date then
         P_RESULT := 'XTR3_BU_VAL_ERROR';
         L_ERROR_CODE := 'XTR_BANK_BALANCE_VAL_ERROR';
     End If;
   Elsif P_ACTION = 'INSERT' then
      If l_rdate is NULL then
         Open  cur_reval_comp;
    	 Fetch cur_reval_comp into l_bdate;
	     Close cur_reval_comp;

         If l_bdate is NOT NULL and l_bdate > p_balance_date then
            P_RESULT := 'XTR3_BU_VAL_WARN';
            L_ERROR_CODE := 'XTR_BANK_BALANCE_VAL_WARN';
     	 End If;
      Elsif l_rdate is NOT NULL and l_rdate > p_balance_date then
         P_RESULT := 'XTR3_BU_VAL_ERROR';
    	 L_ERROR_CODE := 'XTR_BANK_BALANCE_VAL_ERROR';
      End If;
  End If;
  FND_MESSAGE.SET_NAME('XTR',l_error_code);
  FND_MESSAGE.SET_TOKEN('P_DATE',trunc(p_balance_date));
  FND_MESSAGE.SET_TOKEN('P_COMPANY',p_company_code);
  FND_MESSAGE.SET_TOKEN('P_ACCOUNT',p_account_number);
  P_ERROR_MSG := FND_MESSAGE.GET;
END;


Procedure Settlement_Validation(
		P_SETTLEMENT_SUMMARY_ID IN NUMBER,
		P_RESULT OUT NOCOPY VARCHAR2)is
Begin
   /* to be implemented later */
   null;
End Settlement_Validation;


----------------------------------------------------------------------------------------------------
-- 3800146 This procedure verifies the type of account: XTR only or AP/XTR Shared
----------------------------------------------------------------------------------------------------
PROCEDURE ZBA_BANK_ACCOUNT_VERIFICATION (
		P_ORG_ID             IN  NUMBER,
		-- org_id of the company for 'Shared'
		P_ce_bank_account_id IN  NUMBER,
		-- ce_bank_account_id for 'Shared or 'AP-only'
		P_ACCOUNT_NUMBER     IN  VARCHAR2,
		-- account_number in XTR_BANK_ACCOUNTS
		P_CURRENCY           IN  VARCHAR2,-- currency of transaction
		P_BANK_ACCOUNT_ID    OUT NOCOPY NUMBER,
		--ap_bank_account_id 'Shared' or dummy_bank_account_id 'XTRonly'
		P_RESULT             OUT NOCOPY VARCHAR2,-- 'PASS' or 'FAIL'
		P_ERROR_MSG          OUT NOCOPY VARCHAR2) is


      l_dummy          NUMBER;
      l_company        XTR_PARTY_INFO.PARTY_CODE%TYPE;
      l_auth_flag      VARCHAR2(1);
      l_acct_no        XTR_BANK_ACCOUNTS.ACCOUNT_NUMBER%TYPE;
      l_dummy_ap_acct  NUMBER;

      /*-----------------------------------------------------------------------------------*/
      /*  To check for ORG_ID and AP_BANK_ACCOUNT_ID combination                           */
      /*-----------------------------------------------------------------------------------*/

      cursor FIND_AP_ACCT_ID is         -- (1) To check for 'Shared' with this P_AP_BANK_ACCOUNT_ID
      select 1
      from   xtr_bank_accounts
      where  ce_bank_account_id = P_ce_bank_account_id
      and    ce_bank_account_id is not null;

      cursor GET_COMPANY is             -- (2) To check for valid company ORG_ID
      select xp.PARTY_CODE COMPANY_CODE
      from   XTR_PARTY_INFO xp
      where xp.legal_entity_id = P_ORG_ID;       -- bug 3862743


      cursor CHK_USER_ACCESS is         -- (3) To check for user access to company
      select 1
      from   XTR_PARTIES_V
      where  party_code = l_company;

      Cursor CHK_AUTH_ACCT IS           -- (4) To check for ORG_ID and AP_BANK_ID combination
      select b.authorised,              -- (5) To check for Authorised Account
             b.account_number
      from   xtr_bank_accounts  b,
	     xtr_party_info     p
      where  b.ce_bank_account_id  = P_ce_bank_account_id
      and    b.ce_bank_account_id is not null
      and    b.currency            = P_CURRENCY
      and    p.party_code          = b.party_code
      and    p.party_type          = b.party_type
      and    p.legal_entity_id     = P_ORG_ID;       -- bug 3862743

      /*-----------------------------------------------------------------------------------*/
      /*  To check for valid Bank Account Number                                           */
      /*-----------------------------------------------------------------------------------*/
      Cursor CHK_UNIQUE_ACCT IS           -- (a) To check for a single authorised account
      select authorised,
             party_code,
             ce_bank_account_id
      from   xtr_bank_accounts
      where  account_number      = P_ACCOUNT_NUMBER
      and    currency            = P_CURRENCY
      order by authorised desc;   -- so 'Y' comes before 'N'

BEGIN

   P_BANK_ACCOUNT_ID := null;
   P_ERROR_MSG       := null;
   P_RESULT          := null;

   /*------------------------------------------------------------------*/
   /*  Checks Header Account Information: ORG_ID + ce_bank_account_id  */
   /*------------------------------------------------------------------*/
   if P_ORG_ID is not null and P_ce_bank_account_id is not null then

      open  FIND_AP_ACCT_ID;
      fetch FIND_AP_ACCT_ID into l_dummy;
      if FIND_AP_ACCT_ID%NOTFOUND then
         /*--------------------------------------------*/
         /* AP Acct is not setup as a Shared acct.     */
         /*--------------------------------------------*/
         P_RESULT   := 'FAIL';
         FND_MESSAGE.SET_NAME('XTR','XTR_NOT_AP_XTR_SHARED');  -- new message **************************************************************
         FND_MESSAGE.SET_TOKEN('P_AP_ACCOUNT_ID', P_ce_bank_account_id);
         FND_MESSAGE.SET_TOKEN('P_CURRENCY', P_CURRENCY);

      else

         open  GET_COMPANY;
         fetch GET_COMPANY into l_company;
         if GET_COMPANY%NOTFOUND then
            /*--------------------------------------------*/
            /* ORG_ID not setup as Company in Treasury.   */
            /*--------------------------------------------*/
            -- A company that corresponds to the legal entity for Org. ID P_ORG_ID is not set up in Treasury.
            P_RESULT   := 'FAIL';
            FND_MESSAGE.SET_NAME('XTR','XTR_BANK_BAL_INV_COMP');
            FND_MESSAGE.SET_TOKEN('P_ORG_ID',P_ORG_ID);

         else

            open  CHK_USER_ACCESS;
            fetch CHK_USER_ACCESS into l_dummy;
            if CHK_USER_ACCESS%NOTFOUND then
               /*--------------------------------------------*/
               /*   Unauthorised User for this Company       */
               /*--------------------------------------------*/
               -- The user does not have the authority to access the company P_COMPANY.
               P_RESULT   := 'FAIL';
               FND_MESSAGE.SET_NAME('XTR','XTR_BANK_BAL_COMP_AUTH');
               FND_MESSAGE.SET_TOKEN('P_COMPANY',l_company);

            else

               open  CHK_AUTH_ACCT;
               fetch CHK_AUTH_ACCT into l_auth_flag, l_acct_no;
               if CHK_AUTH_ACCT%NOTFOUND then
                  /*------------------------------------------------*/
                  /* Wrong Org_id and AP_Bank_Account combination   */
                  /*------------------------------------------------*/
                  P_RESULT   := 'FAIL';
                  FND_MESSAGE.SET_NAME('XTR','XTR_INVALID_ORG_ACCT');  -- new message *******************************************************
                  FND_MESSAGE.SET_TOKEN('P_ORG_ID',P_ORG_ID);
                  FND_MESSAGE.SET_TOKEN('P_ACCOUNT_ID',P_ce_bank_account_id);

               else
                  if nvl(l_auth_flag,'N') = 'N' then
                     /*--------------------------------------*/
                     /* Account is not authorised for use.   */
                     /*--------------------------------------*/
                     -- The bank account P_ACCOUNT is not authorized in Treasury.
                     P_RESULT   := 'FAIL';
                     FND_MESSAGE.SET_NAME('XTR','XTR_BANK_BAL_ACCT_AUTH');
                     FND_MESSAGE.SET_TOKEN('P_ACCOUNT',l_acct_no);

                  else
                     /*--------------------------------------*/
                     /* AP/XTR Shared account.               */
                     /*--------------------------------------*/
                     P_RESULT   := 'PASS';
                  end if;

               end if;
               close CHK_AUTH_ACCT;

            end if;
            close CHK_USER_ACCESS;

         end if;
         close GET_COMPANY;

      end if;
      close FIND_AP_ACCT_ID;

   elsif P_ACCOUNT_NUMBER is not null then

      open  CHK_UNIQUE_ACCT;
      fetch CHK_UNIQUE_ACCT into l_auth_flag, l_company, l_dummy_ap_acct;
      if CHK_UNIQUE_ACCT%NOTFOUND then
         /*--------------------------------------------*/
         /* Account Number does not exist in Treasury  */
         /*--------------------------------------------*/
         P_RESULT   := 'FAIL';
         FND_MESSAGE.SET_NAME('XTR','XTR_ACCT_NOT_SETUP');  -- new message ******************************************************************
         FND_MESSAGE.SET_TOKEN('P_ACCOUNT_NO',P_ACCOUNT_NUMBER);
         FND_MESSAGE.SET_TOKEN('P_CURRENCY',P_CURRENCY);

      else
         if a_comp(l_company) then
            open  CHK_USER_ACCESS;
            fetch CHK_USER_ACCESS into l_dummy;
            if CHK_USER_ACCESS%NOTFOUND then
               /*--------------------------------------------*/
               /*   Unauthorised User for this Company       */
               /*--------------------------------------------*/
               -- The user does not have the authority to access the company P_COMPANY.
               P_RESULT   := 'FAIL';
               FND_MESSAGE.SET_NAME('XTR','XTR_BANK_BAL_COMP_AUTH');
               FND_MESSAGE.SET_TOKEN('P_COMPANY',l_company);
            end if;
            close  CHK_USER_ACCESS;
         end if;

         if nvl(P_RESULT,'N') <> 'FAIL' then
            if nvl(l_auth_flag,'N') = 'N' then
               /*--------------------------------------*/
               /* Account is not authorised for use.   */
               /*--------------------------------------*/
               -- The bank account P_ACCOUNT is not authorized in Treasury.
               P_RESULT   := 'FAIL';
               FND_MESSAGE.SET_NAME('XTR','XTR_BANK_BAL_ACCT_AUTH');
               FND_MESSAGE.SET_TOKEN('P_ACCOUNT',P_ACCOUNT_NUMBER);

            else
               P_BANK_ACCOUNT_ID := l_dummy_ap_acct;
               fetch CHK_UNIQUE_ACCT into l_auth_flag, l_company, l_dummy_ap_acct;
               if CHK_UNIQUE_ACCT%FOUND then
                  /*--------------------------------------*/
                  /* Duplicate Account is found.          */
                  /*--------------------------------------*/
                  P_BANK_ACCOUNT_ID := null;
                  P_RESULT          := 'FAIL';
                  FND_MESSAGE.SET_NAME('XTR','XTR_DUPLICATE_ACCOUNT');  -- new message ******************************************************
                  FND_MESSAGE.SET_TOKEN('P_ACCOUNT_NUMBER',P_ACCOUNT_NUMBER);
                  FND_MESSAGE.SET_TOKEN('P_CURRENCY',P_CURRENCY);

               else
                  P_RESULT := 'PASS';
               end if;

            end if;  -- l_auth_flag = 'N'
         end if;  -- P_RESULT <> FAIL

      end if;
      close CHK_UNIQUE_ACCT;

   else
      P_RESULT   := 'FAIL';
      FND_MESSAGE.SET_NAME('XTR','XTR_IMPORT_UNEXPECTED_ERROR');  -- existing message ****************************************************

   end if;  -- P_ORG_ID + P_AP_BANK_ACCOUNT_ID not null


   if P_RESULT = 'FAIL' then
      P_ERROR_MSG := FND_MESSAGE.GET;
   end if;

END ZBA_BANK_ACCOUNT_VERIFICATION;


-----------------------------------------------------------------------------------------------------
--  3800146
--  This procedure is a copy of FIND_INT_RATE in XTRINING.fmb. If procedure is called from BAL block,
--  that is deal management window, it uses the following logic.
--
--  Procedure to find the applicable interest rate from interest rate ranges for this account.
--  Seach for specific rate defined for company party currency combination.  If found, go for it.
--  If not found, then search for global rate defined for company party currency combination.
--  If found go for it.  If not found, then return null.
-----------------------------------------------------------------------------------------------------
PROCEDURE FIND_SPECIFIC_GLOBAL_RATE (
			p_company_code     IN VARCHAR2,
			p_party_code       IN VARCHAR2,
			p_currency         IN VARCHAR2,
			p_balance_out      IN NUMBER,
			p_principal_adjust IN NUMBER,
			p_transfer_date    IN DATE,
			p_block            IN VARCHAR2,
			p_ref_code         IN VARCHAR2,
			-- currently only 'IG_PRO1075' is used
			p_interest_rate    OUT NOCOPY NUMBER,
			-- currently only design as OUT param
			p_warn_message     OUT NOCOPY VARCHAR2) is
--
   cursor FIND_SPECIFIC_RATE is
   select INTEREST_RATE
     from xtr_INTEREST_RATE_RANGES_v
    where PARTY_CODE = p_party_code
      and CURRENCY   = nvl(p_currency,CURRENCY)
      and REF_CODE   = p_ref_code  -- 'IG_PRO1075'
      and MIN_AMT    < to_number(p_balance_out)
      and MAX_AMT   >= to_number(p_balance_out)
      and EFFECTIVE_FROM_DATE = (select max(EFFECTIVE_FROM_DATE)
                                   from xtr_INTEREST_RATE_RANGES_v
                                  where PARTY_CODE  = p_PARTY_CODE
                                    and CURRENCY    = nvl(p_CURRENCY,CURRENCY)
                                    and REF_CODE    = p_ref_code  -- 'IG_PRO1075'
                                    and MIN_AMT     < to_number(p_BALANCE_OUT)
                                    and MAX_AMT    >= to_number(p_BALANCE_OUT)
                                    and EFFECTIVE_FROM_DATE <= p_TRANSFER_DATE );

   cursor FIND_GLOBAL_RATE is
   select INTEREST_RATE
     from xtr_INTEREST_RATE_RANGES_v
    where PARTY_CODE = p_COMPANY_CODE
      and CURRENCY   = nvl(p_CURRENCY,CURRENCY)
      and REF_CODE   = p_ref_code  -- 'IG_PRO1075'
      and MIN_AMT    < p_BALANCE_OUT
      and MAX_AMT   >= p_BALANCE_OUT
      and EFFECTIVE_FROM_DATE = (select max(EFFECTIVE_FROM_DATE)
                                   from xtr_INTEREST_RATE_RANGES_v
                                  where EFFECTIVE_FROM_DATE <= p_TRANSFER_DATE
                                    and PARTY_CODE = p_COMPANY_CODE
                                    and CURRENCY   = nvl(p_CURRENCY,CURRENCY)
                                    and REF_CODE   = p_ref_code  -- 'IG_PRO1075'
                                    and MIN_AMT    < p_BALANCE_OUT
                                    and MAX_AMT   >= p_BALANCE_OUT);
   --
    --
   cursor DR_RANGE(p_party varchar2) is
   select nvl(INTEREST_RATE,0)
     from xtr_INTEREST_RATE_RANGES_v
    where PARTY_CODE = p_party
      and CURRENCY   = nvl(p_CURRENCY,CURRENCY)
      and REF_CODE   = p_ref_code  -- 'IG_PRO1075'
      and MAX_AMT   >= p_BALANCE_OUT
      and MIN_AMT   <= 0
      and MIN_AMT    < 0
      and EFFECTIVE_FROM_DATE = (select max(EFFECTIVE_FROM_DATE)
                                   from xtr_INTEREST_RATE_RANGES_v
                                  where EFFECTIVE_FROM_DATE <= p_TRANSFER_DATE
                                    and PARTY_CODE = p_party
                                    and CURRENCY   = nvl(p_CURRENCY,CURRENCY)
                                    and REF_CODE   = p_ref_code  -- 'IG_PRO1075'
                                    and MAX_AMT   >= p_BALANCE_OUT
                                    and MIN_AMT   <= 0
                                    and MIN_AMT    < 0 )
   order by MAX_AMT asc;
 --

   cursor CR_RANGE(p_party varchar2) is
   select nvl(INTEREST_RATE,0)
     from xtr_INTEREST_RATE_RANGES_v
    where PARTY_CODE = p_party
      and CURRENCY   = nvl(p_CURRENCY,CURRENCY)
      and REF_CODE   = p_ref_code  -- 'IG_PRO1075'
      and MIN_AMT   <= p_BALANCE_OUT
      and MAX_AMT   >= 0
      and MIN_AMT   >= 0
      and EFFECTIVE_FROM_DATE = (select max(EFFECTIVE_FROM_DATE)
                                   from xtr_INTEREST_RATE_RANGES_v
                                  where EFFECTIVE_FROM_DATE <= p_TRANSFER_DATE
                                    and PARTY_CODE           = p_party
                                    and CURRENCY             = nvl(p_CURRENCY,CURRENCY)
                                    and REF_CODE             = p_ref_code  -- 'IG_PRO1075'
                                    and MIN_AMT             <= p_BALANCE_OUT
                                    and MAX_AMT             >= 0
                                    and MIN_AMT             >= 0)
   order by MIN_AMT desc;
--

BEGIN

   p_interest_rate := null;
   p_warn_message  := null;

   if p_PRINCIPAL_ADJUST is not null then
      ----------------------------------------------------------------------------------
      -- Find Specific Rate
      ----------------------------------------------------------------------------------
      open  FIND_SPECIFIC_RATE;
      fetch FIND_SPECIFIC_RATE INTO p_INTEREST_RATE;
      if FIND_SPECIFIC_RATE%NOTFOUND then
         close FIND_SPECIFIC_RATE;
         p_INTEREST_RATE := null;
         If p_block = 'IG' then
            if nvl(p_BALANCE_OUT,0)<=0 then
               open  DR_RANGE(p_PARTY_CODE);
               fetch DR_RANGE into p_INTEREST_RATE;
               close DR_RANGE;
            else
               open  CR_RANGE(p_PARTY_CODE);
               fetch CR_RANGE into p_INTEREST_RATE;
               close CR_RANGE;
            end if;
         End if;

         ----------------------------------------------------------------------------------
         -- Find Global Rate
         ----------------------------------------------------------------------------------
         if p_INTEREST_RATE is null then
            open  FIND_GLOBAL_RATE;
            fetch FIND_GLOBAL_RATE INTO p_INTEREST_RATE;
            if FIND_GLOBAL_RATE%NOTFOUND then
               close FIND_GLOBAL_RATE;
               p_INTEREST_RATE := null;
               If p_block = 'IG' then
                  if nvl(p_BALANCE_OUT,0)<=0 then
                     open  DR_RANGE(p_COMPANY_CODE);
                     fetch DR_RANGE into p_INTEREST_RATE;
                     close DR_RANGE;
                  else
                     open  CR_RANGE(p_COMPANY_CODE);
                     fetch CR_RANGE into p_INTEREST_RATE;
                     close CR_RANGE;
                  end if;
               End if;

               If p_block = 'IG' and p_INTEREST_RATE is null then
                  p_warn_message  := 'XTR_542';  -- Cannot find an Interest Rate for this Account
                  p_interest_rate := null;
               End if;

            else
               close FIND_GLOBAL_RATE;
            end if;
         end if;

      else
         close FIND_SPECIFIC_RATE;
      end if;
   end if;

END FIND_SPECIFIC_GLOBAL_RATE;


--------------------------------------------------------------------------------------------------------------
-- 3800146 This procedure is used by Cash Leveling and ZBA processes to derive info for latest IG transaction
--------------------------------------------------------------------------------------------------------------
PROCEDURE DERIVE_LATEST_TRAN (p_company_code     IN  VARCHAR2,
                              p_party_code       IN  VARCHAR2,
                              p_currency         IN  VARCHAR2,
                              p_transfer_date    IN  DATE,
                              p_principal_adjust IN  NUMBER,
                              p_principal_action IN  VARCHAR2,
                              p_interest_rate    OUT NOCOPY NUMBER,
                              p_rounding_type    OUT NOCOPY VARCHAR2,
                              p_day_count_type   OUT NOCOPY VARCHAR2,
                              p_pricing_model    OUT NOCOPY VARCHAR2,
                              p_balance_out      OUT NOCOPY NUMBER ) is
				-- currently only design as OUT param

   ----------------------------------
   -- Find latest IG transaction info
   ----------------------------------
   cursor FIND_LATEST_TRAN is
   select INTEREST_RATE,
          ROUNDING_TYPE,
          DAY_COUNT_TYPE,
          PRICING_MODEL,
          BALANCE_OUT                       -- not BALANCE_BF
         ,deal_number, transaction_number   -- not used
   from   xtr_intergroup_transfers_v
   where  company_code   = p_company_code
   and    party_code     = p_party_code
   and    currency       = p_currency
   and    transfer_date <= p_transfer_date
   order by TRANSFER_DATE desc, TRANSACTION_NUMBER desc;

   l_prv_bal_out NUMBER;
   l_deal_no     NUMBER;
   l_tran_no     NUMBER;

BEGIN

   p_interest_rate   := null;
   p_rounding_type   := null;
   p_day_count_type  := null;
   p_pricing_model   := null;
   p_balance_out     := null;
   l_deal_no         := null;
   l_tran_no         := null;

   -------------------------------------------
   -- Find latest tran details and BALANCE_BF
   -------------------------------------------
   open  FIND_LATEST_TRAN;
   fetch FIND_LATEST_TRAN into p_interest_rate, p_rounding_type, p_day_count_type, p_pricing_model, l_prv_bal_out, l_deal_no, l_tran_no;
   if FIND_LATEST_TRAN%NOTFOUND then
      l_prv_bal_out := 0;
   end if;
   close FIND_LATEST_TRAN;

   -------------------------------------------
   -- Calculate BALANCE_OUT
   -------------------------------------------
   if p_principal_adjust is NOT NULL then
      if p_PRINCIPAL_ACTION = 'PAY' then
         p_balance_out := l_prv_bal_out + p_principal_adjust;
      elsif p_PRINCIPAL_ACTION = 'REC' then
         p_balance_out := l_prv_bal_out - p_principal_adjust;
      end if;
   else
      p_balance_out := l_prv_bal_out;
   end if;

   --dbms_output.put_line('wrap   derive l_DEAL_NO             = '||l_deal_no);
   --dbms_output.put_line('wrap   derive l_TRAN_NO             = '||l_tran_no);
   --dbms_output.put_line('wrap   derive NEW BALANCE OUT       = '||p_balance_out);

END DERIVE_LATEST_TRAN;


-------------------------------------------------------------------------------------
-- 3800146  API to default values for by ZBA and Cash Leveling for IG transactions
-------------------------------------------------------------------------------------
PROCEDURE IG_ZBA_CL_DEFAULT (p_company_code               IN  VARCHAR2,
                             p_intercompany_code          IN  VARCHAR2,
                             p_currency                   IN  VARCHAR2,
                             p_transfer_date              IN  DATE,
                             p_transfer_amount            IN  NUMBER,
                             p_action_code                IN  VARCHAR2,
                             p_interest_rounding          IN  VARCHAR2,
                             p_interest_includes          IN  VARCHAR2,
                             p_company_pricing_model      IN  VARCHAR2,
                             p_intercompany_pricing_model IN  VARCHAR2,
                             l_interest_rate              OUT NOCOPY NUMBER,
                             l_rounding_type              OUT NOCOPY VARCHAR2,
                             l_day_count_type             OUT NOCOPY VARCHAR2,
                             l_pricing_model              OUT NOCOPY VARCHAR2,
                             l_mirror_pricing_model       OUT NOCOPY VARCHAR2)
			     IS   -- pass to IG API

   l_balance_out      NUMBER;
   l_dummy_num        NUMBER;
   l_dummy_char1      xtr_intergroup_transfers.rounding_type%TYPE;
   l_dummy_char2      xtr_intergroup_transfers.day_count_type%TYPE;
   l_specific_global  NUMBER;
   l_dummy_msg        VARCHAR2(30);
   l_mirror_action    VARCHAR2(3);

BEGIN
      --******************************************************************************************************
      -- Derive latest transaction details
      --******************************************************************************************************
      l_interest_rate        := null;
      l_rounding_type        := null;
      l_day_count_type       := null;
      l_pricing_model        := null;
      l_mirror_pricing_model := null;

      DERIVE_LATEST_TRAN (p_company_code,  -- Main IG
                          p_intercompany_code,
                          p_currency,
                          p_transfer_date,
                          p_transfer_amount,
                          p_action_code,
                          l_interest_rate,
                          l_rounding_type,
                          l_day_count_type,
                          l_pricing_model,
                          l_balance_out);

                          --dbms_output.put_line('wrap   derive main l_pricing_model  = '||l_pricing_model);
                          --dbms_output.put_line('wrap   derive main l_interest_rate  = '||l_interest_rate);
                          --dbms_output.put_line('wrap   derive main l_rounding_type  = '||l_rounding_type);
                          --dbms_output.put_line('wrap   derive main l_day_count_type = '||l_day_count_type);
                          --dbms_output.put_line('wrap   derive main l_balance_out    = '||l_balance_out);
                          --dbms_output.put_line('--------------------------------------------------------');

      ------------------------------------------
      -- For new deals only
      ------------------------------------------
      if l_rounding_type is null then
         l_rounding_type  := p_interest_rounding;      -- from Cash Pool ID
         l_day_count_type := p_interest_includes;      -- from Cash Pool ID
         l_pricing_model  := p_company_pricing_model;  -- from Cash Pool ID
         --dbms_output.put_line ('wrap   Default Rounding, Day Count, Pricing');
      end if;

      -------------------------
      -- Find transaction rates
      -------------------------
      l_specific_global := null;

      FIND_SPECIFIC_GLOBAL_RATE (p_company_code,
                                 p_intercompany_code,
                                 p_currency,
                                 l_balance_out,
                                 p_transfer_amount,
                                 p_transfer_date,
                                 null,               -- block name
                                 G_rate_ref_code,    -- currently only 'IG_PRO1075' is used
                                 l_specific_global,  -- currently only design as OUT param
                                 l_dummy_msg);       -- no need message for ZBA/CL
      if l_specific_global is not null then  -- Found specific/global rate
         l_interest_rate := l_specific_global;
      elsif l_interest_rate is null then     -- Latest transaction does not exists
         l_interest_rate := 0;
      end if;

      --dbms_output.put_line('wrap   derive NEW  Spec/Glob/Tran   = '||l_interest_rate);
      --dbms_output.put_line('--------------------------------------------------------');

      --******************************************************************************************************
      -- Find mirror deal's pricing model
      --******************************************************************************************************
      if XTR_IG_TRANSFERS_PKG.is_company(p_intercompany_code) then
         if p_action_code = 'PAY' then
            l_mirror_action := 'REC';
         else
            l_mirror_action := 'PAY';
         end if;
         DERIVE_LATEST_TRAN (p_intercompany_code,  -- Mirror IG
                             p_company_code,
                             p_currency,
                             p_transfer_date,
                             p_transfer_amount,
                             l_mirror_action,
                             l_dummy_num,           -- Same as main deal. Don't find rate again
                             l_dummy_char1,         -- Same as main deal. Don't find ROUNDING_TYPE
                             l_dummy_char2,         -- Same as main deal. Don't find DAY_COUNT_TYPE
                             l_mirror_pricing_model,-- Latest transaction's PRICING_MODEL
                             l_dummy_num);          -- Don't find balance_out again
         if l_mirror_pricing_model is null then
            l_mirror_pricing_model := p_intercompany_pricing_model;  -- from Cash Pool ID
         end if;

         --dbms_output.put_line('wrap   derive MORR l_mirror_pricing = '||l_mirror_pricing_model);
         --dbms_output.put_line('--------------------------------------------------------');

      end if;

END IG_ZBA_CL_DEFAULT;

-------------------------------------------------------------------------------------
-- 3800146 Check for IG duplicate for ZBA only
-------------------------------------------------------------------------------------
PROCEDURE CHK_ZBA_IG_DUPLICATE (
			     p_company_code              IN  VARCHAR2,
                             p_intercompany_code         IN  VARCHAR2,
                             p_currency                  IN  VARCHAR2,
                             p_transfer_amount           IN  NUMBER,
                             p_transfer_date             IN  DATE,
                             p_action_code               IN  VARCHAR2,
                             p_company_portfolio         IN  VARCHAR2,
                             p_company_product_type      IN  VARCHAR2,
                             p_intercompany_portfolio    IN  VARCHAR2,
                             p_intercompany_product_type IN  VARCHAR2,
                             p_company_account_no        IN  VARCHAR2,
                             p_party_account_no          IN  VARCHAR2,
                             p_zba_duplicate             OUT NOCOPY BOOLEAN) IS

      l_deal_no       NUMBER;
      l_tran_no       NUMBER;
      l_mirror_action VARCHAR2(10);

      -------------------------------------------------
      -- 3800146 Local procedure to Check IG Duplicate
      -------------------------------------------------
      PROCEDURE CHECK_IG_DUPLICATE (l_company_code        IN  VARCHAR2,
                                    l_party_code          IN  VARCHAR2,
                                    l_currency            IN  VARCHAR2,
                                    l_principal_adjust    IN  NUMBER,
                                    l_transfer_date       IN  DATE,
                                    l_principal_action    IN  VARCHAR2,
                                    l_portfolio           IN  VARCHAR2,
                                    l_product_type        IN  VARCHAR2,
                                    l_company_account_no  IN  VARCHAR2,
                                    l_party_account_no    IN  VARCHAR2,
                                    l_deal_num            OUT NOCOPY NUMBER,
                                    l_tran_num            OUT NOCOPY NUMBER,
                                    l_duplicate           OUT NOCOPY BOOLEAN) IS

         cursor find_ig_deal is
         select deal_number,
                transaction_number
         from   xtr_intergroup_transfers
         where  company_code       = l_company_code
         and    party_code         = l_party_code
         and    currency           = l_currency
         and    principal_adjust   = l_principal_adjust
         and    transfer_date      = l_transfer_date
         and    principal_action   = l_principal_action
         and    portfolio          = l_portfolio
         and    product_type       = l_product_type
         and    company_account_no = l_company_account_no
         and    party_account_no   = l_party_account_no
	 and	external_source    = 'ZBA'
         order by transfer_date desc, transaction_number desc;
	 /* Bug 4231200 Added the last AND condition. */

         cursor chk_reconcile (l_amt_type VARCHAR2)  is
         select 1
         from   xtr_deal_date_amounts
         where  deal_number        = l_deal_num
         and    transaction_number = l_tran_num
         and    amount_type        = l_amt_type
         and    nvl(cashflow_amount,0) <> 0
         and    reconciled_reference is null;
	 /* Bug 4231200 Changed the last condition to null from not null. */

         l_dummy    NUMBER := null;

      BEGIN

         l_deal_num := null;
         l_tran_num := null;
         open  find_ig_deal;
         fetch find_ig_deal into l_deal_num, l_tran_num;
         close find_ig_deal;

         if l_deal_num is not null then
            open  chk_reconcile ('PRINFLW');
            fetch chk_reconcile into l_dummy;
            if chk_reconcile%FOUND then
               l_duplicate := TRUE;
            else
               l_duplicate := FALSE;
            end if;
            close chk_reconcile;
         else
            l_duplicate := FALSE;
         end if;

      END CHECK_IG_DUPLICATE;

BEGIN
      --******************************************************************************************************
      -- Checks main deal duplicate
      --******************************************************************************************************
      CHECK_IG_DUPLICATE (p_company_code,
                          p_intercompany_code,
                          p_currency,
                          p_transfer_amount,
                          p_transfer_date,
                          p_action_code,
                          p_company_portfolio,
                          p_company_product_type,
                          p_company_account_no,
                          p_party_account_no,
                          l_deal_no,
                          l_tran_no,
                          p_zba_duplicate);

      if p_zba_duplicate then
         fnd_message.set_name ('XTR','XTR_DUPLICATE_ZBA_CL');
         fnd_message.set_token ('DEAL_TYPE','IG');
         fnd_message.set_token ('DEAL_NUMBER',l_deal_no);
         fnd_message.set_token ('TRANSACTION_NUMBER',l_tran_no);
         fnd_msg_pub.add;
         --dbms_output.put_line('wrap   XTR_DUPLICATE_ZBA_CL = C1');

      else

         --******************************************************************************************************
         -- Checks Mirror company duplicate if party is a company
         --******************************************************************************************************
         if XTR_IG_TRANSFERS_PKG.is_company(p_intercompany_code) then

            if p_action_code = 'PAY' then
               l_mirror_action := 'REC';
            else
               l_mirror_action := 'PAY';
            end if;
            CHECK_IG_DUPLICATE (p_intercompany_code,
                                p_company_code,
                                p_currency,
                                p_transfer_amount,
                                p_transfer_date,
                                l_mirror_action,
                                p_intercompany_portfolio,
                                p_intercompany_product_type,
                                p_party_account_no,
                                p_company_account_no,
                                l_deal_no,
                                l_tran_no,
                                p_zba_duplicate);

            if p_zba_duplicate then
               fnd_message.set_name ('XTR','XTR_DUPLICATE_ZBA_CL');
               fnd_message.set_token ('DEAL_TYPE','IG');
               fnd_message.set_token ('DEAL_NUMBER',l_deal_no);
               fnd_message.set_token ('TRANSACTION_NUMBER',l_tran_no);
               fnd_msg_pub.add;
               --dbms_output.put_line('wrap   XTR_DUPLICATE_ZBA_CL = C2');
            end if;

         end if;  -- mirror duplicate check

      end if; -- main duplicate check

END CHK_ZBA_IG_DUPLICATE;


-------------------------------------------------
-- 3800146 Check for IAC duplicate for ZBA only
-------------------------------------------------
PROCEDURE CHK_ZBA_IAC_DUPLICATE (l_company_code      IN  VARCHAR2,
                                 l_transfer_amount   IN  NUMBER,
                                 l_transfer_date     IN  DATE,
                                 l_from_account_no   IN  VARCHAR2,
                                 l_to_account_no     IN  VARCHAR2,
                                 l_portfolio         IN  VARCHAR2,
                                 l_product_type      IN  VARCHAR2,
                                 l_duplicate         OUT NOCOPY BOOLEAN) IS

      l_tran_num NUMBER := null;

      cursor chk_reconcile (l_deal_type VARCHAR2) is
      select A.transaction_number
      from   xtr_interacct_transfers A,
             xtr_deal_date_amounts   B,
             xtr_deal_date_amounts   C
      where  A.company_code       = l_company_code
      and    A.transfer_amount    = l_transfer_amount
      and    A.transfer_date      = l_transfer_date
      and    A.portfolio_code     = l_portfolio
      and    A.product_type       = l_product_type
      and    A.account_no_from    = l_from_account_no
      and    A.account_no_to      = l_to_account_no
      and    A.external_source    = 'ZBA'
      and    B.deal_number        = 0
      and    B.transaction_number = A.transaction_number
      and    B.deal_type          = l_deal_type
      and    C.deal_number        = 0
      and    C.transaction_number = A.transaction_number
      and    C.deal_type          = l_deal_type
      and   (B.reconciled_reference is null or C.reconciled_reference is null);
      /* Bug 4231200. Added the condition to check for external source
	 and changed the last condition to null from not null. */

BEGIN

      --dbms_output.put_line('ZBA duplicate   = '||l_tran_num);

         open  chk_reconcile ('IAC');
         fetch chk_reconcile into l_tran_num;
         if chk_reconcile%FOUND then
            l_duplicate := TRUE;
            fnd_message.set_name ('XTR','XTR_DUPLICATE_ZBA_CL');
            fnd_message.set_token ('DEAL_TYPE','IAC');
            fnd_message.set_token ('DEAL_NUMBER',0);
            fnd_message.set_token ('TRANSACTION_NUMBER',l_tran_num);
            fnd_msg_pub.add;
            --dbms_output.put_line('wrap   XTR_DUPLICATE_ZBA_CL = C2');
         else
            l_duplicate := FALSE;
         end if;
         close chk_reconcile;

END CHK_ZBA_IAC_DUPLICATE;


-------------------------------------------------------------------------------------------------------------------
-- 3800146 This procedure checks if a party is a company regardless of user access
-------------------------------------------------------------------------------------------------------------------
FUNCTION A_COMP (l_comp IN VARCHAR2) return boolean is
      cursor cur_com is
      select 1
      from   XTR_PARTY_INFO
      where  party_code = l_comp
      and    party_type = 'C';
      l_dummy NUMBER;
BEGIN
      open  cur_com;
      fetch cur_com into l_dummy;
      if cur_com%NOTFOUND then
         close cur_com;
         return FALSE;
      end if;
      close cur_com;
      return TRUE;
END A_COMP;

----------------------------------------------------------------------------------------------------------
-- 3800146 Derive IG values from Cash Pool
----------------------------------------------------------------------------------------------------------
PROCEDURE IG_CASHPOOL_DERIVE (
			p_cash_pool_id                IN  NUMBER,
                        p_company_bank_id             IN  NUMBER,
                        p_party_bank_id               IN  NUMBER,
                        p_currency                    IN  VARCHAR2,
                        p_company_code                OUT NOCOPY VARCHAR2,
                        p_company_account_no          OUT NOCOPY VARCHAR2,
                        p_company_rounding_type       OUT NOCOPY VARCHAR2,
                        p_company_day_count_type      OUT NOCOPY VARCHAR2,
                        p_company_pricing_model       OUT NOCOPY VARCHAR2,
                        p_company_product_type        OUT NOCOPY VARCHAR2,
                        p_company_portfolio           OUT NOCOPY VARCHAR2,
                        p_company_fund_limit          OUT NOCOPY VARCHAR2,
                        p_company_inv_limit           OUT NOCOPY VARCHAR2,
                        p_company_dealer              OUT NOCOPY VARCHAR2,
                        p_intercompany_code           OUT NOCOPY VARCHAR2,
                        p_intercompany_account_no     OUT NOCOPY VARCHAR2,
                        p_intercompany_pricing_model  OUT NOCOPY VARCHAR2,
                        p_intercompany_product_type   OUT NOCOPY VARCHAR2,
                        p_intercompany_portfolio      OUT NOCOPY VARCHAR2,
                        p_intercompany_fund_limit     OUT NOCOPY VARCHAR2,
                        p_intercompany_inv_limit      OUT NOCOPY VARCHAR2,
                        p_intercompany_dealer         OUT NOCOPY VARCHAR2) IS

   cursor get_company (l_cashpool_id NUMBER, l_ccy VARCHAR2) is
   select PARTY_CODE
   from   ce_cashpools
   where  cashpool_id   = l_cashpool_id
   and    currency_code = l_ccy;

   cursor get_intercompany (l_cashpool_id NUMBER, l_party_bank_id NUMBER) is
   select PARTY_CODE
   from   ce_cashpool_sub_accts
   where  cashpool_id = l_cashpool_id
   and    account_id  = l_party_bank_id;

   cursor get_attributes (l_cashpool_id NUMBER, l_intercomp_code VARCHAR2) is
   select rounding_type,     day_count_type,        pricing_model,
          product_type,      portfolio,             fund_limit_code,
          invest_limit_code, party_pricing_model,   party_product_type,
          party_portfolio,   party_fund_limit_code, party_invest_limit_code
   from   xtr_cashpool_attributes
   where  cashpool_id = l_cashpool_id
   and    party_code  = l_intercomp_code;

   cursor get_acct_no (l_bank_id  NUMBER, l_ccy VARCHAR2, l_party VARCHAR2) is
   select account_number
   from   xtr_bank_accounts
   where  party_code = l_party
   and    currency   = l_ccy
   and    ce_bank_account_id = l_bank_id;

   cursor get_user (p_fnd_user in number) is
   select dealer_code
   from   xtr_dealer_codes_v
   where  user_id = p_fnd_user;

BEGIN

   open  get_company (p_cash_pool_id, p_currency);
   fetch get_company into p_company_code;
   close get_company;

   open  get_intercompany (p_cash_pool_id, p_party_bank_id);
   fetch get_intercompany into p_intercompany_code;
   close get_intercompany;

   open  get_attributes(p_cash_pool_id, p_intercompany_code);
   fetch get_attributes into p_company_rounding_type,  p_company_day_count_type,     p_company_pricing_model,
                             p_company_product_type,   p_company_portfolio,          p_company_fund_limit,
                             p_company_inv_limit,      p_intercompany_pricing_model, p_intercompany_product_type,
                             p_intercompany_portfolio, p_intercompany_fund_limit,    p_intercompany_inv_limit;
   close get_attributes;

   open  get_acct_no (p_company_bank_id, p_currency, p_company_code);
   fetch get_acct_no into p_company_account_no;
   close get_acct_no;

   open  get_acct_no (p_party_bank_id, p_currency, p_intercompany_code);
   fetch get_acct_no into p_intercompany_account_no;
   close get_acct_no;

   open  get_user(fnd_global.user_id);
   fetch get_user into p_company_dealer;
   close get_user;

   p_intercompany_dealer := p_company_dealer;

END IG_CASHPOOL_DERIVE;

----------------------------------------------------------------------------------------------------------
-- 3800146 Derive IAC values from Cash Pool
----------------------------------------------------------------------------------------------------------
PROCEDURE IAC_CASHPOOL_DERIVE(p_cash_pool_id             IN  NUMBER,
                              p_from_bank_id             IN  NUMBER,
                              p_to_bank_id               IN  NUMBER,
                           -- p_transfer_date            IN  DATE,
                              p_company_code             OUT NOCOPY VARCHAR2,
                              p_company_product_type     OUT NOCOPY VARCHAR2,
                              p_company_portfolio        OUT NOCOPY VARCHAR2,
                              p_account_no_from          OUT NOCOPY VARCHAR2,
                              p_account_no_to            OUT NOCOPY VARCHAR2,
                              p_currency                 OUT NOCOPY VARCHAR2) IS

   cursor get_company (l_cashpool_id NUMBER) is
   select party_code,
          currency_code
   from   ce_cashpools
   where  cashpool_id   = l_cashpool_id;

   cursor get_attributes (l_cashpool_id NUMBER) is
   select iac_product_type,
          iac_portfolio
   from   xtr_cashpool_attributes
   where  cashpool_id = l_cashpool_id
   and    product_type is null; -- Condition added Bug 4309871

   cursor get_acct_no (l_bank_id  NUMBER, l_ccy VARCHAR2, l_party VARCHAR2) is
   select account_number
   from   xtr_bank_accounts
   where  party_code = l_party
   and    currency   = l_ccy
   and    ce_bank_account_id = l_bank_id;

   l_ccy  xtr_bank_accounts.currency%TYPE;

BEGIN
   open  get_company (p_cash_pool_id);
   fetch get_company into p_company_code, p_currency;
   close get_company;

   open  get_attributes(p_cash_pool_id);
   fetch get_attributes into p_company_product_type, p_company_portfolio;
   close get_attributes;

   open  get_acct_no (p_from_bank_id, p_currency, p_company_code);
   fetch get_acct_no into p_account_no_from;
   close get_acct_no;

   open  get_acct_no (p_to_bank_id, p_currency, p_company_code);
   fetch get_acct_no into p_account_no_to;
   close get_acct_no;

END IAC_CASHPOOL_DERIVE;


-------------------------------------------------------------------------------------------------------------------
-- 3800146 This procedure derives the validate and settlement status of IAC when calling from ZBA and Cash Leveling
-------------------------------------------------------------------------------------------------------------------
PROCEDURE SET_IAC_VALIDATE_SETTLE(p_product          IN  VARCHAR2,
                                  p_dealer           IN  VARCHAR2,
                                  p_called_by_flag   IN  VARCHAR2,  -- null for form
                                  p_auth_validate    OUT NOCOPY BOOLEAN,
                                  p_auth_settlement  OUT NOCOPY BOOLEAN) is

   ---------------------------------------------------
   -- for IAC, get PRO_PARAM for auto-auth-settled IAC
   ---------------------------------------------------
   cursor c_param (l_name VARCHAR2) is
   select param_value
   from   xtr_pro_param
   where  param_name = l_name;

   l_validate_deal   VARCHAR2(1);
   l_validate_iac    VARCHAR2(1);
   l_iac_auto_settle VARCHAR2(1);

   FUNCTION user_authority (l_product VARCHAR2, l_dealer VARCHAR2) return BOOLEAN is
      Cursor user_auth is
      SELECT VALIDATION_AUTHORIZED
      FROM   XTR_AUTH_TYPE_SUBTYPE_PROD_V
      WHERE  USER_NAME    = l_DEALER
      AND    DEAL_TYPE    = 'IAC'
      AND    DEAL_SUBTYPE = 'FIRM'
      AND    PRODUCT_TYPE = l_PRODUCT;
      L_dummy VARCHAR2(1);
   BEGIN
      Open  user_auth;
      Fetch user_auth into l_dummy;
      If user_auth%FOUND and l_dummy = 'Y' then
         Close user_auth;
         Return TRUE;
      End if;
      Close user_auth;
      Return FALSE;
   END;

BEGIN
   open  c_param ('DUAL_AUTHORISE');
   fetch c_param into l_validate_deal;
   close c_param;

   open  c_param ('DUAL_AUTHORISE_IAC');
   fetch c_param into l_validate_iac;
   close c_param;

   open  c_param ('IAC_AUTO_SETTLE');
   fetch c_param into l_iac_auto_settle;
   close c_param;

   ----------------------------
   -- Initialise
   ----------------------------
   p_auth_validate    := FALSE;
   p_auth_settlement  := FALSE;

   IF nvl(p_called_by_flag,'N') = 'Z' THEN
      ---------------------------------------------
      -- Calling from ZBA is always settled for IAC
      ---------------------------------------------
      p_auth_settlement := TRUE;

      ------------------------------------------------------------
      -- Calling from ZBA doesnot require user access to validate
      ------------------------------------------------------------
      if nvl(l_validate_deal,'N') = 'Y' and nvl(l_validate_iac,'N') = 'Y' then
         p_auth_validate := TRUE;
      end if;

   ELSE
      ----------------------------------------------------------
      -- Calling from Cash Leveling and IAC form is conditional
      ----------------------------------------------------------
      if nvl(l_validate_iac,'N') = 'Y' then
         if nvl(l_iac_auto_settle,'N') = 'Y' and user_authority(p_PRODUCT, p_DEALER) then
            p_auth_validate   := TRUE;
            p_auth_settlement := TRUE;
         end if;
      else
         if nvl(l_iac_auto_settle,'N') = 'Y' then
            p_auth_settlement := TRUE;
         end if;
      end if;

   END IF;

END SET_IAC_VALIDATE_SETTLE;


------------------------------------------------------------------------------------------------------------------------------------------
-- 3800146 Main IG API called by ZBA and Cash Leveling
------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE IG_GENERATION(p_cash_pool_id               IN NUMBER,
                        p_company_bank_id            IN NUMBER,
                        p_party_bank_id              IN NUMBER,
                        p_currency                   IN VARCHAR2,
                        p_transfer_date              IN DATE,
                        p_transfer_amount            IN NUMBER,
                        p_action_code                IN VARCHAR2,
                        p_accept_limit_error         IN VARCHAR2,  -- see Override_limit on IG p.40
                        p_deal_no                    OUT NOCOPY NUMBER,
                        p_tran_no                    OUT NOCOPY NUMBER,
                        p_mirror_deal_no             OUT NOCOPY NUMBER,
                        p_mirror_tran_no             OUT NOCOPY NUMBER,
                        p_success_flag               OUT NOCOPY VARCHAR2,
                        p_process_flag               IN  VARCHAR2) is

   l_settled                 VARCHAR2(1);
   L_External_IG             xtr_deals_interface%rowtype;
   user_error                BOOLEAN;
   mandatory_error           BOOLEAN;
   validation_error          BOOLEAN;
   limit_error               BOOLEAN;
   l_ext_source              VARCHAR2(30);

   l_company_dealer              xtr_intergroup_transfers.dealer_code%TYPE;
   l_company_code                xtr_intergroup_transfers.company_code%TYPE;
   l_company_account_no          xtr_intergroup_transfers.company_account_no%TYPE;
   l_company_pricing_model       xtr_intergroup_transfers.pricing_model%TYPE;
   l_company_product_type        xtr_intergroup_transfers.product_type%TYPE;
   l_company_portfolio           xtr_intergroup_transfers.portfolio%TYPE;
   l_company_fund_limit          xtr_intergroup_transfers.limit_code%TYPE;
   l_company_inv_limit           xtr_intergroup_transfers.limit_code%TYPE;
   l_company_rounding_type       xtr_intergroup_transfers.rounding_type%TYPE;
   l_company_day_count_type      xtr_intergroup_transfers.day_count_type%TYPE;

   l_intercompany_code           xtr_intergroup_transfers.party_code%TYPE;
   l_intercompany_account_no     xtr_intergroup_transfers.party_account_no%TYPE;
   l_intercompany_pricing_model  xtr_intergroup_transfers.pricing_model%TYPE;
   l_intercompany_product_type   xtr_intergroup_transfers.product_type%TYPE;
   l_intercompany_portfolio      xtr_intergroup_transfers.portfolio%TYPE;
   l_intercompany_fund_limit     xtr_intergroup_transfers.limit_code%TYPE;
   l_intercompany_inv_limit      xtr_intergroup_transfers.limit_code%TYPE;
   l_intercompany_dealer         xtr_intergroup_transfers.dealer_code%TYPE;

   l_interest_rate               NUMBER;
   l_rounding_type               xtr_intergroup_transfers.rounding_type%TYPE;
   l_day_count_type              xtr_intergroup_transfers.day_count_type%TYPE;
   l_pricing_model               xtr_intergroup_transfers.pricing_model%TYPE;
   l_mirror_pricing_model        xtr_intergroup_transfers.pricing_model%TYPE;


/*---------------------------------------------------------------------------------------------------------------------------------------------
 1) Get parameters from CE
                           - derive ROUNDING, INCLUDES, PRICING MODEL, PRODUCT, PORTFOLIO, LIMITS, ACCOUNTS from CASH_POOL_ID so must be valid.
 2) Derive actual values before the creation of transaction BEFORE VALIDATION (need to check authorised values, etc)
                           - RATE, INTEREST ROUNDING, INTEREST INCLUDES, PRICING MODEL (calculated values must come after this)
 3) Validate from IG API   - do not do standard duplicate check from IG API
 4) Duplicate check        - must wait for actual derived values.
 5) Other calculated value - balance, hce amount, limit utilisation etc must come last.
---------------------------------------------------------------------------------------------------------------------------------------------*/
BEGIN

   p_deal_no        := null;
   p_tran_no        := null;
   p_mirror_deal_no := null;
   p_mirror_tran_no := null;
   p_success_flag   := null;

   fnd_msg_pub.initialize;

   --########################################################################################################################
   -- Derive the following with Cash Pool ID before calling default, etc:
   IG_CASHPOOL_DERIVE(p_cash_pool_id,
                      p_company_bank_id,
                      p_party_bank_id,
                      p_currency,
                      l_company_code,
                      l_company_account_no,
                      l_company_rounding_type,
                      l_company_day_count_type,
                      l_company_pricing_model,
                      l_company_product_type,
                      l_company_portfolio,
                      l_company_fund_limit,
                      l_company_inv_limit,
                      l_company_dealer,
                      l_intercompany_code,
                      l_intercompany_account_no,
                      l_intercompany_pricing_model,
                      l_intercompany_product_type,
                      l_intercompany_portfolio,
                      l_intercompany_fund_limit,
                      l_intercompany_inv_limit,
                      l_intercompany_dealer);
   --########################################################################################################################

      --------------------------------------------------------------------------------------------------------------------------
      -- 3800146
      --   1) Derive Interest Rounding, Day Count Type and Pricing Model from EXISTING TRANSACTIONS
      --   2) Before Validation and ANY calculation. (eg. if Pricing Model is unauthorised, then Error.)
      --      a) Rate  b) Rounding  c) Day Count  d) Pricing Model  e) Mirror Pricing
      --------------------------------------------------------------------------------------------------------------------------
      IG_ZBA_CL_DEFAULT (l_company_code,               -- from Pool ID
                         l_intercompany_code,          -- from Pool ID
                         p_currency,
                         p_transfer_date,
                         p_transfer_amount,
                         p_action_code,
                         l_company_rounding_type,      -- from Pool ID
                         l_company_day_count_type,     -- from Pool ID
                         l_company_pricing_model,      -- from Pool ID
                         l_intercompany_pricing_model, -- from Pool ID
                         l_interest_rate,              -- OUT S/G or Latest or Zero
                         l_rounding_type,              -- OUT Latest or Pool ID
                         l_day_count_type,             -- OUT Latest or Pool ID
                         l_pricing_model,              -- OUT Latest or Pool ID
                         l_mirror_pricing_model);      -- OUT Latest or Pool ID
      --------------------------------------------------------------------------------------------------------------------------

      --------------------------------------------------------------
      -- Calling from ZBA is always settled
      --------------------------------------------------------------
      if p_process_flag = 'Z' then
         l_settled      := 'Y';
         l_ext_source   := 'ZBA';  -- called by ZBA
      elsif p_process_flag = 'L' then
         l_settled      := 'N';    -- Always unsettled for IG
         l_ext_source   := 'CL';   -- called by Cash Leveling
      else
         l_settled      := 'N';    -- Always unsettled for IG
      end if;

      --------------------------------------------------------------
      -- Set attributes of xtr_deals_interface
      --------------------------------------------------------------
      L_External_IG.external_deal_id         := '0';
      L_External_IG.deal_type                := 'IG';
      L_External_IG.date_a                   := p_transfer_date;
      L_External_IG.company_code             := l_company_code;
      L_External_IG.cparty_code              := l_intercompany_code;
      L_External_IG.currency_a               := p_currency;
      L_External_IG.account_no_a             := l_company_account_no;
      L_External_IG.account_no_b             := l_intercompany_account_no;
      L_External_IG.action_code              := p_action_code;
      L_External_IG.amount_a                 := p_transfer_amount;
      L_External_IG.rate_a                   := l_interest_rate;        --  DERIVED
      L_External_IG.product_type             := l_company_product_type;
      L_External_IG.portfolio_code           := l_company_portfolio;
      L_External_IG.limit_code               := l_company_fund_limit;
      L_External_IG.limit_code_b             := l_company_inv_limit;
      L_External_IG.override_limit           := p_accept_limit_error;
      L_External_IG.comments                 := null;
      L_External_IG.attribute_category       := null;
      L_External_IG.attribute1               := null;
      L_External_IG.attribute2               := null;
      L_External_IG.attribute3               := null;
      L_External_IG.attribute4               := null;
      L_External_IG.attribute5               := null;
      L_External_IG.attribute6               := null;
      L_External_IG.attribute7               := null;
      L_External_IG.attribute8               := null;
      L_External_IG.attribute9               := null;
      L_External_IG.attribute10              := null;
      L_External_IG.attribute11              := null;
      L_External_IG.attribute12              := null;
      L_External_IG.attribute13              := null;
      L_External_IG.attribute14              := null;
      L_External_IG.attribute15              := null;
      L_External_IG.Rounding_Type            := l_rounding_type;            -- DERIVED
      L_External_IG.Day_Count_Type           := l_day_count_type;           -- DERIVED
      L_External_IG.pricing_model            := l_pricing_model;            -- DERIVED
      L_External_IG.Original_Amount          := 0;                          -- This will be calculated in IG API's CALC_DETAILS
      L_External_IG.Deal_Linking_Code        := null;
      L_External_IG.Dealer_Code              := l_company_dealer;
      L_External_IG.External_Source          := l_ext_source  ;
      L_External_IG.mirror_limit_code_fund   := l_intercompany_fund_limit;
      L_External_IG.mirror_limit_code_invest := l_intercompany_inv_limit;
      L_External_IG.mirror_portfolio_code    := l_intercompany_portfolio;
      L_External_IG.mirror_product_type      := l_intercompany_product_type;
      L_External_IG.mirror_pricing_model     := l_mirror_pricing_model;     -- DERIVED
      L_External_IG.mirror_dealer_code       := l_intercompany_dealer;
      L_External_IG.Settlement_Flag          := l_settled;
      --dbms_output.put_line('wrap   pass  Pricing                = '||L_External_IG.pricing_model);
      --dbms_output.put_line('wrap   pass  Interest Rate          = '||L_External_IG.rate_a);
      --dbms_output.put_line('wrap   pass  Rounding_Type          = '||L_External_IG.Rounding_Type);
      --dbms_output.put_line('wrap   pass  Day_Count_Type         = '||L_External_IG.Day_Count_Type);
      --dbms_output.put_line('wrap   pass  Product_type           = '||L_External_IG.product_type);
      --dbms_output.put_line('wrap   pass  Mirror Pricing         = '||L_External_IG.Mirror_pricing_model);
      --dbms_output.put_line('-----------------------------------------------------');

      ----------------------------------------------------------
      -- Call xtrimigb.pls
      ----------------------------------------------------------
      user_error       := FALSE;
      mandatory_error  := FALSE;
      validation_error := FALSE;
      limit_error      := FALSE;

      XTR_IG_TRANSFERS_PKG.TRANSFER_IG_DEALS(L_External_IG,
                                             null,             -- G_ig_source: must be null
                                             user_error,
                                             mandatory_error,
                                             validation_error,
                                             limit_error,
                                             p_deal_no,
                                             p_tran_no,         -- new
                                             p_mirror_deal_no,  -- new
                                             p_mirror_tran_no); -- new

      --dbms_output.put_line('-----------------------------------------------------');
      --if user_error       then dbms_output.put_line('wrap   User error'); end if;
      --if mandatory_error  then dbms_output.put_line('wrap   Mandatory error'); end if;
      --if validation_error then dbms_output.put_line('wrap   Validation error'); end if;
      --if limit_error      then dbms_output.put_line('wrap   Limit error'); end if;

      if user_error or mandatory_error or validation_error or limit_error then

         p_success_flag    := 'N';
         p_deal_no         := null;
         p_tran_no         := null;
         p_mirror_deal_no  := null;
         p_mirror_tran_no  := null;

      else

         commit;
         p_success_flag := 'Y';

      end if;

END IG_GENERATION;

------------------------------------------------------------------------------------------------------------------------------------------
-- 3800146 Main IAC API called by ZBA and Cash Leveling
------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE IAC_GENERATION(p_cash_pool_id       IN NUMBER,
                         p_from_bank_acct_id  IN NUMBER,
                         p_to_bank_acct_id    IN NUMBER,
                         p_transfer_date      IN DATE,
                         p_transfer_amount    IN NUMBER,
                         p_tran_no            OUT NOCOPY NUMBER,
                         p_success_flag       OUT NOCOPY VARCHAR2,
                         p_process_flag       IN  VARCHAR2) is

   cursor get_user (p_fnd_user in number) is
   select dealer_code
   from   xtr_dealer_codes_v
   where  user_id = p_fnd_user;

   l_Ext_IAC                xtr_interacct_transfers%rowtype;
   l_dealer_code            xtr_interacct_transfers.dealer_code%TYPE;
   l_company_code           xtr_interacct_transfers.company_code%TYPE;
   l_company_product_type   xtr_interacct_transfers.product_type%TYPE;
   l_company_portfolio      xtr_interacct_transfers.portfolio_code%TYPE;
   l_account_no_from        xtr_interacct_transfers.account_no_from%TYPE;
   l_account_no_to          xtr_interacct_transfers.account_no_to%TYPE;
   l_currency               xtr_interacct_transfers.currency%TYPE;
   l_auto_validation        BOOLEAN;
   l_auto_settlement        BOOLEAN;
   user_error               BOOLEAN;
   mandatory_error          BOOLEAN;
   validation_error         BOOLEAN;
   l_ext_source             VARCHAR2(30);
   l_sysdate                DATE;

BEGIN

      p_tran_no       := null;
      p_success_flag  := null;
      l_sysdate       := trunc(sysdate);

      fnd_msg_pub.initialize;

      ----------------------------------------------
      -- 1) Set the process flag
      ----------------------------------------------
      if p_process_flag = 'Z' then
         l_ext_source   := 'ZBA';  -- called by ZBA
      elsif p_process_flag = 'L' then
         l_ext_source   := 'CL';   -- called by Cash Leveling
      else
         p_success_flag := 'N';
      end if;

      ----------------------------------------------
      -- 2) Derive from Cashpool
      ----------------------------------------------
      IF nvl(p_success_flag,'Y') = 'Y' then
         IAC_CASHPOOL_DERIVE(p_cash_pool_id,
                             p_from_bank_acct_id,
                             p_to_bank_acct_id,
                          -- p_transfer_date,
                             l_company_code,
                             l_company_product_type,
                             l_company_portfolio,
                             l_account_no_from,
                             l_account_no_to,
                             l_currency);
      END IF;


      -------------------------------------------------------------------
      -- 3) Set other attributes of XTR_INTERACCT_TRANSFERS
      -------------------------------------------------------------------
      l_Ext_IAC.deal_type        := 'IAC';
      l_Ext_IAC.deal_subtype     := 'FIRM';
      l_Ext_IAC.status_code      := 'CURRENT';
      l_Ext_IAC.transfer_date    := p_transfer_date;
      l_Ext_IAC.transfer_amount  := p_transfer_amount;
      l_Ext_IAC.company_code     := l_company_code;
      l_Ext_IAC.currency         := l_currency;
      l_Ext_IAC.account_no_from  := l_account_no_from;
      l_Ext_IAC.account_no_to    := l_account_no_to;
      l_Ext_IAC.product_type     := l_company_product_type;
      l_Ext_IAC.portfolio_code   := l_company_portfolio;
      l_Ext_IAC.External_Source  := l_ext_source  ;

      ------------------------------------------------------------------
      -- 4) Set DEALER_CODE of XTR_INTERACCT_TRANSFERS
      ------------------------------------------------------------------
      open  get_user(fnd_global.user_id);
      fetch get_user into l_Ext_IAC.dealer_code;
      close get_user;

      ------------------------------------------------------------------
      -- 5) Set DEAL_DATE of XTR_INTERACCT_TRANSFERS
      ------------------------------------------------------------------
      if l_Ext_IAC.Transfer_Date > l_sysdate then
         l_Ext_IAC.deal_date := l_sysdate;
      else
         l_Ext_IAC.deal_date := l_Ext_IAC.Transfer_Date;
      end if;

      ------------------------------------------------------------------
      -- 6) Set Validation + Settlement flag of XTR_INTERACCT_TRANSFERS
      ------------------------------------------------------------------
      SET_IAC_VALIDATE_SETTLE(l_Ext_IAC.product_type,
                              l_Ext_IAC.dealer_code,
                              p_process_flag,
                              l_auto_validation,
                              l_auto_settlement);

      --dbms_output.put_line('wrap   pass  Product_type           = '||l_Ext_IAC.product_type);
      --dbms_output.put_line('----------------------------------------------------------');

      ----------------------------------------------------------
      -- Call xtrimigb.pls
      ----------------------------------------------------------
      user_error       := FALSE;
      mandatory_error  := FALSE;
      validation_error := FALSE;

      XTR_IAC_TRANSFERS_PKG.TRANSFER_IAC_DEALS(l_Ext_IAC,
                                               l_auto_validation,
                                               l_auto_settlement,
                                               user_error,
                                               mandatory_error,
                                               validation_error,
                                               p_tran_no); -- new
      --dbms_output.put_line('-----------------------------------------------------');

      --if user_error       then dbms_output.put_line('wrap   User error'); end if;
      --if mandatory_error  then dbms_output.put_line('wrap   Mandatory error'); end if;
      --if validation_error then dbms_output.put_line('wrap   Validation error'); end if;

      if user_error or mandatory_error or validation_error then

         p_success_flag := 'N';
         p_tran_no      := null;

      else

         commit;
         p_success_flag := 'Y';

      end if;

END IAC_GENERATION;

END XTR_WRAPPER_API_P;

/
