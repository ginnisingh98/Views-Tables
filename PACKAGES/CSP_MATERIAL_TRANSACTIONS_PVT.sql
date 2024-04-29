--------------------------------------------------------
--  DDL for Package CSP_MATERIAL_TRANSACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_MATERIAL_TRANSACTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: cspvmmts.pls 120.1 2006/07/20 06:07:03 hhaugeru noship $ */
-- Start of Comments
-- Package name     : CSP_MATERIAL_TRANSACTIONS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:CSP_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    TRANSACTION_HEADER_ID
--    TRANSACTION_TEMP_ID
--    SOURCE_CODE
--    SOURCE_LINE_ID
--    TRANSACTION_MODE
--    LOCK_FLAG
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_LOGIN
--    REQUEST_ID
--    PROGRAM_APPLICATION_ID
--    PROGRAM_ID
--    PROGRAM_UPDATE_DATE
--    INVENTORY_ITEM_ID
--    REVISION
--    ORGANIZATION_ID
--    SUBINVENTORY_CODE
--    LOCATOR_ID
--    TRANSACTION_QUANTITY
--    PRIMARY_QUANTITY
--    TRANSACTION_UOM
--    TRANSACTION_COST
--    TRANSACTION_TYPE_ID
--    TRANSACTION_ACTION_ID
--    TRANSACTION_SOURCE_TYPE_ID
--    TRANSACTION_SOURCE_ID
--    TRANSACTION_SOURCE_NAME
--    TRANSACTION_DATE
--    ACCT_PERIOD_ID
--    DISTRIBUTION_ACCOUNT_ID
--    TRANSACTION_REFERENCE
--    REQUISITION_LINE_ID
--    REQUISITION_DISTRIBUTION_ID
--    REASON_ID
--    LOT_NUMBER
--    LOT_EXPIRATION_DATE
--    SERIAL_NUMBER
--    RECEIVING_DOCUMENT
--    DEMAND_ID
--    RCV_TRANSACTION_ID
--    MOVE_TRANSACTION_ID
--    COMPLETION_TRANSACTION_ID
--    WIP_ENTITY_TYPE
--    SCHEDULE_ID
--    REPETITIVE_LINE_ID
--    EMPLOYEE_CODE
--    PRIMARY_SWITCH
--    SCHEDULE_UPDATE_CODE
--    SETUP_TEARDOWN_CODE
--    ITEM_ORDERING
--    NEGATIVE_REQ_FLAG
--    OPERATION_SEQ_NUM
--    PICKING_LINE_ID
--    TRX_SOURCE_LINE_ID
--    TRX_SOURCE_DELIVERY_ID
--    PHYSICAL_ADJUSTMENT_ID
--    CYCLE_COUNT_ID
--    RMA_LINE_ID
--    CUSTOMER_SHIP_ID
--    CURRENCY_CODE
--    CURRENCY_CONVERSION_RATE
--    CURRENCY_CONVERSION_TYPE
--    CURRENCY_CONVERSION_DATE
--    USSGL_TRANSACTION_CODE
--    VENDOR_LOT_NUMBER
--    ENCUMBRANCE_ACCOUNT
--    ENCUMBRANCE_AMOUNT
--    SHIP_TO_LOCATION
--    SHIPMENT_NUMBER
--    TRANSFER_COST
--    TRANSPORTATION_COST
--    TRANSPORTATION_ACCOUNT
--    FREIGHT_CODE
--    CONTAINERS
--    WAYBILL_AIRBILL
--    EXPECTED_ARRIVAL_DATE
--    TRANSFER_SUBINVENTORY
--    TRANSFER_ORGANIZATION
--    TRANSFER_TO_LOCATION
--    NEW_AVERAGE_COST
--    VALUE_CHANGE
--    PERCENTAGE_CHANGE
--    MATERIAL_ALLOCATION_TEMP_ID
--    DEMAND_SOURCE_HEADER_ID
--    DEMAND_SOURCE_LINE
--    DEMAND_SOURCE_DELIVERY
--    ITEM_SEGMENTS
--    ITEM_DESCRIPTION
--    ITEM_TRX_ENABLED_FLAG
--    ITEM_LOCATION_CONTROL_CODE
--    ITEM_RESTRICT_SUBINV_CODE
--    ITEM_RESTRICT_LOCATORS_CODE
--    ITEM_REVISION_QTY_CONTROL_CODE
--    ITEM_PRIMARY_UOM_CODE
--    ITEM_UOM_CLASS
--    ITEM_SHELF_LIFE_CODE
--    ITEM_SHELF_LIFE_DAYS
--    ITEM_LOT_CONTROL_CODE
--    ITEM_SERIAL_CONTROL_CODE
--    ITEM_INVENTORY_ASSET_FLAG
--    ALLOWED_UNITS_LOOKUP_CODE
--    DEPARTMENT_ID
--    DEPARTMENT_CODE
--    WIP_SUPPLY_TYPE
--    SUPPLY_SUBINVENTORY
--    SUPPLY_LOCATOR_ID
--    VALID_SUBINVENTORY_FLAG
--    VALID_LOCATOR_FLAG
--    LOCATOR_SEGMENTS
--    CURRENT_LOCATOR_CONTROL_CODE
--    NUMBER_OF_LOTS_ENTERED
--    WIP_COMMIT_FLAG
--    NEXT_LOT_NUMBER
--    LOT_ALPHA_PREFIX
--    NEXT_SERIAL_NUMBER
--    SERIAL_ALPHA_PREFIX
--    SHIPPABLE_FLAG
--    POSTING_FLAG
--    REQUIRED_FLAG
--    PROCESS_FLAG
--    ERROR_CODE
--    ERROR_EXPLANATION
--    ATTRIBUTE_CATEGORY
--    ATTRIBUTE1
--    ATTRIBUTE2
--    ATTRIBUTE3
--    ATTRIBUTE4
--    ATTRIBUTE5
--    ATTRIBUTE6
--    ATTRIBUTE7
--    ATTRIBUTE8
--    ATTRIBUTE9
--    ATTRIBUTE10
--    ATTRIBUTE11
--    ATTRIBUTE12
--    ATTRIBUTE13
--    ATTRIBUTE14
--    ATTRIBUTE15
--    MOVEMENT_ID
--    RESERVATION_QUANTITY
--    SHIPPED_QUANTITY
--    TRANSACTION_LINE_NUMBER
--    TASK_ID
--    TO_TASK_ID
--    SOURCE_TASK_ID
--    PROJECT_ID
--    SOURCE_PROJECT_ID
--    PA_EXPENDITURE_ORG_ID
--    TO_PROJECT_ID
--    EXPENDITURE_TYPE
--    FINAL_COMPLETION_FLAG
--    TRANSFER_PERCENTAGE
--    TRANSACTION_SEQUENCE_ID
--    MATERIAL_ACCOUNT
--    MATERIAL_OVERHEAD_ACCOUNT
--    RESOURCE_ACCOUNT
--    OUTSIDE_PROCESSING_ACCOUNT
--    OVERHEAD_ACCOUNT
--    FLOW_SCHEDULE
--    COST_GROUP_ID
--    DEMAND_CLASS
--    QA_COLLECTION_ID
--    KANBAN_CARD_ID
--    OVERCOMPLETION_TRANSACTION_ID
--    OVERCOMPLETION_PRIMARY_QTY
--    OVERCOMPLETION_TRANSACTION_QTY
--    END_ITEM_UNIT_NUMBER
--    SCHEDULED_PAYBACK_DATE
--    LINE_TYPE_CODE
--    PARENT_TRANSACTION_TEMP_ID
--    PUT_AWAY_STRATEGY_ID
--    PUT_AWAY_RULE_ID
--    PICK_STRATEGY_ID
--    PICK_RULE_ID
--    COMMON_BOM_SEQ_ID
--    COMMON_ROUTING_SEQ_ID
--    COST_TYPE_ID
--    ORG_COST_GROUP_ID
--    MOVE_ORDER_LINE_ID
--    TASK_GROUP_ID
--    PICK_SLIP_NUMBER
--    RESERVATION_ID
--    TRANSACTION_STATUS
--    STANDARD_OPERATIOND_ID
--    TASK_PRIORITY
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

-- phegde commented 02/21/00
--
TYPE CSP_Rec_Type IS RECORD
(
       TRANSACTION_HEADER_ID           NUMBER := FND_API.G_MISS_NUM,
       TRANSACTION_TEMP_ID             NUMBER := FND_API.G_MISS_NUM,
       SOURCE_CODE                     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       SOURCE_LINE_ID                  NUMBER := FND_API.G_MISS_NUM,
       TRANSACTION_MODE                NUMBER := FND_API.G_MISS_NUM,
       LOCK_FLAG                       VARCHAR2(1) := FND_API.G_MISS_CHAR,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       INVENTORY_ITEM_ID               NUMBER := FND_API.G_MISS_NUM,
       REVISION                        VARCHAR2(3) := FND_API.G_MISS_CHAR,
       ORGANIZATION_ID                 NUMBER := FND_API.G_MISS_NUM,
       SUBINVENTORY_CODE               VARCHAR2(10) := FND_API.G_MISS_CHAR,
       LOCATOR_ID                      NUMBER := FND_API.G_MISS_NUM,
       TRANSACTION_QUANTITY            NUMBER := FND_API.G_MISS_NUM,
       PRIMARY_QUANTITY                NUMBER := FND_API.G_MISS_NUM,
       TRANSACTION_UOM                 VARCHAR2(3) := FND_API.G_MISS_CHAR,
       TRANSACTION_COST                NUMBER := FND_API.G_MISS_NUM,
       TRANSACTION_TYPE_ID             NUMBER := FND_API.G_MISS_NUM,
       TRANSACTION_ACTION_ID           NUMBER := FND_API.G_MISS_NUM,
       TRANSACTION_SOURCE_TYPE_ID      NUMBER := FND_API.G_MISS_NUM,
       TRANSACTION_SOURCE_ID           NUMBER := FND_API.G_MISS_NUM,
       TRANSACTION_SOURCE_NAME         VARCHAR2(30) := FND_API.G_MISS_CHAR,
       TRANSACTION_DATE                DATE := FND_API.G_MISS_DATE,
       ACCT_PERIOD_ID                  NUMBER := FND_API.G_MISS_NUM,
       DISTRIBUTION_ACCOUNT_ID         NUMBER := FND_API.G_MISS_NUM,
       TRANSACTION_REFERENCE           VARCHAR2(240) := FND_API.G_MISS_CHAR,
       REQUISITION_LINE_ID             NUMBER := FND_API.G_MISS_NUM,
       REQUISITION_DISTRIBUTION_ID     NUMBER := FND_API.G_MISS_NUM,
       REASON_ID                       NUMBER := FND_API.G_MISS_NUM,
       LOT_NUMBER                      VARCHAR2(80) := FND_API.G_MISS_CHAR,
       LOT_EXPIRATION_DATE             DATE := FND_API.G_MISS_DATE,
       SERIAL_NUMBER                   VARCHAR2(30) := FND_API.G_MISS_CHAR,
       RECEIVING_DOCUMENT              VARCHAR2(10) := FND_API.G_MISS_CHAR,
       DEMAND_ID                       NUMBER := FND_API.G_MISS_NUM,
       RCV_TRANSACTION_ID              NUMBER := FND_API.G_MISS_NUM,
       MOVE_TRANSACTION_ID             NUMBER := FND_API.G_MISS_NUM,
       COMPLETION_TRANSACTION_ID       NUMBER := FND_API.G_MISS_NUM,
       WIP_ENTITY_TYPE                 NUMBER := FND_API.G_MISS_NUM,
       SCHEDULE_ID                     NUMBER := FND_API.G_MISS_NUM,
       REPETITIVE_LINE_ID              NUMBER := FND_API.G_MISS_NUM,
       EMPLOYEE_CODE                   VARCHAR2(10) := FND_API.G_MISS_CHAR,
       PRIMARY_SWITCH                  NUMBER := FND_API.G_MISS_NUM,
       SCHEDULE_UPDATE_CODE            NUMBER := FND_API.G_MISS_NUM,
       SETUP_TEARDOWN_CODE             NUMBER := FND_API.G_MISS_NUM,
       ITEM_ORDERING                   NUMBER := FND_API.G_MISS_NUM,
       NEGATIVE_REQ_FLAG               NUMBER := FND_API.G_MISS_NUM,
       OPERATION_SEQ_NUM               NUMBER := FND_API.G_MISS_NUM,
       PICKING_LINE_ID                 NUMBER := FND_API.G_MISS_NUM,
       TRX_SOURCE_LINE_ID              NUMBER := FND_API.G_MISS_NUM,
       TRX_SOURCE_DELIVERY_ID          NUMBER := FND_API.G_MISS_NUM,
       PHYSICAL_ADJUSTMENT_ID          NUMBER := FND_API.G_MISS_NUM,
       CYCLE_COUNT_ID                  NUMBER := FND_API.G_MISS_NUM,
       RMA_LINE_ID                     NUMBER := FND_API.G_MISS_NUM,
       CUSTOMER_SHIP_ID                NUMBER := FND_API.G_MISS_NUM,
       CURRENCY_CODE                   VARCHAR2(10) := FND_API.G_MISS_CHAR,
       CURRENCY_CONVERSION_RATE        NUMBER := FND_API.G_MISS_NUM,
       CURRENCY_CONVERSION_TYPE        VARCHAR2(30) := FND_API.G_MISS_CHAR,
       CURRENCY_CONVERSION_DATE        DATE := FND_API.G_MISS_DATE,
       USSGL_TRANSACTION_CODE          VARCHAR2(30) := FND_API.G_MISS_CHAR,
       VENDOR_LOT_NUMBER               VARCHAR2(80) := FND_API.G_MISS_CHAR,
       ENCUMBRANCE_ACCOUNT             NUMBER := FND_API.G_MISS_NUM,
       ENCUMBRANCE_AMOUNT              NUMBER := FND_API.G_MISS_NUM,
       SHIP_TO_LOCATION                NUMBER := FND_API.G_MISS_NUM,
       SHIPMENT_NUMBER                 VARCHAR2(30) := FND_API.G_MISS_CHAR,
       TRANSFER_COST                   NUMBER := FND_API.G_MISS_NUM,
       TRANSPORTATION_COST             NUMBER := FND_API.G_MISS_NUM,
       TRANSPORTATION_ACCOUNT          NUMBER := FND_API.G_MISS_NUM,
       FREIGHT_CODE                    VARCHAR2(25) := FND_API.G_MISS_CHAR,
       CONTAINERS                      NUMBER := FND_API.G_MISS_NUM,
       WAYBILL_AIRBILL                 VARCHAR2(20) := FND_API.G_MISS_CHAR,
       EXPECTED_ARRIVAL_DATE           DATE := FND_API.G_MISS_DATE,
       TRANSFER_SUBINVENTORY           VARCHAR2(10) := FND_API.G_MISS_CHAR,
       TRANSFER_ORGANIZATION           NUMBER := FND_API.G_MISS_NUM,
       TRANSFER_TO_LOCATION            NUMBER := FND_API.G_MISS_NUM,
       NEW_AVERAGE_COST                NUMBER := FND_API.G_MISS_NUM,
       VALUE_CHANGE                    NUMBER := FND_API.G_MISS_NUM,
       PERCENTAGE_CHANGE               NUMBER := FND_API.G_MISS_NUM,
       MATERIAL_ALLOCATION_TEMP_ID     NUMBER := FND_API.G_MISS_NUM,
       DEMAND_SOURCE_HEADER_ID         NUMBER := FND_API.G_MISS_NUM,
       DEMAND_SOURCE_LINE              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       DEMAND_SOURCE_DELIVERY          VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ITEM_SEGMENTS                   VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ITEM_DESCRIPTION                VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ITEM_TRX_ENABLED_FLAG           VARCHAR2(1) := FND_API.G_MISS_CHAR,
       ITEM_LOCATION_CONTROL_CODE      NUMBER := FND_API.G_MISS_NUM,
       ITEM_RESTRICT_SUBINV_CODE       NUMBER := FND_API.G_MISS_NUM,
       ITEM_RESTRICT_LOCATORS_CODE     NUMBER := FND_API.G_MISS_NUM,
       ITEM_REVISION_QTY_CONTROL_CODE  NUMBER := FND_API.G_MISS_NUM,
       ITEM_PRIMARY_UOM_CODE           VARCHAR2(3) := FND_API.G_MISS_CHAR,
       ITEM_UOM_CLASS                  VARCHAR2(10) := FND_API.G_MISS_CHAR,
       ITEM_SHELF_LIFE_CODE            NUMBER := FND_API.G_MISS_NUM,
       ITEM_SHELF_LIFE_DAYS            NUMBER := FND_API.G_MISS_NUM,
       ITEM_LOT_CONTROL_CODE           NUMBER := FND_API.G_MISS_NUM,
       ITEM_SERIAL_CONTROL_CODE        NUMBER := FND_API.G_MISS_NUM,
       ITEM_INVENTORY_ASSET_FLAG       VARCHAR2(1) := FND_API.G_MISS_CHAR,
       ALLOWED_UNITS_LOOKUP_CODE       NUMBER := FND_API.G_MISS_NUM,
       DEPARTMENT_ID                   NUMBER := FND_API.G_MISS_NUM,
       DEPARTMENT_CODE                 VARCHAR2(10) := FND_API.G_MISS_CHAR,
       WIP_SUPPLY_TYPE                 NUMBER := FND_API.G_MISS_NUM,
       SUPPLY_SUBINVENTORY             VARCHAR2(10) := FND_API.G_MISS_CHAR,
       SUPPLY_LOCATOR_ID               NUMBER := FND_API.G_MISS_NUM,
       VALID_SUBINVENTORY_FLAG         VARCHAR2(1) := FND_API.G_MISS_CHAR,
       VALID_LOCATOR_FLAG              VARCHAR2(1) := FND_API.G_MISS_CHAR,
       LOCATOR_SEGMENTS                VARCHAR2(240) := FND_API.G_MISS_CHAR,
       CURRENT_LOCATOR_CONTROL_CODE    NUMBER := FND_API.G_MISS_NUM,
       NUMBER_OF_LOTS_ENTERED          NUMBER := FND_API.G_MISS_NUM,
       WIP_COMMIT_FLAG                 VARCHAR2(1) := FND_API.G_MISS_CHAR,
       NEXT_LOT_NUMBER                 VARCHAR2(80) := FND_API.G_MISS_CHAR,
       LOT_ALPHA_PREFIX                VARCHAR2(30) := FND_API.G_MISS_CHAR,
       NEXT_SERIAL_NUMBER              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       SERIAL_ALPHA_PREFIX             VARCHAR2(30) := FND_API.G_MISS_CHAR,
       SHIPPABLE_FLAG                  VARCHAR2(1) := FND_API.G_MISS_CHAR,
       POSTING_FLAG                    VARCHAR2(1) := FND_API.G_MISS_CHAR,
       REQUIRED_FLAG                   VARCHAR2(1) := FND_API.G_MISS_CHAR,
       PROCESS_FLAG                    VARCHAR2(1) := FND_API.G_MISS_CHAR,
       ERROR_CODE                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ERROR_EXPLANATION               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE_CATEGORY              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ATTRIBUTE1                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE15                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       MOVEMENT_ID                     NUMBER := FND_API.G_MISS_NUM,
       RESERVATION_QUANTITY            NUMBER := FND_API.G_MISS_NUM,
       SHIPPED_QUANTITY                NUMBER := FND_API.G_MISS_NUM,
       TRANSACTION_LINE_NUMBER         NUMBER := FND_API.G_MISS_NUM,
       TASK_ID                         NUMBER := FND_API.G_MISS_NUM,
       TO_TASK_ID                      NUMBER := FND_API.G_MISS_NUM,
       SOURCE_TASK_ID                  NUMBER := FND_API.G_MISS_NUM,
       PROJECT_ID                      NUMBER := FND_API.G_MISS_NUM,
       SOURCE_PROJECT_ID               NUMBER := FND_API.G_MISS_NUM,
       PA_EXPENDITURE_ORG_ID           NUMBER := FND_API.G_MISS_NUM,
       TO_PROJECT_ID                   NUMBER := FND_API.G_MISS_NUM,
       EXPENDITURE_TYPE                VARCHAR2(30) := FND_API.G_MISS_CHAR,
       FINAL_COMPLETION_FLAG           VARCHAR2(1) := FND_API.G_MISS_CHAR,
       TRANSFER_PERCENTAGE             NUMBER := FND_API.G_MISS_NUM,
       TRANSACTION_SEQUENCE_ID         NUMBER := FND_API.G_MISS_NUM,
       MATERIAL_ACCOUNT                NUMBER := FND_API.G_MISS_NUM,
       MATERIAL_OVERHEAD_ACCOUNT       NUMBER := FND_API.G_MISS_NUM,
       RESOURCE_ACCOUNT                NUMBER := FND_API.G_MISS_NUM,
       OUTSIDE_PROCESSING_ACCOUNT      NUMBER := FND_API.G_MISS_NUM,
       OVERHEAD_ACCOUNT                NUMBER := FND_API.G_MISS_NUM,
       FLOW_SCHEDULE                   VARCHAR2(1) := FND_API.G_MISS_CHAR,
       COST_GROUP_ID                   NUMBER := FND_API.G_MISS_NUM,
       DEMAND_CLASS                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       QA_COLLECTION_ID                NUMBER := FND_API.G_MISS_NUM,
       KANBAN_CARD_ID                  NUMBER := FND_API.G_MISS_NUM,
       OVERCOMPLETION_TRANSACTION_ID   NUMBER := FND_API.G_MISS_NUM,
       OVERCOMPLETION_PRIMARY_QTY      NUMBER := FND_API.G_MISS_NUM,
       OVERCOMPLETION_TRANSACTION_QTY  NUMBER := FND_API.G_MISS_NUM,
       --PROCESS_TYPE                    NUMBER := FND_API.G_MISS_NUM,  --removed 01/13/00. process_type does not exist in the mmtt table.
       END_ITEM_UNIT_NUMBER            VARCHAR2(60) := FND_API.G_MISS_CHAR,
       SCHEDULED_PAYBACK_DATE          DATE := FND_API.G_MISS_DATE,
       LINE_TYPE_CODE                  NUMBER := FND_API.G_MISS_NUM,
       PARENT_TRANSACTION_TEMP_ID      NUMBER := FND_API.G_MISS_NUM,
       PUT_AWAY_STRATEGY_ID            NUMBER := FND_API.G_MISS_NUM,
       PUT_AWAY_RULE_ID                NUMBER := FND_API.G_MISS_NUM,
       PICK_STRATEGY_ID                NUMBER := FND_API.G_MISS_NUM,
       PICK_RULE_ID                    NUMBER := FND_API.G_MISS_NUM,
       COMMON_BOM_SEQ_ID               NUMBER := FND_API.G_MISS_NUM,
       COMMON_ROUTING_SEQ_ID           NUMBER := FND_API.G_MISS_NUM,
       COST_TYPE_ID                    NUMBER := FND_API.G_MISS_NUM,
       ORG_COST_GROUP_ID               NUMBER := FND_API.G_MISS_NUM,
       MOVE_ORDER_LINE_ID              NUMBER := FND_API.G_MISS_NUM,
       TASK_GROUP_ID                   NUMBER := FND_API.G_MISS_NUM,
       PICK_SLIP_NUMBER                NUMBER := FND_API.G_MISS_NUM,
       RESERVATION_ID                  NUMBER := FND_API.G_MISS_NUM,
       TRANSACTION_STATUS              NUMBER := FND_API.G_MISS_NUM,
       STANDARD_OPERATION_ID           NUMBER := FND_API.G_MISS_NUM,
       TASK_PRIORITY                   NUMBER := FND_API.G_MISS_NUM,
       -- ADDED by phegde 02/23
       WMS_TASK_TYPE                   NUMBER := FND_API.G_MISS_NUM,
       PARENT_LINE_ID                  NUMBER := FND_API.G_MISS_NUM
      -- SOURCE_LOT_NUMBER               VARCHAR2(30) := FND_API.G_MISS_CHAR
);

G_MISS_CSP_REC          CSP_Rec_Type;

TYPE  CSP_Tbl_Type      IS TABLE OF CSP_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_CSP_TBL          CSP_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_material_transactions
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_CSP_Rec     IN CSP_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_material_transactions(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_CSP_Rec     IN    CSP_Rec_Type  := G_MISS_CSP_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_TRANSACTION_TEMP_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_material_transactions
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_CSP_Rec     IN CSP_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_material_transactions(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    --P_Identity_Salesforce_Id     IN   NUMBER       := NULL,
    P_CSP_Rec     IN    CSP_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_material_transactions
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_CSP_Rec     IN CSP_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_material_transactions(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    --P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_CSP_Rec     IN CSP_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

End CSP_MATERIAL_TRANSACTIONS_PVT;

 

/
