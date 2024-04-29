--------------------------------------------------------
--  DDL for Package Body XTR_IG_TRANSFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_IG_TRANSFERS_PKG" AS
/* $Header: xtrimigb.pls 120.21 2005/06/29 09:53:26 csutaria ship $ */


  -------------------------------------------------------------------------------------------------------------------
  Procedure Log_IG_Errors(p_Ext_Deal_Id   In Varchar2,
                          p_Deal_Type     In Varchar2,
                          p_Error_Column  In Varchar2,
                          p_Error_Code    In Varchar2,
                          p_Field_Name    In Varchar2) is
  -------------------------------------------------------------------------------------------------------------------

     cursor c_text is
     select text
     from   xtr_sys_languages_vl
     where  item_name = p_Field_Name;

     p_text xtr_sys_languages_vl.text%TYPE;

  begin

     if G_Ig_Source is null and nvl(G_Ig_External_Source,'@@@') not in (C_ZBA, C_CL) then
        xtr_import_deal_data.log_interface_errors(p_ext_deal_id,
                                                  p_deal_type,
                                                  p_error_column,
                                                  p_error_code);

     else
        if p_Error_Code in ('XTR_MANDATORY',             'XTR_INV_LIMIT_CODE',
                            'XTR_IMP_DEAL_REVAL_EXIST',  'XTR_IMP_DEAL_ACCRUAL_EXIST',
                            'XTR_LIMIT_EXCEEDED','XTR_INV_DESC_FLEX_API','XTR_INV_DESC_FLEX_CONTEXT',
                            'XTR_INV_DESC_FLEX') then
           -------------------------------
           -- Get the dynamic prompt text.
           -------------------------------
           open  c_text;
           fetch c_text into p_text;
           close c_text;

           if p_Error_code = 'XTR_MANDATORY' then
              FND_MESSAGE.Set_Name('XTR','XTR_MANDATORY_FIELD');   -- AW new message
              FND_MESSAGE.Set_Token('FIELD', p_text);

           elsif p_Error_code = 'XTR_INV_LIMIT_CODE' then
              FND_MESSAGE.Set_Name('XTR','XTR_INV_LIMIT_CODE_FIELD');   -- AW new message
              FND_MESSAGE.Set_Token('LIMIT_CODE', p_text);

           elsif p_Error_code = 'XTR_IMP_DEAL_REVAL_EXIST' then
	      FND_MESSAGE.Set_Name ('XTR', 'XTR_DEAL_REVAL_DONE');
              FND_MESSAGE.Set_Token ('DATE',p_field_name);

           elsif p_Error_code = 'XTR_IMP_DEAL_ACCRUAL_EXIST' then
              FND_MESSAGE.Set_Name ('XTR', 'XTR_DEAL_ACCRLS_EXIST');
              FND_MESSAGE.Set_Token ('DATE',p_field_name);

           elsif p_Error_code in ('XTR_INV_DESC_FLEX_API','XTR_INV_DESC_FLEX_CONTEXT','XTR_INV_DESC_FLEX') then
              FND_MESSAGE.Set_Name ('XTR', 'XTR_INV_DESC_FLEX_API');

           elsif p_Error_code = 'XTR_LIMIT_EXCEEDED' then
              null;  -- do nothing, return error to calling form to handle limits checks.

           end if;
        else
           FND_MESSAGE.Set_Name('XTR', p_Error_Code);
        end if;

        --*****************************************************************************************************************
        -- 3800146 Modified for ZBA and CL   ******************************************************************************
        --*****************************************************************************************************************
        -- Populate message to stack for CE to retrieve
        if nvl(G_Ig_External_Source,'@@@') in (C_ZBA, C_CL) then
           fnd_msg_pub.add;
           --dbms_output.put_line('imig   Error  = '|| p_error_code||'   : '||p_field_name);
        else
           APP_EXCEPTION.raise_exception;
        end if;

     end if;

  end;


/* RV: 2229236 */
/*-------------------------------------------------------------------------------------*/
/*             The following function returns the total outstanding balance for the    */
/*             deal including the current transaction for doign limit check            */
/*-------------------------------------------------------------------------------------*/
-----------------------------------------------------------------------------------------
 function GET_LIMIT_AMOUNT (p_company_code  	IN  VARCHAR2 ,
                           p_party_code   	IN  VARCHAR2 ,
                           p_currency     	IN  VARCHAR2 ,
                           p_adjust             IN  NUMBER   ,
                           p_action_code        IN  VARCHAR2) return number is
-----------------------------------------------------------------------------------------
 cursor ins_bal is
    Select sum(cashflow_amount) balance
    from   xtr_deal_date_amounts
    where  cparty_code = p_party_code
    and    company_code = p_company_code
    and    currency = p_currency
    and    deal_type = 'IG'
    and    amount_type = 'PRINFLW';

    l_balance NUMBER;

 begin
      open  ins_bal;
      fetch ins_bal into l_balance;
      close ins_bal;

   if p_action_code = 'PAY' then
      l_balance := nvl(-l_balance,0)+nvl(p_adjust,0);
   else
      l_balance := nvl(-l_balance,0)-nvl(p_adjust,0);
   end if;

   return (nvl(l_balance,0));
 exception
    when others then
      if ins_bal%ISOPEN then close ins_bal;end if;
         return (0);
 end;


  /* RV: 2229236 */
  -----------------------------------------------------------------------------------------------------
  function IS_COMPANY(p_comp   IN VARCHAR2) return boolean is
  -----------------------------------------------------------------------------------------------------
     cursor curs(c_comp IN VARCHAR2) is
     select 'Y'
     from   XTR_PARTIES_V
     where  party_code   = c_comp
     and    party_type = 'C';

     l_dummy	VARCHAR2(1);

  begin
     open  curs (p_comp);
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

  /* RV: 2229236 */
 -----------------------------------------------------------------------------------------------------
  function IS_MIRROR_DEAL(p_comp IN VARCHAR2,
                          p_cparty   IN VARCHAR2,
                          p_curr     IN VARCHAR2) return boolean is
 -----------------------------------------------------------------------------------------------------
   cursor mirror_deal(c_comp   IN Xtr_Intergroup_Transfers.Company_Code%type,
  	 	      c_cparty IN Xtr_Intergroup_Transfers.Party_Code%type,
  		      c_curr   IN Xtr_Intergroup_Transfers.Currency%type) is
     select mirror_Deal
     from   xtr_intergroup_transfers
     where  company_Code = c_comp
     and    party_Code 	 = c_cparty
     and    currency 	 = c_curr
     and    mirror_Deal  = 'Y';

     l_dummy	VARCHAR2(1);

  begin
     open mirror_deal(p_comp, p_cparty, p_curr);
     fetch mirror_deal into l_dummy;
     if mirror_deal%NOTFOUND then
        close mirror_deal;
   	return(FALSE);
     else
        close mirror_deal;
        return(TRUE);
     end if;

  exception
     when others then
	if mirror_deal%ISOPEN then close mirror_deal; end if;
  	   return(FALSE);
  end;

  -----------------------------------------------------------------------------------------------------
 --* Procedure to update pricing model of all transactions with the same deal number (ie. same company,
 --* counterparty, and currency)
 procedure UPDATE_PRICING_MODEL(p_company_code VARCHAR2,
                                p_party_code VARCHAR2,
                                p_currency VARCHAR2,
                                p_pricing_model VARCHAR2) is
-----------------------------------------------------------------------------------------------------
   cursor get_pricing_model is
   select pricing_model, deal_number
   from xtr_intergroup_transfers_v
   where company_code = p_company_code
   and party_code = p_party_code
   and currency = p_currency;

   l_deal_number NUMBER;
   l_pricing_model VARCHAR2(30);

BEGIN
   open get_pricing_model;
   fetch get_pricing_model into l_pricing_model, l_deal_number;
   close get_pricing_model;

   if l_deal_number is not null AND p_pricing_model <> l_pricing_model then
      UPDATE xtr_intergroup_transfers
      SET pricing_model = p_pricing_model
      WHERE deal_number = l_deal_number;
   end if;
END;

-----------------------------------------------------------------------------------------------------
 --* Procedure to return the default pricing model given a company, counterparty, currency and
 --* product type.  First, if only one pricing model is authorized, that is the default.  If one or
 --* more are authorized, the pricing model for transactions under the same deal number is the default.
 --* If no such deal exists, default is based on the product type.  If default pricing model is null
 --* for this product type, we compare currency to SOB Currency of the company.  If two currencies
 --* are equal, default is 'NO_REVAL'.  If different, default is 'FACE_VALUE'.
procedure DEFAULT_PRICING_MODEL(p_company_code IN VARCHAR2,
                                p_party_code IN VARCHAR2,
                                p_currency IN VARCHAR2,
                                p_product_type IN VARCHAR2,
                                p_pricing_model OUT NOCOPY VARCHAR2) is
-----------------------------------------------------------------------------------------------------
   cursor get_pricing_model is
   select pricing_model
   from   xtr_intergroup_transfers_v
   where  company_code = p_company_code
   and    party_code = p_party_code
   and    currency = p_currency;

   cursor default_pm is
   select default_pricing_model
   from   xtr_product_types_v
   where  deal_type = 'IG'
   and    product_type = p_product_type;

   cursor number_of_auth_pm is
   select count(*)
   from   xtr_price_models
   where  deal_type = 'IG'
   and    authorized = 'Y';

   cursor auth_pm is
   select code
   from   xtr_price_models
   where  deal_type = 'IG'
   and    authorized = 'Y';

   cursor get_sob_currency is
   select sob.currency_code
   from   xtr_party_info pinfo, gl_sets_of_books sob
   where  pinfo.party_code = p_company_code
   and    pinfo.set_of_books_id = sob.set_of_books_id;

   l_pm VARCHAR2(30);
   l_dummy NUMBER;
   l_sob_currency VARCHAR2(30);

BEGIN

   open number_of_auth_pm;
   fetch number_of_auth_pm into l_dummy;
   close number_of_auth_pm;
   if l_dummy = 1 then
      open auth_pm;
      fetch auth_pm into p_pricing_model;
      close auth_pm;
   else
      open get_pricing_model;
      fetch get_pricing_model into l_pm;
      close get_pricing_model;
      if l_pm is not null then
         p_pricing_model := l_pm;
      else
         open default_pm;
         fetch default_pm into l_pm;
         close default_pm;
         if l_pm is not null then
            p_pricing_model := l_pm;
         else
            open get_sob_currency;
            fetch get_sob_currency into l_sob_currency;
            close get_sob_currency;
            if l_sob_currency <> p_currency then
               p_pricing_model := 'FACE_VALUE';
            else
               p_pricing_model := 'NO_REVAL';
            end if;
         end if;
      end if;
   end if;
END;


/* RV: 2229236 */
/*-------------------------------------------------------------------------------------*/
/*             The following code implements the duplicate deal check                  */
/*             by best match for the mirror deal                                       */
/*-------------------------------------------------------------------------------------*/
-----------------------------------------------------------------------------------------
procedure CHECK_MIRROR_DUPLICATE(p_company_code     IN  VARCHAR2,
                                 p_party_code       IN  VARCHAR2,
                                 p_currency         IN  VARCHAR2,
                                 p_transfer_date    IN  DATE,
                                 p_action_code 	    IN  VARCHAR2,
                                 p_principal_adjust IN  NUMBER,
                                 p_company_account  IN  VARCHAR2,
                                 p_party_account    IN  VARCHAR2,
                                 duplicate_error    OUT NOCOPY BOOLEAN) is
-----------------------------------------------------------------------------------------
l_count NUMBER;

begin
   select count(*)
   into   l_count
   from   XTR_INTERGROUP_TRANSFERS
   where  company_code        = 	p_company_code
   and    party_code          = 	p_party_code
   and    currency            = 	p_currency
   and    transfer_date       = 	p_transfer_Date
   and    principal_action    = 	p_action_code
   and    principal_adjust    = 	p_principal_adjust
   and    company_account_no  = 	p_companY_account
   and    party_account_no    = 	p_party_account;

   if (l_count > 0) then
      duplicate_error := TRUE;
   else
      duplicate_error := FALSE;
   end if;

end CHECK_MIRROR_DUPLICATE;


--RV 2229236
  ------------------------------------------------------------------------------------
  --  Local procedure to insert Jornal structures for new IG deals
  --  Flows
  procedure INS_IG_JRNL_STRUC(p_company_code  IN  VARCHAR2,
                              p_party_code    IN  VARCHAR2,
                              p_currency      IN  VARCHAR2,
                              p_party_acct    IN VARCHAR2) is
  ------------------------------------------------------------------------------------

  Cursor ig_jrnl(comp_code     IN VARCHAR2,
                 party_code    IN VARCHAR2,
                 currency      IN VARCHAR2,
                 party_acct_no IN VARCHAR2) is
  select 'Y'
  from    xtr_ig_journal_structures
  where   company_code = comp_code
  and     cparty_code  = party_code
  and     cp_currency  = currency
  and     cp_acct_no   = party_acct_no;

  Cursor party_dtls(party_code    IN VARCHAR2,
                    party_acct_no IN VARCHAR2) is
  select currency
  from   xtr_bank_Accounts
  where  account_number = party_acct_no
  and    party_code = party_code;

  l_jrnl          VARCHAR2(1);
  l_jrnl_struc_id NUMBER;
  l_currency 	  VARCHAR2(15);

begin

   open   ig_jrnl(p_company_code,p_party_code,p_currency,p_party_acct);
   fetch  ig_jrnl into l_jrnl;
   close  ig_jrnl;

   if l_jrnl is null then

      select xtr_ig_journal_structures_s.nextval into l_jrnl_struc_id from dual;

      open   party_dtls(p_party_code,p_party_acct);
      fetch  party_dtls into l_currency;
      close  party_dtls;

      insert into xtr_ig_journal_structures(                         xtr_ig_journal_structure_id,company_code,cparty_code,
         cp_currency,cp_acct_no,created_by,creation_Date,last_updated_by,
         last_update_date,last_update_login)
      values (l_jrnl_struc_id,p_company_code,p_party_code,
         l_currency,p_party_acct,FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,
         SYSDATE,FND_GLOBAL.LOGIN_ID);
    end if;
end;


  -----------------------------------------------------------------------------------------------------
  function VALID_CPARTY_CODE(p_comp   IN VARCHAR2,
                             p_cparty IN VARCHAR2) return boolean is
  -----------------------------------------------------------------------------------------------------
     cursor curs(c_comp IN VARCHAR2, c_cparty IN VARCHAR2) is
     select 'Y'
     from   XTR_PARTIES_V
     where  party_code   = c_cparty
     and  ((internal_pty = 'Y' and cross_ref_to_other_party = c_comp)
     or    (party_type = 'C'   and party_code <> c_comp));

     l_dummy	VARCHAR2(1);

  begin
     open  curs (p_comp , p_cparty);
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
  function VALID_TRANSFER_DATE(p_transfer_date IN DATE) return boolean is
  -----------------------------------------------------------------------------------------------------

  begin
     -- bug 3305424 - relax restriction on transfer_date
     return(TRUE);

  end;


  -----------------------------------------------------------------------------------------------------
  function VALID_CURRENCY(p_curr IN VARCHAR2) return boolean is
  -----------------------------------------------------------------------------------------------------
	cursor  curs(c_curr IN VARCHAR2) is
  	select 	ig_year_basis
	from 	XTR_MASTER_CURRENCIES_V
	where   currency = c_curr
	and 	nvl(authorised, 'N') = 'Y';



  begin
	open curs (p_curr);
	fetch curs into G_Ig_year_calc_type;
	if curs%NOTFOUND then
   	   close curs;
	   return(FALSE);
	else
   	   close curs;
           G_Ig_year_calc_type := nvl(G_Ig_year_calc_type,'ACTUAL/ACTUAL');
           return(TRUE);
	end if;

  exception
	when others then
	   if curs%ISOPEN then close curs; end if;
	      return(FALSE);
  end;


  -----------------------------------------------------------------------------------------------------
  function VALID_COMP_ACCT(p_comp      IN VARCHAR2,
                           p_comp_acct IN VARCHAR2,
                           p_curr      IN VARCHAR2) return boolean is
  -----------------------------------------------------------------------------------------------------
	cursor  curs(c_comp IN VARCHAR2, c_comp_acct IN VARCHAR2, c_curr IN VARCHAR2) is
  	select 	'Y'
	from 	XTR_COMPANY_ACCT_LOV_V
	where 	company_code    = c_comp
	and	account_number  = c_comp_acct
        and     currency        = c_curr;

	l_dummy	VARCHAR2(1);

  begin
	open curs (p_comp, p_comp_acct, p_curr);
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
                            p_curr       IN VARCHAR2) return boolean is
  -----------------------------------------------------------------------------------------------------
	cursor  curs(c_party      IN VARCHAR2,
                     c_curr       IN VARCHAR2,
                     c_party_acct IN VARCHAR2) is
	select 	'Y'
	from 	XTR_BANK_ACCOUNTS_V
	where 	party_code 	    = c_party
	and 	currency 	    = c_curr
	and	account_number 	    = c_party_acct
        and     nvl(authorised,'N') = 'Y'
        and     nvl(setoff_account_yn,'N') <> 'Y'
	and	bank_code IS NOT NULL;
	/* Bug 4322706 Added the last AND condition. */

	l_dummy	VARCHAR2(1);

  begin
	open curs (p_party, p_curr, p_party_acct);
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
  function VALID_ACTION(p_action IN VARCHAR2) return boolean is
  -----------------------------------------------------------------------------------------------------
	cursor  curs(c_action IN VARCHAR2) is
	select 	ACTION_CODE
	from 	XTR_AMOUNT_ACTIONS
	where 	deal_type        = 'IG'
	and 	amount_type      = 'PRINFLW'
	and  ( (user_action_code = c_action and nvl(G_Ig_External_Source,'@@@') not in (C_ZBA, C_CL)) or
	            (action_code = c_action and nvl(G_Ig_External_Source,'@@@')     in (C_ZBA, C_CL)) ); -- 3800146 actual code

  begin
	open curs (p_action);
	fetch curs into G_Ig_action;
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
  function VALID_PRODUCT(p_product IN VARCHAR2) return boolean is
  -----------------------------------------------------------------------------------------------------
	cursor  curs(c_product in varchar2) is
	select 	'Y'
	from 	XTR_AUTH_PRODUCT_TYPES_V
	where 	deal_type    = 'IG'
	and 	Product_Type = c_product;

	l_dummy	VARCHAR2(1);

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
                           p_cparty    IN VARCHAR2,
                           p_portfolio IN VARCHAR2) return boolean is
  -----------------------------------------------------------------------------------------------------
	cursor curs(c_comp in varchar2, c_cparty in varchar2, c_portfolio in varchar2) is
	select 	'Y'
	from 	XTR_PORTFOLIOS_V
	where 	company_code    = c_comp
	and 	nvl(cmf_yn,'N') = 'N'
	and    (external_party is null or external_party = c_cparty)
	and 	portfolio       = c_portfolio;

	l_dummy	VARCHAR2(1);

  begin
	open curs (p_comp, p_cparty, p_portfolio);
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

 --------------------------------------------------------------------------------------------
 FUNCTION VALID_PRICING_MODEL(p_pricing_model IN VARCHAR2) return BOOLEAN is
 --------------------------------------------------------------------------------------------
    cursor cur_pricing is
    select code
    from   xtr_price_models
    where  code        = p_pricing_model
    and    deal_type   = 'IG'
    and    nvl(authorized,'N') = 'Y';

    l_dummy VARCHAR2(30);

 BEGIN
    open cur_pricing;
    fetch cur_pricing into l_dummy;
    if cur_pricing%NOTFOUND then
       close cur_pricing;
       return(FALSE);
    end if;
    close cur_pricing;
    return(TRUE);

 END VALID_PRICING_MODEL;


-- Bug 2994712

/*--------------------------------------------------------------------------------*/
FUNCTION valid_deal_linking_code( p_deal_linking_code IN varchar2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_temp varchar2(1);
BEGIN
	IF p_deal_linking_code is not null then
	    BEGIN
		select 'Y'
		into l_temp
		from xtr_deal_linking_v
		where deal_linking_code = p_deal_linking_code
		and rownum = 1;
	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		return(FALSE);
	    END;
        END IF;
	return TRUE;
END valid_deal_linking_code;

-- Bug 2994712

-- Bug 2684411
/*--------------------------------------------------------------------------------*/
FUNCTION valid_dealer_code(p_dealer_code        IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_temp varchar2(1);
BEGIN
	BEGIN
		select 'Y'
		into l_temp
		from xtr_dealer_codes_v
		where dealer_code = p_dealer_code
		and rownum = 1;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		return(FALSE);
	END;
	return(TRUE);
END valid_dealer_code;

-- Bug 2684411


/*----------------2549633--------------*/
  -----------------------------------------------------------------------------------------------------
  function VALID_DAY_COUNT_TYPE(p_day_count_type IN VARCHAR2) return boolean is
  -----------------------------------------------------------------------------------------------------
        l_dummy NUMBER;
  begin
        select count(*)
        into   l_dummy
        from   fnd_lookups
        where  lookup_type='XTR_DAY_COUNT_TYPE'
        and    lookup_code=p_day_count_type;

        if (l_dummy=1) then
          return(TRUE);
        else
          return(FALSE);
        end if;
  end;

  -----------------------------------------------------------------------------------------------------
  function VALID_ROUNDING_TYPE(p_rounding_type IN VARCHAR2) return boolean is
  -----------------------------------------------------------------------------------------------------
        l_dummy NUMBER;
  begin
        select count(*)
        into   l_dummy
        from   fnd_lookups
        where  lookup_type='XTR_ROUNDING_TYPE'
        and    lookup_code=p_rounding_type;

        if (l_dummy=1) then
          return(TRUE);
        else
          return(FALSE);
        end if;
  end;

/*----------------2549633--------------*/

  -----------------------------------------------------------------------------------------------------
  function VALID_LIMIT_CODE(p_comp       IN VARCHAR2,
                            p_cparty     IN VARCHAR2,
                            p_limit      IN VARCHAR2,
                            p_limit_type IN VARCHAR2) return boolean is
                          --p_balance    IN NUMBER) return boolean is
  -----------------------------------------------------------------------------------------------------
	cursor curs(c_comp in varchar2, c_cparty in varchar2, c_limit in varchar2, c_limit_type in varchar2) is
	select	'Y'
	from 	xtr_counterparty_limits_v a,
		xtr_limit_types_v         b
	where 	a.company_code 	= c_comp
	and 	a.cparty_code 	= c_cparty
	and 	a.limit_code    = c_limit
	and 	a.limit_type 	= b.limit_type
        and     nvl(a.authorised,'N') = 'Y'
	and    (a.expiry_date > G_Ig_curr_date or a.expiry_date is null )
	and   ((b.fx_invest_fund_type in ('F','X') and c_limit_type = 'FUND')
	or     (b.fx_invest_fund_type in ('I','X') and c_limit_type = 'INVEST'));
      --and   ((b.fx_invest_fund_type='F' and c_balance < 0)
      --or     (b.fx_invest_fund_type='I' and c_balance > 0) or c_balance = 0)

	l_dummy	VARCHAR2(1);

  begin

     if p_limit is not null then
	open curs (p_comp, p_cparty, p_limit, p_limit_type);
	fetch curs into l_dummy;
	if curs%NOTFOUND then
  	   close curs;
           return(FALSE);
	else
           close curs;
           return(TRUE);
	end if;

     else
        return(TRUE);
     end if;

  exception
	when others then
	   if curs%ISOPEN then close curs; end if;
  	      return(FALSE);
  end;

  -----------------------------------------------------------------------------------------------------
  function VALID_PRINCIPAL_ADJUST(p_value IN NUMBER) return boolean is
  -----------------------------------------------------------------------------------------------------
  begin
	if nvl(p_value,0) < 0 then
	   return(FALSE);
	else
  	   return(TRUE);
	end if;
  end;

  -----------------------------------------------------------------------------------------------------
  function VALID_SETTLEMENT_FLAG(p_value IN VARCHAR2) return boolean is  -- 3800146
  -----------------------------------------------------------------------------------------------------
  begin
	if nvl(p_value,'N') not in ('Y','N') then
	   return(FALSE);
	else
  	   return(TRUE);
	end if;
  end;


  -----------------------------------------------------------------------------------------------------
  function VALID_COMP_REPORTING_CCY (p_comp IN VARCHAR2) return boolean is
  -----------------------------------------------------------------------------------------------------
        cursor RND_FAC is
        select 'Y'
        from   xtr_PARTIES_v p,
               xtr_MASTER_CURRENCIES_v m
        where  p.PARTY_CODE = p_comp
        and    m.CURRENCY   = p.HOME_CURRENCY;

        l_dummy  VARCHAR2(1);

  begin

        open RND_FAC;
        fetch RND_FAC into l_dummy;
        if RND_FAC%NOTFOUND then
           close RND_FAC;
           return(FALSE);
   	end if;
   	close RND_FAC;
        return(TRUE);

  end;


  -----------------------------------------------------------------------------------------------------
  procedure VALID_IG_ACCT(p_comp          IN VARCHAR2,
                          p_cparty        IN VARCHAR2,
                          p_curr          IN VARCHAR2,
                          p_transfer_date IN DATE,
                          p_ext_deal_no   IN VARCHAR2,
                          p_deal_type     IN VARCHAR2,
                          p_error         IN OUT NOCOPY BOOLEAN) is
  -----------------------------------------------------------------------------------------------------

      l_deal_no  NUMBER;
      l_tran_no  NUMBER;
      l_batch    NUMBER;

      -- Find existing reval details for this deal.
      cursor cur_reval_deal IS
      SELECT rd.batch_id
      FROM   xtr_intergroup_transfers it,
             xtr_revaluation_details rd
      WHERE  it.deal_number = l_deal_no
      AND    it.deal_number = rd.deal_no
      AND    period_to      >= p_transfer_date;    -- bug 4367386

      -- Find existing accrual details for this deal.
      cursor cur_accrl_deal IS
      SELECT r.batch_id
      FROM   xtr_batches b,
             xtr_batch_events e,
             xtr_accrls_amort r
      WHERE  r.deal_no      = l_deal_no
      AND    r.batch_id     = b.batch_id
      AND    b.batch_id     = e.batch_id
      AND    r.period_to    >= p_transfer_date  -- bug 4367386
      AND    e.event_code   = 'ACCRUAL';

   begin

      p_error := FALSE;

      ------------------------------------------
      -- Find out if this is an existing deal.
      ------------------------------------------
      GET_DEAL_TRAN_NUMBERS(p_comp,
                            p_cparty,
                            p_curr,
                            l_deal_no,
                            l_tran_no,
                            'N');  -- do not generate a new deal number

      -------------------------------------------------
      -- Validation required only for existing deal.
      -------------------------------------------------
      if l_deal_no is not null then
         Open  cur_reval_deal;
         Fetch cur_reval_deal into l_batch;
         Close cur_reval_deal;
         if l_batch is NOT NULL THEN
            Log_IG_Errors(p_ext_deal_no,p_deal_type,'DateA','XTR_IMP_DEAL_REVAL_EXIST',
                          to_char(p_transfer_date));
            p_error := TRUE;
         End If;

         Open  cur_accrl_deal;
         Fetch cur_accrl_deal into l_batch;
         Close cur_accrl_deal;
         If l_batch is NOT NULL THEN
            Log_IG_Errors(p_ext_deal_no,p_deal_type,'DateA','XTR_IMP_DEAL_ACCRL_EXIST',
                          to_char(p_transfer_date));
            p_error := TRUE;
         End If;

      end if;

   end;  /*  VALID_IG_ACCT  */


  -----------------------------------------------------------------------------------------------------
  --* procedure to copy the values from interface record to Ig Record
  procedure COPY_FROM_INTERFACE_TO_IG(ARec_Interface IN XTR_DEALS_INTERFACE%rowtype ) is
  -----------------------------------------------------------------------------------------------------
  begin

	G_Ig_Main_Rec.ACCUM_INTEREST_BF              := 0 ;
	G_Ig_Main_Rec.ACCUM_INTEREST_BF_HCE          := 0 ;
	G_Ig_Main_Rec.BALANCE_BF                     := 0 ;
	G_Ig_Main_Rec.BALANCE_BF_HCE                 := 0 ;
	G_Ig_Main_Rec.BALANCE_OUT                    := 0 ;
	G_Ig_Main_Rec.BALANCE_OUT_HCE                := 0 ;
	G_Ig_Main_Rec.COMMENTS                       := null;
	G_Ig_Main_Rec.COMPANY_ACCOUNT_NO             := null;
	G_Ig_Main_Rec.COMPANY_CODE                   := null;
	G_Ig_Main_Rec.CREATED_BY                     := null;
	G_Ig_Main_Rec.CREATED_ON                     := null;
	G_Ig_Main_Rec.CURRENCY                       := null;
	G_Ig_Main_Rec.DEAL_NUMBER                    := 0 ;
	G_Ig_Main_Rec.DEAL_TYPE                      := null;
	G_Ig_Main_Rec.INTEREST                       := 0 ;
	G_Ig_Main_Rec.INTEREST_HCE                   := 0 ;
	G_Ig_Main_Rec.INTEREST_RATE                  := 0 ;
	G_Ig_Main_Rec.INTEREST_SETTLED               := 0 ;
	G_Ig_Main_Rec.INTEREST_SETTLED_HCE           := 0 ;
	G_Ig_Main_Rec.LIMIT_CODE                     := null;
	G_Ig_Main_Rec.LIMIT_CODE_INVEST              := null;
	G_Ig_Main_Rec.COMMENTS                       := null;
	G_Ig_Main_Rec.NO_OF_DAYS                     := 0 ;
	G_Ig_Main_Rec.PARTY_ACCOUNT_NO               := null;
	G_Ig_Main_Rec.PARTY_CODE                     := null;
	G_Ig_Main_Rec.PORTFOLIO                      := null;
	G_Ig_Main_Rec.PRINCIPAL_ACTION               := null;
	G_Ig_Main_Rec.PRINCIPAL_ADJUST               := 0 ;
	G_Ig_Main_Rec.PRINCIPAL_ADJUST_HCE           := 0 ;
	G_Ig_Main_Rec.PRODUCT_TYPE                   := null;
        G_Ig_Main_Rec.PRICING_MODEL                  := null;
	G_Ig_Main_Rec.SETTLE_DATE                    := null;
	G_Ig_Main_Rec.TRANSACTION_NUMBER             := 0 ;
	G_Ig_Main_Rec.TRANSFER_DATE                  := null;
	G_Ig_Main_Rec.UPDATED_BY                     := null;
	G_Ig_Main_Rec.UPDATED_ON                     := null;
	G_Ig_Main_Rec.ACCRUAL_INTEREST               := 0 ;
	G_Ig_Main_Rec.FIRST_BATCH_ID                 := null ;
	G_Ig_Main_Rec.LAST_BATCH_ID                  := null ;
	G_Ig_Main_Rec.ATTRIBUTE_CATEGORY             := null;
	G_Ig_Main_Rec.ATTRIBUTE1                     := null;
	G_Ig_Main_Rec.ATTRIBUTE2                     := null;
	G_Ig_Main_Rec.ATTRIBUTE3                     := null;
	G_Ig_Main_Rec.ATTRIBUTE4                     := null;
	G_Ig_Main_Rec.ATTRIBUTE5                     := null;
	G_Ig_Main_Rec.ATTRIBUTE6                     := null;
	G_Ig_Main_Rec.ATTRIBUTE7                     := null;
	G_Ig_Main_Rec.ATTRIBUTE8                     := null;
	G_Ig_Main_Rec.ATTRIBUTE9                     := null;
	G_Ig_Main_Rec.ATTRIBUTE10                    := null;
	G_Ig_Main_Rec.ATTRIBUTE11                    := null;
	G_Ig_Main_Rec.ATTRIBUTE12                    := null;
	G_Ig_Main_Rec.ATTRIBUTE13                    := null;
	G_Ig_Main_Rec.ATTRIBUTE14                    := null;
	G_Ig_Main_Rec.ATTRIBUTE15                    := null;
	G_Ig_Main_Rec.EXTERNAL_DEAL_ID               := null;
	G_Ig_Main_Rec.REQUEST_ID                     := 0 ;
	G_Ig_Main_Rec.PROGRAM_APPLICATION_ID         := 0 ;
	G_Ig_Main_Rec.PROGRAM_ID                     := 0 ;
	G_Ig_Main_Rec.PROGRAM_UPDATE_DATE            := null;
--* Add for Interest Override project
	G_Ig_Main_Rec.ROUNDING_TYPE		     := null;
	G_Ig_Main_Rec.DAY_COUNT_TYPE		     := null;
	G_Ig_Main_Rec.ORIGINAL_AMOUNT		     := 0;
        G_Ig_Main_Rec.DEAL_LINKING_CODE              := null;   -- Bug 2994712
	G_Ig_Main_Rec.DEALER_CODE		     := null;   -- Bug 2684411
	G_Ig_Main_Rec.EXTERNAL_SOURCE                := null;   -- Bug 3800146  -- *******************************************************

--*	==============================================================================================
--*
--*	Column Mapping from Interface Table To the InterGroup Transfers Table
--*
--*	Description                     Int Column           		IG Column
--*     ------------------------------  --------------------------  	-------------------
--*	External ID			EXTERNAL_DEAL_ID		EXTERNAL_DEAL_ID
--*	Deal Type			DEAL_TYPE			DEAL_TYPE
--*	Transfer Date			DATE_A				TRANSFER_DATE
--*	Company				COMPANY_CODE			COMPANY_CODE
--*	Intercompany Party		CPARTY_CODE			PARTY_CODE
--*	Currency			CURRENCY_A			CURRENCY
--*	Company Account			ACCOUNT_NO_A			COMPANY_ACCOUNT_NO
--*	Party Account			ACCOUNT_NO_B			PARTY_ACCOUNT_NO
--*	Action				ACTION_CODE			PRINCIPAL_ACTION
--*	Principal Adjust		AMOUNT_A			PRINCIPAL_ADJUST
--*	Product Type			PRODUCT_TYPE			PRODUCT_TYPE
--*     Pricing Model                   PRICING_MODEL                   PRICING_MODEL
--*	Portfolio			PORTFOLIO_CODE			PORTFOLIO
--*	Fund Limit			LIMIT_CODE			LIMIT_CODE
--*	Invest Limit                    LIMIT_CODE_B  		        LIMIT_CODE_INVEST
--*	Comments                        COMMENTS                        COMMENTS
--*	Interest Rate			RATE_A				INTEREST_RATE
--*	Descriptive Flexfield Category	ATTRIBUTE_CATEGORY		ATTRIBUTE_CATEGORY
--*	Descriptive Flexfields		ATTRIBUTE1 - ATTRIBUTE15	ATTRIBUTE1 - ATTRIBUTE15
--*	External Source       		EXTERNAL_SOURCE         	EXTERNAL_SOURCE   -- 3800146 *****************************************************
--*
--*    	=============================================================================================
--*

	G_Ig_Main_Rec.external_deal_id 		:= ARec_Interface.external_deal_id;
	G_Ig_Main_Rec.deal_type 		:= 'IG';
	G_Ig_Main_Rec.transfer_date		:= ARec_Interface.date_a;
	G_Ig_Main_Rec.company_code 		:= ARec_Interface.company_code;
	G_Ig_Main_Rec.party_code 		:= ARec_Interface.cparty_code;
	G_Ig_Main_Rec.currency 			:= ARec_Interface.currency_a;
	G_Ig_Main_Rec.company_account_no 	:= ARec_Interface.account_no_a;
	G_Ig_Main_Rec.party_account_no 		:= ARec_Interface.account_no_b;
	G_Ig_Main_Rec.principal_action 		:= G_Ig_action;
	G_Ig_Main_Rec.principal_adjust 		:= ARec_Interface.amount_a;
	G_Ig_Main_Rec.interest_rate		:= ARec_Interface.rate_a;
	G_Ig_Main_Rec.product_type 		:= ARec_Interface.product_type;
	G_Ig_Main_Rec.pricing_model             := ARec_Interface.pricing_model;
	G_Ig_Main_Rec.portfolio		 	:= ARec_Interface.portfolio_code;
	G_Ig_Main_Rec.limit_code 		:= ARec_Interface.limit_code;
	G_Ig_Main_Rec.limit_code_invest         := ARec_Interface.limit_code_b;
	G_Ig_Main_Rec.comments                  := ARec_Interface.comments;
	G_Ig_Main_Rec.attribute_category	:= ARec_Interface.attribute_category;
	G_Ig_Main_Rec.attribute1 		:= ARec_Interface.attribute1;
	G_Ig_Main_Rec.attribute2 		:= ARec_Interface.attribute2;
	G_Ig_Main_Rec.attribute3 		:= ARec_Interface.attribute3;
	G_Ig_Main_Rec.attribute4 		:= ARec_Interface.attribute4;
	G_Ig_Main_Rec.attribute5 		:= ARec_Interface.attribute5;
	G_Ig_Main_Rec.attribute6 		:= ARec_Interface.attribute6;
	G_Ig_Main_Rec.attribute7 		:= ARec_Interface.attribute7;
	G_Ig_Main_Rec.attribute8 		:= ARec_Interface.attribute8;
	G_Ig_Main_Rec.attribute9 		:= ARec_Interface.attribute9;
	G_Ig_Main_Rec.attribute10 		:= ARec_Interface.attribute10;
	G_Ig_Main_Rec.attribute11 		:= ARec_Interface.attribute11;
	G_Ig_Main_Rec.attribute12 		:= ARec_Interface.attribute12;
	G_Ig_Main_Rec.attribute13 		:= ARec_Interface.attribute13;
	G_Ig_Main_Rec.attribute14 		:= ARec_Interface.attribute14;
	G_Ig_Main_Rec.attribute15 		:= ARec_Interface.attribute15;
--* Add for Interest Override
	G_Ig_Main_Rec.Rounding_Type		:= ARec_Interface.Rounding_Type;
	G_Ig_Main_Rec.Day_Count_Type		:= ARec_Interface.Day_Count_Type;
	G_Ig_Main_Rec.Original_Amount		:= ARec_Interface.Original_Amount;
	G_Ig_Main_Rec.Deal_Linking_Code         := ARec_Interface.Deal_Linking_Code; -- Bug 2994712
	G_Ig_Main_Rec.Dealer_Code         	:= ARec_Interface.Dealer_Code;       -- Bug 2684411
	G_Ig_Main_Rec.External_Source     	:= ARec_Interface.External_Source;   -- Bug 3800146  ************************************************

        --###########################################################################################################################
        -- 3800146 Do not default for ZBA/CL.  Mandatory check already done for ZBA/CL
        --###########################################################################################################################
	if G_Ig_Main_Rec.pricing_model is NULL and nvl(G_Ig_External_Source,'@@@') not in (C_ZBA, C_CL) then
	   DEFAULT_PRICING_MODEL(G_Ig_Main_Rec.company_code,
	                         G_Ig_Main_Rec.party_code,
	                         G_Ig_Main_Rec.currency,
	                         G_Ig_Main_Rec.product_type,
	                         G_Ig_Main_Rec.pricing_model);
        end if;
        --###########################################################################################################################

  end;  /*  COPY_FROM_INTERFACE_TO_IG  */


  -----------------------------------------------------------------------------------------------------
  --  Local procedure to calculate balance out, interest amount, num of days for each transfer.
  --  Also determine that this is the latest date for a transfer to or from this account.
  --
  procedure CALC_DETAILS is
  -----------------------------------------------------------------------------------------------------
	--
	l_trans_no    number;
	prv_date      Date;
	prv_int_rate  number;
	roundfac      number;
	yr_basis      number;

	prv_accrual_int NUMBER;
--* Add for Interest Project
 	l_day_count_type	VARCHAR2(1);
 	l_rounding_type		VARCHAR2(1);
 	l_first_trans_flag	VARCHAR2(1);
 	l_oldest_date	 	DATE;
 	l_prv_day_count_type	VARCHAR2(1);
--* Add End

	--
	cursor RND_YR is
	select ROUNDING_FACTOR
	from   xtr_MASTER_CURRENCIES_v
	where  CURRENCY = G_Ig_Main_Rec.CURRENCY;
	--
	cursor 	LATEST_DATE is
	select 	a.TRANSFER_DATE,
		a.BALANCE_OUT	,
		a.BALANCE_OUT_HCE,
		a.INTEREST_RATE,
	       	(nvl(a.ACCUM_INTEREST_BF,0) + nvl(a.INTEREST,0) - nvl(a.INTEREST_SETTLED,0)),
	       	(nvl(a.ACCUM_INTEREST_BF_HCE,0) + nvl(a.INTEREST_HCE,0) - nvl(a.INTEREST_SETTLED_HCE,0)),
	       	a.TRANSACTION_NUMBER,
	       	a.ACCRUAL_INTEREST,
		a.ROUNDING_TYPE, --* Add for Interest Project
		a.DAY_COUNT_TYPE --* Add for Interest Project
	from 	xtr_INTERGROUP_TRANSFERS_v a
	where 	a.PARTY_CODE = G_Ig_Main_Rec.PARTY_CODE
	and   	a.COMPANY_CODE = G_Ig_Main_Rec.COMPANY_CODE
	and   	a.CURRENCY = G_Ig_Main_Rec.CURRENCY
	and   	a.TRANSFER_DATE <= G_Ig_Main_Rec.TRANSFER_DATE
	order by a.TRANSFER_DATE desc, a.TRANSACTION_NUMBER desc;
	--
--* Add for Interest Project
 	cursor OLDEST_DATE is
  	 select min(TRANSFER_DATE)
    	   from xtr_intergroup_transfers
   	  where party_code = G_Ig_Main_Rec.PARTY_CODE
     	    and company_code = G_Ig_Main_Rec.COMPANY_CODE
     	    and currency = G_Ig_Main_Rec.CURRENCY;
--
	cursor PRV_DAY_COUNT_TYPE is
   	 SELECT DAY_COUNT_TYPE
     	   from XTR_INTERGROUP_TRANSFERS
    	  where company_code = G_Ig_Main_Rec.COMPANY_CODE
      	    and party_code = G_Ig_Main_Rec.PARTY_CODE
      	    and currency = G_Ig_Main_Rec.CURRENCY
      	    and transfer_date = (select max(transfer_date)
			    	   from xtr_intergroup_transfers
			   	  where company_code = G_Ig_Main_Rec.COMPANY_CODE
			     	    and party_code = G_Ig_Main_Rec.PARTY_CODE
			            and currency = G_Ig_Main_Rec.CURRENCY
			     	    and transfer_date < prv_date)
	  order by transaction_number desc;


--* Add End

  begin
	-- OLD in XTRINING.fmb ???  if Latest_Date%ISOPEN then
	-- OLD in XTRINING.fmb ???     close Latest_Date;
	-- OLD in XTRINING.fmb ???  end if;

	if G_Ig_Main_Rec.CURRENCY is NOT NULL then
		open LATEST_DATE;
	   	fetch LATEST_DATE into 	prv_date,G_Ig_Main_Rec.BALANCE_BF,G_Ig_Main_Rec.BALANCE_BF_HCE,
	       	                        prv_int_rate,G_Ig_Main_Rec.ACCUM_INTEREST_BF,
                                        G_Ig_Main_Rec.ACCUM_INTEREST_BF_HCE,l_trans_no,prv_accrual_int,
					l_rounding_type,l_day_count_type; --* Add day count type for Interest Project
	  	if LATEST_DATE%NOTFOUND then
	    		prv_date     := G_Ig_Main_Rec.TRANSFER_DATE;
	    		prv_int_rate := 0;
	    		G_Ig_Main_Rec.BALANCE_BF     := 0;
	    		G_Ig_Main_Rec.BALANCE_BF_HCE := 0;
	    		G_Ig_Main_Rec.ACCUM_INTEREST_BF     := 0;
	    		G_Ig_Main_Rec.ACCUM_INTEREST_BF_HCE := 0;
	    		prv_accrual_int :=0;
		--* Add for Interest Project
    			G_Ig_Main_Rec.ORIGINAL_AMOUNT := 0;
		--* Add End

	  	else
	    		if G_Ig_Main_Rec.TRANSACTION_NUMBER is NOT NULL then
	     			if G_Ig_Main_Rec.TRANSFER_DATE = prv_date then
	      			   loop
	       				exit when (  prv_date < G_Ig_Main_Rec.TRANSFER_DATE or
                                                   l_trans_no < G_Ig_Main_Rec.TRANSACTION_NUMBER);
	       				fetch LATEST_DATE into 	prv_date, G_Ig_Main_Rec.BALANCE_BF,
                                                                G_Ig_Main_Rec.BALANCE_BF_HCE, prv_int_rate,
                                                                G_Ig_Main_Rec.ACCUM_INTEREST_BF,
                                                                G_Ig_Main_Rec.ACCUM_INTEREST_BF_HCE,
	            			                        l_trans_no, prv_accrual_int,
								l_rounding_type,l_day_count_type;
			       		if LATEST_DATE%NOTFOUND then
	        				prv_date     := G_Ig_Main_Rec.TRANSFER_DATE;
			        		prv_int_rate := 0;
		        			G_Ig_Main_Rec.BALANCE_BF     := 0;
		        			G_Ig_Main_Rec.BALANCE_BF_HCE := 0;
			        		G_Ig_Main_Rec.ACCUM_INTEREST_BF     := 0;
			        		G_Ig_Main_Rec.ACCUM_INTEREST_BF_HCE := 0;
	        				prv_accrual_int :=0;
					--* Add for Interest Project
        					G_Ig_Main_Rec.ORIGINAL_AMOUNT := 0;
					--* Add End

	        				Exit;
	       				end if;
	      			   end loop;
	     			end if;
	    		end if;
	  	end if;

		open  RND_YR;
		fetch RND_YR into roundfac;
		close RND_YR;

		if G_Ig_Main_Rec.TRANSFER_DATE > prv_date then

		--* Add for Interest Project
		/* Decide First Transaction Flag */
		l_first_trans_flag := 'N';
		OPEN OLDEST_DATE;
		FETCH OLDEST_DATE into l_oldest_date;
		CLOSE OLDEST_DATE;

		if l_day_count_type = 'B' and l_oldest_date = prv_date then
   			l_first_trans_flag := 'Y';
		elsif (l_day_count_type = 'B' or l_day_count_type ='F')
     		   and l_oldest_date <> prv_date then

		-- Select Day Count type of previous transaction
			OPEN PRV_DAY_COUNT_TYPE;
			FETCH PRV_DAY_COUNT_TYPE into l_prv_day_count_type;
			CLOSE PRV_DAY_COUNT_TYPE;

   			if l_day_count_type = 'F' and (l_prv_day_count_type = 'B' or l_prv_day_count_type = 'L') then
      				prv_date := prv_date  + 1;
   			elsif l_day_count_type ='B' and l_prv_day_count_type = 'L' then
      				l_first_trans_flag := 'Y';
   			end if;
		end if;
		--* Add End

	  		XTR_CALC_P.CALC_DAYS_RUN(prv_date,
	    	            			 G_Ig_Main_Rec.TRANSFER_DATE,
	      	          			 G_Ig_year_calc_type,
	        	        		 G_Ig_Main_Rec.NO_OF_DAYS,
	          	      			 yr_basis,
						 null,
						 l_day_count_type,    -- Add for Interest Project
						 l_first_trans_flag); -- Add for Interest Project
		else
	  		G_Ig_Main_Rec.NO_OF_DAYS :=0;
	 		yr_basis :=365;
		end if;
-- Original Code
--		G_Ig_Main_Rec.INTEREST := round(G_Ig_Main_Rec.BALANCE_BF * prv_int_rate / 100 *
--                                                G_Ig_Main_Rec.NO_OF_DAYS / yr_basis,roundfac);

		G_Ig_Main_Rec.INTEREST := xtr_fps2_p.interest_round(G_Ig_Main_Rec.BALANCE_BF * prv_int_rate / 100 *
                                                G_Ig_Main_Rec.NO_OF_DAYS / yr_basis,roundfac,l_rounding_type);
	end if;

	if G_Ig_Main_Rec.PRINCIPAL_ADJUST is not null then
		if G_Ig_Main_Rec.PRINCIPAL_ACTION = 'PAY' then
	  	   G_Ig_Main_Rec.BALANCE_OUT := nvl(G_Ig_Main_Rec.BALANCE_BF,0)+nvl(G_Ig_Main_Rec.PRINCIPAL_ADJUST,0);
	        elsif G_Ig_Main_Rec.PRINCIPAL_ACTION = 'REC' then
	           G_Ig_Main_Rec.BALANCE_OUT := nvl(G_Ig_Main_Rec.BALANCE_BF,0)-nvl(G_Ig_Main_Rec.PRINCIPAL_ADJUST,0);
	        end if;

	        -- OLD in XTRINING.fmb ??? close LATEST_DATE;

	 	G_Ig_Main_Rec.ACCRUAL_INTEREST := nvl(prv_accrual_int,0) + nvl(G_Ig_Main_Rec.INTEREST,0);

	--* Add for Interest Project
 		G_Ig_Main_Rec.ORIGINAL_AMOUNT := nvl(G_Ig_Main_Rec.ACCUM_INTEREST_BF,0) + nvl(G_Ig_Main_Rec.INTEREST,0);
	--* Add End

	end if;

	close LATEST_DATE; -- NEW

  end;  /* CALC_DETAILS */



  -----------------------------------------------------------------------------------------------------
  procedure CALC_HCE_AMTS is
  -----------------------------------------------------------------------------------------------------
     roundfac  NUMBER(3,2);

     cursor RND_FAC is
     select m.ROUNDING_FACTOR
     from   xtr_PARTIES_v p,
            xtr_MASTER_CURRENCIES_v m
     where  p.PARTY_CODE = G_Ig_Main_Rec.COMPANY_CODE
     and    m.CURRENCY   = p.HOME_CURRENCY;

     cursor HCE_AMT is
     select nvl(round((nvl(G_Ig_Main_Rec.INTEREST,0) / s.hce_rate),roundfac),0),
            nvl(round((G_Ig_Main_Rec.PRINCIPAL_ADJUST / s.hce_rate),roundfac),0),
	    nvl(round((G_Ig_Main_Rec.BALANCE_OUT / s.hce_rate),roundfac),0),
	    nvl(round((nvl(G_Ig_Main_Rec.INTEREST_SETTLED,0) / s.hce_rate),roundfac),0)
     from   xtr_MASTER_CURRENCIES_v s
     where  s.CURRENCY = G_Ig_Main_Rec.CURRENCY;

  begin

     if G_Ig_Main_Rec.CURRENCY is NOT NULL and G_Ig_Main_Rec.COMPANY_CODE is NOT NULL then
	open  RND_FAC;
   	fetch RND_FAC into roundfac;
   	close RND_FAC;

   	open  HCE_AMT;
   	fetch HCE_AMT into G_Ig_Main_Rec.INTEREST_HCE,G_Ig_Main_Rec.PRINCIPAL_ADJUST_HCE,
                           G_Ig_Main_Rec.BALANCE_OUT_HCE,G_Ig_Main_Rec.INTEREST_SETTLED_HCE;
   	close HCE_AMT;
     end if;

  end;  /*  CALC_HCE_AMTS  */


  -----------------------------------------------------------------------------------------------------
  --  Local procedure to calculate interest amount, num of days for each
  --  transfer. Also determine that this is the latest date for a transfer
  --  to or from this account.
  procedure CALCULATE_VALUES (ARec_Interface IN   XTR_DEALS_INTERFACE%rowtype,
                              p_err_limit    OUT NOCOPY  VARCHAR2) is
  -----------------------------------------------------------------------------------------------------
  begin

     COPY_FROM_INTERFACE_TO_IG(ARec_Interface);

     CALC_DETAILS;  -- Need to calculate current transaction's BALANCE_OUT before doing CASCADE_RECALC.

     CALC_HCE_AMTS;

     -- either

/*  RV 2229236: Using function Get_Limit_Amount to get the total balance for limit check.
     CASCADE_RECALC(ARec_Interface.company_code,
                    ARec_Interface.cparty_code,
                    ARec_Interface.currency_a,
                    ARec_Interface.date_a,
                    ARec_Interface.limit_code,
                    ARec_Interface.limit_code_b,
                    'N');
                 -- p_err_limit);
*/
     /* or
     CASCADE_RECALC(G_Ig_Main_Rec.company_code,
                    G_Ig_Main_Rec.party_code,
                    G_Ig_Main_Rec.currency,
                    G_Ig_Main_Rec.transfer_date,
                    G_Ig_Main_Rec.limit_code,
                    G_Ig_Main_Rec.limit_code_invest,
                    'N');
                 -- p_err_limit);
     */

  end;


  -----------------------------------------------------------------------------------------------------
  procedure CHECK_MANDATORY_FIELDS(ARec_Interface IN XTR_DEALS_INTERFACE%rowtype, p_error OUT NOCOPY BOOLEAN) is
  -----------------------------------------------------------------------------------------------------
  begin

        p_error := FALSE;

	if ARec_Interface.company_code is null then
           log_IG_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'CompanyCode','XTR_MANDATORY','IG.COMPANY_CODE');
           p_error := TRUE;
	end if;

	if ARec_Interface.date_a is null then
           log_IG_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'DateA','XTR_MANDATORY','IG.TRANSFER_DATE');
           p_error := TRUE;
	end if;


	if ARec_Interface.cparty_code is null then
           log_IG_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'CpartyCode','XTR_MANDATORY','IG.PARTY_CODE');
           p_error := TRUE;
	end if;


	if ARec_Interface.currency_a is null then
           log_IG_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'CurrencyA','XTR_MANDATORY','IG.CURRENCY');
           p_error := TRUE;
	end if;


	if ARec_Interface.account_no_a is null then
           log_IG_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'AccountNoA','XTR_MANDATORY','IG.COMPANY_ACCOUNT_NO');
           p_error := TRUE;
	end if;


	if ARec_Interface.account_no_b is null then
           log_IG_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'AccountNoB','XTR_MANDATORY','IG_PARTY_ACCOUNT_NO');
           p_error := TRUE;
	end if;


	if ARec_Interface.action_code is null then
           log_IG_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'ActionCode','XTR_MANDATORY','IG.PRINCIPAL_ACTION_DSP');
           p_error := TRUE;
	end if;


	if ARec_Interface.amount_a is null then
           log_IG_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'AmountA','XTR_MANDATORY','IG.PRINCIPAL_ADJUST');
           p_error := TRUE;
	end if;


	if ARec_Interface.rate_a is null then
           log_IG_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'RateA','XTR_MANDATORY','IG.INTEREST_RATE');
           p_error := TRUE;
	end if;


	if ARec_Interface.product_type is null then
           log_IG_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'ProductType','XTR_MANDATORY','IG.PRODUCT_TYPE');
           p_error := TRUE;
	end if;


	if ARec_Interface.portfolio_code is null then
           log_IG_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'PortfolioCode','XTR_MANDATORY','IG.PORTFOLIO');
           p_error := TRUE;
	end if;

-- Bug 2684411
	if ARec_Interface.dealer_code is null then
           log_IG_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'DealerCode','XTR_MANDATORY','IG.DEALER_CODE');
           p_error := TRUE;
	end if;
-- Bug 2684411


 /*------------------------------------------------------ 2549633-------------------------------------------------------- */

	if ARec_Interface.rounding_type is null then
           log_IG_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'RoundingType','XTR_MANDATORY','IG.ROUNDING_TYPE');
           p_error := TRUE;
	end if;

	if ARec_Interface.day_count_type is null then
           log_IG_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'DayCountType','XTR_MANDATORY','IG.DAY_COUNT_TYPE');
           p_error := TRUE;
	end if;

 /*------------------------------------------------------ 2549633-------------------------------------------------------- */

 /*------------------------------------------------------ 2229236-------------------------------------------------------- */

        if G_Ig_Source is null AND is_company(ARec_Interface.cparty_code)
               AND ARec_Interface.mirror_portfolio_code is null then
           log_IG_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'MirrorPortfolioCode','XTR_MANDATORY','IG.MIRROR_PORTFOLIO_CODE');
           p_error := TRUE;
	end if;

        if G_Ig_Source is null AND is_company(ARec_Interface.cparty_code)
               AND ARec_Interface.mirror_product_type is null then
           log_IG_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'MirrorProductType','XTR_MANDATORY','IG.MIRROR_PRODUCT_TYPE');
           p_error := TRUE;
	end if;

-- Bug 2684411
        if G_Ig_Source is null AND is_company(ARec_Interface.cparty_code)
	       AND ARec_Interface.mirror_dealer_code is null then
           log_IG_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'MirrorDealerCode','XTR_MANDATORY','IG.MIRROR_DEALER_CODE');
           p_error := TRUE;
	end if;
-- Bug 2684411


 /*------------------------------------------------------ 2229236-------------------------------------------------------- */

        --************************************************************************************************
        -- 3800146 Mandatory Check Pricing Model for ZBA/CL
        --************************************************************************************************

	if nvl(G_Ig_External_Source,'@@@') in (C_ZBA,C_CL) and ARec_Interface.pricing_model is null then
           log_IG_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     null,'XTR_MANDATORY','IG.PRICING_MODEL');
           p_error := TRUE;
	end if;

	if nvl(G_Ig_External_Source,'@@@') in (C_ZBA,C_CL) and IS_COMPANY(ARec_Interface.cparty_code) and
           ARec_Interface.mirror_pricing_model is null then
           log_IG_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     null,'XTR_MANDATORY','IG.PRICING_MODEL');  -- same prompt as main deal
           p_error := TRUE;
	end if;
        --************************************************************************************************


  end;  /*  CHECK_MANDATORY_FIELDS  */


  -----------------------------------------------------------------------------------------------------
  procedure VALIDATE_DEALS(ARec_Interface IN XTR_DEALS_INTERFACE%rowtype, p_error  OUT NOCOPY BOOLEAN) is
  -----------------------------------------------------------------------------------------------------
     l_err_segment     	      VARCHAR2(30);
     l_err_cparty  	      BOOLEAN := FALSE;
     l_err_currency  	      BOOLEAN := FALSE;
     l_err_accounting 	      BOOLEAN := FALSE;
     l_mirror_err_accounting  BOOLEAN := FALSE;
     l_err_limit       	      VARCHAR2(10) := NULL;
     l_zba_duplicate          BOOLEAN := FALSE;  -- 3800146

  begin

     p_error := FALSE;

     if not valid_cparty_code(ARec_Interface.Company_Code,ARec_Interface.CParty_Code) then
        Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                  'CpartyCode','XTR_INV_INTERCOMPANY');
        p_error      := TRUE;
        l_err_cparty := TRUE;
     end if;


     if not valid_transfer_date(ARec_Interface.Date_A) then
        Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                  'DateA','XTR_104');
        p_error := TRUE;
     end if;


     if not valid_currency(ARec_Interface.Currency_A) then
        Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                  'CurrencyA','XTR_INV_CURR');
        p_error := TRUE;
        l_err_currency := TRUE;
     end if;


     -----------------------------------------------------------------------------------------
     --* The following code performs the accounting logic validation specific to the IG deals
     -----------------------------------------------------------------------------------------
     VALID_IG_ACCT(ARec_Interface.company_code,
                   ARec_Interface.cparty_code,
                   ARec_Interface.currency_a,
                   ARec_Interface.date_a,
                   ARec_Interface.external_deal_id,
                   ARec_Interface.deal_type,
                   l_err_accounting);


     IF l_err_accounting = TRUE THEN

        p_error := TRUE;

     else

        if not valid_comp_reporting_ccy(ARec_Interface.company_code) then
           Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'CompanyCode','XTR_880');
           p_error := TRUE;
        end if;


        if l_err_currency <> TRUE then
           if not valid_comp_acct(ARec_Interface.Company_Code, ARec_Interface.Account_No_A,
                                  ARec_Interface.Currency_A) then
              Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                        'AccountNoA','XTR_INV_COMP_ACCT_NO');
              p_error := TRUE;
           end if;
        end if;


        if l_err_cparty <> TRUE and l_err_currency <> TRUE then
           if not valid_party_acct(ARec_Interface.CParty_Code, ARec_Interface.Account_No_B,
                                   ARec_Interface.Currency_A) then
              Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                        'AccountNoB','XTR_INV_PARTY_ACCT_NO');
              p_error := TRUE;
           end if;
        end if;


        if not valid_action(ARec_Interface.Action_Code) then
           Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'ActionCode','XTR_INV_ACTION');
           p_error := TRUE;
        end if;


        if not valid_product(ARec_Interface.Product_Type) then
           Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'ProductType','XTR_INV_PRODUCT_TYPE');
           p_error := TRUE;
        end if;

--Bug 2994712
        if not valid_deal_linking_code(ARec_Interface.Deal_Linking_Code) then
           Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'DealLinkingCode','XTR_INV_LINKING_CODE');
           p_error := TRUE;
        end if;
--Bug 2994712

--Bug 2684411
        if not valid_dealer_code(ARec_Interface.Dealer_Code) then
           Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'DealerCode','XTR_INV_DEALER_CODE');
           p_error := TRUE;
        end if;
--Bug 2684411

        if not valid_pricing_model(ARec_Interface.Pricing_Model) then
           Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                              'PricingModel','XTR_INV_PRICING_MODEL');
	/* Bug 4319476 */
	p_error := TRUE;
        end if;

        if l_err_cparty <> TRUE then
           if not valid_portfolio(ARec_Interface.Company_Code,ARec_Interface.CParty_Code,
                                  ARec_Interface.Portfolio_Code) then
              Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                        'PortfolioCode','XTR_INV_PORT_CODE');
              p_error := TRUE;
           end if;
        end if;


        if not valid_principal_adjust(ARec_Interface.Amount_A) then
           Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'AmountA','XTR_56');
           p_error := TRUE;
        end if;

        --------------------------------------------------------------------------
        -- 3800146 Settlement Flag
        --------------------------------------------------------------------------
        if not valid_settlement_flag(ARec_Interface.settlement_flag) then
           Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'SettlementFlag','FND_CP_ITEM_YES_NO');
           p_error := TRUE;
        end if;


        /*------------------------------------------------------ 2549633-------------------------------------------------------- */

        if not valid_rounding_type(ARec_Interface.Rounding_Type) then
           Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'RoundingType','XTR_INV_ROUNDING_TYPE');
           p_error := TRUE;
        end if;

        if not valid_day_count_type(ARec_Interface.Day_Count_Type) then
           Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'DayCountType','XTR_INV_DAY_COUNT_TYPE');
           p_error := TRUE;
        end if;

        /*------------------------------------------------------ 2549633-------------------------------------------------------- */


/*---------------------------------------------------------------------------------------*/
        if G_Ig_Source is null AND is_company(ARec_Interface.cparty_code) then
           VALID_IG_ACCT(ARec_Interface.cparty_code,
                         ARec_Interface.company_code,
                	 ARec_Interface.currency_a,
             	         ARec_Interface.date_a,
               		 ARec_Interface.external_deal_id,
                         ARec_Interface.deal_type,
                         l_mirror_err_accounting);
           if l_mirror_err_accounting = TRUE then
              p_error := TRUE;
           else

              if not valid_product(ARec_Interface.Mirror_Product_Type) then
                 Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'MirrorProductType','XTR_INV_PRODUCT_TYPE');
                 p_error := TRUE;
              end if;

              if not valid_portfolio(ARec_Interface.CParty_Code,ARec_Interface.Company_Code,
                               ARec_Interface.Mirror_Portfolio_Code) then
                 Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'MirrorPortfolioCode','XTR_INV_PORT_CODE');
                 p_error := TRUE;
              end if;

              if not valid_pricing_model(ARec_Interface.Mirror_Pricing_Model) then
                 Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'MirrorPricingModel','XTR_INV_PRICING_MODEL');
                 p_error := TRUE;
              end if;

-- Bug 2994712
              if not valid_deal_linking_code(ARec_Interface.Mirror_Deal_Linking_Code) then
                 Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'MirrorDealLinkingCode','XTR_INV_LINKING_CODE');
                 p_error := TRUE;
              end if;
-- Bug 2994712

-- Bug 2684411
              if not valid_dealer_code(ARec_Interface.Mirror_Dealer_Code) then
                 Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                     'MirrorDealerCode','XTR_INV_DEALER_CODE');
                 p_error := TRUE;
              end if;
-- Bug 2684411


              if ARec_Interface.mirror_limit_code_fund   is not null or
                 ARec_Interface.mirror_limit_code_invest is not null then

                 --------------------------------
                 -- Check individual limit code
                 --------------------------------
                 if ARec_Interface.mirror_limit_code_fund is not null and
                         not valid_limit_code(ARec_Interface.cparty_code,ARec_Interface.company_code,
                                             ARec_Interface.mirror_limit_code_fund,'FUND') then
                    Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                            'MirrorLimitCodeFund','XTR_INV_LIMIT_CODE','IG.LIMIT_CODE');
                    l_err_limit := 'FUND';
                    p_error     := TRUE;
                 end if;

                 if ARec_Interface.mirror_limit_code_invest is not null and
                      not valid_limit_code(ARec_Interface.cparty_code,ARec_Interface.company_code,
                                          ARec_Interface.mirror_limit_code_invest,'INVEST') then
                    Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                               'MirrorLimitCodeInvest','XTR_INV_LIMIT_CODE','IG.LIMIT_CODE_INVEST');
                    l_err_limit := 'INVEST';
                    p_error     := TRUE;
                 end if;
              end if;
        end if; /*  l_mirror_err_accounting = TRUE */
      end if;

      /*---------------------------------------------------------------------------------------*/


        --*****************************************************************************************************************
        -- 3800146 Skip DFF validation for ZBA/Cash Leveling   ************************************************************
        --*****************************************************************************************************************
        if nvl(G_Ig_External_Source,'@@@') not in (C_ZBA,C_CL) then

           if not ( xtr_import_deal_data.val_desc_flex(ARec_Interface,'XTR_IG_DESC_FLEX',l_err_segment)) then
              p_error := TRUE;
              if l_err_segment is not null and l_err_segment = 'Attribute16' then
                 Log_IG_Errors( ARec_Interface.external_deal_id,
                                                            ARec_Interface.deal_type,
                                                            l_err_segment,
                                                            'XTR_INV_DESC_FLEX_API');
              elsif l_err_segment is not null and l_err_segment = 'AttributeCategory' then
                 Log_IG_Errors( ARec_Interface.external_deal_id,
                                                            ARec_Interface.deal_type,
                                                            l_err_segment,
                                                            'XTR_INV_DESC_FLEX_CONTEXT');
              else
                 Log_IG_Errors( ARec_Interface.external_deal_id,
                                                            ARec_Interface.deal_type,
                                                            l_err_segment,
                                                            'XTR_INV_DESC_FLEX');
              end if;
           end if;

        end if;
        ------------------------------------------------------------------------------------------------------


        IF l_err_cparty <> TRUE THEN

           --#########################################################################################################################
           --   3800146  ZBA Duplicate check based on FINAL actual values (after Derivation but before ANY calculation)
           --#########################################################################################################################
           l_zba_duplicate := FALSE;
           if nvl(G_Ig_External_Source,'@@@') = C_ZBA then
              XTR_WRAPPER_API_P.CHK_ZBA_IG_DUPLICATE (ARec_Interface.company_code,          -- p_company_code,
                                                      ARec_Interface.cparty_code,           -- p_intercompany_code,
                                                      ARec_Interface.currency_a,            -- p_currency,
                                                      ARec_Interface.amount_a,              -- p_transfer_amount,
                                                      ARec_Interface.date_a,                -- p_transfer_date,
                                                      ARec_Interface.action_code,           -- p_action_code,
                                                      ARec_Interface.portfolio_code,        -- p_company_portfolio,
                                                      ARec_Interface.product_type,          -- p_company_product_type,
                                                      ARec_Interface.mirror_portfolio_code, -- p_intercompany_portfolio,
                                                      ARec_Interface.mirror_product_type,   -- p_intercompany_product_type,
                                                      ARec_Interface.account_no_a,          -- p_company_account_no,
                                                      ARec_Interface.account_no_b,          -- p_party_account_no,
                                                      l_zba_duplicate);
           end if;
           --########################################################################################################################

           IF l_zba_duplicate THEN
                                     -- #################  Duplicate Error ########################
                    p_error := TRUE; -- #################  Duplicate Error ########################
                                     -- #################  Duplicate Error ########################
           else
                    IF ARec_Interface.limit_code   is not null OR
                       ARec_Interface.limit_code_b is not null THEN

                          --------------------------------
                          -- Check individual limit code
                          --------------------------------
                          if ARec_Interface.limit_code is not null and
                             not valid_limit_code(ARec_Interface.company_code, ARec_Interface.cparty_code,
                                                                               ARec_Interface.limit_code,'FUND') then
                             Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                           'LimitCode','XTR_INV_LIMIT_CODE','IG.LIMIT_CODE');
                             l_err_limit := 'FUND';
                             p_error     := TRUE;
                          end if;

                          if ARec_Interface.limit_code_b is not null and
                             not valid_limit_code(ARec_Interface.company_code, ARec_Interface.cparty_code,
                                                                               ARec_Interface.limit_code_b,'INVEST') then
                             Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                           'LimitCodeB','XTR_INV_LIMIT_CODE','IG.LIMIT_CODE_INVEST');
                             l_err_limit := 'INVEST';
                             p_error     := TRUE;
                          end if;

                          IF l_err_limit is null THEN  -- ***********  No limit Error  ****************

                             ----------------------------
                             -- Calculate Balance
                             ----------------------------                    -- #################  I M P O R T A N T  !!!  #################
                             CALCULATE_VALUES(ARec_Interface, l_err_limit);  -- #################  I M P O R T A N T  !!!  #################
                                                                             -- #################  I M P O R T A N T  !!!  #################
                          END IF;  /* l_err_limit is null */

                    END IF;  /* ARec_Interface.limit_code or ARec_Interface.limit_code_b is not null */

           END IF;  /* duplicate check for ZBA only */

        END IF;  /* l_err_cparty <> TRUE */

     END IF;  /*  l_err_accounting = TRUE */

  end;    /* VALIDATE_DEALS  */



  -----------------------------------------------------------------------------------------------------
  -- Generate a new deal number if p_new_deal = 'Y', otherwise find out if this is existing IG deal.
  -----------------------------------------------------------------------------------------------------
  procedure GET_DEAL_TRAN_NUMBERS(p_comp     IN VARCHAR2,
                                  p_cparty   IN VARCHAR2,
                                  p_curr     IN VARCHAR2,
  				  p_deal_no  IN OUT NOCOPY NUMBER,
                                  p_tran_no  IN OUT NOCOPY NUMBER,
                                  p_new_deal IN VARCHAR2) is
  -----------------------------------------------------------------------------------------------------
     cursor deal_number_cursor(c_comp   IN Xtr_Intergroup_Transfers.Company_Code%type,
  			       c_cparty IN Xtr_Intergroup_Transfers.Party_Code%type,
  			       c_curr   IN Xtr_Intergroup_Transfers.Currency%type) is
     select deal_number,
  	    transaction_number
     from   xtr_intergroup_transfers
     where  company_Code 	= c_comp
     and    party_Code 	= c_cparty
     and    currency 	= c_curr
     order by transaction_number desc;

     cursor new_deal_num is
     select XTR_DEALS_S.nextval
     from   dual;

  begin

     p_deal_no := null;

     open deal_number_cursor(p_comp, p_cparty, p_curr);
     fetch deal_number_cursor into p_deal_no, p_tran_no;
     if deal_number_cursor%NOTFOUND and nvl(p_new_deal,'Y') = 'Y' then

  	--* No Deal Exists in that combination , so need to
  	--* create a new deal number and the transaction number will
  	--* be incremented then on.
  	--*
    	open  new_deal_num;
    	fetch new_deal_num into p_deal_no;
        close new_deal_num;
        p_tran_no := 1;

     else
     	p_tran_no := p_tran_no + 1;
     end if;

     close deal_number_cursor;

  end;  /*  GET_DEAL_TRAN_NUMBERS  */


  -----------------------------------------------------------------------------------------------------
  --* Table Handler For Xtr_Interroup_Transfers For Inserting Row
  procedure CREATE_IG_DEAL(ARec_IG  IN  XTR_INTERGROUP_TRANSFERS%rowtype ) is
  -----------------------------------------------------------------------------------------------------
  begin

     Insert into XTR_INTERGROUP_TRANSFERS(
			 EXTERNAL_DEAL_ID               ,
			 ACCUM_INTEREST_BF              ,
			 ACCUM_INTEREST_BF_HCE          ,
			 BALANCE_BF                     ,
			 BALANCE_BF_HCE                 ,
			 BALANCE_OUT                    ,
			 BALANCE_OUT_HCE                ,
			 COMMENTS                       ,
			 COMPANY_ACCOUNT_NO             ,
			 COMPANY_CODE                   ,
			 CREATED_BY                     ,
			 CREATED_ON                     ,
			 CURRENCY                       ,
			 DEAL_NUMBER                    ,
			 DEAL_TYPE                      ,
			 INTEREST                       ,
			 INTEREST_HCE                   ,
			 INTEREST_RATE                  ,
			 INTEREST_SETTLED               ,
			 INTEREST_SETTLED_HCE           ,
			 LIMIT_CODE                     ,
			 LIMIT_CODE_INVEST              ,
			 NO_OF_DAYS                     ,
			 PARTY_ACCOUNT_NO               ,
			 PARTY_CODE                     ,
			 PORTFOLIO                      ,
			 PRINCIPAL_ACTION               ,
			 PRINCIPAL_ADJUST               ,
			 PRINCIPAL_ADJUST_HCE           ,
			 PRODUCT_TYPE                   ,
			 PRICING_MODEL                  ,
			 SETTLE_DATE                    ,
			 TRANSACTION_NUMBER             ,
			 TRANSFER_DATE                  ,
			 ACCRUAL_INTEREST               ,
			 FIRST_BATCH_ID                 ,
			 LAST_BATCH_ID                  ,
			 ATTRIBUTE_CATEGORY             ,
			 ATTRIBUTE1                     ,
			 ATTRIBUTE2                     ,
			 ATTRIBUTE3                     ,
			 ATTRIBUTE4                     ,
			 ATTRIBUTE5                     ,
			 ATTRIBUTE6                     ,
			 ATTRIBUTE7                     ,
			 ATTRIBUTE8                     ,
			 ATTRIBUTE9                     ,
			 ATTRIBUTE10                    ,
			 ATTRIBUTE11                    ,
			 ATTRIBUTE12                    ,
			 ATTRIBUTE13                    ,
			 ATTRIBUTE14                    ,
			 ATTRIBUTE15                    ,
			 REQUEST_ID                     ,
			 PROGRAM_APPLICATION_ID         ,
			 PROGRAM_ID                     ,
			 PROGRAM_UPDATE_DATE            ,
                         MIRROR_DEAL                    ,
                         MIRROR_DEAL_NUMBER             ,
                         MIRROR_TRANSACTION_NUMBER      ,
			 ROUNDING_TYPE			,
			 DAY_COUNT_TYPE			,
			 ORIGINAL_AMOUNT		,
			 UPDATED_BY			,
			 UPDATED_ON                     ,
                         DEAL_LINKING_CODE              ,
                         DEALER_CODE,
                         EXTERNAL_SOURCE    -- 3800146  -- **********************************************************************************
			 )
			 Values
		       (
			 decode(G_Ig_External_Source,null,ARec_IG.EXTERNAL_DEAL_ID,null), -- 3800146 not needed for ZBA/CL  ******************************
			 ARec_IG.ACCUM_INTEREST_BF              ,
			 ARec_IG.ACCUM_INTEREST_BF_HCE          ,
			 ARec_IG.BALANCE_BF                     ,
			 ARec_IG.BALANCE_BF_HCE                 ,
			 ARec_IG.BALANCE_OUT                    ,
			 ARec_IG.BALANCE_OUT_HCE                ,
			 ARec_IG.COMMENTS                       ,
			 ARec_IG.COMPANY_ACCOUNT_NO             ,
			 ARec_IG.COMPANY_CODE                   ,
			 G_Ig_user                              ,
			 G_Ig_SysDate                           ,
			 ARec_IG.CURRENCY                       ,
			 ARec_IG.DEAL_NUMBER			,
			 ARec_IG.DEAL_TYPE                      ,
			 ARec_IG.INTEREST                       ,
			 ARec_IG.INTEREST_HCE                   ,
			 ARec_IG.INTEREST_RATE                  ,
			 ARec_IG.INTEREST_SETTLED               ,
			 ARec_IG.INTEREST_SETTLED_HCE           ,
			 ARec_IG.LIMIT_CODE                     ,
			 ARec_IG.LIMIT_CODE_INVEST              ,
			 ARec_IG.NO_OF_DAYS                     ,
			 ARec_IG.PARTY_ACCOUNT_NO               ,
			 ARec_IG.PARTY_CODE                     ,
			 ARec_IG.PORTFOLIO                      ,
			 ARec_IG.PRINCIPAL_ACTION               ,
			 ARec_IG.PRINCIPAL_ADJUST               ,
			 ARec_IG.PRINCIPAL_ADJUST_HCE           ,
			 ARec_IG.PRODUCT_TYPE                   ,
			 ARec_IG.PRICING_MODEL                  ,
			 ARec_IG.SETTLE_DATE                    ,
			 ARec_IG.TRANSACTION_NUMBER		,
			 ARec_IG.TRANSFER_DATE                  ,
			 ARec_IG.ACCRUAL_INTEREST               ,
			 ARec_IG.FIRST_BATCH_ID                 ,
			 ARec_IG.LAST_BATCH_ID                  ,
			 ARec_IG.ATTRIBUTE_CATEGORY             ,
			 ARec_IG.ATTRIBUTE1                     ,
			 ARec_IG.ATTRIBUTE2                     ,
			 ARec_IG.ATTRIBUTE3                     ,
			 ARec_IG.ATTRIBUTE4                     ,
			 ARec_IG.ATTRIBUTE5                     ,
			 ARec_IG.ATTRIBUTE6                     ,
			 ARec_IG.ATTRIBUTE7                     ,
			 ARec_IG.ATTRIBUTE8                     ,
			 ARec_IG.ATTRIBUTE9                     ,
			 ARec_IG.ATTRIBUTE10                    ,
			 ARec_IG.ATTRIBUTE11                    ,
			 ARec_IG.ATTRIBUTE12                    ,
			 ARec_IG.ATTRIBUTE13                    ,
			 ARec_IG.ATTRIBUTE14                    ,
			 ARec_IG.ATTRIBUTE15                    ,
			 fnd_global.conc_request_id             ,
			 fnd_global.prog_appl_id                ,
			 fnd_global.conc_program_id             ,
			 G_Ig_SysDate                           ,
                         G_Ig_mirror_deal                       ,
                         G_Ig_orig_deal_no                      ,
                         G_Ig_orig_trans_no                     ,
			 ARec_IG.ROUNDING_TYPE			,
			 ARec_IG.DAY_COUNT_TYPE			,
			 Arec_IG.ORIGINAL_AMOUNT		,
--                       ARec_IG.MIRROR_DEAL                    ,
--                       Arec_IG.MIRROR_DEAL_NUMBER             ,
--                       Arec_IG.MIRROR_TRANSACTION_NUMBER	,
			 G_Ig_user                              ,
			 G_Ig_SysDate                           ,
                         Arec_IG.DEAL_LINKING_CODE              ,
                         Arec_IG.DEALER_CODE,
                         Arec_IG.EXTERNAL_SOURCE    -- 3800146   *************************************************************************
			 );

     UPDATE_PRICING_MODEL(ARec_IG.COMPANY_CODE,
                          ARec_IG.PARTY_CODE,
                          ARec_IG.CURRENCY,
                          ARec_IG.PRICING_MODEL);

  end;  /*  CREATE_IG_DEAL  */

--****************************************************************************************************
--  3800146 To settle a cashflow   *******************************************************************
--****************************************************************************************************
procedure SETTLE_DDA (p_settle_flag   IN  VARCHAR2,
                      p_actual_settle IN  DATE,
                      p_settle        OUT NOCOPY VARCHAR2,
                      p_settle_no     OUT NOCOPY NUMBER,
                      p_settle_auth   OUT NOCOPY VARCHAR2,
                      p_settle_date   OUT NOCOPY DATE,
                      p_trans_mts     OUT NOCOPY VARCHAR2,
                      p_audit_indic   OUT NOCOPY VARCHAR2) is

begin


   if nvl(p_settle_flag,'N') = 'Y' then  -- NOTE : Current IG form does not pass in value but it calls this for mirror deal.

      select XTR_SETTLEMENT_NUMBER_S.NEXTVAL into p_settle_no from DUAL;

      p_settle      := 'Y';
      p_settle_auth := G_Ig_user;
      p_settle_date := p_actual_settle;
      p_trans_mts   := 'Y';
      p_audit_indic := 'Y';

   else

      p_settle      := 'N';
      p_settle_no   := null;
      p_settle_auth := null;
      p_settle_date := null;
      p_trans_mts   := null;
      p_audit_indic := null;

   end if;

end;

  -----------------------------------------------------------------------------------------------------
  --  Local procedure to insert Deal Date Rows for Principal  Interest
  --  Flows
  procedure INS_DEAL_DATE_AMTS is
  -----------------------------------------------------------------------------------------------------

     l_settle          VARCHAR2(1);
     l_settle_no       NUMBER;
     l_settle_auth     xtr_deal_date_amounts.SETTLEMENT_AUTHORISED_BY%TYPE;
     l_settle_date     DATE;
     l_trans_mts       VARCHAR2(1);
     l_audit_indic     VARCHAR2(1);
     l_dummy_num       NUMBER;
     l_dummy_err       VARCHAR2(80);

  begin
     if G_Ig_Main_Rec.PRINCIPAL_ADJUST <> 0 then

        --*****************************************************************************************************************
        -- 3800146  For settlement.  Only affects PRINFLW   ***************************************************************
        --*****************************************************************************************************************
        SETTLE_DDA (G_Ig_settlement_flag,
                    G_Ig_Main_Rec.TRANSFER_DATE,
                    l_settle,
                    l_settle_no,
                    l_settle_auth,
                    l_settle_date,
                    l_trans_mts,
                    l_audit_indic);
        --*****************************************************************************************************************

        insert into xtr_DEAL_DATE_AMOUNTS_v
             (DEAL_TYPE,AMOUNT_TYPE,DATE_TYPE,DEAL_NUMBER,TRANSACTION_NUMBER,
             TRANSACTION_DATE,CURRENCY,AMOUNT,HCE_AMOUNT,AMOUNT_DATE,
             CASHFLOW_AMOUNT,COMPANY_CODE,ACCOUNT_NO,ACTION_CODE,CPARTY_ACCOUNT_NO,
             STATUS_CODE,CPARTY_CODE,
             SETTLE,SETTLEMENT_NUMBER,SETTLEMENT_AUTHORISED_BY,ACTUAL_SETTLEMENT_DATE,TRANS_MTS,AUDIT_INDICATOR, -- 3800146 ******************
             DEAL_SUBTYPE,PRODUCT_TYPE, PORTFOLIO_CODE,
             dual_authorisation_by, dual_authorisation_on)
             ---,LIMIT_CODE)
        values
            ('IG','PRINFLW','COMENCE',G_Ig_Main_Rec.DEAL_NUMBER,G_Ig_Main_Rec.TRANSACTION_NUMBER,
             G_Ig_curr_date,G_Ig_Main_Rec.CURRENCY,abs(G_Ig_Main_Rec.PRINCIPAL_ADJUST),
             abs(G_Ig_Main_Rec.PRINCIPAL_ADJUST_HCE),G_Ig_Main_Rec.TRANSFER_DATE,
             decode(G_Ig_Main_Rec.COMPANY_ACCOUNT_NO,NULL,0,
             decode(G_Ig_Main_Rec.PRINCIPAL_ACTION,'PAY',(-1) * G_Ig_Main_Rec.PRINCIPAL_ADJUST,
             G_Ig_Main_Rec.PRINCIPAL_ADJUST)),G_Ig_Main_Rec.COMPANY_CODE,
             G_Ig_Main_Rec.COMPANY_ACCOUNT_NO,G_Ig_Main_Rec.PRINCIPAL_ACTION,G_Ig_Main_Rec.PARTY_ACCOUNT_NO,
             'CURRENT',G_Ig_Main_Rec.PARTY_CODE,
             l_settle,l_settle_no,l_settle_auth,l_settle_date,l_trans_mts,l_audit_indic,  -- 3800146 *******************************
             decode(G_Ig_Main_Rec.PRINCIPAL_ACTION,'PAY',
             'INVEST','FUND'),G_Ig_Main_Rec.PRODUCT_TYPE,G_Ig_Main_Rec.PORTFOLIO,
             G_Ig_user, G_Ig_curr_date);

        --*****************************************************************************************************************
        -- 3800146  For settlement.  **************************************************************************************
        --*****************************************************************************************************************
         if nvl(G_Ig_settlement_flag,'N') = 'Y' then
           -- Condition Added Bug 4313886
            if(G_Ig_Main_Rec.PRINCIPAL_ACTION = 'PAY') then

            XTR_SETTLEMENT_SUMMARY_P.INS_SETTLEMENT_SUMMARY(l_settle_no,
                                                            G_Ig_Main_Rec.COMPANY_CODE,
                                                            G_Ig_Main_Rec.CURRENCY,
                                                            (-1) * G_Ig_Main_Rec.PRINCIPAL_ADJUST,
                                                            l_settle_date,              -- settlement date
                                                            G_Ig_Main_Rec.COMPANY_ACCOUNT_NO,
                                                            G_Ig_Main_Rec.PARTY_ACCOUNT_NO,
                                                            null,
                                                            'A',
                                                            G_Ig_user_id,
                                                            G_Ig_curr_date,             -- creation date
                                                            G_Ig_External_Source,
                                                            G_Ig_Main_Rec.PARTY_CODE,   -- cparty code
                                                            l_dummy_num);
            else

            XTR_SETTLEMENT_SUMMARY_P.INS_SETTLEMENT_SUMMARY(l_settle_no,
                                                            G_Ig_Main_Rec.COMPANY_CODE,
                                                            G_Ig_Main_Rec.CURRENCY,
                                                            G_Ig_Main_Rec.PRINCIPAL_ADJUST,
                                                            l_settle_date,              -- settlement date
                                                            G_Ig_Main_Rec.COMPANY_ACCOUNT_NO,
                                                            G_Ig_Main_Rec.PARTY_ACCOUNT_NO,
                                                            null,
                                                            'A',
                                                            G_Ig_user_id,
                                                            G_Ig_curr_date,             -- creation date
                                                            G_Ig_External_Source,
                                                            G_Ig_Main_Rec.PARTY_CODE,   -- cparty code
                                                            l_dummy_num);
            end if;
            ------------------------
            -- Workflow Notification
            ------------------------
            if nvl(G_Main_log_id,0) <> 0 then
               XTR_LIMITS_P.UPDATE_LIMIT_EXCESS_LOG(l_settle_no,
                                                    null,
                                                    G_Ig_user,
                                                    G_Main_log_id);

      	       XTR_WORKFLOW_PKG.START_WORKFLOW('XTR_LIMITS_NOTIFICATION','XTR',G_Ig_Main_Rec.DEAL_NUMBER,
                                               G_Ig_Main_Rec.TRANSACTION_NUMBER, 'IG',G_Main_log_id);
            end if;
         end if;

     end if; -- G_Ig_Main_Rec.PRINCIPAL_ADJUST <> 0

     /*-----------------------------------------------------------------*/
     /* This will not be executed for Open API since interest is zero.  */
     /*-----------------------------------------------------------------*/
     if nvl(G_Ig_Main_Rec.INTEREST_SETTLED,0) <> 0 then

        insert into xtr_DEAL_DATE_AMOUNTS_v
	           (DEAL_TYPE,AMOUNT_TYPE,DATE_TYPE,DEAL_NUMBER,TRANSACTION_NUMBER,
	           TRANSACTION_DATE,CURRENCY,AMOUNT,HCE_AMOUNT,AMOUNT_DATE,
	           CASHFLOW_AMOUNT,COMPANY_CODE,ACCOUNT_NO,ACTION_CODE,CPARTY_ACCOUNT_NO,
	           STATUS_CODE,CPARTY_CODE,SETTLE,DEAL_SUBTYPE,PRODUCT_TYPE,
	           PORTFOLIO_CODE,
	           dual_authorisation_by, dual_authorisation_on)  ---- ,LIMIT_CODE)
        values
	           ('IG','INTSET','SETTLE',G_Ig_Main_Rec.DEAL_NUMBER,G_Ig_Main_Rec.TRANSACTION_NUMBER,G_Ig_curr_date,
	            G_Ig_Main_Rec.CURRENCY,abs(G_Ig_Main_Rec.INTEREST_SETTLED),abs(G_Ig_Main_Rec.INTEREST_SETTLED_HCE),
	            nvl(G_Ig_Main_Rec.SETTLE_DATE,G_Ig_Main_Rec.TRANSFER_DATE),
	            decode(G_Ig_Main_Rec.COMPANY_ACCOUNT_NO,null,0,G_Ig_Main_Rec.INTEREST_SETTLED),
	            G_Ig_Main_Rec.COMPANY_CODE,G_Ig_Main_Rec.COMPANY_ACCOUNT_NO,
	            decode(sign(G_Ig_Main_Rec.INTEREST_SETTLED),-1,'PAY','REC'),
	            G_Ig_Main_Rec.PARTY_ACCOUNT_NO,'CURRENT',G_Ig_Main_Rec.PARTY_CODE,'N',
	            decode(sign(G_Ig_Main_Rec.INTEREST_SETTLED),-1,'FUND','INVEST'),
	            G_Ig_Main_Rec.PRODUCT_TYPE,G_Ig_Main_Rec.PORTFOLIO,
	            G_Ig_user, G_Ig_curr_date);
     end if;

  end;  /*  INS_DEAL_DATE_AMTS  */


 -----------------------------------------------------------------------------------------------------
  --  Local procedure to insert Deal Date Rows for Principal  Interest for Mirror Transaction
  --  Flows
  procedure INS_MIRROR_DEAL_DATE_AMTS is
  -----------------------------------------------------------------------------------------------------
     --*****************************************************************************************************************
     -- 3800146   set values for settlement  ***************************************************************************
     --*****************************************************************************************************************
     l_settle          VARCHAR2(1);
     l_settle_no       NUMBER;
     l_settle_auth     xtr_deal_date_amounts.SETTLEMENT_AUTHORISED_BY%TYPE;
     l_settle_date     DATE;
     l_trans_mts       VARCHAR2(1);
     l_audit_indic     VARCHAR2(1);
     l_dummy_num       NUMBER;
     l_dummy_err       VARCHAR2(80);

  begin
     if G_Ig_Mirror_Rec.PRINCIPAL_ADJUST <> 0 then

        --*****************************************************************************************************************
        -- 3800146  Only affects PRINFLW  *********************************************************************************
        --*****************************************************************************************************************
        SETTLE_DDA (G_Ig_settlement_flag,
                    G_Ig_Mirror_Rec.TRANSFER_DATE,
                    l_settle,
                    l_settle_no,
                    l_settle_auth,
                    l_settle_date,
                    l_trans_mts,
                    l_audit_indic);
        -----------------------------------------------------------------

        insert into xtr_DEAL_DATE_AMOUNTS_v
             (DEAL_TYPE,AMOUNT_TYPE,DATE_TYPE,DEAL_NUMBER,TRANSACTION_NUMBER,
             TRANSACTION_DATE,CURRENCY,AMOUNT,HCE_AMOUNT,AMOUNT_DATE,
             CASHFLOW_AMOUNT,COMPANY_CODE,ACCOUNT_NO,ACTION_CODE,CPARTY_ACCOUNT_NO,
             STATUS_CODE,CPARTY_CODE,
             SETTLE,SETTLEMENT_NUMBER,SETTLEMENT_AUTHORISED_BY,ACTUAL_SETTLEMENT_DATE,TRANS_MTS,AUDIT_INDICATOR, -- 3800146 ****************
             DEAL_SUBTYPE,PRODUCT_TYPE, PORTFOLIO_CODE,
             dual_authorisation_by, dual_authorisation_on)
             ---,LIMIT_CODE)
        values
            ('IG','PRINFLW','COMENCE',G_Ig_Mirror_Rec.DEAL_NUMBER,G_Ig_Mirror_Rec.TRANSACTION_NUMBER,
             G_Ig_curr_date,G_Ig_Mirror_Rec.CURRENCY,abs(G_Ig_Mirror_Rec.PRINCIPAL_ADJUST),
             abs(G_Ig_Mirror_Rec.PRINCIPAL_ADJUST_HCE),G_Ig_Mirror_Rec.TRANSFER_DATE,
             decode(G_Ig_Mirror_Rec.COMPANY_ACCOUNT_NO,NULL,0,
             decode(G_Ig_Mirror_Rec.PRINCIPAL_ACTION,'PAY',(-1) * G_Ig_Mirror_Rec.PRINCIPAL_ADJUST,
             G_Ig_Mirror_Rec.PRINCIPAL_ADJUST)),G_Ig_Mirror_Rec.COMPANY_CODE,
             G_Ig_Mirror_Rec.COMPANY_ACCOUNT_NO,G_Ig_Mirror_Rec.PRINCIPAL_ACTION,G_Ig_Mirror_Rec.PARTY_ACCOUNT_NO,
             'CURRENT',G_Ig_Mirror_Rec.PARTY_CODE,
             l_settle,l_settle_no,l_settle_auth,l_settle_date,l_trans_mts,l_audit_indic,  -- 3800146 ***************************
             decode(G_Ig_Mirror_Rec.PRINCIPAL_ACTION,'PAY', 'INVEST','FUND'),G_Ig_Mirror_Rec.PRODUCT_TYPE,G_Ig_Mirror_Rec.PORTFOLIO,
             G_Ig_user, G_Ig_curr_date);

         --*****************************************************************************************************************
         -- 3800146  For settlement.  **************************************************************************************
         --*****************************************************************************************************************
         if nvl(G_Ig_settlement_flag,'N') = 'Y' then
            XTR_SETTLEMENT_SUMMARY_P.INS_SETTLEMENT_SUMMARY(l_settle_no,
                                                            G_Ig_Mirror_Rec.COMPANY_CODE,
                                                            G_Ig_Mirror_Rec.CURRENCY,
                                                            G_Ig_Mirror_Rec.PRINCIPAL_ADJUST,
                                                            l_settle_date,              -- settlement date
                                                            G_Ig_Mirror_Rec.COMPANY_ACCOUNT_NO,
                                                            G_Ig_Mirror_Rec.PARTY_ACCOUNT_NO,
                                                            null,
                                                            'A',
                                                            G_Ig_user_id,
                                                            G_Ig_curr_date,             -- creation date
                                                            G_Ig_External_Source,
                                                            G_Ig_Mirror_Rec.PARTY_CODE, -- cparty code
                                                            l_dummy_num);
            ------------------------
            -- Workflow Notification
            ------------------------
            if nvl(G_Mirror_log_id,0) <> 0 then
               XTR_LIMITS_P.UPDATE_LIMIT_EXCESS_LOG(l_settle_no,
                                                    null,
                                                    G_Ig_user,
                                                    G_Mirror_log_id);

      	       XTR_WORKFLOW_PKG.START_WORKFLOW('XTR_LIMITS_NOTIFICATION','XTR',G_Ig_Mirror_Rec.DEAL_NUMBER,
                                               G_Ig_Mirror_Rec.TRANSACTION_NUMBER, 'IG',G_Mirror_log_id);
            end if;

         end if;

     end if;

  end;  /*  INS_MIRROR_DEAL_DATE_AMTS  */


  -----------------------------------------------------------------------------------------------------
  --  Local Procedure to re calculate amounts for subsequent records where previous records have been ammended.
  procedure CASCADE_RECALC(p_company_code  IN  VARCHAR2,
                           p_party_code    IN  VARCHAR2,
                           p_currency      IN  VARCHAR2,
                           p_transfer_date IN  DATE,
                           p_fund_limit    IN  VARCHAR2,
                           p_invest_limit  IN  VARCHAR2,
                           p_update        IN  VARCHAR2,
			   p_rounding_type IN  VARCHAR2,    --* Add for Interest Override
			   p_day_count_type IN VARCHAR2,    --* Add for Interest Override
			   p_types_update  IN  VARCHAR2) is --* Add for Interest Override
                        -- p_error         OUT VARCHAR2) is
  -----------------------------------------------------------------------------------------------------

     -- only if there are subsequent transactions;

     l_count            NUMBER;
     l_int_rate         NUMBER;
     l_int_settled      NUMBER;
     l_deal_num         NUMBER;
     l_trans_num        NUMBER;
     l_bal_out          NUMBER := 0;
     l_bal_out_hce      NUMBER := 0;
     l_prin_action      VARCHAR2(7);
     l_prin_adj         NUMBER;
     l_accum_int_bf     NUMBER;
     l_accum_int_bf_hce NUMBER;
     l_date             DATE;
     l_interest         NUMBER;
     l_interest_hce     NUMBER;
     l_days             NUMBER;
     l_fund_limit	VARCHAR2(7);
     l_invest_limit     VARCHAR2(7);
     l_limit_type       VARCHAR2(10);
     l_product          VARCHAR2(10);
     l_portfolio        VARCHAR2(10);
     l_rowid	        VARCHAR2(30);
     l_accrual_int	NUMBER;
     prv_date           DATE;
     prv_bal_out        NUMBER;
     prv_bal_out_hce    NUMBER;
     prv_accum_int      NUMBER;
     prv_int_rate       NUMBER;
     roundfac           NUMBER;
     hce_roundfac       NUMBER;
     yr_basis           NUMBER;
     acct               VARCHAR2(20);
     hce_rate           NUMBER;
     prv_accrual_int    NUMBER;
     trans_date 	DATE;
     v_ig_year_basis    VARCHAR2(20);
   --
--* Add for Interest Project
     l_oldest_date	     	DATE;
     l_first_trans_flag 	VARCHAR2(1);
     l_prv_day_count_type	VARCHAR2(1);
     l_rounding_type		VARCHAR2(1);
     l_day_count_type		VARCHAR2(1);
     l_interest_to_date		NUMBER;
--

     cursor GET_HCE is
     select a.hce_rate,
            a.rounding_factor,
            a.ig_year_basis,
            m.rounding_factor
     from   xtr_MASTER_CURRENCIES_V a,
            xtr_PARTIES_V p,
            xtr_MASTER_CURRENCIES_V m
     where  a.CURRENCY   = p_currency
     and    p.PARTY_CODE = p_company_code
     and    m.CURRENCY   = p.HOME_CURRENCY;
--
     cursor RECALC_DATE is
     select rowid,
            DEAL_NUMBER,
            TRANSFER_DATE,
            nvl(BALANCE_OUT,0),
            nvl(BALANCE_OUT_HCE,0),
            nvl(PRINCIPAL_ADJUST,0),
            PRINCIPAL_ACTION,
            INTEREST_RATE,
            nvl(INTEREST_SETTLED,0),
            nvl(NO_OF_DAYS,0),
            TRANSACTION_NUMBER,
            nvl(ACCUM_INTEREST_BF,0),
            nvl(INTEREST,0),
            LIMIT_CODE,
            LIMIT_CODE_INVEST,
            PRODUCT_TYPE,
            PORTFOLIO,
            nvl(ACCRUAL_INTEREST,0),
	    ROUNDING_TYPE, --* Add for Interest Override
	    DAY_COUNT_TYPE --* Add for Interest Override
     from   XTR_INTERGROUP_TRANSFERS_v
     where  PARTY_CODE     = p_party_code
     and    CURRENCY       = p_currency
     and    COMPANY_CODE   = p_company_code
     and    TRANSFER_DATE >= p_transfer_date
     order by TRANSFER_DATE asc, TRANSACTION_NUMBER asc;
--
     /*  This will be checked by VALID_LIMIT_CODE.   Don't need to check for final balance.
     cursor get_type (c_limit_code IN VARCHAR2) is
     select b.fx_invest_fund_type
     from   xtr_counterparty_limits_v a,
            xtr_limit_types_v b
     where  a.company_code = p_company_code
     and    a.cparty_code  = p_party_code
     and    a.limit_type   = b.limit_type
     and    a.limit_code   = c_limit_code;
     */

--* Add for Interest Override Project
  cursor PRV_DAY_COUNT_TYPE is
   SELECT DAY_COUNT_TYPE
     FROM XTR_INTERGROUP_TRANSFERS
    WHERE PARTY_CODE = p_party_code
      AND CURRENCY = p_currency
      AND COMPANY_CODE = p_company_code
      AND TRANSFER_DATE = (select max(transfer_date)
			     from xtr_intergroup_transfers
		            where party_code = p_party_code
	       		      and currency = p_currency
			      and company_code = p_company_code
		 	      and transfer_date < prv_date)
   order by transaction_number desc;


  begin

  -- p_error      := NULL;
--     G_Ig_bal_out := NULL; --RV 2229236

     if p_transfer_date is not null then

         open  GET_HCE;
         fetch GET_HCE INTO hce_rate, roundfac, v_ig_year_basis, hce_roundfac;
         close GET_HCE;

         --* Add for Interest Project
         /* Get the oldest transfer date */
	 select min(TRANSFER_DATE)
	   into l_oldest_date
	   from XTR_INTERGROUP_TRANSFERS
	  where PARTY_CODE = p_party_code
	    and CURRENCY = p_currency
     	    and COMPANY_CODE = p_company_code;
 	 --* Add End

         --
         l_count := 0;

         open RECALC_DATE;
         fetch RECALC_DATE INTO l_rowid,      l_deal_num,    l_date,l_bal_out, l_bal_out_hce,
                                l_prin_adj,   l_prin_action, l_int_rate,       l_int_settled,
                                l_days,       l_trans_num,   l_accum_int_bf,   l_interest,
                                l_fund_limit, l_invest_limit,l_product,        l_portfolio,   l_accrual_int,
				l_rounding_type,	l_day_count_type; --* Add for Interest Override
                              --l_limit_code, l_product,     l_portfolio,      l_accrual_int;
         while RECALC_DATE%FOUND LOOP
            if l_count <> 0 then

               if l_prin_action = 'REC' then
                  l_prin_adj  := (-1) * l_prin_adj;
               end if;

               l_bal_out     := nvl(prv_bal_out,0) + nvl(l_prin_adj,0);
               l_bal_out_hce := nvl(round(l_bal_out / hce_rate,hce_roundfac),0);
               l_accum_int_bf     := nvl(prv_accum_int,0);
               l_accum_int_bf_hce := nvl(round(l_accum_int_bf / hce_rate,hce_roundfac),0);

               if l_date > prv_date then

	       --* Add for Interest Project
	       /* Check the transations to decide First Transaction Flag */
	       l_first_trans_flag := 'N';
	       if nvl(p_day_count_type,l_day_count_type)= 'B' and prv_date = l_oldest_date then -- This transaction is oldest
	          l_first_trans_flag := 'Y';
	       else
                 if (nvl(p_day_count_type,l_day_count_type) = 'B'
                     or nvl(p_day_count_type,l_day_count_type) = 'F') and prv_date <> l_oldest_date then

		  	OPEN PRV_DAY_COUNT_TYPE;
			FETCH PRV_DAY_COUNT_TYPE INTO l_prv_day_count_type;
			CLOSE PRV_DAY_COUNT_TYPE;

                   if (l_prv_day_count_type = 'B' or l_prv_day_count_type = 'L') and
                      nvl(p_day_count_type,l_day_counT_type) = 'F' then
                    prv_date := prv_date + 1;
                   elsif l_prv_day_count_type = 'F' and nvl(p_day_count_type,l_day_count_type) = 'B' then
		    l_first_trans_flag := 'Y';
		   end if;
		  end if;
 	 	end if;
		--* Add End


                  XTR_CALC_P.CALC_DAYS_RUN(prv_date,
                                           l_date,
                                           nvl(v_ig_year_basis, 'ACTUAL/ACTUAL'),
                                           l_days,
                                           yr_basis,
					   null,
			 	  	   nvl(p_day_count_type,l_day_count_type),   -- Add for Interest Project
					   l_first_trans_flag); -- Add for Interest Project

               else
                  l_days    := 0;
                   yr_basis := 365;
               end if;
-- Original Code
--               l_interest     := round(prv_bal_out * prv_int_rate / 100 * l_days / yr_basis,roundfac);
--* Add for Interest Project
	       l_interest     := xtr_fps2_p.interest_round(prv_bal_out * prv_int_rate / 100 * l_days / yr_basis,roundfac,
							nvl(p_rounding_type,l_rounding_type));
               l_interest_hce := nvl(round(l_interest / hce_rate,hce_roundfac),0);

               l_accrual_int  := nvl(prv_accrual_int,0) + nvl(l_interest,0);

               if p_update = 'Y' then
                  update xtr_INTERGROUP_TRANSFERS_v
                  set    BALANCE_BF            = prv_bal_out,
                         BALANCE_BF_HCE        = prv_bal_out_hce,
                         BALANCE_OUT           = l_bal_out,
                         BALANCE_OUT_HCE       = l_bal_out_hce,
                         ACCUM_INTEREST_BF     = l_accum_int_bf,
                         ACCUM_INTEREST_BF_HCE = l_accum_int_bf_hce,
                         INTEREST              = l_interest,
                         INTEREST_HCE          = l_interest_hce,
                         NO_OF_DAYS            = l_days,
                         ACCRUAL_INTEREST      = l_accrual_int,
		      	 DAY_COUNT_TYPE = nvl(p_day_count_type,l_day_count_type),
		      	 ROUNDING_TYPE = nvl(p_rounding_type,l_rounding_type),
		      	 ORIGINAL_AMOUNT = l_accum_int_bf + l_interest

                  where  rowid = l_rowid;
               end if;

            END IF;
--* Add for Interest Project
--* When this flag is set, all transaction should be recalculated and replaced by new types.

	    if p_types_update = 'Y' and p_update ='Y' and l_count = 0 then
                  update xtr_INTERGROUP_TRANSFERS_v
                  set DAY_COUNT_TYPE = nvl(p_day_count_type,l_day_count_type),
		      ROUNDING_TYPE = nvl(p_rounding_type,l_rounding_type)
                  where rowid=l_rowid;
	    end if;
--* Add End


            prv_bal_out     := nvl(l_bal_out,0);
            prv_bal_out_hce := nvl(round(prv_bal_out / hce_rate,hce_roundfac),0);
            prv_accum_int   := nvl(l_accum_int_bf,0) + nvl(l_interest,0) - nvl(l_int_settled,0);
            prv_date        := l_date;
            prv_int_rate    := l_int_rate;
            prv_accrual_int := nvl(l_accrual_int,0);

            l_count  := l_count + 1;

            EXIT WHEN RECALC_DATE%NOTFOUND;
            fetch RECALC_DATE INTO l_rowid,      l_deal_num,    l_date,l_bal_out, l_bal_out_hce,
                                   l_prin_adj,   l_prin_action, l_int_rate,       l_int_settled,
                                   l_days,       l_trans_num,   l_accum_int_bf,   l_interest,
                                   l_fund_limit, l_invest_limit,l_product,        l_portfolio,   l_accrual_int,
				   l_rounding_type,	l_day_count_type;
                                 --l_limit_code, l_product,     l_portfolio,      l_accrual_int;
         END LOOP;

         close RECALC_DATE;

         --------------------------------
         -- To be used by limits check --
         --------------------------------
--         G_Ig_bal_out := l_bal_out;  -- RV 2229236
         --------------------------------

         /*  The check is handled in VALID_LIMIT_CODE
         if p_update = 'N' then

            if l_bal_out < 0 and p_fund_limit is not null then
               open  get_type(p_fund_limit);
               fetch get_type into l_limit_type;
               close get_type;
               if l_limit_type = 'I' then
                  p_error := 'FUND'; --  Limit code should be a FUND type.
               end if;
            elsif l_bal_out > 0 and p_invest_limit is not null then
               open  get_type(p_invest_limit);
               fetch get_type into l_limit_type;
               close get_type;
               if l_limit_type = 'I' then
                  p_error := 'INVEST'; --  Limit code should be a INVEST type.
               end if;
            end if;
         */

         if p_update = 'Y' then

            update xtr_deal_date_amounts_v
            set    AMOUNT           = abs(nvl(l_bal_out,0)),
                   HCE_AMOUNT       = abs(nvl(l_bal_out_hce,0)),
                   AMOUNT_DATE      = nvl(l_date,G_Ig_curr_date),
                 --LIMIT_CODE       = nvl(l_limit_code,'NILL'),
                   LIMIT_CODE       = decode(sign(nvl(l_bal_out,0)),-1,nvl(p_fund_limit,'NILL'),
                                                                       nvl(p_invest_limit,'NILL')),
                   LIMIT_PARTY      = p_party_code,
                   PORTFOLIO_CODE   = l_portfolio,
                   PRODUCT_TYPE     = l_product,
                   DEAL_SUBTYPE     = decode(sign(nvl(l_bal_out,0)),-1,'FUND','INVEST'),
                   ACTION_CODE      = decode(sign(nvl(l_bal_out,0)),-1,'PAY','REC'),
                   TRANSACTION_RATE = l_int_rate
            where  DEAL_TYPE    = 'IG'
            and    DEAL_NUMBER  = l_deal_num
            and    AMOUNT_TYPE  = 'BAL'
            and    CPARTY_CODE  = p_party_code
            and    CURRENCY     = p_currency
            and    COMPANY_CODE = p_company_code;

            if SQL%NOTFOUND and l_count <> 0 then
                insert into xtr_DEAL_DATE_AMOUNTS_v (DEAL_TYPE,                 AMOUNT_TYPE,
                                                     DATE_TYPE,                 DEAL_NUMBER,
                                                     TRANSACTION_NUMBER,        TRANSACTION_DATE,
                                                     AMOUNT_DATE,               COMPANY_CODE,
                                                     STATUS_CODE,               CPARTY_CODE,      LIMIT_PARTY,
                                                     LIMIT_CODE,                PORTFOLIO_CODE,
                                                     CURRENCY,                  TRANSACTION_RATE,
                                                     AMOUNT,                    HCE_AMOUNT,
                                                     ACTION_CODE,
                                                     DEAL_SUBTYPE,
                                                     PRODUCT_TYPE,
                                                     DUAL_AUTHORISATION_BY,     DUAL_AUTHORISATION_ON)
                                             values ('IG',                      'BAL',
                                                     'BALANCE',                 l_deal_num,
                                                     l_trans_num,               l_date,
                                                     l_date,                    p_company_code,
                                                     'CURRENT',                 p_party_code,     p_party_code,
                                                  -- nvl(l_limit_code,'NILL'),
                                                     decode(sign(nvl(l_bal_out,0)),-1,nvl(p_fund_limit,'NILL'),
                                                                                      nvl(p_invest_limit,'NILL')),
                                                     l_portfolio,
                                                     p_currency,                l_int_rate,
                                                     abs(l_bal_out),            abs(nvl(L_bal_out_hce,0)),
                                                     decode(sign(nvl(l_bal_out,0)),-1,'PAY','REC'),
                                                     decode(sign(nvl(l_bal_out,0)),-1,'FUND','INVEST'),
                                                     nvl(l_product,'NOT APPLIC'),
                                                     G_Ig_user,                 G_Ig_curr_date);
            end if;

         end if;  /* p_update = 'Y' */

     end if;  /* p_transfer_date is null */

  end;    /*  CASCADE_RECALC  */


-------------------------------------------------------------------------------------------------------
procedure MIRROR_INIT(p_mirror_deal      IN  VARCHAR2,
                      p_mirror_deal_no   IN  NUMBER,
                      p_mirror_trans_no  IN  NUMBER,
		      p_rounding_type	 IN  VARCHAR2,    --* Added for Interest Override
		      p_day_count_type	 IN  VARCHAR2) is --* Added for Interest Override
-------------------------------------------------------------------------------------------------------
Begin
                         G_Ig_Mirror_Deal         :=  p_mirror_deal    ;
                         G_Ig_Orig_Deal_No        :=  p_mirror_deal_no ;
                         G_Ig_Orig_Trans_No       :=  p_mirror_trans_no;
			--* Added for Interest Override
			 G_Ig_Rounding_Type	  :=  p_rounding_type  ;
			 G_Ig_Day_Count_Type	  :=  p_day_count_type ;
End;



  -----------------------------------------------------------------------------------------------------
  --* Main procedure for Import Deal Record that calls all the validation APIs
  --* stub for backwards compatibility
  procedure TRANSFER_IG_DEALS( ARec_Interface     IN  XTR_DEALS_INTERFACE%rowtype,
                               p_source           IN  VARCHAR2,
                               user_error         OUT NOCOPY BOOLEAN,
                               mandatory_error    OUT NOCOPY BOOLEAN,
                               validation_error   OUT NOCOPY BOOLEAN,
                               limit_error        OUT NOCOPY BOOLEAN) is
  -----------------------------------------------------------------------------------------------------

    --*****************************************************************************************************************
    -- 3800146 for backward compatibility *****************************************************************************
    --*****************************************************************************************************************
    v_dummy   NUMBER;
    v_dummy2  NUMBER;
    v_dummy3  NUMBER;
    v_dummy4  NUMBER;
  BEGIN
    TRANSFER_IG_DEALS(ARec_Interface,p_source,user_error,mandatory_error,validation_error,limit_error,v_dummy,
                      v_dummy2, v_dummy3, v_dummy4);
  END TRANSFER_IG_DEALS;
  -----------------------------------------------------------------------------------------------------


  --*****************************************************************************************************************
  -- 3800146 backwards compatibility   ******************************************************************************
  --*****************************************************************************************************************
  procedure TRANSFER_IG_DEALS( ARec_Interface     IN  XTR_DEALS_INTERFACE%rowtype,
                               p_source           IN  VARCHAR2,
                               user_error         OUT NOCOPY BOOLEAN,
                               mandatory_error    OUT NOCOPY BOOLEAN,
                               validation_error   OUT NOCOPY BOOLEAN,
                               limit_error        OUT NOCOPY BOOLEAN,
                               deal_num           OUT NOCOPY NUMBER) is
    v_dummy2  NUMBER;
    v_dummy3  NUMBER;
    v_dummy4  NUMBER;

  BEGIN
    TRANSFER_IG_DEALS(ARec_Interface,p_source,user_error,mandatory_error,validation_error,limit_error,deal_num,
                      v_dummy2, v_dummy3, v_dummy4);
  END TRANSFER_IG_DEALS;
  -----------------------------------------------------------------------------------------------------


  -----------------------------------------------------------------------------------------------------
  --* Main procedure for Import Deal Record that calls all the validation APIs
  --* and then finally calls the Insert Table Handler.
  procedure TRANSFER_IG_DEALS( ARec_Interface     IN  XTR_DEALS_INTERFACE%rowtype,
                               p_source           IN  VARCHAR2,
                               user_error         OUT NOCOPY BOOLEAN,
                               mandatory_error    OUT NOCOPY BOOLEAN,
                               validation_error   OUT NOCOPY BOOLEAN,
                               limit_error        OUT NOCOPY BOOLEAN,
                               deal_num           OUT NOCOPY NUMBER,
                               tran_num           OUT NOCOPY NUMBER,     -- ***********************************************************************
                               mirror_deal_num    OUT NOCOPY NUMBER,     -- 3800146   New return params for ZBA/CL  *******************************
                               mirror_tran_num    OUT NOCOPY NUMBER) is  -- ***********************************************************************
  -----------------------------------------------------------------------------------------------------

     v_limit_log_return 	NUMBER;
     v_mirror_limit_log_return  NUMBER;
     l_deal_subtype     	VARCHAR2(10);
     l_mirror_deal_subtype      VARCHAR2(10);
     l_dummy            	VARCHAR2(10);
     l_dummy_num        	NUMBER;
     l_limit_code       	VARCHAR2(10);
     l_mirror_limit_code        VARCHAR2(10);
     l_mirror_ig_action 	VARCHAR2(7);  --RV

     duplicate_error    BOOLEAN := FALSE;

     cursor FIND_USER (p_fnd_user in number) is
     select dealer_code
     from   xtr_dealer_codes_v
     where  user_id = p_fnd_user;

     --*****************************************************************************************************************
     -- 3800146   ******************************************************************************************************
     --*****************************************************************************************************************
     cursor USER_ACCESS (l_comp VARCHAR2) is
     select 'Y'
     from   xtr_parties_v
     where  party_type = 'C'
     and    party_code = l_comp;
/*
     temp_Interface_rate_a         XTR_DEALS_INTERFACE.RATE_A%TYPE;
     temp_Interface_Rounding_Type  XTR_DEALS_INTERFACE.ROUNDING_TYPE%TYPE;
     temp_Interface_Day_Count_Type XTR_DEALS_INTERFACE.DAY_COUNT_TYPE%TYPE;
     temp_Interface_pricing_model  XTR_DEALS_INTERFACE.PRICING_MODEL%TYPE;
     temp_Interface_mirror_pricing XTR_DEALS_INTERFACE.PRICING_MODEL%TYPE;
*/

  begin


     -------------------------
     --  Initialise Variables
     -------------------------
   /*------------------ Rvallams: Bug# 2229236 -------------------------*/
     G_Ig_Source        := p_source;

     --*****************************************************************************************************************
     --  3800146 IG/IAC Redesign  **************************************************************************************
     --*****************************************************************************************************************
     G_Ig_External_Source := ARec_Interface.external_source;
     G_Ig_Settlement_Flag := ARec_Interface.settlement_flag;
     G_Main_log_id        := null;
     G_Mirror_log_id      := null;
     deal_num             := null;
     tran_num             := null;
     mirror_deal_num      := null;
     mirror_tran_num      := null;
     --*****************************************************************************************************************
     -- bug 4368177 Made the following variables null
     if G_Ig_Source is null and  not is_company(ARec_Interface.cparty_code) then
        G_Ig_mirror_deal := null;
        G_Ig_orig_deal_no := null;
        G_Ig_orig_trans_no := null;
     end if;


     user_error         := FALSE;
     mandatory_error    := FALSE;
     validation_error   := FALSE;
     limit_error        := FALSE;

     G_Ig_user_id      := fnd_global.user_id;
     open  FIND_USER(G_Ig_User_Id);
     fetch FIND_USER into G_Ig_user;
     close FIND_USER;

     Select sysdate Into G_Ig_SysDate From Dual;
     G_Ig_curr_date := Trunc(G_Ig_SysDate);

     --******************************************************************************************************
     --* Perform the following to purge all the related data in the error table before processing the record
     --
     --******************************************************************************************************
     -- 3800146   Not necessary for ZBA/CL  *****************************************************************
     --******************************************************************************************************
     if G_Ig_Source is null and nvl(G_Ig_External_Source,'@@@') not in (C_ZBA,C_CL) then
        delete from xtr_interface_errors
        where  external_deal_id = ARec_Interface.external_deal_id
        and    deal_type        = ARec_Interface.deal_type;
     end if;

     ----------------------------------------------------------------------------------------------------
     --* The following code checks if user has permissions to transfer the deal (company authorization)
     ----------------------------------------------------------------------------------------------------
     if nvl(G_Ig_External_Source,'@@@') in (C_ZBA,C_CL) then
        -- *************************************************************************************************
        -- 3800146 to check for user access when coming from ZBA and CL   **********************************
        -- *************************************************************************************************
        open  USER_ACCESS(ARec_Interface.company_code);
        fetch USER_ACCESS into l_dummy;
        if USER_ACCESS%NOTFOUND then
           Log_Ig_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,null,'XTR_INV_COMP_CODE');
           user_error := TRUE;
        end if;
        close USER_ACCESS;

        if user_error <> TRUE then
           if IS_COMPANY(ARec_Interface.cparty_code) then
              open  USER_ACCESS(ARec_Interface.cparty_code);
              fetch USER_ACCESS into l_dummy;
              if USER_ACCESS%NOTFOUND then
                 Log_Ig_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,null,'XTR_INV_COMP_CODE');
                 user_error := TRUE;
              end if;
              close USER_ACCESS;
           end if;
        end if;

     else
        xtr_import_deal_data.CHECK_USER_AUTH(ARec_Interface.external_deal_id,
                                             ARec_Interface.deal_type,
                                             ARec_Interface.company_code,
                                             user_error);
     end if;

     if (user_error <> TRUE) then

           --------------------------------------------------------------------------------
           --* The following code does mandatory field validation specific to the IG deals
           --------------------------------------------------------------------------------
           CHECK_MANDATORY_FIELDS(ARec_Interface,mandatory_error);


           if (mandatory_error <> TRUE) then

              --------------------------------------------------------------------------------------
              --* The following code performs the business logic validation specific to the IG deals
              --------------------------------------------------------------------------------------
              VALIDATE_DEALS(ARec_Interface, validation_error);

              if (validation_error <> TRUE) then

                   --------------------------------------------------------------------------------------
                   --  If limit code is not null, then this would have been calculated in VALIDATE_DEALS.
                   --------------------------------------------------------------------------------------
                   if ARec_Interface.limit_code   is null and
                      ARec_Interface.limit_code_b is null then
                      CALCULATE_VALUES(ARec_Interface, l_dummy);
                   end if;

                   ------------------------------------------------------------------
                   --* Perform limit checks
                   ------------------------------------------------------------------
                   if G_Ig_Main_Rec.Principal_Action = 'PAY' then
                      l_deal_subtype := 'INVEST';
                      l_mirror_deal_subtype := 'FUND';
                   else
                      l_deal_subtype := 'FUND';
                      l_mirror_deal_subtype := 'INVEST';
                   end if;

                   --RV 2229236: Using function GET_LIMIT_AMOUNT to get the total amount for limit check

		   G_Ig_bal_out := GET_LIMIT_AMOUNT(ARec_Interface.company_code,
	 			                    ARec_Interface.cparty_code,
				                    ARec_Interface.currency_a,
				                    G_Ig_Main_Rec.PRINCIPAL_ADJUST,
			                            G_Ig_Main_Rec.Principal_Action);


                   -----------------------------------------------------------------------------
                   -- Should be based on the total balance, not the current transaction balance.
                   -----------------------------------------------------------------------------
                   if nvl(G_Ig_bal_out,0) < 0 then
                      l_limit_code   := G_Ig_Main_Rec.limit_code;
                      l_mirror_limit_code   := ARec_Interface.mirror_limit_code_invest;
                   else
                      l_limit_code   := G_Ig_Main_Rec.limit_code_invest;
                      l_mirror_limit_code   := ARec_Interface.mirror_limit_code_fund;
                   end if;

                   if G_Ig_Source is null then --rvallams 2229236
                      v_limit_log_return := xtr_limits_p.log_full_limits_check (null,
                                                  G_Ig_Main_Rec.TRANSACTION_NUMBER,
                                                  G_Ig_Main_Rec.COMPANY_CODE,
                                                  G_Ig_Main_Rec.DEAL_TYPE,
                                                  l_deal_subtype,
                                                  G_Ig_Main_Rec.PARTY_CODE,
                                                  G_Ig_Main_Rec.PRODUCT_TYPE,
                                                  l_limit_code, -- G_Ig_Main_Rec.LIMIT_CODE,
                                                  G_Ig_Main_Rec.PARTY_CODE,     -- LIMIT_PARTY
                                                  G_Ig_Main_Rec.TRANSFER_DATE,  -- AMOUNT_DATE
                                                  abs(G_Ig_bal_out), -- G_Ig_Main_Rec.PRINCIPAL_ADJUST,
                                                  G_Ig_user,
                                                  G_Ig_Main_Rec.CURRENCY);
                      If Nvl(ARec_Interface.override_limit,'N') = 'N' and v_limit_log_return <> 0 then
                         Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                                   'OverrideLimit','XTR_LIMIT_EXCEEDED');
                         limit_error := TRUE;
                      elsif Nvl(ARec_Interface.override_limit,'N') not in ('N', 'Y') then   -- 3800146
                         limit_error := TRUE;
                      else
                         limit_error := FALSE;

                      end if; /* If Limit needs to be checked */

                      /*****************************************************************************************************************/
                      /*  3800146 Settlement Limits   **********************************************************************************/
                      /*****************************************************************************************************************/
                      if nvl(G_Ig_Settlement_flag,'N') = 'Y' and limit_error <> TRUE then
                         -------------------------------------------------------------------------------------------------
                         -- NOTE:  Cashflow can be +/- depending on action.  Please refer to INS_DEAL_DATE_AMTS procedure.
                         -------------------------------------------------------------------------------------------------
                         if G_Ig_Main_Rec.PRINCIPAL_ACTION = 'PAY' then
                            l_dummy_num := -1;
                         else
                            l_dummy_num := 1;
                         end if;
                         G_Main_log_id := XTR_limits_P.LOG_FULL_LIMITS_CHECK (null,
                                                                              G_Ig_Main_Rec.TRANSACTION_NUMBER,
                                                                              '@'||G_Ig_Main_Rec.COMPANY_CODE, -- @ calling from settlements
                                                                              G_Ig_Main_Rec.DEAL_TYPE,
                                                                              l_deal_subtype,
                                                                              G_Ig_Main_Rec.PARTY_CODE,
                                                                              G_Ig_Main_Rec.PRODUCT_TYPE,
                                                                              l_limit_code,
                                                                              G_Ig_Main_Rec.PARTY_CODE,
                                                                              G_Ig_curr_date,
                                                                              l_dummy_num*G_Ig_Main_Rec.PRINCIPAL_ADJUST, --cashflow/2428516
                                                                              G_Ig_user,
                                                                              G_Ig_Main_Rec.CURRENCY);

                         If Nvl(ARec_Interface.override_limit,'N') = 'N' and G_Main_log_id <> 0 then
                            Log_IG_Errors(ARec_Interface.external_deal_id, ARec_Interface.deal_type,
                                                                      'OverrideLimit','XTR_LIMIT_EXCEEDED');
                            XTR_limits_P.maintain_excess_log(G_Main_log_id,'D',null);
                            limit_error := TRUE;
                         elsif Nvl(ARec_Interface.override_limit,'N') not in ('N', 'Y') then   -- 3800146
                            limit_error := TRUE;
                         else
                            limit_error := FALSE;
                         end if;

                      end if;
                      /*****************************************************************************************************************/

                   end if; --rvallams 2229236

                   /*-----------------------------------------------------------------------------------------------------*/
                   --rvallams 2229236

                   if G_Ig_Source is null and is_company(ARec_Interface.cparty_code) and
                                              limit_error <> TRUE then
                      v_mirror_limit_log_return := xtr_limits_p.log_full_limits_check (null,
                                                  null,--   G_Ig_Main_Rec.TRANSACTION_NUMBER,
                                                  G_Ig_Main_Rec.PARTY_CODE,
                                                  G_Ig_Main_Rec.DEAL_TYPE,
                                                  l_mirror_deal_subtype,
                                                  G_Ig_Main_Rec.COMPANY_CODE,
                                                  ARec_Interface.MIRROR_PRODUCT_TYPE,
                                                  l_mirror_limit_code, -- G_Ig_Main_Rec.LIMIT_CODE,
                                                  G_Ig_Main_Rec.COMPANY_CODE,     -- LIMIT_PARTY
                                                  G_Ig_Main_Rec.TRANSFER_DATE,  -- AMOUNT_DATE
                                                  abs(G_Ig_bal_out), -- G_Ig_Main_Rec.PRINCIPAL_ADJUST,
                                                  G_Ig_user,
                                                  G_Ig_Main_Rec.CURRENCY);

                      If Nvl(ARec_Interface.override_limit,'N') = 'N' and v_mirror_limit_log_return <> 0 then
                         Log_IG_Errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                                   'OverrideLimit','XTR_LIMIT_EXCEEDED');
                         limit_error := TRUE;
                      elsif Nvl(ARec_Interface.override_limit,'N') not in ('N', 'Y') then   -- 3800146
                         limit_error := TRUE;
                      else
                         limit_error := FALSE;
                      end if; /* If Limit needs to be checked */

                      /*****************************************************************************************************************/
                      /*  3800146 Settlement Limits   **********************************************************************************/
                      /*****************************************************************************************************************/
                      if nvl(G_Ig_Settlement_flag,'N') = 'Y' and limit_error <> TRUE then
                         ----------------------------------------------------------------------------------------------------------------
                         -- NOTE:  G_Ig_Main_Rec.PRINCIPAL_ACTION is the action of main deal, action will be reversed for mirror deal.
                         ----------------------------------------------------------------------------------------------------------------
                         if G_Ig_Main_Rec.PRINCIPAL_ACTION = 'PAY' then
                            l_dummy_num := 1;
                         else
                            l_dummy_num := -1;
                         end if;
                         G_Mirror_log_id := XTR_limits_P.LOG_FULL_LIMITS_CHECK(null,
                                                                               null,
                                                                               '@'||G_Ig_Main_Rec.PARTY_CODE, -- @ call from settlements
                                                                               G_Ig_Main_Rec.DEAL_TYPE,
                                                                               l_mirror_deal_subtype,
                                                                               G_Ig_Main_Rec.COMPANY_CODE,
                                                                               ARec_Interface.MIRROR_PRODUCT_TYPE,
                                                                               l_mirror_limit_code,
                                                                               G_Ig_Main_Rec.COMPANY_CODE,
                                                                               G_Ig_curr_date,
                                                                               l_dummy_num*G_Ig_Main_Rec.PRINCIPAL_ADJUST,--cashflow/2428516
                                                                               G_Ig_user,
                                                                               G_Ig_Main_Rec.CURRENCY);

                         If Nvl(ARec_Interface.override_limit,'N') = 'N' and G_Mirror_log_id <> 0 then
                            Log_IG_Errors(ARec_Interface.external_deal_id, ARec_Interface.deal_type,
                                                                      'OverrideLimit','XTR_LIMIT_EXCEEDED');
                            XTR_limits_P.maintain_excess_log(G_Mirror_log_id,'D',null);
                            limit_error := TRUE;
                         elsif Nvl(ARec_Interface.override_limit,'N') not in ('N', 'Y') then   -- 3800146
                            limit_error := TRUE;
                         else
                            limit_error := FALSE;
                         end if;

                      end if;
                      /*****************************************************************************************************************/

                   end if; --rvallams 2229236
                   /*-------------------------------------------------------------------------------------------------------*/

              end if; /* Validating various fields */

           end if; /* Checking Mandatory values */

     end if;   /* Checking User Auth */

    /*----------------------------------------------------------------------------------------------*/
    /* If the process passed all the previous validation, it would be considered a valid deal entry */
    /*----------------------------------------------------------------------------------------------*/
     if user_error  <> TRUE and mandatory_error  <> TRUE and
        limit_error <> TRUE and validation_error <> TRUE then

        if G_Ig_Source is null and is_company(ARec_Interface.cparty_code) then
           if G_ig_action = 'PAY' then
              l_mirror_ig_action := 'REC';
           else
              l_mirror_ig_action := 'PAY';
           end if;

           if is_mirror_deal(G_Ig_Main_Rec.company_code,
                             G_Ig_Main_Rec.party_code,
                             G_Ig_Main_Rec.currency) then
              G_Ig_Main_Rec.mirror_deal := 'Y';
           else
              G_Ig_Main_Rec.mirror_deal := null;
           end if;

           G_Ig_Mirror_Deal := G_Ig_Main_Rec.mirror_deal; --RV BUG 2293339

           -- ****************************************************************************************************************
           -- 3800146 Do not check for ZBA and CL.  Done in wrapper   ********************************************************
           -- ****************************************************************************************************************
           duplicate_error := FALSE;  -- 3800146 initialise

           if nvl(G_Ig_External_Source,'@@@') not in (C_ZBA,C_CL) then
              CHECK_MIRROR_DUPLICATE(G_Ig_Main_Rec.party_code,
                                     G_Ig_Main_Rec.company_code,
                                     G_Ig_Main_Rec.currency,
                                     G_Ig_Main_Rec.transfer_date,
                                     l_mirror_ig_action,
                                     G_Ig_Main_Rec.principal_adjust,
                                     G_Ig_Main_Rec.party_account_no,
                                     G_Ig_Main_Rec.company_account_no,
                                     duplicate_error);
           end if;

        end if;

        if duplicate_error <> TRUE then
           GET_DEAL_TRAN_NUMBERS(G_Ig_Main_Rec.company_code,
                                 G_Ig_Main_Rec.party_code,
                                 G_Ig_Main_Rec.currency,
                                 G_Ig_Main_Rec.deal_number,
                                 G_Ig_Main_Rec.transaction_number,
                                 'Y');  -- generate a new deal number



           XTR_LIMITS_P.UPDATE_LIMIT_EXCESS_LOG(G_Ig_Main_Rec.Deal_number,
                                                G_Ig_Main_Rec.Transaction_number,
                                                G_Ig_user,
                                                v_limit_log_return);

           --**********************************************************************************************************
           -- 3800146 return transaction number also to ZBA/CL  *******************************************************
           -- *********************************************************************************************************
           deal_num:=G_Ig_Main_Rec.Deal_number;
           tran_num:=G_Ig_Main_Rec.Transaction_number;
           --**********************************************************************************************************

          /*-------------------------------------------------------------------*/
          /* Call the insert procedure to insert into xtr_intergroup_transfers */
          /*-------------------------------------------------------------------*/

           CREATE_IG_DEAL(G_Ig_Main_Rec);

          /*-----------------------------------------*/
          /* Create journal structures: RV 2229236   */
          /*-----------------------------------------*/

          INS_IG_JRNL_STRUC(G_Ig_Main_Rec.company_code,
                            G_Ig_Main_Rec.party_code,
                            G_Ig_Main_Rec.currency,
                            G_Ig_Main_Rec.party_account_no);

          /*--------------------------------*/
          /* Create DDA rows for new deal.  */
          /*--------------------------------*/
          INS_DEAL_DATE_AMTS;

          /*-------------------------------------------------*/
          /* Update balance_out of subsequent transactions.  */
          /*-------------------------------------------------*/
          CASCADE_RECALC(G_Ig_Main_Rec.company_code,
                         G_Ig_Main_Rec.party_code,
                         G_Ig_Main_Rec.currency,
                         G_Ig_Main_Rec.transfer_date,
                         G_Ig_Main_Rec.limit_code,
                         G_Ig_Main_Rec.limit_code_invest,
                         'Y',
			 G_Ig_Main_Rec.Rounding_Type,
			 G_Ig_Main_Rec.Day_Count_Type);
                      -- l_dummy);

          -----------------------------------------------------------------------------------------
          -----------------------------------------------------------------------------------------
          if G_Ig_Source is null and is_company(ARec_Interface.cparty_code) then

              GET_DEAL_TRAN_NUMBERS(G_Ig_Main_Rec.party_code,
                                 G_Ig_Main_Rec.company_code,
                                 G_Ig_Main_Rec.currency,
                                 G_Ig_Mirror_Rec.deal_number,
                                 G_Ig_Mirror_Rec.transaction_number,
                                 'Y');

              XTR_LIMITS_P.UPDATE_LIMIT_EXCESS_LOG(G_Ig_Mirror_Rec.Deal_number,
                                                   G_Ig_Mirror_Rec.Transaction_number,
                                                   G_Ig_user,
                                                   v_mirror_limit_log_return);


             if G_Ig_Main_Rec.mirror_deal is not null and G_Ig_Main_Rec.mirror_deal = 'Y' then
                G_Ig_mirror_Rec.mirror_deal := null;
             else
                G_Ig_mirror_Rec.mirror_deal := 'Y';
             end if;

             G_Ig_Mirror_Rec.ACCUM_INTEREST_BF              := -G_Ig_Main_Rec.ACCUM_INTEREST_BF ;
  	     G_Ig_Mirror_Rec.ACCUM_INTEREST_BF_HCE          := -G_Ig_Main_Rec.ACCUM_INTEREST_BF_HCE ;
	     G_Ig_Mirror_Rec.BALANCE_BF                     := -G_Ig_Main_Rec.BALANCE_BF ;
	     G_Ig_Mirror_Rec.BALANCE_BF_HCE                 := -G_Ig_Main_Rec.BALANCE_BF_HCE ;
	     G_Ig_Mirror_Rec.BALANCE_OUT                    := -G_Ig_Main_Rec.BALANCE_OUT ;
	     G_Ig_Mirror_Rec.BALANCE_OUT_HCE                := -G_Ig_Main_Rec.BALANCE_OUT_HCE ;
	     G_Ig_Mirror_Rec.COMMENTS                       := null;
	     G_Ig_Mirror_Rec.COMPANY_ACCOUNT_NO             := G_Ig_Main_Rec.PARTY_ACCOUNT_NO;
	     G_Ig_Mirror_Rec.COMPANY_CODE                   := G_Ig_Main_Rec.PARTY_CODE;
 	     G_Ig_Mirror_Rec.CREATED_BY                     := G_Ig_Main_Rec.CREATED_BY;
             G_Ig_Mirror_Rec.CREATED_ON                     := G_Ig_Main_Rec.CREATED_ON;
	     G_Ig_Mirror_Rec.CURRENCY                       := G_Ig_Main_Rec.CURRENCY;
	     G_Ig_Mirror_Rec.DEAL_NUMBER                    := G_Ig_Mirror_Rec.deal_number ;
	     G_Ig_Mirror_Rec.DEAL_TYPE                      := G_Ig_Main_Rec.DEAL_TYPE;
	     G_Ig_Mirror_Rec.INTEREST                       := -G_Ig_Main_Rec.INTEREST ;
	     G_Ig_Mirror_Rec.INTEREST_HCE                   := -G_Ig_Main_Rec.INTEREST_HCE ;
	     G_Ig_Mirror_Rec.INTEREST_RATE                  := G_Ig_Main_Rec.INTEREST_RATE ;
	     G_Ig_Mirror_Rec.INTEREST_SETTLED               := -G_Ig_Main_Rec.INTEREST_SETTLED ;
	     G_Ig_Mirror_Rec.INTEREST_SETTLED_HCE           := -G_Ig_Main_Rec.INTEREST_SETTLED_HCE ;
	     G_Ig_Mirror_Rec.LIMIT_CODE                     := ARec_Interface.MIRROR_LIMIT_CODE_FUND;
	     G_Ig_Mirror_Rec.LIMIT_CODE_INVEST              := ARec_Interface.MIRROR_LIMIT_CODE_INVEST;
	     G_Ig_Mirror_Rec.NO_OF_DAYS                     := G_Ig_Main_Rec.NO_OF_DAYS ;
	     G_Ig_Mirror_Rec.PARTY_ACCOUNT_NO               := G_Ig_Main_Rec.COMPANY_ACCOUNT_NO;
	     G_Ig_Mirror_Rec.PARTY_CODE                     := G_Ig_Main_Rec.COMPANY_CODE;
	     G_Ig_Mirror_Rec.PORTFOLIO                      := ARec_Interface.MIRROR_PORTFOLIO_CODE;
	     G_Ig_Mirror_Rec.PRINCIPAL_ACTION               := l_mirror_ig_action;
	     G_Ig_Mirror_Rec.PRINCIPAL_ADJUST               := G_Ig_Main_Rec.PRINCIPAL_ADJUST ;
	     G_Ig_Mirror_Rec.PRINCIPAL_ADJUST_HCE           := G_Ig_Main_Rec.PRINCIPAL_ADJUST_HCE ;
	     G_Ig_Mirror_Rec.PRODUCT_TYPE                   := ARec_Interface.MIRROR_PRODUCT_TYPE;
	     G_Ig_Mirror_Rec.PRICING_MODEL                  := ARec_Interface.MIRROR_PRICING_MODEL;
--Bug 2994712
	     G_Ig_Mirror_Rec.DEAL_LINKING_CODE              := ARec_Interface.MIRROR_DEAL_LINKING_CODE;
--Bug 2994712
--Bug 2684411
	     G_Ig_Mirror_Rec.DEALER_CODE              	    := ARec_Interface.MIRROR_DEALER_CODE;
--Bug 2684411
	     G_Ig_Mirror_Rec.SETTLE_DATE                    := G_Ig_Main_Rec.SETTLE_DATE;
	     G_Ig_Mirror_Rec.TRANSACTION_NUMBER             := G_Ig_Mirror_Rec.transaction_number ;
	     G_Ig_Mirror_Rec.TRANSFER_DATE                  := G_Ig_Main_Rec.TRANSFER_DATE;
	     G_Ig_Mirror_Rec.UPDATED_BY                     := G_Ig_Main_Rec.UPDATED_BY;
	     G_Ig_Mirror_Rec.UPDATED_ON                     := G_Ig_Main_Rec.UPDATED_ON;
	     G_Ig_Mirror_Rec.ACCRUAL_INTEREST               := -G_Ig_Main_Rec.ACCRUAL_INTEREST ;
	     G_Ig_Mirror_Rec.FIRST_BATCH_ID                 := null ;
	     G_Ig_Mirror_Rec.LAST_BATCH_ID                  := null ;
	     G_Ig_Mirror_Rec.ATTRIBUTE_CATEGORY             := null;
	     G_Ig_Mirror_Rec.ATTRIBUTE1                     := null;
	     G_Ig_Mirror_Rec.ATTRIBUTE2                     := null;
	     G_Ig_Mirror_Rec.ATTRIBUTE3                     := null;
	     G_Ig_Mirror_Rec.ATTRIBUTE4                     := null;
	     G_Ig_Mirror_Rec.ATTRIBUTE5                     := null;
	     G_Ig_Mirror_Rec.ATTRIBUTE6                     := null;
	     G_Ig_Mirror_Rec.ATTRIBUTE7                     := null;
	     G_Ig_Mirror_Rec.ATTRIBUTE8                     := null;
	     G_Ig_Mirror_Rec.ATTRIBUTE9                     := null;
	     G_Ig_Mirror_Rec.ATTRIBUTE10                    := null;
	     G_Ig_Mirror_Rec.ATTRIBUTE11                    := null;
	     G_Ig_Mirror_Rec.ATTRIBUTE12                    := null;
	     G_Ig_Mirror_Rec.ATTRIBUTE13                    := null;
	     G_Ig_Mirror_Rec.ATTRIBUTE14                    := null;
	     G_Ig_Mirror_Rec.ATTRIBUTE15                    := null;
	     G_Ig_Mirror_Rec.EXTERNAL_DEAL_ID               := G_Ig_Main_Rec.EXTERNAL_DEAL_ID||'_M';
	     G_Ig_Mirror_Rec.REQUEST_ID                     := G_Ig_Main_Rec.REQUEST_ID ;
	     G_Ig_Mirror_Rec.PROGRAM_APPLICATION_ID         := G_Ig_Main_Rec.PROGRAM_APPLICATION_ID ;
	     G_Ig_Mirror_Rec.PROGRAM_ID                     := G_Ig_Main_Rec.PROGRAM_ID ;
	     G_Ig_Mirror_Rec.PROGRAM_UPDATE_DATE            := G_Ig_Main_Rec.PROGRAM_UPDATE_DATE;
             G_Ig_Mirror_Deal         			    := G_Ig_mirror_Rec.mirror_deal;
             G_Ig_Orig_Deal_No        			    := G_Ig_Main_Rec.deal_number;
             G_Ig_Orig_Trans_No       			    := G_Ig_Main_Rec.transaction_number;
	     G_Ig_Mirror_Rec.ROUNDING_TYPE		    := G_Ig_Main_Rec.ROUNDING_TYPE ;
	     G_Ig_Mirror_Rec.DAY_COUNT_TYPE		    := G_Ig_Main_Rec.DAY_COUNT_TYPE ;
	     G_Ig_Mirror_Rec.ORIGINAL_AMOUNT		    := -G_Ig_Main_Rec.ORIGINAL_AMOUNT ;
	     G_Ig_Mirror_Rec.External_Source           	    := G_Ig_Main_Rec.External_Source;   -- Bug 3800146  ************************************************

             --###########################################################################################################################
             --  3800146 Do not default for ZBA/CL
             --###########################################################################################################################
	     if G_Ig_Mirror_Rec.PRICING_MODEL is NULL and nvl(G_Ig_External_Source,'@@@') not in (C_ZBA,C_CL) then
	        DEFAULT_PRICING_MODEL(G_Ig_Mirror_Rec.COMPANY_CODE,
	                              G_Ig_Mirror_Rec.PARTY_CODE,
	                              G_Ig_Mirror_Rec.CURRENCY,
	                              G_Ig_Mirror_Rec.PRODUCT_TYPE,
	                              G_Ig_Mirror_Rec.PRICING_MODEL);
	     end if;

             update xtr_intergroup_transfers
             set    mirror_deal_number        = G_Ig_Mirror_Rec.deal_number,
                    mirror_transaction_number = G_Ig_Mirror_Rec.transaction_number
             where  deal_number               = G_Ig_Main_Rec.deal_number
             and    transaction_number        = G_Ig_Main_Rec.transaction_number;

             --**********************************************************************************************************
             -- 3800146 return to ZBA/CL
             -- *********************************************************************************************************
             mirror_deal_num := G_Ig_Mirror_Rec.deal_number;
             mirror_tran_num := G_Ig_Mirror_Rec.transaction_number;
             --**********************************************************************************************************

             CREATE_IG_DEAL(G_Ig_Mirror_Rec);

             /*-----------------------------------------*/
             /* Create journal structures: RV 2229236   */
             /*-----------------------------------------*/
             INS_IG_JRNL_STRUC(G_Ig_Mirror_Rec.company_code,
                               G_Ig_Mirror_Rec.party_code,
                               G_Ig_Mirror_Rec.currency,
                               G_Ig_Mirror_Rec.party_account_no);

             INS_MIRROR_DEAL_DATE_AMTS;
             CASCADE_RECALC(G_Ig_Mirror_Rec.company_code,
                       G_Ig_Mirror_Rec.party_code,
                       G_Ig_Mirror_Rec.currency,
                       G_Ig_Mirror_Rec.transfer_date,
                       G_Ig_Mirror_Rec.limit_code,
                       G_Ig_Mirror_Rec.limit_code_invest,
                       'Y');
          end if;
          -------------------------------------------------------------------------------------------------------------
          -------------------------------------------------------------------------------------------------------------


          /*---------------------------------------------------------------------------------*/
          /* Since the insert is done, we can now delete the rows from the interface table.  */
          /*---------------------------------------------------------------------------------*/
          --******************************************************************************************************
          -- 3800146   Not necessary for ZBA/CL  *****************************************************************
          --******************************************************************************************************
           if G_Ig_Source is null and nvl(G_Ig_External_Source,'@@@') not in (C_ZBA,C_CL) then
              delete from xtr_deals_interface
              where external_deal_id = ARec_Interface.external_deal_id
              and   deal_type        = ARec_Interface.deal_type;
           end if;

        else  /* if mirror duplicate error */
           --******************************************************************************************************
           -- 3800146   Not necessary for ZBA/CL  *****************************************************************
           --******************************************************************************************************
           if G_Ig_Source is null and nvl(G_Ig_External_Source,'@@@') not in (C_ZBA,C_CL) then
              update xtr_deals_interface
              set    load_status_code = 'DUPLICATE_DEAL_ID',
                     last_update_date = G_Ig_SysDate,
                     last_Updated_by  = G_Ig_user_id
              where  external_deal_id = ARec_Interface.external_deal_id
              and    deal_type        = ARec_Interface.deal_type;

              log_ig_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,null,'XTR_MIRROR_DUPLICATE_ERROR');
              validation_error := true;
           end if;

        end if;
     else    /* if any other errors */

       /*---------------------------------------------*/
       /*  Deal interface has error.  Do not import.  */
       /*---------------------------------------------*/
        --******************************************************************************************************
        -- 3800146   Not necessary for ZBA/CL  *****************************************************************
        --******************************************************************************************************
        if G_Ig_Source is null and nvl(G_Ig_External_Source,'@@@') not in (C_ZBA,C_CL) then
           update xtr_deals_interface
           set    load_status_code = 'ERROR',
                  last_update_date = G_Ig_SysDate,
                  last_Updated_by  = G_Ig_user_id
           where  external_deal_id = ARec_Interface.external_deal_id
           and    deal_type        = ARec_Interface.deal_type;

        end if;

     end if;

  end;  /*  TRANSFER_IG_DEALS  */


END;


/
