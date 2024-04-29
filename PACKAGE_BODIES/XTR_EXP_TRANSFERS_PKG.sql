--------------------------------------------------------
--  DDL for Package Body XTR_EXP_TRANSFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_EXP_TRANSFERS_PKG" AS
/* $Header: xtrimexb.pls 120.14 2005/12/29 12:49:52 eaggarwa ship $ */

/*------------------------------------------------------------------------
This procedure is used to log errors.
------------------------------------------------------------------------*/
procedure LOG_ERRORS(p_Ext_Deal_Id   In Varchar2,
                          p_Deal_Type     In Varchar2,
                          p_Error_Column  In Varchar2,
                          p_Error_Code    In Varchar2,
                          p_Field_Name    In Varchar2) is
     cursor c_text is
     select text
     from   xtr_sys_languages_vl
     where  item_name = p_Field_Name;

     p_text xtr_sys_languages_vl.text%TYPE;

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.LOG_ERRORS');
   END IF;

     if G_Source is null then
        xtr_import_deal_data.log_interface_errors(p_ext_deal_id,
                                                  p_deal_type,
                                                  p_error_column,
                                                  p_error_code);
     else
        if p_Error_Code in ('XTR_MANDATORY','XTR_INV_LIMIT_CODE',
        'XTR_IMP_DEAL_REVAL_EXIST',  'XTR_IMP_DEAL_ACCRUAL_EXIST',
        'XTR_LIMIT_EXCEEDED','XTR_INV_DESC_FLEX_API',
        'XTR_INV_DESC_FLEX_CONTEXT','XTR_INV_DESC_FLEX') then
           -------------------------------
           -- Get the dynamic prompt text.
           -------------------------------
           open  c_text;
           fetch c_text into p_text;
           close c_text;

           if p_Error_code = 'XTR_MANDATORY' then
              FND_MESSAGE.Set_Name('XTR','XTR_MANDATORY_FIELD');
              FND_MESSAGE.Set_Token('FIELD', p_text);

           elsif p_Error_code = 'XTR_INV_LIMIT_CODE' then
              FND_MESSAGE.Set_Name('XTR','XTR_INV_LIMIT_CODE_FIELD');
              FND_MESSAGE.Set_Token('LIMIT_CODE', p_text);

           elsif p_Error_code = 'XTR_IMP_DEAL_REVAL_EXIST' then
	      FND_MESSAGE.Set_Name ('XTR', 'XTR_DEAL_REVAL_DONE');
              FND_MESSAGE.Set_Token ('DATE',p_field_name);

           elsif p_Error_code = 'XTR_IMP_DEAL_ACCRUAL_EXIST' then
              FND_MESSAGE.Set_Name ('XTR', 'XTR_DEAL_ACCRLS_EXIST');
              FND_MESSAGE.Set_Token ('DATE',p_field_name);

           elsif p_Error_code in ('XTR_INV_DESC_FLEX_API',
	   'XTR_INV_DESC_FLEX_CONTEXT','XTR_INV_DESC_FLEX') then
              FND_MESSAGE.Set_Name ('XTR', 'XTR_INV_DESC_FLEX_API');

           elsif p_Error_code = 'XTR_LIMIT_EXCEEDED' then
              null;
	   -- do nothing, return error to calling form to handle limits checks.
           end if;
        else
           FND_MESSAGE.Set_Name('XTR', p_Error_Code);
        end if;

        APP_EXCEPTION.raise_exception;
     end if;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.LOG_ERRORS');
   END IF;

END LOG_ERRORS;



/*------------------------------------------------------------------------
This procedure get the actual Action Code.
------------------------------------------------------------------------*/
FUNCTION get_actual_action_code(p_user_action_code VARCHAR2,
				p_deal_type VARCHAR2)
	RETURN VARCHAR2 IS

  cursor Get_Type is
    select ACTION_CODE
      from XTR_AMOUNT_ACTIONS_V
       where DEAL_TYPE = p_deal_type
         and AMOUNT_TYPE = 'AMOUNT'
         and USER_ACTION_CODE = p_user_action_code;

   v_type VARCHAR2(7);

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('get_actual_action_code: ' || 'XTR_EXP_TRANSFERS.GET_ACT_ACTION_CODE');
   END IF;

   open get_type;
   fetch get_type into v_type;
   close get_type;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('get_actual_action_code: ' || 'XTR_EXP_TRANSFERS.GET_ACT_ACTION_CODE');
   END IF;
   return v_type;

END get_actual_action_code;



/*------------------------------------------------------------------------
This procedure get the Actual Deal Type code.
------------------------------------------------------------------------*/
FUNCTION get_actual_deal_type(p_user_deal_type VARCHAR2)
	RETURN VARCHAR2 IS

   cursor deal_type is
      select deal_type from xtr_deal_types
	where user_deal_type = p_user_deal_type;

   v_deal_type VARCHAR2(7);

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('get_actual_deal_type: ' || 'XTR_EXP_TRANSFERS.GET_ACT_DEAL_TYPE');
   END IF;

   open deal_type;
   fetch deal_type into v_deal_type;
   close deal_type;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('get_actual_deal_type: ' || 'XTR_EXP_TRANSFERS.GET_ACT_DEAL_TYPE');
   END IF;
   return v_deal_type;

END get_actual_deal_type;




/*------------------------------------------------------------------------
This procedure get the FX Spot Rate.
------------------------------------------------------------------------*/
FUNCTION get_actual_deal_subtype(p_deal_type VARCHAR2,
			p_user_deal_subtype VARCHAR2)
	RETURN VARCHAR2 IS

   cursor deal_subtype is
      select deal_subtype from xtr_deal_subtypes
	where user_deal_subtype = p_user_deal_subtype
	and deal_type = 'EXP'; --p_deal_type;  -- fails with different user deal types

   v_deal_subtype VARCHAR2(7);

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('get_actual_deal_subtype: ' || 'XTR_EXP_TRANSFERS.GET_ACT_DEAL_SUBT');
   END IF;

   open deal_subtype;
   fetch deal_subtype into v_deal_subtype;
   close deal_subtype;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('get_actual_deal_subtype: ' || 'XTR_EXP_TRANSFERS.GET_ACT_DEAL_SUBT');
   END IF;
   return v_deal_subtype;

END get_actual_deal_subtype;




/*------------------------------------------------------------------------
This procedure is checks whether the company_code is valid.
------------------------------------------------------------------------*/
function VALID_COMPANY_CODE(p_comp IN VARCHAR2) return boolean IS
   CURSOR company_code IS
	SELECT COUNT(*) FROM xtr_parties_v
	WHERE party_type='C' AND party_code=p_comp;

   v_count NUMBER;

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.VALID_COMPANY_CODE');
   END IF;

   OPEN company_code;
   FETCH company_code INTO v_count;
   CLOSE company_code;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.VALID_COMPANY_CODE');
   END IF;

   IF v_count=0 THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;
END VALID_COMPANY_CODE;




/*------------------------------------------------------------------------
This procedure is used to log errors.
------------------------------------------------------------------------*/
function VALID_STATUS_CODE(p_status_code IN VARCHAR2) return boolean IS

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.VALID_STATUS_CODE');
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.VALID_STATUS_CODE');
   END IF;

   IF p_status_code='CURRENT' THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;
END VALID_STATUS_CODE;



/*------------------------------------------------------------------------
This procedure validates the Exposure Type.
------------------------------------------------------------------------*/
function VALID_EXPOSURE_TYPE(p_comp   IN VARCHAR2,
			p_exposure_type IN VARCHAR2) return boolean IS
   CURSOR exposure_type IS
	SELECT COUNT(*) FROM XTR_EXPOSURE_TYPES_V
	WHERE company_code=p_comp
	AND exposure_type=p_exposure_type
	AND tax_brokerage_type IS NULL;

   v_count NUMBER;

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.VALID_EXPOSURE_TYPE');
   END IF;

   OPEN exposure_type;
   FETCH exposure_type INTO v_count;
   CLOSE exposure_type;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.VALID_EXPOSURE_TYPE');
   END IF;

   IF v_count=0 THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;

END VALID_EXPOSURE_TYPE;



/*------------------------------------------------------------------------
This procedure is used to log errors.
------------------------------------------------------------------------*/
function VALID_DEAL_SUBTYPE(p_deal_type   IN VARCHAR2,
			p_deal_subtype IN VARCHAR2) return boolean IS

--   CURSOR deal_subtype IS
--	select COUNT(*)
--	from   xtr_auth_deal_subtypes_v
--	where  deal_type    = p_deal_type
--	and    deal_subtype = p_deal_subtype;
   --The deal_subtype in the view is referring to the user_deal_subtype
   --in the table

   CURSOR deal_subtype IS
	select COUNT(*)
	from xtr_deal_subtypes_v
	where deal_type='EXP' and authorised='Y'
	and user_deal_subtype = p_deal_subtype;

   v_count NUMBER;

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.VALID_DEAL_SUBTYPE');
   xtr_risk_debug_pkg.dlog('VALID_DEAL_SUBTYPE: ' || 'p_deal_type',p_deal_type);
   xtr_risk_debug_pkg.dlog('VALID_DEAL_SUBTYPE: ' || 'p_deal_subtype',p_deal_subtype);
END IF;
   OPEN deal_subtype;
   FETCH deal_subtype INTO v_count;
   CLOSE deal_subtype;
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('VALID_DEAL_SUBTYPE: ' || 'v_count',v_count);
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.VALID_DEAL_SUBTYPE');
   END IF;

   IF v_count=0 THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;
END VALID_DEAL_SUBTYPE;



/*------------------------------------------------------------------------
This procedure checks whether the portfolio code is valid.
------------------------------------------------------------------------*/
function VALID_PORTFOLIO(p_comp      IN VARCHAR2,
                           p_portfolio IN VARCHAR2) return boolean IS
   CURSOR portfolio IS
	select COUNT(*)
	from   xtr_portfolios_v
	where  company_code = p_comp
	and    portfolio = p_portfolio
        and    nvl(cmf_yn,'N') = 'N'
        and    nvl(external_portfolio,'N') = 'N';

   v_count NUMBER;

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.VALID_PORTFOLIO');
   END IF;

   OPEN portfolio;
   FETCH portfolio INTO v_count;
   CLOSE portfolio;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.VALID_PORTFOLIO');
   END IF;

   IF v_count=0 THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;
END VALID_PORTFOLIO;




/*------------------------------------------------------------------------
This procedure is used to log errors.
------------------------------------------------------------------------*/
function VALID_ACTION(p_action IN VARCHAR2,
			p_deal_type IN VARCHAR2) return boolean IS
   CURSOR action IS
	select COUNT(*)
	from   xtr_amount_actions_v
	where  amount_type = 'AMOUNT'
	and    deal_type = 'EXP'
	and user_action_code = p_action;

   v_count NUMBER;

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.VALID_ACTION');
   END IF;

   OPEN action;
   FETCH action INTO v_count;
   CLOSE action;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.VALID_ACTION');
   END IF;

   IF v_count=0 THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;
END VALID_ACTION;




/*------------------------------------------------------------------------
This procedure checks the validity of the currency.
------------------------------------------------------------------------*/
function VALID_CURRENCY(p_curr IN VARCHAR2) return boolean IS
   CURSOR currency IS
	select COUNT(*)
	from   xtr_master_currencies_v
	where  currency = p_curr
	and    NVL(authorised,'N')='Y';

   v_count NUMBER;

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.VALID_CURRENCY');
   END IF;

   OPEN currency;
   FETCH currency INTO v_count;
   CLOSE currency;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.VALID_CURRENCY');
   END IF;

   IF v_count=0 THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;
END VALID_CURRENCY;




/*------------------------------------------------------------------------
This procedure is checks the validity of the company account no.
------------------------------------------------------------------------*/
function VALID_COMP_ACCT(p_comp      IN VARCHAR2,
                           p_comp_acct IN VARCHAR2,
                           p_curr      IN VARCHAR2) return boolean IS
   CURSOR comp_acct IS
	select COUNT(*)
	from   xtr_bank_accounts_v
	where  party_code = p_comp
	and    currency = p_curr
	and account_number = p_comp_acct
	and NVL(authorised,'N') = 'Y';

   v_count NUMBER;

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('VALID_COMP_ACCT: ' || 'XTR_EXP_TRANSFERS.VALID_COMP_ACT');
   END IF;

   OPEN comp_acct;
   FETCH comp_acct INTO v_count;
   CLOSE comp_acct;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('VALID_COMP_ACCT: ' || 'XTR_EXP_TRANSFERS.VALID_COMP_ACT');
   END IF;

   IF v_count=0 THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;
END VALID_COMP_ACCT;

/*------------------------------------------------------------------------
This procedure is used to log errors.
------------------------------------------------------------------------*/
function VALID_SETTLE_ACTION(p_settle_action      IN VARCHAR2,
                           p_deal_subtype IN VARCHAR2,
                           p_act_amount IN NUMBER,
			   p_act_date IN DATE,
			   p_cparty_code IN VARCHAR2) return boolean IS

   p_error BOOLEAN := TRUE;
   v_deal_subtype VARCHAR2(7);

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.VALID_SETTLE_ACTION');
   END IF;

   v_deal_subtype := get_actual_deal_subtype('EXP',p_deal_subtype);
--xtr_risk_debug_pkg.dlog('p_settle_action',p_settle_action);
--xtr_risk_debug_pkg.dlog('p_deal_subtype',p_deal_subtype||'-');
--xtr_risk_debug_pkg.dlog('p_act_amount',p_act_amount);
--xtr_risk_debug_pkg.dlog('p_act_date',p_act_date);
--xtr_risk_debug_pkg.dlog('p_cparty_code',p_cparty_code);
   if p_settle_action = 'Y' THEN
      if p_deal_subtype <> 'FIRM' THEN
	 p_error := FALSE;
      end if;
--xtr_risk_debug_pkg.dlog('After checking DST p_error',p_error);
      if p_act_amount is null or p_act_date is null
      or p_cparty_code is null then
	 p_error := FALSE;
      end if;
   end if;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.VALID_SETTLE_ACTION');
   END IF;
   return p_error;
END VALID_SETTLE_ACTION;

/*------------------------------------------------------------------------
This procedure is used to log errors.
------------------------------------------------------------------------*/
function VALID_CPARTY_CODE(p_comp   IN VARCHAR2,
                             p_cparty IN VARCHAR2) return boolean IS
   CURSOR cparty_code IS
	select COUNT(*)
	from   xtr_party_info_v
	where  party_code <> p_comp
	and    party_code = p_cparty
	and NVL(authorised,'N') = 'Y';

--	select party_code,short_name
--from xtr_party_info_v
--where  nvl(authorised,'N') = 'Y'
--and party_code <> :ET.company_code
--order by party_code

   v_count NUMBER;

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.VALID_CPARTY_CODE');
   xtr_risk_debug_pkg.dlog('VALID_CPARTY_CODE: ' || 'p_cparty',p_cparty);
   xtr_risk_debug_pkg.dlog('VALID_CPARTY_CODE: ' || 'p_comp',p_comp);
END IF;
   OPEN cparty_code;
   FETCH cparty_code INTO v_count;
   CLOSE cparty_code;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.VALID_CPARTY_CODE');
   END IF;

   IF v_count=0 THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;
END VALID_CPARTY_CODE;



/*------------------------------------------------------------------------
This procedure is used to log errors.
------------------------------------------------------------------------*/
function VALID_CPARTY_REF(  p_cparty_account_no IN VARCHAR2,
                            p_cparty_ref IN VARCHAR2,
                            p_cparty IN VARCHAR2,
			    p_curr IN VARCHAR2) return boolean IS
   CURSOR cparty_ref IS
	select COUNT(*)
	from   xtr_bank_accounts_v
	where  party_code = p_cparty
	and    account_number = p_cparty_account_no
	and    currency = p_curr
	and NVL(authorised,'N') = 'Y';

   v_count NUMBER;

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.VALID_CPARTY_REF');
   END IF;

   OPEN cparty_ref;
   FETCH cparty_ref INTO v_count;
   CLOSE cparty_ref;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.VALID_CPARTY_REF');
   END IF;

   IF v_count=0 THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;
END VALID_CPARTY_REF;

/*------------------------------------------------------------------------
This procedure is used to log errors.
------------------------------------------------------------------------*/
function VALID_DEALER_CODE(p_dealer_code IN VARCHAR2) return BOOLEAN is

   CURSOR dealer_code IS
   select COUNT(*)
   from xtr_dealer_codes_v
   where dealer_code = p_dealer_code;

   v_count NUMBER;
BEGIN
   OPEN dealer_code;
   FETCH dealer_code INTO v_count;
   CLOSE dealer_code;

   IF v_count = 0 THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;
END VALID_DEALER_CODE;


/*------------------------------------------------------------------------
This procedure is used to log errors.
------------------------------------------------------------------------*/
function VALID_DEAL_LINK_CODE(p_deal_link_code IN VARCHAR2)
	return boolean IS

   CURSOR deal_link_code IS
	select COUNT(*)
	from   xtr_deal_linking_v
	where  deal_linking_code = p_deal_link_code;

   v_count NUMBER;

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.VALID_DEAL_LINK_CODE');
   END IF;

   OPEN deal_link_code;
   FETCH deal_link_code INTO v_count;
   CLOSE deal_link_code;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.VALID_DEAL_LINK_CODE');
   END IF;

   IF v_count=0 THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;
END VALID_DEAL_LINK_CODE;




/*------------------------------------------------------------------------
Local Procedure to find the home currency for this company and use
the latest bid rate for chosen currency from Spot rates to calculate
HCE amount
------------------------------------------------------------------------*/
FUNCTION CALC_HCE_AMOUNT(p_hce_rate IN NUMBER,
		p_actual_amount IN NUMBER,
		p_estimate_amount IN NUMBER) RETURN NUMBER is

--   Example from Exposure Transactions FORMS
--   cursor HCE is
--      select nvl(round(nvl(:ET.AMOUNT,:ET.ESTIMATE_AMOUNT)/p_hce_rate,
--	rounding_factor),0)
--      from XTR_MASTER_CURRENCIES_V
--      where CURRENCY = :ET.CURRENCY;
--
   v_hce_amount NUMBER;

begin
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.CALC_HCE_AMOUNT');
   END IF;

   if p_actual_amount is not null then
      v_hce_amount := p_actual_amount/p_hce_rate;
   elsif p_estimate_amount is not null then
      v_hce_amount := p_estimate_amount/p_hce_rate;
   else
      v_hce_amount := 0;
   end if;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.CALC_HCE_AMOUNT');
   END IF;
   RETURN v_hce_amount;

end CALC_HCE_AMOUNT;


/*------------------------------------------------------------------------
This procedure get the FX Spot Rate.
------------------------------------------------------------------------*/
FUNCTION get_fx_rate(p_company_code VARCHAR2,
			p_curr VARCHAR2)
	RETURN NUMBER IS

   cursor get_home_currency is
      select home_currency
	from XTR_parties_V
	where party_code = p_company_code;

   cursor get_rate_hce is
      select round(hce_rate,5)
	from XTR_master_currencies_V
	where currency = p_curr;

  v_home_curr VARCHAR2(20);
  v_fx_rate NUMBER;

BEGIN
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('QRM_PA_AGGREGATION_P.GET_FX_RATE');
  END IF;

  open get_home_currency;
  fetch get_home_currency into v_home_curr;
  close get_home_currency;

  open get_rate_hce;
  fetch get_rate_hce into v_fx_rate;
  close get_rate_hce;
  --
  IF v_home_curr = p_curr THEN
    v_fx_rate := 1;
  END IF;

  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpop('QRM_PA_AGGREGATION_P.GET_FX_RATE');
  END IF;

  RETURN v_fx_rate;

END get_fx_rate;




/*------------------------------------------------------------------------
This procedure maps the XTR_DEALS_INTERFACE to XTR_EXPOSURE_TRANSACTIONS
table.
------------------------------------------------------------------------*/
procedure COPY_FROM_INTERFACE_TO_EXP
	(ARec_Interface IN XTR_DEALS_INTERFACE%rowtype,
	 p_error OUT NOCOPY BOOLEAN) IS

   v_fx_rate NUMBER;

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('COPY_FROM_INTERFACE_TO_EXP: ' || 'XTR_EXP_TRANSFERS.COPY_FROM_INT_TO_EXP');
   END IF;

   p_error := FALSE;
   v_fx_rate := get_fx_rate(ARec_Interface.company_code,
			ARec_Interface.currency_a);
   if v_fx_rate is null then
      Log_Errors(ARec_Interface.external_deal_id,
	ARec_Interface.deal_type,
        'CurrencyA','XTR_886');
      p_error := TRUE;
   end if;

   if NOT p_error then
      g_main_rec.ACCOUNT_NO := ARec_Interface.account_no_a;
	/* Bug 4092067. The deal_type is still the user entered value.
	   In case the user_deal_type has been changed from the seeded value
	   the procedure get_actual_action_code will return a null value.
      	   DEAL_TYPE has to be called earlier so that the actual deal_type
	   will be passed to the get_actual_action_code procedure. */
      g_main_rec.DEAL_TYPE := get_actual_deal_type(ARec_Interface.deal_type);
      g_main_rec.ACTION_CODE := get_actual_action_code(
				ARec_Interface.action_code,
				g_main_rec.deal_type);
      g_main_rec.AMOUNT  := ARec_Interface.amount_b;
      --AVG_RATE has to be called earlier than AMOUNT_HCE,
      --because AMOUNT_HCE requires AVG_RATE.
      g_main_rec.AVG_RATE := v_fx_rate;
      g_main_rec.AMOUNT_HCE := calc_hce_amount(v_fx_rate,
				ARec_Interface.amount_b,
				ARec_Interface.amount_a);
      g_main_rec.AMOUNT_TYPE := 'AMOUNT'; --refer to hidden item in ET block
      g_main_rec.ARCHIVE_BY := null;
      g_main_rec.ARCHIVE_DATE := null;
      g_main_rec.AUDIT_INDICATOR := NULL;
      g_main_rec.BALANCE := NULL;
      g_main_rec.BENEFICIARY_CODE := NULL;
      g_main_rec.COMMENTS := ARec_Interface.comments;
      g_main_rec.COMPANY_CODE := ARec_Interface.company_code;
      g_main_rec.CONTRA_NZD_AMOUNT := NULL;
      g_main_rec.COVERED_BY_FX_CONTRACT := NULL;
      g_main_rec.CPARTY_CODE := ARec_Interface.cparty_code;
      g_main_rec.CPARTY_REF := null; -- bug 3034164
      g_main_rec.CPARTY_ACCOUNT_NO := Arec_Interface.cparty_account_no; -- CE BANK MIGRATION
      g_main_rec.CREATED_BY := g_user;
      g_main_rec.CREATED_ON := g_curr_date;
      g_main_rec.CURRENCY := ARec_Interface.currency_a;
      g_main_rec.DEAL_STATUS := NULL; --refer to STATUS_CODE
      g_main_rec.DEAL_SUBTYPE := get_actual_deal_subtype(
					ARec_Interface.deal_type,
					ARec_Interface.deal_subtype);
      g_main_rec.ESTIMATE_AMOUNT := ARec_Interface.amount_a;
      g_main_rec.ESTIMATE_DATE := ARec_Interface.date_a;
      g_main_rec.EXPOSURE_TYPE := ARec_Interface.exposure_type;
      g_main_rec.FIS_FOB := NULL;
      g_main_rec.INTERMEDIARY_BANK_DETAILS := NULL;
      g_main_rec.NZD_AMOUNT := NULL;
      g_main_rec.PAYMENT_AMOUNT  := NULL;
      g_main_rec.PAYMENT_STATUS  := NULL;
      g_main_rec.PORTFOLIO_CODE  := ARec_Interface.portfolio_code;
      g_main_rec.PROFIT_LOSS := NULL;
      g_main_rec.PURCHASING_MODULE := 'N'; --refer to PRE-INSERT trigger
      g_main_rec.SELECT_ACTION := NULL;
      g_main_rec.SELECT_REFERENCE := NULL;
      g_main_rec.SETTLE_ACTION_REQD := ARec_Interface.settle_action_reqd;
      --there is no formal status code in EXP deal, deal can be deleted, but
      --to be consistent put 'CURRENT'
      g_main_rec.STATUS_CODE := nvl(ARec_Interface.status_code,'CURRENT');
      g_main_rec.SUBSIDIARY_REF  := NULL;
      g_main_rec.TAX_BROKERAGE_TYPE := NULL;
      g_main_rec.THIRDPARTY_CODE := ARec_Interface.cparty_code;
      g_main_rec.TRANSACTION_NUMBER := get_transaction_number;
      g_main_rec.UPDATED_BY := null;
      g_main_rec.UPDATED_ON := null;
      g_main_rec.VALUE_DATE := ARec_Interface.date_b;
      g_main_rec.WHOLESALE_REFERENCE := NULL;
      g_main_rec.ATTRIBUTE_CATEGORY := ARec_Interface.attribute_category;
      g_main_rec.ATTRIBUTE1 := ARec_Interface.attribute1;
      g_main_rec.ATTRIBUTE2 := ARec_Interface.attribute2;
      g_main_rec.ATTRIBUTE3 := ARec_Interface.attribute3;
      g_main_rec.ATTRIBUTE4 := ARec_Interface.attribute4;
      g_main_rec.ATTRIBUTE5 := ARec_Interface.attribute5;
      g_main_rec.ATTRIBUTE6 := ARec_Interface.attribute6;
      g_main_rec.ATTRIBUTE7 := ARec_Interface.attribute7;
      g_main_rec.ATTRIBUTE8 := ARec_Interface.attribute8;
      g_main_rec.ATTRIBUTE9 := ARec_Interface.attribute9;
      g_main_rec.ATTRIBUTE10 := ARec_Interface.attribute10;
      g_main_rec.ATTRIBUTE11 := ARec_Interface.attribute11;
      g_main_rec.ATTRIBUTE12 := ARec_Interface.attribute12;
      g_main_rec.ATTRIBUTE13 := ARec_Interface.attribute13;
      g_main_rec.ATTRIBUTE14 := ARec_Interface.attribute14;
      g_main_rec.ATTRIBUTE15 := ARec_Interface.attribute15;
      g_main_rec.EXTERNAL_DEAL_ID := ARec_Interface.external_deal_id;
      g_main_rec.REQUEST_ID := fnd_global.conc_request_id;
      g_main_rec.PROGRAM_APPLICATION_ID  := fnd_global.prog_appl_id;
      g_main_rec.PROGRAM_ID := fnd_global.conc_program_id;
      g_main_rec.PROGRAM_UPDATE_DATE := g_curr_date;
      g_main_rec.INTERNAL_COMMENTS := NULL;
      g_main_rec.EXTERNAL_COMMENTS := ARec_Interface.external_comments;
      g_main_rec.DEAL_LINK_CODE := ARec_Interface.deal_linking_code;

      --Bug 2254853
      if nvl(g_main_rec.SETTLE_ACTION_REQD, 'N') = 'Y' then
         g_main_rec.DUAL_AUTHORISATION_BY := ARec_Interface.dual_authorization_by;
         g_main_rec.DUAL_AUTHORISATION_ON := ARec_Interface.dual_authorization_on;
      else
         g_main_rec.DUAL_AUTHORISATION_BY := NULL;
         g_main_rec.DUAL_AUTHORISATION_ON := NULL;
      end if;
      --Bug 2254853

   end if;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('COPY_FROM_INTERFACE_TO_EXP: ' || 'XTR_EXP_TRANSFERS.COPY_FROM_INT_TO_EXP');
   END IF;
END COPY_FROM_INTERFACE_TO_EXP;




/*------------------------------------------------------------------------
This procedure assigns the values to the global record that will be used
to insert the deal later on.
------------------------------------------------------------------------*/
procedure COPY_TO_EXP
	(ARec IN OUT NOCOPY XTR_EXPOSURE_TRANSACTIONS%rowtype) IS

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.COPY_TO_EXP');
   END IF;

      --per request from One-Step API by Venil
      ARec.transaction_number := get_transaction_number;

      g_main_rec.ACCOUNT_NO := ARec.account_no;
      g_main_rec.ACTION_CODE := ARec.action_code;
      g_main_rec.AMOUNT  := ARec.amount;
      --AVG_RATE has to be called earlier than AMOUNT_HCE,
      --because AMOUNT_HCE requires AVG_RATE.
      g_main_rec.AVG_RATE := ARec.avg_rate;
      g_main_rec.AMOUNT_HCE := ARec.amount_hce;
      g_main_rec.AMOUNT_TYPE := 'AMOUNT'; --refer to hidden item in ET block
      g_main_rec.ARCHIVE_BY := null;
      g_main_rec.ARCHIVE_DATE := null;
      g_main_rec.AUDIT_INDICATOR := NULL;
      g_main_rec.BALANCE := ARec.balance;
      g_main_rec.BENEFICIARY_CODE := ARec.beneficiary_code;
      g_main_rec.COMMENTS := ARec.comments;
      g_main_rec.COMPANY_CODE := ARec.company_code;
      g_main_rec.CONTRA_NZD_AMOUNT := ARec.contra_nzd_amount;
      g_main_rec.COVERED_BY_FX_CONTRACT := ARec.covered_by_fx_contract;
      g_main_rec.CPARTY_CODE := ARec.cparty_code;
      g_main_rec.CPARTY_ACCOUNT_NO := ARec.cparty_account_no;  -- CE BANK MIGRATION
      g_main_rec.CPARTY_REF := null; --bug 3034164
      g_main_rec.CREATED_BY := g_user;
      g_main_rec.CREATED_ON := g_curr_date;
      g_main_rec.CURRENCY := ARec.currency;
      g_main_rec.DEAL_STATUS := ARec.deal_status; --refer to STATUS_CODE
      --DEAL_TYPE has to be called earlier than DEAL_SUBTYPE,
      --because to get actual DEAL_SUBTYPE requires the actual DEAL_TYPE.
      g_main_rec.DEAL_TYPE := ARec.deal_type;
      g_main_rec.DEAL_SUBTYPE := ARec.deal_subtype;
      g_main_rec.ESTIMATE_AMOUNT := ARec.estimate_amount;
      g_main_rec.ESTIMATE_DATE := ARec.estimate_date;
      g_main_rec.EXPOSURE_TYPE := ARec.exposure_type;
      g_main_rec.FIS_FOB := ARec.fis_fob;
      g_main_rec.INTERMEDIARY_BANK_DETAILS := ARec.intermediary_bank_details;
      g_main_rec.NZD_AMOUNT := ARec.nzd_amount;
      g_main_rec.PAYMENT_AMOUNT  := ARec.payment_amount;
      g_main_rec.PAYMENT_STATUS  := ARec.payment_status;
      g_main_rec.PORTFOLIO_CODE  := ARec.portfolio_code;
      g_main_rec.PROFIT_LOSS := ARec.profit_loss;
      g_main_rec.PURCHASING_MODULE := ARec.purchasing_module;
      g_main_rec.SELECT_ACTION := ARec.select_action;
      g_main_rec.SELECT_REFERENCE := ARec.select_reference;
      g_main_rec.SETTLE_ACTION_REQD := ARec.settle_action_reqd;
      --there is no formal status code in EXP deal, deal can be deleted, but
      --to be consistent put 'CURRENT'
      g_main_rec.STATUS_CODE := nvl(ARec.status_code,'CURRENT');
      g_main_rec.SUBSIDIARY_REF  := ARec.subsidiary_ref;
      g_main_rec.TAX_BROKERAGE_TYPE := ARec.tax_brokerage_type;
      g_main_rec.THIRDPARTY_CODE := ARec.thirdparty_code;
      g_main_rec.TRANSACTION_NUMBER := ARec.transaction_number;
      g_main_rec.UPDATED_BY := null;
      g_main_rec.UPDATED_ON := null;
      g_main_rec.VALUE_DATE := ARec.value_date;
      g_main_rec.WHOLESALE_REFERENCE := ARec.wholesale_reference;
      g_main_rec.ATTRIBUTE_CATEGORY := ARec.attribute_category;
      g_main_rec.ATTRIBUTE1 := ARec.attribute1;
      g_main_rec.ATTRIBUTE2 := ARec.attribute2;
      g_main_rec.ATTRIBUTE3 := ARec.attribute3;
      g_main_rec.ATTRIBUTE4 := ARec.attribute4;
      g_main_rec.ATTRIBUTE5 := ARec.attribute5;
      g_main_rec.ATTRIBUTE6 := ARec.attribute6;
      g_main_rec.ATTRIBUTE7 := ARec.attribute7;
      g_main_rec.ATTRIBUTE8 := ARec.attribute8;
      g_main_rec.ATTRIBUTE9 := ARec.attribute9;
      g_main_rec.ATTRIBUTE10 := ARec.attribute10;
      g_main_rec.ATTRIBUTE11 := ARec.attribute11;
      g_main_rec.ATTRIBUTE12 := ARec.attribute12;
      g_main_rec.ATTRIBUTE13 := ARec.attribute13;
      g_main_rec.ATTRIBUTE14 := ARec.attribute14;
      g_main_rec.ATTRIBUTE15 := ARec.attribute15;
      g_main_rec.EXTERNAL_DEAL_ID := ARec.external_deal_id;
      g_main_rec.REQUEST_ID := fnd_global.conc_request_id;
      g_main_rec.PROGRAM_APPLICATION_ID  := fnd_global.prog_appl_id;
      g_main_rec.PROGRAM_ID := fnd_global.conc_program_id;
      g_main_rec.PROGRAM_UPDATE_DATE := g_curr_date;
      g_main_rec.INTERNAL_COMMENTS := ARec.internal_comments;
      g_main_rec.EXTERNAL_COMMENTS := ARec.external_comments;
      g_main_rec.DEAL_LINK_CODE := ARec.deal_link_code;
      g_main_rec.DUAL_AUTHORISATION_BY := g_user;
      g_main_rec.DUAL_AUTHORISATION_ON := trunc(g_curr_date);
      g_main_rec.CASH_POSITION_EXPOSURE := ARec.cash_position_exposure;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.COPY_TO_EXP');
   END IF;
END COPY_TO_EXP;




/*------------------------------------------------------------------------
This procedure is used to check whether all the mandatory fields are
NOT NULL.
If there is error then log the error.
------------------------------------------------------------------------*/
procedure CHECK_MANDATORY_FIELDS(ARec_Interface IN XTR_DEALS_INTERFACE%rowtype
				,p_error OUT NOCOPY BOOLEAN) IS

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.CHECK_MANDATORY_FIELDS');
   END IF;

        p_error := FALSE;

	if ARec_Interface.company_code is null then
           log_errors(ARec_Interface.external_deal_id,
			ARec_Interface.deal_type,
                        'CompanyCode','XTR_MANDATORY','ET.COMPANY_CODE');
           p_error := TRUE;
	end if;
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('CHECK_MANDATORY_FIELDS: ' || 'company_code',p_error);
END IF;
	if ARec_Interface.exposure_type is null then
           log_errors(ARec_Interface.external_deal_id,
			ARec_Interface.deal_type,
                        'ExposureType','XTR_MANDATORY','ET.EXPOSURE_TYPE');
           p_error := TRUE;
	end if;
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('CHECK_MANDATORY_FIELDS: ' || 'exposure_type',p_error);
END IF;
	if ARec_Interface.deal_subtype is null then
           log_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                        'DealSubtype','XTR_MANDATORY','ET.USER_DEAL_SUBTYPE');
           p_error := TRUE;
	end if;
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('CHECK_MANDATORY_FIELDS: ' || 'deal_subtype',p_error);
END IF;
	if ARec_Interface.portfolio_code is null then
           log_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                        'PortfolioCode','XTR_MANDATORY','ET.PORTFOLIO_CODE');
           p_error := TRUE;
	end if;
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('CHECK_MANDATORY_FIELDS: ' || 'portfolio_code',p_error);
END IF;
	if ARec_Interface.action_code is null then
           log_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                        'ActionCode','XTR_MANDATORY','ET.USER_ACTION_CODE');
           p_error := TRUE;
	end if;
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('CHECK_MANDATORY_FIELDS: ' || 'action_code',p_error);
END IF;
	if ARec_Interface.currency_a is null then
           log_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                        'CurrencyA','XTR_MANDATORY','ET.CURRENCY');
           p_error := TRUE;
	end if;
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('CHECK_MANDATORY_FIELDS: ' || 'currency_a',p_error);
END IF;
	if ARec_Interface.settle_action_reqd is null then
           log_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                        'SettleActionReqd','XTR_MANDATORY','ET.SETTLE_ACTION_REQD');
           p_error := TRUE;
	end if;
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('CHECK_MANDATORY_FIELDS: ' || 'settle_action_reqd',p_error);
END IF;
	if ARec_Interface.account_no_a is null then
           log_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                        'AccountNoA','XTR_MANDATORY','ET.ACCOUNT_NO');
           p_error := TRUE;
	end if;
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('CHECK_MANDATORY_FIELDS: ' || 'account_no_a',p_error);
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.CHECK_MANDATORY_FIELDS');
   END IF;
END check_mandatory_fields;



/*------------------------------------------------------------------------
This procedure validates the business logic for the deal items.
------------------------------------------------------------------------*/
procedure VALIDATE_DEALS(ARec_Interface IN XTR_DEALS_INTERFACE%rowtype,
		p_error OUT NOCOPY BOOLEAN) IS

--   v_holiday_level VARCHAR2(1);
--   v_holiday_error NUMBER;

   v_err_segment VARCHAR2(30);
   p_cparty_error BOOLEAN := FALSE;

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.VALIDATE_DEALS');
   END IF;

     p_error := FALSE;

     if not valid_company_code(ARec_Interface.Company_Code) then
        Log_Errors(ARec_Interface.external_deal_id,
		ARec_Interface.deal_type,
                'CompanyCode','XTR_INV_COMP_CODE');
        p_error      := TRUE;
     end if;

     --DEAL_TYPE has to be called earlier than DEAL_SUBTYPE,
     --because to get actual DEAL_SUBTYPE requires the actual DEAL_TYPE.
--     if not valid_status_code(ARec_Interface.status_code) then
--        Log_Errors(ARec_Interface.external_deal_id,
--		ARec_Interface.deal_type,
--                'StatusCode','XTR_INV_STATUS_CODE');
--        p_error := TRUE;
--     end if;

     if not valid_exposure_type(ARec_Interface.company_code,
     ARec_Interface.exposure_type) then
        Log_Errors(ARec_Interface.external_deal_id,
		ARec_Interface.deal_type,
                'ExposureType','XTR_INV_EXPOSURE_TYPE');
        p_error := TRUE;
     end if;

     if not valid_deal_subtype('EXP',
     ARec_Interface.deal_subtype) then
        Log_Errors(ARec_Interface.external_deal_id,
		ARec_Interface.deal_type,
                'DealSubtype','XTR_INV_DEAL_SUBTYPE');
        p_error := TRUE;
     end if;

     if not valid_portfolio(ARec_Interface.company_code,
     ARec_Interface.portfolio_code) then
        Log_Errors(ARec_Interface.external_deal_id,
		ARec_Interface.deal_type,
                'PortfolioCode','XTR_INV_PORT_CODE');
        p_error := TRUE;
     end if;

     if not valid_action(ARec_Interface.action_code,
     ARec_Interface.deal_type) then
        Log_Errors(ARec_Interface.external_deal_id,
		ARec_Interface.deal_type,
                'ActionCode','XTR_INV_ACTION');
        p_error := TRUE;
     end if;

     if not valid_currency(ARec_Interface.Currency_A) then
        Log_Errors(ARec_Interface.external_deal_id,
		ARec_Interface.deal_type,
                'CurrencyA','XTR_INV_CURR');
        p_error := TRUE;
     end if;

     if not valid_comp_acct(ARec_Interface.company_code,
     ARec_Interface.account_no_a,ARec_Interface.currency_a) then
        Log_Errors(ARec_Interface.external_deal_id,
		ARec_Interface.deal_type,
                'AccountNoA','XTR_INV_COMP_ACCT_NO');
        p_error := TRUE;
     end if;

     --
     --All amounts cannot be negative numbers.
     --
     if NVL(ARec_Interface.amount_a,0)<0 then
        Log_Errors(ARec_Interface.external_deal_id,
		ARec_Interface.deal_type,
                'AmountA','XTR_VALUE_GE_ZERO');
        p_error := TRUE;
     end if;

     if NVL(ARec_Interface.amount_b,0)<0 then
        Log_Errors(ARec_Interface.external_deal_id,
		ARec_Interface.deal_type,
                'AmountB','XTR_56');
        p_error := TRUE;
     end if;

     --
     --Error if both estimate and actual amounts are zero
     --
--     if ((ARec_Interface.amount_a IS NULL)
--      and (ARec_Interface.amount_b IS NULL)) then
--        Log_Errors(ARec_Interface.external_deal_id,
--                ARec_Interface.deal_type,
--                'AmountB','XTR_NEED_AMOUNT');
--        p_error := TRUE;
--     end if;

     --
     --Warn if dates fall into holidays.
     --
--     xtr_fps3_p.CHK_HOLIDAY (ARec_Interface.date_a,
--                       ARec_Interface.currency_a,
--                       v_holiday_error,
--                       v_holiday_level);
--     if v_holiday_error is not null then
--        Log_Errors(ARec_Interface.external_deal_id,
--		ARec_Interface.deal_type,
--                'DateA','XTR_INV_ESTIMATE_DATE');
--        p_error := TRUE;
--     end if;

--     xtr_fps3_p.CHK_HOLIDAY (ARec_Interface.date_b,
--                       ARec_Interface.currency_a,
--                       v_holiday_error,
--                       v_holiday_level);
--     if v_holiday_error is not null then
--        Log_Errors(ARec_Interface.external_deal_id,
--		ARec_Interface.deal_type,
--                'DateB','XTR_INV_ACTUAL_DATE');
--        p_error := TRUE;
--     end if;

     if not valid_settle_action(ARec_Interface.settle_action_reqd,
     ARec_Interface.deal_subtype, ARec_Interface.amount_b,
     ARec_Interface.date_b, ARec_Interface.cparty_code) then
        Log_Errors(ARec_Interface.external_deal_id,
		ARec_Interface.deal_type,
                'SettleActionReqd','XTR_INV_SETTLE_ACTION_REQD');
        p_error := TRUE;
     end if;

     if ARec_Interface.cparty_code is not null and
     not valid_cparty_code(ARec_Interface.company_code,
     ARec_Interface.cparty_code) then
        Log_Errors(ARec_Interface.external_deal_id,
		ARec_Interface.deal_type,
                'CpartyCode','XTR_INV_CPARTY_CODE');
        p_error := TRUE;
     end if;

     if (ARec_Interface.account_no_b is not null or ARec_Interface.cparty_account_no is not null) and
     not valid_cparty_ref(ARec_interface.cparty_account_no,ARec_Interface.account_no_b,
     ARec_Interface.cparty_code, ARec_Interface.currency_a) then
        Log_Errors(ARec_Interface.external_deal_id,
		ARec_Interface.deal_type,
                'CpartyAccountNo','XTR_INV_CPARTY_ACCOUNT');
        p_error := TRUE;
        p_cparty_error := TRUE;
     end if;

     if (ARec_Interface.dual_authorization_by is not null and
     not valid_dealer_code(ARec_Interface.dual_authorization_by)) then
        Log_Errors(ARec_Interface.external_deal_id,
                  ARec_Interface.deal_type,
		  'DualAuthorizationBy','XTR_INV_DUAL_AUTH_BY'); -- Bug 2254853
        p_error := TRUE;
     end if;

     if p_cparty_error <> TRUE and ARec_Interface.cparty_code is NOT NULL AND
     ARec_Interface.account_no_b is NOT NULL then
        G_cparty_account := get_cparty_account(ARec_Interface.cparty_code,
				ARec_Interface.currency_a,
				ARec_Interface.account_no_b);
        if G_cparty_account is null then
           Log_Errors(ARec_Interface.external_deal_id,
		ARec_Interface.deal_type,
                'CpartyAccountNo','XTR_CPARTY_ACCT_REQD');  -- CE BANK MIGRATION
           p_error := TRUE;
        end if;
     end if;

     if ARec_Interface.deal_linking_code is not null and
     not valid_deal_link_code(ARec_Interface.deal_linking_code) then
        Log_Errors(ARec_Interface.external_deal_id,
		ARec_Interface.deal_type,
                'DealLinkingCode','XTR_INV_LINKING_CODE');
        p_error := TRUE;
     end if;

     --
     --validate Descriptive Flexfields
     --
     if not (xtr_import_deal_data.val_desc_flex(
     ARec_Interface,'XTR_EXP_DESC',v_err_segment)) then
        p_error := TRUE;
        if v_err_segment is not null and v_err_segment = 'Attribute16' then
           Log_Errors( ARec_Interface.external_deal_id,
                          ARec_Interface.deal_type,
                          v_err_segment,
                          'XTR_INV_DESC_FLEX_API');
        elsif v_err_segment is not null and
	v_err_segment='AttributeCategory' then
           Log_Errors( ARec_Interface.external_deal_id,
                          ARec_Interface.deal_type,
                          v_err_segment,
                          'XTR_INV_DESC_FLEX_CONTEXT');
        else
           Log_Errors( ARec_Interface.external_deal_id,
                          ARec_Interface.deal_type,
                          v_err_segment,
                          'XTR_INV_DESC_FLEX');
        end if;
     end if;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.VALIDATE_DEALS');
   END IF;
END VALIDATE_DEALS;


/*------------------------------------------------------------------------
This procedure is used to transfer EXP deals for the open API.
------------------------------------------------------------------------*/
function GET_TRANSACTION_NUMBER return number IS
   cursor trans_no is
      select XTR_EXPOSURE_TRANS_S.NEXTVAL
      from DUAL;

   v_trans_no NUMBER;

BEGIN
   xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.GET_TRANSACTION_NUMBER');

   open trans_no;
   fetch trans_no into v_trans_no;
   close trans_no;

   xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.GET_TRANSACTION_NUMBER');
   return v_trans_no;
END get_transaction_number;



/*------------------------------------------------------------------------
This procedure is used to get thirdparty account.
------------------------------------------------------------------------*/
function GET_CPARTY_ACCOUNT(p_cparty_code IN VARCHAR2,
			p_curr IN VARCHAR2,
			p_cparty_ref IN VARCHAR2) return varchar2 IS

   cursor REF_ACC is
      select ACCOUNT_NUMBER
      from  XTR_BANK_ACCOUNTS_V
      where PARTY_CODE = p_cparty_code
      and   CURRENCY   = p_curr
      and   BANK_SHORT_CODE = p_cparty_ref;

   v_cparty_account VARCHAR2(20);

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.GET_CPARTY_ACCOUNT');
   END IF;

   open REF_ACC;
   fetch REF_ACC into v_cparty_account;
   close REF_ACC;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.GET_CPARTY_ACCOUNT');
   END IF;
   return v_cparty_account;
END get_cparty_account;



/*------------------------------------------------------------------------
This procedure is the table handler for XTR_EXPOSURE_TRANSACTIONS
------------------------------------------------------------------------*/
procedure CREATE_EXP_DEAL(ARec_Exp IN XTR_EXPOSURE_TRANSACTIONS%rowtype) IS

    cursor FIND_USER (p_fnd_user in number) is
    select dealer_code
    from   xtr_dealer_codes_v
    where  user_id = p_fnd_user;

    l_user       xtr_dealer_codes.dealer_code%TYPE;
    l_dual_user  xtr_dealer_codes.dealer_code%TYPE;
    l_dual_date  DATE;

BEGIN

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.CREATE_EXP_DEAL');
   END IF;

   open  FIND_USER(G_User_Id);
   fetch FIND_USER into l_user;
   close FIND_USER;

   l_dual_user := ARec_Exp.DUAL_AUTHORISATION_BY;
   l_dual_date := ARec_Exp.DUAL_AUTHORISATION_ON;
   if ((l_dual_user is not null and l_dual_date is null) or
      (l_dual_user is null and l_dual_date is not null)) then
      if l_dual_date is null then
         l_dual_date := trunc(sysdate);
      elsif l_dual_user is null then
         l_dual_user := l_user;
      end if;
   end if;

   INSERT INTO xtr_exposure_transactions (
	ACCOUNT_NO,
	ACTION_CODE,
	AMOUNT ,
	AMOUNT_HCE,
	AMOUNT_TYPE,
	ARCHIVE_BY,
	ARCHIVE_DATE,
	AUDIT_INDICATOR,
	AVG_RATE,
	BALANCE,
	BENEFICIARY_CODE,
	COMMENTS,
	COMPANY_CODE,
	CONTRA_NZD_AMOUNT,
	COVERED_BY_FX_CONTRACT ,
	CPARTY_CODE,
	CPARTY_ACCOUNT_NO, -- CE BANK MIGRATION
	CPARTY_REF,
	CREATED_BY,
	CREATED_ON,
	CURRENCY,
	DEAL_STATUS,
	DEAL_SUBTYPE,
	DEAL_TYPE,
	ESTIMATE_AMOUNT,
	ESTIMATE_DATE,
	EXPOSURE_TYPE,
	FIS_FOB,
	INTERMEDIARY_BANK_DETAILS,
	NZD_AMOUNT,
	PAYMENT_AMOUNT ,
	PAYMENT_STATUS ,
	PORTFOLIO_CODE ,
	PROFIT_LOSS,
	PURCHASING_MODULE,
	SELECT_ACTION,
	SELECT_REFERENCE,
	SETTLE_ACTION_REQD,
	STATUS_CODE,
	SUBSIDIARY_REF ,
	TAX_BROKERAGE_TYPE,
	THIRDPARTY_CODE,
	TRANSACTION_NUMBER,
	UPDATED_BY,
	UPDATED_ON,
	VALUE_DATE,
	WHOLESALE_REFERENCE,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
	EXTERNAL_DEAL_ID,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID ,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	INTERNAL_COMMENTS,
	EXTERNAL_COMMENTS,
	DEAL_LINK_CODE,
	DUAL_AUTHORISATION_BY,
	DUAL_AUTHORISATION_ON,
	CASH_POSITION_EXPOSURE
	)
	VALUES (
	Arec_Exp.ACCOUNT_NO,
	Arec_Exp.ACTION_CODE,
	Arec_Exp.AMOUNT ,
	Arec_Exp.AMOUNT_HCE,
	Arec_Exp.AMOUNT_TYPE,
	Arec_Exp.ARCHIVE_BY,
	Arec_Exp.ARCHIVE_DATE,
	Arec_Exp.AUDIT_INDICATOR,
	Arec_Exp.AVG_RATE,
	Arec_Exp.BALANCE,
	Arec_Exp.BENEFICIARY_CODE,
	Arec_Exp.COMMENTS,
	Arec_Exp.COMPANY_CODE,
	Arec_Exp.CONTRA_NZD_AMOUNT,
	Arec_Exp.COVERED_BY_FX_CONTRACT ,
	Arec_Exp.CPARTY_CODE,
	Arec_Exp.CPARTY_ACCOUNT_NO,
	Arec_Exp.CPARTY_REF,
	Arec_Exp.CREATED_BY,
	Arec_Exp.CREATED_ON,
	Arec_Exp.CURRENCY,
	Arec_Exp.DEAL_STATUS,
	Arec_Exp.DEAL_SUBTYPE,
	Arec_Exp.DEAL_TYPE,
	Arec_Exp.ESTIMATE_AMOUNT,
	Arec_Exp.ESTIMATE_DATE,
	Arec_Exp.EXPOSURE_TYPE,
	Arec_Exp.FIS_FOB,
	Arec_Exp.INTERMEDIARY_BANK_DETAILS,
	Arec_Exp.NZD_AMOUNT,
	Arec_Exp.PAYMENT_AMOUNT ,
	Arec_Exp.PAYMENT_STATUS ,
	Arec_Exp.PORTFOLIO_CODE ,
	Arec_Exp.PROFIT_LOSS,
	Arec_Exp.PURCHASING_MODULE,
	Arec_Exp.SELECT_ACTION,
	Arec_Exp.SELECT_REFERENCE,
	Arec_Exp.SETTLE_ACTION_REQD,
	Arec_Exp.STATUS_CODE,
	Arec_Exp.SUBSIDIARY_REF ,
	Arec_Exp.TAX_BROKERAGE_TYPE,
	Arec_Exp.THIRDPARTY_CODE,
	Arec_Exp.TRANSACTION_NUMBER,
	Arec_Exp.UPDATED_BY,
	Arec_Exp.UPDATED_ON,
	Arec_Exp.VALUE_DATE,
	Arec_Exp.WHOLESALE_REFERENCE,
	Arec_Exp.ATTRIBUTE_CATEGORY,
	Arec_Exp.ATTRIBUTE1,
	Arec_Exp.ATTRIBUTE2,
	Arec_Exp.ATTRIBUTE3,
	Arec_Exp.ATTRIBUTE4,
	Arec_Exp.ATTRIBUTE5,
	Arec_Exp.ATTRIBUTE6,
	Arec_Exp.ATTRIBUTE7,
	Arec_Exp.ATTRIBUTE8,
	Arec_Exp.ATTRIBUTE9,
	Arec_Exp.ATTRIBUTE10,
	Arec_Exp.ATTRIBUTE11,
	Arec_Exp.ATTRIBUTE12,
	Arec_Exp.ATTRIBUTE13,
	Arec_Exp.ATTRIBUTE14,
	Arec_Exp.ATTRIBUTE15,
	Arec_Exp.EXTERNAL_DEAL_ID,
	Arec_Exp.REQUEST_ID,
	Arec_Exp.PROGRAM_APPLICATION_ID ,
	Arec_Exp.PROGRAM_ID,
	Arec_Exp.PROGRAM_UPDATE_DATE,
	Arec_Exp.INTERNAL_COMMENTS,
	Arec_Exp.EXTERNAL_COMMENTS,
	Arec_Exp.DEAL_LINK_CODE,
	l_dual_user,                     --Bug 2254853
	l_dual_date,                     --Bug 2254853
	Arec_Exp.CASH_POSITION_EXPOSURE
	);

   if l_dual_user is not null then
      UPDATE xtr_confirmation_details
      SET    confirmation_validated_by = l_dual_user,
	     confirmation_validated_on = l_dual_date
      WHERE  deal_type = 'EXP'
      AND    transaction_no = Arec_Exp.TRANSACTION_NUMBER;
   end if;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.CREATE_EXP_DEAL');
   END IF;

--The following exception is handled in Transfer_Deals_Protected
--and should not be handled here because the potential deal would
--otherwise be deleted from the list

--exception
--  when OTHERS then
--    UPDATE Xtr_Deals_Interface
--    SET Load_Status_Code='ERROR'
--    WHERE External_Deal_Id=Arec_Exp.External_Deal_Id;

END CREATE_EXP_DEAL;



/*------------------------------------------------------------------------
This procedure is the table handler for XTR_DEAL_DATE_AMOUNTS_V
------------------------------------------------------------------------*/
PROCEDURE INS_DEAL_DATE_AMOUNTS (ARec_Exp IN XTR_EXPOSURE_TRANSACTIONS%rowtype)
	IS

-- bug 1849281 proper dealer id should be inserted into dda
  cursor DEALER is
  select DEALER_CODE
  from XTR_DEALER_CODES_V
  where user_id = g_user_id;
--
  v_dealer xtr_dealer_codes.dealer_code%TYPE;
-- end bug 1849281

  v_dual_user  xtr_dealer_codes.dealer_code%TYPE;
  v_dual_date  DATE;

  v_comments VARCHAR2(255);
  v_portfolio_code VARCHAR2(7);
  v_balance_sheet_exposure VARCHAR2(1);
  v_cashflow_amount NUMBER;
  v_cparty_account_no VARCHAR2(20);

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.INS_DEAL_DATE_AMOUNTS');
   END IF;

 -- bug 1849281 select the dealer id
    Open DEALER;
    Fetch DEALER into v_dealer;
    Close DEALER;
 -- end bug 1849281

 --The following logic differentiates some parameter inserted into DDA
 --depending on the purpose/caller indicated by g_source.
 IF g_source='TAX' THEN
    v_comments := AREC_EXP.COMMENTS;
    v_portfolio_code := 'NOTAPPL' ;                     -- bug 4910602
    v_balance_sheet_exposure := NULL;
    v_cashflow_amount := nvl(AREC_EXP.AMOUNT,AREC_EXP.ESTIMATE_AMOUNT);
    v_cparty_account_no := G_cparty_account;
 --Gross Compounded Interest Action requires cashflow=0, so that it won't be
 --shown in Settlement Form.
 ELSIF g_source= 'TAX_CP_G' THEN
    v_comments := AREC_EXP.COMMENTS;
    v_portfolio_code := 'NOTAPPL';                         -- bug 4910602
    v_balance_sheet_exposure := NULL;
    v_cashflow_amount := 0;
    v_cparty_account_no := G_cparty_account;
 ELSE
    v_comments := NULL;
    v_portfolio_code := nvl(AREC_EXP.PORTFOLIO_CODE,'NOTAPPL');
    v_balance_sheet_exposure := 'N';
    v_cashflow_amount := nvl(AREC_EXP.AMOUNT,AREC_EXP.ESTIMATE_AMOUNT);
    IF AREC_EXP.ACTION_CODE='PAY' THEN
       v_cparty_account_no := G_cparty_account;
    ELSE
       v_cparty_account_no := '';
    END IF;
 END IF;

 --Bug 2254853
 v_dual_user := ARec_Exp.DUAL_AUTHORISATION_BY;
 v_dual_date := ARec_Exp.DUAL_AUTHORISATION_ON;
 if ((v_dual_user is not null and v_dual_date is null) or
    (v_dual_user is null and v_dual_date is not null)) then
    if v_dual_date is null then
       v_dual_date := trunc(sysdate);
    elsif v_dual_user is null then
       v_dual_user := v_dealer;
    end if;
 end if;
 --Bug 2254853

 --CGC$USER_1=v_dealer and CGC$SYSDATE_1=trunc(sysdate)
 --from KEY_STARTUP procedure.
 insert into XTR_DEAL_DATE_AMOUNTS_V
        (deal_type,amount_type,date_type,product_type,
         deal_number,transaction_number,transaction_date,
         currency,amount,hce_amount,amount_date,
         cashflow_amount,company_code,account_no,action_code,
         cparty_account_no,cparty_code,status_code,settle,
         exp_settle_reqd,deal_subtype,portfolio_code,balance_sheet_exposure,
         dual_authorisation_by, dual_authorisation_on,
	 dealer_code, comments)
	-- bug 1849281
 values ('EXP','AMOUNT','VALUE',ARec_Exp.EXPOSURE_TYPE,
         0,ARec_Exp.TRANSACTION_NUMBER,
         nvl(ARec_Exp.VALUE_DATE,AREC_EXP.ESTIMATE_DATE),AREC_EXP.CURRENCY,
	 nvl(nvl(AREC_EXP.AMOUNT,AREC_EXP.ESTIMATE_AMOUNT),0),
         nvl(AREC_EXP.AMOUNT_HCE,nvl(nvl(AREC_EXP.AMOUNT,
	 AREC_EXP.ESTIMATE_AMOUNT),0)),
	 nvl(AREC_EXP.VALUE_DATE,AREC_EXP.ESTIMATE_DATE),
         decode(AREC_EXP.ACTION_CODE,'PAY',(-1),1)*v_cashflow_amount,
         AREC_EXP.COMPANY_CODE,AREC_EXP.ACCOUNT_NO,AREC_EXP.ACTION_CODE,
         v_cparty_account_no,
         AREC_EXP.THIRDPARTY_CODE,AREC_EXP.STATUS_CODE,'N',
         nvl(AREC_EXP.SETTLE_ACTION_REQD,'N'),AREC_EXP.DEAL_SUBTYPE,
         v_portfolio_code,v_balance_sheet_exposure,
         v_dual_user, v_dual_date, --Bug 2254853
	 v_dealer, v_comments);
	 -- bug 1849281
--
 --No need for 2nd row insertion for TAX.
 IF g_source IS NULL OR g_source IN ('CONC','FORM') THEN
 /*====================*/
 /* Enhancement to DDA */
 /*====================*/
    insert into XTR_DEAL_DATE_AMOUNTS_V
        (deal_type,amount_type,date_type,product_type,
         deal_number,transaction_number,transaction_date,
         currency,amount,hce_amount,amount_date,
         cashflow_amount,company_code,account_no,action_code,
         cparty_account_no,cparty_code,status_code,settle,
         exp_settle_reqd,deal_subtype,portfolio_code,balance_sheet_exposure,
         dual_authorisation_by, dual_authorisation_on, dealer_code, comments)
	 -- bug 1849281
    values ('EXP','N/A','DEALT',ARec_Exp.EXPOSURE_TYPE,
         0,AREC_EXP.TRANSACTION_NUMBER,
         trunc(SYSDATE),AREC_EXP.CURRENCY,0,
         0,trunc(SYSDATE),
         0,AREC_EXP.COMPANY_CODE,NULL,NULL,NULL,
         AREC_EXP.THIRDPARTY_CODE,AREC_EXP.STATUS_CODE,'N',
         nvl(AREC_EXP.SETTLE_ACTION_REQD,'N'),AREC_EXP.DEAL_SUBTYPE,
         v_portfolio_code,v_balance_sheet_exposure,
         v_dual_user, v_dual_date,  --Bug 2254853
	 v_dealer, v_comments);
	 -- bug 1849281
 END IF;

   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.INS_DEAL_DATE_AMOUNTS');
   END IF;
END INS_DEAL_DATE_AMOUNTS;


/*------------------------------------------------------------------------
This procedure is used to transfer EXP deals for the open API from
the concurrent program.
p_source =  CONC (if called from CONC Program for Deal Import)
Stub for backwards compatibility
------------------------------------------------------------------------*/
procedure TRANSFER_EXP_DEALS( ARec_Interface IN  XTR_DEALS_INTERFACE%rowtype,
                               p_source           IN  VARCHAR2,
                               user_error         OUT NOCOPY BOOLEAN,
                               mandatory_error    OUT NOCOPY BOOLEAN,
                               validation_error   OUT NOCOPY BOOLEAN,
                               limit_error        OUT NOCOPY BOOLEAN) IS
  v_dummy NUMBER;
BEGIN
  TRANSFER_EXP_DEALS(ARec_Interface,p_source,user_error,mandatory_error,validation_error,limit_error,v_dummy);
END TRANSFER_EXP_DEALS;



/*------------------------------------------------------------------------
This procedure is used to transfer EXP deals for the open API from
the concurrent program.
p_source =  CONC (if called from CONC Program for Deal Import)
------------------------------------------------------------------------*/
procedure TRANSFER_EXP_DEALS( ARec_Interface IN  XTR_DEALS_INTERFACE%rowtype,
                               p_source           IN  VARCHAR2,
                               user_error         OUT NOCOPY BOOLEAN,
                               mandatory_error    OUT NOCOPY BOOLEAN,
                               validation_error   OUT NOCOPY BOOLEAN,
                               limit_error        OUT NOCOPY BOOLEAN,
                               deal_num           OUT NOCOPY NUMBER) IS

   CURSOR FIND_USER (p_fnd_user in number) is
     select dealer_code
     from   xtr_dealer_codes_v
     where  user_id = p_fnd_user;

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.TRANSFER_EXP_DEALS');
   END IF;
   --
   --Initialize variables
   --
   user_error         := FALSE;
   mandatory_error    := FALSE;
   validation_error   := FALSE;
   limit_error        := FALSE; --no limit for EXPOSURE

   g_source := p_source;
   g_curr_date := SYSDATE;
   g_user_id := FND_GLOBAL.USER_ID;
   g_cparty_account := null;
   OPEN find_user(g_user_id);
   FETCH find_user INTO g_user;
   CLOSE find_user;

   --
   --Purge the related data from the error table
   --
   if g_source is null then
      delete from xtr_interface_errors
        where  external_deal_id = ARec_Interface.external_deal_id
        and    deal_type        = ARec_Interface.deal_type;
   end if;

   --
   --Check if the user has permissions to transfer the deal
   --
   xtr_import_deal_data.CHECK_USER_AUTH(ARec_Interface.external_deal_id,
                                          ARec_Interface.deal_type,
                                          ARec_Interface.company_code,
                                          user_error);

IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('TRANSFER_EXP_DEALS: ' || 'user_error',user_error);
END IF;

   if (user_error <> TRUE) then
      --
      --The following code does mandatory field validation specific to the deal
      --
      CHECK_MANDATORY_FIELDS(ARec_Interface,mandatory_error);
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('TRANSFER_EXP_DEALS: ' || 'mandatory_error',mandatory_error);
END IF;

      if (mandatory_error <> TRUE) then
         --
         -- The following code performs the business logic validation
         --
         VALIDATE_DEALS(ARec_Interface, validation_error);
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('TRANSFER_EXP_DEALS: ' || 'validation_error',validation_error);
END IF;

         if (validation_error <> TRUE) then
            --
            -- Copy to the temp. storage that will be used for inserting
	    -- into the XTR_EXPOSURE_TRANSACTIONS table
            --
      	    COPY_FROM_INTERFACE_TO_EXP(ARec_Interface, validation_error);
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('TRANSFER_EXP_DEALS: ' || 'validation_error from COPY',validation_error);
END IF;

         end if; --validation error
      end if; --mandatory_error
   end if; --user_error

   --
   --If the process passed all the previous validation, it would be
   --considered a valid deal entry.
   --
   if user_error  <> TRUE and mandatory_error  <> TRUE and
   limit_error <> TRUE and validation_error <> TRUE then
      --
      --Insert deal
      --
      CREATE_EXP_DEAL(g_main_rec);
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('TRANSFER_EXP_DEALS: ' || 'After inserting to XTR_EXPOSURE_TRANSACTIONS');
END IF;
      --
      --Also insert to XTR_DEAL_DATE_AMOUNTS_V
      --
      INS_DEAL_DATE_AMOUNTS(g_main_rec);

      deal_num:=g_main_rec.transaction_number;
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('TRANSFER_EXP_DEALS: ' || 'After inserting to XTR_DEAL_DATE_AMOUNTS');
END IF;
      COMMIT;
      --
      --Since the insert is done, we can now delete the rows from the
      --interface table.
      --
      if G_Source is null then
         delete from xtr_deals_interface
             where external_deal_id = ARec_Interface.external_deal_id
             and   deal_type        = ARec_Interface.deal_type;
      end if;

   else    /* if any other errors */
      /*---------------------------------------------*/
      /*  Deal interface has error.  Do not import.  */
      /*---------------------------------------------*/
      if G_Source is null then
           update xtr_deals_interface
           set    load_status_code = 'ERROR',
                  last_update_date = G_curr_date,
                  last_Updated_by  = G_user_id
           where  external_deal_id = ARec_Interface.external_deal_id
           and    deal_type        = ARec_Interface.deal_type;
      end if;
   end if;

   COMMIT;
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.TRANSFER_EXP_DEALS');
   END IF;

END TRANSFER_EXP_DEALS;



/*------------------------------------------------------------------------
This procedure is used to transfer EXP deals for the open API from
the FORM. There are no business logic validations and no mandatory fields
validations performed.

p_source = TAX (if called from TAX API)
	, FORM (if called from FORM for general purpose)
	, TAX_CP_G (if called from TAX API with interest action Compounded
		gross)
------------------------------------------------------------------------*/
procedure TRANSFER_EXP_DEALS(
			ARec IN OUT NOCOPY XTR_EXPOSURE_TRANSACTIONS%rowtype,
                               p_source           IN  VARCHAR2,
                               user_error         OUT NOCOPY BOOLEAN,
                               mandatory_error    OUT NOCOPY BOOLEAN,
                               validation_error   OUT NOCOPY BOOLEAN,
                               limit_error        OUT NOCOPY BOOLEAN) IS

   CURSOR FIND_USER (p_fnd_user in number) is
     select dealer_code
     from   xtr_dealer_codes_v
     where  user_id = p_fnd_user;

BEGIN
   IF xtr_risk_debug_pkg.g_Debug THEN
      xtr_risk_debug_pkg.dpush('XTR_EXP_TRANSFERS.TRANSFER_EXP_DEALS');
   END IF;

   user_error         := FALSE;
   mandatory_error    := FALSE;
   validation_error   := FALSE;
   limit_error        := FALSE; --no limit for EXPOSURE

   g_source := p_source;
   --Cash Positioning form pass their own created_on
   IF Arec.created_on IS NOT NULL THEN
      g_curr_date := ARec.created_on;
   ELSE
      g_curr_date := SYSDATE;
   END IF;
   g_user_id := FND_GLOBAL.USER_ID;
   g_cparty_account := null;
   --Cash Positioning form pass their own created_by
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('TRANSFER_EXP_DEALS: ' || 'Arec.created_by', Arec.created_by);
END IF;
   IF Arec.created_by IS NOT NULL THEN
      g_user := ARec.created_by;
   ELSE
      OPEN find_user(g_user_id);
      FETCH find_user INTO g_user;
      CLOSE find_user;
   END IF;
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('TRANSFER_EXP_DEALS: ' || 'g_user', g_user);
END IF;

   COPY_TO_EXP(ARec);
   --
   --Insert deal
   --
   CREATE_EXP_DEAL(g_main_rec);
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('TRANSFER_EXP_DEALS: ' || 'After inserting to XTR_EXPOSURE_TRANSACTIONS');
END IF;
   --
   --Also insert to XTR_DEAL_DATE_AMOUNTS_V
   --
   INS_DEAL_DATE_AMOUNTS(g_main_rec);
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('TRANSFER_EXP_DEALS: ' || 'After inserting to XTR_DEAL_DATE_AMOUNTS');
      xtr_risk_debug_pkg.dpop('XTR_EXP_TRANSFERS.TRANSFER_EXP_DEALS');
   END IF;
END TRANSFER_EXP_DEALS;



END;

/
