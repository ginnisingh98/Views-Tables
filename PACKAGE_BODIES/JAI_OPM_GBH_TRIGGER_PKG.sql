--------------------------------------------------------
--  DDL for Package Body JAI_OPM_GBH_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_OPM_GBH_TRIGGER_PKG" AS
/* $Header: jai_opm_gbh_t.plb 120.0.12010000.2 2009/12/09 06:44:00 nprashar ship $ */

/*
  REM +======================================================================+
  REM NAME          ARU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_OPM_GBH_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_OPM_GBH_ARU_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS

  Cursor C_Reg_Sel IS SELECT register_selected, po_id
    FROM JAI_OPM_OSP_HDRS
        WHERE osp_header_id = pr_new.batch_id ;

  Cursor C_Vend_Id(p_po_id number) IS SELECT a. Vendor_id,  a.ship_to_location_id,  b.location_code FROM po_headers_all a, hr_locations_all b
                                      WHERE po_header_id = p_po_id
                                      AND a.SHIP_TO_LOCATION_ID = b.LOCATION_ID; /*Added ship_to_location_id for bug # 9088563*/

  Cursor C_Osp_Rcpt_Dtl IS
    SELECT organization_id, INVENTORY_ITEM_ID,act_quantity,uom_code
    FROM JAI_OPM_OSP_DTLS
    WHERE osp_header_id = pr_new.batch_id
    and issue_recpt_flag = 'R';

  Cursor C_Tot_Excise IS SELECT SUM(excise_payable) tot_excise_payable
  FROM JAI_OPM_OSP_DTLS
             WHERE osp_header_id = pr_new.batch_id and
           issue_recpt_flag = 'I';

  Cursor C_Act_Out_Qty IS SELECT SUM(act_quantity) tot_qty
  FROM JAI_OPM_OSP_DTLS
             WHERE osp_header_id = pr_new.batch_id and
           issue_recpt_flag = 'R';

  Cursor C_Plan_Out_Qty IS SELECT plan_quantity plan_qty
  FROM JAI_OPM_OSP_DTLS
             WHERE osp_header_id = pr_new.batch_id and
           issue_recpt_flag = 'R';
  /*Commented by Brathod for Inv.Convergence, Cursor is not used anywhere in the code*/

  Cursor C_Osp_Ret_days(cpn_organization_id jai_cmn_inventory_orgs.organization_id%type) is
    SELECT MAX(NVL(OSP_RETURN_DAYS,0))
    from  JAI_CMN_INVENTORY_ORGS --JAI_OPM_ORGANIZATIONS
    WHERE organization_id = cpn_organization_id;

  l_updated_by NUMBER;
  l_reg_sel VARCHAR2(20);
  l_po_id number(10);
  l_vend_id number(10);
  l_plan_qty Number;
  l_act_tot_qty Number;
  l_tot_excise_payable Number;
  l_recv_qty Number;
  l_location_code Varchar2(4);
  return_days number;
  l_location_id po_headers_all.ship_to_location_id%TYPE; /* Bug#9088563 */

  /* Added by Ramananda for removal of SQL LITERALs */
  lv_register   JAI_OPM_OSP_HDRS.REGISTER_SELECTED%type ;
  lv_tran_name    JAI_OPM_TXN_EXTN_HDRS.transaction_name%type ;

  BEGIN
    pv_return_code := jai_constants.successful ;
    /*--------------------------------------------------------------------------------------------
Change History
--------------------------------------------------------------------------------------------
    1. Ssumaith - Bug # 2695779 - File Version 712.1
       Changed the cursor definition C_Vend_Id so that it picks up based on discrete tables .Currently
       it is using OPM tables . Since 11.5.7 , this change has been done.

    2. Ssumaith - Bug # 2808732
       Since OPM 11.5.8 (OPM I ) , the table is changed to GME_BATCH_HEADER instead of the
       table pm_btch_hdr .

    3. ssumaith - bug # 2959256
       Major dependency issues arise out of this bug.New columns have been added to the JAI_OPM_OSP_HDRS
       table.The columns added are fin_year, form_number.All further patches using this object will need
       to have this as a pre-requisite.

    4. ssumaith  - Bug # 3015825
       Aligning with the base apps changes in OPM I and OPM J , when the status of the batch changes to wip
       ie .. when the batch status = 2 , then transaction date , originla due date and ectended due dates
       should also be inserted.
       Presently , this was done at completion state , when the batch status = 3

08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old DB Entity Names,
              as required for CASE COMPLAINCE. Version 116.1

13-Jun-2005    File Version: 116.2
               Ramananda for bug#4428980. Removal of SQL LITERALs is done
08-Jul-2005    Brathod
               Issue: Inventory Convergence Uptake
               Solution:
               -  Code related to batch_status = 2 (Release) is commented because this functionality
                  is now handled by the form JAINGOSP.fmb and the code is included in the form.
               -  Code is modified to remove reference to OPM Tables which are obsoleted in R12 Datamodel
                  and replace with the related Discrete Objects

--------------------------------------------------------------------------------------------*/

IF pr_new.BATCH_STATUS = 3 AND pr_old.BATCH_STATUS=1 THEN
/*   Raise_application_error(-20010,'Cannot Certify the Batch Without Releasing it');
*/ pv_return_code := jai_constants.expected_error ; pv_return_message := 'Cannot Certify the Batch Without Releasing it' ; return ;
end if ;
IF pr_old.batch_status <> pr_new.batch_status THEN

  OPEN c_reg_sel;
  FETCH c_reg_sel INTO l_reg_sel,l_po_id;

  IF C_REG_SEL%NOTFOUND THEN
    CLOSE c_reg_sel;
    RETURN;
  END IF;
  CLOSE c_reg_sel;

  l_updated_by := pr_new.last_updated_by;

  IF pr_new.batch_status = 3 THEN

    IF l_reg_sel IS NOT NULL THEN

      OPEN C_Osp_ret_days(pr_new.organization_id );
      FETCH C_Osp_ret_days into return_days;
      CLOSE C_Osp_ret_days;

      OPEN C_Vend_Id(l_po_id);
      FETCH C_Vend_Id INTO l_vend_id, l_location_id, l_location_code; /*Added for bug # 9088563*/
      CLOSE C_Vend_Id;

      If l_vend_id is null then
/*         RAISE_APPLICATION_ERROR('-20009','Purchase Order Not Associated');
     */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'Purchase Order Not Associated' ; return ;
      end if ;
      lv_tran_name := 'OSP_ISSUE' ;
      INSERT INTO JAI_OPM_TXN_EXTN_HDRS
        ( TRANSACTION_NAME,
          TRANSACTION_HEADER_ID,
          VENDOR_CUSTOMER_ID,
          TRANSACTION_DATE,
          ORIGINAL_DUE_DATE,
          EXTENDED_DUE_DATE,
          USER_REFERENCE,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN)
      VALUES
        ( lv_tran_name, --'OSP_ISSUE',
          pr_new.batch_id,
          l_vend_id,
          sysdate,
          sysdate + return_days,
          sysdate + return_days,
          pr_new.batch_no,
          sysdate,
          l_updated_by,
          sysdate,
          l_updated_by,
          null
        );

      jai_cmn_rg_opm_pkg.create_rg23_entry
      ( 'I' ,
        --l_par_orgn,
         l_location_id ,--Location code replaced by location_id for bug # 9088563 l_location_code,  --pr_new.wip_whse_code,
        pr_new.batch_id,
        l_vend_id ,
        sysdate,
        l_reg_sel,
        --Fle.Sql.35 Cbabu
        0,
        jai_constants.yes,
        pr_new.organization_id
      );

      FOR rec IN C_Osp_Rcpt_Dtl LOOP
        IF NVL(rec.act_quantity ,0) > 0 THEN
          jai_cmn_rg_opm_pkg.create_rg_i_entry(
            --l_par_orgn,
            l_location_id, -- Location code replaced by location_id for bug # 9088563  l_location_code,  --pr_new.wip_whse_code,
            pr_new.batch_id,
            sysdate,
            --rec.inventory_item_id,
            rec.act_quantity,
            rec.uom_code,
            l_updated_by,
            rec.organization_id,
            rec.inventory_item_id
          );

        END IF;
      END LOOP;
    END IF;
  ELSIF pr_new.batch_status  = 4 THEN
    OPEN C_Plan_Out_Qty;
    FETCH C_Plan_Out_Qty INTO l_plan_qty;
    CLOSE C_Plan_Out_Qty;

    OPEN C_Act_Out_Qty;
    FETCH C_Act_Out_Qty INTO l_act_tot_qty;
    CLOSE C_Act_Out_Qty;

    OPEN C_Tot_Excise;
    FETCH C_Tot_Excise INTO l_tot_excise_payable;
    CLOSE C_Tot_Excise;

    l_recv_qty := ((nvl(l_act_tot_qty,0) / nvl(l_plan_qty,0))* nvl(l_tot_excise_payable,0));

    UPDATE JAI_OPM_OSP_HDRS
    SET  final_receipt = 'Y',
         receivable_excise = l_recv_qty
    WHERE osp_header_id = pr_new.batch_id;
  END IF;
END IF;
  END ARU_T1 ;

END JAI_OPM_GBH_TRIGGER_PKG ;

/
