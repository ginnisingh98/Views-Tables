--------------------------------------------------------
--  DDL for Package Body GME_LPN_MOBILE_TXN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_LPN_MOBILE_TXN" AS
/*  $Header: GMELMTXB.pls 120.2 2005/12/04 11:06 nsinghi noship $     */
/*===========================================================================+
 |      Copyright (c) 2005 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 |===========================================================================|
 |                                                                           |
 | PL/SQL Package to support the (Java) GME Mobile Application.              |
 | Contains PL/SQL procedures used by mobile to transact material.           |
 |                                                                           |
 +===========================================================================+
 |  HISTORY                                                                  |
 |                                                                           |
 | Date          Who               What                                      |
 | ====          ===               ====                                      |
 | 06-Oct-05     Namit Singhi      First version                             |
 |                                                                           |
 +===========================================================================*/


  g_debug      VARCHAR2 (5) := fnd_profile.VALUE ('AFLOG_LEVEL');

/*
  PROCEDURE NAVIN_DEBUG (p_message   VARCHAR2)
  IS
      i NUMBER ;
      nxt_seq NUMBER;
      PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

  SELECT seq_dbg.NEXTVAL INTO nxt_seq FROM DUAL;
    INSERT INTO nks_temp_table (STR, CREATE_DATE, SEQ) VALUES (p_message, sysdate, nxt_seq);
    COMMIT;
    RETURN;
  END;

  FUNCTION IS_MMTT_RECORD_PRESENT (p_lpn_id   IN NUMBER,
                                    txn_header_id OUT NUMBER,
                                    txn_temp_id    OUT NUMBER)
  RETURN BOOLEAN
  IS
  BEGIN

   SELECT mmtt.TRANSACTION_HEADER_ID, mmtt.TRANSACTION_TEMP_ID
   INTO txn_header_id, txn_temp_id
   FROM mtl_material_transactions_temp mmtt, mtl_txn_request_lines mtrl
   WHERE move_order_line_id = mtrl.line_id
   AND mtrl.lpn_id = p_lpn_id;
   RETURN TRUE;

  EXCEPTION
  WHEN no_data_found THEN
--   NAVIN_DEBUG('IS_MMTT_RECORD_PRESENT : No MMTT record found');
   RETURN FALSE;
  WHEN too_many_rows THEN
--   NAVIN_DEBUG('IS_MMTT_RECORD_PRESENT : More than 1 row, need special handling ');
   RETURN FALSE;
  WHEN OTHERS THEN
--   NAVIN_DEBUG('IS_MMTT_RECORD_PRESENT : In others '||SQLERRM);
   RETURN FALSE;
  END;
*/

 /*+========================================================================+
   | PROCEDURE NAME
   |   Lpn_LoV
   |
   | USAGE
   |
   | ARGUMENTS
   |   p_org_id - Organization Id
   |   p_lpn_no - License Plate Number
   |
   | RETURNS
   |   x_line_cursor - LPN Lov
   |
   | HISTORY
   |   Created  06-Oct-05 Nsinghi
   |
   +========================================================================+*/

  PROCEDURE Lpn_LoV
  (  x_line_cursor     OUT NOCOPY t_genref
  ,  p_org_id          IN  NUMBER
  ,  p_lpn_no          IN  VARCHAR2
  )
  IS
  BEGIN

    OPEN x_line_cursor FOR
	  SELECT wlpn.license_plate_number,
             wlpn.lpn_id,
             wlc.inventory_item_id,
             wlc.quantity
      FROM wms_license_plate_numbers wlpn,
           wms_lpn_contents wlc
      WHERE wlpn.lpn_id = wlc.parent_lpn_id (+)
        AND wlpn.organization_id = wlc.organization_id (+)
        AND wlpn.organization_id = p_org_id
        AND wlpn.license_plate_number LIKE LTRIM(RTRIM('%'||p_lpn_no||'%'))
        AND wlpn.lpn_context = 2
      ORDER BY lpad(wlpn.license_plate_number, 30);

  END Lpn_LoV;

 /*+========================================================================+
   | PROCEDURE NAME
   |   Get_Txn_Type
   |
   | USAGE
   |
   | ARGUMENTS
   |   p_transaction_type
   |
   | RETURNS
   |   transaction_type_id
   |
   | HISTORY
   |   Created  06-Oct-05 Nsinghi
   |
   +========================================================================+*/
  FUNCTION Get_Txn_Type(p_transaction_type_id NUMBER) RETURN NUMBER IS
    l_transaction_type_id NUMBER;
  BEGIN

    IF p_transaction_type_id = G_ING_ISSUE THEN
      l_transaction_type_id := GME_COMMON_PVT.g_ing_issue;
    ELSIF p_transaction_type_id = G_ING_RETURN THEN
      l_transaction_type_id := GME_COMMON_PVT.g_ing_return;
    ELSIF p_transaction_type_id = G_PROD_COMPLETION THEN
      l_transaction_type_id := GME_COMMON_PVT.g_prod_completion;
    ELSIF p_transaction_type_id = G_PROD_RETURN THEN
      l_transaction_type_id := GME_COMMON_PVT.g_prod_return;
    ELSIF p_transaction_type_id = G_BYPROD_COMPLETION THEN
      l_transaction_type_id := GME_COMMON_PVT.g_byprod_completion;
    ELSIF p_transaction_type_id = G_BYPROD_RETURN THEN
      l_transaction_type_id := GME_COMMON_PVT.g_byprod_return;
    END IF;

    RETURN l_transaction_type_id;

  END Get_Txn_Type;

 /*+========================================================================+
   | PROCEDURE NAME
   |   Create_Material_Txns
   |
   | USAGE
   |
   | ARGUMENTS
   |    p_organization_id
   |    p_batch_id
   |    p_material_detail_id
   |    p_item_id
   |    p_revision
   |    p_subinventory_code
   |    p_locator_id
   |    p_txn_qty
   |    p_txn_uom_code
   |    p_sec_txn_qty
   |    p_sec_uom_code
   |    p_primary_uom_code
   |    p_txn_primary_qty
   |    p_reason_id
   |    p_txn_date
   |    p_txn_type_id
   |    p_phantom_type
   |    p_user_id
   |    p_login_id
   |    p_dispense_id
   |
   | RETURNS
   |   x_message
   |
   | HISTORY
   |   Created  06-Oct-05 Nsinghi
   |
   +========================================================================+*/

  PROCEDURE Create_Material_Txn(p_organization_id        IN NUMBER,
                                p_batch_id               IN NUMBER,
                                p_material_detail_id     IN NUMBER,
                                p_item_id                IN NUMBER,
                                p_revision               IN VARCHAR2,
                                p_subinventory_code      IN VARCHAR2,
                                p_locator_id             IN NUMBER,
                                p_txn_qty                IN NUMBER,
                                p_txn_uom_code           IN VARCHAR2,
                                p_sec_txn_qty            IN NUMBER,
                                p_sec_uom_code           IN VARCHAR2,
                                p_primary_uom_code       IN VARCHAR2,
                                p_txn_primary_qty        IN NUMBER,
                                p_reason_id              IN NUMBER,
                                p_txn_date               IN DATE,
                                p_txn_type_id            IN NUMBER,
                                p_phantom_type           IN NUMBER,
                                p_user_id                IN NUMBER,
                                p_login_id               IN NUMBER,
                                p_dispense_id            IN NUMBER,
--                                p_phantom_line_id        IN NUMBER,
                                p_lpn_id                 IN NUMBER,
                                x_txn_id                 OUT NOCOPY NUMBER,
                                x_txn_type_id            OUT NOCOPY NUMBER,
                                x_txn_header_id          OUT NOCOPY NUMBER,
                                x_return_status          OUT NOCOPY VARCHAR2,
                                x_error_msg              OUT NOCOPY VARCHAR2)
  IS
    l_assign_phantom NUMBER;
    l_mmti_rec_in    mtl_transactions_interface%ROWTYPE;
    l_mmti_rec_out   mtl_transactions_interface%ROWTYPE;
  BEGIN

   -- Clearing the quantity cache
   inv_quantity_tree_pub.clear_quantity_cache;

    IF (g_debug IS NOT NULL) THEN
       gme_debug.log_initialize ('MobileCreTxn');
    END IF;

    gme_common_pvt.g_user_ident := p_user_id;
    gme_common_pvt.g_login_id   := p_login_id;
    gme_common_pvt.set_timestamp;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_error_msg     := ' ';

    l_mmti_rec_in.transaction_type_id := Get_Txn_Type(p_txn_type_id);

    l_mmti_rec_in.transaction_source_id          := p_batch_id;
    l_mmti_rec_in.trx_source_line_id             := p_material_detail_id;
    l_mmti_rec_in.inventory_item_id              := p_item_id;
    l_mmti_rec_in.revision                       := p_revision;
    l_mmti_rec_in.organization_id                := p_organization_id;
    l_mmti_rec_in.transaction_date               := p_txn_date;
    l_mmti_rec_in.transaction_quantity           := p_txn_qty;
    l_mmti_rec_in.primary_quantity               := p_txn_primary_qty;
    l_mmti_rec_in.reason_id                      := p_reason_id;
    l_mmti_rec_in.secondary_transaction_quantity := p_sec_txn_qty;
    l_mmti_rec_in.secondary_uom_code             := p_sec_uom_code;
    l_mmti_rec_in.transaction_uom                := p_txn_uom_code;
    l_mmti_rec_in.subinventory_code              := p_subinventory_code;
    l_mmti_rec_in.locator_id                     := p_locator_id;
    l_mmti_rec_in.transaction_source_name        := NULL;
    l_mmti_rec_in.transaction_reference          := p_dispense_id;
    l_mmti_rec_in.transaction_action_id          := NULL;
    l_mmti_rec_in.transfer_lpn_id                := p_lpn_id;


    l_assign_phantom := 0;

/*
    IF p_phantom_line_id IS NOT NULL THEN
      -- This is a product of a phantom batch or a phantom ingredient
      l_assign_phantom := 1;
    END IF;
*/
    GME_TRANSACTIONS_PVT.Build_Txn_Inter_Hdr(
                        p_mmti_rec        => l_mmti_rec_in,
--                        p_assign_phantom  => l_assign_phantom,
                        x_mmti_rec        => l_mmti_rec_out,
                        x_return_status   => x_return_status);


    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_error_msg     := fnd_message.get;
      x_txn_id      := -1;
      x_txn_type_id := -1;
      x_txn_header_id := -1;
    ELSE
      x_txn_id      := l_mmti_rec_out.transaction_interface_id;
      x_txn_type_id := l_mmti_rec_in.transaction_type_id;
      x_txn_header_id := l_mmti_rec_out.transaction_header_id;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in Create MAterial Txn');
      END IF;
      fnd_msg_pub.add_exc_msg('GME_MOBILE_TXN','create_material_txn');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_msg     := fnd_message.get;

  END Create_Material_Txn;

 /*+========================================================================+
   | PROCEDURE NAME
   |   Update_MO_Line
   |
   | USAGE
   |
   | ARGUMENTS
   |   p_lpn_id - LPN id
   |   p_wms_process_flag - Process Flag to be updated to
   |
   | RETURNS
   |   x_return_status - S : If successful, E : If error
   |   x_msg_count - Message count
   |   x_msg_data - Message Data
   |
   | HISTORY
   |   Created  06-Oct-05 Nsinghi
   |
   +========================================================================+*/

PROCEDURE Update_MO_Line
  (p_lpn_id 				                  IN NUMBER,
   p_wms_process_flag 			            IN NUMBER,
   x_return_status                        OUT   NOCOPY VARCHAR2)
IS
  	 l_return_status		      VARCHAR2(1);

BEGIN
	l_return_status:= FND_API.G_RET_STS_SUCCESS;

	UPDATE mtl_txn_request_lines
	SET wms_process_flag = p_wms_process_flag
	WHERE lpn_id = p_lpn_id;

	x_return_status:=l_return_status;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status:=FND_API.G_RET_STS_ERROR;

END Update_MO_Line;

 /*+========================================================================+
   | PROCEDURE NAME
   |  Process_Interface_Txn
   |
   | USAGE
   |
   | ARGUMENTS
   |
   | RETURNS
   |
   | HISTORY
   |   Created  07-Oct-05 Namit Singhi
   |
   +========================================================================+*/
  PROCEDURE Process_Interface_Txn( p_txn_header_id IN NUMBER,
                                   p_user_id       IN NUMBER,
                                   p_login_id      IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_error_msg     OUT NOCOPY VARCHAR2)
  IS
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2 (2000);
   l_trans_count    NUMBER;

  BEGIN

    IF (g_debug IS NOT NULL) THEN
       gme_debug.log_initialize ('MobileProcessTxn');
    END IF;

    gme_common_pvt.g_user_ident := p_user_id;
    gme_common_pvt.g_login_id   := p_login_id;
    gme_common_pvt.set_timestamp;

    GME_TRANSACTIONS_PVT.Process_Transactions
                 (p_api_version           => 2.0,
                  p_init_msg_list         => fnd_api.g_false,
                  p_commit                => fnd_api.g_false,
                  p_validation_level      => fnd_api.g_valid_level_full,
                  p_table                 => 1, -- Source table is Interface
                  p_header_id             => p_txn_header_id,
                  x_return_status         => x_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  x_trans_count           => l_trans_count);

         IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
           --x_error_msg     := fnd_message.get;
           x_error_msg     := l_msg_data;
         END IF;

    --- Reseting this global variable. I guess this should be done in
    --- GME_TRANSACTIONS_PVT.Process_Transactions
    GME_COMMON_PVT.g_transaction_header_id := NULL;

  EXCEPTION
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in Process_Transactions');
      END IF;
      fnd_msg_pub.add_exc_msg('GME_MOBILE_TXN','process_transactions');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_msg     := fnd_message.get;

  END Process_Interface_Txn;

 /*+========================================================================+
   | PROCEDURE NAME
   |  get_prod_count
   |
   | USAGE
   |
   | ARGUMENTS
   |
   | RETURNS
   |
   | HISTORY
   |   Created  07-Oct-05 Namit Singhi
   |
   +========================================================================+*/

  PROCEDURE get_prod_count (p_batch_id       IN NUMBER,
                            p_org_id         IN NUMBER,
                            x_prod_count     OUT NOCOPY NUMBER,
                            x_return_status  OUT NOCOPY VARCHAR2)
  IS
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2 (2000);
   l_trans_count    NUMBER;

  BEGIN

   SELECT COUNT(material_detail_id) INTO x_prod_count
   FROM gme_material_details
   WHERE batch_id = p_batch_id
   AND organization_id = p_org_id
   AND line_type IN (1, 2);

   x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in get_prod_count ');
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END get_prod_count;

 /*+========================================================================+
   | PROCEDURE NAME
   |  get_subinv_loc
   |
   | USAGE
   |
   | ARGUMENTS
   |
   | RETURNS
   |
   | HISTORY
   |   Created  11-Nov-05 Namit Singhi
   |
   +========================================================================+*/

  PROCEDURE get_subinv_loc(p_batch_id           IN NUMBER
                           , p_org_id           IN NUMBER
                           , p_material_dtl_id  IN NUMBER
                           , x_subinventory     OUT NOCOPY VARCHAR2
                           , x_locator          OUT NOCOPY VARCHAR2
                           , x_locator_id       OUT NOCOPY NUMBER
                           , x_return_status    OUT NOCOPY VARCHAR2
                           , x_msg_data         OUT NOCOPY VARCHAR2)
  IS

   CURSOR Cur_sub_loc IS
      SELECT gbh.batch_no, msi.concatenated_segments, gmd.subinventory, mil.concatenated_segments, inventory_location_id
      FROM gme_material_details gmd, mtl_item_locations_kfv mil, gme_batch_header gbh, mtl_system_items_kfv msi
      WHERE gmd.organization_id = p_org_id
      AND gmd.batch_id = p_batch_id
      AND gmd.material_detail_id = p_material_dtl_id
      AND gmd.locator_id = mil.inventory_location_id
      AND gmd.organization_id = mil.organization_id
      AND gmd.batch_id = gbh.batch_id
      AND gmd.organization_id = gbh.organization_id
      AND gmd.inventory_item_id = msi.inventory_item_id
      AND gmd.organization_id = msi.organization_id;

   l_batch_no  VARCHAR2(32);
   l_item      VARCHAR2(240);
   NO_DEF_SUB_LOC EXCEPTION;

  BEGIN

   IF (g_debug IS NOT NULL) THEN
      gme_debug.log_initialize ('MobileGetSubLoc');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_data     := ' ';

   OPEN Cur_sub_loc;
   FETCH Cur_sub_loc INTO l_batch_no, l_item, x_subinventory, x_locator, x_locator_id;
   IF Cur_sub_loc%NOTFOUND THEN
     CLOSE Cur_sub_loc;
     RAISE NO_DEF_SUB_LOC;
   END IF;
   CLOSE Cur_sub_loc;

   IF x_subinventory IS NULL OR x_locator_id IS NULL THEN
      RAISE NO_DEF_SUB_LOC;
   END IF;

  EXCEPTION
    WHEN NO_DEF_SUB_LOC THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When NO_DEF_SUB_LOC exception in get_subinv_loc ');
      END IF;
      FND_MESSAGE.SET_NAME('GME', 'GME_NO_DEF_SUB_LOC');
      FND_MESSAGE.SET_TOKEN('BATCH_NO', l_batch_no);
      FND_MESSAGE.SET_TOKEN('ITEM_NAME', l_item);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := FND_MESSAGE.GET;

   WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in get_subinv_loc ');
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END get_subinv_loc;

END gme_lpn_mobile_txn;

/
