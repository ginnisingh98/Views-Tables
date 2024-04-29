--------------------------------------------------------
--  DDL for Package GCS_DATASUB_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_DATASUB_UTILITY_PKG" AUTHID CURRENT_USER as
/* $Header: gcs_datasub_uts.pls 120.2 2006/06/02 06:30:00 vkosuri noship $ */

  PROCEDURE update_ytd_balances	(p_load_id                  IN      NUMBER,
    			 	                     p_source_system_code        IN      NUMBER,
               			   	         p_dataset_code              IN      NUMBER,
                         	       p_cal_period_id             IN      NUMBER,
   			    	                   p_ledger_id                 IN      NUMBER,
                                 p_currency_type             IN      VARCHAR2,
    			                       p_currency_code             IN      VARCHAR2);

  PROCEDURE update_ptd_balances (p_load_id                   IN      NUMBER,
                                 p_source_system_code        IN      NUMBER,
                                 p_dataset_code              IN      NUMBER,
                                 p_cal_period_id             IN      NUMBER,
                                 p_ledger_id                 IN      NUMBER,
                                 p_currency_type             IN      VARCHAR2,
                                 p_currency_code             IN      VARCHAR2);

  PROCEDURE update_ptd_balance_sheet
				(p_load_id                   IN      NUMBER,
                                 p_source_system_code        IN      NUMBER,
                                 p_dataset_code              IN      NUMBER,
                                 p_cal_period_id             IN      NUMBER,
                                 p_ledger_id                 IN      NUMBER,
                                 p_currency_type             IN      VARCHAR2,
                                 p_currency_code             IN      VARCHAR2);

  PROCEDURE validate_dimension_members(p_load_id             IN      NUMBER );

END GCS_DATASUB_UTILITY_PKG;


 

/
