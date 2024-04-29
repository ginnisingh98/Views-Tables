--------------------------------------------------------
--  DDL for Package Body CSP_PC_FORM_MTLTXNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PC_FORM_MTLTXNS" AS
/*$Header: cspgtmxb.pls 120.0 2005/05/24 18:13:03 appldev noship $*/
-- Start of Comments
-- Package name     : CSP_PC_FORM_MTLTXNS
-- Purpose          : CSP procedures for csp move order transactions.CSP procedures to insert, update and delete
--                    records in the mtl_material_transactions_temp table.
-- History          :
--  27-Dec-99, Add procedure CSP_MO_Lines_Manual_Receipt.
--  20-Dec-99, klou.
--
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_PC_FORM_MTLTXNS';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspgtmxb.pls';

PROCEDURE Validate_And_Write (
-- Procedure name     : Validate_And_Write
-- Purpose            : A wrapper to prepare data to call the update, delete and insert procedures of the
--                      CSP_Material_Transaactions_PVT.
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
      --p_PROCESS_TYPE   IN     NUMBER := FND_API.G_MISS_NUM,
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
      -- P_SOURCE_LOT_NUMBER       IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      X_Return_Status           OUT NOCOPY     VARCHAR2,
      X_Msg_Count               OUT NOCOPY     NUMBER,
      X_Msg_Data                OUT NOCOPY     VARCHAR2
    )
 IS
    l_api_version_number CONSTANT NUMBER := 1.0;
    l_api_name      CONSTANT VARCHAR2(20) := 'Validate_And_Write';
    l_msg_data  VARCHAR2(300);
    EXCP_USER_DEFINED   EXCEPTION;
    l_check_existence   NUMBER := 0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER  := 0;
    l_pick_list_header_id  NUMBER;
    l_commit    VARCHAR2(1) := FND_API.G_FALSE;
    l_creation_date     DATE := p_creation_date;
    l_last_update_date  DATE := p_last_update_date;
    l_csp_mtltxn_rec  CSP_MATERIAL_TRANSACTIONS_PVT.CSP_Rec_Type;

   -- for inserting data, the validation_level should be none
   -- because we do not want to call core apps standard validations.
    l_validation_level  NUMBER  := FND_API.G_VALID_LEVEL_NONE;
    l_transaction_temp_id NUMBER;


BEGIN
    SAVEPOINT Validate_And_Write_PUB;
      IF fnd_api.to_boolean(P_Init_Msg_List) THEN
          -- initialize message list
            FND_MSG_PUB.initialize;
      END IF;

   -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     -- validate p_organization_id
      IF p_organization_id IS NULL THEN
          FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
          FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_organization_id', TRUE);
          FND_MSG_PUB.ADD;
          RAISE EXCP_USER_DEFINED;
      ELSE
                BEGIN
                    select organization_id into l_check_existence
                    from mtl_parameters
                    where organization_id = p_organization_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         FND_MESSAGE.SET_NAME ('INV', 'INVALID ORGANIZATION');
                         FND_MSG_PUB.ADD;
                         RAISE EXCP_USER_DEFINED;
                    WHEN OTHERS THEN
                        fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                        fnd_message.set_token('ERR_FIELD', 'p_organization_id', TRUE);
                        fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                        fnd_message.set_token('TABLE', 'mtl_organizations', TRUE);
                        FND_MSG_PUB.ADD;
                        RAISE EXCP_USER_DEFINED;
                END;
      END IF;

      IF p_action_code NOT IN (0, 1, 2) OR p_action_code IS NULL THEN
            fnd_message.set_name ('INV', 'INV-INVALID ACTION');
            fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
            fnd_msg_pub.add;
            RAISE EXCP_USER_DEFINED;
      END IF;

       IF p_action_code = 0 AND px_transaction_temp_id IS NOT NULL THEN

            -- check whehter the px_transaction_temp_id already exists. If yes, raise an exception.
            BEGIN
                SELECT transaction_temp_id into l_check_existence
                FROM mtl_material_transactions_temp
                WHERE transaction_temp_id = px_transaction_temp_id
                AND organization_id = p_organization_id;

                fnd_message.set_name ('CSP', 'CSP_DUPLICATE_RECORD');
                fnd_msg_pub.add;
                RAISE EXCP_USER_DEFINED;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL;
            END;
       ELSIF p_action_code IN (1, 2) THEN
            IF px_transaction_temp_id IS NULL THEN
                FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
                FND_MESSAGE.SET_TOKEN ('PARAMETER', 'px_transaction_temp_id', TRUE);
                FND_MSG_PUB.ADD;
                RAISE EXCP_USER_DEFINED;
            ELSE
                BEGIN
                    select transaction_temp_id into l_check_existence
                    from mtl_material_transactions_temp
                    where organization_id = p_organization_id
                    and transaction_temp_id = px_transaction_temp_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        fnd_message.set_name ('CSP', 'CSP_INVALID_TEMP_ID');
                        fnd_message.set_token ('ID', to_char(px_transaction_temp_id), TRUE);
                        fnd_msg_pub.add;
                        RAISE EXCP_USER_DEFINED;
                     WHEN EXCP_USER_DEFINED THEN
                        RAISE EXCP_USER_DEFINED;
                   WHEN OTHERS THEN
                        fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                        fnd_message.set_token('ERR_FIELD', 'px_transaction_temp_id', TRUE);
                        fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                        fnd_message.set_token('TABLE', 'mtl_material_transactions_temp', TRUE);
                        FND_MSG_PUB.ADD;
                        RAISE EXCP_USER_DEFINED;
                END;
             END IF;
        ELSE NULL;
        END IF;

       --validating inventory_item_id
       IF p_inventory_item_id IS NULL THEN
            FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
            FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_inventory_item_id', TRUE);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
       ELSE
            BEGIN
              -- validate whether the inventory_item_is exists in the given oranization_id
              select inventory_item_id into l_check_existence
              from mtl_system_items_kfv
              where inventory_item_id = p_inventory_item_id
              and organization_id = p_organization_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   fnd_message.set_name ('INV', 'INV-NO ITEM RECORD');
                   fnd_msg_pub.add;
                   RAISE EXCP_USER_DEFINED;
                WHEN OTHERS THEN
                   fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                   fnd_message.set_token('ERR_FIELD', 'p_inventory_item_id', TRUE);
                   fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                   fnd_message.set_token('TABLE', 'mtl_system_items', TRUE);
                   fnd_msg_pub.add;
                   RAISE EXCP_USER_DEFINED;
            END;
       END IF;

         IF l_creation_date IS NULL THEN
            l_creation_date := sysdate;
       END IF;

       IF l_last_update_date IS NULL THEN
            l_last_update_date := sysdate;
       END IF;

      -- construct the record to call the procedures in csp_material_transactions_pvt.
      l_csp_mtltxn_rec.TRANSACTION_HEADER_ID        := p_TRANSACTION_HEADER_ID;
      l_csp_mtltxn_rec.TRANSACTION_TEMP_ID          := px_TRANSACTION_TEMP_ID;
      l_csp_mtltxn_rec.SOURCE_CODE                  := p_SOURCE_CODE;
      l_csp_mtltxn_rec.SOURCE_LINE_ID               := p_SOURCE_LINE_ID;
      l_csp_mtltxn_rec.TRANSACTION_MODE             := p_TRANSACTION_MODE;
      l_csp_mtltxn_rec.LOCK_FLAG                    := p_LOCK_FLAG;
      l_csp_mtltxn_rec.LAST_UPDATE_DATE             := p_LAST_UPDATE_DATE;
      l_csp_mtltxn_rec.LAST_UPDATED_BY              := p_LAST_UPDATED_BY;
      l_csp_mtltxn_rec.CREATION_DATE                := p_CREATION_DATE;
      l_csp_mtltxn_rec.CREATED_BY                   := p_CREATED_BY;
      l_csp_mtltxn_rec.LAST_UPDATE_LOGIN            := p_LAST_UPDATE_LOGIN;
      l_csp_mtltxn_rec.REQUEST_ID                   := p_REQUEST_ID;
      l_csp_mtltxn_rec.PROGRAM_APPLICATION_ID       := p_PROGRAM_APPLICATION_ID;
      l_csp_mtltxn_rec.PROGRAM_ID                   := p_PROGRAM_ID;
      l_csp_mtltxn_rec.PROGRAM_UPDATE_DATE          := p_PROGRAM_UPDATE_DATE;
      l_csp_mtltxn_rec.INVENTORY_ITEM_ID            := p_INVENTORY_ITEM_ID;
      l_csp_mtltxn_rec.REVISION                     := p_REVISION;
      l_csp_mtltxn_rec.ORGANIZATION_ID              := p_ORGANIZATION_ID;
      l_csp_mtltxn_rec.SUBINVENTORY_CODE            := p_SUBINVENTORY_CODE;
      l_csp_mtltxn_rec.LOCATOR_ID                   := p_LOCATOR_ID;
      l_csp_mtltxn_rec.TRANSACTION_QUANTITY         := p_TRANSACTION_QUANTITY;
      l_csp_mtltxn_rec.PRIMARY_QUANTITY             := p_PRIMARY_QUANTITY;
      l_csp_mtltxn_rec.TRANSACTION_UOM              := p_TRANSACTION_UOM;
      l_csp_mtltxn_rec.TRANSACTION_COST             := p_TRANSACTION_COST;
      l_csp_mtltxn_rec.TRANSACTION_TYPE_ID          := p_TRANSACTION_TYPE_ID;
      l_csp_mtltxn_rec.TRANSACTION_ACTION_ID        := p_TRANSACTION_ACTION_ID;
      l_csp_mtltxn_rec.TRANSACTION_SOURCE_TYPE_ID   := p_TRANSACTION_SOURCE_TYPE_ID;
      l_csp_mtltxn_rec.TRANSACTION_SOURCE_ID        := p_TRANSACTION_SOURCE_ID;
      l_csp_mtltxn_rec.TRANSACTION_SOURCE_NAME      := p_TRANSACTION_SOURCE_NAME;
      l_csp_mtltxn_rec.TRANSACTION_DATE             := p_TRANSACTION_DATE;
      l_csp_mtltxn_rec.ACCT_PERIOD_ID               := p_ACCT_PERIOD_ID;
      l_csp_mtltxn_rec.DISTRIBUTION_ACCOUNT_ID      := p_DISTRIBUTION_ACCOUNT_ID;
      l_csp_mtltxn_rec.TRANSACTION_REFERENCE        := p_TRANSACTION_REFERENCE;
      l_csp_mtltxn_rec.REQUISITION_LINE_ID          := p_REQUISITION_LINE_ID;
      l_csp_mtltxn_rec.REQUISITION_DISTRIBUTION_ID  := p_REQUISITION_DISTRIBUTION_ID;
      l_csp_mtltxn_rec.REASON_ID                    := p_REASON_ID;
      l_csp_mtltxn_rec.LOT_NUMBER                   := p_LOT_NUMBER;
      l_csp_mtltxn_rec.LOT_EXPIRATION_DATE          := p_LOT_EXPIRATION_DATE;
      l_csp_mtltxn_rec.SERIAL_NUMBER                := p_SERIAL_NUMBER;
      l_csp_mtltxn_rec.RECEIVING_DOCUMENT           := p_RECEIVING_DOCUMENT;
      l_csp_mtltxn_rec.DEMAND_ID                    := p_DEMAND_ID;
      l_csp_mtltxn_rec.RCV_TRANSACTION_ID           := p_RCV_TRANSACTION_ID;
      l_csp_mtltxn_rec.MOVE_TRANSACTION_ID          := p_MOVE_TRANSACTION_ID;
      l_csp_mtltxn_rec.COMPLETION_TRANSACTION_ID    := p_COMPLETION_TRANSACTION_ID;
      l_csp_mtltxn_rec.WIP_ENTITY_TYPE              := p_WIP_ENTITY_TYPE;
      l_csp_mtltxn_rec.SCHEDULE_ID                  := p_SCHEDULE_ID;
      l_csp_mtltxn_rec.REPETITIVE_LINE_ID           := p_REPETITIVE_LINE_ID;
      l_csp_mtltxn_rec.EMPLOYEE_CODE                := p_EMPLOYEE_CODE;
      l_csp_mtltxn_rec.PRIMARY_SWITCH               := p_PRIMARY_SWITCH;
      l_csp_mtltxn_rec.SCHEDULE_UPDATE_CODE         := p_SCHEDULE_UPDATE_CODE;
      l_csp_mtltxn_rec.SETUP_TEARDOWN_CODE          := p_SETUP_TEARDOWN_CODE;
      l_csp_mtltxn_rec.ITEM_ORDERING                := p_ITEM_ORDERING;
      l_csp_mtltxn_rec.NEGATIVE_REQ_FLAG            := p_NEGATIVE_REQ_FLAG;
      l_csp_mtltxn_rec.OPERATION_SEQ_NUM            := p_OPERATION_SEQ_NUM;
      l_csp_mtltxn_rec.PICKING_LINE_ID              := p_PICKING_LINE_ID;
      l_csp_mtltxn_rec.TRX_SOURCE_LINE_ID           := p_TRX_SOURCE_LINE_ID;
      l_csp_mtltxn_rec.TRX_SOURCE_DELIVERY_ID       := p_TRX_SOURCE_DELIVERY_ID;
      l_csp_mtltxn_rec.PHYSICAL_ADJUSTMENT_ID       := p_PHYSICAL_ADJUSTMENT_ID;
      l_csp_mtltxn_rec.CYCLE_COUNT_ID               := p_CYCLE_COUNT_ID;
      l_csp_mtltxn_rec.RMA_LINE_ID                  := p_RMA_LINE_ID;
      l_csp_mtltxn_rec.CUSTOMER_SHIP_ID             := p_CUSTOMER_SHIP_ID;
      l_csp_mtltxn_rec.CURRENCY_CODE                := p_CURRENCY_CODE;
      l_csp_mtltxn_rec.CURRENCY_CONVERSION_RATE     := p_CURRENCY_CONVERSION_RATE;
      l_csp_mtltxn_rec.CURRENCY_CONVERSION_TYPE     := p_CURRENCY_CONVERSION_TYPE;
      l_csp_mtltxn_rec.CURRENCY_CONVERSION_DATE     := p_CURRENCY_CONVERSION_DATE;
      l_csp_mtltxn_rec.USSGL_TRANSACTION_CODE       := p_USSGL_TRANSACTION_CODE;
      l_csp_mtltxn_rec.VENDOR_LOT_NUMBER            := p_VENDOR_LOT_NUMBER;
      l_csp_mtltxn_rec.ENCUMBRANCE_ACCOUNT          := p_ENCUMBRANCE_ACCOUNT;
      l_csp_mtltxn_rec.ENCUMBRANCE_AMOUNT           := p_ENCUMBRANCE_AMOUNT;
      l_csp_mtltxn_rec.SHIP_TO_LOCATION             := p_SHIP_TO_LOCATION;
      l_csp_mtltxn_rec.SHIPMENT_NUMBER              := p_SHIPMENT_NUMBER;
      l_csp_mtltxn_rec.TRANSFER_COST                := p_TRANSFER_COST;
      l_csp_mtltxn_rec.TRANSPORTATION_COST          := p_TRANSPORTATION_COST;
      l_csp_mtltxn_rec.TRANSPORTATION_ACCOUNT       := p_TRANSPORTATION_ACCOUNT;
      l_csp_mtltxn_rec.FREIGHT_CODE                 := p_FREIGHT_CODE;
      l_csp_mtltxn_rec.CONTAINERS                   := p_CONTAINERS;
      l_csp_mtltxn_rec.WAYBILL_AIRBILL              := p_WAYBILL_AIRBILL;
      l_csp_mtltxn_rec.EXPECTED_ARRIVAL_DATE        := p_EXPECTED_ARRIVAL_DATE;
      l_csp_mtltxn_rec.TRANSFER_SUBINVENTORY        := p_TRANSFER_SUBINVENTORY;
      l_csp_mtltxn_rec.TRANSFER_ORGANIZATION        := p_TRANSFER_ORGANIZATION;
      l_csp_mtltxn_rec.TRANSFER_TO_LOCATION         := p_TRANSFER_TO_LOCATION;
      l_csp_mtltxn_rec.NEW_AVERAGE_COST             := p_NEW_AVERAGE_COST;
      l_csp_mtltxn_rec.VALUE_CHANGE                 := p_VALUE_CHANGE;
      l_csp_mtltxn_rec.PERCENTAGE_CHANGE            := p_PERCENTAGE_CHANGE;
      l_csp_mtltxn_rec.MATERIAL_ALLOCATION_TEMP_ID  := p_MATERIAL_ALLOCATION_TEMP_ID;
      l_csp_mtltxn_rec.DEMAND_SOURCE_HEADER_ID      := p_DEMAND_SOURCE_HEADER_ID;
      l_csp_mtltxn_rec.DEMAND_SOURCE_LINE           := p_DEMAND_SOURCE_LINE;
      l_csp_mtltxn_rec.DEMAND_SOURCE_DELIVERY       := p_DEMAND_SOURCE_DELIVERY;
      l_csp_mtltxn_rec.ITEM_SEGMENTS                := p_ITEM_SEGMENTS;
      l_csp_mtltxn_rec.ITEM_DESCRIPTION             := p_ITEM_DESCRIPTION;
      l_csp_mtltxn_rec.ITEM_TRX_ENABLED_FLAG        := p_ITEM_TRX_ENABLED_FLAG;
      l_csp_mtltxn_rec.ITEM_LOCATION_CONTROL_CODE   := p_ITEM_LOCATION_CONTROL_CODE;
      l_csp_mtltxn_rec.ITEM_RESTRICT_SUBINV_CODE    := p_ITEM_RESTRICT_SUBINV_CODE;
      l_csp_mtltxn_rec.ITEM_RESTRICT_LOCATORS_CODE  := p_ITEM_RESTRICT_LOCATORS_CODE;
      l_csp_mtltxn_rec.ITEM_REVISION_QTY_CONTROL_CODE   := p_ITEM_REV_QTY_CONTROL_CODE;
      l_csp_mtltxn_rec.ITEM_PRIMARY_UOM_CODE            := p_ITEM_PRIMARY_UOM_CODE;
      l_csp_mtltxn_rec.ITEM_UOM_CLASS                   := p_ITEM_UOM_CLASS;
      l_csp_mtltxn_rec.ITEM_SHELF_LIFE_CODE             := p_ITEM_SHELF_LIFE_CODE;
      l_csp_mtltxn_rec.ITEM_SHELF_LIFE_DAYS             := p_ITEM_SHELF_LIFE_DAYS;
      l_csp_mtltxn_rec.ITEM_LOT_CONTROL_CODE            := p_ITEM_LOT_CONTROL_CODE;
      l_csp_mtltxn_rec.ITEM_SERIAL_CONTROL_CODE         := p_ITEM_SERIAL_CONTROL_CODE;
      l_csp_mtltxn_rec.ITEM_INVENTORY_ASSET_FLAG        := p_ITEM_INVENTORY_ASSET_FLAG;
      l_csp_mtltxn_rec.ALLOWED_UNITS_LOOKUP_CODE        := p_ALLOWED_UNITS_LOOKUP_CODE;
      l_csp_mtltxn_rec.DEPARTMENT_ID                    := p_DEPARTMENT_ID;
      l_csp_mtltxn_rec.DEPARTMENT_CODE                  := p_DEPARTMENT_CODE;
      l_csp_mtltxn_rec.WIP_SUPPLY_TYPE                  := p_WIP_SUPPLY_TYPE;
      l_csp_mtltxn_rec.SUPPLY_SUBINVENTORY              := p_SUPPLY_SUBINVENTORY;
      l_csp_mtltxn_rec.SUPPLY_LOCATOR_ID                := p_SUPPLY_LOCATOR_ID;
      l_csp_mtltxn_rec.VALID_SUBINVENTORY_FLAG          := p_VALID_SUBINVENTORY_FLAG;
      l_csp_mtltxn_rec.VALID_LOCATOR_FLAG               := p_VALID_LOCATOR_FLAG;
      l_csp_mtltxn_rec.LOCATOR_SEGMENTS                 := p_LOCATOR_SEGMENTS;
      l_csp_mtltxn_rec.CURRENT_LOCATOR_CONTROL_CODE     := p_CURRENT_LOCATOR_CONTROL_CODE;
      l_csp_mtltxn_rec.NUMBER_OF_LOTS_ENTERED           := p_NUMBER_OF_LOTS_ENTERED;
      l_csp_mtltxn_rec.WIP_COMMIT_FLAG                  := p_WIP_COMMIT_FLAG;
      l_csp_mtltxn_rec.NEXT_LOT_NUMBER                  := p_NEXT_LOT_NUMBER;
      l_csp_mtltxn_rec.LOT_ALPHA_PREFIX                 := p_LOT_ALPHA_PREFIX;
      l_csp_mtltxn_rec.NEXT_SERIAL_NUMBER               := p_NEXT_SERIAL_NUMBER;
      l_csp_mtltxn_rec.SERIAL_ALPHA_PREFIX              := p_SERIAL_ALPHA_PREFIX;
      l_csp_mtltxn_rec.SHIPPABLE_FLAG                   := p_SHIPPABLE_FLAG;
      l_csp_mtltxn_rec.POSTING_FLAG                     := p_POSTING_FLAG;
      l_csp_mtltxn_rec.REQUIRED_FLAG                    := p_REQUIRED_FLAG;
      l_csp_mtltxn_rec.PROCESS_FLAG                     := p_PROCESS_FLAG;
      l_csp_mtltxn_rec.ERROR_CODE                       := p_ERROR_CODE;
      l_csp_mtltxn_rec.ERROR_EXPLANATION                := p_ERROR_EXPLANATION;
      l_csp_mtltxn_rec.ATTRIBUTE_CATEGORY               := p_ATTRIBUTE_CATEGORY;
      l_csp_mtltxn_rec.ATTRIBUTE1        := p_ATTRIBUTE1;
      l_csp_mtltxn_rec.ATTRIBUTE2        := p_ATTRIBUTE2;
      l_csp_mtltxn_rec.ATTRIBUTE3        := p_ATTRIBUTE3;
      l_csp_mtltxn_rec.ATTRIBUTE4        := p_ATTRIBUTE4;
      l_csp_mtltxn_rec.ATTRIBUTE5        := p_ATTRIBUTE5;
      l_csp_mtltxn_rec.ATTRIBUTE6        := p_ATTRIBUTE6;
      l_csp_mtltxn_rec.ATTRIBUTE7        := p_ATTRIBUTE7;
      l_csp_mtltxn_rec.ATTRIBUTE8        := p_ATTRIBUTE8;
      l_csp_mtltxn_rec.ATTRIBUTE9        := p_ATTRIBUTE9;
      l_csp_mtltxn_rec.ATTRIBUTE10       := p_ATTRIBUTE10;
      l_csp_mtltxn_rec.ATTRIBUTE11       := p_ATTRIBUTE11;
      l_csp_mtltxn_rec.ATTRIBUTE12       := p_ATTRIBUTE12;
      l_csp_mtltxn_rec.ATTRIBUTE13       := p_ATTRIBUTE13;
      l_csp_mtltxn_rec.ATTRIBUTE14       := p_ATTRIBUTE14;
      l_csp_mtltxn_rec.ATTRIBUTE15       := p_ATTRIBUTE15;
      l_csp_mtltxn_rec.MOVEMENT_ID       := p_MOVEMENT_ID;
      l_csp_mtltxn_rec.RESERVATION_QUANTITY           := p_RESERVATION_QUANTITY;
      l_csp_mtltxn_rec.SHIPPED_QUANTITY               := p_SHIPPED_QUANTITY;
      l_csp_mtltxn_rec.TRANSACTION_LINE_NUMBER        := p_TRANSACTION_LINE_NUMBER;
      l_csp_mtltxn_rec.TASK_ID              := p_TASK_ID;
      l_csp_mtltxn_rec.TO_TASK_ID           := p_TO_TASK_ID;
      l_csp_mtltxn_rec.SOURCE_TASK_ID       := p_SOURCE_TASK_ID;
      l_csp_mtltxn_rec.PROJECT_ID           := p_PROJECT_ID;
      l_csp_mtltxn_rec.SOURCE_PROJECT_ID    := p_SOURCE_PROJECT_ID;
      l_csp_mtltxn_rec.PA_EXPENDITURE_ORG_ID        := p_PA_EXPENDITURE_ORG_ID;
      l_csp_mtltxn_rec.TO_PROJECT_ID                := p_TO_PROJECT_ID;
      l_csp_mtltxn_rec.EXPENDITURE_TYPE             := p_EXPENDITURE_TYPE;
      l_csp_mtltxn_rec.FINAL_COMPLETION_FLAG        := p_FINAL_COMPLETION_FLAG;
      l_csp_mtltxn_rec.TRANSFER_PERCENTAGE          := p_TRANSFER_PERCENTAGE;
      l_csp_mtltxn_rec.TRANSACTION_SEQUENCE_ID      := p_TRANSACTION_SEQUENCE_ID;
      l_csp_mtltxn_rec.MATERIAL_ACCOUNT             := p_MATERIAL_ACCOUNT;
      l_csp_mtltxn_rec.MATERIAL_OVERHEAD_ACCOUNT    := p_MATERIAL_OVERHEAD_ACCOUNT;
      l_csp_mtltxn_rec.RESOURCE_ACCOUNT             := p_RESOURCE_ACCOUNT;
      l_csp_mtltxn_rec.OUTSIDE_PROCESSING_ACCOUNT   := p_OUTSIDE_PROCESSING_ACCOUNT;
      l_csp_mtltxn_rec.OVERHEAD_ACCOUNT             := p_OVERHEAD_ACCOUNT;
      l_csp_mtltxn_rec.FLOW_SCHEDULE        := p_FLOW_SCHEDULE;
      l_csp_mtltxn_rec.COST_GROUP_ID        := p_COST_GROUP_ID;
      l_csp_mtltxn_rec.DEMAND_CLASS        := p_DEMAND_CLASS;
      l_csp_mtltxn_rec.QA_COLLECTION_ID        := p_QA_COLLECTION_ID;
      l_csp_mtltxn_rec.KANBAN_CARD_ID        := p_KANBAN_CARD_ID;
      l_csp_mtltxn_rec.OVERCOMPLETION_TRANSACTION_ID        := p_OVERCOMPLETION_TXN_ID;
      l_csp_mtltxn_rec.OVERCOMPLETION_PRIMARY_QTY        := p_OVERCOMPLETION_PRIMARY_QTY;
      l_csp_mtltxn_rec.OVERCOMPLETION_TRANSACTION_QTY        := p_OVERCOMPLETION_TXN_QTY;
      --l_csp_mtltxn_rec.PROCESS_TYPE        := p_PROCESS_TYPE;
      l_csp_mtltxn_rec.END_ITEM_UNIT_NUMBER        := p_END_ITEM_UNIT_NUMBER;
      l_csp_mtltxn_rec.SCHEDULED_PAYBACK_DATE        := p_SCHEDULED_PAYBACK_DATE;
      l_csp_mtltxn_rec.LINE_TYPE_CODE        := p_LINE_TYPE_CODE;
      l_csp_mtltxn_rec.PARENT_TRANSACTION_TEMP_ID        := p_PARENT_TRANSACTION_TEMP_ID;
      l_csp_mtltxn_rec.PUT_AWAY_STRATEGY_ID        := p_PUT_AWAY_STRATEGY_ID;
      l_csp_mtltxn_rec.PUT_AWAY_RULE_ID        := p_PUT_AWAY_RULE_ID;
      l_csp_mtltxn_rec.PICK_STRATEGY_ID        := p_PICK_STRATEGY_ID;
      l_csp_mtltxn_rec.PICK_RULE_ID        := p_PICK_RULE_ID;
      l_csp_mtltxn_rec.COMMON_BOM_SEQ_ID        := p_COMMON_BOM_SEQ_ID;
      l_csp_mtltxn_rec.COMMON_ROUTING_SEQ_ID        := p_COMMON_ROUTING_SEQ_ID;
      l_csp_mtltxn_rec.COST_TYPE_ID        := p_COST_TYPE_ID;
      l_csp_mtltxn_rec.ORG_COST_GROUP_ID        := p_ORG_COST_GROUP_ID;
      l_csp_mtltxn_rec.MOVE_ORDER_LINE_ID        := p_MOVE_ORDER_LINE_ID;
      l_csp_mtltxn_rec.TASK_GROUP_ID        := p_TASK_GROUP_ID;
      l_csp_mtltxn_rec.PICK_SLIP_NUMBER        := p_PICK_SLIP_NUMBER;
      l_csp_mtltxn_rec.RESERVATION_ID        := p_RESERVATION_ID;
      l_csp_mtltxn_rec.TRANSACTION_STATUS        := p_TRANSACTION_STATUS;
      l_csp_mtltxn_rec.STANDARD_OPERATION_ID        := p_STANDARD_OPERATION_ID;
      l_csp_mtltxn_rec.TASK_PRIORITY        := p_TASK_PRIORITY;
      l_csp_mtltxn_rec.WMS_TASK_TYPE    := p_WMS_TASK_TYPE;
      l_csp_mtltxn_rec.PARENT_LINE_ID   := p_PARENT_LINE_ID;
      --l_csp_mtltxn_rec.SOURCE_LOT_NUMBER    := p_SOURCE_LOT_NUMBER;

    IF p_action_code = 0 THEN
         -- call the create_material
         CSP_Material_Transactions_PVT.Create_material_transactions(
                  P_Api_Version_Number         => p_api_version_number,
                  P_Init_Msg_List              => p_init_msg_list,
                  P_Commit                     => l_commit,
                  p_validation_level           => p_validation_level,
                  P_CSP_Rec                    => l_csp_mtltxn_rec,
                  X_TRANSACTION_TEMP_ID        => l_transaction_temp_id,
                  X_Return_Status              => l_return_status,
                  X_Msg_Count                  => l_msg_count,
                  X_Msg_Data                   => l_msg_data
                  );
    ELSIF p_action_code = 1 THEN
        -- call the update_material
         CSP_Material_Transactions_PVT.Update_material_transactions(
                  P_Api_Version_Number         => p_api_version_number,
                  P_Init_Msg_List              => p_init_msg_list,
                  P_Commit                     => l_commit,
                  p_validation_level           => p_validation_level,
                  P_CSP_Rec                    => l_csp_mtltxn_rec,
                  X_Return_Status              => l_return_status,
                  X_Msg_Count                  => l_msg_count,
                  X_Msg_Data                   => l_msg_data
                  );
    ELSE
       -- call the delete_material
       CSP_Material_Transactions_PVT.Delete_material_transactions(
                  P_Api_Version_Number         => p_api_version_number,
                  P_Init_Msg_List              => p_init_msg_list,
                  P_Commit                     => l_commit,
                  p_validation_level           => p_validation_level,
                  P_CSP_Rec                    => l_csp_mtltxn_rec,
                  X_Return_Status              => l_return_status,
                  X_Msg_Count                  => l_msg_count,
                  X_Msg_Data                   => l_msg_data
                  );
    END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
    ELSE
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF fnd_api.to_boolean(p_commit) THEN
            commit work;
        END IF;
    END IF;


EXCEPTION
    WHEN EXCP_USER_DEFINED THEN
        Rollback to Validate_And_Write_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_msg_pub.count_and_get
        ( p_count => x_msg_count
        , p_data  => x_msg_data);

     WHEN FND_API.G_EXC_ERROR THEN
          JTF_PLSQL_API.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
              ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          JTF_PLSQL_API.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
              ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
    WHEN OTHERS THEN
            Rollback to Validate_And_Write_PUB;
            fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
            fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
            fnd_msg_pub.add;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := fnd_api.g_ret_sts_error;

END Validate_and_Write;

PROCEDURE CSP_MO_LINES_MANUAL_RECEIPT (
-- Start of Comments
-- Procedure name     : CSP_MO_LINES_MANUAL_RECEIPT
-- Purpose            : A procedure to perform move_order_line transaction for move orders that are manual receipts.
-- Usage              : This procedure only processes move orders which are not Autorecipt.
-- History            :
--  28-Dev-99, Add function to take care of the subinventory-restricted attribute of the item.
--  27-Dec-99, Vernon Lou.
--
-- NOTES: If validations have been done in the precedent procedure from which this one is being called, doing a
--  full validation here is unnecessary. To avoid repeating the same validations, you can set the
--  p_validation_level to fnd_api.g_valid_level_none when making the procedure call. However, it is your
--  responsibility to make sure all proper validations have been done before calling this procedure.
--  You are recommended to let this procedure handle the validations if you are not sure.
-- CAUTIONS: This procedure *ALWAYS* calls other procedures with validation_level set to FND_API.G_VALID_LEVEL_NONE.
--  If you do not do your own validations before calling this procedure, you should set the p_validation_level
--  to FND_API.G_VALID_LEVEL_FULL when making the call.
-- End of Comments

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
       X_Msg_Data                OUT NOCOPY     VARCHAR2)
 IS
    l_api_version_number CONSTANT NUMBER := 1.0;
    l_api_name      CONSTANT VARCHAR2(50) := 'CSP_MO_LINES_MANUAL';
    l_msg_data  VARCHAR2(300);

    l_check_existence   NUMBER := 0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER  := 0;
    l_commit    VARCHAR2(1) := FND_API.G_FALSE;
    l_creation_date     DATE;
    l_last_update_date  DATE;
    l_csp_mtltxn_rec  CSP_MATERIAL_TRANSACTIONS_PVT.CSP_Rec_Type;
    l_csp_mtltxn_new_rec CSP_MATERIAL_TRANSACTIONS_PVT.CSP_Rec_Type;

   -- for inserting data, the validation_level should be none
   -- because we do not want to call core apps standard validations.
    l_validation_level  NUMBER  := FND_API.G_VALID_LEVEL_NONE;

    l_csp_intransit_subinventory VARCHAR2(20);
    l_profile_option_id          NUMBER;
    l_to_subinventory            VARCHAR2(20);
    l_to_locator                 NUMBER;
    l_transaction_temp_id        NUMBER := NULL;
    l_transaction_header_id      NUMBER := px_transaction_header_id;
    EXCP_USER_DEFINED            EXCEPTION;

   -- declare a cursor to hold all the records in the mtl_material_transactions_temp table
   -- that belong to the move_order_line_id.
   CURSOR c_ml_records IS
       SELECT TRANSACTION_HEADER_ID            ,
       TRANSACTION_TEMP_ID              ,
       SOURCE_CODE                      ,
       SOURCE_LINE_ID                   ,
       TRANSACTION_MODE                 ,
       LOCK_FLAG                        ,
       LAST_UPDATE_DATE                 ,
       LAST_UPDATED_BY                  ,
       CREATION_DATE                    ,
       CREATED_BY                       ,
       LAST_UPDATE_LOGIN                ,
       REQUEST_ID                       ,
       PROGRAM_APPLICATION_ID           ,
       PROGRAM_ID                       ,
       PROGRAM_UPDATE_DATE              ,
       INVENTORY_ITEM_ID                ,
       REVISION                         ,
       ORGANIZATION_ID                  ,
       SUBINVENTORY_CODE                ,
       LOCATOR_ID                       ,
       TRANSACTION_QUANTITY             ,
       PRIMARY_QUANTITY                 ,
       TRANSACTION_UOM                  ,
       TRANSACTION_COST                 ,
       TRANSACTION_TYPE_ID              ,
       TRANSACTION_ACTION_ID            ,
       TRANSACTION_SOURCE_TYPE_ID       ,
       TRANSACTION_SOURCE_ID            ,
       TRANSACTION_SOURCE_NAME          ,
       TRANSACTION_DATE                 ,
       ACCT_PERIOD_ID                   ,
       DISTRIBUTION_ACCOUNT_ID          ,
       TRANSACTION_REFERENCE            ,
       REQUISITION_LINE_ID              ,
       REQUISITION_DISTRIBUTION_ID      ,
       REASON_ID                        ,
       LOT_NUMBER                       ,
       LOT_EXPIRATION_DATE              ,
       SERIAL_NUMBER                    ,
       RECEIVING_DOCUMENT               ,
       DEMAND_ID                        ,
       RCV_TRANSACTION_ID               ,
       MOVE_TRANSACTION_ID              ,
       COMPLETION_TRANSACTION_ID        ,
       WIP_ENTITY_TYPE                  ,
       SCHEDULE_ID                      ,
       REPETITIVE_LINE_ID               ,
       EMPLOYEE_CODE                    ,
       PRIMARY_SWITCH                   ,
       SCHEDULE_UPDATE_CODE             ,
       SETUP_TEARDOWN_CODE              ,
       ITEM_ORDERING                    ,
       NEGATIVE_REQ_FLAG                ,
       OPERATION_SEQ_NUM                ,
       PICKING_LINE_ID                  ,
       TRX_SOURCE_LINE_ID               ,
       TRX_SOURCE_DELIVERY_ID           ,
       PHYSICAL_ADJUSTMENT_ID           ,
       CYCLE_COUNT_ID                   ,
       RMA_LINE_ID                      ,
       CUSTOMER_SHIP_ID                 ,
       CURRENCY_CODE                    ,
       CURRENCY_CONVERSION_RATE         ,
       CURRENCY_CONVERSION_TYPE         ,
       CURRENCY_CONVERSION_DATE         ,
       USSGL_TRANSACTION_CODE           ,
       VENDOR_LOT_NUMBER                ,
       ENCUMBRANCE_ACCOUNT              ,
       ENCUMBRANCE_AMOUNT               ,
       SHIP_TO_LOCATION                 ,
       SHIPMENT_NUMBER                  ,
       TRANSFER_COST                    ,
       TRANSPORTATION_COST              ,
       TRANSPORTATION_ACCOUNT           ,
       FREIGHT_CODE                    ,
       CONTAINERS                       ,
       WAYBILL_AIRBILL                 ,
       EXPECTED_ARRIVAL_DATE            ,
       TRANSFER_SUBINVENTORY            ,
       TRANSFER_ORGANIZATION            ,
       TRANSFER_TO_LOCATION             ,
       NEW_AVERAGE_COST                 ,
       VALUE_CHANGE                     ,
       PERCENTAGE_CHANGE                ,
       MATERIAL_ALLOCATION_TEMP_ID      ,
       DEMAND_SOURCE_HEADER_ID          ,
       DEMAND_SOURCE_LINE               ,
       DEMAND_SOURCE_DELIVERY           ,
       ITEM_SEGMENTS                   ,
       ITEM_DESCRIPTION                ,
       ITEM_TRX_ENABLED_FLAG            ,
       ITEM_LOCATION_CONTROL_CODE       ,
       ITEM_RESTRICT_SUBINV_CODE        ,
       ITEM_RESTRICT_LOCATORS_CODE      ,
       ITEM_REVISION_QTY_CONTROL_CODE   ,
       ITEM_PRIMARY_UOM_CODE            ,
       ITEM_UOM_CLASS                   ,
       ITEM_SHELF_LIFE_CODE             ,
       ITEM_SHELF_LIFE_DAYS             ,
       ITEM_LOT_CONTROL_CODE            ,
       ITEM_SERIAL_CONTROL_CODE         ,
       ITEM_INVENTORY_ASSET_FLAG        ,
       ALLOWED_UNITS_LOOKUP_CODE        ,
       DEPARTMENT_ID                    ,
       DEPARTMENT_CODE                  ,
       WIP_SUPPLY_TYPE                  ,
       SUPPLY_SUBINVENTORY              ,
       SUPPLY_LOCATOR_ID                ,
       VALID_SUBINVENTORY_FLAG          ,
       VALID_LOCATOR_FLAG               ,
       LOCATOR_SEGMENTS                 ,
       CURRENT_LOCATOR_CONTROL_CODE     ,
       NUMBER_OF_LOTS_ENTERED           ,
       WIP_COMMIT_FLAG                  ,
       NEXT_LOT_NUMBER                  ,
       LOT_ALPHA_PREFIX                 ,
       NEXT_SERIAL_NUMBER               ,
       SERIAL_ALPHA_PREFIX              ,
       SHIPPABLE_FLAG                   ,
       POSTING_FLAG                     ,
       REQUIRED_FLAG                    ,
       PROCESS_FLAG                     ,
       ERROR_CODE                       ,
       ERROR_EXPLANATION                ,
       ATTRIBUTE_CATEGORY               ,
       ATTRIBUTE1                       ,
       ATTRIBUTE2                       ,
       ATTRIBUTE3                       ,
       ATTRIBUTE4                       ,
       ATTRIBUTE5                       ,
       ATTRIBUTE6                       ,
       ATTRIBUTE7                       ,
       ATTRIBUTE8                       ,
       ATTRIBUTE9                       ,
       ATTRIBUTE10                      ,
       ATTRIBUTE11                      ,
       ATTRIBUTE12                      ,
       ATTRIBUTE13                      ,
       ATTRIBUTE14                      ,
       ATTRIBUTE15                      ,
       MOVEMENT_ID                      ,
       RESERVATION_QUANTITY             ,
       SHIPPED_QUANTITY                 ,
       TRANSACTION_LINE_NUMBER          ,
       TASK_ID                          ,
       TO_TASK_ID                       ,
       SOURCE_TASK_ID                   ,
       PROJECT_ID                       ,
       SOURCE_PROJECT_ID                ,
       PA_EXPENDITURE_ORG_ID            ,
       TO_PROJECT_ID                    ,
       EXPENDITURE_TYPE                 ,
       FINAL_COMPLETION_FLAG            ,
       TRANSFER_PERCENTAGE              ,
       TRANSACTION_SEQUENCE_ID          ,
       MATERIAL_ACCOUNT                 ,
       MATERIAL_OVERHEAD_ACCOUNT        ,
       RESOURCE_ACCOUNT                 ,
       OUTSIDE_PROCESSING_ACCOUNT       ,
       OVERHEAD_ACCOUNT                 ,
       FLOW_SCHEDULE                    ,
       COST_GROUP_ID                    ,
       DEMAND_CLASS                     ,
       QA_COLLECTION_ID                 ,
       KANBAN_CARD_ID                   ,
       OVERCOMPLETION_TRANSACTION_ID    ,
       OVERCOMPLETION_PRIMARY_QTY       ,
       OVERCOMPLETION_TRANSACTION_QTY   ,
       --PROCESS_TYPE                     ,  --removed 01/13/00. process_type does not exist in the mmtt table.
       END_ITEM_UNIT_NUMBER             ,
       SCHEDULED_PAYBACK_DATE           ,
       LINE_TYPE_CODE                   ,
       PARENT_TRANSACTION_TEMP_ID       ,
       PUT_AWAY_STRATEGY_ID             ,
       PUT_AWAY_RULE_ID                 ,
       PICK_STRATEGY_ID                 ,
       PICK_RULE_ID                     ,
       COMMON_BOM_SEQ_ID                ,
       COMMON_ROUTING_SEQ_ID            ,
       COST_TYPE_ID                     ,
       ORG_COST_GROUP_ID                ,
       MOVE_ORDER_LINE_ID               ,
       TASK_GROUP_ID                    ,
       PICK_SLIP_NUMBER                 ,
       RESERVATION_ID                   ,
       TRANSACTION_STATUS               ,
       STANDARD_OPERATION_ID            ,
       TASK_PRIORITY                    ,
       -- ADDED by phegde 02/23
       WMS_TASK_TYPE                    ,
       PARENT_LINE_ID
      -- SOURCE_LOT_NUMBER
       FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = p_transaction_temp_id
       AND   organization_id = p_organization_id;

   Cursor l_Get_txn_header_id_csr IS
        SELECT mtl_material_transactions_s.nextval
        FROM   dual;

    l_timeout                     NUMBER := 5;
    l_outcome                     BOOLEAN := TRUE;
    l_error_code                  VARCHAR2(200);
    l_error_explanation           VARCHAR2(240);

 BEGIN
    SAVEPOINT CSP_MO_LINES_MANUAL_PUB;

     IF fnd_api.to_boolean(P_Init_Msg_List) THEN
          -- initialize message list
            FND_MSG_PUB.initialize;
      END IF;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                          p_api_version_number,
                                          l_api_name,
                                          G_PKG_NAME)
     THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  IF p_validation_level = fnd_api.g_valid_level_full THEN
  -- Notes: if validations have been done in the precedence procedure which this one is being from, doing a full
  -- validation here is not necessary. The users can set the p_validation_level to fnd_api.g_valid_level_none
  -- if they do not want to repeat the same validations. However, it is their responsibility to make sure
  -- all proper validations have been done before calling this procedure. It is recommended that they let
  -- this procedure handle the validations except that they know what they are doing.

      -- validate p_organization_id
        IF p_organization_id IS NULL THEN
            FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
            FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_organization_id', TRUE);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        ELSE
                  BEGIN
                    select organization_id into l_check_existence
                    from mtl_parameters
                    where organization_id = p_organization_id;
                  EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                           FND_MESSAGE.SET_NAME ('INV', 'INVALID ORGANIZATION');
                           FND_MSG_PUB.ADD;
                           RAISE EXCP_USER_DEFINED;
                      WHEN OTHERS THEN
                          fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                          fnd_message.set_token('ERR_FIELD', 'p_organization_id', TRUE);
                          fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                          fnd_message.set_token('TABLE', 'mtl_organizations', TRUE);
                          FND_MSG_PUB.ADD;
                          RAISE EXCP_USER_DEFINED;
                  END;
        END IF;

   END IF;   -- end of validations

        -- retrieve profile_option_id associated with CSP_INTRANSIT_SUBINVENTORY
       BEGIN
            select profile_option_id into l_profile_option_id
            from fnd_profile_options_vl
            where profile_option_name = 'CSP_INTRANSIT_SUBINVENTORY';

            -- retrieve the csp intransit subinventory
            select profile_option_value into l_csp_intransit_subinventory
            from fnd_profile_option_values
            where profile_option_id = l_profile_option_id;

             -- check whether the intransit subinventory exists in the organization
            select organization_id into l_check_existence
            from mtl_secondary_inventories
            where secondary_inventory_name = l_csp_intransit_subinventory
            and organization_id = p_organization_id
            and nvl(disable_date, sysdate + 1) > sysdate;

       EXCEPTION
            WHEN NO_DATA_FOUND THEN
                fnd_message.set_name ('CSP', 'CSP_INVALID_INTRANSIT_SUB');
                fnd_msg_pub.add;
                --l_msg_data := 'Validation of intransit subinventory failed. Please make sure a subinventory under the working organizatin is assigned to the CSP_INTRANSIT_SUBINVENTORY profile.';
                RAISE EXCP_USER_DEFINED;
            WHEN OTHERS THEN
                fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                fnd_message.set_token('ERR_FIELD', 'profile_option_value', TRUE);
                fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                fnd_message.set_token('TABLE', 'fnd_profile_option_values', TRUE);
                FND_MSG_PUB.ADD;
                RAISE EXCP_USER_DEFINED;
       END;


       ---------------------------------------------------------------------------------------------
       -- Stage 1. Insert data into the interface table.
       -- 1. Open the cursor c_mtl_records.
       -- 2. Fecth the temp data into l_csp_mtltxn_rec.
       -- 3. Save the to_subinventory and to_locator to l_to_subinventory and l_to_locator.
       -- 4. Update the to_subinventory to l_csp_intransit_subinventory, and to_locator to null.
       -- 5. Update the transaction_source_type_id to 13 (inventory),
       --    transaction_type_id to 2 (subinventory transfer) and
       --    transaction_action_id to 2 (subinventory transfer).
       -- 6. Update the process_flag to 'Y'.
       -- 7. Call the CSP_Material_Transactions_PVT.Update_material_transactions to update
       --    the transfer_subinventory to the instransit subinventory.
       -- 8. Call the csp_transactions_pub.transact_temp_record to insert the temp data into the interface table.
       -- 9. Check the return status. If successful, proceed to stage 2. otherwise, close cursor. Raise an exception.
       -----------------------------------------------------------------------------------------------
              OPEN c_ml_records;
              FETCH c_ml_records into l_csp_mtltxn_rec;

              IF c_ml_records%NOTFOUND THEN
                  fnd_message.set_name ('CSP', 'CSP_INVALID_TXN_TEMP_ID');
                  fnd_message.set_token ('ID', to_char(p_transaction_temp_id), TRUE);
                  fnd_msg_pub.add;
                  close c_ml_records;
                  RAISE EXCP_USER_DEFINED;
              END IF;

              -- make a backup record for creating a new mmtt record.
              l_csp_mtltxn_new_rec := l_csp_mtltxn_rec;
              l_to_subinventory := l_csp_mtltxn_rec.transfer_subinventory;
              l_to_locator      := l_csp_mtltxn_rec.transfer_to_location;

              IF l_csp_mtltxn_rec.subinventory_code = l_csp_intransit_subinventory THEN
               -- the temp record was split before. We need not to split it again.
               -- This section should be evaluated again when the CSP decides to create the
               -- material_tranaction_temp record at the packaging stage instead of the
               -- confirm picking stage.
                   close c_ml_records;
                    x_return_status := fnd_api.g_ret_sts_success;
                   return;
              END IF;
              l_csp_mtltxn_new_rec.transfer_subinventory := l_csp_intransit_subinventory;
              l_csp_mtltxn_new_rec.transfer_to_location  := NULL;
              l_csp_mtltxn_new_rec.transaction_source_type_id := 13;
              l_csp_mtltxn_new_rec.transaction_type_id   := 2;   -- subinventory transfer type
              l_csp_mtltxn_new_rec.transaction_action_id := 2;    -- subinventory tranfer
              l_csp_mtltxn_new_rec.process_flag          := 'Y';
              l_csp_mtltxn_new_rec.LAST_UPDATE_DATE      := sysdate;
            --  l_csp_mtltxn_new_rec.CREATION_DATE         := sysdate;
              l_csp_mtltxn_new_rec.transaction_status   := 3;

               -- check whether the inventory_item is restricted to a predefined list of subinventory
               -- if yes, assign csp_intransit inventory to the list
               DECLARE
                    l_restrict_sub_code NUMBER;
                    l_inventory_item_id NUMBER := l_csp_mtltxn_rec.inventory_item_id;

               BEGIN
                   select restrict_subinventories_code into l_restrict_sub_code
                   from mtl_system_items
                   where inventory_item_id = l_inventory_item_id
                   and organization_id = l_csp_mtltxn_rec.organization_id;

                   IF l_restrict_sub_code = 1 THEN
                        DECLARE
                            l_restricted_sub VARCHAR2(10);

                            G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
                            G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
                        BEGIN
                            select secondary_inventory into l_restricted_sub
                            from mtl_item_sub_inventories
                            where organization_id = p_organization_id
                            and inventory_item_id = l_inventory_item_id
                            and secondary_inventory = l_csp_intransit_subinventory;

                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                -- Assign the item to the l_csp_intransit_subinventory in
                                -- the mtl_item_sub_inventories table by calling the
                                -- mtl_item_sub_inventories_pkg.insert_row.
                                CSP_ITEM_SUB_INVENTORIES_PKG.Insert_Row(
                                  px_INVENTORY_ITEM_ID =>  l_inventory_item_id,
                                  p_ORGANIZATION_ID => p_organization_id,
                                  p_SECONDARY_INVENTORY => l_csp_intransit_subinventory,
                                  p_LAST_UPDATE_DATE => sysdate,
                                  p_LAST_UPDATED_BY => G_LOGIN_ID,
                                  p_CREATION_DATE => sysdate,
                                  p_CREATED_BY => G_USER_ID ,
                                  p_LAST_UPDATE_LOGIN => G_LOGIN_ID,
                                  p_PRIMARY_SUBINVENTORY_FLAG => NULL,
                                  p_PICKING_ORDER => NULL,
                                  p_MIN_MINMAX_QUANTITY => NULL,
                                  p_MAX_MINMAX_QUANTITY => NULL,
                                  p_INVENTORY_PLANNING_CODE => 6,   -- Not Planned
                                  p_FIXED_LOT_MULTIPLE => NULL,
                                  p_MINIMUM_ORDER_QUANTITY => NULL,
                                  p_MAXIMUM_ORDER_QUANTITY => NULL,
                                  p_SOURCE_TYPE => NULL,
                                  p_SOURCE_ORGANIZATION_ID => NULL,
                                  p_SOURCE_SUBINVENTORY => NULL,
                                  p_ATTRIBUTE_CATEGORY => NULL,
                                  p_ATTRIBUTE1 => NULL,
                                  p_ATTRIBUTE2 => NULL,
                                  p_ATTRIBUTE3 => NULL,
                                  p_ATTRIBUTE4 => NULL,
                                  p_ATTRIBUTE5 => NULL,
                                  p_ATTRIBUTE6 => NULL,
                                  p_ATTRIBUTE7 => NULL,
                                  p_ATTRIBUTE8 => NULL,
                                  p_ATTRIBUTE9 => NULL,
                                  p_ATTRIBUTE10 => NULL,
                                  p_ATTRIBUTE11 => NULL,
                                  p_ATTRIBUTE12 => NULL,
                                  p_ATTRIBUTE13 => NULL,
                                  p_ATTRIBUTE14 => NULL,
                                  p_ATTRIBUTE15 => NULL,
                                  p_ENCUMBRANCE_ACCOUNT => NULL,
                                  p_PREPROCESSING_LEAD_TIME => NULL,
                                  p_PROCESSING_LEAD_TIME => NULL,
                                  p_POSTPROCESSING_LEAD_TIME => NULL);

                            WHEN OTHERS THEN
                                fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                                fnd_message.set_token('ERR_FIELD', 'secondary_inventory', TRUE);
                                fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                                fnd_message.set_token('TABLE', 'mtl_item_sub_inventories', TRUE);
                                FND_MSG_PUB.ADD;

                                 IF c_ml_records%ISOPEN THEN
                                    close c_ml_records;
                                 END IF;
                                 RAISE EXCP_USER_DEFINED;
                        END;
                     END IF;
                  END;

                    -- Assign the transaction_temp_id of the p_csp_rec to NULL so that the
                    -- CSP_Material_Transactions_PVT.Create_material_transactions will create a new
                    -- transaction_temp_id from the sequence.

                    --  l_csp_mtltxn_new_rec.transaction_temp_id := NULL;

                      CSP_Material_Transactions_PVT.Update_material_transactions(
                            P_Api_Version_Number         => p_api_version_number,
                            P_Init_Msg_List              => p_init_msg_list,
                            P_Commit                     => l_commit,
                            p_validation_level           => l_validation_level,
                            P_CSP_Rec                    => l_csp_mtltxn_new_rec,
                          --  X_TRANSACTION_TEMP_ID        => l_transaction_temp_id,
                            X_Return_Status              => l_return_status,
                            X_Msg_Count                  => l_msg_count,
                            X_Msg_Data                   => l_msg_data
                           );


                         IF l_return_status <> fnd_api.g_ret_sts_success THEN
                               fnd_message.set_name ('CSP', 'CSP_SUB_TXFER_ERROR');
                               fnd_msg_pub.add;
                                IF c_ml_records%ISOPEN THEN
                                    close c_ml_records;
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                         END IF;

                       -- creating a transaction_header_id for inserting into the interface table
                       IF l_transaction_header_id is null THEN
                           Open l_Get_txn_header_id_csr;
                           Fetch l_Get_txn_header_id_csr Into l_transaction_header_id;
                           Close l_Get_txn_header_id_csr;
                       END IF;

                       csp_transactions_pub.transact_temp_record (
                                 P_Api_Version_Number      => l_api_version_number,
                                 P_Init_Msg_List           => FND_API.G_true,
                                 P_Commit                  => fnd_api.g_false,
                                 p_validation_level        => l_validation_level,
                                 p_transaction_temp_id     => l_csp_mtltxn_new_rec.transaction_temp_id,
                                 px_transaction_header_id  => l_transaction_header_id,
                                 p_online_process_flag     => FALSE,
                                 X_Return_Status           => l_return_status,
                                 X_Msg_Count               => l_msg_count,
                                 X_Msg_Data                => l_msg_data );

                       IF l_return_status <> fnd_api.g_ret_sts_success THEN
                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                       END IF;

                     /*  DO NOT CLEAN UP THE TEMP RECORDS. OTHERWISE, THE FOLLOWING API WILL ERROR OUT.
                         Theory: We copy the existing record to the interface table so that we can initialize the
                                 first phrase of transactions while the temp record is left untouched.
                     */

                     ---------------------------------------
                      -- Stage 2: Update the exsiting record which transfers the items from the
                      --          csp intransit to the destination subinventory.
                      -- 1. Update the subinventory_code to l_csp_intransit_subinventory.
                      -- 2. Update the locator_id to NULL.
                      -- 3. Update the transfer_subinventory to l_to_subinventory.
                      -- 4. Update the tansfer_to_location to l_to_locator.
                      -- 5. Update the process_flag to 'N'.
                      -- 6. Call the CSP_Material_Transactions_PVT.update_material_transactions.

                      l_csp_mtltxn_rec.subinventory_code := l_csp_intransit_subinventory;
                      l_csp_mtltxn_rec.locator_id        := NULL;
                      l_csp_mtltxn_rec.transfer_subinventory := l_to_subinventory;
                      l_csp_mtltxn_rec.transfer_to_location  := l_to_locator;
                      l_csp_mtltxn_rec.process_flag          := 'N';
                      l_csp_mtltxn_rec.LAST_UPDATE_DATE      := sysdate;
                   -- l_csp_mtltxn_rec.CREATION_DATE         := sysdate;

                           CSP_Material_Transactions_PVT.Update_material_transactions(
                                P_Api_Version_Number         => p_api_version_number,
                                P_Init_Msg_List              => p_init_msg_list,
                                P_Commit                     => fnd_api.g_false,
                                p_validation_level           => l_validation_level,
                                P_CSP_Rec                    => l_csp_mtltxn_rec,
                                X_Return_Status              => l_return_status,
                                X_Msg_Count                  => l_msg_count,
                                X_Msg_Data                   => l_msg_data
                                );

                        IF l_return_status <> fnd_api.g_ret_sts_success THEN
                               fnd_message.set_name ('CSP', 'CSP_SUB_TXFER_ERROR');
                               fnd_msg_pub.add;
                                 IF c_ml_records%ISOPEN THEN
                                     close c_ml_records;
                                 END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                -- If it gets to here, processing the mtl_material_transactions_temp should complete successfully.
                    IF c_ml_records%ISOPEN THEN
                          close c_ml_records;
                    END IF;

            /*
               -- Finally, call the process_online to perform the underneath material transactions
               IF NOT CSP_Mo_Mtltxns_Util.Call_Online (p_transaction_header_id   => l_transaction_header_id) THEN
                     l_outcome := FALSE;
                     x_return_status := FND_API.G_RET_STS_ERROR;
                     fnd_msg_pub.count_and_get
                     ( p_count => x_msg_count
                     , p_data  => x_msg_data);
                     Return;
              END IF;
            */
            px_transaction_header_id := l_transaction_header_id;
              IF fnd_api.to_boolean(p_commit) THEN
                  commit work;
              END IF;

              x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
      WHEN EXCP_USER_DEFINED THEN
        Rollback to CSP_MO_LINES_MANUAL_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_msg_pub.count_and_get
        ( p_count => x_msg_count
        , p_data  => x_msg_data);
      WHEN FND_API.G_EXC_ERROR THEN
            JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                 P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                 P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);
      WHEN OTHERS THEN
              Rollback to CSP_MO_LINES_MANUAL_PUB;
              fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
              fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
              fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
              fnd_msg_pub.add;
              fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
              x_return_status := fnd_api.g_ret_sts_error;

END CSP_MO_LINES_MANUAL_RECEIPT;


PROCEDURE CSP_MO_Lines_Auto_Receipt (
-- Start of Comments
-- Procedure name     : CSP_MO_Lines_Auto_Receipt
-- Purpose            : A procedure to perform move_order_line transaction for move orders that are of auto receipts.
-- Usage              : This procedure only processes move orders which are Autorecipts.
-- History            :
--  29-Dec-99, Vernon Lou.
--
-- NOTES: If validations have been done in the precedent procedure from which this one is being called, doing a
--  full validation here is unnecessary. To avoid repeating the same validations, you can set the
--  p_validation_level to fnd_api.g_valid_level_none when making the procedure call. However, it is your
--  responsibility to make sure all proper validations have been done before calling this procedure.
--  You are recommended to let this procedure handle the validations if you are not sure.
-- CAUTIONS: This procedure *ALWAYS* calls other procedures with validation_level set to FND_API.G_VALID_LEVEL_NONE.
--  If you do not do your own validations before calling this procedure, you should set the p_validation_level
--  to FND_API.G_VALID_LEVEL_FULL when making the call.
-- End of Comments

       P_Api_Version_Number      IN      NUMBER,
       P_Init_Msg_List           IN      VARCHAR2     := FND_API.G_FALSE,
       P_Commit                  IN      VARCHAR2     := FND_API.G_FALSE,
       p_validation_level        IN      NUMBER       := FND_API.G_VALID_LEVEL_FULL,
       p_organization_id         IN      NUMBER,
       p_transaction_temp_id     IN      NUMBER,
       X_Return_Status           OUT NOCOPY     VARCHAR2,
       X_Msg_Count               OUT NOCOPY     NUMBER,
       X_Msg_Data                OUT NOCOPY     VARCHAR2)
 IS
    l_api_version_number CONSTANT NUMBER := 1.0;
    l_api_name      CONSTANT VARCHAR2(50) := 'CSP_MO_Lines_Auto';
    l_msg_data  VARCHAR2(300);

    l_check_existence   NUMBER := 0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER  := 0;
    l_commit    VARCHAR2(1) := FND_API.G_FALSE;
    l_creation_date     DATE;
    l_last_update_date  DATE;
    l_csp_mtltxn_rec  CSP_MATERIAL_TRANSACTIONS_PVT.CSP_Rec_Type;

   -- for inserting data, the validation_level should be none
   -- because we do not want to call core apps standard validations.
    l_validation_level  NUMBER  := FND_API.G_VALID_LEVEL_NONE;
    l_transaction_temp_id NUMBER;

    EXCP_USER_DEFINED   EXCEPTION;

   -- declare a cursor to hold all the records in the mtl_material_transactions_temp table
   -- that belong to the move_order_line_id.
   CURSOR c_ml_records IS
        SELECT TRANSACTION_HEADER_ID            ,
       TRANSACTION_TEMP_ID              ,
       SOURCE_CODE                      ,
       SOURCE_LINE_ID                   ,
       TRANSACTION_MODE                 ,
       LOCK_FLAG                        ,
       LAST_UPDATE_DATE                 ,
       LAST_UPDATED_BY                  ,
       CREATION_DATE                    ,
       CREATED_BY                       ,
       LAST_UPDATE_LOGIN                ,
       REQUEST_ID                       ,
       PROGRAM_APPLICATION_ID           ,
       PROGRAM_ID                       ,
       PROGRAM_UPDATE_DATE              ,
       INVENTORY_ITEM_ID                ,
       REVISION                         ,
       ORGANIZATION_ID                  ,
       SUBINVENTORY_CODE                ,
       LOCATOR_ID                       ,
       TRANSACTION_QUANTITY             ,
       PRIMARY_QUANTITY                 ,
       TRANSACTION_UOM                  ,
       TRANSACTION_COST                 ,
       TRANSACTION_TYPE_ID              ,
       TRANSACTION_ACTION_ID            ,
       TRANSACTION_SOURCE_TYPE_ID       ,
       TRANSACTION_SOURCE_ID            ,
       TRANSACTION_SOURCE_NAME          ,
       TRANSACTION_DATE                 ,
       ACCT_PERIOD_ID                   ,
       DISTRIBUTION_ACCOUNT_ID          ,
       TRANSACTION_REFERENCE            ,
       REQUISITION_LINE_ID              ,
       REQUISITION_DISTRIBUTION_ID      ,
       REASON_ID                        ,
       LOT_NUMBER                       ,
       LOT_EXPIRATION_DATE              ,
       SERIAL_NUMBER                    ,
       RECEIVING_DOCUMENT               ,
       DEMAND_ID                        ,
       RCV_TRANSACTION_ID               ,
       MOVE_TRANSACTION_ID              ,
       COMPLETION_TRANSACTION_ID        ,
       WIP_ENTITY_TYPE                  ,
       SCHEDULE_ID                      ,
       REPETITIVE_LINE_ID               ,
       EMPLOYEE_CODE                    ,
       PRIMARY_SWITCH                   ,
       SCHEDULE_UPDATE_CODE             ,
       SETUP_TEARDOWN_CODE              ,
       ITEM_ORDERING                    ,
       NEGATIVE_REQ_FLAG                ,
       OPERATION_SEQ_NUM                ,
       PICKING_LINE_ID                  ,
       TRX_SOURCE_LINE_ID               ,
       TRX_SOURCE_DELIVERY_ID           ,
       PHYSICAL_ADJUSTMENT_ID           ,
       CYCLE_COUNT_ID                   ,
       RMA_LINE_ID                      ,
       CUSTOMER_SHIP_ID                 ,
       CURRENCY_CODE                    ,
       CURRENCY_CONVERSION_RATE         ,
       CURRENCY_CONVERSION_TYPE         ,
       CURRENCY_CONVERSION_DATE         ,
       USSGL_TRANSACTION_CODE           ,
       VENDOR_LOT_NUMBER                ,
       ENCUMBRANCE_ACCOUNT              ,
       ENCUMBRANCE_AMOUNT               ,
       SHIP_TO_LOCATION                 ,
       SHIPMENT_NUMBER                  ,
       TRANSFER_COST                    ,
       TRANSPORTATION_COST              ,
       TRANSPORTATION_ACCOUNT           ,
       FREIGHT_CODE                    ,
       CONTAINERS                       ,
       WAYBILL_AIRBILL                 ,
       EXPECTED_ARRIVAL_DATE            ,
       TRANSFER_SUBINVENTORY            ,
       TRANSFER_ORGANIZATION            ,
       TRANSFER_TO_LOCATION             ,
       NEW_AVERAGE_COST                 ,
       VALUE_CHANGE                     ,
       PERCENTAGE_CHANGE                ,
       MATERIAL_ALLOCATION_TEMP_ID      ,
       DEMAND_SOURCE_HEADER_ID          ,
       DEMAND_SOURCE_LINE               ,
       DEMAND_SOURCE_DELIVERY           ,
       ITEM_SEGMENTS                   ,
       ITEM_DESCRIPTION                ,
       ITEM_TRX_ENABLED_FLAG            ,
       ITEM_LOCATION_CONTROL_CODE       ,
       ITEM_RESTRICT_SUBINV_CODE        ,
       ITEM_RESTRICT_LOCATORS_CODE      ,
       ITEM_REVISION_QTY_CONTROL_CODE   ,
       ITEM_PRIMARY_UOM_CODE            ,
       ITEM_UOM_CLASS                   ,
       ITEM_SHELF_LIFE_CODE             ,
       ITEM_SHELF_LIFE_DAYS             ,
       ITEM_LOT_CONTROL_CODE            ,
       ITEM_SERIAL_CONTROL_CODE         ,
       ITEM_INVENTORY_ASSET_FLAG        ,
       ALLOWED_UNITS_LOOKUP_CODE        ,
       DEPARTMENT_ID                    ,
       DEPARTMENT_CODE                  ,
       WIP_SUPPLY_TYPE                  ,
       SUPPLY_SUBINVENTORY              ,
       SUPPLY_LOCATOR_ID                ,
       VALID_SUBINVENTORY_FLAG          ,
       VALID_LOCATOR_FLAG               ,
       LOCATOR_SEGMENTS                 ,
       CURRENT_LOCATOR_CONTROL_CODE     ,
       NUMBER_OF_LOTS_ENTERED           ,
       WIP_COMMIT_FLAG                  ,
       NEXT_LOT_NUMBER                  ,
       LOT_ALPHA_PREFIX                 ,
       NEXT_SERIAL_NUMBER               ,
       SERIAL_ALPHA_PREFIX              ,
       SHIPPABLE_FLAG                   ,
       POSTING_FLAG                     ,
       REQUIRED_FLAG                    ,
       PROCESS_FLAG                     ,
       ERROR_CODE                       ,
       ERROR_EXPLANATION                ,
       ATTRIBUTE_CATEGORY               ,
       ATTRIBUTE1                       ,
       ATTRIBUTE2                       ,
       ATTRIBUTE3                       ,
       ATTRIBUTE4                       ,
       ATTRIBUTE5                       ,
       ATTRIBUTE6                       ,
       ATTRIBUTE7                       ,
       ATTRIBUTE8                       ,
       ATTRIBUTE9                       ,
       ATTRIBUTE10                      ,
       ATTRIBUTE11                      ,
       ATTRIBUTE12                      ,
       ATTRIBUTE13                      ,
       ATTRIBUTE14                      ,
       ATTRIBUTE15                      ,
       MOVEMENT_ID                      ,
       RESERVATION_QUANTITY             ,
       SHIPPED_QUANTITY                 ,
       TRANSACTION_LINE_NUMBER          ,
       TASK_ID                          ,
       TO_TASK_ID                       ,
       SOURCE_TASK_ID                   ,
       PROJECT_ID                       ,
       SOURCE_PROJECT_ID                ,
       PA_EXPENDITURE_ORG_ID            ,
       TO_PROJECT_ID                    ,
       EXPENDITURE_TYPE                 ,
       FINAL_COMPLETION_FLAG            ,
       TRANSFER_PERCENTAGE              ,
       TRANSACTION_SEQUENCE_ID          ,
       MATERIAL_ACCOUNT                 ,
       MATERIAL_OVERHEAD_ACCOUNT        ,
       RESOURCE_ACCOUNT                 ,
       OUTSIDE_PROCESSING_ACCOUNT       ,
       OVERHEAD_ACCOUNT                 ,
       FLOW_SCHEDULE                    ,
       COST_GROUP_ID                    ,
       DEMAND_CLASS                     ,
       QA_COLLECTION_ID                 ,
       KANBAN_CARD_ID                   ,
       OVERCOMPLETION_TRANSACTION_ID    ,
       OVERCOMPLETION_PRIMARY_QTY       ,
       OVERCOMPLETION_TRANSACTION_QTY   ,
       --PROCESS_TYPE                     ,  --removed 01/13/00. process_type does not exist in the mmtt table.
       END_ITEM_UNIT_NUMBER             ,
       SCHEDULED_PAYBACK_DATE           ,
       LINE_TYPE_CODE                   ,
       PARENT_TRANSACTION_TEMP_ID       ,
       PUT_AWAY_STRATEGY_ID             ,
       PUT_AWAY_RULE_ID                 ,
       PICK_STRATEGY_ID                 ,
       PICK_RULE_ID                     ,
       COMMON_BOM_SEQ_ID                ,
       COMMON_ROUTING_SEQ_ID            ,
       COST_TYPE_ID                     ,
       ORG_COST_GROUP_ID                ,
       MOVE_ORDER_LINE_ID               ,
       TASK_GROUP_ID                    ,
       PICK_SLIP_NUMBER                 ,
       RESERVATION_ID                   ,
       TRANSACTION_STATUS               ,
       STANDARD_OPERATION_ID            ,
       TASK_PRIORITY                    ,
       -- ADDED by phegde 02/23
       WMS_TASK_TYPE                    ,
       PARENT_LINE_ID
       --SOURCE_LOT_NUMBER
       FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = p_transaction_temp_id
       AND   organization_id = p_organization_id;
BEGIN
    SAVEPOINT CSP_MO_Lines_Auto_PUB;

     IF fnd_api.to_boolean(P_Init_Msg_List) THEN
          -- initialize message list
            FND_MSG_PUB.initialize;
      END IF;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                          p_api_version_number,
                                          l_api_name,
                                          G_PKG_NAME)
     THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  IF p_validation_level = fnd_api.g_valid_level_full THEN
  -- Notes: if validations have been done in the precedence procedure which this one is being from, doing a full
  -- validation here is not necessary. The users can set the p_validation_level to fnd_api.g_valid_level_none
  -- if they do not want to repeat the same validations. However, it is their responsibility to make sure
  -- all proper validations have been done before calling this procedure. It is recommended that they let
  -- this procedure handle the validations except that they know what they are doing.

      -- validate p_organization_id
        IF p_organization_id IS NULL THEN
            FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
            FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_organization_id', TRUE);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        ELSE
           BEGIN
                select organization_id into l_check_existence
                from mtl_parameters
                where organization_id = p_organization_id;
           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   FND_MESSAGE.SET_NAME ('INV', 'INVALID ORGANIZATION');
                   FND_MSG_PUB.ADD;
                   RAISE EXCP_USER_DEFINED;
              WHEN OTHERS THEN
                   fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                   fnd_message.set_token('ERR_FIELD', 'p_organization_id', TRUE);
                   fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                   fnd_message.set_token('TABLE', 'mtl_organizations', TRUE);
                   FND_MSG_PUB.ADD;
                   RAISE EXCP_USER_DEFINED;
              END;
        END IF;

      -- validate p_move_order_line_id
        IF p_transaction_temp_id IS NULL THEN
          FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
          FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_transaction_temp_id', TRUE);
          FND_MSG_PUB.ADD;
          RAISE EXCP_USER_DEFINED;
        ELSE
            DECLARE
                l_header_id NUMBER;
                l_move_order_line_id NUMBER;
                l_autoreceipt_flag csp_moveorder_headers.autoreceipt_flag%type;

            -- validate whether the move_order_line_id exists
            BEGIN
                select move_order_line_id into l_move_order_line_id
                from mtl_material_transactions_temp
                where transaction_temp_id = p_transaction_temp_id
                and organization_id = p_organization_id;


                select header_id into l_header_id
                from csp_moveorder_lines
                where line_id = l_move_order_line_id;

                -- validate whether the move order is under manual receipt, if not, raise an exception.
                select autoreceipt_flag into l_autoreceipt_flag
                from csp_moveorder_headers
                where header_id = l_header_id;

                IF l_autoreceipt_flag <> 'Y' THEN
                    fnd_message.set_name ('CSP', 'CSP_INVALID_AUTORECEIPT');
                    fnd_msg_pub.add;
                    RAISE EXCP_USER_DEFINED;
                END IF;

            EXCEPTION
                WHEN EXCP_USER_DEFINED THEN
                    RAISE EXCP_USER_DEFINED;
                WHEN NO_DATA_FOUND THEN
                    fnd_message.set_name ('CSP', 'CSP_NO_MO_TXN_RECORD');
                    fnd_msg_pub.add;
                    RAISE EXCP_USER_DEFINED;
                WHEN OTHERS THEN
                    fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                    fnd_message.set_token('ERR_FIELD', 'autoreceipt_flag', TRUE);
                    fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                    fnd_message.set_token('TABLE', 'csp_moveorder_headers', TRUE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
            END;
         END IF;

   END IF;   -- end of validations

       ---------------------------------------------------------------------------------------------
       -- 1. Open the cursor c_mtl_records.
       -- 2. Fecth one row into l_csp_mtltxn_rec.
       -- 3. Set process_flag to 'Y' and transaction_status to 3.
       -- 4. Calll  CSP_Material_Transactions_PVT.Update_material_transactions to update the

             OPEN c_ml_records;
              LOOP
                    FETCH c_ml_records into l_csp_mtltxn_rec;

                    EXIT WHEN c_ml_records%NOTFOUND;

                    l_csp_mtltxn_rec.process_flag          := 'Y';
                    l_csp_mtltxn_rec.transaction_status    := 3;
                    l_csp_mtltxn_rec.posting_flag          := 'Y';
                    l_csp_mtltxn_rec.LAST_UPDATE_DATE      := sysdate;
                    l_csp_mtltxn_rec.CREATION_DATE         := sysdate;


                  CSP_Material_Transactions_PVT.Update_material_transactions(
                        P_Api_Version_Number         => p_api_version_number,
                        P_Init_Msg_List              => p_init_msg_list,
                        P_Commit                     => fnd_api.g_false,
                        p_validation_level           => l_validation_level,
                        P_CSP_Rec                    => l_csp_mtltxn_rec,
                        X_Return_Status              => l_return_status,
                        X_Msg_Count                  => l_msg_count,
                        X_Msg_Data                   => l_msg_data
                  );

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                        IF c_ml_records%ISOPEN THEN
                            close c_ml_records;
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                  END IF;

             END LOOP;

                -- If it gets to here, updating the order line status should complete successfully.
                  IF c_ml_records%ISOPEN THEN
                         close c_ml_records;
                  END IF;

                -- update orderline

                    IF fnd_api.to_boolean(p_commit) THEN
                        commit work;
                    END IF;

                    x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
    WHEN EXCP_USER_DEFINED THEN
        Rollback to CSP_MO_Lines_Auto_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_msg_pub.count_and_get
        ( p_count => x_msg_count
        , p_data  => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
            JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                 P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                 P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);
    WHEN OTHERS THEN
        Rollback to CSP_MO_Lines_Auto_PUB;
        fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
        fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
        fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
        fnd_msg_pub.add;
        fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
        x_return_status := fnd_api.g_ret_sts_error;


END CSP_MO_Lines_Auto_Receipt;

END CSP_PC_FORM_MTLTXNS;

/
