--------------------------------------------------------
--  DDL for Package Body JAI_AP_DVA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_DVA_TRIGGER_PKG" AS
/* $Header: jai_ap_dva_t.plb 120.0 2005/09/01 12:34:27 rallamse noship $ */
 /*
  REM +======================================================================+
  REM NAME          ARI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_AP_DVA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AP_DVA_ARI_T1
  REM
  REM +======================================================================+
  */
 PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
    --  Trigger used for Supplier Merge. When this process is done then the taxes
  --  associated for the old supplier site needs to be copied on to the new site
  --  of the new supplier. TDS info. also has to be copied.
/* Ramananda for File.Sql.35, start */
  v_vendor_id          NUMBER; -- := pr_new.Vendor_Id;
  v_vendor_site_id     NUMBER; -- := pr_new.Vendor_Site_Id;
  v_dup_vendor_id      NUMBER; -- := pr_new.Duplicate_Vendor_Id;
  v_dup_vendor_site_id NUMBER; -- := pr_new.Duplicate_Vendor_Site_Id;
  v_keep_site_flag    VARCHAR2(1); --   := pr_new.Keep_Site_Flag;
  v_cre_dt            DATE;  --  := pr_new.Creation_Date;
  v_cre_by            NUMBER;--  := pr_new.Created_By;
  v_last_upd_dt       DATE; --   := pr_new.Last_Update_Date ;
  v_last_upd_by       NUMBER; -- := pr_new.Last_Updated_By;
  v_last_upd_login    NUMBER; -- := pr_new.Last_Update_Login;
/* --Ramananda for File.Sql.35, end */

  v_code              VARCHAR2(15);
  v_n_vendor_site_id  NUMBER;

  ------------------------------>

  CURSOR Fetch_Vendor_Site_Id_Cur( code IN VARCHAR2 ) IS
  SELECT MAX( Vendor_Site_Id )
  FROM   Po_Vendor_Sites_All
  WHERE  Vendor_Site_Code = code;

  CURSOR Fetch_Vendor_Code_Cur IS
  SELECT Vendor_Site_Code
  FROM   Po_Vendor_Sites_All
  WHERE  Vendor_Site_Id = v_dup_vendor_site_id;
--           AND   Vendor_Id = v_vendor_id;

  ------------------------------>

  CURSOR Fetch_Excise_Dtl_Cur( v_n_vendor_site_id IN NUMBER ) IS
  SELECT Excise_Duty_Region, Excise_Duty_Zone, Excise_Duty_Reg_No,
          Excise_Duty_Range, Excise_Duty_Division, Excise_Duty_Circle,
          Excise_Duty_Comm, St_Reg_No, Cst_Reg_No, Ec_Code,
          Tax_Category_List
  FROM   JAI_CMN_VENDOR_SITES
  WHERE  Vendor_Id = v_dup_vendor_id
  AND    Vendor_Site_Id = v_n_vendor_site_id;

  ------------------------------>

  Excise_Rec  Fetch_Excise_Dtl_Cur%ROWTYPE;

  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
 FILENAME:ja_in_supplier_merg_trg.sql

 CHANGE HISTORY:
S.No      Date          Author and Details
------------------------------------------------------------------------------------------
1         29-Nov-2004   Sanjikum for 4035297. Version 115.1
                        For 'INR' check, added the call to jai_cmn_utils_pkg.check_jai_exists

                  Dependency Due to this Bug:-
                  The current trigger becomes dependent on the function jai_cmn_utils_pkg.check_jai_exists version 115.0.

2. 13-Jun-2005    File Version: 116.3
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On

ja_in_supplier_merg_trg.sql

08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
              DB Entity as required for CASE COMPLAINCE.  Version 116.1
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
115.1              4035297        IN60105D2+4033992  ja_in_util_pkg_s.sql  115.0     Sanjikum 29-Nov-2004  Call to this function.
                                                     ja_in_util_pkg_s.sql  115.0     Sanjikum
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* --Ramananda for File.Sql.35, start */
  v_vendor_id          := pr_new.Vendor_Id;
  v_vendor_site_id     := pr_new.Vendor_Site_Id;
  v_dup_vendor_id      := pr_new.Duplicate_Vendor_Id;
  v_dup_vendor_site_id := pr_new.Duplicate_Vendor_Site_Id;
  v_keep_site_flag     := pr_new.Keep_Site_Flag;
  v_cre_dt             := pr_new.Creation_Date;
  v_cre_by             := pr_new.Created_By;
  v_last_upd_dt        := pr_new.Last_Update_Date ;
  v_last_upd_by        := pr_new.Last_Updated_By;
  v_last_upd_login     := pr_new.Last_Update_Login;
/* --Ramananda for File.Sql.35, end */

  --added the below by Sanjikum for Bug#4035297
  --IF jai_cmn_utils_pkg.check_jai_exists(p_calling_object => 'JA_IN_SUPPLIER_MERG_TRG',
  --                               p_org_id         => pr_new.org_id) = FALSE THEN
  --  RETURN;
  --END IF;

  UPDATE JAI_CMN_VENDOR_SITES
  SET    Inactive_Flag = 'Y',
   Last_Updated_By = v_last_upd_by,
   Last_Update_Date = v_last_upd_dt,
   Last_Update_Login = v_last_upd_login
  WHERE  Vendor_id = v_dup_vendor_id
  AND    Vendor_Site_Id = v_dup_vendor_site_id;

 /* copied the below update from ja_in_po_tds_ins_supp_merg as part of its obsoletion */
  UPDATE JAI_CMN_VENDOR_SITES --Ja_In_Po_Vendor_Sites
  SET    Inactive_Flag = 'Y',
   Last_Updated_By = v_last_upd_by,
   Last_Update_Date = v_last_upd_dt,
   Last_Update_Login = v_last_upd_login
  WHERE  Vendor_id = v_dup_vendor_id
  AND    Vendor_Site_Id = 0;

  IF v_keep_site_flag = 'Y' THEN
      OPEN  Fetch_Vendor_Code_Cur;
      FETCH Fetch_Vendor_Code_Cur INTO v_code;
      CLOSE Fetch_Vendor_Code_Cur;

      OPEN  Fetch_Vendor_Site_Id_Cur( v_code );
      FETCH Fetch_Vendor_Site_Id_Cur INTO v_n_vendor_site_id;
      CLOSE Fetch_Vendor_Site_Id_Cur;

      OPEN  Fetch_Excise_Dtl_Cur( v_n_vendor_site_id);
      FETCH Fetch_Excise_Dtl_Cur INTO Excise_Rec;
      CLOSE Fetch_Excise_Dtl_Cur;

      INSERT INTO JAI_CMN_VENDOR_SITES( VENDOR_ID,
           VENDOR_SITE_ID,
           EXCISE_DUTY_REGION,
           EXCISE_DUTY_ZONE,
           EXCISE_DUTY_REG_NO,
           EXCISE_DUTY_RANGE,
           EXCISE_DUTY_DIVISION,
           EXCISE_DUTY_CIRCLE,
           EXCISE_DUTY_COMM,
           ST_REG_NO,
           CST_REG_NO,
           EC_CODE,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           TAX_CATEGORY_LIST,
           INACTIVE_FLAG )
      VALUES
            ( v_vendor_id,
              v_n_vendor_site_id,
              Excise_Rec.Excise_Duty_Region,
              Excise_Rec.Excise_Duty_Zone,
              Excise_Rec.Excise_Duty_Reg_No,
              Excise_Rec.Excise_Duty_Range,
              Excise_Rec.Excise_Duty_Division,
              Excise_Rec.Excise_Duty_Circle,
              Excise_Rec.Excise_Duty_Comm,
              Excise_Rec.St_Reg_No,
              Excise_Rec.Cst_Reg_No,
              Excise_Rec.Ec_Code,
              v_cre_dt,
              v_cre_by,
              v_last_upd_dt,
              v_last_upd_by,
              v_last_upd_login,
              Excise_Rec.Tax_Category_List,
              NULL
    );
  END IF;

/*
|| Commented by Ramananda as a part of removal of SQL LITERALs
    jai_cmn_vendor_pkg.supplier_merge(
            v_vendor_id,
            v_vendor_site_id,
            v_dup_vendor_id,
            v_dup_vendor_site_id,
            v_cre_dt,
            v_cre_by,
            v_last_upd_dt,
            v_last_upd_by,
            v_last_upd_login );
*/
 /* Added an exception block by Ramananda for bug#4570303 */
 EXCEPTION
   WHEN OTHERS THEN
     Pv_return_code     :=  jai_constants.unexpected_error;
     Pv_return_message  := 'Encountered an error in JAI_AP_DVA_TRIGGER_PKG.ARI_T1 '  || substr(sqlerrm,1,1900);
  END ARI_T1 ;

END JAI_AP_DVA_TRIGGER_PKG ;

/
