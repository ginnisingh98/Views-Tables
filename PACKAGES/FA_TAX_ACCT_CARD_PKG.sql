--------------------------------------------------------
--  DDL for Package FA_TAX_ACCT_CARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_TAX_ACCT_CARD_PKG" AUTHID CURRENT_USER AS
-- $Header: fastacps.pls 120.1.12010000.2 2009/07/19 08:19:31 glchen ship $
-- ****************************************************************************************
-- Copyright (c)  2000  Oracle Solution Services (India)     Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
-- fastacps.pls
--
-- DESCRIPTION
--  This script creates the package specification of fastacps.pls
--  This package is used to generate Asset Tax Accounting Card - Russia.
--
-- USAGE
--   To install        How to Install
--   To execute        How to Execute
--
-- PROGRAM LIST                                 DESCRIPTION
--  beforereport                                      initializes the where clauses with appropriate values
--  get_dff_column_name                     fetches DFF column names
--
-- DEPENDENCIES
--   None.
--
--
-- LAST UPDATE DATE   26-FEB-2007
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION   DATE           AUTHOR(S)                 DESCRIPTION
-- ------- ----------- ------------------- ---------------------------
--  1.0    25-FEB-2007  Srikanth Mallikarjun Gupta     Creation
--****************************************************************************************

--******************************************************
--Variables to Hold the Parameter Values
--******************************************************

P_BOOK_NAME                VARCHAR2(15);
P_CATEGORY_FLEX_STRUCTURE  NUMBER;
P_ASSET_CATEGORY           VARCHAR2(150);
P_ASSET_NUMBER             VARCHAR2(150);


--*******************************************************
--Constants to obtain dynamic values
--*******************************************************

lc_state_reg_date            VARCHAR2(40);
lc_years                     VARCHAR2(40);
lc_months                    VARCHAR2(40);
lc_tax_book_cost             VARCHAR2(40);
lc_reference                 VARCHAR2(40);
lc_event_date                VARCHAR2(40);
lc_suspense_reason           VARCHAR2(40);
lc_adjusting_coefficient     VARCHAR2(40);
lc_adj_rate_reason           VARCHAR2(40);
lc_base_rate                 VARCHAR2(40);
lc_company_name              VARCHAR2(40);
lc_last_deprn_period         VARCHAR2(40);
lc_currency_code             VARCHAR2(40);
lc_asset_category_where      VARCHAR2(300);
lc_asset_number_where        VARCHAR2(300);

--*******************************************************
--Public Functions
--*******************************************************

FUNCTION beforereport RETURN BOOLEAN;
FUNCTION get_dff_column_name(p_appln_id      in  NUMBER
							 ,p_dff_name     in  VARCHAR2
							 ,p_segment_name in  VARCHAR2
							) RETURN VARCHAR2;

END fa_tax_acct_card_pkg;

/
