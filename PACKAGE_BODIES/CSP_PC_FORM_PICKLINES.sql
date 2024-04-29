--------------------------------------------------------
--  DDL for Package Body CSP_PC_FORM_PICKLINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PC_FORM_PICKLINES" AS
/* $Header: cspgtplb.pls 115.11 2002/11/26 06:45:56 hhaugeru ship $ */
-- Start of Commetns --
-- Purpose: wrapper for csp picklist lines private procedure which calls picklist lines table handlers
--
-- MODIFICATION HISTORY
-- Person      Date        Comments
-- ---------   ------      ------------------------------------------
-- klou       04/03/00     Modify procedure to fix bug 1238607.
-- klou       02/08/00     Add standard messages.
-- klou       01/12/00     Replace change AS_UTILITY call with JTF_PLSQL_API.
-- klou       01/03/00     Modify the validations so that when a not null picklist_line_id is passed for
--                         insert operation, it checks whether an identical picklist_line_id exists. It yes,
--                         raise an exception because picklist_line_id should be unique.
-- klou       12/23/99     Add validations to creation_date and last_update_date
-- klou       12/22/99     Add validations.
-- Notes: The following columns should not be null when creating a new record.
--      PICKLIST_LINE_ID                                      NOT NULL
--      CREATED_BY                                            NOT NULL
--      CREATION_DATE                                         NOT NULL
--      LAST_UPDATED_BY                                       NOT NULL
--      LAST_UPDATE_DATE                                      NOT NULL
--      LAST_UPDATE_LOGIN
--      PICKLIST_LINE_NUMBER                                  NOT NULL
--      PICKLIST_HEADER_ID                                    NOT NULL
--      LINE_ID                                               NOT NULL
--      INVENTORY_ITEM_ID                                     NOT NULL
--      UOM_CODE                                              NOT NULL
--      QUANTITY_PICKED                                       NOT NULL
--      TRANSACTION_TEMP_ID                                   NOT NULL
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_PC_FORM_PICKLINES';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspgtplb.pls';
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.LOGIN_ID;

PROCEDURE Validate_And_Write (
          P_Api_Version_Number           IN   NUMBER,
          P_Init_Msg_List                IN   VARCHAR2     := FND_API.G_FALSE,
          P_Commit                       IN   VARCHAR2     := FND_API.G_FALSE,
          p_validation_level             IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
          p_action_code                  IN   NUMBER,    /* 0 = insert, 1 = update, 2 = delete */
          px_PICKLIST_LINE_ID            IN OUT NOCOPY NUMBER,
          p_CREATED_BY                   IN   NUMBER  := FND_API.G_MISS_NUM,
          p_CREATION_DATE                IN   DATE    := FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY              IN   NUMBER  := FND_API.G_MISS_NUM,
          p_LAST_UPDATE_DATE             IN   DATE    := FND_API.G_MISS_DATE,
          p_LAST_UPDATE_LOGIN            IN   NUMBER  := FND_API.G_MISS_NUM,
          p_PICKLIST_LINE_NUMBER         IN   NUMBER  := FND_API.G_MISS_NUM,
          p_picklist_header_id           IN   NUMBER  := FND_API.G_MISS_NUM,
          p_LINE_ID                      IN   NUMBER  := FND_API.G_MISS_NUM,
          p_INVENTORY_ITEM_ID            IN   NUMBER  := FND_API.G_MISS_NUM,
          p_UOM_CODE                     IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_REVISION                     IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_QUANTITY_PICKED              IN   NUMBER    := FND_API.G_MISS_NUM,
          p_TRANSACTION_TEMP_ID          IN   NUMBER    := FND_API.G_MISS_NUM,
          p_ATTRIBUTE_CATEGORY           IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE1                   IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE2                   IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE3                   IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE4                   IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE5                   IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE6                   IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE7                   IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE8                   IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE9                   IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE10                  IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE11                  IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE12                  IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE13                  IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE14                  IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE15                  IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          x_return_status                OUT NOCOPY  VARCHAR2,
          x_msg_count                    OUT NOCOPY  NUMBER,
          x_msg_data                     OUT NOCOPY  VARCHAR2)
    IS
      l_picklist_line_rec   CSP_PICKLIST_LINES_PVT.picklist_line_Rec_Type;
      l_api_version_number        CONSTANT NUMBER  := 1.0;
      l_api_name                  CONSTANT VARCHAR2(20) := 'Validate_And_Write';
      l_msg_data                  VARCHAR2(300);
      l_check_existence           NUMBER := 0;
      l_check_var                 VARCHAR2(20);
      l_return_status             VARCHAR2(1);
      l_msg_count                 NUMBER  := 0;
      l_picklist_header_id       NUMBER := p_picklist_header_id;
      l_commit                    VARCHAR2(1) := FND_API.G_FALSE;
      l_organization_id           NUMBER;
      l_picklist_line_id         NUMBER := 0;
      l_creation_date             DATE := p_creation_date;
      l_last_update_date          DATE := p_last_update_date;
     -- for inserting data, the validation_level should be none
     -- because we do not want to call the core apps standard validations.
      l_validation_level          NUMBER  := FND_API.G_VALID_LEVEL_NONE;
      EXCP_USER_DEFINED           EXCEPTION;
      l_created_by                NUMBER := p_created_by;
      l_last_update_login         NUMBER := p_last_update_login;
      l_last_updated_by           NUMBER := p_last_updated_by;
      Cursor l_Get_Creation_Date_Csr Is
        Select creation_date
        From csp_picklist_lines
        Where picklist_line_id = px_PICKLIST_LINE_ID;

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

   --validating p_action_code
      IF p_action_code NOT IN (0, 1, 2) OR p_action_code IS NULL THEN
            fnd_message.set_name ('INV', 'INV-INVALID ACTION');
            fnd_message.set_token ('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
            fnd_msg_pub.add;
            RAISE EXCP_USER_DEFINED;
      END IF;

      IF p_action_code = 0 THEN
        -- validate the all NOT NULL columns.
         IF px_picklist_line_id IS NOT NULL THEN
           -- valdiate whether an identical picklist_line_id already exists.
              BEGIN
                  SELECt picklist_line_id into l_check_existence
                  FROM CSP_PICKLIST_LINES
                  WHERE picklist_line_id = px_picklist_line_id;

                  fnd_message.set_name ('CSP', 'CSP_DUPLICATE_RECORD');
                  fnd_msg_pub.add;
                  RAISE EXCP_USER_DEFINED;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    NULL;
              END;
         End IF;

            --validating quantity_picked
         IF nvl(p_quantity_picked, fnd_api.g_miss_num) = fnd_api.g_miss_num OR p_quantity_picked < 0 THEN
                fnd_message.set_name ('CSP', 'CSP_INVALID_QTY_PICKED');
                fnd_msg_pub.add;
                RAISE EXCP_USER_DEFINED;
         END IF;

          -- Validate the move order line id
         IF nvl(p_line_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
             FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
             FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_line_id', FALSE);
             FND_MSG_PUB.ADD;
             RAISE EXCP_USER_DEFINED;
         ELSE
            BEGIN
                  select line_id into l_check_existence
                  from csp_moveorder_lines
                  where line_id = p_line_id;
            Exception
                WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name ('CSP', 'CSP_INVALID_MOVEORDER_LINE');
                  fnd_message.set_token ('LINE_ID', to_char(p_line_id), FALSE);
                  fnd_msg_pub.add;
                  RAISE EXCP_USER_DEFINED;
               WHEN TOO_MANY_ROWS THEN
                  -- This is normal. One move order line id can map to many transaction_temp_id's.
                  NULL;
               WHEN OTHERS THEN
                  fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                  fnd_message.set_token('ERR_FIELD', 'p_line_id', FALSE);
                  fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                  fnd_message.set_token('TABLE', 'CSP_MOVEORDER_LINES', FALSE);
                  FND_MSG_PUB.ADD;
                  RAISE EXCP_USER_DEFINED;
            END;
         END IF;

         --validate p_picklist_header_id
         IF nvl(p_picklist_header_id, fnd_api.g_miss_num) =  fnd_api.g_miss_num THEN
              FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
              FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_picklist_header_id', FALSE);
              FND_MSG_PUB.ADD;
              RAISE EXCP_USER_DEFINED;
         ELSE
              BEGIN
                  -- organization id will be used to validate the item id
                  select organization_id into l_organization_id
                  from csp_picklist_headers
                  where picklist_header_id = p_picklist_header_id;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      fnd_message.set_name ('CSP', 'CSP_INVALID_PICKLIST_HEADER');
                      fnd_message.set_token ('HEADER_ID', to_char(p_picklist_header_id), FALSE);
                      fnd_msg_pub.add;
                      RAISE EXCP_USER_DEFINED;
                   WHEN OTHERS THEN
                      fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                      fnd_message.set_token('ERR_FIELD', 'p_picklist_header_id', FALSE);
                      fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                      fnd_message.set_token('TABLE', 'CSP_PICKLIST_HEADERS', FALSE);
                      FND_MSG_PUB.ADD;
                      RAISE EXCP_USER_DEFINED;
              END;
          END IF;

         --validating inventory_item_id
           IF nvl(p_inventory_item_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
                FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
                FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_inventory_item_id ', FALSE);
                FND_MSG_PUB.ADD;
                RAISE EXCP_USER_DEFINED;
           ELSE
                BEGIN
                  -- validate whether the inventory_item_is exists in the given oranization_id
                  select inventory_item_id into l_check_existence
                  from mtl_system_items_kfv
                  where inventory_item_id = p_inventory_item_id
                  and organization_id = l_organization_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       fnd_message.set_name('INV', 'INV-NO ITEM RECROD');
                       fnd_msg_pub.add;
                       RAISE EXCP_USER_DEFINED;
                    WHEN OTHERS THEN
                       fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                          fnd_message.set_token('ERR_FIELD', 'p_inventory_item_id', FALSE);
                          fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                          fnd_message.set_token('TABLE', 'MTL_SYSTEM_ITEMS', FALSE);
                          FND_MSG_PUB.ADD;
                          RAISE EXCP_USER_DEFINED;
                END;
           END IF;

       -- Validate the Picklist_Line_Number
         IF nvl(p_picklist_line_number, 0) < 1 OR p_picklist_line_number = fnd_api.g_miss_num THEN
              FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
              FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_picklist_line_number', FALSE);
              FND_MSG_PUB.ADD;
              RAISE EXCP_USER_DEFINED;
         END IF;

         IF nvl(p_transaction_temp_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
              FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
              FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_transaction_temp_id', FALSE);
              FND_MSG_PUB.ADD;
              RAISE EXCP_USER_DEFINED;
         ELSE
              BEGIN
                  -- validate whether the transaction temp id is valid
                 select transaction_temp_id into l_check_existence
                 from mtl_material_transactions_temp
                 where transaction_temp_id = p_transaction_temp_id
                 and inventory_item_id = p_inventory_item_id
                 and move_order_line_id = p_line_id;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      fnd_message.set_name ('CSP', 'CSP_INVALID_TXN_TEMP_ID');
                      fnd_message.set_token ('ID', to_char(px_picklist_line_id), FALSE);
                      fnd_msg_pub.add;
                      RAISE EXCP_USER_DEFINED;
                  WHEN OTHERS THEN
                      fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                      fnd_message.set_token('ERR_FIELD', 'p_transaction_temp_id', FALSE);
                      fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                      fnd_message.set_token('TABLE', 'MTL_MATERIAL_TRANSACTIONS_TEMP', FALSE);
                      FND_MSG_PUB.ADD;
                      RAISE EXCP_USER_DEFINED;
              END;
         END IF;

         IF nvl(p_uom_code, fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
              FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
              FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_uom_code', FALSE);
              FND_MSG_PUB.ADD;
              RAISE EXCP_USER_DEFINED;
         ELSE
             -- validate the UOM code
              BEGIN
                 select UOM_CODE into l_check_var
                 from mtl_units_of_measure
                 where UOM_CODE = p_uom_code;
              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    fnd_message.set_name('INV', 'INV_UOM_NOTFOUND');
                    fnd_message.set_token('UOM', p_uom_code, FALSE);
                    fnd_msg_pub.add;
                    RAISE EXCP_USER_DEFINED;
                 WHEN OTHERS THEN
                    fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                    fnd_message.set_token('ERR_FIELD', 'p_line_id', FALSE);
                    fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                    fnd_message.set_token('TABLE', 'MTL_UNITS_OF_MEASURE', FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
              END;
         END IF;

      -- check creation_date and last_update_date
         IF nvl(l_creation_date, fnd_api.g_miss_date) = fnd_api.g_miss_date THEN
              l_creation_date := sysdate;
         END IF;

         IF nvl(l_last_update_date, fnd_api.g_miss_date) = fnd_api.g_miss_date THEN
              l_last_update_date := sysdate;
         END IF;

         IF nvl(l_created_by, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
              l_created_by := g_user_id;
         END IF;

         IF nvl(l_last_update_login, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
              l_last_update_login := g_login_id;
         END IF;

         IF nvl(l_last_updated_by, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
              l_last_updated_by := g_user_id;
         END IF;

     ELSIF p_action_code = 1 THEN
          IF px_picklist_line_id IS NULL THEN
              FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
              FND_MESSAGE.SET_TOKEN ('PARAMETER', 'px_picklist_line_id', FALSE);
              FND_MSG_PUB.ADD;
              RAISE EXCP_USER_DEFINED;
          ELSE
              BEGIN
                  select picklist_line_id into l_check_existence
                  from  csp_picklist_lines
                  where picklist_line_id = px_picklist_line_id;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      fnd_message.set_name ('CSP', 'CSP_INVALID_PICKLIST');
                      fnd_message.set_token ('LINE_ID', to_char(px_picklist_line_id), FALSE);
                      fnd_msg_pub.add;
                      RAISE EXCP_USER_DEFINED;
                  WHEN OTHERS THEN
                          fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                          fnd_message.set_token('ERR_FIELD', 'px_picklist_line_id', FALSE);
                          fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                          fnd_message.set_token('TABLE', 'CSP_PICKLIST_LINES', FALSE);
                          FND_MSG_PUB.ADD;
                          RAISE EXCP_USER_DEFINED;
              END;
          END IF;

          -- validate the pick list header id associated with the pick list line id
            IF nvl(p_picklist_header_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
                --validate the pick list header id.
                BEGIN
                    -- for bug 1238607.
                    -- Since we are updating the picklist_header_id, we do not need to check whether it exists in the
                    -- csp_picklist_lines table. Instead, we need to make sure that it exists in the csp_picklist_headers
                    -- table.
                    select picklist_header_id into l_check_existence
                    from csp_picklist_headers
                    where picklist_header_id = p_picklist_header_id;

                    -- find the organization_id based on the p_pick_line_id
                    select organization_id into l_organization_id
                    from csp_picklist_headers
                    where picklist_header_id = p_picklist_header_id;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        fnd_message.set_name('CSP', 'CSP_INVALID_PICKLIST_HEADER');
                        fnd_message.set_token ('HEADER_ID', to_char(p_picklist_header_id), FALSE);
                     -- l_msg_data := 'Pick List Header ID does not exist in the organization.';
                        RAISE EXCP_USER_DEFINED;
                    WHEN OTHERS THEN
                        fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                        fnd_message.set_token('ERR_FIELD', 'px_picklist_line_id', FALSE);
                        fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                        fnd_message.set_token('TABLE', 'CSP_PICKLIST_LINES', FALSE);
                        FND_MSG_PUB.ADD;
                        RAISE EXCP_USER_DEFINED;
                END;

           ELSE -- if the header_id is null
                -- find the organization_id based on the p_pick_line_id
                    select organization_id into l_organization_id
                    from csp_picklist_headers
                    where picklist_header_id = (select picklist_header_id
                                                    from csp_picklist_lines
                                                    where picklist_line_id = px_picklist_line_id);
           END IF;

       --validating inventory_item_id
           IF nvl(p_inventory_item_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
                BEGIN
                  -- validate whether the inventory_item_is exists in the given oranization_id
                  select inventory_item_id into l_check_existence
                  from mtl_system_items_kfv
                  where inventory_item_id = p_inventory_item_id
                  and organization_id = l_organization_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       fnd_message.set_name('INV', 'INV-NO ITEM RECROD');
                       fnd_msg_pub.add;
                       RAISE EXCP_USER_DEFINED;
                    WHEN OTHERS THEN
                       fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                          fnd_message.set_token('ERR_FIELD', 'p_inventory_item_id', FALSE);
                          fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                          fnd_message.set_token('TABLE', 'MTL_SYSTEM_ITEMS', FALSE);
                          FND_MSG_PUB.ADD;
                          RAISE EXCP_USER_DEFINED;
                END;
           END IF;

       -- Validate the move order line id
           IF nvl(p_line_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
              BEGIN
                    select line_id into l_check_existence
                    from csp_moveorder_lines
                    where line_id = p_line_id;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    fnd_message.set_name ('CSP', 'CSP_INVALID_MOVEORDER_LINE');
                    fnd_message.set_token ('LINE_ID', to_char(p_line_id), FALSE);
                    fnd_msg_pub.add;
                    RAISE EXCP_USER_DEFINED;
                 WHEN TOO_MANY_ROWS THEN
                    -- This is normal. One move order line id can map to many transaction_temp_id's.
                    NULL;
                 WHEN OTHERS THEN
                    fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                    fnd_message.set_token('ERR_FIELD', 'p_line_id', FALSE);
                    fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                    fnd_message.set_token('TABLE', 'CSP_MOVEORDER_LINES', FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
              END;
           END IF;

           IF nvl(p_uom_code, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
             -- validate the UOM code
              BEGIN
                 select UOM_CODE into l_check_var
                 from mtl_units_of_measure
                 where UOM_CODE = p_uom_code;
              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    fnd_message.set_name('INV', 'INV_UOM_NOTFOUND');
                    fnd_message.set_token('UOM', p_uom_code, FALSE);
                    fnd_msg_pub.add;
                    RAISE EXCP_USER_DEFINED;
                 WHEN OTHERS THEN
                    fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                    fnd_message.set_token('ERR_FIELD', 'p_line_id', FALSE);
                    fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                    fnd_message.set_token('TABLE', 'MTL_UNITS_OF_MEASURE', FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
              END;
           END IF;

         IF nvl(p_transaction_temp_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num  THEN
              BEGIN
                  -- validate whether the transaction temp id is valid
                 select transaction_temp_id into l_check_existence
                 from mtl_material_transactions_temp
                 where transaction_temp_id = p_transaction_temp_id;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      fnd_message.set_name ('CSP', 'CSP_INVALID_TXN_TEMP_ID');
                      fnd_message.set_token ('ID', to_char(px_picklist_line_id), FALSE);
                      fnd_msg_pub.add;
                      RAISE EXCP_USER_DEFINED;
                  WHEN OTHERS THEN
                      fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                      fnd_message.set_token('ERR_FIELD', 'p_transaction_temp_id', FALSE);
                      fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                      fnd_message.set_token('TABLE', 'MTL_MATERIAL_TRANSACTIONS_TEMP', FALSE);
                      FND_MSG_PUB.ADD;
                      RAISE EXCP_USER_DEFINED;
              END;
          END IF;

        -- validate the creation_date
           IF nvl(l_creation_date, fnd_api.g_miss_date) = fnd_api.g_miss_date THEN
              Open l_Get_Creation_Date_Csr;
              Fetch l_Get_Creation_Date_Csr into l_creation_date;
              If l_Get_Creation_Date_Csr%NOTFOUND Then
                  Close l_Get_Creation_Date_Csr;
                    fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                    fnd_message.set_token('ERR_FIELD', 'p_cretaion_date', FALSE);
                    fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                    fnd_message.set_token('TABLE', 'CSP_PICKLIST_LINES', FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
              End if;
              Close l_Get_Creation_Date_Csr;
           End if;

          IF nvl(l_last_update_date, fnd_api.g_miss_date) = fnd_api.g_miss_date THEN
              l_last_update_date := sysdate;
          END IF;

    ELSE -- p_action_code = 2
           IF px_picklist_line_id IS NULL THEN
              FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
              FND_MESSAGE.SET_TOKEN ('PARAMETER', 'px_picklist_line_id', FALSE);
              FND_MSG_PUB.ADD;
              RAISE EXCP_USER_DEFINED;
          ELSE
              BEGIN
                  select picklist_line_id into l_check_existence
                  from  csp_picklist_lines
                  where picklist_line_id = px_picklist_line_id;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      fnd_message.set_name ('CSP', 'CSP_INVALID_PICKLIST');
                      fnd_message.set_token ('LINE_ID', to_char(px_picklist_line_id), FALSE);
                      fnd_msg_pub.add;
                      RAISE EXCP_USER_DEFINED;
                  WHEN OTHERS THEN
                          fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                          fnd_message.set_token('ERR_FIELD', 'px_picklist_line_id', FALSE);
                          fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                          fnd_message.set_token('TABLE', 'CSP_PICKLIST_LINES', FALSE);
                          FND_MSG_PUB.ADD;
                          RAISE EXCP_USER_DEFINED;
              END;
          END IF;
    END IF;


    -- create picklist line record type
    l_picklist_line_rec.picklist_line_id    := px_picklist_line_id;
    l_picklist_line_rec.created_by          := nvl(l_CREATED_BY, fnd_api.g_miss_num);
    l_picklist_line_rec.creation_date       := l_CREATION_DATE;
    l_picklist_line_rec.last_updated_by     := nvl(l_LAST_UPDATED_BY, fnd_api.g_miss_num);
    l_picklist_line_rec.last_update_date    := l_LAST_UPDATE_DATE;
    l_picklist_line_rec.last_update_login   := l_LAST_UPDATE_LOGIN;
    l_picklist_line_rec.picklist_line_number:= nvl(p_PICKLIST_LINE_NUMBER, fnd_api.g_miss_num);
    l_picklist_line_rec.picklist_header_id  := nvl(p_picklist_header_id, fnd_api.g_miss_num);
    l_picklist_line_rec.LINE_ID             := nvl(p_LINE_ID, fnd_api.g_miss_num);
    l_picklist_line_rec.INVENTORY_ITEM_ID   := nvl(p_INVENTORY_ITEM_ID, fnd_api.g_miss_num);
    l_picklist_line_rec.UOM_CODE            := nvl(p_UOM_CODE, fnd_api.g_miss_char);
    l_picklist_line_rec.REVISION            := p_REVISION;
    l_picklist_line_rec.QUANTITY_PICKED     := nvl(p_QUANTITY_PICKED, fnd_api.g_miss_num);
    l_picklist_line_rec.TRANSACTION_TEMP_ID := nvl(p_TRANSACTION_TEMP_ID, fnd_api.g_miss_num);
    l_picklist_line_rec.ATTRIBUTE_CATEGORY  := p_ATTRIBUTE_CATEGORY;
    l_picklist_line_rec.ATTRIBUTE1          := p_ATTRIBUTE1;
    l_picklist_line_rec.ATTRIBUTE2          := p_ATTRIBUTE2;
    l_picklist_line_rec.ATTRIBUTE3          := p_ATTRIBUTE3;
    l_picklist_line_rec.ATTRIBUTE4          := p_ATTRIBUTE4;
    l_picklist_line_rec.ATTRIBUTE5          := p_ATTRIBUTE5;
    l_picklist_line_rec.ATTRIBUTE6          := p_ATTRIBUTE6;
    l_picklist_line_rec.ATTRIBUTE7          := p_ATTRIBUTE7;
    l_picklist_line_rec.ATTRIBUTE8          := p_ATTRIBUTE8;
    l_picklist_line_rec.ATTRIBUTE9          := p_ATTRIBUTE9;
    l_picklist_line_rec.ATTRIBUTE10         := p_ATTRIBUTE10;
    l_picklist_line_rec.ATTRIBUTE11         := p_ATTRIBUTE11;
    l_picklist_line_rec.ATTRIBUTE12         := p_ATTRIBUTE12;
    l_picklist_line_rec.ATTRIBUTE13         := p_ATTRIBUTE13;
    l_picklist_line_rec.ATTRIBUTE14         := p_ATTRIBUTE14;
    l_picklist_line_rec.ATTRIBUTE15         := p_ATTRIBUTE15;


    IF p_action_code = 0 THEN
      csp_picklist_lines_pvt.Create_picklist_lines(
        P_Api_Version_Number => p_api_version_number,
        P_Init_Msg_List      => P_Init_Msg_List,
        P_Commit             => P_Commit,
        p_validation_level   => l_validation_level,
        P_picklist_line_Rec  => l_picklist_line_rec,
        X_PICKLIST_LINE_ID  => l_picklist_line_id,
        X_Return_Status      => x_return_status,
        X_Msg_Count          => x_msg_count,
        X_Msg_Data           => x_msg_data
      );

    ELSIF p_action_code = 1 THEN
      csp_picklist_lines_pvt.Update_picklist_lines(
        P_Api_Version_Number        => p_api_version_number,
        P_Init_Msg_List             => P_Init_Msg_List,
        P_Commit                    => P_Commit,
        p_validation_level          => l_validation_level,
        --P_Identity_Salesforce_Id     IN   NUMBER       := NULL,
        P_picklist_line_Rec         => l_picklist_line_rec,
        X_Return_Status             => l_return_status,
        X_Msg_Count                 => x_msg_count,
        X_Msg_Data                  => x_msg_data
      );

    ELSIF p_action_code = 2 THEN
      csp_picklist_lines_pvt.Delete_picklist_lines(
        P_Api_Version_Number         => p_api_version_number,
        P_Init_Msg_List              => P_Init_Msg_List,
        p_Commit                     => P_Commit,
        p_validation_level           => l_validation_level,
        --P_identity_salesforce_id     IN   NUMBER       := NULL,
        P_picklist_line_Rec          => l_picklist_line_rec,
        X_Return_Status              => l_return_status,
        X_Msg_Count                  => x_msg_count,
        X_Msg_Data                   => x_msg_data
      );

    END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    px_picklist_line_id := l_picklist_line_id;
    IF fnd_api.to_boolean(p_commit) THEN
         commit work;
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
            fnd_message.set_token ('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
            fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
            fnd_msg_pub.add;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := fnd_api.g_ret_sts_error;

END Validate_And_Write;

END CSP_PC_FORM_PICKLINES;

/
