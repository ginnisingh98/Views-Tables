--------------------------------------------------------
--  DDL for Package CE_FORECAST_REMOTE_SOURCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_FORECAST_REMOTE_SOURCES" AUTHID CURRENT_USER AS
/*  $Header: cefremts.pls 120.3 2003/12/05 19:09:57 sspoonen ship $ */

TYPE AgingRec is record
        ( column_id 	NUMBER,
          start_date    DATE,
          end_date      DATE);

TYPE AgingTab is Table of AgingRec INDEX BY BINARY_INTEGER;

TYPE ConversionRec IS RECORD
  ( from_currency_code	VARCHAR2(30),
    conversion_rate  	NUMBER);

TYPE ConversionTab IS TABLE OF ConversionRec INDEX BY BINARY_INTEGER;

TYPE AmountRec IS RECORD
  ( currency_code	VARCHAR2(30),
    trx_date		DATE,
    bank_account_id	NUMBER,
    forecast_amount	NUMBER,
    trx_amount		NUMBER,
    forecast_column_id	NUMBER);

TYPE AmountTab is TABLE OF AmountRec INDEX BY BINARY_INTEGER;

FUNCTION Populate_Remote_Amounts
  ( forecast_id			NUMBER,
    source_view			VARCHAR2,
    db_link			VARCHAR2,
    forecast_row_id		NUMBER,
    aging_table			AgingTab,
    conversion_table		ConversionTab,
    rp_forecast_currency    	VARCHAR2,
    rp_exchange_date        	DATE,
    rp_exchange_type        	VARCHAR2,
    rp_exchange_rate        	NUMBER,
    rp_src_curr_type        	VARCHAR2,
    rp_src_currency         	VARCHAR2,
    rp_amount_threshold		NUMBER,
    lead_time			NUMBER,
    criteria1			VARCHAR2,
    criteria2			VARCHAR2,
    criteria3			VARCHAR2,
    criteria4			VARCHAR2,
    criteria5			VARCHAR2,
    criteria6			VARCHAR2,
    criteria7			VARCHAR2,
    criteria8			VARCHAR2,
    criteria9			VARCHAR2,
    criteria10			VARCHAR2,
    criteria11			VARCHAR2,
    criteria12			VARCHAR2,
    criteria13			VARCHAR2,
    criteria14			VARCHAR2,
    criteria15			VARCHAR2,
    amount_table		IN OUT NOCOPY AmountTab) RETURN NUMBER;

END CE_FORECAST_REMOTE_SOURCES;


 

/
