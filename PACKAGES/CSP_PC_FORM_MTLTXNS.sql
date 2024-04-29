--------------------------------------------------------
--  DDL for Package CSP_PC_FORM_MTLTXNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PC_FORM_MTLTXNS" AUTHID CURRENT_USER AS
/* $Header: cspgtmxs.pls 120.0 2005/05/25 11:39:58 appldev noship $ */
-- Start of Comments
-- Package name     : CSP_PC_FORM_MTLTXNS
-- Purpose          : A wrapper to prepare data to call the update, delete and insert procedures of the
--                    CSP_Material_Transaactions_PVT.
-- History          :
--  27-Dec-99, Add procedure csp_mo_lines_manual_receipts
--  20-Dec-99, klou.
--
-- NOTE             :
-- End of Comments

PROCEDURE Validate_And_Write (
        P_Api_Version_Number        IN      NUMBER,
       P_Init_Msg_List             IN      VARCHAR2     := FND_API.G_FALSE,
       P_Commit                    IN      VARCHAR2     := FND_API.G_FALSE,
       p_validation_level          IN      NUMBER       := FND_API.G_VALID_LEVEL_FULL,
       p_action_code               IN      NUMBER,
       p_TRANSACTION_HEADER_ID     IN      NUMBER := FND_API.G_MISS_NUM,
       px_TRANSACTION_TEMP_ID      IN      OUT NOCOPY    NUMBER,
       p_SOURCE_CODE             IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_SOURCE_LINE_ID          IN     NUMBER := FND_API.G_MISS_NUM,
      p_TRANSACTION_MODE        IN     NUMBER := FND_API.G_MISS_NUM,
      p_LOCK_FLAG               IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_LAST_UPDATE_DATE        IN     DATE := FND_API.G_MISS_DATE,
      p_LAST_UPDATED_BY         IN     NUMBER := FND_API.G_MISS_NUM,
      p_CREATION_DATE           IN     DATE := FND_API.G_MISS_DATE,
      p_CREATED_BY              IN     NUMBER := FND_API.G_MISS_NUM,
      p_LAST_UPDATE_LOGIN       IN     NUMBER := FND_API.G_MISS_NUM,
      p_REQUEST_ID              IN     NUMBER := FND_API.G_MISS_NUM,
      p_PROGRAM_APPLICATION_ID   IN     NUMBER := FND_API.G_MISS_NUM,
      p_PROGRAM_ID              IN     NUMBER := FND_API.G_MISS_NUM,
      p_PROGRAM_UPDATE_DATE     IN     DATE := FND_API.G_MISS_DATE,
      p_INVENTORY_ITEM_ID       IN     NUMBER := FND_API.G_MISS_NUM,
      p_REVISION                IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ORGANIZATION_ID         IN     NUMBER := FND_API.G_MISS_NUM,
      p_SUBINVENTORY_CODE       IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_LOCATOR_ID              IN     NUMBER := FND_API.G_MISS_NUM,
      p_TRANSACTION_QUANTITY    IN     NUMBER := FND_API.G_MISS_NUM,
      p_PRIMARY_QUANTITY        IN     NUMBER := FND_API.G_MISS_NUM,
      p_TRANSACTION_UOM         IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_TRANSACTION_COST        IN     NUMBER := FND_API.G_MISS_NUM,
      p_TRANSACTION_TYPE_ID     IN     NUMBER := FND_API.G_MISS_NUM,
      p_TRANSACTION_ACTION_ID   IN     NUMBER := FND_API.G_MISS_NUM,
      p_TRANSACTION_SOURCE_TYPE_ID   IN     NUMBER := FND_API.G_MISS_NUM,
      p_TRANSACTION_SOURCE_ID   IN     NUMBER := FND_API.G_MISS_NUM,
      p_TRANSACTION_SOURCE_NAME IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_TRANSACTION_DATE        IN     DATE := FND_API.G_MISS_DATE,
      p_ACCT_PERIOD_ID          IN     NUMBER := FND_API.G_MISS_NUM,
      p_DISTRIBUTION_ACCOUNT_ID IN     NUMBER := FND_API.G_MISS_NUM,
      p_TRANSACTION_REFERENCE   IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_REQUISITION_LINE_ID     IN     NUMBER := FND_API.G_MISS_NUM,
      p_REQUISITION_DISTRIBUTION_ID   IN     NUMBER := FND_API.G_MISS_NUM,
      p_REASON_ID               IN     NUMBER := FND_API.G_MISS_NUM,
      p_LOT_NUMBER              IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_LOT_EXPIRATION_DATE     IN     DATE := FND_API.G_MISS_DATE,
      p_SERIAL_NUMBER           IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_RECEIVING_DOCUMENT      IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_DEMAND_ID               IN     NUMBER := FND_API.G_MISS_NUM,
      p_RCV_TRANSACTION_ID      IN     NUMBER := FND_API.G_MISS_NUM,
      p_MOVE_TRANSACTION_ID     IN     NUMBER := FND_API.G_MISS_NUM,
      p_COMPLETION_TRANSACTION_ID   IN     NUMBER := FND_API.G_MISS_NUM,
      p_WIP_ENTITY_TYPE         IN     NUMBER := FND_API.G_MISS_NUM,
      p_SCHEDULE_ID             IN     NUMBER := FND_API.G_MISS_NUM,
      p_REPETITIVE_LINE_ID      IN     NUMBER := FND_API.G_MISS_NUM,
      p_EMPLOYEE_CODE           IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_PRIMARY_SWITCH          IN     NUMBER := FND_API.G_MISS_NUM,
      p_SCHEDULE_UPDATE_CODE    IN     NUMBER := FND_API.G_MISS_NUM,
      p_SETUP_TEARDOWN_CODE     IN     NUMBER := FND_API.G_MISS_NUM,
      p_ITEM_ORDERING           IN     NUMBER := FND_API.G_MISS_NUM,
      p_NEGATIVE_REQ_FLAG       IN     NUMBER := FND_API.G_MISS_NUM,
      p_OPERATION_SEQ_NUM       IN     NUMBER := FND_API.G_MISS_NUM,
      p_PICKING_LINE_ID         IN     NUMBER := FND_API.G_MISS_NUM,
      p_TRX_SOURCE_LINE_ID      IN     NUMBER := FND_API.G_MISS_NUM,
      p_TRX_SOURCE_DELIVERY_ID  IN     NUMBER := FND_API.G_MISS_NUM,
      p_PHYSICAL_ADJUSTMENT_ID  IN     NUMBER := FND_API.G_MISS_NUM,
      p_CYCLE_COUNT_ID          IN     NUMBER := FND_API.G_MISS_NUM,
      p_RMA_LINE_ID             IN     NUMBER := FND_API.G_MISS_NUM,
      p_CUSTOMER_SHIP_ID        IN     NUMBER := FND_API.G_MISS_NUM,
      p_CURRENCY_CODE           IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_CURRENCY_CONVERSION_RATE   IN     NUMBER := FND_API.G_MISS_NUM,
      p_CURRENCY_CONVERSION_TYPE   IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_CURRENCY_CONVERSION_DATE   IN     DATE := FND_API.G_MISS_DATE,
      p_USSGL_TRANSACTION_CODE  IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_VENDOR_LOT_NUMBER       IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ENCUMBRANCE_ACCOUNT     IN     NUMBER := FND_API.G_MISS_NUM,
      p_ENCUMBRANCE_AMOUNT      IN     NUMBER := FND_API.G_MISS_NUM,
      p_SHIP_TO_LOCATION        IN     NUMBER := FND_API.G_MISS_NUM,
      p_SHIPMENT_NUMBER         IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_TRANSFER_COST           IN     NUMBER := FND_API.G_MISS_NUM,
      p_TRANSPORTATION_COST     IN     NUMBER := FND_API.G_MISS_NUM,
      p_TRANSPORTATION_ACCOUNT  IN     NUMBER := FND_API.G_MISS_NUM,
      p_FREIGHT_CODE            IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_CONTAINERS              IN     NUMBER := FND_API.G_MISS_NUM,
      p_WAYBILL_AIRBILL         IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_EXPECTED_ARRIVAL_DATE   IN     DATE := FND_API.G_MISS_DATE,
      p_TRANSFER_SUBINVENTORY   IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_TRANSFER_ORGANIZATION   IN     NUMBER := FND_API.G_MISS_NUM,
      p_TRANSFER_TO_LOCATION    IN     NUMBER := FND_API.G_MISS_NUM,
      p_NEW_AVERAGE_COST        IN     NUMBER := FND_API.G_MISS_NUM,
      p_VALUE_CHANGE            IN     NUMBER := FND_API.G_MISS_NUM,
      p_PERCENTAGE_CHANGE       IN     NUMBER := FND_API.G_MISS_NUM,
      p_MATERIAL_ALLOCATION_TEMP_ID   IN     NUMBER := FND_API.G_MISS_NUM,
      p_DEMAND_SOURCE_HEADER_ID   IN     NUMBER := FND_API.G_MISS_NUM,
      p_DEMAND_SOURCE_LINE      IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_DEMAND_SOURCE_DELIVERY  IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ITEM_SEGMENTS           IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ITEM_DESCRIPTION        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ITEM_TRX_ENABLED_FLAG   IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ITEM_LOCATION_CONTROL_CODE   IN     NUMBER := FND_API.G_MISS_NUM,
      p_ITEM_RESTRICT_SUBINV_CODE   IN     NUMBER := FND_API.G_MISS_NUM,
      p_ITEM_RESTRICT_LOCATORS_CODE   IN     NUMBER := FND_API.G_MISS_NUM,
      p_ITEM_REV_QTY_CONTROL_CODE   IN     NUMBER := FND_API.G_MISS_NUM,
      p_ITEM_PRIMARY_UOM_CODE   IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ITEM_UOM_CLASS          IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ITEM_SHELF_LIFE_CODE    IN     NUMBER := FND_API.G_MISS_NUM,
      p_ITEM_SHELF_LIFE_DAYS    IN     NUMBER := FND_API.G_MISS_NUM,
      p_ITEM_LOT_CONTROL_CODE   IN     NUMBER := FND_API.G_MISS_NUM,
      p_ITEM_SERIAL_CONTROL_CODE   IN     NUMBER := FND_API.G_MISS_NUM,
      p_ITEM_INVENTORY_ASSET_FLAG  IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ALLOWED_UNITS_LOOKUP_CODE  IN     NUMBER := FND_API.G_MISS_NUM,
      p_DEPARTMENT_ID           IN     NUMBER := FND_API.G_MISS_NUM,
      p_DEPARTMENT_CODE         IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_WIP_SUPPLY_TYPE         IN     NUMBER := FND_API.G_MISS_NUM,
      p_SUPPLY_SUBINVENTORY     IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_SUPPLY_LOCATOR_ID       IN     NUMBER := FND_API.G_MISS_NUM,
      p_VALID_SUBINVENTORY_FLAG IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_VALID_LOCATOR_FLAG      IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_LOCATOR_SEGMENTS        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_CURRENT_LOCATOR_CONTROL_CODE   IN     NUMBER := FND_API.G_MISS_NUM,
      p_NUMBER_OF_LOTS_ENTERED   IN     NUMBER := FND_API.G_MISS_NUM,
      p_WIP_COMMIT_FLAG         IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_NEXT_LOT_NUMBER         IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_LOT_ALPHA_PREFIX        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_NEXT_SERIAL_NUMBER      IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_SERIAL_ALPHA_PREFIX     IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_SHIPPABLE_FLAG          IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_POSTING_FLAG            IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_REQUIRED_FLAG           IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_PROCESS_FLAG            IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ERROR_CODE              IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ERROR_EXPLANATION       IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE_CATEGORY      IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE1              IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE2              IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE3              IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE4              IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE5              IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE6              IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE7              IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE8              IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE9              IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE10             IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE11             IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE12             IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE13             IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE14             IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE15             IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_MOVEMENT_ID             IN     NUMBER := FND_API.G_MISS_NUM,
      p_RESERVATION_QUANTITY    IN     NUMBER := FND_API.G_MISS_NUM,
      p_SHIPPED_QUANTITY        IN     NUMBER := FND_API.G_MISS_NUM,
      p_TRANSACTION_LINE_NUMBER IN     NUMBER := FND_API.G_MISS_NUM,
      p_TASK_ID                 IN     NUMBER := FND_API.G_MISS_NUM,
      p_TO_TASK_ID              IN     NUMBER := FND_API.G_MISS_NUM,
      p_SOURCE_TASK_ID          IN     NUMBER := FND_API.G_MISS_NUM,
      p_PROJECT_ID              IN     NUMBER := FND_API.G_MISS_NUM,
      p_SOURCE_PROJECT_ID       IN     NUMBER := FND_API.G_MISS_NUM,
      p_PA_EXPENDITURE_ORG_ID   IN     NUMBER := FND_API.G_MISS_NUM,
      p_TO_PROJECT_ID           IN     NUMBER := FND_API.G_MISS_NUM,
      p_EXPENDITURE_TYPE        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_FINAL_COMPLETION_FLAG   IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_TRANSFER_PERCENTAGE     IN     NUMBER := FND_API.G_MISS_NUM,
      p_TRANSACTION_SEQUENCE_ID   IN     NUMBER := FND_API.G_MISS_NUM,
      p_MATERIAL_ACCOUNT        IN     NUMBER := FND_API.G_MISS_NUM,
      p_MATERIAL_OVERHEAD_ACCOUNT   IN     NUMBER := FND_API.G_MISS_NUM,
      p_RESOURCE_ACCOUNT        IN     NUMBER := FND_API.G_MISS_NUM,
      p_OUTSIDE_PROCESSING_ACCOUNT   IN     NUMBER := FND_API.G_MISS_NUM,
      p_OVERHEAD_ACCOUNT        IN     NUMBER := FND_API.G_MISS_NUM,
      p_FLOW_SCHEDULE           IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_COST_GROUP_ID           IN     NUMBER := FND_API.G_MISS_NUM,
      p_DEMAND_CLASS            IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_QA_COLLECTION_ID        IN     NUMBER := FND_API.G_MISS_NUM,
      p_KANBAN_CARD_ID          IN     NUMBER := FND_API.G_MISS_NUM,
      p_OVERCOMPLETION_TXN_ID   IN     NUMBER := FND_API.G_MISS_NUM,
      p_OVERCOMPLETION_PRIMARY_QTY   IN     NUMBER := FND_API.G_MISS_NUM,
      p_OVERCOMPLETION_TXN_QTY  IN     NUMBER := FND_API.G_MISS_NUM,
     -- p_PROCESS_TYPE   IN     NUMBER := FND_API.G_MISS_NUM,
      p_END_ITEM_UNIT_NUMBER    IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      p_SCHEDULED_PAYBACK_DATE  IN     DATE := FND_API.G_MISS_DATE,
      p_LINE_TYPE_CODE          IN     NUMBER := FND_API.G_MISS_NUM,
      p_PARENT_TRANSACTION_TEMP_ID   IN     NUMBER := FND_API.G_MISS_NUM,
      p_PUT_AWAY_STRATEGY_ID    IN     NUMBER := FND_API.G_MISS_NUM,
      p_PUT_AWAY_RULE_ID        IN     NUMBER := FND_API.G_MISS_NUM,
      p_PICK_STRATEGY_ID        IN     NUMBER := FND_API.G_MISS_NUM,
      p_PICK_RULE_ID            IN     NUMBER := FND_API.G_MISS_NUM,
      p_COMMON_BOM_SEQ_ID       IN     NUMBER := FND_API.G_MISS_NUM,
      p_COMMON_ROUTING_SEQ_ID   IN     NUMBER := FND_API.G_MISS_NUM,
      p_COST_TYPE_ID            IN     NUMBER := FND_API.G_MISS_NUM,
      p_ORG_COST_GROUP_ID       IN     NUMBER := FND_API.G_MISS_NUM,
      p_MOVE_ORDER_LINE_ID      IN     NUMBER := FND_API.G_MISS_NUM,
      p_TASK_GROUP_ID           IN     NUMBER := FND_API.G_MISS_NUM,
      p_PICK_SLIP_NUMBER        IN     NUMBER := FND_API.G_MISS_NUM,
      p_RESERVATION_ID          IN     NUMBER := FND_API.G_MISS_NUM,
      p_TRANSACTION_STATUS      IN     NUMBER := FND_API.G_MISS_NUM,
      P_STANDARD_OPERATION_ID   IN     NUMBER := FND_API.G_MISS_NUM,
      P_TASK_PRIORITY           IN     NUMBER := FND_API.G_MISS_NUM,
      P_WMS_TASK_TYPE           IN     NUMBER := FND_API.G_MISS_NUM,
      P_PARENT_LINE_ID          IN     NUMBER := FND_API.G_MISS_NUM,
      --P_SOURCE_LOT_NUMBER       IN     VARCHAR2 := FND_API.G_MISS_CHAR,
       X_Return_Status           OUT NOCOPY     VARCHAR2,
       X_Msg_Count               OUT NOCOPY     NUMBER,
       X_Msg_Data                OUT NOCOPY     VARCHAR2
    );


    PROCEDURE CSP_MO_LINES_MANUAL_RECEIPT (
       P_Api_Version_Number      IN      NUMBER,
       P_Init_Msg_List           IN      VARCHAR2     := FND_API.G_FALSE,
       P_Commit                  IN      VARCHAR2     := FND_API.G_FALSE,
       p_validation_level        IN      NUMBER       := FND_API.G_VALID_LEVEL_FULL,
       p_organization_id         IN      NUMBER,
       p_transaction_temp_id     IN      NUMBER,
       px_transaction_header_id  IN OUT NOCOPY  NUMBER,
       p_process_flag            IN      VARCHAR2     := FND_API.G_FALSE,
       X_Return_Status           OUT NOCOPY     VARCHAR2,
       X_Msg_Count               OUT NOCOPY     NUMBER,
       X_Msg_Data                OUT NOCOPY     VARCHAR2
    );


    PROCEDURE CSP_MO_Lines_Auto_Receipt (
       P_Api_Version_Number      IN      NUMBER,
       P_Init_Msg_List           IN      VARCHAR2     := FND_API.G_FALSE,
       P_Commit                  IN      VARCHAR2     := FND_API.G_FALSE,
       p_validation_level        IN      NUMBER       := FND_API.G_VALID_LEVEL_FULL,
       p_organization_id         IN      NUMBER,
       p_transaction_temp_id     IN      NUMBER,
       X_Return_Status           OUT NOCOPY     VARCHAR2,
       X_Msg_Count               OUT NOCOPY     NUMBER,
       X_Msg_Data                OUT NOCOPY     VARCHAR2
       );

END CSP_PC_FORM_MTLTXNS;

 

/