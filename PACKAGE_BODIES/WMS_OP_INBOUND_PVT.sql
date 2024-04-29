--------------------------------------------------------
--  DDL for Package Body WMS_OP_INBOUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_OP_INBOUND_PVT" AS
/*$Header: WMSOPIBB.pls 120.16.12010000.4 2009/02/18 10:47:23 aditshar ship $*/

g_version_printed        BOOLEAN      := FALSE;
g_pkg_name               VARCHAR2(30) := 'WMS_OP_INBOUND_PVT';

G_OP_TYPE_LOAD CONSTANT NUMBER := wms_globals.g_op_type_load;
G_OP_TYPE_DROP CONSTANT NUMBER:= wms_globals.G_OP_TYPE_DROP;
G_OP_TYPE_SORT CONSTANT NUMBER:= wms_globals.G_OP_TYPE_SORT;
G_OP_TYPE_CONSOLIDATE CONSTANT NUMBER:= wms_globals.G_OP_TYPE_CONSOLIDATE;
G_OP_TYPE_PACK CONSTANT NUMBER:= wms_globals.G_OP_TYPE_PACK;
G_OP_TYPE_LOAD_SHIP CONSTANT NUMBER:= wms_globals.G_OP_TYPE_LOAD_SHIP;
G_OP_TYPE_SHIP CONSTANT NUMBER:=  wms_globals.G_OP_TYPE_SHIP;
G_OP_TYPE_CYCLE_COUNT CONSTANT NUMBER :=  wms_globals.G_OP_TYPE_CYCLE_COUNT;
G_OP_TYPE_INSPECT CONSTANT NUMBER :=  wms_globals.G_OP_TYPE_INSPECT;
G_OP_TYPE_CROSSDOCK CONSTANT NUMBER:= wms_globals.G_OP_TYPE_CROSSDOCK;
g_wms_task_type_inspect CONSTANT NUMBER:= wms_globals.g_wms_task_type_inspect;
g_wms_task_type_putaway CONSTANT NUMBER:= wms_globals.g_wms_task_type_putaway;

G_ACTION_RECEIPT CONSTANT NUMBER := inv_globals.g_action_receipt ;
G_ACTION_INTRANSITRECEIPT CONSTANT NUMBER := inv_globals.G_ACTION_INTRANSITRECEIPT;
G_ACTION_SUBXFR CONSTANT NUMBER := inv_globals.g_action_subxfr;
G_SOURCETYPE_MOVEORDER CONSTANT NUMBER := inv_globals.g_sourcetype_moveorder;
G_SOURCETYPE_PURCHASEORDER CONSTANT NUMBER := inv_globals.G_SOURCETYPE_PURCHASEORDER;
G_SOURCETYPE_INTREQ CONSTANT NUMBER := inv_globals.G_SOURCETYPE_INTREQ;
G_SOURCETYPE_RMA CONSTANT NUMBER := inv_globals.G_SOURCETYPE_RMA;
G_SOURCETYPE_inventory CONSTANT NUMBER := inv_globals.G_SOURCETYPE_inventory;
G_TYPE_TRANSFER_ORDER_SUBXFR CONSTANT NUMBER := inv_globals.g_type_transfer_order_subxfr;

G_TO_STATUS_CLOSED CONSTANT NUMBER := inv_globals.g_to_status_closed;
g_task_status_loaded CONSTANT NUMBER:= 4;


PROCEDURE print_debug(p_err_msg IN VARCHAR2, p_module_name IN VARCHAR2, p_level IN NUMBER) IS
  BEGIN
    IF NOT g_version_printed THEN
      inv_mobile_helper_functions.tracelog(p_err_msg => '$Header: WMSOPIBB.pls 120.16.12010000.4 2009/02/18 10:47:23 aditshar ship $', p_module => g_pkg_name, p_level => 9);
      g_version_printed  := TRUE;
    END IF;

--    dbms_output.put_line(p_err_msg);

    inv_log_util.trace(p_err_msg, g_pkg_name || '.' || p_module_name,p_level);
END print_debug;


/**
    *    <b> Init</b>:
    * <p>This API is the document handler for Inbound document records and is called from
    *    Init_op_plan_instance. This API createduplicates child the MMTT/MTLT records and
    *    nulls out the relevant fields on parent MMTT record. </p>
    *  @param x_return_status      -Return Status
    *  @param x_msg_data           -Returns Message Data
    *  @param x_msg_count          -Returns the message count
    *  @param x_source_task_id     -Returns the Source Task Id of the child document record created.
    *  @param x_error_code         -Returns Appropriate error code in case of any error.
    *  @param p_source_task_id     -Identifier of the document record.
    *  @param p_document_rec       -Record Type of MMTT
    *  @param p_operation_type_id  -Operation Type id of the first operation
    *
   **/
  PROCEDURE INIT(
    x_return_status       OUT  NOCOPY    VARCHAR2
  , x_msg_data            OUT  NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
  , x_msg_count           OUT  NOCOPY    NUMBER
  , x_source_task_id      OUT  NOCOPY    NUMBER
  , x_error_code          OUT  NOCOPY    NUMBER
  , p_source_task_id      IN             NUMBER
  , p_document_rec        IN             mtl_material_transactions_temp%ROWTYPE
  , p_operation_type_id   IN             NUMBER
  , p_revert_loc_capacity IN             BOOLEAN DEFAULT FALSE
  , p_subsequent_op_plan_id   IN        NUMBER DEFAULT NULL
  ) IS

    CURSOR c_item_details(v_inventory_item_id NUMBER,v_organization_id NUMBER) IS
     SELECT nvl(lot_control_code,1)lot_control_code,nvl(serial_number_control_code,1) serial_number_control_code
       FROM mtl_system_items_b
     WHERE inventory_item_id = v_inventory_item_id
       AND organization_id   = v_organization_id;

    CURSOR c_mtlt_rec IS
       SELECT *
       FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id=p_source_task_id;

    l_module_name      VARCHAR2(30)   := 'INIT';
    l_debug            NUMBER         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
    l_progress         NUMBER;

    l_mtlt_rec         MTL_TRANSACTION_LOTS_TEMP%ROWTYPE;
    l_item_details_rec c_item_details%ROWTYPE;
    l_wms_task_type    NUMBER;
    l_insert_lot       NUMBER;
    l_ser_trx_id       NUMBER;
    l_proc_msg         VARCHAR2(200);

    l_return_status    VARCHAR2(1);
    l_msg_count        NUMBER;
    l_msg_data         fnd_new_messages.message_text%TYPE;


  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_progress      := 10;


    IF (l_debug=1) THEN
       print_debug('p_source_task_id     ==>'||p_source_task_id,l_module_name,3);
       print_debug('p_operation_type_id  ==>'||p_operation_type_id,l_module_name,3);
       print_debug('p_subsequent_op_plan_id  ==>'||p_subsequent_op_plan_id,l_module_name,3);
       IF(p_revert_loc_capacity = TRUE)THEN
          print_debug('p_revert_loc_capacity  ==> T',l_module_name,3);
        ELSE
          print_debug('p_revert_loc_capacity  ==> F',l_module_name,3);
       END IF;
    END IF;

     /*If p_source_task_id is null then return error status and return with appropriate error code.*/
     IF (p_source_task_id IS NULL) THEN /*Do we need to check this here as we are doing this check in
                                         Public API*/
        IF (l_debug=1) THEN
           print_debug('Source task Id is null',l_module_name,1);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     l_progress:=20;

     /*If the item is a Lot Controlled Item, Query MTL_TRANSACTIONS_LOT_TEM (MTLT) based on
       P_Source_task_ID and poplate the PL/SQL record variable.*/
     /*Checking if the MTLTs exist for a Lot Controlled Item.If there are no records found throw an Invalid
      Document Error as the Assumption made is that rules will always create MTLTs for a lot controlled item
      --Have to finalise on this and will change if required*/

      OPEN c_item_details(p_document_rec.INVENTORY_ITEM_ID,p_document_rec.organization_id);

      FETCH c_item_details INTO l_item_details_rec;

      IF (c_item_details%NOTFOUND) THEN

         IF (l_debug=1) THEN
            print_debug('Item -Org combnation not found',l_module_name,1);
         END IF;
         RAISE FND_API.G_EXC_ERROR;

      END IF;

      CLOSE c_item_details;

      l_progress:=30;
      /*Check if item is lot Control*/
      IF (l_item_details_rec.lot_control_code=2) THEN

          IF (l_debug=1) THEN
             print_debug('Item is lot Controlled',l_module_name,9);
          END IF;

          OPEN c_mtlt_rec;

          FETCH c_mtlt_rec INTO l_mtlt_rec;

          IF (c_mtlt_rec%NOTFOUND) THEN
             IF (l_debug=1) THEN
                print_debug('NO MTLT record exists for Lot Control Item',l_module_name,1);
             END IF;
             /* Throwing exception for this condition as of now as Invalid document record*/
             RAISE FND_API.G_EXC_ERROR;

          END IF;

          CLOSE c_mtlt_rec;

          l_progress:=40;

      END IF;

      /*Create child document record.
         We need to NULL out the destination subinventory and locator for the child MMTT record,
         because they will be suggested by ATF determination methods.
         The actual columns need to be NULL out are: subinventory_code and locator_ID,
         this is because of the following:
         1. The first child MMTT record cannot be a Move order transfer (inventory) transaction.
         2. If the first child MMTT record is for a delivery transaction we should NULL out these two fields
            and ATF determination methods will stamp these columns later.
         3. If the first child MMTT record is for a receiving transfer we should NULL out these two fields
            and ATF determination methods will stamp the transfer_subinventory and
            transfer_to_location columns later.
       */

      /*Calling API INV_TRX_UTIL_PUB.copy_insert_line_trx to create the child MMTT. This is a new API
        in INVTRUS.pls,hence dependency with version 115. */

      IF (l_debug=1) THEN
         print_debug('Calling INV_TRX_UTIL_PUB.copy_insert_line_trx to create child MMTT',l_module_name,9);
      END IF;

      l_progress:=50;
      /*IF p_operation_type_id='INSPECT' then
          /*
            This is the case where operation plan only has one 'Inspect' operation.
            MMTT should have a system task type of 'Inspect'.
            Update MMTT.WMS_TASK_TYPE to 'Inspect' for both parent and child tasks.*/

      IF (p_operation_type_id=G_OP_TYPE_INSPECT) THEN
         IF (l_debug=1) THEN
            print_debug('Operation is inspect,hence setting task type to Inspect',l_module_name,9);
         END IF;

         l_wms_task_type:=WMS_GLOBALS.g_wms_task_type_inspect;
      ELSE
         l_wms_task_type:=p_document_rec.WMS_TASK_TYPE;

      END IF;
      /*
      {{
        Operation plan only has one crossdock operation. Should verify from control board
        that the parent task has inbound crossdock plan and child has outbound plan.

        }}

      */
        IF (p_operation_type_id = g_op_type_crossdock AND
            p_subsequent_op_plan_id IS NOT NULL) -- this is necessary because this file is dual maintained for 11.5.10
              THEN

           IF (l_debug=1) THEN
              print_debug('Stamp subsequent OP plan ID '||p_subsequent_op_plan_id||' to child task. ',l_module_name,9);
           END IF;

           INV_TRX_UTIL_PUB.copy_insert_line_trx
             (
              x_return_status       =>   l_return_status
              ,x_msg_data            =>   l_msg_data
              ,x_msg_count           =>   l_msg_count
              ,x_new_txn_temp_id     =>   x_source_task_id
              ,p_transaction_temp_id =>   p_source_task_id
              ,p_organization_id     =>   p_document_rec.organization_id
              ,p_subinventory_code   =>   FND_API.G_MISS_CHAR
              ,p_locator_id          =>   FND_API.G_MISS_NUM
              ,p_parent_line_id      =>   p_source_task_id
              ,p_wms_task_type       =>   l_wms_task_type
              ,p_operation_plan_id   =>   p_subsequent_op_plan_id
              );

         ELSE

           INV_TRX_UTIL_PUB.copy_insert_line_trx
             (
              x_return_status       =>   l_return_status
              ,x_msg_data            =>   l_msg_data
              ,x_msg_count           =>   l_msg_count
              ,x_new_txn_temp_id     =>   x_source_task_id
              ,p_transaction_temp_id =>   p_source_task_id
              ,p_organization_id     =>   p_document_rec.organization_id
              ,p_subinventory_code   =>   FND_API.G_MISS_CHAR
              ,p_locator_id          =>   FND_API.G_MISS_NUM
              ,p_parent_line_id      =>   p_source_task_id
              ,p_wms_task_type       =>   l_wms_task_type
              );

        END IF;

      l_progress:=60;
      IF (l_debug=1) THEN
         print_debug('Return status is'||l_return_status,l_module_name,9);
      END IF;

      IF (l_return_status=fnd_api.g_ret_sts_error) THEN
             IF (l_debug=1) THEN
                print_debug('Error obtained while creating child record',l_module_name,9);
             END IF;
             RAISE FND_API.G_EXC_ERROR;

      ELSIF (l_return_status<>fnd_api.g_ret_sts_success) THEN

           IF (l_debug=1) THEN
              print_debug('unexpected error while creating child record',l_module_name,9);
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END IF;


      IF (x_source_task_id IS NULL) THEN
         IF (l_debug=1) THEN
            print_debug('Cheild record could not be created',l_module_name,1);

         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_progress:=70;

    /* If Lot Controllled Item then
         Set the transaction_temp_id of the MTLT record variable to the
         transaction_temp_id of the duplicated MMTT record.
        */
       IF (l_item_details_rec.lot_control_code=2) THEN
          l_mtlt_rec.transaction_temp_id:=x_source_task_id;
       END IF;

      l_progress:=80;


      /*Update MMTT record where transaction_temp_ID = P_source_task_ID.
       Null out move_order_line_ID and lpn_ID.*/

      UPDATE mtl_material_transactions_temp
         SET            lpn_id  = NULL,
             move_order_line_id = NULL,
                  wms_task_type = l_wms_task_type
      WHERE transaction_temp_id = p_source_task_id;

      IF (l_debug=1) THEN
         print_debug('Updated Parent MMTT nulling LPN Id,MOL Id',l_module_name,9);
      END IF;

      l_progress:=90;

      /*and Call INV_TRX_UTIL_PUB.INSERT_LOT_TRX passing the appropriate parameters
      from the record variable to insert MTLT record.*/

      IF (l_debug=1) THEN
         print_debug('Calling Insert_lot_trx to insert child MTLT records',l_module_name,9);
      END IF;

      IF (l_item_details_rec.lot_control_code=2) THEN

         l_insert_lot:=INV_TRX_UTIL_PUB.INSERT_LOT_TRX
                       (p_trx_tmp_id               => x_source_task_id,
                        p_user_id                  => FND_GLOBAL.USER_ID ,
                        p_lot_number               => l_mtlt_rec.lot_number ,
                        p_trx_qty                  => l_mtlt_rec.transaction_quantity,
                        p_pri_qty                  => l_mtlt_rec.primary_quantity,
                        p_exp_date                 => l_mtlt_rec.LOT_EXPIRATION_DATE,
                        p_description              => l_mtlt_rec.DESCRIPTION,
                        p_vendor_name              => l_mtlt_rec.VENDOR_NAME ,
                        p_supplier_lot_number      => l_mtlt_rec.SUPPLIER_LOT_NUMBER,
                        p_origination_date         => l_mtlt_rec.ORIGINATION_DATE,
                        p_date_code                => l_mtlt_rec.DATE_CODE,
                        p_grade_code               => l_mtlt_rec.GRADE_CODE,
                        p_change_date              => l_mtlt_rec.CHANGE_DATE,
                        p_maturity_date            => l_mtlt_rec.MATURITY_DATE,
                        p_status_id                => l_mtlt_rec.STATUS_ID ,
                        p_retest_date              => l_mtlt_rec.RETEST_DATE,
                        p_age                      => l_mtlt_rec.age,
                        p_item_size                => l_mtlt_rec.item_size,
                        p_color                    => l_mtlt_rec.color,
                        p_volume                   => l_mtlt_rec.volume,
                        p_volume_uom               => l_mtlt_rec.volume_uom,
                        p_place_of_origin          => l_mtlt_rec.place_of_origin,
                        p_best_by_date             => l_mtlt_rec.best_by_date,
                        p_length                   => l_mtlt_rec.length,
                        p_length_uom               => l_mtlt_rec.length_uom,
                        p_recycled_content         => l_mtlt_rec.recycled_content,
                        p_thickness                => l_mtlt_rec.thickness,
                        p_thickness_uom            => l_mtlt_rec.thickness_uom,
                        p_width                    => l_mtlt_rec.width,
                        p_width_uom                => l_mtlt_rec.width_uom,
                        p_curl_wrinkle_fold        => l_mtlt_rec.curl_wrinkle_fold,
                        p_lot_attribute_category   => l_mtlt_rec.lot_attribute_category,
                        p_c_attribute1             => l_mtlt_rec.c_attribute1,
                        p_c_attribute2             => l_mtlt_rec.c_attribute2,
                        p_c_attribute3             => l_mtlt_rec.c_attribute3,
                        p_c_attribute4             => l_mtlt_rec.c_attribute4,
                        p_c_attribute5             => l_mtlt_rec.c_attribute5,
                        p_c_attribute6             => l_mtlt_rec.c_attribute6,
                        p_c_attribute7             => l_mtlt_rec.c_attribute7,
                        p_c_attribute8             => l_mtlt_rec.c_attribute8,
                        p_c_attribute9             => l_mtlt_rec.c_attribute9,
                        p_c_attribute10            => l_mtlt_rec.c_attribute10,
                        p_c_attribute11            => l_mtlt_rec.c_attribute11,
                        p_c_attribute12            => l_mtlt_rec.c_attribute12,
                        p_c_attribute13            => l_mtlt_rec.c_attribute13,
                        p_c_attribute14            => l_mtlt_rec.c_attribute14,
                        p_c_attribute15            => l_mtlt_rec.c_attribute15,
                        p_c_attribute16            => l_mtlt_rec.c_attribute16,
                        p_c_attribute17            => l_mtlt_rec.c_attribute17,
                        p_c_attribute18            => l_mtlt_rec.c_attribute18,
                        p_c_attribute19            => l_mtlt_rec.c_attribute19,
                        p_c_attribute20            => l_mtlt_rec.c_attribute20,
                        p_d_attribute1             => l_mtlt_rec.d_attribute1,
                        p_d_attribute2             => l_mtlt_rec.d_attribute2,
                        p_d_attribute3             => l_mtlt_rec.d_attribute3,
                        p_d_attribute4             => l_mtlt_rec.d_attribute4,
                        p_d_attribute5             => l_mtlt_rec.d_attribute5,
                        p_d_attribute6             => l_mtlt_rec.d_attribute6,
                        p_d_attribute7             => l_mtlt_rec.d_attribute7,
                        p_d_attribute8             => l_mtlt_rec.d_attribute8,
                        p_d_attribute9             => l_mtlt_rec.d_attribute9,
                        p_d_attribute10            => l_mtlt_rec.d_attribute10,
                        p_n_attribute1             => l_mtlt_rec.n_attribute1,
                        p_n_attribute2             => l_mtlt_rec.n_attribute2,
                        p_n_attribute3             => l_mtlt_rec.n_attribute3,
                        p_n_attribute4             => l_mtlt_rec.n_attribute4,
                        p_n_attribute5             => l_mtlt_rec.n_attribute5,
                        p_n_attribute6             => l_mtlt_rec.n_attribute6,
                        p_n_attribute7             => l_mtlt_rec.n_attribute7,
                        p_n_attribute8             => l_mtlt_rec.n_attribute8,
                        p_n_attribute9             => l_mtlt_rec.n_attribute9,
                        p_n_attribute10            => l_mtlt_rec.n_attribute10,
                        x_ser_trx_id               => l_ser_trx_id,
                        x_proc_msg                 => l_proc_msg,
                        p_territory_code           => l_mtlt_rec.territory_code,
                        p_vendor_id                => l_mtlt_rec.vendor_id,
                        p_secondary_qty            => l_mtlt_rec.secondary_quantity,   -- Bug 8204534
                        p_secondary_uom            => l_mtlt_rec.secondary_unit_of_measure);

         IF (l_insert_lot<>0) THEN
            IF (l_debug=1) THEN
               print_debug('Failed to insert lots',l_module_name,1);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

      IF p_revert_loc_capacity THEN

         l_progress:=100;

         IF l_debug=1 THEN
            print_debug('Suggested locator capacity of the Rules suggested locaotr needs to be reverted',l_module_name,9);
         END IF;

         IF ( p_document_rec.locator_id IS NOT NULL) THEN
            inv_loc_wms_utils.revert_loc_suggested_cap_nauto
              (
               x_return_status             => l_return_status
               , x_msg_count                 => l_msg_count
               , x_msg_data                  => l_msg_data
               , p_organization_id           => p_document_rec.organization_id
               , p_inventory_location_id     => p_document_rec.locator_id
               , p_inventory_item_id         => p_document_rec.inventory_item_id
               , p_primary_uom_flag          => 'Y'
               , p_transaction_uom_code      => NULL
               , p_quantity                  => p_document_rec.primary_quantity
               );
         END IF;

         l_progress:=110;

         IF (l_debug=1) THEN
          print_debug('Return status is'||l_return_status,l_module_name,9);
        END IF;

        IF (l_return_status<>fnd_api.g_ret_sts_success) THEN

            IF (l_debug=1) THEN
               print_debug('Error obtained while reverting locator capacity',l_module_name,9);
               print_debug('Error msg'||x_msg_data,l_module_name,9);
            END IF;

        END IF;

      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
       WHEN fnd_api.g_exc_error THEN
         IF (l_debug=1) THEN
           print_debug('Error obatined at'||l_progress,l_module_name,1);
         END IF;
         x_return_status:=FND_API.G_RET_STS_ERROR;
         /*Message or error code to be populated for Operation PLan Instance Id Null*/

       WHEN OTHERS THEN

        x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
        IF (l_debug=1) THEN
          print_debug('Unexpected Error'||SQLERRM||'at '||l_progress,l_module_name,3);
        END IF;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
        END IF;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

  END;

  /**
    *    <b> Activate</b>:
    * <p>This API is the document handler for Inbound document records and is called from
    *    Activate_operation_instance. This API updates MMTT records and
    *    with the suggested subinventory,locator </p>
    *  @param x_return_status      -Return Status
    *  @param x_msg_data           -Returns Message Data
    *  @param x_msg_count          -Returns the message count
    *  @param x_error_code         -Returns Appropriate error code in case of any error.
    *  @param p_source_task_id     -Identifier of the document record.
    *  @param p_update_param_rec   -Record Type of WMS_ATF_RUNTIME_PUB_APIS.DEST_PARAM_REC_TYPE
    *
   **/
  PROCEDURE ACTIVATE(
   x_return_status      OUT  NOCOPY    VARCHAR2
 , x_msg_data           OUT  NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
 , x_msg_count          OUT  NOCOPY    NUMBER
 , x_error_code         OUT  NOCOPY    NUMBER
 , p_source_task_id     IN             NUMBER
 , p_update_param_rec   IN             DEST_PARAM_REC_TYPE
 , p_document_rec       IN             MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
 )IS

/*     CURSOR c_locator_type(v_location_id NUMBER,v_org_id NUMBER) IS
       SELECT Nvl(inventory_location_type, 3)
        FROM mtl_item_locations
        WHERE inventory_location_id=v_location_id
        AND organization_id=v_org_id;
*/
     CURSOR c_sub_type(v_sub_code VARCHAR2,v_org_id NUMBER) IS
        SELECT Nvl(subinventory_type, 1)
        FROM mtl_secondary_inventories
        WHERE secondary_inventory_name=v_sub_code
        AND organization_id=v_org_id;

     CURSOR c_orig_sugges(v_txn_temp_id NUMBER) IS
     SELECT  nvl(transfer_subinventory,subinventory_code) subinventory_code
            ,nvl(transfer_to_location,locator_id) locator_id
     FROM mtl_material_transactions_temp
     WHERE transaction_temp_id=v_txn_temp_id;

   l_sub_type         NUMBER := -1;
   l_orig_sugges      c_orig_sugges%ROWTYPE;

   l_module_name      VARCHAR2(30)   := 'ACTIVATE';
   l_debug            NUMBER         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress         NUMBER;

   l_msg_data         fnd_new_messages.message_text%TYPE;
   l_return_status    VARCHAR2(1);
   l_msg_count        NUMBER;

  BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_progress      := 10;

     /*Whenever we update transfer_to_location and transfer_subinventory, we need to aware that we are
      * dealing with three types of MMTTS:
      * 1.Receiving transfer: Transaction type 'PO receipt, interorg transfer receipt,
          RMA receipt', destination locator type 'receiving'.
          For this type of MMTT, destination is populated in 'transfer_ sub/locator' fields.
        2.Receiving deliver: Transaction type 'PO receipt', destination locator type 'inventory'.
          For this type of MMTT, destination is populated in 'sub/locator' fields.
        3.Inventory transfer: Transaction type 'Move order transfer'. For this type of MMTT,
         destination is populated in 'transfer_ sub/locator' fields.
         Transaction type is referred in the document for simplicity sake,
         check in the code should be based on transaction_action_ID and transaction_source_type_ID.
         Query for destination locator is actually simpler, if transfer_to_location and
         transfer_subinventory are NULL, we know that destination is stored in subinventory_code and
         locator_ID columns.
      1.        Query locator_type for P_UPDATE_PARAM_REC.LOCATOR_ID
      2.        Update MMTT with P_UPDATE_PARAM_REC
     */

     /*Fetching the subinventory Type*/
      /* Checking if the dest sub,locator and cartonization Id have been suggested. Returning success
       * if they arent populated.
       */
     IF p_update_param_rec.SUG_SUB_CODE IS NOT NULL OR p_update_param_rec.SUG_LOCATION_ID IS NOT NULL
        OR p_update_param_rec.cartonization_id IS NOT NULL THEN

           l_progress:=25;

           OPEN c_sub_type(p_update_param_rec.sug_sub_code,p_document_rec.organization_id);

           FETCH c_sub_type INTO l_sub_type;

           CLOSE c_sub_type;

           IF (l_sub_type=-1 OR l_sub_type NOT IN (1,2)) THEN
              IF (l_debug=1) THEN
                 print_debug('Invalid Sub',l_module_name,1);
              END IF;

              RAISE FND_API.G_EXC_ERROR;
           END IF;

           l_progress:=27;

        /*Deliver transaction updating sub_code and locator_id ,else transfer sub,transfer sub,transfer locator */
        IF (l_debug=1) THEN
           print_debug('l_sub_type = '||l_sub_type,l_module_name,1);
           print_debug('p_document_rec.transaction_action_id = '||p_document_rec.transaction_action_id,l_module_name,1);
           print_debug('p_document_rec.transaction_source_type_id = '||p_document_rec.transaction_source_type_id,l_module_name,1);

        END IF;

        IF ((l_sub_type<>2)AND ((p_document_rec.transaction_action_id=G_ACTION_INTRANSITRECEIPT) OR
               (p_document_rec.transaction_action_id=G_ACTION_RECEIPT AND p_document_rec.transaction_source_type_id IN (G_SOURCETYPE_PURCHASEORDER,G_SOURCETYPE_RMA)))) THEN

           IF (l_debug=1) THEN
              print_debug('Deliver transaction, update sub/loc.',l_module_name,1);
           END IF;

           UPDATE MTL_material_transactions_temp
              SET subinventory_code   = p_update_param_rec.sug_sub_code,
                  locator_id          = p_update_param_rec.sug_location_id,
                  cartonization_id    = p_update_param_rec.cartonization_id
            WHERE transaction_temp_id = p_source_task_id
              AND organization_id     = p_document_rec.organization_id;

         ELSE
           IF (l_debug=1) THEN
              print_debug('Transfer transaction, update transfer sub/loc.',l_module_name,1);
           END IF;

          UPDATE MTL_material_transactions_temp
              SET transfer_subinventory = p_update_param_rec.sug_sub_code,
                  transfer_to_location  = p_update_param_rec.sug_location_id,
                  cartonization_id      = p_update_param_rec.cartonization_id
            WHERE transaction_temp_id   = p_source_task_id
              AND organization_id       = p_document_rec.organization_id;

        END IF;
          l_progress:=30;

     END IF;

     /*If the suggestion is not system suggested locator then Update suggested capacity*/
     l_progress:=40;

     OPEN c_orig_sugges(p_document_rec.parent_line_id);

     FETCH c_orig_sugges INTO l_orig_sugges;

     CLOSE c_orig_sugges;

     l_progress:=50;
     IF (l_debug=1) THEN
        print_debug('Original suggested Sub'||l_orig_sugges.subinventory_code,l_module_name,9);
        print_debug('Original suggested locator'||l_orig_sugges.locator_id,l_module_name,9);

     END IF;

     IF l_orig_sugges.subinventory_code<>p_update_param_rec.sug_sub_code OR
          l_orig_sugges.locator_id<>p_update_param_rec.sug_location_id THEN

        IF (l_debug=1) THEN
           print_debug('Suggested Capacity of Locator needs to be updated',l_module_name,9);
        END IF;

        l_progress:=60;

        IF  (p_update_param_rec.sug_location_id IS NOT NULL) THEN
           inv_loc_wms_utils.update_loc_sugg_cap_wo_empf(
              x_return_status              => l_return_status
            , x_msg_count                  => l_msg_count
            , x_msg_data                   => l_msg_data
            , p_organization_id            => p_document_rec.organization_id
            , p_inventory_location_id      => p_update_param_rec.sug_location_id
            , p_inventory_item_id          => p_document_rec.inventory_item_id
            , p_primary_uom_flag           => 'Y'
            , p_transaction_uom_code       => NULL
            , p_quantity                   => p_document_rec.primary_quantity
            );
        END IF;

        IF (l_debug=1) THEN
          print_debug('Return status is'||l_return_status,l_module_name,9);
        END IF;

        IF (l_return_status<>fnd_api.g_ret_sts_success) THEN

          IF (l_debug=1) THEN
             print_debug(' error while updating suggested locator capacity',l_module_name,9);
          END IF;

        END IF;

     END IF;

     fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

     EXCEPTION
        WHEN fnd_api.g_exc_error THEN
           IF (l_debug=1) THEN
                print_debug('Error obatined at'||l_progress,l_module_name,1);
              END IF;
              x_return_status:=FND_API.G_RET_STS_ERROR;
              /*Message or error code to be populated for Operation PLan Instance Id Null*/

        WHEN OTHERS THEN

             x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
             IF (l_debug=1) THEN
               print_debug('Unexpected Error'||SQLERRM||'at '||l_progress,l_module_name,3);
             END IF;
             IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
               fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
             END IF;
             fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

     END activate;


     -- The revert_crossdock API reverts a sales order or wip crossdock by
     -- 1. Null out crossdock related data on MOL
     -- 2. notify wip or wsh that material should still be backordered.
     -- Ideally this api should belong to WMSCRDKB.pls,
     -- put it here because WMSCRDKB.pls is tripple maintained and
     -- I try to avoid introducing a dependency on WSH_INTERFACE_EXT_GRP

PROCEDURE revert_crossdock
  (x_return_status                  OUT   NOCOPY VARCHAR2
   , x_msg_count                    OUT   NOCOPY NUMBER
   , x_msg_data                     OUT   NOCOPY VARCHAR2
   , p_move_order_line_id           IN NUMBER
   , p_crossdock_type               IN NUMBER
   , p_backorder_delivery_detail_id IN NUMBER
   , p_repetitive_line_id           IN NUMBER
   , p_operation_seq_number         IN NUMBER
   , p_inventory_item_id            IN NUMBER
   , p_primary_quantity             IN NUMBER
   )
  IS
     l_debug          NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_return_status  VARCHAR2(1);
     l_msg_count      NUMBER;
     l_msg_data       VARCHAR2(400);
     l_progress       NUMBER;
     l_module_name      VARCHAR2(30)   := 'REVERT_CROSSDOCK';

     l_detail_info_tab WSH_INTERFACE_EXT_GRP.delivery_details_Attr_tbl_Type;
     l_in_rec          WSH_INTERFACE_EXT_GRP.detailInRecType;
     l_out_Rec         WSH_INTERFACE_EXT_GRP.detailOutRecType;
     l_api_version_number NUMBER := 1.0;

     l_rsv_rec inv_reservation_global.mtl_reservation_rec_type;
     l_original_serial_number inv_reservation_global.serial_number_tbl_type;
     l_organization_id NUMBER;
     l_cur_rel_status VARCHAR2(1);

BEGIN
   IF (l_debug = 1) THEN
      print_debug('Entered. ', l_module_name,1);
      print_debug('  p_backorder_delivery_detail_id = '||p_backorder_delivery_detail_id, l_module_name,1);
      print_debug('  p_crossdock_type = '||p_crossdock_type, l_module_name,1);
      print_debug('  p_move_order_line_id = '||p_move_order_line_id, l_module_name,1);
      print_debug('  p_repetitive_line_id = '||p_repetitive_line_id, l_module_name,1);
      print_debug('  p_operation_seq_number = '||p_operation_seq_number, l_module_name,1);
      print_debug('  p_inventory_item_id = '||p_inventory_item_id, l_module_name,1);
      print_debug('  p_primary_quantity = '||p_primary_quantity, l_module_name,1);

   END IF;

   l_progress := 10;

   x_return_status := FND_API.g_ret_sts_success;
   SAVEPOINT sp_revert_crossdock;

   l_progress := 20;

   UPDATE mtl_txn_request_lines
     SET  backorder_delivery_detail_id = NULL
     , to_subinventory_code = NULL
     , to_locator_id = NULL
     , crossdock_type = NULL
     WHERE  line_id = p_move_order_line_id
     returning organization_id INTO l_organization_id;

   l_progress := 30;

   IF p_crossdock_type = 2 THEN
      l_progress := 40;

      IF (l_debug = 1) THEN
         print_debug('Before calling wms_wip_integration.unallocate_material.', l_module_name,1);
      END IF;

      wms_wip_integration.unallocate_material
        (
         p_wip_entity_id                => p_backorder_delivery_detail_id
         , p_operation_seq_num          => p_operation_seq_number
         , p_inventory_item_id          => p_inventory_item_id
         , p_repetitive_schedule_id     => p_repetitive_line_id
         , p_primary_quantity           => p_primary_quantity
         , x_return_status              => l_return_status
         , x_msg_data                   => l_msg_data
         );

      l_progress := 50;

      IF l_return_status <>FND_API.g_ret_sts_success THEN
         IF (l_debug=1) THEN
            print_debug('wms_wip_integration.unallocate_material returned with x_return_status = '||l_return_status, l_module_name,1);
         END IF;

         RAISE FND_API.G_EXC_ERROR;

      END IF;

    ELSE
      IF (l_debug = 1) THEN
         print_debug('revert sales order crossdock.', l_module_name,1);
      END IF;

      BEGIN
	 SELECT released_status
	   INTO l_cur_rel_status
	   FROM wsh_delivery_details
	   WHERE delivery_detail_id = p_backorder_delivery_detail_id;

	 IF (l_debug = 1) THEN
	    print_debug('current released_status = '||l_cur_rel_status,l_module_name,1);
	 END IF;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('Unable to query WDD.', l_module_name,1);
	    END IF;
	    l_cur_rel_status := 'S';
      END;

      l_progress := 60;

      IF l_cur_rel_status = 'S' THEN
	 l_detail_info_tab(1).delivery_detail_id := p_backorder_delivery_detail_id;
	 l_detail_info_tab(1).released_status := 'R';
	 l_detail_info_tab(1).move_order_line_id := NULL;

	 l_in_rec.caller := 'WMS_XDOCK_WMSOPIBB';
	 l_in_rec.action_code := 'UPDATE';

	 l_return_status := fnd_api.g_ret_sts_success;
	 WSH_INTERFACE_EXT_GRP.Create_Update_Delivery_Detail
	   ( p_api_version_number => 1.0
	     , p_init_msg_list      => fnd_api.g_false
	     , p_commit             => fnd_api.g_false
	     , x_return_status      => l_return_status
	     , x_msg_count          => l_msg_count
	     , x_msg_data           => l_msg_data
	     , p_detail_info_tab    => l_detail_info_tab
	     , p_in_rec             => l_in_rec
	     , x_out_rec            => l_out_rec
	     );

	 IF l_return_status <> fnd_api.g_ret_sts_success
	   THEN
	    IF (l_debug = 1)
	      THEN
	       print_debug
		 ( 'Error status from WSH_INTERFACE_GRP.Create_Update_Delivery_Detail: '
		   || l_return_status
		   , l_module_name, 1
		   );
	    END IF;

	    IF x_return_status = fnd_api.g_ret_sts_error
	      THEN
	       RAISE fnd_api.g_exc_error;
	     ELSE
	       RAISE fnd_api.g_exc_unexpected_error;
	    END IF;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('Successfully updated the WDD record to status ''R'''
			   , l_module_name, 1);
	    END IF;
	 END IF;
      END IF; --IF l_cur_rel_status = 'S' THEN

      l_progress := 70;

      --{{
      --  Cancel an operation plan for crossdocking to shipping should delete the reservation.
      --}}
      l_rsv_rec.organization_id := l_organization_id;
      l_rsv_rec.inventory_item_id := p_inventory_item_id;
      l_rsv_rec.demand_source_line_detail := p_backorder_delivery_detail_id;
      l_rsv_rec.supply_source_type_id := inv_reservation_global.g_source_type_rcv; -- receiving 27

      IF (l_debug = 1) THEN
         print_debug('Before calling inv_reservation_pvt.delete_reservation. ', l_module_name,1);
         print_debug('p_api_version_number = '||l_api_version_number, l_module_name,1);
         print_debug('p_init_msg_lst = '||FND_API.g_false, l_module_name,1);
         print_debug('l_rsv_rec.organization_id = '||l_rsv_rec.organization_id, l_module_name,1);
         print_debug('l_rsv_rec.inventory_item_id = '||l_rsv_rec.inventory_item_id, l_module_name,1);
         print_debug('l_rsv_rec.demand_source_line_detail = '||l_rsv_rec.demand_source_line_detail, l_module_name,1);
         print_debug('l_rsv_rec.supply_source_type_id = '||l_rsv_rec.supply_source_type_id, l_module_name,1);
         print_debug('p_validation_flag = NULL', l_module_name,1);

      END IF;
      inv_reservation_pvt.delete_reservation
        (
         p_api_version_number=> l_api_version_number
         , p_init_msg_lst   =>  FND_API.g_false
         , x_return_status  => l_return_status
         , x_msg_count      => l_msg_count
         , x_msg_data       => l_msg_data
         , p_rsv_rec        => l_rsv_rec
         , p_original_serial_number => l_original_serial_number
         , p_validation_flag    => NULL
         );
      IF (l_debug = 1) THEN
         print_debug('After calling inv_reservation_pvt.delete_reservation. ', l_module_name,1);
         print_debug('x_return_status = '||l_return_status, l_module_name,1);
          print_debug('x_msg_count   = '||l_msg_count, l_module_name,1);
          print_debug('x_msg_data   = '||l_msg_data, l_module_name,1);
      END IF;

      IF l_return_status <>FND_API.g_ret_sts_success THEN
         IF (l_debug=1) THEN
            print_debug('inv_reservation_pvt.delete_reservation. returned with x_return_status = '||l_return_status, l_module_name,1);
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_progress := 80;

   END IF;

   IF (l_debug = 1) THEN
          print_debug('Before exiting. ', l_module_name,1);
          print_debug('  x_return_status = '||x_return_status, l_module_name,1);
          print_debug('  x_msg_count = '||x_msg_count, l_module_name,1);
          print_debug('  x_msg_data = '||x_msg_data, l_module_name,1);
   END IF;
EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      IF (l_debug=1) THEN
         print_debug('fnd_api.g_exc_error. l_progress = '|| l_progress, l_module_name,1);
      END IF;
      x_return_status:=FND_API.G_RET_STS_ERROR;
      ROLLBACK TO sp_revert_crossdock;

  WHEN fnd_api.g_exc_unexpected_error THEN

     x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
     IF (l_debug=1) THEN
        print_debug('fnd_api.g_exc_unexpected_error.  l_progress = '|| l_progress, l_module_name,1);
     END IF;

     ROLLBACK TO sp_revert_crossdock;

   WHEN OTHERS THEN
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      IF (l_debug=1) THEN
         print_debug('fnd_api.g_exc_unexpected_error.  l_progress = '|| l_progress, l_module_name,1);
      END IF;

      ROLLBACK TO sp_revert_crossdock;

END revert_crossdock;


/**
    *    <b> Complete </b>:
    * <p>This API is the document handler for Inbound document records and is called from
    *    Complete_operation_instance.
    *
    *    This API is the document handler for inbound document records and it is called from Complete_operation_instance.
    *    This API handles both situations where current operation is the last step and current operation is not the last step of a plan.
    *    It maintains correct states for document tables (MMTT, MTRL, crossdock related tables etc.) for both cases.
    *  @param x_return_status      -Return Status
    *  @param x_msg_data           -Returns Message Data
    *  @param x_msg_count          -Returns the message count
    *  @param x_source_task_id     -Returns the transaction_temp_ID for the MMTT record created for the next operation
    *  @param x_error_code         -Returns Appropriate error code in case of any error.
    *  @param p_source_task_id     -Identifier of the document record.
    *  @param p_document_rec       -Record Type of MMTT
    *  @param p_operation_type_id  -Operation Type id of the current operation.
    *  @param p_next_operation_type_id  -Operation Type id of the nextt operation.
    *  @param p_sug_to_sub_code    -Suggested subinventory code in WOOI
    *  @param p_sug_to_locator_id  -Suggested locator id in WOOI
    *  @param p_is_last_operation_flag  - Flag to indicate if the current operation is the last step in the plan
    *
   **/
      PROCEDURE complete
      (
       x_return_status        OUT  NOCOPY    VARCHAR2
       , x_msg_data           OUT  NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
       , x_msg_count          OUT  NOCOPY    NUMBER
       , x_source_task_id     OUT  NOCOPY    NUMBER
       , x_error_code         OUT  NOCOPY    NUMBER
       , p_source_task_id     IN             NUMBER
       , p_document_rec       IN             mtl_material_transactions_temp%ROWTYPE
       , p_operation_type_id  IN             NUMBER
       , p_next_operation_type_id  IN        NUMBER
       , p_sug_to_sub_code         IN        VARCHAR2 DEFAULT NULL
       , p_sug_to_locator_id       IN        NUMBER DEFAULT NULL
       , p_is_last_operation_flag  IN        VARCHAR2
       , p_subsequent_op_plan_id   IN        NUMBER DEFAULT NULL
       ) IS

          l_module_name         VARCHAR2(30)   := 'COMPLETE';
          l_debug               NUMBER         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
          l_progress            NUMBER;
          l_return_status       VARCHAR2(1);
          l_msg_count           NUMBER;
          l_msg_data            VARCHAR2(400);

          l_mol_uom_code        VARCHAR2(3);
          l_qty_in_mol_uom      NUMBER;
          l_dest_locator_type   NUMBER;
          l_dest_subinventory_type NUMBER;

          l_new_txn_action_id      NUMBER;
          l_new_txn_source_type_id NUMBER;
          l_new_txn_type_id    NUMBER;
          l_new_wms_task_type_id   NUMBER;
          l_new_subinventory_code  VARCHAR2(10);
          l_new_locator_id         NUMBER;
          l_new_transfer_to_sub    VARCHAR2(10);
          l_new_transfer_to_loc    NUMBER;
          l_new_lpn_id             NUMBER;
          l_lot_control_code       NUMBER;
          l_serial_control_code    NUMBER;
          l_backorder_delivery_detail_id NUMBER;
          l_locator_type           NUMBER;
          l_subinventory_type      NUMBER;
          -- new local variables for workflow support
          l_wf                     NUMBER;
	  --Bug# 7716519  local variables to store sec_qty and sec_uom
	  l_mol_sec_uom_code    VARCHAR2(3);
	  l_mol_sec_qty  NUMBER;
	  l_sec_qty_in_mol_uom NUMBER;  --Bug 7716519

          CURSOR c_mmtt_data_rec IS
             SELECT
               mmtt.lpn_id,
               mmtt.transfer_lpn_id,
               mmtt.content_lpn_id,
               mmtt.operation_plan_id,
               Nvl(msi.subinventory_type, 1) subinventory_type,
               mmtt.move_order_line_id,
               mmtt.operation_seq_num,
               mmtt.repetitive_line_id,
               mmtt.primary_quantity,
               mmtt.inventory_item_id,
               mmtt.reason_id,
               mol.crossdock_type,
               mol.backorder_delivery_detail_id,
               mmtt.transfer_to_location,
               mmtt.locator_id
               FROM mtl_material_transactions_temp mmtt,
               mtl_secondary_inventories msi,
               mtl_txn_request_lines mol
               WHERE mmtt.transaction_temp_id = p_source_task_id
               AND Nvl(mmtt.transfer_subinventory, mmtt.subinventory_code) = msi.secondary_inventory_name (+)
               AND mmtt.organization_id = msi.organization_id (+)
               AND mol.line_id = mmtt.move_order_line_id;

/*
     CURSOR c_locator_type(v_location_id NUMBER,v_org_id NUMBER) IS
       SELECT inventory_location_type
        FROM mtl_item_locations
        WHERE inventory_location_id=v_location_id
        AND organization_id=v_org_id;
*/

     CURSOR c_subinventory_type(v_subinventory_code VARCHAR2, v_org_id NUMBER) IS
        SELECT subinventory_type
          FROM mtl_secondary_inventories
          WHERE secondary_inventory_name = v_subinventory_code
          AND organization_id = v_org_id;

         l_mmtt_data_rec c_mmtt_data_rec%ROWTYPE;

      BEGIN


         x_return_status := FND_API.G_RET_STS_SUCCESS;
         l_progress      := 10;

         IF (l_debug=1) THEN
            print_debug('Entered. ',l_module_name,1);
            print_debug('p_source_task_id => '||p_source_task_id,l_module_name,1);
            print_debug('p_document_rec.transaction_temp_id => '||p_document_rec.transaction_temp_id,l_module_name,1);
            print_debug('p_operation_type_id => '||p_operation_type_id,l_module_name,1);
            print_debug('p_next_operation_type_id => '||p_next_operation_type_id,l_module_name,1);
            print_debug('p_is_last_operation_flag => '||p_is_last_operation_flag,l_module_name,1);
            print_debug('p_subsequent_op_plan_id  ==>'||p_operation_type_id,l_module_name,3);

         END IF;

         -- validate input parameters

         IF p_source_task_id IS NULL THEN
            IF (l_debug=1) THEN
               print_debug('Invalid input param. p_source_task_id Cannot be NULL.',l_module_name,4);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF p_operation_type_id IS NULL THEN
            IF (l_debug=1) THEN
               print_debug('Invalid input param. p_operation_type_id Cannot be NULL.',l_module_name,4);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF p_document_rec.transaction_temp_id IS NULL THEN
            IF (l_debug=1) THEN
               print_debug('Invalid input param. p_document_rec Cannot be NULL.',l_module_name,4);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF p_is_last_operation_flag NOT IN ('N', 'Y') THEN
            IF (l_debug=1) THEN
               print_debug('Invalid input param. p_is_last_operation_flag has to be either Y or N.',l_module_name,4);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         l_progress := 15;

         OPEN c_mmtt_data_rec;

         FETCH c_mmtt_data_rec INTO l_mmtt_data_rec;
         IF c_mmtt_data_rec%notfound THEN
            IF (l_debug=1) THEN
               print_debug('Invalid p_source_task_id : '||p_source_task_id,l_module_name,1);
               RAISE fnd_api.G_EXC_ERROR;
            END IF;
         END IF;
         CLOSE c_mmtt_data_rec;


         l_progress := 20;

         IF p_is_last_operation_flag = 'Y' THEN
            -- Logic to handle document tables if the current operation is the last step in an plan.
            -- It also handles the case where operation plan is not stamped on MMTT.

            IF (l_debug=1) THEN
               print_debug('Logic to handle last operation within the plan.',l_module_name,4);
            END IF;


            IF (l_debug=1) THEN
               print_debug('p_document_rec.parent_line_id = '||p_document_rec.parent_line_id,l_module_name,4);
            END IF;

            -- Since this is the last step, we need to delete the parent (original) MMTT record.
            -- When operation_plan_id is not stamped on MMTT, parent_line_id will also be NULL,
            -- in which case delete parent MMTT will not be necessary.

            IF p_document_rec.parent_line_id IS NOT NULL THEN
               IF (l_debug=1) THEN
                  print_debug('p_document_rec.parent_line_id is not null, therefore need to delete parent MMTT record',l_module_name,4);
                  print_debug('Before calling inv_trx_util_pub.delete_transaction with following parameters: ',l_module_name,4);

                  print_debug('p_transaction_temp_id => '||p_document_rec.parent_line_id,l_module_name,4);
               END IF;

               l_progress := 30;

               inv_trx_util_pub.delete_transaction
                 (x_return_status         => l_return_status
                  , x_msg_data            => l_msg_data
                  , x_msg_count           => l_msg_count
                  , p_transaction_temp_id => p_document_rec.parent_line_id
                  , p_update_parent       => FALSE
                  );

               l_progress := 40;

               IF (l_debug=1) THEN
                  print_debug('After calling inv_trx_util_pub.delete_transaction.',l_module_name,4);

                  print_debug('l_return_status => '||l_return_status,l_module_name,4);
                  print_debug('l_msg_data => '||l_msg_data,l_module_name,4);
                  print_debug('l_msg_count => '||l_msg_count,l_module_name,4);
               END IF;

               IF l_return_status <>FND_API.g_ret_sts_success THEN
                  IF (l_debug=1) THEN
                     print_debug('inv_trx_util_pub.delete_transaction finished with error. l_return_status = ' || l_return_status,l_module_name,4);
                  END IF;

                  RAISE FND_API.G_EXC_ERROR;
               END IF;

            END IF;  -- p_document_rec.parent_line_id IS NOT NULL

            IF p_operation_type_id = g_op_type_drop THEN
               -- current operation type is drop
               IF (l_debug=1) THEN
                  print_debug('Current operation type is DROP '||l_return_status,l_module_name,4);
               END IF;


               -- This is the last step in the operation plan,
               -- therefore need to call complete_crossdock

               l_progress := 42;

                 SELECT backorder_delivery_detail_id
                   INTO l_backorder_delivery_detail_id
                   FROM mtl_txn_request_lines
                   WHERE line_id = p_document_rec.move_order_line_id;

                 l_progress := 44;

                 IF (l_debug=1) THEN
                    print_debug('l_backorder_delivery_detail_id = '||l_backorder_delivery_detail_id, l_module_name,4);
                 END IF;

                 IF l_backorder_delivery_detail_id IS NOT NULL THEN


                    -- Although it appears to be the last step, it is not necessary the last step within
                    -- a plan. It could be that this plan has been aborted.

                    -- So we need to check for two things:
                    -- 1. If the current drop to subinventory is not inventory sub, we should by pass
                    --    complete_crossdock call.
                    -- 2. If the current drop to sub is inventory sub, BUT the current drop is for an
                    --    aborted plan, and the aborted operation was NOT the last step in the plan.
                    --    However it is not practical to check aborted operations since that requires
                    --    querying WOOIH. So we will make sure abort does NOT happen at the last step.
                    --    It actually makes sense that abort at the last step does not buy us much.
                    --    Then we should not call complete_crossdock, rather should call revert_crossdock.
                    -- 3. Need to do one final check for reservable and lpn-controlled. (Or should it be
                    --    taken care of by frond end?)

                    -- THE ABOVE WAS THE ORIGINAL DISCUSSION
                    -- Now it gets simplified to:
                    -- Call complete_crossdock if it is storage sub. call revert_crossdock it is receivint sub.

                    IF (l_debug=1) THEN
                       print_debug('l_mmtt_data_rec.subinventory_type  = '||l_mmtt_data_rec.subinventory_type , l_module_name,4);
                       print_debug('l_mmtt_data_rec.operation_plan_id  = '||l_mmtt_data_rec.operation_plan_id, l_module_name,4);
                    END IF;

                    --{{
                    --  When operation plan is aborted before dropping to inventory
                    --  should retain the crossdock. And load/drop the LPN again
                    --  should continue the crossdocking
                    --}}

                    IF l_mmtt_data_rec.subinventory_type = 2 THEN
                       -- Only call crossdock related stuff if not rcv sub
                       -- revert the crossdock if dropping to rcv sub and last step.
                       -- It means plan has been aborted.
                       NULL;

                     ELSE


                       IF (l_debug=1) THEN
                          print_debug(' Move order line has been crossdocked. And drop to sub is storage. l_backorder_delivery_detail_id = '||l_backorder_delivery_detail_id, l_module_name,4);
                          print_debug(' Before calling WMS_Cross_Dock_Pvt.complete_crossdock with following parameters: ', l_module_name,4);
                          print_debug('p_org_id => '|| p_document_rec.organization_id, l_module_name,4);
                          print_debug('p_temp_id => '|| p_source_task_id, l_module_name,4);
                       END IF;

                       l_progress := 46;

                       WMS_Cross_Dock_Pvt.complete_crossdock
                         (p_org_id => p_document_rec.organization_id
                          , p_temp_id => p_source_task_id
                          , x_return_status => l_return_status
                          , x_msg_count => l_msg_count
                          , x_msg_data => l_msg_data
                          );

                       l_progress := 48;

                       IF (l_debug=1) THEN
                          print_debug(' After calling WMS_Cross_Dock_Pvt.complete_crossdock. ', l_module_name,4);
                          print_debug('l_return_status => '|| l_return_status, l_module_name,4);
                          print_debug('l_msg_count => '|| l_msg_count, l_module_name,4);
                          print_debug('l_msg_data => '|| l_msg_data, l_module_name,4);
                       END IF;

                       IF l_return_status <>FND_API.g_ret_sts_success THEN
                          IF (l_debug=1) THEN
                             print_debug('WMS_Cross_Dock_Pvt.complete_crossdock finished with error. l_return_status = ' || l_return_status,l_module_name,4);
                          END IF;

                          RAISE FND_API.G_EXC_ERROR;
                       END IF;

--                    END IF; -- IF l_mmtt_data_rec.operation_plan_id IS NULL


                    END IF;  --  IF l_mmtt_data_rec.subinventory_type = 2


                 END IF; -- IF l_backorder_delivery_detail_id IS NOT NULL


                 -- Multi-step putaway workflow support
                 IF (l_debug=1) THEN
                    print_debug('Checking if we need to call workflow wrapper',l_module_name,4);
                 END IF;

                 IF l_mmtt_data_rec.subinventory_type = 1 THEN  -- inventory sub
                    IF (l_debug=1) THEN
                       print_debug('Dropping to inventory sub',l_module_name,4);
                    END IF;

                    IF (l_mmtt_data_rec.reason_id IS NOT NULL AND
                        Nvl(l_mmtt_data_rec.transfer_to_location,l_mmtt_data_rec.locator_id) <> p_sug_to_locator_id) THEN
                         IF (l_debug=1) THEN
                         print_debug('We are in last operation, dropping subinv type is inventory, and reason id is not null',l_module_name,4);
                         print_debug('We are going to do workflow processing...',l_module_name,4);
                       END IF;

                       l_wf := 0;

                       BEGIN
                          SELECT 1
                          INTO   l_wf
                          FROM   mtl_transaction_reasons
                          WHERE  reason_id = l_mmtt_data_rec.reason_id
                          AND    workflow_name IS NOT NULL
                          AND    workflow_name <> ' '
                          AND    workflow_process IS NOT NULL
                          AND    workflow_process <> ' ';
                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                            l_wf := 0;
                        END;

                        IF l_wf > 0 THEN

                          IF (l_debug = 1) THEN
                            print_debug('WF exists for this reason code: ' || l_mmtt_data_rec.reason_id,l_module_name,4);
                            print_debug('Calling workflow wrapper FOR location',l_module_name,4);
                            print_debug('dest sub: ' || p_sug_to_sub_code,l_module_name,4);
                            print_debug('dest loc: ' || p_sug_to_locator_id,l_module_name,4);
                          END IF;

                          -- Calling Workflow
                          wms_workflow_wrappers.wf_wrapper(
                            p_api_version         => 1.0
                          , p_init_msg_list       => fnd_api.g_false
                          , p_commit              => fnd_api.g_false
                          , x_return_status       => x_return_status
                          , x_msg_count           => x_msg_count
                          , x_msg_data            => x_msg_data
                          , p_org_id              => p_document_rec.organization_id
                          , p_rsn_id              => l_mmtt_data_rec.reason_id
                          , p_calling_program     => 'complete - for loc discrepancy - loose'
                          , p_tmp_id              => p_source_task_id
                          , p_quantity_picked     => NULL
                          , p_dest_sub            => p_sug_to_sub_code
                          , p_dest_loc            => p_sug_to_locator_id
                          );

                          IF (l_debug = 1) THEN
                            print_debug('After Calling WF Wrapper',l_module_name,4);
                          END IF;

                          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                            IF (l_debug = 1) THEN
                              print_debug('Error callinf WF wrapper',l_module_name,4);
                            END IF;

                            fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
                            fnd_msg_pub.ADD;
                            RAISE fnd_api.g_exc_unexpected_error;
                          ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
                            IF (l_debug = 1) THEN
                              print_debug('Error calling WF wrapper',l_module_name,4);
                            END IF;

                            fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
                            fnd_msg_pub.ADD;
                            RAISE fnd_api.g_exc_error;
                          END IF;
                        END IF; -- END IF (l_wf > 0)
                    END IF; -- END IF reason id is not null
                 END IF; -- END IF inventory sub

                 -- First need to delete current MMTT record.
                 -- Only delete MMTT for Receiving transfer or receiving deliver.
                 -- Inventory TM will delete MMTT for inventory and WIP putaway.

                 IF (l_debug=1) THEN

                    print_debug('p_document_rec.TRANSACTION_ACTION_ID = '||p_document_rec.TRANSACTION_ACTION_ID,l_module_name,4);
                    print_debug('p_document_rec.TRANSACTION_SOURCE_TYPE_ID = '||p_document_rec.TRANSACTION_SOURCE_TYPE_ID,l_module_name,4);
                 END IF;

                 IF (p_document_rec.transaction_action_id = G_ACTION_RECEIPT
                     AND p_document_rec.transaction_source_type_id = g_sourcetype_purchaseorder
                     -- PO receipt (1, 27)
                     ) OR
                   (p_document_rec.transaction_action_id = G_ACTION_RECEIPT
                    AND p_document_rec.transaction_source_type_id = g_sourcetype_rma
                    -- RMA receipt (12, 27)
                     ) OR
                   (p_document_rec.transaction_action_id = G_ACTION_RECEIPT
                    AND p_document_rec.transaction_source_type_id = g_sourcetype_moveorder
                    -- Consolidated inbound move order receipt (4, 27)
                     ) OR
                   (p_document_rec.transaction_action_id = G_ACTION_INTRANSITRECEIPT
                    AND p_document_rec.transaction_source_type_id = g_sourcetype_inventory
                    -- Intransit shipment receipt (13, 12)
                     ) OR
                   (p_document_rec.transaction_action_id = G_ACTION_INTRANSITRECEIPT
                    AND p_document_rec.transaction_source_type_id = G_SOURCETYPE_INTREQ
                    ) THEN

                    -- Before deleting MMTT need to update quantity_detailed on move order line
                    -- And need to check if UOM on MOL and MMTT match.

                    IF (l_debug=1) THEN
                       print_debug('This is a receipt transaction, need to delete MMTT. '||l_return_status,l_module_name,4);
                    END IF;

                    l_progress := 49;

                    SELECT uom_code,secondary_uom_code                --Bug#7716519, stored sec_uom from MTRL in l_mol_sec_uom_code
                      INTO l_mol_uom_code,l_mol_sec_uom_code
                      FROM mtl_txn_request_lines
                      WHERE line_id = p_document_rec.move_order_line_id;
                    l_progress := 50;

                    IF (l_debug=1) THEN

                       print_debug('l_mol_uom_code = '||l_mol_uom_code,l_module_name,4);
                       print_debug('p_document_rec.transaction_uom = '||p_document_rec.transaction_uom,l_module_name,4);
                    END IF;

                    l_qty_in_mol_uom := p_document_rec.transaction_quantity;
		    l_mol_sec_qty := p_document_rec.secondary_transaction_quantity;  --Bug#7716519

                    -- If UOM on MOL does not match that on MMTT,
                    -- need to convert MMTT quantity to that of MOL's UOM
                    IF l_mol_uom_code <> p_document_rec.transaction_uom THEN
                       IF (l_debug=1) THEN
                          print_debug('MMTT and MOL UOM do not match, need to convert quantity.',l_module_name,4);
                          print_debug('Before calling INV_Convert.inv_um_convert with parameters:', l_module_name,4);
                          print_debug('item_id => '||p_document_rec.inventory_item_id, l_module_name,4);
                          print_debug('from_quantity => '||p_document_rec.transaction_quantity, l_module_name,4);
                          print_debug('from_unit => '||p_document_rec.transaction_uom, l_module_name,4);
                             print_debug('to_unit => '||l_mol_uom_code, l_module_name,4);
                       END IF;

                       l_progress := 60;

                       l_qty_in_mol_uom := INV_Convert.inv_um_convert
                         (item_id         => p_document_rec.inventory_item_id,
                          precision        => null,
                          from_quantity => p_document_rec.transaction_quantity,
                          from_unit        => p_document_rec.transaction_uom,
                          to_unit       => l_mol_uom_code,
                          from_name        => null,
                          to_name       => null);

                       l_progress := 70;

                       IF (l_debug=1) THEN
                          print_debug('Drop for receiving txn - After calling INV_Convert.inv_um_convert. l_qty_in_mol_uom = '||l_qty_in_mol_uom, l_module_name,4);

                       END IF;

                    END IF; --  IF l_mol_uom_code <> p_document_rec.transaction_uom
                    --Start changes Bug#7716519, in case the sec_uom_code is not same in MTRL and MMTT,need to convert qty,
		     --Changes parallel to primary_qty
		     IF l_mol_sec_uom_code <> p_document_rec.secondary_uom_code THEN
                       IF (l_debug=1) THEN
                          print_debug('MMTT and MOL UOM do not match, need to convert secondary quantity.',l_module_name,4);
                          print_debug('Before calling INV_Convert.inv_um_convert with parameters:', l_module_name,4);
                          print_debug('item_id => '||p_document_rec.inventory_item_id, l_module_name,4);
                          print_debug('from_quantity => '||p_document_rec.secondary_transaction_quantity, l_module_name,4);
                          print_debug('from_unit => '||p_document_rec.secondary_uom_code, l_module_name,4);
                             print_debug('to_unit => '||l_mol_sec_uom_code, l_module_name,4);
                       END IF;


                       l_sec_qty_in_mol_uom := INV_Convert.inv_um_convert
                         (item_id         => p_document_rec.inventory_item_id,
                          precision        => null,
                          from_quantity => p_document_rec.secondary_transaction_quantity,
                          from_unit        => p_document_rec.secondary_uom_code,
                          to_unit       => l_mol_sec_uom_code,
                          from_name        => null,
                          to_name       => null);

                       l_progress := 70.1;

                       IF (l_debug=1) THEN
                          print_debug('Drop for receiving txn - After calling INV_Convert.inv_um_convert. l_sec_qty_in_mol_uom = '||l_sec_qty_in_mol_uom, l_module_name,4);

                       END IF;

                    END IF;
                    -- end of changes Bug#7716519
                    l_progress := 80;

                    UPDATE mtl_txn_request_lines
                      SET quantity_detailed = quantity_detailed - l_qty_in_mol_uom,
		      secondary_quantity_detailed = secondary_quantity_detailed - l_mol_sec_qty,      --Bug#7716519
                      lpn_id =(SELECT Nvl(mmtt.transfer_lpn_id, mmtt.content_lpn_id)
                               FROM mtl_material_transactions_temp mmtt
                               WHERE mmtt.transaction_temp_id = p_document_rec.transaction_temp_id),
                      wms_process_flag = 1  -- Bug 4657716
                      WHERE line_id = p_document_rec.move_order_line_id;

                    l_progress := 90;


                    IF (l_debug=1) THEN

                       print_debug('Before calling inv_trx_util_pub.delete_transaction with following parameters: ',l_module_name,4);

                       print_debug('p_transaction_temp_id => '||p_source_task_id,l_module_name,4);
                    END IF;

                    inv_trx_util_pub.delete_transaction
                      (x_return_status         => l_return_status
                       , x_msg_data            => l_msg_data
                       , x_msg_count           => l_msg_count
                       , p_transaction_temp_id => p_source_task_id
             , p_update_parent       => FALSE
                       );

                    IF (l_debug=1) THEN
                       print_debug('Drop - After calling inv_trx_util_pub.delete_transaction.',l_module_name,4);

                       print_debug('l_return_status => '||l_return_status,l_module_name,4);
                       print_debug('l_msg_data => '||l_msg_data,l_module_name,4);
                       print_debug('l_msg_count => '||l_msg_count,l_module_name,4);
                    END IF;

                    IF l_return_status <>FND_API.g_ret_sts_success THEN
                       IF (l_debug=1) THEN
                          print_debug('inv_trx_util_pub.delete_transaction finished with error. l_return_status = ' || l_return_status,l_module_name,4);
                       END IF;

                       RAISE FND_API.G_EXC_ERROR;
                    END IF;

                 END IF; -- p_document_rec.transaction_action_id = G_ACTION_RECEIPT



                 -- If we are dropping to an inventory locator
                 -- we need to close move order line and update quantity_delivered.

                 l_progress := 110;

                 IF (l_debug=1) THEN
                    print_debug('p_document_rec.TRANSFER_SUBINVENTORY= '||p_document_rec.transfer_subinventory,l_module_name,4);
                    print_debug('p_document_rec.subinventory_code = '||p_document_rec.subinventory_code,l_module_name,4);
                 END IF;

                 -- Destination sub/locator can be populated in
                 -- eith transfer_ fields or sub/loc fields.

                 IF p_document_rec.transfer_subinventory IS NOT NULL THEN

                    SELECT subinventory_type
                      INTO l_dest_subinventory_type
                      FROM mtl_secondary_inventories
                      WHERE secondary_inventory_name = p_document_rec.transfer_subinventory
                      AND organization_id = p_document_rec.organization_id;
                  ELSE

                    SELECT subinventory_type
                      INTO l_dest_subinventory_type
                      FROM mtl_secondary_inventories
                      WHERE secondary_inventory_name = p_document_rec.subinventory_code
                      AND organization_id = p_document_rec.organization_id;

                 END IF; -- IF p_document_rec.transfer_subinventory IS NOT NULL

                 l_progress := 120;

                 IF (l_debug=1) THEN
                    print_debug('l_dest_subinventory_type = '||l_dest_subinventory_type,l_module_name,4);
                 END IF;

                 IF l_dest_subinventory_type IS NULL OR
                   l_dest_subinventory_type = 1 THEN  -- NULL or 1 considered inventory sub

                    IF (l_debug=1) THEN
                       print_debug('Dropping into an inventory sub, need to close MOL',l_module_name,4);
                    END IF;

                    IF l_mol_uom_code IS NULL OR
                    l_mol_sec_uom_code IS NULL  -- Bug# 7716519
		    THEN
                       IF (l_debug=1) THEN
                          print_debug('Need to query MOL.uom_code',l_module_name,4);
                       END IF;

                       l_progress := 130;

                       -- if MOL UOM has not been queried previously
                       SELECT uom_code
                         INTO l_mol_uom_code
                         FROM mtl_txn_request_lines
                         WHERE line_id = p_document_rec.move_order_line_id;

                       l_progress := 140;

                       IF (l_debug=1) THEN

                          print_debug('l_mol_uom_code = '||l_mol_uom_code,l_module_name,4);
                          print_debug('p_document_rec.transaction_uom = '||p_document_rec.transaction_uom,l_module_name,4);
			   print_debug('p_document_rec.secondary_uom_code = '||p_document_rec.secondary_uom_code,l_module_name,4);                  --Bug# 7716519
                       print_debug('p_document_rec.secondary_transaction_quantity = '||p_document_rec.secondary_transaction_quantity,l_module_name,4);
                       END IF;

                       l_qty_in_mol_uom := p_document_rec.transaction_quantity;
		       l_mol_sec_qty := p_document_rec.secondary_transaction_quantity;  -- Bug# 7716519

                       -- If UOM on MOL does not match that on MMTT,
                       -- need to convert MMTT quantity to that of MOL's UOM
                       IF l_mol_uom_code <> p_document_rec.transaction_uom THEN
                          IF (l_debug=1) THEN
                             print_debug('MMTT and MOL UOM do not match, need to convert quantity.',l_module_name,4);
                             print_debug('Before calling INV_Convert.inv_um_convert with parameters:', l_module_name,4);
                             print_debug('item_id => '||p_document_rec.inventory_item_id, l_module_name,4);
                             print_debug('from_quantity => '||p_document_rec.transaction_quantity, l_module_name,4);
                             print_debug('from_unit => '||p_document_rec.transaction_uom, l_module_name,4);
                             print_debug('to_unit => '||l_mol_uom_code, l_module_name,4);
                          END IF;

                          l_progress := 150;

                          l_qty_in_mol_uom := INV_Convert.inv_um_convert
                            (item_id         => p_document_rec.inventory_item_id,
                             precision        => null,
                             from_quantity => p_document_rec.transaction_quantity,
                             from_unit        => p_document_rec.transaction_uom,
                             to_unit       => l_mol_uom_code,
                             from_name        => null,
                             to_name       => null);

                          l_progress := 160;

                          IF (l_debug=1) THEN
                             print_debug('Drop to INV - after calling INV_Convert.inv_um_convert. l_qty_in_mol_uom = '||l_qty_in_mol_uom, l_module_name,4);

                          END IF;

                       END IF; --  IF l_mol_uom_code <> p_document_rec.transaction_uom
		        -- start bug# 7716519,changes parallel to primary_qty
		       IF l_mol_sec_uom_code <> p_document_rec.secondary_uom_code THEN
                       IF (l_debug=1) THEN
                          print_debug('MMTT and MOL UOM do not match, need to convert secondary quantity.',l_module_name,4);
                          print_debug('Before calling INV_Convert.inv_um_convert with parameters:', l_module_name,4);
                          print_debug('item_id => '||p_document_rec.inventory_item_id, l_module_name,4);
                          print_debug('from_quantity => '||p_document_rec.secondary_transaction_quantity, l_module_name,4);
                          print_debug('from_unit => '||p_document_rec.secondary_uom_code, l_module_name,4);
                             print_debug('to_unit => '||l_mol_sec_uom_code, l_module_name,4);
                       END IF;


                       l_sec_qty_in_mol_uom := INV_Convert.inv_um_convert
                         (item_id         => p_document_rec.inventory_item_id,
                          precision        => null,
                          from_quantity => p_document_rec.secondary_transaction_quantity,
                          from_unit        => p_document_rec.secondary_uom_code,
                          to_unit       => l_mol_sec_uom_code,
                          from_name        => null,
                          to_name       => null);

                       l_progress := 70;

                       IF (l_debug=1) THEN
                          print_debug('Drop for receiving txn - After calling INV_Convert.inv_um_convert. l_sec_qty_in_mol_uom = '||l_sec_qty_in_mol_uom, l_module_name,4);

                       END IF;

                    END IF; --IF l_mol_sec_uom_code <> p_document_rec.secondary_uom_code, end Bug# 7716519 changes

                    END IF;  --IF l_mol_uom_code IS NULL

                    IF (l_debug=1) THEN
                       print_debug('Before update MOL.quantity_delivered. l_qty_in_mol_uom = '||l_qty_in_mol_uom, l_module_name,4);
		       print_debug('Before update MOL.quantity_delivered. l_sec_qty_in_mol_uom = '||l_mol_sec_qty, l_module_name,4); --Bug# 7716519
                    END IF;

                    l_progress := 170;
                    UPDATE mtl_txn_request_lines
                      SET line_status = g_to_status_closed,
                      quantity_delivered = Nvl(quantity_delivered, 0) + l_qty_in_mol_uom,
		      secondary_quantity_delivered = Nvl(secondary_quantity_delivered, 0) + l_mol_sec_qty  -- Bug# 7716519
                      WHERE line_id = p_document_rec.move_order_line_id;
                    -- No need to update lpn_id when closing the move_order_line,
                    -- not a big deal, just be consistent with earlier patchset
                    l_progress := 180;

                 END IF;  --  IF l_dest_subinventory_type IS NULL OR



             ELSIF p_operation_type_id = g_op_type_inspect THEN
               -- current operation type is inspect
               IF (l_debug=1) THEN
                  print_debug('Current operation type is INSPECT '||l_return_status,l_module_name,4);
               END IF;


               -- First need to delete current MMTT record.
               -- Before deleting MMTT need to update quantity_detailed on move order line
               -- And need to check if UOM on MOL and MMTT match.

               l_progress := 190;

               SELECT uom_code
                 INTO l_mol_uom_code
                 FROM mtl_txn_request_lines
                 WHERE line_id = p_document_rec.move_order_line_id;

               l_progress := 200;

               IF (l_debug=1) THEN

                  print_debug('l_mol_uom_code = '||l_mol_uom_code,l_module_name,4);
                  print_debug('p_document_rec.transaction_uom = '||p_document_rec.transaction_uom,l_module_name,4);
               END IF;

               l_qty_in_mol_uom := p_document_rec.transaction_quantity;

               -- If UOM on MOL does not match that on MMTT,
               -- need to convert MMTT quantity to that of MOL's UOM

               IF l_mol_uom_code <> p_document_rec.transaction_uom THEN
                  IF (l_debug=1) THEN
                     print_debug('MMTT and MOL UOM do not match, need to convert quantity.',l_module_name,4);
                     print_debug('Before calling INV_Convert.inv_um_convert with parameters:', l_module_name,4);
                     print_debug('item_id => '||p_document_rec.inventory_item_id, l_module_name,4);
                     print_debug('from_quantity => '||p_document_rec.transaction_quantity, l_module_name,4);
                     print_debug('from_unit => '||p_document_rec.transaction_uom, l_module_name,4);
                     print_debug('to_unit => '||l_mol_uom_code, l_module_name,4);
                  END IF;

                  l_progress := 210;

                  l_qty_in_mol_uom := INV_Convert.inv_um_convert
                    (item_id            => p_document_rec.inventory_item_id,
                     precision           => null,
                     from_quantity => p_document_rec.transaction_quantity,
                     from_unit           => p_document_rec.transaction_uom,
                     to_unit       => l_mol_uom_code,
                     from_name           => null,
                     to_name       => null);

                  l_progress := 220;

                  IF (l_debug=1) THEN
                     print_debug('Inspect - After calling INV_Convert.inv_um_convert. l_qty_in_mol_uom = '||l_qty_in_mol_uom, l_module_name,4);

                  END IF;

               END IF; --  IF l_mol_uom_code <> p_document_rec.transaction_uom

               l_progress := 230;

               UPDATE mtl_txn_request_lines
                 SET quantity_detailed = quantity_detailed - l_qty_in_mol_uom
                 WHERE line_id = p_document_rec.move_order_line_id;

               l_progress := 240;


               IF (l_debug=1) THEN

                  print_debug('Before calling inv_trx_util_pub.delete_transaction with following parameters: ',l_module_name,4);

                  print_debug('p_transaction_temp_id => '||p_source_task_id,l_module_name,4);
               END IF;

               inv_trx_util_pub.delete_transaction
                 (x_return_status         => l_return_status
                  , x_msg_data            => l_msg_data
                  , x_msg_count           => l_msg_count
                  , p_transaction_temp_id => p_source_task_id
        , p_update_parent       => FALSE
                  );

               l_progress := 242;

               IF (l_debug=1) THEN
                  print_debug('Inspect - After calling inv_trx_util_pub.delete_transaction.',l_module_name,4);

                  print_debug('l_return_status => '||l_return_status,l_module_name,4);
                  print_debug('l_msg_data => '||l_msg_data,l_module_name,4);
                  print_debug('l_msg_count => '||l_msg_count,l_module_name,4);
               END IF;

               IF l_return_status <>FND_API.g_ret_sts_success THEN
                  IF (l_debug=1) THEN
                     print_debug('inv_trx_util_pub.delete_transaction finished with error. l_return_status = ' || l_return_status,l_module_name,4);
                  END IF;

                  RAISE FND_API.G_EXC_ERROR;
               END IF;


             ELSE -- p_operation_type_id is not DROP or INSPECT
               IF (l_debug=1) THEN
                  print_debug('Invalid operation type for last step, it can only be DROP or INSPECT. p_operation_type_id = '||p_operation_type_id,l_module_name,4);
               END IF;

               RAISE FND_API.G_EXC_ERROR;

            END IF; -- p_operation_type_id = g_op_type_drop


          ELSE  -- p_is_last_operation_flag <> 'Y'

            l_progress := 244;

            IF (l_debug=1) THEN
               print_debug('Current operation is not the last step within the plan.',l_module_name,4);
            END IF;

            -- Only if current operation is drop we need to manipulate MMTT.
            -- For load we don't need to do anything, inspect can only be the last step.

            IF p_operation_type_id = g_op_type_drop THEN

               IF (l_debug=1) THEN
                  print_debug('Current operation is drop.',l_module_name,4);
               END IF;

               -- Mainly we need to create new child MMTT record for the next operation.
               -- We need to create the new child MMTT record with correct transaction_type_id,  transaction_action_id, and transaction_source_type_ID.
               -- This will be based on the destination locator type of the previous child MMTT record.
               -- If the previous MMTT drops to an inventory locator, we need to create a move order transfer MMTT, otherwise, PO receipt.

               -- Also, for a new inventory transfer MMTT record, we need to set the source subinventory and locator.

               -- It is not necessary to populate source subinventory and locator for receiving transfer MMTT record.
               -- But it is probably cleaner to do so, which requires passing 'is_in_inventory' flag as an input parameter. We might want to do this later.



               -- Based on destination subinventory type of the current MMTT
               -- we decide transaction type for the new MMTT.
               -- If the destination sub for current MMTT is receiving,
               -- the new MMTT will be a receipt and transaction type will be
               -- carried over from the current MMTT;
               -- If the destination sub for current MMTT is inventory,
               -- the new MMTT will be a move order transfer transaction.
               --
               -- Destination sub/locator can be populated in
               -- eith transfer_ fields or sub/loc fields.

               IF (l_debug=1) THEN
                  print_debug('p_document_rec.transfer_subinventory = ' || p_document_rec.transfer_subinventory,l_module_name,4);
                  print_debug('p_document_rec.organization_id = ' || p_document_rec.organization_id,l_module_name,4);
                  print_debug('p_document_rec.subinventory_code = ' || p_document_rec.subinventory_code,l_module_name,4);

               END IF;

               IF p_document_rec.transfer_subinventory IS NOT NULL THEN

                  SELECT subinventory_type
                    INTO l_dest_subinventory_type
                      FROM mtl_secondary_inventories
                    WHERE secondary_inventory_name = p_document_rec.transfer_subinventory
                    AND organization_id = p_document_rec.organization_id;
                ELSE

                  SELECT subinventory_type
                    INTO l_dest_subinventory_type
                    FROM mtl_secondary_inventories
                    WHERE secondary_inventory_name = p_document_rec.subinventory_code
                    AND organization_id = p_document_rec.organization_id;

               END IF; -- IF p_document_rec.transfer_subinventory IS NOT NULL

               l_progress := 250;

               IF (l_debug=1) THEN
                  print_debug('l_dest_subinventory_type = '||l_dest_subinventory_type,l_module_name,4);
               END IF;

               IF l_dest_subinventory_type IS NULL OR
                 l_dest_subinventory_type = 1 THEN
                  -- Current MMTT drops to an invenotry sub
                  IF (l_debug=1) THEN
                     print_debug('Current MMTT drops to inventory ',l_module_name,4);
                  END IF;

                  l_new_txn_action_id   := g_action_subxfr;
                  l_new_txn_source_type_id := g_sourcetype_moveorder;
                  l_new_txn_type_id    := g_type_transfer_order_subxfr;
                  l_new_subinventory_code  := Nvl(p_document_rec.transfer_subinventory,
                                                  p_document_rec.subinventory_code);
                  l_new_locator_id         := Nvl(p_document_rec.transfer_to_location,
                                                  p_document_rec.locator_id);
                  l_new_transfer_to_loc    := NULL;
                  l_new_transfer_to_sub    := NULL;


                ELSE -- current MMTT drops to an receiving sub
                  IF (l_debug=1) THEN
                     print_debug('Current MMTT drops to receiving ',l_module_name,4);
                  END IF;

                  l_new_txn_action_id   := p_document_rec.transaction_action_id;
                  l_new_txn_source_type_id := p_document_rec.transaction_source_type_ID;
                  l_new_txn_type_id    := p_document_rec.transaction_type_id;
                  l_new_subinventory_code  := fnd_api.g_miss_char;
                  l_new_locator_id         := fnd_api.g_miss_num;
                  l_new_transfer_to_loc    := fnd_api.g_miss_num;
                  l_new_transfer_to_sub    := fnd_api.g_miss_char;

               END IF;  -- l_dest_subinventory_type IS NULL


               -- Inventory putaway might have a transfer_lpn_id,
               -- In this case this LPN becomes the lpn_id for next MMTT.

               l_new_lpn_id := Nvl(l_mmtt_data_rec.transfer_lpn_id, l_mmtt_data_rec.content_lpn_id);

               UPDATE mtl_txn_request_lines
                 SET lpn_id = Nvl(l_mmtt_data_rec.transfer_lpn_id, l_mmtt_data_rec.content_lpn_id)
                 WHERE line_id = p_document_rec.move_order_line_id;

               l_progress := 258;

               IF p_next_operation_type_id = g_op_type_inspect THEN
                  IF (l_debug=1) THEN
                     print_debug('Next operation is inspect, need to set WMS_TASK_TYPE to inspect ',l_module_name,4);
                  END IF;

                  l_new_wms_task_type_id := g_wms_task_type_inspect;
                ELSE

                  l_new_wms_task_type_id := p_document_rec.wms_task_type;

               END IF;  -- IF p_next_operation_type_id = g_op_type_inspect

               IF (l_debug=1) THEN

                  print_debug('Before calling inv_trx_util_pub.copy_insert_line_trx with following parameters: ',l_module_name,4);

                  print_debug('p_transaction_temp_id => '||p_source_task_id,l_module_name,4);
                  print_debug('p_subinventory_code => '||l_new_subinventory_code,l_module_name,4);
                  print_debug('p_locator_id => '||l_new_locator_id,l_module_name,4);
                  print_debug('p_to_subinventory_code => '||l_new_transfer_to_sub,l_module_name,4);
                  print_debug('p_to_locator_id => '||l_new_transfer_to_loc,l_module_name,4);
                  print_debug('p_txn_type_id => '||l_new_txn_type_id,l_module_name,4);
                  print_debug('p_txn_action_id => '||l_new_txn_action_id,l_module_name,4);
                  print_debug('p_txn_source_type_id => '||l_new_txn_source_type_id,l_module_name,4);
                  print_debug('p_wms_task_type => '||l_new_wms_task_type_id,l_module_name,4);
                  print_debug('p_lpn_id => '||l_new_lpn_id, l_module_name,4);
                  print_debug('p_transfer_lpn_id => '|| fnd_api.g_miss_num, l_module_name,4);
                  print_debug('p_content_lpn_id => '|| fnd_api.g_miss_num, l_module_name,4);

               END IF;

               l_progress := 260;

               /*
               {{
                 When completing the drop operation right before the crossdock operation
                 need to stamp subsequent outbound operation plan ID to the last task

                 }}

                 */
                 IF (p_next_operation_type_id = g_op_type_crossdock AND
                     p_subsequent_op_plan_id IS NOT NULL) -- this is necessary because this file is dual maintained for 11.5.10
                       THEN

                    INV_TRX_UTIL_PUB.copy_insert_line_trx
                      (
                       x_return_status        =>   l_return_status
                       ,x_msg_data            =>   l_msg_data
                       ,x_msg_count           =>   l_msg_count
                       ,x_new_txn_temp_id     =>   x_source_task_id
                       ,p_transaction_temp_id =>   p_source_task_id
                       ,p_subinventory_code   =>   l_new_subinventory_code
                       ,p_locator_id          =>   l_new_locator_id
                       ,p_to_subinventory_code =>  l_new_transfer_to_sub
                       ,p_to_locator_id       =>   l_new_transfer_to_loc
                       ,p_txn_type_id         =>   l_new_txn_type_id
                       ,p_txn_action_id       =>   l_new_txn_action_id
                       ,p_txn_source_type_id  =>   l_new_txn_source_type_id
                       ,p_wms_task_type       =>   l_new_wms_task_type_id
                       ,p_lpn_id              =>   l_new_lpn_id
                       ,p_transfer_lpn_id     =>   fnd_api.g_miss_num  -- null out transfer_lpn_id
                       ,p_content_lpn_id      =>   fnd_api.g_miss_num  -- null out  content_lpn_id
                       ,p_operation_plan_id   =>   p_subsequent_op_plan_id
                       ,p_transaction_status  =>   2                   -- Bug 5156015
                       );

                    IF (l_debug=1) THEN
                       print_debug('Stamp subsequent OP plan ID '||p_subsequent_op_plan_id||' to child task. ',l_module_name,9);
                    END IF;

                  ELSE
                    INV_TRX_UTIL_PUB.copy_insert_line_trx
                      (
                       x_return_status        =>   l_return_status
                       ,x_msg_data            =>   l_msg_data
                       ,x_msg_count           =>   l_msg_count
                       ,x_new_txn_temp_id     =>   x_source_task_id
                       ,p_transaction_temp_id =>   p_source_task_id
                       ,p_subinventory_code   =>   l_new_subinventory_code
                       ,p_locator_id          =>   l_new_locator_id
                       ,p_to_subinventory_code =>  l_new_transfer_to_sub
                       ,p_to_locator_id       =>   l_new_transfer_to_loc
                       ,p_txn_type_id         =>   l_new_txn_type_id
                       ,p_txn_action_id       =>   l_new_txn_action_id
                       ,p_txn_source_type_id  =>   l_new_txn_source_type_id
                       ,p_wms_task_type       =>   l_new_wms_task_type_id
                       ,p_lpn_id              =>   l_new_lpn_id
                       ,p_transfer_lpn_id     =>   fnd_api.g_miss_num  -- null out transfer_lpn_id
                       ,p_content_lpn_id      =>   fnd_api.g_miss_num  -- null out  content_lpn_id
                       ,p_transaction_status  =>   2                   -- Bug 5156015
                       );
                 END IF;

               l_progress := 270;

               IF (l_debug=1) THEN
                     print_debug('After calling inv_trx_util_pub.copy_insert_line_trx: ',l_module_name,4);

                  print_debug('l_return_status => '||l_return_status,l_module_name,4);
                  print_debug('l_msg_data => '||l_msg_data,l_module_name,4);
                  print_debug('l_msg_count => '||l_msg_count,l_module_name,4);
                  print_debug('x_source_task_id => '||x_source_task_id,l_module_name,4);

               END IF;

               IF l_return_status <>fnd_api.g_ret_sts_success THEN
                  IF (l_debug=1) THEN
                     print_debug('Error occured while calling inv_trx_util_pub.copy_insert_line_trx',l_module_name,4);
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

               -- Get item lot serial control
               -- Need to link MTLT or MSNT to this new MMTT record
               -- if item is lot or serial controlled

               l_progress := 280;

               SELECT lot_control_code,
                 serial_number_control_code
                 INTO l_lot_control_code,
                 l_serial_control_code
                 FROM mtl_system_items_b
                 WHERE inventory_item_id = p_document_rec.inventory_item_id
                 AND organization_id = p_document_rec.organization_id;

               l_progress := 290;

               IF (l_debug=1) THEN
                  print_debug('l_lot_control_code = '||l_lot_control_code,l_module_name,4);
                  print_debug('l_serial_control_code = '||l_serial_control_code,l_module_name,4);
               END IF;

               IF l_lot_control_code = 2 THEN
                  IF (l_debug=1) THEN
                     print_debug('Item is lot controlled, need to link MTLT to new MMTT.',l_module_name,4);
                  END IF;

                  l_progress := 300;

                  UPDATE mtl_transaction_lots_temp
                    SET transaction_temp_id = x_source_task_id
                    WHERE transaction_temp_id = p_source_task_id;

                  l_progress := 310;

                ELSIF l_serial_control_code NOT IN (1, 6) THEN
                  IF (l_debug=1) THEN
                     print_debug('Item is serial controlled and not lot controlled, need to link MSNT to new MMTT.',l_module_name,4);
                  END IF;

                  l_progress := 320;

                  UPDATE mtl_serial_numbers_temp
                    SET transaction_temp_id = x_source_task_id
                    WHERE transaction_temp_id = p_source_task_id;

                  l_progress := 330;

               END IF; --IF l_lot_control_code <> 1

               -- At last, delete current MMTT if
               -- it is for a receiving transaction.
               -- Inventory and WIP putaway will rely on inventory TM
               -- to delete the MMTT.

               IF (p_document_rec.transaction_action_id = G_ACTION_RECEIPT
                   AND p_document_rec.transaction_source_type_id = g_sourcetype_purchaseorder
                   -- PO receipt (1, 27)
                   ) OR
                 (p_document_rec.transaction_action_id = G_ACTION_RECEIPT
                  AND p_document_rec.transaction_source_type_id = g_sourcetype_rma
                  -- RMA receipt (12, 27)
                  ) OR
		 (p_document_rec.transaction_action_id = G_ACTION_RECEIPT
		  AND p_document_rec.transaction_source_type_id = g_sourcetype_moveorder
		  -- Consolidated inbound move order receipt (4, 27)
		  ) OR
		 (p_document_rec.transaction_action_id = G_ACTION_INTRANSITRECEIPT
		  AND p_document_rec.transaction_source_type_id = g_sourcetype_inventory
		  -- Intransit shipment receipt (13, 12)
		  ) OR
                 (p_document_rec.transaction_action_id = G_ACTION_INTRANSITRECEIPT
                  AND p_document_rec.transaction_source_type_id = G_SOURCETYPE_INTREQ
                  ) THEN

                  IF (l_debug=1) THEN
                     print_debug('This is a receipt transaction, need to delete MMTT. '||l_return_status,l_module_name,4);
                  END IF;

                  IF (l_debug=1) THEN

                     print_debug('Before calling inv_trx_util_pub.delete_transaction with following parameters: ',l_module_name,4);

                     print_debug('p_transaction_temp_id => '||p_source_task_id,l_module_name,4);
                  END IF;

                  inv_trx_util_pub.delete_transaction
                    (x_return_status         => l_return_status
                     , x_msg_data            => l_msg_data
                     , x_msg_count           => l_msg_count
                     , p_transaction_temp_id => p_source_task_id
           , p_update_parent       => FALSE
                     );

                  IF (l_debug=1) THEN
                     print_debug('Not last operation - Drop - After calling inv_trx_util_pub.delete_transaction.',l_module_name,4);

                     print_debug('l_return_status => '||l_return_status,l_module_name,4);
                     print_debug('l_msg_data => '||l_msg_data,l_module_name,4);
                     print_debug('l_msg_count => '||l_msg_count,l_module_name,4);
                  END IF;

                  IF l_return_status <>FND_API.g_ret_sts_success THEN
                     IF (l_debug=1) THEN
                        print_debug('Not last operation - Drop - inv_trx_util_pub.delete_transaction finished with error. l_return_status = ' || l_return_status,l_module_name,4);
                     END IF;

                     RAISE FND_API.G_EXC_ERROR;
                  END IF;

               END IF; -- IF (p_document_rec.transaction_action_id = G_ACTION_RECEIPT


            END IF; -- p_operation_type_id = g_op_type_drop

         END IF; -- p_is_last_operation_flag = 'Y'


         IF p_operation_type_id = g_op_type_drop
           AND p_document_rec.transaction_action_id <> g_action_subxfr
           THEN
            -- Need to revert the suggested capacity of the destination locator
            -- Do not need to do this for MO sub transfer - inventory TM handles this.
            IF (l_debug=1) THEN
               print_debug('Before calling inv_loc_wms_utils.revert_loc_suggested_cap_nauto with parameters:'||l_return_status,l_module_name,4);
               print_debug('p_document_rec.organization_id = '|| p_document_rec.organization_id,l_module_name,4);
               print_debug('p_document_rec.transfer_to_location = '|| p_document_rec.transfer_to_location,l_module_name,4);
               print_debug('p_document_rec.locator_i = '|| p_document_rec.locator_id,l_module_name,4);
               print_debug('p_document_rec.inventory_item_id = '|| p_document_rec.inventory_item_id,l_module_name,4);
               print_debug('p_document_rec.transaction_uom = '|| p_document_rec.transaction_uom,l_module_name,4);
               print_debug('p_document_rec.transaction_quantity = '|| p_document_rec.transaction_quantity ,l_module_name,4);
            END IF;

            IF (Nvl(p_document_rec.transfer_to_location, p_document_rec.locator_id) IS NOT NULL) THEN
            --inv_loc_wms_utils.revert_loc_suggested_cap_nauto commented for bug 5920044.
	    inv_loc_wms_utils.revert_loc_suggested_capacity  --bug#5920044.
              (
               x_return_status              => l_return_status
               , x_msg_count                  => l_msg_count
               , x_msg_data                   => l_msg_data
               , p_organization_id            => p_document_rec.organization_id
               , p_inventory_location_id      => Nvl(p_document_rec.transfer_to_location, p_document_rec.locator_id)
               , p_inventory_item_id          => p_document_rec.inventory_item_id
               , p_primary_uom_flag           => 'N'
               , p_transaction_uom_code       => p_document_rec.transaction_uom
               , p_quantity                   => p_document_rec.transaction_quantity
               );
            END IF;

            IF (l_debug=1) THEN
               print_debug('Return status is'||l_return_status,l_module_name,9);
            END IF;

            IF (l_return_status=fnd_api.g_ret_sts_error) THEN
               IF (l_debug=1) THEN
                  print_debug('Error obtained while reverting suggested locator capacity',l_module_name,9);
               END IF;
               -- Bug 5369010: do not raise exception if locator capacity API fails
               -- RAISE FND_API.G_EXC_ERROR;

             ELSIF (l_return_status<>fnd_api.g_ret_sts_success) THEN

               IF (l_debug=1) THEN
                  print_debug('unexpected error while reverting suggested locator capacity',l_module_name,9);
               END IF;
               -- Bug 5369010: do not raise exception if locator capacity API fails
               -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF;

         END IF;

         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

         IF (l_debug=1) THEN
            print_debug('x_return_status => '||x_return_status,l_module_name,1);
            print_debug('x_msg_data => '||x_msg_data,l_module_name,1);
            print_debug('x_msg_count => '||x_msg_count,l_module_name,1);
            print_debug('x_error_code => '||x_error_code,l_module_name,1);
            print_debug('x_source_task_id => '||x_source_task_id,l_module_name,1);

            print_debug('Exited. ',l_module_name,1);
         END IF;


      EXCEPTION
         WHEN fnd_api.g_exc_error THEN
            IF (l_debug=1) THEN
               print_debug('Error (fnd_api.g_exc_error) occured at'||l_progress,l_module_name,1);
            END IF;
            x_return_status:=FND_API.G_RET_STS_ERROR;
            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

            IF c_mmtt_data_rec%isopen THEN
               CLOSE c_mmtt_data_rec;
            END IF;


         WHEN fnd_api.g_exc_unexpected_error THEN

            x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
            IF (l_debug=1) THEN
               print_debug('Unexpected Error (fnd_api.g_exc_unexpected_error) occured at '||l_progress,l_module_name,3);
            END IF;
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
               fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
            END IF;
            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

            IF c_mmtt_data_rec%isopen THEN
               CLOSE c_mmtt_data_rec;
            END IF;

         WHEN OTHERS THEN

            x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
            IF (l_debug=1) THEN
               print_debug('Other Error occured at '||l_progress,l_module_name,1);
               IF SQLCODE IS NOT NULL THEN
                  print_debug('With SQL error : ' || SQLERRM(SQLCODE), l_module_name,1);
               END IF;
            END IF;

            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
               fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
            END IF;
            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

            IF c_mmtt_data_rec%isopen THEN
               CLOSE c_mmtt_data_rec;
            END IF;

      END complete;



/**
    *    <b> Cleanup </b>:
    * <p>This API is the document handler for Inbound document records and is called from
    *    Cleanup_Operation_Instance and Rollback_Operation_Instance </p>
    *
    *
    *    This API clears the destination subinventory, locator, and drop to LPN
    *    if ATF suggested these data.
    *
    *
    *
    *
    *  @param x_return_status      -Return Status
    *  @param x_msg_data           -Returns Message Data
    *  @param x_msg_count          -Returns the message count
    *  @param p_source_task_id     -Identifier of the document record.
    *
   **/
      PROCEDURE cleanup
      (
       x_return_status      OUT  NOCOPY    VARCHAR2
       , x_msg_data           OUT  NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
       , x_msg_count          OUT  NOCOPY    NUMBER
       , p_source_task_id     IN             NUMBER
       )
      IS

         l_module_name      VARCHAR2(30)   := 'CLEANUP';
         l_debug            NUMBER         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
         l_progress         NUMBER;

         l_msg_count        NUMBER;
         l_msg_data         VARCHAR2(400);
         l_return_status    VARCHAR2(1);

         CURSOR c_mmtt_data_rec IS
            SELECT
              transfer_subinventory,
              transfer_to_location,
              subinventory_code,
              locator_id,
              cartonization_id,
              transaction_action_id,
              transaction_source_type_id,
              organization_id,
              inventory_item_id,
              primary_quantity
              FROM mtl_material_transactions_temp
              WHERE transaction_temp_id = p_source_task_id;

         l_mmtt_data_rec c_mmtt_data_rec%ROWTYPE;

         l_mol_lpn_id       NUMBER;

     BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_progress      := 10;

        SAVEPOINT sp_op_inbound_cleanup;

        IF (l_debug=1) THEN
           print_debug('Entered. ',l_module_name,1);
           print_debug('p_source_task_id => '||p_source_task_id,l_module_name,1);
        END IF;

        l_progress      := 20;

        OPEN c_mmtt_data_rec;

        FETCH c_mmtt_data_rec INTO l_mmtt_data_rec;
        IF c_mmtt_data_rec%notfound THEN
           IF (l_debug=1) THEN
              print_debug('Invalid p_source_task_id : '||p_source_task_id,l_module_name,1);
              RAISE fnd_api.G_EXC_ERROR;
           END IF;
        END IF;

        CLOSE c_mmtt_data_rec;

        l_progress      := 30;

        SELECT mol.lpn_id
          INTO l_mol_lpn_id
          FROM mtl_txn_request_lines mol
          WHERE mol.line_id =
          (SELECT move_order_line_id
           FROM mtl_material_transactions_temp
           WHERE transaction_temp_id = p_source_task_id);

        l_progress      := 34;

        IF (l_debug=1) THEN
           print_debug('l_mol_lpn_id = '||l_mol_lpn_id,l_module_name,1);
        END IF;

        IF l_debug=1 THEN
           print_debug('Suggested locator capacity of the Rules suggested locaotr needs to be reverted',l_module_name,4);
        END IF;

        IF (Nvl(l_mmtt_data_rec.transfer_to_location, l_mmtt_data_rec.locator_id) IS NOT NULL) THEN
           inv_loc_wms_utils.revert_loc_suggested_cap_nauto
             (
              x_return_status             => l_return_status
              , x_msg_count                 => l_msg_count
              , x_msg_data                  => l_msg_data
              , p_organization_id           => l_mmtt_data_rec.organization_id
              , p_inventory_location_id     => Nvl(l_mmtt_data_rec.transfer_to_location, l_mmtt_data_rec.locator_id)
              , p_inventory_item_id         => l_mmtt_data_rec.inventory_item_id
              , p_primary_uom_flag          => 'Y'
              , p_transaction_uom_code      => NULL
              , p_quantity                  => l_mmtt_data_rec.primary_quantity
              );
        END IF;

        l_progress:=35;

        IF (l_debug=1) THEN
           print_debug('Return status is'||l_return_status,l_module_name,9);
        END IF;

        IF (l_return_status<>fnd_api.g_ret_sts_success) THEN

           IF (l_debug=1) THEN
              print_debug('Error obtained while reverting locator capacity',l_module_name,9);
              print_debug('Error msg'||x_msg_data,l_module_name,9);
           END IF;

        END IF;



        IF l_mmtt_data_rec.transfer_to_location IS NOT NULL THEN

           -- This cleans up drop operation of an inventory or receiving transfer, in which case transfer sub/loc
           -- columns are populated.
           l_progress      := 40;
           IF (l_debug=1) THEN
              print_debug('Null out transfer_subinventory : ' || l_mmtt_data_rec.transfer_subinventory || ' transfer_to_location : '||l_mmtt_data_rec.transfer_to_location ||' and cartonization_id : '|| l_mmtt_data_rec.cartonization_id,l_module_name,1);
           END IF;

           -- If MMTT.operation_plan_ID is null we don't need to cleanup
           -- transfer_to_location, transfer_subinventory, and cartonization_id,
           -- which were NOT suggested by ATF.

           UPDATE mtl_material_transactions_temp
             SET transfer_subinventory = Decode(operation_plan_id, NULL, transfer_subinventory, NULL),
             transfer_to_location = Decode(operation_plan_id, NULL, transfer_to_location, NULL),
             cartonization_id = Decode(operation_plan_id, NULL, cartonization_id, NULL),
             transfer_lpn_id = NULL,
             content_lpn_id = NULL,
             lpn_id = l_mol_lpn_id,
             wms_task_type = Decode(wms_task_type, -1, g_wms_task_type_putaway, wms_task_type) -- revert it back to putaway if it has been set to -1 from complete_putaway
             WHERE transaction_temp_id = p_source_task_id;

           l_progress := 50;

         ELSE -- IF l_mmtt_data_rec.transfer_to_location IS NULL

           -- This cleans up drop operation of a receiving deliver, in which case sub/loc
           -- columns are not populated.
           -- We shouldn't cleanup sub/loc fields if this is an inventory transfer

           IF l_mmtt_data_rec.transaction_action_id <> 2 THEN

              l_progress      := 60;
              IF (l_debug=1) THEN
                 print_debug('Null out subinventory_code : ' || l_mmtt_data_rec.subinventory_code || ' locator_id : '||l_mmtt_data_rec.locator_id ||' and cartonization_id : '|| l_mmtt_data_rec.cartonization_id,l_module_name,1);
              END IF;

              -- If MMTT.operation_plan_ID is null we don't need to cleanup
              -- locator_ID, subinventory_code, and cartonization_id,
              -- which were NOT suggested by ATF.

              UPDATE mtl_material_transactions_temp
                SET  subinventory_code = Decode(operation_plan_id, NULL, subinventory_code, NULL),
                locator_id = Decode(operation_plan_id, NULL, locator_id, NULL),
                cartonization_id = Decode(operation_plan_id, NULL, cartonization_id, NULL),
                transfer_lpn_id = NULL,
                content_lpn_id = NULL,
                lpn_id = l_mol_lpn_id,
                wms_task_type = Decode(wms_task_type, -1, g_wms_task_type_putaway, wms_task_type) -- revert it back to putaway if it has been set to -1 from complete_putaway
                WHERE transaction_temp_id = p_source_task_id;

              l_progress := 70;
           END IF;  -- IF l_mmtt_data_rec.transaction_action_id <> 2

        END IF;  -- IF l_mmtt_data_rec.transfer_to_location IS NOT NULL

        IF (l_debug=1) THEN
           print_debug('Before calling wms_task_dispatch_put_away.putaway_cleanup with following parameters: ',l_module_name,4);
           print_debug('p_temp_id => '|| p_source_task_id,l_module_name,4);
           print_debug('p_org_id => '|| l_mmtt_data_rec.organization_id,l_module_name,4);
        END IF;

        wms_task_dispatch_put_away.putaway_cleanup
          ( p_temp_id           =>    p_source_task_id
            , p_org_id          =>    l_mmtt_data_rec.organization_id
            , x_return_status   =>    l_return_status
            , x_msg_count       =>    l_msg_count
            , x_msg_data        =>    l_msg_data
            );

        l_progress := 80;

        IF (l_debug=1) THEN
           print_debug('After calling wms_task_dispatch_put_away.putaway_cleanup. ',l_module_name,4);
           print_debug('x_return_status => '|| l_return_status,l_module_name,4);
           print_debug('x_msg_count => '|| l_msg_count,l_module_name,4);
           print_debug('x_msg_data => '|| l_msg_data,l_module_name,4);
        END IF;

        IF l_return_status <>FND_API.g_ret_sts_success THEN
           IF (l_debug=1) THEN
              print_debug('wms_task_dispatch_put_away.putaway_cleanup finished with error. l_return_status = ' || l_return_status,l_module_name,4);
           END IF;

           RAISE FND_API.G_EXC_ERROR;
        END IF;


        IF (l_debug=1) THEN
            print_debug('x_return_status => '||x_return_status,l_module_name,1);
            print_debug('x_msg_data => '||x_msg_data,l_module_name,1);
            print_debug('x_msg_count => '||x_msg_count,l_module_name,1);

            print_debug('Exited. ',l_module_name,1);
        END IF;

      EXCEPTION
         WHEN fnd_api.g_exc_error THEN
            IF (l_debug=1) THEN
               print_debug('Error (fnd_api.g_exc_error) occured at'||l_progress,l_module_name,1);
            END IF;
            x_return_status:=FND_API.G_RET_STS_ERROR;
            IF c_mmtt_data_rec%isopen THEN
               CLOSE c_mmtt_data_rec;
            END IF;

            ROLLBACK TO sp_op_inbound_cleanup;


         WHEN fnd_api.g_exc_unexpected_error THEN

            x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
            IF (l_debug=1) THEN
               print_debug('Unexpected Error (fnd_api.g_exc_unexpected_error) occured at '||l_progress,l_module_name,3);
            END IF;
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
               fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
            END IF;
            IF c_mmtt_data_rec%isopen THEN
               CLOSE c_mmtt_data_rec;
            END IF;

            ROLLBACK TO sp_op_inbound_cleanup;

         WHEN OTHERS THEN

            x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
            IF (l_debug=1) THEN
               print_debug('Other Error occured at '||l_progress,l_module_name,1);
               IF SQLCODE IS NOT NULL THEN
                  print_debug('With SQL error : ' || SQLERRM(SQLCODE), l_module_name,1);
               END IF;
            END IF;
            IF c_mmtt_data_rec%isopen THEN
               CLOSE c_mmtt_data_rec;
            END IF;

            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
               fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
            END IF;

            ROLLBACK TO sp_op_inbound_cleanup;

      END cleanup;



/**
    *    <b> Cancel </b>:
    * <p>This API is the document handler for Inbound document records and is called from
    *    Cancel_Operation_Plan  </p>
    *
    *
    *    This API deletes the parent MMTT record, deletes the child MMTT record,
    *    update and close the move order line as appropriate.
    *
    *
    *  @param x_return_status      -Return Status
    *  @param x_msg_data           -Returns Message Data
    *  @param x_msg_count          -Returns the message count
    *  @param p_source_task_id     -Identifier of the document record.
    *
   **/
     PROCEDURE cancel
      (
       x_return_status      OUT  NOCOPY    VARCHAR2
       , x_msg_data           OUT  NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
       , x_msg_count          OUT  NOCOPY    NUMBER
       , p_source_task_id     IN             NUMBER
       , p_retain_mmtt       IN   VARCHAR2 DEFAULT 'N'
       , p_mmtt_error_code   IN   VARCHAR2 DEFAULT NULL
       , p_mmtt_error_explanation   IN   VARCHAR2 DEFAULT NULL
      )
      IS
          l_module_name      VARCHAR2(30)   := 'CANCEL';
         l_debug            NUMBER         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
         l_progress         NUMBER;
         l_return_status       VARCHAR2(1);
         l_msg_count           NUMBER;
         l_msg_data            VARCHAR2(400);

         l_qty_in_mol_uom   NUMBER;
	 l_subinventory_code VARCHAR2(10);
	 l_locator_id NUMBER;

         CURSOR c_mmtt_data_rec IS
            SELECT
              mmtt.transaction_temp_id,
              mmtt.move_order_line_id,
              mmtt.parent_line_id,
              mmtt.transaction_action_id,
              mmtt.transaction_source_type_id,
              mmtt.transaction_uom,
              mmtt.transaction_quantity,
              mmtt.inventory_item_id,
              mol.uom_code mol_uom_code,
              mol.backorder_delivery_detail_id,
              mol.crossdock_type,
              mmtt.repetitive_line_id,
              mmtt.operation_seq_num,
              mmtt.primary_quantity
         FROM mtl_material_transactions_temp mmtt,
              mtl_txn_request_lines mol
              WHERE transaction_temp_id = p_source_task_id
              AND mmtt.move_order_line_id =  mol.line_id;

    CURSOR c_parent_mmtt_rec(v_txn_temp_id NUMBER) IS
       SELECT
         nvl(transfer_to_location,locator_id) locator_id,
         primary_quantity,
         organization_id,
         inventory_item_id
       FROM mtl_material_transactions_temp
       WHERE transaction_temp_id=v_txn_temp_id;


    CURSOR c_wdt_status IS
       SELECT status
	 FROM wms_dispatched_tasks
	 WHERE transaction_temp_id=p_source_task_id
	 AND   task_type=g_wms_task_type_putaway;

    l_mmtt_data_rec   c_mmtt_data_rec%ROWTYPE;
    l_parent_mmtt_rec c_parent_mmtt_rec%ROWTYPE;
    l_wdt_status NUMBER:=0;

     BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_progress      := 10;

        SAVEPOINT sp_op_inbound_cancel;

        IF (l_debug=1) THEN
           print_debug('Entered. ',l_module_name,1);
           print_debug('p_source_task_id => '||p_source_task_id,l_module_name,1);
           print_debug('p_retain_mmtt => '||p_retain_mmtt,l_module_name,1);
           print_debug('p_mmtt_error_explanation => '||p_mmtt_error_explanation,l_module_name,1);
           print_debug('p_mmtt_error_code => '||p_mmtt_error_code,l_module_name,1);
        END IF;

        l_progress      := 20;


        OPEN c_mmtt_data_rec;

        FETCH c_mmtt_data_rec INTO l_mmtt_data_rec;
        IF c_mmtt_data_rec%notfound THEN
           IF (l_debug=1) THEN
              print_debug('Invalid p_source_task_id : '||p_source_task_id,l_module_name,1);
              RAISE fnd_api.G_EXC_ERROR;
           END IF;
        END IF;

        CLOSE c_mmtt_data_rec;

	OPEN c_parent_mmtt_rec(l_mmtt_data_rec.parent_line_id);

	FETCH c_parent_mmtt_rec INTO l_parent_mmtt_rec;

	IF c_parent_mmtt_rec%NOTFOUND THEN

	   IF (l_debug=1) THEN
	      print_debug('No parent MMTT record found',l_module_name,9);
	   END IF;

	   CLOSE c_parent_mmtt_rec;

	   RAISE fnd_api.G_EXC_ERROR;

	END IF;

	CLOSE c_parent_mmtt_rec;


        l_progress      := 30;

        IF (l_debug=1) THEN
           print_debug('l_mmtt_data_rec.transaction_temp_id = '|| l_mmtt_data_rec.transaction_temp_id,l_module_name,4);
           print_debug('l_mmtt_data_rec.move_order_line_id = '|| l_mmtt_data_rec.move_order_line_id,l_module_name,4);
           print_debug('l_mmtt_data_rec.parent_line_id = '|| l_mmtt_data_rec.parent_line_id,l_module_name,4);
           print_debug('l_mmtt_data_rec.transaction_action_id = '|| l_mmtt_data_rec.transaction_action_id,l_module_name,4);
           print_debug('l_mmtt_data_rec.transaction_source_type_id = '|| l_mmtt_data_rec.transaction_source_type_id,l_module_name,4);
           print_debug('l_mmtt_data_rec.parent_line_id = '|| l_mmtt_data_rec.parent_line_id,l_module_name,4);
           print_debug('l_mmtt_data_rec.backorder_delivery_detail_id = '|| l_mmtt_data_rec.backorder_delivery_detail_id,l_module_name,4);


           print_debug('Delete parent - Before calling INV_TRX_UTIL_PUB.Delete_transaction with following parameters: ' ,l_module_name,4);
           print_debug('p_transaction_temp_id => '|| l_mmtt_data_rec.parent_line_id,l_module_name,4);
           print_debug('p_update_parent => '|| 'FALSE',l_module_name,4);

        END IF;

        l_progress := 40;

        -- delete parent mmtt record

        INV_TRX_UTIL_PUB.Delete_transaction
          (x_return_status       => l_return_status,
           x_msg_data            => l_msg_data,
           x_msg_count           => l_msg_count,
           p_transaction_temp_id => l_mmtt_data_rec.parent_line_id,
           p_update_parent       => FALSE);

        l_progress := 50;

        IF (l_debug=1) THEN
           print_debug('Delete parent - After calling INV_TRX_UTIL_PUB.Delete_transaction.' ,l_module_name,4);
           print_debug('x_return_status => '|| l_return_status,l_module_name,4);
           print_debug('x_msg_data => '|| l_msg_data,l_module_name,4);
           print_debug('x_msg_count => '|| l_msg_count,l_module_name,4);
        END IF;

        IF l_return_status <>FND_API.g_ret_sts_success THEN
           IF (l_debug=1) THEN
              print_debug('Delete parent - inv_trx_util_pub.delete_transaction finished with error. l_return_status = ' || l_return_status,l_module_name,4);
           END IF;

           RAISE FND_API.G_EXC_ERROR;
        END IF;


        -- Need to convert MMTT transaction quantity to the UOM of MOL if UOM
        -- does not match on MMTT and MOL

        l_qty_in_mol_uom := l_mmtt_data_rec.transaction_quantity;

        IF l_mmtt_data_rec.transaction_uom <> l_mmtt_data_rec.mol_uom_code THEN
           IF (l_debug=1) THEN
              print_debug('MMTT and MOL UOM do not match, need to convert quantity.',l_module_name,4);
              print_debug('Before calling INV_Convert.inv_um_convert with parameters:', l_module_name,4);
              print_debug('item_id => '||l_mmtt_data_rec.inventory_item_id, l_module_name,4);
              print_debug('from_quantity => '||l_mmtt_data_rec.transaction_quantity, l_module_name,4);
              print_debug('from_unit => '||l_mmtt_data_rec.transaction_uom, l_module_name,4);
              print_debug('to_unit => '||l_mmtt_data_rec.mol_uom_code, l_module_name,4);
           END IF;

           l_progress := 60;

           l_qty_in_mol_uom := INV_Convert.inv_um_convert
             (item_id         => l_mmtt_data_rec.inventory_item_id,
              precision        => null,
              from_quantity => l_mmtt_data_rec.transaction_quantity,
              from_unit        => l_mmtt_data_rec.transaction_uom,
              to_unit       => l_mmtt_data_rec.mol_uom_code,
              from_name        => null,
              to_name       => null);

           l_progress := 70;

           IF (l_debug=1) THEN
              print_debug(' After calling INV_Convert.inv_um_convert. l_qty_in_mol_uom = '||l_qty_in_mol_uom, l_module_name,4);

           END IF;

        END IF; --  IF l_mmtt_data_rec.transaction_uom <> l_mmtt_data_rec.mol_uom_code

	OPEN c_wdt_status;

	FETCH c_wdt_status INTO l_wdt_status;

	CLOSE c_wdt_status;

        IF (l_mmtt_data_rec.transaction_action_id = G_ACTION_RECEIPT
            AND l_mmtt_data_rec.transaction_source_type_id = g_sourcetype_purchaseorder
            -- PO receipt (1, 27)
            ) OR
          (l_mmtt_data_rec.transaction_action_id = G_ACTION_RECEIPT
           AND l_mmtt_data_rec.transaction_source_type_id = g_sourcetype_rma
           -- RMA receipt (12, 27)
           ) OR
	  (l_mmtt_data_rec.transaction_action_id = G_ACTION_RECEIPT
	   AND l_mmtt_data_rec.transaction_source_type_id = g_sourcetype_moveorder
	   -- Consolidated inbound move order receipt (4, 27)
	   ) OR
	  (l_mmtt_data_rec.transaction_action_id = G_ACTION_INTRANSITRECEIPT
	   AND l_mmtt_data_rec.transaction_source_type_id = g_sourcetype_inventory
	   -- Intransit shipment receipt (13, 12)
	   ) OR
          (l_mmtt_data_rec.transaction_action_id = G_ACTION_INTRANSITRECEIPT
           AND l_mmtt_data_rec.transaction_source_type_id = G_SOURCETYPE_INTREQ
           ) THEN

           -- The MMTT being cancelled is a receiving deliver or receiving transfer,
           -- therefore shouldn't close move order line, only update quantity_detailed.

           IF (l_debug=1) THEN
              print_debug('This is a receipt transaction, need NOT close MOL. '||l_return_status,l_module_name,4);
           END IF;

           l_progress := 80;

	   IF p_retain_mmtt = 'Y' AND l_wdt_status = g_task_status_loaded THEN
	      IF (l_debug=1) THEN
		 print_debug('Task is loaded... do not update quantity_detailed. '||l_return_status,l_module_name,4);
	      END IF;
	    ELSE
	      UPDATE mtl_txn_request_lines
		SET quantity_detailed = quantity_detailed - l_qty_in_mol_uom
		WHERE line_id = l_mmtt_data_rec.move_order_line_id;

	      IF (l_debug=1) THEN
		 print_debug('Updated quantity_detailed. '||l_return_status,l_module_name,4);
	      END IF;
	   END IF;

           l_progress := 90;

         ELSE
           -- The MMTT being cancelled is an inventory transfer,
           -- therefore need to close move order line, and update quantity_detailed.

           IF (l_debug=1) THEN
              print_debug('This is an inventory transfer transaction, need to close MOL. '||l_return_status,l_module_name,4);
           END IF;

           l_progress := 100;

           UPDATE mtl_txn_request_lines
             SET quantity_detailed = quantity_detailed - l_qty_in_mol_uom,
             line_status = g_to_status_closed
             WHERE line_id = l_mmtt_data_rec.move_order_line_id;

           l_progress := 110;

        END IF;  -- IF (p_document_rec.transaction_action_id = G_ACTION_RECEIPT


        IF p_retain_mmtt = 'Y' AND l_wdt_status = g_task_status_loaded THEN
           --{{
           --  when cancel operation plan caused by change of management
           --  retain child MMTT, update MMTT's sub/loc/error, putaway page will
           --  handle that later.
           --}}
           IF (l_debug=1) THEN
              print_debug('Do not delete child MMTT, retain and update sub/loc/error',l_module_name,4);
           END IF;

	   l_subinventory_code := NULL;
	   l_locator_id := NULL;
	   BEGIN
	      SELECT wlpn.subinventory_code
		, wlpn.locator_id
		INTO l_subinventory_code
		, l_locator_id
		FROM wms_license_plate_numbers wlpn
		, mtl_material_transactions_temp mmtt
		WHERE mmtt.lpn_id = wlpn.lpn_id
		AND mmtt.transaction_temp_id = p_source_task_id;
	   EXCEPTION
	      WHEN OTHERS THEN
		 l_subinventory_code := NULL;
		 l_locator_id := NULL;
	   END;

	   IF l_subinventory_code IS NOT NULL
	     AND l_locator_id IS NOT NULL THEN
	      IF l_debug = 1 THEN
		 print_debug('Updating MMTT:'||l_subinventory_code||':'||l_locator_id,l_module_name,4);
	      END IF;
	      UPDATE mtl_material_transactions_temp mmtt
		SET (subinventory_code,
		     locator_id,
		     error_code,
		     error_explanation,
		     parent_line_id,
		     operation_plan_id) =
		(SELECT
		 l_subinventory_code,
		 l_locator_id,
		 p_mmtt_error_code,
		 p_mmtt_error_explanation,
		 NULL,
		 NULL
		 FROM dual
		 )
		WHERE mmtt.transaction_temp_id = p_source_task_id;
	    ELSE
	      IF l_debug = 1 THEN
		 print_debug('Sub/Loc cannot be null for loaded LPN:'||l_subinventory_code||':'||l_locator_id,l_module_name,4);
	      END IF;
	      fnd_message.set_name('WMS','WMS_UNLD_TASK_INFO_ERR');
	      fnd_msg_pub.ADD;
	      RAISE fnd_api.g_exc_error;
	   END IF;
         ELSE
           IF (l_debug=1) THEN
              print_debug('Delete child - Before calling INV_TRX_UTIL_PUB.Delete_transaction with following parameters: ' ,l_module_name,4);
              print_debug('p_transaction_temp_id => '|| p_source_task_id,l_module_name,4);
              print_debug('p_update_parent => '|| 'FALSE',l_module_name,4);

           END IF;

           l_progress := 120;

           -- delete current mmtt record

           INV_TRX_UTIL_PUB.Delete_transaction
             (x_return_status       => l_return_status,
              x_msg_data            => l_msg_data,
              x_msg_count           => l_msg_count,
              p_transaction_temp_id => p_source_task_id,
              p_update_parent       => FALSE);

           l_progress := 130;

           IF (l_debug=1) THEN
              print_debug('Delete child - After calling INV_TRX_UTIL_PUB.Delete_transaction.' ,l_module_name,4);
              print_debug('x_return_status => '|| l_return_status,l_module_name,4);
              print_debug('x_msg_data => '|| l_msg_data,l_module_name,4);
              print_debug('x_msg_count => '|| l_msg_count,l_module_name,4);
           END IF;

           IF l_return_status <>FND_API.g_ret_sts_success THEN
              IF (l_debug=1) THEN
                 print_debug('Delete child - inv_trx_util_pub.delete_transaction finished with error. l_return_status = ' || l_return_status,l_module_name,4);
              END IF;

              RAISE FND_API.G_EXC_ERROR;
           END IF;

        END IF;

        IF l_debug=1 THEN
            print_debug('Suggested locator capacity of the Rules suggested locaotr needs to be reverted',l_module_name,9);
         END IF;

         IF (l_parent_mmtt_rec.locator_id IS NOT NULL) THEN
            inv_loc_wms_utils.revert_loc_suggested_cap_nauto
              (
               x_return_status             => l_return_status
               , x_msg_count                 => l_msg_count
               , x_msg_data                  => l_msg_data
               , p_organization_id           => l_parent_mmtt_rec.organization_id
               , p_inventory_location_id     => l_parent_mmtt_rec.locator_id
               , p_inventory_item_id         => l_parent_mmtt_rec.inventory_item_id
               , p_primary_uom_flag          => 'Y'
               , p_transaction_uom_code      => NULL
               , p_quantity                  => l_parent_mmtt_rec.primary_quantity
               );
         END IF;

        l_progress:=110;

        IF (l_debug=1) THEN
          print_debug('Return status is'||l_return_status,l_module_name,9);
        END IF;

        IF (l_return_status<>fnd_api.g_ret_sts_success) THEN

          IF (l_debug=1) THEN
             print_debug('Error while reverting locator capacity',l_module_name,9);
             print_debug('Error message'||l_msg_data,l_module_name,9);
          END IF;


        END IF;

        --{{
        --  Cancel operation plan should revert the crossdocking, i.e. update shipping,
        --  update MOL, remove reservation.
        --}}

        IF l_mmtt_data_rec.backorder_delivery_detail_id IS NOT NULL THEN
           IF (l_debug=1) THEN
              print_debug('Before calling revert_crossdock with following params:', l_module_name,4);
              print_debug('p_move_order_line_id => '|| l_mmtt_data_rec.move_order_line_id, l_module_name,4);
              print_debug('p_move_order_line_id => '|| l_mmtt_data_rec.move_order_line_id, l_module_name,4);
              print_debug('p_crossdock_type => '|| l_mmtt_data_rec.crossdock_type, l_module_name,4);
              print_debug('p_backorder_delivery_detail_id => '|| l_mmtt_data_rec.backorder_delivery_detail_id, l_module_name,4);
              print_debug('p_repetitive_line_id => '|| l_mmtt_data_rec.repetitive_line_id, l_module_name,4);
              print_debug('p_operation_seq_number => '|| l_mmtt_data_rec.operation_seq_num, l_module_name,4);
              print_debug('p_inventory_item_id => '|| l_mmtt_data_rec.inventory_item_id, l_module_name,4);
              print_debug('p_primary_quantity => '|| l_mmtt_data_rec.primary_quantity, l_module_name,4);
           END IF;

           revert_crossdock
             (x_return_status                  => l_return_status
              , x_msg_count                    => l_msg_count
              , x_msg_data                     => l_msg_data
              , p_move_order_line_id           => l_mmtt_data_rec.move_order_line_id
              , p_crossdock_type               => l_mmtt_data_rec.crossdock_type
              , p_backorder_delivery_detail_id => l_mmtt_data_rec.backorder_delivery_detail_id
              , p_repetitive_line_id           => l_mmtt_data_rec.repetitive_line_id
              , p_operation_seq_number         => l_mmtt_data_rec.operation_seq_num
              , p_inventory_item_id            => l_mmtt_data_rec.inventory_item_id
              , p_primary_quantity             => l_mmtt_data_rec.primary_quantity
              );

           IF l_return_status <>FND_API.g_ret_sts_success THEN
              IF (l_debug=1) THEN
                 print_debug('revert_crossdock finished with error. l_return_status = ' || l_return_status,l_module_name,4);
              END IF;

              RAISE FND_API.G_EXC_ERROR;
           END IF;

        END IF;

        IF (l_debug=1) THEN
           print_debug('x_return_status => '||x_return_status,l_module_name,1);
           print_debug('x_msg_data => '||x_msg_data,l_module_name,1);
           print_debug('x_msg_count => '||x_msg_count,l_module_name,1);

           print_debug('Exited. ',l_module_name,1);
        END IF;

     EXCEPTION
        WHEN fnd_api.g_exc_error THEN
           IF (l_debug=1) THEN
              print_debug('Error (fnd_api.g_exc_error) occured at'||l_progress,l_module_name,1);
           END IF;
           x_return_status:=FND_API.G_RET_STS_ERROR;
           ROLLBACK TO sp_op_inbound_cancel;
           IF c_mmtt_data_rec%isopen THEN
              CLOSE c_mmtt_data_rec;
           END IF;


        WHEN fnd_api.g_exc_unexpected_error THEN

           x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
           IF (l_debug=1) THEN
              print_debug('Unexpected Error (fnd_api.g_exc_unexpected_error) occured at '||l_progress,l_module_name,3);
           END IF;
           IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
              fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
           END IF;
           ROLLBACK TO sp_op_inbound_cancel;
           IF c_mmtt_data_rec%isopen THEN
              CLOSE c_mmtt_data_rec;
           END IF;

        WHEN OTHERS THEN

           x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
           IF (l_debug=1) THEN
              print_debug('Other Error occured at '||l_progress,l_module_name,1);
              IF SQLCODE IS NOT NULL THEN
                 print_debug('With SQL error : ' || SQLERRM(SQLCODE), l_module_name,1);
               END IF;
           END IF;

           IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
              fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
           END IF;

           ROLLBACK TO sp_op_inbound_cancel;
           IF c_mmtt_data_rec%isopen THEN
              CLOSE c_mmtt_data_rec;
           END IF;

     END cancel;


/**
    * <b> Abort </b>:
    * <p> This API is the document handler for Inbound document records and is called from
    *    Abort_Operation_Plan  </p>
    *
    *
    *    This API deletes the parent MMTT record, clear several fields of the child MMTT record,
    *
    *
    *  @param x_return_status      -Return Status
    *  @param x_msg_data           -Returns Message Data
    *  @param x_msg_count          -Returns the message count
    *  @param p_source_task_id     -Identifier of the document record.
    *  @param p_document_rec       -MMTT PL/SQL record
    *
   **/
      PROCEDURE ABORT
      (
       x_return_status      OUT  NOCOPY    VARCHAR2
       , x_msg_data           OUT  NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
       , x_msg_count          OUT  NOCOPY    NUMBER
       , p_document_rec        IN            mtl_material_transactions_temp%ROWTYPE
       , p_plan_orig_sub_code  IN  VARCHAR2
       , p_plan_orig_loc_id    IN  NUMBER
       , p_for_manual_drop     IN  BOOLEAN DEFAULT FALSE
       )
      IS
         l_progress NUMBER;
         l_module_name      VARCHAR2(30)   := 'ABORT';
         l_debug            NUMBER         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
         l_return_status  VARCHAR2(1);
         l_msg_count NUMBER;
         l_msg_data VARCHAR2(400);

      BEGIN

         x_return_status := FND_API.G_RET_STS_SUCCESS;
         l_progress      := 10;
         IF (l_debug=1) THEN
            print_debug('Entered. ',l_module_name,1);
            print_debug('p_document_rec.transaction_temp_id => ' ||p_document_rec.transaction_temp_id ,l_module_name,1);
            print_debug('p_document_rec.parent_line_id => ' ||p_document_rec.parent_line_id ,l_module_name,1);
            print_debug('p_document_rec.locator_id => ' ||p_document_rec.locator_id ,l_module_name,1);
            print_debug('p_document_rec.transfer_to_location => ' ||p_document_rec.transfer_to_location ,l_module_name,1);
            print_debug('p_document_rec.organization_id => '||p_document_rec.organization_id,l_module_name,4);
            print_debug('p_document_rec.primary_quantity => '||p_document_rec.primary_quantity,l_module_name,4);
            print_debug('p_document_rec.inventory_item_id => '||p_document_rec.inventory_item_id,l_module_name,4);
            print_debug('p_plan_orig_sub_code => ' || p_plan_orig_sub_code,l_module_name,1);
            print_debug('p_plan_orig_loc_id => ' || p_plan_orig_loc_id,l_module_name,1);
            IF(p_for_manual_drop = TRUE) THEN
               print_debug('p_for_manual_drop => TRUE',l_module_name, 4);
             ELSE
               print_debug('p_for_manual_drop => FALSE',l_module_name,4);
            END IF;

         END IF;

         SAVEPOINT sp_op_inbound_abort;

         l_progress:=20;
         /* null out the Operation Plan Id ,parent Line Id and delete the Parent transaction temp Id*/
         /*Call table hanlder to delete MMTT/MSNT/MTLT for the Parent MMTT*/
         INV_TRX_UTIL_PUB.Delete_transaction
           (x_return_status       => x_return_status,
            x_msg_data            => x_msg_data,
            x_msg_count           => x_msg_count,
            p_transaction_temp_id => p_document_rec.parent_line_id,
            p_update_parent       => FALSE);

         IF (l_debug=1) THEN
            print_debug('Return status from Delete Transaction'||x_return_status,l_module_name,9);
         END IF;


         IF (x_return_status<>FND_API.G_RET_STS_SUCCESS) THEN

            RAISE FND_API.G_EXC_ERROR;
         END IF;

         l_progress:=30;


         IF (p_plan_orig_loc_id IS NOT NULL) THEN

            IF l_debug=1 THEN
               print_debug('Call inv_loc_wms_utils.revert_loc_suggested_cap_nauto to revert capactity:',l_module_name,4);
               print_debug('p_organization_id => '||p_document_rec.organization_id,l_module_name,4);
               print_debug('p_inventory_location_id => '||p_plan_orig_loc_id,l_module_name,4);
               print_debug('p_inventory_item_id => '||p_document_rec.inventory_item_id,l_module_name,4);
               print_debug('p_quantity => '||p_document_rec.primary_quantity,l_module_name,4);
               print_debug('p_primary_uom_flag => '|| 'Y',l_module_name,4);
               print_debug('p_transaction_uom_code => '|| '',l_module_name,4);

            END IF;

            IF(p_for_manual_drop = TRUE) THEN
               IF l_debug=1 THEN
                  print_debug('inv_loc_wms_utils.Call revert_loc_suggested_capacity',l_module_name,4);
               END IF;
               inv_loc_wms_utils.revert_loc_suggested_capacity
                 (
                  x_return_status             => l_return_status
                  , x_msg_count                 => l_msg_count
                  , x_msg_data                  => l_msg_data
                  , p_organization_id           => p_document_rec.organization_id
                  , p_inventory_location_id     => p_plan_orig_loc_id
                  , p_inventory_item_id         => p_document_rec.inventory_item_id
                  , p_primary_uom_flag          => 'Y'
                  , p_transaction_uom_code      => NULL
                  , p_quantity                  => p_document_rec.primary_quantity
                  );
             ELSE
               IF l_debug=1 THEN
                  print_debug('inv_loc_wms_utils.Call revert_loc_suggested_cap_nauto',l_module_name,4);
               END IF;
               inv_loc_wms_utils.revert_loc_suggested_cap_nauto
                 (
                  x_return_status             => l_return_status
                  , x_msg_count                 => l_msg_count
                  , x_msg_data                  => l_msg_data
                  , p_organization_id           => p_document_rec.organization_id
                  , p_inventory_location_id     => p_plan_orig_loc_id
                  , p_inventory_item_id         => p_document_rec.inventory_item_id
                  , p_primary_uom_flag          => 'Y'
                  , p_transaction_uom_code      => NULL
                  , p_quantity                  => p_document_rec.primary_quantity
                  );

            END IF;

            IF l_debug=1 THEN
               print_debug('After calling inv_loc_wms_utils.revert_loc_suggested_cap_nauto:',l_module_name,4);
               print_debug('x_return_status => '||l_return_status,l_module_name,4);
               print_debug('x_msg_data => '||l_msg_data,l_module_name,4);
               print_debug('x_msg_count => '||l_msg_count,l_module_name,4);
            END IF;

            IF l_return_status <>FND_API.g_ret_sts_success THEN
               IF (l_debug=1) THEN
                  print_debug('inv_loc_wms_utils.revert_loc_suggested_cap_nauto finished with error. l_return_status = ' || l_return_status,l_module_name,4);
               END IF;

               -- Bug 5369010: do not raise exception if locator capacity API fails
               -- RAISE FND_API.G_EXC_ERROR;
            END IF;

         END IF;



         IF (l_debug=1) THEN
            print_debug('Updating parent Line id and Operation plan id for Src Document record',l_module_name,9);
            print_debug('Also update destination sub/loc Src Document record to that of the original task. ',l_module_name,9);
         END IF;

         IF p_document_rec.locator_id IS NULL THEN

            UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP
              SET operation_plan_id  = NULL ,
              parent_line_id     = NULL,
              subinventory_code  = p_plan_orig_sub_code,
              locator_id         = p_plan_orig_loc_id
              WHERE transaction_temp_id = p_document_rec.transaction_temp_id;

          ELSIF  p_document_rec.transfer_to_location IS NULL THEN

            UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP
              SET operation_plan_id  = NULL ,
              parent_line_id     = NULL,
              transfer_subinventory  = p_plan_orig_sub_code,
              transfer_to_location   = p_plan_orig_loc_id
              WHERE transaction_temp_id = p_document_rec.transaction_temp_id;

         END IF;


         IF (l_debug=1) THEN
            print_debug('x_return_status => '||x_return_status,l_module_name,1);
            print_debug('x_msg_data => '||x_msg_data,l_module_name,1);
            print_debug('x_msg_count => '||x_msg_count,l_module_name,1);

            print_debug('Exited. ',l_module_name,1);
         END IF;

      EXCEPTION
        WHEN fnd_api.g_exc_error THEN
           IF (l_debug=1) THEN
              print_debug('Error (fnd_api.g_exc_error) occured at '||l_progress,l_module_name,1);
           END IF;
           x_return_status:=FND_API.G_RET_STS_ERROR;
           ROLLBACK TO sp_op_inbound_abort;

        WHEN fnd_api.g_exc_unexpected_error THEN

           x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
           IF (l_debug=1) THEN
              print_debug('Unexpected Error (fnd_api.g_exc_unexpected_error) occured at '||l_progress,l_module_name,3);
           END IF;

           ROLLBACK TO sp_op_inbound_abort;

        WHEN OTHERS THEN

           x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
           IF (l_debug=1) THEN
              print_debug('Other Error occured at '||l_progress,l_module_name,1);
              IF SQLCODE IS NOT NULL THEN
                 print_debug('With SQL error : ' || SQLERRM(SQLCODE), l_module_name,1);
              END IF;
           END IF;

           ROLLBACK TO sp_op_inbound_abort;

      END abort;

END WMS_OP_INBOUND_PVT;

/
