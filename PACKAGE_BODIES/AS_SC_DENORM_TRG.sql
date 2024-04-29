--------------------------------------------------------
--  DDL for Package Body AS_SC_DENORM_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SC_DENORM_TRG" AS
/* $Header: asxopdtb.pls 120.1.12010000.3 2008/09/22 09:18:48 dkailash ship $ */

--
-- HISTORY
-- 04/07/2000       NACHARYA    Created
-- 12/28/2000       SOLIN       Change for debug message
-- 11/05/2003       gbatra      product hierarchy uptake
--

-- Global Variables
   ERRBUF  Varchar2(3000);
   RETCODE Varchar2(30);

Procedure Fetch_Interest_Info (
    p_interest_type_id           IN  Number,
    p_interest_type              OUT NOCOPY Varchar2,
    p_primary_interest_code_id   IN  Number,
    p_primary_interest_code      OUT NOCOPY Varchar2,
    p_secondary_interest_code_id IN  Number,
    p_secondary_interest_code    OUT NOCOPY Varchar2) IS
Begin
    Begin
          Select interest_type into p_interest_type
          From as_interest_types_tl
          Where interest_type_id = p_interest_type_id
          And language = USERENV('LANG');
        Exception
         When Others then
          p_interest_type := NULL;
        End;

    Begin
          Select code into p_primary_interest_code
          From as_interest_codes_tl
          Where interest_code_id = p_primary_interest_code_id
          And language = USERENV('LANG');
        Exception When Others then
          p_primary_interest_code := NULL;
        End;

    Begin
         Select code into p_secondary_interest_code
         From as_interest_codes_tl
         Where interest_code_id = p_secondary_interest_code_id
         AND language = USERENV('LANG');
        Exception When Others then
         p_secondary_interest_code := NULL;
        End;
End Fetch_Interest_Info;

Procedure convert_amounts(p_from_currency IN Varchar2,
                          p_decision_date IN Date,
                          p_ctotal_amt IN OUT NOCOPY Number,
                          p_csc_amt IN OUT NOCOPY Number,
                          p_cwon_amt IN OUT NOCOPY Number,
                          p_cweighted_amt IN OUT NOCOPY Number,
                          p_status_flg OUT NOCOPY Number) IS

Cursor factor (p_currency IN Varchar2, p_date IN Date) IS
      Select denominator_rate, numerator_rate, minimum_accountable_unit, conversion_status_flag
      From as_period_rates pr, as_period_days pd
      Where pr.from_currency = p_currency
      and pr.to_currency = FND_PROFILE.VALUE('AS_PREFERRED_CURRENCY')
      and pr.conversion_type = FND_PROFILE.VALUE('AS_MC_DAILY_CONVERSION_TYPE')
      and pr.conversion_status_flag = 0
      and pr.period_name = pd.period_name
      and pd.period_day = p_date
      and pd.period_type = FND_PROFILE.VALUE('AS_DEFAULT_PERIOD_TYPE')
      and rownum <= 1;
Begin
   Begin
         p_status_flg := 1;
         For I in factor(p_from_currency, p_decision_date) Loop
             p_status_flg     := I.conversion_status_flag;
             p_ctotal_amt := (((p_ctotal_amt /I.denominator_rate) * I.numerator_rate) / I.minimum_accountable_unit) * I.minimum_accountable_unit;
             p_csc_amt := (((p_csc_amt /I.denominator_rate) * I.numerator_rate) / I.minimum_accountable_unit) * I.minimum_accountable_unit;
             p_cwon_amt := (((p_cwon_amt /I.denominator_rate) * I.numerator_rate) / I.minimum_accountable_unit) * I.minimum_accountable_unit;
             p_cweighted_amt := (((p_cweighted_amt /I.denominator_rate) * I.numerator_rate) / I.minimum_accountable_unit) * I.minimum_accountable_unit;
         End Loop;
    Exception when others then
                p_status_flg := 1;
    End;
End convert_amounts;


Procedure Leads_Trigger_Handler(
				p_new_last_update_date IN as_leads_all.last_update_date%type ,
				p_new_last_updated_by IN as_leads_all.last_updated_by%type,
				p_new_creation_date IN as_leads_all.creation_date%type,
				p_new_created_by IN as_leads_all.created_by%type,
				p_new_last_update_login IN as_leads_all.last_update_login%type,
				p_new_customer_id IN as_leads_all.customer_id%type,
				p_new_address_id IN as_leads_all.address_id%type,
				p_new_lead_id IN as_leads_all.lead_id%type,
				p_new_lead_number IN as_leads_all.lead_number%type,
				p_new_description IN as_leads_all.description%type,
				p_new_decision_date IN as_leads_all.decision_date%type ,
				p_old_decision_date IN as_leads_all.decision_date%type ,
				p_new_sales_stage_id IN as_leads_all.sales_stage_id%type,
				p_new_source_promotion_id IN as_leads_all.source_promotion_id%type,
				p_new_close_competitor_id IN as_leads_all.close_competitor_id%type,
				p_new_owner_salesforce_id IN as_leads_all.owner_salesforce_id%type,
				p_new_owner_sales_group_id IN as_leads_all.owner_sales_group_id%type,
				p_new_win_probability IN as_leads_all.win_probability%type,
				p_old_win_probability IN as_leads_all.win_probability%type,
				p_new_status IN as_leads_all.status%type,
				p_old_status IN as_leads_all.status%type,
				p_new_channel_code IN as_leads_all.channel_code%type,
				p_new_lead_source_code IN as_leads_all.lead_source_code%type,
				p_new_orig_system_reference IN as_leads_all.orig_system_reference%type,
				p_new_currency_code IN as_leads_all.currency_code%type,
				p_old_currency_code IN as_leads_all.currency_code%type,
				p_new_total_amount IN as_leads_all.total_amount%type,
				p_old_total_amount IN as_leads_all.total_amount%type,
				p_old_lead_id IN as_leads_all.lead_id%type,
				p_new_org_id IN as_leads_all.org_id%type,
				p_new_deleted_flag IN as_leads_all.deleted_flag%type,
				p_new_parent_project IN as_leads_all.parent_project%type,
				p_new_close_reason IN as_leads_all.close_reason%type,
				p_new_attr_category IN as_sales_credits_denorm.attribute_category%type,
				p_new_attr1 IN as_sales_credits_denorm.attribute1%type,
				p_new_attr2 IN as_sales_credits_denorm.attribute1%type,
				p_new_attr3 IN as_sales_credits_denorm.attribute1%type,
				p_new_attr4 IN as_sales_credits_denorm.attribute1%type,
				p_new_attr5 IN as_sales_credits_denorm.attribute1%type,
				p_new_attr6 IN as_sales_credits_denorm.attribute1%type,
				p_new_attr7 IN as_sales_credits_denorm.attribute1%type,
				p_new_attr8 IN as_sales_credits_denorm.attribute1%type,
				p_new_attr9 IN as_sales_credits_denorm.attribute1%type,
				p_new_attr10 IN as_sales_credits_denorm.attribute1%type,
				p_new_attr11 IN as_sales_credits_denorm.attribute1%type,
				p_new_attr12 IN as_sales_credits_denorm.attribute1%type,
				p_new_attr13 IN as_sales_credits_denorm.attribute1%type,
				p_new_attr14 IN as_sales_credits_denorm.attribute1%type,
				p_new_attr15 IN as_sales_credits_denorm.attribute1%type,
				p_new_sales_methodology_id IN as_sales_credits_denorm.sales_methodology_id%type,
				p_trigger_mode IN VARCHAR2) IS

CURSOR c_sales_credit_amount (p_lead_id as_leads_all.lead_id%type) IS
	Select sales_credit_id, sales_credit_amount, forecast_date
	From as_sales_credits_denorm
	Where lead_id = p_lead_id;

CURSOR c_no_line_forecasts (p_lead_id as_leads_all.lead_id%type) IS
	Select lead_line_id
	From as_lead_lines_all
	Where lead_id = p_lead_id AND forecast_date IS NULL;

l_customer_id   		as_leads_all.customer_id%TYPE;
l_customer_name   		as_party_customers_v.CUSTOMER_NAME%TYPE;
l_party_type              	as_party_customers_v.party_type%TYPE;
l_sales_stage   		as_sales_stages.name%TYPE;
l_status			as_statuses_tl.meaning%TYPE;
l_win_loss_indicator      	as_statuses_b.win_loss_indicator%Type;
l_forecast_rollup_flag    	as_statuses_b.forecast_rollup_flag%Type;
l_opp_open_status_flag    	as_statuses_b.opp_open_status_flag%Type;
l_customer_category   	 	ar_lookups.meaning%TYPE;
l_customer_category_code  	as_party_customers_v.customer_category_code%TYPE;
l_total_amount			NUMBER;
l_sc_amount 			NUMBER;
l_won_amount 			NUMBER;
l_weighted_amount 		NUMBER;
l_converted_won_amount 	 	NUMBER;
l_converted_weighted_amount	NUMBER;
l_conversion_status_flag   	NUMBER;
l_competitor_name 		hz_parties.party_name%TYPE;
l_owner_person_name	      	jtf_rs_resource_extns.source_name%TYPE;
l_owner_first_name		jtf_rs_resource_extns.source_first_name%TYPE;
l_owner_last_name		jtf_rs_resource_extns.source_last_name%TYPE;
l_owner_group_name	jtf_rs_groups_tl.group_name%TYPE;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
Begin
    IF l_debug THEN
    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Leads_Trigger_Handler Start');
    END IF;

	If p_trigger_mode = 'ON-UPDATE' then
	IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Update opportunity');
        END IF;
		Begin
			Select party_name, party_type, category_code
		       Into  l_customer_name, l_party_type, l_customer_category_code
			From hz_parties
			Where party_id = p_new_customer_id;
		Exception
			When Others then
			 l_customer_name  := NULL;
			 l_party_type     := Null;
			 l_customer_category_code := NULL;
		End;

		Begin
			Select meaning
		 	 Into l_customer_category
			From ar_lookups arlkp
			Where arlkp.lookup_type = 'CUSTOMER_CATEGORY'
			And arlkp.lookup_code = l_customer_category_code;
		Exception
			When others then
			 l_customer_category := NULL;
		End;


		begin
			select party_name
			into l_competitor_name
			from hz_parties
			where party_id = p_new_close_competitor_id;
		exception
			when others then
			l_competitor_name := NULL;
		end;

		Begin
			Select source_name, source_first_name, source_last_name
		 	Into l_owner_person_name, l_owner_first_name, l_owner_last_name
        	From jtf_rs_resource_extns
			Where resource_id = p_new_owner_salesforce_id
                	and category IN ('EMPLOYEE','PARTY');
		Exception When Others then
			l_owner_person_name := Null;
			l_owner_first_name := Null;
			l_owner_last_name := Null;
		End;

		Begin
			Select group_name
		  	Into l_owner_group_name
			From jtf_rs_groups_tl
			Where group_id = p_new_owner_sales_group_id
			And language = userenv('LANG');
		Exception When Others then
			l_owner_group_name := Null;
		End;

		Begin
			Select meaning
		 	 Into as_sc_denorm.scd_close_reason_men(1)
			From as_lookups aslkp
			Where aslkp.lookup_type = 'CLOSE_REASON'
			And aslkp.lookup_code = p_new_close_reason;
		Exception
			When others then
			 as_sc_denorm.scd_close_reason_men(1) := NULL;
		End;

          Begin
                 Select source_name
			Into as_sc_denorm.scd_opp_created_name(1)
		     From jtf_rs_resource_extns
                 Where user_id = p_new_created_by;
 		Exception
			When Others then
			 as_sc_denorm.scd_opp_created_name(1) := Null;
		End;

          Begin
                 Select source_name
			Into as_sc_denorm.scd_opp_last_upd_name(1)
		     From jtf_rs_resource_extns
                 Where user_id = p_new_last_updated_by;
 		Exception
			When Others then
			 as_sc_denorm.scd_opp_last_upd_name(1) := Null;
		End;

		Begin
			Select name
			 Into l_sales_stage
			From as_sales_stages_all_tl sales
			Where sales.sales_stage_id = p_new_sales_stage_id
			And language = USERENV('LANG');
		Exception
			When Others then
		       l_sales_stage  := NULL;
		End;

	    Begin
            	Select meaning, win_loss_indicator, forecast_rollup_flag, opp_open_status_flag
             	 Into l_status, l_win_loss_indicator, l_forecast_rollup_flag, l_opp_open_status_flag
            	From as_statuses_vl status
            	Where status.status_code = p_new_status;
	    Exception
                  When Others then
                   l_status               := Null;
                   l_win_loss_indicator   := Null;
                   l_forecast_rollup_flag := Null;
                   l_opp_open_status_flag := Null;
	    End;

	    l_conversion_status_flag := 1;
	    Begin
                        l_total_amount := p_new_total_amount;
	                convert_amounts(p_new_currency_code, trunc(nvl(p_new_decision_date,p_new_creation_date)), l_total_amount,l_sc_amount,l_converted_won_amount,l_converted_weighted_amount, l_conversion_status_flag);

			Update as_sales_credits_denorm
		        Set object_version_number =  nvl(object_version_number,0) + 1,  opportunity_last_update_date = p_new_last_update_date
				,opportunity_last_updated_by = p_new_last_updated_by
		     		,last_update_date = SYSDATE
				,last_updated_by = p_new_last_updated_by
				,creation_date = SYSDATE
				,created_by = p_new_created_by
				,last_update_login = p_new_last_update_login
				,customer_id = p_new_customer_id
				,customer_name = l_customer_name
				,party_type = l_party_type
				,address_id = p_new_address_id
				,lead_id = p_new_lead_id
				,lead_number = p_new_lead_number
				,opp_description = p_new_description
				,decision_date = trunc(p_new_decision_date)
				,sales_stage_id = p_new_sales_stage_id
				,source_promotion_id = p_new_source_promotion_id
				,close_competitor_id = p_new_close_competitor_id
				,owner_salesforce_id = p_new_owner_salesforce_id
				,owner_sales_group_id = p_new_owner_sales_group_id
				,competitor_name = l_competitor_name
				,owner_person_name = l_owner_person_name
				,owner_last_name = l_owner_last_name
				,owner_first_name = l_owner_first_name
				,owner_group_name = l_owner_group_name
				,sales_stage = l_sales_stage
				,win_probability = p_new_win_probability
				,status = l_status
				,status_code = p_new_status
				,channel_code = p_new_channel_code
				,lead_source_code = p_new_lead_source_code
				,orig_system_reference = p_new_orig_system_reference
				,currency_code = p_new_currency_code
				,total_amount = p_new_total_amount
				,c1_total_amount = l_total_amount
				,c1_currency_code = FND_PROFILE.Value('AS_PREFERRED_CURRENCY')
				,customer_category = l_customer_category
				,customer_category_code = l_customer_category_code
				,org_id  = p_new_org_id
				,request_id = Null
				,conversion_status_flag = l_conversion_status_flag
				,forecast_rollup_flag = l_forecast_rollup_flag
				,win_loss_indicator = l_win_loss_indicator
				,opp_open_status_flag = l_opp_open_status_flag
				,opp_deleted_flag = p_new_deleted_flag
				,parent_project = p_new_parent_project
				,attribute_category = p_new_attr_category
				,attribute1 = p_new_attr1
				,attribute2 = p_new_attr2
				,attribute3 = p_new_attr3
				,attribute4 = p_new_attr4
				,attribute5 = p_new_attr5
				,attribute6 = p_new_attr6
				,attribute7 = p_new_attr7
				,attribute8 = p_new_attr8
				,attribute9 = p_new_attr9
				,attribute10 = p_new_attr10
				,attribute11 = p_new_attr11
				,attribute12 = p_new_attr12
				,attribute13 = p_new_attr13
				,attribute14 = p_new_attr14
				,attribute15 = p_new_attr15
				,close_reason = p_new_close_reason
				,close_reason_meaning = as_sc_denorm.scd_close_reason_men(1)
				,opportunity_last_updated_name = as_sc_denorm.scd_opp_last_upd_name(1)
				,opportunity_created_name = as_sc_denorm.scd_opp_created_name(1)
				,opportunity_created_by = p_new_created_by
				,opportunity_creation_date = p_new_creation_date
                                ,sales_methodology_id = p_new_sales_methodology_id
			Where lead_id = p_old_lead_id;
		End;
    	If (((NVL(p_new_total_amount,0) <> NVL(p_old_total_amount,0)) Or
	   (NVL(p_new_currency_code,' ') <> NVL(p_old_currency_code,' ')) Or
	   (p_new_decision_date <> p_old_decision_date) Or
	   (NVL(p_new_win_probability,0) <> NVL(p_old_win_probability,0)) ) Or
	   (NVL(p_new_status,' ') <>  NVL(p_old_status,' ') )) then
		For curr_rec_sc_amt IN c_sales_credit_amount (p_new_lead_id) Loop
	                l_conversion_status_flag := 1;
                        l_sc_amount := curr_rec_sc_amt.sales_credit_amount;
                        l_weighted_amount := l_sc_amount * NVL(p_new_win_probability,0)/100;
                        l_converted_weighted_amount := l_weighted_amount;
		        l_won_amount := 0;
 		        l_converted_won_amount := 0;
                        If (l_win_loss_indicator = 'W') then
                                l_won_amount := l_sc_amount;
 		        	l_converted_won_amount := l_won_amount;
                        End If;
	                convert_amounts(p_new_currency_code, trunc(nvl(p_new_decision_date,p_new_creation_date)), l_total_amount,l_sc_amount,l_converted_won_amount,l_converted_weighted_amount, l_conversion_status_flag);

				Update as_sales_credits_denorm
				Set object_version_number =  nvl(object_version_number,0) + 1, c1_sales_credit_amount = l_sc_amount,
				    won_amount = l_won_amount,
				    weighted_amount = l_weighted_amount,
				    c1_won_amount = l_converted_won_amount,
				    c1_weighted_amount = l_converted_weighted_amount,
				    request_id = NULL,
				    conversion_status_flag = l_conversion_status_flag
				Where sales_credit_id = curr_rec_sc_amt.sales_credit_id;
	         End Loop;  -- Sales Credit for the new p_new_lead_id Loop
        End If; -- <>
        -- Closed date fix for ASN. If decision date has changed then
        -- Update denorm table forecast_dates to the new value where there
        -- is no line forecast date.
        If p_new_decision_date <> p_old_decision_date Then
		    For curr_rec_nofrcst IN c_no_line_forecasts (p_new_lead_id) Loop
				Update as_sales_credits_denorm
				Set object_version_number =  nvl(object_version_number,0) + 1,
				    forecast_date = trunc(p_new_decision_date)
				Where lead_line_id = curr_rec_nofrcst.lead_line_id;
            End Loop;
        End If;
	Elsif p_trigger_mode = 'ON-DELETE' then
		Begin
			Delete as_sales_credits_denorm
			Where lead_id = p_old_lead_id;
		End;
	End If;
    Exception
    When FND_API.G_EXC_UNEXPECTED_ERROR then
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR, 'Error in Leads Trg:' || sqlerrm);
          END IF;

          FND_MSG_PUB.Add_Exc_Msg('AS_SC_DENORM_TRG', 'Leads_Trigger_Handler');
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    When Others then
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
     		'Error in Leads Trg:' || sqlerrm);
	  END IF;
          FND_MSG_PUB.Add_Exc_Msg('AS_SC_DENORM_TRG', 'Leads_Trigger_Handler');
End  Leads_Trigger_Handler;

Procedure Lead_Lines_Trigger_Handler(
				p_new_last_update_date IN as_lead_lines_all.last_update_date%type ,
				p_new_last_updated_by  IN as_lead_lines_all.last_updated_by%type,
				p_new_creation_date  IN as_lead_lines_all.creation_date%type,
				p_new_created_by     IN as_lead_lines_all.created_by%type,
				p_new_last_update_login  IN as_lead_lines_all.last_update_login%type,
				p_new_lead_id		IN as_lead_lines_all.lead_id%type,
				p_new_lead_line_id	IN as_lead_lines_all.lead_line_id%type,
				p_new_interest_type_id	IN as_lead_lines_all.interest_type_id%type,
				p_new_primary_interest_code_id	IN as_lead_lines_all.primary_interest_code_id%type,
				p_new_sec_interest_code_id IN as_lead_lines_all.secondary_interest_code_id%type,
				p_new_product_category_id	IN as_lead_lines_all.product_category_id%type,
				p_new_product_cat_set_id	IN as_lead_lines_all.product_cat_set_id%type,
				p_new_total_amount IN as_lead_lines_all.total_amount%type,
				p_old_total_amount IN as_lead_lines_all.total_amount%type,
				p_old_lead_line_id	IN as_lead_lines_all.lead_line_id%type,
				p_new_quantity IN as_lead_lines_all.quantity%type,
				p_new_uom_code IN as_lead_lines_all.uom_code%type,
				p_new_inventory_item_id IN as_lead_lines_all.inventory_item_id%type,
				p_new_organization_id IN as_lead_lines_all.organization_id%type,
                    	p_old_frcst_date IN as_lead_lines_all.forecast_date%type,
                    	p_old_rolling_frcst_flg IN as_lead_lines_all.rolling_forecast_flag%type,
                    	p_new_frcst_date IN as_lead_lines_all.forecast_date%type,
                    	p_new_rolling_frcst_flg IN as_lead_lines_all.rolling_forecast_flag%type,
				p_trigger_mode  IN VARCHAR2) IS

Cursor c_sales_credit_amount (p_lead_line_id as_lead_lines_all.lead_id%type)  IS
	Select sales_credit_id, credit_amount, credit_percent
	From as_sales_credits
	Where lead_line_id = p_lead_line_id;

--l_interest_type			as_interest_types_tl.interest_type%TYPE;
--l_primary_interest_code		as_interest_codes_tl.code%TYPE;
--l_secondary_interest_code	as_interest_codes_tl.code%TYPE;
l_status			as_leads_all.status%TYPE;
l_lead_total_amount		as_leads_all.total_amount%TYPE;
l_decision_date			as_leads_all.decision_date%TYPE;
l_currency_code			AS_LEADS_ALL.currency_code%TYPE;
l_total_amount			NUMBER;
l_sc_amount			NUMBER;
l_won_amount			NUMBER;
l_weighted_amount		NUMBER;
l_converted_won_amount		NUMBER;
l_converted_weighted_amount	NUMBER;
l_conversion_status_flag	NUMBER;
l_sales_credit_amount		NUMBER;
l_win_probability		NUMBER;
l_uom_description		as_sales_credits_denorm.uom_description%type;
l_item_description		as_sales_credits_denorm.item_description%type;
l_new_frcst_date as_lead_lines_all.forecast_date%type;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

Begin
    IF l_debug THEN
    	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Lead_Lines_Trigger_Handler Start');
    END IF;

	If p_trigger_mode = 'ON-UPDATE' then
	    Begin
			Select lead.total_amount , trunc(lead.decision_date) decision_date, lead.currency_code, lead.win_probability, status.win_loss_indicator
			 Into  l_lead_total_amount, l_decision_date, l_currency_code, l_win_probability, l_status
			From as_leads_all lead, as_statuses_vl status
			Where lead_id = p_new_lead_id
			And lead.status = status.status_code(+);

            If p_new_frcst_date IS NULL THEN
                l_new_frcst_date := l_decision_date;
            Else
                l_new_frcst_date := trunc(p_new_frcst_date);
            End If;

            Begin
                Select unit_of_measure_tl Into l_uom_description
                From mtl_units_of_measure_tl
                Where uom_code = p_new_uom_code
                And language = userenv('LANG');
            Exception When others then
                    l_uom_description := Null;
            End;

            Begin
                Select description Into l_item_description
                From mtl_system_items_tl
                Where inventory_item_id = p_new_inventory_item_id
                And organization_id = p_new_organization_id
                And language = userenv('LANG');
            Exception When others then
                    l_item_description := Null;
            End;


            /* Commented by gbatra for product hierarchy uptake
            Fetch_Interest_Info (p_new_interest_type_id, l_interest_type
                              ,p_new_primary_interest_code_id, l_primary_interest_code
                              ,p_new_sec_interest_code_id, l_secondary_interest_code);
            */

    		If ((p_new_total_amount = p_old_total_amount) and (nvl(p_old_frcst_date,to_date('01/01/1900','DD/MM/RRRR')) = nvl(p_new_frcst_date,to_date('01/01/1900','DD/MM/RRRR'))) and (nvl(p_old_rolling_frcst_flg,'#') = nvl(p_new_rolling_frcst_flg,'#'))) then
			Update as_sales_credits_denorm
		     	Set object_version_number =  nvl(object_version_number,0) + 1,  last_update_date = SYSDATE
			     ,last_updated_by = NVL(FND_GLOBAL.login_id,-1)
			     ,creation_date = SYSDATE
			     ,created_by = p_new_created_by
			     ,last_update_login = p_new_last_update_login
			     ,lead_line_id = p_new_lead_line_id
			     ,interest_type_id = NVL(p_new_interest_type_id,-1)
			     ,primary_interest_code_id = NVL(p_new_primary_interest_code_id,-1)
			     ,secondary_interest_code_id = NVL(p_new_sec_interest_code_id ,-1)
			     ,product_category_id = NVL(p_new_product_category_id,-1)
			     ,product_cat_set_id = NVL(p_new_product_cat_set_id,-1)
			     --,interest_type = l_interest_type
			     --,primary_interest_code = l_primary_interest_code
			     --,secondary_interest_code = l_secondary_interest_code
			     ,request_id = Null
			     ,quantity = p_new_quantity
			     ,uom_code = p_new_uom_code
			     ,uom_description = l_uom_description
			     ,item_id = p_new_inventory_item_id
			     ,organization_id = p_new_organization_id
			     ,item_description = l_item_description
		             ,forecast_date = l_new_frcst_date
			     ,rolling_forecast_flag = p_new_rolling_frcst_flg
                         Where lead_line_id = p_old_lead_line_id;
				Return;
			Elsif ((NVL(p_new_total_amount,0) <> NVL(p_old_total_amount,0))
		 	      or (nvl(p_old_frcst_date,to_date('01/01/1900','DD/MM/RRRR')) <> nvl(p_new_frcst_date,to_date('01/01/1900','DD/MM/RRRR')))
				or (nvl(p_old_rolling_frcst_flg,'#') <> nvl(p_new_rolling_frcst_flg,'#'))) then
				For curr_rec_sc_amt IN c_sales_credit_amount (p_old_lead_line_id ) Loop
					If curr_rec_sc_amt.credit_percent IS NULL then
						l_sales_credit_amount := NVL(curr_rec_sc_amt.credit_amount ,0);
					Else
						l_sales_credit_amount := (curr_rec_sc_amt.credit_percent /100) * p_new_total_amount;
					End If;
                                 l_conversion_status_flag := 1;
                        	 l_sc_amount := l_sales_credit_amount;
                        	 l_weighted_amount := l_sc_amount * NVL(l_win_probability,0)/100;
                        	 l_converted_weighted_amount := l_weighted_amount;
                        	 l_won_amount := 0;
                        	 l_converted_won_amount := 0;
                        	 If (l_status = 'W') then
                                	l_won_amount := l_sc_amount;
                                	l_converted_won_amount := l_won_amount;
                        	 End If;
                                 convert_amounts(l_currency_code, trunc(nvl(l_decision_date,p_new_creation_date)), l_total_amount,l_sc_amount,l_converted_won_amount,l_converted_weighted_amount, l_conversion_status_flag);
				Update as_sales_credits_denorm
		     		Set object_version_number =  nvl(object_version_number,0) + 1, last_update_date = sysdate
				    ,last_updated_by = NVL(FND_GLOBAL.login_id,-1)
				    ,creation_date = sysdate
				    ,created_by = p_new_created_by
				    ,last_update_login = p_new_last_update_login
				    ,lead_line_id = p_new_lead_line_id
				    ,interest_type_id = NVL(p_new_interest_type_id,-1)
				    ,primary_interest_code_id = NVL(p_new_primary_interest_code_id,-1)
				    ,secondary_interest_code_id = NVL(p_new_sec_interest_code_id ,-1)
			        ,product_category_id = NVL(p_new_product_category_id,-1)
			        ,product_cat_set_id = NVL(p_new_product_cat_set_id,-1)
		     		    ,c1_sales_credit_amount =l_sc_amount
				    ,won_amount =l_won_amount
				    ,weighted_amount =l_weighted_amount
				    ,c1_won_amount =l_converted_won_amount
				    ,c1_weighted_amount =l_converted_weighted_amount
				    --,interest_type = l_interest_type
				    --,primary_interest_code = l_primary_interest_code
				    --,secondary_interest_code = l_secondary_interest_code
				    ,request_id = NULL
				    ,quantity = p_new_quantity
				    ,uom_code = p_new_uom_code
				    ,uom_description = l_uom_description
				    ,item_id = p_new_inventory_item_id
				    ,organization_id = p_new_organization_id
				    ,item_description = l_item_description
				    ,conversion_status_flag = l_conversion_status_flag
				    ,forecast_date = l_new_frcst_date
				    ,rolling_forecast_flag = p_new_rolling_frcst_flg
				    Where  sales_credit_id  =  curr_rec_sc_amt.sales_credit_id;
				End Loop; -- c_sales_credit_amount Loop
			End If;
	End;
	Elsif p_trigger_mode = 'ON-DELETE' then
		Delete as_sales_credits_denorm
		Where lead_line_id = p_old_lead_line_id;
	End If;

    Exception
    When FND_API.G_EXC_UNEXPECTED_ERROR then
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
              'Error in Lead Lines Trg:' || sqlerrm);
          END IF;

          FND_MSG_PUB.Add_Exc_Msg('AS_SC_DENORM_TRG', 'Lead_Lines_Trigger_Handler');
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	When Others then
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
     		'Error in Lead Lines Trg:' || sqlerrm);
     	  END IF;

          FND_MSG_PUB.Add_Exc_Msg('AS_SC_DENORM_TRG', 'Lead_Lines_Trigger_Handler');
End  Lead_Lines_Trigger_Handler;

Procedure Sales_Credit_Trg_Handler(
				p_new_sales_credit_id         IN NUMBER,
				p_new_last_update_date        IN DATE,
				p_new_last_updated_by         IN NUMBER,
				p_new_creation_date           IN DATE,
				p_new_created_by              IN NUMBER,
				p_new_last_update_login       IN NUMBER,
				p_new_request_id              IN NUMBER,
				p_new_lead_id                 IN NUMBER,
				p_new_lead_line_id            IN NUMBER,
				p_new_salesforce_id           IN NUMBER,
				p_new_person_id               IN NUMBER,
				p_new_salesgroup_id           IN NUMBER,
				p_new_credit_amount           IN NUMBER,
				p_new_credit_percent          IN NUMBER,
				p_old_sales_credit_id         IN NUMBER,
				p_new_credit_type_id          IN NUMBER,
                    		p_new_partner_address_id      IN NUMBER,
				p_old_partner_customer_id     IN NUMBER,
				p_new_partner_customer_id     IN NUMBER,
                p_opp_worst_forecast_amount IN NUMBER,
                p_opp_forecast_amount       IN NUMBER,
                p_opp_best_forecast_amount  IN NUMBER,
				p_trigger_mode  	      IN OUT NOCOPY VARCHAR2) IS

l_sales_group_name	      	varchar2(100);
l_sales_rep_name	      	jtf_rs_resource_extns.source_name%TYPE;
l_first_name		      	jtf_rs_resource_extns.source_first_name%TYPE;
l_last_name		      	jtf_rs_resource_extns.source_last_name%TYPE;
l_employee_number	      	jtf_rs_resource_extns.source_number%TYPE;
l_org_id		      	as_leads_all.org_id%TYPE;
--l_interest_type		      	as_interest_types_tl.interest_type%TYPE;
--l_primary_interest_code	      	as_interest_codes_tl.code%TYPE;
--l_secondary_interest_code     	as_interest_codes_tl.code%TYPE;
l_customer_id			as_leads_all.customer_id%TYPE;
l_customer_name			as_party_customers_v.CUSTOMER_NAME%TYPE;
l_party_type			as_party_customers_v.party_type%TYPE;
l_address_id			as_leads_all.address_id%TYPE;
l_lead_number			as_leads_all.lead_number%TYPE;
l_opp_description	        as_leads_all.description%TYPE;
l_decision_date			as_leads_all.decision_date%TYPE;
l_sales_stage_id	        as_leads_all.sales_stage_id%TYPE;
l_source_promotion_id	      	as_leads_all.source_promotion_id%TYPE;
l_close_competitor_id	      	as_leads_all.close_competitor_id%TYPE;
l_owner_salesforce_id		as_leads_all.owner_salesforce_id%TYPE;
l_owner_sales_group_id		as_leads_all.owner_sales_group_id%TYPE;
l_competitor_name 		hz_parties.party_name%TYPE;
l_owner_person_name	      	jtf_rs_resource_extns.source_name%TYPE;
l_owner_first_name		jtf_rs_resource_extns.source_first_name%TYPE;
l_owner_last_name		jtf_rs_resource_extns.source_last_name%TYPE;
l_owner_group_name	jtf_rs_groups_tl.group_name%TYPE;
l_sales_stage			as_sales_stages.name%TYPE;
l_win_probability		as_leads_all.win_probability%TYPE;
l_status_code			as_leads_all.status%TYPE;
l_sales_methodology_id		as_leads_all.sales_methodology_id%TYPE;
l_status			as_statuses_tl.meaning%TYPE;
l_channel_code			as_leads_all.channel_code%TYPE;
l_lead_source_code		as_leads_all.lead_source_code%TYPE;
l_deleted_flag			as_leads_all.deleted_flag%Type;
l_orig_system_reference		as_leads_all.orig_system_reference%TYPE;
l_lead_line_id			as_lead_lines_all.lead_line_id%TYPE;
l_interest_type_id		as_lead_lines_all.INTEREST_TYPE_ID%TYPE;
l_primary_interest_code_id	as_lead_lines_all.PRIMARY_INTEREST_CODE_ID%TYPE;
l_secondary_interest_code_id	as_lead_lines_all.SECONDARY_INTEREST_CODE_ID%TYPE;
l_product_category_id		as_lead_lines_all.PRODUCT_CATEGORY_ID%TYPE;
l_product_cat_set_id		as_lead_lines_all.PRODUCT_CAT_SET_ID%TYPE;
l_currency_code			as_leads_all.currency_code%TYPE;
l_customer_category		ar_lookups.meaning%TYPE;
l_customer_category_code	as_party_customers_v.customer_category_code%TYPE;
l_leadline_total_amount		as_lead_lines_all.total_amount%TYPE;
l_lead_total_amount		as_leads_all.total_amount%TYPE;
l_total_amount			NUMBER;
l_sc_amount			NUMBER;
l_won_amount			NUMBER;
l_weighted_amount		NUMBER;
l_converted_won_amount		NUMBER;
l_converted_weighted_amount	NUMBER;
l_conversion_rate_found		VARCHAR2(1);
l_conversion_status_flag	NUMBER;
l_sales_credit_amount		NUMBER;
l_win_loss_indicator		as_statuses_b.win_loss_indicator%Type;
l_forecast_rollup_flag		as_statuses_b.forecast_rollup_flag%Type;
l_opp_open_status_flag		as_statuses_b.opp_open_status_flag%Type;
l_quantity			as_lead_lines.quantity%Type;
l_uom_code			as_lead_lines.uom_code%Type;
l_uom_description		as_sales_credits_denorm.uom_description%Type;
l_item_id			as_lead_lines.inventory_item_id%Type;
l_organization_id		as_lead_lines.organization_id%Type;
l_item_description		as_sales_credits_denorm.item_description%Type;
l_revenue_flag			aso_i_sales_credit_types_v.quota_flag%Type;
l_parent_project	        as_leads_all.parent_project%Type;
l_partner_cust_name		hz_parties.party_name%Type;
l_business_group_name           hr_all_organization_units_tl.name%Type;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

Begin
    IF l_debug THEN
    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Sales_Credit_Trg_Handler Start');
    END IF;

    If (p_Trigger_Mode = 'ON-DELETE') then
	Begin
	  Delete From as_sales_credits_denorm
	  Where sales_credit_id = p_old_sales_credit_id;
          Return;
     End;
    End If;

   Select customer_id,
		address_id,
		lead_number,
		description,
		trunc(decision_date) decision_date,
		sales_stage_id,
		source_promotion_id,
		close_competitor_id,
		owner_salesforce_id,
		owner_sales_group_id,
		win_probability,
		status,
		channel_code,
		lead_source_code,
		orig_system_reference,
		currency_code,
		total_amount,
		org_id,
		deleted_flag,
		parent_project,
		last_update_date,
		last_updated_by,
		creation_date,
            	created_by,
            	close_reason,
            	attribute_category,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		attribute10,
		attribute11,
		attribute12,
		attribute13,
		attribute14,
		attribute15,
                sales_methodology_id
	Into
		l_customer_id,
		l_address_id,
		l_lead_number,
		l_opp_description,
		l_decision_date,
		l_sales_stage_id,
		l_source_promotion_id,
		l_close_competitor_id,
		l_owner_salesforce_id,
		l_owner_sales_group_id,
		l_win_probability,
		l_status_code,
		l_channel_code,
		l_lead_source_code,
		l_orig_system_reference,
		l_currency_code,
		l_lead_total_amount,
		l_org_id,
		l_deleted_flag,
            	l_parent_project,
            	as_sc_denorm.scd_opp_last_upd_date(1),
            	as_sc_denorm.scd_opp_last_upd_by(1),
		as_sc_denorm.scd_opp_creation_date(1),
            	as_sc_denorm.scd_opp_created_by(1),
            	as_sc_denorm.scd_close_reason(1),
            	as_sc_denorm.scd_attribute_category(1),
            	as_sc_denorm.scd_attribute1(1),
            	as_sc_denorm.scd_attribute2(1),
            	as_sc_denorm.scd_attribute3(1),
            	as_sc_denorm.scd_attribute4(1),
            	as_sc_denorm.scd_attribute5(1),
            	as_sc_denorm.scd_attribute6(1),
            	as_sc_denorm.scd_attribute7(1),
            	as_sc_denorm.scd_attribute8(1),
            	as_sc_denorm.scd_attribute9(1),
            	as_sc_denorm.scd_attribute10(1),
            	as_sc_denorm.scd_attribute11(1),
            	as_sc_denorm.scd_attribute12(1),
            	as_sc_denorm.scd_attribute13(1),
            	as_sc_denorm.scd_attribute14(1),
            	as_sc_denorm.scd_attribute15(1),
                l_sales_methodology_id
	From as_leads_all
	Where lead_id = p_new_lead_id;

	Begin
		Select group_name
		  Into l_sales_group_name
		From jtf_rs_groups_tl
		Where group_id = p_new_salesgroup_id
		And language = userenv('LANG');
	Exception When Others then
		l_sales_group_name := Null;
	End;

    Begin
          Select party_name
		 Into l_partner_cust_name
          From hz_parties
		Where party_id = p_new_partner_customer_id;
    Exception When Others then
	    l_partner_cust_name := Null;
    End;

     Begin
		Select quota_flag
		 Into l_revenue_flag
		From aso_i_sales_credit_types_v
		Where sales_credit_type_id = p_new_credit_type_id;
	Exception When Others then
  		l_revenue_flag := Null;
	End;

	Begin
		Select source_name, source_first_name, source_last_name, source_number
		 Into l_sales_rep_name, l_first_name, l_last_name, l_employee_number
        From jtf_rs_resource_extns
		Where resource_id = p_new_salesforce_id
                and category IN ('EMPLOYEE','PARTY');
	Exception When Others then
		l_sales_rep_name := Null;
		l_first_name := Null;
		l_last_name := Null;
		l_employee_number := Null;
	End;

	Begin
		Select party_name, party_type, category_code
		 Into  l_customer_name, l_party_type, l_customer_category_code
		From hz_parties cust, as_leads_all lead
		Where lead.customer_id = cust.party_id
		And lead.lead_id = p_new_lead_id;
	Exception When Others then
		l_customer_name  := Null;
		l_party_type     := Null;
		l_customer_category_code := Null;
	End;

	Begin
		Select meaning
		 Into l_customer_category
		From	ar_lookups arlkp
		Where arlkp.lookup_type = 'CUSTOMER_CATEGORY'
		And arlkp.lookup_code = l_customer_category_code;
	Exception When others then
		l_customer_category := Null;
	End;


	begin
		select party_name
		into l_competitor_name
		from hz_parties
		where party_id = l_close_competitor_id;
	exception
		when others then
		l_competitor_name := NULL;
	end;

 		Begin
			Select source_name, source_first_name, source_last_name
		 	Into l_owner_person_name, l_owner_first_name, l_owner_last_name
        	From jtf_rs_resource_extns
			Where resource_id = l_owner_salesforce_id
                	and category IN ('EMPLOYEE','PARTY');
		Exception When Others then
			l_owner_person_name := Null;
			l_owner_first_name := Null;
			l_owner_last_name := Null;
		End;

		Begin
			Select group_name
		  	Into l_owner_group_name
			From jtf_rs_groups_tl
			Where group_id = l_owner_sales_group_id
			And language = userenv('LANG');
		Exception When Others then
			l_owner_group_name := Null;
		End;


     Begin
		Select meaning
		 Into as_sc_denorm.scd_close_reason_men(1)
		From as_lookups aslkp
		Where aslkp.lookup_type = 'CLOSE_REASON'
		And aslkp.lookup_code = as_sc_denorm.scd_close_reason(1);
		Exception
		 When others then
			as_sc_denorm.scd_close_reason_men(1) := NULL;
	End;

     Begin
     	Select source_name
	 Into as_sc_denorm.scd_opp_created_name(1)
	From jtf_rs_resource_extns
      Where user_id = as_sc_denorm.scd_opp_created_by(1);
 	 Exception
	  When Others then
	   as_sc_denorm.scd_opp_created_name(1) := Null;
	End;

     Begin
     	Select source_name
		 Into as_sc_denorm.scd_opp_last_upd_name(1)
		From jtf_rs_resource_extns
          Where user_id = as_sc_denorm.scd_opp_last_upd_by(1);
 		Exception
			When Others then
			 as_sc_denorm.scd_opp_last_upd_name(1) := Null;
	End;

	Begin
		Select name
		 Into l_sales_stage
		From  as_sales_stages_all_tl sales, as_leads_all lead
		Where sales.sales_stage_id = lead.sales_stage_id
		And lead.lead_id = p_new_lead_id
		And sales.language = userenv('LANG');
	Exception When Others then
		l_sales_stage  := Null;
	End;

	Begin
		Select meaning, win_loss_indicator, forecast_rollup_flag, opp_open_status_flag
	     Into l_status, l_win_loss_indicator, l_forecast_rollup_flag, l_opp_open_status_flag
		From as_statuses_vl status,
			as_leads_all lead
		Where lead.status = status.status_code
                --And status.language = userenv('LANG')
		And lead.lead_id = p_new_lead_id;
	Exception When Others then
	  l_status             	:= Null;
          l_win_loss_indicator   	:= Null;
          l_forecast_rollup_flag 	:= Null;
          l_opp_open_status_flag 	:= Null;
	End;


	Begin
		Select lead_line_id, nvl(interest_type_id,-1), nvl(primary_interest_code_id,-1),
               nvl(secondary_interest_code_id,-1),
               nvl(product_category_id, -1), nvl(product_cat_set_id, -1),
               total_amount, quantity, uom_code, inventory_item_id, organization_id, trunc(nvl(forecast_date, l_decision_date)), rolling_forecast_flag
		Into l_lead_line_id, l_interest_type_id, l_primary_interest_code_id,
		     l_secondary_interest_code_id, l_product_category_id, l_product_cat_set_id, l_leadline_total_amount, l_quantity, l_uom_code, l_item_id, l_organization_id, as_sc_denorm.scd_frcst_date(1), as_sc_denorm.scd_rolling_frcst_flg(1)
		From as_lead_lines_all
		Where lead_id = p_new_lead_id
		And lead_line_id = p_new_lead_line_id;
	Exception When Others then
		l_lead_line_id := Null;
		l_interest_type_id := -1;
		l_primary_interest_code_id := -1;
		l_secondary_interest_code_id  := -1;
		l_product_category_id := -1;
		l_product_cat_set_id := -1;
		l_leadline_total_amount := Null;
		l_quantity := Null;
		l_uom_code := Null;
		l_item_id  := Null;
		l_organization_id := Null;
        as_sc_denorm.scd_frcst_date(1) := l_decision_date;
		as_sc_denorm.scd_rolling_frcst_flg(1) := Null;
	End;

    	Begin
        Select unit_of_measure_tl Into l_uom_description
        From mtl_units_of_measure_tl
        Where uom_code = l_uom_code
        And language = userenv('LANG');
	Exception When others then
     	l_uom_description := Null;
    	End;

    	Begin
        Select description Into l_item_description
        From mtl_system_items_tl
        Where inventory_item_id = l_item_id
        And organization_id = l_organization_id
        And language = userenv('LANG');
	Exception When others then
     	l_item_description := Null;
    	End;

    	Begin
       	Select name Into l_business_group_name
        From hr_all_organization_units_tl
        Where organization_id = l_org_id
        and language = userenv('LANG');
	Exception When others then
     		l_business_group_name := Null;
    	End;

        /* Commented by gbatra for product hierarchy uptake
    	Fetch_Interest_Info (l_interest_type_id, l_interest_type
                              ,l_primary_interest_code_id, l_primary_interest_code
                              ,l_secondary_interest_code_id, l_secondary_interest_code);
        */

	If p_new_credit_percent IS NULL then
		l_sales_credit_amount := NVL(p_new_credit_amount,0);
	Else
		l_sales_credit_amount := (p_new_credit_percent/100) * l_leadline_total_amount;
	End if;

     Begin
              l_conversion_status_flag := 1;
              l_total_amount := l_lead_total_amount;
              l_sc_amount := l_sales_credit_amount;
              l_weighted_amount := l_sc_amount * NVL(l_win_probability,0)/100;
              l_converted_weighted_amount := l_weighted_amount;
              l_won_amount := 0;
              l_converted_won_amount := 0;
              If (l_win_loss_indicator = 'W') then
              	l_won_amount := l_sc_amount;
                l_converted_won_amount := l_won_amount;
              End If;
              convert_amounts(l_currency_code,  trunc(nvl(l_decision_date,p_new_creation_date)), l_total_amount,l_sc_amount,l_converted_won_amount,l_converted_weighted_amount, l_conversion_status_flag);
			 If p_Trigger_Mode = 'ON-UPDATE' then
               		Update as_sales_credits_denorm
					Set object_version_number =  nvl(object_version_number,0) + 1,  sales_credit_id = p_new_sales_credit_id
						,opportunity_last_update_date = as_sc_denorm.scd_opp_last_upd_date(1)
						,opportunity_last_updated_by = as_sc_denorm.scd_opp_last_upd_by(1)
						,last_update_date = sysdate
						,last_updated_by = NVL(FND_GLOBAL.login_id,-1)
						,creation_date = sysdate
						,created_by = p_new_created_by
						,last_update_login = p_new_last_update_login
						,sales_group_id = p_new_salesgroup_id
						,sales_group_name = l_sales_group_name
						,salesforce_id = p_new_salesforce_id
						,employee_person_id = p_new_person_id
						,sales_rep_name = l_sales_rep_name
						,customer_id = l_customer_id
						,customer_name	= l_customer_name
						,address_id = l_address_id
						,lead_id = p_new_lead_id
						,lead_number = l_lead_number
						,opp_description = l_opp_description
						,decision_date	= l_decision_date
						,sales_stage_id = l_sales_stage_id
						,source_promotion_id = l_source_promotion_id
						,close_competitor_id = l_close_competitor_id
						,owner_salesforce_id = l_owner_salesforce_id
						,owner_sales_group_id = l_owner_sales_group_id
						,competitor_name = l_competitor_name
						,owner_person_name = l_owner_person_name
						,owner_last_name = l_owner_last_name
						,owner_first_name = l_owner_first_name
						,owner_group_name = l_owner_group_name
						,sales_stage = l_sales_stage
						,win_probability = l_win_probability
						,status_code = l_status_code
						,status = l_status
						,channel_code = l_channel_code
						,lead_source_code = l_lead_source_code
						,orig_system_reference = l_orig_system_reference
						,lead_line_id = l_lead_line_id
						,interest_type_id = l_interest_type_id
						,primary_interest_code_id = l_primary_interest_code_id
						,secondary_interest_code_id = l_secondary_interest_code_id
						,product_category_id = l_product_category_id
						,product_cat_set_id = l_product_cat_set_id
						,currency_code = l_currency_code
						,total_amount = l_lead_total_amount
						,sales_credit_amount = l_sales_credit_amount
						,c1_currency_code = FND_PROFILE.Value('AS_PREFERRED_CURRENCY')
						,c1_total_amount = l_total_amount
						,c1_sales_credit_amount = l_sc_amount
						,won_amount = l_won_amount
						,weighted_amount = l_weighted_amount
						,c1_won_amount	= l_converted_won_amount
						,c1_weighted_amount = l_converted_weighted_amount
						,customer_category = l_customer_category
						,customer_category_code = l_customer_category_code
						,first_name = l_first_name
						,last_name = l_last_name
						,org_id = l_org_id
                              			,business_group_name = l_business_group_name
						--,interest_type = l_interest_type
						--,primary_interest_code = l_primary_interest_code
						--,secondary_interest_code	= l_secondary_interest_code
						,request_id = Null
						,conversion_status_flag = l_conversion_status_flag
						,party_type = l_party_type
						,forecast_rollup_flag = l_forecast_rollup_flag
						,win_loss_indicator = l_win_loss_indicator
						,opp_open_status_flag = l_opp_open_status_flag
						,opp_deleted_flag = l_deleted_flag
						,employee_number = l_employee_number
						,quantity = l_quantity
						,uom_code = l_uom_code
						,uom_description = l_uom_description
						,item_id = l_item_id
						,organization_id = l_organization_id
						,item_description = l_item_description
						,credit_type_id = p_new_credit_type_id
						,revenue_flag = l_revenue_flag
						,parent_project = l_parent_project
						,partner_customer_id = p_new_partner_customer_id
						,partner_address_id = p_new_partner_address_id
						,partner_customer_name = l_partner_cust_name
						,attribute_category = as_sc_denorm.scd_attribute_category(1)
						,attribute1 = as_sc_denorm.scd_attribute1(1)
						,attribute2 = as_sc_denorm.scd_attribute2(1)
						,attribute3 = as_sc_denorm.scd_attribute3(1)
						,attribute4 = as_sc_denorm.scd_attribute4(1)
						,attribute5 = as_sc_denorm.scd_attribute5(1)
						,attribute6 = as_sc_denorm.scd_attribute6(1)
						,attribute7 = as_sc_denorm.scd_attribute7(1)
						,attribute8 = as_sc_denorm.scd_attribute8(1)
						,attribute9 = as_sc_denorm.scd_attribute9(1)
						,attribute10 = as_sc_denorm.scd_attribute10(1)
						,attribute11 = as_sc_denorm.scd_attribute11(1)
						,attribute12 = as_sc_denorm.scd_attribute12(1)
						,attribute13 = as_sc_denorm.scd_attribute13(1)
						,attribute14 = as_sc_denorm.scd_attribute14(1)
						,attribute15 = as_sc_denorm.scd_attribute15(1)
						,forecast_date = as_sc_denorm.scd_frcst_date(1)
						,rolling_forecast_flag = as_sc_denorm.scd_rolling_frcst_flg(1)
						,close_reason = as_sc_denorm.scd_close_reason(1)
						,close_reason_meaning = as_sc_denorm.scd_close_reason_men(1)
						,opportunity_last_updated_name = as_sc_denorm.scd_opp_last_upd_name(1)
						,opportunity_created_name = as_sc_denorm.scd_opp_created_name(1)
						,opportunity_created_by = as_sc_denorm.scd_opp_created_by(1)
						,opportunity_creation_date = as_sc_denorm.scd_opp_creation_date(1)
				                ,sales_methodology_id = l_sales_methodology_id
				        ,opp_worst_forecast_amount = p_opp_worst_forecast_amount
				        ,opp_forecast_amount = p_opp_forecast_amount
				        ,opp_best_forecast_amount = p_opp_best_forecast_amount
						Where sales_credit_id = p_old_sales_credit_id;

						If (sql%rowcount <=0) then
                              	p_Trigger_Mode := 'ON-INSERT';
						End If;
                End If;

          If p_Trigger_Mode = 'ON-INSERT' then
			  Insert Into as_sales_credits_denorm
            				(sales_credit_id
            				,opportunity_last_update_date
            				,opportunity_last_updated_by
            				,last_update_date
            				,last_updated_by
            				,creation_date
            				,created_by
            				,last_update_login
            				,sales_group_id
            				,sales_group_name
            				,salesforce_id
            				,employee_person_id
            				,sales_rep_name
            				,customer_id
            				,customer_name
            				,address_id
            				,lead_id
            				,lead_number
            				,opp_description
            				,decision_date
            				,sales_stage_id
					,source_promotion_id
					,close_competitor_id
					,owner_salesforce_id
					,owner_sales_group_id
					,competitor_name
					,owner_person_name
					,owner_last_name
					,owner_first_name
					,owner_group_name
            				,sales_stage
            				,win_probability
            				,status_code
            				,status
            				,channel_code
            				,lead_source_code
            				,orig_system_reference
            				,lead_line_id
            				,interest_type_id
            				,primary_interest_code_id
            				,secondary_interest_code_id
            				,product_category_id
            				,product_cat_set_id
            				,currency_code
            				,total_amount
            				,sales_credit_amount
            				,c1_currency_code
            				,c1_total_amount
            				,c1_sales_credit_amount
            				,won_amount
            				,weighted_amount
            				,c1_won_amount
            				,c1_weighted_amount
            				,customer_category
            				,customer_category_code
            				,first_name
            				,last_name
            				,org_id
                                    	,business_group_name
            				--,interest_type
            				--,primary_interest_code
            				--,secondary_interest_code
            				,conversion_status_flag
					,party_type
					,forecast_rollup_flag
					,win_loss_indicator
					,opp_open_status_flag
					,opp_deleted_flag
					,employee_number
					,quantity
					,uom_code
					,uom_description
					,item_id
					,organization_id
					,item_description
					,credit_type_id
					,revenue_flag
					,parent_project
					,partner_address_id
					,partner_customer_id
					,partner_customer_name
					,opportunity_last_updated_name
					,opportunity_created_name
					,opportunity_creation_date
					,opportunity_created_by
					,close_reason
					,close_reason_meaning
					,attribute_category
					,attribute1
					,attribute2
					,attribute3
					,attribute4
					,attribute5
					,attribute6
					,attribute7
					,attribute8
					,attribute9
					,attribute10
					,attribute11
					,attribute12
					,attribute13
					,attribute14
					,attribute15
					,forecast_date
					,rolling_forecast_flag
                                        ,sales_methodology_id
                    ,opp_worst_forecast_amount
                    ,opp_forecast_amount
                    ,opp_best_forecast_amount)
				     Values
            				(p_new_sales_credit_id
            				,as_sc_denorm.scd_opp_last_upd_date(1)
            				,as_sc_denorm.scd_opp_last_upd_by(1)
            				,sysdate
            				,NVL(FND_GLOBAL.login_id,-1)
            				,SYSDATE
            				,p_new_created_by
            				,p_new_last_update_login
            				,p_new_salesgroup_id
            				,l_sales_group_name
            				,p_new_salesforce_id
            				,p_new_person_id
            				,l_sales_rep_name
            				,l_customer_id
            				,l_customer_name
            				,l_address_id
            				,p_new_lead_id
            				,l_lead_number
            				,l_opp_description
            				,l_decision_date
            				,l_sales_stage_id
					,l_source_promotion_id
					,l_close_competitor_id
					,l_owner_salesforce_id
					,l_owner_sales_group_id
					,l_competitor_name
					,l_owner_person_name
					,l_owner_last_name
					,l_owner_first_name
					,l_owner_group_name
            				,l_sales_stage
            				,l_win_probability
            				,l_status_code
            				,l_status
            				,l_channel_code
            				,l_lead_source_code
            				,l_orig_system_reference
            				,l_lead_line_id
            				,l_interest_type_id
            				,l_primary_interest_code_id
            				,l_secondary_interest_code_id
            				,l_product_category_id
            				,l_product_cat_set_id
            				,l_currency_code
            				,l_lead_total_amount
            				,l_sales_credit_amount
            				,FND_PROFILE.Value('AS_PREFERRED_CURRENCY')
            				,l_total_amount
            				,l_sc_amount
            				,l_won_amount
            				,l_weighted_amount
            				,l_converted_won_amount
            				,l_converted_weighted_amount
            				,l_customer_category
            				,l_customer_category_code
            				,l_first_name
            				,l_last_name
            				,l_org_id
                              		,l_business_group_name
            				--,l_interest_type
            				--,l_primary_interest_code
            				--,l_secondary_interest_code
            				,l_conversion_status_flag
					,l_party_type
					,l_forecast_rollup_flag
					,l_win_loss_indicator
					,l_opp_open_status_flag
					,l_deleted_flag
					,l_employee_number
					,l_quantity
					,l_uom_code
					,l_uom_description
					,l_item_id
					,l_organization_id
					,l_item_description
					,p_new_credit_type_id
					,l_revenue_flag
					,l_parent_project
					,p_new_partner_address_id
					,p_new_partner_customer_id
					,l_partner_cust_name
					,as_sc_denorm.scd_opp_last_upd_name(1)
					,as_sc_denorm.scd_opp_created_name(1)
					,as_sc_denorm.scd_opp_creation_date(1)
					,as_sc_denorm.scd_opp_created_by(1)
					,as_sc_denorm.scd_close_reason(1)
					,as_sc_denorm.scd_close_reason_men(1)
					,as_sc_denorm.scd_attribute_category(1)
					,as_sc_denorm.scd_attribute1(1)
					,as_sc_denorm.scd_attribute2(1)
					,as_sc_denorm.scd_attribute3(1)
					,as_sc_denorm.scd_attribute4(1)
					,as_sc_denorm.scd_attribute5(1)
					,as_sc_denorm.scd_attribute6(1)
					,as_sc_denorm.scd_attribute7(1)
					,as_sc_denorm.scd_attribute8(1)
					,as_sc_denorm.scd_attribute9(1)
					,as_sc_denorm.scd_attribute10(1)
					,as_sc_denorm.scd_attribute11(1)
					,as_sc_denorm.scd_attribute12(1)
					,as_sc_denorm.scd_attribute13(1)
					,as_sc_denorm.scd_attribute14(1)
					,as_sc_denorm.scd_attribute15(1)
					,as_sc_denorm.scd_frcst_date(1)
					,as_sc_denorm.scd_rolling_frcst_flg(1)
					,l_sales_methodology_id
                    ,p_opp_worst_forecast_amount
                    ,p_opp_forecast_amount
                    ,p_opp_best_forecast_amount);
                End if;
	Exception
         When Others then
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                  'Error in Sales Credits Trigger:' || sqlerrm);
              END IF;

              FND_MSG_PUB.Add_Exc_Msg('AS_SC_DENORM_TRG', 'Sales_Credit_Trg_Handler');
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    End;

Exception
    When FND_API.G_EXC_UNEXPECTED_ERROR then
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
              'Error in Sales Credits Trigger:' || sqlerrm);
          END IF;

          FND_MSG_PUB.Add_Exc_Msg('AS_SC_DENORM_TRG', 'Sales_Credit_Trg_Handler');
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	When Others then
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
     		'Error in Sales Credits Trigger:' || sqlerrm);
          END IF;

          FND_MSG_PUB.Add_Exc_Msg('AS_SC_DENORM_TRG', 'Sales_Credit_Trg_Handler');
End Sales_Credit_Trg_Handler;

End AS_SC_DENORM_TRG;

/
