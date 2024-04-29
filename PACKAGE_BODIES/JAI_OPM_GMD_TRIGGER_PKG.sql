--------------------------------------------------------
--  DDL for Package Body JAI_OPM_GMD_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_OPM_GMD_TRIGGER_PKG" AS
/* $Header: jai_opm_gmd_t.plb 120.1.12010000.3 2009/01/02 07:03:55 sguduru ship $ */

/*
  REM +======================================================================+
  REM NAME          ARU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_OPM_GMD_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_OPM_GMD_ARU_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS

  Cursor C_chk_hdr IS
  SELECT po_id
  FROM JAI_OPM_OSP_HDRS
  WHERE osp_header_id = pr_new.batch_id ;

  Cursor C_batch_no is
    SELECT batch_no, batch_status  --, wip_whse_code
         , ja_osp_batch
    from gme_batch_header
    WHERE batch_id =pr_new.batch_id;

  Cursor C_Rec_Exist IS SELECT rowid, unit_price FROM JAI_OPM_OSP_DTLS
        WHERE osp_header_id = pr_new.batch_id
        AND organization_id = pr_new.organization_id
        AND inventory_item_id = pr_new.inventory_item_id;

  cursor c_whse_orgn(l_whse_code varchar2) is
    select organization_id
    from mtl_secondary_inventories
    where secondary_inventory_name = l_whse_code;

  Cursor C_Excise_Rate(P_Form_Name varchar2) IS
    SELECT rate
    FROM JAI_OPM_OSP_EXC_RATES
    WHERE form_name = P_Form_Name;

  Cursor C_Form_name IS
    SELECT form_name FROM JAI_OPM_OSP_HDRS
    WHERE  osp_header_id = pr_new.batch_id;

  Cursor C_Inv_Ind(cp_organization_id number, cp_inventory_item_id number) IS
    select decode(inventory_item_flag, 'Y', 0, 1)  noninv_ind
    from mtl_system_items
    where organization_id = cp_organization_id
    and inventory_item_id = cp_inventory_item_id;
    --SELECT noninv_ind FROM ic_item_mst
    --WHERE item_id = p_item_id;

  CURSOR c_get_location_id (cpn_po_id number)
  IS
  SELECT ship_to_location_id location_id
  FROM   po_headers_all
  WHERE  po_header_id = cpn_po_id;



  l_rowid  VARCHAR2(40);
  l_updated_by NUMBER;
  l_osp_dtl_id  NUMBER(15);
  l_iss_rcpt_flag VARCHAR2(1);
  l_btch_stat NUMBER(1);
  l_rcpt_qty  NUMBER;
  l_orgn_code Varchar2(4);
  l_location_id  NUMBER;
  -- l_whse_code Varchar2(4);
  l_form_name Varchar2(16);
  l_unit_price NUMBER;
  l_excise_rate NUMBER;
  l_excise_payable NUMBER;
  l_noninv_ind Number(1);
  l_whse_orgn varchar2(4);
  l_batch_no varchar2(32);
  l_ja_osp_batch gme_batch_header.ja_osp_batch%type;

  v_file_name  varchar2(30);
  ln_po_id  number;

  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------------------------
  Change History :
------------------------------------------------------------------------------------------------------------
  1 26/04/2003  Sriram - bug # 2808732
        With OPM J , major changes have been made in the way base apps behaves with respect to the production batch cycle.
        The values of batch status which was 3 earlier is now 2 . Hence the code which was to get executed when the status was
        3 should now get executed when the status is 2 . This change has been done in the trigger and commented apropriately.

  2  08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old DB Entity Names,
                    as required for CASE COMPLAINCE. Version 116.1

  3. 13-Jun-2005    File Version: 116.2
                    Ramananda for bug#4428980. Removal of SQL LITERALs is done
  4  14/07/2005   4485801 Brathod, File Version 117.1
                  Issue: Inventory Convergence Uptake for R12 Initiative

  5. 04-Jan-2006  rallamse bug#4924272 File Version 120.1
                  Issue : IF C_chk_hdr%NOTFOUND check after the statement CLOSE C_chk_hdr;
                  Fix: Moved the CLOSE C_chk_hdr after the check mentioned above.

6 . 3-Dec-2008  Changes by nprashar for bug 7540543, During insert into table JAI_OPM_OSP_DETAILS,
                        for columns UOM_CODE,PLAN_QUANTITY dtl_num, wip_plan_quantity are now being used.
-------------------------------------------------------------------------------------------------------------  */

  OPEN C_chk_hdr;
  FETCH C_chk_hdr INTO ln_po_id;
  /* rallamse bug#4924272 Moved the if condition before the CLOSE C_chk_hdr */
  IF C_chk_hdr%NOTFOUND THEN
    CLOSE C_chk_hdr;
    RETURN;
  END IF;
  CLOSE C_chk_hdr;


  v_file_name := 'ompt117_osp.log';

  OPEN C_batch_no;
  FETCH C_batch_no INTO l_batch_no,l_btch_stat, l_ja_osp_batch;
  CLOSE C_batch_no;

  IF ( nvl(l_ja_osp_batch, -999) <> 1 ) THEN
    RETURN;
  END IF;

  OPEN C_whse_orgn(pr_new.subinventory);
  FETCH C_whse_orgn INTO l_orgn_code;
  CLOSE C_whse_orgn;

  IF  NVL(pr_old.actual_qty,0) < pr_new.actual_qty THEN
    OPEN C_Rec_Exist;
    FETCH C_Rec_Exist INTO l_rowid, l_unit_price;
    CLOSE C_Rec_Exist;

    l_updated_by := pr_new.last_updated_by;

    OPEN C_Inv_Ind(pr_new.organization_id, pr_new.inventory_item_id);
    FETCH C_Inv_Ind INTO l_noninv_ind;
    CLOSE C_Inv_Ind;

      IF l_btch_stat = 2  AND pr_new.line_type = -1   THEN
        IF l_rowid IS NOT NULL THEN

          IF NVL(l_unit_price,0) > 0 THEN

            OPEN C_Form_name;
            FETCH C_Form_name INTO l_form_name;
            CLOSE C_Form_name ;

            OPEN C_Excise_Rate(l_form_name) ;
            FETCH C_Excise_Rate INTO l_Excise_Rate ;
            CLOSE C_Excise_Rate ;

            IF l_excise_rate IS NULL THEN
              l_excise_rate := 10;
            END IF;

          END IF;
          l_excise_payable := ((NVL(l_unit_price,0)*pr_new.actual_qty*nvl(l_excise_rate,0))/100);

          UPDATE JAI_OPM_OSP_DTLS
          SET act_quantity = pr_new.actual_qty,
            excise_payable = l_excise_payable,
            last_updated_by = l_updated_by,
            last_update_date = sysdate
          WHERE rowid = l_rowid;
        END IF;
      ELSIF l_btch_stat IN (3,4) AND pr_new.line_type = -1 AND l_noninv_ind = 0 THEN
/*         RAISE_APPLICATION_ERROR('-20009','Actual Quantity can not be changed'); */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'Actual Quantity can not be changed' ; return ;
      ELSIF l_btch_stat = 2 AND pr_new.line_type = 1  THEN -- made the comparison against the l_btch_stat to 3 from 2 for OPM J completion - sriram - bug # 2808732
        l_rcpt_qty  := pr_new.actual_qty - pr_old.actual_qty;

        OPEN  c_get_location_id (ln_po_id);
        FETCH c_get_location_id INTO l_location_id;
        CLOSE c_get_location_id;

       INSERT INTO JAI_OPM_OSP_DTLS (OSP_DETAIL_ID,
            OSP_HEADER_ID,
            TRANS_DATE,
            UOM_CODE,
            PLAN_QUANTITY ,
            ACT_QUANTITY,
            UNIT_PRICE,
            MODVAT_CLAIMED,
            EXCISE_PAYABLE,
            ISSUE_RECPT_FLAG,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATED_BY ,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            PROCESSING_CHARGE,
            MAIN_RCPT_FLAG,
            inventory_item_id,
            organization_id)
    VALUES    (   JAI_OPM_OSP_DTLS_S1.NEXTVAL,
            pr_new.batch_id,
            sysdate,
            /* Commented by nprashar for bug 7540543
            pr_new.item_um,
            pr_new.plan_qty,
            */
            pr_new.dtl_um, /*Added by nprashar for  bug 7540543*/
            pr_new.wip_plan_qty, /*Added by nprashar for bug 7540543*/
            l_rcpt_qty  ,
            null,
            null,
            null,
            'R',
            SYSDATE,
            l_updated_by,
            l_updated_by,
            SYSDATE,
            null,
            null,
            'N',
            pr_new.inventory_item_id,
            pr_new.organization_id
       ) returning OSP_HEADER_ID into l_osp_dtl_id;

        jai_cmn_rg_opm_pkg.create_rg_i_entry(
          l_location_id,
          pr_new.batch_id,
          sysdate,
          l_rcpt_qty  ,
          pr_new.item_um,
          l_updated_by,
          pr_new.organization_id,
          pr_new.inventory_item_id
        );

      ELSIF l_btch_stat = 4 AND pr_new.line_type = 1  THEN
/*         RAISE_APPLICATION_ERROR('-20011','Actual Output Quantity can not be changed');
      */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'Actual Output Quantity can not be changed' ; return ;
      END IF;
    ELSIF pr_old.actual_qty > pr_new.actual_qty THEN
/*         RAISE_APPLICATION_ERROR('-20012','You can not reduce the Actual Quantity');
   */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'You can not reduce the Actual Quantity' ; return ;
    END IF ;
  END ARU_T1 ;

END JAI_OPM_GMD_TRIGGER_PKG ;

/
