--------------------------------------------------------
--  DDL for Package Body AS_LEADS_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_LEADS_AUDIT_PKG" AS
/* $Header: asxopadb.pls 120.2 2005/09/02 04:05:22 appldev ship $ */

--
-- HISTORY
--
-- 11/05/2003 gbatra	product hierarchy uptake
--
--

Procedure Leads_Trigger_Handler(
	p_new_last_update_date 		IN as_leads_all.last_update_date%type ,
	p_old_last_update_date		IN as_leads_all.last_update_date%type ,
	p_new_last_updated_by 		IN as_leads_all.last_updated_by%type,
	p_new_creation_date 		IN as_leads_all.creation_date%type,
	p_new_created_by 		IN as_leads_all.created_by%type,
	p_new_last_update_login  	IN as_leads_all.last_update_login%type,
	p_new_lead_id 			IN as_leads_all.lead_id%type,
	p_old_lead_id 			IN as_leads_all.lead_id%type,
	p_new_address_id 		IN as_leads_all.address_id%type,
	p_old_address_id 		IN as_leads_all.address_id%type,
	p_new_status 			IN as_leads_all.status%type,
	p_old_status 			IN as_leads_all.status%type,
	p_new_sales_stage_id 		IN as_leads_all.sales_stage_id%type,
	p_old_sales_stage_id 		IN as_leads_all.sales_stage_id%type,
	p_new_channel_code 		IN as_leads_all.channel_code%type,
	p_old_channel_code 		IN as_leads_all.channel_code%type,
	p_new_win_probability 		IN as_leads_all.win_probability%type,
	p_old_win_probability 		IN as_leads_all.win_probability%type,
	p_new_decision_date 		IN as_leads_all.decision_date%type ,
	p_old_decision_date 		IN as_leads_all.decision_date%type ,
	p_new_currency_code 		IN as_leads_all.currency_code%type,
	p_old_currency_code 		IN as_leads_all.currency_code%type,
	p_new_total_amount 		IN as_leads_all.total_amount%type,
	p_old_total_amount 		IN as_leads_all.total_amount%type,
	p_new_security_group_id         IN as_leads_all.security_group_id%type,
	p_old_security_group_id     	IN as_leads_all.security_group_id%type,
   	p_new_customer_id               IN as_leads_all.customer_id%type,
   	p_old_customer_id               IN as_leads_all.customer_id%type,
   	p_new_description           	IN as_leads_all.description%type,
   	p_old_description           	IN as_leads_all.description%type,
   	p_new_source_promotion_id   	IN as_leads_all.source_promotion_id%type,
   	p_old_source_promotion_id   	IN as_leads_all.source_promotion_id%type,
   	p_new_offer_id              	IN as_leads_all.offer_id%type,
   	p_old_offer_id              	IN as_leads_all.offer_id%type,
   	p_new_close_competitor_id   	IN as_leads_all.close_competitor_id%type,
   	p_old_close_competitor_id   	IN as_leads_all.close_competitor_id%type,
   	p_new_vehicle_response_code 	IN as_leads_all.vehicle_response_code%type,
   	p_old_vehicle_response_code 	IN as_leads_all.vehicle_response_code%type,
   	p_new_sales_methodology_id  	IN as_leads_all.sales_methodology_id%type,
   	p_old_sales_methodology_id  	IN as_leads_all.sales_methodology_id%type,
   	p_new_owner_salesforce_id   	IN as_leads_all.owner_salesforce_id%type,
   	p_old_owner_salesforce_id   	IN as_leads_all.owner_salesforce_id%type,
   	p_new_owner_sales_group_id  	IN as_leads_all.owner_sales_group_id%type,
   	p_old_owner_sales_group_id  	IN as_leads_all.owner_sales_group_id%type,
   	p_new_org_id                    IN as_leads_all.org_id%type,
   	p_old_org_id                    IN as_leads_all.org_id%type,
	p_trigger_mode 			IN VARCHAR2)
IS
l_LOG_ID	NUMBER;
IsInsert        NUMBER :=0;
l_debug CONSTANT BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_lead_count	NUMBER :=0;
l_dummy_date     CONSTANT DATE := to_date('31-12-9999', 'DD-MM-YYYY');
BEGIN
-- -- dbms_output.ENABLE(32000);
-- dbms_output.put_line( 'p_trigger_mode = '|| p_trigger_mode );
-- dbms_output.put_line( 'p_old_last_update_date = '|| to_char(p_old_last_update_date, 'DD-MON-YYYY HH:MI:SSSSS')	 );
-- dbms_output.put_line( 'p_new_last_update_date = '|| to_char(p_new_last_update_date, 'DD-MON-YYYY HH:MI:SSSSS')	 );

    IF (UPPER(nvl(FND_PROFILE.VALUE('AS_OPP_ENABLE_LOG'), 'N')) = 'Y' ) THEN

    	update as_leads_log
    	set object_version_number =  nvl(object_version_number,0) + 1, 	log_end_date = p_new_last_update_date,
        	current_log = 0,
		log_active_days = trunc(p_new_last_update_date) - trunc (p_old_last_update_date),
		endday_log_flag = decode (trunc(p_new_last_update_date), trunc (p_old_last_update_date), 'N', 'Y')
	where lead_id = p_new_lead_id
	and   last_update_date = p_old_last_update_date;

    IF ( p_trigger_mode = 'ON-INSERT' ) THEN
	-- dbms_output.put_line('I am in ON-INSERT of Leads_Trigger_Handler');
	-- dbms_output.put_line('Before Calling AS_LEADS_LOG_PKG.Insert_Row');

	AS_LEADS_LOG_PKG.Insert_Row(
          px_LOG_ID   		=> l_LOG_ID,
          p_LEAD_ID    		=> p_new_lead_id,
          p_CREATED_BY    	=> p_new_created_by,
          p_CREATION_DATE    	=> p_new_creation_date,
          p_LAST_UPDATED_BY    	=> p_new_last_updated_by,
          p_LAST_UPDATE_DATE   	=> p_new_last_update_date,
          p_LAST_UPDATE_LOGIN  	=> p_new_last_update_login,
          p_STATUS_CODE    	=> p_new_status,
          p_SALES_STAGE_ID    	=> p_new_sales_stage_id,
          p_WIN_PROBABILITY    	=> p_new_win_probability,
          p_DECISION_DATE    	=> p_new_decision_date,
          p_ADDRESS_ID    	=> p_new_address_id,
          p_CHANNEL_CODE    	=> p_new_channel_code,
          p_CURRENCY_CODE    	=> p_new_currency_code,
          p_TOTAL_AMOUNT    	=> p_new_total_amount ,
	  p_SECURITY_GROUP_ID      =>  p_new_security_group_id,
	  p_CUSTOMER_ID            =>	p_new_customer_id,
 	  p_DESCRIPTION            =>  p_new_description,
	  p_SOURCE_PROMOTION_ID    =>  p_new_source_promotion_id,
	  p_OFFER_ID               =>  p_new_offer_id ,
   	  p_CLOSE_COMPETITOR_ID    =>  p_new_close_competitor_id,
	  p_VEHICLE_RESPONSE_CODE  =>  p_new_vehicle_response_code,
 	  p_SALES_METHODOLOGY_ID   =>  p_new_sales_methodology_id,
	  p_OWNER_SALESFORCE_ID    =>  p_new_owner_salesforce_id,
	  p_OWNER_SALES_GROUP_ID   =>  p_new_owner_sales_group_id,
	  p_LOG_START_DATE	   =>  p_new_last_update_date,
	  p_LOG_END_DATE	   =>  p_new_last_update_date,
	  p_LOG_ACTIVE_DAYS	   =>  0,
	  p_CURRENT_LOG		   =>  1,
	  p_ENDDAY_LOG_FLAG	   => 'Y',
	  p_ORG_ID                 =>  p_new_org_id,
	  p_TRIGGER_MODE	   =>  'I');
        IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'asxopadb: Insert Log: '||l_LOG_ID );
	END IF;

    ELSIF ( p_trigger_mode = 'ON-UPDATE' ) THEN

	 GET_VALUE(p_old_last_update_date, p_new_last_update_date, IsInsert);

	  -- dbms_output.put_line('I am in ON-UPDATE of Leads_Trigger_Handler');
	  -- dbms_output.put_line('ISINSERT VALUE IS:'|| ISInsert);

	 SELECT count(*) INTO l_lead_count
	 FROM   AS_LEADS_LOG
	 WHERE  LEAD_ID = p_old_lead_id;

	 IF ( l_lead_count = 0 ) THEN
	 	-- dbms_output.put_line('AS_LEADS_LOG: Not exists condition'|| l_lead_count);
	 	AS_LEADS_LOG_PKG.Insert_Row(
				px_LOG_ID   		=> l_LOG_ID,
				p_LEAD_ID    		=> p_new_lead_id,
				p_CREATED_BY    	=> p_new_created_by,
				p_CREATION_DATE    	=> p_new_creation_date,
				p_LAST_UPDATED_BY    	=> p_new_last_updated_by,
				p_LAST_UPDATE_DATE   	=> p_new_last_update_date,
				p_LAST_UPDATE_LOGIN  	=> p_new_last_update_login,
				p_STATUS_CODE    	=> p_new_status,
				p_SALES_STAGE_ID    	=> p_new_sales_stage_id,
				p_WIN_PROBABILITY    	=> p_new_win_probability,
				p_DECISION_DATE    	=> p_new_decision_date,
				p_ADDRESS_ID    	=> p_new_address_id,
				p_CHANNEL_CODE    	=> p_new_channel_code,
				p_CURRENCY_CODE    	=> p_new_currency_code,
				p_TOTAL_AMOUNT    	=> p_new_total_amount ,
				p_SECURITY_GROUP_ID      =>  p_new_security_group_id,
				p_CUSTOMER_ID            =>	p_new_customer_id,
				p_DESCRIPTION            =>  p_new_description,
				p_SOURCE_PROMOTION_ID    =>  p_new_source_promotion_id,
				p_OFFER_ID               =>  p_new_offer_id ,
				p_CLOSE_COMPETITOR_ID    =>  p_new_close_competitor_id,
				p_VEHICLE_RESPONSE_CODE  =>  p_new_vehicle_response_code,
				p_SALES_METHODOLOGY_ID   =>  p_new_sales_methodology_id,
				p_OWNER_SALESFORCE_ID    =>  p_new_owner_salesforce_id,
				p_OWNER_SALES_GROUP_ID   =>  p_new_owner_sales_group_id,
			  	p_LOG_START_DATE	   =>  p_new_last_update_date,
			  	p_LOG_END_DATE	   =>  p_new_last_update_date,
			  	p_LOG_ACTIVE_DAYS	   =>  0,
			  	p_CURRENT_LOG		   =>  1,
			  	p_ENDDAY_LOG_FLAG	   => 'Y',
				p_ORG_ID                 =>  p_new_org_id,
				p_TRIGGER_MODE	   =>  'U');
				IF l_debug THEN
					AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
						'asxopadb: Insert Log: '||l_LOG_ID );
				END IF;
	 ELSE
	 	--DBMS_OUTPUT.DISABLE;

	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check new amount value'|| nvl(p_new_address_id,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check old address value'|| nvl(p_old_address_id,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check new amount value'|| nvl(p_new_status,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check old status value'|| nvl(p_old_status,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check new stage value'|| nvl(p_new_sales_stage_id,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check old stage value'|| nvl(p_old_sales_stage_id,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check new channel value'|| nvl(p_new_channel_code,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check old channel value'|| nvl(p_old_channel_code,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check new win value'|| nvl(p_new_win_probability,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check old win value'|| nvl(p_old_win_probability,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check new date value'|| p_new_decision_date);
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check old date value'|| p_old_decision_date);
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check new Curr value'|| nvl(p_new_currency_code,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check old Curr value'|| nvl(p_old_currency_code,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check new tamount value'|| nvl(p_new_total_amount,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check old tamount value'|| nvl(p_old_total_amount,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check new sgroup value'|| nvl(p_new_security_group_id,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check old sgroup value'|| nvl(p_old_security_group_id,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check new customer value'|| nvl(p_new_customer_id,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check old customer value'|| nvl(p_old_customer_id,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check new oppdesc value'|| nvl(p_new_description,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check old oppdesc value'|| nvl(p_old_description,0));
		-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check new spromo value'|| nvl(p_new_source_promotion_id,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check old spromo value'|| nvl(p_old_source_promotion_id,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check new offer value'|| nvl(p_new_offer_id,0));
		-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check old offer value'|| nvl(p_old_offer_id,0));
		-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check new compt value'|| nvl(p_new_close_competitor_id,0));
		-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check old compt value'|| nvl(p_old_close_competitor_id,0));
		-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check new vresp value'|| nvl(p_new_vehicle_response_code,0));
		-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check old vresp value'|| nvl(p_old_vehicle_response_code,0));
		-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check new meth value'|| nvl(p_new_sales_methodology_id,0));
		-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check old meth value'|| nvl(p_old_sales_methodology_id,0));
		-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check new salesf value'|| nvl(p_new_owner_salesforce_id,0));
		-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check old salesf value'|| nvl(p_old_owner_salesforce_id,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check new salesg value'|| nvl(p_new_owner_sales_group_id,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check old salesg value'|| nvl(p_old_owner_sales_group_id,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check new org value'|| nvl(p_new_org_id,0));
	 	-- dbms_output.put_line('AS_LEADS_LOG: Before changes state check old org value'|| nvl(p_old_org_id,0));

	 	IF( (	( nvl(p_new_address_id,0) 	<> nvl(p_old_address_id,0) 		) OR
	 	        ( p_new_last_update_date 	<> p_old_last_update_date 		) OR
 			( nvl(p_new_status,0) 		<> nvl(p_old_status,0) 		) OR
 			( nvl(p_new_sales_stage_id,0) 	<> nvl(p_old_sales_stage_id,0) 	) OR
 			( nvl(p_new_channel_code,0) 	<> nvl(p_old_channel_code,0) 		) OR
 			( nvl(p_new_win_probability,0) 	<> nvl(p_old_win_probability,0) 	) OR
			( nvl(p_new_decision_date, l_dummy_date) 	<> nvl(p_old_decision_date, l_dummy_date) 		) OR
			( nvl(p_new_currency_code,0) 	<> nvl(p_old_currency_code,0) 		) OR
 			( nvl(p_new_total_amount,0) 	<> nvl(p_old_total_amount,0) 		) OR
 			( nvl(p_new_security_group_id,0) 	<> nvl(p_old_security_group_id,0)     	) OR
 			( nvl(p_new_customer_id,0)       	<> nvl(p_old_customer_id,0)            ) OR
 			( nvl(p_new_description,0)       	<> nvl(p_old_description,0)           	) OR
 			( nvl(p_new_source_promotion_id,0) <> nvl(p_old_source_promotion_id,0)   	) OR
 			( nvl(p_new_offer_id,0)            <> nvl(p_old_offer_id,0)              	) OR
 			( nvl(p_new_close_competitor_id,0) <> nvl(p_old_close_competitor_id,0)   	) OR
 			( nvl(p_new_vehicle_response_code,0) 	<> nvl(p_old_vehicle_response_code,0) 	) OR
 			( nvl(p_new_sales_methodology_id,0)  	<> nvl(p_old_sales_methodology_id,0)  	) OR
 			( nvl(p_new_owner_salesforce_id,0)   	<> nvl(p_old_owner_salesforce_id,0)   	) OR
 			( nvl(p_new_owner_sales_group_id,0)  	<> nvl(p_old_owner_sales_group_id,0)  	) OR
 			( nvl(p_new_org_id,0)                  <> nvl(p_old_org_id,0)                 ) ) ) THEN
 			IF ( IsInsert = 0)	THEN
 				-- dbms_output.put_line('AS_LEADS_LOG: changed state i am in sam day'|| IsInsert);
				AS_LEADS_LOG_PKG.Update_Row(
				       		  p_LOG_ID    		=> l_LOG_ID,
					          p_LEAD_ID    		=> p_new_lead_id,
						  p_OLD_LEAD_ID 	=> p_old_lead_id,
					          p_CREATED_BY    	=> p_new_created_by,
					          p_CREATION_DATE 	=> p_new_creation_date,
					          p_LAST_UPDATED_BY    	=> p_new_last_updated_by,
					          p_LAST_UPDATE_DATE   	=> p_new_last_update_date,
						  p_OLD_LAST_UPDATE_DATE => p_old_last_update_date,
					          p_LAST_UPDATE_LOGIN    => p_new_last_update_login,
					          p_STATUS_CODE    	=> p_new_status,
					          p_SALES_STAGE_ID    	=> p_new_sales_stage_id,
					          p_WIN_PROBABILITY   	=> p_new_win_probability,
					          p_DECISION_DATE    	=> p_new_decision_date,
					          p_ADDRESS_ID    	=> p_new_address_id,
					          p_CHANNEL_CODE  	=> p_new_channel_code,
					          p_CURRENCY_CODE 	=> p_new_currency_code,
					          p_TOTAL_AMOUNT  	=> p_new_total_amount ,
						  p_SECURITY_GROUP_ID      =>  p_new_security_group_id,
						  p_CUSTOMER_ID            =>	p_new_customer_id,
					 	  p_DESCRIPTION            =>  p_new_description,
						  p_SOURCE_PROMOTION_ID    =>  p_new_source_promotion_id,
						  p_OFFER_ID               =>  p_new_offer_id ,
					   	  p_CLOSE_COMPETITOR_ID    =>  p_new_close_competitor_id,
						  p_VEHICLE_RESPONSE_CODE  =>  p_new_vehicle_response_code,
					 	  p_SALES_METHODOLOGY_ID   =>  p_new_sales_methodology_id,
						  p_OWNER_SALESFORCE_ID    =>  p_new_owner_salesforce_id,
						  p_OWNER_SALES_GROUP_ID   =>  p_new_owner_sales_group_id,
				  		  p_LOG_START_DATE	   =>  p_new_last_update_date,
						  p_LOG_END_DATE	   	   =>  p_new_last_update_date,
						  p_LOG_ACTIVE_DAYS	   =>  0,
						  p_CURRENT_LOG		   =>  1,
						  p_ENDDAY_LOG_FLAG	   => 'Y',
						  p_ORG_ID		   =>  p_new_org_id,
						  p_TRIGGER_MODE	   =>  'U');
						IF l_debug THEN
						 		AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
						                     'asxopadb: Update Log: '||p_old_lead_id || 'and '|| p_old_last_update_date  );
	                			END IF;
 			ELSE
 				-- dbms_output.put_line('AS_LEADS_LOG: not changed state i am in diff day'|| IsInsert);
 				AS_LEADS_LOG_PKG.Insert_Row(
						px_LOG_ID   		=> l_LOG_ID,
						p_LEAD_ID    		=> p_new_lead_id,
						p_CREATED_BY    	=> p_new_created_by,
						p_CREATION_DATE    	=> p_new_creation_date,
						p_LAST_UPDATED_BY    	=> p_new_last_updated_by,
						p_LAST_UPDATE_DATE   	=> p_new_last_update_date,
						p_LAST_UPDATE_LOGIN  	=> p_new_last_update_login,
						p_STATUS_CODE    	=> p_new_status,
						p_SALES_STAGE_ID    	=> p_new_sales_stage_id,
						p_WIN_PROBABILITY    	=> p_new_win_probability,
						p_DECISION_DATE    	=> p_new_decision_date,
						p_ADDRESS_ID    	=> p_new_address_id,
						p_CHANNEL_CODE    	=> p_new_channel_code,
						p_CURRENCY_CODE    	=> p_new_currency_code,
						p_TOTAL_AMOUNT    	=> p_new_total_amount ,
						p_SECURITY_GROUP_ID      =>  p_new_security_group_id,
						p_CUSTOMER_ID            =>	p_new_customer_id,
						p_DESCRIPTION            =>  p_new_description,
						p_SOURCE_PROMOTION_ID    =>  p_new_source_promotion_id,
						p_OFFER_ID               =>  p_new_offer_id ,
						p_CLOSE_COMPETITOR_ID    =>  p_new_close_competitor_id,
						p_VEHICLE_RESPONSE_CODE  =>  p_new_vehicle_response_code,
						p_SALES_METHODOLOGY_ID   =>  p_new_sales_methodology_id,
						p_OWNER_SALESFORCE_ID    =>  p_new_owner_salesforce_id,
						p_OWNER_SALES_GROUP_ID   =>  p_new_owner_sales_group_id,
					  	p_LOG_START_DATE	   =>  p_new_last_update_date,
					  	p_LOG_END_DATE	   =>  p_new_last_update_date,
					  	p_LOG_ACTIVE_DAYS	   =>  0,
					  	p_CURRENT_LOG		   =>  1,
					  	p_ENDDAY_LOG_FLAG	   => 'Y',
						p_ORG_ID                 =>  p_new_org_id,
						p_TRIGGER_MODE	   =>  'U');
						IF l_debug THEN
							AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
								'asxopadb: Insert Log: '||l_LOG_ID );
						END IF;
 			END IF;
 		/*ELSE
 			-- dbms_output.put_line('AS_LEADS_LOG: manually updating the data');
 			UPDATE as_leads_log
 			SET object_version_number =  nvl(object_version_number,0) + 1, LAST_UPDATE_DATE = p_new_last_update_date
 			WHERE log_id = ( select max(log_id)
                 			from as_leads_log
                 			where lead_id = p_new_lead_id);*/
	 	END IF;
	END IF;
    END IF;

    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR then
	  -- dbms_output.put_line('Error Number1:'||SQLCODE);
	  -- dbms_output.put_line('Error Message1:'|| SUBSTR(SQLERRM, 1, 200));

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
			'Error in Leads Trg:' || sqlerrm);
          END IF;

          FND_MSG_PUB.Add_Exc_Msg('AS_LEADS_AUDIT_PKG', 'Leads_Trigger_Handler');
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
	 -- dbms_output.put_line('Error Number2:'||SQLCODE);
	 -- dbms_output.put_line('Error Message2:'|| SUBSTR(SQLERRM, 1, 200));
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
     			'Error in Leads Trg:' || sqlerrm);
          END IF;

          FND_MSG_PUB.Add_Exc_Msg('AS_LEADS_AUDIT_PKG', 'Leads_Trigger_Handler');
END  Leads_Trigger_Handler;
Procedure Lead_Lines_Trigger_Handler(
	p_trigger_mode 			 IN VARCHAR2,
	p_new_lead_id 			 IN as_lead_lines_all.lead_id%type,
	p_old_lead_id 			 IN as_lead_lines_all.lead_id%type,

	p_new_lead_line_id		 IN as_lead_lines_all.lead_line_id%type,
	p_old_lead_line_id		 IN as_lead_lines_all.lead_line_id%type,

	p_new_last_update_date		 IN as_lead_lines_all.last_update_date%type,
	p_old_last_update_date		 IN as_lead_lines_all.last_update_date%type,

	p_new_last_updated_by		 IN as_lead_lines_all.last_updated_by%type,
	p_old_last_updated_by		 IN as_lead_lines_all.last_updated_by%type,

	p_new_last_update_login		 IN as_lead_lines_all.last_update_login%type,
	p_old_last_update_login		 IN as_lead_lines_all.last_update_login%type,

	p_new_creation_date		 IN as_lead_lines_all.creation_date%type,
	p_old_creation_date		 IN as_lead_lines_all.creation_date%type,

	p_new_created_by		 IN as_lead_lines_all.created_by%type,
	p_old_created_by		 IN as_lead_lines_all.created_by%type,

	p_new_interest_type_id		 IN as_lead_lines_all.interest_type_id%type,
	p_old_interest_type_id		 IN as_lead_lines_all.interest_type_id%type,
	p_new_primary_interest_code_id	 IN as_lead_lines_all.primary_interest_code_id%type,
	p_old_primary_interest_code_id	 IN as_lead_lines_all.primary_interest_code_id%type,
	p_new_second_interest_code_id IN as_lead_lines_all.secondary_interest_code_id%type,
	p_old_second_interest_code_id IN as_lead_lines_all.secondary_interest_code_id%type,
	p_new_product_category_id		 IN as_lead_lines_all.product_category_id%type,
	p_old_product_category_id		 IN as_lead_lines_all.product_category_id%type,
	p_new_product_cat_set_id		 IN as_lead_lines_all.product_cat_set_id%type,
	p_old_product_cat_set_id		 IN as_lead_lines_all.product_cat_set_id%type,
	p_new_inventory_item_id 	 IN as_lead_lines_all.inventory_item_id%type,
	p_old_inventory_item_id 	 IN as_lead_lines_all.inventory_item_id%type,
	p_new_organization_id	 	 IN as_lead_lines_all.organization_id%type,
	p_old_organization_id	 	 IN as_lead_lines_all.organization_id%type,
	p_new_source_promotion_id 	 IN as_lead_lines_all.source_promotion_id%type,
	p_old_source_promotion_id 	 IN as_lead_lines_all.source_promotion_id%type,
	p_new_offer_id		 	 IN as_lead_lines_all.offer_id%type,
	p_old_offer_id		 	 IN as_lead_lines_all.offer_id%type,
	p_new_org_id		 	 IN as_lead_lines_all.org_id%type,
	p_old_org_id		 	 IN as_lead_lines_all.org_id%type,
	p_new_forecast_date		 IN as_lead_lines_all.forecast_date%type,
	p_old_forecast_date		 IN as_lead_lines_all.forecast_date%type,
	p_new_rolling_forecast_flag	 IN as_lead_lines_all.rolling_forecast_flag%type,
	p_old_rolling_forecast_flag	 IN as_lead_lines_all.rolling_forecast_flag%type,
	p_new_total_amount		 IN as_lead_lines_all.total_amount%type	,
	p_old_total_amount		 IN as_lead_lines_all.total_amount%type	,
	p_new_quantity 			 IN as_lead_lines_all.quantity%type	,
	p_old_quantity 			 IN as_lead_lines_all.quantity%type	,
	p_new_uom			 IN as_lead_lines_all.UOM_CODE%type,
	p_old_uom			 IN as_lead_lines_all.UOM_CODE%type)
IS
today_date Date;
lookUpTypeFlag BOOLEAN;
IsInsert NUMBER := 0;
l_debug CONSTANT BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_line_count NUMBER := 0;
l_new_last_update_date DATE := p_new_last_update_date;
l_dummy_date     CONSTANT DATE := to_date('31-12-9999', 'DD-MM-YYYY');
BEGIN
	-- dbms_output.put_line('After calling Lead_Lines_Trigger_Handler');
    IF p_trigger_mode = 'ON-DELETE' THEN
        l_new_last_update_date := sysdate;
    END IF;

    update as_lead_lines_log
    set object_version_number =  nvl(object_version_number,0) + 1,
        endday_log_flag = decode (trunc(l_new_last_update_date), trunc (p_old_last_update_date), 'N', 'Y')
    where lead_line_id = p_old_lead_line_id
          and last_update_date = p_old_last_update_date;

	IF ( p_trigger_mode = 'ON-INSERT' ) THEN
		 -- dbms_output.put_line('Lead_Lines_Trigger_Handler Trigger mode' || p_trigger_mode);
		AS_LEADS_LINES_LOG_PKG.Insert_Row(p_new_lead_id    		,
  						p_new_lead_line_id 		,
						p_new_last_update_date      ,
						p_new_last_updated_by       ,
						p_new_last_update_login     ,
						p_new_creation_date         ,
  						p_new_created_by            ,
  						p_new_interest_type_id      ,
  						p_new_primary_interest_code_id    ,
  						p_new_second_interest_code_id  ,
  						p_new_product_category_id      ,
  						p_new_product_cat_set_id      ,
	  					p_new_inventory_item_id           ,
  						p_new_organization_id                ,
  						p_new_source_promotion_id         ,
  						p_new_offer_id                    ,
  						p_new_org_id                      ,
  						p_new_forecast_date               ,
  						p_new_rolling_forecast_flag,
  						'Y',
  						'I');

		IF l_debug THEN
		AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'asxopadb: Insert Log: Lead_line_id '||p_new_lead_line_id || ' and Last Update Date '|| p_new_last_update_date);
		END IF;

	ELSIF ( p_trigger_mode = 'ON-UPDATE' ) THEN
		GET_VALUE(p_old_last_update_date,p_new_last_update_date,IsInsert);
		-- dbms_output.put_line('Lead_Lines_Trigger_Handler IF Isinsert value' || IsInsert);

		SELECT COUNT(*) INTO l_line_count FROM AS_LEAD_LINES_LOG
		WHERE LEAD_ID = p_old_lead_id
		AND LEAD_LINE_ID = p_old_lead_line_id;

		IF (l_line_count = 0) THEN
			-- dbms_output.put_line('Lead_Lines_Trigger_Handler I am in not exist state' || l_line_count);
			AS_LEADS_LINES_LOG_PKG.Insert_Row(p_new_lead_id,
					p_new_lead_line_id 	,
					p_new_last_update_date      ,
					p_new_last_updated_by       ,
					p_new_last_update_login     ,
					p_new_creation_date         ,
			  		p_new_created_by            ,
			  		p_new_interest_type_id      ,
			  		p_new_primary_interest_code_id    ,
			  		p_new_second_interest_code_id  ,
			  		p_new_product_category_id      ,
			  		p_new_product_cat_set_id      ,
				  	p_new_inventory_item_id           ,
			  		p_new_organization_id                ,
			  		p_new_source_promotion_id         ,
			  		p_new_offer_id                    ,
			  		p_new_org_id                      ,
			  		p_new_forecast_date               ,
			  		p_new_rolling_forecast_flag       ,
			  		'Y',
			  		'U');
			  	IF l_debug THEN
								AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
							                      'asxopadb: Update Log: Lead_line_id '||p_old_lead_line_id || ' and Last Update Date '|| p_old_last_update_date);
                        	END IF;
                ELSE


                	IF( ( ( p_new_last_updated_by		<> p_old_last_updated_by 		) OR
			      ( p_new_interest_type_id		<> p_old_interest_type_id		) OR
			      ( p_new_primary_interest_code_id	<> p_old_primary_interest_code_id	) OR
			      ( p_new_second_interest_code_id    <> p_old_second_interest_code_id 	) OR
			      ( p_new_product_category_id    <> p_old_product_category_id 	) OR
			      ( p_new_product_cat_set_id    <> p_old_product_cat_set_id 	) OR
			      ( p_new_inventory_item_id 	        <> p_old_inventory_item_id 	) OR
			      ( p_new_organization_id	 	<> p_old_organization_id	 	) OR
			      ( p_new_source_promotion_id 	<> p_old_source_promotion_id 		) OR
			      ( p_new_offer_id		 	<> p_old_offer_id		 	) OR
			      ( p_new_org_id		 	<> p_old_org_id		 		) OR
			      ( nvl(p_new_forecast_date, l_dummy_date)		<> nvl(p_old_forecast_date, l_dummy_date)			) OR
  		              ( p_new_rolling_forecast_flag	<> p_old_rolling_forecast_flag		) OR
  		              ( nvl(p_new_total_amount, -10)		<> nvl(p_old_total_amount, -10)			) OR
			      ( p_new_quantity 			<> p_old_quantity 			) OR
			      ( p_new_uom			<> p_old_uom				) ) ) THEN
  		              IF (IsInsert = 0) THEN
  		              		-- dbms_output.put_line('Lead_Lines_Trigger_Handler I am in changes same day state' || IsInsert);
  		              		-- dbms_output.put_line('Lead_Lines_Trigger_Handler I am in changes same day state old date' || to_char(p_old_last_update_date,'dd:mm:yyyy HH:MI:SS'));
  		              		-- dbms_output.put_line('Lead_Lines_Trigger_Handler I am in changes same day state new state' || to_char(p_new_last_update_date,'dd:mm:yyyy HH:MI:SS'));
					AS_LEADS_LINES_LOG_PKG.Update_Row(p_new_lead_id            ,
						p_old_lead_line_id               ,
						p_old_last_update_date           ,
						p_new_last_update_date	       ,
						p_new_last_updated_by              ,
						p_new_last_update_login            ,
						p_new_creation_date                ,
						p_new_created_by                   ,
						p_new_interest_type_id             ,
						p_new_primary_interest_code_id     ,
						p_new_second_interest_code_id   ,
						p_new_product_category_id             ,
						p_new_product_cat_set_id             ,
						p_new_inventory_item_id            ,
						p_new_organization_id              ,
						p_new_source_promotion_id          ,
						p_new_offer_id                     ,
						p_new_org_id                       ,
						p_new_forecast_date                ,
					    	p_new_rolling_forecast_flag        ,
					    	'Y',
					    	'U');
						IF l_debug THEN
							AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
							'asxopadb: Update Log: Lead_line_id '||p_old_lead_line_id || ' and Last Update Date '|| p_old_last_update_date);
						END IF;
			      ELSE
			      		-- dbms_output.put_line('Lead_Lines_Trigger_Handler I am in changes diff day state' || IsInsert);
			      		AS_LEADS_LINES_LOG_PKG.Insert_Row(p_new_lead_id,
						p_new_lead_line_id 	,
						p_new_last_update_date      ,
						p_new_last_updated_by       ,
						p_new_last_update_login     ,
						p_new_creation_date         ,
			  			p_new_created_by            ,
			  			p_new_interest_type_id      ,
			  			p_new_primary_interest_code_id    ,
			  			p_new_second_interest_code_id  ,
						p_new_product_category_id             ,
						p_new_product_cat_set_id             ,
				  		p_new_inventory_item_id           ,
			  			p_new_organization_id                ,
			  			p_new_source_promotion_id         ,
			  			p_new_offer_id                    ,
			  			p_new_org_id                      ,
			  			p_new_forecast_date               ,
			  			p_new_rolling_forecast_flag       ,
			  			'Y',
			  			'U');
			  			IF l_debug THEN
								AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
							                      'asxopadb: Update Log: Lead_line_id '||p_old_lead_line_id || ' and Last Update Date '|| p_old_last_update_date);
                        			END IF;
  		              END IF;
  		              -- dbms_output.put_line('Lead_Lines_Trigger_Handler After completing the chages if block' || IsInsert);

  		         END IF;
  		         -- dbms_output.put_line('Lead_Lines_Trigger_Handler After checking if block' || IsInsert);

		END IF;
	ELSIF( p_trigger_mode = 'ON-DELETE' ) THEN

			-- dbms_output.put_line('Lead_Lines_Trigger_Handler delte  value');
			AS_LEADS_LINES_LOG_PKG.Delete_Row(p_old_lead_id,
  						p_old_lead_line_id 	,
						p_old_last_update_date      ,
						p_old_last_updated_by       ,
						p_old_last_update_login     ,
						p_old_creation_date         ,
  						p_old_created_by,
  						'Y');



			IF l_debug THEN
			AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	                      'asxopadb: Delete Log: Lead_line_id '||p_old_lead_line_id || ' and Last Update Date '|| p_old_last_update_date);
	                END IF;
	END IF;
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR then
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
			'Error in Lead Lines Trg:' || sqlerrm);
	  END IF;
          FND_MSG_PUB.Add_Exc_Msg('AS_LEADS_AUDIT_PKG', 'Lead_Lines_Trigger_Handler');
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
     			'Error in Lead Lines Trg:' || sqlerrm);
	  END IF;
          FND_MSG_PUB.Add_Exc_Msg('AS_LEADS_AUDIT_PKG', 'Lead_Lines_Trigger_Handler');
END Lead_Lines_Trigger_Handler;
PROCEDURE Sales_Credits_Trigger_Handler(p_trigger_Mode 	IN VARCHAR2,
	p_new_lead_id 			 IN as_sales_credits.lead_id%type,
	p_old_lead_id 			 IN as_sales_credits.lead_id%type,

	p_new_lead_line_id		 IN as_sales_credits.lead_line_id%type,
	p_old_lead_line_id		 IN as_sales_credits.lead_line_id%type,

	p_new_sales_credit_id		 IN as_sales_credits.sales_credit_id%type,
	p_old_sales_credit_id		 IN as_sales_credits.sales_credit_id%type,

	p_new_last_update_date		 IN as_sales_credits.last_update_date%type,
	p_old_last_update_date		 IN as_sales_credits.last_update_date%type,

	p_new_last_updated_by		 IN as_sales_credits.last_updated_by%type,
	p_old_last_updated_by		 IN as_sales_credits.last_updated_by%type,

	p_new_last_update_login		 IN as_sales_credits.last_update_login%type,
	p_old_last_update_login		 IN as_sales_credits.last_update_login%type,

	p_new_creation_date		 IN as_sales_credits.creation_date%type,
	p_old_creation_date		 IN as_sales_credits.creation_date%type,

	p_new_created_by		 IN as_sales_credits.created_by%type,
	p_old_created_by		 IN as_sales_credits.created_by%type,

	p_new_salesforce_id		 IN as_sales_credits.salesforce_id%type,
	p_old_salesforce_id		 IN as_sales_credits.salesforce_id%type,
	p_new_salesgroup_id		 IN as_sales_credits.salesgroup_id%type,
	p_old_salesgroup_id		 IN as_sales_credits.salesgroup_id%type,
	p_new_credit_type_id		 IN as_sales_credits.credit_type_id%type,
	p_old_credit_type_id		 IN as_sales_credits.credit_type_id%type,
	p_new_credit_percent	 	 IN as_sales_credits.credit_percent%type,
	p_old_credit_percent	 	 IN as_sales_credits.credit_percent%type,
	p_new_credit_amount	 	 IN as_sales_credits.credit_amount%type ,
	p_old_credit_amount	 	 IN as_sales_credits.credit_amount%type ,
	p_new_opp_worst_frcst_amount IN as_sales_credits.opp_worst_forecast_amount%type,
	p_old_opp_worst_frcst_amount IN as_sales_credits.opp_worst_forecast_amount%type,
	p_new_opp_frcst_amount IN as_sales_credits.opp_forecast_amount%type,
	p_old_opp_frcst_amount IN as_sales_credits.opp_forecast_amount%type,
	p_new_opp_best_frcst_amount IN as_sales_credits.opp_best_forecast_amount%type,
	p_old_opp_best_frcst_amount IN as_sales_credits.opp_best_forecast_amount%type)
IS
today_date Date;
IsInsert        NUMBER :=0;
l_debug CONSTANT BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_credit_count	NUMBER :=0;
l_new_last_update_date DATE := p_new_last_update_date;
BEGIN

        IF p_trigger_mode = 'ON-DELETE' THEN
            l_new_last_update_date := sysdate;
        END IF;

	   -- dbms_output.put_line('After calling Sales_Credits_Trigger_Handler');
       update as_sales_credits_log
       set object_version_number =  nvl(object_version_number,0) + 1,
           endday_log_flag = decode (trunc(l_new_last_update_date), trunc (p_old_last_update_date), 'N', 'Y')
       where sales_credit_id = p_old_sales_credit_id
             and last_update_date = p_old_last_update_date;

	   IF ( p_trigger_mode = 'ON-INSERT' ) THEN
		-- dbms_output.put_line('Sales_Credits_Trigger_Handler Trigger mode' || p_trigger_mode);
		AS_SALES_CREDITS_LOG_PKG.Insert_Row(p_new_lead_id    	,
  						p_new_lead_line_id 	,
						p_new_sales_credit_id	,
						p_new_last_update_date  ,
						p_new_last_updated_by   ,
						p_new_last_update_login ,
						p_new_creation_date     ,
  						p_new_created_by        ,
						p_new_salesforce_id	,
						p_new_salesgroup_id	,
						p_new_credit_type_id	,
						p_new_credit_percent	,
						p_new_credit_amount,
						p_new_opp_worst_frcst_amount,
						p_new_opp_frcst_amount,
						p_new_opp_best_frcst_amount,
						'Y',
						'I');
		IF l_debug THEN
		AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'asxopadb: Sales credit Insert Log: Lead_line_id '||p_new_lead_line_id || ' and Last Update Date '|| p_new_last_update_date);
		END IF;

	ELSIF ( p_trigger_mode = 'ON-UPDATE' ) THEN
		GET_VALUE(p_old_last_update_date, p_new_last_update_date,IsInsert);
		-- dbms_output.put_line('Sales_Credits_Trigger_Handler IF Isinsert value' || IsInsert);

		SELECT COUNT(*) INTO l_credit_count
		FROM as_sales_credits_log
		WHERE SALES_CREDIT_ID = p_old_sales_credit_id;

		IF (l_credit_count = 0) THEN
			AS_SALES_CREDITS_LOG_PKG.Insert_Row(p_new_lead_id    	,
					p_new_lead_line_id 	,
					p_new_sales_credit_id	,
					p_new_last_update_date  ,
					p_new_last_updated_by   ,
					p_new_last_update_login ,
					p_new_creation_date     ,
					p_new_created_by        ,
					p_new_salesforce_id	,
					p_new_salesgroup_id	,
					p_new_credit_type_id	,
					p_new_credit_percent	,
					p_new_credit_amount,
					p_new_opp_worst_frcst_amount,
					p_new_opp_frcst_amount,
					p_new_opp_best_frcst_amount,
					'Y',
					'U');
					IF l_debug THEN
						AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
						'asxopadb: Sales credit Insert Log: Lead_line_id '||p_new_lead_line_id || ' and Last Update Date '|| p_new_last_update_date);
					END IF;
		ELSE
			IF( ( ( p_new_last_updated_by		<>   p_old_last_updated_by ) OR
		    	      ( p_new_salesforce_id		<>   p_old_salesforce_id   ) OR
		    	      ( nvl(p_new_salesgroup_id, -10)		<>   nvl(p_old_salesgroup_id, -10)   ) OR
		    	      ( p_new_credit_type_id		<>   p_old_credit_type_id  ) OR
		    	      ( p_new_credit_percent	 	<>   p_old_credit_percent  ) OR
		    	      ( nvl(p_new_credit_amount, -10)	 	<>   nvl(p_old_credit_amount, -10)   ) OR
		    	      ( nvl(p_new_opp_worst_frcst_amount, -10)	 	<>   nvl(p_old_opp_worst_frcst_amount, -10)  ) OR
		    	      ( nvl(p_new_opp_frcst_amount, -10)	 	<>   nvl(p_old_opp_frcst_amount, -10)  ) OR
		    	      ( nvl(p_new_opp_best_frcst_amount, -10)	 	<>   nvl(p_old_opp_best_frcst_amount, -10)  ) )) THEN
		    	      IF( IsInsert = 0) THEN
		    	      		-- dbms_output.put_line('Sales_Credits_Trigger_Handler ELSE Isinsert value' || IsInsert);
					AS_SALES_CREDITS_LOG_PKG.Update_Row(p_new_lead_id     ,
							p_new_lead_line_id           ,
							p_old_sales_credit_id	     ,
							p_old_last_update_date       ,
							p_new_last_update_date	     ,
							p_new_last_updated_by        ,
							p_new_last_update_login      ,
							p_new_creation_date          ,
							p_new_created_by             ,
							p_new_salesforce_id	,
							p_new_salesgroup_id	,
							p_new_credit_type_id	,
							p_new_credit_percent	,
							p_new_credit_amount,
					        p_new_opp_worst_frcst_amount,
					        p_new_opp_frcst_amount,
					        p_new_opp_best_frcst_amount,
					        'Y',
							'U');
					IF l_debug THEN
							AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			                	      'asxopadb: Sales credit Update Log: Lead_line_id '||p_old_sales_credit_id || ' and Last Update Date '|| p_old_last_update_date);
					END IF;
		    	      ELSE
		    	      		AS_SALES_CREDITS_LOG_PKG.Insert_Row(p_new_lead_id    	,
							p_new_lead_line_id 	,
							p_new_sales_credit_id	,
							p_new_last_update_date  ,
							p_new_last_updated_by   ,
							p_new_last_update_login ,
							p_new_creation_date     ,
							p_new_created_by        ,
							p_new_salesforce_id	,
							p_new_salesgroup_id	,
							p_new_credit_type_id	,
							p_new_credit_percent	,
							p_new_credit_amount,
					        p_new_opp_worst_frcst_amount,
					        p_new_opp_frcst_amount,
					        p_new_opp_best_frcst_amount,
					        'Y',
							'U');
					IF l_debug THEN
						AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
					         'asxopadb: Sales credit Insert Log: Lead_line_id '||p_new_lead_line_id || ' and Last Update Date '|| p_new_last_update_date);
					END IF;
		    	      END IF;
			END IF;
		END IF;

	ELSIF( p_trigger_mode = 'ON-DELETE' ) THEN

			-- dbms_output.put_line('Sales_Credits_Trigger_Handler delete  value');
			AS_SALES_CREDITS_LOG_PKG.Delete_Row(p_old_lead_id    	,
  						p_old_lead_line_id 	,
						p_old_sales_credit_id	,
						p_old_last_update_date  ,
						p_old_last_updated_by   ,
						p_old_last_update_login ,
						p_old_creation_date     ,
  						p_old_created_by,
  						'Y');

		IF l_debug THEN
		AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'asxopadb: Sales credit Update Log: Lead_line_id '||p_old_sales_credit_id || ' and Last Update Date '|| p_old_last_update_date);
		END IF;

	END IF;
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR then
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
			'Error in Sales credits Trg:' || sqlerrm);
	  END IF;
          FND_MSG_PUB.Add_Exc_Msg('AS_LEADS_AUDIT_PKG', 'Sales_Credits_Trigger_Handler');
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
     			'Error in Sales Credits Trg:' || sqlerrm);
          END IF;

          FND_MSG_PUB.Add_Exc_Msg('AS_LEADS_AUDIT_PKG', 'Lead_Lines_Trigger_Handler');
END Sales_Credits_Trigger_Handler;


PROCEDURE GET_VALUE(p_old_last_update_date IN DATE,
		    p_new_last_update_date IN DATE,
		    IsInsert OUT NOCOPY NUMBER)
IS
TODAY_YEAR 		VARCHAR2(4);
LAST_UPDATE_YEAR	VARCHAR2(4);
TODAY_DAY		VARCHAR2(4);
LAST_UPDATE_DAY		VARCHAR2(4);
TODAY_CHECK		VARCHAR2(4);
LAST_UPDATE_CHECK	VARCHAR2(4);
today_date		DATE;
TODAY_HOUR		VARCHAR2(4);
LAST_UPDATE_HOUR	VARCHAR2(4);
TIMEFRAME		VARCHAR2(10);
AS_TIMEFRAME		VARCHAR2(10);
BEGIN

IsInsert := 1;
TIMEFRAME := nvl(FND_PROFILE.VALUE('AS_OPP_LOG_TIMEFRAME'),'NONE');
-- dbms_output.put_line('TIMEFRAME = ' || TIMEFRAME );
-- dbms_output.put_line('Old date is='|| to_char(p_old_last_update_date,'dd/mon/yyyy HH:MI:SS'));
-- dbms_output.put_line('Old date is='|| to_char(p_new_last_update_date,'dd/mon/yyyy HH:MI:SS'));


IF ( TIMEFRAME = 'YEAR'    AND trunc(p_old_last_update_date, 'YY') = trunc(p_new_last_update_date, 'YY')) OR
   ( TIMEFRAME = 'QUARTER' AND trunc(p_old_last_update_date, 'Q' ) = trunc(p_new_last_update_date, 'Q' )) OR
   ( TIMEFRAME = 'MONTH'   AND trunc(p_old_last_update_date, 'MM') = trunc(p_new_last_update_date, 'MM')) OR
   ( TIMEFRAME = 'WEEK'    AND trunc(p_old_last_update_date, 'WW') = trunc(p_new_last_update_date, 'WW')) OR
   ( TIMEFRAME = 'DAY'     AND trunc(p_old_last_update_date, 'DD') = trunc(p_new_last_update_date, 'DD')) OR
   ( TIMEFRAME = 'HOUR'    AND trunc(p_old_last_update_date, 'HH') = trunc(p_new_last_update_date, 'HH')) OR
   ( TIMEFRAME = 'MIN'     AND trunc(p_old_last_update_date, 'MI') = trunc(p_new_last_update_date, 'MI')) THEN
	IsInsert := 0;
	-- dbms_output.put_line('Inside insert');
END IF;


-- dbms_output.put_line('TIMEFRAME = ' || TIMEFRAME );
-- dbms_output.put_line('IsInsert = ' || IsInsert);


/*

		SELECT TO_CHAR(sysdate ,'YYYY') INTO TODAY_YEAR FROM DUAL;
		SELECT nvl( TO_CHAR(p_old_last_update_date ,'YYYY'),1) INTO LAST_UPDATE_YEAR FROM DUAL;
		dbms_output.put_line('Todays Year is :'||TODAY_YEAR);
		dbms_output.put_line('Last date Year is :'||LAST_UPDATE_YEAR);

		SELECT TO_CHAR(sysdate ,'DDD') INTO TODAY_DAY FROM DUAL;
		SELECT TO_CHAR(p_old_last_update_date ,'DDD') INTO LAST_UPDATE_DAY FROM DUAL;

		IF ( TIMEFRAME = 'NONE' ) THEN
			dbms_output.put_line('I am in ALL');
			IsInsert := 1;
                ELSIF ( TIMEFRAME = 'YEAR' ) THEN
			IF ( TODAY_YEAR <> LAST_UPDATE_YEAR ) THEN
			dbms_output.put_line('I am in YEAR');
			  	IsInsert := 1;
			END IF;

                ELSIF ( TIMEFRAME = 'QUARTER' ) THEN
			SELECT TO_CHAR(sysdate ,'Q') INTO TODAY_CHECK FROM DUAL;
			SELECT TO_CHAR(p_old_last_update_date ,'Q') INTO LAST_UPDATE_CHECK FROM DUAL;

			IF ( ( TODAY_CHECK <> LAST_UPDATE_CHECK ) OR ( TODAY_YEAR <> LAST_UPDATE_YEAR )) THEN
			  	IsInsert := 1;
			END IF;
                ELSIF ( TIMEFRAME = 'MONTH' ) THEN
			SELECT TO_CHAR(sysdate ,'MM') INTO TODAY_CHECK FROM DUAL;
			SELECT TO_CHAR(p_old_last_update_date ,'MM') INTO LAST_UPDATE_CHECK FROM DUAL;

			IF ( ( TODAY_CHECK <> LAST_UPDATE_CHECK ) OR ( TODAY_YEAR <> LAST_UPDATE_YEAR ) ) THEN
			  	IsInsert := 1;
			END IF;
                ELSIF ( TIMEFRAME = 'WEEK' ) THEN
			SELECT TO_CHAR(sysdate ,'WW') INTO TODAY_CHECK FROM DUAL;
			SELECT TO_CHAR(p_old_last_update_date ,'WW') INTO LAST_UPDATE_CHECK FROM DUAL;
			IF ( ( TODAY_CHECK <> LAST_UPDATE_CHECK ) OR ( TODAY_YEAR <> LAST_UPDATE_YEAR ) ) THEN
			  	IsInsert := 1;
			END IF;
                ELSIF ( TIMEFRAME = 'DAY' ) THEN
			select sysdate into today_date from dual;
			IF (  ( TODAY_DAY <> LAST_UPDATE_DAY) OR ( TODAY_YEAR <> LAST_UPDATE_YEAR )) THEN
			  	IsInsert := 1;
			END IF;
                ELSIF ( TIMEFRAME = 'HOUR' ) THEN
			SELECT TO_CHAR(sysdate ,'HH24') INTO TODAY_CHECK FROM DUAL;
			SELECT TO_CHAR(p_old_last_update_date ,'HH24') INTO LAST_UPDATE_CHECK FROM DUAL;

			IF ( ( TODAY_CHECK <> LAST_UPDATE_CHECK ) OR ( TODAY_DAY <> LAST_UPDATE_DAY ) ) THEN
			  	IsInsert := 1;
			END IF;
                ELSIF ( TIMEFRAME = 'MIN' ) THEN
			SELECT TO_CHAR(sysdate ,'MI') INTO TODAY_CHECK FROM DUAL;
			SELECT TO_CHAR(p_old_last_update_date ,'MI') INTO LAST_UPDATE_CHECK FROM DUAL;

			SELECT TO_CHAR(sysdate ,'HH24') INTO TODAY_HOUR FROM DUAL;
			SELECT TO_CHAR(p_old_last_update_date ,'HH24') INTO LAST_UPDATE_HOUR FROM DUAL;

			IF ( ( TODAY_CHECK <> LAST_UPDATE_CHECK ) OR ( TODAY_HOUR <> LAST_UPDATE_HOUR ) ) THEN
			  	IsInsert := 1;
			END IF;

		END IF;
*/


END GET_VALUE;


END AS_LEADS_AUDIT_PKG;

/
