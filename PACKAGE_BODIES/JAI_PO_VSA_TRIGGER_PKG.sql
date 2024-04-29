--------------------------------------------------------
--  DDL for Package Body JAI_PO_VSA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PO_VSA_TRIGGER_PKG" AS
/* $Header: jai_po_vsa_t.plb 120.1 2006/05/26 11:49:44 lgopalsa noship $ */

/*
  REM +======================================================================+
  REM NAME          ARU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_PO_VSA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_PO_VSA_ARU_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
	-- added by Gsr 12-jul-01
 v_operating_id                     number; --File.Sql.35 Cbabu   :=pr_new.ORG_ID;
 v_gl_set_of_bks_id                 gl_sets_of_books.set_of_books_id%type;
 v_currency_code                     gl_sets_of_books.currency_code%type;

 /* Bug 5243532. Added by Lakshmi Gopalsami
  * Removed cursor Fetch_Book_Id_cur and implemented
  * caching logic.
  * Removed unused cursor sob_cur
  * Defined variable for implementing caching logic.
  */
  l_func_curr_det jai_plsql_cache_pkg.func_curr_details;
  -- End for bug 5243532
  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
 FILENAME: ja_in_dis_inactive_vend_trg.sql

 CHANGE HISTORY:
S.No  Date          Author and Details
1     29-Nov-2004    Sanjikum for 4035297. Version 115.1
                         Changed the 'INR' check. Added the call to jai_cmn_utils_pkg.check_jai_exists

2     08-Jun-2005   This Object is Modified to refer to New DB Entry names in place of Old
                        DB as required for CASE COMPLAINCE. Version 116.1

3     13-Jun-2005    File Version: 116.3
                       Ramananda for bug#4428980. Removal of SQL LITERALs is done

                      Dependency Due to this Bug:-
                       The current trigger becomes dependent on the function jai_cmn_utils_pkg.check_jai_exists version 115.0.

4     26-Jul-2005     R12 Changes to replace po_vendor_sites_all with po_vendor_sites

5.    03-Aug-2005  Aiyer for the bug 4532841,File Version 120.3
                   Issue:-
                    Compilation error for the trigger as the synonym po_vendor_sites_all does not exists.

                   Fix :-
                    As per the revised TCA structure the synonym po_vendor_sites_all has been renamed to po_ap_vendor_sites_all

                   Dependency Due to this Bug:-
                    None

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On

ja_in_dis_inactive_vend_trg.sql
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
115.1              4035297        IN60105D2+4033992  ja_in_util_pkg_s.sql  115.0     Sanjikum 29-Nov-2004  Call to this function.
                                                     ja_in_util_pkg_s.sql  115.0     Sanjikum

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

 v_operating_id  := pr_new.ORG_ID;

 /* Bug 5243532. Added by Lakshmi Gopalsami
  * Removed the cursor Fetch_Book_Id_Cur
  * and implemented using caching logic.
  */
 l_func_curr_det    := jai_plsql_cache_pkg.return_sob_curr
                          (p_org_id  => v_operating_id);
 v_gl_set_of_bks_id := l_func_curr_det.ledger_id;

  --IF jai_cmn_utils_pkg.check_jai_exists( p_calling_object => 'JA_IN_DIS_INACTIVE_VEND_TRG',
  --                                p_set_of_books_id => v_gl_set_of_bks_id ) = FALSE THEN
  --  RETURN;
  -- END IF;

  IF pr_old.inactive_date IS NULL AND pr_new.inactive_date IS NOT NULL THEN
     UPDATE JAI_CMN_VENDOR_SITES
     SET    inactive_flag = 'Y'
     WHERE  vendor_site_id  = pr_new.vendor_site_id;
   ELSIF pr_old.inactive_date IS NOT NULL AND pr_new.inactive_date IS NULL THEN
     UPDATE JAI_CMN_VENDOR_SITES
     SET    inactive_flag = ''
     WHERE  vendor_site_id  = pr_new.vendor_site_id;
   END IF;
  END ARU_T1 ;

END JAI_PO_VSA_TRIGGER_PKG ;

/
