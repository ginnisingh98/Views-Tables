--------------------------------------------------------
--  DDL for Package Body JAI_PO_V_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PO_V_TRIGGER_PKG" AS
/* $Header: jai_po_v_t.plb 120.0 2005/09/01 12:37:13 rallamse noship $ */

/*
  REM +======================================================================+
  REM NAME          ARU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_PO_V_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_PO_V_ARU_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
	-- Added by GSri on 14-JUL-01
V_SET_OF_BOOKS_ID NUMBER ; --File.Sql.35 Cbabu  :=pr_new.SET_OF_BOOKS_ID;
v_currency_code VARCHAR2(15);

CURSOR Sob_Cur is
     select Currency_code
       from gl_sets_of_books
      where set_of_books_id = V_SET_OF_BOOKS_ID;
------ End of addition by Gsri on 14-jul-01
  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
 FILENAME: ja_in_dis_inact_vendor_trg.sql

 CHANGE HISTORY:
S.No      Date          Author and Details


1.    29-nov-2004  ssumaith - bug# 4037690  - File version 115.1
                   Check whether india localization is being used was done using a INR check in every trigger.
                   This check has now been moved into a new package and calls made to this package from this trigger
                   If the function jai_cmn_utils_pkg.check_jai_exists returns true it means INR is the set of books currency ,
                   Hence if this function returns FALSE , control should return.

2.    08-Jun-2005   This Object is Modified to refer to New DB Entry names in place of Old
                    DB as required for CASE COMPLAINCE. Version 116.1

3. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

4   26-Jul-2005   R12 Changes to replace po_vendors with po_ap_vendors table

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On

ja_in_dis_inact_vendor_trg.sql
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
115.1              4037690        IN60105D2          ja_in_util_pkg_s.sql  115.0     ssumaith 29-Nov-2004  Call to this function.
                                                     ja_in_util_pkg_s.sql  115.0     ssumaith

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- Added by GSri on 14-jul-01

V_SET_OF_BOOKS_ID := pr_new.SET_OF_BOOKS_ID;

  --If jai_cmn_utils_pkg.check_jai_exists(P_CALLING_OBJECT => 'JA_IN_DIS_INACT_VENDOR_TRG', P_SET_OF_BOOKS_ID => pr_new.set_of_books_id) = false then
  --    return;
  -- end if;

  IF pr_old.end_date_active IS NULL AND pr_new.end_date_active IS NOT NULL THEN
     UPDATE JAI_CMN_VENDOR_SITES
     SET    inactive_flag = 'Y'
     WHERE  vendor_id  = pr_new.vendor_id
     AND    vendor_site_id = 0 ;
  ELSIF pr_old.end_date_active IS NOT NULL AND pr_new.end_date_active IS NULL THEN
     UPDATE JAI_CMN_VENDOR_SITES
     SET    inactive_flag = ''
     WHERE  vendor_id  = pr_new.vendor_id
     AND    vendor_site_id = 0 ;
  END IF;
  END ARU_T1 ;

END JAI_PO_V_TRIGGER_PKG ;

/
