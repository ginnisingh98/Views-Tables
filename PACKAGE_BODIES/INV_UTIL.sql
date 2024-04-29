--------------------------------------------------------
--  DDL for Package Body INV_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_UTIL" AS
/* $Header: INVINUTB.pls 115.6 2002/12/31 20:43:02 lplam ship $ */
   g_pkg_name                     VARCHAR2(100) := 'inv_util';

PROCEDURE insert_mmtt(p_api_version	 IN  NUMBER,
		      p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                      p_commit	  	 IN  VARCHAR2 := FND_API.G_FALSE,
                      p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
		      p_mmtt_rec         IN  mtl_material_transactions_temp%ROWTYPE,
                      x_trx_header_id	 OUT NOCOPY NUMBER,
		      x_trx_temp_id      OUT NOCOPY NUMBER,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count	 OUT NOCOPY NUMBER,
		      x_msg_data	 OUT NOCOPY VARCHAR2)
IS
   l_api_version	CONSTANT NUMBER := 1.0;
   l_api_name		CONSTANT VARCHAR2(30):= g_pkg_name||'.insert_mmtt';
   l_trx_type_id 	NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   x_trx_header_id := NULL;
   x_trx_temp_id   := NULL;

   IF (l_debug = 1) THEN
      inv_log_util.trace('Begin insert_mmtt: action_id: ' || p_mmtt_rec.transaction_action_id, g_pkg_name, 9);
   END IF;

   -- Standard Start of API savepoint
   SAVEPOINT sp_insert_mmtt;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
   END IF;


   -- validate the transaction_type_id, transaction_action_id and transaction_source_type_id
   SELECT transaction_type_id
   INTO l_trx_type_id
   FROM mtl_transaction_types
   WHERE transaction_type_id = p_mmtt_rec.TRANSACTION_TYPE_ID
   and transaction_action_id = p_mmtt_rec.TRANSACTION_ACTION_ID
   and transaction_source_type_id = p_mmtt_rec.TRANSACTION_SOURCE_TYPE_ID;

   -- get the transaction_header_id
   SELECT mtl_material_transactions_s.NEXTVAL
   INTO x_trx_header_id
   FROM DUAL;

   -- get the transaction_temp_id
   SELECT mtl_material_transactions_s.NEXTVAL
   INTO x_trx_temp_id
   FROM DUAL;

   INSERT INTO mtl_material_transactions_temp
	(TRANSACTION_HEADER_ID
	 ,TRANSACTION_TEMP_ID
	 ,SOURCE_CODE
	 ,SOURCE_LINE_ID
	 ,TRANSACTION_MODE
	 ,LOCK_FLAG
	 ,LAST_UPDATE_DATE
 	 ,LAST_UPDATED_BY
	 ,CREATION_DATE
	 ,CREATED_BY
	 ,LAST_UPDATE_LOGIN
	 ,REQUEST_ID
	 ,PROGRAM_APPLICATION_ID
	 ,PROGRAM_ID
	 ,PROGRAM_UPDATE_DATE
	 ,INVENTORY_ITEM_ID
	 ,REVISION
	 ,ORGANIZATION_ID
         ,SUBINVENTORY_CODE
	 ,LOCATOR_ID
	 ,TRANSACTION_QUANTITY
	 ,PRIMARY_QUANTITY
	 ,TRANSACTION_UOM
	 ,TRANSACTION_COST
	 ,TRANSACTION_TYPE_ID
	 ,TRANSACTION_ACTION_ID
	 ,TRANSACTION_SOURCE_TYPE_ID
	 ,TRANSACTION_SOURCE_ID
	 ,TRANSACTION_SOURCE_NAME
	 ,TRANSACTION_DATE
	 ,ACCT_PERIOD_ID
	 ,DISTRIBUTION_ACCOUNT_ID
	 ,TRANSACTION_REFERENCE
	 ,REQUISITION_LINE_ID
	 ,REQUISITION_DISTRIBUTION_ID
	 ,REASON_ID
	 ,LOT_NUMBER
         ,LOT_EXPIRATION_DATE
         ,SERIAL_NUMBER
         ,RECEIVING_DOCUMENT
         ,DEMAND_ID
         ,RCV_TRANSACTION_ID
         ,MOVE_TRANSACTION_ID
         ,COMPLETION_TRANSACTION_ID
         ,WIP_ENTITY_TYPE
         ,SCHEDULE_ID
         ,REPETITIVE_LINE_ID
         ,EMPLOYEE_CODE
         ,PRIMARY_SWITCH
         ,SCHEDULE_UPDATE_CODE
         ,SETUP_TEARDOWN_CODE
         ,ITEM_ORDERING
         ,NEGATIVE_REQ_FLAG
         ,OPERATION_SEQ_NUM
	 ,PICKING_LINE_ID
         ,TRX_SOURCE_LINE_ID
         ,TRX_SOURCE_DELIVERY_ID
	 ,PHYSICAL_ADJUSTMENT_ID
	 ,CYCLE_COUNT_ID
	 ,RMA_LINE_ID
	 ,CUSTOMER_SHIP_ID
	 ,CURRENCY_CODE
	 ,CURRENCY_CONVERSION_RATE
	 ,CURRENCY_CONVERSION_TYPE
	 ,CURRENCY_CONVERSION_DATE
	 ,USSGL_TRANSACTION_CODE
	 ,VENDOR_LOT_NUMBER
	 ,ENCUMBRANCE_ACCOUNT
	 ,ENCUMBRANCE_AMOUNT
	 ,SHIP_TO_LOCATION
	 ,SHIPMENT_NUMBER
	 ,TRANSFER_COST
	 ,TRANSPORTATION_COST
	 ,TRANSPORTATION_ACCOUNT
	 ,FREIGHT_CODE
	 ,CONTAINERS
	 ,WAYBILL_AIRBILL
	 ,EXPECTED_ARRIVAL_DATE
	 ,TRANSFER_SUBINVENTORY
         ,TRANSFER_ORGANIZATION
	 ,TRANSFER_TO_LOCATION
	 ,NEW_AVERAGE_COST
	 ,VALUE_CHANGE
	 ,PERCENTAGE_CHANGE
	 ,MATERIAL_ALLOCATION_TEMP_ID
	 ,DEMAND_SOURCE_HEADER_ID
	 ,DEMAND_SOURCE_LINE
	 ,DEMAND_SOURCE_DELIVERY
         ,ITEM_SEGMENTS
	 ,ITEM_DESCRIPTION
	 ,ITEM_TRX_ENABLED_FLAG
	 ,ITEM_LOCATION_CONTROL_CODE
	 ,ITEM_RESTRICT_SUBINV_CODE
	 ,ITEM_RESTRICT_LOCATORS_CODE
	 ,ITEM_REVISION_QTY_CONTROL_CODE
	 ,ITEM_PRIMARY_UOM_CODE
	 ,ITEM_UOM_CLASS
	 ,ITEM_SHELF_LIFE_CODE
	 ,ITEM_SHELF_LIFE_DAYS
	 ,ITEM_LOT_CONTROL_CODE
         ,ITEM_SERIAL_CONTROL_CODE
         ,ITEM_INVENTORY_ASSET_FLAG
	 ,ALLOWED_UNITS_LOOKUP_CODE
	 ,DEPARTMENT_ID
	 ,DEPARTMENT_CODE
	 ,WIP_SUPPLY_TYPE
	 ,SUPPLY_SUBINVENTORY
	 ,SUPPLY_LOCATOR_ID
	 ,VALID_SUBINVENTORY_FLAG
	 ,VALID_LOCATOR_FLAG
	 ,LOCATOR_SEGMENTS
	 ,CURRENT_LOCATOR_CONTROL_CODE
	 ,NUMBER_OF_LOTS_ENTERED
	 ,WIP_COMMIT_FLAG
	 ,NEXT_LOT_NUMBER
	 ,LOT_ALPHA_PREFIX
	 ,NEXT_SERIAL_NUMBER
	 ,SERIAL_ALPHA_PREFIX
	 ,SHIPPABLE_FLAG
	 ,POSTING_FLAG
	 ,REQUIRED_FLAG
	 ,PROCESS_FLAG
 	 ,ERROR_CODE
	 ,ERROR_EXPLANATION
	 ,ATTRIBUTE_CATEGORY
	 ,ATTRIBUTE1
         ,ATTRIBUTE2
         ,ATTRIBUTE3
         ,ATTRIBUTE4
         ,ATTRIBUTE5
         ,ATTRIBUTE6
         ,ATTRIBUTE7
         ,ATTRIBUTE8
         ,ATTRIBUTE9
         ,ATTRIBUTE10
         ,ATTRIBUTE11
         ,ATTRIBUTE12
         ,ATTRIBUTE13
         ,ATTRIBUTE14
         ,ATTRIBUTE15
         ,MOVEMENT_ID
         ,RESERVATION_QUANTITY
         ,SHIPPED_QUANTITY
         ,TRANSACTION_LINE_NUMBER
         ,TASK_ID
         ,TO_TASK_ID
         ,SOURCE_TASK_ID
         ,PROJECT_ID
         ,SOURCE_PROJECT_ID
         ,PA_EXPENDITURE_ORG_ID
         ,TO_PROJECT_ID
         ,EXPENDITURE_TYPE
         ,FINAL_COMPLETION_FLAG
         ,TRANSFER_PERCENTAGE
         ,TRANSACTION_SEQUENCE_ID
         ,MATERIAL_ACCOUNT
         ,MATERIAL_OVERHEAD_ACCOUNT
         ,RESOURCE_ACCOUNT
         ,OUTSIDE_PROCESSING_ACCOUNT
         ,OVERHEAD_ACCOUNT
         ,FLOW_SCHEDULE
         ,COST_GROUP_ID
         ,TRANSFER_COST_GROUP_ID
         ,DEMAND_CLASS
         ,QA_COLLECTION_ID
         ,KANBAN_CARD_ID
         ,OVERCOMPLETION_TRANSACTION_QTY
         ,OVERCOMPLETION_PRIMARY_QTY
         ,OVERCOMPLETION_TRANSACTION_ID
         ,END_ITEM_UNIT_NUMBER
         ,SCHEDULED_PAYBACK_DATE
         ,LINE_TYPE_CODE
         ,PARENT_TRANSACTION_TEMP_ID
         ,PUT_AWAY_STRATEGY_ID
         ,PUT_AWAY_RULE_ID
         ,PICK_STRATEGY_ID
         ,PICK_RULE_ID
         ,MOVE_ORDER_LINE_ID
         ,TASK_GROUP_ID
         ,PICK_SLIP_NUMBER
         ,RESERVATION_ID
         ,COMMON_BOM_SEQ_ID
         ,COMMON_ROUTING_SEQ_ID
         ,ORG_COST_GROUP_ID
         ,COST_TYPE_ID
         ,TRANSACTION_STATUS
         ,STANDARD_OPERATION_ID
         ,TASK_PRIORITY
         ,WMS_TASK_TYPE
         ,PARENT_LINE_ID
         ,LPN_ID
         ,TRANSFER_LPN_ID
         ,WMS_TASK_STATUS
         ,CONTENT_LPN_ID
         ,CONTAINER_ITEM_ID
         ,CARTONIZATION_ID
         ,PICK_SLIP_DATE
         ,REBUILD_ITEM_ID
	 ,REBUILD_SERIAL_NUMBER
	 ,REBUILD_ACTIVITY_ID
	 ,REBUILD_JOB_NAME
	 ,ORGANIZATION_TYPE
	 ,TRANSFER_ORGANIZATION_TYPE
	 ,OWNING_ORGANIZATION_ID
	 ,OWNING_TP_TYPE
	 ,XFR_OWNING_ORGANIZATION_ID
	 ,TRANSFER_OWNING_TP_TYPE
	 ,PLANNING_ORGANIZATION_ID
	 ,PLANNING_TP_TYPE
	 ,XFR_PLANNING_ORGANIZATION_ID
	 ,TRANSFER_PLANNING_TP_TYPE
	 ,SECONDARY_UOM_CODE
	 ,SECONDARY_TRANSACTION_QUANTITY
	 ,TRANSACTION_BATCH_ID
	 ,TRANSACTION_BATCH_SEQ)
    VALUES (
          x_trx_header_id
         ,x_trx_temp_id
         ,p_mmtt_rec.SOURCE_CODE
         ,p_mmtt_rec.SOURCE_LINE_ID
         ,p_mmtt_rec.TRANSACTION_MODE
         ,p_mmtt_rec.LOCK_FLAG
         ,p_mmtt_rec.LAST_UPDATE_DATE
         ,p_mmtt_rec.LAST_UPDATED_BY
         ,p_mmtt_rec.CREATION_DATE
         ,p_mmtt_rec.CREATED_BY
         ,p_mmtt_rec.LAST_UPDATE_LOGIN
         ,p_mmtt_rec.REQUEST_ID
         ,p_mmtt_rec.PROGRAM_APPLICATION_ID
         ,p_mmtt_rec.PROGRAM_ID
         ,p_mmtt_rec.PROGRAM_UPDATE_DATE
         ,p_mmtt_rec.INVENTORY_ITEM_ID
         ,p_mmtt_rec.REVISION
         ,p_mmtt_rec.ORGANIZATION_ID
         ,p_mmtt_rec.SUBINVENTORY_CODE
         ,p_mmtt_rec.LOCATOR_ID
	 ,p_mmtt_rec.TRANSACTION_QUANTITY
	 ,p_mmtt_rec.PRIMARY_QUANTITY
	 ,p_mmtt_rec.TRANSACTION_UOM
         ,p_mmtt_rec.TRANSACTION_COST
         ,p_mmtt_rec.TRANSACTION_TYPE_ID
         ,p_mmtt_rec.TRANSACTION_ACTION_ID
         ,p_mmtt_rec.TRANSACTION_SOURCE_TYPE_ID
         ,p_mmtt_rec.TRANSACTION_SOURCE_ID
         ,p_mmtt_rec.TRANSACTION_SOURCE_NAME
         ,p_mmtt_rec.TRANSACTION_DATE
         ,p_mmtt_rec.ACCT_PERIOD_ID
         ,p_mmtt_rec.DISTRIBUTION_ACCOUNT_ID
         ,p_mmtt_rec.TRANSACTION_REFERENCE
         ,p_mmtt_rec.REQUISITION_LINE_ID
         ,p_mmtt_rec.REQUISITION_DISTRIBUTION_ID
         ,p_mmtt_rec.REASON_ID
         ,p_mmtt_rec.LOT_NUMBER
         ,p_mmtt_rec.LOT_EXPIRATION_DATE
         ,p_mmtt_rec.SERIAL_NUMBER
         ,p_mmtt_rec.RECEIVING_DOCUMENT
         ,p_mmtt_rec.DEMAND_ID
         ,p_mmtt_rec.RCV_TRANSACTION_ID
         ,p_mmtt_rec.MOVE_TRANSACTION_ID
         ,p_mmtt_rec.COMPLETION_TRANSACTION_ID
         ,p_mmtt_rec.WIP_ENTITY_TYPE
         ,p_mmtt_rec.SCHEDULE_ID
         ,p_mmtt_rec.REPETITIVE_LINE_ID
         ,p_mmtt_rec.EMPLOYEE_CODE
         ,p_mmtt_rec.PRIMARY_SWITCH
         ,p_mmtt_rec.SCHEDULE_UPDATE_CODE
         ,p_mmtt_rec.SETUP_TEARDOWN_CODE
         ,p_mmtt_rec.ITEM_ORDERING
         ,p_mmtt_rec.NEGATIVE_REQ_FLAG
         ,p_mmtt_rec.OPERATION_SEQ_NUM
         ,p_mmtt_rec.PICKING_LINE_ID
         ,p_mmtt_rec.TRX_SOURCE_LINE_ID
         ,p_mmtt_rec.TRX_SOURCE_DELIVERY_ID
         ,p_mmtt_rec.PHYSICAL_ADJUSTMENT_ID
         ,p_mmtt_rec.CYCLE_COUNT_ID
         ,p_mmtt_rec.RMA_LINE_ID
         ,p_mmtt_rec.CUSTOMER_SHIP_ID
         ,p_mmtt_rec.CURRENCY_CODE
         ,p_mmtt_rec.CURRENCY_CONVERSION_RATE
         ,p_mmtt_rec.CURRENCY_CONVERSION_TYPE
         ,p_mmtt_rec.CURRENCY_CONVERSION_DATE
         ,p_mmtt_rec.USSGL_TRANSACTION_CODE
         ,p_mmtt_rec.VENDOR_LOT_NUMBER
         ,p_mmtt_rec.ENCUMBRANCE_ACCOUNT
         ,p_mmtt_rec.ENCUMBRANCE_AMOUNT
         ,p_mmtt_rec.SHIP_TO_LOCATION
         ,p_mmtt_rec.SHIPMENT_NUMBER
         ,p_mmtt_rec.TRANSFER_COST
         ,p_mmtt_rec.TRANSPORTATION_COST
         ,p_mmtt_rec.TRANSPORTATION_ACCOUNT
         ,p_mmtt_rec.FREIGHT_CODE
         ,p_mmtt_rec.CONTAINERS
         ,p_mmtt_rec.WAYBILL_AIRBILL
         ,p_mmtt_rec.EXPECTED_ARRIVAL_DATE
         ,p_mmtt_rec.TRANSFER_SUBINVENTORY
         ,p_mmtt_rec.TRANSFER_ORGANIZATION
         ,p_mmtt_rec.TRANSFER_TO_LOCATION
         ,p_mmtt_rec.NEW_AVERAGE_COST
         ,p_mmtt_rec.VALUE_CHANGE
         ,p_mmtt_rec.PERCENTAGE_CHANGE
         ,p_mmtt_rec.MATERIAL_ALLOCATION_TEMP_ID
         ,p_mmtt_rec.DEMAND_SOURCE_HEADER_ID
         ,p_mmtt_rec.DEMAND_SOURCE_LINE
         ,p_mmtt_rec.DEMAND_SOURCE_DELIVERY
         ,p_mmtt_rec.ITEM_SEGMENTS
         ,p_mmtt_rec.ITEM_DESCRIPTION
         ,p_mmtt_rec.ITEM_TRX_ENABLED_FLAG
         ,p_mmtt_rec.ITEM_LOCATION_CONTROL_CODE
         ,p_mmtt_rec.ITEM_RESTRICT_SUBINV_CODE
         ,p_mmtt_rec.ITEM_RESTRICT_LOCATORS_CODE
         ,p_mmtt_rec.ITEM_REVISION_QTY_CONTROL_CODE
         ,p_mmtt_rec.ITEM_PRIMARY_UOM_CODE
         ,p_mmtt_rec.ITEM_UOM_CLASS
         ,p_mmtt_rec.ITEM_SHELF_LIFE_CODE
         ,p_mmtt_rec.ITEM_SHELF_LIFE_DAYS
         ,p_mmtt_rec.ITEM_LOT_CONTROL_CODE
         ,p_mmtt_rec.ITEM_SERIAL_CONTROL_CODE
         ,p_mmtt_rec.ITEM_INVENTORY_ASSET_FLAG
         ,p_mmtt_rec.ALLOWED_UNITS_LOOKUP_CODE
         ,p_mmtt_rec.DEPARTMENT_ID
         ,p_mmtt_rec.DEPARTMENT_CODE
         ,p_mmtt_rec.WIP_SUPPLY_TYPE
         ,p_mmtt_rec.SUPPLY_SUBINVENTORY
         ,p_mmtt_rec.SUPPLY_LOCATOR_ID
         ,p_mmtt_rec.VALID_SUBINVENTORY_FLAG
         ,p_mmtt_rec.VALID_LOCATOR_FLAG
         ,p_mmtt_rec.LOCATOR_SEGMENTS
         ,p_mmtt_rec.CURRENT_LOCATOR_CONTROL_CODE
         ,p_mmtt_rec.NUMBER_OF_LOTS_ENTERED
         ,p_mmtt_rec.WIP_COMMIT_FLAG
         ,p_mmtt_rec.NEXT_LOT_NUMBER
         ,p_mmtt_rec.LOT_ALPHA_PREFIX
         ,p_mmtt_rec.NEXT_SERIAL_NUMBER
         ,p_mmtt_rec.SERIAL_ALPHA_PREFIX
         ,p_mmtt_rec.SHIPPABLE_FLAG
         ,p_mmtt_rec.POSTING_FLAG
         ,p_mmtt_rec.REQUIRED_FLAG
         ,p_mmtt_rec.PROCESS_FLAG
         ,p_mmtt_rec.ERROR_CODE
         ,p_mmtt_rec.ERROR_EXPLANATION
         ,p_mmtt_rec.ATTRIBUTE_CATEGORY
         ,p_mmtt_rec.ATTRIBUTE1
         ,p_mmtt_rec.ATTRIBUTE2
         ,p_mmtt_rec.ATTRIBUTE3
         ,p_mmtt_rec.ATTRIBUTE4
         ,p_mmtt_rec.ATTRIBUTE5
         ,p_mmtt_rec.ATTRIBUTE6
         ,p_mmtt_rec.ATTRIBUTE7
         ,p_mmtt_rec.ATTRIBUTE8
         ,p_mmtt_rec.ATTRIBUTE9
         ,p_mmtt_rec.ATTRIBUTE10
         ,p_mmtt_rec.ATTRIBUTE11
         ,p_mmtt_rec.ATTRIBUTE12
         ,p_mmtt_rec.ATTRIBUTE13
         ,p_mmtt_rec.ATTRIBUTE14
         ,p_mmtt_rec.ATTRIBUTE15
         ,p_mmtt_rec.MOVEMENT_ID
         ,p_mmtt_rec.RESERVATION_QUANTITY
         ,p_mmtt_rec.SHIPPED_QUANTITY
         ,p_mmtt_rec.TRANSACTION_LINE_NUMBER
         ,p_mmtt_rec.TASK_ID
         ,p_mmtt_rec.TO_TASK_ID
         ,p_mmtt_rec.SOURCE_TASK_ID
         ,p_mmtt_rec.PROJECT_ID
         ,p_mmtt_rec.SOURCE_PROJECT_ID
         ,p_mmtt_rec.PA_EXPENDITURE_ORG_ID
         ,p_mmtt_rec.TO_PROJECT_ID
         ,p_mmtt_rec.EXPENDITURE_TYPE
         ,p_mmtt_rec.FINAL_COMPLETION_FLAG
         ,p_mmtt_rec.TRANSFER_PERCENTAGE
         ,p_mmtt_rec.TRANSACTION_SEQUENCE_ID
         ,p_mmtt_rec.MATERIAL_ACCOUNT
         ,p_mmtt_rec.MATERIAL_OVERHEAD_ACCOUNT
         ,p_mmtt_rec.RESOURCE_ACCOUNT
         ,p_mmtt_rec.OUTSIDE_PROCESSING_ACCOUNT
         ,p_mmtt_rec.OVERHEAD_ACCOUNT
         ,p_mmtt_rec.FLOW_SCHEDULE
         ,p_mmtt_rec.COST_GROUP_ID
         ,p_mmtt_rec.TRANSFER_COST_GROUP_ID
         ,p_mmtt_rec.DEMAND_CLASS
         ,p_mmtt_rec.QA_COLLECTION_ID
         ,p_mmtt_rec.KANBAN_CARD_ID
         ,p_mmtt_rec.OVERCOMPLETION_TRANSACTION_QTY
         ,p_mmtt_rec.OVERCOMPLETION_PRIMARY_QTY
         ,p_mmtt_rec.OVERCOMPLETION_TRANSACTION_ID
         ,p_mmtt_rec.END_ITEM_UNIT_NUMBER
         ,p_mmtt_rec.SCHEDULED_PAYBACK_DATE
         ,p_mmtt_rec.LINE_TYPE_CODE
         ,p_mmtt_rec.PARENT_TRANSACTION_TEMP_ID
         ,p_mmtt_rec.PUT_AWAY_STRATEGY_ID
         ,p_mmtt_rec.PUT_AWAY_RULE_ID
         ,p_mmtt_rec.PICK_STRATEGY_ID
         ,p_mmtt_rec.PICK_RULE_ID
         ,p_mmtt_rec.MOVE_ORDER_LINE_ID
         ,p_mmtt_rec.TASK_GROUP_ID
         ,p_mmtt_rec.PICK_SLIP_NUMBER
         ,p_mmtt_rec.RESERVATION_ID
         ,p_mmtt_rec.COMMON_BOM_SEQ_ID
         ,p_mmtt_rec.COMMON_ROUTING_SEQ_ID
         ,p_mmtt_rec.ORG_COST_GROUP_ID
         ,p_mmtt_rec.COST_TYPE_ID
         ,p_mmtt_rec.TRANSACTION_STATUS
         ,p_mmtt_rec.STANDARD_OPERATION_ID
         ,p_mmtt_rec.TASK_PRIORITY
         ,p_mmtt_rec.WMS_TASK_TYPE
         ,p_mmtt_rec.PARENT_LINE_ID
         ,p_mmtt_rec.LPN_ID
         ,p_mmtt_rec.TRANSFER_LPN_ID
         ,p_mmtt_rec.WMS_TASK_STATUS
         ,p_mmtt_rec.CONTENT_LPN_ID
         ,p_mmtt_rec.CONTAINER_ITEM_ID
         ,p_mmtt_rec.CARTONIZATION_ID
         ,p_mmtt_rec.PICK_SLIP_DATE
	 ,p_mmtt_rec.REBUILD_ITEM_ID
	 ,p_mmtt_rec.REBUILD_SERIAL_NUMBER
	 ,p_mmtt_rec.REBUILD_ACTIVITY_ID
	 ,p_mmtt_rec.REBUILD_JOB_NAME
	 ,p_mmtt_rec.ORGANIZATION_TYPE
	 ,p_mmtt_rec.TRANSFER_ORGANIZATION_TYPE
	 ,p_mmtt_rec.OWNING_ORGANIZATION_ID
	 ,p_mmtt_rec.OWNING_TP_TYPE
	 ,p_mmtt_rec.XFR_OWNING_ORGANIZATION_ID
	 ,p_mmtt_rec.TRANSFER_OWNING_TP_TYPE
	 ,p_mmtt_rec.PLANNING_ORGANIZATION_ID
	 ,p_mmtt_rec.PLANNING_TP_TYPE
	 ,p_mmtt_rec.XFR_PLANNING_ORGANIZATION_ID
	 ,p_mmtt_rec.TRANSFER_PLANNING_TP_TYPE
	 ,p_mmtt_rec.SECONDARY_UOM_CODE
	 ,p_mmtt_rec.SECONDARY_TRANSACTION_QUANTITY
	 ,p_mmtt_rec.TRANSACTION_BATCH_ID
	 ,p_mmtt_rec.TRANSACTION_BATCH_SEQ);

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
	  IF (l_debug = 1) THEN
   	  inv_log_util.trace('Inserted a New Record in MMTT', g_pkg_name, 9);
	  END IF;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count,
        p_data                  =>      x_msg_data);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         ROLLBACK TO sp_insert_mmtt;
	 x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('INV', 'INV_TRX_TYPE_ERROR');
         FND_MSG_PUB.ADD;
         IF (l_debug = 1) THEN
            inv_log_util.trace('insert mmtt .. EXCEP NO_DATA_FOUND : ', g_pkg_name, 9);
         END IF;
    WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO sp_insert_mmtt;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
             (p_encoded               =>      FND_API.G_FALSE,
              p_count                 =>      x_msg_count,
              p_data                  =>      x_msg_data);
         IF (l_debug = 1) THEN
            inv_log_util.trace('insert_mmtt .. EXCEP G_EXC_ERROR : ', g_pkg_name, 9);
         END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO sp_insert_mmtt;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get
             (p_encoded               =>      FND_API.G_FALSE,
              p_count                 =>      x_msg_count,
              p_data                  =>      x_msg_data);
         IF (l_debug = 1) THEN
            inv_log_util.trace('insert_mmtt .. EXCEP G_EXC_UNEXPECTED_ERROR : ', g_pkg_name, 9);
         END IF;
    WHEN OTHERS THEN
         ROLLBACK TO sp_insert_mmtt;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            FND_MSG_PUB.Add_Exc_Msg
                (G_PKG_NAME,
                 l_api_name);
         END IF;
         FND_MSG_PUB.Count_And_Get
             (p_encoded               =>      FND_API.G_FALSE,
              p_count                 =>      x_msg_count,
              p_data                  =>      x_msg_data);
         IF (l_debug = 1) THEN
            inv_log_util.trace('insert_mmtt .. EXCEP others: ' || SQLERRM(SQLCODE), g_pkg_name, 9);
         END IF;
END insert_mmtt;
--

PROCEDURE insert_mtlt(p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                      p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                      p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
		      p_mtlt_rec         IN  mtl_transaction_lots_temp%ROWTYPE,
		      x_return_status	 OUT NOCOPY VARCHAR2,
		      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2)
IS
   l_api_version        CONSTANT NUMBER := 1.0;
   l_api_name           CONSTANT VARCHAR2(30):= g_pkg_name||'.insert_mtlt';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   -- Standard Start of API savepoint
   SAVEPOINT sp_insert_mtlt;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
   END IF;

   INSERT INTO mtl_transaction_lots_temp
        (TRANSACTION_TEMP_ID
         ,LAST_UPDATE_DATE
	 ,LAST_UPDATED_BY
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_LOGIN
         ,REQUEST_ID
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,PROGRAM_UPDATE_DATE
         ,TRANSACTION_QUANTITY
         ,PRIMARY_QUANTITY
         ,LOT_NUMBER
         ,LOT_EXPIRATION_DATE
         ,ERROR_CODE
         ,SERIAL_TRANSACTION_TEMP_ID
         ,GROUP_HEADER_ID
         ,PUT_AWAY_RULE_ID
         ,PICK_RULE_ID
         ,DESCRIPTION
         ,VENDOR_ID
         ,SUPPLIER_LOT_NUMBER
         ,TERRITORY_CODE
         ,ORIGINATION_DATE
         ,DATE_CODE
         ,GRADE_CODE
         ,CHANGE_DATE
         ,MATURITY_DATE
         ,STATUS_ID
         ,RETEST_DATE
         ,AGE
         ,ITEM_SIZE
         ,COLOR
         ,VOLUME
         ,VOLUME_UOM
         ,PLACE_OF_ORIGIN
         ,BEST_BY_DATE
         ,LENGTH
         ,LENGTH_UOM
         ,RECYCLED_CONTENT
         ,THICKNESS
         ,THICKNESS_UOM
         ,WIDTH
         ,WIDTH_UOM
         ,CURL_WRINKLE_FOLD
         ,LOT_ATTRIBUTE_CATEGORY
         ,C_ATTRIBUTE1
         ,C_ATTRIBUTE2
         ,C_ATTRIBUTE3
         ,C_ATTRIBUTE4
         ,C_ATTRIBUTE5
         ,C_ATTRIBUTE6
         ,C_ATTRIBUTE7
         ,C_ATTRIBUTE8
         ,C_ATTRIBUTE9
         ,C_ATTRIBUTE10
         ,C_ATTRIBUTE11
         ,C_ATTRIBUTE12
         ,C_ATTRIBUTE13
         ,C_ATTRIBUTE14
         ,C_ATTRIBUTE15
         ,C_ATTRIBUTE16
         ,C_ATTRIBUTE17
         ,C_ATTRIBUTE18
         ,C_ATTRIBUTE19
         ,C_ATTRIBUTE20
         ,D_ATTRIBUTE1
         ,D_ATTRIBUTE2
         ,D_ATTRIBUTE3
         ,D_ATTRIBUTE4
         ,D_ATTRIBUTE5
         ,D_ATTRIBUTE6
         ,D_ATTRIBUTE7
         ,D_ATTRIBUTE8
         ,D_ATTRIBUTE9
         ,D_ATTRIBUTE10
         ,N_ATTRIBUTE1
         ,N_ATTRIBUTE2
         ,N_ATTRIBUTE3
         ,N_ATTRIBUTE4
         ,N_ATTRIBUTE5
         ,N_ATTRIBUTE6
         ,N_ATTRIBUTE7
         ,N_ATTRIBUTE8
         ,N_ATTRIBUTE9
         ,N_ATTRIBUTE10
         ,VENDOR_NAME
         ,SUBLOT_NUM
         ,SECONDARY_QUANTITY
	 ,SECONDARY_UNIT_OF_MEASURE
	 ,QC_GRADE)
    VALUES (
          p_mtlt_rec.TRANSACTION_TEMP_ID
	 ,p_mtlt_rec.LAST_UPDATE_DATE
         ,p_mtlt_rec.LAST_UPDATED_BY
         ,p_mtlt_rec.CREATION_DATE
         ,p_mtlt_rec.CREATED_BY
         ,p_mtlt_rec.LAST_UPDATE_LOGIN
         ,p_mtlt_rec.REQUEST_ID
         ,p_mtlt_rec.PROGRAM_APPLICATION_ID
         ,p_mtlt_rec.PROGRAM_ID
         ,p_mtlt_rec.PROGRAM_UPDATE_DATE
	 ,ABS(p_mtlt_rec.TRANSACTION_QUANTITY)
	 ,ABS(p_mtlt_rec.PRIMARY_QUANTITY)
	 ,p_mtlt_rec.LOT_NUMBER
	 ,p_mtlt_rec.LOT_EXPIRATION_DATE
         ,p_mtlt_rec.ERROR_CODE
         ,p_mtlt_rec.SERIAL_TRANSACTION_TEMP_ID
	 ,p_mtlt_rec.GROUP_HEADER_ID
	 ,p_mtlt_rec.PUT_AWAY_RULE_ID
	 ,p_mtlt_rec.PICK_RULE_ID
         ,p_mtlt_rec.DESCRIPTION
         ,p_mtlt_rec.VENDOR_ID
         ,p_mtlt_rec.SUPPLIER_LOT_NUMBER
         ,p_mtlt_rec.TERRITORY_CODE
         ,p_mtlt_rec.ORIGINATION_DATE
         ,p_mtlt_rec.DATE_CODE
         ,p_mtlt_rec.GRADE_CODE
         ,p_mtlt_rec.CHANGE_DATE
         ,p_mtlt_rec.MATURITY_DATE
         ,p_mtlt_rec.STATUS_ID
         ,p_mtlt_rec.RETEST_DATE
         ,p_mtlt_rec.AGE
         ,p_mtlt_rec.ITEM_SIZE
         ,p_mtlt_rec.COLOR
         ,p_mtlt_rec.VOLUME
         ,p_mtlt_rec.VOLUME_UOM
         ,p_mtlt_rec.PLACE_OF_ORIGIN
         ,p_mtlt_rec.BEST_BY_DATE
         ,p_mtlt_rec.LENGTH
         ,p_mtlt_rec.LENGTH_UOM
         ,p_mtlt_rec.RECYCLED_CONTENT
         ,p_mtlt_rec.THICKNESS
         ,p_mtlt_rec.THICKNESS_UOM
         ,p_mtlt_rec.WIDTH
         ,p_mtlt_rec.WIDTH_UOM
         ,p_mtlt_rec.CURL_WRINKLE_FOLD
         ,p_mtlt_rec.LOT_ATTRIBUTE_CATEGORY
         ,p_mtlt_rec.C_ATTRIBUTE1
         ,p_mtlt_rec.C_ATTRIBUTE2
         ,p_mtlt_rec.C_ATTRIBUTE3
         ,p_mtlt_rec.C_ATTRIBUTE4
         ,p_mtlt_rec.C_ATTRIBUTE5
         ,p_mtlt_rec.C_ATTRIBUTE6
         ,p_mtlt_rec.C_ATTRIBUTE7
         ,p_mtlt_rec.C_ATTRIBUTE8
         ,p_mtlt_rec.C_ATTRIBUTE9
         ,p_mtlt_rec.C_ATTRIBUTE10
         ,p_mtlt_rec.C_ATTRIBUTE11
         ,p_mtlt_rec.C_ATTRIBUTE12
         ,p_mtlt_rec.C_ATTRIBUTE13
         ,p_mtlt_rec.C_ATTRIBUTE14
         ,p_mtlt_rec.C_ATTRIBUTE15
         ,p_mtlt_rec.C_ATTRIBUTE16
         ,p_mtlt_rec.C_ATTRIBUTE17
         ,p_mtlt_rec.C_ATTRIBUTE18
         ,p_mtlt_rec.C_ATTRIBUTE19
         ,p_mtlt_rec.C_ATTRIBUTE20
         ,p_mtlt_rec.D_ATTRIBUTE1
         ,p_mtlt_rec.D_ATTRIBUTE2
         ,p_mtlt_rec.D_ATTRIBUTE3
         ,p_mtlt_rec.D_ATTRIBUTE4
         ,p_mtlt_rec.D_ATTRIBUTE5
         ,p_mtlt_rec.D_ATTRIBUTE6
         ,p_mtlt_rec.D_ATTRIBUTE7
         ,p_mtlt_rec.D_ATTRIBUTE8
         ,p_mtlt_rec.D_ATTRIBUTE9
         ,p_mtlt_rec.D_ATTRIBUTE10
         ,p_mtlt_rec.N_ATTRIBUTE1
         ,p_mtlt_rec.N_ATTRIBUTE2
         ,p_mtlt_rec.N_ATTRIBUTE3
         ,p_mtlt_rec.N_ATTRIBUTE4
         ,p_mtlt_rec.N_ATTRIBUTE5
         ,p_mtlt_rec.N_ATTRIBUTE6
         ,p_mtlt_rec.N_ATTRIBUTE7
         ,p_mtlt_rec.N_ATTRIBUTE8
         ,p_mtlt_rec.N_ATTRIBUTE9
         ,p_mtlt_rec.N_ATTRIBUTE10
         ,p_mtlt_rec.VENDOR_NAME
	 ,p_mtlt_rec.SUBLOT_NUM
	 ,p_mtlt_rec.SECONDARY_QUANTITY
	 ,p_mtlt_rec.SECONDARY_UNIT_OF_MEASURE
	 ,p_mtlt_rec.QC_GRADE);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO sp_insert_mtlt;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
             (p_encoded               =>      FND_API.G_FALSE,
              p_count                 =>      x_msg_count,
              p_data                  =>      x_msg_data);
         IF (l_debug = 1) THEN
            inv_log_util.trace('insert_mtlt .. EXCEP G_EXC_ERROR : ', g_pkg_name, 9);
         END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO sp_insert_mtlt;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get
             (p_encoded               =>      FND_API.G_FALSE,
              p_count                 =>      x_msg_count,
              p_data                  =>      x_msg_data);
         IF (l_debug = 1) THEN
            inv_log_util.trace('insert_mtlt .. EXCEP G_EXC_UNEXPECTED_ERROR : ', g_pkg_name, 9);
         END IF;
    WHEN OTHERS THEN
         ROLLBACK TO sp_insert_mtlt;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            FND_MSG_PUB.Add_Exc_Msg
                (G_PKG_NAME,
                 l_api_name);
         END IF;
         FND_MSG_PUB.Count_And_Get
             (p_encoded               =>      FND_API.G_FALSE,
              p_count                 =>      x_msg_count,
              p_data                  =>      x_msg_data);
         IF (l_debug = 1) THEN
            inv_log_util.trace( 'proc_insert_mtlt .. EXCEP others : ', g_pkg_name, 9);
         END IF;
END insert_mtlt;
--

PROCEDURE insert_msnt(p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                      p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                      p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                      p_msnt_rec	 IN  mtl_serial_numbers_temp%ROWTYPE,
		      x_return_status    OUT NOCOPY VARCHAR2,
		      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2)
IS
   l_api_version        CONSTANT NUMBER := 1.0;
   l_api_name           CONSTANT VARCHAR2(30):= g_pkg_name||'.insert_msnt';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   -- Standard Start of API savepoint
   SAVEPOINT sp_insert_mmtt;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
   END IF;

   INSERT INTO mtl_serial_numbers_temp
        (TRANSACTION_TEMP_ID
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_LOGIN
         ,REQUEST_ID
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,PROGRAM_UPDATE_DATE
         ,VENDOR_SERIAL_NUMBER
         ,VENDOR_LOT_NUMBER
         ,FM_SERIAL_NUMBER
         ,TO_SERIAL_NUMBER
         ,SERIAL_PREFIX
         ,ERROR_CODE
         ,PARENT_SERIAL_NUMBER
         ,GROUP_HEADER_ID
         ,END_ITEM_UNIT_NUMBER
         ,SERIAL_ATTRIBUTE_CATEGORY
         ,TERRITORY_CODE
         ,ORIGINATION_DATE
         ,C_ATTRIBUTE1
         ,C_ATTRIBUTE2
         ,C_ATTRIBUTE3
         ,C_ATTRIBUTE4
         ,C_ATTRIBUTE5
         ,C_ATTRIBUTE6
         ,C_ATTRIBUTE7
         ,C_ATTRIBUTE8
         ,C_ATTRIBUTE9
         ,C_ATTRIBUTE10
         ,C_ATTRIBUTE11
         ,C_ATTRIBUTE12
         ,C_ATTRIBUTE13
         ,C_ATTRIBUTE14
         ,C_ATTRIBUTE15
         ,C_ATTRIBUTE16
         ,C_ATTRIBUTE17
         ,C_ATTRIBUTE18
         ,C_ATTRIBUTE19
         ,C_ATTRIBUTE20
         ,D_ATTRIBUTE1
         ,D_ATTRIBUTE2
         ,D_ATTRIBUTE3
         ,D_ATTRIBUTE4
         ,D_ATTRIBUTE5
         ,D_ATTRIBUTE6
         ,D_ATTRIBUTE7
         ,D_ATTRIBUTE8
         ,D_ATTRIBUTE9
         ,D_ATTRIBUTE10
         ,N_ATTRIBUTE1
         ,N_ATTRIBUTE2
         ,N_ATTRIBUTE3
         ,N_ATTRIBUTE4
         ,N_ATTRIBUTE5
         ,N_ATTRIBUTE6
         ,N_ATTRIBUTE7
         ,N_ATTRIBUTE8
         ,N_ATTRIBUTE9
         ,N_ATTRIBUTE10
         ,STATUS_ID
         ,TIME_SINCE_NEW
         ,CYCLES_SINCE_NEW
         ,TIME_SINCE_OVERHAUL
         ,CYCLES_SINCE_OVERHAUL
         ,TIME_SINCE_REPAIR
         ,CYCLES_SINCE_REPAIR
         ,TIME_SINCE_VISIT
         ,CYCLES_SINCE_VISIT
         ,TIME_SINCE_MARK
         ,CYCLES_SINCE_MARK
         ,NUMBER_OF_REPAIRS)
    VALUES (
          p_msnt_rec.TRANSACTION_TEMP_ID
	 ,p_msnt_rec.LAST_UPDATE_DATE
         ,p_msnt_rec.LAST_UPDATED_BY
         ,p_msnt_rec.CREATION_DATE
         ,p_msnt_rec.CREATED_BY
         ,p_msnt_rec.LAST_UPDATE_LOGIN
         ,p_msnt_rec.REQUEST_ID
         ,p_msnt_rec.PROGRAM_APPLICATION_ID
         ,p_msnt_rec.PROGRAM_ID
         ,p_msnt_rec.PROGRAM_UPDATE_DATE
         ,p_msnt_rec.VENDOR_SERIAL_NUMBER
         ,p_msnt_rec.VENDOR_LOT_NUMBER
	 ,p_msnt_rec.FM_SERIAL_NUMBER
	 ,p_msnt_rec.TO_SERIAL_NUMBER
	 ,p_msnt_rec.SERIAL_PREFIX
         ,p_msnt_rec.ERROR_CODE
         ,p_msnt_rec.PARENT_SERIAL_NUMBER
         ,p_msnt_rec.GROUP_HEADER_ID
         ,p_msnt_rec.END_ITEM_UNIT_NUMBER
         ,p_msnt_rec.SERIAL_ATTRIBUTE_CATEGORY
         ,p_msnt_rec.TERRITORY_CODE
         ,p_msnt_rec.ORIGINATION_DATE
         ,p_msnt_rec.C_ATTRIBUTE1
         ,p_msnt_rec.C_ATTRIBUTE2
         ,p_msnt_rec.C_ATTRIBUTE3
         ,p_msnt_rec.C_ATTRIBUTE4
         ,p_msnt_rec.C_ATTRIBUTE5
         ,p_msnt_rec.C_ATTRIBUTE6
         ,p_msnt_rec.C_ATTRIBUTE7
         ,p_msnt_rec.C_ATTRIBUTE8
         ,p_msnt_rec.C_ATTRIBUTE9
         ,p_msnt_rec.C_ATTRIBUTE10
         ,p_msnt_rec.C_ATTRIBUTE11
         ,p_msnt_rec.C_ATTRIBUTE12
         ,p_msnt_rec.C_ATTRIBUTE13
         ,p_msnt_rec.C_ATTRIBUTE14
         ,p_msnt_rec.C_ATTRIBUTE15
         ,p_msnt_rec.C_ATTRIBUTE16
         ,p_msnt_rec.C_ATTRIBUTE17
         ,p_msnt_rec.C_ATTRIBUTE18
         ,p_msnt_rec.C_ATTRIBUTE19
         ,p_msnt_rec.C_ATTRIBUTE20
         ,p_msnt_rec.D_ATTRIBUTE1
         ,p_msnt_rec.D_ATTRIBUTE2
         ,p_msnt_rec.D_ATTRIBUTE3
         ,p_msnt_rec.D_ATTRIBUTE4
         ,p_msnt_rec.D_ATTRIBUTE5
         ,p_msnt_rec.D_ATTRIBUTE6
         ,p_msnt_rec.D_ATTRIBUTE7
         ,p_msnt_rec.D_ATTRIBUTE8
         ,p_msnt_rec.D_ATTRIBUTE9
         ,p_msnt_rec.D_ATTRIBUTE10
         ,p_msnt_rec.N_ATTRIBUTE1
         ,p_msnt_rec.N_ATTRIBUTE2
         ,p_msnt_rec.N_ATTRIBUTE3
         ,p_msnt_rec.N_ATTRIBUTE4
         ,p_msnt_rec.N_ATTRIBUTE5
         ,p_msnt_rec.N_ATTRIBUTE6
         ,p_msnt_rec.N_ATTRIBUTE7
         ,p_msnt_rec.N_ATTRIBUTE8
         ,p_msnt_rec.N_ATTRIBUTE9
         ,p_msnt_rec.N_ATTRIBUTE10
         ,p_msnt_rec.STATUS_ID
         ,p_msnt_rec.TIME_SINCE_NEW
         ,p_msnt_rec.CYCLES_SINCE_NEW
         ,p_msnt_rec.TIME_SINCE_OVERHAUL
         ,p_msnt_rec.CYCLES_SINCE_OVERHAUL
         ,p_msnt_rec.TIME_SINCE_REPAIR
         ,p_msnt_rec.CYCLES_SINCE_REPAIR
         ,p_msnt_rec.TIME_SINCE_VISIT
         ,p_msnt_rec.CYCLES_SINCE_VISIT
         ,p_msnt_rec.TIME_SINCE_MARK
         ,p_msnt_rec.CYCLES_SINCE_MARK
         ,p_msnt_rec.number_of_repairs);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO sp_insert_msnt;
         IF FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            FND_MSG_PUB.Add_Exc_Msg
                (G_PKG_NAME,
                 l_api_name);
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         IF (l_debug = 1) THEN
            inv_log_util.trace('proc_insert_msnt .. EXCEP G_EXC_ERROR : ', g_pkg_name, 9);
         END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO sp_insert_msnt;
         IF FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            FND_MSG_PUB.Add_Exc_Msg
                (G_PKG_NAME,
                 l_api_name);
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF (l_debug = 1) THEN
            inv_log_util.trace('proc_insert_msnt .. EXCEP G_EXC_UNEXPECTED_ERROR : ', g_pkg_name, 9);
         END IF;
    WHEN OTHERS THEN
         ROLLBACK TO sp_insert_msnt;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            FND_MSG_PUB.Add_Exc_Msg
                (G_PKG_NAME,
                 l_api_name);
         END IF;
         FND_MSG_PUB.Count_And_Get
             (p_encoded               =>      FND_API.G_FALSE,
              p_count                 =>      x_msg_count,
              p_data                  =>      x_msg_data);
         IF (l_debug = 1) THEN
            inv_log_util.trace('proc_insert_msnt .. EXCEP others: ' || SQLERRM(SQLCODE), g_pkg_name, 9) ;
         END IF;
END insert_msnt;

END inv_util;

/
