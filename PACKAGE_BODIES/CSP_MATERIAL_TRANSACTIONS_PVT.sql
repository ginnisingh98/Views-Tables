--------------------------------------------------------
--  DDL for Package Body CSP_MATERIAL_TRANSACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_MATERIAL_TRANSACTIONS_PVT" AS
/* $Header: cspvmmtb.pls 120.1 2006/07/20 06:03:50 hhaugeru noship $ */
-- Start of Comments
-- Package name     : CSP_MATERIAL_TRANSACTIONS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_MATERIAL_TRANSACTIONS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspvmmtb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.LOGIN_ID;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_material_transactions(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_CSP_Rec     IN    CSP_Rec_Type  := G_MISS_CSP_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_TRANSACTION_TEMP_ID        OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'CREATE_MATERIAL_TXN';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
--l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_MATERIAL_TXN_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Debug Message
      -- JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Create_material_transactions_BC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_CSP_Rec      =>  P_CSP_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


     /* AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
          p_api_version_number => 2.0
         ,p_salesforce_id => NULL
         ,x_return_status => x_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
         ,x_sales_member_rec => l_identity_sales_member_rec);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
    */

/*      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_material_transactions');

          -- Invoke validation procedures
        Validate_material_transactions(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => JTF_PLSQL_API.G_CREATE,
              P_CSP_Rec  =>  P_CSP_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
*/
      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
     -- JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling create table handler');

      -- assign p_CSP_rec.transaction_temp_id to x_transaction_temp_id
         x_TRANSACTION_TEMP_ID :=  p_CSP_rec.TRANSACTION_TEMP_ID;

      -- Invoke table handler(MTL_MATERIAL_TRANSACTIONS_TEMP_PKG._Row)
      CSP_MTL_TRANSACTIONS_PKG.Insert_Row(
          p_TRANSACTION_HEADER_ID  => p_CSP_rec.TRANSACTION_HEADER_ID,
          px_TRANSACTION_TEMP_ID  => x_TRANSACTION_TEMP_ID,
          p_SOURCE_CODE  => p_CSP_rec.SOURCE_CODE,
          p_SOURCE_LINE_ID  => p_CSP_rec.SOURCE_LINE_ID,
          p_TRANSACTION_MODE  => p_CSP_rec.TRANSACTION_MODE,
          p_LOCK_FLAG  => p_CSP_rec.LOCK_FLAG,
          p_LAST_UPDATE_DATE  => p_CSP_rec.LAST_UPDATE_DATE,
          p_LAST_UPDATED_BY  => p_CSP_rec.LAST_UPDATED_BY,
          p_CREATION_DATE  => p_CSP_rec.CREATION_DATE,
          p_CREATED_BY  => p_CSP_rec.CREATED_BY,
          p_LAST_UPDATE_LOGIN  => p_CSP_rec.LAST_UPDATE_LOGIN,
          p_REQUEST_ID  => p_CSP_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => p_CSP_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => p_CSP_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => p_CSP_rec.PROGRAM_UPDATE_DATE,
          p_INVENTORY_ITEM_ID  => p_CSP_rec.INVENTORY_ITEM_ID,
          p_REVISION  => p_CSP_rec.REVISION,
          p_ORGANIZATION_ID  => p_CSP_rec.ORGANIZATION_ID,
          p_SUBINVENTORY_CODE  => p_CSP_rec.SUBINVENTORY_CODE,
          p_LOCATOR_ID  => p_CSP_rec.LOCATOR_ID,
          p_TRANSACTION_QUANTITY  => p_CSP_rec.TRANSACTION_QUANTITY,
          p_PRIMARY_QUANTITY  => p_CSP_rec.PRIMARY_QUANTITY,
          p_TRANSACTION_UOM  => p_CSP_rec.TRANSACTION_UOM,
          p_TRANSACTION_COST  => p_CSP_rec.TRANSACTION_COST,
          p_TRANSACTION_TYPE_ID  => p_CSP_rec.TRANSACTION_TYPE_ID,
          p_TRANSACTION_ACTION_ID  => p_CSP_rec.TRANSACTION_ACTION_ID,
          p_TRANSACTION_SOURCE_TYPE_ID  => p_CSP_rec.TRANSACTION_SOURCE_TYPE_ID,
          p_TRANSACTION_SOURCE_ID  => p_CSP_rec.TRANSACTION_SOURCE_ID,
          p_TRANSACTION_SOURCE_NAME  => p_CSP_rec.TRANSACTION_SOURCE_NAME,
          p_TRANSACTION_DATE  => p_CSP_rec.TRANSACTION_DATE,
          p_ACCT_PERIOD_ID  => p_CSP_rec.ACCT_PERIOD_ID,
          p_DISTRIBUTION_ACCOUNT_ID  => p_CSP_rec.DISTRIBUTION_ACCOUNT_ID,
          p_TRANSACTION_REFERENCE  => p_CSP_rec.TRANSACTION_REFERENCE,
          p_REQUISITION_LINE_ID  => p_CSP_rec.REQUISITION_LINE_ID,
          p_REQUISITION_DISTRIBUTION_ID  => p_CSP_rec.REQUISITION_DISTRIBUTION_ID,
          p_REASON_ID  => p_CSP_rec.REASON_ID,
          p_LOT_NUMBER  => p_CSP_rec.LOT_NUMBER,
          p_LOT_EXPIRATION_DATE  => p_CSP_rec.LOT_EXPIRATION_DATE,
          p_SERIAL_NUMBER  => p_CSP_rec.SERIAL_NUMBER,
          p_RECEIVING_DOCUMENT  => p_CSP_rec.RECEIVING_DOCUMENT,
          p_DEMAND_ID  => p_CSP_rec.DEMAND_ID,
          p_RCV_TRANSACTION_ID  => p_CSP_rec.RCV_TRANSACTION_ID,
          p_MOVE_TRANSACTION_ID  => p_CSP_rec.MOVE_TRANSACTION_ID,
          p_COMPLETION_TRANSACTION_ID  => p_CSP_rec.COMPLETION_TRANSACTION_ID,
          p_WIP_ENTITY_TYPE  => p_CSP_rec.WIP_ENTITY_TYPE,
          p_SCHEDULE_ID  => p_CSP_rec.SCHEDULE_ID,
          p_REPETITIVE_LINE_ID  => p_CSP_rec.REPETITIVE_LINE_ID,
          p_EMPLOYEE_CODE  => p_CSP_rec.EMPLOYEE_CODE,
          p_PRIMARY_SWITCH  => p_CSP_rec.PRIMARY_SWITCH,
          p_SCHEDULE_UPDATE_CODE  => p_CSP_rec.SCHEDULE_UPDATE_CODE,
          p_SETUP_TEARDOWN_CODE  => p_CSP_rec.SETUP_TEARDOWN_CODE,
          p_ITEM_ORDERING  => p_CSP_rec.ITEM_ORDERING,
          p_NEGATIVE_REQ_FLAG  => p_CSP_rec.NEGATIVE_REQ_FLAG,
          p_OPERATION_SEQ_NUM  => p_CSP_rec.OPERATION_SEQ_NUM,
          p_PICKING_LINE_ID  => p_CSP_rec.PICKING_LINE_ID,
          p_TRX_SOURCE_LINE_ID  => p_CSP_rec.TRX_SOURCE_LINE_ID,
          p_TRX_SOURCE_DELIVERY_ID  => p_CSP_rec.TRX_SOURCE_DELIVERY_ID,
          p_PHYSICAL_ADJUSTMENT_ID  => p_CSP_rec.PHYSICAL_ADJUSTMENT_ID,
          p_CYCLE_COUNT_ID  => p_CSP_rec.CYCLE_COUNT_ID,
          p_RMA_LINE_ID  => p_CSP_rec.RMA_LINE_ID,
          p_CUSTOMER_SHIP_ID  => p_CSP_rec.CUSTOMER_SHIP_ID,
          p_CURRENCY_CODE  => p_CSP_rec.CURRENCY_CODE,
          p_CURRENCY_CONVERSION_RATE  => p_CSP_rec.CURRENCY_CONVERSION_RATE,
          p_CURRENCY_CONVERSION_TYPE  => p_CSP_rec.CURRENCY_CONVERSION_TYPE,
          p_CURRENCY_CONVERSION_DATE  => p_CSP_rec.CURRENCY_CONVERSION_DATE,
          p_USSGL_TRANSACTION_CODE  => p_CSP_rec.USSGL_TRANSACTION_CODE,
          p_VENDOR_LOT_NUMBER  => p_CSP_rec.VENDOR_LOT_NUMBER,
          p_ENCUMBRANCE_ACCOUNT  => p_CSP_rec.ENCUMBRANCE_ACCOUNT,
          p_ENCUMBRANCE_AMOUNT  => p_CSP_rec.ENCUMBRANCE_AMOUNT,
          p_SHIP_TO_LOCATION  => p_CSP_rec.SHIP_TO_LOCATION,
          p_SHIPMENT_NUMBER  => p_CSP_rec.SHIPMENT_NUMBER,
          p_TRANSFER_COST  => p_CSP_rec.TRANSFER_COST,
          p_TRANSPORTATION_COST  => p_CSP_rec.TRANSPORTATION_COST,
          p_TRANSPORTATION_ACCOUNT  => p_CSP_rec.TRANSPORTATION_ACCOUNT,
          p_FREIGHT_CODE  => p_CSP_rec.FREIGHT_CODE,
          p_CONTAINERS  => p_CSP_rec.CONTAINERS,
          p_WAYBILL_AIRBILL  => p_CSP_rec.WAYBILL_AIRBILL,
          p_EXPECTED_ARRIVAL_DATE  => p_CSP_rec.EXPECTED_ARRIVAL_DATE,
          p_TRANSFER_SUBINVENTORY  => p_CSP_rec.TRANSFER_SUBINVENTORY,
          p_TRANSFER_ORGANIZATION  => p_CSP_rec.TRANSFER_ORGANIZATION,
          p_TRANSFER_TO_LOCATION  => p_CSP_rec.TRANSFER_TO_LOCATION,
          p_NEW_AVERAGE_COST  => p_CSP_rec.NEW_AVERAGE_COST,
          p_VALUE_CHANGE  => p_CSP_rec.VALUE_CHANGE,
          p_PERCENTAGE_CHANGE  => p_CSP_rec.PERCENTAGE_CHANGE,
          p_MATERIAL_ALLOCATION_TEMP_ID  => p_CSP_rec.MATERIAL_ALLOCATION_TEMP_ID,
          p_DEMAND_SOURCE_HEADER_ID  => p_CSP_rec.DEMAND_SOURCE_HEADER_ID,
          p_DEMAND_SOURCE_LINE  => p_CSP_rec.DEMAND_SOURCE_LINE,
          p_DEMAND_SOURCE_DELIVERY  => p_CSP_rec.DEMAND_SOURCE_DELIVERY,
          p_ITEM_SEGMENTS  => p_CSP_rec.ITEM_SEGMENTS,
          p_ITEM_DESCRIPTION  => p_CSP_rec.ITEM_DESCRIPTION,
          p_ITEM_TRX_ENABLED_FLAG  => p_CSP_rec.ITEM_TRX_ENABLED_FLAG,
          p_ITEM_LOCATION_CONTROL_CODE  => p_CSP_rec.ITEM_LOCATION_CONTROL_CODE,
          p_ITEM_RESTRICT_SUBINV_CODE  => p_CSP_rec.ITEM_RESTRICT_SUBINV_CODE,
          p_ITEM_RESTRICT_LOCATORS_CODE  => p_CSP_rec.ITEM_RESTRICT_LOCATORS_CODE,
          p_ITEM_REV_QTY_CONTROL_CODE  => p_CSP_rec.ITEM_REVISION_QTY_CONTROL_CODE,
          p_ITEM_PRIMARY_UOM_CODE  => p_CSP_rec.ITEM_PRIMARY_UOM_CODE,
          p_ITEM_UOM_CLASS  => p_CSP_rec.ITEM_UOM_CLASS,
          p_ITEM_SHELF_LIFE_CODE  => p_CSP_rec.ITEM_SHELF_LIFE_CODE,
          p_ITEM_SHELF_LIFE_DAYS  => p_CSP_rec.ITEM_SHELF_LIFE_DAYS,
          p_ITEM_LOT_CONTROL_CODE  => p_CSP_rec.ITEM_LOT_CONTROL_CODE,
          p_ITEM_SERIAL_CONTROL_CODE  => p_CSP_rec.ITEM_SERIAL_CONTROL_CODE,
          p_ITEM_INVENTORY_ASSET_FLAG  => p_CSP_rec.ITEM_INVENTORY_ASSET_FLAG,
          p_ALLOWED_UNITS_LOOKUP_CODE  => p_CSP_rec.ALLOWED_UNITS_LOOKUP_CODE,
          p_DEPARTMENT_ID  => p_CSP_rec.DEPARTMENT_ID,
          p_DEPARTMENT_CODE  => p_CSP_rec.DEPARTMENT_CODE,
          p_WIP_SUPPLY_TYPE  => p_CSP_rec.WIP_SUPPLY_TYPE,
          p_SUPPLY_SUBINVENTORY  => p_CSP_rec.SUPPLY_SUBINVENTORY,
          p_SUPPLY_LOCATOR_ID  => p_CSP_rec.SUPPLY_LOCATOR_ID,
          p_VALID_SUBINVENTORY_FLAG  => p_CSP_rec.VALID_SUBINVENTORY_FLAG,
          p_VALID_LOCATOR_FLAG  => p_CSP_rec.VALID_LOCATOR_FLAG,
          p_LOCATOR_SEGMENTS  => p_CSP_rec.LOCATOR_SEGMENTS,
          p_CURRENT_LOCATOR_CONTROL_CODE  => p_CSP_rec.CURRENT_LOCATOR_CONTROL_CODE,
          p_NUMBER_OF_LOTS_ENTERED  => p_CSP_rec.NUMBER_OF_LOTS_ENTERED,
          p_WIP_COMMIT_FLAG  => p_CSP_rec.WIP_COMMIT_FLAG,
          p_NEXT_LOT_NUMBER  => p_CSP_rec.NEXT_LOT_NUMBER,
          p_LOT_ALPHA_PREFIX  => p_CSP_rec.LOT_ALPHA_PREFIX,
          p_NEXT_SERIAL_NUMBER  => p_CSP_rec.NEXT_SERIAL_NUMBER,
          p_SERIAL_ALPHA_PREFIX  => p_CSP_rec.SERIAL_ALPHA_PREFIX,
          p_SHIPPABLE_FLAG  => p_CSP_rec.SHIPPABLE_FLAG,
          p_POSTING_FLAG  => p_CSP_rec.POSTING_FLAG,
          p_REQUIRED_FLAG  => p_CSP_rec.REQUIRED_FLAG,
          p_PROCESS_FLAG  => p_CSP_rec.PROCESS_FLAG,
          p_ERROR_CODE  => p_CSP_rec.ERROR_CODE,
          p_ERROR_EXPLANATION  => p_CSP_rec.ERROR_EXPLANATION,
          p_ATTRIBUTE_CATEGORY  => p_CSP_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_CSP_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_CSP_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_CSP_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_CSP_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_CSP_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_CSP_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_CSP_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_CSP_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_CSP_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_CSP_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_CSP_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_CSP_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_CSP_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_CSP_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_CSP_rec.ATTRIBUTE15,
          p_MOVEMENT_ID  => p_CSP_rec.MOVEMENT_ID,
          p_RESERVATION_QUANTITY  => p_CSP_rec.RESERVATION_QUANTITY,
          p_SHIPPED_QUANTITY  => p_CSP_rec.SHIPPED_QUANTITY,
          p_TRANSACTION_LINE_NUMBER  => p_CSP_rec.TRANSACTION_LINE_NUMBER,
          p_TASK_ID  => p_CSP_rec.TASK_ID,
          p_TO_TASK_ID  => p_CSP_rec.TO_TASK_ID,
          p_SOURCE_TASK_ID  => p_CSP_rec.SOURCE_TASK_ID,
          p_PROJECT_ID  => p_CSP_rec.PROJECT_ID,
          p_SOURCE_PROJECT_ID  => p_CSP_rec.SOURCE_PROJECT_ID,
          p_PA_EXPENDITURE_ORG_ID  => p_CSP_rec.PA_EXPENDITURE_ORG_ID,
          p_TO_PROJECT_ID  => p_CSP_rec.TO_PROJECT_ID,
          p_EXPENDITURE_TYPE  => p_CSP_rec.EXPENDITURE_TYPE,
          p_FINAL_COMPLETION_FLAG  => p_CSP_rec.FINAL_COMPLETION_FLAG,
          p_TRANSFER_PERCENTAGE  => p_CSP_rec.TRANSFER_PERCENTAGE,
          p_TRANSACTION_SEQUENCE_ID  => p_CSP_rec.TRANSACTION_SEQUENCE_ID,
          p_MATERIAL_ACCOUNT  => p_CSP_rec.MATERIAL_ACCOUNT,
          p_MATERIAL_OVERHEAD_ACCOUNT  => p_CSP_rec.MATERIAL_OVERHEAD_ACCOUNT,
          p_RESOURCE_ACCOUNT  => p_CSP_rec.RESOURCE_ACCOUNT,
          p_OUTSIDE_PROCESSING_ACCOUNT  => p_CSP_rec.OUTSIDE_PROCESSING_ACCOUNT,
          p_OVERHEAD_ACCOUNT  => p_CSP_rec.OVERHEAD_ACCOUNT,
          p_FLOW_SCHEDULE  => p_CSP_rec.FLOW_SCHEDULE,
          p_COST_GROUP_ID  => p_CSP_rec.COST_GROUP_ID,
          p_DEMAND_CLASS  => p_CSP_rec.DEMAND_CLASS,
          p_QA_COLLECTION_ID  => p_CSP_rec.QA_COLLECTION_ID,
          p_KANBAN_CARD_ID  => p_CSP_rec.KANBAN_CARD_ID,
          p_OVERCOMPLETION_TXN_ID  => p_CSP_rec.OVERCOMPLETION_TRANSACTION_ID,
          p_OVERCOMPLETION_PRIMARY_QTY  => p_CSP_rec.OVERCOMPLETION_PRIMARY_QTY,
          p_OVERCOMPLETION_TXN_QTY  => p_CSP_rec.OVERCOMPLETION_TRANSACTION_QTY,
          -- p_PROCESS_TYPE  => p_CSP_rec.PROCESS_TYPE,
          p_END_ITEM_UNIT_NUMBER  => p_CSP_rec.END_ITEM_UNIT_NUMBER,
          p_SCHEDULED_PAYBACK_DATE  => p_CSP_rec.SCHEDULED_PAYBACK_DATE,
          p_LINE_TYPE_CODE  => p_CSP_rec.LINE_TYPE_CODE,
          p_PARENT_TRANSACTION_TEMP_ID  => p_CSP_rec.PARENT_TRANSACTION_TEMP_ID,
          p_PUT_AWAY_STRATEGY_ID  => p_CSP_rec.PUT_AWAY_STRATEGY_ID,
          p_PUT_AWAY_RULE_ID  => p_CSP_rec.PUT_AWAY_RULE_ID,
          p_PICK_STRATEGY_ID  => p_CSP_rec.PICK_STRATEGY_ID,
          p_PICK_RULE_ID  => p_CSP_rec.PICK_RULE_ID,
          p_COMMON_BOM_SEQ_ID  => p_CSP_rec.COMMON_BOM_SEQ_ID,
          p_COMMON_ROUTING_SEQ_ID  => p_CSP_rec.COMMON_ROUTING_SEQ_ID,
          p_COST_TYPE_ID  => p_CSP_rec.COST_TYPE_ID,
          p_ORG_COST_GROUP_ID  => p_CSP_rec.ORG_COST_GROUP_ID,
          p_MOVE_ORDER_LINE_ID  => p_CSP_rec.MOVE_ORDER_LINE_ID,
          p_TASK_GROUP_ID  => p_CSP_rec.TASK_GROUP_ID,
          p_PICK_SLIP_NUMBER  => p_CSP_rec.PICK_SLIP_NUMBER,
          p_RESERVATION_ID  => p_CSP_rec.RESERVATION_ID,
          p_TRANSACTION_STATUS  => p_CSP_rec.TRANSACTION_STATUS,
          p_STANDARD_OPERATION_ID  => p_CSP_rec.STANDARD_OPERATION_ID,
          p_TASK_PRIORITY  => p_CSP_rec.TASK_PRIORITY,
          p_WMS_TASK_TYPE => p_CSP_rec.WMS_TASK_TYPE,
          p_PARENT_LINE_ID => p_CSP_rec.PARENT_LINE_ID);
--        P_SOURCE_LOT_NUMBER => p_CSP_rec.SOURCE_LOT_NUMBER);
      -- Hint: Primary key should be returned.
      -- x_TRANSACTION_TEMP_ID := px_TRANSACTION_TEMP_ID;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      -- JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Create_material_transactions_AC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_CSP_Rec      =>  P_CSP_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
       EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_material_transactions;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_material_transactions(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_CSP_Rec                    IN   CSP_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
/*
Cursor C_Get_material_transactions(TRANSACTION_HEADER_ID Number) IS
    Select rowid,
           TRANSACTION_HEADER_ID,
           TRANSACTION_TEMP_ID,
           SOURCE_CODE,
           SOURCE_LINE_ID,
           TRANSACTION_MODE,
           LOCK_FLAG,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           INVENTORY_ITEM_ID,
           REVISION,
           ORGANIZATION_ID,
           SUBINVENTORY_CODE,
           LOCATOR_ID,
           TRANSACTION_QUANTITY,
           PRIMARY_QUANTITY,
           TRANSACTION_UOM,
           TRANSACTION_COST,
           TRANSACTION_TYPE_ID,
           TRANSACTION_ACTION_ID,
           TRANSACTION_SOURCE_TYPE_ID,
           TRANSACTION_SOURCE_ID,
           TRANSACTION_SOURCE_NAME,
           TRANSACTION_DATE,
           ACCT_PERIOD_ID,
           DISTRIBUTION_ACCOUNT_ID,
           TRANSACTION_REFERENCE,
           REQUISITION_LINE_ID,
           REQUISITION_DISTRIBUTION_ID,
           REASON_ID,
           LOT_NUMBER,
           LOT_EXPIRATION_DATE,
           SERIAL_NUMBER,
           RECEIVING_DOCUMENT,
           DEMAND_ID,
           RCV_TRANSACTION_ID,
           MOVE_TRANSACTION_ID,
           COMPLETION_TRANSACTION_ID,
           WIP_ENTITY_TYPE,
           SCHEDULE_ID,
           REPETITIVE_LINE_ID,
           EMPLOYEE_CODE,
           PRIMARY_SWITCH,
           SCHEDULE_UPDATE_CODE,
           SETUP_TEARDOWN_CODE,
           ITEM_ORDERING,
           NEGATIVE_REQ_FLAG,
           OPERATION_SEQ_NUM,
           PICKING_LINE_ID,
           TRX_SOURCE_LINE_ID,
           TRX_SOURCE_DELIVERY_ID,
           PHYSICAL_ADJUSTMENT_ID,
           CYCLE_COUNT_ID,
           RMA_LINE_ID,
           CUSTOMER_SHIP_ID,
           CURRENCY_CODE,
           CURRENCY_CONVERSION_RATE,
           CURRENCY_CONVERSION_TYPE,
           CURRENCY_CONVERSION_DATE,
           USSGL_TRANSACTION_CODE,
           VENDOR_LOT_NUMBER,
           ENCUMBRANCE_ACCOUNT,
           ENCUMBRANCE_AMOUNT,
           SHIP_TO_LOCATION,
           SHIPMENT_NUMBER,
           TRANSFER_COST,
           TRANSPORTATION_COST,
           TRANSPORTATION_ACCOUNT,
           FREIGHT_CODE,
           CONTAINERS,
           WAYBILL_AIRBILL,
           EXPECTED_ARRIVAL_DATE,
           TRANSFER_SUBINVENTORY,
           TRANSFER_ORGANIZATION,
           TRANSFER_TO_LOCATION,
           NEW_AVERAGE_COST,
           VALUE_CHANGE,
           PERCENTAGE_CHANGE,
           MATERIAL_ALLOCATION_TEMP_ID,
           DEMAND_SOURCE_HEADER_ID,
           DEMAND_SOURCE_LINE,
           DEMAND_SOURCE_DELIVERY,
           ITEM_SEGMENTS,
           ITEM_DESCRIPTION,
           ITEM_TRX_ENABLED_FLAG,
           ITEM_LOCATION_CONTROL_CODE,
           ITEM_RESTRICT_SUBINV_CODE,
           ITEM_RESTRICT_LOCATORS_CODE,
           ITEM_REVISION_QTY_CONTROL_CODE,
           ITEM_PRIMARY_UOM_CODE,
           ITEM_UOM_CLASS,
           ITEM_SHELF_LIFE_CODE,
           ITEM_SHELF_LIFE_DAYS,
           ITEM_LOT_CONTROL_CODE,
           ITEM_SERIAL_CONTROL_CODE,
           ITEM_INVENTORY_ASSET_FLAG,
           ALLOWED_UNITS_LOOKUP_CODE,
           DEPARTMENT_ID,
           DEPARTMENT_CODE,
           WIP_SUPPLY_TYPE,
           SUPPLY_SUBINVENTORY,
           SUPPLY_LOCATOR_ID,
           VALID_SUBINVENTORY_FLAG,
           VALID_LOCATOR_FLAG,
           LOCATOR_SEGMENTS,
           CURRENT_LOCATOR_CONTROL_CODE,
           NUMBER_OF_LOTS_ENTERED,
           WIP_COMMIT_FLAG,
           NEXT_LOT_NUMBER,
           LOT_ALPHA_PREFIX,
           NEXT_SERIAL_NUMBER,
           SERIAL_ALPHA_PREFIX,
           SHIPPABLE_FLAG,
           POSTING_FLAG,
           REQUIRED_FLAG,
           PROCESS_FLAG,
           ERROR_CODE,
           ERROR_EXPLANATION,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           MOVEMENT_ID,
           RESERVATION_QUANTITY,
           SHIPPED_QUANTITY,
           TRANSACTION_LINE_NUMBER,
           TASK_ID,
           TO_TASK_ID,
           SOURCE_TASK_ID,
           PROJECT_ID,
           SOURCE_PROJECT_ID,
           PA_EXPENDITURE_ORG_ID,
           TO_PROJECT_ID,
           EXPENDITURE_TYPE,
           FINAL_COMPLETION_FLAG,
           TRANSFER_PERCENTAGE,
           TRANSACTION_SEQUENCE_ID,
           MATERIAL_ACCOUNT,
           MATERIAL_OVERHEAD_ACCOUNT,
           RESOURCE_ACCOUNT,
           OUTSIDE_PROCESSING_ACCOUNT,
           OVERHEAD_ACCOUNT,
           FLOW_SCHEDULE,
           COST_GROUP_ID,
           DEMAND_CLASS,
           QA_COLLECTION_ID,
           KANBAN_CARD_ID,
           OVERCOMPLETION_TRANSACTION_ID,
           OVERCOMPLETION_PRIMARY_QTY,
           OVERCOMPLETION_TRANSACTION_QTY,
           PROCESS_TYPE,
           END_ITEM_UNIT_NUMBER,
           SCHEDULED_PAYBACK_DATE,
           LINE_TYPE_CODE,
           PARENT_TRANSACTION_TEMP_ID,
           PUT_AWAY_STRATEGY_ID,
           PUT_AWAY_RULE_ID,
           PICK_STRATEGY_ID,
           PICK_RULE_ID,
           COMMON_BOM_SEQ_ID,
           COMMON_ROUTING_SEQ_ID,
           COST_TYPE_ID,
           ORG_COST_GROUP_ID,
           MOVE_ORDER_LINE_ID,
           TASK_GROUP_ID,
           PICK_SLIP_NUMBER,
           RESERVATION_ID,
           TRANSACTION_STATUS
    From  MTL_MATERIAL_TRANSACTIONS_TEMP
    -- Hint: Developer need to provide Where clause
    For Update NOWAIT;
*/
l_api_name                CONSTANT VARCHAR2(30) := 'UPDATE_MATERIAL_TXN';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
--l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_ref_CSP_rec  CSP_material_transactions_PVT.CSP_Rec_Type;
l_tar_CSP_rec  CSP_material_transactions_PVT.CSP_Rec_Type := P_CSP_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_MATERIAL_TXN_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Update_material_transactions_BU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_CSP_Rec      =>  P_CSP_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/

 /*     AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
          p_api_version_number => 2.0
         ,p_salesforce_id => p_identity_salesforce_id
         ,x_return_status => x_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
         ,x_sales_member_rec => l_identity_sales_member_rec);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
*/
      -- Debug Message
     -- JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Open Cursor to Select');

/*
      Open C_Get_material_transactions( l_tar_CSP_rec.TRANSACTION_HEADER_ID);

      Fetch C_Get_material_transactions into
               l_rowid,
               l_ref_CSP_rec.TRANSACTION_HEADER_ID,
               l_ref_CSP_rec.TRANSACTION_TEMP_ID,
               l_ref_CSP_rec.SOURCE_CODE,
               l_ref_CSP_rec.SOURCE_LINE_ID,
               l_ref_CSP_rec.TRANSACTION_MODE,
               l_ref_CSP_rec.LOCK_FLAG,
               l_ref_CSP_rec.LAST_UPDATE_DATE,
               l_ref_CSP_rec.LAST_UPDATED_BY,
               l_ref_CSP_rec.CREATION_DATE,
               l_ref_CSP_rec.CREATED_BY,
               l_ref_CSP_rec.LAST_UPDATE_LOGIN,
               l_ref_CSP_rec.REQUEST_ID,
               l_ref_CSP_rec.PROGRAM_APPLICATION_ID,
               l_ref_CSP_rec.PROGRAM_ID,
               l_ref_CSP_rec.PROGRAM_UPDATE_DATE,
               l_ref_CSP_rec.INVENTORY_ITEM_ID,
               l_ref_CSP_rec.REVISION,
               l_ref_CSP_rec.ORGANIZATION_ID,
               l_ref_CSP_rec.SUBINVENTORY_CODE,
               l_ref_CSP_rec.LOCATOR_ID,
               l_ref_CSP_rec.TRANSACTION_QUANTITY,
               l_ref_CSP_rec.PRIMARY_QUANTITY,
               l_ref_CSP_rec.TRANSACTION_UOM,
               l_ref_CSP_rec.TRANSACTION_COST,
               l_ref_CSP_rec.TRANSACTION_TYPE_ID,
               l_ref_CSP_rec.TRANSACTION_ACTION_ID,
               l_ref_CSP_rec.TRANSACTION_SOURCE_TYPE_ID,
               l_ref_CSP_rec.TRANSACTION_SOURCE_ID,
               l_ref_CSP_rec.TRANSACTION_SOURCE_NAME,
               l_ref_CSP_rec.TRANSACTION_DATE,
               l_ref_CSP_rec.ACCT_PERIOD_ID,
               l_ref_CSP_rec.DISTRIBUTION_ACCOUNT_ID,
               l_ref_CSP_rec.TRANSACTION_REFERENCE,
               l_ref_CSP_rec.REQUISITION_LINE_ID,
               l_ref_CSP_rec.REQUISITION_DISTRIBUTION_ID,
               l_ref_CSP_rec.REASON_ID,
               l_ref_CSP_rec.LOT_NUMBER,
               l_ref_CSP_rec.LOT_EXPIRATION_DATE,
               l_ref_CSP_rec.SERIAL_NUMBER,
               l_ref_CSP_rec.RECEIVING_DOCUMENT,
               l_ref_CSP_rec.DEMAND_ID,
               l_ref_CSP_rec.RCV_TRANSACTION_ID,
               l_ref_CSP_rec.MOVE_TRANSACTION_ID,
               l_ref_CSP_rec.COMPLETION_TRANSACTION_ID,
               l_ref_CSP_rec.WIP_ENTITY_TYPE,
               l_ref_CSP_rec.SCHEDULE_ID,
               l_ref_CSP_rec.REPETITIVE_LINE_ID,
               l_ref_CSP_rec.EMPLOYEE_CODE,
               l_ref_CSP_rec.PRIMARY_SWITCH,
               l_ref_CSP_rec.SCHEDULE_UPDATE_CODE,
               l_ref_CSP_rec.SETUP_TEARDOWN_CODE,
               l_ref_CSP_rec.ITEM_ORDERING,
               l_ref_CSP_rec.NEGATIVE_REQ_FLAG,
               l_ref_CSP_rec.OPERATION_SEQ_NUM,
               l_ref_CSP_rec.PICKING_LINE_ID,
               l_ref_CSP_rec.TRX_SOURCE_LINE_ID,
               l_ref_CSP_rec.TRX_SOURCE_DELIVERY_ID,
               l_ref_CSP_rec.PHYSICAL_ADJUSTMENT_ID,
               l_ref_CSP_rec.CYCLE_COUNT_ID,
               l_ref_CSP_rec.RMA_LINE_ID,
               l_ref_CSP_rec.CUSTOMER_SHIP_ID,
               l_ref_CSP_rec.CURRENCY_CODE,
               l_ref_CSP_rec.CURRENCY_CONVERSION_RATE,
               l_ref_CSP_rec.CURRENCY_CONVERSION_TYPE,
               l_ref_CSP_rec.CURRENCY_CONVERSION_DATE,
               l_ref_CSP_rec.USSGL_TRANSACTION_CODE,
               l_ref_CSP_rec.VENDOR_LOT_NUMBER,
               l_ref_CSP_rec.ENCUMBRANCE_ACCOUNT,
               l_ref_CSP_rec.ENCUMBRANCE_AMOUNT,
               l_ref_CSP_rec.SHIP_TO_LOCATION,
               l_ref_CSP_rec.SHIPMENT_NUMBER,
               l_ref_CSP_rec.TRANSFER_COST,
               l_ref_CSP_rec.TRANSPORTATION_COST,
               l_ref_CSP_rec.TRANSPORTATION_ACCOUNT,
               l_ref_CSP_rec.FREIGHT_CODE,
               l_ref_CSP_rec.CONTAINERS,
               l_ref_CSP_rec.WAYBILL_AIRBILL,
               l_ref_CSP_rec.EXPECTED_ARRIVAL_DATE,
               l_ref_CSP_rec.TRANSFER_SUBINVENTORY,
               l_ref_CSP_rec.TRANSFER_ORGANIZATION,
               l_ref_CSP_rec.TRANSFER_TO_LOCATION,
               l_ref_CSP_rec.NEW_AVERAGE_COST,
               l_ref_CSP_rec.VALUE_CHANGE,
               l_ref_CSP_rec.PERCENTAGE_CHANGE,
               l_ref_CSP_rec.MATERIAL_ALLOCATION_TEMP_ID,
               l_ref_CSP_rec.DEMAND_SOURCE_HEADER_ID,
               l_ref_CSP_rec.DEMAND_SOURCE_LINE,
               l_ref_CSP_rec.DEMAND_SOURCE_DELIVERY,
               l_ref_CSP_rec.ITEM_SEGMENTS,
               l_ref_CSP_rec.ITEM_DESCRIPTION,
               l_ref_CSP_rec.ITEM_TRX_ENABLED_FLAG,
               l_ref_CSP_rec.ITEM_LOCATION_CONTROL_CODE,
               l_ref_CSP_rec.ITEM_RESTRICT_SUBINV_CODE,
               l_ref_CSP_rec.ITEM_RESTRICT_LOCATORS_CODE,
               l_ref_CSP_rec.ITEM_REVISION_QTY_CONTROL_CODE,
               l_ref_CSP_rec.ITEM_PRIMARY_UOM_CODE,
               l_ref_CSP_rec.ITEM_UOM_CLASS,
               l_ref_CSP_rec.ITEM_SHELF_LIFE_CODE,
               l_ref_CSP_rec.ITEM_SHELF_LIFE_DAYS,
               l_ref_CSP_rec.ITEM_LOT_CONTROL_CODE,
               l_ref_CSP_rec.ITEM_SERIAL_CONTROL_CODE,
               l_ref_CSP_rec.ITEM_INVENTORY_ASSET_FLAG,
               l_ref_CSP_rec.ALLOWED_UNITS_LOOKUP_CODE,
               l_ref_CSP_rec.DEPARTMENT_ID,
               l_ref_CSP_rec.DEPARTMENT_CODE,
               l_ref_CSP_rec.WIP_SUPPLY_TYPE,
               l_ref_CSP_rec.SUPPLY_SUBINVENTORY,
               l_ref_CSP_rec.SUPPLY_LOCATOR_ID,
               l_ref_CSP_rec.VALID_SUBINVENTORY_FLAG,
               l_ref_CSP_rec.VALID_LOCATOR_FLAG,
               l_ref_CSP_rec.LOCATOR_SEGMENTS,
               l_ref_CSP_rec.CURRENT_LOCATOR_CONTROL_CODE,
               l_ref_CSP_rec.NUMBER_OF_LOTS_ENTERED,
               l_ref_CSP_rec.WIP_COMMIT_FLAG,
               l_ref_CSP_rec.NEXT_LOT_NUMBER,
               l_ref_CSP_rec.LOT_ALPHA_PREFIX,
               l_ref_CSP_rec.NEXT_SERIAL_NUMBER,
               l_ref_CSP_rec.SERIAL_ALPHA_PREFIX,
               l_ref_CSP_rec.SHIPPABLE_FLAG,
               l_ref_CSP_rec.POSTING_FLAG,
               l_ref_CSP_rec.REQUIRED_FLAG,
               l_ref_CSP_rec.PROCESS_FLAG,
               l_ref_CSP_rec.ERROR_CODE,
               l_ref_CSP_rec.ERROR_EXPLANATION,
               l_ref_CSP_rec.ATTRIBUTE_CATEGORY,
               l_ref_CSP_rec.ATTRIBUTE1,
               l_ref_CSP_rec.ATTRIBUTE2,
               l_ref_CSP_rec.ATTRIBUTE3,
               l_ref_CSP_rec.ATTRIBUTE4,
               l_ref_CSP_rec.ATTRIBUTE5,
               l_ref_CSP_rec.ATTRIBUTE6,
               l_ref_CSP_rec.ATTRIBUTE7,
               l_ref_CSP_rec.ATTRIBUTE8,
               l_ref_CSP_rec.ATTRIBUTE9,
               l_ref_CSP_rec.ATTRIBUTE10,
               l_ref_CSP_rec.ATTRIBUTE11,
               l_ref_CSP_rec.ATTRIBUTE12,
               l_ref_CSP_rec.ATTRIBUTE13,
               l_ref_CSP_rec.ATTRIBUTE14,
               l_ref_CSP_rec.ATTRIBUTE15,
               l_ref_CSP_rec.MOVEMENT_ID,
               l_ref_CSP_rec.RESERVATION_QUANTITY,
               l_ref_CSP_rec.SHIPPED_QUANTITY,
               l_ref_CSP_rec.TRANSACTION_LINE_NUMBER,
               l_ref_CSP_rec.TASK_ID,
               l_ref_CSP_rec.TO_TASK_ID,
               l_ref_CSP_rec.SOURCE_TASK_ID,
               l_ref_CSP_rec.PROJECT_ID,
               l_ref_CSP_rec.SOURCE_PROJECT_ID,
               l_ref_CSP_rec.PA_EXPENDITURE_ORG_ID,
               l_ref_CSP_rec.TO_PROJECT_ID,
               l_ref_CSP_rec.EXPENDITURE_TYPE,
               l_ref_CSP_rec.FINAL_COMPLETION_FLAG,
               l_ref_CSP_rec.TRANSFER_PERCENTAGE,
               l_ref_CSP_rec.TRANSACTION_SEQUENCE_ID,
               l_ref_CSP_rec.MATERIAL_ACCOUNT,
               l_ref_CSP_rec.MATERIAL_OVERHEAD_ACCOUNT,
               l_ref_CSP_rec.RESOURCE_ACCOUNT,
               l_ref_CSP_rec.OUTSIDE_PROCESSING_ACCOUNT,
               l_ref_CSP_rec.OVERHEAD_ACCOUNT,
               l_ref_CSP_rec.FLOW_SCHEDULE,
               l_ref_CSP_rec.COST_GROUP_ID,
               l_ref_CSP_rec.DEMAND_CLASS,
               l_ref_CSP_rec.QA_COLLECTION_ID,
               l_ref_CSP_rec.KANBAN_CARD_ID,
               l_ref_CSP_rec.OVERCOMPLETION_TRANSACTION_ID,
               l_ref_CSP_rec.OVERCOMPLETION_PRIMARY_QTY,
               l_ref_CSP_rec.OVERCOMPLETION_TRANSACTION_QTY,
               l_ref_CSP_rec.PROCESS_TYPE,
               l_ref_CSP_rec.END_ITEM_UNIT_NUMBER,
               l_ref_CSP_rec.SCHEDULED_PAYBACK_DATE,
               l_ref_CSP_rec.LINE_TYPE_CODE,
               l_ref_CSP_rec.PARENT_TRANSACTION_TEMP_ID,
               l_ref_CSP_rec.PUT_AWAY_STRATEGY_ID,
               l_ref_CSP_rec.PUT_AWAY_RULE_ID,
               l_ref_CSP_rec.PICK_STRATEGY_ID,
               l_ref_CSP_rec.PICK_RULE_ID,
               l_ref_CSP_rec.COMMON_BOM_SEQ_ID,
               l_ref_CSP_rec.COMMON_ROUTING_SEQ_ID,
               l_ref_CSP_rec.COST_TYPE_ID,
               l_ref_CSP_rec.ORG_COST_GROUP_ID,
               l_ref_CSP_rec.MOVE_ORDER_LINE_ID,
               l_ref_CSP_rec.TASK_GROUP_ID,
               l_ref_CSP_rec.PICK_SLIP_NUMBER,
               l_ref_CSP_rec.RESERVATION_ID,
               l_ref_CSP_rec.TRANSACTION_STATUS;

       If ( C_Get_material_transactions%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('CSP', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'material_transactions', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
       Close     C_Get_material_transactions;
*/


/*      If (l_tar_CSP_rec.last_update_date is NULL or
          l_tar_CSP_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_CSP_rec.last_update_date <> l_ref_CSP_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'material_transactions', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
*/

/*      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_material_transactions');

          -- Invoke validation procedures
          Validate_material_transactions(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => JTF_PLSQL_API.G_UPDATE,
              P_CSP_Rec  =>  P_CSP_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
*/
      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
    --  JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(MTL_MATERIAL_TRANSACTIONS_TEMP_PKG.Update_Row)
      CSP_MTL_TRANSACTIONS_PKG.Update_Row(
          p_TRANSACTION_HEADER_ID  => p_CSP_rec.TRANSACTION_HEADER_ID,
          p_TRANSACTION_TEMP_ID  => p_CSP_rec.TRANSACTION_TEMP_ID,
          p_SOURCE_CODE  => p_CSP_rec.SOURCE_CODE,
          p_SOURCE_LINE_ID  => p_CSP_rec.SOURCE_LINE_ID,
          p_TRANSACTION_MODE  => p_CSP_rec.TRANSACTION_MODE,
          p_LOCK_FLAG  => p_CSP_rec.LOCK_FLAG,
          p_LAST_UPDATE_DATE  => p_CSP_rec.LAST_UPDATE_DATE,
          p_LAST_UPDATED_BY  => p_CSP_rec.LAST_UPDATED_BY,
          p_CREATION_DATE  => p_CSP_rec.CREATION_DATE,
          p_CREATED_BY  => p_CSP_rec.CREATED_BY,
          p_LAST_UPDATE_LOGIN  => p_CSP_rec.LAST_UPDATE_LOGIN,
          p_REQUEST_ID  => p_CSP_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => p_CSP_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => p_CSP_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => p_CSP_rec.PROGRAM_UPDATE_DATE,
          p_INVENTORY_ITEM_ID  => p_CSP_rec.INVENTORY_ITEM_ID,
          p_REVISION  => p_CSP_rec.REVISION,
          p_ORGANIZATION_ID  => p_CSP_rec.ORGANIZATION_ID,
          p_SUBINVENTORY_CODE  => p_CSP_rec.SUBINVENTORY_CODE,
          p_LOCATOR_ID  => p_CSP_rec.LOCATOR_ID,
          p_TRANSACTION_QUANTITY  => p_CSP_rec.TRANSACTION_QUANTITY,
          p_PRIMARY_QUANTITY  => p_CSP_rec.PRIMARY_QUANTITY,
          p_TRANSACTION_UOM  => p_CSP_rec.TRANSACTION_UOM,
          p_TRANSACTION_COST  => p_CSP_rec.TRANSACTION_COST,
          p_TRANSACTION_TYPE_ID  => p_CSP_rec.TRANSACTION_TYPE_ID,
          p_TRANSACTION_ACTION_ID  => p_CSP_rec.TRANSACTION_ACTION_ID,
          p_TRANSACTION_SOURCE_TYPE_ID  => p_CSP_rec.TRANSACTION_SOURCE_TYPE_ID,
          p_TRANSACTION_SOURCE_ID  => p_CSP_rec.TRANSACTION_SOURCE_ID,
          p_TRANSACTION_SOURCE_NAME  => p_CSP_rec.TRANSACTION_SOURCE_NAME,
          p_TRANSACTION_DATE  => p_CSP_rec.TRANSACTION_DATE,
          p_ACCT_PERIOD_ID  => p_CSP_rec.ACCT_PERIOD_ID,
          p_DISTRIBUTION_ACCOUNT_ID  => p_CSP_rec.DISTRIBUTION_ACCOUNT_ID,
          p_TRANSACTION_REFERENCE  => p_CSP_rec.TRANSACTION_REFERENCE,
          p_REQUISITION_LINE_ID  => p_CSP_rec.REQUISITION_LINE_ID,
          p_REQUISITION_DISTRIBUTION_ID  => p_CSP_rec.REQUISITION_DISTRIBUTION_ID,
          p_REASON_ID  => p_CSP_rec.REASON_ID,
          p_LOT_NUMBER  => p_CSP_rec.LOT_NUMBER,
          p_LOT_EXPIRATION_DATE  => p_CSP_rec.LOT_EXPIRATION_DATE,
          p_SERIAL_NUMBER  => p_CSP_rec.SERIAL_NUMBER,
          p_RECEIVING_DOCUMENT  => p_CSP_rec.RECEIVING_DOCUMENT,
          p_DEMAND_ID  => p_CSP_rec.DEMAND_ID,
          p_RCV_TRANSACTION_ID  => p_CSP_rec.RCV_TRANSACTION_ID,
          p_MOVE_TRANSACTION_ID  => p_CSP_rec.MOVE_TRANSACTION_ID,
          p_COMPLETION_TRANSACTION_ID  => p_CSP_rec.COMPLETION_TRANSACTION_ID,
          p_WIP_ENTITY_TYPE  => p_CSP_rec.WIP_ENTITY_TYPE,
          p_SCHEDULE_ID  => p_CSP_rec.SCHEDULE_ID,
          p_REPETITIVE_LINE_ID  => p_CSP_rec.REPETITIVE_LINE_ID,
          p_EMPLOYEE_CODE  => p_CSP_rec.EMPLOYEE_CODE,
          p_PRIMARY_SWITCH  => p_CSP_rec.PRIMARY_SWITCH,
          p_SCHEDULE_UPDATE_CODE  => p_CSP_rec.SCHEDULE_UPDATE_CODE,
          p_SETUP_TEARDOWN_CODE  => p_CSP_rec.SETUP_TEARDOWN_CODE,
          p_ITEM_ORDERING  => p_CSP_rec.ITEM_ORDERING,
          p_NEGATIVE_REQ_FLAG  => p_CSP_rec.NEGATIVE_REQ_FLAG,
          p_OPERATION_SEQ_NUM  => p_CSP_rec.OPERATION_SEQ_NUM,
          p_PICKING_LINE_ID  => p_CSP_rec.PICKING_LINE_ID,
          p_TRX_SOURCE_LINE_ID  => p_CSP_rec.TRX_SOURCE_LINE_ID,
          p_TRX_SOURCE_DELIVERY_ID  => p_CSP_rec.TRX_SOURCE_DELIVERY_ID,
          p_PHYSICAL_ADJUSTMENT_ID  => p_CSP_rec.PHYSICAL_ADJUSTMENT_ID,
          p_CYCLE_COUNT_ID  => p_CSP_rec.CYCLE_COUNT_ID,
          p_RMA_LINE_ID  => p_CSP_rec.RMA_LINE_ID,
          p_CUSTOMER_SHIP_ID  => p_CSP_rec.CUSTOMER_SHIP_ID,
          p_CURRENCY_CODE  => p_CSP_rec.CURRENCY_CODE,
          p_CURRENCY_CONVERSION_RATE  => p_CSP_rec.CURRENCY_CONVERSION_RATE,
          p_CURRENCY_CONVERSION_TYPE  => p_CSP_rec.CURRENCY_CONVERSION_TYPE,
          p_CURRENCY_CONVERSION_DATE  => p_CSP_rec.CURRENCY_CONVERSION_DATE,
          p_USSGL_TRANSACTION_CODE  => p_CSP_rec.USSGL_TRANSACTION_CODE,
          p_VENDOR_LOT_NUMBER  => p_CSP_rec.VENDOR_LOT_NUMBER,
          p_ENCUMBRANCE_ACCOUNT  => p_CSP_rec.ENCUMBRANCE_ACCOUNT,
          p_ENCUMBRANCE_AMOUNT  => p_CSP_rec.ENCUMBRANCE_AMOUNT,
          p_SHIP_TO_LOCATION  => p_CSP_rec.SHIP_TO_LOCATION,
          p_SHIPMENT_NUMBER  => p_CSP_rec.SHIPMENT_NUMBER,
          p_TRANSFER_COST  => p_CSP_rec.TRANSFER_COST,
          p_TRANSPORTATION_COST  => p_CSP_rec.TRANSPORTATION_COST,
          p_TRANSPORTATION_ACCOUNT  => p_CSP_rec.TRANSPORTATION_ACCOUNT,
          p_FREIGHT_CODE  => p_CSP_rec.FREIGHT_CODE,
          p_CONTAINERS  => p_CSP_rec.CONTAINERS,
          p_WAYBILL_AIRBILL  => p_CSP_rec.WAYBILL_AIRBILL,
          p_EXPECTED_ARRIVAL_DATE  => p_CSP_rec.EXPECTED_ARRIVAL_DATE,
          p_TRANSFER_SUBINVENTORY  => p_CSP_rec.TRANSFER_SUBINVENTORY,
          p_TRANSFER_ORGANIZATION  => p_CSP_rec.TRANSFER_ORGANIZATION,
          p_TRANSFER_TO_LOCATION  => p_CSP_rec.TRANSFER_TO_LOCATION,
          p_NEW_AVERAGE_COST  => p_CSP_rec.NEW_AVERAGE_COST,
          p_VALUE_CHANGE  => p_CSP_rec.VALUE_CHANGE,
          p_PERCENTAGE_CHANGE  => p_CSP_rec.PERCENTAGE_CHANGE,
          p_MATERIAL_ALLOCATION_TEMP_ID  => p_CSP_rec.MATERIAL_ALLOCATION_TEMP_ID,
          p_DEMAND_SOURCE_HEADER_ID  => p_CSP_rec.DEMAND_SOURCE_HEADER_ID,
          p_DEMAND_SOURCE_LINE  => p_CSP_rec.DEMAND_SOURCE_LINE,
          p_DEMAND_SOURCE_DELIVERY  => p_CSP_rec.DEMAND_SOURCE_DELIVERY,
          p_ITEM_SEGMENTS  => p_CSP_rec.ITEM_SEGMENTS,
          p_ITEM_DESCRIPTION  => p_CSP_rec.ITEM_DESCRIPTION,
          p_ITEM_TRX_ENABLED_FLAG  => p_CSP_rec.ITEM_TRX_ENABLED_FLAG,
          p_ITEM_LOCATION_CONTROL_CODE  => p_CSP_rec.ITEM_LOCATION_CONTROL_CODE,
          p_ITEM_RESTRICT_SUBINV_CODE  => p_CSP_rec.ITEM_RESTRICT_SUBINV_CODE,
          p_ITEM_RESTRICT_LOCATORS_CODE  => p_CSP_rec.ITEM_RESTRICT_LOCATORS_CODE,
          p_ITEM_REV_QTY_CONTROL_CODE  => p_CSP_rec.ITEM_REVISION_QTY_CONTROL_CODE,
          p_ITEM_PRIMARY_UOM_CODE  => p_CSP_rec.ITEM_PRIMARY_UOM_CODE,
          p_ITEM_UOM_CLASS  => p_CSP_rec.ITEM_UOM_CLASS,
          p_ITEM_SHELF_LIFE_CODE  => p_CSP_rec.ITEM_SHELF_LIFE_CODE,
          p_ITEM_SHELF_LIFE_DAYS  => p_CSP_rec.ITEM_SHELF_LIFE_DAYS,
          p_ITEM_LOT_CONTROL_CODE  => p_CSP_rec.ITEM_LOT_CONTROL_CODE,
          p_ITEM_SERIAL_CONTROL_CODE  => p_CSP_rec.ITEM_SERIAL_CONTROL_CODE,
          p_ITEM_INVENTORY_ASSET_FLAG  => p_CSP_rec.ITEM_INVENTORY_ASSET_FLAG,
          p_ALLOWED_UNITS_LOOKUP_CODE  => p_CSP_rec.ALLOWED_UNITS_LOOKUP_CODE,
          p_DEPARTMENT_ID  => p_CSP_rec.DEPARTMENT_ID,
          p_DEPARTMENT_CODE  => p_CSP_rec.DEPARTMENT_CODE,
          p_WIP_SUPPLY_TYPE  => p_CSP_rec.WIP_SUPPLY_TYPE,
          p_SUPPLY_SUBINVENTORY  => p_CSP_rec.SUPPLY_SUBINVENTORY,
          p_SUPPLY_LOCATOR_ID  => p_CSP_rec.SUPPLY_LOCATOR_ID,
          p_VALID_SUBINVENTORY_FLAG  => p_CSP_rec.VALID_SUBINVENTORY_FLAG,
          p_VALID_LOCATOR_FLAG  => p_CSP_rec.VALID_LOCATOR_FLAG,
          p_LOCATOR_SEGMENTS  => p_CSP_rec.LOCATOR_SEGMENTS,
          p_CURRENT_LOCATOR_CONTROL_CODE  => p_CSP_rec.CURRENT_LOCATOR_CONTROL_CODE,
          p_NUMBER_OF_LOTS_ENTERED  => p_CSP_rec.NUMBER_OF_LOTS_ENTERED,
          p_WIP_COMMIT_FLAG  => p_CSP_rec.WIP_COMMIT_FLAG,
          p_NEXT_LOT_NUMBER  => p_CSP_rec.NEXT_LOT_NUMBER,
          p_LOT_ALPHA_PREFIX  => p_CSP_rec.LOT_ALPHA_PREFIX,
          p_NEXT_SERIAL_NUMBER  => p_CSP_rec.NEXT_SERIAL_NUMBER,
          p_SERIAL_ALPHA_PREFIX  => p_CSP_rec.SERIAL_ALPHA_PREFIX,
          p_SHIPPABLE_FLAG  => p_CSP_rec.SHIPPABLE_FLAG,
          p_POSTING_FLAG  => p_CSP_rec.POSTING_FLAG,
          p_REQUIRED_FLAG  => p_CSP_rec.REQUIRED_FLAG,
          p_PROCESS_FLAG  => p_CSP_rec.PROCESS_FLAG,
          p_ERROR_CODE  => p_CSP_rec.ERROR_CODE,
          p_ERROR_EXPLANATION  => p_CSP_rec.ERROR_EXPLANATION,
          p_ATTRIBUTE_CATEGORY  => p_CSP_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_CSP_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_CSP_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_CSP_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_CSP_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_CSP_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_CSP_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_CSP_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_CSP_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_CSP_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_CSP_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_CSP_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_CSP_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_CSP_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_CSP_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_CSP_rec.ATTRIBUTE15,
          p_MOVEMENT_ID  => p_CSP_rec.MOVEMENT_ID,
          p_RESERVATION_QUANTITY  => p_CSP_rec.RESERVATION_QUANTITY,
          p_SHIPPED_QUANTITY  => p_CSP_rec.SHIPPED_QUANTITY,
          p_TRANSACTION_LINE_NUMBER  => p_CSP_rec.TRANSACTION_LINE_NUMBER,
          p_TASK_ID  => p_CSP_rec.TASK_ID,
          p_TO_TASK_ID  => p_CSP_rec.TO_TASK_ID,
          p_SOURCE_TASK_ID  => p_CSP_rec.SOURCE_TASK_ID,
          p_PROJECT_ID  => p_CSP_rec.PROJECT_ID,
          p_SOURCE_PROJECT_ID  => p_CSP_rec.SOURCE_PROJECT_ID,
          p_PA_EXPENDITURE_ORG_ID  => p_CSP_rec.PA_EXPENDITURE_ORG_ID,
          p_TO_PROJECT_ID  => p_CSP_rec.TO_PROJECT_ID,
          p_EXPENDITURE_TYPE  => p_CSP_rec.EXPENDITURE_TYPE,
          p_FINAL_COMPLETION_FLAG  => p_CSP_rec.FINAL_COMPLETION_FLAG,
          p_TRANSFER_PERCENTAGE  => p_CSP_rec.TRANSFER_PERCENTAGE,
          p_TRANSACTION_SEQUENCE_ID  => p_CSP_rec.TRANSACTION_SEQUENCE_ID,
          p_MATERIAL_ACCOUNT  => p_CSP_rec.MATERIAL_ACCOUNT,
          p_MATERIAL_OVERHEAD_ACCOUNT  => p_CSP_rec.MATERIAL_OVERHEAD_ACCOUNT,
          p_RESOURCE_ACCOUNT  => p_CSP_rec.RESOURCE_ACCOUNT,
          p_OUTSIDE_PROCESSING_ACCOUNT  => p_CSP_rec.OUTSIDE_PROCESSING_ACCOUNT,
          p_OVERHEAD_ACCOUNT  => p_CSP_rec.OVERHEAD_ACCOUNT,
          p_FLOW_SCHEDULE  => p_CSP_rec.FLOW_SCHEDULE,
          p_COST_GROUP_ID  => p_CSP_rec.COST_GROUP_ID,
          p_DEMAND_CLASS  => p_CSP_rec.DEMAND_CLASS,
          p_QA_COLLECTION_ID  => p_CSP_rec.QA_COLLECTION_ID,
          p_KANBAN_CARD_ID  => p_CSP_rec.KANBAN_CARD_ID,
          p_OVERCOMPLETION_TXN_ID  => p_CSP_rec.OVERCOMPLETION_TRANSACTION_ID,
          p_OVERCOMPLETION_PRIMARY_QTY  => p_CSP_rec.OVERCOMPLETION_PRIMARY_QTY,
          p_OVERCOMPLETION_TXN_QTY  => p_CSP_rec.OVERCOMPLETION_TRANSACTION_QTY,
         -- p_PROCESS_TYPE  => p_CSP_rec.PROCESS_TYPE,
          p_END_ITEM_UNIT_NUMBER  => p_CSP_rec.END_ITEM_UNIT_NUMBER,
          p_SCHEDULED_PAYBACK_DATE  => p_CSP_rec.SCHEDULED_PAYBACK_DATE,
          p_LINE_TYPE_CODE  => p_CSP_rec.LINE_TYPE_CODE,
          p_PARENT_TRANSACTION_TEMP_ID  => p_CSP_rec.PARENT_TRANSACTION_TEMP_ID,
          p_PUT_AWAY_STRATEGY_ID  => p_CSP_rec.PUT_AWAY_STRATEGY_ID,
          p_PUT_AWAY_RULE_ID  => p_CSP_rec.PUT_AWAY_RULE_ID,
          p_PICK_STRATEGY_ID  => p_CSP_rec.PICK_STRATEGY_ID,
          p_PICK_RULE_ID  => p_CSP_rec.PICK_RULE_ID,
          p_COMMON_BOM_SEQ_ID  => p_CSP_rec.COMMON_BOM_SEQ_ID,
          p_COMMON_ROUTING_SEQ_ID  => p_CSP_rec.COMMON_ROUTING_SEQ_ID,
          p_COST_TYPE_ID  => p_CSP_rec.COST_TYPE_ID,
          p_ORG_COST_GROUP_ID  => p_CSP_rec.ORG_COST_GROUP_ID,
          p_MOVE_ORDER_LINE_ID  => p_CSP_rec.MOVE_ORDER_LINE_ID,
          p_TASK_GROUP_ID  => p_CSP_rec.TASK_GROUP_ID,
          p_PICK_SLIP_NUMBER  => p_CSP_rec.PICK_SLIP_NUMBER,
          p_RESERVATION_ID  => p_CSP_rec.RESERVATION_ID,
          p_TRANSACTION_STATUS  => p_CSP_rec.TRANSACTION_STATUS,
          p_STANDARD_OPERATION_ID  => p_CSP_rec.STANDARD_OPERATION_ID,
          p_TASK_PRIORITY  => p_CSP_rec.TASK_PRIORITY,
          p_WMS_TASK_TYPE => p_CSP_rec.WMS_TASK_TYPE,
          p_PARENT_LINE_ID => p_CSP_rec.PARENT_LINE_ID);
--          P_SOURCE_LOT_NUMBER => p_CSP_rec.SOURCE_LOT_NUMBER);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Update_material_transactions_AU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_CSP_Rec      =>  P_CSP_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
      EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_material_transactions;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_material_transactions(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   -- P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_CSP_Rec     IN CSP_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'DELETE_MATERIAL_TXN';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
 --dbms_output.put_line('START CSP_MATERIAL');

      -- Standard Start of API savepoint
      SAVEPOINT DELETE_MATERIAL_TXN_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

--dbms_output.put_line('in CSP MATERIAL');

      -- Debug Message
--     JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Delete_material_transactions_BD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_CSP_Rec      =>  P_CSP_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/

/*      AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
          p_api_version_number => 2.0
         ,p_salesforce_id => p_identity_salesforce_id
         ,x_return_status => x_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
         ,x_sales_member_rec => l_identity_sales_member_rec);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
*/
      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling delete table handler');

      -- Invoke table handler(MTL_MATERIAL_TRANSACTIONS_TEMP_PKG.Delete_Row)

	 CSP_MTL_TRANSACTIONS_PKG.Delete_Row(
          p_TRANSACTION_TEMP_ID  => p_CSP_rec.TRANSACTION_TEMP_ID);

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
     -- JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Delete_material_transactions_AD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_CSP_Rec      =>  P_CSP_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
      EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_material_transactions;

/*
-- This procudure defines the columns for the Dynamic SQL.
PROCEDURE Define_Columns(
    P_CSP_Rec   IN  CSP_MATERIAL_TRANSACTIONS_PUB.CSP_Rec_Type,
    p_cur_get_CSP   IN   NUMBER
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Define Columns Begins');

      -- define all columns for CSP_MATERIAL_TRANSACTIONS_V view
      dbms_sql.define_column(p_cur_get_CSP, 1, P_CSP_Rec.TRANSACTION_HEADER_ID);
      dbms_sql.define_column(p_cur_get_CSP, 2, P_CSP_Rec.TRANSACTION_TEMP_ID);
      dbms_sql.define_column(p_cur_get_CSP, 3, P_CSP_Rec.SOURCE_CODE, 30);
      dbms_sql.define_column(p_cur_get_CSP, 4, P_CSP_Rec.SOURCE_LINE_ID);
      dbms_sql.define_column(p_cur_get_CSP, 5, P_CSP_Rec.TRANSACTION_MODE);
      dbms_sql.define_column(p_cur_get_CSP, 6, P_CSP_Rec.LOCK_FLAG, 1);
      dbms_sql.define_column(p_cur_get_CSP, 7, P_CSP_Rec.REQUEST_ID);
      dbms_sql.define_column(p_cur_get_CSP, 8, P_CSP_Rec.INVENTORY_ITEM_ID);
      dbms_sql.define_column(p_cur_get_CSP, 9, P_CSP_Rec.REVISION, 3);
      dbms_sql.define_column(p_cur_get_CSP, 10, P_CSP_Rec.ORGANIZATION_ID);
      dbms_sql.define_column(p_cur_get_CSP, 11, P_CSP_Rec.SUBINVENTORY_CODE, 10);
      dbms_sql.define_column(p_cur_get_CSP, 12, P_CSP_Rec.LOCATOR_ID);
      dbms_sql.define_column(p_cur_get_CSP, 13, P_CSP_Rec.TRANSACTION_QUANTITY);
      dbms_sql.define_column(p_cur_get_CSP, 14, P_CSP_Rec.PRIMARY_QUANTITY);
      dbms_sql.define_column(p_cur_get_CSP, 15, P_CSP_Rec.TRANSACTION_UOM, 3);
      dbms_sql.define_column(p_cur_get_CSP, 16, P_CSP_Rec.TRANSACTION_COST);
      dbms_sql.define_column(p_cur_get_CSP, 17, P_CSP_Rec.TRANSACTION_TYPE_ID);
      dbms_sql.define_column(p_cur_get_CSP, 18, P_CSP_Rec.TRANSACTION_ACTION_ID);
      dbms_sql.define_column(p_cur_get_CSP, 19, P_CSP_Rec.TRANSACTION_SOURCE_TYPE_ID);
      dbms_sql.define_column(p_cur_get_CSP, 20, P_CSP_Rec.TRANSACTION_SOURCE_ID);
      dbms_sql.define_column(p_cur_get_CSP, 21, P_CSP_Rec.TRANSACTION_SOURCE_NAME, 30);
      dbms_sql.define_column(p_cur_get_CSP, 22, P_CSP_Rec.TRANSACTION_DATE);
      dbms_sql.define_column(p_cur_get_CSP, 23, P_CSP_Rec.ACCT_PERIOD_ID);
      dbms_sql.define_column(p_cur_get_CSP, 24, P_CSP_Rec.DISTRIBUTION_ACCOUNT_ID);
      dbms_sql.define_column(p_cur_get_CSP, 25, P_CSP_Rec.TRANSACTION_REFERENCE, 240);
      dbms_sql.define_column(p_cur_get_CSP, 26, P_CSP_Rec.REQUISITION_LINE_ID);
      dbms_sql.define_column(p_cur_get_CSP, 27, P_CSP_Rec.REQUISITION_DISTRIBUTION_ID);
      dbms_sql.define_column(p_cur_get_CSP, 28, P_CSP_Rec.REASON_ID);
      dbms_sql.define_column(p_cur_get_CSP, 29, P_CSP_Rec.LOT_NUMBER, 80);
      dbms_sql.define_column(p_cur_get_CSP, 30, P_CSP_Rec.LOT_EXPIRATION_DATE);
      dbms_sql.define_column(p_cur_get_CSP, 31, P_CSP_Rec.SERIAL_NUMBER, 30);
      dbms_sql.define_column(p_cur_get_CSP, 32, P_CSP_Rec.RECEIVING_DOCUMENT, 10);
      dbms_sql.define_column(p_cur_get_CSP, 33, P_CSP_Rec.DEMAND_ID);
      dbms_sql.define_column(p_cur_get_CSP, 34, P_CSP_Rec.RCV_TRANSACTION_ID);
      dbms_sql.define_column(p_cur_get_CSP, 35, P_CSP_Rec.MOVE_TRANSACTION_ID);
      dbms_sql.define_column(p_cur_get_CSP, 36, P_CSP_Rec.COMPLETION_TRANSACTION_ID);
      dbms_sql.define_column(p_cur_get_CSP, 37, P_CSP_Rec.WIP_ENTITY_TYPE);
      dbms_sql.define_column(p_cur_get_CSP, 38, P_CSP_Rec.SCHEDULE_ID);
      dbms_sql.define_column(p_cur_get_CSP, 39, P_CSP_Rec.REPETITIVE_LINE_ID);
      dbms_sql.define_column(p_cur_get_CSP, 40, P_CSP_Rec.EMPLOYEE_CODE, 10);
      dbms_sql.define_column(p_cur_get_CSP, 41, P_CSP_Rec.PRIMARY_SWITCH);
      dbms_sql.define_column(p_cur_get_CSP, 42, P_CSP_Rec.SCHEDULE_UPDATE_CODE);
      dbms_sql.define_column(p_cur_get_CSP, 43, P_CSP_Rec.SETUP_TEARDOWN_CODE);
      dbms_sql.define_column(p_cur_get_CSP, 44, P_CSP_Rec.ITEM_ORDERING);
      dbms_sql.define_column(p_cur_get_CSP, 45, P_CSP_Rec.NEGATIVE_REQ_FLAG);
      dbms_sql.define_column(p_cur_get_CSP, 46, P_CSP_Rec.OPERATION_SEQ_NUM);
      dbms_sql.define_column(p_cur_get_CSP, 47, P_CSP_Rec.PICKING_LINE_ID);
      dbms_sql.define_column(p_cur_get_CSP, 48, P_CSP_Rec.TRX_SOURCE_LINE_ID);
      dbms_sql.define_column(p_cur_get_CSP, 49, P_CSP_Rec.TRX_SOURCE_DELIVERY_ID);
      dbms_sql.define_column(p_cur_get_CSP, 50, P_CSP_Rec.PHYSICAL_ADJUSTMENT_ID);
      dbms_sql.define_column(p_cur_get_CSP, 51, P_CSP_Rec.CYCLE_COUNT_ID);
      dbms_sql.define_column(p_cur_get_CSP, 52, P_CSP_Rec.RMA_LINE_ID);
      dbms_sql.define_column(p_cur_get_CSP, 53, P_CSP_Rec.CUSTOMER_SHIP_ID);
      dbms_sql.define_column(p_cur_get_CSP, 54, P_CSP_Rec.CURRENCY_CODE, 10);
      dbms_sql.define_column(p_cur_get_CSP, 55, P_CSP_Rec.CURRENCY_CONVERSION_RATE);
      dbms_sql.define_column(p_cur_get_CSP, 56, P_CSP_Rec.CURRENCY_CONVERSION_TYPE, 30);
      dbms_sql.define_column(p_cur_get_CSP, 57, P_CSP_Rec.CURRENCY_CONVERSION_DATE);
      dbms_sql.define_column(p_cur_get_CSP, 58, P_CSP_Rec.USSGL_TRANSACTION_CODE, 30);
      dbms_sql.define_column(p_cur_get_CSP, 59, P_CSP_Rec.VENDOR_LOT_NUMBER, 80);
      dbms_sql.define_column(p_cur_get_CSP, 60, P_CSP_Rec.ENCUMBRANCE_ACCOUNT);
      dbms_sql.define_column(p_cur_get_CSP, 61, P_CSP_Rec.ENCUMBRANCE_AMOUNT);
      dbms_sql.define_column(p_cur_get_CSP, 62, P_CSP_Rec.SHIP_TO_LOCATION);
      dbms_sql.define_column(p_cur_get_CSP, 63, P_CSP_Rec.SHIPMENT_NUMBER, 30);
      dbms_sql.define_column(p_cur_get_CSP, 64, P_CSP_Rec.TRANSFER_COST);
      dbms_sql.define_column(p_cur_get_CSP, 65, P_CSP_Rec.TRANSPORTATION_COST);
      dbms_sql.define_column(p_cur_get_CSP, 66, P_CSP_Rec.TRANSPORTATION_ACCOUNT);
      dbms_sql.define_column(p_cur_get_CSP, 67, P_CSP_Rec.FREIGHT_CODE, 25);
      dbms_sql.define_column(p_cur_get_CSP, 68, P_CSP_Rec.CONTAINERS);
      dbms_sql.define_column(p_cur_get_CSP, 69, P_CSP_Rec.WAYBILL_AIRBILL, 20);
      dbms_sql.define_column(p_cur_get_CSP, 70, P_CSP_Rec.EXPECTED_ARRIVAL_DATE);
      dbms_sql.define_column(p_cur_get_CSP, 71, P_CSP_Rec.TRANSFER_SUBINVENTORY, 10);
      dbms_sql.define_column(p_cur_get_CSP, 72, P_CSP_Rec.TRANSFER_ORGANIZATION);
      dbms_sql.define_column(p_cur_get_CSP, 73, P_CSP_Rec.TRANSFER_TO_LOCATION);
      dbms_sql.define_column(p_cur_get_CSP, 74, P_CSP_Rec.NEW_AVERAGE_COST);
      dbms_sql.define_column(p_cur_get_CSP, 75, P_CSP_Rec.VALUE_CHANGE);
      dbms_sql.define_column(p_cur_get_CSP, 76, P_CSP_Rec.PERCENTAGE_CHANGE);
      dbms_sql.define_column(p_cur_get_CSP, 77, P_CSP_Rec.MATERIAL_ALLOCATION_TEMP_ID);
      dbms_sql.define_column(p_cur_get_CSP, 78, P_CSP_Rec.DEMAND_SOURCE_HEADER_ID);
      dbms_sql.define_column(p_cur_get_CSP, 79, P_CSP_Rec.DEMAND_SOURCE_LINE, 30);
      dbms_sql.define_column(p_cur_get_CSP, 80, P_CSP_Rec.DEMAND_SOURCE_DELIVERY, 30);
      dbms_sql.define_column(p_cur_get_CSP, 81, P_CSP_Rec.ITEM_SEGMENTS, 240);
      dbms_sql.define_column(p_cur_get_CSP, 82, P_CSP_Rec.ITEM_DESCRIPTION, 240);
      dbms_sql.define_column(p_cur_get_CSP, 83, P_CSP_Rec.ITEM_TRX_ENABLED_FLAG, 1);
      dbms_sql.define_column(p_cur_get_CSP, 84, P_CSP_Rec.ITEM_LOCATION_CONTROL_CODE);
      dbms_sql.define_column(p_cur_get_CSP, 85, P_CSP_Rec.ITEM_RESTRICT_SUBINV_CODE);
      dbms_sql.define_column(p_cur_get_CSP, 86, P_CSP_Rec.ITEM_RESTRICT_LOCATORS_CODE);
      dbms_sql.define_column(p_cur_get_CSP, 87, P_CSP_Rec.ITEM_REVISION_QTY_CONTROL_CODE);
      dbms_sql.define_column(p_cur_get_CSP, 88, P_CSP_Rec.ITEM_PRIMARY_UOM_CODE, 3);
      dbms_sql.define_column(p_cur_get_CSP, 89, P_CSP_Rec.ITEM_UOM_CLASS, 10);
      dbms_sql.define_column(p_cur_get_CSP, 90, P_CSP_Rec.ITEM_SHELF_LIFE_CODE);
      dbms_sql.define_column(p_cur_get_CSP, 91, P_CSP_Rec.ITEM_SHELF_LIFE_DAYS);
      dbms_sql.define_column(p_cur_get_CSP, 92, P_CSP_Rec.ITEM_LOT_CONTROL_CODE);
      dbms_sql.define_column(p_cur_get_CSP, 93, P_CSP_Rec.ITEM_SERIAL_CONTROL_CODE);
      dbms_sql.define_column(p_cur_get_CSP, 94, P_CSP_Rec.ITEM_INVENTORY_ASSET_FLAG, 1);
      dbms_sql.define_column(p_cur_get_CSP, 95, P_CSP_Rec.ALLOWED_UNITS_LOOKUP_CODE);
      dbms_sql.define_column(p_cur_get_CSP, 96, P_CSP_Rec.DEPARTMENT_ID);
      dbms_sql.define_column(p_cur_get_CSP, 97, P_CSP_Rec.DEPARTMENT_CODE, 10);
      dbms_sql.define_column(p_cur_get_CSP, 98, P_CSP_Rec.WIP_SUPPLY_TYPE);
      dbms_sql.define_column(p_cur_get_CSP, 99, P_CSP_Rec.SUPPLY_SUBINVENTORY, 10);
      dbms_sql.define_column(p_cur_get_CSP, 100, P_CSP_Rec.SUPPLY_LOCATOR_ID);
      dbms_sql.define_column(p_cur_get_CSP, 101, P_CSP_Rec.VALID_SUBINVENTORY_FLAG, 1);
      dbms_sql.define_column(p_cur_get_CSP, 102, P_CSP_Rec.VALID_LOCATOR_FLAG, 1);
      dbms_sql.define_column(p_cur_get_CSP, 103, P_CSP_Rec.LOCATOR_SEGMENTS, 240);
      dbms_sql.define_column(p_cur_get_CSP, 104, P_CSP_Rec.CURRENT_LOCATOR_CONTROL_CODE);
      dbms_sql.define_column(p_cur_get_CSP, 105, P_CSP_Rec.NUMBER_OF_LOTS_ENTERED);
      dbms_sql.define_column(p_cur_get_CSP, 106, P_CSP_Rec.WIP_COMMIT_FLAG, 1);
      dbms_sql.define_column(p_cur_get_CSP, 107, P_CSP_Rec.NEXT_LOT_NUMBER, 80);
      dbms_sql.define_column(p_cur_get_CSP, 108, P_CSP_Rec.LOT_ALPHA_PREFIX, 30);
      dbms_sql.define_column(p_cur_get_CSP, 109, P_CSP_Rec.NEXT_SERIAL_NUMBER, 30);
      dbms_sql.define_column(p_cur_get_CSP, 110, P_CSP_Rec.SERIAL_ALPHA_PREFIX, 30);
      dbms_sql.define_column(p_cur_get_CSP, 111, P_CSP_Rec.SHIPPABLE_FLAG, 1);
      dbms_sql.define_column(p_cur_get_CSP, 112, P_CSP_Rec.POSTING_FLAG, 1);
      dbms_sql.define_column(p_cur_get_CSP, 113, P_CSP_Rec.REQUIRED_FLAG, 1);
      dbms_sql.define_column(p_cur_get_CSP, 114, P_CSP_Rec.PROCESS_FLAG, 1);
      dbms_sql.define_column(p_cur_get_CSP, 115, P_CSP_Rec.ERROR_CODE, 240);
      dbms_sql.define_column(p_cur_get_CSP, 116, P_CSP_Rec.ERROR_EXPLANATION, 240);
      dbms_sql.define_column(p_cur_get_CSP, 117, P_CSP_Rec.ATTRIBUTE_CATEGORY, 30);
      dbms_sql.define_column(p_cur_get_CSP, 118, P_CSP_Rec.ATTRIBUTE1, 150);
      dbms_sql.define_column(p_cur_get_CSP, 119, P_CSP_Rec.ATTRIBUTE2, 150);
      dbms_sql.define_column(p_cur_get_CSP, 120, P_CSP_Rec.ATTRIBUTE3, 150);
      dbms_sql.define_column(p_cur_get_CSP, 121, P_CSP_Rec.ATTRIBUTE4, 150);
      dbms_sql.define_column(p_cur_get_CSP, 122, P_CSP_Rec.ATTRIBUTE5, 150);
      dbms_sql.define_column(p_cur_get_CSP, 123, P_CSP_Rec.ATTRIBUTE6, 150);
      dbms_sql.define_column(p_cur_get_CSP, 124, P_CSP_Rec.ATTRIBUTE7, 150);
      dbms_sql.define_column(p_cur_get_CSP, 125, P_CSP_Rec.ATTRIBUTE8, 150);
      dbms_sql.define_column(p_cur_get_CSP, 126, P_CSP_Rec.ATTRIBUTE9, 150);
      dbms_sql.define_column(p_cur_get_CSP, 127, P_CSP_Rec.ATTRIBUTE10, 150);
      dbms_sql.define_column(p_cur_get_CSP, 128, P_CSP_Rec.ATTRIBUTE11, 150);
      dbms_sql.define_column(p_cur_get_CSP, 129, P_CSP_Rec.ATTRIBUTE12, 150);
      dbms_sql.define_column(p_cur_get_CSP, 130, P_CSP_Rec.ATTRIBUTE13, 150);
      dbms_sql.define_column(p_cur_get_CSP, 131, P_CSP_Rec.ATTRIBUTE14, 150);
      dbms_sql.define_column(p_cur_get_CSP, 132, P_CSP_Rec.ATTRIBUTE15, 150);
      dbms_sql.define_column(p_cur_get_CSP, 133, P_CSP_Rec.MOVEMENT_ID);
      dbms_sql.define_column(p_cur_get_CSP, 134, P_CSP_Rec.RESERVATION_QUANTITY);
      dbms_sql.define_column(p_cur_get_CSP, 135, P_CSP_Rec.SHIPPED_QUANTITY);
      dbms_sql.define_column(p_cur_get_CSP, 136, P_CSP_Rec.TRANSACTION_LINE_NUMBER);
      dbms_sql.define_column(p_cur_get_CSP, 137, P_CSP_Rec.TASK_ID);
      dbms_sql.define_column(p_cur_get_CSP, 138, P_CSP_Rec.TO_TASK_ID);
      dbms_sql.define_column(p_cur_get_CSP, 139, P_CSP_Rec.SOURCE_TASK_ID);
      dbms_sql.define_column(p_cur_get_CSP, 140, P_CSP_Rec.PROJECT_ID);
      dbms_sql.define_column(p_cur_get_CSP, 141, P_CSP_Rec.SOURCE_PROJECT_ID);
      dbms_sql.define_column(p_cur_get_CSP, 142, P_CSP_Rec.PA_EXPENDITURE_ORG_ID);
      dbms_sql.define_column(p_cur_get_CSP, 143, P_CSP_Rec.TO_PROJECT_ID);
      dbms_sql.define_column(p_cur_get_CSP, 144, P_CSP_Rec.EXPENDITURE_TYPE, 30);
      dbms_sql.define_column(p_cur_get_CSP, 145, P_CSP_Rec.FINAL_COMPLETION_FLAG, 1);
      dbms_sql.define_column(p_cur_get_CSP, 146, P_CSP_Rec.TRANSFER_PERCENTAGE);
      dbms_sql.define_column(p_cur_get_CSP, 147, P_CSP_Rec.TRANSACTION_SEQUENCE_ID);
      dbms_sql.define_column(p_cur_get_CSP, 148, P_CSP_Rec.MATERIAL_ACCOUNT);
      dbms_sql.define_column(p_cur_get_CSP, 149, P_CSP_Rec.MATERIAL_OVERHEAD_ACCOUNT);
      dbms_sql.define_column(p_cur_get_CSP, 150, P_CSP_Rec.RESOURCE_ACCOUNT);
      dbms_sql.define_column(p_cur_get_CSP, 151, P_CSP_Rec.OUTSIDE_PROCESSING_ACCOUNT);
      dbms_sql.define_column(p_cur_get_CSP, 152, P_CSP_Rec.OVERHEAD_ACCOUNT);
      dbms_sql.define_column(p_cur_get_CSP, 153, P_CSP_Rec.FLOW_SCHEDULE, 1);
      dbms_sql.define_column(p_cur_get_CSP, 154, P_CSP_Rec.COST_GROUP_ID);
      dbms_sql.define_column(p_cur_get_CSP, 155, P_CSP_Rec.DEMAND_CLASS, 30);
      dbms_sql.define_column(p_cur_get_CSP, 156, P_CSP_Rec.QA_COLLECTION_ID);
      dbms_sql.define_column(p_cur_get_CSP, 157, P_CSP_Rec.KANBAN_CARD_ID);
      dbms_sql.define_column(p_cur_get_CSP, 158, P_CSP_Rec.OVERCOMPLETION_TRANSACTION_ID);
      dbms_sql.define_column(p_cur_get_CSP, 159, P_CSP_Rec.OVERCOMPLETION_PRIMARY_QTY);
      dbms_sql.define_column(p_cur_get_CSP, 160, P_CSP_Rec.OVERCOMPLETION_TRANSACTION_QTY);
      dbms_sql.define_column(p_cur_get_CSP, 161, P_CSP_Rec.PROCESS_TYPE);
      dbms_sql.define_column(p_cur_get_CSP, 162, P_CSP_Rec.END_ITEM_UNIT_NUMBER, 60);
      dbms_sql.define_column(p_cur_get_CSP, 163, P_CSP_Rec.SCHEDULED_PAYBACK_DATE);
      dbms_sql.define_column(p_cur_get_CSP, 164, P_CSP_Rec.LINE_TYPE_CODE);
      dbms_sql.define_column(p_cur_get_CSP, 165, P_CSP_Rec.PARENT_TRANSACTION_TEMP_ID);
      dbms_sql.define_column(p_cur_get_CSP, 166, P_CSP_Rec.PUT_AWAY_STRATEGY_ID);
      dbms_sql.define_column(p_cur_get_CSP, 167, P_CSP_Rec.PUT_AWAY_RULE_ID);
      dbms_sql.define_column(p_cur_get_CSP, 168, P_CSP_Rec.PICK_STRATEGY_ID);
      dbms_sql.define_column(p_cur_get_CSP, 169, P_CSP_Rec.PICK_RULE_ID);
      dbms_sql.define_column(p_cur_get_CSP, 170, P_CSP_Rec.COMMON_BOM_SEQ_ID);
      dbms_sql.define_column(p_cur_get_CSP, 171, P_CSP_Rec.COMMON_ROUTING_SEQ_ID);
      dbms_sql.define_column(p_cur_get_CSP, 172, P_CSP_Rec.COST_TYPE_ID);
      dbms_sql.define_column(p_cur_get_CSP, 173, P_CSP_Rec.ORG_COST_GROUP_ID);
      dbms_sql.define_column(p_cur_get_CSP, 174, P_CSP_Rec.MOVE_ORDER_LINE_ID);
      dbms_sql.define_column(p_cur_get_CSP, 175, P_CSP_Rec.TASK_GROUP_ID);
      dbms_sql.define_column(p_cur_get_CSP, 176, P_CSP_Rec.PICK_SLIP_NUMBER);
      dbms_sql.define_column(p_cur_get_CSP, 177, P_CSP_Rec.RESERVATION_ID);
      dbms_sql.define_column(p_cur_get_CSP, 178, P_CSP_Rec.TRANSACTION_STATUS);

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Define Columns Ends');
END Define_Columns;

-- This procudure gets column values by the Dynamic SQL.
PROCEDURE Get_Column_Values(
    p_cur_get_CSP   IN   NUMBER,
    X_CSP_Rec   OUT NOCOPY  CSP_MATERIAL_TRANSACTIONS_PUB.CSP_Rec_Type
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Get Column Values Begins');

      -- get all column values for CSP_MATERIAL_TRANSACTIONS_V table
      dbms_sql.column_value(p_cur_get_CSP, 1, X_CSP_Rec.TRANSACTION_HEADER_ID);
      dbms_sql.column_value(p_cur_get_CSP, 2, X_CSP_Rec.TRANSACTION_TEMP_ID);
      dbms_sql.column_value(p_cur_get_CSP, 3, X_CSP_Rec.SOURCE_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 4, X_CSP_Rec.SOURCE_LINE_ID);
      dbms_sql.column_value(p_cur_get_CSP, 5, X_CSP_Rec.TRANSACTION_MODE);
      dbms_sql.column_value(p_cur_get_CSP, 6, X_CSP_Rec.LOCK_FLAG);
      dbms_sql.column_value(p_cur_get_CSP, 7, X_CSP_Rec.REQUEST_ID);
      dbms_sql.column_value(p_cur_get_CSP, 8, X_CSP_Rec.INVENTORY_ITEM_ID);
      dbms_sql.column_value(p_cur_get_CSP, 9, X_CSP_Rec.REVISION);
      dbms_sql.column_value(p_cur_get_CSP, 10, X_CSP_Rec.ORGANIZATION_ID);
      dbms_sql.column_value(p_cur_get_CSP, 11, X_CSP_Rec.SUBINVENTORY_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 12, X_CSP_Rec.LOCATOR_ID);
      dbms_sql.column_value(p_cur_get_CSP, 13, X_CSP_Rec.TRANSACTION_QUANTITY);
      dbms_sql.column_value(p_cur_get_CSP, 14, X_CSP_Rec.PRIMARY_QUANTITY);
      dbms_sql.column_value(p_cur_get_CSP, 15, X_CSP_Rec.TRANSACTION_UOM);
      dbms_sql.column_value(p_cur_get_CSP, 16, X_CSP_Rec.TRANSACTION_COST);
      dbms_sql.column_value(p_cur_get_CSP, 17, X_CSP_Rec.TRANSACTION_TYPE_ID);
      dbms_sql.column_value(p_cur_get_CSP, 18, X_CSP_Rec.TRANSACTION_ACTION_ID);
      dbms_sql.column_value(p_cur_get_CSP, 19, X_CSP_Rec.TRANSACTION_SOURCE_TYPE_ID);
      dbms_sql.column_value(p_cur_get_CSP, 20, X_CSP_Rec.TRANSACTION_SOURCE_ID);
      dbms_sql.column_value(p_cur_get_CSP, 21, X_CSP_Rec.TRANSACTION_SOURCE_NAME);
      dbms_sql.column_value(p_cur_get_CSP, 22, X_CSP_Rec.TRANSACTION_DATE);
      dbms_sql.column_value(p_cur_get_CSP, 23, X_CSP_Rec.ACCT_PERIOD_ID);
      dbms_sql.column_value(p_cur_get_CSP, 24, X_CSP_Rec.DISTRIBUTION_ACCOUNT_ID);
      dbms_sql.column_value(p_cur_get_CSP, 25, X_CSP_Rec.TRANSACTION_REFERENCE);
      dbms_sql.column_value(p_cur_get_CSP, 26, X_CSP_Rec.REQUISITION_LINE_ID);
      dbms_sql.column_value(p_cur_get_CSP, 27, X_CSP_Rec.REQUISITION_DISTRIBUTION_ID);
      dbms_sql.column_value(p_cur_get_CSP, 28, X_CSP_Rec.REASON_ID);
      dbms_sql.column_value(p_cur_get_CSP, 29, X_CSP_Rec.LOT_NUMBER);
      dbms_sql.column_value(p_cur_get_CSP, 30, X_CSP_Rec.LOT_EXPIRATION_DATE);
      dbms_sql.column_value(p_cur_get_CSP, 31, X_CSP_Rec.SERIAL_NUMBER);
      dbms_sql.column_value(p_cur_get_CSP, 32, X_CSP_Rec.RECEIVING_DOCUMENT);
      dbms_sql.column_value(p_cur_get_CSP, 33, X_CSP_Rec.DEMAND_ID);
      dbms_sql.column_value(p_cur_get_CSP, 34, X_CSP_Rec.RCV_TRANSACTION_ID);
      dbms_sql.column_value(p_cur_get_CSP, 35, X_CSP_Rec.MOVE_TRANSACTION_ID);
      dbms_sql.column_value(p_cur_get_CSP, 36, X_CSP_Rec.COMPLETION_TRANSACTION_ID);
      dbms_sql.column_value(p_cur_get_CSP, 37, X_CSP_Rec.WIP_ENTITY_TYPE);
      dbms_sql.column_value(p_cur_get_CSP, 38, X_CSP_Rec.SCHEDULE_ID);
      dbms_sql.column_value(p_cur_get_CSP, 39, X_CSP_Rec.REPETITIVE_LINE_ID);
      dbms_sql.column_value(p_cur_get_CSP, 40, X_CSP_Rec.EMPLOYEE_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 41, X_CSP_Rec.PRIMARY_SWITCH);
      dbms_sql.column_value(p_cur_get_CSP, 42, X_CSP_Rec.SCHEDULE_UPDATE_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 43, X_CSP_Rec.SETUP_TEARDOWN_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 44, X_CSP_Rec.ITEM_ORDERING);
      dbms_sql.column_value(p_cur_get_CSP, 45, X_CSP_Rec.NEGATIVE_REQ_FLAG);
      dbms_sql.column_value(p_cur_get_CSP, 46, X_CSP_Rec.OPERATION_SEQ_NUM);
      dbms_sql.column_value(p_cur_get_CSP, 47, X_CSP_Rec.PICKING_LINE_ID);
      dbms_sql.column_value(p_cur_get_CSP, 48, X_CSP_Rec.TRX_SOURCE_LINE_ID);
      dbms_sql.column_value(p_cur_get_CSP, 49, X_CSP_Rec.TRX_SOURCE_DELIVERY_ID);
      dbms_sql.column_value(p_cur_get_CSP, 50, X_CSP_Rec.PHYSICAL_ADJUSTMENT_ID);
      dbms_sql.column_value(p_cur_get_CSP, 51, X_CSP_Rec.CYCLE_COUNT_ID);
      dbms_sql.column_value(p_cur_get_CSP, 52, X_CSP_Rec.RMA_LINE_ID);
      dbms_sql.column_value(p_cur_get_CSP, 53, X_CSP_Rec.CUSTOMER_SHIP_ID);
      dbms_sql.column_value(p_cur_get_CSP, 54, X_CSP_Rec.CURRENCY_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 55, X_CSP_Rec.CURRENCY_CONVERSION_RATE);
      dbms_sql.column_value(p_cur_get_CSP, 56, X_CSP_Rec.CURRENCY_CONVERSION_TYPE);
      dbms_sql.column_value(p_cur_get_CSP, 57, X_CSP_Rec.CURRENCY_CONVERSION_DATE);
      dbms_sql.column_value(p_cur_get_CSP, 58, X_CSP_Rec.USSGL_TRANSACTION_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 59, X_CSP_Rec.VENDOR_LOT_NUMBER);
      dbms_sql.column_value(p_cur_get_CSP, 60, X_CSP_Rec.ENCUMBRANCE_ACCOUNT);
      dbms_sql.column_value(p_cur_get_CSP, 61, X_CSP_Rec.ENCUMBRANCE_AMOUNT);
      dbms_sql.column_value(p_cur_get_CSP, 62, X_CSP_Rec.SHIP_TO_LOCATION);
      dbms_sql.column_value(p_cur_get_CSP, 63, X_CSP_Rec.SHIPMENT_NUMBER);
      dbms_sql.column_value(p_cur_get_CSP, 64, X_CSP_Rec.TRANSFER_COST);
      dbms_sql.column_value(p_cur_get_CSP, 65, X_CSP_Rec.TRANSPORTATION_COST);
      dbms_sql.column_value(p_cur_get_CSP, 66, X_CSP_Rec.TRANSPORTATION_ACCOUNT);
      dbms_sql.column_value(p_cur_get_CSP, 67, X_CSP_Rec.FREIGHT_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 68, X_CSP_Rec.CONTAINERS);
      dbms_sql.column_value(p_cur_get_CSP, 69, X_CSP_Rec.WAYBILL_AIRBILL);
      dbms_sql.column_value(p_cur_get_CSP, 70, X_CSP_Rec.EXPECTED_ARRIVAL_DATE);
      dbms_sql.column_value(p_cur_get_CSP, 71, X_CSP_Rec.TRANSFER_SUBINVENTORY);
      dbms_sql.column_value(p_cur_get_CSP, 72, X_CSP_Rec.TRANSFER_ORGANIZATION);
      dbms_sql.column_value(p_cur_get_CSP, 73, X_CSP_Rec.TRANSFER_TO_LOCATION);
      dbms_sql.column_value(p_cur_get_CSP, 74, X_CSP_Rec.NEW_AVERAGE_COST);
      dbms_sql.column_value(p_cur_get_CSP, 75, X_CSP_Rec.VALUE_CHANGE);
      dbms_sql.column_value(p_cur_get_CSP, 76, X_CSP_Rec.PERCENTAGE_CHANGE);
      dbms_sql.column_value(p_cur_get_CSP, 77, X_CSP_Rec.MATERIAL_ALLOCATION_TEMP_ID);
      dbms_sql.column_value(p_cur_get_CSP, 78, X_CSP_Rec.DEMAND_SOURCE_HEADER_ID);
      dbms_sql.column_value(p_cur_get_CSP, 79, X_CSP_Rec.DEMAND_SOURCE_LINE);
      dbms_sql.column_value(p_cur_get_CSP, 80, X_CSP_Rec.DEMAND_SOURCE_DELIVERY);
      dbms_sql.column_value(p_cur_get_CSP, 81, X_CSP_Rec.ITEM_SEGMENTS);
      dbms_sql.column_value(p_cur_get_CSP, 82, X_CSP_Rec.ITEM_DESCRIPTION);
      dbms_sql.column_value(p_cur_get_CSP, 83, X_CSP_Rec.ITEM_TRX_ENABLED_FLAG);
      dbms_sql.column_value(p_cur_get_CSP, 84, X_CSP_Rec.ITEM_LOCATION_CONTROL_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 85, X_CSP_Rec.ITEM_RESTRICT_SUBINV_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 86, X_CSP_Rec.ITEM_RESTRICT_LOCATORS_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 87, X_CSP_Rec.ITEM_REVISION_QTY_CONTROL_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 88, X_CSP_Rec.ITEM_PRIMARY_UOM_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 89, X_CSP_Rec.ITEM_UOM_CLASS);
      dbms_sql.column_value(p_cur_get_CSP, 90, X_CSP_Rec.ITEM_SHELF_LIFE_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 91, X_CSP_Rec.ITEM_SHELF_LIFE_DAYS);
      dbms_sql.column_value(p_cur_get_CSP, 92, X_CSP_Rec.ITEM_LOT_CONTROL_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 93, X_CSP_Rec.ITEM_SERIAL_CONTROL_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 94, X_CSP_Rec.ITEM_INVENTORY_ASSET_FLAG);
      dbms_sql.column_value(p_cur_get_CSP, 95, X_CSP_Rec.ALLOWED_UNITS_LOOKUP_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 96, X_CSP_Rec.DEPARTMENT_ID);
      dbms_sql.column_value(p_cur_get_CSP, 97, X_CSP_Rec.DEPARTMENT_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 98, X_CSP_Rec.WIP_SUPPLY_TYPE);
      dbms_sql.column_value(p_cur_get_CSP, 99, X_CSP_Rec.SUPPLY_SUBINVENTORY);
      dbms_sql.column_value(p_cur_get_CSP, 100, X_CSP_Rec.SUPPLY_LOCATOR_ID);
      dbms_sql.column_value(p_cur_get_CSP, 101, X_CSP_Rec.VALID_SUBINVENTORY_FLAG);
      dbms_sql.column_value(p_cur_get_CSP, 102, X_CSP_Rec.VALID_LOCATOR_FLAG);
      dbms_sql.column_value(p_cur_get_CSP, 103, X_CSP_Rec.LOCATOR_SEGMENTS);
      dbms_sql.column_value(p_cur_get_CSP, 104, X_CSP_Rec.CURRENT_LOCATOR_CONTROL_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 105, X_CSP_Rec.NUMBER_OF_LOTS_ENTERED);
      dbms_sql.column_value(p_cur_get_CSP, 106, X_CSP_Rec.WIP_COMMIT_FLAG);
      dbms_sql.column_value(p_cur_get_CSP, 107, X_CSP_Rec.NEXT_LOT_NUMBER);
      dbms_sql.column_value(p_cur_get_CSP, 108, X_CSP_Rec.LOT_ALPHA_PREFIX);
      dbms_sql.column_value(p_cur_get_CSP, 109, X_CSP_Rec.NEXT_SERIAL_NUMBER);
      dbms_sql.column_value(p_cur_get_CSP, 110, X_CSP_Rec.SERIAL_ALPHA_PREFIX);
      dbms_sql.column_value(p_cur_get_CSP, 111, X_CSP_Rec.SHIPPABLE_FLAG);
      dbms_sql.column_value(p_cur_get_CSP, 112, X_CSP_Rec.POSTING_FLAG);
      dbms_sql.column_value(p_cur_get_CSP, 113, X_CSP_Rec.REQUIRED_FLAG);
      dbms_sql.column_value(p_cur_get_CSP, 114, X_CSP_Rec.PROCESS_FLAG);
      dbms_sql.column_value(p_cur_get_CSP, 115, X_CSP_Rec.ERROR_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 116, X_CSP_Rec.ERROR_EXPLANATION);
      dbms_sql.column_value(p_cur_get_CSP, 117, X_CSP_Rec.ATTRIBUTE_CATEGORY);
      dbms_sql.column_value(p_cur_get_CSP, 118, X_CSP_Rec.ATTRIBUTE1);
      dbms_sql.column_value(p_cur_get_CSP, 119, X_CSP_Rec.ATTRIBUTE2);
      dbms_sql.column_value(p_cur_get_CSP, 120, X_CSP_Rec.ATTRIBUTE3);
      dbms_sql.column_value(p_cur_get_CSP, 121, X_CSP_Rec.ATTRIBUTE4);
      dbms_sql.column_value(p_cur_get_CSP, 122, X_CSP_Rec.ATTRIBUTE5);
      dbms_sql.column_value(p_cur_get_CSP, 123, X_CSP_Rec.ATTRIBUTE6);
      dbms_sql.column_value(p_cur_get_CSP, 124, X_CSP_Rec.ATTRIBUTE7);
      dbms_sql.column_value(p_cur_get_CSP, 125, X_CSP_Rec.ATTRIBUTE8);
      dbms_sql.column_value(p_cur_get_CSP, 126, X_CSP_Rec.ATTRIBUTE9);
      dbms_sql.column_value(p_cur_get_CSP, 127, X_CSP_Rec.ATTRIBUTE10);
      dbms_sql.column_value(p_cur_get_CSP, 128, X_CSP_Rec.ATTRIBUTE11);
      dbms_sql.column_value(p_cur_get_CSP, 129, X_CSP_Rec.ATTRIBUTE12);
      dbms_sql.column_value(p_cur_get_CSP, 130, X_CSP_Rec.ATTRIBUTE13);
      dbms_sql.column_value(p_cur_get_CSP, 131, X_CSP_Rec.ATTRIBUTE14);
      dbms_sql.column_value(p_cur_get_CSP, 132, X_CSP_Rec.ATTRIBUTE15);
      dbms_sql.column_value(p_cur_get_CSP, 133, X_CSP_Rec.MOVEMENT_ID);
      dbms_sql.column_value(p_cur_get_CSP, 134, X_CSP_Rec.RESERVATION_QUANTITY);
      dbms_sql.column_value(p_cur_get_CSP, 135, X_CSP_Rec.SHIPPED_QUANTITY);
      dbms_sql.column_value(p_cur_get_CSP, 136, X_CSP_Rec.TRANSACTION_LINE_NUMBER);
      dbms_sql.column_value(p_cur_get_CSP, 137, X_CSP_Rec.TASK_ID);
      dbms_sql.column_value(p_cur_get_CSP, 138, X_CSP_Rec.TO_TASK_ID);
      dbms_sql.column_value(p_cur_get_CSP, 139, X_CSP_Rec.SOURCE_TASK_ID);
      dbms_sql.column_value(p_cur_get_CSP, 140, X_CSP_Rec.PROJECT_ID);
      dbms_sql.column_value(p_cur_get_CSP, 141, X_CSP_Rec.SOURCE_PROJECT_ID);
      dbms_sql.column_value(p_cur_get_CSP, 142, X_CSP_Rec.PA_EXPENDITURE_ORG_ID);
      dbms_sql.column_value(p_cur_get_CSP, 143, X_CSP_Rec.TO_PROJECT_ID);
      dbms_sql.column_value(p_cur_get_CSP, 144, X_CSP_Rec.EXPENDITURE_TYPE);
      dbms_sql.column_value(p_cur_get_CSP, 145, X_CSP_Rec.FINAL_COMPLETION_FLAG);
      dbms_sql.column_value(p_cur_get_CSP, 146, X_CSP_Rec.TRANSFER_PERCENTAGE);
      dbms_sql.column_value(p_cur_get_CSP, 147, X_CSP_Rec.TRANSACTION_SEQUENCE_ID);
      dbms_sql.column_value(p_cur_get_CSP, 148, X_CSP_Rec.MATERIAL_ACCOUNT);
      dbms_sql.column_value(p_cur_get_CSP, 149, X_CSP_Rec.MATERIAL_OVERHEAD_ACCOUNT);
      dbms_sql.column_value(p_cur_get_CSP, 150, X_CSP_Rec.RESOURCE_ACCOUNT);
      dbms_sql.column_value(p_cur_get_CSP, 151, X_CSP_Rec.OUTSIDE_PROCESSING_ACCOUNT);
      dbms_sql.column_value(p_cur_get_CSP, 152, X_CSP_Rec.OVERHEAD_ACCOUNT);
      dbms_sql.column_value(p_cur_get_CSP, 153, X_CSP_Rec.FLOW_SCHEDULE);
      dbms_sql.column_value(p_cur_get_CSP, 154, X_CSP_Rec.COST_GROUP_ID);
      dbms_sql.column_value(p_cur_get_CSP, 155, X_CSP_Rec.DEMAND_CLASS);
      dbms_sql.column_value(p_cur_get_CSP, 156, X_CSP_Rec.QA_COLLECTION_ID);
      dbms_sql.column_value(p_cur_get_CSP, 157, X_CSP_Rec.KANBAN_CARD_ID);
      dbms_sql.column_value(p_cur_get_CSP, 158, X_CSP_Rec.OVERCOMPLETION_TRANSACTION_ID);
      dbms_sql.column_value(p_cur_get_CSP, 159, X_CSP_Rec.OVERCOMPLETION_PRIMARY_QTY);
      dbms_sql.column_value(p_cur_get_CSP, 160, X_CSP_Rec.OVERCOMPLETION_TRANSACTION_QTY);
      dbms_sql.column_value(p_cur_get_CSP, 161, X_CSP_Rec.PROCESS_TYPE);
      dbms_sql.column_value(p_cur_get_CSP, 162, X_CSP_Rec.END_ITEM_UNIT_NUMBER);
      dbms_sql.column_value(p_cur_get_CSP, 163, X_CSP_Rec.SCHEDULED_PAYBACK_DATE);
      dbms_sql.column_value(p_cur_get_CSP, 164, X_CSP_Rec.LINE_TYPE_CODE);
      dbms_sql.column_value(p_cur_get_CSP, 165, X_CSP_Rec.PARENT_TRANSACTION_TEMP_ID);
      dbms_sql.column_value(p_cur_get_CSP, 166, X_CSP_Rec.PUT_AWAY_STRATEGY_ID);
      dbms_sql.column_value(p_cur_get_CSP, 167, X_CSP_Rec.PUT_AWAY_RULE_ID);
      dbms_sql.column_value(p_cur_get_CSP, 168, X_CSP_Rec.PICK_STRATEGY_ID);
      dbms_sql.column_value(p_cur_get_CSP, 169, X_CSP_Rec.PICK_RULE_ID);
      dbms_sql.column_value(p_cur_get_CSP, 170, X_CSP_Rec.COMMON_BOM_SEQ_ID);
      dbms_sql.column_value(p_cur_get_CSP, 171, X_CSP_Rec.COMMON_ROUTING_SEQ_ID);
      dbms_sql.column_value(p_cur_get_CSP, 172, X_CSP_Rec.COST_TYPE_ID);
      dbms_sql.column_value(p_cur_get_CSP, 173, X_CSP_Rec.ORG_COST_GROUP_ID);
      dbms_sql.column_value(p_cur_get_CSP, 174, X_CSP_Rec.MOVE_ORDER_LINE_ID);
      dbms_sql.column_value(p_cur_get_CSP, 175, X_CSP_Rec.TASK_GROUP_ID);
      dbms_sql.column_value(p_cur_get_CSP, 176, X_CSP_Rec.PICK_SLIP_NUMBER);
      dbms_sql.column_value(p_cur_get_CSP, 177, X_CSP_Rec.RESERVATION_ID);
      dbms_sql.column_value(p_cur_get_CSP, 178, X_CSP_Rec.TRANSACTION_STATUS);

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Get Column Values Ends');
END Get_Column_Values;

PROCEDURE Gen_CSP_order_cl(
    p_order_by_rec   IN   CSP_MATERIAL_TRANSACTIONS_PUB.CSP_sort_rec_type,
    x_order_by_cl    OUT NOCOPY  VARCHAR2,
    x_return_status  OUT NOCOPY  VARCHAR2,
    x_msg_count      OUT NOCOPY  NUMBER,
    x_msg_data       OUT NOCOPY  VARCHAR2
)
IS
l_order_by_cl        VARCHAR2(1000)   := NULL;
l_util_order_by_tbl  JTF_PLSQL_API.Util_order_by_tbl_type;
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Order by Begins');

      -- Hint: Developer should add more statements according to CSP_sort_rec_type
      -- Ex:
      -- l_util_order_by_tbl(1).col_choice := p_order_by_rec.customer_name;
      -- l_util_order_by_tbl(1).col_name := 'Customer_Name';

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Invoke JTF_PLSQL_API.Translate_OrderBy');

      JTF_PLSQL_API.Translate_OrderBy(
          p_api_version_number   =>   1.0
         ,p_init_msg_list        =>   FND_API.G_FALSE
         ,p_validation_level     =>   FND_API.G_VALID_LEVEL_FULL
         ,p_order_by_tbl         =>   l_util_order_by_tbl
         ,x_order_by_clause      =>   l_order_by_cl
         ,x_return_status        =>   x_return_status
         ,x_msg_count            =>   x_msg_count
         ,x_msg_data             =>   x_msg_data);

      IF(l_order_by_cl IS NOT NULL) THEN
          x_order_by_cl := 'order by' || l_order_by_cl;
      ELSE
          x_order_by_cl := NULL;
      END IF;

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Order by Ends');
END Gen_CSP_order_cl;

-- This procedure bind the variables for the Dynamic SQL
PROCEDURE Bind(
    P_CSP_Rec   IN   CSP_MATERIAL_TRANSACTIONS_PUB.CSP_Rec_Type,
    -- Hint: Add more binding variables here
    p_cur_get_CSP   IN   NUMBER
)
IS
BEGIN
      -- Bind variables
      -- Only those that are not NULL
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Bind Variables Begins');

      -- The following example applies to all columns,
      -- developers can copy and paste them.
      IF( (P_CSP_Rec.TRANSACTION_HEADER_ID IS NOT NULL) AND (P_CSP_Rec.TRANSACTION_HEADER_ID <> FND_API.G_MISS_NUM) )
      THEN
          DBMS_SQL.BIND_VARIABLE(p_cur_get_CSP, ':p_TRANSACTION_HEADER_ID', P_CSP_Rec.TRANSACTION_HEADER_ID);
      END IF;

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Bind Variables Ends');
END Bind;

PROCEDURE Gen_Select(
    x_select_cl   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Select Begins');

      x_select_cl := 'Select ' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSACTION_HEADER_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSACTION_TEMP_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.SOURCE_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.SOURCE_LINE_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSACTION_MODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.LOCK_FLAG,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.LAST_UPDATE_DATE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.LAST_UPDATED_BY,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.CREATION_DATE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.CREATED_BY,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.LAST_UPDATE_LOGIN,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.REQUEST_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.PROGRAM_APPLICATION_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.PROGRAM_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.PROGRAM_UPDATE_DATE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.INVENTORY_ITEM_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.REVISION,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ORGANIZATION_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.SUBINVENTORY_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.LOCATOR_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSACTION_QUANTITY,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.PRIMARY_QUANTITY,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSACTION_UOM,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSACTION_COST,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSACTION_TYPE_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSACTION_ACTION_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSACTION_SOURCE_TYPE_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSACTION_SOURCE_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSACTION_SOURCE_NAME,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSACTION_DATE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ACCT_PERIOD_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.DISTRIBUTION_ACCOUNT_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSACTION_REFERENCE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.REQUISITION_LINE_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.REQUISITION_DISTRIBUTION_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.REASON_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.LOT_NUMBER,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.LOT_EXPIRATION_DATE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.SERIAL_NUMBER,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.RECEIVING_DOCUMENT,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.DEMAND_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.RCV_TRANSACTION_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.MOVE_TRANSACTION_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.COMPLETION_TRANSACTION_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.WIP_ENTITY_TYPE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.SCHEDULE_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.REPETITIVE_LINE_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.EMPLOYEE_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.PRIMARY_SWITCH,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.SCHEDULE_UPDATE_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.SETUP_TEARDOWN_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ITEM_ORDERING,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.NEGATIVE_REQ_FLAG,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.OPERATION_SEQ_NUM,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.PICKING_LINE_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRX_SOURCE_LINE_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRX_SOURCE_DELIVERY_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.PHYSICAL_ADJUSTMENT_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.CYCLE_COUNT_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.RMA_LINE_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.CUSTOMER_SHIP_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.CURRENCY_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.CURRENCY_CONVERSION_RATE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.CURRENCY_CONVERSION_TYPE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.CURRENCY_CONVERSION_DATE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.USSGL_TRANSACTION_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.VENDOR_LOT_NUMBER,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ENCUMBRANCE_ACCOUNT,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ENCUMBRANCE_AMOUNT,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.SHIP_TO_LOCATION,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.SHIPMENT_NUMBER,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSFER_COST,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSPORTATION_COST,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSPORTATION_ACCOUNT,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.FREIGHT_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.CONTAINERS,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.WAYBILL_AIRBILL,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.EXPECTED_ARRIVAL_DATE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSFER_SUBINVENTORY,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSFER_ORGANIZATION,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSFER_TO_LOCATION,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.NEW_AVERAGE_COST,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.VALUE_CHANGE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.PERCENTAGE_CHANGE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.MATERIAL_ALLOCATION_TEMP_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.DEMAND_SOURCE_HEADER_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.DEMAND_SOURCE_LINE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.DEMAND_SOURCE_DELIVERY,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ITEM_SEGMENTS,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ITEM_DESCRIPTION,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ITEM_TRX_ENABLED_FLAG,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ITEM_LOCATION_CONTROL_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ITEM_RESTRICT_SUBINV_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ITEM_RESTRICT_LOCATORS_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ITEM_REVISION_QTY_CONTROL_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ITEM_PRIMARY_UOM_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ITEM_UOM_CLASS,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ITEM_SHELF_LIFE_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ITEM_SHELF_LIFE_DAYS,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ITEM_LOT_CONTROL_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ITEM_SERIAL_CONTROL_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ITEM_INVENTORY_ASSET_FLAG,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ALLOWED_UNITS_LOOKUP_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.DEPARTMENT_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.DEPARTMENT_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.WIP_SUPPLY_TYPE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.SUPPLY_SUBINVENTORY,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.SUPPLY_LOCATOR_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.VALID_SUBINVENTORY_FLAG,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.VALID_LOCATOR_FLAG,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.LOCATOR_SEGMENTS,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.CURRENT_LOCATOR_CONTROL_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.NUMBER_OF_LOTS_ENTERED,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.WIP_COMMIT_FLAG,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.NEXT_LOT_NUMBER,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.LOT_ALPHA_PREFIX,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.NEXT_SERIAL_NUMBER,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.SERIAL_ALPHA_PREFIX,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.SHIPPABLE_FLAG,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.POSTING_FLAG,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.REQUIRED_FLAG,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.PROCESS_FLAG,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ERROR_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ERROR_EXPLANATION,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ATTRIBUTE_CATEGORY,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ATTRIBUTE1,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ATTRIBUTE2,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ATTRIBUTE3,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ATTRIBUTE4,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ATTRIBUTE5,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ATTRIBUTE6,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ATTRIBUTE7,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ATTRIBUTE8,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ATTRIBUTE9,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ATTRIBUTE10,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ATTRIBUTE11,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ATTRIBUTE12,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ATTRIBUTE13,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ATTRIBUTE14,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ATTRIBUTE15,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.MOVEMENT_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.RESERVATION_QUANTITY,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.SHIPPED_QUANTITY,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSACTION_LINE_NUMBER,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TASK_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TO_TASK_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.SOURCE_TASK_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.PROJECT_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.SOURCE_PROJECT_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.PA_EXPENDITURE_ORG_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TO_PROJECT_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.EXPENDITURE_TYPE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.FINAL_COMPLETION_FLAG,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSFER_PERCENTAGE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSACTION_SEQUENCE_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.MATERIAL_ACCOUNT,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.MATERIAL_OVERHEAD_ACCOUNT,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.RESOURCE_ACCOUNT,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.OUTSIDE_PROCESSING_ACCOUNT,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.OVERHEAD_ACCOUNT,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.FLOW_SCHEDULE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.COST_GROUP_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.DEMAND_CLASS,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.QA_COLLECTION_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.KANBAN_CARD_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.OVERCOMPLETION_TRANSACTION_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.OVERCOMPLETION_PRIMARY_QTY,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.OVERCOMPLETION_TRANSACTION_QTY,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.PROCESS_TYPE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.END_ITEM_UNIT_NUMBER,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.SCHEDULED_PAYBACK_DATE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.LINE_TYPE_CODE,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.PARENT_TRANSACTION_TEMP_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.PUT_AWAY_STRATEGY_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.PUT_AWAY_RULE_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.PICK_STRATEGY_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.PICK_RULE_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.COMMON_BOM_SEQ_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.COMMON_ROUTING_SEQ_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.COST_TYPE_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.ORG_COST_GROUP_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.MOVE_ORDER_LINE_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TASK_GROUP_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.PICK_SLIP_NUMBER,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.RESERVATION_ID,' ||
                'CSP_MATERIAL_TRANSACTIONS_V.TRANSACTION_STATUS,' ||
                'from CSP_MATERIAL_TRANSACTIONS_V';
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Select Ends');

END Gen_Select;

PROCEDURE Gen_CSP_Where(
    P_CSP_Rec     IN   CSP_MATERIAL_TRANSACTIONS_PUB.CSP_Rec_Type,
    x_CSP_where   OUT NOCOPY   VARCHAR2
)
IS
-- cursors to check if wildcard values '%' and '_' have been passed
-- as item values
CURSOR c_chk_str1(p_rec_item VARCHAR2) IS
    SELECT INSTR(p_rec_item, '%', 1, 1)
    FROM DUAL;
CURSOR c_chk_str2(p_rec_item VARCHAR2) IS
    SELECT INSTR(p_rec_item, '_', 1, 1)
    FROM DUAL;

-- return values from cursors
str_csr1   NUMBER;
str_csr2   NUMBER;
l_operator VARCHAR2(10);
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Where Begins');

      -- There are three examples for each kind of datatype:
      -- NUMBER, DATE, VARCHAR2.
      -- Developer can copy and paste the following codes for your own record.

      -- example for NUMBER datatype
      IF( (P_CSP_Rec.TRANSACTION_HEADER_ID IS NOT NULL) AND (P_CSP_Rec.TRANSACTION_HEADER_ID <> FND_API.G_MISS_NUM) )
      THEN
          IF(x_CSP_where IS NULL) THEN
              x_CSP_where := 'Where';
          ELSE
              x_CSP_where := x_CSP_where || ' AND ';
          END IF;
          x_CSP_where := x_CSP_where || 'P_CSP_Rec.TRANSACTION_HEADER_ID = :p_TRANSACTION_HEADER_ID';
      END IF;

      -- example for DATE datatype
      IF( (P_CSP_Rec.LAST_UPDATE_DATE IS NOT NULL) AND (P_CSP_Rec.LAST_UPDATE_DATE <> FND_API.G_MISS_DATE) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_CSP_Rec.LAST_UPDATE_DATE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_CSP_Rec.LAST_UPDATE_DATE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_CSP_where IS NULL) THEN
              x_CSP_where := 'Where ';
          ELSE
              x_CSP_where := x_CSP_where || ' AND ';
          END IF;
          x_CSP_where := x_CSP_where || 'P_CSP_Rec.LAST_UPDATE_DATE ' || l_operator || ' :p_LAST_UPDATE_DATE';
      END IF;

      -- example for VARCHAR2 datatype
      IF( (P_CSP_Rec.SOURCE_CODE IS NOT NULL) AND (P_CSP_Rec.SOURCE_CODE <> FND_API.G_MISS_CHAR) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_CSP_Rec.SOURCE_CODE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_CSP_Rec.SOURCE_CODE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_CSP_where IS NULL) THEN
              x_CSP_where := 'Where ';
          ELSE
              x_CSP_where := x_CSP_where || ' AND ';
          END IF;
          x_CSP_where := x_CSP_where || 'P_CSP_Rec.SOURCE_CODE ' || l_operator || ' :p_SOURCE_CODE';
      END IF;

      -- Add more IF statements for each column below

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Where Ends');

END Gen_CSP_Where;

-- Item-level validation procedures
PROCEDURE Validate_TRANSACTION_HEADER_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSACTION_HEADER_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_HEADER_ID is not NULL and p_TRANSACTION_HEADER_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_HEADER_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSACTION_HEADER_ID;


PROCEDURE Validate_TRANSACTION_TEMP_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSACTION_TEMP_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_TEMP_ID is not NULL and p_TRANSACTION_TEMP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_TEMP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSACTION_TEMP_ID;


PROCEDURE Validate_SOURCE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SOURCE_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SOURCE_CODE is not NULL and p_SOURCE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SOURCE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SOURCE_CODE;


PROCEDURE Validate_SOURCE_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SOURCE_LINE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SOURCE_LINE_ID is not NULL and p_SOURCE_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SOURCE_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SOURCE_LINE_ID;


PROCEDURE Validate_TRANSACTION_MODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSACTION_MODE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_MODE is not NULL and p_TRANSACTION_MODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_MODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSACTION_MODE;


PROCEDURE Validate_LOCK_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LOCK_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_LOCK_FLAG is not NULL and p_LOCK_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_LOCK_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LOCK_FLAG;


PROCEDURE Validate_REQUEST_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REQUEST_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUEST_ID is not NULL and p_REQUEST_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUEST_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REQUEST_ID;


PROCEDURE Validate_INVENTORY_ITEM_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INVENTORY_ITEM_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_INVENTORY_ITEM_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message('ERROR', 'Private material_transactions API: -Violate NOT NULL constraint(INVENTORY_ITEM_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_INVENTORY_ITEM_ID is not NULL and p_INVENTORY_ITEM_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_INVENTORY_ITEM_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_INVENTORY_ITEM_ID;


PROCEDURE Validate_REVISION (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REVISION                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_REVISION is not NULL and p_REVISION <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REVISION <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REVISION;


PROCEDURE Validate_ORGANIZATION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ORGANIZATION_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_ORGANIZATION_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message('ERROR', 'Private material_transactions API: -Violate NOT NULL constraint(ORGANIZATION_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ORGANIZATION_ID is not NULL and p_ORGANIZATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ORGANIZATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ORGANIZATION_ID;


PROCEDURE Validate_SUBINVENTORY_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SUBINVENTORY_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SUBINVENTORY_CODE is not NULL and p_SUBINVENTORY_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SUBINVENTORY_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SUBINVENTORY_CODE;


PROCEDURE Validate_LOCATOR_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LOCATOR_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_LOCATOR_ID is not NULL and p_LOCATOR_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_LOCATOR_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LOCATOR_ID;


PROCEDURE Validate_TRANSACTION_QUANTITY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSACTION_QUANTITY                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_TRANSACTION_QUANTITY is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message('ERROR', 'Private material_transactions API: -Violate NOT NULL constraint(TRANSACTION_QUANTITY)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_QUANTITY is not NULL and p_TRANSACTION_QUANTITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_QUANTITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSACTION_QUANTITY;


PROCEDURE Validate_PRIMARY_QUANTITY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRIMARY_QUANTITY                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_PRIMARY_QUANTITY is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message('ERROR', 'Private material_transactions API: -Violate NOT NULL constraint(PRIMARY_QUANTITY)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PRIMARY_QUANTITY is not NULL and p_PRIMARY_QUANTITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PRIMARY_QUANTITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PRIMARY_QUANTITY;


PROCEDURE Validate_TRANSACTION_UOM (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSACTION_UOM                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_TRANSACTION_UOM is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message('ERROR', 'Private material_transactions API: -Violate NOT NULL constraint(TRANSACTION_UOM)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_UOM is not NULL and p_TRANSACTION_UOM <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_UOM <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSACTION_UOM;


PROCEDURE Validate_TRANSACTION_COST (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSACTION_COST                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_COST is not NULL and p_TRANSACTION_COST <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_COST <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSACTION_COST;


PROCEDURE Validate_TRANSACTION_TYPE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSACTION_TYPE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_TRANSACTION_TYPE_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message('ERROR', 'Private material_transactions API: -Violate NOT NULL constraint(TRANSACTION_TYPE_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_TYPE_ID is not NULL and p_TRANSACTION_TYPE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_TYPE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSACTION_TYPE_ID;


PROCEDURE Validate_TRANSACTION_ACTION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSACTION_ACTION_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_TRANSACTION_ACTION_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message('ERROR', 'Private material_transactions API: -Violate NOT NULL constraint(TRANSACTION_ACTION_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_ACTION_ID is not NULL and p_TRANSACTION_ACTION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_ACTION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSACTION_ACTION_ID;


PROCEDURE Validate_TRANSACTION_SOURCE_TYPE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSACTION_SOURCE_TYPE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_TRANSACTION_SOURCE_TYPE_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message('ERROR', 'Private material_transactions API: -Violate NOT NULL constraint(TRANSACTION_SOURCE_TYPE_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_SOURCE_TYPE_ID is not NULL and p_TRANSACTION_SOURCE_TYPE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_SOURCE_TYPE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSACTION_SOURCE_TYPE_ID;


PROCEDURE Validate_TRANSACTION_SOURCE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSACTION_SOURCE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_SOURCE_ID is not NULL and p_TRANSACTION_SOURCE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_SOURCE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSACTION_SOURCE_ID;


PROCEDURE Validate_TRANSACTION_SOURCE_NAME (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSACTION_SOURCE_NAME                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_SOURCE_NAME is not NULL and p_TRANSACTION_SOURCE_NAME <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_SOURCE_NAME <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSACTION_SOURCE_NAME;


PROCEDURE Validate_TRANSACTION_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSACTION_DATE                IN   DATE,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_TRANSACTION_DATE is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message('ERROR', 'Private material_transactions API: -Violate NOT NULL constraint(TRANSACTION_DATE)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_DATE is not NULL and p_TRANSACTION_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSACTION_DATE;


PROCEDURE Validate_ACCT_PERIOD_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ACCT_PERIOD_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_ACCT_PERIOD_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message('ERROR', 'Private material_transactions API: -Violate NOT NULL constraint(ACCT_PERIOD_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ACCT_PERIOD_ID is not NULL and p_ACCT_PERIOD_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ACCT_PERIOD_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ACCT_PERIOD_ID;


PROCEDURE Validate_DISTRIBUTION_ACCOUNT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DISTRIBUTION_ACCOUNT_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_DISTRIBUTION_ACCOUNT_ID is not NULL and p_DISTRIBUTION_ACCOUNT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_DISTRIBUTION_ACCOUNT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DISTRIBUTION_ACCOUNT_ID;


PROCEDURE Validate_TRANSACTION_REFERENCE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSACTION_REFERENCE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_REFERENCE is not NULL and p_TRANSACTION_REFERENCE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_REFERENCE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSACTION_REFERENCE;


PROCEDURE Validate_REQUISITION_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REQUISITION_LINE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUISITION_LINE_ID is not NULL and p_REQUISITION_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUISITION_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REQUISITION_LINE_ID;


PROCEDURE Validate_REQUISITION_DISTRIBUTION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REQUISITION_DISTRIBUTION_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUISITION_DISTRIBUTION_ID is not NULL and p_REQUISITION_DISTRIBUTION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUISITION_DISTRIBUTION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REQUISITION_DISTRIBUTION_ID;


PROCEDURE Validate_REASON_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REASON_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_REASON_ID is not NULL and p_REASON_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REASON_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REASON_ID;


PROCEDURE Validate_LOT_NUMBER (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LOT_NUMBER                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_LOT_NUMBER is not NULL and p_LOT_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_LOT_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LOT_NUMBER;


PROCEDURE Validate_LOT_EXPIRATION_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LOT_EXPIRATION_DATE                IN   DATE,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_LOT_EXPIRATION_DATE is not NULL and p_LOT_EXPIRATION_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_LOT_EXPIRATION_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LOT_EXPIRATION_DATE;


PROCEDURE Validate_SERIAL_NUMBER (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SERIAL_NUMBER                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SERIAL_NUMBER is not NULL and p_SERIAL_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SERIAL_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SERIAL_NUMBER;


PROCEDURE Validate_RECEIVING_DOCUMENT (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RECEIVING_DOCUMENT                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_RECEIVING_DOCUMENT is not NULL and p_RECEIVING_DOCUMENT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_RECEIVING_DOCUMENT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RECEIVING_DOCUMENT;


PROCEDURE Validate_DEMAND_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DEMAND_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_DEMAND_ID is not NULL and p_DEMAND_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_DEMAND_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DEMAND_ID;


PROCEDURE Validate_RCV_TRANSACTION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RCV_TRANSACTION_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_RCV_TRANSACTION_ID is not NULL and p_RCV_TRANSACTION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_RCV_TRANSACTION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RCV_TRANSACTION_ID;


PROCEDURE Validate_MOVE_TRANSACTION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_MOVE_TRANSACTION_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_MOVE_TRANSACTION_ID is not NULL and p_MOVE_TRANSACTION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_MOVE_TRANSACTION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_MOVE_TRANSACTION_ID;


PROCEDURE Validate_COMPLETION_TRANSACTION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_COMPLETION_TRANSACTION_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_COMPLETION_TRANSACTION_ID is not NULL and p_COMPLETION_TRANSACTION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_COMPLETION_TRANSACTION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_COMPLETION_TRANSACTION_ID;


PROCEDURE Validate_WIP_ENTITY_TYPE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_WIP_ENTITY_TYPE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_WIP_ENTITY_TYPE is not NULL and p_WIP_ENTITY_TYPE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_WIP_ENTITY_TYPE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_WIP_ENTITY_TYPE;


PROCEDURE Validate_SCHEDULE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SCHEDULE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SCHEDULE_ID is not NULL and p_SCHEDULE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SCHEDULE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SCHEDULE_ID;


PROCEDURE Validate_REPETITIVE_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REPETITIVE_LINE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_REPETITIVE_LINE_ID is not NULL and p_REPETITIVE_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REPETITIVE_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REPETITIVE_LINE_ID;


PROCEDURE Validate_EMPLOYEE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_EMPLOYEE_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_EMPLOYEE_CODE is not NULL and p_EMPLOYEE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_EMPLOYEE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_EMPLOYEE_CODE;


PROCEDURE Validate_PRIMARY_SWITCH (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRIMARY_SWITCH                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PRIMARY_SWITCH is not NULL and p_PRIMARY_SWITCH <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PRIMARY_SWITCH <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PRIMARY_SWITCH;


PROCEDURE Validate_SCHEDULE_UPDATE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SCHEDULE_UPDATE_CODE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SCHEDULE_UPDATE_CODE is not NULL and p_SCHEDULE_UPDATE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SCHEDULE_UPDATE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SCHEDULE_UPDATE_CODE;


PROCEDURE Validate_SETUP_TEARDOWN_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SETUP_TEARDOWN_CODE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SETUP_TEARDOWN_CODE is not NULL and p_SETUP_TEARDOWN_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SETUP_TEARDOWN_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SETUP_TEARDOWN_CODE;


PROCEDURE Validate_ITEM_ORDERING (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ITEM_ORDERING                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_ORDERING is not NULL and p_ITEM_ORDERING <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_ORDERING <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ITEM_ORDERING;


PROCEDURE Validate_NEGATIVE_REQ_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_NEGATIVE_REQ_FLAG                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_NEGATIVE_REQ_FLAG is not NULL and p_NEGATIVE_REQ_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_NEGATIVE_REQ_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_NEGATIVE_REQ_FLAG;


PROCEDURE Validate_OPERATION_SEQ_NUM (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_OPERATION_SEQ_NUM                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_OPERATION_SEQ_NUM is not NULL and p_OPERATION_SEQ_NUM <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_OPERATION_SEQ_NUM <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_OPERATION_SEQ_NUM;


PROCEDURE Validate_PICKING_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PICKING_LINE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PICKING_LINE_ID is not NULL and p_PICKING_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PICKING_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PICKING_LINE_ID;


PROCEDURE Validate_TRX_SOURCE_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRX_SOURCE_LINE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRX_SOURCE_LINE_ID is not NULL and p_TRX_SOURCE_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRX_SOURCE_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRX_SOURCE_LINE_ID;


PROCEDURE Validate_TRX_SOURCE_DELIVERY_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRX_SOURCE_DELIVERY_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRX_SOURCE_DELIVERY_ID is not NULL and p_TRX_SOURCE_DELIVERY_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRX_SOURCE_DELIVERY_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRX_SOURCE_DELIVERY_ID;


PROCEDURE Validate_PHYSICAL_ADJUSTMENT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PHYSICAL_ADJUSTMENT_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PHYSICAL_ADJUSTMENT_ID is not NULL and p_PHYSICAL_ADJUSTMENT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PHYSICAL_ADJUSTMENT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PHYSICAL_ADJUSTMENT_ID;


PROCEDURE Validate_CYCLE_COUNT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CYCLE_COUNT_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_CYCLE_COUNT_ID is not NULL and p_CYCLE_COUNT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CYCLE_COUNT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CYCLE_COUNT_ID;


PROCEDURE Validate_RMA_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RMA_LINE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_RMA_LINE_ID is not NULL and p_RMA_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_RMA_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RMA_LINE_ID;


PROCEDURE Validate_CUSTOMER_SHIP_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CUSTOMER_SHIP_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_CUSTOMER_SHIP_ID is not NULL and p_CUSTOMER_SHIP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CUSTOMER_SHIP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CUSTOMER_SHIP_ID;


PROCEDURE Validate_CURRENCY_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CURRENCY_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_CURRENCY_CODE is not NULL and p_CURRENCY_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CURRENCY_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CURRENCY_CODE;


PROCEDURE Validate_CURRENCY_CONVERSION_RATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CURRENCY_CONVERSION_RATE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_CURRENCY_CONVERSION_RATE is not NULL and p_CURRENCY_CONVERSION_RATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CURRENCY_CONVERSION_RATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CURRENCY_CONVERSION_RATE;


PROCEDURE Validate_CURRENCY_CONVERSION_TYPE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CURRENCY_CONVERSION_TYPE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_CURRENCY_CONVERSION_TYPE is not NULL and p_CURRENCY_CONVERSION_TYPE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CURRENCY_CONVERSION_TYPE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CURRENCY_CONVERSION_TYPE;


PROCEDURE Validate_CURRENCY_CONVERSION_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CURRENCY_CONVERSION_DATE                IN   DATE,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_CURRENCY_CONVERSION_DATE is not NULL and p_CURRENCY_CONVERSION_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CURRENCY_CONVERSION_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CURRENCY_CONVERSION_DATE;


PROCEDURE Validate_USSGL_TRANSACTION_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_USSGL_TRANSACTION_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_USSGL_TRANSACTION_CODE is not NULL and p_USSGL_TRANSACTION_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_USSGL_TRANSACTION_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_USSGL_TRANSACTION_CODE;


PROCEDURE Validate_VENDOR_LOT_NUMBER (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_VENDOR_LOT_NUMBER                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_VENDOR_LOT_NUMBER is not NULL and p_VENDOR_LOT_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_VENDOR_LOT_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_VENDOR_LOT_NUMBER;


PROCEDURE Validate_ENCUMBRANCE_ACCOUNT (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ENCUMBRANCE_ACCOUNT                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ENCUMBRANCE_ACCOUNT is not NULL and p_ENCUMBRANCE_ACCOUNT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ENCUMBRANCE_ACCOUNT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ENCUMBRANCE_ACCOUNT;


PROCEDURE Validate_ENCUMBRANCE_AMOUNT (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ENCUMBRANCE_AMOUNT                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ENCUMBRANCE_AMOUNT is not NULL and p_ENCUMBRANCE_AMOUNT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ENCUMBRANCE_AMOUNT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ENCUMBRANCE_AMOUNT;


PROCEDURE Validate_SHIP_TO_LOCATION (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SHIP_TO_LOCATION                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SHIP_TO_LOCATION is not NULL and p_SHIP_TO_LOCATION <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SHIP_TO_LOCATION <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SHIP_TO_LOCATION;


PROCEDURE Validate_SHIPMENT_NUMBER (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SHIPMENT_NUMBER                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SHIPMENT_NUMBER is not NULL and p_SHIPMENT_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SHIPMENT_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SHIPMENT_NUMBER;


PROCEDURE Validate_TRANSFER_COST (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSFER_COST                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSFER_COST is not NULL and p_TRANSFER_COST <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSFER_COST <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSFER_COST;


PROCEDURE Validate_TRANSPORTATION_COST (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSPORTATION_COST                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSPORTATION_COST is not NULL and p_TRANSPORTATION_COST <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSPORTATION_COST <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSPORTATION_COST;


PROCEDURE Validate_TRANSPORTATION_ACCOUNT (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSPORTATION_ACCOUNT                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSPORTATION_ACCOUNT is not NULL and p_TRANSPORTATION_ACCOUNT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSPORTATION_ACCOUNT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSPORTATION_ACCOUNT;


PROCEDURE Validate_FREIGHT_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_FREIGHT_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_FREIGHT_CODE is not NULL and p_FREIGHT_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_FREIGHT_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_FREIGHT_CODE;


PROCEDURE Validate_CONTAINERS (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CONTAINERS                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_CONTAINERS is not NULL and p_CONTAINERS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CONTAINERS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CONTAINERS;


PROCEDURE Validate_WAYBILL_AIRBILL (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_WAYBILL_AIRBILL                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_WAYBILL_AIRBILL is not NULL and p_WAYBILL_AIRBILL <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_WAYBILL_AIRBILL <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_WAYBILL_AIRBILL;


PROCEDURE Validate_EXPECTED_ARRIVAL_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_EXPECTED_ARRIVAL_DATE                IN   DATE,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_EXPECTED_ARRIVAL_DATE is not NULL and p_EXPECTED_ARRIVAL_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_EXPECTED_ARRIVAL_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_EXPECTED_ARRIVAL_DATE;


PROCEDURE Validate_TRANSFER_SUBINVENTORY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSFER_SUBINVENTORY                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSFER_SUBINVENTORY is not NULL and p_TRANSFER_SUBINVENTORY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSFER_SUBINVENTORY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSFER_SUBINVENTORY;


PROCEDURE Validate_TRANSFER_ORGANIZATION (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSFER_ORGANIZATION                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSFER_ORGANIZATION is not NULL and p_TRANSFER_ORGANIZATION <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSFER_ORGANIZATION <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSFER_ORGANIZATION;


PROCEDURE Validate_TRANSFER_TO_LOCATION (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSFER_TO_LOCATION                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSFER_TO_LOCATION is not NULL and p_TRANSFER_TO_LOCATION <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSFER_TO_LOCATION <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSFER_TO_LOCATION;


PROCEDURE Validate_NEW_AVERAGE_COST (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_NEW_AVERAGE_COST                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_NEW_AVERAGE_COST is not NULL and p_NEW_AVERAGE_COST <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_NEW_AVERAGE_COST <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_NEW_AVERAGE_COST;


PROCEDURE Validate_VALUE_CHANGE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_VALUE_CHANGE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_VALUE_CHANGE is not NULL and p_VALUE_CHANGE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_VALUE_CHANGE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_VALUE_CHANGE;


PROCEDURE Validate_PERCENTAGE_CHANGE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PERCENTAGE_CHANGE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PERCENTAGE_CHANGE is not NULL and p_PERCENTAGE_CHANGE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PERCENTAGE_CHANGE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PERCENTAGE_CHANGE;


PROCEDURE Validate_MATERIAL_ALLOCATION_TEMP_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_MATERIAL_ALLOCATION_TEMP_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_MATERIAL_ALLOCATION_TEMP_ID is not NULL and p_MATERIAL_ALLOCATION_TEMP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_MATERIAL_ALLOCATION_TEMP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_MATERIAL_ALLOCATION_TEMP_ID;


PROCEDURE Validate_DEMAND_SOURCE_HEADER_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DEMAND_SOURCE_HEADER_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_DEMAND_SOURCE_HEADER_ID is not NULL and p_DEMAND_SOURCE_HEADER_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_DEMAND_SOURCE_HEADER_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DEMAND_SOURCE_HEADER_ID;


PROCEDURE Validate_DEMAND_SOURCE_LINE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DEMAND_SOURCE_LINE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_DEMAND_SOURCE_LINE is not NULL and p_DEMAND_SOURCE_LINE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_DEMAND_SOURCE_LINE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DEMAND_SOURCE_LINE;


PROCEDURE Validate_DEMAND_SOURCE_DELIVERY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DEMAND_SOURCE_DELIVERY                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_DEMAND_SOURCE_DELIVERY is not NULL and p_DEMAND_SOURCE_DELIVERY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_DEMAND_SOURCE_DELIVERY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DEMAND_SOURCE_DELIVERY;


PROCEDURE Validate_ITEM_SEGMENTS (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ITEM_SEGMENTS                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_SEGMENTS is not NULL and p_ITEM_SEGMENTS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_SEGMENTS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ITEM_SEGMENTS;


PROCEDURE Validate_ITEM_DESCRIPTION (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ITEM_DESCRIPTION                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_DESCRIPTION is not NULL and p_ITEM_DESCRIPTION <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_DESCRIPTION <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ITEM_DESCRIPTION;


PROCEDURE Validate_ITEM_TRX_ENABLED_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ITEM_TRX_ENABLED_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_TRX_ENABLED_FLAG is not NULL and p_ITEM_TRX_ENABLED_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_TRX_ENABLED_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ITEM_TRX_ENABLED_FLAG;


PROCEDURE Validate_ITEM_LOCATION_CONTROL_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ITEM_LOCATION_CONTROL_CODE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_LOCATION_CONTROL_CODE is not NULL and p_ITEM_LOCATION_CONTROL_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_LOCATION_CONTROL_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ITEM_LOCATION_CONTROL_CODE;


PROCEDURE Validate_ITEM_RESTRICT_SUBINV_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ITEM_RESTRICT_SUBINV_CODE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_RESTRICT_SUBINV_CODE is not NULL and p_ITEM_RESTRICT_SUBINV_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_RESTRICT_SUBINV_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ITEM_RESTRICT_SUBINV_CODE;


PROCEDURE Validate_ITEM_RESTRICT_LOCATORS_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ITEM_RESTRICT_LOCATORS_CODE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_RESTRICT_LOCATORS_CODE is not NULL and p_ITEM_RESTRICT_LOCATORS_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_RESTRICT_LOCATORS_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ITEM_RESTRICT_LOCATORS_CODE;


PROCEDURE Validate_ITEM_REVISION_QTY_CONTROL_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ITEM_REVISION_QTY_CONTROL_CODE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_REVISION_QTY_CONTROL_CODE is not NULL and p_ITEM_REVISION_QTY_CONTROL_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_REVISION_QTY_CONTROL_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ITEM_REVISION_QTY_CONTROL_CODE;


PROCEDURE Validate_ITEM_PRIMARY_UOM_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ITEM_PRIMARY_UOM_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_PRIMARY_UOM_CODE is not NULL and p_ITEM_PRIMARY_UOM_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_PRIMARY_UOM_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ITEM_PRIMARY_UOM_CODE;


PROCEDURE Validate_ITEM_UOM_CLASS (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ITEM_UOM_CLASS                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_UOM_CLASS is not NULL and p_ITEM_UOM_CLASS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_UOM_CLASS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ITEM_UOM_CLASS;


PROCEDURE Validate_ITEM_SHELF_LIFE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ITEM_SHELF_LIFE_CODE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_SHELF_LIFE_CODE is not NULL and p_ITEM_SHELF_LIFE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_SHELF_LIFE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ITEM_SHELF_LIFE_CODE;


PROCEDURE Validate_ITEM_SHELF_LIFE_DAYS (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ITEM_SHELF_LIFE_DAYS                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_SHELF_LIFE_DAYS is not NULL and p_ITEM_SHELF_LIFE_DAYS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_SHELF_LIFE_DAYS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ITEM_SHELF_LIFE_DAYS;


PROCEDURE Validate_ITEM_LOT_CONTROL_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ITEM_LOT_CONTROL_CODE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_LOT_CONTROL_CODE is not NULL and p_ITEM_LOT_CONTROL_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_LOT_CONTROL_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ITEM_LOT_CONTROL_CODE;


PROCEDURE Validate_ITEM_SERIAL_CONTROL_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ITEM_SERIAL_CONTROL_CODE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_SERIAL_CONTROL_CODE is not NULL and p_ITEM_SERIAL_CONTROL_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_SERIAL_CONTROL_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ITEM_SERIAL_CONTROL_CODE;


PROCEDURE Validate_ITEM_INVENTORY_ASSET_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ITEM_INVENTORY_ASSET_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_INVENTORY_ASSET_FLAG is not NULL and p_ITEM_INVENTORY_ASSET_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ITEM_INVENTORY_ASSET_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ITEM_INVENTORY_ASSET_FLAG;


PROCEDURE Validate_ALLOWED_UNITS_LOOKUP_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ALLOWED_UNITS_LOOKUP_CODE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ALLOWED_UNITS_LOOKUP_CODE is not NULL and p_ALLOWED_UNITS_LOOKUP_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ALLOWED_UNITS_LOOKUP_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ALLOWED_UNITS_LOOKUP_CODE;


PROCEDURE Validate_DEPARTMENT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DEPARTMENT_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_DEPARTMENT_ID is not NULL and p_DEPARTMENT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_DEPARTMENT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DEPARTMENT_ID;


PROCEDURE Validate_DEPARTMENT_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DEPARTMENT_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_DEPARTMENT_CODE is not NULL and p_DEPARTMENT_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_DEPARTMENT_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DEPARTMENT_CODE;


PROCEDURE Validate_WIP_SUPPLY_TYPE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_WIP_SUPPLY_TYPE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_WIP_SUPPLY_TYPE is not NULL and p_WIP_SUPPLY_TYPE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_WIP_SUPPLY_TYPE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_WIP_SUPPLY_TYPE;


PROCEDURE Validate_SUPPLY_SUBINVENTORY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SUPPLY_SUBINVENTORY                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SUPPLY_SUBINVENTORY is not NULL and p_SUPPLY_SUBINVENTORY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SUPPLY_SUBINVENTORY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SUPPLY_SUBINVENTORY;


PROCEDURE Validate_SUPPLY_LOCATOR_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SUPPLY_LOCATOR_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SUPPLY_LOCATOR_ID is not NULL and p_SUPPLY_LOCATOR_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SUPPLY_LOCATOR_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SUPPLY_LOCATOR_ID;


PROCEDURE Validate_VALID_SUBINVENTORY_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_VALID_SUBINVENTORY_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_VALID_SUBINVENTORY_FLAG is not NULL and p_VALID_SUBINVENTORY_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_VALID_SUBINVENTORY_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_VALID_SUBINVENTORY_FLAG;


PROCEDURE Validate_VALID_LOCATOR_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_VALID_LOCATOR_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_VALID_LOCATOR_FLAG is not NULL and p_VALID_LOCATOR_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_VALID_LOCATOR_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_VALID_LOCATOR_FLAG;


PROCEDURE Validate_LOCATOR_SEGMENTS (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LOCATOR_SEGMENTS                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_LOCATOR_SEGMENTS is not NULL and p_LOCATOR_SEGMENTS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_LOCATOR_SEGMENTS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LOCATOR_SEGMENTS;


PROCEDURE Validate_CURRENT_LOCATOR_CONTROL_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CURRENT_LOCATOR_CONTROL_CODE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_CURRENT_LOCATOR_CONTROL_CODE is not NULL and p_CURRENT_LOCATOR_CONTROL_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CURRENT_LOCATOR_CONTROL_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CURRENT_LOCATOR_CONTROL_CODE;


PROCEDURE Validate_NUMBER_OF_LOTS_ENTERED (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_NUMBER_OF_LOTS_ENTERED                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_NUMBER_OF_LOTS_ENTERED is not NULL and p_NUMBER_OF_LOTS_ENTERED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_NUMBER_OF_LOTS_ENTERED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_NUMBER_OF_LOTS_ENTERED;


PROCEDURE Validate_WIP_COMMIT_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_WIP_COMMIT_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_WIP_COMMIT_FLAG is not NULL and p_WIP_COMMIT_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_WIP_COMMIT_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_WIP_COMMIT_FLAG;


PROCEDURE Validate_NEXT_LOT_NUMBER (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_NEXT_LOT_NUMBER                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_NEXT_LOT_NUMBER is not NULL and p_NEXT_LOT_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_NEXT_LOT_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_NEXT_LOT_NUMBER;


PROCEDURE Validate_LOT_ALPHA_PREFIX (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LOT_ALPHA_PREFIX                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_LOT_ALPHA_PREFIX is not NULL and p_LOT_ALPHA_PREFIX <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_LOT_ALPHA_PREFIX <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LOT_ALPHA_PREFIX;


PROCEDURE Validate_NEXT_SERIAL_NUMBER (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_NEXT_SERIAL_NUMBER                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_NEXT_SERIAL_NUMBER is not NULL and p_NEXT_SERIAL_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_NEXT_SERIAL_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_NEXT_SERIAL_NUMBER;


PROCEDURE Validate_SERIAL_ALPHA_PREFIX (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SERIAL_ALPHA_PREFIX                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SERIAL_ALPHA_PREFIX is not NULL and p_SERIAL_ALPHA_PREFIX <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SERIAL_ALPHA_PREFIX <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SERIAL_ALPHA_PREFIX;


PROCEDURE Validate_SHIPPABLE_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SHIPPABLE_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SHIPPABLE_FLAG is not NULL and p_SHIPPABLE_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SHIPPABLE_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SHIPPABLE_FLAG;


PROCEDURE Validate_POSTING_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_POSTING_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_POSTING_FLAG is not NULL and p_POSTING_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_POSTING_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_POSTING_FLAG;


PROCEDURE Validate_REQUIRED_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REQUIRED_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUIRED_FLAG is not NULL and p_REQUIRED_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUIRED_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REQUIRED_FLAG;


PROCEDURE Validate_PROCESS_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PROCESS_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PROCESS_FLAG is not NULL and p_PROCESS_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PROCESS_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PROCESS_FLAG;


PROCEDURE Validate_ERROR_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ERROR_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ERROR_CODE is not NULL and p_ERROR_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ERROR_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ERROR_CODE;


PROCEDURE Validate_ERROR_EXPLANATION (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ERROR_EXPLANATION                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ERROR_EXPLANATION is not NULL and p_ERROR_EXPLANATION <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ERROR_EXPLANATION <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ERROR_EXPLANATION;


PROCEDURE Validate_MOVEMENT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_MOVEMENT_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_MOVEMENT_ID is not NULL and p_MOVEMENT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_MOVEMENT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_MOVEMENT_ID;


PROCEDURE Validate_RESERVATION_QUANTITY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RESERVATION_QUANTITY                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_RESERVATION_QUANTITY is not NULL and p_RESERVATION_QUANTITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_RESERVATION_QUANTITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RESERVATION_QUANTITY;


PROCEDURE Validate_SHIPPED_QUANTITY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SHIPPED_QUANTITY                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SHIPPED_QUANTITY is not NULL and p_SHIPPED_QUANTITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SHIPPED_QUANTITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SHIPPED_QUANTITY;


PROCEDURE Validate_TRANSACTION_LINE_NUMBER (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSACTION_LINE_NUMBER                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_LINE_NUMBER is not NULL and p_TRANSACTION_LINE_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_LINE_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSACTION_LINE_NUMBER;


PROCEDURE Validate_TASK_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TASK_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TASK_ID is not NULL and p_TASK_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TASK_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TASK_ID;


PROCEDURE Validate_TO_TASK_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TO_TASK_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TO_TASK_ID is not NULL and p_TO_TASK_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TO_TASK_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TO_TASK_ID;


PROCEDURE Validate_SOURCE_TASK_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SOURCE_TASK_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SOURCE_TASK_ID is not NULL and p_SOURCE_TASK_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SOURCE_TASK_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SOURCE_TASK_ID;


PROCEDURE Validate_PROJECT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PROJECT_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PROJECT_ID is not NULL and p_PROJECT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PROJECT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PROJECT_ID;


PROCEDURE Validate_SOURCE_PROJECT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SOURCE_PROJECT_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SOURCE_PROJECT_ID is not NULL and p_SOURCE_PROJECT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SOURCE_PROJECT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SOURCE_PROJECT_ID;


PROCEDURE Validate_PA_EXPENDITURE_ORG_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PA_EXPENDITURE_ORG_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PA_EXPENDITURE_ORG_ID is not NULL and p_PA_EXPENDITURE_ORG_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PA_EXPENDITURE_ORG_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PA_EXPENDITURE_ORG_ID;


PROCEDURE Validate_TO_PROJECT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TO_PROJECT_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TO_PROJECT_ID is not NULL and p_TO_PROJECT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TO_PROJECT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TO_PROJECT_ID;


PROCEDURE Validate_EXPENDITURE_TYPE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_EXPENDITURE_TYPE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_EXPENDITURE_TYPE is not NULL and p_EXPENDITURE_TYPE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_EXPENDITURE_TYPE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_EXPENDITURE_TYPE;


PROCEDURE Validate_FINAL_COMPLETION_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_FINAL_COMPLETION_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_FINAL_COMPLETION_FLAG is not NULL and p_FINAL_COMPLETION_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_FINAL_COMPLETION_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_FINAL_COMPLETION_FLAG;


PROCEDURE Validate_TRANSFER_PERCENTAGE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSFER_PERCENTAGE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSFER_PERCENTAGE is not NULL and p_TRANSFER_PERCENTAGE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSFER_PERCENTAGE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSFER_PERCENTAGE;


PROCEDURE Validate_TRANSACTION_SEQUENCE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSACTION_SEQUENCE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_SEQUENCE_ID is not NULL and p_TRANSACTION_SEQUENCE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_SEQUENCE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSACTION_SEQUENCE_ID;


PROCEDURE Validate_MATERIAL_ACCOUNT (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_MATERIAL_ACCOUNT                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_MATERIAL_ACCOUNT is not NULL and p_MATERIAL_ACCOUNT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_MATERIAL_ACCOUNT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_MATERIAL_ACCOUNT;


PROCEDURE Validate_MATERIAL_OVERHEAD_ACCOUNT (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_MATERIAL_OVERHEAD_ACCOUNT                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_MATERIAL_OVERHEAD_ACCOUNT is not NULL and p_MATERIAL_OVERHEAD_ACCOUNT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_MATERIAL_OVERHEAD_ACCOUNT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_MATERIAL_OVERHEAD_ACCOUNT;


PROCEDURE Validate_RESOURCE_ACCOUNT (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RESOURCE_ACCOUNT                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_RESOURCE_ACCOUNT is not NULL and p_RESOURCE_ACCOUNT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_RESOURCE_ACCOUNT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RESOURCE_ACCOUNT;


PROCEDURE Validate_OUTSIDE_PROCESSING_ACCOUNT (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_OUTSIDE_PROCESSING_ACCOUNT                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_OUTSIDE_PROCESSING_ACCOUNT is not NULL and p_OUTSIDE_PROCESSING_ACCOUNT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_OUTSIDE_PROCESSING_ACCOUNT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_OUTSIDE_PROCESSING_ACCOUNT;


PROCEDURE Validate_OVERHEAD_ACCOUNT (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_OVERHEAD_ACCOUNT                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_OVERHEAD_ACCOUNT is not NULL and p_OVERHEAD_ACCOUNT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_OVERHEAD_ACCOUNT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_OVERHEAD_ACCOUNT;


PROCEDURE Validate_FLOW_SCHEDULE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_FLOW_SCHEDULE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_FLOW_SCHEDULE is not NULL and p_FLOW_SCHEDULE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_FLOW_SCHEDULE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_FLOW_SCHEDULE;


PROCEDURE Validate_COST_GROUP_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_COST_GROUP_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_COST_GROUP_ID is not NULL and p_COST_GROUP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_COST_GROUP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_COST_GROUP_ID;


PROCEDURE Validate_DEMAND_CLASS (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DEMAND_CLASS                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_DEMAND_CLASS is not NULL and p_DEMAND_CLASS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_DEMAND_CLASS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DEMAND_CLASS;


PROCEDURE Validate_QA_COLLECTION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_QA_COLLECTION_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_QA_COLLECTION_ID is not NULL and p_QA_COLLECTION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_QA_COLLECTION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_QA_COLLECTION_ID;


PROCEDURE Validate_KANBAN_CARD_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_KANBAN_CARD_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_KANBAN_CARD_ID is not NULL and p_KANBAN_CARD_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_KANBAN_CARD_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_KANBAN_CARD_ID;


PROCEDURE Validate_OVERCOMPLETION_TRANSACTION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_OVERCOMPLETION_TRANSACTION_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_OVERCOMPLETION_TRANSACTION_ID is not NULL and p_OVERCOMPLETION_TRANSACTION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_OVERCOMPLETION_TRANSACTION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_OVERCOMPLETION_TRANSACTION_ID;


PROCEDURE Validate_OVERCOMPLETION_PRIMARY_QTY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_OVERCOMPLETION_PRIMARY_QTY                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_OVERCOMPLETION_PRIMARY_QTY is not NULL and p_OVERCOMPLETION_PRIMARY_QTY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_OVERCOMPLETION_PRIMARY_QTY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_OVERCOMPLETION_PRIMARY_QTY;


PROCEDURE Validate_OVERCOMPLETION_TRANSACTION_QTY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_OVERCOMPLETION_TRANSACTION_QTY                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_OVERCOMPLETION_TRANSACTION_QTY is not NULL and p_OVERCOMPLETION_TRANSACTION_QTY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_OVERCOMPLETION_TRANSACTION_QTY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_OVERCOMPLETION_TRANSACTION_QTY;


PROCEDURE Validate_PROCESS_TYPE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PROCESS_TYPE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PROCESS_TYPE is not NULL and p_PROCESS_TYPE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PROCESS_TYPE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PROCESS_TYPE;


PROCEDURE Validate_END_ITEM_UNIT_NUMBER (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_END_ITEM_UNIT_NUMBER                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_END_ITEM_UNIT_NUMBER is not NULL and p_END_ITEM_UNIT_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_END_ITEM_UNIT_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_END_ITEM_UNIT_NUMBER;


PROCEDURE Validate_SCHEDULED_PAYBACK_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SCHEDULED_PAYBACK_DATE                IN   DATE,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SCHEDULED_PAYBACK_DATE is not NULL and p_SCHEDULED_PAYBACK_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SCHEDULED_PAYBACK_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SCHEDULED_PAYBACK_DATE;


PROCEDURE Validate_LINE_TYPE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LINE_TYPE_CODE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_LINE_TYPE_CODE is not NULL and p_LINE_TYPE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_LINE_TYPE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LINE_TYPE_CODE;


PROCEDURE Validate_PARENT_TRANSACTION_TEMP_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARENT_TRANSACTION_TEMP_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARENT_TRANSACTION_TEMP_ID is not NULL and p_PARENT_TRANSACTION_TEMP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARENT_TRANSACTION_TEMP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARENT_TRANSACTION_TEMP_ID;


PROCEDURE Validate_PUT_AWAY_STRATEGY_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PUT_AWAY_STRATEGY_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PUT_AWAY_STRATEGY_ID is not NULL and p_PUT_AWAY_STRATEGY_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PUT_AWAY_STRATEGY_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PUT_AWAY_STRATEGY_ID;


PROCEDURE Validate_PUT_AWAY_RULE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PUT_AWAY_RULE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PUT_AWAY_RULE_ID is not NULL and p_PUT_AWAY_RULE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PUT_AWAY_RULE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PUT_AWAY_RULE_ID;


PROCEDURE Validate_PICK_STRATEGY_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PICK_STRATEGY_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PICK_STRATEGY_ID is not NULL and p_PICK_STRATEGY_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PICK_STRATEGY_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PICK_STRATEGY_ID;


PROCEDURE Validate_PICK_RULE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PICK_RULE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PICK_RULE_ID is not NULL and p_PICK_RULE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PICK_RULE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PICK_RULE_ID;


PROCEDURE Validate_COMMON_BOM_SEQ_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_COMMON_BOM_SEQ_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_COMMON_BOM_SEQ_ID is not NULL and p_COMMON_BOM_SEQ_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_COMMON_BOM_SEQ_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_COMMON_BOM_SEQ_ID;


PROCEDURE Validate_COMMON_ROUTING_SEQ_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_COMMON_ROUTING_SEQ_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_COMMON_ROUTING_SEQ_ID is not NULL and p_COMMON_ROUTING_SEQ_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_COMMON_ROUTING_SEQ_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_COMMON_ROUTING_SEQ_ID;


PROCEDURE Validate_COST_TYPE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_COST_TYPE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_COST_TYPE_ID is not NULL and p_COST_TYPE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_COST_TYPE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_COST_TYPE_ID;


PROCEDURE Validate_ORG_COST_GROUP_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ORG_COST_GROUP_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ORG_COST_GROUP_ID is not NULL and p_ORG_COST_GROUP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ORG_COST_GROUP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ORG_COST_GROUP_ID;


PROCEDURE Validate_MOVE_ORDER_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_MOVE_ORDER_LINE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_MOVE_ORDER_LINE_ID is not NULL and p_MOVE_ORDER_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_MOVE_ORDER_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_MOVE_ORDER_LINE_ID;


PROCEDURE Validate_TASK_GROUP_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TASK_GROUP_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TASK_GROUP_ID is not NULL and p_TASK_GROUP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TASK_GROUP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TASK_GROUP_ID;


PROCEDURE Validate_PICK_SLIP_NUMBER (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PICK_SLIP_NUMBER                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PICK_SLIP_NUMBER is not NULL and p_PICK_SLIP_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PICK_SLIP_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PICK_SLIP_NUMBER;


PROCEDURE Validate_RESERVATION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RESERVATION_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_RESERVATION_ID is not NULL and p_RESERVATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_RESERVATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RESERVATION_ID;


PROCEDURE Validate_TRANSACTION_STATUS (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TRANSACTION_STATUS                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_STATUS is not NULL and p_TRANSACTION_STATUS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TRANSACTION_STATUS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TRANSACTION_STATUS;


-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = JTF_PLSQL_API.G_VALIDATE_UPDATE, we should use cursor
--       to get old values for all fields used in inter-field validation and set all G_MISS_XXX fields to original value
--       stored in database table.
PROCEDURE Validate_CSP_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CSP_Rec     IN    CSP_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'API_INVALID_RECORD');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CSP_Rec;

PROCEDURE Validate_material_transactions(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_CSP_Rec     IN    CSP_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_material_transactions';
 BEGIN

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
          Validate_TRANSACTION_HEADER_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSACTION_HEADER_ID   => P_CSP_Rec.TRANSACTION_HEADER_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSACTION_TEMP_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSACTION_TEMP_ID   => P_CSP_Rec.TRANSACTION_TEMP_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SOURCE_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SOURCE_CODE   => P_CSP_Rec.SOURCE_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SOURCE_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SOURCE_LINE_ID   => P_CSP_Rec.SOURCE_LINE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSACTION_MODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSACTION_MODE   => P_CSP_Rec.TRANSACTION_MODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_LOCK_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LOCK_FLAG   => P_CSP_Rec.LOCK_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_REQUEST_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REQUEST_ID   => P_CSP_Rec.REQUEST_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_INVENTORY_ITEM_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_INVENTORY_ITEM_ID   => P_CSP_Rec.INVENTORY_ITEM_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_REVISION(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REVISION   => P_CSP_Rec.REVISION,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ORGANIZATION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ORGANIZATION_ID   => P_CSP_Rec.ORGANIZATION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SUBINVENTORY_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SUBINVENTORY_CODE   => P_CSP_Rec.SUBINVENTORY_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_LOCATOR_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LOCATOR_ID   => P_CSP_Rec.LOCATOR_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSACTION_QUANTITY(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSACTION_QUANTITY   => P_CSP_Rec.TRANSACTION_QUANTITY,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PRIMARY_QUANTITY(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PRIMARY_QUANTITY   => P_CSP_Rec.PRIMARY_QUANTITY,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSACTION_UOM(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSACTION_UOM   => P_CSP_Rec.TRANSACTION_UOM,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSACTION_COST(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSACTION_COST   => P_CSP_Rec.TRANSACTION_COST,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSACTION_TYPE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSACTION_TYPE_ID   => P_CSP_Rec.TRANSACTION_TYPE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSACTION_ACTION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSACTION_ACTION_ID   => P_CSP_Rec.TRANSACTION_ACTION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSACTION_SOURCE_TYPE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSACTION_SOURCE_TYPE_ID   => P_CSP_Rec.TRANSACTION_SOURCE_TYPE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSACTION_SOURCE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSACTION_SOURCE_ID   => P_CSP_Rec.TRANSACTION_SOURCE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSACTION_SOURCE_NAME(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSACTION_SOURCE_NAME   => P_CSP_Rec.TRANSACTION_SOURCE_NAME,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSACTION_DATE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSACTION_DATE   => P_CSP_Rec.TRANSACTION_DATE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ACCT_PERIOD_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ACCT_PERIOD_ID   => P_CSP_Rec.ACCT_PERIOD_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_DISTRIBUTION_ACCOUNT_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DISTRIBUTION_ACCOUNT_ID   => P_CSP_Rec.DISTRIBUTION_ACCOUNT_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSACTION_REFERENCE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSACTION_REFERENCE   => P_CSP_Rec.TRANSACTION_REFERENCE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_REQUISITION_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REQUISITION_LINE_ID   => P_CSP_Rec.REQUISITION_LINE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_REQUISITION_DISTRIBUTION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REQUISITION_DISTRIBUTION_ID   => P_CSP_Rec.REQUISITION_DISTRIBUTION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_REASON_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REASON_ID   => P_CSP_Rec.REASON_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_LOT_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LOT_NUMBER   => P_CSP_Rec.LOT_NUMBER,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_LOT_EXPIRATION_DATE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LOT_EXPIRATION_DATE   => P_CSP_Rec.LOT_EXPIRATION_DATE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SERIAL_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SERIAL_NUMBER   => P_CSP_Rec.SERIAL_NUMBER,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_RECEIVING_DOCUMENT(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RECEIVING_DOCUMENT   => P_CSP_Rec.RECEIVING_DOCUMENT,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_DEMAND_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DEMAND_ID   => P_CSP_Rec.DEMAND_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_RCV_TRANSACTION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RCV_TRANSACTION_ID   => P_CSP_Rec.RCV_TRANSACTION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_MOVE_TRANSACTION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_MOVE_TRANSACTION_ID   => P_CSP_Rec.MOVE_TRANSACTION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_COMPLETION_TRANSACTION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_COMPLETION_TRANSACTION_ID   => P_CSP_Rec.COMPLETION_TRANSACTION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_WIP_ENTITY_TYPE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_WIP_ENTITY_TYPE   => P_CSP_Rec.WIP_ENTITY_TYPE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SCHEDULE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SCHEDULE_ID   => P_CSP_Rec.SCHEDULE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_REPETITIVE_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REPETITIVE_LINE_ID   => P_CSP_Rec.REPETITIVE_LINE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_EMPLOYEE_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_EMPLOYEE_CODE   => P_CSP_Rec.EMPLOYEE_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PRIMARY_SWITCH(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PRIMARY_SWITCH   => P_CSP_Rec.PRIMARY_SWITCH,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SCHEDULE_UPDATE_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SCHEDULE_UPDATE_CODE   => P_CSP_Rec.SCHEDULE_UPDATE_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SETUP_TEARDOWN_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SETUP_TEARDOWN_CODE   => P_CSP_Rec.SETUP_TEARDOWN_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ITEM_ORDERING(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ITEM_ORDERING   => P_CSP_Rec.ITEM_ORDERING,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_NEGATIVE_REQ_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_NEGATIVE_REQ_FLAG   => P_CSP_Rec.NEGATIVE_REQ_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_OPERATION_SEQ_NUM(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OPERATION_SEQ_NUM   => P_CSP_Rec.OPERATION_SEQ_NUM,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PICKING_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PICKING_LINE_ID   => P_CSP_Rec.PICKING_LINE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRX_SOURCE_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRX_SOURCE_LINE_ID   => P_CSP_Rec.TRX_SOURCE_LINE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRX_SOURCE_DELIVERY_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRX_SOURCE_DELIVERY_ID   => P_CSP_Rec.TRX_SOURCE_DELIVERY_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PHYSICAL_ADJUSTMENT_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PHYSICAL_ADJUSTMENT_ID   => P_CSP_Rec.PHYSICAL_ADJUSTMENT_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CYCLE_COUNT_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CYCLE_COUNT_ID   => P_CSP_Rec.CYCLE_COUNT_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_RMA_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RMA_LINE_ID   => P_CSP_Rec.RMA_LINE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CUSTOMER_SHIP_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CUSTOMER_SHIP_ID   => P_CSP_Rec.CUSTOMER_SHIP_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CURRENCY_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CURRENCY_CODE   => P_CSP_Rec.CURRENCY_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CURRENCY_CONVERSION_RATE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CURRENCY_CONVERSION_RATE   => P_CSP_Rec.CURRENCY_CONVERSION_RATE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CURRENCY_CONVERSION_TYPE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CURRENCY_CONVERSION_TYPE   => P_CSP_Rec.CURRENCY_CONVERSION_TYPE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CURRENCY_CONVERSION_DATE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CURRENCY_CONVERSION_DATE   => P_CSP_Rec.CURRENCY_CONVERSION_DATE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_USSGL_TRANSACTION_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_USSGL_TRANSACTION_CODE   => P_CSP_Rec.USSGL_TRANSACTION_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_VENDOR_LOT_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_VENDOR_LOT_NUMBER   => P_CSP_Rec.VENDOR_LOT_NUMBER,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ENCUMBRANCE_ACCOUNT(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ENCUMBRANCE_ACCOUNT   => P_CSP_Rec.ENCUMBRANCE_ACCOUNT,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ENCUMBRANCE_AMOUNT(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ENCUMBRANCE_AMOUNT   => P_CSP_Rec.ENCUMBRANCE_AMOUNT,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SHIP_TO_LOCATION(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SHIP_TO_LOCATION   => P_CSP_Rec.SHIP_TO_LOCATION,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SHIPMENT_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SHIPMENT_NUMBER   => P_CSP_Rec.SHIPMENT_NUMBER,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSFER_COST(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSFER_COST   => P_CSP_Rec.TRANSFER_COST,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSPORTATION_COST(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSPORTATION_COST   => P_CSP_Rec.TRANSPORTATION_COST,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSPORTATION_ACCOUNT(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSPORTATION_ACCOUNT   => P_CSP_Rec.TRANSPORTATION_ACCOUNT,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_FREIGHT_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_FREIGHT_CODE   => P_CSP_Rec.FREIGHT_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CONTAINERS(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CONTAINERS   => P_CSP_Rec.CONTAINERS,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_WAYBILL_AIRBILL(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_WAYBILL_AIRBILL   => P_CSP_Rec.WAYBILL_AIRBILL,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_EXPECTED_ARRIVAL_DATE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_EXPECTED_ARRIVAL_DATE   => P_CSP_Rec.EXPECTED_ARRIVAL_DATE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSFER_SUBINVENTORY(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSFER_SUBINVENTORY   => P_CSP_Rec.TRANSFER_SUBINVENTORY,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSFER_ORGANIZATION(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSFER_ORGANIZATION   => P_CSP_Rec.TRANSFER_ORGANIZATION,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSFER_TO_LOCATION(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSFER_TO_LOCATION   => P_CSP_Rec.TRANSFER_TO_LOCATION,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_NEW_AVERAGE_COST(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_NEW_AVERAGE_COST   => P_CSP_Rec.NEW_AVERAGE_COST,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_VALUE_CHANGE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_VALUE_CHANGE   => P_CSP_Rec.VALUE_CHANGE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PERCENTAGE_CHANGE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PERCENTAGE_CHANGE   => P_CSP_Rec.PERCENTAGE_CHANGE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_MATERIAL_ALLOCATION_TEMP_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_MATERIAL_ALLOCATION_TEMP_ID   => P_CSP_Rec.MATERIAL_ALLOCATION_TEMP_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_DEMAND_SOURCE_HEADER_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DEMAND_SOURCE_HEADER_ID   => P_CSP_Rec.DEMAND_SOURCE_HEADER_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_DEMAND_SOURCE_LINE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DEMAND_SOURCE_LINE   => P_CSP_Rec.DEMAND_SOURCE_LINE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_DEMAND_SOURCE_DELIVERY(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DEMAND_SOURCE_DELIVERY   => P_CSP_Rec.DEMAND_SOURCE_DELIVERY,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ITEM_SEGMENTS(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ITEM_SEGMENTS   => P_CSP_Rec.ITEM_SEGMENTS,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ITEM_DESCRIPTION(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ITEM_DESCRIPTION   => P_CSP_Rec.ITEM_DESCRIPTION,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ITEM_TRX_ENABLED_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ITEM_TRX_ENABLED_FLAG   => P_CSP_Rec.ITEM_TRX_ENABLED_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ITEM_LOCATION_CONTROL_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ITEM_LOCATION_CONTROL_CODE   => P_CSP_Rec.ITEM_LOCATION_CONTROL_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ITEM_RESTRICT_SUBINV_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ITEM_RESTRICT_SUBINV_CODE   => P_CSP_Rec.ITEM_RESTRICT_SUBINV_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ITEM_RESTRICT_LOCATORS_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ITEM_RESTRICT_LOCATORS_CODE   => P_CSP_Rec.ITEM_RESTRICT_LOCATORS_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ITEM_REVISION_QTY_CONTROL_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ITEM_REVISION_QTY_CONTROL_CODE   => P_CSP_Rec.ITEM_REVISION_QTY_CONTROL_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ITEM_PRIMARY_UOM_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ITEM_PRIMARY_UOM_CODE   => P_CSP_Rec.ITEM_PRIMARY_UOM_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ITEM_UOM_CLASS(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ITEM_UOM_CLASS   => P_CSP_Rec.ITEM_UOM_CLASS,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ITEM_SHELF_LIFE_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ITEM_SHELF_LIFE_CODE   => P_CSP_Rec.ITEM_SHELF_LIFE_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ITEM_SHELF_LIFE_DAYS(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ITEM_SHELF_LIFE_DAYS   => P_CSP_Rec.ITEM_SHELF_LIFE_DAYS,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ITEM_LOT_CONTROL_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ITEM_LOT_CONTROL_CODE   => P_CSP_Rec.ITEM_LOT_CONTROL_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ITEM_SERIAL_CONTROL_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ITEM_SERIAL_CONTROL_CODE   => P_CSP_Rec.ITEM_SERIAL_CONTROL_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ITEM_INVENTORY_ASSET_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ITEM_INVENTORY_ASSET_FLAG   => P_CSP_Rec.ITEM_INVENTORY_ASSET_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ALLOWED_UNITS_LOOKUP_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ALLOWED_UNITS_LOOKUP_CODE   => P_CSP_Rec.ALLOWED_UNITS_LOOKUP_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_DEPARTMENT_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DEPARTMENT_ID   => P_CSP_Rec.DEPARTMENT_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_DEPARTMENT_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DEPARTMENT_CODE   => P_CSP_Rec.DEPARTMENT_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_WIP_SUPPLY_TYPE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_WIP_SUPPLY_TYPE   => P_CSP_Rec.WIP_SUPPLY_TYPE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SUPPLY_SUBINVENTORY(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SUPPLY_SUBINVENTORY   => P_CSP_Rec.SUPPLY_SUBINVENTORY,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SUPPLY_LOCATOR_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SUPPLY_LOCATOR_ID   => P_CSP_Rec.SUPPLY_LOCATOR_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_VALID_SUBINVENTORY_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_VALID_SUBINVENTORY_FLAG   => P_CSP_Rec.VALID_SUBINVENTORY_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_VALID_LOCATOR_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_VALID_LOCATOR_FLAG   => P_CSP_Rec.VALID_LOCATOR_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_LOCATOR_SEGMENTS(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LOCATOR_SEGMENTS   => P_CSP_Rec.LOCATOR_SEGMENTS,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CURRENT_LOCATOR_CONTROL_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CURRENT_LOCATOR_CONTROL_CODE   => P_CSP_Rec.CURRENT_LOCATOR_CONTROL_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_NUMBER_OF_LOTS_ENTERED(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_NUMBER_OF_LOTS_ENTERED   => P_CSP_Rec.NUMBER_OF_LOTS_ENTERED,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_WIP_COMMIT_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_WIP_COMMIT_FLAG   => P_CSP_Rec.WIP_COMMIT_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_NEXT_LOT_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_NEXT_LOT_NUMBER   => P_CSP_Rec.NEXT_LOT_NUMBER,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_LOT_ALPHA_PREFIX(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LOT_ALPHA_PREFIX   => P_CSP_Rec.LOT_ALPHA_PREFIX,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_NEXT_SERIAL_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_NEXT_SERIAL_NUMBER   => P_CSP_Rec.NEXT_SERIAL_NUMBER,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SERIAL_ALPHA_PREFIX(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SERIAL_ALPHA_PREFIX   => P_CSP_Rec.SERIAL_ALPHA_PREFIX,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SHIPPABLE_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SHIPPABLE_FLAG   => P_CSP_Rec.SHIPPABLE_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_POSTING_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_POSTING_FLAG   => P_CSP_Rec.POSTING_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_REQUIRED_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REQUIRED_FLAG   => P_CSP_Rec.REQUIRED_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PROCESS_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PROCESS_FLAG   => P_CSP_Rec.PROCESS_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ERROR_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ERROR_CODE   => P_CSP_Rec.ERROR_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ERROR_EXPLANATION(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ERROR_EXPLANATION   => P_CSP_Rec.ERROR_EXPLANATION,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_MOVEMENT_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_MOVEMENT_ID   => P_CSP_Rec.MOVEMENT_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_RESERVATION_QUANTITY(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RESERVATION_QUANTITY   => P_CSP_Rec.RESERVATION_QUANTITY,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SHIPPED_QUANTITY(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SHIPPED_QUANTITY   => P_CSP_Rec.SHIPPED_QUANTITY,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSACTION_LINE_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSACTION_LINE_NUMBER   => P_CSP_Rec.TRANSACTION_LINE_NUMBER,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TASK_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TASK_ID   => P_CSP_Rec.TASK_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TO_TASK_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TO_TASK_ID   => P_CSP_Rec.TO_TASK_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SOURCE_TASK_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SOURCE_TASK_ID   => P_CSP_Rec.SOURCE_TASK_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PROJECT_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PROJECT_ID   => P_CSP_Rec.PROJECT_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SOURCE_PROJECT_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SOURCE_PROJECT_ID   => P_CSP_Rec.SOURCE_PROJECT_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PA_EXPENDITURE_ORG_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PA_EXPENDITURE_ORG_ID   => P_CSP_Rec.PA_EXPENDITURE_ORG_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TO_PROJECT_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TO_PROJECT_ID   => P_CSP_Rec.TO_PROJECT_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_EXPENDITURE_TYPE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_EXPENDITURE_TYPE   => P_CSP_Rec.EXPENDITURE_TYPE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_FINAL_COMPLETION_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_FINAL_COMPLETION_FLAG   => P_CSP_Rec.FINAL_COMPLETION_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSFER_PERCENTAGE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSFER_PERCENTAGE   => P_CSP_Rec.TRANSFER_PERCENTAGE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSACTION_SEQUENCE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSACTION_SEQUENCE_ID   => P_CSP_Rec.TRANSACTION_SEQUENCE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_MATERIAL_ACCOUNT(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_MATERIAL_ACCOUNT   => P_CSP_Rec.MATERIAL_ACCOUNT,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_MATERIAL_OVERHEAD_ACCOUNT(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_MATERIAL_OVERHEAD_ACCOUNT   => P_CSP_Rec.MATERIAL_OVERHEAD_ACCOUNT,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_RESOURCE_ACCOUNT(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RESOURCE_ACCOUNT   => P_CSP_Rec.RESOURCE_ACCOUNT,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_OUTSIDE_PROCESSING_ACCOUNT(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OUTSIDE_PROCESSING_ACCOUNT   => P_CSP_Rec.OUTSIDE_PROCESSING_ACCOUNT,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_OVERHEAD_ACCOUNT(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OVERHEAD_ACCOUNT   => P_CSP_Rec.OVERHEAD_ACCOUNT,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_FLOW_SCHEDULE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_FLOW_SCHEDULE   => P_CSP_Rec.FLOW_SCHEDULE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_COST_GROUP_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_COST_GROUP_ID   => P_CSP_Rec.COST_GROUP_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_DEMAND_CLASS(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DEMAND_CLASS   => P_CSP_Rec.DEMAND_CLASS,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_QA_COLLECTION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_QA_COLLECTION_ID   => P_CSP_Rec.QA_COLLECTION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_KANBAN_CARD_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_KANBAN_CARD_ID   => P_CSP_Rec.KANBAN_CARD_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_OVERCOMPLETION_TRANSACTION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OVERCOMPLETION_TRANSACTION_ID   => P_CSP_Rec.OVERCOMPLETION_TRANSACTION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_OVERCOMPLETION_PRIMARY_QTY(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OVERCOMPLETION_PRIMARY_QTY   => P_CSP_Rec.OVERCOMPLETION_PRIMARY_QTY,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_OVERCOMPLETION_TRANSACTION_QTY(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OVERCOMPLETION_TRANSACTION_QTY   => P_CSP_Rec.OVERCOMPLETION_TRANSACTION_QTY,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PROCESS_TYPE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PROCESS_TYPE   => P_CSP_Rec.PROCESS_TYPE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_END_ITEM_UNIT_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_END_ITEM_UNIT_NUMBER   => P_CSP_Rec.END_ITEM_UNIT_NUMBER,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SCHEDULED_PAYBACK_DATE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SCHEDULED_PAYBACK_DATE   => P_CSP_Rec.SCHEDULED_PAYBACK_DATE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_LINE_TYPE_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LINE_TYPE_CODE   => P_CSP_Rec.LINE_TYPE_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARENT_TRANSACTION_TEMP_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARENT_TRANSACTION_TEMP_ID   => P_CSP_Rec.PARENT_TRANSACTION_TEMP_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PUT_AWAY_STRATEGY_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PUT_AWAY_STRATEGY_ID   => P_CSP_Rec.PUT_AWAY_STRATEGY_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PUT_AWAY_RULE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PUT_AWAY_RULE_ID   => P_CSP_Rec.PUT_AWAY_RULE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PICK_STRATEGY_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PICK_STRATEGY_ID   => P_CSP_Rec.PICK_STRATEGY_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PICK_RULE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PICK_RULE_ID   => P_CSP_Rec.PICK_RULE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_COMMON_BOM_SEQ_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_COMMON_BOM_SEQ_ID   => P_CSP_Rec.COMMON_BOM_SEQ_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_COMMON_ROUTING_SEQ_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_COMMON_ROUTING_SEQ_ID   => P_CSP_Rec.COMMON_ROUTING_SEQ_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_COST_TYPE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_COST_TYPE_ID   => P_CSP_Rec.COST_TYPE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ORG_COST_GROUP_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ORG_COST_GROUP_ID   => P_CSP_Rec.ORG_COST_GROUP_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_MOVE_ORDER_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_MOVE_ORDER_LINE_ID   => P_CSP_Rec.MOVE_ORDER_LINE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TASK_GROUP_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TASK_GROUP_ID   => P_CSP_Rec.TASK_GROUP_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PICK_SLIP_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PICK_SLIP_NUMBER   => P_CSP_Rec.PICK_SLIP_NUMBER,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_RESERVATION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RESERVATION_ID   => P_CSP_Rec.RESERVATION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TRANSACTION_STATUS(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TRANSACTION_STATUS   => P_CSP_Rec.TRANSACTION_STATUS,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

      END IF;

      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_RECORD) THEN
          -- Hint: Inter-field level validation can be added here
          -- invoke record level validation procedures
          Validate_CSP_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          P_CSP_Rec     =>    P_CSP_Rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_INTER_RECORD) THEN
          -- invoke inter-record level validation procedures
          NULL;
      END IF;

      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_INTER_ENTITY) THEN
          -- invoke inter-entity level validation procedures
          NULL;
      END IF;


      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');

END Validate_material_transactions;
*/

End CSP_MATERIAL_TRANSACTIONS_PVT;

/
