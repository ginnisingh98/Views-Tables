--------------------------------------------------------
--  DDL for Package INV_TXN_MANAGER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TXN_MANAGER_PUB" AUTHID CURRENT_USER AS
/* $Header: INVTXMGS.pls 120.7.12000000.1 2007/01/17 16:33:06 appldev ship $ */
/*#
 * This package contains the Inventory Transactions Process wrapper which
 * calls the Inventory Transaction Manager to process records in the material
 * transaction interface table.
 * @rep:scope public
 * @rep:product INV
 * @rep:lifecycle active
 * @rep:displayname Material Transaction
 * @rep:category BUSINESS_ENTITY INV_MATERIAL_TRANSACTION
 */
   TYPE Line_REC_Type IS RECORD (
     TRANSACTION_INTERFACE_ID       mtl_transactions_interface.transaction_interface_id%TYPE
     ,TRANSACTION_HEADER_ID   mtl_transactions_interface.transaction_HEADER_id%TYPE
     ,REQUEST_ID               mtl_transactions_interface.REQUEST_id%TYPE
     ,INVENTORY_ITEM_ID        mtl_transactions_interface.inventory_item_id%TYPE
     ,ORGANIZATION_ID          mtl_transactions_interface.organization_id%TYPE
     ,SUBINVENTORY_CODE        mtl_transactions_interface.SUBINVENTORY_CODE%TYPE
     ,TRANSFER_ORGANIZATION    mtl_transactions_interface.TRANSFER_ORGANIZATION%TYPE
     ,TRANSFER_SUBINVENTORY    mtl_transactions_interface.TRANSFER_SUBINVENTORY%TYPE
     ,TRANSACTION_UOM          mtl_transactions_interface.TRANSACTION_UOM%TYPE
     ,TRANSACTION_DATE         mtl_transactions_interface.TRANSACTION_DATE%TYPE
     ,TRANSACTION_QUANTITY     mtl_transactions_interface.TRANSACTION_QUANTITY%TYPE
     ,LOCATOR_ID               mtl_transactions_interface.LOCATOR_ID%TYPE
     ,TRANSFER_LOCATOR         mtl_transactions_interface.TRANSFER_LOCATOR%TYPE
     ,TRANSACTION_SOURCE_ID    mtl_transactions_interface.TRANSACTION_SOURCE_ID%TYPE
     ,TRANSACTION_SOURCE_TYPE_ID     mtl_transactions_interface.TRANSACTION_SOURCE_TYPE_ID%TYPE
     ,TRANSACTION_ACTION_ID    mtl_transactions_interface.TRANSACTION_ACTION_ID%TYPE
     ,TRANSACTION_TYPE_ID      mtl_transactions_interface.TRANSACTION_TYPE_ID%TYPE
     ,DISTRIBUTION_ACCOUNT_ID  mtl_transactions_interface.DISTRIBUTION_ACCOUNT_ID%TYPE
     ,SHIPPABLE_FLAG           mtl_transactions_interface.SHIPPABLE_FLAG%TYPE
     ,ROWID                          VARCHAR(31)
     ,NEW_AVERAGE_COST         mtl_transactions_interface.NEW_AVERAGE_COST%TYPE
     ,VALUE_CHANGE             mtl_transactions_interface.VALUE_CHANGE%TYPE
     ,PERCENTAGE_CHANGE        mtl_transactions_interface.PERCENTAGE_CHANGE%TYPE
     ,MATERIAL_ACCOUNT         mtl_transactions_interface.MATERIAL_ACCOUNT%TYPE
     ,MATERIAL_OVERHEAD_ACCOUNT      mtl_transactions_interface.MATERIAL_OVERHEAD_ACCOUNT%TYPE
     ,RESOURCE_ACCOUNT         mtl_transactions_interface.RESOURCE_ACCOUNT%TYPE
     ,OUTSIDE_PROCESSING_ACCOUNT     mtl_transactions_interface.OUTSIDE_PROCESSING_ACCOUNT%TYPE
     ,OVERHEAD_ACCOUNT         mtl_transactions_interface.OVERHEAD_ACCOUNT%TYPE
     ,REQUISITION_LINE_ID      mtl_transactions_interface.REQUISITION_LINE_ID%TYPE
     ,OVERCOMPLETION_TRANSACTION_QTY mtl_transactions_interface.OVERCOMPLETION_TRANSACTION_QTY%TYPE
     ,END_ITEM_UNIT_NUMBER     mtl_transactions_interface.END_ITEM_UNIT_NUMBER%TYPE
     ,SCHEDULED_PAYBACK_DATE   mtl_transactions_interface.SCHEDULED_PAYBACK_DATE%TYPE
     ,REVISION                 mtl_transactions_interface.REVISION%TYPE
     ,ORG_COST_GROUP_ID        mtl_transactions_interface.ORG_COST_GROUP_ID%TYPE
     ,COST_TYPE_ID             mtl_transactions_interface.COST_TYPE_ID%TYPE
     ,PRIMARY_QUANTITY         mtl_transactions_interface.PRIMARY_QUANTITY%TYPE
     ,SOURCE_LINE_ID           mtl_transactions_interface.SOURCE_LINE_ID%TYPE
     ,PROCESS_FLAG             mtl_transactions_interface.PROCESS_FLAG%TYPE
     ,TRANSACTION_SOURCE_NAME  mtl_transactions_interface.TRANSACTION_SOURCE_NAME%TYPE
     ,TRX_SOURCE_DELIVERY_ID   mtl_transactions_interface.TRX_SOURCE_DELIVERY_ID%TYPE
     ,TRX_SOURCE_LINE_ID       mtl_transactions_interface.TRX_SOURCE_LINE_ID%TYPE
     ,PARENT_ID         mtl_transactions_interface.PARENT_ID%TYPE
     ,TRANSACTION_BATCH_ID     mtl_transactions_interface.TRANSACTION_BATCH_ID%TYPE
     ,TRANSACTION_BATCH_SEQ    mtl_transactions_interface.TRANSACTION_BATCH_SEQ%TYPE
     -- INVCONV start fabdi
     ,SECONDARY_TRANSACTION_QUANTITY mtl_transactions_interface.SECONDARY_TRANSACTION_QUANTITY%TYPE
     ,SECONDARY_UOM_CODE             mtl_transactions_interface.SECONDARY_UOM_CODE%TYPE
     -- INVCONV end fabdi
     ,SHIP_TO_LOCATION_ID      mtl_transactions_interface.SHIP_TO_LOCATION_ID%TYPE --eIB Build; Bug# 4348541
     ,TRANSFER_PRICE           mtl_transactions_interface.TRANSFER_PRICE%TYPE
        -- OPM INVCONV umoogala For Process-Discrete Xfers Enh.
     -- Pawan  11th july added wip_entity_type
     ,WIP_ENTITY_TYPE          mtl_transactions_interface.WIP_ENTITY_TYPE%TYPE
     /*Bug 5392366. Added the following two columns. */
     ,COMPLETION_TRANSACTION_ID mtl_transactions_interface.COMPLETION_TRANSACTION_ID%TYPE
     ,MOVE_TRANSACTION_ID       mtl_transactions_interface.MOVE_TRANSACTION_ID%TYPE
   );


   TYPE line_Tbl_Type IS TABLE OF line_Rec_Type;


   -----------------------------------------------------------------------
   -- Global Constants for Transaction Processing Mode
   -- There are the values the column TRANSACTION_MODE in MTI/MMTT/MMT
   -- could have and their meanings. The columns determines 2 things
   --   1) the source of the transaction record (MTI or MMTT)
   --   2) mode of processing (Online, Asyncronous, Background)
   -----------------------------------------------------------------------
   PROC_MODE_MMTT_ONLINE    CONSTANT NUMBER :=  1 ;
   PROC_MODE_MMTT_ASYNC     CONSTANT NUMBER :=  2 ;
   PROC_MODE_MMTT_BGRND     CONSTANT NUMBER :=  3 ;
   PROC_MODE_MTI            CONSTANT NUMBER :=  8 ;

   -----------------------------------------------------------------------
   -- Please note that other constants used in the Transaction Manager are
   -- defined in package INV_GLOBALS  and TrxTypes.java
   -----------------------------------------------------------------------


   -----------------------------------------------------------------------
   -- Name : validate_group
   -- Desc : Validate a group of MTI records in a batch together.
   --          This is called from process_transaction() when TrxMngr processes
   --          a batch of records
   -- I/P params :
   --     p_header_id : transaction_header_id
   -----------------------------------------------------------------------
   PROCEDURE validate_group(p_header_id NUMBER
                                ,x_return_status OUT NOCOPY VARCHAR2
                                ,x_msg_count OUT NOCOPY NUMBER
                                ,x_msg_data OUT NOCOPY VARCHAR2
                                ,p_userid NUMBER DEFAULT -1
			    ,p_loginid NUMBER DEFAULT -1);



   -----------------------------------------------------------------------
   -- Name : validate_lines (wrapper)
   -- Desc : Validate each record of a batch in MTI .
   --        This procedure acts as a wrapper and calls the inner validate_lines.
   --
   -- I/P params :
   --     p_header_id : transaction_header_id
   --     p_validation_level : Validation level
   -----------------------------------------------------------------------
   PROCEDURE validate_lines(p_header_id NUMBER,
                           p_commit VARCHAR2 := fnd_api.g_false     ,
                           p_validation_level NUMBER  := fnd_api.g_valid_level_full  ,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count OUT NOCOPY NUMBER,
                           x_msg_data OUT NOCOPY VARCHAR2,
                           p_userid NUMBER DEFAULT -1,
                           p_loginid NUMBER DEFAULT -1,
                           p_applid NUMBER DEFAULT NULL,
                           p_progid NUMBER DEFAULT NULL);


   -----------------------------------------------------------------------
   -- Name : validate_lines (inner)
   -- Desc : Validate a record in MTI .
   --        This procedure is called from process_transaction() when TrxMngr
   --        processes a batch of records in MTI
   --
   -- I/P params :
   --     p_line_Rec_Type : MTI record type
   -----------------------------------------------------------------------
   PROCEDURE validate_lines(p_line_Rec_Type line_Rec_type,
                           p_commit VARCHAR2 := fnd_api.g_false     ,
                           p_validation_level NUMBER  := fnd_api.g_valid_level_full  ,
                           p_error_flag OUT NOCOPY VARCHAR2,
                           p_userid NUMBER DEFAULT -1,
                           p_loginid NUMBER DEFAULT -1,
                           p_applid NUMBER DEFAULT NULL,
                           p_progid NUMBER DEFAULT NULL);

   -----------------------------------------------------------------------
   -- Name : post_temp_validation
   -- Desc : Validations on a transaction record after moving to MMTT
   --        This procedure is called from process_transaction()
   --
   -- I/P params :
   --     p_line_rec_type : MTI record type
   -----------------------------------------------------------------------
   FUNCTION post_temp_validation(p_line_rec_type line_rec_type
                                   , p_val_req NUMBER
                                   , p_userid NUMBER DEFAULT -1
                                   , p_flow_schedule NUMBER
				   , p_lot_number VARCHAR2 DEFAULT NULL -- Added for bug 4377625
                                   ) RETURN BOOLEAN;


   -----------------------------------------------------------------------
   -- Name : get_open_period
   -- Desc : Determine Account PeriodId based on organization and transaction-date
   --        This procedure is called from validate_lines()
   --
   -- I/P params :
   --     p_org_id     : Org Id
   --     p_trans_date : Transaction Date
   -----------------------------------------------------------------------
   FUNCTION get_open_period(p_org_id NUMBER
                                 ,p_trans_date DATE
                                 ,p_chk_date NUMBER) RETURN NUMBER;


   -----------------------------------------------------------------------
   -- Name : process_Transactions
   -- Desc : This procedure is the interface API to the INV Transaction Manager.
   --        It is called to process a batch of transaction_records .
   --
   -- I/P Params :
   --     p_table      : Source of transaction records
   --                      ( 1 == MTI,  2 == MMTT)
   --     p_header_id  : Transaction Header Id
   --     p_commit     : commit after processing or not
   -- O/P Params :
   --     x_trans_count : count of transaction records processed
   --
   -----------------------------------------------------------------------
/*#
 * This function is the interface procedure to the Inventory Transaction Manager
 * to validate and process a batch of material transaction interface records.
 * @param p_api_version API Version of this procedure. Current version is 1.0
 * @param p_init_msg_list fnd_api.g_false or fnd_api.g_true is passed as input to determine whether to Initialize message list or not
 * @param p_commit Indicates whether to commit the changes after successful processing
 * @param p_validation_level Indicates whether or not to perform a full validation
 * @param x_return_status Returns the status to indicate success or failure of execution
 * @param x_msg_count Returns number of error message in the error message stack in case of failure
 * @param x_msg_data Returns the error message in case of failure
 * @param x_trans_count The count of material transaction interface records processed.
 * @param p_table Source of transaction records with value 1 of material transaction interface table and value 2 of material transaction temp table
 * @param p_header_id Transaction header id
 * @return Returns the status with value 0 to indicate successful processing and value -1 to indicate failure processing
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Material transaction interface records
 */
   FUNCTION process_Transactions(
          p_api_version         IN     NUMBER            ,
          p_init_msg_list       IN      VARCHAR2 := fnd_api.g_false     ,
          p_commit              IN      VARCHAR2 := fnd_api.g_false     ,
          p_validation_level    IN      NUMBER   := fnd_api.g_valid_level_full  ,
          x_return_status       OUT     NOCOPY VARCHAR2                        ,
          x_msg_count           OUT     NOCOPY NUMBER                          ,
          x_msg_data            OUT     NOCOPY VARCHAR2                        ,
          x_trans_count         OUT     NOCOPY NUMBER                          ,
          p_table               IN      NUMBER := 1                     ,
          p_header_id           IN      NUMBER  )
      RETURN NUMBER;


   -----------------------------------------------------------------------
   -- Name : tmpinsert
   -- Desc : Move a transaction record from MTI to MMTT
   --        This procedure is called from process_transaction()
   --
   -- I/P params :
   --     p_rowid     : rowid of record in MTI Id
   --
   -----------------------------------------------------------------------
   FUNCTION tmpinsert(p_header_id IN NUMBER)
     RETURN BOOLEAN;




   -----------------------------------------------------------------------
   -- Name : rel_reservations_mrp_update
   -- Desc : Relieve reservation for a transaction and update MRP tables for
   --         a transaction record in MMTT.
   --        This procedure is called from BaseTransaction.java
   --
   -- I/P params :
   --    p_header_id           : transaction_header_id in MMTT
   --    p_transaction_temp_id : transaction_temp_id in MMTT
   -----------------------------------------------------------------------
   -- Bug 4764790: passing the transaction id for relieving
   -- reservations along with the serial numbers
   PROCEDURE rel_reservations_mrp_update
     (p_header_id IN NUMBER,
      p_transaction_temp_id IN NUMBER,
      p_transaction_id NUMBER DEFAULT NULL,
      p_res_sts OUT NOCOPY VARCHAR2,
      p_res_msg OUT NOCOPY VARCHAR2,
      p_res_count OUT NOCOPY NUMBER,
      p_mrp_status OUT NOCOPY VARCHAR2);

  FUNCTION mrp_ship_order (
    p_disposition_id    NUMBER
  , p_inv_item_id       NUMBER
  , p_quantity          NUMBER
  , p_last_updated_by   NUMBER
  , p_org_id            NUMBER
  , p_line_num          VARCHAR2
  , p_shipment_date     DATE
  , p_demand_class      VARCHAR2
  ) RETURN BOOLEAN;

END INV_TXN_MANAGER_PUB;

 

/
