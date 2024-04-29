--------------------------------------------------------
--  DDL for Package Body XTR_FX_TRANSFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_FX_TRANSFERS_PKG" AS
/* $Header: xtrimfxb.pls 120.5 2005/06/29 09:22:27 badiredd ship $*/

/* Stub for backwards compatability */
/*-------------------------------------------------------------------------------------*/
PROCEDURE TRANSFER_FX_DEALS(ARec_Interface     IN  XTR_DEALS_INTERFACE%ROWTYPE,
                            user_error         OUT NOCOPY BOOLEAN,
                            mandatory_error    OUT NOCOPY BOOLEAN,
                            validation_error   OUT NOCOPY BOOLEAN,
                            limit_error        OUT NOCOPY BOOLEAN) is
/*-------------------------------------------------------------------------------------*/
  v_dummy NUMBER;
BEGIN
  TRANSFER_FX_DEALS(ARec_Interface,user_error,mandatory_error,validation_error,limit_error,v_dummy);
END TRANSFER_FX_DEALS;

/*-------------------------------------------------------------------------------------*/
PROCEDURE TRANSFER_FX_DEALS(ARec_Interface     IN  XTR_DEALS_INTERFACE%ROWTYPE,
                            user_error         OUT NOCOPY BOOLEAN,
                            mandatory_error    OUT NOCOPY BOOLEAN,
                            validation_error   OUT NOCOPY BOOLEAN,
                            limit_error        OUT NOCOPY BOOLEAN,
                            deal_num           OUT NOCOPY NUMBER) is
/*-------------------------------------------------------------------------------------*/

   l_limit_amount     NUMBER;
   v_limit_log_return NUMBER;

  cursor c_deal_no is
  select xtr_deals_s.nextval
  from   dual;

BEGIN

    -------------------------
    --  Initialise Variables
    -------------------------
    limit_error       := FALSE;
    G_User_Id         := fnd_global.user_id;
    g_currency_first  := null;
    g_currency_second := null;
    G_Pricing_Model   := null;
    Select Trunc(sysdate) Into G_Curr_Date From Dual;

   --------------------------------------------------------------------------------------------------------
   --* Perform the following to purge all the related data in the error table before processing the record
   --------------------------------------------------------------------------------------------------------
   delete from xtr_interface_errors
   where  external_deal_id = ARec_Interface.external_deal_id
   and    deal_type        = ARec_Interface.deal_type;

   ----------------------------------------------------------------------------------------------------
   --* The following code checks if user has permissions to transfer the deal (company authorization)
   ----------------------------------------------------------------------------------------------------
   XTR_IMPORT_DEAL_DATA.CHECK_USER_AUTH(ARec_Interface.external_deal_id,
		                        ARec_Interface.deal_type,
		                        ARec_Interface.company_code,
		                        user_error);


   if (user_error <> TRUE) then

         --------------------------------------------------------------------------------
         --* The following code does mandatory field validation specific to the FX deals
         --------------------------------------------------------------------------------
         CHECK_MANDATORY_FIELDS(ARec_Interface, mandatory_error);


         if (mandatory_error <> TRUE) then

            --------------------------------------------------------------------------------------
            --* The following code performs the business logic validation specific to the FX deals
            --------------------------------------------------------------------------------------
            VALIDATE_DEALS(ARec_Interface, validation_error);

            if (validation_error <> TRUE) then

                 ------------------------------------------------------------------
    	         --* Perform limit checks
                 ------------------------------------------------------------------

		 if g_currency_first = G_Fx_Main_Rec.currency_buy then
		    l_limit_amount    := G_Fx_Main_Rec.buy_amount;
		 else
		    l_limit_amount    := G_Fx_Main_Rec.sell_amount;
		 end if;


		 v_limit_log_return := XTR_LIMITS_P.LOG_FULL_LIMITS_CHECK (
		  	                                   G_Fx_Main_Rec.deal_no,
			                                   1,
			                                   G_Fx_Main_Rec.company_code,
			                                   G_Fx_Main_Rec.deal_type,
		  	                                   G_Fx_Main_Rec.deal_subtype,
			                                   G_Fx_Main_Rec.cparty_code,
			                                   G_Fx_Main_Rec.product_type,
			                                   G_Fx_Main_Rec.limit_code,
			                                   G_Fx_Main_Rec.cparty_code,    -- limit_party
			                                   G_Fx_Main_Rec.value_date,    -- amount_date
			                                   l_limit_amount,
			                                   G_Fx_Main_Rec.dealer_code,
			                                   g_currency_first,
			                                   g_currency_second );

	         If Nvl(ARec_Interface.override_limit,'N') = 'N' and v_limit_log_return <> 0 then
		    xtr_import_deal_data.log_interface_errors(ARec_Interface.external_deal_id,ARec_Interface.deal_type,
                                                              'OverrideLimit','XTR_LIMIT_EXCEEDED');
		    limit_error := TRUE;
	         else
	      	    limit_error := FALSE;

	         end if; /* If Limit needs to be checked */

	    end if; /* Validating various fields */

         end if; /* Checking Mandatory values */

   end if;   /* Checking User Auth */

   /*----------------------------------------------------------------------------------------------*/
   /* If the process passed all the previous validation, it would be considered a valid deal entry */
   /*----------------------------------------------------------------------------------------------*/
   if user_error  <> TRUE and mandatory_error  <> TRUE and
      limit_error <> TRUE and validation_error <> TRUE then

      open  c_deal_no;
      fetch c_deal_no into deal_num;
      close c_deal_no;

      XTR_LIMITS_P.UPDATE_LIMIT_EXCESS_LOG(deal_num,
	                                   1,
	                                   Fnd_Global.User_Id,
	                                   v_limit_log_return);

     /*----------------------------------------------------*/
     /* Call the insert procedure to insert into xtr_deals */
     /*----------------------------------------------------*/
      CREATE_FX_DEAL(G_Fx_Main_Rec, deal_num);

     /*---------------------------------------------------------------------------------*/
     /* Since the insert is done, we can now delete the rows from the interface table.  */
     /*---------------------------------------------------------------------------------*/
      delete from xtr_deals_interface
      where external_deal_id = ARec_Interface.external_deal_id
      and   deal_type        = ARec_Interface.deal_type;

   else

      update xtr_deals_interface
      set    load_status_code = 'ERROR',
             last_update_date = G_Curr_Date,
             Last_Updated_by  = g_user_id
      where  external_deal_id = ARec_Interface.external_deal_id
      and    deal_type        = ARec_Interface.deal_type;

   end if;

end TRANSFER_FX_DEALS;


/*------------------------------------------------------------*/
/* The following code implements the CHECK_USER_AUTH process  */
/*------------------------------------------------------------*/
/* Moved to xtrimddb.pls
PROCEDURE CHECK_USER_AUTH(p_external_deal_id IN VARCHAR2,
			  p_deal_type    IN VARCHAR2,
			  p_company_code IN VARCHAR2,
                          error OUT NOCOPY BOOLEAN) is
l_dummy varchar2(1);

BEGIN

      error := FALSE;

   BEGIN
      select 'Y'
      into   l_dummy
      from   xtr_parties_v
      where  party_type = 'C'
      and    party_code = p_company_code
      and    rownum     = 1;


   EXCEPTION
      WHEN NO_DATA_FOUND THEN
      error := TRUE;
      xtr_import_deal_data.log_interface_errors( p_external_deal_id ,p_deal_type,'CompanyCode','XTR_INV_COMP_CODE');
   END;

END CHECK_USER_AUTH;
*/


/*------------------------------------------------------------------------------*/
/*      The following code implements the CHECK_MANDATORY_FIELDS process        */
/*------------------------------------------------------------------------------*/
PROCEDURE CHECK_MANDATORY_FIELDS(ARec_Interface IN  XTR_DEALS_INTERFACE%ROWTYPE,
                                 error 		OUT NOCOPY BOOLEAN) is
/*------------------------------------------------------------------------------*/
  BEGIN

        error := FALSE; /* Defaulting it to No errors */

	if ARec_Interface.dealer_code is null then
		xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'DealerCode','XTR_MANDATORY');
		error := TRUE;
	end if;

	if ARec_Interface.date_a is null then
		xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'DateA','XTR_MANDATORY');
		error := TRUE;
	end if;

	if ARec_Interface.cparty_code is null then
		xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'CpartyCode','XTR_MANDATORY');
		error := TRUE;
	end if;

	if ARec_Interface.deal_subtype is null then
		xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'DealSubtype','XTR_MANDATORY');
		error := TRUE;
	end if;

	if ARec_Interface.product_type is null then
		xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'ProductType','XTR_MANDATORY');
		error := TRUE;
	end if;

	if ARec_Interface.date_b is null then
		xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'DateB','XTR_MANDATORY');
		error := TRUE;
	end if;

	if ARec_Interface.currency_a is null then
		xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'CurrencyA','XTR_MANDATORY');
		error := TRUE;
	end if;

	if ARec_Interface.currency_b is null then
		xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'CurrencyB','XTR_MANDATORY');
		error := TRUE;
	end if;

	if ARec_Interface.amount_a is null then
		xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'AmountA','XTR_MANDATORY');
		error := TRUE;
	end if;

	if ARec_Interface.amount_b is null then
		xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'AmountB','XTR_MANDATORY');
		error := TRUE;
	end if;

	if ARec_Interface.rate_a is null then
		xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'RateA','XTR_MANDATORY');
		error := TRUE;
	end if;

	if ARec_Interface.rate_b is null then
		xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'RateB','XTR_MANDATORY');
		error := TRUE;
	end if;

	if ARec_Interface.account_no_a is null then
		xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'AccountNoA','XTR_MANDATORY');
		error := TRUE;
	end if;

	if ARec_Interface.account_no_b is null then
		xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'AccountNoB','XTR_MANDATORY');
		error := TRUE;
	end if;

	if ARec_Interface.pricing_model is null then
		xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'PricingModel','XTR_MANDATORY');
		error := TRUE;
	end if;

	if  ARec_Interface.brokerage_code is null and
           (ARec_Interface.rate_c is not null or ARec_Interface.amount_c is not null) then
		xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'BrokerageCode','XTR_MANDATORY_BROKERAGE');
		error := TRUE;
	end if;


END CHECK_MANDATORY_FIELDS;



/*------------------------------------------------------------------------*/
/*     The following code implements the VALIDATE_DEALS process           */
/*------------------------------------------------------------------------*/
PROCEDURE VALIDATE_DEALS(ARec_Interface    IN XTR_DEALS_INTERFACE%ROWTYPE,
                         error OUT NOCOPY BOOLEAN) is
/*------------------------------------------------------------------------*/
   rate_error boolean     := FALSE;
   validity_error boolean := FALSE;
BEGIN

   CHECK_VALIDITY(ARec_Interface, validity_error);

   IF validity_error <> TRUE then

   	COPY_FROM_INTERFACE_TO_FX(ARec_Interface);

   	CALC_RATES(ARec_Interface, rate_error);

	if (rate_error <> TRUE) then
	      error := FALSE;
	else
	      error := TRUE;
	end if;
   ELSE
	error := TRUE;
   END IF;

END VALIDATE_DEALS;



/*-------------------------------------------------------------------------*/
PROCEDURE CHECK_VALIDITY(ARec_Interface    IN XTR_DEALS_INTERFACE%ROWTYPE,
                         error OUT NOCOPY BOOLEAN) is
/*-------------------------------------------------------------------------*/

l_error 		number := 0;
l_err_segment 		varchar2(30);
l_err_cparty 		boolean := FALSE;
l_err_deal_subtype 	boolean := FALSE;
l_err_deal_date		boolean := FALSE;
l_err_currency_b	boolean := FALSE;
l_err_currency_a	boolean := FALSE;
l_err_brokerage_code    boolean := FALSE;

 BEGIN

   /* This procedure will include all the column validations */

   	if not ( val_cparty_code(ARec_Interface.company_code, ARec_Interface.cparty_code)) then
		xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						           ARec_Interface.Deal_Type,
						           'CpartyCode',
						           'XTR_INV_CPARTY_CODE');
		l_error := l_error +1;
		l_err_cparty := TRUE;
	end if;

	if l_err_cparty <> TRUE then

 		if not ( val_portfolio_code(ARec_Interface.company_code,
					    ARec_Interface.cparty_code,
					    ARec_Interface.portfolio_code)) then
		     xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						                ARec_Interface.Deal_Type,
						                'PortfolioCode',
						                'XTR_INV_PORT_CODE');
		     l_error := l_error +1;
		end if;

   		if not ( val_limit_code(ARec_Interface.company_code,
				        ARec_Interface.cparty_code,
				        ARec_Interface.limit_code)) then
		     xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						                ARec_Interface.Deal_Type,
						                'LimitCode',
						                'XTR_INV_LIMIT_CODE');
		     l_error := l_error +1;
		end if;
	end if;

      	if not (val_currencies(ARec_Interface.currency_a)) then
		xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						           ARec_Interface.Deal_Type,
						           'CurrencyA',
						           'XTR_INV_BUY_CURR');
		l_error := l_error +1;
		l_err_currency_a := TRUE;
      	end if;

	if not (val_currencies(ARec_Interface.currency_b)) then
		xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
		   			                   ARec_Interface.Deal_Type,
					                   'CurrencyB',
					                   'XTR_INV_SELL_CURR');
		 l_error := l_error +1;
		 l_err_currency_b := TRUE;
	end if;

      	if not ( val_deal_subtype(ARec_Interface.deal_subtype,G_Fx_Deal_Type)) then
	    xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
					               ARec_Interface.Deal_Type,
					               'DealSubtype',
					               'XTR_INV_DEAL_SUBTYPE');
	    l_error := l_error +1;
	    l_err_deal_subtype := TRUE;
	end if;

	if l_err_deal_subtype <> TRUE then
   		if not ( val_product_type(ARec_Interface.product_type,ARec_Interface.deal_subtype,G_Fx_Deal_type)) then
		    xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						               ARec_Interface.Deal_Type,
						               'ProductType',
						               'XTR_INV_PRODUCT_TYPE');
		    l_error := l_error +1;
 		end if;
 	end if;

	if l_err_currency_a <> TRUE and l_err_currency_b <> TRUE then
   		if not (val_buy_sell_curr_comb(ARec_Interface.currency_a, ARec_Interface.currency_b)) then
		    xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						               ARec_Interface.Deal_Type,
						               'CurrencyA',
						               'XTR_INV_BUY_SELL_CURR_COMB');

		    xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						               ARec_Interface.Deal_Type,
						               'CurrencyB',
						               'XTR_INV_BUY_SELL_CURR_COMB');
		    l_error := l_error +1;
		end if;
	end if;

      	if not ( val_brokerage_code(ARec_Interface.brokerage_code)) then
	    xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
					               ARec_Interface.Deal_Type,
					               'BrokerageCode',
					               'XTR_INV_BROKERAGE_CODE');
	    l_error := l_error +1;
            l_err_brokerage_code := TRUE;
	end if;

	if l_err_currency_a <> TRUE then
        	if not ( val_comp_acct_no(ARec_Interface.company_code,
					  ARec_Interface.currency_a,
					  ARec_Interface.account_no_a)) then
		    xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						               ARec_Interface.Deal_Type,
						               'AccountNoA',
						               'XTR_INV_BUY_ACCT_NO');
		    l_error := l_error +1;
      		end if;
      	end if;

	if l_err_currency_b <> TRUE then
   		if not ( val_comp_acct_no(ARec_Interface.company_code,
				   	  ARec_Interface.currency_b,
				     	  ARec_Interface.account_no_b)) then
		    xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						               ARec_Interface.Deal_Type,
						               'AccountNoB',
						               'XTR_INV_SELL_ACCT_NO');
		    l_error := l_error +1;
		end if;
	end if;

	if l_err_cparty <> TRUE and l_err_currency_b <> TRUE then
   		if not ( val_cparty_ref(ARec_Interface.cparty_account_no,
		   		        ARec_Interface.cparty_ref,
		   		        ARec_Interface.cparty_code,
				        ARec_Interface.currency_b)) then
		    xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						               ARec_Interface.Deal_Type,
						               'CpartyAccountNo',  -- CE BANK MIGRATION
						               'XTR_INV_CPARTY_REF');
		l_error := l_error +1;
		end if;
	end if;

     	if not ( val_dealer_code(ARec_Interface.dealer_code)) then
		xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						           ARec_Interface.Deal_Type,
						           'DealerCode',
						           'XTR_INV_DEALER_CODE');
		l_error := l_error +1;
	end if;

     	if ARec_Interface.dual_authorization_by is not null and
           not ( val_dealer_code(ARec_Interface.dual_authorization_by)) then
		xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						           ARec_Interface.Deal_Type,
						           'DualAuthorizationBy',
						           'XTR_INV_DUAL_AUTH_BY');
		l_error := l_error +1;
	end if;

     	if not ( val_deal_date(ARec_Interface.date_a)) then
		xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						           ARec_Interface.Deal_Type,
						           'DateA',
						           'XTR_INV_DEAL_DATE');
		l_error := l_error +1;
		l_err_deal_date := TRUE;
	end if;

     	if not ( val_client_code(ARec_Interface.client_code)) then
		xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						           ARec_Interface.Deal_Type,
						           'ClientCode',
						           'XTR_INV_CLIENT_CODE');
		l_error := l_error +1;
	end if;

	if l_err_deal_date <> TRUE then
     		if not ( val_value_date(ARec_Interface.date_a,
					ARec_Interface.date_b)) then
		    xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						               ARec_Interface.Deal_Type,
						               'DateB',
						               'XTR_INV_VALUE_DATE');
		    l_error := l_error +1;
		end if;
	end if;

     	if not ( val_deal_linking_code(ARec_Interface.deal_linking_code)) then
		xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						           ARec_Interface.Deal_Type,
						           'DealLinkingCode',
						           'XTR_INV_LINKING_CODE');
		l_error := l_error +1;
	end if;


     	if not ( val_pricing_model(ARec_Interface.pricing_model)) then
		xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						           ARec_Interface.Deal_Type,
						           'PricingModel',
						           'XTR_INV_PRICING_MODEL');
		l_error := l_error +1;
	end if;

     	if not ( val_market_data_set(ARec_Interface.market_data_set)) then
		xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						           ARec_Interface.Deal_Type,
						           'MarketDataSet',
						           'XTR_INV_MKT_DATA_SET');
		l_error := l_error +1;
	end if;

        if l_err_brokerage_code <> TRUE and l_err_currency_a <> TRUE and l_err_currency_b <> TRUE then

     	   if not ( val_brokerage_currency(ARec_Interface.brokerage_currency,
					   G_Fx_Deal_Type,
					   ARec_Interface.currency_a,
					   ARec_Interface.currency_b,
					   ARec_Interface.brokerage_code)) then
		xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						           ARec_Interface.Deal_Type,
						           'BrokerageCurrency',
						           'XTR_INV_BROK_CURRENCY');
		l_error := l_error +1;
	   end if;
	end if;


        /*-------------------------------------------------------------------------------*/
        /*       Flexfields Validation                                                   */
        /*-------------------------------------------------------------------------------*/

        if not ( xtr_import_deal_data.val_desc_flex(ARec_Interface,'XTR_DEALS_DESC_FLEX',l_err_segment)) then
           l_error := l_error +1;
           if l_err_segment is not null and l_err_segment = 'Attribute16' then
		xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						           ARec_Interface.Deal_Type,
						           l_err_segment,
						           'XTR_INV_DESC_FLEX_API');
           elsif l_err_segment is not null and l_err_segment = 'AttributeCategory' then
		xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						           ARec_Interface.Deal_Type,
						           l_err_segment,
						           'XTR_INV_DESC_FLEX_CONTEXT');
           else
		xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						           ARec_Interface.Deal_Type,
						           l_err_segment,
						           'XTR_INV_DESC_FLEX');
           end if;
	end if;

        --rvallams begin


     	if (ARec_Interface.rate_a <= 0) then
		xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						           ARec_Interface.Deal_Type,
						           'RateA',
						           'XTR_2180');
		l_error := l_error +1;
	end if;

     	if (ARec_Interface.rate_b <= 0) then
		xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
						           ARec_Interface.Deal_Type,
						           'RateB',
						           'XTR_2180');
		l_error := l_error +1;
	end if;

        --rvallams end

	if l_error > 0 then
	   error := TRUE;
	else
	   error := FALSE;
	end if;

END CHECK_VALIDITY;

/*--------------------------------------------------------------------*/
FUNCTION val_deal_date (p_date_a        IN date) return BOOLEAN is
/*--------------------------------------------------------------------*/
l_date date;
BEGIN

	IF ( p_date_a > g_curr_date ) THEN
		return(FALSE);
	END IF;
	return TRUE;
END val_deal_date;

/*--------------------------------------------------------------------*/
FUNCTION val_value_date (p_date_a	IN date,
			p_date_b        IN date) return BOOLEAN is
/*--------------------------------------------------------------------*/
BEGIN

	IF ( p_date_a > p_date_b ) THEN
		return(FALSE);
	END IF;
	return TRUE;
END val_value_date;

/*--------------------------------------------------------------------*/
FUNCTION val_client_code(p_client_code 	IN varchar2) return BOOLEAN is
/*--------------------------------------------------------------------*/
l_temp varchar2(1);
BEGIN
	IF p_client_code is not null then
	    BEGIN
		select 'Y'
		into l_temp
		from xtr_parties_v
		where party_type = 'CP'
		and party_category = 'CL'
		and party_code = p_client_code
		and rownum = 1;
	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		return(FALSE);
	    END;
	END IF;
	return TRUE;
END val_client_code;

/*----------------------------------------------------------------------------*/
FUNCTION val_portfolio_code(p_company_code   IN varchar2,
			    p_cparty_code    IN varchar2,
			    p_portfolio_code IN varchar2) return BOOLEAN is
/*----------------------------------------------------------------------------*/
l_temp varchar2(1);
BEGIN
	BEGIN
	   select 'Y'
	   into l_temp
	   from xtr_portfolios_v
	   where company_code = p_company_code
	   and (external_party is null or external_party = p_cparty_code)
	   and portfolio = p_portfolio_code
	   and rownum = 1;
	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	   return(FALSE);
	END;

	return TRUE;

END val_portfolio_code;

/*----------------------------------------------------------------------------*/
FUNCTION val_limit_code(    p_company_code 	IN varchar2,
			     p_cparty_code	IN varchar2,
			     p_limit_code	IN varchar2) return BOOLEAN is
/*----------------------------------------------------------------------------*/
l_temp varchar2(1);
BEGIN
	IF p_limit_code is not null then
	    BEGIN
		select 'Y'
		into l_temp
		from xtr_counterparty_limits_v a, xtr_limit_types_v b
		where a.company_code = p_company_code
		and a.cparty_code = p_cparty_code
		and a.limit_code <> 'SETTLE'
		and a.limit_code = p_limit_code
		and a.limit_type = b.limit_type
		and b.fx_invest_fund_type='X'
		and nvl(a.authorised,'N') = 'Y'
		and nvl(a.expiry_date,sysdate+1) > sysdate
		and rownum = 1;
	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		return(FALSE);
	    END;
	END IF;
	return TRUE;
END val_limit_code;

/*----------------------------------------------------------------------------*/
FUNCTION val_currencies ( p_currency	IN varchar2) return BOOLEAN is
/*----------------------------------------------------------------------------*/
l_temp varchar2(1);
BEGIN
	BEGIN
		Select 'Y'
		Into l_temp
		from   xtr_master_currencies_v
		where  nvl(authorised,'N') = 'Y'
		And    currency = p_currency
		and    rownum = 1;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		return(FALSE);
	END;
	return TRUE;
END val_currencies;

/*----------------------------------------------------------------------------*/
FUNCTION val_buy_sell_curr_comb ( p_buy_currency	IN varchar2,
			          p_sell_currency	IN varchar2) return BOOLEAN is
/*----------------------------------------------------------------------------*/
l_temp varchar2(1);
BEGIN
	BEGIN
		select currency_first, currency_second
 	 	into   g_currency_first, g_currency_second
		from   xtr_buy_sell_combinations_v
		where  nvl(authorised,'N') = 'Y'
		and    currency_buy = p_buy_currency
		and    currency_sell = p_sell_currency
		and    rownum = 1;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		return(FALSE);
	END;
	return TRUE;
END val_buy_sell_curr_comb;

/*----------------------------------------------------------------------------*/
FUNCTION val_comp_acct_no(p_company_code 	IN varchar2,
			  p_currency		IN varchar2,
			  p_account_no		IN varchar2) return BOOLEAN is
/*----------------------------------------------------------------------------*/
l_temp varchar2(1);
BEGIN
	BEGIN
		select 'Y'
		into l_temp
		from xtr_company_acct_lov_v
		where company_code = p_company_code
		and currency = p_currency
		and account_number = p_account_no
		and rownum = 1;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		return(FALSE);
	END;
	return TRUE;
END val_comp_acct_no;


/*----------------------------------------------------------------------------*/
FUNCTION val_cparty_ref(    p_cparty_account_no IN varchar2,
			     p_cparty_ref 	IN varchar2,
			     p_cparty_code	IN varchar2,
			     p_currency_b	IN varchar2) return BOOLEAN is
/*----------------------------------------------------------------------------*/
l_temp varchar2(1);
BEGIN
	IF (p_cparty_ref is null and p_cparty_account_no is null) then
		return TRUE;
	END IF;

	    BEGIN
		select 'Y'
		into l_temp
		from xtr_bank_accounts_v
		where bank_short_code = p_cparty_ref
		and   party_code = p_cparty_code
		and   account_number = p_cparty_account_no
		and   nvl(authorised,'N') = 'Y'
		and   currency = p_currency_b
		and   rownum = 1;
	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		return(FALSE);
	    END;

	return TRUE;
END val_cparty_ref;


/*--------------------------------------------------------------------------------*/
FUNCTION val_deal_linking_code( p_deal_linking_code IN varchar2) return BOOLEAN is
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
END val_deal_linking_code;

/*--------------------------------------------------------------------------------*/
FUNCTION val_brokerage_code ( p_brokerage_code	IN varchar2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_temp varchar2(1);
BEGIN
	IF p_brokerage_code is not null then
	    BEGIN
		select 'Y'
		into   l_temp
		from   xtr_tax_brokerage_setup_v a, xtr_deduction_calcs_v b
		where  a.reference_code = p_brokerage_code
		and    a.deal_type      = G_Fx_Deal_Type
		and    a.deduction_type = 'B'
		and    a.deal_type      = b.deal_type
		and    a.calc_type      = b.calc_type
		and    nvl(a.authorised,'N') = 'Y'
		and    rownum = 1;
	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		return(FALSE);
	    END;
	END IF;
	return TRUE;
END val_brokerage_code;


/*--------------------------------------------------------------------------------*/
FUNCTION val_dealer_code(p_dealer_code        IN VARCHAR2) return BOOLEAN is
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
END val_dealer_code;

/*--------------------------------------------------------------------------------*/
FUNCTION val_cparty_code(p_company_code       IN VARCHAR2,
			   p_cparty_code	IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_temp varchar2(1);
BEGIN
	BEGIN
		select 'Y'
		into l_temp
		from xtr_party_info_v
		where ((party_type = 'CP' and fx_cparty='Y')
			or party_type = 'C')
		and party_code = p_cparty_code
		and party_code <> p_company_code
		and nvl(authorised,'N') = 'Y'
		and rownum = 1;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		return(FALSE);
	END;
	return(TRUE);
END val_cparty_code;


/*--------------------------------------------------------------------------------*/
FUNCTION val_deal_subtype(p_deal_subtype IN VARCHAR2,
			  p_deal_type	 IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_temp varchar2(1);
BEGIN
        ------------------------------------------------------------------------------------------------------
        --* Note : Deal_subtype column in the view is actually referring to the user_deal_subtype of the table.
        ------------------------------------------------------------------------------------------------------
	BEGIN
		select 'Y'
		into   l_temp
		from   xtr_auth_deal_subtypes_v
		where  deal_type    = p_deal_type
		and    deal_subtype = p_deal_subtype
		and    rownum       = 1;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		return(FALSE);
	END;
	return(TRUE);
END val_deal_subtype;

/*--------------------------------------------------------------------------------*/
FUNCTION val_product_type(p_product_type   IN VARCHAR2,
			  p_deal_subtype   IN VARCHAR2,
			  p_deal_type	   IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
   l_temp varchar2(1);
   l_deal_subtype varchar2(10);
BEGIN
	BEGIN
		select deal_subtype
		into   l_deal_subtype
		from   xtr_deal_subtypes
		where  deal_type 	    = p_deal_type
		and    user_deal_subtype    = p_deal_subtype
                and    nvl(authorised,'N')  = 'Y'
                and    rownum = 1;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		return(FALSE);
	END;

	BEGIN
		select 'Y'
		into  l_temp
		from  xtr_auth_product_types_v
		where product_type = p_product_type
		and   deal_type    = p_deal_type
		and   deal_subtype = l_deal_subtype
		and   rownum = 1;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		return(FALSE);
	END;
	return(TRUE);

END val_product_type;


/*--------------------------------------------------------------------------------*/
FUNCTION val_pricing_model(p_pricing_model        IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
   cursor cur_pricing is
   select code
   from   xtr_price_models
   where  code        = p_pricing_model
   and    deal_type   = 'FX'
   and    nvl(authorized,'N') = 'Y';

BEGIN
   open cur_pricing;
   fetch cur_pricing into G_Pricing_model;
   if cur_pricing%NOTFOUND then
      close cur_pricing;
      return(FALSE);
   end if;
   close cur_pricing;
   return(TRUE);

END val_pricing_model;

/*--------------------------------------------------------------------------------*/
FUNCTION val_market_data_set(p_market_data_set        IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_temp varchar2(1);


BEGIN
	IF p_market_data_set is not null then
	  BEGIN
		select 'Y'
		into l_temp
		from xtr_rm_md_sets
		where set_code = p_market_data_set
		and nvl(authorized_yn,'N') = 'Y'
		and rownum = 1;
	  EXCEPTION
		WHEN NO_DATA_FOUND THEN
		return(FALSE);
	  END;
	END IF;
	return(TRUE);
END val_market_data_set;

/*--------------------------------------------------------------------------------*/
FUNCTION val_brokerage_currency(p_brokerage_currency  IN VARCHAR2,
				p_deal_type	      IN VARCHAR2,
				p_currency_a	      IN VARCHAR2,
				p_currency_b	      IN VARCHAR2,
				p_brokerage_code      IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_temp varchar2(1);
l_amount_type varchar2(10);
BEGIN
	IF p_brokerage_currency is not null and p_brokerage_code is not null then
	  	BEGIN
			select 	d.amount_type
			into   	l_amount_type
			from  	xtr_tax_brokerage_setup a,
		      		xtr_deduction_calcs_v d
			where  	a.deal_type          = p_deal_type
			and   	a.reference_code     = p_brokerage_code
			and   	nvl(a.authorised,'N')= 'Y'
			and   	d.deal_type          = a.deal_type
			and   	d.calc_type          = a.calc_type
			and 	rownum =1;
	  	EXCEPTION
			WHEN NO_DATA_FOUND THEN
			return(FALSE);
	  	END;

		IF (l_amount_type = 'BUY' and p_brokerage_currency <> p_currency_a ) then
		   return(FALSE);
	 	ELSIF (l_amount_type = 'SELL' and p_brokerage_currency <> p_currency_b ) then
		   return(FALSE);
		END IF;
	END IF;
	return(TRUE);
END val_brokerage_currency;

/*--------------------------------------------------------------------------------*/
--FUNCTION val_desc_flex( p_Interface_Rec   IN XTR_DEALS_INTERFACE%ROWTYPE,
--                        p_error_segment   IN OUT NOCOPY VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
/*
l_segment number(3);
BEGIN


     fnd_flex_descval.set_column_value('ATTRIBUTE1',p_Interface_Rec.ATTRIBUTE1);
     fnd_flex_descval.set_column_value('ATTRIBUTE2',p_Interface_Rec.ATTRIBUTE2);
     fnd_flex_descval.set_column_value('ATTRIBUTE3',p_Interface_Rec.ATTRIBUTE3);
     fnd_flex_descval.set_column_value('ATTRIBUTE4',p_Interface_Rec.ATTRIBUTE4);
     fnd_flex_descval.set_column_value('ATTRIBUTE5',p_Interface_Rec.ATTRIBUTE5);
     fnd_flex_descval.set_column_value('ATTRIBUTE6',p_Interface_Rec.ATTRIBUTE6);
     fnd_flex_descval.set_column_value('ATTRIBUTE7',p_Interface_Rec.ATTRIBUTE7);
     fnd_flex_descval.set_column_value('ATTRIBUTE8',p_Interface_Rec.ATTRIBUTE8);
     fnd_flex_descval.set_column_value('ATTRIBUTE9',p_Interface_Rec.ATTRIBUTE9);
     fnd_flex_descval.set_column_value('ATTRIBUTE10',p_Interface_Rec.ATTRIBUTE10);
     fnd_flex_descval.set_column_value('ATTRIBUTE11',p_Interface_Rec.ATTRIBUTE11);
     fnd_flex_descval.set_column_value('ATTRIBUTE12',p_Interface_Rec.ATTRIBUTE12);
     fnd_flex_descval.set_column_value('ATTRIBUTE13',p_Interface_Rec.ATTRIBUTE13);
     fnd_flex_descval.set_column_value('ATTRIBUTE14',p_Interface_Rec.ATTRIBUTE14);
     fnd_flex_descval.set_column_value('ATTRIBUTE15',p_Interface_Rec.ATTRIBUTE15);

     fnd_flex_descval.set_context_value(p_Interface_Rec.ATTRIBUTE_CATEGORY);

   IF fnd_flex_descval.validate_desccols('XTR','XTR_DEALS_DESC_FLEX') then
       if (fnd_flex_descval.is_valid) then
	   null;
       else
          --RV    l_segment := to_char(fnd_flex_descval.error_segment) ;
          --RV    p_error_segment := 'Attribute'||l_segment;
	   return(FALSE);
       end if;

       if (fnd_flex_descval.value_error OR
            fnd_flex_descval.unsupported_error) then
          --RV    l_segment := to_char(fnd_flex_descval.error_segment) ;
	  --RV    p_error_segment := 'Attribute'||l_segment;
	   return(FALSE);
       end if;

       return(TRUE);

    ELSE
        l_segment := to_char(fnd_flex_descval.error_segment) ;
        -- RV
        --if l_segment Is Not Null Then
        --   p_error_segment := 'Attribute'||l_segment;
        --else
        --   p_error_segment := 'AttributeCategory';
        --end If;
        --/

	If l_segment Is Null Then
     		p_error_segment := 'AttributeCategory';
 	End If;

        return(FALSE);
    END IF;


END val_desc_flex;
*/

/*------------------------------------------------------------------------------------------*/
PROCEDURE copy_from_interface_to_fx(ARec_Interface IN xtr_deals_interface%rowtype ) is
/*------------------------------------------------------------------------------------------*/
l_deal_subtype	varchar2(10);
BEGIN

	G_Fx_Main_Rec.EXTERNAL_DEAL_ID		:= NULL;
	G_Fx_Main_Rec.DEAL_TYPE			:= NULL;
	G_Fx_Main_Rec.DEALER_CODE		:= NULL;
	G_Fx_Main_Rec.COMPANY_CODE		:= NULL;
	G_Fx_Main_Rec.CPARTY_CODE		:= NULL;
	G_Fx_Main_Rec.CLIENT_CODE		:= NULL;
	G_Fx_Main_Rec.PORTFOLIO_CODE		:= NULL;
	G_Fx_Main_Rec.LIMIT_CODE		:= NULL;
	G_Fx_Main_Rec.DEAL_SUBTYPE		:= NULL;
	G_Fx_Main_Rec.PRODUCT_TYPE		:= NULL;
	G_Fx_Main_Rec.DEAL_DATE			:= NULL;
	G_Fx_Main_Rec.VALUE_DATE		:= NULL;
	G_Fx_Main_Rec.CURRENCY_BUY		:= NULL;
	G_Fx_Main_Rec.CURRENCY_SELL		:= NULL;
	G_Fx_Main_Rec.BUY_AMOUNT		:= NULL;
	G_Fx_Main_Rec.SELL_AMOUNT		:= NULL;
	G_Fx_Main_Rec.BUY_ACCOUNT_NO		:= NULL;
	G_Fx_Main_Rec.SELL_ACCOUNT_NO		:= NULL;
	G_Fx_Main_Rec.BASE_RATE			:= NULL;
	G_Fx_Main_Rec.TRANSACTION_RATE		:= NULL;
	G_Fx_Main_Rec.COMMENTS			:= NULL;
	G_Fx_Main_Rec.EXTERNAL_COMMENTS		:= NULL;
	G_Fx_Main_Rec.INTERNAL_TICKET_NO	:= NULL;
	G_Fx_Main_Rec.EXTERNAL_CPARTY_NO	:= NULL;
	G_Fx_Main_Rec.CPARTY_ACCOUNT_NO         := NULL;
	G_Fx_Main_Rec.CPARTY_REF	        := NULL;
	G_Fx_Main_Rec.MARKET_DATA_SET	        := NULL;
	G_Fx_Main_Rec.DEAL_LINKING_CODE        	:= NULL;
	G_Fx_Main_Rec.BROKERAGE_CODE        	:= NULL;
	G_Fx_Main_Rec.BROKERAGE_RATE	        := NULL;
	G_Fx_Main_Rec.BROKERAGE_AMOUNT	        := NULL;
	G_Fx_Main_Rec.BROKERAGE_CURRENCY	:= NULL;
	G_Fx_Main_Rec.PRICING_MODEL	        := NULL;
	G_Fx_Main_Rec.BUY_HCE_AMOUNT            := NULL;
	G_Fx_Main_Rec.SELL_HCE_AMOUNT           := NULL;
	G_Fx_Main_Rec.FORWARD_HCE_AMOUNT        := NULL;
	G_Fx_Main_Rec.PORTFOLIO_AMOUNT          := NULL;
	G_Fx_Main_Rec.DUAL_AUTHORISATION_BY	:= NULL;
	G_Fx_Main_Rec.DUAL_AUTHORISATION_ON	:= to_date(NULL);
	G_Fx_Main_Rec.STATUS_CODE	        := NULL;
	G_Fx_Main_Rec.ATTRIBUTE_CATEGORY	:= NULL;
	G_Fx_Main_Rec.ATTRIBUTE1	        := NULL;
	G_Fx_Main_Rec.ATTRIBUTE2	        := NULL;
	G_Fx_Main_Rec.ATTRIBUTE3	        := NULL;
	G_Fx_Main_Rec.ATTRIBUTE4	        := NULL;
	G_Fx_Main_Rec.ATTRIBUTE5	        := NULL;
	G_Fx_Main_Rec.ATTRIBUTE6	        := NULL;
	G_Fx_Main_Rec.ATTRIBUTE7	        := NULL;
	G_Fx_Main_Rec.ATTRIBUTE8	        := NULL;
	G_Fx_Main_Rec.ATTRIBUTE9	        := NULL;
	G_Fx_Main_Rec.ATTRIBUTE10	        := NULL;
	G_Fx_Main_Rec.ATTRIBUTE11	        := NULL;
	G_Fx_Main_Rec.ATTRIBUTE12	        := NULL;
	G_Fx_Main_Rec.ATTRIBUTE13	        := NULL;
	G_Fx_Main_Rec.ATTRIBUTE14	        := NULL;
	G_Fx_Main_Rec.ATTRIBUTE15	        := NULL;


       /*--------------------------------------------*/
       /* Find the actual deal subtype               */
       /*--------------------------------------------*/
	SELECT deal_subtype
	INTO   l_deal_subtype
	FROM   xtr_deal_subtypes
	WHERE  deal_type 	 = G_Fx_Deal_Type
	AND    user_deal_subtype = ARec_Interface.DEAL_SUBTYPE
        AND    rownum = 1;

       /*--------------------------------------------*/
       /* Copying values into the Global Record Type */
       /*--------------------------------------------*/
	G_Fx_Main_Rec.EXTERNAL_DEAL_ID	    := 	ARec_Interface.EXTERNAL_DEAL_ID	;
	G_Fx_Main_Rec.DEAL_TYPE		    := 	G_Fx_Deal_Type			;
	G_Fx_Main_Rec.DEALER_CODE	    := 	ARec_Interface.DEALER_CODE	;
	G_Fx_Main_Rec.COMPANY_CODE	    := 	ARec_Interface.COMPANY_CODE	;
	G_Fx_Main_Rec.CPARTY_CODE	    := 	ARec_Interface.CPARTY_CODE	;
	G_Fx_Main_Rec.CLIENT_CODE	    := 	ARec_Interface.CLIENT_CODE	;
	G_Fx_Main_Rec.PORTFOLIO_CODE	    := 	ARec_Interface.PORTFOLIO_CODE	;
	G_Fx_Main_Rec.LIMIT_CODE	    := 	ARec_Interface.LIMIT_CODE	;
	G_Fx_Main_Rec.DEAL_SUBTYPE	    := 	l_deal_subtype			;
	G_Fx_Main_Rec.PRODUCT_TYPE	    := 	ARec_Interface.PRODUCT_TYPE	;
	G_Fx_Main_Rec.DEAL_DATE		    := 	ARec_Interface.DATE_A		;
	G_Fx_Main_Rec.VALUE_DATE	    := 	ARec_Interface.DATE_B		;
	G_Fx_Main_Rec.CURRENCY_BUY	    := 	ARec_Interface.CURRENCY_A	;
	G_Fx_Main_Rec.CURRENCY_SELL	    := 	ARec_Interface.CURRENCY_B	;
	G_Fx_Main_Rec.NO_OF_DAYS	    :=	G_Fx_Main_Rec.VALUE_DATE - G_Fx_Main_Rec.DEAL_DATE;
	G_Fx_Main_Rec.BUY_AMOUNT	    := 	ARec_Interface.AMOUNT_A		;
	G_Fx_Main_Rec.SELL_AMOUNT	    := 	ARec_Interface.AMOUNT_B		;
	G_Fx_Main_Rec.BUY_ACCOUNT_NO	    := 	ARec_Interface.ACCOUNT_NO_A	;
	G_Fx_Main_Rec.SELL_ACCOUNT_NO	    := 	ARec_Interface.ACCOUNT_NO_B	;
	G_Fx_Main_Rec.BASE_RATE		    := 	ARec_Interface.RATE_A		;
	G_Fx_Main_Rec.TRANSACTION_RATE	    := 	ARec_Interface.RATE_B		;
	G_Fx_Main_Rec.COMMENTS		    := 	ARec_Interface.COMMENTS		;
	G_Fx_Main_Rec.EXTERNAL_COMMENTS	    := 	ARec_Interface.EXTERNAL_COMMENTS ;
	G_Fx_Main_Rec.INTERNAL_TICKET_NO    := 	ARec_Interface.INTERNAL_TICKET_NO;
	G_Fx_Main_Rec.EXTERNAL_CPARTY_NO    := 	ARec_Interface.EXTERNAL_CPARTY_NO;
	G_Fx_Main_Rec.CPARTY_ACCOUNT_NO     :=  ARec_Interface.CPARTY_ACCOUNT_NO;
	G_Fx_Main_Rec.CPARTY_REF	    := 	NULL                    	; --bug 304164
	G_Fx_Main_Rec.PRICING_MODEL	    := 	G_Pricing_Model                 ;
	G_Fx_Main_Rec.MARKET_DATA_SET	    := 	ARec_Interface.MARKET_DATA_SET  ;
	G_Fx_Main_Rec.DEAL_LINKING_CODE	    := 	ARec_Interface.DEAL_LINKING_CODE;
        if ARec_Interface.BROKERAGE_CODE is not null then
	   G_Fx_Main_Rec.BROKERAGE_CODE	    := 	ARec_Interface.BROKERAGE_CODE	;
	   G_Fx_Main_Rec.BROKERAGE_RATE	    := 	ARec_Interface.RATE_C		;
	   G_FX_Main_Rec.BROKERAGE_AMOUNT   := 	ARec_Interface.AMOUNT_C		;
	   G_Fx_Main_Rec.BROKERAGE_CURRENCY := 	ARec_Interface.BROKERAGE_CURRENCY;
        else
	   G_Fx_Main_Rec.BROKERAGE_CODE	    := 	null;
	   G_Fx_Main_Rec.BROKERAGE_RATE	    := 	null;
	   G_FX_Main_Rec.BROKERAGE_AMOUNT   := 	null;
	   G_Fx_Main_Rec.BROKERAGE_CURRENCY := 	null;
        end if;
	G_Fx_Main_Rec.DUAL_AUTHORISATION_BY := 	ARec_Interface.DUAL_AUTHORIZATION_BY;
	G_Fx_Main_Rec.DUAL_AUTHORISATION_ON := 	ARec_Interface.DUAL_AUTHORIZATION_ON;
	G_Fx_Main_Rec.STATUS_CODE	    := 	'CURRENT';

        /*--------------------------------------------------------------------*/
        /*                Flexfields will be implemented in Patchset G.       */
        /*--------------------------------------------------------------------*/
	G_Fx_Main_Rec.ATTRIBUTE_CATEGORY    := 	ARec_Interface.ATTRIBUTE_CATEGORY;
	G_Fx_Main_Rec.ATTRIBUTE1	    := 	ARec_Interface.ATTRIBUTE1	;
	G_Fx_Main_Rec.ATTRIBUTE2	    := 	ARec_Interface.ATTRIBUTE2	;
	G_Fx_Main_Rec.ATTRIBUTE3	    := 	ARec_Interface.ATTRIBUTE3	;
	G_Fx_Main_Rec.ATTRIBUTE4	    := 	ARec_Interface.ATTRIBUTE4	;
	G_Fx_Main_Rec.ATTRIBUTE5	    := 	ARec_Interface.ATTRIBUTE5	;
	G_Fx_Main_Rec.ATTRIBUTE6	    := 	ARec_Interface.ATTRIBUTE6	;
	G_Fx_Main_Rec.ATTRIBUTE7	    := 	ARec_Interface.ATTRIBUTE7	;
	G_Fx_Main_Rec.ATTRIBUTE8	    := 	ARec_Interface.ATTRIBUTE8	;
	G_Fx_Main_Rec.ATTRIBUTE9	    := 	ARec_Interface.ATTRIBUTE9	;
	G_Fx_Main_Rec.ATTRIBUTE10	    := 	ARec_Interface.ATTRIBUTE10	;
	G_Fx_Main_Rec.ATTRIBUTE11  	    := 	ARec_Interface.ATTRIBUTE11	;
	G_Fx_Main_Rec.ATTRIBUTE12	    := 	ARec_Interface.ATTRIBUTE12	;
	G_Fx_Main_Rec.ATTRIBUTE13	    := 	ARec_Interface.ATTRIBUTE13	;
	G_Fx_Main_Rec.ATTRIBUTE14	    := 	ARec_Interface.ATTRIBUTE14	;
	G_Fx_Main_Rec.ATTRIBUTE15	    := 	ARec_Interface.ATTRIBUTE15	;

END copy_from_interface_to_fx;

/*------------------------------------------------------------*/
/*   The following code implements the calc_rates process     */
/*------------------------------------------------------------*/
PROCEDURE CALC_RATES(ARec_Interface    IN XTR_DEALS_INTERFACE%ROWTYPE,
                     error OUT NOCOPY boolean) is

l_bkr_amt_type		varchar2(30);
l_dummy_char		varchar2(30);

--rvallams
roundfac number(3,2);

cursor rnd(p_curr in VARCHAR2) is
  select m.rounding_factor
   from xtr_master_currencies_v m
   where m.currency = p_curr;


begin

   error := FALSE;

   /*--------------------------------------------------------------------------------------------*/
   /* This process checks the values of the three columns to make sure that they are all in sync */
   /*--------------------------------------------------------------------------------------------*/
   VALIDATE_BUY_SELL_AMOUNT(ARec_Interface.deal_type, error);


--rvallams bug 2383157 begin

   /*--------------------------------------------------------------------------------------------*/
   /* Store the amounts rounded as per the precision of the currency                             */
   /*--------------------------------------------------------------------------------------------*/
   if error <> TRUE then

      open rnd(G_Fx_Main_Rec.currency_buy);
      fetch rnd into roundfac;
      close rnd;
      G_Fx_Main_Rec.buy_amount := round(G_Fx_Main_Rec.buy_amount,roundfac);

      open rnd(G_Fx_Main_Rec.currency_sell);
      fetch rnd into roundfac;
      close rnd;
      G_Fx_Main_Rec.sell_amount := round(G_Fx_Main_Rec.sell_amount,roundfac);

   end if;

--rvallams bug 2383157 end


   /*--------------------------------------------------------------------------------------------*/
   /* This process checks brokerage values.                                                      */
   /*--------------------------------------------------------------------------------------------*/
   if error <> TRUE then
      xtr_fps2_p.tax_brokerage_amt_type(G_FX_Deal_Type,
                                        ARec_Interface.brokerage_code,
                                        null,
                                        l_bkr_amt_type,
                                        l_dummy_char);
      if  G_Fx_Main_Rec.deal_date       is not null and
          G_Fx_Main_Rec.buy_amount      is not null and
          G_Fx_Main_Rec.sell_amount     is not null and
          ARec_Interface.brokerage_code is not null then
          if ARec_Interface.amount_c is null then
             CALC_BROKERAGE_AMT(ARec_Interface.deal_type, l_bkr_amt_type, error);
          end if;

          if G_Fx_Main_Rec.brokerage_amount is not null and G_Fx_Main_Rec.brokerage_currency is null then
             if l_bkr_amt_type = 'BUY' then
                G_Fx_Main_Rec.brokerage_currency := ARec_Interface.currency_a;
             else
                G_Fx_Main_Rec.brokerage_currency := ARec_Interface.currency_b;
             end if;
          end if;

      end if;
   end if;

   if error <> TRUE then
      CALC_HCE_AMOUNTS(ARec_Interface.deal_type, error);
   end if;


end CALC_RATES;


/*--------------------------------------------------------------------------------*/
PROCEDURE CALC_HCE_AMOUNTS (p_user_deal_type IN VARCHAR2, p_error OUT NOCOPY BOOLEAN) is
/*--------------------------------------------------------------------------------*/

 home_currency       varchar2(15);
 roundfac            number;
 bid_rate            number;
 forward_hce_first   number;
 forward_hce_second  number;
 limit_weighting     number;
 dummy_char          varchar2(20);
 dummy_num           number;

 cursor rnd_fac is
  select p.home_currency,
         m.rounding_factor
   from  xtr_parties_v p,
         xtr_master_currencies_v m
   where p.party_code = G_Fx_Main_Rec.company_code
   and   p.party_type = 'C'
   and   m.currency   = p.home_currency;

 cursor hc_rate is
  select round((G_Fx_Main_Rec.buy_amount/ s.hce_rate ),roundfac)
  from  xtr_master_currencies_v s
  where s.currency   = G_Fx_Main_Rec.currency_buy;

 cursor calc_hce is
  select round(((G_Fx_Main_Rec.buy_amount / G_Fx_Main_Rec.base_rate -
                 G_Fx_Main_Rec.sell_amount )/ s.hce_rate),roundfac),
                  round(((G_Fx_Main_Rec.buy_amount * G_Fx_Main_Rec.base_rate -
                    G_Fx_Main_Rec.sell_amount )/ s.hce_rate),roundfac)
   from  xtr_master_currencies_v s
   where s.currency   = G_Fx_Main_Rec.currency_sell ;

BEGIN

   p_error := FALSE;

   /* ------------------------------------------------------------------------ */
   /* Determine home currency and rounding factor for subsequent calculations. */
   /* ------------------------------------------------------------------------ */
      open rnd_fac;
      fetch rnd_fac into home_currency, roundfac;
      if rnd_fac%notfound then
         close rnd_fac;
         /* cannot find home currency rate */
         xtr_import_deal_data.log_interface_errors(G_Fx_Main_Rec.External_Deal_Id,p_user_deal_type,
                                                   'CompanyCode','XTR_880');
         p_error := TRUE;
         return;
      end if;
      close rnd_fac;

   /* ------------------------------------------------------------------------------------------------------*/
   /* Calculation for buy amount differs depending on whether the buy or sell currency is the home currency.*/
   /* ------------------------------------------------------------------------------------------------------*/
   /* 1. buy currency = home currency. If buy curr = home curr then buy hce amount is set to buy amount     */
   /* ------------------------------------------------------------------------------------------------------*/

      if G_Fx_Main_Rec.currency_buy = home_currency then
       	G_Fx_Main_Rec.buy_hce_amount := G_Fx_Main_Rec.buy_amount;
       	G_Fx_Main_Rec.sell_hce_amount := G_Fx_Main_Rec.buy_amount;
      end if;


   /* ------------------------------------------------------------------------------------------------------*/
   /* 2. sell currency = home currency. If sell curr = home curr then sell hce amount is set to sell amount */
   /* ------------------------------------------------------------------------------------------------------*/

      if G_Fx_Main_Rec.currency_sell = home_currency then
       	G_Fx_Main_Rec.buy_hce_amount := G_Fx_Main_Rec.sell_amount;
       	G_Fx_Main_Rec.sell_hce_amount := G_Fx_Main_Rec.sell_amount;
      end if;


   /* ------------------------------------------------------------------------------------------------------*/
   /* 3. home currency <> sell or buy currencies. If home currency is not sell or buy currency then         */
   /*    buy hce amount is calculated as buy amount /spot_rates.hce_rate for buy curr                       */
   /* ------------------------------------------------------------------------------------------------------*/

     if (G_Fx_Main_Rec.currency_buy <> home_currency and
         G_Fx_Main_Rec.currency_sell <> home_currency) then
	  open hc_rate;
	  fetch hc_rate into G_Fx_Main_Rec.buy_hce_amount;
	  if hc_rate%notfound then
	     close hc_rate;
	     /* Cannot find home currency rate */
	     xtr_import_deal_data.log_interface_errors(G_Fx_Main_Rec.External_Deal_Id,p_user_deal_type,
                                                       'CurrencyA','XTR_880');
             p_error := TRUE;
             return;
	  end if;
	  G_Fx_Main_Rec.sell_hce_amount := G_Fx_Main_Rec.buy_hce_amount;
	  close hc_rate;
     end if;

   /* -------------------------------------------------------------------
      Forward hce amount. Calculation for forward buy amount differs,
      depending on whether the buy or sell currency is the home ccy
      If buy curr = home curr then
      forward hce amount is set to  buy amount - sell amount/base rate
      else, if sell curr = home curr then
      forward hce amount is set to buy amount/base rate - sell amount   */
    /*------------------------------------------------------------------*/

     if G_Fx_Main_Rec.currency_buy = home_currency then
        G_Fx_Main_Rec.forward_hce_amount := round(G_Fx_Main_Rec.buy_amount -
                                           (G_Fx_Main_Rec.sell_amount/G_Fx_Main_Rec.base_rate),roundfac);
     elsif G_Fx_Main_Rec.currency_sell = home_currency then
        G_Fx_Main_Rec.forward_hce_amount := round((G_Fx_Main_Rec.buy_amount/G_Fx_Main_Rec.base_rate -
                                            G_Fx_Main_Rec.sell_amount),roundfac);
     end if;

   /* -----------------------------------------------------------------------
      If home currency is not sell or buy currency then forward hce
      amount is calculated as :(buy amount/base rate - sell amount)/hce
      for sell ccy if sell currency quoted first in buy/sell combinations or
     (buy amount*base rate - sell amount)/hce for sell currency if sell
     currency quoted second in buy/sell combinations.                       */
   /*-----------------------------------------------------------------------*/

     if (G_Fx_Main_Rec.currency_buy <> home_currency and G_Fx_Main_Rec.currency_sell <> home_currency) then
         open calc_hce;
         fetch calc_hce into  forward_hce_first, forward_hce_second;
         if calc_hce%notfound then
            close calc_hce;
	    xtr_import_deal_data.log_interface_errors(G_Fx_Main_Rec.External_Deal_Id,p_user_deal_type,
                                                      'CurrencyB','XTR_886');  -- Unable to find spot rate sell data
            p_error := TRUE;
            return;
         end if;

         if G_Fx_Main_Rec.currency_sell = g_currency_first then
             G_Fx_Main_Rec.forward_hce_amount := forward_hce_first;
         else
             G_Fx_Main_Rec.forward_hce_amount := forward_hce_second;
         end if;

         close calc_hce;

     end if;

    /*-----------------------------------------------------------*/
    /* portfolio amount. set portfolio amount to buy hce amount. */
    /*-----------------------------------------------------------*/
     G_Fx_Main_Rec.portfolio_amount := G_Fx_Main_Rec.buy_hce_amount;


end CALC_HCE_AMOUNTS;

/*------------------------------------------------------------*/
PROCEDURE CALC_BROKERAGE_AMT(p_user_deal_type IN  VARCHAR2,
                             p_bkr_amt_type   IN  VARCHAR2,
                             p_error          OUT NOCOPY BOOLEAN) IS
/*------------------------------------------------------------*/
  l_dummy_num  number;
  l_dummy_char varchar2(30);
  l_amt        number;
  l_ccy        varchar2(30);
  l_err_code   number(8);
  l_level      varchar2(2) := ' ';

l_mine  number;

BEGIN
   if (p_bkr_amt_type = 'BUY'  and G_Fx_Main_Rec.currency_buy is not null  and G_Fx_Main_Rec.buy_amount is not null) or
      (p_bkr_amt_type = 'SELL' and G_Fx_Main_Rec.currency_sell is not null and G_Fx_Main_Rec.sell_amount is not null) then

      if p_bkr_amt_type = 'BUY' then
         l_ccy := G_Fx_Main_Rec.currency_buy;
         l_amt := G_Fx_Main_Rec.buy_amount;
      else
         l_ccy := G_Fx_Main_Rec.currency_sell;
         l_amt := G_Fx_Main_Rec.sell_amount;
      end if;
      xtr_fps1_p.calc_tax_brokerage(G_Fx_Main_Rec.deal_type,
                                    G_Fx_Main_Rec.deal_date,
                                    null,
                                    G_Fx_Main_Rec.brokerage_code,
                                    l_ccy,
                                    0,
                                    0,
                                    null,
                                    0,
                                    l_dummy_num,
                                    p_bkr_amt_type,
                                    l_amt,
                                    G_Fx_Main_Rec.brokerage_rate,
                                    l_dummy_num,
                                    l_dummy_num,
                                    G_Fx_Main_Rec.brokerage_amount,
                                    l_dummy_num,
                                    l_err_code,
                                    l_level);

      check_for_error(p_user_deal_type, l_err_code, l_level);

      if nvl(l_level,'X') = 'E' then
         p_error := TRUE;
      else
         p_error := FALSE;
      end if;

   end if;

END CALC_BROKERAGE_AMT;

/*------------------------------------------------------------*/
PROCEDURE VALIDATE_BUY_SELL_AMOUNT (p_user_deal_type IN VARCHAR2,
                                    p_error OUT NOCOPY boolean) is
/*------------------------------------------------------------*/
   l_error_amt BOOLEAN := FALSE;

BEGIN

        chk_buy_sell_amount(p_user_deal_type,g_currency_first, l_error_amt);

        if (l_error_amt = TRUE) then
	    p_error := TRUE;
        else
	    p_error := FALSE;
        end if;

END VALIDATE_BUY_SELL_AMOUNT;


/*------------------------------------------------------------*/
PROCEDURE  CHK_BUY_SELL_AMOUNT (p_user_deal_type IN VARCHAR2,
                                p_currency_first IN varchar2,
			        p_error IN OUT NOCOPY BOOLEAN) is
/*------------------------------------------------------------*/

 roundfac              number(3,2);
 v_new_buy_amount      number;
 v_new_sell_amount     number;
 l_tol 		       number;

/*
 cursor rnd is
  select m.rounding_factor
   from xtr_master_currencies_v m
   where m.currency = G_Fx_Main_Rec.currency_sell;
*/

--RV 2342574
 cursor rnd(p_curr in VARCHAR2) is
  select m.rounding_factor
   from xtr_master_currencies_v m
   where m.currency = p_curr;

 Cursor tol is
 select parameter_value
 from   xtr_company_parameters
 where  company_code = G_Fx_Main_Rec.COMPANY_CODE
 and    parameter_code = 'IMPORT_FXTOL';

BEGIN
  if nvl(G_Fx_Main_Rec.buy_amount,nvl(G_Fx_Main_Rec.sell_amount,0)) <> 0 and
     G_Fx_Main_Rec.transaction_rate is not null then

/* 2342574
   	open rnd;
   	fetch rnd into roundfac;
   	close rnd;
*/
	open  tol;
	fetch tol into l_tol;
	close tol;

   	if G_Fx_Main_Rec.currency_sell = p_currency_first then
           --RV 2342574
       	   open rnd(G_Fx_Main_Rec.currency_sell);
   	   fetch rnd into roundfac;
   	   close rnd;
     	   v_new_sell_amount := round(nvl(G_Fx_Main_Rec.buy_amount,0) / G_Fx_Main_Rec.transaction_rate,nvl(roundfac,2));

--    	   if v_new_sell_amount <> NVL(G_Fx_Main_Rec.sell_amount,0) then  -- rvallams bug 2397061

	   if v_new_sell_amount < round(NVL(G_Fx_Main_Rec.sell_amount,0) - l_tol/power(10,nvl(roundfac,0)),nvl(roundfac,2))
              OR v_new_sell_amount > round(NVL(G_Fx_Main_Rec.sell_amount,0) + l_tol/power(10,nvl(roundfac,0)),nvl(roundfac,2))  then

     	      xtr_import_deal_data.log_interface_errors(G_Fx_Main_Rec.External_Deal_Id,p_user_deal_type,
                                                        'AmountA','XTR_INV_BUY_AMT');
     	      xtr_import_deal_data.log_interface_errors(G_Fx_Main_Rec.External_Deal_Id,p_user_deal_type,
                                                        'AmountB','XTR_INV_SELL_AMT');
	      p_error := TRUE;
   	   end if;
   	else

           --RV 2342574
	   open rnd(G_Fx_Main_Rec.currency_buy);
   	   fetch rnd into roundfac;
   	   close rnd;

           v_new_buy_amount := round(nvl(G_Fx_Main_Rec.sell_amount,0)/ G_Fx_Main_Rec.transaction_rate,nvl(roundfac,2));

--           if  (v_new_buy_amount <> NVL(G_Fx_Main_Rec.buy_amount,0)) then -- rvallams bug 2397061

	   if v_new_buy_amount < round(NVL(G_Fx_Main_Rec.buy_amount,0) - l_tol/power(10,nvl(roundfac,0)),nvl(roundfac,2))
              OR v_new_buy_amount > round(NVL(G_Fx_Main_Rec.buy_amount,0) + l_tol/power(10,nvl(roundfac,0)),nvl(roundfac,2))  then

     	      xtr_import_deal_data.log_interface_errors(G_Fx_Main_Rec.External_Deal_Id,p_user_deal_type,
                                                        'AmountA','XTR_INV_BUY_AMT');
     	      xtr_import_deal_data.log_interface_errors(G_Fx_Main_Rec.External_Deal_Id,p_user_deal_type,
                                                        'AmountB','XTR_INV_SELL_AMT');
	      p_error := TRUE;
   	   end if;
   	end if;

  end if;

END CHK_BUY_SELL_AMOUNT;


/*------------------------------------------------------------*/
PROCEDURE CREATE_FX_DEAL(ARec_Fx   IN XTR_DEALS%ROWTYPE,
			 p_deal_no IN NUMBER) IS
/*------------------------------------------------------------*/

    cursor FIND_USER (p_fnd_user in number) is
    select dealer_code
    from   xtr_dealer_codes_v
    where  user_id = p_fnd_user;

    l_user       xtr_dealer_codes.dealer_code%TYPE;
    l_dual_user  xtr_dealer_codes.dealer_code%TYPE;
    l_dual_date  DATE;

Begin

        open  FIND_USER(G_User_Id);
        fetch FIND_USER into l_user;
        close FIND_USER;

        l_dual_user := ARec_Fx.DUAL_AUTHORISATION_BY;
        l_dual_date := ARec_Fx.DUAL_AUTHORISATION_ON;
        if ((l_dual_user is not null and l_dual_date is null) or
            (l_dual_user is null     and l_dual_date is not null)) then
            if l_dual_date is null then
               l_dual_date := trunc(sysdate);
            elsif l_dual_user is null then
               l_dual_user := l_user;
            end if;
        end if;

	INSERT INTO xtr_deals
	       (
		  EXTERNAL_DEAL_ID ,
		  DEAL_NO 		,
		  DEAL_TYPE  		,
		  DEALER_CODE 		,
		  COMPANY_CODE 		,
		  CPARTY_CODE 		,
		  CLIENT_CODE 		,
		  PORTFOLIO_CODE 	,
		  LIMIT_CODE 		,
		  DEAL_SUBTYPE 		,
		  PRODUCT_TYPE 		,
		  DEAL_DATE  		,
		  VALUE_DATE 		,
		  BASE_DATE  		,
		  CURRENCY_BUY 		,
		  CURRENCY_SELL 	,
		  BUY_AMOUNT 		,
		  SELL_AMOUNT 		,
		  BUY_ACCOUNT_NO 	,
		  SELL_ACCOUNT_NO 	,
		  BASE_RATE  		,
		  TRANSACTION_RATE 	,
		  COMMENTS  		,
		  EXTERNAL_COMMENTS 	,
		  INTERNAL_TICKET_NO 	,
		  EXTERNAL_CPARTY_NO 	,
		  CPARTY_ACCOUNT_NO     ,
		  CPARTY_REF 		,
		  NO_OF_DAYS 		,
		  PRICING_MODEL		,
		  MARKET_DATA_SET 	,
		  DEAL_LINKING_CODE 	,
		  BROKERAGE_CODE 	,
		  BROKERAGE_RATE 	,
		  BROKERAGE_AMOUNT 	,
		  BROKERAGE_CURRENCY 	,
		  BUY_HCE_AMOUNT    	,
		  SELL_HCE_AMOUNT   	,
		  FORWARD_HCE_AMOUNT	,
		  PORTFOLIO_AMOUNT      ,
		  STATUS_CODE		,
		  DUAL_AUTHORISATION_BY	,
		  DUAL_AUTHORISATION_ON	,
		  CREATED_BY		,
		  CREATED_ON		,
	          ATTRIBUTE_CATEGORY 	,
	          ATTRIBUTE1 		,
	          ATTRIBUTE2 		,
	          ATTRIBUTE3 		,
	          ATTRIBUTE4 		,
	          ATTRIBUTE5 		,
	          ATTRIBUTE6 		,
	          ATTRIBUTE7 		,
	          ATTRIBUTE8 		,
	          ATTRIBUTE9 		,
	          ATTRIBUTE10 		,
	          ATTRIBUTE11 		,
	          ATTRIBUTE12 		,
	          ATTRIBUTE13 		,
	          ATTRIBUTE14 		,
	          ATTRIBUTE15 ,
		  REQUEST_ID   ,
		  PROGRAM_APPLICATION_ID   ,
		  PROGRAM_ID           ,
		  PROGRAM_UPDATE_DATE            )
	     VALUES
	       (
  		  ARec_Fx.EXTERNAL_DEAL_ID 	,
		  p_deal_no			,
		  ARec_Fx.DEAL_TYPE  		,
		  ARec_Fx.DEALER_CODE 		,
		  ARec_Fx.COMPANY_CODE 		,
		  ARec_Fx.CPARTY_CODE 		,
		  ARec_Fx.CLIENT_CODE 		,
		  ARec_Fx.PORTFOLIO_CODE 	,
		  ARec_Fx.LIMIT_CODE 		,
		  ARec_Fx.DEAL_SUBTYPE 		,
		  ARec_Fx.PRODUCT_TYPE 		,
		  ARec_Fx.DEAL_DATE  		,
		  ARec_Fx.VALUE_DATE 		,
		  ARec_Fx.DEAL_DATE  		,
		  ARec_Fx.CURRENCY_BUY 		,
		  ARec_Fx.CURRENCY_SELL 	,
		  ARec_Fx.BUY_AMOUNT 		,
		  ARec_Fx.SELL_AMOUNT 		,
		  ARec_Fx.BUY_ACCOUNT_NO 	,
		  ARec_Fx.SELL_ACCOUNT_NO 	,
		  ARec_Fx.BASE_RATE  		,
		  ARec_Fx.TRANSACTION_RATE 	,
		  ARec_Fx.COMMENTS  		,
		  ARec_Fx.EXTERNAL_COMMENTS 	,
		  ARec_Fx.INTERNAL_TICKET_NO 	,
		  ARec_Fx.EXTERNAL_CPARTY_NO 	,
		  Arec_Fx.CPARTY_ACCOUNT_NO     ,
		  ARec_Fx.CPARTY_REF 		,
	          ARec_Fx.NO_OF_DAYS            ,
		  ARec_Fx.PRICING_MODEL		,
		  ARec_Fx.MARKET_DATA_SET 	,
		  ARec_Fx.DEAL_LINKING_CODE 	,
		  ARec_Fx.BROKERAGE_CODE 	,
		  ARec_Fx.BROKERAGE_RATE 	,
		  ARec_Fx.BROKERAGE_AMOUNT 	,
		  ARec_Fx.BROKERAGE_CURRENCY 	,
		  ARec_Fx.BUY_HCE_AMOUNT    	,
		  ARec_Fx.SELL_HCE_AMOUNT   	,
		  ARec_Fx.FORWARD_HCE_AMOUNT	,
		  ARec_Fx.PORTFOLIO_AMOUNT      ,
		  ARec_Fx.STATUS_CODE		,
		  l_dual_user                   ,
		  l_dual_date                   ,
		  nvl(l_user,G_User_Id)	        ,
		  g_curr_date			,
	        --decode(ARec_Fx.ATTRIBUTE_CATEGORY,'Global Data Elements','',ARec_Fx.ATTRIBUTE_CATEGORY)	,
	          ARec_Fx.ATTRIBUTE_CATEGORY    ,
	          ARec_Fx.ATTRIBUTE1 		,
	          ARec_Fx.ATTRIBUTE2 		,
	          ARec_Fx.ATTRIBUTE3 		,
	          ARec_Fx.ATTRIBUTE4 		,
	          ARec_Fx.ATTRIBUTE5 		,
	          ARec_Fx.ATTRIBUTE6 		,
	          ARec_Fx.ATTRIBUTE7 		,
	          ARec_Fx.ATTRIBUTE8 		,
	          ARec_Fx.ATTRIBUTE9 		,
	          ARec_Fx.ATTRIBUTE10 		,
	          ARec_Fx.ATTRIBUTE11 		,
	          ARec_Fx.ATTRIBUTE12 		,
	          ARec_Fx.ATTRIBUTE13 		,
	          ARec_Fx.ATTRIBUTE14 		,
	          ARec_Fx.ATTRIBUTE15 		,
		  FND_GLOBAL.conc_request_id	,
		  FND_GLOBAL.prog_appl_id	,
		  FND_GLOBAL.conc_program_id	,
		  g_curr_date
 		  );

        xtr_reval_process_p.xtr_ins_init_fv(ARec_Fx.COMPANY_CODE,p_deal_no,ARec_Fx.DEAL_TYPE,NULL);

        if l_dual_user is not null then
	   UPDATE xtr_deal_date_amounts
           SET    dual_authorisation_by = l_dual_user,
	          dual_authorisation_on = l_dual_date
           WHERE  deal_number 	        = p_deal_no;

	   UPDATE xtr_confirmation_details
           SET    confirmation_validated_by = l_dual_user,
	          confirmation_validated_on = l_dual_date
           WHERE  deal_no 	    	    = p_deal_no;

	   UPDATE xtr_deals
           SET    dual_authorisation_on = l_dual_date
           WHERE  deal_no     	        = p_deal_no;
        end if;

END CREATE_FX_DEAL;

/*------------------------------------------------------------------------*/
PROCEDURE CHECK_FOR_ERROR( p_user_deal_type IN VARCHAR2,
                           l_err_code       IN NUMBER,
                           l_level          IN VARCHAR2 ) is
/*------------------------------------------------------------------------*/

begin
declare
  new_error_code varchar2(30);
  Begin
      new_error_code := 'XTR_'|| to_char(l_err_code);  -- XTR_886 Unable to find Spot Rate.
      if nvl(l_level,'X') = 'E' then
	xtr_import_deal_data.log_interface_errors(G_Fx_Main_Rec.External_Deal_Id, p_user_deal_type,
                                                                                 'AmountC',new_error_code);
      end if;
  End;
END CHECK_FOR_ERROR;

END XTR_FX_TRANSFERS_PKG;

/
