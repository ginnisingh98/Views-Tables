--------------------------------------------------------
--  DDL for Package Body GMD_QMSMC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QMSMC" AS
  /* $Header: GMDQMSMB.pls 120.22.12010000.7 2009/11/05 07:44:00 kannavar ship $ */

  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');

  PROCEDURE VERIFY_EVENT(
                         /* procedure to verify event if the event is sample disposition or sample event disposition */p_itemtype  IN VARCHAR2,
                         p_itemkey   IN VARCHAR2,
                         p_actid     IN NUMBER,
                         p_funcmode  IN VARCHAR2,
                         p_resultout OUT NOCOPY VARCHAR2) IS

    l_event_name varchar2(240) := WF_ENGINE.GETITEMATTRTEXT(itemtype => p_itemtype,
                                                            itemkey  => P_itemkey,
                                                            aname    => 'EVENT_NAME');
    l_event_key  varchar2(240) := WF_ENGINE.GETITEMATTRTEXT(itemtype => p_itemtype,
                                                            itemkey  => P_itemkey,
                                                            aname    => 'EVENT_KEY');

    l_current_approver varchar2(240);

    l_application_id        number;
    l_transaction_type      varchar2(100);
    l_user                  varchar2(32);
    Approver                AME_UTIL.APPROVERRECORD;
    l_inventory_item_id     number;
    l_item_number           varchar2(240);
    l_item_desc             varchar2(240);
    l_lot_number            varchar2(240);
    l_parent_lot_number     varchar2(240);
    l_sample_plan           varchar2(4000) := '';
    l_sample_plan_out       varchar2(4000);
    l_sample_plan_id        number;
    l_sample_count          varchar2(240);
    l_sample_qty            varchar2(240);
    l_sample_qty_uom        varchar2(240);
    l_frequency_count       varchar2(240);
    l_frequency_per         varchar2(240);
    l_frequency_type        varchar2(240);
    l_sampling_event_id     number;
    l_batch_no              varchar2(100);
    l_formula_no            varchar2(240);
    l_recipe_no             varchar2(240);
    l_organization_code     varchar2(240) := NULL;
    l_subinventory          varchar2(240) := NULL;
    l_doc_type              varchar2(240);
    l_transaction_type_id   number(10);
    l_transaction_type_name varchar2(240);
    l_trans_qty             number;
    l_trans_qty_uom         varchar2(32);
    l_trans_qty2            number;
    l_trans_qty_uom2        varchar2(32);
    l_receipt_no            varchar2(240);
    l_purchase_no           varchar2(240);
    l_vendor_no             varchar2(240);
    l_supplier_id           varchar2(240);
    l_vendor_lot_num        VARCHAR2(32); --Bug#6145310
    --RLNAGARA B4905645 start
    l_retest_Date_tmp  date;
    l_expiry_date_tmp  date;
    l_retest_Date      varchar2(30);
    l_expiry_date      varchar2(30);
    l_date_format_mask varchar2(30);
    --RLNAGARA B4905645 end
    l_batch_step_no     varchar2(240);
    l_form              varchar2(240);
    l_log               varchar2(2000);
    l_valid_transaction boolean := false;
    l_vendor_spec_found boolean := false;
    l_inv_spec          GMD_SPEC_MATCH_GRP.INVENTORY_SPEC_REC_TYPE;
    l_cust_spec         GMD_SPEC_MATCH_GRP.CUSTOMER_SPEC_REC_TYPE;
    l_supp_spec         GMD_SPEC_MATCH_GRP.SUPPLIER_SPEC_REC_TYPE;

    L_SPEC_ID       NUMBER;
    L_SPEC_VR_ID    NUMBER;
    L_SPEC_TYPE     VARCHAR2(100);
    L_RETURN_STATUS VARCHAR2(100);
    L_Msg_DATA      VARCHAR2(2000);

    l_sampling_events     GMD_SAMPLING_EVENTS%ROWTYPE;
    l_sampling_events_out GMD_SAMPLING_EVENTS%ROWTYPE;
    l_event_spec_disp     GMD_EVENT_SPEC_DISP%ROWTYPE;
    l_event_spec_disp_out GMD_EVENT_SPEC_DISP%ROWTYPE;
    quality_config        GMD_QUALITY_CONFIG%ROWTYPE;

    l_shipment_header_id number;
    l_po_header_id       number;
    l_po_line_id         number;
    l_vendor_id          number;
    l_org_id             number;
    l_vendor_site_id     number;
    l_organization_id    number;
    l_operating_unit     VARCHAR2(240); --RLNAGARA B5018797 Changed from Number to VARCHAR2
    l_retest_indicator   varchar2(1) := NULL;
    l_locator            varchar2(240) := NULL;
    l_locator_id         NUMBER;

    l_receipt_id      number;
    l_receipt_line_id number;
    l_qty_conv        number;

    l_reserve_cnt_req    varchar2(240) := '';
    l_reserve_qty        varchar2(240) := '';
    l_archive_cnt_req    varchar2(240) := '';
    l_archive_qty        varchar2(240) := '';
    l_doc_number         number;
    l_auto_sample        varchar2(1) := 'N';
    l_sample_plan_exists number := 0;
    create_status        varchar2(240);

    -- added for bug 4165704
    l_revision   VARCHAR2(3);
    l_orgn_found BOOLEAN;

    sample_name_temp varchar2(100) := '';
    sample_name      varchar2(100) := '';
    rsample_name     varchar2(500) := '';
    asample_name     varchar2(500) := '';
    fsample_name     varchar2(500) := '';
    frsample_name    varchar2(500) := '';
    fasample_name    varchar2(500) := '';
    lsample_name     varchar2(500) := '';
    lrsample_name    varchar2(500) := '';
    lasample_name    varchar2(500) := '';
    r                NUMBER; --RLNAGARA Bug 5910300
    l_from_role      varchar2(2000);

    no_vendor_found EXCEPTION; /* Bug # 4576699 */
    no_application_id_found EXCEPTION; /* Bug # 4576699 */
    no_user_name_found EXCEPTION; /* Bug # 4576699 */

    --RLNAGARA Bug5334308
    l_trans_id   NUMBER;
    l_gen_obj_id NUMBER;
    l_lot_qty    NUMBER;
    l_lot_qty2   NUMBER;

    --RLNAGARA B5499961 Added Organization_Code to the select clause.
    CURSOR inv IS
      SELECT B.INVENTORY_ITEM_ID,
             M.revision,
             B.concatenated_segments,
             B.DESCRIPTION,
             M.TRANSACTION_TYPE_ID,
             T.TRANSACTION_TYPE_NAME,
             M.TRANSACTION_QUANTITY,
             M.SECONDARY_TRANSACTION_QUANTITY,
             M.TRANSACTION_UOM,
             M.SECONDARY_UOM_CODE,
             M.ORGANIZATION_ID,
             mp.organization_code,
             M.SUBINVENTORY_code,
             M.LOCATOR_ID
        FROM MTL_SYSTEM_ITEMS_B_KFV    B,
             MTL_MATERIAL_TRANSACTIONS M,
             MTL_TRANSACTION_TYPES     T,
             mtl_parameters            mp
       WHERE M.transaction_id = l_event_key
         AND M.organization_id = B.organization_id
         AND mp.organization_id = B.organization_id
         AND M.inventory_item_id = B.inventory_item_id
         AND M.transaction_type_id = T.transaction_type_id;

    -- Bug 4440045: added the inv_lot cursor
    CURSOR inv_lot IS
      SELECT c.PARENT_LOT_NUMBER, c.LOT_NUMBER
        FROM MTL_LOT_NUMBERS             C,
             MTL_MATERIAL_TRANSACTIONS   M,
             MTL_TRANSACTION_LOT_NUMBERS L
       WHERE M.transaction_id = l_event_key
         AND M.inventory_item_id = C.inventory_item_id
         AND M.organization_id = C.organization_id
         AND C.LOT_NUMBER = L.LOT_NUMBER
         AND M.transaction_id = L.transaction_id;
    -- Bug #3473230 (JKB) Added doc_id above.

    -- Bug 4165704: added cursor below to get locator
    CURSOR Cur_locator(loc_id NUMBER) IS
      SELECT concatenated_segments
        FROM mtl_item_locations_kfv
       WHERE inventory_location_id = loc_id;

    CURSOR lot is
      SELECT B.inventory_item_id,
             mp.organization_code, --RLNAGARA B4905645
             B.organization_id,
             B.concatenated_segments ITEM_Number,
             B.description,
             A.parent_LOT_Number,
             A.LOT_Number,
             B.primary_uom_code,
             B.primary_uom_code,
             A.expiration_date,
             A.Retest_Date
        FROM mtl_lot_numbers A, mtl_system_items_b_kfv B, mtl_parameters mp --RLNAGARA B4905645
       WHERE A.inventory_item_id = B.inventory_item_id
         AND A.organization_id = B.organization_id
         AND mp.organization_id = A.organization_id
         AND --RLNAGARA B4905645
             A.organization_id || '-' || A.inventory_item_id || '-' ||
             A.LOT_number = l_event_key;

    CURSOR recv IS
      SELECT so.organization_code,
             im.organization_id,
             rt.subinventory,
             im.inventory_Item_id,
             sl.item_revision,
             im.concatenated_segments item_number,
             im.description,
             rt.Quantity,
             rt.secondary_quantity,
             rt.unit_of_measure,
             rt.secondary_unit_of_measure,
             rt.shipment_header_id,
             rt.po_header_id,
             rt.po_line_id,
             rt.vendor_id,
             rt.vendor_site_id,
             sl.shipment_line_id,
             po.segment1 purchase_no,
             sh.receipt_num,
             rt.locator_id,
             po.org_id, --RLNAGARA B5018797
             hou.name, --RLNAGARA B5018797
             rt.vendor_lot_num --Bug#6145310
        FROM rcv_transactions     rt,
             mtl_system_items_kfv im,
             mtl_parameters       so,
             rcv_shipment_lines   sl,
             po_headers_all       po,
             rcv_shipment_headers sh,
             hr_operating_units   hou --RLNAGARA B5018797
       WHERE rt.TRANSACTION_ID = l_event_key
         AND rt.shipment_header_id = sl.shipment_header_id
         AND rt.shipment_line_id = sl.shipment_line_id
         AND sl.item_id = im.inventory_item_id
         AND sl.to_organization_id = im.organization_id
         AND so.organization_id = im.organization_id
         AND rt.organization_id = im.ORGANIZATION_ID
         AND po.po_header_id = rt.po_header_id
         AND sh.shipment_header_id = rt.shipment_header_id
         AND po.org_id = hou.organization_id; --RLNAGARA B5018797

    /* if subinventory from above is not null */
    CURSOR recv_subinventory IS
      SELECT description
        FROM mtl_secondary_inventories
       WHERE organization_id = l_organization_id
         AND secondary_inventory_name = l_subinventory;

    --RLNAGARA Bug5334308 Added cursor get_lot and modified cursor recv_inv
    CURSOR get_lot(p_gen_obj_id NUMBER) IS
      SELECT LOT_NUMBER
        FROM mtl_lot_numbers
       WHERE GEN_OBJECT_ID = p_gen_obj_id;

    CURSOR recv_inv(p_trans_id NUMBER, p_lot_number VARCHAR2) IS
      SELECT so.organization_code,
             im.organization_id,
             rt.subinventory,
             im.inventory_Item_id,
             sl.item_revision,
             im.concatenated_segments item_number,
             im.description,
             rt.Quantity total_primary,
             rt.secondary_quantity total_secondary,
             rt.unit_of_measure,
             rt.secondary_unit_of_measure,
             rt.shipment_header_id,
             rt.po_header_id,
             rt.po_line_id,
             rt.vendor_id,
             rt.vendor_site_id,
             sl.shipment_line_id,
             po.segment1,
             sh.receipt_num,
             rt.locator_id,
             lot.lot_number,
             lot.parent_lot_number,
             po.org_id,
             hou.name,
             sum(tran.quantity) lot_primary,
             sum(tran.secondary_quantity) lot_secondary,
             rt.vendor_lot_num --Bug#6145310
        FROM rcv_transactions       rt,
             mtl_system_items_b_kfv im,
             mtl_parameters         so,
             rcv_shipment_lines     sl,
             po_headers_all         po,
             rcv_shipment_headers   sh,
             rcv_lot_transactions   tran,
             mtl_lot_numbers        lot,
             hr_operating_units     hou
       WHERE rt.TRANSACTION_ID = p_trans_id
         AND rt.shipment_header_id = sl.shipment_header_id
         AND rt.shipment_line_id = sl.shipment_line_id
         AND sl.item_id = im.inventory_item_id
         AND sl.to_organization_id = im.organization_id
         AND so.organization_id = im.organization_id
         AND rt.organization_id = im.ORGANIZATION_ID
         AND po.po_header_id = rt.po_header_id
         AND sh.shipment_header_id = rt.shipment_header_id
         AND rt.transaction_id = tran.transaction_id
         AND tran.lot_num = p_lot_number
         AND lot.inventory_item_id = im.inventory_item_id
         AND tran.lot_num = lot.lot_number
         AND lot.organization_id = im.organization_id
         AND po.org_id = hou.organization_id
       GROUP BY so.organization_code,
                im.organization_id,
                rt.subinventory,
                im.inventory_Item_id,
                sl.item_revision,
                im.concatenated_segments,
                im.description,
                rt.Quantity,
                rt.secondary_quantity,
                rt.unit_of_measure,
                rt.secondary_unit_of_measure,
                rt.shipment_header_id,
                rt.po_header_id,
                rt.po_line_id,
                rt.vendor_id,
                rt.vendor_site_id,
                sl.shipment_line_id,
                po.segment1,
                sh.receipt_num,
                rt.locator_id,
                lot.lot_number,
                lot.parent_lot_number,
                po.org_id,
                hou.name,
                rt.vendor_lot_num;

    CURSOR get_sampling_plan_id(x_spec_vr_id_in number) is
      select nvl(sample_cnt_req, 0) sample_cnt_req,
             nvl(sample_qty, 0) sample_qty,
             sample_qty_uom,
             frequency_cnt,
             frequency_per,
             sm.sampling_plan_id,
             frequency_type,
             nvl(RESERVE_CNT_REQ, 0) reserve_cnt_req,
             nvl(RESERVE_QTY, 0) reserve_qty,
             nvl(ARCHIVE_CNT_REQ, 0) archive_cnt_req,
             nvl(ARCHIVE_QTY, 0) archive_qty
        from gmd_com_spec_vrs_vl  sv, --gmd_all_spec_vrs sv, performance bug# 4916912
             gmd_sampling_plans_b sm
       where sv.sampling_plan_id = sm.sampling_plan_id
         and sv.spec_vr_id = x_spec_vr_id_in;

    CURSOR inv_sample_plan(X_SPEC_VR_ID NUMBER) is
      select nvl(sample_cnt_req, 0) sample_cnt_req,
             nvl(sample_qty, 0) sample_qty,
             sample_qty_uom,
             frequency_cnt,
             frequency_per,
             sm.sampling_plan_id,
             frequency_type,
             nvl(RESERVE_CNT_REQ, 0) reserve_cnt_req,
             nvl(RESERVE_QTY, 0) reserve_qty,
             nvl(ARCHIVE_CNT_REQ, 0) archive_cnt_req,
             nvl(ARCHIVE_QTY, 0) archive_qty
        from gmd_sampling_plans_b sm, gmd_inventory_spec_vrs sv
       where sv.sampling_plan_id = sm.sampling_plan_id
         and sv.spec_vr_id = X_SPEC_VR_ID;

    CURSOR sample_plan_freq_per(x_frequency_per varchar2) is
      SELECT meaning
        FROM gem_lookups
       WHERE lookup_type = 'GMD_QC_FREQUENCY_PERIOD'
         and lookup_code = x_frequency_per;

    /* Cursors to check if Spec VR has auto enable flag enabled */

    CURSOR inventory_auto_sample(X_SPEC_VR_ID number) is
      select nvl(auto_sample_ind, 'N')
        from GMD_INVENTORY_SPEC_VRS
       where spec_vr_id = X_SPEC_VR_ID;

    CURSOR supplier_auto_sample(X_SPEC_VR_ID number) is
      Select nvl(auto_sample_ind, 'N')
        from GMD_SUPPLIER_SPEC_VRS
       where spec_vr_id = X_SPEC_VR_ID;

    CURSOR specvr_auto_sample(X_SPEC_VR_ID number) is
      Select nvl(auto_sample_ind, 'N')
        from GMD_COM_SPEC_VRS_VL --GMD_ALL_SPEC_VRS performance bug# 4916912
       where spec_vr_id = X_SPEC_VR_ID;

    /* Given a sampling event and a retain as, gets the sample numbers */
    CURSOR get_sample_num(x_sampling_event_in number, x_retain_as_in varchar2) is
      select sample_no
        from gmd_Samples
       where sampling_event_id = x_Sampling_event_in
         and retain_as = x_retain_as_in;
    CURSOR get_reg_sample_num(x_sampling_event_in number, x_retain_as_in varchar2) is
      select sample_no
        from gmd_Samples
       where sampling_event_id = x_Sampling_event_in
         and retain_as is NULL;

    CURSOR get_from_role is
      select nvl(text, '')
        from wf_Resources
       where name = 'WF_ADMIN_ROLE' --RLNAGARA B5654562 Changed from WF_ADMIN to WF_ADMIN_ROLE
         and language = userenv('LANG');

    -- Bug 4165704 - org_id should be in rcv_transactions table, but since it isn't
    --               I need to get the value here
    --RLNAGARA B5018797 org_id is there in the po_headers_all table and hence getting from there.
    -- Here we are getting vendor name instead of vendor_site_code.
    CURSOR get_vendor_no IS /* 4576699*/
      SELECT a.segment1
        FROM po_vendors a, mtl_parameters m
       WHERE a.vendor_id = l_vendor_id
         AND m.organization_id = l_organization_id
         AND m.process_enabled_flag = 'Y';

    CURSOR get_application_id IS /* 4576699 */
      SELECT application_id
        FROM fnd_application
       WHERE application_short_name = 'GMD';

    CURSOR get_user_name(x_user_id NUMBER) IS /* 4576699 */
      SELECT user_name FROM fnd_user WHERE user_id = x_user_id;

  BEGIN
    gmd_debug.put_line('SampleCreation WF. VERIFY_EVENT '); /* 4576699 */

    IF (l_debug = 'Y') THEN
      gmd_debug.log_initialize('SampleCreation');
    END IF;

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('Event Name ' || l_event_name);
      gmd_debug.put_line('Event Key ' || l_event_key);

    END IF;

    /*************************************/
    /* CHECK WHICH EVENT HAS BEEN RAISED */
    /*************************************/
    -- Bug 4165704: event name changed
    -- IF l_event_name = 'oracle.apps.gmi.inventory.created' THEN

    IF ((l_event_name = 'oracle.apps.gmd.inventory.created') OR
       (l_event_name = 'oracle.apps.gmi.inventory.created')) THEN
      l_transaction_type := 'INVENTORY_TRANSACTION';
      gmd_debug.put_line('Inventory '); /* 4576699 */

      OPEN inv;
      FETCH inv
        INTO l_inventory_item_id, l_revision, l_item_number, l_item_desc, l_transaction_type_id, l_transaction_type_name, l_trans_qty, l_trans_qty2, l_trans_qty_uom, l_trans_qty_uom2, l_organization_id, l_organization_code, --RLNAGARA B5499961
      l_subinventory, l_locator_id;
      IF inv%found THEN

        l_valid_transaction := true;

        -- Bug 4440045: added the cursor below to fetch lot and parent lot.
        OPEN inv_lot;
        FETCH inv_lot
          INTO l_parent_lot_number, l_lot_number;
        IF inv_lot%NOTFOUND THEN

          l_parent_lot_number := NULL;
          l_lot_number        := NULL;
        END IF;
      END IF;

      -- Bug 4165704: this routine is using the 'ic' files and I don't see why it is needed
      -- so I took it out. I don't see  l_transaction_type_id being used!!!
      -- GET_DOC_NO(l_transaction_type_id, l_doc_type, l_transaction_type_id);
      -- Bug #3473230 (JKB) Added get_doc_no above.

      CLOSE inv;

      -- Bug 4165704: added cursor to retrieve locator
      IF l_locator_id IS NOT NULL THEN
        OPEN Cur_locator(l_locator_id);
        FETCH Cur_locator
          INTO l_locator;
        CLOSE Cur_locator;
      END IF; -- l_locator_id is not null

      -- Bug 4165704:event name changed
      -- ELSIF l_event_name = 'oracle.apps.gmd.lotexpiry')

    ELSIF (l_event_name = 'oracle.apps.gmi.lotexpirydate.update') THEN
      gmd_debug.put_line('Lot Expiry Date   '); /* 4576699 */

      l_transaction_type := 'LOTEXPIRY_TRANSACTION';
      OPEN lot;
      Fetch lot
        INTO l_inventory_item_id, l_organization_code, --RLNAGARA B4905645
      l_organization_id, l_item_number, l_item_desc, l_parent_lot_number, l_lot_number, l_trans_qty_uom, l_trans_qty_uom2, l_expiry_date_tmp, --RLNAGARA B4905645
      l_retest_date_tmp; --RLNAGARA B4905645
      IF lot%FOUND THEN
        l_valid_transaction := true;
        l_retest_indicator  := 'Y';
        --RLNAGARA B4905645
        l_date_format_mask := fnd_profile.value('ICX_DATE_FORMAT_MASK') ||
                              ' HH24:MI:SS';
        l_expiry_date      := TO_CHAR(l_expiry_date_tmp, l_date_format_mask);

      END IF;

      CLOSE lot;

      l_revision     := NULL;
      l_subinventory := NULL;
      l_locator_id   := NULL;

      -- Bug 4165704:event name changed
      -- ELSIF l_event_name = 'oracle.apps.gmd.lotretest' THEN
    ELSIF (l_event_name = 'oracle.apps.gmi.lotretestdate.update') THEN
      gmd_debug.put_line('Lot Retest Date '); /* 4576699 */

      l_transaction_type := 'LOTRETEST_TRANSACTION';
      OPEN lot;
      FETCH lot
        INTO l_inventory_item_id, l_organization_code, --RLNAGARA B4905645
      l_organization_id, l_item_number, l_item_desc, l_parent_lot_number, l_lot_number, l_trans_qty_uom, l_trans_qty_uom2, l_expiry_date_tmp, --RLNAGARA B4905645
      l_retest_date_tmp; --RLNAGARA B4905645
      IF lot%FOUND THEN
        l_valid_transaction := true;
        l_retest_indicator  := 'Y';
        --RLNAGARA B4905645
        l_date_format_mask := fnd_profile.value('ICX_DATE_FORMAT_MASK') ||
                              ' HH24:MI:SS';
        l_retest_date      := TO_CHAR(l_retest_date_tmp, l_date_format_mask);

      END IF;
      CLOSE lot;

      l_revision     := NULL;
      l_subinventory := NULL;
      l_locator_id   := NULL;

    ELSIF l_event_name = 'oracle.apps.gml.po.receipt.created' THEN
      gmd_debug.put_line('PO Receipts'); -- Bug # 4576699

      l_transaction_type := 'RECEIVING_TRANSACTION';
      --wf_log_pkg.string(6, 'Dummy','PO Receipts');
      /* Set Org Context as we are using multi org view RCV_TRANSACTIONS_V */

      OPEN recv;
      FETCH recv
        INTO l_organization_code, l_organization_id, l_subinventory, l_inventory_item_id,
        l_revision, l_item_number, l_item_desc, l_trans_qty, l_trans_qty2, l_trans_qty_uom,
        l_trans_qty_uom2, l_shipment_header_id, l_po_header_id, l_po_line_id, l_vendor_id,
        l_vendor_site_id, l_receipt_line_id, l_purchase_no, l_receipt_no, l_locator_id,
      -- took out org_id for P1 bug
      l_org_id, --RLNAGARA B5018797 Uncommented this
      l_operating_unit, --RLNAGARA B5018797
      l_vendor_lot_num; --Bug#6145310
      IF recv%found THEN
        --wf_log_pkg.string(6, 'Dummy','Found PO Receipts');

        l_valid_transaction := true;
      END IF;

      CLOSE recv;

      -- Bug 4165704: added cursor to retrieve locator
      IF l_locator_id IS NOT NULL THEN
        OPEN Cur_locator(l_locator_id);
        FETCH Cur_locator
          INTO l_locator;
        CLOSE Cur_locator;
      END IF; -- l_locator_id is not null

      -- Bug 4165704:event name changed
      --ELSIF l_event_name = 'oracle.apps.gmi.inv.po.receipt' THEN
    ELSIF ((l_event_name = 'oracle.apps.gmd.po.receipt.inventory') OR
          (l_event_name = 'oracle.apps.gmi.inv.po.receipt')) THEN
      gmd_debug.put_line('Inventory PO Receipts'); -- Bug # 4576699

      l_transaction_type := 'INV_RCV_TRANSACTION';

      --RLNAGARA Bug5334308
      l_trans_id   := SUBSTR(l_event_key, 1, INSTR(l_event_key, '-') - 1);
      l_gen_obj_id := SUBSTR(l_event_key, INSTR(l_event_key, '-') + 1);

      OPEN get_lot(l_gen_obj_id);
      FETCH get_lot
        INTO l_lot_number;
      CLOSE get_lot;

      OPEN recv_inv(l_trans_id, l_lot_number);
      FETCH recv_inv
        into l_organization_code, l_organization_id, l_subinventory, l_inventory_item_id,
        l_revision, l_item_number, l_item_desc, l_trans_qty, l_trans_qty2, l_trans_qty_uom,
        l_trans_qty_uom2, l_shipment_header_id, l_po_header_id, l_po_line_id, l_vendor_id,
        l_vendor_site_id, l_receipt_line_id, l_purchase_no, l_receipt_no, l_locator_id, l_lot_number,
        l_parent_lot_number, l_org_id, l_operating_unit, l_lot_qty, l_lot_qty2, l_vendor_lot_num; --Bug#6145310
      IF recv_inv%found THEN
        gmd_debug.put_line('Found Inv PO Receipts'); -- Bug # 4576699
        l_valid_transaction := true;
      END IF;
      CLOSE recv_inv;

      -- Bug 4165704: added cursor to retrieve locator
      IF l_locator_id IS NOT NULL THEN
        OPEN Cur_locator(l_locator_id);
        FETCH Cur_locator
          INTO l_locator;
        CLOSE Cur_locator;
      END IF; -- l_locator_id is not null

    ELSIF l_event_name = 'oracle.apps.gme.batch.created' THEN
      gmd_debug.put_line('Event is Batch Creation'); -- Bug # 4576699
      l_transaction_type  := 'PRODUCTION_TRANSACTION';
      l_valid_transaction := true;
    ELSIF l_event_name = 'oracle.apps.gme.batchstep.created' THEN
      gmd_debug.put_line('Event is Batchstep Creation'); -- Bug # 4576699
      l_transaction_type  := 'PRODUCTION_TRANSACTION';
      l_valid_transaction := true;
    ELSIF l_event_name = 'oracle.apps.gme.bstep.rel.wf' THEN
      gmd_debug.put_line('Event is Batch Step Release'); -- Bug # 4576699
      l_transaction_type  := 'PRODUCTION_TRANSACTION';
      l_valid_transaction := true;
    END IF;

    /************************************************/
    /* END OF CHECK FOR WHICH EVENT HAS BEEN RAISED */
    /************************************************/

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('Transaction Type ' || l_transaction_type);
    END IF;

    OPEN get_from_role;
    FETCH get_from_role
      into l_from_role;
    CLOSE get_from_role;

    IF l_Event_name not in
       ('oracle.apps.gme.batchstep.created', 'oracle.apps.gme.batch.created',
        'oracle.apps.gme.bstep.rel.wf') THEN
      gmd_debug.put_line('Checking for Vendor Specifications '); -- Bug # 4576699

      /**********************************/
      /* ONLY CONTINUE IF NOT WIP       */
      /**********************************/

      -- Bug 4165704: event 'oracle.apps.gmi.inv.po.receipt' name changed to  'oracle.apps.gmd.po.receipt.inventory'
      IF l_valid_transaction and
         l_event_name in ('oracle.apps.gml.po.receipt.created',
          'oracle.apps.gmd.po.receipt.inventory',
          'oracle.apps.gmi.inv.po.receipt') THEN
        gmd_debug.put_line('Processing PO Transactions'); -- Bug # 4576699

        /**********************************/
        /* Supplier Samples ONLY          */
        /* Check for specification        */
        /**********************************/

        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('PO Receiving Code');
        END IF;

        -- Bug 4165704: replaced the following sql with code below
        IF l_vendor_id IS NOT NULL THEN
          OPEN get_vendor_no; /* 4576699 */
          FETCH get_vendor_no
            INTO l_vendor_no;

          IF (get_vendor_no%NOTFOUND) THEN
            CLOSE get_vendor_no;

            RAISE no_vendor_found;
          END IF;
          CLOSE get_vendor_no;
        END IF;

        /*Figure out if proper Specifications exist */
        l_supp_spec.inventory_item_id := l_inventory_item_id;
        l_supp_spec.revision          := l_revision;
        l_supp_spec.organization_id   := l_organization_id;
        l_supp_spec.subinventory      := l_subinventory;
        l_supp_spec.locator_id        := l_locator_id;
        l_supp_spec.supplier_id       := l_vendor_id;
        l_supp_spec.supplier_site_id  := l_vendor_site_id;
        l_supp_spec.po_header_id      := l_po_header_id;
        l_supp_spec.po_line_id        := l_po_line_id;
        l_supp_spec.date_effective    := SYSDATE;
        l_supp_spec.exact_match       := 'N';
        l_supp_spec.lot_number        := L_lot_number;
        l_supp_spec.parent_lot_number := L_parent_lot_number;
        l_supp_spec.org_id            := l_org_id; --RLNAGARA B5018797 to find correct supplier spec using org_id

        gmd_debug.put_line('PO Specification attributes Set'); -- Bug # 4576699
        --wf_log_pkg.string(6, 'Dummy','PO Specification attributes Set');

        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('Checking for Spec');
        END IF;

        IF GMD_SPEC_MATCH_GRP.FIND_SUPPLIER_OR_INV_SPEC(p_supplier_spec_rec => l_supp_spec,
                                                        x_spec_id           => l_spec_id,
                                                        x_spec_vr_id        => l_spec_vr_id,
                                                        x_spec_type         => l_spec_type,
                                                        x_return_status     => l_return_status,
                                                        x_message_data      => l_msg_data) THEN

          /* Specification Found */
          /* Check to see if there is a sampling plan */
          IF (l_debug = 'Y') THEN
            gmd_debug.put_line('Spec found');
          END IF;

          OPEN get_sampling_plan_id(l_spec_vr_id);
          FETCH get_sampling_plan_id
            into l_sample_count, l_sample_qty, l_sample_qty_uom, l_frequency_count, l_frequency_per, l_sample_plan_id, l_frequency_type, l_reserve_cnt_req, l_reserve_qty, l_archive_cnt_req, l_archive_qty;

          IF get_sampling_plan_id%found THEN
            IF (l_frequency_type <> 'Q') THEN
              OPEN sample_plan_freq_per(l_frequency_per);
              FETCH sample_plan_freq_per
                into l_frequency_per;
              CLOSE sample_plan_freq_per;
            END IF;

            l_sample_plan_exists := 1;
          ELSE
            l_sample_plan_exists := 0;
            l_sample_count       := 1;
          END IF; --  IF get_sampling_plan_id%found
          CLOSE get_sampling_plan_id;

          /*
             OPEN recv_sample_plan(l_spec_vr_id);
             FETCH recv_sample_plan into l_sample_count,
                                      l_sample_qty,
                                         l_sample_qty_uom,
                                      l_frequency_count, l_frequency_per ,
                                         l_sample_plan_id ,
                                      l_frequency_type,
                                         l_reserve_cnt_req,
                                      l_reserve_qty,
                                      l_archive_cnt_req,
                                      l_archive_qty;
             CLOSE recv_sample_plan;
          */

          /* Create Sampling Event for Supplier sample */
          l_sampling_events.original_spec_vr_id := l_spec_vr_id;
          l_sampling_events.sampling_plan_id    := l_sample_plan_id;
          l_sampling_events.disposition         := '1P';
          l_sampling_events.source              := 'S';
          l_sampling_events.inventory_item_id   := L_inventory_item_id;
          l_sampling_events.revision            := L_revision;
          l_sampling_events.sample_req_cnt      := l_sample_count;
          l_sampling_events.sample_taken_cnt    := 0;
          l_sampling_events.supplier_id         := L_vendor_id;
          l_sampling_events.supplier_site_id    := L_vendor_site_id;
          l_sampling_events.po_header_id        := L_po_header_id;
          l_sampling_events.po_line_id          := L_po_line_id;
          l_sampling_events.sample_type         := 'I';
          l_sampling_events.subinventory        := l_subinventory;
          l_sampling_events.locator_id          := l_locator_id;
          l_sampling_events.lot_number          := L_lot_number;
          l_sampling_events.parent_lot_number   := L_parent_lot_number;
          l_sampling_events.organization_id     := L_organization_id;
          l_sampling_events.CREATION_DATE       := SYSDATE;
          l_sampling_events.CREATED_BY          := FND_GLOBAL.USER_ID;
          l_sampling_events.LAST_UPDATED_BY     := FND_GLOBAL.USER_ID;
          l_sampling_events.LAST_UPDATE_DATE    := SYSDATE;
          l_sampling_events.org_id              := l_org_id; --RLNAGARA B5018797 Added this parameter to insert
          l_sampling_events.supplier_lot_no     := l_vendor_lot_num;

          /* Added missing PO Receiving information */
          l_sampling_events.receipt_id      := L_shipment_header_id;
          l_sampling_events.receipt_line_id := L_receipt_line_id;

          IF NOT
              GMD_SAMPLING_EVENTS_PVT.insert_row(p_sampling_events => l_sampling_events,
                                                 x_sampling_events => l_sampling_events_out) THEN
            gmd_debug.put_line('Sampling Event Creation Failed'); -- Bug # 4576699

            --wf_log_pkg.string(6, 'Dummy','Sampling Event Creation Failed');
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          l_sampling_events := l_sampling_events_out;

          /* Check to see if auto Sample Creation is enabled for this supplier or inventory Spec VR */
          /* Invconv bug 4165704: if inventory spec vr found, inventory_auto_sample cursor used */
          IF l_spec_type = 'I' THEN
            OPEN inventory_auto_sample(l_spec_vr_id);
            FETCH inventory_auto_sample
              into l_auto_sample;
            CLOSE inventory_auto_sample;
          ELSE
            OPEN supplier_auto_sample(l_spec_vr_id);
            FETCH supplier_auto_sample
              into l_auto_Sample;
            CLOSE supplier_auto_sample;
          END IF;

          -- bug 4165704: doc_number replaced by call to GMD_QUALITY_PARAMETERS_GRP.get_quality_parameters
          --              Check to see if Auto Doc Numbering exists for the Org
          GMD_QUALITY_PARAMETERS_GRP.get_quality_parameters(p_organization_id    => l_organization_id,
                                                            x_quality_parameters => quality_config,
                                                            x_return_status      => l_return_status,
                                                            x_orgn_found         => l_orgn_found);

          IF (l_return_status <> 'S') THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          l_doc_number := quality_config.sample_assignment_type;

          IF l_sample_plan_exists = 1 THEN
            -- taken out because redundant
            --IF (l_frequency_type <> 'Q') THEN
            --   OPEN sample_plan_freq_per (l_frequency_per) ;
            --   FETCH sample_plan_freq_per into l_frequency_per ;
            --   CLOSE sample_plan_freq_per ;
            --END IF;

            FND_MESSAGE.SET_NAME('GMD', 'GMD_SAMPLE_PLAN_INFO');
            FND_MESSAGE.SET_TOKEN('SAMPLE_NO', l_sample_count);
            FND_MESSAGE.SET_TOKEN('FREQ_CNT', l_frequency_count);
            FND_MESSAGE.SET_TOKEN('FREQ_PER', l_frequency_per);
            FND_MESSAGE.SET_TOKEN('SAMPLE_QTY', l_sample_qty);
            FND_MESSAGE.SET_TOKEN('SAMPLE_UOM', l_sample_qty_uom); --RLNAGARA B4905670 It is SAMPLE_UOM and not SAMPLE_QTY_UOM
            FND_MESSAGE.SET_TOKEN('ASAMPLE_NO', l_archive_cnt_req);
            FND_MESSAGE.SET_TOKEN('ASAMPLE_QTY', l_archive_qty);
            FND_MESSAGE.SET_TOKEN('RSAMPLE_NO', l_reserve_cnt_req);
            FND_MESSAGE.SET_TOKEN('RSAMPLE_QTY', l_reserve_qty);

            /* Check to see if auto sample creation is enabled and auto docu numbering for the Org*/
            IF ((l_auto_sample = 'Y') and (l_doc_number = 2)) THEN

              /* Calculate the required standard samples */
              IF (l_frequency_type = 'Q') THEN
                -- Bug 3617267
                -- Bug 4165704: Inventory Convergence
                --              new conversion routine used.
                -- GMICUOM.icuomcv( pitem_id => l_inventory_item_id,
                -- plot_id => NULL,
                -- pcur_qty => l_trans_qty ,
                -- pcur_uom => l_trans_qty_uom,
                -- pnew_uom => l_frequency_per ,
                -- onew_qty => l_qty_conv);

                --Begin Bug 6807847. For PO Transactions l_trans_qty_uom is in unit_of_measure.
                --Hence get corresponding uom_code from unit_of_measure.
                IF (l_debug = 'Y') THEN
                  gmd_debug.put_line('PO Transactions, l_trans_qty_uom = ' ||
                                     l_trans_qty_uom);
                END IF;

                BEGIN
                  SELECT uom_code
                    INTO l_trans_qty_uom
                    FROM mtl_units_of_measure
                   WHERE unit_of_measure = l_trans_qty_uom;

                EXCEPTION
                  WHEN OTHERS THEN
                    IF (l_debug = 'Y') THEN
                      gmd_debug.put_line('Unable to fetch uom_code from mtl_units_of_measure');
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
                END;
                --End Bug 6807847.

                --RLNAGARA 5334308 Added the IF condition..coz we need to create samples based on Lot qty
                IF (l_event_name = 'oracle.apps.gmi.inv.po.receipt') THEN
                  l_qty_conv := INV_CONVERT.
                                inv_um_convert(item_id         => l_inventory_item_id,
                                               lot_number      => NULL,
                                               organization_id => l_organization_id,
                                               precision       => 5, -- decimal point precision
                                               from_quantity   => l_lot_qty,
                                               from_unit       => l_trans_qty_uom,
                                               to_unit         => l_frequency_per,
                                               from_name       => NULL,
                                               to_name         => NULL);
                ELSE
                  l_qty_conv := INV_CONVERT.
                                inv_um_convert(item_id         => l_inventory_item_id,
                                               lot_number      => NULL,
                                               organization_id => l_organization_id,
                                               precision       => 5, -- decimal point precision
                                               from_quantity   => l_trans_qty,
                                               from_unit       => l_trans_qty_uom,
                                               to_unit         => l_frequency_per,
                                               from_name       => NULL,
                                               to_name         => NULL);
                END IF;

                --Bug 6807847
                IF l_qty_conv = -99999 THEN
                  IF (l_debug = 'Y') THEN
                    gmd_debug.put_line('ERROR1 in function INV_CONVERT.inv_um_convert');
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- Bug 4896237. svankada. Sample Count = (Trans_qty in sampling plan freq UOM /  Per * Sample_cnt)
                l_sampling_events.sample_req_cnt := floor(l_qty_conv /
                                                          l_frequency_count) *
                                                    l_sample_count;

              ELSIF (l_frequency_type = 'F') THEN
                -- Bug 3617267
                r := 0; --Added in Bug No.8222504
                --RLNAGARA Bug 5910300 start
                UPDATE GMD_SUPPLIER_SPEC_VRS
                   SET RECEIPT_FREQUENCY = NVL(RECEIPT_FREQUENCY, 0) + 1 --RLNAGARA Bug 5910300 Rework Added NVL
                 WHERE SPEC_VR_ID = l_spec_vr_id;

                IF (SQL%ROWCOUNT <> 0) THEN
                  --Added IF in Bug No.8222504
                  select RECEIPT_FREQUENCY
                    into r
                    from GMD_SUPPLIER_SPEC_VRS
                   where spec_vr_id = l_spec_vr_id;
                END IF;

                IF r <> l_frequency_count THEN
                  p_resultout := 'COMPLETE:';
                  --  RETURN;  --Commented in Bug No.8222504
                ELSE
                  UPDATE GMD_SUPPLIER_SPEC_VRS
                     SET RECEIPT_FREQUENCY = 0
                   WHERE SPEC_VR_ID = l_spec_vr_id;
                  l_sampling_events.sample_req_cnt := l_sample_count;
                END IF;
                --RLNAGARA Bug 5910300 end
              ELSIF (l_frequency_type = 'T') THEN
                -- Bug 3617267
                l_sampling_events.sample_req_cnt := l_sample_count;
              ELSIF (l_frequency_type = 'P') THEN
                -- Bug 3617267
                --RLNAGARA 5334308 Added the IF condition..coz we need to create samples based on Lot qty
                IF (l_event_name = 'oracle.apps.gmi.inv.po.receipt') THEN
                  l_sampling_events.sample_req_cnt := l_sample_count *
                                                      floor(l_lot_qty /
                                                            l_frequency_per);
                ELSE
                  l_sampling_events.sample_req_cnt := l_sample_count *
                                                      floor(l_trans_qty /
                                                            l_frequency_per);
                END IF;
              END IF; -- IF (l_frequency_type = 'Q')

              -- Create Supplier samples
              GMD_AUTO_SAMPLE_PKG.create_samples(l_sampling_events,
                                                 l_spec_id,
                                                 l_spec_vr_id,
                                                 create_status);

              /* Sampling Event Successfully Created. Set Form Attribute to the sampling event */
              l_form := 'GMDQSAMPLES_F:SAMPLING_EVENT_ID="' ||
                        l_sampling_events.sampling_event_id || '"';

              /* If we created samples, show them */
              OPEN get_sample_num(l_sampling_events.sampling_event_id, 'R');
              FETCH get_sample_num
                into frsample_name; /* Get the first */
              IF frsample_name is not NULL THEN
                LOOP
                  lrsample_name    := sample_name_temp;
                  sample_name_temp := '';
                  FETCH get_sample_num
                    into sample_name_temp;
                  EXIT WHEN get_sample_num%NOTFOUND;
                END LOOP;
              ELSE
                lrsample_name := frsample_name;
              END IF;
              CLOSE get_sample_num;

              OPEN get_sample_num(l_sampling_events.sampling_event_id, 'A');
              FETCH get_sample_num
                into fasample_name; /* Get the first */
              IF fasample_name is not NULL THEN
                LOOP
                  lasample_name    := sample_name_temp;
                  sample_name_temp := '';
                  FETCH get_sample_num
                    into sample_name_temp;
                  EXIT WHEN get_sample_num%NOTFOUND;
                END LOOP;
              ELSE
                lasample_name := fasample_name;
              END IF;
              CLOSE get_sample_num;

              OPEN get_reg_sample_num(l_sampling_events.sampling_event_id,
                                      null);
              FETCH get_reg_sample_num
                into fsample_name; /* Get the first */
              IF fsample_name is not NULL THEN
                LOOP
                  lsample_name     := sample_name_temp;
                  sample_name_temp := '';
                  FETCH get_reg_sample_num
                    into sample_name_temp;
                  EXIT WHEN get_reg_sample_num%NOTFOUND;
                END LOOP;
              ELSE
                lsample_name := fsample_name;
              END IF;
              CLOSE get_reg_sample_num;

              IF (lrsample_name IS not NULL) THEN
                FND_MESSAGE.SET_TOKEN('RESERVE_SAMPLES',
                                      frsample_name || '-' || lrsample_name);
              ELSE
                FND_MESSAGE.SET_TOKEN('RESERVE_SAMPLES', frsample_name);
              END IF;

              IF (lasample_name IS not NULL) THEN
                FND_MESSAGE.SET_TOKEN('ARCHIVE_SAMPLES',
                                      fasample_name || '-' || lasample_name);
              ELSE
                FND_MESSAGE.SET_TOKEN('ARCHIVE_SAMPLES', fasample_name);
              END IF;

              IF (lsample_name IS not NULL) THEN
                FND_MESSAGE.SET_TOKEN('RGULAR_SAMPLES',
                                      fsample_name || '-' || lsample_name);
              ELSE
                FND_MESSAGE.SET_TOKEN('RGULAR_SAMPLES', fsample_name);
              END IF;

              --l_sample_plan := FND_MESSAGE.GET(); RLNAGARA B4905670 Commented this line

            ELSE
              -- IF ((l_auto_sample <> 'Y') or (l_doc_number <> 2))

              /* Sampling Event Successfully Created. Set Form Attribute to the sampling event */
              --RLNAGARA B5389806 Only passing sampling_event_id is not enough to create samples.
              --Here we need to pass another parameter called WF_SAMPLE which informs that the sample
              --is getting created from the workflow notification. Based on this only we take the sample
              --disposition as the disposition in the sampling events table otherwise if the WF_SAMPLE
              --is "N"(or NULL) (this will happen when we call samples form from other forms to create samples)
              --then we take the default disposition ie Pending to create the samples.

              --l_form := 'GMDQSMPL_EDIT_F:SAMPLING_EVENT_ID="'|| l_sampling_events.sampling_event_id||'"';
              l_form := 'GMDQSMPL_EDIT_F:SAMPLING_EVENT_ID="' ||
                        l_sampling_events.sampling_event_id ||
                        '" WF_SAMPLE="Y"';

            END IF; -- IF ((l_auto_sample = 'Y') and (l_doc_number = 2))

            -- Bug 3625651 : populate the workflow attribute with
            -- the sampling plan information
            l_sample_plan := FND_MESSAGE.GET();

          ELSE
            -- l_sample_plan_exists <> 1
            FND_MESSAGE.SET_NAME('GMD', 'GMD_SAMPLE_PLAN_NONE');
            l_sample_plan  := FND_MESSAGE.GET();
            l_sample_count := 1; -- just in case

            /* Sampling Event Successfully Created. Set Form Attribute
            to the sampling event */
            --RLNAGARA B5389806 Only passing sampling_event_id is not enough to create samples.
            --Here we need to pass another parameter called WF_SAMPLE which informs that the sample
            --is getting created from the workflow notification. Based on this only we take the sample
            --disposition as the disposition in the sampling events table otherwise if the WF_SAMPLE
            --is "N"(or NULL) (this will happen when we call samples form from other forms to create samples)
            --then we take the default disposition ie Pending to create the samples.

            --l_form := 'GMDQSMPL_EDIT_F:SAMPLING_EVENT_ID="'|| l_sampling_events.sampling_event_id||'"';
            l_form := 'GMDQSMPL_EDIT_F:SAMPLING_EVENT_ID="' ||
                      l_sampling_events.sampling_event_id ||
                      '" WF_SAMPLE="Y"';
          END IF; -- IF  l_sample_plan_exists = 1

          IF ((l_auto_sample <> 'Y') or (l_doc_number <> 2)) THEN
            /* In the case where auto sample IS not enabled, create event spec disp */
            /* Create Spec Event Disposition Row */
            l_event_spec_disp.SAMPLING_EVENT_ID            := l_sampling_events.sampling_event_id;
            l_event_spec_disp.SPEC_ID                      := l_spec_id;
            l_event_spec_disp.SPEC_VR_ID                   := l_spec_vr_id;
            l_event_spec_disp.DISPOSITION                  := '1P';
            l_event_spec_disp.SPEC_USED_FOR_LOT_ATTRIB_IND := NULL;
            l_event_spec_disp.DELETE_MARK                  := 0;
            l_event_spec_disp.CREATION_DATE                := sysdate;
            l_event_spec_disp.CREATED_BY                   := FND_GLOBAL.USER_ID;
            l_event_spec_disp.LAST_UPDATE_DATE             := sysdate;
            l_event_spec_disp.LAST_UPDATED_BY              := FND_GLOBAL.USER_ID;

            IF (l_debug = 'Y') THEN
              gmd_debug.put_line('Going to insert event spec disp');
            END IF;

            IF NOT
                GMD_EVENT_SPEC_DISP_PVT.INSERT_ROW(p_event_spec_disp => l_event_spec_disp,
                                                   x_event_spec_disp => l_event_spec_disp_out) THEN
              gmd_debug.put_line('Sampling Event disposition Creation Failed'); -- Bug # 4576699

              --wf_log_pkg.string(6, 'Dummy','Sampling Event disposition Creation Failed');
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            l_event_spec_disp := l_event_spec_disp_out;

            IF (l_debug = 'Y') THEN
              gmd_debug.put_line('Created event spec disp');
            END IF;

          END IF; /* End of check to create event spec for non-auto sample */

          l_vendor_spec_found := true;
          gmd_debug.put_line('Vendor Specification Found....Event Created with id' ||
                             l_sampling_events.sampling_event_id); -- Bug # 4576699

        ELSE
          -- supplier spec not found
          l_vendor_spec_found := false;
        END IF; -- IF GMD_SPEC_MATCH_GRP.FIND_SUPPLIER_OR_INV_SPEC(

      END IF; -- IF l_valid_transaction and l_event_name  in ('oracle.apps.gml.po.receipt.created',

      /***************************************************************/
      /***************************************************************/
      /***************************************************************/
      /* Come here if inventory transaction (lot retest/expiry, etc. */
      /***************************************************************/
      /* CHECK FOR INVENTORY SPEC IF OTHER SPEC NOT FOUND ************/
      /***************************************************************/
      /***************************************************************/
      /***************************************************************/

      --gml_sf_log('Checking for inventory spec. ');

      IF l_valid_transaction and not l_vendor_spec_found THEN
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('Inventory Code');
        END IF;

        /* Figure out if proper Specifications exist */
        l_inv_spec.inventory_item_id := L_inventory_item_id;
        l_inv_spec.revision          := L_revision;
        l_inv_spec.organization_id   := l_organization_id;
        l_inv_spec.lot_number        := l_lot_number;
        l_inv_spec.parent_lot_number := l_parent_lot_number;
        l_inv_spec.subinventory      := l_subinventory;
        l_inv_spec.locator_id        := l_locator_id;
        l_inv_spec.date_effective    := SYSDATE;
        l_inv_spec.exact_match       := 'N';

        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('Checking for Spec');
        END IF;

        IF GMD_SPEC_MATCH_GRP.FIND_INVENTORY_SPEC(p_inventory_spec_rec => l_inv_spec,
                                                  x_spec_id            => l_spec_id,
                                                  x_spec_vr_id         => l_spec_vr_id,
                                                  x_return_status      => l_return_status,
                                                  x_message_data       => l_msg_data) THEN

          /* Specification Found */
          /* Create Sampling Event */

          IF (l_debug = 'Y') THEN
            gmd_debug.put_line('Spec Found: ' || l_spec_id || ' ' ||
                               l_spec_vr_id);
          END IF;

          OPEN get_sampling_plan_id(l_spec_vr_id);
          FETCH get_sampling_plan_id
            INTO l_sample_count, l_sample_qty, l_sample_qty_uom, l_frequency_count, l_frequency_per, l_sample_plan_id, l_frequency_type, l_reserve_cnt_req, l_reserve_qty, l_archive_cnt_req, l_archive_qty;

          /* replaced by get_sampling_plan_id above
          OPEN inv_sample_plan(l_spec_vr_id);
                  FETCH inv_sample_plan into l_sample_count, l_sample_qty,
                         l_sample_qty_uom, l_frequency_count, l_frequency_per ,
                         l_sample_plan_id , l_frequency_type,
                         l_reserve_cnt_req, l_reserve_qty,
                         l_archive_cnt_req, l_archive_qty;
          CLOSE inv_sample_plan;
          */

          IF get_sampling_plan_id%found THEN
            NULL;
          ELSE
            l_sample_count := 1;
          END IF;

          CLOSE get_sampling_plan_id;

          l_sampling_events.original_spec_vr_id := l_spec_vr_id;
          l_sampling_events.sampling_plan_id    := l_sample_plan_id;
          l_sampling_events.locator_id          := l_locator_id;
          l_sampling_events.disposition         := '1P';
          l_sampling_events.source              := 'I';
          l_sampling_events.inventory_item_id   := L_inventory_item_id;
          l_sampling_events.revision            := L_revision;
          l_sampling_events.lot_number          := L_lot_number;
          l_sampling_events.parent_lot_number   := L_parent_lot_number;
          l_sampling_events.subinventory        := L_subinventory;
          l_sampling_events.lot_retest_ind      := L_retest_indicator;
          l_sampling_events.sample_req_cnt      := l_sample_count;
          l_sampling_events.sample_taken_cnt    := 0;
          l_sampling_events.sample_type         := 'I';
          -- Bug 2825696: added orgn_code to gmd_sampling_events table
          l_sampling_events.organization_id  := L_organization_id;
          l_sampling_events.CREATION_DATE    := SYSDATE;
          l_sampling_events.CREATED_BY       := FND_GLOBAL.USER_ID;
          l_sampling_events.LAST_UPDATED_BY  := FND_GLOBAL.USER_ID;
          l_sampling_events.LAST_UPDATE_DATE := SYSDATE;

          IF (l_debug = 'Y') THEN
            gmd_debug.put_line('Going to insert sample event');
          END IF;

          IF NOT
              GMD_SAMPLING_EVENTS_PVT.insert_row(p_sampling_events => l_sampling_events,
                                                 x_sampling_events => l_sampling_events_out) THEN
            gmd_debug.put_line('Sampling Event Creation Failed'); -- Bug # 4576699
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          l_sampling_events := l_sampling_events_out;

          IF (l_debug = 'Y') THEN
            gmd_debug.put_line('Created Sampling Event');
          END IF;

          /* Check to see if auto Sample Creation is enabled for this Spec VR */
          OPEN inventory_auto_sample(l_spec_vr_id);
          FETCH inventory_auto_sample
            into l_auto_sample;
          CLOSE inventory_auto_sample;

          /* Check to see if Auto Doc Numbering exists for the Org */
          GMD_QUALITY_PARAMETERS_GRP.get_quality_parameters(p_organization_id    => l_organization_id,
                                                            x_quality_parameters => quality_config,
                                                            x_return_status      => l_return_status,
                                                            x_orgn_found         => l_orgn_found);

          IF (l_return_status <> 'S') THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          l_doc_number := quality_config.sample_assignment_type;

          IF (l_debug = 'Y') THEN
            gmd_debug.put_line('Auto Sample Flag: ' || l_auto_sample);
          END IF;

          /* Check to see if there is a sampling plan */
          OPEN inv_sample_plan(l_spec_vr_id);
          FETCH inv_sample_plan
            into l_sample_count, l_sample_qty, l_sample_qty_uom, l_frequency_count, l_frequency_per, l_sample_plan_id, l_frequency_type, l_reserve_cnt_req, l_reserve_qty, l_archive_cnt_req, l_archive_qty;

          IF inv_sample_plan%found THEN
            IF (l_frequency_type <> 'Q') THEN
              OPEN sample_plan_freq_per(l_frequency_per);
              FETCH sample_plan_freq_per
                into l_frequency_per;
              CLOSE sample_plan_freq_per;
            END IF;

            FND_MESSAGE.SET_NAME('GMD', 'GMD_SAMPLE_PLAN_INFO');
            FND_MESSAGE.SET_TOKEN('SAMPLE_NO', l_sample_count);
            FND_MESSAGE.SET_TOKEN('FREQ_CNT', l_frequency_count);
            FND_MESSAGE.SET_TOKEN('FREQ_PER', l_frequency_per);
            FND_MESSAGE.SET_TOKEN('SAMPLE_QTY', l_sample_qty);
            FND_MESSAGE.SET_TOKEN('SAMPLE_UOM', l_sample_qty_uom); --RLNAGARA B4905670
            FND_MESSAGE.SET_TOKEN('ASAMPLE_NO', l_archive_cnt_req);
            FND_MESSAGE.SET_TOKEN('ASAMPLE_QTY', l_archive_qty);
            FND_MESSAGE.SET_TOKEN('RSAMPLE_NO', l_reserve_cnt_req);
            FND_MESSAGE.SET_TOKEN('RSAMPLE_QTY', l_reserve_qty);

            l_sample_plan_exists := 1;

            /* Check to see if auto sample creation is enabled */
            IF ((l_auto_sample = 'Y') and (l_doc_number = 2)) THEN
              IF (l_debug = 'Y') THEN
                gmd_debug.put_line('going to Auto sample pkg');
              END IF;

              /* Calculate the required standard samples */
              -- BUG 4165704: event name changed
              -- IF l_event_name = 'oracle.apps.gmi.inventory.created' THEN
              IF ((l_event_name = 'oracle.apps.gmd.inventory.created') OR
                 (l_event_name = 'oracle.apps.gmi.inventory.created')) THEN
                IF (l_frequency_type = 'Q') THEN
                  -- Bug 3617267
                  -- Bug 4165704: Inventory Convergence
                  --              new conversion routine used.
                  -- GMICUOM.icuomcv( pitem_id => l_inventory_item_id,
                  -- plot_id => NULL,
                  -- pcur_qty => l_trans_qty ,
                  -- pcur_uom => l_trans_qty_uom,
                  -- pnew_uom => l_frequency_per ,
                  -- onew_qty => l_qty_conv);

                  l_qty_conv := INV_CONVERT.
                                inv_um_convert(item_id         => l_inventory_item_id,
                                               lot_number      => NULL,
                                               organization_id => l_organization_id,
                                               precision       => 5, -- decimal point precision
                                               from_quantity   => l_trans_qty,
                                               from_unit       => l_trans_qty_uom,
                                               to_unit         => l_frequency_per,
                                               from_name       => NULL,
                                               to_name         => NULL);

                  --Bug 6807847
                  IF l_qty_conv = -99999 THEN
                    IF (l_debug = 'Y') THEN
                      gmd_debug.put_line('ERROR2 in function INV_CONVERT.inv_um_convert');
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
                  END IF;

                  -- Bug 4896237. svankada. Sample Count = (Trans_qty in sampling plan freq UOM /  Per * Sample_cnt)
                  l_sampling_events.sample_req_cnt := FLOOR(l_qty_conv /
                                                            l_frequency_count) *
                                                      l_sample_count;
                ELSIF (l_frequency_type = 'F') THEN
                  -- Bug 3617267
                  l_sampling_events.sample_req_cnt := l_sample_count;
                ELSIF (l_frequency_type = 'T') THEN
                  -- Bug 3617267
                  l_sampling_events.sample_req_cnt := l_sample_count;
                ELSIF (l_frequency_type = 'P') THEN
                  -- Bug 3617267
                  l_sampling_events.sample_req_cnt := l_sample_count *
                                                      floor(l_trans_qty /
                                                            l_frequency_per);
                END IF; --  IF (l_frequency_type = 'Q')
              END IF; --  IF l_event_name = 'oracle.apps.gmd.inventory.created'

              GMD_AUTO_SAMPLE_PKG.create_samples(l_sampling_events,
                                                 l_spec_id,
                                                 l_spec_vr_id,
                                                 create_status);

              IF (l_debug = 'Y') THEN
                gmd_debug.put_line('Status from Auto pkg ' ||
                                   create_status);
              END IF;

              /* Sampling Event Successfully Created. Set Form Attribute
              to the sampling event */
              l_form := 'GMDQSAMPLES_F:SAMPLING_EVENT_ID="' ||
                        l_sampling_events.sampling_event_id || '"';

              /* If we created samples, show them */
              OPEN get_sample_num(l_sampling_events.sampling_event_id, 'R');
              FETCH get_sample_num
                into frsample_name; /* Get the first */

              IF frsample_name IS not NULL THEN
                LOOP
                  lrsample_name    := sample_name_temp;
                  sample_name_temp := '';
                  FETCH get_sample_num
                    into sample_name_temp;
                  EXIT WHEN get_sample_num%NOTFOUND;
                END LOOP;
              ELSE
                lrsample_name := frsample_name;
              END IF; -- IF frsample_name IS not NULL
              CLOSE get_sample_num;

              OPEN get_sample_num(l_sampling_events.sampling_event_id, 'A');
              FETCH get_sample_num
                into fasample_name; /* Get the first */

              IF fasample_name IS not NULL THEN
                LOOP
                  lasample_name    := sample_name_temp;
                  sample_name_temp := '';
                  FETCH get_sample_num
                    into sample_name_temp;
                  EXIT WHEN get_sample_num%NOTFOUND;
                END LOOP;
              ELSE
                lasample_name := fasample_name;
              END IF;
              CLOSE get_sample_num;

              OPEN get_reg_sample_num(l_sampling_events.sampling_event_id,
                                      null);
              FETCH get_reg_sample_num
                into fsample_name; /* Get the first */
              IF fsample_name is not NULL THEN
                LOOP
                  lsample_name     := sample_name_temp;
                  sample_name_temp := '';
                  FETCH get_reg_sample_num
                    into sample_name_temp;
                  exit when get_reg_sample_num%NOTFOUND;
                END LOOP;
              ELSE
                lsample_name := fsample_name;
              END IF;
              CLOSE get_reg_sample_num;

              IF (lrsample_name is not NULL) THEN
                FND_MESSAGE.SET_TOKEN('RESERVE_SAMPLES',
                                      frsample_name || '-' || lrsample_name);
              ELSE
                FND_MESSAGE.SET_TOKEN('RESERVE_SAMPLES', frsample_name);
              END IF;

              IF (lasample_name is not NULL) THEN
                FND_MESSAGE.SET_TOKEN('ARCHIVE_SAMPLES',
                                      fasample_name || '-' || lasample_name);
              ELSE
                FND_MESSAGE.SET_TOKEN('ARCHIVE_SAMPLES', fasample_name);
              END IF;

              IF (lsample_name is not NULL) THEN
                FND_MESSAGE.SET_TOKEN('RGULAR_SAMPLES',
                                      fsample_name || '-' || lsample_name);
              ELSE
                FND_MESSAGE.SET_TOKEN('RGULAR_SAMPLES', fsample_name);
              END IF;

            ELSE
              /* Sampling Event Successfully Created. Set Form Attribute
              to the sampling event */
              --RLNAGARA B5389806 Only passing sampling_event_id is not enough to create samples.
              --Here we need to pass another parameter called WF_SAMPLE which informs that the sample
              --is getting created from the workflow notification. Based on this only we take the sample
              --disposition as the disposition in the sampling events table otherwise if the WF_SAMPLE
              --is "N"(or NULL) (this will happen when we call samples form from other forms to create samples)
              --then we take the default disposition ie Pending to create the samples.

              --l_form := 'GMDQSMPL_EDIT_F:SAMPLING_EVENT_ID="'|| l_sampling_events.sampling_event_id||'"';
              l_form := 'GMDQSMPL_EDIT_F:SAMPLING_EVENT_ID="' ||
                        l_sampling_events.sampling_event_id ||
                        '" WF_SAMPLE="Y"';
            END IF;
            -- bug 4165704: not sure why this is here so I took it out?
            --RLNAGARA Uncommented the below line as this is necessary here because we have to show this message in the notification.
            l_sample_plan := FND_MESSAGE.GET();
          ELSE
            FND_MESSAGE.SET_NAME('GMD', 'GMD_SAMPLE_PLAN_NONE');
            l_sample_plan  := FND_MESSAGE.GET();
            l_sample_count := 1; -- incase there is no sample plan used

            /* Sampling Event Successfully Created. Set Form Attribute
            to the sampling event */
            --RLNAGARA B5389806 Only passing sampling_event_id is not enough to create samples.
            --Here we need to pass another parameter called WF_SAMPLE which informs that the sample
            --is getting created from the workflow notification. Based on this only we take the sample
            --disposition as the disposition in the sampling events table otherwise if the WF_SAMPLE
            --is "N"(or NULL) (this will happen when we call samples form from other forms to create samples)
            --then we take the default disposition ie Pending to create the samples.

            --l_form := 'GMDQSMPL_EDIT_F:SAMPLING_EVENT_ID="'|| l_sampling_events.sampling_event_id||'"';
            l_form := 'GMDQSMPL_EDIT_F:SAMPLING_EVENT_ID="' ||
                      l_sampling_events.sampling_event_id ||
                      '" WF_SAMPLE="Y"';
          END IF;
          CLOSE inv_sample_plan;

          IF ((l_auto_sample <> 'Y') or (l_doc_number <> 2)) THEN
            /* In the case where auto sample is not enabled, create event spec disp */
            /* Create Spec Event Disposition Row */
            l_event_spec_disp.SAMPLING_EVENT_ID            := l_sampling_events.sampling_event_id;
            l_event_spec_disp.SPEC_ID                      := l_spec_id;
            l_event_spec_disp.SPEC_VR_ID                   := l_spec_vr_id;
            l_event_spec_disp.DISPOSITION                  := '1P';
            l_event_spec_disp.SPEC_USED_FOR_LOT_ATTRIB_IND := NULL;
            l_event_spec_disp.DELETE_MARK                  := 0;
            l_event_spec_disp.CREATION_DATE                := sysdate;
            l_event_spec_disp.CREATED_BY                   := FND_GLOBAL.USER_ID;
            l_event_spec_disp.LAST_UPDATE_DATE             := sysdate;
            l_event_spec_disp.LAST_UPDATED_BY              := FND_GLOBAL.USER_ID;

            IF (l_debug = 'Y') THEN
              gmd_debug.put_line('Going to insert event spec disp');
            END IF;

            IF NOT
                GMD_EVENT_SPEC_DISP_PVT.insert_row(

                                                   p_event_spec_disp => l_event_spec_disp,
                                                   x_event_spec_disp => l_event_spec_disp_out) THEN
              gmd_debug.put_line('Sampling Event disposition Creation Failed'); -- Bug # 4576699
              RAISE FND_API.G_EXC_ERROR;
            END IF; --  IF NOT GMD_EVENT_SPEC_DISP_PVT.insert_row

            l_event_spec_disp := l_event_spec_disp_out;

            IF (l_debug = 'Y') THEN
              gmd_debug.put_line('Created event spec disp');
            END IF;

          END IF; /* End of check to create event spec for non-auto sample */

        ELSE
          gmd_debug.put_line('Could Not Find Specification'); -- Bug # 4576699
          --wf_log_pkg.string(6, 'Dummy','Could Not Find Specification');
          P_resultout := 'COMPLETE:NO_WORKFLOW';
          return;
        END IF;
      END IF;
      IF not l_valid_transaction THEN
        gmd_debug.put_line('No Valid Transctions'); /* 4576699 */
        /* No Valid Transctions */
        P_resultout := 'COMPLETE:NO_WORKFLOW';
        return;
      END IF;

      /* Get First Approver */
      /* Get application_id from FND_APPLICATION */
      -- Bug 4576699: Added cursor instead of 'select' statement here
      OPEN get_application_id; /* xxx4576699 */

      FETCH get_application_id
        INTO l_application_id;

      IF (get_application_id%NOTFOUND) THEN
        CLOSE get_application_id;

        RAISE no_application_id_found;
      END IF;
      CLOSE get_application_id;

      AME_API.CLEARALLAPPROVALS(applicationIdIn   => l_application_id,
                                transactionIdIn   => l_event_key,
                                transactionTypeIn => l_transaction_type);

      l_log := 'Approvers Cleared';
      AME_API.GETNEXTAPPROVER(applicationIdIn   => l_application_id,
                              transactionIdIn   => l_event_key,
                              transactionTypeIn => l_transaction_type,
                              nextApproverOut   => Approver);

      IF (Approver.user_id is null and Approver.person_id is null) THEN
        gmd_debug.put_line('No Approval Required 1'); /* 4576699 */

        /* No Approval Required */
        P_resultout := 'COMPLETE:NO_WORKFLOW';
        return;
      END IF;

      IF (Approver.person_id is null) THEN
        OPEN get_user_name(approver.user_id); /* 4576699 */

        FETCH get_user_name
          INTO l_user;

        IF (get_user_name%NOTFOUND) THEN
          CLOSE get_user_name;
          RAISE no_user_name_found;
        END IF;

        CLOSE get_user_name;

      ELSE
        OPEN get_user_name(ame_util.personidtouserid(approver.person_id)); /* 4576699 */
        FETCH get_user_name
          INTO l_user;

        IF (get_user_name%NOTFOUND) THEN
          CLOSE get_user_name;

          RAISE no_user_name_found;
        END IF;

        CLOSE get_user_name;

      END IF;

      /* Set the User Attribute */
      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'CURRENT_APPROVER',
                                avalue   => l_user);
      /* Set All other Attributes */

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'APPS_FORM',
                                avalue   => l_form);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'ITEM_NUMBER',
                                avalue   => l_ITEM_NUMBER);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'ITEM_REVISION',
                                avalue   => l_REVISION);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'ITEM_DESC',
                                avalue   => l_item_desc);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARENT_LOT',
                                avalue   => l_parent_lot_number);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'LOT_NUMBER',
                                avalue   => l_lot_number);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'ORGANIZATION_CODE',
                                avalue   => l_ORGANIZATION_CODE);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'SUBINVENTORY',
                                avalue   => l_subinventory);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'LOCATOR',
                                avalue   => l_locator);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'DOC_TYPE',
                                avalue   => l_doc_type);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'DOCUMENT_NO',
                                avalue   => l_doc_number); -- where does doc no come from???
      -- Bug #3473230 (JKB) Added doc_no above.
      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'DOC_DESC',
                                avalue   => l_transaction_type_name);

      WF_ENGINE.SETITEMATTRNUMBER(itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'TRANS_QTY',
                                  avalue   => l_trans_qty);

      WF_ENGINE.SETITEMATTRNUMBER(itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'TRANS_QTY2',
                                  avalue   => l_trans_qty2);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'TRANS_UOM',
                                avalue   => l_trans_qty_uom);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'TRANS_UOM2',
                                avalue   => l_trans_qty_uom2);

      --RLNAGARA B4905645 Changed SETITEMATTRDATE with SETITEMATTRTEXT for retest and expiry dates.
      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'RETEST_DATE',
                                avalue   => l_retest_date);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'EXPIRY_DATE',
                                avalue   => l_expiry_date);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PURCHASE_NO',
                                avalue   => l_purchase_no);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'SUPPLIER_NO',
                                avalue   => l_vendor_no);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'RECEIPT_NO',
                                avalue   => l_receipt_no);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'SAMPLING_PLAN',
                                avalue   => l_sample_plan);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => '#FROM_ROLE',
                                avalue   => l_from_role);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'AME_TRANS',
                                avalue   => l_transaction_type);

      --RLNAGARA B5018797 Added this as Operting Unit is added to the Notification also.

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'OPERATING_UNIT',
                                avalue   => l_operating_unit);

      --RLNAGARA Bug5334308
      WF_ENGINE.SETITEMATTRNUMBER(itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'LOT_QTY',
                                  avalue   => l_lot_qty);

      WF_ENGINE.SETITEMATTRNUMBER(itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'LOT_QTY2',
                                  avalue   => l_lot_qty2);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'LOT_UOM',
                                avalue   => l_trans_qty_uom);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'LOT_UOM2',
                                avalue   => l_trans_qty_uom2);

      /* As this a pure FYI notification we will set the approver to approve status */
      Approver.approval_status := AME_UTIL.APPROVEDSTATUS;
      AME_API.UPDATEAPPROVALSTATUS(applicationIdIn   => l_application_id,
                                   transactionIdIn   => l_event_key,
                                   approverIn        => Approver,
                                   transactionTypeIn => l_transaction_type,
                                   forwardeeIn       => AME_UTIL.EMPTYAPPROVERRECORD);
    END IF;

    P_resultout := 'COMPLETE:' || l_transaction_type;

    -- Bug 4576699: added Exceptions besides OTHERS
  EXCEPTION
    WHEN no_vendor_found THEN
      gmd_debug.put_line('Vendor Number not found');
    WHEN no_application_id_found THEN
      gmd_debug.put_line('Application Id not found');
    WHEN no_user_name_found THEN
      gmd_debug.put_line('User Name not found');
    WHEN OTHERS THEN
      wf_core.CONTEXT('GMD_QMSMC',
                      'VERIFY_EVENT',
                      p_itemtype,
                      p_itemkey,
                      l_log);
      RAISE;
  END VERIFY_EVENT;

  /* procedure check next approver */
  PROCEDURE CHECK_NEXT_APPROVER(p_itemtype  IN VARCHAR2,
                                p_itemkey   IN VARCHAR2,
                                p_actid     IN NUMBER,
                                p_funcmode  IN VARCHAR2,
                                p_resultout OUT NOCOPY VARCHAR2)

   IS
    l_event_name varchar2(240) := WF_ENGINE.GETITEMATTRTEXT(itemtype => p_itemtype,
                                                            itemkey  => P_itemkey,
                                                            aname    => 'EVENT_NAME');

    l_event_key varchar2(240) := WF_ENGINE.GETITEMATTRTEXT(itemtype => p_itemtype,
                                                           itemkey  => P_itemkey,
                                                           aname    => 'EVENT_KEY');

    l_current_approver varchar2(240);

    l_application_id        number;
    l_transaction_type      varchar2(100) := WF_ENGINE.GETITEMATTRTEXT(itemtype => p_itemtype,
                                                                       itemkey  => P_itemkey,
                                                                       aname    => 'AME_TRANS');
    l_user                  varchar2(32);
    Approver                AME_UTIL.APPROVERRECORD;
    l_ITEM_NUMBER           varchar2(240);
    l_item_desc             varchar2(240);
    l_lot_number            varchar2(240);
    l_parent_lot_number     varchar2(240);
    l_sample_no             varchar2(240);
    l_sample_plan           varchar2(240);
    l_sample_disposition    varchar2(240);
    l_sample_source         varchar2(240);
    l_specification         varchar2(240);
    l_validity_rule         varchar2(240);
    l_validity_rule_version varchar2(240);
    l_sample_event_text     varchar2(4000);
    l_sampling_event_id     number;
    l_form                  varchar2(240);
    l_log                   varchar2(4000);
  BEGIN

    /* Get Next Approver */
    /* Get application_id from FND_APPLICATION */
    select application_id
      into l_application_id
      from fnd_application
     where application_short_name = 'GMD';

    AME_API.GETNEXTAPPROVER(applicationIdIn   => l_application_id,
                            transactionIdIn   => l_event_key,
                            transactionTypeIn => l_transaction_type,
                            nextApproverOut   => Approver);

    IF (Approver.user_id is null and Approver.person_id is null) THEN
      /* No Approval Required */
      P_resultout := 'COMPLETE:N';
    ELSE
      IF (Approver.person_id is null) THEN
        select user_name
          into l_user
          from fnd_user
         where user_id = Approver.user_id;
      ELSE
        select user_name
          into l_user
          from fnd_user
         where user_id = AME_UTIL.PERSONIDTOUSERID(Approver.person_id);
      END IF;

      /* Set the User Attribute */

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'CURRENT_APPROVER',
                                avalue   => l_user);

      P_resultout              := 'COMPLETE:Y';
      Approver.approval_status := AME_UTIL.APPROVEDSTATUS;
      AME_API.UPDATEAPPROVALSTATUS(applicationIdIn   => l_application_id,
                                   transactionIdIn   => l_event_key,
                                   approverIn        => Approver,
                                   transactionTypeIn => l_transaction_type,
                                   forwardeeIn       => AME_UTIL.EMPTYAPPROVERRECORD);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.CONTEXT('GMD_QMSMC',
                      'CHECK_NEXT_APPROVER',
                      p_itemtype,
                      p_itemkey,
                      l_log);
      raise;

  END CHECK_NEXT_APPROVER;

  /* Production Procedure */
  PROCEDURE PRODUCTION(p_itemtype  IN VARCHAR2,
                       p_itemkey   IN VARCHAR2,
                       p_actid     IN NUMBER,
                       p_funcmode  IN VARCHAR2,
                       p_resultout OUT NOCOPY VARCHAR2)

   IS
    l_event_name varchar2(240) := WF_ENGINE.GETITEMATTRTEXT(itemtype => p_itemtype,
                                                            itemkey  => P_itemkey,
                                                            aname    => 'EVENT_NAME');

    l_event_key varchar2(240) := WF_ENGINE.GETITEMATTRTEXT(itemtype => p_itemtype,
                                                           itemkey  => P_itemkey,
                                                           aname    => 'EVENT_KEY');

    Approver              AME_UTIL.APPROVERRECORD;
    L_WIP_SPEC            GMD_SPEC_MATCH_GRP.WIP_SPEC_REC_TYPE;
    L_SAMPLING_EVENTS     GMD_SAMPLING_EVENTS%ROWTYPE;
    l_sampling_events_out GMD_SAMPLING_EVENTS%ROWTYPE;
    l_event_spec_disp     GMD_EVENT_SPEC_DISP%ROWTYPE;
    l_event_spec_disp_out GMD_EVENT_SPEC_DISP%ROWTYPE;
    quality_config        GMD_QUALITY_CONFIG%ROWTYPE;

    l_current_approver  varchar2(240);
    l_ITEM_NUMBER       varchar2(240);
    l_item_desc         varchar2(240);
    l_lot_number        varchar2(240);
    l_parent_lot_number varchar2(240);
    L_RECIPE_NO         varchar2(240);
    L_FORMULA_NO        varchar2(240);
    L_ROUTING_NO        varchar2(240);
    L_OPRN_NO           varchar2(240);
    L_FORM              varchar2(240);
    l_itemtype          varchar2(240);
    l_itemkey           varchar2(240);
    l_workflow_process  varchar2(240);
    X_batch_id          varchar2(240);
    X_batch_step_id     varchar2(240);
    t_batch_id          varchar2(240);
    t_batch_step_id     varchar2(240);
    l_sample_count      varchar2(240);
    l_sample_qty        varchar2(240);
    l_sample_qty_uom    varchar2(240);
    l_frequency_count   varchar2(240);
    l_frequency_per     varchar2(240);
    l_frequency_type    varchar2(240);
    message             varchar2(200);
    l_reserve_cnt_req   varchar2(240);
    l_reserve_qty       varchar2(240);
    l_archive_cnt_req   varchar2(240);
    l_archive_qty       varchar2(240);
    l_revision          varchar2(240);
    l_spec_name         varchar2(240); -- RLNAGARA Bug 5032406 (FP of 4604305 ME)

    L_BATCH_NO      varchar2(32);
    L_EXACT_MATCH   varchar2(1);
    L_RETURN_STATUS varchar2(100);

    l_log             varchar2(4000);
    l_sample_plan     varchar2(4000);
    l_sample_plan_out varchar2(4000);
    L_Msg_DATA        varchar2(2000);

    l_auto_sample varchar2(1);
    create_status varchar2(20);

    sample_name_temp varchar2(100) := '';
    fsample_name     varchar2(500) := '';
    frsample_name    varchar2(500) := '';
    fasample_name    varchar2(500) := '';
    lsample_name     varchar2(500) := '';
    lrsample_name    varchar2(500) := '';
    lasample_name    varchar2(500) := '';
    l_from_role      varchar2(500);

    L_ORGANIZATION_CODE varchar2(240) := NULL;
    l_subinventory      varchar2(240) := NULL;
    l_locator           varchar2(240) := NULL;

    L_GRADE            varchar2(150);
    l_transaction_type varchar2(100);
    l_user             varchar2(32);

    l_sampling_event_id  number;
    l_application_id     number;
    l_locator_id         number;
    L_inventory_ITEM_ID  number;
    L_ORGANIZATION_ID    number;
    L_BATCH_ID           number;
    L_RECIPE_ID          number;
    L_FORMULA_ID         number;
    L_FORMULALINE_ID     number;
    L_MATERIAL_DETAIL_ID number;
    L_STEP_ID            number;
    L_STEP_NO            number;
    L_OPRN_ID            number;
    L_ROUTING_ID         number;

    L_FORMULA_VERS       number(5);
    L_ROUTING_VERS       number(5);
    L_RECIPE_VERSION     number(5);
    L_OPRN_VERS          number(5);
    L_CHARGE             number;
    L_SPEC_ID            number;
    L_SPEC_VR_ID         number;
    l_sample_plan_id     number;
    x_temp               number;
    dummy                number;
    l_last_update_by     number;
    l_doc_number         number;
    l_spec_vers          number; -- RLNAGARA Bug 5032406 (FP of 4604305 ME)
    l_sample_plan_exists number := 0;

    L_DATE_EFFECTIVE DATE;
    l_orgn_found     BOOLEAN;
    b                NUMBER; --RLNAGARA Bug 5910300

    CURSOR wip_sample_plan(X_SPEC_VR_ID NUMBER) IS
      SELECT nvl(sample_cnt_req, 0) sample_cnt_req,
             nvl(sample_qty, 0) sample_qty,
             sample_qty_uom,
             frequency_cnt,
             frequency_per,
             sm.sampling_plan_id,
             frequency_type,
             nvl(RESERVE_CNT_REQ, 0) reserve_cnt_req,
             nvl(RESERVE_QTY, 0) reserve_qty,
             nvl(ARCHIVE_CNT_REQ, 0) archive_cnt_req,
             nvl(ARCHIVE_QTY, 0) archive_qty
        FROM gmd_sampling_plans_b sm, gmd_wip_spec_vrs sv
       WHERE sv.sampling_plan_id = sm.sampling_plan_id
         AND sv.spec_vr_id = X_SPEC_VR_ID;

    CURSOR wip_sample_plan_freq_per(x_frequency_per varchar2) IS
      SELECT meaning
        FROM gem_lookups
       WHERE lookup_type = 'GMD_QC_FREQUENCY_PERIOD'
         AND lookup_code = x_frequency_per;

    CURSOR get_sampling_plan_id(x_spec_vr_id_in number) IS
      SELECT sampling_plan_id
        FROM gmd_com_spec_vrs_vl --gmd_all_spec_vrs performance bug# 4916912
       WHERE spec_vr_id = x_spec_vr_id_in;

    -- Bug 5391632: added cursor below to get locator
    CURSOR Cur_locator(loc_id NUMBER) IS
      SELECT concatenated_segments
        FROM mtl_item_locations_kfv
       WHERE inventory_location_id = loc_id;

    /* RLNAGARA Bug 5032406 (FP of 4604305 ME)  added cursor to get spec name and version */
    CURSOR get_spec_name(x_spec_id_in NUMBER) IS
      SELECT spec_name, spec_vers
        FROM gmd_specifications_b
       WHERE spec_id = x_spec_id_in;

    /* This cursor works for both batch created and batchstep created event */
    -- Bug 4165704: 1. a.wip_subinventory taken out since it no longer exists in gme_batch_header
    --              2. a.revision added
    CURSOR C1(x_batch_id varchar2, x_batch_step_id varchar2) is
      SELECT A.BATCH_NO,
             A.BATCH_ID,
             A.ORGANIZATION_ID,
             P.ORGANIZATION_CODE,
             A.ROUTING_ID,
             C.RECIPE_ID,
             A.FORMULA_ID,
             A.ROUTING_ID,
             F.INVENTORY_ITEM_ID,
             F.REVISION,
             F.FORMULALINE_ID,
             F.MATERIAL_DETAIL_ID,
             F.LOCATOR_ID, --RLNAGARA B5389806
             F.SUBINVENTORY, --RLNAGARA B5389806
             to_number(NULL) BATCHSTEP_ID,
             to_number(NULL) BATCHSTEP_NO,
             to_number(NULL) OPRN_ID,
             C.RECIPE_NO || ' / ' || C.RECIPE_VERSION,
             H.FORMULA_NO || ' / ' || FORMULA_VERS,
             I.CONCATENATED_SEGMENTS,
             I.DESCRIPTION ITEM_DESC1,
             A.LAST_UPDATED_BY
        FROM GME_BATCH_HEADER          A,
             GMD_RECIPE_VALIDITY_RULES b,
             GMD_RECIPES_B             C, --GMD_RECIPES C performance bug# 4916912
             GME_MATERIAL_DETAILS      F,
             FM_FORM_MST_B             H, --FM_FORM_MST H performance bug# 4916912
             MTL_PARAMETERS            P,
             MTL_SYSTEM_ITEMS_B_KFV    I
       WHERE A.BATCH_ID = x_batch_id
         AND A.BATCH_ID = F.BATCH_ID
         AND A.RECIPE_VALIDITY_RULE_ID = B.RECIPE_VALIDITY_RULE_ID
         AND B.RECIPE_ID = C.RECIPE_ID
         AND NVL(x_batch_step_id, 1) = 1
         AND F.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
         AND H.FORMULA_ID = A.FORMULA_ID
         AND F.LINE_TYPE = 1 /*Bug#6638743*/
         AND P.ORGANIZATION_ID = A.ORGANIZATION_ID
         AND (B.ORGANIZATION_ID = A.ORGANIZATION_ID OR
             B.ORGANIZATION_ID IS NULL)
         AND -- PK Bug 6595576
             I.ORGANIZATION_ID = A.ORGANIZATION_ID
         AND F.ORGANIZATION_ID = A.ORGANIZATION_ID
      UNION
      SELECT A.BATCH_NO,
             A.BATCH_ID,
             A.ORGANIZATION_ID,
             P.ORGANIZATION_CODE,
             A.ROUTING_ID,
             C.RECIPE_ID,
             A.FORMULA_ID,
             A.ROUTING_ID,
             F.INVENTORY_ITEM_ID,
             F.REVISION,
             F.FORMULALINE_ID,
             F.MATERIAL_DETAIL_ID,
             F.LOCATOR_ID, --RLNAGARA B5389806
             F.SUBINVENTORY, --RLNAGARA B5389806
             D.BATCHSTEP_ID,
             D.BATCHSTEP_NO BATCHSTEP_NO,
             D.OPRN_ID,
             C.RECIPE_NO || ' / ' || C.RECIPE_VERSION,
             H.FORMULA_NO || ' / ' || FORMULA_VERS,
             I.CONCATENATED_SEGMENTS ITEM_NUMBER,
             I.DESCRIPTION,
             A.LAST_UPDATED_BY
        FROM GME_BATCH_HEADER          A,
             GMD_RECIPE_VALIDITY_RULES b,
             GMD_RECIPES_B             C, --GMD_RECIPES C performance bug# 4916912
             GME_BATCH_STEPS           D,
             GME_MATERIAL_DETAILS      F,
             FM_FORM_MST_B             H, --FM_FORM_MST H performance bug# 4916912
             MTL_PARAMETERS            P,
             MTL_SYSTEM_ITEMS_B_KFV    I
       WHERE A.BATCH_ID = x_batch_id
         AND A.BATCH_ID = F.BATCH_ID
         AND A.BATCH_ID = D.BATCH_ID
         AND A.RECIPE_VALIDITY_RULE_ID = B.RECIPE_VALIDITY_RULE_ID
         AND B.RECIPE_ID = C.RECIPE_ID
         AND D.BATCHSTEP_ID = x_batch_step_id
         AND --RLNAGARA Bug 5032406 (FP of 4604305 ME) For batch creation, do not select steps
             F.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
         AND H.FORMULA_ID = A.FORMULA_ID
         AND P.ORGANIZATION_ID = A.ORGANIZATION_ID
         AND F.ORGANIZATION_ID = A.ORGANIZATION_ID
         AND (B.ORGANIZATION_ID = A.ORGANIZATION_ID OR
             B.ORGANIZATION_ID IS NULL)
         AND -- PK Bug 6595576
             I.ORGANIZATION_ID = A.ORGANIZATION_ID
         AND F.LINE_TYPE = 1 /*Bug#6638743*/
       ORDER by BATCHSTEP_NO DESC;

    /* Cursors to check if Spec VR has auto enable flag enabled */
    CURSOR wip_auto_sample(X_SPEC_VR_ID number) is
      select nvl(auto_sample_ind, 'N')
        from GMD_WIP_SPEC_VRS
       where spec_vr_id = X_SPEC_VR_ID;

    /* Given a sampling event and a retain as, gets the sample numbers */
    CURSOR get_sample_num(x_sampling_event_in number, x_retain_as varchar2) is
      select sample_no
        from gmd_Samples
       where sampling_event_id = x_Sampling_event_in
         and retain_as = x_retain_as;

    CURSOR get_reg_sample_num(x_sampling_event_in number, x_retain_as_in varchar2) is
      select sample_no
        from gmd_Samples
       where sampling_event_id = x_Sampling_event_in
         and retain_as is NULL;

    CURSOR get_from_role is
      select nvl(text, '')
        from wf_Resources
       where name = 'WF_ADMIN_ROLE' --RLNAGARA B5654562 Changed from WF_ADMIN to WF_ADMIN_ROLE
         and language = userenv('LANG');

     /* Bug No.8942353 - Start */
   CURSOR Cur_pending_lot(x_material_detail_id number) is
       select mln.lot_number, mln.parent_lot_number
       from mtl_lot_numbers mln
       where lot_number =
        (select lot_number
          from GME_PENDING_PRODUCT_LOTS
         where material_detail_id = x_material_detail_id
           and pending_product_lot_id =
               (select min(pending_product_lot_id)
                  from GME_PENDING_PRODUCT_LOTS
                 where material_detail_id = x_material_detail_id));

       l_pending_parent_lot  varchar2(240) := NULL ;
       l_pending_lot   varchar2(240) := NULL ;

       /* Bug No.8942353 - End */

  BEGIN
    --gml_sf_log('start proc PRODUCTION and event='||l_event_name);

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('Event name ' || l_event_name);
      gmd_debug.put_line('Event key ' || l_Event_key);
    END IF;

    OPEN get_from_role;
    FETCH get_from_role
      into l_from_role;
    CLOSE get_from_role;

    IF P_FUNCMODE = 'RUN' THEN
      /* Get application_id from FND_APPLICATION */
      SELECT application_id
        INTO l_application_id
        FROM fnd_application
       WHERE application_short_name = 'GMD';

      /*************************************/
      /* Check which event has been raised */
      /*************************************/
      --  wf_log_pkg.string( 6,
      --                     'Dummy',
      --                     'Entered Production Transaction with event_key '||l_event_key
      --                    );

      IF l_event_name = 'oracle.apps.gme.batch.created' THEN
        l_transaction_type := 'PRODUCTION_TRANSACTION';
        t_batch_id         := l_Event_key;
        t_batch_step_id    := NULL;

      ELSIF l_event_name = 'oracle.apps.gme.batchstep.created' THEN
        SELECT BATCH_ID
          INTO t_batch_id
          FROM gme_batch_steps
         WHERE batchstep_id = l_event_key;

        l_transaction_type := 'PRODUCTION_TRANSACTION';
        t_batch_step_id    := l_event_key;
        l_Event_key        := t_batch_id;

      ELSIF l_event_name = 'oracle.apps.gme.bstep.rel.wf' THEN
        SELECT BATCH_ID
          INTO t_batch_id
          FROM gme_batch_steps
         WHERE batchstep_id = l_event_key;

        l_transaction_type := 'BATCHRELEASE_TRANSACTION';
        t_batch_step_id    := l_event_key;
        l_Event_key        := t_batch_id;
      END IF;

      gmd_p_fs_context.set_additional_attr; /* Added in Bug No.9024801 */

      /*Figure out if all the batch_steps are covered for sample creation */
      OPEN C1(t_batch_id, t_batch_step_id);
      LOOP
        FETCH C1
          INTO L_BATCH_NO, L_BATCH_ID, L_ORGANIZATION_ID, L_ORGANIZATION_CODE, L_ROUTING_ID, L_RECIPE_ID, L_FORMULA_ID, L_ROUTING_ID, L_INVENTORY_ITEM_ID, L_REVISION, L_FORMULALINE_ID, L_MATERIAL_DETAIL_ID, l_locator_id, --RLNAGARA B5389806
        l_subinventory, --RLNAGARA B5389806
        L_STEP_ID, L_STEP_NO, L_OPRN_ID, L_RECIPE_NO, L_FORMULA_NO, L_ITEM_NUMBER, L_ITEM_DESC, L_LAST_UPDATE_BY;

        EXIT WHEN C1%NOTFOUND;

        /* Material Details found Proceed for Finding the spec */
        l_wip_spec.organization_id   := L_organization_id;
        l_wip_spec.inventory_item_id := L_inventory_item_id;
        l_wip_spec.revision          := L_revision;
        l_wip_spec.batch_id          := L_batch_id;
        l_wip_spec.recipe_id         := L_recipe_id;
        l_wip_spec.formula_id        := L_formula_id;
        l_wip_spec.routing_id        := L_routing_id;
        l_wip_spec.step_id           := L_step_id;
        l_wip_spec.step_no           := L_step_no;
        l_wip_spec.oprn_id           := L_oprn_id;
        l_wip_spec.charge            := NULL;
        l_wip_spec.date_effective    := SYSDATE;
        l_wip_spec.exact_match       := 'N';

        -- bug 4640143: if batch id exists then material detail id is used
        IF l_batch_id IS NOT NULL THEN
          l_wip_spec.material_detail_id := L_material_detail_id;
        ELSE
          l_wip_spec.formulaline_id := L_formulaline_id;
        END IF;

        /* Bug No.7032231 - Commented the following code as it is not supporting to get spec details  */

        /*  IF l_Event_name in ('oracle.apps.gme.batchstep.created',
                            'oracle.apps.gme.bstep.rel.wf') THEN
             l_wip_spec.find_spec_with_step          := 'Y';
        ELSE
             l_wip_spec.find_spec_with_step          := 'N';
        END IF; */

        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('Checking for WIP Spec ');
        END IF;

        IF GMD_SPEC_MATCH_GRP.FIND_WIP_SPEC(p_wip_spec_rec  => l_wip_spec,
                                            x_spec_id       => l_spec_id,
                                            x_spec_vr_id    => l_spec_vr_id,
                                            x_return_status => l_return_status,
                                            x_message_data  => l_msg_data) THEN

          IF (l_debug = 'Y') THEN
            gmd_debug.put_line('WIP Spec Found: ' || l_Spec_id || ' ' ||
                               l_spec_vr_id);
          END IF;

          /* RLNAGARA Bug 5032406 (FP of 4604305 ME) Assigning values to l_spec_name and l_spec_vers */
          OPEN get_spec_name(l_spec_id);
          FETCH get_spec_name
            INTO l_spec_name, l_spec_vers;
          CLOSE get_spec_name;

          -- 5391632
          IF l_locator_id IS NOT NULL THEN
            OPEN Cur_locator(l_locator_id);
            FETCH Cur_locator
              INTO l_locator;
            CLOSE Cur_locator;
          END IF; -- l_locator_id is not null

          OPEN get_sampling_plan_id(l_spec_vr_id);
          FETCH get_sampling_plan_id
            into l_sample_plan_id;
          CLOSE get_sampling_plan_id;

          OPEN wip_sample_plan(l_spec_vr_id);
          FETCH wip_sample_plan
            into l_sample_count, l_sample_qty, l_sample_qty_uom, l_frequency_count, l_frequency_per, l_sample_plan_id, l_frequency_type, l_reserve_cnt_req, l_reserve_qty, l_archive_cnt_req, l_archive_qty;

          IF wip_sample_plan%found THEN
            -- 4165704: added l_sample_plan_exists here so I could uncomment 'CLOSE wip_sample_plan' below
            l_sample_plan_exists := 1;
          ELSE
            l_sample_count := 1;
          END IF;

          CLOSE wip_sample_plan;

          /*****************************/
          /* Specification Found       */
          /* Create the Sampling Event */
          /*****************************/
          --RLNAGARA B5389806 Added the below IF-ELSE-ENDIF condition.
          IF l_Event_name in ('oracle.apps.gme.batchstep.created',
              'oracle.apps.gme.batch.created') THEN
            l_sampling_events.disposition := '0PL';
          ELSE
            l_sampling_events.disposition := '1P';
          END IF;

          l_sampling_events.original_spec_vr_id := l_spec_vr_id;
          l_sampling_events.sampling_plan_id    := l_sample_plan_id;
          l_sampling_events.source              := 'W';
          l_sampling_events.inventory_item_id   := l_inventory_item_id;
          l_sampling_events.revision            := l_revision;
          l_sampling_events.sample_req_cnt      := l_sample_count;
          l_sampling_events.sample_taken_cnt    := 0;
          l_sampling_events.batch_ID            := l_batch_id;
          l_sampling_events.recipe_id           := l_recipe_id; /*Bug 3378697*/
          l_sampling_events.formula_id          := l_formula_id;
          l_sampling_events.formulaline_id      := l_formulaline_id;
          l_sampling_events.material_detail_id  := l_material_detail_id; -- Bug 4640143 added this
          l_sampling_events.routing_id          := l_routing_id;
          l_sampling_events.subinventory        := l_subinventory;
          l_sampling_events.locator_id          := l_locator_id;

          l_sampling_events.step_id          := l_step_id;
          l_sampling_events.step_no          := l_step_no;
          l_sampling_events.oprn_id          := l_oprn_id;
          l_sampling_events.sample_type      := 'I';
          l_sampling_events.organization_id  := L_organization_id;
          l_sampling_events.CREATION_DATE    := SYSDATE;
          l_sampling_events.CREATED_BY       := FND_GLOBAL.USER_ID;
          l_sampling_events.LAST_UPDATED_BY  := FND_GLOBAL.USER_ID;
          l_sampling_events.LAST_UPDATE_DATE := SYSDATE;
          --wf_log_pkg.string(6, 'Dummy','Before Creating the Sampling Event');

          /* Bug No.8942353 - Start */
          IF (l_material_detail_id IS NOT NULL) THEN
             OPEN Cur_pending_lot(l_material_detail_id);
             FETCH Cur_pending_lot
                   INTO l_pending_parent_lot, l_pending_lot;
                   l_sampling_events.PARENT_LOT_NUMBER  := l_pending_lot;
                   l_sampling_events.LOT_NUMBER := l_pending_parent_lot;
             CLOSE Cur_pending_lot;
          END IF;
           /* Bug No.8942353 - End */

          IF NOT
              GMD_SAMPLING_EVENTS_PVT.insert_row(p_sampling_events => l_sampling_events,
                                                 x_sampling_events => l_sampling_events_out) THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          l_sampling_events := l_sampling_events_out;

          /* Check to see if auto Sample Creation is enabled for this Spec VR */
          OPEN wip_auto_sample(l_spec_vr_id);
          FETCH wip_auto_sample
            into l_auto_Sample;
          CLOSE wip_auto_sample;

          GMD_QUALITY_PARAMETERS_GRP.get_quality_parameters(p_organization_id    => l_organization_id,
                                                            x_quality_parameters => quality_config,
                                                            x_return_status      => l_return_status,
                                                            x_orgn_found         => l_orgn_found);

          IF (l_return_status <> 'S') THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          l_doc_number := quality_config.sample_assignment_type;
          IF (l_debug = 'Y') THEN
            gmd_debug.put_line('Auto sample flag: ' || l_auto_sample);
          END IF;

          -- Bug 4165704: took out reference to wip_sample_plan cursor and put in l_sample_plan_exists
          IF l_sample_plan_exists = 1 THEN
            FND_MESSAGE.SET_NAME('GMD', 'GMD_SAMPLE_PLAN_INFO');
            FND_MESSAGE.SET_TOKEN('SAMPLE_NO', l_sample_count);
            FND_MESSAGE.SET_TOKEN('SAMPLE_QTY', l_sample_qty);
            FND_MESSAGE.SET_TOKEN('SAMPLE_UOM', l_sample_qty_uom); --RLNAGARA B4905670
            FND_MESSAGE.SET_TOKEN('FREQ_CNT', l_frequency_count);
            FND_MESSAGE.SET_TOKEN('ASAMPLE_NO', l_archive_cnt_req);
            FND_MESSAGE.SET_TOKEN('ASAMPLE_QTY', l_archive_qty);
            FND_MESSAGE.SET_TOKEN('RSAMPLE_NO', l_reserve_cnt_req);
            FND_MESSAGE.SET_TOKEN('RSAMPLE_QTY', l_reserve_qty);
            FND_MESSAGE.SET_TOKEN('RESERVE_SAMPLES', frsample_name);
            FND_MESSAGE.SET_TOKEN('ARCHIVE_SAMPLES', fasample_name);
            FND_MESSAGE.SET_TOKEN('RGULAR_SAMPLES', fsample_name);

            --RLNAGARA Bug 5910300 start
            IF (l_frequency_type = 'F') THEN
              UPDATE GMD_WIP_SPEC_VRS
                 SET BATCH_FREQUENCY = NVL(BATCH_FREQUENCY, 0) + 1 --RLNAGARA Bug 5910300 Rework Added NVL
               WHERE SPEC_VR_ID = l_spec_vr_id;
              select batch_frequency
                into b
                from gmd_wip_spec_vrs
               where spec_vr_id = l_spec_vr_id;

              IF b <> l_frequency_count THEN
                p_resultout := 'COMPLETE:';
                RETURN;
              ELSE
                UPDATE GMD_WIP_SPEC_VRS
                   SET BATCH_FREQUENCY = 0
                 WHERE SPEC_VR_ID = l_spec_vr_id;
                l_sampling_events.sample_req_cnt := l_sample_count;
              END IF;
              --RLNAGARA Bug 5910300 end
            ELSIF (l_frequency_type <> 'Q') THEN
              OPEN wip_sample_plan_freq_per(l_frequency_per);
              FETCH wip_sample_plan_freq_per
                into l_frequency_per;
              CLOSE wip_sample_plan_freq_per;
            END IF;

            FND_MESSAGE.SET_TOKEN('FREQ_PER', l_frequency_per);

            /* Check to see if auto sample creation is enabled */
            IF ((l_auto_sample = 'Y') and (l_doc_number = 2)) THEN
              GMD_AUTO_SAMPLE_PKG.create_samples(l_sampling_events,
                                                 l_spec_id,
                                                 l_spec_vr_id,
                                                 create_status);
              /* Sampling Event Successfully Created. Set Form Attribute
              to the sampling event */
              l_form := 'GMDQSAMPLES_F:SAMPLING_EVENT_ID="' ||
                        l_sampling_events.sampling_event_id || '"';

              /* If we created samples, show them */
              /* get the reserve sample names*/
              OPEN get_sample_num(l_sampling_events.sampling_event_id, 'R');
              FETCH get_sample_num
                into frsample_name; /* Get the first */

              IF frsample_name is not NULL THEN
                LOOP
                  lrsample_name    := sample_name_temp;
                  sample_name_temp := '';
                  FETCH get_sample_num
                    into sample_name_temp;
                  EXIT WHEN get_sample_num%NOTFOUND;
                END LOOP;
              ELSE
                lrsample_name := frsample_name;
              END IF;
              CLOSE get_sample_num;

              /* get the archive sample names*/
              OPEN get_sample_num(l_sampling_events.sampling_event_id, 'A');
              FETCH get_sample_num
                into fasample_name; /* Get the first */

              IF fasample_name is not NULL THEN
                LOOP
                  lasample_name    := sample_name_temp;
                  sample_name_temp := '';
                  FETCH get_sample_num
                    into sample_name_temp;
                  EXIT WHEN get_sample_num%NOTFOUND;
                END LOOP;
              ELSE
                lasample_name := fasample_name;
              END IF;
              CLOSE get_sample_num;

              /* get the sample names*/
              OPEN get_reg_sample_num(l_sampling_events.sampling_event_id,
                                      null);
              FETCH get_reg_sample_num
                into fsample_name; /* Get the first */

              IF fsample_name is not NULL THEN
                LOOP
                  lsample_name     := sample_name_temp;
                  sample_name_temp := '';
                  FETCH get_reg_sample_num
                    into sample_name_temp;
                  exit when get_reg_sample_num%NOTFOUND;
                END LOOP;
              ELSE
                lsample_name := fsample_name;
              END IF;
              CLOSE get_reg_sample_num;

              IF (lrsample_name is not NULL) THEN
                FND_MESSAGE.SET_TOKEN('RESERVE_SAMPLES',
                                      frsample_name || '-' || lrsample_name);
              ELSE
                FND_MESSAGE.SET_TOKEN('RESERVE_SAMPLES', frsample_name);
              END IF;

              IF (lasample_name is not NULL) THEN
                FND_MESSAGE.SET_TOKEN('ARCHIVE_SAMPLES',
                                      fasample_name || '-' || lasample_name);
              ELSE
                FND_MESSAGE.SET_TOKEN('ARCHIVE_SAMPLES', fasample_name);
              END IF;

              IF (lsample_name is not NULL) THEN
                FND_MESSAGE.SET_TOKEN('RGULAR_SAMPLES',
                                      fsample_name || '-' || lsample_name);
              ELSE
                FND_MESSAGE.SET_TOKEN('RGULAR_SAMPLES', fsample_name);
              END IF;

            ELSE
              /* Sampling Event Successfully Created. Set Form Attribute
              to the sampling event */
              --RLNAGARA B5389806 Only passing sampling_event_id is not enough to create samples.
              --Here we need to pass another parameter called WF_SAMPLE which informs that the sample
              --is getting created from the workflow notification. Based on this only we take the sample
              --disposition as the disposition in the sampling events table otherwise if the WF_SAMPLE
              --is "N"(or NULL) (this will happen when we call samples form from other forms to create samples)
              --then we take the default disposition ie Pending to create the samples.

              --l_form := 'GMDQSMPL_EDIT_F:SAMPLING_EVENT_ID="'|| l_sampling_events.sampling_event_id||'"';
              l_form := 'GMDQSMPL_EDIT_F:SAMPLING_EVENT_ID="' ||
                        l_sampling_events.sampling_event_id ||
                        '" WF_SAMPLE="Y"';
            END IF;
            l_sample_plan := FND_MESSAGE.GET();

          ELSE
            FND_MESSAGE.SET_NAME('GMD', 'GMD_SAMPLE_PLAN_NONE');
            l_sample_plan := FND_MESSAGE.GET();

            l_sample_count := 1; -- just in case
            --RLNAGARA B5389806 Only passing sampling_event_id is not enough to create samples.
            --Here we need to pass another parameter called WF_SAMPLE which informs that the sample
            --is getting created from the workflow notification. Based on this only we take the sample
            --disposition as the disposition in the sampling events table otherwise if the WF_SAMPLE
            --is "N"(or NULL) (this will happen when we call samples form from other forms to create samples)
            --then we take the default disposition ie Pending to create the samples.

            --l_form := 'GMDQSMPL_EDIT_F:SAMPLING_EVENT_ID="'||l_sampling_events.sampling_event_id||'"';
            l_form := 'GMDQSMPL_EDIT_F:SAMPLING_EVENT_ID="' ||
                      l_sampling_events.sampling_event_id ||
                      '" WF_SAMPLE="Y"';
          END IF;

          IF ((l_auto_sample <> 'Y') or (l_doc_number <> 2)) THEN
            l_event_spec_disp.SAMPLING_EVENT_ID            := l_sampling_events.sampling_event_id;
            l_event_spec_disp.SPEC_ID                      := l_spec_id;
            l_event_spec_disp.SPEC_VR_ID                   := l_spec_vr_id;
            l_event_spec_disp.DISPOSITION                  := '1P';
            l_event_spec_disp.SPEC_USED_FOR_LOT_ATTRIB_IND := NULL;
            l_event_spec_disp.DELETE_MARK                  := 0;
            l_event_spec_disp.CREATION_DATE                := sysdate;
            l_event_spec_disp.CREATED_BY                   := FND_GLOBAL.USER_ID;
            l_event_spec_disp.LAST_UPDATE_DATE             := sysdate;
            l_event_spec_disp.LAST_UPDATED_BY              := FND_GLOBAL.USER_ID;

            IF (l_debug = 'Y') THEN
              gmd_debug.put_line('Going to insert event spec disp');
            END IF;

            IF NOT
                GMD_EVENT_SPEC_DISP_PVT.insert_row(p_event_spec_disp => l_event_spec_disp,
                                                   x_event_spec_disp => l_event_spec_disp_out) THEN

              RAISE FND_API.G_EXC_ERROR;
            END IF;
            l_event_spec_disp := l_event_spec_disp_out;

            IF (l_debug = 'Y') THEN
              gmd_debug.put_line('Created event spec disp');
            END IF;
          END IF; /* End of check to create event spec for non-auto sample */

          IF l_step_id is NOT NULL THEN
            fnd_global.apps_initialize(USER_ID      => l_last_update_by,
                                       resp_id      => NULL,
                                       resp_appl_id => NULL);

            fnd_profile.initialize(l_last_update_by);

            -- Bug 4165704: GME added p_org_id to parameter list
            gme_api_grp.update_step_quality_status(p_batchstep_id   => l_step_id,
                                                   p_org_id         => l_organization_id,
                                                   p_quality_status => 2,
                                                   x_return_status  => l_return_status);

            IF l_return_status <> 'S' THEN
              NULL;
            END IF;
          END IF;

          IF (l_debug = 'Y') THEN
            gmd_debug.put_line('Ckecking for approver ');
          END IF;

          /* Start the Workflow for the Given Combination */
          AME_API.CLEARALLAPPROVALS(applicationIdIn   => l_application_id,
                                    transactionIdIn   => l_event_key,
                                    transactionTypeIn => l_transaction_type);
          --wf_log_pkg.string(6, 'Dummy','Approvers Cleared');
          AME_API.GETNEXTAPPROVER(applicationIdIn   => l_application_id,
                                  transactionIdIn   => l_event_key,
                                  transactionTypeIn => l_transaction_type,
                                  nextApproverOut   => Approver);

          /*   IF(Approver.user_id is null and Approver.person_id is null) THEN*/
          /* No Approval Required */
          /*             P_resultout:='COMPLETE:NO_WORKFLOW';
              return;
          END IF;*/

          IF (Approver.user_id is not null or
             Approver.person_id is not null) THEN
            /* Added in Bug No.7032334 */

            IF (Approver.person_id is null) THEN
              select user_name
                into l_user
                from fnd_user
               where user_id = Approver.user_id;
            ELSE
              select user_name
                into l_user
                from fnd_user
               where user_id =
                     AME_UTIL.PERSONIDTOUSERID(Approver.person_id);
            END IF;

            IF (l_debug = 'Y') THEN
              gmd_debug.put_line('Approver Found ');
            END IF;

            l_itemtype         := 'GMDQMSMC';
            l_itemkey          := l_event_key || '-' || l_step_id || '-' ||
                                  l_INVENTORY_item_id || '-' ||
                                  to_char(sysdate, 'dd/mm/yy hh:mi:ss');
            l_workflow_process := 'GMDQMSMC_PROD_PROCESS';

            WF_ENGINE.CREATEPROCESS(itemtype => l_itemtype,
                                    itemkey  => l_itemkey,
                                    process  => l_Workflow_Process);

            --wf_log_pkg.string(6, 'Dummy','Child Process Created');

            /* Set the User Attribute */

            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'CURRENT_APPROVER',
                                      avalue   => l_user);

            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'APPS_FORM',
                                      avalue   => l_form);
            /* Set All other Attributes */

            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'EVENT_NAME',
                                      avalue   => l_event_name);

            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'EVENT_KEY',
                                      avalue   => l_event_key);

            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'APPS_FORM',
                                      avalue   => l_form);

            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'ITEM_NUMBER',
                                      avalue   => l_ITEM_NUMBER);

            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'ITEM_REVISION',
                                      avalue   => l_REVISION);

            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'ITEM_DESC',
                                      avalue   => l_item_desc);

            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'ORGANIZATION_CODE',
                                      avalue   => l_organization_code);

            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'SUBINVENTORY',
                                      avalue   => l_subinventory);

            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'LOCATOR',
                                      avalue   => l_locator);

            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'FORMULA_NO',
                                      avalue   => l_formula_no);

            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'RECIPE_NO',
                                      avalue   => l_recipe_no);

            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'BATCH_NO',
                                      avalue   => l_batch_no);

            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'BATCH_STEP_NO',
                                      avalue   => l_step_no);

            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'SAMPLING_PLAN',
                                      avalue   => l_sample_plan);

            WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                      itemkey  => p_itemkey,
                                      aname    => '#FROM_ROLE',
                                      avalue   => l_from_role);

            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'AME_TRANS',
                                      avalue   => l_transaction_type);

            -- RLNAGARA Bug 5032406 (FP of 4604305 ME) Setting spec name and version wf attributes
            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'SPEC_NAME',
                                      avalue   => l_spec_name);
            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'SPEC_VERS',
                                      avalue   => l_spec_vers);

            WF_LOG_PKG.STRING(6, 'Setting', 'Setting Parent');

            WF_ENGINE.SETITEMPARENT(itemtype        => l_itemtype,
                                    itemkey         => l_itemkey,
                                    parent_itemtype => p_itemtype,
                                    parent_itemkey  => p_itemkey,
                                    parent_context  => NULL);

            /* As this a pure FYI notification we will set the approver to approve status */
            /* Bug #4576699 Moved this code before WF_ENGINE.STARTPROCESS so that
            CHECK_NEXT_APPROVER doesn't fetch records from the first approver to whom
            a notification is already sent */

            Approver.approval_status := AME_UTIL.APPROVEDSTATUS;
            AME_API.UPDATEAPPROVALSTATUS(applicationIdIn   => l_application_id,
                                         transactionIdIn   => l_event_key,
                                         approverIn        => Approver,
                                         transactionTypeIn => l_transaction_type,
                                         forwardeeIn       => AME_UTIL.EMPTYAPPROVERRECORD);

            /* start the Workflow process */
            --WF_LOG_PKG.STRING(6, 'Dummy','Starting Process');
            WF_ENGINE.STARTPROCESS(itemtype => l_itemtype,
                                   itemkey  => l_itemkey);
          END IF; /*  Added in Bug no. 7033224 */
        END IF; /* Spec Found */
      END LOOP;
      CLOSE C1;
    END IF;
    p_resultout := 'COMPLETE:';

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.CONTEXT('GMD_QMSMC',
                      'PRODUCTION',
                      p_itemtype,
                      p_itemkey,
                      l_log);
      raise;

  END PRODUCTION;

  /* RLNAGARA Bug 5032406 (FP of 4604305 ME) Added new procedure IS_STEP */
  /* procedure to check if the event is raised for a batch step level transaction */
  PROCEDURE IS_STEP(p_itemtype  IN VARCHAR2,
                    p_itemkey   IN VARCHAR2,
                    p_actid     IN NUMBER,
                    p_funcmode  IN VARCHAR2,
                    p_resultout OUT NOCOPY VARCHAR2) IS
    l_event_name varchar2(240) := WF_ENGINE.GETITEMATTRTEXT(itemtype => p_itemtype,
                                                            itemkey  => P_itemkey,
                                                            aname    => 'EVENT_NAME');

  BEGIN

    IF l_event_name IN
       ('oracle.apps.gme.batchstep.created', 'oracle.apps.gme.bstep.rel.wf') THEN
      P_resultout := 'COMPLETE:Y';
    ELSE
      P_resultout := 'COMPLETE:N';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.CONTEXT('GMD_QMSMC', 'IS_STEP', p_itemtype, p_itemkey);
      RAISE;

  END IS_STEP;

END GMD_QMSMC;


/
