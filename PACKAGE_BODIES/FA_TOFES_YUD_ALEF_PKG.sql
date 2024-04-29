--------------------------------------------------------
--  DDL for Package Body FA_TOFES_YUD_ALEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_TOFES_YUD_ALEF_PKG" AS
-- $Header: FASTYAPB.pls 120.4.12010000.8 2010/02/04 08:24:34 mswetha ship $
-- ****************************************************************************************
-- Copyright (c)  2000  Oracle Solution Services (India)     Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
--  FASTYAPB.pls
--
-- DESCRIPTION
--  This script creates the package body of FA_TOFES_YUD_ALEF_PKG.
--  This package is used to generate Israeli Fixed Asset Report.
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
-- Draft1B 22-Sep-2009 Karna Kumar M updated the code as per the Bug# 8915053
-- Draft1C 11-Nov-2009 Karna Kumar M updated the code as per the Bug# 8915053
--===========================================================================*/

--Function to Calculate the YTD TRANSACTION AMOUNT
FUNCTION YTD_TRANS_AMT(p_asset_id_in IN NUMBER)
RETURN NUMBER
IS
ln_amount  NUMBER;
BEGIN

IF upper(P_MRCSOBTYPE) = 'R'
THEN
  SELECT SUM(DECODE(DEBIT_CREDIT_FLAG, 'CR', ADJUSTMENT_AMOUNT * (-1), ADJUSTMENT_AMOUNT))
    INTO ln_amount
    FROM FA_ADJUSTMENTS_MRC_V
   WHERE BOOK_TYPE_CODE   = P_BOOK_NAME
     AND ASSET_ID    = p_asset_id_in
     AND ADJUSTMENT_TYPE  = 'COST'
     AND SOURCE_TYPE_CODE = 'ADJUSTMENT'
     AND PERIOD_COUNTER_ADJUSTED BETWEEN p_lex_begin_period_counter AND p_lex_end_period_counter;

  ELSE

  SELECT SUM(DECODE(DEBIT_CREDIT_FLAG, 'CR', ADJUSTMENT_AMOUNT * (-1), ADJUSTMENT_AMOUNT))
    INTO ln_amount
    FROM FA_ADJUSTMENTS
   WHERE BOOK_TYPE_CODE   = P_BOOK_NAME
     AND ASSET_ID    = p_asset_id_in
     AND ADJUSTMENT_TYPE  = 'COST'
     AND SOURCE_TYPE_CODE = 'ADJUSTMENT'
     AND PERIOD_COUNTER_ADJUSTED BETWEEN p_lex_begin_period_counter AND p_lex_end_period_counter;
END IF;

         RETURN ln_amount;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  ln_amount := 0;
  RETURN ln_amount;
END YTD_TRANS_AMT;

--=====================================================================
--=====================================================================

FUNCTION DEPRN_CLAIM_NUMBER (P_ASSET_ID_IN in number)
RETURN NUMBER
IS
ln_number  NUMBER;
BEGIN

IF upper(P_MRCSOBTYPE) = 'R'
THEN
  /* Bug#8915053,9103594-Changes done as per new formula for Depr.Claim Rate */
   SELECT count(PERIOD_COUNTER)
   INTO ln_number
   FROM FA_DEPRN_SUMMARY_MRC_V
   WHERE book_type_code = p_book_name
   AND asset_id = p_asset_id_in
   AND period_counter BETWEEN p_lex_begin_period_counter AND p_lex_end_period_counter
   AND deprn_source_code = 'DEPRN'
   AND deprn_amount <> 0;
ELSE
   /* Bug#8915053,9103594-Changes done as per new formula for Depr.Claim Rate */
   SELECT count(PERIOD_COUNTER)
   INTO ln_number
   FROM fa_Deprn_summary
   WHERE book_type_code = p_book_name
   AND asset_id = p_asset_id_in
   AND period_counter BETWEEN p_lex_begin_period_counter AND p_lex_end_period_counter
   AND deprn_source_code = 'DEPRN'
   AND deprn_amount <> 0;
END IF;
RETURN ln_number;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
 ln_number := 1;
 RETURN ln_number;
END DEPRN_CLAIM_NUMBER;

--=====================================================================
--=====================================================================
--Function to Calculate the YTD Depreciation Amount
FUNCTION YTD_DEPRN_AMT(p_asset_id_in IN NUMBER)
RETURN NUMBER
IS
ln_amount  NUMBER;
BEGIN
  /*SELECT SUM(DEPRN_AMOUNT)
    INTO ln_amount
    FROM FA_DEPRN_SUMMARY
   WHERE BOOK_TYPE_CODE = P_BOOK_NAME
     AND ASSET_ID     = p_asset_id_in
     AND PERIOD_COUNTER BETWEEN p_lex_begin_period_counter AND p_lex_end_period_counter;*/
--Bug#9337624:Changes done to calculate ytd correctly.
IF upper(P_MRCSOBTYPE) = 'R' THEN
   SELECT sum(deprn_amount)
      INTO ln_amount
      FROM FA_DEPRN_SUMMARY_MRC_V
      WHERE BOOK_TYPE_CODE = P_BOOK_NAME
      AND ASSET_ID     = p_asset_id_in
      AND DEPRN_SOURCE_CODE = 'DEPRN'
      AND PERIOD_COUNTER  BETWEEN p_lex_begin_period_counter AND p_lex_end_period_counter;
ELSE
   SELECT sum(deprn_amount)
      INTO ln_amount
      FROM FA_DEPRN_SUMMARY
      WHERE BOOK_TYPE_CODE = P_BOOK_NAME
      AND ASSET_ID     = p_asset_id_in
      AND DEPRN_SOURCE_CODE = 'DEPRN'
      AND PERIOD_COUNTER  BETWEEN p_lex_begin_period_counter AND p_lex_end_period_counter;
END IF;

 RETURN ln_amount;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
 ln_amount := 0;
 RETURN ln_amount;
END YTD_DEPRN_AMT;

--=====================================================================
--=====================================================================
--Function to Calculate the YTD Depreciation retire Amount
FUNCTION YTD_DEPRN_RETIRE_AMT(p_asset_id_in IN NUMBER, p_period_counter IN NUMBER)
RETURN NUMBER
IS
ln_amount  NUMBER;
BEGIN
  /*SELECT SUM(DEPRN_AMOUNT)
    INTO ln_amount
    FROM FA_DEPRN_SUMMARY
   WHERE BOOK_TYPE_CODE = P_BOOK_NAME
     AND ASSET_ID     = p_asset_id_in
     AND PERIOD_COUNTER BETWEEN p_lex_begin_period_counter AND p_lex_end_period_counter;*/
IF upper(P_MRCSOBTYPE) = 'R'
THEN
  SELECT DEPRN_ADJUSTMENT_AMOUNT
    INTO ln_amount
    FROM FA_DEPRN_SUMMARY_MRC_V
   WHERE BOOK_TYPE_CODE = P_BOOK_NAME
     AND ASSET_ID     = p_asset_id_in
     AND period_counter = p_period_counter
     AND PERIOD_COUNTER > (SELECT MAX(fdp.period_counter)
  FROM FA_DEPRN_PERIODS_MRC_V fdp
  WHERE FDP.book_type_code = P_BOOK_NAME
  AND fdp.fiscal_year < (SELECT MAX(fiscal_year)
           FROM FA_DEPRN_PERIODS_MRC_V
         WHERE book_type_code = P_BOOK_NAME
         AND  period_close_date IS NOT NULL));
ELSE

  SELECT DEPRN_ADJUSTMENT_AMOUNT
    INTO ln_amount
    FROM FA_DEPRN_SUMMARY
   WHERE BOOK_TYPE_CODE = P_BOOK_NAME
     AND ASSET_ID     = p_asset_id_in
     AND period_counter = p_period_counter
     AND PERIOD_COUNTER > (SELECT MAX(fdp.period_counter)
  FROM fa_deprn_periods fdp
  WHERE FDP.book_type_code = P_BOOK_NAME
  AND fdp.fiscal_year < (SELECT MAX(fiscal_year)
           FROM FA_DEPRN_PERIODS
         WHERE book_type_code = P_BOOK_NAME
         AND  period_close_date IS NOT NULL));
  END IF;

  RETURN ln_amount;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  ln_amount := 0;
  RETURN ln_amount;
END YTD_DEPRN_RETIRE_AMT;

--=====================================================================
--=====================================================================
--Function to calculate the Accumulated Depreciation Prior Year Amount
FUNCTION ACCM_DEPRN_PR_AMT(p_asset_id_in IN NUMBER)
RETURN NUMBER
IS
ln_amount  NUMBER;
BEGIN


IF upper(P_MRCSOBTYPE) = 'R'
THEN
  SELECT SUM(DEPRN_AMOUNT)
    INTO ln_amount
    FROM FA_DEPRN_SUMMARY_MRC_V
   WHERE BOOK_TYPE_CODE = P_BOOK_NAME
     AND ASSET_ID     = p_asset_id_in
     AND PERIOD_COUNTER <= (SELECT MAX(fdp.period_counter)
    FROM FA_DEPRN_PERIODS_MRC_V fdp
   WHERE FDP.book_type_code = P_BOOK_NAME
     AND fdp.fiscal_year < (SELECT MAX(fiscal_year)
                              FROM FA_DEPRN_PERIODS_MRC_V
                                                 WHERE book_type_code = P_BOOK_NAME
                                                   AND  period_close_date IS NOT NULL));

ELSE

  SELECT SUM(DEPRN_AMOUNT)
    INTO ln_amount
    FROM FA_DEPRN_SUMMARY
   WHERE BOOK_TYPE_CODE = P_BOOK_NAME
     AND ASSET_ID     = p_asset_id_in
     AND PERIOD_COUNTER <= (SELECT MAX(fdp.period_counter)
    FROM FA_DEPRN_PERIODS fdp
   WHERE FDP.book_type_code = P_BOOK_NAME
     AND fdp.fiscal_year < (SELECT MAX(fiscal_year)
                              FROM FA_DEPRN_PERIODS
                                                 WHERE book_type_code = P_BOOK_NAME
                                                   AND  period_close_date IS NOT NULL));

END IF;

RETURN ln_amount;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  ln_amount := 0;
  RETURN ln_amount;
END ACCM_DEPRN_PR_AMT;

--=====================================================================
--=====================================================================
--Function to calculate the Accumulated Depreciation Prior Year Amount
FUNCTION ACCM_DEPRN_PR_RETIRE_AMT(p_asset_id_in IN NUMBER, p_period_counter IN NUMBER)
RETURN NUMBER
IS
ln_amount  NUMBER;
BEGIN

IF upper(P_MRCSOBTYPE) = 'R'
THEN
  SELECT SUM(DEPRN_ADJUSTMENT_AMOUNT)
    INTO ln_amount
    FROM FA_DEPRN_SUMMARY_MRC_V
   WHERE BOOK_TYPE_CODE = P_BOOK_NAME
     AND ASSET_ID     = p_asset_id_in
     AND PERIOD_COUNTER = P_PERIOD_COUNTER
     AND PERIOD_COUNTER <= (SELECT MAX(fdp.period_counter)
    FROM FA_DEPRN_PERIODS_MRC_V fdp
   WHERE FDP.book_type_code = P_BOOK_NAME
     AND fdp.fiscal_year < (SELECT MAX(fiscal_year)
                              FROM FA_DEPRN_PERIODS_MRC_V
                                                 WHERE book_type_code = P_BOOK_NAME
                                                   AND period_close_date IS NOT NULL));

ELSE
  SELECT SUM(DEPRN_ADJUSTMENT_AMOUNT)
    INTO ln_amount
    FROM FA_DEPRN_SUMMARY
   WHERE BOOK_TYPE_CODE = P_BOOK_NAME
     AND ASSET_ID     = p_asset_id_in
     AND PERIOD_COUNTER = P_PERIOD_COUNTER
     AND PERIOD_COUNTER <= (SELECT MAX(fdp.period_counter)
    FROM fa_deprn_periods fdp
   WHERE FDP.book_type_code = P_BOOK_NAME
     AND fdp.fiscal_year < (SELECT MAX(fiscal_year)
                              FROM FA_DEPRN_PERIODS
                                                 WHERE book_type_code = P_BOOK_NAME
                                                   AND period_close_date IS NOT NULL));

END IF;

RETURN ln_amount;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  ln_amount := 0;
  RETURN ln_amount;
END ACCM_DEPRN_PR_RETIRE_AMT;

--=====================================================================
--=====================================================================
--Purchase date
FUNCTION PURCHASE_DATE(p_asset_id_in IN NUMBER)
RETURN DATE
IS
ld_date  DATE;
BEGIN
 SELECT INVOICE_DATE
   INTO ld_date
   FROM AP_INVOICES_ALL
  WHERE INVOICE_ID IN (SELECT FAI.INVOICE_ID
                         FROM FA_ASSET_INVOICES FAI
                             ,FA_ADDITIONS_B FA
                             ,FA_BOOKS FB
                       WHERE FAI.ASSET_ID = FA.ASSET_ID
                         AND FA.ASSET_ID = FB.ASSET_ID
                         AND FA.ASSET_ID = p_asset_id_in
                         AND FB.BOOK_TYPE_CODE = P_BOOK_NAME)
                         AND VENDOR_ID IN (SELECT FAI.PO_VENDOR_ID
                        FROM FA_ASSET_INVOICES FAI
                            ,FA_ADDITIONS_B FA
                            ,FA_BOOKS FB
                       WHERE FAI.ASSET_ID = FA.ASSET_ID
                                             AND FA.ASSET_ID = FB.ASSET_ID
                                             AND FA.ASSET_ID = p_asset_id_in
                                             AND FB.BOOK_TYPE_CODE = P_BOOK_NAME);

RETURN ld_date;
EXCEPTION
  --Bug#9237853
  WHEN OTHERS THEN
  SELECT FB.DATE_PLACED_IN_SERVICE
    INTO ld_date
    FROM FA_ADDITIONS_B FA
        ,FA_BOOKS     FB
   WHERE FA.ASSET_ID = FB.ASSET_ID
     AND FA.ASSET_ID = p_asset_id_in
     AND FB.BOOK_TYPE_CODE = P_BOOK_NAME
     AND FB.TRANSACTION_HEADER_ID_OUT IS NULL;

  RETURN ld_date;
END PURCHASE_DATE;

--=====================================================================
--=====================================================================

function AfterPForm return boolean is
begin
  return (TRUE);
end;
--=============================================================
--=============================================================
FUNCTION beforeReport
RETURN BOOLEAN
IS
BEGIN


fnd_file.put_line(fnd_file.log,'p_ca_set_of_books_id  is '||p_ca_set_of_books_id);
IF p_ca_set_of_books_id <> -1999
THEN

  BEGIN
   select mrc_sob_type_code, currency_code
   into P_MRCSOBTYPE, lp_currency_code
   from gl_sets_of_books
   where set_of_books_id = p_ca_set_of_books_id;
    fnd_file.put_line(fnd_file.log, 'P_MRCSOBTYPE    '||P_MRCSOBTYPE);
         fnd_file.put_line(fnd_file.log, 'lp_currency_code    '||lp_currency_code);
  EXCEPTION
    WHEN OTHERS THEN
     P_MRCSOBTYPE := 'P';
  END;
ELSE
   P_MRCSOBTYPE := 'P';
END IF;


  fnd_file.put_line(fnd_file.log,'In the Before Report Proc');
   fnd_file.put_line(fnd_file.log, 'P_MRCSOBTYPE    '||P_MRCSOBTYPE);
IF upper(P_MRCSOBTYPE) = 'R'
THEN
  fnd_client_info.set_currency_context(p_ca_set_of_books_id);
END IF;
 fnd_file.put_line(fnd_file.log, ' after  fnd_client_info ');
 fnd_file.put_line(fnd_file.log, 'P_MRCSOBTYPE    '||P_MRCSOBTYPE);
IF upper(P_MRCSOBTYPE) = 'R'
THEN
  SELECT PERIOD_COUNTER
    INTO p_lex_begin_period_counter
    FROM FA_DEPRN_PERIODS_MRC_V
   WHERE BOOK_TYPE_CODE  = P_BOOK_NAME
     AND PERIOD_NAME  = P_BEGIN_PERIOD;
  fnd_file.put_line(fnd_file.log,'R-p_lex_begin_period_counter::'||p_lex_begin_period_counter);

  SELECT PERIOD_COUNTER
    INTO p_lex_end_period_counter
    FROM FA_DEPRN_PERIODS_MRC_V
   WHERE BOOK_TYPE_CODE  = P_BOOK_NAME
     AND PERIOD_NAME  = P_END_PERIOD;
fnd_file.put_line(fnd_file.log,'R-p_lex_end_period_counter::'||p_lex_end_period_counter);

  SELECT Accounting_flex_structure
    INTO lc_acct_flex_struc
    FROM FA_BOOK_CONTROLS_MRC_V
   WHERE book_type_code = P_BOOK_NAME;
fnd_file.put_line(fnd_file.log,'R-lc_acct_flex_struc::'||lc_acct_flex_struc);

ELSE
  SELECT PERIOD_COUNTER
    INTO p_lex_begin_period_counter
    FROM FA_DEPRN_PERIODS
   WHERE BOOK_TYPE_CODE  = P_BOOK_NAME
     AND PERIOD_NAME  = P_BEGIN_PERIOD;
  fnd_file.put_line(fnd_file.log,'p_lex_begin_period_counter::'||p_lex_begin_period_counter);

  SELECT PERIOD_COUNTER
    INTO p_lex_end_period_counter
    FROM FA_DEPRN_PERIODS
   WHERE BOOK_TYPE_CODE  = P_BOOK_NAME
     AND PERIOD_NAME  = P_END_PERIOD;
fnd_file.put_line(fnd_file.log,'p_lex_end_period_counter::'||p_lex_end_period_counter);

  SELECT Accounting_flex_structure
    INTO lc_acct_flex_struc
    FROM FA_BOOK_CONTROLS
   WHERE book_type_code = P_BOOK_NAME;
fnd_file.put_line(fnd_file.log,'lc_acct_flex_struc::'||lc_acct_flex_struc);

END IF;

IF upper(P_MRCSOBTYPE) = 'R'

THEN
fnd_file.put_line(fnd_file.log,'R-b4 lp statementss   ');
  LP_FA_BOOK_CONTROLS := 'FA_BOOK_CONTROLS_MRC_V';
  LP_FA_BOOKS         := 'FA_BOOKS_MRC_V';
  LP_FA_ADJUSTMENTS   := 'FA_ADJUSTMENTS_MRC_V';
  LP_FA_RETIREMENTS   := 'FA_RETIREMENTS_MRC_V';
  LP_FA_DEPRN_PERIODS := 'FA_DEPRN_PERIODS_MRC_V';
  LP_FA_ASSET_INVOICES := 'FA_ASSET_INVOICES_MRC_V';
ELSE
  lp_fa_book_controls := 'FA_BOOK_CONTROLS';
  lp_fa_books         := 'FA_BOOKS';
  lp_fa_adjustments   := 'FA_ADJUSTMENTS';
  lp_fa_retirements   := 'FA_RETIREMENTS';
  lp_fa_deprn_periods := 'FA_DEPRN_PERIODS';
  lp_fa_asset_invoices := 'FA_ASSET_INVOICES';

END IF;

RETURN(TRUE);
END beforeReport;

END FA_TOFES_YUD_ALEF_PKG;

/
