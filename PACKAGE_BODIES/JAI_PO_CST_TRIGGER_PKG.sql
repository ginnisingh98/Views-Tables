--------------------------------------------------------
--  DDL for Package Body JAI_PO_CST_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PO_CST_TRIGGER_PKG" AS
/* $Header: jai_po_cstg_t.plb 120.0.12010000.2 2008/11/21 07:16:42 srjayara ship $ */

/*
  REM +======================================================================+
  REM NAME          BRI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_PO_CSGT_BRIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_PO_CSGT_BRI_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE BRI_T1 ( pr_old t_rec%type , pr_new in out t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS

  ln_transaction_id       RCV_TRANSACTIONS.TRANSACTION_ID%TYPE;
  ln_accrual_amount       JAI_RCV_REP_ACCRUAL_T.ACCRUAL_AMOUNT%TYPE;
  ln_set_of_books_id      GL_SETS_OF_BOOKS.SET_OF_BOOKS_ID%TYPE;
  lv_currency_code        GL_SETS_OF_BOOKS.CURRENCY_CODE%TYPE;

  CURSOR cur_get_setOfBooksId
    (cpn_operating_unit_id   HR_OPERATING_UNITS.ORGANIZATION_ID%TYPE,
     cpv_information_context HR_ORGANIZATION_INFORMATION.ORG_INFORMATION_CONTEXT%TYPE
    )
  IS
  SELECT to_number(o3.org_information3) set_of_books_id
  FROM   hr_organization_information o3
  WHERE  organization_id = cpn_operating_unit_id
  AND    o3.org_information_context = cpv_information_context;

  CURSOR cur_get_accrual_amount
         (cpn_transaction_id JAI_RCV_REP_ACCRUAL_T.TRANSACTION_ID%TYPE)
  IS
  SELECT accrual_amount
  FROM   jai_rcv_rep_accrual_t
  WHERE  transaction_id = cpn_transaction_id;

  ln_transaction_qty    RCV_TRANSACTIONS.QUANTITY%TYPE;

  CURSOR cur_get_transaction_qty (cpn_transaction_id RCV_TRANSACTIONS.TRANSACTION_ID%TYPE)
  IS
  SELECT quantity
  FROM   rcv_transactions
  WHERE  transaction_id = cpn_transaction_id;

  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
 FILENAME: jai_po_csg_bri_t.sql
 CHANGE HISTORY:

  S.No      Date          Author and Details
  1       21-NOV-2008    Bug 7565737 - India Localization Taxes are getting doubled for invoices.
                         Reason - Receipt matched invoices are also populated with rcv_transaction_id.
			 Fix - Added a check to process only the rows with invoice_distribution_id as
			       NULL.

  Future Dependencies For the release Of this Object:-
  (Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
  A datamodel change )
  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
  Of File                           On Bug/Patchset    Dependent On


------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  OPEN  cur_get_setOfBooksId (cpn_operating_unit_id => pr_new.operating_unit_id,
                              cpv_information_context => 'Operating Unit Information'
                              );
  FETCH cur_get_setOfBooksId INTO ln_set_of_books_id;
  CLOSE cur_get_setOfBooksId;

  --IF jai_cmn_utils_pkg.check_jai_exists
  --     ( p_calling_object  => 'JAI_PO_CSGT_BRI_T1',
  --       p_set_of_books_id => ln_set_of_books_id) = FALSE THEN
  --  RETURN;
  -- END IF;

  ln_transaction_id := pr_new.rcv_transaction_id;

 /* IF condition added for bug 7567537 - amount should be updated only for
  * transactions from PO source*/
 IF pr_new.invoice_distribution_id IS NULL AND pr_new.write_off_id IS NULL
 THEN
  OPEN  cur_get_accrual_amount (cpn_transaction_id => ln_transaction_id);
  FETCH cur_get_accrual_amount INTO ln_accrual_amount;
  CLOSE cur_get_accrual_amount;

  OPEN  cur_get_transaction_qty (cpn_transaction_id => ln_transaction_id);
  FETCH cur_get_transaction_qty into ln_transaction_qty;
  CLOSE cur_get_transaction_qty;

  IF NVL( ln_transaction_qty, 0) = 0 THEN
    RETURN;
  END IF;

  IF ln_transaction_qty <> ABS(pr_new.quantity) THEN
    ln_accrual_amount :=   ln_accrual_amount
                         * (ABS(pr_new.quantity) / ln_transaction_qty);
  END IF;

  IF NVL(pr_new.quantity,0) < 0 then
     ln_accrual_amount := - ln_accrual_amount;
  END IF;

  IF NVL(ln_accrual_amount, 0) <> 0 THEN
    IF NVL(pr_new.amount, 0) <> 0 THEN
      pr_new.amount := pr_new.amount + ln_accrual_amount;
    END IF;

    IF  NVL(pr_new.entered_amount, 0) <> 0
    AND NVL(pr_new.currency_code,'X') <> jai_constants.func_curr THEN
      pr_new.entered_amount :=  pr_new.entered_amount
                            + (ln_accrual_amount * pr_new.currency_conversion_rate);
    END IF;
  END IF;
 END IF;
  END BRI_T1 ;

END JAI_PO_CST_TRIGGER_PKG ;

/
