--------------------------------------------------------
--  DDL for Package WMS_OP_INBOUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_OP_INBOUND_PVT" AUTHID CURRENT_USER AS
/*$Header: WMSOPIBS.pls 120.2.12010000.2 2008/10/10 07:43:51 abasheer ship $*/


/*Record type to pass values to ACtivate*/
TYPE DEST_PARAM_REC_TYPE IS RECORD
  (SUG_SUB_CODE               VARCHAR(10),
   SUG_LOCATION_ID            NUMBER,
   CARTONIZATION_ID           NUMBER
   );


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
    x_return_status      OUT  NOCOPY    VARCHAR2
  , x_msg_data           OUT  NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
  , x_msg_count          OUT  NOCOPY    NUMBER
  , x_source_task_id     OUT  NOCOPY    NUMBER
  , x_error_code         OUT  NOCOPY    NUMBER
  , p_source_task_id     IN             NUMBER
  , p_document_rec       IN             mtl_material_transactions_temp%ROWTYPE
  , p_operation_type_id  IN             NUMBER
  , p_revert_loc_capacity IN             BOOLEAN DEFAULT FALSE
  , p_subsequent_op_plan_id   IN        NUMBER DEFAULT NULL
  );


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
 );



/**
    *    <b> Complete </b>:
    * <p>This API is the document handler for Inbound document records and is called from
    *    Complete_operation_instance.
    *
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
       x_return_status      OUT  NOCOPY    VARCHAR2
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
       );

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
       );

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
      );

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
       );

 /** The revert_crossdock API reverts a sales order or wip crossdock by
      *
      * 1. Nulling out crossdock related data on MOL
      * 2. Notify wip or wsh that material should still be backordered.
      *
      *
      *  @param x_return_status                  -Return Status
      *  @param x_msg_data                       -Returns Message Data
      *  @param x_msg_count                      -Returns the message count
      *  @param p_move_order_line_id             -Identifier of the MTRL record
      *  @param p_crossdock_type                 -Crossdock type from MTRL
      *  @param p_backorder_delivery_detail_id   -Back order detail ID from MTRL
      *  @param p_repetitive_line_id             -Repetitive line ID from MMTT
      *  @param p_operation_seq_number           -Operation sequence no from MMTT
      *  @param p_inventory_item_id              -Inventory item used
      *  @param p_primary_quantity               -Primary quantity of the item
      *
     **/

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
    );

END WMS_OP_INBOUND_PVT;

/
