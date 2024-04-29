--------------------------------------------------------
--  DDL for Package Body XTR_STOCK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_STOCK_PKG" AS
/* $Header: xtrstckb.pls 120.11.12000000.2 2007/03/21 06:59:44 kbabu ship $ */

/************************************************************************/
/* This procedure is to insert information into DDA table after deal is */
/* commit.                                                              */
/************************************************************************/
PROCEDURE INS_STOCK_DDA (p_deal_no IN NUMBER,
			 p_reverse_dda IN BOOLEAN) as

cursor CUR_DEAL is
select *
from XTR_DEALS_V
where deal_no = p_deal_no;

D CUR_DEAL%ROWTYPE;

Cursor cur_div_share is
	   Select cash_dividend_id, dividend_per_share, declare_date
	   From xtr_stock_cash_dividends
	   Where stock_issue_code = D.bond_issue
	   And record_date >= D.start_date
	   And nvl(generated_flag, 'N') IN ('G', 'Y');
	   /* Bug 3737048 Added the new status in the cursor. */

Cursor cur_cparty_acct is
      select ACCOUNT_NUMBER
      from  XTR_BANK_ACCOUNTS_V
      where PARTY_CODE = D.CPARTY_CODE
      and   CURRENCY   = D.CURRENCY
      and   ((PARTY_TYPE = 'CP' and BANK_SHORT_CODE = D.CPARTY_REF)
           or(PARTY_TYPE = 'C' and substr(BANK_SHORT_CODE, 1, 7) = D.CPARTY_REF));

cursor HCE_RATE(p_currency VARCHAR2) is
select rounding_factor, hce_rate
from   XTR_MASTER_CURRENCIES_V
where  currency = p_currency;

 l_div_id	NUMBER;
 l_div 		NUMBER;
 l_declare_date DATE;
 l_rev_amt 	NUMBER:= NULL;
 l_rev_amt_hce 	NUMBER:= NULL;
 l_sysdate            DATE :=trunc(sysdate);
 p_one_step_rec xtr_fps2_p.one_step_rec_type;
 l_round	NUMBER;
 l_hce_rate	NUMBER;
 l_amt_date	DATE;
 l_cparty_acct  VARCHAR2(20):= NULL;

BEGIN
 Open CUR_DEAL;
 Fetch CUR_DEAL into D;
 IF CUR_DEAL%FOUND then
    Open cur_cparty_acct;
    Fetch cur_cparty_acct into l_cparty_acct;
    Close cur_cparty_acct;

    If D.deal_subtype = 'BUY' then
         -- COMENCE row Details
       INSERT INTO XTR_DEAL_DATE_AMOUNTS
       (deal_type, amount_type, date_type, deal_number, transaction_number,
	transaction_date, currency,amount, hce_amount, amount_date, transaction_rate,
	cashflow_amount, company_code, account_no, status_code,
	portfolio_code, dealer_code, client_code, deal_subtype, cparty_code, settle,
	product_type, cparty_account_no)
       values
	('STOCK', 'COMENCE', 'SETTLE', D.DEAL_NO, 1, D.DEAL_DATE, D.CURRENCY,
	D.START_AMOUNT, D.START_HCE_AMOUNT,  D.START_DATE, D.CAPITAL_PRICE,
	decode(D.DEAL_SUBTYPE,'BUY',-1,1) * D.START_AMOUNT, D.COMPANY_CODE,
	D.SETTLE_ACCOUNT_NO, D.STATUS_CODE, D.PORTFOLIO_CODE,
    	D.DEALER_CODE, D.CLIENT_CODE, D.DEAL_SUBTYPE,  D.CPARTY_CODE, 'N',
	D.PRODUCT_TYPE, l_cparty_acct);

 	  -- Dealt Row  with Counterparties
       INSERT INTO XTR_DEAL_DATE_AMOUNTS
       (deal_type, amount_type, date_type, deal_number, transaction_number,
	transaction_date, currency,  amount,hce_amount, amount_date, transaction_rate,
	cashflow_amount, company_code, account_no, status_code,
	portfolio_code, dealer_code,  client_code, deal_subtype, cparty_code, settle,
	product_type)
       values
	('STOCK', 'N/A', 'DEALT',  D.DEAL_NO, 1, D.DEAL_DATE, D.CURRENCY,
     	D.START_AMOUNT, D.START_HCE_AMOUNT,  D.DEAL_DATE, D.CAPITAL_PRICE,0,
	D.COMPANY_CODE, D.SETTLE_ACCOUNT_NO, D.STATUS_CODE,
        D.PORTFOLIO_CODE, D.DEALER_CODE, D.CLIENT_CODE, D.DEAL_SUBTYPE, D.CPARTY_CODE,
        'N', D.PRODUCT_TYPE);

          -- Limit Row
       insert INTO XTR_DEAL_DATE_AMOUNTS
       (deal_type, amount_type, date_type,  deal_number, transaction_number,
	transaction_date, currency, amount,hce_amount, amount_date, transaction_rate,
        cashflow_amount, company_code, account_no, status_code,
	portfolio_code, dealer_code, client_code, deal_subtype, cparty_code, settle,
        product_type, limit_code, limit_party)
       values ('STOCK', 'LIMIT', 'LIMIT', D.DEAL_NO, 1, D.DEAL_DATE, D.CURRENCY,
       D.START_AMOUNT, D.START_HCE_AMOUNT, D.DEAL_DATE,D.CAPITAL_PRICE, 0,
       D.COMPANY_CODE, D.SETTLE_ACCOUNT_NO, D.STATUS_CODE,
       D.PORTFOLIO_CODE, D.DEALER_CODE, D.CLIENT_CODE, D.DEAL_SUBTYPE, D.CPARTY_CODE,
       'N',  D.PRODUCT_TYPE, nvl(D.LIMIT_CODE, 'NILL'),
       nvl(D.ACCEPTOR_CODE,D.CPARTY_CODE));

         -- Insert into xtr_confirmation details
            XTR_MISC_P.DEAL_ACTIONS
                (D.deal_type,  D.deal_no, 1, 'NEW_STOCK_BUY_CONTRACT',
                 D.cparty_code,  D.client_code, l_sysdate,
                 D.company_code, D.status_code, null,
                 D.deal_subtype, D.currency,    D.cparty_advice,
                 D.client_advice,  D.start_amount, null);


    Else   -- deal_type 'SELL'
        -- COMENCE row Details
       INSERT INTO XTR_DEAL_DATE_AMOUNTS
       (deal_type, amount_type, date_type, deal_number, transaction_number,
	transaction_date, currency,amount, hce_amount, amount_date, transaction_rate,
	cashflow_amount, company_code, account_no, status_code,
	portfolio_code, dealer_code, client_code, deal_subtype, cparty_code, settle,
	product_type, cparty_account_no)
       values
	('STOCK', 'COMENCE', 'SETTLE', D.DEAL_NO, 1, D.DEAL_DATE, D.CURRENCY,
	D.START_AMOUNT, D.START_HCE_AMOUNT,  D.START_DATE, D.CAPITAL_PRICE,
	decode(D.DEAL_SUBTYPE,'BUY',-1,1) * D.START_AMOUNT, D.COMPANY_CODE,
	D.SETTLE_ACCOUNT_NO, D.STATUS_CODE, D.PORTFOLIO_CODE,
        D.DEALER_CODE, D.CLIENT_CODE, D.DEAL_SUBTYPE,  D.CPARTY_CODE, 'N',
	D.PRODUCT_TYPE, l_cparty_acct);

        -- Dealt Row  with Counterparties
       insert INTO XTR_DEAL_DATE_AMOUNTS
       (deal_type, amount_type, date_type, deal_number, transaction_number,
	transaction_date, currency,  amount,hce_amount, amount_date, transaction_rate,
	cashflow_amount, company_code, account_no, status_code,
	portfolio_code, dealer_code,  client_code, deal_subtype, cparty_code, settle,
	product_type)
       values ('STOCK', 'N/A', 'DEALT',  D.DEAL_NO, 1, D.DEAL_DATE, D.CURRENCY,
       D.START_AMOUNT, D.START_HCE_AMOUNT,  D.DEAL_DATE, D.CAPITAL_PRICE,0,
       D.COMPANY_CODE, D.SETTLE_ACCOUNT_NO, D.STATUS_CODE,
       D.PORTFOLIO_CODE, D.DEALER_CODE, D.CLIENT_CODE, D.DEAL_SUBTYPE, D.CPARTY_CODE,
       'N', D.PRODUCT_TYPE);

        -- if resale start_date <= dividend's record date, need to reverse cash dividend
        -- on SELL side where date_type = 'DIVDAT' and amount_type 'DIVEXP'
      If p_reverse_dda = TRUE then
          Open cur_div_share;
          Fetch cur_div_share into l_div_id, l_div, l_declare_date;
          While cur_div_share%FOUND loop
	     L_rev_amt := D.quantity * l_div;

	     Open hce_rate(D.currency);
	     Fetch hce_rate into l_round, l_hce_rate;
	     close hce_rate;

	     l_rev_amt_hce := round((L_rev_amt / l_hce_rate), l_round);

	    if l_declare_date > D.DEAL_DATE then
	       l_amt_date := l_declare_date;
	    else
	       l_amt_date := D.DEAL_DATE;
	    end if;

            Insert into XTR_DEAL_DATE_AMOUNTS
            (deal_type, amount_type, date_type, deal_number, transaction_number,
	     transaction_date, currency,  amount,hce_amount, amount_date, transaction_rate,
	     cashflow_amount, company_code, account_no, status_code,
	     portfolio_code, dealer_code,  client_code, deal_subtype, cparty_code, settle,
	     product_type, action_code)
            Values ('STOCK', 'DIVEXP', 'DIVDAT', D.DEAL_NO, l_div_id, D.DEAL_DATE, D.CURRENCY,
                    l_rev_amt, l_rev_amt_hce, l_amt_date, l_div, 0, D.COMPANY_CODE,
                    D.SETTLE_ACCOUNT_NO, D.STATUS_CODE, D.PORTFOLIO_CODE,
                    D.DEALER_CODE, D.CLIENT_CODE, D.DEAL_SUBTYPE, D.CPARTY_CODE, 'N',
                    D.PRODUCT_TYPE, 'REV');

              Fetch cur_div_share into l_div_id, l_div, l_declare_date;
          End loop;

      end if;

         -- Insert into xtr_confirmation details
            XTR_MISC_P.DEAL_ACTIONS
                (D.deal_type,  D.deal_no, 1, 'NEW_STOCK_SELL_CONTRACT',
                 D.cparty_code,  D.client_code, l_sysdate,
                 D.company_code, D.status_code, null,
                 D.deal_subtype, D.currency,    D.cparty_advice,
                 D.client_advice,  D.start_amount, null);

   end if;

   /****************************************************************************/
   /*  This procedure will insert an EXP deal into DDA table if user select    */
   /*  a tax code which is an one-step settlement method                       */
   /****************************************************************************/

   If D.TAX_CODE is NOT NULL then
	p_one_step_rec.p_schedule_code := D.TAX_CODE;
	p_one_step_rec.p_currency      := D.CURRENCY;
	p_one_step_rec.p_amount        := D.TAX_AMOUNT;
        p_one_step_rec.p_settlement_date := D.START_DATE;
        p_one_step_rec.p_settlement_account := D.SETTLE_ACCOUNT_NO;
        p_one_step_rec.p_company_code  := D.COMPANY_CODE;
        p_one_step_rec.p_cparty_code   := D.CPARTY_CODE;
        p_one_step_rec.p_cparty_account_no  := D.CPARTY_REF;

	XTR_FPS2_P.one_step_settlement(p_one_step_rec);

	If p_one_step_rec.p_exp_number is NOT NULL then
	   Update XTR_DEALS
	   Set tax_settled_reference = p_one_step_rec.p_exp_number
	   Where deal_no = D.deal_no;
	End if;
   End if;

END IF;
 Close CUR_DEAL;

end INS_STOCK_DDA;

-----------------------------------------------------------------------------------
/************************************************************/
/* This procedure is to update related tables when user     */
/* set Stock deal status from 'CURRENT' to 'CANCELLED'      */
/************************************************************/
PROCEDURE CANCEL_STOCK (p_deal_no IN NUMBER,
			p_deal_subtype IN VARCHAR2,
			p_currency IN VARCHAR2) IS

 cursor LOCK_DDA_DEAL is
 select ROWID
 from XTR_DEAL_DATE_AMOUNTS
 where deal_number = p_deal_no
 for update of status_code nowait;

 cursor LOCK_ROLL is
 select ROWID
 from XTR_ROLLOVER_TRANSACTIONS
 where deal_number = p_deal_no
 for update of status_code nowait;

 cursor BKGE_EXP is
 select BKGE_SETTLED_REFERENCE
 from XTR_DEALS_V
 where deal_type = 'STOCK'
 and deal_no = p_deal_no
 and bkge_settled_reference is NOT NULL;


-- Add for SELL Stock cancellation. Bug 3222956
 cursor UPD_BUY_DEAL is
 select deal_no, quantity, cross_ref_start_date, init_consideration
 from XTR_STOCK_ALLOC_DETAILS
 where cross_ref_no = p_deal_no;

 cursor UPD_BUY_DIV(p_buy_deal NUMBER, p_sell_date DATE) is
 select transaction_number, quantity, interest_rate,
	tax_settled_reference, tax_rate
 from XTR_ROLLOVER_TRANSACTIONS
 where deal_number = p_buy_deal
 and start_date >= p_sell_date;

 cursor cur_hce is
 select rounding_factor, hce_rate
 from XTR_MASTER_CURRENCIES_V
 where currency = p_currency;

 l_rowid	VARCHAR2(30);
 l_tax_ref	NUMBER;
 l_tax_rate	NUMBER;
 l_tax_amt	NUMBER;
 l_tax_amt_hce	NUMBER;
 l_bkge_ref	NUMBER;
 l_dummy	NUMBER:= NULL;
 l_buy_deal 	NUMBER;
 l_quantity	NUMBER;
 l_sell_start_date DATE;
 l_init_cons	NUMBER;
 l_trans_no	NUMBER;
 l_trans_quantity	NUMBER;
 l_trans_rate	NUMBER;
 l_trans_int	NUMBER;
 l_round	NUMBER;
 l_hce_rate	NUMBER;
 l_hce_int	NUMBER;
 l_limit_amt	NUMBER;

BEGIN
 --------------------------------------------------
 -- Delete entries from XTR_DEAL_DATE_AMOUNTS table
 --------------------------------------------------
 Open lock_dda_deal;
 Fetch lock_dda_deal into l_rowid;
 while lock_dda_deal%FOUND loop
    delete from XTR_DEAL_DATE_AMOUNTS
    where rowid = l_rowid;
    fetch lock_dda_deal into l_rowid;
 end loop;

 --------------------------------------------------
 -- Set Status to CANCELLED for XTR_ROLLOVER_TRANSACTIONS table
 ----------------------------------------------------
 if p_deal_subtype = 'BUY' then
    Open lock_roll;
    fetch lock_roll into l_rowid;
    while lock_roll%FOUND loop
       update XTR_ROLLOVER_TRANSACTIONS
       set status_code = 'CANCELLED'
       where rowid = l_rowid;
       fetch lock_roll into l_rowid;
    end loop;
 end if;


  -----------------------------------------------------
  -- Delete entris from XTR_CONFIRMATION_DETAILS table
  -----------------------------------------------------
      delete xtr_confirmation_details
      where  deal_type      = 'STOCK'
      and    deal_no = p_deal_no;

  ----------------------------------------------------------------------------
  -- Delete EXP record from XTR_EXPOSURE_TRANSACTIONS and DDA if there is any
  --------------------------------------------------------------------------

    XTR_FPS2_P.DELETE_TAX_EXPOSURE(p_deal_no, l_dummy);

  Open BKGE_EXP;
  Fetch BKGE_EXP into l_bkge_ref;
  if BKGE_EXP%FOUND then
     Delete from XTR_EXPOSURE_TRANSACTIONS
     Where transaction_number = l_bkge_ref;

     Delete from XTR_DEAL_DATE_AMOUNTS
     Where deal_type = 'EXP'
     and deal_number = 0
     and transaction_number = l_bkge_ref;
  end if;
  Close BKGE_EXP;

 -----------------------------------------------------------------------
 -- For cancellation of SELL Stock deal
 -----------------------------------------------------------------------
  if p_deal_subtype = 'SELL' then

     Open cur_hce;
     Fetch cur_hce into l_round, l_hce_rate;
     Close cur_hce;
     l_round := nvl(l_round, 2);
     l_hce_rate := nvl(l_hce_rate, 1);

     Open UPD_BUY_DEAL;
     Fetch UPD_BUY_DEAL into l_buy_deal, l_quantity, l_sell_start_date, l_init_cons;
     While UPD_BUY_DEAL%FOUND loop
	-- Update BUY deal's remaining quantity and limit amount
	l_limit_amt := l_init_cons;

        Update XTR_DEALS
        Set remaining_quantity = remaining_quantity + l_quantity,
	    status_code = 'CURRENT'
        where deal_no = l_buy_deal;

	Update XTR_DEAL_DATE_AMOUNTS
	Set amount = amount + l_limit_amt,
	    hce_amount = round((amount+l_limit_amt)/l_hce_rate, l_round)
	where deal_number = l_buy_deal
	and amount_type = 'LIMIT'
	and date_type = 'LIMIT';

        Update XTR_DEAL_DATE_AMOUNTS
	Set status_code = 'CURRENT'
	where deal_number = l_buy_deal
	and status_code = 'CLOSED';

        -- Update BUY deal's dividend that is issue after SELL deal
        Open UPD_BUY_DIV(l_buy_deal, l_sell_start_date);
	Fetch UPD_BUY_DIV into l_trans_no, l_trans_quantity, l_trans_rate,
	      l_tax_ref, l_tax_rate;
	While UPD_BUY_DIV%FOUND loop
	   l_trans_quantity := l_trans_quantity + l_quantity;
	   l_trans_int	    := round(l_trans_quantity * l_trans_rate, l_round);
	   l_hce_int	    := round(l_trans_int / l_hce_rate, l_round);
	   if l_tax_ref is NOT NULL then  -- dividend's tax
		l_tax_amt   := round(l_tax_rate * l_trans_int /100, l_round);
		l_tax_amt_hce:= round(l_tax_amt /l_hce_rate, l_round);

		Update XTR_DEAL_DATE_AMOUNTS
		set amount = l_tax_amt,
		    hce_amount = l_tax_amt_hce,
		    cashflow_amount = (-1) * l_tax_amt
		where deal_type = 'EXP'
		and deal_number = 0
		and transaction_number = l_tax_ref;
	   end if;

	   Update XTR_ROLLOVER_TRANSACTIONS
	   Set quantity = l_trans_quantity,
	       interest = l_trans_int,
	       interest_hce = l_hce_int,
	       tax_amount = l_tax_amt,
	       tax_amount_hce = l_tax_amt_hce
	   where deal_number = l_buy_deal
	   and transaction_number = l_trans_no;

	   Update XTR_DEAL_DATE_AMOUNTS
	   Set AMOUNT          = l_trans_int,
	       CASHFLOW_AMOUNT = l_trans_int,
	       HCE_AMOUNT      = l_hce_int
	   Where deal_number = l_buy_deal
	   and transaction_number = l_trans_no
	   and amount_type = 'DIVSET';

	   Fetch UPD_BUY_DIV into l_trans_no, l_trans_quantity, l_trans_rate,
		l_tax_ref, l_tax_rate;

	End loop;
	CLOSE UPD_BUY_DIV;

        Update XTR_STOCK_ALLOC_DETAILS
        set remaining_quantity = remaining_quantity + l_quantity
        where deal_no = l_buy_deal
        and ((cross_ref_start_date > l_sell_start_date)
          or (cross_ref_start_date = l_sell_start_date and cross_ref_no > p_deal_no));

        Fetch UPD_BUY_DEAL into l_buy_deal, l_quantity, l_sell_start_date, l_init_cons;
     End loop;
     Close UPD_BUY_DEAL;

     Delete from XTR_STOCK_ALLOC_DETAILS
     where cross_ref_no = p_deal_no;

  end if;

END CANCEL_STOCK;

--------------------------------------------------------------------------------
/*============================================================================*/
/*===================  BEGIN CASH DIVIDEND PROCEDURES  =======================*/
/*============================================================================*/

------------------------------------------------------
-- Check all dividends are correct
------------------------------------------------------
FUNCTION  INVALID_DIV_DATE(p_declare_date DATE,
                           p_record_date  DATE,
                           p_payment_date DATE) return BOOLEAN IS

BEGIN

   if (p_declare_date is not null and p_record_date is not null and p_declare_date > p_record_date) or
      (p_record_date is not null and p_payment_date is not null and p_record_date > p_payment_date) then
       --fnd_message.set_name ('XTR','XTR_DIVIDEND_DATE_ERROR');
       return TRUE;
   end if;

   return FALSE;

END;

-------------------------------------------------------------------------
-- Check that stock dividend combination is unique
-------------------------------------------------------------------------
FUNCTION  UNIQUE_STOCK_DIV_EXIST(p_stock_issue  VARCHAR2,
                                 p_declare_date DATE,
                                 p_record_date  DATE,
                                 p_payment_date DATE) return BOOLEAN IS

   cursor EXIST_STOCK_DIV is
   select 1
   from   XTR_STOCK_CASH_DIVIDENDS
   where  STOCK_ISSUE_CODE = p_stock_issue
   and    DECLARE_DATE     = p_declare_date
   and    RECORD_DATE      = p_record_date
   and    PAYMENT_DATE     = p_payment_date;

   l_dummy  NUMBER := 0;

BEGIN

   if p_stock_issue is not null then

      open  EXIST_STOCK_DIV;
      fetch EXIST_STOCK_DIV into l_dummy;
      close EXIST_STOCK_DIV;

      if l_dummy = 1 then
         --fnd_message.set_name('XTR','XTR_UNIQUE_CASH_DIVIDEND');
         return TRUE;
      end if;

   end if;

   return FALSE;

END;

/* Bug 3737048. The procedure below has been added to take care
of the situation when payment date is updated for a record that has
the status 'Not Generated'. */

-------------------------------------------------------------------------
-- Check that stock dividend combination is unique during update
-- by using the cash dividend id of the record being updated.
-------------------------------------------------------------------------
FUNCTION  UNIQUE_STOCK_DIV_EXIST(p_cash_dividend_id NUMBER,
                                 p_stock_issue  VARCHAR2,
                                 p_declare_date DATE,
                                 p_record_date DATE) return BOOLEAN IS

   cursor EXIST_STOCK_DIV is
   select 1
   from   XTR_STOCK_CASH_DIVIDENDS
   where  STOCK_ISSUE_CODE = p_stock_issue
   and    DECLARE_DATE     = p_declare_date
   and    RECORD_DATE      = p_record_date
   and    cash_dividend_id <> p_cash_dividend_id;

   l_dummy  NUMBER := 0;

BEGIN

   if p_cash_dividend_id is not null then

      open  EXIST_STOCK_DIV;
      fetch EXIST_STOCK_DIV into l_dummy;
      close EXIST_STOCK_DIV;

      if l_dummy = 1 then
         return TRUE;
      end if;

   end if;

   return FALSE;

END;

---------------------------------------------------------------
-- Disable delete function if dividend has been settled/journal
---------------------------------------------------------------
FUNCTION DISABLE_DELETE (p_div_id  NUMBER) return BOOLEAN IS

   cursor CHK_SETTLE is
   select 1
   from   xtr_deal_date_amounts     dda
   where  dda.deal_type          = 'STOCK'
   and    dda.transaction_number = p_div_id
   and    dda.amount_type        = 'DIVSET' and dda.deal_subtype = 'BUY'
   and    nvl(dda.settle,'N')    = 'Y'
   union
   select 1
   from   xtr_deal_date_amounts a,
          xtr_rollover_transactions b
   where  a.deal_type          = 'EXP'
   and    a.transaction_number = b.tax_settled_reference
   and    nvl(a.settle,'N')    = 'Y'
   and    b.deal_type          = 'STOCK'
   and    b.transaction_number = p_div_id
   and    b.tax_settled_reference is not null;

   cursor CHK_JOURNAL is
   select 2
   from   xtr_journals jnl
   where  jnl.deal_type          = 'STOCK'
   and    jnl.transaction_number = p_div_id
   and  ((jnl.amount_type        = 'DIVSET' and jnl.deal_subtype = 'BUY')
   or    (jnl.amount_type        = 'DIVEXP'))
   union
   select 2
   from   xtr_journals a,
          xtr_rollover_transactions b
   where  a.deal_type          = 'EXP'
   and    a.transaction_number = b.tax_settled_reference
   and    b.deal_type          = 'STOCK'
   and    b.transaction_number = p_div_id
   and    b.tax_settled_reference is not null;

   cursor CHK_CONFIRMATION is
   select 3
   from   xtr_confirmation_details
   where  deal_type = 'STOCK'
   and    transaction_no = p_div_id
   and   (confirmation_validated_by is not null
   or     confirmation_validated_on is not null);

   l_dummy NUMBER := 0;

BEGIN
      open  CHK_SETTLE;
      fetch CHK_SETTLE into l_dummy;
      close CHK_SETTLE;
      if l_dummy = 1 then  -- cannot delete
         return TRUE;
      else
         open  CHK_JOURNAL;
         fetch CHK_JOURNAL into l_dummy;
         close CHK_JOURNAL;
         if l_dummy = 2 then  -- cannot delete
            return TRUE;
         else
            open  CHK_CONFIRMATION;
            fetch CHK_CONFIRMATION into l_dummy;
            close CHK_CONFIRMATION;
            if l_dummy = 3 then  -- cannot delete
               return TRUE;
            else
               return FALSE;
            end if;
         end if;
      end if;

END;

--------------------------------------------------------
-- Count how many deals will generate dividend
--------------------------------------------------------
FUNCTION  GENERATE_CNT (p_div_id           IN  NUMBER,
                        p_stock_issue      IN  VARCHAR2,
                        p_declare_date     IN  DATE,
                        p_record_date      IN  DATE,
                        p_payment_date     IN  DATE,
                        p_div_per_share    IN  NUMBER) return NUMBER IS

   l_dummy  NUMBER := 0;

begin

  ------------------------------------------------------------------------------
  -- Same select statement as GENERATE_DIV, changing this must also change that.
  ------------------------------------------------------------------------------
   /* Bug 3737048. Added the condition for the settle date. */

   select count(*)
   into   l_dummy
   from   xtr_deals d
   where  d.deal_type     = 'STOCK'
   and    d.deal_subtype  = 'BUY'
   and    d.status_code  <> 'CANCELLED'
   and    d.bond_issue    = p_stock_issue
   and    d.start_date   <= p_record_date
   and    d.quantity > (select nvl(sum(b.quantity),0)
                        from   xtr_stock_alloc_details b
                        where  b.deal_no                    = d.deal_no
                        and    b.cross_ref_start_date      <= p_record_date)
   and    not exists   (select 1
                        from   xtr_rollover_transactions r
                        where  r.transaction_number = p_div_id
                        and    r.deal_number        = d.deal_no
			and    r.settle_date IS NOT NULL) ;


   return (l_dummy);

end;


-----------------------------------------------------
-- Generate dividend for the BUY deals, create RT,DDA
-----------------------------------------------------
/* Bug 3737048. Added the last parameter. */
PROCEDURE GENERATE_DIV (p_div_id           NUMBER,
                        p_stock_issue      VARCHAR2,
                        p_currency         VARCHAR2,
                        p_declare_date     DATE,
                        p_record_date      DATE,
                        p_payment_date     DATE,
                        p_div_per_share    NUMBER,
                        p_sys_user         VARCHAR2,
                        p_sys_date         DATE,
                        p_deal_no          NUMBER,
			p_reverse	   VARCHAR2) IS

  ------------------------------------------------------------------------------
  -- Same select statement as GENERATE_CNT, changing this must also change that.
  ------------------------------------------------------------------------------
   /* Bug 3737048. Added the condition for settle date. */

   cursor BUY_DEAL is
   select deal_no
   from   xtr_deals d
   where  d.deal_type     = 'STOCK'
   and    d.deal_subtype  = 'BUY'
   and    d.status_code  <> 'CANCELLED'
   and    d.deal_no       = nvl(p_deal_no,deal_no)
   and    d.bond_issue    = p_stock_issue
   and    d.start_date   <= p_record_date
   and    d.quantity > (select nvl(sum(b.quantity),0)
                        from   xtr_stock_alloc_details b
                        where  b.deal_no                    = d.deal_no
                        and    b.cross_ref_start_date      <= p_record_date)
   and    not exists   (select 1
                        from   xtr_rollover_transactions r
                        where  r.transaction_number = p_div_id
                        and    r.deal_number        = d.deal_no
			and    r.settle_date IS NOT NULL);

   cursor DEAL_DETAIL (l_deal_no NUMBER) is
   select *
   from   xtr_deals
   where  deal_no = l_deal_no;

   BUY    DEAL_DETAIL%ROWTYPE;

   Cursor cur_cparty_acct is
      select ACCOUNT_NUMBER
      from  XTR_BANK_ACCOUNTS_V
      where PARTY_CODE = BUY.CPARTY_CODE
      and   CURRENCY   = BUY.CURRENCY
      and   ((PARTY_TYPE = 'CP' and BANK_SHORT_CODE = BUY.CPARTY_REF)
           or(PARTY_TYPE = 'C' and substr(BANK_SHORT_CODE, 1, 7) = BUY.CPARTY_REF));

   --------------------------------------------
   -- Get rounding currency and hce_rate
   --------------------------------------------
   cursor ROUND_FACTOR is
   select rounding_factor, hce_rate
   from   XTR_MASTER_CURRENCIES_V
   where  currency = p_currency;

   --------------------------------------------
   -- Get home rounding curency
   --------------------------------------------
   cursor HCE_ROUND_FACTOR is
   select a.rounding_factor
   from   XTR_MASTER_CURRENCIES_V a,
          XTR_PRO_PARAM           b
   where  b.param_name = 'SYSTEM_FUNCTIONAL_CCY'
   and    a.currency   =  param_value;

   -------------------------------------------------
   -- Find total quantity sold if there are any sell
   -------------------------------------------------
   cursor QTY_SOLD (l_deal_no  NUMBER)  is
   select nvl(sum(QUANTITY),0)
   from   xtr_stock_alloc_details
   where  deal_no = l_deal_no
   and    cross_ref_start_date <= p_record_date;

   -------------------------------------------------
   -- Find individual resale to reverse DIVEXP
   -------------------------------------------------
   cursor SELL_REV (l_buy_deal_no  NUMBER)  is
   select d.DEAL_NO,
          s.QUANTITY,
          d.DEAL_DATE,
          d.START_DATE,
          d.CURRENCY,
          d.COMPANY_CODE,
          d.SETTLE_ACCOUNT_NO,
          d.STATUS_CODE,
          d.PORTFOLIO_CODE,
          d.DEALER_CODE,
          d.CLIENT_CODE,
          d.CPARTY_CODE,
          d.PRODUCT_TYPE
   from   xtr_stock_alloc_details s,
          xtr_deals d
   where  s.deal_no               = l_buy_deal_no
   and    s.cross_ref_start_date <= p_record_date
   and    s.cross_ref_no = d.deal_no
   and    d.deal_type    = 'STOCK'
   and    d.deal_subtype = 'SELL'
   and    d.status_code  = 'CURRENT';


/* for bug 5917859 starts */

L_STOCK_ISSUER XTR_STOCK_ISSUES.STOCK_ISSUER%TYPE;
l_cparty_ref   XTR_BANK_ACCOUNTS.BANK_SHORT_CODE%TYPE;


CURSOR C_STOCK_ISSUER IS
SELECT STOCK_ISSUER
FROM XTR_STOCK_ISSUES
WHERE STOCK_ISSUE_CODE = p_stock_issue;

/* for bug 5917859 ENDS */

   SELL   SELL_REV%ROWTYPE;

   l_rounding           NUMBER;
   l_hce_rate           NUMBER;
   l_hce_rounding       NUMBER;
   l_int_amt            NUMBER;
   l_int_amt_hce        NUMBER;
   l_exp_amt            NUMBER;
   l_exp_amt_hce        NUMBER;
   l_qty_sold           NUMBER;
   l_remain_qty         NUMBER;
   l_tran_declare_date  DATE;

   l_tax_rate           NUMBER;
   l_tax_amt            NUMBER;
   l_tax_amt_hce        NUMBER;

   l_dummy              NUMBER;
   l_err_code           NUMBER;
   l_level              VARCHAR2(50);
   l_cparty_acct	VARCHAR2(20);

   /* Bug 3737048 Added the variable below. */
   l_tax_settled_reference XTR_EXPOSURE_TRANSACTIONS.Transaction_Number%Type;

   one_step_rec  XTR_FPS2_P.one_step_rec_type; /*  p_schedule_code
                                                   p_currency
                                                   p_amount
                                                   p_settlement_date
                                                   p_settlement_account
                                                   p_company_code
                                                   p_cparty_code
                                                   p_cparty_account_no
                                                   p_error
                                                   p_settle_method
                                                   p_exp_number          */

BEGIN

   open  ROUND_FACTOR;
   fetch ROUND_FACTOR into l_rounding, l_hce_rate;
   close ROUND_FACTOR;

   open  HCE_ROUND_FACTOR;
   fetch HCE_ROUND_FACTOR into l_hce_rounding;
   close HCE_ROUND_FACTOR;

   for BUY_D in BUY_DEAL loop

      open  DEAL_DETAIL(BUY_D.deal_no);
      fetch DEAL_DETAIL into BUY;
      if    DEAL_DETAIL%FOUND then

	/* for bug 5917859 starts */

	OPEN C_STOCK_ISSUER;
	FETCH C_STOCK_ISSUER INTO L_STOCK_ISSUER;
	CLOSE C_STOCK_ISSUER;

        IF L_STOCK_ISSUER <> BUY.cparty_code THEN
		XTR_fps2_P.STANDING_SETTLEMENTS (L_STOCK_ISSUER,
						BUY.CURRENCY,
						'STOCK',
						BUY.DEAL_SUBTYPE,
						BUY.PRODUCT_TYPE,
						Null,
						l_cparty_ref ,
						l_cparty_acct);

        ELSE
	/* for bug 5917859 ENDS */


	   Open cur_cparty_acct;
    	   Fetch cur_cparty_acct into l_cparty_acct;
       	   Close cur_cparty_acct;

	END IF; --  for bug 5917859

         -------------------------------
         -- Find actual declare date
         -------------------------------
         if  BUY.deal_date <= p_declare_date then    -- AW Bug 2486820 issue 13
             l_tran_declare_date := p_declare_date;
         else
             l_tran_declare_date := BUY.deal_date;   -- AW Bug 2486820 issue 13
         end if;

         -------------------------------
         -- Find remaining shares
         -------------------------------
         l_qty_sold := 0;
         open  QTY_SOLD (BUY.deal_no);
         fetch QTY_SOLD into l_qty_sold;
         close QTY_SOLD;

         l_remain_qty := BUY.quantity - l_qty_sold;

         if nvl(l_remain_qty,0) <> 0 then

            l_int_amt     := round(l_remain_qty * p_div_per_share,nvl(l_rounding,2));
            l_int_amt_hce := round(l_int_amt / l_hce_rate,nvl(l_hce_rounding,2));

            l_exp_amt     := round(BUY.quantity * p_div_per_share,nvl(l_rounding,2));
            l_exp_amt_hce := round(l_exp_amt / l_hce_rate,nvl(l_hce_rounding,2));

            -------------------------------------------------
            -- Tax Calculation
            -------------------------------------------------
            if BUY.income_tax_code is not null then
	       l_tax_rate := NULL;

               XTR_FPS1_P.CALC_TAX_AMOUNT (BUY.deal_type,        -- IN deal type
                                           p_declare_date,       -- IN deal date
                                           null,                 -- IN principal tax schedule
                                           BUY.income_tax_code,  -- IN income tax schedule
                                           p_currency,           -- IN currency (buy ccy for FX)
                                           null,                 -- IN sell ccy if FX
                                           null,                 -- IN year basis
                                           null,                 -- IN number of days
                                           null,                 -- IN principal tax amount
                                           l_dummy,              -- IN/OUT principal tax rate
                                           l_int_amt,            -- IN income tax amount
                                           l_TAX_RATE,           -- IN/OUT income tax rate
                                           l_dummy,              -- IN/OUT calculated principal tax
                                           l_tax_amt,            -- IN/OUT calculated income tax
                                           l_err_code,           -- OUT
                                           l_level);             -- OUT
               l_tax_amt_hce := round(l_tax_amt / l_hce_rate,nvl(l_hce_rounding,2));

            end if;

            -------------------------------------------------
            -- Insert cash dividend RT row for the BUY deal
            -------------------------------------------------
	    /* Bug 3737048. Modified Code Begins. */
	    Update	xtr_rollover_transactions
	    set		settle_date = p_payment_date
	    where	transaction_number = p_div_id
	    and		deal_number = BUY.deal_no;

	    IF SQL%NOTFOUND THEN	/* End Code Added. */
            	Insert into xtr_rollover_transactions
                	(deal_number,         	transaction_number,
                        deal_type,           	deal_subtype,
                        quantity,            	interest,
			interest_hce,		tax_code,
                        tax_rate,           	tax_amount,
			tax_amount_hce,		interest_rate,
                        currency,           	dealer_code,
                        status_code,         	portfolio_code,
                        client_code,         	company_code,
			cparty_code,        	product_type,
                        deal_date,           	start_date,
                        settle_date,
			created_by,          	created_on)
                values (BUY.deal_no,         	p_div_id,
			BUY.deal_type,       	BUY.deal_subtype,
			l_remain_qty,        	l_int_amt,
                        l_int_amt_hce,         	BUY.income_tax_code,
			l_tax_rate,         	l_tax_amt,
                        l_tax_amt_hce,         	p_div_per_share,
			BUY.currency,       	BUY.dealer_code,
                        BUY.status_code,     	BUY.portfolio_code,
                        BUY.client_code,        BUY.company_code,
			L_STOCK_ISSUER,    -- FOR BUG 5917859   BUY.cparty_code,
			BUY.product_type,
                        l_tran_declare_date, 	p_record_date,
			p_payment_date,
                        p_sys_user,          	p_sys_date);

	    END IF; /* Bug 3737048 Added. */

            -----------------------------------------------------
            -- Insert cash dividend DDA - DIVSET for the BUY deal
            -----------------------------------------------------
	    /* Bug 3737048 Added the IF Condition below. */
	    IF (p_payment_date is not null) THEN
            	Insert into XTR_DEAL_DATE_AMOUNTS
                       (deal_type,		deal_number,
                        transaction_number,	deal_subtype,
                        date_type,        	amount_type,
                        action_code,         	transaction_date,
                        transaction_rate,       currency,
                        company_code,         	account_no,
			status_code,		portfolio_code,
                        dealer_code,         	client_code,
                        cparty_code,         	settle,
			product_type,		amount_date,
                        amount,       		cashflow_amount,
                        hce_amount,	       	cparty_account_no,
                        created_by,           	created_on)
                values (BUY.deal_type,        	BUY.deal_no,
                        p_div_id,         	BUY.deal_subtype,
			'PAYMENT',		'DIVSET',
                        null,			BUY.deal_date,
			p_div_per_share,	BUY.currency,
                        BUY.company_code,       BUY.settle_account_no,
                        BUY.status_code,        BUY.portfolio_code,
			BUY.dealer_code,	BUY.client_code,
                        L_STOCK_ISSUER,    -- FOR BUG 5917859  BUY.cparty_code,
			'N',
                        BUY.product_type,       p_payment_date,
			l_int_amt,    		l_int_amt,
                        l_int_amt_hce,        	l_cparty_acct,
                        p_sys_user,           	p_sys_date);
	    END IF;

            ----------------------------------------------------------
            -- Insert cash dividend DDA - DIVEXP(POS) for the BUY deal
            ----------------------------------------------------------
	    /* Bug 3737048. Added the Update statement and the IF condition. */
	    update XTR_DEAL_DATE_AMOUNTS
	    set	   currency = BUY.currency
	    where  deal_number = BUY.deal_no
	    and    transaction_number = p_div_id
	    and    date_type = 'DIVDAT'
	    and    amount_type = 'DIVEXP';

	    IF SQL%NOTFOUND THEN
            	Insert into XTR_DEAL_DATE_AMOUNTS
                	(deal_type,            	deal_number,
			 transaction_number,
                         deal_subtype,         	date_type,
                         amount_type,          	action_code,
                         transaction_date,     	transaction_rate,
                         currency,             	company_code,
                         account_no,           	status_code,
                         portfolio_code,       	dealer_code,
                         client_code,          	cparty_code,
                         settle,               	product_type,
                         amount_date,          	amount,
                         cashflow_amount,      	hce_amount,
                         created_by,           	created_on)
                values 	(BUY.deal_type,        	BUY.deal_no,
			 p_div_id,
                         BUY.deal_subtype,    	'DIVDAT',
                         'DIVEXP',             	'POS',
                         BUY.deal_date,        	p_div_per_share,
                         BUY.currency,         	BUY.company_code,
                         BUY.settle_account_no,	BUY.status_code,
                         BUY.portfolio_code,   	BUY.dealer_code,
                         BUY.client_code,      	L_STOCK_ISSUER,    -- FOR BUG 5917859  BUY.cparty_code,
                         'N',                  	BUY.product_type,
                         l_tran_declare_date,  	l_exp_amt,
                         0,        		l_exp_amt_hce,
                         p_sys_user,           	p_sys_date);

	    END IF; /* Bug 3737048 Added. */

            --------------------------------------------------------------
            -- Adjust cash dividend DDA - DIVEXP(REV) for the SELL deal
            --------------------------------------------------------------
	    /* Bug 3737048 Don't adjust DIVEXP from flag 'G' to 'Y'. */

	    IF p_reverse IS NULL THEN
            	l_tran_declare_date := null;
            	l_exp_amt           := null;
            	l_exp_amt_hce       := null;

            	open  SELL_REV(BUY.deal_no);
            	fetch SELL_REV into SELL;
            	while SELL_REV%FOUND loop

                  	-------------------------------
                  	-- Find actual declare date
                  	-------------------------------
                  	if  SELL.deal_date <= p_declare_date then
			/* Bug 2486820 issue 13 */
                      		l_tran_declare_date := p_declare_date;
                  	else
                      		l_tran_declare_date := SELL.deal_date;
				/* Bug 2486820 issue 13 */
                  	end if;

                  	l_exp_amt     := round(SELL.quantity *
					    p_div_per_share,nvl(l_rounding,2));
                  	l_exp_amt_hce := round(l_exp_amt / l_hce_rate,
					    nvl(l_hce_rounding,2));

                  /*-----------------------------------------------------------
                  Insert/Update cash dividend DDA - DIVEXP(REV) for
		  the SELL deal
                  ------------------------------------------------------------*/
                  	-- Bug 2517289
                  	update XTR_DEAL_DATE_AMOUNTS
                  	set    amount     = amount + l_exp_amt,
                         	hce_amount = hce_amount + l_exp_amt_hce
                  	where  deal_number        = SELL.deal_no
                  	and    transaction_number = p_div_id
                  	and    date_type          = 'DIVDAT'
                  	and    amount_type        = 'DIVEXP'
                  	and    action_code        = 'REV';

                  	if SQL%NOTFOUND then
                     		Insert into XTR_DEAL_DATE_AMOUNTS
                             		(deal_type,           deal_number,
					transaction_number,
                              		deal_subtype,         date_type,
                              		amount_type,          action_code,
                              		transaction_date,     transaction_rate,
                              		currency,             company_code,
                              		account_no,           status_code,
                              		portfolio_code,       dealer_code,
                              		client_code,          cparty_code,
                              		settle,               product_type,
                              		amount_date,          amount,
                              		cashflow_amount,      hce_amount,
                              		created_by,           created_on)
                      		values ('STOCK',              SELL.deal_no,
					p_div_id,
                              		'SELL',               'DIVDAT',
                              		'DIVEXP',             'REV',
                               		SELL.deal_date,       p_div_per_share,
                               		SELL.currency,        SELL.company_code,
                               		SELL.settle_account_no,SELL.status_code,
                               		SELL.portfolio_code,   SELL.dealer_code,
                               		SELL.client_code,      L_STOCK_ISSUER,    -- FOR BUG 5917859   SELL.cparty_code,
                               		'N',                  SELL.product_type,
                               		l_tran_declare_date,   l_exp_amt,
                               		0,		       l_exp_amt_hce,
                               		p_sys_user,            p_sys_date);
                  	end if;

               		fetch SELL_REV into SELL;

            	end loop; -- of SELL_REV
            	close SELL_REV;

	end if;

            -------------------------------------------------
            -- Insert confirmation details
            -------------------------------------------------
            XTR_MISC_P.DEAL_ACTIONS (BUY.deal_type,    BUY.deal_no, p_div_id,
                                    'NEW_STOCK_CASH_DIVIDEND',
                                     L_STOCK_ISSUER,    -- FOR BUG 5917859  BUY.cparty_code,
				     BUY.client_code,
				     p_sys_date,
                                     BUY.company_code, BUY.status_code, null,
                                     BUY.deal_subtype, BUY.currency,
				     BUY.cparty_advice,
                                     BUY.client_advice,l_int_amt,       null);

	    /* Bug 3737048. Added the select below.
	       Determine if the tax settlement exposure record has been
	       generated already. */

	    select tax_settled_reference
            into   l_tax_settled_reference
            from   xtr_rollover_transactions
            where  deal_number = BUY.deal_no
            and    deal_type = 'STOCK'
            and    transaction_number = p_div_id;

            /* Bug 3737048. Added the last 2 conditions in the IF statement. */
	    /* Bug 4383634. Changed the last condition. */

            if  BUY.income_tax_code is not null and
		BUY.settle_account_no is not null and
               	l_tax_amt is not null and l_tax_amt_hce is not null and
		p_payment_date is not null and
		l_tax_settled_reference is null then
               -------------------------------------------------
               -- Insert exposure transactions
               -------------------------------------------------
               one_step_rec.p_schedule_code      := BUY.income_tax_code;
               one_step_rec.p_currency           := BUY.currency;
               one_step_rec.p_amount             := l_tax_amt;
               one_step_rec.p_settlement_date    := p_payment_date;
               one_step_rec.p_company_code       := BUY.company_code;
               one_step_rec.p_settlement_account := BUY.settle_account_no;
               one_step_rec.p_cparty_code        := BUY.cparty_code;
               one_step_rec.p_cparty_account_no  := BUY.cparty_ref;

               XTR_FPS2_P.ONE_STEP_SETTLEMENT(one_step_rec);

               -------------------------------------------------------
               -- Update Rollover Rows for related transactions
               -------------------------------------------------------

               if one_step_rec.p_exp_number is not null then
                  update XTR_ROLLOVER_TRANSACTIONS
                  set    TAX_SETTLED_REFERENCE = one_step_rec.p_exp_number
                  where  DEAL_TYPE             = 'STOCK'
                  and    DEAL_NUMBER           = BUY.deal_no
                  and    TRANSACTION_NUMBER    = p_div_id;
               end if;

            end if;

         end if; -- remaining_qty <> 0

      end if;  --   DEAL_DETAIL%found
      close DEAL_DETAIL;

   end loop;  -- BUY_D

END;

------------------------------------------------------
-- Count if dividends have been created
------------------------------------------------------
FUNCTION DELETE_CNT(p_div_id  NUMBER) return NUMBER is
   l_dummy  NUMBER := 0;
BEGIN

   select count(*)
   into   l_dummy
   from   xtr_rollover_transactions
   where  transaction_number = p_div_id
   and    deal_type = 'STOCK';

   return l_dummy;

END;

---------------------------------------------
-- Delete Dividend, RT, DDA, Exposure records
---------------------------------------------
FUNCTION  DELETE_DIV (p_div_id   NUMBER) return BOOLEAN IS

   cursor TAX_TRANS is
   select deal_number,                       -- Bug 2506786 tax_settled_reference
          transaction_number
   from   XTR_ROLLOVER_TRANSACTIONS
   where  deal_type          = 'STOCK'
   and    transaction_number = p_div_id
   and    tax_settled_reference is not null;

BEGIN

   if not DISABLE_DELETE(p_div_id) then

      FOR EXP_ID in TAX_TRANS loop

         ----------------------------------------
         -- Delete Exposure Transactions and DDA
         ----------------------------------------
         -- Bug 2506786
         XTR_FPS2_P.DELETE_TAX_EXPOSURE(EXP_ID.deal_number,EXP_ID.transaction_number);

      END LOOP;

      -------------------------------
      -- Any DDA's DIVEXP and DIVSET
      -------------------------------
      delete xtr_deal_date_amounts
      where  deal_type    =   'STOCK'
      and    deal_subtype in ('BUY','SELL')
      and    amount_type  in ('DIVSET','DIVEXP')
      and    transaction_number = p_div_id;

      -------------------------------
      -- Any RT's cash dividend
      -------------------------------
      delete xtr_rollover_transactions
      where  deal_type          = 'STOCK'
      and    transaction_number = p_div_id;

      -------------------------------
      -- Any confirmation details
      -------------------------------
      delete xtr_confirmation_details
      where  deal_type      = 'STOCK'
      and    transaction_no = p_div_id;

      return TRUE;

   else
      return FALSE;
   end if;

END;

/*============================================================================*/
/*=====================  END CASH DIVIDEND PROCEDURES  =======================*/
/*============================================================================*/


END XTR_STOCK_PKG;

/
