--------------------------------------------------------
--  DDL for Package AS_LEADS_LINES_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_LEADS_LINES_LOG_PKG" AUTHID CURRENT_USER as
/* $Header: asxtlnls.pls 120.2 2005/09/02 04:05:30 appldev ship $ */
PROCEDURE Insert_Row(p_lead_id    NUMBER,
  p_lead_line_id                    NUMBER,
  p_last_update_date                        DATE,
  p_last_updated_by                         NUMBER,
  p_last_update_login                       NUMBER,
  p_creation_date                   DATE,
  p_created_by                              NUMBER,
  p_interest_type_id                        NUMBER,
  p_primary_interest_code_id                NUMBER,
  p_secondary_interest_code_id              NUMBER,
  p_product_category_id                     NUMBER,
  p_product_cat_set_id                      NUMBER,
  p_inventory_item_id                       NUMBER,
  p_organization                    NUMBER,
  p_source_promotion_id                     NUMBER,
  p_offer_id                                NUMBER,
  p_org_id                          NUMBER,
  p_forecast_date                   DATE,
  p_rolling_forecast_flag           VARCHAR2,
  p_endday_log_flag         VARCHAR2,
  p_TRIGGER_MODE 	   	    VARCHAR2);
PROCEDURE Update_Row(p_lead_id            NUMBER,
	old_lead_line_id                  NUMBER,
	old_last_update_date              DATE,
	new_last_update_date		DATE,
	p_last_updated_by               NUMBER,
    	p_last_update_login             NUMBER,
    	p_creation_date                 DATE,
    	p_created_by                    NUMBER,
    	p_interest_type_id              NUMBER,
    	p_primary_interest_code_id      NUMBER,
    	p_secondary_interest_code_id    NUMBER,
        p_product_category_id           NUMBER,
        p_product_cat_set_id            NUMBER,
    	p_inventory_item_id             NUMBER,
    	p_organization_id               NUMBER,
    	p_source_promotion_id           NUMBER,
    	p_offer_id                      NUMBER,
    	p_org_id                        NUMBER,
    	p_forecast_date                 DATE,
    	p_rolling_forecast_flag         VARCHAR2,
    	p_endday_log_flag       VARCHAR2,
    	p_TRIGGER_MODE 	   		VARCHAR2);


PROCEDURE Delete_Row(p_old_lead_id	NUMBER,
  		p_old_lead_line_id 	NUMBER,
		p_old_last_update_date      DATE,
		p_old_last_updated_by       NUMBER,
		p_old_last_update_login     NUMBER,
		p_old_creation_date         DATE,
  		p_old_created_by            NUMBER,
        p_endday_log_flag         VARCHAR2);

END AS_LEADS_LINES_LOG_PKG;

 

/
