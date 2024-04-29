--------------------------------------------------------
--  DDL for Package GCS_XML_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_XML_GEN_PKG" AUTHID CURRENT_USER as
/* $Header: gcsxmlgens.pls 120.7 2005/12/23 11:57:42 hakumar noship $ */
/*
   TYPE r_ds_header_data 	IS RECORD
                                (load_id                 NUMBER(15),
                                 load_name               VARCHAR2(50),
                                 entity_id               NUMBER,
                                 entity_name             VARCHAR2(150),
                                 balance_type            VARCHAR2(80),
                                 amount_type_code        VARCHAR2(30),
                                 amount_type_name        VARCHAR2(80),
                                 curr_type_code          VARCHAR2(30),
                                 curr_type_name          VARCHAR2(80),
                                 currency_code           VARCHAR2(15),
                                 currency_name           VARCHAR2(80),
                                 cal_period_id           NUMBER,
                                 cal_period_name         VARCHAR2(80),
                                 measure_type_code       VARCHAR2(30),
                                 measure_type_name       VARCHAR2(80),
                                 start_time              VARCHAR2(30),
                                 end_time                VARCHAR2(30),
                                 status_code             VARCHAR2(30),
                                 balance_type_code       VARCHAR2(30),
                                 balances_rule_id        NUMBER(9),
                                 balances_rule_name      VARCHAR2(150),
                                 ledger_id               NUMBER,
                                 ledger_name             VARCHAR2(150),
                                 source_system_code      NUMBER,
                                 entity_currency_code    VARCHAR2(15),
                                 sub_global_vs_combo_id  NUMBER);

   TYPE r_cmtb_header_data 	IS RECORD
                                (run_name                VARCHAR2(720),
                                 cal_period_name	     VARCHAR2(450),
                                 balance_type            VARCHAR2(80),
                                 start_time              VARCHAR2(30),
                                 end_time                VARCHAR2(30),
                                 currency_name           VARCHAR2(80),
                                 hierarchy_name          VARCHAR2(150),
                                 hierarchy_id            NUMBER,
                                 cal_period_id           NUMBER);

   TYPE r_ad_header_data 	IS RECORD
                               (entry_name	             VARCHAR2(80),
                               description			     VARCHAR2(240),
                               total_consideration       VARCHAR2(240),
                               category_name             VARCHAR2(80),
                               transaction_date          DATE,
                               hierarchy_name		     VARCHAR2(150),
                               cons_hierarchy_name	     VARCHAR2(150),
                               cons_entity_name		     VARCHAR2(150),
                               child_entity_name	     VARCHAR2(150),
                               currency_name		     VARCHAR2(80));

   --Bugfix 4725916: Added category code to the record to support drilldown
   TYPE r_entry_header_data 	IS RECORD
                                (entry_name	             	VARCHAR2(80),
                                 description		     	VARCHAR2(240),
                                 hierarchy_name		     	VARCHAR2(150),
                                 entity_name		     	VARCHAR2(150),
                                 currency_name		     	VARCHAR2(80),
                                 cal_period_name         	VARCHAR2(80),
                                 suspense_flag           	VARCHAR2(1),
                                 rule_id                 	NUMBER,
                                 entity_id               	NUMBER,
                                 hierarchy_id            	NUMBER,
                                 cal_period_id           	NUMBER,
                                 balance_type_code       	VARCHAR2(30),
                                 currency_code           	VARCHAR2(30),
                                 entity_type_code        	VARCHAR2(30),
				 category_code			VARCHAR2(80));

   TYPE r_rowseq_hash_data IS RECORD
                                (creation_row_sequence NUMBER,
                                 rowseq_hash_key       VARCHAR2(1000));

 --
  -- PROCEDURE
  --   generate_entry_xml
  -- Purpose
  --   Generates the XML per entry and stores on ENTRY_DATA
  --   If entry was created by consolidation rule it will put the XML on EXECUTION_DATA
  --
  --
  -- Arguments
  --   p_entry_id	 	Entry Identifier
  --
  -- Notes
  --

 PROCEDURE  generate_entry_xml ( p_entry_id	      IN  NUMBER,
                                 p_category_code  IN  VARCHAR2,
                                 p_cons_rule_flag IN  VARCHAR2);

 PROCEDURE  generate_cmtb_xml ( p_entry_id          IN  NUMBER,
                                p_entity_id	        IN	NUMBER,
                                p_hierarchy_id      IN  NUMBER,
                                p_cal_period_id     IN  NUMBER,
                                p_balance_type_code IN  VARCHAR2,
                                p_currency_code     IN  VARCHAR2);

 PROCEDURE  generate_ds_xml ( p_load_id	      IN  NUMBER);

 PROCEDURE  generate_ad_xml ( p_ad_transaction_id IN  NUMBER);*/

 PROCEDURE  submit_entry_xml_gen( 	x_errbuf		    OUT NOCOPY	VARCHAR2,
                              		x_retcode		    OUT NOCOPY	VARCHAR2,
                              		p_run_name		    IN VARCHAR2,
                              		p_cons_entity_id   	IN NUMBER,
                              		p_category_code    	IN VARCHAR2,
                              		p_child_entity_id  	IN NUMBER,
                              		p_run_detail_id    	IN NUMBER);
END GCS_XML_GEN_PKG;

 

/
