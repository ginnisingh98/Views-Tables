--------------------------------------------------------
--  DDL for Package Body JAI_JOM_LM_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_JOM_LM_TRIGGER_PKG" AS
/* $Header: jai_jom_lm_t.plb 120.1 2007/06/13 06:23:49 bduvarag ship $ */

/*
  REM +======================================================================+
  REM NAME          ARI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_JOM_LM_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_JOM_LM_ARI_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
  CURSOR Lc_Check_Count IS
    SELECT COUNT(*)
    FROM JAI_OM_LC_HDRS
    WHERE lc_number = pr_new.lc_number;

  CURSOR c_lc_Balance IS
  SELECT LC_BALANCE_AMOUNT
  FROM JAI_OM_LC_HDRS
  WHERE LC_NUMBER = pr_new.LC_NUMBER;


  lv_amount_applied NUMBER; -- := pr_new.amount; --Ramananda for File.Sql.35
  lv_lc_count NUMBER;
  lv_picking_line_id NUMBER;
  v_lc_balance       Number; --Added by Sriram Bug # 2165355
/*--------------------------------------------------------------------------------------
Change History
1.  Sriram - Bug # 2165355 - Lc Forward Porting - 25/10/2002

2.  08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                  DB Entity as required for CASE COMPLAINCE.  Version 116.1

3. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done
4. 13/06/2007	bduvarag for the bug#6124130, File version 120.1
		changed the condtion > to >= while matching the lc_amount
----------------------------------------------------------------------------------------*/
  BEGIN
    pv_return_code := jai_constants.successful ;
     lv_amount_applied := pr_new.amount; --Ramananda for File.Sql.35

  OPEN lc_check_count;
  FETCH lc_check_count INTO lv_lc_count;
  CLOSE lc_check_count;

  OPEN   c_lc_Balance;
  Fetch  c_lc_Balance into v_lc_balance;
  Close  c_lc_Balance;

  IF lv_lc_count > 0
  THEN
/*Bug6124130 bduvarag, added the = condition */
   IF v_lc_balance - lv_amount_applied >= 0  Then
    UPDATE JAI_OM_LC_HDRS
    SET lc_balance_amount = ROUND(NVL(lc_balance_amount,0),2) - ROUND(NVL(lv_amount_applied,0),2)
    WHERE lc_number = pr_new.lc_number;
   ELSE
/*     RAISE_APPLICATION_ERROR(-20102,'There is not enough Balance available for this Matching');
   */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'There is not enough Balance available for this Matching' ; return ;
    END IF ;
   ELSE
/*     RAISE_APPLICATION_ERROR(-20101,'The Matched LC Does not Exist');
  */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'The Matched LC Does not Exist' ; return ;
    END IF ;
   /* Added an exception block by Ramananda for bug#4570303 */
 EXCEPTION
   WHEN OTHERS THEN
     Pv_return_code     :=  jai_constants.unexpected_error;
     Pv_return_message  := 'Encountered an error in JAI_JOM_LM_TRIGGER_PKG.ARI_T1 '  || substr(sqlerrm,1,1900);

  END ARI_T1 ;

END JAI_JOM_LM_TRIGGER_PKG ;

/
