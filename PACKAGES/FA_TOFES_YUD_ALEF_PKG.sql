--------------------------------------------------------
--  DDL for Package FA_TOFES_YUD_ALEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_TOFES_YUD_ALEF_PKG" 
-- $Header: FASTYAPS.pls 120.4.12010000.4 2009/10/09 19:18:28 mswetha ship $
-- ****************************************************************************************
-- Copyright (c)  2000    Oracle            Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
--  FASTYAPS.pls
--
-- DESCRIPTION
--  This script creates the PackageSpecification of FA_TOFES_YUD_ALEF_PKG.
--  This package AUTHID CURRENT_USER is used to generate IsraeliFA Report.
--
-- USAGE
--   To install        How to Install
--   To execute        How to Execute
--
-- PROGRAM LIST        DESCRIPTION
--
-- BEFOREREPORT        This function is used to dynamically get the
--                     WHERE clause in SELECT statement.
--
--YTD_TRANS_AMT         This Funtion is used to Calculate the YTD TRANSACTION AMOUNT
--
--YTD_DEPRN_AMT         This Funtion is used to Calculate the YTD Depreciation Amount
--
--YTD_DEPRN_RETIRE_AMT  This Funtion is used to calcualte the YTD Depreciation retire Amount
--
--ACCM_DEPRN_PR_AMT     This Funtion is used to calcualte the Accumulated Depreciation Prior Year Amount
--
--PURCHASE_DATE         This Funtion is used to calculate the Purchase Date
--
-- DEPENDENCIES
-- None
--
-- CALLED BY
-- Tofes Yud Alef Report 1342 (Israel)
--
-- LAST UPDATE DATE    22-Jan-2007
-- Date the program has been modified for the last time.
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)       DESCRIPTION
-- ------- ----------- --------------- --------------------------------------
-- Draft1A 22-Jan-2007 Karna Kumar M Initial Creation
--===========================================================================*/
AS

/*=========================================
Variables to Hold the Parameter Values
=========================================*/
p_book_name    VARCHAR2(30);
p_ledger_id    NUMBER;
p_legal_entity NUMBER;
p_begin_period VARCHAR2(30);
p_end_period   VARCHAR2(30);
P_ca_set_of_books_id    number;
P_mrcsobtype    varchar2(10);
lp_currency_code        varchar2(15);
lp_fa_book_controls     varchar2(50);
lp_fa_books     varchar2(50);
lp_fa_adjustments       varchar2(50);
lp_fa_retirements       varchar2(50);
lp_fa_deprn_periods varchar2(50);
lp_fa_asset_invoices varchar2(50);
/*=========================================
Lexical Variables to obtain dynamic values
=========================================*/

p_lex_begin_period_counter NUMBER;  -- Obtains the Period number for a beginning Period
p_lex_end_period_counter   NUMBER;  -- Obtains the Period number for a ending Period
lc_acct_flex_struc         NUMBER;

/*=========================================
Public Functions
=========================================*/

FUNCTION ytd_trans_amt(p_asset_id_in IN NUMBER) RETURN NUMBER;
FUNCTION deprn_claim_number(p_asset_id_in IN NUMBER) RETURN NUMBER;
FUNCTION ytd_deprn_amt(p_asset_id_in IN NUMBER) RETURN NUMBER;
FUNCTION ytd_deprn_retire_amt(p_asset_id_in    IN NUMBER
                             ,p_period_counter IN NUMBER) RETURN NUMBER;
FUNCTION accm_deprn_pr_amt(p_asset_id_in IN NUMBER) RETURN NUMBER;
FUNCTION accm_deprn_pr_retire_amt(p_asset_id_in    IN NUMBER
                                 ,p_period_counter IN NUMBER) RETURN NUMBER;
FUNCTION purchase_date(p_asset_id_in IN NUMBER) RETURN DATE;
FUNCTION beforereport  RETURN BOOLEAN;
function AfterPForm return boolean  ;
END FA_TOFES_YUD_ALEF_PKG;

/
