--------------------------------------------------------
--  DDL for Package Body CSP_MO_MTLTXNS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_MO_MTLTXNS_UTIL" AS
/*$Header: cspgtmub.pls 120.1 2006/07/20 05:39:33 hhaugeru noship $*/
-- Start of Comments
-- Package name     : CSP_MO_MTLTXNS_UTIL
-- Purpose          : This package includes the procedures that handle material transactions associated with any move orders.
-- History
--  08-Feb-00, Add standard messages and validations.
--  29-Dec-99, Vernon Lou.
--
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_MO_MTLTXNS_UTIL';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspgtmub.pls';
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.LOGIN_ID;

PROCEDURE Update_Order_Line_Status(
/* $Header: cspgtmub.pls 120.1 2006/07/20 05:39:33 hhaugeru noship $ */
-- Start of Comments
-- Procedure name   : update_order_line_status
-- Purpose          : This procedure updates the line status of a move order in the mtl_txn_request_lines table.
-- History          :
--  Person       Date               Descriptions
--  ------       ----              --------------
--  klou         03-Jan-2000         Added options for NONE or FULL validations.
--  klou         01-Jan-2000         created.
--
--  NOTES: If validations have been done in the precedent procedure from which this one is being called, doing a
--  full validation here is unnecessary. To avoid repeating the same validations, you can set the
--  p_validation_level to fnd_api.g_valid_level_none when making the procedure call. However, it is your
--  responsibility to make sure all proper validations have been done before calling this procedure.
--  You are recommended to let this procedure handle the validations if you are not sure.
--
-- CAUTIONS: This procedure *ALWAYS* calls other procedures with validation_level set to FND_API.G_VALID_LEVEL_NONE.
--  If you do not do your own validations before calling this procedure, you should set the p_validation_level
--  to FND_API.G_VALID_LEVEL_FULL when making the call.
-- End of Comments

       P_Api_Version_Number      IN      NUMBER,
       P_Init_Msg_List           IN      VARCHAR2     := FND_API.G_FALSE,
       P_Commit                  IN      VARCHAR2     := FND_API.G_FALSE,
       p_validation_level        IN      NUMBER       := FND_API.G_VALID_LEVEL_FULL,
       p_organization_id         IN      NUMBER,
       p_move_order_line_id      IN      NUMBER,
       X_Return_Status           OUT NOCOPY     VARCHAR2,
       X_Msg_Count               OUT NOCOPY     NUMBER,
       X_Msg_Data                OUT NOCOPY     VARCHAR2
 )
 IS

    l_api_version_number CONSTANT NUMBER := 1.0;
    l_api_name      CONSTANT VARCHAR2(50) := 'Update_Order_Line_Sts';
    l_msg_data  VARCHAR2(300);
    l_check_existence   NUMBER := 0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER  := 0;
    l_commit    VARCHAR2(1) := FND_API.G_FALSE;
    l_creation_date     DATE;
    l_last_update_date  DATE;
    l_validation_level  NUMBER  := FND_API.G_VALID_LEVEL_NONE;
    l_header_id NUMBER;
    EXCP_USER_DEFINED   EXCEPTION;

BEGIN
     SAVEPOINT Update_Order_Line_Sts_PUB;
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
          FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_organization_id', FALSE);
          FND_MSG_PUB.ADD;
          RAISE EXCP_USER_DEFINED;
        ELSE
            BEGIN
                select organization_id into l_check_existence
                from mtl_parameters
                where organization_id = p_organization_id ;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                       FND_MESSAGE.SET_NAME ('INV', 'INVALID ORGANIZATION');
                       FND_MSG_PUB.ADD;
                       RAISE EXCP_USER_DEFINED;
                  WHEN OTHERS THEN
                      fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                      fnd_message.set_token('ERR_FIELD', 'p_organization_id', FALSE);
                      fnd_message.set_token('ROUTINE', l_api_name, FALSE);
                      fnd_message.set_token('TABLE', 'mtl_organizations', FALSE);
                      FND_MSG_PUB.ADD;
                      RAISE EXCP_USER_DEFINED;
            END;
        END IF;


         -- validate p_move_order_line_id
        IF p_move_order_line_id IS NULL THEN
          FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
          FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_move_order_line_id', FALSE);
          FND_MSG_PUB.ADD;
          RAISE EXCP_USER_DEFINED;
        ELSE
             -- validate whether the move_order_line_id exists in the mmtt table
            BEGIN
               SELECT transaction_temp_id into l_check_existence
               FROM mtl_material_transactions_temp
               WHERE move_order_line_id =  p_move_order_line_id
               AND organization_id = p_organization_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                fnd_message.set_name ('CSP', 'CSP_INVALID_MOVEORDER_LINE');
                fnd_message.set_token ('LINE_ID', to_char(p_move_order_line_id), FALSE);
                fnd_msg_pub.add;
                RAISE EXCP_USER_DEFINED;
               WHEN TOO_MANY_ROWS THEN
                  -- This is normal. One move order line id can map to many transaction_temp_id's.
                  NULL;
               WHEN OTHERS THEN
                  fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                  fnd_message.set_token('ERR_FIELD', 'p_move_order_line_id', FALSE);
                  fnd_message.set_token('ROUTINE', l_api_name, FALSE);
                  fnd_message.set_token('TABLE', 'mtl_material_transactions_temp', FALSE);
                  FND_MSG_PUB.ADD;
                  RAISE EXCP_USER_DEFINED;
            END;

            -- validate whether the move_order_line_id exists
            BEGIN
                select header_id into l_header_id
                from csp_moveorder_lines
                where line_id = p_move_order_line_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    fnd_message.set_name ('CSP', 'CSP_INVALID_MOVEORDER_LINE');
                    fnd_message.set_token ('LINE_ID', to_char(p_move_order_line_id), FALSE);
                    fnd_msg_pub.add;
                    RAISE EXCP_USER_DEFINED;
                WHEN OTHERS THEN
                  fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                  fnd_message.set_token('ERR_FIELD', 'p_move_order_line_id', FALSE);
                  fnd_message.set_token('ROUTINE', l_api_name, FALSE);
                  fnd_message.set_token('TABLE', 'csp_moveorder_lines', FALSE);
                  FND_MSG_PUB.ADD;
                  RAISE EXCP_USER_DEFINED;
            END;
         END IF;
   END IF;

            -- call a core apps api to update the line status.
            -- Since the core apps api does not return a status, we have to catch the exception it may throw.
            BEGIN

               INV_Trolin_Util.Update_Row_Status
                 (   p_line_id      => p_move_order_line_id,
                     p_status       => 5    -- update status to 5 = closed
                  );
             /*
              update mtl_txn_request_lines
              set line_status = 5
              where line_id = p_move_order_line_id;

                IF fnd_api.to_boolean(p_commit) THEN
                    commit work;
                END IF;
              */
               x_return_status := FND_API.G_RET_STS_SUCCESS;

            EXCEPTION
                WHEN OTHERS THEN
                    RAISE FND_API.G_EXC_ERROR;
            END;

     IF fnd_api.to_boolean(p_commit) THEN
                    commit work;
     END IF;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN EXCP_USER_DEFINED THEN
        Rollback to Update_Order_Line_Sts_PUB;
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
        Rollback to Update_Order_Line_Sts_PUB;
        fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
        fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
        fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
        fnd_msg_pub.add;
        fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
        x_return_status := fnd_api.g_ret_sts_error;
END Update_Order_Line_Status;


FUNCTION validate_mo_line_status (
/* $Header: cspgtmub.pls 120.1 2006/07/20 05:39:33 hhaugeru noship $ */
-- Start of Comments
-- Function name   : validate_mo_line_status
-- Purpose         : This function checks whether the status of all order lines of a move order has been closed.
--                   It returns fnd_api.g_true if the status of all order lines has been closed.
--                   Otherwise, it returns fnd_api.g_false.
-- History          :
--  Person       Date               Descriptions
--  ------       ----              --------------
--  klou         03-Jan-2000         Add options for NONE or FULL validations.
--  klou         01-Jan-2000         created.
--
--  NOTES:
-- End of Comments
        p_move_order_header_id IN  NUMBER,
        p_status_to_be_validated IN NUMBER)
        RETURN VARCHAR2
IS
    l_line_id              NUMBER;
    l_line_status          NUMBER := -1;
    CURSOR l_mo_header_csr IS
      SELECT line_id
      FROM CSP_MOVEORDER_LINES
      WHERE header_id = p_move_order_header_id;

BEGIN
        OPEN l_mo_header_csr;
            LOOP
                FETCH l_mo_header_csr INTO l_line_id;
                EXIT WHEN l_mo_header_csr%NOTFOUND;

                BEGIN
                    SELECT line_status INTO l_line_status
                    FROM mtl_txn_request_lines
                    WHERE line_id = l_line_id;

                     IF l_line_status <> p_status_to_be_validated THEN
                        CLOSE l_mo_header_csr;
                        RETURN fnd_api.g_false;
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        CLOSE l_mo_header_csr;
                       RETURN fnd_api.g_false;
                END;

            END LOOP;


         IF l_mo_header_csr%rowcount = 0 THEN
                IF l_mo_header_csr%ISOPEN THEN
                     CLOSE l_mo_header_csr;
                END IF;
                RETURN fnd_api.g_false;
          END IF;

         IF l_mo_header_csr%ISOPEN THEN
            CLOSE l_mo_header_csr;
         END IF;

        RETURN fnd_api.g_true;

END validate_mo_line_status;


PROCEDURE confirm_receipt (
-- Start of Comments
-- Procedure name  : confirm_receipt
-- Purpose         : This procedure initiates the material transactions for manual receipt orders when the
--                   users confirm that they receive the shipped orders. In addition to updating the mmtt table,
--                   it also updates quantity_received column in the csp_packlist_lines table.
--
-- History          :
--  Person       Date               Descriptions
--  ------       ----              --------------
--  klou         13-Apr-2000         Modify the logic so that misc. receipt is used to handle over receipt and
--                                   misc. issue is used to handle under receipt. Over receiving serial controlled items
--                                   is not allowed but will be implemented in the future release.
--  klou         05-Apr-2000         Add over receiving and receipt short.
--  klou         22-Mar-2000         Add logic to move data from the temp table to the interface table. This is required for
--                                   calling the process_online procedure.
--  klou         08-Feb-2000         Add standard messages.
--  klou         22-Jan-2000         Include codes to handle material transactions for item under serial and/or lot control.
--  klou         07-Jan-2000         include codes to check whether the quantity_received exceed the
--                                   (shipped_quantity - quantity_received). add p_to_subiventroy_code
--                                   and p_to_locator_id.
--  klou         03-Jan-2000         modify to take move_order_line_id instead of header_id.
--  klou         01-Jan-2000         created.
--
--  NOTES: If validations have been done in the precedent procedure from which this one is being called, doing a
--  full validation here is unnecessary. To avoid repeating the same validations, you can set the
--  p_validation_level to fnd_api.g_valid_level_none when making the procedure call. However, it is your
--  responsibility to make sure all proper validations have been done before calling this procedure.
--  You are recommended to let this procedure handle the validations if you are not sure.
--
--  CAUTIONS: This procedure *ALWAYS* calls other procedures with validation_level set to FND_API.G_VALID_LEVEL_NONE.
--  If you do not do your own validations before calling this procedure, you should set the p_validation_level
--  to FND_API.G_VALID_LEVEL_FULL when making the call.
-- End of Comments

       P_Api_Version_Number      IN      NUMBER,
       P_Init_Msg_List           IN      VARCHAR2     := FND_API.G_FALSE,
       P_Commit                  IN      VARCHAR2     := FND_API.G_FALSE,
       p_validation_level        IN      NUMBER       := FND_API.G_VALID_LEVEL_FULL,
       p_packlist_line_id        IN      NUMBER,
       p_organization_id         IN      NUMBER,
       p_transaction_temp_id     IN      NUMBER,
       p_quantity_received       IN      NUMBER,
       p_to_subinventory_code    IN      VARCHAR2      := NULL,
       p_to_locator_id           IN      NUMBER        := NULL,
       p_serial_number           IN      VARCHAR2      := NULL,
       p_lot_number              IN      VARCHAR2      := NULL,
       p_revision                IN      VARCHAR2      := NULL,
       p_receiving_option        IN      NUMBER        := 0, --0 = receiving normal, 1 = receipt short, 2 = over receipt (but do not close the packlist and move order, 3 = over receipt (close everything)
       px_transaction_header_id  IN OUT NOCOPY  NUMBER,
       p_process_flag            IN      VARCHAR2      := fnd_api.g_false,
       X_Return_Status           OUT NOCOPY     VARCHAR2,
       X_Msg_Count               OUT NOCOPY     NUMBER,
       X_Msg_Data                OUT NOCOPY     VARCHAR2)

 IS
    l_line_id                     NUMBER;
    l_api_version_number          CONSTANT NUMBER       := 1.0;
    l_api_name                    CONSTANT VARCHAR2(50) := 'confirm_receipt';
    l_msg_data                    VARCHAR2(300);
    l_check_existence             NUMBER                := 0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER                := 0;
    l_commit                      VARCHAR2(1)           := FND_API.G_FALSE;
    l_creation_date               DATE;
    l_last_update_date            DATE;
    l_header_id                   NUMBER;
    l_packlist_header_id          NUMBER;
    l_packlist_header_status      VARCHAR2(30)          := NULL;
    l_packlist_line_status        VARCHAR2(30)          := NULL;
    l_count			  NUMBER;

   -- for inserting data, the validation_level should be none
   -- because we do not want to call core apps standard validations.
    l_validation_level            NUMBER                := FND_API.G_VALID_LEVEL_NONE;
    l_move_order_line_id          NUMBER;
    l_csp_mtltxn_rec              CSP_MATERIAL_TRANSACTIONS_PVT.CSP_Rec_Type;
    l_csp_mtltxn_over_rec         CSP_MATERIAL_TRANSACTIONS_PVT.CSP_Rec_Type;
    l_csp_mtltxn_bak_rec          CSP_MATERIAL_TRANSACTIONS_PVT.CSP_Rec_Type;
    l_csp_mtltxn_misc_issue_rec   CSP_MATERIAL_TRANSACTIONS_PVT.CSP_Rec_Type;
    l_mtlt_tbl                    csp_pp_util.g_mtlt_tbl_type;
    l_msnt_tbl                    csp_pp_util.g_msnt_tbl_type;
    l_trolin_rec                  INV_Move_Order_PUB.Trolin_Rec_Type;
    l_packlist_headers_rec        CSP_packlist_headers_PVT.PLH_Rec_Type;

    -- Use 1 as the starting index because it is what the core apps API uses.
    -- we are not going to update this index becase there is only one record in the
    -- msnt that is coresponding to the l_packlist_sl_rec.serial_number.
    l_index                       NUMBER                := 1;
    l_transaction_temp_id         NUMBER                := NULL;
    l_txn_temp_id_to_be_removed   NUMBER                := NULL;
    l_outcome                     BOOLEAN               := TRUE;
    l_error_code                  VARCHAR2(200);
    l_error_explanation           VARCHAR2(240);
    l_transaction_header_id       NUMBER                := px_transaction_header_id;
    --l_txn_header_id_cleaned       NUMBER                := NULL;
    l_temp_id_to_be_processed     NUMBER;
    l_quantity_shipped            NUMBER                := 0;
    l_quantity_received           NUMBER                := 0;
    l_avail_qty                   NUMBER                := 0;
    l_recv_less_than_txn          VARCHAR2(1)           := fnd_api.g_false;
    l_org_received_qty            NUMBER;
    EXCP_USER_DEFINED             EXCEPTION;

  CURSOR l_ml_records(l_transaction_temp_id NUMBER) IS
   SELECT
       TRANSACTION_HEADER_ID            ,
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
--       SOURCE_LOT_NUMBER
       FROM mtl_material_transactions_temp
       WHERE transaction_temp_id  = l_transaction_temp_id
       AND   organization_id = p_organization_id;
   CURSOR l_Get_Shipped_Received_Qty IS
        SELECT nvl(quantity_shipped, 0), nvl(quantity_received, 0)
        FROM CSP_Packlist_Lines
        WHERE packlist_line_id = p_packlist_line_id
        and organization_id = p_organization_id;
   CURSOR l_Get_Moveorder_Headers(l_line_id NUMBER) IS
        SELECT distinct header_id
        FROM csp_moveorder_lines
        WHERE line_id = l_line_id;
   CURSOR l_Get_txn_header_id_csr IS
        SELECT mtl_material_transactions_s.nextval
        FROM   dual;
   CURSOR l_Get_Packlist_Status_Csr(l_packlist_header_id NUMBER) IS
        SELECT packlist_status
        FROM csp_packlist_headers
        WHERE packlist_header_id = l_packlist_header_id;
   CURSOR l_Get_Acct_Period_Csr is
        SELECT acct_period_id
        FROM   org_acct_periods
        WHERE  trunc(period_start_date) <= trunc(sysdate)
        AND    trunc(schedule_close_date) >= trunc(sysdate)
        AND    organization_id = p_organization_id
        AND    period_close_date is null
        AND    nvl(open_flag,'Y') = 'Y';
   CURSOR l_Get_Serial_Temp_id_Csr IS
        SELECT MTL_MATERIAL_TRANSACTIONS_S.nextval FROM dual;

   CURSOR l_Get_Packlist_Csr (l_packlist_header_id NUMBER) Is
         SELECT
          PACKLIST_HEADER_ID ,
          CREATED_BY ,
          CREATION_DATE ,
          LAST_UPDATED_BY ,
          LAST_UPDATE_DATE ,
          LAST_UPDATE_LOGIN ,
          ORGANIZATION_ID ,
          PACKLIST_NUMBER ,
          SUBINVENTORY_CODE ,
          PACKLIST_STATUS ,
          DATE_CREATED ,
          DATE_PACKED ,
          DATE_SHIPPED ,
          DATE_RECEIVED ,
          CARRIER ,
          SHIPMENT_METHOD ,
          WAYBILL ,
          COMMENTS ,
          LOCATION_ID,
          PARTY_SITE_ID,
          ATTRIBUTE_CATEGORY ,
          ATTRIBUTE1 ,
          ATTRIBUTE2 ,
          ATTRIBUTE3 ,
          ATTRIBUTE4 ,
          ATTRIBUTE5 ,
          ATTRIBUTE6 ,
          ATTRIBUTE7 ,
          ATTRIBUTE8 ,
          ATTRIBUTE9 ,
          ATTRIBUTE10 ,
          ATTRIBUTE11 ,
          ATTRIBUTE12 ,
          ATTRIBUTE13 ,
          ATTRIBUTE14 ,
          ATTRIBUTE15
    From  CSP_PACKLIST_HEADERS
    WHERE organization_id = p_organization_id
    AND   packlist_header_id = l_packlist_header_id;

    -- Added to fix bug 1321353.
    CURSOR l_Get_Org_Qty_Csr Is
     Select nvl(quantity_shipped,0)-nvl(quantity_received,0)
     From csp_packlist_lines
     Where packlist_line_id = p_packlist_line_id
     And   organization_id  = p_organization_id;
BEGIN
   SAVEPOINT confirm_receipt_PUB;

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
    -- Notes: if validations have been done in the precedence procedure which this one is being called, doing a full
    -- validation here is not necessary. You can set the p_validation_level to fnd_api.g_valid_level_none
    -- if you do not want to repeat the same validations. However, it is your responsibility to make sure
    -- all proper validations have been done before calling this procedure. It is recommended that you let
    -- this procedure handle the validations except that you know what you are doing.

     -- validate p_organization_id
       IF p_organization_id IS NULL THEN
          FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
          FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_organization_id', FALSE);
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
                   fnd_message.set_token('ERR_FIELD', 'p_organization_id', FALSE);
                   fnd_message.set_token('ROUTINE', l_api_name, FALSE);
                   fnd_message.set_token('TABLE', 'mtl_organizations', FALSE);
                   FND_MSG_PUB.ADD;
                   RAISE EXCP_USER_DEFINED;
            END;
       END IF;

    END IF; -- end full validations

      -- Validate the p_packlist_line_id
        IF nvl(p_packlist_line_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
          FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
          FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_packlist_line_id', FALSE);
          FND_MSG_PUB.ADD;
          RAISE EXCP_USER_DEFINED;
        ELSE
            -- get the packlist_header_id
            BEGIN
                select packlist_header_id into l_packlist_header_id
                from csp_packlist_lines
                where organization_id = p_organization_id
                and packlist_line_id = p_packlist_line_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    fnd_message.set_name ('CSP', 'CSP_INVALID_PACKLIST_LINE');
                    fnd_message.set_token ('LINE_ID', to_char(p_packlist_line_id), FALSE);
                    fnd_msg_pub.add;
                    RAISE EXCP_USER_DEFINED;
                WHEN OTHERS THEN
                    fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                    fnd_message.set_token('ERR_FIELD', 'p_packlist_line_id', FALSE);
                    fnd_message.set_token('ROUTINE', l_api_name, FALSE);
                    fnd_message.set_token('TABLE', 'csp_packlist_lines', FALSE);
                    fnd_msg_pub.add;
                    RAISE EXCP_USER_DEFINED;
            END;

            -- Check whether the packlist already has a status of 'Received' (3) or of 'Received Short' (4).
            -- If true, raise an exception because we should not process a closed packlist.
                OPEN l_Get_Packlist_Status_Csr(l_packlist_header_id);
                FETCH l_Get_Packlist_Status_Csr INTO l_packlist_header_status;
                CLOSE l_Get_Packlist_Status_Csr;

                IF l_packlist_header_status IS NULL THEN
                    fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                    fnd_message.set_token('ERR_FIELD', 'p_packlist_header_status', FALSE);
                    fnd_message.set_token('ROUTINE', l_api_name, FALSE);
                    fnd_message.set_token('TABLE', 'CSP_PACKLIST_HEADERS', FALSE);
                    fnd_msg_pub.add;
                    RAISE EXCP_USER_DEFINED;
                END IF;

                IF l_packlist_header_status = '3'  THEN
                    fnd_message.set_name('CSP', 'CSP_INVALID_PACKLIST_TXN');
                    fnd_message.set_token('PACKLIST_HEADER_ID', to_char(l_packlist_header_id), FALSE);
                    fnd_msg_pub.add;
                    RAISE EXCP_USER_DEFINED;
                END IF;

            IF p_validation_level = fnd_api.g_valid_level_full THEN
                  BEGIN
                      select packlist_line_id into l_check_existence
                      from csp_packlist_lines
                      where packlist_line_id = p_packlist_line_id
                      and organization_id = p_organization_id;
                   EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          fnd_message.set_name ('CSP', 'CSP_INVALID_PACKLIST_LINE');
                          fnd_message.set_token ('LINE_ID', to_char(p_packlist_line_id), FALSE);
                          fnd_msg_pub.add;
                          RAISE EXCP_USER_DEFINED;
                      WHEN OTHERS THEN
                          fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                          fnd_message.set_token('ERR_FIELD', 'p_packlist_line_id', FALSE);
                          fnd_message.set_token('ROUTINE', l_api_name, FALSE);
                          fnd_message.set_token('TABLE', 'csp_packlist_lines', FALSE);
                          fnd_msg_pub.add;
                          RAISE EXCP_USER_DEFINED;
                  END;
            END IF;
         END IF;

   -- Validate the quantity received
      IF nvl(p_quantity_received, fnd_api.g_miss_num) = fnd_api.g_miss_num OR p_quantity_received < 0 THEN
         /*  IF p_quantity_received = 0 AND p_receiving_option = 1 THEN
              -- close the move order and ship order because the receiving option is receiving short.
                      -- update quantity_received in the csp_packlist_lines table
                         CSP_PL_SHIP_UTIL.Update_Packlist_Sts_Qty (
                              P_Api_Version_Number => l_api_version_number,
                              P_Init_Msg_List      => FND_API.G_true,
                              P_Commit             => l_commit,
                              p_validation_level   => l_validation_level,
                              p_organization_id    => p_organization_id,
                              p_packlist_line_id   => p_packlist_line_id,
                              p_line_status        => '4',
                              p_quantity_packed    => NULL,
                              p_quantity_shipped   => NULL,
                              p_quantity_received  => 0,
                              x_return_status      => l_return_status,
                              x_msg_count          => l_msg_count,
                              x_msg_data           => l_msg_data
                            );

                     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                            RAISE FND_API.G_EXC_ERROR;
                     END IF;

                   IF fnd_api.to_boolean(CSP_PL_SHIP_UTIL.validate_pl_line_status(l_packlist_header_id, '3', true)) THEN
                         -- update the packlist_header_status
                          CSP_PL_SHIP_UTIL.update_packlist_header_sts (
                              P_Api_Version_Number          => l_api_version_number,
                              P_Init_Msg_List               => FND_API.G_true,
                              P_Commit                      => l_commit,
                              p_validation_level            => l_validation_level,
                              p_packlist_header_id          => l_packlist_header_id,
                              p_organization_id             => p_organization_id,
                              p_packlist_status             => '3',
                              x_return_status               => l_return_status,
                              x_msg_count                   => l_msg_count,
                              x_msg_data                    => l_msg_data );
                    END IF;

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           RAISE FND_API.G_EXC_ERROR;
                    END IF;

                    OPEN l_ml_records(p_transaction_temp_id);
                    FETCH l_ml_records INTO l_csp_mtltxn_rec;

                    IF l_ml_records%NOTFOUND AND (p_receiving_option IN (0, 1)) THEN
                        fnd_message.set_name ('CSP', 'CSP_NO_MO_TXN_RECORD');
                        fnd_msg_pub.add;
                        CLOSE l_ml_records;
                        RAISE EXCP_USER_DEFINED;
                    END IF;
                    CLOSE l_ml_records;

                    l_move_order_line_id := l_csp_mtltxn_rec.move_order_line_id;

                 -- Update the header_status of the mtl_txn_request_headers table.
                    OPEN l_Get_Moveorder_Headers(l_move_order_line_id);
                    FETCH l_Get_Moveorder_Headers INTO l_header_id;
                    IF l_Get_Moveorder_Headers%NOTFOUND THEN
                        CLOSE l_Get_Moveorder_Headers;
                        fnd_message.set_name ('CSP', 'CSP_MOVEORDER_LINE_NO_PARENT');
                        fnd_message.set_token ('LINE_ID', to_char(l_move_order_line_id), FALSE);
                        fnd_msg_pub.add;
                        RAISE EXCP_USER_DEFINED;
                    END IF;
                    CLOSE l_Get_Moveorder_Headers;

                    INV_Trohdr_Util.Update_Row_Status
                               (   p_header_id    => l_header_id,
                                   p_status       => 5);

                    Under_Over_Receipt (
                             p_transaction_temp_id     => p_transaction_temp_id,
                             p_receiving_option        => p_receiving_option,
                             px_transaction_header_id  => l_transaction_header_id, --l_txn_header_id_cleaned,
                             p_discrepancy_qty         => (-1 * l_csp_mtltxn_rec.transaction_quantity),
                             X_Return_Status           => l_return_status,
                             X_Msg_Count               => l_msg_count,
                             X_Msg_Data                => l_msg_data);

                    IF l_transaction_header_id IS NULL THEN
                          -- messages have been set in the Under_Over_Receipt
                          RAISE EXCP_USER_DEFINED;
                    END IF;
                    GOTO END_JOB;
            ELSE
                 fnd_message.set_name ('CSP', 'CSP_INVALID_QUANTITY_RECEIVED');
                 fnd_msg_pub.add;
                 RAISE EXCP_USER_DEFINED;
            END IF; */
             fnd_message.set_name ('CSP', 'CSP_INVALID_QUANTITY_RECEIVED');
             fnd_msg_pub.add;
             RAISE EXCP_USER_DEFINED;
      ELSE
           OPEN l_Get_Shipped_Received_Qty;
           FETCH l_Get_Shipped_Received_Qty INTO l_quantity_shipped, l_quantity_received;
           IF l_Get_Shipped_Received_Qty%NOTFOUND THEN
                fnd_message.set_name ('CSP', 'CSP_INVALID_PACKLIST_LINE');
                fnd_message.set_token ('LINE_ID', to_char(p_packlist_line_id), FALSE);
                fnd_msg_pub.add;
                CLOSE l_Get_Shipped_Received_Qty;
                RAISE EXCP_USER_DEFINED;
           END IF;
           CLOSE l_Get_Shipped_Received_Qty;
      END IF;

 -- Validate the new to_subinventory and to_locator.
    IF p_validation_level = fnd_api.g_valid_level_full THEN
            IF p_to_subinventory_code IS NOT NULL THEN
               DECLARE
                  l_subinventory_code VARCHAR2(10);
               BEGIN
                  SELECT secondary_inventory_name into l_subinventory_code
                  FROM mtl_secondary_inventories
                  WHERE secondary_inventory_name = p_to_subinventory_code
                  AND organization_id = p_organization_id
                  AND nvl(disable_date, sysdate+1) > sysdate;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      fnd_message.set_name ('INV', 'INV-NO SUBINVENTORY RECORD');
                      fnd_message.set_token ('SUBINV', p_to_subinventory_code, FALSE);
                      fnd_message.set_token ('ORG', to_char(p_organization_id), FALSE);
                      fnd_msg_pub.add;
                      RAISE EXCP_USER_DEFINED;
                  WHEN OTHERS THEN
                      fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                      fnd_message.set_token('ERR_FIELD', 'p_to_subinventory_code', FALSE);
                      fnd_message.set_token('ROUTINE', l_api_name, FALSE);
                      fnd_message.set_token('TABLE', 'csp_packlist_lines', FALSE);
                      fnd_msg_pub.add;
                      RAISE EXCP_USER_DEFINED;
              END;
           END IF;
           IF p_to_locator_id IS NOT NULL THEN
              BEGIN
                  SELECT inventory_location_id into l_check_existence
                  FROM mtl_item_locations
                  WHERE inventory_location_id = p_to_locator_id
                  AND organization_id = organization_id
                  AND subinventory_code = p_to_subinventory_code
                  AND nvl(disable_date, sysdate+1) > sysdate;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      fnd_message.set_name('INV', 'INV_LOCATOR_NOT_AVAILABLE');
                      fnd_msg_pub.add;
                      RAISE EXCP_USER_DEFINED;
                  WHEN OTHERS THEN
                      fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                      fnd_message.set_token('ERR_FIELD', 'p_locator_id', FALSE);
                      fnd_message.set_token('ROUTINE', l_api_name, FALSE);
                      fnd_message.set_token('TABLE', 'mtl_item_locations', FALSE);
                      fnd_msg_pub.ADD;
                      RAISE EXCP_USER_DEFINED;
              END;
           END IF;
    END IF;

       -- It is now ready for the transactions
          OPEN l_ml_records(p_transaction_temp_id);
          FETCH l_ml_records INTO l_csp_mtltxn_rec;
          IF l_ml_records%NOTFOUND AND (p_receiving_option IN (0, 1)) THEN
              fnd_message.set_name ('CSP', 'CSP_NO_MO_TXN_RECORD');
              fnd_msg_pub.add;
              CLOSE l_ml_records;
              RAISE EXCP_USER_DEFINED;
          ELSIF l_ml_records%NOTFOUND AND (p_receiving_option IN (2, 3)) THEN
              -- In this case, the user may have received all the items. This situation praticularly happens when
              -- the user over receipts a series of serial items. For example, temp_id = 1001 is designated to receive
              -- item_s of serial numbers from SN0 - SN4. Since confirm_receipt transacts one serial number at a time,
              -- after the user received SN0, SN1, SN2 and SN3, the transaction quantity of temp_id 1001 is deducted to
              -- 1. Finally the user received SN4, the temp record is finally deleted after online process. For over receipt,
              -- the user may want to receive SN5 which is tied to the deleted temp_id. What we need to do is to reconstruct
              -- the temp record before proceeding further.
              CLOSE l_ml_records;

              -- Prepare to create the mtl_material_transactions_temp record
                l_csp_mtltxn_rec.transaction_temp_id := p_transaction_temp_id;
                l_csp_mtltxn_rec.organization_id     := p_organization_id;

                SELECT line_id, inventory_item_id, to_subinventory_code, to_locator_id, uom_code
                INTO l_csp_mtltxn_rec.move_order_line_id, l_csp_mtltxn_rec.inventory_item_id,
                     l_csp_mtltxn_rec.transfer_subinventory, l_csp_mtltxn_rec.transfer_to_location,
                     l_csp_mtltxn_rec.transaction_uom
                FROM mtl_txn_request_lines
                WHERE line_id = (SELECT line_id FROM csp_packlist_lines WHERE packlist_line_id = p_packlist_line_id)
                AND organization_id = p_organization_id;

                -- Find the serial control code, lot control code and item primary uom.
                SELECT primary_uom_code, serial_number_control_code, lot_control_code
                INTO l_csp_mtltxn_rec.item_primary_uom_code, l_csp_mtltxn_rec.item_serial_control_code,
                     l_csp_mtltxn_rec.item_lot_control_code
                FROM mtl_system_items
                WHERE inventory_item_id = l_csp_mtltxn_rec.inventory_item_id
                AND organization_id = p_organization_id;

                -- Find the Account Period ID
                OPEN l_Get_Acct_Period_Csr;
                FETCH l_Get_Acct_Period_Csr INTO l_csp_mtltxn_rec.acct_period_id;
                CLOSE l_Get_Acct_Period_Csr;

                l_csp_mtltxn_rec.transfer_subinventory := nvl(p_to_subinventory_code, l_csp_mtltxn_rec.transfer_subinventory);
                l_csp_mtltxn_rec.transfer_to_location  := nvl(p_to_locator_id, l_csp_mtltxn_rec.transfer_to_location);
                l_csp_mtltxn_rec.transaction_quantity  := p_quantity_received;
                l_csp_mtltxn_rec.primary_quantity      := p_quantity_received;
                l_csp_mtltxn_rec.transaction_source_type_id := 13;   -- Inventory
                l_csp_mtltxn_rec.transaction_type_id   := 2;       -- subinventory transfer type
                l_csp_mtltxn_rec.transaction_action_id := 2;        -- subinventory tranfer
                l_csp_mtltxn_rec.process_flag          := 'Y';
                l_csp_mtltxn_rec.transaction_status    := 3;
                l_csp_mtltxn_rec.LAST_UPDATE_DATE      := sysdate;
                l_csp_mtltxn_rec.CREATION_DATE         := sysdate;
                l_csp_mtltxn_rec.created_by            := g_user_id;
                l_csp_mtltxn_rec.last_update_login     := g_login_id;
                l_csp_mtltxn_rec.last_updated_by       := g_user_id;

                -- change the revision to the specific revision when p_reivison is not null, 05/31/00 klou.
                l_csp_mtltxn_rec.revision              := nvl(p_revision, l_csp_mtltxn_rec.revision);

                IF NOT fnd_api.to_boolean(Convert_Temp_UOM(l_csp_mtltxn_rec, p_quantity_received)) THEN
                  -- Messages are set in the Convert_Temp_UOM function.
                         RAISE EXCP_USER_DEFINED;
                END IF;

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

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE FND_API.G_EXC_ERROR;
                END IF;

             -- Now we have to check whether we need to insert into the mtlt and msnt tables.
                IF nvl(l_csp_mtltxn_rec.item_lot_control_code, 1) <> 1 THEN
                      IF nvl(p_lot_number, fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
                          fnd_message.set_name('CSP', 'CSP_OVER_RECEIPT_LOT_MISSED');
                          fnd_message.set_token('ITEM_NAME', csp_pp_util.get_item_name(l_csp_mtltxn_rec.inventory_item_id), FALSE);
                          fnd_msg_pub.add;
                          RAISE EXCP_USER_DEFINED;
                      END IF;

                      -- Insert the record into the mtlt.
                      l_mtlt_tbl(l_index).transaction_temp_id  := p_transaction_temp_id;
                      l_mtlt_tbl(l_index).last_update_date     := sysdate;
                      l_mtlt_tbl(l_index).last_updated_by      := g_user_id;
                      l_mtlt_tbl(l_index).creation_date        := sysdate;
                      l_mtlt_tbl(l_index).created_by           := g_user_id;
                      l_mtlt_tbl(l_index).last_update_login    := g_login_id;
                      l_mtlt_tbl(l_index).transaction_quantity := l_csp_mtltxn_rec.transaction_quantity;
                      l_mtlt_tbl(l_index).primary_quantity     := l_csp_mtltxn_rec.primary_quantity;
                      l_mtlt_tbl(l_index).lot_number           := p_lot_number;

                      SELECT expiration_date INTO l_mtlt_tbl(l_index).lot_expiration_date
                      FROM mtl_lot_numbers
                      WHERE inventory_item_id = l_csp_mtltxn_rec.inventory_item_id
                      AND organization_id = p_organization_id
                      AND lot_number = p_lot_number;

                      -- create a mtlt record
                      csp_pp_util.insert_mtlt(
                          x_return_status  => l_return_status
                          ,p_mtlt_tbl       => l_mtlt_tbl
                          ,p_mtlt_tbl_size  => 1
                         );

                        IF l_return_status <> fnd_api.g_ret_sts_success THEN
                              fnd_message.set_name ('CSP', 'CSP_EXEC_FAILED_IN_TBL');
                              fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                              fnd_message.set_token ('TABLE', 'MTL_TRANSACTION_LOTS_TEMP', FALSE);
                              fnd_msg_pub.add;
                              RAISE EXCP_USER_DEFINED;
                        END IF;

                        -- If the item is also under serial control, we need to insert into the msnt.
                        IF nvl(l_csp_mtltxn_rec.item_serial_control_code, 1) in (2,5) THEN

                            IF nvl(p_serial_number, fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
                                fnd_message.set_name ('CSP', 'CSP_OVER_RECEIPT_SERIAL_MISSED');
                                fnd_message.set_token('ITEM_NAME', csp_pp_util.get_item_name(l_csp_mtltxn_rec.inventory_item_id), FALSE);
                                fnd_msg_pub.add;
                                RAISE EXCP_USER_DEFINED;
                            ELSE
                                IF p_quantity_received <> 1 THEN
                                    fnd_message.set_name('CSP', 'CSP_OVER_RECEIPT_SERIAL_QTY');
                                    fnd_message.set_token('ITEM_NAME', csp_pp_util.get_item_name(l_csp_mtltxn_rec.inventory_item_id), FALSE);
                                    fnd_msg_pub.add;
                                    RAISE EXCP_USER_DEFINED;
                                END IF;
                            END IF;


                         -- create a transaction_serial_temp_id.
                            OPEN l_Get_Serial_Temp_id_Csr;
                            FETCH l_Get_Serial_Temp_id_Csr INTO l_mtlt_tbl(l_index).serial_transaction_temp_id;
                            CLOSE l_Get_Serial_Temp_id_Csr;

                            -- update the mtlt record
                            update mtl_transaction_lots_temp
                            set serial_transaction_temp_id = l_mtlt_tbl(l_index).serial_transaction_temp_id
                            where transaction_temp_id = l_mtlt_tbl(l_index).transaction_temp_id
                            and lot_number = l_mtlt_tbl(l_index).lot_number;

                            If (SQL%NOTFOUND) then
                                  fnd_message.set_name ('CSP', 'CSP_EXEC_FAILED_IN_TBL');
                                  fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
                                  fnd_message.set_token ('TABLE', 'Mtl_Transaction_Lots_Temp', TRUE);
                                  fnd_msg_pub.add;
                                  RAISE EXCP_USER_DEFINED;
                            End If;

                            -- create the msnt recrod
                             l_msnt_tbl(l_index).transaction_temp_id := l_mtlt_tbl(l_index).serial_transaction_temp_id;
                             l_msnt_tbl(l_index).last_update_date    := sysdate;
                             l_msnt_tbl(l_index).last_updated_by     := g_user_id;
                             l_msnt_tbl(l_index).creation_date       := sysdate;
                             l_msnt_tbl(l_index).created_by          := g_user_id;
                             l_msnt_tbl(l_index).last_update_login   := g_login_id;
                             l_msnt_tbl(l_index).fm_serial_number    := p_serial_number;
                             l_msnt_tbl(l_index).to_serial_number    := p_serial_number;
                             l_msnt_tbl(l_index).serial_prefix       := 1;

                             csp_pp_util.insert_msnt(
                                x_return_status  => l_return_status
                               ,p_msnt_tbl       => l_msnt_tbl
                               ,p_msnt_tbl_size  => 1
                               );

                            IF l_return_status <> fnd_api.g_ret_sts_success THEN
                                fnd_message.set_name ('CSP', 'CSP_EXEC_FAILED_IN_TBL');
                                fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
                                fnd_message.set_token ('TABLE', 'Mtl_Serial_Numbers_Temp', TRUE);
                                fnd_msg_pub.add;
                                RAISE EXCP_USER_DEFINED;
                            END IF;
                       END IF;
                ELSIF  nvl(l_csp_mtltxn_rec.item_lot_control_code, 1) = 1 AND
                       nvl(l_csp_mtltxn_rec.item_serial_control_code, 1) in (2, 5) THEN
                    -- Serial control only
                     IF nvl(p_serial_number, fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
                        fnd_message.set_name ('CSP', 'CSP_OVER_RECEIPT_SERIAL_MISSED');
                        fnd_message.set_token('ITEM_NAME', csp_pp_util.get_item_name(l_csp_mtltxn_rec.inventory_item_id), FALSE);
                        fnd_msg_pub.add;
                        RAISE EXCP_USER_DEFINED;
                     ELSE
                        IF p_quantity_received <> 1 THEN
                            fnd_message.set_name('CSP', 'CSP_OVER_RECEIPT_SERIAL_QTY');
                            fnd_message.set_token('ITEM_NAME', csp_pp_util.get_item_name(l_csp_mtltxn_rec.inventory_item_id), FALSE);
                            fnd_msg_pub.add;
                            RAISE EXCP_USER_DEFINED;
                        END IF;
                     END IF;
                     l_msnt_tbl(l_index).transaction_temp_id := p_transaction_temp_id;
                     l_msnt_tbl(l_index).last_update_date    := sysdate;
                     l_msnt_tbl(l_index).last_updated_by     := g_user_id;
                     l_msnt_tbl(l_index).creation_date       := sysdate;
                     l_msnt_tbl(l_index).created_by          := g_user_id;
                     l_msnt_tbl(l_index).last_update_login   := g_login_id;
                     l_msnt_tbl(l_index).fm_serial_number    := p_serial_number;
                     l_msnt_tbl(l_index).to_serial_number    := p_serial_number;
                     l_msnt_tbl(l_index).serial_prefix       := 1;

                     csp_pp_util.insert_msnt(
                        x_return_status  => l_return_status
                       ,p_msnt_tbl       => l_msnt_tbl
                       ,p_msnt_tbl_size  => 1
                       );

                    IF l_return_status <> fnd_api.g_ret_sts_success THEN
                        fnd_message.set_name ('CSP', 'CSP_EXEC_FAILED_IN_TBL');
                        fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
                        fnd_message.set_token ('TABLE', 'Mtl_Serial_Numbers_Temp', TRUE);
                        fnd_msg_pub.add;
                        RAISE EXCP_USER_DEFINED;
                    END IF;
                ELSE  NULL; -- already taken care.
                END IF;

                Under_Over_Receipt (
                         p_transaction_temp_id     => p_transaction_temp_id,
                         p_receiving_option        => p_receiving_option,
                         px_transaction_header_id  => l_transaction_header_id, --l_txn_header_id_cleaned,
                         p_discrepancy_qty         => l_csp_mtltxn_rec.transaction_quantity,
                         X_Return_Status           => l_return_status,
                         X_Msg_Count               => l_msg_count,
                         X_Msg_Data                => l_msg_data);

                IF l_transaction_header_id IS NULL THEN
                      -- messages have been set in the Under_Over_Receipt
                      RAISE EXCP_USER_DEFINED;
                END IF;
          ELSE
             CLOSE l_ml_records;
          END IF;

         l_move_order_line_id := l_csp_mtltxn_rec.move_order_line_id;

        -- Open the l_Get_Moveorder_Headers to get the header_id to prepare the update of the
        -- header status in the mtl_txn_request_headers.
        OPEN l_Get_Moveorder_Headers(l_move_order_line_id);
        FETCH l_Get_Moveorder_Headers INTO l_header_id;
            IF l_Get_Moveorder_Headers%NOTFOUND THEN
            CLOSE l_Get_Moveorder_Headers;
            fnd_message.set_name ('CSP', 'CSP_MOVEORDER_LINE_NO_PARENT');
            fnd_message.set_token ('LINE_ID', to_char(l_move_order_line_id), FALSE);
            fnd_msg_pub.add;
            RAISE EXCP_USER_DEFINED;
        END IF;
        CLOSE l_Get_Moveorder_Headers;


   -- Check whether the item is subinventory restricted.
   -- If yes, we have to make sure the p_to_subinventory_code is in the restricted list.
   -- The process_online procedure will take care of the validations so it can be optional to do them here.
    IF p_validation_level = fnd_api.g_valid_level_full THEN
         IF p_to_subinventory_code IS NOT NULL THEN
                DECLARE
                    l_restrict_sub_code NUMBER;
                    l_inventory_item_id NUMBER := l_csp_mtltxn_rec.inventory_item_id;
                BEGIN
                   select restrict_subinventories_code into l_restrict_sub_code
                   from mtl_system_items
                   where inventory_item_id = l_inventory_item_id
                   and organization_id = p_organization_id;
                   IF l_restrict_sub_code = 1 THEN   -- the item is subinventory-restricted
                        DECLARE
                            l_restricted_sub VARCHAR2(10);
                        BEGIN
                            select secondary_inventory into l_restricted_sub
                            from mtl_item_sub_inventories
                            where organization_id = p_organization_id
                            and inventory_item_id = l_inventory_item_id
                            and secondary_inventory = p_to_subinventory_code;
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                fnd_message.set_name ('CSP', 'CSP_ITEM_SUB_VIOLATION');
                                fnd_message.set_token ('SUB', p_to_subinventory_code, FALSE);
                                fnd_msg_pub.add;
                                RAISE EXCP_USER_DEFINED;
                            WHEN OTHERS THEN
                                fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                                fnd_message.set_token('ERR_FIELD', 'p_to_subinventory_code', FALSE);
                                fnd_message.set_token('ROUTINE', l_api_name, FALSE);
                                fnd_message.set_token('TABLE', 'mtl_item_sub_inventories', FALSE);
                                fnd_msg_pub.ADD;
                                RAISE EXCP_USER_DEFINED;
                       END;
                  END IF;
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    fnd_message.set_name ('INV', 'INV-NO ITEM RECORD');
                    fnd_msg_pub.add;
                    RAISE EXCP_USER_DEFINED;
                WHEN OTHERS THEN
                    fnd_message.set_name('CSP', 'CSP_ITEM_UNEXPECTED_ERRORS');
                    fnd_message.set_token('ROUTINE', l_api_name, FALSE);
                    fnd_msg_pub.ADD;
                    RAISE EXCP_USER_DEFINED;
            END;
        END IF;
        IF p_to_locator_id IS NOT NULL THEN
         -- check whether the item is under restrict locators
         DECLARE
                l_restrict_locators_code NUMBER;
                l_inventory_item_id NUMBER := l_csp_mtltxn_rec.inventory_item_id;
         BEGIN
                SELECT restrict_locators_code INTO l_restrict_locators_code
                FROM mtl_system_items
                WHERE inventory_item_id = l_inventory_item_id
                AND organization_id = p_organization_id;

                IF l_restrict_locators_code = 1 THEN        -- locators restricted to a predefined list.
                    BEGIN
                        SELECT locator_id INTO l_check_existence
                        FROM mtl_item_loc_defaults
                        WHERE inventory_item_id = l_inventory_item_id
                        AND organization_id = p_organization_id
                        AND locator_id = p_to_locator_id
                        AND subinventory_code = p_to_subinventory_code;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            fnd_message.set_name ('INV', 'INV_LOCATOR_NOT_AVAILABLE');
                            fnd_msg_pub.add;
                            RAISE EXCP_USER_DEFINED;
                        WHEN OTHERS THEN
                            fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                            fnd_message.set_token('ERR_FIELD', 'p_to_locator_id', FALSE);
                            fnd_message.set_token('ROUTINE', l_api_name, FALSE);
                            fnd_message.set_token('TABLE', 'mtl_item_loc_defaults', FALSE);
                            fnd_msg_pub.ADD;
                            RAISE EXCP_USER_DEFINED;
                   END;
                END IF;
            END;
         END IF;
    END IF;

       -- Check whether a new mmtt record is required.
         IF p_quantity_received > l_csp_mtltxn_rec.transaction_quantity THEN

            -- In this case, the user has to specify a p_receiving_option either 2 or 3.
            IF p_receiving_option NOT IN (2, 3) THEN
                fnd_message.set_name('CSP', 'CSP_INVALID_OVER_RECEIPT_QTY');
                fnd_msg_pub.add;
                RAISE EXCP_USER_DEFINED;
            End If;

            l_csp_mtltxn_over_rec := l_csp_mtltxn_rec;

            -- Find the quantity_shipped - quantity_received for that packlist line id. Please see bug 1321353.
            Open l_Get_Org_Qty_Csr;
            Fetch l_Get_Org_Qty_Csr Into l_org_received_qty;
            Close l_Get_Org_Qty_Csr;
            If l_org_received_qty < 0 Then
                fnd_message.set_name('CSP', 'CSP_INVALID_OVER_RECEIPT_QTY');
                fnd_msg_pub.add;
                RAISE EXCP_USER_DEFINED;
            End If;

            If l_org_received_qty < l_csp_mtltxn_rec.transaction_quantity Then
                -- In this case, we need to create two mmtt records. One for the l_org_received_qty, one for the over receipt quantity.
                -- We also need to update the existing mmtt record to the quantity of (transaction_quantity - l_org_received_qty).
                 l_csp_mtltxn_bak_rec := l_csp_mtltxn_rec;

                 IF p_to_subinventory_code IS NOT NULL THEN
                        l_csp_mtltxn_rec.transfer_subinventory := p_to_subinventory_code;
                        l_csp_mtltxn_rec.transfer_to_location  := p_to_locator_id;
                 END IF;

                 -- change the revision to the specific revision when p_reivison is not null, 05/31/00 klou.
                 l_csp_mtltxn_rec.revision    := nvl(p_revision, l_csp_mtltxn_rec.revision);

                 -- Set the transaction_quantity = l_org_received_qty.
                 l_csp_mtltxn_rec.transaction_quantity := l_org_received_qty;

                 IF NOT fnd_api.to_boolean(Convert_Temp_UOM(l_csp_mtltxn_rec,
                                                      (l_org_received_qty))) THEN
                 -- Messages are set in the Convert_Temp_UOM function.
                    RAISE EXCP_USER_DEFINED;
                 ELSE
                     l_csp_mtltxn_rec.primary_quantity := l_org_received_qty;
                 END IF;

                 l_csp_mtltxn_rec.transaction_temp_id := NULL;
                 l_csp_mtltxn_rec.creation_date    := sysdate;
                 l_csp_mtltxn_rec.last_update_date := sysdate;

                 CSP_Material_Transactions_PVT.Create_material_transactions(
                            P_Api_Version_Number         => p_api_version_number,
                            P_Init_Msg_List              => p_init_msg_list,
                            P_Commit                     => l_commit,
                            p_validation_level           => p_validation_level,
                            P_CSP_Rec                    => l_csp_mtltxn_rec,
                            X_TRANSACTION_TEMP_ID        => l_transaction_temp_id,
                            X_Return_Status              => l_return_status,
                            X_Msg_Count                  => l_msg_count,
                            X_Msg_Data                   => l_msg_data);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       RAISE FND_API.G_EXC_ERROR;
                 END IF;
                 l_csp_mtltxn_rec.transaction_temp_id := l_transaction_temp_id;

                 l_temp_id_to_be_processed := l_csp_mtltxn_rec.transaction_temp_id;

                 -- Update the existing mmtt record.
                 -- This mmtt record is intended to stay in the temp table for the next shipment.
                 l_csp_mtltxn_bak_rec.transaction_quantity := l_csp_mtltxn_bak_rec.transaction_quantity - l_org_received_qty;
                 IF NOT fnd_api.to_boolean(Convert_Temp_UOM(l_csp_mtltxn_rec,
                                                      (l_csp_mtltxn_bak_rec.transaction_quantity))) THEN
                 -- Messages are set in the Convert_Temp_UOM function.
                    RAISE EXCP_USER_DEFINED;
                 ELSE
                     l_csp_mtltxn_bak_rec.primary_quantity := l_csp_mtltxn_bak_rec.transaction_quantity;
                 END IF;

                 CSP_Material_Transactions_PVT.Update_material_transactions(
                            P_Api_Version_Number         => p_api_version_number,
                            P_Init_Msg_List              => p_init_msg_list,
                            P_Commit                     => l_commit,
                            p_validation_level           => p_validation_level,
                            P_CSP_Rec                    => l_csp_mtltxn_rec,
                            X_Return_Status              => l_return_status,
                            X_Msg_Count                  => l_msg_count,
                            X_Msg_Data                   => l_msg_data);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       RAISE FND_API.G_EXC_ERROR;
                 END IF;

             Elsif l_org_received_qty = l_csp_mtltxn_rec.transaction_quantity Then

                 -- update the transfer to subinventory, transfer to location id and revision of the
                 -- remaining temp record.
                 IF p_to_subinventory_code IS NOT NULL THEN
                        l_csp_mtltxn_rec.transfer_subinventory := p_to_subinventory_code;
                        l_csp_mtltxn_rec.transfer_to_location  := p_to_locator_id;
                 END IF;

                 -- change the revision to the specific revision when p_reivison is not null, 05/31/00 klou.
                 l_csp_mtltxn_rec.revision    := nvl(p_revision, l_csp_mtltxn_rec.revision);

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

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       RAISE FND_API.G_EXC_ERROR;
                 END IF;
                 l_temp_id_to_be_processed := l_csp_mtltxn_rec.transaction_temp_id;

              Else -- this is an error.
                   fnd_message.set_name('CSP', 'CSP_INVALID_OVER_RECEIPT_QTY');
                   fnd_msg_pub.add;
                   RAISE EXCP_USER_DEFINED;
              End If;

            l_csp_mtltxn_over_rec.creation_date    := sysdate;
            l_csp_mtltxn_over_rec.last_update_date := sysdate;
            l_csp_mtltxn_over_rec.transaction_quantity := p_quantity_received - l_org_received_qty;

         -- change the revision to the specific revision when p_reivison is not null, 05/31/00 klou.
            l_csp_mtltxn_over_rec.revision         := nvl(p_revision, l_csp_mtltxn_over_rec.revision);

            IF p_to_subinventory_code IS NOT NULL THEN
                 /* For misc. receipt, the destination subinventory should be stored in the subinventory_code and locator_id.
                    Storing these information in the transfer_subinventory and transafer_to_location causes the misc. receipt
                    to error. */
                    l_csp_mtltxn_over_rec.subinventory_code := p_to_subinventory_code;
                    l_csp_mtltxn_over_rec.locator_id        := p_to_locator_id;

                    l_csp_mtltxn_over_rec.transfer_subinventory := p_to_subinventory_code;
                    l_csp_mtltxn_over_rec.transfer_to_location  := p_to_locator_id;
            ELSE
                    l_csp_mtltxn_over_rec.subinventory_code := l_csp_mtltxn_over_rec.transfer_subinventory;
                    l_csp_mtltxn_over_rec.locator_id        := l_csp_mtltxn_over_rec.transfer_to_location;

            END IF;

            IF NOT fnd_api.to_boolean(Convert_Temp_UOM(l_csp_mtltxn_over_rec,
                                                      (l_csp_mtltxn_over_rec.transaction_quantity))) THEN
                 -- Messages are set in the Convert_Temp_UOM function.
                    RAISE EXCP_USER_DEFINED;
            ELSE
                l_csp_mtltxn_over_rec.primary_quantity := l_csp_mtltxn_over_rec.transaction_quantity;
            END IF;

            l_csp_mtltxn_over_rec.transaction_temp_id := NULL;

            CSP_Material_Transactions_PVT.Create_material_transactions(
                    P_Api_Version_Number         => p_api_version_number,
                    P_Init_Msg_List              => p_init_msg_list,
                    P_Commit                     => l_commit,
                    p_validation_level           => p_validation_level,
                    P_CSP_Rec                    => l_csp_mtltxn_over_rec,
                    X_TRANSACTION_TEMP_ID        => l_transaction_temp_id,
                    X_Return_Status              => l_return_status,
                    X_Msg_Count                  => l_msg_count,
                    X_Msg_Data                   => l_msg_data);

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
            END IF;

            l_csp_mtltxn_over_rec.transaction_temp_id :=l_transaction_temp_id;

            IF nvl(l_csp_mtltxn_over_rec.item_serial_control_code, 1) in (2,5) THEN
              -- This case should not happen because we always transact one serial number at time.
              -- Eventually, the transaction_qunatity is either 1 or the whole transaction temp record
              -- was deleted when the last expected serial number is transacted.
              fnd_message.set_name('CSP', 'CSP_OVER_RECEIPT_SERIAL_QTY');
              fnd_message.set_token('ITEM_NAME', csp_pp_util.get_item_name(l_csp_mtltxn_over_rec.inventory_item_id), FALSE);
              fnd_msg_pub.add;
              RAISE EXCP_USER_DEFINED;
            END IF;
            IF nvl(l_csp_mtltxn_over_rec.item_lot_control_code, 1) <> 1 THEN
                  IF nvl(p_lot_number, fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
                    fnd_message.set_name('CSP', 'CSP_OVER_RECEIPT_LOT_MISSED');
                    fnd_message.set_token('ITEM_NAME', csp_pp_util.get_item_name(l_csp_mtltxn_over_rec.inventory_item_id), FALSE);
                    fnd_msg_pub.add;
                    RAISE EXCP_USER_DEFINED;
                  END IF;

                  DECLARE
                        l_mtlt_tbl csp_pp_util.g_mtlt_tbl_type;
                        l_index  NUMBER := 1;
                        CURSOR l_Get_Mtlt IS
                              SELECT * FROM mtl_transaction_lots_temp
                              WHERE transaction_temp_id = l_csp_mtltxn_rec.transaction_temp_id -- Get the lot record form the original temp id
                              ORDER BY TRANSACTION_QUANTITY DESC;
                  -- Verify whether there is lot record in the mtlt table.
                  BEGIN
                      OPEN l_Get_Mtlt;
                      FETCH l_Get_Mtlt INTO l_mtlt_tbl(l_index);
                      IF l_Get_Mtlt%rowcount = 0 THEN
                             fnd_message.set_name ('CSP', 'CSP_NO_LOT_TXN_RECORD');
                             fnd_msg_pub.add;
                             CLOSE l_Get_Mtlt;
                             RAISE EXCP_USER_DEFINED;
                      END IF;
                      CLOSE l_Get_Mtlt;

                      l_mtlt_tbl(l_index).transaction_temp_id := l_csp_mtltxn_over_rec.transaction_temp_id;
                      l_mtlt_tbl(l_index).lot_number := p_lot_number;
                      l_mtlt_tbl(l_index).transaction_quantity := l_csp_mtltxn_over_rec.transaction_quantity;
                      l_mtlt_tbl(l_index).primary_quantity := l_csp_mtltxn_over_rec.primary_quantity;

                       csp_pp_util.insert_mtlt(
                            x_return_status  => l_return_status
                            ,p_mtlt_tbl       => l_mtlt_tbl
                            ,p_mtlt_tbl_size  => 1
                       );

                       IF l_return_status <> fnd_api.g_ret_sts_success THEN
                            fnd_message.set_name ('CSP', 'CSP_EXEC_FAILED_IN_TBL');
                            fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                            fnd_message.set_token ('TABLE', 'Mtl_Transaction_Lots_Temp', FALSE);
                            fnd_msg_pub.add;
                            RAISE EXCP_USER_DEFINED;
                       END IF;

                  EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          fnd_message.set_name ('CSP', 'CSP_OVER_RECEIPT_LOT_QTY');
                          fnd_message.set_token ('LOT_NUMBER', p_lot_number, FALSE);
                          fnd_msg_pub.add;
                          RAISE EXCP_USER_DEFINED;
                      WHEN OTHERS THEN
                          RAISE EXCP_USER_DEFINED;
                  END;
             END IF;

             Under_Over_Receipt (
                   p_transaction_temp_id     => l_csp_mtltxn_over_rec.transaction_temp_id,
                   p_receiving_option        => p_receiving_option,
                   px_transaction_header_id  => l_transaction_header_id, --l_txn_header_id_cleaned,
                   p_discrepancy_qty         => l_csp_mtltxn_over_rec.transaction_quantity,
                   X_Return_Status           => l_return_status,
                   X_Msg_Count               => l_msg_count,
                   X_Msg_Data                => l_msg_data);

            IF l_transaction_header_id IS NULL THEN
                  -- messages have been set in the Under_Over_Receipt
                  RAISE EXCP_USER_DEFINED;
            END IF;

            -- Update the mtl_txn_request_lines and mtl_txn_request_headers tables.
            BEGIN
                   select nvl(quantity, 0) into l_trolin_rec.quantity
                   from mtl_txn_request_lines
                   where line_id = l_move_order_line_id;

                   select nvl(quantity_delivered,0) into l_trolin_rec.quantity_delivered
                   from mtl_txn_request_lines
                   where line_id = l_move_order_line_id;

            EXCEPTION
                    WHEN OTHERS THEN
                        fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
                        fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                        fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
                        fnd_msg_pub.add;
                        RAISE EXCP_USER_DEFINED;
            END;

          -- Update order line status and order header status
             IF l_trolin_rec.quantity_delivered = l_trolin_rec.quantity
                OR (p_receiving_option = 3) THEN

                      INV_Trolin_Util.Update_Row_Status
                       (   p_line_id      => l_move_order_line_id,
                           p_status       => 5  );  -- update status to 5 = closed

                      INV_Trohdr_Util.Update_Row_Status
                         (   p_header_id    =>l_header_id,
                             p_status       => 5);    -- update status to 5 = closed

             END IF; -- end the update_line_status block

         ELSIF p_quantity_received = l_csp_mtltxn_rec.transaction_quantity THEN
             IF NOT fnd_api.to_boolean(Convert_Temp_UOM(l_csp_mtltxn_rec, p_quantity_received)) THEN
                    -- Messages are set at the Convert_Temp_UOM function.
                       RAISE EXCP_USER_DEFINED;
             ELSE
                     l_csp_mtltxn_rec.primary_quantity := l_csp_mtltxn_rec.transaction_quantity;
             END IF;

             IF p_to_subinventory_code IS NOT NULL THEN
                    l_csp_mtltxn_rec.transfer_subinventory := p_to_subinventory_code;
                    l_csp_mtltxn_rec.transfer_to_location  := p_to_locator_id;
             END IF;

             -- change the revision to the specific revision when p_reivison is not null, 05/31/00 klou.
             l_csp_mtltxn_rec.revision    := nvl(p_revision, l_csp_mtltxn_rec.revision);

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

             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_ERROR;
             END IF;

             l_temp_id_to_be_processed := l_csp_mtltxn_rec.transaction_temp_id;

                BEGIN
                   select nvl(quantity, 0) into l_trolin_rec.quantity
                   from mtl_txn_request_lines
                   where line_id = l_move_order_line_id;

                   select nvl(quantity_delivered,0) into l_trolin_rec.quantity_delivered
                   from mtl_txn_request_lines
                   where line_id = l_move_order_line_id;

                EXCEPTION
                   WHEN OTHERS THEN
                      fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
                      fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                      fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
                      fnd_msg_pub.add;
                      RAISE EXCP_USER_DEFINED;
                END;

                -- update order line status and order header status
                 IF l_trolin_rec.quantity_delivered = l_trolin_rec.quantity THEN
                      INV_Trolin_Util.Update_Row_Status
                       (   p_line_id      => l_move_order_line_id,
                           p_status       => 5 );  -- update status to 5 = closed

                    -- check whether all the line statuses of the order have been closed.
                    -- If they are all closed, update the header status.
                      IF FND_API.to_boolean(validate_mo_line_status (l_header_id, 5)) THEN
                         -- update the header status in the mtl_txn_request_headers
                          -- call a core apps api to update the line status.
                          -- Since the core apps api does not return a status, we have to catch the exception
                          -- it may throw.
                          BEGIN
                            INV_Trohdr_Util.Update_Row_Status
                               (   p_header_id    => l_header_id,
                                   p_status       => 5);   -- update status to 5 = closed

                             x_return_status := FND_API.G_RET_STS_SUCCESS;
                           EXCEPTION
                                  WHEN OTHERS THEN
                                      RAISE FND_API.G_EXC_ERROR;
                           END;
                        END IF;
               END IF; -- end the update_line_status block

        ELSE  -- p_quantity_received less than transaction_quantity
           -- 1. create a new mmtt record having transaction_quantity = p_quantity_received
           --     and process_flag = 'Y' and transaction_status = 3.
           -- 2. update the transaction_quantity of the existing one to the remaining quantity.
          l_recv_less_than_txn := fnd_api.g_true;

          IF p_receiving_option NOT IN (0, 1) THEN
                fnd_message.set_name('CSP', 'CSP_INVALID_OVER_RECEIPT_QTY');
                fnd_msg_pub.add;
                RAISE EXCP_USER_DEFINED;
           END IF;
           l_csp_mtltxn_bak_rec := l_csp_mtltxn_rec;

          DECLARE  -- beginning of main transaction
              CURSOR l_Get_Packlist_SL IS
                              SELECT PACKLIST_SERIAL_LOT_ID,
                                     CREATED_BY,
                                     CREATION_DATE,
                                     LAST_UPDATED_BY,
                                     LAST_UPDATE_DATE,
                                     LAST_UPDATE_LOGIN,
                                     PACKLIST_LINE_ID,
                                     ORGANIZATION_ID,
                                     INVENTORY_ITEM_ID,
                                     QUANTITY,
                                     LOT_NUMBER,
                                     SERIAL_NUMBER
                              FROM CSP_Packlist_Serial_Lots
                              WHERE packlist_line_id = p_packlist_line_id
                              AND organization_id    = p_organization_id;
                   l_packlist_sl_rec  CSP_Pack_Serial_Lots_PVT.plsl_Rec_Type;
                   l_serial_number    VARCHAR2(30):= NULL;
                   l_lot_number       VARCHAR2(80) := NULL;
                   l_serial_lot_flag  VARCHAR2(1)        := fnd_api.g_false;

          BEGIN
              If p_quantity_received > 0 Then
                    l_csp_mtltxn_rec.transaction_quantity := p_quantity_received;
                    l_csp_mtltxn_rec.primary_quantity     := p_quantity_received;
                    l_csp_mtltxn_rec.transaction_temp_id  := NULL;
                    l_move_order_line_id                  := l_csp_mtltxn_rec.move_order_line_id;

                    IF NOT fnd_api.to_boolean(Convert_Temp_UOM(l_csp_mtltxn_rec, p_quantity_received)) THEN
                        -- Messages are set in the Convert_Temp_UOM function.
                           RAISE EXCP_USER_DEFINED;
                    ELSE
                         l_csp_mtltxn_rec.primary_quantity := l_csp_mtltxn_rec.transaction_quantity;
                    END IF;

                 -- Change the revision to the specific revision when p_reivison is not null, 05/31/00 klou.
                    l_csp_mtltxn_rec.revision := nvl(p_revision, l_csp_mtltxn_rec.revision);

                    IF p_to_subinventory_code IS NOT NULL THEN
                        l_csp_mtltxn_rec.transfer_subinventory := p_to_subinventory_code;
                        l_csp_mtltxn_rec.transfer_to_location  := p_to_locator_id;
                    END IF;

                    CSP_Material_Transactions_PVT.Create_material_transactions(
                        P_Api_Version_Number         => p_api_version_number,
                        P_Init_Msg_List              => p_init_msg_list,
                        P_Commit                     => l_commit,
                        p_validation_level           => p_validation_level,
                        P_CSP_Rec                    => l_csp_mtltxn_rec,
                        X_TRANSACTION_TEMP_ID        => l_transaction_temp_id,
                        X_Return_Status              => l_return_status,
                        X_Msg_Count                  => l_msg_count,
                        X_Msg_Data                   => l_msg_data);

                     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;
                    l_temp_id_to_be_processed := l_transaction_temp_id;
                    -- update the existing mmtt record
                    l_csp_mtltxn_bak_rec.transaction_quantity  :=  l_csp_mtltxn_bak_rec.transaction_quantity - p_quantity_received;
                 -- l_csp_mtltxn_bak_rec.primary_quantity      :=  l_csp_mtltxn_bak_rec.primary_quantity - p_quantity_received;
                    l_csp_mtltxn_bak_rec.last_update_date      := sysdate;

                    IF NOT fnd_api.to_boolean(Convert_Temp_UOM(l_csp_mtltxn_bak_rec, l_csp_mtltxn_bak_rec.transaction_quantity)) THEN
                    -- Messages are set in the Convert_Temp_UOM function.
                           RAISE EXCP_USER_DEFINED;
                    ELSE
                         l_csp_mtltxn_bak_rec.primary_quantity := l_csp_mtltxn_bak_rec.transaction_quantity;
                    END IF;

                    CSP_Material_Transactions_PVT.Update_material_transactions(
                            P_Api_Version_Number         => p_api_version_number,
                            P_Init_Msg_List              => p_init_msg_list,
                            P_Commit                     => fnd_api.g_false,
                            p_validation_level           => l_validation_level,
                            P_CSP_Rec                    => l_csp_mtltxn_bak_rec,
                            X_Return_Status              => l_return_status,
                            X_Msg_Count                  => l_msg_count,
                            X_Msg_Data                   => l_msg_data
                            );

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       RAISE FND_API.G_EXC_ERROR;
                    END IF;

                    -- Check whether we need to update the msnt and the mtlt tables.
                    OPEN l_Get_Packlist_SL;
                    LOOP
                        FETCH l_Get_Packlist_SL INTO l_packlist_sl_rec;
                        EXIT WHEN l_Get_Packlist_SL%NOTFOUND;
                        IF p_serial_number IS NULL THEN
                              l_serial_number := l_packlist_sl_rec.serial_number;
                            IF p_lot_number IS NULL THEN
                               l_lot_number := l_packlist_sl_rec.lot_number;
                            ELSE
                               l_lot_number := p_lot_number;
                            END IF;

                            IF l_lot_number = l_packlist_sl_rec.lot_number OR
                                l_lot_number IS NULL THEN
                              Transact_Serial_Lots (
                                   p_new_transaction_temp_id =>   l_transaction_temp_id,
                                   p_old_transaction_temp_id =>   l_csp_mtltxn_bak_rec.transaction_temp_id,
                                   p_lot_number              =>   l_lot_number,
                                   p_serial_number           =>   l_serial_number,
                                   p_qty_received            =>   p_quantity_received,
                                   X_Return_Status           =>   l_return_status,
                                   X_Msg_Count               =>   l_msg_count,
                                   X_Msg_Data                =>   l_msg_data);
                               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                      CLOSE l_Get_Packlist_SL;
                                      RAISE FND_API.G_EXC_ERROR;
                               END IF;
                             END IF;

                             l_serial_lot_flag := fnd_api.g_true;
                         ELSE
                            l_serial_number := p_serial_number;
                            IF p_lot_number IS NULL THEN
                               l_lot_number := l_packlist_sl_rec.lot_number;
                            ELSE
                               l_lot_number := p_lot_number;
                            END IF;
                            IF (l_lot_number = l_packlist_sl_rec.lot_number OR
                                 l_lot_number IS NULL) AND
                                    l_serial_number = l_packlist_sl_rec.serial_number THEN
                                Transact_Serial_Lots (
                                   p_new_transaction_temp_id =>   l_transaction_temp_id,
                                   p_old_transaction_temp_id =>   l_csp_mtltxn_bak_rec.transaction_temp_id,
                                   p_lot_number              =>   l_lot_number,
                                   p_serial_number           =>   l_serial_number,
                                   p_qty_received            =>   p_quantity_received,
                                   X_Return_Status           =>   l_return_status,
                                   X_Msg_Count               =>   l_msg_count,
                                   X_Msg_Data                =>   l_msg_data);
                                   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                          CLOSE l_Get_Packlist_SL;
                                          RAISE FND_API.G_EXC_ERROR;
                                   END IF;
                                   l_serial_lot_flag := fnd_api.g_true;
                                   EXIT;
                             END IF;
                          END IF;
                    END LOOP;
                    IF NOT fnd_api.to_boolean(l_serial_lot_flag) AND
                        l_Get_Packlist_SL%rowcount <> 0 THEN
                           fnd_message.set_name ('CSP', 'CSP_NO_SERIAL_LOT_PACKLIST');
                           fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                           fnd_msg_pub.add;
                           CLOSE l_Get_Packlist_SL;
                           RAISE EXCP_USER_DEFINED;
                    END IF;
                    IF l_Get_Packlist_SL%ISOPEN THEN
                       CLOSE l_Get_Packlist_SL;
                    END IF;
               End If; --end p_quantity_received > 0

               IF p_receiving_option = 1 THEN
                   DECLARE   -- main misc issue txn
                        l_misc_issue_qty                         NUMBER := 0;
                   BEGIN
                        Open l_Get_Org_Qty_Csr;
                        Fetch l_Get_Org_Qty_Csr Into l_org_received_qty;
                        Close l_Get_Org_Qty_Csr;

                        If l_org_received_qty < 0 Then
                                fnd_message.set_name('CSP', 'CSP_INVALID_OVER_RECEIPT_QTY');
                                fnd_msg_pub.add;
                                RAISE EXCP_USER_DEFINED;
                        End If;

                        -- Now we need to do a misc. issue of which the txn qty = l_org_received_qty - p_quantity_received
                        l_misc_issue_qty := l_org_received_qty - p_quantity_received;

                       If l_misc_issue_qty = l_csp_mtltxn_bak_rec.transaction_quantity Then
                            -- 1. Update the move order header.
                            -- 2. Transact l_csp_mtltxn_bak_rec as misc issue.
                            -- Receipt short: update the header status
                             INV_Trohdr_Util.Update_Row_Status ( p_header_id    => l_header_id,
                                                                 p_status       => 5);

                             l_csp_mtltxn_misc_issue_rec :=  l_csp_mtltxn_bak_rec;
                       Else
                            -- 1. Create a new temp record whose transaction_quantity = l_misc_issue_qty.
                            -- 2. Update the l_csp_mtltxn_bak_rec such that the
                            --     transaction_quantity = l_csp_mtltxn_bak_rec.transaction_quantity - l_misc_issue_qty.
                            -- * Please be aware that receiving short of serial items is not available at release 2.

                            l_csp_mtltxn_misc_issue_rec                      :=  l_csp_mtltxn_bak_rec;
                            l_csp_mtltxn_misc_issue_rec.transaction_quantity :=  l_misc_issue_qty;
                            l_csp_mtltxn_misc_issue_rec.creation_date        :=  sysdate;

                            IF NOT fnd_api.to_boolean(Convert_Temp_UOM(l_csp_mtltxn_misc_issue_rec,
                                                                      (l_csp_mtltxn_misc_issue_rec.transaction_quantity))) THEN
                                 -- Messages are set in the Convert_Temp_UOM function.
                                    RAISE EXCP_USER_DEFINED;
                            ELSE
                                l_csp_mtltxn_misc_issue_rec.primary_quantity := l_csp_mtltxn_misc_issue_rec.transaction_quantity;
                            END IF;

                            l_csp_mtltxn_misc_issue_rec.transaction_temp_id := NULL;

                            CSP_Material_Transactions_PVT.Create_material_transactions(
                                    P_Api_Version_Number         => p_api_version_number,
                                    P_Init_Msg_List              => p_init_msg_list,
                                    P_Commit                     => l_commit,
                                    p_validation_level           => p_validation_level,
                                    P_CSP_Rec                    => l_csp_mtltxn_misc_issue_rec,
                                    X_TRANSACTION_TEMP_ID        => l_transaction_temp_id,
                                    X_Return_Status              => l_return_status,
                                    X_Msg_Count                  => l_msg_count,
                                    X_Msg_Data                   => l_msg_data);

                            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                  RAISE FND_API.G_EXC_ERROR;
                            END IF;

                            l_csp_mtltxn_misc_issue_rec.transaction_temp_id :=l_transaction_temp_id;
                            --//// Take care of the msnt and mtlt records when the whole packlist is closed in short, i.e. p_quantity_received=0
                            -- Check whether we need to update the msnt and the mtlt tables.
                            If p_quantity_received = 0 Then
                                OPEN l_Get_Packlist_SL;
                                LOOP
                                    FETCH l_Get_Packlist_SL INTO l_packlist_sl_rec;
                                    EXIT WHEN l_Get_Packlist_SL%NOTFOUND;
                                    l_lot_number    := l_packlist_sl_rec.lot_number;
                                    l_serial_number := l_packlist_sl_rec.serial_number;

                                    IF l_serial_number IS NULL AND l_lot_number IS NOT NULL THEN
                                     -- Items only under lot control.
                                        Transact_Serial_Lots (
                                             p_new_transaction_temp_id =>   l_transaction_temp_id,
                                             p_old_transaction_temp_id =>   l_csp_mtltxn_bak_rec.transaction_temp_id,
                                             p_lot_number              =>   l_lot_number,
                                             p_serial_number           =>   l_serial_number,
                                             p_qty_received            =>   l_misc_issue_qty,
                                             X_Return_Status           =>   l_return_status,
                                             X_Msg_Count               =>   l_msg_count,
                                             X_Msg_Data                =>   l_msg_data);
                                         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                CLOSE l_Get_Packlist_SL;
                                                RAISE FND_API.G_EXC_ERROR;
                                         END IF;
                                         l_serial_lot_flag := fnd_api.g_true;
                                     ELSIF l_serial_number IS NOT NULL THEN
                                      -- The item is under serial control. It may be or may not be under lot control.
                                      -- However, whether it is under lot control or not, it is not important to us
                                      -- because we have to transact one serial number at a time.
                                         Transact_Serial_Lots (
                                             p_new_transaction_temp_id =>   l_transaction_temp_id,
                                             p_old_transaction_temp_id =>   l_csp_mtltxn_bak_rec.transaction_temp_id,
                                             p_lot_number              =>   l_lot_number,
                                             p_serial_number           =>   l_serial_number,
                                             p_qty_received            =>   1,
                                             X_Return_Status           =>   l_return_status,
                                             X_Msg_Count               =>   l_msg_count,
                                             X_Msg_Data                =>   l_msg_data);
                                             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                    CLOSE l_Get_Packlist_SL;
                                                    RAISE FND_API.G_EXC_ERROR;
                                             END IF;
                                             l_serial_lot_flag := fnd_api.g_true;
                                       ELSE
                                          -- This is an error. The csp_packlist_serial_lots table should not contain any error
                                          -- that has neither serial number nor lot number.
                                          l_serial_lot_flag := fnd_api.g_false;
                                          exit;
                                       END IF;
                                END LOOP;
                                IF NOT fnd_api.to_boolean(l_serial_lot_flag) AND
                                    l_Get_Packlist_SL%rowcount <> 0 THEN
                                       fnd_message.set_name ('CSP', 'CSP_NO_SERIAL_LOT_PACKLIST');
                                       fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                                       fnd_msg_pub.add;
                                       CLOSE l_Get_Packlist_SL;
                                       RAISE EXCP_USER_DEFINED;
                                END IF;
                                IF l_Get_Packlist_SL%ISOPEN THEN
                                   CLOSE l_Get_Packlist_SL;
                                END IF;
                            End If; -- end p_quantity_received = 0

                            --//////////////////////
                            -- update the existing record
                            l_csp_mtltxn_bak_rec.transaction_quantity  :=  l_csp_mtltxn_bak_rec.transaction_quantity - l_misc_issue_qty;
                            l_csp_mtltxn_bak_rec.last_update_date      :=  sysdate;

                            IF NOT fnd_api.to_boolean(Convert_Temp_UOM(l_csp_mtltxn_bak_rec, l_csp_mtltxn_bak_rec.transaction_quantity)) THEN
                            -- Messages are set in the Convert_Temp_UOM function.
                                   RAISE EXCP_USER_DEFINED;
                            ELSE
                                 l_csp_mtltxn_bak_rec.primary_quantity := l_csp_mtltxn_bak_rec.transaction_quantity;
                            END IF;

                            CSP_Material_Transactions_PVT.Update_material_transactions(
                                    P_Api_Version_Number         => p_api_version_number,
                                    P_Init_Msg_List              => p_init_msg_list,
                                    P_Commit                     => fnd_api.g_false,
                                    p_validation_level           => l_validation_level,
                                    P_CSP_Rec                    => l_csp_mtltxn_bak_rec,
                                    X_Return_Status              => l_return_status,
                                    X_Msg_Count                  => l_msg_count,
                                    X_Msg_Data                   => l_msg_data
                                    );

                            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                               RAISE FND_API.G_EXC_ERROR;
                            END IF;
                         End If;

                       -- Initialize the misc. issue.
                        Under_Over_Receipt (
                               p_transaction_temp_id     => l_csp_mtltxn_misc_issue_rec.transaction_temp_id,
                               p_receiving_option        => p_receiving_option,
                               px_transaction_header_id  => l_transaction_header_id,
                               p_discrepancy_qty         => (-1 * l_csp_mtltxn_misc_issue_rec.transaction_quantity),
                               X_Return_Status           => l_return_status,
                               X_Msg_Count               => l_msg_count,
                               X_Msg_Data                => l_msg_data);

                        IF l_transaction_header_id IS NULL THEN
                              -- messages were set at the sub function level.
                              RAISE EXCP_USER_DEFINED;
                        END IF;
                   END;  -- end main misc issue txn
             END IF;     -- end p_receiving_option = 0
           END;          -- End of main transaction (p_quantity_received < transaction_quantity).
      END IF;

      -- Define the packlist line status.
      -- 4 = received short, 3 = received, 2 = shipped, 1 = open
       IF p_receiving_option = 0 THEN
            IF l_quantity_shipped = (l_quantity_received + p_quantity_received) THEN
                 l_packlist_line_status := '3';
            END IF;
       ELSIF p_receiving_option = 1 THEN
           l_packlist_line_status := '4';  -- receipt short.
       ELSIF p_receiving_option = 3 THEN   -- over receipt, but close the packlist and move order
           l_packlist_line_status := '3';
       ELSE
           l_packlist_line_status := NULL;
       END IF;

     -- Update quantity_received in the csp_packlist_lines table
       CSP_PL_SHIP_UTIL.Update_Packlist_Sts_Qty (
          P_Api_Version_Number => l_api_version_number,
          P_Init_Msg_List      => FND_API.G_true,
          P_Commit             => l_commit,
          p_validation_level   => l_validation_level,
          p_organization_id    => p_organization_id,
          p_packlist_line_id   => p_packlist_line_id,
          p_line_status        => l_packlist_line_status,
          p_quantity_packed    => NULL,
          p_quantity_shipped   => NULL,
          p_quantity_received  => (l_quantity_received + p_quantity_received),
          x_return_status      => l_return_status,
          x_msg_count          => l_msg_count,
          x_msg_data           => l_msg_data
        );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Define the packlist header status
     IF p_receiving_option = 0 OR p_receiving_option = 3 THEN
        BEGIN
            SELECT count(packlist_line_status)
            INTO l_count
            FROM csp_packlist_lines
            WHERE packlist_header_id = l_packlist_header_id
            AND packlist_line_status = 4;
          EXCEPTION
            WHEN no_data_found THEN
              null;
        END;

        IF fnd_api.to_boolean(CSP_PL_SHIP_UTIL.validate_pl_line_status(l_packlist_header_id, '3', true)) THEN
          IF (l_count > 0) THEN
            l_packlist_header_status := '4';
          ELSE
            l_packlist_header_status := '3';
          END IF;
        ELSE
          l_packlist_header_status := fnd_api.g_miss_char;  --fnd_api.g_miss_char = not to update the status
        END IF;
     ELSIF p_receiving_option = 1 THEN
        IF fnd_api.to_boolean(CSP_PL_SHIP_UTIL.validate_pl_line_status(l_packlist_header_id, '3', true)) THEN
                l_packlist_header_status := '4';
        ELSE
           l_packlist_header_status := fnd_api.g_miss_char;  --fnd_api.g_miss_char = not to update the status
        END IF;
     ELSE
           l_packlist_header_status := fnd_api.g_miss_char;  --fnd_api.g_miss_char = not to update the status
     END IF;

    -- Update the date_received and the packlist_status in the packlist. klou 5/17/00.
       Open l_Get_Packlist_Csr(l_packlist_header_id);
       Fetch l_Get_Packlist_Csr Into l_packlist_headers_rec;
       If l_Get_Packlist_Csr%NOTFOUND Then
          fnd_message.set_name ('CSP', 'CSP_INVALID_PACKLIST_LINE');
          fnd_message.set_token ('LINE_ID', to_char(p_packlist_line_id), FALSE);
          fnd_msg_pub.add;
          Close l_Get_Packlist_Csr;
          RAISE EXCP_USER_DEFINED;
       Else
          Close l_Get_Packlist_Csr;
       End If;

       l_packlist_headers_rec.date_received    := sysdate;
       l_packlist_headers_rec.last_update_date := sysdate;
       l_packlist_headers_rec.packlist_status  := l_packlist_header_status;

    -- Call the CSP_Packlist_Headers_PVT.Update_packlist_headers to update the packlist_status.
       CSP_Packlist_Headers_PVT.Update_packlist_headers(
            P_Api_Version_Number         => l_api_version_number,
            P_Init_Msg_List              => p_init_msg_list,
            P_Commit                     => FND_API.G_FALSE,
            p_validation_level           => l_validation_level,
            P_Identity_Salesforce_Id     => NULL,
            P_PLH_Rec                    => l_packlist_headers_rec,
            X_Return_Status              => l_return_status,
            X_Msg_Count                  => l_msg_count,
            X_Msg_Data                   => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

     If l_temp_id_to_be_processed IS NOT NULL THEN
     -- We are now ready to insert the data into interface table and delete the record in the temp table
        OPEN l_ml_records(l_temp_id_to_be_processed);
        FETCH l_ml_records INTO l_csp_mtltxn_rec;
        Close l_ml_records;
        -- Get the transaction header id
        Open l_Get_txn_header_id_csr;
        IF l_transaction_header_id IS NULL THEN
                Fetch l_Get_txn_header_id_csr Into l_transaction_header_id;
                Close l_Get_txn_header_id_csr;
        END IF;
       -- Call the csp_transactions_pub.transact_temp_record
          csp_transactions_pub.transact_temp_record (
                   P_Api_Version_Number      => l_api_version_number,
                   P_Init_Msg_List           => FND_API.G_true,
                   P_Commit                  => l_commit,
                   p_validation_level        => l_validation_level,
                   p_transaction_temp_id     => l_temp_id_to_be_processed,
                   px_transaction_header_id  => l_transaction_header_id,
                   p_online_process_flag     => FALSE,
                   X_Return_Status           => l_return_status,
                   X_Msg_Count               => l_msg_count,
                   X_Msg_Data                => l_msg_data );

             IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

          -- before calling the online process manager, we need to remove the temp record
           IF not fnd_api.to_boolean(Clean_Up (l_temp_id_to_be_processed)) THEN
                   RAISE EXCP_USER_DEFINED;
           END IF;
      End If;
<<END_JOB>>
    -- Call the process_online to submit a concurrent request.
    IF fnd_api.to_boolean(p_process_flag) THEN
            IF NOT Call_Online ( p_transaction_header_id   => l_transaction_header_id) THEN
               l_outcome := FALSE;
               x_return_status := FND_API.G_RET_STS_ERROR;
               GOTO END_ALL;
            END IF;
    END IF;

    px_transaction_header_id := l_transaction_header_id;

    IF fnd_api.to_boolean(p_commit) THEN
           commit work;
    END IF;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

 <<END_ALL>>
       fnd_msg_pub.count_and_get
        ( p_count => x_msg_count
        , p_data  => x_msg_data);
EXCEPTION
    WHEN EXCP_USER_DEFINED THEN
        Rollback to confirm_receipt_PUB;
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
        Rollback to confirm_receipt_PUB;
        fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
        fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
        fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
        fnd_msg_pub.add;
        fnd_msg_pub.count_and_get
        ( p_count => x_msg_count
        , p_data  => x_msg_data);
        x_return_status := fnd_api.g_ret_sts_error;
END confirm_receipt;

Function Clean_Up (p_transaction_temp_id IN NUMBER)
    Return VARCHAR2
IS
    l_api_version_number              CONSTANT NUMBER       := 1.0;
    l_api_name                        CONSTANT VARCHAR2(50) := 'Clean_Up';
    l_msg_count                       NUMBER                := 0;
    l_msg_data                        VARCHAR2(300);
    l_check_existence                 NUMBER                := 0;
    l_return_status                   VARCHAR2(1);
    l_mtlt_tbl                        csp_pp_util.g_mtlt_tbl_type;
    l_index                           NUMBER                := 1;
    l_temp_id_to_be_processed         NUMBER                := p_transaction_temp_id;
    l_csp_mtltxn_rec                  CSP_MATERIAL_TRANSACTIONS_PVT.CSP_Rec_Type;
    CURSOR l_ml_records IS
        SELECT
         TRANSACTION_HEADER_ID            ,
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
--       SOURCE_LOT_NUMBER
       FROM mtl_material_transactions_temp
        WHERE transaction_temp_id  = p_transaction_temp_id;
BEGIN
    OPEN l_ml_records;
    FETCH l_ml_records INTO l_csp_mtltxn_rec;
    IF l_ml_records%NOTFOUND THEN
        fnd_message.set_name ('CSP', 'CSP_NO_MO_TXN_RECORD');
        fnd_msg_pub.add;
        CLOSE l_ml_records;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE l_ml_records;
      -- case 1: if lot control , delete the record in mmtt table and mtlt table.
            If nvl(l_csp_mtltxn_rec.item_lot_control_code, 1) <> 1 And
               nvl(l_csp_mtltxn_rec.item_serial_control_code, 1) in (1, 6) Then

                      delete from mtl_transaction_lots_temp
                      where transaction_temp_id = l_temp_id_to_be_processed;

                      delete from mtl_material_transactions_temp
                      where transaction_temp_id = l_temp_id_to_be_processed;
      -- case 2: if lot control and serial control, delete the record in the mmtt table, the mtlt table and the msnt table
            Elsif nvl(l_csp_mtltxn_rec.item_lot_control_code, 1) <> 1 And
                  nvl(l_csp_mtltxn_rec.item_serial_control_code, 1) in (2, 5) Then
                      Declare
                           Cursor l_Get_Serial_Lot_id_Csr Is
                              select serial_transaction_temp_id from mtl_transaction_lots_temp
                              where transaction_temp_id = l_temp_id_to_be_processed;
                           l_serial_temp_id_del NUMBER;
                      Begin
                          Open l_Get_Serial_Lot_id_Csr;
                          Loop
                              Fetch l_Get_Serial_Lot_id_Csr Into l_Serial_Temp_Id_Del;
                              Exit When l_Get_Serial_Lot_id_Csr%NotFound;

                              delete from mtl_serial_numbers_temp
                              where transaction_temp_id = l_Serial_Temp_Id_Del;
                          End Loop;
                          If l_Get_Serial_Lot_id_Csr%ROWCOUNT = 0 Then
                              FND_MESSAGE.SET_NAME('CSP', 'CSP_RECEIPT_SERIAL_LOT_FAILURE');
                              FND_MSG_PUB.ADD;
                              Close l_Get_Serial_Lot_id_Csr;
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                          End If;

                          Close l_Get_Serial_Lot_id_Csr;
                      End;

                      delete from mtl_transaction_lots_temp
                      where transaction_temp_id = l_temp_id_to_be_processed;

                      delete from mtl_material_transactions_temp
                      where transaction_temp_id = l_temp_id_to_be_processed;
        -- case 3: if serial control, delete the record in the mmtt table and the msnt table
            Elsif nvl(l_csp_mtltxn_rec.item_lot_control_code, 1) = 1 And
                  nvl(l_csp_mtltxn_rec.item_serial_control_code, 1) in (2,5) Then

                      delete from mtl_serial_numbers_temp
                      where transaction_temp_id = l_temp_id_to_be_processed;

                      delete from mtl_material_transactions_temp
                      where transaction_temp_id = l_temp_id_to_be_processed;
            Else
        -- case 4: neither serial control nor lot control, delete the record in the mmtt table
                      delete from mtl_material_transactions_temp
                      where transaction_temp_id = l_temp_id_to_be_processed;
            End If;

         Return fnd_api.g_true;
EXCEPTION
    WHEN OTHERS THEN
            fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
            fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
            fnd_msg_pub.add;
            Return fnd_api.g_false;
END Clean_Up;

Function Call_Online (p_transaction_header_id NUMBER)
    Return Boolean
Is
    l_timeout                     NUMBER  := null;
    l_outcome                     BOOLEAN := TRUE;
    l_error_code                  VARCHAR2(200);
    l_error_explanation           VARCHAR2(240);
    Type l_Interface_Type IS Record (
         transaction_source_id NUMBER,
         trx_source_line_id    NUMBER,
         organization_id       NUMBER );
    l_Interface_Rec               l_Interface_Type;
    CURSOR l_Get_Interface_Csr IS
        SELECT transaction_source_id, trx_source_line_id, organization_id
        FROM   mtl_transactions_interface
        WHERE  transaction_header_id = p_transaction_header_id;
Begin
      -- Commit the changes before calling mtl_onlien_transaction_pub.process_online
      commit;

      OPEN l_Get_Interface_Csr;

      -- Note: Auto commit will be performed in the call of the mtl_online_transaction_pub.process_online.
      --       If the process_online failed, there was no way to rollback what was previously transacted.
      l_outcome := mtl_online_transaction_pub.process_online
         ( p_transaction_header_id  => p_transaction_header_id
         , p_timeout                => l_timeout
         , p_error_code             => l_error_code
         , p_error_explanation      => l_error_explanation
         );

      If (l_outcome = FALSE) Then
            FND_MESSAGE.SET_NAME('CSP', 'CSP_TRANSACT_ERRORS');
            --FND_MESSAGE.SET_TOKEN('ERROR_CODE', l_error_code, FALSE);
           -- FND_MESSAGE.SET_TOKEN('ERROR_EXPLANATION', l_error_explanation, FALSE);
            FND_MESSAGE.SET_TOKEN('TRANSACTION_HEADER_ID', to_char(p_transaction_header_id), FALSE);
            FND_MSG_PUB.ADD;
            CLOSE l_Get_Interface_Csr;
            Return l_outcome;
      Else
           Begin
               LOOP
                    FETCH l_Get_Interface_Csr INTO l_Interface_Rec;
                    EXIT WHEN l_Get_Interface_Csr%NOTFOUND;
                     -- Update the move_order_line_id in the mtl_material_transactions so that the transaction record
                     -- has track-back history to the move order.
                     -- We need to do this post transaction update because there is no such column move_order_line_id in the
                     -- mtl_transactions_interface table.
                     update mtl_material_transactions
                     set move_order_line_id = l_Interface_Rec.trx_source_line_id
                     where transaction_source_id = l_Interface_Rec.transaction_source_id
                     and  trx_source_line_id = l_Interface_Rec.trx_source_line_id
                     and organization_id = l_Interface_Rec.organization_id;
                END LOOP;
                IF l_Get_Interface_Csr%ISOPEN THEN
                      CLOSE l_Get_Interface_Csr;
                END IF;
            End;  -- If there is an error, it must be SQL%NOTFOUND. This will be caught by the OTHERS exception of the main block.
      End If;
    Return true;
EXCEPTION
       WHEN OTHERS THEN
           IF l_Get_Interface_Csr%ISOPEN THEN
                   CLOSE l_Get_Interface_Csr;
           END IF;
           Return false;
End Call_Online;

Procedure Under_Over_Receipt (
-- Start of Comments
-- Procedure name   : Under_Over_Receipt
-- Purpose          : This procedure handles the under or over receipt.
-- Login            : In the case of under receipt, this procedure updates the transfer_subinventory and
--                    transfer_to_location of the temp record to NULL, and the transaction_action_type to misc. issue.
--                    It then moves the data from the temp table to the interface table. It returns the transaction_header_id.
--                    In the case of over receipt, this procedure updates the subinventory_code and locator_id
--                    to NULL, and the transaction_action_type to misc. receipt. It then moves the data from the
--                    temp table to the interface table. It returns the transaction_header_id.
--                    This procedure also cleans the record in the temp table.
--                    This procedure sets the px_transaction_header_id to NULL when it fails.
--
-- History          :
--  Person       Date               Descriptions
--  ------       ----              --------------
--  klou         13-Apr-2000         created.
-- End of Comments

         p_transaction_temp_id     IN     NUMBER,
         p_receiving_option        IN     NUMBER,
         px_transaction_header_id  IN OUT NOCOPY NUMBER,
         p_discrepancy_qty         IN     NUMBER := 0,
         X_Return_Status           OUT NOCOPY    VARCHAR2,
         X_Msg_Count               OUT NOCOPY    NUMBER,
         X_Msg_Data                OUT NOCOPY    VARCHAR2)

IS
    l_api_version_number                 CONSTANT NUMBER       := 1.0;
    l_api_name                           CONSTANT VARCHAR2(50) := 'Under_Over_Receipt';
    l_msg_data                           VARCHAR2(300);
    l_commit                             VARCHAR2(1)           := fnd_api.g_false;
    l_check_existence                    NUMBER                := 0;
    l_return_status                      VARCHAR2(1);
    l_msg_count                          NUMBER                := 0;
    l_mtlt_tbl                           csp_pp_util.g_mtlt_tbl_type;
    l_index                              NUMBER                := 1;
    l_transaction_header_id              NUMBER                := NULL;
    l_account_id                         NUMBER                := NULL;
    l_validation_level                   NUMBER                := FND_API.G_VALID_LEVEL_NONE;
    --l_trolin_rec                         INV_Move_Order_PUB.Trolin_Rec_Type;
    l_csp_mtltxn_rec                     CSP_MATERIAL_TRANSACTIONS_PVT.CSP_Rec_Type;
    EXCP_USER_DEFINED EXCEPTION;
    Cursor l_Get_txn_header_id_csr IS
        SELECT mtl_material_transactions_s.nextval
        FROM   dual;

    CURSOR l_ml_records IS
        SELECT
          TRANSACTION_HEADER_ID            ,
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
      -- PROCESS_TYPE                     ,  --removed 01/13/00. process_type does not exist in the mmtt table.
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
      WHERE transaction_temp_id  = p_transaction_temp_id;

    CURSOR l_Get_Mtlt IS
        SELECT * FROM mtl_transaction_lots_temp
        WHERE transaction_temp_id = p_transaction_temp_id
        ORDER BY TRANSACTION_QUANTITY DESC;
BEGIN
    IF p_receiving_option NOT IN (1, 2, 3) THEN
        fnd_message.set_name('CSP', 'CSP_INVALID_OVER_RECEIPT_QTY');
        fnd_msg_pub.add;
        RAISE EXCP_USER_DEFINED;
    END IF;

    OPEN l_ml_records;
    FETCH l_ml_records INTO l_csp_mtltxn_rec;
    IF l_ml_records%NOTFOUND THEN
      fnd_message.set_name ('CSP', 'CSP_NO_MO_TXN_RECORD');
      fnd_msg_pub.add;
      CLOSE l_ml_records;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE l_ml_records;

    l_csp_mtltxn_rec.distribution_account_id := Get_CSP_Acccount_ID (l_csp_mtltxn_rec.organization_id);

    IF l_csp_mtltxn_rec.distribution_account_id IS NULL THEN
        fnd_message.set_name('CSP', 'CSP_RECEIPT_ACCOUNT_NOT_FOUND');
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_receiving_option = 1 THEN -- receiving short
        l_csp_mtltxn_rec.transfer_subinventory := NULL;
        l_csp_mtltxn_rec.transfer_to_location  := NULL;
        l_csp_mtltxn_rec.transaction_type_id   := 32; -- misc. issue
        l_csp_mtltxn_rec.transaction_action_id := 1;  -- issue from stores
        l_csp_mtltxn_rec.transaction_source_type_id := 13; -- inventory
    ELSE -- must be over receiving
       /* l_csp_mtltxn_rec.subinventory_code     := NULL;   --
        l_csp_mtltxn_rec.locator_id            := NULL; */
        l_csp_mtltxn_rec.transfer_subinventory := NULL;
        l_csp_mtltxn_rec.transfer_to_location  := NULL;
        l_csp_mtltxn_rec.transaction_type_id   := 42;  -- misc. receipt
        l_csp_mtltxn_rec.transaction_action_id := 27;  -- receipt into stores
        l_csp_mtltxn_rec.transaction_source_type_id := 13; -- inventory
    END IF;
/* 06/08/2000 klou: do not need to update the quantity delivered because this will mess up the move in quantity
   in the move order status form.
    -- Update the quantity_delivered to reflect the over-received quantity.
        l_trolin_rec := INV_Trolin_util.Query_Row(l_csp_mtltxn_rec.move_order_line_id );
        l_trolin_rec.quantity_delivered := nvl(l_trolin_rec.quantity_delivered,0) + p_discrepancy_qty;
        l_trolin_rec.last_update_date := SYSDATE;
        l_trolin_rec.last_updated_by := FND_GLOBAL.USER_ID;
        l_trolin_rec.last_update_login := FND_GLOBAL.LOGIN_ID;
        INV_Trolin_Util.Update_Row(l_trolin_rec);
*/

    CSP_Material_Transactions_PVT.Update_material_transactions(
          P_Api_Version_Number        => l_api_version_number,
          P_Init_Msg_List             => FND_API.G_TRUE,
          P_Commit                    => FND_API.G_FALSE,
          p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
          P_CSP_Rec                   => l_csp_mtltxn_rec,
          X_Return_Status             => l_return_status ,
          X_Msg_Count                 => l_msg_count,
          X_Msg_Data                  => l_msg_data);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- get the transaction header id
   Open l_Get_txn_header_id_csr;
   Fetch l_Get_txn_header_id_csr Into l_transaction_header_id;
   Close l_Get_txn_header_id_csr;

  -- Call the csp_transactions_pub.transact_temp_record
      csp_transactions_pub.transact_temp_record (
           P_Api_Version_Number      => l_api_version_number,
           P_Init_Msg_List           => FND_API.G_true,
           P_Commit                  => l_commit,
           p_validation_level        => l_validation_level,
           p_transaction_temp_id     => p_transaction_temp_id,
           px_transaction_header_id  => l_transaction_header_id,
           p_online_process_flag     => FALSE,
           X_Return_Status           => l_return_status,
           X_Msg_Count               => l_msg_count,
           X_Msg_Data                => l_msg_data );

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

        If NOT fnd_api.to_boolean(clean_up(p_transaction_temp_id)) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
   px_transaction_header_id := l_transaction_header_id;
EXCEPTION
    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         px_transaction_header_id := NULL;
END Under_Over_Receipt;


Function Get_CSP_Acccount_ID (p_organization_id NUMBER)
    Return NUMBER
Is
    l_account_id NUMBER;
    Cursor l_Get_Account_Id_Csr IS
        Select distribution_account
        From mtl_generic_dispositions
        Where upper(segment1) = 'CSP_RECEIPT'
        And organization_id = p_organization_id
        And trunc(nvl(effective_date, sysdate-1)) <= trunc(sysdate)
        And trunc(nvl(disable_date, sysdate+1)) >= trunc(sysdate);
Begin
    Open l_Get_Account_Id_Csr;
    Fetch l_Get_Account_Id_Csr Into l_account_id;
    Close l_Get_Account_Id_Csr;
    Return l_account_id;
End Get_CSP_Acccount_ID;


Procedure Transact_Serial_Lots (
-- This procedure was created specifically for use in the CSP confirm receipt transactions.
       p_new_transaction_temp_id IN      NUMBER,
       p_old_transaction_temp_id IN      NUMBER,
       p_lot_number              IN      VARCHAR2,
       p_serial_number           IN      VARCHAR2,
       p_qty_received            IN      NUMBER,
       X_Return_Status           OUT NOCOPY     VARCHAR2,
       X_Msg_Count               OUT NOCOPY     NUMBER,
       X_Msg_Data                OUT NOCOPY     VARCHAR2)
IS
    l_mtlt_tbl csp_pp_util.g_mtlt_tbl_type;
    l_msnt_tbl csp_pp_util.g_msnt_tbl_type;

    -- use 1 as the starting index because it is what the core apps API uses.
    -- we are not going to update this index becase there is only one record in the
    -- msnt that is coresponding to the l_packlist_sl_rec.serial_number.
    l_index                NUMBER := 1;
    l_api_name             VARCHAR2(30) := 'Transact_Serial_Lots';
    l_return_status        VARCHAR2(1);
    l_msg_data             VARCHAR2(300);
    l_msg_count            NUMBER;
    l_prefix               VARCHAR2(30);
    l_num                  VARCHAR2(30);
    l_temp_fm_prefix       VARCHAR2(30);
    l_temp_fm_num          VARCHAR2(30);
    l_temp_to_prefix       VARCHAR2(30);
    l_temp_to_num          VARCHAR2(30);
    l_number_length        NUMBER;   -- the length of the number section of the serial numbers
    l_new_fm_num           NUMBER;
    l_new_to_num           NUMBER;
    l_done_flag            VARCHAR2(1) := fnd_api.g_true;
    l_serial_case          NUMBER := NULL; -- 0 = requires to create a new mtlt record.
    l_quantity_remained    NUMBER := p_qty_received;
    l_old_serial_temp_id   NUMBER;
    l_new_serial_temp_id   NUMBER;
    EXCP_USER_DEFINED      EXCEPTION;

    CURSOR l_Get_Mtlt IS
      SELECT * FROM mtl_transaction_lots_temp
      WHERE transaction_temp_id = p_old_transaction_temp_id
      AND lot_number = p_lot_number
      ORDER BY TRANSACTION_QUANTITY DESC;
    CURSOR l_Get_Serial_Temp_id_Csr IS SELECT MTL_MATERIAL_TRANSACTIONS_S.nextval FROM dual;

  --- Subfunction transact_serial
    Procedure transact_serial(
     -- p_new_transaction_temp_id IN      NUMBER,
     -- p_old_transaction_temp_id IN      NUMBER,
       p_temp_id_ref             IN      NUMBER,
       p_new_temp_id             IN      NUMBER
        )  --return boolean
     is
        CURSOR l_Get_Msnt(l_transaction_temp_id NUMBER) IS
            SELECT * FROM mtl_serial_numbers_temp
            WHERE transaction_temp_id = l_transaction_temp_id; --p_old_transaction_temp_id;
        l_new_temp_id NUMBER := p_new_temp_id;
     begin

         OPEN l_Get_Msnt(p_temp_id_ref);
              LOOP
                  FETCH l_Get_Msnt INTO l_msnt_tbl(l_index);
                  EXIT WHEN l_Get_Msnt%NOTFOUND;

               --   l_serial_transaction_temp_id := l_msnt_tbl(l_index).transaction_temp_id; -- removed on 03/30/00

                -- analyze the serial number range
                csp_pp_util.split_prefix_num (
                       p_serial_number        => p_serial_number
                      ,p_prefix               => l_prefix
                      ,x_num                  => l_num
                   );
                csp_pp_util.split_prefix_num (
                       p_serial_number        => l_msnt_tbl(l_index).fm_serial_number
                      ,p_prefix               => l_temp_fm_prefix
                      ,x_num                  => l_temp_fm_num
                     );
                csp_pp_util.split_prefix_num (
                       p_serial_number        => l_msnt_tbl(l_index).to_serial_number
                      ,p_prefix               => l_temp_to_prefix
                      ,x_num                  => l_temp_to_num
                     );

                l_number_length := length(l_num);

                IF l_prefix = l_temp_fm_prefix AND l_num IS NOT NULL
                  AND l_temp_fm_num IS NOT NULL AND l_temp_to_num IS NOT NULL THEN

                        IF to_number(l_num) > to_number(l_temp_fm_num)
                            AND to_number(l_num) < to_number(l_temp_to_num) THEN
                              -- Example case:
                              --      fm_serial_number = serial00, to_serial_number = serial09
                              --      p_serial_number  = serial04.
                              -- Split the serial number range into 3 records.
                              -- The first one for the l_temp_fm_num to the l_new_to_num.
                              -- The second one for the l_new_to_num to the l_temp_to_num.
                              -- The last one for the l_packlist_sl_rec.serial_number to be transacted as
                              -- the new transaction_temp_id.
                              -- In any cases, we can recycle the l_msnt_tbl table.

                              -- First msnt record: just need to update the existing record.
                              l_new_to_num := to_number(l_num) - 1; --- to_number(l_temp_fm_num);
                              update mtl_serial_numbers_temp
                              set to_serial_number = l_prefix||lpad(to_char(l_new_to_num),l_number_length, '0'),
                                  last_update_date = sysdate,
                                  serial_prefix = l_new_to_num - to_number(l_temp_fm_num) + 1
                              where transaction_temp_id = l_msnt_tbl(l_index).transaction_temp_id
                              and fm_serial_number = l_msnt_tbl(l_index).fm_serial_number
                              and to_serial_number = l_msnt_tbl(l_index).to_serial_number;

                              If (SQL%NOTFOUND) then
                                fnd_message.set_name ('CSP', 'CSP_EXEC_FAILED_IN_TBL');
                                fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                                fnd_message.set_token ('TABLE', 'Mtl_Serial_Numbers_Temp', FALSE);
                                fnd_msg_pub.add;
                                CLOSE l_Get_Msnt;
                                RAISE EXCP_USER_DEFINED;
                              End If;

                              -- Second msnt record: create a new record with new serial number range.
                              l_new_fm_num := to_number(l_num) + 1;
                              l_msnt_tbl(l_index).fm_serial_number
                                := l_prefix||lpad(to_char(l_new_fm_num),l_number_length, '0');
                              l_msnt_tbl(l_index).serial_prefix := to_number(l_temp_to_num) - l_new_fm_num + 1;
                              l_msnt_tbl(l_index).creation_date := sysdate;
                              l_msnt_tbl(l_index).last_update_date := sysdate;

                              -- create a new msnt record based on the above information.
                              csp_pp_util.insert_msnt(
                                  x_return_status  => l_return_status
                                 ,p_msnt_tbl       => l_msnt_tbl
                                 ,p_msnt_tbl_size  => 1
                                 );

                             IF l_return_status <> fnd_api.g_ret_sts_success THEN
                                  fnd_message.set_name ('CSP', 'CSP_EXEC_FAILED_IN_TBL');
                                  fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                                  fnd_message.set_token ('TABLE', 'Mtl_Serial_Numbers_Temp', FALSE);
                                  fnd_msg_pub.add;
                                  CLOSE l_Get_Msnt;
                                  RAISE EXCP_USER_DEFINED;
                             END IF;

                             -- Last record: create a new msnt record having the l_new_transation_temp_id
                             l_msnt_tbl(l_index).transaction_temp_id := l_new_temp_id;
                             l_msnt_tbl(l_index).fm_serial_number := p_serial_number;
                             l_msnt_tbl(l_index).to_serial_number := p_serial_number;
                             l_msnt_tbl(l_index).serial_prefix := 1;
                             l_msnt_tbl(l_index).creation_date := sysdate;
                             l_msnt_tbl(l_index).last_update_date := sysdate;

                              csp_pp_util.insert_msnt(
                                x_return_status  => l_return_status
                               ,p_msnt_tbl       => l_msnt_tbl
                               ,p_msnt_tbl_size  => 1
                               );

                             IF l_return_status <> fnd_api.g_ret_sts_success THEN
                                  fnd_message.set_name ('CSP', 'CSP_EXEC_FAILED_IN_TBL');
                                  fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                                  fnd_message.set_token ('TABLE', 'Mtl_Serial_Numbers_Temp', FALSE);
                                  fnd_msg_pub.add;
                                  CLOSE l_Get_Msnt;
                                  RAISE EXCP_USER_DEFINED;
                             END IF;

                            l_done_flag := fnd_api.g_true;
                            l_serial_case := 0;
                            exit;

                      ELSIF l_temp_fm_num = l_num AND to_number(l_num) < to_number(l_temp_to_num) THEN
                         -- Example case:
                         --      fm_serial_number = serial00, to_serial_number = serial09
                         --      p_serial_number  = serial00.
                         -- split the existing msnt record into 2 records.
                         -- The first record: update the frm_serial_number of the exsiting record to the l_new_fm_num.
                         -- The second record: create a new msnt record having the l_new_transation_temp_id and the p_serial_number.

                         -- First record: update the existing record such that the fm_serial_number = p_serial_number + 1.
                          l_new_fm_num := to_number(l_num) + 1;
                          update mtl_serial_numbers_temp
                          set fm_serial_number = l_prefix||lpad(to_char(l_new_fm_num),l_number_length, '0'),
                              last_update_date = sysdate,
                              serial_prefix = to_number(l_temp_to_num) - l_new_fm_num +1
                          where transaction_temp_id = l_msnt_tbl(l_index).transaction_temp_id
                          and fm_serial_number = l_msnt_tbl(l_index).fm_serial_number
                          and to_serial_number = l_msnt_tbl(l_index).to_serial_number;

                          If (SQL%NOTFOUND) then
                                fnd_message.set_name ('CSP', 'CSP_EXEC_FAILED_IN_TBL');
                                fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                                fnd_message.set_token ('TABLE', 'Mtl_Serial_Numbers_Temp', FALSE);
                                fnd_msg_pub.add;
                                CLOSE l_Get_Msnt;
                                RAISE EXCP_USER_DEFINED;
                          End If;

                       -- Second record:
                             l_msnt_tbl(l_index).transaction_temp_id := l_new_temp_id;
                             l_msnt_tbl(l_index).fm_serial_number := p_serial_number;
                             l_msnt_tbl(l_index).to_serial_number := p_serial_number;
                             l_msnt_tbl(l_index).serial_prefix := 1;
                             l_msnt_tbl(l_index).creation_date := sysdate;
                             l_msnt_tbl(l_index).last_update_date := sysdate;

                              csp_pp_util.insert_msnt(
                                x_return_status  => l_return_status
                               ,p_msnt_tbl       => l_msnt_tbl
                               ,p_msnt_tbl_size  => 1
                               );

                          IF l_return_status <> fnd_api.g_ret_sts_success THEN
                              fnd_message.set_name ('CSP', 'CSP_EXEC_FAILED_IN_TBL');
                              fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                              fnd_message.set_token ('TABLE', 'Mtl_Serial_Numbers_Temp', FALSE);
                              fnd_msg_pub.add;
                              CLOSE l_Get_Msnt;
                              RAISE EXCP_USER_DEFINED;
                          END IF;

                          l_done_flag := fnd_api.g_true;
                          l_serial_case := 0;
                          exit;

                      ELSIF l_temp_to_num = l_num AND to_number(l_temp_fm_num) < to_number(l_num) THEN
                         -- Example case:
                         --      fm_serial_number = serial00, to_serial_number = serial09
                         --      p_serial_number  = serial09.
                         -- split the existing msnt record into 2 records.
                         -- The first record: update the to_serial_number of the existing record to the l_new_to_num.
                         -- The second record: create a new msnt record having the l_new_transation_temp_id and the p_serial_number.

                         -- First record
                          l_new_to_num := to_number(l_num) - 1;
                          update mtl_serial_numbers_temp
                          set to_serial_number = l_prefix||lpad(to_char(l_new_to_num),l_number_length, '0'),
                              last_update_date = sysdate,
                              serial_prefix = l_new_to_num - to_number(l_temp_fm_num) + 1
                          where transaction_temp_id = l_msnt_tbl(l_index).transaction_temp_id
                          and fm_serial_number = l_msnt_tbl(l_index).fm_serial_number
                          and to_serial_number = l_msnt_tbl(l_index).to_serial_number;

                          If (SQL%NOTFOUND) then
                                fnd_message.set_name ('CSP', 'CSP_EXEC_FAILED_IN_TBL');
                                fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                                fnd_message.set_token ('TABLE', 'Mtl_Serial_Numbers_Temp', FALSE);
                                fnd_msg_pub.add;
                                CLOSE l_Get_Msnt;
                                RAISE EXCP_USER_DEFINED;
                          End If;

                         -- Second record:
                             l_msnt_tbl(l_index).transaction_temp_id := l_new_temp_id;
                             l_msnt_tbl(l_index).fm_serial_number := p_serial_number;
                             l_msnt_tbl(l_index).to_serial_number := p_serial_number;
                             l_msnt_tbl(l_index).serial_prefix := 1;
                             l_msnt_tbl(l_index).creation_date := sysdate;
                             l_msnt_tbl(l_index).last_update_date := sysdate;

                              csp_pp_util.insert_msnt(
                                x_return_status  => l_return_status
                               ,p_msnt_tbl       => l_msnt_tbl
                               ,p_msnt_tbl_size  => 1
                               );

                          IF l_return_status <> fnd_api.g_ret_sts_success THEN
                              fnd_message.set_name ('CSP', 'CSP_EXEC_FAILED_IN_TBL');
                              fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                              fnd_message.set_token ('TABLE', 'Mtl_Serial_Numbers_Temp', FALSE);
                              fnd_msg_pub.add;
                              CLOSE l_Get_Msnt;
                              RAISE EXCP_USER_DEFINED;
                          END IF;

                          l_done_flag := fnd_api.g_true;
                          l_serial_case := 0;
                          exit;

                 ELSIF l_num = l_temp_to_num AND l_num = l_temp_fm_num THEN
                       -- Example case:
                       --      fm_serial_number = serial00, to_serial_number = serial00
                       --      p_serial_number  = serial00.
                       -- This is a case which fm_serial_number = to_serial_number.
                       -- In this case, we just need to update the transaction_temp_id to the l_new_temp_id.
                          l_done_flag := fnd_api.g_true;
                          l_serial_case := 1;

                          update mtl_serial_numbers_temp
                          set transaction_temp_id = l_new_temp_id
                          where transaction_temp_id = l_msnt_tbl(l_index).transaction_temp_id
                          and fm_serial_number = l_msnt_tbl(l_index).fm_serial_number
                          and to_serial_number = l_msnt_tbl(l_index).to_serial_number;

                          If (SQL%NOTFOUND) then
                                fnd_message.set_name ('CSP', 'CSP_EXEC_FAILED_IN_TBL');
                                fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                                fnd_message.set_token ('TABLE', 'Mtl_Serial_Numbers_Temp', FALSE);
                                fnd_msg_pub.add;
                                CLOSE l_Get_Msnt;
                                RAISE EXCP_USER_DEFINED;
                          End If;

                          exit;
                    ELSE
                       -- Example case:
                       --      fm_serial_number = serial00, to_serial_number = serial09
                       --      p_serial_number  = serial11.  Not in the record being examined, can be in next one.
                       -- start another loop
                          l_serial_case := null;
                          l_done_flag := fnd_api.g_false;
                    END IF;

              ELSIF l_prefix = l_temp_fm_prefix AND l_num IS NULL
                  AND l_temp_to_num IS NULL AND l_temp_fm_num IS NULL THEN
                  -- Example case:
                  --      fm_serial_number = serial, to_serial_number = serial
                  --      p_serial_number  = serial.
                  -- There is no serial number range in this case.
                  -- This is a case which fm_serial_number = to_serial_number.
                  -- In this case, we just need to update the transaction_temp_id to the l_new_temp_id.
                     l_done_flag := fnd_api.g_true;
                     l_serial_case := 1;
                     update mtl_serial_numbers_temp
                     set transaction_temp_id = l_new_temp_id
                     where transaction_temp_id = l_msnt_tbl(l_index).transaction_temp_id
                     and fm_serial_number = l_msnt_tbl(l_index).fm_serial_number
                     and to_serial_number = l_msnt_tbl(l_index).to_serial_number;

                     If (SQL%NOTFOUND) then
                          fnd_message.set_name ('CSP', 'CSP_EXEC_FAILED_IN_TBL');
                          fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                          fnd_message.set_token ('TABLE', 'Mtl_Serial_Numbers_Temp', FALSE);
                          fnd_msg_pub.add;
                          CLOSE l_Get_Msnt;
                          RAISE EXCP_USER_DEFINED;
                     End If;
                     exit;
              ELSE
                  -- start another loop
                     l_serial_case := null;
                     l_done_flag := fnd_api.g_false;
              END IF;
            END LOOP;

            IF (l_Get_Msnt%rowcount = 0 AND p_serial_number IS NOT NULL) OR
               (l_Get_Msnt%rowcount <> 0 AND NOT fnd_api.to_boolean(l_done_flag)) THEN
                  fnd_message.set_name ('CSP', 'CSP_NO_SERIAL_TXN_RECORD');
                  fnd_msg_pub.add;
                  IF l_Get_Msnt%ISOPEN THEN
                      CLOSE l_Get_Msnt;
                  END IF;
                  RAISE EXCP_USER_DEFINED;
            END IF;

            IF l_Get_Msnt%ISOPEN THEN
                  CLOSE l_Get_Msnt;
            END IF;
      End transact_serial;
  ---- End transact_serial sub_function

BEGIN
  SAVEPOINT Transact_Serial_Lots_PUB;

  -- case 1: serial_control = true, lot_control = false
  IF p_serial_number IS NOT NULL
     AND p_lot_number IS NULL THEN
        transact_serial(
           p_temp_id_ref => p_old_transaction_temp_id,
           p_new_temp_id => p_new_transaction_temp_id);

  -- case 2: serial_control = true, lot_control = true
  ELSIF p_lot_number IS NOT NULL
        AND p_serial_number IS NOT NULL THEN
            DECLARE
                Cursor l_Get_Mtlt_Lot_No IS
                    SELECT * FROM mtl_transaction_lots_temp
                    WHERE transaction_temp_id = p_old_transaction_temp_id
                    AND lot_number = p_lot_number;
            BEGIN

                OPEN l_Get_Mtlt_Lot_No;
                -- This loop only loops once if everything is correct. Otherwise, exceptions should be thrown.
                    FETCH l_Get_Mtlt_Lot_No INTO l_mtlt_tbl(l_index);
                    IF l_Get_Mtlt_Lot_No%rowcount = 0 THEN
                         fnd_message.set_name ('CSP', 'CSP_NO_LOT_TXN_RECORD');
                         fnd_msg_pub.add;
                         CLOSE l_Get_Mtlt_Lot_No;
                         RAISE EXCP_USER_DEFINED;
                    END IF;

                    IF l_Get_Mtlt%ISOPEN THEN
                        CLOSE l_Get_Mtlt_Lot_No;
                    END IF;

                     -- For items also under serial control, we transact one serial number at a time.
                     -- l_quantity_remained was initialized to p_quantity_received.
                       l_quantity_remained := l_mtlt_tbl(l_index).transaction_quantity - l_quantity_remained;

                       IF l_quantity_remained > 0 THEN
                          -- update the existing transaction_quantity to l_quantity_remained.
                          -- create a new record.
                          update mtl_transaction_lots_temp
                          set transaction_quantity = l_quantity_remained,
                              primary_quantity = l_quantity_remained
                          where transaction_temp_id = l_mtlt_tbl(l_index).transaction_temp_id
                          and serial_transaction_temp_id = l_mtlt_tbl(l_index).serial_transaction_temp_id
                          and lot_number = l_mtlt_tbl(l_index).lot_number;

                          If (SQL%NOTFOUND) then
                            fnd_message.set_name ('CSP', 'CSP_EXEC_FAILED_IN_TBL');
                            fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                            fnd_message.set_token ('TABLE', 'Mtl_Transaction_Lots_Temp', FALSE);
                            fnd_msg_pub.add;
                            CLOSE l_Get_Mtlt;
                            RAISE EXCP_USER_DEFINED;
                          End If;

                          l_old_serial_temp_id := l_mtlt_tbl(l_index).serial_transaction_temp_id;

                          Open l_Get_Serial_Temp_id_Csr;
                          Fetch l_Get_Serial_Temp_id_Csr Into l_new_serial_temp_id;
                          Close l_Get_Serial_Temp_id_Csr;

                          -- create a new record
                          l_mtlt_tbl(l_index).transaction_quantity := p_qty_received;
                          l_mtlt_tbl(l_index).primary_quantity := p_qty_received;
                          l_mtlt_tbl(l_index).transaction_temp_id := p_new_transaction_temp_id;
                          l_mtlt_tbl(l_index).serial_transaction_temp_id := l_new_serial_temp_id;

                          csp_pp_util.insert_mtlt(
                            x_return_status  => l_return_status
                            ,p_mtlt_tbl       => l_mtlt_tbl
                            ,p_mtlt_tbl_size  => 1
                           );

                          IF l_return_status <> fnd_api.g_ret_sts_success THEN
                                fnd_message.set_name ('CSP', 'CSP_EXEC_FAILED_IN_TBL');
                                fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                                fnd_message.set_token ('TABLE', 'Mtl_Transaction_Lots_Temp', FALSE);
                                fnd_msg_pub.add;
                                CLOSE l_Get_Mtlt;
                                RAISE EXCP_USER_DEFINED;
                          ELSE
                                -- transact the serial number
                                transact_serial(p_temp_id_ref => l_old_serial_temp_id,
                                                p_new_temp_id => l_new_serial_temp_id);
                          END IF;

                      ELSIF l_quantity_remained < 0 THEN
                        -- For serial controlled items that are also under lot-control, this case should not
                        -- happen because confirm receipt is transacting one serial number at time.
                            fnd_message.set_name ('CSP', 'CSP_INVALID_SERIAL_QTY');
                            fnd_msg_pub.add;
                            --l_msg_data := 'Unexpected errors.';
                            CLOSE l_Get_Mtlt;
                            RAISE EXCP_USER_DEFINED;

                      ELSE
                        -- l_quantity_remained = 0, this case should not happen either.
                        -- The p_quantity_received must be 1 when the item is under serial control.
                        -- If the serial number in the msnt is the last one to be transacted
                        -- i.e. when fm_serial_number = to_serial_number, the l_serial_case should be 1.
                            fnd_message.set_name ('CSP', 'CSP_INVALID_SERIAL_QTY');
                            fnd_msg_pub.add;
                            CLOSE l_Get_Mtlt;
                            RAISE EXCP_USER_DEFINED;

                      END IF;
                END; -- end block
-- case 3: serial_control = false, lot_control = true
  ELSIF p_lot_number IS NOT NULL
        AND p_serial_number IS NULL THEN

        DECLARE
           l_qty_received NUMBER := p_qty_received;
        BEGIN
            OPEN l_Get_Mtlt;
            LOOP
                FETCH l_Get_Mtlt INTO l_mtlt_tbl(l_index);
                EXIT WHEN l_Get_Mtlt%NOTFOUND;
                l_quantity_remained := l_mtlt_tbl(l_index).transaction_quantity - l_qty_received;
                   IF l_quantity_remained > 0 THEN
                          -- update the existing transaction_quantity to l_quantity_remained.
                          -- create a new record.
                          update mtl_transaction_lots_temp
                          set transaction_quantity = l_quantity_remained,
                              primary_quantity = l_quantity_remained
                          where transaction_temp_id = l_mtlt_tbl(l_index).transaction_temp_id
                          and lot_number = l_mtlt_tbl(l_index).lot_number;

                          If (SQL%NOTFOUND) then
                            fnd_message.set_name ('CSP', 'CSP_EXEC_FAILED_IN_TBL');
                            fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                            fnd_message.set_token ('TABLE', 'Mtl_Transaction_Lots_Temp', FALSE);
                            fnd_msg_pub.add;
                            CLOSE l_Get_Mtlt;
                            RAISE EXCP_USER_DEFINED;
                          End If;

                          -- create a new record
                          l_mtlt_tbl(l_index).transaction_quantity := l_qty_received;
                          l_mtlt_tbl(l_index).primary_quantity := l_qty_received;
                          l_mtlt_tbl(l_index).transaction_temp_id := p_new_transaction_temp_id;

                          csp_pp_util.insert_mtlt(
                            x_return_status  => l_return_status
                            ,p_mtlt_tbl       => l_mtlt_tbl
                            ,p_mtlt_tbl_size  => 1
                            );

                          IF l_return_status <> fnd_api.g_ret_sts_success THEN
                            fnd_message.set_name ('CSP', 'CSP_EXEC_FAILED_IN_TBL');
                            fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                            fnd_message.set_token ('TABLE', 'Mtl_Transaction_Lots_Temp', FALSE);
                            fnd_msg_pub.add;
                            CLOSE l_Get_Mtlt;
                            RAISE EXCP_USER_DEFINED;
                          END IF;
                        exit;  -- exit the loop because the quantity_received is less than the transaction_quantity

                    ELSIF l_quantity_remained < 0 THEN
                       -- get ready for the next loop.
                       -- l_quantity_remained := abs(l_quantity_remained);
                          l_qty_received := abs(l_quantity_remained);
                    ELSE  -- l_quantity_remained = 0  because the quantity_received = transaction_quantity
                    -- update the existing record to the p_new_transaction_temp_id
                          update mtl_transaction_lots_temp
                          set transaction_temp_id = p_new_transaction_temp_id
                          where transaction_temp_id = l_mtlt_tbl(l_index).transaction_temp_id
                          and lot_number = l_mtlt_tbl(l_index).lot_number;
                          If (SQL%NOTFOUND) then
                            fnd_message.set_name ('CSP', 'CSP_EXEC_FAILED_IN_TBL');
                            fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                            fnd_message.set_token ('TABLE', 'Mtl_Transaction_Lots_Temp', FALSE);
                            fnd_msg_pub.add;
                            CLOSE l_Get_Mtlt;
                            RAISE EXCP_USER_DEFINED;
                          End If;
                    END IF;
           END LOOP;

           IF l_Get_Mtlt%rowcount = 0 THEN
                fnd_message.set_name ('CSP', 'CSP_NO_LOT_TXN_RECORD');
                fnd_msg_pub.add;
           --l_msg_data := 'Could not find any records in the mtl_transaction_lots_temp table.';
                CLOSE l_Get_Mtlt;
                RAISE EXCP_USER_DEFINED;
           END IF;

           IF l_Get_Mtlt%ISOPEN THEN
              CLOSE l_Get_Mtlt;
           END IF;
       END;
  Else
     NULL;
  End if;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
   fnd_msg_pub.count_and_get
        ( p_count => x_msg_count
        , p_data  => x_msg_data);
EXCEPTION
     WHEN EXCP_USER_DEFINED THEN
        Rollback to Transact_Serial_Lots_PUB;
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
            Rollback to Transact_Serial_Lots_PUB;
            fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
            fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
            fnd_msg_pub.add;
            fnd_msg_pub.count_and_get
            ( p_count => x_msg_count
            , p_data  => x_msg_data);
            x_return_status := fnd_api.g_ret_sts_error;
END Transact_Serial_Lots;

FUNCTION Convert_Temp_UOM (p_csp_mtltxn_rec IN OUT NOCOPY CSP_MATERIAL_TRANSACTIONS_PVT.CSP_Rec_Type,
                           p_quantity_convert IN NUMBER)
    RETURN VARCHAR2
    -- This function calculates the primary quantity of a temp record if the transaction_uom is different
    -- from the item_primary_uom. It returns true if the conversion is successful. Otherwise, it
    -- insert error messages into the message stack and returns false.
IS
BEGIN
    IF p_csp_mtltxn_rec.transaction_uom <> nvl(p_csp_mtltxn_rec.item_primary_uom_code, p_csp_mtltxn_rec.transaction_uom)
                    THEN
                    p_csp_mtltxn_rec.primary_quantity := inv_convert.inv_um_convert (
                                        item_id       => p_csp_mtltxn_rec.inventory_item_id,
                                        precision     => 38,
                                        from_quantity => p_quantity_convert,
                                        from_unit     => p_csp_mtltxn_rec.transaction_uom,
                                        to_unit       => p_csp_mtltxn_rec.item_primary_uom_code,
                                        from_name     => p_csp_mtltxn_rec.transaction_uom,
                                        to_name       => p_csp_mtltxn_rec.item_primary_uom_code);
                    IF p_csp_mtltxn_rec.primary_quantity = -99999 THEN
                       fnd_message.set_name ('INV', 'INV_INVALID_UOM_CONV');
                       fnd_message.set_token ('VALUE1', p_csp_mtltxn_rec.transaction_uom, TRUE);
                       fnd_message.set_token ('VALUE2', p_csp_mtltxn_rec.item_primary_uom_code, TRUE);
                       fnd_msg_pub.add;
                       RETURN fnd_api.g_false;
                    END IF;
   END IF;
   RETURN fnd_api.g_true;
END Convert_Temp_UOM;

END CSP_MO_MTLTXNS_UTIL;

/
