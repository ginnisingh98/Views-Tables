--------------------------------------------------------
--  DDL for Package AS_SALES_CREDITS_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_CREDITS_LOG_PKG" AUTHID CURRENT_USER as
/* $Header: asxtscls.pls 120.2 2005/09/02 04:05:37 appldev ship $ */
PROCEDURE Insert_Row(p_new_lead_id    	NUMBER,
  						p_new_lead_line_id 	NUMBER,
						p_new_sales_credit_id	NUMBER,
						p_new_last_update_date  DATE,
						p_new_last_updated_by   NUMBER,
						p_new_last_update_login NUMBER,
						p_new_creation_date     DATE,
  						p_new_created_by        NUMBER,
						p_new_salesforce_id	NUMBER,
						p_new_salesgroup_id	NUMBER,
						p_new_credit_type_id	NUMBER,
						p_new_credit_percent	NUMBER,
						p_new_credit_amount	NUMBER,
						p_new_opp_worst_frcst_amount NUMBER,
						p_new_opp_frcst_amount NUMBER,
						p_new_opp_best_frcst_amount NUMBER,
						p_endday_log_flag   VARCHAR2,
						p_TRIGGER_MODE 	   	VARCHAR2);

PROCEDURE Update_Row(p_new_lead_id          NUMBER,
	p_new_lead_line_id              NUMBER,
	p_old_sales_credit_id		NUMBER,
	p_old_last_update_date          DATE,
	p_new_last_update_date		DATE,
	p_new_last_updated_by           NUMBER,
    	p_new_last_update_login         NUMBER,
    	p_new_creation_date             DATE,
    	p_new_created_by                NUMBER,
	p_new_salesforce_id		NUMBER,
	p_new_salesgroup_id		NUMBER,
	p_new_credit_type_id		NUMBER,
	p_new_credit_percent		NUMBER,
	p_new_credit_amount		NUMBER,
	p_new_opp_worst_frcst_amount NUMBER,
	p_new_opp_frcst_amount NUMBER,
	p_new_opp_best_frcst_amount NUMBER,
	p_endday_log_flag           VARCHAR2,
	p_TRIGGER_MODE 	   	    	VARCHAR2);


Procedure Delete_Row(p_old_lead_id   NUMBER,
  	p_old_lead_line_id 	NUMBER,
	p_old_sales_credit_id	NUMBER,
	p_old_last_update_date  DATE,
	p_old_last_updated_by   NUMBER,
	p_old_last_update_login NUMBER,
	p_old_creation_date     DATE,
  	p_old_created_by        NUMBER,
	p_endday_log_flag           VARCHAR2);

END AS_SALES_CREDITS_LOG_PKG;

 

/
