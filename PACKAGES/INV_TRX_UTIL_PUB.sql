--------------------------------------------------------
--  DDL for Package INV_TRX_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TRX_UTIL_PUB" AUTHID CURRENT_USER AS
  /* $Header: INVTRXUS.pls 120.5.12010000.4 2011/11/22 09:40:01 gke ship $ */


  --    Name: INSERT_LINE_TRX
  --
  --    Input parameters:
  --       p_trx_hdr_id                   Transaction Header Id
  --       p_item_id                      Inventory Item Id
  --       p_revision                     Item Revision
  --       p_org_id                       Organization ID
  --       p_trx_action_id                Transaction Action
  --       p_subinv_code                  Subinventory Code
  --       p_tosubinv_code                Transfer Subinventory Code
  --       p_locator_id                   Locator ID
  --       p_tolocator_id                 Transfer Locator ID
  --       p_xfr_org_id                   Transfer Organization ID
  --       p_trx_type_id                  Transaction Type ID
  --       p_trx_src_type_id              Transaction Source Type ID
  --       p_trx_qty                      Quantity
  --       p_uom                          Unit Of Measurement
  --       p_date                         Transaction Date
  --       p_reason_id                    Reason ID
  --       p_user_id                      User ID
  --       p_frt_code                     Freight Code
  --       p_ship_num                     Shipment Number
  --       p_dist_id                      Distribution Account Id
  --       p_way_bill                     Waybill Airbill
  --       p_exp_arr                      Expected Arrival Date
  --       p_cost_group                   Cost Group Id
  --       p_from_lpn_id                  From LPN ID
  --       p_cnt_lpn_id                   Content LPN ID
  --       p_xfr_lpn_id                   Transfer LPN ID
  --       p_cost_of_transfer             Cost of Transfer              : 2326247
  --       p_cost_of_transportation       Cost of Transportation        : 2326247
  --       p_transfer_percentage          Transfer Percentage           : 2326247
  --       p_transportation_cost_account  Transportation Cost Account   : 2326247
  --       p_planning_org_id              Planning Organization ID      : Consignment and VMI Changes
  --       p_planning_tp_type             Planning TP Type              : Consignment and VMI Changes
  --       p_owning_org_id                Owning Organization ID        : Consignment and VMI Changes
  --       p_owning_tp_type               Owning TP Type                : Consignment and VMI Changes
  --       p_trx_src_line_id              Trx Source Line ID
  --       p_secondary_trx_qty            Secondary Transaction Quantity
  --       p_secondary_uom                Secondary Transaction Qty UOM
  --       p_move_order_line_id           Move Order Line ID            : Patchset J
  --       p_posting_flag                 Posting Flag                  : Patchset J
  --       p_ship_to_location_id          Ship To Location ID           : eIB Build; Bug# 4348541
  --	   p_relieve_reservations_flag	  Relieve Reservations Flag	: Bug 6310875
  --
  --      Output parameters:
  --       x_trx_tmp_id                   Transaction Temp ID
  --       x_proc_msg                     Message from the Process-Manager
  --       return_status                  0 on Success, 1 on Error
  --
  --     Functions:  This API calculates the account_period_id based on the
  --      transaction date and inserts a new row into MTL_MATERIAL_TRANSACTIONS_TEMP
  --      The function returns the transaction_temp_id which is unique for this
  --      record, and could be used for coupling Lot and Serial Transaction
  --      records associated with this transaction.
  --
  FUNCTION insert_line_trx(
    p_trx_hdr_id                  IN            NUMBER
  , p_item_id                     IN            NUMBER
  , p_revision                    IN            VARCHAR2 := NULL
  , p_org_id                      IN            NUMBER
  , p_trx_action_id               IN            NUMBER
  , p_subinv_code                 IN            VARCHAR2
  , p_tosubinv_code               IN            VARCHAR2 := NULL
  , p_locator_id                  IN            NUMBER := NULL
  , p_tolocator_id                IN            NUMBER := NULL
  , p_xfr_org_id                  IN            NUMBER := NULL
  , p_trx_type_id                 IN            NUMBER
  , p_trx_src_type_id             IN            NUMBER
  , p_trx_qty                     IN            NUMBER
  , p_pri_qty                     IN            NUMBER
  , p_uom                         IN            VARCHAR2
  , p_date                        IN            DATE := SYSDATE
  , p_reason_id                   IN            NUMBER := NULL
  , p_user_id                     IN            NUMBER
  , p_frt_code                    IN            VARCHAR2 := NULL
  , p_ship_num                    IN            VARCHAR2 := NULL
  , p_dist_id                     IN            NUMBER := NULL
  , p_way_bill                    IN            VARCHAR2 := NULL
  , p_exp_arr                     IN            DATE := NULL
  , p_cost_group                  IN            NUMBER := NULL
  , p_from_lpn_id                 IN            NUMBER := NULL
  , p_cnt_lpn_id                  IN            NUMBER := NULL
  , p_xfr_lpn_id                  IN            NUMBER := NULL
  , p_trx_src_id                  IN            NUMBER := NULL
  , x_trx_tmp_id                  OUT NOCOPY    NUMBER
  , x_proc_msg                    OUT NOCOPY    VARCHAR2
  , p_xfr_cost_group              IN            NUMBER := NULL
  , p_completion_trx_id           IN            NUMBER := NULL
  , p_flow_schedule               IN            VARCHAR2 := NULL
  , p_trx_cost                    IN            NUMBER := NULL
  , p_project_id                  IN            NUMBER := NULL
  , p_task_id                     IN            NUMBER := NULL
  , p_cost_of_transfer            IN            NUMBER := NULL
  , p_cost_of_transportation      IN            NUMBER := NULL
  , p_transfer_percentage         IN            NUMBER := NULL
  , p_transportation_cost_account IN            NUMBER := NULL
  , p_planning_org_id             IN            NUMBER := NULL
  , p_planning_tp_type            IN            NUMBER := NULL
  , p_owning_org_id               IN            NUMBER := NULL
  , p_owning_tp_type              IN            NUMBER := NULL
  , p_trx_src_line_id             IN            NUMBER := NULL
  , p_secondary_trx_qty           IN            NUMBER := NULL
  , p_secondary_uom               IN            VARCHAR2 := NULL
  , p_move_order_line_id          IN            NUMBER := NULL
  , p_posting_flag                IN            VARCHAR2 := NULL
  , p_move_order_header_id        IN            NUMBER := NULL
  , p_serial_allocated_flag       IN            VARCHAR2 := NULL
  , p_transaction_status          IN            NUMBER := NULL
  , p_process_flag                IN            VARCHAR2 := NULL
  , p_ship_to_location_id         IN            NUMBER DEFAULT NULL
  , p_relieve_reservations_flag   IN		VARCHAR2 DEFAULT NULL		--	Bug 6310875
  , p_opm_org_in_xfer             IN            VARCHAR2 DEFAULT NULL           --      Bug 8939057
    )
    RETURN NUMBER;

  --
  --     Name: INSERT_LOT_TRX
  --
  --     Input parameters:
  --       p_trx_tmp_id         Transaction Temp Id
  --       p_user_id            User ID
  --       p_lot_number         Lot Number
  --       p_trx_qty            Quantity
  --       p_pri_qty            Primary Quantity
  --       p_exp_date           Expiry Date
  --       p_secondary_qty      Secondary Quantity
  --       p_secondary_uom      Secondary Quantity UOM
  --
  --      Output parameters:
  --       x_ser_trx_id        Serial Transaction Temp Id, to be used if
  --                            inserting SerialNumber records associated
  --                            with Lot Number.
  --       x_proc_msg          Message from the Process-Manager
  --       return_status       0 on Success, 1 on Error
  --
  --      Functions: This function inserts a Lot Transaction record into
  --          MTL_TRANSACTION_LOT_NUMBERS. The argument p_trx_tmp_id is
  --          used to couple this record with a transaction-line in
  --          MTL_MATERIAL_TRANSACTIONS_TEMP
  --
  FUNCTION insert_lot_trx(
    p_trx_tmp_id             IN            NUMBER
  , p_user_id                IN            NUMBER
  , p_lot_number             IN            VARCHAR2
  , p_trx_qty                IN            NUMBER
  , p_pri_qty                IN            NUMBER
  , p_exp_date               IN            DATE := NULL
  , p_description            IN            VARCHAR2 := NULL
  , p_vendor_name            IN            VARCHAR2 := NULL
  , p_supplier_lot_number    IN            VARCHAR2 := NULL
  , p_origination_date       IN            DATE := NULL
  , p_date_code              IN            VARCHAR2 := NULL
  , p_grade_code             IN            VARCHAR2 := NULL
  , p_change_date            IN            DATE := NULL
  , p_maturity_date          IN            DATE := NULL
  , p_status_id              IN            NUMBER := NULL
  , p_retest_date            IN            DATE := NULL
  , p_age                    IN            NUMBER := NULL
  , p_item_size              IN            NUMBER := NULL
  , p_color                  IN            VARCHAR2 := NULL
  , p_volume                 IN            NUMBER := NULL
  , p_volume_uom             IN            VARCHAR2 := NULL
  , p_place_of_origin        IN            VARCHAR2 := NULL
  , p_best_by_date           IN            DATE := NULL
  , p_length                 IN            NUMBER := NULL
  , p_length_uom             IN            VARCHAR2 := NULL
  , p_recycled_content       IN            NUMBER := NULL
  , p_thickness              IN            NUMBER := NULL
  , p_thickness_uom          IN            VARCHAR2 := NULL
  , p_width                  IN            NUMBER := NULL
  , p_width_uom              IN            VARCHAR2 := NULL
  , p_curl_wrinkle_fold      IN            VARCHAR2 := NULL
  , p_lot_attribute_category IN            VARCHAR2 := NULL
  , p_c_attribute1           IN            VARCHAR2 := NULL
  , p_c_attribute2           IN            VARCHAR2 := NULL
  , p_c_attribute3           IN            VARCHAR2 := NULL
  , p_c_attribute4           IN            VARCHAR2 := NULL
  , p_c_attribute5           IN            VARCHAR2 := NULL
  , p_c_attribute6           IN            VARCHAR2 := NULL
  , p_c_attribute7           IN            VARCHAR2 := NULL
  , p_c_attribute8           IN            VARCHAR2 := NULL
  , p_c_attribute9           IN            VARCHAR2 := NULL
  , p_c_attribute10          IN            VARCHAR2 := NULL
  , p_c_attribute11          IN            VARCHAR2 := NULL
  , p_c_attribute12          IN            VARCHAR2 := NULL
  , p_c_attribute13          IN            VARCHAR2 := NULL
  , p_c_attribute14          IN            VARCHAR2 := NULL
  , p_c_attribute15          IN            VARCHAR2 := NULL
  , p_c_attribute16          IN            VARCHAR2 := NULL
  , p_c_attribute17          IN            VARCHAR2 := NULL
  , p_c_attribute18          IN            VARCHAR2 := NULL
  , p_c_attribute19          IN            VARCHAR2 := NULL
  , p_c_attribute20          IN            VARCHAR2 := NULL
  , p_d_attribute1           IN            DATE := NULL
  , p_d_attribute2           IN            DATE := NULL
  , p_d_attribute3           IN            DATE := NULL
  , p_d_attribute4           IN            DATE := NULL
  , p_d_attribute5           IN            DATE := NULL
  , p_d_attribute6           IN            DATE := NULL
  , p_d_attribute7           IN            DATE := NULL
  , p_d_attribute8           IN            DATE := NULL
  , p_d_attribute9           IN            DATE := NULL
  , p_d_attribute10          IN            DATE := NULL
  , p_n_attribute1           IN            NUMBER := NULL
  , p_n_attribute2           IN            NUMBER := NULL
  , p_n_attribute3           IN            NUMBER := NULL
  , p_n_attribute4           IN            NUMBER := NULL
  , p_n_attribute5           IN            NUMBER := NULL
  , p_n_attribute6           IN            NUMBER := NULL
  , p_n_attribute7           IN            NUMBER := NULL
  , p_n_attribute8           IN            NUMBER := NULL
  , p_n_attribute9           IN            NUMBER := NULL
  , p_n_attribute10          IN            NUMBER := NULL
  , x_ser_trx_id             OUT NOCOPY    NUMBER
  , x_proc_msg               OUT NOCOPY    VARCHAR2
  , p_territory_code         IN            VARCHAR2 := NULL
  , p_vendor_id              IN            VARCHAR2 := NULL
  , p_secondary_qty          IN            NUMBER := NULL
  , p_secondary_uom          IN            VARCHAR2 := NULL

  --Bug No 3952081
  --Add arguments to intake new OPM attributes of the lot
  , p_parent_lot_number      IN            MTL_LOT_NUMBERS.PARENT_LOT_NUMBER%TYPE := NULL
  , p_origination_type       IN            MTL_LOT_NUMBERS.ORIGINATION_TYPE%TYPE := NULL
  , p_expriration_action_date IN           MTL_LOT_NUMBERS.EXPIRATION_ACTION_DATE%TYPE := NULL
  , p_expriration_action_code IN           MTL_LOT_NUMBERS.EXPIRATION_ACTION_CODE%TYPE := NULL
  , p_hold_date              IN            MTL_LOT_NUMBERS.HOLD_DATE%TYPE := NULL
  )
    RETURN NUMBER;

  --
  --     Name: INSERT_SER_TRX
  --
  --     Input parameters:
  --       p_trx_tmp_id         Transaction Temp ID
  --       p_user_id            User ID
  --       p_fm_ser_num         'From' Serial Number
  --       p_to_ser_num         'To'   Serial Number
  --
  --      Output parameters:
  --       x_proc_msg          Message from the Process-Manager
  --       return_status       0 on Success, 1 on Error
  --
  --      Functions: This API inserts a Serial Transaction record into
  --       MTL_SERIAL_NUMBERS_TEMP. The argument p_trx_tmp_id is
  --       used to couple this record with a transaction-line in
  --       MTL_MATERIAL_TRANSACTIONS_TEMP
  --
  FUNCTION insert_ser_trx(
    p_trx_tmp_id                IN            NUMBER
  , p_user_id                   IN            NUMBER
  , p_fm_ser_num                IN            VARCHAR2
  , p_to_ser_num                IN            VARCHAR2
  , p_ven_ser_num               IN            VARCHAR2 := NULL
  , p_vet_lot_num               IN            VARCHAR2 := NULL
  , p_parent_ser_num            IN            VARCHAR2 := NULL
  , p_end_item_unit_num         IN            VARCHAR2 := NULL
  , p_serial_attribute_category IN            VARCHAR2 := NULL
  , p_orgination_date           IN            DATE := NULL
  , p_c_attribute1              IN            VARCHAR2 := NULL
  , p_c_attribute2              IN            VARCHAR2 := NULL
  , p_c_attribute3              IN            VARCHAR2 := NULL
  , p_c_attribute4              IN            VARCHAR2 := NULL
  , p_c_attribute5              IN            VARCHAR2 := NULL
  , p_c_attribute6              IN            VARCHAR2 := NULL
  , p_c_attribute7              IN            VARCHAR2 := NULL
  , p_c_attribute8              IN            VARCHAR2 := NULL
  , p_c_attribute9              IN            VARCHAR2 := NULL
  , p_c_attribute10             IN            VARCHAR2 := NULL
  , p_c_attribute11             IN            VARCHAR2 := NULL
  , p_c_attribute12             IN            VARCHAR2 := NULL
  , p_c_attribute13             IN            VARCHAR2 := NULL
  , p_c_attribute14             IN            VARCHAR2 := NULL
  , p_c_attribute15             IN            VARCHAR2 := NULL
  , p_c_attribute16             IN            VARCHAR2 := NULL
  , p_c_attribute17             IN            VARCHAR2 := NULL
  , p_c_attribute18             IN            VARCHAR2 := NULL
  , p_c_attribute19             IN            VARCHAR2 := NULL
  , p_c_attribute20             IN            VARCHAR2 := NULL
  , p_d_attribute1              IN            DATE := NULL
  , p_d_attribute2              IN            DATE := NULL
  , p_d_attribute3              IN            DATE := NULL
  , p_d_attribute4              IN            DATE := NULL
  , p_d_attribute5              IN            DATE := NULL
  , p_d_attribute6              IN            DATE := NULL
  , p_d_attribute7              IN            DATE := NULL
  , p_d_attribute8              IN            DATE := NULL
  , p_d_attribute9              IN            DATE := NULL
  , p_d_attribute10             IN            DATE := NULL
  , p_n_attribute1              IN            NUMBER := NULL
  , p_n_attribute2              IN            NUMBER := NULL
  , p_n_attribute3              IN            NUMBER := NULL
  , p_n_attribute4              IN            NUMBER := NULL
  , p_n_attribute5              IN            NUMBER := NULL
  , p_n_attribute6              IN            NUMBER := NULL
  , p_n_attribute7              IN            NUMBER := NULL
  , p_n_attribute8              IN            NUMBER := NULL
  , p_n_attribute9              IN            NUMBER := NULL
  , p_n_attribute10             IN            NUMBER := NULL
  , p_status_id                 IN            NUMBER := NULL
  , p_territory_code            IN            VARCHAR2 := NULL
  , p_time_since_new            IN            NUMBER := NULL
  , p_cycles_since_new          IN            NUMBER := NULL
  , p_time_since_overhaul       IN            NUMBER := NULL
  , p_cycles_since_overhaul     IN            NUMBER := NULL
  , p_time_since_repair         IN            NUMBER := NULL
  , p_cycles_since_repair       IN            NUMBER := NULL
  , p_time_since_visit          IN            NUMBER := NULL
  , p_cycles_since_visit        IN            NUMBER := NULL
  , p_time_since_mark           IN            NUMBER := NULL
  , p_cycles_since_mark         IN            NUMBER := NULL
  , p_number_of_repairs         IN            NUMBER := NULL
  , p_validation_level          IN            NUMBER := NULL
  , p_wms_installed             IN            VARCHAR2 := NULL
  , p_quantity                  IN            NUMBER := NULL
  , x_proc_msg                  OUT NOCOPY    VARCHAR2
  , p_attribute_category        IN            VARCHAR2 := NULL
  , p_attribute1                IN            VARCHAR2 := NULL
  , p_attribute2                IN            VARCHAR2 := NULL
  , p_attribute3                IN            VARCHAR2 := NULL
  , p_attribute4                IN            VARCHAR2 := NULL
  , p_attribute5                IN            VARCHAR2 := NULL
  , p_attribute6                IN            VARCHAR2 := NULL
  , p_attribute7                IN            VARCHAR2 := NULL
  , p_attribute8                IN            VARCHAR2 := NULL
  , p_attribute9                IN            VARCHAR2 := NULL
  , p_attribute10               IN            VARCHAR2 := NULL
  , p_attribute11               IN            VARCHAR2 := NULL
  , p_attribute12               IN            VARCHAR2 := NULL
  , p_attribute13               IN            VARCHAR2 := NULL
  , p_attribute14               IN            VARCHAR2 := NULL
  , p_attribute15               IN            VARCHAR2 := NULL
  , p_dffupdatedflag		IN 	      VARCHAR2 := NULL
  )
    RETURN NUMBER;

/**
  * The API is responsible for Creating a New MMTT by copying column values
  * from an Existing MMTT.
  * <p>
  * Column Values from the old MMTT will be copied to the new MMTT. But
  * preference will be given to the parameters corresponding to the Column
  * Values if they have a Not NULL value.
  * <p>
  * Values for the Parameter: <br>
  *   1. NULL value - The column value from the existing MMTT will be used
  *      for that column. <br>
  *   2. G_MISS_XXX - The respective column will be set to NULL. <br>
  *   3. Valid Value - The passed parameter value will be used. <br>
  * <p>
  * Mandatory Parameter: <br>
  *   1. Transaction Temp ID has to be passed for the API to go through
  *      successfully.
  * <p>
  * Optional Parameters: <br>
  *   It will be better (performance wise) to pass these parameters even
  *   though you dont want to override it. <br>
  *   1. Organization ID - Account Period will be checked. Org ID is required
  *      for that check. <br>
  *   2. Primary Qty and Transaction Qty - If only either of them is passed, it
  *      means that the Qty column is overriden. The other Qty has to be
  *      derived. It will be better to pass both or atleast Inventory Item ID and
  *      Transaction UOM. <br>
  * <p>
  * @param  x_return_status           Return Status
  * @param  x_msg_count               Number of Messages in the stack.
  * @param  x_msg_data                Message if Count is 1
  * @param  x_new_txn_temp_id         Transaction Temp ID of the new MMTT.
  * @param  p_transaction_temp_id     Transaction Temp ID of the existing MMTT
  * @param  p_inventory_item_id       Inventory Item ID (Cannot have G_MISS_NUM)
  * @param  p_revision                Revision
  * @param  p_organization_id         Organization ID (Cannot have G_MISS_NUM)
  * @param  p_subinventory_code       Subinventory Code
  * @param  p_locator_id              Locator ID
  * @param  p_cost_group_id           Cost Group ID
  * @param  p_to_organization_id      Transfer Organization ID
  * @param  p_to_subinventory_code    Transfer Subinventory Code
  * @param  p_to_locator_id           Transfer Locator ID
  * @param  p_to_cost_group_id        Transfer Cost Group ID
  * @param  p_txn_qty                 Transaction Qty (Cannot have G_MISS_NUM)
  * @param  p_primary_qty             Primary Qty (Cannot have G_MISS_NUM)
  * @param  p_sec_txn_qty             Secondary Qty (Cannot have G_MISS_NUM)
  * @param  p_transaction_uom         Transaction UOM (Cannot have G_MISS_CHAR)
  * @param  p_lpn_id                  LPN ID
  * @param  p_transfer_lpn_id         Transfer LPN ID
  * @param  p_content_lpn_id          Content LPN ID
  * @param  p_txn_type_id             Transaction Type ID (Cannot have G_MISS_NUM)
  * @param  p_txn_action_id           Transaction Action ID (Cannot have G_MISS_NUM)
  * @param  p_txn_source_type_id      Transaction Source Type ID (Cannot have G_MISS_NUM)
  * @param  p_transaction_date        Transaction Date (Cannot have G_MISS_DATE)
  * @param  p_transaction_source_id   Transaction Source ID
  * @param  p_trx_source_line_id      Transaction Source Line ID
  * @param  p_move_order_line_id      Move Order Line ID
  * @param  p_reservation_id          Reservation ID
  * @param  p_parent_line_id          Parent Line ID
  * @param  p_pick_slip_number        Pick Slip Number
  * @param  p_wms_task_type           WMS Task Type
  * @param  p_user_id                 User ID (Cannot have G_MISS_NUM)
  */
  PROCEDURE copy_insert_line_trx(
    x_return_status            OUT NOCOPY VARCHAR2
  , x_msg_data                 OUT NOCOPY VARCHAR2
  , x_msg_count                OUT NOCOPY NUMBER
  , x_new_txn_temp_id          OUT NOCOPY NUMBER
  , p_transaction_temp_id      IN         NUMBER
  , p_transaction_header_id    IN         NUMBER   DEFAULT NULL
  , p_inventory_item_id        IN         NUMBER   DEFAULT NULL
  , p_revision                 IN         VARCHAR2 DEFAULT NULL
  , p_organization_id          IN         NUMBER   DEFAULT NULL
  , p_subinventory_code        IN         VARCHAR2 DEFAULT NULL
  , p_locator_id               IN         NUMBER   DEFAULT NULL
  , p_cost_group_id            IN         NUMBER   DEFAULT NULL
  , p_to_organization_id       IN         NUMBER   DEFAULT NULL
  , p_to_subinventory_code     IN         VARCHAR2 DEFAULT NULL
  , p_to_locator_id            IN         NUMBER   DEFAULT NULL
  , p_to_cost_group_id         IN         NUMBER   DEFAULT NULL
  , p_txn_qty                  IN         NUMBER   DEFAULT NULL
  , p_primary_qty              IN         NUMBER   DEFAULT NULL
  , p_sec_txn_qty              IN         NUMBER   DEFAULT NULL --INVCONV KKILLAMS
  , p_transaction_uom          IN         VARCHAR2 DEFAULT NULL
  , p_lpn_id                   IN         NUMBER   DEFAULT NULL
  , p_transfer_lpn_id          IN         NUMBER   DEFAULT NULL
  , p_content_lpn_id           IN         NUMBER   DEFAULT NULL
  , p_txn_type_id              IN         NUMBER   DEFAULT NULL
  , p_txn_action_id            IN         NUMBER   DEFAULT NULL
  , p_txn_source_type_id       IN         NUMBER   DEFAULT NULL
  , p_transaction_date         IN         DATE     DEFAULT NULL
  , p_transaction_source_id    IN         NUMBER   DEFAULT NULL
  , p_trx_source_line_id       IN         NUMBER   DEFAULT NULL
  , p_move_order_line_id       IN         NUMBER   DEFAULT NULL
  , p_reservation_id           IN         NUMBER   DEFAULT NULL
  , p_parent_line_id           IN         NUMBER   DEFAULT NULL
  , p_pick_slip_number         IN         NUMBER   DEFAULT NULL
  , p_wms_task_type            IN         NUMBER   DEFAULT NULL
  , p_user_id                  IN         NUMBER   DEFAULT NULL
  , p_move_order_header_id     IN         NUMBER   DEFAULT NULL
  , p_serial_allocated_flag    IN         VARCHAR2 DEFAULT NULL
  , p_operation_plan_id        IN         NUMBER   DEFAULT NULL--lezhang
  , p_transaction_status       IN         NUMBER   DEFAULT NULL
  );

  /*
   *  Procedure: DELETE_TRANSACTION
   *    1. Deletes a MMTT record given the Transaction Temp ID
   *    2. If it is a Lot Controlled Item, cascades the Delete till MTLT
   *    3. If it is a Serial Controlled Item , cascades the Delete till MSNT. Unmarks the Serial.
   */
  PROCEDURE delete_transaction(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_data            OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , p_transaction_temp_id            NUMBER
  , p_update_parent                  BOOLEAN   DEFAULT TRUE
  );

  /*
   *  Procedure: UPDATE_PARENT_MMTT
   *    This procedure updates or deletes the parent task when one of the child tasks
   *    is deleted. Generally this procedure is called before deleting a Child Record.
   *    1. Parent MMTT Qty is updated if there will be more than one MMTT even after
   *       the deletion of the child record.
   *    2. Parent MMTT is deleted along with the Task when there will be only one MMTT
   *       after the deletion of the child record. Child Tasks will not be dispatched
   *       or Queued.
   */
  PROCEDURE update_parent_mmtt(
    x_return_status       OUT NOCOPY VARCHAR2
  , p_parent_line_id      IN         NUMBER
  , p_child_line_id       IN         NUMBER
  , p_lot_control_code    IN         NUMBER
  , p_serial_control_code IN         NUMBER
  );

  --
  -- Name : DELETE_LOT_SER_TRX
  --
  --   Input Parameters:
  --              p_trx_tmp_id    : Transction temp id
  --              p_org_id        : Organization id
  --              p_item_id       : Inventory Item Id
  --              p_lotctrl       : Lot control code
  --              p_serctrl       : Serial number control code
  --   Output Parameters:
  --              x_return_status : Return Status
  --

  PROCEDURE delete_lot_ser_trx(
    p_trx_tmp_id    IN            NUMBER
  , p_org_id        IN            NUMBER
  , p_item_id       IN            NUMBER
  , p_lotctrl       IN            NUMBER
  , p_serctrl       IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  );


  /*  Bug 13020024
   *  Procedure: call_rcv_manager
   *    Input Parameters:
   *          p_trx_header_id : Transaction Header Id
   *    Output Parameters:
   *          x_return_status : Return value of calling RCV TM
   *          x_outcome       : Outcome of calling RCV TM
   *          x_msg           : Error message
   *    This procedure is to call RCVTM for IOT in online mode.
   *    1. Fetches MMTs with p_trx_header_id, and update the related RTIs with a new group_id.
   *    2. Make a call to RCVTM with this group_id
   */

  PROCEDURE call_rcv_manager
            ( x_return_value       OUT  NOCOPY   NUMBER,
              x_outcome            OUT  NOCOPY   VARCHAR2,
              x_msg                OUT  NOCOPY   VARCHAR2,
              p_trx_header_id      IN   NUMBER
	           );

  --
  --
  --  Name : TRACE
  --
  --     Input parameters:
  --       p_mesg           Message to Trace
  --       p_mod            Module . A short string representing the module
  --       p_level          Trace level of message. A number from 1 - 9.
  --                            1 - Most serious error messages
  --                            9 - Least serious info. message
  --
  --      Output parameters:
  --
  --  Function : Inventory Tracing
  --   Inventory tracing is dependant on the following INV profiles
  --       INV_DEBUG_TRACE
  --       INV_DEBUG_FILE
  --       INV_DEBUG_LEVEL
  --
  --
  PROCEDURE TRACE(p_mesg VARCHAR2, p_mod VARCHAR2 := NULL, p_level NUMBER := 9);
END inv_trx_util_pub;

/
