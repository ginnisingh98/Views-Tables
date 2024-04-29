--------------------------------------------------------
--  DDL for Package Body CSP_PICK_SL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PICK_SL_UTIL" AS
/*$Header: cspgtslb.pls 120.0 2005/05/25 11:31:02 appldev noship $*/
-- Start of Comments
-- Package name     : CSP_Pick_SL_Util
-- Purpose          : A wrapper to prepare data to call the update, delete and insert procedures of the
--                    csp_pick_serial_lots_PVT.
-- MODIFICATION HISTORY
-- Person      Date        Comments
-- ---------   ------      ------------------------------------------
-- klou       01/28/00     Created.
--
-- NOTES: If validations have been done in the precedent procedure from which this one is being called, doing a
--  full validation here is unnecessary. To avoid repeating the same validations, you can set the
--  p_validation_level to fnd_api.g_valid_level_none when making the procedure call. However, it is your
--  responsibility to make sure all proper validations have been done before calling this procedure.
--  You are recommended to let this procedure handle the validations if you are not sure.
--
-- NOTES: This procedure does not consider the fnd_api.g_miss_num and fnd_api.g_miss_char.
--
-- CAUTIONS: This procedure *ALWAYS* calls other procedures with validation_level set to FND_API.G_VALID_LEVEL_NONE.
--  If you do not do your own validations before calling this procedure, you should set the p_validation_level
--  to FND_API.G_VALID_LEVEL_FULL when making the call.
--
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_Pick_SL_Util';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspgtslb.pls';
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.LOGIN_ID;

PROCEDURE Validate_And_Write (
       P_Api_Version_Number        IN        NUMBER,
       P_Init_Msg_List             IN        VARCHAR2     := FND_API.G_TRUE,
       P_Commit                    IN        VARCHAR2     := FND_API.G_FALSE,
       p_validation_level          IN        NUMBER       := FND_API.G_VALID_LEVEL_FULL,
       p_action_code               IN        NUMBER,
       px_PICKLIST_SERIAL_LOT_ID   IN OUT NOCOPY    NUMBER,
       p_CREATED_BY                IN NUMBER,
       p_CREATION_DATE             IN DATE,
       p_LAST_UPDATED_BY           IN NUMBER,
       p_LAST_UPDATE_DATE          IN DATE,
       p_LAST_UPDATE_LOGIN         IN NUMBER,
       p_PICKLIST_LINE_ID          IN NUMBER,
       p_ORGANIZATION_ID           IN NUMBER,
       p_INVENTORY_ITEM_ID         IN NUMBER,
       p_QUANTITY                  IN NUMBER,
       p_LOT_NUMBER                IN VARCHAR2,
       p_SERIAL_NUMBER             IN VARCHAR2,
       X_Return_Status           OUT NOCOPY     VARCHAR2,
       X_Msg_Count               OUT NOCOPY     NUMBER,
       X_Msg_Data                OUT NOCOPY     VARCHAR2
    )
 IS
    -- csp standard declarations
    l_api_version_number        CONSTANT NUMBER  := 1.0;
    l_api_name                  CONSTANT VARCHAR2(30) := 'Validate_And_Write';
    l_msg_data                  VARCHAR2(300);
    l_check_existence           NUMBER := 0;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER  := 0;
    l_commit                    VARCHAR2(1) := FND_API.G_FALSE;
    l_validation_level          NUMBER  := FND_API.G_VALID_LEVEL_NONE;
    EXCP_USER_DEFINED           EXCEPTION;

    -- customers declarations
    l_picklist_Serial_Lot_ID        NUMBER := NULL;
    l_psl_rec               csp_pick_serial_lots_PVT.psl_Rec_Type;

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
            IF p_validation_level = fnd_api.g_valid_level_full THEN
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
             NULL;
        END IF;


      IF p_action_code IN (0, 1) THEN
        IF p_validation_level = fnd_api.g_valid_level_full THEN
         -- valide packlist_line_id
          IF p_picklist_line_id IS NULL THEN
              FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
              FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_packlist_line_id', TRUE);
              FND_MSG_PUB.ADD;
              RAISE EXCP_USER_DEFINED;
          END IF;
            BEGIN
                SELECT picklist_line_id INTO l_check_existence
                FROM csp_picklist_lines
                WHERE picklist_line_id = p_picklist_line_id;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   -- the following error message needs to be changed to the appropriate one once Apps is up again.
                    FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
                    FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_packlist_line_id', TRUE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
                WHEN OTHERS THEN
                    fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                    fnd_message.set_token('ERR_FIELD', 'p_picklist_line_id', TRUE);
                    fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                    fnd_message.set_token('TABLE', 'csp_picklist_lines', TRUE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
           END;
      END IF;
    END IF;

    IF p_action_code IN (1, 2) THEN
        IF px_PICKLIST_SERIAL_LOT_ID IS NULL THEN
            FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
            FND_MESSAGE.SET_TOKEN ('PARAMETER', 'px_picklist_serial_lot_id', TRUE);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        END IF;

        BEGIN
            -- validate whether the px_picklist_serial_lot_id exists.
            SELECT picklist_serial_lot_id INTO l_check_existence
            FROM CSP_Picklist_Serial_Lots
            WHERE picklist_serial_lot_id = px_picklist_serial_lot_id
            AND picklist_line_id = p_picklist_line_id;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                   -- the following error message needs to be changed to the appropriate one once Apps is up again.
                    FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
                    FND_MESSAGE.SET_TOKEN ('PARAMETER', 'px_picklist_serial_lot_id', TRUE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
                WHEN OTHERS THEN
                    fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                    fnd_message.set_token('ERR_FIELD', 'px_picklist_serial_lot_id', TRUE);
                    fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                    fnd_message.set_token('TABLE', 'csp_picklist_serial_lots', TRUE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
       END;
    END IF;


         l_psl_rec.PICKLIST_SERIAL_LOT_ID :=  px_PICKLIST_SERIAL_LOT_ID;
         l_psl_rec.CREATED_BY             :=  p_CREATED_BY;
         l_psl_rec.CREATION_DATE          :=  p_CREATION_DATE;
         l_psl_rec.LAST_UPDATED_BY        :=  p_LAST_UPDATED_BY;
         l_psl_rec.LAST_UPDATE_DATE       :=  p_LAST_UPDATE_DATE;
         l_psl_rec.LAST_UPDATE_LOGIN      :=  p_LAST_UPDATE_LOGIN;
         l_psl_rec.PICKLIST_LINE_ID       :=  p_PICKLIST_LINE_ID;
         l_psl_rec.ORGANIZATION_ID        :=  p_ORGANIZATION_ID;
         l_psl_rec.INVENTORY_ITEM_ID      :=  p_INVENTORY_ITEM_ID;
         l_psl_rec.QUANTITY               :=  p_QUANTITY;
         l_psl_rec.LOT_NUMBER             :=  p_LOT_NUMBER;
         l_psl_rec.SERIAL_NUMBER          :=  p_SERIAL_NUMBER;


       IF p_action_code = 0 THEN
        -- call the csp_pick_serial_lots_PVT.Create_pick_serial_lots
            IF p_CREATION_DATE IS NULL THEN
               l_psl_rec.CREATION_DATE := sysdate;
            END IF;

            IF p_LAST_UPDATE_DATE IS NULL THEN
               l_psl_rec.LAST_UPDATE_DATE := sysdate;
            END IF;

            csp_pick_serial_lots_PVT.Create_pick_serial_lots (
              P_Api_Version_Number        => l_Api_Version_Number,
              P_Init_Msg_List             => p_Init_Msg_List,
              P_Commit                    => l_Commit,
              p_validation_level          => l_validation_level,
              P_psl_Rec                   => l_psl_rec,
              X_PICKLIST_SERIAL_LOT_ID    => l_picklist_serial_lot_id,
              X_Return_Status             => l_return_status,
              X_Msg_Count                 => l_msg_count,
              X_Msg_Data                  => l_msg_data);

         ELSIF p_action_code = 1 THEN
        -- call the csp_pick_serial_lots_PVT.Update_pick_serial_lots
            IF p_LAST_UPDATE_DATE IS NULL THEN
               l_psl_rec.LAST_UPDATE_DATE := sysdate;
            END IF;

            csp_pick_serial_lots_PVT.Update_pick_serial_lots(
              P_Api_Version_Number         => l_Api_Version_Number,
              P_Init_Msg_List              => p_Init_Msg_List,
              P_Commit                     => l_Commit,
              p_validation_level           => l_validation_level,
              P_Identity_Salesforce_Id     => NULL,
              P_psl_Rec                    => l_psl_rec,
              X_Return_Status             => l_return_status,
              X_Msg_Count                 => l_msg_count,
              X_Msg_Data                  => l_msg_data);

         ELSIF p_action_code = 2 THEN
        -- call the csp_pick_serial_lots_PVT.Create_pick_serial_lots
             csp_pick_serial_lots_PVT.Delete_pick_serial_lots(
              P_Api_Version_Number         => l_Api_Version_Number,
              P_Init_Msg_List              => p_Init_Msg_List,
              P_Commit                     => l_Commit,
              p_validation_level           => l_validation_level,
              P_Identity_Salesforce_Id     => NULL,
              P_psl_Rec                    => l_psl_rec,
              X_Return_Status             => l_return_status,
              X_Msg_Count                 => l_msg_count,
              X_Msg_Data                  => l_msg_data);

         ELSE
             fnd_message.set_name('INV', 'INV-INVALID ACTION');
             fnd_message.set_token('ROUTINE', l_api_name, TRUE);
             fnd_msg_pub.add;
             RAISE EXCP_USER_DEFINED;
       END IF;

             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSE
                x_return_status := fnd_api.g_ret_sts_success;
                px_PICKLIST_SERIAL_LOT_ID := l_picklist_serial_lot_id;
                IF fnd_api.to_boolean(p_commit) THEN
                    commit work;
                END IF;
             END IF;
EXCEPTION
        WHEN EXCP_USER_DEFINED THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            fnd_msg_pub.count_and_get
            ( p_count => x_msg_count
            , p_data  => x_msg_data);

            --for debugging purpose
           -- x_msg_data := l_msg_data;

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
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Validate_And_Write;

END CSP_Pick_SL_Util;

/
