--------------------------------------------------------
--  DDL for Package Body JAI_AR_HCA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AR_HCA_TRIGGER_PKG" AS
/* $Header: jai_ar_rc_t.plb 120.0 2005/09/01 12:34:59 rallamse noship $ */
/*
  REM +======================================================================+
  REM NAME          ARD_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_AR_RC_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AR_RC_ARD_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE ARD_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
    v_count Number;
  v_customer_id  Number; -- := pr_old.customer_id; --Ramananda for File.Sql.35

  Cursor Cust_count IS
  Select count(*)
  From   JAI_CMN_CUS_ADDRESSES
  Where  Customer_Id = v_customer_id;

  BEGIN
    pv_return_code := jai_constants.successful ;
/*    FILENAME: JA_IN_CUSTOMER_DELETE_TRG.sql

 CHANGE HISTORY:
S.No      Date     Author and Details
1.  2001/07/12    Anuradha Parthasarathy
                  Code added to ensure that this trigger doesnt fire for Non Indian OU.

2. 26-05-2005     rallamse bug#4384239
                  The trigger is previously based on AR.RA_CUSTOMERS
                  which does not have a synonym in APPS and GSCC does not allow hardcoded
                  schema name AR as per File.Sql.6
                  As per discussion with CBABU, changed the trigger to table HZ_CUST_ACCOUNTS
                  and used pr_old.cust_account_id instead of pr_old.customer_id

3. 08-Jun-2005    File Version 116.2. This Object is Modified to refer to New DB Entity names in place of Old
                  DB Entity as required for CASE COMPLAINCE.

4. 13-Jun-2005    Ramananda for bug#4428980. File Version: 116.2
                  Removal of SQL LITERALs is done

--------------------------------------------------------------------------------------------*/
  v_customer_id  := pr_old.cust_account_id; --Ramananda for File.Sql.35

  Open  Cust_Count;
  Fetch Cust_Count into v_count;
  Close Cust_Count;

  If NVL(v_count,0) = 0 then
    Return;
  Else
    Delete JAI_CMN_CUS_ADDRESSES
      Where  Customer_ID = v_customer_id;
  End if;
   /* Added an exception block by Ramananda for bug#4570303 */
   EXCEPTION
     WHEN OTHERS THEN
       Pv_return_code     :=  jai_constants.unexpected_error;
       Pv_return_message  := 'Encountered an error in JAI_AR_HCA_TRIGGER_PKG.ARD_T1  '  || substr(sqlerrm,1,1900);

  END ARD_T1 ;

END JAI_AR_HCA_TRIGGER_PKG ;

/
