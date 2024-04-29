--------------------------------------------------------
--  DDL for Package Body JAI_AR_GLDIST_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AR_GLDIST_TRIGGER_PKG" AS
/* $Header: jai_ar_gldist_t.plb 120.0 2005/11/10 13:35:16 brathod noship $ */
  /*
  REM +======================================================================+
  REM NAME          BRI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_AR_GLDIST_BRIUD_T1
  REM
  REM NOTES
  REM
  REM +======================================================================+
  */
PROCEDURE BRI_T1 ( pr_old t_rec%type ,
                   pr_new t_rec%type ,
                   pv_action varchar2 ,
                   pv_return_code out nocopy varchar2 ,
                   pv_return_message out nocopy varchar2
                   ) IS
/********************************************************************************************************************************
Created By  : brathod

Created Date: 11-Nov-2005

Bug         : 4727534

Purpose     : Stop the Ar Posting To GL (General Ledger Transfer Program) from posting if data for the invoice exists in JAI_AR_TRX_INS_LINES_T.
              indicating that user did not/forgot to run the India Local Concurrent Program.
              Here data is being posted from ra_cust_trx_line_gl_dist_all to gl_interface.

********************************************************************************************************************************/

/*
|| Should stop all invoices from posting because
|| data still lies in ja_in_temp_line_insert
|| This includes both Imported and Manual tramsactions
*/
CURSOR cur_get_temp_row
IS
SELECT
        1
FROM
        JAI_AR_TRX_INS_LINES_T
WHERE
        customer_trx_id  =  pr_new.customer_trx_id
AND     error_flag       <> 'D'; /* Modified by Ramananda for removal of SQL LITERALs */

ln_exists NUMBER;

BEGIN
  pv_return_code := jai_constants.successful ;
  OPEN  cur_get_temp_row;
  FETCH cur_get_temp_row INTO ln_exists;
  IF cur_get_temp_row%FOUND THEN
    /*
    ||Data found in JAI_AR_TRX_INS_LINES_T , India Local concurrent has not been run for this invoice.
    ||Stop the posting to gl_interface
    */
    CLOSE cur_get_temp_row;
  /*     raise_application_error (-20131,'IL Taxes found in JAI_AR_TRX_INS_LINES_T table. Please run the India Local Concurrent Program and then post the record into GL');*/
     pv_return_code := jai_constants.expected_error ;
     pv_return_message := 'IL Taxes found in JAI_AR_TRX_INS_LINES_T table. Please run the India Local Concurrent Program and then post the record into GL' ;
     return ;
  END IF ;
  CLOSE cur_get_temp_row;
   /* Added an exception block by Ramananda for bug#4570303 */
   EXCEPTION
     WHEN OTHERS THEN
       Pv_return_code     :=  jai_constants.unexpected_error;
       Pv_return_message  := 'Encountered an error in JAI_AR_GLDIST_TRIGGER_PKG.BRI_T1  '  || substr(sqlerrm,1,1900);
  END BRI_T1 ;

END JAI_AR_GLDIST_TRIGGER_PKG ;

/
