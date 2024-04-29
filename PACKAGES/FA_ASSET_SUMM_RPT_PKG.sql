--------------------------------------------------------
--  DDL for Package FA_ASSET_SUMM_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_ASSET_SUMM_RPT_PKG" AUTHID CURRENT_USER AS
-- $Header: FASSUMRPTPS.pls 120.4.12010000.3 2009/08/17 14:37:40 klakshmi ship $
/*===========================================================================+
--*************************************************************************
-- Copyright (c)  2000    Oracle                 Product Development
-- All rights reserved
--*************************************************************************
--
-- HEADER
--  Source control header
--
-- PROGRAM NAME
--   FASSUMRPTPS.pls
--
-- DESCRIPTION
-- This script creates the package specification of FA_ASSET_SUMM_RPT_PKG
-- This package is used for Asset Summary Report of Germany.
--
-- USAGE
--   To install        sqlplus <apps_user>/<apps_pwd> @FASSUMRPTPS.pls
--   To execute        sqlplus <apps_user>/<apps_pwd> FA_ASSET_SUMM_RPT_PKG.
--
-- PROGRAM LIST        DESCRIPTION
--
-- BEFOREREPORT        This function is used to dynamically get the
--                     WHERE clause in SELECT statement.
--
--ADDITIONS_AMOUNT     This function is used to obtain the Asset Additions
--                     during the from and to period values
--RETIREMENT_AMOUNT    This function is used to obtain the Retirement amount
--                     of an asset that is retired during the period
--CHANGES_OF_ACCOUNTS  This function obtains the amount that is changed from
--                     one Code Combination to another by Transfer of Assets
--                     or by the reclassification of assets
--CURRENT_AMOUNT       This function is used to obtain the cost of an asset
--                     which is created before the "from period"
--ACCM_DEPRN_AMT       This function is used to calculate the Depreciation
--                     reserve amount for an Asset uptil the End period.
--DEPRN_EXPENSE        This function is used to calculate the Depreciation amount
--                     during the from and to period values of an Asset
--ADJUSTMENT_AMOUNT    This function is used to obtain the Cost adjustments of an
--                     asset during the period
--ACCM_DEPRN_AMT_PR_YEAR  This function is used to calculate the Depreciation reserve
--                        of an asset prior to the from period of an asset
--                        This is mainly used for calculating the Net Book Value of
--                        an Asset
--
-- DEPENDENCIES
-- None
--
-- CALLED BY
-- Asset Summary Report (Germany).
--
-- LAST UPDATE DATE    26-Feb-2007
-- Date the program has been modified for the last time.
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)       DESCRIPTION
-- ------- ----------- --------------- --------------------------------------
-- Draft1A 26-Feb-2007 Sandeep Kumar G Initial Creation
-- Draft1B 15-Aug-2009 Rakesh Pulla   Added the parameter p_fah_trx_header_id to meet
--                                    the requirement in the SR 7284007.992
+===========================================================================*/


/*=========================================
Variables to Hold the Parameter Values
=========================================*/
P_BOOK_NAME       VARCHAR2(30);
P_BEGIN_PERIOD    VARCHAR2(30);
P_END_PERIOD      VARCHAR2(30);
P_ACCOUNT_DESC    VARCHAR2(30);
P_FROM_CATEGORY   VARCHAR2(30);
P_TO_CATEGORY     VARCHAR2(30);
P_FROM_ACCOUNT    VARCHAR2(30);
P_TO_ACCOUNT      VARCHAR2(30);
P_ASSET_DETAILS   VARCHAR2(30);

/*=========================================
Lexical Variables to obtain dynamic values
=========================================*/

gn_lex_begin_period_counter NUMBER;  -- Obtains the Period number for a beginning Period
gn_lex_end_period_counter   NUMBER;  -- Obtains the Period number for a ending Period
gc_acct_flex_struc          NUMBER;
gc_cat_flex_struc           NUMBER;

gd_period_close_date        DATE;    --posses the Close date of End period
gd_period_open_date         DATE;    --posses the Open date of Beginning period
gd_per_close_date           DATE;    --posses the Close date of End period
gd_per_open_date            DATE;    --posses the Open date of Beginning period

gc_book_class               VARCHAR2(30);
gc_asset_details            VARCHAR2(1) := 'N';


gc_category_where VARCHAR2(400);

gc_from_maj_seg   VARCHAR2(100);
gc_from_min_seg   VARCHAR2(100);
gc_to_maj_seg     VARCHAR2(100);
gc_to_min_seg     VARCHAR2(100);

gc_trx_sub_type   VARCHAR2(100);

gc_ledger_name    VARCHAR2(30);
gc_currency_code  VARCHAR2(30);
/*=========================================
Public Functions
=========================================*/

FUNCTION ASSIGNED_UNITS(p_asset_id_in IN NUMBER
                       ,p_ccid_in  IN NUMBER
                       ,p_transaction_units_in IN NUMBER
                       ,p_original_cost_in IN NUMBER
                       ,p_units_in  IN NUMBER) RETURN NUMBER;

FUNCTION ADDITIONS_AMOUNT(p_transaction_header_id IN NUMBER
                         ,p_asset_id_in    IN NUMBER
                         ,p_category_id_in IN NUMBER
                         ,p_asset_type_in  IN VARCHAR2
                         ,p_ccid_in        IN NUMBER
                         ,p_location_id_in IN NUMBER
                         ,p_fah_trx_header_id IN NUMBER) RETURN NUMBER;

FUNCTION RETIREMENT_AMOUNT(p_transaction_header_id IN NUMBER
                          ,p_asset_id_in    IN NUMBER
                          ,p_category_id_in IN NUMBER
                          ,p_asset_type_in  IN VARCHAR2
                          ,p_ccid_in        IN NUMBER
                          ,p_location_id_in IN NUMBER) RETURN NUMBER;

FUNCTION CHANGES_OF_ACCOUNTS(p_transaction_header_id IN NUMBER
                            ,p_asset_id_in    IN NUMBER
                            ,p_category_id_in IN NUMBER
                            ,p_asset_type_in  IN VARCHAR2
                            ,p_ccid_in IN NUMBER
                            ,p_location_id_in IN NUMBER
							,p_fah_trx_header_id IN NUMBER) RETURN NUMBER;

FUNCTION CURRENT_AMOUNT(p_transaction_header_id IN NUMBER
                        ,p_asset_id_in IN NUMBER
                        ,p_category_id_in IN NUMBER
                        ,p_asset_type_in  IN VARCHAR2
                        ,p_ccid_in     IN NUMBER
                        ,p_location_id_in IN NUMBER) RETURN NUMBER;

FUNCTION CATEGORY_ACCM_DEPRN_AMT(p_transaction_header_id IN NUMBER
                                ,p_asset_id_in IN NUMBER
                                ,p_ccid_in IN NUMBER
                                ,p_location_id_in IN NUMBER) RETURN NUMBER;
FUNCTION ACCM_DEPRN_AMT(p_transaction_header_id IN NUMBER
                       ,p_asset_id_in IN NUMBER
                       ,p_ccid_in     IN NUMBER
                       ,p_location_id_in IN NUMBER) RETURN NUMBER;

FUNCTION DEPRN_EXPENSE(p_transaction_header_id IN NUMBER
                      ,p_asset_id_in IN NUMBER
                      ,p_ccid_in     IN NUMBER
                      ,p_location_id_in IN NUMBER) RETURN NUMBER;

FUNCTION ADJUSTMENT_AMOUNT(p_transaction_header_id IN NUMBER
                          ,p_asset_id_in    IN NUMBER
                          ,p_category_id_in IN NUMBER
                          ,p_asset_type_in  IN VARCHAR2
                          ,p_location_id_in IN NUMBER
                          ,p_ccid_in     IN NUMBER) RETURN NUMBER;

FUNCTION APPRECIATION_AMOUNT(p_transaction_header_id IN NUMBER
                            ,p_asset_id_in    IN NUMBER
                            ,p_category_id_in IN NUMBER
                            ,p_asset_type_in  IN VARCHAR2
                            ,p_location_id_in IN NUMBER
                            ,p_ccid_in     IN NUMBER) RETURN NUMBER;

FUNCTION ACCM_DEPRN_AMT_PR_YEAR(p_transaction_header_id IN NUMBER
                               ,p_asset_id_in IN NUMBER
                               ,p_ccid_in IN NUMBER
                               ,p_location_id_in IN NUMBER) RETURN NUMBER;

FUNCTION GAIN_LOSS_AMOUNT(p_transaction_header_id IN NUMBER
                         ,p_asset_id_in IN NUMBER
                         ,p_category_id_in IN NUMBER
                         ,p_asset_type_in IN VARCHAR2
                         ,p_ccid_in IN NUMBER
                         ,p_location_id_in IN NUMBER)  RETURN NUMBER;

FUNCTION beforereport RETURN BOOLEAN;

END FA_ASSET_SUMM_RPT_PKG;

/
