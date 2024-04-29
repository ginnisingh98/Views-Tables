--------------------------------------------------------
--  DDL for Package Body JAI_JRG_23AC2_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_JRG_23AC2_TRIGGER_PKG" AS
/* $Header: jai_jrg_23ac2_t.plb 120.2.12010000.2 2008/12/19 06:53:58 srjayara ship $ */

/*
  REM +======================================================================+
  REM NAME          BRI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_JRG_23AC2_BRIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_JRG_23AC2_BRI_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE BRI_T1 ( pr_old t_rec%type , pr_new in out t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
	  /*
    This cursor is to fetch the Information regarding vendor change from JAI_RCV_CENVAT_CLAIMS.
  */

  CURSOR c_fetch_vendor_info(cp_transaction_type rcv_transactions.transaction_type%type)
  IS
  SELECT
         vendor_changed_flag    ,
         vendor_id              ,
         vendor_site_id
  FROM
         JAI_RCV_CENVAT_CLAIMS
  WHERE
         transaction_id  in
                            (
                                SELECT
                                                transaction_id
                                FROM
                                                rcv_transactions
                                WHERE
                                                transaction_type        = cp_transaction_type /* 'RECEIVE'  --Ramananda for removal of SQL LITERALs */
                                START WITH
                                                transaction_id          =  pr_new.receipt_ref
                                CONNECT BY PRIOR
                                                parent_transaction_id   = transaction_id
                            );

  --Variable definitions
  v_vendor_change       JAI_RCV_CENVAT_CLAIMS.vendor_changed_flag%type   ;  /*  To hold the Flag value whether vendor is changed or not. */
  v_vendor_id           JAI_RCV_CENVAT_CLAIMS.vendor_id%type             ;  /*  To hold the vendor id of ja_in_receipt_cenvat.           */
  v_vendor_site_id      JAI_RCV_CENVAT_CLAIMS.vendor_site_id%type        ;  /*  To hold the vendor site id of ja_in_receipt_cenvat.      */
  v_range_no            JAI_CMN_VENDOR_SITES.excise_duty_range%type    ;
  v_division_no         JAI_CMN_VENDOR_SITES.excise_duty_division%type ;
  --Added the below 4 variables by Sanjikum for Bug #3964409
  ln_slno               JAI_CMN_RG_23AC_II_TRXS.slno%TYPE;
  ln_opening_balance    JAI_CMN_RG_23AC_II_TRXS.opening_balance%TYPE;
  ln_closing_balance    JAI_CMN_RG_23AC_II_TRXS.closing_balance%TYPE;
  ln_txn_amt            JAI_CMN_RG_23AC_II_TRXS.cr_basic_ed%TYPE;
  BEGIN
    pv_return_code := jai_constants.successful ;
    /*********************************************************************************************************************************************************************

Created By      : Aiyer

Creation Date   : 21-Jul-2003

Enhancement Bug : 3025626

Purpose         : Modify the vendor_id, vendor_site_id, Range and Division information in JAI_CMN_RG_23AC_II_TRXS table from the
                  JAI_RCV_CENVAT_CLAIMS table when a third party supplier information has been registered through the
                  Claim Modvat On Receipt form.

Dependency     : - The following dependency has been created in this bug
                   1. Technical dependency due to datamodel change :-
                       3 new fields VENDOR_CHANGED_FLAG,VENDOR_ID and VENDOR_SITE_ID have
                       been added to the table JAI_RCV_CENVAT_CLAIMS and the view JAI_RCV_CLAIM_MODVAT_V
                       (base view of the form JAINMVAT.fmb) has been modified to add vendor_changed_flag
                       and vendor_site_id. Also the way the vendor_id is fetched in the view has also been changed.

                   2. Functional Dependency:-
                       The form JAINMVAT, with this enhancement, has the capability to capture the third party vendor
                       information.
                       For this 3 new fields vendor_changed_flag, dsp_vendor_site_code and vendor_site_id have been added to the form.
                       Another 2 new triggers ja_in_rg23_part_i_bi_trg and ja_in_pla_bi_trg.sql have been created as a part of this enhancement bug.

Change History :

1.    08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                    DB Entity as required for CASE COMPLAINCE.  Version 116.1


2.   13-Jun-2005    File Version: 116.2
                    Ramananda for bug#4428980. Removal of SQL LITERALs is done

3.   3-Mar-2007	    bduvarag for bug#5141459,File version 120.2
		    Forward porting the changes done in 11i bug#4548378

4.   19-Dec-2008    Bug 7637074 File version 120.0.12000000.3 / 120.2.12010000.2 / 120.3
                    Issue : Addl. CVD amount is not considered for the balances.
		    Fix   : Included addl. CVD amounts in the calculation of ln_txn_amt.
		            This is the same as bug 5377703 (forward port for bug 5362183).

/*----------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY: FILENAME: ja_in_rg23_part_ii_bi_trg.sql
S.No  Date        Author and Details
------------------------------------------------------------------------------------------------------------------------
1     27/10/2004  Sanjikum for Bug # 3964409, File version 115.1

                  Issue
                  -----
                  Duplicate Slno is generated in the JAI_CMN_RG_PLA_TRXS table

                  Fix
                  ---
                  1. Commented the Trigger condition - "WHEN ( new.transaction_id = 18 )"
                  2. In the Begin Block, added the call to ja_in_rg_util.update_rg_slno
                  3. Added an If condition, similar to the Trigger when condition and moved all existing
                     Code in it


Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files                                  Version     Author   Date         Remarks
Of File                              On Bug/Patchset    Dependent On
ja_in_rg23_part_ii_bi_trg.sql
----------------------------------------------------------------------------------------------------------------------------------------------------
616.1                  3025626       IN60104D1+3025626   1. ja_3025626_alter.sql            616.1     Aiyer   21/07/2003   Enhancement, Introduced data
                                                         2. JAI_RCV_CLAIM_MODVAT_V.sql        616.1                          model changes in table JAI_RCV_CENVAT_CLAIMS,
                                                         3. ja_in_pla_bi_trg.sql            616.1                          alterations in view JAI_RCV_CLAIM_MODVAT_V,
                                                         4. ja_in_rg23_part_i_bi_trg.sql    616.1                          added 3 new fields in form JAINMVAT.fmb and
                                                         5. JAINMVAT.fmb                    616.4                          2 new triggers - ja_in_pla_bi_trg.sql and
                                                         6. JAF23A_1.rdf                    616.1                          ja_in_rg23_part_i_bi_trg.sql. All present in patch 3025626.

115.1                  3964409                           1. jai_cmn_utils_pkg.sql           115.0    Sanjikum 27/10/2004
                                                         2. ja_in_create_3964409_apps.sql   115.0
                                                         3. ja_in_create_3964409_ja.sql     115.0
                                                         4. ja_in_datafix_po_3964409.sql    115.0
                                                         5. ja_in_pla_bi_trg.sql            115.0
**********************************************************************************************************************************************************************/

  --Start added by Sanjikum for Bug #3964409
  /*additional CVD fields included in formula for bug 7637074*/
  ln_txn_amt := NVL(pr_new.cr_basic_ed,0) + NVL(pr_new.cr_additional_ed,0) + NVL(pr_new.cr_other_ed,0) + NVL(pr_new.cr_additional_cvd,0)
                      - NVL(pr_new.dr_basic_ed,0) - NVL(pr_new.dr_additional_ed,0) - NVL(pr_new.dr_other_ed,0) - NVL(pr_new.dr_additional_cvd,0);

  IF pr_new.transaction_source_num IS NOT NULL THEN	/*Bug 5141459 bduvarag*/
  jai_cmn_utils_pkg.update_rg_slno(
      pn_organization_id  => pr_new.organization_id,
      pn_location_id    => pr_new.location_id,
      pv_register_type  => pr_new.register_type,
      pn_fin_year     => pr_new.fin_year,
      pn_txn_amt      => ln_txn_amt,
      pn_slno       => ln_slno,
      pn_opening_balance  => ln_opening_balance,
      pn_closing_balance  => ln_closing_balance
      );

  pr_new.slno := ln_slno;
  pr_new.opening_balance := ln_opening_balance;
  pr_new.closing_balance := ln_closing_balance;
  END IF;	/*Bug 5141459 bduvarag*/
  --End added by Sanjikum for Bug #3964409

  --Added the IF condition and commented the Trigger condition above by Sanjikum for Bug #3964409
  IF pr_new.transaction_source_num = 18 THEN
    OPEN  c_fetch_vendor_info('RECEIVE');
    FETCH c_fetch_vendor_info INTO v_vendor_change        ,
                                   v_vendor_id            ,
                                   v_vendor_site_id;

    IF   c_fetch_vendor_info%FOUND THEN
      IF nvl(v_vendor_change,'N') = 'N' THEN
        CLOSE c_fetch_vendor_info;
        return;             /* The Trigger should not do anything when vendor,vendor site is not changed. */

      ELSE                  /* Incase the count is present, then this table should have the changed vendor id and vendor site id.*/
        /* Assigning the changed vendor values. */
        pr_new.vendor_id        :=  v_vendor_id     ;
        pr_new.vendor_site_id   :=  v_vendor_site_id;

        /* To bring the Division and Range of the changed vendor/vendorsite id. */
        jai_rcv_utils_pkg.get_div_range
                                            (
                                               v_vendor_id       ,
                                               v_vendor_site_id  ,
                                               v_range_no        ,
                                               v_division_no
                                            );
        pr_new.range_no     := v_range_no;
        pr_new.division_no  := v_division_no;
      END IF;
    END IF;
    CLOSE c_fetch_vendor_info;
  END IF;
exception
  when others THEN
/*     raise_application_error(-20010,'Exception is raised in ja_in_rg23_part_ii_bi_trg' || sqlerrm);
*/ pv_return_code := jai_constants.expected_error ; pv_return_message := 'Exception is raised in ja_in_rg23_part_ii_bi_trg' || sqlerrm ; return ;
END BRI_T1 ;
END JAI_JRG_23AC2_TRIGGER_PKG ;

/
