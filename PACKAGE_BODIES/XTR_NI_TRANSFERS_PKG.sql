--------------------------------------------------------
--  DDL for Package Body XTR_NI_TRANSFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_NI_TRANSFERS_PKG" AS
/* $Header: xtrimnib.pls 120.1 2005/06/29 10:06:24 csutaria noship $*/

/* Stub for consistency sake */
/*-------------------------------------------------------------------------------------*/
PROCEDURE TRANSFER_NI_DEALS(ARec_Interface     IN  XTR_DEALS_INTERFACE%ROWTYPE,
                            user_error         OUT NOCOPY BOOLEAN,
                            mandatory_error    OUT NOCOPY BOOLEAN,
                            validation_error   OUT NOCOPY BOOLEAN,
                            limit_error        OUT NOCOPY BOOLEAN) is
/*-------------------------------------------------------------------------------------*/
  v_dummy NUMBER;
BEGIN
  TRANSFER_NI_DEALS(ARec_Interface,user_error,mandatory_error,validation_error,limit_error,v_dummy);
END;

/*-------------------------------------------------------------------------------------*/
PROCEDURE TRANSFER_NI_DEALS(ARec_Interface     IN  XTR_DEALS_INTERFACE%ROWTYPE,
                            user_error         OUT NOCOPY BOOLEAN,
                            mandatory_error    OUT NOCOPY BOOLEAN,
                            validation_error   OUT NOCOPY BOOLEAN,
                            limit_error        OUT NOCOPY BOOLEAN,
                            deal_num           OUT NOCOPY NUMBER) is
/*-------------------------------------------------------------------------------------*/

   v_limit_log_return NUMBER;
   l_risk_code_holder XTR_DEALS_INTERFACE.cparty_code%TYPE;

BEGIN

    -------------------------
    --  Initialise Variables
    -------------------------
    g_user_id         := fnd_global.user_id;
    g_curr_date       := trunc(sysdate);
    g_ni_deal_subtype := null;
    g_ni_deal_type    := 'NI';
    g_no_of_days      := null;
    g_year_basis      := null;
    g_num_parcels     := 0;



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
         --* The following code does mandatory field validation specific to the NI deals
         --------------------------------------------------------------------------------
         CHECK_MANDATORY_FIELDS(ARec_Interface, mandatory_error);


         if (mandatory_error <> TRUE) then

            --------------------------------------------------------------------------------------
            --* The following code performs the business logic validation specific to the NI deals
            --------------------------------------------------------------------------------------
            VALIDATE_DEALS(ARec_Interface, validation_error);

            if (validation_error <> TRUE) then

                 ------------------------------------------------------------------
                     --* Perform limit checks
                 ------------------------------------------------------------------

                 if g_ni_deal_subtype = 'ISSUE' then
                    l_risk_code_holder    := G_Ni_Main_Rec.cparty_code;
                 else
                    l_risk_code_holder    := G_Ni_Main_Rec.acceptor_code;
                 end if;

                 v_limit_log_return := XTR_LIMITS_P.LOG_FULL_LIMITS_CHECK (
                                                             G_Ni_Main_Rec.deal_no,
                                                           1,                            -- TRANSACTION_NUMBER
                                                           G_Ni_Main_Rec.company_code,
                                                           G_Ni_Main_Rec.deal_type,
                                                             G_Ni_Main_Rec.deal_subtype,
                                                           l_risk_code_holder,
                                                           G_Ni_Main_Rec.product_type,
                                                           G_Ni_Main_Rec.riskparty_limit_code,
                                                           G_Ni_Main_Rec.riskparty_code,     -- limit_party
                                                           G_Ni_Main_Rec.maturity_date,  -- amount_date
                                                           G_Ni_Main_Rec.maturity_balance_amount,
                                                           G_Ni_Main_Rec.dealer_code,
                                                           G_Ni_Main_Rec.currency);

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

      /*wdk: would like to do get deal_no here, and then calc trans and various inserts*/

      CHECK_ACCRUAL_REVAL(ARec_Interface);

     /*----------------------------------------------------*/
     /* Call the insert procedure to insert into xtr_deals */
     /*----------------------------------------------------*/
      CREATE_NI_DEAL;

      XTR_LIMITS_P.UPDATE_LIMIT_EXCESS_LOG(G_Ni_Main_Rec.DEAL_NO,
                                           1,
                                           Fnd_Global.User_Id,
                                           v_limit_log_return);

      deal_num:=g_ni_main_rec.deal_no;

     /*----------------------------------------------------------------------------------*/
     /* Since the insert is done, we can now delete the rows from the interface tables.  */
     /*----------------------------------------------------------------------------------*/
      delete from xtr_deals_interface
      where  external_deal_id = ARec_Interface.external_deal_id
      and    deal_type        = ARec_Interface.deal_type;

      delete from xtr_transactions_interface
      where  external_deal_id = ARec_Interface.external_deal_id
      and    deal_type        = ARec_Interface.deal_type;

   else

      update xtr_deals_interface
      set    load_status_code = 'ERROR',
             last_update_date = G_Curr_Date,
             Last_Updated_by  = g_user_id
      where  external_deal_id = ARec_Interface.external_deal_id
      and    deal_type        = ARec_Interface.deal_type;

   end if;

end TRANSFER_NI_DEALS;


/*------------------------------------------------------------------------------*/
/*      The following code implements the CHECK_MANDATORY_FIELDS process        */
/*------------------------------------------------------------------------------*/
PROCEDURE CHECK_MANDATORY_FIELDS(ARec_Interface IN  XTR_DEALS_INTERFACE%ROWTYPE,
                                 error                 OUT NOCOPY BOOLEAN) is
/*------------------------------------------------------------------------------*/
  PROCEDURE CHECK_MANDATORY_TR_FIELDS IS

    CURSOR GET_TRANSACTIONS IS
      SELECT *
      FROM   XTR_TRANSACTIONS_INTERFACE
      WHERE  EXTERNAL_DEAL_ID = ARec_Interface.external_deal_id
      AND    DEAL_TYPE = ARec_Interface.deal_type;

    l_has_transactions boolean:=false;

    BEGIN

      FOR l_transaction IN GET_TRANSACTIONS LOOP

        l_has_transactions:=true;

        if l_transaction.amount_a is null then
                xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,
                                                          ARec_Interface.Deal_Type,
                                                          'AmountA',
                                                          'XTR_MANDATORY',
                                                          l_transaction.transaction_no);
                error := TRUE;
        end if;

        if l_transaction.amount_b is null and l_transaction.amount_c is null then
                xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,
                                                          ARec_Interface.Deal_Type,
                                                          'AmountB',
                                                          'XTR_MANDATORY_FACEVALUE',
                                                          l_transaction.transaction_no);
                error := TRUE;
        end if;

        if l_transaction.option_a is null then
                xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,
                                                          ARec_Interface.Deal_Type,
                                                          'OptionA',
                                                          'XTR_MANDATORY',
                                                          l_transaction.transaction_no);
                error := TRUE;
        end if;


      END LOOP;

      if not(l_has_transactions) then
                xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,
                                                          ARec_Interface.Deal_Type,
                                                          'ExternalDealId',
                                                          'XTR_MANDATORY_TRANSACTIONS');
                error := TRUE;
      end if;

    END CHECK_MANDATORY_TR_FIELDS;

  BEGIN

        error := FALSE; /* Defaulting it to No errors */

        if ARec_Interface.dealer_code is null then
                xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'DealerCode','XTR_MANDATORY');
                error := TRUE;
        end if;

        if ARec_Interface.company_code is null then
                xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'CompanyCode','XTR_MANDATORY');
                error := TRUE;
        end if;

        if ARec_Interface.portfolio_code is null then
                xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'PortfolioCode','XTR_MANDATORY');
                error := TRUE;
        end if;

        if ARec_Interface.year_calc_type is null then
                xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'YearCalcType','XTR_MANDATORY');
                error := TRUE;
        end if;

        if ARec_Interface.basis_type is null then
                xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'BasisType','XTR_MANDATORY');
                error := TRUE;
        end if;

        if ARec_Interface.rounding_type is null then
                xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'RoundingType','XTR_MANDATORY');
                error := TRUE;
        end if;

        if ARec_Interface.day_count_type is null then
                xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'DayCountType','XTR_MANDATORY');
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

        if ARec_Interface.date_c is null then
                xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'DateC','XTR_MANDATORY');
                error := TRUE;
        end if;

        if ARec_Interface.currency_a is null then
                xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'CurrencyA','XTR_MANDATORY');
                error := TRUE;
        end if;

        if ARec_Interface.rate_a is null then
                xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'RateA','XTR_MANDATORY');
                error := TRUE;
        end if;

        if ARec_Interface.account_no_a is null then
                xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'AccountNoA','XTR_MANDATORY');
                error := TRUE;
        end if;

        if  ARec_Interface.brokerage_code is null and
           (ARec_Interface.rate_c is not null or ARec_Interface.amount_c is not null) then
                xtr_import_deal_data.log_interface_errors(ARec_Interface.External_Deal_Id,ARec_Interface.Deal_Type,
                                                          'BrokerageCode','XTR_MANDATORY_BROKERAGE');
                error := TRUE;
        end if;

        CHECK_MANDATORY_TR_FIELDS;

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

           COPY_FROM_INTERFACE_TO_NI(ARec_Interface);

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


l_error                 number := 0;
l_err_segment           varchar2(30);
l_err_cparty            boolean := FALSE;
l_err_deal_subtype      boolean := FALSE;
l_err_deal_date         boolean := FALSE;
l_err_currency_a        boolean := FALSE;
l_err_brokerage_code    boolean := FALSE;


  PROCEDURE VALIDATE_TRANSACTIONS IS

    CURSOR GET_TRANSACTIONS IS
      SELECT *
      FROM   XTR_TRANSACTIONS_INTERFACE
      WHERE  EXTERNAL_DEAL_ID = ARec_Interface.external_deal_id
      AND    DEAL_TYPE = ARec_Interface.deal_type;

    BEGIN

      FOR l_transaction IN GET_TRANSACTIONS LOOP

           if (l_transaction.amount_a<=0) then
                xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                           ARec_Interface.Deal_Type,
                                                           'AmountA',
                                                           'XTR_VALUE_GE_ZERO',
                                                           l_transaction.transaction_no);
                l_error := l_error +1;
        end if;

           if ( l_transaction.amount_b<0) then
                xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                           ARec_Interface.Deal_Type,
                                                           'AmountB',
                                                           'XTR_VALUE_GE_ZERO',
                                                           l_transaction.transaction_no);
                l_error := l_error +1;
        end if;

           if ( l_transaction.amount_c<0) then
                xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                           ARec_Interface.Deal_Type,
                                                           'AmountC',
                                                           'XTR_VALUE_GE_ZERO',
                                                           l_transaction.transaction_no);
                l_error := l_error +1;
           elsif not ( val_consideration(l_transaction.amount_b,l_transaction.amount_c,ARec_Interface.basis_type)) then
                xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                           ARec_Interface.Deal_Type,
                                                           'AmountC',
                                                           'XTR_INV_CONSIDERATION',
                                                           l_transaction.transaction_no);
                l_error := l_error +1;
        end if;


        -- Interest overide is validated later

        if l_err_deal_subtype <> TRUE then

		   if not ( val_serial_number(l_transaction.value_a,l_transaction.amount_a)) then
			xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
								   ARec_Interface.Deal_Type,
								   'ValueA',
								   'XTR_INV_SERIAL_NUMBER',
								   l_transaction.transaction_no);
			l_error := l_error +1;
		end if;
	end if;

           if ( l_transaction.option_a not in ('Y','N')) then
                xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                           ARec_Interface.Deal_Type,
                                                           'OptionA',
                                                           'XTR_INV_AVAILABLE',
                                                           l_transaction.transaction_no);
                l_error := l_error +1;
        end if;


        /*-------------------------------------------------------------------------------*/
        /*      Transaction Flexfields Validation                                        */
        /*-------------------------------------------------------------------------------*/

        if not ( xtr_import_deal_data.val_transaction_desc_flex(l_transaction,'XTR_RT_DESC_FLEX',l_err_segment)) then
           l_error := l_error +1;
           if l_err_segment is not null and l_err_segment = 'Attribute16' then
                xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                           ARec_Interface.Deal_Type,
                                                           l_err_segment,
                                                           'XTR_INV_DESC_FLEX_API',
                                                           l_transaction.transaction_no);
           elsif l_err_segment is not null and l_err_segment = 'AttributeCategory' then
                xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                           ARec_Interface.Deal_Type,
                                                           l_err_segment,
                                                           'XTR_INV_DESC_FLEX_CONTEXT',
                                                           l_transaction.transaction_no);
           else
                xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                           ARec_Interface.Deal_Type,
                                                           l_err_segment,
                                                           'XTR_INV_DESC_FLEX',
                                                           l_transaction.transaction_no);
           end if;
        end if;


      END LOOP;

    END VALIDATE_TRANSACTIONS;

    PROCEDURE GET_DAYS_RUN IS
    BEGIN
        if (ARec_interface.date_b <= ARec_Interface.date_c) then
          XTR_CALC_P.CALC_DAYS_RUN(ARec_Interface.date_b,
                                ARec_Interface.date_c,
                                ARec_Interface.year_calc_type,
                                g_no_of_days,
                                g_year_basis,
                                null,
                                ARec_Interface.day_count_type,
                                'Y');
        end if;
    END GET_DAYS_RUN;

 BEGIN

   /* This procedure will include all the column validations */
        if not ( val_deal_subtype(ARec_Interface.deal_subtype)) then
            xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                       ARec_Interface.Deal_Type,
                                                       'DealSubtype',
                                                       'XTR_INV_DEAL_SUBTYPE');
            l_error := l_error +1;
            l_err_deal_subtype := TRUE;
        end if;

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
        end if;
        /*

                 if not ( val_risk_party_code(ARec_Interface.acceptor_code)) then
                     xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                                ARec_Interface.Deal_Type,
                                                                'AcceptorCode',
                                                                'XTR_INV_RISK_PARTY_CODE');
                     l_error := l_error +1;
                end if;

                 if not ( val_risk_party_code(ARec_Interface.drawer_code)) then
                     xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                                ARec_Interface.Deal_Type,
                                                                'DrawerCode',
                                                                'XTR_INV_RISK_PARTY_CODE');
                     l_error := l_error +1;
                end if;

                 if not ( val_risk_party_code(ARec_Interface.endorser_code)) then
                     xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                                ARec_Interface.Deal_Type,
                                                                'EndorserCode',
                                                                'XTR_INV_RISK_PARTY_CODE');
                     l_error := l_error +1;
                end if;
        */
        if l_err_deal_subtype <> TRUE then

                   if not ( val_limit_code(ARec_Interface.limit_code,
                                        ARec_Interface.company_code,
                                        ARec_Interface.acceptor_code,
                                        ARec_Interface.endorser_code,
                                        ARec_Interface.drawer_code)) then
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
                                                           'XTR_INV_CURR');
                l_error := l_error +1;
                l_err_currency_a := TRUE;
              end if;

        if l_err_deal_subtype <> TRUE then
                   if not ( val_product_type(ARec_Interface.product_type,g_ni_deal_subtype)) then
                    xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                               ARec_Interface.Deal_Type,
                                                               'ProductType',
                                                               'XTR_INV_PRODUCT_TYPE');
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

        if l_err_cparty <> TRUE  and l_err_currency_a <> TRUE then
                   if not ( val_cparty_ref(ARec_Interface.cparty_account_no,
                                           ARec_Interface.cparty_ref,
                                           ARec_Interface.cparty_code,
                                           ARec_Interface.currency_a)) then
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

        if l_err_currency_a <> TRUE then
		if not ( val_comp_acct_no(ARec_Interface.company_code,
					  ARec_Interface.currency_a,
					  ARec_Interface.account_no_a)) then
			xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
								   ARec_Interface.Deal_Type,
								   'AccountNoA',
								   'XTR_INV_COMP_ACCT_NO');
			l_error := l_error +1;
		end if;
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


/*WDK: new message */


        if not ( val_rounding_type(ARec_Interface.rounding_type)) then
                xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                           ARec_Interface.Deal_Type,
                                                           'RoundingType',
                                                           'XTR_INV_ROUNDING_TYPE');
                l_error := l_error +1;
        end if;

        if not ( val_day_count_type(ARec_Interface.day_count_type)) then
                xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                           ARec_Interface.Deal_Type,
                                                           'DayCountType',
                                                           'XTR_INV_DAY_COUNT_TYPE');
                l_error := l_error +1;
        end if;

        if not ( val_start_date(ARec_Interface.date_a,
                                ARec_Interface.date_b)) then
                xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                           ARec_Interface.Deal_Type,
                                                           'DateB',
                                                           'XTR_INV_START_DATE');
                l_error := l_error +1;
        end if;

        if not ( val_maturity_date(ARec_Interface.date_b,
                                   ARec_Interface.date_c)) then
                xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                           ARec_Interface.Deal_Type,
                                                           'DateC',
                                                           'XTR_INV_MATURITY_DATE');
                l_error := l_error +1;
        end if;

        if not ( val_year_calc_type(ARec_Interface.year_calc_type)) then
                xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                           ARec_Interface.Deal_Type,
                                                           'YearCalcType',
                                                           'XTR_INV_DAY_COUNT_BASIS');
                l_error := l_error +1;
        end if;

        if not ( val_basis_type(ARec_Interface.basis_type)) then
                xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                           ARec_Interface.Deal_Type,
                                                           'BasisType',
                                                           'XTR_INV_BASIS_TYPE');
                l_error := l_error +1;
        end if;

        GET_DAYS_RUN;

        if not ( val_trans_rate(ARec_Interface.rate_a,
                                ARec_Interface.currency_a)) then
                xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                           ARec_Interface.Deal_Type,
                                                           'RateA',
                                                           'XTR_VALUE_GE_ZERO');  -- bug 2798328
                                                           -- 'XTR_INV_TRANS_RATE');
                l_error := l_error +1;
        end if;

        if not ( val_client_settle(ARec_Interface.settle_action_reqd)) then
                xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                           ARec_Interface.Deal_Type,
                                                           'SettleActionReqd',
                                                           'XTR_INV_CLIENT_SETTLE');
                l_error := l_error +1;
        end if;

        if not ( val_year_calc_day_count_combo(ARec_Interface.year_calc_type,
                                               ARec_Interface.day_count_type)) then
                xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                           ARec_Interface.Deal_Type,
                                                           'DayCountType',
                                                           'XTR_CHK_30_BOTH');
                l_error := l_error +1;
        end if;

        if l_err_deal_subtype <> TRUE then
		if not ( val_principal_tax_code(ARec_Interface.schedule_a)) then
			xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
								   ARec_Interface.Deal_Type,
								   'ScheduleA',
								   'XTR_INV_PRINCIPAL_TAX_CODE');
			l_error := l_error +1;
		end if;

		if not ( val_interest_tax_code(ARec_Interface.schedule_b)) then
			xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
								   ARec_Interface.Deal_Type,
								   'ScheduleB',
								   'XTR_INV_INTEREST_TAX_CODE');
			l_error := l_error +1;
		end if;
	end if;

        if ( ARec_Interface.option_a not in ('Y','N')) then
                xtr_import_deal_data.log_interface_errors( ARec_Interface.External_Deal_Id,
                                                           ARec_Interface.Deal_Type,
                                                           'OptionA',
                                                           'XTR_INV_DEFAULT_TAX_CODE');
                l_error := l_error +1;
        end if;



        VALIDATE_TRANSACTIONS;



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

        if l_error > 0 then
           error := TRUE;
        else
           error := FALSE;
        end if;

END CHECK_VALIDITY;

/*--------------------------------------------------------------------*/
FUNCTION val_deal_date (p_date_a        IN date) return BOOLEAN is
/*--------------------------------------------------------------------*/
BEGIN
        return (p_date_a<=g_curr_date);
END val_deal_date;

/*--------------------------------------------------------------------*/
FUNCTION val_start_date (p_date_a        IN date,
                         p_date_b        IN date) return BOOLEAN is
/*--------------------------------------------------------------------*/
BEGIN
        return (p_date_a<=p_date_b);
END val_start_date;

/*--------------------------------------------------------------------*/
FUNCTION val_maturity_date (p_date_a        IN date,
                            p_date_b        IN date) return BOOLEAN is
/*--------------------------------------------------------------------*/
BEGIN
        return (p_date_a<=p_date_b);
END val_maturity_date;

/*--------------------------------------------------------------------*/
FUNCTION val_client_code(p_client_code         IN varchar2) return BOOLEAN is
/*--------------------------------------------------------------------*/
l_count NUMBER;
BEGIN
        IF (p_client_code is null) then
            return true;
        end if;

                select count(*)
                into l_count
                from xtr_parties_v
                where party_type = 'CP'
                and party_category = 'CL'
                and party_code = p_client_code;

                return (l_count>0);
END val_client_code;

/*----------------------------------------------------------------------------*/
FUNCTION val_portfolio_code(p_company_code   IN varchar2,
                            p_cparty_code    IN varchar2,
                            p_portfolio_code IN varchar2) return BOOLEAN is
/*----------------------------------------------------------------------------*/
l_count NUMBER;
BEGIN
           select count(*)
           into l_count
           from xtr_portfolios_v
           where company_code = p_company_code
           and (external_party is null or external_party = p_cparty_code)
           and portfolio = p_portfolio_code;

           return (l_count>0);

END val_portfolio_code;

/*----------------------------------------------------------------------------*/
FUNCTION val_currencies ( p_currency        IN varchar2) return BOOLEAN is
/*----------------------------------------------------------------------------*/
l_count NUMBER;
BEGIN
                Select count(*)
                Into l_count
                from   xtr_master_currencies_v
                where  nvl(authorised,'N') = 'Y'
                And    currency = p_currency;

                return (l_count>0);
END val_currencies;

/*----------------------------------------------------------------------------*/
FUNCTION val_comp_acct_no(p_company_code         IN varchar2,
                          p_currency                IN varchar2,
                          p_account_no                IN varchar2) return BOOLEAN is
/*----------------------------------------------------------------------------*/
l_count NUMBER;
BEGIN
        select count(*)
        into l_count
        from xtr_bank_accounts_v
        where party_code = p_company_code
        and currency = p_currency
        and nvl(setoff_account_yn,'N') = 'N'
        and account_number = p_account_no;

        return (l_count>0);
END val_comp_acct_no;


/*----------------------------------------------------------------------------*/
FUNCTION val_cparty_ref(     p_cparty_account_no  IN varchar2,
                             p_cparty_ref         IN varchar2,
                             p_cparty_code        IN varchar2,
                             p_currency         IN varchar2) return BOOLEAN is
/*----------------------------------------------------------------------------*/
l_count NUMBER;
BEGIN
        IF (p_cparty_ref is null and p_cparty_account_no is null) then
            return true;
        end if;
                select count(*)
                into l_count
                from xtr_bank_accounts_v
                where currency = p_currency
                and   party_code = p_cparty_code
                and   account_number = p_cparty_account_no
                and   nvl(authorised,'N') = 'Y'
                and   bank_short_code = p_cparty_ref;

                return (l_count>0);
END val_cparty_ref;


/*--------------------------------------------------------------------------------*/
FUNCTION val_deal_linking_code( p_deal_linking_code IN varchar2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_count NUMBER;
BEGIN
        IF (p_deal_linking_code is null) then
                return true;
        end if;
                select count(*)
                into l_count
                from xtr_deal_linking_v
                where deal_linking_code = p_deal_linking_code;

                return (l_count>0);
END val_deal_linking_code;

/*--------------------------------------------------------------------------------*/
FUNCTION val_brokerage_code ( p_brokerage_code        IN varchar2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_count NUMBER;
BEGIN
        IF (p_brokerage_code is null) then
            return true;
        end if;

                select count(*)
                into   l_count
                from   xtr_tax_brokerage_setup_v a, xtr_deduction_calcs_v b
                where  a.reference_code = p_brokerage_code
                and    a.deal_type      = 'NI'
                and    a.deduction_type = 'B'
                and    a.deal_type      = b.deal_type
                and    a.calc_type      = b.calc_type
                and    nvl(a.authorised,'N') = 'Y';

                return (l_count>0);
END val_brokerage_code;


/*--------------------------------------------------------------------------------*/
FUNCTION val_dealer_code(p_dealer_code        IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_count NUMBER;
BEGIN
                select count(*)
                into l_count
                from xtr_dealer_codes_v
                where dealer_code = p_dealer_code;

                return (l_count>0);
END val_dealer_code;

/*--------------------------------------------------------------------------------*/
FUNCTION val_cparty_code(p_company_code         IN VARCHAR2,
                         p_cparty_code          IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_count NUMBER;
BEGIN
                select count(*)
                into l_count
                from xtr_party_info_v
                where party_type in ('CP','C')
                and ((party_type = 'CP' and mm_cparty='Y')
                        or party_type = 'C')
                and party_code = p_cparty_code
                and party_code <> p_company_code
                and nvl(authorised,'N') = 'Y';

                return (l_count>0);
END val_cparty_code;


/*--------------------------------------------------------------------------------*/
FUNCTION val_deal_subtype(p_user_deal_subtype IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_count NUMBER;
cursor get_deal_subtype is
        select deal_subtype
        from   xtr_deal_subtypes
        where  deal_type             = 'NI'
        and    user_deal_subtype    = p_user_deal_subtype
        and    nvl(authorised,'N')  = 'Y'
        and    rownum = 1;
BEGIN
        open get_deal_subtype;
        fetch get_deal_subtype into g_ni_deal_subtype;
        if get_deal_subtype%NOTFOUND then
                close get_deal_subtype;
                return false;
        end if;
        close get_deal_subtype;
        ------------------------------------------------------------------------------------------------------
        --* Note : Deal_subtype column in the view is actually referring to the user_deal_subtype of the table.
        ------------------------------------------------------------------------------------------------------
        select count(*)
        into   l_count
        from   xtr_auth_deal_subtypes_v a,
               xtr_deal_subtypes b
        where  a.deal_type    = 'NI'
        and    a.deal_type    = b.deal_type
        and    a.deal_subtype = b.user_deal_subtype
        and    b.deal_subtype in ('BUY','ISSUE')
        and    b.deal_subtype = g_ni_deal_subtype;

        return (l_count>0);
END val_deal_subtype;

/*--------------------------------------------------------------------------------*/
FUNCTION val_product_type(p_product_type   IN VARCHAR2,
                          p_deal_subtype   IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
/* p_deal_subtype is the system deal_subtype not the user deal subtype            */
   l_count Number;
BEGIN

        select count(*)
        into   l_count
        from   xtr_product_types_v
        where deal_type = 'NI'
        and   product_auth = 'Y'
        and   product_type = p_product_type
        and   product_type in(select product_type
                from  xtr_auth_product_types_v
                where deal_type='NI'
                and   deal_subtype=p_deal_subtype);

        return (l_count>0);
END val_product_type;

/*--------------------------------------------------------------------------------*/
FUNCTION val_pricing_model(p_pricing_model        IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
   l_count Number;
BEGIN
   select count(*)
   into   l_count
   from   xtr_price_models
   where  code        = p_pricing_model
   and    deal_type   = 'NI'
   and    nvl(authorized,'N') = 'Y';

   return (l_count>0);
END val_pricing_model;

/*--------------------------------------------------------------------------------*/
FUNCTION val_market_data_set(p_market_data_set        IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
   l_count number;
BEGIN
        select count(*)
        into l_count
        from xtr_rm_md_sets
        where set_code = p_market_data_set
        and nvl(authorized_yn,'N') = 'Y';

        return (p_market_data_set is null or l_count>0);
END val_market_data_set;

/*--------------------------------------------------------------------------------*/
FUNCTION val_risk_party_code(p_party_code        IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
/* Generic function to be used by Risk Party (Acceptor/Drawer/Endorser)           */
   l_count number;
BEGIN
	/* bug 2798328
        select count(*)
        into l_count
        from xtr_parties_v
        where party_code=p_party_code;

        return (p_party_code is null or l_count>0);
        */
        return true;
END val_risk_party_code;


/*--------------------------------------------------------------------------------*/
FUNCTION val_limit_code(p_limit_code        IN VARCHAR2,
                        p_company_code      IN VARCHAR2,
                        p_acceptor_code     IN VARCHAR2,
                        p_endorser_code     IN VARCHAR2,
                        p_drawer_code       IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_count number;

BEGIN
        select count(*)
        into l_count
        from   xtr_counterparty_limits_v a,
               xtr_limit_types_v b
        where  a.company_code = p_company_code
        and   (a.cparty_code = p_acceptor_code or a.cparty_code = p_endorser_code or a.cparty_code = p_drawer_code)
        and    a.limit_code <> 'SETTLE'
        and    a.limit_type  = b.limit_type
        and  ((fx_invest_fund_type in ('X','I') and g_ni_deal_subtype in ('BUY','COVER')) or
                      (fx_invest_fund_type in ('X','F') and g_ni_deal_subtype in ('SELL','SHORT','ISSUE')))
        and    a.authorised='Y' and nvl(a.expiry_date,sysdate+1)>sysdate
        and    a.limit_code = p_limit_code;

        return (p_limit_code is null or l_count>0);
END val_limit_code;


/*--------------------------------------------------------------------------------*/
FUNCTION val_rounding_type(p_rounding_type        IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_count number;

BEGIN
        select count(*)
        into l_count
        from fnd_lookups
        where lookup_type='XTR_ROUNDING_TYPE'
        and lookup_code=p_rounding_type;

        return (l_count>0);
END val_rounding_type;

/*--------------------------------------------------------------------------------*/
FUNCTION val_day_count_type(p_day_count_type        IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_count number;

BEGIN
        select count(*)
        into l_count
        from fnd_lookups
        where lookup_type='XTR_DAY_COUNT_TYPE'
        and lookup_code=p_day_count_type;

        return (l_count>0);
END val_day_count_type;

/*--------------------------------------------------------------------------------*/
FUNCTION val_year_calc_type(p_year_calc_type        IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_count number;

BEGIN
        select count(*)
        into l_count
        from fnd_lookups
        where lookup_type='XTR_DAY_COUNT_BASIS'
        AND lookup_code IN ('30/','30E+/','30E/','ACTUAL/ACTUAL','ACTUAL360','ACTUAL365')
        and lookup_code=p_year_calc_type;

        return (l_count>0);
END val_year_calc_type;

/*--------------------------------------------------------------------------------*/
FUNCTION val_year_calc_day_count_combo(p_year_calc_type IN VARCHAR2,
                                       p_day_count_type IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
BEGIN
  return not(substr(p_year_calc_type,1,2) = '30' and p_day_count_type = 'B');

END val_year_calc_day_count_combo;

/*--------------------------------------------------------------------------------*/
FUNCTION val_basis_type(p_basis_type        IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_count number;

BEGIN
        select count(*)
        into l_count
        from fnd_lookups
        where lookup_type='XTR_DISCOUNT_YIELD'
        and lookup_code=p_basis_type;

        return (l_count>0);
END val_basis_type;

/*--------------------------------------------------------------------------------*/
FUNCTION val_trans_rate(p_trans_rate        IN VARCHAR2,
                        p_currency            IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
BEGIN
        return (p_trans_rate>=0); -- bug 2798328
END val_trans_rate;


/*--------------------------------------------------------------------------------*/
FUNCTION val_client_settle(p_client_settle        IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_count number;

BEGIN
        select count(*)
        into l_count
        from fnd_lookups
        where lookup_type='XTR_PRINCIPAL_SETTLED_BY'
        and lookup_code=p_client_settle;

        return (l_count>0);
END val_client_settle;


/*--------------------------------------------------------------------------------*/
FUNCTION val_principal_tax_code(p_tax_code        IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_count number;

BEGIN
        if (p_tax_code is null) then
                return true;
        end if;
        select count(*)
        into l_count
        from xtr_tax_brokerage_setup a,
        fnd_lookups lu, xtr_tax_deduction_calcs c
        where a.deal_type = 'NI'
        and lu.lookup_type='XTR_TAX_CALC_TYPES'
        and lu.lookup_code=a.calc_type
        and a.deduction_type = 'T'
        and a.deal_type = c.deal_type
        and a.calc_type = c.calc_type
        and a.tax_settle_method = c.tax_settle_method
        and nvl(a.authorised, 'N') = 'Y'
        and c.principal_or_income_tax='P'
        and c.deal_subtype=g_ni_deal_subtype
        and a.reference_code=p_tax_code;

        return (l_count>0);
END val_principal_tax_code;

/*--------------------------------------------------------------------------------*/
FUNCTION val_interest_tax_code(p_tax_code        IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/
l_count number;

BEGIN
        if (p_tax_code is null) then
                return true;
        end if;
        select count(*)
        into l_count
        from xtr_tax_brokerage_setup a,
        fnd_lookups lu, xtr_tax_deduction_calcs c
        where a.deal_type = 'NI'
        and lu.lookup_type='XTR_TAX_CALC_TYPES'
        and lu.lookup_code=a.calc_type
        and a.deduction_type = 'T'
        and a.deal_type = c.deal_type
        and a.calc_type = c.calc_type
        and a.tax_settle_method = c.tax_settle_method
        and nvl(a.authorised, 'N') = 'Y'
        and c.principal_or_income_tax='I'
        and c.deal_subtype=g_ni_deal_subtype
        and a.reference_code=p_tax_code;

        return (l_count>0);
END val_interest_tax_code;


/*--------------------------------------------------------------------------------*/
FUNCTION val_interest  (p_company_code      IN varchar2,
                        p_cparty_code       IN varchar2,
                        p_deal_type         IN varchar2,
                        p_currency_code     IN varchar2,
                        p_int_amount        IN number,
                        p_original_amount   IN number) RETURN boolean IS
/*--------------------------------------------------------------------------------*/
/* -------------------------------------------------------------------
Tolerance check logic:
For each level, set the weight as the followings,
 company       --- waight 8 (null is waight 0)
 counter party --- waight 4 (null is waight 0)
 deal type     --- waight 2 (null is waight 0)
 currency code --- waight 1 (null is waight 0)

 From the matched interest tolerances,
 this procedure use the tolerance values of the highest total waight
--------------------------------------------------------------------*/

  l_total_weight        number :=0;
  l_limit_amount        number;
  l_amount_percent      number;
  l_currency            varchar2(15);
  l_tol_id              number; -- interest_tolerance_id for debug

  l_max_weight          number :=0;
  l_use_limit_amount    number;
  l_use_amount_percent  number;
  l_use_currency        varchar2(15);
  l_use_tol_id          number default null; -- interest_tolerance_id for debug

  l_function_currency   varchar2(15); -- company function currency
  l_rate                number:=1; -- conversino rate
  l_int_amount          number; -- The converted interest amount
  l_system_currency     varchar2(15); -- System Functional Currency

  l_allow_override	VARCHAR2(1);
  cursor get_allow_override is
  Select allow_override
  From Xtr_Dealer_Codes
  Where user_id = fnd_global.user_id;

  cursor chk_int_tol is
  select to_number(
         decode(it.company_code,null,0,8)
         + decode(it.cparty_code, null,0,4)
         + decode(it.deal_type, null,0,2)
         + decode(it.currency_code,null,0,1)) total_weight,
         it.limit_amount,
         it.amount_percent,
         it.currency_code,
         it.interest_tolerance_id
  from          xtr_interest_tolerances  it
  where  it.company_code = p_company_code
  and         nvl(it.cparty_code, p_cparty_code) = p_cparty_code
  and    nvl(it.deal_type, p_deal_type) = p_deal_type
  and    nvl(it.currency_code, p_currency_code) = p_currency_code
  and    authorized='Y';

  cursor sys_curr is
  select PARAM_VALUE
  from XTR_PRO_PARAM
  where param_name ='SYSTEM_FUNCTIONAL_CCY';

BEGIN

  l_int_amount := p_int_amount;

  if l_int_amount = p_original_amount then
    return true;
  end if;

  open get_allow_override;
  fetch get_allow_override into l_allow_override;
  close get_allow_override;

  if (NVL(l_allow_override,'N')<>'Y') then
    return false;
  end if;

  open sys_curr;
  fetch sys_curr into l_system_currency;
  close sys_curr;

  open chk_int_tol;
  LOOP
   fetch chk_int_tol into l_total_weight, l_limit_amount,l_amount_percent,l_currency,l_tol_id;

   EXIT WHEN chk_int_tol%NOTFOUND;
    if l_total_weight > l_max_weight then
        l_max_weight :=l_total_weight;
        l_use_limit_amount := l_limit_amount;
        l_use_amount_percent := l_amount_percent;
        l_use_currency := l_currency;
        l_use_tol_id := l_tol_id;
    end if;

  END LOOP;

  close chk_int_tol;

  -- Interest tolerances are not setup.
  if l_max_weight =0
     or (l_use_limit_amount is null and l_use_amount_percent is null)
  then
        return false;
  end if;

  if l_use_currency is null then

        select nvl(set_of_books_currency,l_system_currency)
        into l_function_currency
        from xtr_parties_v
        where party_code = p_company_code;

         if l_function_currency <> p_currency_code then
                xtr_fps2_p.currency_cross_rate(l_function_currency,
                                                 p_currency_code,
                                                 l_rate);

                if l_rate is null then
                  return false;
                else
                  if l_use_limit_amount is not null then
                        l_use_limit_amount := l_use_limit_amount * l_rate;
                  end if;
                end if;

        end if;
  end if;

  if l_use_limit_amount is not null then
        if abs(p_original_amount - l_int_amount) > l_use_limit_amount then
                return false;
        end if;
  end if;

  if l_use_amount_percent is not null then
        if abs(p_original_amount - l_int_amount)
                                > abs(p_original_amount*l_use_amount_percent/100) then
                return false;
        end if;
  end if;

  return true;
END val_interest;

/*--------------------------------------------------------------------------------*/
FUNCTION val_consideration(p_face_value        IN VARCHAR2,
                           p_consideration     IN VARCHAR2,
                           p_basis_type               IN VARCHAR2) return BOOLEAN is
/*--------------------------------------------------------------------------------*/

BEGIN
  if ((p_face_value is not null and p_consideration is not null) or (p_consideration is not null and p_basis_type='DISCOUNT')) then
    return false;
  end if;
  return true;
END val_consideration;

/*--------------------------------------------------------------------------------*/
FUNCTION val_serial_number(p_serial_number        IN VARCHAR2,
                           p_parcel_count         IN NUMBER) return BOOLEAN is
/*--------------------------------------------------------------------------------*/

l_count NUMBER;

BEGIN
  if (p_serial_number is null) then
    return true;
  end if;
  if (g_ni_deal_subtype<>'ISSUE') then
    return false;
  end if;
  if (p_parcel_count > 1) then
    return false;
  end if;
  select count(*)
  into   l_count
  from   xtr_bill_bond_issues_v
  where ni_or_bond='NI'
  and issue_date is null
  and status is null
  and serial_number=p_serial_number;

  return l_count>0;
END val_serial_number;


/* ------------- END FIELD VALIDATION SECTION ------------------------------------*/

PROCEDURE CHECK_ACCRUAL_REVAL(ARec_interface IN xtr_deals_interface%ROWTYPE) IS

		/*--------------------------------------------------------------------------------*/
		PROCEDURE CHK_TRANS_RATE(p_trans_rate        IN VARCHAR2,
					p_currency            IN VARCHAR2) is
		/*--------------------------------------------------------------------------------*/
		l_count number;
		l_tolerance number;
		v_err_code NUMBER(8);
		v_err_level VARCHAR2(2) := ' ';

		cursor get_tolerance is
			select tolerance
			from   xtr_deal_subtypes
			where  deal_type='NI'
			and    deal_subtype=g_ni_deal_subtype;

		BEGIN
			open get_tolerance;
			fetch get_tolerance into l_tolerance;
			if get_tolerance%NOTFOUND then
				close get_tolerance;
				XTR_IMPORT_DEAL_DATA.log_deal_warning(FND_MESSAGE.GET_STRING('XTR','XTR_598')); -- rate not within acceptable tolerance
				return;
			end if;
			close get_tolerance;

			XTR_FPS3_P.CHK_TOLERANCE(p_trans_rate,
					p_currency,
					l_tolerance,
					nvl(g_no_of_days,30),
					'%',
					v_err_code,
					v_err_level);

			if (v_err_code is not null) then
				XTR_IMPORT_DEAL_DATA.log_deal_warning(FND_MESSAGE.GET_STRING('XTR','XTR_598')); -- rate not within acceptable tolerance
			end if;
		END chk_trans_rate;


		PROCEDURE   CHK_RVL_DATE(P_COMPANY   IN  VARCHAR2) IS

			 cursor cur_date is
			 select PARAMETER_VALUE_CODE from XTR_COMPANY_PARAMETERS P
			 where  p.company_code = p_company
			 and    p.parameter_code = 'ACCNT_TSDTM';

			 l_date_type varchar2(30);
			 l_date      date;

			 cursor cur_reval(p_date in date) IS
			 SELECT count(*)
			 FROM
						 xtr_batches b,xtr_batch_events e
			 WHERE
						 b.company_code = p_company
			 AND   b.batch_id     = e.batch_id
			 AND   e.event_code   = 'REVAL'
			 AND   b.period_end   >= p_date;

			 l_dummy	number;
			 l_btn        number;
			 l_logMessage VARCHAR2(255);

		BEGIN
			Open cur_date;
			Fetch cur_date into l_date_type;
			Close cur_date;

					If l_date_type = 'TRADE' then
						 l_date := ARec_interface.DATE_A;  --DEAL_DATE
					Elsif  l_date_type = 'SETTLE' then
						 l_date := ARec_interface.DATE_B;  --START_DATE
					End If;

			Open cur_reval(l_date);
			Fetch cur_reval into l_dummy;

			If nvl(l_dummy,0) > 0 then
					FND_MESSAGE.Set_Name ('XTR', 'XTR_IMPORT_BEFORE_REVAL');
					FND_MESSAGE.Set_Token ('DATE',l_date);
					l_logMessage:=FND_MESSAGE.Get;
					XTR_IMPORT_DEAL_DATA.log_deal_warning(l_logMessage);
			End If;
		END;

		PROCEDURE   CHK_ACCRL_DATE(P_COMPANY   IN  VARCHAR2) IS

			 cursor cur_date is
			 select PARAMETER_VALUE_CODE from XTR_COMPANY_PARAMETERS P
			 where  p.company_code = p_company
			 and    p.parameter_code = 'ACCNT_TSDTM';

			 l_date_type varchar2(30);
			 l_date      date;

			 cursor cur_accrl(p_date in date) IS
			 SELECT count(*)
			 FROM
						 xtr_batches b,xtr_batch_events e
			 WHERE
						 b.company_code = p_company
			 AND   b.batch_id     = e.batch_id
			 AND   e.event_code   = 'ACCRUAL'
			 AND   b.period_end   >= p_date;

			 l_dummy	number;
			 l_btn        number;
                         l_logMessage VARCHAR2(255);
		BEGIN
			Open cur_date;
			Fetch cur_date into l_date_type;
			Close cur_date;

					If l_date_type = 'TRADE' then
						 l_date := ARec_interface.DATE_A;  --DEAL_DATE
					Elsif  l_date_type = 'SETTLE' then
						 l_date := ARec_interface.DATE_B;  --START_DATE
					End If;

			Open cur_accrl(l_date);
			Fetch cur_accrl into l_dummy;

			If nvl(l_dummy,0) > 0 then
					FND_MESSAGE.Set_Name ('XTR', 'XTR_IMPORT_BEFORE_ACCRUAL');
					FND_MESSAGE.Set_Token ('DATE',l_date);
					l_logMessage:=FND_MESSAGE.Get;
					XTR_IMPORT_DEAL_DATA.log_deal_warning(l_logMessage);
			End If;
		END;

BEGIN CHK_TRANS_RATE(ARec_interface.rate_a,ARec_interface.currency_a); -- bug 2798328
      CHK_ACCRL_DATE(ARec_interface.COMPANY_CODE);
      CHK_RVL_DATE(ARec_interface.COMPANY_CODE);
END CHECK_ACCRUAL_REVAL;


/* ------------- BEGIN DATA POPULATION SECTION -----------------------------------*/

/*------------------------------------------------------------------------------------------*/
PROCEDURE copy_from_interface_to_ni(ARec_Interface IN xtr_deals_interface%rowtype ) is
/*------------------------------------------------------------------------------------------*/

    CURSOR GET_RISKPARTY_CODE IS
      select a.cparty_code
      from   xtr_counterparty_limits_v a,
             xtr_limit_types_v b
      where  a.company_code = G_Ni_Main_Rec.company_code
      and   (a.cparty_code = G_Ni_Main_Rec.acceptor_code
             or a.cparty_code = G_Ni_Main_Rec.endorser_code
             or a.cparty_code = G_Ni_Main_Rec.drawer_code)
      and    a.limit_code <> 'SETTLE'
      and    a.limit_type  = b.limit_type
      and  ((fx_invest_fund_type in ('X','I') and G_Ni_Main_Rec.deal_subtype in ('BUY','COVER')) or
            (fx_invest_fund_type in ('X','F') and G_Ni_Main_Rec.deal_subtype in ('SELL','SHORT','ISSUE')))
      and    a.authorised='Y' and nvl(a.expiry_date,sysdate+1)>sysdate
      and    a.limit_code=G_Ni_Main_Rec.riskparty_limit_code
      and    rownum=1;

PROCEDURE COPY_TR_FROM_INTERFACE IS
    CURSOR GET_TRANSACTIONS IS
      SELECT *
      FROM   XTR_TRANSACTIONS_INTERFACE
      WHERE  EXTERNAL_DEAL_ID = ARec_Interface.external_deal_id
      AND    DEAL_TYPE = ARec_Interface.deal_type;


    i Number:=0;
BEGIN
    G_Ni_Parcel_Rec.DELETE;
    G_Ni_Trans_Flex.DELETE;

    for l_transactions in get_transactions loop
        i:=i+1;

        G_Ni_Parcel_Rec(i).DEAL_NO              := NULL;
        G_Ni_Parcel_Rec(i).PARCEL_SPLIT_NO      := l_transactions.TRANSACTION_NO; --This hack maintains a reference for interest overide errors and should be overwritten
        G_Ni_Parcel_Rec(i).PARCEL_SIZE          := l_transactions.AMOUNT_A;
        G_Ni_Parcel_Rec(i).FACE_VALUE_AMOUNT    := l_transactions.AMOUNT_B;
        G_Ni_Parcel_Rec(i).CONSIDERATION        := l_transactions.AMOUNT_C;
        G_Ni_Parcel_Rec(i).INTEREST             := l_transactions.AMOUNT_D;
        G_Ni_Parcel_Rec(i).STATUS_CODE          := 'CURRENT';
        G_Ni_Parcel_Rec(i).DEAL_SUBTYPE         := G_Ni_Deal_Subtype;
        G_Ni_Parcel_Rec(i).AVAILABLE_FOR_RESALE := l_transactions.OPTION_A;
        G_Ni_Parcel_Rec(i).PARCEL_REMAINING     := l_transactions.AMOUNT_A;
        G_Ni_Parcel_Rec(i).SELECT_NUMBER        := NULL;
        G_Ni_Parcel_Rec(i).SELECT_FV_AMOUNT     := NULL;
        G_Ni_Parcel_Rec(i).REFERENCE_NUMBER     := NULL;
        G_Ni_Parcel_Rec(i).RESERVE_PARCEL       := NULL;
        G_Ni_Parcel_Rec(i).OLD_SELECT_NUMBER    := NULL;
        G_Ni_Parcel_Rec(i).SERIAL_NUMBER        := l_transactions.VALUE_A;
        G_Ni_Parcel_Rec(i).SERIAL_NUMBER_IN     := NULL;
        G_Ni_Parcel_Rec(i).ISSUE_BANK           := NULL;
        G_Ni_Parcel_Rec(i).ORIGINAL_AMOUNT      := NULL;

        G_Ni_Trans_Flex(i).ATTRIBUTE_CATEGORY   := l_transactions.ATTRIBUTE_CATEGORY;
        G_Ni_Trans_Flex(i).ATTRIBUTE1           := l_transactions.ATTRIBUTE1;
        G_Ni_Trans_Flex(i).ATTRIBUTE2           := l_transactions.ATTRIBUTE2;
        G_Ni_Trans_Flex(i).ATTRIBUTE3           := l_transactions.ATTRIBUTE3;
        G_Ni_Trans_Flex(i).ATTRIBUTE4           := l_transactions.ATTRIBUTE4;
        G_Ni_Trans_Flex(i).ATTRIBUTE5           := l_transactions.ATTRIBUTE5;
        G_Ni_Trans_Flex(i).ATTRIBUTE6           := l_transactions.ATTRIBUTE6;
        G_Ni_Trans_Flex(i).ATTRIBUTE7           := l_transactions.ATTRIBUTE7;
        G_Ni_Trans_Flex(i).ATTRIBUTE8           := l_transactions.ATTRIBUTE8;
        G_Ni_Trans_Flex(i).ATTRIBUTE9           := l_transactions.ATTRIBUTE9;
        G_Ni_Trans_Flex(i).ATTRIBUTE10          := l_transactions.ATTRIBUTE10;
        G_Ni_Trans_Flex(i).ATTRIBUTE11          := l_transactions.ATTRIBUTE11;
        G_Ni_Trans_Flex(i).ATTRIBUTE12          := l_transactions.ATTRIBUTE12;
        G_Ni_Trans_Flex(i).ATTRIBUTE13          := l_transactions.ATTRIBUTE13;
        G_Ni_Trans_Flex(i).ATTRIBUTE14          := l_transactions.ATTRIBUTE14;
        G_Ni_Trans_Flex(i).ATTRIBUTE15          := l_transactions.ATTRIBUTE15;

    end loop;
    g_num_parcels:=i;
END COPY_TR_FROM_INTERFACE;

BEGIN
        G_Ni_Main_Rec.EXTERNAL_DEAL_ID          := NULL;
        G_Ni_Main_Rec.FREQUENCY                 := NULL;
        G_Ni_Main_Rec.DEAL_TYPE                 := NULL;
        G_Ni_Main_Rec.BROKERAGE_AMOUNT_HCE      := NULL;
        G_Ni_Main_Rec.TAX_AMOUNT_HCE            := NULL;
        G_Ni_Main_Rec.MATURITY_BALANCE_HCE_AMOUNT := NULL;
        G_Ni_Main_Rec.RISKPARTY_CODE            := NULL;
        G_Ni_Main_Rec.YEAR_BASIS                := NULL;
        G_Ni_Main_Rec.INTEREST_HCE_AMOUNT       := NULL;
        G_Ni_Main_Rec.START_HCE_AMOUNT          := NULL;
        G_Ni_Main_Rec.PORTFOLIO_AMOUNT          := NULL;
        G_Ni_Main_Rec.MATURITY_HCE_AMOUNT       := NULL;
        G_Ni_Main_Rec.PREMIUM_ACCOUNT_NO        := NULL;
        G_Ni_Main_Rec.NI_DEAL_NO                := NULL;
        G_Ni_Main_Rec.RENEG_DATE                := NULL;
        G_Ni_Main_Rec.DEAL_NO                   := NULL;
        G_Ni_Main_Rec.STATUS_CODE               := NULL;
        G_Ni_Main_Rec.DEALER_CODE               := NULL;
        G_Ni_Main_Rec.DEAL_DATE                 := NULL;
        G_Ni_Main_Rec.COMPANY_CODE              := NULL;
        G_Ni_Main_Rec.CPARTY_CODE               := NULL;
        G_Ni_Main_Rec.CLIENT_CODE               := NULL;
        G_Ni_Main_Rec.PORTFOLIO_CODE            := NULL;
        G_Ni_Main_Rec.KNOCK_TYPE                := NULL;
        G_Ni_Main_Rec.NI_PROFIT_LOSS            := NULL;
        G_Ni_Main_Rec.DEAL_SUBTYPE              := NULL;
        G_Ni_Main_Rec.PRODUCT_TYPE              := NULL;
        G_Ni_Main_Rec.CURRENCY                  := NULL;
        G_Ni_Main_Rec.YEAR_CALC_TYPE            := NULL;
        G_Ni_Main_Rec.START_DATE                := NULL;
        G_Ni_Main_Rec.MATURITY_DATE             := NULL;
        G_Ni_Main_Rec.NO_OF_DAYS                := NULL;
        G_Ni_Main_Rec.MATURITY_AMOUNT           := NULL;
        G_Ni_Main_Rec.MATURITY_BALANCE_AMOUNT   := NULL;
        G_Ni_Main_Rec.START_AMOUNT              := NULL;
        G_Ni_Main_Rec.CALC_BASIS                := NULL;
        G_Ni_Main_Rec.INTEREST_RATE             := NULL;
        G_Ni_Main_Rec.INTEREST_AMOUNT           := NULL;
        G_Ni_Main_Rec.ORIGINAL_AMOUNT           := NULL;
        G_Ni_Main_Rec.ROUNDING_TYPE             := NULL;
        G_Ni_Main_Rec.DAY_COUNT_TYPE            := NULL;
        G_Ni_Main_Rec.COMMENTS                  := NULL;
        G_Ni_Main_Rec.INTERNAL_TICKET_NO        := NULL;
        G_Ni_Main_Rec.EXTERNAL_COMMENTS         := NULL;
        G_Ni_Main_Rec.EXTERNAL_CPARTY_NO        := NULL;
        G_Ni_Main_Rec.MATURITY_ACCOUNT_NO       := NULL;
        G_Ni_Main_Rec.CPARTY_ACCOUNT_NO         := NULL;
        G_Ni_Main_Rec.CPARTY_REF                := NULL;
        G_Ni_Main_Rec.PRINCIPAL_SETTLED_BY      := NULL;
        G_Ni_Main_Rec.SECURITY_ID               := NULL;
        G_Ni_Main_Rec.MARGIN                    := NULL;
        G_Ni_Main_Rec.PRICING_MODEL             := NULL;
        G_Ni_Main_Rec.MARKET_DATA_SET           := NULL;
        G_Ni_Main_Rec.DEAL_LINKING_CODE         := NULL;
        G_Ni_Main_Rec.ACCEPTOR_CODE             := NULL;
        G_Ni_Main_Rec.ACCEPTOR_NAME             := NULL;
        G_Ni_Main_Rec.DRAWER_CODE               := NULL;
        G_Ni_Main_Rec.DRAWER_NAME               := NULL;
        G_Ni_Main_Rec.ENDORSER_CODE             := NULL;
        G_Ni_Main_Rec.ENDORSER_NAME             := NULL;
        G_Ni_Main_Rec.RISKPARTY_LIMIT_CODE      := NULL;
        G_Ni_Main_Rec.TAX_CODE                  := NULL;
        G_Ni_Main_Rec.TAX_RATE                  := NULL;
        G_Ni_Main_Rec.TAX_AMOUNT                := NULL;
        G_Ni_Main_Rec.TAX_SETTLED_REFERENCE     := NULL;
        G_Ni_Main_Rec.INCOME_TAX_CODE           := NULL;
        G_Ni_Main_Rec.INCOME_TAX_RATE           := NULL;
        G_Ni_Main_Rec.INCOME_TAX_AMOUNT         := NULL;
        G_Ni_Main_Rec.INCOME_TAX_SETTLED_REF    := NULL;
        G_Ni_Main_Rec.ATTRIBUTE_CATEGORY        := NULL;
        G_Ni_Main_Rec.ATTRIBUTE1                := NULL;
        G_Ni_Main_Rec.ATTRIBUTE2                := NULL;
        G_Ni_Main_Rec.ATTRIBUTE3                := NULL;
        G_Ni_Main_Rec.ATTRIBUTE4                := NULL;
        G_Ni_Main_Rec.ATTRIBUTE5                := NULL;
        G_Ni_Main_Rec.ATTRIBUTE6                := NULL;
        G_Ni_Main_Rec.ATTRIBUTE7                := NULL;
        G_Ni_Main_Rec.ATTRIBUTE8                := NULL;
        G_Ni_Main_Rec.ATTRIBUTE9                := NULL;
        G_Ni_Main_Rec.ATTRIBUTE10               := NULL;
        G_Ni_Main_Rec.ATTRIBUTE11               := NULL;
        G_Ni_Main_Rec.ATTRIBUTE12               := NULL;
        G_Ni_Main_Rec.ATTRIBUTE13               := NULL;
        G_Ni_Main_Rec.ATTRIBUTE14               := NULL;
        G_Ni_Main_Rec.ATTRIBUTE15               := NULL;



       /*--------------------------------------------*/
       /* Copying values into the Global Record Type */
       /*--------------------------------------------*/
        select xtr_deals_s.nextval
        into G_Ni_Main_Rec.DEAL_NO
        from   dual;

        G_Ni_Main_Rec.EXTERNAL_DEAL_ID      :=         ARec_Interface.EXTERNAL_DEAL_ID;
        G_Ni_Main_Rec.DEAL_TYPE             :=         G_Ni_Deal_Type;
        G_Ni_Main_Rec.DEALER_CODE           :=         ARec_Interface.DEALER_CODE;
        G_Ni_Main_Rec.COMPANY_CODE          :=         ARec_Interface.COMPANY_CODE;
        G_Ni_Main_Rec.CPARTY_CODE           :=         ARec_Interface.CPARTY_CODE;
        G_Ni_Main_Rec.CLIENT_CODE           :=         ARec_Interface.CLIENT_CODE;
        G_Ni_Main_Rec.PORTFOLIO_CODE        :=         ARec_Interface.PORTFOLIO_CODE;
        G_Ni_Main_Rec.DEAL_SUBTYPE          :=         G_Ni_Deal_Subtype;
        G_Ni_Main_Rec.PRODUCT_TYPE          :=         ARec_Interface.PRODUCT_TYPE;
        G_Ni_Main_Rec.YEAR_CALC_TYPE        :=         ARec_Interface.YEAR_CALC_TYPE;
        G_Ni_Main_Rec.DEAL_DATE             :=         ARec_Interface.DATE_A;
        G_Ni_Main_Rec.START_DATE            :=         ARec_Interface.DATE_B;
        G_Ni_Main_Rec.MATURITY_DATE         :=         ARec_Interface.DATE_C;
        G_Ni_Main_Rec.CALC_BASIS            :=         ARec_Interface.BASIS_TYPE;
        G_Ni_Main_Rec.ROUNDING_TYPE         :=         ARec_Interface.ROUNDING_TYPE;
        G_Ni_Main_Rec.DAY_COUNT_TYPE        :=         ARec_Interface.DAY_COUNT_TYPE;
        G_Ni_Main_Rec.CURRENCY              :=         ARec_Interface.CURRENCY_A;
        G_Ni_Main_Rec.NO_OF_DAYS            :=         g_no_of_days;
        G_Ni_Main_Rec.YEAR_BASIS            :=         g_year_basis;
        G_Ni_Main_Rec.MARGIN                :=         ARec_Interface.AMOUNT_A;
        G_Ni_Main_Rec.MATURITY_ACCOUNT_NO   :=         ARec_Interface.ACCOUNT_NO_A;
        G_Ni_Main_Rec.INTEREST_RATE         :=         ARec_Interface.RATE_A;
        G_Ni_Main_Rec.COMMENTS              :=         ARec_Interface.COMMENTS;
        G_Ni_Main_Rec.EXTERNAL_COMMENTS     :=         ARec_Interface.EXTERNAL_COMMENTS ;
        G_Ni_Main_Rec.INTERNAL_TICKET_NO    :=         ARec_Interface.INTERNAL_TICKET_NO;
        G_Ni_Main_Rec.EXTERNAL_CPARTY_NO    :=         ARec_Interface.EXTERNAL_CPARTY_NO;
        G_Ni_Main_Rec.CPARTY_ACCOUNT_NO     :=         ARec_Interface.CPARTY_ACCOUNT_NO;
        G_Ni_Main_Rec.CPARTY_REF            :=         NULL; --bug 3034164
        G_Ni_Main_Rec.PRINCIPAL_SETTLED_BY  :=         ARec_Interface.SETTLE_ACTION_REQD;
        G_Ni_Main_Rec.SECURITY_ID           :=         ARec_Interface.SECURITY_ID;
        G_Ni_Main_Rec.PRICING_MODEL         :=         ARec_Interface.PRICING_MODEL;
        G_Ni_Main_Rec.MARKET_DATA_SET       :=         ARec_Interface.MARKET_DATA_SET;
        G_Ni_Main_Rec.DEAL_LINKING_CODE     :=         ARec_Interface.DEAL_LINKING_CODE;
        G_Ni_Main_Rec.ACCEPTOR_CODE         :=         ARec_Interface.ACCEPTOR_CODE;
        G_Ni_Main_Rec.DRAWER_CODE           :=         ARec_Interface.DRAWER_CODE;
        G_Ni_Main_Rec.ENDORSER_CODE         :=         ARec_Interface.ENDORSER_CODE;
        G_Ni_Main_Rec.RISKPARTY_LIMIT_CODE  :=         ARec_Interface.LIMIT_CODE;

        if G_Ni_Main_Rec.RISKPARTY_LIMIT_CODE is not null then
           open get_riskparty_code;
           fetch get_riskparty_code into G_Ni_Main_Rec.RISKPARTY_CODE;
           close get_riskparty_code;
        end if;

        if ARec_Interface.BROKERAGE_CODE is not null then
           G_Ni_Main_Rec.BROKERAGE_CODE     :=         ARec_Interface.BROKERAGE_CODE;
           G_Ni_Main_Rec.BROKERAGE_RATE     :=         ARec_Interface.RATE_C;
           G_NI_Main_Rec.BROKERAGE_AMOUNT   :=         ARec_Interface.AMOUNT_C;
           G_Ni_Main_Rec.BROKERAGE_CURRENCY :=         ARec_Interface.BROKERAGE_CURRENCY;
        else
           G_Ni_Main_Rec.BROKERAGE_CODE     :=         null;
           G_Ni_Main_Rec.BROKERAGE_RATE     :=         null;
           G_NI_Main_Rec.BROKERAGE_AMOUNT   :=         null;
           G_Ni_Main_Rec.BROKERAGE_CURRENCY :=         null;
        end if;

        G_Ni_Main_Rec.TAX_CODE              :=         ARec_Interface.SCHEDULE_A;
        --G_Ni_Main_Rec.TAX_RATE              :=         Calculated
        --G_Ni_Main_Rec.TAX_AMOUNT            :=         Calculated
        --G_Ni_Main_Rec.TAX_SETTLED_REFERENCE :=         Calculated
        G_Ni_Main_Rec.INCOME_TAX_CODE       :=         ARec_Interface.SCHEDULE_B;
        --G_Ni_Main_Rec.INCOME_TAX_RATE       :=         Calculated
        --G_Ni_Main_Rec.INCOME_TAX_AMOUNT     :=         Calculated
        --G_Ni_Main_Rec.INCOME_TAX_SETTLED_REF:=         Calculated

        if (ARec_Interface.OPTION_A='Y') then
           G_DO_TAX_DEFAULTING:=true;
        else
           G_DO_TAX_DEFAULTING:=false;
        end if;

        G_Ni_Main_Rec.DUAL_AUTHORISATION_BY :=         ARec_Interface.DUAL_AUTHORIZATION_BY;
        G_Ni_Main_Rec.DUAL_AUTHORISATION_ON :=         ARec_Interface.DUAL_AUTHORIZATION_ON;
        G_Ni_Main_Rec.STATUS_CODE           :=         'CURRENT';
        G_Ni_Main_Rec.KNOCK_TYPE            :=         'N';

        /*--------------------------------------------------------------------*/
        /*                Flexfields will be implemented in Patchset G.       */
        /*--------------------------------------------------------------------*/
        G_Ni_Main_Rec.ATTRIBUTE_CATEGORY    :=         ARec_Interface.ATTRIBUTE_CATEGORY;
        G_Ni_Main_Rec.ATTRIBUTE1            :=         ARec_Interface.ATTRIBUTE1;
        G_Ni_Main_Rec.ATTRIBUTE2            :=         ARec_Interface.ATTRIBUTE2;
        G_Ni_Main_Rec.ATTRIBUTE3            :=         ARec_Interface.ATTRIBUTE3;
        G_Ni_Main_Rec.ATTRIBUTE4            :=         ARec_Interface.ATTRIBUTE4;
        G_Ni_Main_Rec.ATTRIBUTE5            :=         ARec_Interface.ATTRIBUTE5;
        G_Ni_Main_Rec.ATTRIBUTE6            :=         ARec_Interface.ATTRIBUTE6;
        G_Ni_Main_Rec.ATTRIBUTE7            :=         ARec_Interface.ATTRIBUTE7;
        G_Ni_Main_Rec.ATTRIBUTE8            :=         ARec_Interface.ATTRIBUTE8;
        G_Ni_Main_Rec.ATTRIBUTE9            :=         ARec_Interface.ATTRIBUTE9;
        G_Ni_Main_Rec.ATTRIBUTE10           :=         ARec_Interface.ATTRIBUTE10;
        G_Ni_Main_Rec.ATTRIBUTE11           :=         ARec_Interface.ATTRIBUTE11;
        G_Ni_Main_Rec.ATTRIBUTE12           :=         ARec_Interface.ATTRIBUTE12;
        G_Ni_Main_Rec.ATTRIBUTE13           :=         ARec_Interface.ATTRIBUTE13;
        G_Ni_Main_Rec.ATTRIBUTE14           :=         ARec_Interface.ATTRIBUTE14;
        G_Ni_Main_Rec.ATTRIBUTE15           :=         ARec_Interface.ATTRIBUTE15;

        COPY_TR_FROM_INTERFACE;

END copy_from_interface_to_ni;

/*------------------------------------------------------------*/
/*   The following code implements the calc_rates process     */
/*------------------------------------------------------------*/
PROCEDURE CALC_RATES(ARec_Interface    IN XTR_DEALS_INTERFACE%ROWTYPE,
                     error OUT NOCOPY boolean) is

l_bkr_amt_type              varchar2(30);
l_dummy_char                varchar2(30);

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

--rvallams bug 2383157 begin

   /*--------------------------------------------------------------------------------------------*/
   /* Store the amounts rounded as per the precision of the currency                             */
   /*--------------------------------------------------------------------------------------------*/
   /*
   if error <> TRUE then

      --WDK: do we need any rounding?

      open rnd(G_Ni_Main_Rec.currency);
      fetch rnd into roundfac;
      close rnd;
      G_Ni_Main_Rec.buy_amount := round(G_Ni_Main_Rec.buy_amount,roundfac);


   end if;
   */
--rvallams bug 2383157 end


   /*--------------------------------------------------------------------------------------------*/
   /* This process calculates all of the splits secondary data and total values                  */
   /*--------------------------------------------------------------------------------------------*/
   if error <> TRUE then
      CALC_TOTAL_SPLITS(ARec_Interface.deal_type, error);
   end if;

   /*--------------------------------------------------------------------------------------------*/
   /* This process checks brokerage values.                                                      */
   /*--------------------------------------------------------------------------------------------*/
   if error <> TRUE then
      xtr_fps2_p.tax_brokerage_amt_type(G_NI_Deal_Type,
                                        G_Ni_Main_Rec.brokerage_code,
                                        null,
                                        l_bkr_amt_type,
                                        l_dummy_char);
      if  G_Ni_Main_Rec.brokerage_code is not null then
          if ARec_Interface.amount_c is null then
             CALC_BROKERAGE_AMT(ARec_Interface.deal_type, l_bkr_amt_type, error);
          end if;

          if G_Ni_Main_Rec.brokerage_amount is not null and G_Ni_Main_Rec.brokerage_currency is null then
             G_Ni_Main_Rec.brokerage_currency := ARec_Interface.currency_a;
          end if;

      end if;
   end if;

   if error <> TRUE then
      CALC_HCE_AMOUNTS(ARec_Interface.deal_type, error);
   end if;


end CALC_RATES;


/*  Local Procedure to maintain totals of Multiple 'Split Block' */
/*--------------------------------------------------------------------------------*/
PROCEDURE CALC_TOTAL_SPLITS(p_user_deal_type  in VARCHAR2,p_error OUT NOCOPY boolean) is
/*--------------------------------------------------------------------------------*/


   cursor HCE is
   select nvl(m.HCE_RATE,1)
   from   xtr_MASTER_CURRENCIES_v m
   where  m.CURRENCY   =  G_Ni_Main_Rec.CURRENCY;

   cursor RND_FAC is
   select m.ROUNDING_FACTOR
   from   xtr_PARTIES_v p,
          xtr_MASTER_CURRENCIES_v m
   where  p.PARTY_CODE = G_Ni_Main_Rec.COMPANY_CODE
   and    p.PARTY_TYPE = 'C'
   and    m.CURRENCY   =  p.HOME_CURRENCY;

   type CONSIDERATION_TYPE is table of number index by binary_integer;
   type FACE_VALUE_AMOUNT_TYPE is table of number index by binary_integer;
   type INTEREST_TYPE is table of number index by binary_integer;
   type ORIGINAL_AMOUNT_TYPE is table of number index by binary_integer;
   V_CONSIDERATION        CONSIDERATION_TYPE;
   V_FACE_VALUE_AMOUNT        FACE_VALUE_AMOUNT_TYPE;
   V_INTEREST        INTEREST_TYPE;
   V_ORIGINAL_AMOUNT        ORIGINAL_AMOUNT_TYPE;

   L_ROUNDING_FACTOR XTR_MASTER_CURRENCIES_V.ROUNDING_FACTOR%TYPE;

   G_TOTAL_SIZE                 NUMBER := 0;
   G_TOTAL_FACE_VALUE_AMOUNT    NUMBER := 0;
   G_TOTAL_CONSIDERATION        NUMBER := 0;
   G_TOTAL_INTEREST             NUMBER := 0;
   G_TOTAL_ORIGINAL_AMOUNT      NUMBER := 0; --Add Interest Override
   G_TOTAL_SIZE_REMAINING       NUMBER := 0;
   G_TOTAL_PRN_TAX_AMOUNT       NUMBER := 0;
   G_TOTAL_INT_TAX_AMOUNT       NUMBER := 0;
   G_HC_RATE                    NUMBER := 0;

   v_dummy_num                  NUMBER;

/*------ Start Calc_Total_Splits local procedure ------*/

        /*  Local Procedure to calculate interest on discount basis to derive
            start amount. */
        /*--------------------------------------------------------------------------------*/
        PROCEDURE CALC_START_AMOUNT is
        /*--------------------------------------------------------------------------------*/
            l_interest_amount NUMBER :=NULL;
        BEGIN
                if G_Ni_Main_Rec.CALC_BASIS = 'YIELD' then
                      XTR_fps2_P.DISCOUNT_INTEREST_CALC(G_Ni_Main_Rec.YEAR_BASIS,
                              G_Ni_Main_Rec.MATURITY_AMOUNT,
                              G_Ni_Main_Rec.INTEREST_RATE,
                              G_Ni_Main_Rec.NO_OF_DAYS,
                              L_ROUNDING_FACTOR,
                              l_interest_amount,  -- Add Interest Override
                              G_Ni_Main_Rec.ROUNDING_TYPE);  -- Add Interest Override
                else
                      XTR_fps2_P.INTEREST_CALCULATOR(G_Ni_Main_Rec.YEAR_BASIS,
                              G_Ni_Main_Rec.MATURITY_AMOUNT,
                              G_Ni_Main_Rec.INTEREST_RATE,
                              G_Ni_Main_Rec.NO_OF_DAYS,
                              L_ROUNDING_FACTOR,
                              l_interest_amount, -- Add Interest Override
                              G_Ni_Main_Rec.ROUNDING_TYPE);  -- Add Interest Override
                end if;
                G_Ni_Main_Rec.ORIGINAL_AMOUNT := l_interest_amount;
                G_Ni_Main_Rec.INTEREST_AMOUNT := G_Ni_Main_Rec.ORIGINAL_AMOUNT;
                G_Ni_Main_Rec.START_AMOUNT    := G_Ni_Main_Rec.MATURITY_AMOUNT - G_Ni_Main_Rec.INTEREST_AMOUNT;
        END CALC_START_AMOUNT;




        /*  Local Procedure to calculate interest on yield basis to derive
                        face value amount for multiple splits.*/
        /*--------------------------------------------------------------------------------*/
        PROCEDURE CALC_FACE_VALUE_AMOUNT(p_parcel_num in Number) is
         j Number:=p_parcel_num;
        /*--------------------------------------------------------------------------------*/
        BEGIN
                XTR_FPS2_P.INTEREST_CALCULATOR(G_Ni_Main_Rec.YEAR_BASIS,
                                               G_Ni_Parcel_Rec(j).CONSIDERATION,
                                               G_Ni_Main_Rec.INTEREST_RATE,
                                               G_Ni_Main_Rec.NO_OF_DAYS,
                                               L_ROUNDING_FACTOR,
                                               G_Ni_Parcel_Rec(j).ORIGINAL_AMOUNT, -- Add Interest Override
                                               G_Ni_Main_Rec.ROUNDING_TYPE);      -- Add Interest Override

                IF (G_Ni_Parcel_Rec(j).INTEREST is NULL) then
                  G_Ni_Parcel_Rec(j).INTEREST := G_Ni_Parcel_Rec(j).ORIGINAL_AMOUNT; -- Add Interest Override
                END IF;

                G_Ni_Parcel_Rec(j).FACE_VALUE_AMOUNT := G_Ni_Parcel_Rec(j).CONSIDERATION + G_Ni_Parcel_Rec(j).INTEREST;
                --G_Ni_Parcel_Rec(j).CONSIDERATION := nvl(G_Ni_Parcel_Rec(j).FACE_VALUE_AMOUNT,0) - nvl(G_Ni_Parcel_Rec(j).INTEREST,0);

        END CALC_FACE_VALUE_AMOUNT;

        /*  Local Procedure to calculate interest on discount basis to derive
                        consideration amounts for multiple splits. */
        /*--------------------------------------------------------------------------------*/
        PROCEDURE CALC_CONSIDERATION(p_parcel_num in Number) is
         j Number:=p_parcel_num;
        /*--------------------------------------------------------------------------------*/
        BEGIN
         if nvl(G_Ni_Main_Rec.CALC_BASIS,'YIELD') = 'YIELD' then

                        XTR_FPS2_P.DISCOUNT_INTEREST_CALC(G_Ni_Main_Rec.YEAR_BASIS,
                                                          G_Ni_Parcel_Rec(j).FACE_VALUE_AMOUNT,
                                                          G_Ni_Main_Rec.INTEREST_RATE,
                                                          G_Ni_Main_Rec.NO_OF_DAYS,
                                                          L_ROUNDING_FACTOR,
                                                          G_Ni_Parcel_Rec(j).ORIGINAL_AMOUNT, --Add Interest Override
                                                          G_Ni_Main_Rec.ROUNDING_TYPE);     --Add Interest Override

                        IF (G_Ni_Parcel_Rec(j).INTEREST is NULL) then
                          G_Ni_Parcel_Rec(j).INTEREST := G_Ni_Parcel_Rec(j).ORIGINAL_AMOUNT;   --Add Interest Override
                        END IF;

         else
                        XTR_FPS2_P.INTEREST_CALCULATOR(G_Ni_Main_Rec.YEAR_BASIS,
                                                          G_Ni_Parcel_Rec(j).FACE_VALUE_AMOUNT,
                                                          G_Ni_Main_Rec.INTEREST_RATE,
                                                          G_Ni_Main_Rec.NO_OF_DAYS,
                                                          L_ROUNDING_FACTOR,
                                                          G_Ni_Parcel_Rec(j).ORIGINAL_AMOUNT, --Add Interest Override
                                                          G_Ni_Main_Rec.ROUNDING_TYPE);      --Add Interest Override
                        IF (G_Ni_Parcel_Rec(j).INTEREST is NULL) then
                          G_Ni_Parcel_Rec(j).INTEREST := G_Ni_Parcel_Rec(j).ORIGINAL_AMOUNT; --Add Interest Override
                        END IF;
         end if;

         G_Ni_Parcel_Rec(j).CONSIDERATION       := nvl(G_Ni_Parcel_Rec(j).FACE_VALUE_AMOUNT,0) - nvl(G_Ni_Parcel_Rec(j).INTEREST,0);
        END CALC_CONSIDERATION;





        /*--------------------------------------------------------------------------------*/
        PROCEDURE DEFAULT_TAX_CODES IS
        /*--------------------------------------------------------------------------------*/
           v_dummy_num NUMBER;
           v_dummy_char VARCHAR2(30);
        --
        BEGIN

           if G_Ni_Main_Rec.cparty_code is not null and G_Ni_Main_Rec.deal_subtype is not null and
           G_Ni_Main_Rec.product_type is not null then
              --Principal Tax
              if G_Ni_Main_Rec.tax_code is null then
                 xtr_fps2_p.TAX_BROKERAGE_DEFAULTING('NI',
                                   G_NI_DEAL_SUBTYPE,
                                   G_Ni_Main_Rec.PRODUCT_TYPE,
                                   nvl(G_Ni_Main_Rec.CLIENT_CODE,G_Ni_Main_Rec.CPARTY_CODE),
                                   G_Ni_Main_Rec.PRINCIPAL_SETTLED_BY,
                                   v_dummy_char,
                                   G_Ni_Main_Rec.TAX_CODE,
                                   v_dummy_char,
                                   G_Ni_Main_Rec.CURRENCY,
                                   v_dummy_char,
                                   v_dummy_char,
                                   v_dummy_char,
                                   v_dummy_char);
              end if;
              --Interest Tax
              if G_Ni_Main_Rec.income_tax_code is null then
                 xtr_fps2_p.TAX_BROKERAGE_DEFAULTING('NI',
                                   G_NI_DEAL_SUBTYPE,
                                   G_Ni_Main_Rec.PRODUCT_TYPE,
                                   nvl(G_Ni_Main_Rec.CLIENT_CODE,G_Ni_Main_Rec.CPARTY_CODE),
                                   v_dummy_char,
                                   v_dummy_char,
                                   v_dummy_char,
                                   G_Ni_Main_Rec.INCOME_TAX_CODE,
                                   G_Ni_Main_Rec.CURRENCY,
                                   v_dummy_char,
                                   v_dummy_char,
                                   v_dummy_char,
                                   v_dummy_char);
              end if;
           end if;
        END DEFAULT_TAX_CODES;






        /*  Local Procedure to calculate tax for the parcels. */
        /*--------------------------------------------------------------------------------*/
				PROCEDURE CALC_TAX_AMT(p_consideration NUMBER,
						p_maturity_amt NUMBER,
						p_interest NUMBER,
						p_start_date DATE,
						p_year_basis NUMBER,
						p_no_of_days NUMBER,
						p_ccy VARCHAR2,
						p_prn_tax_calc_type VARCHAR2,
						p_prn_tax_code VARCHAR2,
						p_int_tax_code VARCHAR2,
						p_prn_tax_amt OUT NOCOPY NUMBER,
						p_int_tax_amt OUT NOCOPY NUMBER,
						p_prn_tax_rate OUT NOCOPY NUMBER,
						p_int_tax_rate OUT NOCOPY NUMBER) IS
        /*--------------------------------------------------------------------------------*/

					 v_prn_amt NUMBER;
					 v_dummy_num NUMBER;

				BEGIN
					 --Principal Tax
					 if p_prn_tax_code is not null then
							if p_prn_tax_calc_type in ('CON_A','CON_F') then
								 v_prn_amt := p_consideration;
							else
								 v_prn_amt := p_maturity_amt;
							end if;
							--calculate principal tax
							xtr_fps1_p.CALC_TAX_AMOUNT('NI',
																 p_start_date,
																 p_prn_tax_code,
																 null,
																 p_ccy,
																 null,
																 p_year_basis,
																 p_no_of_days,
																 v_prn_amt,
																 p_prn_tax_rate,
																 null,
																 v_dummy_num,
																 p_prn_tax_amt,
																 v_dummy_num,
																 v_dummy_num,
																 v_dummy_num);
					 end if;
					 --Interest Tax
					 if p_int_tax_code is not null then
							--calculate interest tax
							xtr_fps1_p.CALC_TAX_AMOUNT('NI',
																 p_start_date,
																 null,
																 p_int_tax_code,
																 p_ccy,
																 null,
																 p_year_basis,
																 p_no_of_days,
																 null,
																 v_dummy_num,
																 p_interest,
																 p_int_tax_rate,
																 v_dummy_num,
																 p_int_tax_amt,
																 v_dummy_num,
																 v_dummy_num);
					 end if;

				END CALC_TAX_AMT;


























        /*--------------------------------------------------------------------------------*/
				PROCEDURE GET_TAX_INFO
        /*--------------------------------------------------------------------------------*/
						 IS
				--
					 cursor get_tax_info(p_tax_code VARCHAR2) is
							select tax_settle_method,calc_type
							from xtr_tax_brokerage_setup_v
							where reference_code = p_tax_code;
				--
					 cursor get_tax_codes(p_deal_no NUMBER) is
							select tax_code,income_tax_code from xtr_deals
							where deal_no=p_deal_no;
				--
				BEGIN
				      g_prn_tax_settle_method:=null;
				      g_prn_tax_calc_type:=null;
				      g_int_tax_settle_method:=null;
				      g_int_tax_calc_type:=null;
							if (G_Ni_Main_Rec.tax_code is null) then
								G_Ni_Main_Rec.tax_rate:=null;
								G_Ni_Main_Rec.tax_amount:=null;
							else
								open get_tax_info(G_Ni_Main_Rec.tax_code);
								fetch get_tax_info into G_PRN_TAX_SETTLE_METHOD,G_PRN_TAX_CALC_TYPE;
								close get_tax_info;
							end if;
							if (G_Ni_Main_Rec.income_tax_code is null) then
								G_Ni_Main_Rec.income_tax_rate:=null;
								G_Ni_Main_Rec.income_tax_amount:=null;
							else
								open get_tax_info(G_Ni_Main_Rec.income_tax_code);
								fetch get_tax_info into G_INT_TAX_SETTLE_METHOD,G_INT_TAX_CALC_TYPE;
								close get_tax_info;
							end if;
				END GET_TAX_INFO;











        /*--------------------------------------------------------------------------------*/
				FUNCTION TAX_ROUNDING(p_ccy VARCHAR2,
        /*--------------------------------------------------------------------------------*/
						p_tax_code VARCHAR2,
						p_number NUMBER)
				RETURN NUMBER IS
				--
					 cursor RND_FAC(p_ccy VARCHAR2) is
					 select nvl(m.ROUNDING_FACTOR,2)
					 from   xtr_MASTER_CURRENCIES_v m
					 where  m.CURRENCY   =  p_ccy;
				--
					 cursor get_rounding_rules(p_tax_code VARCHAR2) is
							select tax_rounding_rule,tax_rounding_precision
							from XTR_TAX_BROKERAGE_SETUP
							where reference_code=p_tax_code;
				--
					 v_rounding_rule VARCHAR2(1);
					 v_rounding_precision VARCHAR2(20);
					 v_rnd_fac NUMBER;
					 v_number NUMBER;
				--
				BEGIN
					 if p_number is not null and p_ccy is not null
					 and p_tax_code is not null then
							open get_rounding_rules(p_tax_code);
							fetch get_rounding_rules into
								 v_rounding_rule,v_rounding_precision;
							close get_rounding_rules;
							v_rnd_fac := xtr_fps1_p.get_tax_round_factor
									(v_rounding_precision,p_ccy);
							v_number := xtr_fps2_p.interest_round(p_number,v_RND_FAC,
									v_rounding_rule);
							return v_number;
					 else
							return null;
					 end if;
				END TAX_ROUNDING;











/*------ End Calc_Total_Splits local procedure ------*/
begin

   p_error := false;

   open HCE;
   fetch HCE INTO G_HC_RATE;
   if HCE%NOTFOUND then
      xtr_import_deal_data.log_interface_errors(G_Ni_Main_Rec.External_Deal_Id,p_user_deal_type,
                                                'CurrencyA','XTR_886');  -- Unable to find spot rate data
      p_error:=true;
   end if;
   close HCE;

   open RND_FAC;
   fetch RND_FAC INTO L_ROUNDING_FACTOR;
   if RND_FAC%NOTFOUND then
      xtr_import_deal_data.log_interface_errors(G_Ni_Main_Rec.External_Deal_Id,p_user_deal_type,
                                             'CompanyCode','XTR_880');--Unable to find home currency data
      p_error:=true;
   end if;
   close RND_FAC;

 if not(p_error) then

   /* Clear any old values and tables */


   G_FV_AMT_HCE.DELETE;
   G_INTEREST_HCE.DELETE;
   G_PRN_TAX_AMOUNT.DELETE;
   G_INT_TAX_AMOUNT.DELETE;


   if (G_DO_TAX_DEFAULTING) then
     DEFAULT_TAX_CODES;
   end if;

   GET_TAX_INFO;

   CALC_START_AMOUNT;

   for i in 1..g_num_parcels loop


      if (G_Ni_Parcel_Rec(i).FACE_VALUE_AMOUNT is not null) then
              CALC_CONSIDERATION(i);
      else
              CALC_FACE_VALUE_AMOUNT(i);
      end if;

      if not ( val_interest(G_Ni_Main_Rec.company_code,
                     G_Ni_Main_Rec.cparty_code,
                     G_Ni_Deal_type,
                     G_Ni_Main_Rec.currency,
                     G_Ni_Parcel_Rec(i).interest,
                     G_Ni_Parcel_Rec(i).original_amount)) then
        xtr_import_deal_data.log_interface_errors( G_Ni_Main_Rec.External_Deal_Id,
                                               p_user_deal_type,
                                               'AmountD',
                                               'XTR_INV_INTEREST',
                                               G_Ni_Parcel_Rec(i).parcel_split_no);  --This value temporarily holds the interface transaction_no
        p_error := true;
      end if;


      CALC_TAX_AMT(G_Ni_Parcel_Rec(i).consideration,
                   G_Ni_Parcel_Rec(i).face_value_amount,
                   G_Ni_Parcel_Rec(i).interest,
                   G_Ni_Main_Rec.start_date,
                   G_Ni_Main_Rec.year_basis,
                   G_Ni_Main_Rec.no_of_days,
                   null,
                   g_prn_tax_calc_type,
                   G_Ni_Main_Rec.tax_code,
                   G_Ni_Main_Rec.income_tax_code,
                   g_prn_tax_amount(i),
                   g_int_tax_amount(i),
                   G_Ni_Main_Rec.tax_rate,
                   G_Ni_Main_Rec.income_tax_rate);


      G_FV_AMT_HCE(i)   := round(G_Ni_Parcel_Rec(i).FACE_VALUE_AMOUNT / G_HC_RATE,L_ROUNDING_FACTOR);
      G_INTEREST_HCE(i) := round(G_Ni_Parcel_Rec(i).INTEREST / G_HC_RATE,L_ROUNDING_FACTOR);

      V_CONSIDERATION(i)     := G_Ni_Parcel_Rec(i).PARCEL_SIZE * G_Ni_Parcel_Rec(i).CONSIDERATION;
      V_FACE_VALUE_AMOUNT(i) := G_Ni_Parcel_Rec(i).PARCEL_SIZE * G_Ni_Parcel_Rec(i).FACE_VALUE_AMOUNT;
      V_INTEREST(i)          := G_Ni_Parcel_Rec(i).PARCEL_SIZE * G_Ni_Parcel_Rec(i).INTEREST;
      V_ORIGINAL_AMOUNT(i)   := G_Ni_Parcel_Rec(i).PARCEL_SIZE * G_Ni_Parcel_Rec(i).ORIGINAL_AMOUNT;

      G_TOTAL_CONSIDERATION     := G_TOTAL_CONSIDERATION+NVL(V_CONSIDERATION(i),0);
      G_TOTAL_FACE_VALUE_AMOUNT := G_TOTAL_FACE_VALUE_AMOUNT+NVL(V_FACE_VALUE_AMOUNT(i),0);
      G_TOTAL_INTEREST          := G_TOTAL_INTEREST+NVL(V_INTEREST(i),0);
      G_TOTAL_ORIGINAL_AMOUNT   := G_TOTAL_ORIGINAL_AMOUNT+NVL(V_ORIGINAL_AMOUNT(i),0);

      G_TOTAL_SIZE              := nvl(G_TOTAL_SIZE,0) + nvl(G_Ni_Parcel_Rec(i).PARCEL_SIZE,0);

      G_TOTAL_SIZE_REMAINING    := nvl(G_TOTAL_SIZE_REMAINING,0) +
                                          nvl(G_Ni_Parcel_Rec(i).PARCEL_REMAINING,0);
      /* WDK: do we need rounding?
      G_TOTAL_FACE_VALUE_AMOUNT := round(nvl(G_TOTAL_FACE_VALUE_AMOUNT,0),L_ROUNDING_FACTOR) +
                                          round((G_Ni_Parcel_Rec(i).PARCEL_SIZE * nvl(G_Ni_Parcel_Rec(i).FACE_VALUE_AMOUNT,0)),L_ROUNDING_FACTOR);
      G_TOTAL_CONSIDERATION     := nvl(G_TOTAL_CONSIDERATION,0) +
                                          round(G_Ni_Parcel_Rec(i).PARCEL_SIZE * nvl(G_Ni_Parcel_Rec(i).CONSIDERATION,0),L_ROUNDING_FACTOR);
      G_TOTAL_ORIGINAL_AMOUNT   := nvl(G_TOTAL_ORIGINAL_AMOUNT,0) +
                                          XTR_FPS2_P.interest_round(G_Ni_Parcel_Rec(i).PARCEL_SIZE *
                                          nvl(G_Ni_Parcel_Rec(i).ORIGINAL_AMOUNT,0),
                                          L_ROUNDING_FACTOR,G_Ni_Main_Rec.ROUNDING_TYPE);
      G_TOTAL_INTEREST          := nvl(G_TOTAL_INTEREST,0) +
                                          XTR_FPS2_P.interest_round(G_Ni_Parcel_Rec(i).PARCEL_SIZE *
                                          nvl(G_Ni_Parcel_Rec(i).INTEREST,0),
                                          L_ROUNDING_FACTOR,G_Ni_Main_Rec.ROUNDING_TYPE);
      */

      G_TOTAL_PRN_TAX_AMOUNT := nvl(G_TOTAL_PRN_TAX_AMOUNT,0) + G_Ni_Parcel_Rec(i).PARCEL_SIZE * nvl(g_prn_tax_amount(i),0);
      G_TOTAL_INT_TAX_AMOUNT := nvl(G_TOTAL_INT_TAX_AMOUNT,0) + G_Ni_Parcel_Rec(i).PARCEL_SIZE * nvl(g_int_tax_amount(i),0);


      G_Ni_Parcel_Rec(i).DEAL_NO := G_Ni_Main_Rec.DEAL_NO;
      G_Ni_Parcel_Rec(i).DEAL_SUBTYPE := g_ni_deal_subtype;

      G_Ni_Parcel_Rec(i).STATUS_CODE := 'CURRENT';

      select xtr_exposure_trans_s.nextval
      into   G_Ni_Parcel_Rec(i).PARCEL_SPLIT_NO  --This overwrites old transaction tracking number
      from   dual;

   END LOOP;

   G_Ni_Main_Rec.FREQUENCY := G_TOTAL_SIZE;

   G_Ni_Main_Rec.START_AMOUNT            := G_TOTAL_CONSIDERATION;
   G_Ni_Main_Rec.MATURITY_AMOUNT         := G_TOTAL_FACE_VALUE_AMOUNT;
   G_Ni_Main_Rec.MATURITY_BALANCE_AMOUNT := G_Ni_Main_Rec.MATURITY_AMOUNT;
   G_Ni_Main_Rec.INTEREST_AMOUNT         := G_TOTAL_INTEREST;
   G_Ni_Main_Rec.ORIGINAL_AMOUNT         := G_TOTAL_ORIGINAL_AMOUNT;

   G_Ni_Main_Rec.TAX_AMOUNT       :=tax_rounding(G_Ni_Main_Rec.currency,G_Ni_Main_Rec.tax_code       , G_TOTAL_PRN_TAX_AMOUNT);
   G_Ni_Main_Rec.INCOME_TAX_AMOUNT:=tax_rounding(G_Ni_Main_Rec.currency,G_Ni_Main_Rec.income_tax_code, G_TOTAL_INT_TAX_AMOUNT);

 end if;
END CALC_TOTAL_SPLITS;


/*  Local Procedure to find the rounding factor for the home currency for
this company and use the latest HCE amounts for the chosen currency from
Spot rates to calculate HCE amounts calculate the Limit Amount. Set
portfolio amount to Start HCE Amount */

/*--------------------------------------------------------------------------------*/
PROCEDURE CALC_HCE_AMOUNTS (p_user_deal_type IN VARCHAR2, p_error OUT NOCOPY BOOLEAN) is
/*--------------------------------------------------------------------------------*/

   l_roundfac   NUMBER(3,2);

   cursor rnd_fac is
   select m.rounding_factor
   from   xtr_parties_v p,
          xtr_master_currencies_v m
   where  p.party_code = G_Ni_Main_Rec.company_code
   and    p.party_type = 'C'
   and    m.currency   = p.home_currency;

   cursor HCE is
   select round((G_Ni_Main_Rec.START_AMOUNT / nvl(s.HCE_RATE,1)),nvl(l_roundfac,2)),
          round((G_Ni_Main_Rec.MATURITY_AMOUNT / nvl(s.HCE_RATE,1)),nvl(l_roundfac,2)),
          round((G_Ni_Main_Rec.INTEREST_AMOUNT / nvl(s.HCE_RATE,1)),nvl(l_roundfac,2)),
          round((nvl(G_Ni_Main_Rec.BROKERAGE_AMOUNT,0) / nvl(s.HCE_RATE,1)),nvl(l_roundfac,2))
   from   XTR_MASTER_CURRENCIES_v s
   where  s.CURRENCY = G_Ni_Main_Rec.CURRENCY;

begin
      open RND_FAC;
      fetch RND_FAC into l_roundfac;
      if RND_FAC%NOTFOUND then
         close RND_FAC;
         xtr_import_deal_data.log_interface_errors(G_Ni_Main_Rec.External_Deal_Id,p_user_deal_type,
                                                   'CompanyCode','XTR_880');--Unable to find home currency data
         p_error := true;
      end if;
      close RND_FAC;

      if G_Ni_Main_Rec.CURRENCY is NULL then
         G_Ni_Main_Rec.START_HCE_AMOUNT     := NULL;
         G_Ni_Main_Rec.INTEREST_HCE_AMOUNT  := NULL;
         G_Ni_Main_Rec.MATURITY_HCE_AMOUNT  := NULL;
         G_Ni_Main_Rec.PORTFOLIO_AMOUNT     := NULL;
      else
         open HCE;
         fetch HCE INTO G_Ni_Main_Rec.START_HCE_AMOUNT,     G_Ni_Main_Rec.MATURITY_HCE_AMOUNT,
                        G_Ni_Main_Rec.INTEREST_HCE_AMOUNT,  G_Ni_Main_Rec.BROKERAGE_AMOUNT_HCE;
         if HCE%NOTFOUND then
            close HCE;
            xtr_import_deal_data.log_interface_errors(G_Ni_Main_Rec.External_Deal_Id,p_user_deal_type,
                                                      'CurrencyA','XTR_886');  -- Unable to find spot rate data
            p_error := true;
         end if;
         close HCE;
         G_Ni_Main_Rec.MATURITY_BALANCE_HCE_AMOUNT := G_Ni_Main_Rec.MATURITY_HCE_AMOUNT;
         G_Ni_Main_Rec.PORTFOLIO_AMOUNT            := G_Ni_Main_Rec.MATURITY_HCE_AMOUNT;
      end if;
      p_error := false;
end CALC_HCE_AMOUNTS;

/*------------------------------------------------------------*/
PROCEDURE CALC_BROKERAGE_AMT(p_user_deal_type IN  VARCHAR2,
                             p_bkr_amt_type   IN  VARCHAR2,
                             p_error          OUT NOCOPY BOOLEAN) IS
/*------------------------------------------------------------*/
  l_dummy_num  NUMBER;
  l_dummy_char VARCHAR2(30);
  l_amount     NUMBER;
  l_err_code   NUMBER(8);
  l_level      VARCHAR2(2) := ' ';
BEGIN
   p_error := false;
   if ((p_bkr_amt_type = 'INTL_FV' and G_Ni_Main_Rec.MATURITY_AMOUNT is not null) or
        G_Ni_Main_Rec.INTEREST_AMOUNT is not null) then
      if p_bkr_amt_type = 'INTL_FV' then
         l_amount := G_Ni_Main_Rec.MATURITY_AMOUNT;
      else
         l_amount := G_Ni_Main_Rec.INTEREST_AMOUNT;
      end if;
      XTR_FPS1_P.CALC_TAX_BROKERAGE(G_Ni_Main_Rec.DEAL_TYPE,
                         G_Ni_Main_Rec.DEAL_DATE,
                         null,
                         G_Ni_Main_Rec.BROKERAGE_CODE,
                         G_Ni_Main_Rec.CURRENCY,
                         0,
                         0,
                         null,
                         0,
                         l_dummy_num,
                         p_bkr_amt_type,
                         l_amount,
                         G_Ni_Main_Rec.BROKERAGE_RATE,
                         l_dummy_num,
                         l_dummy_num,
                         G_Ni_Main_Rec.BROKERAGE_AMOUNT,
                         l_dummy_num,
                         l_err_code,
                         l_level);
      if (nvl(l_level,'X')='E') then
         xtr_import_deal_data.log_interface_errors(G_Ni_Main_Rec.External_Deal_Id,p_user_deal_type,
                                                      'CurrencyA','XTR_886');  -- Unable to find spot rate data
         p_error := true;
      end if;
   end if;

END CALC_BROKERAGE_AMT;

/*------------------------------------------------------------*/
PROCEDURE CREATE_NI_DEAL IS
/*------------------------------------------------------------*/

    cursor FIND_USER (p_fnd_user in number) is
    select dealer_code
    from   xtr_dealer_codes_v
    where  user_id = p_fnd_user;

    l_user       xtr_dealer_codes.dealer_code%TYPE;
    l_dual_user  xtr_dealer_codes.dealer_code%TYPE;
    l_dual_date  DATE;

    l_bank_code XTR_BANK_ACCOUNTS_V.BANK_CODE%TYPE;

		cursor get_bank_issue_code(p_serial_number in NUMBER) is
	    select bank_code
	    from   xtr_bill_bond_issues_v
	    where  ni_or_bond='NI'
	    and    serial_number=p_serial_number;


    cursor get_bank_code is
      select BANK_CODE
      from   XTR_BANK_ACCOUNTS_V
      where  ACCOUNT_NUMBER = G_Ni_Main_Rec.Maturity_Account_No
      and    PARTY_CODE     = G_Ni_Main_Rec.Company_Code;


/* -------- to insert parcels into transaction table -------*/
        /*------------------------------------------------------------*/
        PROCEDURE CREATE_TRANSACTIONS IS
        /*------------------------------------------------------------*/
                 l_tran_no              NUMBER:=0;
        --
        BEGIN
          for i in 1..g_num_parcels loop
            for j in 1..G_Ni_Parcel_Rec(i).PARCEL_SIZE loop
               l_tran_no := l_tran_no + 1;

                  insert into XTR_ROLLOVER_TRANSACTIONS_V
                    (DEAL_NUMBER,DEAL_DATE,TRANSACTION_NUMBER,DEAL_TYPE,DEAL_SUBTYPE,
                    BALANCE_OUT,CURRENCY,PARCEL_SPLIT_NO,CREATED_BY,CREATED_ON,
                    INTEREST_RATE,START_DATE,MATURITY_DATE,NO_OF_DAYS,COMPANY_CODE,
                    STATUS_CODE,PRODUCT_TYPE,CLIENT_CODE,INTEREST,ENDORSER_CODE,
                    ENDORSER_NAME,ACCEPTOR_CODE,ACCEPTOR_NAME,DRAWER_CODE,DRAWER_NAME,
                    CPARTY_CODE,DEALER_CODE,BALANCE_OUT_HCE,INTEREST_HCE,PORTFOLIO_CODE,
                    ATTRIBUTE_CATEGORY,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,
                    ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,
                    ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15,
                    ORIGINAL_AMOUNT,  --Add Interest Override
                    PRINCIPAL_TAX_CODE  ,PRINCIPAL_TAX_RATE,
                    PRINCIPAL_TAX_AMOUNT,PRINCIPAL_TAX_SETTLED_REF,
                    TAX_CODE            ,TAX_RATE,
                    TAX_AMOUNT          ,TAX_SETTLED_REFERENCE
                    )
                  values
                    ------------
                    -- NEW NI --
                    ------------
                    (G_Ni_Main_Rec.DEAL_NO,G_Ni_Main_Rec.DEAL_DATE,l_tran_no,'NI',G_Ni_Main_Rec.DEAL_SUBTYPE,
                    G_Ni_Parcel_Rec(i).FACE_VALUE_AMOUNT,G_Ni_Main_Rec.CURRENCY,G_Ni_Parcel_Rec(i).PARCEL_SPLIT_NO,
                    G_Ni_Main_Rec.CREATED_BY,G_Ni_Main_Rec.CREATED_ON,G_Ni_Main_Rec.INTEREST_RATE,G_Ni_Main_Rec.START_DATE,
                    G_Ni_Main_Rec.MATURITY_DATE,G_Ni_Main_Rec.NO_OF_DAYS,G_Ni_Main_Rec.COMPANY_CODE,G_Ni_Main_Rec.STATUS_CODE,
                    G_Ni_Main_Rec.PRODUCT_TYPE,G_Ni_Main_Rec.CLIENT_CODE,G_Ni_Parcel_Rec(i).INTEREST,G_Ni_Main_Rec.ENDORSER_CODE,
                    G_Ni_Main_Rec.ENDORSER_NAME,G_Ni_Main_Rec.ACCEPTOR_CODE,G_Ni_Main_Rec.ACCEPTOR_NAME,G_Ni_Main_Rec.DRAWER_CODE,
                    G_Ni_Main_Rec.DRAWER_NAME,G_Ni_Main_Rec.CPARTY_CODE,G_Ni_Main_Rec.DEALER_CODE,G_FV_AMT_HCE(i),
                    G_INTEREST_HCE(i),G_Ni_Main_Rec.PORTFOLIO_CODE,
                    G_Ni_Trans_Flex(i).ATTRIBUTE_CATEGORY,G_Ni_Trans_Flex(i).ATTRIBUTE1,G_Ni_Trans_Flex(i).ATTRIBUTE2,
                    G_Ni_Trans_Flex(i).ATTRIBUTE3,G_Ni_Trans_Flex(i).ATTRIBUTE4,G_Ni_Trans_Flex(i).ATTRIBUTE5,
                    G_Ni_Trans_Flex(i).ATTRIBUTE6,G_Ni_Trans_Flex(i).ATTRIBUTE7,G_Ni_Trans_Flex(i).ATTRIBUTE8,G_Ni_Trans_Flex(i).ATTRIBUTE9,
                    G_Ni_Trans_Flex(i).ATTRIBUTE10,G_Ni_Trans_Flex(i).ATTRIBUTE11,G_Ni_Trans_Flex(i).ATTRIBUTE12,G_Ni_Trans_Flex(i).ATTRIBUTE13,
                    G_Ni_Trans_Flex(i).ATTRIBUTE14,G_Ni_Trans_Flex(i).ATTRIBUTE15,
                    G_Ni_Parcel_Rec(i).ORIGINAL_AMOUNT,  --Add Interest Override
                    G_Ni_Main_Rec.TAX_CODE       ,G_Ni_Main_Rec.TAX_RATE,
                    G_PRN_TAX_AMOUNT(i)          ,null,
                    G_Ni_Main_Rec.INCOME_TAX_CODE,G_Ni_Main_Rec.INCOME_TAX_RATE,
                    G_INT_TAX_AMOUNT(i)          ,null
                  );

            END LOOP;
          END LOOP;
        END CREATE_TRANSACTIONS;


        --------------------------------------------------------------------
        -- Divides the brokerage amount as weighted average across parcels.
        -- This is the weighted average version of SPLIT_BROKERAGE_AMOUNT.
        --------------------------------------------------------------------
        /*------------------------------------------------------------*/
        PROCEDURE WEIGHTED_BROKERAGE_AMOUNT IS
        /*------------------------------------------------------------*/

           cursor CUR_ROUND is
           select nvl(a.ROUNDING_FACTOR,2),
                  nvl(b.ROUNDING_FACTOR,2)
           from   XTR_MASTER_CURRENCIES_v a,
                  xtr_MASTER_CURRENCIES_v b,
                  xtr_PARTIES_v           p
           where  a.CURRENCY   = G_Ni_Main_Rec.CURRENCY
           and    p.PARTY_CODE = G_Ni_Main_Rec.COMPANY_CODE
           and    p.PARTY_TYPE = 'C'
           and    b.CURRENCY   =  p.HOME_CURRENCY;

           l_tran_no               NUMBER;
           l_rounding              NUMBER;
           l_hce_rounding          NUMBER;
           l_running_bkge_amt      NUMBER;
           l_running_bkge_amt_hce  NUMBER;
           l_total_parcel          NUMBER;
           l_total_face_value      NUMBER;
           l_total_face_value_hce  NUMBER;
           l_tran_face_value       NUMBER;
           l_tran_face_value_hce   NUMBER;
        --
        BEGIN

           if G_Ni_Main_Rec.BROKERAGE_AMOUNT is not null then
              ------------
              -- NEW NI --
              -----------------------------------------------------------------------------------------
              -- Divide brokerage amount among parcels
              -----------------------------------------------------------------------------------------
              open CUR_ROUND;
              fetch CUR_ROUND into l_rounding, l_hce_rounding;
              close CUR_ROUND;

              select count(deal_number),
                     sum(balance_out),
                     sum(balance_out_hce)
              into   l_total_parcel,
                     l_total_face_value,
                     l_total_face_value_hce
              from   XTR_ROLLOVER_TRANSACTIONS
              where  company_code = G_Ni_Main_Rec.COMPANY_CODE
              and    deal_number  = G_Ni_Main_Rec.DEAL_NO
              and    deal_type    = 'NI'
              and    brokerage_amount is null;

              if nvl(l_total_face_value,-1) > 0 and  -- make sure that we don't divide by zero
                 nvl(l_total_face_value_hce,-1) > 0 then

                 l_running_bkge_amt     := 0;
                 l_running_bkge_amt_hce := 0;
                 l_tran_no              := 1;

                 LOOP
                    if l_total_parcel = 0 then
                       exit;
                    end if;
                    --------------------------------
                    -- Update RT brokerage amount --
                    --------------------------------
                    update XTR_ROLLOVER_TRANSACTIONS_V
                    set    BROKERAGE_AMOUNT     = round(decode(l_total_parcel,
                                                  1,G_Ni_Main_Rec.BROKERAGE_AMOUNT- l_running_bkge_amt,
                                                   (G_Ni_Main_Rec.BROKERAGE_AMOUNT/l_total_face_value)*balance_out),
                                                  l_rounding),
                           BROKERAGE_AMOUNT_HCE = round(decode(l_total_parcel,
                                                  1, G_Ni_Main_Rec.BROKERAGE_AMOUNT_HCE- l_running_bkge_amt_hce,
                                                    (G_Ni_Main_Rec.BROKERAGE_AMOUNT_HCE/l_total_face_value_hce)*balance_out_hce),
                                                  l_hce_rounding)
                    where  company_code         = G_Ni_Main_Rec.COMPANY_CODE
                    and    deal_number          = G_Ni_Main_Rec.DEAL_NO
                    and    deal_type            = 'NI'
                    and    transaction_number   = l_tran_no
                    and    brokerage_amount is null;

                    select balance_out,
                           balance_out_hce
                    into   l_tran_face_value,
                           l_tran_face_value_hce
                    from   XTR_ROLLOVER_TRANSACTIONS
                    where  company_code       = G_Ni_Main_Rec.COMPANY_CODE
                    and    deal_number        = G_Ni_Main_Rec.DEAL_NO
                    and    deal_type          = 'NI'
                    and    transaction_number = l_tran_no;

                    l_running_bkge_amt     := round(l_running_bkge_amt +
                                              (G_Ni_Main_Rec.BROKERAGE_AMOUNT/l_total_face_value)*l_tran_face_value,
                                              l_rounding);
                    l_running_bkge_amt_hce := round(l_running_bkge_amt_hce +
                                              (G_Ni_Main_Rec.BROKERAGE_AMOUNT_HCE/l_total_face_value_hce)*l_tran_face_value_hce,
                                              l_hce_rounding);

                    l_total_parcel := l_total_parcel - 1;
                    l_tran_no      := l_tran_no + 1;

                 END LOOP;
              end if;
           end if;

        END WEIGHTED_BROKERAGE_AMOUNT;


        /*------------------------------------------------------------*/
        PROCEDURE SET_INITIAL_FAIR_VALUE IS
        /*------------------------------------------------------------*/

           cursor ROLL_ID is
           select transaction_number
           from   xtr_rollover_transactions
           where  company_code = G_Ni_Main_Rec.company_code
           and    deal_number = G_Ni_Main_Rec.deal_no
           and    deal_type = 'NI'
           and    initial_fair_value is null;

           l_tran_no   NUMBER;

        BEGIN
           open ROLL_ID;
           fetch ROLL_ID into l_tran_no;
           while ROLL_ID%FOUND loop
              xtr_reval_process_p.xtr_ins_init_fv(G_Ni_Main_Rec.COMPANY_CODE,G_Ni_Main_Rec.DEAL_NO,'NI',l_TRAN_NO,G_Ni_Main_Rec.day_count_type);
              fetch ROLL_ID into l_tran_no;
           end loop;
           close ROLL_ID;

        END SET_INITIAL_FAIR_VALUE;














        /*--------------------------------------------------------------------------------*/
				PROCEDURE CALL_ONE_STEP_SETTLEMENT (p_prn_exp_number OUT NOCOPY NUMBER,
								p_int_exp_number OUT NOCOPY NUMBER)
							IS
        /*--------------------------------------------------------------------------------*/
				--
					 v_rec xtr_fps2_p.one_step_rec_type;
					 v_error VARCHAR2(40);
					 v_settle_method xtr_tax_brokerage_setup.tax_settle_method%Type;
				--
				BEGIN
					 --Principal Tax
					 if g_prn_tax_settle_method='OSG' then
							v_rec.p_source := 'TAX';
							v_rec.p_schedule_code      := G_Ni_Main_Rec.tax_code;
							v_rec.p_currency           := G_Ni_Main_Rec.currency;
							v_rec.p_amount             := G_Ni_Main_Rec.tax_amount;
							v_rec.p_settlement_date    := G_Ni_Main_Rec.start_date;
							v_rec.p_settlement_account := G_Ni_Main_Rec.maturity_account_no;
							v_rec.p_company_code       := G_Ni_Main_Rec.company_code;
							v_rec.p_cparty_code        := G_Ni_Main_Rec.cparty_code;
							v_rec.p_cparty_account_no  := G_Ni_Main_Rec.cparty_ref;

							XTR_FPS2_P.One_Step_Settlement(v_rec);

							v_error := v_rec.p_error;
							v_settle_method := v_rec.p_settle_method;
							p_prn_exp_number := v_rec.p_exp_number;

							update xtr_deals
							   set tax_settled_reference=p_prn_exp_number
							   where deal_no=G_Ni_Main_Rec.deal_no;
					 end if;

					 --Interest Tax
					 if g_int_tax_settle_method='OSG' then
							v_rec.p_source := 'TAX';
							v_rec.p_schedule_code      := G_Ni_Main_Rec.income_tax_code;
							v_rec.p_currency           := G_Ni_Main_Rec.currency;
							v_rec.p_amount             := G_Ni_Main_Rec.income_tax_amount;
							v_rec.p_settlement_date    := G_Ni_Main_Rec.start_date;
							v_rec.p_settlement_account := G_Ni_Main_Rec.maturity_account_no;
							v_rec.p_company_code       := G_Ni_Main_Rec.company_code;
							v_rec.p_cparty_code        := G_Ni_Main_Rec.cparty_code;
							v_rec.p_cparty_account_no  := G_Ni_Main_Rec.cparty_ref;

							XTR_FPS2_P.One_Step_Settlement(v_rec);

							v_error := v_rec.p_error;
							v_settle_method := v_rec.p_settle_method;
							p_int_exp_number := v_rec.p_exp_number;

							update xtr_deals
							   set income_tax_settled_ref=p_int_exp_number
							   where deal_no=G_Ni_Main_Rec.deal_no;
					 end if;
				END CALL_ONE_STEP_SETTLEMENT;





        /*--------------------------------------------------------------------------------*/
				PROCEDURE GET_RISK_PARTY_NAMES IS
				    cursor risk_party_name(p_party_code in VARCHAR2) is
				        select short_name
						    from   xtr_parties_v
						    where  party_code=p_party_code;

				BEGIN
				    open risk_party_name(G_Ni_Main_Rec.ACCEPTOR_CODE);
				    fetch risk_party_name into G_Ni_Main_Rec.ACCEPTOR_NAME;
				    close risk_party_name;

				    open risk_party_name(G_Ni_Main_Rec.DRAWER_CODE);
				    fetch risk_party_name into G_Ni_Main_Rec.DRAWER_NAME;
				    close risk_party_name;

				    open risk_party_name(G_Ni_Main_Rec.ENDORSER_CODE);
				    fetch risk_party_name into G_Ni_Main_Rec.ENDORSER_NAME;
				    close risk_party_name;

				END GET_RISK_PARTY_NAMES;

        /*--------------------------------------------------------------------------------*/



        /*---------- end local procedure to data into secondary tables ----*/


Begin

        open  FIND_USER(G_User_Id);
        fetch FIND_USER into l_user;
        close FIND_USER;

        l_dual_user := G_Ni_Main_Rec.DUAL_AUTHORISATION_BY;
        l_dual_date := G_Ni_Main_Rec.DUAL_AUTHORISATION_ON;
        if ((l_dual_user is not null and l_dual_date is null) or
            (l_dual_user is null     and l_dual_date is not null)) then
            if l_dual_date is null then
               l_dual_date := trunc(sysdate);
            elsif l_dual_user is null then
               l_dual_user := l_user;
            end if;
        end if;

        G_Ni_Main_Rec.CREATED_BY:=nvl(l_user,G_User_Id);
				G_Ni_Main_Rec.CREATED_ON:=g_curr_date;

				GET_RISK_PARTY_NAMES;


        INSERT INTO XTR_DEALS
        (
            EXTERNAL_DEAL_ID,
            FREQUENCY,
            DEAL_TYPE,
            BROKERAGE_AMOUNT_HCE,
            TAX_AMOUNT_HCE,
            MATURITY_BALANCE_HCE_AMOUNT,
            RISKPARTY_CODE,
            YEAR_BASIS,
            INTEREST_HCE_AMOUNT,
            START_HCE_AMOUNT,
            PORTFOLIO_AMOUNT,
            MATURITY_HCE_AMOUNT,
            PREMIUM_ACCOUNT_NO,
            NI_DEAL_NO,
            RENEG_DATE,
            DEAL_NO,
            STATUS_CODE,
            DEALER_CODE,
            DEAL_DATE,
            COMPANY_CODE,
            CPARTY_CODE,
            CLIENT_CODE,
            PORTFOLIO_CODE,
            KNOCK_TYPE,
            NI_PROFIT_LOSS,
            DEAL_SUBTYPE,
            PRODUCT_TYPE,
            CURRENCY,
            YEAR_CALC_TYPE,
            START_DATE,
            MATURITY_DATE,
            NO_OF_DAYS,
            MATURITY_AMOUNT,
            MATURITY_BALANCE_AMOUNT,
            START_AMOUNT,
            CALC_BASIS,
            INTEREST_RATE,
            INTEREST_AMOUNT,
            ORIGINAL_AMOUNT,
            ROUNDING_TYPE,
            DAY_COUNT_TYPE,
            COMMENTS,
            INTERNAL_TICKET_NO,
            EXTERNAL_COMMENTS,
            EXTERNAL_CPARTY_NO,
            MATURITY_ACCOUNT_NO,
            CPARTY_ACCOUNT_NO,
            CPARTY_REF,
            PRINCIPAL_SETTLED_BY,
            SECURITY_ID,
            MARGIN,
            PRICING_MODEL,
            MARKET_DATA_SET,
            DEAL_LINKING_CODE,
            ACCEPTOR_CODE,
            ACCEPTOR_NAME,
            DRAWER_CODE,
            DRAWER_NAME,
            ENDORSER_CODE,
            ENDORSER_NAME,
            RISKPARTY_LIMIT_CODE,
            BROKERAGE_CODE,
            BROKERAGE_RATE,
            BROKERAGE_AMOUNT,
            BROKERAGE_CURRENCY,
            TAX_CODE,
            TAX_RATE,
            TAX_AMOUNT,
            TAX_SETTLED_REFERENCE,
            INCOME_TAX_CODE,
            INCOME_TAX_RATE,
            INCOME_TAX_AMOUNT,
            INCOME_TAX_SETTLED_REF,
            DUAL_AUTHORISATION_BY,
            DUAL_AUTHORISATION_ON,
            CREATED_BY,
            CREATED_ON,
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
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE
        )
        VALUES
        (
            G_Ni_Main_Rec.EXTERNAL_DEAL_ID,
            G_Ni_Main_Rec.FREQUENCY,
            G_Ni_Main_Rec.DEAL_TYPE,
            G_Ni_Main_Rec.BROKERAGE_AMOUNT_HCE,
            G_Ni_Main_Rec.TAX_AMOUNT_HCE,
            G_Ni_Main_Rec.MATURITY_BALANCE_HCE_AMOUNT,
            G_Ni_Main_Rec.RISKPARTY_CODE,
            G_Ni_Main_Rec.YEAR_BASIS,
            G_Ni_Main_Rec.INTEREST_HCE_AMOUNT,
            G_Ni_Main_Rec.START_HCE_AMOUNT,
            G_Ni_Main_Rec.PORTFOLIO_AMOUNT,
            G_Ni_Main_Rec.MATURITY_HCE_AMOUNT,
            G_Ni_Main_Rec.PREMIUM_ACCOUNT_NO,
            G_Ni_Main_Rec.NI_DEAL_NO,
            G_Ni_Main_Rec.RENEG_DATE,
            G_Ni_Main_Rec.DEAL_NO,
            G_Ni_Main_Rec.STATUS_CODE,
            G_Ni_Main_Rec.DEALER_CODE,
            G_Ni_Main_Rec.DEAL_DATE,
            G_Ni_Main_Rec.COMPANY_CODE,
            G_Ni_Main_Rec.CPARTY_CODE,
            G_Ni_Main_Rec.CLIENT_CODE,
            G_Ni_Main_Rec.PORTFOLIO_CODE,
            G_Ni_Main_Rec.KNOCK_TYPE,
            G_Ni_Main_Rec.NI_PROFIT_LOSS,
            G_Ni_Main_Rec.DEAL_SUBTYPE,
            G_Ni_Main_Rec.PRODUCT_TYPE,
            G_Ni_Main_Rec.CURRENCY,
            G_Ni_Main_Rec.YEAR_CALC_TYPE,
            G_Ni_Main_Rec.START_DATE,
            G_Ni_Main_Rec.MATURITY_DATE,
            G_Ni_Main_Rec.NO_OF_DAYS,
            G_Ni_Main_Rec.MATURITY_AMOUNT,
            G_Ni_Main_Rec.MATURITY_BALANCE_AMOUNT,
            G_Ni_Main_Rec.START_AMOUNT,
            G_Ni_Main_Rec.CALC_BASIS,
            G_Ni_Main_Rec.INTEREST_RATE,
            G_Ni_Main_Rec.INTEREST_AMOUNT,
            G_Ni_Main_Rec.ORIGINAL_AMOUNT,
            G_Ni_Main_Rec.ROUNDING_TYPE,
            G_Ni_Main_Rec.DAY_COUNT_TYPE,
            G_Ni_Main_Rec.COMMENTS,
            G_Ni_Main_Rec.INTERNAL_TICKET_NO,
            G_Ni_Main_Rec.EXTERNAL_COMMENTS,
            G_Ni_Main_Rec.EXTERNAL_CPARTY_NO,
            G_Ni_Main_Rec.MATURITY_ACCOUNT_NO,
            G_Ni_Main_Rec.CPARTY_ACCOUNT_NO,
            G_Ni_Main_Rec.CPARTY_REF,
            G_Ni_Main_Rec.PRINCIPAL_SETTLED_BY,
            G_Ni_Main_Rec.SECURITY_ID,
            G_Ni_Main_Rec.MARGIN,
            G_Ni_Main_Rec.PRICING_MODEL,
            G_Ni_Main_Rec.MARKET_DATA_SET,
            G_Ni_Main_Rec.DEAL_LINKING_CODE,
            G_Ni_Main_Rec.ACCEPTOR_CODE,
            G_Ni_Main_Rec.ACCEPTOR_NAME,
            G_Ni_Main_Rec.DRAWER_CODE,
            G_Ni_Main_Rec.DRAWER_NAME,
            G_Ni_Main_Rec.ENDORSER_CODE,
            G_Ni_Main_Rec.ENDORSER_NAME,
            G_Ni_Main_Rec.RISKPARTY_LIMIT_CODE,
            G_Ni_Main_Rec.BROKERAGE_CODE,
            G_Ni_Main_Rec.BROKERAGE_RATE,
            G_NI_Main_Rec.BROKERAGE_AMOUNT,
            G_Ni_Main_Rec.BROKERAGE_CURRENCY,
            G_Ni_Main_Rec.TAX_CODE,
            G_Ni_Main_Rec.TAX_RATE,
            G_Ni_Main_Rec.TAX_AMOUNT,
            G_Ni_Main_Rec.TAX_SETTLED_REFERENCE,
            G_Ni_Main_Rec.INCOME_TAX_CODE,
            G_Ni_Main_Rec.INCOME_TAX_RATE,
            G_Ni_Main_Rec.INCOME_TAX_AMOUNT,
            G_Ni_Main_Rec.INCOME_TAX_SETTLED_REF,
            l_dual_user,
            l_dual_date,
            G_Ni_Main_Rec.CREATED_BY,
            G_Ni_Main_Rec.CREATED_ON,
            G_Ni_Main_Rec.ATTRIBUTE_CATEGORY,
            G_Ni_Main_Rec.ATTRIBUTE1,
            G_Ni_Main_Rec.ATTRIBUTE2,
            G_Ni_Main_Rec.ATTRIBUTE3,
            G_Ni_Main_Rec.ATTRIBUTE4,
            G_Ni_Main_Rec.ATTRIBUTE5,
            G_Ni_Main_Rec.ATTRIBUTE6,
            G_Ni_Main_Rec.ATTRIBUTE7,
            G_Ni_Main_Rec.ATTRIBUTE8,
            G_Ni_Main_Rec.ATTRIBUTE9,
            G_Ni_Main_Rec.ATTRIBUTE10,
            G_Ni_Main_Rec.ATTRIBUTE11,
            G_Ni_Main_Rec.ATTRIBUTE12,
            G_Ni_Main_Rec.ATTRIBUTE13,
            G_Ni_Main_Rec.ATTRIBUTE14,
            G_Ni_Main_Rec.ATTRIBUTE15,
            FND_GLOBAL.conc_request_id,
            FND_GLOBAL.prog_appl_id,
            FND_GLOBAL.conc_program_id,
            g_curr_date
        );


                   --Parcels
                   -- WDK: change to forall
                 for i in 1..g_num_parcels loop

                        if (g_ni_deal_subtype = 'ISSUE' and G_Ni_Parcel_Rec(i).SERIAL_NUMBER is not null) then

                            open get_bank_code;
                            fetch get_bank_code into l_bank_code;
                            close get_bank_code;

                            open get_bank_issue_code(G_Ni_Parcel_Rec(i).SERIAL_NUMBER);
                            fetch get_bank_issue_code into G_Ni_Parcel_Rec(i).ISSUE_BANK;
                            close get_bank_issue_code;

                            update XTR_bill_bond_issues_V
                            set    issue_date      = G_Ni_Main_Rec.DEAL_DATE,
                                   deal_number     = G_Ni_Main_Rec.DEAL_NO,
                                   status          = G_Ni_Parcel_Rec(i).STATUS_CODE,
                                   parcel_split_no = G_Ni_Parcel_Rec(i).PARCEL_SPLIT_NO,
                                   due_date        = G_Ni_Main_Rec.MATURITY_DATE,
                                   currency        = G_Ni_Main_Rec.CURRENCY,
                                   amount          = G_Ni_Parcel_Rec(i).FACE_VALUE_AMOUNT,
                                   bank_code       = l_bank_code
                            where  ni_or_bond      = 'NI'
                            and    serial_number   = G_Ni_Parcel_Rec(i).SERIAL_NUMBER;

                        else
                          G_Ni_Parcel_Rec(i).SERIAL_NUMBER    := null;
                          G_Ni_Parcel_Rec(i).SERIAL_NUMBER_IN := null;
                          G_Ni_Parcel_Rec(i).ISSUE_BANK       := null;
                        end if;

                        insert into xtr_parcel_splits(
                                DEAL_NO,
                                PARCEL_SPLIT_NO,
                                PARCEL_SIZE,
                                FACE_VALUE_AMOUNT,
                                CONSIDERATION,
                                INTEREST,
                                STATUS_CODE,
                                DEAL_SUBTYPE,
                                AVAILABLE_FOR_RESALE,
                                PARCEL_REMAINING,
                                SELECT_NUMBER,
                                SELECT_FV_AMOUNT,
                                REFERENCE_NUMBER,
                                RESERVE_PARCEL,
                                OLD_SELECT_NUMBER,
                                SERIAL_NUMBER,
                                SERIAL_NUMBER_IN,
                                ISSUE_BANK,
                                ORIGINAL_AMOUNT
                                )
                        Values(
                                G_Ni_Parcel_Rec(i).DEAL_NO,
                                G_Ni_Parcel_Rec(i).PARCEL_SPLIT_NO,
                                G_Ni_Parcel_Rec(i).PARCEL_SIZE,
                                G_Ni_Parcel_Rec(i).FACE_VALUE_AMOUNT,
                                G_Ni_Parcel_Rec(i).CONSIDERATION,
                                G_Ni_Parcel_Rec(i).INTEREST,
                                G_Ni_Parcel_Rec(i).STATUS_CODE,
                                G_Ni_Parcel_Rec(i).DEAL_SUBTYPE,
                                G_Ni_Parcel_Rec(i).AVAILABLE_FOR_RESALE,
                                G_Ni_Parcel_Rec(i).PARCEL_REMAINING,
                                G_Ni_Parcel_Rec(i).SELECT_NUMBER,
                                G_Ni_Parcel_Rec(i).SELECT_FV_AMOUNT,
                                G_Ni_Parcel_Rec(i).REFERENCE_NUMBER,
                                G_Ni_Parcel_Rec(i).RESERVE_PARCEL,
                                G_Ni_Parcel_Rec(i).OLD_SELECT_NUMBER,
                                G_Ni_Parcel_Rec(i).SERIAL_NUMBER,
                                G_Ni_Parcel_Rec(i).SERIAL_NUMBER_IN,
                                G_Ni_Parcel_Rec(i).ISSUE_BANK,
                                G_Ni_Parcel_Rec(i).ORIGINAL_AMOUNT
                        );

                end loop;

                CREATE_TRANSACTIONS;

                WEIGHTED_BROKERAGE_AMOUNT;

                SET_INITIAL_FAIR_VALUE;

                CALL_ONE_STEP_SETTLEMENT(G_Ni_Main_Rec.TAX_SETTLED_REFERENCE,G_Ni_Main_Rec.INCOME_TAX_SETTLED_REF);


        if l_dual_user is not null then
           UPDATE xtr_deal_date_amounts
           SET    dual_authorisation_by = l_dual_user,
                  dual_authorisation_on = l_dual_date
           WHERE  deal_number           = G_Ni_Main_Rec.DEAL_NO;

           UPDATE xtr_confirmation_details
           SET    confirmation_validated_by = l_dual_user,
                  confirmation_validated_on = l_dual_date
           WHERE  deal_no                   = G_Ni_Main_Rec.DEAL_NO;

           UPDATE xtr_deals
           SET    dual_authorisation_on = l_dual_date
           WHERE  deal_no               = G_Ni_Main_Rec.DEAL_NO;
        end if;

END CREATE_NI_DEAL;

END XTR_NI_TRANSFERS_PKG;

/
