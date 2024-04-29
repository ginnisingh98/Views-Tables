--------------------------------------------------------
--  DDL for Package Body JAI_RCV_RSL_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RCV_RSL_TRIGGER_PKG" AS
/* $Header: jai_rcv_rsl_t.plb 120.1 2007/06/22 08:29:07 bgowrava ship $ */

/*
  REM +======================================================================+
  REM NAME          ARU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_RCV_RSL_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_RCV_RSL_ARU_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
	  --*********TRANSACTION_TYPE******************
  CURSOR c_get_tran_type IS
    Select transaction_type, nvl(quantity, 0) quantity
      , routing_header_id     -- Vijay Shankar for Bug#3637910
    from RCV_TRANSACTIONS
    where transaction_id = (
      Select max(Transaction_id)
      FROM RCV_TRANSACTIONS
      where shipment_header_id = pr_new.shipment_header_id
      AND SHIPMENT_LINE_ID = pr_new.shipment_line_id
    );

      --Added by Bgowrava for Bug#6144268
		CURSOR c_ops_check IS
		    SELECT plt.OUTSIDE_OPERATION_FLAG
		    FROM     po_line_types_b plt,
		             po_lines_all pla
		    where    plt.line_type_id = pla.line_type_id
    AND     pla.po_line_id = pr_new.po_line_id;
    v_ops_flag       PO_LINE_TYPES_B.OUTSIDE_OPERATION_FLAG%TYPE;

    -- Commented the following cursor by Bgowrava for Bug#6144268
 /* CURSOR c_item_type( p_organization_id IN NUMBER, p_inv_item_id IN NUMBER) IS
    SELECT item_type FROM mtl_system_items
    WHERE organization_id = p_organization_id
    AND inventory_item_id = p_inv_item_id;*/

  v_item_type       MTL_SYSTEM_ITEMS.item_type%TYPE;
  v_tran_type       RCV_TRANSACTIONS.transaction_type%TYPE;
  v_rcv_tran_qty      RCV_TRANSACTIONS.quantity%TYPE;

  -- Vijay Shankar for Bug#3637910
  v_routing_header_id   RCV_TRANSACTIONS.routing_header_id%TYPE;

  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
CHANGE HISTORY:     FILENAME: ja_in_update_57F4.sql

  - This trigger is Only to Handle OSP Transactions for matching with Localization 57F4 forms

S.No      Date     Author and Details
------------------------------------------------------------------------------------------
 1   01-JUN-2001  Satya Added DUAL UOM functionality

 2   29-OCT-2002    Nagaraj.s for Bug2643016
                     As Functionally required, an Update statement is written to update the CR_REG_ENTRY_DATE of
                     the ja_in_57f4_table. This will definitely have implications on Approve 57f4 receipt screen on
                     Modvat claim but since no Modvat claim is available for 57f4 register, this has been approved
                     functionally.
 3   22-JAN-2003    Vijay Shankar for Bug#2746952, FileVersion# 615.2
                     During the RETURN TO VENDOR transaction for the shipment line, the code is getting executed and
                     return quantity is getting updated. This is happening when a partial receipt is made and then RTV
                     is made for the same

04   25-MAY-2004    Vijay Shankar for Bug#3637910, FileVersion# 619.1
                     modified the if condition, so that 57F4 forms are updated with returned quantity even if direct delivery
                     case, which is not happening previouly

05.  29-NOV-2005    Aparajita for bug#4036241. Version#115.1

                    Introduced the call to centralized packaged procedure,
                    jai_cmn_utils_pkg.check_jai_exists to check if localization has been installed.

06   08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old DB Entity Names,
                   as required for CASE COMPLAINCE. Version 116.1

07. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

Dependency:
----------

Sl No. Bug        Dependent on
                  Bug/Patch set    Details
-------------------------------------------------------------------------------------------------
1      4036241    4033992          Call to  jai_cmn_utils_pkg.check_jai_exists, whcih was created thru bug
                                   4033992.
                                   ja_in_util_pkg_s.sql 115.0
                                   ja_in_util_pkg_b.sql 115.0

--------------------------------------------------------------------------------------------------*/

  --if
  --  jai_cmn_utils_pkg.check_jai_exists (p_calling_object => 'JA_IN_UPDATE_57F4', p_inventory_orgn_id =>  pr_new.to_organization_id)
  --  =
  --  FALSE
  --then
    /* India Localization funtionality is not required */
  --  return;
  --end if;


  OPEN c_get_tran_type;
  FETCH c_get_tran_type INTO v_tran_type, v_rcv_tran_qty, v_routing_header_id;
  CLOSE c_get_tran_type;

-- Commented the following cursor by Bgowrava for Bug#6144268
  /*OPEN c_item_type(pr_new.to_organization_id, pr_new.item_id);
  FETCH c_item_type INTO v_item_type;
  CLOSE c_item_type;*/

  -- Added by bgowrava for Bug#6144268
	  OPEN c_ops_check;
	  FETCH c_ops_check INTO v_ops_flag;
     CLOSE c_ops_check;

  -- This Check means if ITEM_TYPE is OSP and Latest RCV_TRANSCATION is related to RECEIVE or CORRECT
  -- IF nvl(v_item_type, 'OP') = 'OP' AND v_tran_type IN ('RECEIVE', 'CORRECT') THEN
  -- if condition modified by Vijay Shankar for Bug#3637910
  --IF nvl(v_item_type, 'OP') = 'OP'
  IF nvl(v_ops_flag, 'N') = 'Y'    -- Added by bgowrava
    AND ( ( v_routing_header_id <> 3 AND v_tran_type IN ('RECEIVE', 'CORRECT'))     -- Standard and Inspection routing
      OR ( v_routing_header_id = 3 AND v_tran_type IN ('DELIVER', 'CORRECT'))     -- Direct Delivery routing
    )
  THEN
    jai_po_osp_pkg.update_57f4_on_receiving (
        pr_new.shipment_header_id,
        pr_new.shipment_line_id,
        pr_new.to_organization_id,
        pr_new.ship_to_location_id,
        pr_new.item_id,
        v_tran_type,
        v_rcv_tran_qty,
        pr_new.primary_unit_of_measure,
        pr_old.primary_unit_of_measure,
        pr_new.unit_of_measure,
        pr_new.po_header_id,
        pr_new.po_release_id,
        pr_new.po_line_id,
        pr_new.po_line_location_id,
        pr_new.last_updated_by,
        pr_new.last_update_login,
        pr_new.creation_date
    );

  END IF;
  END ARU_T1 ;

END JAI_RCV_RSL_TRIGGER_PKG ;

/
