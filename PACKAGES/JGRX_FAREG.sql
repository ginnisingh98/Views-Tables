--------------------------------------------------------
--  DDL for Package JGRX_FAREG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JGRX_FAREG" AUTHID CURRENT_USER AS
/* $Header: jgrxfrs.pls 115.3 2000/10/09 18:01:27 pkm ship   $ */

--  Main Core Report
    PROCEDURE fa_get_report  (
        p_book_type_code       IN  VARCHAR2,
        p_period_from          IN  VARCHAR2,
        p_period_to            IN  VARCHAR2,
        p_dummy                IN  NUMBER,
        p_major_category       IN  VARCHAR2,
        p_minor_category       IN  VARCHAR2,
        p_type                 IN  VARCHAR2,  -- ASSET or RTRMNT
        request_id             IN  NUMBER,
        retcode                OUT NUMBER,
        errbuf                 OUT VARCHAR2);



--
-- All event trigger procedures must be defined as public procedures
-- Procedure written for the Main/Core Report.

   PROCEDURE fa_ASSET_before_report;

   PROCEDURE fa_ASSET_bind (c IN INTEGER);

   PROCEDURE fa_ASSET_after_fetch;

   PROCEDURE fa_ASSET_after_report;


   PROCEDURE fa_RTRMNT_before_report;

   PROCEDURE fa_RTRMNT_bind (c IN INTEGER);

   PROCEDURE fa_RTRMNT_after_fetch;

   PROCEDURE fa_RTRMNT_after_report;


--
-- These are local procedure
--
   FUNCTION Get_category_segment RETURN VARCHAR2;

   PROCEDURE Get_period_date (
        p_period_from          IN  VARCHAR2,
        p_period_to            IN  VARCHAR2);

   PROCEDURE Startup;
   PROCEDURE Get_RTRMNT_reserve ;
   PROCEDURE Get_cost_value;
   PROCEDURE Get_cost_increase;
   PROCEDURE Get_cost_decrease;

   PROCEDURE Get_revaluation;
   PROCEDURE Get_revaluation_change;

   PROCEDURE Get_deprn_reserve_value;
   PROCEDURE Get_deprn_reserve_increase;
   PROCEDURE Get_deprn_reserve_decrease;

   PROCEDURE Get_bonus_reserve_value;
   PROCEDURE Get_bonus_reserve_increase;
   PROCEDURE Get_bonus_reserve_decrease;

   PROCEDURE Get_fiscal_year_date;
   PROCEDURE Get_depreciation_rate;
   PROCEDURE Get_bonus_rate;

   PROCEDURE Get_transactions;
   PROCEDURE Get_addition_transactions;
   PROCEDURE Get_adjustment_transactions;
   PROCEDURE Get_retirement_transactions;
   PROCEDURE Get_revaluation_transactions;

   PROCEDURE Insert_transaction( p_transaction_date    IN DATE,
                                 p_transaction_number  IN NUMBER,
 		                         p_transaction_code    IN VARCHAR2,
                                 p_transaction_amount  IN NUMBER);

   PROCEDURE Get_Net_Book_Value;
   PROCEDURE Get_invoice_number;
   procedure Get_deprn_accounts;

   FUNCTION Get_starting_depreciation_year RETURN NUMBER;

   FUNCTION Get_parent_asset_number RETURN VARCHAR2;

   FUNCTION Get_account_segment RETURN VARCHAR2;

  --
  -- This is the structure to hold the placeholder values
  --
  TYPE var_t IS RECORD(
       ORGANIZATION_NAME                        VARCHAR2(60),
       FUNCTIONAL_CURRENCY_CODE		        VARCHAR2(15),
       LAST_UPDATE_DATE                         DATE,
       LAST_UPDATED_BY                          NUMBER,
       LAST_UPDATE_LOGIN                        NUMBER,
       CREATION_DATE                            DATE,
       CREATED_BY                               NUMBER,
       MAJOR_CATEGORY                           VARCHAR2(30),
       MINOR_CATEGORY                           VARCHAR2(30),
       DEPRN_RATE                               NUMBER,
       STARTING_DEPRN_YEAR                      VARCHAR2(4),
       ASSET_HEADING                            VARCHAR2(15),
       ASSET_NUMBER                             VARCHAR2(25),
       DESCRIPTION                              VARCHAR2(80),
       PARENT_ASSET_ID			        NUMBER,
       PARENT_ASSET_NUMBER			VARCHAR2(15),
       ASSET_COST_ORIG                          NUMBER,
       BONUS_RATE                               NUMBER,
       INVOICE_NUMBER                           VARCHAR2(50),
       SUPPLIER_NAME                            VARCHAR2(80),
       COST_ACCOUNT                             VARCHAR2(25),
       EXPENSE_ACCOUNT                          VARCHAR2(25),
       RESERVE_ACCOUNT                          VARCHAR2(25),
       BONUS_DEPRN_ACCOUNT                      VARCHAR2(25),
       BONUS_RESERVE_ACCOUNT                    VARCHAR2(25),
       ASSET_COST_INITIAL                       NUMBER,
       ASSET_COST_INCREASE                      NUMBER,
       ASSET_COST_DECREASE                      NUMBER,
       ASSET_COST_FINAL                         NUMBER,
       REVALUATION_INITIAL                      NUMBER,
       REVALUATION_INCREASE                     NUMBER,
       REVALUATION_DECREASE                     NUMBER,
       REVALUATION_FINAL                        NUMBER,
       DEPRN_RESERVE_INITIAL                    NUMBER,
       DEPRN_RESERVE_INCREASE                   NUMBER,
       DEPRN_RESERVE_DECREASE                   NUMBER,
       DEPRN_RESERVE_FINAL                      NUMBER,
       BONUS_RESERVE_INITIAL                    NUMBER,
       BONUS_RESERVE_INCREASE                   NUMBER,
       BONUS_RESERVE_DECREASE                   NUMBER,
       BONUS_RESERVE_FINAL                      NUMBER,
       NET_BOOK_VALUE_INITIAL                   NUMBER,
       NET_BOOK_VALUE_INCREASE                  NUMBER,
       NET_BOOK_VALUE_DECREASE                  NUMBER,
       NET_BOOK_VALUE_FINAL                     NUMBER,
       TRANSACTION_DATE                         DATE,
       TRANSACTION_NUMBER                       NUMBER,
       TRANSACTION_CODE                         VARCHAR2(20),
       TRANSACTION_AMOUNT                       NUMBER,
       SALES_AMOUNT                             NUMBER,
       COST_RETIRED                             NUMBER,
       DEPRN_RESERVE                            NUMBER,
       BONUS_RESERVE                            NUMBER,
       NET_BOOK_VALUE                           NUMBER,
       GAIN_LOSS                                NUMBER,
       ASSET_ID                                 NUMBER,
       PRORATE_DATE                             DATE,
       RATE_SOURCE_ROULE                        VARCHAR2(10),
       date_placed_in_service                   DATE,
       method_id                                NUMBER,
       adjusted_rate                            NUMBER,
       life_in_months                           NUMBER,
       rate_source_rule                         VARCHAR2(10),
       bonus_rule                               VARCHAR2(30),
       date_retired                             DATE,
       transaction_header_id                    NUMBER,
       INITIAL_HEADING           		VARCHAR(15),
       VARIATION_HEADING                	VARCHAR(15),
       FINAL_HEADING            		VARCHAR(132),
       ASSET_VARIATION          		NUMBER,
       REVAL_VARIATION	                	NUMBER,
       DEPRN_VARIATION          		NUMBER,
       BONUS_VARIATION          		NUMBER,
       NETBO_VARIATION          		NUMBER,
       REVALUATION_TOTAL                	NUMBER
);

   var var_t;

END JGRX_FAREG;

 

/
