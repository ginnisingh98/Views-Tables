--------------------------------------------------------
--  DDL for Package Body XTR_IAC_TRANSFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_IAC_TRANSFERS_PKG" AS
/* $Header: xtrimiab.pls 120.2 2008/01/25 07:33:44 srsampat ship $ */


  -------------------------------------------------------------------------------------------------------------------
  Procedure Log_IAC_Errors(p_Error_Code    In Varchar2,
                           p_Field_Name    In Varchar2) is
  -------------------------------------------------------------------------------------------------------------------

     cursor c_text is
     select text
     from   xtr_sys_languages_vl
     where  item_name = p_Field_Name;

     p_text xtr_sys_languages_vl.text%TYPE;

  begin

        if p_Error_Code = 'XTR_MANDATORY' then
           -------------------------------
           -- Get the dynamic prompt text.
           -------------------------------
           open  c_text;
           fetch c_text into p_text;
           close c_text;

           FND_MESSAGE.Set_Name('XTR','XTR_MANDATORY_FIELD');   -- AW new message
           FND_MESSAGE.Set_Token('FIELD', p_text);

        else
           FND_MESSAGE.Set_Name('XTR', p_Error_Code);
        end if;

        --*****************************************************************************************************************
        -- Populate message to stack for CE to retrieve
        --*****************************************************************************************************************
        fnd_msg_pub.add;
        --dbms_output.put_line('imIAC   Error  = '|| p_error_code||'   : '||p_field_name);

  end;

  -----------------------------------------------------------------------------------------------------
  function VALID_CURRENCY(p_curr IN VARCHAR2) return boolean is
  -----------------------------------------------------------------------------------------------------
        cursor  curs(c_curr IN VARCHAR2) is
        select  1
        from    XTR_MASTER_CURRENCIES
        where   currency = c_curr;

        l_dummy  NUMBER;

  begin
        open curs (p_curr);
        fetch curs into l_dummy;
        if curs%NOTFOUND then
           close curs;
           return(FALSE);
        else
           close curs;
           return(TRUE);
        end if;

  exception
        when others then
           if curs%ISOPEN then close curs; end if;
              return(FALSE);
  end;



  -----------------------------------------------------------------------------------------------------
  function VALID_PARTY_ACCT(p_party      IN VARCHAR2,
                            p_party_acct IN VARCHAR2,
                            p_curr       IN VARCHAR2) return varchar2 is
  -----------------------------------------------------------------------------------------------------
	cursor  curs(c_party      IN VARCHAR2,
                     c_curr       IN VARCHAR2,
                     c_party_acct IN VARCHAR2) is
	select 	a.BANK_CODE,
                a.AUTHORISED
	from 	XTR_BANK_ACCOUNTS_V a,
                XTR_PARTY_INFO      b
	where 	a.party_code 	    = c_party
	and 	a.currency 	    = c_curr
        and     nvl(a.setoff_account_yn,'N') <> 'Y'
	and	a.account_number    = c_party_acct
        and     a.bank_code         = b.party_code
        order by nvl(a.authorised,'N') desc;

	l_bank_code	xtr_bank_accounts.bank_code%TYPE;
        l_auth          VARCHAR2(1);

  begin
	open curs (p_party, p_curr, p_party_acct);
        fetch curs into l_bank_code, l_auth;
	if curs%NOTFOUND then
           close curs;
           FND_MESSAGE.Set_Name('XTR', 'XTR_BANK_CODE_MISSING'); -- The bank account ACCOUNT_NUMBER is missing a bank code.
           FND_MESSAGE.SET_TOKEN('ACCOUNT_NUMBER', p_party_acct);
           fnd_msg_pub.add;
           --dbms_output.put_line('imIAC   Error  = XTR_BANK_CODE_MISSING = '|| p_party_acct);
           return(NULL);
	else
           close curs;
           if nvl(l_auth,'N') = 'N' then
              FND_MESSAGE.Set_Name('XTR', 'XTR_BANK_BAL_ACCT_AUTH'); -- The bank account P_ACCOUNT is not authorised.
              FND_MESSAGE.SET_TOKEN('P_ACCOUNT', p_party_acct);
              fnd_msg_pub.add;
              --dbms_output.put_line('imIAC   Error  = XTR_BANK_BAL_ACCT_AUTH = '|| p_party_acct);
              return(NULL);
           else
              return(l_bank_code);
           end if;
	end if;

  exception
	when others then
           if curs%ISOPEN then close curs; end if;
              return(NULL);
  end;


  -----------------------------------------------------------------------------------------------------
  function VALID_PRODUCT(p_product IN VARCHAR2) return boolean is
  -----------------------------------------------------------------------------------------------------
	cursor  curs(c_product in varchar2) is
	select 	1
	from 	XTR_AUTH_PRODUCT_TYPES_V
	where 	deal_type    = C_iac_type
	and 	Product_Type = c_product;

	l_dummy	NUMBER;

  begin
	open curs (p_product);
	fetch curs into l_dummy;
	if curs%NOTFOUND then
   	   close curs;
   	   return(FALSE);
	else
   	   close curs;
	   return(TRUE);
	end if;

  exception
	when others then
           if curs%ISOPEN then close curs; end if;
              return(FALSE);
  end;


  -----------------------------------------------------------------------------------------------------
  function VALID_PORTFOLIO(p_comp      IN VARCHAR2,
                           p_portfolio IN VARCHAR2) return boolean is
  -----------------------------------------------------------------------------------------------------
	cursor curs(c_comp in varchar2, c_portfolio in varchar2) is
	select 	1
	from 	XTR_PORTFOLIOS_V
	where 	company_code    = c_comp
	and     nvl(external_portfolio,'N') <> 'Y'
	and 	portfolio       = c_portfolio;

	l_dummy	NUMBER;

  begin
	open curs (p_comp, p_portfolio);
        fetch curs into l_dummy;
        if curs%NOTFOUND then
           close curs;
           return(FALSE);
        else
           close curs;
           return(TRUE);
        end if;

  exception
	when others then
           if curs%ISOPEN then close curs; end if;
              return(FALSE);
  end;


  /*--------------------------------------------------------------------------------*/
  FUNCTION VALID_DEALER_CODE(p_dealer_code        IN VARCHAR2) return BOOLEAN is
  /*--------------------------------------------------------------------------------*/
  l_temp NUMBER;
  BEGIN
	BEGIN
		select 1
		into l_temp
		from xtr_dealer_codes_v
		where dealer_code = p_dealer_code
		and rownum = 1;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		return(FALSE);
	END;
	return(TRUE);
  END VALID_DEALER_CODE;


  -----------------------------------------------------------------------------------------------------
  function VALID_TRANSFER_AMOUNT(p_value IN NUMBER) return boolean is
  -----------------------------------------------------------------------------------------------------
  begin
	if nvl(p_value,0) < 0 then
	   return(FALSE);
	else
  	   return(TRUE);
	end if;
  end;

  -----------------------------------------------------------------------------------------------------
  function VALID_DEAL_DATE(p_value IN DATE) return boolean is
  -----------------------------------------------------------------------------------------------------
  begin
	if nvl(p_value,sysdate) > G_iac_date then
	   return(FALSE);
	else
  	   return(TRUE);
	end if;
  end;


  -----------------------------------------------------------------------------------------------------
  procedure CHECK_MANDATORY_FIELDS(ARec_IAC IN xtr_interacct_transfers%rowtype,
				   p_error OUT NOCOPY BOOLEAN) is
  -----------------------------------------------------------------------------------------------------
  begin

        p_error := FALSE;

	if ARec_IAC.company_code is null then
           Log_IAC_errors('XTR_MANDATORY','CG$CTRL.COMPANY_CODE');
           p_error := TRUE;
	end if;

	if ARec_IAC.transfer_date is null then
           Log_IAC_errors('XTR_MANDATORY','CG$CTRL.AMOUNT_DATE');
           p_error := TRUE;
	end if;

	if ARec_IAC.account_no_from is null then
           Log_IAC_errors('XTR_MANDATORY','TRANS.ACCOUNT_NAME_FROM');
           p_error := TRUE;
	end if;


	if ARec_IAC.account_no_to is null then
           Log_IAC_errors('XTR_MANDATORY','TRANS.ACCOUNT_NAME_TO');
           p_error := TRUE;
	end if;

	if ARec_IAC.transfer_amount is null then
           Log_IAC_errors('XTR_MANDATORY','TRANS.PAY_AMOUNT');
           p_error := TRUE;
	end if;

	if ARec_IAC.product_type is null then
           Log_IAC_errors('XTR_MANDATORY','TRANS.PRODUCT_TYPE');
           p_error := TRUE;
	end if;


	if ARec_IAC.portfolio_code is null then
           Log_IAC_errors('XTR_MANDATORY','TRANS.PORTFOLIO_CODE_FROM');
           p_error := TRUE;
	end if;

	if ARec_IAC.dealer_code is null then
           Log_IAC_errors('XTR_MANDATORY','CG$CTRL.DEALER_CODE');
           p_error := TRUE;
	end if;

	if ARec_IAC.deal_date is null then
           Log_IAC_errors('XTR_MANDATORY','CG$CTRL.DEAL_DATE');
           p_error := TRUE;
	end if;

  end;  /*  CHECK_MANDATORY_FIELDS  */


  -----------------------------------------------------------------------------------------------------
  procedure VALIDATE_DEALS(ARec_IAC         IN  xtr_interacct_transfers%rowtype,
                           p_Bank_Code_From OUT NOCOPY VARCHAR2,
                           p_Bank_Code_To   OUT NOCOPY VARCHAR2,
                           p_error          OUT NOCOPY BOOLEAN) is
  -----------------------------------------------------------------------------------------------------
     l_zba_duplicate  BOOLEAN := FALSE;

  begin

     p_error := FALSE;

     if not VALID_CURRENCY(ARec_IAC.Currency) then

        Log_IAC_errors('XTR_INV_CURR');
        p_error        := TRUE;

     else

        p_Bank_Code_From := null;
        p_Bank_Code_From := VALID_PARTY_ACCT(ARec_IAC.Company_Code, ARec_IAC.Account_No_From, ARec_IAC.Currency);
        if p_Bank_Code_From is null then
           p_error := TRUE;
        end if;


        p_Bank_Code_To := null;
        p_Bank_Code_To := VALID_PARTY_ACCT(ARec_IAC.Company_Code, ARec_IAC.Account_No_To, ARec_IAC.Currency);
        if p_Bank_Code_To is null then
           p_error := TRUE;
        end if;

     end if;  -- not currency error

     if ARec_IAC.Account_No_From = ARec_IAC.Account_No_To then
        Log_IAC_errors('XTR_1877'); -- The account numbers must be different
        p_error := TRUE;
     end if;

     if not VALID_PRODUCT(ARec_IAC.Product_Type) then
        Log_IAC_errors('XTR_INV_PRODUCT_TYPE');
        p_error := TRUE;
     end if;


     if not VALID_DEALER_CODE(ARec_IAC.Dealer_Code) then
        Log_IAC_errors('XTR_INV_DEALER_CODE');
        p_error := TRUE;
     end if;

     if not VALID_PORTFOLIO(ARec_IAC.Company_Code, ARec_IAC.Portfolio_Code) then
        Log_IAC_errors('XTR_INV_PORT_CODE');
        p_error := TRUE;
     end if;


     if not VALID_TRANSFER_AMOUNT(ARec_IAC.Transfer_Amount) then
        Log_IAC_errors('XTR_56');
        p_error := TRUE;
     end if;

     if not VALID_DEAL_DATE(ARec_IAC.Deal_Date) then
        Log_IAC_errors('XTR_INV_DEAL_DATE');
        p_error := TRUE;
     end if;


     --------------------------------------------------------------------------------------------------
     -- Duplicate check for ZBA
     --------------------------------------------------------------------------------------------------
     if not p_error and ARec_IAC.External_Source = C_ZBA then
        XTR_WRAPPER_API_P.CHK_ZBA_IAC_DUPLICATE (ARec_IAC.company_code,          -- p_company_code,
                                                 ARec_IAC.transfer_amount,       -- p_transfer_amount,
                                                 ARec_IAC.transfer_date,         -- p_transfer_date,
                                                 ARec_IAC.account_no_from,       -- p_company_account_no,
                                                 ARec_IAC.account_no_to,         -- p_party_account_no,
                                                 ARec_IAC.portfolio_code,        -- p_company_portfolio,
                                                 ARec_IAC.product_type,          -- p_company_product_type,
                                                 l_zba_duplicate);
        if l_zba_duplicate then
           p_error := TRUE;
        end if;

     end if;

  end;    /* VALIDATE_DEALS  */


--********************************************************************************************
--  To settle a cashflow   *******************************************************************
--********************************************************************************************
procedure VALIDATE_SETTLE_DDA (p_validate_flag IN  BOOLEAN,
                               p_settle_flag   IN  BOOLEAN,
                               p_actual_settle IN  DATE,
                               p_dual_auth_by  OUT NOCOPY VARCHAR2,
                               p_dual_auth_on  OUT NOCOPY DATE,
                               p_settle        OUT NOCOPY VARCHAR2,
                               p_settle_no     OUT NOCOPY NUMBER,
                               p_settle_no2    OUT NOCOPY NUMBER,
                               p_settle_auth   OUT NOCOPY VARCHAR2,
                               p_settle_date   OUT NOCOPY DATE,
                               p_trans_mts     OUT NOCOPY VARCHAR2,
                               p_audit_indic   OUT NOCOPY VARCHAR2) is

begin

  -- Bug 6738354 start
  select XTR_SETTLEMENT_NUMBER_S.NEXTVAL into p_settle_no  from DUAL;
  select XTR_SETTLEMENT_NUMBER_S.NEXTVAL into p_settle_no2 from DUAL;
  -- Bug 6738354 end

   -------------------------------------
   -- Dual Authorised  Attributes
   -------------------------------------
   if p_validate_flag then
      p_dual_auth_by := G_iac_user;
      p_dual_auth_on := G_iac_date;
   else
      p_dual_auth_by := null;
      p_dual_auth_on := null;
   end if;

   -------------------------------------
   -- Settlement Attributes
   -------------------------------------
   if p_settle_flag then

     /* Bug 6738354 start
      select XTR_SETTLEMENT_NUMBER_S.NEXTVAL into p_settle_no  from DUAL;
      select XTR_SETTLEMENT_NUMBER_S.NEXTVAL into p_settle_no2 from DUAL;
      Bug 6738354 end */
      p_settle      := 'Y';
      p_settle_auth := G_iac_user;
      p_settle_date := p_actual_settle;
      p_trans_mts   := 'Y';
      p_audit_indic := 'Y';

   else
      p_settle      := 'N';
      /* Bug 6738354 start
      p_settle_no   := null;
      p_settle_no2  := null;
      Bug 6738354 end  */
      p_settle_auth := null;
      p_settle_date := null;
      p_trans_mts   := null;
      p_audit_indic := null;

   end if;

end;

  -----------------------------------------------------------------------------------------------------
  --  Local procedure to insert Deal Date Rows
  -----------------------------------------------------------------------------------------------------
  procedure INS_DEAL_DATE_AMTS (ARec_IAC      IN  XTR_INTERACCT_TRANSFERS%rowtype,
                                p_From_Bank   IN  XTR_DEAL_DATE_AMOUNTS.LIMIT_PARTY%TYPE,
                                p_To_Bank     IN  XTR_DEAL_DATE_AMOUNTS.LIMIT_PARTY%TYPE,
                                p_tran_num    IN  NUMBER,
                                p_Validated   IN  BOOLEAN,
                                p_Settled     IN  BOOLEAN ) is
  -----------------------------------------------------------------------------------------------------

     l_settle          VARCHAR2(1);
     l_settle_no       NUMBER := null;
     l_settle_no2      NUMBER := null;
     l_settle_auth     xtr_deal_date_amounts.SETTLEMENT_AUTHORISED_BY%TYPE;
     l_settle_date     DATE;
     l_dual_auth_by    xtr_deal_date_amounts.DUAL_AUTHORISATION_BY%TYPE;
     l_dual_auth_on    DATE;
     l_trans_mts       VARCHAR2(1);
     l_audit_indic     VARCHAR2(1);
     l_dummy_num       NUMBER;

  begin

        -------------------------------------------------------------------------
        --  Validation and settlement
        -------------------------------------------------------------------------
        VALIDATE_SETTLE_DDA (p_Validated,
                             p_Settled,
                             ARec_IAC.Transfer_date,
                             l_dual_auth_by,
                             l_dual_auth_on,
                             l_settle,
                             l_settle_no,
                             l_settle_no2,
                             l_settle_auth,
                             l_settle_date,
                             l_trans_mts,
                             l_audit_indic);

        -------------------------------------------------------------------------
        -- Paying side (bank account from)
        -------------------------------------------------------------------------
        insert into XTR_DEAL_DATE_AMOUNTS_V
                    (deal_type,                amount_type,               date_type,                product_type,
                     deal_number,              transaction_number,        transaction_date,
                     currency,                 amount,                    hce_amount,               amount_date,
                     cashflow_amount,          company_code,              account_no,               action_code,
                     cparty_code,              cparty_account_no,         status_code,
                     exp_settle_reqd,          deal_subtype,              portfolio_code,           dealer_code,
                     limit_party,              DUAL_AUTHORISATION_BY,     DUAL_AUTHORISATION_ON,
                     SETTLE,                   SETTLEMENT_NUMBER,         SETTLEMENT_AUTHORISED_BY, ACTUAL_SETTLEMENT_DATE,
                     TRANS_MTS,                AUDIT_INDICATOR)
        values     ( ARec_IAC.deal_type,      'AMOUNT',                  'VALUE',                   ARec_IAC.PRODUCT_TYPE,
                     0,                        p_tran_num,                ARec_IAC.deal_date,       -- per TD design
                     ARec_IAC.CURRENCY,        ARec_IAC.TRANSFER_AMOUNT,  0,                        ARec_IAC.Transfer_date,
                     -ARec_IAC.TRANSFER_AMOUNT,ARec_IAC.COMPANY_CODE,     ARec_IAC.ACCOUNT_NO_FROM, 'PAY',
                     ARec_IAC.COMPANY_CODE,    ARec_IAC.ACCOUNT_NO_TO,    ARec_IAC.STATUS_CODE,
                     'Y',                      ARec_IAC.DEAL_SUBTYPE,     ARec_IAC.PORTFOLIO_CODE,  ARec_IAC.DEALER_CODE,
                     p_From_Bank,              l_dual_auth_by,            l_dual_auth_on,
                     l_settle,                 l_settle_no,               l_settle_auth,            l_settle_date,
                     l_trans_mts,              l_audit_indic);

        -------------------------------------------------------------------------
        -- Receiving Side (Bank account to)
        -------------------------------------------------------------------------
        insert into XTR_DEAL_DATE_AMOUNTS_V
                    (deal_type,                amount_type,               date_type,                product_type,
                     deal_number,              transaction_number,        transaction_date,
                     currency,                 amount,                    hce_amount,               amount_date,
                     cashflow_amount,          company_code,              account_no,               action_code,
                     cparty_code,              cparty_account_no,         status_code,
                     exp_settle_reqd,          deal_subtype,              portfolio_code,           dealer_code,
                     limit_party,              DUAL_AUTHORISATION_BY,     DUAL_AUTHORISATION_ON,
                     SETTLE,                   SETTLEMENT_NUMBER,         SETTLEMENT_AUTHORISED_BY, ACTUAL_SETTLEMENT_DATE,
                     TRANS_MTS,                AUDIT_INDICATOR)
        values    (  ARec_IAC.deal_type,      'AMOUNT',                   'VALUE',                  ARec_IAC.PRODUCT_TYPE,
                     0,                        p_tran_num,                ARec_IAC.deal_date,       -- per TD design
                     ARec_IAC.CURRENCY,        ARec_IAC.TRANSFER_AMOUNT,  0,                        ARec_IAC.TRANSFER_DATE,
                     ARec_IAC.TRANSFER_AMOUNT, ARec_IAC.COMPANY_CODE,     ARec_IAC.ACCOUNT_NO_TO,  'REC',
                     ARec_IAC.COMPANY_CODE,    ARec_IAC.ACCOUNT_NO_FROM,  ARec_IAC.STATUS_CODE,
                     'Y',                      ARec_IAC.DEAL_SUBTYPE,     ARec_IAC.PORTFOLIO_CODE,  ARec_IAC.DEALER_CODE,
                     p_To_Bank,                l_dual_auth_by,            l_dual_auth_on,
                     l_settle,                 l_settle_no2,              l_settle_auth,            l_settle_date,
                     l_trans_mts,              l_audit_indic);

        -------------------------------------------------
        -- Create Settlement Summary
        -------------------------------------------------
        if p_Settled then
           -------------------------
           -- Paying
           -------------------------
           XTR_SETTLEMENT_SUMMARY_P.INS_SETTLEMENT_SUMMARY(l_settle_no,
                                                           ARec_IAC.COMPANY_CODE,
                                                           ARec_IAC.CURRENCY,
                                                           -ARec_IAC.TRANSFER_AMOUNT, -- PAY amount
                                                           l_settle_date,             -- settlement_date
                                                           ARec_IAC.ACCOUNT_NO_FROM,  -- PAY account
                                                           ARec_IAC.ACCOUNT_NO_TO,    -- REC account
                                                           null,
                                                           'A',
                                                           fnd_global.user_id,        -- created_by
                                                           G_sys_date,                -- creation_date
                                                           ARec_IAC.External_Source,
                                                           ARec_IAC.COMPANY_CODE,     -- cparty code
                                                           l_dummy_num);
           -------------------------
           -- Receiving
           -------------------------
           XTR_SETTLEMENT_SUMMARY_P.INS_SETTLEMENT_SUMMARY(l_settle_no2,
                                                           ARec_IAC.COMPANY_CODE,
                                                           ARec_IAC.CURRENCY,
                                                           ARec_IAC.TRANSFER_AMOUNT,  -- REC amount
                                                           l_settle_date,             -- settlement_date
                                                           ARec_IAC.ACCOUNT_NO_TO,    -- REC account
                                                           ARec_IAC.ACCOUNT_NO_FROM,  -- PAY account
                                                           null,
                                                           'A',
                                                           fnd_global.user_id,        -- created_by
                                                           G_sys_date,                -- creation_date
                                                           ARec_IAC.External_Source,
                                                           ARec_IAC.COMPANY_CODE,     -- cparty code
                                                           l_dummy_num);
        end if;

  end;  /*  INS_DEAL_DATE_AMTS  */


  -----------------------------------------------------------------------------------------------------
  --* Table Handler For Xtr_Interroup_Transfers For Inserting Row
  procedure CREATE_IAC_DEAL(ARec_IAC      IN  XTR_INTERACCT_TRANSFERS%rowtype,
                            p_Validated   IN  BOOLEAN,
                            p_tran_num    IN  NUMBER) is
  -----------------------------------------------------------------------------------------------------
     cursor EXP_TRANS_NUM is
     select XTR_EXPOSURE_TRANS_S.NEXTVAL
     from  DUAL;

     l_dual_dealer XTR_INTERACCT_TRANSFERS.DEALER_CODE%TYPE;
     l_dual_date   DATE;

  begin
/*
     open  EXP_TRANS_NUM;
     fetch EXP_TRANS_NUM into p_tran_num;
     close EXP_TRANS_NUM;
*/

     if p_Validated then
        l_dual_dealer := ARec_IAC.DEALER_CODE;
        l_dual_date   := G_sys_date;
     else
        l_dual_dealer := null;
        l_dual_date   := null;
     end if;

     Insert into XTR_INTERACCT_TRANSFERS(
                         ACCOUNT_NO_FROM,
                         ACCOUNT_NO_TO,
                         COMPANY_CODE,
                         CURRENCY,
                         DEAL_SUBTYPE,
                         DEAL_TYPE,
                         PORTFOLIO_CODE,
                         PRODUCT_TYPE,
                         STATUS_CODE,
                         TRANSFER_AMOUNT,
                         TRANSFER_DATE,
                         TRANSACTION_NUMBER,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATED_BY,
                         LAST_UPDATE_DATE,
                         LAST_UPDATE_LOGIN,
                         DUAL_AUTHORISATION_BY,
                         DUAL_AUTHORISATION_ON,
                         DEAL_DATE,
                         DEALER_CODE,
		         REQUEST_ID,
		         PROGRAM_APPLICATION_ID,
		         PROGRAM_ID,
		         PROGRAM_UPDATE_DATE,
                         EXTERNAL_SOURCE)
		Values ( ARec_IAC.ACCOUNT_NO_FROM,
                         ARec_IAC.ACCOUNT_NO_TO,
                         ARec_IAC.COMPANY_CODE,
                         ARec_IAC.CURRENCY,
                         ARec_IAC.DEAL_SUBTYPE,      -- DEAL_SUBTYPE
                         ARec_IAC.DEAL_TYPE,         -- DEAL_TYPE
                         ARec_IAC.PORTFOLIO_CODE,
                         ARec_IAC.PRODUCT_TYPE,
                         ARec_IAC.STATUS_CODE,       -- STATUS_CODE
                         ARec_IAC.TRANSFER_AMOUNT,
                         ARec_IAC.TRANSFER_DATE,
                         p_tran_num,                 -- TRANSACTION_NUMBER
                         G_sys_date,                 -- CREATION_DATE
                         fnd_global.user_id,         -- CREATED_BY
                         fnd_global.user_id,         -- LAST_UPDATED_BY
                         G_sys_date,                 -- LAST_UPDATE_DATE
                         fnd_global.user_id,         -- LAST_UPDATE_LOGIN
                         l_dual_dealer,              -- DUAL_AUTHORIZATION_BY
                         l_dual_date,                -- DUAL_AUTHORIZATION_ON
                         ARec_IAC.DEAL_DATE,         -- DEAL DATE
                         ARec_IAC.DEALER_CODE,       -- DEALER_CODE
		         fnd_global.conc_request_id,
		         fnd_global.prog_appl_id,
		         fnd_global.conc_program_id,
		         G_sys_date,
                         ARec_IAC.EXTERNAL_SOURCE);

  end;  /*  CREATE_IAC_DEAL  */

  -----------------------------------------------------------------------------------------------------
  --* Main procedure for Import Deal Record that calls all the validation APIs
  --* and then finally calls the Insert Table Handler.
  procedure TRANSFER_IAC_DEALS( ARec_IAC           IN  XTR_INTERACCT_TRANSFERS%rowtype,
                                p_Validated        IN  BOOLEAN,
                                p_Settled          IN  BOOLEAN,
                                user_error         OUT NOCOPY BOOLEAN,
                                mandatory_error    OUT NOCOPY BOOLEAN,
                                validation_error   OUT NOCOPY BOOLEAN,
                                p_tran_num         OUT NOCOPY NUMBER) is
  -----------------------------------------------------------------------------------------------------

     cursor FIND_USER (p_fnd_user in number) is
     select dealer_code
     from   xtr_dealer_codes_v
     where  user_id = p_fnd_user;

     cursor USER_ACCESS (l_comp VARCHAR2) is
     select 1
     from   xtr_parties_v
     where  party_type = 'C'
     and    party_code = l_comp;

     cursor EXP_TRANS_NUM is
     select XTR_EXPOSURE_TRANS_S.NEXTVAL
     from  DUAL;

     l_dummy          NUMBER;
     l_bank_code_from xtr_deal_date_amounts.limit_party%TYPE;
     l_bank_code_to   xtr_deal_date_amounts.limit_party%TYPE;

  begin

     -------------------------
     --  Initialise Variables
     -------------------------
     p_tran_num         := null;
     user_error         := FALSE;
     mandatory_error    := FALSE;
     validation_error   := FALSE;

     open  FIND_USER(fnd_global.user_id);
     fetch FIND_USER into G_iac_user;
     close FIND_USER;

     Select sysdate, trunc(sysdate)
     into   G_sys_date, G_iac_date
     From   Dual;

     ----------------------------------------------------------------------------------------------------
     --* The following code checks if user has permissions to transfer the deal (company authorization)
     ----------------------------------------------------------------------------------------------------
     open  USER_ACCESS(ARec_IAC.company_code);
     fetch USER_ACCESS into l_dummy;
     if USER_ACCESS%NOTFOUND then
        Log_IAC_errors('XTR_INV_COMP_CODE');
        user_error := TRUE;
     end if;
     close USER_ACCESS;

     if (user_error <> TRUE) then

           --------------------------------------------------------------------------------
           --* The following code does mandatory field validation specific to the IAC deals
           --------------------------------------------------------------------------------
           CHECK_MANDATORY_FIELDS(ARec_IAC,mandatory_error);

           if (mandatory_error <> TRUE) then

              --------------------------------------------------------------------------------------
              --* The following code performs the business logic validation specific to the IAC deals
              --------------------------------------------------------------------------------------
              VALIDATE_DEALS(ARec_IAC, l_Bank_Code_From, l_Bank_Code_To, validation_error);

           end if; /* Checking Mandatory values */

     end if;   /* Checking User Auth */

    /*----------------------------------------------------------------------------------------------*/
    /* If the process passed all the previous validation, it would be considered a valid deal entry */
    /*----------------------------------------------------------------------------------------------*/
     if user_error  <> TRUE and mandatory_error  <> TRUE and validation_error <> TRUE then

           open  EXP_TRANS_NUM;
           fetch EXP_TRANS_NUM into p_tran_num;
           close EXP_TRANS_NUM;


           INS_DEAL_DATE_AMTS (ARec_IAC,
                               l_Bank_Code_From,
                               l_Bank_code_To,
                               p_tran_num,
                               p_Validated,
                               p_Settled);

           CREATE_IAC_DEAL    (ARec_IAC,
                               p_Validated,
                               p_tran_num);

           XTR_MISC_P.MAINT_PROJECTED_BALANCES;

     end if;

  end;  /*  TRANSFER_IAC_DEALS  */


END XTR_IAC_TRANSFERS_PKG;


/
