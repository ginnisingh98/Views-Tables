--------------------------------------------------------
--  DDL for Package AS_LEADS_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_LEADS_AUDIT_PKG" AUTHID CURRENT_USER AS
/* $Header: asxopads.pls 120.2 2006/03/25 04:20:28 savadhan noship $ */

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
	p_trigger_mode 			IN VARCHAR2);
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
	p_old_uom			 IN as_lead_lines_all.UOM_CODE%type);


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
	p_new_credit_amount	 	 IN as_sales_credits.credit_amount%type,
	p_old_credit_amount	 	 IN as_sales_credits.credit_amount%type,
	p_new_opp_worst_frcst_amount IN as_sales_credits.opp_worst_forecast_amount%type,
	p_old_opp_worst_frcst_amount IN as_sales_credits.opp_worst_forecast_amount%type,
	p_new_opp_frcst_amount IN as_sales_credits.opp_forecast_amount%type,
	p_old_opp_frcst_amount IN as_sales_credits.opp_forecast_amount%type,
	p_new_opp_best_frcst_amount IN as_sales_credits.opp_best_forecast_amount%type,
	p_old_opp_best_frcst_amount IN as_sales_credits.opp_best_forecast_amount%type);

PROCEDURE GET_VALUE(p_old_last_update_date IN DATE,
		    p_new_last_update_date IN DATE,
		    IsInsert OUT NOCOPY NUMBER);

End AS_LEADS_AUDIT_PKG ;

 

/
