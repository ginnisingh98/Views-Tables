--------------------------------------------------------
--  DDL for Package AS_SC_DENORM_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SC_DENORM_TRG" AUTHID CURRENT_USER AS
/* $Header: asxopdts.pls 115.28 2004/01/16 11:23:14 sumahali ship $ */

Procedure Leads_Trigger_Handler(
				p_new_last_update_date IN as_leads_all.last_update_date%type ,
				p_new_last_updated_by IN as_leads_all.last_updated_by%type,
				p_new_creation_date IN as_leads_all.creation_date%type,
				p_new_created_by IN as_leads_all.created_by%type,
				p_new_last_update_login  IN as_leads_all.last_update_login%type,
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
				p_trigger_mode IN VARCHAR2);

Procedure Lead_Lines_Trigger_Handler(
				p_new_last_update_date IN as_lead_lines_all.last_update_date%type ,
				p_new_last_updated_by IN as_lead_lines_all.last_updated_by%type,
				p_new_creation_date IN as_lead_lines_all.creation_date%type,
				p_new_created_by IN as_lead_lines_all.created_by%type,
				p_new_last_update_login IN as_lead_lines_all.last_update_login%type,
				p_new_lead_id IN as_lead_lines_all.lead_id%type,
				p_new_lead_line_id IN as_lead_lines_all.lead_line_id%type,
				p_new_interest_type_id IN as_lead_lines_all.interest_type_id%type,
				p_new_primary_interest_code_id IN as_lead_lines_all.primary_interest_code_id%type,
				p_new_sec_interest_code_id IN as_lead_lines_all.secondary_interest_code_id%type,
				p_new_product_category_id IN as_lead_lines_all.product_category_id%type,
				p_new_product_cat_set_id IN as_lead_lines_all.product_cat_set_id%type,
				p_new_total_amount IN as_lead_lines_all.total_amount%type,
				p_old_total_amount IN as_lead_lines_all.total_amount%type,
				p_old_lead_line_id IN as_lead_lines_all.lead_line_id%type,
                        p_new_quantity IN as_lead_lines_all.quantity%type,
                        p_new_uom_code IN as_lead_lines_all.uom_code%type,
                        p_new_inventory_item_id IN as_lead_lines_all.inventory_item_id%type,
                        p_new_organization_id IN as_lead_lines_all.organization_id%type,
                        p_old_frcst_date IN as_lead_lines_all.forecast_date%type,
                        p_old_rolling_frcst_flg IN as_lead_lines_all.rolling_forecast_flag%type,
                        p_new_frcst_date IN as_lead_lines_all.forecast_date%type,
                        p_new_rolling_frcst_flg IN as_lead_lines_all.rolling_forecast_flag%type,
				p_trigger_mode IN VARCHAR2);

Procedure Sales_Credit_Trg_Handler(
				p_new_sales_credit_id                 IN NUMBER,
				p_new_last_update_date                IN DATE,
				p_new_last_updated_by                 IN NUMBER,
				p_new_creation_date                   IN DATE,
				p_new_created_by                      IN NUMBER,
				p_new_last_update_login               IN NUMBER,
				p_new_request_id                      IN NUMBER,
				p_new_lead_id                         IN NUMBER,
				p_new_lead_line_id                    IN NUMBER,
				p_new_salesforce_id                   IN NUMBER,
				p_new_person_id                       IN NUMBER,
				p_new_salesgroup_id                   IN NUMBER,
				p_new_credit_amount                   IN NUMBER,
				p_new_credit_percent                  IN NUMBER,
  				p_old_sales_credit_id                 IN NUMBER,
  				p_new_credit_type_id                  IN NUMBER,
                    	p_new_partner_address_id              IN NUMBER,
                    	p_old_partner_customer_id             IN NUMBER,
                    	p_new_partner_customer_id             IN NUMBER,
                p_opp_worst_forecast_amount       IN NUMBER,
                p_opp_forecast_amount             IN NUMBER,
                p_opp_best_forecast_amount        IN NUMBER,
				p_trigger_mode  		      	  IN OUT NOCOPY VARCHAR2);

Procedure convert_amounts(p_from_currency IN Varchar2,
                          p_decision_date IN Date,
                          p_ctotal_amt IN OUT NOCOPY Number,
                          p_csc_amt IN OUT NOCOPY Number,
                          p_cwon_amt IN OUT NOCOPY Number,
                          p_cweighted_amt IN OUT NOCOPY Number,
                          p_status_flg OUT NOCOPY Number);


Procedure Fetch_Interest_Info (
    p_interest_type_id IN Number,
    p_interest_type OUT NOCOPY Varchar2,
    p_primary_interest_code_id IN Number,
    p_primary_interest_code OUT NOCOPY Varchar2,
    p_secondary_interest_code_id IN Number,
    p_secondary_interest_code OUT NOCOPY Varchar2);



INVALID_FORECAST_CALENDAR     EXCEPTION;
INVALID_PERIOD                EXCEPTION;

End AS_SC_DENORM_TRG ;

 

/
