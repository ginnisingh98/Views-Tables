--------------------------------------------------------
--  DDL for Package INV_SERIAL_NUMBER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_SERIAL_NUMBER_PUB" AUTHID CURRENT_USER AS
  /* $Header: INVPSNS.pls 120.0.12010000.6 2010/07/27 12:08:22 hjogleka ship $ */
  /*#
 * The Serial Numbers procedures allow users to create, update and validate serials.
 * In Addition users can the uniqueness of a serial number,
 * get difference between two serial numbers, validate and update serial attributes and
 * create unit (serial) transactions
 * @rep:scope public
 * @rep:product INV
 * @rep:lifecycle active
 * @rep:displayname Inventory Serial Number
 * @rep:category BUSINESS_ENTITY INV_SERIAL_NUMBER
 */

  g_org_id                NUMBER;
  g_transfer_org_id       NUMBER;
  g_firstscan             BOOLEAN                                      := TRUE;
  g_serial_attributes_tbl inv_lot_sel_attr.lot_sel_attributes_tbl_type;

/*#
 * Use this procedure to populate Serial Attribute columns
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Populate Serial Attribute Columns
 */
  PROCEDURE populateattributescolumn;

/*#
 * Use this procedure to Set the value of g_firstscan variable
 * @param p_firstscan TRUE or FALSE can be passed as input in this variable to set the value of g_firstscan
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set First Scan
 */
  PROCEDURE set_firstscan(p_firstscan IN BOOLEAN);

  -- Overloaded Procedure insertSerial for eAM
 /*#
 * Use this procedure to validate and insert a given Serial Number.
 * @param p_api_version API version is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_init_msg_list fnd_api.g_false or fnd_api.g_true is passed as input in this variable to determine whether to Initialize message list or not
 * @paraminfo {@rep:required}
 * @param p_commit fnd_api.g_false or fnd_api.g_true is passed as input in this variable to determine whether to commit or not
 * @paraminfo {@rep:required}
 * @param p_validation_level Validation level is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_inventory_item_id Inventory Item id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_organization_id Organization id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_serial_number Serial Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_current_status Current Status of the Serial Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_group_mark_id Group Mark id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_lot_number Lot Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_initialization_date Initialization Date is passed as input in this variable
 * @param x_return_status Return Status indiacation success or failure.
 * @paraminfo {@rep:required}
 * @param x_msg_count message count from the error stack in case of failure
 * @paraminfo {@rep:required}
 * @param x_msg_data x_msg_data Return the error message in case of failure
 * @paraminfo {@rep:required}
 * @param p_organization_type Organization type is passed as input in this variable
 * @param p_owning_org_id Owning Organization id is passed as input in this variable
 * @param p_owning_tp_type Owning Trading partner type is passed as input in this variable
 * @param p_planning_org_id Planning Organization id is passed as input in this variable
 * @param p_planning_tp_type Planning Trading partner type is passed as input in this variable
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Insert Serial Number
 */
  PROCEDURE insertserial(
    p_api_version         IN            NUMBER
  , p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false
  , p_commit              IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level    IN            NUMBER := fnd_api.g_valid_level_full
  , p_inventory_item_id   IN            NUMBER
  , p_organization_id     IN            NUMBER
  , p_serial_number       IN            VARCHAR2
  , p_current_status      IN            NUMBER
  , p_group_mark_id       IN            NUMBER
  , p_lot_number          IN            VARCHAR2
  , p_initialization_date IN            DATE DEFAULT SYSDATE
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , p_organization_type   IN            NUMBER DEFAULT NULL
  , p_owning_org_id       IN            NUMBER DEFAULT NULL
  , p_owning_tp_type      IN            NUMBER DEFAULT NULL
  , p_planning_org_id     IN            NUMBER DEFAULT NULL
  , p_planning_tp_type    IN            NUMBER DEFAULT NULL
  );

  -- 'Serial Tracking in WIP project. add wip_entity_id, operation_seq_num, intraooperation_step_type
  -- also as the input parameters.
  /*#
 * Use this procedure to validate and insert a given Serial Number.
 * @param p_api_version API version is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_init_msg_list fnd_api.g_false or fnd_api.g_true is passed as input in this variable to determine whether to Initialize message list or not
 * @paraminfo {@rep:required}
 * @param p_commit fnd_api.g_false or fnd_api.g_true is passed as input in this variable to determine whether to commit or not
 * @paraminfo {@rep:required}
 * @param p_validation_level Validation level is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_inventory_item_id Inventory Item id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_organization_id Organization id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_serial_number Serial Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_initialization_date Initialization Date is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_completion_date Unit completion date is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_ship_date Unit Ship Date is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_revision Inventory Item Revision code is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_lot_number Lot Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_current_locator_id Current Locator id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_subinventory_code Current Subinventry Code is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_trx_src_id Transaction Source id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_unit_vendor_id Unit Supplier Code is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_vendor_lot_number Supplier Lot Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_vendor_serial_number Supplier Serial Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_receipt_issue_type Transaction Type is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_txn_src_id Transaction Source id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_txn_src_name Transaction source Name is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_txn_src_type_id Transaction Source type id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_transaction_id Transaction id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_current_status Current Status of the Serial Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_parent_item_id Component parent part Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_parent_serial_number Component parent Serial Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_cost_group_id Cost Group id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_transaction_action_id Transaction action id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_transaction_temp_id Transaction Temp id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_status_id Status id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param x_object_id Return Object id
 * @paraminfo {@rep:required}
 * @param x_return_status Return Status indiacation success or failure.
 * @paraminfo {@rep:required}
 * @param x_msg_count message count from the error stack in case of failure
 * @paraminfo {@rep:required}
 * @param x_msg_data x_msg_data Return the error message in case of failure
 * @paraminfo {@rep:required}
 * @param p_organization_type Organization type is passed as input in this variable
 * @param p_owning_org_id Owning Organization id is passed as input in this variable
 * @param p_owning_tp_type Owning Trading partner type is passed as input in this variable
 * @param p_planning_org_id Planning Organization id is passed as input in this variable
 * @param p_planning_tp_type Planning Trading partner type is passed as input in this variable
 * @param p_wip_entity_id Wip entity id is passed as input in this variable
 * @param p_operation_seq_num Wip operaion Sequence Number is passed as input in this variable
 * @param p_intraoperation_step_type Code for Interopration step in mfg_lookups is passed as input in this variable
 * @paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Insert Serial Number
 */
 PROCEDURE insertserial(
    p_api_version              IN            NUMBER
  , p_init_msg_list            IN            VARCHAR2 := fnd_api.g_false
  , p_commit                   IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level         IN            NUMBER := fnd_api.g_valid_level_full
  , p_inventory_item_id        IN            NUMBER
  , p_organization_id          IN            NUMBER
  , p_serial_number            IN            VARCHAR2
  , p_initialization_date      IN            DATE
  , p_completion_date          IN            DATE
  , p_ship_date                IN            DATE
  , p_revision                 IN            VARCHAR2
  , p_lot_number               IN            VARCHAR2
  , p_current_locator_id       IN            NUMBER
  , p_subinventory_code        IN            VARCHAR2
  , p_trx_src_id               IN            NUMBER
  , p_unit_vendor_id           IN            NUMBER
  , p_vendor_lot_number        IN            VARCHAR2
  , p_vendor_serial_number     IN            VARCHAR2
  , p_receipt_issue_type       IN            NUMBER
  , p_txn_src_id               IN            NUMBER
  , p_txn_src_name             IN            VARCHAR2
  , p_txn_src_type_id          IN            NUMBER
  , p_transaction_id           IN            NUMBER
  , p_current_status           IN            NUMBER
  , p_parent_item_id           IN            NUMBER
  , p_parent_serial_number     IN            VARCHAR2
  , p_cost_group_id            IN            NUMBER
  , p_transaction_action_id    IN            NUMBER
  , p_transaction_temp_id      IN            NUMBER
  , p_status_id                IN            NUMBER
  , x_object_id                OUT NOCOPY    NUMBER
  , x_return_status            OUT NOCOPY    VARCHAR2
  , x_msg_count                OUT NOCOPY    NUMBER
  , x_msg_data                 OUT NOCOPY    VARCHAR2
  , p_organization_type        IN            NUMBER DEFAULT NULL
  , p_owning_org_id            IN            NUMBER DEFAULT NULL
  , p_owning_tp_type           IN            NUMBER DEFAULT NULL
  , p_planning_org_id          IN            NUMBER DEFAULT NULL
  , p_planning_tp_type         IN            NUMBER DEFAULT NULL
  , p_wip_entity_id            IN            NUMBER DEFAULT NULL
  , p_operation_seq_num        IN            NUMBER DEFAULT NULL
  , p_intraoperation_step_type IN            NUMBER DEFAULT NULL
  );

  -- This api is the wrapper to insert a range of serial numbers into
  -- mtl_serial_numbers

  /* FP-J Lot/Serial Support Enhancement
   * Created a new parameter p_rcv_serial_flag that would be used to identify
   * that this API is called from receiving UI, which is used to control updates
   * to MTL_SERIAL_NUMBERS
   */
   /*#
 * Use this procedure to validate and insert a range of Serial Numbers
 * based on Start Serial Number and End Serial Number.
 * @param p_api_version API version is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_init_msg_list fnd_api.g_false or fnd_api.g_true is passed as input in this variable to determine whether to Initialize message list or not
 * @paraminfo {@rep:required}
 * @param p_commit fnd_api.g_false or fnd_api.g_true is passed as input in this variable to determine whether to commit or not
 * @paraminfo {@rep:required}
 * @param p_validation_level Validation level is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_inventory_item_id Inventory Item id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_organization_id Organization id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_from_serial_number Start Serial Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_to_serial_number End Serial Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_initialization_date Initialization Date is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_completion_date Unit completion date is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_ship_date Unit Ship Date is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_revision Inventory Item Revision code is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_lot_number Lot Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_current_locator_id Current Locator id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_subinventory_code Current Subinventry Code is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_trx_src_id Transaction Source id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_unit_vendor_id Unit Supplier Code is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_vendor_lot_number Supplier Lot Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_vendor_serial_number Supplier Serial Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_receipt_issue_type Transaction Type is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_txn_src_id Transaction Source id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_txn_src_name Transaction source Name is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_txn_src_type_id Transaction Source type id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_transaction_id Transaction id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_current_status Current Status of the Serial Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_parent_item_id Component parent part Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_parent_serial_number Component parent Serial Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_cost_group_id Cost Group id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_transaction_action_id Transaction action id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_transaction_temp_id Transaction Temp id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_status_id Status id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_inspection_status Status after Inspection is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param x_object_id Return Object id
 * @paraminfo {@rep:required}
 * @param x_return_status Return Status indiacation success or failure.
 * @paraminfo {@rep:required}
 * @param x_msg_count message count from the error stack in case of failure
 * @paraminfo {@rep:required}
 * @param x_msg_data x_msg_data Return the error message in case of failure
 * @paraminfo {@rep:required}
 * @param p_organization_type Organization type is passed as input in this variable
 * @param p_owning_org_id Owning Organization id is passed as input in this variable
 * @param p_owning_tp_type Owning Trading partner type is passed as input in this variable
 * @param p_planning_org_id Planning Organization id is passed as input in this variable
 * @param p_planning_tp_type Planning Trading partner type is passed as input in this variable
 * @param p_rcv_serial_flag Flag specicying receiving serial or not is passed as input in this variable
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Insert Range of Serial Numbers
 */
 PROCEDURE insert_range_serial(
    p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 := fnd_api.g_false
  , p_commit                IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level      IN            NUMBER := fnd_api.g_valid_level_full
  , p_inventory_item_id     IN            NUMBER
  , p_organization_id       IN            NUMBER
  , p_from_serial_number    IN            VARCHAR2
  , p_to_serial_number      IN            VARCHAR2
  , p_initialization_date   IN            DATE
  , p_completion_date       IN            DATE
  , p_ship_date             IN            DATE
  , p_revision              IN            VARCHAR2
  , p_lot_number            IN            VARCHAR2
  , p_current_locator_id    IN            NUMBER
  , p_subinventory_code     IN            VARCHAR2
  , p_trx_src_id            IN            NUMBER
  , p_unit_vendor_id        IN            NUMBER
  , p_vendor_lot_number     IN            VARCHAR2
  , p_vendor_serial_number  IN            VARCHAR2
  , p_receipt_issue_type    IN            NUMBER
  , p_txn_src_id            IN            NUMBER
  , p_txn_src_name          IN            VARCHAR2
  , p_txn_src_type_id       IN            NUMBER
  , p_transaction_id        IN            NUMBER
  , p_current_status        IN            NUMBER
  , p_parent_item_id        IN            NUMBER
  , p_parent_serial_number  IN            VARCHAR2
  , p_cost_group_id         IN            NUMBER
  , p_transaction_action_id IN            NUMBER
  , p_transaction_temp_id   IN            NUMBER
  , p_status_id             IN            NUMBER
  , p_inspection_status     IN            NUMBER
  , x_object_id             OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , p_organization_type     IN            NUMBER DEFAULT NULL
  , p_owning_org_id         IN            NUMBER DEFAULT NULL
  , p_owning_tp_type        IN            NUMBER DEFAULT NULL
  , p_planning_org_id       IN            NUMBER DEFAULT NULL
  , p_planning_tp_type      IN            NUMBER DEFAULT NULL
  , p_rcv_serial_flag       IN            VARCHAR2 DEFAULT NULL
  );

  -- 'Serial Tracking in WIP project. add wip_entity_id, operation_seq_num, intraooperation_step_type, line_mark_id
  -- also as the input parameters.
  /*#
 * Use this procedure to update a given Serial Number
 * @param p_api_version API version is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_init_msg_list fnd_api.g_false or fnd_api.g_true is passed as input in this variable to determine whether to Initialize message list or not
 * @paraminfo {@rep:required}
 * @param p_commit fnd_api.g_false or fnd_api.g_true is passed as input in this variable to determine whether to commit or not
 * @paraminfo {@rep:required}
 * @param p_validation_level Validation level is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_inventory_item_id Inventory Item id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_organization_id Organization id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_serial_number Serial Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_initialization_date Initialization Date is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_completion_date Unit completion date is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_ship_date Unit Ship Date is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_revision Inventory Item Revision code is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_lot_number Lot Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_current_locator_id Current Locator id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_subinventory_code Current Subinventry Code is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_trx_src_id Transaction Source id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_unit_vendor_id Unit Supplier Code is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_vendor_lot_number Supplier Lot Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_vendor_serial_number Supplier Serial Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_receipt_issue_type Transaction Type is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_txn_src_id Transaction Source id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_txn_src_name Transaction source Name is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_txn_src_type_id Transaction Source type id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_current_status Current Status of the Serial Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_parent_item_id Component parent part Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_parent_serial_number Component parent Serial Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_serial_temp_id Transaction temp id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_last_status Last Status is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_status_id Status id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param x_object_id Return Object id
 * @paraminfo {@rep:required}
 * @param x_return_status Return Status indiacation success or failure.
 * @paraminfo {@rep:required}
 * @param x_msg_count message count from the error stack in case of failure
 * @paraminfo {@rep:required}
 * @param x_msg_data x_msg_data Return the error message in case of failure
 * @paraminfo {@rep:required}
 * @param p_organization_type Organization type is passed as input in this variable
 * @param p_owning_org_id Owning Organization id is passed as input in this variable
 * @param p_owning_tp_type Owning Trading partner type is passed as input in this variable
 * @param p_transaction_action_id Transaction action id is passed as input in this variable
 * @param p_planning_org_id Planning Organization id is passed as input in this variable
 * @param p_planning_tp_type Planning Trading partner type is passed as input in this variable
 * @param p_wip_entity_id Wip entity id is passed as input in this variable
 * @param p_operation_seq_num Wip operaion Sequence Number is passed as input in this variable
 * @param p_intraoperation_step_type Code for Interopration step in mfg_lookups is passed as input in this variable
 * @param p_line_mark_id Line identifier is passed as input in this variable
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Serial Number
 */
PROCEDURE updateserial(
    p_api_version              IN            NUMBER
  , p_init_msg_list            IN            VARCHAR2 := fnd_api.g_false
  , p_commit                   IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level         IN            NUMBER := fnd_api.g_valid_level_full
  , p_inventory_item_id        IN            NUMBER
  , p_organization_id          IN            NUMBER
  , p_serial_number            IN            VARCHAR2
  , p_initialization_date      IN            DATE
  , p_completion_date          IN            DATE
  , p_ship_date                IN            DATE
  , p_revision                 IN            VARCHAR2
  , p_lot_number               IN            VARCHAR2
  , p_current_locator_id       IN            NUMBER
  , p_subinventory_code        IN            VARCHAR2
  , p_trx_src_id               IN            NUMBER
  , p_unit_vendor_id           IN            NUMBER
  , p_vendor_lot_number        IN            VARCHAR2
  , p_vendor_serial_number     IN            VARCHAR2
  , p_receipt_issue_type       IN            NUMBER
  , p_txn_src_id               IN            NUMBER
  , p_txn_src_name             IN            VARCHAR2
  , p_txn_src_type_id          IN            NUMBER
  , p_current_status           IN            NUMBER
  , p_parent_item_id           IN            NUMBER
  , p_parent_serial_number     IN            VARCHAR2
  , p_serial_temp_id           IN            NUMBER
  , p_last_status              IN            NUMBER
  , p_status_id                IN            NUMBER
  , x_object_id                OUT NOCOPY    NUMBER
  , x_return_status            OUT NOCOPY    VARCHAR2
  , x_msg_count                OUT NOCOPY    NUMBER
  , x_msg_data                 OUT NOCOPY    VARCHAR2
  , p_organization_type        IN            NUMBER DEFAULT NULL
  , p_owning_org_id            IN            NUMBER DEFAULT NULL
  , p_owning_tp_type           IN            NUMBER DEFAULT NULL
  , p_planning_org_id          IN            NUMBER DEFAULT NULL
  , p_planning_tp_type         IN            NUMBER DEFAULT NULL
  , p_transaction_action_id    IN            NUMBER DEFAULT NULL
  , p_wip_entity_id            IN            NUMBER DEFAULT NULL
  , p_operation_seq_num        IN            NUMBER DEFAULT NULL
  , p_intraoperation_step_type IN            NUMBER DEFAULT NULL
  , p_line_mark_id             IN            NUMBER DEFAULT NULL
  );


/*#
 * Use this procedure to create Transactions of serialized units.
 * @param p_api_version API version is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_init_msg_list fnd_api.g_false or fnd_api.g_true is passed as input in this variable to determine whether to Initialize message list or not
 * @paraminfo {@rep:required}
 * @param p_commit fnd_api.g_false or fnd_api.g_true is passed as input in this variable to determine whether to commit or not
 * @paraminfo {@rep:required}
 * @param p_validation_level Validation level is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_inventory_item_id Inventory Item id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_organization_id Organization id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_serial_number Serial Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_current_locator_id Current Locator id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_subinventory_code Current Subinventry Code is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_transaction_date Transaction date is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_txn_src_id Transaction Source id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_txn_src_name Transaction source Name is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_txn_src_type_id Transaction Source type id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_transaction_id Transaction id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_transaction_action_id Transaction action id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_transaction_temp_id Transaction Temp id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_receipt_issue_type Transaction Type is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_customer_id Customer id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_ship_id Ship code is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_status_id Status id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param x_return_status Return Status indiacation success or failure.
 * @paraminfo {@rep:required}
 * @param x_msg_count message count from the error stack in case of failure
 * @paraminfo {@rep:required}
 * @param x_msg_data x_msg_data Return the error message in case of failure
 * @paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Insert Unit Transactions
 */
  PROCEDURE insertunittrx(
    p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 := fnd_api.g_false
  , p_commit                IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level      IN            NUMBER := fnd_api.g_valid_level_full
  , p_inventory_item_id     IN            NUMBER
  , p_organization_id       IN            NUMBER
  , p_serial_number         IN            VARCHAR2
  , p_current_locator_id    IN            NUMBER
  , p_subinventory_code     IN            VARCHAR2
  , p_transaction_date      IN            DATE
  , p_txn_src_id            IN            NUMBER
  , p_txn_src_name          IN            VARCHAR2
  , p_txn_src_type_id       IN            NUMBER
  , p_transaction_id        IN            NUMBER
  , p_transaction_action_id IN            NUMBER
  , p_transaction_temp_id   IN            NUMBER
  , p_receipt_issue_type    IN            NUMBER
  , p_customer_id           IN            NUMBER
  , p_ship_id               IN            NUMBER
  , p_status_id             IN            NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  );

  --
  --     Name: GENERATE_SERIALS (Concurrent Program )
  --
  --     Input parameters:
  --       p_org_id             Organization ID
  --       p_item_id            Item ID
  --       p_qty                Count of Serial Numbers
  --       p_wip_id             Wip Entity ID
  --       p_rev                Revision
  --       p_lot                Lot Number
  --
  --      Output parameters:
  --       x_retcode
  --       x_errbuf
  --
  --      Functions: This API generates a batch of Serial Numbers
  --      in MTL_SERIAL_NUMBERS and sets their status as
  --       'DEFINED_BUT_NOT_USED'. Before inserting into the table
  --      it ensures that there is no clash with existing Serial Numbers
  --      as per the configured Serial-Number-Uniqueness attribute.
  --      Note: This API works in an autonomous transaction.
  --      Note: This API is called by the Serial-Generation concurrent program
  --

    /*#
 * Use this procedure to generate a range of Serial Numbers.
 * All these Serial Numbers will have the status 'DEFINED_BUT_NOT_USED'.
 * It makes sure that there is no clash with the existing Serial Numbers
 * according to the Serial-Number-Uniqueness attribute.
 * It works in an autonomous transaction, and is called by
 * the Serial-Generation concurrent program.
 * @param x_retcode Return status indicating success or failure
 * @paraminfo {@rep:required}
 * @param x_errbuf Return the error message in case of failure
 * @paraminfo {@rep:required}
 * @param p_org_id Organization Id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_item_id Inventory Item id passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_qty Quantity passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_serial_code Serial contol code is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_wip_id Wip entity id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_rev Revision is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_lot Lot Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_group_mark_id Group identifier is passed as input in this variable
 * @param p_line_mark_id Line identifier is passed as input in this variable
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generate Serial Numbers
 */
  PROCEDURE generate_serials(
    x_retcode       OUT NOCOPY    VARCHAR2
  , x_errbuf        OUT NOCOPY    VARCHAR2
  , p_org_id        IN            NUMBER
  , p_item_id       IN            NUMBER
  , p_qty           IN            NUMBER
  , p_serial_code   IN            VARCHAR2
  , p_wip_id        IN            NUMBER
  , p_rev           IN            NUMBER
  , p_lot           IN            NUMBER
  , p_group_mark_id IN            NUMBER DEFAULT NULL
  , p_line_mark_id  IN            NUMBER DEFAULT NULL
  );

  --
  --     Name: GENERATE_SERIALS
  --
  --     Input parameters:
  --       p_org_id             Organization ID
  --       p_item_id            Item ID
  --       p_qty                Count of Serial Numbers
  --       p_wip_id             Wip Entity ID
  --       p_rev                Revision
  --       p_lot                Lot Number
  --
  --      Output parameters:
  --       x_start_serial      Starting Serial Number
  --       x_end_serial        Ending Serial Number
  --       x_proc_msg          Message from the Process-Manager
  --       return_status       0 on Success, 1 on Error
  --
  --      Functions: This API generates a batch of Serial Numbers
  --      in MTL_SERIAL_NUMBERS and sets their status as
  --       'DEFINED_BUT_NOT_USED'. Before inserting into the table
  --      it ensures that there is no clash with existing Serial Numbers
  --      as per the configured Serial-Number-Uniqueness attribute.
  --      Note: This API works in an autonomous transaction
  --
    /*#
 * Use this function to generate a range of Serial Numbers
 * @param p_org_id Organization Id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_item_id Inventory Item id passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_qty Quantity passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_wip_id Wip entity id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_rev Revision is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_lot Lot Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_group_mark_id Group identifier is passed as input in this variable
 * @param p_line_mark_id Line identifier is passed as input in this variable
 * @param x_start_ser Return Start serial
 * @paraminfo {@rep:required}
 * @param x_end_ser Return End serial
 * @paraminfo {@rep:required}
 * @param x_proc_msg Return Message from the Process-Manager
 * @paraminfo {@rep:required}
 * @param p_skip_serial Serial number to be excluded is passed as input in this variable
 * @paraminfo {@rep:required}
 * @return status indicating success or failure
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generate Serial Numbers
 */
  FUNCTION generate_serials(
    p_org_id        IN            NUMBER
  , p_item_id       IN            NUMBER
  , p_qty           IN            NUMBER
  , p_wip_id        IN            NUMBER
  , p_rev           IN            VARCHAR2
  , p_lot           IN            VARCHAR2
  , p_group_mark_id IN            NUMBER DEFAULT NULL
  , p_line_mark_id  IN            NUMBER DEFAULT NULL
  , x_start_ser     OUT NOCOPY    VARCHAR2
  , x_end_ser       OUT NOCOPY    VARCHAR2
  , x_proc_msg      OUT NOCOPY    VARCHAR2
  , p_skip_serial   IN            NUMBER DEFAULT NULL
  )
    RETURN NUMBER;

  --
  --     Name: IS_SERIAL_UNIQUE
  --
  --     Input parameters:
  --       p_org_id             Organization ID
  --       p_item_id            Item ID
  --       p_serial             Serial Number
  --
  --      Output parameters:
  --       x_proc_msg          Message from the Process-Manager
  --       return_status       0 on Success, 1 on Error
  --
  --      Functions: This API checks wheather a Serial Number
  --       can be entered into MTL_SERIAL_NUMBER after considering the
  --       SERIAL_NUMBER_TYPE of MTL_PARAMETERS. This attribute  can
  --       have the following values :
  --        1 - Unique serial numbers within inventory item
  --        2 - Unique serial numbers within organization.
  --        3 - Unique serial numbers across organizations.
  --
  --
    /*#
 * Use this function to check whether a Serial number is unique or not
 * @param p_org_id Organization Id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_item_id Inventory Item id passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_serial Serial Number passed as input in this variable
 * @paraminfo {@rep:required}
 * @param x_proc_msg Return Message from the Process-Manager
 * @paraminfo {@rep:required}
 * @return Status indicating success or failure
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Is Serial Unique
 */
  FUNCTION is_serial_unique(p_org_id IN NUMBER, p_item_id IN NUMBER, p_serial IN VARCHAR2, x_proc_msg OUT NOCOPY VARCHAR2)
    RETURN NUMBER;

  --
  --     Name: GET_SERIAL_DIFF
  --
  --     Input parameters:
  --       p_fm_serial          'from' Serial Number
  --       p_to_serial          'to'   Serial Number
  --
  --      Output parameters:
  --       return_status       quantity between passed serial numbers
  --
  --      Functions: This API returns the numeric difference between the
  --      fromSerNum and toSerNum by first seperating the numeric part
  --      from the strings and getting its difference
  --       * Note:  - string-prefix part of both the numbers should match
  --       *        - numeric part lengths should match
  --       *        - difference should be greater than 0
  --
  --
    /*#
 * Use this function to get the quantity of units between two Serial Numbers.
 * @param p_fm_serial From Serial Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_to_serial To Serial Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @return The quantity between two Serial Numbers
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Serial Difference
 */
  FUNCTION get_serial_diff(p_fm_serial IN VARCHAR2, p_to_serial IN VARCHAR2)
    RETURN NUMBER;

  --
  --     Name: VALIDATE_SERIALS
  --
  --     Input parameters:
  --       p_org_id             Organization ID
  --       p_item_id            Item ID
  --       p_wip_id             Wip Entity ID
  --       p_rev                Revision
  --       p_lot                Lot Number
  --       p_locator_id         Locator Id
  --       p_subinventory_code  SubInv Code
  --       p_issue_receipt      Issue/Receipt Flag
  --     IN/OUT parameters:
  --       p_qty               Quantity/Count of Serial Numbers
  --       x_end_ser           End Serial Number
  --      Output parameters:
  --       x_proc_msg          Error Message
  --
  --      Functions: This API Validate a batch of Serial Numbers
  --      and if the serial number is new then insert the
  --      serial number in MTL_SERIAL_NUMBERS and sets their status
  --      appropriate to the transaction. Before inserting into the table
  --      it ensures that there is no clash with existing Serial Numbers
  --      as per the configured Serial-Number-Uniqueness attribute.
  --
  -- Bug 3194093 added two more parameters to validate_serials()
  -- p_rcv_validate,p_rcv_shipment_line_id to support serial
  -- validation for intransit receipt transactions
  -- applicable for Inter-org,Internal sales order Intransit txns
  -- Bug 3384652 Changing the param name p_rcv_shipment_line_id to
  -- p_rcv_source_line_id.And the value passed to this is either
  -- shipment_line_id or ram_line_id depending on the transaction
  -- Source type and action. To support serial validation for RMA

  -- Bug 7541512, added p_rcv_parent_txn_id to validate serial number of return to vendor transactions.

  /*#
 * Use this function to validate a batch of Serial Numbers
 * and, if the serial numbers are new, to insert the
 * serial number in MTL_SERIAL_NUMBERS and to set the status
 * appropriate to the transaction. Before inserting into the table
 * it ensures that there is no clash with existing Serial Numbers
 * according to the configured Serial-Number-Uniqueness attribute.
 * @param p_org_id Organization Id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_item_id Inventory Item id passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_qty Quantity passed as input in this variable and Return the valid quantity
 * @paraminfo {@rep:required}
 * @param p_rev Revision is passed as input in this variable
 * @param p_lot Lot Number is passed as input in this variable
 * @param p_start_ser Start Serial Number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_trx_src_id Transaction Source Type id is passed as input in this variable
 * @param p_trx_action_id Transaction Action id is passed as input in this variable
 * @param p_subinventory_code Subinventory code is passed as input in this variable
 * @param p_locator_id Locator id is passed as input in this variable
 * @param p_wip_entity_id Wip entity id is passed as input in this variable
 * @param p_group_mark_id Group identifier is passed as input in this variable
 * @param p_line_mark_id Line identifier is passed as input in this variable
 * @param p_issue_receipt Issue or Receipt code is passed as input in this variable
 * @param x_end_ser End Serial Number is passed as input in this variable and returns the valid End Serial Number
 * @paraminfo {@rep:required}
 * @param x_proc_msg Return Message from the Process-Manager
 * @paraminfo {@rep:required}
 * @param p_check_for_grp_mark_id The flag that determines whether to check for group mark id is passed as input in this variable
 * @param p_rcv_validate The flag that determines whether the Serial Number should be validated or not is passed as input in this variable
 * @param p_rcv_source_line_id Source Line id is passed as input in this variable
 * @return Return status indicating success or failure
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Serials
 */

 /* Bug 6898933  Added parameter p_transaction_type_id in below procedure */

  FUNCTION validate_serials(
    p_org_id                IN            NUMBER
  , p_item_id               IN            NUMBER
  , p_qty                   IN OUT NOCOPY NUMBER
  , p_rev                   IN            VARCHAR2 DEFAULT NULL
  , p_lot                   IN            VARCHAR2 DEFAULT NULL
  , p_start_ser             IN            VARCHAR2
  , p_trx_src_id            IN            NUMBER DEFAULT NULL
  , p_trx_action_id         IN            NUMBER DEFAULT NULL
  , p_subinventory_code     IN            VARCHAR2 DEFAULT NULL
  , p_locator_id            IN            NUMBER DEFAULT NULL
  , p_wip_entity_id         IN            NUMBER DEFAULT NULL
  , p_group_mark_id         IN            NUMBER DEFAULT NULL
  , p_line_mark_id          IN            NUMBER DEFAULT NULL
  , p_issue_receipt         IN            VARCHAR2 DEFAULT NULL
  , x_end_ser               IN OUT NOCOPY VARCHAR2
  , x_proc_msg              OUT NOCOPY    VARCHAR2
  , p_check_for_grp_mark_id IN            VARCHAR2 DEFAULT 'N'
  , p_rcv_validate          IN            VARCHAR2 DEFAULT 'N'
  , p_rcv_source_line_id    IN            NUMBER   DEFAULT -1
  , p_xfr_org_id            IN            NUMBER DEFAULT -1  -- Bug#4153297
  , p_rcv_parent_txn_id     IN            NUMBER DEFAULT -1
  , p_transaction_type_id   IN            NUMBER DEFAULT 0
  )   --Bug# 2656316
    RETURN NUMBER;

  /*#
 * Use this function to get the next Serial Number using the current Serial
 * Number and Increment Value.
 * @param p_curr_serial Current Serial number is passed as input in this variable
 * @param p_inc_value Increment value is passed as input in this variable
 * @return Returns next Serial Number
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Increment Serial Number
 */
  FUNCTION increment_ser_num(p_curr_serial VARCHAR2, p_inc_value NUMBER)
    RETURN VARCHAR2;

--Description
--Procedure for validating and updating serial attributes.
  /*#
 * Use this procedure to validate and update serial attributes.
 * @param x_return_status Return status indicating success or failure
 * @paraminfo {@rep:required}
 * @param x_msg_count Return message count from the error stack in case of failure
 * @paraminfo {@rep:required}
 * @param x_msg_data Return the error message in case of failure
 * @paraminfo {@rep:required}
 * @param x_validation_status Return the validation status
 * @paraminfo {@rep:required}
 * @param p_serial_number Serial number is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_organization_id Organization Id is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_inventory_item_id Inventory Item id passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_serial_att_tbl Serial Attributes table is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_validate_only TRUE is passed as input in this variable if only validation is required
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate and Update Serial Attributes
 */
PROCEDURE validate_update_serial_att
  (x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   x_validation_status     OUT NOCOPY VARCHAR2,
   p_serial_number         IN  VARCHAR2,
   p_organization_id       IN  NUMBER,
   p_inventory_item_id     IN  NUMBER,
   p_serial_att_tbl    IN
   inv_lot_sel_attr.lot_sel_attributes_tbl_type,
   p_validate_only         IN  BOOLEAN DEFAULT FALSE
   );

FUNCTION SNGetMask(P_txn_act_id          IN      NUMBER,
                   P_txn_src_type_id     IN      NUMBER,
                   P_serial_control      IN      NUMBER,
                   x_to_status           OUT NOCOPY     NUMBER,
                   x_dynamic_ok          OUT NOCOPY    NUMBER,
                   P_receipt_issue_flag  IN      VARCHAR2,
                   x_mask                OUT NOCOPY    VARCHAR2,
                   x_errorcode           OUT NOCOPY    NUMBER)
                   RETURN BOOLEAN;

PROCEDURE update_msn
 (x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
   p_trxdate              IN    DATE,
   p_transaction_temp_id  IN    NUMBER,
   p_rev                  IN    VARCHAR2,
   p_lotnum               IN    VARCHAR2,
   p_orgid                IN    NUMBER,
   p_locid                IN    NUMBER, -- :lii,
   p_subinv               IN    VARCHAR2,
   p_trxsrctypid          IN    NUMBER,
   p_trxsrcid             IN    NUMBER,
   p_trx_act_id           IN    NUMBER,
   p_vendid               IN    NUMBER, -- :i_vendor_idi,
   p_venlot               IN    VARCHAR2,
   p_receipt_issue_type   IN    NUMBER,
   p_trxsname             IN    VARCHAR2,
   p_lstupdby             IN    NUMBER,
   p_parent_item_id       IN    NUMBER, -- :parent_item_i,
   p_parent_ser_num       IN    VARCHAR2, -- :parent_sn_i,
   p_ser_ctrl_code        IN    NUMBER,
   p_xfr_ser_ctrl_code    IN    NUMBER,
   p_trx_qty              IN    NUMBER,
   p_invitemid            IN    NUMBER,
   p_f_ser_num            IN    VARCHAR2,
   p_t_ser_num            IN    VARCHAR2,
   x_serial_updated       OUT NOCOPY NUMBER
);

FUNCTION getGroupId(
   p_trx_source_type_id      IN number,
   p_trx_action_id           IN number) RETURN NUMBER;

FUNCTION validate_status(
   p_trx_src_type_id         IN NUMBER,
   p_trx_action_id           IN NUMBER,
   p_isIssue                 IN BOOLEAN,
   p_ser_num_ctrl_code       IN NUMBER,
   p_curr_status             IN NUMBER,
   p_last_trx_src_type_id    IN NUMBER,
   p_xfr_ser_num_ctrl_code   IN NUMBER,
   p_isRestrictRcptSerial    IN NUMBER
) return number;

FUNCTION valsn(
   p_trx_src_type_id              IN   NUMBER,
   p_trx_action_id                IN   NUMBER,
   p_revision                     IN   VARCHAR2,
   p_curr_subinv_code             IN   VARCHAR2,
   p_locator_id                   IN   NUMBER,
   p_item                         IN   NUMBER,
   p_curr_org_id                  IN   NUMBER,
   p_lot                          IN   VARCHAR2,
   p_curr_ser_num                 IN   VARCHAR2,
   p_ser_num_ctrl_code            IN   NUMBER,
   p_xfr_ser_num_ctrl_code        IN   NUMBER,
   p_trx_qty                      IN   NUMBER,
   p_acct_prof_value              IN   VARCHAR2,
   p_mask                         IN   VARCHAR2,
   p_db_current_status            IN   NUMBER,
   p_db_current_organization_id   IN   NUMBER,
   p_db_revision                  IN   VARCHAR2,
   p_db_lot_number                IN   VARCHAR2,
   p_db_current_subinventory_code IN   VARCHAR2,
   p_db_current_locator_id        IN   NUMBER,
   p_db_wip_ent_id_ind            IN   NUMBER,
   p_db_lst_txn_src_type_id        IN   NUMBER
) RETURN NUMBER DETERMINISTIC;
--pragma restrict_references(valsn,  WNDS, WNPS, RNDS, RNPS);

PROCEDURE insertRangeUnitTrx(
            p_api_version               IN  NUMBER,
            p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
            p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
            p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
            p_inventory_item_id         IN NUMBER,
            p_organization_id           IN NUMBER,
            p_fm_serial_number          IN VARCHAR2,
            p_to_serial_number          IN VARCHAR2,
            p_current_locator_id        IN NUMBER,
            p_subinventory_code         IN VARCHAR2,
            p_transaction_date          IN DATE,
            p_txn_src_id                IN NUMBER,
            p_txn_src_name              IN VARCHAR2,
            p_txn_src_type_id           IN NUMBER,
            p_transaction_id            IN NUMBER,
            p_transaction_action_id     IN NUMBER,
            p_transaction_temp_id       IN NUMBER,
            p_receipt_issue_type        IN NUMBER,
            p_customer_id               IN NUMBER,
            p_ship_id                   IN NUMBER,
            p_status_id                 IN NUMBER,
            x_return_status             OUT NOCOPY VARCHAR2,
            x_msg_count                 OUT NOCOPY NUMBER,
            x_msg_data                  OUT NOCOPY VARCHAR2);

--serial tagging
PROCEDURE is_serial_controlled(
            p_inventory_item_id         IN NUMBER,
            p_organization_id           IN NUMBER,
            p_transfer_org_id           IN NUMBER DEFAULT NULL,
            p_txn_type_id               IN NUMBER DEFAULT NULL,
            p_txn_src_type_id           IN NUMBER DEFAULT NULL,
            p_txn_action_id             IN NUMBER DEFAULT NULL,
            p_serial_control            IN NUMBER DEFAULT NULL,
            p_xfer_serial_control       IN NUMBER DEFAULT NULL,
            x_serial_control            OUT NOCOPY NUMBER,
            x_return_status             OUT NOCOPY VARCHAR2);

--serial tagging
FUNCTION is_serial_tagged(
            p_inventory_item_id         IN NUMBER,
            p_organization_id           IN NUMBER
) RETURN NUMBER;

FUNCTION is_serial_tagged(
            p_inventory_item_id         IN NUMBER DEFAULT NULL,
            p_organization_id           IN NUMBER DEFAULT NULL,
            p_template_id               IN NUMBER
) RETURN NUMBER;

PROCEDURE copy_serial_tag_assignments(
            p_from_org_id               IN NUMBER DEFAULT NULL,
            p_from_item_id              IN NUMBER DEFAULT NULL,
            p_from_template_id          IN NUMBER DEFAULT NULL,
            p_to_org_id                 IN NUMBER DEFAULT NULL,
            p_to_item_id                IN NUMBER DEFAULT NULL,
            p_to_template_id            IN NUMBER DEFAULT NULL,
            x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE delete_serial_tag_assignments(
            p_inventory_item_id         IN NUMBER,
            p_organization_id           IN NUMBER,
            x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE delete_serial_tag_assignments(
            p_inventory_item_id         IN NUMBER DEFAULT NULL,
            p_organization_id           IN NUMBER DEFAULT NULL,
            p_template_id               IN NUMBER,
            x_return_status             OUT NOCOPY VARCHAR2);

END inv_serial_number_pub;

/
